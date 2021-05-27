FuncNoteTipView = FuncNoteTipView or BaseClass(XuiBaseView)

function FuncNoteTipView:__init()
	self:SetModal(false)
	self.can_penetrate = true
	self.texture_path_list[1] = 'res/xui/funcnote.png'
	self.texture_path_list[2] = 'res/xui/boss.png'
	self.config_tab  = {
		-- {"func_note_ui_cfg",1,{0},}
		{"func_note_ui_cfg",2,{0},}
	}
	self.cur_max_idx = 0
end

function FuncNoteTipView:__delete()

end	

function FuncNoteTipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
	-- XUI.SetRichTextVerticalSpace(self.node_t_list.desc_rich_text.node,10)
		self.node_t_list.btn_close.node:addClickEventListener(BindTool.Bind(self.CloseView, self))
		self:CreateList()
		if self.cur_max_idx < 2 then
			self.func_note_list:SetJumpDirection(ListView.Top)
		else	
			self.func_note_list:SetJumpDirection(ListView.Bottom)
		end
		self.achieve_handler = GlobalEventSystem:Bind(AchievementEventType.ACHIEVE_STATE_CHANGE, BindTool.Bind(self.FlushData, self))
	end	
end	
function FuncNoteTipView:ReleaseCallBack()
	if self.func_note_list then
		self.func_note_list:DeleteMe()
		self.func_note_list = nil 
	end
	if self.achieve_handler then
		GlobalEventSystem:UnBind(self.achieve_handler)
		self.achieve_handler = nil
	end

	ClientCommonButtonDic[CommonButtonType.FUNCNOTE_DATA_GRID] = nil

end	
function FuncNoteTipView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FuncNoteTipView:SetCurMaxIdx(idx)
	self.cur_max_idx = idx
end

function FuncNoteTipView:FlushData()
	local data =  GuideData.Instance:GetNewFuncNoteCfg()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)		-- 人物转生等级
	local show_acts_data = {}
	for i = 1, self.cur_max_idx, 1 do
		local v = data[i]
		v.is_not_open = false
		table.insert(show_acts_data, v)
	end
	local one_data
	if self.cur_max_idx < 2 then
		for i = 1 + self.cur_max_idx, 3 do
			one_data = data[i]
			one_data.is_not_open = true
			table.insert(show_acts_data, one_data)
		end
	elseif self.cur_max_idx < #data then
		one_data = data[self.cur_max_idx + 1]
		one_data.is_not_open = true
		table.insert(show_acts_data, one_data)
	end
	self.func_note_list:SetDataList(show_acts_data)

end

function FuncNoteTipView:CreateList()
	if self.func_note_list == nil then
		local ph = self.ph_list.ph_func_note_list
		self.func_note_list = ListView.New()
		self.func_note_list:SetIsUseStepCalc(false)
		self.func_note_list:Create(ph.x, ph.y, ph.w, ph.h, nil, FuncNoteItem, nil, nil, self.ph_list.ph_type_item)
		self.node_t_list["new_fun_note_tip_layout"].node:addChild(self.func_note_list:GetView(), 5)
		-- self.func_note_list:SetMargin(5)
		-- self.func_note_list:SetItemsInterval(10)
		-- self.func_note_list:SelectIndex(1)
		self.func_note_list:GetView():setAnchorPoint(0, 0)
		-- self.func_note_list:SetJumpDirection(ListView.Bottom)
		--self.func_note_list:SetSelectCallBack(BindTool.Bind1(self.SelectEquipListCallBack, self))

		ClientCommonButtonDic[CommonButtonType.FUNCNOTE_DATA_GRID] = self.func_note_list
	end
end
function FuncNoteTipView:OnFlush(params_t)
	-- local guide = params_t["all"]
	-- self.node_t_list.title_img.node:loadTexture(ResPath.GetFuncNotePic("title_" .. guide.mainui_icon))
	-- self.node_t_list.desc_img.node:loadTexture(ResPath.GetFuncNotePic("desc_" .. guide.mainui_icon))
	-- RichTextUtil.ParseRichText(self.node_t_list.desc_rich_text.node,guide.desc)
	self:FlushData()
end	
function FuncNoteTipView:CloseView()
	self:Close()
end
FuncNoteItem = FuncNoteItem or BaseClass(BaseRender)
function FuncNoteItem:__init()

end

function FuncNoteItem:__delete()

	if self.fetch_state_list then
		self.fetch_state_list:DeleteMe()
		self.fetch_state_list = nil
	end
end

