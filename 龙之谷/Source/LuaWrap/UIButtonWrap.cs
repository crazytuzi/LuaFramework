using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIButtonWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("SetState", SetState),
			new LuaMethod("New", _CreateUIButton),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("current", get_current, set_current),
			new LuaField("dragHighlight", get_dragHighlight, set_dragHighlight),
			new LuaField("hoverSprite", get_hoverSprite, set_hoverSprite),
			new LuaField("pressedSprite", get_pressedSprite, set_pressedSprite),
			new LuaField("disabledSprite", get_disabledSprite, set_disabledSprite),
			new LuaField("pixelSnap", get_pixelSnap, set_pixelSnap),
			new LuaField("onClick", get_onClick, set_onClick),
			new LuaField("cacheCol", get_cacheCol, set_cacheCol),
			new LuaField("cacheC2d", get_cacheC2d, set_cacheC2d),
			new LuaField("isEnabled", get_isEnabled, set_isEnabled),
			new LuaField("normalSprite", get_normalSprite, set_normalSprite),
		};

		LuaScriptMgr.RegisterLib(L, "UIButton", typeof(UIButton), regs, fields, typeof(UIButtonColor));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIButton(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIButton class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIButton);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_current(IntPtr L)
	{
		LuaScriptMgr.Push(L, UIButton.current);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_dragHighlight(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name dragHighlight");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index dragHighlight on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.dragHighlight);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hoverSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hoverSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hoverSprite on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.hoverSprite);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pressedSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pressedSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pressedSprite on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.pressedSprite);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_disabledSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name disabledSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index disabledSprite on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.disabledSprite);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pixelSnap(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pixelSnap");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pixelSnap on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.pixelSnap);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onClick(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onClick");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onClick on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.onClick);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cacheCol(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cacheCol");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cacheCol on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.cacheCol);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cacheC2d(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cacheC2d");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cacheC2d on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.cacheC2d);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isEnabled(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

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
	static int get_normalSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name normalSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index normalSprite on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.normalSprite);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_current(IntPtr L)
	{
		UIButton.current = (UIButton)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIButton));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_dragHighlight(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name dragHighlight");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index dragHighlight on a nil value");
			}
		}

		obj.dragHighlight = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_hoverSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hoverSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hoverSprite on a nil value");
			}
		}

		obj.hoverSprite = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pressedSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pressedSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pressedSprite on a nil value");
			}
		}

		obj.pressedSprite = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_disabledSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name disabledSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index disabledSprite on a nil value");
			}
		}

		obj.disabledSprite = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pixelSnap(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pixelSnap");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pixelSnap on a nil value");
			}
		}

		obj.pixelSnap = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onClick(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onClick");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onClick on a nil value");
			}
		}

		obj.onClick = (List<EventDelegate>)LuaScriptMgr.GetNetObject(L, 3, typeof(List<EventDelegate>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cacheCol(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cacheCol");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cacheCol on a nil value");
			}
		}

		obj.cacheCol = (Collider)LuaScriptMgr.GetUnityObject(L, 3, typeof(Collider));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cacheC2d(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cacheC2d");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cacheC2d on a nil value");
			}
		}

		obj.cacheC2d = (Collider2D)LuaScriptMgr.GetUnityObject(L, 3, typeof(Collider2D));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isEnabled(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

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
	static int set_normalSprite(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIButton obj = (UIButton)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name normalSprite");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index normalSprite on a nil value");
			}
		}

		obj.normalSprite = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetState(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		UIButton obj = (UIButton)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIButton");
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

