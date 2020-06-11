// An example ROSE plugin: PrintNamesPlugin.cpp

//Mandatory include headers
#include "rose.h"
#include "plugin.h"

// optional headers
#include "RoseAst.h" // using AST Iterator
#include <iostream>

using namespace std;
using namespace Rose;

//Step 1. Derive a plugin action from Rose::PluginAction 
class PrintNamesAction : public Rose::PluginAction {
 public:
    PrintNamesAction() {}
    ~PrintNamesAction() {}

   // This is optional. Need only if your plugin wants to handle options
  // Provide command line option processing: arg will be the options passed to this plugin
   bool ParseArgs(const std::vector<std::string> &arg)
   {
     cout<<arg.size()<< " arguments "<<endl;
     for (size_t i=0; i< arg.size(); i++)
     {
       cout<<arg[i]<<endl;
     }
     return true;
   }

    // This is mandatory: providing work in your plugin
    // Do actual work after ParseArgs();
    void process (SgProject* n) {
      SgNode* node= n;
      RoseAst ast(node);

      for(RoseAst::iterator i=ast.begin();i!=ast.end();++i) {
        SgFunctionDeclaration* fdecl= isSgFunctionDeclaration(*i);
        if (fdecl && (fdecl->get_definingDeclaration()==fdecl))
          cout<<fdecl->get_name()<<endl;
      }

    } // end process()
};

//Step 2: Declare a plugin entry with a unique name 
//        Register it under a unique action name plus some description 
static Rose::PluginRegistry::Add<PrintNamesAction>  uniquePluginName1("print-names", "print function names");
