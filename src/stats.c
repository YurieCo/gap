/****************************************************************************
**
*W  stats.c                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file contains the functions of the statements package.
**
**  The  statements package  is the  part  of  the interpreter that  executes
**  statements for their effects and prints statements.
*/
#include        "system.h"              /* system dependent part           */

const char * Revision_stats_c =
   "@(#)$Id$";

#include        "sysfiles.h"            /* file input/output               */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "bool.h"                /* booleans                        */

#include        "code.h"                /* coder                           */
#include        "vars.h"                /* variables                       */
#include        "exprs.h"               /* expressions                     */

#include        "intrprtr.h"            /* interpreter                     */

#include        "ariths.h"              /* basic arithmetic                */

#define INCLUDE_DECLARATION_PART
#include        "stats.h"               /* statements                      */
#undef  INCLUDE_DECLARATION_PART

#ifdef SYS_IS_MAC_MWC
#include        "macintr.h"              /* Mac interrupt handlers	      */
#endif

/****************************************************************************
**

*F  EXEC_STAT(<stat>) . . . . . . . . . . . . . . . . . . execute a statement
**
**  'EXEC_STAT' executes the statement <stat>.
**
**  If   this  causes   the  execution  of   a  return-value-statement,  then
**  'EXEC_STAT' returns 1, and the return value is stored in 'ReturnObjStat'.
**  If this causes the execution of a return-void-statement, then 'EXEC_STAT'
**  returns 2.  If  this causes execution  of a break-statement (which cannot
**  happen if <stat> is the body of a  function), then 'EXEC_STAT' returns 4.
**  Otherwise 'EXEC_STAT' returns 0.
**
**  'EXEC_STAT'  causes  the  execution  of  <stat>  by dispatching   to  the
**  executor, i.e., to the  function that executes statements  of the type of
**  <stat>.
**
**  'EXEC_STAT' is defined in the declaration part of this package as follows:
**
#define EXEC_STAT(stat) ( (*ExecStatFuncs[ TNUM_STAT(stat) ]) ( stat ) )
*/


/****************************************************************************
**
*V  ExecStatFuncs[<type>] . . . . . .  executor for statements of type <type>
**
**  'ExecStatFuncs' is   the dispatch table  that contains  for every type of
**  statements a pointer to the executor  for statements of  this type, i.e.,
**  the function  that should  be  called  if a  statement   of that type  is
**  executed.
*/
UInt            (* ExecStatFuncs[256]) ( Stat stat );


/****************************************************************************
**
*V  CurrStat  . . . . . . . . . . . . . . . . .  currently executed statement
**
**  'CurrStat'  is the statement that  is currently being executed.  The sole
**  purpose of 'CurrStat' is to make it possible to  point to the location in
**  case an error is signalled.
*/
Stat            CurrStat;


/****************************************************************************
**
*V  ReturnObjStat . . . . . . . . . . . . . . . .  result of return-statement
**
**  'ReturnObjStat'  is   the result of the   return-statement  that was last
**  executed.  It is set  in  'ExecReturnObj' and  used in the  handlers that
**  interpret functions.
*/
Obj             ReturnObjStat;


/****************************************************************************
**

*F  ExecUnknownStat(<stat>) . . . . . executor for statements of unknown type
**
**  'ExecUnknownStat' is the executor that is called if an attempt is made to
**  execute a statement <stat> of an unknown type.  It  signals an error.  If
**  this  is  ever  called, then   GAP is   in  serious  trouble, such as  an
**  overwritten type field of a statement.
*/
UInt            ExecUnknownStat (
    Stat                stat )
{
    Pr(
        "Panic: tried to execute a statement of unknown type '%d'\n",
        (Int)TNUM_STAT(stat), 0L );
    return 0;
}


/****************************************************************************
**
*F  ExecSeqStat(<stat>) . . . . . . . . . . . .  execute a statement sequence
**
**  'ExecSeqStat' executes the statement sequence <stat>.
**
**  This is done  by  executing  the  statements one  after  another.  If   a
**  leave-statement  ('break' or  'return')  is executed  inside  one  of the
**  statements, then the execution of  the  statement sequence is  terminated
**  and the non-zero leave-value  is returned (to  tell the calling  executor
**  that a leave-statement was executed).  If no leave-statement is executed,
**  then 0 is returned.
**
**  A statement sequence with <n> statements is represented by  a bag of type
**  'T_SEQ_STAT' with  <n> subbags.  The first  is  the  first statement, the
**  second is the second statement, and so on.
*/
UInt            ExecSeqStat (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                nr;             /* number of statements            */
    UInt                i;              /* loop variable                   */

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);

    /* loop over the statements                                            */
    for ( i = 1; i <= nr; i++ ) {

        /* execute the <i>-th statement                                    */
        if ( (leave = EXEC_STAT( ADDR_STAT(stat)[i-1] )) != 0 ) {
            return leave;
        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecSeqStat2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[1] );
}

UInt            ExecSeqStat3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[2] );
}

UInt            ExecSeqStat4 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[2] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[3] );
}

UInt            ExecSeqStat5 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[2] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[3] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[4] );
}

UInt            ExecSeqStat6 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[2] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[3] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[4] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[5] );
}

UInt            ExecSeqStat7 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[2] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[3] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[4] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[5] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[6] );
}


