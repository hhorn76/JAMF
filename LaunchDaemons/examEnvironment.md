<h2>How to create a LaunchDaemon to call a Jamf Pro event trigger</h2>

These compontnets will create a System LaunchDaemon that will execute a Jamf Pro policy event trigger at startup.
We use this to move and backup any files found on the Desktop and Documents folders of our exam computers.

1.  Create the Script backupDesktopAndDocuments.sh in Jamf Pro.
2.  Create a policy that will execute a script with an event trigger of backupDesktop
3.  Create a package with Jamf Pro Composer and add the PLIST de.hhorn76.examEnvironment.plist to /Library/LaunchDaemons/ 
4.  Add the script postInstallExamEnvironment.sh to the post install scripts in Jamf Pro Composer, this will load the LaunchDaemon to execute a event trigger at startup.
5.  Create the package and upload to Jamf Pro Admin.
6.  Create another policy to install the package with the postinstall script.
7.  Whenever the computer is started up, the LaunchDaemon will execute the Jamf Pro event trigger to execute the script, keeping the script on Jamf Pro ensures that we can still modify it, if we would like to change something.
