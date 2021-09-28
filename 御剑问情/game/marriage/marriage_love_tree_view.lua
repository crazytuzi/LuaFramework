MarriageLoveTreeView = MarriageLoveTreeView or BaseClass(BaseRender)

local MaxStarCount = 10

function MarriageLoveTreeView:__init(instance)
	self.old_self_star_level = -1
	self.old_lover_star_level = -1

	self.need_item_id = 0
	self.item_num_enough = true

	self.auto_buy_toggle = self:FindObj("AutoBuyTab").toggle

	self.self_star_list = {}
	local star_list_transform = self:FindObj("SelfStarList").transform
	for i = 1, MaxStarCount do
		self.self_star_list[i] = star_list_transform:FindHard("Star" .. i)
	end

	self.lover_star_list = {}
	star_list_transform = self:FindObj("LoverStarList").transform
	for i = 1, MaxStarCount do
		self.lover_star_list[i] = star_list_transform:FindHard("Star" .. i)
	end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self.item_cell:Reset()

	self.hp = self:FindVariable("Hp")
	self.gong_ji = self:FindVariable("Gongji")
	self.fang_yu = self:FindVariable("Fangyu")

	self.add_fangyu = self:FindVariable("AddFangYu")
	self.add_gongji = self:FindVariable("AddGongJi")
	self.add_hp = self:FindVariable("AddHp")
	self.btn_text = self:FindVariable("BtnText")
	self.can_water = self:FindVariable("CanWater")
	self.can_water:SetValue(false)
	self.free_time = self:FindVariable("FreeTime")
	self.have_lover = self:FindVariable("HaveLover")
	self.is_free = self:FindVariable("IsFree")
	self.is_max = self:FindVariable("IsMax")
	self.item_used_str = self:FindVariable("ItemUsedStr")
	self.other_love_tree_order = self:FindVariable("OtherLoveTreeOrder")
	self.other_rawimage = self:FindVariable("OtherRawImage")
	self.power = self:FindVariable("Power")
	self.progress_value = self:FindVariable("ProgressValue")
	self.pro_text = self:FindVariable("ProText")
	self.self_love_tree_order = self:FindVariable("SelfLoveTreeOrder")
	self.self_rawimage = self:FindVariable("SelfRawImage")
	self.self_star_level = self:FindVariable("SelfStarLevel")		--我的星级
	self.lover_star_level = self:FindVariable("LoverStarLevel")		--伴侣的星级

	self:ListenEvent("ClickWater", BindTool.Bind(self.ClickWater, self))
	self:ListenEvent("OpenHelp", BindTool.Bind(self.OpenHelp, self))
end

function MarriageLoveTreeView:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function MarriageLoveTreeView:OpenHelp()
	TipsCtrl.Instance:ShowHelpTipView(145)
end

function MarriageLoveTreeView:ClickWater()
	local function buy_call_back(item_id, item_num, is_bind, is_use, is_buy_quick)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		self.auto_buy_toggle.isOn = is_buy_quick
	end

	local is_auto_buy = self.auto_buy_toggle.isOn and 1 or 0
	local is_free = self.is_free:GetBoolean()
	if is_auto_buy == 0 and not is_free and not self.item_num_enough then
		TipsCtrl.Instance:ShowCommonBuyView(buy_call_back, self.need_item_id, nil, 1)
		return
	end

	self.is_auto = not self.is_auto

	MarriageCtrl.Instance:SendLoveTreeWaterReq(is_auto_buy)
end

--初始化界面
function MarriageLoveTreeView:InitView()
	self.is_auto = false
	self.init_progess = true
	self.old_self_star_level = -1
	self.old_lover_star_level = -1

	self.need_item_id = 0
	self.item_num_enough = true

	self.auto_buy_toggle.isOn = false

	self:FlushLoveTreeView()
end

function MarriageLoveTreeView:CloseView()
	self.is_auto = false
end

function MarriageLoveTreeView:FlushLoveTreeView()
	--获取服务器数据
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if nil == love_tree_info then
		return
	end

	--判断是否有伴侣
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self.have_lover:SetValue(main_vo.lover_uid > 0)

	self:FlushSelfContent()
	self:FlushLoverContent()
end

--自动升级回调
function MarriageLoveTreeView:UpGradeResult(result)
	if not self.is_auto then
		return
	end

	if result == 1 then
		local is_auto_buy = self.auto_buy_toggle.isOn and 1 or 0
		MarriageCtrl.Instance:SendLoveTreeWaterReq(is_auto_buy)
	else
		self.is_auto = false
		self.btn_text:SetValue(Language.Marriage.AutoWaterDes)
	end
