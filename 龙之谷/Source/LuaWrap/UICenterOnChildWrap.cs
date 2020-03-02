using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UICenterOnChildWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Recenter", Recenter),
			new LuaMethod("CenterOn", CenterOn),
			new LuaMethod("New", _CreateUICenterOnChild),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("springStrength", get_springStrength, set_springStrength),
			new LuaField("nextPageThreshold", get_nextPageThreshold, set_nextPageThreshold),
			new LuaField("onFinished", get_onFinished, set_onFinished),
			new LuaField("centeredObject", get_centeredObject, null),
		};

		LuaScriptMgr.RegisterLib(L, "UICenterOnChild", typeof(UICenterOnChild), regs, fields, typeof(MonoBehaviour));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUICenterOnChild(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UICenterOnChild class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UICenterOnChild);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_springStrength(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UICenterOnChild obj = (UICenterOnChild)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name springStrength");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index springStrength on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.springStrength);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_nextPageThreshold(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UICenterOnChild obj = (UICenterOnChild)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name nextPageThreshold");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index nextPageThreshold on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.nextPageThreshold);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onFinished(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UICenterOnChild obj = (UICenterOnChild)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onFinished");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onFinished on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onFinished);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_centeredObject(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UICenterOnChild obj = (UICenterOnChild)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name centeredObject");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index centeredObject on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.centeredObject);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_springStrength(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UICenterOnChild obj = (UICenterOnChild)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name springStrength");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index springStrength on a nil value");
			}
		}

		obj.springStrength = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_nextPageThreshold(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UICenterOnChild obj = (UICenterOnChild)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name nextPageThreshold");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index nextPageThreshold on a nil value");
			}
		}

		obj.nextPageThreshold = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onFinished(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UICenterOnChild obj = (UICenterOnChild)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onFinished");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onFinished on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onFinished = (SpringPanel.OnFinished)LuaScriptMgr.GetNetObject(L, 3, typeof(SpringPanel.OnFinished));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onFinished = () =>
			{
				func.Call();
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Recenter(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UICenterOnChild obj = (UICenterOnChild)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UICenterOnChild");
		obj.Recenter();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CenterOn(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UICenterOnChild obj = (UICenterOnChild)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UICenterOnChild");
		Transform arg0 = (Transform)LuaScriptMgr.GetUnityObject(L, 2, typeof(Transform));
		obj.CenterOn(arg0);
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

