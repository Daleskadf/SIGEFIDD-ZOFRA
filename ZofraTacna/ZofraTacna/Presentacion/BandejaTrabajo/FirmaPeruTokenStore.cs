using System;
using System.Collections.Concurrent;

namespace ZofraTacna.Presentacion
{
    public static class FirmaPeruTokenStore
    {
        private static ConcurrentDictionary<string, string> _tokenMap = new ConcurrentDictionary<string, string>();
        private static ConcurrentDictionary<string, DateTime> _tokenExpiry = new ConcurrentDictionary<string, DateTime>();

        public static void StoreToken(string token, string login)
        {
            _tokenMap[token] = login;
            _tokenExpiry[token] = DateTime.Now.AddMinutes(30);
        }

        public static string GetLoginForToken(string token)
        {
            if (_tokenMap.TryGetValue(token, out string login))
            {
                if (_tokenExpiry.TryGetValue(token, out DateTime expiry) && expiry > DateTime.Now)
                {
                    return login;
                }
                else
                {
                    RemoveToken(token);
                }
            }
            return null;
        }

        public static void RemoveToken(string token)
        {
            _tokenMap.TryRemove(token, out _);
            _tokenExpiry.TryRemove(token, out _);
        }
    }
}
