SpiritLingPoView = SpiritLingPoView or BaseClass(BaseRender)

local DISPLAYNAME = {
	[10006001] = "spirit_lingpo_frame_special_1",
	[10004001] = "spirit_lingpo_frame_special_2",
	[10009001] = "spirit_lingpo_frame_special_3",
	[10025001] = "spirit_lingpo_frame_special_4"
}

function SpiritLingPoView:__init(Instance)
	self.cur_index = 1
	self.is_fight_out = false
	self.strengthen_level = 1
	self.wuxing_level = 0
	self.cell_list = {}
	self.attr_list = {}
	self.attr_up_list = {}
  	for i=1,2 do
     	self.attr_list[i] = {}
     	self.attr_list[i].value = self:FindVariable("attr_value_"..i)
     	self.attr_list[i].up_value = self:FindVariable("up_value_"..i)
     	self.attr_up_list[i] = self:FindVariable("attr_up_"..i)
 	 end
    self.attr_value_3 = self:FindVariable("attr_value_3")

  	self.next_attr_list = {}
	for i=1,3 do
	    self.next_attr_list[i] = self:FindVariable("next_attr_value_"..i)
	end
	self.model_name =  self:FindVariable("model_name")
	self.next_title_img =  self:FindVariable("next_title_img")
	self.zhan_li = self:FindVariable("zhan_li")
	self.up_zhan_li = self:FindVariable("up_zhan_li")
	self.title_level_limit_text = self:FindVariable("title_level_limit_text")
	self.slider_value = self:FindVariable("slider_value")
	self.slider_text = self:FindVariable("slider_text")
	self.have_num = self:FindVariable("have_num")
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_gray = self:FindVariable("show_gray")
	self.up_image = self:FindVariable("up_image")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))

	self.display = self:FindObj("model_display")
	self.model_view = RoleModel.New("spirit_lingpo_frame")
	self.model_view:SetDisplay(self.display.ui3d_display)

	self:ListenEvent("OnClickAdvance", BindTool.Bind(self.OnClickAdvance, self))
	self:ListenEvent("OnclickPlus", BindTool.Bind(self.OnclickPlus, self))

	self.list_view = self:FindObj("list_view")
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function SpiritLingPoView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.attr_up_list = {}

  	if self.model_view then
	    self.model_view:DeleteMe()
	    self.model_view = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self:CancelSliderQuest()
	self.cur_index = 1
	self.is_fight_out = nil
	self.wuxing_level = nil
	self.strengthen_level = nil
end

function SpiritLingPoView:OnClickAdvance()
	self.is_fight_out = false
	local sure_func = function()
	 	self:SendAdvanceReq()
	end
	local sure_tiwce_func = function()
		self:SendAdvanceReqTiwce()
	end
	local item_info = SpiritData.Instance:GetLingAdvanceItemInfo(self.cur_lingpo_list[self.cur_index].type)
	local spirit_fightout_list = SpiritData.Instance:GetSpiritInfo().jingling_list
	local bag_list = SpiritData.Instance:GetBagBestSpirit()
	local dec_1 = Language.JingLing.LingPoAdvanceDec[0]
	local dec_2 = Language.JingLing.LingPoAdvanceDec[1]
	for i, v in pairs(bag_list) do
		if v.item_id and v.item_id == item_info.data.item_id then
			self.strengthen_level = v.param.strengthen_level
			self.wuxing_level = v.param.param2
			break
		end
	end
	local info, t = self:CheckIsNil()
	local cost_item_num = t.exp - info.exp
	for k, v in pairs(spirit_fightout_list) do
		if v.item_id ~= nil and v.item_id == item_info.data.item_id then
			self.is_fight_out = true
			break
		end
	end
	if item_info.my_count < item_info.need_num then
	   	-- TipsCtrl.Instance:ShowItemGetWayView(item_info.data.item_id)
	   	SpiritCtrl.Instance:OpenSpiritGetWayTip(item_info.data.item_id)
	else
		if self.is_fight_out then
			if self.strengthen_level > 1 or self.wuxing_level > 0 then
				TipsCtrl.Instance:ShowCommonAutoView("use_spirit_01", dec_1, sure_func, nil, nil, nil, nil, nil, true, true)
			else
				self:SendAdvanceReq()
			end

		elseif item_info.my_count <= cost_item_num then
			if self.strengthen_level > 1 or self.wuxing_level > 0 then
				TipsCtrl.Instance:ShowCommonAutoView("use_spirit_01", dec_2, sure_tiwce_func, nil, nil, nil, nil, nil, true, true)
			else
				TipsCtrl.Instance:ShowCommonAutoView("use_spirit_01", dec_2, sure_func, nil, nil, nil, nil, nil, true, true)
			end
		else
			if self.strengthen_level > 1 or self.wuxing_level > 0 then
				TipsCtrl.Instance:ShowCommonAutoView("use_spirit_01", dec_1, sure_func, nil, nil, nil, nil, nil, true, true)
			else
				self:SendAdvanceReq()
			end
		end
	end
