#############################################################################
##
#W  pcgsperm.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file  contains    functions which deal with   polycyclic  generating
##  systems of solvable permutation groups.
##
Revision.pcgsperm_gi :=
    "@(#)$Id$";

#############################################################################
##
#R  IsMemberPcSeriesPermGroup . . . . . . . . . . . . .  members of pc series
##
DeclareRepresentation( "IsMemberPcSeriesPermGroup",
    IsPermGroup, [ "noInSeries" ] );

#############################################################################
##
#F  WordVector( <gens>, <id>, <v> ) . . . . . .  make word from exponent list
##
InstallGlobalFunction( WordVector, function( gens, id, v )
    local  word,  ll,  z;
    
    word := id;
    for ll  in [ 1 .. Length( v ) ]  do
        z := Int( v[ ll ] );
        if z <> 0  then
            word := word * gens[ ll ] ^ z;
        fi;
    od;
    return word;
end );

#############################################################################
##
#F  WordNumber( <gens>, <id>, <num>, <p> )  . . . . . . make word from number
##
InstallGlobalFunction( WordNumber, function( gens, id, num, p )
    local word,  gen;
    
    word := id;
    num := num - 1;
    for gen  in gens  do
        word := word * gen ^ ( num mod p );
        num := QuoInt( num, p );
    od;
    return word;
end );

#############################################################################
##
#F  AddNormalizingElementPcgs( <G>, <z> ) . . . . . cyclic extension for pcgs
##
InstallGlobalFunction( AddNormalizingElementPcgs, function( G, z )
    local   S,  A,  pos,  relord,
            pnt,  orb,  l,  L,  n,  m,  img,  i,  f,  p,  edg;

    S := G;
    A := G;
    pos := 1;
    L := [  ];
    if IsBound( G.relativeOrders )  then  relord := G.relativeOrders;
                                    else  relord := false;             fi;
    
    # Loop over the stabilizer chain.
    while z <> S.identity  do

	# If necessary, extend the stabilizer chain.
        if IsBound( G.base )  then
            ChooseNextBasePoint( S, G.base, [ z ] );
        elif not IsBound( S.stabilizer )  then
            InsertTrivialStabilizer( S, SmallestMovedPoint( z ) );
            Unbind( S.stabilizer.relativeOrders );
        fi;
        
        # Extend the orbit.
        orb := S.orbit;
        pnt := orb[ 1 ];
        l := Length( orb );  Add( L, l );
        n := l;
        m := 1;
        img := pnt / z;
        while not IsBound( S.translabels[ img ] )  do
            orb[ n + 1 ] := img;
            for i  in [ 2 .. l ]  do
                orb[ n + i ] := orb[ n - l + i ] / z;
            od;
            n := n + l;
            m := m + 1;
            img := img / z;
        od;
        
        # Let  $m   =  p_1p_2...p_l$.  Then  instead   of  entering <z>  into
        # '<G>.translabels' <d> times, enter $z^d$ once, for $d=p_1p_2...p_k$
        # (where $k<=l$).
        if m > 1  then
            
            # If <m> = 1, the current level <A> has not been extended and <z>
            # has been shifted  into <w> in  the next level. <w> or something
            # further down, which will extend a  future level, must be put in
            # as a generator here.
            AddSet( S.genlabels, 1 - pos );
            while A.orbit[ 1 ] <> S.orbit[ 1 ]  do
                AddSet( A.genlabels, 1 - pos );
                A := A.stabilizer;
            od;
            A := A.stabilizer;
            
            f := 1;
            for p  in FactorsInt( m )  do
                if relord <> false  then
                    InsertElmList( relord, pos, p );
                fi;
                pos := pos + 1;
                InsertElmList( S.labels, pos, z );
                edg := ListWithIdenticalEntries( l, -pos );
                for i  in f * [ 1 .. m / f - 1 ]  do
                    S.translabels{ orb{ i * l + [ 1 .. l ] } } := edg;
                od;
                f := f * p;
                z := z ^ p;
            od;
    
        fi;

        # Find a cofactor to <z> such that the product fixes <pnt>.
        edg := S.translabels[ pnt ^ z ];
        while edg <> 1  do
            if edg > 1  then  z := z * S.labels[ edg + pos - 1 ];
                        else  z := z * S.labels[ -edg ];       fi;
            edg := S.translabels[ pnt ^ z ];
        od;
    
	# Go down one step in the stabilizer chain.
	S := S.stabilizer;
 
    od;
    
    if pos = 1  then
        return false;
    fi;
    
    # Correct   the `genlabels' and   `translabels'  entries and  install the
    # `generators'.
    S := G;  i := 0;  pos := pos - 1;
    while IsBound( S.stabilizer )  do
        p := PositionSorted( S.genlabels, 2 );
        if not IsEmpty( S.genlabels )
           and S.genlabels[ 1 ] < 1  then
            S.genlabels[ 1 ] := 2 - S.genlabels[ 1 ];
        fi;
        orb := [ p .. Length( S.genlabels ) ];
        S.genlabels{ orb } := S.genlabels{ orb } + pos;
        if i < Length( L )  then  i := i + 1;  l := L[ i ];
                            else  l := Length( S.orbit );    fi;
        orb := S.orbit{ [ 2 .. l ] };
        S.translabels{ orb } := S.translabels{ orb } + pos;
        orb := S.orbit{ [ l + 1 .. Length( S.orbit ) ] };
        S.translabels{ orb } := -S.translabels{ orb };
        S.transversal := [  ];
        S.transversal{ S.orbit } := S.labels{ S.translabels{ S.orbit } };
        S.generators := S.labels{ S.genlabels };
        S := S.stabilizer;
    od;
    
    return true;
end );

