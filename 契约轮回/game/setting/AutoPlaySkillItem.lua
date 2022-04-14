AutoPlaySkillItem = AutoPlaySkillItem or class("AutoPlaySkillItem",BaseCloneItem)
local AutoPlaySkillItem = AutoPlaySkillItem

function AutoPlaySkillItem:ctor(obj,parent_node,layer)
	AutoPlaySkillItem.super.Load(self)
end

function AutoPlaySkillItem:dctor()
end

function AutoPlaySkillItem:LoadCallBack()
	self.nodes = {
		"skillbg/skillicon","ToggleNormal",
	}
	self:GetChildren(self.nodes)
	self.skillicon = GetImage(self.skillicon)
	self.ToggleNormal = self.ToggleNormal:GetComponent("Toggle")
	self:AddEvent()
end

function AutoPlaySkillItem:AddEvent()
end

--data:p_skill
function AutoPlaySkillItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function AutoPlaySkillItem:UpdateView()
	lua_resMgr:SetImageTexture(self,self.skillicon, 'iconasset/icon_skill', self.data.id, true)
	self.ToggleNormal.isOn = SkillUIModel:GetInstance():IsAutoUseSkill(self.data.id)
end