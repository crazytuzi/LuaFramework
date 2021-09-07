ShenGeGodBodyView = ShenGeGodBodyView or BaseClass(BaseRender)
function ShenGeGodBodyView:__init(instance)
	self.list_index = 0
	self.point_index = 1
	self:InitScroller()

	self.attr_value_list = {}
	self.slider_value_list = {}
	self.toggle_value_list = {}
	self.toggle_obj_list = {}
	self.slider_image = {}
	for i = 1, 3 do
		self.attr_value_list[i] = self:FindVariable("AttrValue" .. i)
		self.slider_value_list[i] = self:FindVariable("SliderValue" .. i)
		self:ListenEvent("OnClickToggle" .. i, BindTool.Bind(self.OnClickToggle, self, i))
		self.toggle_value_list[i] = 0
		self.toggle_obj_list[i] = self:FindObj("Toggle".. i).toggle
		self.slider_image[i] = self:FindVariable("SliderImage" .. i)
	end
	self.desc = self:FindVariable("Desc")
	self.all_power = self:FindVariable("AllPower")
	self.stuff_num = self:FindVariable("StuffNum")

	self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle

	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("SutffCell"))

	self.point_list = self:FindObj("PointList")
	self.point_item_list = {}
	for i = 0, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM - 1 do
		local obj = self.point_list.transform:GetChild(i).gameObject
		local point_item = PointCell.New(obj)
		point_item:SetIndex(i+1)
		point_item:SetClickCallBack(BindTool.Bind(self.ClickPointCallBack, self))
		table.insert(self.point_item_list, point_item)
	end

	self:ListenEvent("OnClickXiLian", BindTool.Bind(self.OnClickXiLian, self))
	self:ListenEvent("AutoBuyChange", BindTool.Bind(self.AutoBuyChange, self))
	self:ListenEvent("OnClickTips", BindTool.Bind(self.OnClickTips, self))
	self:ListenEvent("OnClickPreview", BindTool.Bind(self.OnClickPreview, self))
	self.is_auto_buy_stone = 0
	self:ResetToggle()
	-- self.main_role_level_change = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ShenGeGodBodyView:__delete()

	if self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for _, v in ipairs(self.point_item_list) do
		v:DeleteMe()
	end
	self.point_item_list = {}
	if nil ~= self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ShenGeGodBodyView:ItemDataChangeCallback()
	self:Flush()
	RemindManager.Instance:Fire(RemindName.ShenGe_Godbody)
end

function ShenGeGodBodyView:MainRoleLevelChange()
	
end

function ShenGeGodBodyView:InitScroller()
	self.cell_list = {}
	self.data = ShenGeData.Instance:GetShenquListData()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return ShenGeData.Instance:GetShenquCount()
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  ShenquItem.New(cell.gameObject,self)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.scroller.toggle_group)
		end
		local cell_data = self.data[data_index]
		target_cell:SetData(cell_data)
		target_cell:SetCellIndex(data_index - 1)
		target_cell:SetClickCallBack(BindTool.Bind(self.SelectShenquCallBack, self, cell_data.shenqu_id))
		target_cell:SetToggle(cell_data.shenqu_id == self.list_index)
	end
end

function ShenGeGodBodyView:ReleaseCallBack()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ShenGeGodBodyView:OnFlush(param_list)
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushPointList()
	self:FlushRightContent()
end


function ShenGeGodBodyView:FlushPointList()
	for k, v in ipairs(self.point_item_list) do
		if k == self.point_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:Flush()
	end
	self:FlushRightContent()
end

