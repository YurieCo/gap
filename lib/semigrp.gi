#############################################################################
##
#W  semigrp.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains generic methods for semigroups.
##
Revision.semigrp_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  PrintObj( <S> ) . . . . . . . . . . . . . . . . . . . . print a semigroup
##
InstallMethod( PrintObj,
    "for a semigroup",
    true,
    [ IsSemigroup ], 0,
    function( S )
    Print( "Semigroup( ... )" );
    end );

InstallMethod( PrintObj,
    "for a semigroup with known generators",
    true,
    [ IsSemigroup and HasGeneratorsOfMagma ], 0,
    function( S )
    Print( "Semigroup( ", GeneratorsOfMagma( S ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <S> )  . . . . . . . . . . . . . . . . . . . .  view a semigroup
##
InstallMethod( ViewObj,
    "for a semigroup",
    true,
    [ IsSemigroup ], 0,
    function( S )
    Print( "<semigroup>" );
    end );

InstallMethod( ViewObj,
    "for a semigroup with generators",
    true,
    [ IsSemigroup and HasGeneratorsOfMagma ], 0,
    function( S )
	if Length(GeneratorsOfMagma(S)) = 1 then
	    Print( "<semigroup with ", Length( GeneratorsOfMagma( S ) ),
           " generator>" );
	else
	    Print( "<semigroup with ", Length( GeneratorsOfMagma( S ) ),
           " generators>" );
	fi;
    end );


#############################################################################
##
#M  SemigroupByGenerators( <gens> ) . . . . . . semigroup generated by <gens>
##
InstallMethod( SemigroupByGenerators,
    "for a collection",
    true,
    [ IsCollection ], 0,
    function( gens )
    local S;
    S:= Objectify( NewType( FamilyObj( gens ),
                            IsSemigroup and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagma( S, AsList( gens ) );
		
    return S;
    end );


#############################################################################
##
#M  AsSemigroup( <D> ) . . . . . . . . . . .  domain <D>, viewed as semigroup
##
InstallMethod( AsSemigroup,
    "for a semigroup",
    true,
    [ IsSemigroup ], 100,
    IdFunc );

InstallMethod( AsSemigroup,
    "generic method for collections",
    true,
    [ IsCollection ], 0,
    function ( D )
    local   S,  L;

    D := AsSSortedList( D );
    L := ShallowCopy( D );
    S := Submagma( SemigroupByGenerators( D ), [] );
    SubtractSet( L, AsSSortedList( S ) );
    while not IsEmpty(L)  do
        S := ClosureMagmaDefault( S, L[1] );
        SubtractSet( L, AsSSortedList( S ) );
    od;
    if Length( AsSSortedList( S ) ) <> Length( D )  then
        return fail;
    fi;
    S := SemigroupByGenerators( GeneratorsOfSemigroup( S ) );
    SetAsSSortedList( S, D );
    SetIsFinite( S, true );
    SetSize( S, Length( D ) );

    # return the semigroup
    return S;
    end );


#############################################################################
##
#F  Semigroup( <gen>, ... ) . . . . . . . . semigroup generated by collection
#F  Semigroup( <gens> ) . . . . . . . . . . semigroup generated by collection
##
InstallGlobalFunction( Semigroup, function( arg )

    # special case for matrices, because they may look like lists
    if Length( arg ) = 1 and IsMatrix( arg[1] ) then
      return SemigroupByGenerators( [ arg[1] ] );

    # list of generators
    elif Length( arg ) = 1 and IsList( arg[1] ) and 0 < Length( arg[1] ) then
      return SemigroupByGenerators( arg[1] );

    # generators
    elif 0 < Length( arg ) then
      return SemigroupByGenerators( arg );

    # no argument given, error
    else
      Error("usage: Semigroup(<gen>,...),Semigroup(<gens>),Semigroup(<D>)");
    fi;
end );


#############################################################################
##                                                        
#M  AsSubsemigroup( <G>, <U> )    
##     
InstallMethod( AsSubsemigroup,
    "generic method for a domain and a collection",
    IsIdenticalObj,               
    [ IsDomain, IsCollection ], 0,                                   
    function( G, U )
    local S;
    if not IsSubset( G, U ) then
      return fail;
    fi;
    if IsMagma( U ) then
      if not IsAssociative( U ) then
        return fail;
      fi;
      S:= SubsemigroupNC( G, GeneratorsOfMagma( U ) );
    else
      S:= SubmagmaNC( G, AsList( U ) );
      if not IsAssociative( S ) then
        return fail;
      fi;
    fi;
    UseIsomorphismRelation( U, S );
    UseSubsetRelation( U, S );
    return S;
    end );

#############################################################################
##
#M	Enumerator( <S> )
#M	Enumerator( <S> : Side:= "left" )
#M	Enumerator( <S> : Size:= "right")
##
##	Creates a naive semigroup enumerator.   By default this enumerates the
##	right semigroup ideal of the set of generators.   This is the same as
##	the third form.
##
##	In the second form it enumerates the left semigroup ideal generated by
##	the semigroup generators.
##
InstallMethod( Enumerator, "for a generic semigroup", true,
	[IsSemigroup and HasGeneratorsOfSemigroup], 0,
function(S)

	# NOTE.   Since we are considering a semigroup enumeration as being
	# an enumeration of the ideal generated by the semigroup generators,
	# we want the attribute setters for ideal code to affect the semigroup.
	# Thus, at this stage we set IsRightSemigroupIdeal for the semigroup
	# to be true, and GeneratorsOfRightMagmaIdeal to the semigroup
	# generators.   Finally, S is set to be its own parent.

	if ValueOption("Side") = "left" then
		SetIsLeftSemigroupIdeal(S, true);
		SetGeneratorsOfLeftMagmaIdeal(S, GeneratorsOfSemigroup(S));
		SetParent(S, S);
		return Enumerator(S);	# we already have methods for ideals.
	fi;
	SetIsRightSemigroupIdeal(S, true);
	SetGeneratorsOfRightMagmaIdeal(S, GeneratorsOfSemigroup(S));
	SetParent(S, S);
	return Enumerator(S);	# we already have methods for ideals.
end);


#############################################################################
##
#M  IsSimpleSemigroup( <S> )
##
##  for a group.
##
##	All groups are simple semigroups. Returns true.
##
InstallMethod(IsSimpleSemigroup,
  "for a group",
  true,
  [ IsGroup], 0,
  s->true);	

#############################################################################
##
#M  IsSimpleSemigroup( <S> )
##
##  for a trivial semigroup.
##
##  A trivial semigroup is a simple semigroup. Returns true.
##
InstallMethod(IsSimpleSemigroup, "for a trivial semigroup", true,
  [ IsSemigroup and IsTrivial], 0, s->true);

#############################################################################
##
#M 	IsSimpleSemigroup( <S> )
##
##	for semigroup which has generators.
##
##	In such a case the semigroup is simple iff all generators are
##	Greens J less than or equal to any element of the semigroup.
##
##	Proof: 
##	(->) Suppose <S> is simple; equivalently this means than
##	for all element <t> of <S>, <StS=S>. So let <t> be an
##	arbitrary element of <S> and let <x> be any generator of <S>.
##	Then $S^1xS^1 \subseteq S = StS \subseteq S^1tS^1$ and this
##	means that <x> is J less than or equal to t.
##
##	(<-) Conversely. 
##	Recall that <S> simple is equivalent to J being
##	the universal relation in <S>. So that is what we have to proof.
##	All elements of the semigroup are J less than or equal to the generators
##	since they are products of generators. But since by the condition
##	given all generators are less than or equal to all other elements 
##	it follows that all elements of the semigroup are J related, and 
##	hence J is universal.
##	QED
##
##	In order to apply the above result we are going to check that
##	one of the generators is J-minimal and that all other generators are
##	J-less than or equal to  that first generator.
##
##	It returns true if the semigroup is finite and is simple.
##	It returns false if the semigroup is not simple and is finite.
##	It might return false if the semigroup is not simple and infinite.
##	It does not terminate if the semigroup although simple, is infinite
##
InstallMethod(IsSimpleSemigroup, 
	"for semigroup with generators",
	true,
	[ IsSemigroup and HasGeneratorsOfSemigroup], 0,
function(s)
	local it,				# the iterator of the semigroup s 
				t,				# an element of the semigroup
				J,				# Greens J relation of the semigroup
				gens,			# a set of generators of the semigroup
				a,				# a generator
				i,				# loop variable
				jt,ja,jx;	# J classes

	# the iterator, the J-relation and a generating set for the semigroup
	it:=Iterator(s);
	J:=GreensJRelation(s);
	gens:=GeneratorsOfSemigroup(s);

	# pick a generator, gens[1], and build its J class
  jx:=EquivalenceClassOfElementNC(J,gens[1]);

	# check whether gens[1] is J less than or equal to all other els of the smg
	while not(IsDoneIterator(it)) do
		# pick the next element of the semigroup 
		t:=NextIterator(it);
		# if gens[1] is not J-less than or equal to t then S is not simple
		jt:=EquivalenceClassOfElementNC(J,t);
		if not(IsGreensLessThanOrEqual(jx,jt)) then
    	return false;
    fi;
  od;

	# notice that the above cycle only terminates without returning false
	# when the semigroup is finite

	# now check whether all other generators are J less than or equal
	# the first one. No need to compare with first one (itself), so start in the 
	# second one. Also, no need to compare with any other generator equal
	# to first one
	i:=2;
	while i in [1..Length(gens)] do
		a:=gens[i];
		ja:=EquivalenceClassOfElementNC(J,a);
		if not(IsGreensLessThanOrEqual(ja,jx)) then
			return false;
		fi;
		i:=i+1;
	od;

	# hence the semigroup is simple
	return true;

end);		

#############################################################################
##
#M  IsSimpleSemigroup( <S> )
##
##	for a semigroup which has a MultiplicativeNeutralElement.
##	
##	In this case is enough to show that the MultiplicativeNeutralElement 
##	is J-less than or equal to all other elements.
##	This is because a MultiplicativeNeutralElement is J greater than or
##	equal to any other element and hence by showing that is less than
##	or equal any other element it follows that J is universal, and
##	therefore the semigroup <S> is simple. 
##
##	If the semigroup is finite it returns true if the semigroup is
##	simple and false otherwise.
##	If the semigroup is infinite and simple it does not terminate. It
##	might terminate and return false if the semigroup is not simple.
##
InstallMethod( IsSimpleSemigroup,
  "for a semigroup with a MultiplicativeNeutralElement",
  true,
  [ IsSemigroup and HasMultiplicativeNeutralElement ], 0,
function(s)

	local it,					# the iterator of the semigroup S 
				J,					# Green's J relation on the semigroup
				jn,jt,			# J-classes
				t,					# an element of the semigroup
				neutral;		# the MultiplicativeNeutralElement of s

	# the iterator and the J-relation on S
	it:=Iterator(s);
	J:=GreensJRelation(s);

	# the multiplicative neutral element and its J class
	neutral:=MultiplicativeNeutralElement(s);
  jn:=EquivalenceClassOfElementNC(J,neutral);

	while not(IsDoneIterator(it)) do
		t:=NextIterator(it);
    jt:=EquivalenceClassOfElementNC(J,t);
		# if neutral is not J less than or equal to t then S is not simple
    if not(IsGreensLessThanOrEqual(jn,jt)) then
      return false;
    fi;
  od;

	# notice that the above cycle only terminates without returning
	# false if the semigroup is finite

	# hence s is simple
	return true;

end);	

#############################################################################
##      
#M  IsSimpleSemigroup( <S> )
##
##  for a semigroup.
##	This is the general case for a semigroup.
##	
##	A semigroup is simple iff J is the universal relation in S.
##	So we are going to fix a J class and look throught the semigroup
##	to check whether there are other J-classes.
##
##	It returns false if it finds a new J-class.
##	It returns true if is finite and only finds one J-class.
##	It does not terminate if simple but infinite.
##
InstallMethod(IsSimpleSemigroup,
  "for a semigroup",
  true,
  [ IsSemigroup ], 0,
function(s)
	local it,				# the iterator of the semigroup s 
				J,				# J relation on s
				a,b,			# elements of the semigroup
				ja,jb;		# J-classes
	
	# the J-relation on s and the iterator of s
	J:=GreensJRelation(s);
	it:=Iterator(s);

	# pick an element of the semigroup
	a:=NextIterator(it);
	# and build its J class
	ja:=EquivalenceClassOfElementNC(J,a);

	# if IsDoneIterator(it) it means that the semigroup is trivial, and hence simple
	if IsDoneIterator(it) then
		return true;
	fi;

	# look through all elements of s
	# to find out if there are more J classes
	while not(IsDoneIterator(it)) do
		b:=NextIterator(it);
		jb:=EquivalenceClassOfElementNC(J,b);
		# if a and b are not in the same J class then the smg is not simple
		if not(IsGreensLessThanOrEqual(ja,jb)) then
			return false;
		elif not (IsGreensLessThanOrEqual(jb,ja)) then
			return false;
		fi;
	od;

	# notice that the above cycle only terminates without returning
	# false if the semigroup is finite

	# hence the semigroup is simple
	return true;

end);

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> )
##
##  for a zero group.
##
##  All groups are simple semigroups. Hence all zero groups are 0-simple. 
##
InstallMethod(IsZeroSimpleSemigroup,
  "for a ZeroGroup",
  true,
  [ IsZeroGroup], 0,
  function(s) return true; end);

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> )
##
##  for a group.
##
##  A group is not a zero simple semigroup because does not have a zero. 
##
InstallMethod(IsZeroSimpleSemigroup,
  "for a ZeroGroup",
  true,
  [ IsGroup], 0,
  function(s) return false; end);

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> )
##
##  for a trivial semigroup.
##
##  a trivial semigroup is not 0 simple, since S^2=0
##	Moreover is not representable by a Rees Matrix semigroup
##	over a zero group (which has at least two elements)
##
InstallMethod(IsZeroSimpleSemigroup, "for a trivial semigroup", true,
  [ IsSemigroup and IsTrivial], 0, s->false);

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> )
##
##  for a semigroup which has generators.
##
##  In such a case if the semigroup has more than two elements it is 
##	0-simple iff 
##	 (i) <S^2> is non equal to the singleton set consisting of zero; and 
##	(ii) all generators are Greens J less than or equal to any non zero 
##			 element of the semigroup.
##	If the semigroup has exactly two elements then it is simple
##	iff the square of the nonzero element is nonzero
##	Is the semigroup has only one element then it is not 0-simple.
##
##  Proof: 
##  The last sentence, about a semigroup with only two elements is obvious.	
##
##	So suppose <S> has more than two elements. 
##	(->) Suppose <S> is 0-simple; 
##	Equivalently this means than for all non zero element <t> of <S>, 
##	<StS=S>. 
##	So let <t> be a nonzero arbitrary element of <S> and let <x> be 
##	any generator of <S>.
##  Then $S^1xS^1 \subseteq S = StS \subseteq S^1tS^1$ and this
##  means that <x> is J less than or equal to t.
##	Condition (i) follows from the definition of being 0-simple.
##  
##	(<-) Conversely. 
##	Recall that <S> 0-simple is equivalent to J 
##	having has equivalence classes <S\0> and 0 itself, and <S^2> nonzero. 
##  So that is what we have to proof. 
##	That <S^2> is not equal to zero is immediate.
##  Now, all nonzero elements of the semigroup are J less than or equal 
##	the generators since they are products of generators. 
##	But since by condition (ii) all generators are J-less than or equal 
##	all other nonzero elements it follows that all non-zero elements of the 
##	semigroup are J related, and hence J has only two classes. QED 
##
##	To check that (ii) holds is enough to show that one of the generators
##	is J less than or equal to every other non zero element of <S>  and 
##	then show that all other generators are J-less than or equal to that
##	generator.
##
InstallMethod(IsZeroSimpleSemigroup,
  "for a semigroup with generators",
  true,
  [ IsSemigroup and HasGeneratorsOfSemigroup ], 
	0,
function(s)
  local e,      	# enumerator for the semigroup s 
				gens,			# a set of generators of the semigroup
				x,				# a non zero generators of s
				zero,			# the multiplicative zero of the semigroup
				nonzero,	# nonzero element of s in case s has two elements
        J,        # Greens J relation of the semigroup
        a,        # a generator
				i,j,			# loop variables
        jx,jt,ja; # J classes

	# the enumerator, the set of generators and the zero for s 
  e:=Enumerator(s);

	# if e[2] is not bound then s is trivial, hence is not 0 simple
	if not (IsBound(e[2])) then 
		return false;
	fi;

	zero:=MultiplicativeZero(s);
	# next check that if S has two elements, whether the square of the
	# nonzero one is nonzero 
	# If all squares are zero then the semigroup is not 0-simple
	if not(IsBound(e[3])) then
		if e[1]<>zero then
			nonzero:=e[1];
		else
			nonzero:=e[2];
		fi;
	  if nonzero^2=zero then
			# then this means that S^2 is the zero set, and hence
			# S is not 0-simple
			return false;
		else
			# S is 0-simple
			return true;
		fi;
	fi;	

	# otherwise if the semigroup has more than 2 els, start by 
	# fixing a generator;
	# we know that there is a nonzero generator as there are at least 
	# three elements in S, so we look for such a generator
  gens:=GeneratorsOfSemigroup(s);
	x:=zero;
	i:=1;
	while ( x=zero and (i in [1..Length(gens)]) ) do
		if gens[i]<>zero then
			x:=gens[i];
		fi;
		i:=i+1;
	od;
	
	# and check that x is J less than or equal to every other nonzero
	# element of the semigroup 
	# Notice that x is at this point gens[i-1]
  J:=GreensJRelation(s);
  jx:=EquivalenceClassOfElementNC(J,x);
	j:=1;
	while IsBound(e[j]) do
		if e[j]<>zero then
    	jt:=EquivalenceClassOfElementNC(J,e[j]);
	    if not(IsGreensLessThanOrEqual(jx,jt)) then
  	    return false;
    	fi;
		fi;
		j:=j+1;
  od;

	# notice that if we arrive here is because the semigroup is
	# finite for otherwise the above cycle does not stop
	# (unless the semigroup is not simple, when it ends returning false)

	# the last thing we have to check is that all other
	# nonzero generators are J less than or equal to x
	# Recall that from the way we have found x, x is gen[i-1] and
	# all previous gens are zero
	# So we can start comparing x from gens[i] onwards 
	while i<=Length(gens) do 
		a:=gens[i];
		if a<>zero then 
	    ja:=EquivalenceClassOfElementNC(J,a);
  	  if not(IsGreensLessThanOrEqual(ja,jx)) then
    	  return false;
	    fi;
		fi;
		i:=i+1;
 	od;

  return true;

end);

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> )
##
##  for a semigroup with zero which has a MultiplicativeNeutralElement.
##
##  In this case is enough to show that the MultiplicativeNeutralElement
##  is J-less than or equal to all other non-zero elements of S and
##	that if S has only two elements, s^2 is non zero.
##  This is because a MultiplicativeNeutralElement is J greater than or
##  equal to any other element and hence by showing that is less than
##  or equal any other element it follows that J is universal, and
##  therefore the semigroup <S> is simple.
##
##	This time if the semigroup only has two elements than it
##	is simple since for sure the square of the Neutral Element
##	is itself, and hence is non-zero
##
InstallMethod( IsZeroSimpleSemigroup,
  "for a semigroup with a MultiplicativeNeutralElement",
  true,
  [ IsSemigroup and HasMultiplicativeNeutralElement ],
 	0,
function(s)

  local e,        	# the enumerator of the semigroup s 
        J,          # Green's J relation on the semigroup
        jn,ji,      # J-classes
				zero,				# the zero element of s
				i,					# loop variable
        neutral;    # the MultiplicativeNeutralElement of s

  e:=Enumerator(s);

 	# the trivial semigroup is not 0-simple
  if not(IsBound(e[2])) then
    return false;
  fi;

	# as remarked above, if the semigroup has a neutral element then
	# if it has two elements it is simple
	if not(IsBound(e[3])) then
		return true;
	fi;

  neutral:=MultiplicativeNeutralElement(s);
	zero:=MultiplicativeZero(s);
  J:=GreensJRelation(s);
  jn:=EquivalenceClassOfElementNC(J,neutral);
	i:=1;
	while IsBound(e[i]) do
		if e[i]<>zero then
    	ji:=EquivalenceClassOfElementNC(J,e[i]);
    	if not(IsGreensLessThanOrEqual(jn,ji)) then
      	return false;
    	fi;
		fi;
		i:=i+1;
  od;

  return true;
end);

