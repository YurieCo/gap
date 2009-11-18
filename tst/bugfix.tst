#############################################################################
##
#W  bugfix.tst
##
#H  $Id: bugfix.tst,v 1.80 2009/09/30 19:01:17 alexk Exp $
##
##  Exclude from testall.g: why?
##


##  Do not show package banners during these tests.
gap> BANNER_ORIG:= GAPInfo.CommandLineOptions.b;;
gap> GAPInfo.CommandLineOptions.b:= true;;


gap> START_TEST("bugfixes test");

##  Bug 18 for fix 4
##
gap> if LoadPackage( "ctbllib" ) <> fail then
>      if Irr( CharacterTable( "WeylD", 4 ) )[1] <>
>           [ 3, -1, 3, -1, 1, -1, 3, -1, -1, 0, 0, -1, 1 ] then
>        Print( "problem with Irr( CharacterTable( \"WeylD\", 4 ) )[1]\n" );
>      fi;
>    fi;

##  Check to see if the strongly connected component (Error 3) fix has been
##     installed
##
gap> M := Monoid([Transformation( [ 2, 3, 4, 5, 5 ] ),
> Transformation( [ 3, 1, 4, 5, 5 ] ),
> Transformation( [ 2, 1, 4, 3, 5 ] ) ]);;
gap> Size(GreensLClasses(M)[2])=2;
true

##  Check the fix in OrbitStabilizerAlgorithm (Error 4) for infinite groups.
##
gap> N:=GroupByGenerators(
>   [ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 0, 0 ], [ 0, -1, 0, 0 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 1, 0 ], [ 0, -1, 0, 1 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 0, -1 ], [ 0, -1, 1, 0 ] ], 
>     [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ], 
>     [ [ 0, 1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, 1 ], [ 0, 0, 1, 0 ] ] ] );
<matrix group with 6 generators>
gap> IsFinite(N);
false
gap> G:=GroupByGenerators( [ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ],
>   [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ] ] );
Group([ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ] 
 ])
gap> Centralizer(N,G);
<matrix group of size infinity with 6 generators>

## iterated autgp (5)
gap> g:=Group((1,2,3),(4,5,6),(2,3)(5,6));;
gap> aut:=AutomorphismGroup(g);;
gap> ccu:=ConjugacyClasses(aut);;
gap> aut2:=AutomorphismGroup(aut);;

## field conversion (6)
gap> v := [];;
gap> ConvertToVectorRep(v,3);;
gap> ConvertToVectorRep(v,9);;

## EulerianFunction (10)
gap> EulerianFunction( DihedralGroup(8), 2);
24
gap> EulerianFunction( CyclicGroup(6), 1 );
2
gap> EulerianFunction( CyclicGroup(5), 1 );
4

gap> g:=SmallGroup(1,1);;
gap> ConjugacyClassesSubgroups(g);;

gap> g:=Group([ (3,5), (1,3,5) ]);;
gap> MaximalSubgroups(g);;

## GQuotients
gap> s := SymmetricGroup(4);;
gap> g := SmallGroup(48,1);;
gap> GQuotients(g,s);
[  ]

## Costantini bug, in inverting lists of compressed vectors
gap> p := 3;; e := 16;;
gap> g := ElementaryAbelianGroup(p^e);;
gap> l := PCentralLieAlgebra(g);;
gap> b := Basis(l);;
gap> b2 := b;;
gap> RelativeBasis(b,b2);;

## Testing if an element is in a Green's D equivalence class (fix 2 no. 12)
gap> s := Semigroup(Transformation([1,1,3,4]),Transformation([1,2,2,4]));;
gap> dc := GreensDClasses(s);;
gap> Transformation([1,1,3,4]) in dc[1];
false

## Testing if Green's D classes can be compared for finite semigroups
gap> s := Transformation([1,1,3,4,5]);;
gap> c := Transformation([2,3,4,5,1]);;
gap> op5 := Semigroup(s,c);;
gap> dcl := GreensDClasses(op5);;
gap> IsGreensLessThanOrEqual(dcl[4],dcl[5]);
true

## Testing that GroupHClassOfGreensDClass is implemented
gap> h := GroupHClassOfGreensDClass(dcl[4]);;

## Testing AssociatedReesMatrixSemigroupOfDClass.
##         IsZeroSimpleSemigroup, IsomorphismReesMatrixSemigroup,
##         and SandwichMatrixOfReesZeroMatrixSemigroup
##         create Greens D classes correctly.
gap> rms := AssociatedReesMatrixSemigroupOfDClass(dcl[5]);;
gap> s := Transformation([1,1,2]);;
gap> c := Transformation([2,3,1]);;
gap> op3 := Semigroup(s,c);;
gap> IsRegularSemigroup(op3);;
gap> dcl := GreensDClasses(op3);;
gap> dcl := SortedList(ShallowCopy(dcl));;
gap> d2 := dcl[2];; d1:= dcl[1];;
gap> i2 := SemigroupIdealByGenerators(op3,[Representative(d2)]);;
gap> GeneratorsOfSemigroup(i2);;
gap> i1 := SemigroupIdealByGenerators(i2,[Representative(d1)]);;
gap> GeneratorsOfSemigroup(i1);;
gap> c1 := ReesCongruenceOfSemigroupIdeal(i1);;
gap> q := i2/c1;;
gap> IsZeroSimpleSemigroup(q);;
gap> irms := IsomorphismReesMatrixSemigroup(q);;
gap> SandwichMatrixOfReesZeroMatrixSemigroup(Source(irms));;

gap> g := Group( (1,2),(1,2,3) );;
gap> i := TrivialSubgroup( g );;
gap> CentralizerModulo( g, i, (1,2) );
Group([ (1,2) ])

##  bugs 2, 3, 6, 7, 20 for fix 2.
gap> x:= Sum( GeneratorsOfAlgebra( QuaternionAlgebra( Rationals, -2, -2 ) ) );;
gap> x * Inverse( x ) = One( x );
true
gap> LargestMovedPoint(ProjectiveSymplecticGroup(6,2)) = 63;
true
gap> t1:= CharacterTable( CyclicGroup( 2 ) );;  SetIdentifier( t1, "C2" );
gap> t2:= CharacterTable( CyclicGroup( 3 ) );;  SetIdentifier( t2, "C3" );
gap> t1 * t1;  ( t1 mod 2 ) * ( t1 mod 2 );
CharacterTable( "C2xC2" )
BrauerTable( "C2xC2", 2 )
gap> ( t1 mod 2 ) * t2;  t2 * ( t1 mod 2 );
BrauerTable( "C2xC3", 2 )
BrauerTable( "C3xC2", 2 )
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> chi:= TrivialCharacter( t );;
gap> IntScalarProducts( t, [ chi ], chi );
true
gap> NonnegIntScalarProducts( t, [ chi ], chi );
true
gap> Representative( TrivialSubgroup( Group( (1,2) ) ) );
()
gap> Representative( TrivialSubspace( GF(2)^2 ) );
[ 0*Z(2), 0*Z(2) ]
gap> g:=SmallGroup(70,3);;
gap> g:=GroupByPcgs(Pcgs(g));;
gap> IdGroup(g);
[ 70, 3 ]

gap> G := Group(());;F := FreeGroup( 1, "f" );;
gap> hom := GroupHomomorphismByImages(F,G,GeneratorsOfGroup(F),
> GeneratorsOfGroup(G));;
gap> PreImagesRepresentative(hom,());
<identity ...>

##  bug 2 for fix 4.
gap> 1 * One( Integers mod NextPrimeInt( 2^16 ) );
ZmodpZObj( 1, 65537 )

gap> f:=FreeGroup("a","b");;g:=f/[Comm(f.1,f.2),f.1^5,f.2^7];;Pcgs(g);;
gap> n:=Subgroup(g,[g.2]);; m:=ModuloPcgs(g,n);;
gap> ExponentsOfPcElement(m,m[1]);
[ 1 ]

##  bug 11 for fix 4.
gap> x:= Indeterminate( Rationals );;
gap> f:= x^4 + 3*x^2 + 1;;
gap> F:= AlgebraicExtension( Rationals, f );;
gap> Basis( F )[1];;

# bug in ReducedSCTable:
gap> T:= EmptySCTable( 1, 0, "antisymmetric" );
[ [ [ [  ], [  ] ] ], -1, 0 ]
gap> ReducedSCTable( T, Z(3)^0 );
[ [ [ [  ], [  ] ] ], -1, 0*Z(3) ]

## Rees Matrix bug fix 4
gap> s := Semigroup(Transformation([2,3,1]));;
gap> IsSimpleSemigroup(s);;
gap> irms := IsomorphismReesMatrixSemigroup(s);;
gap> Size(Source(irms));
3

## Semigroup/Monoid rewriting system bug for fix 4
gap> f := FreeSemigroup("a","b");;
gap> a := f.1;; b := f.2;;
gap> s := f/[[a*b,b],[b*a,a]];;
gap> rws := KnuthBendixRewritingSystem(s);
Knuth Bendix Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ a*b, b ], [ b*a, a ] ]
gap> MakeConfluent(rws);
gap> rws;
Knuth Bendix Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ a*b, b ], [ b*a, a ], [ a^2, a ], [ b^2, b ] ]
gap> HasReducedConfluentRewritingSystem(s);
true

gap> x:= Indeterminate( Rationals );;
gap> a:= 1/(1+x);;
gap> b:= 1/(x+x^2);;
gap> a=b;
false