function ShenGeGodBodyView:FlushRightContent()
	local cfg = ShenGeData.Instance:GetShenquCfgById(self.list_index)
	self.stuff_cell:SetData({item_id = cfg.stuff_id})
	self.all_power:SetValue(0)
	local xilian_count = 0
	for i = 1, 3 do
		if self.toggle_value_list[i] > 0 then
			xilian_count = xilian_count + 1
		end
	end
	local item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	local need_num = 0
	if xilian_count > 0 then
		need_num = cfg["stuff_num_" ..xilian_count - 1]
	end
	local had_text = ""
	local need_text = ToColorStr(' / '..need_num,TEXT_COLOR.WHITE)
	if item_num >= need_num then
		had_text = ToColorStr(item_num,TEXT_COLOR.GREEN)
	else
		had_text = ToColorStr(item_num,COLOR.RED)
	end
	self.stuff_num:SetValue(had_text..need_text)

	local cur_info = ShenGeData.Instance:GetOnePointInfo(self.list_index, self.point_index)
	if nil == cur_info or not next(cur_info) then return end
	local name_list = {}
	for i = 1, 3 do
		if cur_info[i].attr_point >= 0 then
			local point_cfg = ShenGeData.Instance:GetShenquXiLianCfg(self.list_index, cur_info[i].attr_point)
			if point_cfg then
				local slider_value = cur_info[i].attr_value / point_cfg[1]["max_" .. point_cfg[1].point_type]
									
				if slider_value < 0.5 then
					local bundle, asset = ResPath.GetShenQuSlider(6)
					self.slider_image[i]:SetAsset(bundle, asset)
				elseif slider_value < 0.75 then
					local bundle, asset = ResPath.GetShenQuSlider(4)
					self.slider_image[i]:SetAsset(bundle, asset)
				else
					local bundle, asset = ResPath.GetShenQuSlider(5)
					self.slider_image[i]:SetAsset(bundle, asset)
				end
				self.slider_value_list[i]:SetValue(slider_value)
			end
			name_list[i] = Language.ShenGe.NameList[cur_info[i].attr_point + 1]
			self.attr_value_list[i]:SetValue(name_list[i] .. "+" .. string.format(Language.ShenGe.NumColor, TEXT_COLOR.GREEN_5, cur_info[i].attr_value))
		else
			self.attr_value_list[i]:SetValue(Language.ShenGe.ZWSX)
			self.slider_value_list[i]:SetValue(0)
		end
	end
	
	local ready_count = 0
	local cur_name = Language.ShenGe.NameList[8]
	if next(name_list) then
		local check_table = TableCopy(name_list)
		local flag = 0
		
		for k, v in pairs(check_table) do
			for _k, _v in pairs(name_list) do
				if v == _v then
					flag = flag + 1
				end
			end
			if flag > 1 then
				cur_name =  v
				ready_count = flag
				break
			else
				cur_name = name_list[1]
				ready_count = 1
			end
			flag = 0			
		end		
	end
	local color = ready_count == cfg.perfect_num and TEXT_COLOR.GREEN_5 or TEXT_COLOR.RED
	self.desc:SetValue(string.format(Language.ShenGe.ShenQuDesc, color, ready_count, cfg.perfect_num, cur_name, cfg.value_percent .. "%"))

	local point_attr = ShenGeData.Instance:GetOnePointInfoAttr(self.list_index, self.point_index)
	if ready_count >= cfg.perfect_num or ShenGeData.Instance:GetAttrPointInfoNumByShenQuId(self.list_index) > 0 then
		-- self.all_power:SetValue(CommonDataManager.GetCapability(point_attr) + cfg.value_percent / 100 * CommonDataManager.GetCapability(point_attr))
		local value = (cfg.value_percent / 100 * CommonDataManager.GetCapability(point_attr)) * ShenGeData.Instance:GetAttrPointInfoNumByShenQuId(self.list_index)
		self.all_power:SetValue(CommonDataManager.GetCapability(point_attr) + value) 
	else
		self.all_power:SetValue(CommonDataManager.GetCapability(point_attr))
	end
end

