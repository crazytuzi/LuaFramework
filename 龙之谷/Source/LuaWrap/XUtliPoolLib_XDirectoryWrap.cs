using System;
using LuaInterface;

public class XUtliPoolLib_XDirectoryWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("CreateDirectory", CreateDirectory),
			new LuaMethod("Delete", Delete),
			new LuaMethod("Exists", Exists),
			new LuaMethod("GetCreationTime", GetCreationTime),
			new LuaMethod("GetCurrentDirectory", GetCurrentDirectory),
			new LuaMethod("GetDirectories", GetDirectories),
			new LuaMethod("GetDirectoryRoot", GetDirectoryRoot),
			new LuaMethod("GetFiles", GetFiles),
			new LuaMethod("GetFileSystemEntries", GetFileSystemEntries),
			new LuaMethod("GetParent", GetParent),
			new LuaMethod("Move", Move),
			new LuaMethod("New", _CreateXUtliPoolLib_XDirectory),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
		};

		LuaScriptMgr.RegisterLib(L, "XUtliPoolLib.XDirectory", typeof(XUtliPoolLib.XDirectory), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateXUtliPoolLib_XDirectory(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			XUtliPoolLib.XDirectory obj = new XUtliPoolLib.XDirectory();
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XDirectory.New");
		}

		return 0;
	}

	static Type classType = typeof(XUtliPoolLib.XDirectory);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateDirectory(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.DirectoryInfo o = XUtliPoolLib.XDirectory.CreateDirectory(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Delete(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		XUtliPoolLib.XDirectory.Delete(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Exists(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		bool o = XUtliPoolLib.XDirectory.Exists(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCreationTime(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		DateTime o = XUtliPoolLib.XDirectory.GetCreationTime(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCurrentDirectory(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		string o = XUtliPoolLib.XDirectory.GetCurrentDirectory();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDirectories(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string[] o = XUtliPoolLib.XDirectory.GetDirectories(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			string[] o = XUtliPoolLib.XDirectory.GetDirectories(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 3)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			System.IO.SearchOption arg2 = (System.IO.SearchOption)LuaScriptMgr.GetNetObject(L, 3, typeof(System.IO.SearchOption));
			string[] o = XUtliPoolLib.XDirectory.GetDirectories(arg0,arg1,arg2);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XDirectory.GetDirectories");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDirectoryRoot(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string o = XUtliPoolLib.XDirectory.GetDirectoryRoot(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFiles(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string[] o = XUtliPoolLib.XDirectory.GetFiles(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			string[] o = XUtliPoolLib.XDirectory.GetFiles(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XDirectory.GetFiles");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFileSystemEntries(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string[] o = XUtliPoolLib.XDirectory.GetFileSystemEntries(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			string[] o = XUtliPoolLib.XDirectory.GetFileSystemEntries(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XDirectory.GetFileSystemEntries");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetParent(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.DirectoryInfo o = XUtliPoolLib.XDirectory.GetParent(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Move(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		XUtliPoolLib.XDirectory.Move(arg0,arg1);
		return 0;
	}
}