/****************************************************************************
**
*F  ExecIf(<stat>)  . . . . . . . . . . . . . . . . . execute an if-statement
**
**  'ExecIf' executes the if-statement <stat>.
**
**  This is done by evaluating the conditions  until one evaluates to 'true',
**  and then executing the corresponding body.  If a leave-statement ('break'
**  or  'return') is executed  inside the  body, then   the execution of  the
**  if-statement is  terminated and the  non-zero leave-value is returned (to
**  tell the  calling executor that a  leave-statement was executed).   If no
**  leave-statement is executed, then 0 is returned.
**
**  An if-statement with <n> branches is represented by  a bag of type 'T_IF'
**  with 2*<n> subbags.  The first subbag is  the first condition, the second
**  subbag is the  first body, the third subbag  is the second condition, the
**  fourth subbag is the second body, and so  on.  If the if-statement has an
**  else-branch, this is represented by a branch without a condition.
*/
UInt            ExecIf (
    Stat                stat )
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */

    /* if the condition evaluates to 'true', execute the if-branch body    */
    SET_BRK_CURR_STAT( stat );
    cond = ADDR_STAT(stat)[0];
    if ( EVAL_BOOL_EXPR( cond ) != False ) {

        /* execute the if-branch body and leave                            */
        body = ADDR_STAT(stat)[1];
        return EXEC_STAT( body );

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecIfElse (
    Stat                stat )
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */

    /* if the condition evaluates to 'true', execute the if-branch body    */
    SET_BRK_CURR_STAT( stat );
    cond = ADDR_STAT(stat)[0];
    if ( EVAL_BOOL_EXPR( cond ) != False ) {

        /* execute the if-branch body and leave                            */
        body = ADDR_STAT(stat)[1];
        return EXEC_STAT( body );

    }

    /* otherwise execute the else-branch body and leave                    */
    body = ADDR_STAT(stat)[3];
    return EXEC_STAT( body );
}

UInt            ExecIfElif (
    Stat                stat )
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */
    UInt                nr;             /* number of branches              */
    UInt                i;              /* loop variable                   */

    /* get the number of branches                                          */
    nr = SIZE_STAT( stat ) / (2*sizeof(Stat));

    /* loop over all branches                                              */
    for ( i = 1; i <= nr; i++ ) {

        /* if the condition evaluates to 'true', execute the branch body   */
        SET_BRK_CURR_STAT( stat );
        cond = ADDR_STAT(stat)[2*(i-1)];
        if ( EVAL_BOOL_EXPR( cond ) != False ) {

            /* execute the branch body and leave                           */
            body = ADDR_STAT(stat)[2*(i-1)+1];
            return EXEC_STAT( body );

        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecIfElifElse (
    Stat                stat )
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */
    UInt                nr;             /* number of branches              */
    UInt                i;              /* loop variable                   */

    /* get the number of branches                                          */
    nr = SIZE_STAT( stat ) / (2*sizeof(Stat)) - 1;

    /* loop over all branches                                              */
    for ( i = 1; i <= nr; i++ ) {

        /* if the condition evaluates to 'true', execute the branch body   */
        SET_BRK_CURR_STAT( stat );
        cond = ADDR_STAT(stat)[2*(i-1)];
        if ( EVAL_BOOL_EXPR( cond ) != False ) {

            /* execute the branch body and leave                           */
            body = ADDR_STAT(stat)[2*(i-1)+1];
            return EXEC_STAT( body );

        }

    }

    /* otherwise execute the else-branch body and leave                    */
    body = ADDR_STAT(stat)[2*(i-1)+1];
    return EXEC_STAT( body );
}


/****************************************************************************
**
*F  ExecFor(<stat>) . . . . . . . . . . . . . . . . . . .  execute a for-loop
**
**  'ExecFor' executes the for-loop <stat>.
**
**  This  is   done by   evaluating  the  list-expression, checking  that  it
**  evaluates  to  a list, and   then looping over the   entries in the list,
**  executing the  body for each element  of the list.   If a leave-statement
**  ('break' or 'return') is executed inside the  body, then the execution of
**  the for-loop is terminated and 0 is returned if the leave-statement was a
**  break-statement   or  the   non-zero leave-value   is   returned  if  the
**  leave-statement was a return-statement (to tell the calling executor that
**  a return-statement was  executed).  If  no leave-statement was  executed,
**  then 0 is returned.
**
**  A for-loop with <n> statements  in its body   is represented by a bag  of
**  type 'T_FOR' with <n>+2  subbags.  The first  subbag is an assignment bag
**  for the loop variable, the second subbag  is the list-expression, and the
**  remaining subbags are the statements.
*/
Obj             ITERATOR;

Obj             IS_DONE_ITER;

Obj             NEXT_ITER;

UInt            ExecFor (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                var;            /* variable                        */
    UInt                vart;           /* variable type                   */
    Obj                 list;           /* list to loop over               */
    Obj                 elm;            /* one element of the list         */
    Stat                body;           /* body of loop                    */
    UInt                i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    if ( IS_REFLVAR( ADDR_STAT(stat)[0] ) ) {
        var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );
        vart = 'l';
    }
    else if ( T_REF_LVAR <= TNUM_EXPR( ADDR_STAT(stat)[0] )
           && TNUM_EXPR( ADDR_STAT(stat)[0] ) <= T_REF_LVAR_16 ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'l';
    }
    else if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_HVAR ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'h';
    }
    else /* if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_GVAR ) */ {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'g';
    }

    /* evaluate the list                                                   */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[1] );

    /* get the body                                                        */
    body = ADDR_STAT(stat)[2];

    /* special case for lists                                              */
    if ( IS_SMALL_LIST( list ) ) {

        /* loop over the list, skipping unbound entries                    */
        i = 1;
        while ( i <= LEN_LIST(list) ) {

            /* get the element and assign it to the variable               */
            elm = ELMV0_LIST( list, i );
            i++;
            if ( elm == 0 )  continue;
            if      ( vart == 'l' )  ASS_LVAR( var, elm );
            else if ( vart == 'h' )  ASS_HVAR( var, elm );
            else if ( vart == 'g' )  AssGVar(  var, elm );

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( SyIsIntr() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body )) != 0 ) {
                return (leave & 3);
            }

        }

    }

    /* general case                                                        */
    else {

        /* get the iterator                                                */
        list = CALL_1ARGS( ITERATOR, list );

        /* loop over the iterator                                          */
        while ( CALL_1ARGS( IS_DONE_ITER, list ) == False ) {

            /* get the element and assign it to the variable               */
            elm = CALL_1ARGS( NEXT_ITER, list );
            if      ( vart == 'l' )  ASS_LVAR( var, elm );
            else if ( vart == 'h' )  ASS_HVAR( var, elm );
            else if ( vart == 'g' )  AssGVar(  var, elm );

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( SyIsIntr() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body )) != 0 ) {
                return (leave & 3);
            }

        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecFor2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                var;            /* variable                        */
    UInt                vart;           /* variable type                   */
    Obj                 list;           /* list to loop over               */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    UInt                i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    if ( IS_REFLVAR( ADDR_STAT(stat)[0] ) ) {
        var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );
        vart = 'l';
    }
    else if ( T_REF_LVAR <= TNUM_EXPR( ADDR_STAT(stat)[0] )
           && TNUM_EXPR( ADDR_STAT(stat)[0] ) <= T_REF_LVAR_16 ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'l';
    }
    else if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_HVAR ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'h';
    }
    else /* if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_GVAR ) */ {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'g';
    }

    /* evaluate the list                                                   */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[1] );

    /* get the body                                                        */
    body1 = ADDR_STAT(stat)[2];
    body2 = ADDR_STAT(stat)[3];

    /* special case for lists                                              */
    if ( IS_SMALL_LIST( list ) ) {

        /* loop over the list, skipping unbound entries                    */
        i = 1;
        while ( i <= LEN_LIST(list) ) {

            /* get the element and assign it to the variable               */
            elm = ELMV0_LIST( list, i );
            i++;
            if ( elm == 0 )  continue;
            if      ( vart == 'l' )  ASS_LVAR( var, elm );
            else if ( vart == 'h' )  ASS_HVAR( var, elm );
            else if ( vart == 'g' )  AssGVar(  var, elm );

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( SyIsIntr() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body1 )) != 0 ) {
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body2 )) != 0 ) {
                return (leave & 3);
            }

        }

    }

    /* general case                                                        */
    else {

        /* get the iterator                                                */
        list = CALL_1ARGS( ITERATOR, list );

        /* loop over the iterator                                          */
        while ( CALL_1ARGS( IS_DONE_ITER, list ) == False ) {

            /* get the element and assign it to the variable               */
            elm = CALL_1ARGS( NEXT_ITER, list );
            if      ( vart == 'l' )  ASS_LVAR( var, elm );
            else if ( vart == 'h' )  ASS_HVAR( var, elm );
            else if ( vart == 'g' )  AssGVar(  var, elm );

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( SyIsIntr() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body1 )) != 0 ) {
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body2 )) != 0 ) {
                return (leave & 3);
            }

        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecFor3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                var;            /* variable                        */
    UInt                vart;           /* variable type                   */
    Obj                 list;           /* list to loop over               */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */
    UInt                i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    if ( IS_REFLVAR( ADDR_STAT(stat)[0] ) ) {
        var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );
        vart = 'l';
    }
    else if ( T_REF_LVAR <= TNUM_EXPR( ADDR_STAT(stat)[0] )
           && TNUM_EXPR( ADDR_STAT(stat)[0] ) <= T_REF_LVAR_16 ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'l';
    }
    else if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_HVAR ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'h';
    }
    else /* if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_GVAR ) */ {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'g';
    }

    /* evaluate the list                                                   */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[1] );

    /* get the body                                                        */
    body1 = ADDR_STAT(stat)[2];
    body2 = ADDR_STAT(stat)[3];
    body3 = ADDR_STAT(stat)[4];

    /* special case for lists                                              */
    if ( IS_SMALL_LIST( list ) ) {

        /* loop over the list, skipping unbound entries                    */
        i = 1;
        while ( i <= LEN_LIST(list) ) {

            /* get the element and assign it to the variable               */
            elm = ELMV0_LIST( list, i );
            i++;
            if ( elm == 0 )  continue;
            if      ( vart == 'l' )  ASS_LVAR( var, elm );
            else if ( vart == 'h' )  ASS_HVAR( var, elm );
            else if ( vart == 'g' )  AssGVar(  var, elm );

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( SyIsIntr() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body1 )) != 0 ) {
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body2 )) != 0 ) {
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body3 )) != 0 ) {
                return (leave & 3);
            }


        }

    }

    /* general case                                                        */
    else {

        /* get the iterator                                                */
        list = CALL_1ARGS( ITERATOR, list );

        /* loop over the iterator                                          */
        while ( CALL_1ARGS( IS_DONE_ITER, list ) == False ) {

            /* get the element and assign it to the variable               */
            elm = CALL_1ARGS( NEXT_ITER, list );
            if      ( vart == 'l' )  ASS_LVAR( var, elm );
            else if ( vart == 'h' )  ASS_HVAR( var, elm );
            else if ( vart == 'g' )  AssGVar(  var, elm );

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( SyIsIntr() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body1 )) != 0 ) {
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body2 )) != 0 ) {
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body3 )) != 0 ) {
                return (leave & 3);
            }


        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecForRange(<stat>)  . . . . . . . . . . . . . . . .  execute a for-loop
