TipZiZhiView = TipZiZhiView or BaseClass(BaseView)

local FROM_MOUNT = 1		-- 从坐骑界面打开
local FROM_WING = 2			-- 从羽翼界面打开
local FROM_HALO = 3			-- 从光环界面打开
local FROM_SHENGONG = 4		-- 从神弓界面打开
local FROM_SHENYI = 5		-- 从神翼界面打开
local FROM_FIGHT_MOUNT = 6	-- 从战骑界面打开
local FROM_SHEN_BING = 7	-- 从神兵界面打开
local FROM_FOOT = 8			-- 从足迹界面打开
local FROM_CLOAK = 9		-- 从披风界面打开
local FROM_WAIST = 10		-- 从腰饰界面打开
local FROM_TOUSHI = 11		-- 从头饰界面打开
local FROM_QILINBI = 12		-- 从麒麟臂界面打开
local FROM_MASK = 13		-- 从面饰界面打开
local FROM_LINGZHU = 14		-- 从灵珠界面打开
local FROM_XIANBAO = 15		-- 从仙宝界面打开
local FROM_LINGCHONG = 16	-- 从灵宠界面打开
local FROM_LINGGONG = 17	-- 从灵弓界面打开
local FROM_LINGQI = 18		-- 从灵骑界面打开

local NameList = {"坐骑", "羽翼", "光环", "神弓", "神翼", "神兵", "足迹", "披风", "腰饰", "头饰", "麒麟臂", "面饰", "灵珠", "仙宝", "灵宠", "灵弓", "灵骑"}

function TipZiZhiView:__init()
	self.ui_config = {"uis/views/tips/advancetips_prefab","ZiZhiTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_first_open = false
	self.get_way_list = {}

	self.shuxingdan_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward, "type")
end

-- 创建完调用
function TipZiZhiView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickUseButton",
		BindTool.Bind(self.OnClickUseButton, self))
	self:ListenEvent("OnClickWay1", BindTool.Bind(self.OnClickWay, self, 1))
	self:ListenEvent("OnClickWay2", BindTool.Bind(self.OnClickWay, self, 2))
	self:ListenEvent("OnClickWay3", BindTool.Bind(self.OnClickWay, self, 3))

	self.gongji = self:FindVariable("GongJi")
	self.gongji_add = self:FindVariable("GongJiAdd")
	self.fangyu = self:FindVariable("FangYu")
	self.fangyu_add = self:FindVariable("FangYuAdd")
	self.shengming = self:FindVariable("ShengMing")
	self.shengming_add = self:FindVariable("ShengMingAdd")
	self.have_pro_num = self:FindVariable("RemaindeNum")
	self.explain = self:FindVariable("Explain")
	self.exp_cur_value = self:FindVariable("ExpCurValue")
	self.exp_max_value = self:FindVariable("ExpMaxValue")
	self.pro_name = self:FindVariable("PropName")
	self.cur_uese_text = self:FindVariable("CurUseText")
	self.next_use_num = self:FindVariable("NextUseNum")

	self.show_ways = self:FindVariable("ShowTextWays")
	self.show_icons = self:FindVariable("ShowIconWays")
	self.show_next_effect = self:FindVariable("ShowNextEffect")

	self.show_tip = self:FindVariable("ShowTip")
	self.show_next_use_text = self:FindVariable("ShowNextUseTX")
	self.tip_name = self:FindVariable("TipName")
	self.jie_text = self:FindVariable("jie_text")


	self.text_way_list = {
		{is_show = self:FindVariable("ShowWay1"), name = self:FindVariable("WayName1")},
		{is_show = self:FindVariable("ShowWay2"), name = self:FindVariable("WayName2")},
		{is_show = self:FindVariable("ShowWay3"), name = self:FindVariable("WayName3")}
	}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3")},
	}

	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.use_button = self:FindObj("UseButton")
	self.scroller = self:FindObj("Scroller").scroll_rect

	self.from_view = nil
	self.info = nil
	self.max_shuxingdan_count = 0
	self.item_id = nil
	self.max_grade = 0
	self.next_max_shuxingdan_count = nil
	self:Flush()
