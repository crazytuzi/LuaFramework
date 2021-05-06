local CMonsterAtkCityDetailPart = class("CMonsterAtkCityDetailPart", CBox)

function CMonsterAtkCityDetailPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_BehindTexture = self:NewUI(2, CTexture)
	self.m_MapTexture = self:NewUI(3, CTexture)
	self.m_MapTextureBg = self:NewUI(4, CSprite)
	self.m_MonsterNode = self:NewUI(5, CWidget)
	self.m_MonsterBox = self:NewUI(6, CBox)
	self.m_NpcBox = self:NewUI(8, CBox)
	self.m_TranserBox = self:NewUI(10, CBox)
	self.m_OriginNode = self:NewUI(11, CWidget)
	self.m_GoToLabel = self:NewUI(12, CLabel)
	self.m_FootNode = self:NewUI(13, CObject)
	self.m_FootClone = self:NewUI(14, CSprite)
	self.m_MapID = nil
	self.m_SceneID = nil
	self.m_ResID = nil
	self.m_MonsterBoxDic = {}
	self.m_NpcBoxList = {}
	self.m_TranserBoxList = {}
	self.m_FootList = {}
	self.m_ParentView = nil
	self.m_MonsterDepth = 100
	self:InitContent()
end

function CMonsterAtkCityDetailPart.InitContent(self)
	self.m_MonsterBox:SetActive(false)
	self.m_NpcBox:SetActive(false)
	self.m_TranserBox:SetActive(false)
	self.m_FootClone:SetActive(false)
	self.m_BehindTexture:AddUIEvent("click", callback(self, "ShowPart", false))
	self.m_GoToLabel:AddUIEvent("click", callback(self, "OnGoTo"))
	self.m_MapTexture:AddUIEvent("click", callback(self, "OnClickMapTexture"))	
	g_MonsterAtkCityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMonsterAtkCityEvnet"))
end

function CMonsterAtkCityDetailPart.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CMonsterAtkCityDetailPart.OnMonsterAtkCityEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.MonsterAtkCity.Event.AddMonster then
		if oCtrl.m_EventData then
			self:AddMonsterBox(oCtrl.m_EventData)
		end
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.DelMonster then
		if oCtrl.m_EventData then
			self:DelMonsterBox(oCtrl.m_EventData)
		end
	end
end

function CMonsterAtkCityDetailPart.Clear(self)
	for k,oMonsterBox in pairs(self.m_MonsterBoxDic) do
		self:DelMonsterBox(oMonsterBox.m_Npcid)
	end
	for i,v in ipairs(self.m_NpcBoxList) do
		v:Destroy()
	end
	for i,v in ipairs(self.m_TranserBoxList) do
		v:Destroy()
	end
	for i,v in ipairs(self.m_FootList) do
		v:Destroy()
	end
end

function CMonsterAtkCityDetailPart.ShowPart(self, bShow)
	self:SetActive(bShow)
	if not bShow then
		self:Clear()
	end
end

function CMonsterAtkCityDetailPart.SetCityData(self, oBox)
	self.m_MapID = oBox.m_MapID
	self.m_SceneID = oBox.m_CityID
	self.m_ResID = oBox.m_ResID
	--printc(self.m_MapID, self.m_SceneID, self.m_ResID)
	self:InitMiniMapView(self.m_ResID)
end

function CMonsterAtkCityDetailPart.InitMiniMapView(self, resid)
	self.m_MapTexture:SetActive(false)
	local resid = resid or g_MapCtrl:GetResID() or 1010 
	local pathName = string.format("Map2d/%s/minimap_%s.png", resid, resid)
	local function finishLoadMiniMap(textureRes, errcode)
		if Utils.IsNil(self) then
			return
		end
		if textureRes then
			self.m_MapTexture:SetMainTexture(textureRes)
		else
			return
		end
		self:SetMimiMapSize(textureRes.width , textureRes.height)
	end
	g_ResCtrl:LoadAsync(pathName, finishLoadMiniMap)
end

