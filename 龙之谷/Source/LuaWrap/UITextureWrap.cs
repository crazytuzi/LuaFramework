using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UITextureWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Refresh", Refresh),
			new LuaMethod("MakePixelPerfect", MakePixelPerfect),
			new LuaMethod("OnFill", OnFill),
			new LuaMethod("SetTexture", SetTexture),
			new LuaMethod("SetRuntimeTexture", SetRuntimeTexture),
			new LuaMethod("FillMat", FillMat),
			new LuaMethod("GetTextureListType", GetTextureListType),
			new LuaMethod("New", _CreateUITexture),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("mtexType", get_mtexType, set_mtexType),
			new LuaField("mIsRuntimeLoad", get_mIsRuntimeLoad, set_mIsRuntimeLoad),
			new LuaField("texPath", get_texPath, set_texPath),
			new LuaField("shaderName", get_shaderName, set_shaderName),
			new LuaField("mTexture", get_mTexture, set_mTexture),
			new LuaField("mTexture1", get_mTexture1, set_mTexture1),
			new LuaField("sepTexAlpha", get_sepTexAlpha, set_sepTexAlpha),
			new LuaField("colorTex", get_colorTex, set_colorTex),
			new LuaField("sepTexAlphaH2", get_sepTexAlphaH2, set_sepTexAlphaH2),
			new LuaField("colorTexH2", get_colorTexH2, set_colorTexH2),
			new LuaField("sepTexAlphaH4", get_sepTexAlphaH4, set_sepTexAlphaH4),
			new LuaField("colorTexH4", get_colorTexH4, set_colorTexH4),
			new LuaField("horizontally2", get_horizontally2, set_horizontally2),
			new LuaField("horizontally4", get_horizontally4, set_horizontally4),
			new LuaField("vertically2", get_vertically2, set_vertically2),
			new LuaField("vertically4", get_vertically4, set_vertically4),
			new LuaField("normalTex", get_normalTex, set_normalTex),
			new LuaField("mainTexture", get_mainTexture, set_mainTexture),
			new LuaField("alphaTexture", get_alphaTexture, null),
			new LuaField("material", get_material, set_material),
			new LuaField("shader", get_shader, set_shader),
			new LuaField("flip", get_flip, set_flip),
			new LuaField("premultipliedAlpha", get_premultipliedAlpha, null),
			new LuaField("uvRect", get_uvRect, set_uvRect),
			new LuaField("drawingDimensions", get_drawingDimensions, null),
		};

		LuaScriptMgr.RegisterLib(L, "UITexture", typeof(UITexture), regs, fields, typeof(UIWidget));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUITexture(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UITexture class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UITexture);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mtexType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mtexType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mtexType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mtexType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mIsRuntimeLoad(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mIsRuntimeLoad");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mIsRuntimeLoad on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mIsRuntimeLoad);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_texPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name texPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index texPath on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.texPath);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_shaderName(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name shaderName");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index shaderName on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.shaderName);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mTexture");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mTexture on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mTexture);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mTexture1(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mTexture1");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mTexture1 on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mTexture1);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sepTexAlpha(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.sepTexAlpha);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_colorTex(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.colorTex);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sepTexAlphaH2(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.sepTexAlphaH2);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_colorTexH2(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.colorTexH2);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sepTexAlphaH4(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.sepTexAlphaH4);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_colorTexH4(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.colorTexH4);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_horizontally2(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.horizontally2);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_horizontally4(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.horizontally4);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_vertically2(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.vertically2);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_vertically4(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.vertically4);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_normalTex(IntPtr L)
	{
		LuaScriptMgr.Push(L, UITexture.normalTex);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mainTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mainTexture");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mainTexture on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.mainTexture);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_alphaTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name alphaTexture");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index alphaTexture on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.alphaTexture);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_material(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name material");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index material on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.material);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_shader(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name shader");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index shader on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.shader);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_flip(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name flip");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index flip on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.flip);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_premultipliedAlpha(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name premultipliedAlpha");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index premultipliedAlpha on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.premultipliedAlpha);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_uvRect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name uvRect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index uvRect on a nil value");
			}
		}

		LuaScriptMgr.PushValue(L, obj.uvRect);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_drawingDimensions(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name drawingDimensions");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index drawingDimensions on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.drawingDimensions);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mtexType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mtexType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mtexType on a nil value");
			}
		}

		obj.mtexType = (byte)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mIsRuntimeLoad(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mIsRuntimeLoad");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mIsRuntimeLoad on a nil value");
			}
		}

		obj.mIsRuntimeLoad = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_texPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name texPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index texPath on a nil value");
			}
		}

		obj.texPath = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_shaderName(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name shaderName");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index shaderName on a nil value");
			}
		}

		obj.shaderName = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mTexture");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mTexture on a nil value");
			}
		}

		obj.mTexture = (Texture)LuaScriptMgr.GetUnityObject(L, 3, typeof(Texture));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mTexture1(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mTexture1");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mTexture1 on a nil value");
			}
		}

		obj.mTexture1 = (Texture)LuaScriptMgr.GetUnityObject(L, 3, typeof(Texture));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sepTexAlpha(IntPtr L)
	{
		UITexture.sepTexAlpha = (Shader)LuaScriptMgr.GetUnityObject(L, 3, typeof(Shader));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_colorTex(IntPtr L)
	{
		UITexture.colorTex = (Shader)LuaScriptMgr.GetUnityObject(L, 3, typeof(Shader));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sepTexAlphaH2(IntPtr L)
	{
		UITexture.sepTexAlphaH2 = (Shader)LuaScriptMgr.GetUnityObject(L, 3, typeof(Shader));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_colorTexH2(IntPtr L)
	{
		UITexture.colorTexH2 = (Shader)LuaScriptMgr.GetUnityObject(L, 3, typeof(Shader));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sepTexAlphaH4(IntPtr L)
	{
		UITexture.sepTexAlphaH4 = (Shader)LuaScriptMgr.GetUnityObject(L, 3, typeof(Shader));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_colorTexH4(IntPtr L)
	{
		UITexture.colorTexH4 = (Shader)LuaScriptMgr.GetUnityObject(L, 3, typeof(Shader));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_horizontally2(IntPtr L)
	{
		UITexture.horizontally2 = (byte)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_horizontally4(IntPtr L)
	{
		UITexture.horizontally4 = (byte)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_vertically2(IntPtr L)
	{
		UITexture.vertically2 = (byte)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_vertically4(IntPtr L)
	{
		UITexture.vertically4 = (byte)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_normalTex(IntPtr L)
	{
		UITexture.normalTex = (byte)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mainTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name mainTexture");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index mainTexture on a nil value");
			}
		}

		obj.mainTexture = (Texture)LuaScriptMgr.GetUnityObject(L, 3, typeof(Texture));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_material(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name material");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index material on a nil value");
			}
		}

		obj.material = (Material)LuaScriptMgr.GetUnityObject(L, 3, typeof(Material));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_shader(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name shader");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index shader on a nil value");
			}
		}

		obj.shader = (Shader)LuaScriptMgr.GetUnityObject(L, 3, typeof(Shader));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_flip(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name flip");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index flip on a nil value");
			}
		}

		obj.flip = (UITexture.Flip)LuaScriptMgr.GetNetObject(L, 3, typeof(UITexture.Flip));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_uvRect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UITexture obj = (UITexture)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name uvRect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index uvRect on a nil value");
			}
		}

		obj.uvRect = (Rect)LuaScriptMgr.GetNetObject(L, 3, typeof(Rect));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Refresh(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UITexture obj = (UITexture)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UITexture");
		obj.Refresh();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MakePixelPerfect(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UITexture obj = (UITexture)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UITexture");
		obj.MakePixelPerfect();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnFill(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		UITexture obj = (UITexture)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UITexture");
		BetterList<Vector3> arg0 = (BetterList<Vector3>)LuaScriptMgr.GetNetObject(L, 2, typeof(BetterList<Vector3>));
		BetterList<Vector2> arg1 = (BetterList<Vector2>)LuaScriptMgr.GetNetObject(L, 3, typeof(BetterList<Vector2>));
		BetterList<Color32> arg2 = (BetterList<Color32>)LuaScriptMgr.GetNetObject(L, 4, typeof(BetterList<Color32>));
		obj.OnFill(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetTexture(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UITexture obj = (UITexture)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UITexture");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		obj.SetTexture(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetRuntimeTexture(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		UITexture obj = (UITexture)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UITexture");
		Texture arg0 = (Texture)LuaScriptMgr.GetUnityObject(L, 2, typeof(Texture));
		bool arg1 = LuaScriptMgr.GetBoolean(L, 3);
		obj.SetRuntimeTexture(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FillMat(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UITexture obj = (UITexture)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UITexture");
		Material arg0 = (Material)LuaScriptMgr.GetUnityObject(L, 2, typeof(Material));
		obj.FillMat(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTextureListType(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		byte o = UITexture.GetTextureListType(arg0);
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

