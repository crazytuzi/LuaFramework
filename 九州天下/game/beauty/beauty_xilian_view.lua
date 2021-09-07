BeautyXiLianView = BeautyXiLianView or BaseClass(BaseRender)

function BeautyXiLianView:__init(instance)
	self.cur_select = 1	
	self.is_auto_buy_stuff = 0
end

function BeautyXiLianView:__delete()
    if self.model_display then
		self.model_display:DeleteMe()
		self.model_display = nil
	end

	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	if self.lock_cell then
		self.lock_cell:DeleteMe()
		self.lock_cell = nil
	end

	if self.hunqi_attr_list then	
		for k,v in pairs(self.hunqi_attr_list) do
			if v then
				v:DeleteMe()
			end
		end
	end
	self.hunqi_attr_list = {}

	if self.name_cell_list then	
		for k,v in pairs(self.name_cell_list) do
			v:DeleteMe()
		end
		self.name_cell_list = {}
	end	

	if self.select_stuff then
		GlobalEventSystem:UnBind(self.select_stuff)
	end

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	self.xilian_red = nil
	self.element_red_list = {}
end

function BeautyXiLianView:LoadCallBack(instance)
	self.contain_cell_list = {}
	self.name_cell_list = {}
	self.display = self:FindObj("ModelDisplay")		-- 3D模型显示

	self.hunqi_attr_list = {}		--属性列表
	self.element_red_list = {}
	for i = 1, 8 do
		local xilian_element_obj =  self:FindObj("Element" .. i)
		local element = XiLianElement.New(xilian_element_obj)
		element:SetIndex(i)
		element:SetClickCallBack(BindTool.Bind(self.ClickXiLianCallBack, self))
		table.insert(self.hunqi_attr_list, element)

		self.element_red_list[i] = self:FindVariable("ElementRed" .. i)
	end

	self.toggle = self:FindObj("toggle")	--自动购买开关

	self.current_select_hunqi = 1
	self.lock_slot_num = 0
	self.lock_slot_flag = 0
	self.xilian_comsume_color = 0
	self.open_xilian_slot_num = 0

	self.hunqi_name = self:FindVariable("hunqi_name")
	self.attr1 = self:FindVariable("attr1")
	self.attr2 = self:FindVariable("attr2")
	self.power = self:FindVariable("power")
	self.stuff_num = self:FindVariable("stuff_num")
	self.lock_num = self:FindVariable("lock_num")
	self.show_buy = self:FindVariable("show_buy")
	self.show_cur_attr = self:FindVariable("show_cur_attr")
	self.show_next_attr = self:FindVariable("show_next_attr")

	self.stuff_cell = ItemCell.New(self:FindObj("item"))
	-- self.stuff_cell:SetInstanceParent(self:FindObj("item"))
	self.stuff_cell:ListenClick(BindTool.Bind(self.SelectStuff, self))

	self.lock_cell = ItemCell.New()
	self.lock_cell:SetInstanceParent(self:FindObj("lock_item"))

	self.list_data = BeautyData.Instance:GetBeautyInfo()
	self.name_list = self:FindObj("NameList")
	local name_view_delegate = self.name_list.list_simple_delegate
	--生成数量
	name_view_delegate.NumberOfCellsDel = function()
		return #self.list_data or 0
	end
	--刷新函数
	name_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNameListView, self)

	self.select_stuff_cfg = HunQiData.Instance:GetHunQiXiLianDefaultInfo()
	self:ListenEvent("OnClickXiLian", BindTool.Bind(self.OnClickXiLian, self))
	self:ListenEvent("SelectStuff", BindTool.Bind(self.SelectStuff, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickAutoBuy", BindTool.Bind(self.OnClickAutoBuy, self))
	self.select_stuff = GlobalEventSystem:Bind(OtherEventType.HUNQI_XILIAN_STUFF_SELECT, BindTool.Bind(self.OnSelectStuff, self))

	--监听物品变化
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	self.xilian_red = self:FindVariable("XiLianRed")

	self:InitModel()
	self:InitView()
end

function BeautyXiLianView:RefreshNameListView(cell, data_index, cell_index)
	data_index = data_index + 1
	local icon_cell = self.name_cell_list[cell]
	if icon_cell == nil then
		icon_cell = BeautyXiLianNameCell.New(cell.gameObject)
		icon_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		icon_cell:SetToggleActive(self.name_list.toggle_group, data_index == self.cur_select)
		self.name_cell_list[cell] = icon_cell
	end
	local data = self.list_data[data_index]
	icon_cell:SetIndex(data_index)
	icon_cell:SetRedFlag(BeautyData.Instance:GetIsCanOpen(data_index - 1))
	icon_cell:SetData(data)
end

function BeautyXiLianView:OnFlush()
	if self.name_list ~= nil then
		self.name_list.scroller:ReloadData(0)
	end
	self:FlushAttr()
end

function BeautyXiLianView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data or self.cur_select == cell.index then return end

	local cfg_data = HunQiData.Instance:GetHunQiXiLianOpenCfg(cell.index - 1, 0)
	local lingshu_level_limit = 0
	if cfg_data then
		lingshu_level_limit = cfg_data.lingshu_level_limit
	end
	local info = BeautyData.Instance:GetBeautyActiveInfo(cell.index - 1)
	local name = ""
	if info then
		name = info.name
	end

	if cell.data.is_active == 0 then 	--美人未激活
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Beaut.NeedActiveBeauty, name))
		return
	
	elseif cell.data.grade < lingshu_level_limit then	--美人等级不到洗炼限制等级
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Beaut.NeedLevelBeauty, name,lingshu_level_limit))
		return
	end
	self.cur_select = cell.index
	self.current_select_hunqi = cell.index

	self:FlushView()
	self:UpModelState()
	self:ResertLock()