end

--刷新我的相关面板
function MarriageLoveTreeView:FlushSelfContent()
	--获取服务器数据
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if nil == love_tree_info then
		return
	end

	local real_star_level = love_tree_info.love_tree_star_level
	--获取小等级
	local star_level = real_star_level % MaxStarCount

	--判断是否已满级
	local next_love_tree_cfg_info = MarriageData.Instance:GetTreeInfo(real_star_level + 1)
	self.is_max:SetValue(next_love_tree_cfg_info == nil)

	if self.old_self_star_level ~= -1 and self.old_self_star_level ~= real_star_level then
		--星级有改变，播放特效
		local temp_star_index = star_level
		if temp_star_index == 0 and next_love_tree_cfg_info == nil then
			temp_star_index = MaxStarCount
		end

		--0星的时候不播放特效
		if temp_star_index ~= 0 then
			self:PlayUpStarEffect(self.self_star_list[temp_star_index])
		end
	end

	--重新记录旧的星级
	self.old_self_star_level = real_star_level

	--设置当前星级
	local lover_love_tree_cfg_info = MarriageData.Instance:GetTreeInfo(real_star_level + 1)
	if nil == lover_love_tree_cfg_info then
		--已满级直接设置最大星数
		star_level = MaxStarCount
	end
	self.self_star_level:SetValue(star_level)

	--获取阶数
	local big_level, _ = math.modf(real_star_level / MaxStarCount)

	--设置阶数
	local order_str = string.format(Language.Common.Order, big_level)
	self.self_love_tree_order:SetValue(order_str)

	self:FlushSelfAttr()
	self:UpdateUsedItem()
	self:RefreshProgress()
end

--设置我的属性展示
function MarriageLoveTreeView:FlushSelfAttr()
	--获取服务器数据
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if nil == love_tree_info then
		return
	end

	local real_star_level = love_tree_info.love_tree_star_level
	--获取当前等级的相思树信息
	local self_love_tree_cfg_info = MarriageData.Instance:GetTreeInfo(real_star_level)
	if nil == self_love_tree_cfg_info then
		return
	end

	--设置当前属性
	self.hp:SetValue(self_love_tree_cfg_info.maxhp)
	self.gong_ji:SetValue(self_love_tree_cfg_info.gongji)
	self.fang_yu:SetValue(self_love_tree_cfg_info.fangyu)

	local main_vo = GameVoManager.Instance:GetMainRoleVo()

	--设置底图
	local asset, bundle = ResPath.GetRawImage(main_vo.sex == 1 and "Love_Tree_Male.png" or "Love_Tree_FeMale.png")
	self.self_rawimage:SetAsset(asset, bundle)

	if main_vo.lover_uid <= 0 then
		--没结婚
		local capability = CommonDataManager.GetCapabilityCalculation(self_love_tree_cfg_info)
		self.power:SetValue(capability)
		return
	end

	--获取伴侣的属性列表
	local lover_love_tree_cfg_info = MarriageData.Instance:GetTreeInfo(love_tree_info.other_love_tree_star_level)

	--获取额外增加的属性列表
	local add_attr_info = {}
	if nil ~= lover_love_tree_cfg_info then
		--获取其他数据
		local tree_other_cfg = MarriageData.Instance:GetTreeOtherCfg()

		add_attr_info = CommonDataManager.MulAttribute(CommonDataManager.GetAttributteByClass(lover_love_tree_cfg_info), tree_other_cfg.marry_add_per / 100)
	end

	--设置额外增加的属性列表
	local add_hp = math.floor(add_attr_info.max_hp or 0)
	local add_gongji = math.floor(add_attr_info.gong_ji or 0)
	local add_fangyu = math.floor(add_attr_info.fang_yu or 0)
	self.add_hp:SetValue(add_hp)
	self.add_gongji:SetValue(add_gongji)
	self.add_fangyu:SetValue(add_fangyu)

	local add_capability = CommonDataManager.GetCapabilityCalculation(add_attr_info)
	local capability = CommonDataManager.GetCapabilityCalculation(self_love_tree_cfg_info)
	--设置战斗力（需要算上伴侣额外增加的战斗力）
	self.power:SetValue(add_capability + capability)
end

