ForgeUpStarView = ForgeUpStarView or BaseClass(BaseRender)

local Defult_Icon_List = {
	[1] = "icon_toukui",
	[2] = "icon_yifu",
	[3] = "icon_kuzi",
	[4] = "icon_xiezi",
	[5] = "icon_hushou",
	[6] = "icon_xianglian",
	[7] = "icon_wuqi",
	[8] = "icon_jiezhi",
	[9] = "icon_yaodai",
	[10] = "icon_jiezhi"
}

local star_image_list = {
	[0] = "Star001",
	[1] = "Star001",
	[2] = "Star002",
	[3] = "Star003",
	[4] = "Star004",
	[5] = "Star005",
	[6] = "Star001",
	[7] = "Star002",
	[8] = "Star003",
	[9] = "Star004",
	[10] = "Star005",
}

local MaxStartLevel = 500

function ForgeUpStarView:__init()
	--获取组件
	self.center_display = self:FindObj("CenterDisplay")
	self.model_effect_bg = self:FindObj("ModelEffectBg")

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self:FindObj("CurEquipCell"))

	---[[获取变量
	--展示属性
	self.show_hp = self:FindVariable("ShowHp")
	self.show_gongji = self:FindVariable("ShowGongji")
	self.show_fangyu = self:FindVariable("ShowFangyu")

	--属性值(现在属性,增加的属性)
	self.now_hp = self:FindVariable("NowHp")
	self.add_hp = self:FindVariable("AddHp")
	self.now_gongji = self:FindVariable("NowGongji")
	self.add_gongji = self:FindVariable("AddGongji")
	self.now_fangyu = self:FindVariable("NowFangyu")
	self.add_fangyu = self:FindVariable("AddFangyu")

	--星魂等级,战力
	self.star_level = self:FindVariable("StarLevel")
	self.power = self:FindVariable("Power")
	self.total_power = self:FindVariable("TotalPower")

	--展示加成属性
	self.show_hp_addattr = self:FindVariable("ShowHpAddAttr")
	self.show_gongji_addattr = self:FindVariable("ShowGongjiAddAttr")
	self.show_fangyu_addattr = self:FindVariable("ShowFangyuAddAttr")
	self.is_show_text = self:FindVariable("IsShowText")

	--进度条文本
	self.now_pro = self:FindVariable("NowPro")
	self.add_pro = self:FindVariable("AddPro")
	self.need_pro = self:FindVariable("NeedPro")

	--进度条值
	self.now_proess = self:FindVariable("NowProess")

	--声望
	self.sheng_wang = self:FindVariable("ShengWang")

	--按钮
	self.btn_starup_text = self:FindVariable("BtnStarUpText")
	self.btn_onekey_text = self:FindVariable("BtnOneKeyText")
	self.can_starup = self:FindVariable("CanStarUp")
	self.all_max = self:FindVariable("AllMax")

	--是否已满级
	self.is_max_level = self:FindVariable("IsMaxLevel")
	--]]

	--模型背景特效
	self.effect_glow = self:FindVariable("effect_glow")

	self:ListenEvent("OpenAtrrTips", BindTool.Bind(self.OpenAtrrTips, self))
	self:ListenEvent("ClickStarUp", BindTool.Bind(self.ClickStarUp, self))
	self:ListenEvent("OnClickOneKey", BindTool.Bind(self.OnClickOneKey, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("OnTextEvent", BindTool.Bind(self.OnTextEvent, self))


	self.cur_level = 0

	--装备位置列表
	self.equip_position_list = {}
	for i = 1, 10 do
		local equip_obj = self:FindObj("Item" .. i)
		local position = equip_obj.rect.localPosition
		table.insert(self.equip_position_list, position)
	end

	self.equip_list = {}
	self.up_star_list = {}
	for i = 1, 10 do
		equip_item = EquipUpStarCell.New(self:FindObj("Item"..i))
		equip_item:ListenClick(BindTool.Bind(self.ClickItem, self, i))
		table.insert(self.equip_list, equip_item)
		local up_arrow = self:FindVariable("ShowUp" .. i)
		table.insert(self.up_star_list, up_arrow)

	end

	--星星列表
	self.star_list = {}
	self.gray_list = {}
	for i = 1, 10 do
		local star_image = self:FindVariable("StarImg" .. i)
		table.insert(self.star_list, star_image)
		local is_gray = self:FindVariable("Gray" .. i)
		table.insert(self.gray_list, is_gray)
	end

	self.init_progess = true
	--引导用按钮
	self.up_star_btn = self:FindObj("UpStarBtn")
	self.old_star_t = {}
	self.now_proess:SetValue(0)
	self:FristFlushView()
end

function ForgeUpStarView:__delete()
	for k, v in ipairs(self.equip_list) do
		v:DeleteMe()
	end
	self.equip_list = {}

	if self.EquipModel then
		self.EquipModel:DeleteMe()
		self.EquipModel = nil
	end

	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end


	self.is_show_text = nil
end

--开始监听改变
function ForgeUpStarView:StartListenPrestige()
	--开始监听魔晶变化
	self.score_change_callback = BindTool.Bind1(self.MoJingChange, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.score_change_callback)

	--开始监听装备信息变化
	if self.equip_listen_func == nil then
		self.equip_listen_func = BindTool.Bind1(self.OnEquipInfoChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_listen_func)
	end
end

--结束监听数据变化
function ForgeUpStarView:StopListen()
	--结束监听装备信息改变
	if self.equip_listen_func then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_listen_func)
		self.equip_listen_func = nil
	end

	--结束监听魔晶改变
	if self.score_change_callback then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.score_change_callback)
		self.score_change_callback = nil
	end
	self:StopAutoQuest()
