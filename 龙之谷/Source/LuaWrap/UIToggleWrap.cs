using System;
using UnityEngine;
using System.Collections.Generic;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIToggleWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("GetActiveToggle", GetActiveToggle),
			new LuaMethod("ForceSetActive", ForceSetActive),
			new LuaMethod("New", _CreateUIToggle),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("list", get_list, set_list),
			new LuaField("current", get_current, set_current),
			new LuaField("group", get_group, set_group),
			new LuaField("activeSprite", get_activeSprite, set_activeSprite),
			new LuaField("activeSprite2", get_activeSprite2, set_activeSprite2),
			new LuaField("activeAnimation", get_activeAnimation, set_activeAnimation),
			new LuaField("startsActive", get_startsActive, set_startsActive),
			new LuaField("instantTween", get_instantTween, set_instantTween),
			new LuaField("optionCanBeNone", get_optionCanBeNone, set_optionCanBeNone),
			new LuaField("onChange", get_onChange, set_onChange),
			new LuaField("value", get_value, set_value),
		};

		LuaScriptMgr.RegisterLib(L, "UIToggle", typeof(UIToggle), regs, fields, typeof(UIWidgetContainer));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIToggle(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIToggle class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIToggle);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_list(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, UIToggle.list);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_current(IntPtr L)
	{
		LuaScriptMgr.Push(L, UIToggle.current);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_group(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name group");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index group on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.group);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_activeSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeSprite on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.activeSprite);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_activeSprite2(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeSprite2");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeSprite2 on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.activeSprite2);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_activeAnimation(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeAnimation");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeAnimation on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.activeAnimation);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startsActive(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name startsActive");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index startsActive on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.startsActive);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_instantTween(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name instantTween");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index instantTween on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.instantTween);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_optionCanBeNone(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name optionCanBeNone");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index optionCanBeNone on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.optionCanBeNone);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onChange(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onChange");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onChange on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.onChange);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_value(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name value");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index value on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.value);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_list(IntPtr L)
	{
		UIToggle.list = (BetterList<UIToggle>)LuaScriptMgr.GetNetObject(L, 3, typeof(BetterList<UIToggle>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_current(IntPtr L)
	{
		UIToggle.current = (UIToggle)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIToggle));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_group(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name group");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index group on a nil value");
			}
		}

		obj.group = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_activeSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeSprite on a nil value");
			}
		}

		obj.activeSprite = (UIWidget)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIWidget));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_activeSprite2(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeSprite2");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeSprite2 on a nil value");
			}
		}

		obj.activeSprite2 = (UIWidget)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIWidget));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_activeAnimation(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeAnimation");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeAnimation on a nil value");
			}
		}

		obj.activeAnimation = (Animation)LuaScriptMgr.GetUnityObject(L, 3, typeof(Animation));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startsActive(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name startsActive");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index startsActive on a nil value");
			}
		}

		obj.startsActive = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_instantTween(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name instantTween");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index instantTween on a nil value");
			}
		}

		obj.instantTween = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_optionCanBeNone(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name optionCanBeNone");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index optionCanBeNone on a nil value");
			}
		}

		obj.optionCanBeNone = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onChange(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onChange");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onChange on a nil value");
			}
		}

		obj.onChange = (List<EventDelegate>)LuaScriptMgr.GetNetObject(L, 3, typeof(List<EventDelegate>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_value(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIToggle obj = (UIToggle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name value");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index value on a nil value");
			}
		}

		obj.value = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetActiveToggle(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		UIToggle o = UIToggle.GetActiveToggle(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ForceSetActive(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIToggle obj = (UIToggle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIToggle");
		bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
		obj.ForceSetActive(arg0);
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

