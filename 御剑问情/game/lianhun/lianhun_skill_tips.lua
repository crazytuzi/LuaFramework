LianhunSkillTipsView = LianhunSkillTipsView or BaseClass(BaseView)
function LianhunSkillTipsView:__init()
	self.ui_config = {"uis/views/lianhun_prefab", "SkillDesTip"}
	self.view_layer = UiLayer.Pop

	self.next_des = ""
	self.asset = ""
	self.bunble = ""
	self.name = ""
	self.level = 0
	self.now_des = ""
	self.levelup_str = ""
end

function LianhunSkillTipsView:__delete()

end

function LianhunSkillTipsView:ReleaseCallBack()
	self.show_now_attr = nil
	self.is_max = nil
	self.skill_name = nil
	self.skill_level = nil
	self.now_attr_des = nil
	self.next_attr_des = nil
	self.levelup_des = nil
	self.active_des = nil
	self.skill_res = nil
	self.skill_eff = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.display = nil
end

function LianhunSkillTipsView:LoadCallBack()
	self.show_now_attr = self:FindVariable("ShowNowAttr")
	self.is_max = self:FindVariable("IsMax")
	self.skill_name = self:FindVariable("SkillName")
	self.skill_level = self:FindVariable("SkillLevel")
	self.now_attr_des = self:FindVariable("NowAttrDes")
	self.next_attr_des = self:FindVariable("NextAttrDes")
	self.levelup_des = self:FindVariable("LevelUpDes")
	self.active_des = self:FindVariable("ActiveDes")
	self.skill_res = self:FindVariable("SkillRes")
	self.display = self:FindObj("diaplay")
	self.model = RoleModel.New("lianhun_skill1")
	self.model:SetDisplay(self.display.ui3d_display)

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function LianhunSkillTipsView:CloseWindow()
	self:Close()
end

function LianhunSkillTipsView:OpenCallBack()
	--设置技能图标
	self.skill_res:SetAsset(self.asset, self.bunble)
	self.model:SetPanelName("lianhun_skill" .. math.max(1, self.level))
	self.model:SetMainAsset(self.eff_asset, self.eff_bunble)
	self.model:SetTrigger(ANIMATOR_PARAM.REST)
	--设置是否已激活
	local active_des = Language.Lianhun.IsActiveDes
	if self.level <= 0 then
		active_des = Language.Lianhun.NotActiveDes
	end
	self.active_des:SetValue(active_des)

	--设置等级和名字
	self.skill_name:SetValue(self.name)
	self.skill_level:SetValue(self.level)

	--设置本级属性的展示
	if self.now_des ~= "" then
		self.show_now_attr:SetValue(true)
		self.now_attr_des:SetValue(self.now_des)
	else
		self.show_now_attr:SetValue(false)
	end

	--设置下级属性和升级要求展示
	if self.next_des ~= "" then
		self.is_max:SetValue(false)
		self.next_attr_des:SetValue(self.next_des)
		self.levelup_des:SetValue(self.levelup_str)
	else
		self.is_max:SetValue(true)
	end
end

function LianhunSkillTipsView:CloseCallBack()

end

function LianhunSkillTipsView:SetSkillName(name)
	self.name = name or ""
end

function LianhunSkillTipsView:SetSkillLevel(level)
	self.level = level or 0
end

function LianhunSkillTipsView:SetNowDes(des)
	self.now_des = des or ""
end

function LianhunSkillTipsView:SetNextDes(des)
	self.next_des = des or ""
end

function LianhunSkillTipsView:SetLevelUpDes(levelup_str)
	self.levelup_str = levelup_str or ""
end

function LianhunSkillTipsView:SetSkillRes(asset, bunble)
	self.asset = asset or ""
	self.bunble = bunble or ""
end

function LianhunSkillTipsView:SetSkillEffRes(asset, bunble)
	self.eff_asset = asset or ""
	self.eff_bunble = bunble or ""
end