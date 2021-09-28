-- 主面板:社交
FriendCommonPanel = BaseClass(CommonBackGround)

function FriendCommonPanel:__init(listId)

	self.model = FriendModel:GetInstance()
	self.familyModel = FamilyModel:GetInstance()

	self.id = "FriendCommonPanel"
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="hy01", res1="hy00", id="0", red=true},
		{label="", res0="jz01", res1="jz00", id="1", red=false},
		{label="", res0="jz01", res1="jz00", id="2", red=false},
		{label="", res0="cr01", res1="cr00", id="3", red=false}
	}
	self:AddHandler()
	self.defaultTabIndex = 0
	self.selectPanel = nil
	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == "0" then
			self:SetTitle("好 友")
			if not self.friendPanel then
				self.friendPanel = FriendPanel.New()
				if listId then
					self.friendPanel.tabListCtrl.selectedIndex = listId
					self.friendPanel:BtnTextColor(listId)
				else
					self.friendPanel.tabListCtrl.selectedIndex = 0
					self.friendPanel:BtnTextColor(0)
				end
				self.friendPanel:SetXY(147,115)
				self.container:AddChild(self.friendPanel.ui)
			end
			cur = self.friendPanel
		elseif id == "1" then
			if self.container == nil then return end
			self:SetTitle("家 族")
			if not self.familyCreatePanel then
				self.familyCreatePanel = FamilyCreatePanel.New(self.container)
				if self.familyModel:GetRedTips() then
					local vo = self.familyModel.inviteVo
					local yqPanel = FamilyYQPanel.New(vo)
					UIMgr.ShowCenterPopup(yqPanel)
				end
			end
			-- self:FamilyInvite()
			cur = self.familyCreatePanel
		elseif id == "2" then
			if self.container == nil then return end
			self:SetTitle("家 族")
			if not self.familyMainPanel then
				self.familyMainPanel = FamilyMainPanel.New(self.container)
				self.familyMainPanel:Update()
				self.familyModel:UpdateMembers()
			end
			cur = self.familyMainPanel
		elseif id == "3" then
			self:SetTitle("仇 敌")
			if not self.choudiPanel then
				self.choudiPanel = ChoudiPanel.New()
				self.choudiPanel:SetXY(141, 115)
				self.container:AddChild(self.choudiPanel.ui)
			end
			cur = self.choudiPanel
		end

		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				cur:SetVisible(true)
			end
		end

		self:SetTabarTips(id, false)
	end
	
end

function FriendCommonPanel:FamilyInvite()
	if self.familyModel:GetRedTips() and #self.familyModel.invitePanelList >= 1 then
		for i,v in ipairs(self.familyModel.invitePanelList) do
			local vo = v.vo
			local yqPanel = FamilyYQPanel.New(vo)
			table.insert(self.familyModel.invitePanel, yqPanel)
			UIMgr.ShowCenterPopup(yqPanel)
		end
	end
end

function FriendCommonPanel:Open(tabIndex, id, openFamily)
--	self.tabIndex = tabIndex or 0
--	self.id = id or 0
--	if not id then
--		FriendController:GetInstance():C_FriendList(1)
--	end
--	self:SetSelectTabbar(self.tabIndex)	
--	self.friendPanel.tabListCtrl.selectedIndex = self.id 
--	self.friendPanel:BtnTextColor(self.id)
	CommonBackGround.Open(self)
	if tabIndex then
		self:SetSelectTabbar(tabIndex)
	else
		self:SetSelectTabbar(0)
	end

	if id then
		self.friendPanel.tabListCtrl.selectedIndex = id
		self.friendPanel:BtnTextColor(id)
	else
		self.friendPanel.tabListCtrl.selectedIndex = 0
		self.friendPanel:BtnTextColor(0)
		FriendController:GetInstance():C_FriendList(1)
	end

	if openFamily then
		self:SetSelectTabbar(1)
	end

	if self.familyModel.familyId == 0 then 
		self:SetTabbarVisible( "1", true) -- 未创建
		self:SetTabbarVisible( "2", false)
	else
		self:SetTabbarVisible( "1", false) -- 已创建
		self:SetTabbarVisible( "2", true)
	end
	self:SetTabarTips(1, self.familyModel:GetRedTips())
end

function FriendCommonPanel:Layout()
	-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现（仅一次）
	--self:SetTabbarVisible("1", false)                                                    --隐藏指定id 标签
	--self:SetTabbarVisible("3", false)
end

function FriendCommonPanel:AddHandler()
	if not self.createHandler then
		self.createHandler = GlobalDispatcher:AddEventListener(EventName.FAMILY_CREATE, function ()
			self:Update()
		end)
	end

	if not self.disbandHandler then
		self.disbandHandler = GlobalDispatcher:AddEventListener(EventName.FAMILY_DISBAND, function ()
			self:Update()
			self.familyModel:Clear()
		end)
	end

	if not self.changeHandler then
		self.changeHandler = GlobalDispatcher:AddEventListener(EventName.FAMILY_CHANGE, function ()
			if self.familyMainPanel and self.familyMainPanel.isInited and self.familyModel:GetModelState() then
				self.familyMainPanel:Update()
			end
			self:Update()
		end)
	end
	self.closeCallback = function ()
		if self.familyMainPanel then
			self.familyMainPanel:Close()
		end
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end

	if not self.inviteHandler then
		self.inviteHandler = GlobalDispatcher:AddEventListener(EventName.FAMILY_INVITE, function ()
			if self.familyCreatePanel and self.familyModel:GetRedTips() then
				-- self:FamilyInvite()
				local vo = self.familyModel.inviteVo
				local yqPanel = FamilyYQPanel.New(vo)
				UIMgr.ShowCenterPopup(yqPanel)
				self:SetTabarTips(1, false)
			end
		end)
	end
end

function FriendCommonPanel:Update()
	if not self.familyModel then return end
	if self.selectPanel == self.familyCreatePanel or self.selectPanel == self.familyMainPanel then
		if self.familyModel.familyId == 0 then 
			self:SetTabbarVisible( "1", true) -- 未创建
			self:SetTabbarVisible( "2", false)
			self:SetSelectTabbar(1)
		else
			self:SetTabbarVisible( "1", false) -- 已创建
			self:SetTabbarVisible( "2", true)
			self:SetSelectTabbar(2)
			GlobalDispatcher:RemoveEventListener(self.inviteHandler)
			self.inviteHandler = nil
		end
	end
end

function FriendCommonPanel:__delete()
	if self.friendPanel then
		self.friendPanel:Destroy()
	end
	self.friendPanel = nil
	
	if self.choudiPanel then
		self.choudiPanel:Destroy()
	end
	self.choudiPanel = nil

	if self.familyCreatePanel then
		self.familyCreatePanel:Destroy()
	end
	self.familyCreatePanel = nil

	if self.familyMainPanel then
		self.familyMainPanel:Destroy()
	end
	self.familyMainPanel = nil

	GlobalDispatcher:RemoveEventListener(self.changeHandler)
	GlobalDispatcher:RemoveEventListener(self.disbandHandler)
	GlobalDispatcher:RemoveEventListener(self.createHandler)

	self.changeHandler=nil
	self.disbandHandler=nil
	self.createHandler=nil
end