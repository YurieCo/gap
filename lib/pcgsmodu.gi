#############################################################################
##
#W  pcgsmodu.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the   methods for polycylic generating  systems modulo
##  another such system.
##
Revision.pcgsmodu_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsModuloPcgsRep
##
DeclareRepresentation( "IsModuloPcgsRep", IsPcgsDefaultRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap" ] );


#############################################################################
##
#R  IsModuloTailPcgsRep
##
DeclareRepresentation( "IsModuloTailPcgsRep", IsModuloPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap" ] );

#############################################################################
##
#R  IsNumeratorParentForExponentsRep(<obj>)
##
##  modulo pcgs in this representation can use the numerator parent for
##  computing exponents
DeclareRepresentation( "IsNumeratorParentForExponentsRep",
    IsModuloPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap","depthsInParent","numeratorParent","parentZeroVector" ] );

#############################################################################
##
#R  IsSubsetInducedNumeratorModuloTailPcgsRep(<obj>)
##
DeclareRepresentation( "IsSubsetInducedNumeratorModuloTailPcgsRep",
    IsModuloTailPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap","depthsInParent","numeratorParent","parentZeroVector" ] );

#############################################################################
##
#R  IsModuloTailPcgsByListRep(<obj>)
##
DeclareRepresentation( "IsModuloTailPcgsByListRep", IsModuloTailPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap","depthsInParent","numeratorParent","parentZeroVector" ] );

#############################################################################
##
#M  IsBound[ <pos> ]
##
InstallMethod( IsBound\[\],
    true,
    [ IsModuloPcgs,
      IsPosInt ],
    0,

function( pcgs, pos )
    return pos <= Length(pcgs);
end );


#############################################################################
##
#M  Length( <pcgs> )
##
InstallMethod( Length,
    true,
    [ IsModuloPcgs and IsModuloPcgsRep ],
    0,
    pcgs -> Length(pcgs!.pcSequence) );


#############################################################################
##
#M  Position( <pcgs>, <elm>, <from> )
##
InstallMethod( Position,
    true,
    [ IsModuloPcgs and IsModuloPcgsRep,
      IsObject,
      IsInt ],
    0,

function( pcgs, obj, from )
    return Position( pcgs!.pcSequence, obj, from );
end );


#############################################################################
##
#M  PrintObj( <modulo-pcgs> )
##
InstallMethod( PrintObj,
    true,
    [ IsModuloPcgs ],
    0,

function( obj )
    Print( "(", NumeratorOfModuloPcgs(obj), " mod ",
           DenominatorOfModuloPcgs(obj), ")" );
end );


#############################################################################
##
#M  <pcgs> [ <pos> ]
##
InstallMethod( \[\],
    true,
    [ IsModuloPcgs and IsModuloPcgsRep,
      IsPosInt ],
    0,

function( pcgs, pos )
    return pcgs!.pcSequence[pos];
end );


#AH: 3-5-99: this is nowhere used
# #############################################################################
# ##
# #M  ModuloParentPcgs( <pcgs> )
# ##
# InstallMethod( ModuloParentPcgs,
#     true,
#     [ IsPcgs ],
#     0,
#     pcgs -> ParentPcgs( pcgs ) mod pcgs );

#############################################################################
##
#M  ModuloTailPcgsByList( <home>, <list>, <taildepths> )
##
InstallGlobalFunction( ModuloTailPcgsByList,
function( home, factor, wm )
local   wd,  filter,  new,  i;

  if IsSubset(home,factor) then
    wd:=List(factor,i->Position(home,i));
  else
    wd:=List(factor,i->DepthOfPcElement(home,i));
  fi;

  # check which filter to use
  filter := IsModuloPcgs and IsModuloTailPcgsRep 
	    and IsModuloTailPcgsByListRep;

  if IsSubset(home,factor) then
    filter:=filter and IsSubsetInducedNumeratorModuloTailPcgsRep;
  fi;

  if Length(wd)=Length(Set(wd)) then
    # the depths are all different. We can get the exponetnts from the
    # parent pcgs
    filter:=filter and IsNumeratorParentForExponentsRep;
  fi;

  if HasIsParentPcgsFamilyPcgs(home) 
      and IsParentPcgsFamilyPcgs(home) then
    filter:=filter and IsNumeratorParentPcgsFamilyPcgs;
  fi;

  if IsPrimeOrdersPcgs(home)  then
      filter := filter and HasIsPrimeOrdersPcgs and IsPrimeOrdersPcgs
                       and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
  elif IsFiniteOrdersPcgs(home)  then
      filter := filter and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
  fi;

  # construct a pcgs from <pcs>
  new := PcgsByPcSequenceCons(
	      IsPcgsDefaultRep,
	      filter,
	      FamilyObj(OneOfPcgs(home)),
	      factor,[]);

  SetRelativeOrders(new,RelativeOrders(home){wd});
  # store other useful information
  new!.moduloDepths := wm;

  # setup the maps
  new!.moduloMap := [];
  for i  in [ 1 .. Length(wm) ]  do
      new!.moduloMap[wm[i]] := i;
  od;
  new!.depthMap := [];
  for i  in [ 1 .. Length(wd) ]  do
      new!.depthMap[wd[i]] := i;
  od;

  new!.numeratorParent:=home;
  new!.depthsInParent:=wd;
  new!.parentZeroVector:=home!.zeroVector;

  # and return
  return new;
end);

#############################################################################
##
#M  ModuloPcgsByPcSequenceNC( <home>, <pcs>, <modulo> )
##
InstallMethod( ModuloPcgsByPcSequenceNC, "generic method for pcgs mod pcgs",
    true, [ IsPcgs, IsList, IsPcgs ], 0,

function( home, list, modulo )
    local   pcgs,  wm,  wp,  wd,  pcs,  filter,  new,  i,depthsInParent;

    # <list> is a pcgs for the sum of <list> and <modulo>
    if IsPcgs(list) and (ParentPcgs(modulo) = list or IsSubset(list,modulo)) 
      then
        pcgs := list;
        wm   := List( modulo, x -> DepthOfPcElement( pcgs, x ) );
        wp   := [ 1 .. Length(list) ];
        wd   := Difference( wp, wm );
        pcs  := list{wd};

    # otherwise compute the sum
    else
        pcgs := SumPcgs( home, modulo, list );
        wm   := List( modulo, x -> DepthOfPcElement( pcgs, x ) );
        wp   := List( list,   x -> DepthOfPcElement( pcgs, x ) );
        if not IsSubset( pcgs, list )  then
            pcgs := List(pcgs);
            for i  in [ 1 .. Length(list) ]  do
                pcgs[wp[i]] := list[i];
            od;
            pcgs := InducedPcgsByPcSequenceNC( home, pcgs );
        fi;
        wd   := Difference( wp, wm );
        pcs  := list{ List( wd, x -> Position( wp, x ) ) };
    fi;

    # check which filter to use
    filter := IsModuloPcgs and 
	      HasDenominatorOfModuloPcgs and HasNumeratorOfModuloPcgs;

    depthsInParent:=fail; # do not set by default
    if IsEmpty(wd) or wd[Length(wd)] = Length(wd)  then
        filter := filter and IsModuloTailPcgsRep;
	# are we even: tail mod further tail?
        if IsSubsetInducedPcgsRep(pcgs) and IsModuloTailPcgsRep(pcgs)
	  and IsBound(pcgs!.depthsInParent) then
	  filter:=filter and IsSubsetInducedNumeratorModuloTailPcgsRep;
	  depthsInParent:=pcgs!.depthsInParent;
	  # is everything even family induced?
	  if HasIsParentPcgsFamilyPcgs(pcgs) 
	     and IsParentPcgsFamilyPcgs(pcgs) then
	    filter:=filter and IsNumeratorParentPcgsFamilyPcgs;
	  fi;
	elif HasIsFamilyPcgs(pcgs) and IsFamilyPcgs(pcgs) then
	  # the same if the enumerator is not induced but actually the
	  # familypcgs
	  filter:=filter and IsSubsetInducedNumeratorModuloTailPcgsRep
		  and IsNumeratorParentPcgsFamilyPcgs;
	  depthsInParent:=[1..Length(pcgs)]; # not stored in FamilyPcgs
	fi;
    else
      if Length(wd)=Length(Set(wd)) and IsSubset(list,modulo) then
	# the depths are all different and the modulus is just a tail. We
	# can get the exponents from the parent pcgs.
	filter:=filter and IsNumeratorParentForExponentsRep;
	if not IsBound(pcgs!.depthsInParent) then
	  pcgs!.depthsInParent:=List(pcgs,i->DepthOfPcElement(Parent(pcgs),i));
	fi;
	depthsInParent:=pcgs!.depthsInParent;
      else
	filter := filter and IsModuloPcgsRep;
      fi;
    fi;
    if IsPrimeOrdersPcgs(home)  then
	filter := filter and HasIsPrimeOrdersPcgs and IsPrimeOrdersPcgs
			and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
    elif IsFiniteOrdersPcgs(home)  then
	filter := filter and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
    fi;

    # store the one and other information

    # construct a pcgs from <pcs>
    new := PcgsByPcSequenceCons(
               IsPcgsDefaultRep,
               filter,
               FamilyObj(OneOfPcgs(pcgs)),
               pcs,
	       [DenominatorOfModuloPcgs, modulo,
		NumeratorOfModuloPcgs, pcgs ]);

    SetRelativeOrders(new,RelativeOrders(pcgs){wd});
    # store other useful information
    new!.moduloDepths := wm;

    # setup the maps
    new!.moduloMap := [];
    for i  in [ 1 .. Length(wm) ]  do
        new!.moduloMap[wm[i]] := i;
    od;
    new!.depthMap := [];
    for i  in [ 1 .. Length(wd) ]  do
        new!.depthMap[wd[i]] := i;
    od;

    if depthsInParent<>fail then
      new!.numeratorParent:=ParentPcgs(pcgs);
      new!.depthsInParent:=depthsInParent{wd};
      new!.parentZeroVector:=ParentPcgs(pcgs)!.zeroVector;
    fi;

    # and return
    return new;

end );


#############################################################################
##
#M  ModuloPcgsByPcSequence( <home>, <pcs>, <modulo> )
##
InstallMethod( ModuloPcgsByPcSequence,
    "generic method",
    true,
    [ IsPcgs,
      IsList,
      IsInducedPcgs ],
    0,

function( home, list, modulo )
    return ModuloPcgsByPcSequenceNC( home, list, modulo );
end );


#############################################################################
##
#M  <pcgs1> mod <induced-pcgs2>
##
InstallMethod( MOD,"parent pcgs mod induced pcgs",
    IsIdenticalObj,
    [ IsPcgs,
      IsInducedPcgs ],
    0,

function( pcgs, modulo )
    if ParentPcgs(modulo) <> pcgs  then
        TryNextMethod();
    fi;
    return ModuloPcgsByPcSequenceNC( pcgs, pcgs, modulo );
end );

#############################################################################
##
#M  <pcgs1> mod <pcgs2>
##
InstallMethod( MOD,"two parent pcgs",
    IsIdenticalObj,
    [ IsPcgs,
      IsPcgs ],
    0,

function( pcgs, modulo )
    if modulo <> pcgs  then
        TryNextMethod();
    fi;
    return ModuloPcgsByPcSequenceNC( pcgs, pcgs, modulo );
end );


#############################################################################
##
#M  <induced-pcgs1> mod <induced-pcgs2>
##
InstallMethod( MOD,"two induced pcgs",
    IsIdenticalObj,
    [ IsInducedPcgs,
      IsInducedPcgs ],
    0,

function( pcgs, modulo )
    if ParentPcgs(modulo) <> ParentPcgs(pcgs)  then
        TryNextMethod();
    fi;
    return ModuloPcgsByPcSequenceNC( ParentPcgs(pcgs), pcgs, modulo );
end );


#############################################################################
##
#M  <modulo-pcgs1> mod <modulo-pcgs2>
##
InstallMethod( MOD,"two modulo pcgs",
    IsIdenticalObj,
    [ IsModuloPcgs,
      IsModuloPcgs ],
    0,

function( pcgs, modulo )
    if DenominatorOfModuloPcgs(pcgs) <> DenominatorOfModuloPcgs(modulo)  then
        Error( "denominators of <pcgs> and <modulo> are not equal" );
    fi;
    return NumeratorOfModuloPcgs(pcgs) mod NumeratorOfModuloPcgs(modulo);
end );


#############################################################################
##
#M  <(induced)pcgs1> mod <(induced)pcgs 2>
##
InstallMethod( MOD,"two induced pcgs",
    IsIdenticalObj, [ IsPcgs, IsPcgs ], 0,
function( pcgs, modulo )

  # enforce the same parent pcgs
  if ParentPcgs(modulo) <> ParentPcgs(pcgs)  then
    modulo:=InducedPcgsByGeneratorsNC(ParentPcgs(pcgs),AsList(modulo));
  fi;

  return ModuloPcgsByPcSequenceNC( ParentPcgs(pcgs), pcgs, modulo );
end);

#############################################################################
##
#M  DepthOfPcElement( <modulo-pcgs>, <elm>, <min> )
##
InstallOtherMethod( DepthOfPcElement,
    "pcgs modulo pcgs, ignoring <min>",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsModuloPcgs,
      IsObject,
      IsInt ],
    0,

function( pcgs, elm, min )
    local   dep;

    dep := DepthOfPcElement( pcgs, elm );
    if dep < min  then
        Error( "minimal depth <min> is incorrect" );
    fi;
    return dep;
end );


#############################################################################
##
#M  ExponentOfPcElement( <modulo-pcgs>, <elm>, <pos> )
##
InstallOtherMethod( ExponentOfPcElement,
    "pcgs modulo pcgs, ExponentsOfPcElement", IsCollsElmsX,
    [ IsModuloPcgs, IsObject, IsPosInt ], 0,
function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm)[pos];
end );


#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <elm>, <poss> )
##
InstallOtherMethod( ExponentsOfPcElement,
  "pcgs mod. pcgs,range, falling back to Exp.OfPcElement", IsCollsElmsX,
    [ IsModuloPcgs, IsObject, IsList ], 0,
function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm){pos};
end );


#############################################################################
##
#M  IsFiniteOrdersPcgs( <modulo-pcgs> )
##
InstallOtherMethod( IsFiniteOrdersPcgs, true, [ IsModuloPcgs ], 0,
function( pcgs )
    return ForAll( RelativeOrders(pcgs), x -> x <> 0 and x <> infinity );
end );


#############################################################################
##
#M  IsPrimeOrdersPcgs( <modulo-pcgs> )
##
InstallOtherMethod( IsPrimeOrdersPcgs,
    true,
    [ IsModuloPcgs ],
    0,

function( pcgs )
    return ForAll( RelativeOrders(pcgs), x -> IsPrimeInt(x) );
end );



#############################################################################
##
#M  LeadingExponentOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( LeadingExponentOfPcElement,
    "pcgs modulo pcgs, use ExponentsOfPcElement", IsCollsElms,
    [ IsModuloPcgs, IsObject ], 0,
function( pcgs, elm )
    local   exp,  dep;

    exp := ExponentsOfPcElement( pcgs, elm );
    dep := PositionNot( exp, 0 );
    if Length(exp) < dep  then
        return fail;
    else
        return exp[dep];
    fi;
end );



#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <empty-list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method for empty lists",
    true, [ IsModuloPcgs, IsList and IsEmpty ], 0,
function( pcgs, list )
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method: modulo", true,
    [ IsModuloPcgs, IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs, list )
    local   elm,  i;

    elm := fail;

    for i  in [ 1 .. Length(list) ]  do
      if list[i]=1  then
	if elm=fail then elm := pcgs[i];
	else elm := elm * pcgs[i];fi;
      elif list[i] <> 0  then
	if elm=fail then elm := pcgs[i] ^ list[i];
	else elm := elm * pcgs[i] ^ list[i];fi;
      fi;
    od;
    if elm=fail then elm := OneOfPcgs(pcgs);fi;

    return elm;

end );


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <ffe-list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method: modulo, FFE",
    true, [ IsModuloPcgs, IsRowVector and IsFFECollection ], 0,
