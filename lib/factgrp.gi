#############################################################################
##
#W  factgrp.gi                      GAP library              Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations of operations for factor group maps
##
Revision.factgrp_gi:=
  "@(#)$Id$";

#############################################################################
##
#M  NaturalHomomorphismsPool(G) . . . . . . . . . . . . . . initialize method
##
InstallMethod(NaturalHomomorphismsPool,true,[IsGroup],0,
  G->rec(GopDone:=false,ker:=[],ops:=[],cost:=[],group:=G,lock:=[],
         intersects:=[],blocksdone:=[],in_code:=false));

#############################################################################
##
#F  AddNaturalHomomorphismsPool(G,N,op[,cost[,blocksdone]]) . Store operation
##       op for kernel N if there is not already a cheaper one
##       returns false if nothing had been added and 'fail' if adding was
##       forbidden
##
InstallGlobalFunction(AddNaturalHomomorphismsPool,function(arg)
local G,N,op,i,c,p,pool,perm;
  G:=arg[1];
  N:=arg[2];
  op:=arg[3];

  # don't store trivial cases
  if Size(N)=1 or Size(N)=Size(G) then
    Info(InfoFactor,4,"trivial sub");
    # do we really want the trivial subgroup?
    if not (HasNaturalHomomorphismsPool(G) and
      ForAny(NaturalHomomorphismsPool(G).ker,j->Size(j)=1)) then
    return false;
    fi;
  fi;

  pool:=NaturalHomomorphismsPool(G);

  # split lists in their components
  if IsList(op) and not IsInt(op[1]) then
    p:=[];
    for i in op do
      if IsMapping(i) then
        c:=Intersection(G,KernelOfMultiplicativeGeneralMapping(i));
      else
        c:=Core(G,i);
      fi;
      Add(p,c);
      AddNaturalHomomorphismsPool(G,c,i);
    od;
    # transfer in numbers list
    op:=List(p,i->PositionSet(pool.ker,i));
    if Length(arg)<4 then
      # add the prices
      c:=Sum(pool.cost{op});
    fi;
  # compute/get costs
  elif Length(arg)>3 then
    c:=arg[4];
  else
    if IsGroup(op) then
      c:=Index(G,op);
    elif IsMapping(op) then
      c:=Image(op);
      if IsPcGroup(c) then
	c:=1;
      elif IsPermGroup(c) then
	c:=NrMovedPoints(c);
      else
        c:=Size(c);
      fi;
    fi;
  fi;

  # check whether we have already a better operation (or whether this normal
  # subgroup is locked)

  p:=PositionSet(pool.ker,N);
  if p=fail then
    if pool.in_code then
      return fail;
    fi;
    p:=PositionSorted(pool.ker,N);
    # compute the permutation we have to apply finally
    perm:=PermList(Concatenation([1..p-1],[Length(pool.ker)+1],
                   [p..Length(pool.ker)]))^-1;

    # first add at the end
    p:=Length(pool.ker)+1;
    pool.ker[p]:=N;
  elif c>=pool.cost[p] then
    Info(InfoFactor,4,"bad price");
    return false; # nothing added
  elif pool.lock[p]=true then
    return fail; # nothing added
  else
    perm:=();
  fi;

  Info(InfoFactor,3,"Added price ",c," for size ",Index(G,N));
  if IsMapping(op) and not HasKernelOfMultiplicativeGeneralMapping(op) then
    SetKernelOfMultiplicativeGeneralMapping(op,N);
  fi;
  pool.ops[p]:=op;
  pool.cost[p]:=c;
  pool.lock[p]:=false;

  # update the costs of all intersections that are affected
  for i in [1..Length(pool.ker)] do
    if IsList(pool.ops[i]) and IsInt(pool.ops[i][1]) and p in pool.ops[i] then
      pool.cost[i]:=Sum(pool.cost{pool.ops[i]});
    fi;
  od;

  if Length(arg)>4 then
    pool.blocksdone[p]:=arg[5];
  else
    pool.blocksdone[p]:=false;
  fi;

  if perm<>() then
    # sort the kernels anew
    pool.ker:=Permuted(pool.ker,perm);
    # sort/modify the other components accordingly
    pool.ops:=Permuted(pool.ops,perm);
    for i in [1..Length(pool.ops)] do
      # if entries are lists of integers
      if IsList(pool.ops[i]) and IsInt(pool.ops[i][1]) then
	pool.ops[i]:=List(pool.ops[i],i->i^perm);
      fi;
    od;
    pool.cost:=Permuted(pool.cost,perm);
    pool.lock:=Permuted(pool.lock,perm);
    pool.blocksdone:=Permuted(pool.blocksdone,perm);
    pool.intersects:=Set(List(pool.intersects,i->List(i,j->j^perm)));
  fi;

  return perm; # if anyone wants to keep the permutation
end);