#############################################################################
##
#F  ExtendSeriesPermGroup( ... )  . . . . . . extend a series of a perm group
##
InstallGlobalFunction( ExtendSeriesPermGroup, function(
            G,       # the group in which factors are to be normal/central
            series,  # the series being constructed
            cent,    # flag: true if central factors are wanted
            desc,    # flag: true if a fastest-descending series is wanted
            elab,    # flag: true if elementary abelian factors are wanted
            s,       # the element to be added to `series[ <lev> ]'
            lev,     # the level of the series which is to be extended
            dep,     # the depth of <s> in <G>
            bound )  # a bound on the depth, for solvability/nilpotency tests
                         
    local   M0,  M1,  C,  X,  oldX,  T,  t,  u,  w,  r,  done,
            ndep,  ord,  gcd,  p;
    
    # If we are too deep in the derived series, give up.
    if dep > bound  then
        return s;
    fi;
    
    if desc  then
        
        # If necessary, add a new (trivial) subgroup to the series.
        if lev + 2 > Length( series )  then
            series[ lev + 2 ] := StructuralCopy( series[ lev + 1 ] );
        fi;
    
        M0 := series[ lev + 1 ];
        M1 := series[ lev + 2 ];
        X := M0.labels{ [ 2 .. Length( M0.labels )
                             - Length( M1.labels ) + 1 ] };
        r := lev + 2;
        
    # If the  series  need not be   fastest-descending, prepare to add  a new
    # group to the list.
    else
        M1 := series[ 1 ];
        M0 := StructuralCopy( M1 );
        X := [  ];
        r := 1;
    fi;
    
    # For elementary abelian factors, find a suitable prime.
    if IsInt( elab )  then
        p := elab;
    elif elab  then
        
        # For central series, the prime must be given.
        if cent  then
          Error("cannot construct central el ab series with varying primes");
        fi;
      
        ord := OrderPerm( s );
        if not IsEmpty( X )  then
            gcd := GcdInt( ord, OrderPerm( X[ 1 ] ) );
            if gcd <> 1  then
                ord := gcd;
            fi;
        fi;
        p := FactorsInt( ord )[ 1 ];
    fi;
    
    # Loop over all conjugates of <s>.
    C := [ s ];
    while not IsEmpty( C )  do
        t := C[ 1 ];
        C := C{ [ 2 .. Length( C ) ] };
        if not MembershipTestKnownBase( M0, G, t )  then
            
            # Form  all necessary  commutators with  <t>   and for elementary
            # abelian factors also a <p>th power.
            if cent  then  T := SSortedList( GeneratorsOfGroup( G ) );
                     else  T := SSortedList( X );                       fi;
            done := false;
            while not done  and  ( not IsEmpty( T )  or  elab <> false )  do
                if not IsEmpty( T )  then
                    u := T[ 1 ];        RemoveSet( T, u );
                    w := Comm( t, u );  ndep := dep + 1;
                else
                    done := true;
                    w := t ^ p;         ndep := dep;
                fi;
            
                # If   the commutator or  power  is not  in <M1>, recursively
                # extend <M1>.
                if not MembershipTestKnownBase( M1, G, w )  then
                    w := ExtendSeriesPermGroup( G, series, cent,
                                 desc, elab, w, lev + 1, ndep, bound );
                    if w <> true  then
                        return w;
                    fi;
                    M1 := series[ r ];
                    
                    # The enlarged <M1> also pushes up <M0>.
                    M0 := StructuralCopy( M1 );
                    oldX := X;
                    X := [  ];
                    for u  in oldX  do
                        if AddNormalizingElementPcgs( M0, u )  then
                            Add( X, u );
                        else
                            RemoveSet( T, u );
                        fi;
                    od;
                    if MembershipTestKnownBase( M0, G, t )  then
                        done := true;
                    fi;
                fi;
                
            od;
            
            # Add <t> to <M0> and register its conjugates.
            if AddNormalizingElementPcgs( M0, t )  then
                Add( X, t );
            fi;
            UniteSet( C, List( GeneratorsOfGroup( G ), g -> t ^ g ) );
            
        fi;
    od;

    # For a fastest-descending series,  replace the old group. Otherwise, add
    # the new group to the list.
    if desc  then
        series[ lev + 1 ] := M0;
        if IsEmpty( X )  then
            RemoveElmList( series, lev + 2 );
        fi;
    else
        if not IsEmpty( X )  then
            InsertElmList( series, 1, M0 );
        fi;
    fi;
    
    return true;
end );