#############################################################################
##     
#M  IsZeroSimpleSemigroup( <S> )
##
##  for a semigroup with a zero.
##  This is the general case for a semigroup with a zero.
##
##  A semigroup is 0-simple iff 
##	(i) S has two elements and S^2<>0
##	(ii) S has more than two elements and its only J classes are
##			 S-0 and 0	
##
##	So, in the case when we have at least three elements we are going
##  to fix a non-zero J class and look throught the semigroup
##  to check whether there are other non-zero J-classes.
##
##  It returns false if it finds a new non-zero J-class, ie, smg is
##	not 0-simple.
##  It returns true if is finite and only finds one nonzero J-class,
##	that is, the semigroup is 0-simple.
##  It does not terminate if 0-simple but infinite.
##
InstallMethod(IsZeroSimpleSemigroup,
  "for a semigroup",
  true,
  [ IsSemigroup ], 0,
function(s)

  local e,       	# the enumerator of the semigroup s
				zero,			# the multiplicative zero of the semigroup
				nonzero,	# the nonzero el of a semigroup with two elements
        J,        # J relation on s
        b,      # elements of the semigroup
				i,				# loop variable
        ja,jb;    # J-classes

  # the enumerator and the multiplicative zero of s 
  e:=Enumerator(s);
	zero:=MultiplicativeZero(s);

  # the trivial semigroup is not 0-simple
  if not(IsBound(e[2])) then
    return false;
  fi;

  # next check that if S has two elements, whether the square of the
  # nonzero one is nonzero
  if not(IsBound(e[3])) then
    if e[1]<>zero then
      nonzero:=e[1];
    else
      nonzero:=e[2];
    fi;
    if nonzero^2=zero then
      # then this means that S^2 is the zero set, and hence
      # S is not 0-simple
      return false;
    else
      # S is 0-simple
      return true;
    fi;
  fi;

	# so by now we know that s has at least three elements	

	# the J relation on s
  J:=GreensJRelation(s);

	# look for the first non zero element and build its J class
	if e[1]<>zero then
		ja:=EquivalenceClassOfElementNC(J,e[1]);
	else
		ja:=EquivalenceClassOfElementNC(J,e[2]);
	fi;
	
  # look through all nonzero elements of s
  # to find out if there are more nonzero J classes
	# We do not have to start looking from the fisrt one, since the first
	# one is either zero or else is the element we started with.
	# In the case the first one is zero we can start looking by the 3rd one.
	if e[1]=zero then
		i:=3;
	else
		i:=2;
	fi;

  while IsBound(e[i]) do
    b:=e[i];
		if b<>zero then
	    jb:=EquivalenceClassOfElementNC(J,b);
  	  # if ja and jb are not the same J class then the smg is not simple
    	if not(IsGreensLessThanOrEqual(ja,jb)) then
      	return false;
	    elif not (IsGreensLessThanOrEqual(jb,ja)) then
  	    return false;
    	fi;
		fi;
		i:=i+1;
  od;

  # notice that the above cycle only terminates without returning
  # false if the semigroup is finite

  # hence the semigroup is 0-simple
  return true;

end);