function CMonsterAtkCityDetailPart.SetMimiMapSize(self, width, height)
	local finalWidth, finalHeight = 0, 0
	-- 适配(横向,定宽 \ 纵向,定高)
	local baseW, baseH = 500, 500
	local ratio = width / height 
	if ratio > 1 then
		finalWidth = baseW
		finalHeight = finalWidth / ratio
		if finalHeight > baseH then
			finalHeight = baseH
			finalWidth = finalHeight * ratio
		end
	else
		finalHeight = baseH
		finalWidth = finalHeight * ratio
	end

	local w = data.mapdata.DATA[self.m_MapID].width
	local h = data.mapdata.DATA[self.m_MapID].height
	self.m_Scene2MapZoomX = w / finalWidth
	self.m_Scene2MapZoomY = h / finalHeight
	self.m_MapTexture:SetPivot(enum.UIWidget.Pivot.Center)
	self.m_MapTexture:SetLocalPos(Vector3.zero)
	self.m_MapTexture:SetSize(finalWidth, finalHeight)
	self.m_MapTexture:SetPivot(enum.UIWidget.Pivot.BottomLeft)
	self.m_MapTexture:SetActive(true)
	self.m_MapTexture.m_UIWidget:ResizeCollider()
	self.m_MapTextureBg:ResetAndUpdateAnchors()
	self.m_MonsterNode:ResetAndUpdateAnchors()
	self.m_OriginNode:ResetAndUpdateAnchors()
	
	self:InitNpcAndTranser()

	self:InitMonster()
	self:CheckDaoBiao()
end

function CMonsterAtkCityDetailPart.InitMonster(self)
	self.m_MonsterBoxDic = {}
	local monsterInfos = g_MonsterAtkCityCtrl:GetMonsterInfos()
	for i,monsterInfo in pairs(monsterInfos) do
		self:CreateMonsterBox(monsterInfo)
	end
end

function CMonsterAtkCityDetailPart.CreateMonsterBox(self, monsterInfo)	
	if monsterInfo.map_id == self.m_MapID then --and monsterInfo.sceneid == self.m_SceneID then
		local pathid = monsterInfo.path_id
		local dData = data.msattackdata.PathConfig[pathid]
		if not dData then 
			return
		end
		local map_path = dData.map_path
		local alive_time = dData.alive_time
		local map_speed = dData.map_speed
		local interval = g_TimeCtrl:GetTimeS() - monsterInfo.createtime
		if interval < alive_time then
			local startPos, starIdx = g_MonsterAtkCityCtrl:GetStartPos(map_path, interval)
			local oMonsterBox = self.m_MonsterBox:Clone()
			oMonsterBox.m_IconSprite = oMonsterBox:NewUI(1, CSprite)
			oMonsterBox.m_BgSprite = oMonsterBox:NewUI(2, CSprite)
			if monsterInfo and monsterInfo.npctype == "middle" then
				oMonsterBox.m_BgSprite:SetSpriteName("pic_monster_bg_2")
			elseif monsterInfo and monsterInfo.npctype == "large" then
				oMonsterBox:SetLocalScale(Vector3.New(1.5, 1.5, 1.5))
				oMonsterBox.m_BgSprite:SetSpriteName("pic_monster_bg_3")
			else
				oMonsterBox.m_BgSprite:SetSpriteName("pic_monster_bg_1")
			end
			self.m_MonsterDepth = self.m_MonsterDepth + 1
			oMonsterBox.m_BgSprite:SetDepth(self.m_MonsterDepth)
			self.m_MonsterDepth = self.m_MonsterDepth + 1
			oMonsterBox.m_IconSprite:SetDepth(self.m_MonsterDepth)
			oMonsterBox.m_Npcid = monsterInfo.npcid
			oMonsterBox:SetParent(self.m_MonsterNode.m_Transform)
			oMonsterBox:SetLocalPos(startPos)
			oMonsterBox.m_IconSprite:SpriteAvatar(monsterInfo.model_info.shape)
			oMonsterBox:SetActive(true)
			self.m_MonsterBoxDic[monsterInfo.npcid] = oMonsterBox
			self:CheckMoveMonsterBox(oMonsterBox, starIdx, map_path)
		end
	end
end

function CMonsterAtkCityDetailPart.CheckMoveMonsterBox(self, oMonsterBox, starIdx, map_path)
	if Utils.IsNil(oMonsterBox) then
		return
	end
	starIdx = starIdx + 1
	if map_path[starIdx] then
		self:MoveMonsterBox(oMonsterBox, starIdx, map_path)
	else
		self:DelMonsterBox(oMonsterBox.m_Npcid)
	end
end 

function CMonsterAtkCityDetailPart.MoveMonsterBox(self, oMonsterBox, starIdx, map_path)
	local targetPos = Vector3.New(map_path[starIdx].x, map_path[starIdx].y, 0)
	local interval = map_path[starIdx].time - map_path[starIdx-1].time
	local tween = DOTween.DOLocalMove(oMonsterBox.m_Transform, targetPos, interval)
	DOTween.OnComplete(tween, callback(self, "CheckMoveMonsterBox", oMonsterBox, starIdx, map_path))
