XiLianContentView = XiLianContentView or BaseClass(BaseRender)

function XiLianContentView:__init()
	if XiLianContentView.Instance ~= nil then
		-- error("[XiLianContentView] attempt to create singleton twice!")
		-- return
	end
	XiLianContentView.Instance = self

	self.contain_cell_list = {}
	self.select_data = {}
	self.model_display = self:FindObj("ModelDisplay")		-- 3D模型显示

	self.hunqi_btn_list = {}
	for i = 1, 6 do
		local hunqi_btn_obj =  self:FindObj("hunqi" .. i)
		local hunqi_btn = HunQiXiLianBtn.New(hunqi_btn_obj)
		hunqi_btn:SetIndex(i)
		hunqi_btn:SetClickCallBack(BindTool.Bind(self.HunQiBtnClick, self, i))
		table.insert(self.hunqi_btn_list, hunqi_btn)
	end

	self.hunqi_attr_list = {}
	for i = 1, 8 do
		local xilian_element_obj =  self:FindObj("Element" .. i)
		local element = XiLianElement.New(xilian_element_obj)
		element:SetIndex(i)
		element:SetClickCallBack(BindTool.Bind(self.OnClickElement, self))
		table.insert(self.hunqi_attr_list, element)
	end

	self.toggle = self:FindObj("toggle")

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
	self.hunqi_scroll_rect = self:FindObj("hunqi_scroll_rect")
	self.btn_stuff = self:FindObj("btn_stuff")

	self.click_desc = self:FindVariable("ClickDesc")

	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("item"))

	self.stuff_cell:ListenClick(BindTool.Bind(self.SelectStuff, self))

	self:ListenEvent("BtnLeft", BindTool.Bind(self.OnBtnLeft, self))
	self:ListenEvent("BtnRight", BindTool.Bind(self.OnBtnRight, self))

	self.lock_cell = ItemCell.New()
	self.lock_cell:SetInstanceParent(self:FindObj("lock_item"))

	self.select_stuff_cfg = HunQiData.Instance:GetHunQiXiLianDefaultInfo()
	self:ListenEvent("OnClickXiLian", BindTool.Bind(self.OnClickXiLian, self))
	self:ListenEvent("SelectStuff", BindTool.Bind(self.SelectStuff, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self.select_stuff = GlobalEventSystem:Bind(OtherEventType.HUNQI_XILIAN_STUFF_SELECT, BindTool.Bind(self.OnSelectStuff, self))

	--监听物品变化
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
end

function XiLianContentView:__delete()
    if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	if self.lock_cell then
		self.lock_cell:DeleteMe()
		self.lock_cell = nil
	end

	for k,v in pairs(self.hunqi_btn_list) do
		v:DeleteMe()
	end
	self.hunqi_btn_list = {}

	for k,v in pairs(self.hunqi_attr_list) do
		v:DeleteMe()
	end
	self.hunqi_attr_list = {}
	GlobalEventSystem:UnBind(self.select_stuff)

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end
end

function XiLianContentView:OnItemDataChange(item_id)
	self:FlushStuff()
end

function XiLianContentView:FlushHigh()
	for i,v in ipairs(self.hunqi_btn_list) do
		v:SetShowHigh((v:GetIndex() == self.current_select_hunqi) and (HunQiData.Instance:GetHunQiXiLianTotalStarNumById(i) ~= 0))
	end
end

function XiLianContentView:HunQiBtnClick(cur_data,hunqi_btn)
	if hunqi_btn then
		if self.current_select_hunqi == hunqi_btn:GetIndex() then
			return
		end
		local data = hunqi_btn:GetData()
		if data.star_level <= 0 then
			local cfg_data = HunQiData.Instance:GetHunQiXiLianOpenCfg(hunqi_btn:GetIndex() - 1, 0)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.HunQi.XiLianOpenLimitDesc, PlayerData.GetLevelString(cfg_data.open_level)))
			self:FlushHigh()
			return
		end
		self.current_select_hunqi = hunqi_btn:GetIndex()
	else
		if self.current_select_hunqi == cur_data.star_level then
			return
		end
		if cur_data.star_level <= 0 then
			local cfg_data = HunQiData.Instance:GetHunQiXiLianOpenCfg(self.current_select_hunqi, 0)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.HunQi.XiLianOpenLimitDesc, PlayerData.GetLevelString(cfg_data.open_level)))
			self:FlushHigh()
			return
		end
		-- self.current_select_hunqi = hunqi_btn:GetIndex()
	end
	self:FlushModel()
	self:FlushView()
	self:ResertLock()
