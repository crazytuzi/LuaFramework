ZhiBaoUpgradeView = ZhiBaoUpgradeView or BaseClass(BaseRender)

-- local AttrGetPower = nil
local EFFECT_CD = 1

local attr_order = {
	[1] = "maxhp",
	[2] = "gongji",
	[3] = "fangyu",
	-- [4] = "mingzhong",
	-- [5] = "shanbi",
	-- [6] = "baoji",
	-- [7] = "jianren",
}
local attr_img = {
	[1] = "hp",
	[2] = "gj",
	[3] = "fy",
}

local panel_name = {
	[13003]="zhi_bao_upgrade_pane2"
}


function ZhiBaoUpgradeView:__init()
	self.max_skill_num = 4
	self.effect_cd = 0
	--四个技能
	self.skill_list = {}
	for i=1,self.max_skill_num do
		self.skill_list[i] = self:FindObj("Skill"..i)
		self.skill_list[i].button:AddClickListener(BindTool.Bind(self.OnSkillClick, self, i))
	end

	--六个属性
	self.attr_list = {}
	local obj_group = self:FindObj("ObjGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "AttrGroup") ~= nil then
			self.attr_list[count] = ZhiBaoUpgradeAttrGroup.New(obj)
			self.attr_list[count]:SetIndex(count)
			count = count + 1
		end
	end
	--等级
	self.current_level = self:FindVariable("CurrentLevel")
	self.next_level = self:FindVariable("NextLevel")

	--战力
	self.power = self:FindVariable("Power")

	--经验条
	self.slider_value = self:FindVariable("SliderValue")
	self.slider_text = self:FindVariable("SliderText")

	--监听
	self:ListenEvent("UpgradeClick", BindTool.Bind(self.OnUpgradeClick, self))
	self:ListenEvent("UseImageClick", BindTool.Bind(self.UseImageClick, self))
	self:ListenEvent("HuanHuaClick", BindTool.Bind(self.HuanHuaClick, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.HelpClick, self))

	--形象动画勋章
	local max_image = ZhiBaoData.Instance:GetMaxImageNum()
	self.selet_data_index = 1
	local ani_callback = BindTool.Bind(self.AniFinish, self)
	local get_icon_callback = BindTool.Bind(self.GetIconId, self)
	self.ani_medal = AniMedalIconPlus.New(self, max_image, ani_callback, get_icon_callback)

	--阶级
	self.class_value = -1
	-- self.class_bg = self:FindVariable("ClassBG")
	-- self.class_text = self:FindVariable("ClassText")

	--预览部分
	self.preview_name = self:FindVariable("PreviewName")
	self.preview_level = self:FindVariable("PreviewLevel")
	self.preview_class = self:FindVariable("PreviewClass")

	--幻化红点
	self.red_point = self:FindVariable("HuanHuaRedPoint")

	--是否满级
	self.is_max_level = self:FindVariable("IsMaxLevel")

	--升级红点
	self.show_upgrade_red_point = self:FindVariable("ShowUpgradeRedPoint")
	self.is_max_grade = self:FindVariable("IsMaxGrade")
	self.is_using = self:FindVariable("IsUsing")
	self.is_show = self:FindVariable("IsShow")
	self.effect_root = self:FindObj("EffectRoot")

	-- 宝具模型代码
	self.center_display = self:FindObj("CenterDisplay")
	self:InitEquipModel()

	self:AniFinish()
	self:Flush()
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ZhiBao_HuanHua)

	self.prefab_preload_id = 0
end

function ZhiBaoUpgradeView:__delete()
	if self.EquipModel then
		self.EquipModel:DeleteMe()
		self.EquipModel = nil
	end
	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	for k, v in ipairs(self.attr_list) do
		v:DeleteMe()
	end
	self.attr_list = {}

	if self.ani_medal then
		self.ani_medal:DeleteMe()
		self.ani_medal = nil
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function ZhiBaoUpgradeView:CloseCallBack()

end

-------------------------------
-- 模型相关代码
-------------------------------
function ZhiBaoUpgradeView:InitEquipModel()
	if not self.EquipModel then
		self.EquipModel = RoleModel.New("zhi_bao_upgrade_panel")
		self.EquipModel:SetDisplay(self.center_display.ui3d_display)
	end
end

