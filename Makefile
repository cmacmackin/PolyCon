# The compiler
FC = gfortran-5
CC = gcc
# flags for debugging or for maximum performance, comment as necessary
FCFLAGS = -Ofast -I$(INC) -J$(INC) -fPIC
LDFLAGS = -Ofast
# ifort flags:
#FCFLAGS = -g -O0 -traceback -check all -assume realloc_lhs
#FCFLAGS = -O3
# flags forall (e.g. look for system .mod files, required in gfortran)
#FCFLAGS += -I/usr/include

# libraries needed for linking, unused in the examples
#LIBS = -L. -lpolycon

# List of executables to be built within the package
SDIR = src
INC = mod
ODIR = obj

OUTSHARED = libpolycon.so
OUTSTATIC = libpolycon.a

_OBJS = abstract_container_mod.o container_mod.o 
OBJS = $(patsubst %,$(ODIR)/%,$(_OBJS))

# "make" builds all
shared: init $(OBJS)
	$(FC) -shared -o $(OUTSHARED) $(filter-out init,$^) $(LDFLAGS)

static: init $(OBJS)
	ar rcs $(OUTSTATIC) $(filter-out init,$^)

$(OUTSTATIC): static

test: $(OUTSTATIC) $(ODIR)/tests/container_test.o 
	 $(FC) -o $@ $(filter-out $(OUTSTATIC),$^) $(OUTSTATIC) $(LDFLAGS)

$(ODIR)/tests/container_test.o: $(SDIR)/tests/container_test.f90
	$(FC) $(FCFLAGS) -fpic -o $@ -c $<

%: $(ODIR)/%.o
	$(FC) $(FCFLAGS) -o $@ $^ $(LDFLAGS)

$(ODIR)/%.o: $(SDIR)/%.f
	$(FC) $(FCFLAGS) -o $@ -c $<

$(ODIR)/%.o: $(SDIR)/%.F
	$(FC) $(FCFLAGS) -o $@ -c $<

$(ODIR)/%.o: $(SDIR)/%.f90
	$(FC) $(FCFLAGS) -o $@ -c $<

$(ODIR)/%.o: $(SDIR)/%.F90
	$(FC) $(FCFLAGS) -o $@ -c $<

$(ODIR)/%.o: $(SDIR)/%.f95
	$(FC) $(FCFLAGS) -o $@ -c $<

$(ODIR)/%.o: $(SDIR)/%.F95
	$(FC) $(FCFLAGS) -o $@ -c $<

clean:
	/bin/rm  -rf $(ODIR)/*.o ./tmp $(INC)/*.mod test

init:
	mkdir -p $(ODIR)
	mkdir -p $(ODIR)/tests
	mkdir -p $(INC)
