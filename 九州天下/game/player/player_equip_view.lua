PlayerEquipView = PlayerEquipView or BaseClass(BaseRender)
local ShowRemindLevel = 60					-- 出现可装备阶数是否为最大阶数提示的最低等级

local Defult_Icon_List = {
	100, 1100, 3100, 4100, 5100, 6100, {8100, 8200, 8300}, 26000, 2100, 26000
	}

local JIEZHI_INDEX_1 = 8
local JIEZHI_INDEX_2 = 10

function PlayerEquipView:__init(instance)
	if instance == nil then
		return
	end

	self.from_view = TipsFormDef.FROM_BAG_EQUIP

	self.cells = {}
	self.spec_cells = {}

	self.show_shen_equip_btn = self:FindVariable("ShowShenEquipBtn")
	self.show_goto_btn_1 = self:FindVariable("ShowGotoBtn1")
	self.show_goto_btn_2 = self:FindVariable("ShowGotoBtn2")
	self.show_deity_suits = self:FindVariable("ShowDeitySuitsView")
	self.mojie_red_list = {}
	for i=1,4 do
		self.mojie_red_list[i] = self:FindVariable("MojieRed" .. i)
	end

	self:Init()	
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)

	self.mojie_info_event = BindTool.Bind(self.UpdateMojieData, self)
	MojieData.Instance:AddListener(MojieData.MOJIE_EVENT, self.mojie_info_event)

	self:ListenEvent("OpenMojie",BindTool.Bind(self.HandleOpenMojie, self))
	self:ListenEvent("OpenCheckEquipView",BindTool.Bind(self.HandleOpenCheckEquipView, self))
	self:ListenEvent("GoToTreasure",BindTool.Bind(self.GoToTreasure, self))
	self:ListenEvent("OpenGouyu",BindTool.Bind(self.OpenGouyu, self))
	self:ListenEvent("OpenSpecial",BindTool.Bind(self.OpenSpecial, self))
	self:ListenEvent("SwitchToShenEquip",BindTool.Bind(self.SwitchToShenEquip, self))

	self.red_point_list = {
		[RemindName.Mojie] = self:FindVariable("ShowMojieRed"),
		[RemindName.GouYu] = self:FindVariable("ShowGouYuRed"),
		[RemindName.JieZhi] = self:FindVariable("ShowJieZhiRed"),
		[RemindName.GuaZhui] = self:FindVariable("ShowGuaZhuiRed"),
		[RemindName.ShenEquip] = self:FindVariable("ShowShenEquipRedPoint"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

end

function PlayerEquipView:__delete()
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if EquipData.Instance ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
		self.equip_data_change_fun = nil
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_datalist_change_fun)
		self.equip_datalist_change_fun = nil
	end
	if MojieData.Instance then
		MojieData.Instance:RemoveListener(MojieData.MOJIE_EVENT, self.mojie_info_event)
	end
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	for k, v in pairs(self.spec_cells) do
		v:DeleteMe()
	end
	self.spec_cells = {}
	self.red_point_list = {}
end

function PlayerEquipView:OpenCallBack()
	if self.equip_data_change_fun == nil then
		self.equip_data_change_fun = BindTool.Bind1(self.OnEquipDataChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_change_fun)
	end
	if self.equip_datalist_change_fun == nil then
		self.equip_datalist_change_fun = BindTool.Bind1(self.OnEquipDataListChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_datalist_change_fun, true)
	end

	self:OnEquipDataChange()
end

function PlayerEquipView:CloseCallBack()
	if self.equip_data_change_fun ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
		self.equip_data_change_fun = nil
	end
	if self.equip_datalist_change_fun ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_datalist_change_fun)
		self.equip_datalist_change_fun = nil
	end
end

function PlayerEquipView:HandleOpenMojie()
	ViewManager.Instance:Open(ViewName.Mojie, TabIndex.role_jinjie)
end

function PlayerEquipView:SwitchToShenEquip()
	local player_view = PlayerCtrl.Instance:GetView()
	player_view:OnSwitchToShenEquip(true)
end

function PlayerEquipView:OpenGouyu()
	ViewManager.Instance:Open(ViewName.Mojie, TabIndex.role_jinjie)
end

function PlayerEquipView:HandleOpenCheckEquipView()
	PlayerCtrl.Instance:OpenCheckEquipView()
end

function PlayerEquipView:GoToTreasure()
	-- ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
	-- ViewManager.Instance:Close(ViewName.Player)
	ViewManager.Instance:Open(ViewName.Mojie, TabIndex.role_mojie)
end

--主角身上的装备发生变化
function PlayerEquipView:OnEquipDataChange(item_id, index, reason)
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

--主角身上的列表装备变化
function PlayerEquipView:OnEquipDataListChange()
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

function PlayerEquipView:SetPlayerData(t)
	local equiplist = EquipData.Instance:GetDataList()
	self:SetData(equiplist)
end

function PlayerEquipView:UpdateMojieData()
	for k,v in pairs(self.spec_cells) do
		local data = MojieData.Instance:GetOneMojieInfo(k - 1)
		v:SetData(data)
		v:ListenClick(BindTool.Bind(self.OnClickMojieItem, self, k, data, v))
		-- v:SetIconGrayScale(data.mojie_level <= 0)
		v:ShowQuality(data.mojie_level > 0)
		if data.mojie_level <= 0 then
			v:ShowQuality(false)
			local bundle, asset = ResPath.GetPlayerImage("mojie_bg" .. k)
			v:SetAsset(bundle, asset )
		end
	end
