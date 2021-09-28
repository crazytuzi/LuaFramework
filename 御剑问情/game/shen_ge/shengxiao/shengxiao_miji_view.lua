ShengXiaoMijiView = ShengXiaoMijiView or BaseClass(BaseView)

FEECTBYLEVEL = {
	[0] = "baoshi_lanse",
	[1] = "baoshi_zi",
	[2] = "baoshi_huang",
}

function ShengXiaoMijiView:__init()
	self.ui_config = {"uis/views/shengxiaoview_prefab", "ShengXiaoMiji"}
    self.play_audio = true
end

function ShengXiaoMijiView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickPlus", BindTool.Bind(self.OnClickPlus, self))
	self:ListenEvent("OnTakeOffMiji", BindTool.Bind(self.OnTakeOffMiji, self))
	self:ListenEvent("OnClickStudy", BindTool.Bind(self.OnClickStudy, self))
	self:ListenEvent("OnCloseDetail", BindTool.Bind(self.OnCloseDetail, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OpenComposeView", BindTool.Bind(self.OpenComposeView, self))
	self:ListenEvent("OpenAllMijiView", BindTool.Bind(self.OpenAllMijiView, self))
	self:InitDetail()
	self.show_add_btn = self:FindVariable("show_add_btn")
	self.select_miji_path = self:FindVariable("select_miji_path")
	self.select_effect_path = self:FindVariable("select_effect_path")
	self.study_data = nil
	self.shengxiao_list = {}
	self.list_view = self:FindObj("ShengXiaoList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_index = 1

	self.miji_list_obj = self:FindObj("IconList")
	self.miji_list = {}
	self.high_light_list = {}
	self.has_active_list = {}
	self.begin_index = 1
	self.turn_circle_count = 0
	self.is_rolling = false

	self.total_power = self:FindVariable("totalPower")

	for i = 1, 8 do
		self.high_light_list[i] = self:FindVariable("show_high_" .. i)
		self.has_active_list[i] = self:FindVariable("show_active_" .. i)
		local slot_obj = self.miji_list_obj.transform:FindHard("Slot_" .. i)
		local slot_cell = MijiCell.New(slot_obj)
		slot_cell:SetIndex(i)
		slot_cell:SetClickCallBack(BindTool.Bind(self.SlotClick, self, i))
		table.insert(self.miji_list, slot_cell)
	end

	self.time_space = 1
	self:Flush()
end

function ShengXiaoMijiView:InitDetail()
	self.detail_cap = self:FindVariable("detail_cap")
	self.select_miji_name = self:FindVariable("select_miji_name")
	self.select_desc = self:FindVariable("select_desc")
	self.detail_path = self:FindVariable("detail_path")
	self.show_detail_view = self:FindVariable("ShowMijiDetail")
	self.arrt_icon = self:FindVariable("arrt_icon")
	self.show_detail_view:SetValue(false)
	self.check_seq = 0
end

function ShengXiaoMijiView:ReleaseCallBack()
	for k, v in ipairs(self.high_light_list) do
		v = nil
	end
	self.high_light_list = {}
	for k, v in ipairs(self.miji_list) do
		v:DeleteMe()
		v = nil
	end
	self.miji_list = {}
	for k, v in ipairs(self.shengxiao_list) do
		v:DeleteMe()
	end
	self.shengxiao_list = {}
	for k, v in ipairs(self.has_active_list) do
		v = nil
	end
	self.has_active_list = {}
	self.list_view = nil
	self.miji_list_obj = nil
	self.show_add_btn = nil
	self.select_miji_path = nil
	self.study_data = nil
	self.detail_cap = nil
	self.select_miji_name = nil
	self.select_desc = nil
	self.show_detail_view = nil
	self.detail_path = nil
	self.select_effect_path = nil
	self.total_power = nil
	self.arrt_icon = nil
end

function ShengXiaoMijiView:OpenCallBack()
	self.begin_index = 1
	-- self:SetShowIndex(1)
	self:Flush()
end

function ShengXiaoMijiView:CloseCallBack()
	self.study_data = nil
	self.show_add_btn:SetValue(true)

	if self.anim_countdown ~= nil then
		GlobalTimerQuest:CancelQuest(self.anim_countdown)
		self.anim_countdown = nil
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CALC_CAPACITY)
		self.turn_circle_count = 0
		self.time_space = 1
		self.is_rolling = false
		self:ClearSelect()
	end
end

local count = 0
local turn_count = 1
function ShengXiaoMijiView:StarRoller()
	if self.anim_countdown == nil then
		count = 0
		turn_count = self.begin_index
		if self.anim_countdown then
			GlobalTimerQuest:CancelQuest(self.anim_countdown)
			self.anim_countdown = nil
		end
		self.anim_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowAnim, self), 0.025)
	end
