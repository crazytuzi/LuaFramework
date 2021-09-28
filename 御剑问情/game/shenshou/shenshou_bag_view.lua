
ShenShouBagView = ShenShouBagView or BaseClass(BaseView)
local BAG_MAX_GRID_NUM = 200			-- 最大格子数
function ShenShouBagView:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","ShenshouBagView"}
	self.play_audio = true
	self.bag_cell = {}
	self.equip_t = {}
	self.quality = 0
	self.star = 0
	self.open_q_sect = false
	self.open_s_sect = false
	self.shou_id = 1
	self.data_list = {}
	self.equip_txt_t = {}
	self.equip_up_t = {}
	self.cache_index = nil
end

function ShenShouBagView:__delete()

end

function ShenShouBagView:ReleaseCallBack()
	self.head_img = nil
	self.show_quality_select = nil
	self.show_star_select = nil
	self.quality_txt = nil
	self.star_txt = nil
	self.is_active = nil

	for k,v in pairs(self.equip_t) do
		v:DeleteMe()
	end
	self.equip_t = {}

	for k,v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
	self.bag_list_view = nil
	self.equip_txt_t = {}
	self.equip_up_t = {}
end

function ShenShouBagView:LoadCallBack()
	self.head_img = self:FindVariable("HeadImg")
	self.show_quality_select = self:FindVariable("ShowQualitySelect")
	self.show_star_select = self:FindVariable("ShowStarSelect")
	self.quality_txt = self:FindVariable("QualityTxt")
	self.star_txt = self:FindVariable("StarTxt")
	self.is_active = self:FindVariable("IsActive")

	for i = 1, 5 do
		local item_cell = ShenShouEquip.New()
		item_cell:SetInstanceParent(self:FindObj("Equip" .. i))
		self.equip_t[i] = item_cell
		self.equip_txt_t[i] = self:FindVariable("EquipTxt" .. i)
		self.equip_up_t[i] = self:FindObj("Up" .. i)
		self.equip_up_t[i].transform:SetAsLastSibling()
		self:ListenEvent("OnClickEquip" .. i, BindTool.Bind(self.EquipCellClick, self, i, item_cell))
	end

	self.bag_list_view = self:FindObj("ListView")
	local list_delegate = self.bag_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)


	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickGet",BindTool.Bind(self.OnClickGet, self))
	self:ListenEvent("OnClickSelectQuality",BindTool.Bind(self.OnClickSelectQuality, self))
	self:ListenEvent("OnClickSelectStar",BindTool.Bind(self.OnClickSelectStar, self))
	self:ListenEvent("OnClickCloseSlect",BindTool.Bind(self.OnClickCloseSlect, self))
	for i = 0, 4 do
		self:ListenEvent("OnClickQuality" .. i + 1,BindTool.Bind(self.OnClickQuality, self, i))
	end
	for i = 0, 3 do
		self:ListenEvent("OnClickStar" .. i + 1,BindTool.Bind(self.OnClickStar, self, i))
	end
end

function ShenShouBagView:EquipCellClick(i)
	local slot_data = ShenShouData.Instance:GetOneSlotData(self.shou_id, i - 1)
	local is_filter = false
	if nil ~= slot_data then
		if slot_data.item_id > 0 then
			is_filter = false
		else
			is_filter = true
		end
	else
		is_filter = true
	end

	if is_filter then
		self:FilterShenShouBag(i)
	end
end

function ShenShouBagView:EquipClick(i, cell)
	if cell.data and cell.data.item_id and  cell.data.item_id > 0 then
		local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(cell.data.item_id)
		self.shenshou_equip_cfg = shenshou_equip_cfg
		if nil == shenshou_equip_cfg then return end
		ShenShouCtrl.Instance:SetDataAndOepnEquipTip(cell:GetData(), ShenShouEquipTip.FromView.ShenShouEquipView, self.shou_id)
		-- ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_TAKE_OFF, self.shou_id, self.shenshou_equip_cfg.slot_index)
	end
end

function ShenShouBagView:OpenShenShouBag(shou_id, cache_index)
	if shou_id < 0 then return end
	self.shou_id = shou_id
	self.cache_index = cache_index
	self:Open()
end

function ShenShouBagView:FilterShenShouBag(i)
	local quality_requirement = ShenShouData.Instance:GetQualityRequirementCfg(self.shou_id, i - 1)
	local bag_cfg = ShenShouData.Instance:GetShenshouBackpackInfo()
	local list_1 = {}
	local list_2 = {}
	for k,v in pairs(bag_cfg) do
		if v.is_equip == 1 and v.slot_index == quality_requirement.slot and v.quality >= quality_requirement.slot_need_quality then
			list_1[#list_1 + 1] = v
		-- else
		-- 	list_2[#list_2 + 1] = v
		end
	end
	if #list_1 == 0 then
		TipsCtrl.Instance:ShowCommonAutoView("", Language.ShenShou.NoRightEquip, BindTool.Bind(self.OnClickGet, self), nil, nil, Language.ShenShou.GainEquip)
		return
	end

	self.quality = 0
	self.star = 0
	self:RecoverSelect()
	table.sort(list_1, ShenShouData.Instance:SortList("quality", "star_count", "is_equip"))
	table.sort(list_2, ShenShouData.Instance:SortList("quality", "star_count", "is_equip"))
	local num = #list_1
	
	-- for i=1, #list_2 do
	-- 	table.insert(list_1, list_2[i])
	-- end
	self.data_list = list_1
	if self.bag_list_view and self.bag_list_view.list_view.isActiveAndEnabled then
		self.bag_list_view.list_view:JumpToIndex(0)
		self.bag_list_view.list_view:Reload()
	end
end

function ShenShouBagView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function ShenShouBagView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ShenShouEquip.New(cellObj)
		cell.name = "shenshou_bag"
		cell:SetToggleGroup(self.bag_list_view.toggle_group)
		self.bag_cell[cellObj] = cell
	end

	local grid_index = math.floor(index / 4) * 4 + (4 - index % 4)
	-- 获取数据信息
	local data = self.data_list[grid_index] or {}
	cell:SetShouId(self.shou_id)
	cell:SetData(data, true)
	cell:ShowHighLight(false)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell, grid_index))
