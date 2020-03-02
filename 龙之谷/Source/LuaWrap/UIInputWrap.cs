using System;
using UnityEngine;
using System.Collections.Generic;
using LuaInterface;
using Object = UnityEngine.Object;

public class UIInputWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Validate", Validate),
			new LuaMethod("Submit", Submit),
			new LuaMethod("UpdateLabel", UpdateLabel),
			new LuaMethod("RemoveFocus", RemoveFocus),
			new LuaMethod("SaveValue", SaveValue),
			new LuaMethod("LoadValue", LoadValue),
			new LuaMethod("New", _CreateUIInput),
			new LuaMethod("GetClassType", GetClassType),
			new LuaMethod("__eq", Lua_Eq),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("current", get_current, set_current),
			new LuaField("selection", get_selection, set_selection),
			new LuaField("label", get_label, set_label),
			new LuaField("inputType", get_inputType, set_inputType),
			new LuaField("keyboardType", get_keyboardType, set_keyboardType),
			new LuaField("validation", get_validation, set_validation),
			new LuaField("characterLimit", get_characterLimit, set_characterLimit),
			new LuaField("savedAs", get_savedAs, set_savedAs),
			new LuaField("selectOnTab", get_selectOnTab, set_selectOnTab),
			new LuaField("activeTextColor", get_activeTextColor, set_activeTextColor),
			new LuaField("caretColor", get_caretColor, set_caretColor),
			new LuaField("selectionColor", get_selectionColor, set_selectionColor),
			new LuaField("onSubmit", get_onSubmit, set_onSubmit),
			new LuaField("onChange", get_onChange, set_onChange),
			new LuaField("onKeyTriggered", get_onKeyTriggered, set_onKeyTriggered),
			new LuaField("onValidate", get_onValidate, set_onValidate),
			new LuaField("recentKey", get_recentKey, set_recentKey),
			new LuaField("defaultText", get_defaultText, set_defaultText),
			new LuaField("value", get_value, set_value),
			new LuaField("isSelected", get_isSelected, set_isSelected),
			new LuaField("cursorPosition", get_cursorPosition, set_cursorPosition),
			new LuaField("selectionStart", get_selectionStart, set_selectionStart),
			new LuaField("selectionEnd", get_selectionEnd, set_selectionEnd),
			new LuaField("caret", get_caret, null),
		};

		LuaScriptMgr.RegisterLib(L, "UIInput", typeof(UIInput), regs, fields, typeof(MonoBehaviour));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUIInput(IntPtr L)
	{
		LuaDLL.luaL_error(L, "UIInput class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(UIInput);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_current(IntPtr L)
	{
		LuaScriptMgr.Push(L, UIInput.current);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_selection(IntPtr L)
	{
		LuaScriptMgr.Push(L, UIInput.selection);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_label(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name label");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index label on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.label);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_inputType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name inputType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index inputType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.inputType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_keyboardType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name keyboardType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index keyboardType on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.keyboardType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_validation(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name validation");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index validation on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.validation);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_characterLimit(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name characterLimit");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index characterLimit on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.characterLimit);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_savedAs(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name savedAs");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index savedAs on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.savedAs);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_selectOnTab(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name selectOnTab");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index selectOnTab on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.selectOnTab);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_activeTextColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeTextColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeTextColor on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.activeTextColor);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_caretColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name caretColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index caretColor on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.caretColor);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_selectionColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name selectionColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index selectionColor on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.selectionColor);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onSubmit(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onSubmit");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onSubmit on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.onSubmit);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onChange(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

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

		LuaScriptMgr.PushObject(L, obj.onChange);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onKeyTriggered(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onKeyTriggered");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onKeyTriggered on a nil value");
			}
		}

		LuaScriptMgr.PushObject(L, obj.onKeyTriggered);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onValidate(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onValidate");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onValidate on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.onValidate);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_recentKey(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name recentKey");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index recentKey on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.recentKey);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_defaultText(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name defaultText");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index defaultText on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.defaultText);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_value(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name value");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index value on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.value);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isSelected(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isSelected");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isSelected on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.isSelected);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cursorPosition(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cursorPosition");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cursorPosition on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.cursorPosition);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_selectionStart(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name selectionStart");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index selectionStart on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.selectionStart);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_selectionEnd(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name selectionEnd");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index selectionEnd on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.selectionEnd);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_caret(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name caret");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index caret on a nil value");
			}
		}

		LuaScriptMgr.Push(L, obj.caret);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_current(IntPtr L)
	{
		UIInput.current = (UIInput)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIInput));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_selection(IntPtr L)
	{
		UIInput.selection = (UIInput)LuaScriptMgr.GetUnityObject(L, 3, typeof(UIInput));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_label(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name label");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index label on a nil value");
			}
		}

		obj.label = (UILabel)LuaScriptMgr.GetUnityObject(L, 3, typeof(UILabel));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_inputType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name inputType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index inputType on a nil value");
			}
		}

		obj.inputType = (UIInput.InputType)LuaScriptMgr.GetNetObject(L, 3, typeof(UIInput.InputType));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_keyboardType(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name keyboardType");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index keyboardType on a nil value");
			}
		}

		obj.keyboardType = (UIInput.KeyboardType)LuaScriptMgr.GetNetObject(L, 3, typeof(UIInput.KeyboardType));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_validation(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name validation");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index validation on a nil value");
			}
		}

		obj.validation = (UIInput.Validation)LuaScriptMgr.GetNetObject(L, 3, typeof(UIInput.Validation));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_characterLimit(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name characterLimit");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index characterLimit on a nil value");
			}
		}

		obj.characterLimit = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_savedAs(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name savedAs");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index savedAs on a nil value");
			}
		}

		obj.savedAs = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_selectOnTab(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name selectOnTab");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index selectOnTab on a nil value");
			}
		}

		obj.selectOnTab = (GameObject)LuaScriptMgr.GetUnityObject(L, 3, typeof(GameObject));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_activeTextColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name activeTextColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index activeTextColor on a nil value");
			}
		}

		obj.activeTextColor = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_caretColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name caretColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index caretColor on a nil value");
			}
		}

		obj.caretColor = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_selectionColor(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name selectionColor");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index selectionColor on a nil value");
			}
		}

		obj.selectionColor = LuaScriptMgr.GetColor(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onSubmit(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onSubmit");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onSubmit on a nil value");
			}
		}

		obj.onSubmit = (List<EventDelegate>)LuaScriptMgr.GetNetObject(L, 3, typeof(List<EventDelegate>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onChange(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

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

		obj.onChange = (List<EventDelegate>)LuaScriptMgr.GetNetObject(L, 3, typeof(List<EventDelegate>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onKeyTriggered(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onKeyTriggered");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onKeyTriggered on a nil value");
			}
		}

		obj.onKeyTriggered = (List<EventDelegate>)LuaScriptMgr.GetNetObject(L, 3, typeof(List<EventDelegate>));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onValidate(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name onValidate");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index onValidate on a nil value");
			}
		}

		LuaTypes funcType = LuaDLL.lua_type(L, 3);

		if (funcType != LuaTypes.LUA_TFUNCTION)
		{
			obj.onValidate = (UIInput.OnValidate)LuaScriptMgr.GetNetObject(L, 3, typeof(UIInput.OnValidate));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.ToLuaFunction(L, 3);
			obj.onValidate = (param0, param1, param2) =>
			{
				int top = func.BeginPCall();
				LuaScriptMgr.Push(L, param0);
				LuaScriptMgr.Push(L, param1);
				LuaScriptMgr.Push(L, param2);
				func.PCall(top, 3);
				object[] objs = func.PopValues(top);
				func.EndPCall(top);
				return (char)objs[0];
			};
		}
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_recentKey(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name recentKey");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index recentKey on a nil value");
			}
		}

		obj.recentKey = (KeyCode)LuaScriptMgr.GetNetObject(L, 3, typeof(KeyCode));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_defaultText(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name defaultText");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index defaultText on a nil value");
			}
		}

		obj.defaultText = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_value(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name value");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index value on a nil value");
			}
		}

		obj.value = LuaScriptMgr.GetString(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isSelected(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name isSelected");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index isSelected on a nil value");
			}
		}

		obj.isSelected = LuaScriptMgr.GetBoolean(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cursorPosition(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name cursorPosition");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index cursorPosition on a nil value");
			}
		}

		obj.cursorPosition = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_selectionStart(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name selectionStart");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index selectionStart on a nil value");
			}
		}

		obj.selectionStart = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_selectionEnd(IntPtr L)
	{
		object o = LuaScriptMgr.GetLuaObject(L, 1);
		UIInput obj = (UIInput)o;

		if (obj == null)
		{
			LuaTypes types = LuaDLL.lua_type(L, 1);

			if (types == LuaTypes.LUA_TTABLE)
			{
				LuaDLL.luaL_error(L, "unknown member name selectionEnd");
			}
			else
			{
				LuaDLL.luaL_error(L, "attempt to index selectionEnd on a nil value");
			}
		}

		obj.selectionEnd = (int)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Validate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UIInput obj = (UIInput)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIInput");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		string o = obj.Validate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Submit(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIInput obj = (UIInput)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIInput");
		obj.Submit();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UpdateLabel(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIInput obj = (UIInput)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIInput");
		obj.UpdateLabel();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveFocus(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIInput obj = (UIInput)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIInput");
		obj.RemoveFocus();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SaveValue(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIInput obj = (UIInput)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIInput");
		obj.SaveValue();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadValue(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		UIInput obj = (UIInput)LuaScriptMgr.GetUnityObjectSelf(L, 1, "UIInput");
		obj.LoadValue();
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

