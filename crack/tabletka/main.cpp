#include "hack.h"

int main ()
{
        int code_error = 0;

        char *file_name = "../CRACKME.COM";

        crack_file (file_name, &code_error);

        graph_video ();

        return 0;
}