end

function ForgeUpStarView:OnEquipInfoChange(change_item_id)
	if change_item_id then
		return
	end
	local index = self.select_index
	if index <= 0 then
		return
	end

	self:CheckShowUpArrow()

	--装备数量不一样时刷新装备界面
	local equip_count = EquipData.Instance:GetDataCount()
	if equip_count ~= self.equip_count then
		self:FlushLeftEquip()
		self.equip_count = equip_count
		return
	else
		self:FlushLeftEquip()
	end

	if self.is_auto_upstar then
		self:FlushLeftEquip()
	end

	local equip_index = index - 1
	local equipdata = EquipData.Instance:GetGridData(equip_index)
	local star_level = equipdata.star_level
	if star_level == self.now_star_level then
		--装备星级一样时只刷新进度条
		self:FlushProgress()
	else
		self:FlushOneEquip()
		self:FlushRightList()
		self:FlushTotlePower()
	end
end

function ForgeUpStarView:MoJingChange()
	local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	local value = tonumber(mojing)
	self:ChangeShengWang(value)
	self:CheckShowUpArrow()
end

function ForgeUpStarView:CloseUpStarView()
	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end

	if self.tweener2 then
		self.tweener2:Pause()
		self.tweener2 = nil
	end
	self:StopListen()
	self.old_star_t = {}
end

--打开属性加成
function ForgeUpStarView:OpenAtrrTips()
	local star_level, now_cfg, next_cfg = ForgeData.Instance:GetTotleStarInfo()
	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeStarSuitAtt, star_level, now_cfg, next_cfg)
end

--开始升星
function ForgeUpStarView:ClickStarUp()
	if not self:PopRect() then
		if self.select_index > 0 then
			ForgeCtrl.Instance:SendUpStarReq(self.select_index - 1)
		end
	end
end

--一键升星
function ForgeUpStarView:OnClickOneKey()
	if self.auto_index == -2 then
		TipsCtrl.Instance:ShowItemGetWayView(ResPath.CurrencyToIconId["shengwang"])
		return
	elseif self.auto_index == -1 then
		return
	end
	self.is_auto_upstar = not self.is_auto_upstar
	self:FlushOneKeyUpStar()

	if self.is_auto_upstar then
		ForgeCtrl.Instance:SendUpStarReq(self.auto_index)
		if self.auto_upstar_quest == nil then
			self.auto_upstar_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OneKeyQuest, self), 0.3)
		end
	else
		self:StopAutoQuest()
	end
end

function ForgeUpStarView:StopAutoQuest()
	self.is_auto_upstar = false
	self:FlushOneKeyUpStar()
	if self.auto_upstar_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.auto_upstar_quest)
		self.auto_upstar_quest = nil
	end
end

function ForgeUpStarView:OneKeyQuest()
	self.auto_index = ForgeData.Instance:GetMinStarIndex()
	if self.auto_index ~= -1 and  self.auto_index ~= -2 then
		ForgeCtrl.Instance:SendUpStarReq(self.auto_index)
	else
		self:StopAutoQuest()
	end
