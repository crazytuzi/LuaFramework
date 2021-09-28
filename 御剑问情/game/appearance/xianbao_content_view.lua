XianBaoContentView = XianBaoContentView or BaseClass(BaseRender)

function XianBaoContentView:__init()
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
	self:ListenEvent("OnClickAllAttrBtn",
		BindTool.Bind(self.OnClickAllAttrBtn, self))

	self.effect_root = self:FindObj("EffectRoot")

	self.toggle_check = self:FindObj("ToggleCheck").toggle

	self.model = RoleModel.New("xianbao_panel")
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
	self.red_point_list = {
		[RemindName.XianBao_ZiZhi] = self:FindVariable("zizhi_remind"),
		[RemindName.XianBao_HuanHua] = self:FindVariable("huanhua_remind"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k,v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function XianBaoContentView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function XianBaoContentView:RemindChangeCallBack(key, value)
	if self.red_point_list[key] then
		self.red_point_list[key]:SetValue(value > 0)
	end
end

function XianBaoContentView:ClickUse()
	local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.select_grade)
	if nil == grade_info then
		return
	end

	XianBaoCtrl.Instance:SendUseXianBaoImage(grade_info.image_id, 0)
end

function XianBaoContentView:ClickLeft()
	self.select_grade = self.select_grade - 1
	self:FlushView()
end

function XianBaoContentView:ClickRight()
	self.select_grade = self.select_grade + 1
	self:FlushView()
end

function XianBaoContentView:ClickUpgrade()
	local xianbao_info = XianBaoData.Instance:GetXianBaoInfo()
	if nil == xianbao_info then
		return
	end

	local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_info.grade)
	if nil == grade_info then
		return
	end

	--获取下一级，不存在则满级
	local next_grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_info.grade + 1)
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
		XianBaoCtrl.Instance:SendUpgradeXianBao(grade_info.pack_num, is_auto_buy)
	end
end

function XianBaoContentView:ClickHelp()
end

function XianBaoContentView:ClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "xianbao_zizhi")
end

function XianBaoContentView:ClickHuanHua()
	ViewManager.Instance:Open(ViewName.XianBaoHuanHua)
end

function XianBaoContentView:InitView()
	self.is_init = true

	self.is_upgrade_state = false

	--重置按钮状态
	self.is_upgrade:SetValue(false)
	self.toggle_check.isOn = false

	self.old_select_grade = 0
	self.select_grade = 0
	local xianbao_info = XianBaoData.Instance:GetXianBaoInfo()
	if nil ~= xianbao_info then
		--默认选择已使用的形象阶数
		if xianbao_info.grade == 1 then
			--零阶和一阶使用相同形象
			self.select_grade = xianbao_info.grade
		else
			local image_info = XianBaoData.Instance:GetXianBaoImageCfgInfoByImageId(xianbao_info.used_imageid)
			if nil ~= image_info then
				--show_grade为客户端阶数由0开始，服务器阶数由1开始，所以要加1
				self.select_grade = image_info.show_grade + 1
			end

		end
	end

	self:FlushView()
end


-- 显示全属性加成面板
function XianBaoContentView:OnClickAllAttrBtn()
	self.all_attr_panel:SetActive(not self.all_attr_panel.gameObject.activeSelf)
end

function XianBaoContentView:FlushAllAttrPanel()
	local all_attr_percent = XianBaoData.Instance:GetAllAttrPercent()
	local active_need_grade = XianBaoData.Instance:GetActiveNeedGrade()
	local cur_grade = XianBaoData.Instance:GetGrade()
	self.all_attr_percent:SetValue(all_attr_percent)
	self.active_need_grade:SetValue(active_need_grade - 1) --客户端显示的阶数比服务端少一，所以这里减一
	self.all_attr_btn_gray:SetValue(cur_grade >= active_need_grade)
end

function XianBaoContentView:FlushView()
	self:FlushLeft()
	self:FlushRight()
end

function XianBaoContentView:FlushModel()
	--对应等级数据
	local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.select_grade)
	if nil == grade_info then
		return
	end

	--对应资源数据
	local image_info = XianBaoData.Instance:GetXianBaoImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_info then
		return
	end

	local bundle, asset = ResPath.GetXianBaoModel(image_info.res_id)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
end

