#############################################################################
##
#W  grpfp.gi                    GAP library                    Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for finitely presented groups (fp groups).
##  Methods for subgroups of fp groups can also be found in `sgpres.gi'.
##
##  1. methods for elements of f.p. groups
##  2. methods for f.p. groups
##
Revision.grpfp_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. methods for elements of f.p. groups
##

#############################################################################
##
#M  ElementOfFpGroup( <fam>, <elm> )
##
InstallMethod( ElementOfFpGroup,
    "for a family of f.p. group elements, and an assoc. word",
    true,
    [ IsElementOfFpGroupFamily, IsAssocWordWithInverse ],
    0,
    function( fam, elm )
    return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
    end );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . . . . for packed word in default representation
##
InstallMethod( PrintObj,
    "for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedElementDefaultRep ],
    0,
    function( obj )
    Print( obj![1] );
    end );


#############################################################################
##
#M  UnderlyingElement( <elm> )  . . . . . . . . . . for element of f.p. group
##
InstallMethod( UnderlyingElement,
    "for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedElementDefaultRep ],
    0,
    obj -> obj![1] );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( ExtRepOfObj,
    "for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedElementDefaultRep ],
    0,
    obj -> ExtRepOfObj( obj![1] ) );


#############################################################################
##
#M  InverseOp( <elm> )  . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( InverseOp,
    "for an element of an f.p. group",
    true,
    [ IsElementOfFpGroup ],
    0,
    obj -> ElementOfFpGroup( FamilyObj( obj ),
                             Inverse( UnderlyingElement( obj ) ) ) );


#############################################################################
##
#M  One( <fam> )  . . . . . . . . . . . . . for family of f.p. group elements
##
InstallOtherMethod( One,
    "for a family of f.p. group elements",
    true,
    [ IsElementOfFpGroupFamily ],
    0,
    fam -> ElementOfFpGroup( fam, One( fam!.freeGroup ) ) );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( One, "for an f.p. group element", true, [ IsElementOfFpGroup ],
    0, obj -> One( FamilyObj( obj ) ) );

# a^0 calls OneOp, so we have to catch this as well.
InstallMethod( OneOp, "for an f.p. group element", true, [ IsElementOfFpGroup ],
    0, obj -> One( FamilyObj( obj ) ) );


#############################################################################
##
#M  \*( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \*,
    "for two f.p. group elements",
    IsIdenticalObj,
    [ IsElementOfFpGroup,
      IsElementOfFpGroup ],
    0,
    function( left, right )
    local fam;
    fam:= FamilyObj( left );
    return ElementOfFpGroup( fam,
               UnderlyingElement( left ) * UnderlyingElement( right ) );
    end );


#############################################################################
##
#M  \=( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \=, "for two f.p. group elements", IsIdenticalObj,
    [ IsElementOfFpGroup, IsElementOfFpGroup ], 0,
function( left, right )
local hom;
  if UnderlyingElement(left)=UnderlyingElement(right) then
    return true;
  fi;
  hom:=IsomorphismPermGroup(FamilyObj(left));
  return Image(hom,left)=Image(hom,right);
end );

#############################################################################
##
#M  \<( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \<, "for two f.p. group elements", IsIdenticalObj,
    [ IsElementOfFpGroup, IsElementOfFpGroup ],0,
# this is the only method that may ever be called!
function( left, right )
  return FpElmComparisonMethod(FamilyObj(left))(left,right);
end );

InstallMethod( FpElmComparisonMethod, "via perm rep.", true,
  [IsElementOfFpGroupFamily],0,
function( fam )
local hom;
  hom:=IsomorphismPermGroup(fam);
  return function(left,right);
	   return Image(hom,left)<Image(hom,right);
	 end;
end );

#############################################################################
##
##  2. methods for f.p. groups
##

#############################################################################
##
#M  SubgroupOfWholeGroupByCosetTable(<fpfam>,<tab>)
##
InstallGlobalFunction(SubgroupOfWholeGroupByCosetTable,function(fam,tab)
local S;
  S := Objectify(NewType(fam,IsGroup and IsAttributeStoringRep ),
        rec() ); 
  SetParent(S,fam!.wholeGroup);
  SetCosetTableInWholeGroup(S,tab);
  SetIndexInWholeGroup(S,Length(tab[1]));
  return S;
end);

#############################################################################
##
#M  SubgroupOfWholeGroupByQuotientSubgroup(<fpfam>,<Q>,<U>)
##
InstallGlobalFunction(SubgroupOfWholeGroupByQuotientSubgroup,function(fam,Q,U)
local S;
#  if (IsPermGroup(Q) or IsPcGroup(Q)) and Index(Q,U)=1 then
#    # we get the full group
#    S:=fam!.wholeGroup;
#    if not IsBound(S!.quot) then # in case some algorithm wants it
#      S!.quot:=GroupWithGenerators(List(GeneratorsOfGroup(S),i->()));
#      S!.sub:=S!.quot;
#    fi;
#    return S;
#  fi;

  S := Objectify(NewType(fam, IsGroup and
    IsSubgroupOfWholeGroupByQuotientRep and IsAttributeStoringRep ),
        rec(quot:=Q,sub:=U) ); 
  SetParent(S,fam!.wholeGroup);
  if CanComputeIndex(Q,U) then
    SetIndexInWholeGroup(S,Index(Q,U));
  fi;
  # transfer normality information
  if (HasIsNormalInParent(U) and Q=Parent(U)) or
    (HasGeneratorsOfGroup(U) and Length(GeneratorsOfGroup(U))=0) or
    (CanComputeSize(U) and Size(U)=1) then
      SetIsNormalInParent(S,true);
  fi;
  return S;
end);


#############################################################################
##
#M  \in ( <elm>, <U> )  in subgroup of fp group
##
InstallMethod( \in, "subgroup of fp group", IsElmsColls,
  [ IsElementOfFpGroup, IsSubgroupFpGroup ], 0,
function(elm,U)
local t,i,j,p,e,pos;
  t:=CosetTableInWholeGroup(U);
  elm:=UnderlyingElement(elm);

  p:=1;
  for i in [1..NumberSyllables(elm)] do
    e:=ExponentSyllable(elm,i);
    if e<0 then
      pos:=2*GeneratorSyllable(elm,i);
      e:=-e;
    else
      pos:=2*GeneratorSyllable(elm,i)-1;
    fi;
    for j in [1..e] do
      p:=t[pos][p];
    od;
  od;
  return p=1;
end);