end

function XiLianContentView:SetLockNum()
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

function XiLianContentView:GetIsLockByIndex(index)
	if self.hunqi_attr_list[index] then
		return self.hunqi_attr_list[index]:GetIsLock()
	end
	return false
end

function XiLianContentView:GetLockNum()
	return self.lock_slot_num
end

function XiLianContentView:ResertLock()
	for i,v in ipairs(self.hunqi_attr_list) do
		v:SetToggle(false)
	end
	self:SetLockNum()
	self:FlushStuff()
end

-- 左边按钮
function XiLianContentView:OnBtnLeft()
	self.hunqi_scroll_rect.scroll_rect.horizontalNormalizedPosition = 0
	-- self.current_select_hunqi = self.current_select_hunqi - 1
	-- local xilian_info_level = HunQiData.Instance:GetHunQiXiLianTotalStarNumById(self.current_select_hunqi)
	-- if xilian_info_level <= 0 then
	-- 	self.current_select_hunqi = self.current_select_hunqi + 1
	-- 	return
	-- end
	-- self:FlushModel()
	-- self:FlushView()
	-- self:ResertLock()
end
-- 右边按钮
function XiLianContentView:OnBtnRight()
	self.hunqi_scroll_rect.scroll_rect.horizontalNormalizedPosition = 1
	-- self.current_select_hunqi = self.current_select_hunqi + 1
	-- local xilian_info_level = HunQiData.Instance:GetHunQiXiLianTotalStarNumById(self.current_select_hunqi)
	-- if xilian_info_level <= 0 then
	-- 	self.current_select_hunqi = self.current_select_hunqi - 1
	-- 	return
	-- end
	-- self:HunQiBtnClick(self.select_data[self.current_select_hunqi])
	-- self:FlushModel()
	-- self:FlushView()
	-- self:ResertLock()
end

function XiLianContentView:FlushAttr()
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
		data.open_level = cfg_data.open_level
		data.xilian_slot_open_falg = xilian_data.xilian_slot_open_falg[33 - i]
		data.xilian_shuxing_type = xilian_data.xilian_shuxing_type[i]
		data.xilian_shuxing_star = xilian_data.xilian_shuxing_star[i]
		data.xilian_shuxing_value = xilian_data.xilian_shuxing_value[i]
		self.hunqi_attr_list[i]:SetData(data)
		if 1 == data.xilian_slot_open_falg then
			self.open_xilian_slot_num = self.open_xilian_slot_num + 1
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

	self.show_cur_attr:SetValue(cur_attr ~= nil and cur_add_per > cur_star)
	self.show_next_attr:SetValue(next_attr ~= nil)
end

function XiLianContentView:FlushHunQiList()
	for i,v in ipairs(self.hunqi_btn_list) do
		local data = {}
		data.star_level = HunQiData.Instance:GetHunQiXiLianTotalStarNumById(i)
		data.open_limit = HunQiData.Instance:GetHunQiXiLianOpenCfg(i - 1, 0).open_level
		v:SetData(data)
		self.select_data[i] = data
	end
end