end
function SpiritLingPoView:SendAdvanceReqTiwce()
	local dec_1 = Language.JingLing.LingPoAdvanceDec[0]
	local sure_func1 = function()
	 	self:SendAdvanceReq()
	end
	TipsCtrl.Instance:ShowCommonTip(sure_func1, nil, dec_1, nil, nil, true)
end

function SpiritLingPoView:SendAdvanceReq()
	SpiritData.Instance:SetCurAdvanceLingPoType(self.cur_lingpo_list[self.cur_index].type)
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVELCARD, self.cur_lingpo_list[self.cur_index].type)
end

function SpiritLingPoView:OnclickPlus()
	TipsCtrl.Instance:ShowSpiritPlusView(self.cur_lingpo_list)
end

function SpiritLingPoView:SetCurIndex(index)
	if index ~= self.cur_index then
		self.cur_index = index
		self.up_image:SetValue(true)
		for i=1,2 do
			self.attr_up_list[i]:SetValue(true)
		end
		self:Flush("flush_modle", {[1] = true})
	end
end

function SpiritLingPoView:GetCurIndex()
  	return self.cur_index
end

--获得排序后的列表
function SpiritLingPoView:GetCurLingpoList()
	return self.cur_lingpo_list
end

--判空
function SpiritLingPoView:CheckIsNil()
	local spirit_data = SpiritData.Instance
	local info = spirit_data:GetLingPoInfo(self.cur_lingpo_list[self.cur_index].type)
	if not info or not next(info) then return end

	local t = spirit_data:GetLingPoCurCfg(self.cur_lingpo_list[self.cur_index].type, info.level)
	if not t.cfg or not next(t.cfg) then return end

	return info, t
end

function SpiritLingPoView:OnFlush(...)
	self.cur_lingpo_list = SpiritData.Instance:GetLingPoSortList(self.cur_index)
	self:FlushAttr()
	self:FlushTotlePower()
	self:FlushBag()
	self:FlushTitleFrame()
	self.list_view.scroller:RefreshActiveCellViews()

	local param = {...}
	if not param[1]["flush_modle"] then return end
	self:FlushModel()
end

--刷新属性
function SpiritLingPoView:FlushAttr()
	local info, t = self:CheckIsNil()
	if not info or not t then return end

	local spirit_data = SpiritData.Instance
	self:FlushSlider(false)
	local up_value_list = spirit_data:GetLingPoUpValue(self.cur_lingpo_list[self.cur_index].type, info.level)

	local up_zhan_li_num = spirit_data:GetLingPoZhanLiUpValue(self.cur_lingpo_list[self.cur_index].type, info.level)
	if up_zhan_li_num == 0 then
		self.up_image:SetValue(false)
	else
		self.up_zhan_li:SetValue(up_zhan_li_num)
	end
	local is_over_zeor = info.level > 0

	for i=1,2 do
		self.attr_list[i].value:SetValue(is_over_zeor and t.cfg["attr_value"..i] or 0)
		self.attr_value_3:SetValue(is_over_zeor and t.cfg["attr_value3"] or 0)
		if self.up_image:GetBoolean() then
	    	self.attr_list[i].up_value:SetValue(up_value_list[i])
	    else
	    	self.attr_up_list[i]:SetValue(false)
	    end
	end

	local max_level = spirit_data:GetLingPoMaxLevel()
	self.show_interactable:SetValue(info.level < max_level)
	self.show_gray:SetValue(info.level < max_level)
end

