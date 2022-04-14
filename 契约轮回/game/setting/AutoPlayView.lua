AutoPlayView = AutoPlayView or class("AutoPlayView",BaseItem)
local AutoPlayView = AutoPlayView
local tableInsert = table.insert

function AutoPlayView:ctor(parent_node,layer)
	self.abName = "autoplay"
	self.assetName = "AutoPlayView"
	self.layer = layer

	self.model = SettingModel:GetInstance()
	AutoPlayView.super.Load(self)

	self.skill_item = {}
end

function AutoPlayView:dctor()
	if self.event_id then
		self.model:RemoveListener(self.event_id)
	end

	for i=1, #self.skill_item do
		self.skill_item[i]:destroy()
	end
end

function AutoPlayView:LoadCallBack()
	self.nodes = {
		"range/ToggleNormal","range/TogglePoint","pickup/pick1","pickup/pick2","pickup/pick3","pickup/pick4",
		"autoeat/eatclose","autoeat/eatopen","bg/hours","addbutton","start","max_hours","ScrollView/Viewport/Content",
		"ScrollView/Viewport/Content/AutoPlaySkillItem",
	}
	self:GetChildren(self.nodes)
	self.hours = GetText(self.hours)
	self.max_hours = GetText(self.max_hours)
	self.AutoPlaySkillItem_gameobject = self.AutoPlaySkillItem.gameObject
	SetVisible(self.AutoPlaySkillItem_gameobject, false)
	self.pick1_t = self.pick1:GetComponent("Toggle")
	self.pick2_t = self.pick2:GetComponent("Toggle")
	self.pick3_t = self.pick3:GetComponent("Toggle")
	self.pick4_t = self.pick4:GetComponent("Toggle")
	self.eatclose_t = GetToggle(self.eatclose)
	self.eatopen_t = GetToggle(self.eatopen)
	self:AddEvent()

	self:UpdateView()
end

function AutoPlayView:AddEvent()
	local function call_back()
		self.hours.text = self.model:GetAfkTime()
	end
	self.event_id = self.model:AddListener(SettingEvent.UpdateAfkInfo, call_back)

	local function call_back(target,x,y)
		
	end
	AddClickEvent(self.start.gameObject,call_back)

	local function call_back(target,x,y)
		self.model:AddAfkTime()
	end
	AddClickEvent(self.addbutton.gameObject,call_back)

	local function call_back(target, value)
		local flag = (value and 1 or 0)
		self.model:SetPickup(1, flag)
	end
	AddValueChange(self.pick1.gameObject, call_back)

	local function call_back(target, value)
		local flag = (value and 1 or 0)
		self.model:SetPickup(2, flag)
	end
	AddValueChange(self.pick2.gameObject, call_back)

	local function call_back(target, value)
		local flag = (value and 1 or 0)
		self.model:SetPickup(3, flag)
	end
	AddValueChange(self.pick3.gameObject, call_back)

	local function call_back(target, value)
		local flag = (value and 1 or 0)
		self.model:SetPickup(4, flag)
	end
	AddValueChange(self.pick4.gameObject, call_back)

	local function call_back(target, value)
		if value then
			self.model:SetSmelt(0)
		end
	end
	AddValueChange(self.eatclose.gameObject, call_back)

	local function call_back(target, value)
		if value then
			self.model:SetSmelt(1)
		end
	end
	AddValueChange(self.eatopen.gameObject, call_back)
end

function AutoPlayView:SetData(data)

end

function AutoPlayView:UpdateView( )
	local val = String2Table(Config.db_game["afk_max_time"].val)[1]
	self.max_hours.text = string.format("(%dh at most)", tonumber(val)/3600)
	self.hours.text = self.model:GetAfkTime()
	for i=1, #self.skill_item do
		self.skill_item[i]:destroy()
	end
	local skill_list = SkillUIModel:GetInstance():GetSkillList()
	for i=5, 8 do
		if skill_list[i] then
			local item = AutoPlaySkillItem(self.AutoPlaySkillItem_gameobject, self.Content)
			item:SetData(skill_list[i])
			tableInsert(self.skill_item, item)
		end
	end
	local flag = self.model:GetPickup(1)
	self.pick1_t.isOn = (flag == 1)
	flag = self.model:GetPickup(2)
	self.pick2_t.isOn = (flag == 1)
	flag = self.model:GetPickup(3)
	self.pick3_t.isOn = (flag == 1)
	flag = self.model:GetPickup(4)
	self.pick4_t.isOn = (flag == 1)
	local auto_smelt = self.model:GetSmelt()
	self.eatclose_t.isOn = (auto_smelt == 0)
	self.eatopen_t.isOn = (auto_smelt == 1)
end