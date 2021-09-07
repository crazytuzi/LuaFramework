ForgeUpStarView = ForgeUpStarView or BaseClass(BaseRender)

local star_num = 10

function ForgeUpStarView:__init()	
	self.cell_list = {}
	self.select_index = 1
	self.equip_index = 0

	--self.old_star_level = 0  --用于升星成功提示
end

function ForgeUpStarView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.attr_tips then
		self.attr_tips:DeleteMe()
		self.attr_tips = nil
	end

	if self.mining_delay then
		GlobalTimerQuest:CancelQuest(self.mining_delay)
		self.mining_delay = nil
	end
end

function ForgeUpStarView:LoadCallBack()
	self.equip_index = ForgeData.Instance:GetDefaultEquipIndex()

	self.cur_level = self:FindVariable("cur_level")
	self.total_level = self:FindVariable("total_level")

	self.cur_attr_name = self:FindVariable("cur_attr_name")
	self.next_attr_name = self:FindVariable("next_attr_name")
	self.cur_attr_value = self:FindVariable("cur_attr_value")
	self.next_attr_value = self:FindVariable("next_attr_value")

	self.cur_power = self:FindVariable("cur_power")
	self.next_power = self:FindVariable("next_power")
	self.total_power = self:FindVariable("total_power")
	self.is_max_level = self:FindVariable("is_max_level")
	self.is_total_max_level = self:FindVariable("is_total_max_level")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_num = self:FindVariable("item_num")

	self.exp_radio = self:FindVariable("exp_radio")
	self.cur_process = self:FindVariable("cur_process")

	self.star_img_list = {}
	for i = 1, star_num do
		self.star_img_list[i] = self:FindVariable("star_img" .. i)
	end

	self.equip_list = self:FindObj("UpStarList")
	self.list_view_delegate = self.equip_list.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.attr_tips = UpStarAttrTips.New(self:FindObj("AttrTips"))
	self.attr_tips:SetActive(false)

	-- local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	-- if equip_data then
	-- 	self.old_star_level =  equip_data.param.star_level
	-- end

	self:ListenEvent("OnClickUpStar", BindTool.Bind(self.OnClickUpStar, self))
	self:ListenEvent("OnClickTotalAttr", BindTool.Bind(self.OnClickTotalAttr, self))
	self:ListenEvent("OnClickCloseTips", BindTool.Bind(self.OnClickCloseTips, self))
	self:ListenEvent("OnClickDescTips", BindTool.Bind(self.OnClickDescTips, self))

	self:Flush()
end

function ForgeUpStarView:GetNumberOfCells()
	return EquipData.Instance:GetDataCount()
end

function ForgeUpStarView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local equip_cell = self.cell_list[cell]
	if equip_cell == nil then
		equip_cell = UpStarItemCell.New(cell.gameObject)
		equip_cell.parent_view = self
		self.cell_list[cell] = equip_cell
	end
	equip_cell:SetIndex(data_index)
	local data = ForgeData.Instance:GetCurEquipList()
	equip_cell:SetData(data[data_index])
end

function ForgeUpStarView:SetSelectIndex(select_index, equip_index)
	self.select_index = select_index
	self.equip_index = equip_index
end

function ForgeUpStarView:GetSelectIndex()
	return self.select_index or 1
end

function ForgeUpStarView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function ForgeUpStarView:OnClickUpStar()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end
	
	local level = equip_data.param.star_level + 1 > ForgeData.Instance:GetUpStarMaxLevel() and ForgeData.Instance:GetUpStarMaxLevel() or equip_data.param.star_level + 1
	local attr = ForgeData.Instance:GetUpStarSingleCfg(self.equip_index, level)
	local has_num = ItemData.Instance:GetItemNumInBagById(attr.stuff_id)
	if has_num <= 0 then
		TipsCtrl.Instance:ShowItemGetWayView(attr.stuff_id)
		return
	end
	--self.old_star_level =  equip_data.param.star_level
	ForgeCtrl.Instance:SendUpStarReq(self.equip_index)
end

function ForgeUpStarView:OnClickTotalAttr()
	if self.attr_tips.root_node.gameObject.activeSelf then
		self.attr_tips:SetActive(false)
	else
		self.attr_tips:SetData()
		self.attr_tips:SetActive(true)
	end
