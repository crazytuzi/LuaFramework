--[[
武魂管理
liyuan
2014年9月28日10:33:06
]]
_G.SpiritsController = setmetatable({},{__index=IController})

SpiritsController.name = "SpiritsController";
SpiritsController.xiuxianPfxTime = 30000
SpiritsController.lastTime = 0

function SpiritsController:Create()
	--SpiritsUtil:Print('SpiritsController:Create()')
	-- MsgManager:RegisterCallBack(MsgType.SC_WuHunListResult,self,self.OnWuHunListResult);
	--MsgManager:RegisterCallBack(MsgType.SC_AddWuHunResult,self,self.OnAddWuHunResult);
	MsgManager:RegisterCallBack(MsgType.SC_FeedWuHunResult,self,self.OnFeedWuHunResult);
	MsgManager:RegisterCallBack(MsgType.SC_ProceWuHunResult,self,self.OnProceWuHunResult);
	MsgManager:RegisterCallBack(MsgType.SC_AdjunctionWuHunResult,self,self.OnAhjunctionWuHunResult);
	MsgManager:RegisterCallBack(MsgType.SC_WuHunLingshouInfoResult,self,self.OnWuHunLingshouInfoResult);--武魂信息
	MsgManager:RegisterCallBack(MsgType.SC_WuHunShenshouListResult,self,self.OnWuHunShenshouListResult);--武魂皮肤信息
	MsgManager:RegisterCallBack(MsgType.SC_AdjunctionWuHunShenshouResult,self,self.OnAdjunctionWuHunShenshouResult);--武魂皮肤使用
	MsgManager:RegisterCallBack(MsgType.SC_AddWuHunShenshouResult,self,self.OnAddWuHunShenshouResult);--武魂皮肤激活
	MsgManager:RegisterCallBack(MsgType.SC_ShenShouTimeNotify,self,self.OnShenShouTimeNotify);--武魂皮肤获得或者失去通知
end

function SpiritsController:BeforeLineChange()
	SpiritsModel.isAutoLevelUp = false
	UIzhanshou:HideUPArrow()
	Notifier:sendNotification(NotifyConsts.WuhunLevelUpFail);
end

function SpiritsController:BeforeEnterCross()
	SpiritsModel.isAutoLevelUp = false
	UIzhanshou:HideUPArrow()
	Notifier:sendNotification(NotifyConsts.WuhunLevelUpFail);
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求所有武魂数据
function SpiritsController:GetWuhunList()
	local msg = ReqQueryWuHunMsg:new();
	MsgManager:Send(msg)
end

-- 请求激活武魂
function SpiritsController:ActiveWuhun(wuhunId)
	local msg = ReqAddWuHunShenshouMsg:new()
	msg.wuhunId = wuhunId
	FTrace(msg, '请求激活武魂');
	MsgManager:Send(msg)
end

-- 请求喂养武魂
function SpiritsController:FeedWuhun(wuhunId, guanzhuNum)
	SpiritsUtil:Print('请求喂养武魂'..wuhunId..'次数'..guanzhuNum);
	local msg = ReqFeedWuHunMsg:new()
	msg.wuhunId = wuhunId
	msg.feedNum = guanzhuNum
	MsgManager:Send(msg)
end

-- 请求武魂进阶
function SpiritsController:LevelUpWuhun(wuhunId, autoBuy)
	local msg = ReqProceWuHunMsg:new()
	msg.wuhunId = wuhunId
	if autoBuy then msg.autobuy = 0	else msg.autobuy = 1 end
	FTrace(msg, '请求武魂进阶')
	MsgManager:Send(msg)
end

-- 请求武魂附身
function SpiritsController:AhjunctionWuhun(wuhunId, flag)
	--SpiritsUtil:Print('SpiritsController:AhjunctionWuhun'..wuhunId..'flag'..flag);
	if flag == 1 then
		if SitModel:GetSitState() ~= SitConsts.NoneSit then
			SitController:ReqCancelSit()
		end
	end
	if MainPlayerController.standInState then
		return
	end
	local msg = ReqAdjunctionWuHunMsg:new()
	if wuhunId and wuhunId > 0 then
		msg.wuhunId = wuhunId
	else
		msg.wuhunId = SpiritsModel.selectedWuhunId
	end
	msg.wuhunFlag = flag
	MsgManager:Send(msg)
	FTrace(msg, '请求灵兽附身')
end

-- 武魂神兽附身
function SpiritsController:AhjunctionWuhunshenshou(wuhunId, flag)
	--SpiritsUtil:Print('SpiritsController:AhjunctionWuhun'..wuhunId..'flag'..flag);
	if flag == 1 then
		if SitModel:GetSitState() ~= SitConsts.NoneSit then
			SitController:ReqCancelSit()
		end
	end
	local msg = ReqAdjunctionWuHunShenshouMsg:new()
	msg.wuhunId = wuhunId
	msg.wuhunFlag = flag
	MsgManager:Send(msg)
	FTrace(msg, '请求神兽附身')
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 激活武魂
function SpiritsController:OnAddWuHunResult(msg)
	--SpiritsUtil:Print('返回激活武魂')
	--SpiritsUtil:Trace(msg)
	
	if msg.result == 1 then
		SpiritsModel:ActiveWuhun(msg.wuhunId)
	else
		--SpiritsUtil:Print('激活武魂失败')
	end
