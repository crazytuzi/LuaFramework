using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIDummyWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("OnFill", OnFill),
			new LuaMethod("LateUpdate", LateUpdate),
			new LuaMethod("Reset", Reset),
			new LuaMethod("GetPanel", GetPanel),
			new LuaMethod("New", _CreateUIDummy),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("RenderQueue", get_RenderQueue, null),
			new LuaField("RefreshRenderQueue", get_RefreshRenderQueue, set_RefreshRenderQueue),
		};

		LuaScriptMgr.RegisterLib(L, "UIDummy", typeof(UIDummy), regs, fields, typeof(UIWidget));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIDummy(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIDummy class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIDummy);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_RenderQueue(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIDummy obj = (UIDummy)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name RenderQueue");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index RenderQueue on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.RenderQueue);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_RefreshRenderQueue(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIDummy obj = (UIDummy)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name RefreshRenderQueue");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index RefreshRenderQueue on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.RefreshRenderQueue);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_RefreshRenderQueue(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIDummy obj = (UIDummy)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name RefreshRenderQueue");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index RefreshRenderQueue on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.RefreshRenderQueue = (UILib.RefreshRenderQueueCb)LuaScriptMgr.GetNetObject(L, 3, typeof(UILib.RefreshRenderQueueCb));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.RefreshRenderQueue = (param0) =>
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
	static int OnFill(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		UIDummy obj = (UIDummy)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIDummy");
		BetterList<Vector3> arg0 = (BetterList<Vector3>)LuaScriptMgr.GetNetObject(L, 2, typeof(BetterList<Vector3>));
		BetterList<Vector2> arg1 = (BetterList<Vector2>)LuaScriptMgr.GetNetObject(L, 3, typeof(BetterList<Vector2>));
		BetterList<Color32> arg2 = (BetterList<Color32>)LuaScriptMgr.GetNetObject(L, 4, typeof(BetterList<Color32>));
		obj.OnFill(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LateUpdate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIDummy obj = (UIDummy)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIDummy");
		obj.LateUpdate();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Reset(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIDummy obj = (UIDummy)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIDummy");
		obj.Reset();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPanel(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIDummy obj = (UIDummy)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIDummy");
		UILib.IXUIPanel o = obj.GetPanel();
		LuaScriptMgr.PushObject(L, o);
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