function XiLianContentView:FlushStuff()
	local stuff_cfg = self.select_stuff_cfg
	self.stuff_cell:SetData({item_id = stuff_cfg.consume_item.item_id})

	--判断品质
	local item_cfg = ItemData.Instance:GetItemConfig(stuff_cfg.consume_item.item_id)
	local name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	--颜色紫色以上
	if stuff_cfg.comsume_color > 1 then
		local str = string.format(Language.HunQi.ShowClickDesc[stuff_cfg.comsume_color], name)
		self.click_desc:SetValue(str)
	else
		--普通的不显示
		self.click_desc:SetValue("")
	end

	self.xilian_comsume_color = stuff_cfg.comsume_color
	self.stuff_item_id = stuff_cfg.consume_item.item_id
	local free_max_times = HunQiData.Instance:GetOtherCfg().free_xilian_times
	local yet_free_times = HunQiData.Instance:GetHunQiXiLianFreeTimes()
	local surplus = free_max_times - yet_free_times
	-- if surplus > 0 then
		-- self.stuff_num:SetValue(string.format(Language.HunQi.FreeTimes, surplus))
	-- else
		local num = ItemData.Instance:GetItemNumInBagById(stuff_cfg.consume_item.item_id)
		local need_num = stuff_cfg.consume_item.num
		-- local color = num >= need_num and EXT_COLOR.BULE_NORMAL or COLOR.RED

		local stuff_color = ""
		if num >= need_num then
			stuff_color = TEXT_COLOR.TONGYONG_TS
		else
			stuff_color = TEXT_COLOR.RED_1
		end
		self.stuff_num:SetValue(ToColorStr(num,stuff_color) .. " / " .. need_num)
	-- end
	self.show_buy:SetValue(self.select_stuff_cfg.comsume_color < HunQiData.XiLianStuffColor.RED)

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
	self.lock_cell:ShowHighLight(false)

	local has_lock_color = ""
	if has_lock_stuff_num >= need_lock_stuff_num then
		has_lock_color = TEXT_COLOR.TONGYONG_TS
	else
		has_lock_color = TEXT_COLOR.RED_1
	end

	if has_lock_stuff_num <= 0 then
		self.lock_num:SetValue(ToColorStr(has_lock_stuff_num ,TEXT_COLOR.RED_1).. " / " .. need_lock_stuff_num)
	else
		self.lock_num:SetValue(ToColorStr(has_lock_stuff_num ,has_lock_color).. " / " .. need_lock_stuff_num)
	end
end

function XiLianContentView:FlushModel()
	if nil == self.model then
		self.model = RoleModel.New("hunqi_content_panel")
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	if self.current_select_hunqi > 0 then
		self.is_model_change = true
		local res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.current_select_hunqi - 1)
		local asset, bundle = ResPath.GetHunQiModel(res_id)
		local function complete_callback()
			self.is_model_change = false
			if self.model then
				local is_active_special = HunQiData.Instance:IsActiveSpecial(self.current_select_hunqi)
				self.model:ShowAttachPoint(AttachPoint.Weapon, not is_active_special)
				self.model:ShowAttachPoint(AttachPoint.Weapon2, is_active_special)
			end
		end
		self.model:SetPanelName(HunQiData.Instance:SetSpecialModle(res_id))
		self.model:SetMainAsset(asset, bundle, complete_callback)
	else
		self.model:ClearModel()
	end

	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.current_select_hunqi - 1)
	local color = SOUL_NAME_COLOR[color_num]
	hunqi_name = ToColorStr(hunqi_name, color)
	self.hunqi_name:SetValue(hunqi_name)
end

function XiLianContentView:InitView()
	self:FlushView()
	self:FlushModel()
end

function XiLianContentView:FlushView()
	self:FlushAttr()
	self:FlushStuff()
	self:FlushHunQiList()
	self:FlushHigh()
end

function XiLianContentView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function XiLianContentView:OnClickXiLian()
	if ItemData.Instance:GetItemNumInBagById(self.stuff_item_id) <= 0 and not self.toggle.toggle.isOn and self.select_stuff_cfg.comsume_color < HunQiData.XiLianStuffColor.RED then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.stuff_item_id]
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.toggle.toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.stuff_item_id, nofunc, 1)
		return
	end

	local has_rare, num = HunQiData.Instance:GetHunQiXiLianHasRareById(self.current_select_hunqi)
	local des = string.format(Language.HunQi.XiLianConfireTips, num)
	local function ok_callback()
		-- 请求洗练，param1 魂器类型， param2锁定槽0-7位表示1-8位属性, param3洗练材料类型,param4 是否自动购买, param5 是否免费
		local free_max_times = HunQiData.Instance:GetOtherCfg().free_xilian_times
		local yet_free_times = HunQiData.Instance:GetHunQiXiLianFreeTimes()
		local surplus = free_max_times - yet_free_times
		local is_free = surplus > 0 and 1 or 0
		local is_auto_buy = self.toggle.toggle.isOn and 1 or 0
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_XILIAN_REQ, self.current_select_hunqi - 1, self.lock_slot_flag, self.xilian_comsume_color, is_auto_buy, 0)
	end
	if has_rare then
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback, nil, nil, nil, nil, nil, true, false)
	else
		ok_callback()
	end
