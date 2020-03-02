using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

public class HotfixManagerWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("LoadHotfix", LoadHotfix),
			new LuaMethod("Dispose", Dispose),
			new LuaMethod("DoLuaFile", DoLuaFile),
			new LuaMethod("TryFixMsglist", TryFixMsglist),
			new LuaMethod("TryFixClick", TryFixClick),
			new LuaMethod("TryFixRefresh", TryFixRefresh),
			new LuaMethod("TryFixHandler", TryFixHandler),
			new LuaMethod("CallLuaFunc", CallLuaFunc),
			new LuaMethod("RegistedPtc", RegistedPtc),
			new LuaMethod("ProcessOveride", ProcessOveride),
			new LuaMethod("GetLuaScriptMgr", GetLuaScriptMgr),
			new LuaMethod("OnLeaveScene", OnLeaveScene),
			new LuaMethod("OnEnterScene", OnEnterScene),
			new LuaMethod("OnEnterSceneFinally", OnEnterSceneFinally),
			new LuaMethod("OnAttachToHost", OnAttachToHost),
			new LuaMethod("OnPandoraCallback", OnPandoraCallback),
			new LuaMethod("OnReconnect", OnReconnect),
			new LuaMethod("OnDetachFromHost", OnDetachFromHost),
			new LuaMethod("FadeShow", FadeShow),
			new LuaMethod("OnPause", OnPause),
			new LuaMethod("New", _CreateHotfixManager),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("CLICK_LUA_FILE", get_CLICK_LUA_FILE, null),
			new LuaField("DOC_LUA_FILE", get_DOC_LUA_FILE, null),
			new LuaField("MSG_LUE_FILE", get_MSG_LUE_FILE, null),
			new LuaField("befRpath", get_befRpath, set_befRpath),
			new LuaField("aftPath", get_aftPath, set_aftPath),
			new LuaField("breakPath", get_breakPath, set_breakPath),
			new LuaField("useHotfix", get_useHotfix, set_useHotfix),
			new LuaField("hotmsglist", get_hotmsglist, set_hotmsglist),
			new LuaField("Instance", get_Instance, null),
		};

		LuaScriptMgr.RegisterLib(L, "HotfixManager", typeof(HotfixManager), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateHotfixManager(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			HotfixManager obj = new HotfixManager();
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: HotfixManager.New");
		}

		return 0;
	}

	static Type classType = typeof(HotfixManager);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CLICK_LUA_FILE(IntPtr L)
	{
		LuaScriptMgr.Push(L, HotfixManager.CLICK_LUA_FILE);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_DOC_LUA_FILE(IntPtr L)
	{
		LuaScriptMgr.Push(L, HotfixManager.DOC_LUA_FILE);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_MSG_LUE_FILE(IntPtr L)
	{
		LuaScriptMgr.Push(L, HotfixManager.MSG_LUE_FILE);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_befRpath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name befRpath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index befRpath on a nil value");
			}
		}

		LuaScriptMgr.PushArray(L, obj.befRpath);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_aftPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name aftPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index aftPath on a nil value");
			}
		}

		LuaScriptMgr.PushArray(L, obj.aftPath);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_breakPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name breakPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index breakPath on a nil value");
			}
		}

		LuaScriptMgr.PushArray(L, obj.breakPath);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_useHotfix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name useHotfix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index useHotfix on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.useHotfix);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hotmsglist(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hotmsglist");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hotmsglist on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.hotmsglist);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Instance(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, HotfixManager.Instance);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_befRpath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name befRpath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index befRpath on a nil value");
			}
		}

		obj.befRpath = LuaScriptMgr.GetArrayString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_aftPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name aftPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index aftPath on a nil value");
			}
		}

		obj.aftPath = LuaScriptMgr.GetArrayString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_breakPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name breakPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index breakPath on a nil value");
			}
		}

		obj.breakPath = LuaScriptMgr.GetArrayString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_useHotfix(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name useHotfix");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index useHotfix on a nil value");
			}
		}

		obj.useHotfix = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_hotmsglist(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		HotfixManager obj = (HotfixManager)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hotmsglist");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hotmsglist on a nil value");
			}
		}

		obj.hotmsglist = (Dictionary<string,string>)LuaScriptMgr.GetNetObject(L, 3, typeof(Dictionary<string,string>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadHotfix(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		Action arg0 = null;
		LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

		if (funcType2 != LuaTypes.LUA_TFUNCTION)
		{
			 arg0 = (Action)LuaScriptMgr.GetNetObject(L, 2, typeof(Action));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.GetLuaFunction(L, 2);
			arg0 = () =>
			{
				func.Call();
			};
		}

		obj.LoadHotfix(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Dispose(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		obj.Dispose();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DoLuaFile(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		bool o = obj.DoLuaFile(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TryFixMsglist(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		obj.TryFixMsglist();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TryFixClick(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		XUtliPoolLib.HotfixMode arg0 = (XUtliPoolLib.HotfixMode)LuaScriptMgr.GetNetObject(L, 2, typeof(XUtliPoolLib.HotfixMode));
		string arg1 = LuaScriptMgr.GetLuaString(L, 3);
		bool o = obj.TryFixClick(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TryFixRefresh(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		XUtliPoolLib.HotfixMode arg0 = (XUtliPoolLib.HotfixMode)LuaScriptMgr.GetNetObject(L, 2, typeof(XUtliPoolLib.HotfixMode));
		string arg1 = LuaScriptMgr.GetLuaString(L, 3);
		GameObject arg2 = (GameObject)LuaScriptMgr.GetUnityObject(L, 4, typeof(GameObject));
		bool o = obj.TryFixRefresh(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TryFixHandler(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		XUtliPoolLib.HotfixMode arg0 = (XUtliPoolLib.HotfixMode)LuaScriptMgr.GetNetObject(L, 2, typeof(XUtliPoolLib.HotfixMode));
		string arg1 = LuaScriptMgr.GetLuaString(L, 3);
		GameObject arg2 = (GameObject)LuaScriptMgr.GetUnityObject(L, 4, typeof(GameObject));
		bool o = obj.TryFixHandler(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallLuaFunc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		string arg1 = LuaScriptMgr.GetLuaString(L, 3);
		obj.CallLuaFunc(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RegistedPtc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 2);
		byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 3);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 4);
		obj.RegistedPtc(arg0,objs1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ProcessOveride(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 2);
		byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 3);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 4);
		obj.ProcessOveride(arg0,objs1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLuaScriptMgr(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		LuaScriptMgr o = obj.GetLuaScriptMgr();
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnLeaveScene(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		obj.OnLeaveScene();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnEnterScene(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		obj.OnEnterScene();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnEnterSceneFinally(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		obj.OnEnterSceneFinally();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnAttachToHost(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		obj.OnAttachToHost();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnPandoraCallback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		obj.OnPandoraCallback(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnReconnect(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		obj.OnReconnect();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnDetachFromHost(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		obj.OnDetachFromHost();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FadeShow(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
		obj.FadeShow(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnPause(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		HotfixManager obj = (HotfixManager)LuaScriptMgr.GetNetObjectSelf(L, 1, "HotfixManager");
		bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
		obj.OnPause(arg0);
		return 0;
	}
}

