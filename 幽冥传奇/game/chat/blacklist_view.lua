BlacklistView = BlacklistView or BaseClass(XuiBaseView)

function BlacklistView:__init()
	self:SetModal(true)
	self.name = "BlacklistView"
	self.open_mode = OpenMode.OpenOnly
	self.is_visable = true
	self.m_data_mgr = ChatData.Instance
	self.config_tab = {	
		{"chat_ui_cfg", 7, {0}},
	}
end

function BlacklistView:__delete()
	if nil ~= self.blacklist then
		self.blacklist:DeleteMe()
		self.blacklist = nil
	end
end

function BlacklistView:LoadCallBack()
	self:BtnBindEven("btn_addblack", self.AddBlackHandler)
	self:BtnBindEven("btn_removeblack", self.RemoveBlackHandler)
	self:BtnBindEven("btn_window_close", self.OnClose)
	self:CreateAutoFriendList()
end

function BlacklistView:CloseCallBack()
	
end

function BlacklistView:ShowIndexCallBack()
	self.root_node:setPositionX(HandleRenderUnit:GetWidth() / 2)
	self.root_node:setPositionY(HandleRenderUnit:GetHeight() / 2)
	self:Flush()
end

function BlacklistView:AddBlackHandler()
	ChatCtrl.Instance:OpenAddBlacklistView()
end

function BlacklistView:RemoveBlackHandler()
	local items = self.blacklist:GetAllItems() or {}
	for k,v in pairs(items) do
		if v.is_choose == true and v:GetData() ~= nil then
			ChatCtrl.Instance:SendDeleteBlackReq(v:GetData().user_id)
		end
	end
end

function BlacklistView:CreateAutoFriendList()
	local ph = self.ph_list.ph_blacklist
	self.blacklist = ListView.New()
	self.blacklist:Create(ph.x, ph.y, ph.w, ph.h, nil, BlacklistRender, nil, nil, self.ph_list.ph_listitem)
	self.blacklist:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_addblackList.node:addChild(self.blacklist:GetView(), 100)
	self.blacklist:SetJumpDirection(ListView.Top)
end

function BlacklistView:OnFlush()
	local data = self.m_data_mgr:GetBlacklist()
	if nil ~= data and nil ~= self.blacklist then
		self.blacklist:SetDataList(data)
	end
end

--btn单击事件绑定
function BlacklistView:BtnBindEven(btn_name, OnClickHandler)
	if nil == OnClickHandler then
		Log("绑定单击事件为空")
		return
	end
	if nil ~= btn_name and nil ~= self.node_t_list[btn_name] then
		self.node_t_list[btn_name].node:addClickEventListener(BindTool.Bind1(OnClickHandler, self))
	end
end

function BlacklistView:OnClose()
	self:Close()
end












----------------------------------------------------------------------------------------------------
-- 黑名单item
----------------------------------------------------------------------------------------------------
BlacklistRender = BlacklistRender or BaseClass(BaseRender)
function BlacklistRender:__init()
	self.is_choose = false
end

function BlacklistRender:__delete()
	if nil ~= self.role_avatar then
		self.role_avatar:DeleteMe()
		self.role_avatar = nil
	end
end

function BlacklistRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_avatar
	if nil ~= ph then
		self.role_avatar = RoleHeadCell.New(false)
		self.role_avatar:SetPosition(ph.x, ph.y)
		self.view:addChild(self.role_avatar:GetView(), 100)
	end
	self.role_avatar:GetView():setScale(0.9)

	self.img_select = self.node_tree.img_select.node
	self.node_tree.btn_checkbg.node:addClickEventListener(BindTool.Bind1(self.OnChoose, self))
end

function BlacklistRender:OnFlush()
	self.role_avatar:SetRoleInfo(self.data.user_id, self.data.gamename, self.data.prof, true)

	self.img_select:setVisible(SocietyData.Instance:GetAddfriendList()[self.data.user_id])

	self.node_tree.lbl_name.node:setString(self.data.gamename)

	self.node_tree.lbl_name.node:setColor(SEX_COLOR[self.data.sex][3])

	self.node_tree.label_level.node:setString(RoleData.GetLevelString(self.data.level))

	self.node_tree.label_prof.node:setString(tostring(Language.Common.ProfName[self.data.prof]))
	self.node_tree.label_prof.node:setColor(PROF_COLOR3B[self.data.prof])

	self.node_tree.img9_bg.node:setVisible(self.index % 2 ~= 0)
	self.is_choose = false
	self.img_select:setVisible(self.is_choose)
end

function BlacklistRender:OnChoose()
	self.is_choose = not self.img_select:isVisible()
	self.img_select:setVisible(self.is_choose)
end