#############################################################################
##
#W  fldabnum.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares operations for fields consisting of cyclotomics.
##
##  Note that we must distinguish abelian number fields and fields
##  that consist of cyclotomics.
##  (The image of the natural embedding of the rational number field
##  into a field of rational functions is of course an abelian number field
##  but its elements are not cyclotomics since this would be a property given
##  by their family.)
##
Revision.fldabnum_gd :=
    "@(#)$Id$";


#############################################################################
##
#P  IsNumberField( <F> )
##
##  A number field is a finite extension of a prime field in characteristic
##  zero.
##
DeclareProperty( "IsNumberField", IsField );

InstallSubsetMaintenance( IsNumberField,
    IsField and IsNumberField, IsField );

InstallIsomorphismMaintenance( IsNumberField,
    IsField and IsNumberField, IsField );


#############################################################################
##
#P  IsAbelianNumberField( <F> )
##
##  An *abelian number field* is a number field that is a Galois extension
##  of the prime field with abelian Galois group (see~"GaloisGroup.field").
##
DeclareProperty( "IsAbelianNumberField", IsField );

InstallTrueMethod( IsNumberField, IsAbelianNumberField );

InstallSubsetMaintenance( IsAbelianNumberField,
    IsField and IsAbelianNumberField, IsField );

InstallIsomorphismMaintenance( IsAbelianNumberField,
    IsField and IsAbelianNumberField, IsField );


#############################################################################
##
#m  Conductor( <F> )
##
##  The attribute is defined in `cyclotom.g'.
##
InstallIsomorphismMaintenance( Conductor,
    IsField and IsAbelianNumberField, IsField );


#############################################################################
##
#M  IsFieldControlledByGaloisGroup( <cycfield> )
##
##  For finite fields and abelian number fields
##  (independent of the representation of their elements),
##  we know the Galois group and have a method for `Conjugates' that does
##  not use `MinimalPolynomial'.
##
InstallTrueMethod( IsFieldControlledByGaloisGroup,
    IsField and IsAbelianNumberField );


#############################################################################
##
#P  IsCyclotomicField( <F> )
##
##  A *cyclotomic field* is an abelian number field that is generated by
##  roots of unity.
##
DeclareProperty( "IsCyclotomicField", IsField );

InstallTrueMethod( IsAbelianNumberField, IsCyclotomicField );

InstallIsomorphismMaintenance( IsCyclotomicField,
    IsField and IsCyclotomicField, IsField );


#############################################################################
##
#A  GaloisStabilizer( <F> )
##
##  For an abelian number field <F>, `GaloisStabilizer' returns
##  the set of all integers $k$ in the range from $1$ to the conductor of
##  <F> such that the field automorphism induced by raising roots of unity
##  in <F> to the $k$-th power acts trivially on <F>.
##
DeclareAttribute( "GaloisStabilizer", IsAbelianNumberField );

InstallIsomorphismMaintenance( GaloisStabilizer,
    IsField and IsAbelianNumberField, IsField );


#############################################################################
##
#C  IsRationals( <obj> )
##
DeclareSynonym( "IsRationals",
    IsCyclotomicCollection and IsField and IsPrimeField );


#############################################################################
##
#V  Rationals . . . . . . . . . . . . . . . . . . . . . .  field of rationals
##
DeclareGlobalVariable( "Rationals", "field of rationals" );


#############################################################################
##
#C  IsGaussianRationals( <obj> )
##
DeclareCategory( "IsGaussianRationals", IsCyclotomicCollection and IsField );
#T better?


#############################################################################
##
#V  GaussianRationals . . . . . . . . . . . . . . field of Gaussian rationals
##
##  is the field $Q(i)$ of Gaussian rationals.
##
DeclareGlobalVariable( "GaussianRationals",
    "field of Gaussian rationals (identical with CF(4))" );


#############################################################################
##
#V  CYCLOTOMIC_FIELDS
##
##  At position <n>, the <n>-th cyclotomic field is stored.
##
DeclareGlobalVariable( "CYCLOTOMIC_FIELDS",
    "list, CYCLOTOMIC_FIELDS[n] = CF(n) if bound" );
InstallFlushableValue( CYCLOTOMIC_FIELDS, [ Rationals,,, GaussianRationals ] );


