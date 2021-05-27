using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.IO;

namespace UCodeBuilder
{
    public partial class Form1 : Form
    {
        private List<Def> lDefs = new List<Def>();
        private List<Inst> lInsts = new List<Inst>();
        private List<int> lBits = new List<int>();

        public Form1()
        {
            InitializeComponent();

            textBox1.Text = @"..\..\..\..\..\ucode\I86_ucode_risk_style.txt";
            textBox2.Text = @"..\..\..\..\..\rtl\cpu\rom_adr_bin.txt";
            textBox3.Text = @"..\..\..\..\..\rtl\cpu\rom_dep_bin.txt";
            textBox4.Text = @"..\..\..\..\..\rtl\cpu\rom_ucd_bin.txt";
        }

        private void button2_Click(object sender, EventArgs e)
        {
            textBox1.Text = UserOpenFile(textBox1.Text);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            textBox2.Text = UserSaveFile(textBox2.Text);
        }

        private void button4_Click(object sender, EventArgs e)
        {
            textBox3.Text = UserSaveFile(textBox3.Text);
        }

        private void button5_Click(object sender, EventArgs e)
        {
            textBox4.Text = UserSaveFile(textBox4.Text);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Compile();
        }

        private string UserOpenFile(string sFile)
        {
            OpenFileDialog OFD = new OpenFileDialog();
            OFD.Filter = "Text Files (.txt)|*.txt|All Files (*.*)|*.*";
            OFD.FilterIndex = 1;
            OFD.Multiselect = false;

            OFD.InitialDirectory = Path.GetFullPath(Path.GetDirectoryName(sFile));
            OFD.FileName = Path.GetFileName(sFile);

            DialogResult DR = OFD.ShowDialog();
            if (DR == DialogResult.OK)
                return OFD.FileName;
            return sFile;
        }

        private string UserSaveFile(string sFile)
        {
            SaveFileDialog SFD = new SaveFileDialog();
            SFD.Filter = "Text Files (.txt)|*.txt|All Files (*.*)|*.*";
            SFD.FilterIndex = 1;

            SFD.InitialDirectory = Path.GetFullPath(Path.GetDirectoryName(sFile));
            SFD.FileName = Path.GetFileName(sFile);

            DialogResult DR = SFD.ShowDialog();
            if (DR == DialogResult.OK)
                return SFD.FileName;
            return sFile;
        }

        private void Compile()
        {
            string sFileSrc = textBox1.Text;
            string sFileAROM = textBox2.Text;
            string sFileDROM = textBox3.Text;
            string sFileUROM = textBox4.Text;

            textBox5.Text = "";

            AddLineLog("Loading microcode source file...");
            LoadFile(sFileSrc);
            AddLineLog("Building...");
            Build();
            getFieldSizes();
            EncodeBin();
            //SortInsts();
            GetDepPL();

            AddLineLog("Writing ROM's...");
            BuildAdrROM(sFileAROM, sFileDROM);
            WriteROM(sFileUROM);

            AddLineLog("Completed");
        }

        private void AddLineLog(string sText)
        {
            textBox5.SelectionStart = textBox5.Text.Length;
            textBox5.SelectedText = sText + "\r\n";
            textBox5.Refresh();
        }

        private void LoadFile(string sFile)
        {
            lDefs = new List<Def>();
            lInsts = new List<Inst>();

            StreamReader SR = new StreamReader(sFile);
            string sLine = null;
            while ((sLine = SR.ReadLine()) != null)
            {
                if (sLine.IndexOf("#") != -1)
                    sLine = sLine.Substring(0, sLine.IndexOf("#"));

                sLine = sLine.Replace(" ", "\t");
                sLine = sLine.Replace(",", "\t");
                while (sLine.IndexOf("\t\t") != -1)
                    sLine = sLine.Replace("\t\t", "\t");

                if (sLine != "")
                {
                    string[] sVal = sLine.Split(new string[] { "\t" }, StringSplitOptions.RemoveEmptyEntries);

                    if (sLine.Substring(0, 1) == "\t")
                    {
                        if (sVal.Length > 0)
                        {
                            int Ind = lInsts.Count - 1;
                            List<string> sOps = new List<string>();
                            for (int i = 0; i < sVal.Length; i++)
                                sOps.Add(sVal[i]);
                            lInsts[Ind].Fields.Add(sOps);
                        }
                    }
                    else
                    {
                        if (sVal[0] == "DEF")
                        {
                            int ID = Convert.ToInt32(sVal[1]);

                            while (lDefs.Count <= ID)
                                lDefs.Add(new Def(lDefs.Count - 1));

                            for (int i = 2; i < sVal.Length; i++)
                            {
                                if (lDefs[ID].Vals.Count < i - 1)
                                    lDefs[ID].Vals.Add(new List<string>());

                                string[] sV = sVal[i].Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
                                for (int j = 0; j < sV.Length; j++)
                                    lDefs[ID].Vals[i - 2].Add(sV[j]);
                            }
                        }
                        else
                        {
                            if (sVal.Length > 4)
                            {
                                Inst I = new Inst(sVal[0], sVal[1], sVal[2], sVal[3]);
                                List<string> sOps = new List<string>();
                                for (int i = 4; i < sVal.Length; i++)
                                    sOps.Add(sVal[i]);
                                I.Fields.Add(sOps);
                                lInsts.Add(I);
                            }
                            else
                                System.Windows.Forms.MessageBox.Show(sLine);
                        }
                    }
                }
            }
            SR.Close();
        }

