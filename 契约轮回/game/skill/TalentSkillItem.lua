TalentSkillItem = TalentSkillItem or class("TalentSkillItem",BaseCloneItem)
local TalentSkillItem = TalentSkillItem

function TalentSkillItem:ctor(obj,parent_node,layer)
	TalentSkillItem.super.Load(self)
end

function TalentSkillItem:dctor()
	self.model:RemoveTabListener(self.events)
	self.events = nil
end

function TalentSkillItem:LoadCallBack()
	self.nodes = {
		"Image","level","selected"
	}
	self:GetChildren(self.nodes)
	self.Image_img = GetImage(self.Image)
	self.level = GetText(self.level)
	self.model = SkillUIModel.GetInstance()
	self:AddEvent()
end

function TalentSkillItem:AddEvent()
	self.events = self.events or {}

	local function call_back(skill_id)
		if skill_id == self.data.id then
			SetVisible(self.selected, true)
		else
			SetVisible(self.selected, false)
		end
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentSelectSkill, call_back)

	local function call_back(skill_id)
		if self.data.id == skill_id then
			local cur_level = self.model.talent_skills[skill_id] or 0
			self.level.text = string.format("%s/%s", cur_level, self.data.level_limit)
			SetGray(self.Image_img, false)
		end
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentUpdateSkill, call_back)

	local function call_back(target,x,y)
		self:Select()
	end
	AddClickEvent(self.Image.gameObject,call_back)
end

--data:talent
function TalentSkillItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function TalentSkillItem:UpdateView( )
	local skill_id = self.data.id
	local pos = String2Table(self.data.pose)
	SetAnchoredPosition(self.transform, pos[1], pos[2])
	local skillcfg = Config.db_skill[skill_id]
	local icon = skillcfg.icon
	local cur_level = self.model.talent_skills[skill_id] or 0
	local function call_back(sp)
		self.Image_img.sprite = sp
		if cur_level == 0 then
			SetGray(self.Image_img, true)
		else
			SetGray(self.Image_img, false)
		end
	end
	lua_resMgr:SetImageTexture(self,self.Image_img, "iconasset/icon_skill", icon, false, call_back)
	
	self.level.text = string.format("%s/%s", cur_level, self.data.level_limit)
end

function TalentSkillItem:Select()
	self.model:Brocast(SkillUIEvent.TalentSelectSkill, self.data.id)
end