end

--帮助
function ForgeUpStarView:ClickHelp()
	local tips_id = 13    -- 升星tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeUpStarView:ClickItem(index)
	self.init_progess = true
	local data = self.equip_list[index]:GetData()
	if not data or not data.param or not next(data.param) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Equip.GetWayTip)
		return
	end

	-- if nil ~= self.equip_list[self.select_index] then
	-- 	self.equip_list[self.select_index]:SetHightLight(false)
	-- end

	-- self.equip_list[index]:SetHightLight(true)
	if index == self.select_index then
		return
	end
	self.select_index = index
	self:FlushFlyAni(index)
end

function ForgeUpStarView:InitProgess()
	self.init_progess = true
end

function ForgeUpStarView:SetSelectIndex(index)
	self.select_index = index
end

function ForgeUpStarView:GetSelectIndex()
	return self.select_index
end

--刷新进度条
function ForgeUpStarView:FlushProgress()
	local index = self.select_index
	if index <= 0 then
		return
	end
	local equip_index = index - 1
	local equipdata = EquipData.Instance:GetGridData(equip_index)
	local param = equipdata.param or {}
	local star_level = param.star_level
	local next_star_attr = ForgeData.Instance:GetStarAttr(equip_index, star_level + 1)
	if nil ~= next_star_attr then
		local now_exp = param.star_exp or 0
		self.now_pro:SetValue(now_exp)
		local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
		local max_pro = next_star_attr.need_shengwang
		local need_exp = max_pro - now_exp
		self.need_pro:SetValue(max_pro)
		if mojing >= need_exp then
			self.add_pro:SetValue(need_exp)
		else
			self.add_pro:SetValue(mojing)
		end

		local can_add_proress = 0
		if mojing <= 0 then
			can_add_proress = 0
		elseif mojing >= need_exp then
			can_add_proress = 1
		else
			can_add_proress = (mojing + now_exp)/max_pro
		end
		if self.init_progess then
			self.now_proess:InitValue(now_exp/max_pro)
			self.init_progess = false
		else
			self.now_proess:SetValue(now_exp/max_pro)
		end
	elseif star_level >= MaxStartLevel then
		self.now_proess:SetValue(1)
	end
	self.is_max_level:SetValue(star_level >= MaxStartLevel)
end

--刷新声望
function ForgeUpStarView:ChangeShengWang(value)
	if self.sheng_wang then
		self.sheng_wang:SetValue(value)
	end
end

--单独刷新一件装备
function ForgeUpStarView:FlushOneEquip()
	local equiplist = EquipData.Instance:GetDataList()
	local main_prof = GameVoManager.Instance.main_role_vo.prof
	local index = self.select_index
	local equip_index = index - 1
	local equip_data = equiplist[equip_index]

	local equip_cell = self.equip_list[index]
	if equip_cell then
		if equip_data then
			equip_cell:SetData(equip_data, true)
			equip_cell:SetInteractable(true)
			equip_cell:ShowStarLevel(true)
			local param = equip_data.param or {}
			local star_level = param.star_level or 0
			self.old_star_t[index] = star_level
			equip_cell:SetStarLevel(star_level)
			-- equip_cell:ShowQuality(true)
			-- equip_cell:SetIconGrayScale(false)
			equip_cell:SetHightLight(true)
			-- equip_cell:ShowStrengthLable(false)
		else
			-- local data = {}
			-- if type(Defult_Icon_List[index]) == "table" then
			-- 	data.item_id = Defult_Icon_List[index][main_prof]
			-- else
			-- 	data.item_id = Defult_Icon_List[index]
			-- end
			-- equip_cell:SetData(data, true)
			-- equip_cell:ShowQuality(false)
			-- equip_cell:SetIconGrayScale(true)
			-- equip_cell:SetHightLight(false)
			-- equip_cell:ShowHighLight(false)
			-- equip_cell:SetInteractable(false)

			local data = {}
			equip_cell:SetData(data)
			equip_cell:SetInteractable(false)
			equip_cell:ShowStarLevel(false)
			equip_cell:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[index]))
			equip_cell:SetHightLight(false)
			self.old_star_t[index] = 0
		end
	end

	self:CheckShowUpArrow()
end

