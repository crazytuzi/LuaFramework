ShenGeZhangKongView = ShenGeZhangKongView or BaseClass(BaseRender)

local piaozi_pos = {
	[0] = {x = -450, y = 200},
	[1] = {x = 300, y = 200},
	[2] = {x = -450, y = -270},
	[3] = {x = 300, y = -270},
}

function ShenGeZhangKongView:__init(instance)
	self.is_ten = false
	self.is_auto_buy = false
end

function ShenGeZhangKongView:__delete()
	if self.flag_list ~= nil then
		for k,v in pairs(self.flag_list) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.flag_list = {}
	end

	if self.bead_list ~= nil then
		for k,v in pairs(self.bead_list) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.bead_list = {}
	end

	self.is_ten = false
	self.is_auto_buy = false

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.ShenGeView)
	self.red_point = nil
end

function ShenGeZhangKongView:LoadCallBack()
	self.item_str = self:FindVariable("ItemStr")
	self.show_hook = self:FindVariable("ShowHook")
	self.consume_path = self:FindVariable("ConsumePath")
	self.button = self:FindObj("Button")

	self.flag_list = {}
	for i = 1, 4 do
		self.flag_list[i] = ShenGeZKFlag.New(self:FindObj("Flag" .. i))
		self.flag_list[i]:SetIndex(i)
	end

	self.bead_list = {}
	for i = 1, 4 do
		self.bead_list[i] = ShenGeZKBead.New(self:FindObj("Bead" .. i))
		self.bead_list[i]:SetIndex(i)
	end

	self:ListenEvent("OnClickAttr", BindTool.Bind(self.OnClickAttr, self))
	self:ListenEvent("OnClickUpgrade", BindTool.Bind(self.OnClickUpgrade, self))
	self:ListenEvent("OnClickTip", BindTool.Bind(self.OnClickTip, self))
	self:ListenEvent("OnClickHook", BindTool.Bind(self.OnClickHook, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.red_point = self:FindVariable("ShowRedPoint")
end

function ShenGeZhangKongView:OpenCallBack()
end

function ShenGeZhangKongView:CloseCallBack()
	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.ShenGeView)
end

function ShenGeZhangKongView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local check_id = ShenGeData.Instance:GetZhangkongItemID()
	if check_id ~= nil and check_id == item_id then
		self:SetItemNum()
	end
end

function ShenGeZhangKongView:OnClickAttr()
	ShenGeCtrl.Instance:OpenZKAttrTipView()
end

function ShenGeZhangKongView:OnClickUpgrade()
	if self:CheckIsAllMax() then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengeZhangkong.AllLevelMax)
		return
	end

	if self.item_id == nil then
		return
	end

	-- if ShenGeData.Instance:IsZhangkongAllMaxLevel() then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.ShengeZhangkong.AllLevelMax, 1)
	-- end
	roll_type = self.is_ten and 10 or 1
	local buy_num = roll_type
	if ItemData.Instance:GetItemNumInBagById(self.item_id) < buy_num and not self.is_auto_buy then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			self:SetItemNum()
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.is_auto_buy = is_buy_quick
			end
		end
		if roll_type == 10 then
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, buy_num - ItemData.Instance:GetItemNumInBagById(self.item_id))
		else
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
		end

		self:SetItemNum()
		return
	end

	local function ok_callback(is_auto)
		if is_auto ~= nil then
			self.is_auto_buy = is_auto
		end
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_UPLEVEL_ZHANGKONG, roll_type == 10 and 1 or 0)
	end

	--if not TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenge_zk"] or not TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenge_zk"].is_auto_buy then
	if not self.is_auto_buy and ItemData.Instance:GetItemNumInBagById(self.item_id) < buy_num then
		local str = string.format(Language.ShenGe.ZKUpTip, roll_type)
		TipsCtrl.Instance:ShowCommonAutoView("auto_shenge_zk", str, ok_callback, canel_callback, true, nil, nil, nil, true)
	else
		ok_callback()
	end
end

function ShenGeZhangKongView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(214)
end

function ShenGeZhangKongView:OnClickHook()
	self.is_ten = not self.is_ten
	if self.show_hook ~= nil then
		self.show_hook:SetValue(self.is_ten)
	end

	self:SetItemNum()
end