function ZhiBaoUpgradeView:SetModelData()
	if 0 >= self.selet_data_index then
		self.selet_data_index = 1
	end

	local res_id = ZhiBaoData.Instance:GetZhiBaoXingX(self.selet_data_index)
	local bubble, asset = ResPath.GetHighBaoJuModel(res_id)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	local load_list = {{bubble, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			if not self.EquipModel then return end
			
			self.EquipModel:SetPanelName(self:SetSpecialModle(res_id))
			self.EquipModel:SetMainAsset(bubble, asset)
			-- self.EquipModel:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ZHIBAO], res_id, DISPLAY_PANEL.FULL_PANEL)
			self.EquipModel:SetLoopAnimal("bj_rest", "rest_stop")
		end)
end


function ZhiBaoUpgradeView:SetSpecialModle(modle_id)
	local display_name = "zhi_bao_upgrade_panel"--通用面板名称
	if nil ~= panel_name[modle_id] then
		display_name = panel_name[modle_id]
		--print_error(PanelName)
	end
	--print_error(display_name, modle_id)
	return display_name
end

-------------------------------
-- 结束
-------------------------------
function ZhiBaoUpgradeView:HelpClick()
	local tips_id = 20    -- 宝具tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ZhiBaoUpgradeView:RemindChangeCallBack(key, value)
	self.red_point:SetValue(value > 0)
end


function ZhiBaoUpgradeView:SetHuanHuaRedPoint()
	self.red_point:SetValue(RemindManager.Instance:GetRemind(RemindName.ZhiBao_HuanHua) > 0)
end

function ZhiBaoUpgradeView:HuanHuaClick()
	ZhiBaoCtrl.Instance:OpenHuanHuaView()
end

--点击了使用形象
function ZhiBaoUpgradeView:UseImageClick()
	if ZhiBaoData.Instance:GetImageIsActive(self.selet_data_index) then
		ZhiBaoCtrl.Instance:SendUseImage(self.selet_data_index)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotEnoughZhiBaoLevel)
	end
end

function ZhiBaoUpgradeView:SetButtonVisible()
	local is_active = ZhiBaoData.Instance:GetImageIsActive(self.selet_data_index)
	if is_active then
		self.is_using:SetValue(self.selet_data_index == ZhiBaoData.Instance:GetZhiBaoImage())
		self.is_show:SetValue(self.selet_data_index == ZhiBaoData.Instance:GetZhiBaoImage())
	else
		self.is_using:SetValue(true)
		self.is_show:SetValue(false)
	end
end

--动画勋章 播放完
function ZhiBaoUpgradeView:AniFinish()
	local level_cfg = ZhiBaoData.Instance:GetLevelImageCfg(self.selet_data_index)
	local max_image = ZhiBaoData.Instance:GetMaxImageNum()
	local active_index = ZhiBaoData.Instance:GetJsByLevel(ZhiBaoData.Instance:GetZhiBaoLevel())
	local right_arrow = self:FindObj("RightArrow")
	if not level_cfg then
		return
	end
	right_arrow:SetActive(self.selet_data_index < max_image and active_index >= self.selet_data_index)
	self.preview_name:SetValue(level_cfg.name)
	self.preview_class:SetValue(level_cfg.image_id)
	-- print_log(self.selet_data_index)
	if self.selet_data_index > 10 then
		self.selet_data_index = 10
	end
	-- self.class_text:SetValue(Language.Common.NumToChs[self.selet_data_index]..Language.Common.Jie)
	self:SetModelData()
	self:SetButtonVisible()
end

--动画勋章 获取刷新数据
function ZhiBaoUpgradeView:GetIconId()
	local image = ZhiBaoData.Instance:GetZhiBaoImage()
	local is_show_wearing = (self.selet_data_index == image)
	local level_cfg = ZhiBaoData.Instance:GetLevelImageCfg(self.selet_data_index)
	if not level_cfg then
		return
	end
	local id = 26220 + level_cfg.image_id - 1 -- TODO目前没有UI图标
	local bundle, asset = ResPath.GetItemIcon(id)
	return bundle, asset, is_show_wearing
end

function ZhiBaoUpgradeView:OpenCallBack()
	self:SetNormalIcon()
	self:SetHuanHuaRedPoint()
end

function ZhiBaoUpgradeView:SetNormalIcon()
	local img_index = ZhiBaoData.Instance:GetZhiBaoImage()
	if img_index >= 1000 then
		-- self.selet_data_index = img_index - 1000
	elseif img_index == 0 then
		self.selet_data_index = 1
	else
		self.selet_data_index = img_index
	end
	self.ani_medal:OpenCallBack()
	if ZhiBaoView.Instance and ZhiBaoView.Instance:GetUpGradeToggleisOn() then
		self:SetModelData()
	end
end

