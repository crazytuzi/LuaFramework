local CommonFunc = require("game/tips/tips_common_func")
TipsShowPowerPropView = TipsShowPowerPropView or BaseClass(BaseView)

function TipsShowPowerPropView:__init()
	self.ui_config = {"uis/views/tips/proptips", "ShowPowerPropTip"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)

	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_handle = {}
	self.get_way_list = {}
	self.close_call_back = nil
	self.index = nil -- 魔器特殊处理
	self.is_magic_weapon = false
	self.play_audio = true
	self.power_prop_type = nil
	self.cell_height = 26
	self.property_list_num = 0
	self.offset_show_icons = 0  
end

function TipsShowPowerPropView:LoadCallBack()
	self:ListenEvent("CloseButton",
		BindTool.Bind(self.CloseTips, self))
	self:ListenEvent("OnClickWay1",
		BindTool.Bind(self.OnClickWay, self, 1))
	self:ListenEvent("OnClickWay2",
		BindTool.Bind(self.OnClickWay, self, 2))
	self:ListenEvent("OnClickWay3",
		BindTool.Bind(self.OnClickWay, self, 3))

	-- self.quality_img = self:FindObj("Quality_BG")
	self.price_icon = self:FindObj("SaleIcon")
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.title_icon_name = self:FindVariable("TitleIconName")
	self.use_level = self:FindVariable("UseLevel")
	self.prop_describe = self:FindVariable("Describe")
	self.price_text = self:FindVariable("Price")
	self.sale_info_content = self:FindVariable("SaleInfo")

	self.limit_day = self:FindVariable("LimitDay")
	self.limit_hour = self:FindVariable("LimitHour")
	self.limit_min = self:FindVariable("LimitMin")
	self.limit_sec = self:FindVariable("LimitSec")
	self.show_time_limit = self:FindVariable("ShowTimeLimit")
	self.show_day_limit = self:FindVariable("ShowDayLimit")
	self.show_storge_score = self:FindVariable("ShowStorgeScore")
	self.storge_score = self:FindVariable("StorgeScore")
	self.zhanli_text = self:FindVariable("ZhanLiText")
	self.prop_type = self:FindVariable("PropType")
	self.attack = self:FindVariable("Attack")
	self.health = self:FindVariable("Health")
	self.defense = self:FindVariable("Defense")
	self.mingzhong = self:FindVariable("MingZhong")
	self.shanbi = self:FindVariable("ShanBi")
	self.baoji = self:FindVariable("BaoJi")
	self.jianren = self:FindVariable("JianRen")
	self.show_zhanli = self:FindVariable("ShowZhanLi")
	self.show_attack = self:FindVariable("ShowAttack")
	self.show_health = self:FindVariable("ShowHealth")
	self.show_defense = self:FindVariable("ShowDefense")
	self.show_mingzhong = self:FindVariable("ShowMingZhong")
	self.show_shanbi = self:FindVariable("ShowShanBi")
	self.show_baoji = self:FindVariable("ShowBaoJi")
	self.show_jianren = self:FindVariable("ShowJianRen")

	self.ice_master = self:FindVariable("IceMaster")
	self.fire_master = self:FindVariable("FireMaster")
	self.thunder_master = self:FindVariable("ThunderMaster")
	self.poison_Master = self:FindVariable("PoisonMaster")
	self.show_ice_master = self:FindVariable("ShowIceMaster")
	self.show_fire_master = self:FindVariable("ShowFireMaster")
	self.show_thunder_master = self:FindVariable("ShowThunderMaster")
	self.show_poison_Master = self:FindVariable("ShowpoisonMaster")
	self.qualityline = self:FindVariable("QualityLine")
	self.frame = self:FindObj("Frame")

	self.show_ignore_fangyu = self:FindVariable("ShowIgnoreFangyu")
	self.ignore_fangyu = self:FindVariable("IgnoreFangyu")
	self.show_hurt_increase = self:FindVariable("ShowHurtIncrease")
	self.hurt_increase = self:FindVariable("HurtIncrease")
	self.show_hurt_reduce = self:FindVariable("ShowHurtReduce")
	self.hurt_reduce = self:FindVariable("HurtReduce")

	self.show_ways = self:FindVariable("ShowTexts")
	self.show_icons = self:FindVariable("ShowIcons")
	self.text_way_list = {
		{is_show = self:FindVariable("ShowText1"), name = self:FindVariable("Text1")},
		{is_show = self:FindVariable("ShowText2"), name = self:FindVariable("Text2")},
		{is_show = self:FindVariable("ShowText3"), name = self:FindVariable("Text3")}
	}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3")},
	}

	for i=1, 3 do
		local btn = self:FindObj("Button"..i)
		local text = btn:FindObj("Text")
		self.buttons[i] = {btn = btn, text = text}
	end
