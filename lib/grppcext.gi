#############################################################################
##
#W  grppcext.gi                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.grppcext_gi :=
    "@(#)$Id$";

#############################################################################
##
#F FpGroupPcGroupSQ( G ). . . . . . . . .relators according to sq-algorithmus
##
InstallGlobalFunction( FpGroupPcGroupSQ, function( G )
    local F, f, g, n, rels, i, j, w, v, p, k;

    F := FreeGroup( Length(Pcgs(G)) );
    f := GeneratorsOfGroup( F );
    g := Pcgs( G );
    n := Length( g );
    rels := List( [1..n], x -> List( [1..x], y -> false ) );
    for i in [1..n] do
        for j in [1..i-1] do
            w := f[j]^-1 * f[i] * f[j];
            v := ExponentsOfPcElement( g, g[j]^-1 * g[i] * g[j] );
            for k in Reversed( [1..n] ) do
                w := w * f[k]^(-v[k]);
            od;
            rels[i][j] := w;
        od; 
        p := RelativeOrderOfPcElement( g, g[i] );
        w := f[i]^p;
        v := ExponentsOfPcElement( g, g[i]^p );
        for k in Reversed( [1..n] ) do
            w := w * f[k]^(-v[k]);
        od;
        rels[i][i] := w;
    od;
    return rec( group := F, relators := Concatenation( rels ) );
end );

#############################################################################
##
#F MappedPcElement( elm, pcgs, list )
##
InstallGlobalFunction(MappedPcElement,function( elm, pcgs, list )
    local vec, new, i;
    if Length( list ) = 0 then return fail; fi;
    vec := ExponentsOfPcElement( pcgs, elm );
    if Length( list ) < Length( vec ) then return fail; fi;
    new := false;
    for i in [1..Length(vec)] do
      if vec[i]>0 then
	if new=false then
	  new := list[i]^vec[i];
        else
	  new := new * list[i]^vec[i];
	fi;
      fi;
    od;
    if new=false then
      new:=One(list[1]);
    fi;
    return new;
end);

#############################################################################
##
#F  ExtensionSQ( C, G, M, c )
##
##  If <c> is zero,  construct the split extension of <G> and <M>
##
InstallGlobalFunction( ExtensionSQ, function( C, G, M, c )
    local field, d, n, rels, i, j, w, p, k, l, v, F, m, relators, H, orders,
          Mgens;

    # construct module generators
    field := M.field;
    Mgens := M.generators;
    if Length(Mgens) = 0 then
        return AbelianGroup( List([1..M.dimension], 
                              x -> Characteristic(M.field)));
    fi;
    d := Length(Mgens[1]);
    n := Length(Pcgs( G ));

    # add tails to presentation
    if c = 0  then
        rels := ShallowCopy( C.relators );
    else
        rels := [];
        for i  in [ 1 .. n ]  do
            rels[i] := [];
            for j  in [ 1 .. i ]  do
                if C.relators[i][j] = 0  then
                    w := [];
                else
                    w := ShallowCopy(C.relators[i][j]);
                fi;
                p := (i^2-i)/2 + j - 1;
                for k  in [ 1 .. d ]  do
                    l := c[p*d+k];
                    if l <> Zero( field ) then
                        Add( w, n+k );
                        Add( w, IntFFE(l) );
                    fi;
                od;
                if 0 = Length(w)  then
                    w := 0;
                fi;
                rels[i][j] := w;
            od;
        od;
    fi;

    # add module
    for j  in [ 1 .. d ]  do
        rels[n+j] := [];
        for i  in [ 1 .. j-1 ]  do
            rels[n+j][n+i] := [ n+j, 1 ];
        od;
        rels[n+j][n+j] := 0;
    od;

    # add operation of <G> on module
    for i  in [ 1 .. n ]  do
        for j  in [ 1 .. d ]  do
            v := Mgens[i][j];
            w := [];
            for k  in [ 1 .. d ]  do
                l := v[k];
                if l <> Zero( field ) then
                    Add( w, n+k );
                    Add( w, IntFFE(l) );
                fi;
            od;
            rels[n+j][i] := w;
        od;
    od;

    orders := Concatenation( C.orders, List( [1..d], 
                                       x -> Characteristic( field ) ) );

    # create extension as fp group
    F := FreeGroup( n+d );
    m := GeneratorsOfGroup( F );

    # and construct new presentation from collector
    relators := [];
    for i  in [ 1 .. d+n ]  do
        for j  in [ i .. d+n ]  do
            if i = j  then
                w := m[i]^orders[i];
            else
                w := m[j]^m[i];
            fi;
            v := rels[j][i];
            if 0 <> v  then
                for k  in [ Length(v)-1, Length(v)-3 .. 1 ]  do
                    w := w * m[v[k]]^(-v[k+1]);
                od;
            fi;
            Add( relators, w );
        od;
    od;

    H := PcGroupFpGroup( F / relators );
    SetModuleOfExtension( H, Subgroup(H, Pcgs(H){[n+1..n+d]} ) );
    return H;
end );

