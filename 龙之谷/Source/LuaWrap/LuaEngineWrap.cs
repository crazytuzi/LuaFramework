using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class LuaEngineWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("InitLua", InitLua),
			new LuaMethod("New", _CreateLuaEngine),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("Instance", get_Instance, set_Instance),
			new LuaField("hotfixMgr", get_hotfixMgr, null),
			new LuaField("luaUIManager", get_luaUIManager, null),
			new LuaField("luaGameInfo", get_luaGameInfo, null),
		};

		LuaScriptMgr.RegisterLib(L, "LuaEngine", typeof(LuaEngine), regs, fields, typeof(MonoBehaviour));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateLuaEngine(IntPtr L)
	{
		LuaDLL.luaL_error(L, "LuaEngine class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(LuaEngine);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Instance(IntPtr L)
	{
		LuaScriptMgr.Push(L, LuaEngine.Instance);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hotfixMgr(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaEngine obj = (LuaEngine)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hotfixMgr");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hotfixMgr on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.hotfixMgr);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_luaUIManager(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaEngine obj = (LuaEngine)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name luaUIManager");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index luaUIManager on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.luaUIManager);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_luaGameInfo(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaEngine obj = (LuaEngine)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name luaGameInfo");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index luaGameInfo on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.luaGameInfo);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Instance(IntPtr L)
	{
		LuaEngine.Instance = (LuaEngine)LuaScriptMgr.GetUnityObject(L, 3, typeof(LuaEngine));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InitLua(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaEngine obj = (LuaEngine)LuaScriptMgr.GetUnityObjectSelf(L, 1, "LuaEngine");
		obj.InitLua();
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

