TipChengZhangView = TipChengZhangView or BaseClass(BaseView)

local FROM_MOUNT = 1		-- 从坐骑界面打开
local FROM_WING = 2			-- 从羽翼界面打开
local FROM_HALO = 3			-- 从光环界面打开
local FROM_SHENGONG = 4		-- 从神弓界面打开
local FROM_SHENYI = 5		-- 从神翼界面打开

local NameList = {"坐骑", "羽翼", "光环", "神弓", "神翼"}

function TipChengZhangView:__init()
	self.ui_config = {"uis/views/tips/advancetips_prefab","ChengZhangTip"}
	self.view_layer = UiLayer.Pop

	self.get_way_list = {}
	self.is_first_open = false
	self.from_view = nil
	self.info = nil
	self.level_cfg = nil
	self.grade_cfg = nil
	self.max_chengzhangdan_count = nil
	self.next_grade_max_chengzhangdan_count = nil
	self.item_id = nil
	self.can_use = true
	self.max_grade = 0
	self.tip_grade_cfg = nil
end

-- 创建完调用
function TipChengZhangView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickUseButton",
		BindTool.Bind(self.OnClickUseButton, self))
	self:ListenEvent("OnClickWay1",
		BindTool.Bind(self.OnClickWay, self, 1))
	self:ListenEvent("OnClickWay2",
		BindTool.Bind(self.OnClickWay, self, 2))
	self:ListenEvent("OnClickWay3",
		BindTool.Bind(self.OnClickWay, self, 3))

	self.mingzhong = self:FindVariable("MingZhong")
	self.shanbi = self:FindVariable("ShanBi")
	self.gongji = self:FindVariable("GongJi")
	self.baoji = self:FindVariable("BaoJi")
	self.fangyu = self:FindVariable("FangYu")
	self.jianren = self:FindVariable("JianRen")
	self.maxhp = self:FindVariable("HP")
	self.cur_add_per = self:FindVariable("Current_Per")
	self.have_pro_num = self:FindVariable("RemaindeNum")
	self.explain = self:FindVariable("Explain")
	self.exp_cur_value = self:FindVariable("ExpCurValue")
	self.exp_max_value = self:FindVariable("ExpMaxValue")
	self.prop_name = self:FindVariable("PropName")
	self.name = self:FindVariable("Name")
	self.cur_use_text = self:FindVariable("CurUseText")
	self.next_use_num = self:FindVariable("NextUseNum")
	self.tip_grade = self:FindVariable("TipGrade")

	self.show_tip = self:FindVariable("ShowTips")
	self.show_next_use_text = self:FindVariable("ShowNextUseTX")

	self.show_ways = self:FindVariable("ShowTexts")
	self.show_icons = self:FindVariable("ShowIcons")
	self.text_way_list = {
		{is_show = self:FindVariable("ShowWay1"), name = self:FindVariable("Way1")},
		{is_show = self:FindVariable("ShowWay2"), name = self:FindVariable("Way2")},
		{is_show = self:FindVariable("ShowWay3"), name = self:FindVariable("Way3")}
	}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3")},
	}

	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.use_button = self:FindObj("UseButton")

	self:Flush()
end

function TipChengZhangView:ReleaseCallBack()
	self.from_view = nil
	self.info = nil
	self.level_cfg = nil
	self.grade_cfg = nil
	self.max_chengzhangdan_count = nil
	self.can_use = nil
	self.item_id = nil
	self.is_first_open = nil
	self.max_grade = nil
	self.get_way_list = {}
end

function TipChengZhangView:OnClickCloseButton()
	self:Close()
end

function TipChengZhangView:OpenCallBack()
	self.is_first_open = true
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function TipChengZhangView:CloseCallBack()
	self.is_first_open = false
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.info = nil
	self.level_cfg = nil
	self.grade_cfg = nil
	self.next_grade_max_chengzhangdan_count = nil
	self.max_chengzhangdan_count = nil
	self.max_grade = nil
	self.tip_grade_cfg = nil
end

function TipChengZhangView:OnClickWay(index)
	if nil == index or nil == self.get_way_list[index] then return end
	local data = {item_id = self.item_id}
	ViewManager.Instance:OpenByCfg(self.get_way_list[index], data)
	self:Close()
end

function TipChengZhangView:OnClickUseButton()
	if self.info == nil or self.grade_cfg == nil or self.max_chengzhangdan_count == nil then
		return
	end
	if (self.grade_cfg.chengzhangdan_limit + self.max_chengzhangdan_count) == 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mount.GradeNoEnough)
		return
	end

	if self.info.chengzhangdan_count >= self.max_chengzhangdan_count then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mount.GradeNoEnough)
		return
	end

	self.bag_prop_data = ItemData.Instance:GetItem(self.item_id)
	if self.bag_prop_data == nil then
		local item_shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_shop_cfg == nil then
			-- TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
			return
		else
			local func = function(item_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id)
			return
		end
	end

	if not self.can_use then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	PackageCtrl.Instance:SendUseItem(self.bag_prop_data.index, 1, self.bag_prop_data.sub_type, item_cfg.need_gold)
	self.can_use = false