############################################################################
##
#A  ANonReesCongruenceOfSemigroup( <S> )
##
##  for a finite semigroup <S>.
##
##  In this case the following holds:
##  Proposition (A.Solomon): S is Rees Congruence <->
##                           Every congruence generated by a pair is Rees.
##  Proof: -> is immediate.
##        <- Let \rho be some non-Rees congruence in S.
##  Let [a] and [b] be distinct nontrivial congruence classes of \rho.
##  Let a, a' \in [a]. By assumption, the congruence generated
##  by the pair (a, a') is a Rees congruence.
##  Thus, since the kernel K is contained
##  in the nontrivial congruence class of <(a,a')>, and similarly K is contained
##  in the nontrivial congruence class of <(b,b')> for any b, b' \in [b]. Thus
##  we must have that (a,b) \in \rho, contradicting the assumption. \QED
##
##  So, to find a non rees congruence we only have to look within the
##  congruences generated by a pair of elements of <S>. If all
##  of these are Rees it menas that there are no Non-rees congruences.
##
##  This method returns a non rees congruence if it exists and
##  fail otherwise
##
##  So we look through all possible pairs of elements of s.
##  We do this by using an iterator for N times N.
##  Notice that for this iterator IsDoneIterator is always false,
##  since there are always a next element in N times N.
##
InstallMethod( ANonReesCongruenceOfSemigroup,
    "for a semigroup",
    true,
    [IsSemigroup and IsFinite], 0,
function( s )
	local e,x,y,i,j;

  e := EnumeratorSorted(s);
  for i in [1 .. Length(e)] do
    for j in [i+1 .. Length(e)] do
      x := e[i];
      y := e[j];
      if not IsReesCongruence( SemigroupCongruenceByGeneratingPairs(s, [[x,y]])) then
        return SemigroupCongruenceByGeneratingPairs(s, [[x,y]]);
      fi;
    od;
  od;
  return fail;
end);

