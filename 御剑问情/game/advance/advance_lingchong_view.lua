LingChongContentView = LingChongContentView or BaseClass(BaseRender)

function LingChongContentView:__init()
	self.old_select_grade = 0
	self.select_grade = 0					--服务器阶数
	self.old_grade = -1

	self:ListenEvent("ClickUse",
		BindTool.Bind(self.ClickUse, self))
	self:ListenEvent("ClickLeft",
		BindTool.Bind(self.ClickLeft, self))
	self:ListenEvent("ClickRight",
		BindTool.Bind(self.ClickRight, self))
	self:ListenEvent("ClickUpgrade",
		BindTool.Bind(self.ClickUpgrade, self))
	self:ListenEvent("ClickHelp",
		BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickZiZhi",
		BindTool.Bind(self.ClickZiZhi, self))
	self:ListenEvent("ClickHuanHua",
		BindTool.Bind(self.ClickHuanHua, self))
	self:ListenEvent("ClickSkill",
		BindTool.Bind(self.ClickSkill, self))
	self:ListenEvent("OnClickAllAttrBtn",
		BindTool.Bind(self.OnClickAllAttrBtn, self))

	self.effect_root = self:FindObj("EffectRoot")

	self.toggle_check = self:FindObj("ToggleCheck").toggle

	self.effect_model = RoleModel.New("lingchong_panel")
	self.effect_model:SetDisplay(self:FindObj("EffectDisplay").ui3d_display)

	self.model = RoleModel.New("lingchong_panel")
	self.model:SetDisplay(self:FindObj("Display").ui3d_display)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.baoji = self:FindVariable("baoji")
	self.fangyu = self:FindVariable("fangyu")
	self.fight_power = self:FindVariable("fight_power")
	self.gongji = self:FindVariable("gongji")
	self.is_used = self:FindVariable("is_used")
	self.can_use = self:FindVariable("can_use")
	self.jianren = self:FindVariable("jianren")
	self.maxhp = self:FindVariable("maxhp")
	self.mingzhong = self:FindVariable("mingzhong")
	self.pro_str = self:FindVariable("pro_str")
	self.pro_value = self:FindVariable("pro_value")
	self.grade_name = self:FindVariable("grade_name")
	self.shanbi = self:FindVariable("shanbi")
	self.show_left = self:FindVariable("show_left")
	self.show_right = self:FindVariable("show_right")
	self.use_item_str = self:FindVariable("use_item_str")
	self.name = self:FindVariable("name")
	self.is_upgrade = self:FindVariable("is_upgrade")
	self.is_max = self:FindVariable("is_max")
	self.show_clear_val = self:FindVariable("show_clear_val")
	self.all_attr_panel = self:FindObj("AllAttrPanel")
	self.all_attr_percent = self:FindVariable("AllAttrPercent")
	self.active_need_grade = self:FindVariable("ActiveNeedGrade")
	self.all_attr_btn_gray = self:FindVariable("AllAttrBtnGray")

	--红点
	self.zizhi_remind = self:FindVariable("zizhi_remind")
	self.huanhua_remind = self:FindVariable("huanhua_remind")
	self.red_point_list = {
		-- [RemindName.LingChong_ZiZhi] = self:FindVariable("zizhi_remind"),
		-- [RemindName.LingChong_HuanHua] = self:FindVariable("huanhua_remind"),
	}

	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	-- for k,v in pairs(self.red_point_list) do
	-- 	RemindManager.Instance:Bind(self.remind_change, k)
	-- end
end

function LingChongContentView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.effect_model then
		self.effect_model:DeleteMe()
		self.effect_model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- if RemindManager.Instance then
	-- 	RemindManager.Instance:UnBind(self.remind_change)
	-- end
end

function LingChongContentView:RemindChangeCallBack(key, value)
	if self.red_point_list[key] then
		self.red_point_list[key]:SetValue(value > 0)
	end
end

-- 显示全属性加成面板
function LingChongContentView:OnClickAllAttrBtn()
	self.all_attr_panel:SetActive(not self.all_attr_panel.gameObject.activeSelf)
end

function LingChongContentView:FlushAllAttrPanel()
	local all_attr_percent = LingChongData.Instance:GetAllAttrPercent()
	local active_need_grade = LingChongData.Instance:GetActiveNeedGrade()
	local cur_grade = LingChongData.Instance:GetGrade()
	self.all_attr_percent:SetValue(all_attr_percent)
	self.active_need_grade:SetValue(active_need_grade - 1) --客户端显示的阶数比服务端少一，所以这里减一
	self.all_attr_btn_gray:SetValue(cur_grade >= active_need_grade)
end