#############################################################################
##
#M  Extension( G, M, c )
##
InstallMethod( Extension,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsObject, IsVector ],
    0,
function( G, M, c )
    local C;
    C := CollectorSQ( G, M, false );
    return ExtensionSQ( C, G, M, c );
end );

#############################################################################
##
#M  Extensions( G, M )
##
InstallMethod( Extensions,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsObject],
    0,
function( G, M )
    local C, ext, co, cc, c, i;

    C := CollectorSQ( G, M, false );
    ext := [ ExtensionSQ( C, G, M, 0 ) ];

    # compute the two cocycles
    co := TwoCohomologySQ( C, G, M );
    if Length( co ) = 0 then return
        [SplitExtension(G,M)];
    fi;

    cc := VectorSpace( M.field, co );
    for i in [2..Size(cc)] do
        c := AsList( cc )[i];
        Add( ext, ExtensionSQ( C, G, M, c ) );
    od;
    return ext;
end );

############################################################################
##
#F RelVectorToCocycle( vec, cohom )
##
RelVectorToCocycle := function( vec, cohom )
    local H, z, pcgsH, pcgsG, coc;
    H := ExtensionSQ( cohom.collector, cohom.group, cohom.module, vec );
    z := One( cohom.module.field );
    pcgsH := Pcgs( H );
    pcgsG := cohom.pcgs;
    coc := function( g, h )
        local gg, hh, gh;
        gg := MappedPcElement( g, pcgsG, pcgsH );
        hh := MappedPcElement( h, pcgsG, pcgsH );
        gh := gg * hh;
        return ExponentsOfPcElement( pcgsH, gh, 
               [Length( pcgsG )+1..Length( pcgsH )] ) * z;
    end;
    return coc;
end;

############################################################################
##
#F OnRelVector( vec, tup, cohom )
##
OnRelVector := function( vec, tup, cohom )
    local z, H, pcgsH, pcgsG, imgs, k, i, j, rel, tail, w, tails, 
          vecs, mapd, ords, m, fpgens;


    # compute extensions
    H := ExtensionSQ( cohom.collector, cohom.group, cohom.module, vec );   
    pcgsH := Pcgs( H );
    pcgsG := Pcgs( cohom.group );
    ords  := RelativeOrders( pcgsG );
    fpgens := GeneratorsOfGroup( cohom.presentation.group );

    # map pcgs of G to H
    imgs := List( pcgsG, x -> x^Inverse( tup[1] ) );
    imgs := List( imgs, x -> MappedPcElement( x, pcgsG, pcgsH ) );

    # compute tails of relators in H
    k := 0;
    z := One( cohom.module.field );
    tails := [];
    for i in [1..Length(pcgsG)] do
        for j in [1..i] do

            # compute tail of relator
            k := k + 1;
            rel := cohom.presentation.relators[k];
            tail := MappedWord( rel, fpgens, imgs );

            # conjugating element
            if i = j then
                w := pcgsG[i]^ords[i];
            else
                w := pcgsG[i]^pcgsG[j];
            fi;
            m := MappedPcElement( w, pcgsG, imgs );
            Add( tails, tail^m );
        od;
    od;

    # compute corresponding vectors
    vecs := List( tails, x -> ExponentsOfPcElement( pcgsH, x, 
                   [Length(pcgsG)+1..Length(pcgsH)] ) * z );

    # apply matrix
    mapd := List( vecs, x -> x * tup[2] );

    return Concatenation( mapd );
