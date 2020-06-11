# rose-plugin

Starting from Version 0.9.9.83, ROSE has a new feature to support external plugins. It borrows the design and implementation of Clang Plugins.

The interface is very similar to what Clang has, with some simplification and improvements.

With this feature, you can develop your ROSE-based tools as dynamically loadable plugins. Then you can use command line options of ROSE's default translator, identityTranslator (or another ROSE translator), to
* load shared libraries containing the plugins,
* specify actions to be executed,
* as well as pass command line options to each action.

## Benefits

The main benefit of using plugins is that you can use a single installed ROSE default translator to execute one or more arbitrary external plugins, in the order they appear on the command line.

This will significantly reduce the overhead of composing ROSE-based transformations, by reusing the costly parsing and unparsing, and freely chaining up the transformation plugins through command line options.

The deployment of plugins are much simpler also. No need to recompile/reinstall ROSE.

For example, we had to call two heavy-weight tools in two command lines:
```
# two separated command lines to run two ROSE-based tools, each of which has costly parsing and unparsing. 
tool_1 input.c;
tool_2 input.c;
```

Now, we can call the default ROSE identityTranslator and chain up two plugins (act1 and act2) instead:
```
# sharing one identitiTranslator's parsing/unparsing support,
# load multiple shared libraries, executing two actions in the order they show up in the command line, also pass multiple options to each of the plugins

rose-compiler -rose:plugin_lib lib.so -rose:plugin_lib lib2.so -rose:plugin_action act -rose:plugin_action act2 \
 -rose:plugin_arg_act1 op1 -rose:plugin_arg_act1 op2 -rose:plugin_arg_act2 op3 -rose:plugin_arg_act2 op4 
```

## Command Line Interface
rose-compiler --help , excerpt of the plugin section 
```
Plugin Mode:
     -rose:plugin_lib <shared_lib_filename>
                             Specify the file path to a shared library built from plugin source files 
                             This option can repeat multiple times to load multiple libraries 
     -rose:plugin_action <act_name>
                             Specify the plugin action to be executed
                             This option can repeat multiple times to execute multiple actions 
                             in the order shown up in command line 
     -rose:plugin_arg_<act_name>  <option>
                             Specify one option to be passed to a plugin named act_name
                             This option can repeat multiple times to provide multiple options to a plugin 

```

Examples
* rose-compiler -rose:plugin_lib /path/libPrintNamesPlugin.so -rose:plugin_action print-names -rose:plugin_arg_print-names pretty-printing
  * load a shared library containing a single plugin, execute the plugin named print-names, also pass an option named "pretty-printing" to the plugin. 
* rose-compiler -rose:plugin_lib lib.so -rose:plugin_lib lib2.so -rose:plugin_action act1 -rose:plugin_action act2 -rose:plugin_arg_act1 op1 -rose:plugin_arg_act1 op2 -rose:plugin_arg_act2 op3 -rose:plugin_arg_act2 op4
  * load multiple shared libraries, executing two actions in the order they show up in the command line, also pass multiple options to each of the plugins

## Plugin Super Class
Two interface functions are provided for a ROSE plugin:
* ParseArgs(): optionally handle command line options passed to this plugin
* process(): process the AST 
<pre>
  class PluginAction {
    public:
      virtual void process(SgProject*) {};
      virtual bool ParseArgs(const std::vector<std::string> &arg) {return true; };
  };
</pre>

## Running the example plugin

Edit makefile to set ROSE_INSTALL to the right path (--prefix path).

Then type
* make check

Command line and options used are: 
* rose-compiler -rose:plugin_lib PrintNamesPlugin.so -rose:plugin_action print-names -rose:plugin_arg_print-names op1 -c input_testPlugins.C 

Sample input file: input_testPlugins.C 
```
int foo() {}
int bar(); 
int a, b,c;
```

Sample output: 
```
1 arguments
op1
"foo"
```