function LingChongContentView:ClickUse()
	local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.select_grade)
	if nil == grade_info then
		return
	end

	LingChongCtrl.Instance:SendUseLingChongImage(grade_info.image_id, 0)
end

function LingChongContentView:ClickLeft()
	self.select_grade = self.select_grade - 1
	self:FlushView()
end

function LingChongContentView:ClickRight()
	self.select_grade = self.select_grade + 1
	self:FlushView()
end

function LingChongContentView:ClickUpgrade()
	local lingchong_info = LingChongData.Instance:GetLingChongInfo()
	if nil == lingchong_info then
		return
	end

	local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingchong_info.grade)
	if nil == grade_info then
		return
	end

	--获取下一级，不存在则满级
	local next_grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingchong_info.grade + 1)
	if nil == next_grade_info then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.MaxGradeText)
		return
	end

	local is_auto_buy = self.toggle_check.isOn and 1 or 0
	local item_id = grade_info.upgrade_stuff_id
	local item_id2 = grade_info.upgrade_stuff2_id
	local need_item_num = grade_info.upgrade_stuff_count
	local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)

	if is_auto_buy == 0 and have_item_num < need_item_num then
		local function buy_call_back(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			self.toggle_check.isOn = is_buy_quick
		end

		TipsCtrl.Instance:ShowCommonBuyView(buy_call_back, item_id, nil, 1)
		return
	end

	self.is_upgrade_state = not self.is_upgrade_state
	--设置按钮状态
	self.is_upgrade:SetValue(self.is_upgrade_state)

	if self.is_upgrade_state then
		LingChongCtrl.Instance:SendUpgradeLingChong(grade_info.pack_num, is_auto_buy)
	end
end

function LingChongContentView:ClickHelp()
end

function LingChongContentView:ClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "lingchong_zizhi")
end

function LingChongContentView:ClickHuanHua()
	ViewManager.Instance:Open(ViewName.LingChongHuanHua)
end

function LingChongContentView:ClickSkill()
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "lingchongkill", {index = 0})
end

function LingChongContentView:InitView()
	self.is_init = true

	self.is_upgrade_state = false

	--重置按钮状态
	self.is_upgrade:SetValue(false)
	self.toggle_check.isOn = false

	self.old_select_grade = 0
	self.select_grade = 0
	local lingchong_info = LingChongData.Instance:GetLingChongInfo()
	if nil ~= lingchong_info then
		--默认选择已使用的形象阶数
		if lingchong_info.grade == 1 then
			--零阶和一阶使用相同形象
			self.select_grade = lingchong_info.grade
		else
			local image_info = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(lingchong_info.used_imageid)
			if nil ~= image_info then
				--show_grade为客户端阶数由0开始，服务器阶数由1开始，所以要加1
				self.select_grade = image_info.show_grade + 1
			end

		end
	end

	self:FlushView()
end

function LingChongContentView:FlushView()
	self:FlushLeft()
	self:FlushRight()
end

function LingChongContentView:FlushModel()
	--对应等级数据
	local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.select_grade)
	if nil == grade_info then
		return
	end

	--对应资源数据
	local image_info = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_info then
		return
	end

	local bundle, asset = ResPath.GetLingChongModelEffect(image_info.res_id_h)
	self.effect_model:SetMainAsset(bundle, asset)

	bundle, asset = ResPath.GetLingChongModel(image_info.res_id_h)

	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
	self.model:SetTrigger(LINGCHONG_ANIMATOR_PARAM.REST)
end

function LingChongContentView:FlushLeft()
	local lingchong_info = LingChongData.Instance:GetLingChongInfo()
	if nil == lingchong_info then
		return
	end

	--初始记录旧阶数
	if self.old_grade < 0 then
		self.old_grade = lingchong_info.grade
	end

	if self.old_grade ~= lingchong_info.grade then
		--进阶成功
		AudioService.Instance:PlayAdvancedAudio()
		self:PlayEffect()

		self.old_grade = lingchong_info.grade
		self.select_grade = lingchong_info.grade
	end

	--刷新模型
	if self.select_grade ~= self.old_select_grade then
		self.old_select_grade = self.select_grade

		self:FlushModel()
	end

	local temp_grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.select_grade)
	if nil == temp_grade_info then
		return
	end

	self.grade_name:SetValue(temp_grade_info.gradename)
	self:FlushAllAttrPanel()

	--刷新使用状态
	if lingchong_info.grade >= self.select_grade then
		self.can_use:SetValue(true)
		self.is_used:SetValue(temp_grade_info.image_id == lingchong_info.used_imageid)
	else
		self.can_use:SetValue(false)
	end

	--刷新左右箭头
	local last_temp_grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.select_grade - 1)
	local is_show_left = true
	if nil == last_temp_grade_info or (lingchong_info.grade > 1 and temp_grade_info.show_grade == 1) then
		--没有上一阶属性或者处于第一阶(服务器第二阶)不显示左箭头
		is_show_left = false
	end
	self.show_left:SetValue(is_show_left)

	local next_temp_grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.select_grade + 1)
	local is_show_right = true
	if nil == next_temp_grade_info or self.select_grade > lingchong_info.grade then
		is_show_right = false
	end
	self.show_right:SetValue(is_show_right)