--刷新伴侣的相关面板
function MarriageLoveTreeView:FlushLoverContent()
	--先判断是否有伴侣
	local main_vo = GameVoManager.Instance:GetMainRoleVo()

	--设置底图
	local asset, bundle = ResPath.GetRawImage(main_vo.sex == 1 and "Love_Tree_FeMale.png" or "Love_Tree_Male.png")
	self.other_rawimage:SetAsset(asset, bundle)

	if main_vo.lover_uid <= 0 then
		return
	end

	--获取服务器数据
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if nil == love_tree_info then
		return
	end

	local real_star_level = love_tree_info.other_love_tree_star_level
	--获取小等级
	local star_level = real_star_level % MaxStarCount

	if self.old_lover_star_level ~= -1 and self.old_lover_star_level ~= real_star_level then
		--星级有改变，播放特效
		local temp_star_index = star_level
		local next_love_tree_cfg_info = MarriageData.Instance:GetTreeInfo(real_star_level + 1)
		if temp_star_index == 0 and next_love_tree_cfg_info == nil then
			temp_star_index = MaxStarCount
		end

		--0星的时候不播放特效
		if temp_star_index ~= 0 then
			self:PlayUpStarEffect(self.lover_star_list[temp_star_index])
		end
	end

	--重新记录旧的星级
	self.old_lover_star_level = real_star_level

	--设置当前星级
	local lover_love_tree_cfg_info = MarriageData.Instance:GetTreeInfo(real_star_level + 1)
	if nil == lover_love_tree_cfg_info then
		--已满级直接设置最大星数
		star_level = MaxStarCount
	end
	self.lover_star_level:SetValue(star_level)

	--获取阶数
	local big_level, _ = math.modf(real_star_level / MaxStarCount)

	--设置阶数
	local order_str = string.format(Language.Common.Order, big_level)
	self.other_love_tree_order:SetValue(order_str)
end

--刷新物品使用相关显示
function MarriageLoveTreeView:UpdateUsedItem()
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if nil == love_tree_info then
		return
	end

	local now_star_level = love_tree_info.love_tree_star_level
	local tree_info = MarriageData.Instance:GetTreeInfo(now_star_level)
	if nil == tree_info then
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local item_data = tree_info.female_up_star_item
	--男女所消耗的物品不同
	if main_vo.sex == 1 then
		item_data = tree_info.male_up_star_item
	end

	--设置消耗的物品展示
	self.item_cell:SetData({item_id = item_data.item_id})

	--设置消耗描述
	local tree_other_cfg = MarriageData.Instance:GetTreeOtherCfg()
	local is_free = love_tree_info.free_water_self < tree_other_cfg.self_free_water_time
	if is_free then
		local free_times = tree_other_cfg.self_free_water_time - love_tree_info.free_water_self
		self.is_free:SetValue(true)
		self.free_time:SetValue(free_times)
	else
		self.is_free:SetValue(false)
		local need_num = item_data.num
		local have_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

		if need_num > have_num then
			self.item_num_enough = false
			have_num = ToColorStr(have_num, TEXT_COLOR.RED)
		else
			self.item_num_enough = true
			have_num = ToColorStr(have_num, TEXT_COLOR.BLUE_4)
		end

		local used_str = string.format(Language.Common.CountDes, have_num, need_num)
		self.item_used_str:SetValue(used_str)

		self.need_item_id = item_data.item_id
	end

	if self.is_auto then
		self.btn_text:SetValue(Language.Common.Stop)
	else
		self.btn_text:SetValue(Language.Marriage.AutoWaterDes)
	end
end

--刷新进度条
function MarriageLoveTreeView:RefreshProgress()
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if nil == love_tree_info then
		return
	end
	local now_star_level = love_tree_info.love_tree_star_level
	local next_tree_info = MarriageData.Instance:GetTreeInfo(now_star_level + 1)
	if nil == next_tree_info then
		self.progress_value:SetValue(1)
		self.pro_text:SetValue(Language.Common.YiManJi)
		return
	end

	local now_tree_info = MarriageData.Instance:GetTreeInfo(now_star_level)
	if nil == now_tree_info then
		return
	end

	local need_exp = now_tree_info.need_exp
	local now_exp = love_tree_info.love_tree_cur_exp
	local bili = now_exp / need_exp
	if self.init_progess then
		self.progress_value:InitValue(bili)
		self.init_progess = false
	else
		self.progress_value:SetValue(bili)
	end

	local pro_text = string.format(Language.Common.CountDes, now_exp, need_exp)
	self.pro_text:SetValue(pro_text)
end

--播放升级特效
function MarriageLoveTreeView:PlayUpStarEffect(obj)
	if nil ~= obj then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui/ui_star_prefab",
			"UI_star",
			obj.transform,
			0.3)
	end
end