function( pcgs, list )
    local   elm,  i,z;

    elm := fail;

    for i  in [ 1 .. Length(list) ]  do
      z :=IntFFE(list[i]);
      if z=1 then
	if elm=fail then elm := pcgs[i] ;
	else elm := elm * pcgs[i] ; fi;
      elif z>1 then
	if elm=fail then elm := pcgs[i] ^ z;
	else elm := elm * pcgs[i] ^ z;fi;
      fi;
    od;
    if elm=fail then elm := OneOfPcgs(pcgs);fi;

    return elm;

end );


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <empty-list> )
##
InstallOtherMethod( PcElementByExponentsNC,
    "generic method for empty list as basis or basisindex, modulo", true,
    [ IsModuloPcgs, IsList and IsEmpty, IsList ],
    SUM_FLAGS, #this is better than everything else

function( pcgs, basis, list )
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method: modulo, basis",
    IsFamFamX, [IsModuloPcgs,IsList,IsRowVector and IsCyclotomicCollection], 0,
function( pcgs, basis, list )
    local   elm,  i;

    elm := OneOfPcgs(pcgs);

    for i  in [ 1 .. Length(list) ]  do
        if list[i] <> 0  then
            elm := elm * basis[i] ^ list[i];
        fi;
    od;

    return elm;

end );

