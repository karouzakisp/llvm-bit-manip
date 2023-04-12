//=== -- RISCVInstrInfoB.td RISCV-V thead-extension ba,bb,bs instructions



//===--------------------------------------------------------------------------
// Operand and SDNode transformation definitions.
//===--------------------------------------------------------------------------

def riscv_tstnbz  : SDNode<"RISCVISD::TSTNBZ", SDTUnaryOp>;



def OPC_CUSTOM1   : RISCVOpcode<"CUSTOM1", 0b0001011>;


let Predicates = [HasStdExtBa], 
  hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class addsl_ir<bits<3> funct3,string opcodestr> 
			: RVInstR<0, funct3, OPC_CUSTOM1, (outs GPR:$rd),
			(ins GPR:$rs1, GPR:$rs2, uimm2:$uimm2), opcodestr,
			"$rd, $rs1, $rs2, $uimm2">{
  bits<2> uimm2;
  bits<5> rs1;
  bits<5> rs2;
  bits<5> rd;
  let Inst{31-27} = 0;
  let Inst{26-25} = uimm2;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0x1;
  let Inst{11-7} = rd; 
}


let Predicates = [HasStdExtBb], 
hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
class ext_ir<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_CUSTOM1, (outs GPR:$rd),
    (ins GPR:$rs1, uimmlog2xlen:$msb, uimmlog2xlen:$lsb), opcodestr,
    "$rd, $rs1, $msb, $lsb">{
    bits<6> msb;
    bits<6> lsb;
    let Inst{31-26} = msb;
    let Inst{25-20} = lsb;

}

class rev_ir<bits<5> funct5, bits<2> funct2, string opcodestr>
  : RVInstR4<funct2, 0b001, OPC_CUSTOM1, (outs GPR:$rd), (ins GPR:$rs1),
  opcodestr, "$rd, $rs1">{
  let rs3 = funct5;
  let rs2 = 0;
}

} // HasStdExtBb

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class shift_ir<bits<5> funct5, bits<3> funct3, string opcodestr>
  : RVInstIShift<funct5, funct3, OPC_CUSTOM1, (outs GPR:$rd),
  (ins GPR:$rs1, uimmlog2xlen:$shamt), opcodestr, "$rd, $rs1, $shamt">;