#############################################################################
##
#F  TryPcgsPermGroup(<G>, <cent>, <desc>, <elab>) . . try to construct a pcgs
##
InstallGlobalFunction(TryPcgsPermGroup,function( G, cent, desc, elab )
    local   grp,  pcgs,  U,  oldlen,  series,  y,  w,  whole,
            bound,  deg,  step,  i,  S,  filter;

    # If the last member <U> of the series <G> already has a pcgs, start with
    # its stabilizer chain.
    if IsList( G )  then
        U := G[ Length( G ) ];
        if HasPcgs( U )  and  IsPcgsPermGroupRep( Pcgs( U ) )  then
            U := CopyStabChain( Pcgs( U )!.stabChain );
        fi;
    else
        U := TrivialSubgroup( G );
        if IsTrivial( G )  then  G := [ G ];
                           else  G := [ G, U ];  fi;
    fi;
    
    # Otherwise start  with stabilizer chain  of  <U> with identical `labels'
    # components on all levels.
    if IsGroup( U )  then                               
        if IsTrivial( U )  and  not HasStabChainMutable( U )  then
            U := EmptyStabChain( [  ], One( U ) );
        else
	    S:=U;
            U := StabChainMutable( U );
            if IsBound( U.base )  and Length(U.base)>0  then  i := U.base;
                                  else  i := fail;   fi;

	    # ensure compatible bases
	    if HasBaseOfGroup(G[1])
	       and not IsSubset(BaseOfGroup(G[1]),BaseStabChain(U)) then

	      # ensure compatible bases

	      # compute a new stab chain without touching the stab chain
	      # stored in S
	      #T this is less than satisficial but I don't see how otherwise
	      #T to avoid those %$#@ side effects. AH
	      U:= StabChainOp( GroupByGenerators(GeneratorsOfGroup(S),One(S) ),
	                     rec(base:=BaseOfGroup(G[1]),size:=Size(S)));
	    else
	      U := StabChainBaseStrongGenerators( BaseStabChain( U ),
			   StrongGeneratorsStabChain( U ),U.identity );
	      if i <> fail  then
		  U.base := i;
	      fi;
	   fi;
        fi;
    fi;

    
    # The `genlabels' at every level of $U$ must be sets.
    S := U;
    while not IsEmpty( S.genlabels )  do
        Sort( S.genlabels );
        S := S.stabilizer;
    od;

    grp := G[ 1 ];
    whole := IsTrivial( G[ Length( G ) ] );
    
    oldlen := Length( U.labels );
    series := [ U ];
    series[ 1 ].relativeOrders := [  ];

    if not IsTrivial( grp )  then
        
        # The derived  length of  <G> was  bounded by  Dixon. The  nilpotency
        # class of <G> is at most Max( log_p(d)-1 ).
        deg := NrMovedPoints( grp );
        if cent  then
            bound := Maximum( List( Collected( FactorsInt( deg ) ), p ->
                             p[ 1 ] ^ ( LogInt( deg, p[ 1 ] ) - 1 ) ) );
        else
            bound := Int( LogInt( deg ^ 5, 3 ) / 2 );
        fi;
        if     HasSize( grp )
           and Length( FactorsInt( Size( grp ) ) ) < bound  then
            bound := Length( FactorsInt( Size( grp ) ) );
        fi;
        
        for step  in Reversed( [ 1 .. Length( G ) - 1  ] )  do
            for y  in GeneratorsOfGroup( G[ step ] )  do
                if not y in GeneratorsOfGroup( G[ step + 1 ] )  then
                    w := ExtendSeriesPermGroup( G[ step ], series, cent,
                                 desc, elab, y, 0, 0, bound );
                    if w <> true  then
                        SetIsNilpotentGroup( grp, false );
                        if not cent  then
                            SetIsSolvableGroup( grp, false );
                        fi;
                        
                        # In case of  failure, return two ``witnesses'':  The
                        # pcgs   of   the solvable  normal   subgroup  of <G>
                        # constructed    so   far,     and   an  element   in
                        # $G^{(\infty)}$.
#T this should be cleaned up.
                        return [ PcgsStabChainSeries( IsPcgsPermGroupRep,
                                 GroupStabChain( grp, series[ 1 ], true ),
                                 series, oldlen ),
                                 w ];
                        
                    fi;
                fi;
            od;
        od;
    fi;
    
    # Construct the pcgs object.
    if whole  then  filter := IsPcgsPermGroupRep;
              else  filter := IsModuloPcgsPermGroupRep;  fi;

    if elab=true then
      filter:=filter and IsPcgsElementaryAbelianSeries;
    fi;

    if cent then
      filter:=filter and IsPcgsCentralSeries;
    fi;

    pcgs := PcgsStabChainSeries( filter, grp, series, oldlen );

    if whole  then
        SetIsSolvableGroup( grp, true );
        SetPcgs( grp, pcgs );
        if cent  then
            SetIsNilpotentGroup( grp, true );
        fi;
    else
        pcgs!.denominator := G[ Length( G ) ];
        if     HasIsSolvableGroup( G[ Length( G ) ] )
           and IsSolvableGroup( G[ Length( G ) ] )  then
            SetIsSolvableGroup( grp, true );
        fi;
    fi;
    return pcgs;
end);

#############################################################################
##
#F  PcgsStabChainSeries( <filter>, <G>, <series>, <oldlen> )  .
##
InstallGlobalFunction( PcgsStabChainSeries, function( filter, G, series, oldlen )
    local   pcgs,  first,  i;

    first := [  ];
    for i  in [ 1 .. Length( series ) ]  do
      Add( first, Length( series[ i ].labels ) );
    od;
    
    pcgs := PcgsByPcSequenceCons(
		IsPcgsDefaultRep,
		IsPcgs and filter and IsPrimeOrdersPcgs 
		  and HasIndicesNormalSteps,
		ElementsFamily( FamilyObj( G ) ),
		series[ 1 ].labels
		{ 1 + [ 1 .. Length(series[ 1 ].labels) - oldlen ] },
                [IndicesNormalSteps, first[ 1 ] - first + 1] );

    SetRelativeOrders(pcgs, series[ 1 ].relativeOrders);
    pcgs!.stabChain := series[ 1 ];
    pcgs!.generatingSeries:=series;

#    if HasHomePcgs(G) and HomePcgs(G)<>pcgs then
#      G:=Group(series[1].generators,());
#    fi;
#    SetGroupOfPcgs( pcgs, G );

    return pcgs;
end );

