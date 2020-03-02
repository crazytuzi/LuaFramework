using System;
using UnityEngine;
using System.Collections.Generic;
using LuaInterface;

public class EventDelegateWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Equals", Equals),
			new LuaMethod("GetHashCode", GetHashCode),
			new LuaMethod("Setz", Setz),
			new LuaMethod("Set", Set),
			new LuaMethod("Execute", Execute),
			new LuaMethod("Clear", Clear),
			new LuaMethod("ToString", ToString),
			new LuaMethod("IsValid", IsValid),
			new LuaMethod("Add", Add),
			new LuaMethod("Remove", Remove),
			new LuaMethod("New", _CreateEventDelegate),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__tostring", Lua_ToString),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("oneShot", get_oneShot, set_oneShot),
			new LuaField("target", get_target, set_target),
			new LuaField("methodName", get_methodName, set_methodName),
			new LuaField("parameters", get_parameters, null),
			new LuaField("isValid", get_isValid, null),
			new LuaField("isEnabled", get_isEnabled, null),
		};

		LuaScriptMgr.RegisterLib(L, "EventDelegate", typeof(EventDelegate), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateEventDelegate(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			EventDelegate obj = new EventDelegate();
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else if (count == 1)
		{
			EventDelegate.Callback arg0 = null;
			LuaTypes funcType1 = LuaDLL.lua_type(L, 1);

			if (funcType1 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (EventDelegate.Callback)LuaScriptMgr.GetNetObject(L, 1, typeof(EventDelegate.Callback));
			}
			else
			{
				LuaFunction func = LuaScriptMgr.GetLuaFunction(L, 1);
				arg0 = () =>
				{
					func.Call();
				};
			}

			EventDelegate obj = new EventDelegate(arg0);
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else if (count == 2)
		{
			MonoBehaviour arg0 = (MonoBehaviour)LuaScriptMgr.GetUnityObject(L, 1, typeof(MonoBehaviour));
			string arg1 = LuaScriptMgr.GetString(L, 2);
			EventDelegate obj = new EventDelegate(arg0,arg1);
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: EventDelegate.New");
		}

		return 0;
	}

	static Type classType = typeof(EventDelegate);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_oneShot(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name oneShot");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index oneShot on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.oneShot);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_target(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name target");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index target on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.target);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_methodName(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name methodName");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index methodName on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.methodName);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_parameters(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name parameters");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index parameters on a nil value");
			}
		}

		LuaScriptMgr.PushArray(L, obj.parameters);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isValid(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isValid");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isValid on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isValid);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isEnabled(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

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
	static int set_oneShot(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name oneShot");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index oneShot on a nil value");
			}
		}

		obj.oneShot = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_target(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name target");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index target on a nil value");
			}
		}

		obj.target = (MonoBehaviour)LuaScriptMgr.GetUnityObject(L, 3, typeof(MonoBehaviour));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_methodName(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		EventDelegate obj = (EventDelegate)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name methodName");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index methodName on a nil value");
			}
		}

		obj.methodName = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Lua_ToString(IntPtr L)
	{
		object obj = LuaScriptMgr.GetLuaObject(L, 1);

		if (obj != null)
		{
			LuaScriptMgr.Push(L, obj.ToString());
		}
		else
		{
			LuaScriptMgr.Push(L, "Table: EventDelegate");
		}

		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Equals(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		EventDelegate obj = LuaScriptMgr.GetVarObject(L, 1) as EventDelegate;
		object arg0 = LuaScriptMgr.GetVarObject(L, 2);
		bool o = obj != null ? obj.Equals(arg0) : arg0 == null;
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetHashCode(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		EventDelegate obj = (EventDelegate)LuaScriptMgr.GetNetObjectSelf(L, 1, "EventDelegate");
		int o = obj.GetHashCode();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Setz(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		EventDelegate obj = (EventDelegate)LuaScriptMgr.GetNetObjectSelf(L, 1, "EventDelegate");
		EventDelegate.Callback arg0 = null;
		LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

		if (funcType2 != LuaTypes.LUA_TFUNCTION)
		{
			 arg0 = (EventDelegate.Callback)LuaScriptMgr.GetNetObject(L, 2, typeof(EventDelegate.Callback));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.GetLuaFunction(L, 2);
			arg0 = () =>
			{
				func.Call();
			};
		}

		obj.Setz(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Set(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>), typeof(EventDelegate)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate arg1 = (EventDelegate)LuaScriptMgr.GetLuaObject(L, 2);
			EventDelegate.Set(arg0,arg1);
			return 0;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>), typeof(EventDelegate.Callback)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate.Callback arg1 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (EventDelegate.Callback)LuaScriptMgr.GetLuaObject(L, 2);
			}
			else
			{
				LuaFunction func = LuaScriptMgr.GetLuaFunction(L, 2);
				arg1 = () =>
				{
					func.Call();
				};
			}

			EventDelegate.Set(arg0,arg1);
			return 0;
		}
		else if (count == 3)
		{
			EventDelegate obj = (EventDelegate)LuaScriptMgr.GetNetObjectSelf(L, 1, "EventDelegate");
			MonoBehaviour arg0 = (MonoBehaviour)LuaScriptMgr.GetUnityObject(L, 2, typeof(MonoBehaviour));
			string arg1 = LuaScriptMgr.GetLuaString(L, 3);
			obj.Set(arg0,arg1);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: EventDelegate.Set");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Execute(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate.Execute(arg0);
			return 0;
		}
		else if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(EventDelegate)))
		{
			EventDelegate obj = (EventDelegate)LuaScriptMgr.GetNetObjectSelf(L, 1, "EventDelegate");
			bool o = obj.Execute();
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: EventDelegate.Execute");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clear(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		EventDelegate obj = (EventDelegate)LuaScriptMgr.GetNetObjectSelf(L, 1, "EventDelegate");
		obj.Clear();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ToString(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		EventDelegate obj = (EventDelegate)LuaScriptMgr.GetNetObjectSelf(L, 1, "EventDelegate");
		string o = obj.ToString();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsValid(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetNetObject(L, 1, typeof(List<EventDelegate>));
		bool o = EventDelegate.IsValid(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Add(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>), typeof(EventDelegate)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate arg1 = (EventDelegate)LuaScriptMgr.GetLuaObject(L, 2);
			EventDelegate.Add(arg0,arg1);
			return 0;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>), typeof(EventDelegate.Callback)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate.Callback arg1 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (EventDelegate.Callback)LuaScriptMgr.GetLuaObject(L, 2);
			}
			else
			{
				LuaFunction func = LuaScriptMgr.GetLuaFunction(L, 2);
				arg1 = () =>
				{
					func.Call();
				};
			}

			EventDelegate.Add(arg0,arg1);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>), typeof(EventDelegate), typeof(bool)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate arg1 = (EventDelegate)LuaScriptMgr.GetLuaObject(L, 2);
			bool arg2 = LuaDLL.lua_toboolean(L, 3);
			EventDelegate.Add(arg0,arg1,arg2);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>), typeof(EventDelegate.Callback), typeof(bool)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate.Callback arg1 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (EventDelegate.Callback)LuaScriptMgr.GetLuaObject(L, 2);
			}
			else
			{
				LuaFunction func = LuaScriptMgr.GetLuaFunction(L, 2);
				arg1 = () =>
				{
					func.Call();
				};
			}

			bool arg2 = LuaDLL.lua_toboolean(L, 3);
			EventDelegate.Add(arg0,arg1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: EventDelegate.Add");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Remove(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>), typeof(EventDelegate)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate arg1 = (EventDelegate)LuaScriptMgr.GetLuaObject(L, 2);
			bool o = EventDelegate.Remove(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(List<EventDelegate>), typeof(EventDelegate.Callback)))
		{
			List<EventDelegate> arg0 = (List<EventDelegate>)LuaScriptMgr.GetLuaObject(L, 1);
			EventDelegate.Callback arg1 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (EventDelegate.Callback)LuaScriptMgr.GetLuaObject(L, 2);
			}
			else
			{
				LuaFunction func = LuaScriptMgr.GetLuaFunction(L, 2);
				arg1 = () =>
				{
					func.Call();
				};
			}

			bool o = EventDelegate.Remove(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: EventDelegate.Remove");
		}

		return 0;
	}
}