end

function PlayerEquipView:SetData(equiplist)
	for k, v in pairs(self.cells) do
		if equiplist[k - 1] and equiplist[k - 1].item_id then
			v:SetData(equiplist[k - 1])
			v:SetIconGrayScale(false)
			v:ShowQuality(true)
			v:SetHighLight(self.cur_index == k)
			local item_cfg = ItemData.Instance:GetItemConfig(equiplist[k - 1].item_id)
			if item_cfg then
				local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
				local prof = GameVoManager.Instance:GetMainRoleVo().prof
				local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv, prof, item_cfg.sub_type)
				-- 等级不低于60 出现可装备阶数是否为最大阶数提示
				if main_role_lv >= ShowRemindLevel then
					v:ChangeRemind(item_cfg.order < max_order)
				end
			end
		else
			local jiezhi_level = MojieData.Instance:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE)
			local guazhui_level = MojieData.Instance:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI)
			local data = {}
			data.is_bind = 0
			if type(Defult_Icon_List[k]) == "table" then
				local prof = GameVoManager.Instance:GetMainRoleVo().prof
				data.item_id = Defult_Icon_List[k][prof]
			else
				data.item_id= Defult_Icon_List[k]
			end
			v:SetData(data)
			v:SetIsShowGrade(false)

			--客户端做的装备表现
			if k == 8 and jiezhi_level >= 1 then 
				local equip_type = k == 8 and jiezhi_level or guazhui_level
				local bundle, asset = ResPath.GetPlayerImage("jewelry_" .. 1)
				v:SetAsset(bundle, asset )
				v:SetStrength(jiezhi_level)
				v:ShowStrengthLable(true)
				v:QualityColor(GameEnum.ITEM_COLOR_ORANGE)
			elseif k == 10 and guazhui_level >= 1 then
				local bundle, asset = ResPath.GetPlayerImage("jewelry_" .. 2)
				v:SetAsset(bundle, asset )
				v:SetStrength(guazhui_level)
				v:ShowStrengthLable(true)
				v:QualityColor(GameEnum.ITEM_COLOR_ORANGE)
			else
				local bundle, asset = ResPath.GetPlayerImage("equip_bg" .. k)
				v:SetAsset(bundle, asset )
				v:ShowQuality(false)
				v:SetHighLight(false)
			end
			-- v:ShowHighLight(false)
			v:ChangeRemind(false)
		end
		v:ListenClick(BindTool.Bind(self.OnClickItem, self, k, equiplist[k - 1], v))
	end
end

function PlayerEquipView:Init()
	local bunble, asset = ResPath.GetImages("bg_cell_equip")

	for i = 1, 10 do
		local item = ItemCell.New()
		item:SetItemCellBg(bunble, asset)
		item:SetInstanceParent(self:FindObj("Item"..i))
		self.cells[i] = item
	end
	for i = 1, MOJIE_MAX_TYPE do
		local item = ItemCell.New()
		item:SetItemCellBg(bunble, asset)
		item:SetInstanceParent(self:FindObj("SpecItem"..i))
		self.spec_cells[i] = item
	end
	self:SetPlayerData(PlayerData.Instance.role_vo)
	self:UpdateMojieData()
	local flag = OpenFunData.Instance:CheckIsHide("shenzhuang")
	self.show_deity_suits:SetValue(flag)
end

function PlayerEquipView:OnClickMojieItem(index, data, cell)
	data.index = index
	local close_callback = function ()
		cell:SetHighLight(false)
	end
	ViewManager.Instance:Open(ViewName.Mojie, TabIndex.role_mojie, "data", {types = index})
	cell:SetHighLight(false)
end

function PlayerEquipView:OnClickItem(index, data, cell)
	if data == nil or not next(data) then
		cell:SetHighLight(false)

		if index == JIEZHI_INDEX_1 or index == JIEZHI_INDEX_2 then
			ViewManager.Instance:Open(ViewName.Mojie, TabIndex.role_jewelry, "data", {types = MojieData.Instance:GetGuazhuiType(index)})
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
		end
		return
	end
	if index == JIEZHI_INDEX_1 or index == JIEZHI_INDEX_2 then
		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
		ViewManager.Instance:Close(ViewName.Player)
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	-- if not item_cfg then
	-- 	cell:SetHighLight(false)
	-- 	if index == JIEZHI_INDEX_1 or index == JIEZHI_INDEX_2 then
	-- 		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
	-- 		ViewManager.Instance:Close(ViewName.Player)
	-- 	else
	-- 		TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
	-- 	end
	-- 	return
	-- end
	self.cur_index = index
	cell:SetHighLight(self.cur_index == index)
	local close_callback = function ()
		cell:SetHighLight(false)
		self.cur_index = nil
	end
	if data.param and item_cfg ~= nil then
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local shen_info = DeitySuitData.Instance:GetEquipData(equip_index)
		data.param.angel_level = shen_info and shen_info.level or 0
	end

	TipsCtrl.Instance:OpenItem(data, self.from_view, nil, close_callback)
end

function PlayerEquipView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
		if remind_name == RemindName.Mojie then
			for i=1,4 do
				self.mojie_red_list[i]:SetValue(MojieData.Instance:IsShowMojieRedPoint(i - 1))
			end
		end
	end
end

function PlayerEquipView:OpenSpecial()
	ViewManager.Instance:Open(ViewName.Mojie, TabIndex.role_mojie)
end