##  bugs 12 and 14 for fix 4
gap> IsRowVector( [ [ 1 ] ] );
false
gap> IsRowModule( TrivialSubmodule( GF(2)^[2,2] ) );
false

gap> g:=SL(2,5);;c:=Irr(g)[6];;
gap> hom:=IrreducibleRepresentationsDixon(g,c);;
gap> Size(Image(hom));
60

##  bug 16 for fix 4
gap> Difference( [ 1, 1 ], [] );
[ 1 ]

## bug 17 for fix 4
gap> f := FreeGroup( 2 );;
gap> g := f/[f.1^4,f.2^4,Comm(f.1,f.2)];;
gap> Elements(g);
[ <identity ...>, f1, f1^3, f2, f2^3, f1^2, f1*f2, f1*f2^3, f1^3*f2, 
  f1^3*f2^3, f2^2, f1^2*f2, f1^2*f2^3, f1*f2^2, f1^3*f2^2, f1^2*f2^2 ]

gap> NrPrimitiveGroups(441);
24

##  bug 2 for fix 5
gap> IsSubset( GF(2)^[2,2], GF(4)^[2,2] );
false

gap> G:=Group((8,12)(10,14),(8,10)(12,14),(4,6)(12,14),(2,4)(10,12),
> (4,8)(6,10), (9,13)(11,15),(9,11)(13,15),(5,7)(13,15),(3,5)(11,13),
> (5,9)(7,11));;
gap> x:=Group((1,8)(2,7)(3,6)(4,5)(9,16)(10,15)(11,14)(12,13),
> (1,9)(2,10)(3,11)(4,12)(5,13)(6,14)(7,15)(8,16),
> (1,4)(2,3)(5,8)(6,7)(9,12)(10,11)(13,16)(14,15),
> (1,10)(2,9)(3,12)(4,11)(5,14)(6,13)(7,16)(8,15));;
gap> y:=Group((1,8)(2,7)(3,6)(4,5)(9,14)(10,13)(11,16)(12,15),
> (1,11)(2,10)(3,9)(4,12)(5,15)(6,14)(7,13)(8,16),
> (1,4)(2,3)(5,8)(6,7)(9,10)(11,12)(13,14)(15,16),
> (1,10)(2,11)(3,12)(4,9)(5,14)(6,15)(7,16)(8,13));;
gap> RepresentativeAction(G,x,y)<>fail;
true

##  bug 5 for fix 5
gap> BaseOrthogonalSpaceMat( [ [ 1, 0 ] ] );
[ [ 0, 1 ] ]

##  bug 6 for fix 5
gap> IsSet( AUTOLOAD_PACKAGES );
true

##  bug 7 for fix 5
gap> tbl:= CharacterTable( SL(2,3) );;  irr:= Irr( tbl );;
gap> lin:= Filtered( LinearCharacters( tbl ), x -> Order(x) = 3 );;
gap> deg3:= First( irr, x -> DegreeOfCharacter( x ) = 3 );;
gap> MolienSeries( tbl, lin[1] + deg3, lin[2] );
( 2*z^2+z^3-z^4+z^6 ) / ( (1-z^3)^2*(1-z^2)^2 )

##  bug 8 for fix 5
gap> l:= [ 1, 2 ];;  i:= Intersection( [ l ] );;
gap> IsIdenticalObj( l, i );
false

## bug 9 for fix 5
gap> A:=FullMatrixLieAlgebra(Rationals,2);
<Lie algebra over Rationals, with 3 generators>
gap> B:=LieDerivedSubalgebra(A);
<Lie algebra of dimension 3 over Rationals>
gap> D:=Derivations(Basis(B));
<Lie algebra of dimension 3 over Rationals>

##  bug 10 for fix 5
gap> k:=AbelianGroup([5,5,5]);
<pc group of size 125 with 3 generators>
gap> h:=SylowSubgroup(AutomorphismGroup(k),2);
<group>
gap> g:=SemidirectProduct(h,k);
<pc group with 10 generators>
gap> Centre(g);
Group([  ])

## bug 11 for fix 5
gap> m1:=[[0,1],[0,0]];;
gap> m2:=[[0,0],[1,0]];;
gap> m3:=[[1,0],[0,-1]];;
gap> M1:=MatrixByBlockMatrix(BlockMatrix([[1,1,m1]],2,2));;
gap> M2:=MatrixByBlockMatrix(BlockMatrix([[1,1,m2]],2,2));;
gap> M3:=MatrixByBlockMatrix(BlockMatrix([[1,1,m3]],2,2));;
gap> M4:=MatrixByBlockMatrix(BlockMatrix([[2,2,m1]],2,2));;
gap> M5:=MatrixByBlockMatrix(BlockMatrix([[2,2,m2]],2,2));;
gap> M6:=MatrixByBlockMatrix(BlockMatrix([[2,2,m3]],2,2));;
gap> L:=LieAlgebra(Rationals,[M1,M2,M3,M4,M5,M6]);
<Lie algebra over Rationals, with 6 generators>
gap> DirectSumDecomposition(L);
[ <two-sided ideal in <Lie algebra of dimension 6 over Rationals>, 
      (dimension 3)>, 
  <two-sided ideal in <Lie algebra of dimension 6 over Rationals>, 
      (dimension 3)> ]

##  bug 16 for fix 5
gap> IrrBaumClausen( Group(()));;

##  bug 17 for fix 5 (example taken from `vspcmat.tst')
gap> w:= LeftModuleByGenerators( GF(9),
> [ [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ],
> [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ],
> [ [ 0*Z(3), Z(3) ], [ Z(3), Z(3) ] ] ] );;
gap> w = AsVectorSpace( GF(3), w );
true

##  bug 18 for fix 5
gap> List( Irr( AlternatingGroup( 5 ) ), TestMonomial );;

##  bug 2 for fix 6
gap> if LoadPackage( "tomlib" ) <> fail then
>      DerivedSubgroupsTom( TableOfMarks( "A10" ) );
>    fi;

##  bug 3 for fix 6
gap> Order( ZmodnZObj( 2, 7 ) );;  Inverse( ZmodnZObj( 2, 7 ) );;

##  bug 4 for fix 6
gap> tbl:= CharacterTable( SL(2,3) );;  irr:= Irr( tbl );;
gap> z:= Indeterminate( Rationals );
x_1
gap> lin:= Filtered( LinearCharacters( tbl ), x -> Order(x) = 3 );;
gap> deg3:= First( irr, x -> DegreeOfCharacter( x ) = 3 );;
gap> ser:= MolienSeries( tbl, lin[1] + deg3, lin[2] );;
gap> MolienSeriesWithGivenDenominator( ser, [ 6,6,4,4 ] );
( 2*z^2+z^3+3*z^4+6*z^5+3*z^6+7*z^7+7*z^8+3*z^9+6*z^10+4*z^11+z^12+3*z^13+z^14\
+z^16 ) / ( (1-z^6)^2*(1-z^4)^2 )


#############################################################################
##
##  Fixes for GAP 4.4
##

##  bug 8 for fix 1
gap> q:= QuaternionAlgebra( Rationals );;
gap> t:= TrivialSubspace( q );;
gap> tt:= Subspace( q, [] );;
gap> Intersection2( t, tt );;


gap> g:=SmallGroup(6,2);;
gap> f:=FreeGroup(3);;
gap> f:=f/[f.2*f.3];;
gap> q:=GQuotients(f,g);;
gap> k:=List(q,Kernel);;
gap> k:=Intersection(k);;
gap> hom:=IsomorphismFpGroup(TrivialSubgroup(g));;
gap> IsFpGroup(Range(hom));
true

## bug 3 for fix 2
gap> Order([[-E(7),0,0,0],[0,-E(7)^6,0,0],[0,0,E(21),0],[0,0,0,E(21)^20]]);
42
gap> Order(-E(7)*IdentityMat(14));
14

## bug 5 for fix 2
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> PowerMap( t, -1 );;  PowerMap( t, -1, 2 );;
gap> m:= t mod 2;;
gap> PowerMap( m, -1 );;  PowerMap( m, -1, 2 );;

## bug 9 for fix 2
gap> IsSimple(Ree(3));
false

## bug 10 for fix 2
gap> g:= GU(3,4);;  g.1 in g;
true
gap> ForAll( GeneratorsOfGroup( Sp(4,4) ), x -> x in SP(4,2) );
false

## bug 12 for fix 2
gap> IsMatrix( Basis( VectorSpace( GF(2), Basis( GF(2)^2 ) ) ) );
true

## bug 13 for fix 2
gap> -1 in [1..2];
false

## bug 16-18 for fix 4
gap> AbelianInvariantsMultiplier(SL(3,2));
[ 2 ]
gap> AllPrimitiveGroups(Size,60);
#W  AllPrimitiveGroups: Degree restricted to [ 1 .. 2499 ]
[ A(5), PSL(2,5), A(5) ]
gap> ix18:=X(GF(5),1);;f:=ix18^5-1;;
gap> Discriminant(f);
0*Z(5)

## bug 3 for fix 5
gap> One( DirectProduct( Group( [], () ), Group( [], () ) ) );;

## bug 4 for fix 5
gap> emb:= Embedding( DirectProduct( Group( (1,2) ), Group( (1,2) ) ), 1 );;
gap> PreImagesRepresentative( emb, (1,2)(3,4) );
fail

## bug 6 for fix 5
gap> v:= VectorSpace( Rationals, [ [ 1 ] ] );;
gap> x:= LeftModuleHomomorphismByImages( v, v, Basis( v ), Basis( v ) );;
gap> x + 0*x;;