InstallMethod( \in, "subgroup of fp group by quotient rep", IsElmsColls,
  [ IsElementOfFpGroup, 
    IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(elm,U)
  # transfer elm in factor
  elm:=UnderlyingElement(elm);
  elm:=MappedWord(elm,FreeGeneratorsOfWholeGroup(U),
                  GeneratorsOfGroup(U!.quot));

  return elm in U!.sub;
end);


#############################################################################
##
#M  \=( <U>, <V> )  . . . . . . . . .  for two subgroups of a f.p. group
##
InstallMethod( \=, "subgroups of fp group", IsIdenticalObj,
    [ IsSubgroupFpGroup, IsSubgroupFpGroup ], 0,
function( left, right )
  return IndexInWholeGroup(left)=IndexInWholeGroup(right)
         and IsSubset(left,right) and IsSubset(right,left);
end );

#############################################################################
##
#M  IsSubset( <U>, <V> )  . . . . . . . . .  for two subgroups of a f.p. group
##
InstallMethod( IsSubset, "subgroups of fp group: test generators",
  IsIdenticalObj,
  [ IsSubgroupFpGroup, # don't use the `CanEasilyTestMembership' filter here
                       # as the generator list may be empty.
    IsSubgroupFpGroup and HasGeneratorsOfGroup], 0,
function(left,right)
  if Length(GeneratorsOfGroup(right))>0 
    and not CanEasilyTestMembership(left) then
    TryNextMethod();
  fi;
  return ForAll(GeneratorsOfGroup(right),i->i in left);
end);

InstallMethod(IsSubset,"subgroups of fp group by quot. rep",IsIdenticalObj,
    [ IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep,
      IsSubgroupFpGroup  and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(G,H)
local A,B,U,V,W,E,F,map;
  # trivial plausibility
  if HasIndexInWholeGroup(G) and HasIndexInWholeGroup(H) and 
      IndexInWholeGroup(G)>IndexInWholeGroup(H) then
    return false;
  fi;

  A:=G!.quot;
  B:=H!.quot;
  U:=G!.sub;
  V:=H!.sub;
  # are we represented in the same quotient?
  if GeneratorsOfGroup(A)=GeneratorsOfGroup(B) then
    # we are, compare simply in the quotient
    return IsSubset(U,V);
  fi;

  # now we have to test ``subsetness'' in the subdirect product defined by
  # the quotients. WLOG the whole group is this subdirect product S
  #   A  |   |S  | B      Let E<A and F<B be the normal subgroups
  #      |   |   |        whose factors are glued together. We have
  #  E 	/   / \   \  F    E=(ker(S->B))->A
  #    /   /   \   \      F=(ker(S->A))->B
  #	   \   /
  #	    \ /
  #  Then G>H if and only if the following two conditions hold:
  #  1) The image of G in B contains V.
  #  2) G contains ker(S->B) (so with 1 it is sufficient, this is trivially
  #     neccessary as H contains this kernel).
  #     This condition is fulfilled, if U>E

  #  To compute this, first note that F is generated (as normal subgroup) by
  #  the relators of A evaluated in the generators of B. This is the
  #  coKernel of a mapping A->B
  if not IsTrivial(V) then
    map:=GroupGeneralMappingByImages(A,B,GeneratorsOfGroup(A),
					GeneratorsOfGroup(B));
    F:=CoKernelOfMultiplicativeGeneralMapping(map);
    W:=ClosureGroup(F,
                    List(GeneratorsOfGroup(U),i->ImagesRepresentative(map,i)));
    if not IsSubset(W,V) then
      return false; # condition 1
    fi;
  fi;

  map:=GroupGeneralMappingByImages(B,A,GeneratorsOfGroup(B),
                                       GeneratorsOfGroup(A));
  E:=CoKernelOfMultiplicativeGeneralMapping(map);
  return IsSubset(U,E);
end);

InstallMethod( IsSubset, "subgp fp group: via quotient rep", IsIdenticalObj,
  [ IsSubgroupFpGroup, IsSubgroupFpGroup ], 0,
function(left,right)
  return IsSubset(AsSubgroupOfWholeGroupByQuotient(left),
                  AsSubgroupOfWholeGroupByQuotient(right));
end);

InstallMethod( CanComputeIsSubset, "whole fp family group", IsIdenticalObj,
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup ], 0,
function(left,right)
  return true;
end);

InstallMethod(IsNormalOp,"subgroups of fp group by quot. rep in full fp grp.",
  IsIdenticalObj, [ IsSubgroupFpGroup and IsWholeFamily,
      IsSubgroupFpGroup  and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(G,H)
  return IsNormal(H!.quot,H!.sub);
end);

#############################################################################
##
#M  GeneratorsOfGroup( <F> )  . . . . . . . . . . . . . . .  for a f.p. group
##
InstallMethod( GeneratorsOfGroup,
    "for whole family f.p. group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,
    function( F )
    local Fam;
    Fam:= ElementsFamily( FamilyObj( F ) );
    return List( FreeGeneratorsOfFpGroup( F ),
                 g -> ElementOfFpGroup( Fam, g ) );
    end );


#############################################################################
##
#M  AbelianInvariants( <G> ) . . . . . . . . . . . . . . . . . for a fp group
##
InstallMethod( AbelianInvariants,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   Fam,        # elements family of <G>
            mat,        # relator matrix of <G>
            gens,       # generators of free group
            row,        # a row of <mat>
            rel,        # a relator of <G>
            g,          # a letter of <rel>
            p,          # position of <g> or its inverse in <gens>
            i;          # loop variable

    Fam := ElementsFamily( FamilyObj( G ) );
    gens := FreeGeneratorsOfFpGroup( G );

    # handle groups with no relators
    if IsEmpty( RelatorsOfFpGroup( G ) ) then
        return [ 1 .. Length( gens ) ] * 0;
    fi;

    # make the relator matrix
    mat := [];
    for rel  in RelatorsOfFpGroup( G ) do
        row := [];
        for i  in [ 1 .. Length( gens ) ]  do
            row[i] := 0;
        od;
        for i  in [ 1 .. Length( rel ) ]  do
            g := Subword( rel, i, i );
            p := Position( gens, g );
            if p <> fail  then
                row[p] := row[p] + 1;
            else
                p := Position( gens, g^-1 );
                row[p] := row[p] - 1;
            fi;
        od;
        Add( mat, row );
    od;

    # diagonalize the matrix
    DiagonalizeMat( Integers, mat );

    # return the abelian invariants
    return AbelianInvariantsOfList( DiagonalOfMat( mat ) );
end );


#############################################################################
##
#M  AbelianInvariants( <H> ) . . . . . . . . . . for a subgroup of a fp group
##
InstallMethod( AbelianInvariants,
  "for a subgroup of a finitely presented group", true,
  [ IsSubgroupFpGroup ], 0,
function( H )

    local G;

    if IsGroupOfFamily( H ) then
      TryNextMethod();
    fi;

    # Get the whole group `G' of `H'.
    G:= FamilyObj( H )!.wholeGroup;

    # Call the global function for subgroups of f.p. groups.
    return AbelianInvariantsSubgroupFpGroup( G, H );
end );

#############################################################################
##
#M  IsPerfectGroup( <H> )
##
InstallMethod( IsPerfectGroup,
  "for a (subgroup of a) finitely presented group", true,
  [ IsSubgroupFpGroup ], 0,
# for fp groups `AbelianInvariants' works.
    G -> IsEmpty( AbelianInvariants( G ) ) );

#############################################################################
##
#M  DerivedSubgroup( <G> ) . . . . . . . . . . . . . . . . . for a fp group
##
InstallMethod( DerivedSubgroup, "for a finitely presented group", true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
function(G)
local hom,u;
  hom:=MaximalAbelianQuotient(G);
  if Size(Range(hom))=1 then
    return G; # this is needed because the trivial quotient is represented
              # as fp group on no generators
  fi;
  u:=PreImage(hom,TrivialSubgroup(Range(hom)));
  SetIndexInWholeGroup(u,Size(Range(hom)));
  return u;
end);

InstallMethod( DerivedSubgroup, "subgroup of a finitely presented group", true,
    [ IsSubgroupFpGroup ], 0,
function(G)
local iso,hom,u;
  iso:=IsomorphismFpGroup(G);
  hom:=MaximalAbelianQuotient(Range(iso));
  if Size(Range(hom))=1 then
    return G; # this is needed because the trivial quotient is represented
              # as fp group on no generators
  fi;
  hom:=CompositionMapping(hom,iso);
  u:=PreImage(hom,TrivialSubgroup(Range(hom)));
  if HasIndexInWholeGroup(G) then
    SetIndexInWholeGroup(u,IndexInWholeGroup(G)*Size(Range(hom)));
  fi;
  return u;
end);

# The following two methods have been superseded - Derived Subgroup now
# works properly.
# #############################################################################
# ##
# #M  CommutatorFactorGroup( <G> )  . . . . . . . . . . . . .  for a f.p. group
# ##
# InstallMethod( CommutatorFactorGroup,
#     "for a finitely presented group",
#     true,
#     [ IsSubgroupFpGroup and IsGroupOfFamily ],
#     0,
# 
# function( G )
#     local   C,          # commutator factor group of <G>, result
#             F,          # associated free group
#             gens,       # generators of <F>
#             grels,      # relators of <G>
#             rels,       # relators of <C>
#             g, h,       # two generators of <F>
#             i, k;       # loop variables
# 
#     # get the arguments
#     F     := FreeGroupOfFpGroup( G );
#     gens  := GeneratorsOfGroup( F );
#     grels := RelatorsOfFpGroup( G );
# 
#     # copy the relators of <G> and add the commutator relators
#     rels := ShallowCopy( grels );
#     for i in [ 1 .. Length( gens ) - 1 ] do
#         g := gens[i];
#         for k in [ i + 1 .. Length( gens ) ] do
#             h := gens[k];
#             if not ( Comm( g, h ) in rels or Comm( h, g ) in rels ) then
#                 Add( rels, Comm( g, h ) );
#             fi;
#         od;
#     od;
# 
#     # make the commutator factor group and return it
#     C := F / rels;
#     SetIsCommutative( C, true );
#     return C;
# 
# end );
# 
# 
# #############################################################################
# ##
# #M  CommutatorFactorGroup( <G> ) . . . . . . . . for a subgroup of a fp group
# ##
# InstallMethod( CommutatorFactorGroup,
#     "for a subgroup of a finitely presented group",
#     true,
#     [ IsSubgroupFpGroup ],
#     0,
#     function( H )
# 
#     local G;
# 
#     if IsGroupOfFamily( H ) then
#       TryNextMethod();
#     fi;
# 
#     # Get the whole group `G' of `H'.
#     G:= FamilyObj( H )!.wholeGroup;
# 
#     # Delegate to the method for the whole f.p. group.
#     return CommutatorFactorGroup(
#         FpGroupPresentation( PresentationSubgroup( G, H ) ) );
# #T better compute the abelian invariants and then call `AbelianGroup'?
#     end );


#############################################################################
##
#M  CosetTable( <G>, <H> )  . . . . coset table of a finitely presented group
##
InstallMethod( CosetTable,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily, IsSubgroupFpGroup ],
    0,

function( G, H );

    if G <> FamilyObj( H )!.wholeGroup then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    return CosetTableInWholeGroup( H );

end );


#############################################################################
##
#M  CosetTableFromGensAndRels( <fgens>, <grels>, <fsgens> ) . . . . . . . . .
#M                                                     do a coset enumeration
##
##  'CosetTableFromGensAndRels'  is the working horse  for computing  a coset
##  table of H in G where G is a finitley presented group, H is a subgroup of
##  G,  and  G  is the whole group of  H.  It applies a Felsch strategy Todd-
##  Coxeter coset enumeration. The expected parameters are
##
##  \beginitems
##    fgens  & generators of the free group F associated to G,
##
##    grels  & relators of G,
##
##    fsgens & preimages of the subgroup generators of H in F.
##  \enditems
##
##  `CosetTableFromGensAndRels' processes two options (see
##  chapter~"Options"): 
##  \beginitems
##    `max' & The limit of the number of cosets to be defined. If the
##    enumeration does not finish with this number of cosets, an error is
##    raised and the user is asked whether she wants to continue
##
##    `silent'  & if set to `true' the algorithm will not rais the error
##    mentioned under option `max' but silently return `fail'. This can be
##    useful if an enumeration is only wanted unless it becomes too big.
##  \enditems
InstallGlobalFunction( CosetTableFromGensAndRels,
function ( fgens, grels, fsgens )
  Info( InfoFpGroup, 1, "CosetTableFromGensAndRels called:" );
  # catch trivial subgroup generators
  if ForAny(fsgens,i->Length(i)=0) then
    fsgens:=Filtered(fsgens,i->Length(i)>0);
  fi;
  # call the TC plugin
  return TCENUM.CosetTableFromGensAndRels(fgens,grels,fsgens);
end);

# The library version.
# Do *NOT* change the interface!
GAPTCENUM.CosetTableFromGensAndRels := function ( fgens, grels, fsgens )
    local   next,  prev,            # next and previous coset on lists
            firstFree,  lastFree,   # first and last free coset
            firstDef,   lastDef,    # first and last defined coset
            table,                  # columns in the table for gens
            rels,                   # representatives of the relators
            relsGen,                # relators sorted by start generator
            subgroup,               # rows for the subgroup gens
            deductions,             # deduction queue
            i, gen, inv,            # loop variables for generator
            g,                      # loop variable for generator col
            rel,                    # loop variables for relation
            p, p1, p2,              # generator position numbers
            app,                    # arguments list for 'MakeConsequences'
            limit,                  # limit of the table
            maxlimit,               # maximal size of the table
            j,                      # integer variable
            length, length2,        # length of relator (times 2)
            cols,
            nums,
            l,
            nrdef,                  # number of defined cosets
            nrmax,                  # maximal value of the above
            nrdel,                  # number of deleted cosets
            nrinf,                  # number for next information message
	    silent;		    # do we want the algorithm to silently
	                            # return `fail' if the algorithm did not
				    # finish in the permitted size?

    # give some information
    Info( InfoFpGroup, 2, "    defined deleted alive   maximal");
    nrdef := 1;
    nrmax := 1;
    nrdel := 0;
    nrinf := 1000;

    # initialize size of the table
    limit    := CosetTableDefaultLimit;
    maxlimit:=ValueOption("max");
    if maxlimit=fail or not IsInt(maxlimit) then
      maxlimit := CosetTableDefaultMaxLimit;
    fi;

    silent:=ValueOption("silent")=true;

    # define one coset (1)
    firstDef  := 1;  lastDef  := 1;
    firstFree := 2;  lastFree := limit;

    # make the lists that link together all the cosets
    next := [ 2 .. limit + 1 ];  next[1] := 0;  next[limit] := 0;
    prev := [ 0 .. limit - 1 ];  prev[2] := 0;

    # compute the representatives for the relators
    rels := RelatorRepresentatives( grels );

    # make the columns for the generators
    table := [];
    for gen  in fgens  do
        g := ListWithIdenticalEntries( limit, 0 );
        Add( table, g );
        if not ( gen^2 in rels or gen^-2 in rels ) then
            g := ListWithIdenticalEntries( limit, 0 );
        fi;
        Add( table, g );
    od;

    # make the rows for the relators and distribute over relsGen
    relsGen := RelsSortedByStartGen( fgens, rels, table, true );

    # make the rows for the subgroup generators
    subgroup := [];
    for rel  in fsgens  do
        length := Length( rel );
        length2 := 2 * length;
        nums := [ ]; nums[length2] := 0;
        cols := [ ]; cols[length2] := 0;

        # compute the lists.
        i := 0;  j := 0;
        while i < length do
            i := i + 1;  j := j + 2;
            gen := Subword( rel, i, i );
            p := Position( fgens, gen );
            if p = fail then
                p := Position( fgens, gen^-1 );
                p1 := 2 * p;
                p2 := 2 * p - 1;
            else
                p1 := 2 * p - 1;
                p2 := 2 * p;
            fi;
            nums[j]   := p1;  cols[j]   := table[p1];
            nums[j-1] := p2;  cols[j-1] := table[p2];
        od;
        Add( subgroup, [ nums, cols ] );
    od;

    # add an empty deduction list
    deductions := [];

    # make the structure that is passed to 'MakeConsequences'
    app := [ table, next, prev, relsGen, subgroup ];

    # we do not want minimal gaps to be marked in the coset table
    app[12] := 0;

    # run over all the cosets
    while firstDef <> 0  do

        # run through all the rows and look for undefined entries
        for i  in [ 1 .. Length( table ) ]  do
            gen := table[i];

            if gen[firstDef] <= 0  then

                inv := table[i + 2*(i mod 2) - 1];

                # if necessary expand the table
                if firstFree = 0  then
                    if 0 < maxlimit and  maxlimit <= limit  then
			if silent then
			  return fail;
			fi;
                        maxlimit := Maximum(maxlimit*2,limit*2);
                        Error( "the coset enumeration has defined more ",
                               "than ", limit, " cosets:\ntype 'return;' ",
                               "if you want to continue with a new limit ",
                               "of ", maxlimit, " cosets,\ntype 'quit;' ",
                               "if you want to quit the coset ",
                               "enumeration,\ntype 'maxlimit := 0; return;'",
                               " in order to continue without a limit,\n" );
                    fi;
                    next[2*limit] := 0;
                    prev[2*limit] := 2*limit-1;
                    for g  in table  do g[2*limit] := 0;  od;
                    for l  in [ limit+2 .. 2*limit-1 ]  do
                        next[l] := l+1;
                        prev[l] := l-1;
                        for g  in table  do g[l] := 0;  od;
                    od;
                    next[limit+1] := limit+2;
                    prev[limit+1] := 0;
                    for g  in table  do g[limit+1] := 0;  od;
                    firstFree := limit+1;
                    limit := 2*limit;
                    lastFree := limit;
                fi;

                # update the debugging information
                nrdef := nrdef + 1;
                if nrmax <= firstFree  then
                    nrmax := firstFree;
                fi;

                # define a new coset
                gen[firstDef]   := firstFree;
                inv[firstFree]  := firstDef;
                next[lastDef]   := firstFree;
                prev[firstFree] := lastDef;
                lastDef         := firstFree;
                firstFree       := next[firstFree];
                next[lastDef]   := 0;

                # set up the deduction queue and run over it until it's empty
                app[6] := firstFree;
                app[7] := lastFree;
                app[8] := firstDef;
                app[9] := lastDef;
                app[10] := i;
                app[11] := firstDef;
                nrdel := nrdel + MakeConsequences( app );
                firstFree := app[6];
                lastFree := app[7];
                firstDef := app[8];
                lastDef  := app[9];

                # give some information
                while nrinf <= nrdef+nrdel  do
                    Info( InfoFpGroup, 2, "\t", nrdef, "\t", nrinf-nrdef,
                          "\t", 2*nrdef-nrinf, "\t", nrmax );
                    nrinf := nrinf + 1000;
                od;

            fi;
        od;

        firstDef := next[firstDef];
    od;

    Info( InfoFpGroup, 1, "\t", nrdef, "\t", nrdel, "\t", nrdef-nrdel, "\t",
          nrmax );

    # separate pairs of identical table columns.                  
    for i in [ 1 .. Length( fgens ) ] do                             
        if IsIdenticalObj( table[2*i-1], table[2*i] ) then
            table[2*i] := StructuralCopy( table[2*i-1] );       
        fi;                                                                
    od;

    # standardize the table
    StandardizeTable( table );

    # return the table
    return table;
end;


#############################################################################
##
#M  CosetTableInWholeGroup( <H> )  . . . . . .  coset table of an fp subgroup
#M                                                         in its whole group
##
##  is equivalent to `CosetTable( <G>, <H> )' where <G> is the (unique)
##  finitely presented group such that <H> is a subgroup of <G>.
##
InstallMethod( TryCosetTableInWholeGroup,"for finitely presented groups",
    true, [ IsSubgroupFpGroup ], 0,
function( H )
    local   G,          # whole group of <H>
            fgens,      # generators of the free group F asscociated to G
            grels,      # relators of G
            sgens,      # subgroup generators of H
            fsgens,     # preimages of subgroup generators in F
            T;          # coset table

    # do we know it already?
    if HasCosetTableInWholeGroup(H) then
      return CosetTableInWholeGroup(H);
    fi;

    # Get whole group <G> of <H>.
    G := FamilyObj( H )!.wholeGroup;

    # get some variables
    fgens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    sgens := GeneratorsOfGroup( H );
    fsgens := List( sgens, gen -> UnderlyingElement( gen ) );

    # Construct the coset table of <G> by <H>.
    T := CosetTableFromGensAndRels( fgens, grels, fsgens );

    if T<>fail then
      SetCosetTableInWholeGroup(H,T);
    fi;
    return T;

end );

InstallMethod( CosetTableInWholeGroup,"for finitely presented groups",
    true, [ IsSubgroupFpGroup ], 0,
function( H )
  # don't get trapped by a `silent' option lingering around.
  return TryCosetTableInWholeGroup(H:silent:=false);
end );

InstallMethod(CosetTableInWholeGroup,"ByQuoSubRep",true,
  [IsSubgroupOfWholeGroupByQuotientRep],0,
function(G)
  # construct coset table
  return CosetTableBySubgroup(G!.quot,G!.sub);
end);


#############################################################################
##
#M  Display( <G> ) . . . . . . . . . . . . . . . . . . .  display an fp group
##
InstallMethod( Display,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   gens,       # generators o the free group
            rels,       # relators of <G>
            nrels,      # number of relators
            i;          # loop variable

    gens := FreeGeneratorsOfFpGroup( G );
    rels := RelatorsOfFpGroup( G );
    Print( "generators = ", gens, "\n" );
    nrels := Length( rels );
    Print( "relators = [" );
    if nrels > 0 then
        Print( "\n ", rels[1] );
        for i in [ 2 .. nrels ] do
            Print( ",\n ", rels[i] );
        od;
    fi;
    Print( " ]\n" );
end );


#############################################################################
##
#F  FactorGroupFpGroupByRels( <G>, <elts> )
##
##  Returns the factor group G/N of G by the normal closure N of <elts> where
##  <elts> is expected to be a list of elements of G.
##
InstallGlobalFunction( FactorGroupFpGroupByRels,
function( G, elts )
    local   F,          # free group associated to G and to G/N
            grels,      # relators of G
            words,      # representative words in F for the elements in elts
            rels;       # relators of G/N

    # get some local variables
    F     := FreeGroupOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    words := List( elts, g -> UnderlyingElement( g ) );

    # get relators for G/N
    rels := Concatenation( grels, words );

    # return the resulting factor group G/N
    return F / rels;
end );


#############################################################################
##
#M  FactorFreeGroupByRelators(<F>,<rels>) .  factor of free group by relators
##
BindGlobal( "FactorFreeGroupByRelators", function( F, rels )
    local G, fam, gens;

    # Create a new family.
    fam := NewFamily( "FamilyElementsFpGroup", IsElementOfFpGroup );

    # Create the default type for the elements.
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

    fam!.freeGroup := F;
    fam!.relators := Immutable( rels );

    # Create the group.
    G := Objectify(
        NewType( CollectionsFamily( fam ),
            IsSubgroupFpGroup and IsWholeFamily and IsAttributeStoringRep ),
        rec() );

    # Mark <G> to be the 'whole group' of its later subgroups.
    FamilyObj( G )!.wholeGroup := G;
    SetFilterObj(G,IsGroupOfFamily);

    # Create generators of the group.
    gens:= List( GeneratorsOfGroup( F ), g -> ElementOfFpGroup( fam, g ) );
    SetGeneratorsOfGroup( G, gens );
    if IsEmpty( gens ) then
      SetOne( G, ElementOfFpGroup( fam, One( F ) ) );
    fi;

    return G;
end );


#############################################################################
##
#M  \/( <F>, <rels> ) . . . . . . . . . . for free group and list of relators
##
InstallOtherMethod( \/,
    "for free groups and relators",
    IsIdenticalObj,
    [ IsFreeGroup, IsCollection ],
    0,
    FactorFreeGroupByRelators );


#############################################################################
##
#M  \/( <F>, <rels> ) . . . . . . . for free group and empty list of relators
##
InstallOtherMethod( \/,
    "for a free group and an empty list of relators",
    true,
    [ IsFreeGroup, IsEmpty ],
    0,
    FactorFreeGroupByRelators );


#############################################################################
##
#M  FreeGeneratorsOfFpGroup( F )  . . generators of the underlying free group
##
InstallMethod( FreeGeneratorsOfFpGroup,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> GeneratorsOfGroup( FreeGroupOfFpGroup( G ) ) );

#############################################################################
##
#M  FreeGeneratorsOfWholeGroup( U )  . . generators of the underlying free group
##
InstallMethod( FreeGeneratorsOfWholeGroup,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup ], 0,
    G -> GeneratorsOfGroup( ElementsFamily(FamilyObj( G ))!.freeGroup ) );

