using System;
using UnityEngine;
using System.Collections.Generic;
using LuaInterface;

public static class DelegateFactory
{
	delegate Delegate DelegateValue(LuaFunction func);
	static Dictionary<Type, DelegateValue> dict = new Dictionary<Type, DelegateValue>();

	[NoToLuaAttribute]
	public static void Register(IntPtr L)
	{
		dict.Add(typeof(Action<GameObject>), new DelegateValue(Action_GameObject));
		dict.Add(typeof(Action), new DelegateValue(Action));
		dict.Add(typeof(UnityEngine.Events.UnityAction), new DelegateValue(UnityEngine_Events_UnityAction));
		dict.Add(typeof(System.Reflection.MemberFilter), new DelegateValue(System_Reflection_MemberFilter));
		dict.Add(typeof(System.Reflection.TypeFilter), new DelegateValue(System_Reflection_TypeFilter));
		dict.Add(typeof(Camera.CameraCallback), new DelegateValue(Camera_CameraCallback));
		dict.Add(typeof(Application.AdvertisingIdentifierCallback), new DelegateValue(Application_AdvertisingIdentifierCallback));
		dict.Add(typeof(Application.LogCallback), new DelegateValue(Application_LogCallback));
		dict.Add(typeof(UICamera.OnScreenResize), new DelegateValue(UICamera_OnScreenResize));
		dict.Add(typeof(UICamera.OnCustomInput), new DelegateValue(UICamera_OnCustomInput));
		dict.Add(typeof(UIWidget.OnDimensionsChanged), new DelegateValue(UIWidget_OnDimensionsChanged));
		dict.Add(typeof(UIWidget.HitCheck), new DelegateValue(UIWidget_HitCheck));
		dict.Add(typeof(UIProgressBar.OnDragFinished), new DelegateValue(UIProgressBar_OnDragFinished));
		dict.Add(typeof(UILib.SliderValueChangeEventHandler), new DelegateValue(UILib_SliderValueChangeEventHandler));
		dict.Add(typeof(UIGrid.OnReposition), new DelegateValue(UIGrid_OnReposition));
		dict.Add(typeof(BetterList<Transform>.CompareFunc), new DelegateValue(CompareFunc_Transform));
		dict.Add(typeof(UIInput.OnValidate), new DelegateValue(UIInput_OnValidate));
		dict.Add(typeof(UIScrollView.OnDragFinished), new DelegateValue(UIScrollView_OnDragFinished));
		dict.Add(typeof(UITable.OnReposition), new DelegateValue(UITable_OnReposition));
		dict.Add(typeof(UIEventListener.VoidDelegate), new DelegateValue(UIEventListener_VoidDelegate));
		dict.Add(typeof(UIEventListener.BoolDelegate), new DelegateValue(UIEventListener_BoolDelegate));
		dict.Add(typeof(UIEventListener.FloatDelegate), new DelegateValue(UIEventListener_FloatDelegate));
		dict.Add(typeof(UIEventListener.VectorDelegate), new DelegateValue(UIEventListener_VectorDelegate));
		dict.Add(typeof(UIEventListener.ObjectDelegate), new DelegateValue(UIEventListener_ObjectDelegate));
		dict.Add(typeof(UIEventListener.KeyCodeDelegate), new DelegateValue(UIEventListener_KeyCodeDelegate));
		dict.Add(typeof(EventDelegate.Callback), new DelegateValue(EventDelegate_Callback));
		dict.Add(typeof(SpringPanel.OnFinished), new DelegateValue(SpringPanel_OnFinished));
		dict.Add(typeof(DelManager.GameObjDelegate), new DelegateValue(DelManager_GameObjDelegate));
		dict.Add(typeof(UILib.ButtonClickEventHandler), new DelegateValue(UILib_ButtonClickEventHandler));
		dict.Add(typeof(UILib.SpriteClickEventHandler), new DelegateValue(UILib_SpriteClickEventHandler));
		dict.Add(typeof(UILib.RefreshRenderQueueCb), new DelegateValue(UILib_RefreshRenderQueueCb));
	}

	[NoToLuaAttribute]
	public static Delegate CreateDelegate(Type t, LuaFunction func)
	{
		DelegateValue create = null;

		if (!dict.TryGetValue(t, out create))
		{
			Debugger.LogError("Delegate {0} not register", t.FullName);
			return null;
		}
		return create(func);
	}

