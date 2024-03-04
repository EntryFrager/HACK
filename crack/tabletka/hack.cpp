#include "hack.h"

void crack_file (char *file_name, int *code_error)
{
        my_assert (file_name != NULL, ERR_PTR);

        FOPEN_ (crackme, file_name, "r+b");

        char nope_buffer[] = {0x90, 0x90};

        int offset = 118;

        fseek (crackme, offset, 0);
        fwrite (nope_buffer, sizeof(char), 2, crackme);

        FCLOSE_ (crackme);

        return;
}

void graph_video ()
{
        txCreateWindow (600, 400, true);
        txSetColor (TX_PINK);

        char *name_image[10] = {"../png/1.bmp", "../png/2.bmp", "../png/3.bmp", "../png/4.bmp", "../png/5.bmp",
                                "../png/6.bmp", "../png/7.bmp", "../png/8.bmp", "../png/9.bmp", "../png/10.bmp"};

        int x_0 = 10;
        int y_0 = 300;

        int x_1 = 310;
        int y_1 = 340;

        int x_2 = 13;

        int delta_x = 3;

        int x_0_proc = 130;
        int y_0_proc = 350;

        int x_1_proc = 200;
        int y_1_proc = 390;

        char str[4] = "";

        char *png_name = NULL;

        char *name_sound = "../sound/sound.wav";
        
        txPlaySound (name_sound);

        for (size_t i = 1; i <= 100; i++)
        {
                if ((i - 1) % 10 == 0)
                {
                        png_name = name_image[(i - 1) / 10];       
                }

                HDC image = txLoadImage (png_name, 600, 400);
                txClear ();
                txBitBlt (txDC (), 0, 0, 0, 0, image);

                txSetFillColor (TX_WHITE);
                txRectangle (x_0, y_0, x_1, y_1);
                
                txSetFillColor (TX_PINK);       
                txRectangle (x_0, y_0, x_2, y_1);

                char *str_proc = itoa (i, str, 10);
                txDrawText (x_0_proc, y_0_proc, x_1_proc, y_1_proc, str_proc);

                x_2 += delta_x;

                txSleep (200);
        }

        txPlaySound (NULL);

        txDrawText (150, 70, 450, 100, "File successfully hacked");
}