TalentGroupItem = TalentGroupItem or class("TalentGroupItem",BaseCloneItem)
local TalentGroupItem = TalentGroupItem

function TalentGroupItem:ctor(obj,parent_node,layer)
	TalentGroupItem.super.Load(self)
end

function TalentGroupItem:dctor()
	self.model:RemoveTabListener(self.events)
	self.events = nil
end

function TalentGroupItem:LoadCallBack()
	self.nodes = {
		"Image", "selected", "level"
	}
	self:GetChildren(self.nodes)
	self.Image_img = GetImage(self.Image)
	self.selected_img = GetImage(self.selected)
	self.level = GetText(self.level)
	self.model = SkillUIModel.GetInstance()
	self:AddEvent()
end

function TalentGroupItem:AddEvent()
	self.events = self.events or {}

	local function call_back(group)
		if group==self.data then
			SetVisible(self.selected, true)
			lua_resMgr:SetImageTexture(self,self.selected_img, 'skill_image', self:GetRes(group), true)
		else
			SetVisible(self.selected, false)
		end
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentSelectGroup, call_back)

	local function call_back()
		self.level.text = self.model:GetTotalPoint(self.data)
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentUpdateSkill, call_back)
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentUpdateInfo, call_back)

	local function call_back(target,x,y)
		self:Select()
	end
	AddClickEvent(self.Image.gameObject,call_back)
end

--data:group
function TalentGroupItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function TalentGroupItem:Select()
	--SkillUIController:GetInstance():RequestTalentInfo(self.data)
	self.model:Brocast(SkillUIEvent.TalentSelectGroup, self.data)
end

function TalentGroupItem:UpdateView()
	local res, res2 = "", ""
	if self.data == 1 then
		res = "talent_fight"
		res2 = "talent_fight2"
	elseif self.data == 2 then
		res = "talent_guide"
		res2 = "talent_guide2"
	else
		res = "talent_base"
		res2 = "talent_base2"
	end

	lua_resMgr:SetImageTexture(self,self.Image_img, 'skill_image', res,true)
	self.level.text = self.model:GetTotalPoint(self.data)
end

function TalentGroupItem:GetRes(group)
	local res
	if self.data == 1 then
		res = "talent_fight2"
	elseif self.data == 2 then
		res = "talent_guide2"
	else
		res = "talent_base2"
	end
	return res
end