#############################################################################
##
#F  LockNaturalHomomorphismsPool(G,N)  . .  store flag to prohibit changes of
##                                                               the map to N
##
InstallGlobalFunction(LockNaturalHomomorphismsPool,function(G,N)
local pool;
  pool:=NaturalHomomorphismsPool(G);
  N:=PositionSet(pool.ker,N);
  if N<>fail then
    pool.lock[N]:=true;
  fi;
end);


#############################################################################
##
#F  UnlockNaturalHomomorphismsPool(G,N) . . .  clear flag to allow changes of
##                                                               the map to N
##
InstallGlobalFunction(UnlockNaturalHomomorphismsPool,function(G,N)
local pool;
  pool:=NaturalHomomorphismsPool(G);
  N:=PositionSet(pool.ker,N);
  if N<>fail then
    pool.lock[N]:=false;
  fi;
end);


#############################################################################
##
#F  KnownNaturalHomomorphismsPool(G,N) . . . . .  check whether Hom is stored
##                                                               (or obvious)
##
InstallGlobalFunction(KnownNaturalHomomorphismsPool,function(G,N)
  return N=G or Size(N)=1 
      or PositionSet(NaturalHomomorphismsPool(G).ker,N)<>fail;
end);


#############################################################################
##
#F  GetNaturalHomomorphismsPool(G,N)  . . . .  get operation for G/N if known
##
InstallGlobalFunction(GetNaturalHomomorphismsPool,function(G,N)
local pool,p,h,ise,emb,i,j;
  if not HasNaturalHomomorphismsPool(G) then
    return fail;
  fi;
  pool:=NaturalHomomorphismsPool(G);
  p:=PositionSet(pool.ker,N);
  if p<>fail then
    h:=pool.ops[p];
    if IsList(h) then
      # just stored as intersection. Construct the mapping!
      # join intersections
      ise:=ShallowCopy(h);
      for i in ise do
	if IsList(pool.ops[i]) and IsInt(pool.ops[i][1]) then
	  for j in Filtered(pool.ops[i],j-> not j in ise) do
	    Add(ise,j);
	  od;
	elif not pool.blocksdone[i] then
	  h:=GetNaturalHomomorphismsPool(G,pool.ker[i]);
	  pool.in_code:=true; # don't add any new kernel here
	  # (which would mess up the numbering)
	  ImproveActionDegreeByBlocks(G,pool.ker[i],h);
	  pool.in_code:=false;
	fi;
      od;
      ise:=List(ise,i->GetNaturalHomomorphismsPool(G,pool.ker[i]));
      h:=CallFuncList(DirectProduct,List(ise,Image));
      emb:=List([1..Length(ise)],i->Embedding(h,i));
      emb:=List(GeneratorsOfGroup(G),
	   i->Product([1..Length(ise)],j->Image(emb[j],Image(ise[j],i))));
      ise:=SubgroupNC(h,emb);

      h:=GroupHomomorphismByImagesNC(G,ise,GeneratorsOfGroup(G),emb);
      SetKernelOfMultiplicativeGeneralMapping(h,N);
      pool.ops[p]:=h;
    elif IsGroup(h) then
      h:=FactorCosetAction(G,h,N); # will implicitely store
    fi;
    p:=h;
  fi;
  return p;
end);