#############################################################################
##
#M  FreeGroupOfFpGroup( F ) . . . . . .  underlying free group of an fp group
##
InstallMethod( FreeGroupOfFpGroup,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.freeGroup );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )
##
InstallMethod( ImagesRepresentative,
  "map from fp group or free group, use 'MappedWord'",
  FamSourceEqFamElm, [ IsFromFpGroupStdGensGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
  return MappedWord(elm,hom!.generators,hom!.genimages);
end);

InstallMethod( ImagesRepresentative,
  # this is not caught by the similar generic method: The elements might be
  # not identical.
  "simple tests on equal words", FamSourceEqFamElm,
  [ IsFromFpGroupGeneralMappingByImages and IsGroupGeneralMappingByImages,
    IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
local he,ue,p;
  ue:=UnderlyingElement(elm);
  if IsOne(ue) then
    return One(Range(hom));
  fi;
  he:=List(hom!.generators,UnderlyingElement);
  p:=Position(he,ue);
  if p<>fail then
    return hom!.genimages[p];
  fi;
  p:=Position(he,ue^-1);
  if p<>fail then
    return hom!.genimages[p]^-1;
  fi;
  TryNextMethod();
end);

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> )
##
InstallMethod( KernelOfMultiplicativeGeneralMapping, "GHBI from fp grp", true,
 [ IsFromFpGroupGeneralMappingByImages and IsGroupGeneralMappingByImages ], 0,
function(hom)
local k;
  #T Instead of using the CoKernel the function would better use a wreath
  #T product representation of the factor, using K+K. AH

  if IsGroupOfFamily(Source(hom)) then
    k:=PreImage(hom,TrivialSubgroup(Range(hom)));
  else
    k:=CoKernelOfMultiplicativeGeneralMapping( InverseGeneralMapping( hom ) );
  fi;


  if HasIsSurjective(hom) and IsSurjective( hom ) and 
     HasIndexInWholeGroup( Source(hom) ) 
     and HasRange(hom) # surjective action homomorphisms do not store
                       # the range by default
     and HasSize( Range( hom ) ) then
          SetIndexInWholeGroup( k, 
                 IndexInWholeGroup( Source(hom) ) * Size( Range(hom) ));
  fi;
  return k;
end);

InstallMethod( CoKernelOfMultiplicativeGeneralMapping, "GHBI from fp grp", true,
 [ IsFromFpGroupGeneralMappingByImages 
   and IsGroupGeneralMappingByImages ], 0,
function(map)
local so,fp,isofp,rels;
  # the mapping is on the std. generators. So we just have to evaluate the
  # relators in the generators on the genimages and take the normal closure.
  so:=Source(map);
  isofp:=IsomorphismFpGroupByGenerators(so,map!.generators);
  fp:=Range(isofp);
  rels:=RelatorsOfFpGroup(fp);
  rels:=List(rels,i->MappedWord(i,FreeGeneratorsOfFpGroup(fp),map!.genimages));
  return NormalClosure(Range(map),SubgroupNC(Range(map),rels));
end);

#############################################################################
##
#M  Index( <G>,<H> )
##
InstallMethod( IndexOp, "for finitely presented groups", true,
    [ IsSubgroupFpGroup, IsSubgroupFpGroup ], 0,
function(G,H)
  if not IsSubset(G,H) then
    Error("<H> must be a subset of <G>");
  fi;
  # catch a stupid case
  if IsIdenticalObj(G,H) then
    return 1;
  fi;
  return IndexInWholeGroup(H)/IndexInWholeGroup(G);
end);

InstallMethod( IndexOp, "for finitely presented group in whole group", true,
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup ], 0,
function(G,H)
  return IndexInWholeGroup(H);
end);

InstallMethod( CanComputeIndex,"subgroups fp groups",IsIdenticalObj,
  [IsGroup and HasIndexInWholeGroup,IsGroup and HasIndexInWholeGroup],
  0,ReturnTrue);

InstallMethod( CanComputeIndex,"subgroup of full fp groups",IsIdenticalObj,
  [IsGroup and IsWholeFamily,IsGroup and HasIndexInWholeGroup],
  0,ReturnTrue);

InstallMethod( CanComputeIndex,"subgroup of full fp groups",IsIdenticalObj,
  [IsGroup and IsWholeFamily,IsGroup and HasCosetTableInWholeGroup],
  0,ReturnTrue);


#############################################################################
##
#M  IndexInWholeGroup( <H> )  . . . . . .  index of a subgroup in an fp group
##
InstallMethod( IndexInWholeGroup, "for subgroups of fp groups", true,
    [ IsSubgroupFpGroup ], 0,
function( H )
local T;

    # Get the coset table of <H> in its whole group.
    T := CosetTableInWholeGroup( H );
    return Length( T[1] );
end );

InstallMethod( IndexInWholeGroup, "for full fp group",true,
    [ IsSubgroupFpGroup and IsWholeFamily ], 0, a->1);

#############################################################################
##
#M  GeneratorsOfGroup
##
InstallMethod(GeneratorsOfGroup,"subgroup of fp group, by coset table",
  true,[IsSubgroupFpGroup],0,
function(U)
local P,l,f;
  P:=FamilyObj(U)!.wholeGroup;
  f:=FreeGeneratorsOfFpGroup(P);
  l:=SubgroupGeneratorsCosetTable(f,RelatorsOfFpGroup(P),
       CosetTableInWholeGroup(U) );
  l:=List(l,i->MappedWord(i,f,GeneratorsOfGroup(P)));
  return l;
end);

#############################################################################
##
#M  ConjugateGroup(<U>,<g>)  U^g
##
InstallMethod(ConjugateGroup,"subgroups of fp group with coset table",
  IsCollsElms, [IsSubgroupFpGroup and HasCosetTableInWholeGroup,
	       IsMultiplicativeElementWithInverse],0,
function(U,g)
local V,t,w,wi,i,j,e,pos;
  t:=CosetTableInWholeGroup(U);
  if Length(t)<2 then
    return U; # the whole group
  fi;

  # the image of g in the permutation group
  w:=UnderlyingElement(g);
  wi:=[1..Length(t[1])];
  for i in [1..NumberSyllables(w)] do
    e:=ExponentSyllable(w,i);
    if e<0 then
      pos:=2*GeneratorSyllable(w,i);
      e:=-e;
    else
      pos:=2*GeneratorSyllable(w,i)-1;
    fi;
    for j in [1..e] do
      wi:=t[pos]{wi}; # multiply permutations
    od;
  od;
  w:=PermList(wi)^-1;
  t:=List(t,i->OnTuples(i{wi},w));
  StandardizeTable(t);
  V:=SubgroupOfWholeGroupByCosetTable(FamilyObj(U),t);

  if HasGeneratorsOfGroup(U) then
    SetGeneratorsOfGroup(V,List(GeneratorsOfGroup(U),i->i^g));
  fi;
  return V;
end);

InstallMethod(ConjugateGroup,"subgroups of fp group by quotient",
  IsCollsElms, [ IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep,
	       IsMultiplicativeElementWithInverse],0,
function(U,elm)
  # transfer elm in factor
  elm:=UnderlyingElement(elm);
  elm:=MappedWord(elm,FreeGeneratorsOfWholeGroup(U),
                  GeneratorsOfGroup(U!.quot));

  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),U!.quot,
    ConjugateGroup(U!.sub,elm));
end);

InstallMethod(AsSubgroupOfWholeGroupByQuotient,"create",true,
  [IsSubgroupFpGroup],0,
function(U)
local tab,Q,A;
  tab:=CosetTableInWholeGroup(U);
  Q:=GroupWithGenerators(List(tab{[1,3..Length(tab)-1]},PermList));
  #T: try to improve via blocks

  A:=Stabilizer(Q,1);
  U:=SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),Q,A);
  return U;
end);

InstallMethod(AsSubgroupOfWholeGroupByQuotient,"is already",true,
  [IsSubgroupOfWholeGroupByQuotientRep],0,x->x);

#############################################################################
##
#M  CoreOp(<U>,<V>)  . intersection of two fin. pres. groups
##
InstallMethod(CoreOp,"subgroups of fp group: use quotient rep",IsIdenticalObj,
  [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(V,U)
  return Core(V,AsSubgroupOfWholeGroupByQuotient(U));
end);

InstallMethod(CoreOp,"subgroups of fp group by quotient",IsIdenticalObj,
  [IsSubgroupFpGroup,
  IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep],0,
function(V,U)
local q,gens;
  # map the generators of V in the quotient
  gens:=GeneratorsOfGroup(V);
  gens:=List(gens,UnderlyingElement);
  q:=U!.quot;
  gens:=List(gens,i->MappedWord(i,FreeGeneratorsOfWholeGroup(U),
                                GeneratorsOfGroup(q)));
  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),q,
           Core(SubgroupNC(q,gens),U!.sub));
end);

#############################################################################
##
#M  Intersection2(<G>,<H>)  . intersection of two fin. pres. groups
##
InstallMethod(Intersection2,"subgroups of fp group",IsIdenticalObj,
  [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function ( G, H )
    local   
    	    Fam,	# group family
            rels,       # representatives for the relators
            table,      # coset table for <I> in its parent
            nrcos,      # number of cosets of <I>
            tableG,     # coset table of <G>
            nrcosG,     # number of cosets of <G>
            tableH,     # coset table of <H>
            nrcosH,     # number of cosets of <H>
	    pargens,	# generators of Parent(G)
	    freegens,	# free generators of Parent(G)
            nrgens,     # number of generators of the parent of <G> and <H>
            ren,        # if 'ren[<i>]' is 'nrcosH * <iG> + <iH>' then the
                        # coset <i> of <I> corresponds to the intersection
                        # of the pair of cosets <iG> of <G> and <iH> of <H>
            ner,        # the inverse mapping of 'ren'
            cos,        # coset loop variable
            gen,        # generator loop variable
            img;        # image of <cos> under <gen>

    Fam:=FamilyObj(G);
    # handle trivial cases
    if IsIdenticalObj(G,Fam!.wholeGroup) then
        return H;
    elif IsIdenticalObj(H,Fam!.wholeGroup) then
        return G;
    fi;

    tableG := CosetTableInWholeGroup(G);
    nrcosG := Length( tableG[1] ) + 1;
    tableH := CosetTableInWholeGroup(H);
    nrcosH := Length( tableH[1] ) + 1;

    if nrcosH<=nrcosG and HasGeneratorsOfGroup(G) then
      if ForAll(GeneratorsOfGroup(G),i->i in H) then
        return G;
      fi;
    elif nrcosG<=nrcosH and HasGeneratorsOfGroup(H) then
      if ForAll(GeneratorsOfGroup(H),i->i in G) then
        return H;
      fi;
    fi;

    pargens:=GeneratorsOfGroup(Fam!.wholeGroup);
    freegens:=FreeGeneratorsOfFpGroup(Fam!.wholeGroup);
    # initialize the table for the intersection
    rels := RelatorRepresentatives( RelatorsOfFpGroup( Fam!.wholeGroup ) );
    nrgens := Length(freegens);
    table := [];
    for gen  in [ 1 .. nrgens ]  do
        table[ 2*gen-1 ] := [];
	table[ 2*gen ] := [];
    od;

    # set up the renumbering
    ren := ListWithIdenticalEntries(nrcosG*nrcosH,0);
    ner := ListWithIdenticalEntries(nrcosG*nrcosH,0);
    ren[ 1*nrcosH + 1 ] := 1;
    ner[ 1 ] := 1*nrcosH + 1;
    nrcos := 1;

    # the coset table for the intersection is the transitive component of 1
    # in the *tensored* permutation representation
    cos := 1;
    while cos <= nrcos  do

        # loop over all entries in this row
        for gen  in [ 1 .. nrgens ]  do

            # get the coset pair
            img := nrcosH * tableG[ 2*gen-1 ][ QuoInt( ner[ cos ], nrcosH ) ]
                          + tableH[ 2*gen-1 ][ ner[ cos ] mod nrcosH ];

            # if this pair is new give it the next available coset number
            if ren[ img ] = 0  then
                nrcos := nrcos + 1;
                ren[ img ] := nrcos;
                ner[ nrcos ] := img;
            fi;

            # and enter it into the coset table
            table[ 2*gen-1 ][ cos ] := ren[ img ];
            table[ 2*gen   ][ ren[ img ] ] := cos;

        od;

        cos := cos + 1;
    od;

    return SubgroupOfWholeGroupByCosetTable(Fam,table);
end);

InstallMethod(Intersection2,"subgroups of fp group by quotient",IsIdenticalObj,
  [IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep,
   IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep],0,
function ( G, H )
local d,A,B,e1,e2,Ag,Bg,s,sg,u,v;
  A:=G!.quot;
  B:=H!.quot;
  d:=DirectProduct(A,B);
  e1:=Embedding(d,1);
  e2:=Embedding(d,2);
  Ag:=GeneratorsOfGroup(A);
  Bg:=GeneratorsOfGroup(B);
  # form the sdp
  sg:=List([1..Length(Ag)],i->Image(e1,Ag[i])*Image(e2,Bg[i]));
  s:=SubgroupNC(d,sg);
  Assert(1,GeneratorsOfGroup(s)=sg);

  # get both subgroups in the direct product via the projections
  # instead of intersecting both preimages with s we only intersect the
  # intersection
  u:=PreImagesSet(Projection(d,1),G!.sub);
  v:=PreImagesSet(Projection(d,2),H!.sub);
  u:=Intersection(u,v);
  u:=Intersection(u,s);

  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),s,u);
end);

#############################################################################
##
#M  ClosureGroup( <G>, <obj> )
##
InstallMethod( ClosureGroup, "subgrp fp: by quotient subgroup",IsCollsElms,
  [IsSubgroupFpGroup and HasParent and IsSubgroupOfWholeGroupByQuotientRep,
    IsMultiplicativeElementWithInverse ], 0,
function( U, elm )
local Q,V,hom;
  Q:=U!.quot;
  # transfer elm in factor
  elm:=UnderlyingElement(elm);
  elm:=MappedWord(elm,FreeGeneratorsOfWholeGroup(U),GeneratorsOfGroup(Q));
  if elm in U!.sub then
    return U; # no new group
  fi;

  V:=ClosureSubgroupNC(U!.sub,elm);
  # do we want to get a smaller representation?
  if IsPermGroup(Q) and Length(MovedPoints(Q))>2*Index(Q,V) then
    # we can improve the degree
    hom:=ActionHomomorphism(Q,RightTransversal(Q,V),OnRight);
    Q:=GroupWithGenerators(List(GeneratorsOfGroup(Q),i->Image(hom,i)));
    return 
      SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),Q,Stabilizer(Q,1));
  else
    # close
    return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),Q,V);
  fi;
end );

InstallMethod( ClosureGroup, "subgrp fp: Has coset table",IsCollsElms,
  [ IsSubgroupFpGroup and HasParent and HasCosetTableInWholeGroup,
    IsMultiplicativeElementWithInverse ], 0,
function( U, elm )
local tab,Q,es,eo,b;
  tab:=CosetTableInWholeGroup(U);
  tab:=List(tab{[1,3..Length(tab)-1]},PermList);
  Q:=GroupWithGenerators(tab);
  elm:=UnderlyingElement(elm);
  elm:=MappedWord(elm,FreeGeneratorsOfWholeGroup(U),tab);
  if 1^elm=1 then
    return U; # no new group
  fi;

  es:=SubgroupNC(Q,[elm]);
  # form a block system 
  eo:=Orbit(es,1); # block seed
  b:=[[1]]; # this is guaranteed to be overwritten at least once
  while not IsSubset(b[1],eo) do
    # fuse to new blocks
    b:=Blocks(Q,[1..IndexInWholeGroup(U)],eo);
    eo:=Union(List(b[1],i->Orbit(es,i))); # all orbits of elm on the new block
  od; # until the block does not grow any more under es.

  b:=ActionHomomorphism(Q,b,OnSets);
  tab:=List(tab,i->ImageElm(b,i));
  Q:=GroupWithGenerators(tab);
  return
    SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),Q,Stabilizer(Q,1));
  
