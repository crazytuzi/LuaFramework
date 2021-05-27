------ShopItemRender------------
ComposeShopItemRender = ComposeShopItemRender or BaseClass(BaseRender)
function ComposeShopItemRender:__init()
	self.item_cell = nil
end

function ComposeShopItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ComposeShopItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	-- self.item_cell:SetEventEnabled(false)
	self.item_cell:GetView():setAnchorPoint(cc.p(0,0))
	self.view:addChild(self.item_cell:GetView(), 100)
	
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
end

function ComposeShopItemRender:OnClickBuyBtn()
	if self.data.item_cfg then
		if self.data.item_cfg.price[1].type == 2 then
			BagCtrl.Instance:BindYBBuy(self.data.item_cfg, 1,self.data.item_cfg.item)
		else	
			ShopCtrl.BuyItemFromStore(self.data.item_cfg.id, 1, self.data.item_cfg.item, 1)
		end	
	end	
end

function ComposeShopItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ComposeShopItemRender:OnFlush()
	
	if nil == self.data or nil == self.data.item_cfg then
		return
	end
	
	local shop_cfg = self.data.item_cfg

	local item_config = ItemData.Instance:GetItemConfig(shop_cfg.item)
	if nil == item_config then
		return
	end
	self.item_cell:SetData({["item_id"] = shop_cfg.item, ["num"] = 1})

	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.lbl_item_name.node:setString(item_config.name)

	local cost_path = ShopData.GetMoneyTypeIcon(shop_cfg.price[1].type)
	self.node_tree.img_cost.node:loadTexture(cost_path)
	self.node_tree.lbl_item_cost.node:setColor(COLOR3B.WHITE)
	self.node_tree.lbl_item_cost.node:setString(shop_cfg.price[1].price)
end

function ComposeShopItemRender:CreateSelectEffect()
end


------GodArmItemRender------------
ComposeGodArmItemRender = ComposeGodArmItemRender or BaseClass(BaseRender)
function ComposeGodArmItemRender:__init()
	self.item_cell = nil
end

function ComposeGodArmItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ComposeGodArmItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
	-- self.item_cell = BaseCell.New()
	-- self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	-- -- self.item_cell:SetEventEnabled(false)
	-- self.item_cell:GetView():setAnchorPoint(cc.p(0,0))
	-- self.view:addChild(self.item_cell:GetView(), 100)
	
end

function ComposeGodArmItemRender:OnClick()
	-- if nil ~= self.click_callback then
	-- 	self.click_callback(self)
	-- end
end

function ComposeGodArmItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local path = ResPath.GetItem(self.data.icon)
	self.node_tree.img_icon.node:loadTexture(path)
	-- self.node_tree.txt_name.node:setString(self.data.name)
	-- self.node_tree.img_name.node:loadTexture()
	self.node_tree.img_bg_1.node:setGrey(self.data.can_selec == false)
	self.node_tree.img_icon.node:setGrey(self.data.can_selec == false)
end

function ComposeGodArmItemRender:CreateSelectEffect()
	local ph = self.ph_list.ph_selec_effec
	self.select_effect = XUI.CreateImageView(ph.x, ph.y, ResPath.GetGodArm("god_arm_img_3"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end


------ComposeGodArmAttrRender------------
ComposeGodArmAttrRender = ComposeGodArmAttrRender or BaseClass(BaseRender)
function ComposeGodArmAttrRender:__init()
	
end

function ComposeGodArmAttrRender:__delete()
	
end

function ComposeGodArmAttrRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
end

function ComposeGodArmAttrRender:OnFlush()
	if nil == self.data then
		return
	end
	self.node_tree.txt_attr_name.node:setString(self.data.type_str .. "：")
	self.node_tree.txt_attr_val.node:setString(self.data.value_str)
end

function ComposeGodArmAttrRender:CreateSelectEffect()
end

------GodArmLightItem------------
GodArmLightItem = GodArmLightItem or BaseClass(BaseRender)
function GodArmLightItem:__init()
	
end

function GodArmLightItem:__delete()
	
end

function GodArmLightItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
end

function GodArmLightItem:OnFlush()
	if nil == self.data then
		return
	end
	-- self.view:setVisible(self.data.is_lit == false)
	-- self.node_tree.img_light_bg.node:setVisible(true)
	self.node_tree.img_light_lock.node:setVisible(self.data.is_lit == false)
end

function GodArmLightItem:CreateSelectEffect()
end