end

function ShenShouBagView:HandleBagOnClick(cell, index)
	if nil == cell.data then return end
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(cell.data.item_id)
	self.shenshou_equip_cfg = shenshou_equip_cfg
	if nil == shenshou_equip_cfg then return end
	if self.shenshou_equip_cfg.is_equip == 1 then
		-- ShenShouCtrl.Instance:OpenShenShouEquipTip(self.data, self.item_tip_from)
		ShenShouCtrl.Instance:SetDataAndOepnEquipTip(cell:GetData(), ShenShouEquipTip.FromView.ShenShouBagView, self.shou_id)
		-- ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_PUT_ON, self.shou_id, cell.data.index,  self.shenshou_equip_cfg.slot_index)
	else
		ShenShouCtrl.Instance:OpenShenShouStuffTip(cell.data)
	end
end


function ShenShouBagView:OnClickQuality(i)
	self.quality = i
	self.open_q_sect = false
	self.show_quality_select:SetValue(false)
	self:FlushShenShouBag()
end

function ShenShouBagView:OnClickStar(i)
	self.star = i
	self.open_s_sect = false
	self.show_star_select:SetValue(false)
	self:FlushShenShouBag()
end

function ShenShouBagView:FlushShenShouBag()
	self.quality_txt:SetValue(Language.ShenShou.ChooseBtnText[self.quality])
	self.star_txt:SetValue(Language.ShenShou.ChooseBtnText2[self.star])
	self.data_list = ShenShouData.Instance:UpFilterShenShouEq(self.quality, self.star, self.shou_id)
	if self.bag_list_view and self.bag_list_view.list_view.isActiveAndEnabled then
		self.bag_list_view.list_view:JumpToIndex(0)
		self.bag_list_view.list_view:Reload()
	end
end

function ShenShouBagView:OnClickGet()
	ViewManager.Instance:Close(ViewName.ShenShou)
	ViewManager.Instance:Close(ViewName.ShenShouBag)
	ViewManager.Instance:Open(ViewName.KuaFuBattle)
end

function ShenShouBagView:OnClickSelectQuality()
	self.open_q_sect = not self.open_q_sect
	self.show_quality_select:SetValue(self.open_q_sect)
end

function ShenShouBagView:OnClickSelectStar()
	self.open_s_sect = not self.open_s_sect
	self.show_star_select:SetValue(self.open_s_sect)
end

function ShenShouBagView:OnClickCloseSlect()
	self.open_q_sect = false
	self.open_s_sect = false
	self.show_quality_select:SetValue(false)
	self.show_star_select:SetValue(false)
end

function ShenShouBagView:OpenCallBack()
	self:Flush()
end


function ShenShouBagView:CloseCallBack()
	self:RecoverSelect()
end

function ShenShouBagView:RecoverSelect()
	self.quality = 0
	self.star = 0
	self.show_quality_select:SetValue(false)
	self.show_star_select:SetValue(false)
	self.open_q_sect = false
	self.open_s_sect = false
	self.quality_txt:SetValue(Language.ShenShou.ChooseBtnText[self.quality])
	self.star_txt:SetValue(Language.ShenShou.ChooseBtnText2[self.star])
end

function ShenShouBagView:OnFlush(param_t)
	self.head_img:SetAsset("uis/views/shenshouview/images_atlas", "shenshou_" .. self.shou_id)
	local is_active  = ShenShouData.Instance:IsShenShouActive(self.shou_id)
	self.is_active:SetValue(is_active)

	if self.cache_index then
		self:FilterShenShouBag(self.cache_index)
		self.cache_index = nil
	else
		self:FlushShenShouBag()
	end

	local quality_requirement = ShenShouData.Instance:GetQualityRequirement(self.shou_id)
	for k,v in pairs(quality_requirement) do
		local str = Language.ShenShou.ItemDesc[v.slot_need_quality] .. Language.ShenShou.ZhuangBeiLeiXing[v.slot]
		self.equip_txt_t[v.slot + 1]:SetValue("<color=" .. ITEM_TIP_COLOR[v.slot_need_quality] .. ">" .. str .. "</color>")
	end

	local shenshou_list = ShenShouData.Instance:GetShenshouList(self.shou_id)
	local is_visible = ShenShouData.Instance:GetShenShouHasRemindImg(self.shou_id)
	local flag = false
	if shenshou_list then
		for k, v in pairs(shenshou_list.equip_list) do
			self.equip_t[k]:SetData(v)
			self.equip_t[k]:ShowHighLight(false)
			flag = ShenShouData.Instance:GetHasBetterShenShouEquip(v, self.shou_id, k)
			self.equip_up_t[k]:SetActive(is_visible and flag)
			self.equip_t[k].root_node:SetActive(v ~= nil and v.item_id > 0)
			if v.item_id > 0 then
				self.equip_t[k]:ListenClick(BindTool.Bind(self.EquipClick, self, k, self.equip_t[k]))
				self.equip_t[k]:SetInteractable(true)
			end
		end
	else
		for k,v in pairs(self.equip_t) do
			flag = ShenShouData.Instance:GetHasBetterShenShouEquip(nil, self.shou_id, k)
			self.equip_up_t[k]:SetActive(is_visible and flag)
			v.root_node:SetActive(false)
		end
	end
end