end

function ShengXiaoMijiView:FlushDetailView()
	self.show_detail_view:SetValue(true)
	local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(self.check_seq)
	local item_cfg = ItemData.Instance:GetItemConfig(miji_cfg.item_id)
	self.detail_cap:SetValue(miji_cfg.capacity)
	if miji_cfg.type < 10 then
		local data = {}
		data[SHENGXIAO_MIJI_TYPE[miji_cfg.type]] = miji_cfg.value
		self.detail_cap:SetValue(CommonDataManager.GetCapabilityCalculation(data))
	end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.select_miji_name:SetValue(name_str)
	self.select_desc:SetValue(miji_cfg.type_name)
	self.arrt_icon:SetAsset(ResPath.GetBaseAttrIcon(miji_cfg.icon))
	self.detail_path:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
end

function ShengXiaoMijiView:FlushMijiInfo()
	local miji_data_list = ShengXiaoData.Instance:GetZodiacMijiList(self.list_index)
	local cur_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.list_index)
	for k, v in ipairs(self.miji_list) do
		local miji_data = {}
		miji_data.value = miji_data_list[k]
		local limit_level = ShengXiaoData.Instance:GetKongIsOpenByIndex(k)
		miji_data.lock_state = cur_level < limit_level
		v:SetData(miji_data)
		self.has_active_list[k]:SetValue(miji_data_list[k] >= 0)
	end
	self:CalculateTotalPower(miji_data_list);
end
--计算总战力
function ShengXiaoMijiView:CalculateTotalPower(miji_data_list)
	local totalPower = 0;
	for k,v in ipairs(miji_data_list) do
		if v >= 0 then
			local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(v)
			local item_cfg = ItemData.Instance:GetItemConfig(miji_cfg.item_id)
			totalPower = totalPower + item_cfg.power
		end
	end
	self.total_power:SetValue(totalPower)
end
function ShengXiaoMijiView:FlushShengXiaoList()
	for k,v in pairs(self.shengxiao_list) do
		v:OnFlush()
	end
end

function ShengXiaoMijiView:FlushStudyIcon()
	if self.study_data then
		local item_cfg = ItemData.Instance:GetItemConfig(self.study_data.item_id)
		self.select_miji_path:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
		local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(self.study_data.cfg_index)
		self.select_effect_path:SetAsset(ResPath.GetEffectMiJi(FEECTBYLEVEL[miji_cfg.level]))
	end
end

function ShengXiaoMijiView:OnFlush(param_list)
	self:FlushMijiInfo()
	self:FlushShengXiaoList()
end

function ShengXiaoMijiView:GetNumberOfCells()
	return 12
end

function ShengXiaoMijiView:GetSelectIndex()
	return self.list_index
end

function ShengXiaoMijiView:SetSelectIndex(index)
	self.list_index = index
end

function ShengXiaoMijiView:FlushListHL()
	for k,v in pairs(self.shengxiao_list) do
		v:FlushHL()
	end
end

function ShengXiaoMijiView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local shengxiao_cell = self.shengxiao_list[cell]
	if shengxiao_cell == nil then
		shengxiao_cell = ShengXiaoListItem.New(cell.gameObject)
		shengxiao_cell.root_node.toggle.group = self.list_view.toggle_group
		shengxiao_cell.shengxiao_miji_view = self
		self.shengxiao_list[cell] = shengxiao_cell
	end

	shengxiao_cell:SetItemIndex(data_index)
	shengxiao_cell:SetData({})