end

-- 喂养武魂
function SpiritsController:OnFeedWuHunResult(msg)
	SpiritsUtil:Print('返回喂养武魂')
	SpiritsUtil:Trace(msg)
	
	SpiritsModel:FeedWuHun(msg.wuhunId, msg.hunzhu, msg.feedNum, msg.feedProgress)
end

-- 武魂进阶
local timerKey;
function SpiritsController:OnProceWuHunResult(msg)
	FTrace(msg, '返回武魂进阶')
	
	if msg.result ~= 0 then
		SpiritsModel.isAutoLevelUp = false
		UIzhanshou:HideUPArrow()
		Notifier:sendNotification(NotifyConsts.WuhunLevelUpFail);
		return 
	end
	
	if msg.proceState == 1 then --进阶成功
		UIzhanshou:HideUPArrow()
		WarPrintModel:SetOpenState()
		Notifier:sendNotification(NotifyConsts.WuhunLevelUpsucceed);
	end
	
	VipModel:SetIsChange(VipConsts.TYPE_LINGSHOU,true);
	
	SpiritsModel:WuhuLevelUp(msg.wuhunId, msg.wuhunWish, msg.proceState, msg.proceId)
	if SpiritsModel.isAutoLevelUp then
		timerKey = TimerManager:RegisterTimer( function()
			if SpiritsModel.isAutoLevelUp then
				UILevelUpSpirits:OnLevelUP()
			end
		end, 300, 1 );-- 自动升阶时间间隔300毫秒
	end
end


function SpiritsController:OnEnterGame()
	local mplayer = MainPlayerController:GetPlayer()
	SpiritsUtil:SetWuhunPfx(MainPlayerController:GetRoleID(), 0, mplayer:GetAvatar(),mplayer:GetPlayerInfoByType(enAttrType.eaProf))
end

-- 武魂信息
function SpiritsController:OnWuHunLingshouInfoResult(msg)
	FTrace(msg, '武魂信息')
	
	local wuhuVO = SpiritsVO:new()
	for attrName, attrValue in pairs(msg) do
		wuhuVO[attrName] = attrValue
	end	
	
	local cfg = t_wuhun[wuhuVO.wuhunId]
	if cfg then 
		local feedTable = cfg.feed_consume
		wuhuVO.feedItem = feedTable[1]
	else
		wuhuVO.feedItem = nil
	end
	
	if wuhuVO.wuhunselectId ~= wuhuVO.wuhunId then
		LinshouModel.selectedWuhunId = wuhuVO.wuhunId;
	end
	LinshouModel:SetWuhunState(wuhuVO.wuhunselectId,wuhuVO.wuhunState);
	SpiritsModel.selectedWuhunId = wuhuVO.wuhunselectId
	SpiritsModel.currentWuhun = wuhuVO
	SpiritsModel:SetPillNum(msg.pillNum);
	Notifier:sendNotification(NotifyConsts.WuhunListUpdate);
	SkillController:OnWuhunSkillChange();
	WarPrintModel:SetOpenState()
end

-- 武魂皮肤信息
function SpiritsController:OnWuHunShenshouListResult(msg)
	-- print('==============神兽皮肤信息')
	-- trace(msg)
	
	for i,wuhunInfo in pairs(msg.wuhunshenshou) do
		local vo = {};
		vo.wuhunId = wuhunInfo.wuhunId;
		vo.time = wuhunInfo.time;
		vo.wuhunState = 0;
		LinshouModel:AddShenShouVO(vo);
	end
end

--武魂皮肤获得或者失去通知
function SpiritsController:OnShenShouTimeNotify(msg)
	if msg.time ~= 0 then
		local vo = {};
		vo.wuhunId = msg.wuhunId;
		vo.time = msg.time;
		vo.wuhunState = 1;
		LinshouModel:AddShenShouVO(vo);
		local wuhunState = 0;
		if LinshouModel:getWuhuVO(msg.wuhunId) then
			wuhunState = LinshouModel:getWuhuVO(msg.wuhunId).wuhunState;
		else
			if self.currentWuhun.msg.wuhunId == msg.wuhunId then
				wuhunState = self.currentWuhun.wuhunState;
			end
		end
		SpiritsController:AhjunctionWuhun(msg.wuhunId, wuhunState);
	else
		if vo.wuhunId == SpiritsModel.selectedWuhunId then
			if SpiritsModel:GetWuhunId() then
				SpiritsController:AhjunctionWuhun(msg.wuhunId, LinshouModel:getWuhuVO(msg.wuhunId).wuhunState);
			end
		end
	end
	
end

