using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UISpriteWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("GetAtlasSprite", GetAtlasSprite),
			new LuaMethod("MakePixelPerfect", MakePixelPerfect),
			new LuaMethod("OnFill", OnFill),
			new LuaMethod("SetAtlas", SetAtlas),
			new LuaMethod("New", _CreateUISprite),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("current", get_current, set_current),
			new LuaField("atlasPath", get_atlasPath, set_atlasPath),
			new LuaField("centerType", get_centerType, set_centerType),
			new LuaField("leftType", get_leftType, set_leftType),
			new LuaField("rightType", get_rightType, set_rightType),
			new LuaField("bottomType", get_bottomType, set_bottomType),
			new LuaField("topType", get_topType, set_topType),
			new LuaField("onClick", get_onClick, set_onClick),
			new LuaField("isEnabled", get_isEnabled, null),
			new LuaField("type", get_type, set_type),
			new LuaField("flip", get_flip, set_flip),
			new LuaField("FillScale", get_FillScale, null),
			new LuaField("material", get_material, null),
			new LuaField("atlas", get_atlas, set_atlas),
			new LuaField("spriteName", get_spriteName, set_spriteName),
			new LuaField("isValid", get_isValid, null),
			new LuaField("fillDirection", get_fillDirection, set_fillDirection),
			new LuaField("fillAmount", get_fillAmount, set_fillAmount),
			new LuaField("invert", get_invert, set_invert),
			new LuaField("border", get_border, null),
			new LuaField("minWidth", get_minWidth, null),
			new LuaField("minHeight", get_minHeight, null),
			new LuaField("drawingDimensions", get_drawingDimensions, null),
		};

		LuaScriptMgr.RegisterLib(L, "UISprite", typeof(UISprite), regs, fields, typeof(UIWidget));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUISprite(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UISprite class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UISprite);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_current(IntPtr L)
	{
		LuaScriptMgr.Push(L, UISprite.current);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_atlasPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name atlasPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index atlasPath on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.atlasPath);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_centerType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name centerType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index centerType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.centerType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_leftType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name leftType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index leftType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.leftType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rightType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name rightType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index rightType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.rightType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_bottomType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name bottomType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index bottomType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.bottomType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_topType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name topType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index topType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.topType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onClick(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onClick");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onClick on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.onClick);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isEnabled(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isEnabled");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isEnabled on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isEnabled);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_type(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name type");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index type on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.type);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_flip(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

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
	static int get_FillScale(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name FillScale");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index FillScale on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.FillScale);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_material(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

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
	static int get_atlas(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name atlas");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index atlas on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.atlas);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_spriteName(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name spriteName");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index spriteName on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.spriteName);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isValid(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isValid");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isValid on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isValid);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fillDirection(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fillDirection");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fillDirection on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.fillDirection);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fillAmount(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fillAmount");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fillAmount on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.fillAmount);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_invert(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name invert");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index invert on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.invert);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_border(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name border");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index border on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.border);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_minWidth(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name minWidth");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index minWidth on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.minWidth);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_minHeight(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name minHeight");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index minHeight on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.minHeight);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_drawingDimensions(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

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
	static int set_current(IntPtr L)
	{
		UISprite.current = (UISprite)LuaScriptMgr.GetUnityObject(L, 3, typeof(UISprite));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_atlasPath(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name atlasPath");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index atlasPath on a nil value");
			}
		}

		obj.atlasPath = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_centerType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name centerType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index centerType on a nil value");
			}
		}

		obj.centerType = (UISprite.AdvancedType)LuaScriptMgr.GetNetObject(L, 3, typeof(UISprite.AdvancedType));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_leftType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name leftType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index leftType on a nil value");
			}
		}

		obj.leftType = (UISprite.AdvancedType)LuaScriptMgr.GetNetObject(L, 3, typeof(UISprite.AdvancedType));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_rightType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name rightType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index rightType on a nil value");
			}
		}

		obj.rightType = (UISprite.AdvancedType)LuaScriptMgr.GetNetObject(L, 3, typeof(UISprite.AdvancedType));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_bottomType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name bottomType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index bottomType on a nil value");
			}
		}

		obj.bottomType = (UISprite.AdvancedType)LuaScriptMgr.GetNetObject(L, 3, typeof(UISprite.AdvancedType));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_topType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name topType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index topType on a nil value");
			}
		}

		obj.topType = (UISprite.AdvancedType)LuaScriptMgr.GetNetObject(L, 3, typeof(UISprite.AdvancedType));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onClick(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onClick");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onClick on a nil value");
			}
		}

		obj.onClick = (List<EventDelegate>)LuaScriptMgr.GetNetObject(L, 3, typeof(List<EventDelegate>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_type(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name type");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index type on a nil value");
			}
		}

		obj.type = (UISprite.Type)LuaScriptMgr.GetNetObject(L, 3, typeof(UISprite.Type));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_flip(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

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

		obj.flip = (UISprite.Flip)LuaScriptMgr.GetNetObject(L, 3, typeof(UISprite.Flip));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_atlas(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name atlas");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index atlas on a nil value");
			}
		}

		obj.atlas = (UIAtlas)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIAtlas));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_spriteName(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name spriteName");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index spriteName on a nil value");
			}
		}

		obj.spriteName = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_fillDirection(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fillDirection");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fillDirection on a nil value");
			}
		}

		obj.fillDirection = (UISprite.FillDirection)LuaScriptMgr.GetNetObject(L, 3, typeof(UISprite.FillDirection));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_fillAmount(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fillAmount");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fillAmount on a nil value");
			}
		}

		obj.fillAmount = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_invert(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UISprite obj = (UISprite)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name invert");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index invert on a nil value");
			}
		}

		obj.invert = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetAtlasSprite(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UISprite obj = (UISprite)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UISprite");
		UISpriteData o = obj.GetAtlasSprite();
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MakePixelPerfect(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UISprite obj = (UISprite)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UISprite");
		obj.MakePixelPerfect();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnFill(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		UISprite obj = (UISprite)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UISprite");
		BetterList<Vector3> arg0 = (BetterList<Vector3>)LuaScriptMgr.GetNetObject(L, 2, typeof(BetterList<Vector3>));
		BetterList<Vector2> arg1 = (BetterList<Vector2>)LuaScriptMgr.GetNetObject(L, 3, typeof(BetterList<Vector2>));
		BetterList<Color32> arg2 = (BetterList<Color32>)LuaScriptMgr.GetNetObject(L, 4, typeof(BetterList<Color32>));
		obj.OnFill(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetAtlas(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UISprite obj = (UISprite)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UISprite");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		obj.SetAtlas(arg0);
		return 0;
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