#############################################################################
##
#F  DegreeNaturalHomomorphismsPool(G,N) degree for operation for G/N if known
##
InstallGlobalFunction(DegreeNaturalHomomorphismsPool,function(G,N)
local p,pool;
  pool:=NaturalHomomorphismsPool(G);
  p:=PositionSet(pool.ker,N);
  if p<>fail then
    p:=pool.cost[p];
  fi;
  return p;
end);


#############################################################################
##
#F  CloseNaturalHomomorphismsPool(<G>[,<N>]) . . calc intersections of known
##         operation kernels, don't continue anything whic is smaller than N
##
InstallGlobalFunction(CloseNaturalHomomorphismsPool,function(arg)
local G,pool,p,comb,i,c,perm,l,isi;
  G:=arg[1];
  pool:=NaturalHomomorphismsPool(G);
  p:=[1..Length(pool.ker)];
  
  repeat
    # obviously it is sufficient to consider only pairs iteratively
    p:=Set(p);
    comb:=Combinations(p,2);
    comb:=Filtered(comb,i->not i in pool.intersects);
    l:=Length(pool.ker);
    Info(InfoFactor,2,"CloseNaturalHomomorphismsPool");
    for i in comb do
      c:=Intersection(pool.ker[i[1]],pool.ker[i[2]]);
      isi:=ShallowCopy(i);

      # unpack 'iterated' lists
      if IsList(pool.ops[i[2]]) and IsInt(pool.ops[i[2]][1]) then
        isi:=Concatenation(isi{[1]},pool.ops[i[2]]);
      fi;
      if IsList(pool.ops[i[1]]) and IsInt(pool.ops[i[1]][1]) then
        isi:=Concatenation(isi{[2..Length(isi)]},pool.ops[i[1]]);
      fi;
      isi:=Set(isi);

      perm:=AddNaturalHomomorphismsPool(G,c,isi,Sum(pool.cost{i}));
      if perm<>fail then
	# note that we got the intersections
	if perm<>false then
	  AddSet(pool.intersects,List(i,j->j^perm));
	else
	  AddSet(pool.intersects,i);
        fi;
      fi;

      # note index shifts
      if IsPerm(perm) then
	p:=List(p,i->i^perm);
	Apply(comb,j->OnSets(j,perm));
      fi;

      if Length(arg)=1 or IsSubgroup(c,arg[2]) then
	AddSet(p,
	  PositionSet(pool.ker,c)); # to allow iterated intersections
      fi;
    od;
  until Length(comb)=0; # nothing new was added
  
end);


#############################################################################
##
#F  FactorCosetAction( <G>, <U>, [<N>] )  operation on the right cosets Ug
##                                        with possibility to indicate kernel
##
DoFactorCosetAction:=function(arg)
local G,u,op,h,N,rt;
  G:=arg[1];
  u:=arg[2];
  if Length(arg)>2 then
    N:=arg[3];
  else
    N:=false;
  fi;
  if IsList(u) and Length(u)=0 then
    u:=G;
    Error("only trivial operation ?  I Set u:=G;");
  fi;
  if N=false then
    N:=Core(G,u);
  fi;
  rt:=RightTransversal(G,u);
  if not IsRightTransversalRep(rt) then
    # the right transversal has no special `PositionCanonical' method.
    rt:=List(rt,i->RightCoset(u,i));
  fi;
  h:=ActionHomomorphism(G,rt,OnRight,"surjective");
  op:=Image(h,G);
  SetSize(op,Index(G,N));

  # and note our knowledge
  SetKernelOfMultiplicativeGeneralMapping(h,N);
  AddNaturalHomomorphismsPool(G,N,h);
  return h;
end;

InstallMethod(FactorCosetAction,"by right transversal operation",
  IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,U)
  return DoFactorCosetAction(G,U);
end);

InstallOtherMethod(FactorCosetAction,
  "by right transversal operation, given kernel",IsFamFamFam,
  [IsGroup,IsGroup,IsGroup],0,
function(G,U,N)
  return DoFactorCosetAction(G,U,N);
end);