NorSerPermPcgs:=function(pcgs)
local series,G,i;
  G:=GroupOfPcgs(pcgs);
  series:=pcgs!.generatingSeries;
  for i  in [ 1 .. Length( series ) ]  do
        Unbind( series[ i ].relativeOrders );
        Unbind( series[ i ].base           );
        series[ i ] := GroupStabChain( G, series[ i ], true );
        SetHomePcgs ( series[ i ], pcgs );
        SetFilterObj( series[ i ], IsMemberPcSeriesPermGroup );
        series[ i ]!.noInSeries := i;
  od;
  return series;
end;

InstallMethod(NormalSeriesByPcgs,"perm group rep",true,
   [IsPcgs and IsPcgsPermGroupRep],0, NorSerPermPcgs);

InstallOtherMethod(NormalSeriesByPcgs,"perm group modulo rep",true,
  [IsModuloPcgsPermGroupRep],0,
NorSerPermPcgs);

#############################################################################
##
#F  TailOfPcgsPermGroup( <pcgs>, <from> ) . . . . . . . . construct tail pcgs
##
InstallGlobalFunction( TailOfPcgsPermGroup, function( pcgs, from )
    local   tail,  i;
    
    i := 1;
    while IndicesNormalSteps( pcgs )[ i ] < from  do
        i := i + 1;
    od;
    tail := PcgsByPcSequenceCons(
	    IsPcgsDefaultRep,
	    IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs
	      and HasIndicesNormalSteps 
	      and HasNormalSeriesByPcgs,
	    FamilyObj( OneOfPcgs( pcgs ) ),
	    pcgs{[IndicesNormalSteps(pcgs)[i]..Length(pcgs)]},
	    [ IndicesNormalSteps,
	      IndicesNormalSteps(pcgs){[i..Length(IndicesNormalSteps(pcgs))]},
	    NormalSeriesByPcgs,
	      NormalSeriesByPcgs(pcgs){[i..Length(IndicesNormalSteps(pcgs))]}]);

    SetRelativeOrders(tail,RelativeOrders(pcgs){[from..Length(pcgs)]});
    tail!.stabChain := StabChainMutable( NormalSeriesByPcgs( pcgs )[ i ] );
    if from < IndicesNormalSteps( pcgs )[ i ]  then
        tail := ExtendedPcgs( tail,
                        pcgs{ [ from .. IndicesNormalSteps( pcgs )[ i ] - 1 ] } );
    fi;
    return tail;
end );

#############################################################################
##
#F  PcgsMemberPcSeriesPermGroup( <U> ) . . . . pcgs for a group in the series
##
InstallGlobalFunction( PcgsMemberPcSeriesPermGroup, function( U )
    local   home,  pcgs,npf;

    home := HomePcgs( U );
    npf:=IndicesNormalSteps(home);

    if U!.noInSeries>Length(npf) then
      # special treatment for the trivial subgroup
      pcgs:=InducedPcgsByGenerators(home,GeneratorsOfGroup(U));
    else
      pcgs := TailOfPcgsPermGroup( home,
		      IndicesNormalSteps( home )[ U!.noInSeries ] );
    fi;
    SetGroupOfPcgs( pcgs, U );
    return pcgs;
end );

#############################################################################
##
#F  ExponentsOfPcElementPermGroup( <pcgs>, <g>, <min>, <max>, <mode> )  local
##
InstallGlobalFunction( ExponentsOfPcElementPermGroup,
    function( pcgs, g, mindepth, maxdepth, mode )
    local   exp,  base,  bimg,  r,  depth,  img,  H,  bpt,  gen,  e,  i;
    
    if mode = 'e'  then
        exp := ListWithIdenticalEntries( maxdepth - mindepth + 1, 0 );
    fi;
    base  := BaseStabChain( pcgs!.stabChain );
    bimg  := OnTuples( base, g );
    r     := Length( base );
    depth := mindepth;
    
    while depth <= maxdepth  do
        
        # Determine the depth of <g>.
        repeat
            img := ShallowCopy( bimg );
            gen := pcgs!.pcSequence[ depth ];
            depth := depth + 1;
        
            # Find the base level of the <depth>th generator, remove the part
            # of <g> moving the earlier basepoints.
            H := pcgs!.stabChain;
            bpt := H.orbit[ 1 ];
            i := 1;
            while bpt ^ gen = bpt  do
                while img[ i ] <> bpt  do
                    img{ [ i .. r ] } := OnTuples( img{ [ i .. r ] },
                                                 H.transversal[ img[ i ] ] );
                od;
                H := H.stabilizer;
                bpt := H.orbit[ 1 ];
                i := i + 1;
            od;
            
        until depth > maxdepth  or  H.translabels[ img[ i ] ] = depth;
        
        # If  `H.translabels[  img[  i ] ]  =   depth', then <g>  is  not the
        # identity.
        if H.translabels[ img[ i ] ] = depth  then
            if mode = 'd'  then
                return depth - 1;
            fi;
           
            # Determine the <depth>th exponent.
            e := RelativeOrders( pcgs )[ depth - 1 ];
            i := img[ i ];
            repeat
                e := e - 1;
                i := i ^ gen;
            until H.translabels[ i ] <> depth;
            
            if mode = 'l'  then
                return e;
            fi;
            
            # Remove the appropriate  power  of the <depth>th  generator  and
            # iterate.
            exp[ depth - mindepth ] := e;
            g := LeftQuotient( gen ^ e, g );
            bimg := OnTuples( base, g );
            
        fi;
    od;
    if   mode = 'd'  then  return maxdepth + 1;
    elif mode = 'l'  then  return fail;
    else                   return exp;  fi;
end );