end

function TipChengZhangView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == MountDanId.ChengZhangDanId or item_id == MountDanId.ZiZhiDanId or
		item_id == WingDanId.ChengZhangDanId or item_id == WingDanId.ZiZhiDanId or
		item_id == HaloDanId.ChengZhangDanId or item_id == HaloDanId.ZiZhiDanId or
		item_id == ShengongDanId.ChengZhangDanId or item_id == ShengongDanId.ZiZhiDanId or
		item_id == ShenyiDanId.ChengZhangDanId or item_id == ShenyiDanId.ZiZhiDanId then
		self.have_pro_num:SetValue(ItemData.Instance:GetItemNumInBagById(self.item_id))
		self.can_use = true
	end
end

function TipChengZhangView:SetData()
	if self.from_view == FROM_MOUNT then
		self.info = MountData.Instance:GetMountInfo()
		if not self.info or not next(self.info) then return end
		self.level_cfg = MountData.Instance:GetMountLevelCfg(self.info.mount_level)
		self.grade_cfg = MountData.Instance:GetMountGradeCfg(self.info.grade)
		self.max_chengzhangdan_count = MountData.Instance:GetSpecialImageAttrSum().chengzhangdan_count
		self.max_grade = MountData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_grade_max_chengzhangdan_count = MountData.Instance:GetSpecialImageAttrSum(info).chengzhangdan_count
		self.tip_grade_cfg = MountData.Instance:GetChengzhangDanLimit()
	elseif self.from_view == FROM_WING then
		self.info = WingData.Instance:GetWingInfo()
		if not self.info or not next(self.info) then return end
		self.level_cfg = WingData.Instance:GetWingLevelCfg(self.info.wing_level)
		self.grade_cfg = WingData.Instance:GetWingGradeCfg(self.info.grade)
		self.max_chengzhangdan_count = WingData.Instance:GetSpecialImageAttrSum().chengzhangdan_count
		self.max_grade = WingData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_grade_max_chengzhangdan_count = WingData.Instance:GetSpecialImageAttrSum(info).chengzhangdan_count
		self.tip_grade_cfg = WingData.Instance:GetChengzhangDanLimit()
	elseif self.from_view == FROM_HALO then
		self.info = HaloData.Instance:GetHaloInfo()
		if not self.info or not next(self.info) then return end
		self.level_cfg = HaloData.Instance:GetHaloLevelCfg(self.info.halo_level)
		self.grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.info.grade)
		self.max_chengzhangdan_count = HaloData.Instance:GetSpecialImageAttrSum().chengzhangdan_count
		self.max_grade = HaloData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_grade_max_chengzhangdan_count = HaloData.Instance:GetSpecialImageAttrSum(info).chengzhangdan_count
		self.tip_grade_cfg = HaloData.Instance:GetChengzhangDanLimit()
	elseif self.from_view == FROM_SHENGONG then
		self.info = ShengongData.Instance:GetShengongInfo()
		if not self.info or not next(self.info) then return end
		self.level_cfg = ShengongData.Instance:GetShengongLevelCfg(self.info.shengong_level)
		self.grade_cfg = ShengongData.Instance:GetShengongGradeCfg(self.info.grade)
		self.max_chengzhangdan_count = ShengongData.Instance:GetSpecialImageAttrSum().chengzhangdan_count
		self.max_grade = ShengongData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_grade_max_chengzhangdan_count = ShengongData.Instance:GetSpecialImageAttrSum(info).chengzhangdan_count
		self.tip_grade_cfg = ShengongData.Instance:GetChengzhangDanLimit()
	else
		self.info = ShenyiData.Instance:GetShenyiInfo()
		if not self.info or not next(self.info) then return end
		self.level_cfg = ShenyiData.Instance:GetShenyiLevelCfg(self.info.shenyi_level)
		self.grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.info.grade)
		self.max_chengzhangdan_count = ShenyiData.Instance:GetSpecialImageAttrSum().chengzhangdan_count
		self.max_grade = ShenyiData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_grade_max_chengzhangdan_count = ShenyiData.Instance:GetSpecialImageAttrSum(info).chengzhangdan_count
		self.tip_grade_cfg = ShenyiData.Instance:GetChengzhangDanLimit()
	end
	if self.info == nil or self.level_cfg == nil or self.grade_cfg == nil or self.max_chengzhangdan_count == nil then
		return
	end

	local level_attr = CommonDataManager.GetAttributteByClass(self.level_cfg, true)
	local grade_attr = CommonDataManager.GetAttributteByClass(self.grade_cfg, true)
	local sum_attr = CommonDataManager.AddAttributeAttr(level_attr, grade_attr)
	local data = {}
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	data.item_id = self.item_id
	data.prop_name = item_cfg.prop_name
	self.cell:SetData(data)
	self.bag_prop_data = ItemData.Instance:GetItem(self.item_id)
	self.prop_name:SetValue(item_cfg.name)
	self.have_pro_num:SetValue(ItemData.Instance:GetItemNumInBagById(self.item_id))
	self.cur_add_per:SetValue(self.info.chengzhangdan_count * 1)
	self.gongji:SetValue(math.floor(sum_attr.gong_ji * self.info.chengzhangdan_count * 0.01))
	self.fangyu:SetValue(math.floor(sum_attr.fang_yu * self.info.chengzhangdan_count * 0.01))
	self.maxhp:SetValue(math.floor(sum_attr.max_hp * self.info.chengzhangdan_count * 0.01))
	self.mingzhong:SetValue(math.floor(sum_attr.ming_zhong * self.info.chengzhangdan_count * 0.01))
	self.shanbi:SetValue(math.floor(sum_attr.shan_bi * self.info.chengzhangdan_count * 0.01))
	self.baoji:SetValue(math.floor(sum_attr.bao_ji * self.info.chengzhangdan_count * 0.01))
	self.jianren:SetValue(math.floor(sum_attr.jian_ren * self.info.chengzhangdan_count * 0.01))
	self.exp_cur_value:SetValue(self.info.chengzhangdan_count)
	self.exp_max_value:SetValue(self.max_chengzhangdan_count)
	if self.max_chengzhangdan_count == 0 then
		self.explain:SetValue(0)
		self.show_tip:SetValue(true)
		self.name:SetValue(NameList[self.from_view])
		self.next_use_num:SetValue(self.next_grade_max_chengzhangdan_count or 0)
		local str = string.format(Language.Mount.ShowRedStr, self.tip_grade_cfg and self.tip_grade_cfg.gradename or "一阶")
		self.tip_grade:SetValue(str)
	else
		self.show_tip:SetValue(false)
		if self.is_first_open then
			self.explain:InitValue(self.info.chengzhangdan_count / self.max_chengzhangdan_count)
		else
			self.explain:SetValue(self.info.chengzhangdan_count / self.max_chengzhangdan_count)
		end
		local str = string.format(Language.Advance.GreenStr, self.info.chengzhangdan_count, self.max_chengzhangdan_count)
		if self.info.chengzhangdan_count >= self.max_chengzhangdan_count then
			str = string.format(Language.Advance.RedStr, self.info.chengzhangdan_count, self.max_chengzhangdan_count)
		end
		self.cur_use_text:SetValue(str)
		self.next_use_num:SetValue(self.next_grade_max_chengzhangdan_count or 0)
	end
	self.is_first_open = false
	self.show_next_use_text:SetValue(nil ~= self.next_grade_max_chengzhangdan_count and self.next_grade_max_chengzhangdan_count > 0
		and (self.tip_grade_cfg and self.tip_grade_cfg.grade - 1 <= self.info.grade))
	self.use_button.button.interactable = (self.info.grade < self.max_grade) and true or (self.max_chengzhangdan_count > self.info.chengzhangdan_count)