InstallMethod(FactorCosetAction,"by right transversal operation, Niceo",
  IsIdenticalObj,[IsGroup and IsHandledByNiceMonomorphism,IsGroup],0,
function(G,U)
local hom;
  hom:=NiceMonomorphism(G);
  return hom*DoFactorCosetAction(Image(hom,G),Image(hom,U));
end);

InstallOtherMethod(FactorCosetAction,
  "by right transversal operation, given kernel, Niceo",IsFamFamFam,
  [IsGroup and IsHandledByNiceMonomorphism,IsGroup,IsGroup],0,
function(G,U,N)
local hom;
  hom:=NiceMonomorphism(G);
  return hom*DoFactorCosetAction(Image(hom,G),Image(hom,U),Image(hom,N));
end);


#############################################################################
##
#M  DoCheapActionImages(G) . . . . . . . . . . All cheap operations for G
##
InstallMethod(DoCheapActionImages,true,[IsGroup],0,Ignore);

InstallMethod(DoCheapActionImages,true,[IsPermGroup],0,
function(G)
local dom,o,bl,i,j,b,op,pool;

  pool:=NaturalHomomorphismsPool(G);
  if pool.GopDone=false then

    dom:=MovedPoints(G);
    # orbits
    o:=Orbits(G,dom);
    o:=Set(List(o,Set));

    # do orbits and test for blocks 
    bl:=[];
    for i in o do
      op:=ActionHomomorphism(G,i,"surjective");
      if i<>dom then
        AddNaturalHomomorphismsPool(G,Stabilizer(G,i,OnTuples),
			    op,Length(i));
      fi;

      if Length(i)<500 and Size(Image(op,G))>10*Length(i) then
	# all blocks
	for j in AllBlocks(Image(op,G)) do
	  j:=i{j}; # preimage
	  b:=Orbit(G,j,OnSets);
	  Add(bl,b);
	od;
      else
	# one block system
	b:=Blocks(G,i);
	if Length(b)>1 then
	  Add(bl,b);
	fi;
      fi;
    od;

    for i in bl do
      op:=ActionHomomorphism(G,i,OnSets,"surjective");
      b:=KernelOfMultiplicativeGeneralMapping(op);

      #AH kernel is blockstab intersect.
      #b:=g;
      #for j in i do
      #  b:=StabilizerOfBlockNC(b,j);
      #od;

      AddNaturalHomomorphismsPool(G,b,op);
    od;

    pool.GopDone:=true;
  fi;

end);

