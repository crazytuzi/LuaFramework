using System;
using LuaInterface;

public class PrivateExtensionsWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("CallPrivateMethod", CallPrivateMethod),
			new LuaMethod("CallStaticPrivateMethod", CallStaticPrivateMethod),
			new LuaMethod("GetPrivateField", GetPrivateField),
			new LuaMethod("GetStaticPrivateField", GetStaticPrivateField),
			new LuaMethod("GetPrivateProperty", GetPrivateProperty),
			new LuaMethod("GetStaticPrivateProperty", GetStaticPrivateProperty),
			new LuaMethod("SetPrivateField", SetPrivateField),
			new LuaMethod("SetStaticPrivateField", SetStaticPrivateField),
			new LuaMethod("SetPrivateProperty", SetPrivateProperty),
			new LuaMethod("SetStaticPrivateProperty", SetStaticPrivateProperty),
			new LuaMethod("New", _CreatePrivateExtensions),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaScriptMgr.RegisterLib(L, "PrivateExtensions", regs);
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreatePrivateExtensions(IntPtr L)
	{
		LuaDLL.luaL_error(L, "PrivateExtensions class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(PrivateExtensions);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallPrivateMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object[] objs2 = LuaScriptMgr.GetParamsObject(L, 3, count - 2);
		object o = PrivateExtensions.CallPrivateMethod(arg0,arg1,objs2);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallStaticPrivateMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object[] objs2 = LuaScriptMgr.GetParamsObject(L, 3, count - 2);
		object o = PrivateExtensions.CallStaticPrivateMethod(arg0,arg1,objs2);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPrivateField(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = PrivateExtensions.GetPrivateField(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetStaticPrivateField(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = PrivateExtensions.GetStaticPrivateField(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPrivateProperty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = PrivateExtensions.GetPrivateProperty(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetStaticPrivateProperty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = PrivateExtensions.GetStaticPrivateProperty(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPrivateField(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		PrivateExtensions.SetPrivateField(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetStaticPrivateField(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		PrivateExtensions.SetStaticPrivateField(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPrivateProperty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		PrivateExtensions.SetPrivateProperty(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetStaticPrivateProperty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		PrivateExtensions.SetStaticPrivateProperty(arg0,arg1,arg2);
		return 0;
	}
}

