using System;
using LuaInterface;

public class LuaStringBufferWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Set", Set),
			new LuaMethod("Copy", Copy),
			new LuaMethod("New", _CreateLuaStringBuffer),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("buffer", get_buffer, set_buffer),
		};

		LuaScriptMgr.RegisterLib(L, "LuaStringBuffer", typeof(LuaStringBuffer), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateLuaStringBuffer(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			LuaStringBuffer obj = new LuaStringBuffer();
			LuaScriptMgr.Push(L, obj);
			return 1;
		}
		else if (count == 1)
		{
			byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 1);
			LuaStringBuffer obj = new LuaStringBuffer(objs0);
			LuaScriptMgr.Push(L, obj);
			return 1;
		}
		else if (count == 2)
		{
			IntPtr arg0 = (IntPtr)LuaScriptMgr.GetNumber(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			LuaStringBuffer obj = new LuaStringBuffer(arg0,arg1);
			LuaScriptMgr.Push(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: LuaStringBuffer.New");
		}

		return 0;
	}

	static Type classType = typeof(LuaStringBuffer);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_buffer(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaStringBuffer obj = (LuaStringBuffer)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name buffer");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index buffer on a nil value");
			}
		}

		LuaScriptMgr.PushArray(L, obj.buffer);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_buffer(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		LuaStringBuffer obj = (LuaStringBuffer)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name buffer");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index buffer on a nil value");
			}
		}

		obj.buffer = LuaScriptMgr.GetArrayNumber<byte>(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Set(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		LuaStringBuffer obj = (LuaStringBuffer)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaStringBuffer");
		byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
		obj.Set(objs0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Copy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		LuaStringBuffer obj = (LuaStringBuffer)LuaScriptMgr.GetNetObjectSelf(L, 1, "LuaStringBuffer");
		byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 3);
		obj.Copy(objs0,arg1);
		return 0;
	}
}

