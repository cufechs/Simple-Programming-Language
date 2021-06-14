using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Windows.Forms;
using System.Diagnostics;

namespace Compilers_GUI
{
	public partial class Form1 : Form
	{
		public Form1()
		{
            InitializeComponent();

            string[] comands =
            {
                "flex lexer.l",
                "bison -dy --verbose parser.y",
                "g++ -w -g symbolTable.hpp y.tab.c"
            };

            ExecuteCommand(comands, System.IO.Directory.GetCurrentDirectory() + "\\");

            symbols_btn.BackColor = Color.LightGray;
            quad_btn.BackColor = Color.LightGray;
        }

		private void button1_Click(object sender, EventArgs e)
		{
			File.WriteAllText("test.c", code_txt.Text);

            string[] comands = { ".\\a.exe .\\test.c" };

            //File.Delete("test.c");

            ExecuteCommand(comands, System.IO.Directory.GetCurrentDirectory() + "\\");

            if(CodeGenerator.GenerateCode())
                quads_Click(sender, e);
            else
                log_txt.Text = "ERROR - Can not Generate Code (quad.txt file missing!)" +
                    "\nCompilation failed";
        }

		private void quads_Click(object sender, EventArgs e)
		{
            if (ShowLog())
            {
                try
                {
                    generated_txt.Text = File.ReadAllText("GeneratedCode.txt");
                    quad_btn.BackColor = Color.LightBlue;
                    symbols_btn.BackColor = Color.LightGray;
                }
                catch (FileNotFoundException eee)
                {
                    log_txt.Text = "ERROR - GeneratedCode file not found\n";
                }
            }
            else
                generated_txt.Text = "";
        }

        private void symbol_Click(object sender, EventArgs e)
		{
            if (ShowLog())
            {
                try
                {
                    generated_txt.Text = File.ReadAllText("symbols.txt");
                    symbols_btn.BackColor = Color.LightBlue;
                    quad_btn.BackColor = Color.LightGray;
                }
                catch (FileNotFoundException eee)
                {
                    log_txt.Text += "ERROR - symbols file not found";
                }
            }
            else
                generated_txt.Text = "";
        }

        private bool ShowLog()
		{
            try
            {
                string log = File.ReadAllText("log.txt");
                if(log == "")
				{
                    log_txt.Text = "Compiled successfully";
                    return true;
				}
				else
				{
                    log_txt.Text = log;
                    return false;
                }
            }
            catch (FileNotFoundException eee)
            {
                log_txt.Text += "ERROR - log file not found";
                return false;
            }
        }


        private void ExecuteCommand(string[] Commands, string Path)
        {
            string bat = Guid.NewGuid() + ".bat";
            string batFileName = Path + @"" + bat;

            using (StreamWriter batFile = new StreamWriter(batFileName))
            {
                foreach (string Comm in Commands)
                    batFile.WriteLine(Comm);
            }

            ProcessStartInfo processStartInfo = new ProcessStartInfo("powershell.exe", "./" +  bat);
            processStartInfo.UseShellExecute = false;
            processStartInfo.CreateNoWindow = true;
            processStartInfo.WindowStyle = ProcessWindowStyle.Normal;

            Process p = Process.Start(processStartInfo);

            p.WaitForExit();
            p.Close();

            File.Delete(batFileName);
        }
	}
}
