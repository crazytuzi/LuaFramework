--材料副本列表(进入不同副本的窗口)
MaterialFbListView = MaterialFbListView or BaseClass(XuiBaseView)

function MaterialFbListView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(false)
	-- self.is_async_load = false
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self.texture_path_list[2] = 'res/xui/charge.png'
	self.texture_path_list[3] = 'res/xui/limit_activity.png'
	self.config_tab = {
		-- {"fuben_child_view_ui_cfg", 1, {0}},
		{"fuben_child_view_ui_cfg", 5, {0}},
	}
	self.fb_list_view = nil

end

function MaterialFbListView:__delete()

end

function MaterialFbListView:OpenCallBack()
	FubenCtrl.Instance:MaterialFbDataReq()
end

function MaterialFbListView:CloseCallBack()
end

function MaterialFbListView:ReleaseCallBack()
	if self.material_event then
		GlobalEventSystem:UnBind(self.material_event)
		self.material_event = nil
	end
	if self.fb_list_view then
		self.fb_list_view:DeleteMe()
		self.fb_list_view = nil
	end
	
end

function MaterialFbListView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateFBList()
		self:OnMaterialFbDataChange()
		self.material_event = GlobalEventSystem:Bind(MaterialFbEventType.MATERIAL_FB_DATA_CHANGE, BindTool.Bind(self.OnMaterialFbDataChange, self))
	end
end

function MaterialFbListView:ShowIndexCallBack(index)
	self:Flush()
end

function MaterialFbListView:OnFlush(param_t, index)
	-- self:OnMaterialFbDataChange()
end

function MaterialFbListView:CreateFBList()
	local ph = self.ph_list.ph_fb_item_list
	self.fb_list_view = ListView.New()
 	self.fb_list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, MaterialFbEntryRender, nil, nil, self.ph_list.ph_fb_item)
 	self.fb_list_view:SetItemsInterval(3)
 	self.fb_list_view:SetJumpDirection(ListView.Left)
 	self.fb_list_view:SetIsUseStepCalc(false)
	self.node_t_list.layout_fuben_list.node:addChild(self.fb_list_view:GetView(), 100)
	local list_data = FubenData.Instance:GetMaterialFbCfg()
	self.fb_list_view:SetDataList(list_data)
end

function MaterialFbListView:OnMaterialFbDataChange()
	local data_t = FubenData.Instance:GetMaterialFbData()
	for i, v in ipairs(data_t) do
		if self.fb_list_view and self.fb_list_view:GetItemAt(i) then
			self.fb_list_view:GetItemAt(i):FlushRestTime(v)
		end
	end
end




--MaterialFbEntryRender
MaterialFbEntryRender = MaterialFbEntryRender or BaseClass(BaseRender)
function MaterialFbEntryRender:__init()
	self.cells_t = {}
end

function MaterialFbEntryRender:__delete()
	for k, v in pairs(self.cells_t) do
		v:DeleteMe()
	end
	self.cells_t = {}
end

function MaterialFbEntryRender:CreateChild()
	BaseRender.CreateChild(self)
	for i = 0, 2 do
		local ph = self.ph_list["ph_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetCell():setVisible(false)
		self.view:addChild(cell:GetView(), 99)
		self.cells_t[i] = cell
	end
	-- self.node_tree.btn_enter.node:setEnabled(false)
	 XUI.RichTextSetCenter(self.node_tree.rest_time.node)
	XUI.AddClickEventListener(self.node_tree.btn_enter.node, BindTool.Bind(self.OnEnterClick, self), true)
end

function MaterialFbEntryRender:OnFlush()
	if not self.data then return end
	local server_open_days = OtherData.Instance:GetOpenServerDays()
	self.node_tree.lbl_fb_name.node:setString(self.data.name)
	self.node_tree.lbl_openLv.node:setString(string.format(Language.Common.ZhuanLvCond, self.data.lvLimit[1], self.data.lvLimit[2]))
	local need_award = {}
	for k, v in pairs(self.data.fubenAwards) do
		if server_open_days >= v.cond[1] and server_open_days <= v.cond[2] then
			need_award = v.awards
		end
	end
	self:SetCellsData(need_award)
end

function MaterialFbEntryRender:FlushRestTime(timeData)
	local rest_time = self.data.dailyEnterTimes - timeData.enterTime
	local costIndex = (timeData.enterTime + 1) <= self.data.dailyEnterTimes and timeData.enterTime + 1 or self.data.dailyEnterTimes
	local color = rest_time > 0 and "00ff00" or "ff2828"
	-- PrintTable(self.data["enterConsume" .. costIndex])
	local item_cfg = ItemData.Instance:GetItemConfig(self.data["enterConsume" .. costIndex][1].id)
	-- print("消耗次数物品id = ", self.data["enterConsume" .. costIndex].id)

	local name = item_cfg.name
	local cost = self.data["enterConsume" .. costIndex][1].count
	if self.node_tree.lbl_cost then
		self.node_tree.lbl_cost.node:setString(string.format(Language.Fuben.MaterialEnterCost, name, cost))
		local content = string.format(Language.Fuben.MaterialRestCnt, color, rest_time)
		RichTextUtil.ParseRichText(self.node_tree.rest_time.node, content, 20)
		self.node_tree.btn_enter.node:setEnabled(rest_time > 0)
	end
end

function MaterialFbEntryRender:SetCellsData(need_award)
	local awardCnt = #need_award
	for i, v in ipairs(self.cells_t) do
		local item_id = nil
		if awardCnt == 1 or awardCnt == 0 then
			self.cells_t[i]:GetCell():setVisible(i == 0)
			if next(need_award) then
				item_id = need_award[1].id
				if need_award[1].type > 0 then
					item_id = ItemData.Instance:GetVirtualItemId(need_award[1].type)
				end 
				self.cells_t[0]:SetData({item_id = item_id, num = 0, is_bind = need_award[1].bind})
			end
		else
			self.cells_t[i]:GetCell():setVisible(i ~= 0)
			if next(need_award) then
				for i_2, v_2 in ipairs(need_award) do
					item_id = v_2.id
					if v_2.type > 0 then
						item_id = ItemData.Instance:GetVirtualItemId(v_2.type)
					end 
					self.cells_t[i_2]:SetData({item_id = item_id, num = 0, is_bind = v_2.bind})
				end
			end
		end
	end
	
end

function MaterialFbEntryRender:OnEnterClick()
	FubenCtrl.Instance:EnterMaterialFbReq(self.index)
end

function MaterialFbEntryRender:CreateSelectEffect()

end