**
**  'ExecForRange' executes the  for-loop  <stat>, which is a  for-loop whose
**  loop variable is  a  local variable and  whose  list is a  literal  range
**  expression.
**
**  This  is   done by   evaluating  the  list-expression, checking  that  it
**  evaluates  to  a list, and   then looping over the   entries in the list,
**  executing the  body for each element  of the list.   If a leave-statement
**  ('break' or 'return') is executed inside the  body, then the execution of
**  the for-loop is terminated and 0 is returned if the leave-statement was a
**  break-statement   or  the   non-zero leave-value   is   returned  if  the
**  leave-statement was a return-statement (to tell the calling executor that
**  a return-statement was  executed).  If  no leave-statement was  executed,
**  then 0 is returned.
**
**  A short for-loop with <n> statements in its body is  represented by a bag
**  of   type 'T_FOR_RANGE'  with <n>+2 subbags.     The  first subbag is  an
**  assignment   bag  for  the  loop  variable,   the second    subbag is the
**  list-expression, and the remaining subbags are the statements.
*/
UInt            ExecForRange (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                lvar;           /* local variable                  */
    Int                 first;          /* first value of range            */
    Int                 last;           /* last value of range             */
    Obj                 elm;            /* one element of the list         */
    Stat                body;           /* body of the loop                */
    Int                 i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    lvar = LVAR_REFLVAR( ADDR_STAT(stat)[0] );

    /* evaluate the range                                                  */
    SET_BRK_CURR_STAT( stat );
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[0] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <first> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can return an integer for <first>" );
    }
    first = INT_INTOBJ(elm);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[1] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <last> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can return an integer for <last>" );
    }
    last  = INT_INTOBJ(elm);

    /* get the body                                                        */
    body = ADDR_STAT(stat)[2];

    /* loop over the range                                                 */
    for ( i = first; i <= last; i++ ) {

        /* get the element and assign it to the variable                   */
        elm = INTOBJ_INT( i );
        ASS_LVAR( lvar, elm );

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the statements in the body                              */
        if ( (leave = EXEC_STAT( body )) != 0 ) {
            return (leave & 3);
        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecForRange2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                lvar;           /* local variable                  */
    Int                 first;          /* first value of range            */
    Int                 last;           /* last value of range             */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Int                 i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    lvar = LVAR_REFLVAR( ADDR_STAT(stat)[0] );

    /* evaluate the range                                                  */
    SET_BRK_CURR_STAT( stat );
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[0] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <first> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can return an integer for <first>" );
    }
    first = INT_INTOBJ(elm);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[1] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <last> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can return an integer for <last>" );
    }
    last  = INT_INTOBJ(elm);

    /* get the body                                                        */
    body1 = ADDR_STAT(stat)[2];
    body2 = ADDR_STAT(stat)[3];

    /* loop over the range                                                 */
    for ( i = first; i <= last; i++ ) {

        /* get the element and assign it to the variable                   */
        elm = INTOBJ_INT( i );
        ASS_LVAR( lvar, elm );

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the statements in the body                              */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            return (leave & 3);
        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecForRange3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                lvar;           /* local variable                  */
    Int                 first;          /* first value of range            */
    Int                 last;           /* last value of range             */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */
    Int                 i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    lvar = LVAR_REFLVAR( ADDR_STAT(stat)[0] );

    /* evaluate the range                                                  */
    SET_BRK_CURR_STAT( stat );
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[0] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <first> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can return an integer for <first>" );
    }
    first = INT_INTOBJ(elm);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[1] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <last> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can return an integer for <last>" );
    }
    last  = INT_INTOBJ(elm);

    /* get the body                                                        */
    body1 = ADDR_STAT(stat)[2];
    body2 = ADDR_STAT(stat)[3];
    body3 = ADDR_STAT(stat)[4];

    /* loop over the range                                                 */
    for ( i = first; i <= last; i++ ) {

        /* get the element and assign it to the variable                   */
        elm = INTOBJ_INT( i );
        ASS_LVAR( lvar, elm );

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the statements in the body                              */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body3 )) != 0 ) {
            return (leave & 3);
        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecWhile(<stat>) . . . . . . . . . . . . . . . . .  execute a while-loop
**
**  'ExecWhile' executes the while-loop <stat>.
**
**  This is done  by  executing the  body while  the condition   evaluates to
**  'true'.  If a leave-statement   ('break' or 'return') is executed  inside
**  the  body, then the execution of  the while-loop  is  terminated and 0 is
**  returned if the  leave-statement was  a  break-statement or the  non-zero
**  leave-value is returned if the leave-statement was a return-statement (to
**  tell the calling executor  that a return-statement  was executed).  If no
**  leave-statement was executed, then 0 is returned.
**
**  A while-loop with <n> statements  in its body  is represented by a bag of
**  type  'T_WHILE' with <n>+1 subbags.   The first  subbag is the condition,
**  the second subbag is the first statement,  the third subbag is the second
**  statement, and so on.
*/
UInt ExecWhile (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body;           /* body of loop                    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body = ADDR_STAT(stat)[1];

    /* while the condition evaluates to 'true', execute the body           */
    SET_BRK_CURR_STAT( stat );
    while ( EVAL_BOOL_EXPR( cond ) != False ) {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body )) != 0 ) {
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt ExecWhile2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body1 = ADDR_STAT(stat)[1];
    body2 = ADDR_STAT(stat)[2];

    /* while the condition evaluates to 'true', execute the body           */
    SET_BRK_CURR_STAT( stat );
    while ( EVAL_BOOL_EXPR( cond ) != False ) {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt ExecWhile3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body1 = ADDR_STAT(stat)[1];
    body2 = ADDR_STAT(stat)[2];
    body3 = ADDR_STAT(stat)[3];

    /* while the condition evaluates to 'true', execute the body           */
    SET_BRK_CURR_STAT( stat );
    while ( EVAL_BOOL_EXPR( cond ) != False ) {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body3 )) != 0 ) {
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecRepeat(<stat>)  . . . . . . . . . . . . . . . . execute a repeat-loop
**
**  'ExecRepeat' executes the repeat-loop <stat>.
**
**  This is  done by  executing  the body until   the condition evaluates  to
**  'true'.  If  a leave-statement ('break'  or 'return')  is executed inside
**  the  body, then the  execution of the repeat-loop  is terminated and 0 is
**  returned  if the leave-statement   was a break-statement  or the non-zero
**  leave-value is returned if the leave-statement was a return-statement (to
**  tell the  calling executor that a  return-statement was executed).  If no
**  leave-statement was executed, then 0 is returned.
**
**  A repeat-loop with <n> statements in its body is  represented by a bag of
**  type 'T_REPEAT'  with <n>+1 subbags.  The  first subbag is the condition,
**  the second subbag is the first statement, the  third subbag is the second
**  statement, and so on.
*/
UInt ExecRepeat (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body;           /* body of loop                    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body = ADDR_STAT(stat)[1];

    /* execute the body until the condition evaluates to 'true'            */
    SET_BRK_CURR_STAT( stat );
    do {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body )) != 0 ) {
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    } while ( EVAL_BOOL_EXPR( cond ) == False );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt ExecRepeat2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body1 = ADDR_STAT(stat)[1];
    body2 = ADDR_STAT(stat)[2];

    /* execute the body until the condition evaluates to 'true'            */
    SET_BRK_CURR_STAT( stat );
    do {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    } while ( EVAL_BOOL_EXPR( cond ) == False );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt ExecRepeat3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body1 = ADDR_STAT(stat)[1];
    body2 = ADDR_STAT(stat)[2];
    body3 = ADDR_STAT(stat)[3];

    /* execute the body until the condition evaluates to 'true'            */
    SET_BRK_CURR_STAT( stat );
    do {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( SyIsIntr() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body3 )) != 0 ) {
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    } while ( EVAL_BOOL_EXPR( cond ) == False );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecBreak(<stat>) . . . . . . . . . . . . . . . execute a break-statement
**
**  'ExecBreak' executes the break-statement <stat>.
**
**  This  is done   by  returning 4  (to tell  the   calling executor that  a
**  break-statement was executed).
**
**  A break-statement is  represented  by a bag of   type 'T_BREAK' with   no
**  subbags.
*/
UInt            ExecBreak (
    Stat                stat )
{
    /* return to the next loop                                             */
    return 4;
}

