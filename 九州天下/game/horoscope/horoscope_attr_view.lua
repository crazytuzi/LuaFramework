--------------------------------------------------------------------------
-- HoroscopeAttrView 星座信息面板
--------------------------------------------------------------------------
HoroscopeAttrView = HoroscopeAttrView or BaseClass(BaseRender)

local EFFECT_CD = 1

function HoroscopeAttrView:__init()
	HoroscopeAttrView.Instance = self
	self:InitView()
end

function HoroscopeAttrView:__delete()
	if self.tweener then
		self.tweener:Pause()
		self.tweener = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function HoroscopeAttrView:InitView()
	self.hp = self:FindVariable("hp")
	self.add_hp = self:FindVariable("add_hp")
	self.atk = self:FindVariable("atk")
	self.add_atk = self:FindVariable("add_atk")
	self.def = self:FindVariable("def")
	self.add_def = self:FindVariable("add_def")
	self.fight = self:FindVariable("fight")
	self.add_fight = self:FindVariable("add_fight")
	self.bt = self:FindVariable("bt")
	self.number = self:FindVariable("number")
	self.suit_level = self:FindVariable("suit_level")
	self.cur_suit_level = self:FindVariable("cur_suit_level")

	self.name = self:FindVariable("name")
	self.angle_fight = self:FindVariable("angle_fight")
	self.angle_level = self:FindVariable("angle_level")
	self.angle_hp = self:FindVariable("angle_hp")
	self.angle_atk = self:FindVariable("angle_atk")
	self.angle_def = self:FindVariable("angle_def")
	self.angle_add_hp = self:FindVariable("angle_add_hp")
	self.angle_add_atk = self:FindVariable("angle_add_atk")
	self.angle_add_def = self:FindVariable("angle_add_def")

	self.move_max_icon = self:FindVariable("move_max_icon")
	self.is_allmax_level = self:FindVariable("is_allmax_level")
	self.is_angle_max_level = self:FindVariable("is_angle_max_level")

	self.attr = self:FindObj("attr")
	self.move_icon = self:FindObj("move_icon")
	self.effect_root = self:FindObj("EffectRoot")
	self.up_bt = self:FindObj("up_bt")

	self:ListenEvent("UpGrade", BindTool.Bind2(self.OnUpGrade, self, i))
	self:ListenEvent("ClosenAttr", BindTool.Bind(self.OnClosenAttr, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.OnHelpClick, self))
	self:ListenEvent("AllAttrClick", BindTool.Bind(self.OnAllAttrClick, self))

	self.item_cell = ItemCell.New(self:FindObj("item_cell"))
	self.item_data = {}

	self.cur_zodiac = 0
	self.effect_cd = 0
	self.xing_zuo_list = {}
	self.variable_table_list = {}
	self.event_table_list = {}
	self.obj_table_list = {}

	self.min_icon_list = {}
	self.max_icon_list = {}
	self.name_list = {}
	self.level_list = {}
	self.is_active_list = {}
	self.is_show_list = {}

	--星座位置列表
	self.horoscope_min_position_list = {}
	self.horoscope_min_position_list[1] = Vector3(290,0,0)
	self.horoscope_min_position_list[2] = Vector3(251,-145,0)
	self.horoscope_min_position_list[3] = Vector3(145,-251,0)
	self.horoscope_min_position_list[4] = Vector3(0,-290,0)
	self.horoscope_min_position_list[5] = Vector3(-145,-251,0)
	self.horoscope_min_position_list[6] = Vector3(-251,-145,0)
	self.horoscope_min_position_list[7] = Vector3(-290,0,0)
	self.horoscope_min_position_list[8] = Vector3(-251,145,0)
	self.horoscope_min_position_list[9] = Vector3(-145,251,0)
	self.horoscope_min_position_list[10] = Vector3(0,290,0)
	self.horoscope_min_position_list[11] = Vector3(145,251,0)
	self.horoscope_min_position_list[12] = Vector3(251,145,0)

	for i=1,12 do
		self.xing_zuo_list[i] = self:FindObj("xingzuo"..i)
		self.variable_table_list[i] = self.xing_zuo_list[i]:GetComponent(typeof(UIVariableTable))
		self.event_table_list[i] = self.xing_zuo_list[i]:GetComponent(typeof(UIEventTable))
		self.obj_table_list[i] = self.xing_zuo_list[i]:GetComponent(typeof(UINameTable))

		self.name_list[i] = self.variable_table_list[i]:FindVariable("name")
		self.level_list[i] = self.variable_table_list[i]:FindVariable("level")
		self.is_active_list[i] = self.variable_table_list[i]:FindVariable("is_active")
		self.is_show_list[i] = self.variable_table_list[i]:FindVariable("is_show")

		self.event_table_list[i]:ListenEvent("Click", BindTool.Bind2(self.OnClick, self, i))
	end

	-- self:FlushRight()
	self.move_icon:SetActive(false)
	self.attr:SetActive(false)
	self:FlushRedPt()
