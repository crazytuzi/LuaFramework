ComposeLookView = ComposeLookView or BaseClass(XuiBaseView)

function ComposeLookView:__init()
	self.texture_path_list[1] = 'res/xui/compose.png'
	self.config_tab = {
		{"compose_ui_cfg", 6, {0}},
	}
	self:SetIsAnyClickClose(true)
	self:SetModal(true)
end

function ComposeLookView:__delete()	
end

function ComposeLookView:ReleaseCallBack()
	if nil ~= self.look_scroll_list then
		self.look_scroll_list:DeleteMe()
		self.look_scroll_list = nil
	end	
end


function ComposeLookView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		if nil == self.look_scroll_list then
			local ph = self.ph_list.ph_compose_list
			self.look_scroll_list = ListView.New()
			self.look_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ComposeBroswerItemRender, nil, nil, self.ph_list.ph_list_item)
			self.node_t_list.list_container.node:addChild(self.look_scroll_list:GetView(), 100)
			self.look_scroll_list:SetJumpDirection(ListView.Top)
		end
	end
end


function ComposeLookView:OnFlush(param_t, index)
	
	for k,v in pairs(param_t) do
		if k == "type" then
			local cfg = ComposeData.Instance:GetConfigByType(v.type)
			local list = {}
			local equip_type, hand_pos = ComposeData.Instance:GetItemTypeByComposeType(v.type)
			local equip = EquipData.Instance:GetEquipByType(equip_type, hand_pos)
			local n = 1
			if equip ~= nil then
				n = ComposeData.Instance:GetStepStar(equip.compose_level)
				if (n + 4) >= #cfg then
					n = #cfg - 4
				end
			end
			for i = n, n + 4 do -- 只显示5个
				table.insert(list,{config = cfg[i],desc = Language.Compose.StepDesc[i],level = i * 10})
			end	
			self.look_scroll_list:SetDataList(list)
		end
	end		
end



------ComposeBroswerItemRender------------
ComposeBroswerItemRender = ComposeBroswerItemRender or BaseClass(BaseRender)
function ComposeBroswerItemRender:__init()
	self.item_cell = nil
end

function ComposeBroswerItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ComposeBroswerItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_cell_item.x, self.ph_list.ph_cell_item.y)
	-- self.item_cell:SetEventEnabled(false)
	self.item_cell:GetView():setAnchorPoint(cc.p(0,0))
	self.view:addChild(self.item_cell:GetView(), 100)
end

function ComposeBroswerItemRender:OnClickBuyBtn()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ComposeBroswerItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ComposeBroswerItemRender:OnFlush()
	
	if nil == self.data then
		return
	end
	local cfg = self.data.config
	
	local item_config = ItemData.Instance:GetItemConfig(cfg.itemId)
	if nil == item_config then
		return
	end
	self.item_cell:SetData({["item_id"] = cfg.itemId, ["num"] = 0, ["is_bind"] = 0,["compose_level"] = self.data.level})

	self.node_tree.titleText.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.titleText.node:setString(item_config.name)
	self.node_tree.descText.node:setString(self.data.desc)
end

function ComposeBroswerItemRender:CreateSelectEffect()
end