end;

############################################################################
##
#F CocycleToRelVector( coc, cohom )
##
CocycleToRelVector := function( coc, cohom )
    local vec, gens, invs, pcgsG, rel, s, sub, i, w, t, m, r, ords, j,k,l;

    vec := [];
    gens := cohom.fpgens;
    invs := List( gens, x -> x^-1 );
    pcgsG := cohom.pcgs;
    ords  := RelativeOrders( pcgsG );
    
    k := 0;
    for i in [1..Length(pcgsG)] do
        for j in [1..i] do

            # compute tail
            k   := k + 1;
            rel := cohom.fprelators[k];
            s := Length( rel );
            sub := List( [1..cohom.module.dimension], 
                          x -> Zero( cohom.module.field));
            for l in [1..s] do

                # compute left side
                w := Subword( rel, l, l );
                r := MappedWord( w, gens, pcgsG );
   
                # compute right side
                if l = 1 then
                    t := Identity( cohom.group );
                else
                    t := Subword( rel, 1, l-1 );
                    t := MappedWord( t, gens, pcgsG );
                fi;
    
                # add to vector
                m := MappedPcElement( r, pcgsG, cohom.module.generators );
                sub := sub * m;
                sub := sub + coc( t, r );
                if w in invs then
                    sub := sub - coc( r, r^-1 );
                fi;
            od;

            # conjugating element
            if i = j then
                w := pcgsG[i]^ords[i];
            else
                w := pcgsG[i]^pcgsG[j];
            fi;
            m := MappedPcElement( w, pcgsG, cohom.module.generators);
            
            Append( vec, sub*m );
        od;
    od;
    return vec;
end;

############################################################################
##
#F OnCocycle( coc, tup, cohom )
##
OnCocycle := function( coc, tup, cohom )
    local inv, new;
    inv := Inverse( tup[1] );
    new := function( g, h )
        return coc( Image( inv, g ), Image( inv, h ) )*tup[2];
    end;
    return new;
end;

############################################################################
##
#F IsCocycle( coc, cohom )
##
IsCocycle := function( coc, cohom )
    local G, e, a, b, c, m, r, l;
    G := cohom.group;
    e := Enumerator( G );
    for c in e do
        m := MappedPcElement( c, cohom.pcgs, cohom.module.generators);
        for b in e do
            r := coc( b, c );
            for a in e do
                l := coc( a*b, c ) + coc( a, b )*m - coc( a, b*c);
                if not r = l then 
                    return false;
                fi;
            od;
        od;
        Print("next round \n");
    od;
    return true;
end;

