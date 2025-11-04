#include <stdio.h>        //for printf()
#include <dirent.h>       //library to open, read and close directory
#include <string.h>       //library so that we can use string helpers (e.g. strrchr, strcmp)
#include <stdlib.h>       //library to use system() function for shell commands


int main (void) {

    DIR * directory;                                       //directory pointer variable, to allow program to open and read directory
    struct dirent * entry;                                 //entry pointer, used to read each file inside the directory
    int txt_count = 0;                                     //set txt_count to 0, which counts the number of .txt files



    directory = opendir(".");                              //open the current working directory
    if (directory == NULL) {                               //if directory fails to open
        printf("Error opening directory.\n");              //print out error message 
        return 1;                                          //end program and report error
    }



    printf("All of the .txt files in this directory are as follows:\n");  //header message before listing starts

    while ((entry = readdir(directory)) != NULL) {         //loop to read each file/folder name one by one
        const char *filename = entry->d_name;              //get the file name
        const char *dot = strrchr(filename, '.');          //find the LAST '.' in the file name (e.g. test1.1.txt finds the last dot)

        if (dot != NULL && strcmp(dot, ".txt") == 0) {     //check if file name ends with ".txt"
            printf("%s\n", filename);                      //print out the file name
            txt_count++;                                   //add +1 to txt_count
        }
    }



    if (closedir(directory) == -1) {                       //try to close the directory; if fail, returns -1
        printf("Error closing directory.\n");              //print error message
        return 1;                                          //end program and report error
    }



    printf("\nThere are %d .txt files in the current directory.\n", txt_count);  //print the number of .txt files found



    if (txt_count > 0) {                                   //if there are .txt files, then proceed to compress
        int rc = system("zip -q -T mytxt.zip -- *.txt");   //run shell command to compress all .txt files into mytxt.zip

        if (rc == 0) {                                     //if zip command runs successfully
            printf("Compressed all .txt files into mytxt.zip\n");
            printf("There are number of %d .txt files and compressed into a .zip file.\n", txt_count);
        } 
        else {                                             //if zip command fails
            printf("Compression failed (zip exit code %d).\n", rc);
        }
    } 
    else {                                                 //if there are no .txt files
        printf("No .txt files to compress.\n");
    }



    return 0;                                              //end program normally
}