	public static Delegate Action_GameObject(LuaFunction func)
	{
		Action<GameObject> d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			func.PCall(top, 1);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate Action(LuaFunction func)
	{
		Action d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate UnityEngine_Events_UnityAction(LuaFunction func)
	{
		UnityEngine.Events.UnityAction d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate System_Reflection_MemberFilter(LuaFunction func)
	{
		System.Reflection.MemberFilter d = (param0, param1) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.PushObject(L, param0);
			LuaScriptMgr.PushVarObject(L, param1);
			func.PCall(top, 2);
			object[] objs = func.PopValues(top);
			func.EndPCall(top);
			return (bool)objs[0];
		};
		return d;
	}

	public static Delegate System_Reflection_TypeFilter(LuaFunction func)
	{
		System.Reflection.TypeFilter d = (param0, param1) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.PushVarObject(L, param1);
			func.PCall(top, 2);
			object[] objs = func.PopValues(top);
			func.EndPCall(top);
			return (bool)objs[0];
		};
		return d;
	}

	public static Delegate Camera_CameraCallback(LuaFunction func)
	{
		Camera.CameraCallback d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			func.PCall(top, 1);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate Application_AdvertisingIdentifierCallback(LuaFunction func)
	{
		Application.AdvertisingIdentifierCallback d = (param0, param1, param2) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			LuaScriptMgr.Push(L, param2);
			func.PCall(top, 3);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate Application_LogCallback(LuaFunction func)
	{
		Application.LogCallback d = (param0, param1, param2) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			LuaScriptMgr.Push(L, param2);
			func.PCall(top, 3);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate UICamera_OnScreenResize(LuaFunction func)
	{
		UICamera.OnScreenResize d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate UICamera_OnCustomInput(LuaFunction func)
	{
		UICamera.OnCustomInput d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate UIWidget_OnDimensionsChanged(LuaFunction func)
	{
		UIWidget.OnDimensionsChanged d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate UIWidget_HitCheck(LuaFunction func)
	{
		UIWidget.HitCheck d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			func.PCall(top, 1);
			object[] objs = func.PopValues(top);
			func.EndPCall(top);
			return (bool)objs[0];
		};
		return d;
	}

	public static Delegate UIProgressBar_OnDragFinished(LuaFunction func)
	{
		UIProgressBar.OnDragFinished d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate UILib_SliderValueChangeEventHandler(LuaFunction func)
	{
		UILib.SliderValueChangeEventHandler d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			func.PCall(top, 1);
			object[] objs = func.PopValues(top);
			func.EndPCall(top);
			return (bool)objs[0];
		};
		return d;
	}

	public static Delegate UIGrid_OnReposition(LuaFunction func)
	{
		UIGrid.OnReposition d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate CompareFunc_Transform(LuaFunction func)
	{
		BetterList<Transform>.CompareFunc d = (param0, param1) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			func.PCall(top, 2);
			object[] objs = func.PopValues(top);
			func.EndPCall(top);
			return (int)objs[0];
		};
		return d;
	}

	public static Delegate UIInput_OnValidate(LuaFunction func)
	{
		UIInput.OnValidate d = (param0, param1, param2) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			LuaScriptMgr.Push(L, param2);
			func.PCall(top, 3);
			object[] objs = func.PopValues(top);
			func.EndPCall(top);
			return (char)objs[0];
		};
		return d;
	}

	public static Delegate UIScrollView_OnDragFinished(LuaFunction func)
	{
		UIScrollView.OnDragFinished d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate UITable_OnReposition(LuaFunction func)
	{
		UITable.OnReposition d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate UIEventListener_VoidDelegate(LuaFunction func)
	{
		UIEventListener.VoidDelegate d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			func.PCall(top, 1);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate UIEventListener_BoolDelegate(LuaFunction func)
	{
		UIEventListener.BoolDelegate d = (param0, param1) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			func.PCall(top, 2);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate UIEventListener_FloatDelegate(LuaFunction func)
	{
		UIEventListener.FloatDelegate d = (param0, param1) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			func.PCall(top, 2);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate UIEventListener_VectorDelegate(LuaFunction func)
	{
		UIEventListener.VectorDelegate d = (param0, param1) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			func.PCall(top, 2);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate UIEventListener_ObjectDelegate(LuaFunction func)
	{
		UIEventListener.ObjectDelegate d = (param0, param1) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			func.PCall(top, 2);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate UIEventListener_KeyCodeDelegate(LuaFunction func)
	{
		UIEventListener.KeyCodeDelegate d = (param0, param1) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			LuaScriptMgr.Push(L, param1);
			func.PCall(top, 2);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate EventDelegate_Callback(LuaFunction func)
	{
		EventDelegate.Callback d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate SpringPanel_OnFinished(LuaFunction func)
	{
		SpringPanel.OnFinished d = () =>
		{
			func.Call();
		};
		return d;
	}

	public static Delegate DelManager_GameObjDelegate(LuaFunction func)
	{
		DelManager.GameObjDelegate d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			func.PCall(top, 1);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate UILib_ButtonClickEventHandler(LuaFunction func)
	{
		UILib.ButtonClickEventHandler d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.PushObject(L, param0);
			func.PCall(top, 1);
			object[] objs = func.PopValues(top);
			func.EndPCall(top);
			return (bool)objs[0];
		};
		return d;
	}

	public static Delegate UILib_SpriteClickEventHandler(LuaFunction func)
	{
		UILib.SpriteClickEventHandler d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.PushObject(L, param0);
			func.PCall(top, 1);
			func.EndPCall(top);
		};
		return d;
	}

	public static Delegate UILib_RefreshRenderQueueCb(LuaFunction func)
	{
		UILib.RefreshRenderQueueCb d = (param0) =>
		{
			int top = func.BeginPCall();
			IntPtr L = func.GetLuaState();
			LuaScriptMgr.Push(L, param0);
			func.PCall(top, 1);
			func.EndPCall(top);
		};
		return d;
	}

	public static void Clear()
	{
		dict.Clear();
	}

}
