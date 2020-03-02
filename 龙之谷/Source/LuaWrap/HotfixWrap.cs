using System;
using UnityEngine;
using LuaInterface;

public class HotfixWrap
{
	public static void Register(IntPtr L)
	{
		LuaMethod[] regs = new LuaMethod[]
		{
			new LuaMethod("Init", Init),
			new LuaMethod("LuaWait", LuaWait),
			new LuaMethod("LuaLoop", LuaLoop),
			new LuaMethod("RemoveTimer", RemoveTimer),
			new LuaMethod("SendLuaPtc", SendLuaPtc),
			new LuaMethod("SendLuaBytePtc", SendLuaBytePtc),
			new LuaMethod("RegistNotifyID", RegistNotifyID),
			new LuaMethod("RegistPtc", RegistPtc),
			new LuaMethod("RegisterLuaRPC", RegisterLuaRPC),
			new LuaMethod("SendLuaRPC", SendLuaRPC),
			new LuaMethod("SendLuaRPCWithReq", SendLuaRPCWithReq),
			new LuaMethod("SendLuaByteRPC", SendLuaByteRPC),
			new LuaMethod("SendLuaByteRPCWithReq", SendLuaByteRPCWithReq),
			new LuaMethod("LuaMessageBoxConfirm", LuaMessageBoxConfirm),
			new LuaMethod("LuaShowSystemTip", LuaShowSystemTip),
			new LuaMethod("LuaShowSystemTipErrCode", LuaShowSystemTipErrCode),
			new LuaMethod("LuaShowItemAccess", LuaShowItemAccess),
			new LuaMethod("LuaShowItemTooltipDialog", LuaShowItemTooltipDialog),
			new LuaMethod("LuaShowDetailTooltipDialog", LuaShowDetailTooltipDialog),
			new LuaMethod("LuaShowItemTooltipDialogByUID", LuaShowItemTooltipDialogByUID),
			new LuaMethod("SetPlayer", SetPlayer),
			new LuaMethod("GetPlayer", GetPlayer),
			new LuaMethod("CallPlayerMethod", CallPlayerMethod),
			new LuaMethod("GetDocument", GetDocument),
			new LuaMethod("SetDocumentMember", SetDocumentMember),
			new LuaMethod("GetDocumentMember", GetDocumentMember),
			new LuaMethod("GetGetDocumentLongMember", GetGetDocumentLongMember),
			new LuaMethod("GetDocumentStaticMember", GetDocumentStaticMember),
			new LuaMethod("CallDocumentMethod", CallDocumentMethod),
			new LuaMethod("CallDocumentLongMethod", CallDocumentLongMethod),
			new LuaMethod("CallDocumentStaticMethod", CallDocumentStaticMethod),
			new LuaMethod("GetSingle", GetSingle),
			new LuaMethod("GetSingleMember", GetSingleMember),
			new LuaMethod("GetSingleLongMember", GetSingleLongMember),
			new LuaMethod("SetSingleMember", SetSingleMember),
			new LuaMethod("CallSingleMethod", CallSingleMethod),
			new LuaMethod("CallSingleLongMethod", CallSingleLongMethod),
			new LuaMethod("GetEnumType", GetEnumType),
			new LuaMethod("GetStringTable", GetStringTable),
			new LuaMethod("GetGlobalString", GetGlobalString),
			new LuaMethod("GetObjectString", GetObjectString),
			new LuaMethod("GetLuaLong", GetLuaLong),
			new LuaMethod("RefreshPlayerName", RefreshPlayerName),
			new LuaMethod("OpenSys", OpenSys),
			new LuaMethod("AttachSysRedPointRelative", AttachSysRedPointRelative),
			new LuaMethod("AttachSysRedPointRelativeUI", AttachSysRedPointRelativeUI),
			new LuaMethod("DetachSysRedPointRelative", DetachSysRedPointRelative),
			new LuaMethod("DetachSysRedPointRelativeUI", DetachSysRedPointRelativeUI),
			new LuaMethod("ForceUpdateSysRedPointImmediately", ForceUpdateSysRedPointImmediately),
			new LuaMethod("GetSysRedPointState", GetSysRedPointState),
			new LuaMethod("LuaDoFile", LuaDoFile),
			new LuaMethod("LuaGetFunction", LuaGetFunction),
			new LuaMethod("LuaTableBuffer", LuaTableBuffer),
			new LuaMethod("LuaTableBin", LuaTableBin),
			new LuaMethod("ReturnableStream", ReturnableStream),
			new LuaMethod("ReadFileSize", ReadFileSize),
			new LuaMethod("CheckFileSize", CheckFileSize),
			new LuaMethod("ReadRowSize", ReadRowSize),
			new LuaMethod("CheckRowSize", CheckRowSize),
			new LuaMethod("ReadDataHandle", ReadDataHandle),
			new LuaMethod("ReadSeqHead", ReadSeqHead),
			new LuaMethod("ReadSeqListHead", ReadSeqListHead),
			new LuaMethod("ReadInt", ReadInt),
			new LuaMethod("ReadUInt", ReadUInt),
			new LuaMethod("ReadLong", ReadLong),
			new LuaMethod("ReadFloat", ReadFloat),
			new LuaMethod("ReadDouble", ReadDouble),
			new LuaMethod("ReadString", ReadString),
			new LuaMethod("LuaProtoBuffer", LuaProtoBuffer),
			new LuaMethod("LuaProtoBuffer1", LuaProtoBuffer1),
			new LuaMethod("SetClickCallback", SetClickCallback),
			new LuaMethod("SetPressCallback", SetPressCallback),
			new LuaMethod("SetDragCallback", SetDragCallback),
			new LuaMethod("SetSubmmitCallback", SetSubmmitCallback),
			new LuaMethod("InitWrapContent", InitWrapContent),
			new LuaMethod("SetWrapContentCount", SetWrapContentCount),
			new LuaMethod("SetupPool", SetupPool),
			new LuaMethod("DrawItemView", DrawItemView),
			new LuaMethod("SetTexture", SetTexture),
			new LuaMethod("DestoryTexture", DestoryTexture),
			new LuaMethod("EnableMainDummy", EnableMainDummy),
			new LuaMethod("SetMainDummy", SetMainDummy),
			new LuaMethod("ResetMainAnimation", ResetMainAnimation),
			new LuaMethod("CreateCommonDummy", CreateCommonDummy),
			new LuaMethod("SetDummyAnim", SetDummyAnim),
			new LuaMethod("SetMainDummyAnim", SetMainDummyAnim),
			new LuaMethod("DestroyDummy", DestroyDummy),
			new LuaMethod("ParseIntSeqList", ParseIntSeqList),
			new LuaMethod("ParseUIntSeqList", ParseUIntSeqList),
			new LuaMethod("ParseFloatSeqList", ParseFloatSeqList),
			new LuaMethod("ParseDoubleSeqList", ParseDoubleSeqList),
			new LuaMethod("ParseStringSeqList", ParseStringSeqList),
			new LuaMethod("TransInt64", TransInt64),
			new LuaMethod("TansString", TansString),
			new LuaMethod("OpInit64", OpInit64),
			new LuaMethod("PrintBytes", PrintBytes),
			new LuaMethod("New", _CreateHotfix),
			new LuaMethod("GetClassType", GetClassType),
		};

		LuaField[] fields = new LuaField[]
		{
			new LuaField("m_uiUtility", get_m_uiUtility, set_m_uiUtility),
			new LuaField("startOffset", get_startOffset, set_startOffset),
			new LuaField("count", get_count, set_count),
			new LuaField("allSameMask", get_allSameMask, set_allSameMask),
			new LuaField("luaExtion", get_luaExtion, null),
			new LuaField("GameSysMgr", get_GameSysMgr, null),
			new LuaField("onlineReTime", get_onlineReTime, null),
		};

		LuaScriptMgr.RegisterLib(L, "Hotfix", typeof(Hotfix), regs, fields, typeof(object));
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateHotfix(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 0)
		{
			Hotfix obj = new Hotfix();
			LuaScriptMgr.PushObject(L, obj);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.New");
		}

		return 0;
	}