#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC,
    "generic method: modulo, basis, FFE", IsFamFamX,
    [ IsModuloPcgs, IsList, IsRowVector and IsFFECollection ], 0,
function( pcgs, basis, list )
    local   elm,  i,  z;

    elm := OneOfPcgs(pcgs);

    for i  in [ 1 .. Length(list) ]  do
        z := IntFFE(list[i]);
	if z=1 then
	  elm := elm * basis[i] ;
	elif z>1 then
	  elm := elm * basis[i] ^ z;
	fi;
    od;

    return elm;

end );


#############################################################################
##
#M  ReducedPcElement( <pcgs>, <left>, <right> )
##
InstallOtherMethod( ReducedPcElement,
    "pcgs modulo pcgs",
    IsCollsElmsElms,
    [ IsModuloPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    return ReducedPcElement( NumeratorOfModuloPcgs(pcgs), left, right );
end );


#############################################################################
##
#M  RelativeOrderOfPcElement( <pcgs>, <elm> )
##
InstallOtherMethod( RelativeOrderOfPcElement,
    "pcgs modulo pcgs",
    IsCollsElms,
    [ IsModuloPcgs and IsPrimeOrdersPcgs,
      IsObject ],
    # as we fall back on the code for pcgs, we must be sure that the method
    # has lower value
    SIZE_FLAGS(FLAGS_FILTER(IsModuloPcgs))
    -SIZE_FLAGS(FLAGS_FILTER(IsModuloPcgs and IsPrimeOrdersPcgs)),

function( pcgs, elm )
    return RelativeOrderOfPcElement( NumeratorOfModuloPcgs(pcgs), elm );
end );

#############################################################################
##

#M  DepthOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( DepthOfPcElement,
    "pcgs modulo pcgs",
    IsCollsElms,
    [ IsModuloPcgs and IsModuloPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   d,  num;

    num := NumeratorOfModuloPcgs(pcgs);
    d := DepthOfPcElement( num, elm );
    if d > Length(num)  then
        return Length(pcgs)+1;
    elif d in pcgs!.moduloDepths  then
        return PositionNot( ExponentsOfPcElement( pcgs, elm ), 0 );
    else
        return pcgs!.depthMap[d];
    fi;
end );

#############################################################################
##
#M  ExponentsOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement, "pcgs modulo pcgs", IsCollsElms,
    [ IsModuloPcgs and IsModuloPcgsRep, IsObject ], 0,
function( pcgs, elm )
    local   id,  exp,  ros,  den,  num,  wm,  mm,  pm,  d,  ll,  lr;

    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length(pcgs),0);
    den := DenominatorOfModuloPcgs(pcgs);
    num := NumeratorOfModuloPcgs(pcgs);
    if not IsPrimeOrdersPcgs(num)  then TryNextMethod();  fi;

    wm  := pcgs!.moduloDepths;
    mm  := pcgs!.moduloMap;
    pm  := pcgs!.depthMap;
    ros := RelativeOrders(num);

    while elm <> id  do
        d := DepthOfPcElement( num, elm );

        if IsBound(mm[d])  then
            ll  := LeadingExponentOfPcElement( num, elm );
            lr  := LeadingExponentOfPcElement( num, den[mm[d]] );
            elm := LeftQuotient( den[mm[d]]^(ll / lr mod ros[d]), elm );
        else
            ll := LeadingExponentOfPcElement( num, elm );
            lr := LeadingExponentOfPcElement( num, pcgs[pm[d]] );
            exp[pm[d]] := ll / lr mod ros[d];
            elm := LeftQuotient( pcgs[pm[d]]^exp[pm[d]], elm );
        fi;
    od;
    return exp;
