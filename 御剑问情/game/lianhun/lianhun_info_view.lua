--魂炼
LianhunInfoView = LianhunInfoView or BaseClass(BaseRender)
local old_index = ""
local Defult_Icon_List = {
	[1] = "icon_toukui",
	[2] = "icon_yifu",
	[3] = "icon_kuzi",
	[4] = "icon_xiezi",
	[5] = "icon_hushou",
	[6] = "icon_xianglian",
	[7] = "icon_wuqi",
	[8] = "icon_jiezhi",
	[9] = "icon_yaodai",
	[10] = "icon_jiezhi"
}
local EQUIO_SORT = {1, 7, 2, 5, 9, 6, 3, 8, 4, 10,}
function LianhunInfoView:__init()
	self.cur_lv = self:FindVariable("CurLevel")
	self.next_lv = self:FindVariable("NextLevel")
	self.cur_cap = self:FindVariable("CurCap")
	self.next_cap = self:FindVariable("NextCap")
	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.btn_txt = self:FindVariable("BtnTxt")
	self.cur_name = self:FindVariable("CurName")
	self.next_name = self:FindVariable("NextName")

	self.display = self:FindObj("display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self.attr_cell_list = {}
	self.cur_attr_data = {}
	self.next_attr_data = {}
	-- self.equip_cell = ItemCell.New()
	-- self.equip_cell:SetInstanceParent(self:FindObj("CurEquipCell"))

	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("Material"))
	self.stuff_cell:SetDefualtBgState(false)
	self.stuff_num = self:FindVariable("MaterialNum")
	self.up_grade_limit_txt = self:FindVariable("UpGradeLimitTxt")
	self.can_up_grade = self:FindVariable("CanUpGarde")
	self.skill_lv = self:FindVariable("SkillLv")


	self.equip_list = {}
	local equip_parent = self:FindObj("EquipParent")
	PrefabPool.Instance:Load(AssetID("uis/views/lianhun_prefab","LianhunEquip"),
		function(prefab)
			for i = 1,10 do
				local obj = GameObject.Instantiate(prefab)
				obj.transform:SetParent(equip_parent.transform, false)
				obj = U3DObject(obj)
				item = LianhunEquipItemCell.New(obj)
				item.root_node.toggle.group = equip_parent.toggle_group
				local index = EQUIO_SORT[i] or 0
				item:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, item, index - 1))
				self.equip_list[index] = item
			end
			PrefabPool.Instance:Free(prefab)
			self:Flush()
		end)

	self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle
	self:ListenEvent("HelpClick", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OpenSkillTips", BindTool.Bind(self.OpenSkillTips, self))
		self:ListenEvent("OnClickLianhun", BindTool.Bind(self.OnClickLianhun, self))
	self.select_item_index = -1
end

function LianhunInfoView:__delete()
	if self.equip_list then
		for k,v in pairs(self.equip_list) do
			v:DeleteMe()
		end
	end
	self.equip_list ={}
	if self.attr_cell_list then
		for k,v in pairs(self.attr_cell_list) do
			v:DeleteMe()
		end
	end
	self.attr_cell_list ={}
	-- if self.equip_cell then
	-- 	self.equip_cell:DeleteMe()
	-- 	self.equip_cell = nil
	-- end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end
end

function LianhunInfoView:FlushCurAttrList()
	if nil == self.cur_attr_list then
		self.cur_attr_list = self:FindObj("CurAttrList")
		local list_delegate = self.cur_attr_list.list_simple_delegate
		list_delegate.NumberOfCellsDel = function ()
			return #self.cur_attr_data
		end
		list_delegate.CellRefreshDel = function (cell, data_index)
			local cell_item = self.attr_cell_list[cell]
			if cell_item == nil then
				cell_item = LianhunInfoAttrItem.New(cell.gameObject)
				self.attr_cell_list[cell] = cell_item
			end
			local data = self.cur_attr_data[data_index + 1]
			cell_item:SetData(data)
		end
	end
	if self.cur_attr_list.scroller.isActiveAndEnabled then
		self.cur_attr_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end


function LianhunInfoView:FlushNextAttrList()
	if nil == self.next_attr_list then
		self.next_attr_list = self:FindObj("NextAttrList")
		local list_delegate = self.next_attr_list.list_simple_delegate
		list_delegate.NumberOfCellsDel = function ()
			return #self.next_attr_data
		end
		list_delegate.CellRefreshDel = function (cell, data_index)
			local cell_item = self.attr_cell_list[cell]
			if cell_item == nil then
				cell_item = LianhunInfoAttrItem.New(cell.gameObject)
				self.attr_cell_list[cell] = cell_item
			end
			local data = self.next_attr_data[data_index + 1]
			cell_item:SetData(data)
		end
	end
	if self.next_attr_list.scroller.isActiveAndEnabled then
		self.next_attr_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function LianhunInfoView:OnClickEquipItem(cell, equip_index)
	if self.select_item_index == equip_index then
		if cell.data and cell.data.lianhun_level > 0 then
			LianhunCtrl.Instance:ShowEquipTips(cell.data)
		end
		return
	end

	self.select_item_index = equip_index
	self:SetRightInfo()
end

function LianhunInfoView:SetRightInfo()
	local data_list = EquipData.Instance:GetGridInfo() or {}
	-- self.equip_cell:SetData(data_list[self.select_item_index])

	local data = data_list[self.select_item_index] or {}
	local show_index = self.select_item_index + 1
	if self.select_item_index == GameEnum.EQUIP_INDEX_JIEZHI or self.select_item_index == GameEnum.EQUIP_INDEX_JIEZHI_2 then
		show_index = 20
	end
	if show_index > 0 and old_index ~= show_index then
		old_index = show_index
		local model_index = "000" .. show_index
		local bundle, asset = ResPath.GetForgeEquipModel(model_index)
		self.model:SetPanelName("lianhun_equip" .. show_index)
		self.model:SetMainAsset(bundle, asset)
	end
	local lianhun_level = data.lianhun_level or 0
	self.btn_txt:SetValue(lianhun_level < 1 and Language.Lianhun.BtnTxt[1] or Language.Lianhun.BtnTxt[2])
	local cur_cfg = LianhunData.Instance:GetEquipLianhuncfg(self.select_item_index, lianhun_level)
	local next_cfg = LianhunData.Instance:GetEquipLianhuncfg(self.select_item_index, lianhun_level + 1)
	self.cur_attr_data = {}
	local cur_attr =  CommonDataManager.GetAttributteByClass(cur_cfg or {})
	local next_attr =  CommonDataManager.GetAttributteByClass(next_cfg or {})
	if lianhun_level > 0 and cur_cfg then
		for k,v in pairs(cur_attr) do
			if v > 0 then
				table.insert(self.cur_attr_data, {key = k, value = v})
			end
		end
	elseif next_cfg then
		for k,v in pairs(next_attr) do
			if v > 0 then
				table.insert(self.cur_attr_data, {key = k, value = 0})
			end
		end
	end
	if cur_cfg then
		self.stuff_cell:SetData({item_id = cur_cfg.stuff_id, num = 1})
		self.stuff_cell:SetDefualtBgState(false)
		local name_str = "<color=%s>%s</color>"
		self.cur_name:SetValue(string.format(name_str, LIANHUN_NAME_COLOR_EQUIP[lianhun_level], cur_cfg.name))

		local num = ItemData.Instance:GetItemNumInBagById(cur_cfg.stuff_id)
		local color = num < cur_cfg.stuff_count and TEXT_COLOR.RED or TEXT_COLOR.YELLOW1
		local str = "<color=%s>%d</color> / %d"
		self.stuff_num:SetValue(string.format(str, color, num, cur_cfg.stuff_count))
	end
	self.cur_lv:SetValue(lianhun_level)
	self.cur_cap:SetValue(CommonDataManager.GetCapability(cur_attr))
	self:FlushCurAttrList()

	self.is_max_level:SetValue(next_cfg == nil)
	self.next_attr_data = {}
	if next_cfg then
		for k,v in pairs(next_attr) do
			if v > 0 then
				table.insert(self.next_attr_data, {key = k, value = v})
			end
		end
		self.next_lv:SetValue(lianhun_level + 1)
		local name_str = "<color=%s>%s</color>"
		self.next_name:SetValue(string.format(name_str, LIANHUN_NAME_COLOR_EQUIP[lianhun_level + 1], next_cfg.name))
		self.next_cap:SetValue(CommonDataManager.GetCapability(next_attr, true, cur_attr))
		self:FlushNextAttrList()
	end
	self.can_up_grade:SetValue(nil ~= next_cfg)
	self.skill_lv:SetValue(EquipData.Instance:GetMinLianhunLevel())
	local des_text = ""
	if nil == next_cfg then
		des_text = Language.Common.MaxLvTips
	end
	self.up_grade_limit_txt:SetValue(des_text)
end

function LianhunInfoView:OpenCallBack()
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	self.equip_change_callback = BindTool.Bind(self.OnEquipDataChange, self)
	EquipData.Instance:NotifyDataChangeCallBack(self.equip_change_callback)
	self:Flush()
end

function LianhunInfoView:CloseCallBack()
	old_index = ""
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_change_callback)
end

