#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/LazyValueInfo.h"
#include "llvm/IR/ConstantRange.h"
#include "llvm/Analysis/BlockFrequencyInfo"

using namespace llvm;

// INITIALIZE_PASS_DEPENDENCY(LazyBlockFrequencyInfoPass)
INITIALIZE_PASS_DEPENDENCY(LazyValueInfoWrapperPass)


namespace {
	class SignExtensionLegacyPass : public FunctionPass {
		// data
		bool runOnFunction(Function &F) override;

		void getAnalysisUsage(AnalysisUsage &AU) const override {	
			AU.addRequired<LazyValueInfoWrapperPass>();
			//LazyBlockFrequencyInfoPass::getLazyBFIAnalysisUsage(AU);

		}	
}

static bool processBinOp(BinaryOperator *BinOp, LazyValueInfo *LVI){
	
	Instruction::BinaryOps Opcode = BinOp->getOpcode();
  Value *LHS = BinOp->getOperand(0);
  Value *RHS = BinOp->getOperand(1);
	ConstantRange LRange = LVI->getConstantRange(LHS, BinOp);
	ConstantRange RRange = LVI->getConstantRange(RHS, BinOp);
}

bool EliminateSignExtensions(Function &F, LazyValueInfo &LVI){
	for (BasicBlock *BB : depth_first(&F.getEntryBlock())) {
		for (Instruction &II : llvm::make_early_inc_range(*BB)){
			switch (II.getOpcode()){
			case Instruction::Add:
			case Instruction::Sub:
			case Instruction::Mul:
			case Instruction::Shl:				
				processBinOp(cast<BinaryOperator>(&II), LVI);
			}
		}
	}



}


bool SignExtensionLegacyPass::runOnFunction(Function &F){
	LazyValueInfo *LVI = &getAnalysis<LazyValueInfoWrapperPass>().getLVI();
	return EliminateSignExtensions(F, LVI);
}


