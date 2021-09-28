require "Core.Module.Pattern.Proxy"

XuanBaoProxy = Proxy:New();
function XuanBaoProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XuanBaoInfo, XuanBaoProxy.RspInfo);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XuanBaoStatusChg, XuanBaoProxy.RspStatus);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XuanBaoAward, XuanBaoProxy.RspGetAward);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.XuanBaoFullAward, XuanBaoProxy.RspGetDayAward);
end

function XuanBaoProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XuanBaoInfo, XuanBaoProxy.RspInfo);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XuanBaoStatusChg, XuanBaoProxy.RspStatus);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XuanBaoAward, XuanBaoProxy.RspGetAward);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.XuanBaoFullAward, XuanBaoProxy.RspGetDayAward);
end

function XuanBaoProxy.ReqInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.XuanBaoInfo);
end

function XuanBaoProxy.RspInfo(cmd, data)
	if(data ~= nil and data.errCode == nil) then
		XuanBaoManager.Init(data);
	end
end

--奖励状态更新
function XuanBaoProxy.RspStatus(cmd, data)
	XuanBaoManager.SetNotify(data);
end

function XuanBaoProxy.ReqGetAward(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.XuanBaoAward, {id = id});
end

function XuanBaoProxy.RspGetAward(cmd, data)
	if(data ~= nil and data.errCode == nil) then
		XuanBaoManager.SetAwardStatus(data.id, 2);
	end
end

function XuanBaoProxy.ReqGetDayAward(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.XuanBaoFullAward, {id = id});
end

function XuanBaoProxy.RspGetDayAward(cmd, data)
	if(data ~= nil and data.errCode == nil) then
		XuanBaoManager.SetData(data);
		XuanBaoManager.hasAward = false;
		MessageManager.Dispatch(XuanBaoNotes, XuanBaoNotes.RSP_AWARD_CHG);
		--MessageManager.Dispatch(XuanBaoNotes, XuanBaoNotes.RSP_TYPE_AWARD_CHG);
	end
end