############################################################################
##
#F CompatiblePairs( G, M )
#F CompatiblePairs( G, M, D )  ... D <= Aut(G) x GL
#F CompatiblePairs( G, M, D, flag ) ... D <= Aut(G) x GL normalises K
##
InstallGlobalFunction( CompatiblePairs, function( arg )
    local G, M, Mgrp, oper, A, B, D, K, f, tmp, tup,
          translate,p1,p1iso,p2,p2iso,DP,triso,gens,genimgs;

    # catch arguments
    G := arg[1];
    M := arg[2];
    Mgrp := GroupByGenerators( M.generators );
    oper := GroupHomomorphismByImagesNC( G, Mgrp, Pcgs(G), M.generators );

    # automorphism groups of G and M
    if Length( arg ) = 2 then
        Info( InfoCompPairs, 1, "    CompP: compute aut group");
        A := AutomorphismGroup( G );
        B := GL( M.dimension, Characteristic( M.field ) );
        D := DirectProduct( A, B );
    else
        D := arg[3];
    fi;

    # the trivial case
    if IsBound( M.isCentral ) and M.isCentral then
        return D;
    fi;

    translate:=false; # do we translate D in a permutation group?
    if HasDirectProductInfo(D) then
      IsGroupOfAutomorphisms(DirectProductInfo(D).groups[1]);
      p1iso:=IsomorphismPermGroup(DirectProductInfo(D).groups[1]);
      p2iso:=IsomorphismPermGroup(DirectProductInfo(D).groups[2]);
      DP:=DirectProduct(ImagesSource(p1iso),ImagesSource(p2iso));
      p1:=Projection(DP,1);
      p2:=Projection(DP,2);
      if IsSolvableGroup(DP) then
        gens:=Pcgs(DP);
      else
        gens:=GeneratorsOfGroup(DP);
      fi;

      genimgs:=List(gens,
	  i->ImagesRepresentative(Embedding(D,1),
		PreImagesRepresentative(p1iso,ImagesRepresentative(p1,i)))
	    *ImagesRepresentative(Embedding(D,2),
		PreImagesRepresentative(p2iso,ImagesRepresentative(p2,i))) );

      triso:=GroupHomomorphismByImagesNC(DP,D,gens,genimgs);
      SetIsBijective(triso,true);
      D:=DP;
      translate:=true;
    fi;

    if translate=false then
      gens:=GeneratorsOfGroup(D);
      genimgs:=gens;
    fi;

    # compute stabilizer of K in A 
    if Length( arg ) <= 3 or not arg[4] then

        # get kernel of oper
        K := KernelOfMultiplicativeGeneralMapping( oper );

        # get its stabilizer
	f := function( pt, a ) return Image( a[1], pt ); end;
        tmp := OrbitStabilizer( D, K,gens,genimgs, f );
        SetSize( tmp.stabilizer, Size(D)/Length(tmp.orbit) ); 

	if Size(tmp.stabilizer)<Size(D) then
	  D := tmp.stabilizer;
	  if translate then
	    if IsSolvableGroup(D) then
	      gens:=Pcgs(D);
	    else
	      gens:=GeneratorsOfGroup(D);
	    fi;
	    genimgs:=List(gens,i->ImageElm(triso,i));
	  else
	    gens:=GeneratorsOfGroup(D);
	    genimgs:=gens;
	  fi;
	fi;

        Info( InfoCompPairs, 1, "    CompP: found orbit of length ",
              Length( tmp.orbit ));
    fi;

    # compute stabilizer of M.generators in D
    f := function( tup, elm )
    local gens;
      gens := List( tup[1], x -> PreImagesRepresentative( elm[1], x ) );
      gens := List( gens, x -> MappedPcElement( x, tup[1], tup[2] ) );
      gens := List( gens, x -> x ^ elm[2] );
      return Tuple( [tup[1], gens] );
    end;

    tup := Tuple( [Pcgs(G), M.generators] );

    tmp := OrbitStabilizer( D, tup,gens,genimgs, f );
    if translate then
      tmp:=rec(stabilizer:=Image(triso,tmp.stabilizer),orbit:=tmp.orbit);
    fi;
    SetSize( tmp.stabilizer, Size(D)/Length(tmp.orbit) ); 
    D := tmp.stabilizer;
    Info( InfoCompPairs, 1, "    CompP: found orbit of length ",
          Length( tmp.orbit ));
    return D;
end );

#############################################################################
##
#F IsCompatiblePair( G, M, tup )
##
IsCompatiblePair := function( G, M, tup )
    local pcgs, imgs, hom, i, g, h, new;
    pcgs := Pcgs( G );
    imgs := M.generators;
    hom  := GroupHomomorphismByImagesNC( G,
                GroupByGenerators( imgs, imgs[1]^0 ),
                pcgs, imgs);
    if not IsGroupHomomorphism( hom ) then return false; fi;
    for i in [1..Length(pcgs)] do
        g := Image( hom, Image( tup[1], pcgs[i] ) );
        h := imgs[i]^tup[2];
        if g <> h then return false; fi;
    od;
    new := GroupHomomorphismByImagesNC( G, G, pcgs, 
           List( pcgs,x -> Image( tup[1], x ) ) );
    if not IsGroupHomomorphism( new ) and IsBijective( new ) then 
        return false;
    fi;
    return true;
