TipZiZhiView = TipZiZhiView or BaseClass(BaseView)

local FROM_MOUNT = 1		-- 从坐骑界面打开
local FROM_WING = 2			-- 从羽翼界面打开
local FROM_HALO = 3			-- 从光环界面打开
local FROM_SHENGONG = 4		-- 从神弓界面打开（足迹）
local FROM_SHENYI = 5		-- 从神翼界面打开（披风）
local FROM_FIGHT_MOUNT = 6	-- 法印
local FROM_HALIDOM = 7		-- 圣物
local FROM_BEAUTY_HALO = 8 	-- 芳华
local FROM_HEADWEAR = 9 	-- 从头饰
local FROM_MASK = 10 		-- 从面饰
local FROM_WAIST = 11		-- 从腰饰
local FROM_BEAD = 12		-- 从灵珠
local FROM_FABAO = 13		-- 从法宝
local FROM_KIRIN_ARM = 14 	-- 从麒麟臂

local NameList = {"坐骑", "羽翼", "光环", "足迹", "披风", "法印", "法器", "芳华","头饰","面饰","腰饰","灵珠","法宝","麒麟臂"}

local FLUSH_PARAM = {[FROM_MOUNT] = "mount", [FROM_WING] = "wing", [FROM_HALO] = "halo", [FROM_SHENGONG] = "shengong",
		[FROM_SHENYI] = "shenyi", [FROM_FIGHT_MOUNT] = "fightmount", [FROM_HALIDOM] = "halidom", [FROM_BEAUTY_HALO] = "beautyhali",
		[FROM_HEADWEAR] = "headwear", [FROM_MASK] = "mask", [FROM_WAIST] = "waist", [FROM_BEAD] = "bead", [FROM_FABAO] = "fabao", [FROM_KIRIN_ARM] = "kirin_arm",
}

function TipZiZhiView:__init()
	self.ui_config = {"uis/views/tips/advancetips","ZiZhiTip"}
	self:SetMaskBg(true)
	-- self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_first_open = false
	self.get_way_list = {}
end

-- 创建完调用
function TipZiZhiView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton", BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickUseButton", BindTool.Bind(self.OnClickUseButton, self))
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

	self.item_tip = self:FindVariable("ItemTip")

	self.text_way_list = {
		{is_show = self:FindVariable("ShowWay1"), name = self:FindVariable("WayName1")},
		{is_show = self:FindVariable("ShowWay2"), name = self:FindVariable("WayName2")},
		{is_show = self:FindVariable("ShowWay3"), name = self:FindVariable("WayName3")}
	}
	self.icon_list = {}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3")},
	}

	-- self.cell = ItemCell.New(self:FindObj("ItemCell").gameObject)
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemGood")) 
	self.use_button = self:FindObj("UseButton")
	self.scroller = self:FindObj("Scroller").scroll_rect

	self.from_view = nil
	self.info = nil
	self.max_shuxingdan_count = 0
	self.grade_cfg = nil
	self.item_id = nil
	self.max_grade = 0
	self.next_max_shuxingdan_count = nil
	self:Flush()
end

function TipZiZhiView:ReleaseCallBack()
	self.from_view = nil
	self.info = nil
	self.max_shuxingdan_count = nil
	self.grade_cfg = nil
	self.item_id = nil
	self.can_use = nil
	self.is_first_open = nil
	self.max_grade = nil
	-- if self.use_succe ~= nil then
	-- 	GlobalEventSystem:UnBind(self.use_succe)
	-- 	self.use_succe = nil
	-- end

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
	self.use_button = nil
	self.scroller = nil
	self.item_tip = nil

	self.text_way_list = {}
	self.icon_list = {}
	self.get_way_list = {}

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- if self.cell then
	-- 	self.cell:DeleteMe()
	-- 	self.cell = nil
	-- end
end

function TipZiZhiView:OnClickWay(index)
	if nil == self.get_way_list[index] then return end
	local data = {item_id = self.item_id}
	-- ViewManager.Instance:Close(ViewName.Advance)
	local list = Split(self.get_way_list[index], "#")
	if list then
		ViewManager.Instance:Open(list[1], TabIndex[list[2]])
	end
	-- self:Close()