	static Type classType = typeof(Hotfix);

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetClassType(IntPtr L)
	{
		LuaScriptMgr.Push(L, classType);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_uiUtility(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, Hotfix.m_uiUtility);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startOffset(IntPtr L)
	{
		LuaScriptMgr.Push(L, Hotfix.startOffset);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_count(IntPtr L)
	{
		LuaScriptMgr.Push(L, Hotfix.count);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_allSameMask(IntPtr L)
	{
		LuaScriptMgr.Push(L, Hotfix.allSameMask);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_luaExtion(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, Hotfix.luaExtion);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_GameSysMgr(IntPtr L)
	{
		LuaScriptMgr.PushObject(L, Hotfix.GameSysMgr);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onlineReTime(IntPtr L)
	{
		LuaScriptMgr.Push(L, Hotfix.onlineReTime);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_uiUtility(IntPtr L)
	{
		Hotfix.m_uiUtility = (XUtliPoolLib.IUiUtility)LuaScriptMgr.GetNetObject(L, 3, typeof(XUtliPoolLib.IUiUtility));
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startOffset(IntPtr L)
	{
		Hotfix.startOffset = (ushort)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_count(IntPtr L)
	{
		Hotfix.count = (byte)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_allSameMask(IntPtr L)
	{
		Hotfix.allSameMask = (byte)LuaScriptMgr.GetNumber(L, 3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Init(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		Action arg0 = null;
		LuaTypes funcType1 = LuaDLL.lua_type(L, 1);

		if (funcType1 != LuaTypes.LUA_TFUNCTION)
		{
			 arg0 = (Action)LuaScriptMgr.GetNetObject(L, 1, typeof(Action));
		}
		else
		{
			LuaFunction func = LuaScriptMgr.GetLuaFunction(L, 1);
			arg0 = () =>
			{
				func.Call();
			};
		}

		Hotfix.Init(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaWait(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		LuaFunction arg1 = LuaScriptMgr.GetLuaFunction(L, 2);
		int o = Hotfix.LuaWait(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaLoop(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		LuaFunction arg2 = LuaScriptMgr.GetLuaFunction(L, 3);
		int o = Hotfix.LuaLoop(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveTimer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		Hotfix.RemoveTimer(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendLuaPtc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 1);
		LuaStringBuffer arg1 = LuaScriptMgr.GetStringBuffer(L, 2);
		bool o = Hotfix.SendLuaPtc(arg0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendLuaBytePtc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 1);
		byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
		bool o = Hotfix.SendLuaBytePtc(arg0,objs1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RegistNotifyID(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		Hotfix.RegistNotifyID();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RegistPtc(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 1);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		Hotfix.RegistPtc(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RegisterLuaRPC(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 1);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		LuaFunction arg2 = LuaScriptMgr.GetLuaFunction(L, 3);
		LuaFunction arg3 = LuaScriptMgr.GetLuaFunction(L, 4);
		Hotfix.RegisterLuaRPC(arg0,arg1,arg2,arg3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendLuaRPC(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 1);
		LuaStringBuffer arg1 = LuaScriptMgr.GetStringBuffer(L, 2);
		LuaFunction arg2 = LuaScriptMgr.GetLuaFunction(L, 3);
		LuaFunction arg3 = LuaScriptMgr.GetLuaFunction(L, 4);
		Hotfix.SendLuaRPC(arg0,arg1,arg2,arg3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendLuaRPCWithReq(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 1);
		LuaStringBuffer arg1 = LuaScriptMgr.GetStringBuffer(L, 2);
		LuaFunction arg2 = LuaScriptMgr.GetLuaFunction(L, 3);
		LuaFunction arg3 = LuaScriptMgr.GetLuaFunction(L, 4);
		Hotfix.SendLuaRPCWithReq(arg0,arg1,arg2,arg3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendLuaByteRPC(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 1);
		byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
		LuaFunction arg2 = LuaScriptMgr.GetLuaFunction(L, 3);
		LuaFunction arg3 = LuaScriptMgr.GetLuaFunction(L, 4);
		Hotfix.SendLuaByteRPC(arg0,objs1,arg2,arg3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SendLuaByteRPCWithReq(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		uint arg0 = (uint)LuaScriptMgr.GetNumber(L, 1);
		byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
		LuaFunction arg2 = LuaScriptMgr.GetLuaFunction(L, 3);
		LuaFunction arg3 = LuaScriptMgr.GetLuaFunction(L, 4);
		Hotfix.SendLuaByteRPCWithReq(arg0,objs1,arg2,arg3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaMessageBoxConfirm(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		LuaFunction arg1 = LuaScriptMgr.GetLuaFunction(L, 2);
		LuaFunction arg2 = LuaScriptMgr.GetLuaFunction(L, 3);
		Hotfix.LuaMessageBoxConfirm(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaShowSystemTip(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		Hotfix.LuaShowSystemTip(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaShowSystemTipErrCode(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		Hotfix.LuaShowSystemTipErrCode(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaShowItemAccess(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		Hotfix.LuaShowItemAccess(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaShowItemTooltipDialog(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		GameObject arg1 = (GameObject)LuaScriptMgr.GetUnityObject(L, 2, typeof(GameObject));
		Hotfix.LuaShowItemTooltipDialog(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaShowDetailTooltipDialog(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		GameObject arg1 = (GameObject)LuaScriptMgr.GetUnityObject(L, 2, typeof(GameObject));
		Hotfix.LuaShowDetailTooltipDialog(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaShowItemTooltipDialogByUID(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		GameObject arg1 = (GameObject)LuaScriptMgr.GetUnityObject(L, 2, typeof(GameObject));
		Hotfix.LuaShowItemTooltipDialogByUID(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPlayer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		Hotfix.SetPlayer(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPlayer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		object o = Hotfix.GetPlayer(arg0);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallPlayerMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		bool arg0 = LuaScriptMgr.GetBoolean(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object[] objs2 = LuaScriptMgr.GetParamsObject(L, 3, count - 2);
		object o = Hotfix.CallPlayerMethod(arg0,arg1,objs2);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDocument(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		object o = Hotfix.GetDocument(arg0);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDocumentMember(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 5);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
		bool arg4 = LuaScriptMgr.GetBoolean(L, 5);
		Hotfix.SetDocumentMember(arg0,arg1,arg2,arg3,arg4);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDocumentMember(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
		object o = Hotfix.GetDocumentMember(arg0,arg1,arg2,arg3);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetGetDocumentLongMember(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
		string o = Hotfix.GetGetDocumentLongMember(arg0,arg1,arg2,arg3);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDocumentStaticMember(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
		object o = Hotfix.GetDocumentStaticMember(arg0,arg1,arg2,arg3);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallDocumentMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		string arg2 = LuaScriptMgr.GetLuaString(L, 3);
		object[] objs3 = LuaScriptMgr.GetParamsObject(L, 4, count - 3);
		object o = Hotfix.CallDocumentMethod(arg0,arg1,arg2,objs3);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallDocumentLongMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		string arg2 = LuaScriptMgr.GetLuaString(L, 3);
		object[] objs3 = LuaScriptMgr.GetParamsObject(L, 4, count - 3);
		string o = Hotfix.CallDocumentLongMethod(arg0,arg1,arg2,objs3);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallDocumentStaticMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		string arg2 = LuaScriptMgr.GetLuaString(L, 3);
		object[] objs3 = LuaScriptMgr.GetParamsObject(L, 4, count - 3);
		object o = Hotfix.CallDocumentStaticMethod(arg0,arg1,arg2,objs3);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSingle(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		object o = Hotfix.GetSingle(arg0);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSingleMember(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 5);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
		bool arg4 = LuaScriptMgr.GetBoolean(L, 5);
		object o = Hotfix.GetSingleMember(arg0,arg1,arg2,arg3,arg4);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSingleLongMember(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 5);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
		bool arg4 = LuaScriptMgr.GetBoolean(L, 5);
		string o = Hotfix.GetSingleLongMember(arg0,arg1,arg2,arg3,arg4);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetSingleMember(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 6);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object arg2 = LuaScriptMgr.GetVarObject(L, 3);
		bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
		bool arg4 = LuaScriptMgr.GetBoolean(L, 5);
		bool arg5 = LuaScriptMgr.GetBoolean(L, 6);
		Hotfix.SetSingleMember(arg0,arg1,arg2,arg3,arg4,arg5);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallSingleMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		string arg3 = LuaScriptMgr.GetLuaString(L, 4);
		object[] objs4 = LuaScriptMgr.GetParamsObject(L, 5, count - 4);
		object o = Hotfix.CallSingleMethod(arg0,arg1,arg2,arg3,objs4);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallSingleLongMethod(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		string arg3 = LuaScriptMgr.GetLuaString(L, 4);
		object[] objs4 = LuaScriptMgr.GetParamsObject(L, 5, count - 4);
		string o = Hotfix.CallSingleLongMethod(arg0,arg1,arg2,arg3,objs4);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetEnumType(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		object o = Hotfix.GetEnumType(arg0,arg1);
		LuaScriptMgr.PushVarObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetStringTable(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		object[] objs1 = LuaScriptMgr.GetParamsObject(L, 2, count - 1);
		string o = Hotfix.GetStringTable(arg0,objs1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetGlobalString(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string o = Hotfix.GetGlobalString(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetObjectString(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 2)
		{
			object arg0 = LuaScriptMgr.GetVarObject(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			string o = Hotfix.GetObjectString(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 4)
		{
			object arg0 = LuaScriptMgr.GetVarObject(L, 1);
			string arg1 = LuaScriptMgr.GetLuaString(L, 2);
			bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
			bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
			string o = Hotfix.GetObjectString(arg0,arg1,arg2,arg3);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.GetObjectString");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLuaLong(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		XUtliPoolLib.XLuaLong o = Hotfix.GetLuaLong(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RefreshPlayerName(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		Hotfix.RefreshPlayerName();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenSys(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		bool o = Hotfix.OpenSys(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AttachSysRedPointRelative(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		Hotfix.AttachSysRedPointRelative(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AttachSysRedPointRelativeUI(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		GameObject arg1 = (GameObject)LuaScriptMgr.GetUnityObject(L, 2, typeof(GameObject));
		Hotfix.AttachSysRedPointRelativeUI(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DetachSysRedPointRelative(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		Hotfix.DetachSysRedPointRelative(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DetachSysRedPointRelativeUI(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		Hotfix.DetachSysRedPointRelativeUI(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ForceUpdateSysRedPointImmediately(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		bool arg1 = LuaScriptMgr.GetBoolean(L, 2);
		Hotfix.ForceUpdateSysRedPointImmediately(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSysRedPointState(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		bool o = Hotfix.GetSysRedPointState(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaDoFile(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		Hotfix.LuaDoFile(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaGetFunction(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		LuaInterface.LuaFunction o = Hotfix.LuaGetFunction(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaTableBuffer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string o = Hotfix.LuaTableBuffer(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaTableBin(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		System.IO.BinaryReader o = Hotfix.LuaTableBin(arg0);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReturnableStream(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.BinaryReader));
		Hotfix.ReturnableStream(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadFileSize(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.BinaryReader));
		Hotfix.ReadFileSize(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CheckFileSize(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.BinaryReader));
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		Hotfix.CheckFileSize(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadRowSize(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.BinaryReader));
		Hotfix.ReadRowSize(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CheckRowSize(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.BinaryReader));
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
		Hotfix.CheckRowSize(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadDataHandle(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.BinaryReader));
		Hotfix.ReadDataHandle(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadSeqHead(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.BinaryReader));
		Hotfix.ReadSeqHead(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadSeqListHead(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetNetObject(L, 1, typeof(System.IO.BinaryReader));
		int o = Hotfix.ReadSeqListHead(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadInt(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			int o = Hotfix.ReadInt(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			int o = Hotfix.ReadInt(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.ReadInt");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadUInt(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			uint o = Hotfix.ReadUInt(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			uint o = Hotfix.ReadUInt(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.ReadUInt");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadLong(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(int)))
		{
			int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
			string o = Hotfix.ReadLong(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(System.IO.BinaryReader)))
		{
			System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetLuaObject(L, 1);
			string o = Hotfix.ReadLong(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			string o = Hotfix.ReadLong(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.ReadLong");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadFloat(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			float o = Hotfix.ReadFloat(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			float o = Hotfix.ReadFloat(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.ReadFloat");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadDouble(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			double o = Hotfix.ReadDouble(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			double o = Hotfix.ReadDouble(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.ReadDouble");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadString(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(System.IO.BinaryReader)))
		{
			System.IO.BinaryReader arg0 = (System.IO.BinaryReader)LuaScriptMgr.GetLuaObject(L, 1);
			string o = Hotfix.ReadString(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 1 && LuaScriptMgr.CheckTypes(L, 1, typeof(int)))
		{
			int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
			string o = Hotfix.ReadString(arg0);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else if (count == 2)
		{
			int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
			int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
			string o = Hotfix.ReadString(arg0,arg1);
			LuaScriptMgr.Push(L, o);
			return 1;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.ReadString");
		}

		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaProtoBuffer(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		LuaStringBuffer o = Hotfix.LuaProtoBuffer(objs0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaProtoBuffer1(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		LuaStringBuffer o = Hotfix.LuaProtoBuffer1(objs0,arg1);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetClickCallback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		LuaFunction arg1 = LuaScriptMgr.GetLuaFunction(L, 2);
		Hotfix.SetClickCallback(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPressCallback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		LuaFunction arg1 = LuaScriptMgr.GetLuaFunction(L, 2);
		Hotfix.SetPressCallback(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDragCallback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		LuaFunction arg1 = LuaScriptMgr.GetLuaFunction(L, 2);
		Hotfix.SetDragCallback(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetSubmmitCallback(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		LuaFunction arg1 = LuaScriptMgr.GetLuaFunction(L, 2);
		Hotfix.SetSubmmitCallback(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InitWrapContent(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		LuaFunction arg1 = LuaScriptMgr.GetLuaFunction(L, 2);
		Hotfix.InitWrapContent(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetWrapContentCount(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		Hotfix.SetWrapContentCount(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetupPool(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		GameObject arg1 = (GameObject)LuaScriptMgr.GetUnityObject(L, 2, typeof(GameObject));
		uint arg2 = (uint)LuaScriptMgr.GetNumber(L, 3);
		XUtliPoolLib.XUIPool o = Hotfix.SetupPool(arg0,arg1,arg2);
		LuaScriptMgr.PushObject(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DrawItemView(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		GameObject arg0 = (GameObject)LuaScriptMgr.GetUnityObject(L, 1, typeof(GameObject));
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
		bool arg3 = LuaScriptMgr.GetBoolean(L, 4);
		Hotfix.DrawItemView(arg0,arg1,arg2,arg3);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetTexture(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		UITexture arg0 = (UITexture)LuaScriptMgr.GetUnityObject(L, 1, typeof(UITexture));
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		bool arg2 = LuaScriptMgr.GetBoolean(L, 3);
		Hotfix.SetTexture(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DestoryTexture(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		UITexture arg0 = (UITexture)LuaScriptMgr.GetUnityObject(L, 1, typeof(UITexture));
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		Hotfix.DestoryTexture(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableMainDummy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		bool arg0 = LuaScriptMgr.GetBoolean(L, 1);
		UIDummy arg1 = (UIDummy)LuaScriptMgr.GetUnityObject(L, 2, typeof(UIDummy));
		Hotfix.EnableMainDummy(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMainDummy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		bool arg0 = LuaScriptMgr.GetBoolean(L, 1);
		Hotfix.SetMainDummy(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetMainAnimation(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 0);
		Hotfix.ResetMainAnimation();
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateCommonDummy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		uint arg1 = (uint)LuaScriptMgr.GetNumber(L, 2);
		UILib.IUIDummy arg2 = (UILib.IUIDummy)LuaScriptMgr.GetNetObject(L, 3, typeof(UILib.IUIDummy));
		float arg3 = (float)LuaScriptMgr.GetNumber(L, 4);
		string o = Hotfix.CreateCommonDummy(arg0,arg1,arg2,arg3);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDummyAnim(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 4);
		Hotfix obj = (Hotfix)LuaScriptMgr.GetNetObjectSelf(L, 1, "Hotfix");
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 2);
		string arg1 = LuaScriptMgr.GetLuaString(L, 3);
		string arg2 = LuaScriptMgr.GetLuaString(L, 4);
		obj.SetDummyAnim(arg0,arg1,arg2);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMainDummyAnim(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		Hotfix obj = (Hotfix)LuaScriptMgr.GetNetObjectSelf(L, 1, "Hotfix");
		string arg0 = LuaScriptMgr.GetLuaString(L, 2);
		obj.SetMainDummyAnim(arg0);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DestroyDummy(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 2);
		int arg0 = (int)LuaScriptMgr.GetNumber(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		Hotfix.DestroyDummy(arg0,arg1);
		return 0;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ParseIntSeqList(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
		int o = Hotfix.ParseIntSeqList(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ParseUIntSeqList(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
		uint o = Hotfix.ParseUIntSeqList(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ParseFloatSeqList(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
		float o = Hotfix.ParseFloatSeqList(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ParseDoubleSeqList(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
		double o = Hotfix.ParseDoubleSeqList(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ParseStringSeqList(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		object arg0 = LuaScriptMgr.GetVarObject(L, 1);
		int arg1 = (int)LuaScriptMgr.GetNumber(L, 2);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
		string o = Hotfix.ParseStringSeqList(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TransInt64(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		ulong o = Hotfix.TransInt64(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TansString(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 1);
		ulong arg0 = (ulong)LuaScriptMgr.GetNumber(L, 1);
		string o = Hotfix.TansString(arg0);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpInit64(IntPtr L)
	{
		LuaScriptMgr.CheckArgsCount(L, 3);
		string arg0 = LuaScriptMgr.GetLuaString(L, 1);
		string arg1 = LuaScriptMgr.GetLuaString(L, 2);
		int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
		string o = Hotfix.OpInit64(arg0,arg1,arg2);
		LuaScriptMgr.Push(L, o);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PrintBytes(IntPtr L)
	{
		int count = LuaDLL.lua_gettop(L);

		if (count == 1)
		{
			byte[] objs0 = LuaScriptMgr.GetArrayNumber<byte>(L, 1);
			Hotfix.PrintBytes(objs0);
			return 0;
		}
		else if (count == 2)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
			Hotfix.PrintBytes(arg0,objs1);
			return 0;
		}
		else if (count == 3)
		{
			string arg0 = LuaScriptMgr.GetLuaString(L, 1);
			byte[] objs1 = LuaScriptMgr.GetArrayNumber<byte>(L, 2);
			int arg2 = (int)LuaScriptMgr.GetNumber(L, 3);
			Hotfix.PrintBytes(arg0,objs1,arg2);
			return 0;
		}
		else
		{
			LuaDLL.luaL_error(L, "invalid arguments to method: Hotfix.PrintBytes");
		}

		return 0;
	}
}