end

function BeautyXiLianView:ClickXiLianCallBack(cell)
	if nil == cell or nil == cell.data then return end	
	if 0 == cell.data.xilian_slot_open_falg then	
		if self.list_data[cell.data.hunqi_id].is_active and self.list_data[cell.data.hunqi_id].is_active == 0 then		
			local name = BeautyData.Instance:GetBeautyActiveInfo(cell.data.hunqi_id - 1).name
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Beaut.NeedActiveBeauty, name))
			cell.toggle.toggle.isOn = false				
			return
		end	

		local is_open = 0
		if 1 == cell.data.slot_id then
			is_open = 1
		else
			is_open = self.hunqi_attr_list[cell.data.slot_id - 1].data.xilian_slot_open_falg
		end
		if is_open and is_open == 0 then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Beaut.IsCanOpenTip))
			return
		end
		local cost = cell.data.gold_cost
		if cost <= 0 then
			self:UnlockingBeauty(cell)
		else
			local function ok_callback()
				self:UnlockingBeauty(cell)
			end
			local des = string.format(Language.Beaut.UnLockingTip, cost)
			TipsCtrl.Instance:ShowCommonAutoView("beaut_xilian_unlock", des, ok_callback)
		end
	else
		if cell.toggle.toggle.isOn and self:GetCanLock() then
			SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.LockTip)
			cell.toggle.toggle.isOn = false
		end
		GlobalEventSystem:Fire(OtherEventType.HUNQI_XILIAN_STUFF_SELECT, 1)
	end


end

function BeautyXiLianView:UnlockingBeauty(cell)
	local open_num, open_consume, open_list = HunQiData.Instance:GetHunQiXiLianOpenConsume(cell.data.hunqi_id, cell.data.slot_id)
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_XILIAN_OPEN_SLOT, cell.data.hunqi_id - 1, cell.data.slot_id - 1) 
	cell.toggle.toggle.isOn = false
end

function BeautyXiLianView:OnItemDataChange(item_id)
	self:FlushStuff()
end

function BeautyXiLianView:SetLockNum()
	local lock_flag = 0
	local num = 0
	for i,v in ipairs(self.hunqi_attr_list) do
		if v:GetIsLock() then
			num = num + 1
			lock_flag = lock_flag + math.pow(2 , i - 1)
		end
	end
	self.lock_slot_num = num
	self.lock_slot_flag = lock_flag
end
--是否锁定该属性不洗炼
function BeautyXiLianView:GetIsLockByIndex(index)
	if self.hunqi_attr_list[index] then
		return self.hunqi_attr_list[index]:GetIsLock()
	end
	return false
end

function BeautyXiLianView:GetCanLock()
	return self.lock_slot_num == self.open_xilian_slot_num - 1
end

function BeautyXiLianView:ResertLock()
	for i,v in ipairs(self.hunqi_attr_list) do
		v:SetToggle(false)
	end
	self:SetLockNum()
	self:FlushStuff()
end