function ZhiBaoUpgradeView:ShowCurrentIcon()
	local level = ZhiBaoData.Instance:GetZhiBaoLevel()
	local cfg = ZhiBaoData.Instance:GetLevelCfgByLevel(level)
	if cfg ~= nil then
		self.selet_data_index = cfg.image_id
	else
		self.selet_data_index = 1
	end
	self.ani_medal:OpenCallBack()
	if ZhiBaoView.Instance and ZhiBaoView.Instance:GetUpGradeToggleisOn() then
		self:SetModelData()
	end
end

function ZhiBaoUpgradeView:OnClassUpgrade()
	self:ShowCurrentIcon()
	-- self:UseImageClick()
end

function ZhiBaoUpgradeView:AttrSetData(name, now_value, count, next_value)
	if count > #self.attr_list then
		print("属性超出最大可显示范围", name, now_value)
		return count
	end
	local data = {}
	local name_txt = name..": "
	local value_txt = now_value
	data.now_attr_text = name_txt..now_value
	if next_value ~= nil then
		data.next_attr_text = next_value
	end
	self.attr_list[count]:SetActive(true)
	self.attr_list[count]:SetData(data)
	count = count + 1
	return count
end

function ZhiBaoUpgradeView:UpGradeFlush()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
				"effects2/prefab/ui_x/ui_sjcg_prefab",
				"UI_sjcg",
				self.effect_root.transform,
				2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ZhiBaoUpgradeView:Flush()
	local zhibao_level = ZhiBaoData.Instance:GetZhiBaoLevel()
	if zhibao_level == nil then
		print_log('获取至宝等级失败')
		return
	end
	local next_image_cfg = ZhiBaoData.Instance:GetNextImageCfg()
	if next_image_cfg ~= nil then
		self.is_max_grade:SetValue(false)
		self.preview_level:SetValue(next_image_cfg.level)
	else
		self.is_max_grade:SetValue(true)
	end

	self.show_upgrade_red_point:SetValue(ZhiBaoData.Instance:CheckZhiBaoCanUpgrade())

	local cu_cfg = ZhiBaoData.Instance:GetLevelCfgByLevel(zhibao_level)
	local next_cfg = ZhiBaoData.Instance:GetLevelCfgByLevel(zhibao_level + 1)
	self.is_max_level:SetValue((next_cfg==nil))
	--普通属性对
	local attrs = CommonDataManager.GetAttributteNoUnderline(cu_cfg)
	local next_attrs = CommonDataManager.GetAttributteNoUnderline(next_cfg)

	for k,v in pairs(self.attr_list) do
		v:SetActive(false)
	end
	local count = 1
	for i=1,#attr_order do
		local key = attr_order[i]
		-- if attrs[key] > 0 then
			local name = CommonDataManager.GetAttrName(key)
			local next_attr_text = nil
			if next_cfg ~= nil then
				next_attr_text = next_attrs[key]
			end
			count = self:AttrSetData(name, attrs[key], count, next_attr_text)
		-- end
	end
	--坐骑羽翼属性对
	--当前
	local mount_add = 0
	local wing_add = 0

	mount_add = cu_cfg.mount_attr_add
	wing_add = cu_cfg.wing_attr_add
	--下一
	local next_mount_cfg, next_wing_cfg = ZhiBaoData.Instance:GetNextAdditionCfg(mount_add, wing_add)
	--下一坐骑
	local m_name = Language.Common.AdvanceAttrName.mount_attr
	local m_value = '+'..(mount_add / 100)..'%'
	local m_next_value = nil
	if next_mount_cfg ~= nil then
		m_next_value = (next_mount_cfg.mount_attr_add / 100)..'%'..'('..next_mount_cfg.level..Language.Common.Ji..')'
	end
	count = self:AttrSetData(m_name, m_value, count, m_next_value)
	--下一羽翼
	local w_name = Language.Common.AdvanceAttrName.wing_attr
	local w_value = '+'..(wing_add / 100)..'%'
	local w_next_value = nil
	if next_wing_cfg ~= nil then
		w_next_value = (next_wing_cfg.wing_attr_add / 100)..'%'..'('..next_wing_cfg.level..Language.Common.Ji..')'
	end
	count = self:AttrSetData(w_name, w_value, count, w_next_value)
	--经验
	local playr_zhibao_exp = ZhiBaoData.Instance:GetZhiBaoExp()
	local next_level_text = ""
	local slider_value = 0
	local slider_text = ""
	if next_cfg ~= nil then
		slider_value = playr_zhibao_exp / cu_cfg.uplevel_exp
		next_level_text = 'Lv.'..zhibao_level + 1
		slider_text = playr_zhibao_exp..' / '..cu_cfg.uplevel_exp
	else
		slider_value = 1
		next_level_text = ""
		slider_text = ""
	end
	--等级
	self.current_level:SetValue("Lv."..zhibao_level)
	self.next_level:SetValue(next_level_text)
	--经验进度条
	self.slider_value:SetValue(slider_value)
	self.slider_text:SetValue(slider_text)
	--阶级
	local cu_image_id = cu_cfg.image_id
	if cu_image_id > self.class_value then
		self.class_value = cu_cfg.image_id
		self:OnClassUpgrade()
	end
	-- local tmp_calss_text = ''
	-- local bundle, asset = '', ''
	-- tmp_calss_text = ZhiBaoData.Instance:GetChsNumber(cu_cfg.image_id)
	-- bundle, asset = ResPath.GetMountGradeQualityBG(math.ceil(cu_cfg.image_id/2))

	-- self.class_text:SetValue(Language.Common.NumToChs[self.selet_data_index]..Language.Common.Jie)
	-- self.class_bg:SetAsset(bundle, asset)
	--技能
	for i=1,#self.skill_list do
		local cfg = ZhiBaoData.Instance:GetSkillCfgByIndex(i - 1)
		if cfg == nil then
			cfg = ZhiBaoData.Instance:GetSkillCfgBySkillLevel(i - 1, 1)
		end
		--TODO目前没有图标
		bundle, asset = ResPath.GetBaoJuSkillIcon(cfg.skill_idx + 1)
		self.skill_list[i].image:LoadSprite(bundle, asset)
		local skill_data = ZhiBaoData.Instance:GetSkillCfgByIndex(i - 1)
		if skill_data then
			self.skill_list[i].grayscale.GrayScale=0
		else
			self.skill_list[i].grayscale.GrayScale=255
		end
	end
	--战斗力
	self.power:SetValue(CommonDataManager.GetCapability(attrs))

	self.ani_medal:FlushMainIcon()
	self:SetButtonVisible()
	if ZhiBaoData.Instance:GetZhiBaoIsJj() then
		self:SetModelData()
	end