## bug 7 for fix 5
gap> a:= GroupRing( GF(2), Group( (1,2) ) );;
gap> 1/3 * a.1;;  a.1 * (1/3);;

## bug 10 for fix 5
gap> R:= Integers mod 6;;
gap> Size( Ideal( R, [ Zero( R ) ] ) + Ideal( R, [ 2 * One( R ) ] ) );
3

## for changes 4.4.4 -> 4.4.5  (extracted from corresponding dev/Update)


# For fixes:


# 2005/01/06 (TB)
gap> One( DirectProduct( Group( [], () ), Group( [], () ) ) );;


# 2005/01/06 (TB)
gap> emb:= Embedding( DirectProduct( Group( (1,2) ), Group( (1,2) ) ), 1 );;
gap> PreImagesRepresentative( emb, (1,2)(3,4) );
fail


# 2005/02/21 (TB)
gap> v:= VectorSpace( Rationals, [ [ 1 ] ] );;
gap> x:= LeftModuleHomomorphismByImages( v, v, Basis( v ), Basis( v ) );;
gap> x + 0*x;;


# 2005/02/21 (TB)
# 2006/03/13 (JJM) - removed this duplicate of 'bug 7 for fix 5' test
#gap> a:= GroupRing( GF(2), Group( (1,2) ) );;
#gap> 1/3 * a.1;;  a.1 * (1/3);;


# 2005/02/26 (AH)
gap> Random(GF(26831423036065352611));;


# 2005/03/05 (AH)
gap> x:=X(Rationals);;
gap> PowerMod(x,3,x^2);
0
gap> PowerMod(x,1,x);
0


# 2005/03/08 (AH)
gap> p:=[0,1];
[ 0, 1 ]
gap> UnivariatePolynomial(Rationals,p);
x_1
gap> p;
[ 0, 1 ]


# 2005/03/31 (TB)
gap> R:= Integers mod 6;;
gap> Size( Ideal( R, [ Zero( R ) ] ) + Ideal( R, [ 2 * One( R ) ] ) );
3


# 2005/04/12 (FL (includes a fix in dev-version by Burkhard))
## the less memory GAP has, the earlier the following crashed GAP
#out := OutputTextFile("/dev/null",false);
#g := SymmetricGroup(1000000);
#for i in [1..100] do
#    Print(i, " \c");
#    r := PseudoRandom(g);
#    PrintTo(out, "Coset representative is ", r, "\n");
#od;


# 2005/04/12 (FL)
gap> IntHexString(['a','1']);
161


# 2005/04/12 (AH)
gap> f:=FreeGroup(IsSyllableWordsFamily,8);;
gap> g:=GeneratorsOfGroup(f);;
gap> g1:=g[1];;
gap> g2:=g[2];;
gap> g3:=g[3];;
gap> g4:=g[4];;
gap> g5:=g[5];;
gap> g6:=g[6];;
gap> g7:=g[7];;
gap> g8:=g[8];;
gap> rws:=SingleCollector(f,[ 2, 3, 2, 3, 2, 3, 2, 3 ]);;
gap> r:=[
gap>   [1,g4*g6],
gap>   [3,g4],
gap>   [5,g6*g8^2],
gap>   [7,g8],
gap> ];;
gap> for x in r do SetPower(rws,x[1],x[2]);od;
gap> G:= GroupByRwsNC(rws);;
gap> f1:=G.1;;
gap> f2:=G.2;;
gap> f3:=G.3;;
gap> f4:=G.4;;
gap> f5:=G.5;;
gap> f6:=G.6;;
gap> f7:=G.7;;
gap> f8:=G.8;;
gap> a:=Subgroup(G,[f3*f6*f8^2, f5*f6*f8^2, f7*f8, f4*f6^2*f8 ]);;
gap> b:=Subgroup(G,[f2^2*f4^2*f6*f7*f8^2, f2*f4*f6^2*f8^2, f5*f6^2*f8,
>                   f2^2*f6^2*f8, f2*f3*f4, f2^2]);;
gap> Size(Intersection(a,b))=Number(a,i->i in b);
true


# 2005/04/15 (TB)
gap> CompareVersionNumbers( "1.0", ">=9.9" );
false


# 2005/04/26 (SL)

# too complicated to construct



# 2005/04/27 (TB)
gap> Iterator( Subspaces( VectorSpace( GF(2), [ X( GF(2) ) ] ) ) );;


# 2005/04/27 (TB)
gap> String( [ [ '1' ] ] );  String( rec( a:= [ '1' ] ) );
"[ \"1\" ]"
"rec( a := \"1\" )"


