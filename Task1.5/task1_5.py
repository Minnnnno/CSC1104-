#!/usr/bin/env python3

import os               #library to open, read and close directory
import zipfile          #library to create zip archives without shell commands
import sys              #for exit codes (to mimic return 1 / return 0 behavior)


def main(): 

    directory = "."                                      #directory string variable, to allow program to open and read directory
    txt_count = 0                                        #set txt_count to 0, which counts the number of .txt files
    txt_files = []                                       #list to store .txt filenames we find



    try:
        entries = os.listdir(directory)                  #read all entries (files/folders) in current directory
    except OSError:
        print("Error opening directory.")                #print out error message 
        return 1                                         #end program and report error



    print("All of the .txt files in this directory are as follows:")  #header message before listing starts

    for filename in entries:                             #loop to read each file/folder name one by one
        root, ext = os.path.splitext(filename)           #split name into base and extension (find LAST '.' like strrchr)

        if ext == ".txt":                                #check if file name ends with ".txt"
            print(filename)                              #print out the file name
            txt_count += 1                               #add +1 to txt_count
            txt_files.append(filename)                   #store file name for zipping later



    print(f"\nThere are {txt_count} .txt files in the current directory.")   #print the number of .txt files found



    if txt_count > 0:                                   #if there are .txt files, then proceed to compress
        try:
            with zipfile.ZipFile("mytxt.zip", mode="w", compression=zipfile.ZIP_DEFLATED) as zf:   #run archive creation to compress all .txt files into mytxt.zip
                for f in txt_files:
                    if os.path.isfile(f):                #ensure it’s a regular file (not folder)
                        zf.write(f, arcname=f)           #store file under its name in the zip

            print("Compressed all .txt files into mytxt.zip")  
            print(f"There are number of {txt_count} .txt files and compressed into a .zip file.")
        except Exception as e:
            print(f"Compression failed ({e}).")          #print error message if zipping fails
            return 1                                     #end program and report error

    else:                                                #if there are no .txt files
        print("No .txt files to compress.")



    return 0                                             #end program normally



if __name__ == "__main__":
    sys.exit(main())                                     #run main() and return exit code like C