end

function ForgeUpStarView:OnClickCloseTips()
	self.attr_tips:SetActive(false)
end

function ForgeUpStarView:OnClickDescTips()
	TipsCtrl.Instance:ShowHelpTipView(13)
end

function ForgeUpStarView:FlushStar()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end
	
	local star_level = equip_data.param.star_level
	local star_index = math.floor(star_level % 10)
	local star_res = math.floor(star_level / 10)
	for i = 1, star_num do
		if i <= star_index then
			local bundle, asset= ResPath.GetForgeImg("star_" .. (star_res + 1))
			self.star_img_list[i]:SetAsset(bundle, asset)
		else
			local bundle, asset= ResPath.GetForgeImg("star_" .. star_res)
			self.star_img_list[i]:SetAsset(bundle, asset)
		end
	end
end

function ForgeUpStarView:FlushStuffItem()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end
	
	local level = equip_data.param.star_level + 1 > ForgeData.Instance:GetUpStarMaxLevel() and ForgeData.Instance:GetUpStarMaxLevel() or equip_data.param.star_level + 1
	local attr = ForgeData.Instance:GetUpStarSingleCfg(self.equip_index, level)
	local has_num = ItemData.Instance:GetItemNumInBagById(attr.stuff_id)

	self.item_cell:SetShowNumTxtLessNum(-1)
	self.item_cell:SetData({item_id = attr.stuff_id, num = has_num, is_bind = 0})

	if has_num <= 0 then
		self.item_num:SetValue(ToColorStr(has_num, TEXT_COLOR.RED) .. "/" .. 1)
	else
		self.item_num:SetValue(ToColorStr(has_num, TEXT_COLOR.GREEN) .. "/" .. 1) -- 策划说写死一个
	end
end

function ForgeUpStarView:FlushUpStarAttr()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end
	
	self.cur_level:SetValue(string.format(Language.Forge.StarLevel, equip_data.param.star_level))

	local level_sum = 0
	for k,v in pairs(EquipData.Instance:GetDataList()) do
		level_sum = level_sum + v.param.star_level
	end
	self.total_level:SetValue(string.format(Language.Forge.StarLevel, level_sum))

	local cur_attr = ForgeData.Instance:GetUpStarSingleCfg(self.equip_index, equip_data.param.star_level)
	local next_attr = ForgeData.Instance:GetUpStarSingleCfg(self.equip_index, equip_data.param.star_level + 1)

	if nil == cur_attr or nil == next(cur_attr) then
		local cur_attr_name = ForgeData.Instance:GetUpStarShowAttr(next_attr)
		self.cur_attr_value:SetValue(0)
		self.cur_attr_name:SetValue(Language.Common.AttrNameNoUnderline[cur_attr_name] .. "：")
		self.cur_power:SetValue(0)
	else
		local cur_attr_name = ForgeData.Instance:GetUpStarShowAttr(cur_attr)
		self.cur_attr_value:SetValue(cur_attr[cur_attr_name])
		self.cur_attr_name:SetValue(Language.Common.AttrNameNoUnderline[cur_attr_name] .. "：")
		local cur_power = CommonDataManager.GetCapabilityCalculation(cur_attr)
		self.cur_power:SetValue(cur_power)
	end

	if nil ~= next_attr and nil ~= next(next_attr) then
		local next_attr_name = ForgeData.Instance:GetUpStarShowAttr(next_attr)
		self.next_attr_value:SetValue(next_attr[next_attr_name])
		self.next_attr_name:SetValue(Language.Common.AttrNameNoUnderline[next_attr_name] .. "：")
		local next_power = CommonDataManager.GetCapabilityCalculation(next_attr)
		self.next_power:SetValue(next_power)
	end

	local total_attr = ForgeData.Instance:GetStarTotalAttr()
	local total_cap = CommonDataManager.GetCapabilityCalculation(total_attr)
	self.total_power:SetValue(total_cap)

	self.is_max_level:SetValue(equip_data.param.star_level >= ForgeData.Instance:GetUpStarMaxLevel())
	self.is_total_max_level:SetValue(ForgeData.Instance:GetIsUpStarMaxLevel())