end

function XiLianContentView:OnClickElement(cell)
	if nil == cell then
		return
	end

	local data = cell:GetData()

	if 0 == data.xilian_slot_open_falg then
		if PlayerData.Instance.role_vo.level < data.open_level then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.HunQi.XiLianOpenLimitDesc, PlayerData.GetLevelString(data.open_level)))
			cell:SetToggle(false)
			return
		end

		local open_num, open_consume, open_list = HunQiData.Instance:GetHunQiXiLianOpenConsume(data.hunqi_id, data.slot_id)
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_XILIAN_OPEN_SLOT, data.hunqi_id - 1, data.slot_id - 1)
		cell:SetToggle(false)
	else
		if cell:GetIsLock() and self:GetCanLock() then
			SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.LockTip)
			cell:SetToggle(false)
		end
		GlobalEventSystem:Fire(OtherEventType.HUNQI_XILIAN_STUFF_SELECT, 1)
	end
end

function XiLianContentView:SelectStuff()
	self.stuff_cell:ShowHighLight(false)
	ViewManager.Instance:Open(ViewName.HunQiXiLianStuffView)
end

function XiLianContentView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(237)
end

function XiLianContentView:OnSelectStuff(operate_type, stuff_cfg)
	if 1 == operate_type then
		self:SetLockNum()
	else
		self.select_stuff_cfg = stuff_cfg
		self.toggle.toggle.isOn = false
	end
	self:FlushStuff()
end

function XiLianContentView:GetCanLock()
	return self.lock_slot_num == self.open_xilian_slot_num - 1
end

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
		local color = TEXT_COLOR.BLUE_SPECIAL   -- 1~3 蓝色  4~6 紫色  7~8 橙色  9~10 红色
		if self.data.xilian_shuxing_star >= 9 then
			color = TEXT_COLOR.RED_4
		elseif self.data.xilian_shuxing_star >= 7 then
			color = TEXT_COLOR.ORANGE_4
		elseif self.data.xilian_shuxing_star >= 4 then
			color = TEXT_COLOR.PURPLE_3
		end
		str = string.format(Language.HunQi.XiLianAttrDesc, attr_type, color, attr_value, self.data.xilian_shuxing_star)
		self.attr:SetValue(str)
	else
		self.cost:SetValue(self.data.gold_cost)
	end
	self.is_open:SetValue(1 == self.data.xilian_slot_open_falg)
end

---------------------HunQiXiLianBtn----------------------------
HunQiXiLianBtn = HunQiXiLianBtn or BaseClass(BaseCell)
function HunQiXiLianBtn:__init()
	self.icon_res = self:FindVariable("IconRes")
	self.hunqi_name = self:FindVariable("Name")
	self.level = self:FindVariable("lv")
	self.show_hight = self:FindVariable("show_hight")
	self.is_active = self:FindVariable("IsActive")
	self.show_redpoint = self:FindVariable("ShowRedPoint")
	self.lianqi_list = self:FindObj("lianqi_btn_list")
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function HunQiXiLianBtn:__delete()

end

function HunQiXiLianBtn:OnFlush()
	self.show_redpoint:SetValue(HunQiData.Instance:CalcHunQiXiLianShuRedPointById(self:GetIndex()) > 0)
		--设置图标
	local model_res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.index - 1)
	local param = model_res_id - 17000
	local res_id = "HunQi_" .. param
	self.icon_res:SetAsset(ResPath.GetHunQiImg(res_id))
	self.level:SetValue(self.data.star_level)
	self.is_active:SetValue(self.data.star_level > 0)
end

function HunQiXiLianBtn:SetShowHigh(value)
	self.lianqi_list.toggle.enabled = self.data.star_level > 0
	self.show_hight:SetValue(self.data.star_level > 0)
	self.root_node.toggle.isOn = value
end