# 2005/05/03 (BH)
gap> if LoadPackage ("crisp") <> fail then
>      F:=FreeGroup("a","b","c");;
>      a:=F.1;;b:=F.2;;c:=F.3;;
>      G:=F/[a^12,b^2*a^6,c^2*a^6,b^-1*a*b*a,c^-1*a*c*a^-7,c^-1*b*c*a^-9*b^-1];;
>      pcgs := PcgsElementaryAbelianSeries (G);;
>      ser := ChiefSeries (G);;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgs (pcgs, H))
>                           <> ParentPcgs (pcgs)) then
>        Print( "problem with crisp (1)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <>  ParentPcgs(HomePcgs (H))) then
>        Print( "problem with crisp (2)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <> HomePcgs (H)) then
>        Print( "problem with crisp (3)\n" );
>      fi;
>      G2:=Image(IsomorphismPermGroup(G));
>      pcgs := PcgsElementaryAbelianSeries (G2);
>      ser := ChiefSeries (G2);
>      if ForAny (ser, H -> ParentPcgs (InducedPcgs (pcgs, H))
>                           <> pcgs) then
>        Print( "problem with crisp (4)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <> ParentPcgs(HomePcgs (H))) then
>        Print( "problem with crisp (5)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <> HomePcgs (H)) then
>        Print( "problem with crisp (6)\n" );
>      fi;
>    fi;


# 2005/05/03 (BE)
gap> SmallGroupsInformation(512);

  There are 10494213 groups of order 512.
     1 is cyclic. 
     2 - 10 have rank 2 and p-class 3.
     11 - 386 have rank 2 and p-class 4.
     387 - 1698 have rank 2 and p-class 5.
     1699 - 2008 have rank 2 and p-class 6.
     2009 - 2039 have rank 2 and p-class 7.
     2040 - 2044 have rank 2 and p-class 8.
     2045 has rank 3 and p-class 2.
     2046 - 29398 have rank 3 and p-class 3.
     29399 - 30617 have rank 3 and p-class 4.
     30618 - 31239 have rank 3 and p-class 3.
     31240 - 56685 have rank 3 and p-class 4.
     56686 - 60615 have rank 3 and p-class 5.
     60616 - 60894 have rank 3 and p-class 6.
     60895 - 60903 have rank 3 and p-class 7.
     60904 - 67612 have rank 4 and p-class 2.
     67613 - 387088 have rank 4 and p-class 3.
     387089 - 419734 have rank 4 and p-class 4.
     419735 - 420500 have rank 4 and p-class 5.
     420501 - 420514 have rank 4 and p-class 6.
     420515 - 6249623 have rank 5 and p-class 2.
     6249624 - 7529606 have rank 5 and p-class 3.
     7529607 - 7532374 have rank 5 and p-class 4.
     7532375 - 7532392 have rank 5 and p-class 5.
     7532393 - 10481221 have rank 6 and p-class 2.
     10481222 - 10493038 have rank 6 and p-class 3.
     10493039 - 10493061 have rank 6 and p-class 4.
     10493062 - 10494173 have rank 7 and p-class 2.
     10494174 - 10494200 have rank 7 and p-class 3.
     10494201 - 10494212 have rank 8 and p-class 2.
     10494213 is elementary abelian.

  This size belongs to layer 7 of the SmallGroups library. 
  IdSmallGroup is not available for this size. 


# 2005/05/04 (SL)
gap> c := [1,1,0,1]*Z(2);
[ Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0 ]
gap> m := [1,1]*Z(2);
[ Z(2)^0, Z(2)^0 ]
gap> PowerModCoeffs(c, 1, m);
[ Z(2)^0 ]
gap> ConvertToVectorRep(c, 2);
2
gap> ConvertToVectorRep(m, 2);
2
gap> Print(PowerModCoeffs(c, 1, m), "\n");
[ Z(2)^0 ]



# 2005/05/06 (SL)
gap> A:=[[Z(2)]];; ConvertToMatrixRep(A,2);;
gap> Sort(A); A;
<a 1x1 matrix over GF2>


# 2005/05/09 (TB)
# call: gap -A
# gap> SaveWorkspace( "wsp" );;
# call: gap -A -L wsp


# 2005/05/09 (FL)
gap> NextPrimeInt(23482648263482364926498249);
#I  IsPrimeInt: probably prime, but not proven: 23482648263482364926498251
23482648263482364926498251


# 2005/05/09 (Colva, FL (for 4R4))
gap> L:=AllPrimitiveGroups(NrMovedPoints,26,Size,[1..2^28-1]);
[ PSL(2, 25), PGL(2, 25), PSigmaL(2, 25), PSL(2, 25).2, PGammaL(2, 25) ]

# For new features:


# 2005/04/13 (FL)
gap> IsCheapConwayPolynomial(5,96);
false


# 2005/04/21 (FL)
gap> NormalBase( GF(3^6) );
[ Z(3^6)^2, Z(3^6)^6, Z(3^6)^18, Z(3^6)^54, Z(3^6)^162, Z(3^6)^486 ]
gap>  NormalBase( GF( GF(8), 2 ) );
[ Z(2^6), Z(2^6)^8 ]


# 2005/04/21 (FL)
gap> IsBound(HELP_VIEWER_INFO.firefox);
true


# 2005/04/26 (SL, FL)
gap> AClosestVectorCombinationsMatFFEVecFFECoords;
<Operation "AClosestVectorCombinationsMatFFEVecFFECoords">
gap> ConstituentsPolynomial;
function( p ) ... end


# 2005/04/27 (TB)
gap> IsBound( CYC_LIST );
true


# 2005/05/03 (SK)
gap> x := Indeterminate(Integers);;
gap> ContinuedFractionExpansionOfRoot(x^2-7,20);
[ 2, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1 ]
gap> ContinuedFractionExpansionOfRoot(x^2-7,0);
[ 2, 1, 1, 1, 4 ]
gap> ContinuedFractionExpansionOfRoot(x^3-2,20);
[ 1, 3, 1, 5, 1, 1, 4, 1, 1, 8, 1, 14, 1, 10, 2, 1, 4, 12, 2, 3 ]
gap> ContinuedFractionExpansionOfRoot(x^5-x-1,50);
[ 1, 5, 1, 42, 1, 3, 24, 2, 2, 1, 16, 1, 11, 1, 1, 2, 31, 1, 12, 5, 1, 7, 11, 
  1, 4, 1, 4, 2, 2, 3, 4, 2, 1, 1, 11, 1, 41, 12, 1, 8, 1, 1, 1, 1, 1, 9, 2, 
  1, 5, 4 ]
gap> ContinuedFractionApproximationOfRoot(x^2-2,10);
3363/2378
gap> 3363^2-2*2378^2;
1
gap> z := ContinuedFractionApproximationOfRoot(x^5-x-1,20);
499898783527/428250732317
gap> z^5-z-1;
486192462527432755459620441970617283/
14404247382319842421697357558805709031116987826242631261357


# 2005/05/03 (SK)
gap> l := AllSmallGroups(12);;
gap> List(l,StructureDescription);; l;
[ C3 : C4, C12, A4, D12, C6 x C2 ]
gap> List(AllSmallGroups(40),G->StructureDescription(G:short));
[ "5:8", "40", "5:8", "5:Q8", "4xD10", "D40", "2x(5:4)", "(10x2):2", "20x2",
  "5xD8", "5xQ8", "2x(5:4)", "2^2xD10", "10x2^2" ]
gap> List(AllTransitiveGroups(DegreeAction,6),G->StructureDescription(G:short));
[ "6", "S3", "D12", "A4", "3xS3", "2xA4", "S4", "S4", "S3xS3", "(3^2):4",
  "2xS4", "A5", "(S3xS3):2", "S5", "A6", "S6" ]
gap> StructureDescription(PSL(4,2));
"A8"


# 2005/05/03 (BE)
gap> NumberSmallGroups(5^6);
684
gap> NumberSmallGroups(5*7*9*11*13);
22


# 2005/05/05 (TB)
gap> IsBound( ShowPackageVariables );
true


# 2005/05/05 (TB)
gap> IsReadableFile( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );
true


# 2005/05/06 (TB)
gap> IsBound( HasMultiplicationTable );
true


#############################################################################
##
##  for changes 4.4.5 -> 4.4.6  (extracted from corresponding dev/Update)

# For fixes:


# 2005/05/17 (AH)
gap> IsConjugate(TransitiveGroup(9,19),Group([ (2,8,9,3)(4,6,7,5),
> (2,9)(3,8)(4,7)(5 ,6), (1,2,9)(3,4,5)(6,7,8), (1,4,7)(2,5,8)(3,6,9) ]),
> Group([ (3,7)(4,8)(5,6), (2,9)(3,8)(4,7)(5,6),(1,7,4)(2,8,5)(3,9,6),
> (1,6,5)(2,7,3)(4,9,8) ]));;


# 2005/05/18 (TB)
gap> t:= Runtime();;
gap> CayleyGraphSemigroup( Monoid( Transformation([2,3,4,5,6,1,7]),
>      Transformation([6,5,4,3,2,1,7]), Transformation([1,2,3,4,6,7,7]) ) );;
gap> if Runtime() - t > 5000 then
>      Print( "#E  efficiency problem with enumerators of semigroups!\n" );
> fi;


# 2005/06/06 (AH)
gap> Irr(SmallGroup(516,11));;


# 2005/06/13 (AH)
gap> IsSimple(AlternatingGroup(3));
true


# 2005/06/17 (SL)
gap> l := [1,2,3,4];
[ 1, 2, 3, 4 ]
gap> COPY_LIST_ENTRIES(l,2,1,l,3,1,3);
gap> l;
[ 1, 2, 2, 3, 4 ]


# 2005/06/23 (AH)
gap> if LoadPackage("crisp") <> fail then
>     h:=Source(EpimorphismSchurCover(SmallGroup(64,150)));
>     NormalSubgroups( Centre( h ) );
>     fi;


# 2005/07/09 (AH)
gap> CompositionSeries(PerfectGroup(IsPermGroup,262440,1));;


# 2005/07/13 (JS)
gap> PerfectGroup(7800,1);; # load perf2.grp
gap> PerfectGroup(7680,1);; # should load perf1.grp, gives error in 4.4.5


# 2005/07/13 (JS)
gap> NrPerfectLibraryGroups(1);
0


# 2005/07/18 (FL)
gap> TypeObj(IMPLICATIONS);;


# 2005/07/20 (TB)
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
gap> A:= AlgebraByStructureConstants( Rationals, T, "A." );;
gap> GeneratorsOfAlgebra( A );
[ A.1, A.2 ]


# 2005/07/20 (TB)
gap> F:= FreeAssociativeAlgebra( Rationals, 2 );;
gap> IsAssociativeElement( F.1 );
true
gap> F:= FreeAlgebra( Rationals, 2 );;
gap> IsAssociativeElement( F.1 );
false


# 2005/07/21 (JS)
gap> G:=PerfectGroup(IsPermGroup,734832,1);;
gap> H:=PerfectGroup(IsPermGroup,734832,2);;
gap> K:=PerfectGroup(IsPermGroup,734832,3);;
gap> Assert(0,H<>K); # Fails in 4.4.5
gap> Assert(0,Size(G)=734832 and IsPerfectGroup(G)); # Sanity check
gap> Assert(0,Size(H)=734832 and IsPerfectGroup(H)); # Sanity check
gap> Assert(0,Size(K)=734832 and IsPerfectGroup(K)); # Sanity check
gap> Assert(0,Size(Complementclasses(G,SylowSubgroup(FittingSubgroup(G),3)))=1); # Iso check
gap> Assert(0,Size(Complementclasses(H,SylowSubgroup(FittingSubgroup(H),3)))=3); # Iso check
gap> Assert(0,Size(Complementclasses(K,SylowSubgroup(FittingSubgroup(K),3)))=0); # Iso check


# 2005/08/10 (TB)
gap> ApplicableMethod( \in, [ 1, Rationals ] );
function( x, Rationals ) ... end


# 2005/08/11 (JS)
gap> List([1,2,3],k->IdGroup(SylowSubgroup(PerfectGroup(IsPermGroup,864000,k),2)));
[ [ 256, 55700 ], [ 256, 55970 ], [ 256, 56028 ] ]


# 2005/08/11 (TB)
# gap> fam:= NewFamily( "fam" );;
# gap> DeclareGlobalVariable( "TestFam" );
# gap> InstallValue( TestFam, CollectionsFamily( fam ) );
# #I  please use `BindGlobal' for the family object CollectionsFamily(...), not \
# `InstallValue'
# gap> IsIdenticalObj( TestFam, CollectionsFamily( fam ) );
# false
# gap> MakeReadWriteGlobal( "TestFam" );  UnbindGlobal( "TestFam" );


# 2005/08/15 (AH)
gap> Centre( MagmaByMultiplicationTable( [ [ 2, 2 ], [ 2, 1 ] ] ) );
[  ]


# 2005/08/17 (Max)
# Test code is not possible to provide because the error condition
# cannot be tested in a platform independent way.


# 2005/08/19 (JS)
gap> PermutationCycle((1,2,3,4,5,6)^2,[1..6],1); # returns fail in 4.4.5
(1,3,5)


# 2005/08/19 (JS)
gap> f:=function() Assert(0,false); end;; g:=function() f(); end;;
gap> ##  The following should just trigger a normal error, but in 4.4.5
gap> ##  it will send a few hundred lines before crashing:
gap> # g();


# 2005/08/19 (JS)
gap> g:= SmallGroup( 48, 30 );;
gap> AbelianInvariantsMultiplier( g ); # returned [ 2, 2 ] in 4.4.5
[ 2 ]


# 2005/08/19 (SL)
gap> Inverse(0*Z(2));
fail
gap> Inverse(0*Z(3));
fail


# 2005/08/22 (JS+AH)
gap> ##  The mailing lists contain more specific test code that is longer.
gap> ##  The following should never terminate, but does in 4.4.5
gap> # repeat G:=PerfectGroup(IsPermGroup,79200,3); P:=SylowSubgroup(G,11);
gap> # N:=Normalizer(G,P); Q:=N/P; until Size(DerivedSubgroup(Q)) <> 120;


# 2005/08/23 (TB)
gap> g:= SymmetricGroup( 4 );; IsSolvable( g );; Irr( g );;
gap> meth:= ApplicableMethod( CharacterDegrees, [ g, 0 ] );;
gap> meth( g, 0 );
"TRY_NEXT_METHOD"


# 2005/08/23 (TB)
gap> RereadLib( "debug.g" );
gap> Debug( Size );
Usage: Debug( <func>[, <name>] );
       where <func> is a function but not an operation,
       and   <name> is a string.


# 2005/08/23 (FL)
# commented out the test and the error message,
# since a different message is printed on 32 bit systems and 64 bit systems
gap> a := 2^(8*GAPInfo.BytesPerVariable-4)-1;;
gap> Unbind( x );
gap> # x := [-a..a];;
# Range: the length of a range must be less than 2^28
gap> IsBound(x);
false


# 2005/08/23 (TB)
gap> tbl:= CharacterTable( ElementaryAbelianGroup( 4 ) );;
gap> IsElementaryAbelian( tbl );
true
gap> ClassPositionsOfMinimalNormalSubgroups( tbl );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ] ]
gap> if LoadPackage ("ctbllib") <> fail then
>      tbl:= CharacterTableIsoclinic( CharacterTable( "2.A5.2" ) );
>      if tbl mod 3 = fail then
>        Error( CharacterTable( "Isoclinic(2.A5.2)" ), " mod 3" );
>      fi;
>      SourceOfIsoclinicTable( tbl );
>    fi;
gap> tbl:= CharacterTable( Group( () ) );;
gap> ClassPositionsOfElementaryAbelianSeries( tbl );;


# 2005/08/25 (JS)
gap> G := Group((1,2));; PrimePGroup(G);
2
gap> PrimePGroup(Subgroup(G,[])); # returns 2 in 4.4.5
fail


# 2005/08/25 (JS)
gap> HasIsPGroup( SylowSubgroup( SymmetricGroup( 5 ), 5 ) ); # false in 4.4.5
true


# 2005/08/26 (Max)
gap> IsOperation(MutableCopyMat);
true


# 2005/08/29 (TB)
gap> LoadPackage( "ctbllib", "=0.0" );
fail


# For new features:


# 2005/06/08 (SL)
gap> gamma := [[2,5],[3],[4,5],[1],[]];
[ [ 2, 5 ], [ 3 ], [ 4, 5 ], [ 1 ], [  ] ]
gap> STRONGLY_CONNECTED_COMPONENTS_DIGRAPH(gamma);
[ [ 5 ], [ 1, 2, 3, 4 ] ]


# 2005/07/18 (FL)
# takes too long in repeatedly running  tests
# IsProbablyPrimeInt(2^9689-1);


# 2005/07/20 (SK), 2009/09/28 (AK)
gap> if VERSION = "4.dev" then Float := MACFLOAT_STRING; fi;
gap> Float("355")/Float("113");
3.14159
gap> Rat(last);
355/113
gap> 1/4*last2;
0.785398


# 2005/07/20 (SK)
gap> PadicValuation(288/17,2);
5


# 2005/07/20 (TB)
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
gap> A:= AlgebraByStructureConstants( Rationals, T );;  A.1;
v.1


# 2005/07/21 (FL)
gap> IsCheapConwayPolynomial(5, 55);
true
gap> IsCheapConwayPolynomial(2, 108);
true


# 2005/07/22 (SK)
gap> EpimorphismFromFreeGroup(SymmetricGroup(4));
[ x1, x2 ] -> [ (1,2,3,4), (1,2) ]


# 2005/07/22 (SK)
gap> ForAll([Lambda,Phi,Sigma,Tau],IsOperation);
true


# 2005/08/08 (CMRD)
gap> AllPrimitiveGroups( Size, 60 );;
#W  AllPrimitiveGroups: Degree restricted to [ 1 .. 2499 ]


# 2005/08/11 (TB)
gap> DeclareGlobalVariable( "TestVariable" );
gap> InstallFlushableValue( TestVariable, rec() );
gap> MakeReadWriteGlobal( "TestVariable" );  UnbindGlobal( "TestVariable" );


# 2005/08/11 (TB)
gap> DeclareOperation( "TestOperation", [ IsGroup, IsGroup ] );
gap> InstallMethod( TestOperation, [ "IsGroup and IsAbelian", "IsGroup" ],
>        function( G, H ) return true; end );
gap> MakeReadWriteGlobal( "TestOperation" );  UnbindGlobal( "TestOperation" );


# 2005/08/15 (SK)
gap> List([0..5],i->PartialFactorization(7^64-1,i));
[ [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17,
      1868505648951954197516197706132003401892793036353 ],
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353,
      5293217135841230021292344776577913319809612001 ],
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 134818753, 47072139617,
      531968664833, 1567903802863297 ],
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 1201, 169553, 7699649,
      134818753, 47072139617, 531968664833 ],
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 1201, 169553, 7699649,
      134818753, 47072139617, 531968664833 ],
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 1201, 169553, 7699649,
      134818753, 47072139617, 531968664833 ] ]