end


function CMonsterAtkCityDetailPart.AddMonsterBox(self, npcid)
	local monsterInfo = g_MonsterAtkCityCtrl:GetMonsterInfo(npcid)
	self:CreateMonsterBox(monsterInfo)
end

function CMonsterAtkCityDetailPart.DelMonsterBox(self, npcid)
	local oMonsterBox = self.m_MonsterBoxDic[npcid]
	if oMonsterBox then
		DOTween.DOKill(oMonsterBox.m_Transform, false)
		oMonsterBox:Destroy()
	end
	self.m_MonsterBoxDic[npcid] = nil
end

function CMonsterAtkCityDetailPart.InitNpcAndTranser(self)
	--[[
	self.m_NpcBoxList = {}
	local npclist = DataTools.GetGlobalNpcList(self.m_MapID) or {}
	for i,v in ipairs(npclist) do
		local oNpcBox = self.m_NpcBox:Clone()
		oNpcBox:SetActive(true)
		oNpcBox.m_NameLabel = oNpcBox:NewUI(1, CLabel)
		oNpcBox.m_NameLabel:SetText(v.name)
		oNpcBox:SetParent(self.m_OriginNode.m_Transform)
		local mapPos = self:GetScene2MapPos(Vector3.New(v.x, v.y, v.z))
		oNpcBox:SetLocalPos(mapPos)
		table.insert(self.m_NpcBoxList, oNpcBox)
	end
	]]

	--[[
	self.m_TranserBoxList = {}
	local sceneData = DataTools.GetSceneDataForMapid(self.m_MapID) or {}
	--self.m_TranserBoxList = DataTools.GetSceneDataForMapid(self.m_MapID) or {}
	for i,v in ipairs(sceneData.transfers) do
		local oTranserBox = self.m_TranserBox:Clone()
		oTranserBox:SetActive(true)
		oTranserBox.m_NameLabel = oTranserBox:NewUI(1, CLabel)
		oTranserBox:SetParent(self.m_OriginNode.m_Transform)
		local targetData = DataTools.GetSceneData(v.target_scene)
		oTranserBox.m_NameLabel:SetText(targetData.scene_name)
		local mapPos = self:GetScene2MapPos(Vector3.New(v.x, v.y, 0))
		oTranserBox:SetLocalPos(mapPos)
		table.insert(self.m_TranserBoxList, oTranserBox)
	end
	]]

	local footData
	for k,v in pairs(data.msattackdata.PathConfig) do
		if v.map_id == self.m_MapID then
			footData = v.map_path
		end
	end
	if footData then
		for i=1, #footData, 2 do
			local v = footData[i]
			if v then
				local oFoot = self.m_FootClone:Clone()
				if i == 1 then
					oFoot:SetSpriteName("pic_path_0")
					oFoot:SetSize(32, 22)
				else
					oFoot:SetSpriteName("pic_path_1")
					oFoot:SetSize(7, 7)
				end
				oFoot:SetActive(true)
				oFoot:SetParent(self.m_FootNode.m_Transform)
				oFoot:SetLocalPos(Vector3.New(v.x, v.y, 0))
				table.insert(self.m_FootList, oFoot)
			end
		end
	end
	local v = footData[#footData]
	local oTranserBox = self.m_TranserBox:Clone()
	oTranserBox:SetActive(true)
	oTranserBox.m_NameLabel = oTranserBox:NewUI(1, CLabel)
	oTranserBox.m_NameLabel:SetText("帝都")
	oTranserBox:SetParent(self.m_FootNode.m_Transform)
	oTranserBox:SetLocalPos(Vector3.New(v.x, v.y, 0))
	table.insert(self.m_FootList, oTranserBox)
end

function CMonsterAtkCityDetailPart.CheckDaoBiao(self)
	if g_MonsterAtkCityCtrl.m_DaoBiao then
		local path = {}
		for k,v in pairs(g_MonsterAtkCityCtrl.m_DaoBiao) do
			local oMonsterNpc = g_MonsterAtkCityCtrl:GetMonsterNpc(v.npcid)
			if oMonsterNpc then
				local worldPos = oMonsterNpc:GetPos()
				local mapPos = self:GetScene2MapPos(worldPos)
				local oBox = self.m_MonsterBox:Clone()
				oBox:SetParent(self.m_MonsterNode.m_Transform)
				oBox:SetLocalPos(mapPos)
				oBox:SetActive(true)
				v.mapPos = mapPos
				table.insert(path, v)
			end
		end

		local disInfo = g_MonsterAtkCityCtrl.m_DisInfo
		if disInfo then
			local alive_time = "alive_time="..disInfo.time.."\n"
			local map_dic = "map_dic="..disInfo.dis.."\n"
			local spath = ""
			for i,v in ipairs(disInfo.path) do
				local worldPos = Vector3.New(v.pos.x / 1000, v.pos.y / 1000, 0)
				local mapPos = self:GetScene2MapPos(worldPos)
				spath = spath..
					string.format("%0.3f", mapPos.x)
					.."|"..
					string.format("%0.3f", mapPos.y)
					.."|"..
					string.format("%0.3f", v.time)
					..","
			end
			local map_path = "scene_path="..spath
			local s = "module(...)\n--MonsterAtkCity path build\n"..alive_time..map_dic..map_path
			local savePath = IOTools.GetAssetPath("/MonsterAtkCity/map_path_"..g_MapCtrl:GetMapID())
			IOTools.SaveTextFile(savePath, s)
		end
	end
end

function CMonsterAtkCityDetailPart.GetScene2MapPos(self, keyPos)
	return Vector3.New(keyPos.x / self.m_Scene2MapZoomX, keyPos.y / self.m_Scene2MapZoomY, 0)
end

function CMonsterAtkCityDetailPart.OnGoTo(self, obj)
	local oHero = g_MapCtrl:GetHero()
	if not oHero then
		return
	end
	netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, self.m_MapID)
	self.m_ParentView:CloseView()
