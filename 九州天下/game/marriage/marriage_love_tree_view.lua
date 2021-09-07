MarriageLoveTreeView = MarriageLoveTreeView or BaseClass(BaseRender)

local EFFECT_CD = 1
local Male_bg = "MoneyTreeBg_01"
local FeMale_bg = "MoneyTreeBg_02"

function MarriageLoveTreeView:__init(instance)
	self.effect_cd = 0
	self.now_star_level = -1

	self.effect_obj = self:FindObj("EffectObj")
	self.start_obj = self:FindObj("StartObj")

	self.hp = self:FindVariable("Hp")
	self.gong_ji = self:FindVariable("Gongji")
	self.fang_yu = self:FindVariable("Fangyu")
	self.ming_zhong = self:FindVariable("Mingzhong")
	self.shan_bi = self:FindVariable("Shanbi")
	self.bao_ji = self:FindVariable("Baoji")
	self.jian_ren = self:FindVariable("Jianren")

	self.add_hp = self:FindVariable("AddHp")
	self.add_gongji = self:FindVariable("AddGongji")
	self.add_fangyu = self:FindVariable("AddFangyu")

	self.show_star_level = self:FindVariable("ShowStarLevel")		--星级
	self.order = self:FindVariable("Order")							--阶数
	self.progress = self:FindVariable("Progress")					--进度
	self.item_name = self:FindVariable("ItemName")
	self.used_item_num = self:FindVariable("UsedItemNum")
	self.have_item_num = self:FindVariable("HaveItemNum")
	self.now_pro = self:FindVariable("nowpro")
	self.max_pro = self:FindVariable("maxpro")
	self.is_free = self:FindVariable("IsFree")
	self.free_time = self:FindVariable("FreeTime")
	self.is_max = self:FindVariable("IsMax")
	self.enter_btn_text = self:FindVariable("EnterBtnText")
	self.can_help = self:FindVariable("CanHelp")				--是否可以帮助伴侣浇水
	self.can_water = self:FindVariable("CanWater")				--是否显示浇水红点
	self.power = self:FindVariable("Power")
	self.show_help_redpoint = self:FindVariable("ShowHelpRedPoint")
	self.show_water_redpoint = self:FindVariable("WaterNumRedPoint")

	self.raw_image_bg = self:FindVariable("RawImageBg")

	self:ListenEvent("EnterLoverGarden", BindTool.Bind(self.EnterLoverGarden, self))
	self:ListenEvent("ClickWater", BindTool.Bind(self.ClickWater, self))
	self:ListenEvent("OpenHelp", BindTool.Bind(self.OpenHelp, self))
end

function MarriageLoveTreeView:__delete()
	self.effect_cd = 0
	self.now_star_level = -1
end

function MarriageLoveTreeView:OpenHelp()
	TipsCtrl.Instance:ShowHelpTipView(145)
end

function MarriageLoveTreeView:EnterLoverGarden()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	if main_role.lover_uid <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotLoverDes)
		return
	end
	self.now_star_level = -1
	local tree_state = MarriageData.Instance:GetTreeState()
	tree_state = tree_state == 1 and 0 or 1
	self.init_progess = true
	MarriageCtrl.Instance:SendLoveTreeInfoReq(tree_state)
end

function MarriageLoveTreeView:ClickWater()
	-- if not self.is_free_water then
	-- 	--没有免费浇水次数
	-- 	local item_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	-- 	if item_num <= 0 then
	-- 		TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
	-- 		return
	-- 	end
	-- end
	local tree_state = MarriageData.Instance:GetTreeState()
	local water_by = 0
	if tree_state == 0 then
		water_by = 1
	end
	MarriageCtrl.Instance:SendLoveTreeWaterReq(0, water_by)
end

function MarriageLoveTreeView:FlushProgressEffect()
	TipsCtrl.Instance:ShowFlyEffectManager(ViewName.Marriage, "effects2/prefab/ui/ui_guangdian1_prefab", "UI_guangdian1", self.start_obj, self.effect_obj, nil, 1)
end

