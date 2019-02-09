#include "chilkat/include/CkFtp2.h"
#include <stdio.h>

void ChilkatSample(void)
    {
    CkFtp2 ftp;

    bool success;

    //  Any string unlocks the component for the 1st 30-days.
    success = ftp.UnlockComponent("Anything for 30-day trial");
    if (success != true) {
        return;
    }

    ftp.put_Hostname("ftp.someFtpServer.com");
    ftp.put_Username("myLogin");
    ftp.put_Password("myPassword");

    //  Connect and login to the FTP server.
    success = ftp.Connect();
    if (success != true) {
        return;
    }

    //  Change to the remote directory where the file is located.
    //  This step is only necessary if the file is not in the root directory
    //  for the FTP account.
    success = ftp.ChangeRemoteDir("junk");
    if (success != true) {
        return;
    }

    const char *localFilename = "c:/temp/hamlet.xml";
    const char *remoteFilename = "hamlet.xml";

    //  Download a file.
    success = ftp.GetFile(remoteFilename,localFilename);
    if (success != true) {
        return;
    }

    success = ftp.Disconnect();


    }
