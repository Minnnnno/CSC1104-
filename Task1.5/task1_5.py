#!/usr/bin/env python3

import os               #library to open, read and close directory
import zipfile          #library to create zip archives without shell commands
import sys              #for exit codes (to mimic return 1 / return 0 behavior)
import time              #library for high-resolution timing


def main(): 

    directory = "."                                      #directory string variable, to allow program to open and read directory
    txt_count = 0                                        #set txt_count to 0, which counts the number of .txt files
    txt_files = []                                       #list to store .txt filenames we find

    
    t_total0 = time.perf_counter()                      #record program start time
   

    try:
        entries = os.listdir(directory)                  #read all entries (files/folders) in current directory
    except OSError:
        print("Error opening directory.")                #print out error message 
        return 1                                         #end program and report error

    print("All of the .txt files in this directory are as follows:")  #header message before listing starts

    
    t_list0 = time.perf_counter()                       #record listing start time
    
    for filename in entries:                             #loop to read each file/folder name one by one
        root, ext = os.path.splitext(filename)           #split name into base and extension (find LAST '.' like strrchr)

        if ext == ".txt":                                #check if file name ends with ".txt"
            print(filename)                              #print out the file name
            txt_count += 1                               #add +1 to txt_count
            txt_files.append(filename)                   #store file name for zipping later
    t_list1 = time.perf_counter()                        #record listing end time
    list_ms = (t_list1 - t_list0) * 1000                 #calculate duration in milliseconds
    

    print(f"\nThere are {txt_count} .txt files in the current directory.")   #print the number of .txt files found

    zip_ms = 0                                           #variable to hold compression time

    if txt_count > 0:                                   #if there are .txt files, then proceed to compress
        #START compression timing 
        t_zip0 = time.perf_counter()                    #record compression start time
        
        try:
            with zipfile.ZipFile("mytxt.zip", mode="w", compression=zipfile.ZIP_DEFLATED) as zf:   #run archive creation to compress all .txt files into mytxt.zip
                for f in txt_files:
                    if os.path.isfile(f):                #ensure it’s a regular file (not folder)
                        zf.write(f, arcname=f)           #store file under its name in the zip
            t_zip1 = time.perf_counter()                 #record compression end time
            zip_ms = (t_zip1 - t_zip0) * 1000            #calculate compression duration (ms)
            # END compression timing 
            print("Compressed all .txt files into mytxt.zip")  
            print(f"There are number of {txt_count} .txt files and compressed into a .zip file.")
        except Exception as e:
            print(f"Compression failed ({e}).")          #print error message if zipping fails
            return 1                                     #end program and report error
    else:                                                #if there are no .txt files
        print("No .txt files to compress.")

    #  END total timing 
    t_total1 = time.perf_counter()                      #record program end time
    total_ms = (t_total1 - t_total0) * 1000             #calculate total duration (ms)
    # 

    # Timing Results
    print(f"\n[Timing] Listing: {list_ms:.3f} ms")
    if txt_count > 0:
        print(f"[Timing] Compression: {zip_ms:.3f} ms")    #if timing more than 0s, means there is file 
    else:
        print("[Timing] Compression: N/A (no .txt files)") #else compression timing now known.
    print(f"[Timing] Total program: {total_ms:.3f} ms")

    return 0                                             #end program normally


if __name__ == "__main__":
    sys.exit(main())                                     #run main() and return exit code like C