# 2005/08/24 (SL, FL)
gap> l:=[1,2];;
gap> Remove(l,1); l;
1
[ 2 ]
gap> Add(l, 100, 1); l;
[ 100, 2 ]


#############################################################################
##
##  for changes 4.4.6 -> 4.4.7  (extracted from corresponding dev/Update)

# For fixes:


# 2005/09/07 (TB)
gap> Is8BitMatrixRep( InvariantQuadraticForm( SO( 7, 3 ) ).matrix );
true
gap> Is8BitMatrixRep( InvariantBilinearForm( Sp( 4, 4 ) ).matrix );
true
gap> Is8BitMatrixRep( InvariantSesquilinearForm( SU( 4, 2 ) ).matrix );
true


# 2005/09/13 (AH)
gap> r:=PolynomialRing(Rationals,3);; eo:=EliminationOrdering([2],[3,1]);;


# 2005/09/20 (SK)
gap> # None as the library methods for `NormalSubgroups' apparently obey
gap> # the `rule' that the trivial subgroup appears in the first and the
gap> # whole group appears in the last position.


# 2005/10/05 (SL and MN)
gap> p := PermList(Concatenation([2..10000],[1]));;
gap> for i in [1..10000] do a := p^0; od; time1 := time;;
gap> for i in [1..10000] do a := OneOp(p); od; time2 := time;;
gap> if time1 <= 3 * time2 then Print("Fix worked\n"); fi;
Fix worked


# 2005/10/14 (BH)
gap> IsBoundGlobal ("ComputedInducedPcgses");
true


# 2005/10/14 (BH)
gap> if LoadPackage ("crisp", "1.2.1", false) <> fail then
>     G := DirectProduct(CyclicGroup(2), CyclicGroup(3), SymmetricGroup(4));
>     AllInvariantSubgroupsWithQProperty (G, G, ReturnTrue, ReturnTrue, rec());
>     if ( (1, 5) in EnumeratorByPcgs ( Pcgs( SymmetricGroup (4) ) ) ) then
>      Print( "problem with crisp (7)\n" );
>     fi;
>    fi;


# 2005/10/26 (JS)
gap> PolynomialByExtRep(FamilyObj(X(Rationals)),[[1,1],1,[2,1],1]); # x_2+x_1 in 4.4.6
x_1+x_2


# 2005/10/28 (TB)
gap> fail in List( Irr( SymmetricGroup( 3 ) ), Inverse );
true


# 2005/10/28 (TB)
gap> Order( ClassFunction( CyclicGroup( 1 ), [ (1-EI(5))/ER(6) ] ) );
infinity


# 2005/10/28 (TB)
gap> rg:= GroupRing( GF(2), SymmetricGroup( 3 ) );;
gap> i:= Ideal( rg, [ Sum( GeneratorsOfAlgebra( rg ){ [ 1, 2 ] } ) ] );;
gap> Dimension( rg / i );;


# 2005/10/29 (TB)
gap> if LoadPackage( "ctbllib" ) <> fail then
>      t:= CharacterTable( "S12(2)" );  p:= PrevPrimeInt( Exponent( t ) );
>      if not IsSmallIntRep( p ) then
>        PowerMap( t, p );
>      fi;
>    fi;


# 2005/11/22 (TB)
gap> Z(4) in Group( Z(2) );;


# 2005/11/25 (JS)
gap> NrPerfectLibraryGroups(450000);
3
gap> NrPerfectLibraryGroups(962280);
1
gap> NrMovedPoints(PerfectGroup(IsPermGroup,129024,2));
288
gap> NrMovedPoints(PerfectGroup(IsPermGroup,258048,2));
576
gap> NrMovedPoints(PerfectGroup(IsPermGroup,516096,1));
400


# 2005/11/28 (FL)
gap> ConjugacyClasses(SL(2,3))[1];
[ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ]^G


# 2005/11/28 (TB)
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> SetIdentifier( t, "Sym(4)" );
gap> Display( t, rec( classes:= [ 4 ] ) );
Sym(4)

     2  .
     3  1

       3a
    2P 3a
    3P 1a

X.1     1
X.2     .
X.3    -1
X.4     .
X.5     1


# 2005/11/29 (TB)
gap> l:= [ [ 1, 2 ] ];;  CheckFixedPoints( [ 1 ], l, [ 1, 1 ] );;  l;
[ 1 ]


# 2005/11/29 (TB)
gap> IsIdenticalObj( VectorSpace, FreeLeftModule );
false


# 2005/11/29 (TB)
gap> AsGroup( [ 1, -1 ] );
#I  no groups of cyclotomics allowed because of incompatible ^
fail