/****************************************************************************
**
*F  ExecEmpty( <stat> ) . . . . . execute an empty statement
**
**  Does nothing
*/
UInt ExecEmpty( Stat stat )
{
  return 0;
}


/****************************************************************************
**
*F  ExecInfo( <stat> )  . . . . . . . . . . . . . . execute an info-statement
**
**  'ExecInfo' executes the info-statement <stat>.
**
**  This is  done by evaluating the first  two arguments, using the GAP level
**  function InfoDecision to decide whether the message has to be printed. If
**  it has, the other arguments are evaluated and passed to InfoDoPrint
**
**  An  info-statement is represented by a  bag of type 'T_INFO' with subbags
**  for the arguments
*/
UInt ExecInfo (
    Stat            stat )
{
    Obj             selectors;
    Obj             level;
    Obj             selected;
    UInt            narg;
    UInt            i;
    Obj             args;
    Obj             arg;

    selectors = EVAL_EXPR( ARGI_INFO( stat, 1 ) );
    level = EVAL_EXPR( ARGI_INFO( stat, 2) );
    selected = CALL_2ARGS(InfoDecision, selectors, level);
    if (selected == True) {

        /* Get the number of arguments to be printed                       */
        narg = NARG_SIZE_INFO(SIZE_STAT(stat)) - 2;

        /* set up a list                                                   */
        args = NEW_PLIST( T_PLIST, narg );
        SET_LEN_PLIST( args, narg );

        /* evaluate the objects to be printed into the list                */
        for (i = 1; i <= narg; i++) {

            /* These two statements must not be combined into one because of
               the risk of a garbage collection during the evaluation
               of arg, which may happen after the pointer to args has been
               extracted
            */
            arg = EVAL_EXPR(ARGI_INFO(stat, i+2));
            SET_ELM_PLIST(args, i, arg);
            CHANGED_BAG(args);
        }

        /* and print them                                                  */
        CALL_1ARGS(InfoDoPrint, args);
    }
    return 0;
}

