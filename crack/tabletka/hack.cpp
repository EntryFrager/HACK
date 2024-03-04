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
        txSetColor (TX_BLACK);

        HDC image = txLoadImage ("../png/1.bmp", 600, 400);
        txBitBlt (txDC (), 0, 0, 0, 0, image);

        int x_0 = 0;
        int y_0 = 30;

        int delta_x = 10;
        int y_1 = 50;

        char str[2] = ".";

        for (size_t i = 1; i < 61; i++)
        {
                txDrawText (x_0, y_0, x_0 + delta_x, y_1, str);

                x_0 += delta_x;

                txSleep (50);
        }

        txDrawText (150, 70, 450, 100, "File successfully hacked");
}