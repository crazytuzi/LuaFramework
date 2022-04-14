DungeTeamBossitem = DungeTeamBossitem or class("DungeTeamBossitem",BaseCloneItem)
local DungeTeamBossitem = DungeTeamBossitem

function DungeTeamBossitem:ctor(obj,parent_node,layer)
	DungeTeamBossitem.super.Load(self)
end

function DungeTeamBossitem:dctor()
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
end

function DungeTeamBossitem:LoadCallBack()
	self.nodes = {
		"lock", "lock/openlevel", "title", "jieText", "selected"
	}
	self:GetChildren(self.nodes)
	self.openlevel = GetText(self.openlevel)
	self.title = GetText(self.title)
	self.jieText = GetText(self.jieText)
	self.model = DungeonModel.GetInstance()
	self:AddEvent()
end

function DungeTeamBossitem:AddEvent()
	self.events = self.events or {}

	local function call_back(dunge)
		SetVisible(self.selected, self.data.id == dunge.id)
	end
	self.events[#self.events+1] = self.model:AddListener(DungeonEvent.TeamBossItemClick, call_back)

	local function call_back(target,x,y)
		self.model:Brocast(DungeonEvent.TeamBossItemClick, self.data)
	end
	AddClickEvent(self.gameObject,call_back)
end

function DungeTeamBossitem:SetData(data)
	self.data = data
	self:UpdateView()
end

function DungeTeamBossitem:UpdateView()
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    if level < self.data.level then
    	SetVisible(self.lock, true)
    	SetVisible(self.title, false)
    	self.openlevel.text = string.format("<color=#ff3939>%s</color>", GetLevelShow(self.data.level))
    else
    	SetVisible(self.lock, false)
    	SetVisible(self.title, true)
    	self.title.text = self.data.name_scale
    end
    self.jieText.text = string.format("T%s", self.data.order or 1)
end