function ShenGeGodBodyView:OnClickXiLian()
	local cfg = ShenGeData.Instance:GetShenquCfgById(self.list_index)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[cfg.stuff_id]
	
	local xilian_count = 0
	for i = 1, 3 do
		if self.toggle_value_list[i] > 0 then
			xilian_count = xilian_count + 1
		end
	end

	local item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	local need_num = 0
	if xilian_count > 0 then
		need_num = cfg["stuff_num_" ..xilian_count - 1]
	end

	-- local gold = PlayerData.Instance.role_vo["gold"]
	-- if item_cfg == nil or gold < (item_cfg.gold * need_num) then
	-- 	TipsCtrl.Instance:ShowLackDiamondView()
	-- 	return
	-- end

	if item_num < need_num  and self.is_auto_buy_stone == 0 then
		-- local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[cfg.stuff_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(cfg.stuff_id)
			return
		end

		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.isOn = true
				self.is_auto_buy_stone = 1
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, cfg.stuff_id, nil, need_num)
		return
	end
	
	-- if ShenGeData.Instance:ISShowCommonAuto(self.list_index, self.point_index, self.toggle_value_list) then
	-- 	TipsCtrl.Instance:ShowCommonAutoView("shen_ge_god_body_view", Language.ShenGe.TipsDesc,
	-- 		function() ShenGeCtrl.Instance:SendShenquReq(self.list_index, self.point_index - 1, 
	-- 			self.is_auto_buy_stone, self.toggle_value_list) end,
	-- 		function() return end)
	-- 	return
	-- end
	ShenGeCtrl.Instance:SendShenquReq(self.list_index, self.point_index - 1, self.is_auto_buy_stone, self.toggle_value_list)

end

function ShenGeGodBodyView:SelectShenquCallBack(data_index)
	self.list_index = data_index
	self:ResetToggle()
	self:Flush()
end

function ShenGeGodBodyView:ClickPointCallBack(cell)
	if nil == cell then
		return
	end
	local index = cell:GetIndex()
	cell:SetToggleState(true)
	for k, v in ipairs(self.point_item_list) do
		if v ~= cell then
			v:SetToggleState(false)
		end
	end
	
	if index == self.point_index then
		return
	end
	
	self.point_index = index
	self:ResetToggle()
	self:FlushRightContent()
end

function ShenGeGodBodyView:ResetToggle()
	self.toggle_value_list[1] = 1
	self.toggle_value_list[2] = 1
	self.toggle_value_list[3] = 1
	self.toggle_obj_list[1].isOn = true
	self.toggle_obj_list[2].isOn = true
	self.toggle_obj_list[3].isOn = true
end

function ShenGeGodBodyView:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

function ShenGeGodBodyView:OnClickTips()
	local tips_id = 228
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenGeGodBodyView:OnClickToggle(i, is_on)
	if is_on then
		self.toggle_value_list[i] = 1
	else
		local count = 0
		local index = -1
		for k,v in pairs(self.toggle_value_list) do
			if v > 0 then
				count = count + 1
				index = k
			end
		end
		if count == 1 and index == i then
			self.toggle_obj_list[i].isOn = true
			SysMsgCtrl.Instance:ErrorRemind(Language.ShenGe.OneLast)
			return
		end
		self.toggle_value_list[i] = 0
	end
	self:FlushRightContent()
end

function ShenGeGodBodyView:OnClickPreview()
	local data = ShenGeData.Instance:GetTotalAttrList(self.list_index)
	--TipsCtrl.Instance:ShowAttrView(data)
	TipsCtrl.Instance:OpenGeneralView(data)
end

function ShenGeGodBodyView:GetListIndex()
	return self.list_index
end
---------ShenquItem左侧标签-----------
ShenquItem = ShenquItem or BaseClass(BaseCell)

function ShenquItem:__init(instance, parent)
	self.parent = parent
	self.show_rp = self:FindVariable("show_rp")
	self.image_path = self:FindVariable("image_path")
	self.capblity = self:FindVariable("capblity")
	self.is_acitve = self:FindVariable("is_acitve")
	self.level = self:FindVariable("level")
	self.name = self:FindVariable("name")
	self:ListenEvent("ClickItem",BindTool.Bind(self.OnClick, self))
end

function ShenquItem:__delete()
	self.parent = nil
end

function ShenquItem:SetCellIndex(index)
	self.cell_index = index
end

function ShenquItem:SetToggleGroup(group)
  	self.root_node.toggle.group = group
end

function ShenquItem:SetToggle(value)
  	self.root_node.toggle.isOn = value
end

