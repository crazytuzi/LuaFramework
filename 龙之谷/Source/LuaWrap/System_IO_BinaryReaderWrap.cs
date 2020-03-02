using System;
using LuaInterface;

public class System_IO_BinaryReaderWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Close", Close),
			new LuaMethod("PeekChar", PeekChar),
			new LuaMethod("Read", Read),
			new LuaMethod("ReadBoolean", ReadBoolean),
			new LuaMethod("ReadByte", ReadByte),
			new LuaMethod("ReadBytes", ReadBytes),
			new LuaMethod("ReadChar", ReadChar),
			new LuaMethod("ReadChars", ReadChars),
			new LuaMethod("ReadDecimal", ReadDecimal),
			new LuaMethod("ReadDouble", ReadDouble),
			new LuaMethod("ReadInt16", ReadInt16),
			new LuaMethod("ReadInt32", ReadInt32),
			new LuaMethod("ReadInt64", ReadInt64),
			new LuaMethod("ReadSByte", ReadSByte),
			new LuaMethod("ReadString", ReadString),
			new LuaMethod("ReadSingle", ReadSingle),
			new LuaMethod("ReadUInt16", ReadUInt16),
			new LuaMethod("ReadUInt32", ReadUInt32),
			new LuaMethod("ReadUInt64", ReadUInt64),
			new LuaMethod("New", _CreateSystem_IO_BinaryReader),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("BaseStream", get_BaseStream, null),
		};

		LuaScriptMgr.RegisterLib(L, "System.IO.BinaryReader", typeof(System.IO.BinaryReader), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateSystem_IO_BinaryReader(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			System.IO.Stream arg0 = (System.IO.Stream)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.Stream));
			System.IO.BinaryReader obj = new System.IO.BinaryReader(arg0);
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else if (count == 2)
		{
			System.IO.Stream arg0 = (System.IO.Stream)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.Stream));
			System.Text.Encoding arg1 = (System.Text.Encoding)LuaScriptMgr.GetNetObject(L, 2, typeof(System.Text.Encoding));
			System.IO.BinaryReader obj = new System.IO.BinaryReader(arg0,arg1);
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: System.IO.BinaryReader.New");
		}

		return 0;
	}

	static Type classType = typeof(System.IO.BinaryReader);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_BaseStream(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name BaseStream");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index BaseStream on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.BaseStream);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Close(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		obj.Close();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PeekChar(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		int o = obj.PeekChar();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Read(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
			int o = obj.Read();
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 4 && LuaScriptMgr.CheckTypes(L, 1, typeof(System.IO.BinaryReader), typeof(char[]), typeof(int), typeof(int)))
		{
			System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
			char[] objs0 = LuaScriptMgr.GetArrayNumber<char>(L, 2);
			int arg1 = (int)LuaDLL.lua_tonumber(L, 3);
			int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
			int o = obj.Read(objs0,arg1,arg2);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 4 && LuaScriptMgr.CheckTypes(L, 1, typeof(System.IO.BinaryReader), typeof(byte[]), typeof(int), typeof(int)))
		{
			System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
			byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
			int arg1 = (int)LuaDLL.lua_tonumber(L, 3);
			int arg2 = (int)LuaDLL.lua_tonumber(L, 4);
			int o = obj.Read(objs0,arg1,arg2);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: System.IO.BinaryReader.Read");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadBoolean(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		bool o = obj.ReadBoolean();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadByte(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		byte o = obj.ReadByte();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadBytes(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 2);
		byte[] o = obj.ReadBytes(arg0);
		LuaScriptMgr.PushArray(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadChar(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		char o = obj.ReadChar();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadChars(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 2);
		char[] o = obj.ReadChars(arg0);
		LuaScriptMgr.PushArray(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadDecimal(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		decimal o = obj.ReadDecimal();
		LuaScriptMgr.PushValue(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadDouble(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		double o = obj.ReadDouble();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadInt16(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		short o = obj.ReadInt16();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadInt32(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		int o = obj.ReadInt32();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadInt64(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		long o = obj.ReadInt64();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadSByte(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		sbyte o = obj.ReadSByte();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadString(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		string o = obj.ReadString();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadSingle(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		float o = obj.ReadSingle();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadUInt16(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		ushort o = obj.ReadUInt16();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadUInt32(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		uint o = obj.ReadUInt32();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadUInt64(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader obj = (System.IO.BinaryReader)LuaScriptMgr.GetNetObjectSelf(L, 1, "System.IO.BinaryReader");
		ulong o = obj.ReadUInt64();
		LuaScriptMgr.Push(L, o);
		return 1;
	}
}