function BeautyXiLianView:FlushAttr()
	local xilian_data = HunQiData.Instance:GetHunQiXiLianInfoById(self.current_select_hunqi)
	if not xilian_data then
		return
	end
	self.open_xilian_slot_num = 0
	for i = 1, 8 do
		local cfg_data = HunQiData.Instance:GetHunQiXiLianOpenCfg(self.current_select_hunqi - 1, i - 1)
		local data = {}
		data.hunqi_id = self.current_select_hunqi
		data.slot_id = i
		data.gold_cost = cfg_data.gold_cost
		data.lingshu_level_limit = cfg_data.lingshu_level_limit
		data.xilian_slot_open_falg = xilian_data.xilian_slot_open_falg[33 - i]
		data.xilian_shuxing_type = xilian_data.xilian_shuxing_type[i]
		data.xilian_shuxing_star = xilian_data.xilian_shuxing_star[i]
		data.xilian_shuxing_value = xilian_data.xilian_shuxing_value[i]
		self.hunqi_attr_list[i]:SetData(data)
		if 1 == data.xilian_slot_open_falg then 
			self.open_xilian_slot_num = self.open_xilian_slot_num + 1 
		end

		if self.element_red_list[i] ~= nil then
			self.element_red_list[i]:SetValue(cfg_data.gold_cost <= 0 and xilian_data.xilian_slot_open_falg[33 - i] == 0 and BeautyData.Instance:GetIsActive(self.current_select_hunqi))
		end
	end

	local total_star = HunQiData.Instance:GetHunQiXiLianTotalStarNumById(self.current_select_hunqi)
	local cur_attr, next_attr = HunQiData.Instance:GetHunQiXiLianSuitAttrById(self.current_select_hunqi - 1)
	local cur_add_per = 0
	local next_add_per = 0
	local cur_star = 0
	local next_star = 0
	if cur_attr then
		cur_add_per = cur_attr.add_per / 100
		cur_star = cur_attr.need_start_count
	end
	if next_attr then
		next_add_per = next_attr.add_per / 100
		next_star = next_attr.need_start_count
	end
	self.attr1:SetValue(string.format(Language.HunQi.XiLianSuitAttr, cur_add_per, total_star, cur_star))
	self.attr2:SetValue(string.format(Language.HunQi.XiLianSuitAttr, next_add_per, ToColorStr(total_star, COLOR.RED), next_star))
	local capability = HunQiData.Instance:GetHunQiXiLianCapability(self.current_select_hunqi)
	self.power:SetValue(capability)

	self.show_cur_attr:SetValue(cur_attr ~= nil)
	self.show_next_attr:SetValue(next_attr ~= nil)
end

function BeautyXiLianView:FlushHunQiList()
	if self.name_list ~= nil then
		self.name_list.scroller:ReloadData(0)
	end
end

function BeautyXiLianView:FlushStuff()
	local stuff_cfg = self.select_stuff_cfg
	self.stuff_cell:SetData({item_id = stuff_cfg.consume_item.item_id})
	self.xilian_comsume_color = stuff_cfg.comsume_color
	self.stuff_item_id = stuff_cfg.consume_item.item_id
	local free_max_times = HunQiData.Instance:GetOtherCfg().free_xilian_times
	local yet_free_times = HunQiData.Instance:GetHunQiXiLianFreeTimes()
	local surplus = free_max_times - yet_free_times
	local xilian_red = false
	if surplus > 0 then
		self.stuff_num:SetValue(string.format(Language.HunQi.FreeTimes, surplus))
		xilian_red = true
	else
		local num = ItemData.Instance:GetItemNumInBagById(stuff_cfg.consume_item.item_id)
		local need_num = stuff_cfg.consume_item.num
		local color = num >= need_num and TEXT_COLOR.GREEN_7 or COLOR.WHITE
		self.stuff_num:SetValue(ToColorStr(num,color) .. "/" .. need_num )
		xilian_red = num >= need_num
	end

	-- if self.xilian_red ~= nil then
	-- 	self.xilian_red:SetValue(xilian_red and BeautyData.Instance:SetCheckXLRed(false))
	-- end
	self.show_buy:SetValue(self.select_stuff_cfg.comsume_color < HunQiData.XiLianStuffColor.PURPLE)

	local lock_stuff_cfg = HunQiData.Instance:GetHunQiXiLianLockConsume(self.lock_slot_num)
	if self.lock_slot_num >= #self.hunqi_attr_list then
		return
	end
	local need_lock_stuff_num = lock_stuff_cfg.lock_comsume_item.num
	if 0 == lock_stuff_cfg.lock_comsume_item.item_id then
		need_lock_stuff_num = 0
	end 
	local has_lock_stuff_num = ItemData.Instance:GetItemNumInBagById(lock_stuff_cfg.lock_comsume_ID)
	self.lock_cell:SetData({item_id = lock_stuff_cfg.lock_comsume_ID})
	local color = has_lock_stuff_num >= need_lock_stuff_num and TEXT_COLOR.GREEN_7 or COLOR.WHITE
	self.lock_num:SetValue(ToColorStr(has_lock_stuff_num, color) .. "/" .. need_lock_stuff_num)
	-- self.lock_num:SetValue(ToColorStr(has_lock_stuff_num .. "/" .. need_lock_stuff_num, color))