end


function ZhiBaoUpgradeView:OnSkillClick(skill_number)
	skill_number = skill_number - 1
	local skill_data = ZhiBaoData.Instance:GetSkillCfgByIndex(skill_number)
	local next_level = 0
	if skill_data ~= nil then
		next_level = skill_data.skill_level + 1
	else
		next_level = 1
	end
	local next_skill_data = ZhiBaoData.Instance:GetSkillCfgBySkillLevel(skill_number, next_level)
	TipsCtrl.Instance:ShowZhiBaoSkillView(skill_data, next_skill_data)
end

function ZhiBaoUpgradeView:OnUpgradeClick()
	if ZhiBaoData.Instance:GetZhiBaoCanUpgrade() then
		ZhiBaoCtrl.Instance:SendZhiBaoUpgrade()
		AudioService.Instance:PlayAdvancedAudio()
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotEnoughZhiBaoExp)
	end
end

----------------------------------------------------------------------------
--ZhiBaoUpgradeAttrGroup		属性对
----------------------------------------------------------------------------

ZhiBaoUpgradeAttrGroup = ZhiBaoUpgradeAttrGroup or BaseClass(BaseCell)
function ZhiBaoUpgradeAttrGroup:__init()
	self.now_attr = self:FindVariable("NowAttr")
	self.next_attr = self:FindVariable("NextAttr")
	self.show_next = self:FindVariable("ShowNext")
	self.attr_icon = self:FindVariable("Icon")
	self.attr_type = self:FindVariable("AttrType")
end

function ZhiBaoUpgradeAttrGroup:__delete()
end

function ZhiBaoUpgradeAttrGroup:OnFlush()
	local now_attr_val = string.sub(self.data.now_attr_text, 8)
	local now_attr_type = string.sub(self.data.now_attr_text, 1, 7)
	self.attr_type:SetValue(now_attr_type)
	self.now_attr:SetValue(now_attr_val)
	if self.data.next_attr_text ~= nil then
		self.show_next:SetValue(true)
		self.next_attr:SetValue(self.data.next_attr_text)
	else
		self.show_next:SetValue(false)
	end
	local path_name = attr_img[self.index] and "icon_info_" .. attr_img[self.index] or "icon_info_gj"
	if self.attr_icon then
		local bundle, asset = ResPath.GetImages(path_name, "icon_atlas")
		self.attr_icon:SetAsset(bundle, asset)
	end
end
