using System;
using LuaInterface;

public class LuaGameInfoWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("New", _CreateLuaGameInfo),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("single", get_single, null),
			new LuaField("name", get_name, set_name),
			new LuaField("exp", get_exp, set_exp),
			new LuaField("maxexp", get_maxexp, set_maxexp),
			new LuaField("level", get_level, set_level),
			new LuaField("ppt", get_ppt, set_ppt),
			new LuaField("coin", get_coin, set_coin),
			new LuaField("dia", get_dia, set_dia),
			new LuaField("energy", get_energy, set_energy),
			new LuaField("draggon", get_draggon, set_draggon),
		};

		LuaScriptMgr.RegisterLib(L, "LuaGameInfo", typeof(LuaGameInfo), regs, fields, typeof(System.Object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateLuaGameInfo(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			LuaGameInfo obj = new LuaGameInfo();
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: LuaGameInfo.New");
		}

		return 0;
	}

	static Type classType = typeof(LuaGameInfo);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_single(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, LuaGameInfo.single);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_name(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name name");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index name on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.name);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_exp(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name exp");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index exp on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.exp);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maxexp(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name maxexp");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index maxexp on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.maxexp);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_level(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name level");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index level on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.level);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ppt(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name ppt");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index ppt on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.ppt);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_coin(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name coin");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index coin on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.coin);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_dia(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name dia");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index dia on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.dia);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_energy(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name energy");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index energy on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.energy);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_draggon(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name draggon");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index draggon on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.draggon);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_name(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name name");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index name on a nil value");
			}
		}

		obj.name = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_exp(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name exp");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index exp on a nil value");
			}
		}

		obj.exp = (uint)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maxexp(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name maxexp");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index maxexp on a nil value");
			}
		}

		obj.maxexp = (uint)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_level(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name level");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index level on a nil value");
			}
		}

		obj.level = (uint)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ppt(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name ppt");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index ppt on a nil value");
			}
		}

		obj.ppt = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_coin(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name coin");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index coin on a nil value");
			}
		}

		obj.coin = (uint)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_dia(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name dia");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index dia on a nil value");
			}
		}

		obj.dia = (uint)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_energy(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name energy");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index energy on a nil value");
			}
		}

		obj.energy = (uint)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_draggon(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaGameInfo obj = (LuaGameInfo)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name draggon");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index draggon on a nil value");
			}
		}

		obj.draggon = (uint)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}
}