end

-- 初始化模型处理函数
function BeautyXiLianView:InitModel()
	if nil == self.model_display then
		self.model_display = RoleModel.New("beauty_panel")
		self.model_display:SetDisplay(self.display.ui3d_display)
	end
end

function BeautyXiLianView:FlushArrowState()
	for k,v in pairs(self.name_cell_list) do
		v:SetToggleOn(self.cur_select)
	end
	
end

function BeautyXiLianView:UpActivateInfo()
	local info = BeautyData.Instance:GetBeautyInfo()
	if info[self.cur_select] then
	
	end
end

function BeautyXiLianView:UpModelState()
	local active_info = BeautyData.Instance:GetBeautyActiveInfo(self.cur_select - 1)
	local beaut_info = BeautyData.Instance:GetBeautyInfo()[self.cur_select]

	if self.str_get_way ~= nil then
		local way_cfg = BeautyData.Instance:GetWayById(active_info.get_way)
		if way_cfg.discription ~= nil then
			self.str_get_way:SetValue(string.format(Language.Beaut.GetWayLabel, way_cfg.discription))
		end
	end

	if self.model_display and self.list_data[self.cur_select] and beaut_info and active_info then
		local bundle, asset = ResPath.GetGoddessNotLModel(active_info.model)
		self.model_display:SetMainAsset(bundle, asset, function ()
			self.model_display:ShowAttachPoint(AttachPoint.Weapon, beaut_info.is_active_shenwu == 1)
			self.model_display:ShowAttachPoint(AttachPoint.Weapon2, beaut_info.is_active_shenwu == 1)
			self.model_display:SetLayer(4, 1.0)
			self.model_display:SetTrigger("chuchang", false)

		end)
		self.model_display:ResetRotation()
	end
end

function BeautyXiLianView:InitView()
	self:FlushView()
	self:UpModelState()
end

function BeautyXiLianView:FlushView()
	self:FlushAttr()
	self:FlushStuff()
	self:FlushHunQiList()
	self:FlushArrowState()
	self:UpActivateInfo()
end
--传入的变量为开关toggle点击之后的状态 1为开 0为关
function BeautyXiLianView:OnClickAutoBuy(is_on)	
	self.is_auto_buy_stuff = is_on and 1 or 0	
end

function BeautyXiLianView:OnClickXiLian()
	local xilian_data = HunQiData.Instance:GetHunQiXiLianInfoById(self.current_select_hunqi)
	local has_rare = false 	--是否有一条7星及以上的属性为锁定
	local num = 0
	if xilian_data then
		for i,v in ipairs(xilian_data.xilian_shuxing_star) do
			if v >= 7 and not self:GetIsLockByIndex(i) then
				has_rare =true
				num = num + 1
			end
		end
	end
	local des = string.format(Language.HunQi.XiLianConfireTips, num)
	local function ok_callback()
		-- 请求洗练，param1 魂器类型， param2锁定槽0-7位表示1-8位属性, param3洗练材料类型,param4 是否自动购买, param5 是否免费
		local free_max_times = HunQiData.Instance:GetOtherCfg().free_xilian_times
		local yet_free_times = HunQiData.Instance:GetHunQiXiLianFreeTimes()
		local surplus = free_max_times - yet_free_times
		local is_free = surplus > 0 and 1 or 0 
		local is_auto_buy = self.toggle.toggle.isOn and 1 or 0
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_XILIAN_REQ, self.current_select_hunqi - 1, self.lock_slot_flag, self.xilian_comsume_color, is_auto_buy, is_free) 
		-- if self.is_auto_buy_stuff == 0 then
		-- 	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
		-- 		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		-- 		if is_buy_quick then
		-- 			self.toggle.toggle.isOn = true
		-- 			self.is_auto_buy_stuff = 1
		-- 		end
		-- 	end
		-- 	item_id = self.select_stuff_cfg.consume_item.item_id
		-- 	need_num = self.select_stuff_cfg.consume_item.num
		-- 	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, need_num)		
		-- else
		-- 	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_XILIAN_REQ, self.current_select_hunqi - 1, self.lock_slot_flag, self.xilian_comsume_color, self.is_auto_buy_stuff, is_free) 
		-- end
	end
	if has_rare then
		TipsCtrl.Instance:ShowCommonAutoView("XiSuitAttr", des, ok_callback, nil, nil, nil, nil, nil, true, false)
	else
		ok_callback()
	end
