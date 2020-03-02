using System;
using UnityEngine;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIScrollViewWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("NeedRecalcBounds", NeedRecalcBounds),
			new LuaMethod("RestrictWithinBounds", RestrictWithinBounds),
			new LuaMethod("DisableSpring", DisableSpring),
			new LuaMethod("UpdateScrollbars", UpdateScrollbars),
			new LuaMethod("SetDragAmount", SetDragAmount),
			new LuaMethod("ResetPosition", ResetPosition),
			new LuaMethod("UpdatePosition", UpdatePosition),
			new LuaMethod("OnScrollBar", OnScrollBar),
			new LuaMethod("MoveRelative", MoveRelative),
			new LuaMethod("MoveAbsolute", MoveAbsolute),
			new LuaMethod("Press", Press),
			new LuaMethod("Drag", Drag),
			new LuaMethod("Scroll", Scroll),
			new LuaMethod("SetAutoMove", SetAutoMove),
			new LuaMethod("New", _CreateUIScrollView),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("list", get_list, set_list),
			new LuaField("movement", get_movement, set_movement),
			new LuaField("dragEffect", get_dragEffect, set_dragEffect),
			new LuaField("restrictWithinPanel", get_restrictWithinPanel, set_restrictWithinPanel),
			new LuaField("disableDragIfFits", get_disableDragIfFits, set_disableDragIfFits),
			new LuaField("smoothDragStart", get_smoothDragStart, set_smoothDragStart),
			new LuaField("iOSDragEmulation", get_iOSDragEmulation, set_iOSDragEmulation),
			new LuaField("scrollWheelFactor", get_scrollWheelFactor, set_scrollWheelFactor),
			new LuaField("momentumAmount", get_momentumAmount, set_momentumAmount),
			new LuaField("horizontalScrollBar", get_horizontalScrollBar, set_horizontalScrollBar),
			new LuaField("verticalScrollBar", get_verticalScrollBar, set_verticalScrollBar),
			new LuaField("showScrollBars", get_showScrollBars, set_showScrollBars),
			new LuaField("customMovement", get_customMovement, set_customMovement),
			new LuaField("contentPivot", get_contentPivot, set_contentPivot),
			new LuaField("onDragFinished", get_onDragFinished, set_onDragFinished),
			new LuaField("moveControllerTime", get_moveControllerTime, set_moveControllerTime),
			new LuaField("panel", get_panel, null),
			new LuaField("isDragging", get_isDragging, null),
			new LuaField("bounds", get_bounds, null),
			new LuaField("canMoveHorizontally", get_canMoveHorizontally, null),
			new LuaField("canMoveVertically", get_canMoveVertically, null),
			new LuaField("shouldMoveHorizontally", get_shouldMoveHorizontally, null),
			new LuaField("shouldMoveVertically", get_shouldMoveVertically, null),
			new LuaField("currentMomentum", get_currentMomentum, set_currentMomentum),
		};

		LuaScriptMgr.RegisterLib(L, "UIScrollView", typeof(UIScrollView), regs, fields, typeof(MonoBehaviour));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIScrollView(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIScrollView class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIScrollView);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_list(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, UIScrollView.list);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_movement(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name movement");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index movement on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.movement);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_dragEffect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name dragEffect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index dragEffect on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.dragEffect);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_restrictWithinPanel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name restrictWithinPanel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index restrictWithinPanel on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.restrictWithinPanel);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_disableDragIfFits(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name disableDragIfFits");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index disableDragIfFits on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.disableDragIfFits);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_smoothDragStart(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name smoothDragStart");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index smoothDragStart on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.smoothDragStart);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_iOSDragEmulation(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name iOSDragEmulation");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index iOSDragEmulation on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.iOSDragEmulation);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_scrollWheelFactor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name scrollWheelFactor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index scrollWheelFactor on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.scrollWheelFactor);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_momentumAmount(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name momentumAmount");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index momentumAmount on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.momentumAmount);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_horizontalScrollBar(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name horizontalScrollBar");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index horizontalScrollBar on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.horizontalScrollBar);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_verticalScrollBar(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name verticalScrollBar");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index verticalScrollBar on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.verticalScrollBar);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_showScrollBars(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name showScrollBars");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index showScrollBars on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.showScrollBars);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_customMovement(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name customMovement");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index customMovement on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.customMovement);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_contentPivot(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name contentPivot");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index contentPivot on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.contentPivot);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDragFinished(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDragFinished");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDragFinished on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onDragFinished);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_moveControllerTime(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name moveControllerTime");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index moveControllerTime on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.moveControllerTime);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_panel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

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
	static int get_isDragging(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isDragging");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isDragging on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isDragging);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_bounds(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name bounds");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index bounds on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.bounds);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_canMoveHorizontally(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name canMoveHorizontally");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index canMoveHorizontally on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.canMoveHorizontally);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_canMoveVertically(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name canMoveVertically");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index canMoveVertically on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.canMoveVertically);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_shouldMoveHorizontally(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name shouldMoveHorizontally");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index shouldMoveHorizontally on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.shouldMoveHorizontally);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_shouldMoveVertically(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name shouldMoveVertically");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index shouldMoveVertically on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.shouldMoveVertically);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_currentMomentum(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name currentMomentum");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index currentMomentum on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.currentMomentum);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_list(IntPtr L)
	{
		UIScrollView.list = (BetterList<UIScrollView>)LuaScriptMgr.GetNetObject(L, 3, typeof(BetterList<UIScrollView>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_movement(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name movement");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index movement on a nil value");
			}
		}

		obj.movement = (UIScrollView.Movement)LuaScriptMgr.GetNetObject(L, 3, typeof(UIScrollView.Movement));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_dragEffect(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name dragEffect");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index dragEffect on a nil value");
			}
		}

		obj.dragEffect = (UIScrollView.DragEffect)LuaScriptMgr.GetNetObject(L, 3, typeof(UIScrollView.DragEffect));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_restrictWithinPanel(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name restrictWithinPanel");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index restrictWithinPanel on a nil value");
			}
		}

		obj.restrictWithinPanel = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_disableDragIfFits(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name disableDragIfFits");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index disableDragIfFits on a nil value");
			}
		}

		obj.disableDragIfFits = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_smoothDragStart(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name smoothDragStart");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index smoothDragStart on a nil value");
			}
		}

		obj.smoothDragStart = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_iOSDragEmulation(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name iOSDragEmulation");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index iOSDragEmulation on a nil value");
			}
		}

		obj.iOSDragEmulation = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_scrollWheelFactor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name scrollWheelFactor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index scrollWheelFactor on a nil value");
			}
		}

		obj.scrollWheelFactor = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_momentumAmount(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name momentumAmount");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index momentumAmount on a nil value");
			}
		}

		obj.momentumAmount = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_horizontalScrollBar(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name horizontalScrollBar");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index horizontalScrollBar on a nil value");
			}
		}

		obj.horizontalScrollBar = (UIProgressBar)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIProgressBar));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_verticalScrollBar(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name verticalScrollBar");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index verticalScrollBar on a nil value");
			}
		}

		obj.verticalScrollBar = (UIProgressBar)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIProgressBar));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_showScrollBars(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name showScrollBars");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index showScrollBars on a nil value");
			}
		}

		obj.showScrollBars = (UIScrollView.ShowCondition)LuaScriptMgr.GetNetObject(L, 3, typeof(UIScrollView.ShowCondition));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_customMovement(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name customMovement");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index customMovement on a nil value");
			}
		}

		obj.customMovement = LuaScriptMgr.GetVector2(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_contentPivot(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name contentPivot");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index contentPivot on a nil value");
			}
		}

		obj.contentPivot = (UIWidget.Pivot)LuaScriptMgr.GetNetObject(L, 3, typeof(UIWidget.Pivot));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDragFinished(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onDragFinished");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onDragFinished on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onDragFinished = (UIScrollView.OnDragFinished)LuaScriptMgr.GetNetObject(L, 3, typeof(UIScrollView.OnDragFinished));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onDragFinished = () =>
			{
				func.Call();
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_moveControllerTime(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name moveControllerTime");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index moveControllerTime on a nil value");
			}
		}

		obj.moveControllerTime = (float)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_currentMomentum(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIScrollView obj = (UIScrollView)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name currentMomentum");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index currentMomentum on a nil value");
			}
		}

		obj.currentMomentum = LuaScriptMgr.GetVector3(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int NeedRecalcBounds(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		obj.NeedRecalcBounds();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RestrictWithinBounds(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
			bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
			bool o = obj.RestrictWithinBounds(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 4)
		{
			UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
			bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
			bool arg1 = LuaScriptMgr.GetBoolean(L, 3);
			bool arg2 = LuaScriptMgr.GetBoolean(L, 4);
			bool o = obj.RestrictWithinBounds(arg0,arg1,arg2);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: UIScrollView.RestrictWithinBounds");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DisableSpring(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		obj.DisableSpring();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UpdateScrollbars(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
			obj.UpdateScrollbars();
			return 0;
		}
		else if (count == 2)
		{
			UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
			bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
			obj.UpdateScrollbars(arg0);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: UIScrollView.UpdateScrollbars");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDragAmount(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		float arg0 = (float)LuaScriptMgr.GetNumber(L, 2);
		float arg1 = (float)LuaScriptMgr.GetNumber(L, 3);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 4);
		obj.SetDragAmount(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetPosition(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
			obj.ResetPosition();
			return 0;
		}
		else if (count == 2)
		{
			UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
			float arg0 = (float)LuaScriptMgr.GetNumber(L, 2);
			obj.ResetPosition(arg0);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: UIScrollView.ResetPosition");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UpdatePosition(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		obj.UpdatePosition();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnScrollBar(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		obj.OnScrollBar();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MoveRelative(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		obj.MoveRelative(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MoveAbsolute(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		Vector3 arg0 = LuaScriptMgr.GetVector3(L, 2);
		obj.MoveAbsolute(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Press(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		bool arg0 = LuaScriptMgr.GetBoolean(L, 2);
		obj.Press(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Drag(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		obj.Drag();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Scroll(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		float arg0 = (float)LuaScriptMgr.GetNumber(L, 2);
		obj.Scroll(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetAutoMove(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		UIScrollView obj = (UIScrollView)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIScrollView");
		float arg0 = (float)LuaScriptMgr.GetNumber(L, 2);
		float arg1 = (float)LuaScriptMgr.GetNumber(L, 3);
		float arg2 = (float)LuaScriptMgr.GetNumber(L, 4);
		obj.SetAutoMove(arg0,arg1,arg2);
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