function FuncNoteItem:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_gift_list = {}
	ph = self.ph_list.ph_cells_list
	local item_ui_cfg = self.ph_list.ph_awards_cell_1
	local interval = (ph.w - item_ui_cfg.w * 3) / 2
	self.fetch_state_list = ListView.New()
	self.fetch_state_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftAwarRender, nil, nil, item_ui_cfg)
	self.fetch_state_list:SetItemsInterval(interval)
	self.view:addChild(self.fetch_state_list:GetView(), 99)
	self.fetch_state_list:GetView():setTouchEnabled(false)
	self.node_tree.btn_getawards.node:addClickEventListener(BindTool.Bind(self.GetAward, self))
	self.node_tree.btn_join.node:addClickEventListener(BindTool.Bind(self.OnJoin, self))
end

function FuncNoteItem:OnFlush()
	if not self.data then return end
	self.node_tree.img_icon.node:loadTexture(ResPath.GetMainui("icon_" .. string.format("%02d",self.data.icon) .. "_img"))
	self.node_tree.txt_name.node:setString(self.data.name)
	local level_circle = ""
	if self.data.circle == 0 then
		level_circle = self.data.level ..Language.Common.Ji
	else	
		level_circle = self.data.circle .. Language.Common.Zhuan
	end	
	self.node_tree.txt_level.node:setString(level_circle)
	self.node_tree.txt_desc.node:removeAllElements()
	RichTextUtil.ParseRichText(self.node_tree.txt_desc.node, self.data.describe,20, COLOR3B.WHITE)
	local str = ""
	if not self.data.is_not_open then
		str = Language.Common.FuncNoteState[1]
		self.node_tree.txt_level.node:setColor(COLOR3B.GREEN)
		self.node_tree.txt_stat.node:setColor(COLOR3B.GREEN)
	else
		str = Language.Common.FuncNoteState[2]
		self.node_tree.txt_level.node:setColor(COLOR3B.RED)
		self.node_tree.txt_stat.node:setColor(COLOR3B.RED)
	end
	self.node_tree.txt_stat.node:setString(str)
	self.node_tree.txt_num.node:setVisible(false)
	local config_tab = AchieveData.GetAchieveConfig(self.data.achieveId)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local cur_data = {}
	local index = 1
	for i1, v1 in ipairs(config_tab[1].awards) do
		if v1.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v1.type)
			if virtual_item_id then
				table.insert(cur_data, {["item_id"] = virtual_item_id, ["num"] = 1, is_bind = 0})
			end
		else
			if v1.job == prof then
				if v1.sex == -1 or v1.sex == sex then
					table.insert(cur_data, {item_id = v1.id, num = v1.count, is_bind = v1.bind})
				end	
			elseif v1.job == nil then
				table.insert(cur_data, {item_id = v1.id, num = v1.count, is_bind = v1.bind})
			end
		end
	end
	self.fetch_state_list:SetDataList(cur_data)
	local ph = self.ph_list.ph_cells_list
	local len = #cur_data
	if len < 3 then
		local item_ui_cfg = self.ph_list.ph_awards_cell_1
		local interval = self.fetch_state_list:GetView():getItemsInterval()
		local w = item_ui_cfg.w * len + (len - 1) * interval
		self.fetch_state_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.fetch_state_list:GetView():setPosition(ph.x, ph.y)
	end	

	if len == 1 then
		self.node_tree.txt_num.node:setVisible(true)
		self.node_tree.txt_num.node:setString("X".. cur_data[1].num)
	end	
	local is_finish = AchieveData.Instance:GetAwardState(self.data.achieveId) 
	if is_finish.reward == 1 then
		self.node_tree.btn_getawards.node:setEnabled(false)
	else	
		self.node_tree.btn_getawards.node:setEnabled(true)
	end	
	-- XUI.SetLayoutImgsGrey(self.view, self.data.is_not_open == true, false)
	-- XUI.SetLayoutImgsGrey(self.node_tree.btn_getawards.node, self.data.is_not_open == true, false)

end

function FuncNoteItem:GetAward()
	if not self.data then return end
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)		-- 人物转生等级
	if circle_level >= self.data.circle then
		if role_level < self.data.level then
			SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.Common.FuncNoteGetAward,self.data.level))
		else	
			AchieveCtrl.Instance:SendAchieveRewardReq(self.data.achieveId)
		end	
	else		
		SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.Common.FuncNoteGetAwardCircle,self.data.circle))
	end	
end

function FuncNoteItem:OnJoin()
	if self.data == nil then return end
	if ActivityData.IsSwitchToOtherView(self.data.teleId) then
		local tele_cfg = ActivityData.GetCommonTeleCfg(self.data.teleId)
		ActivityCtrl.Instance:OpenOneActView(tele_cfg)
	else
		Scene.Instance:CommonSwitchTransmitSceneReq(self.data.teleId)
	end
	-- ViewManager.Instance:Close(ViewName.FuncNoteTip)
end

function FuncNoteItem:CompareGuideData(data)
	return self.data and self.data.achieveId == data[1]
end	

function FuncNoteItem:GetGuideView(data)
	if data[2] then
		return self.node_tree.btn_join.node
	end	
	return self.node_tree.btn_getawards.node
end	