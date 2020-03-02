using UnityEngine;
using System.Collections;
using System.Text;

public static class Debugger
{

    static StringBuilder builder = new StringBuilder();

    public static void Log(string str, params object[] args)
    {
#if LuaDebug

#if DISABLE_PANDORASDK
        builder.Length = 0;
        builder.Append("lua=>");
        builder.AppendFormat(str, args);
        Debug.Log(builder.ToString());
#else
        Debug.Log("lua=>"+str);
#endif

#endif
    }


    public static void LogWarning(string str, params object[] args)
    {
        builder.Length = 0;//clear
        builder.Append("lua=>");
        builder.AppendFormat(str, args);
        Debug.LogWarning(builder.ToString());
    }


    public static void LogError(string str, params object[] args)
    {
        builder.Length = 0; //clear
        builder.Append("lua=>");
        builder.AppendFormat(str, args);
        Debug.LogError(builder.ToString());
    }


}
