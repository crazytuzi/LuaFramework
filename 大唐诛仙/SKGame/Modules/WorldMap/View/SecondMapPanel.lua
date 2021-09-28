SecondMapPanel = BaseClass(BaseView)
function SecondMapPanel:__init( ... )
	self.ui = UIPackage.CreateObject("WorldMaps","SecondMapPanel")
	self.exitBtn = self.ui:GetChild("exitBtn")
	self.changeWorMapBtn = self.ui:GetChild("changeWorMapBtn")
	self.mapRoad = self.ui:GetChild("mapRoad")
	self.mapScale = self.ui:GetChild("mapScale")
	self.signContain = self.ui:GetChild("signContain")
	self.touchLay = self.ui:GetChild("touchLay")
	self.id = "SecondMapPanel"

	self.npcIconList = {}
	self.transferIconList = {}
	self.teamIconList = {}
	self.bossIconList = {}
	self.playerIconUI = nil
	self.targetIcon = nil
	self.mainPlayer = nil
	self.offSet = 0

	self:SendSynBoss() --发送获取boss怪物状态
	self:GetZiJi()
	self.root = layerMgr:GetUILayer()
	self.model = WorldMapModel:GetInstance()
	self.mapRoad.url = self.model.mapRoadURL
	self:GetScale()
	self:InitEvent()
	self:AddEvent()
end

function SecondMapPanel:InitEvent()
	self.exitBtn.onClick:Add(function ()
		self:Close()
	end)
	self.changeWorMapBtn.onClick:Add(function ()
		WorldMapController:GetInstance():Open(1)
	end)
	self.touchLay.onTouchBegin:Add(function (evt)
		if self.targetIcon then
			self.targetIcon:RemoveFromParent()
			destroyUI(self.targetIcon)
		end
		self.targetIcon = nil
		self:TouchXunlu(evt)
	end)
	self.openCallback = function() 
		self:SetMapIcon()
		self:SetTeamIcon()
		self:Update()
	end
end

function SecondMapPanel:GetScale()
	self.offSet = layerMgr.WIDTH - (layerMgr.WIDTH - self.mapRoad.width)*0.5
	local bili_width = self.offSet/(self.mapRoad.width)
	local bili_height = layerMgr.HEIGHT/(self.mapRoad.height)
	if (bili_height >= 1 and bili_width >= 1) or (bili_height < 1 and bili_width < 1) then
		if bili_height < bili_width then
			self.scale = bili_height        
		else
			self.scale = bili_width
		end
	elseif bili_height <= 1 and bili_width >= 1 then
		self.scale = bili_height			   
	elseif bili_height > 1 and bili_width < 1 then
		self.scale = bili_width
	end
end

function SecondMapPanel:GetZiJi()
	local scene = SceneController:GetInstance():GetScene()
	self.mainPlayer = scene.mainPlayer
end

function SecondMapPanel:SendSynBoss()
	local mapId = SceneModel:GetInstance().sceneId
	if mapId >= 2001 and mapId <= 2009 then
		SceneController:GetInstance():C_SynMonsterState()
	end
end

function SecondMapPanel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.Player_AutoRunEnd, function()
		if self.targetIcon then
			self.targetIcon:RemoveFromParent()
			destroyUI(self.targetIcon)
		end
		self.targetIcon = nil
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.TEAM_CHANGED, function()
		if self.teamIconList then
		for i,v in ipairs(self.teamIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.teamIconList = {}
	end
		self:SetTeamIcon()
	end)

	self.handler2 = self.model:AddEventListener(WorldMapConst.BossStateChange, function()
		self:SetBossIcon()
	end)
end

function SecondMapPanel:SetBossIcon()
	--self.signContain:GetChild("BossIcon")
	for k,v in ipairs(self.model.bossList) do
		for i,p in ipairs(self.model.bossState) do
			if p.refreshId == v[1] then
				if p.state == 0 then
					self.signContain:GetChild("BossIcon").grayed = false
			else
					self.signContain:GetChild("BossIcon").grayed = true
				end
			end
		end
	end
end

function SecondMapPanel:Start()
	RenderMgr.Add(function () self:Update() end, "MapRender")
end

function SecondMapPanel:Pause()
	RenderMgr.Realse("MapRender")
end