#############################################################################
##
#F  CyclotomicField( <n> )  . . . . . . .  create the <n>-th cyclotomic field
#F  CyclotomicField( <gens> )
#F  CyclotomicField( <subfield>, <n> )
#F  CyclotomicField( <subfield>, <gens> )
##
##  The first version creates the <n>-th cyclotomic field. The second
##  version creates the cyclotomic field generated by <gens>. In both cases
##  the field can be generated as an extension of a designated <subfield>.
##
DeclareGlobalFunction( "CyclotomicField" );

DeclareSynonym( "CF", CyclotomicField );


#############################################################################
##
#V  ABELIAN_NUMBER_FIELDS
##
##  At position <n>, those fields with conductor <n> are stored that are not
##  cyclotomic fields.
##  The list for cyclotomic fields is `CYCLOTOMIC_FIELDS'.
##
DeclareGlobalVariable( "ABELIAN_NUMBER_FIELDS",
    "list of lists, at position [1][n] stabilizers, at [2][n] the fields" );
InstallFlushableValue( ABELIAN_NUMBER_FIELDS, [ [], [] ] );


#############################################################################
##
#F  AbelianNumberField( <n>, <stab> ) . . . .  create an abelian number field
##
##  fixed field of the group generated by <stab> (prime residues modulo <n>)
##  in the cyclotomic field with conductor <n>.
##
DeclareGlobalFunction( "AbelianNumberField" );

DeclareSynonym( "NF", AbelianNumberField );
DeclareSynonym( "NumberField", AbelianNumberField );


#############################################################################
##
#F  ZumbroichBase( <n>, <m> )
##
##  is the set of exponents <e> for which `E(<n>)^<e>' belongs to the
##  (generalized) Zumbroich base of the cyclotomic field $Q_n$,
##  viewed as vector space over $Q_m$.
##
##  The  base,  the  base conversion  and the  reduction  to  the  minimal
##  cyclotomic field  are  described in~\cite{Zum89}.
##
##  *Note* that for $<n> \equiv 2 \bmod 4$ we have
##  `ZumbroichBase( <n>, 1 ) = 2 * ZumbroichBase( <n>/2, 1 )' but
##  `List( ZumbroichBase(  <n>, 1  ), x -> E(  <n>  )^x ) =
##   List( ZumbroichBase( <n>/2, 1 ), x -> E( <n>/2 )^x )'.
##
DeclareGlobalFunction( "ZumbroichBase" );


#############################################################################
##
#F  LenstraBase( <n>, <stabilizer>, <super>, <m> )
##
##  is a list of lists of integers, each list indexing the exponents of
##  an orbit of a subgroup of <stabilizer> on <n>-th roots of unity.
##
##  <super> is a list representing a supergroup of <stabilizer> which
##  shall act consistently with the action of <stabilizer>, i.e., each orbit
##  of <supergroup> is a union of orbits of <stabilizer>.
##
##  <m> is a positive integer.  The basis described by the returned list is
##  an integral basis over the cyclotomic field $\Q_m$.
##
##  *Note* that the elements are in general not sets, since the first element
##  is always an element of `ZumbroichBase( <n>, <m> )';
##  this property is used by `NF' and `Coefficients'.
##
##  *Note* that <stabilizer> must not contain the stabilizer of a proper
##  cyclotomic subfield of the <n>-th cyclotomic field.
##
DeclareGlobalFunction( "LenstraBase" );


#############################################################################
##
#V  Cyclotomics . . . . . . . . . . . . . . . . . .  field of all cyclotomics
##
##  is the field of all cyclotomics (in {\GAP}).
##
DeclareGlobalVariable( "Cyclotomics", "field of all cyclotomics" );


#############################################################################
##
#F  ANFAutomorphism( <F>, <k> )  . .  automorphism of an abelian number field
##
##  Let <F> be an abelian number field <F> and <k> an integer.
##  If <k> is coprime to the conductor (see~"Conductor") of <F> then
##  `ANFAutomorphism' returns the automorphism of <F> defined as the linear
##  extension of the map that raises each root of unity in <F> to its <k>-th
##  power, otherwise an error is signalled.
##
DeclareGlobalFunction( "ANFAutomorphism" );


#############################################################################
##
#A  ExponentOfPowering( <map> )
##
##  For a mapping <map> that raises each element of its preimage to the same
##  power $n$, `ExponentOfPowering' returns the number $n$.
##
##  The action of a Galois automorphism of an abelian number field is given
##  by the $\Q$-linear extension of raising each root of unity to the same
##  power $n$.
##  For such an automorphism, `ExponentOfPowering' returns $n$.
##
DeclareAttribute( "ExponentOfPowering", IsMapping );


#############################################################################
##
#E
