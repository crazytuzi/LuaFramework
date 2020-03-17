--[[
奇遇副本追踪面板
2015年7月30日16:59:27
haohu
]]
------------------------------------------------------------

_G.UIRandomDungeonGuide = BaseUI:new("UIRandomDungeonGuide")

function UIRandomDungeonGuide:Create()
	self:AddSWF("randomDungeonGuide.swf", true, "center")
end

function UIRandomDungeonGuide:OnLoaded( objSwf )
	objSwf.btnTitle.click = function() self:OnBtnTitleClick() end
	local panel = objSwf.panel
	objSwf.panel.btnNext.click = function() self:OnBtnNextClick() end
	objSwf.panel.btnLink.click = function() self:OnBtnLinkClick() end
	objSwf.panel.btnQuit.click = function() self:OnBtnQuitClick() end
end

function UIRandomDungeonGuide:OnShow()
	self:ShowTitle()
	self:ShowLink()
	self:ShowProgress()
	self:ShowBtn()
	self:AutoDoGuide()
	
end

function UIRandomDungeonGuide:AutoDoGuide()
	if t_consts[90].val2 then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaLevel >= t_consts[90].val2 then
			self:DoGuide();
			
			if self.autotimerKey then
				TimerManager:UnRegisterTimer(self.autotimerKey);
				self.autotimerKey = nil;
			end
			self.autotimerKey = TimerManager:RegisterTimer( function()
				if self.autotimerKey then
					local randomDungeon = RandomQuestModel:GetDungeon()
					if randomDungeon and self.bShowState then
						self:DoGuide();
					end
					TimerManager:UnRegisterTimer(self.autotimerKey);
					self.autotimerKey = nil;
				end
			end, 16000, 0 );
		end
	end
end

function UIRandomDungeonGuide:OnHide()

end

function UIRandomDungeonGuide:OnBtnTitleClick()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.panel
	if not panel then return end
	panel._visible = not panel._visible
end

function UIRandomDungeonGuide:OnBtnLinkClick()
	self:DoGuide()
end

function UIRandomDungeonGuide:OnBtnNextClick()
	self:DoGuide()
end

function UIRandomDungeonGuide:DoGuide()
	local randomDungeon = RandomQuestModel:GetDungeon()
	if not randomDungeon then
		Error( "you are not in random dungeon" )
		print( debug.traceback() )
	end
	randomDungeon:DoGuide()
end

function UIRandomDungeonGuide:OnBtnQuitClick()
	RandomQuestController:ReqRandomDungeonExit()
end

function UIRandomDungeonGuide:ShowTitle()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.panel.txtTitle.text = StrConfig["randomQuest003"]
end

function UIRandomDungeonGuide:ShowLink()
	local objSwf = self.objSwf
	if not objSwf then return end
	local randomDungeon = RandomQuestModel:GetDungeon()
	if not randomDungeon then return end
	objSwf.panel.btnLink.htmlLabel = randomDungeon:GetLink()
end

function UIRandomDungeonGuide:ShowProgress()
	local objSwf = self.objSwf
	if not objSwf then return end
	local randomDungeon = RandomQuestModel:GetDungeon()
	if not randomDungeon then return end
	objSwf.panel.txtProgress.htmlText = randomDungeon:GetStepProgressLabel()
end

function UIRandomDungeonGuide:ShowBtn()
	local objSwf = self.objSwf
	if not objSwf then return end
	local randomDungeon = RandomQuestModel:GetDungeon()
	if not randomDungeon then return end
	objSwf.panel.btnNext.label = randomDungeon:GetBtnLabel()
	objSwf.panel.btnQuit.label = StrConfig['randomQuest001']
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIRandomDungeonGuide:ListNotificationInterests()
	return {
		NotifyConsts.RandomDungeonProgress,
		NotifyConsts.RandomDungeonZazenTime,
		NotifyConsts.RandomDungeonStep
	};
end

--处理消息
function UIRandomDungeonGuide:HandleNotification(name, body)
	if name == NotifyConsts.RandomDungeonZazenTime then
		self:ShowProgress()
	elseif name == NotifyConsts.RandomDungeonProgress then
		self:ShowProgress()
	elseif name == NotifyConsts.RandomDungeonStep then
		self:ShowBtn()
		self:ShowLink()
		self:ShowProgress()
	end
end