end );

#############################################################################
##
#M  ExponentsOfPcElement( <modulo-pcgs>, <elm>, <subrange> )
##
InstallOtherMethod( ExponentsOfPcElement, "pcgs modulo pcgs, subrange",
    IsCollsElmsX, [ IsModuloPcgs and IsModuloPcgsRep, IsObject,IsList ], 0,
function( pcgs, elm,range )
    local   id,  exp,  ros,  den,  num,  wm,  mm,  pm,  d,  ll,  lr,max;

    if not IsSSortedList(range) then
      TryNextMethod(); # the range may be unsorted or contain duplicates,
      # then we would have to be more clever.
    fi;
    max:=Maximum(range);

    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length(pcgs),0);
    den := DenominatorOfModuloPcgs(pcgs);
    num := NumeratorOfModuloPcgs(pcgs);
    if not IsPrimeOrdersPcgs(num)  then TryNextMethod();  fi;

    wm  := pcgs!.moduloDepths;
    mm  := pcgs!.moduloMap;
    pm  := pcgs!.depthMap;
    ros := RelativeOrders(num);

    while elm <> id  do
      d := DepthOfPcElement( num, elm );
      if IsBound(pm[d]) and pm[d]>max then
	# we have reached the maximum of the range we asked for. Thus we
	# can stop calculating exponents now, all further exponents would
	# be discarded anyhow.
	# Note that the depthMap is sorted!
	elm:=id;
      else
        if IsBound(mm[d])  then
            ll  := LeadingExponentOfPcElement( num, elm );
            lr  := LeadingExponentOfPcElement( num, den[mm[d]] );
            elm := LeftQuotient( den[mm[d]]^(ll / lr mod ros[d]), elm );
        else
            ll := LeadingExponentOfPcElement( num, elm );
            lr := LeadingExponentOfPcElement( num, pcgs[pm[d]] );
            exp[pm[d]] := ll / lr mod ros[d];
            elm := LeftQuotient( pcgs[pm[d]]^exp[pm[d]], elm );
        fi;
      fi;
    od;
    exp:=exp{range};
    return exp;
