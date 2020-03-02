using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIWidgetWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("SetupDecorate", SetupDecorate),
			new LuaMethod("RegisterUI", RegisterUI),
			new LuaMethod("SetDimensions", SetDimensions),
			new LuaMethod("GetSides", GetSides),
			new LuaMethod("CalculateFinalAlpha", CalculateFinalAlpha),
			new LuaMethod("Invalidate", Invalidate),
			new LuaMethod("CalculateCumulativeAlpha", CalculateCumulativeAlpha),
			new LuaMethod("SetRect", SetRect),
			new LuaMethod("ResizeCollider", ResizeCollider),
			new LuaMethod("FullCompareFunc", FullCompareFunc),
			new LuaMethod("PanelCompareFunc", PanelCompareFunc),
			new LuaMethod("CalculateBounds", CalculateBounds),
			new LuaMethod("SetDirty", SetDirty),
			new LuaMethod("MarkAsChanged", MarkAsChanged),
			new LuaMethod("CreatePanel", CreatePanel),
			new LuaMethod("SetPanel", SetPanel),
			new LuaMethod("CheckLayer", CheckLayer),
			new LuaMethod("ParentHasChanged", ParentHasChanged),
			new LuaMethod("UpdateVisibility", UpdateVisibility),
			new LuaMethod("UpdateTransform", UpdateTransform),
			new LuaMethod("UpdateGeometry", UpdateGeometry),
			new LuaMethod("ClearGeometry", ClearGeometry),
			new LuaMethod("WriteToBuffers", WriteToBuffers),
			new LuaMethod("MakePixelPerfect", MakePixelPerfect),
			new LuaMethod("OnFill", OnFill),
			new LuaMethod("New", _CreateUIWidget),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("uid", get_uid, set_uid),
			new LuaField("sid", get_sid, set_sid),
			new LuaField("decorateList", get_decorateList, set_decorateList),
			new LuaField("onChange", get_onChange, set_onChange),
			new LuaField("autoResizeBoxCollider", get_autoResizeBoxCollider, set_autoResizeBoxCollider),
			new LuaField("hideIfOffScreen", get_hideIfOffScreen, set_hideIfOffScreen),
			new LuaField("autoFindPanel", get_autoFindPanel, set_autoFindPanel),
			new LuaField("keepAspectRatio", get_keepAspectRatio, set_keepAspectRatio),
			new LuaField("aspectRatio", get_aspectRatio, set_aspectRatio),
			new LuaField("hitCheck", get_hitCheck, set_hitCheck),
			new LuaField("panel", get_panel, set_panel),
			new LuaField("storePanel", get_storePanel, set_storePanel),
			new LuaField("geometry", get_geometry, set_geometry),
			new LuaField("fillGeometry", get_fillGeometry, set_fillGeometry),
			new LuaField("boxColliderCache", get_boxColliderCache, set_boxColliderCache),
			new LuaField("calcRenderQueue", get_calcRenderQueue, set_calcRenderQueue),
			new LuaField("drawCall", get_drawCall, set_drawCall),
			new LuaField("textureIndex", get_textureIndex, set_textureIndex),
			new LuaField("faraway", get_faraway, null),
			new LuaField("drawRegion", get_drawRegion, set_drawRegion),
			new LuaField("pivotOffset", get_pivotOffset, null),
			new LuaField("width", get_width, set_width),
			new LuaField("height", get_height, set_height),
			new LuaField("color", get_color, set_color),
			new LuaField("alpha", get_alpha, set_alpha),
			new LuaField("isVisible", get_isVisible, null),
			new LuaField("hasVertices", get_hasVertices, null),
			new LuaField("rawPivot", get_rawPivot, set_rawPivot),
			new LuaField("pivot", get_pivot, set_pivot),
			new LuaField("depth", get_depth, set_depth),
			new LuaField("raycastDepth", get_raycastDepth, null),
			new LuaField("localCorners", get_localCorners, null),
			new LuaField("localSize", get_localSize, null),
			new LuaField("worldCorners", get_worldCorners, null),
			new LuaField("drawingDimensions", get_drawingDimensions, null),
			new LuaField("material", get_material, set_material),
			new LuaField("mainTexture", get_mainTexture, set_mainTexture),
			new LuaField("alphaTexture", get_alphaTexture, null),
			new LuaField("shader", get_shader, set_shader),
			new LuaField("hasBoxCollider", get_hasBoxCollider, null),
			new LuaField("DefaultBoxCollider", get_DefaultBoxCollider, null),
			new LuaField("minWidth", get_minWidth, null),
			new LuaField("minHeight", get_minHeight, null),
			new LuaField("border", get_border, null),
		};

		LuaScriptMgr.RegisterLib(L, "UIWidget", typeof(UIWidget), regs, fields, typeof(UIRect));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIWidget(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIWidget class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIWidget);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_uid(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name uid");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index uid on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.uid);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sid(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name sid");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index sid on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.sid);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_decorateList(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name decorateList");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index decorateList on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.decorateList);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onChange(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onChange");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onChange on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onChange);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_autoResizeBoxCollider(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name autoResizeBoxCollider");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index autoResizeBoxCollider on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.autoResizeBoxCollider);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hideIfOffScreen(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hideIfOffScreen");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hideIfOffScreen on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.hideIfOffScreen);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_autoFindPanel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name autoFindPanel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index autoFindPanel on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.autoFindPanel);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_keepAspectRatio(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name keepAspectRatio");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index keepAspectRatio on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.keepAspectRatio);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_aspectRatio(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name aspectRatio");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index aspectRatio on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.aspectRatio);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hitCheck(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hitCheck");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hitCheck on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.hitCheck);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_panel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name panel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index panel on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.panel);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_storePanel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name storePanel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index storePanel on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.storePanel);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_geometry(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name geometry");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index geometry on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.geometry);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fillGeometry(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fillGeometry");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fillGeometry on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.fillGeometry);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_boxColliderCache(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name boxColliderCache");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index boxColliderCache on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.boxColliderCache);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_calcRenderQueue(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name calcRenderQueue");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index calcRenderQueue on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.calcRenderQueue);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_drawCall(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name drawCall");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index drawCall on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.drawCall);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_textureIndex(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name textureIndex");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index textureIndex on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.textureIndex);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_faraway(IntPtr L)
	{
		LuaScriptMgr.Push(L, UIWidget.faraway);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_drawRegion(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name drawRegion");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index drawRegion on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.drawRegion);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pivotOffset(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pivotOffset");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pivotOffset on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.pivotOffset);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_width(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name width");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index width on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.width);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_height(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name height");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index height on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.height);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_color(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name color");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index color on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.color);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_alpha(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name alpha");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index alpha on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.alpha);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isVisible(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isVisible");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isVisible on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isVisible);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hasVertices(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hasVertices");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hasVertices on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.hasVertices);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rawPivot(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name rawPivot");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index rawPivot on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.rawPivot);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pivot(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pivot");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pivot on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.pivot);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_depth(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name depth");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index depth on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.depth);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_raycastDepth(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name raycastDepth");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index raycastDepth on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.raycastDepth);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_localCorners(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name localCorners");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index localCorners on a nil value");
			}
		}

		LuaScriptMgr.PushArray(L, obj.localCorners);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_localSize(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name localSize");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index localSize on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.localSize);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_worldCorners(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name worldCorners");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index worldCorners on a nil value");
			}
		}

		LuaScriptMgr.PushArray(L, obj.worldCorners);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_drawingDimensions(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
	static int get_material(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
	static int get_mainTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
		UIWidget obj = (UIWidget)o;

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
	static int get_shader(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
	static int get_hasBoxCollider(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hasBoxCollider");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hasBoxCollider on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.hasBoxCollider);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_DefaultBoxCollider(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name DefaultBoxCollider");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index DefaultBoxCollider on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.DefaultBoxCollider);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_minWidth(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
		UIWidget obj = (UIWidget)o;

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
	static int get_border(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
	static int set_uid(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name uid");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index uid on a nil value");
			}
		}

		obj.uid = (uint)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sid(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name sid");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index sid on a nil value");
			}
		}

		obj.sid = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_decorateList(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name decorateList");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index decorateList on a nil value");
			}
		}

		obj.decorateList = (List<UIWidget.Decorate>)LuaScriptMgr.GetNetObject(L, 3, typeof(List<UIWidget.Decorate>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onChange(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onChange");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onChange on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onChange = (UIWidget.OnDimensionsChanged)LuaScriptMgr.GetNetObject(L, 3, typeof(UIWidget.OnDimensionsChanged));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onChange = () =>
			{
				func.Call();
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_autoResizeBoxCollider(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name autoResizeBoxCollider");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index autoResizeBoxCollider on a nil value");
			}
		}

		obj.autoResizeBoxCollider = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_hideIfOffScreen(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hideIfOffScreen");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hideIfOffScreen on a nil value");
			}
		}

		obj.hideIfOffScreen = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_autoFindPanel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name autoFindPanel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index autoFindPanel on a nil value");
			}
		}

		obj.autoFindPanel = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_keepAspectRatio(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name keepAspectRatio");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index keepAspectRatio on a nil value");
			}
		}

		obj.keepAspectRatio = (UIWidget.AspectRatioSource)LuaScriptMgr.GetNetObject(L, 3, typeof(UIWidget.AspectRatioSource));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_aspectRatio(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name aspectRatio");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index aspectRatio on a nil value");
			}
		}

		obj.aspectRatio = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_hitCheck(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name hitCheck");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index hitCheck on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.hitCheck = (UIWidget.HitCheck)LuaScriptMgr.GetNetObject(L, 3, typeof(UIWidget.HitCheck));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.hitCheck = (param0) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				func.PCall(top, 1);
				object[] objs = func.PopValues(top);
				func.EndPCall(top);
				return (bool)objs[0];
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_panel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name panel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index panel on a nil value");
			}
		}

		obj.panel = (UIPanel)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIPanel));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_storePanel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name storePanel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index storePanel on a nil value");
			}
		}

		obj.storePanel = (UIPanel)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIPanel));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_geometry(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name geometry");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index geometry on a nil value");
			}
		}

		obj.geometry = (UIGeometry)LuaScriptMgr.GetNetObject(L, 3, typeof(UIGeometry));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_fillGeometry(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name fillGeometry");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index fillGeometry on a nil value");
			}
		}

		obj.fillGeometry = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_boxColliderCache(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name boxColliderCache");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index boxColliderCache on a nil value");
			}
		}

		obj.boxColliderCache = (BoxCollider)LuaScriptMgr.GetUnityObject(L, 3, typeof(BoxCollider));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_calcRenderQueue(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name calcRenderQueue");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index calcRenderQueue on a nil value");
			}
		}

		obj.calcRenderQueue = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_drawCall(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name drawCall");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index drawCall on a nil value");
			}
		}

		obj.drawCall = (UIDrawCall)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIDrawCall));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_textureIndex(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name textureIndex");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index textureIndex on a nil value");
			}
		}

		obj.textureIndex = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_drawRegion(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name drawRegion");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index drawRegion on a nil value");
			}
		}

		obj.drawRegion = LuaScriptMgr.GetVector4(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_width(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name width");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index width on a nil value");
			}
		}

		obj.width = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_height(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name height");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index height on a nil value");
			}
		}

		obj.height = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_color(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name color");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index color on a nil value");
			}
		}

		obj.color = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_alpha(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name alpha");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index alpha on a nil value");
			}
		}

		obj.alpha = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_rawPivot(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name rawPivot");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index rawPivot on a nil value");
			}
		}

		obj.rawPivot = (UIWidget.Pivot)LuaScriptMgr.GetNetObject(L, 3, typeof(UIWidget.Pivot));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pivot(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name pivot");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index pivot on a nil value");
			}
		}

		obj.pivot = (UIWidget.Pivot)LuaScriptMgr.GetNetObject(L, 3, typeof(UIWidget.Pivot));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_depth(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name depth");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index depth on a nil value");
			}
		}

		obj.depth = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_material(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
	static int set_mainTexture(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
	static int set_shader(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIWidget obj = (UIWidget)o;

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
	static int SetupDecorate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		obj.SetupDecorate();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RegisterUI(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		Component arg0 = (Component)LuaScriptMgr.GetUnityObject(L, 2, typeof(Component));
		obj.RegisterUI(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDimensions(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 2);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 3);
		obj.SetDimensions(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSides(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		Transform arg0 = (Transform)LuaScriptMgr.GetUnityObject(L, 2, typeof(Transform));
		Vector3[] o = obj.GetSides(arg0);
		LuaScriptMgr.PushArray(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalculateFinalAlpha(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 2);
		float o = obj.CalculateFinalAlpha(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Invalidate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
		obj.Invalidate(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalculateCumulativeAlpha(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 2);
		float o = obj.CalculateCumulativeAlpha(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetRect(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 5);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		float arg0 = (float)LuaScriptMgr.GetNumber(L, 2);
		float arg1 = (float)LuaScriptMgr.GetNumber(L, 3);
		float arg2 = (float)LuaScriptMgr.GetNumber(L, 4);
		float arg3 = (float)LuaScriptMgr.GetNumber(L, 5);
		obj.SetRect(arg0,arg1,arg2,arg3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResizeCollider(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		obj.ResizeCollider();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FullCompareFunc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget arg0 = (UIWidget)LuaScriptMgr.GetUnityObject(L, 1, typeof(UIWidget));
		UIWidget arg1 = (UIWidget)LuaScriptMgr.GetUnityObject(L, 2, typeof(UIWidget));
		int o = UIWidget.FullCompareFunc(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PanelCompareFunc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget arg0 = (UIWidget)LuaScriptMgr.GetUnityObject(L, 1, typeof(UIWidget));
		UIWidget arg1 = (UIWidget)LuaScriptMgr.GetUnityObject(L, 2, typeof(UIWidget));
		int o = UIWidget.PanelCompareFunc(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalculateBounds(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
			Bounds o = obj.CalculateBounds();
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
			Transform arg0 = (Transform)LuaScriptMgr.GetUnityObject(L, 2, typeof(Transform));
			Bounds o = obj.CalculateBounds(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: UIWidget.CalculateBounds");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDirty(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		obj.SetDirty();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MarkAsChanged(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		obj.MarkAsChanged();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreatePanel(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		UIPanel o = obj.CreatePanel();
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPanel(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		UIPanel arg0 = (UIPanel)LuaScriptMgr.GetUnityObject(L, 2, typeof(UIPanel));
		obj.SetPanel(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CheckLayer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		obj.CheckLayer();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ParentHasChanged(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		obj.ParentHasChanged();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UpdateVisibility(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 3);
		bool o = obj.UpdateVisibility(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UpdateTransform(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 2);
		bool o = obj.UpdateTransform(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UpdateGeometry(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 2);
		bool o = obj.UpdateGeometry(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearGeometry(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		obj.ClearGeometry();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteToBuffers(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 6);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		FastListV3 arg0 = (FastListV3)LuaScriptMgr.GetNetObject(L, 2, typeof(FastListV3));
		FastListV2 arg1 = (FastListV2)LuaScriptMgr.GetNetObject(L, 3, typeof(FastListV2));
		FastListColor32 arg2 = (FastListColor32)LuaScriptMgr.GetNetObject(L, 4, typeof(FastListColor32));
		BetterList<Vector3> arg3 = (BetterList<Vector3>)LuaScriptMgr.GetNetObject(L, 5, typeof(BetterList<Vector3>));
		BetterList<Vector4> arg4 = (BetterList<Vector4>)LuaScriptMgr.GetNetObject(L, 6, typeof(BetterList<Vector4>));
		obj.WriteToBuffers(arg0,arg1,arg2,arg3,arg4);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MakePixelPerfect(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		obj.MakePixelPerfect();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnFill(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		UIWidget obj = (UIWidget)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIWidget");
		BetterList<Vector3> arg0 = (BetterList<Vector3>)LuaScriptMgr.GetNetObject(L, 2, typeof(BetterList<Vector3>));
		BetterList<Vector2> arg1 = (BetterList<Vector2>)LuaScriptMgr.GetNetObject(L, 3, typeof(BetterList<Vector2>));
		BetterList<Color32> arg2 = (BetterList<Color32>)LuaScriptMgr.GetNetObject(L, 4, typeof(BetterList<Color32>));
		obj.OnFill(arg0,arg1,arg2);
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