function ShenGeZhangKongView:CheckIsAllMax()
	local is_can = true
	local all_info = ShenGeData.Instance:GetZhangKongAllInfo()

	if all_info == nil or next(all_info) == nil then
		return is_can
	end

	for i = 1, 4 do
		if all_info.zhangkong_list[i - 1] ~= nil then
			local max_level_cfg = ShenGeData.Instance:GetGridCfgByGrid(i - 1)
			local max_level = #max_level_cfg - 1
			local cur_level = all_info.zhangkong_list[i - 1].level
			if cur_level < max_level then
				is_can = false
				break
			end
		end
	end
	
	return is_can
end

function ShenGeZhangKongView:SetItemNum()
	local item_id = ShenGeData.Instance:GetZhangkongItemID()
	if item_id == nil then
		return
	end

	self.item_id = item_id
	local has_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	local str = ""
	local color = COLOR.GREED
	if other_cfg ~= nil then
		if self.is_ten then
			local data = other_cfg.ten_chou_item
			if data ~= nil and has_num < data.num then
				color = COLOR.RED
			end
			str = data.num
		else
			local data = other_cfg.once_chou_item
			if data ~= nil and has_num < data.num then
				color = COLOR.RED
			end		
			str = data.num	
		end
	end

	if self.item_str ~= nil then
		self.item_str:SetValue(ToColorStr(has_num, color) .. "/" .. str)
	end
	
	self.red_point:SetValue(has_num > 0)

	local item_data = ItemData.Instance:GetItemConfig(item_id)
	if self.consume_path ~= nil and item_data ~= nil then
		local bundle, asset = ResPath.GetItemIcon(item_data.icon_id)
		self.consume_path:SetAsset(bundle, asset)
	end
end

function ShenGeZhangKongView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			for i = 1, 4 do
				self:FlushByIndex(i - 1)
			end
		elseif k == "show_fly" then
			self:ShowShengWuViewFly(v.item_list)
		end
	end
end

function ShenGeZhangKongView:FlushByIndex(grid)
	if grid == nil then
		return
	end

	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local attr_tab, _, kind_cfg = ShenGeData.Instance:GetInlayAttrListAndOtherFightPower(cur_page)	
	if attr_tab == nil or kind_cfg == nil then
		return
	end

	local i = grid + 1
	if self.flag_list == nil or self.flag_list[i] == nil then
		return
	end

	local cfg = ShenGeData.Instance:GetZhangkongInfoByGrid(i - 1, true)
	if cfg ~= nil and next(cfg) ~= nil then
		if self.flag_list[i]:GetLevel() == nil or self.flag_list[i]:GetLevel() ~= cfg.level then
			local flag_data = {}
			local read_level = cfg.show_next and cfg.level - 1 or cfg.level
			flag_data.name = string.format(Language.ShenGe.ZKFlagTitle, cfg.name, read_level)
			flag_data.attr_list = {}
			flag_data.level = read_level
			local attr_cfg = CommonStruct.AttributeNoUnderline()
			for j = 1, 2 do
				if cfg.attr_list ~= nil and cfg.attr_list[j] ~= nil then
					local name = ShenGeZhanKongEnumName[cfg.attr_list[j].name] or ""
					local attr_data = {}
					attr_data.name = name .. ":"
					attr_data.val = cfg.attr_list[j].val
					table.insert(flag_data.attr_list, attr_data)
					local key = ShenGeZKCapAttr[cfg.attr_list[j].name]
					if key ~= nil then
						attr_cfg[key] = attr_cfg[key] + cfg.attr_list[j].val
					end
				end
			end

			if cfg.shenge_pro ~= nil then
				local pro_val = cfg.shenge_pro * 0.0001
				local attr_data = {}
				attr_data.name = Language.ShenGe.ZKFlagDesc[i] .. ":"
				attr_data.val = tostring(cfg.shenge_pro * 0.01) .. "%" 
				table.insert(flag_data.attr_list, attr_data)
				if kind_cfg[i] ~= nil then
					for k,v in pairs(kind_cfg[i]) do
						  if v ~= nil then
					   		local add_val = math.floor(pro_val * attr_tab[k])
					   		attr_cfg[k] = attr_cfg[k] + add_val
					   end
					end
				end
			end

			flag_data.cap_value = CommonDataManager.GetCapability(attr_cfg)
			flag_data.show_next = cfg.show_next
			self.flag_list[i]:SetData(flag_data)
		end

		if self.bead_list[i] ~= nil then
			local bead_data = {}
			bead_data.exp_str = cfg.exp .. "/" .. cfg.cfg_exp
			bead_data.pro_value = cfg.exp / cfg.cfg_exp
			self.bead_list[i]:SetData(bead_data)
		end
	end
	self:SetItemNum()
