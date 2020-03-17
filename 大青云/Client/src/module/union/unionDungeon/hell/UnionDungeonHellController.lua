--[[
帮派副本：地宫炼狱Controller
2015年1月8日15:06:56
haohu
]]

_G.UnionDungeonHellController = setmetatable( {}, {__index = IController});
UnionDungeonHellController.name = "UnionDungeonHellController";

UnionDungeonHellController.Oper_OpenUI = "openUI"
UnionDungeonHellController.Oper_ReEnter = "reEnter"

function UnionDungeonHellController:Create()
	MsgManager:RegisterCallBack( MsgType.WC_GuildHellInfo, self, self.OnGuildHellInfoRsv ) -- 服务端通知: 服务端通知:帮派活动-地宫炼狱信息
	MsgManager:RegisterCallBack( MsgType.WC_EnterGuildHell, self, self.OnEnterGuildHellResult ) -- 服务端通知：请求进入地宫炼狱结果
	MsgManager:RegisterCallBack( MsgType.SC_QuitGuildHell, self, self.OnQuitGuildHellResult ) -- 服务端通知：退出挑战地宫炼狱结果
	MsgManager:RegisterCallBack( MsgType.WC_GuildHellResult, self, self.OnGuildHellResult ) -- 服务端通知：挑战地宫炼狱结果
	MsgManager:RegisterCallBack( MsgType.WC_GuildHellNotice, self, self.OnGuildHellNotice ) -- 每周一重置后，玩家第一次上限加个弹窗提醒
end

function UnionDungeonHellController:OnEnterGame()
	self:QueryGuildHellInfo()
end

function UnionDungeonHellController:OnChangeSceneMap()
	if self.sceneChangeCallBack then
		self.sceneChangeCallBack();
		self.sceneChangeCallBack = nil;
	end
	if UIUnionHellNotice and UIUnionHellNotice:IsShow() then
		UIUnionHellNotice:Hide();
	end
end

--------------------------------------response----------------------------------------
-- 收到层级信息变化
function UnionDungeonHellController:OnGuildHellInfoRsv( msg )
	local stratumList = msg.stratumList;
	UnionDungeonHellModel:UpdateStratumList( stratumList );
end

-- 服务器返回进入地宫炼狱结果
function UnionDungeonHellController:OnEnterGuildHellResult( msg )
	local result = msg.result;
	if result == 0 then -- 进入成功
		local stratumId = msg.id;
		UIUnion:Hide();
		UIUnionHellScene:Open( stratumId );
		MainMenuController:HideRight();
		UnionDungeonHellModel:SetInHellState(true)
		self.sceneChangeCallBack = function()
			UIUnionHellScene:RunToFight()
		end
	elseif result == 1 then -- 组队状态不可挑战
		FloatManager:AddCenter( StrConfig['unionhell048'] )
	end
end

-- 服务器返回地宫炼狱挑战结果
local wan; -- 胜利
local lastStratum;
function UnionDungeonHellController:OnGuildHellResult( msg )
	local result = msg.result;
	lastStratum = msg.id;
	UIUnionHellScene:StopTimer()
	if result == 0 then -- 挑战成功
		-- 打开挑战成功面板
		local stratumVO = UnionDungeonHellModel:GetStratum( lastStratum );
		stratumVO.state = true;
		UIUnionHellSuccess:Open( msg.time, msg.bestTime );
		SoundManager:PlaySfx(2019);
		wan = true;
	else
		-- 打开挑战失败面板
		UIUnionHellFail:Open();
		SoundManager:PlaySfx(2020);
		wan = false;
	end
	UIUnionHellScene:Hide();
end

-- 服务器返回退出地宫炼狱结果
function UnionDungeonHellController:OnQuitGuildHellResult( msg )
	local result = msg.result;
	if result == 0 then -- 退出成功
		UIUnionHellScene:Hide();
		MainMenuController:UnhideRight();
		UIUnionHellSuccess:Hide();
		UIUnionHellFail:Hide();
		if self.nextOper == self.Oper_ReEnter then
			self.sceneChangeCallBack = self.Enter(self)
		elseif self.nextOper == self.Oper_OpenUI then
			self.sceneChangeCallBack = self.ShowHellViewLater(self)
		else
			self.sceneChangeCallBack = nil
		end
		wan = nil;
		lastStratum = nil
		UnionDungeonHellModel:SetInHellState(false)
	end
end

local showUITimerKey
function UnionDungeonHellController:ShowHellViewLater()
	if showUITimerKey then
		TimerManager:UnRegisterTimer( showUITimerKey )
		showUITimerKey = nil
	end
	TimerManager:RegisterTimer( function()
		local stratum, tweenToNext;
		if wan == true then
			stratum, tweenToNext = lastStratum, lastStratum < UnionHellConsts:GetNumStratum();
		end
		UIUnionDungeonHell:ShowWhenGetOut(stratum, tweenToNext);
		showUITimerKey = nil
	end, 1000, 1)
end

function UnionDungeonHellController:Enter()
	local currentStratum = UnionDungeonHellModel:GetCurrentStratum();
	UnionDungeonHellController:ReqEnterGuildHell(currentStratum)
end

function UnionDungeonHellController:OnGuildHellNotice(msg)
	UIUnionHellNotice:Show()
end


--------------------------------------request----------------------------------------
--请求地宫炼狱信息
function UnionDungeonHellController:QueryGuildHellInfo()
	local msg = ReqQueryGuildHellInfoMsg:new();
	MsgManager:Send(msg);
end

--@param stratumId:地宫炼狱层级id
function UnionDungeonHellController:ReqEnterGuildHell(stratumId)
	-- 只有当前层可以挑战
	local currentStratum = UnionDungeonHellModel:GetCurrentStratum();
	if currentStratum > stratumId then
		FloatManager:AddNormal( StrConfig['unionhell046'] );
		return;
	end
	if currentStratum < stratumId then
		FloatManager:AddNormal( StrConfig['unionhell047'] );
		return;
	end
	local msg = ReqEnterGuildHellMsg:new();
	msg.id = stratumId;
	MsgManager:Send(msg);
	self.nextOper = nil
	self.sceneChangeCallBack = nil
end

--请求退出地宫炼狱
-- oper - 0 退出 1 继续下一层 2 再次挑战本层
function UnionDungeonHellController:ReqQuitGuildHell()
	local msg = ReqQuitGuildHellMsg:new();
	MsgManager:Send(msg);
end

------------------------------------------------------------------------------

--请求退出地宫炼狱
function UnionDungeonHellController:Quit()
	self:ReqQuitGuildHell()
	self.nextOper = self.Oper_OpenUI
end

--请求继续挑战下一层
function UnionDungeonHellController:Continue()
	self:ReqQuitGuildHell()
	self.nextOper = self.Oper_ReEnter
end

function UnionDungeonHellController:Retry()
	self:ReqQuitGuildHell()
	self.nextOper = self.Oper_ReEnter
end
