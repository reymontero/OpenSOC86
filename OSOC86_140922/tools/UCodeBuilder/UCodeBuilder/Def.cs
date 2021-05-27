using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace UCodeBuilder
{
    public class Def
    {
        public int Ind = 0;
        public List<List<string>> Vals = new List<List<string>>();

        public Def()
        {
        }

        public Def(int iInd)
        {
            Ind = iInd;
        }
    }
}