end

function ShengXiaoMijiView:SetShowIndex(index)
	self.begin_index = index
	for k,v in pairs(self.high_light_list) do
		v:SetValue(false)
	end
	self.high_light_list[self.begin_index]:SetValue(true)
end

function ShengXiaoMijiView:ShowAnim()
	count = count + 1
	if turn_count > 1 then
		if turn_count < 9 then
			if count * turn_count < 9 then
				return
			end
		elseif turn_count  > 20 + ShengXiaoData.Instance:GetEndIndex() - 8 and count < 10 then
			if count * (21 + ShengXiaoData.Instance:GetEndIndex() - turn_count) < 9 then
				return
			end
		end
	end
	count = 0
	self.is_rolling = true
	self.time_space = self.time_space - 0.1
	
	if self.begin_index == 8 then
		self.turn_circle_count = self.turn_circle_count + 1
	end
	self:SetShowIndex(self.begin_index + 1 > 8 and 1 or self.begin_index + 1)
	turn_count = turn_count + 1
	if turn_count > 20 and self.begin_index == ShengXiaoData.Instance:GetEndIndex() then
		if self.anim_countdown ~= nil then
			GlobalTimerQuest:CancelQuest(self.anim_countdown)
			self.anim_countdown = nil
		end
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CALC_CAPACITY)
		self.turn_circle_count = 0
		self.time_space = 1
		self.is_rolling = false
		self:ClearSelect()
		self:Flush()
	end
end


function ShengXiaoMijiView:SlotClick(index, cell, data)
	if cell:IsLock() then
		local open_level = ShengXiaoData.Instance:GetKongIsOpenByIndex(index)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.ShengXiao.MijiOpen, open_level))
		return
	end
	if data.value < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoMiji)
		return
	end
	self.check_seq = data.value
	self:FlushDetailView()
end

function ShengXiaoMijiView:OnClickClose()
	self:Close()
end

function ShengXiaoMijiView:SetStudyData(data)
	self.study_data = data
	self:FlushStudyIcon()
	self.show_add_btn:SetValue(false)
end

function ShengXiaoMijiView:OnClickPlus()
	if self.is_rolling then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.IsStuding)
		return
	end
	local bag_list = ShengXiaoData.Instance:GetBagMijiList()
	if next(bag_list) then
		ShengXiaoData.Instance:SetMijiShengXiaoIndex(self.list_index)
		ViewManager.Instance:Open(ViewName.MijiBagView)
		--ViewManager.Instance:Open(ViewName.AllMijiView)
	else
		--TipsCtrl.Instance:ShowItemGetWayView(27602)
		TipsCtrl.Instance:ShowMijiGetWayView()
		--SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoBagItem)
	end
end

function ShengXiaoMijiView:ClearSelect()
	self.study_data = nil
	self.show_add_btn:SetValue(true)
end

function ShengXiaoMijiView:OnTakeOffMiji()
	if self.is_rolling then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.IsStuding)
		return
	end
	self:OnClickPlus()
end

function ShengXiaoMijiView:OnClickStudy()
	if self.study_data ~= nil and self.is_rolling == false then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_PUT_MIJI, self.list_index - 1, self.study_data.cfg_index)
	elseif self.is_rolling then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.IsStuding)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChoseMijiFirst)
	end
end

function ShengXiaoMijiView:GetIsRolling()
	return self.is_rolling
end

function ShengXiaoMijiView:OnCloseDetail()
	self.show_detail_view:SetValue(false)
end

function ShengXiaoMijiView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(178)
end

function ShengXiaoMijiView:OpenComposeView()
	ViewManager.Instance:Open(ViewName.MiJiComposeView)
end
function ShengXiaoMijiView:OpenAllMijiView()
	ViewManager.Instance:Open(ViewName.AllMijiView)
end



---------------------ShengXiaoListItem--------------------------------
ShengXiaoListItem = ShengXiaoListItem or BaseClass(BaseCell)

