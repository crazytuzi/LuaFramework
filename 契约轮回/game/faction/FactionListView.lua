--
-- @Author: chk
-- @Date:   2018-12-05 10:56:51
--
FactionListView = FactionListView or class("FactionListView",BaseItem)
local FactionListView = FactionListView

function FactionListView:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionListView"
	self.layer = layer
	self.events = {}
	self.notShowItems = {}
	self.items = {}
	self.model = FactionModel:GetInstance()
	FactionListView.super.Load(self)
end

function FactionListView:dctor()
	self.model:RemoveTabListener(self.events)
	for i, v in pairs(self.items) do
		v:destroy()
	end
	self.items = {}
	if self.emptyGirl  then
		self.emptyGirl:destroy()
	end
end

function FactionListView:LoadCallBack()
	self.nodes = {
		"emptyGirlCon",
		"Search/SearchBtn",
		"Search/SearchIpt",
		"CreateBtn",
		"AppBtn",
		"Scroll View/Viewport/Content",
	}
	self:GetChildren(self.nodes)
	self.SearchIptIpt = self.SearchIpt:GetComponent('InputField')

	self:AddEvent()

	FactionController.GetInstance():RequestFactionList()
end

function FactionListView:AddEvent()
	local function call_back()
		lua_panelMgr:GetInstance():GetPanelOrCreate(FactionCreatePanel):Open()
	end
	AddClickEvent(self.CreateBtn.gameObject,call_back)

	--local function call_back()
	--self.SearchIptIpt.onValueChange.AddListener(call_back)
	local function call_back()
		local factionIds = self.model:GetAllCanApplyFactionids()
		for i, v in pairs(factionIds or {}) do
			FactionController.Instance:RequestApplyEnterFaction(v)
		end
	end
	AddClickEvent(self.AppBtn.gameObject,call_back)

	local function call_back()
		self:SearchFaction(self.SearchIptIpt.text)
	end

	AddClickEvent(self.SearchBtn.gameObject,call_back)
	self.events[#self.events + 1] = self.model:AddListener(FactionEvent.FactionList,handler(self,self.UpdateView))
end

function FactionListView:SetData(data)

end

function FactionListView:SearchFaction(name)
	for i, v in pairs(self.notShowItems) do
		SetVisible(v.gameObject,true)
	end

	self.notShowItems = {}
	if name ~= "" then
		for i, v in pairs(self.items) do
			local str = string.match(v.data.name,name)
			if  str == nil then
				table.insert(self.notShowItems,v)
			end
		end
	end


	for i, v in pairs(self.notShowItems) do
		SetVisible(v.gameObject,false)
	end

	if table.nums(self.notShowItems) <= 0 then
		for i, v in pairs(self.items) do
			SetVisible(v.gameObject,true)
		end
	end
end

function FactionListView:UpdateView()
	if table.nums(self.model.factionLst) <= 0 then
		if self.emptyGirl == nil then
			self.emptyGirl = EmptyGirl(self.emptyGirlCon,ConfigLanguage.Faction.FstCreateFaction)
		end
	else
		for i, v in pairs(self.items) do
			v:destroy()
		end

		self.items = {}
		for i, v in pairs(self.model.factionLst) do
			local item = FactionListItemSettor(self.Content,"UI",i)
			item:SetData(v)
			table.insert(self.items,item)
		end
	end
end