#############################################################################
##
#F  PcGroupPcgs( <pcgs>, <index>, <isPcgsCentral> )  . .  pcp group from pcgs
##
InstallGlobalFunction( PcGroupPcgs, function( pcgs, index, isPcgsCentral )
    local   m,  sc,  gens,  p,  start,  i,  i2,  n,  n2;

    m := Length( pcgs );
    sc := SingleCollector( FreeGroup( m ), RelativeOrders( pcgs ) );

    # Find the relations of the p-th powers. Use  the  vector space structure
    # of the elementary abelian factors.
    for i  in [ 1 .. Length( index ) - 1 ]  do
        p := RelativeOrders( pcgs )[ index[ i ] ];
        start := index[ i + 1 ];
        gens := GeneratorsOfRws( sc ){ [ start .. m ] };
        for n  in [ index[ i ] .. index[ i + 1 ] - 1 ]  do
            SetPowerNC( sc, n, WordVector
                    ( gens, ReducedOne( sc ), ExponentsOfPcElementPermGroup
                      ( pcgs, pcgs[ n ] ^ p, start, m, 'e' ) ) );
        od;
    od;

    # Find the relations of the conjugates.
    for i  in [ 1 .. Length( index ) - 1 ]  do
        for n  in [ index[ i ] .. index[ i + 1 ] - 1 ]  do
            for i2  in [ 1 .. i - 1 ]  do
                if isPcgsCentral then
                    start := index[ i + 1 ];
                    gens := GeneratorsOfRws( sc ){ [ start .. m ] };
                    for n2  in [ index[ i2 ] .. index[ i2 + 1 ] - 1 ]  do
                        SetConjugateNC( sc, n, n2, WordVector( gens,
                            GeneratorsOfRws( sc )[ n ],
                            ExponentsOfPcElementPermGroup( pcgs, Comm
                            ( pcgs[ n ], pcgs[ n2 ] ), start, m, 'e' ) ) );
                    od;
                else
                    start := index[ i2 + 1 ];
                    gens := GeneratorsOfRws( sc ){ [ start .. m ] };
                    for n2  in [ index[ i2 ] .. index[ i2 + 1 ] - 1 ]  do
                        SetConjugateNC( sc, n, n2, WordVector( gens,
                            ReducedOne( sc ), ExponentsOfPcElementPermGroup
                            ( pcgs,
                              pcgs[ n ] ^ pcgs[ n2 ], start, m, 'e' ) ) );
                    od;
                fi;
            od;
            start := index[ i + 1 ];
            gens := GeneratorsOfRws( sc ){ [ start .. m ] };
            for n2  in [ index[ i ] .. n - 1 ]  do
                SetConjugateNC( sc, n, n2, WordVector
                    ( gens, GeneratorsOfRws( sc )[ n ],
                      ExponentsOfPcElementPermGroup( pcgs, Comm
                      ( pcgs[ n ], pcgs[ n2 ] ), start, m, 'e' ) ) );
            od;
        od;
    od;
    UpdatePolycyclicCollector( sc );
    return GroupByRwsNC( sc );
end );

#############################################################################
##
#F  SolvableNormalClosurePermGroup( <G>, <H> )  . . . solvable normal closure
##
InstallGlobalFunction( SolvableNormalClosurePermGroup, function( G, H )
    local   U,  oldlen,  series,  bound,  z,  S;

    U := CopyStabChain( StabChainMutable( TrivialSubgroup( G ) ) );
    oldlen := Length( U.labels );
    
    # The `genlabels' at every level of $U$ must be sets.
    S := U;
    while not IsEmpty( S.genlabels )  do
        Sort( S.genlabels );
        S := S.stabilizer;
    od;

    if HasBaseOfGroup(G) and not IsSubset(G,BaseStabChain(U)) then
      Error("incompatible bases");
    fi;

    U.relativeOrders := [  ];
    series := [ U ];
    
    # The derived length of <G> is at most (5 log_3(deg(<G>)))/2 (Dixon).
    bound := Int( LogInt( Maximum(1,NrMovedPoints( G ) ^ 5), 3 ) / 2 );
    if     HasSize( G )
       and Length( FactorsInt( Size( G ) ) ) < bound  then
        bound := Length( FactorsInt( Size( G ) ) );
    fi;
    
    if IsGroup( H )  then
        H := GeneratorsOfGroup( H );
    fi;
    for z  in H  do
        if ExtendSeriesPermGroup( G, series, false, false, false, z, 0, 0,
                   bound ) <> true  then
            return fail;
        fi;
    od;
    
    U := GroupStabChain( G, series[ 1 ], true );
    SetIsSolvableGroup( U, true );
    SetIsNormalInParent( U, true );
    return U;
end );