end

function LingChongContentView:FlushRight()
	local lingchong_info = LingChongData.Instance:GetLingChongInfo()
	if nil == lingchong_info then
		return
	end

	local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingchong_info.grade)
	if nil == grade_info then
		return
	end

	--刷新属性
	local name = ""
	local temp_grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.select_grade)
	if nil ~= temp_grade_info then
		local image_info = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(temp_grade_info.image_id)
		if nil ~= image_info then
			name = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		end
	end

	self.name:SetValue(name)

	self.maxhp:SetValue(grade_info.maxhp)
	self.gongji:SetValue(grade_info.gongji)
	self.fangyu:SetValue(grade_info.fangyu)
	self.mingzhong:SetValue(grade_info.mingzhong)
	self.shanbi:SetValue(grade_info.shanbi)
	self.baoji:SetValue(grade_info.baoji)
	self.jianren:SetValue(grade_info.jianren)

	local capability = CommonDataManager.GetCapabilityCalculation(grade_info)
	local all_attr_percent_cap = LingChongData.Instance:CalculateAllAttrCap(capability) 
	self.fight_power:SetValue(capability + all_attr_percent_cap)

	self.show_clear_val:SetValue(grade_info.is_clear_bless)

	self.is_max:SetValue(true)

	local pro_value = 1
	local pro_str = Language.Common.MaxGrade
	--获取下一阶属性，如果存在则设置进度
	local next_grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingchong_info.grade + 1)
	if nil ~= next_grade_info then
		self.is_max:SetValue(false)
		pro_value = lingchong_info.grade_bless_val / grade_info.bless_val_limit
		pro_str = string.format("%s / %s", lingchong_info.grade_bless_val, grade_info.bless_val_limit)
	end

	--刷新进度条
	if self.is_init then
		self.is_init = false
		self.pro_value:InitValue(pro_value)
	else
		self.pro_value:SetValue(pro_value)
	end

	self.pro_str:SetValue(pro_str)

	--刷新物品展示
	self:FlushItem()
end

function LingChongContentView:UpGradeResult(result)
	if not self.is_upgrade_state then
		return
	end

	local lingchong_info = LingChongData.Instance:GetLingChongInfo()
	if nil == lingchong_info then
		return
	end

	local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingchong_info.grade)
	if nil == grade_info then
		return
	end

	if result == 0 then
		self.is_upgrade_state = false
		self.is_upgrade:SetValue(false)
		return
	end

	self.is_upgrade:SetValue(true)

	self:FlushView()

	--判断是否勾选一键购买
	if self.toggle_check.isOn then
		LingChongCtrl.Instance:SendUpgradeLingChong(grade_info.pack_num, 1)
	else
		LingChongCtrl.Instance:SendUpgradeLingChong(grade_info.pack_num, 0)
	end
end

function LingChongContentView:FlushItem()
	local lingchong_info = LingChongData.Instance:GetLingChongInfo()
	if nil == lingchong_info then
		return
	end

	local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingchong_info.grade)
	if nil == grade_info then
		return
	end

	local item_id = grade_info.upgrade_stuff_id
	local item_id2 = grade_info.upgrade_stuff2_id
	local need_item_num = grade_info.upgrade_stuff_count
	local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)

	self.item_cell:SetData({item_id = item_id})

	local item_str = ""
	local next_grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingchong_info.grade + 1)
	if nil ~= next_grade_info then
		local color = TEXT_COLOR.RED
		if have_item_num >= need_item_num then
			color = TEXT_COLOR.YELLOW
		end
		
		have_item_num = ToColorStr(have_item_num, color)
		item_str = string.format("%s / %s", have_item_num, need_item_num)
	end
	self.use_item_str:SetValue(item_str)

	--刷新红点
	self.zizhi_remind:SetValue(LingChongData.Instance:CalcZiZhiRemind() > 0)
	self.huanhua_remind:SetValue(LingChongData.Instance:CalcHuanHuaRemind() > 0)
end

function LingChongContentView:PlayEffect()
	EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
end

function LingChongContentView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "lingchong" then
			self:FlushView()
		elseif k == "lingchong_upgrade" then
			self:UpGradeResult(v[1])
		elseif k == "lingchong_item_change" then
			self:FlushItem()
		end
	end
end