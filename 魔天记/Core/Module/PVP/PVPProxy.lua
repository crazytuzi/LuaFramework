require "Core.Module.Pattern.Proxy"

PVPProxy = Proxy:New();
PVPProxy._selectData = nil
function PVPProxy:OnRegister()
	PVPProxy.selectData = nil
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetPVPRank, PVPProxy.GetPVPRankCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.PVPFight, PVPProxy.PVPFightCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetPVPPlayer, PVPProxy.GetPVPPlayerCallBack);
end

function PVPProxy:OnRemove()
	PVPProxy._selectData = nil
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetPVPPlayer, PVPProxy.GetPVPPlayerCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.PVPFight, PVPProxy.PVPFightCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetPVPRank, PVPProxy.GetPVPRankCallBack);
end

function PVPProxy.SetSelectData(data)
	PVPProxy._selectData = data
	ModuleManager.SendNotification(PVPNotes.UPDATE_PVPPANEL_SELECTPLAYER, PVPProxy._selectData)
end

function PVPProxy.SendGetPVPPlayer()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetPVPPlayer);
end

function PVPProxy.GetPVPPlayerCallBack(cmd, data)
	
	if(data and data.errCode == nil) then
		PVPManager.InitData(data)
		ModuleManager.SendNotification(PVPNotes.OPEN_PVPPANEL)
	end
end

function PVPProxy.SendPVPFight()
	
	
	SocketClientLua.Get_ins():SendMessage(CmdType.PVPFight, {i = PVPProxy._selectData.idx});
end

function PVPProxy.PVPFightCallBack(cmd, data)
	
	
	if(data and data.errCode == nil) then
		ModuleManager.SendNotification(PVPNotes.CLOSE_PVPPANEL)
		ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
		
		GameSceneManager.GotoScene(705000)
		PVPManager.SetOldPVPRank()
		
	else
		
	end
end

function PVPProxy.SendGetPVPRank(index)
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetPVPRank, {p = index});
end

function PVPProxy.GetPVPRankCallBack(cmd, data)
	if(data and data.errCode == nil) then
		PVPManager.SetPVPRankData(data)
		ModuleManager.SendNotification(PVPNotes.UPDATE_PVPRANKPANEL)
	else
		
	end
end

function PVPProxy.BuyPVPTime()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.BuyPVPTime, PVPProxy.BuyPVPTimeCallBack);
	SocketClientLua.Get_ins():SendMessage(CmdType.BuyPVPTime, {});
	-- local needMoneyConf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BUYPVPTIME)
	-- local needMoney = needMoneyConf[PVPManager.GetPVPBuyTime() + 1].need_money
	-- if(MoneyDataManager.Get_gold() >= needMoney) then
	-- 	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.BuyPVPTime, PVPProxy.BuyPVPTimeCallBack);
	-- 	SocketClientLua.Get_ins():SendMessage(CmdType.BuyPVPTime, {});
	-- else
	-- 	MsgUtils.ShowTips("pvp/pvpPanel/common/xianyubuzu");
	-- end
end

function PVPProxy.BuyPVPTimeCallBack(cmd, data)
	if(data and data.errCode == nil) then
		MsgUtils.ShowTips("pvp/pvpPanel/buySuccess");
		PVPManager.UpdatePVPBuyTime(data.bt)
		PVPManager.UpdatePVPLimitTime(data.t)
	end
end