# 2005/12/21 (BH)
gap> ApplicableMethod (CharacteristicPolynomial, [GF(2), GF(4), [[Z(2)]], 1])=fail;
false


# 2005/12/22 (Robert F. Morse)
gap> t:=Transformation([1,2,3,3]);;
gap> s:=FullTransformationSemigroup(4);;
gap> ld:=GreensDClassOfElement(FullTransformationSemigroup(4),
> Transformation([1,2,3,3]));;
gap> rs:=AssociatedReesMatrixSemigroupOfDClass(ld);;
gap> SandwichMatrixOfReesZeroMatrixSemigroup(rs);
[ [ 0, 0, 0, (), (), () ], [ 0, (), (), 0, 0, () ],
  [ (), 0, (), 0, (1,2)(3,4)(5,6), 0 ],
  [ (), (1,3)(2,5)(4,6), 0, (1,4,5)(2,6,3), 0, 0 ] ]


# 2006/01/11 (MC)
gap> d := DirectoryCurrent();;
gap> f := Filename(DirectoriesSystemPrograms(), "rev");;
gap> if f <> fail then
>      s := InputOutputLocalProcess(d,f,[]);;
>      if PrintFormattingStatus(s) <> false then
>        Print( "unexpected PrintFormattingStatus value\n" );
>      fi;
>      SetPrintFormattingStatus(s,false);
>      AppendTo(s,"The cat sat on the mat\n");
>      if ReadLine(s) <> "tam eht no tas tac ehT\n" then
>        Print( "There is a problem concerning a cat on a mat.\n" );
>      fi;
>      CloseStream(s);
>    fi;


# 2006/01/18 (AH)
gap> G:=WreathProduct(CyclicGroup(3),Group((1,2,3),(4,5,6)));;
gap> Assert(0,Size(Group(GeneratorsOfGroup(G)))=6561);


# 2006/01/25 (TB)
gap> Basis( Rationals );;


# 2006/02/14 (SK)
gap> testG :=
>    function ( a, b )
>      local  M1;
>       M1 := [ [ [      0, -E(a)^-1 ], [ -E(a),       0 ] ],
>               [ [      0,       -1 ], [     1,       0 ] ],
>               [ [ E(4*b),        0 ], [     0, -E(4*b) ] ],
>               [ [     -1,        0 ], [     0,      -1 ] ]];
>       return (Group(M1));
>    end;;
gap> StructureDescription(testG(8,2));
"(C8 x C4) : C2"
gap> StructureDescription(testG(8,3));
"C3 x QD16"
gap> StructureDescription(testG(8,4));
"(C16 x C4) : C2"


# 2006/02/27 (AH)
gap> RepresentativeAction(Group(()), [1], [2], OnSets);;


# 2006/03/02 (AH)
gap> x:=X(Rationals,1);;
gap> y:=X(Rationals,2);;
gap> a:=X(Rationals,3);;
gap> c:=X(Rationals,4);;
gap> s:=X(Rationals,5);;
gap> L:=[(a+c)*s-x,(a+c)*c-y,s^2+c^2-1];;
gap> ReducedGroebnerBasis(L,MonomialLexOrdering([x,y,a,c,s]));
[ c^2+s^2-1, -a*c+s^2+y-1, -a*s-c*s+x ]
gap> ReducedGroebnerBasis(L,MonomialLexOrdering([c,s,x,y,a]));
[ x^4+2*x^2*y^2-x^2*a^2+y^4-y^2*a^2-2*x^2*y-2*y^3+y^2, 
  -x^3-x*y^2+x*a^2+y*a*s+x*y, x^2*y+x*a*s+y^3-y*a^2-x^2-2*y^2+y, 
  x^2*s+y^2*s-x*a-y*s, -x^2-y^2+a^2+s^2+2*y-1, -x^2-y^2+a^2+a*c+y, 
  x*s+y*c-a-c, x*c-y*s, a*s+c*s-x, x^2+y^2-a^2+c^2-2*y ]


# 2006/03/03 (FL)
gap> s := "";; str := OutputTextString(s, false);;
gap> for i in [0..255] do WriteByte(str, i); od;
gap> CloseStream(str);
gap> s = List([0..255], CHAR_INT);
true


# 2006/2/20 (AH)
gap> group1 := Group([ (1,3)(2,5)(4,7)(6,8), (1,4)(2,6)(3,7)(5,8),
> (1,5)(2,3)(4,8)(6,7), (2,3,4,5,7,8,6), (3,4,7)(5,6,8) ]);;
gap> group2 := Group([ (1,3,4,7,2,6,8), (1,8,7,5,3,6,2) ]);;
gap> group3 := SymmetricGroup([1..8]);;
gap> RepresentativeAction(group3,group1,group2);
fail


# 2006/03/08 (SL)
gap> Z(3,30);
z


# For new features:


# 2005/12/08 (TB)
gap> if LoadPackage( "ctbllib" ) <> fail then
>      if List( Filtered( Irr( CharacterTable( "Sz(8).3" ) mod 3 ),
>                         x -> x[1] = 14 ), ValuesOfClassFunction )
>         <> [ [ 14, -2, 2*E(4), -2*E(4), -1, 0, 1 ],
>              [ 14, -2, -2*E(4), 2*E(4), -1, 0, 1 ] ] then
>        Print( "ordering problem in table of Sz(8).3 mod 3\n" );
>      fi;
>    fi;


# 2005/12/08 (TB)
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> SetIdentifier( t, "Sym(4)" );  Display( t,
>     rec( powermap:= "ATLAS", centralizers:= "ATLAS", chars:= false ) );
Sym(4)

    24  4  8  3  4

 p      A  A  A  B
 p'     A  A  A  A
    1A 2A 2B 3A 4A



# 2005/12/08 (TB, Michael Hartley (implementation of a prototype))
gap> LowIndexSubgroupsFpGroupIterator;;


# 2005/12/22 (Robert F. Morse)
gap> g := Image(IsomorphismFpGroup(SmallGroup(8,3)));;
gap> h := Image(IsomorphismFpGroup(SmallGroup(120,5)));;
gap> fp := FreeProduct(g,h);;
gap> IsFpGroup(fp);
true
gap> emb := Embedding(fp,1);;
gap> IsMapping(emb);
true
gap> dp := DirectProduct(g,h);;
gap> IsFpGroup(dp);
true
gap> IdGroup(dp);
[ 960, 5746 ]
gap> IdGroup(Image(Projection(dp,2)));
[ 120, 5 ]
gap> IdGroup(Image(Embedding(dp,1)));
[ 8, 3 ]


# 2005/12/28 (FL)
gap> IsCheapConwayPolynomial(2,114);
true


#############################################################################
##
##  for changes 4.4.7 -> 4.4.8  (extracted from corresponding dev/Update)


# For fixes:


# 2006/04/07 (TB)
gap> G:= SymmetricGroup(3);;
gap> m:= InnerAutomorphism( G, (1,2) );;
gap> n:= TransformationRepresentation( InnerAutomorphism( G, (1,2,3) ) );;
gap> m * n;;  n * m;;


# 2006/04/18 (SK)
gap> gp := FreeGroup(1);; Size(gp);;
gap> DirectProduct(gp,gp);
<fp group of size infinity on the generators [ f1, f2 ]>


# 2006/04/18 (TB)
gap> Decomposition( [ [1,1], [E(3),E(3)^2] ], [ [1,-1] ], 1 );
[ fail ]


# 2006/05/12 (TB)
gap> Center( OctaveAlgebra( GF(13) ) );;


# 2006/07/25 (AH)
gap> g:=TransitiveGroup(10,8);;
gap> ConjugatorOfConjugatorIsomorphism(ConjugatorAutomorphism(g,(4,9)));
(1,6)(2,7)(3,8)(5,10)


# 2006/07/27 (SK)
gap> IsPolycyclicGroup(SymmetricGroup(4));
true
gap> IsPolycyclicGroup(SymmetricGroup(5));
false
gap> IsPolycyclicGroup(Group([[1,1],[0,1]]));
true
## 2006/09/20 (JJM)
## comment out this test, since it will not complete without Polenta.
#gap> IsPolycyclicGroup(Group([[1,1],[0,1]],[[0,1],[1,0]]));
#false


# 2006/07/28 (RFM)
gap> g := CyclicGroup(1);;
gap> SchurCover(g);;
gap> sc := SchurCover(g);;
gap> IdGroup(sc);
[ 1, 1 ]
gap> epi := EpimorphismSchurCover(g);;
gap> Image(epi)=g;
true
gap> IdGroup(Source(epi));
[ 1, 1 ]
gap> G := SmallGroup(27,3);;
gap> IsCentralFactor(G);
true
gap> AbelianInvariantsMultiplier(G);
[ 3, 3 ]
gap> AbelianInvariants(Kernel(EpimorphismNonabelianExteriorSquare(G)));
[ 3, 3 ]
gap> ec := Epicentre(DirectProduct(CyclicGroup(25),CyclicGroup(5)));;
gap> IsTrivial(ec);
false
gap> ec := Epicentre(DirectProduct(CyclicGroup(3),CyclicGroup(3)));;
gap> IsTrivial(ec);
true


# 2006/08/19 (Max)
gap> m := [[1]];;
gap> IsMutable(m^1);
true


# 2006/08/19 (Max)
gap> IsOperation(StripMemory);
true


# 2006/08/22 (Max)
gap> "IS_BLIST_REP" in NamesFilter(TypeObj(BlistList([1,2],[2]))![2]);
true


