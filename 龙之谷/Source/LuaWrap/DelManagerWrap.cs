using System;
using LuaInterface;

public class DelManagerWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Clear", Clear),
			new LuaMethod("New", _CreateDelManager),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("onGoClick", get_onGoClick, set_onGoClick),
			new LuaField("fButtonDelegate", get_fButtonDelegate, set_fButtonDelegate),
			new LuaField("sButtonDelegate", get_sButtonDelegate, set_sButtonDelegate),
			new LuaField("sprClickEventHandler", get_sprClickEventHandler, set_sprClickEventHandler),
		};

		LuaScriptMgr.RegisterLib(L, "DelManager", typeof(DelManager), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateDelManager(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			DelManager obj = new DelManager();
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: DelManager.New");
		}

		return 0;
	}

	static Type classType = typeof(DelManager);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onGoClick(IntPtr L)
	{
		LuaScriptMgr.Push(L, DelManager.onGoClick);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fButtonDelegate(IntPtr L)
	{
		LuaScriptMgr.Push(L, DelManager.fButtonDelegate);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sButtonDelegate(IntPtr L)
	{
		LuaScriptMgr.Push(L, DelManager.sButtonDelegate);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sprClickEventHandler(IntPtr L)
	{
		LuaScriptMgr.Push(L, DelManager.sprClickEventHandler);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onGoClick(IntPtr L)
	{
		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			DelManager.onGoClick = (DelManager.GameObjDelegate)LuaScriptMgr.GetNetObject(L, 3, typeof(DelManager.GameObjDelegate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			DelManager.onGoClick = (param0) =>
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
	static int set_fButtonDelegate(IntPtr L)
	{
		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			DelManager.fButtonDelegate = (UILib.ButtonClickEventHandler)LuaScriptMgr.GetNetObject(L, 3, typeof(UILib.ButtonClickEventHandler));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			DelManager.fButtonDelegate = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.PushObject(L, param0);
				func.PCall(top, 1);
				object[] objs = func.PopValues(top);
				func.EndPCall(top);
				return (bool)objs[0];
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sButtonDelegate(IntPtr L)
	{
		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			DelManager.sButtonDelegate = (UILib.ButtonClickEventHandler)LuaScriptMgr.GetNetObject(L, 3, typeof(UILib.ButtonClickEventHandler));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			DelManager.sButtonDelegate = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.PushObject(L, param0);
				func.PCall(top, 1);
				object[] objs = func.PopValues(top);
				func.EndPCall(top);
				return (bool)objs[0];
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sprClickEventHandler(IntPtr L)
	{
		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			DelManager.sprClickEventHandler = (UILib.SpriteClickEventHandler)LuaScriptMgr.GetNetObject(L, 3, typeof(UILib.SpriteClickEventHandler));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			DelManager.sprClickEventHandler = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.PushObject(L, param0);
				func.PCall(top, 1);
				func.EndPCall(top);
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clear(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		DelManager.Clear();
		return 0;
	}
}

