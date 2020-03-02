using System;
using System.Collections.Generic;
using LuaInterface;

public class PublicExtensionsWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("CastNumberParameters", CastNumberParameters),
			new LuaMethod("CallPublicMethod", CallPublicMethod),
			new LuaMethod("CallStaticPublicMethod", CallStaticPublicMethod),
			new LuaMethod("GetPublicField", GetPublicField),
			new LuaMethod("GetStaticPublicField", GetStaticPublicField),
			new LuaMethod("GetFieldInfo", GetFieldInfo),
			new LuaMethod("GetPublicProperty", GetPublicProperty),
			new LuaMethod("GetStaticPublicProperty", GetStaticPublicProperty),
			new LuaMethod("GetPropertyInfo", GetPropertyInfo),
			new LuaMethod("SetPublicField", SetPublicField),
			new LuaMethod("SetStaticPublicField", SetStaticPublicField),
			new LuaMethod("SetPublicProperty", SetPublicProperty),
			new LuaMethod("SetStaticPublicProperty", SetStaticPublicProperty),
			new LuaMethod("New", _CreatePublicExtensions),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaScriptMgr.RegisterLib(L, "PublicExtensions", regs);
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreatePublicExtensions(IntPtr L)
	{
		LuaDLL.luaL_error(L, "PublicExtensions class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(PublicExtensions);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CastNumberParameters(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		object[] objs0 = LuaScriptMgr.GetArrayObject<object>(L, 1);
		Type[] objs1 = LuaScriptMgr.GetArrayObject<Type>(L, 2);
		List<Type[]> o = PublicExtensions.CastNumberParameters(objs0,objs1);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallPublicMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object[] objs2 = LuaScriptMgr.GetParamsObject(L, 3, count - 2);
		object o = PublicExtensions.CallPublicMethod(arg0,arg1,objs2);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallStaticPublicMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object[] objs2 = LuaScriptMgr.GetParamsObject(L, 3, count - 2);
		object o = PublicExtensions.CallStaticPublicMethod(arg0,arg1,objs2);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPublicField(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = PublicExtensions.GetPublicField(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetStaticPublicField(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = PublicExtensions.GetStaticPublicField(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFieldInfo(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		Type arg0 = LuaScriptMgr.GetTypeObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		System.Reflection.BindingFlags arg2 = (System.Reflection.BindingFlags)LuaScriptMgr.GetNetObject(L, 3, typeof(System.Reflection.BindingFlags));
		System.Reflection.FieldInfo o = PublicExtensions.GetFieldInfo(arg0,arg1,arg2);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPublicProperty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = PublicExtensions.GetPublicProperty(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetStaticPublicProperty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = PublicExtensions.GetStaticPublicProperty(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPropertyInfo(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		Type arg0 = LuaScriptMgr.GetTypeObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		System.Reflection.BindingFlags arg2 = (System.Reflection.BindingFlags)LuaScriptMgr.GetNetObject(L, 3, typeof(System.Reflection.BindingFlags));
		System.Reflection.PropertyInfo o = PublicExtensions.GetPropertyInfo(arg0,arg1,arg2);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPublicField(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		PublicExtensions.SetPublicField(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetStaticPublicField(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		PublicExtensions.SetStaticPublicField(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPublicProperty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		PublicExtensions.SetPublicProperty(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetStaticPublicProperty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		PublicExtensions.SetStaticPublicProperty(arg0,arg1,arg2);
		return 0;
	}
}

