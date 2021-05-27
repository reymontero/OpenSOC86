using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.IO;

namespace VGASim
{
    public partial class Form1 : Form
    {
        private Bitmap bVGA = new Bitmap(800, 600);

        public Form1()
        {
            InitializeComponent();

            //string sPath = @"C:\Users\Roy\Documents\IntelPC\vgasim-1.0.0a_win32\";
            //string sPath = @"C:\Users\Roy\Documents\Verilog\sram_test\simulation\modelsim\";
            //string sPath = @"C:\Users\Roy\Documents\Visual Studio 2010\Projects\sram_test\sram_test\bin\Debug\";
            string sPath = @"..\..\..\..\..\project\soc\simulation\modelsim\";
            string sFile = "vgalog.txt";
            textBox1.Text = sPath + sFile;
        }

        private void LoadFile(string sFile)
        {
            StreamReader SR = new StreamReader(sFile);
            string sLine = null;

            bool bValid = false;
            bool bHS = false;
            bool bVS = false;

            int iScr = (int)numericUpDown1.Value;
            int curScr = 0;

            int X = 0;
            int Y = 0;

            bVGA = new Bitmap(1024, 800);
            Graphics gVGA = Graphics.FromImage(bVGA);
            gVGA.Clear(Color.White);
            LockBitmap lockBitmap = new LockBitmap(bVGA);
            lockBitmap.LockBits();

            while ((sLine = SR.ReadLine()) != null)
            {
                if (bValid == false)
                {
                    if (sLine.ToLower().IndexOf("x") == -1)
                        bValid = true;
                }

                if (bValid == true)
                {
                    sLine = sLine.ToLower().Replace("x", "0");

                    if (sLine.Substring(1, 1) == "1")
                        bVS = true;
                    else if ((bVS == true) && (sLine.Substring(1, 1) == "0"))
                    {
                        bVS = false;
                        curScr++;
                        X = 0;
                        Y = 0;
                        if (curScr > iScr)
                            break;
                    }

                    if (sLine.Substring(0, 1) == "1")
                        bHS = true;
                    else if ((bHS == true) && (sLine.Substring(0, 1) == "0"))
                    {
                        bHS = false;
                        X = 0;
                        Y++;
                    }

                    if (iScr == curScr)
                    {
                        try
                        {
                            int R = 255 * Convert.ToInt32(sLine.Substring(2, 1));
                            int G = 255 * Convert.ToInt32(sLine.Substring(3, 1));
                            int B = 255 * Convert.ToInt32(sLine.Substring(4, 1));

                            //if (sLine.Substring(0, 1) == "0")
                            //    R = 255;
                            //if (sLine.Substring(1, 1) == "0")
                            //    B = 255;

                            Color C = Color.FromArgb(R, G, B);
                            if ((bVS == false) || (bHS == false))
                                C = Color.White;

                            lockBitmap.SetPixel(X, Y, C);
                        }
                        catch
                        {
                            MessageBox.Show(sLine);
                        }
                        X++;
                    }
                }
            }

            SR.Close();

            lockBitmap.UnlockBits();
        }

        private void Form1_Resize(object sender, EventArgs e)
        {
            pictureBox1.Invalidate();
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            int iW = this.ClientRectangle.Width;
            int iH = this.ClientRectangle.Height;
            Bitmap bScr = new Bitmap(iW, iH);
            Graphics gScr = Graphics.FromImage(bScr);
            gScr.Clear(Color.White);

            gScr.DrawImage(bVGA, 0, 0);

            e.Graphics.DrawImage(bScr, 0, 0);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            LoadFile(textBox1.Text);
            pictureBox1.Invalidate();
        }



    }
}