end );


#############################################################################
##
#M  ExponentsOfPcElement( <tail-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement, "pcgs modulo tail-pcgs", IsCollsElms,
    [ IsModuloPcgs and IsModuloTailPcgsRep, IsObject ], 0,
function( pcgs, elm )
    return ExponentsOfPcElement(
        NumeratorOfModuloPcgs(pcgs), elm, pcgs!.depthMap );
end );

#############################################################################
##
#M  ExponentsOfPcElement( <tail-pcgs>, <elm>, <subrange> )
##
InstallOtherMethod( ExponentsOfPcElement, "pcgs modulo tail-pcgs, subrange",
    IsCollsElmsX, [ IsModuloPcgs and IsModuloTailPcgsRep, IsObject,IsList ], 0,
function( pcgs, elm,range )
    return ExponentsOfPcElement(
        NumeratorOfModuloPcgs(pcgs), elm, pcgs!.depthMap{range} );
end );

#############################################################################
##
#M  ExponentOfPcElement( <tail-pcgs>, <elm>, <pos> )
##
InstallOtherMethod( ExponentOfPcElement,
    "pcgs modulo tail-pcgs, ExponentsOfPcElement",IsCollsElmsX,
    [ IsModuloPcgs and IsModuloTailPcgsRep,
      IsObject,
      IsPosInt ], 0,
function( pcgs, elm, pos )
    return ExponentOfPcElement(
        NumeratorOfModuloPcgs(pcgs), elm, pcgs!.depthMap[pos] );
end );