/****************************************************************************
**
*F  ExecAssert2Args(<stat>) . . . . . . . . . . . execute an assert-statement
**
**  'ExecAssert2Args' executes the 2 argument assert-statement <stat>.
**
**  A 2 argument assert-statement is  represented  by a bag of   type
**  'T_ASSERT_2ARGS' with subbags for the 2 arguments
*/
UInt ExecAssert2Args (
    Stat            stat )
{
    Obj             level;
    Obj             decision;

    level = EVAL_EXPR( ADDR_STAT( stat )[0] );
    if ( ! LT(CurrentAssertionLevel, level) )  {
        decision = EVAL_EXPR( ADDR_STAT( stat )[1]);
        while ( decision != True && decision != False ) {
         decision = ErrorReturnObj(
          "Assertion condition must evaluate to 'true' or 'false', not a %s",
          (Int)TNAM_OBJ(decision), 0L,
          "you may return 'true' or 'false' or you may quit");
        }
        if ( decision == False ) {
            ErrorReturnVoid( "Assertion failure", 0L, 0L, "you may return");
        }

        /* decision must be 'True' here                                    */
        else {
            return 0;
        }
    }
  return 0;
}

/****************************************************************************
**
*F  ExecAssert3Args(<stat>) . . . . . . . . . . . execute an assert-statement
**
**  'ExecAssert3Args' executes the 3 argument assert-statement <stat>.
**
**  A 3 argument assert-statement is  represented  by a bag of   type
**  'T_ASSERT_3ARGS' with subbags for the 3 arguments
*/
UInt ExecAssert3Args (
    Stat            stat )
{
    Obj             level;
    Obj             decision;
    Obj             message;

    level = EVAL_EXPR( ADDR_STAT( stat )[0] );
    if ( ! LT(CurrentAssertionLevel, level) ) {
        decision = EVAL_EXPR( ADDR_STAT( stat )[1]);
        while ( decision != True && decision != False ) {
         decision = ErrorReturnObj(
         "Assertion condition must evaluate to 'true' or 'false', not a %s",
         (Int)TNAM_OBJ(decision), 0L,
         "you may return 'true' or 'false' or you may quit");
        }
        if ( decision == False ) {
            message = EVAL_EXPR(ADDR_STAT( stat )[2]);
            if ( message != (Obj) 0 ) 
                PrintObj(message);
        }
        return 0;
    }
    return 0;
}


/****************************************************************************
**
*F  ExecReturnObj(<stat>) . . . . . . . . .  execute a return-value-statement
**
**  'ExecRetval' executes the return-value-statement <stat>.
**
**  This    is  done  by  setting  'ReturnObjStat'    to   the  value of  the
**  return-value-statement, and returning   1 (to tell   the calling executor
**  that a return-value-statement was executed).
**
**  A return-value-statement  is represented by a  bag of type 'T_RETURN_OBJ'
**  with      one  subbag.    This  subbag     is   the    expression  of the
**  return-value-statement.
*/
UInt            ExecReturnObj (
    Stat                stat )
{
#if ! HAVE_SIGNAL
    /* test for an interrupt                                               */
    if ( SyIsIntr() ) {
        ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
    }
#endif

    /* evaluate the expression                                             */
    SET_BRK_CURR_STAT( stat );
    ReturnObjStat = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* return up to function interpreter                                   */
    return 1;
}


/****************************************************************************
**
*F  ExecReturnVoid(<stat>)  . . . . . . . . . execute a return-void-statement
**
**  'ExecReturnVoid'   executes  the return-void-statement <stat>,  i.e., the
**  return-statement that returns not value.
**
**  This  is done by   returning 2  (to tell    the calling executor  that  a
**  return-void-statement was executed).
**
**  A return-void-statement  is represented by  a bag of type 'T_RETURN_VOID'
**  with no subbags.
*/
UInt            ExecReturnVoid (
    Stat                stat )
{
#if ! HAVE_SIGNAL
    /* test for an interrupt                                               */
    if ( SyIsIntr() ) {
        ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
    }
#endif

    /* set 'ReturnObjStat' to void                                         */
    ReturnObjStat = 0;

    /* return up to function interpreter                                   */
    return 2;
}