end

function TipZiZhiView:ReleaseCallBack()
	self.from_view = nil
	self.info = nil
	self.max_shuxingdan_count = nil
	self.item_id = nil
	self.can_use = nil
	self.is_first_open = nil
	self.max_grade = nil
	-- if self.use_succe ~= nil then
	-- 	GlobalEventSystem:UnBind(self.use_succe)
	-- 	self.use_succe = nil
	-- end
	self.get_way_list = {}

	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	-- 清理变量和对象
	self.gongji = nil
	self.gongji_add = nil
	self.fangyu = nil
	self.fangyu_add = nil
	self.shengming = nil
	self.shengming_add = nil
	self.have_pro_num = nil
	self.explain = nil
	self.exp_cur_value = nil
	self.exp_max_value = nil
	self.pro_name = nil
	self.cur_uese_text = nil
	self.next_use_num = nil
	self.show_ways = nil
	self.show_icons = nil
	self.show_next_effect = nil
	self.show_tip = nil
	self.show_next_use_text = nil
	self.tip_name = nil
	self.text_way_list = nil
	self.icon_list = nil
	self.use_button = nil
	self.scroller = nil
	self.jie_text = nil
end

function TipZiZhiView:OnClickWay(index)
	if nil == self.get_way_list[index] then return end
	local data = {item_id = self.item_id}
	local list = Split(self.get_way_list[index], "#")
	local tab_index = TabIndex[list[2]]
	if list then
		ViewManager.Instance:Open(list[1], tonumber(tab_index))
	end
	self:Close()
end

function TipZiZhiView:OpenCallBack()
	self.is_first_open = true
	self.can_use = true
	-- if self.use_succe == nil then
	-- 	self.use_succe = GlobalEventSystem:Bind(OtherEventType.USE_PROP_SUCCE, BindTool.Bind(self.CanUse, self))
	-- end
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)

	self.scroller.normalizedPosition = Vector2(0, 1)

	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function TipZiZhiView:CloseCallBack()
	self.is_first_open = false
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.info = nil
	self.max_shuxingdan_count = nil
	self.can_use = nil
	self.is_first_open = nil
	self.max_grade = nil
	self.next_max_shuxingdan_count = nil
	self.get_way_list = {}
end

function TipZiZhiView:OnClickCloseButton()
	self:Close()
end

function TipZiZhiView:OnClickUseButton()
	if self.info == nil or self.max_shuxingdan_count == nil then
		return
	end
	if self.max_shuxingdan_count == 0 and self.from_view ~= FROM_SHEN_BING then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mount.GradeNoEnough)
		return
	end

	if self.info.shuxingdan_count >= self.max_shuxingdan_count and self.from_view ~= FROM_SHEN_BING then
		TipsCtrl.Instance:ShowSystemMsg(self.from_view ~= FROM_SHEN_BING and Language.Mount.GradeNoEnough or Language.Common.ShenBingZiZhiLimit)
		return
	end

	self.bag_prop_data = ItemData.Instance:GetItem(self.item_id)

	if self.bag_prop_data == nil then
		local item_shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_shop_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			self:Close()
			return
		else
			if item_shop_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(self.item_id, 2)
				return
			end

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

function TipZiZhiView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self.have_pro_num:SetValue(ItemData.Instance:GetItemNumInBagById(self.item_id))
	self.can_use = true
	self:Flush()
end

