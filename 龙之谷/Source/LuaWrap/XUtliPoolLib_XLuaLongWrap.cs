using System;
using LuaInterface;

public class XUtliPoolLib_XLuaLongWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Get", Get),
			new LuaMethod("New", _CreateXUtliPoolLib_XLuaLong),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("str", get_str, set_str),
		};

		LuaScriptMgr.RegisterLib(L, "XUtliPoolLib.XLuaLong", typeof(XUtliPoolLib.XLuaLong), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateXUtliPoolLib_XLuaLong(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			XUtliPoolLib.XLuaLong obj = new XUtliPoolLib.XLuaLong(arg0);
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XLuaLong.New");
		}

		return 0;
	}

	static Type classType = typeof(XUtliPoolLib.XLuaLong);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_str(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		XUtliPoolLib.XLuaLong obj = (XUtliPoolLib.XLuaLong)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name str");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index str on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.str);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_str(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		XUtliPoolLib.XLuaLong obj = (XUtliPoolLib.XLuaLong)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name str");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index str on a nil value");
			}
		}

		obj.str = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Get(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		XUtliPoolLib.XLuaLong obj = (XUtliPoolLib.XLuaLong)LuaScriptMgr.GetNetObjectSelf(L, 1, "XUtliPoolLib.XLuaLong");
		ulong o = obj.Get();
		LuaScriptMgr.Push(L, o);
		return 1;
	}
}

