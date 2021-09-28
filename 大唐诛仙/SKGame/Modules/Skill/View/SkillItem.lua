SkillItem = BaseClass(LuaUI)

function SkillItem:__init(...)
	self.URL = "ui://tv6313j0w5h8d";
	self:__property(...)
	self:Config()
end

function SkillItem:SetProperty(...)
	
end

function SkillItem:Config()
	self:CleanUI() --
	self:InitData()
end

function SkillItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Skill","SkillItem");

	self.button = self.ui:GetController("button")
	self.img_alpha_bg = self.ui:GetChild("img_alpha_bg")
	self.img_select_bg = self.ui:GetChild("img_select_bg")
	self.img_arrow = self.ui:GetChild("img_arrow")
	self.loader_icon = self.ui:GetChild("loader_icon")
	self.group_skill_icon = self.ui:GetChild("group_skill_icon")
	self.img_bg_lev = self.ui:GetChild("img_bg_lev")
	self.label_lev = self.ui:GetChild("label_lev")
	self.group_skill_lev = self.ui:GetChild("group_skill_lev")
	self.img_skill_icon_border = self.ui:GetChild("img_skill_icon_border")
	self.effect_root = self.ui:GetChild("effect_root")

end

function SkillItem.Create(ui, ...)
	return SkillItem.New(ui, "#", {...})
end

function SkillItem:__delete()
	self.skillData = nil
	self.model = nil
	self:CleanUI()
	self:CleanEffect()
end

function SkillItem:InitData()
	self.skillData = {}
	self.model = SkillModel:GetInstance()
	self.effectObj = nil
end

function SkillItem:SetData(data)
	self.skillData = data or {}
end

function SkillItem:SetUI()
	if not TableIsEmpty(self.skillData) then
		
		local isHas = self.model:IsHasSkill(self.skillData.skillId)
		local strLev = ""
		self.loader_icon.url = "Icon/Skill/"..self.skillData.iconID
		if not isHas then
			strLev = "0级"
		else
			strLev = StringFormat("{0}级" , self.skillData.level)
		end
		self.label_lev.text = strLev
		self:SetGrayed(not isHas)

		local IsCanUpgrade = self.model:IsCanUpgrade(self.skillData.skillId)
		self:SetUpgradeArrowUI(IsCanUpgrade)
		
	end
end

function SkillItem:CleanUI()
	self.img_alpha_bg.visible = false
	self.img_select_bg.visible = false
	self.img_arrow.visible = false
	self.loader_icon.url = ""
	self.label_lev.text = ""
end

function SkillItem:SetSelectUI(bl)
	self.img_select_bg.visible = bl
end

function SkillItem:SetUpgradeArrowUI(bl)
	self.img_arrow.visible = bl
end


function SkillItem:LoadEffect()
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

function SkillItem:CleanEffect()
	if self.effectObj ~= nil then
		destroyImmediate(self.effectObj)
		self.effectObj = nil
	end
end

--如果是铭文技能，需要使能透明底图，和特效
function SkillItem:SetEffect()
	if not TableIsEmpty(self.skillData) then
		if self.model:IsMWSkill(self.skillData.skillId) == true then
			self:LoadEffect()
			self.img_alpha_bg.visible = true
		else
			self:CleanEffect()
			self.img_alpha_bg.visible = false
		end
	end
end