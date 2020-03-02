using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class LuaDlgWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("OnHide", OnHide),
			new LuaMethod("OnDestroy", OnDestroy),
			new LuaMethod("OnShow", OnShow),
			new LuaMethod("New", _CreateLuaDlg),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
		};

		LuaScriptMgr.RegisterLib(L, "LuaDlg", typeof(LuaDlg), regs, fields, typeof(MonoBehaviour));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateLuaDlg(IntPtr L)
	{
		LuaDLL.luaL_error(L, "LuaDlg class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(LuaDlg);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnHide(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaDlg obj = (LuaDlg)LuaScriptMgr.GetUnityObjectSelf(L, 1, "LuaDlg");
		obj.OnHide();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnDestroy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaDlg obj = (LuaDlg)LuaScriptMgr.GetUnityObjectSelf(L, 1, "LuaDlg");
		obj.OnDestroy();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnShow(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaDlg obj = (LuaDlg)LuaScriptMgr.GetUnityObjectSelf(L, 1, "LuaDlg");
		obj.OnShow();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Lua_Eq(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Object arg0 = LuaScriptMgr.GetLuaObject(L, 1) as Object;
		Object arg1 = LuaScriptMgr.GetLuaObject(L, 2) as Object;
		bool o = arg0 == arg1;
		LuaScriptMgr.Push(L, o);
		return 1;
	}
}

