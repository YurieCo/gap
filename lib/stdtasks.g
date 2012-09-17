# To avoid deadlock, object locks are acquired in the following
# priority order:
#
# Triggers > Tasks/Milestones > TASK_QUEUE

TASK_QUEUE := ShareObj( rec (
  ready_tasks := [],
  workers := [],
  active_count := 0,
  max_active := 4,
) );

CURRENT_TASK := fail;
MakeThreadLocal("CURRENT_TASK");

TASKS := AtomicRecord( rec (

  WorkerThread := function(context)
    local task;
    WaitSemaphore(context.semaphore);
    while true do
      WaitSemaphore(context.semaphore);
      atomic context.task_container do
        task := context.task_container.task;
        context.task_container.task := fail;
      od;
      if not IsIdenticalObj(task, fail) then
        CURRENT_TASK := task;
        TASKS.ExecuteTask(task, context);
        CURRENT_TASK := fail;
        atomic TASK_QUEUE do
          Add(TASK_QUEUE.workers, context);
          TASK_QUEUE.active_count := TASK_QUEUE.active_count - 1;
        od;
        TASKS.WakeWorker();
      fi;
    od;
  end,
    
  WakeWorker := function()
    local task;
    atomic TASK_QUEUE do
      while TASK_QUEUE.active_count < TASK_QUEUE.max_active and
            Length(TASK_QUEUE.ready_tasks) > 0 do
        task := TASK_QUEUE.ready_tasks[1];
	      # Workaround because dynamic retyping of list breaks the
	      # following statement:
        # Remove(TASK_QUEUE.ready_tasks, 1);
        TASK_QUEUE.ready_tasks :=
          TASK_QUEUE.ready_tasks{[2..Length(TASK_QUEUE.ready_tasks)]};
        MigrateSingleObj(TASK_QUEUE.ready_tasks, TASK_QUEUE);
        atomic task do
          if IsIdenticalObj(task.worker, fail) then
            if Length(TASK_QUEUE.workers) > 0 then
              task.worker := TASK_QUEUE.workers[1];
              Remove(TASK_QUEUE.workers, 1);
            else
              task.worker := TASKS.NewWorker();
            fi;
            atomic task.worker.task_container do
              task.worker.task_container.task := task;
            od;
          fi;
          if not IsIdenticalObj(task.body, fail) then
            TASK_QUEUE.active_count := TASK_QUEUE.active_count + 1;
          fi;
          SignalSemaphore(task.worker.semaphore);
        od;
      od;
    od;
  end,
    
  ExecuteTask := function(task, context)
    local error, result, async, notify, trigger, i, body, args;
    atomic task do
      task.started := true;
      async := task.async;
      atomic task.region do
        for i in [1..Length(task.adopt)] do
          if task.adopt[i] then
            AdoptObj(task.args[i]);
          fi;
        od;
      od;
      body := task.body;
      args := ShallowCopy(task.args);
    od;
    result := CALL_WITH_CATCH(body, args);
    error := not result[1];
    if error or Length(result) = 1 then
      result := fail;
    else
      result := result[2];
    fi;
    if error then
      Print("Task Error: ", result, "\n");
    fi;
    atomic task do
      task.complete := true;
      if not async then
        if IsThreadLocal(result) then
          atomic task.region do
            task.result := MigrateObj(result, task.region);
          od;
          task.adopt_result := true;
        else
          task.result := result;
          task.adopt_result := false;
        fi;
      fi;
      notify := AdoptSingleObj(task.notify);
      task.notify := MigrateSingleObj([], task);
    od;
    for trigger in notify do
      TASKS.FireTrigger(trigger);
    od;
  end,
    
  NewWorker := function()
    local context, thread;
    context := MakeWriteOnceAtomic(rec(
                       semaphore := CreateSemaphore(),
                       task_container := ShareSingleObj(rec(task := fail)),
                       ));
    thread := CreateThread(TASKS.WorkerThread, context);
    context.thread := thread;
    SignalSemaphore(context.semaphore);
    return context;
  end,
    
  NewTask := function(func, args)
    local task, arg;
    task := rec(
      args := [],
      adopt := [],
      result := fail,
      adopt_result := fail,
      region := NewRegion(),
      complete := false,
      started := false,
      async := false,
      body := func,
      worker := fail,
      conditions := [],
      notify := [],
    );
    for arg in args do
      if IsThreadLocal(arg) then
        Add(task.args, LockAndMigrateObj(CopyRegion(arg), task.region));
        Add(task.adopt, true);
      else
        Add(task.args, arg);
        Add(task.adopt, false);
      fi;
    od;
    return task;
  end,

  MakePseudoTask := function()
    local task;
    task := TASKS.NewTask(fail, []);
    task.worker := TASKS.PseudoWorker();
    CURRENT_TASK := task;
  end,

  PseudoWorker := function()
    local context;
    context := MakeWriteOnceAtomic(rec(
      region := NewRegion(),
      semaphore := CreateSemaphore(),
      thread := fail,
    ));
    return context;
  end,

  NewMilestone := function(contributions)
    local c;
    c := Set(contributions);
    return rec(
      achieved := Set([]),
      targets := Immutable(c),
      complete := Length(c) = 0,
      notify := [],
    );
  end,

  # Triggers are built from sets of conditions.
  # Conditions are shared records with the requirement
  # that they have a boolean 'complete' element, which
  # is true if the condition is met and a 'notify' list
  # of triggers, which gets invoked when the condition
  # has been met.
  #
  # Triggers can be either a conjunction or a disjunction
  # of conditions right now. Later on, it may be useful
  # to have more complex ways of composing them.

  BuildTrigger := function(task, is_conjunction)
    return rec(
               task := task,
               conditions := task.conditions,
               done := false,
               is_conjunction := is_conjunction,
               );
  end,

  FireTrigger := function(trigger)
    local cond, done, task, tasks;
    done := false;
    atomic readwrite trigger do
      if trigger.done then
        return;
      fi;
      if trigger.is_conjunction then
        done := true;
        for cond in trigger.conditions do
          atomic readonly cond do
            if not cond.complete then
              done := false;
              break;
            fi;
          od;
        od;
      else
        done := false;
        for cond in trigger.conditions do
          atomic readonly cond do
            if cond.complete then
              done := true;
              break;
            fi;
          od;
        od;
      fi;
      trigger.done := done;
      if not done then
        return;
      fi;
      task := trigger.task;
    od;
    atomic task, TASK_QUEUE do
      if IsIdenticalObj(task.worker, fail) then
        Add(TASK_QUEUE.ready_tasks, task);
        TASKS.WakeWorker();
      else
	    # Workaround because dynamic retyping of list breaks the
	    # following statement:
            # Add(TASK_QUEUE.ready_tasks, task, 1);
        tasks := [ task ];
        Append(tasks, TASK_QUEUE.ready_tasks);
        TASK_QUEUE.ready_tasks := MigrateSingleObj(tasks, TASK_QUEUE);
        TASKS.WakeWorker();
      fi;
    od;
  end,
    
  ActivateTrigger := function(trigger)
    local cond;
    atomic trigger do
      for cond in trigger.conditions do
        atomic cond do
          if not cond.complete then
            Add(cond.notify, trigger);
          fi;
        od;
      od;
    od;
    # Recheck conditions, because they may have fired
    # in the meantime.
    TASKS.FireTrigger(trigger);
  end,

  QueueTask := function(task)
    local trigger;
    atomic task, TASK_QUEUE do
      if Length(task.conditions) = 0 then
        Add(TASK_QUEUE.ready_tasks, task);
        TASKS.WakeWorker();
        return;
      else
        trigger := TASKS.BuildTrigger(task, true);
        if trigger.done then
          Add(TASK_QUEUE.ready_tasks, task);
          TASKS.WakeWorker();
          return;
        fi;
      fi;
    od;
    # We get here if we have a triggered task with
    # unmet conditions.
    ShareObj(trigger);
    TASKS.ActivateTrigger(trigger);
  end,
) );

