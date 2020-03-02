using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIButtonColorWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("SetState", SetState),
			new LuaMethod("New", _CreateUIButtonColor),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("tweenTarget", get_tweenTarget, set_tweenTarget),
			new LuaField("hover", get_hover, set_hover),
			new LuaField("pressed", get_pressed, set_pressed),
			new LuaField("disabledColor", get_disabledColor, set_disabledColor),
			new LuaField("changeStateSprite", get_changeStateSprite, set_changeStateSprite),
			new LuaField("duration", get_duration, set_duration),
			new LuaField("state", get_state, set_state),
			new LuaField("defaultColor", get_defaultColor, set_defaultColor),
			new LuaField("isEnabled", get_isEnabled, set_isEnabled),
		};

		LuaScriptMgr.RegisterLib(L, "UIButtonColor", typeof(UIButtonColor), regs, fields, typeof(UIWidgetContainer));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIButtonColor(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIButtonColor class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIButtonColor);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_tweenTarget(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name tweenTarget");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index tweenTarget on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.tweenTarget);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hover(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hover");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hover on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.hover);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pressed(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pressed");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pressed on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.pressed);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_disabledColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name disabledColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index disabledColor on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.disabledColor);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_changeStateSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name changeStateSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index changeStateSprite on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.changeStateSprite);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_duration(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name duration");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index duration on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.duration);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_state(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name state");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index state on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.state);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_defaultColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name defaultColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index defaultColor on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.defaultColor);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isEnabled(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isEnabled");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isEnabled on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isEnabled);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_tweenTarget(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name tweenTarget");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index tweenTarget on a nil value");
			}
		}

		obj.tweenTarget = (GameObject)LuaScriptMgr.GetUnityObject(L, 3, typeof(GameObject));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_hover(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hover");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hover on a nil value");
			}
		}

		obj.hover = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pressed(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pressed");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pressed on a nil value");
			}
		}

		obj.pressed = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_disabledColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name disabledColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index disabledColor on a nil value");
			}
		}

		obj.disabledColor = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_changeStateSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name changeStateSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index changeStateSprite on a nil value");
			}
		}

		obj.changeStateSprite = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_duration(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name duration");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index duration on a nil value");
			}
		}

		obj.duration = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_state(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name state");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index state on a nil value");
			}
		}

		obj.state = (UIButtonColor.State)LuaScriptMgr.GetNetObject(L, 3, typeof(UIButtonColor.State));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_defaultColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name defaultColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index defaultColor on a nil value");
			}
		}

		obj.defaultColor = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isEnabled(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButtonColor obj = (UIButtonColor)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isEnabled");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isEnabled on a nil value");
			}
		}

		obj.isEnabled = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetState(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		UIButtonColor obj = (UIButtonColor)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIButtonColor");
		UIButtonColor.State arg0 = (UIButtonColor.State)LuaScriptMgr.GetNetObject(L, 2, typeof(UIButtonColor.State));
		bool arg1 = LuaScriptMgr.GetBoolean(L, 3);
		obj.SetState(arg0,arg1);
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