#############################################################################
##
#M  <pcgsG> mod <pcgsN> . . . . . . . . . . . . . . . . .  of perm group pcgs
##
InstallMethod( \mod, "perm group pcgs", IsIdenticalObj,
        [ IsPcgs and IsPcgsPermGroupRep,
          IsPcgs and IsPcgsPermGroupRep ], 20,
    function( G, N )
    local   pcgs,  i;

    if G{ [ Length( G ) - Length( N ) + 1 .. Length( G ) ] } = N  then

      i := 1;
      while Length( G ) - IndicesNormalSteps( G )[ i ] >= Length( N )  do
	  i := i + 1;
      od;

      pcgs:=G{ [ 1 .. Length( G ) - Length( N ) ] };
      pcgs := PcgsByPcSequenceCons(
	      IsPcgsDefaultRep,
	      IsPcgs and IsModuloPcgsPermGroupRep and
	      IsModuloPcgs and IsPrimeOrdersPcgs
		and HasIndicesNormalSteps 
		and HasNormalSeriesByPcgs,
	      FamilyObj( OneOfPcgs( G ) ),
	      pcgs,
	      [IndicesNormalSteps, Concatenation( IndicesNormalSteps( G )
		      { [ 1 .. i - 1 ] }, [ Length( pcgs ) + 1 ] ),
	      NormalSeriesByPcgs, Concatenation( NormalSeriesByPcgs( G )
		      { [ 1 .. i - 1 ] }, [ GroupOfPcgs( N ) ] )]);

      SetRelativeOrders(pcgs, RelativeOrders( G ){ [ 1..Length(pcgs) ] });
      pcgs!.stabChain := G!.stabChain;

    else
        pcgs := PcgsByPcSequenceCons(
                IsPcgsDefaultRep,
                IsPcgs and IsModuloPcgsPermGroupRep and
                IsModuloPcgs and IsPrimeOrdersPcgs
		  and HasIndicesNormalSteps 
		  and HasNormalSeriesByPcgs,
                FamilyObj( OneOfPcgs( G ) ),
                [  ],
		[IndicesNormalSteps, [ 1 ],
		NormalSeriesByPcgs, [ GroupOfPcgs( N ) ]] );

	SetRelativeOrders(pcgs, [  ]);
        pcgs!.stabChain := N!.stabChain;
        pcgs := ExtendedPcgs( pcgs, G );
    fi;
    SetGroupOfPcgs( pcgs, GroupOfPcgs( G ) );
    SetNumeratorOfModuloPcgs  ( pcgs, G );
    SetDenominatorOfModuloPcgs( pcgs, N );
    pcgs!.denominator := GroupOfPcgs( N );
    return pcgs;
end );

#############################################################################
##
#M  ModuloPcgsByPcSequenceNC( <G>, <U>, <L> ) . . . . . . for perm group pcgs
##
InstallMethod( ModuloPcgsByPcSequenceNC, "perm group pcgs", true,
        [ IsPcgs and IsPcgsPermGroupRep,
          IsPcgs and IsPcgsPermGroupRep,
          IsPcgs and IsPcgsPermGroupRep ], 20,
    function( G, U, L )
    return U mod L;
end );

#############################################################################
##
#M  NumeratorOfModuloPcgs( <pcgs> ) . . . . . . . . . .  for perm modulo pcgs
##
InstallOtherMethod( NumeratorOfModuloPcgs, true,
    [ IsModuloPcgsPermGroupRep ], 0,
    pcgs -> Pcgs( GroupOfPcgs( pcgs ) ) );

#############################################################################
##
#M  DenominatorOfModuloPcgs( <pcgs> ) . . . . . . . . .  for perm modulo pcgs
##
InstallOtherMethod( DenominatorOfModuloPcgs, true,
    [ IsModuloPcgsPermGroupRep ], 0,
    pcgs -> Pcgs( pcgs!.denominator ) );

#############################################################################
##
#M  Pcgs( <G> ) . . . . . . . . . . . . . . . . . . . .  pcgs for perm groups
##
InstallMethod( Pcgs, "Sims's method", true, [ IsPermGroup ],
        100,  # to override method ``from indep. generators of abelian group''
    function( G )
    local   pcgs;
    
    pcgs := TryPcgsPermGroup( G, false, false, false );
    if not IsPcgs( pcgs )  then  return fail;
                           else  return pcgs;  fi;
end );

InstallMethod( Pcgs, "tail of perm pcgs", true,
        [ IsMemberPcSeriesPermGroup ], 100,
        PcgsMemberPcSeriesPermGroup );

#############################################################################
##
#M  GroupOfPcgs( <pcgs> ) . . . . . . . . . . . . . . . . . . for perm groups
##
InstallMethod( GroupOfPcgs, true, [ IsPcgs and IsPcgsPermGroupRep ], 0,
    function( pcgs )
    local   G;
    
    G := GroupStabChain( pcgs!.stabChain );
    SetPcgs( G, pcgs );
    return G;
end );

#############################################################################
##
#M  PcSeries( <pcgs> )  . . . . . . . . . . . . . . . . . . . for perm groups
##
InstallMethod( PcSeries, true, [ IsPcgs and IsPcgsPermGroupRep ], 0,
    function( pcgs )
    local   series,  G,  N,  i;

    G := GroupOfPcgs( pcgs );
    N := CopyStabChain( StabChainMutable( TrivialSubgroup( G ) ) );
    series := [ GroupStabChain( G, CopyStabChain( N ), true ) ];
    for i  in Reversed( [ 1 .. Length( pcgs ) ] )  do
        AddNormalizingElementPcgs( N, pcgs[ i ] );
        Add( series, GroupStabChain( G, CopyStabChain( N ), true ) );
    od;
    return Reversed( series );
end );        