        private void Build()
        {
            for (int i = 0; i < lInsts.Count; i++)
            {
                lInsts[i].Values = new List<List<int>>();
                for (int j = 0; j < lInsts[i].Fields.Count; j++)
                {
                    lInsts[i].Values.Add(new List<int>());
                    for (int k = 0; k < lInsts[i].Fields[j].Count; k++)
                    {
                        int V = FindDef(k, lInsts[i].Fields[j][k]);
                        lInsts[i].Values[j].Add(V);
                    }
                }
            }
        }

        private int FindDef(int Ind, string sName)
        {
            if (Ind >= lDefs.Count)
                MessageBox.Show(Ind.ToString() + " " + sName);
            for (int i = 0; i < lDefs[Ind].Vals.Count; i++)
                for (int j = 0; j < lDefs[Ind].Vals[i].Count; j++)
                    if (lDefs[Ind].Vals[i][j] == sName)
                        return i;
            MessageBox.Show(sName);
            return -1;
        }

        private void getFieldSizes()
        {
            lBits = new List<int>();
            for (int i = 0; i < lDefs.Count; i++)
            {
                int iB = (int)Math.Ceiling(Math.Log(lDefs[i].Vals.Count, 2));
                lBits.Add(iB);
            }
        }

        private void EncodeBin()
        {
            for (int i = 0; i < lInsts.Count; i++)
            {
                for (int j = 0; j < lInsts[i].Values.Count; j++)
                {
                    int iLeft = lInsts[i].Values.Count - 1 - j;
                    if (iLeft > 3)
                        iLeft = 3;

                    string sBin = Convert.ToString(iLeft, 2);
                    while (sBin.Length < 2)
                        sBin = "0" + sBin;

                    if (lInsts[i].Type.ToUpper() == "{P}")
                        sBin = "1_" + sBin;
                    else
                        sBin = "0_" + sBin;

                    for (int k = 0; k < lInsts[i].Values[j].Count; k++)
                    {
                        string sTmp = Convert.ToString(lInsts[i].Values[j][k], 2);
                        while (sTmp.Length < lBits[k])
                            sTmp = "0" + sTmp;
                        sBin += "_" + sTmp;
                    }
                    lInsts[i].Bins.Add(sBin);
                }
            }
        }

        public void WriteROM(string sFile)
        {
            int opCnt = 0;
            for (int i = 0; i < lInsts.Count; i++)
                opCnt += lInsts[i].Bins.Count;

            int dptWidth = (int)Math.Ceiling(Math.Log(opCnt, 2));
            int Depth = (int)Math.Pow(2, dptWidth);

            int opWidth = 3;
            for (int i = 0; i < lBits.Count; i++)
                opWidth += lBits[i];

            StreamWriter SW = new StreamWriter(sFile);
            int Ind = 0;
            for (int i = 0; i < lInsts.Count; i++)
                for (int j = 0; j < lInsts[i].Bins.Count; j++)
                {
                    string sBin = lInsts[i].Bins[j];
                    sBin = sBin.Replace("_", "");
                    SW.WriteLine(sBin);
                    Ind++;
                }
            SW.Close();
        }


        private void SortInsts()
        {
            for (int i = 0; i < lInsts.Count; i++)
            {
                string sTmp = lInsts[i].Opcode;
                sTmp = sTmp.Replace("x", "0");
                sTmp = sTmp.Replace("m", "0");
                sTmp = sTmp.Replace(".", "");
                sTmp = sTmp.Replace("_", "");
                lInsts[i].Ord = Convert.ToInt32(sTmp, 2);
            }

            lInsts.Sort(delegate(Inst A, Inst B) { return A.Ord.CompareTo(B.Ord); });
        }

