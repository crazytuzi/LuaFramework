--[[
boss 勋章 controller
haohu
2015-11-19 17:35:00
]]

_G.BossMedalController = setmetatable( {}, {__index = IController} )
BossMedalController.name = "BossMedalController"

function BossMedalController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_BossMedalInfo, self, self.OnBossMedalInfo );
	MsgManager:RegisterCallBack( MsgType.SC_BossMedalLevelUp, self, self.OnBossMedalLevelUp );
	MsgManager:RegisterCallBack( MsgType.SC_BossMedalPoints, self, self.OnBossMedalPointsRsv );
	self:RegisterActivePrompt()
end

----------------------------------------------Response-----------------------------------------------

-- 返回Boss勋章信息, 上线发
function BossMedalController:OnBossMedalInfo( msg )
	QuestController:TestTrace("返回Boss勋章信息, 上线发")
	QuestController:TestTrace(msg)
	---------------------------------------------
	BossMedalModel:SetLevel( msg.level )
	BossMedalModel:SetStar( msg.star )
	BossMedalModel:SetGrowValue( msg.growValue )
	for i, vo in pairs( msg.pointsList ) do
		local bossType = i - 1
		BossMedalModel:SetBossNum( bossType, vo.bossNum )
	end
end

-- 返回Boss勋章升级结果
function BossMedalController:OnBossMedalLevelUp( msg )
	QuestController:TestTrace("返回Boss勋章升级结果" .. msg.result)
	QuestController:TestTrace(msg)
	---------------------------------------------
	if msg.result == 0 then
		local levelChanged = BossMedalModel:SetLevel( msg.level )
		BossMedalModel:SetStar( msg.star )
		BossMedalModel:SetGrowValue( msg.growValue )
		if levelChanged then
			self:StopAutoLevelUp()
			return
		end
		if BossMedalModel:GetAutoLvUp() then
			self:StopAutoLevelUpTimer()
			self.autoLvUpTimer = TimerManager:RegisterTimer( function()
				self:ReqLevelUp(true)
				self:StopAutoLevelUpTimer()
			end, 300, 1)
		end
	end
end

-- 返回Boss勋章点数
function BossMedalController:OnBossMedalPointsRsv( msg )
	QuestController:TestTrace("返回Boss勋章点数")
	QuestController:TestTrace(msg)
	---------------------------------------------
	BossMedalModel:SetBossNum( msg.bossType, msg.bossNum )
end

----------------------------------------------Request-----------------------------------------------

-- 请求升级Boss勋章
function BossMedalController:ReqLevelUp(auto)
	if not auto then auto = false end
	local currentLevel = BossMedalModel:GetLevel()
	if currentLevel < 1 then
		local itemID,num = BossMedalConsts:GetActiveItem();
		if not itemID then return end
		local bgNum = BagModel:GetItemNumInBag(itemID);
		if bgNum < num then
			FloatManager:AddNormal( StrConfig['magicWeapon014'] )
			return
		end
		local msg = ReqBossMedalLevelUpMsg:new()
		MsgManager:Send(msg)
		return
	end
	if BossMedalModel:GetCurrentPoints() < BossMedalUtils:GetConsumePoints( currentLevel ) then
		FloatManager:AddNormal( StrConfig['bosshuizhang023'] )
		self:StopAutoLevelUp()
		return
	end
	if currentLevel >= BossMedalConsts:GetMaxLevel() then
		FloatManager:AddNormal(StrConfig['bosshuizhang024'] )
		self:StopAutoLevelUp()
		return
	end

	local msg = ReqBossMedalLevelUpMsg:new()
	MsgManager:Send(msg)
	if auto then
		self:StartAutoLevelUp()
	else
		self:StopAutoLevelUp()
	end
	---------------------------------------------
	QuestController:TestTrace("请求升级/激活Boss勋章")
end


---------------------------------------------------------------------------------------------------

function BossMedalController:StartAutoLevelUp()
	BossMedalModel:SetAutoLvUp(true)
end

function BossMedalController:StopAutoLevelUp()
	self:StopAutoLevelUpTimer()
	BossMedalModel:SetAutoLvUp(false)
end

function BossMedalController:StopAutoLevelUpTimer()
	if self.autoLvUpTimer then
		TimerManager:UnRegisterTimer( self.autoLvUpTimer )
		self.autoLvUpTimer = nil
	end
end

-- 提醒激活boss徽章
function BossMedalController:CheckPromptActive(itemId)
	-- boss徽章未开启
	if not FuncManager:GetFuncIsOpen( FuncConsts.BossHuizhang ) then
		return
	end
	-- boss徽章已激活
	if BossMedalModel:IsActive() then
		return
	end
	-- 道具不是需要的道具
	local needItem, needNum = BossMedalConsts:GetActiveItem()
	if needItem ~= itemId then
		return
	end
	-- 道具不够激活
	if BagModel:GetItemNumInBag(needItem) < needNum then
		return
	end
	-- 提示激活
	UIItemGuide:Open(19)
end

function BossMedalController:RegisterActivePrompt()
	Notifier:registerNotification( NotifyConsts.BagItemNumChange, function( name, body )
		self:CheckPromptActive(body.id)
	end)
end

-- 入口按钮tips
function BossMedalController:ShowBossMedalTips(show)
	if show then
		if not FuncManager:GetFuncIsOpen( FuncConsts.BossHuizhang ) then
			local cfg = t_funcOpen[FuncConsts.BossHuizhang]
			TipsManager:ShowBtnTips( string.format( StrConfig["bosshuizhang025"], cfg.open_level ), TipsConsts.Dir_RightDown )
			return
		end
		if not BossMedalModel:IsActive() then
			TipsManager:ShowBtnTips( StrConfig["bosshuizhang026"], TipsConsts.Dir_RightDown)
			return
		end
		UIBossMedalTips:Show()
	else
		UIBossMedalTips:Hide()
		TipsManager:Hide()
	end
end