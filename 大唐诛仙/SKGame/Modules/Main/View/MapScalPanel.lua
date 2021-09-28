MapScalPanel = BaseClass(LuaUI)
function MapScalPanel:__init( ... )
	self.URL = "ui://0042gnit9l3bet"
	self:__property(...)
	self:Config()
	self:AddEvent()

end
function MapScalPanel:SetProperty( ... )
end
function MapScalPanel:Config()
	self.worldModel = WorldMapModel:GetInstance()
	self.sceneModel=SceneModel:GetInstance()
	self.npcIconList = {}
	self.transferIconList = {}
	self.teamIconList = {}
	self.bossIconList = {}
	self.scale = 0.5
	self:Start()
end

function MapScalPanel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
		self.mapRoad1.url = self.worldModel.mapRoadURL
		self.signContain1:SetSize(self.mapRoad1.width, self.mapRoad1.height)
		self.mapRoad1:SetScale(-self.scale, self.scale)          --------------------------------------------------------------------------------------
		if self.npcIconList then 
			for i,v in ipairs(self.npcIconList) do
				v:RemoveFromParent()
				destroyUI(v)
			end
			self.npcIconList = {}
		end
		if self.transferIconList then
			for i,v in ipairs(self.transferIconList) do
				v:RemoveFromParent()
				destroyUI(v)
			end
			self.transferIconList = {}
		end
		if self.teamIconList then
			for i,v in ipairs(self.teamIconList) do
				v:RemoveFromParent()
				destroyUI(v)
			end
			self.teamIconList = {}
		end
		if self.bossIconList then
			for i,v in ipairs(self.bossIconList) do
				v:RemoveFromParent()
				destroyUI(v)
			end
			self.bossIconList = {}
		end
		self:SetPos()
		self:SetTeamIcon1()
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.TEAM_CHANGED, function()
		if self.teamIconList then
		for i,v in ipairs(self.teamIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.teamIconList = {}
	end
		self:SetTeamIcon1()
	end)
end

function MapScalPanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","MapScalPanel");

	self.mapRoad1 = self.ui:GetChild("mapRoad1")
	self.signContain1 = self.ui:GetChild("signContain1")
end

function MapScalPanel:Start()
	RenderMgr.Add(function () self:Update() end, "MapRender1")
end

function MapScalPanel:Pause()
	RenderMgr.Realse("MapRender1")
end

function MapScalPanel:Update()
	if #self.teamIconList > 0 then
		if self.teamIconList then
		for i,v in ipairs(self.teamIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.teamIconList = {}
	end
		self:SetTeamIcon1()
	end
	if self.signContain1:GetChild("BossIcon") then
		if self.worldModel.isRemoveBoss then
		    self.signContain1:GetChild("BossIcon").grayed = true              --boss离场 或死亡
		else
			self.signContain1:GetChild("BossIcon").grayed = false
		end
	end
end

function MapScalPanel:SetPos()
	
	self.signContain1:SetSize(self.mapRoad1.width, self.mapRoad1.height)
	local npcList = self.worldModel.NpcPosList
	local transferList = self.worldModel.transferPosList
	local bossList = self.worldModel.bossList
	if #npcList > 0 then
		for k,v in ipairs(npcList) do
			local npcIcon = UIPackage.CreateObject("WorldMaps" , "NpcIcon")
			if v[1] == 1 then
				npcIcon.icon = " "
				npcIcon.title = " "
			elseif v[1] == 2 then
				npcIcon.icon = "Icon/Map/NPC_1"
				npcIcon.title = v[2]
			end
			npcIcon:SetScale(-0.8, 0.8)
			npcIcon:SetXY(v[3][1]*10*self.scale, v[3][3]*10*self.scale)
			self.signContain1:AddChild(npcIcon)
			table.insert(self.npcIconList, npcIcon)
		end
	end

	if #transferList > 0 then
		for k,v in ipairs(transferList) do
			local transferIcon = UIPackage.CreateObject("WorldMaps" , "TransferIcon")
			transferIcon:GetChild("title").text = v[1]
			transferIcon:SetScale(-0.8,0.8)
			transferIcon:SetXY(v[2][1]*10*self.scale, v[2][3]*10*self.scale)
			self.signContain1:AddChild(transferIcon)
			table.insert(self.transferIconList, transferIcon)
		end
	end	
	if #bossList > 0 then
		for k,v in ipairs(bossList) do
			local bossIcon = UIPackage.CreateObject("WorldMaps" , "BossIcon")
			bossIcon.name = "BossIcon"
			bossIcon:SetScale(-0.8,0.8)
			bossIcon:SetXY(v[2][1]*10*self.scale, v[2][3]*10*self.scale)
			self.signContain1:AddChild(bossIcon)
			table.insert(self.transferIconList, bossIcon)
		end
	end
end

function MapScalPanel:SetTeamIcon1()
	local teamlist = self.worldModel.teamPlayerList
	if #teamlist > 0 then
		for i,v in ipairs(teamlist) do
			local guid = nil
			for k,j in pairs(self.sceneModel.playerList) do
				if j.playerId == v.playerId then
					guid = k
				end
			end
			if not self.sceneModel:IsMainPlayer(guid) then
				local v3 = self.sceneModel:GetPlayerPos(guid)
				if v3 then
					local teamIcon = UIPackage.CreateObject("WorldMaps" , "TeamFlag")
					local learderId = ZDModel:GetInstance():GetLeaderId()
					if learderId == v.playerId then
						teamIcon:GetChild("icon").url = "Icon/Map/team_0"
					else
						teamIcon:GetChild("icon").url = "Icon/Map/team_1"
					end
					teamIcon:SetXY(v3.x*10*self.scale, v3.z*10*self.scale)
					teamIcon:SetScale(-1,1)
					self.signContain1:AddChild(teamIcon)
					table.insert(self.teamIconList, teamIcon)
				end
			end
		end
	end
end

-- Combining existing UI generates a class
function MapScalPanel.Create( ui, ...)
	return MapScalPanel.New(ui, "#", {...})
end
function MapScalPanel:__delete()
	RenderMgr.Realse("MapRender1")
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	if self.npcIconList then
		for i,v in ipairs(self.npcIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.npcIconList = nil
	end
	if self.transferIconList then
		for i,v in ipairs(self.transferIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.transferIconList = nil
	end
	if self.teamIconList then
		for i,v in ipairs(self.teamIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.teamIconList = nil
	end
	if self.bossIconList then
		for i,v in ipairs(self.bossIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.bossIconList = nil
	end
end