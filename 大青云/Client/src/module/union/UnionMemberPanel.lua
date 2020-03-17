--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionMember = BaseUI:new("UIUnionMember")


UIUnionMember.tabButton = {}

function UIUnionMember:Create()
	self:AddSWF("unionMemberPanel.swf", true, nil)

	self:AddChild(UIUnionMemberList,         UnionConsts.TabUnionMemberList)
	self:AddChild(UIUnionMemberEvent,       UnionConsts.TabUnionMemberEvent)
	self:AddChild(UIUnionMemberApply, UnionConsts.TabUnionMemberApplyList)
	self:AddChild(UIUnionMemberActivity, UnionConsts.TabUnionMemberActivityList)
	
end

function UIUnionMember:WithRes()
	return {"unionMemberListPanel.swf"}
end

function UIUnionMember:OnLoaded(objSwf, name)
	-- set child panel
	self:GetChild(UnionConsts.TabUnionMemberList):SetContainer(objSwf.childPanel1)
	self:GetChild(UnionConsts.TabUnionMemberEvent):SetContainer(objSwf.childPanel1)
	self:GetChild(UnionConsts.TabUnionMemberApplyList):SetContainer(objSwf.childPanel1)
	self:GetChild(UnionConsts.TabUnionMemberActivityList):SetContainer(objSwf.childPanel1)
	--tab button 
	self.tabButton[UnionConsts.TabUnionMemberList] = objSwf.btnUnionMemberList
	self.tabButton[UnionConsts.TabUnionMemberEvent] = objSwf.btnUnionMemberEvent
	self.tabButton[UnionConsts.TabUnionMemberApplyList] = objSwf.btnUnionMemberApply
	self.tabButton[UnionConsts.TabUnionMemberActivityList] = objSwf.btnUnionMemberActivity
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
end

function UIUnionMember:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIUnionMember:OnShow(name)
	self:TurnToSubpanel( UnionConsts.TabUnionMemberList )
	self:UpdatePermission()
	self:RedPoint()
	self:initRedPoint()
end

-- 帮派有新队员申请
--adder:houxudong
--date:2016/8/1 11:54:12
UIUnionMember.timerKey = nil;
UIUnionMember.newLoader = nil;
function UIUnionMember:initRedPoint( )
	self.timerKey = TimerManager:RegisterTimer(function()
		self:RedPoint()
	end,1000,0); 
end

function UIUnionMember:RedPoint( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local isNewApply,newApplyNum = UnionUtils:CheckJoinNewpattern()
	if isNewApply then
		self.newLoader = self:SetRedPoint(objSwf.btnUnionMemberApply,newApplyNum,RedPointConst.showRedPoint,RedPointConst.showNum)       --显示感叹号
		if self.newLoader then 
			self.newLoader._x = objSwf.btnUnionMemberApply._width;
		end
	else
		if self.newLoader then 
			self:RemoveRedPoint(self.newLoader)
			self.newLoader = nil;
		end
	end
end
function UIUnionMember:OnHide( )
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	if self.newLoader then
		self:RemoveRedPoint(self.newLoader)
		self.newLoader = nil;
	end
end

function UIUnionMember:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function UIUnionMember:TurnToSubpanel(panelName)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName)
		end
	end
end

--消息处理
function UIUnionMember:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if name == NotifyConsts.ChangeLeaderUpdate then
		self:UpdatePermission()
	end
end

-- 消息监听
function UIUnionMember:ListNotificationInterests()
	return {NotifyConsts.ChangeLeaderUpdate}
end

-- 更新权限
function UIUnionMember:UpdatePermission()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	--申请审核
	if UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.invitation_verify) == 1 then
		objSwf.btnUnionMemberApply.visible = true
		objSwf.btnUnionMemberActivity.visible = true
	else
		objSwf.btnUnionMemberApply.visible = false
		objSwf.btnUnionMemberActivity.visible = false
		
		local child = self:GetChild(UnionConsts.TabUnionMemberApplyList)
		if child and child:IsShow() then
			self:TurnToSubpanel( UnionConsts.TabUnionMemberList )
		end
		
		child = self:GetChild(UnionConsts.TabUnionMemberActivityList)
		if child and child:IsShow() then
			self:TurnToSubpanel( UnionConsts.TabUnionMemberList )
		end
	end
end


