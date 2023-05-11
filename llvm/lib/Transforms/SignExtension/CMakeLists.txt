add_llvm_library( LLVMSignExtension MODULE
  SignExtension.cpp

  PLUGIN_TOOL
  opt
  )