end );


# override default because we want to close the larger group with the smaller
InstallMethod( ClosureGroup, "for subgroup of fp group, and subgroup",
  IsIdenticalObj,[IsSubgroupFpGroup and HasParent,IsSubgroupFpGroup ],0,
function( U, V )
  if IndexInWholeGroup(U)<IndexInWholeGroup(V) then
    return ClosureGroup(V,U);
  fi;
  return ClosureGroup(U,GeneratorsOfGroup(V));
end );


#############################################################################
##
#M  KnowsHowToDecompose(<G>,<gens>) 
##
InstallMethod( KnowsHowToDecompose,"fp groups: Say yes if finite index",
    IsIdenticalObj, [ IsSubgroupFpGroup, IsList ], 0,
function(G,l)
  # this will only practically hold if we have a rewriting function. Without
  # setting this already, however further temporary work would have to be
  # done for kernel methods to transfer the size of an image to the index of
  # the kernel of a surjection group homomorphism.
  return CanComputeIndex(FamilyObj(G)!.wholeGroup,G) 
         and IndexInWholeGroup(G)<infinity;
end);

#############################################################################
##
#M  IsAbelian( <G> )  . . . . . . . . . . . .  test if an fp group is abelian
##
InstallMethod( IsAbelian,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   isAbelian,  # result
            gens,       # generators of <G>
            fgens,      # generators of the associated free group
            rels,       # relators of <G>
            one,        # identity element of <G>
            g, h,       # two generators of <G>
            i, k;       # loop variables

    gens  := GeneratorsOfGroup( G );
    fgens := FreeGeneratorsOfFpGroup( G );
    rels  := RelatorsOfFpGroup( G );
    one   := One( G );
    isAbelian := true;
    for i  in [ 1 .. Length( gens ) - 1 ]  do
        g := fgens[i];
        for k  in [ i + 1 .. Length( fgens ) ]  do
            h := fgens[k];
            isAbelian := isAbelian and (
                           Comm( g, h ) in rels
                           or Comm( h, g ) in rels
                           or Comm( gens[i], gens[k] ) = one
                          );
        od;
    od;
    return isAbelian;

end );


#############################################################################
##
#M  IsSingleValued
##
InstallMethod( IsSingleValued,
  "map from fp group or free group, given on std. gens: test relators",
  true,
  [IsFromFpGroupStdGensGeneralMappingByImages],0,
function(hom)
local s,sg,o;
  s:=Source(hom);
  if IsFreeGroup(s) then
    return true;
  fi;
  sg:=FreeGeneratorsOfFpGroup(s);
  o:=One(Range(hom));
  return ForAll(RelatorsOfFpGroup(s),i->MappedWord(i,sg,hom!.genimages)=o);
end);


#############################################################################
##
#M  IsTrivial( <G> ) . . . . . . . . . . . . . . . . . test if <G> is trivial
##
InstallMethod( IsTrivial,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )

    if 0 = Length( GeneratorsOfGroup( G ) )  then
        return true;
    else
        return Size( G ) = 1;
    fi;

end );


#############################################################################
##
#M  IsomorphismFpGroup( G )
##
InstallMethod( IsomorphismFpGroup, "for perm groups", true, [IsPermGroup], 0,
function( G )
    return IsomorphismFpGroupByCompositionSeries( G, "F" );
end );

InstallOtherMethod( IsomorphismFpGroup, "for perm groups, name", true,
  [IsPermGroup,IsString], 0,
function( G,s )
    return IsomorphismFpGroupByCompositionSeries( G, s );
end );

InstallOtherMethod( IsomorphismFpGroup,"for simple permutation groups",true,
  [IsPermGroup and IsSimpleGroup,IsString],0,
function(G,str)
  return IsomorphismFpGroupByGenerators( G, SmallGeneratingSet(G), str );
end);


#############################################################################
##
#M  IsomorphismFpGroupByCompositionSeries( G, str )
##
InstallMethod( IsomorphismFpGroupByCompositionSeries,
               "for permutation groups", true,
               [IsPermGroup, IsString], 0,
function( G, str )
    local l, H, gensH, iso, F, gensF, imgsF, relatorsF, free, n, k, N, M,
          hom, preiH, c, new, T, gensT, E, gensE, imgsE, relatorsE, rel,
          w, t, i, j, series;

    # the solvable case
    if IsSolvableGroup( G ) then
        return IsomorphismFpGroupByPcgs( Pcgs(G), str );
    fi;

    # compute composition series
    series := CompositionSeries( G );
    l      := Length( series );

    # set up
    H := series[l-1];
    # if IsPrime( Size( H ) ) then
    #     gensH := Filtered( GeneratorsOfGroup( H ),
    #                        x -> Order(x)=Size(H) ){[1]};
    # else
    #     gensH := Set( GeneratorsOfGroup( H ) );
    #     gensH := Filtered( gensH, x -> x <> One(H) );
    # fi;

    IsSimpleGroup(H); #ensure H knows to be simple, thus the call to
    # `IsomorphismFpGroup' will not yield an infinite recursion.
    IsNaturalAlternatingGroup(H); # We have quite often a factor A_n for
    # which GAP knows better presentations. Thus this test is worth doing.
    iso := IsomorphismFpGroup( H,str );

    F := FreeGroupOfFpGroup( Image( iso ) );
    gensF := GeneratorsOfGroup( F );
    imgsF := iso!.generators;
    relatorsF := RelatorsOfFpGroup( Image( iso ) );
    free := GroupHomomorphismByImagesNC( F, series[l-1], gensF, imgsF );
    n := Length( gensF );

    # loop over series upwards
    for k in Reversed( [1..l-2] ) do

        # get composition factor
        N := series[k];
        M := series[k+1];
	# do not call `InParent'-- rather safe than sorry.
        hom := NaturalHomomorphismByNormalSubgroupNC(N, M );
        H := Image( hom );
        # if IsPrime( Size( H ) ) then
        #     gensH := Filtered( GeneratorsOfGroup( H ),
        #                        x -> Order(x)=Size(H) ){[1]};
        # else
        #     gensH := Set( GeneratorsOfGroup( H ) );
        #     gensH := Filtered( gensH, x -> x <> One(H) );
        # fi;

	# compute presentation of H
	IsSimpleGroup(H);
	IsNaturalAlternatingGroup(H);
	new:=IsomorphismFpGroup(H,"@");
	gensH:=List(GeneratorsOfGroup(Image(new)),
	              i->PreImagesRepresentative(new,i));
        preiH := List( gensH, x -> PreImagesRepresentative( hom, x ) );

        c     := Length( gensH );

        T   := Image( new );
        gensT := GeneratorsOfGroup( FreeGroupOfFpGroup( T ) );

        # create new free group
        E     := FreeGroup( n+c, str );
        gensE := GeneratorsOfGroup( E );
        imgsE := Concatenation( preiH, imgsF );
        relatorsE := [];

        # modify presentation of H
        for rel in RelatorsOfFpGroup( T ) do
            w := MappedWord( rel, gensT, gensE{[1..c]} );
            t := MappedWord( rel, gensT, imgsE{[1..c]} );
            if not t = One( G ) then
                t := PreImagesRepresentative( free, t );
                t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
            else
                t := One( E );
            fi;
            Add( relatorsE, w/t );
        od;

        # add operation of T on F
        for i in [1..c] do
            for j in [1..n] do
                w := Comm( gensE[c+j], gensE[i] );
                t := Comm( imgsE[c+j], imgsE[i] );
                if not t = One( G ) then
                    t := PreImagesRepresentative( free, t );
                    t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
                else
                    t := One( E );
                fi;
                Add( relatorsE, w/t );
            od;
        od;

        # append relators of F
        for rel in relatorsF do
            w := MappedWord( rel, gensF, gensE{[c+1..c+n]} );
            Add( relatorsE, w );
        od;

        # iterate
        F := E;
        gensF := gensE;
        imgsF := imgsE;
        relatorsF := relatorsE;
        free :=  GroupHomomorphismByImagesNC( F, N, gensF, imgsF );
        n := n + c;
    od;

    # set up
    F := F / relatorsF;
    gensF := GeneratorsOfGroup( F );
    iso := GroupHomomorphismByImagesNC( G, F, imgsF, gensF );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ) );
    return iso;
end );


InstallOtherMethod( IsomorphismFpGroupByCompositionSeries,
                    "for perm groups",
                    true,
                    [IsPermGroup],
                    0,
function( G )
    return IsomorphismFpGroupByCompositionSeries( G, "F" );
end );


#############################################################################
##
#M  IsomorphismFpGroupByGenerators( G, gens, str )
##
InstallMethod( IsomorphismFpGroupByGenerators,
               "for perm groups",
               true,
               [IsPermGroup, IsList, IsString],
               0,

function( G, gens, str )
    local F, gensF, hom, relators, S, gensS, iso;

    # check trivial case
    if Length( gens ) = 0 then
        S := FreeGroup( 0 );
    elif Length( gens ) = 1 then
        F := FreeGroup( 1 );
        gensF := GeneratorsOfGroup( F );
        relators := [gensF[1]^Size(G)];
        S := F/relators;
    else
        F := FreeGroup( Length( gens ), str );
        gensF := GeneratorsOfGroup( F );
        hom := GroupHomomorphismByImagesNC( G, F, gens, gensF );
        relators := CoKernelGensPermHom( hom );
        S := F / relators;
    fi;
    gensS := GeneratorsOfGroup( S );
    iso := GroupHomomorphismByImagesNC( G, S, gens, gensS );
    SetIsSurjective( iso, true );
    SetIsInjective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ));
    return iso;
end );

InstallOtherMethod( IsomorphismFpGroupByGenerators,
               "for perm groups",
               true,
               [IsPermGroup, IsList],
               0,
function( G, gens )
    return IsomorphismFpGroupByGenerators( G, gens, "F" );
end );


#############################################################################
##
#M  IsomorphismFpGroupBySubnormalSeries( G, series, str )
##
InstallMethod( IsomorphismFpGroupBySubnormalSeries,
               "for groups",
               true,
               [IsPermGroup, IsList, IsString],
               0,
function( G, series, str )
    local l, H, gensH, iso, F, gensF, imgsF, relatorsF, free, n, k, N, M,
          hom, preiH, c, new, T, gensT, E, gensE, imgsE, relatorsE, rel,
          w, t, i, j;

    # set up with smallest subgroup of series
    l      := Length( series );
    H := series[l-1];
    gensH := Set( GeneratorsOfGroup( H ) );
    gensH := Filtered( gensH, x -> x <> One(H) );
    iso   := IsomorphismFpGroupByGenerators( H, gensH, str );
    F     := FreeGroupOfFpGroup( Image( iso ) );
    gensF := GeneratorsOfGroup( F );
    imgsF := iso!.generators;
    relatorsF := RelatorsOfFpGroup( Image( iso ) );
    free  := GroupHomomorphismByImagesNC( F, series[l-1], gensF, imgsF );
    n     := Length( gensF );

    # loop over series upwards
    for k in Reversed( [1..l-2] ) do

        # get composition factor
        N := series[k];
        M := series[k+1];
        hom   := NaturalHomomorphismByNormalSubgroupNC( N, M );
        H     := Image( hom );
        gensH := Set( GeneratorsOfGroup( H ) );
        gensH := Filtered( gensH, x -> x <> One(H) );
        preiH := List( gensH, x -> PreImagesRepresentative( hom, x ) );
        c     := Length( gensH );

        # compute presentation of H
        new := IsomorphismFpGroupByGenerators( H, gensH, "g" );
        T   := Image( new );
        gensT := GeneratorsOfGroup( FreeGroupOfFpGroup( T ) );

        # create new free group
        E     := FreeGroup( n+c, str );
        gensE := GeneratorsOfGroup( E );
        imgsE := Concatenation( preiH, imgsF );
        relatorsE := [];

        # modify presentation of H
        for rel in RelatorsOfFpGroup( T ) do
            w := MappedWord( rel, gensT, gensE{[1..c]} );
            t := MappedWord( rel, gensT, imgsE{[1..c]} );
            if not t = One( G ) then
                t := PreImagesRepresentative( free, t );
                t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
            else
                t := One( E );
            fi;
            Add( relatorsE, w/t );
        od;

        # add operation of T on F
        for i in [1..c] do
            for j in [1..n] do
                w := Comm( gensE[c+j], gensE[i] );
                t := Comm( imgsE[c+j], imgsE[i] );
                if not t = One( G ) then
                    t := PreImagesRepresentative( free, t );
                    t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
                else
                    t := One( E );
                fi;
                Add( relatorsE, w/t );
            od;
        od;

        # append relators of F
        for rel in relatorsF do
            w := MappedWord( rel, gensF, gensE{[c+1..c+n]} );
            Add( relatorsE, w );
        od;

        # iterate
        F := E;
        gensF := gensE;
        imgsF := imgsE;
        relatorsF := relatorsE;
        free :=  GroupHomomorphismByImagesNC( F, N, gensF, imgsF );
        n := n + c;
    od;

    # set up
    F     := F / relatorsF;
    gensF := GeneratorsOfGroup( F );
    iso   := GroupHomomorphismByImagesNC( G, F, imgsF, gensF );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ) );
    return iso;
end);

InstallOtherMethod( IsomorphismFpGroupBySubnormalSeries,
               "for groups",
               true,
               [IsPermGroup, IsList],
               0,
function( G, series )
    return IsomorphismFpGroupBySubnormalSeries( G, series, "F" );
end);


#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> )
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
  "map from fp group or free group to perm group",
  true, [ IsFromFpGroupStdGensGeneralMappingByImages
	  and IsToPermGroupGeneralMappingByImages ],0,
function(hom)
local f,p,t,orbs,o,cor,u,frg;

  f:=Source(hom);
  frg:=FreeGeneratorsOfFpGroup(f);
  t:=List(GeneratorsOfGroup(f),i->Image(hom,i));
  p:=SubgroupNC(Range(hom),t);
  Assert(1,GeneratorsOfGroup(p)=t);
  # construct coset table
  t:=[];
  orbs:=Orbits(p,MovedPoints(p));
  cor:=f;

  for o in orbs do
    u:=SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(f),
         p,Core(p,Stabilizer(p,o[1])));
    cor:=Intersection(cor,u);
  od;

  if IsIdenticalObj(cor,f) then # in case we get a wrong parent
    SetIsNormalInParent(cor,true);
  fi;
  return cor;
end);

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> )
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
  "map from fp group or free group to arbitrary finite group",
  true, [ IsFromFpGroupStdGensGeneralMappingByImages ],0,
function(hom)
local p,s,t;

  s:=Source(hom);
  t:=List(GeneratorsOfGroup(s),i->Image(hom,i));
  p:=SubgroupNC(Range(hom),t);
  Assert(1,GeneratorsOfGroup(p)=t);
  if not IsFinite(p) then
    TryNextMethod();
  fi;

  return SubgroupOfWholeGroupByQuotientSubgroup(
           FamilyObj(s),p,TrivialSubgroup(p));
end);