end

function HoroscopeAttrView:OnHelpClick()
	local tips_id = 82 -- 星座帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function HoroscopeAttrView:OnAllAttrClick()
	self:OpenAttr()
end

function HoroscopeAttrView:FlushRedPt()
	for i=1,12 do
		local level = HoroscopeData.Instance:GetXzLevelBySeq(i - 1)
		local data = HoroscopeData.Instance:GetSingDataById(i-1,level)
		local have_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
		if have_num > 0 and level < 30 then
			MoLongView.Instance:HoroscopeAttrShowRedPoint(true)
			return
		end
	end
	MoLongView.Instance:HoroscopeAttrShowRedPoint(false)
end

-- 升级时刷新特效
function HoroscopeAttrView:FlushEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui/ui_shengjichenggong_prefab",
			"UI_shengjichenggong",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

-- 属性面板
function HoroscopeAttrView:OnClosenAttr()
	self.attr:SetActive(false)
end

function HoroscopeAttrView:OpenAttr(data)
	local cur_level = HoroscopeData.Instance:GetXzSuitLevel(true)
	local cur_data = HoroscopeData.Instance:GetXzSuitAttrByLevel(cur_level)
	local next_data = HoroscopeData.Instance:GetXzSuitAttrByLevel(HoroscopeData.Instance:GetNextLevelByCurlevel(cur_level))
	TipsCtrl.Instance:ShowTotalAttrView(Language.Horoscope.XinHunTaoZ, HoroscopeData.Instance:GetXzSuitLevel(), cur_data, next_data,Language.Horoscope.XinHunLevelGo)
end

-- 消耗道具
function HoroscopeAttrView:ItemCellFlush()
	local level = HoroscopeData.Instance:GetXzLevelBySeq(self.cur_zodiac)
	local data = HoroscopeData.Instance:GetSingDataById(self.cur_zodiac,level)
	self.item_data.item_id = data.item_id
	self.item_data.num = 0
	self.item_data.is_bind = 0
	local have_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	if have_num < 1 then
		self.number:SetValue(string.format("%s",ToColorStr(have_num, TEXT_COLOR.RED)))
	else
		self.number:SetValue(have_num)
	end

	self.item_cell:SetData(self.item_data)
end

function HoroscopeAttrView:OnUpGrade()
	local index = ItemData.Instance:GetItemIndex(self.item_data.item_id)
	if index ~= -1 then
		PackageCtrl.Instance:SendUseItem(index)
	else
		TipsCtrl.Instance:ShowItemGetWayView(self.item_data.item_id)
	end
end

function HoroscopeAttrView:FlushInfoView()
	self:FlushRedPt()
	self:FlushLeft()
	self:FlushRight()
end