RedispatchOnCondition( ANonReesCongruenceOfSemigroup,
	true, [IsSemigroup], [IsFinite], 0);

############################################################################
##
#P  IsReesCongruenceSemigroup( <S> )
##
InstallMethod( IsReesCongruenceSemigroup,
    "for a (possibly infinite) semigroup",
    true,
    [ IsSemigroup], 0,
function( s )
  local nonreescong;

  nonreescong:=ANonReesCongruenceOfSemigroup(s);
  return nonreescong=fail;
 
end);
 

#############################################################################
##
#O  HomomorphismFactorSemigroup( <S>, <C> )
#O  HomomorphismFactorSemigroupByClosure( <S>, <L> )
#O  FactorSemigroup( <S>, <C> )
#O  FactorSemigroupByClosure( <S>, <L> )
##
##  In the first form <C> is a congruence and HomomorphismFactorSemigroup,
##  returns a homomorphism $<S> \rightarrow <S>/<C>
##
##  This is the only one which should do any work and is installed
##  in all the appropriate places.
##
##  All implementations of \/ should be done in terms of the above 
##  four operations.
##

InstallMethod( HomomorphismFactorSemigroupByClosure,
	"for a semigroup and generating pairs of a congruence",
	IsElmsColls,
  [ IsSemigroup, IsList ], 0,
function(s, l)
	return HomomorphismFactorSemigroup(s, 
		SemigroupCongruenceByGeneratingPairs(s,l) );
end);


