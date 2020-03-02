using System;
using LuaInterface;

public class XUtliPoolLib_XFileWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("AppendAllText", AppendAllText),
			new LuaMethod("AppendText", AppendText),
			new LuaMethod("Copy", Copy),
			new LuaMethod("Create", Create),
			new LuaMethod("CreateText", CreateText),
			new LuaMethod("Decrypt", Decrypt),
			new LuaMethod("Delete", Delete),
			new LuaMethod("Encrypt", Encrypt),
			new LuaMethod("Exists", Exists),
			new LuaMethod("GetAttributes", GetAttributes),
			new LuaMethod("GetCreationTime", GetCreationTime),
			new LuaMethod("GetCreationTimeUtc", GetCreationTimeUtc),
			new LuaMethod("GetLastAccessTime", GetLastAccessTime),
			new LuaMethod("GetLastWriteTime", GetLastWriteTime),
			new LuaMethod("GetLastWriteTimeUtc", GetLastWriteTimeUtc),
			new LuaMethod("Move", Move),
			new LuaMethod("Open", Open),
			new LuaMethod("OpenRead", OpenRead),
			new LuaMethod("OpenText", OpenText),
			new LuaMethod("OpenWrite", OpenWrite),
			new LuaMethod("ReadAllBytes", ReadAllBytes),
			new LuaMethod("ReadAllLines", ReadAllLines),
			new LuaMethod("ReadAllText", ReadAllText),
			new LuaMethod("Replace", Replace),
			new LuaMethod("WriteAllBytes", WriteAllBytes),
			new LuaMethod("WriteAllLines", WriteAllLines),
			new LuaMethod("WriteAllText", WriteAllText),
			new LuaMethod("New", _CreateXUtliPoolLib_XFile),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
		};

		LuaScriptMgr.RegisterLib(L, "XUtliPoolLib.XFile", typeof(XUtliPoolLib.XFile), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateXUtliPoolLib_XFile(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			XUtliPoolLib.XFile obj = new XUtliPoolLib.XFile();
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XFile.New");
		}

		return 0;
	}

	static Type classType = typeof(XUtliPoolLib.XFile);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AppendAllText(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			XUtliPoolLib.XFile.AppendAllText(arg0,arg1);
			return 0;
		}
		else if (count == 3)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			System.Text.Encoding arg2 = (System.Text.Encoding)LuaScriptMgr.GetNetObject(L, 3, typeof(System.Text.Encoding));
			XUtliPoolLib.XFile.AppendAllText(arg0,arg1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XFile.AppendAllText");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AppendText(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.StreamWriter o = XUtliPoolLib.XFile.AppendText(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Copy(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			XUtliPoolLib.XFile.Copy(arg0,arg1);
			return 0;
		}
		else if (count == 3)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
			XUtliPoolLib.XFile.Copy(arg0,arg1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XFile.Copy");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Create(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			System.IO.FileStream o = XUtliPoolLib.XFile.Create(arg0);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			System.IO.FileStream o = XUtliPoolLib.XFile.Create(arg0,arg1);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XFile.Create");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateText(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.StreamWriter o = XUtliPoolLib.XFile.CreateText(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Decrypt(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		XUtliPoolLib.XFile.Decrypt(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Delete(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		XUtliPoolLib.XFile.Delete(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Encrypt(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		XUtliPoolLib.XFile.Encrypt(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Exists(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		bool o = XUtliPoolLib.XFile.Exists(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetAttributes(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.FileAttributes o = XUtliPoolLib.XFile.GetAttributes(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCreationTime(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		DateTime o = XUtliPoolLib.XFile.GetCreationTime(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCreationTimeUtc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		DateTime o = XUtliPoolLib.XFile.GetCreationTimeUtc(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLastAccessTime(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		DateTime o = XUtliPoolLib.XFile.GetLastAccessTime(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLastWriteTime(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		DateTime o = XUtliPoolLib.XFile.GetLastWriteTime(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLastWriteTimeUtc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		DateTime o = XUtliPoolLib.XFile.GetLastWriteTimeUtc(arg0);
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Move(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		XUtliPoolLib.XFile.Move(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Open(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.FileMode arg1 = (System.IO.FileMode)LuaScriptMgr.GetNetObject(L, 2, typeof(System.IO.FileMode));
		System.IO.FileStream o = XUtliPoolLib.XFile.Open(arg0,arg1);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenRead(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.FileStream o = XUtliPoolLib.XFile.OpenRead(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenText(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.StreamReader o = XUtliPoolLib.XFile.OpenText(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenWrite(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.FileStream o = XUtliPoolLib.XFile.OpenWrite(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadAllBytes(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		byte[] o = XUtliPoolLib.XFile.ReadAllBytes(arg0);
		LuaScriptMgr.PushArray(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadAllLines(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string[] o = XUtliPoolLib.XFile.ReadAllLines(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			System.Text.Encoding arg1 = (System.Text.Encoding)LuaScriptMgr.GetNetObject(L, 2, typeof(System.Text.Encoding));
			string[] o = XUtliPoolLib.XFile.ReadAllLines(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XFile.ReadAllLines");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadAllText(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string o = XUtliPoolLib.XFile.ReadAllText(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			System.Text.Encoding arg1 = (System.Text.Encoding)LuaScriptMgr.GetNetObject(L, 2, typeof(System.Text.Encoding));
			string o = XUtliPoolLib.XFile.ReadAllText(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XFile.ReadAllText");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Replace(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		string arg2 = LuaScriptMgr.GetLuaString(L, 3);
		XUtliPoolLib.XFile.Replace(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteAllBytes(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
		XUtliPoolLib.XFile.WriteAllBytes(arg0,objs1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteAllLines(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string[] objs1 = LuaScriptMgr.GetArrayString(L, 2);
			XUtliPoolLib.XFile.WriteAllLines(arg0,objs1);
			return 0;
		}
		else if (count == 3)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string[] objs1 = LuaScriptMgr.GetArrayString(L, 2);
			System.Text.Encoding arg2 = (System.Text.Encoding)LuaScriptMgr.GetNetObject(L, 3, typeof(System.Text.Encoding));
			XUtliPoolLib.XFile.WriteAllLines(arg0,objs1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XFile.WriteAllLines");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteAllText(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			XUtliPoolLib.XFile.WriteAllText(arg0,arg1);
			return 0;
		}
		else if (count == 3)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			System.Text.Encoding arg2 = (System.Text.Encoding)LuaScriptMgr.GetNetObject(L, 3, typeof(System.Text.Encoding));
			XUtliPoolLib.XFile.WriteAllText(arg0,arg1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: XUtliPoolLib.XFile.WriteAllText");
		}

		return 0;
	}
}

