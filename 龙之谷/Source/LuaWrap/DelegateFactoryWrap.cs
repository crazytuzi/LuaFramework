using System;
using LuaInterface;

public class DelegateFactoryWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Action_GameObject", Action_GameObject),
			new LuaMethod("Action", Action),
			new LuaMethod("UnityEngine_Events_UnityAction", UnityEngine_Events_UnityAction),
			new LuaMethod("System_Reflection_MemberFilter", System_Reflection_MemberFilter),
			new LuaMethod("System_Reflection_TypeFilter", System_Reflection_TypeFilter),
			new LuaMethod("Camera_CameraCallback", Camera_CameraCallback),
			new LuaMethod("Application_AdvertisingIdentifierCallback", Application_AdvertisingIdentifierCallback),
			new LuaMethod("Application_LogCallback", Application_LogCallback),
			new LuaMethod("UICamera_OnScreenResize", UICamera_OnScreenResize),
			new LuaMethod("UICamera_OnCustomInput", UICamera_OnCustomInput),
			new LuaMethod("UIWidget_OnDimensionsChanged", UIWidget_OnDimensionsChanged),
			new LuaMethod("UIWidget_HitCheck", UIWidget_HitCheck),
			new LuaMethod("UIProgressBar_OnDragFinished", UIProgressBar_OnDragFinished),
			new LuaMethod("UILib_SliderValueChangeEventHandler", UILib_SliderValueChangeEventHandler),
			new LuaMethod("UIGrid_OnReposition", UIGrid_OnReposition),
			new LuaMethod("CompareFunc_Transform", CompareFunc_Transform),
			new LuaMethod("UIInput_OnValidate", UIInput_OnValidate),
			new LuaMethod("UIScrollView_OnDragFinished", UIScrollView_OnDragFinished),
			new LuaMethod("UITable_OnReposition", UITable_OnReposition),
			new LuaMethod("UIEventListener_VoidDelegate", UIEventListener_VoidDelegate),
			new LuaMethod("UIEventListener_BoolDelegate", UIEventListener_BoolDelegate),
			new LuaMethod("UIEventListener_FloatDelegate", UIEventListener_FloatDelegate),
			new LuaMethod("UIEventListener_VectorDelegate", UIEventListener_VectorDelegate),
			new LuaMethod("UIEventListener_ObjectDelegate", UIEventListener_ObjectDelegate),
			new LuaMethod("UIEventListener_KeyCodeDelegate", UIEventListener_KeyCodeDelegate),
			new LuaMethod("EventDelegate_Callback", EventDelegate_Callback),
			new LuaMethod("SpringPanel_OnFinished", SpringPanel_OnFinished),
			new LuaMethod("DelManager_GameObjDelegate", DelManager_GameObjDelegate),
			new LuaMethod("UILib_ButtonClickEventHandler", UILib_ButtonClickEventHandler),
			new LuaMethod("UILib_SpriteClickEventHandler", UILib_SpriteClickEventHandler),
			new LuaMethod("UILib_RefreshRenderQueueCb", UILib_RefreshRenderQueueCb),
			new LuaMethod("Clear", Clear),
			new LuaMethod("New", _CreateDelegateFactory),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaScriptMgr.RegisterLib(L, "DelegateFactory", regs);
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateDelegateFactory(IntPtr L)
	{
		LuaDLL.luaL_error(L, "DelegateFactory class does not have a constructor function");
		return 0;
	}

	static Type classType = typeof(DelegateFactory);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Action_GameObject(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.Action_GameObject(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Action(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.Action(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UnityEngine_Events_UnityAction(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UnityEngine_Events_UnityAction(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int System_Reflection_MemberFilter(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.System_Reflection_MemberFilter(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int System_Reflection_TypeFilter(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.System_Reflection_TypeFilter(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Camera_CameraCallback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.Camera_CameraCallback(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Application_AdvertisingIdentifierCallback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.Application_AdvertisingIdentifierCallback(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Application_LogCallback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.Application_LogCallback(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UICamera_OnScreenResize(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UICamera_OnScreenResize(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UICamera_OnCustomInput(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UICamera_OnCustomInput(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIWidget_OnDimensionsChanged(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIWidget_OnDimensionsChanged(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIWidget_HitCheck(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIWidget_HitCheck(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIProgressBar_OnDragFinished(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIProgressBar_OnDragFinished(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UILib_SliderValueChangeEventHandler(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UILib_SliderValueChangeEventHandler(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIGrid_OnReposition(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIGrid_OnReposition(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CompareFunc_Transform(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.CompareFunc_Transform(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIInput_OnValidate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIInput_OnValidate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIScrollView_OnDragFinished(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIScrollView_OnDragFinished(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UITable_OnReposition(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UITable_OnReposition(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIEventListener_VoidDelegate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIEventListener_VoidDelegate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIEventListener_BoolDelegate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIEventListener_BoolDelegate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIEventListener_FloatDelegate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIEventListener_FloatDelegate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIEventListener_VectorDelegate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIEventListener_VectorDelegate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIEventListener_ObjectDelegate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIEventListener_ObjectDelegate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UIEventListener_KeyCodeDelegate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UIEventListener_KeyCodeDelegate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EventDelegate_Callback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.EventDelegate_Callback(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SpringPanel_OnFinished(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.SpringPanel_OnFinished(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DelManager_GameObjDelegate(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.DelManager_GameObjDelegate(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UILib_ButtonClickEventHandler(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UILib_ButtonClickEventHandler(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UILib_SpriteClickEventHandler(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UILib_SpriteClickEventHandler(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UILib_RefreshRenderQueueCb(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		LuaFunction arg0 = LuaScriptMgr.GetLuaFunction(L, 1);
		Delegate o = DelegateFactory.UILib_RefreshRenderQueueCb(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clear(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		DelegateFactory.Clear();
		return 0;
	}
}