#############################################################################
##
#M  ExponentsOfPcElement( <subset-induced,modulo-tail-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "subset induced pcgs modulo tail-pcgs", IsCollsElms,
    [ IsModuloPcgs and IsModuloTailPcgsRep
      and IsNumeratorParentForExponentsRep, IsObject ], 0,
function( pcgs, elm )
    return
      ExponentsOfPcElement(pcgs!.numeratorParent,elm,pcgs!.depthsInParent);
end );

#############################################################################
##
#M  ExponentsOfPcElement( <subset-induced,modulo-tail-pcgs>,<elm>,<subrange> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "subset induced pcgs modulo tail-pcgs, subrange",
    IsCollsElmsX,
    [ IsModuloPcgs and IsModuloTailPcgsRep
      and IsNumeratorParentForExponentsRep, IsObject,IsList ], 0,
function( pcgs, elm, range )
    return
      ExponentsOfPcElement(pcgs!.numeratorParent,elm,pcgs!.depthsInParent{range});
end );

#############################################################################
##
#M  ExponentsOfRelativePower( <subset-induced,modulo-tail-pcgs>, <> )
##
InstallOtherMethod( ExponentsOfRelativePower,
    "subset induced pcgs modulo tail-pcgs", true,
    [ IsModuloPcgs and IsModuloTailPcgsRep
      and IsNumeratorParentForExponentsRep, IsPosInt ], 0,
function( pcgs, ind )
  return ExponentsOfRelativePower(ParentPcgs(pcgs!.numeratorParent),
    pcgs!.depthsInParent[ind]) # depth of the element in the parent
                                {pcgs!.depthsInParent};
end );