function ShengXiaoListItem:__init()
	self.shengxiao_miji_view = nil
	self.show_hl = self:FindVariable("show_hl")
	self.level = self:FindVariable("level")
	self.image_path = self:FindVariable("image_path")
	self.show_lock = self:FindVariable("show_lock")
	self.miji_count = self:FindVariable("miji_count")
	self.open_condition = self:FindVariable("open_condition")
	self.shengxiao_name = self:FindVariable("shengxiao_name")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function ShengXiaoListItem:__delete()
	self.shengxiao_miji_view = nil
end

function ShengXiaoListItem:SetItemIndex(index)
	self.item_index = index
end

function ShengXiaoListItem:OnFlush()
	self:FlushHL()
	local miji_count = ShengXiaoData.Instance:GetMijiCountByindex(self.item_index)
	local shengxiao_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.item_index)
	local miji_open_cfg = ShengXiaoData.Instance:GetMijiOpenCfgByIndex(self.item_index)
	self.show_lock:SetValue(not ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index))
	if not ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index) then
		local last_miji_count = ShengXiaoData.Instance:GetMijiLimitCount(self.item_index)
		local cfg =  ShengXiaoData.Instance:GetZodiacInfoByIndex(self.item_index - 1, 1)
		self.open_condition:SetValue(string.format(Language.ShengXiao.NoOpen, cfg.name, last_miji_count))
	end
	self.level:SetValue(shengxiao_level)
	self.miji_count:SetValue(miji_count)
	self.image_path:SetAsset(ResPath.GetShengXiaoIcon(self.item_index))
	local cfg =  ShengXiaoData.Instance:GetZodiacInfoByIndex(self.item_index, 1)
	if not cfg then print_log("cfg is nil") return end
	self.shengxiao_name:SetValue(cfg.name)
end

function ShengXiaoListItem:OnClickItem(is_click)
	if is_click then
		local select_index = self.shengxiao_miji_view:GetSelectIndex()
		if select_index == self.item_index then
			return
		end
		if not ShengXiaoData.Instance:GetMijiIsOpenByIndex(self.item_index) then
			return
		end
		if self.shengxiao_miji_view:GetIsRolling() then
			SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.IsStuding)
			return
		end
		self.shengxiao_miji_view:SetSelectIndex(self.item_index)
		self.shengxiao_miji_view:FlushListHL()
		self.shengxiao_miji_view:FlushMijiInfo()
	end
end

function ShengXiaoListItem:FlushHL()
	local select_index = self.shengxiao_miji_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.item_index)
end


-----------------------MijiCell---------------------------
MijiCell = MijiCell or BaseClass(BaseRender)
function MijiCell:__init()
	self.is_lock = self:FindVariable("IsLock")
	self.have_item = self:FindVariable("HaveItem")

	self.image_res = self:FindVariable("ImageRes")
	self.effect_path = self:FindVariable("effect_path")
	self.lock_state = true
	self:ListenEvent("Click", BindTool.Bind(self.Click, self))
end

function MijiCell:__delete()
end

function MijiCell:Click()
	if self.clickcallback then
		self.clickcallback(self, self.data)
	end
end

function MijiCell:SetClickCallBack(callback)
	self.clickcallback = callback
end

function MijiCell:SetIndex(index)
	self.index = index
end

function MijiCell:GetIndex()
	return self.index
end

-- data里面有个协议发的东西就够了
function MijiCell:SetData(data)
	if not data or not next(data) then
		return
	end
	self.data = data
	self.have_item:SetValue(data.value >= 0)
	if data.value >= 0 then
		local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(data.value)
		local item_cfg = ItemData.Instance:GetItemConfig(miji_cfg.item_id)
		self.image_res:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
		self.effect_path:SetAsset(ResPath.GetEffectMiJi(FEECTBYLEVEL[miji_cfg.level]))
	end
	self.lock_state = self.data.lock_state
	self.is_lock:SetValue(self.lock_state)
end

function MijiCell:GetData()
	return self.data
end

function MijiCell:IsLock()
	return self.lock_state
end