/****************************************************************************
**
*F  ExecIntrStat(<stat>)  . . . . . . . . . . . . . . interrupt a computation
**
**  'ExecIntrStat' is called when a computation was interrupted (by a call to
**  'InterruptExecStat').  It  changes   the entries in    the dispatch table
**  'ExecStatFuncs' back   to   their original   value,   calls 'Error',  and
**  redispatches after a return from the break-loop.
*/
UInt (* RealExecStatFuncs[256]) ( Stat stat );
UInt RealExecStatCopied = 0;

UInt ExecIntrStat (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    /* change the entries in 'ExecStatFuncs' back to the original          */
    if ( RealExecStatCopied ) {
        for ( i=0; i<sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
            ExecStatFuncs[i] = RealExecStatFuncs[i];
        }
    }
    SyIsIntr();

    /* and now for something completely different                          */
    SET_BRK_CURR_STAT( stat );

    if ( SyStorOverrun != 0 ) {
      SyStorOverrun = 0; /* reset */
      ErrorReturnVoid(
        "exceeded the permitted memory (`-o' command line option)",
	0L, 0L, "you can return" );
    }
    else {
      ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
    }

    /* continue at the interrupted statement                               */
    return EXEC_STAT( stat );
}


/****************************************************************************
**

*F  InterruptExecStat() . . . . . . . . interrupt the execution of statements
**
**  'InterruptExecStat'  interrupts the execution of   statements at the next
**  possible moment.  It is called from 'SyAnsIntr' if an interrupt signal is
**  received.  It is never called on systems that do not support signals.  On
**  those systems the executors test 'SyIsIntr' at regular intervals.
**
**  'InterruptExecStat' changes all entries   in the executor  dispatch table
**  'ExecStatFuncs'  to point to  'ExecIntrStat',  which changes  the entries
**  back, calls 'Error', and redispatches after a return from the break-loop.
*/
#if !SYS_MAC_MWC
void InterruptExecStat ( void )
{
    UInt                i;              /* loop variable                   */

    /* remember the original entries from the table 'ExecStatFuncs'        */
    if ( ! RealExecStatCopied ) {
        for ( i=0; i<sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
            RealExecStatFuncs[i] = ExecStatFuncs[i];
        }
        RealExecStatCopied = 1;
    }

    /* change the entries in the table 'ExecStatFuncs' to 'ExecIntrStat'   */
    for ( i = 0;
          i < T_SEQ_STAT;
          i++ ) {
        ExecStatFuncs[i] = ExecIntrStat;
    }
    for ( i = T_RETURN_VOID;
          i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]);
          i++ ) {
        ExecStatFuncs[i] = ExecIntrStat;
    }
}
#endif

/****************************************************************************
**
*F  ClearError()  . . . . . . . . . . . . . .  reset execution and error flag
*/
void ClearError ( void )
{
    UInt        i;

    /* change the entries in 'ExecStatFuncs' back to the original          */
    if ( RealExecStatCopied ) {
        for ( i=0; i<sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
            ExecStatFuncs[i] = RealExecStatFuncs[i];
        }
    }

#ifdef SYS_IS_MAC_MWC
	ActivateIntr ();   /* re-enable Mac interrupt check */
#endif

    /* reset <NrError>                                                     */
    NrError = 0;
}



/****************************************************************************
**
*F  PrintStat(<stat>) . . . . . . . . . . . . . . . . . . . print a statement
**
**  'PrintStat' prints the statements <stat>.
**
**  'PrintStat' simply dispatches  through the table  'PrintStatFuncs' to the
**  appropriate printer.
*/
void            PrintStat (
    Stat                stat )
{
    (*PrintStatFuncs[TNUM_STAT(stat)])( stat );
}


/****************************************************************************
**
*V  PrintStatFuncs[<type>]  . .  print function for statements of type <type>
**
**  'PrintStatFuncs' is the dispatching table that contains for every type of
**  statements a pointer to the  printer for statements  of this type,  i.e.,
**  the function that should be called to print statements of this type.
*/
void            (* PrintStatFuncs[256] ) ( Stat stat );


/****************************************************************************
**
*F  PrintUnknownStat(<stat>)  . . . . . . . . print statement of unknown type
**
**  'PrintUnknownStat' is the printer  that is called if  an attempt  is made
**  print a statement <stat>  of an unknown type.   It signals an error.   If
**  this  is  ever called,   then GAP  is in  serious   trouble, such  as  an
**  overwritten type field of a statement.
*/
void            PrintUnknownStat (
    Stat                stat )
{
    ErrorQuit(
        "Panic: cannot print statement of type '%d'",
        (Int)TNUM_STAT(stat), 0L );
}


/****************************************************************************
**
*F  PrintSeqStat(<stat>)  . . . . . . . . . . . .  print a statement sequence
**
**  'PrintSeqStat' prints the statement sequence <stat>.
*/
void            PrintSeqStat (
    Stat                stat )
{
    UInt                nr;             /* number of statements            */
    UInt                i;              /* loop variable                   */

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);

    /* loop over the statements                                            */
    for ( i = 1; i <= nr; i++ ) {

        /* print the <i>-th statement                                      */
        PrintStat( ADDR_STAT(stat)[i-1] );

        /* print a line break after all but the last statement             */
        if ( i < nr )  Pr( "\n", 0L, 0L );

    }

}


