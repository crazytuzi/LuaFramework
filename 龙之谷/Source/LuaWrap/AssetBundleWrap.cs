using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class AssetBundleWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("LoadFromFileAsync", LoadFromFileAsync),
			new LuaMethod("LoadFromFile", LoadFromFile),
			new LuaMethod("LoadFromMemoryAsync", LoadFromMemoryAsync),
			new LuaMethod("LoadFromMemory", LoadFromMemory),
			new LuaMethod("Contains", Contains),
			new LuaMethod("LoadAsset", LoadAsset),
			new LuaMethod("LoadAssetAsync", LoadAssetAsync),
			new LuaMethod("LoadAssetWithSubAssets", LoadAssetWithSubAssets),
			new LuaMethod("LoadAssetWithSubAssetsAsync", LoadAssetWithSubAssetsAsync),
			new LuaMethod("LoadAllAssets", LoadAllAssets),
			new LuaMethod("LoadAllAssetsAsync", LoadAllAssetsAsync),
			new LuaMethod("Unload", Unload),
			new LuaMethod("GetAllAssetNames", GetAllAssetNames),
			new LuaMethod("GetAllScenePaths", GetAllScenePaths),
			new LuaMethod("New", _CreateAssetBundle),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("mainAsset", get_mainAsset, null),
			new LuaField("isStreamedSceneAssetBundle", get_isStreamedSceneAssetBundle, null),
		};

		LuaScriptMgr.RegisterLib(L, "UnityEngine.AssetBundle", typeof(AssetBundle), regs, fields, typeof(Object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateAssetBundle(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			AssetBundle obj = new AssetBundle();
			LuaScriptMgr.Push(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.New");
		}

		return 0;
	}

	static Type classType = typeof(AssetBundle);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mainAsset(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		AssetBundle obj = (AssetBundle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mainAsset");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mainAsset on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mainAsset);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isStreamedSceneAssetBundle(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		AssetBundle obj = (AssetBundle)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isStreamedSceneAssetBundle");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isStreamedSceneAssetBundle on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isStreamedSceneAssetBundle);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadFromFileAsync(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			AssetBundleCreateRequest o = AssetBundle.LoadFromFileAsync(arg0);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			uint arg1 = (uint)LuaScriptMgr.GetNumber(L, 2);
			AssetBundleCreateRequest o = AssetBundle.LoadFromFileAsync(arg0,arg1);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else if (count == 3)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			uint arg1 = (uint)LuaScriptMgr.GetNumber(L, 2);
			ulong arg2 = (ulong)LuaScriptMgr.GetNumber(L, 3);
			AssetBundleCreateRequest o = AssetBundle.LoadFromFileAsync(arg0,arg1,arg2);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadFromFileAsync");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadFromFile(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			AssetBundle o = AssetBundle.LoadFromFile(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			uint arg1 = (uint)LuaScriptMgr.GetNumber(L, 2);
			AssetBundle o = AssetBundle.LoadFromFile(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 3)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			uint arg1 = (uint)LuaScriptMgr.GetNumber(L, 2);
			ulong arg2 = (ulong)LuaScriptMgr.GetNumber(L, 3);
			AssetBundle o = AssetBundle.LoadFromFile(arg0,arg1,arg2);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadFromFile");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadFromMemoryAsync(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 1);
			AssetBundleCreateRequest o = AssetBundle.LoadFromMemoryAsync(objs0);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else if (count == 2)
		{
			byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 1);
			uint arg1 = (uint)LuaScriptMgr.GetNumber(L, 2);
			AssetBundleCreateRequest o = AssetBundle.LoadFromMemoryAsync(objs0,arg1);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadFromMemoryAsync");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadFromMemory(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 1);
			AssetBundle o = AssetBundle.LoadFromMemory(objs0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 1);
			uint arg1 = (uint)LuaScriptMgr.GetNumber(L, 2);
			AssetBundle o = AssetBundle.LoadFromMemory(objs0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadFromMemory");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Contains(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		bool o = obj.Contains(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAsset(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			Object o = obj.LoadAsset(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 3)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			Type arg1 = LuaScriptMgr.GetTypeObject(L, 3);
			Object o = obj.LoadAsset(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadAsset");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAssetAsync(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			AssetBundleRequest o = obj.LoadAssetAsync(arg0);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else if (count == 3)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			Type arg1 = LuaScriptMgr.GetTypeObject(L, 3);
			AssetBundleRequest o = obj.LoadAssetAsync(arg0,arg1);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadAssetAsync");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAssetWithSubAssets(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			Object[] o = obj.LoadAssetWithSubAssets(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 3)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			Type arg1 = LuaScriptMgr.GetTypeObject(L, 3);
			Object[] o = obj.LoadAssetWithSubAssets(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadAssetWithSubAssets");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAssetWithSubAssetsAsync(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			AssetBundleRequest o = obj.LoadAssetWithSubAssetsAsync(arg0);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else if (count == 3)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			Type arg1 = LuaScriptMgr.GetTypeObject(L, 3);
			AssetBundleRequest o = obj.LoadAssetWithSubAssetsAsync(arg0,arg1);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadAssetWithSubAssetsAsync");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAllAssets(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			Object[] o = obj.LoadAllAssets();
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			Object[] o = obj.LoadAllAssets(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadAllAssets");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAllAssetsAsync(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			AssetBundleRequest o = obj.LoadAllAssetsAsync();
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else if (count == 2)
		{
			AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			AssetBundleRequest o = obj.LoadAllAssetsAsync(arg0);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: AssetBundle.LoadAllAssetsAsync");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Unload(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
		bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
		obj.Unload(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetAllAssetNames(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
		string[] o = obj.GetAllAssetNames();
		LuaScriptMgr.PushArray(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetAllScenePaths(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		AssetBundle obj = (AssetBundle)LuaScriptMgr.GetUnityObjectSelf(L, 1, "AssetBundle");
		string[] o = obj.GetAllScenePaths();
		LuaScriptMgr.PushArray(L, o);
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