end

function BeautyXiLianView:SelectStuff()
	ViewManager.Instance:Open(ViewName.BeautyXiLianStuffView)
end

function BeautyXiLianView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(219)
end

function BeautyXiLianView:OnSelectStuff(operate_type, stuff_cfg)
	if 1 == operate_type then
		self:SetLockNum()
	else
		self.select_stuff_cfg = stuff_cfg
		self.toggle.toggle.isOn = false
	end
	self:FlushStuff()
end

---------------XiLianElement 洗炼属性------------------
XiLianElement = XiLianElement or BaseClass(BaseCell)

function XiLianElement:__init()
	self.toggle = self:FindObj("toggle")
	self.attr = self:FindVariable("attr")
	self.cost = self:FindVariable("cost")
	self.is_open = self:FindVariable("is_open")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function XiLianElement:__delete()

end

function XiLianElement:GetIsLock()
	return self.toggle.toggle.isOn
end

function XiLianElement:SetToggle(value)
	self.toggle.toggle.isOn = value
end

function XiLianElement:OnFlush(param_t)
	if not self.data then
		return
	end
	if 1 == self.data.xilian_slot_open_falg then
		local str = ""
		local attr_type = Language.HunQi.XiLianAttrType[self.data.xilian_shuxing_type]
		local shuxing_classify = HunQiData.Instance:GetHunQiXiLianShuXingType(self.data.hunqi_id - 1, self.data.xilian_shuxing_type).shuxing_classify or 0
		local attr_value = self.data.xilian_shuxing_value
		if shuxing_classify ~= 1 then
			attr_value = attr_value / 100 .. "%"
		end
		local color = TEXT_COLOR.BLUE
		if self.data.xilian_shuxing_star >= 9 then
			color = TEXT_COLOR.RED
		elseif self.data.xilian_shuxing_star >= 7 then 
			color = TEXT_COLOR.ORANGE_3
		elseif self.data.xilian_shuxing_star >= 5 then 
			color = TEXT_COLOR.PURPLE_3
		end
		str = string.format(Language.HunQi.XiLianAttrDesc, attr_type, color, attr_value, self.data.xilian_shuxing_star)
		self.attr:SetValue(str)
	else
		self.cost:SetValue(self.data.gold_cost)
	end
	self.is_open:SetValue(1 == self.data.xilian_slot_open_falg)
end

-------------------BeautyXiLianNameCell 左侧美人名字列表---------------------
BeautyXiLianNameCell = BeautyXiLianNameCell or BaseClass(BaseCell)
function BeautyXiLianNameCell:__init(instance)
	self:ListenEvent("ItemClick",BindTool.Bind(self.OnIconBtnClick, self))

	self.name = self:FindVariable("IconName")
	self.show_red = self:FindVariable("ShowRedPoint")
	self.level = self:FindVariable("lv")
	self.is_select = self:FindVariable("is_select")
	self.is_active = self:FindVariable("is_active")
	self.red_flag = false
end

function BeautyXiLianNameCell:__delete()
	self.red_flag = false
end

function BeautyXiLianNameCell:SetToggleActive(group, bool)
	self.root_node.toggle.group = group
	self.root_node.toggle.isOn = bool
	self.is_select:SetValue(bool)
end

function BeautyXiLianNameCell:SetToggleOn(index)
	self.root_node.toggle.isOn = self.index == index
	self:SetHighLight(index)
end

function BeautyXiLianNameCell:SetHighLight(index)
	self.is_select:SetValue(self.index == index)
end

function BeautyXiLianNameCell:OnFlush()
	if nil == self.data then return end
	local info = BeautyData.Instance:GetBeautyActiveInfo(self.index - 1)
	if info then
		self.name:SetValue(info.name)
	end

	local star_level = HunQiData.Instance:GetHunQiXiLianTotalStarNumById(self.index)
	self.is_active:SetValue(self.data.is_active == 1)
	self.level:SetValue(star_level)

	if self.show_red ~= nil then
		self.show_red:SetValue(self.red_flag)
	end
end	

function BeautyXiLianNameCell:OnIconBtnClick()
	self:OnClick()
end

function BeautyXiLianNameCell:SetRedFlag(value)
	self.red_flag = value
end