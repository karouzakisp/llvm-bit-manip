//=== -- RISCVInstrInfoB.td RISCV-V thead-extension ba,bb,bc instructions

def OPC_CUSTOM1   : RISCVOpcode<"CUSTOM1", 0b0001011>;

def uimm2_node : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isUint<2>(Imm);}]> {
  let ParserMatchClass = UImmAsmOperand<2>;
  let DecoderMethod = "decodeUImmOperand<2>";
  let OperandType = "OPERAND_UIMM2";
  let OperandNamespace = "RISCVOp";
}


let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class addsl_ir<bits<3> funct3,string opcodestr> // TODO ADD RISCVOpcode 
			: RVInstR<0, funct3, OPC_CUSTOM1, (outs GPR:$rd),
			(ins GPR:$rs1, GPR:$rs2, uimm2:$uimm2), opcodestr,
			"$rd, $rs1, $rs2, $uimm2">{
  bits<2> uimm2;
  let Inst{31-27} = 0;
  let Inst{26-25} = uimm2;
}


let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ext_ir<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_CUSTOM1, (outs GPR:$rd),
    (ins GPR:$rs1, uimmlog2xlen:$msb, uimmlog2xlen:$lsb), opcodestr,
    "$rd, $rs1, $msb, $lsb">{
    bits<6> msb;
    bits<6> lsb;
    let Inst{31-26} = msb;
    let Inst{25-20} = lsb;

}



// Predicates


  def ADDSL : addsl_ir<0b001, "addsl">;

  def EXT : ext_ir<0b010, "ext">;

  def EXTU : ext_ir<0b011, "extu">;

  def : Pat<(add GPR:$rs1, (shl GPR:$rs2, uimm2_node:$uimm2) ) ,
         (ADDSL GPR:$rs1, GPR:$rs2, uimm2_node:$uimm2)>;

    
  def : Pat<(sext_inreg GPR:$rs1,  i8) , (EXT GPR:$rs1, 7, 0)>;
  def : Pat<(sext_inreg GPR:$rs1,  i16) , (EXT GPR:$rs1, 16, 0)>;
  def : Pat<(sext_inreg GPR:$rs1,  i32) , (EXT GPR:$rs1, 32, 0)>;



    
   // def : Pat<(i64 zexti32 (i64 GPR:$rs1 ) ) , 
