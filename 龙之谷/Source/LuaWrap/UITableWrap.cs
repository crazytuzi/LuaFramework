using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UITableWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Reposition", Reposition),
			new LuaMethod("RepositionOnlyOneLevel", RepositionOnlyOneLevel),
			new LuaMethod("New", _CreateUITable),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("columns", get_columns, set_columns),
			new LuaField("direction", get_direction, set_direction),
			new LuaField("sorting", get_sorting, set_sorting),
			new LuaField("hideInactive", get_hideInactive, set_hideInactive),
			new LuaField("keepWithinPanel", get_keepWithinPanel, set_keepWithinPanel),
			new LuaField("padding", get_padding, set_padding),
			new LuaField("onReposition", get_onReposition, set_onReposition),
			new LuaField("repositionNow", null, set_repositionNow),
			new LuaField("children", get_children, null),
		};

		LuaScriptMgr.RegisterLib(L, "UITable", typeof(UITable), regs, fields, typeof(UIWidgetContainer));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUITable(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UITable class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UITable);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_columns(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name columns");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index columns on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.columns);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_direction(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name direction");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index direction on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.direction);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sorting(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name sorting");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index sorting on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.sorting);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hideInactive(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hideInactive");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hideInactive on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.hideInactive);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_keepWithinPanel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name keepWithinPanel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index keepWithinPanel on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.keepWithinPanel);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_padding(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name padding");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index padding on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.padding);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onReposition(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onReposition");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onReposition on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onReposition);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_children(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name children");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index children on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.children);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_columns(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name columns");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index columns on a nil value");
			}
		}

		obj.columns = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_direction(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name direction");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index direction on a nil value");
			}
		}

		obj.direction = (UITable.Direction)LuaScriptMgr.GetNetObject(L, 3, typeof(UITable.Direction));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sorting(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name sorting");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index sorting on a nil value");
			}
		}

		obj.sorting = (UITable.Sorting)LuaScriptMgr.GetNetObject(L, 3, typeof(UITable.Sorting));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_hideInactive(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hideInactive");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hideInactive on a nil value");
			}
		}

		obj.hideInactive = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_keepWithinPanel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name keepWithinPanel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index keepWithinPanel on a nil value");
			}
		}

		obj.keepWithinPanel = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_padding(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name padding");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index padding on a nil value");
			}
		}

		obj.padding = LuaScriptMgr.GetVector2(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onReposition(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onReposition");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onReposition on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onReposition = (UITable.OnReposition)LuaScriptMgr.GetNetObject(L, 3, typeof(UITable.OnReposition));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onReposition = () =>
			{
				func.Call();
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_repositionNow(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITable obj = (UITable)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name repositionNow");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index repositionNow on a nil value");
			}
		}

		obj.repositionNow = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Reposition(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UITable obj = (UITable)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UITable");
		obj.Reposition();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RepositionOnlyOneLevel(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UITable obj = (UITable)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UITable");
		obj.RepositionOnlyOneLevel();
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

