using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

public class LocalizationWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Load", Load),
			new LuaMethod("LoadCSV", LoadCSV),
			new LuaMethod("Set", Set),
			new LuaMethod("Get", Get),
			new LuaMethod("Exists", Exists),
			new LuaMethod("New", _CreateLocalization),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("localizationHasBeenSet", get_localizationHasBeenSet, set_localizationHasBeenSet),
			new LuaField("dictionary", get_dictionary, set_dictionary),
			new LuaField("knownLanguages", get_knownLanguages, null),
			new LuaField("language", get_language, set_language),
		};

		LuaScriptMgr.RegisterLib(L, "Localization", typeof(Localization), regs, fields, null);
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateLocalization(IntPtr L)
	{
		LuaDLL.luaL_error(L, "Localization class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(Localization);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_localizationHasBeenSet(IntPtr L)
	{
		LuaScriptMgr.Push(L, Localization.localizationHasBeenSet);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_dictionary(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, Localization.dictionary);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_knownLanguages(IntPtr L)
	{
		LuaScriptMgr.PushArray(L, Localization.knownLanguages);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_language(IntPtr L)
	{
		LuaScriptMgr.Push(L, Localization.language);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_localizationHasBeenSet(IntPtr L)
	{
		Localization.localizationHasBeenSet = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_dictionary(IntPtr L)
	{
		Localization.dictionary = (Dictionary<string,string[]>)LuaScriptMgr.GetNetObject(L, 3, typeof(Dictionary<string,string[]>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_language(IntPtr L)
	{
		Localization.language = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Load(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		TextAsset arg0 = (TextAsset)LuaScriptMgr.GetUnityObject(L, 1, typeof(TextAsset));
		Localization.Load(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadCSV(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		TextAsset arg0 = (TextAsset)LuaScriptMgr.GetUnityObject(L, 1, typeof(TextAsset));
		bool o = Localization.LoadCSV(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Set(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		Dictionary<string,string> arg1 = (Dictionary<string,string>)LuaScriptMgr.GetNetObject(L, 2, typeof(Dictionary<string,string>));
		Localization.Set(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Get(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(string)))
		{
			string arg0 = LuaScriptMgr.GetString(L, 1);
			string o = Localization.Get(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(int)))
		{
			int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
			string o = Localization.Get(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Localization.Get");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Exists(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		bool o = Localization.Exists(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}
}