#############################################################################
##
#M  PreImagesSet( <hom> )
##
InstallMethod( PreImagesSet,
  "map from fp group or free group to arbitrary finite group",
  CollFamRangeEqFamElms,
  [ IsFromFpGroupStdGensHomomorphismByImages,IsGroup ],0,
function(hom,u)
local s,p,t;
  s:=Source(hom);
  t:=List(GeneratorsOfGroup(s),i->Image(hom,i));
  p:=GroupWithGenerators(t);
  SetParent(p,Range(hom));
  if HasIsSurjective(hom) and IsSurjective(hom) then
    SetIndexInParent(p,1);
  fi;

  return SubgroupOfWholeGroupByQuotientSubgroup(
           FamilyObj(s),p,u);
end);

# this method is not ready (we would have to test that hom!.generators are
# the schreier generators) 26-2-99, AH
# InstallMethod( PreImagesSet, "map from subgroup of fp group",
#   CollFamRangeEqFamElms,
#   [ IsFromFpGroupHomomorphismByImages,IsGroup ],0,
# function(hom,u)
# local s,a,t;
#   s:=Source(hom);
#   t:=CosetTableInWholeGroup(s);
#   a:=CosetTable(Image(hom),u);
#   # now tensor the coset tables
#
# end);


#############################################################################
##
#M  LowIndexSubgroupsFpGroup(<G>,<H>,<index>[,<excluded>]) . . find subgroups
#M                               of small index in a finitely presented group
##
BindGlobal( "DoLowIndexSubgroupsFpGroup", function ( arg )
    local   G,          # parent group
            ggens,      # generators of G
            fgens,      # generators of associated free group
            grels,      # relators of G
            involutions, # indices of involutory gens of G
            hgens,      # generators of H
            fhgens,     # their preimages in the free group of G
            H,          # subgroup to be included in all resulting subgroups
            index,      # maximal index of subgroups to be determined
            excludeList, # representatives of element classes to be excluded
            exclude,    # true, if element classes to be excluded are given
            excludeGens, # table columns corresponding to gens to be excluded
            excludeWords, # words to be excluded, sorted by start generator
            subs,       # subgroups of <G>, result
            sub,        # one subgroup
            gens,       # generators of <sub>
            indexInWholeGroup, # index of <sub> in G
            tableInWholeGroup, # coset table of <sub> in G
            table,      # coset table
            nrgens,     # 2*(number of generators)+1
            nrcos,      # number of cosets in the coset table
            definition, # "definition"
            choice,     # "choice"
            deduction,  # "deduction"
            action,     # 'action[<i>]' is definition or choice or deduction
            actgen,     # 'actgen[<i>]' is the gen where this action was
            actcos,     # 'actcos[<i>]' is the coset where this action was
            nract,      # number of actions
            nrded,      # number of deductions already handled
            coinc,      # 'true' if a coincidence happened
            gen,        # current generator
            cos,        # current coset
            rels,       # representatives for the relators
            relsGen,    # relators sorted by start generator
            subgroup,   # rows for the subgroup gens
            nrsubgrp,   # number of subgroups
            app,        # arguments list for 'ApplyRel'
            later,      # 'later[<i>]' is <> 0 if <i> is smaller than 1
            nrfix,      # index of a subgroup in its normalizer
            pair,       # loop variable for subgroup generators as pairs
            rel,        # loop variable for relators
            triple,     # loop variable for relators as triples
            r, s,       # renumbering lists
            x, y,       # loop variables
            g, c, d,    # loop variables
            p, p1, p2,  # generator position numbers
            length,     # relator length
            length2,    # twice a relator length
            cols,
            nums,
            ngens,      # number of generators of G
            word,       # loop variable for words to be excluded
            numgen,
            numcos,
            i, j;       # loop variables

    # give some information
    Info( InfoFpGroup, 1, "LowIndexSubgroupsFpGroup called" );

    # check the arguments
    G := arg[1];
    H := arg[2];
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;
    index := arg[3];

    # get some local variables
    ggens := GeneratorsOfGroup( G );
    fgens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    involutions := IndicesInvolutaryGenerators( G );
    hgens := GeneratorsOfGroup( H );
    fhgens := List( hgens, gen -> UnderlyingElement( gen ) );

    # initialize the exclude lists, if elements to be excluded are given
    exclude := Length( arg ) > 3;
    if exclude then
        excludeList := arg[4];
    fi;

    # initialize the subgroup list
    subs := [];

    # handle the special case index = 1.
    if index = 1 then
        if not exclude or excludeList = [] then  subs := [ G ];  fi;
        return subs;
    fi;

    # initialize table
    rels := RelatorRepresentatives( grels );
    nrgens := 2 * Length( fgens ) + 1;
    nrcos := 1;
    table := [];
    for i in [ 1 .. Length( fgens ) ] do
        g := ListWithIdenticalEntries( index, 0 );
        Add( table, g );
        if not i in involutions then
	    g := ListWithIdenticalEntries( index, 0 );
        fi;
        Add( table, g );
    od;

    # prepare the exclude lists
    if exclude then

        # mark the column numbers of the generators to be excluded
        ngens := Length( fgens );
        excludeGens := ListWithIdenticalEntries( 2 * ngens, 0 );
        for i in [ 1 .. ngens ] do
            gen := fgens[i];
            if gen in excludeList or gen^-1 in excludeList then
                excludeGens[2*i-1] := 1;
                excludeGens[2*i] := 1;
            fi;
        od;

        # make the rows for the words of length > 1 to be excluded
        excludeWords := [];
        for word in excludeList do
            if Length( word ) > 1 then
                Add( excludeWords, word );
            fi;
        od;
        excludeWords := RelsSortedByStartGen(
            fgens, excludeWords, table, false );
    fi;

    # make the rows for the relators and distribute over relsGen
    relsGen := RelsSortedByStartGen( fgens, rels, table, true );

    # make the rows for the subgroup generators
    subgroup := [];
    for rel  in fhgens  do
        length := Length( rel );
        length2 := 2 * length;
        nums := [ ]; nums[length2] := 0;
        cols := [ ]; cols[length2] := 0;

        # compute the lists.
        i := 0;  j := 0;
        while i < length do
            i := i + 1;  j := j + 2;
            gen := Subword( rel, i, i );
            p := Position( fgens, gen );
            if p = fail then
                p := Position( fgens, gen^-1 );
                p1 := 2 * p;
                p2 := 2 * p - 1;
            else
                p1 := 2 * p - 1;
                p2 := 2 * p;
            fi;
            nums[j]   := p1;  cols[j]   := table[p1];
            nums[j-1] := p2;  cols[j-1] := table[p2];
        od;
        Add( subgroup, [ nums, cols ] );
    od;
    nrsubgrp := Length( subgroup );

    # make an structure that is passed to 'ApplyRel'
    app := ListWithIdenticalEntries( 4, 0 );

    # set up the action stack
    definition := 1;
    choice := 2;
    deduction := 3;
    nract := 1;
    action := [ choice ];
    gen := 1;
    actgen := [ gen ];
    cos := 1;
    actcos := [ cos ];

    # set up the lexicographical information list
    later := ListWithIdenticalEntries( index, 0 );

    # initialize the renumbering lists
    r := [ ]; r[index] := 0;
    s := [ ]; s[index] := 0;

    # do an exhaustive backtrack search
    while 1 < nract  or table[1][1] < 2  do

        # find the next choice that does not already appear in this col.
        c := table[ gen ][ cos ];
        repeat
            c := c + 1;
        until index < c  or table[ gen+1 ][ c ] = 0;

        # if there is a further choice try it
        if action[nract] <> definition  and c <= index  then

            # remove the last choice from the table
            d := table[ gen ][ cos ];
            if d <> 0  then
                table[ gen+1 ][ d ] := 0;
            fi;

            # enter it in the table
            table[ gen ][ cos ] := c;
            table[ gen+1 ][ c ] := cos;

            # and put information on the action stack
            if c = nrcos + 1  then
                nrcos := nrcos + 1;
                action[ nract ] := definition;
            else
                action[ nract ] := choice;
            fi;

            # run through the deduction queue until it is empty
            nrded := nract;
            coinc := false;
            while nrded <= nract and not coinc  do

                # check given exclude elements to be excluded
                if exclude then
                    numgen := actgen[nrded];
                    numcos := actcos[nrded];
                    if excludeGens[numgen] = 1 and
                        numcos = table[numgen][numcos] then
                        coinc := true;
                    else
                        length := Length( excludeWords[actgen[nrded]] );
                        i := 1;
                        while i <= length and not coinc do
                            triple := excludeWords[actgen[nrded]][i];
                            app[1] := triple[3];
                            app[2] := actcos[ nrded ];
                            app[3] := -1;
                            app[4] := app[2];
                            if not ApplyRel( app, triple[2] ) and
                                app[1] = app[3] + 1 then
                                coinc := true;
                            fi;
                            i := i + 1;
                        od;
                    fi;
                fi;

                # if there are still subgroup generators apply them
                i := 1;
                while i <= nrsubgrp and not coinc do
                    pair := subgroup[i];
                    app[1] := 2;
                    app[2] := 1;
                    app[3] := Length(pair[2])-1;
                    app[4] := 1;
                    if ApplyRel( app, pair[2] )  then
                        if   pair[2][app[1]][app[2]] <> 0  then
                            coinc := true;
                        elif pair[2][app[3]][app[4]] <> 0  then
                            coinc := true;
                        else
                            pair[2][app[1]][app[2]] := app[4];
                            pair[2][app[3]][app[4]] := app[2];
                            nract := nract + 1;
                            action[ nract ] := deduction;
                            actgen[ nract ] := pair[1][app[1]];
                            actcos[ nract ] := app[2];
                        fi;
                    fi;
                    i := i + 1;
                od;

                # apply all relators that start with this generator
                length := Length( relsGen[actgen[nrded]] );
                i := 1;
                while i <= length and not coinc do
                    triple := relsGen[actgen[nrded]][i];
                    app[1] := triple[3];
                    app[2] := actcos[ nrded ];
                    app[3] := -1;
                    app[4] := app[2];
                    if ApplyRel( app, triple[2] )  then
                        if   triple[2][app[1]][app[2]] <> 0  then
                            coinc := true;
                        elif triple[2][app[3]][app[4]] <> 0  then
                            coinc := true;
                        else
                            triple[2][app[1]][app[2]] := app[4];
                            triple[2][app[3]][app[4]] := app[2];
                            nract := nract + 1;
                            action[ nract ] := deduction;
                            actgen[ nract ] := triple[1][app[1]];
                            actcos[ nract ] := app[2];
                        fi;
                    fi;
                    i := i + 1;
                od;

                nrded := nrded + 1;
            od;

            # unless there was a coincidence check lexicography
            if not coinc then
              nrfix := 1;
              x := 1;
              while x < nrcos and not coinc do
                x := x + 1;

                # set up the renumbering
                for i in [1..nrcos] do
                    r[i] := 0;
                    s[i] := 0;
                od;
                r[x] := 1;  s[1] := x;

                # run through the old and the new table in parallel
                c := 1;  y := 1;
                while c <= nrcos  and not coinc  and later[x] = 0  do

                    # get the corresponding coset for the new table
                    d := s[c];

                    # loop over the entries in this row
                    g := 1;
                    while   g < nrgens
                        and c <= nrcos  and not coinc  and later[x] = 0  do

                        # if either entry is missing we cannot decide yet
                        if table[g][c] = 0  or table[g][d] = 0  then
                            c := nrcos + 1;

                        # if old and new both contain a definition
                        elif r[ table[g][d] ] = 0 and table[g][c] = y+1  then
                            y := y + 1;
                            r[ table[g][d] ] := y;
                            s[ y ] := table[g][d];

                        # if only new is a definition
                        elif r[ table[g][d] ] = 0  then
                            later[x] := nract;

                        # if new is the smaller one we have a coincidence
                        elif r[ table[g][d] ] < table[g][c]  then

                            # check that <x> fixes <H>
                            coinc := true;
                            for pair in subgroup  do
                                app[1] := 2;
                                app[2] := x;
                                app[3] := Length(pair[2])-1;
                                app[4] := x;
                                if ApplyRel( app, pair[2] )  then

                                    # coincidence: <x> does not fix <H>
                                    if   pair[2][app[1]][app[2]] <> 0  then
                                        later[x] := nract;
                                        coinc := false;
                                    elif pair[2][app[3]][app[4]] <> 0  then
                                        later[x] := nract;
                                        coinc := false;

                                    # non-closure (ded): <x> may not fix <H>
                                    else
                                        coinc := false;
                                    fi;

                                # non-closure (not ded): <x> may not fix <H>
                                elif app[1] <= app[3]  then
                                    coinc := false;
                                fi;

                            od;

                        # if old is the smaller one very good
                        elif table[g][c] < r[ table[g][d] ]  then
                            later[x] := nract;

                        fi;

                        g := g + 2;
                    od;

                    c := c + 1;
                od;

                if c = nrcos + 1  then
                    nrfix := nrfix + 1;
                fi;

              od;
            fi;

            # if there was no coincidence
            if not coinc  then

                # look for another empty place
                c := cos;
                g := gen;
                while c <= nrcos  and table[ g ][ c ] <> 0  do
                    g := g + 2;
                    if g = nrgens  then
                        c := c + 1;
                        g := 1;
                    fi;
                od;

                # if there is an empty place, make this a new choice point
                if c <= nrcos  then

                    nract := nract + 1;
                    action[ nract ] := choice; # necessary?
                    gen := g;
                    actgen[ nract ] := gen;
                    cos := c;
                    actcos[ nract ] := cos;
                    table[ gen ][ cos ] := 0; # necessary?

                # otherwise we found a subgroup
                else

                    # give some information
                    Info( InfoFpGroup, 2,  " class ", Length(subs)+1,
                                  " of index ", nrcos,
                                  " and length ", nrcos / nrfix );

                    # find a generating system for the subgroup
                    gens := ShallowCopy( hgens );
                    for i  in [ 1 .. nract ]  do
                        if action[ i ] = choice  then
                            x := One( ggens[1] );
                            c := actcos[i];
                            while c <> 1  do
                                g := nrgens - 1;
                                y := nrgens - 1;
                                while 0 < g  do
                                    if table[g][c] <= table[y][c]  then
                                        y := g;
                                    fi;
                                    g := g - 2;
                                od;
                                x := ggens[ y/2 ] * x;
                                c := table[y][c];
                            od;
                            x := x * ggens[ (actgen[i]+1)/2 ];
                            c := table[ actgen[i] ][ actcos[i] ];
                            while c <> 1  do
                                g := nrgens - 1;
                                y := nrgens - 1;
                                while 0 < g  do
                                    if table[g][c] <= table[y][c]  then
                                        y := g;
                                    fi;
                                    g := g - 2;
                                od;
                                x := x * ggens[ y/2 ]^-1;
                                c := table[y][c];
                            od;
                            Add( gens, x );
                        fi;
                    od;

                    # add the coset table
                    sub := Subgroup( G, gens );
                    tableInWholeGroup := [];
                    for g  in [ 1 .. Length( fgens ) ]  do
                        tableInWholeGroup[2*g-1]
                                := table[2*g-1]{ [1..nrcos] };
			tableInWholeGroup[2*g]
			    := table[2*g]{ [1..nrcos] };
                    od;
                    SetCosetTableInWholeGroup( sub, tableInWholeGroup );
		    indexInWholeGroup := Length( tableInWholeGroup[1] );
		    SetIndexInWholeGroup( sub, indexInWholeGroup );
		    if HasSize( G ) then
		      SetSize( sub, Size( G ) / indexInWholeGroup );
		    fi;

                    # add this subgroup to the list of subgroups
                    #N  05-Feb-92 martin should be 'ConjugacyClassSubgroup'
                    Add( subs, sub );

                    # undo all deductions since the previous choice point
                    while action[ nract ] = deduction  do
                        g := actgen[ nract ];
                        c := actcos[ nract ];
                        d := table[ g ][ c ];
                        if g mod 2 = 1  then
                            table[ g   ][ c ] := 0;
                            table[ g+1 ][ d ] := 0;
                        else
                            table[ g   ][ c ] := 0;
                            table[ g-1 ][ d ] := 0;
                        fi;
                        nract := nract - 1;
                    od;
                    for x  in [2..index]  do
                        if nract <= later[x]  then
                            later[x] := 0;
                        fi;
                    od;

                fi;

            # if there was a coincendence go back to the current choice point
            else

                # undo all deductions since the previous choice point
                while action[ nract ] = deduction  do
                    g := actgen[ nract ];
                    c := actcos[ nract ];
                    d := table[ g ][ c ];
                    if g mod 2 = 1  then
                        table[ g   ][ c ] := 0;
                        table[ g+1 ][ d ] := 0;
                    else
                        table[ g   ][ c ] := 0;
                        table[ g-1 ][ d ] := 0;
                    fi;
                    nract := nract - 1;
                od;
                for x  in [2..index]  do
                    if nract <= later[x]  then
                        later[x] := 0;
                    fi;
                od;

            fi;

        # go back to the previous choice point if there are no more choices
        else

            # undo the choice point
            if action[ nract ] = definition  then
                nrcos := nrcos - 1;
            fi;
            g := actgen[ nract ];
            c := actcos[ nract ];
            d := table[ g ][ c ];
            if g mod 2 = 1  then
                table[ g   ][ c ] := 0;
                table[ g+1 ][ d ] := 0;
            else
                table[ g   ][ c ] := 0;
                table[ g-1 ][ d ] := 0;
            fi;
            nract := nract - 1;

            # undo all deductions since the previous choice point
            while action[ nract ] = deduction  do
                g := actgen[ nract ];
                c := actcos[ nract ];
                d := table[ g ][ c ];
                if g mod 2 = 1  then
                    table[ g   ][ c ] := 0;
                    table[ g+1 ][ d ] := 0;
                else
                    table[ g   ][ c ] := 0;
                    table[ g-1 ][ d ] := 0;
                fi;
                nract := nract - 1;
            od;
            for x  in [2..index]  do
                if nract <= later[x]  then
                    later[x] := 0;
                fi;
            od;

            cos := actcos[ nract ];
            gen := actgen[ nract ];

        fi;

    od;

    # give some final information
    Info( InfoFpGroup, 1, "LowIndexSubgroupsFpGroup returns ",
                 Length(subs), " classes" );

    # return the subgroups
    return subs;
end );