#############################################################################
##
#M  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )  . . . . . . . .  as perm pcgs
##
InstallMethod( InducedPcgsByPcSequenceNC, "tail of perm pcgs", true,
  [ IsPcgsPermGroupRep and IsPrimeOrdersPcgs and IsPcgs,
    IsList and IsPermCollection ], 0,
function( pcgs, pcs )
local   igs,  i,ran;

  i := Position( IndicesNormalSteps( pcgs ), Length( pcgs )-Length( pcs )+1 );
  ran:=[ Length( pcgs ) - Length( pcs ) + 1 .. Length( pcgs ) ];
  if i = fail  or pcgs{ ran } <> pcs  then
    TryNextMethod();
  fi;
  igs := PcgsByPcSequenceCons(
    IsPcgsDefaultRep,
    IsPcgs and IsInducedPcgs and IsInducedPcgsRep and
    IsPrimeOrdersPcgs and IsTailInducedPcgsRep and IsPcgsPermGroupRep
		and HasIndicesNormalSteps 
		and HasNormalSeriesByPcgs and HasParentPcgs,
    FamilyObj( OneOfPcgs( pcgs ) ),
    pcgs{ [ Length( pcgs ) - Length( pcs ) + 1 .. Length( pcgs ) ] },
      [IndicesNormalSteps, IndicesNormalSteps( pcgs )
	      { [ i .. Length( IndicesNormalSteps( pcgs ) ) ] },
      NormalSeriesByPcgs, NormalSeriesByPcgs( pcgs )
	      { [ i .. Length( IndicesNormalSteps( pcgs ) ) ] },
      ParentPcgs, pcgs] );

  SetRelativeOrders(igs, RelativeOrders( pcgs ) { ran });
  igs!.stabChain := StabChainMutable( NormalSeriesByPcgs( pcgs )[ i ] );
  igs!.tailStart := Length( pcgs ) - Length( pcs ) + 1;
  # information many InducedPcgs methods use
  igs!.depthsInParent:=ran;
  igs!.depthMapFromParent:=[];
  igs!.depthMapFromParent{ran}:=[1..Length(igs)];
  igs!.depthMapFromParent[Length(pcgs)+1]:=Length(igs)+1;
  return igs;
end );

#############################################################################
##
#M  InducedPcgsWrtHomePcgs( <U> ) . . . . . . . . . . . . . . . via home pcgs
##
InstallMethod( InducedPcgsWrtHomePcgs, "tail of perm pcgs", true,
        [ IsMemberPcSeriesPermGroup and HasHomePcgs ], 0,
function( U )
local   pcgs,par,ran;
  
  pcgs := PcgsMemberPcSeriesPermGroup( U );
  par:=HomePcgs(U);
  SetFilterObj( pcgs, IsInducedPcgs and IsInducedPcgsRep);
  SetParentPcgs( pcgs,par ) ;
  # information many InducedPcgs methods use
  ran:=[IndicesNormalSteps(par)[U!.noInSeries]..Length(par)];
  pcgs!.depthsInParent:=ran;
  pcgs!.depthMapFromParent:=[];
  pcgs!.depthMapFromParent{ran}:=[1..Length(pcgs)];
  pcgs!.depthMapFromParent[Length(par)+1]:=Length(pcgs)+1;
  pcgs!.tailStart:=IndicesNormalSteps(par)[U!.noInSeries];
  return pcgs;
end );

#############################################################################
##
#M  ExtendedPcgs( <N>, <gens> ) . . . . . . . . . . . . . . .  in perm groups
##
InstallMethod( ExtendedPcgs, "perm pcgs", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
          IsList and IsPermCollection ], 0,
    function( N, gens )
    local   S,  gen,  pcs,  pcgs;

    S := CopyStabChain( N!.stabChain );
    S.relativeOrders := ShallowCopy( RelativeOrders( N ) );
    for gen  in Reversed( gens )  do
        AddNormalizingElementPcgs( S, gen );
    od;
    pcs := S.labels{ [ 2 .. Length( S.labels ) -
                   Length( N!.stabChain.labels ) + Length( N ) + 1 ] };
    if IsInducedPcgs( N )  then
        pcgs := InducedPcgsByPcSequenceNC( ParentPcgs( N ), pcs );
    else
        pcgs := PcgsByPcSequenceCons( IsPcgsDefaultRep,
                        IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
                        FamilyObj( OneOfPcgs( N ) ), pcs,[] );
    fi;
    pcgs!.stabChain := S;
    SetRelativeOrders( pcgs, S.relativeOrders );
    Unbind( S.relativeOrders );
    SetIndicesNormalSteps( pcgs, Concatenation( [ 1 ], IndicesNormalSteps( N ) ) );
    SetNormalSeriesByPcgs( pcgs, Concatenation( [ GroupStabChain( S ) ],
            NormalSeriesByPcgs( N ) ) );
    return pcgs;
end );

#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <g> [ , <from> ] )  . . . . . . for perm groups
##
InstallMethod( DepthOfPcElement, true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm ], 0,
    function( pcgs, g )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Length( pcgs ), 'd' );
end );

InstallOtherMethod( DepthOfPcElement, true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsPosInt ], 0,
    function( pcgs, g, depth )
    return ExponentsOfPcElementPermGroup( pcgs, g, depth, Length( pcgs ),
                   'd' );
end );
    
#############################################################################
##
#M  LeadingExponentOfPcElement( <pcgs>, <g> ) . . . . . . . . for perm groups
##
InstallMethod( LeadingExponentOfPcElement, true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm ], 0,
    function( pcgs, g )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Length( pcgs ), 'l' );
end );
    
#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <g> [ , <poss> ] )  . . . . for perm groups
##
InstallMethod( ExponentsOfPcElement, "perm group", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm ], 0,
    function( pcgs, g )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Length( pcgs ), 'e' );
end );

InstallOtherMethod( ExponentsOfPcElement, "perm group with positions", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsList and IsCyclotomicCollection ], 0,
    function( pcgs, g, poss )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Maximum( poss ), 'e' )
           { poss };
           # was: { poss - Minimum( poss ) + 1 };
end );

InstallOtherMethod( ExponentsOfPcElement, "perm group with 0 positions", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsList and IsEmpty ], 0,
    function( pcgs, g, poss )
    return [  ];
end );

