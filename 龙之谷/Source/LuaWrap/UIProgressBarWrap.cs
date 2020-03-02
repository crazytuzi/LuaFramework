using System;
using UnityEngine;
using System.Collections.Generic;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIProgressBarWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("ForceUpdate", ForceUpdate),
			new LuaMethod("SetDynamicGround", SetDynamicGround),
			new LuaMethod("New", _CreateUIProgressBar),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("current", get_current, set_current),
			new LuaField("bHideThumbAtEnds", get_bHideThumbAtEnds, set_bHideThumbAtEnds),
			new LuaField("onDragFinished", get_onDragFinished, set_onDragFinished),
			new LuaField("bHideFgAtEnds", get_bHideFgAtEnds, set_bHideFgAtEnds),
			new LuaField("UseFillDir", get_UseFillDir, set_UseFillDir),
			new LuaField("thumb", get_thumb, set_thumb),
			new LuaField("mBG", get_mBG, set_mBG),
			new LuaField("mFG", get_mFG, set_mFG),
			new LuaField("mDG", get_mDG, set_mDG),
			new LuaField("numberOfSteps", get_numberOfSteps, set_numberOfSteps),
			new LuaField("onChange", get_onChange, set_onChange),
			new LuaField("cachedTransform", get_cachedTransform, null),
			new LuaField("cachedCamera", get_cachedCamera, null),
			new LuaField("foregroundWidget", get_foregroundWidget, set_foregroundWidget),
			new LuaField("backgroundWidget", get_backgroundWidget, set_backgroundWidget),
			new LuaField("fillDirection", get_fillDirection, set_fillDirection),
			new LuaField("value", get_value, set_value),
			new LuaField("alpha", get_alpha, set_alpha),
		};

		LuaScriptMgr.RegisterLib(L, "UIProgressBar", typeof(UIProgressBar), regs, fields, typeof(UIWidgetContainer));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIProgressBar(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIProgressBar class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIProgressBar);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_current(IntPtr L)
	{
		LuaScriptMgr.Push(L, UIProgressBar.current);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_bHideThumbAtEnds(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name bHideThumbAtEnds");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index bHideThumbAtEnds on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.bHideThumbAtEnds);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDragFinished(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDragFinished");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDragFinished on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onDragFinished);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_bHideFgAtEnds(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name bHideFgAtEnds");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index bHideFgAtEnds on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.bHideFgAtEnds);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_UseFillDir(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name UseFillDir");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index UseFillDir on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.UseFillDir);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_thumb(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name thumb");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index thumb on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.thumb);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mBG(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mBG");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mBG on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mBG);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mFG(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mFG");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mFG on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mFG);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mDG(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mDG");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mDG on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mDG);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_numberOfSteps(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name numberOfSteps");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index numberOfSteps on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.numberOfSteps);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onChange(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

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
	static int get_cachedTransform(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cachedTransform");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cachedTransform on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.cachedTransform);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cachedCamera(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cachedCamera");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cachedCamera on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.cachedCamera);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_foregroundWidget(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name foregroundWidget");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index foregroundWidget on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.foregroundWidget);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_backgroundWidget(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name backgroundWidget");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index backgroundWidget on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.backgroundWidget);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fillDirection(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fillDirection");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fillDirection on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.fillDirection);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_value(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

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
	static int get_alpha(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name alpha");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index alpha on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.alpha);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_current(IntPtr L)
	{
		UIProgressBar.current = (UIProgressBar)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIProgressBar));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_bHideThumbAtEnds(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name bHideThumbAtEnds");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index bHideThumbAtEnds on a nil value");
			}
		}

		obj.bHideThumbAtEnds = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDragFinished(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDragFinished");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDragFinished on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onDragFinished = (UIProgressBar.OnDragFinished)LuaScriptMgr.GetNetObject(L, 3, typeof(UIProgressBar.OnDragFinished));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onDragFinished = () =>
			{
				func.Call();
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_bHideFgAtEnds(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name bHideFgAtEnds");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index bHideFgAtEnds on a nil value");
			}
		}

		obj.bHideFgAtEnds = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_UseFillDir(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name UseFillDir");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index UseFillDir on a nil value");
			}
		}

		obj.UseFillDir = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_thumb(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name thumb");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index thumb on a nil value");
			}
		}

		obj.thumb = (Transform)LuaScriptMgr.GetUnityObject(L, 3, typeof(Transform));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mBG(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mBG");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mBG on a nil value");
			}
		}

		obj.mBG = (UIWidget)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIWidget));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mFG(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mFG");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mFG on a nil value");
			}
		}

		obj.mFG = (UIWidget)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIWidget));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mDG(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mDG");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mDG on a nil value");
			}
		}

		obj.mDG = (UIWidget)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIWidget));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_numberOfSteps(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name numberOfSteps");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index numberOfSteps on a nil value");
			}
		}

		obj.numberOfSteps = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onChange(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

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
	static int set_foregroundWidget(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name foregroundWidget");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index foregroundWidget on a nil value");
			}
		}

		obj.foregroundWidget = (UIWidget)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIWidget));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_backgroundWidget(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name backgroundWidget");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index backgroundWidget on a nil value");
			}
		}

		obj.backgroundWidget = (UIWidget)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIWidget));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_fillDirection(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fillDirection");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fillDirection on a nil value");
			}
		}

		obj.fillDirection = (UIProgressBar.FillDirection)LuaScriptMgr.GetNetObject(L, 3, typeof(UIProgressBar.FillDirection));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_value(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

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

		obj.value = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_alpha(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIProgressBar obj = (UIProgressBar)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name alpha");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index alpha on a nil value");
			}
		}

		obj.alpha = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ForceUpdate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIProgressBar obj = (UIProgressBar)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIProgressBar");
		obj.ForceUpdate();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDynamicGround(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		UIProgressBar obj = (UIProgressBar)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIProgressBar");
		float arg0 = (float)LuaScriptMgr.GetNumber(L, 2);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 3);
		obj.SetDynamicGround(arg0,arg1);
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

