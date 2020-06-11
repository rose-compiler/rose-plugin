# specify where the installed copy of ROSE is located. 
# Essentially the --prefix path used with configure
ROSE_INSTALL=/opt/rose/installDebug


## Your Plugin source files
Plugin=PrintNamesPlugin
Plugin_SOURCE=$(Plugin).cpp

## Input testcode for your plugin
TESTCODE=test1.cpp

# Standard C++ compiler stuff (see rose-config --help)
comma   := ,
CXX      = $(shell $(ROSE_INSTALL)/bin/rose-config cxx)
CPPFLAGS = $(shell $(ROSE_INSTALL)/bin/rose-config cppflags) -I.
CXXFLAGS = $(shell $(ROSE_INSTALL)/bin/rose-config cxxflags)
LIBDIRS  = $(shell $(ROSE_INSTALL)/bin/rose-config libdirs)
LDFLAGS  = $(shell $(ROSE_INSTALL)/bin/rose-config ldflags) -L. \
           $(addprefix -Wl$(comma)-rpath -Wl$(comma), $(subst :, , $(LIBDIRS)))

#-------------------------------------------------------------
# Makefile Targets
#-------------------------------------------------------------

all: $(Plugin).so

# compile the plugin and generate a shared library
# -g is recommended to be used by default to enable debugging your code
$(Plugin).so: $(Plugin_SOURCE)
	$(CXX) -g $(Plugin_SOURCE) -fpic -shared $(CPPFLAGS) $(LDFLAGS) -o $@

# test the plugin
check: $(Plugin).so
	$(ROSE_INSTALL)/bin/rose-compiler -c -rose:plugin_lib $(Plugin).so -rose:plugin_action print-names -rose:plugin_arg_print-names op1 -I. -I$(ROSE_INSTALL)/include $(TESTCODE) 

clean:
	rm -rf $(Plugin).so *.o rose_* *.dot