InstallMethod( HomomorphismFactorSemigroupByClosure,
	"for a semigroup and empty list",
	true,
  [ IsSemigroup, IsList and IsEmpty ], 0,
function(s, l)
	return HomomorphismFactorSemigroup(s, 
		SemigroupCongruenceByGeneratingPairs(s,l) );
end);

InstallMethod( FactorSemigroup,
	"for a semigroup and a congruence",
	true,
  [ IsSemigroup, IsSemigroupCongruence ],  0,
function(s, c) 
	if not s = Source(c) then
    TryNextMethod();
  fi;

  return Range(HomomorphismFactorSemigroup(s, c));
end);

InstallMethod( FactorSemigroupByClosure,
  "for a semigroup and generating pairs of a congruence",
  IsElmsColls,
  [ IsSemigroup, IsList ], 0,
function(s, l) 
  return Range(HomomorphismFactorSemigroup(s, 
    SemigroupCongruenceByGeneratingPairs(s,l) ));
end);


InstallMethod( FactorSemigroupByClosure,
  "for a semigroup and empty list",
  true,
  [ IsSemigroup, IsEmpty  and IsList], 0,
function(s, l) 
  return Range(HomomorphismFactorSemigroup(s, 
    SemigroupCongruenceByGeneratingPairs(s,l) ));
end);

