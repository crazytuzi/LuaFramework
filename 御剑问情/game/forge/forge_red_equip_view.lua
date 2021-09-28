ForgeRedEquipView = ForgeRedEquipView or BaseClass(BaseRender)

local CAN_COMPOSE_COLOR_LIMIT = 4	-- 橙色
local XIAN_PIN_TYPE_LIST = {
	[1] = 58,
	[2] = 59,
	[3] = 60,
}
local EFFECT_CD = 1

function ForgeRedEquipView:__init(instance, parent)
	self.parent = parent
	self.parent:SetClickCallBack(TabIndex.forge_red_equip, BindTool.Bind(self.OnClickEquipitem, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickJinJie", BindTool.Bind(self.OnClickJinJie, self))

	local item_l = ItemCell.New()
	item_l:SetInstanceParent(self:FindObj("LeftItem"))
	self.left_item = item_l

	local item_r = ItemCell.New()
	item_r:SetInstanceParent(self:FindObj("RightItem"))
	self.right_item = item_r

	local item_c = ItemCell.New()
	item_c:SetInstanceParent(self:FindObj("CostItem"))
	item_c:SetShowNumTxtLessNum(99999)
	self.cost_item = item_c

	self.show_info = self:FindVariable("ShowInfo")
	self.show_succed_effect = self:FindVariable("ShowSuccedEffect")
	self.show_succed_effect:SetValue(false)

	self.left_equip_name = self:FindVariable("LeftEquipName")
	self.right_equip_name = self:FindVariable("RightEquipName")
	self.need_prop_name = self:FindVariable("NeedPropName")
	self.need_prop_num = self:FindVariable("NeedPropNum")
	self.bag_prop_num = self:FindVariable("BagPropNum")

	self.now_select_index = 0
	self.effect_cd = 0
end

function ForgeRedEquipView:__delete()
	self.parent = nil

	if nil ~= self.left_item then
		self.left_item:DeleteMe()
		self.left_item = nil
	end

	if nil ~= self.right_item then
		self.right_item:DeleteMe()
		self.right_item = nil
	end

	if nil ~= self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end
end

function ForgeRedEquipView:CloseCallBack()
	self:ResetEffect()
end

function ForgeRedEquipView:ResetEffect()
	if nil ~= self.show_succed_effect then
		self.show_succed_effect:SetValue(false)
	end
end

function ForgeRedEquipView:OnClickHelp()
	local tips_id = 183
  	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeRedEquipView:OnClickJinJie()
	ForgeCtrl.Instance:SendEquipJinjie(self.now_select_index)
end

function ForgeRedEquipView:OnClickEquipitem(index, data)
	index = index or 0
	data = data or EquipData.Instance:GetDataList()[index]
	if nil == data
		or nil == data.item_id
		or data.item_id <= 0 then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		return
	end
	
	self.now_select_index = index
	if item_cfg.color < CAN_COMPOSE_COLOR_LIMIT then
		self:Flush()
		return
	end

	self:Flush()
end

function ForgeRedEquipView:SetLeftItemData()
	local data = EquipData.Instance:GetDataList()[self.now_select_index]

	if nil == data
		or nil == data.item_id
		or data.item_id <= 0 then
		self.left_equip_name:SetValue("")
		return
	end

	self.left_item:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		self.left_equip_name:SetValue("")
		return
	end

	if not ForgeData.Instance:CheckEquipCanSelect(data) then
		self.show_info:SetValue(false)
		return
	end

	self.left_equip_name:SetValue(string.format(Language.Common.ToColor, SOUL_NAME_COLOR[item_cfg.color], item_cfg.name))

	local xianpin_type_list = data.param and data.param.xianpin_type_list or {}
	local cfg = ForgeData.Instance:GetRedEquipComposeCfg(data.item_id, #xianpin_type_list)
end

function ForgeRedEquipView:SetPreviewItemData()
	local data = EquipData.Instance:GetDataList()[self.now_select_index]
	if nil == data
		or nil == data.item_id
		or data.item_id <= 0 then
		self.right_equip_name:SetValue("")
		return
	end

	local xianpin_type_list = data.param and data.param.xianpin_type_list or {}
	local cfg = ForgeData.Instance:GetRedEquipComposeCfg(data.item_id, #xianpin_type_list)

	if nil == cfg then
		self.right_equip_name:SetValue("")
		return
	end
	local need_item = cfg.stuff_item
	self.cost_item:SetData(need_item)
	self:SetCostInfo(need_item)

	local new_data = {}
	new_data.item_id = cfg.gain_item > 0 and cfg.gain_item or data.item_id
	if cfg.xianpin_num > 0 then
		new_data.param = {xianpin_type_list = {}}
		for i = 1, cfg.xianpin_num do
			table.insert(new_data.param.xianpin_type_list, XIAN_PIN_TYPE_LIST[i])
		end
	end
	self.right_item:SetData(new_data)

	local right_equip_name = ""
	local right_item_cfg = ItemData.Instance:GetItemConfig(cfg.gain_item)
	if nil ~= right_item_cfg then
		right_equip_name = string.format(Language.Common.ToColor, SOUL_NAME_COLOR[right_item_cfg.color], right_item_cfg.name)
	end
	self.right_equip_name:SetValue(right_equip_name)

end

function ForgeRedEquipView:SetCostInfo(need_item)
	if nil == need_item then return end

	local item_cfg = ItemData.Instance:GetItemConfig(need_item.item_id)
	if nil == item_cfg then return end

	self.need_prop_name:SetValue(string.format(Language.Common.ToColor, SOUL_NAME_COLOR[item_cfg.color], item_cfg.name))
	self.need_prop_num:SetValue(need_item.num)
	local count = ItemData.Instance:GetItemNumInBagById(need_item.item_id)
	if count < need_item.num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Mount.ShowBlueNum, count)
	end
	self.bag_prop_num:SetValue(count)
end

function ForgeRedEquipView:IsNoEquip()
	local data_list = EquipData.Instance:GetDataList()
	if nil == data_list or nil == next(data_list) then
		return true
	end
	for _, v in pairs(data_list) do
		if nil ~= v.item_id and v.item_id > 0 then
			if ForgeData.Instance:CheckEquipCanSelect(v) then
				return false
			end
		end
	end
	return true
end

function ForgeRedEquipView:PlaySuccedEffet()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		self.show_succed_effect:SetValue(false)
		self.show_succed_effect:SetValue(true)
	    self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ForgeRedEquipView:OnFlush()
	self.show_info:SetValue(not self:IsNoEquip())
	self:SetLeftItemData()
	self:SetPreviewItemData()
end