#############################################################################
##
#M  ExponentsOfConjugate( <subset-induced,modulo-tail-pcgs>, <> )
##
InstallOtherMethod( ExponentsOfConjugate,
    "subset induced pcgs modulo tail-pcgs", true,
    [ IsModuloPcgs and IsModuloTailPcgsRep
      and IsNumeratorParentForExponentsRep, IsPosInt,IsPosInt ], 0,
function( pcgs, i,j )
  return ExponentsOfConjugate(ParentPcgs(pcgs!.numeratorParent),
    pcgs!.depthsInParent[i], # depth of the element in the parent
    pcgs!.depthsInParent[j]) # depth of the element in the parent
                                {pcgs!.depthsInParent};
end );

#############################################################################
##
#M  ExponentsConjugateLayer( <mpcgs>,<elm>,<e> )
##
InstallMethod( ExponentsConjugateLayer,"default: compute brute force",
  IsCollsElmsElms,[IsModuloPcgs,IsMultiplicativeElementWithInverse,
                   IsMultiplicativeElementWithInverse],0,
function(m,elm,e)
  return ExponentsOfPcElement(m,elm^e);
end);


#############################################################################
##
#M  PcGroupWithPcgs( <modulo-pcgs> )
##
InstallMethod( PcGroupWithPcgs, "pcgs modulo pcgs", true, [ IsModuloPcgs ], 0,

function( pcgs )

    # the following only works for finite orders
    if not IsFiniteOrdersPcgs(pcgs)  then
        TryNextMethod();
    fi;
    return GROUP_BY_PCGS_FINITE_ORDERS(pcgs);

end );


#############################################################################
##
#M  GroupOfPcgs( <modulo-pcgs> )
##
InstallOtherMethod( GroupOfPcgs, true, [ IsModuloPcgs ], 0,
function( pcgs )
  return GroupOfPcgs( NumeratorOfModuloPcgs( pcgs ) );
end );

#############################################################################
##
#M  NumeratorOfModuloPcgs( <modolo-tail-pcgs-by-list-rep> )
##
InstallMethod( NumeratorOfModuloPcgs,
    "modolo-tail-pcgs-by-list-rep", true,
    [ IsModuloPcgs and IsModuloTailPcgsByListRep],0,
function( mpcgs )
local home;
  home:=mpcgs!.numeratorParent;
  return InducedPcgsByPcSequenceNC(home,
           Concatenation(mpcgs!.pcSequence,home{mpcgs!.moduloDepths}));
end );

#############################################################################
##
#M  DenominatorOfModuloPcgs( <modolo-tail-pcgs-by-list-rep> )
##
InstallMethod( DenominatorOfModuloPcgs,
    "modolo-tail-pcgs-by-list-rep", true,
    [ IsModuloPcgs and IsModuloTailPcgsByListRep],0,
function( mpcgs )
local home;
  home:=mpcgs!.numeratorParent;
  return InducedPcgsByPcSequenceNC(home,home{mpcgs!.moduloDepths});
end );

#############################################################################
##
#M  NumeratorOfModuloPcgs( <pcgs> )
##
InstallMethod(NumeratorOfModuloPcgs,"for pcgs",true,[IsPcgs],0,
function(pcgs)
  if IsModuloPcgs(pcgs) and not IsPcgs(pcgs) then
    TryNextMethod();
  fi;
  return pcgs;
end);


#############################################################################
##
#M  DenominatorOfModuloPcgs( <pcgs> )
##
InstallMethod(DenominatorOfModuloPcgs,"for pcgs",true,[IsPcgs],0,
function(pcgs)
  if IsModuloPcgs(pcgs) and not IsPcgs(pcgs) then
    TryNextMethod();
  fi;
  return InducedPcgsByGeneratorsNC(pcgs,[]);
end);



#############################################################################
##
#M  ModuloPcgs( <G>,<H> )
##
InstallMethod(ModuloPcgs,"for groups",IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,H)
local home;
  home:=HomePcgs(G);
  G:=InducedPcgs(home,G);
  return G mod InducedPcgs(home,H);
end);

#############################################################################
##

#E  pcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##