--刷新装备面板
function ForgeUpStarView:FlushLeftEquip()
	local equiplist = EquipData.Instance:GetDataList()
	local main_prof = GameVoManager.Instance.main_role_vo.prof
	local is_first = true
	for k, v in ipairs(self.equip_list) do
		local equip_data = equiplist[k - 1]
		local star_level = 0
		if equip_data and equip_data.item_id then
			if is_first then
				self.first_index = k			--记录第一个有装备的格子
				is_first = false
			end
			v:SetData(equip_data, true)
			v:SetInteractable(true)
			v:ShowStarLevel(true)
			local param = equip_data.param or {}
			star_level = param.star_level or 0
			v:SetStarLevel(star_level)
			-- v:ShowQuality(true)
			-- v:SetIconGrayScale(false)
			-- v:SetHightLight(true)
			-- v:ShowStrengthLable(false)
		else
			local data = {}
			-- if type(Defult_Icon_List[k]) == "table" then
				-- data.item_id = Defult_Icon_List[k][main_prof]
			-- else
				-- data.item_id = Defult_Icon_List[k]
			-- end
			v:SetData(data)
			v:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[k]))
			-- v:ShowQuality(false)
			-- v:SetIconGrayScale(true)
			v:SetHightLight(false)
			-- v:ShowHighLight(false)
			v:SetInteractable(false)
		end
		-- if self.old_star_t[k] and self.old_star_t[k] ~= star_level then
		-- 	EffectManager.Instance:PlayAtTransformCenter(
		-- 	"effects/prefabs",
		-- 	"UI_Jinengshengji",
		-- 	v.root_node.transform,
		-- 	1.0)
		-- end
		self.old_star_t[k] = star_level
	end

	self:CheckShowUpArrow()
end

function ForgeUpStarView:CheckShowUpArrow()
	local data_list = EquipData.Instance:GetDataList()

	for k, v in ipairs(self.equip_list) do
		local equip_data = data_list[k - 1]
		local star = self.up_star_list[k]

		if nil ~= equip_data and nil ~= equip_data.index then
			local is_show_up_arrow = ForgeData.Instance:GetCanUpStarByLevelAndIndex(equip_data.index, equip_data.param.star_level)
			star:SetValue(is_show_up_arrow)

		else
			star:SetValue(false)
		end
	end
	self.auto_index = ForgeData.Instance:GetMinStarIndex()
end

--初始化右边面板
function ForgeUpStarView:InitRightList()
	self.show_hp:SetValue(false)
	self.show_gongji:SetValue(false)
	self.show_fangyu:SetValue(false)

	self.show_hp_addattr:SetValue(false)
	self.show_gongji_addattr:SetValue(false)
	self.show_fangyu_addattr:SetValue(false)

	self.now_hp:SetValue(0)
	self.now_gongji:SetValue(0)
	self.now_fangyu:SetValue(0)

	self.star_level:SetValue(0)
	self.power:SetValue(0)

	self.now_pro:SetValue(0)
	self.add_pro:SetValue(0)
	self.need_pro:SetValue(0)

	-- self.can_proess:SetValue(0)
	self.now_proess:SetValue(0)

	self.can_starup:SetValue(false)
	self.cur_level = 0
end