--刷新物品
function SpiritLingPoView:FlushBag()
	local spirit_data = SpiritData.Instance
	local item_info = spirit_data:GetLingAdvanceItemInfo(self.cur_lingpo_list[self.cur_index].type)
	local color = spirit_data:GetLingPoCountColor(self.cur_lingpo_list[self.cur_index].type)
	local info, t = self:CheckIsNil()
	if not next(item_info) then return end
	local has_item = item_info.my_count > 0
	self.item_cell:SetData(item_info.data)
	self.item_cell:SetItemNumVisible(has_item)
	self.item_cell:SetNum(0)
	-- self.item_cell:SetIconGrayScale(not has_item)
	-- self.item_cell:ShowQuality(has_item)
	local cost_item_num = t.exp - info.exp
	if item_info.my_count >= cost_item_num then
		local dec = string.format(Language.JingLing.HaveNumDesc1, item_info.my_count, cost_item_num)
		self.have_num:SetValue(dec)
	else
		local dec = string.format(Language.JingLing.HaveNumDesc2, item_info.my_count, cost_item_num)
		self.have_num:SetValue(dec)
	end
end

--刷新模型
function SpiritLingPoView:FlushModel()
  	local spirit_data = SpiritData.Instance
  	local ling_po_show_id = spirit_data:GetLingPoSpiritId(self.cur_lingpo_list[self.cur_index].type)
  	if ling_po_show_id == 0 then return end
  	local spirit_cfg = spirit_data:GetSpiritResIdByItemId(ling_po_show_id)
  	local item_cfg = ItemData.Instance:GetItemConfig(ling_po_show_id)
  	if spirit_cfg == nil then return end

  	self.model_view:ResetRotation()
  	self.model_view:SetPanelName(self:SetSpecialModle(spirit_cfg.res_id))
  	self.model_view:SetMainAsset(ResPath.GetSpiritModel(spirit_cfg.res_id))
  	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">"..spirit_cfg.name.."</color>"
 	self.model_name:SetValue(name_str)
end

--刷新称号Frame
function SpiritLingPoView:FlushTitleFrame()
	local spirit_data = SpiritData.Instance
	local info = spirit_data:GetLingPoInfo(self.cur_lingpo_list[self.cur_index].type)
	if not info or not next(info) then return end

	local attr_list = spirit_data:GetLingPoTitleAttr()
	for i=1,3 do
	   self.next_attr_list[i]:SetValue(attr_list[i])
	end
	local title_info = spirit_data:GetCurTitleInfo()
	self.title_level_limit_text:SetValue(info.level)

	if title_id == 0 then return end
	self.next_title_img:SetAsset(ResPath.GetTitleIcon(title_info.title_id))
end

--刷新滑动条
function SpiritLingPoView:FlushSlider(is_paly_anim)
	local info, t = self:CheckIsNil()
	if not info and not t then return end

	local spirit_data = SpiritData.Instance
	if not is_paly_anim then
		local max_level = spirit_data:GetLingPoMaxLevel()
		if info.level < max_level then
			self.slider_text:SetValue(info.exp.." / "..t.exp)
			self.slider_value:SetValue(info.exp/t.exp)
		else
			self.slider_text:SetValue(Language.EquipShen.DJYM)
			self.slider_value:SetValue(1)
		end
		return
	end

	self.slider_value:SetValue(info.exp/t.exp)
	local time = spirit_data:CheckLingpoAnimTime(info.exp, t.exp)
	self:SliderQuest(time + 0.1)
end

function SpiritLingPoView:CancelSliderQuest()
	if self.timer_quest then
	   GlobalTimerQuest:CancelQuest(self.timer_quest)
	   self.timer_quest = nil
	end
end

--客户端表现进度条动画
function SpiritLingPoView:SliderQuest(time)
	self:CancelSliderQuest()
	local info, t = self:CheckIsNil()
	if not info and not t then return end

	local spirit_data = SpiritData.Instance
	local fix_time = time
	self.timer = 0
	self:CancelSliderQuest()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer + UnityEngine.Time.deltaTime
		if self.timer < fix_time - 0.1 then
			local pricent = self.timer/(fix_time - 0.1)
			self.slider_value:SetValue(pricent)
			self.slider_text:SetValue(math.ceil(pricent * t.exp).."/".. t.exp)
		end

		if self.timer >= fix_time then
			local max_level = spirit_data:GetLingPoMaxLevel()
			if info.level < max_level then
				self:FlushSlider(false)
				self:CancelSliderQuest()
			end
		end
	end, 0)
