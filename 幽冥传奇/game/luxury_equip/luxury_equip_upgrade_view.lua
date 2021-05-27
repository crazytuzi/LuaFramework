LuxuryEquipUpgradeView = LuxuryEquipUpgradeView or BaseClass(BaseView)

function LuxuryEquipUpgradeView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/role.png'
	}
	self.config_tab = {
		{"role1_ui_cfg", 7, {0}},
	}
	self.need_del_objs = {}
	self.consume_cell_list = {}
	self.pos = nil
	self.eff = nil
	self.eff_2 = nil
	self.eff_3 = nil
	-- require("scripts/game/layout_luxury_equip_upgrade/name").New(ViewDef.LuxuryEquipUpgrade.name)
end

function LuxuryEquipUpgradeView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
	self.need_del_objs = {}
	self.data = nil

	if self.eff then
		self.eff:setStop()
		self.eff = nil
	end

	if self.eff_2 then
		self.eff_2:setStop()
		self.eff_2 = nil
	end

	if self.eff_3 then
		self.eff_3:setStop()
		self.eff_3 = nil
	end
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function LuxuryEquipUpgradeView:LoadCallBack(index, loaded_times)
	self.data = LuxuryEquipUpgradeData.Instance				--数据
	self.master_cell = LuxuryEquipUpgradeView.LuxuryEquipUpgradeCell.New()
	self.master_cell:SetPosition(self.ph_list.ph_master_cell.x, self.ph_list.ph_master_cell.y)
	self.node_t_list.layout_luxury_equip_upgrade.node:addChild(self.master_cell:GetView(), 10)
	table.insert(self.need_del_objs, self.master_cell)

	for i = 1, 6 do
		self.consume_cell_list[i] = LuxuryEquipUpgradeView.LuxuryEquipUpgradeCell.New()
		self.consume_cell_list[i]:SetPosition(self.ph_list["ph_cell_" .. i].x, self.ph_list["ph_cell_" .. i].y)
		self.node_t_list.layout_luxury_equip_upgrade.node:addChild(self.consume_cell_list[i]:GetView(), 10)
		table.insert(self.need_del_objs, self.consume_cell_list[i])
	end

	self.product_cell = LuxuryEquipUpgradeView.LuxuryEquipUpgradeCell.New()
	self.product_cell:SetPosition(self.ph_list.ph_product_cell.x, self.ph_list.ph_product_cell.y)
	self.node_t_list.layout_luxury_equip_upgrade.node:addChild(self.product_cell:GetView(), 10)
	table.insert(self.need_del_objs, self.product_cell)

	if self.eff == nil then
		self.eff = AnimateSprite:create()
		self.node_t_list.layout_luxury_equip_upgrade.node:addChild(self.eff,3)
		self.eff:setPosition(300, 405)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1110)
	self.eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

	

	
	XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnClickBUpgrade, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChangeCallBack, self, 1))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
end

function LuxuryEquipUpgradeView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function LuxuryEquipUpgradeView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function LuxuryEquipUpgradeView:ShowIndexCallBack(index)
	self:Flush(index)
end

function LuxuryEquipUpgradeView:OnFlush(param_t, index)
	if param_t.param then
		self.pos = param_t.param.pos
		local item_id = param_t.param.item_id
		local upgrade_cfg = self.data:GetUpgradeCfg(self.pos, item_id)
		if upgrade_cfg then
			self.master_cell:SetData(self.data:FarmatCellData({item_id = item_id}))

			for i = 1, 6 do
				self.consume_cell_list[i]:SetData(self.data:FarmatCellData(ItemData.FormatItemData(upgrade_cfg.consume[i] or {})))
			end

			self.product_cell:SetData(self.data:FarmatCellData({item_id =  upgrade_cfg.itemId}))
			local item_cfg = ItemData.Instance:GetItemConfig(upgrade_cfg.itemId)
			self.node_t_list.txt_product_name.node:setString(item_cfg and item_cfg.name or "")
		else
			self.master_cell:SetData(nil)	
			for i = 1, 6 do
				self.consume_cell_list[i]:SetData(nil)
			end
			self.product_cell:SetData(nil)
			self.node_t_list.txt_product_name.node:setString("")
		end
		
	end

end

function LuxuryEquipUpgradeView:OnClickBUpgrade()
	LuxuryEquipUpgradeCtrl.SendLuxuryEquipUpgrade(self.pos)
end

function LuxuryEquipUpgradeView:OnBagItemChangeCallBack()
	local item_data = EquipData.Instance:GetEquipDataBySolt(self.pos)
	self:Flush(0, "param", {pos = self.pos, item_id = item_data and item_data.item_id or 0})

	
end

function LuxuryEquipUpgradeView:OnChangeOneEquip(data)
	if data == nil then return end
	if (data.slot >= EquipData.EquipSlot.itSubmachineGunPos and data.slot <= EquipData.EquipSlot.itGentlemenBootsPos) then
		if self.eff_2 == nil then
			self.eff_2 = AnimateSprite:create()
			self.node_t_list.layout_luxury_equip_upgrade.node:addChild(self.eff_2,999)
			self.eff_2:setPosition(300, 365)
		end
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1111)
		
		self.eff_2:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)

		if self.delay_time then
			GlobalTimerQuest:CancelQuest(self.delay_time)
			self.delay_time = nil
		end
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function ( ... )
			if self.eff_3 == nil then
				self.eff_3 = AnimateSprite:create()
				self.node_t_list.layout_luxury_equip_upgrade.node:addChild(self.eff_3,999)
				self.eff_3:setPosition(310, 410)
			end
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1112)
			self.eff_3:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
		end, 0.95)
		
	end
end

------------------------------------------------------------------------------------------------------------------------
LuxuryEquipUpgradeView.LuxuryEquipUpgradeCell = LuxuryEquipUpgradeView.LuxuryEquipUpgradeCell or BaseClass(BaseCell)
function  LuxuryEquipUpgradeView.LuxuryEquipUpgradeCell:OnFlush()
	BaseCell.OnFlush(self)
	if nil == self.data then return end
	self:SetRightBottomText(self.data.num .. "/" .. self.data.need_num, COLOR3B.GREEN)
	if self.data.need_num > self.data.num then
		self:MakeGray(true)
	else
		self:MakeGray(false)
	end
end