end

function TipChengZhangView:ShowWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for k, v in ipairs(self.icon_list) do
		v.is_show:SetValue(false)
		self.text_way_list[k].is_show:SetValue(false)
	end
	if next(way) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.show_icons:SetValue(true)
				self.show_ways:SetValue(false)
				if tonumber(v) == 0 then
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUI("Icon_System_Shop")
					self.icon_list[k].icon:SetAsset(bundle, asset)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUI(getway_cfg_k.icon)
					self.icon_list[k].icon:SetAsset(bundle, asset)
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.show_ways:SetValue(true)
				self.show_icons:SetValue(false)
				if tonumber(v) == 0 then
					self.text_way_list[k].is_show:SetValue(true)
					self.text_way_list[k].name:SetValue(Language.Common.Shop)
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.text_way_list[k].is_show:SetValue(true)
					if getway_cfg_k.button_name ~= "" and getway_cfg_k.button_name ~= nil then
						self.text_way_list[k].name:SetValue(getway_cfg_k.button_name)
					else
						self.text_way_list[k].name:SetValue(getway_cfg_k.discription)
					end
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	elseif nil == next(way) and (nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg) then
		self.show_ways:SetValue(true)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		for k, v in pairs(msg) do
			self.text_way_list[k].is_show:SetValue(true)
			self.text_way_list[k].name:SetValue(v)
		end
	end
end

function TipChengZhangView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "mountchengzhang" then
			-- print("坐骑成长丹界面")
			self.item_id = v.item_id
			self.from_view = FROM_MOUNT
		elseif k == "wingchengzhang" then
			-- print("羽翼成长丹界面")
			self.item_id = v.item_id
			self.from_view = FROM_WING
		elseif k == "halochengzhang" then
			-- print("光环成长丹界面")
			self.item_id = v.item_id
			self.from_view = FROM_HALO
		elseif k == "shengongchengzhang" then
			-- print("神弓成长丹界面")
			self.item_id = v.item_id
			self.from_view = FROM_SHENGONG
		elseif k == "shenyichengzhang" then
			-- print("神翼成长丹界面")
			self.item_id = v.item_id
			self.from_view = FROM_SHENYI
		end
		if self.item_id ~= nil then
			-- print("TipChengZhangView : OnFlush() self.item_id == ", self.item_id)
			self:SetData()
			self:ShowWay()
		end
	end
end