InstallMethod(LowIndexSubgroupsFpGroup, "subgroups of full fp group",
  IsFamFamX,
  [IsSubgroupFpGroup and IsWholeFamily,IsSubgroupFpGroup,IsPosInt],0,
  DoLowIndexSubgroupsFpGroup);

InstallOtherMethod(LowIndexSubgroupsFpGroup,
  "subgroups of full fp group, with exclusion list", IsFamFamXY,
  [IsSubgroupFpGroup and IsWholeFamily,IsSubgroupFpGroup,IsPosInt,IsList],0,
  DoLowIndexSubgroupsFpGroup);

InstallMethod(LowIndexSubgroupsFpGroup, "subgroups of fp group",
  IsFamFamX, [IsSubgroupFpGroup,IsSubgroupFpGroup,IsPosInt],0,
function(G,H,ind)
local fpi,u,l,i,a;
  fpi:=IsomorphismFpGroup(G);
  u:=LowIndexSubgroupsFpGroup(Range(fpi),Image(fpi,H),ind);

  l:=[];
  for i in u do
    a:=PreImagesSet(fpi,i);
    SetIndexInWholeGroup(a,IndexInWholeGroup(G)*IndexInWholeGroup(i));
    Add(l,a);
  od;
  return l;
end);

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup(<G>,<N>)
##
InstallMethod(NaturalHomomorphismByNormalSubgroupOp,
  "for subgroups of fp groups",IsIdenticalObj,
    [IsSubgroupFpGroup, IsSubgroupFpGroup],0,
function(G,N)
local T;
  if not HasCosetTableInWholeGroup(N) and not
    IsSubgroupOfWholeGroupByQuotientRep(N) then

    # try to compute a coset table
    T:=TryCosetTableInWholeGroup(N:silent:=true);
    if T=fail then
      if not IsWholeFamily(G) then
        TryNextMethod(); # can't do
      fi;
      # did not succeed - do the stupid thing
      T:=FactorGroupNC( G, GeneratorsOfGroup( N ) );
      T:=GroupHomomorphismByImagesNC(G,T,
          GeneratorsOfGroup(G),GeneratorsOfGroup(T));
      return T;
    fi;

  fi;
  return NaturalHomomorphismByNormalSubgroupNC(G,
           AsSubgroupOfWholeGroupByQuotient(N));
end);

InstallMethod(NaturalHomomorphismByNormalSubgroupOp,
  "for subgroups of fp groups by quotient rep.",IsIdenticalObj,
    [IsSubgroupFpGroup, 
     IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep ],0,
function(G,N)
local Q,B,Ggens,gens,hom;
  Q:=N!.quot;
  Ggens:=GeneratorsOfGroup(G);
  # generators of G in image
  gens:=List(Ggens,elm->
    MappedWord(elm,FreeGeneratorsOfWholeGroup(N),GeneratorsOfGroup(Q)));
  B:=SubgroupNC(Q,gens);
  hom:=NaturalHomomorphismByNormalSubgroupNC(B,N!.sub);
  gens:=List(gens,i->ImageElm(hom,i));
  hom:=GroupHomomorphismByImagesNC(G,Range(hom),Ggens,gens);
  SetKernelOfMultiplicativeGeneralMapping(hom,N);
  return hom;
end);

InstallMethod(NaturalHomomorphismByNormalSubgroupOp,
  "trivial fp case",IsIdenticalObj,
    [IsSubgroupFpGroup, 
     IsSubgroupFpGroup and IsWholeFamily ],0,
function(G,N)
local Q,Ggens,gens,hom;

  Ggens:=GeneratorsOfGroup(G);
  # generators of G in image
  gens:=List(Ggens,elm->());
  Q:=GroupWithGenerators(gens);
  hom:=GroupHomomorphismByImagesNC(G,Q,Ggens,gens);
  SetKernelOfMultiplicativeGeneralMapping(hom,N);
  return hom;
end);

#############################################################################
##
#M  NormalizerOp(<G>,<H>)
##
InstallMethod(NormalizerOp,"subgroups of fp group: find stabilizing cosets",
  IsIdenticalObj,[IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function ( G, H )
local   N,          # normalizer of <H> in <G>, result
	Ntab,	    # normalizer coset table
	pargens,    # parent generators
	table,      # coset table of <H> in its parent
	nrcos,      # number of cosets in the table
	nrgens,     # 2*(number of generators of <H>s parent)+1
	iseql,      # true if coset <c> normalizes <H>
	r, s,       # renumbering of the coset table and its inverse
	c, d, e,    # coset loop variables
	g;       # generator loop variables

  # compute the normalizer in the full group.

  # first we need the coset table of <H>
  table := CosetTableInWholeGroup(H);
  pargens:=GeneratorsOfGroup(FamilyObj(G)!.wholeGroup);
  nrcos := Length( table[1] );
  nrgens := 2*Length( pargens ) + 1;

  # find the cosets of <H> in its parent whose elements normalize <H>
  N := [1];
  for c  in [ 2 .. nrcos ]  do

    # test if the renumbered table is equal to the original table
    r := 0 * [ 1 .. nrcos ];
    s := 0 * [ 1 .. nrcos ];
    r[c] := 1;  s[1] := c;
    e := 1;
    iseql := true;
    d := 1;
    while d <= nrcos  and iseql  do
      g := 1;
      while g < nrgens  and iseql  do
	if r[ table[g][s[d]] ] = 0  then
	  e := e + 1;
	  r[ table[g][s[d]] ] := e;
	  s[ e ] := table[g][s[d]];
	fi;
	iseql := (r[ table[g][s[d]] ] = table[g][d]);
	g := g + 2;
      od;
      d := d + 1;
    od;

    # add the index of this coset if it normalizes
    if iseql  then
      AddSet(N,c);
    fi;

  od;

  # now N is the block representing the normalizer cosets.

  if Length(N)=1 then
    # self-normalizing
    N:=H;
  else
    # form the whole block system
    table:=List(table{[1,3..Length(table)-1]},PermList);
    N:=Orbit(Group(table,()),N,OnSets);
    N:=Set(N);
    d:=Length(N);

    # make a table for the action on these blocks.
    N:=List(table,i->Permutation(i,N,OnSets));
    Ntab:=[];
    for c in N do
      Add(Ntab,OnTuples([1..d],c));
      Add(Ntab,OnTuples([1..d],c^-1));
    od;
    StandardizeTable(Ntab);

    N:=SubgroupOfWholeGroupByCosetTable(FamilyObj(H),Ntab);
  fi;

  # if necessary intersect with G
  if HasIsWholeFamily(G) and IsWholeFamily(G) then
    return N;
  fi;
  N:=Intersection(G,N);

  return N;
end);

InstallMethod(NormalizerOp,"subgroups of fp group by quot. rep",
  IsIdenticalObj,
    [ IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep,
      IsSubgroupFpGroup  and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(G,H)
local d,A,B,e1,e2,Ag,Bg,s,sg,u,v;
  A:=G!.quot;
  B:=H!.quot;
  # are we represented in the same quotient?
  if GeneratorsOfGroup(A)=GeneratorsOfGroup(B) then
    # we are, compute simply in the quotient
    return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),G!.quot,
             Normalizer(G!.sub,H!.sub));
  fi;

  d:=DirectProduct(A,B);
  e1:=Embedding(d,1);
  e2:=Embedding(d,2);
  Ag:=GeneratorsOfGroup(A);
  Bg:=GeneratorsOfGroup(B);
  # form the sdp
  sg:=List([1..Length(Ag)],i->Image(e1,Ag[i])*Image(e2,Bg[i]));
  s:=SubgroupNC(d,sg);
  Assert(1,GeneratorsOfGroup(s)=sg);

  # get both subgroups in the direct product via the projections
  # instead of intersecting both preimages with s we only intersect the
  # intersection
  u:=PreImagesSet(Projection(d,1),G!.sub);
  v:=PreImagesSet(Projection(d,2),H!.sub);
  u:=Intersection(u,s);
  v:=Intersection(v,s);

  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),s,
	    Normalizer(u,v));
  
end);

InstallMethod(NormalizerOp,"in whole group by quot. rep",
  IsIdenticalObj,
    [ IsSubgroupFpGroup and IsWholeFamily,
      IsSubgroupFpGroup  and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(G,H)
  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),H!.quot,
	    Normalizer(H!.quot,H!.sub));
end);

#############################################################################
##
#M  MappedWord( <x>, <gens1>, <gens2> )
##
InstallOtherMethod( MappedWord, true,
    [ IsElementOfFpGroup, IsList, IsList ], 0,
    MappedWordForAssocWord );


#############################################################################
##
#F  MostFrequentGeneratorFpGroup( <G> ) . . . . . . . most frequent generator
##
##  is an internal function which is used in some applications of coset
##  table methods. It returns the first of those generators of the given
##  finitely presented group <G> which occur most frequently in the
##  relators.
##
InstallGlobalFunction( MostFrequentGeneratorFpGroup, function ( G )

    local altered, gens, gens2, i, i1, i2, k, max, j, num, numgens,
          numrels, occur, power, rel, relj, rels, set;

#@@ # check the first argument to be a finitely presented group.
#@@ if not ( IsRecord( G ) and IsBound( G.isFpGroup ) and G.isFpGroup ) then
#@@     Error( "argument must be a finitely presented group" );
#@@ fi;

    # Get some local variables.
    gens := FreeGeneratorsOfFpGroup( G );
    rels := RelatorsOfFpGroup( G );
    numgens := Length( gens );
    numrels := Length( rels );

    # Initialize a counter.
    occur := ListWithIdenticalEntries( numgens, 0 );
    power := ListWithIdenticalEntries( numgens, 0 );

    # initialize a list of the generators and their inverses
    gens2 := [ ]; gens2[numgens] := 0;
    for i in [ 1 .. numgens ] do
        gens2[i] := gens[i];
        gens2[numgens+i] := gens[i]^-1;
    od;

    # convert the relators to vectors of generator numbers and count their
    # occurrences.
    for j in [ 1 .. numrels ] do
        # convert the j-th relator to a Tietze relator
        relj := rels[j];
        i1 := 1;
        i2 := Length( relj );
        while i1 < i2 and
            Subword( relj, i1, i1 ) = Subword( relj, i2, i2 )^-1 do
            i1 := i1 + 1;
            i2 := i2 - 1;
        od;
        rel := List( [ i1 .. i2 ],
            i -> Position( gens2, Subword( relj, i, i ) ) );
        # count the occurrences of the generators in rel
        for i in [ 1 .. Length( rel ) ] do
            k := rel[i];
            if k = fail then
                Error( "given relator is not a word in the generators" );
            elif k <= numgens then
                occur[k] := occur[k] + 1;
            else
                k := k - numgens;
                rel[i] := -k;
                occur[k] := occur[k] + 1;
            fi;
        od;
        # check the current relator for being a power relator.
        set := Set( rel );
        if Length( set ) = 2 then
            num := [ 0, 0 ];
            for i in rel do
                if i = set[1] then num[1] := num[1] + 1;
                else num[2] := num[2] + 1; fi;
            od;
            if num[1] = 1 then
                power[AbsInt( set[2] )] := AbsInt( set[1] );
            elif num[2] = 1 then
                power[AbsInt( set[1] )] := AbsInt( set[2] );
            fi;
        fi;
    od;

    # increase the occurrences numbers of generators which are roots of
    # other ones, but avoid infinite loops.
    i := 1;
    altered := true;
    while altered do
        altered := false;
        for j in [ i .. numgens ] do
            if power[j] > 0 and power[power[j]] = 0 then
                occur[j] := occur[j] + occur[power[j]];
                power[j] := 0;
                altered := true;
                if i = j then i := i + 1; fi;
            fi;
        od;
    od;

    # find the most frequently occurring generator and return it.
    i := 1;
    max := occur[1];
    for j in [ 2 .. numgens ] do
        if occur[j] > max then
            i := j;
            max := occur[j];
        fi;
    od;
    gens := GeneratorsOfGroup( G );
    return gens[i];
end );


#############################################################################
##
#M  PreImagesRepresentative
##
InstallMethod( PreImagesRepresentative,
  "hom. to standard generators of fp group, using 'MappedWord'",
  FamRangeEqFamElm,
  [IsToFpGroupHomomorphismByImages,IsMultiplicativeElementWithInverse],0,
function(hom,elm)
  if not IsIdenticalObj(hom!.genimages,GeneratorsOfGroup(Range(hom))) then
    # check, whether we map to the standard generators
    TryNextMethod();
  fi;
  return MappedWord(elm,hom!.genimages,hom!.generators);
end);