function ShenquItem:OnFlush(param_t)
	if not self.data then return end
	self.image_path:SetAsset("uis/views/shengeview/images_atlas", "shenqu_" .. self.data.shenqu_id)
	local one_attr_list = ShenGeData.Instance:GetTotalAttrList(self.data.shenqu_id)
	local cfg = ShenGeData.Instance:GetShenquCfgById(self.data.shenqu_id)
	local value = (cfg.value_percent / 100 * CommonDataManager.GetCapability(one_attr_list)) * ShenGeData.Instance:GetAttrPointInfoNumByShenQuId(self.data.shenqu_id)
	self.capblity:SetValue(CommonDataManager.GetCapability(one_attr_list) + value)
	local shenqu_id = 0
	if self.data.shenqu_id > 0 then
		shenqu_id = self.data.shenqu_id - 1
	end
	-- local shenqu_history_max_cap = ShenGeData.Instance:GetShenQuHistoryMaxCap(shenqu_id) or 0
	-- self.is_acitve:SetValue(shenqu_history_max_cap >= (self.data.fighting_capacity or 0))
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	self.is_acitve:SetValue(self.data.role_level <= role_level)
	local active_num = ShenGeData.Instance:GetActiveShenQuNum()
	
	if self.data.shenqu_id == active_num then
		self.level:SetValue(string.format(Language.ShenGe.WuLueDesc,self.data.role_level))
	else
		self.level:SetValue(Language.Common.NoActivate)
	end	
	-- self.root_node.toggle.interactable = shenqu_history_max_cap >= self.data.fighting_capacity

	local item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	self.show_rp:SetValue(item_num > 0 and self.data.role_level <= role_level)

	if self.name ~= nil then
		self.name:SetValue(self.data.name)
	end
end

function ShenquItem:OnClick()
	-- local shenqu_id = 0
	-- if self.data.shenqu_id > 0 then
	-- 	shenqu_id = self.data.shenqu_id - 1
	-- end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if self.data.role_level > role_level then
		SysMsgCtrl.Instance:ErrorRemind(self.data.tips)
	end
	-- local shenqu_history_max_cap = ShenGeData.Instance:GetShenQuHistoryMaxCap(shenqu_id)
	-- if shenqu_history_max_cap < self.data.fighting_capacity then
	-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.ShenGe.ShenGeDesc, self.data.fighting_capacity))
	-- end
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end
-------------------------------PointCell------------------------------
-------------------------------------------------------------------------------
PointCell = PointCell or BaseClass(BaseCell)

local Effect_Res_List = {
	[1] = "UI_xingling_lvse",
	[2] = "UI_xingling_lanse",
	[3] = "UI_xingling_zise",
	[4] = "UI_xingling_huangse",
	[5] = "UI_xingling_hongse",
	[6] = "UI_xingling_hongse",
	[7] = "UI_xingling_hongse",
}

function PointCell:__init()
	self.name = self:FindVariable("Name")
	self.icon_res = self:FindVariable("Res")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))

	GlobalTimerQuest:AddDelayTimer(function ()
					self.init_pos = self.root_node.transform.anchoredPosition
					self:PlaySelectAction()
				end, 0.5)
end

function PointCell:__delete()
	self.init_pos = nil
end

function PointCell:OnFlush()
	self.name:SetValue(Language.OneWordAttr.NameList[self.index])
	self.icon_res:SetAsset(ResPath.GetShenGeImg("img_attr_".. self.index))
end

function PointCell:SetToggleState(state)

	self.root_node.toggle.isOn = state
	if self.init_pos then
		self:PlaySelectAction()
	end
end

function PointCell:PlaySelectAction()
	if self.root_node.toggle.isOn then
		if nil == self.tween then
			self.tween = self.root_node.transform:DOAnchorPosY(self.init_pos.y + 10, 0.5)
			self.tween:SetEase(DG.Tweening.Ease.InOutSine)
			self.tween:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
		end
	else
		if self.tween then
			self.tween:Pause()
			self.tween = nil
		end

		self.root_node.transform.anchoredPosition = self.init_pos
	end
end