function LianhunInfoView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(268)
end

function LianhunInfoView:OpenSkillTips()
	local level = EquipData.Instance:GetMinLianhunLevel()
	local skill_info = LianhunData.Instance:GetEquipLianhunSuitcfg(level)
	local next_skill_info = LianhunData.Instance:GetEquipLianhunSuitcfg(level + 1)

	local skill_name = level > 0 and  skill_info.skill_name or next_skill_info.skill_name
	local skill_level = level
	local asset, bunble = ResPath.GetLianhunRes("LianhunSkill")
	local eff_asset = level > 0 and skill_info.effect_ab or next_skill_info.effect_ab
	local eff_bunble = level > 0 and skill_info.effect_show or next_skill_info.effect_show
	local now_des = ""
	local next_des = ""
	local levelup_des = ""
	if level > 0 then
		now_des = skill_info.skill_dec
	end
	if nil ~= next_skill_info then
		next_des = next_skill_info.skill_dec
		local name = LianhunData.Instance:GetEquipLianhunSuitName(next_skill_info.suit_level) or ""
		levelup_des = string.format(Language.Lianhun.LevelUpDes, name)
	end
	LianhunCtrl.Instance:ShowSkillTips(skill_name, skill_level, now_des, next_des, levelup_des, asset, bunble, eff_asset, eff_bunble)
