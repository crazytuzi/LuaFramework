PersonalBossTipView = PersonalBossTipView or BaseClass(XuiBaseView)

function PersonalBossTipView:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.config_tab  = {
							{"boss_ui_cfg", 8, {0},}
						}
	self.data = nil
	self.index = nil 
	self.can_enter = nil 
end

function PersonalBossTipView:__delete()
	
end

function PersonalBossTipView:ReleaseCallBack()
	if self.boss_reward_cell ~= nil then
		for k,v in pairs(self.boss_reward_cell) do
			v:DeleteMe()
		end
		self.boss_reward_cell = {}
	end
	if self.scene_event then
		 GlobalEventSystem:UnBind(self.scene_event)
		 self.scene_event = nil
	end
end

function PersonalBossTipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCells()
		XUI.AddClickEventListener(self.node_t_list.btn_enter_fuben_boss.node, BindTool.Bind1(self.EnterPersonalBossFuben, self), true)
		self.scene_event = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.ChangeScene, self))	
	end
end

function PersonalBossTipView:CreateCells()
	self.boss_reward_cell = {}
	for i = 1, 6 do
		local ph = self.ph_list.ph_first_reward_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 90*(i - 1), ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_personalboss_tip.node:addChild(cell:GetView(), 103)
		table.insert(self.boss_reward_cell, cell)
	end
end

function PersonalBossTipView:SetData(index,data, bool)
	self.index = index
	self.data = data
	self.can_enter = bool
	self:Flush()
end

function PersonalBossTipView:OpenCallBack()
	
end

function PersonalBossTipView:CloseCallBack(is_all)

end

function PersonalBossTipView:ShowIndexCallBack(index)

end

function PersonalBossTipView:OnFlush(flush_param_t, index)
	if self.data == nil or self.index == nil then return end
	self.node_t_list.txt_my_time.node:setString(string.format(Language.Boss.RemainTime, self.data.enter_time, (self.data.time_limit or 3)))
	RichTextUtil.ParseRichText(self.node_t_list.rich_fuben_name.node, self.data.boss_name, 22)
	XUI.RichTextSetCenter(self.node_t_list.rich_fuben_name.node)
	local txt = ""
	if self.data.levellimit[1] == 0 then
		txt = string.format(Language.Boss.ConsumeLevel, self.data.levellimit[2] or 0)
	else
		txt = string.format(Language.Boss.ConsumeCircle, self.data.levellimit[1] or 0, self.data.levellimit[2] or 0)
	end
	self.node_t_list.txt_enter_condition.node:setString(txt)
	local reward_data = BossData.Instance:GetPersonalBossReward()
	local cur_data = reward_data[self.index]
	local single_data = cur_data[1] or {}
	for k, v in pairs(single_data) do
		if self.boss_reward_cell[k] ~= nil then
			self.boss_reward_cell[k]:SetData(v)
		end
	end
end

function PersonalBossTipView:EnterPersonalBossFuben()
	if self.data ~= nil then
		if self.data.enter_time >= self.data.time_limit then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Boss.NotTimes)
		else
			if self.can_enter == true then
				BossCtrl.Instance:SendEnterBossSceneReq(self.data.boss_pos)
			else
				SysMsgCtrl.Instance:FloatingTopRightText(Language.Boss.TipBossDess)
			end
		end
	end
end

function PersonalBossTipView:ChangeScene()
	self:Close()
end