/****************************************************************************
**
*F  PrintIf(<stat>) . . . . . . . . . . . . . . . . . . print an if-statement
**
**  'PrIf' prints the if-statement <stat>.
**
**  Linebreaks are printed after the 'then' and the statements in the bodies.
**  If necessary one is preferred immediately before the 'then'.
*/
void            PrintIf (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    /* print the 'if' branch                                               */
    Pr( "if%4> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<  then%2>\n", 0L, 0L );
    PrintStat( ADDR_STAT(stat)[1] );
    Pr( "%4<\n", 0L, 0L );

    /* print the 'elif' branch                                             */
    for ( i = 2; i <= SIZE_STAT(stat)/(2*sizeof(Stat)); i++ ) {
        if ( TNUM_EXPR( ADDR_STAT(stat)[2*(i-1)] ) == T_TRUE_EXPR ) {
            Pr( "else%4>\n", 0L, 0L );
        }
        else {
            Pr( "elif%4> ", 0L, 0L );
            PrintExpr( ADDR_STAT(stat)[2*(i-1)] );
            Pr( "%2<  then%2>\n", 0L, 0L );
        }
        PrintStat( ADDR_STAT(stat)[2*(i-1)+1] );
        Pr( "%4<\n", 0L, 0L );
    }

    /* print the 'fi'                                                      */
    Pr( "fi;", 0L, 0L );
}


/****************************************************************************
**
*F  PrintFor(<stat>)  . . . . . . . . . . . . . . . . . . .  print a for-loop
**
**  'PrintFor' prints the for-loop <stat>.
**
**  Linebreaks are printed after the 'do' and the statements in the body.  If
**  necesarry it is preferred immediately before the 'in'.
*/
void            PrintFor (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    Pr( "for%4> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<  in%2> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr( "%2<  do%2>\n", 0L, 0L );
    for ( i = 2; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat( ADDR_STAT(stat)[i] );
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr( "\n", 0L, 0L );
    }
    Pr( "%4<\nod;", 0L, 0L );
}


/****************************************************************************
**
*F  PrintWhile(<stat>)  . . . . . . . . . . . . . . . . .  print a while loop
**
**  'PrintWhile' prints the while-loop <stat>.
**
**  Linebreaks are printed after the 'do' and the statments  in the body.  If
**  necessary one is preferred immediately before the 'do'.
*/
void            PrintWhile (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    Pr( "while%4> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<  do%2>\n", 0L, 0L );
    for ( i = 1; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat( ADDR_STAT(stat)[i] );
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr( "\n", 0L, 0L );
    }
    Pr( "%4<\nod;", 0L, 0L );
}


/****************************************************************************
**
*F  PrintRepeat(<stat>) . . . . . . . . . . . . . . . . . print a repeat-loop
**
**  'PrintRepeat' prints the repeat-loop <stat>.
**
**  Linebreaks are printed after the 'repeat' and the statements in the body.
**  If necessary one is preferred after the 'until'.
*/
void            PrintRepeat (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    Pr( "repeat%4>\n", 0L, 0L );
    for ( i = 1; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat( ADDR_STAT(stat)[i] );
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr( "\n", 0L, 0L );
    }
    Pr( "%4<\nuntil%2> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<;", 0L, 0L );
}


/****************************************************************************
**
*F  PrintBreak(<stat>)  . . . . . . . . . . . . . . . print a break-statement
**
**  'PrintBreak' prints the break-statement <stat>.
*/
void            PrintBreak (
    Stat                stat )
{
    Pr( "break;", 0L, 0L );
}

/****************************************************************************
**
*F  PrintEmpty(<stat>)
**
*/
void             PrintEmpty( Stat stat )
{
  Pr( ";", 0L, 0L);
}

/****************************************************************************
**
*F  PrintInfo(<stat>)  . . . . . . . . . . . . . . . print an info-statement
**
**  'PrintInfo' prints the info-statement <stat>.
*/

void            PrintInfo (
    Stat               stat )
{
    UInt                i;              /* loop variable                   */

    /* print the keyword                                                   */
    Pr("%2>Info",0L,0L);

    /* print the opening parenthesis                                       */
    Pr("%<( %>",0L,0L);

    /* print the expressions that evaluate to the actual arguments         */
    for ( i = 1; i <= NARG_SIZE_INFO( SIZE_STAT(stat) ); i++ ) {
        PrintExpr( ARGI_INFO(stat,i) );
        if ( i != NARG_SIZE_INFO( SIZE_STAT(stat) ) ) {
            Pr("%<, %>",0L,0L);
        }
    }

    /* print the closing parenthesis                                       */
    Pr(" %2<);",0L,0L);
}

/****************************************************************************
**
*F  PrintAssert2Args(<stat>)  . . . . . . . . . . . . print an info-statement
**
**  'PrintAssert2Args' prints the 2 argument assert-statement <stat>.
*/

void            PrintAssert2Args (
    Stat               stat )
{

    /* print the keyword                                                   */
    Pr("%2>Assert",0L,0L);

    /* print the opening parenthesis                                       */
    Pr("%<( %>",0L,0L);

    /* Print the arguments, separated by a comma                           */
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<, %>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );

    /* print the closing parenthesis                                       */
    Pr(" %2<);",0L,0L);
}
  
/****************************************************************************
**
*F  PrintAssert3Args(<stat>)  . . . . . . . . . . . . print an info-statement
**
**  'PrintAssert3Args' prints the 3 argument assert-statement <stat>.
*/

