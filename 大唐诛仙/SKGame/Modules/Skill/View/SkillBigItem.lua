SkillBigItem = BaseClass(LuaUI)

function SkillBigItem:__init(...)
	self.URL = "ui://tv6313j0l6nql";
	self:__property(...)
	self:Config()
end

function SkillBigItem:SetProperty(...)
	
end

function SkillBigItem:Config()
	self:CleanUI()
	self:InitData()
end

function SkillBigItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Skill","SkillBigItem");

	self.button = self.ui:GetController("button")
	self.image_alpha_bg = self.ui:GetChild("image_alpha_bg")
	self.image_select = self.ui:GetChild("image_select")
	self.loader_skill_icon = self.ui:GetChild("loader_skill_icon")
	self.image_arrow = self.ui:GetChild("image_arrow")
	self.group_skill = self.ui:GetChild("group_skill")
	self.bg_level = self.ui:GetChild("bg_level")
	self.label_level = self.ui:GetChild("label_level")
	self.group_level = self.ui:GetChild("group_level")
	self.image_skill_icon_border = self.ui:GetChild("image_skill_icon_border")
	self.effect_root = self.ui:GetChild("effect_root")

end

function SkillBigItem.Create(ui, ...)
	return SkillBigItem.New(ui, "#", {...})
end

function SkillBigItem:__delete()
	self.skillData = nil
	self.model = nil
	self:CleanUI()
	self:CleanEffect()
end

function SkillBigItem:CleanUI()
	self.image_alpha_bg.visible = false
	self.image_select.visible = false
	self.loader_skill_icon.url = ""
	self.image_arrow.visible = false
	self.label_level.text = ""

end

function SkillBigItem:InitData()
	self.skillData = {}
	self.model = SkillModel:GetInstance()
	self.effectObj = nil
end

function SkillBigItem:SetData(data)	
	self.skillData = data or {}
end

function SkillBigItem:SetUI()
	if not TableIsEmpty(self.skillData) then
		local isHas = self.model:IsHasSkill(self.skillData.skillId)
		self.loader_skill_icon.url = StringFormat("Icon/Skill/{0}" , self.skillData.iconID)
		local strLev = ""
		if not isHas then
			strLev = "0级"
		else
			strLev = StringFormat("{0}级" , self.skillData.level)
		end
		self.label_level.text = strLev
		self:SetGrayed(not isHas)

		local IsCanUpgrade = self.model:IsCanUpgrade(self.skillData.skillId)
		self:SetUpgradeArrowUI(IsCanUpgrade)
	end
end

function SkillBigItem:SetSelectUI(bl)
	self.image_select.visible = bl
end

function SkillBigItem:SetUpgradeArrowUI(bl)
	self.image_arrow.visible = bl
end

function SkillBigItem:LoadEffect()
	local function LoadCallback(effect)
		if effect then
			if self.effectObj ~= nil then
				destroyImmediate(self.effectObj)
				self.effectObj = nil
			end
			local effectObj = GameObject.Instantiate(effect)
			effectObj.transform.localPosition = Vector3.New(54 , -53 , 0)
			effectObj.transform.localScale = Vector3.New(80, 80, 80)
	 		effectObj.transform.localRotation = Quaternion.Euler(0, 0, 0)

			self.effect_root:SetNativeObject(GoWrapper.New(effectObj))

			self.effectObj = effectObj
		end
	end
	LoadEffect("4600" , LoadCallback)
end

function SkillBigItem:CleanEffect()
	if self.effectObj ~= nil then
		destroyImmediate(self.effectObj)
		self.effectObj = nil
	end
end

--如果是铭文技能，需要使能透明底图和特效
function SkillBigItem:SetEffect()
	if not TableIsEmpty(self.skillData) then
		if self.model:IsMWSkill(self.skillData.skillId) == true then
			self:LoadEffect()
			self.image_alpha_bg.visible = true
		else
			self:CleanEffect()
			self.image_alpha_bg.visible = false
		end
	end
end
