require "Core.Module.Pattern.Proxy"

WildBossProxy = Proxy:New();
WildBossProxy.isRefreshBossHurt = false;
WildBossProxy.to = nil
function WildBossProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WildBossInfos, WildBossProxy._WildBossInfosHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WildBossHeroRank, WildBossProxy._WildBossHeroRankHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WildBossHurtRank, WildBossProxy._WildBossHurtRankHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CheckLine, WildBossProxy._CheckLineHandler, self);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WildBossVipInfo, WildBossProxy._RspVipBossInfo);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WildBossVipHistory, WildBossProxy._RspHistory);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WildBossVipHurtRank, WildBossProxy._RspHurtRankList);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WildBossVipInfoChg, WildBossProxy._RspBossInfoChg);
	
end

function WildBossProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WildBossInfos, WildBossProxy._WildBossInfosHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WildBossHeroRank, WildBossProxy._WildBossHeroRankHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WildBossHurtRank, WildBossProxy._WildBossHurtRankHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.CheckLine, WildBossProxy._CheckLineHandler, self);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WildBossVipInfo, WildBossProxy._RspVipBossInfo);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WildBossVipHistory, WildBossProxy._RspHistory);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WildBossVipHurtRank, WildBossProxy._RspHurtRankList);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WildBossVipInfoChg, WildBossProxy._RspBossInfoChg);
end

function WildBossProxy:_WildBossInfosHandler(cmd, data)
	if(data and data.errCode == nil) then
		WildBossManager.SetWildBossData(data)
		ModuleManager.SendNotification(WildBossNotes.UPDATE_WILDBOSSPANEL)
	end
end

function WildBossProxy:_WildBossHeroRankHandler(cmd, data)
	if(data and data.errCode == nil) then
		ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSRANKPANEL, data)
	end
	
end


function WildBossProxy:_WildBossHurtRankHandler(cmd, data)
	if(WildBossProxy.isRefreshBossHurt) then
		ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSHURTRANKPANEL, data);
		WildBossProxy.isRefreshBossHurt = false;
	end
end


function WildBossProxy.RefreshBossInfos()
	SocketClientLua.Get_ins():SendMessage(CmdType.WildBossInfos, {});
end

function WildBossProxy.RefreshBossHeroRank(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.WildBossHeroRank, {id = id});
end

function WildBossProxy.RefreshBossHurtRank(id)
	local map_type = GameSceneManager.map.info.type;
	if map_type == InstanceDataManager.MapType.VipWildBoss then
		WildBossProxy.ReqHurtRankList(id);
	else
		local data = {};
		data.mid = id;
		WildBossProxy.isRefreshBossHurt = true;
		SocketClientLua.Get_ins():SendMessage(CmdType.WildBossHurtRank, data);
	end
end

function WildBossProxy:_CheckLineHandler(cmd, data)	
	if(data and data.errCode == nil) then
		if(data.f == 1) then
			-- GameSceneManager.to = WildBossProxy.to			
			MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, WildBossProxy.MotoPos, self);
			
			GameSceneManager.GotoScene(data.tsi, data.ln,WildBossProxy.to)
			
			ModuleManager.SendNotification(YaoShouNotes.CLOSE_YAOSHOUPANEL);
			ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSINFOPANEL)
			ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSPANEL)
			ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
		else
			MsgUtils.ShowTips("SelectScene/lineLimit")
		end		
	end
end

function WildBossProxy:MotoPos()	
	MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, WildBossProxy.MotoPos, self);
	if(WildBossProxy.to and GameSceneManager.map.info.id == WildBossProxy.to.sid) then		
		if(WildBossProxy.to.moveToPos) then
			HeroController.GetInstance():MoveTo(WildBossProxy.to.moveToPos)
		end
	end
	
	WildBossProxy.to = nil
end


function WildBossProxy.SendCheckLine(data)
	WildBossProxy.to = data
	SocketClientLua.Get_ins():SendMessage(CmdType.CheckLine, {tsi = tostring(data.sid), ln = data.ln});
end

--请求vip古魔信息
function WildBossProxy.ReqVipBossInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.WildBossVipInfo);
end

function WildBossProxy._RspVipBossInfo(cmd, data)
	if(data and data.errCode == nil) then
		WildBossManager.SetVipBossData(data);
	end
end

--请求进入VIP古魔场景
function WildBossProxy.ReqEnterVipMap(data)
	WildBossProxy.to = data;
	-- GameSceneManager.to = WildBossProxy.to		
	MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, WildBossProxy.MotoPos, self);
	
	GameSceneManager.GotoScene(tostring(data.sid), nil, WildBossProxy.to);
	ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSINFOPANEL)
	ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSPANEL)
	ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
end

function WildBossProxy._RspBossInfoChg(cmd, data)
	WildBossManager.UpdateVipBossData(data)
end

function WildBossProxy.ReqHistory(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.WildBossVipHistory, {id = id});
end


function WildBossProxy._RspHistory(cmd, data)
	if(data and data.errCode == nil) then
		ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSRANKPANEL, data)
	end
end

function WildBossProxy.ReqHurtRankList(id)
	WildBossProxy.isRefreshBossHurt = true;
	SocketClientLua.Get_ins():SendMessage(CmdType.WildBossVipHurtRank, {mid = id});
end

function WildBossProxy._RspHurtRankList(cmd, data)
	if(WildBossProxy.isRefreshBossHurt) then
		ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSHURTRANKPANEL, data);
		WildBossProxy.isRefreshBossHurt = false;
	end
end

