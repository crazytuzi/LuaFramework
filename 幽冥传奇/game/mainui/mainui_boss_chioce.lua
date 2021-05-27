MainuiBossChioce = MainuiBossChioce or BaseClass(XuiBaseView)

function MainuiBossChioce:__init()
	self.can_penetrate = false
	self.is_any_click_close = true
	self.view = nil
	self.config_tab = {
		{"boss_temp_ui_cfg", 2, {0}},
	}
	self:SetRootNodeOffPos({x = -300, y = 0})
end

function MainuiBossChioce:__delete()
	self.view = nil
end

function MainuiBossChioce:ReleaseCallBack()
	if self.boss_listview then
		self.boss_listview:DeleteMe()
		self.boss_listview = nil
	end
end

function MainuiBossChioce:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self:LeiTaiBossChoice()
		local data = MainuiData.Instance:GetBossData()
		self.boss_listview:SetDataList(data)
	end
end

-- 选择BOSS
function MainuiBossChioce:LeiTaiBossChoice()
	if not self.boss_listview then
		local ph = self.ph_list.ph_boss_item
		self.boss_listview = ListView.New()
		self.boss_listview:Create(ph.x, ph.y, ph.w, ph.h, direction, MainuiBossItemReander, nil, false, self.ph_list.ph_item_boss)
		self.boss_listview:SetItemsInterval(10)
		self.boss_listview:SetMargin(5)
		self.boss_listview:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_leitai_boss.node:addChild(self.boss_listview:GetView(), 100)
	end
end

function MainuiBossChioce:OnFlush(paramt,index)
	
end

function MainuiBossChioce:ShowIndexCallBack(index)
	self:Flush(index)
end

function MainuiBossChioce:CloseCallBack()
end

-- 选择boss render
MainuiBossItemReander = MainuiBossItemReander or BaseClass(BaseRender)
function MainuiBossItemReander:__init()
	-- self.item_cell = nil
end

function MainuiBossItemReander:__delete()
end	

function MainuiBossItemReander:CreateChild()
	BaseRender.CreateChild(self)


	XUI.AddClickEventListener(self.node_tree.img_btn.node, BindTool.Bind1(self.OnBossBtn, self), true)
end
	
function MainuiBossItemReander:OnFlush()
	local data = ConfigManager.Instance:GetMonsterConfig(self.data.boss_data.monsterId)
	local name = DelNumByString(data.name)
	self.node_tree.img_btn.node:setTitleText(name)
	self.node_tree.img_btn.node:setEnabled(self.data.is_skill == 0)

end	

function MainuiBossItemReander:OnBossBtn()
	local boss_pos, boss_id = self.data.pos, self.data.npcId
	Scene.Instance:GetMainRole():LeaveFor(Scene.Instance:GetSceneId(), boss_pos[1], boss_pos[2], MoveEndType.NpcTask, boss_id, 1)
end

-- 创建选中特效
function MainuiBossItemReander:CreateSelectEffect()
end



