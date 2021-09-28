TouShiHuanHuaView = TouShiHuanHuaView or BaseClass(BaseView)

function TouShiHuanHuaView:__init()
	self.ui_config = {"uis/views/appearance_prefab", "TouShiHuanHuaView"}
	self.click_func = BindTool.Bind(self.ClickItem, self)
	self.item_change_func = BindTool.Bind(self.ItemChangeCallBack, self)
end

function TouShiHuanHuaView:__delete()
end

function TouShiHuanHuaView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	self.list_view = nil
	self.name = nil
	self.maxhp = nil
	self.gongji = nil
	self.fangyu = nil
	self.fight_power = nil
	self.item_str = nil
	self.is_active = nil
	self.is_max = nil
	self.power_up_value = nil
	self.is_used = nil
	self.cur_level = nil
end

function TouShiHuanHuaView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickUpGrade",BindTool.Bind(self.ClickUpGrade, self))
	self:ListenEvent("ClickUsed",BindTool.Bind(self.ClickUsed, self))

	self.name = self:FindVariable("name")
	self.maxhp = self:FindVariable("maxhp")
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.fight_power = self:FindVariable("fight_power")
	self.item_str = self:FindVariable("item_str")
	self.is_active = self:FindVariable("is_active")
	self.is_max = self:FindVariable("is_max")
	self.power_up_value = self:FindVariable("power_up_value")
	self.is_used = self:FindVariable("is_used")
	self.cur_level = self:FindVariable("cur_level")

	self.list_data = {}
	self.cell_list = {}

	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.model = RoleModel.New("toushi_huan_hua_panel")
	self.model:SetDisplay(self:FindObj("display").ui3d_display)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
end

function TouShiHuanHuaView:CloseWindow()
	self:Close()
end

function TouShiHuanHuaView:ClickUpGrade()
	local data = self.list_data[self.select_index]
	if data == nil then
		return
	end

	local image_id = data.image_id
	local data_list = ItemData.Instance:GetBagItemDataList()
	local is_active = TouShiData.Instance:GetHuanHuaIsActiveByImageId(image_id)
	local huanhua_cfg_info = TouShiData.Instance:GetHuanHuaCfgInfo(image_id)
	if huanhua_cfg_info == nil then
		return
	end
	
	if not is_active then
		for k, v in pairs(data_list) do
			if v.item_id == data.item_id then
				PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
				return
			end
		end
		self:ItemNotEnough(huanhua_cfg_info)
	else	
		local have_num = ItemData.Instance:GetItemNumInBagById(huanhua_cfg_info.stuff_id)
		local need_num = huanhua_cfg_info.stuff_num or 0
		if have_num < need_num then
			self:ItemNotEnough(huanhua_cfg_info)
			return	
		end
		TouShiCtrl.Instance:SendTouShiSpecialImgUpgrade(data.image_id)
	end
end

