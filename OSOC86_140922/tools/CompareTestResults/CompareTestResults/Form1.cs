using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.IO;

namespace CompareTestResults
{
    public partial class Form1 : Form
    {
        private List<List<string>> lstT = new List<List<string>>();

        public Form1()
        {
            InitializeComponent();

            textBox1.Text = @"..\..\..\..\..\project\cpu\simulation\modelsim\";
            textBox2.Text = @"..\..\..\..\..\test\TestsResults.txt";
        }

        private void button1_Click(object sender, EventArgs e)
        {
            CheckResults();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            FolderBrowserDialog FBD = new FolderBrowserDialog();
            FBD.SelectedPath = Path.GetFullPath(textBox1.Text);
            DialogResult DR = FBD.ShowDialog();
            if (DR == DialogResult.OK)
            {
                string sTmp = FBD.SelectedPath;
                if (sTmp != "")
                    if (sTmp.Substring(sTmp.Length - 1, 1) != "\\")
                        sTmp += "\\";
                textBox1.Text = sTmp;
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            OpenFileDialog OFD = new OpenFileDialog();
            OFD.Filter = "Text Files (.txt)|*.txt|All Files (*.*)|*.*";
            OFD.FilterIndex = 1;
            OFD.Multiselect = false;

            OFD.InitialDirectory = Path.GetFullPath(Path.GetDirectoryName(textBox2.Text));
            OFD.FileName = Path.GetFileName(textBox2.Text);

            DialogResult DR = OFD.ShowDialog();
            if (DR == DialogResult.OK)
                textBox2.Text = OFD.FileName;
        }

        private void CheckResults()
        {
            string sFileT = textBox2.Text;
            string sPathR = textBox1.Text;

            LoadTestFile(sFileT);

            List<string> Tests = new List<string>();
            List<int> Inds = new List<int>();
            for (int i = 1; i < 20; i++)
                if (i != 9)
                {
                    string sTmp = Convert.ToString(i, 16);
                    while (sTmp.Length < 2)
                        sTmp = "0" + sTmp;

                    Tests.Add("instlog" + sTmp + ".txt");
                    Inds.Add(i);
                }

            for (int i = 0; i < Tests.Count; i++)
            {
                string sLog = "";
                int cnt = Compare(sPathR + Tests[i], Inds[i], ref sLog);

                int cntRef = lstT[Inds[i]].Count;
                string sErr = "OK";
                if ((cnt == 0) || (sLog != ""))
                    sErr = "error";
                textBox3.Text += Tests[i] + "\t" + "lines: sim=" + cnt.ToString() + ", ref=" + cntRef.ToString() + "\t"+ sErr + "\r\n";
                textBox3.Text += sLog;// +"\r\n";
            }

            MessageBox.Show("Done");
        }

        private void LoadTestFile(string sFile)
        {
            lstT = new List<List<string>>();
            int Ind = -1;

            StreamReader SR = new StreamReader(sFile);
            string sLine = null;
            while ((sLine = SR.ReadLine()) != null)
                if (sLine.Length > 2)
                {
                    if (sLine.Substring(2, 1) == "_")
                    {
                        Ind = Convert.ToInt32(sLine.Substring(0, 2));
                        while (lstT.Count <= Ind)
                            lstT.Add(new List<string>());
                    }
                    else if (sLine.Substring(0, 2) == "0x")
                    {
                        sLine = sLine.Substring(sLine.IndexOf(":"), sLine.Length - sLine.IndexOf(":"));
                        sLine = sLine.Replace("0x", "");
                        sLine = sLine.Replace("X", "0");
                        lstT[Ind].Add(sLine);
                    }
                }
            SR.Close();
        }

        private int Compare(string sFile, int Ind, ref string sLog)
        {
            List<string> lstR = new List<string>();

            StreamReader SR = new StreamReader(sFile);
            string sLine = null;
            while ((sLine = SR.ReadLine()) != null)
            {
                if (sLine.IndexOf(":") != -1)
                {
                    sLine = sLine.Substring(sLine.IndexOf(":"), sLine.Length - sLine.IndexOf(":"));
                    sLine = sLine.Replace("0x", "");
                    sLine = sLine.Replace("X", "0");
                    lstR.Add(sLine);
                }
            }
            SR.Close();

            sLog = "";
            for (int i = 0; (i < lstR.Count) && (i < lstT[Ind].Count); i++)
                if (lstR[i] != lstT[Ind][i])
                    sLog += lstR[i] + "\r\n";

            return lstR.Count;
        }

        

    }
}