end

function TipsShowPowerPropView:__delete()
	self.buttons = {}
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_label = nil
	CommonFunc.DeleteMe()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.button_handle = {}
	self.power_prop_type = nil
end

function TipsShowPowerPropView:ReleaseCallBack()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil
	end

	-- 清理变量和对象
	self.price_icon = nil
	self.scroller_rect = nil
	self.title_icon_name = nil
	self.use_level = nil
	self.prop_describe = nil
	self.price_text = nil
	self.sale_info_content = nil
	self.limit_day = nil
	self.limit_hour = nil
	self.limit_min = nil
	self.limit_sec = nil
	self.show_time_limit = nil
	self.show_day_limit = nil
	self.show_storge_score = nil
	self.storge_score = nil
	self.show_ways = nil
	self.show_icons = nil
	self.text_way_list = nil
	self.icon_list = nil
	self.show_zhanli = nil
	self.zhanli_text = nil
	self.prop_type = nil
	self.buttons = {}

	self.attack = nil
	self.health = nil
	self.defense = nil
	self.mingzhong = nil
	self.shanbi = nil
	self.baoji = nil
	self.jianren = nil
	self.show_zhanli = nil
	self.show_attack = nil
	self.show_health = nil
	self.show_defense = nil
	self.show_mingzhong = nil
	self.show_shanbi = nil
	self.show_baoji = nil
	self.show_jianren = nil

	self.ice_master = nil
	self.fire_master = nil
	self.thunder_master = nil
	self.poison_Master = nil
	self.show_ice_master = nil
	self.show_fire_master = nil
	self.show_thunder_master = nil
	self.show_poison_Master = nil
	self.frame = nil
	self.data = nil
	self.qualityline = nil

	self.show_ignore_fangyu = nil
	self.ignore_fangyu = nil
	self.show_hurt_increase = nil
	self.hurt_increase = nil
	self.show_hurt_reduce = nil
	self.hurt_reduce = nil
	
	self.button_handle = {}
end

function TipsShowPowerPropView:CloseTips()
	self.data = nil
	self:Close()
end

function TipsShowPowerPropView:CloseCallBack()
	if self.close_call_back ~= nil then
		if self.is_magic_weapon then
			self.close_call_back(self.index)
		else
			self.close_call_back()
		end
	end
	self.close_call_back = nil

	if self.time_count ~= nil then
		CountDown.Instance:RemoveCountDown(self.time_count)
		self.time_count = nil
	end

	self.get_way_list = {}

	if next(self.button_handle) then
		for k,v in pairs(self.button_handle) do
			v:Dispose()
		end
	end
	
end

function TipsShowPowerPropView:OpenCallBack()
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self.property_list_num = 0
	self.offset_show_icons = 0
end

--点击跳转到获取途径
function TipsShowPowerPropView:OnClickWay(index)
	if index == nil or self.get_way_list[index] == nil then return end

	ViewManager.Instance:OpenByCfg(self.get_way_list[index], self.data)

	local list = Split(self.get_way_list[index], "#")
	ViewManager.Instance:CloseAllViewExceptViewName(list[1], list[2])
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			tx = self.data.btn_text or tx
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			self.button_handle[k] = self:ListenEvent("Button"..k,
				BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function TipsShowPowerPropView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	--神器特殊处理
	local military_rank = MilitaryRankData.Instance:GetCurLevel()
	if item_cfg.get_msg == Language.Shenqi.BaoJiaGetWay then --宝甲需要校尉
		if military_rank < 12 then
			SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.NeedXiaoWei)
			return
		end
	end
	if item_cfg.get_msg == Language.Shenqi.ShenBingGetWay then --神兵需要大都统
		if military_rank < 10 then
			SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.NeedDaDuTong)
			return
		end
	end

	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end

	--魔器特殊处理
	if item_cfg.use_type == 41 then
		self.index = self.data.id
		self.is_magic_weapon = true
	end

	self:Close()