#############################################################################
##
#F  RelatorRepresentatives(<rels>) . set of representatives of a list of rels
##
##  'RelatorRepresentatives' returns a set of  relators,  that  contains  for
##  each relator in the list <rels> its minimal cyclical  permutation  (which
##  is automatically cyclically reduced).
##
InstallGlobalFunction( RelatorRepresentatives, function ( rels )
    local   cyc, fam, i, j, length, list, min, rel, reversed, reps;

    reps := [ ];

    # loop over all nontrivial relators
    for rel in rels  do
        length := Length( rel );
        if length > 0  then

            # invert the exponents to their negative values in order to get
            # an appropriate lexicographical ordering of the relators.
            fam := FamilyObj( rel );
            list := ShallowCopy(ExtRepOfObj( rel ));
            for i in [ 2, 4 .. Length( list ) ] do
                list[i] := -list[i];
            od;

            # find the minimal cyclic permutation
            reversed := ObjByExtRep( fam, list );
            cyc := reversed;
            min := cyc;
            if cyc^-1 < min  then min := cyc^-1;  fi;
            for i  in [ 1 .. length - 1 ]  do
                cyc := cyc ^ Subword( reversed, i, i );
                if cyc    < min  then min := cyc;     fi;
                if cyc^-1 < min  then min := cyc^-1;  fi;
            od;

            # if the relator is new, add it to the representatives
	    min:=Immutable([ Length( min ), min ] );
            if not min in reps  then
                AddSet( reps,min);
            fi;

        fi;
    od;

    # reinvert the exponents.
    for i in [ 1 .. Length( reps ) ]  do
        rel := reps[i][2];
        fam := FamilyObj( rel );
        list := ShallowCopy(ExtRepOfObj( rel ));
        for j in [ 2, 4 .. Length( list ) ] do
            list[j] := -list[j];
        od;
        reps[i] := ObjByExtRep( fam, list );
    od;

    # return the representatives
    return reps;
end );


