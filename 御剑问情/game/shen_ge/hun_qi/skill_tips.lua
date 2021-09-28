SkillTipsView = SkillTipsView or BaseClass(BaseView)
function SkillTipsView:__init()
	self.ui_config = {"uis/views/hunqiview_prefab", "SkillDesTip"}
	self.view_layer = UiLayer.Pop

	self.next_des = ""
	self.asset = ""
	self.bunble = ""
	self.name = ""
	self.level = 0
	self.now_des = ""
	self.levelup_str = ""
end

function SkillTipsView:__delete()

end

function SkillTipsView:ReleaseCallBack()
	self.show_now_attr = nil
	self.is_max = nil
	self.skill_name = nil
	self.skill_level = nil
	self.now_attr_des = nil
	self.next_attr_des = nil
	self.levelup_des = nil
	self.active_des = nil
	self.skill_res = nil
end

function SkillTipsView:LoadCallBack()
	self.show_now_attr = self:FindVariable("ShowNowAttr")
	self.is_max = self:FindVariable("IsMax")
	self.skill_name = self:FindVariable("SkillName")
	self.skill_level = self:FindVariable("SkillLevel")
	self.now_attr_des = self:FindVariable("NowAttrDes")
	self.next_attr_des = self:FindVariable("NextAttrDes")
	self.levelup_des = self:FindVariable("LevelUpDes")
	self.active_des = self:FindVariable("ActiveDes")
	self.skill_res = self:FindVariable("SkillRes")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function SkillTipsView:CloseWindow()
	self:Close()
end

function SkillTipsView:OpenCallBack()
	--设置技能图标
	self.skill_res:SetAsset(self.asset, self.bunble)

	--设置是否已激活
	local active_des = Language.HunQi.IsActiveDes
	if self.level <= 0 then
		active_des = Language.HunQi.NotActiveDes
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

function SkillTipsView:CloseCallBack()

end

function SkillTipsView:SetSkillName(name)
	self.name = name or ""
end

function SkillTipsView:SetSkillLevel(level)
	self.level = level or 0
end

function SkillTipsView:SetNowDes(des)
	self.now_des = des or ""
end

function SkillTipsView:SetNextDes(des)
	self.next_des = des or ""
end

function SkillTipsView:SetLevelUpDes(levelup_str)
	self.levelup_str = levelup_str or ""
end

function SkillTipsView:SetSkillRes(asset, bunble)
	self.asset = asset or ""
	self.bunble = bunble or ""
end