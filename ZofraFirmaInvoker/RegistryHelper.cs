using System;
using System.Reflection;
using Microsoft.Win32;

namespace ZofraFirmaInvoker
{
    public static class RegistryHelper
    {
        public static void RegisterProtocol()
        {
            string protocolName = "zofratacna";
            string applicationPath = Assembly.GetExecutingAssembly().Location;

            using (RegistryKey key = Registry.ClassesRoot.CreateSubKey(protocolName))
            {
                key.SetValue(string.Empty, "URL:ZofraFirma Protocol");
                key.SetValue("URL Protocol", string.Empty);

                using (RegistryKey defaultIcon = key.CreateSubKey("DefaultIcon"))
                {
                    defaultIcon.SetValue(string.Empty, applicationPath + ",1");
                }

                using (RegistryKey commandKey = key.CreateSubKey(@"shell\open\command"))
                {
                    commandKey.SetValue(string.Empty, "\"" + applicationPath + "\" \"%1\"");
                }
            }
        }
    }
}