end

--data = {item_id=100....} 如果背包有的话最好把背包的物品传过来
function TipsShowPowerPropView:SetData(data, from_view, param_t, close_call_back,power_prop_type)
	if not data then
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.power_prop_type = power_prop_type or 0
	self:Flush()
end

function TipsShowPowerPropView:OnFlush()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local bundle,sprite = ResPath.GetQualityLineBgIcon(item_cfg.color)
	self.qualityline:SetAsset(bundle, sprite)
	-- self.quality_img.image:LoadSprite(bundle,sprite)

	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.title_icon_name:SetValue(name_str)
	self.cell:SetData(self.data)
	self.cell:SetInteractable(false)

	local description =	ItemData.Instance:GetItemDescription(self.data.item_id)
	self.prop_describe:SetValue(description)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	--local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	--local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	--local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind) --level_befor.."级【"..level_behind.."转】"
	local level_for = string.format(Language.Common.Zhuan_Level, item_cfg.limit_level)
	local level_str = vo.level >= item_cfg.limit_level and level_for or string.format(Language.Mount.ShowRedStr, level_for)

	self.use_level:SetValue(level_str)
	if(self.data.price == nil) then
		self.data.price = item_cfg.sellprice
	end
	if self.data.price ~= nil then
		self.price_text:SetValue(self.data.price)
	else
		self.sale_info_content:SetValue(false)
	end
	showHandlerBtn(self)
	self:SetWay()
	-- self.scroller_rect.normalizedPosition = Vector2(0, 1)

	if self.data.invalid_time and self.data.invalid_time > 0 then
		self:SetPropLimitTime(self.data.invalid_time)
	elseif item_cfg.time_length and item_cfg.time_length > 0 then
		local time_limit = tonumber(item_cfg.time_length)
		local is_show_day_limit = time_limit - 24 * 3600 > 0
		if not is_show_day_limit then
			local left_hour = math.floor(time_limit / 3600)
			local left_min = math.floor((time_limit - left_hour * 3600) / 60)
			local left_sec = math.floor(time_limit - left_hour * 3600 - left_min * 60)
			self.limit_hour:SetValue(left_hour)
			self.limit_min:SetValue(left_min)
			self.limit_sec:SetValue(left_sec)
		else
			self.limit_day:SetValue(math.ceil(time_limit / 24 / 3600))
		end
	end
	self.show_time_limit:SetValue(item_cfg.time_length and item_cfg.time_length > 0 or false)
	-- self.show_storge_score:SetValue((self.data.item_id == 27789 or self.data.item_id == 27790 or self.data.item_id == 27791) and true or false)
	if item_cfg.guild_storage_score and item_cfg.guild_storage_score > 0 then
		self.storge_score:SetValue(item_cfg.guild_storage_score)
	end

	local show_power = item_cfg.power ~= nil and item_cfg.power ~= 0
	self.show_zhanli:SetValue(show_power)
	if show_power then
		self.zhanli_text:SetValue(tonumber(item_cfg.power))
	end
	self:SetFightPower(self.power_prop_type,item_cfg)
	local cfg = GuildCtrl.Instance.guild_data:GetStorageFixedItemCfg()
	if self.data.item_id == cfg.item_id and self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		self.show_storge_score:SetValue(true)
		self.storge_score:SetValue(cfg.need_score)
	else
		self.show_storge_score:SetValue(false)
	end
	self:ChangePanelHeight(self.property_list_num)
end

-- 设置限时物品倒计时
function TipsShowPowerPropView:SetPropLimitTime(invalid_time)
	if not invalid_time then return end

	local diff_time = invalid_time - TimeCtrl.Instance:GetServerTime()

	local is_show_day_limit = diff_time - 24 * 3600 > 0
	self.show_day_limit:SetValue(is_show_day_limit)
	self.limit_day:SetValue(math.ceil(diff_time / 24 / 3600))

	if not self.time_count and diff_time > 0 and not is_show_day_limit then
		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.time_count ~= nil then
					CountDown.Instance:RemoveCountDown(self.time_count)
					self.time_count = nil
				end
				self:Close()
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.limit_hour:SetValue(left_hour)
			self.limit_min:SetValue(left_min)
			self.limit_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.time_count = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