#############################################################################
##
#F  ImproveActionDegreeByBlocks( <G>, <N> , {hom/subgrp} [,forceblocks] )
##  extension of <U> in <G> such that   \bigcap U^g=N remains valid
##
InstallGlobalFunction(ImproveActionDegreeByBlocks,function(arg)
local G,N,oh,gens,img,dom,b,improve,bp,bb,i,fb,k,bestdeg,subo,op;
  G:=arg[1];
  N:=arg[2];
  oh:=arg[3];
  if Length(arg)>3 then
    fb:=arg[4];
  else
    fb:=false;
  fi;

  # if subgroup is given, construct an homomorphism
  if IsGroup(oh) then
    # unless it is too hard compared to what we know already
    if DegreeNaturalHomomorphismsPool(G,N)=fail 
       or Index(G,oh)<=10000 then
      oh:=FactorCosetAction(G,oh,N); #stores implicitely!
    else
      return fail;
    fi;
  fi;
  AddNaturalHomomorphismsPool(G,N,oh);
  Info(InfoFactor,1,"try to find block systems");

  # remember that we computed the blocks
  b:=NaturalHomomorphismsPool(G);

  # special case to use it for improving a permutation representation
  if Size(N)=1 then
    Info(InfoFactor,1,"special case for trivial subgroup");
    b.ker:=[N];
    b.ops:=[oh];
    b.cost:=[Length(MovedPoints(Range(oh)))];
    b.lock:=[false];
    b.blocksdone:=[false];
  fi;

  i:=PositionSet(b.ker,N);
  if b.blocksdone[i] then
    return DegreeNaturalHomomorphismsPool(G,N); # we have done it already
  fi;
  b.blocksdone[i]:=true;

  if not IsPermGroup(Range(oh)) then
    return 1;
  fi;

  img:=Image(oh,G);
  dom:=MovedPoints(img);

  if IsTransitive(img,dom) then
    # one orbit: Blocks
    repeat

      gens:=List(GeneratorsOfGroup(G),i->Image(oh,i));
      b:=Blocks(img,dom);
      improve:=false;
      if Length(b)>1 then
	subo:=ApproximateSuborbitsStabilizerPermGroup(img,dom[1]);
	subo:=Difference(List(subo,i->i[1]),dom{[1]});
	if fb<>fail and (Length(subo)<=500 or fb=true) then
	  Info(InfoFactor,2,"try all seeds");
	  # if the degree is not too big or if we are desparate then go for
	  # all blocks
	  # greedy approach: take always locally best one (otherwise there
	  # might be too much work to do)
	  bestdeg:=Length(dom);
	  bp:=[]; #Blocks pool
	  i:=1;
	  while i<=Length(subo) do
	    bb:=Blocks(img,dom,[1,subo[i]]);
	    if Length(bb)>1 and not bb[1] in bp then
	      Info(InfoFactor,3,"found block system ",bb[1]);
	      # new nontriv. system found 
	      AddSet(bp,bb[1]);
	      # store action
	      op:=ActionHomomorphism(img,bb,OnSets,"surjective");
	      k:=KernelOfMultiplicativeGeneralMapping(op);
	      op:=GroupHomomorphismByImagesNC(G,Range(op),
                     GeneratorsOfGroup(G),
		     List(gens,i->Image(op,i)));
	      SetKernelOfMultiplicativeGeneralMapping(op,PreImages(oh,k));
	      AddNaturalHomomorphismsPool(G,
                  KernelOfMultiplicativeGeneralMapping(op),
                                          op,Length(bb));
	      # and note whether we got better
	      improve:=improve or (Size(k)=1);
	      if Size(k)=1 and Length(bb)<bestdeg then
	        bestdeg:=Length(bb);
	      fi;
	    fi;
	    # break the test loop if we found a fairly small block system
	    # (iterate greedily immediately)
	    if improve and bestdeg<i then
	      i:=Length(dom);
	    fi;
	    i:=i+1;
	  od;
	else
	  Info(InfoFactor,2,"try only one system");
	  op:=ActionHomomorphism(img,b,OnSets,"surjective");
	  k:=KernelOfMultiplicativeGeneralMapping(op);
	  # keep action knowledge
	  op:=GroupHomomorphismByImagesNC(G,Range(op),GeneratorsOfGroup(G),
	     List(gens,i->Image(op,i)));
	  SetKernelOfMultiplicativeGeneralMapping(op,PreImages(oh,k));
	  AddNaturalHomomorphismsPool(G,
              KernelOfMultiplicativeGeneralMapping(op),
                                      op,Length(b));
	  improve:=improve or (Size(k)=1);
	fi;
	if improve then
	  # update mapping
	  oh:=GetNaturalHomomorphismsPool(G,N);
	  img:=Image(oh,G);
	  dom:=MovedPoints(img);
	fi;
      fi;
    until improve=false;
  fi;
  Info(InfoFactor,1,"end of blocks search");
  return DegreeNaturalHomomorphismsPool(G,N);
end);

#############################################################################
##
#F  SmallerDegreePermutationRepresentation( <G> )
##
InstallGlobalFunction(SmallerDegreePermutationRepresentation,function(G)
local H;
  if not IsTransitive(G,MovedPoints(G)) then
    Error("need transitive operation");
  fi;
  H:= GroupWithGenerators( GeneratorsOfGroup( G ) );
  if HasSize(G) then
    SetSize(H,Size(G));
  fi;
  ImproveActionDegreeByBlocks(H,TrivialSubgroup(H),IdentityMapping(H));
  return GetNaturalHomomorphismsPool(H,TrivialSubgroup(H));
end);

