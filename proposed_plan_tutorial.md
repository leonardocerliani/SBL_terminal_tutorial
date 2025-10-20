# Computation, terminal usage, Storm access, markdown and github tutorial

This meeting is open to all SBL members and Storm users. It will be conducted in the Large Meeting room from 14:00 to 16:00. 
Everyone must bring their laptops.

Requirements: 
- know how to open a terminal
- have Twingate access
- have a Storm account
- install Visual Studio Code in your computer

## Proposed plan:

**1. Computation part:**

- What is the difference between a CPU and GPU? 
- What is a computer core and its processing power, and how to see it in the terminal? 
- What is the difference between RAM usage and CPU usage? 
- What are the most important commands to check RAM, CPU, computer cores and size of files how to interpret output? 
    - Difference between htop, btop and others 
- What is bash? 

*Estimated time: 15 minutes*

**2. Terminal usage:**
- Most important bash commands for working in terminal/command line – Linux, Windows, Mac 
    - cd / cp / rm / ls / cat / nano / pwd / mdkir / mv / grep / find / cls / man / help / tree / wc / less / chmod / du  plus additions (-a / -r / .. / ~ / * , etc) 
    - alias
    - check size of file
- Ctrl+shift+C to copy to terminal and Ctrl+shift+V to past to terminal 
- Arrows up and down to see older commands 
- Ctrl+A to jump to beginning of line and Ctrl+E to jump to the end 
- How to create any file from the terminal? 
- How to create a bash script to run on multiple datafiles?  
    - Basic shell scripting – variables, for loops and input arguments 
- How to limit CPU usage in parallel processing of multiple files in bash script?  
    - xargs 
- How to use a docker container? 

*Estimated time: 60 minutes*

**3. Storm access and usage:**
- .ssh setup 
- Using ssh to connect to storm (without username/pw) instead of x2goclient	 
    - From the local terminal using an alias of ssh –L  
    - Generating a .ssh/config file 
    - Usage inside VS code 
- How to take advantage of .ssh to use  RStudio, jupyter notebook, Google Colab, Matlab running on storm in your local browser? 
- How to locally edit files/scripts on storm using VS code 
- How to copy from local to remote and vice-versa? 
- How to visualize MRI data on storm?  
    - Using x2goclient: Fslview (docker container) / [itk-snap](https://www.itksnap.org/pmwiki/pmwiki.php) / [MRIcroGL](https://github.com/rordenlab/MRIcroGL)
    - In RStudio within the browser: [PapayaWidget](https://github.com/muschellij2/papayaWidget)

*Estimated time: 45 minutes*