#############################################################################
##
#M  ExponentOfPcElement( <pcgs>, <g>, <pos> ) . . . . . . . . for perm groups
##
InstallMethod( ExponentOfPcElement, true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsPosInt ], 0,
    function( pcgs, g, pos )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, pos, 'e' )[ pos ];
end );

#############################################################################
##
#M  RepresentativeAction( <G>, <d>, <e>, OnPoints )   first compare cycles
##
InstallOtherMethod( RepresentativeActionOp,
    "cycle structure comparison",
    true,
    [ IsPermGroup and CanEasilyComputePcgs,
      IsPerm,
      IsPerm,
      IsFunction ],
    0,

function( G, d, e, opr )
    if opr <> OnPoints  then
        TryNextMethod();
    elif Collected( CycleLengths( d, MovedPoints( G ) ) ) <>
         Collected( CycleLengths( e, MovedPoints( G ) ) )  then
        return fail;
    else
        TryNextMethod();
    fi;
end );

#############################################################################
##
#M  IsomorphismPcGroup( <G> ) . . . . . . . . . . . .  perm group as pc group
##
InstallMethod( IsomorphismPcGroup, true, [ IsPermGroup ], 0,
    function( G )
    local   iso,  A,  pcgs;
    
    # Make  a pcgs   based on  an  elementary   abelian series (good  for  ag
    # routines).
    pcgs:=PcgsElementaryAbelianSeries(G);
    if not IsPcgs( pcgs )  then
	return fail;
    fi;

    # Construct the pcp group <A> and the bijection between <A> and <G>.
    A := PcGroupPcgs( pcgs, IndicesNormalSteps( pcgs ), false );
    iso := GroupHomomorphismByImagesNC( G, A, pcgs, GeneratorsOfGroup( A ) );
    SetIsBijective( iso, true );
    
    return iso;
end );

#############################################################################
##
#M  EpiPcByModpcgs( <G>, <H>, <gens>, <imgs> ) . . . . make GHBI
##
BindGlobal("EpiPcByModpcgs",function( G, H, gens, imgs )
local   filter,  hom,pcgs,imgso,den;
  
  den:=GeneratorsOfGroup(gens!.denominator); # denominator gens
  hom := rec(generators:=Concatenation(gens,den),
             genimages:=Concatenation(imgs,List(den,i->One(H))));
  filter := HasSource and HasRange and IsGroupGeneralMappingByPcgs
            and IsToPcGroupGeneralMappingByImages and IsTotal;

  if IsPermGroup( G )  then
    filter := filter and IsPermGroupGeneralMappingByImages;
  fi;

  pcgs:=[gens,imgs];

  hom.sourcePcgs       := gens;
  hom.sourcePcgsImages := imgs;
  # precompute powers of the pcgs images
  hom.sourcePcgsImagesPowers := List([1..Length(gens)],
	  i->List([1..RelativeOrders(gens)[i]-1], j->imgs[i]^j));

  if HasGeneratorsOfGroup(H) 
      and IsIdenticalObj(GeneratorsOfGroup(H),imgs) then
    imgso:=H;
  else
    imgso:=SubgroupNC( H, imgs);
  fi;
  # we can also get the ImagesSource quickly
  ObjectifyWithAttributes( hom,
  NewType( GeneralMappingsFamily
	  ( ElementsFamily( FamilyObj( G ) ),
	    ElementsFamily( FamilyObj( H ) ) ), filter and HasImagesSource ), 
	    Source,G,
	    Range,H,
	    ImagesSource,imgso);

  SetIsMapping(hom,true);
  return hom;
end );

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . .  for solvable factors
##
NH_TRYPCGS_LIMIT:=30000;
InstallMethod( NaturalHomomorphismByNormalSubgroupOp,
  "try solvable factor for permutation groups",
  IsIdenticalObj, [ IsPermGroup, IsPermGroup ], 0,
    function( G, N )
    local   map,  pcgs,  A;
    
    if Minimum(Index(G,N),NrMovedPoints(G))>NH_TRYPCGS_LIMIT then
      TryNextMethod();
    fi;

    # Make  a pcgs   based on  an  elementary   abelian series (good  for  ag
    # routines).
    pcgs := TryPcgsPermGroup( [ G, N ], false, false, true );
    if not IsModuloPcgs( pcgs )  then
        TryNextMethod();
    fi;

    # Construct the pcp group <A> and the bijection between <A> and <G>.
    A := PcGroupPcgs( pcgs, IndicesNormalSteps( pcgs ), false );
    UseFactorRelation( G, N, A );
    map := EpiPcByModpcgs( G, A, pcgs, GeneratorsOfGroup( A ) );
    SetIsSurjective( map, true );
    SetKernelOfMultiplicativeGeneralMapping( map, N );
    
    return map;
end );

#############################################################################
##
#M  ModuloPcgs( <G>, <N> )
##
InstallMethod( ModuloPcgs, "for permutation groups", IsIdenticalObj,
        [ IsPermGroup, IsPermGroup ], 0,
function( G, N )
local   pcgs;

  # Make  a pcgs   based on  an  elementary   abelian series (good  for  ag
  # routines).
  pcgs := TryPcgsPermGroup( [ G, N ], false, false, true );

  if not IsModuloPcgs( pcgs )  then
      return fail;
  fi;

  # set nomerator and denominator appropriately
  SetNumeratorOfModuloPcgs(pcgs,GeneratorsOfGroup(G));
  SetDenominatorOfModuloPcgs(pcgs,GeneratorsOfGroup(N));

  return pcgs;
end);


#############################################################################
##
#E  pcgsperm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here