#############################################################################
##
#F  GenericFindActionKernel  random search for subgroup with faithful core
##
BADINDEX:=1000; # the index that is too big
GenericFindActionKernel:=function(arg)
local G,N,u,v,bv,cnt,zen,uc,nu,totalcnt,interupt,cor,badi;
  G:=arg[1];
  N:=arg[2];
  uc:=TrivialSubgroup(G);
  # look if it is worth to look at action on N
  # if not abelian: later replace by abelian Normal subgroup
  if IsAbelian(N) and (Size(N)>50 or Index(G,N)<Factorial(Size(N)))
      and Size(N)<50000 then
    zen:=Centralizer(G,N);
    if Size(zen)=Size(N) then
      cnt:=0;
      repeat
	cnt:=cnt+1;
	zen:=Centralizer(G,Random(N));
	if Size(Core(G,zen))=Size(N) and
	    Index(G,zen)<Index(G,uc) then
	  uc:=zen;
	fi;
      # until enough searched or just one orbit
      until cnt=9 or (Index(G,zen)+1=Size(N));
    else
      Info(InfoFactor,3,"centralizer too big");
    fi;
  fi;

  # try a random extension step
  # (We might always first add a random element and get something bigger)
  v:=N;
  bv:=v;

  #if Length(arg)=3 then
    ## in one example 512->90, ca. 40 tries
    #cnt:=Int(arg[3]/10);
  #else
    #cnt:=25;
  #fi;

  totalcnt:=0;
  interupt:=false;
  cnt:=20;
  badi:=BADINDEX;
  repeat
    u:=v;
    repeat
      repeat
	if Length(arg)<4 or Random([1,2])=1 then
	  nu:=ClosureGroup(u,Random(G));
	else
	  nu:=ClosureGroup(u,Random(arg[4]));
	fi;
	totalcnt:=totalcnt+1;
	if Length(arg)>2 and Minimum(Index(G,v),arg[3])<20000 
	     and 10*totalcnt>Minimum(Index(G,v),arg[3]) then
	  # interupt if we're already quite good
	  interupt:=true;
	fi;
	# Abbruchkriterium: Bis kein Normalteiler, es sei denn, es ist N selber
	# (das brauchen wir, um in einigen trivialen F"allen abbrechen zu
	# k"onnen)
      until 
        # der Index ist nicht so klein, da"s wir keine Chance haben
	((Index(G,nu)>50 or Factorial(Index(G,nu))>=Index(G,N)) and
	not IsNormal(G,nu)) or IsSubset(u,nu) or interupt;
      u:=nu;
    until 
      # und die Gruppe ist nicht zuviel schlechter als der
      # beste bekannte Index. Daf"ur brauchen wir aber wom"oglich mehrfache
      # Erweiterungen.
      interupt or (((Length(arg)=2 or Index(G,u)<=100*arg[3])));

    cor:=Core(G,u);

    if Size(u)>Size(v) and Size(cor)=Size(N) then
      v:=u;
    fi;

    # store known information(we do't act, just store the subgroup.
    # Thus this is fairly cheap
    AddNaturalHomomorphismsPool(G,cor,u,Index(G,u));

    Info(InfoFactor,2,"  ext ",cnt,": ",Index(G,u)," ",Index(G,v)," ",
             v=u,":",totalcnt);
    cnt:=cnt-1;

    if Size(v)>Size(bv) then
      bv:=v;
    fi;

    if cnt=0 and DegreeNaturalHomomorphismsPool(G,N)>badi then
      Info(InfoWarning,2,"index unreasonably large, iterating");
      badi:=Int(badi*11/10);
      cnt:=20;
      v:=N; # all new
    fi;
  until interupt or cnt<=0 or Index(G,bv)<100;
  u:=bv;

  if Index(G,uc)<Index(G,u) then
    Info(InfoFactor,1,"use centralizer");
    u:=uc;
  fi;

  # will we need the coset operation?
  if (Length(arg)=2 and Index(G,u)<10000) 
     or(Length(arg)>2 and arg[3]>Index(G,u)) then
    #FactorCosetAction(G,u,N);
    ImproveActionDegreeByBlocks(G,N,u); # computes and stores
    return GetNaturalHomomorphismsPool(G,N);
  else
    # too big, rely on canonical routine
    return fail;
  fi;
