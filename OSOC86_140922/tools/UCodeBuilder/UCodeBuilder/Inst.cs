using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace UCodeBuilder
{
    public class Inst
    {
        public string Opcode = "";
        public string Info = "";
        public string Mod = "";
        public string Type = "";

        public List<int> RdRegs = new List<int>();
        public List<int> RdType = new List<int>();
        public List<int> WrRegs = new List<int>();
        public List<int> WrType = new List<int>();

        public string DepBin = "";

        public int Ord = 0;

        public List<List<string>> Fields = new List<List<string>>();
        public List<List<int>> Values = new List<List<int>>();
        public List<string> Bins = new List<string>();

        public Inst()
        {
        }

        public Inst(string sOpcode, string sInfo, string sMod, string sType)
        {
            Opcode = sOpcode;
            Info = sInfo;
            Mod = sMod;
            Type = sType;
        }
    }
}