function TipZiZhiView:GetShuXinDanInfo()
	local shuxingdan_info = nil
	if self.from_view == FROM_MOUNT then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.MOUNT]
	elseif self.from_view == FROM_WING then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.WING]
		
	elseif self.from_view == FROM_HALO then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.HALO]
		
	elseif self.from_view == FROM_FOOT then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.FOOT]
		
	elseif self.from_view == FROM_SHENGONG then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.SHENGONG]
		
	elseif self.from_view == FROM_SHENYI then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.SHENYI]
		
	elseif self.from_view == FROM_FIGHT_MOUNT then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.FIGHTMOUNT]
		
	elseif self.from_view == FROM_SHEN_BING then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.SHENBING]
		
	elseif self.from_view == FROM_CLOAK then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.CLOAK]
		
	elseif self.from_view == FROM_WAIST then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.WAIST]
		
	elseif self.from_view == FROM_TOUSHI then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.TOUSHI]

	elseif self.from_view == FROM_QILINBI then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.QILINBI]

	elseif self.from_view == FROM_MASK then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.MASK]

	elseif self.from_view == FROM_LINGZHU then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.LINGZHU]

	elseif self.from_view == FROM_XIANBAO then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.XIANBAO]

	elseif self.from_view == FROM_LINGCHONG then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.LINGCHONG]

	elseif self.from_view == FROM_LINGGONG then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.LINGGONG]

	elseif self.from_view == FROM_LINGQI then
		shuxingdan_info = self.shuxingdan_cfg[ZIZHI_TYPE.LINGQI]
	end

	return shuxingdan_info
end

function TipZiZhiView:FlushData()
	if self.from_view == FROM_MOUNT then
		self.info = MountData.Instance:GetMountInfo()
		self.max_shuxingdan_count = MountData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.max_grade = MountData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = MountData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_WING then
		self.info = WingData.Instance:GetWingInfo()
		self.max_shuxingdan_count = WingData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.max_grade = WingData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = WingData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_HALO then
		self.info = HaloData.Instance:GetHaloInfo()
		self.max_shuxingdan_count = HaloData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.max_grade = HaloData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = HaloData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_FOOT then
		self.info = FootData.Instance:GetFootInfo()
		self.max_shuxingdan_count = FootData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.max_grade = FootData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = FootData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_SHENGONG then
		self.info = ShengongData.Instance:GetShengongInfo()
		self.max_shuxingdan_count = ShengongData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.max_grade = ShengongData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = ShengongData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_SHENYI then
		self.info = ShenyiData.Instance:GetShenyiInfo()
		self.max_shuxingdan_count = ShenyiData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.max_grade = ShenyiData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = ShenyiData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_FIGHT_MOUNT then
		self.info = FightMountData.Instance:GetFightMountInfo()
		self.max_shuxingdan_count = FightMountData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.max_grade = FightMountData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = FightMountData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_SHEN_BING then
		local shen_bing_data = ShenBingData.Instance
		self.info = shen_bing_data:GetShenBingInfo()
		self.max_shuxingdan_count = shen_bing_data:GetLimitXingDanCount()
		self.max_grade = #shen_bing_data:GetShenBingCfg().level_attr
		self.next_max_shuxingdan_count = shen_bing_data:GetLimitXingDanCount(self.info.level + 1)

	elseif self.from_view == FROM_CLOAK then
		self.info = CloakData.Instance:GetCloakInfo()
		self.info.level = self.info.cloak_level
		local level_cfg = CloakData.Instance:GetCloakLevelCfg(self.info.level)
		self.max_shuxingdan_count = level_cfg.shuxingdan_limit
		self.max_grade = CloakData.Instance:GetMaxCloakLevel()
		local next_level_cfg = CloakData.Instance:GetCloakLevelCfg(self.info.level + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or level_cfg.shuxingdan_limit

	elseif self.from_view == FROM_WAIST then
		self.info = WaistData.Instance:GetYaoShiInfo()
		self.max_shuxingdan_count = WaistData.Instance:GetMaxShuXingDanCount()
		self.max_grade = WaistData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = WaistData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)

	elseif self.from_view == FROM_TOUSHI then
		self.info = TouShiData.Instance:GetTouShiInfo()
		self.max_shuxingdan_count = TouShiData.Instance:GetMaxShuXingDanCount()
		self.max_grade = TouShiData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = TouShiData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)

	elseif self.from_view == FROM_QILINBI then
		self.info = QilinBiData.Instance:GetQilinBiInfo()
		self.max_shuxingdan_count = QilinBiData.Instance:GetMaxShuXingDanCount()
		self.max_grade = QilinBiData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = QilinBiData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)

	elseif self.from_view == FROM_MASK then
		self.info = MaskData.Instance:GetMaskInfo()
		self.max_shuxingdan_count = MaskData.Instance:GetMaxShuXingDanCount()
		self.max_grade = MaskData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = MaskData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)

	elseif self.from_view == FROM_LINGZHU then
		self.info = LingZhuData.Instance:GetLingZhuInfo()
		self.max_shuxingdan_count = LingZhuData.Instance:GetMaxShuXingDanCount()
		self.max_grade = LingZhuData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = LingZhuData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)

	elseif self.from_view == FROM_XIANBAO then
		self.info = XianBaoData.Instance:GetXianBaoInfo()
		self.max_shuxingdan_count = XianBaoData.Instance:GetMaxShuXingDanCount()
		self.max_grade = XianBaoData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = XianBaoData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)

	elseif self.from_view == FROM_LINGCHONG then
		self.info = LingChongData.Instance:GetLingChongInfo()
		self.max_shuxingdan_count = LingChongData.Instance:GetMaxShuXingDanCount()
		self.max_grade = LingChongData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = LingChongData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)

	elseif self.from_view == FROM_LINGGONG then
		self.info = LingGongData.Instance:GetLingGongInfo()
		self.max_shuxingdan_count = LingGongData.Instance:GetMaxShuXingDanCount()
		self.max_grade = LingGongData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = LingGongData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)

	elseif self.from_view == FROM_LINGQI then
		self.info = LingQiData.Instance:GetLingQiInfo()
		self.max_shuxingdan_count = LingQiData.Instance:GetMaxShuXingDanCount()
		self.max_grade = LingQiData.Instance:GetSpecialImgMaxLevel()
		self.next_max_shuxingdan_count = LingQiData.Instance:GetMaxShuXingDanCount(self.info.grade + 1)
	end