end

function LianhunInfoView:OnClickLianhun()
	LianhunCtrl.Instance:SendEquipmentLianhunUplevel(self.select_item_index, self.auto_buy_toggle.isOn and 1 or 0)
end

function LianhunInfoView:OnFlush(param_t)
	if #self.equip_list < 10 then
		return
	end
	self:SetEquipData()
	self:SetRightInfo()
end

function LianhunInfoView:SetEquipData()
	local data_list = EquipData.Instance:GetGridInfo()
	for k, v in pairs(self.equip_list) do
		local data = data_list[k - 1]
		if data then

			if self.select_item_index == nil or self.select_item_index < 0 then
				self.select_item_index = k - 1
			end
			v:SetData(data)
			v:SetInteractable(true)
			v:SetHightLight(self.select_item_index == k - 1)
			local lianhun_level = data and data.lianhun_level or 0
			local cur_cfg = LianhunData.Instance:GetEquipLianhuncfg(k - 1, lianhun_level)
			local next_cfg = LianhunData.Instance:GetEquipLianhuncfg(k - 1, lianhun_level + 1)
			local show_arrow = false
			if cur_cfg and next_cfg then
				local num = ItemData.Instance:GetItemNumInBagById(cur_cfg.stuff_id)
				if cur_cfg.stuff_count <= num then
					show_arrow = true
				end
			end
			v:ShowArrow(show_arrow)
			if lianhun_level > 0 then
				v:SetColorLabel(ResPath.GetLianhunRes("colorlabel_" .. lianhun_level))
			else
				v:SetColorLabel("", "")
			end
		end
	end
end

function LianhunInfoView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.select_item_index and self.select_item_index >= 0 then
		self:Flush()
	end
end

function LianhunInfoView:OnEquipDataChange()
	if self.select_item_index and self.select_item_index >= 0 then
		self:Flush()
	end
end


LianhunInfoAttrItem = LianhunInfoAttrItem or BaseClass(BaseCell)

function LianhunInfoAttrItem:__init()
	self.value = self:FindVariable("AttrVal")
	self.add_attr = self:FindVariable("AddVal")
	self.attr_name = self:FindVariable("AttrName")
	self.attr_img = self:FindVariable("Img")
end

function LianhunInfoAttrItem:__delete()
end

function LianhunInfoAttrItem:OnFlush()
	if self.data == nil then return end
	self.value:SetValue(self.data.value)
	self.add_attr:SetValue(self.data.add_attr or 0)
	self.attr_name:SetValue(CommonDataManager.GetAttrName(self.data.key))
	self.attr_img:SetAsset(ResPath.GetBaseAttrIcon(self.data.key))
end



LianhunEquipItemCell = LianhunEquipItemCell or BaseClass(BaseCell)

function LianhunEquipItemCell:__init()
	self.quality = self:FindVariable("Quality")
	self.icon = self:FindVariable("Icon")
	self.show_arrow = self:FindVariable("ShowArrow")
	self.color_label = self:FindVariable("ColorLabel")
	self.show_arrow:SetValue(false)
	self.color_label:SetAsset("", "")
end

function LianhunEquipItemCell:__delete()

end

function LianhunEquipItemCell:OnFlush()
	if nil == self.data then return end

	if self.data.lianhun_level < 1 then
		self:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[self.data.index + 1]))
		self:SetQuality(-1)
	else
		local cur_cfg = LianhunData.Instance:GetEquipLianhuncfg(self.data.index, self.data.lianhun_level)
		if cur_cfg then
			self:SetIcon(ResPath.GetLianhunEquipRes(cur_cfg.res_id))
		end
		self:SetQuality(self.data.lianhun_level)
	end
end


function LianhunEquipItemCell:ShowArrow(value, k)
	self.show_arrow:SetValue(value)
end

function LianhunEquipItemCell:SetColorLabel(asset, bunble)
	self.color_label:SetAsset(asset, bunble)
end

function LianhunEquipItemCell:SetIcon(bundle, asset)
	if nil ==  bundle or nil == asset then return end
	self.icon:SetAsset(bundle, asset)
end

function LianhunEquipItemCell:SetQuality(level)
	local bundle1, asset1 = ResPath.GetRoleEquipQualityIcon(level)
	self.quality:SetAsset(bundle1, asset1)
end

function LianhunEquipItemCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function LianhunEquipItemCell:SetInteractable(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.interactable = enable
	end
end

function LianhunEquipItemCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function LianhunEquipItemCell:SetHightLight(value)
	if nil == self.root_node.toggle then return end
	self.root_node.toggle.isOn = value
end