#############################################################################
##
#M  RelatorsOfFpGroup( F )
##
InstallMethod( RelatorsOfFpGroup,
    "for finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.relators );


#############################################################################
##
#M  IndicesInvolutaryGenerators( F )
##
InstallMethod( IndicesInvolutaryGenerators, "for finitely presented group",
  true, [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
function(G)
local g,r;
  g:=FreeGeneratorsOfFpGroup(G);
  r:=RelatorsOfFpGroup(G);
  r:=Filtered(r,i->NumberSyllables(i)=1);
  return Filtered([1..Length(g)],i->g[i]^2 in r or g[i]^-2 in r);
end);


#############################################################################
##
#F  RelsSortedByStartGen( <gens>, <rels>, <table> [, <ignore> ] )
#F                                         relators sorted by start generator
##
##  'RelsSortedByStartGen'  is a  subroutine of the  Felsch Todd-Coxeter  and
##  the  Reduced Reidemeister-Schreier  routines. It returns a list which for
##  each  generator or  inverse generator  contains a list  of all cyclically
##  reduced relators,  starting  with that element,  which can be obtained by
##  conjugating or inverting given relators.  The relators are represented as
##  lists of the coset table columns corresponding to the generators and,  in
##  addition, as lists of the respective column numbers.
##                            
##  Square relators  will be ignored  if ignore = true.  The default value of
##  ignore is false.
##
InstallGlobalFunction( RelsSortedByStartGen, function ( arg )
local   gens,                   # group generators
	gennums,		# indices of generators
	rels,                   # relators
	table,                  # coset table
	ignore,                 # if true, ignore square relators
	relsGen,                # resulting list
	rel, cyc,               # one relator and cyclic permutation
	length, extleng,        # length and extended length of rel
	base, base2,            # base length of rel
	gen,                    # one generator in rel
	exp,		 	# syllable exponent
	es,		 	# exponents sum
	nums, invnums,          # numbers list and inverse
	cols, invcols,          # columns list and inverse
	p, p1, p2,              # positions of generators
	i, j, k;                # loop variables

    # get the arguments
    gens := arg[1];
    gennums:=
      List(gens,i->GeneratorSyllable(i,1)); # the indices of the generators
    rels := arg[2];
    table := arg[3];
    ignore := false;
    if  Length( arg ) > 3 then  ignore := arg[4];  fi;

    # check that the table has the right number of columns
    if 2 * Length(gens) <> Length(table) then
        Error( "table length is inconsistent with number of generators" );
    fi;

    # initialize the list to be constructed
    relsGen := [ ]; relsGen[2*Length(gens)] := 0;
    for i  in [ 1 .. Length(gens) ]  do
        relsGen[ 2*i-1 ] := [];
        if not IsIdenticalObj( table[ 2*i-1 ], table[ 2*i ] )  then
            relsGen[ 2*i ] := [];
        else
            relsGen[ 2*i ] := relsGen[ 2*i-1 ];
        fi;
    od;

    # now loop over all parent group relators
    for rel  in rels  do

        # get the length and the basic length of relator rel
        length := Length( rel );
        base := 1;

#        cyc := rel ^ Subword( rel, base, base );
#        while cyc <> rel do
#            base := base + 1;
#            cyc := cyc ^ Subword( rel, base, base );
#        od;

	# work in ext. rep.
	es:=ExtRepOfObj(rel);

	# conjugate with first generator
	cyc:=ShallowCopy(es);
	p:=SignInt(cyc[2]);
	if cyc[1]=cyc[Length(cyc)-1] then
	  cyc[Length(cyc)]:=cyc[Length(cyc)]+p;
	else
	  Append(cyc,[cyc[1],p]);
	fi;
	cyc[2]:=cyc[2]-p;
	if cyc[2]=0 then
	  cyc:=cyc{[3..Length(cyc)]};
	fi;

        while cyc <> es do
            base := base + 1;
	    p:=SignInt(cyc[2]);
	    if cyc[1]=cyc[Length(cyc)-1] then
	      cyc[Length(cyc)]:=cyc[Length(cyc)]+p;
	    else
	      Append(cyc,[cyc[1],p]);
	    fi;
	    cyc[2]:=cyc[2]-p;
	    if cyc[2]=0 then
	      cyc:=cyc{[3..Length(cyc)]};
	    fi;

        od;

	# ignore square relators
	if length <> 2 or base <> 1 or not ignore then

	    # initialize the columns and numbers lists corresponding to the
	    # current relator
	    base2 := 2 * base;
	    extleng := 2 * ( base + length ) - 1;
	    nums    := [ ]; nums[extleng]    := 0;
	    cols    := [ ]; cols[extleng]    := 0;
	    invnums := [ ]; invnums[extleng] := 0;
	    invcols := [ ]; invcols[extleng] := 0;

	    # compute the lists
	    i := 0; # number of current syllable
	    j := 1;  k := base2 + 3;
	    es:=0; # exponent index in word
	    while es < base do
		i:=i+1;
		gen:=GeneratorSyllable(rel,i);
		p:=Position(gennums,gen);
		exp:=ExponentSyllable(rel,i);
		if exp<0 then
		    p1:=2*p;
		    p2:=2*p-1;
		    exp:=-exp;
		else
		    p1:=2*p-1;
		    p2:=2*p;
		fi;

		while exp>0 and es<base do
		    j := j + 2;  k := k - 2;
		    nums[j]   := p1;         invnums[k-1] := p1;
		    nums[j-1] := p2;         invnums[k]   := p2;
		    cols[j]   := table[p1];  invcols[k-1] := table[p1];
		    cols[j-1] := table[p2];  invcols[k]   := table[p2];
		    Add( relsGen[p1], [ nums, cols, j ] );
		    Add( relsGen[p2], [ invnums, invcols, k ] );
		    exp:=exp-1;
		    es:=es+1;
	       od;
	    od;

	    while j < extleng do
		j := j + 1;
		nums[j] := nums[j-base2];  invnums[j] := invnums[j-base2];
		cols[j] := cols[j-base2];  invcols[j] := invcols[j-base2];
	    od;

	    nums[1] := length;          invnums[1] := length;
	    cols[1] := 2 * length - 3;  invcols[1] := cols[1];
        fi;
    od;

    # return the list
    return relsGen;
end );


#############################################################################
##
#M  Size( <G> )  . . . . . . . . . . . . . size of a finitely presented group
##
InstallMethod( Size,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   fgens,      # generators of the free group
            rels,       # relators of <G>
            H,          # subgroup of <G>
            T;          # coset table of <G> by <H>

        fgens := FreeGeneratorsOfFpGroup( G );
        rels  := RelatorsOfFpGroup( G );

        # handle free and trivial group
        if 0 = Length( fgens ) then
            return 1;
        elif 0 = Length(rels) then
            return infinity;

        # handle nontrivial fp group by computing the index of its trivial
        # subgroup
        else
            H := Subgroup( G, [ MostFrequentGeneratorFpGroup( G ) ] );
            T := AugmentedCosetTableMtc( G, H, -1, "_x" );
            if T.exponent = infinity then
                return infinity;
            else
                return T.index * T.exponent;
            fi;
        fi;

end );


#############################################################################
##
#M  Size( <H> )  . . . . . . size of s subgroup of a finitely presented group
##
InstallMethod( Size,
    "for subgroups of finitely presented groups",
    true,
    [ IsSubgroupFpGroup ],
    0,

function( H )
    local G;

    # Get whole group <G> of <H>.
    G := FamilyObj( H )!.wholeGroup;

    # Compute the size of <G> and the index of <H> in <G>.
    return Size( G ) / IndexInWholeGroup( H );

end );


#############################################################################
##
#M  IsomorphismPermGroup(<G>)
##
InstallMethod(IsomorphismPermGroup,"for full finitely presented groups",
    true, [ IsGroup and IsSubgroupFpGroup and IsGroupOfFamily ],
    # as this method may be called to compare elements we must get higher
    # than a method for finite groups (via right multiplication).
    SIZE_FLAGS(FLAGS_FILTER(IsFinite and IsGroup)),
function(G)
local t,p,H,gens;

  # handle free and trivial group
  if 0 = Length( FreeGeneratorsOfFpGroup( G )) then
    return GroupHomomorphismByImagesNC( G, GroupByGenerators( [], () ),
                                        [], [] );
  fi;

  # try action on cosets of cyclic subgroups
  gens:=GeneratorsOfGroup(G);
  # get most frequent first
  t:=MostFrequentGeneratorFpGroup(G);
  gens:=Concatenation([t],Filtered(gens,i->not IsIdenticalObj(i,t)));

  repeat
    t:=AugmentedCosetTableMtc(G,Subgroup(G,gens{[1]}), 1, "@" );
    if t.exponent=infinity then
      Error("<G> must be finite");
    fi;

    p:=List(t.cosetTable{[1,3..Length(t.cosetTable)-1]},PermList);

    H:= GroupByGenerators( p );
    # compute stabilizer chain with size info.
    StabChain(H,rec(limit:=t.exponent*Length(t.cosetTable)));

    gens:=gens{[2..Length(gens)]};
  until Size(H)=t.exponent*Length(t.cosetTable[1]) or Length(gens)=0;

  if Size(H)<t.exponent*Length(t.cosetTable[1]) then
    # we will need the regular action
    t:=CosetTableFromGensAndRels(FreeGeneratorsOfFpGroup(G),
				RelatorsOfFpGroup(G),[]:silent:=false);
    p:=List(t{[1,3..Length(t)-1]},PermList);
    H:= GroupByGenerators( p );
    SetSize(H,Length(t[1]));
  fi;

  p:=SmallerDegreePermutationRepresentation(H);
  # tell the family that we can now compare elements
  SetCanEasilyCompareElements(FamilyObj(One(G)),true);

  p:= GroupHomomorphismByImagesNC(G,Image(p),GeneratorsOfGroup(G),
			List(GeneratorsOfGroup(H),i->Image(p,i)));
  return p;
end);

InstallOtherMethod(IsomorphismPermGroup,"for family of fp words",true,
  [IsElementOfFpGroupFamily],0,
function(fam)
  # use the full group
  return IsomorphismPermGroup(CollectionsFamily(fam)!.wholeGroup);
end);

#############################################################################
##
#M  FactorCosetAction( <G>, <U> )
##
InstallMethod(FactorCosetAction,"for full fp group on subgroup",
  IsIdenticalObj,[IsSubgroupFpGroup and IsGroupOfFamily,IsSubgroupFpGroup],
  5,# we want this to be better than the method below for the subgroup in
    # quotient rep.
function(G,U)
local t;
  t:=CosetTableInWholeGroup(U);
  t:=List(t{[1,3..Length(t)-1]},PermList);
  return GroupHomomorphismByImagesNC( G, GroupByGenerators( t ),
                                      GeneratorsOfGroup( G ), t );
end);

InstallMethod(FactorCosetAction,"for subgroups of an fp group",
  IsIdenticalObj,[IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(G,U)
  return FactorCosetAction(G,AsSubgroupOfWholeGroupByQuotient(U));
end);

InstallMethod(FactorCosetAction,"subgrp in quotient Rep", IsIdenticalObj,
  [IsSubgroupFpGroup,
   IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep],0,
function(G,U)
local gens,q,h;
  # map the generators of G in the quotient
  gens:=GeneratorsOfGroup(G);
  gens:=List(gens,UnderlyingElement);
  q:=U!.quot;
  gens:=List(gens,i->MappedWord(i,FreeGeneratorsOfWholeGroup(U),
                                GeneratorsOfGroup(q)));
  h:=FactorCosetAction(SubgroupNC(q,gens),U!.sub);
  gens:=List(gens,i->ImagesRepresentative(h,i));
  return GroupHomomorphismByImagesNC( G, Range(h),
                                      GeneratorsOfGroup( G ), gens );
end);


#############################################################################
##
#F  SubgroupGeneratorsCosetTable(<freegens>,<fprels>,<table>)
##     determines subgroup generators from free generators, relators and
##     coset table. It returns elements of the free group!
##
InstallGlobalFunction( SubgroupGeneratorsCosetTable,
    function ( freegens, fprels, table )
    local   gens,               # generators for the subgroup
            rels,               # representatives for the relators
            relsGen,            # relators sorted by start generator
            deductions,         # deduction queue
            ded,                # index of current deduction in above
            nrdeds,             # current number of deductions in above
            nrgens,
            cos,                # loop variable for coset
            i, gen, inv,        # loop variables for generator
            g,                  # loop variable for generator col
            triple,             # loop variable for relators as triples
            app,                # arguments list for 'ApplyRel'
            x, y, c;

    nrgens := 2 * Length( freegens ) + 1;
    gens := [];

    table:=List(table,ShallowCopy);
    # make all entries in the table negative
    for cos  in [ 1 .. Length( table[1] ) ]  do
        for gen  in table  do
            if 0 < gen[cos]  then
                gen[cos] := -gen[cos];
            fi;
        od;
    od;

    # make the rows for the relators and distribute over relsGen
    rels := RelatorRepresentatives( fprels );
    relsGen := RelsSortedByStartGen( freegens, rels, table );

    # make the structure that is passed to 'ApplyRel'
    app := ListWithIdenticalEntries(4,0);

    # run over all the cosets
    cos := 1;
    while cos <= Length( table[1] )  do

        # run through all the rows and look for undefined entries
        for i  in [1..Length(freegens)]  do
            gen := table[2*i-1];

            if gen[cos] < 0  then

                inv := table[2*i];

                # make the Schreier generator for this entry
                x := One(freegens[1]);
                c := cos;
                while c <> 1  do
                    g := nrgens - 1;
                    y := nrgens - 1;
                    while 0 < g  do
                        if AbsInt(table[g][c]) <= AbsInt(table[y][c])  then
                            y := g;
                        fi;
                        g := g - 2;
                    od;
                    x := freegens[ y/2 ] * x;
                    c := AbsInt(table[y][c]);
                od;
                x := x * freegens[ i ];
                c := AbsInt( gen[ cos ] );
                while c <> 1  do
                    g := nrgens - 1;
                    y := nrgens - 1;
                    while 0 < g  do
                        if AbsInt(table[g][c]) <= AbsInt(table[y][c])  then
                            y := g;
                        fi;
                        g := g - 2;
                    od;
                    x := x * freegens[ y/2 ]^-1;
                    c := AbsInt(table[y][c]);
                od;
                if x <> One(x)  then
                    Add( gens, x );
                fi;

                # define a new coset
                gen[cos]   := - gen[cos];
                inv[ gen[cos] ] := cos;

                # set up the deduction queue and run over it until it's empty
                deductions := [ [i,cos] ];
                nrdeds := 1;
                ded := 1;
                while ded <= nrdeds  do

                    # apply all relators that start with this generator
                    for triple in relsGen[deductions[ded][1]] do
                        app[1] := triple[3];
                        app[2] := deductions[ded][2];
                        app[3] := -1;
                        app[4] := app[2];
                        if ApplyRel( app, triple[2] ) then
                            triple[2][app[1]][app[2]] := app[4];
                            triple[2][app[3]][app[4]] := app[2];
                            nrdeds := nrdeds + 1;
                            deductions[nrdeds] := [triple[1][app[1]],app[2]];
                        fi;
                    od;

                    ded := ded + 1;
                od;

            fi;
        od;

        cos := cos + 1;
    od;

    # return the generators
    return gens;
end );

#############################################################################
##
#M  IntermediateSubgroups(<G>,<U>)
##
InstallMethod(IntermediateSubgroups,"fp group via quotient subgroups",
  IsIdenticalObj, [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(G,U)
local A,B,Q,gens,int,i,fam;
  U:=AsSubgroupOfWholeGroupByQuotient(U);
  Q:=U!.quot;
  A:=U!.sub;
  # generators of G in permutation image
  gens:=List(GeneratorsOfGroup(G),elm->
    MappedWord(elm,FreeGeneratorsOfWholeGroup(U),GeneratorsOfGroup(Q)));
  B:=Subgroup(Q,gens);
  int:=IntermediateSubgroups(B,A);
  B:=[];
  fam:=FamilyObj(U);
  for i in int.subgroups do
    Add(B,SubgroupOfWholeGroupByQuotientSubgroup(fam,Q,i));
  od;
  return rec(subgroups:=B,inclusions:=int.inclusions);
end);

#############################################################################
##
#F  GQuotients(<F>,<G>)  . . . . . epimorphisms from F onto G up to conjugacy
##
InstallMethod(GQuotients,"whole fp group",true,
  [IsSubgroupFpGroup and IsWholeFamily,IsGroup and IsFinite],1,
function (F,G)
local Fgens,	# generators of F
      rels,	# power relations
      cl,	# classes of G
      e,	# excluded orders (for which the presentation collapses
      u,	# trial generating set's group
      pimgs,	# possible images
      val,	# its value
      i,	# loop
      h;	# epis

  Fgens:=GeneratorsOfGroup(F);

  if Length(Fgens)=0 then
    if Size(G)>1 then
      return [];
    else
      return [GroupHomomorphismByImagesNC(F,G,[],[])];
    fi;
  fi;

  if Size(G)=1 then
    return [GroupHomomorphismByImagesNC(F,G,Fgens,
			  List(Fgens,i->One(G)))];
  elif Length(Fgens)=1 then
    Info(InfoMorph,1,"Cyclic group: only one quotient possible");
    # a cyclic group has at most one quotient
    if not IsCyclic(G) then
      return [];
    else
      # get the cyclic gens
      h:=First(AsList(G),i->Order(i)=Size(G));
      # just map them
      return [GroupHomomorphismByImagesNC(F,G,Fgens,[h])];
    fi;
  fi;

  cl:=ConjugacyClasses(G);

  # search relators in only one generator
  rels:=ListWithIdenticalEntries(Length(Fgens),false);

  for i in RelatorsOfFpGroup(F) do
    u:=List([1..Length(i)],j->Subword(i,j,j));
    if Length(Set(u))=1 then
      # found relator in only one generator
      val:=Position(FreeGeneratorsOfFpGroup(F),u[1]);
      if val=fail then
	val:=Position(FreeGeneratorsOfFpGroup(F),u[1]^-1);
	if val=fail then Error();fi;
      fi;
      u:=Length(u);
      if rels[val]=false then
	rels[val]:=u;
      else
	rels[val]:=Gcd(rels[val],u);
      fi;
    fi;
  od;


  # exclude orders
  e:=Set(List(cl,i->Order(Representative(i))));
  e:=List(Fgens,i->ShallowCopy(e));
  for i in [1..Length(Fgens)] do
    if rels[i]<>false then
      e[i]:=Filtered(e[i],j->rels[i]<>j and IsInt(rels[i]/j));
    fi;
  od;
  e:=ExcludedOrders(F,e);

  # find potential images
  pimgs:=[];

  for i in [1..Length(Fgens)] do
    if rels[i]<>false then
      Info(InfoMorph,2,"generator order must divide ",rels[i]);
      u:=Filtered(cl,j->IsInt(rels[i]/Order(Representative(j))));
    else
      Info(InfoMorph,2,"no restriction on generator order");
      u:=ShallowCopy(cl);
    fi;
    u:=Filtered(u,j->not Order(Representative(j)) in e[i]);
    Add(pimgs,u);
  od;

  val:=Product(pimgs,i->Sum(i,Size));
  Info(InfoMorph,2,List(pimgs,Length)," possibilities, Value: ",val);

  h:=MorClassLoop(G,pimgs, rec(gens:=Fgens,to:=G,from:=F,
			       free:=FreeGeneratorsOfFpGroup(F),
                               rels:=List(RelatorsOfFpGroup(F),i->[i,1])),13);
  Info(InfoMorph,2,"Test kernels");
  cl:=[];
  u:=[];
  for i in h do
    if not KernelOfMultiplicativeGeneralMapping(i) in u then
      Add(u,KernelOfMultiplicativeGeneralMapping(i));
      Add(cl,i);
    fi;
  od;

  Info(InfoMorph,1,Length(h)," found -> ",Length(cl)," homs");
  return cl;
end);

InstallMethod(GQuotients,"subgroup of an fp group",true,
  [IsSubgroupFpGroup,IsGroup and IsFinite],1,
function (F,G)
local e,fpi;
  fpi:=IsomorphismFpGroup(F);
  e:=GQuotients(Range(fpi),G);
  return List(e,i->fpi*i);
end);

#############################################################################
##
#M  IsomorphismFpSemigroup( <G> )
##
##  for a finitely presented group.
##  Returns an isomorphism to a finitely presented semigroup.
##
InstallMethod(IsomorphismFpSemigroup,"for fp groups",
  true, [IsFpGroup], 0,
function(g)

  local i, rel,       # loop variable
        freegp,       # free group underlying g
				id,						# identity of free group
				nat,					# natural hom from free group to g
        gensfreegp,   # semigroup generators of the free group
        freesmg,      # free semigroup on the generators gensfreegp
        gensfreesmg,  # generators of freesmg
        idgen,        # identity generator
        newrels,      # relations
        rels,         # relators of g 
        smgrel,       # relators transformed into relation in the semigroup
        semi,         # fp semigroup  
        isomfun,      # the isomorphism function
        invfun,       # the inverse isomorphism function
        gpword2semiword, 
				smgword2gpword,			
				gens;

  ################################################
  # gpword2semiword
  # Change a word in the free group into a word
  # in the free semigroup. Just increment the generators
  # by one to shift past the identity generator
  ################################################
  gpword2semiword := function(id, w)
    local
        wlist,    # external rep of the word
        i;        # loop variable

    wlist := ShallowCopy(ExtRepOfObj(w));

    if Length(wlist) = 0 then # it is the identity
      return id;
    fi;

    for i in [1 .. Length(wlist)/2] do
      if wlist[2*i]<0 then
        wlist[2*i] := -1 * wlist[2*i];
        wlist[2*i-1] := 2 * wlist[2*i-1];
      else
        wlist[2*i-1] := 2 * wlist[2*i-1] + 1; 
      fi;
    od;
    return ObjByExtRep(FamilyObj(id), wlist);
  end;


	
	# this code courtesy of Chris Wensley
	smgword2gpword := function( id, w )
			local  wlist, i;
			wlist := ShallowCopy( ExtRepOfObj( w ) );
			if ( ( wlist = [ 1, 1 ] ) or ( Length( wlist ) = 0 ) ) then
					return id;
			fi;
			for i in [1..Length(wlist)/2] do
					if ( RemInt( wlist[2*i-1], 2 ) = 0 ) then
							wlist[2*i] := - wlist[2*i];
					fi;

					wlist[2*i-1] := QuoInt( wlist[2*i-1], 2 );
			od;
			return ObjByExtRep( FamilyObj( id ), wlist );
	end;
	



  # first we create the fp semigroup

  # get the free group underlying the fp group given
  freegp := FreeGroupOfFpGroup( g );
  # and get its semigroup generators 
  gensfreegp := GeneratorsOfSemigroup( freegp );  
  # the first generator is the identity so we disregard it
  # and we build the free monoid on the other generators
  freesmg := FreeSemigroup(gensfreegp{[1..Length(gensfreegp)]});
  
  # now give names to the generators of freesmg
  gensfreesmg := GeneratorsOfSemigroup( freesmg );
  idgen := gensfreesmg[1]; 

  # now relations that make the free smg into a group
  # first the ones concerning the identity
  newrels := [ [idgen*idgen,idgen] ];
  for i in [ 2 .. Length(gensfreesmg) ] do
    Add(newrels, [idgen*gensfreesmg[i], gensfreesmg[i]]);
    Add(newrels, [gensfreesmg[i]*idgen, gensfreesmg[i]]);
  od;

  # then relations gens * gens^-1 = idgen (and the other way around)
  for i in [2..Length(gensfreesmg)] do
    if IsOddInt( i ) then 
      Add( newrels, [gensfreesmg[i]*gensfreesmg[i-1],idgen]);
    else
      Add( newrels, [gensfreesmg[i]*gensfreesmg[i+1],idgen]);   
    fi;
  od;

  # now add the relations from the fp group to newrels
  # We have to transform relators into relations in the free semigroup
  # (in particular we have to transform the words in the free
  # group to words in the free semigroup)
  rels := RelatorsOfFpGroup( g );
  for rel in rels do
     smgrel:= [gpword2semiword(idgen, rel), idgen ]; 
     Add( newrels, smgrel );
  od;
  
  # finally create the fp semigroup
  semi := FactorFreeSemigroupByRelations( freesmg, newrels);
  gens := GeneratorsOfSemigroup( semi );

  isomfun := x -> ElementOfFpSemigroup( FamilyObj(gens[1] ), 
                  gpword2semiword( idgen, x ));

	# Further addition from Chris Wensley
	id := One( freegp );
	nat := GroupHomomorphismByImages( freegp, g, GeneratorsOfGroup( freegp ),
																						 GeneratorsOfGroup( g ) );
	invfun := x -> Image( nat, smgword2gpword( id, UnderlyingElement( x ) ) );
	# CW - end
  
  return MagmaIsomorphismByFunctionsNC(g, semi, isomfun, invfun);

end);

#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod(ViewObj,"fp group",true,[IsSubgroupFpGroup],
 10,# to override the pure `Size' method
function(G)
  if IsFreeGroup(G) then TryNextMethod();fi;
  if IsGroupOfFamily(G) then
    Print("<fp group");
    if HasSize(G) then
      Print(" of size ",Size(G));
    fi;
    if Length(GeneratorsOfGroup(G))>VIEWLEN*10 then
      Print(" with ",Length(GeneratorsOfGroup(G))," generators>");
    else
      Print(" on the generators ",GeneratorsOfGroup(G),">");
    fi;
  else
    Print("Group(");
    if HasGeneratorsOfGroup(G) then
      if not IsBound(G!.gensWordLengthSum) then
	G!.gensWordLengthSum:=Sum(List(GeneratorsOfGroup(G),
	         i->Length(UnderlyingElement(i))));
      fi;
      if G!.gensWordLengthSum<=VIEWLEN*30 then
        Print(GeneratorsOfGroup(G));
      else
        Print("<",Length(GeneratorsOfGroup(G))," generators>");
      fi;
    else
      Print("<fp, no generators known>");
    fi;
    Print(")");
  fi;
end);

#############################################################################
##
#M  ExcludedOrders(<G>)
##
InstallMethod(StoredExcludedOrders,"fp group",true,
  [IsSubgroupFpGroup and
  # for each gen: first entry: excluded orders, second: tested orders
  # (superset)
  IsGroupOfFamily],0,G->List(GeneratorsOfGroup(G),x->[[],[]]));

InstallGlobalFunction(ExcludedOrders,
function(arg)
local f,a,i,j,gens,tstord,excl,p,s;
  f:=arg[1];
  s:=StoredExcludedOrders(f);
  gens:=FreeGeneratorsOfFpGroup(f);
  if Length(arg)>1 then
    tstord:=List(arg[2],ShallowCopy);
  else
    tstord:=List(gens,i->[1]);
    for i in RelatorsOfFpGroup(f) do
      for j in [1..NumberSyllables(i)] do
	a:=AbsInt(ExponentSyllable(i,j));
	if a>1 then
	  UniteSet(tstord[GeneratorSyllable(i,j)],DivisorsInt(a));
	fi;
      od;
    od;
  fi;

  # take those orders we know already to be true
  excl:=List([1..Length(gens)],i->ShallowCopy(Intersection(tstord[i],s[i][1])));

  for i in [1..Length(tstord)] do
    # remove orders which have been tested once
    tstord[i]:=Difference(tstord[i],s[i][2]);
  od;

  for i in [1..Length(gens)] do
    for j in Reversed(tstord[i]) do
      AddSet(s[i][2],j);
      if ForAny(excl[i],k->IsInt(k/j)) then
        # we know it even with a power => is true
        AddSet(excl[i],j);
	AddSet(s[i][1],j);
      else
	p:=PresentationFpGroup(f,0);
	AddRelator(p,p!.generators[i]^j);
	TzGoGo(p);
	if Length(p!.generators)=0 then
	  AddSet(excl[i],j);
	  AddSet(s[i][1],j);
	else
	  if i=1 then
	    a:=[gens[2]];
	  else
	    a:=[gens[1]];
	  fi;
	  a:=CosetTableFromGensAndRels(gens,
	       Concatenation(RelatorsOfFpGroup(f),[gens[i]^j]),a:
	       max:=15999,silent);
	  if IsList(a) and Length(a[1])=1 and
	     # now we can try the size
	     Size(FpGroupPresentation(p))=1 then
	    AddSet(excl[i],j);
	    AddSet(s[i][1],j);
	  fi;
	fi;
      fi;
    od;
  od;
  return excl;
end);


#############################################################################
##
#M  IsConjugatorIsomorphism( <hom> )
##
InstallMethod( IsConjugatorIsomorphism,
    "for a f.p. group general mapping",
    true,
    [ IsGroupGeneralMapping ], 1,
    # There is no filter to test whether source and range of a homomorphism
    # are f.p. groups.
    # So we have to test explicitly and make this method
    # higher ranking than the default one in `ghom.gi'.
    function( hom )

    local s, r, G, genss, rep;

    s:= Source( hom );
    if not IsSubgroupFpGroup( s ) then
      TryNextMethod();
    elif not ( IsGroupHomomorphism( hom ) and IsBijective( hom ) ) then
      return false;
    elif IsEndoGeneralMapping( hom ) and IsInnerAutomorphism( hom ) then
      return true;
    fi;
    r:= Range( hom );

    # Check whether source and range are in the same family.
    if FamilyObj( s ) <> FamilyObj( r ) then
      return false;
    fi;

    # Compute a conjugator in the full f.p. group.
    G:= FamilyObj( s )!.wholeGroup;
    genss:= GeneratorsOfGroup( s );
    rep:= RepresentativeAction( G, genss, List( genss,
                    i -> ImagesRepresentative( hom, i ) ), OnTuples );

    # Return the result.
    if rep <> fail then
      Assert( 1, ForAll( genss, i -> Image( hom, i ) = i^rep ) );
      SetConjugatorOfConjugatorIsomorphism( hom, rep );
      return true;
    else
      return false;
    fi;
    end );


#############################################################################
##
#E