let Predicates = [HasStdExtBb], 
hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
class shiftW_ir<bits<7> funct7, bits<3> funct3, string opcodestr>
 : RVInstIShiftW<funct7, funct3, OPC_CUSTOM1, (outs GPR:$rd), (ins GPR:$rs1,
  uimm5:$shamt), opcodestr, "$rd, $rs1, $shamt">;

} // hasStdExtBb



  let Predicates = [HasStdExtBa] in {
    def ADDSL : addsl_ir<0b001, "addsl">;
  } // Predicates = [HasStdExtBa]

  let Predicates = [HasStdExtBb] in {
    def EXT : ext_ir<0b010, "ext">;
    def EXTU : ext_ir<0b011, "extu">;
    def FF0 : rev_ir<0b10000, 0b10, "ff0">;
    def FF1 : rev_ir<0b10000, 0b11, "ff1">;
    def REV : rev_ir<0b10000, 0b01, "rev">;
    def REVW : rev_ir<0b10010, 0b00, "revw">;  
    def SRRI : shift_ir<0b00010, 0b001, "srri">;
    def SRRIW : shiftW_ir<0b0001010, 0b001, "srriw">; 
    def TSTNBZ : rev_ir<0b10011, 0b00, "tstnbz">;
  } // Predicates = [HasStdExtBb]
   
  let Predicates = [HasStdExtBs] in {
    def TST : shift_ir<0b10001, 0b001, "tst">;
  }
  
  let Predicates = [HasStdExtBa] in {

    def : Pat<(add GPR:$rs1, (shl GPR:$rs2, uimm2:$uimm2) ) ,
           (ADDSL GPR:$rs1, GPR:$rs2, uimm2:$uimm2)>;
    
    def : Pat<(add (add GPR:$rs1, GPR:$rs2), GPR:$rs2 ),
              (ADDSL GPR:$rs1, GPR:$rs2, 1 )>;
    foreach i = 1...2 in {
      def : Pat<(add (add GPR:$rs1, (shl GPR:$rs2, (XLenVT i ))),(shl GPR:$rs2, (XLenVT i))),
                (ADDSL GPR:$rs1, GPR:$rs2, (ImmPlus1 (XLenVT i)))>;
    }

  } // Predicates = [HasStdExtBa] 
  
  let Predicates = [HasStdExtBb] in {
     
    def : Pat<(sext_inreg GPR:$rs1, i1) , (EXT GPR:$rs1, 0, 0)>; 
    def : Pat<(sext_inreg GPR:$rs1, i8) , (EXT GPR:$rs1, 7, 0)>;
    def : Pat<(sext_inreg GPR:$rs1, i16) , (EXT GPR:$rs1, 15, 0)>;
    
    def : Pat<(and GPR:$rs1, 1), (EXTU GPR:$rs1, 0, 0)>;
    def : Pat<(and GPR:$rs1, 0xff), (EXTU GPR:$rs1, 7, 0)>;
    def : Pat<(and GPR:$rs1, 0xffff), (EXTU GPR:$rs1, 15, 0)>;

    foreach i = 1...14 in {
       def : Pat<(and (shl GPR:$rs1, (XLenVT i)), 0xffff ),
                (EXTU GPR:$rs1, 15, (XLenVT i))>;
    }

    def : Pat<(ctlz GPR:$rs1), (FF1 GPR:$rs1)>;
    def : Pat<(ctlz (xor GPR:$rs1, -1)), (FF0 GPR:$rs1)>;
       
    def : Pat<(bswap GPR:$rs1), (REV GPR:$rs1 ) >;
    
    def : Pat<(or ( srl i16:$rs1, (i64 8) ), (shl i16:$rs1, (i64 8) ) )  , (REV i16:$rs1 ) >;

  //   def : Pat<(or (and 0xff, (srl i32:$rs1, (i64 24))), 
  //                 (and 0xff0000, (shl i32:$rs1 ,  (i64 8))) ,
  //                 (and 0xff00, (srl i32:$rs1 ,  (i64 8))),  
  //                 (and 0xff000000, (shl i32:$rs1 ,  (i64 24)))), 
  //                 (REV i32:$rs1 )>;

    def : Pat<(sra ( bswap i64:$rs1), (i64 32 )) , (REVW i64:$rs1 ) >;
    

    def : Pat<(rotl GPR:$rs1, uimmlog2xlen:$uimmlog2xlen),
              (SRRI GPR:$rs1, (ImmSubFromXLen uimmlog2xlen:$uimmlog2xlen))>;

    def : Pat<(rotr GPR:$rs1, uimmlog2xlen:$uimmlog2xlen),
              (SRRI GPR:$rs1, uimmlog2xlen:$uimmlog2xlen)>;
    
    def : Pat<(rotr i32:$rs1, GPR:$rs2),
              (OR (SRL i32:$rs1, GPR:$rs2),
               (SLL i32:$rs1, (SUB 32, GPR:$rs2)))>;
      
    def : Pat<(rotl i32:$rs1, GPR:$rs2),
              (OR (SLL i32:$rs1, GPR:$rs2),
               (SRL i32:$rs1, (SUB 32, GPR:$rs2)))>;

    def : PatGpr<int_riscv_tstnbz, TSTNBZ>; 
    def : PatGpr<riscv_tstnbz, TSTNBZ>;

  } // Predicates = [HasStdExtBb] 

  
let Predicates = [IsRV64, HasStdExtBb] in {
  def : Pat<(sext_inreg GPR:$rs1,  i32) , (EXT GPR:$rs1, 31, 0)>;
  def : Pat<(and GPR:$rs1, 0xffffffff), (EXTU GPR:$rs1, 31, 0)>;
  

  def : Pat<(rotr i64:$rs1, GPR:$rs2),
            (OR (SRL GPR:$rs1, GPR:$rs2),
             (SLL GPR:$rs1, (SUB 64, GPR:$rs2)))>;
  
  def : Pat<(rotl i64:$rs1, GPR:$rs2),
            (OR (SLL GPR:$rs1, GPR:$rs2),
             (SRL GPR:$rs1, (SUB 64, GPR:$rs2)))>;
  
  def : InstAlias<"srriw $rd, $rs1, $shamt",
                (SRRIW GPR:$rd, GPR:$rs1, uimm5:$shamt), 0>;  
 
  def : PatGprImm<riscv_rorw, SRRIW, uimm5>; 
  // #TODO test
  def : Pat<(riscv_rorw GPR:$rs1, uimm5:$shamt),
            (SRRIW GPR:$rs1, uimm5:$shamt)>;
  
} // Predicates = [IsRV64, HasStdExtbb]

  let Predicates = [HasStdExtBs] in { 
      def : Pat<(and (srl GPR:$rs1, uimmlog2xlen:$shamt), 1 ), 
                (TST GPR:$rs1, uimmlog2xlen:$shamt)>;
  } // Predicates = [HasStdExtBs] 