-- 武魂附身
function SpiritsController:OnAhjunctionWuHunResult(msg)
	FTrace(msg, '返回武魂附身')
	if msg.result == 0 then
		-- 附身失败
		--SpiritsUtil:Print('武魂附身失败！！')
	else
		SpiritsModel:FushenWuhun(msg.wuhunId, msg.result)
        SpiritsUtil:Print("FushenSucesss"..msg.wuhunId)
		if msg.result == 1 then--附身
			self:PlayWuhunHetiPfx(msg.wuhunId)
		end
	end
end

-- 武魂皮肤使用
function SpiritsController:OnAdjunctionWuHunShenshouResult(msg)
	FTrace(msg, '武魂皮肤使用')
	
	if msg.result == 0 then
		-- 附身失败
		--SpiritsUtil:Print('武魂附身失败！！')
	else
		SpiritsModel:FushenWuhun(msg.wuhunId, msg.result)
		if msg.result == 1 then--附身
			self:PlayWuhunHetiPfx(msg.wuhunId)
		end
	end
end

-- 播放武魂切换特效
function SpiritsController:PlayWuhunHetiPfx(wuhunId)
	if not wuhunId or wuhunId == 0 then return end
	local switchPfxId = nil
	if t_wuhun[wuhunId] then 
		switchPfxId = t_wuhun[wuhunId].ui_id 
	elseif t_wuhunachieve[wuhunId] then 
		switchPfxId = t_wuhunachieve[wuhunId].ui_id 
	end
	if not switchPfxId then return end
	local uiCfg = t_lingshouui[switchPfxId]
	if not uiCfg or not uiCfg.model then return end
	local modelCfg = t_lingshoumodel[uiCfg.model]
	if not modelCfg or not modelCfg.fit_action then return end
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	local avatar = selfPlayer:GetAvatar()
	if avatar then
		-- --如果在马上 先下马
		-- if MountModel:isRideState() then
		-- 	MountController:RideMount()
		-- end
		avatar:PlayHetiAction()
		avatar:PlayerPfxOnSkeleton(modelCfg.fit_action)
		SoundManager:PlaySkillSfx(11013);
	end
end

function SpiritsController:Update(dwInterval)
	local wuhunId = SpiritsModel:GetFushenWuhunId()
	if not wuhunId or wuhunId == 0 then return end
	self.lastTime = self.lastTime + dwInterval
	if self.lastTime >= self.xiuxianPfxTime then
		self.lastTime = self.lastTime - self.xiuxianPfxTime
		-- self:PlayWuhunXiuXianPfx()
	end
end

-- 播放武魂休闲特效
function SpiritsController:PlayWuhunXiuXianPfx()
	local wuhunId = SpiritsModel:GetFushenWuhunId()
	if not wuhunId or wuhunId == 0 then return end
	local switchPfxId = nil
	if t_wuhun[wuhunId] then 
		switchPfxId = t_wuhun[wuhunId].active_ghost 
	elseif t_wuhunachieve[wuhunId] then 
		switchPfxId = t_wuhunachieve[wuhunId].active_ghost 
	end
	
	-- switchPfxId = "npc_xuanzhong.pfx"
	if not switchPfxId then return end
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	-- FPrint("播放武魂休闲特效8")
	local avatar = selfPlayer:GetAvatar()
	if avatar then
		-- FPrint("播放武魂休闲特效9")
		avatar:PlayerPfxOnSkeleton(switchPfxId)
	end
end

-- 武魂皮肤激活
function SpiritsController:OnAddWuHunShenshouResult(msg)
	FTrace(msg, '武魂皮肤激活')
	if msg.result == 0 then
		LinshouModel:ActiveWuhun(msg.wuhunId)
		
		local wuhunState = 0;
		if LinshouModel:getWuhuVO(msg.wuhunId) then
			wuhunState = LinshouModel:getWuhuVO(msg.wuhunId).wuhunState;
		else
			if self.currentWuhun.msg.wuhunId == msg.wuhunId then
				wuhunState = self.currentWuhun.wuhunState;
			end
		end
		SpiritsController:AhjunctionWuhun(msg.wuhunId, wuhunState);
		
	else
		--SpiritsUtil:Print('激活武魂失败')
	end
end

function SpiritsController:GetModelId(wuhunId)
	-- if not wuhunId or wuhunId == 0 then
	-- 	return
	-- end
	-- local switchPfxId = nil
	-- if t_wuhun[wuhunId] then 
	-- 	switchPfxId = t_wuhun[wuhunId].ui_id 
	-- elseif t_wuhunachieve[wuhunId] then 
	-- 	switchPfxId = t_wuhunachieve[wuhunId].ui_id 
	-- end
	-- if not switchPfxId then
	-- 	return
	-- end
	-- local uiCfg = t_lingshouui[switchPfxId]
	-- if not uiCfg or not uiCfg.model then
	-- 	return
	-- end
	-- return uiCfg.model
end

function SpiritsController:GetHetiPfx(wuhunId)
	local modelId = SpiritsController:GetModelId(wuhunId)
	if not modelId then
		return
	end
	local modelCfg = t_lingshoumodel[modelId]
	if not modelCfg then
		return
	end
	if not modelCfg.fit_action then
		return
	end
	return modelCfg.fit_action
end