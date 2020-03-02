using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIEventListenerWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Get", Get),
			new LuaMethod("New", _CreateUIEventListener),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("parameter", get_parameter, set_parameter),
			new LuaField("onSubmit", get_onSubmit, set_onSubmit),
			new LuaField("onClick", get_onClick, set_onClick),
			new LuaField("onDoubleClick", get_onDoubleClick, set_onDoubleClick),
			new LuaField("onLongPress", get_onLongPress, set_onLongPress),
			new LuaField("onHover", get_onHover, set_onHover),
			new LuaField("onPress", get_onPress, set_onPress),
			new LuaField("onSelect", get_onSelect, set_onSelect),
			new LuaField("onScroll", get_onScroll, set_onScroll),
			new LuaField("onDrag", get_onDrag, set_onDrag),
			new LuaField("onDrop", get_onDrop, set_onDrop),
			new LuaField("onKey", get_onKey, set_onKey),
		};

		LuaScriptMgr.RegisterLib(L, "UIEventListener", typeof(UIEventListener), regs, fields, typeof(MonoBehaviour));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIEventListener(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIEventListener class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIEventListener);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_parameter(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name parameter");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index parameter on a nil value");
			}
		}

		LuaScriptMgr.PushVarObject(L, obj.parameter);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onSubmit(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onSubmit");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onSubmit on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onSubmit);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onClick(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

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

		LuaScriptMgr.Push(L, obj.onClick);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDoubleClick(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDoubleClick");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDoubleClick on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onDoubleClick);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onLongPress(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onLongPress");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onLongPress on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onLongPress);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onHover(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onHover");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onHover on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onHover);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onPress(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onPress");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onPress on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onPress);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onSelect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onSelect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onSelect on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onSelect);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onScroll(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onScroll");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onScroll on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onScroll);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDrag(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDrag");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDrag on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onDrag);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDrop(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDrop");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDrop on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onDrop);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onKey(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onKey");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onKey on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onKey);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_parameter(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name parameter");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index parameter on a nil value");
			}
		}

		obj.parameter = LuaScriptMgr.GetVarObject(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onSubmit(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onSubmit");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onSubmit on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onSubmit = (UIEventListener.VoidDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.VoidDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onSubmit = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onClick(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

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

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onClick = (UIEventListener.VoidDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.VoidDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onClick = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDoubleClick(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDoubleClick");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDoubleClick on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onDoubleClick = (UIEventListener.VoidDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.VoidDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onDoubleClick = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onLongPress(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onLongPress");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onLongPress on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onLongPress = (UIEventListener.VoidDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.VoidDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onLongPress = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onHover(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onHover");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onHover on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onHover = (UIEventListener.BoolDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.BoolDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onHover = (param0, param1) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				LuaScriptMgr.Push(L, param1);
				func.PCall(top, 2);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onPress(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onPress");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onPress on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onPress = (UIEventListener.BoolDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.BoolDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onPress = (param0, param1) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				LuaScriptMgr.Push(L, param1);
				func.PCall(top, 2);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onSelect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onSelect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onSelect on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onSelect = (UIEventListener.BoolDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.BoolDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onSelect = (param0, param1) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				LuaScriptMgr.Push(L, param1);
				func.PCall(top, 2);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onScroll(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onScroll");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onScroll on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onScroll = (UIEventListener.FloatDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.FloatDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onScroll = (param0, param1) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				LuaScriptMgr.Push(L, param1);
				func.PCall(top, 2);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDrag(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDrag");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDrag on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onDrag = (UIEventListener.VectorDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.VectorDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onDrag = (param0, param1) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				LuaScriptMgr.Push(L, param1);
				func.PCall(top, 2);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDrop(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDrop");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDrop on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onDrop = (UIEventListener.ObjectDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.ObjectDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onDrop = (param0, param1) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				LuaScriptMgr.Push(L, param1);
				func.PCall(top, 2);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onKey(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIEventListener obj = (UIEventListener)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onKey");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onKey on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onKey = (UIEventListener.KeyCodeDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIEventListener.KeyCodeDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onKey = (param0, param1) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				LuaScriptMgr.Push(L, param1);
				func.PCall(top, 2);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Get(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		UIEventListener o = UIEventListener.Get(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
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

