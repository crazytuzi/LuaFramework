ItemGetItemTip = ItemGetItemTip or BaseClass(XuiBaseView)

function ItemGetItemTip:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.def_index = 0
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.config_tab = {
		{"itemtip_ui_cfg", 11, {0}}
	}
end

function ItemGetItemTip:__delete()
end

function ItemGetItemTip:ReleaseCallBack()
	if self.item_list then
		self.item_list:DeleteMe()
		self.item_list = nil
	end	
end	

function ItemGetItemTip:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local ph = self.ph_list.ph_getchange_list
		self.item_list = ListView.New()
 		self.item_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ItemGetItemTipCell, nil, nil, self.ph_list.ph_getchange_item)
 		self.item_list:SetItemsInterval(4)
 		self.item_list:SetJumpDirection(ListView.Left)
		self.root_node:addChild(self.item_list:GetView(), 100)
	end	
end	

function ItemGetItemTip:OnFlush(param_t, index)
	local item = param_t["item"]
	if item then
		local cfg = ItemData.GetItemToItemConfig(item.item_id)
		if cfg then
			local item_list = {}
			local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
			local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
			for i = 1,#cfg.select_items do
				local cfg_info = cfg.select_items[i]
				
				if cfg_info.job == nil or cfg_info.job == -1 or cfg_info.job == job then
					if cfg_info.sex == nil or cfg_info.sex == -1 or cfg_info.sex == sex then
						local item_info = {}
						item_info.index = i
						item_info.data = cfg_info
						item_info.src_item = item
						table.insert(item_list,item_info)
					end		
				end	
			end	
			self.item_list:SetDataList(item_list)
		end	
	end	
end	


ItemGetItemTipCell = ItemGetItemTipCell or BaseClass(BaseRender)
function ItemGetItemTipCell:__delete()
	if self.rew_cell then
		self.rew_cell:DeleteMe()
		self.rew_cell = nil
	end
end

function ItemGetItemTipCell:CreateChild()
	BaseRender.CreateChild(self)
	if not self.rew_cell then
		self.rew_cell = BaseCell.New()
		self.rew_cell:SetShowProfFlag(true)
		self.rew_cell:GetView():setAnchorPoint(0.5, 0.5)
		self.rew_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)

		self.view:addChild(self.rew_cell:GetView(), 9)
		XUI.AddClickEventListener(self.node_tree.change_get_btn.node,BindTool.Bind(self.OnBtnClick,self))
	end	
end

function ItemGetItemTipCell:OnBtnClick()
	if self.data then
		BagCtrl.Instance:SendUseItemByItem(self.data.src_item,0,1,self.data.index,"")
		ViewManager.Instance:Close(ViewName.ItemGetItemTip)
	end	
end	

function ItemGetItemTipCell:OnFlush()
	if not self.data then return end
	
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.data.id)
	self.rew_cell:SetData({item_id = item_cfg.id,is_bind = 0})
	self.node_tree.name_text.node:setString(item_cfg.name)
end

function ItemGetItemTipCell:CreateSelectEffect()
end