end;

#############################################################################
##
#F MatrixOperationOfCP( cohom, tup )
##
MatrixOperationOfCP := function( cohom, tup )
    local mat, c, b, d;

    mat := [];
    for c in Basis( Image( cohom.cohom ) ) do
        b := PreImagesRepresentative( cohom.cohom, c );
        d := OnRelVector( b, tup, cohom );
        Add( mat, Image( cohom.cohom, d ) );
    od;
    return mat;
end;

#############################################################################
##
#F MatrixOperationOfCPGroup( cc, gens )
##
MatrixOperationOfCPGroup := function( cc, gens  )
    local mats, base, pcgs, ords, imgs, n, d, fpgens, fprels, H, pcgsH, 
          l, g, imgl, k, i, j, rel, tail, m, tails, prei, h;
 

    mats := List( gens, x -> [] );
    base := Basis( Image( cc.cohom ) );
    prei := List( base, x -> PreImagesRepresentative( cc.cohom, x ) );

    pcgs := Pcgs( cc.group );
    ords := RelativeOrders( pcgs );
    imgs := List( gens, x -> List( pcgs, y -> y^Inverse( x[1] ) ) );

    n := Length( pcgs );
    d := cc.module.dimension;

    fpgens := GeneratorsOfGroup( cc.presentation.group );
    fprels := cc.presentation.relators;

    # loop over base elements and compute images under operation
    for h in [1..Length(base)] do
        H := ExtensionSQ( cc.collector, cc.group, cc.module, prei[h] );
        pcgsH := Pcgs( H );

        # loop over generators 
        for l in [1..Length(gens)] do
            g := gens[l];
            imgl := List( imgs[l], x -> MappedPcElement( x, pcgs, pcgsH ) );
            
            if imgl <> pcgs then

                # compute tails of relators in H
                k := 0;
                tails := [];
                for i in [1..Length(pcgs)] do
                    for j in [1..i] do

                        # compute tail of relator
                        k := k + 1;
                        rel := fprels[k];
                        tail := MappedWord( rel, fpgens, imgl );

                        # conjugating element
                        if not IsBound( cc.module.isCentral ) or 
                           not cc.module.isCentral then
                            if i = j then
                                m := imgl[i]^ords[i];
                            else
                                m := imgl[i]^imgl[j];
                            fi;
                            tail := tail^m;
                        fi;
                        tail := ExponentsOfPcElement(pcgsH,tail,[n+1..n+d]);
                        tail := tail * g[2];
                        Add( tails, tail );
                    od;
                od;
            else
                tails := List( [1..Length(fprels)], 
                                x -> base[h]{[(x-1)*d+1..x*d]}*g[2] );
            fi;
            tails := Flat( tails );
            tails := Image( cc.cohom, tails );
            Add( mats[l], tails );
        od;
    od;
    return mats;
end;

#############################################################################
##
#M ExtensionRepresentatives( G, M, C )
##
InstallMethod( ExtensionRepresentatives,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsRecord, IsGroup ],
    0,
function( G, M, C )
    local cc, ext, mats, Mgrp, orbs;

    cc := TwoCohomology( G, M );

    # catch the trivial case
    if Dimension(Image(cc.cohom)) = 0 then
        return [ExtensionSQ( cc.collector, G, M, 0 )];
    elif Dimension( Image(cc.cohom)) = 1 then
        return [ExtensionSQ( cc.collector, G, M, 0 ),
                ExtensionSQ( cc.collector, G, M, Basis(Source(cc.cohom))[1])]; 
    fi;

    mats := MatrixOperationOfCPGroup( cc, GeneratorsOfGroup( C ) );

    # compute orbit of mats on H^2( G, M )
    Mgrp := GroupByGenerators( mats );
    orbs := Orbits( Mgrp, Image(cc.cohom), OnRight );
    orbs := List( orbs, x -> PreImagesRepresentative( cc.cohom, x[1] ) );
    ext  := List( orbs, x -> ExtensionSQ( cc.collector, G, M, x ) );
    return ext;
end);

