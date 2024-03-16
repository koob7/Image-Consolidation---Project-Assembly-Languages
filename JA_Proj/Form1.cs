 //Projekt JA SSI
 //£¹czenie bitmap pomijaj¹c niepo¿¹dane t³o
 //06.01.2024 semestr V AEI INF 
 //Konrad Kobielus
 //werja v1.0


using ScottPlot;
using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace JA_Proj
{
    public partial class Form1 : Form
    {
        Bitmap image1;
        Bitmap image2;
        Bitmap image3;
        bool photoOpened = false;
        bool photo2Opened = false;
        int numThreads = 1;
        bool asmChosen = false;
        bool cppChosen = false;
        string imagePath1;
        string imagePath2;

        double[] arrayX;
        double[] cppTimes;
        double[] asmTimes;




        public Form1()
        {
            InitializeComponent();
            hScrollBar1.Value = numThreads;
            label2.Text = numThreads.ToString();
        }

        private void button1_Click(object sender, EventArgs e)//za³adowanie obrazu bazowego
        {
            using (OpenFileDialog openFileDialog = new OpenFileDialog())
            {
                openFileDialog.Filter = "Picture (*.bmp)|*.bmp";
                openFileDialog.FilterIndex = 1;

                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                    imagePath1 = openFileDialog.FileName;
                    try
                    {
                        image1 = new Bitmap(imagePath1);
                        photoOpened = true;
                        pictureBox1.Image = image1;
                    }
                    catch (ArgumentException)
                    {
                        MessageBox.Show("Wyst¹pi³ b³¹d. SprawdŸ œcie¿kê do pliku obrazu.");
                        return;
                    }
                }
            }
        }

        private void button2_Click_1(object sender, EventArgs e)//za³adowanie obrazu wstawianego
        {
            using (OpenFileDialog openFileDialog = new OpenFileDialog())
            {
                openFileDialog.Filter = "Picture (*.bmp)|*.bmp";
                openFileDialog.FilterIndex = 1;

                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                    imagePath2 = openFileDialog.FileName;

                    try
                    {
                        image2 = new Bitmap(imagePath2);
                        photo2Opened = true;
                        pictureBox2.Image = image2;
                    }
                    catch (ArgumentException)
                    {
                        MessageBox.Show("Wyst¹pi³ b³¹d. SprawdŸ œcie¿kê do pliku obrazu.");
                        return;
                    }
                }
            }
        }

        private void button3_Click(object sender, EventArgs e)//uruchomienie edycji obrazu
        {
            if (image1 != null && image2 != null && (cppChosen || asmChosen))
            {
                Stopwatch stopwatchCpp = new Stopwatch();
                Stopwatch stopwatchAsm = new Stopwatch();
                int width1 = image1.Width;//szerokoœæ obrazu 1
                int height1 = image1.Height;//wysokoœæ obrazu 1
                int width2 = image2.Width;//szerokoœæ obrazu 2
                int height2 = image2.Height;//wysokoœæ obrazu2
                int startY;//adres poczatku edytowanego obszaru
                int endY;//adres koñca edytowanego obszaru
                BitmapData bitmapData1 = image1.LockBits(new Rectangle(0, 0, width1, height1), ImageLockMode.ReadWrite, PixelFormat.Format24bppRgb);
                BitmapData bitmapData2 = image2.LockBits(new Rectangle(0, 0, width2, height2), ImageLockMode.ReadWrite, PixelFormat.Format24bppRgb);
                int bytesPerPixel = Image.GetPixelFormatSize(PixelFormat.Format24bppRgb) / 8;
                arrayX = new double[numThreads];
                cppTimes = new double[numThreads];
                asmTimes = new double[numThreads];
                for (int numberOfThread = 1; numberOfThread <= numThreads; numberOfThread++)
                {
                    //int numberOfThread = 3;
                    unsafe
                    {                                                       
                        [DllImport(@"C:\Users\kobie\source\repos\JA_Proj\x64\Release\biblioteka_asm.dll")]
                        static extern void MyProc1(byte* start1, byte* end1, byte* endPhoto1, int width1,
                                                     byte* start2, byte* end2, byte* endPhoto2, int width2);
                        //start1 - adres pierwszego piksela w pierwszym wierszu eytowanego obszaru nr1
                        //end1 - adres pierwszego piksela w ostatnim wierszu eytowanego obszaru nr1
                        //endPhoto1 - adres pierwszego piksela w ostatnim wierszu eytowanego obrazu nr1
                        //width1 - liczba pikseli w wierszch obrazu nr1
                        //start2 - adres pierwszego piksela w pierwszym wierszu eytowanego obszaru nr2
                        //end2 - adres pierwszego piksela w ostatnim wierszu eytowanego obszaru nr2
                        //endPhoto2 - adres pierwszego piksela w ostatnim wierszu eytowanego obrazu nr2
                        //width2 - liczba pikseli w wierszch obrazu nr 2
                        [DllImport(@"C:\Users\kobie\source\repos\JA_Proj\x64\Release\dll_cpp.dll")]
                        static extern void editPhoto(byte* start1, byte* end1, byte* endPhoto1, int width1,
                                                     byte* start2, byte* end2, byte* endPhoto2, int width2);

                        byte* ptr1 = (byte*)bitmapData1.Scan0;//wskaŸnik na pierwszy piksel obrazu bazowego
                        byte* ptr2 = (byte*)bitmapData2.Scan0;//wskaŸnik na pierwszy piksel obrazu wstawianego

                        if (asmChosen)//wywo³anie biblioteki asm
                        {

                            stopwatchAsm.Start();
                            Parallel.For(0, numberOfThread, threadNum =>
                            {
                                //obliczanie zakresu edytowanego obszaru dla danego danego w¹tku
                                if (height1 < height2)//je¿eli obraz 1 jest mniejszy
                                {
                                    startY = (height1 / numberOfThread) * threadNum;
                                    if (height1 % numberOfThread >= threadNum + 1)
                                    {
                                        startY += threadNum;
                                    }
                                    else startY += height1 % numberOfThread;
                                    endY = startY + (height1 / numberOfThread);
                                    if (height1 % numberOfThread >= threadNum + 1)
                                    {
                                        endY += 1;
                                    }
                                }
                                else//je¿eli obraz 2 jest mniejszy
                                {
                                    startY = (height2 / numberOfThread) * threadNum;
                                    if (height2 % numberOfThread >= threadNum + 1)
                                    {
                                        startY += threadNum;
                                    }
                                    else startY += height2 % numberOfThread;
                                    endY = startY + (height2 / numberOfThread);
                                    if (height2 % numberOfThread >= threadNum + 1)
                                    {
                                        endY += 1;
                                    }
                                }

                                //if (threadNum == 0)
                                //{
                                try
                                {
                                    MyProc1(ptr1 + startY * width1 * bytesPerPixel, ptr1 + endY * width1 * bytesPerPixel, ptr1 + width1 * height1 * bytesPerPixel, width1,
                                              ptr2 + startY * width2 * bytesPerPixel, ptr2 + endY * width2 * bytesPerPixel, ptr2 + width2 * height2 * bytesPerPixel, width2);
                                }
                                //}
                                catch (Exception e) { }
                            });
                            stopwatchAsm.Stop();//pomiar czasu wywo³ania biblioteki asm
                        }

                        if (cppChosen)//wywo³anie biblioteki cpp
                        {
                            stopwatchCpp.Start();
                            Parallel.For(0, numberOfThread, threadNum =>
                            {
                                if (height1 < height2)
                                {
                                    startY = (height1 / numberOfThread) * threadNum;
                                    if (height1 % numberOfThread >= threadNum + 1)
                                    {
                                        startY += threadNum;
                                    }
                                    else startY += height1 % numberOfThread;
                                    endY = startY + (height1 / numberOfThread);
                                    if (height1 % numberOfThread >= threadNum + 1)
                                    {
                                        endY += 1;
                                    }
                                }
                                else
                                {
                                    startY = (height2 / numberOfThread) * threadNum;
                                    if (height2 % numberOfThread >= threadNum + 1)
                                    {
                                        startY += threadNum;
                                    }
                                    else startY += height2 % numberOfThread;
                                    endY = startY + (height2 / numberOfThread);
                                    if (height2 % numberOfThread >= threadNum + 1)
                                    {
                                        endY += 1;
                                    }
                                }

                                editPhoto(ptr1 + startY * width1 * bytesPerPixel, ptr1 + endY * width1 * bytesPerPixel, ptr1 + width1 * height1 * bytesPerPixel, width1,
                                          ptr2 + startY * width2 * bytesPerPixel, ptr2 + endY * width2 * bytesPerPixel, ptr2 + width2 * height2 * bytesPerPixel, width2);

                            });
                            stopwatchCpp.Stop();//pomiar czasu wywo³ania biblioteki cpp
                        }



                        asmTimes[numberOfThread - 1] = stopwatchAsm.ElapsedTicks;
                        cppTimes[numberOfThread - 1] = stopwatchCpp.ElapsedTicks;
                        stopwatchAsm.Reset();
                        stopwatchCpp.Reset();
                    }

                }

                image1.UnlockBits(bitmapData1);
                image2.UnlockBits(bitmapData2);
                image3 = new Bitmap(image1);//utworzenie nowej bitmapy i skopiowanie do niej zawartoœci bitmapu image1
                image1.Dispose();
                image1 = null;
                photoOpened = false;
                image2.Dispose();
                image2 = null;
                pictureBox1.Image = null;
                pictureBox2.Image = null;

                for (int i = 0; i < numThreads; i++)
                {
                    arrayX[i] = i + 1;
                }
                //narysowanie wykresów
                formsPlot1.Reset();
                formsPlot1.Plot.Legend(Enabled, ScottPlot.Alignment.UpperRight);
                if (cppChosen)
                    formsPlot1.Plot.AddScatter(arrayX, cppTimes, label: "Cpp", lineWidth: 0);
                if (asmChosen)
                    formsPlot1.Plot.AddScatter(arrayX, asmTimes, label: "ASM", lineWidth: 0);
                formsPlot1.Plot.Title("Wykres czasowy");
                formsPlot1.Plot.YLabel("Czas (?s)");
                formsPlot1.Plot.XLabel("Liczba w¹tków");
                //formsPlot1.AddErrorBars(xs, ys, null, yErr, markerSize: 5);
                formsPlot1.Refresh();

                //zapis bitmapy image3 jako "obraz_wynikowy.bmp"
                string outputImagePath = @"C:\Users\kobie\Downloads\obraz_wynikowy.bmp";
                image3.Save(outputImagePath);
                pictureBox3.Image = image3;
            }
            else
            {
                if (!cppChosen && !asmChosen) { MessageBox.Show("Wybierz któr¹ bibliotekê chcesz uruchomiæ"); }
                if (image1 == null) { MessageBox.Show("Za³aduj ponownie zdjêcie bazowe"); }
                if (image2 == null) { MessageBox.Show("Za³aduj ponownie zdjêcie wklejane"); }
            }
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)//wybór biblioteki cpp
        {
            cppChosen = !cppChosen;
        }

        private void checkBox2_CheckedChanged(object sender, EventArgs e)//wybór biblioteki asm
        {
            asmChosen = !asmChosen;
        }

        private void hScrollBar1_Scroll_1(object sender, ScrollEventArgs e)//wybór liczby w¹tków
        {
            HScrollBar hScrollBar = (HScrollBar)sender;
            numThreads = hScrollBar.Value;
            label2.Text = numThreads.ToString();
        }



    }
}