function TouShiHuanHuaView:ItemNotEnough(huanhua_cfg_info)
	local cfg = ConfigManager.Instance:GetAutoConfig("shop_auto")
	local item_cfg = cfg and cfg.item[huanhua_cfg_info.stuff_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(huanhua_cfg_info.stuff_id)
		return
	end

	if item_cfg.bind_gold == 0 then
		TipsCtrl.Instance:ShowShopView(huanhua_cfg_info.stuff_id, 2)
		return
	end

	local func = function(stuff_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(stuff_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, huanhua_cfg_info.stuff_id, nil, huanhua_cfg_info.stuff_num)
end

function TouShiHuanHuaView:ClickUsed()
	local data = self.list_data[self.select_index]
	if data == nil then
		return
	end

	local image_id = data.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000
	TouShiCtrl.Instance:SendUseTouShiImage(image_id)
end

function TouShiHuanHuaView:GetNumberOfCells()
	return #self.list_data
end

function TouShiHuanHuaView:RefreshCell(cell, data_index)
	data_index = data_index + 1

	local huanhua_cell = self.cell_list[cell]
	if nil == huanhua_cell then
		huanhua_cell = TouShiHuanHuaCell.New(cell.gameObject)
		huanhua_cell:SetToggleGroup(self.list_view.toggle_group)
		huanhua_cell:SetClickCallBack(self.click_func)

		self.cell_list[cell] = huanhua_cell
	end

	--重新设置高亮
	huanhua_cell:SetToggleIsOn(self.select_index == data_index)
	huanhua_cell:SetIndex(data_index)
	huanhua_cell:SetData(self.list_data[data_index])
end

function TouShiHuanHuaView:ClickItem(cell)
	if cell == nil then
		return
	end

	local data = cell:GetData()
	if data == nil then
		return
	end

	local index = cell:GetIndex()
	if self.select_index == index then
		return
	end

	self.select_index = index

	self:FlushView()
end

function TouShiHuanHuaView:FlushView()
	self:FlushContent()
	self:FlushItem()
	self:FlushModel()
end

function TouShiHuanHuaView:FlushContent()
	local data = self.list_data[self.select_index]
	if data == nil then
		return
	end

	local image_id = data.image_id

	local huanhua_cfg_info = TouShiData.Instance:GetHuanHuaCfgInfo(image_id)
	if huanhua_cfg_info == nil then
		return
	end

	local now_level = TouShiData.Instance:GetHuanHuaGrade(image_id)
	local max_level = TouShiData.Instance:GetSpecialImgMaxLevel()
	local power = CommonDataManager.GetCapabilityCalculation(huanhua_cfg_info)
	local next_hunahua_cfg_info = nil
	local add_power = 0
	local is_active = TouShiData.Instance:GetHuanHuaIsActiveByImageId(image_id)
	local is_used = TouShiData.Instance:GetHuanHuaIdIsUsed(image_id, true)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local color = item_cfg and item_cfg.color or 1
	
	if now_level < max_level then	--获取下一级的幻化信息
		next_hunahua_cfg_info = TouShiData.Instance:GetHuanHuaCfgInfo(image_id, now_level + 1)
	end
	
	if next_hunahua_cfg_info ~= nil then
		add_power = CommonDataManager.GetCapabilityCalculation(next_hunahua_cfg_info) - power
	end

	self.maxhp:SetValue(huanhua_cfg_info.maxhp)
	self.gongji:SetValue(huanhua_cfg_info.gongji)
	self.fangyu:SetValue(huanhua_cfg_info.fangyu)
	self.fight_power:SetValue(power)
	self.is_max:SetValue(now_level >= max_level)
	self.power_up_value:SetValue(add_power)
	self.is_active:SetValue(is_active)
	self.is_used:SetValue(is_used)
	self.name:SetValue("<color="..Common_Five_Rank_Color[color]..">"..data.image_name.."</color>")
end

function TouShiHuanHuaView:FlushItem()
	local data = self.list_data[self.select_index]
	if data == nil then
		return
	end

	local image_id = data.image_id
	local level = TouShiData.Instance:GetHuanHuaGrade(image_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local level_color = item_cfg and item_cfg.color or 1
	local is_active = TouShiData.Instance:GetHuanHuaIsActiveByImageId(image_id)
	local color_str = is_active and string.format(Language.Mount.HuanHuaLevel, Common_Five_Rank_Color[color], level) or ""
	self.cur_level:SetValue(color_str)

	local item_id = data.item_id
	self.item_cell:SetData({item_id = item_id})

	local huanhua_cfg_info = TouShiData.Instance:GetHuanHuaCfgInfo(image_id)
	if huanhua_cfg_info == nil then
		return
	end

	local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local need_num = huanhua_cfg_info.stuff_num or 0
	local color = have_num >= need_num and TEXT_COLOR.BLUE_4 or TEXT_COLOR.RED
	local item_str = string.format("%s / %s", ToColorStr(have_num, color), ToColorStr(need_num, TEXT_COLOR.BLACK_1))
	self.item_str:SetValue(item_str)
end

function TouShiHuanHuaView:FlushModel()
	local data = self.list_data[self.select_index]
	if data == nil then
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local info = {}
	info.prof = main_vo.prof
	info.sex = main_vo.sex
	info.appearance = {}
	info.appearance.fashion_body = main_vo.appearance.fashion_body
	info.appearance.toushi_used_imageid = data.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000

	self.model:ResetRotation()
	self.model:SetModelResInfo(info, true, true, true, true, true, true)
end

function TouShiHuanHuaView:FlushList()
	self.list_data = TouShiData.Instance:GetHuanHuaCfgList() or {}
	self.list_view.scroller:ReloadData(0)
end

function TouShiHuanHuaView:FlushListRemind()
	for _, v in pairs(self.cell_list) do
		v:FlushRemind()
	end
end

function TouShiHuanHuaView:ItemChangeCallBack()
	self:Flush("flush_item")
end

function TouShiHuanHuaView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_func)

	self.select_index = 1

	self:FlushList()
	self:Flush()
end

function TouShiHuanHuaView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_func)
end

function TouShiHuanHuaView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "flush_item" then
			self:FlushItem()
			self:FlushContent()
			self.list_view.scroller:RefreshAndReloadActiveCellViews(false)
		else
			self:FlushView()
		end
	end
end

---------------------------------------------------------------------------------------------------
TouShiHuanHuaCell = TouShiHuanHuaCell or BaseClass(BaseCell)
function TouShiHuanHuaCell:__init()
	self.name = self:FindVariable("name")
	self.remind = self:FindVariable("remind")
	self.is_use = self:FindVariable("is_use")
	self.can_use = self:FindVariable("can_use")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function TouShiHuanHuaCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TouShiHuanHuaCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function TouShiHuanHuaCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function TouShiHuanHuaCell:FlushRemind()
	if self.data == nil then
		return
	end

	local image_id = self.data.image_id

	--已满级没红点
	if TouShiData.Instance:GetHuanHuaGrade(image_id) >= TouShiData.Instance:GetSpecialImgMaxLevel() then
		self.remind:SetValue(false)
		return
	end

	local huanhua_cfg_info = TouShiData.Instance:GetHuanHuaCfgInfo(image_id)
	if huanhua_cfg_info == nil then
		return
	end

	local remind = ItemData.Instance:GetItemNumIsEnough(self.data.item_id, huanhua_cfg_info.stuff_num)
	self.remind:SetValue(remind)
end

function TouShiHuanHuaCell:OnFlush()
	if self.data == nil then
		return
	end

	local image_id = self.data.image_id or 0
	local data_item_id = self.data.item_id or 0
	local name = self.data.image_name or ""
	local is_active = TouShiData.Instance:GetHuanHuaIsActiveByImageId(image_id)
	local is_use = TouShiData.Instance:GetHuanHuaIdIsUsed(image_id, true)
	local item_cfg = ItemData.Instance:GetItemConfig(data_item_id)
	local color = item_cfg and item_cfg.color or 1
	local name_str = ToColorStr(name, Common_Five_Rank_Color[color])

	self.can_use:SetValue(is_active)
	self.is_use:SetValue(is_use)
	self.item_cell:SetData({item_id = data_item_id})
	self.name:SetValue(name_str)

	self:FlushRemind()
end