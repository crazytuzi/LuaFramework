--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionMemberEvent = BaseUI:new("UIUnionMemberEvent")
function UIUnionMemberEvent:Create()
	self:AddSWF("unionMemberEventPanel.swf", true, nil);
end

function UIUnionMemberEvent:OnLoaded(objSwf, name)
	for i=33, 34 do 
		objSwf['labUnion'..i].text = UIStrConfig['union'..i]
	end
	objSwf.checkAll.select = function() self:UpdateEventList() end
	objSwf.checkContribution.select = function() self:UpdateEventList() end
	objSwf.checkMemChanged.select = function() self:UpdateEventList() end
	objSwf.checkLevelUp.select = function() self:UpdateEventList() end
end

function UIUnionMemberEvent:OnShow(name)
	UnionController:ReqMyGuildEvents()
end

--消息处理
function UIUnionMemberEvent:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if name == NotifyConsts.UpdateGuildEventList then
		self:UpdateEventList()
	end
end

-- 消息监听
function UIUnionMemberEvent:ListNotificationInterests()
	return {NotifyConsts.UpdateGuildEventList};
end

------------------------------------------------------------------------------
--									UI逻辑
------------------------------------------------------------------------------

-- 更新帮派成员列表
function UIUnionMemberEvent:UpdateEventList()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local eventList = UnionModel.UnionMemEventList
	if not eventList then return end
	
	local list = UnionUtils:GetGuildEventListDataGridData(eventList)
	
	objSwf.listPlayer.dataProvider:cleanUp() 
	for i, guildVO in pairs(list) do
		if self:GetEventType(guildVO.id) then
			objSwf.listPlayer.dataProvider:push( UIData.encode(guildVO) )
		end
	end
	objSwf.listPlayer:invalidateData()
end

function UIUnionMemberEvent:GetEventType(eType)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local eventTypes = {}
	if objSwf.checkAll.selected then
		eventTypes = UnionConsts.EventAll
	elseif objSwf.checkMemChanged.selected then
		eventTypes = UnionConsts.EventMemChanged
	elseif objSwf.checkLevelUp.selected then
		eventTypes = UnionConsts.EventLevelUp
	elseif objSwf.checkContribution.selected then
		eventTypes = UnionConsts.EventContribution
	end
	
	for i,v in pairs(eventTypes) do
		if v == eType then
			return true
		end
	end
	
	return false
end