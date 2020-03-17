--[[
奇遇副本 基类
2015年7月30日17:08:14
haohu
]]
--------------------------------------------------------------

_G.RandomDungeon = {}

RandomDungeon.id       = 0
-- 步骤1 对话NPC
-- 步骤2 (打怪等,每种副本不一样)
-- 步骤3 读秒退出
RandomDungeon.step     = 1
RandomDungeon.subject  = nil
RandomDungeon.progress = 0
RandomDungeon.guideTimer = nil
RandomDungeon.quitTimer = nil

function RandomDungeon:new(id)
	local obj = {}
	setmetatable( obj, {__index = self} )
	obj.id   = id
	obj.step = 1
	obj.progress = 0
	obj:Init()
	return obj
end

function RandomDungeon:Init()
	-- override
end

function RandomDungeon:GetId()
	return self.id
end

function RandomDungeon:GetCfg()
	local cfg = _G.t_qiyu[self.id]
	if not cfg then
		Debug( string.format( "cannot find qiyu config in t_qiyu, qiyu event id:%s", tid ) )
	end
	return cfg
end

function RandomDungeon:GetLink()
	local cfg = self:GetCfg()
	local format = "<u>%s</u>"
	local str
	if self.step == 1 then
		str = cfg.link
	else
		str = cfg.trace
	end
	return string.format( format, str )
end

function RandomDungeon:GetBtnLabel()
	if self.step == 1 then
		return StrConfig['randomQuest002']
	end
	local cfg = self:GetCfg()
	return cfg.btnLabel
end

function RandomDungeon:GetStepProgressLabel()
	if self.step == 1 then
		return ""
	end
	return self:GetProgressTxt()
end

function RandomDungeon:GetProgressTxt()
	local progress   = self:GetProgress()
	local totalCount = self:GetTotalCount()
	return string.format( "数量:<font color='#00FF00'>%s/%s</font>", progress, totalCount )
end

function RandomDungeon:GetDialog()
	-- 有答题优先返回答题对话
	if self.subject then
		return self.subject:GetNpcTalk()
	end
	local cfg = self:GetCfg()
	return cfg.dialog
end

function RandomDungeon:GetOptions()
	-- 有答题优先返回答题选项
	if self.subject then
		return self.subject:GetOptions()
	end
	local answer = self:GetAnswerStr()
	local option = { label = answer }
	return { UIData.encode( option ) }
end

function RandomDungeon:GetAnswerStr()
	local cfg = self:GetCfg()
	return cfg.answer
end

function RandomDungeon:TalkToNpc(answer)
	local step = self.step
	if step == 1 then
		RandomQuestController:ReqRandomDungeonStepComplete( step )
		return
	end
	if step == 2 then -- 只有第1步对话可以请求完成，第2部需要做任务完成
		-- 有答题优先答题
		if self.subject then
			self.subject:Answer( answer )
			return
		end
		self:DoStep2()
		return
	end
	if step == 3 then
		self:CloseNpcDialog()
	end
end

function RandomDungeon:GetStep()
	return self.step
end

function RandomDungeon:SetStep(step)
	if self.step ~= step then
		self.step = step
		if step == 2 then -- 步骤3，读秒退出
			self:DoStep2()
		elseif self.step == 3 then -- 步骤3，读秒退出
			self:DoStep3()
		end
		return true
	end
	return false
end

function RandomDungeon:GetSubject()
	return self.subject
end

function RandomDungeon:SetSubject(subject)
	self.subject = subject
end

function RandomDungeon:GetProgress()
	return self.progress
end

function RandomDungeon:SetProgress(progress)
	if self.progress ~= progress then
		self.progress = progress
		return true
	end
	return false
end

function RandomDungeon:GetTotalCount()
	return 0
end

--跑向NPC
function RandomDungeon:RunToNpc()
	local npc = self:GetNpc()
	if not npc then
		Error("cannot find npc")
		return
	end
	NpcController:GoToTalkWithNpc( npc )
end

function RandomDungeon:GetNpc()
	local cfg = self:GetCfg()
	return NpcModel:GetCurrNpcByNpcId(cfg.npc)
end

-- t_qiyu tid
function RandomDungeon:GetType()
	-- override
end

function RandomDungeon:DoGuide()
	local step = self.step
	if step == 1 then -- 第1步
		self:DoStep1()
	elseif step == 2 then -- 第2步
		self:DoStep2()
	else
		Debug(step)
	end
end

function RandomDungeon:DoStep1()
	if not UIRandomDungeonNpc:IsShow() then
		self:RunToNpc()
	end
end

function RandomDungeon:DoStep2()
	-- override
end

function RandomDungeon:DoStep3()
	self:StartQuitTimer()
end

function RandomDungeon:CloseNpcDialog()
	UIRandomDungeonNpc:Hide()
end

function RandomDungeon:OnEnter()
	self.step = 1
	UIRandomDungeonGuide:Show()
	UIRandomDungeonPrompt:Show()
	MainMenuController:HideRightTop()
	self:StartGuideTimer()
	self:EnterAction()
end

function RandomDungeon:OnExit()
	self:Dispose()
	UIRandomDungeonGuide:Hide()
	UIRandomDungeonPrompt:Hide()
	MainMenuController:UnhideRightTop()
	UIRamdomQuestProGress:Hide();
	RandomQuestModel:SetIsRandomQuest(true)
end

function RandomDungeon:EnterAction()
	-- override
end

----------------------- 自动引导 -----------------------

-- 引导对话
function RandomDungeon:StartGuideTimer()
	self.guideTimer = TimerManager:RegisterTimer( function()
		if self.step == 1 then
			MainPlayerController:ReqCancelSit()
			self:DoStep1()
		end
	end, 10000, 0 )
end

function RandomDungeon:StopGuideTimer()
	if self.guideTimer then
		TimerManager:UnRegisterTimer( self.guideTimer )
		self.guideTimer = nil
	end
end

----------------------- 倒计时退出 -----------------------

function RandomDungeon:StartQuitTimer()
	if self.quitTimer then return end
	self.quitTime = 10
	self.quitTimer = TimerManager:RegisterTimer( function()
		self:OnQuitTimer()
	end, 1000, 0 )
	self:PromptQuit()
end

function RandomDungeon:OnQuitTimer()
	self.quitTime = self.quitTime - 1
	if self.quitTime == 8 then
		if UIRandomDungeonGuide:IsShow() then
			UIRamdomQuestProGress:Open()
		end
	end

	if self.quitTime == 0 then
		self:StopQuitTimer()
		RandomQuestController:ReqRandomDungeonExit()
		return
	end
	self:PromptQuit()
end

function RandomDungeon:PromptQuit()
	local prompt = string.format( StrConfig['randomQuest103'], self.quitTime )
	UIRandomDungeonPrompt:Prompt( prompt )
end

function RandomDungeon:StopQuitTimer()
	if self.quitTimer then
		TimerManager:UnRegisterTimer( self.quitTimer )
		self.quitTimer = nil
	end
end

----------------------- 销毁 -----------------------

function RandomDungeon:Dispose()
	self:StopGuideTimer()
	self:StopQuitTimer()
	if self.subject then
		self.subject:Dispose()
	end
	self.subject = nil
end