#############################################################################
##
#F MyIntCoefficients( p, d, w )
##
MyIntCoefficients := function( p, d, w )
    local v, int, i;
    v   := IntVecFFE( w );
    int := 0;
    for i in [1..d] do
        int := int * p + v[i];
    od;
    return int;
end;

#############################################################################
##
#F MatOrbsApprox( mats, dim, field ) . . . . . . . . . . . . underfull orbits 
##
MatOrbsApprox := function( mats, dim, field )
    local p, q, r, l, n, seen, reps, rest, i, v, orb, j, w, im, h, mat, rep,
          red;

    # set up 
    p := Characteristic( field );
    q := p^dim;
    r := p^dim - 1;
    l := List( [1..dim], x -> p );
    n := Length( mats );
   
    # set up large boolean list
    seen := [];
    seen[q] := false;
    for i in [1..q-1] do
        seen[i] := false;
    od;
    IsBlist( seen );

    reps := [];
    rest := r;
    red  := true;
    for i in [1..r] do
        if not seen[i] then

            seen[i] := true;
            v    := CoefficientsMultiadic( l, i );
            orb  := [v];
            rest := rest - 1;
            j    := 1;
            rep  := v;
            while j <= Length( orb ) do
                w := orb[j];
                for mat in mats do
                    im := w * mat;
                    h  := MyIntCoefficients( p, dim, im );
                    if not seen[h] then
                        seen[h] := true;
                        rest    := rest - 1;
                        Add( orb, im );
                    elif h < i then
                        rep := false;
                    fi;
                od;
                if rest = 0 then
                    j := Length( orb );
                elif Length(orb) > 60000 or IsBool( rep ) then
                    j := Length( orb );
                    red := false;
                fi;
                j := j + 1;
            od;
            if not IsBool( rep ) then
                Add( reps, rep );
            fi;
        fi;
    od;
    return rec( reps := reps * One( field ), red := red );
end;

#############################################################################
##
#F MatOrbs( mats, dim, field )
##
MatOrbs := function( mats, dim, field )
    local p, q, r, l, n, seen, reps, rest, i, v, orb, j, w, im, h, mat, rep;

    # set up 
    p := Characteristic( field );
    q := p^dim;
    r := p^dim - 1;
    l := List( [1..dim], x -> p );
    n := Length( mats );
   
    # set up large boolean list
    seen := [];
    seen[q] := false;
    for i in [1..q-1] do seen[i] := false; od;
    IsBlist( seen );

    reps := [];
    rest := r;
    for i in [1..r] do
        if not seen[i] then
            seen[i] := true;
            v    := CoefficientsMultiadic( l, i );
            orb  := [v];
            rest := rest - 1;
            j    := 1;
            rep  := v;
            Add( reps, rep );
            while j <= Length( orb ) do
                w := orb[j];
                for mat in mats do
                    im := w * mat;
                    h  := MyIntCoefficients( p, dim, im );
                    if not seen[h] then
                        seen[h] := true;
                        rest    := rest - 1;
                        Add( orb, im );
                    fi;
                od;
                if rest = 0 then j := Length( orb ); fi;
                j := j + 1;
            od;
            Info( InfoExtReps, 3, "found orbit of length: ", Length(orb),
                                  " remaining points: ",rest);
        fi;
    od;
    return reps * One( field );
end;

