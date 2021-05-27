using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.IO;

namespace OsocDasm
{
    public partial class Form1 : Form
    {
        List<string[]> lstUC = new List<string[]>();

        public Form1()
        {
            InitializeComponent();

            textBox1.Text = @"..\..\..\..\..\project\soc\simulation\modelsim\runlog.txt";
            textBox2.Text = @"..\..\..\..\..\project\soc\simulation\modelsim\runlog_dasm.txt";
            textBox3.Text = @"..\..\..\..\..\ucode\I86_ucode_risk_style.txt";
        }

        private void button1_Click(object sender, EventArgs e)
        {
            LoadUCode(textBox3.Text);
            Dasm(textBox1.Text, textBox2.Text);
            MessageBox.Show("done");
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
            textBox3.Text = UserOpenFile(textBox3.Text);
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

        private void LoadUCode(string sFile)
        {
            lstUC = new List<string[]>();

            StreamReader SR = new StreamReader(sFile);
            string sLine = null;
            while ((sLine = SR.ReadLine()) != null)
            if (sLine != "")
            {
                if (sLine.Substring(0, 1) != "#")
                {
                    sLine = sLine.Replace(" ", "\t");
                    string[] sVal = sLine.Split(new string[] { "\t" }, StringSplitOptions.RemoveEmptyEntries);
                    if (sVal.Length > 1)
                        if (sVal[0].ToUpper() != "DEF")
                        {
                            lstUC.Add(new string[] { sVal[0].Replace("m", "x").ToLower(), sVal[1] });
                        }
                }
            }
            SR.Close();
        }

        private void Dasm(string sFileIn, string sFileOut)
        {
            StreamWriter SW = new StreamWriter(sFileOut, false);
            StreamReader SR = new StreamReader(sFileIn);
            float fLen = SR.BaseStream.Length;
            int iPrc10Cur = 0;
            string sLine = null;
            while ((sLine = SR.ReadLine()) != null)
                if (sLine != "")
                {
                    int iPrc = (int)(100.0f * (float)SR.BaseStream.Position / fLen);
                    progressBar1.Value = iPrc;
                    int iPrc10 = 10 * (int)(iPrc / 10);
                    if (iPrc10Cur < iPrc10)
                    {
                        iPrc10Cur = iPrc10;
                        progressBar1.Refresh();
                    }

                    sLine = sLine.Replace(" ", "\t");
                    string[] sVal = sLine.Split(new string[] { "\t" }, StringSplitOptions.RemoveEmptyEntries);
                    string sMnem = MatchOP(sVal[1], sVal[2]);

                    string sTmp = sVal[0] + "\t" + sMnem;
                    for (int i = 1; i < sVal.Length; i++)
                        sTmp += "\t" + sVal[i];

                    SW.WriteLine(sTmp);
                }
            SR.Close();
            SW.Close();
        }

        private string MatchOP(string sOpHex, string sModHex)
        {
            string sMnem = "";
            bool bDup = false;

            string OP = Convert.ToString(Convert.ToInt32(sOpHex, 16), 2);
            while (OP.Length < 8)
                OP = "0" + OP;
            string MOD = Convert.ToString(Convert.ToInt32(sModHex, 16), 2);
            while (MOD.Length < 8)
                MOD = "0" + MOD;
            OP += MOD;

            for (int i = 0; i < lstUC.Count; i++)
            {
                bool bErr = false;
                for (int j = 0; j < lstUC[i][0].Length; j++)
                    if ((lstUC[i][0].Substring(j, 1) != OP.Substring(j, 1)) && (lstUC[i][0].Substring(j, 1) != "x"))
                    {
                        bErr = true;
                        break;
                    }
                if (bErr == false)
                {
                    if (sMnem != "")
                        bDup = true;
                    sMnem = lstUC[i][1];
                }
            }
            if (bDup == true)
                sMnem += "*";
            return sMnem;
        }

    }
}