NewMilestone := function(arg)
  local milestone;
  if Length(arg) = 0 then
    milestone := TASKS.NewMilestone([0]);
  elif Length(arg) = 1 and not IS_STRING(arg[1]) and IS_LIST(arg[1]) then
    milestone := TASKS.NewMilestone(arg[1]);
  else
    milestone := TASKS.NewMilestone(arg);
  fi;
  return ShareObj(milestone);
end;

ContributeToMilestone := function(milestone, contribution)
  local trigger, notify;
  atomic milestone do
    if not contribution in milestone.targets then
      Error("ContributeToMilestone: Milestone does not have such a contribution");
    fi;
    if milestone.complete then
      return;
    fi;
    AddSet(milestone.achieved, Immutable(contribution));
    if Length(milestone.achieved) < Length(milestone.targets) then
      return;
    fi;
    milestone.complete := true;
    notify := AdoptSingleObj(milestone.notify);
    milestone.notify := MigrateSingleObj([], milestone);
  od;
  for trigger in notify do
    TASKS.FireTrigger(trigger);
  od;
end;

AchieveMilestone := function(milestone)
  local trigger, notify;
  atomic milestone do
    milestone.achieved := CopyRegion(milestone.targets);
    milestone.complete := true;
    notify := AdoptSingleObj(milestone.notify);
    milestone.notify := MigrateSingleObj([], milestone);
  od;
  for trigger in notify do
    TASKS.FireTrigger(trigger);
  od;
end;

IsMilestoneAchieved := atomic function(readonly milestone)
  return milestone.complete;
end;