--设置获取方式
function TipsShowPowerPropView:SetWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for k, v in ipairs(self.icon_list) do
		v.is_show:SetValue(false)
		self.text_way_list[k].is_show:SetValue(false)
	end
	if next(way) and (nil == item_cfg.get_msg or "" == item_cfg.get_msg) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.show_icons:SetValue(true)
				self.show_ways:SetValue(false)
				if tonumber(v) == 0 then
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUIButton("Icon_System_Shop")
					self.icon_list[k].icon:SetAsset(bundle, asset)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUIButton(getway_cfg_k.icon)
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
	elseif nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg then
		self.show_ways:SetValue(true)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		self.show_icons:SetValue(false)
		for k, v in pairs(msg) do
			self.text_way_list[k].is_show:SetValue(true)
			self.text_way_list[k].name:SetValue(v)
			self.offset_show_icons = -70
		end
	end
end

function TipsShowPowerPropView:SetFightPower(power_prop_type,item_cfg)
	local fight_power = 0
	local cfg = {}

	if power_prop_type == SHOW_POWER_PROP_TYPE.TITLE_NAME then														--称号
		cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1)
		self:SetProperty(cfg)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	elseif power_prop_type == SHOW_POWER_PROP_TYPE.GEMSTONE then													--宝石
		local attr = {}
		cfg = ForgeData.Instance:GetGemCfg(self.data.item_id)
		local attr_type1 = cfg.attr_type1
		local attr_type2 = cfg.attr_type2
		attr[attr_type1] = cfg.attr_val1
		attr[attr_type2] = cfg.attr_val2
		self:SetProperty(attr)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(attr))
	elseif power_prop_type == SHOW_POWER_PROP_TYPE.SHUXINGDAN then													--属性丹
		local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
		for k,v in pairs(shuxingdan_cfg) do
			if v.type == item_cfg.param1 then
				cfg = v
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end

	elseif power_prop_type == SHOW_POWER_PROP_TYPE.BRACELET then													--手镯
		local mojie_data = MojieData.Instance:GetMojieCfgForStuffId(self.data.item_id, 1)
		if mojie_data == nil then return end
		self:SetProperty(mojie_data)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(mojie_data))
	elseif power_prop_type == SHOW_POWER_PROP_TYPE.SHENQI then 														--神器
		local shenbing_cfg = ShenqiData.Instance:GetShenbingInlayAllCfg()											--神兵
		local baojia_cfg = ShenqiData.Instance:GetBaojiaInlayAllCfg()												--宝甲
		for k,v in pairs(shenbing_cfg) do
			if v.inlay_stuff_id == self.data.item_id then
				cfg = v
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapability(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
		for k,v in pairs(baojia_cfg) do
			if v.inlay_stuff_id == self.data.item_id then
				cfg = v
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapability(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif power_prop_type == SHOW_POWER_PROP_TYPE.JINJIEQUIP then 														--形象
		for i = 0, 3 do
			local mount_cfg = MountData.Instance:GetEquipInfoCfg(i, 1)													--坐骑
			local wing_cfg = WingData.Instance:GetEquipInfoCfg(i,1)														--羽翼
			local halo_cfg = HaloData.Instance:GetEquipInfoCfg(i, 1)													--天罡
			local fazhen_cfg = FaZhenData.Instance:GetEquipInfoCfg(i, 1)												--法印
			local beautyhalo_cfg =BeautyHaloData.Instance:GetEquipInfoCfg(i, 1)											--芳华
			local halidom_cfg = HalidomData.Instance:GetEquipInfoCfg(i, 1)												--圣物
			local foot_cfg =ShengongData.Instance:GetEquipInfoCfg(i, 1)													--足迹
			local mantle_cfg = ShenyiData.Instance:GetEquipInfoCfg(i, 1)												--披风
			local bead_cfg = BeadData.Instance:GetEquipInfoCfg(i, 1)													--灵珠
			local fabao_cfg = FaBaoData.Instance:GetEquipInfoCfg(i, 1)													--法宝
			local head_wear_cfg = HeadwearData.Instance:GetEquipInfoCfg(i, 1)											--头饰
			local kirin_arm_cfg = KirinArmData.Instance:GetEquipInfoCfg(i, 1)											--麒麟臂
			local mask_cfg = MaskData.Instance:GetEquipInfoCfg(i, 1)													--面饰
			local waist_cfg = WaistData.Instance:GetEquipInfoCfg(i, 1)													--腰饰
			if self.data.item_id == mount_cfg.item.item_id then
				cfg = mount_cfg
			elseif self.data.item_id == wing_cfg.item.item_id then
				cfg = wing_cfg
			elseif self.data.item_id == halo_cfg.item.item_id then
				cfg = halo_cfg
			elseif self.data.item_id == fazhen_cfg.item.item_id then
				cfg = fazhen_cfg
			elseif self.data.item_id == beautyhalo_cfg.item.item_id then
				cfg = beautyhalo_cfg
			elseif self.data.item_id == halidom_cfg.item.item_id then
				cfg = halidom_cfg
			elseif self.data.item_id == foot_cfg.item.item_id then
				cfg = foot_cfg
			elseif self.data.item_id == mantle_cfg.item.item_id then
				cfg = mantle_cfg
			elseif self.data.item_id == bead_cfg.item.item_id then
				cfg = bead_cfg
			elseif self.data.item_id == fabao_cfg.item.item_id then
				cfg = fabao_cfg
			elseif self.data.item_id == head_wear_cfg.item.item_id then
				cfg = head_wear_cfg
			elseif self.data.item_id == kirin_arm_cfg.item.item_id then
				cfg = kirin_arm_cfg
			elseif self.data.item_id == mask_cfg.item.item_id then
				cfg = mask_cfg
			elseif self.data.item_id == waist_cfg.item.item_id then
				cfg = waist_cfg
			end
		end		
		self:SetProperty(cfg)
		fight_power = CommonDataManager.GetCapability(CommonDataManager.GetAttributteByClass(cfg))
	elseif power_prop_type == SHOW_POWER_PROP_TYPE.ZHUANSHENG then														--转生
		local zhuansheng_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("new_zhuansheng_cfg_auto").suit_base_attr_cfg, "item_id")
		if zhuansheng_cfg and zhuansheng_cfg[self.data.item_id] then
			local value_type = zhuansheng_cfg[self.data.item_id].base_attr_type
			local value = zhuansheng_cfg[self.data.item_id].base_attr_value
			if value_type and value then
				local attr_name_list = {
					[1] = "gong_ji",
					[2] = "ming_zhong",
					[3] = "bao_ji",
					[4] = "ignore_fangyu",
					[5] = "hurt_increase",
					[6] = "max_hp",
					[7] = "fang_yu",
					[8] = "hurt_reduce",
					[9] = "shan_bi",
					[10] = "jian_ren",
				}
				cfg[attr_name_list[value_type]] = value
			end
		end
		self:SetProperty(cfg)
		fight_power = CommonDataManager.GetCapability(CommonDataManager.GetAttributteByClass(cfg))
	end
	self.zhanli_text:SetValue(fight_power)
end


--设置战力
function TipsShowPowerPropView:SetProperty(cfg)
	local attack = 0
	local defense = 0
	local health = 0
	local mingzhong = 0
	local shanbi = 0
	local baoji = 0
	local jianren = 0
	local ice_master = 0
	local fire_master = 0
	local thunder_master = 0
	local poison_Master = 0
	local ignore_fangyu = 0
	local hurt_increase = 0
	local hurt_reduce = 0
	
	if cfg then
		attack = cfg.gong_ji or cfg.attack or cfg.gongji or 0
		defense = cfg.fang_yu or cfg.fangyu or 0
		health  = cfg.max_hp or cfg.maxhp or cfg.hp or cfg.qixue or 0
		mingzhong  = cfg.ming_zhong or cfg.mingzhong or 0
		shanbi  = cfg.shan_bi or cfg.shanbi or 0
		baoji  = cfg.bao_ji or cfg.baoji or 0
		jianren  = cfg.jian_ren or cfg.jianren or 0
		ice_master = cfg.ice_master or 0
		fire_master = cfg.fire_master or 0
		thunder_master = cfg.thunder_master or 0
		poison_Master = cfg.poison_master or 0
		ignore_fangyu = cfg.ignore_fangyu or cfg.ignorefangyu or 0
		hurt_increase = cfg.hurt_increase or cfg.hurtincrease or 0
		hurt_reduce = cfg.hurt_reduce or cfg.hurtreduce or 0

		self.show_attack:SetValue(attack > 0)
		self.show_defense:SetValue(defense > 0)
		self.show_health:SetValue(health > 0)
		self.show_mingzhong:SetValue(mingzhong > 0)
		self.show_shanbi:SetValue(shanbi > 0)
		self.show_baoji:SetValue(baoji > 0)
		self.show_jianren:SetValue(jianren > 0)
		self.show_ice_master:SetValue(ice_master > 0)
		self.show_fire_master:SetValue(fire_master > 0)
		self.show_thunder_master:SetValue(thunder_master > 0)
		self.show_poison_Master:SetValue(poison_Master > 0)
		self.show_ignore_fangyu:SetValue(ignore_fangyu > 0)
		self.show_hurt_increase:SetValue(hurt_increase > 0)
		self.show_hurt_reduce:SetValue(hurt_reduce > 0)

		--计算显示属性的条数，然后算出高度
		self.property_list_num = attack > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = defense > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = health > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = mingzhong > 0 and self.property_list_num + 1 or self.property_list_num		
		self.property_list_num = shanbi > 0 and self.property_list_num + 1 or self.property_list_num		
		self.property_list_num = baoji > 0 and self.property_list_num + 1 or self.property_list_num		
		self.property_list_num = jianren > 0 and self.property_list_num + 1 or self.property_list_num		
		self.property_list_num = ice_master > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = fire_master > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = thunder_master > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = poison_Master > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = ignore_fangyu > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = hurt_increase > 0 and self.property_list_num + 1 or self.property_list_num
		self.property_list_num = hurt_reduce > 0 and self.property_list_num + 1 or self.property_list_num

		self.attack:SetValue(attack)
		self.health:SetValue(health)
		self.defense:SetValue(defense)		
		self.mingzhong:SetValue(mingzhong)		
		self.shanbi:SetValue(shanbi)		
		self.baoji:SetValue(baoji)		
		self.jianren:SetValue(jianren)		
		self.ice_master:SetValue(ice_master)
		self.fire_master:SetValue(fire_master)
		self.thunder_master:SetValue(thunder_master)
		self.poison_Master:SetValue(poison_Master)
		self.ignore_fangyu:SetValue(ignore_fangyu)
		self.hurt_increase:SetValue(hurt_increase)
		self.hurt_reduce:SetValue(hurt_reduce)
	else
		self.show_attack:SetValue(false)
		self.show_defense:SetValue(false)
		self.show_health:SetValue(false)
		self.show_mingzhong:SetValue(false)
		self.show_shanbi:SetValue(false)
		self.show_baoji:SetValue(false)
		self.show_jianren:SetValue(false)
		self.show_ice_master:SetValue(false)
		self.show_fire_master:SetValue(false)
		self.show_thunder_master:SetValue(false)
		self.show_poison_Master:SetValue(false)
		self.show_ignore_fangyu:SetValue(false)
		self.show_hurt_increase:SetValue(false)
		self.show_hurt_reduce:SetValue(false)
	end
end


--控制Tips面板的长度
function TipsShowPowerPropView:ChangePanelHeight(item_count)
	--Tips面板长短控制
	local frame_HeightMax = 670
	local frame_HeightMix = 450
	local frame_offset = 505
	self:ChangeHeight(self.frame,item_count,frame_HeightMax,frame_HeightMix,frame_offset)

end	

function TipsShowPowerPropView:ChangeHeight(panel,item_count,HeightMax,HeightMix,offset)
	--Tips面板长短控制
	local panel_Width = panel.rect.rect.width
	local panel_height = self.cell_height * item_count + offset + self.offset_show_icons			--offset是listview和底框的间距和
	
	--最小高度和最大高度
	if panel_height > HeightMax then
		panel_height = HeightMax
	end
	if panel_height < HeightMix then
		panel_height = HeightMix
	end
	panel.rect.sizeDelta = Vector2(panel_Width, panel_height)

end	