#############################################################################
##
#F NonSplitExtensions( G, M [, reduce] ) 
##
NonSplitExtensions := function( arg )
    local G, M, C, cc, cohom, mats, CP, all, red, c;

    # catch arguments
    G := arg[1];
    M := arg[2];

    # compute H^2(G, M)
    cc := TwoCohomology( G, M );
    C  := cc.collector;

    Info( InfoExtReps, 1, "   dim(M) = ",M.dimension,
                                " char(M) = ", Characteristic(M.field),
                                " dim(H2) = ", Dimension(Image(cc.cohom)));

    # catch the trivial cases
    if Dimension( Image( cc.cohom ) ) = 0 then
        all := [];
        red := true;

    elif Dimension( Image(cc.cohom ) ) = 1 then
        c := PreImagesRepresentative(cc.cohom, Basis(Image(cc.cohom))[1]);
        all := [ExtensionSQ( C, G, M, c)];
        red := true;

    # if reduction is suppressed
    elif IsBound( arg[3] ) and not arg[3] then
        all := NormedRowVectors( Image(cc.cohom) );
        all := List( all, x -> ExtensionSQ(cohom.collector, G, M, 
                               PreImagesRepresentative(cc.cohom,x )));
        red := false;

    # sometimes we do not want to reduce
    elif not IsBound( arg[3] ) 
        and Size(Image(cc.cohom)) < 10
        and not (HasIsFrattiniFree( G ) and IsFrattiniFree( G ))
        and not HasAutomorphismGroup( G )
    then
        all := NormedRowVectors( Image(cc.cohom) );
        all := List( all, x -> ExtensionSQ(cc.collector, G, M, 
                               PreImagesRepresentative(cc.cohom, x )));
        red := false;

    # then we want to reduce
    else

        Info( InfoExtReps, 2, "   Ext: compute compatible pairs");
        CP := CompatiblePairs( G, M );

        Info( InfoExtReps, 2, "   Ext: compute linear action");
        mats := MatrixOperationOfCPGroup( cc, GeneratorsOfGroup( CP ) );

        Info( InfoExtReps, 2, "   Ext: compute orbits ");
        all := MatOrbs( mats, Length(mats[1]) , M.field );
        red := true;
        Info( InfoExtReps, 2, "   Ext: found ",Length(all)," orbits ");

        # create extensions and add info
        all := List( all, x -> ExtensionSQ(cc.collector, G, M, 
                               PreImagesRepresentative(cc.cohom, x )));
    fi;

    if red then
        Info( InfoExtReps, 1, "    found ",Length(all),
                               " extensions - reduced");
    else
        Info( InfoExtReps, 1, "    found ",Length(all)," extensions ");
    fi;

    return rec( groups := all, reduced := red );
end;

#############################################################################
##
#F  SplitExtension( G, M )
#F  SplitExtension( G, aut, N )
##
InstallMethod( SplitExtension,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsObject ],
    0,
function( G, M )
    return Extension( G, M, 0 );
end );

InstallOtherMethod( SplitExtension,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsObject, CanEasilyComputePcgs ],
    0,
function( G, aut, N )
    local pcgsG, fpg, n, gensG, pcgsN, fpn, d, gensN, F, gensF, relators,
          rel, new, g, e, t, l, i, j, k, H, m, relsN, relsG;
    
    pcgsG := Pcgs( G );
    fpg   := Range( IsomorphismFpGroup( G ) );
    n     := Length( pcgsG );
    gensG := GeneratorsOfGroup( FreeGroupOfFpGroup( fpg ) );
    relsG := RelatorsOfFpGroup( fpg );

    pcgsN := Pcgs( N );
    fpn   := Range( IsomorphismFpGroup( N ) );
    d     := Length( pcgsN );
    gensN := GeneratorsOfGroup( FreeGroupOfFpGroup( fpn ) );
    relsN := RelatorsOfFpGroup( fpn );
   
    F := FreeGroup( n + d );
    gensF := GeneratorsOfGroup( F );
    relators := [];

    # relators of G
    for rel in relsG do
        new := MappedWord( rel, gensG, gensF{[1..n]} );
        Add( relators, new );
    od;

    # operation of G on N
    for i in [1..n] do
        for j in [1..d] do

            # left hand side
            l := Comm( gensF[n+j], gensF[i] );

            # right hand side
            g := Image( aut, pcgsG[i] );
            m := Image( g, pcgsN[j] );
            e := ExponentsOfPcElement( pcgsN, (pcgsN[j]^-1 * m)^-1 );
            t := One( F );
            for k in [1..d] do
                t := t * gensF[n+k]^e[k];
            od;
            
            # add new relator
            Add( relators, l * t );
        od;
    od;
            
    # relators of N
    for rel in relsN do
        new := MappedWord( rel, gensN, gensF{[n+1..n+d]} );
        Add( relators, new );
    od;

    H := PcGroupFpGroup( F / relators );
    SetModuleOfExtension( H, Subgroup(H, Pcgs(H){[n+1..n+d]} ) );
    return H;