function XianBaoContentView:FlushLeft()
	local xianbao_info = XianBaoData.Instance:GetXianBaoInfo()
	if nil == xianbao_info then
		return
	end

	--初始记录旧阶数
	if self.old_grade < 0 then
		self.old_grade = xianbao_info.grade
	end

	if self.old_grade ~= xianbao_info.grade then
		--进阶成功
		AudioService.Instance:PlayAdvancedAudio()
		self:PlayEffect()

		self.old_grade = xianbao_info.grade
		self.select_grade = xianbao_info.grade
	end

	--刷新模型
	if self.select_grade ~= self.old_select_grade then
		self.old_select_grade = self.select_grade

		self:FlushModel()
	end

	local temp_grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.select_grade)
	if nil == temp_grade_info then
		return
	end

	self.grade_name:SetValue(temp_grade_info.gradename)
	self:FlushAllAttrPanel()
	
	--刷新使用状态
	if xianbao_info.grade >= self.select_grade then
		self.can_use:SetValue(true)
		self.is_used:SetValue(temp_grade_info.image_id == xianbao_info.used_imageid)
	else
		self.can_use:SetValue(false)
	end

	--刷新左右箭头
	local last_temp_grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.select_grade - 1)
	local is_show_left = true
	if nil == last_temp_grade_info or (xianbao_info.grade > 1 and temp_grade_info.show_grade == 1) then
		--没有上一阶属性或者处于第一阶(服务器第二阶)不显示左箭头
		is_show_left = false
	end
	self.show_left:SetValue(is_show_left)

	local next_temp_grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.select_grade + 1)
	local is_show_right = true
	if nil == next_temp_grade_info or self.select_grade > xianbao_info.grade then
		is_show_right = false
	end
	self.show_right:SetValue(is_show_right)
end

function XianBaoContentView:FlushRight()
	local xianbao_info = XianBaoData.Instance:GetXianBaoInfo()
	if nil == xianbao_info then
		return
	end

	local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_info.grade)
	if nil == grade_info then
		return
	end

	--刷新属性
	local name = ""
	local temp_grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.select_grade)
	if nil ~= temp_grade_info then
		local image_info = XianBaoData.Instance:GetXianBaoImageCfgInfoByImageId(temp_grade_info.image_id)
		if nil ~= image_info then
			name = ToColorStr(image_info.image_name, APPEARANCE_NAME_COLOR[image_info.colour])
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
	local all_attr_percent_cap = XianBaoData.Instance:CalculateAllAttrCap(capability)
	self.fight_power:SetValue(capability + all_attr_percent_cap)

	self.show_clear_val:SetValue(grade_info.is_clear_bless)

	self.is_max:SetValue(true)

	local pro_value = 1
	local pro_str = Language.Common.MaxGrade
	--获取下一阶属性，如果存在则设置进度
	local next_grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_info.grade + 1)
	if nil ~= next_grade_info then
		self.is_max:SetValue(false)
		pro_value = xianbao_info.grade_bless_val / grade_info.bless_val_limit
		pro_str = string.format("%s / %s", xianbao_info.grade_bless_val, grade_info.bless_val_limit)
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

function XianBaoContentView:UpGradeResult(result)
	if not self.is_upgrade_state then
		return
	end

	local xianbao_info = XianBaoData.Instance:GetXianBaoInfo()
	if nil == xianbao_info then
		return
	end

	local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_info.grade)
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
		XianBaoCtrl.Instance:SendUpgradeXianBao(grade_info.pack_num, 1)
	else
		XianBaoCtrl.Instance:SendUpgradeXianBao(grade_info.pack_num, 0)
	end
end

function XianBaoContentView:FlushItem()
	local xianbao_info = XianBaoData.Instance:GetXianBaoInfo()
	if nil == xianbao_info then
		return
	end

	local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_info.grade)
	if nil == grade_info then
		return
	end

	local item_id = grade_info.upgrade_stuff_id
	local item_id2 = grade_info.upgrade_stuff2_id
	local need_item_num = grade_info.upgrade_stuff_count
	local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)

	self.item_cell:SetData({item_id = item_id})

	local item_str = ""
	local next_grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_info.grade + 1)
	if nil ~= next_grade_info then
		local color = TEXT_COLOR.RED
		if have_item_num >= need_item_num then
			color = TEXT_COLOR.YELLOW
		end
		
		have_item_num = ToColorStr(have_item_num, color)
		item_str = string.format("%s / %s", have_item_num, need_item_num)
	end
	self.use_item_str:SetValue(item_str)
end

function XianBaoContentView:PlayEffect()
	EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
end

function XianBaoContentView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "xianbao" then
			self:FlushView()
		elseif k == "xianbao_upgrade" then
			self:UpGradeResult(v[1])
		elseif k == "xianbao_item_change" then
			self:FlushItem()
		end
	end
end