end

function TipZiZhiView:SetData()
	self:FlushData()
	if self.info == nil or self.max_shuxingdan_count == nil then
		return
	end

	local shuxingdan = self:GetShuXinDanInfo()
	if nil == shuxingdan then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	self.shengming:SetValue(shuxingdan.maxhp * self.info.shuxingdan_count)
	self.shengming_add:SetValue(shuxingdan.maxhp)
	self.gongji:SetValue(shuxingdan.gongji * self.info.shuxingdan_count)
	self.gongji_add:SetValue(shuxingdan.gongji)
	self.fangyu:SetValue(shuxingdan.fangyu * self.info.shuxingdan_count)
	self.fangyu_add:SetValue(shuxingdan.fangyu)
	local data = {}
	data.item_id = self.item_id
	data.prop_name = item_cfg.pro_name
	self.cell:SetData(data)
	self.bag_prop_data = ItemData.Instance:GetItem(self.item_id)
	self.have_pro_num:SetValue(ItemData.Instance:GetItemNumInBagById(self.item_id))
	self.exp_cur_value:SetValue(self.info.shuxingdan_count)
	self.exp_max_value:SetValue(self.max_shuxingdan_count)
	self.pro_name:SetValue(item_cfg.name)
	self.jie_text:SetValue(self.from_view == FROM_SHEN_BING and Language.Common.Ji or Language.Common.Jie)
	if self.max_shuxingdan_count == 0 then
		self.explain:SetValue(0)
		self.show_tip:SetValue(true)
		self.tip_name:SetValue(NameList[self.from_view])
		self.next_use_num:SetValue(self.next_max_shuxingdan_count or 0)
	else
		self.show_tip:SetValue(false)
		if self.is_first_open then
			self.explain:InitValue(self.info.shuxingdan_count / self.max_shuxingdan_count)
		else
			self.explain:SetValue(self.info.shuxingdan_count / self.max_shuxingdan_count)
		end
		local str = ""
		if self.from_view ~= FROM_SHEN_BING and self.from_view ~= FROM_CLOAK then
			str = string.format(Language.Advance.GreenStr2, self.info.shuxingdan_count, self.max_shuxingdan_count)
			if self.info.shuxingdan_count >= self.max_shuxingdan_count then
				str = string.format(Language.Advance.RedStr, self.info.shuxingdan_count, self.max_shuxingdan_count)
			end
		else
			str = tostring(self.info.shuxingdan_count)
		end
		self.cur_uese_text:SetValue(str)
		self.next_use_num:SetValue(self.next_max_shuxingdan_count or 0)
	end
	self.is_first_open = false
	self.show_next_effect:SetValue(self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count)
	self.show_next_use_text:SetValue(nil ~= self.next_max_shuxingdan_count and self.next_max_shuxingdan_count > 0 and self.from_view ~= FROM_SHEN_BING and self.from_view ~= FROM_CLOAK)
	self.use_button.button.interactable = (((self.info.grade or self.info.level) < self.max_grade) and true or (self.max_shuxingdan_count > self.info.shuxingdan_count)) or self.from_view == FROM_SHEN_BING or self.from_view == FROM_CLOAK