end

function ForgeUpStarView:FlushProgress()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end

	local next_level = equip_data.param.star_level + 1
	local next_star_attr = ForgeData.Instance:GetStarAttr(self.equip_index, next_level)

	if nil ~= next_star_attr then
		local attr = ForgeData.Instance:GetStarAttr(self.equip_index, next_level)
		self.cur_process:SetValue(equip_data.param.star_exp .. "/" .. attr.need_exp)
		if equip_data.param.star_exp / attr.need_exp == 0 then
			self.exp_radio:SetValue(1)

			if self.mining_delay == nil then  -- 没有方法解决了，有新方法优化一下吧
				self.mining_delay = GlobalTimerQuest:AddDelayTimer(function ()
					self.exp_radio:SetValue(equip_data.param.star_exp / attr.need_exp)
					GlobalTimerQuest:CancelQuest(self.mining_delay)
					self.mining_delay = nil
				end, 0)
			end
		else
			self.exp_radio:SetValue(equip_data.param.star_exp / attr.need_exp)
		end
	else
		self.cur_process:SetValue("0/0")
		self.exp_radio:InitValue(0)	
	end
end

function ForgeUpStarView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			if v.need_flush == nil or v.need_flush then
				if self.select_index == 1 then
					self.equip_list.scroller:ReloadData(0)
				else
					self.equip_list.scroller:RefreshAndReloadActiveCellViews(true)
				end
			end

			self:FlushStar()
			self:FlushStuffItem()
			self:FlushUpStarAttr()
			self:FlushProgress()
		end
	end
end

------------------------UpStarItemCell------------------------------
UpStarItemCell = UpStarItemCell or BaseClass(BaseCell)

function UpStarItemCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
	self.name = self:FindVariable("name")
	self.level = self:FindVariable("level")
	self.show_hl = self:FindVariable("show_hl")
	self.show_red_point = self:FindVariable("show_red_point")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function UpStarItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function UpStarItemCell:ClickItem()
	local select_index = self.parent_view:GetSelectIndex()
	self.parent_view:SetSelectIndex(self.index, self.data.index)
	self.parent_view:FlushAllHL()
	self.parent_view:Flush("all", {need_flush = false})
end

function UpStarItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.name:SetValue(cfg.name)
	self.item_cell:SetData({item_id = self.data.item_id, num = self.data.num, is_bind = self.data.is_bind})

	self.level:SetValue(string.format(Language.Forge.StarLevel, self.data.param.star_level))

	self:FlushHL()

	self.show_red_point:SetValue(ForgeData.Instance:GetUpStarRemindByIndex(self.data.index))
end

function UpStarItemCell:FlushHL()
	local select_index = self.parent_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end

-------------UpStarAttrTips--------------------------------
UpStarAttrTips = UpStarAttrTips or BaseClass(BaseCell)

function UpStarAttrTips:__init()
	self.cur_attr_value = self:FindVariable("cur_attr_value")
	self.next_attr_value = self:FindVariable("next_attr_value")
	self.cur_level = self:FindVariable("cur_level")
	self.next_level = self:FindVariable("next_level")
	self.cur_total_attr = self:FindVariable("cur_total_attr")
	self.next_total_attr = self:FindVariable("next_total_attr")
end

function UpStarAttrTips:__delete()

end

function UpStarAttrTips:OnFlush()
	local level = ForgeData.Instance:GetStarTotalLevel()
	local cur_cfg, next_level, next_cfg = ForgeData.Instance:GetStarAddCfgAndNextLevel()

	self.cur_level:SetValue(level)
	self.next_level:SetValue(next_level)
	self.cur_attr_value:SetValue(cur_cfg.per_pvp_hurt_reduce / 100 .. "%")
	self.next_attr_value:SetValue(next_cfg.per_pvp_hurt_reduce / 100 .. "%")
	self.cur_total_attr:SetValue(CommonDataManager.GetCapabilityCalculation(cur_cfg))
	self.next_total_attr:SetValue(CommonDataManager.GetCapabilityCalculation(next_cfg))
end