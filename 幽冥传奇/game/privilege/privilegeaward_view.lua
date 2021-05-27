PrivilegeAwardView = PrivilegeAwardView or BaseClass(XuiBaseView)

function PrivilegeAwardView:__init()
	self.texture_path_list[1] = 'res/xui/privilege.png'
	--self.is_async_load = false	
	self.is_any_click_close = true
	self.is_modal = true
	self.config_tab = {
		{"privilege_ui_cfg", 2, {0}},
	}

	self.background_opacity = 10
end

function PrivilegeAwardView:__delete()
	
end

function PrivilegeAwardView:ReleaseCallBack()
	if self.grid_list ~= nil then
		self.grid_list:DeleteMe()
		self.grid_list = nil 
	end

	if nil ~= self.alert_award_privilege then
		self.alert_award_privilege:DeleteMe()
  		self.alert_award_privilege = nil
	end	
	if self.role_attr_change then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change)
		self.role_attr_change = nil 
	end
end

function PrivilegeAwardView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateGrid()
		XUI.AddClickEventListener(self.node_t_list.btn_close_window.node, BindTool.Bind1(self.OnClose, self), true)
		XUI.AddClickEventListener(self.node_t_list.award_btn_openpri.node, BindTool.Bind1(self.OpePrivilege, self), true)
		XUI.AddClickEventListener(self.node_t_list.award_btn_receive.node, BindTool.Bind1(self.RecevieAward, self), true)
		XUI.AddClickEventListener(self.node_t_list.award_btn_receiveall.node, BindTool.Bind1(self.RecevieAllAward, self), true)
		self.alert_award_privilege = Alert.New()
		self.role_attr_change = BindTool.Bind1(self.FlushAttrValue, self)
		RoleData.Instance:NotifyAttrChange(self.role_attr_change)
	end
end

function PrivilegeAwardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()

end


function PrivilegeAwardView:OnClose()
	self:Close()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function PrivilegeAwardView:FlushText(data)
	if data.state == 0 then
		self.node_t_list.award_btn_openpri.node:setVisible(true)
		self.node_t_list.award_btn_receive.node:setVisible(false)
		self.node_t_list.award_remind_name.node:setVisible(false)
		self.node_t_list.award_btn_receiveall.node:setVisible(false)
	else
		local award_fectch_state = PrivilegeData.Instance:GetPrilivegeState(data.vipType)
		local all_award = PrivilegeData.Instance:GetAwardNum()
		if  all_award >= 2 then
			self.node_t_list.award_btn_receiveall.node:setVisible(true)
			self.node_t_list.award_remind_name.node:setVisible(true)
			self.node_t_list.award_btn_receive.node:setVisible(false)
			self.node_t_list.award_btn_openpri.node:setVisible(false)
		else
			if award_fectch_state == 0 then
				self.node_t_list.award_btn_receive.node:setVisible(true)
				self.node_t_list.award_remind_name.node:setVisible(true)
				self.node_t_list.award_btn_openpri.node:setVisible(false)
				self.node_t_list.award_btn_receiveall.node:setVisible(false)
			else	
				self.node_t_list.award_btn_receive.node:setVisible(false)
				self.node_t_list.award_remind_name.node:setVisible(false)
				self.node_t_list.award_btn_openpri.node:setVisible(false)
				self.node_t_list.award_btn_receiveall.node:setVisible(false)
			end
		end
	end
end
function PrivilegeAwardView:SetData(data, true_data)
	self.data = data
	local index_data = PrivilegeData.Instance:GetData()
	self.cur_data= index_data[true_data]	 
	self:Open()
	self.cur_index = true_data
end

function PrivilegeAwardView:OnFlush()
	if self.data  == nil  then return end
	local vipNametxt = self.cur_data.vipName..string.format(Language.Privilege.PrivilegeReward[self.cur_index],Language.Privilege.PrivilegeReward[5])
   	RichTextUtil.ParseRichText(self.node_t_list.txt_reward.node, vipNametxt, 23)
   	XUI.RichTextSetCenter(self.node_t_list.txt_reward.node)
	self.grid_list:SetData(self.data)
	local ph = self.ph_list.ph_grid_list
	local len = #self.data
	if len <  5 then
		local w = 80 * len + (len - 1) * 12
		self.grid_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.grid_list:GetView():setPosition(ph.x, ph.y)
	end	
	self:FlushText(self.cur_data)
end

function PrivilegeAwardView:CreateGrid()
	if self.grid_list == nil then
		local ph = self.ph_list.ph_grid_list
		self.grid_list = ListView.New()
		local t = {x=ph.x, y=ph.y,width =ph.w, height =ph.h, direction = ScrollDir.Horizontal, itemRender= GridCell }
		local grid_node = self.grid_list:CreateView(t)
		grid_node:setPosition(ph.x, ph.y)
		self.grid_list:SetItemsInterval(12)
		self.node_t_list.layout_2.node:addChild(grid_node, 100)
		self.grid_list:SetGravity(ListViewGravity.CenterHorizontal)
	end

end

function PrivilegeAwardView:OpePrivilege()

	local view = ViewManager.Instance:GetView(ViewName.PrivilegeDialog)
	if view then
		view:SetData(self.cur_index)
		view:Flush()
	end
	self:OnClose()
	AudioManager.Instance:PlayClickBtnSoundEffect()

end

function PrivilegeAwardView:FlushAttrValue(key, value)
	if key == OBJ_ATTR.ACTOR_VIP_FLAG or 
		key == OBJ_ATTR.ACTOR_VIP_EXPIRE_TIME or
		 key == OBJ_ATTR.ACTOR_AVOIDINJURY or 
		 key == OBJ_ATTR.ACTOR_MAGIC_EQUIPID or 
		 key == OBJ_ATTR.ACTOR_MAGIC_EQUIPEXP then
		 self:Flush()
	end
end
function PrivilegeAwardView:RecevieAward()
	PrivilegeCtrl.SendAwardPrivilege(self.cur_data.vipType)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function PrivilegeAwardView:RecevieAllAward()
	local all_data = PrivilegeData.Instance:GetData()
	for i=1,#all_data do
		if all_data[i].state ~= 0 then
			local fectch_state = PrivilegeData.Instance:GetPrilivegeState(all_data[i].vipType)
			if fectch_state == 0 then
				PrivilegeCtrl.SendAwardPrivilege(all_data[i].vipType)
			end 
		end
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end