end

function TipZiZhiView:OpenCallBack()
	self.is_first_open = true
	self.can_use = true
	-- if self.use_succe == nil then
	-- 	self.use_succe = GlobalEventSystem:Bind(OtherEventType.USE_PROP_SUCCE, BindTool.Bind(self.CanUse, self))
	-- end

	self.scroller.normalizedPosition = Vector2(0, 1)

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function TipZiZhiView:CloseCallBack()
	self.is_first_open = false
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.info = nil
	self.max_shuxingdan_count = nil
	self.grade_cfg = nil
	self.can_use = nil
	self.is_first_open = nil
	self.max_grade = nil
	self.next_max_shuxingdan_count = nil
end

function TipZiZhiView:OnClickCloseButton()
	self:Close()
end

function TipZiZhiView:OnClickUseButton()
	if self.info == nil or self.grade_cfg == nil or self.max_shuxingdan_count == nil then
		return
	end
	if (self.grade_cfg.shuxingdan_limit + self.max_shuxingdan_count) == 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mount.GradeNoEnough)
		return
	end

	if self.info.shuxingdan_count >= self.max_shuxingdan_count then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mount.GradeNoEnough)
		return
	end

	self.bag_prop_data = ItemData.Instance:GetItem(self.item_id)

	if self.bag_prop_data == nil then
		local item_shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_shop_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			self:Close()
			-- TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
			return
		else
			-- if item_shop_cfg.bind_gold == 0 then
			-- 	TipsCtrl.Instance:ShowShopView(self.item_id, 2)
			-- 	return
			-- end

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
	if item_id == MountDanId.ZiZhiDanId or item_id == WingDanId.ZiZhiDanId or
		item_id == HaloDanId.ZiZhiDanId or item_id == ShengongDanId.ZiZhiDanId or item_id == ShenyiDanId.ZiZhiDanId
		or item_id == FightMountDanId.ZiZhiDanId or item_id == HalidomDanId.ZiZhiDanId or item_id == BeautyHaloDanId.ZiZhiDanId or 
		item_id == HeadwearDanId.ZiZhiDanId or item_id == MaskDanId.ZiZhiDanId or item_id == WaistDanId.ZiZhiDanId or
		item_id == BeadDanId.ZiZhiDanId or item_id == FaBaoDanId.ZiZhiDanId or item_id == KirinArmDanId.ZiZhiDanId then

		if self.from_view == FROM_SHENGONG or self.from_view == FROM_SHENYI then
			GoddessCtrl.Instance:FlushView(FLUSH_PARAM[self.from_view])
		else
			AdvanceCtrl.Instance:FlushViewFromZiZhi(FLUSH_PARAM[self.from_view])
		end

		self.have_pro_num:SetValue(ItemData.Instance:GetItemNumInBagById(self.item_id))
		self.can_use = true
	end
end