--刷新星星
function ForgeUpStarView:FlushStarList(star_level)
	local team_big_star, team_small_star = math.modf(star_level/10)
	team_big_star = team_big_star%10

	if star_level >= 100 and team_big_star == 0 then
		team_big_star = 10
	end
	team_small_star = string.format("%.2f", team_small_star * 10)
	team_small_star = math.floor(team_small_star)
	local image_list = {}
	for i = 1, 10 do
		local res_id = star_image_list[team_big_star]
		if res_id then
			local bubble, asset = ResPath.GetStarImages(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	end

	local small_res_id = team_big_star + 1
	if small_res_id > 10 then
		small_res_id = small_res_id - 10
	end
	for j = 1, team_small_star do
		local res_id = star_image_list[small_res_id]
		if res_id then
			local bubble, asset = ResPath.GetStarImages(res_id)
			local res_path = {bubble, asset}
			image_list[j] = res_path
		end
	end
	for k, v in ipairs(self.star_list) do
		local res_path = image_list[k]
		if res_path then
			v:SetAsset(res_path[1], res_path[2])
		else
			local bubble, asset = ResPath.GetStarImages("star001")
			v:SetAsset(bubble, asset)
		end
	end
	for k, v in ipairs(self.gray_list) do
		v:SetValue(false)
	end

	if team_big_star <= 0 then
		for i = team_small_star + 1, 10 do
			self.gray_list[i]:SetValue(true)
		end
	end
end

--刷新总战力界面
function ForgeUpStarView:FlushTotlePower()
	local capability = ForgeData.Instance:GetUpStarPower()
	self.total_power:SetValue(capability)
end

--刷新右边面板
function ForgeUpStarView:FlushRightList()
	local index = self.select_index
	if index <= 0 then
		index = 0
	end
	self:FlushEquipModel()
	local equip_index = index - 1
	local equip_data = EquipData.Instance:GetGridData(equip_index)
	if equip_data then
		local param = equip_data.param or {}
		local star_level = param.star_level
		self.now_star_level = star_level 			--记录星级
		local attr_info = ForgeData.Instance:GetStarAttr(equip_index, star_level)

		if nil ~= attr_info then
			--显示战斗力
			local capability = CommonDataManager.GetCapability(attr_info)
			self.power:SetValue(capability)

			local now_hp = attr_info.maxhp
			local now_gongji = attr_info.gongji
			local now_fangyu = attr_info.fangyu

			self.now_hp:SetValue(now_hp)
			self.now_gongji:SetValue(now_gongji)
			self.now_fangyu:SetValue(now_fangyu)

			if star_level >= MaxStartLevel then
				self.show_hp:SetValue(now_hp > 0)
				self.show_gongji:SetValue(now_gongji > 0)
				self.show_fangyu:SetValue(now_fangyu > 0)
				self.show_hp_addattr:SetValue(false)
				self.show_gongji_addattr:SetValue(false)
				self.show_fangyu_addattr:SetValue(false)
			else
				local next_attr_info = ForgeData.Instance:GetStarAttr(equip_index, star_level + 1)

				if nil ~= next_attr_info then
					local add_hp = next_attr_info.maxhp - now_hp
					local add_gongji = next_attr_info.gongji - now_gongji
					local add_fangyu = next_attr_info.fangyu - now_fangyu

					self.show_hp_addattr:SetValue(add_hp > 0)
					self.show_gongji_addattr:SetValue(add_gongji > 0)
					self.show_fangyu_addattr:SetValue(add_fangyu > 0)

					self.add_hp:SetValue(add_hp)
					self.add_gongji:SetValue(add_gongji)
					self.add_fangyu:SetValue(add_fangyu)

					self.show_hp:SetValue(add_hp > 0)
					self.show_gongji:SetValue(add_gongji > 0)
					self.show_fangyu:SetValue(add_fangyu > 0)
				else
					self.show_hp:SetValue(false)
					self.show_gongji:SetValue(false)
					self.show_fangyu:SetValue(false)
				end
			end

			--设置星级
			self.star_level:SetValue(star_level)

			self.btn_starup_text:SetValue(Language.Forge.UpStar)
			self.cur_level = star_level
			if star_level >= MaxStartLevel then
				self.btn_starup_text:SetValue(Language.Forge.FullLevel)
				self.can_starup:SetValue(false)
			else
				self.can_starup:SetValue(not self.is_auto_upstar)
			end

			self:FlushStarList(star_level)
			self:FlushProgress()
		else
			self:InitRightList()
		end
	end
end

-- 声望不足时弹框处理
function ForgeUpStarView:PopRect()
	local index = self.select_index
	if index <= 0 then
		return false
	end
	local equip_index = index - 1
	local equipdata = EquipData.Instance:GetGridData(equip_index)
	local param = equipdata.param or {}
	local star_level = param.star_level
	local next_star_attr = ForgeData.Instance:GetStarAttr(equip_index, star_level + 1)
	if nil ~= next_star_attr then
		local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
		if mojing <= 0 then
			TipsCtrl.Instance:ShowItemGetWayView(ResPath.CurrencyToIconId["shengwang"])
			return true
		end
	end

	return false
end

function ForgeUpStarView:ClearEquipBgEffect()
end

function ForgeUpStarView:SetEquipModelBgEffect(color)
end

--刷新装备模型
function ForgeUpStarView:FlushEquipModel()
	if self.equip_cell then
		local equipdata = EquipData.Instance:GetGridData(self.select_index - 1)
		local param = equipdata.param or {}
		local star_level = param.star_level or 0
		self.equip_cell:SetData(equipdata)
		self.equip_cell:SetStarLevel(star_level)
		self.equip_cell:ShowStarLevel(true)
		self.equip_cell:ShowStrengthLable(false)
	end
end

function ForgeUpStarView:InitEquipModel()
end

function ForgeUpStarView:FlushFlyAni(index)
	local equiplist = EquipData.Instance:GetDataList()
	if not next(equiplist) then
		return
	end
	self:FlushEquipModel()
	self.can_starup:SetValue(true)
	self:FlushRightList()
end

function ForgeUpStarView:OnMoveEnd()
end

function ForgeUpStarView:FristFlushView()
	self.equip_count = EquipData.Instance:GetDataCount()
	self.select_index = 0
	self.first_index = 0
	self.auto_index = ForgeData.Instance:GetMinStarIndex()
	self.is_auto_upstar = false
	self:FlushOneKeyUpStar()
	self:FlushLeftEquip()
	self:InitEquipModel()
	self:InitRightList()
	self:FlushTotlePower()

	if self.first_index > 0 then
		self.equip_list[self.first_index]:SetHightLight(true)
		self.select_index = self.first_index
		self:FlushFlyAni(self.first_index)
	end

	local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	self:ChangeShengWang(mojing)
	self:StartListenPrestige()

	self.is_show_text:SetValue(TimeCtrl.Instance:GetCurOpenServerDay() <= GameEnum.NEW_SERVER_DAYS)
end

function ForgeUpStarView:FlushOneKeyUpStar()
	self.can_starup:SetValue(not self.is_auto_upstar and self.cur_level < MaxStartLevel)
	self.all_max:SetValue(self.auto_index and self.auto_index == -1)
	self.btn_onekey_text:SetValue(self.is_auto_upstar and Language.Forge.StopStar or Language.Forge.OneKeyUpStar)
end

function ForgeUpStarView:OnTextEvent()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_mojing)
end


