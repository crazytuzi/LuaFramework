--[[
奇遇任务 tips
2015年8月3日17:50:00
haohu
]]
--------------------------------------------------------------

UIRandomQuestTips = BaseUI:new("UIRandomQuestTips")

function UIRandomQuestTips:Create()
	self:AddSWF( "randomQuestTips.swf", true, "top" )
end

function UIRandomQuestTips:OnLoaded( objSwf )
	objSwf.lblReward.text = StrConfig['randomQuest101']
end

function UIRandomQuestTips:OnResize(wWidth,wHeight)
	self:SetUIPos()
end

function UIRandomQuestTips:SetUIPos()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf._x      = wWidth - 279
	local monsePos = _sys:getRelativeMouse()
	objSwf._y      = monsePos.y + 20
end

function UIRandomQuestTips:OnShow()
	self:UpdateShow()
	self:SetUIPos()
end

function UIRandomQuestTips:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local quest = RandomQuestModel:GetQuest()
	if not quest then
		self:Hide()
		return
	end
	local cfg = quest:GetCfg()
	objSwf.txtTitle.htmlText = string.format( StrConfig['randomQuest102'], cfg.groupName )
	objSwf.txtDes.text = cfg.desc
	local uiList = objSwf.list
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack( quest:GetShowRewards() ) )
	uiList:invalidateData()
end

function UIRandomQuestTips:ListNotificationInterests()
	return { NotifyConsts.RandomQuestAdd }
end

function UIRandomQuestTips:HandleNotification( name, body )
	if name == NotifyConsts.RandomQuestAdd then
		self:UpdateShow()
	end
end