end;


#############################################################################
##
#M  FindActionKernel(<G>)  . . . . . . . . . . . . . . . . . . . . generic
##
InstallMethod(FindActionKernel,"generic for finite groups",IsIdenticalObj,
  [IsGroup and IsFinite,IsGroup],0,
function(G,N)
  return GenericFindActionKernel(G,N);
end);

InstallMethod(FindActionKernel,"general case: can't do",IsIdenticalObj,
  [IsGroup,IsGroup],0,
function(G,N)
  return fail;
end);


#############################################################################
##
#M  FindActionKernel(<G>)  . . . . . . . . . . . . . . . . . . . . permgrp
##
InstallMethod(FindActionKernel,"perm",IsIdenticalObj,
  [IsPermGroup,IsPermGroup],0,
function(G,N)
local o,oo,s,i,u,m,v,cnt,comb,bestdeg,dom,blocksdone,pool;

  if Index(G,N)<50 then
    # small index, anything is OK
    return GenericFindActionKernel(G,N);
  else
    # get the known ones, including blocks &c. which might be of use
    DoCheapActionImages(G);

    pool:=NaturalHomomorphismsPool(G);
    dom:=MovedPoints(G);

    # store regular to have one anyway
    bestdeg:=Index(G,N);
    AddNaturalHomomorphismsPool(G,N,N,bestdeg);

    blocksdone:=false;
    # use subgroup that fixes a base of N
    # get orbits of a suitable stabilizer.
    o:=BaseOfGroup(N);
    s:=Stabilizer(G,o,OnTuples);
    if Size(s)>1 then
      cnt:=Filtered(Orbits(s,dom),i->Length(i)>1);
      for i in cnt do
	v:=ClosureGroup(N,Stabilizer(s,i[1]));
	if Size(v)>Size(N) and Index(G,v)<2000 then
	  u:=Core(G,v);
	  AddNaturalHomomorphismsPool(G,u,v,Index(G,v));
	fi;
      od;
      # try also intersections
      CloseNaturalHomomorphismsPool(G,N);

      bestdeg:=DegreeNaturalHomomorphismsPool(G,N);

      Info(InfoFactor,1,"Base Stabilizer and known, best Index ",bestdeg);

      if bestdeg<500 and bestdeg<Index(G,N) then
	# should be better...
	bestdeg:=ImproveActionDegreeByBlocks(G,N,
	  GetNaturalHomomorphismsPool(G,N));
	blocksdone:=true;
	Info(InfoFactor,2,"Blocks improve to ",bestdeg);
      fi;
    fi;

    # then we should look at the orbits of the normal subgroup to see,
    # whether anything stabilizing can be of use
    o:=Filtered(Orbits(N,dom),i->Length(Orbit(G,i[1]))>Length(i));
    Apply(o,Set);
    oo:=Orbits(G,o,OnSets);
    s:=G;
    for i in oo do
      s:=StabilizerOfBlockNC(s,i[1]);
    od;
    Info(InfoFactor,2,"stabilizer of index ",Index(G,s));

    m:=Core(G,s); # the normal subgroup we get this way.
    AddNaturalHomomorphismsPool(G,m,s,Index(G,s));

    if Size(m)=Size(N) and Index(G,s)<bestdeg then
      bestdeg:=Index(G,s);
      blocksdone:=false;
      Info(InfoFactor,2,"Orbits Stabilizer improves to index ",bestdeg);
    elif Size(m)>Size(N) then
      # no hard work for trivial cases
      if 2*Index(G,N)>Length(o) then
	# try to find a subgroup, which does not contain any part of m
	# For wreath products (the initial aim), the following method works
	# fairly well
	v:=Subgroup(G,Filtered(GeneratorsOfGroup(G),i->not i in m));
	v:=SmallGeneratingSet(v);

	cnt:=Length(v);
	repeat
	  for comb in Combinations([1..Length(v)],cnt) do
    #Print(">",comb,"\n");
	    u:=Subgroup(G,v{comb});
	    o:=ClosureGroup(N,u);
	    if Index(G,o)<bestdeg and Size(Core(G,o))=Size(N) then
	      bestdeg:=Index(G,o);
	      AddNaturalHomomorphismsPool(G,N,o,bestdeg);
	      blocksdone:=false;
	      cnt:=0;
	    fi;
	  od;
	  cnt:=cnt-1;
	until cnt<=0;
      fi;
    fi;

    Info(InfoFactor,2,"Orbits Stabilizer, Best Index ",bestdeg);
    # first force blocks
    if (not blocksdone) and bestdeg<200 and bestdeg<Index(G,N) then
      bestdeg:=ImproveActionDegreeByBlocks(G,N,
	GetNaturalHomomorphismsPool(G,N));
      blocksdone:=true;
      Info(InfoFactor,2,"Blocks improve to ",bestdeg);
    fi;

    if bestdeg=Index(G,N) or 
      (bestdeg>400 and not(bestdeg<=2*NrMovedPoints(G))) then
      if GenericFindActionKernel(G,N,bestdeg,s)<>fail then
	blocksdone:=true;
      fi;
      Info(InfoFactor,1,"  Random search found ",
           DegreeNaturalHomomorphismsPool(G,N));
    #if (bestdeg>500 and Index(G,o)<5000) or Index(G,o)<bestdeg then
    #  # tell 'IODBB' not to doo too much blocksearch
    #  o:=ImproveActionDegreeByBlocks(G,o,N,bestdeg<Index(G,o));
    #  Info(InfoFactor,1,"  Blocks improve to ",Index(G,o),"\n");
    #fi;
    fi;

    if not blocksdone then
      ImproveActionDegreeByBlocks(G,N,GetNaturalHomomorphismsPool(G,N));
    fi;

    return GetNaturalHomomorphismsPool(G,N);
    return o;
  fi;

end);