void            PrintAssert3Args (
    Stat               stat )
{

    /* print the keyword                                                   */
    Pr("%2>Assert",0L,0L);

    /* print the opening parenthesis                                       */
    Pr("%<( %>",0L,0L);

    /* Print the arguments, separated by commas                            */
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<, %>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr("%<, %>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );

    /* print the closing parenthesis                                       */
    Pr(" %2<);",0L,0L);
}
  


/****************************************************************************
**
*F  PrintReturnObj(<stat>)  . . . . . . . . .  print a return-value-statement
**
**  'PrintReturnObj' prints the return-value-statement <stat>.
*/
void            PrintReturnObj (
    Stat                stat )
{
    Pr( "%2>return%< %>", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<;", 0L, 0L );
}


/****************************************************************************
**
*F  PrintReturnVoid(<stat>) . . . . . . . . . . print a return-void-statement
**
**  'PrintReturnVoid' prints the return-void-statement <stat>.
*/
void            PrintReturnVoid (
    Stat                stat )
{
    Pr( "return;", 0L, 0L );
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                i;              /* loop variable                   */

    /* make the global bags known to Gasman                                */
    /* 'InitGlobalBag( &CurrStat );' is not really needed, since we are in */
    /* for a lot of trouble if 'CurrStat' ever becomes the last reference. */
    /* furthermore, statements are no longer bags                          */
    /* InitGlobalBag( &CurrStat );                                         */

    InitGlobalBag( &ReturnObjStat, "src/stats.c:ReturnObjStat" );

    /* connect to external functions                                       */
    ImportFuncFromLibrary( "Iterator",       &ITERATOR );
    ImportFuncFromLibrary( "IsDoneIterator", &IS_DONE_ITER );
    ImportFuncFromLibrary( "NextIterator",   &NEXT_ITER );

    /* install executors for non-statements                                */
    for ( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
        ExecStatFuncs[i] = ExecUnknownStat;
    }

    /* install executors for compound statements                           */
    ExecStatFuncs [ T_SEQ_STAT       ] = ExecSeqStat;
    ExecStatFuncs [ T_SEQ_STAT2      ] = ExecSeqStat2;
    ExecStatFuncs [ T_SEQ_STAT3      ] = ExecSeqStat3;
    ExecStatFuncs [ T_SEQ_STAT4      ] = ExecSeqStat4;
    ExecStatFuncs [ T_SEQ_STAT5      ] = ExecSeqStat5;
    ExecStatFuncs [ T_SEQ_STAT6      ] = ExecSeqStat6;
    ExecStatFuncs [ T_SEQ_STAT7      ] = ExecSeqStat7;
    ExecStatFuncs [ T_IF             ] = ExecIf;
    ExecStatFuncs [ T_IF_ELSE        ] = ExecIfElse;
    ExecStatFuncs [ T_IF_ELIF        ] = ExecIfElif;
    ExecStatFuncs [ T_IF_ELIF_ELSE   ] = ExecIfElifElse;
    ExecStatFuncs [ T_FOR            ] = ExecFor;
    ExecStatFuncs [ T_FOR2           ] = ExecFor2;
    ExecStatFuncs [ T_FOR3           ] = ExecFor3;
    ExecStatFuncs [ T_FOR_RANGE      ] = ExecForRange;
    ExecStatFuncs [ T_FOR_RANGE2     ] = ExecForRange2;
    ExecStatFuncs [ T_FOR_RANGE3     ] = ExecForRange3;
    ExecStatFuncs [ T_WHILE          ] = ExecWhile;
    ExecStatFuncs [ T_WHILE2         ] = ExecWhile2;
    ExecStatFuncs [ T_WHILE3         ] = ExecWhile3;
    ExecStatFuncs [ T_REPEAT         ] = ExecRepeat;
    ExecStatFuncs [ T_REPEAT2        ] = ExecRepeat2;
    ExecStatFuncs [ T_REPEAT3        ] = ExecRepeat3;
    ExecStatFuncs [ T_BREAK          ] = ExecBreak;
    ExecStatFuncs [ T_INFO           ] = ExecInfo;
    ExecStatFuncs [ T_ASSERT_2ARGS   ] = ExecAssert2Args;
    ExecStatFuncs [ T_ASSERT_3ARGS   ] = ExecAssert3Args;
    ExecStatFuncs [ T_RETURN_OBJ     ] = ExecReturnObj;
    ExecStatFuncs [ T_RETURN_VOID    ] = ExecReturnVoid;
    ExecStatFuncs [ T_EMPTY          ] = ExecEmpty;

    /* install printers for non-statements                                */
    for ( i = 0; i < sizeof(PrintStatFuncs)/sizeof(PrintStatFuncs[0]); i++ ) {
        PrintStatFuncs[i] = PrintUnknownStat;
    }
    /* install printing functions for compound statements                  */
    PrintStatFuncs[ T_SEQ_STAT       ] = PrintSeqStat;
    PrintStatFuncs[ T_SEQ_STAT2      ] = PrintSeqStat;
    PrintStatFuncs[ T_SEQ_STAT3      ] = PrintSeqStat;
    PrintStatFuncs[ T_SEQ_STAT4      ] = PrintSeqStat;
    PrintStatFuncs[ T_SEQ_STAT5      ] = PrintSeqStat;
    PrintStatFuncs[ T_SEQ_STAT6      ] = PrintSeqStat;
    PrintStatFuncs[ T_SEQ_STAT7      ] = PrintSeqStat;
    PrintStatFuncs[ T_IF             ] = PrintIf;
    PrintStatFuncs[ T_IF_ELSE        ] = PrintIf;
    PrintStatFuncs[ T_IF_ELIF        ] = PrintIf;
    PrintStatFuncs[ T_IF_ELIF_ELSE   ] = PrintIf;
    PrintStatFuncs[ T_FOR            ] = PrintFor;
    PrintStatFuncs[ T_FOR2           ] = PrintFor;
    PrintStatFuncs[ T_FOR3           ] = PrintFor;
    PrintStatFuncs[ T_FOR_RANGE      ] = PrintFor;
    PrintStatFuncs[ T_FOR_RANGE2     ] = PrintFor;
    PrintStatFuncs[ T_FOR_RANGE3     ] = PrintFor;
    PrintStatFuncs[ T_WHILE          ] = PrintWhile;
    PrintStatFuncs[ T_WHILE2         ] = PrintWhile;
    PrintStatFuncs[ T_WHILE3         ] = PrintWhile;
    PrintStatFuncs[ T_REPEAT         ] = PrintRepeat;
    PrintStatFuncs[ T_REPEAT2        ] = PrintRepeat;
    PrintStatFuncs[ T_REPEAT3        ] = PrintRepeat;
    PrintStatFuncs[ T_BREAK          ] = PrintBreak;
    PrintStatFuncs[ T_INFO           ] = PrintInfo;
    PrintStatFuncs[ T_ASSERT_2ARGS   ] = PrintAssert2Args;
    PrintStatFuncs[ T_ASSERT_3ARGS   ] = PrintAssert3Args;
    PrintStatFuncs[ T_RETURN_OBJ     ] = PrintReturnObj;
    PrintStatFuncs[ T_RETURN_VOID    ] = PrintReturnVoid;
    PrintStatFuncs[ T_EMPTY          ] = PrintEmpty;

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoStats() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "stats",                            /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    0,                                  /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoStats ( void )
{
    module.revision_c = Revision_stats_c;
    module.revision_h = Revision_stats_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  stats.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/