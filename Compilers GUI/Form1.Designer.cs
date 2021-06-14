
namespace Compilers_GUI
{
	partial class Form1
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.button1 = new System.Windows.Forms.Button();
			this.code_txt = new System.Windows.Forms.RichTextBox();
			this.generated_txt = new System.Windows.Forms.RichTextBox();
			this.log_txt = new System.Windows.Forms.RichTextBox();
			this.quad_btn = new System.Windows.Forms.Button();
			this.symbols_btn = new System.Windows.Forms.Button();
			this.textBox1 = new System.Windows.Forms.TextBox();
			this.textBox2 = new System.Windows.Forms.TextBox();
			this.textBox3 = new System.Windows.Forms.TextBox();
			this.SuspendLayout();
			// 
			// button1
			// 
			this.button1.BackColor = System.Drawing.SystemColors.ButtonShadow;
			this.button1.Location = new System.Drawing.Point(1087, 603);
			this.button1.Name = "button1";
			this.button1.Size = new System.Drawing.Size(344, 47);
			this.button1.TabIndex = 0;
			this.button1.Text = "Compile";
			this.button1.UseVisualStyleBackColor = false;
			this.button1.Click += new System.EventHandler(this.button1_Click);
			// 
			// code_txt
			// 
			this.code_txt.BorderStyle = System.Windows.Forms.BorderStyle.None;
			this.code_txt.Location = new System.Drawing.Point(18, 37);
			this.code_txt.Name = "code_txt";
			this.code_txt.Size = new System.Drawing.Size(689, 474);
			this.code_txt.TabIndex = 1;
			this.code_txt.Text = "";
			// 
			// generated_txt
			// 
			this.generated_txt.Location = new System.Drawing.Point(742, 37);
			this.generated_txt.Name = "generated_txt";
			this.generated_txt.ReadOnly = true;
			this.generated_txt.Size = new System.Drawing.Size(689, 474);
			this.generated_txt.TabIndex = 2;
			this.generated_txt.Text = "";
			// 
			// log_txt
			// 
			this.log_txt.Location = new System.Drawing.Point(18, 542);
			this.log_txt.Name = "log_txt";
			this.log_txt.ReadOnly = true;
			this.log_txt.Size = new System.Drawing.Size(1038, 108);
			this.log_txt.TabIndex = 3;
			this.log_txt.Text = "";
			// 
			// quad_btn
			// 
			this.quad_btn.BackColor = System.Drawing.SystemColors.ActiveCaption;
			this.quad_btn.Location = new System.Drawing.Point(1087, 542);
			this.quad_btn.Name = "quad_btn";
			this.quad_btn.Size = new System.Drawing.Size(169, 47);
			this.quad_btn.TabIndex = 4;
			this.quad_btn.Text = "Quadruples";
			this.quad_btn.UseVisualStyleBackColor = false;
			this.quad_btn.Click += new System.EventHandler(this.quads_Click);
			// 
			// symbols_btn
			// 
			this.symbols_btn.Location = new System.Drawing.Point(1262, 542);
			this.symbols_btn.Name = "symbols_btn";
			this.symbols_btn.Size = new System.Drawing.Size(169, 47);
			this.symbols_btn.TabIndex = 4;
			this.symbols_btn.Text = "Symbols";
			this.symbols_btn.UseVisualStyleBackColor = true;
			this.symbols_btn.Click += new System.EventHandler(this.symbol_Click);
			// 
			// textBox1
			// 
			this.textBox1.BorderStyle = System.Windows.Forms.BorderStyle.None;
			this.textBox1.ForeColor = System.Drawing.SystemColors.InactiveCaptionText;
			this.textBox1.Location = new System.Drawing.Point(18, 517);
			this.textBox1.Multiline = true;
			this.textBox1.Name = "textBox1";
			this.textBox1.ReadOnly = true;
			this.textBox1.Size = new System.Drawing.Size(100, 19);
			this.textBox1.TabIndex = 5;
			this.textBox1.Text = "Log";
			// 
			// textBox2
			// 
			this.textBox2.BorderStyle = System.Windows.Forms.BorderStyle.None;
			this.textBox2.ForeColor = System.Drawing.SystemColors.InactiveCaptionText;
			this.textBox2.Location = new System.Drawing.Point(19, 12);
			this.textBox2.Multiline = true;
			this.textBox2.Name = "textBox2";
			this.textBox2.ReadOnly = true;
			this.textBox2.Size = new System.Drawing.Size(100, 19);
			this.textBox2.TabIndex = 5;
			this.textBox2.Text = "Enter your code";
			// 
			// textBox3
			// 
			this.textBox3.BorderStyle = System.Windows.Forms.BorderStyle.None;
			this.textBox3.ForeColor = System.Drawing.SystemColors.InactiveCaptionText;
			this.textBox3.Location = new System.Drawing.Point(742, 12);
			this.textBox3.Multiline = true;
			this.textBox3.Name = "textBox3";
			this.textBox3.ReadOnly = true;
			this.textBox3.Size = new System.Drawing.Size(137, 19);
			this.textBox3.TabIndex = 5;
			this.textBox3.Text = "Generated Code";
			// 
			// Form1
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(1482, 674);
			this.Controls.Add(this.textBox3);
			this.Controls.Add(this.textBox2);
			this.Controls.Add(this.textBox1);
			this.Controls.Add(this.symbols_btn);
			this.Controls.Add(this.quad_btn);
			this.Controls.Add(this.log_txt);
			this.Controls.Add(this.generated_txt);
			this.Controls.Add(this.code_txt);
			this.Controls.Add(this.button1);
			this.Name = "Form1";
			this.Text = "Compilers GUI";
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Button button1;
		private System.Windows.Forms.RichTextBox code_txt;
		private System.Windows.Forms.RichTextBox generated_txt;
		private System.Windows.Forms.RichTextBox log_txt;
		private System.Windows.Forms.Button quad_btn;
		private System.Windows.Forms.Button symbols_btn;
		private System.Windows.Forms.TextBox textBox1;
		private System.Windows.Forms.TextBox textBox2;
		private System.Windows.Forms.TextBox textBox3;
	}
}