#############################################################################
##
#M  FindActionKernel(<G>)  . . . . . . . . . . . . . . . . . . . . generic
##
InstallMethod(FindActionKernel,"Niceo",IsIdenticalObj,
  [IsGroup and IsHandledByNiceMonomorphism,IsGroup],0,
function(G,N)
local hom;
  hom:=NiceMonomorphism(G);
  return hom*GenericFindActionKernel(Image(hom,G),Image(hom,N));
end);


#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> )  . .  mapping G ->> G/N
##                             this function returns an epimorphism from G
##  with kernel N. The range of this mapping is a suitable (isomorphic) 
##  permutation group (with which we can compute much easier).
InstallMethod(NaturalHomomorphismByNormalSubgroupOp,
  "search for operation",IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,N)
local h;

  # catch the trivial case N=G (N=1 is a separately installed method)
  if CanComputeIndex(G,N) and Index(G,N)=1 then
    h:=GroupByGenerators( [], () );
    h:=GroupHomomorphismByImagesNC( G, h, GeneratorsOfGroup( G ),
                                    List( GeneratorsOfGroup( G ), i -> () ));
    SetKernelOfMultiplicativeGeneralMapping( h, G );
    return h;
  fi;

  # check, whether we already know a factormap
  DoCheapActionImages(G);
  h:=GetNaturalHomomorphismsPool(G,N);
  if h=fail then
    # now we try to find a suitable operation
    h:=FindActionKernel(G,N);
    if h<>fail then
      Info(InfoFactor,1,"Action of degree ",
	Length(MovedPoints(Range(h)))," found");
    else
      Error("I don't know how to find a natural homomorphism for <N> in <G>");
      # nothing had been found, still rely on 'NatHom'
      h:= NaturalHomomorphismByNormalSubgroup( G, N );
    fi;
  fi;
  # return the map
  return h;
end);

#############################################################################
##
#E  factgrp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##