        public void BuildAdrROM(string sFileA, string sFileD)
        {
            int Cnt = 0;
            int[] iMap = new int[1024];
            string[] sMap = new string[1024];
            for (int i = 0; i < lInsts.Count; i++)
            {
                List<int> lAdr = CalcAdresses(lInsts[i].Opcode);
                for (int j = 0; j < lAdr.Count; j++)
                {
                    iMap[lAdr[j]] = Cnt;
                    sMap[lAdr[j]] = lInsts[i].DepBin;
                }
                Cnt += lInsts[i].Bins.Count;
            }

            int depBits = 1;
            for (int i = 0; i < sMap.Length; i++)
            {
                if (sMap[i] == null)
                    sMap[i] = "";
                if (depBits < sMap[i].Length)
                    depBits = sMap[i].Length;
            }

            string sEmpty = "0";
            while (sEmpty.Length < depBits)
                sEmpty += "0";

            for (int i = 0; i < sMap.Length; i++)
                if (sMap[i] == "")
                    sMap[i] = sEmpty;

            int adrWidth = (int)Math.Ceiling(Math.Log(Cnt, 2));

            StreamWriter SW = new StreamWriter(sFileA);
            for (int i = 0; i < iMap.Length; i++)
            {
                string sBin = Convert.ToString(iMap[i], 2);
                while (sBin.Length < adrWidth)
                    sBin = "0" + sBin;
                SW.WriteLine(sBin);
            }
            SW.Close();


            StreamWriter SW2 = new StreamWriter(sFileD);
            for (int i = 0; i < sMap.Length; i++)
                SW2.WriteLine(sMap[i]);
            SW2.Close();
        }

        private List<int> CalcAdresses(string sOpcode)
        {
            string sOp = sOpcode.Substring(0, 8);
            string sMod = sOpcode.Substring(8, sOpcode.Length - 8);
            bool bMod = true;
            if (sMod.Replace("x", "").Length == 0)
                bMod = false;

            string[] lstOp = expandValues(new string[] { sOp });

            List<string> lAdr = new List<string>();

            string tM = sMod.Substring(0, 1);
            if (tM == "m")
                tM = "0";
            sMod = sMod.Substring(2, sMod.Length - 2);

            for (int i = 0; i < lstOp.Length; i++)
            {
                if (bMod == false)
                    lAdr.Add(lstOp[i]);
                else
                {
                    int iOp = Convert.ToInt32(lstOp[i], 2);


                    List<string> lsM = new List<string>();
                    if (tM == "x")
                    {
                        lsM.Add("0");
                        lsM.Add("1");
                    }
                    else
                        lsM.Add(tM);

                    for (int k = 0; k < lsM.Count; k++)
                    {
                        string sM = lsM[k];

                        bool bAddMod = false;
                        if ((iOp & 0xFC) == 0x80)
                            bAddMod = true;
                        else if ((iOp & 0xFC) == 0xD0)
                            bAddMod = true;
                        else if ((iOp & 0xFE) == 0xF6)
                            bAddMod = true;
                        else if ((iOp & 0xFE) == 0xFE)
                            bAddMod = true;

                        if (bAddMod == false)
                            lAdr.Add(sM + lstOp[i]);
                        else
                        {
                            if ((iOp & 0xFC) == 0xD0)
                            {
                                string sTmp = "1" + sM + "001" + lstOp[i].Substring(6, 2) + "000";
                                lAdr.Add(sTmp);
                            }
                            else
                            {
                                string[] lstM = expandValues(new string[] { sMod });
                                for (int j = 0; j < lstM.Length; j++)
                                {
                                    string sTmp = "";
                                    if ((iOp & 0xFC) == 0x80)
                                        sTmp = "1" + sM + "000" + lstOp[i].Substring(6, 2) + lstM[j];
                                    //else if ((iOp & 0xFC) == 0xD0)
                                    //    sTmp = "1" + sM + "001" + lstOp[i].Substring(6, 2) + lstM;
                                    else if ((iOp & 0xFE) == 0xF6)
                                        sTmp = "1" + sM + "0100" + lstOp[i].Substring(7, 1) + lstM[j];
                                    else if ((iOp & 0xFE) == 0xFE)
                                        sTmp = "1" + sM + "0110" + lstOp[i].Substring(7, 1) + lstM[j];

                                    lAdr.Add(sTmp);
                                }
                            }
                        }
                    }
                }
            }

            List<int> lIAdr = new List<int>();
            for (int i = 0; i < lAdr.Count; i++)
                lIAdr.Add(Convert.ToInt32(lAdr[i], 2));
            return lIAdr;
        }

        private string[] expandValues(string[] S)
        {
            List<string> lstR = new List<string>();
            bool bChange = false;
            for (int i = 0; i < S.Length; i++)
            {
                string sTmp = S[i];
                if (sTmp.IndexOf("x") == -1)
                    lstR.Add(sTmp);
                else
                {
                    string sL = sTmp.Substring(0, sTmp.IndexOf("x"));
                    string sR = sTmp.Substring(sTmp.IndexOf("x") + 1, sTmp.Length - sTmp.IndexOf("x") - 1);
                    lstR.Add(sL + "0" + sR);
                    lstR.Add(sL + "1" + sR);
                    bChange = true;
                }
            }
            if (bChange == true)
                return expandValues(lstR.ToArray());
            return lstR.ToArray();
        }

        public void GetDepPL()
        {
            for (int i = 0; i < lInsts.Count; i++)
                if (lInsts[i].Type.ToUpper() == "{P}")
                    lInsts[i].DepBin = "1";
                else
                    lInsts[i].DepBin = "0";
        }


    }
}