EquipUpStarCell = EquipUpStarCell or BaseClass(BaseRender)

function EquipUpStarCell:__init(instance)
	self.quality = self:FindVariable("Quality")
	self.icon = self:FindVariable("Icon")
	self.start_level = self:FindVariable("Star")
	self.show_star_level = self:FindVariable("ShowStar")
	self.effect = self:FindObj("effect")
end

function EquipUpStarCell:__delete()

end

function EquipUpStarCell:Reset()
	self.icon:ResetAsset()
	self.quality:ResetAsset()
	self.show_star_level:SetValue(false)
end

function EquipUpStarCell:SetData(data)
	self.data = data
	if nil == data
		or nil == next(data) then
		self:Reset()
		return
	end

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		self:Reset()
		return
	end

	self:SetQuality(item_cfg)

	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self:SetIcon(bundle, asset)
end

function EquipUpStarCell:SetIcon(bundle, asset)
	if nil ==  bundle or nil == asset then return end
	self.icon:SetAsset(bundle, asset)
end

function EquipUpStarCell:SetQuality(item_cfg)
	local bundle1, asset1 = ResPath.GetEquipStarQualityIcon(item_cfg.color)
	self.quality:SetAsset(bundle1, asset1)
end

function EquipUpStarCell:SetStarLevel(value)
	if self.start_level then
		if self.old_level == nil then
			self.old_level = value
		elseif value > self.old_level then
			self.old_level = value
			EffectManager.Instance:PlayAtTransform("effects2/prefab/ui/ui_jinengshengji_1_prefab", "UI_Jinengshengji_1", self.effect.transform, 2, nil, nil, Vector3(0.6,0.6,0.6))
			if value >= MaxStartLevel then					
				ForgeCtrl:FlushUpstarTabRemind()	--刷新红点
			end
		end
		self.start_level:SetValue(value)
	end
end

function EquipUpStarCell:GetData()
	return self.data or {}
end

function EquipUpStarCell:SetHightLight(value)
	if nil == self.root_node.toggle then return end
	self.root_node.toggle.isOn = value
end

function EquipUpStarCell:ShowStarLevel(enable)
	if self.show_star_level then
		self.show_star_level:SetValue(enable)
	end
end

function EquipUpStarCell:SetInteractable(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.interactable = enable
	end
end

function EquipUpStarCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function EquipUpStarCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end