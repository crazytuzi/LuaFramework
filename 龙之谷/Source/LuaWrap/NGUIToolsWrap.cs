using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class NGUIToolsWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("PlaySound", PlaySound),
			new LuaMethod("PlayFmod", PlayFmod),
			new LuaMethod("OpenURL", OpenURL),
			new LuaMethod("RandomRange", RandomRange),
			new LuaMethod("GetHierarchy", GetHierarchy),
			new LuaMethod("FindCameraForLayer", FindCameraForLayer),
			new LuaMethod("AddWidgetCollider", AddWidgetCollider),
			new LuaMethod("UpdateWidgetCollider", UpdateWidgetCollider),
			new LuaMethod("GetTypeName", GetTypeName),
			new LuaMethod("RegisterUndo", RegisterUndo),
			new LuaMethod("SetDirty", SetDirty),
			new LuaMethod("AddChild", AddChild),
			new LuaMethod("AttachChild", AttachChild),
			new LuaMethod("CalculateRaycastDepth", CalculateRaycastDepth),
			new LuaMethod("CalculateNextDepth", CalculateNextDepth),
			new LuaMethod("AdjustDepth", AdjustDepth),
			new LuaMethod("BringForward", BringForward),
			new LuaMethod("PushBack", PushBack),
			new LuaMethod("NormalizeDepths", NormalizeDepths),
			new LuaMethod("NormalizeWidgetDepths", NormalizeWidgetDepths),
			new LuaMethod("NormalizePanelDepths", NormalizePanelDepths),
			new LuaMethod("CreateUI", CreateUI),
			new LuaMethod("SetChildLayer", SetChildLayer),
			new LuaMethod("AddSprite", AddSprite),
			new LuaMethod("GetRoot", GetRoot),
			new LuaMethod("Destroy", Destroy),
			new LuaMethod("DestroyImmediate", DestroyImmediate),
			new LuaMethod("Broadcast", Broadcast),
			new LuaMethod("IsChild", IsChild),
			new LuaMethod("SetActive", SetActive),
			new LuaMethod("SetActiveChildren", SetActiveChildren),
			new LuaMethod("GetActive", GetActive),
			new LuaMethod("SetActiveSelf", SetActiveSelf),
			new LuaMethod("SetLayer", SetLayer),
			new LuaMethod("Round", Round),
			new LuaMethod("MakePixelPerfect", MakePixelPerfect),
			new LuaMethod("Save", Save),
			new LuaMethod("Load", Load),
			new LuaMethod("ApplyPMA", ApplyPMA),
			new LuaMethod("MarkParentAsChanged", MarkParentAsChanged),
			new LuaMethod("ParentPanelChanged", ParentPanelChanged),
			new LuaMethod("GetSides", GetSides),
			new LuaMethod("GetWorldCorners", GetWorldCorners),
			new LuaMethod("GetFuncName", GetFuncName),
			new LuaMethod("New", _CreateNGUITools),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("mEnableLoadingUpdate", get_mEnableLoadingUpdate, set_mEnableLoadingUpdate),
			new LuaField("soundVolume", get_soundVolume, set_soundVolume),
			new LuaField("fileAccess", get_fileAccess, null),
			new LuaField("clipboard", get_clipboard, set_clipboard),
		};

		LuaScriptMgr.RegisterLib(L, "NGUITools", typeof(NGUITools), regs, fields, null);
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateNGUITools(IntPtr L)
	{
		LuaDLL.luaL_error(L, "NGUITools class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(NGUITools);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mEnableLoadingUpdate(IntPtr L)
	{
		LuaScriptMgr.Push(L, NGUITools.mEnableLoadingUpdate);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_soundVolume(IntPtr L)
	{
		LuaScriptMgr.Push(L, NGUITools.soundVolume);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fileAccess(IntPtr L)
	{
		LuaScriptMgr.Push(L, NGUITools.fileAccess);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_clipboard(IntPtr L)
	{
		LuaScriptMgr.Push(L, NGUITools.clipboard);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mEnableLoadingUpdate(IntPtr L)
	{
		NGUITools.mEnableLoadingUpdate = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_soundVolume(IntPtr L)
	{
		NGUITools.soundVolume = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_clipboard(IntPtr L)
	{
		NGUITools.clipboard = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlaySound(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			AudioClip arg0 = (AudioClip)LuaScriptMgr.GetUnityObject(L, 1, typeof(AudioClip));
			AudioSource o = NGUITools.PlaySound(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			AudioClip arg0 = (AudioClip)LuaScriptMgr.GetUnityObject(L, 1, typeof(AudioClip));
			float arg1 = (float)LuaScriptMgr.GetNumber(L, 2);
			AudioSource o = NGUITools.PlaySound(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 3)
		{
			AudioClip arg0 = (AudioClip)LuaScriptMgr.GetUnityObject(L, 1, typeof(AudioClip));
			float arg1 = (float)LuaScriptMgr.GetNumber(L, 2);
			float arg2 = (float)LuaScriptMgr.GetNumber(L, 3);
			AudioSource o = NGUITools.PlaySound(arg0,arg1,arg2);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.PlaySound");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayFmod(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		NGUITools.PlayFmod(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenURL(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			WWW o = NGUITools.OpenURL(arg0);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			WWWForm arg1 = (WWWForm)LuaScriptMgr.GetNetObject(L, 2, typeof(WWWForm));
			WWW o = NGUITools.OpenURL(arg0,arg1);
			LuaScriptMgr.PushObject(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.OpenURL");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RandomRange(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		int o = NGUITools.RandomRange(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetHierarchy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		string o = NGUITools.GetHierarchy(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindCameraForLayer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		Camera o = NGUITools.FindCameraForLayer(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddWidgetCollider(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			BoxCollider o = NGUITools.AddWidgetCollider(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
			BoxCollider o = NGUITools.AddWidgetCollider(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 3)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			UIWidget arg1 = (UIWidget)LuaScriptMgr.GetUnityObject(L, 2, typeof(UIWidget));
			bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
			BoxCollider o = NGUITools.AddWidgetCollider(arg0,arg1,arg2);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.AddWidgetCollider");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UpdateWidgetCollider(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		UIWidget arg0 = (UIWidget)LuaScriptMgr.GetUnityObject(L, 1, typeof(UIWidget));
		BoxCollider arg1 = (BoxCollider)LuaScriptMgr.GetUnityObject(L, 2, typeof(BoxCollider));
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		NGUITools.UpdateWidgetCollider(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTypeName(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Object arg0 = (Object)LuaScriptMgr.GetUnityObject(L, 1, typeof(Object));
		string o = NGUITools.GetTypeName(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RegisterUndo(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Object arg0 = (Object)LuaScriptMgr.GetUnityObject(L, 1, typeof(Object));
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		NGUITools.RegisterUndo(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDirty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Object arg0 = (Object)LuaScriptMgr.GetUnityObject(L, 1, typeof(Object));
		NGUITools.SetDirty(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddChild(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			GameObject o = NGUITools.AddChild(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(GameObject)))
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetLuaObject(L, 1);
			GameObject arg1 = (GameObject)LuaScriptMgr.GetLuaObject(L, 2);
			GameObject o = NGUITools.AddChild(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(bool)))
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetLuaObject(L, 1);
			bool arg1 = LuaDLL.lua_toboolean(L, 2);
			GameObject o = NGUITools.AddChild(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.AddChild");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AttachChild(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		GameObject arg1 = (GameObject)LuaScriptMgr.GetUnityObject(L, 2, typeof(GameObject));
		NGUITools.AttachChild(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalculateRaycastDepth(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		int o = NGUITools.CalculateRaycastDepth(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalculateNextDepth(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			int o = NGUITools.CalculateNextDepth(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
			int o = NGUITools.CalculateNextDepth(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.CalculateNextDepth");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AdjustDepth(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		int o = NGUITools.AdjustDepth(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int BringForward(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		NGUITools.BringForward(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PushBack(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		NGUITools.PushBack(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int NormalizeDepths(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		NGUITools.NormalizeDepths();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int NormalizeWidgetDepths(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		NGUITools.NormalizeWidgetDepths();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int NormalizePanelDepths(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		NGUITools.NormalizePanelDepths();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateUI(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			bool arg0 = LuaScriptMgr.GetBoolean(L, 1);
			UIPanel o = NGUITools.CreateUI(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			bool arg0 = LuaScriptMgr.GetBoolean(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			UIPanel o = NGUITools.CreateUI(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 3)
		{
			Transform arg0 = (Transform)LuaScriptMgr.GetUnityObject(L, 1, typeof(Transform));
			bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
			int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
			UIPanel o = NGUITools.CreateUI(arg0,arg1,arg2);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.CreateUI");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetChildLayer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Transform arg0 = (Transform)LuaScriptMgr.GetUnityObject(L, 1, typeof(Transform));
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		NGUITools.SetChildLayer(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddSprite(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		UIAtlas arg1 = (UIAtlas)LuaScriptMgr.GetUnityObject(L, 2, typeof(UIAtlas));
		string arg2 = LuaScriptMgr.GetLuaString(L, 3);
		UISprite o = NGUITools.AddSprite(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetRoot(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		GameObject o = NGUITools.GetRoot(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Destroy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Object arg0 = (Object)LuaScriptMgr.GetUnityObject(L, 1, typeof(Object));
		NGUITools.Destroy(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DestroyImmediate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Object arg0 = (Object)LuaScriptMgr.GetUnityObject(L, 1, typeof(Object));
		NGUITools.DestroyImmediate(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Broadcast(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			NGUITools.Broadcast(arg0);
			return 0;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			object arg1 = LuaScriptMgr.GetVarObject(L, 2);
			NGUITools.Broadcast(arg0,arg1);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.Broadcast");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsChild(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Transform arg0 = (Transform)LuaScriptMgr.GetUnityObject(L, 1, typeof(Transform));
		Transform arg1 = (Transform)LuaScriptMgr.GetUnityObject(L, 2, typeof(Transform));
		bool o = NGUITools.IsChild(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetActive(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
			NGUITools.SetActive(arg0,arg1);
			return 0;
		}
		else if (count == 3)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
			bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
			NGUITools.SetActive(arg0,arg1,arg2);
			return 0;
		}
		else if (count == 4)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
			bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
			bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
			NGUITools.SetActive(arg0,arg1,arg2,arg3);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.SetActive");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetActiveChildren(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		NGUITools.SetActiveChildren(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetActive(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject)))
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetLuaObject(L, 1);
			bool o = NGUITools.GetActive(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(Behaviour)))
		{
			Behaviour arg0 = (Behaviour)LuaScriptMgr.GetLuaObject(L, 1);
			bool o = NGUITools.GetActive(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.GetActive");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetActiveSelf(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		NGUITools.SetActiveSelf(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLayer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		NGUITools.SetLayer(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Round(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 1);
		Vector3 o = NGUITools.Round(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MakePixelPerfect(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Transform arg0 = (Transform)LuaScriptMgr.GetUnityObject(L, 1, typeof(Transform));
		NGUITools.MakePixelPerfect(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Save(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
		bool o = NGUITools.Save(arg0,objs1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Load(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		byte[] o = NGUITools.Load(arg0);
		LuaScriptMgr.PushArray(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ApplyPMA(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Color arg0 = LuaScriptMgr.GetColor(L, 1);
		Color o = NGUITools.ApplyPMA(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MarkParentAsChanged(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		NGUITools.MarkParentAsChanged(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ParentPanelChanged(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			UIPanel arg1 = (UIPanel)LuaScriptMgr.GetUnityObject(L, 2, typeof(UIPanel));
			NGUITools.ParentPanelChanged(arg0,arg1);
			return 0;
		}
		else if (count == 3)
		{
			GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
			UIRect arg1 = (UIRect)LuaScriptMgr.GetUnityObject(L, 2, typeof(UIRect));
			UIPanel arg2 = (UIPanel)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIPanel));
			NGUITools.ParentPanelChanged(arg0,arg1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.ParentPanelChanged");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSides(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			Camera arg0 = (Camera)LuaScriptMgr.GetUnityObject(L, 1, typeof(Camera));
			Vector3[] o = NGUITools.GetSides(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(Transform)))
		{
			Camera arg0 = (Camera)LuaScriptMgr.GetLuaObject(L, 1);
			Transform arg1 = (Transform)LuaScriptMgr.GetLuaObject(L, 2);
			Vector3[] o = NGUITools.GetSides(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(float)))
		{
			Camera arg0 = (Camera)LuaScriptMgr.GetLuaObject(L, 1);
			float arg1 = (float)LuaDLL.lua_tonumber(L, 2);
			Vector3[] o = NGUITools.GetSides(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 3)
		{
			Camera arg0 = (Camera)LuaScriptMgr.GetUnityObject(L, 1, typeof(Camera));
			float arg1 = (float)LuaScriptMgr.GetNumber(L, 2);
			Transform arg2 = (Transform)LuaScriptMgr.GetUnityObject(L, 3, typeof(Transform));
			Vector3[] o = NGUITools.GetSides(arg0,arg1,arg2);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.GetSides");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetWorldCorners(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			Camera arg0 = (Camera)LuaScriptMgr.GetUnityObject(L, 1, typeof(Camera));
			Vector3[] o = NGUITools.GetWorldCorners(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(Transform)))
		{
			Camera arg0 = (Camera)LuaScriptMgr.GetLuaObject(L, 1);
			Transform arg1 = (Transform)LuaScriptMgr.GetLuaObject(L, 2);
			Vector3[] o = NGUITools.GetWorldCorners(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(Camera), typeof(float)))
		{
			Camera arg0 = (Camera)LuaScriptMgr.GetLuaObject(L, 1);
			float arg1 = (float)LuaDLL.lua_tonumber(L, 2);
			Vector3[] o = NGUITools.GetWorldCorners(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 3)
		{
			Camera arg0 = (Camera)LuaScriptMgr.GetUnityObject(L, 1, typeof(Camera));
			float arg1 = (float)LuaScriptMgr.GetNumber(L, 2);
			Transform arg2 = (Transform)LuaScriptMgr.GetUnityObject(L, 3, typeof(Transform));
			Vector3[] o = NGUITools.GetWorldCorners(arg0,arg1,arg2);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: NGUITools.GetWorldCorners");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFuncName(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		string o = NGUITools.GetFuncName(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}
}

