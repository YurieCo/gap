#############################################################################
##
#W  grpreps.gd                  GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.grpreps_gd :=
    "@(#)$Id$";

#############################################################################
##
#O  AbsolutIrreducibleModules( <G>, <F>, <dim> )
##
##  returns a list of length 2. The first entry is a generating system of
##  <G>. The second entry is a list of all absolute irreducible modules of
##  <G> over the field <F> in dimension <dim>, given as MeatAxe modules
##  (see~"GModuleByMats").
DeclareOperation( "AbsolutIrreducibleModules", [ IsGroup, IsField, IsInt ] );

#############################################################################
##
#O  IrreducibleModules( <G>, <F>, <dim> )
##
##  returns a list of length 2. The first entry is a generating system of
##  <G>. The second entry is a list of all irreducible modules of
##  <G> over the field <F> in dimension <dim>, given as MeatAxe modules
##  (see~"GModuleByMats").
DeclareOperation( "IrreducibleModules", [ IsGroup, IsField, IsInt ] );

#############################################################################
##
#O  RegularModule( <G>, <F> )
##
##  returns a list of length 2. The first entry is a generating system of
##  <G>. The second entry is the regular module of <G> over <F>, given as a
##  MeatAxe modules (see~"GModuleByMats").
DeclareOperation( "RegularModule", [ IsGroup, IsField ] );

#############################################################################
DeclareGlobalFunction( "RegularModuleByGens" );