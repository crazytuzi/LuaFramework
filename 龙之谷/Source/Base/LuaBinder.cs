using System;
using System.Collections.Generic;

public static class LuaBinder
{
	public static List<string> wrapList = new List<string>();
	public static void Bind(IntPtr L, string type = null)
	{
		if (type == null || wrapList.Contains(type)) return;
		wrapList.Add(type); type += "Wrap";
		switch (type) {
			case "AppConstWrap": AppConstWrap.Register(L); break;
			case "ApplicationWrap": ApplicationWrap.Register(L); break;
			case "AssetBundleWrap": AssetBundleWrap.Register(L); break;
			case "BehaviourWrap": BehaviourWrap.Register(L); break;
			case "BoxColliderWrap": BoxColliderWrap.Register(L); break;
			case "CameraWrap": CameraWrap.Register(L); break;
			case "ColliderWrap": ColliderWrap.Register(L); break;
			case "ComponentWrap": ComponentWrap.Register(L); break;
			case "DebuggerWrap": DebuggerWrap.Register(L); break;
			case "DelegateFactoryWrap": DelegateFactoryWrap.Register(L); break;
			case "DelegateWrap": DelegateWrap.Register(L); break;
			case "DelManagerWrap": DelManagerWrap.Register(L); break;
			case "EnumWrap": EnumWrap.Register(L); break;
			case "EventDelegateWrap": EventDelegateWrap.Register(L); break;
			case "GameObjectWrap": GameObjectWrap.Register(L); break;
			case "HotfixManagerWrap": HotfixManagerWrap.Register(L); break;
			case "HotfixWrap": HotfixWrap.Register(L); break;
			case "IEnumeratorWrap": IEnumeratorWrap.Register(L); break;
			case "InputWrap": InputWrap.Register(L); break;
			case "LocalizationWrap": LocalizationWrap.Register(L); break;
			case "LuaDlgWrap": LuaDlgWrap.Register(L); break;
			case "LuaEngineWrap": LuaEngineWrap.Register(L); break;
			case "LuaEnumTypeWrap": LuaEnumTypeWrap.Register(L); break;
			case "LuaGameInfoWrap": LuaGameInfoWrap.Register(L); break;
			case "LuaStringBufferWrap": LuaStringBufferWrap.Register(L); break;
			case "LuaUIManagerWrap": LuaUIManagerWrap.Register(L); break;
			case "MonoBehaviourWrap": MonoBehaviourWrap.Register(L); break;
			case "NGUIToolsWrap": NGUIToolsWrap.Register(L); break;
			case "ObjectWrap": ObjectWrap.Register(L); break;
			case "PlayerPrefsWrap": PlayerPrefsWrap.Register(L); break;
			case "PrivateExtensionsWrap": PrivateExtensionsWrap.Register(L); break;
			case "PublicExtensionsWrap": PublicExtensionsWrap.Register(L); break;
			case "ScreenWrap": ScreenWrap.Register(L); break;
			case "stringWrap": stringWrap.Register(L); break;
			case "System_IO_BinaryReaderWrap": System_IO_BinaryReaderWrap.Register(L); break;
			case "System_ObjectWrap": System_ObjectWrap.Register(L); break;
			case "TestProtolWrap": TestProtolWrap.Register(L); break;
			case "TimeWrap": TimeWrap.Register(L); break;
			case "TransformWrap": TransformWrap.Register(L); break;
			case "TypeWrap": TypeWrap.Register(L); break;
			case "UIAtlasWrap": UIAtlasWrap.Register(L); break;
			case "UIButtonColorWrap": UIButtonColorWrap.Register(L); break;
			case "UIButtonWrap": UIButtonWrap.Register(L); break;
			case "UICameraWrap": UICameraWrap.Register(L); break;
			case "UICenterOnChildWrap": UICenterOnChildWrap.Register(L); break;
			case "UIDummyWrap": UIDummyWrap.Register(L); break;
			case "UIEventListenerWrap": UIEventListenerWrap.Register(L); break;
			case "UIGridWrap": UIGridWrap.Register(L); break;
			case "UIInputWrap": UIInputWrap.Register(L); break;
			case "UILabelWrap": UILabelWrap.Register(L); break;
			case "UIProgressBarWrap": UIProgressBarWrap.Register(L); break;
			case "UIRectWrap": UIRectWrap.Register(L); break;
			case "UIScrollViewWrap": UIScrollViewWrap.Register(L); break;
			case "UISliderWrap": UISliderWrap.Register(L); break;
			case "UISpriteWrap": UISpriteWrap.Register(L); break;
			case "UITableWrap": UITableWrap.Register(L); break;
			case "UITextureWrap": UITextureWrap.Register(L); break;
			case "UIToggleWrap": UIToggleWrap.Register(L); break;
			case "UIWidgetContainerWrap": UIWidgetContainerWrap.Register(L); break;
			case "UIWidgetWrap": UIWidgetWrap.Register(L); break;
			case "XUtliPoolLib_XDirectoryWrap": XUtliPoolLib_XDirectoryWrap.Register(L); break;
			case "XUtliPoolLib_XFileWrap": XUtliPoolLib_XFileWrap.Register(L); break;
			case "XUtliPoolLib_XLuaLongWrap": XUtliPoolLib_XLuaLongWrap.Register(L); break;
		}
	}
}