RunTask := function(arg)
  local task;
  task := TASKS.NewTask(arg[1], arg{[2..Length(arg)]});
  task.started := true;
  ShareObj(task);
  TASKS.QueueTask(task);
  return task;
end;

RunAsyncTask := function(arg)
  local task;
  task := TASKS.NewTask(arg[1], arg{[2..Length(arg)]});
  task.async := true;
  task.started := true;
  ShareObj(task);
  TASKS.QueueTask(task);
  return task;
end;

DelayTask := function(arg)
  local task;
  task := TASKS.NewTask(arg[1], arg{[2..Length(arg)]});
  ShareObj(task);
  return task;
end;

ExecuteTask := atomic function(readwrite task)
  if not task.started and Length(task.conditions) = 0 then
    task.started := true;
    TASKS.QueueTask(task);
  fi;
end;

MakeAsyncTask := atomic function(readwrite task)
  if not task.started then
    task.async := true;
  else
    Error("Cannot make a task asynchronous after it has been started");
  fi;
end;

ScheduleTask := function(arg)
  local cond, task, trigger;
  cond := arg[1];
  atomic readonly cond do
    if not IS_LIST(cond) then
      cond := [ cond ];
    fi;
  od;
  task := TASKS.NewTask(arg[2], arg{[3..Length(arg)]});
  task.conditions := MakeReadOnlyObj(cond);
  ShareObj(task);
  TASKS.QueueTask(task);
  return task;
end;

ScheduleAsyncTask := function(arg)
  local cond, task, trigger;
  cond := arg[1];
  atomic readonly cond do
    if not IS_LIST(cond) then
      cond := [ cond ];
    fi;
  od;
  task := TASKS.NewTask(arg[2], arg{[3..Length(arg)]});
  task.async := true;
  task.conditions := MakeReadOnlyObj(cond);
  ShareObj(task);
  TASKS.QueueTask(task);
  return task;
end;

WAIT_TASK := function(conditions, is_conjunction)
  local task, trigger, suspend, semaphore;
  task := CURRENT_TASK;
  if IsIdenticalObj(task, fail) then
    # We are actually calling this from the main thread
    TASKS.MakePseudoTask();
    task := CURRENT_TASK;
  fi;
  atomic task do
    suspend := not IsIdenticalObj(task.body, fail);
    task.conditions := MakeReadOnlyObj(conditions);
    semaphore := task.worker.semaphore;
    trigger := TASKS.BuildTrigger(task, is_conjunction);
  od;
  if not trigger.done then
    if suspend then
      atomic TASK_QUEUE do
	TASK_QUEUE.active_count := TASK_QUEUE.active_count - 1;
      od;
    fi;
    ShareObj(trigger);
    TASKS.ActivateTrigger(trigger);
    while true do
      TASKS.WakeWorker();
      WaitSemaphore(semaphore);
      atomic readonly trigger do
        if trigger.done then
	  return;
	fi;
      od;
    od;
  fi;
end;

WaitTask := function(arg)
  if Length(arg) = 1 and IsThreadLocal(arg[1]) and IS_LIST(arg[1]) then
    WAIT_TASK(arg[1], true);
  else
    WAIT_TASK(arg, true);
  fi;
end;

WaitTasks := WaitTask;

WaitAnyTask := function(arg)
  if Length(arg) = 1 and IsThreadLocal(arg[1]) and IS_LIST(arg[1]) then
    WAIT_TASK(arg[1], false);
  else
    WAIT_TASK(arg, false);
  fi;
end;

TaskResult := function(task)
  local complete;
  atomic readonly task do
    complete := task.complete;
  od;
  if not complete then
    WAIT_TASK([task], true);
  fi;
  atomic task do
    if task.adopt_result then
      atomic task.region do
        return AdoptObj(CopyRegion(task.result));
      od;
    else
      return task.result;
    fi;
  od;
end;

ImmediateTask := function(arg)
  local result, task;
  result := CALL_WITH_CATCH(arg[1], arg{[2..Length(arg)]});
  if Length(result) = 1 or not result[1] then
    if Length(result) > 1 then
      Print("Task Error: ", result[2], "\n");
    fi;
    result := fail;
  else
    result := result[2];
  fi;
  task := ShareObj (rec( started := true, complete := true, async := false,
                  result := result, adopt_result := false ));
  return task;
end;

TaskIsAsync := atomic function(readonly task)
  return task.async;
end;

TaskStarted := atomic function(readonly task)
  return task.started;
end;

TaskFinished := atomic function(readonly task)
  return task.complete;
end;

TaskInfo := atomic function(readonly task)
  return CopyRegion(task);
end;

SetMaxTaskWorkers := function(count)
  atomic TASK_QUEUE do
    TASK_QUEUE.max_active := count;
  od;
end;

RunningTasks := function()
  atomic TASK_QUEUE do
    return TASK_QUEUE.active_count;
  od;
end;

CullIdleTasks := function()
end;