function TipZiZhiView:SetData()
	if self.from_view == FROM_MOUNT then
		self.info = MountData.Instance:GetMountInfo()
		self.max_shuxingdan_count = MountData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = MountData.Instance:GetMountGradeCfg(self.info.grade)
		self.max_grade = MountData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = MountData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count	

	elseif self.from_view == FROM_WING then
		self.info = WingData.Instance:GetWingInfo()
		self.max_shuxingdan_count = WingData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = WingData.Instance:GetWingGradeCfg(self.info.grade)
		self.max_grade = WingData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = WingData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_HALO then
		self.info = HaloData.Instance:GetHaloInfo()
		self.max_shuxingdan_count = HaloData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.info.grade)
		self.max_grade = HaloData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = HaloData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_SHENGONG then
		self.info = ShengongData.Instance:GetShengongInfo()
		self.max_shuxingdan_count = ShengongData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = ShengongData.Instance:GetShengongGradeCfg(self.info.grade)
		self.max_grade = ShengongData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = ShengongData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_SHENYI then
		self.info = ShenyiData.Instance:GetShenyiInfo()
		self.max_shuxingdan_count = ShenyiData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.info.grade)
		self.max_grade = ShenyiData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = ShenyiData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_FIGHT_MOUNT then
		self.info = FaZhenData.Instance:GetFightMountInfo()
		self.max_shuxingdan_count = FaZhenData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = FaZhenData.Instance:GetMountGradeCfg(self.info.grade)
		self.max_grade = FaZhenData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = FaZhenData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_HALIDOM then
		self.info = HalidomData.Instance:GetHalidomInfo()
		self.max_shuxingdan_count = HalidomData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = HalidomData.Instance:GetHalidomGradeCfg(self.info.grade)
		self.max_grade = HalidomData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = HalidomData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_BEAUTY_HALO then
		self.info = BeautyHaloData.Instance:GetBeautyHaloInfo()
		self.max_shuxingdan_count = BeautyHaloData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = BeautyHaloData.Instance:GetBeautyHaloGradeCfg(self.info.grade)
		self.max_grade = BeautyHaloData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = BeautyHaloData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_HEADWEAR then
		self.info = HeadwearData.Instance:GetHeadwearInfo()
		self.max_shuxingdan_count = HeadwearData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = HeadwearData.Instance:GetHeadwearGradeCfg(self.info.grade)
		self.max_grade = HeadwearData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = HeadwearData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_MASK then
		self.info = MaskData.Instance:GetMaskInfo()
		self.max_shuxingdan_count = MaskData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = MaskData.Instance:GetMaskGradeCfg(self.info.grade)
		self.max_grade = MaskData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = MaskData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_WAIST then
		self.info = WaistData.Instance:GetWaistInfo()
		self.max_shuxingdan_count = WaistData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = WaistData.Instance:GetWaistGradeCfg(self.info.grade)
		self.max_grade = WaistData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = WaistData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_BEAD then
		self.info = BeadData.Instance:GetBeadInfo()
		self.max_shuxingdan_count = BeadData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = BeadData.Instance:GetBeadGradeCfg(self.info.grade)
		self.max_grade = BeadData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = BeadData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_FABAO then
		self.info = FaBaoData.Instance:GetFaBaoInfo()
		self.max_shuxingdan_count = FaBaoData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(self.info.grade)
		self.max_grade = FaBaoData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = FaBaoData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	elseif self.from_view == FROM_KIRINARM then
		self.info = KirinArmData.Instance:GetKirinArmInfo()
		self.max_shuxingdan_count = KirinArmData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = KirinArmData.Instance:GetKirinArmGradeCfg(self.info.grade)
		self.max_grade = KirinArmData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 10, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = KirinArmData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count

	end

	if self.info == nil or self.max_shuxingdan_count == nil or self.grade_cfg == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	local shuxingdan = nil
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == MountShuXingDanCfgType.Type and self.from_view == FROM_MOUNT then
			shuxingdan = v
			break
		elseif v.type == WingShuXingDanCfgType.Type and self.from_view == FROM_WING then
			shuxingdan = v
			break
		elseif v.type == HaloShuXingDanCfgType.Type and self.from_view == FROM_HALO then
			shuxingdan = v
			break
		elseif v.type == ShengongShuXingDanCfgType.Type and self.from_view == FROM_SHENGONG then
			shuxingdan = v
			break
		elseif v.type == ShenyiShuXingDanCfgType.Type and self.from_view == FROM_SHENYI then
			shuxingdan = v
			break
		elseif v.type == FaZhenShuXingDanCfgType.Type and self.from_view == FROM_FIGHT_MOUNT then
			shuxingdan = v
			break
		elseif v.type == HalidomShuXingDanCfgType.Type and self.from_view == FROM_HALIDOM then
			shuxingdan = v
			break
		elseif v.type == BeautyHaloShuXingDanCfgType.Type and self.from_view == FROM_BEAUTY_HALO then
			shuxingdan = v
			break
		elseif v.type == HeadwearShuXingDanCfgType.Type and self.from_view == FROM_HEADWEAR then
			shuxingdan = v
			break
		elseif v.type == MaskShuXingDanCfgType.Type and self.from_view == FROM_MASK then
			shuxingdan = v
			break
		elseif v.type == WaistShuXingDanCfgType.Type and self.from_view == FROM_WAIST then
			shuxingdan = v
			break
		elseif v.type == BeadShuXingDanCfgType.Type and self.from_view == FROM_BEAD then
			shuxingdan = v
			break
		elseif v.type == FaBaoShuXingDanCfgType.Type and self.from_view == FROM_FABAO then
			shuxingdan = v
			break
		elseif v.type == KirinArmShuXingDanCfgType.Type and self.from_view == FROM_KIRINARM then
			shuxingdan = v
			break
		end
	end
	if not shuxingdan then return end

	if self.item_tip ~= nil and self.grade_cfg ~= nil then
		self.item_tip:SetValue(Language.Common.ShengYu .. shuxingdan.item_name .. ":")
	end

	self.shengming:SetValue(shuxingdan.maxhp * self.info.shuxingdan_count)
	self.shengming_add:SetValue(shuxingdan.maxhp)
	self.gongji:SetValue(shuxingdan.gongji * self.info.shuxingdan_count)
	self.gongji_add:SetValue(shuxingdan.gongji)
	self.fangyu:SetValue(shuxingdan.fangyu * self.info.shuxingdan_count)
	self.fangyu_add:SetValue(shuxingdan.fangyu)
	local data = {}
	data.item_id = self.item_id
	data.prop_name = item_cfg.pro_name
	-- self.cell:SetData(data)
	self.bag_prop_data = ItemData.Instance:GetItem(self.item_id)
	self.have_pro_num:SetValue(ItemData.Instance:GetItemNumInBagById(self.item_id))
	self.exp_cur_value:SetValue(self.info.shuxingdan_count)
	self.exp_max_value:SetValue(self.max_shuxingdan_count)
	self.pro_name:SetValue(item_cfg.name)
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
		-- local str = string.format(Language.Advance.GreenStr, self.info.shuxingdan_count, self.max_shuxingdan_count)
		-- if self.info.shuxingdan_count >= self.max_shuxingdan_count then
		-- 	str = string.format(Language.Advance.RedStr, self.info.shuxingdan_count, self.max_shuxingdan_count)
		-- end
		local num = self.max_shuxingdan_count - self.info.shuxingdan_count
		local str = string.format(Language.Advance.ColorStr,num)
		self.cur_uese_text:SetValue(str)
		self.next_use_num:SetValue(self.next_max_shuxingdan_count or 0)
	end
	self.is_first_open = false
	self.show_next_effect:SetValue(self.max_grade < self.info.grade or self.max_shuxingdan_count > self.info.shuxingdan_count)
	self.show_next_use_text:SetValue(nil ~= self.next_max_shuxingdan_count and self.next_max_shuxingdan_count > 0)
	self.use_button.button.interactable = (self.info.grade < self.max_grade) and true or (self.max_shuxingdan_count > self.info.shuxingdan_count)
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
					-- local bundle, asset = ResPath.GetImages("Icon_System_Shop")
					-- self.icon_list[k].icon:SetAsset(bundle, asset)
					self.icon_list[k].icon:SetValue(Language.Common.Shop)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					-- local bundle, asset = ResPath.GetImages(getway_cfg_k.icon)
					-- self.icon_list[k].icon:SetAsset(bundle, asset)
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

function TipZiZhiView:SetItemData()
	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	self.item_cell:SetData({item_id = self.item_id, is_bind=0})
	self.item_cell:SetNum(num)
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
		elseif k == "halidomzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_HALIDOM
		elseif k == "beautyhalozizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_BEAUTY_HALO
		elseif k == "headwearzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_HEADWEAR
		elseif k == "maskzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_MASK
		elseif k == "waistzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_WAIST
		elseif k == "beadzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_BEAD
		elseif k == "fabaozizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_FABAO
		elseif k == "kirin_armzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_KIRINARM
		end
		if self.item_id ~= nil then
			self:SetData()
			self:SetItemData()
			self:ShowWay()
		end
	end
end