using System;
using UnityEngine;
using LuaInterface;

public class LuaUIManagerWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("IsUIShowed", IsUIShowed),
			new LuaMethod("Load", Load),
			new LuaMethod("AttachHandler", AttachHandler),
			new LuaMethod("AttachHandlers", AttachHandlers),
			new LuaMethod("DestroyChilds", DestroyChilds),
			new LuaMethod("DetchHandler", DetchHandler),
			new LuaMethod("Hide", Hide),
			new LuaMethod("GetDlgObj", GetDlgObj),
			new LuaMethod("IDHide", IDHide),
			new LuaMethod("Destroy", Destroy),
			new LuaMethod("IDDestroy", IDDestroy),
			new LuaMethod("Clear", Clear),
			new LuaMethod("New", _CreateLuaUIManager),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("Instance", get_Instance, null),
		};

		LuaScriptMgr.RegisterLib(L, "LuaUIManager", typeof(LuaUIManager), regs, fields, typeof(System.Object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateLuaUIManager(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			LuaUIManager obj = new LuaUIManager();
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: LuaUIManager.New");
		}

		return 0;
	}

	static Type classType = typeof(LuaUIManager);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Instance(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, LuaUIManager.Instance);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsUIShowed(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		bool o = obj.IsUIShowed();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Load(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		bool o = obj.Load(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AttachHandler(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		string arg1 = LuaScriptMgr.GetLuaString(L, 3);
		GameObject o = obj.AttachHandler(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AttachHandlers(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		string[] objs1 = LuaScriptMgr.GetParamsString(L, 3, count - 2);
		obj.AttachHandlers(arg0,objs1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DestroyChilds(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		obj.DestroyChilds(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DetchHandler(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			obj.DetchHandler(arg0);
			return 0;
		}
		else if (count == 3)
		{
			LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			string arg1 = LuaScriptMgr.GetLuaString(L, 3);
			obj.DetchHandler(arg0,arg1);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: LuaUIManager.DetchHandler");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Hide(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		bool o = obj.Hide(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDlgObj(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		GameObject o = obj.GetDlgObj(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IDHide(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 2);
		bool o = obj.IDHide(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Destroy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		bool o = obj.Destroy(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IDDestroy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 2);
		bool o = obj.IDDestroy(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clear(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaUIManager obj = (LuaUIManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaUIManager");
		obj.Clear();
		return 0;
	}
}

