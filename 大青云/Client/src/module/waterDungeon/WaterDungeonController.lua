--[[
流水副本 controller
2015年6月24日12:12:32
haohu
]]

_G.WaterDungeonController =  setmetatable( {}, {__index = IController} );
WaterDungeonController.name = "WaterDungeonController"

WaterDungeonController.sceneChangeCallBack = nil

function WaterDungeonController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_WaterDungeonInfo, self, self.OnWaterDungeonInfoRsv );
	MsgManager:RegisterCallBack( MsgType.SC_WaterDungeonRank, self, self.OnWaterDungeonRankRsv );
	MsgManager:RegisterCallBack( MsgType.SC_WaterDungeonProgress, self, self.OnWaterDungeonProgressRsv );       --流水副本进度
	MsgManager:RegisterCallBack( MsgType.SC_WaterDungeonResult, self, self.OnWaterDungeonResultRsv );           --流水副本结算
	MsgManager:RegisterCallBack( MsgType.SC_WaterDungeonEnterResult, self, self.OnWaterDungeonEnterResultRsv ); --进入流水副本返回结果结果
	MsgManager:RegisterCallBack( MsgType.SC_WaterDungeonExitResult, self, self.OnWaterDungeonExitResultRsv );   --服务器返回:退出流水副本结果
	MsgManager:RegisterCallBack( MsgType.SC_BackWaterDungeonReward, self, self.OnBackWaterDungeonReward );
	MsgManager:RegisterCallBack( MsgType.SC_BackWaterDungeonMoreReward, self, self.OnBackWaterDungeonMoreReward );
	MsgManager:RegisterCallBack( MsgType.SC_WaterDungeonBuffTime, self, self.OnWaterDungeonAddBufferTime );     --经验副本增加时间
end

function WaterDungeonController:OnEnterGame()
	self:QueryWaterDungeonInfo()
end

-- 切换场景完成后的回调
function WaterDungeonController:OnChangeSceneMap()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	if mapCfg.type == 14 then
		-- UIAutoBattleTip:Open(function()
		if self.sceneChangeCallBack then
			self.sceneChangeCallBack()
			self.sceneChangeCallBack = nil
		end
		-- end,true);
	end
end

------------------------------------------------ response ------------------------------------------------------------

-- 服务器返回:流水副本信息
function WaterDungeonController:OnWaterDungeonInfoRsv( msg )
	WaterDungeonModel:SetBestWave( msg.wave )
	WaterDungeonModel:SetBestExp( msg.exp )
	WaterDungeonModel:SetBestMonster( msg.monster )
	WaterDungeonModel:SetTimeUsed( msg.time )
	WaterDungeonModel:SetLeftTime( msg.Cdtime)   --剩余时间
	--可领取损失经验
	if msg.moreReward == 1 then
		WaterDungeonModel:SetLossExp(msg.moreExp);
	end
	self:sendNotification( NotifyConsts.RefreshWaterdata);
end

-- 服务器返回:流水副本排行榜
function WaterDungeonController:OnWaterDungeonRankRsv( msg )
	local list = msg.rankList
	WaterDungeonModel:SetRankList(list)
end

-- 服务器返回:流水副本进度
function WaterDungeonController:OnWaterDungeonProgressRsv( msg )
	WaterDungeonModel:SetCurrentWave( msg.wave)
	WaterDungeonModel:SetCurrentWaveMonster( msg.monster )
	WaterDungeonModel:SetExp( msg.exp ) 
	WaterDungeonModel:SetTotalMonster( msg.totalKillMonster )
end

-- 服务器返回:流水副本结算
function WaterDungeonController:OnWaterDungeonResultRsv( msg )
	UIWaterDungeonProgress:Hide()
	self:OnPlayTimeDown(1000,msg)
end

-- 延迟5秒打开结算界面
function WaterDungeonController:OnPlayTimeDown(dealyTime,msg)
	local num = 5
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			UIWaterDungeonResult:Open( msg.wave, msg.exp )
		end
		if num == 5 then
			UITimeTopSec:Open(2); 
			UIQiZhanDungeonInfo:ONCloseTimer()
		end
		num = num - 1
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,dealyTime)
end

-- 服务器返回：buffer增加的时间
function WaterDungeonController:OnWaterDungeonAddBufferTime( msg )
	WaterDungeonModel:SetAddBufferTime( msg.buffTime ) 
end

-- 服务器返回:进入流水副本结果
function WaterDungeonController:OnWaterDungeonEnterResultRsv( msg )
	local result = msg.result
	if result == 0 then
		self.sceneChangeCallBack = function()
			AutoBattleController:OpenAutoBattle()  --自动挂机
		end
		MainMenuController:HideRight()
		UIWaterDungeon:Hide()
		UIDungeonMain:Hide()
		UIWaterDungeonProgress:Show() --显示流水副本任务栏
	end
end

-- 服务器返回:退出流水副本结果
function WaterDungeonController:OnWaterDungeonExitResultRsv( msg )
	local result = msg.result
	if result == 0 then
		UIWaterDungeonProgress:Hide()
		UIWaterDungeonResult:Hide()
		WaterDungeonModel:ClearProgress()
		MainMenuController:UnhideRight()
		self:QueryWaterDungeonInfo()
		if UIConfirm:IsShow() then
			UIConfirm:Hide();
		end
	end
end