end

function ShenGeZhangKongView:OnAutoFly(grid, add_exp)
	if grid then
		TipsCtrl.Instance:ShowFlyEffectManager(ViewName.ShenGeView, "effects2/prefab/ui/ui_guangdian1_prefab", "UI_guangdian1", 
			self.button, self.bead_list[grid + 1].root_node, nil, 0.5,
			BindTool.Bind(self.OnAutoFlyCallFun, self, grid, add_exp))
	end
end

function ShenGeZhangKongView:OnAutoFlyCallFun(grid, add_exp)
	self:FlushByIndex(grid)
	self:ShowFloatingTips(grid, add_exp)
end

function ShenGeZhangKongView:ShowShengWuViewFly(data)
	local fly_list = {}
	for k,v in pairs(data) do
		if fly_list[v.grid] == nil then
			fly_list[v.grid] = {}
			fly_list[v.grid].grid = v.grid
			fly_list[v.grid].add_exp = v.add_exp
		else
			fly_list[v.grid].add_exp = fly_list[v.grid].add_exp + v.add_exp
		end
	end

	for k,v in pairs(fly_list) do
		self:OnAutoFly(v.grid, v.add_exp)
	end
end

function ShenGeZhangKongView:ShowFloatingTips(index, add_exp)
	TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.Goddess.AddExp, add_exp), piaozi_pos[index].x, piaozi_pos[index].y, true)
end
-----------------------ShenGeZKFlag-------------------------------------------------
ShenGeZKFlag = ShenGeZKFlag or BaseClass(BaseRender)
function ShenGeZKFlag:__init(instance)
	self.title_str = self:FindVariable("TitleStr")
	for i = 1, 3 do
		self["name" .. i] = self:FindVariable("Name" .. i)
		self["value" .. i] = self:FindVariable("Value" .. i)
		self["show_attr" .. i] = self:FindVariable("ShowAttr" .. i)
	end

	self.cap_value = self:FindVariable("CapValue")
	self.tip_str = self:FindVariable("TopStr")
	self.index = 0
	self.level = nil
end

function ShenGeZKFlag:__delete()
	self.index = 0
	self.level = nil
end

function ShenGeZKFlag:SetIndex(index)
	self.index = index
end

function ShenGeZKFlag:SetData(data)
	self.data = data
	self:Flush()
end

function ShenGeZKFlag:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	self.level = self.data.level or 0

	if self.title_str ~= nil then
		self.title_str:SetValue(self.data.name or "")
	end

	if self.cap_value ~= nil then
		self.cap_value:SetValue(self.data.cap_value or 0)
	end
	
	if self.tip_str ~= nil then
		local str = self.data.show_next and Language.ShenGe.OneShowTip or Language.ShenGe.TopShowTip 
		self.tip_str:SetValue(str)
	end

	for i = 1, 3 do
		local is_show = false
		if self["name" .. i] ~= nil and self.data.attr_list[i] ~= nil then
			self["name" .. i]:SetValue(self.data.attr_list[i].name or "")
			is_show = true
		end

		if self["value" .. i] ~= nil and self.data.attr_list[i] ~= nil then
			self["value" .. i]:SetValue(self.data.attr_list[i].val or "")
			is_show = true
		end

		if self["show_attr" .. i] then
			self["show_attr" .. i]:SetValue(is_show)
		end
	end
end

function ShenGeZKFlag:GetLevel()
	return self.level
end

-----------------------ShenGeZKBead-------------------------------------------------
ShenGeZKBead = ShenGeZKBead or BaseClass(BaseRender)
function ShenGeZKBead:__init(instance)
	self.pro_val = self:FindVariable("ProValue")
	self.pro_str = self:FindVariable("ProStr")
	self.index = 0
end

function ShenGeZKBead:__delete()
end

function ShenGeZKBead:SetIndex(index)
	self.index = index
end

function ShenGeZKBead:SetData(data)
	self.data = data
	self:Flush()
end

function ShenGeZKBead:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.pro_val ~= nil then
		self.pro_val:SetValue(self.data.pro_value or 0)
	end

	if self.pro_str ~= nil then
		self.pro_str:SetValue(self.data.exp_str or 0)
	end
end