#############################################################################
##
#M  \/( <s>, <rels> ) . . . .  for semigroup and empty list 
##
InstallOtherMethod( \/,
    "for a semigroup and an empty list",
    true,
    [ IsSemigroup, IsEmpty ],
    0,
    FactorSemigroupByClosure );

#############################################################################
##
#M  \/( <s>, <rels> ) . . . .  for semigroup and list of pairs of elements
##
InstallOtherMethod( \/,
    "for semigroup and list of pairs",
    IsElmsColls,
    [ IsSemigroup, IsList ],
    0,
    FactorSemigroupByClosure );

#############################################################################
##
#M  \/( <s>, <cong> ) . . . .  for semigroup and congruence
##
InstallOtherMethod( \/,
    "for a semigroup and a congruence",
    true,
    [ IsSemigroup, IsSemigroupCongruence ],
    0,
    FactorSemigroup );

#############################################################################
##
#M  IsRegularSemigroupElement( <S>, <x> )
##
##  A semigroup element is regular if and only if its DClass is regular,
##  which in turn is regular if and only if every R and L class contains
##  an idempotent.   In the generic case, therefore, we iterate over an
##  elements R class, and look for idempotents.
##
InstallMethod(IsRegularSemigroupElement, "for generic semigroup", 
    IsCollsElms, [IsSemigroup, IsAssociativeElement], 0,
function(S, x)
    local r, i;

    if not x in S then
        return false;
    fi;

    r:= EquivalenceClassOfElementNC(GreensRRelation(S), x);
    for i in Iterator(r) do
        if i*i=i then
            # we have found an idempotent.
            return true;
        fi;
    od;

    # no idempotents in R class implies not regular.
    return false;
end);

#############################################################################
##
#M  IsRegularSemigroup( <S> )
##
InstallMethod(IsRegularSemigroup, "for generic semigroup", true,
    [IsSemigroup], 0,
        S->ForAll(GreensDClasses(S), IsRegularDClass));

#############################################################################
##
#E