end

function SpiritLingPoView:OnClose()
	self:CancelSliderQuest()
end

function SpiritLingPoView:GetNumberOfCells()
  	return SpiritData.Instance:GetLingPoCfgCount()
end

function SpiritLingPoView:RefreshView(cell, data_index)
	--灵魄类型从0起
	data_index = data_index + 1
	local ling_po_cell = self.cell_list[cell]
	if ling_po_cell == nil then
	  	ling_po_cell = SpiritLingPoCell.New(cell.gameObject)
	    ling_po_cell.parent = self
	    self.cell_list[cell] = ling_po_cell
	end
	ling_po_cell:SetIndex(data_index)
	ling_po_cell:Flush()
end

function SpiritLingPoView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local is_lingpo_id = SpiritData.Instance:CheckIsLingpoItem(item_id)
	if not is_lingpo_id then return end

	local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
	local flush_modle = my_count == 0
	if flush_modle then
		self:Flush("flush_modle", {[1] = true})
	else
		self:Flush()
	end
end

function SpiritLingPoView:SetSpecialModle(modle_id)
	local display_name = "spirit_lingpo_frame"
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

function SpiritLingPoView:FlushTotlePower()
    local capability = SpiritData.Instance:GetLingPoTotalZhanLi()
    self.zhan_li:SetValue(capability)
end

-----------------------SpiritLingPoCell-----------------
SpiritLingPoCell = SpiritLingPoCell or BaseClass(BaseCell)
function SpiritLingPoCell:__init()
	self.level_text = self:FindVariable("level_text")
	self.name_text = self:FindVariable("name_text")
	self.zhanli_text = self:FindVariable("zhanli_text")
	self.TextColorIndex = self:FindVariable("TextColorIndex")
	self.quality_icon = self:FindVariable("quality_icon")
	self.quality_text = self:FindVariable("quality_text")
	self.show_hl = self:FindVariable("show_hl")
	self.show_red_point = self:FindVariable("show_red_point")
	self:ListenEvent("OnItemClick", BindTool.Bind(self.OnItemClick, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
end

function SpiritLingPoCell:__delete()
	if self.item_cell then
	  	self.item_cell:DeleteMe()
	    self.item_cell = nil
	end
	self.parent = nil
end

function SpiritLingPoCell:OnFlush()
	self.lingpo_type = self.parent:GetCurLingpoList()[self.index].type
	self.show_red_point:SetValue(SpiritData.Instance:CheckLingpoCellRedPoint(self.lingpo_type))
	self:FlushInfo()
	self:FlushLingPoItem()
end

function SpiritLingPoCell:FlushInfo()
	local spirit_data = SpiritData.Instance
	local info = spirit_data:GetLingPoInfo(self.lingpo_type)
	if not info or not next(info) then return end

	local item_info = spirit_data:GetLingAdvanceItemInfo(self.lingpo_type)
	self.level_text:SetValue(info.level)
	self.zhanli_text:SetValue(spirit_data:GetLingPoZhanLi(self.lingpo_type, info.level))
	self.item_cell:SetData(item_info.data)
	local cur_index = self.parent:GetCurIndex() or 0
	self.show_hl:SetValue(cur_index == self.index)
end

--刷新灵魄品质名称
function SpiritLingPoCell:FlushLingPoItem()
	local spirit_data = SpiritData.Instance
	local ling_po_show_id = spirit_data:GetLingPoSpiritId(self.lingpo_type)
	if ling_po_show_id == 0 then return end

	local item_cfg = ItemData.Instance:GetItemConfig(ling_po_show_id)
	if not item_cfg or not next(item_cfg) then return end

	self.quality_icon:SetAsset(ResPath.GetQualityTagBg(Common_Five_Rank_Color[item_cfg.color]))
	self.TextColorIndex:SetValue(item_cfg.color)
	self.quality_text:SetValue(Language.QualityAttr[Common_Five_Rank_Color[item_cfg.color]])

	local spirit_cfg = spirit_data:GetSpiritResIdByItemId(ling_po_show_id)
	if spirit_cfg == nil then return end
	self.name_text:SetValue(spirit_cfg.name)
end

function SpiritLingPoCell:OnItemClick()
  	self.parent:SetCurIndex(self.index)
end