function MarriageLoveTreeView:FlushLoveTreeView()
	--获取服务端返回的相思树信息
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	local now_star_level = love_tree_info.love_tree_star_level
	if not next(love_tree_info) then
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local res_str = ""
	local show_red_point = false

	local tree_other_cfg = MarriageData.Instance:GetTreeCfg()
	--获取当前等级的相思树信息
	local love_tree_cfg = MarriageData.Instance:GetTreeInfo(love_tree_info.other_love_tree_star_level)
	local other_level = love_tree_info.other_love_tree_star_level

	if love_tree_info.is_self == 1 then
		self.enter_btn_text:SetValue(Language.Marriage.ToOtherLoverTreeDes)
		local item_data = love_tree_cfg.male_up_star_item
		if main_vo.sex == 1 then
			res_str = Male_bg
			item_data = love_tree_cfg.female_up_star_item
		else
			res_str = FeMale_bg
		end

		local assist_free_water_time = tree_other_cfg.assist_free_water_time
		local other_item_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
		if main_vo.lover_uid <= 0 or other_level == 100 then
			show_red_point = false
		elseif love_tree_info.free_water_other < assist_free_water_time or other_item_num >= item_data.num then
			show_red_point = true
		end
	else
		self.enter_btn_text:SetValue(Language.Marriage.ReturnOtherLoverTreeDes)
		local item_data = love_tree_cfg.female_up_star_item
		if main_vo.sex == 1 then
			item_data = love_tree_cfg.male_up_star_item
			res_str = FeMale_bg
		else
			res_str = Male_bg
		end

		local self_free_water_time = tree_other_cfg.self_free_water_time
		local self_item_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
		if love_tree_info.free_water_self < self_free_water_time or self_item_num >= item_data.num  then
			show_red_point = true
		end
		
		if other_level == 100 then
			show_red_point = false
		end
	end
	self.show_help_redpoint:SetValue(show_red_point)
	local raw_bunble, raw_asset = ResPath.GetRawImage(res_str, true)
	--self.raw_image_bg:SetAsset(raw_bunble, raw_asset)
	MarriageCtrl.Instance:SetTreeBg(raw_bunble, raw_asset)

	--拆分大等级为阶数和星级
	local big_level, star_level = math.modf(now_star_level/10)
	star_level = string.format("%.2f", star_level * 10)
	star_level = math.floor(star_level)

	-- if self.now_star_level > 0 and self.now_star_level < now_star_level then
	-- 	self:PlayUpStarEffect()
	-- end
	self.now_star_level = now_star_level					--记录现在的等级
	self.show_star_level:SetValue(star_level)
	local order_str = CommonDataManager.GetDaXie(big_level) .. "阶"
	self.order:SetValue(order_str)
	local is_max_level = #Language.Common.NumToChs - 1 == big_level

	--根据等级获取相思树现有属性
	local tree_info = MarriageData.Instance:GetTreeInfo(now_star_level)
	local halo_tree_info = MarriageData.Instance:GetTreeInfo(love_tree_info.other_love_tree_star_level)
	self.hp:SetValue(tree_info.maxhp or 0)
	self.gong_ji:SetValue(tree_info.gongji or 0)
	self.fang_yu:SetValue(tree_info.fangyu or 0)
	self.ming_zhong:SetValue(tree_info.shanbi or 0)
	self.shan_bi:SetValue(tree_info.mingzhong or 0)
	self.bao_ji:SetValue(tree_info.baoji or 0)
	self.jian_ren:SetValue(tree_info.jianren or 0)

	self.add_hp:SetValue(string.format(Language.Marriage.LoverTreeAttr, halo_tree_info.maxhp * 0.3))
	self.add_gongji:SetValue(string.format(Language.Marriage.LoverTreeAttr, halo_tree_info.gongji * 0.3))
	self.add_fangyu:SetValue(string.format(Language.Marriage.LoverTreeAttr, halo_tree_info.fangyu * 0.3))
	local capability = CommonDataManager.GetCapabilityCalculation(tree_info)
	self.power:SetValue(capability)

	self:UpdateUsedItem(is_max_level)
	self:RefreshProgress()
end

--刷新物品使用
function MarriageLoveTreeView:UpdateUsedItem(is_max_level)
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if not next(love_tree_info) then
		return
	end
	local now_star_level = love_tree_info.love_tree_star_level
	local tree_info = MarriageData.Instance:GetTreeInfo(now_star_level)

	local tree_cfg = MarriageData.Instance:GetTreeCfg()

	--获取相思树的主人（自己1, 别人0）
	local tree_state = MarriageData.Instance:GetTreeState()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local item_data = {}
	local free_times = 0
	local is_free = false
	if tree_state == 1 then
		is_free = love_tree_info.free_water_self < tree_cfg.self_free_water_time
		free_times = tree_cfg.self_free_water_time - love_tree_info.free_water_self
		--男女所消耗的物品不同
		if main_vo.sex == 1 then
			item_data = tree_info.male_up_star_item
		else
			item_data = tree_info.female_up_star_item
		end
	else
		is_free = love_tree_info.free_water_other < tree_cfg.assist_free_water_time
		free_times = tree_cfg.assist_free_water_time - love_tree_info.free_water_other
		--男女所消耗的物品不同
		if main_vo.sex == 1 then
			item_data = tree_info.female_up_star_item
		else
			item_data = tree_info.male_up_star_item
		end
	end

	self.is_free_water = is_free
	self.item_id = item_data.item_id
	if is_free then
		self.is_free:SetValue(true)
		self.free_time:SetValue(free_times)
		self.show_water_redpoint:SetValue(tonumber(free_times) > 0 and now_star_level < 100)
	else
		self.is_free:SetValue(false)
		local item_name = ItemData.Instance:GetItemName(item_data.item_id)
		self.item_name:SetValue(item_name)
		local need_num = item_data.num
		self.used_item_num:SetValue(need_num)

		local have_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
		self.show_water_redpoint:SetValue((tonumber(have_num) - need_num) >= 0 and now_star_level < 100)
		if need_num > have_num then
			have_num = ToColorStr(have_num, TEXT_COLOR.RED)
		else
			have_num = ToColorStr(have_num, TEXT_COLOR.GREEN)
		end
		self.have_item_num:SetValue(have_num)
	end
end

--刷新进度条
function MarriageLoveTreeView:RefreshProgress()
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if not next(love_tree_info) then
		return
	end
	local now_star_level = love_tree_info.love_tree_star_level
	local now_tree_info = MarriageData.Instance:GetTreeInfo(now_star_level)
	local next_tree_info = MarriageData.Instance:GetTreeInfo(now_star_level + 1)
	self.is_max:SetValue(not next(next_tree_info))

	local need_exp = now_tree_info.need_exp
	self.max_pro:SetValue(need_exp)

	local now_exp = next(next_tree_info) and love_tree_info.love_tree_cur_exp or need_exp
	self.now_pro:SetValue(now_exp)

	if not next(next_tree_info) then
		self.progress:InitValue(1)
		return
	end

	if self.init_progess then
		self.progress:InitValue(now_exp/need_exp)
		self.init_progess = false
	else
		self.progress:SetValue(now_exp/need_exp)
		self:FlushProgressEffect()
	end
end

--播放升级特效
function MarriageLoveTreeView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui/ui_shengjichenggong_prefab",
			"UI_shengjichenggong",
			self.effect_obj.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end