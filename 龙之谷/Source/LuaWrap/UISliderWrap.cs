using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UISliderWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("New", _CreateUISlider),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("eventHandler", get_eventHandler, set_eventHandler),
		};

		LuaScriptMgr.RegisterLib(L, "UISlider", typeof(UISlider), regs, fields, typeof(UIProgressBar));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUISlider(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UISlider class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UISlider);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_eventHandler(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISlider obj = (UISlider)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name eventHandler");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index eventHandler on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.eventHandler);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_eventHandler(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISlider obj = (UISlider)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name eventHandler");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index eventHandler on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.eventHandler = (UILib.SliderValueChangeEventHandler)LuaScriptMgr.GetNetObject(L, 3, typeof(UILib.SliderValueChangeEventHandler));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.eventHandler = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				object[] objs = func.PopValues(top);
				func.EndPCall(top);
				return (bool)objs[0];
			};
		}
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

