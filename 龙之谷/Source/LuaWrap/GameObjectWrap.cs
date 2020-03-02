using System;
using UnityEngine;
using System.Collections.Generic;
using LuaInterface;
using Object = UnityEngine.Object;

public class GameObjectWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("CreatePrimitive", CreatePrimitive),
			new LuaMethod("GetComponent", GetComponent),
			new LuaMethod("GetComponentInChildren", GetComponentInChildren),
			new LuaMethod("GetComponentInParent", GetComponentInParent),
			new LuaMethod("GetComponents", GetComponents),
			new LuaMethod("GetComponentsInChildren", GetComponentsInChildren),
			new LuaMethod("GetComponentsInParent", GetComponentsInParent),
			new LuaMethod("SetActive", SetActive),
			new LuaMethod("CompareTag", CompareTag),
			new LuaMethod("FindGameObjectWithTag", FindGameObjectWithTag),
			new LuaMethod("FindWithTag", FindWithTag),
			new LuaMethod("FindGameObjectsWithTag", FindGameObjectsWithTag),
			new LuaMethod("SendMessageUpwards", SendMessageUpwards),
			new LuaMethod("SendMessage", SendMessage),
			new LuaMethod("BroadcastMessage", BroadcastMessage),
			new LuaMethod("AddComponent", AddComponent),
			new LuaMethod("Find", Find),
			new LuaMethod("New", _CreateGameObject),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("transform", get_transform, null),
			new LuaField("layer", get_layer, set_layer),
			new LuaField("activeSelf", get_activeSelf, null),
			new LuaField("activeInHierarchy", get_activeInHierarchy, null),
			new LuaField("isStatic", get_isStatic, set_isStatic),
			new LuaField("tag", get_tag, set_tag),
			new LuaField("scene", get_scene, null),
			new LuaField("gameObject", get_gameObject, null),
		};

		LuaScriptMgr.RegisterLib(L, "UnityEngine.GameObject", typeof(GameObject), regs, fields, typeof(Object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateGameObject(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			GameObject obj = new GameObject();
			LuaScriptMgr.Push(L, obj);
			return 1;
		}
		else if (count == 1)
		{
			string arg0 = LuaScriptMgr.GetString(L, 1);
			GameObject obj = new GameObject(arg0);
			LuaScriptMgr.Push(L, obj);
			return 1;
		}
		else if (LuaScriptMgr.CheckTypes(L, 1, typeof(string)) && LuaScriptMgr.CheckParamsType(L, typeof(Type), 2, count - 1))
		{
			string arg0 = LuaScriptMgr.GetString(L, 1);
			Type[] objs1 = LuaScriptMgr.GetParamsObject<Type>(L, 2, count - 1);
			GameObject obj = new GameObject(arg0,objs1);
			LuaScriptMgr.Push(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.New");
		}

		return 0;
	}

	static Type classType = typeof(GameObject);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_transform(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name transform");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index transform on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.transform);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_layer(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name layer");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index layer on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.layer);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_activeSelf(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeSelf");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeSelf on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.activeSelf);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_activeInHierarchy(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeInHierarchy");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeInHierarchy on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.activeInHierarchy);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isStatic(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isStatic");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isStatic on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isStatic);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_tag(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name tag");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index tag on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.tag);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_scene(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name scene");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index scene on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.scene);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_gameObject(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name gameObject");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index gameObject on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.gameObject);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_layer(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name layer");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index layer on a nil value");
			}
		}

		obj.layer = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isStatic(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isStatic");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isStatic on a nil value");
			}
		}

		obj.isStatic = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_tag(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		GameObject obj = (GameObject)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name tag");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index tag on a nil value");
			}
		}

		obj.tag = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreatePrimitive(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		PrimitiveType arg0 = (PrimitiveType)LuaScriptMgr.GetNetObject(L, 1, typeof(PrimitiveType));
		GameObject o = GameObject.CreatePrimitive(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetComponent(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(string)))
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetString(L, 2);
			Component o = obj.GetComponent(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(Type)))
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			Component o = obj.GetComponent(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.GetComponent");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetComponentInChildren(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			Component o = obj.GetComponentInChildren(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 3)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			bool arg1 = LuaScriptMgr.GetBoolean(L, 3);
			Component o = obj.GetComponentInChildren(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.GetComponentInChildren");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetComponentInParent(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
		Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
		Component o = obj.GetComponentInParent(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetComponents(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			Component[] o = obj.GetComponents(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 3)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			List<Component> arg1 = (List<Component>)LuaScriptMgr.GetNetObject(L, 3, typeof(List<Component>));
			obj.GetComponents(arg0,arg1);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.GetComponents");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetComponentsInChildren(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			Component[] o = obj.GetComponentsInChildren(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 3)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			bool arg1 = LuaScriptMgr.GetBoolean(L, 3);
			Component[] o = obj.GetComponentsInChildren(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.GetComponentsInChildren");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetComponentsInParent(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			Component[] o = obj.GetComponentsInParent(arg0);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else if (count == 3)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
			bool arg1 = LuaScriptMgr.GetBoolean(L, 3);
			Component[] o = obj.GetComponentsInParent(arg0,arg1);
			LuaScriptMgr.PushArray(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.GetComponentsInParent");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetActive(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
		bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
		obj.SetActive(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CompareTag(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		bool o = obj.CompareTag(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindGameObjectWithTag(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		GameObject o = GameObject.FindGameObjectWithTag(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindWithTag(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		GameObject o = GameObject.FindWithTag(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindGameObjectsWithTag(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		GameObject[] o = GameObject.FindGameObjectsWithTag(arg0);
		LuaScriptMgr.PushArray(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendMessageUpwards(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			obj.SendMessageUpwards(arg0);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(string), typeof(SendMessageOptions)))
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetString(L, 2);
			SendMessageOptions arg1 = (SendMessageOptions)LuaScriptMgr.GetLuaObject(L, 3);
			obj.SendMessageUpwards(arg0,arg1);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(string), typeof(object)))
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetString(L, 2);
			object arg1 = LuaScriptMgr.GetVarObject(L, 3);
			obj.SendMessageUpwards(arg0,arg1);
			return 0;
		}
		else if (count == 4)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			object arg1 = LuaScriptMgr.GetVarObject(L, 3);
			SendMessageOptions arg2 = (SendMessageOptions)LuaScriptMgr.GetNetObject(L, 4, typeof(SendMessageOptions));
			obj.SendMessageUpwards(arg0,arg1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.SendMessageUpwards");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendMessage(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			obj.SendMessage(arg0);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(string), typeof(SendMessageOptions)))
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetString(L, 2);
			SendMessageOptions arg1 = (SendMessageOptions)LuaScriptMgr.GetLuaObject(L, 3);
			obj.SendMessage(arg0,arg1);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(string), typeof(object)))
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetString(L, 2);
			object arg1 = LuaScriptMgr.GetVarObject(L, 3);
			obj.SendMessage(arg0,arg1);
			return 0;
		}
		else if (count == 4)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			object arg1 = LuaScriptMgr.GetVarObject(L, 3);
			SendMessageOptions arg2 = (SendMessageOptions)LuaScriptMgr.GetNetObject(L, 4, typeof(SendMessageOptions));
			obj.SendMessage(arg0,arg1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.SendMessage");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int BroadcastMessage(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			obj.BroadcastMessage(arg0);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(string), typeof(SendMessageOptions)))
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetString(L, 2);
			SendMessageOptions arg1 = (SendMessageOptions)LuaScriptMgr.GetLuaObject(L, 3);
			obj.BroadcastMessage(arg0,arg1);
			return 0;
		}
		else if (count == 3 && LuaScriptMgr.CheckTypes(L, 1, typeof(GameObject), typeof(string), typeof(object)))
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetString(L, 2);
			object arg1 = LuaScriptMgr.GetVarObject(L, 3);
			obj.BroadcastMessage(arg0,arg1);
			return 0;
		}
		else if (count == 4)
		{
			GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
			string arg0 = LuaScriptMgr.GetLuaString(L, 2);
			object arg1 = LuaScriptMgr.GetVarObject(L, 3);
			SendMessageOptions arg2 = (SendMessageOptions)LuaScriptMgr.GetNetObject(L, 4, typeof(SendMessageOptions));
			obj.BroadcastMessage(arg0,arg1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: GameObject.BroadcastMessage");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddComponent(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject obj = (GameObject)LuaScriptMgr.GetUnityObjectSelf(L, 1, "GameObject");
		Type arg0 = LuaScriptMgr.GetTypeObject(L, 2);
		Component o = obj.AddComponent(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Find(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		GameObject o = GameObject.Find(arg0);
		LuaScriptMgr.Push(L, o);
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