# 2006/08/28 (FL)
gap> for i in [1..10000] do a := PositionSorted(l,[i]); od; time1 := time;;
gap> l := Immutable(l);;
gap> for i in [1..10000] do a := PositionSorted(l,[i]); od; time2 := time;;
gap> time1 < 2*time2; # time1 and time2 should be about the same
true


# 2006/08/29 (FL (and AH))
gap> IsBound(ITER_POLY_WARN);
true


# 2006/08/28 (SL)

gap> a := -70170876888665790351719387465587751111897440176;;
gap> b := -24507694029460834590427275534096897425026491796;;
gap> GcdInt(a,b);
4


# 2006/04/02 (AH)
gap> F:=FreeGroup("x","y","z");;
gap> x:=F.1;;y:=F.2;;z:=F.3;;
gap> rels:=[x^2,y^2,z^4,Comm(z^-2,x),(z*x)^4,Comm(z^-1,y)^2,
> (y*x)^4,(Comm(z,y)*x)^2,(Comm(y,z^-1)*x)^2,(y*z)^6,
> z^-1*y*z^-1*x*z*y*z^-1*x*z*y*z^-1*x*z*y*z*x,y*z*x*z*y*x*y*z^-1*x*y*z^-1*x*y*z*x*y*z^-1*x];;
gap> G:=F/rels;;
gap> x:=G.1;;y:=G.2;;z:=G.3;;
gap> s3:=Subgroup(G,[ z*y*z*y^-1, z^-1*y*z^-1*y^-1, y*z*x*z^-1*y^-1*x^-1,
> z*x*y*z*x^-1*y^-1 ]);;
gap> L:=LowIndexSubgroupsFpGroup(G,s3,4);;
gap> Assert(0,Length(L)=27);


# For new features:


# 2006/06/19 (SK)
gap> Positions([1,2,1,2,3,2,2],2);
[ 2, 4, 6, 7 ]
gap> Positions([1,2,1,2,3,2,2],4);
[  ]


# 2006/07/06 (SL)
gap> z := Z(3,10);;
gap> LogFFE(z,z^2);
fail
gap> z := Z(3,11);;
gap> LogFFE(z,z^2);
fail


# 2006/08/16 (FL)
gap> EvalString("1234\\\r\n567");
1234567


# 2006/08/16 (FL)
gap> IsBound(GAPInfo.SystemEnvironment);
true


# 2006/08/28 (FL)
gap> Length(IDENTS_BOUND_GVARS());;
gap> Length(ALL_RNAMES());;


# 2006/08/28 (FL)
gap> IsCheapConwayPolynomial(2,100);
true


# 2006/08/28 (FL)
gap> Random(GlobalMersenneTwister,[1..6]);;


#############################################################################
##
##  for changes 4.4.8 -> 4.4.9  (extracted from corresponding dev/Update)


# 2006/10/04 (TB)
gap> PseudoRandom( AutomorphismGroup( AlternatingGroup( 5 ) ) );;


# 2006/10/23 (FL)
gap> s := "";; for i in [0..255] do Add(s, CHAR_INT(i)); od;
gap> fnam := Filename(DirectoryTemporary(), "guck");;
gap> FileString(fnam, s);;
gap> f := InputTextFile(fnam);;
gap> List([0..255], i-> ReadByte(f)) = [0..255];
true
gap> RemoveFile(fnam);
true


# 2006/10/31 (FL)
gap> Positions("abcdeca", 'c');
[ 3, 6 ]


# 2006/10/4 (AH)
gap> g:=SmallGroup(1800,646);;c:=CharacterTable(g);;Irr(c);;


#############################################################################
##
##  for changes 4.4.9 -> 4.4.10  (extracted from corresponding dev/Update)

# For fixes:


# 2006/11/13 (AH)
gap> Socle (Group ([[1]]));;


# 2006/11/14 (FL)
gap> DirectoryContents( Filename( DirectoriesLibrary( "" ), "lib" ) );;


# 2007/01/17 (AH)
gap> R := PolynomialRing(GF(4),1);; x := Z(4) * One(R);;
gap> x in DefaultRing(x);
true


# 2007/01/22 (SL)
gap> F := GF(7,3);;
gap> F1 := GF(F,2);;
gap> a := PrimitiveRoot(F1);;
gap> B := Basis(F1);;
gap> Coefficients(B,a^0);
[ z0, 0z ]


# 2007/02/14 (SL)
gap> m:= [ [ Z(2,18)^0, 0*Z(2,18) ], 
>     [ Z(2)^0+Z(2,18)+Z(2,18)^2+Z(2,18)^7+Z(2,18)^8+Z(2,18)^10+Z(2,18)^12
>       +Z(2,18)^14+Z(2,18)^15, Z(2,18)^0 ] ];;
gap> KroneckerProduct( [[Z(2)]], m );  
[ <a GF2 vector of length 2>, [ 1+z+z2+z7+z8+z10+z12+z14+z15, z0 ] ]


# 2007/02/21 (TB)
gap> v:= GF(2)^2;;  bv:= BasisVectors( Basis( v ) );;
gap> IsInjective( LeftModuleGeneralMappingByImages( v, v, bv, 0 * bv ) );
false
gap> map:= LeftModuleGeneralMappingByImages( v, v, 0 * bv, bv );;
gap> ImagesRepresentative( map, Zero( v ) );
[ 0*Z(2), 0*Z(2) ]


# 2007/02/23 (Max)
gap> Enumerator(GF(74761));
<enumerator of GF(74761)>


# 2007/03/12 (SL)

gap> z := Z(3,12)-Z(3,12);
0z
gap> DegreeFFE(z);
1
gap> FFECONWAY.TryToWriteInSmallerField(z,2);
0*Z(3)



# 2007/03/19 (SL)
gap> GF(GF(7^3),2);
AsField( GF(7^3), GF(7^6) )



# 2007/03/20 (SL)

gap> x := Z(2,18)^((2^18-1)/511);;
gap> b := Basis(GF(512));;
gap> Coefficients(b,x);
[ 0z, z0, 0z, 0z, 0z, 0z, 0z, 0z, 0z ]



# 2007/03/26 (AH)
gap> s:=ConjugacyClassSubgroups(
> Group([
>  (2,3)(6,7)(10,11)(14,15),
>  (5,9)(6,10)(7,11)(8,12),
>  (3,5)(4,6)(11,13)(12,14),
>  (1,2)(3,4)(5,6)(7,8)(9,10)(11,12)(13,14)(15,16),
>  (17,18)
> ]),
> Group([
>  (1,16)(2,15)(3,14)(4,13)(5,12)(6,11)(7,10)(8,9),
>  (1,13,16,4)(2,5,15,12)(3,9,14,8)(6,7,11,10)(17,18),
>  (5,9)(6,10)(7,11)(8,12),
>  (2,3)(5,9)(6,11)(7,10)(8,12)(14,15)
> ]))[1];;
gap> IdGroup(s);;
gap> ConjugacyClassesSubgroups(s);;



# 2007/03/30 (TB)
gap> IsSubset( [ [], [1] ], [ [] ] );
true


# 2007/04/02 (FL)
gap> Print(x -> 100000000000, "\n");
function ( x )
    return 100000000000;
end


# 2007/04/18 (FL)
gap> PRINT_PREC(rec(a:=1)); Print("\n");
rec(
  a := 1 )


# 2007/06/14 (FL)
gap> BlistList([1..10],[4234623462462464234242]);
[ false, false, false, false, false, false, false, false, false, false ]


# 2007/07/02 (SK)
gap> GeneratorsOfRing(Rationals);
"TRY_NEXT_METHOD"
gap> GeneratorsOfRingWithOne(Rationals);
"TRY_NEXT_METHOD"


# 2007/07/06 (JS)
gap> PrimitiveGroup(50,4);
PGL(2, 49)
gap> Name(PrimitiveGroup(50,6)) = "PGL(2, 49)";
false


# 2007/07/07 (FL)
gap> OnTuples([,1],());
Error, OnTuples for perm: list must not contain holes


# 2007/07/27 (AH)
gap> H:=GroupByPcgs(Pcgs(AbelianGroup([6,6])));;
gap> K:=SmallGroup(IdGroup(H));;
gap> 1H:=TrivialGModule(H,GF(3));;
gap> 1K:=TrivialGModule(K,GF(3));;
gap> Assert(1,Rank(TwoCohomologySQ(CollectorSQ(H,1H,true),H,1H))=
> Rank(TwoCohomologySQ(CollectorSQ(K,1K,true),K,1K)));


# 2007/08/08 (SL)
gap> l := [1,2,3];;
gap> for i in [2] do Print(IsBound(l[10^20]),"\n"); od;
false


# 2007/08/15 (MN)
gap> Print(ZmodpZObj(2,65537),"\n");
ZmodpZObj( 2, 65537 )
# For new features:


# 2007/03/21 (TB)
gap> IrreducibleModules( DihedralGroup(38), GF(2), 0 );;


# 2007/06/14 (FL)
gap> PositionSublist([1,2,3,4,5,6,7],[4,5,6]);
4


# 2007/08/15 (MN)
gap> l := [1,2,3];
[ 1, 2, 3 ]
gap> MakeImmutable(l);
[ 1, 2, 3 ]


# 2007/08/22 (AD)
gap> f := UnivariatePolynomial( Rationals, [-4,0,0,1] );;
gap> L := AlgebraicExtension( Rationals, f );
<algebraic extension over the Rationals of degree 3>


# 2007/08/28 (TB)
gap> IsDocumentedVariable( "CharacterTableRegular" );
true


