//Projekt JA SSI
//Łączenie bitmap pomijając niepożądane tło
//06.01.2024 semestr V AEI INF 
//Konrad Kobielus
//werja v1.0
using ScottPlot;
using System;
using System.Windows.Forms;



namespace JA_Proj
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
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
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            checkBox1 = new CheckBox();
            checkBox2 = new CheckBox();
            pictureBox1 = new PictureBox();
            button1 = new Button();
            pictureBox2 = new PictureBox();
            pictureBox3 = new PictureBox();
            button2 = new Button();
            button3 = new Button();
            label4 = new Label();
            backgroundWorker1 = new System.ComponentModel.BackgroundWorker();
            formsPlot1 = new FormsPlot();
            label1 = new Label();
            hScrollBar1 = new HScrollBar();
            label2 = new Label();
            ((System.ComponentModel.ISupportInitialize)pictureBox1).BeginInit();
            ((System.ComponentModel.ISupportInitialize)pictureBox2).BeginInit();
            ((System.ComponentModel.ISupportInitialize)pictureBox3).BeginInit();
            SuspendLayout();
            // 
            // checkBox1
            // 
            checkBox1.AutoSize = true;
            checkBox1.Location = new Point(57, 216);
            checkBox1.Name = "checkBox1";
            checkBox1.Size = new Size(56, 24);
            checkBox1.TabIndex = 2;
            checkBox1.Text = "cpp";
            checkBox1.UseVisualStyleBackColor = true;
            checkBox1.CheckedChanged += checkBox1_CheckedChanged;
            // 
            // checkBox2
            // 
            checkBox2.AutoSize = true;
            checkBox2.Location = new Point(209, 216);
            checkBox2.Name = "checkBox2";
            checkBox2.Size = new Size(58, 24);
            checkBox2.TabIndex = 3;
            checkBox2.Text = "asm";
            checkBox2.UseVisualStyleBackColor = true;
            checkBox2.CheckedChanged += checkBox2_CheckedChanged;
            // 
            // pictureBox1
            // 
            pictureBox1.Location = new Point(21, 334);
            pictureBox1.Name = "pictureBox1";
            pictureBox1.Size = new Size(306, 230);
            pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBox1.TabIndex = 5;
            pictureBox1.TabStop = false;
            // 
            // button1
            // 
            button1.Location = new Point(45, 299);
            button1.Name = "button1";
            button1.Size = new Size(264, 29);
            button1.TabIndex = 6;
            button1.Text = "wybierz zdjęcie bazowe";
            button1.UseVisualStyleBackColor = true;
            button1.Click += button1_Click;
            // 
            // pictureBox2
            // 
            pictureBox2.Location = new Point(363, 334);
            pictureBox2.Name = "pictureBox2";
            pictureBox2.Size = new Size(306, 230);
            pictureBox2.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBox2.TabIndex = 9;
            pictureBox2.TabStop = false;
            // 
            // pictureBox3
            // 
            pictureBox3.Location = new Point(363, 49);
            pictureBox3.Name = "pictureBox3";
            pictureBox3.Size = new Size(306, 230);
            pictureBox3.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBox3.TabIndex = 10;
            pictureBox3.TabStop = false;
            // 
            // button2
            // 
            button2.Location = new Point(384, 299);
            button2.Name = "button2";
            button2.Size = new Size(264, 29);
            button2.TabIndex = 11;
            button2.Text = "wybierz zdjęcie wstawiane";
            button2.UseVisualStyleBackColor = true;
            button2.Click += button2_Click_1;
            // 
            // button3
            // 
            button3.Location = new Point(384, 12);
            button3.Name = "button3";
            button3.Size = new Size(264, 29);
            button3.TabIndex = 13;
            button3.Text = "uruchom program";
            button3.UseVisualStyleBackColor = true;
            button3.Click += button3_Click;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Location = new Point(93, 171);
            label4.Name = "label4";
            label4.Size = new Size(135, 20);
            label4.TabIndex = 17;
            label4.Text = "wybierz bibliotekę ";
            // 
            // formsPlot1
            // 
            formsPlot1.Location = new Point(698, 131);
            formsPlot1.Margin = new Padding(5, 4, 5, 4);
            formsPlot1.Name = "formsPlot1";
            formsPlot1.Size = new Size(552, 342);
            formsPlot1.TabIndex = 18;
            formsPlot1.Plot.Title("Wykres czasowy");
            formsPlot1.Plot.YLabel("Czas (μs)");
            formsPlot1.Plot.XLabel("Liczba wątków");
            formsPlot1.Refresh();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(45, 38);
            label1.Name = "label1";
            label1.Size = new Size(248, 20);
            label1.TabIndex = 20;
            label1.Text = "wybierz maksymalną  liczbę wątków";
            // 
            // hScrollBar1
            // 
            hScrollBar1.Location = new Point(37, 89);
            hScrollBar1.Maximum = 73;
            hScrollBar1.Minimum = 1;
            hScrollBar1.Name = "hScrollBar1";
            hScrollBar1.Size = new Size(207, 43);
            hScrollBar1.TabIndex = 21;
            hScrollBar1.Value = 1;
            hScrollBar1.Scroll += hScrollBar1_Scroll_1;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new Point(284, 98);
            label2.Name = "label2";
            label2.Size = new Size(17, 20);
            label2.TabIndex = 22;
            label2.Text = "1";
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1264, 583);
            Controls.Add(label2);
            Controls.Add(hScrollBar1);
            Controls.Add(label1);
            Controls.Add(formsPlot1);
            Controls.Add(label4);
            Controls.Add(button3);
            Controls.Add(button2);
            Controls.Add(pictureBox3);
            Controls.Add(pictureBox2);
            Controls.Add(button1);
            Controls.Add(pictureBox1);
            Controls.Add(checkBox2);
            Controls.Add(checkBox1);
            Name = "Form1";
            Text = "Form1";
            ((System.ComponentModel.ISupportInitialize)pictureBox1).EndInit();
            ((System.ComponentModel.ISupportInitialize)pictureBox2).EndInit();
            ((System.ComponentModel.ISupportInitialize)pictureBox3).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion


        private CheckBox checkBox1;
        private CheckBox checkBox2;
        private PictureBox pictureBox1;
        private Button button1;
        private PictureBox pictureBox2;
        private PictureBox pictureBox3;
        private Button button2;
        private Button button3;
        private Label label4;
        private System.ComponentModel.BackgroundWorker backgroundWorker1;
        private FormsPlot formsPlot1;
        private Label label1;
        private HScrollBar hScrollBar1;
        private Label label2;
    }
}