-- 服务器返回:返回流水副本奖励
function WaterDungeonController:OnBackWaterDungeonReward( msg )
	local result = msg.result
	if result == 0 then
		WaterDungeonController:ExitWaterDungeon();		--请求退出
	elseif result == 1 then
		FloatManager:AddNormal( StrConfig['waterDungeon401'] );
	elseif result == 2 then
		FloatManager:AddNormal( StrConfig['waterDungeon402'] );
	else
		FloatManager:AddNormal( StrConfig['waterDungeon403'] );
	end
end

--
function WaterDungeonController:OnBackWaterDungeonMoreReward( msg )
	local result = msg.result;
	if result == 0 then
		WaterDungeonModel:SetLossExp(0);
	elseif result == 1 then -- 绑元不够
		FloatManager:AddNormal( StrConfig['waterDungeon401'] );
	elseif result == 2 then -- 元宝不够
		FloatManager:AddNormal( StrConfig['waterDungeon402'] );
	else
		FloatManager:AddNormal( StrConfig['waterDungeon403'] );
	end
end
------------------------------------------------ request ------------------------------------------------------------

-- 客户端请求：流水副本信息
function WaterDungeonController:QueryWaterDungeonInfo()
	local msg = ReqWaterDungeonInfoMsg:new();
	MsgManager:Send(msg);
end

-- 客户端请求：流水副本排行榜
function WaterDungeonController:QueryWaterDungeonRank()
	local msg = ReqWaterDungeonRankMsg:new();
	MsgManager:Send(msg);
end

-- 客户端请求：进入流水副本
function WaterDungeonController:EnterWaterDungeon()
	-- 优先消耗免费进入次数
	local freeTimes = WaterDungeonModel:GetDayFreeTime();
	local cdTimes = WaterDungeonModel:GetLeftTime();
	if freeTimes > 0 and cdTimes == 0 then
		self:Enter()   --进入流水副本
		return;
	elseif freeTimes > 0 and cdTimes > 0 then
		FloatManager:AddNormal( StrConfig['waterDungeon012'] )
		return
	end
	-- 判断次数
	local timeAvailable = WaterDungeonModel:GetTimeAvailableNew()
	local pickTimes = WaterDungeonModel:GetPick()       --道具是否满足
	local vipCondition = WaterDungeonModel:CheckVip( )  --VIP类型是否满足
	if timeAvailable > 0 and pickTimes and cdTimes == 0 and vipCondition == true then
		self:Enter()                                    --进入流水副本
		return
	end
	if timeAvailable <= 0 then
		FloatManager:AddNormal( StrConfig['waterDungeon007'] )
		return
	elseif timeAvailable <= 0 and not pickTimes then
		FloatManager:AddNormal( StrConfig['waterDungeon007'] )
		return
	elseif not pickTimes and cdTimes > 0 then
		FloatManager:AddNormal( StrConfig['waterDungeon014'] )
		return
	elseif not pickTimes then
		FloatManager:AddNormal( StrConfig['waterDungeon009'] )
		local itemId, itemNum = WaterDungeonConsts:GetEnterItem()
		UIQuickBuyConfirm:Open( itemId,itemNum)        -- 打开快速购买界面
		return
	elseif cdTimes > 0 then
		FloatManager:AddNormal( StrConfig['waterDungeon012'] )
		return
	elseif vipCondition == false then
		FloatManager:AddNormal( StrConfig['waterDungeon013'] )
		return
	end
end

function WaterDungeonController:ConfirmCostEnter()
	self:CloseConfirm()
	local confirm = function()
		self:Enter()
		self:CloseConfirm()
	end
	local cancel = function()
		self:CloseConfirm()
	end
	local item, itemNum = WaterDungeonConsts:GetEnterItem()
	local itemCfg = t_item[item]
	local itemName = itemCfg and itemCfg.name or "missing"
	local str = itemName .. "×" .. itemNum
	local content      = string.format( StrConfig["dungeon506"], str );
	local confirmLabel = StrConfig["dungeon508"];
	local cancelLabel  = StrConfig["dungeon504"];
	self.confirmUid = UIConfirm:Open( content, confirm, cancel, confirmLabel, cancelLabel );
end

function WaterDungeonController:CloseConfirm()
	if self.confirmUid then
		UIConfirm:Close( self.confirmUid )
		self.confirmUid = nil
	end
end

-- 客户端请求：进入流水副本
function WaterDungeonController:Enter()
	local func = function() 
		local msg = ReqWaterDungeonEnterMsg:new()
		MsgManager:Send(msg)
	end
	if TeamUtils:RegisterNotice( UIWaterDungeon,func ) then
		return
	end
	func()
end

function WaterDungeonController:IsPayItemEnough()
	local item, itemNum = WaterDungeonConsts:GetEnterItem()
	return BagModel:GetItemNumInBag( item ) >= itemNum
end

-- 客户端请求：退出流水副本
function WaterDungeonController:ExitWaterDungeon()
	local msg = ReqWaterDungeonExitMsg:new()
	MsgManager:Send(msg)
end

-- 请求流水副本奖励类型
function WaterDungeonController:ExitWaterDungeonReward(_type)
	local msg = ReqWaterDungeonRewardMsg:new()
	msg.type = _type;
	MsgManager:Send(msg)
end

--额外领取流水副本多倍奖励  损失经验面板
function WaterDungeonController:SendWaterDungeonReward(_type)
	local msg = ReqWaterDungeonLossRewardMsg:new();
	msg.type = _type;
	MsgManager:Send(msg);
end