function HoroscopeAttrView:FlushFly()
	self.is_playing = true
	if self.tweener then
		self.tweener:Pause()
	end

	local min_position = self.horoscope_min_position_list[self.cur_zodiac + 1]
	self.move_icon.rect:SetLocalPosition(min_position.x, min_position.y, 0)
	self.move_icon.rect:SetLocalScale(0, 0, 0)

	local target_pos = Vector3(0, 0, 0)
	local target_scale = Vector3(1, 1, 1)
	self.tweener = self.move_icon.rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener = self.move_icon.rect:DOScale(target_scale, 0.7)
	self.tweener:OnComplete(BindTool.Bind(self.OnMoveEnd, self))
end

function HoroscopeAttrView:OnMoveEnd()
	self.is_playing = false
	self.move_icon:SetActive(false)
	for i=1,12 do
		if i == self.cur_zodiac + 1 then
			self.is_show_list[i]:SetValue(true)
		else
			self.is_show_list[i]:SetValue(false)
		end
	end
end

function HoroscopeAttrView:OnClick(i)
	if self.cur_zodiac == i - 1 or self.is_playing then
		return
	end

	self.cur_zodiac = i - 1
	self.move_icon:SetActive(true)
	data = HoroscopeData.Instance:GetSingDataById(self.cur_zodiac,1)
	local str = "horoscope_max_"..data.item_id
	self.move_max_icon:SetAsset("uis/views/horoscopeview",str)
	self:FlushFly()
	self:FlushRight()
	self:ItemCellFlush()
end

function HoroscopeAttrView:FlushRight()
	local level = HoroscopeData.Instance:GetXzLevelBySeq(self.cur_zodiac)
	local data = HoroscopeData.Instance:GetSingDataById(self.cur_zodiac,level)
	self.angle_level:SetValue(level)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..data.name.."</color>"
	self.name:SetValue(string.format("Lv%s %s",level,name_str))
	self.angle_hp:SetValue(data.maxhp)
	self.angle_atk:SetValue(data.gongji)
	self.angle_def:SetValue(data.fangyu)

	if level < 30 then
		self.is_angle_max_level:SetValue(false)
		local next_data = HoroscopeData.Instance:GetSingDataById(self.cur_zodiac,level + 1,true)
		self.angle_add_hp:SetValue(next_data.maxhp)
		self.angle_add_atk:SetValue(next_data.gongji)
		self.angle_add_def:SetValue(next_data.fangyu)
		self.bt:SetValue(Language.Common.Up)
		self.up_bt.button.interactable = true
		self.up_bt.grayscale.GrayScale = 0
	else
		self.bt:SetValue(Language.Common.YiManJi)
		self.up_bt.button.interactable = false
		self.up_bt.grayscale.GrayScale = 255
		self.is_angle_max_level:SetValue(true)
	end

	local attr = {}
	attr = CommonStruct.Attribute()
	attr.max_hp = data.maxhp
	attr.gong_ji = data.gongji
	attr.fang_yu = data.fangyu
	attr.ming_zhong = data.mingzhong
	attr.shan_bi = data.shanbi
	attr.bao_ji = data.baoji
	attr.jian_ren = data.jianren
	local fight = CommonDataManager.GetCapabilityCalculation(attr)

	self.angle_fight:SetValue(fight)
	self:ItemCellFlush()
end

function HoroscopeAttrView:FlushLeft()
	self.cur_suit_level:SetValue(HoroscopeData.Instance:GetXzSuitLevel())
	for i=1,12 do
		local level = HoroscopeData.Instance:GetXzLevelBySeq(i - 1)
		local data = HoroscopeData.Instance:GetSingDataById(i-1,level)
		self.name_list[i]:SetValue(data.name)
		self.level_list[i]:SetValue(level)
		if i == self.cur_zodiac + 1 then
			self.is_show_list[i]:SetValue(true)
		else
			self.is_show_list[i]:SetValue(false)
		end

		local have_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
		if have_num > 0 and level < 30 then
			self.is_active_list[i]:SetValue(true)
		else
			self.is_active_list[i]:SetValue(false)
		end
	end
end