# 2007/08/29 (TB)
gap> x:= TrivialCharacter( CharacterTable( SymmetricGroup(4) ) mod 2 );;
gap> ScalarProduct( x, x );;


# 2007/08/29 (TB)
gap> a:= QuaternionAlgebra( [ EB(5) ] );
<algebra-with-one of dimension 4 over NF(5,[ 1, 4 ])>
gap> IsSubset( a, QuaternionAlgebra( Rationals ) );
true


# 2007/08/31 (FL)
gap> # Quotient to yield the same on 32- and 64-bit systems
gap> SHALLOW_SIZE([1])/GAPInfo.BytesPerVariable;
2
gap> SHALLOW_SIZE(List([1..160],i->i^2))/GAPInfo.BytesPerVariable;
161
gap> [ShrinkAllocationPlist, ShrinkAllocationString];;
gap> [EmptyPlist, EmptyString];;                                               


# 2007/08/31 (FL)
gap> IsCheapConwayPolynomial(2,150);
true
gap> IsCheapConwayPolynomial(3,52); 
true


#############################################################################
##
##  for changes 4.4.10 -> 4.4.11  (extracted from corresponding dev/Update)


# For fixes:


# 2007/10/10 (TB)
gap> IsomorphismTypeInfoFiniteSimpleGroup( 1 );;


# 2007/10/15 (FL)
gap> d:=NewDictionary(3213,true);;
gap> LookupDictionary(d,4);
fail


# 2007/12/14 (MN)
gap> a := [1..100];;
gap> MemoryUsage(a)=MemoryUsage(a);
true


# 2008/01/02 (AH)
gap> G:=SmallGroup(1308,1);
<pc group of size 1308 with 4 generators>
gap> Length(Irr(G));
48


# 2008/02/13 (TB)



# 2008/03/19 (TB)
gap> DefiningPolynomial( AsField( GF(9), GF(3^6) ) );
x_1^3+Z(3^2)^6*x_1^2+Z(3^2)*x_1+Z(3^2)^5


# 2008/04/03 (JS)
gap> if LoadPackage( "atlasrep" ) <> fail then
>      g:= Group( AtlasGenerators( "HS", 1, 4 ).generators );
>      ConjugacyClassesMaximalSubgroups( g ); 
>    fi;


# 2008/04/23 (TB)
gap> GeneratorsOfAlgebra( QuaternionAlgebra( GF(17) ) );
[ e, i, j, k ]
gap> GeneratorsOfAlgebra( QuaternionAlgebra( GF(17) ) );
[ e, i, j, k ]


# 2008/06/24 (FL)
# none, we hope that the changed code is never needed!


# 2008/07/20 (Laurent Bartholdi)
gap> Intersection( [ -1 .. 1 ], [ -1 .. 1 ] ); # previously was empty
[ -1 .. 1 ]
gap> Intersection( [ 2, 4 .. 10 ], [ 3 .. 5 ] ); # previously was [ 4, 6 ]
[ 4 ]


# 2008/08/13 (SL)
gap> Z(3,20) + Z(3,20)^0;
1+z
gap> AA := Z(3^10)^30683;
Z(3^10)^30683
gap> BB := Z(3)^0+Z(3^15)^3+Z(3^15)^4+2*Z(3^15)^5+2*Z(3^15)^8+2*Z(3^15)^10+2*Z(3^15)^11+Z(3^15)^13;
1+z3+z4+2z5+2z8+2z10+2z11+z13
gap> AA=BB;
false
gap> RT := Z(3^6);
Z(3^6)
gap> DD := Z(3^12)+Z(3^12)^2+2*Z(3^12)^3+2*Z(3^12)^4+Z(3^12)^5+Z(3^12)^6+Z(3^12)^7+Z(3^12)^8+2*Z(3^12)^9;
z+z2+2z3+2z4+z5+z6+z7+z8+2z9
gap> LogFFE(DD,RT);            
340


# 2008/09/02 (FL)
gap> SmithNormalFormIntegerMatTransforms(
> [ [ 2, 0, 0, 0, 0 ], [ 2, 2, 0, -2, 0 ], [ 0, -2, -2, -2, 0 ],
>   [ 3, 1, -1, 0, -1 ], [ 4, -2, 0, 2, 0 ], [ 3, -1, -1, 2, -1 ],
>   [ 0, 4, -2, 0, 2 ], [ 2, 2, 0, 2, 2 ], [ 0, 0, 0, 0, 0 ],
>   [ 2, 0, -4, -2, 0 ], [ 0, -2, 4, 2, -2 ], [ 2, -2, 0, -2, -1 ],
>   [ 3, -3, -1, 1, 0 ] ]).normal;
[ [ 1, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 2, 0 ], 
  [ 0, 0, 0, 0, 2 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0 ] ]


# 2008/09/10 (TB)
gap> g:= AlternatingGroup( 10 );;                                   
gap> gens:= GeneratorsOfGroup( g );;                                 
gap> hom:= GroupHomomorphismByImagesNC( g, g, gens, gens );;         
gap> IsOne( hom ); # This took (almost) forever before the change ...
true


# 2008/09/10 (TB)
gap> Display( StraightLineProgram( "a(ab)", [ "a", "b" ] ) );
# input:
r:= [ g1, g2 ];
# program:
r[3]:= r[1];
r[4]:= r[1]*r[2];
r[5]:= r[3]*r[4];
# return value:
r[5]


# 2008/09/11 (AH)
gap> x:=Indeterminate(CF(7));;
gap> K:=AlgebraicExtension(CF(7),x^2-3);;
gap> a:=GeneratorsOfField(K)[1];;
gap> x2 := E(7)+a*(E(7)^2+E(7)^3);
(E(7)^2+E(7)^3)*a+E(7)


# 2008/09/18 (AH)
gap> g:=Group((14,15)(16,17), (12,13), (9,10,11), (4,8)(16,17),
> (1,8)(2,3)(4,5)(6,7)(16,17), (1,3)(2,8)(4,6)(5,7)(16,17));;
gap> IsNilpotent(g);
true
# For new features:


# 2008/02/29 (TB)
gap> f:= GF(2);; x:= Indeterminate( f );; p:= x^2+x+1;;
gap> e:= AlgebraicExtension( f, p );;
gap> GeneratorsOfLeftModule( e );;  Basis( e );;  Iterator( e );;


# 2008/03/26 (TB)
gap> FrobeniusCharacterValue( E(55), 2 );
z+z2+z3+z4+z5+z6+z8+z10+z12+z13+z14+z16+z17+z19


# 2008/04/14 (SK)
gap> [[4,5],[5,6]] in GL(2,Integers);
true
gap> [[4,5],[5,6]] in SL(2,Integers);
false


# 2008/04/14 (SK)
gap> String(Integers^3);
"( Integers^3 )"
gap> ViewString(GF(16)^3);
"( GF(2^4)^3 )"
gap> IsRowModule(1);
false


# 2008/04/14 (SK)
gap> G := Group((1,2));;
gap> SetName(G,"C2");
gap> ViewString(G);
"C2"


# 2008/04/15 (SK)
gap> PolynomialRing(GF(2),1);
GF(2)[x_1]
gap> String(PolynomialRing(GF(8),4));
"PolynomialRing( GF(2^3), [ x_1, x_2, x_3, x_4 ] )"
gap> ViewString(PolynomialRing(GF(2),1));
"GF(2)[x_1]"


# 2008/06/05 (FL)
gap> Binomial(2^80,3);
294474510796397388263882186039667753853121547637256443485296081974067200


# 2008/10/01 (TB)
gap> QuaternionAlgebra( Field( [ EB(5) ] ) );;
gap> IsDivisionRing( QuaternionAlgebra( Field( [ EB(5) ] ) ) );
true


# 2008/11/16 (TB)
gap> t:= [ [ 1, 2, 3, 4, 5 ], [ 2, 1, 4, 5, 3 ], [ 3, 5, 1, 2, 4 ],
>          [ 4, 3, 5, 1, 2 ], [ 5, 4, 2, 3, 1 ] ];;
gap> m:= MagmaByMultiplicationTable( t );;
gap> IsAssociative( m );
false
gap> AsGroup( m );
fail


# 2008/11/16 (TB)
gap> att:= NewAttribute( "att", IsObject );
gap> prop1:= NewProperty( "prop1", IsObject );
gap> prop2:= NewProperty( "prop2", IsObject );
gap> InstallTrueMethod( prop2, prop1 );
gap> InstallImmediateMethod( att, Tester( prop2 ), 0, G -> 1 );
gap> # The intended behaviour is that `prop1' implies `prop2',
gap> # and that a known value of `prop2' triggers a method call
gap> # that yields the value for the attribute `att'.
gap> g:= Group( (1,2,3,4), (1,2) );;
gap> Tester( att )( g ); Tester( prop1 )( g ); Tester( prop2 )( g );
false
false
false
gap> Setter( prop1 )( g, true );
gap> # Now `prop1' is `true',
gap> # the logical implication sets also `prop2' to `true',
gap> # thus the condition for the immediate method is satisfied.
gap> Tester( prop1 )( g ); Tester( prop2 )( g );
true
true
gap> Tester( att )( g );  # Here we got `false' before the fix.
true


gap> STOP_TEST( "bugfix.tst", 7621100000 );


##  Reset `GAPInfo.CommandLineOptions.b'.
gap> GAPInfo.CommandLineOptions.b:= BANNER_ORIG;;


#############################################################################
##
#E
