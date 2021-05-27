SuccessTip = SuccessTip or BaseClass(XuiBaseView)

function SuccessTip:__init()
	self.is_modal = true
	self.is_any_click_close = false
	--self:SetIsAnyClickClose(false)
	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/fuben.png"
	self.config_tab  = {
							-- {"fuben_child_view_ui_cfg", 2, {0},},
							{"fuben_child_view_ui_cfg", 9, {0},},
						}
	self.page = nil 
	self.level = nil 
	self.my_data = nil
	self.star_list = nil 
	self.reward = 1
	self.reward_cell = {}
	self.star_list = {}
end

function SuccessTip:__delete()
	
end

function SuccessTip:ReleaseCallBack()
	if self.reward_cell ~= nil then
		for i,v in ipairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
	if self.scene_event then
		 GlobalEventSystem:UnBind(self.scene_event)
		 self.scene_event = nil
	end
	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end

	self.effec = nil
end

function SuccessTip:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCell()
		self:CreateStar()
		--self.node_t_list.layout_boss_reward.node:setVisible(false)
		XUI.AddClickEventListener(self.node_t_list.layout_exit.node, BindTool.Bind1(self.OnExitFuben, self))
		XUI.AddClickEventListener(self.node_t_list.btn_get_reward.node, BindTool.Bind1(self.OnGetReward, self))
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.OnGetReward, self))
		XUI.AddClickEventListener(self.node_t_list.btn_get_reward_dou.node, BindTool.Bind1(self.OnGetRewarddouble, self))
		self.scene_event = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.ChangeScene, self))

		self.effec = RenderUnit.CreateEffect(10, self.node_t_list.btn_get_reward_dou.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		self.effec:setScaleY(0.9)
		self.effec:setScaleX(0.5)
	end
end

function SuccessTip:OnGetReward()
	StrenfthFbCtrl.Instance:GetFubenReWard(0)
	if self:IsOpen() then
		self:Close()
	end
end

function SuccessTip:OnGetRewarddouble()
	if self.alert_view == nil then
		self.alert_view = Alert.New()
	end
	local gold_num = StrenfthFbData.Instance:GetDoubleLinQuConsume(self.page, self.level)
	local txt = string.format(Language.StrenfthFb.LingQuShuoMing, gold_num)
	self.alert_view:SetLableString(txt)
	self.alert_view:SetOkFunc(BindTool.Bind2(self.SendAgreeHandler, self))
	self.alert_view:Open()
end

function SuccessTip:SendAgreeHandler()
	StrenfthFbCtrl.Instance:GetFubenReWard(1)
	local gold_num = StrenfthFbData.Instance:GetDoubleLinQuConsume(self.page, self.level)
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= gold_num then
		if self:IsOpen() then
			self:Close()
		end
	end
end

function SuccessTip:SetData(page, level, star_num, reward_num)
	self.count = star_num
	self.page = page 
	self.level = level
	self.reward = reward_num
	self:Flush()
end

function SuccessTip:OnFlush()
	self:StarVisible(self.count)
	local data = StrenfthFbData.Instance:GetSuccessReward(self.page, self.level, self.count)
	self.node_t_list.txt_tonguang_time.node:setString("")
	local cur_data = {}
	for i, v in ipairs(data) do
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				cur_data[i] = {["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
			end
		else
			cur_data[i] = {item_id = v.id, num = v.count, is_bind = 0}
		end
	end
	for i, v in ipairs(self.reward_cell) do
		if #cur_data >= i then
			v:GetView():setVisible(true)
			self.node_t_list["rew_val_"..i].node:setVisible(true)
		else
			v:GetView():setVisible(false)
			self.node_t_list["rew_val_"..i].node:setVisible(false)
		end
	end
	for i, v in ipairs(cur_data) do
		self.node_t_list["rew_val_"..i].node:setString("x"..v.num * (self.reward or 1))
	end
	for i, v in ipairs(cur_data) do
		self.reward_cell[i]:SetData({item_id = v.item_id, num = 1, is_bind = 0})
	end
	for i, v in ipairs(self.reward_cell) do
		local ph = self.ph_list["ph_rew_"..i]
		if #cur_data == 1 then
			v:GetView():setPositionX(ph.x + 105)
			self.node_t_list["rew_val_"..i].node:setPositionX(ph.x + 105)
		elseif #cur_data == 2 then
			v:GetView():setPositionX(ph.x + 55)
			self.node_t_list["rew_val_"..i].node:setPositionX(ph.x + 45)
		end
	end
end

function SuccessTip:CreateCell()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_rew_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_strength_success.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

function SuccessTip:CreateStar()
	self.star_list = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_star_"..i]
		local file = ResPath.GetCommon("star_2_1")	
		local start = XUI.CreateImageView(ph.x + 35 , ph.y + 40, file)
		self.node_t_list.layout_strength_success.node:addChild(start, 999)
		table.insert(self.star_list, start)
	end
end

function SuccessTip:StarVisible(star)
	for i,v in pairs(self.star_list) do
		if star >= i then
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end
end

function SuccessTip:OpenCallBack()
end

function SuccessTip:CloseCallBack()
end

function SuccessTip:OnExitFuben()
	-- Scene.Instance:QuitActiveFubenReq(1)
	-- if self:IsOpen() then
	-- 	self:Close()
	-- end
end

function SuccessTip:ChangeScene()
	self:Close()
end