end);


#############################################################################
##
#F ConjugatingElement( G, inn )
##
ConjugatingElement := function( G, inn )
    local elm, C, g, h, n, gens, imgs, i;

    elm := Identity( G );
    C   := G;
    gens := GeneratorsOfGroup( G );
    imgs := List( gens, x -> Image( inn, x ) );
    for i in [1..Length(gens)] do
        g := gens[i];
        h := imgs[i];
        n := RepresentativeAction( C, g, h );
        elm := elm * n;
        C := Centralizer( C, g^n );
        gens := List( gens, x -> x ^ n );
    od;
    return elm;
end;

#############################################################################
##
#M  TopExtensionsByAutomorphism( G, aut, p )
##
InstallMethod( TopExtensionsByAutomorphism,
    "generic method for groups",
    true, 
    [ CanEasilyComputePcgs, IsObject, IsInt ],
    0,
function( G, aut, p )
    local pcgs, n, R, gensR, F, gens, relators, pow, pre, powers, i,
          t, rel, new, grps;

    pcgs := Pcgs( G );
    n    := Length( pcgs );
    R    := Range( IsomorphismFpGroup( G ) );
    gensR := GeneratorsOfGroup( FreeGroupOfFpGroup( R ) );
    
    F := FreeGroup( n + 1 );
    gens := GeneratorsOfGroup( F );
    relators := [];
 
    # compute all possible powers of g
    pow := aut^p;
    pre := ConjugatingElement( G, pow );
    powers := List( AsList( Centre(G) ), x -> pre * x );
    powers := Filtered( powers, x -> Image( aut, x ) = x );
    grps   := List( powers, x -> false );

    # compute operation 
    for i in [1..n] do
        t := pcgs[i]^-1 * Image( aut, pcgs[i] );
        t := MappedPcElement( t, pcgs, gens{[2..n+1]} );
        Add( relators, Comm( gens[1], gens[i+1] ) * t );
    od;

    # add relators 
    Append( relators, List( RelatorsOfFpGroup( R ),
                      x -> MappedWord( x, gensR, gens{[2..n+1]} ) ) ); 

    # set up groups
    for i in [1..Length(powers)] do
        t := MappedPcElement( powers[i], pcgs, gens{[2..n+1]} );
        rel := gens[1]^p / t;
        new := Concatenation( [rel], relators );
        grps[i] := PcGroupFpGroup( F / new );
    od;

    # return 
    return grps;
end );
    
#############################################################################
##
#M  CyclicTopExtensions( G, p )
##
InstallMethod( CyclicTopExtensions,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsInt ],
    0,
function( G, p )
    local A, gens, P, gensI, I, F, cl, hom, res, aut, new, nat;

    # compute automorphism group
    A := AutomorphismGroup( G );

    # compute rational classes in Aut(G) / Inn(G)
    gens := GeneratorsOfGroup( G );
    if p in Factors( Size( A ) / Index( G, Centre(G) )) then
        P := Action( A, AsList( G ) );
        gensI := List( gens, x -> Permutation( x, AsList( G ), OnPoints ) );
        I := Subgroup( P, gensI );
    
        nat := NaturalHomomorphismByNormalSubgroup( P, I );
        F   := Range( nat );

        # compute rational classes
        cl := RationalClasses( F );
        cl := List( cl, Representative );
        cl := Filtered( cl, x -> x^p = One( F ) );

        # transfer back - 1. part
        cl := List( cl, x -> PreImagesRepresentative( nat, x ) );
    
        # transfer back - 2. part
        hom := GroupHomomorphismByImagesNC( P, A, GeneratorsOfGroup( P ),
               GeneratorsOfGroup( A ) );
        cl := List( cl, x -> Image( hom, x ) );
    else
        cl := [IdentityMapping( G )];
    fi;

    # compute extensions
    res := [];
    for aut in cl do
        new := TopExtensionsByAutomorphism( G, aut, p );
        Append( res, new );
    od;
    return res;
end );