end

function TipZiZhiView:ShowWay()
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
					self.icon_list[k].icon:SetValue(Language.Common.Shop)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					self.icon_list[k].icon:SetValue(getway_cfg_k.discription)
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.show_icons:SetValue(false)
				self.show_ways:SetValue(true)
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

function TipZiZhiView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "mountzizhi" then
			self.item_id = v.item_id or MountDanId.ZiZhiDanId
			self.from_view = FROM_MOUNT
		elseif k == "wingzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_WING
		elseif k == "halozizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_HALO
		elseif k == "shengongzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_SHENGONG
		elseif k == "shenyizizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_SHENYI
		elseif k == "fightmountzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_FIGHT_MOUNT
		elseif k == "shenbingzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_SHEN_BING
		elseif k == "footzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_FOOT
		elseif k == "cloakzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_CLOAK
		elseif k == "waist_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.WAIST] and self.shuxingdan_cfg[ZIZHI_TYPE.WAIST].item_id
			self.from_view = FROM_WAIST
		elseif k == "toushi_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.TOUSHI] and self.shuxingdan_cfg[ZIZHI_TYPE.TOUSHI].item_id
			self.from_view = FROM_TOUSHI
		elseif k == "qilinbi_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.QILINBI] and self.shuxingdan_cfg[ZIZHI_TYPE.QILINBI].item_id
			self.from_view = FROM_QILINBI
		elseif k == "mask_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.MASK] and self.shuxingdan_cfg[ZIZHI_TYPE.MASK].item_id
			self.from_view = FROM_MASK
		elseif k == "lingzhu_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.LINGZHU] and self.shuxingdan_cfg[ZIZHI_TYPE.LINGZHU].item_id
			self.from_view = FROM_LINGZHU
		elseif k == "xianbao_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.XIANBAO] and self.shuxingdan_cfg[ZIZHI_TYPE.XIANBAO].item_id
			self.from_view = FROM_XIANBAO
		elseif k == "lingchong_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.LINGCHONG] and self.shuxingdan_cfg[ZIZHI_TYPE.LINGCHONG].item_id
			self.from_view = FROM_LINGCHONG
		elseif k == "linggong_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.LINGGONG] and self.shuxingdan_cfg[ZIZHI_TYPE.LINGGONG].item_id
			self.from_view = FROM_LINGGONG
		elseif k == "lingqi_zizhi" then
			self.item_id = self.shuxingdan_cfg[ZIZHI_TYPE.LINGQI] and self.shuxingdan_cfg[ZIZHI_TYPE.LINGQI].item_id
			self.from_view = FROM_LINGQI
		end
		if self.item_id ~= nil then
			print("TipZiZhiView : OnFlush() self.item_id == ", self.item_id)
			self:SetData()
			self:ShowWay()
		end
	end
end