function SecondMapPanel:Update()
	local pos = SceneModel:GetInstance():GetMainPlayerPos()
	self.model.playerPos = pos

	if pos then
		self.playerIconUI:SetXY(pos.x*10*self.scale, pos.z*10*self.scale)
	end
	if #self.teamIconList > 0 then
		if self.teamIconList then
		for i,v in ipairs(self.teamIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.teamIconList = {}
		end
	end
	self:SetTeamIcon()
end

function SecondMapPanel:SetMapIcon()
	self.mapRoad:SetScale(-self.scale, self.scale)
	self.mapRoad:SetXY(self.offSet, 0)
	self.signContain:SetXY(self.mapRoad.x, self.mapRoad.y)
	self.signContain:SetSize(self.mapRoad.width, self.mapRoad.height)
	if #self.model.NpcPosList > 0 then
		for k,v in ipairs(self.model.NpcPosList) do
			local npcIcon = UIPackage.CreateObject("WorldMaps" , "NpcIcon")
			if v[1] == 1 then
				npcIcon.icon = "Icon/Map/NPC_0"
				npcIcon.title = v[2]
			elseif v[1] == 2 then
				npcIcon.icon = "Icon/Map/NPC_1"
				npcIcon.title = v[2]
			end
			npcIcon:SetScale(-1, 1)
			npcIcon:SetXY(v[3][1]*10*(self.scale), v[3][3]*10*(self.scale))
			self.signContain:AddChild(npcIcon)
			table.insert(self.npcIconList, npcIcon)
		end
	end

	if #self.model.transferPosList > 0 then
		for k,v in ipairs(self.model.transferPosList) do
			local transferIcon = UIPackage.CreateObject("WorldMaps" , "TransferIcon")
			transferIcon:GetChild("title").text = v[1]
			transferIcon:SetScale(-1,1)
			transferIcon:SetXY(v[2][1]*10*(self.scale), v[2][3]*10*(self.scale))
			self.signContain:AddChild(transferIcon)
			table.insert(self.transferIconList, transferIcon)
		end
	end
	if #self.model.bossList > 0 then
		for k,v in ipairs(self.model.bossList) do
			local bossIcon = UIPackage.CreateObject("WorldMaps" , "BossIcon")
			bossIcon.name = "BossIcon"
			bossIcon:SetScale(-1,1)
			for i,p in ipairs(self.model.bossState) do
				if p.refreshId == v[1] then
					if p.state == 0 then
						bossIcon.grayed = false
					else
						bossIcon.grayed = true
					end
				end
			end
			bossIcon:SetXY(v[2][1]*10*self.scale, v[2][3]*10*self.scale)
			self.signContain:AddChild(bossIcon)
			table.insert(self.bossIconList, bossIcon)
		end
	end
	
	self.playerIconUI = PlayerIcon.New()
	self.signContain:AddChild(self.playerIconUI.ui)
	self:Start()
end

function SecondMapPanel:TouchXunlu(evt)
	local scene = SceneController:GetInstance():GetScene()
	if self.mainPlayer then
		scene:StopAutoFight(false) --停止自动战斗
	end

	-- local model = SceneModel:GetInstance()
	local data = evt.data
	local v2 = self.root:GlobalToLocal(Vector2.New(data.x, data.y))
	local uiZB = Vector3.New((self.offSet-v2.x)/(self.scale)/10, v2.y/(self.scale)/10)
	local targetZB = Vector3.New(uiZB.x, 0, uiZB.y)
	local gx, gy = MapUtil.LocalToGrid(targetZB)
	if Astar.isBlock(gx, gy) then
		return	
	end
	self.targetIcon = UIPackage.CreateObject("WorldMaps" , "TargetAnima")
	self.targetIcon:SetXY(self.offSet-v2.x, v2.y)
	self.signContain:AddChild(self.targetIcon)
	local mainPlayerObj = scene:GetMainPlayer()
	if mainPlayerObj then
		mainPlayerObj:Reset()
		GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity)
		mainPlayerObj:MoveToPositionByAgent(targetZB)
		GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
	end

end

function SecondMapPanel:SetTeamIcon()
	local teamlist = WorldMapModel:GetInstance().teamPlayerList
	if #teamlist > 0 then
		for i,v in ipairs(teamlist) do
			local guid = nil
			for k,j in pairs(SceneModel:GetInstance().playerList) do
				if j.playerId == v.playerId then
					guid = k
				end
			end
			if guid then
				if not SceneModel:GetInstance():IsMainPlayer(guid) then
					local v3 = SceneModel:GetInstance():GetPlayerPos(guid)
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
						self.signContain:AddChild(teamIcon)
						table.insert(self.teamIconList, teamIcon)
					end
				end
			end
		end
	end
end

function SecondMapPanel:__delete()
	RenderMgr.Realse("MapRender")
	if self.model then
		self.model:RemoveEventListener(self.handler2)
	end
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
	if self.playerIconUI then
		self.playerIconUI:Destroy()
		self.playerIconUI = nil
	end
	if self.targetIcon then
		self.targetIcon:Destroy()
	end
	if self.bossIconList then
		for i,v in ipairs(self.bossIconList) do
			v:RemoveFromParent()
			destroyUI(v)
		end
		self.bossIconList = nil
	end
	self.targetIcon = nil
end