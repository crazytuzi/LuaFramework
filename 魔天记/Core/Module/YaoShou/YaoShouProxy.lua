require "Core.Module.Pattern.Proxy"

YaoShouProxy = Proxy:New();
function YaoShouProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.YaoShouBossInfo, YaoShouProxy.RspInfo);
end

function YaoShouProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.YaoShouBossInfo, YaoShouProxy.RspInfo);
end

function YaoShouProxy.ReqInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.YaoShouBossInfo);
end

function YaoShouProxy.RspInfo(cmd, data)
	if(data ~= nil and data.errCode == nil) then
		YaoShouManager.SetBossData(data);
		MessageManager.Dispatch(YaoShouNotes, YaoShouNotes.RSP_INFO);
	end
end