end

function CMonsterAtkCityDetailPart.SetMapTimer(self)
	if self.m_MapTimer then
		Utils.DelTimer(self.m_MapTimer)
		self.m_MapTimer = nil
	end
	local function update()
		if Utils.IsNil(self) or not self:GetActive() then
			return false
		end
		for k,oBox in pairs(self.m_MonsterBoxDic) do
			local npcid = oBox.m_Npcid
			local oMonsterNpc = g_MonsterAtkCityCtrl:GetMonsterNpc(npcid)
			if oMonsterNpc then
				local worldPos = oMonsterNpc:GetPos()
				local mapPos = self:GetScene2MapPos(worldPos)
				oBox:SetLocalPos(mapPos)
			end
		end
		return true
	end
	self.m_MapTimer = Utils.AddTimer(update, 0.1, 0.1)
	self:Test()
end

function CMonsterAtkCityDetailPart.Test(self)
	local worldPos = Vector3(29,20,0)
	local mapPos = self:GetScene2MapPos(worldPos)
	table.print(mapPos)
end

function CMonsterAtkCityDetailPart.GetMap2ScenePos(self, keyPos)
	return Vector3.New(keyPos.x * self.m_Scene2MapZoomX, keyPos.y * self.m_Scene2MapZoomY, 0)
end

function CMonsterAtkCityDetailPart.OnClickMapTexture(self)
	if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
		--g_NotifyCtrl:FloatMsg("组队状态下只有队长可操作")
		return
	end

	local oNGUICamera = g_CameraCtrl:GetNGUICamera()
	local oUICamera = g_CameraCtrl:GetUICamera()
	local vTouchPos = oNGUICamera.lastEventPosition
	
	local vTextureWorldPos = oUICamera:ScreenToWorldPoint(Vector3.New(vTouchPos.x, vTouchPos.y, 0))

	local vTextureLocalPos = self.m_MapTexture:InverseTransformPoint(vTextureWorldPos)

	local vGlobalWorldPos = self:GetMap2ScenePos(vTextureLocalPos)

	self:AutoWalk(vGlobalWorldPos, self.m_MapID)
end

function CMonsterAtkCityDetailPart.AutoWalk(self, vPos, mapID)
	local function autowalk()
		local resID = nil
		if data.mapdata.DATA[mapID] then
			resID = data.mapdata.DATA[mapID]["resource_id"]
		end
		
		if g_MapCtrl:GetMapID() ~= mapID or g_MapCtrl.m_MapLoding or resID ~= g_MapCtrl.m_ResID then
			return true
		else
			g_MapTouchCtrl:WalkToPos(vPos)
			self.m_ParentView:CloseView()
		end
	end
	
	local curMapID = g_MapCtrl:GetMapID()
	if g_MapCtrl:GetMapID() ~= mapID then
		local oHero = g_MapCtrl:GetHero()
		netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapID)
		if self.m_AutoWalkTimer then
			Utils.DelTimer(cls.m_AutoWalkTimer)
		end
		self.m_AutoWalkTimer = Utils.AddTimer(autowalk, 0.1, 0.1)
	else
		autowalk()
	end
end

return CMonsterAtkCityDetailPart