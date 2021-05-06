local CMiniMapPage = class("CMiniMap",CPageBase)

function CMiniMapPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMiniMapPage.OnInitPage(self)	
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SwitchBtn = self:NewUI(2, CButton)
	self.m_SearchBtn = self:NewUI(3, CButton)
	self.m_PlayerInfoOrigin = self:NewUI(4, CWidget)
	self.m_PlayerIcon = self:NewUI(5, CSprite)
	self.m_TargetPoint = self:NewUI(6, CWidget)
	self.m_TargetLabel = self:NewUI(7, CLabel)
	self.m_FootPointList = self:NewUI(8, CObject)
	self.m_PointClone = self:NewUI(9, CObject)
	self.m_MapTexture = self:NewUI(10, CTexture)
	self.m_MapTextureBg = self:NewUI(11, CSprite)
	self.m_NpcBoxListNode = self:NewUI(12,CObject)
	self.m_NpcBoxListGrid = self:NewUI(13, CGrid)
	self.m_NpcSeachBoxClone = self:NewUI(14, CBox)
	self.m_TeleportShortNameNode = self:NewUI(15, CObject)
	self.m_TeleportShortNameBoxClone = self:NewUI(16, CBox)
	self.m_NpcShortNameNode = self:NewUI(17, CObject)
	self.m_NpcShortNameBoxClone = self:NewUI(18, CBox)
	self.m_MapName = self:NewUI(19, CLabel)
	self.m_Container = self:NewUI(20, CWidget)
	self.m_OrgWarPart = self:NewUI(21, CBox)
	self.m_OrgPreparePart = self:NewUI(22, CBox)
	
	g_GuideCtrl:AddGuideUI("map_world_map_btn", self.m_SwitchBtn)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnSwitchMapBtn"))
	self.m_SearchBtn:AddUIEvent("click", callback(self, "OnSearchBtn"))
	self.m_MapTexture:AddUIEvent("click", callback(self, "OnClickMapTexture"))	
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnClose"))
	g_UITouchCtrl:TouchOutDetect(self.m_NpcBoxListNode, callback(self.m_NpcBoxListNode, "SetActive", false))
	
	self.m_CloseBtn:SetActive(false)
	self.m_SwitchBtn:SetActive(false)
	self.m_SearchBtn:SetActive(false)
	self.m_PlayerIcon:SetActive(false)
	self.m_TargetPoint:SetActive(false)
	self.m_PointClone:SetActive(false)
	self.m_PointClone:SetActive(false)
	self.m_MapTextureBg:SetActive(false)
	self.m_NpcBoxListNode:SetActive(false)
	self.m_NpcSeachBoxClone:SetActive(false)
	self.m_TeleportShortNameBoxClone:SetActive(false)
	self.m_NpcShortNameBoxClone:SetActive(false)

	self.m_Distances = 2
	-- 宽高比例（默认1.33）
	self.m_MiniMapRatio = 1.33
	self.m_Scene2MapZoomX = 1
	self.m_Scene2MapZoomY = 1

	-- 路径点ObjList\总路径点\当前走过的点
	self.m_FootPointObjList = {}
	self.m_FootPointCount = 0
	self.m_FootPointIndex = 1

	self.m_MiniMapTimer = nil
	self.m_FinishTexture = false

	-- TODO 传送点列表

	-- 场景Npc数据列表
	self.m_globalNpcList = {}
	self.m_shortNameNpcList = {}
	self.m_NpcInfoBoxList = {}

	UITools.ResizeToRootSize(self.m_Container)
	self:SetupMiniPage()
	self:InitMiniMapView()
end

-- EventCallback
function CMiniMapPage.OnClose(self)
	self.m_ParentView:CloseView()
end

function CMiniMapPage.OnSwitchMapBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("world_map") then
		self.m_ParentView:ShowSpecificPage(1)
	end	
end

function CMiniMapPage.OnSearchBtn(self)
	if g_ActivityCtrl:ActivityBlockContrl("world_npc") then
		if self.m_NpcBoxListNode:GetActive() then
			self.m_NpcBoxListNode:SetActive(false)
		else
			self:SetSearchInfo()
		end
	end	
end

function CMiniMapPage.OnClickMapTexture(self)
	if g_StateCtrl:GetState(1005) and g_ActivityCtrl:InWorldBossFB() then
		g_NotifyCtrl:FloatMsg("死亡状态下不可移动")
		return
	end

	if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
		g_NotifyCtrl:FloatMsg("组队状态下只有队长可操作")
		return
	end

	if not g_ActivityCtrl:ActivityBlockContrl("map_click") then
	 	return
	end

	self:HideFootPoints(#self.m_FootPointObjList)

	local oNGUICamera = g_CameraCtrl:GetNGUICamera()
	local oUICamera = g_CameraCtrl:GetUICamera()
	local vTouchPos = oNGUICamera.lastEventPosition
	
	local vTextureWorldPos = oUICamera:ScreenToWorldPoint(Vector3.New(vTouchPos.x, vTouchPos.y, 0))

	local vTextureLocalPos = self.m_MapTexture:InverseTransformPoint(vTextureWorldPos)

	local vGlobalWorldPos = self:GetMap2ScenePos(vTextureLocalPos)

	g_MapTouchCtrl:WalkToPos(vGlobalWorldPos)

	local function delay(obj)
		obj:OnShowPage()
		return false
	end
	Utils.AddTimer(objcall(self, delay), 0.1, 0.1)
end

function CMiniMapPage.SetupMiniPage(self)
	self.m_globalNpcList = DataTools.GetGlobalNpcList(g_MapCtrl:GetMapID())
	for _,v in ipairs(self.m_globalNpcList) do
		-- if v.shortName and string.len(v.shortName) > 0 then
			table.insert(self.m_shortNameNpcList, v)
		-- end
	end
end

-- InitView
function CMiniMapPage.InitMiniMapView(self)
	self.m_PlayerIcon:SetSpriteName("pic_map_avatar_" .. g_AttrCtrl.model_info.shape)
	local resid = g_MapCtrl:GetResID()
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

		local containerW, containerH = self.m_Container:GetSize()
		local relativeRatio = textureRes.width / containerW
		self:SetMimiMapSize(textureRes.width, textureRes.height)
		self.m_Distances = define.Map.AdaptationView.PointSpac * relativeRatio
		
		local ratio = textureRes.width / textureRes.height 
		--[[暂时保留
		local finalWidth, finalHeight
		-- 适配(横向,定宽 \ 纵向,定高)
		if ratio >= 1 then
			finalWidth = containerW
			finalHeight = finalWidth / ratio
		else
			finalHeight = containerH
			finalWidth = finalHeight * ratio
		end

		--以宽未基准做检测
		finalWidth = containerW
		finalHeight = finalWidth / ratio
		if finalHeight > containerH then
			finalHeight = containerH
			finalWidth = finalHeight * ratio
		end
		--以高未基准做检测
		self:SetMimiMapSize(finalWidth, finalHeight)
		]]
		

		self:SetNpcInfo()
		self.m_FinishTexture = true
		self:OnShowPage()
		self.m_PlayerIcon:SetActive(true)
		self.m_CloseBtn:SetActive(true)
		self.m_SwitchBtn:SetActive(self:IsSwitchBtnShow())
		self.m_SearchBtn:SetActive(self:IsSwitchBtnShow())
	end
	g_ResCtrl:LoadAsync(pathName, finishLoadMiniMap)
end

function CMiniMapPage.SetMimiMapSize(self, finalWidth, finalHeight)
	local w, h = g_MapCtrl:GetMapSize()
	self.m_Scene2MapZoomX = w / finalWidth
	self.m_Scene2MapZoomY = h / finalHeight

	self.m_MapTexture:SetPivot(enum.UIWidget.Pivot.Center)
	self.m_MapTexture:SetLocalPos(Vector3.zero)
	self.m_MapTexture:SetSize(finalWidth, finalHeight)
	self.m_MapTexture:SetPivot(enum.UIWidget.Pivot.BottomLeft)

	self.m_MapTexture.m_UIWidget:ResizeCollider()

	self.m_CloseBtn:ResetAndUpdateAnchors()
	self.m_SwitchBtn:ResetAndUpdateAnchors()
	self.m_SearchBtn:ResetAndUpdateAnchors()
	self.m_PlayerInfoOrigin:ResetAndUpdateAnchors()
	self.m_MapName:ResetAndUpdateAnchors()
	self.m_MapTextureBg:ResetAndUpdateAnchors()
	self.m_MapTextureBg:SetActive(true)

end

function CMiniMapPage.SetNpcInfo(self)
	self.m_MapName:SetText(g_MapCtrl:GetSceneName())
	self:RefreshExtraNpc()
	
	if g_OrgWarCtrl:GetCurrentScene() == define.Org.OrgWarScene.War then
		self.m_OrgWarPart:SetActive(true)
		self.m_OrgPreparePart:SetActive(false)
	elseif g_OrgWarCtrl:GetCurrentScene() == define.Org.OrgWarScene.Prepare then
		self.m_OrgWarPart:SetActive(false)
		self.m_OrgPreparePart:SetActive(true)
		self:SetOrgWarNpc()
	elseif not g_MapCtrl:IsVirtualScene() then
		self.m_OrgWarPart:SetActive(false)
		self.m_OrgPreparePart:SetActive(false)
		self:SetTransfers()
		self:SetNpc(self.m_shortNameNpcList)
	end
end

function CMiniMapPage.SetOrgWarNpc(self)
	local oData = data.npcdata.OrgWarNpc[50004]
	self.m_OrgPreparePart.m_Name = self.m_OrgPreparePart:NewUI(1, CLabel)
	self.m_OrgPreparePart.m_Name:SetText(oData.name)
	local vWorldPos = Vector3.New(oData.x, oData.y, oData.z)
	local vTexturePos = self:GetScene2MapPos(vWorldPos)
	local nameHalfWidth = self.m_OrgPreparePart.m_Name:GetSize() / 2
	if vTexturePos.x - nameHalfWidth < 0  then
		vTexturePos.x = nameHalfWidth
	elseif vTexturePos.x + nameHalfWidth > define.Map.AdaptationView.Width then
		vTexturePos.x = define.Map.AdaptationView.Width - nameHalfWidth
	end
	self.m_OrgPreparePart:SetLocalPos(vTexturePos)
end

function CMiniMapPage.SetNpc(self, oData)
	local oNpcBox = nil
	for i,v in ipairs(oData) do
		if i > #self.m_NpcInfoBoxList then
			oNpcBox = self.m_NpcShortNameBoxClone:Clone()
			oNpcBox.m_Name = oNpcBox:NewUI(1, CLabel)
			oNpcBox.m_Bg = oNpcBox:NewUI(2, CSprite)
			oNpcBox:SetParent(self.m_NpcShortNameNode.m_Transform)
			table.insert(self.m_NpcInfoBoxList, oNpcBox)
		else
			oNpcBox = self.m_NpcInfoBoxList[i]
		end
		local kind = v.kind == 1
		if v.shortName ~= "" then
			oNpcBox.m_Name:SetText(v.shortName)
		else
			oNpcBox.m_Name:SetText(v.name)
		end
		--oNpcBox.m_Name:SetText((kind and "[0fFF32]" or "[FFF9E3]") .. v.name)
		--oNpcBox.m_Name:SetEffectColor(kind and Color.New(12/255, 120/255, 66/255, 1) or Color.New(153/255, 96/255, 17/255, 1))
		-- green-npc yellow-npc
		--oNpcBox.m_Bg:SetSpriteName(kind and "green-npc" or "yellow-npc")

		oNpcBox:SetName(v.id .. "_" .. v.name)
		local vWorldPos = Vector3.New(v.x, v.y, v.z)
		local vTexturePos = self:GetScene2MapPos(vWorldPos)
		local nameHalfWidth = oNpcBox.m_Name:GetSize() / 2
		if vTexturePos.x - nameHalfWidth < 0  then
			vTexturePos.x = nameHalfWidth
		elseif vTexturePos.x + nameHalfWidth > define.Map.AdaptationView.Width then
			vTexturePos.x = define.Map.AdaptationView.Width - nameHalfWidth
		end
		oNpcBox:SetLocalPos(vTexturePos)
		oNpcBox:SetActive(true)
	end
	for i=#oData+1,#self.m_NpcInfoBoxList do
		oNpcBox = self.m_NpcInfoBoxList[i]
		if not oNpcBox then
			break
		end
		oNpcBox:SetActive(false)
	end
end

function CMiniMapPage.SetTransfers(self)
	local mapID = g_MapCtrl:GetMapID()
	local mapData = DataTools.GetMapData(mapID)
	-- TODO 传送点
	local sceneData = DataTools.GetSceneDataForMapid(mapID) --transfers
	local oTeleportBox = nil
	if not sceneData.transfers then
		printc("没有传送点-->mapID:", mapID)
		return
	end
	for i,v in ipairs(sceneData.transfers) do
		oTeleportBox = self.m_TeleportShortNameBoxClone:Clone()
		oTeleportBox.m_Name = oTeleportBox:NewUI(1, CLabel)
		oTeleportBox.m_Bg = oTeleportBox:NewUI(2, CSprite)	
		oTeleportBox:SetParent(self.m_TeleportShortNameNode.m_Transform)
		local targetData = DataTools.GetSceneData(v.target_scene)
		oTeleportBox.m_Name:SetText(targetData.scene_name)
		oTeleportBox:SetName(v.target_scene .. "_" .. targetData.scene_name)
		
		local vWorldPos = Vector3.New(v.x, v.y, 0)
		local vTexturePos = self:GetScene2MapPos(vWorldPos)
		local nameHalfWidth = oTeleportBox.m_Name:GetSize() / 2
		if vTexturePos.x - nameHalfWidth < 0  then
			vTexturePos.x = nameHalfWidth
		elseif vTexturePos.x + nameHalfWidth > define.Map.AdaptationView.Width then
			vTexturePos.x = define.Map.AdaptationView.Width - nameHalfWidth
		end
		oTeleportBox:SetLocalPos(vTexturePos)
		oTeleportBox:SetActive(true)
	end
end

function CMiniMapPage.RefreshExtraNpc(self)
	local dMapData = g_MapCtrl:GetMiniMapData()
	if not dMapData then
		return
	end
	local oNpcBox = nil
	self.m_ExtraNpcBoxList = {}
	for hdname, npclist in pairs(dMapData) do
		--table.print(npclist)
		for id, v in pairs(npclist) do
			oNpcBox = self.m_NpcShortNameBoxClone:Clone()
			oNpcBox.m_Name = oNpcBox:NewUI(1, CLabel)
			oNpcBox.m_Bg = oNpcBox:NewUI(2, CSprite)
			oNpcBox:SetParent(self.m_NpcShortNameNode.m_Transform)
			oNpcBox.m_Name:SetText(v.name)
			oNpcBox:SetName(v.id .. "_" .. v.name)
			
			table.insert(self.m_ExtraNpcBoxList, oNpcBox)
			local vWorldPos = Vector3.New(v.x, v.y, v.z)
			local vTexturePos = self:GetScene2MapPos(vWorldPos)
			local nameHalfWidth = oNpcBox.m_Name:GetSize() / 2
			if vTexturePos.x - nameHalfWidth < 0  then
				vTexturePos.x = nameHalfWidth
			elseif vTexturePos.x + nameHalfWidth > define.Map.AdaptationView.Width then
				vTexturePos.x = define.Map.AdaptationView.Width - nameHalfWidth
			end
			oNpcBox:SetLocalPos(vTexturePos)
			oNpcBox:SetActive(true)
		end
	end
end

-- Override
function CMiniMapPage.OnHidePage(self)
	if self.m_MiniMapTimer then
		Utils.DelTimer(self.m_MiniMapTimer)
		self.m_MiniMapTimer = nil
	end
end

function CMiniMapPage.OnShowPage(self)
	if self.m_FinishTexture then
		self:ResetPlayerPos()
		self:InitPathPoint()
		self:SetMiniMapTimer()
	end
end

function CMiniMapPage.ResetPlayerPos(self)
	-- 设置玩家PlayerIcon位置
	local heroLocalPos = self:GetHeroLocalPos()
	local finalLocalPos = self:GetScene2MapPos(heroLocalPos)
	self.m_PlayerIcon:SetLocalPos(finalLocalPos)
end

function CMiniMapPage.InitPathPoint(self)
	local oHero = g_MapCtrl:GetHero()
	if not oHero then
		return
	end
	local heroPathList = oHero:GetPath()
	if not heroPathList or #heroPathList <= 0 then
		return
	end

	self.m_FootPointCount = 0
	local heroPathLen = #heroPathList

	-- 计算当前目标点位
	local targetLocalPos = heroPathList[heroPathLen]
	local targetWorldPos = self:GetScene2MapPos(targetLocalPos)
	self.m_TargetPoint:SetLocalPos(targetWorldPos)
	self.m_TargetLabel:SetText(string.format("(%d,%d)", math.floor(targetLocalPos.x), math.floor(targetLocalPos.y)))

	local flagPos = heroPathList[1]
	if heroPathLen == 2 then
		-- heroPathLen=2,路径点自行补间
		self:LinePathPoint(self:GetScene2MapPos(heroPathList[1]), self:GetScene2MapPos(heroPathList[2]))
	else
		local distance = self.m_Distances^2
		for _,v in ipairs(heroPathList) do
			v.z = 0
			if (flagPos.x-v.x)^2 + (flagPos.y-v.y)^2 > distance then
				flagPos = v
				self:CurvePathPoint(self:GetScene2MapPos(flagPos), self:GetScene2MapPos(v))
			end
		end
	end

	-- 计算玩家当前位置
	local heroWayIndex = oHero:GetWayPointIndex()

	-- heroPathLen=1代表是直线,所以路径点全部自行补间,所以iNowPos返回的是0,所以把当前路径点设置为第一个
	if heroPathLen == 2 and heroWayIndex == 0 and next(self.m_FootPointObjList) ~= nil then
		self.m_FootPointIndex = 1
	else
		-- 根据路径总长度和实际的路径点table之间的比例算出当前经过的点
		self.m_FootPointIndex = math.ceil(heroWayIndex * (#self.m_FootPointObjList / heroPathLen))
		self:HideFootPoints(self.m_FootPointIndex, false)

		if next(self.m_FootPointObjList) ~= nil then
			local footPoint = self.m_FootPointObjList[self.m_FootPointIndex]
			if footPoint and not footPoint:GetActive() then
				self.m_FootPointIndex = self.m_FootPointIndex + 1
			end
		end
	end
end

-- 直线点补间
function CMiniMapPage.LinePathPoint(self, startPos, endPos)
	if startPos == nil or endPos == nil then 
		return
	end
	local iRadian = math.atan2(endPos.y - startPos.y, endPos.x - startPos.x)
	local iCosRadian = math.cos(iRadian)
	local iSinRadian = math.sin(iRadian)
	local iTotalen = Vector3.Distance(startPos, endPos)
	local oPoint = nil
	for i=1,iTotalen,30 do
		self.m_FootPointCount = self.m_FootPointCount + 1
		oPoint = self:CloneFootPoint(self.m_FootPointCount)
		oPoint:SetParent(self.m_FootPointList.m_Transform)
		local x = startPos.x + iCosRadian * i
		local y = startPos.y + iSinRadian * i
		oPoint:SetLocalPos(Vector3.New(x, y, 0))
	end
end

-- 曲线点补间
function CMiniMapPage.CurvePathPoint(self, startPos, endPos)
	if not startPos or not endPos then 
		return
	end
	self.m_FootPointCount = self.m_FootPointCount + 1
	local oPoint = self:CloneFootPoint(self.m_FootPointCount)
	oPoint:SetParent(self.m_FootPointList.m_Transform)
	oPoint:SetLocalPos(Vector3.New(startPos.x, startPos.y, 0))
end

-- CloneFootPoint
function CMiniMapPage.CloneFootPoint(self, index)
	local oPoint = nil
	if index > #self.m_FootPointObjList then
		oPoint = self.m_PointClone:Clone()
		oPoint:SetName("FootPoint_" .. index)
		table.insert(self.m_FootPointObjList, oPoint)
	else
		oPoint = self.m_FootPointObjList[index]
	end
	oPoint:SetActive(true)
	return oPoint
end

function CMiniMapPage.SetMiniMapTimer(self)
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local bCheck = self:CheckFootPointObjList()
		local pointObj = self.m_FootPointObjList[self.m_FootPointIndex]
		local endSta = (pointObj and pointObj:GetActive()) or bCheck
		if endSta then
			if pointObj and Vector3.Distance(self.m_PlayerIcon:GetLocalPos(), pointObj:GetLocalPos()) < 6 then
				pointObj:SetActive(false)
				self.m_FootPointIndex = self.m_FootPointIndex + 1
			end
			local direction = self.m_FootPointIndex%2 == 1
			local flip = direction and enum.UISprite.Flip.Horizontally or enum.UISprite.Flip.Nothing
			self.m_PlayerIcon:SetFlip(flip)
		end

		self.m_TargetPoint:SetActive(endSta)
		self:ResetPlayerPos()
		return endSta
	end
	self.m_MiniMapTimer = Utils.AddTimer(update, 0.1, 0.1)
end

function CMiniMapPage.CheckFootPointObjList(self)
	for i,pointObj in ipairs(self.m_FootPointObjList) do
		if pointObj and pointObj:GetActive() then
			return true
		end
	end
end

-- Help
-- 世界场景坐标坐标转换到UIMiniMap坐标
function CMiniMapPage.GetScene2MapPos(self, keyPos)
	return Vector3.New(keyPos.x / self.m_Scene2MapZoomX, keyPos.y / self.m_Scene2MapZoomY, 0)
end
-- UIMiniMap坐标转换到世界场景坐标
function CMiniMapPage.GetMap2ScenePos(self, keyPos)
	return Vector3.New(keyPos.x * self.m_Scene2MapZoomX, keyPos.y * self.m_Scene2MapZoomY, 0)
end

function CMiniMapPage.HideFootPoints(self, count)
	for i=1,count do
		if self.m_FootPointObjList[i] then
			self.m_FootPointObjList[i]:SetActive(false)
		end
	end
end

function CMiniMapPage.GetHeroLocalPos(self)
	local oHero = g_MapCtrl:GetHero()
	return oHero and oHero:GetLocalPos() or Vector3.zero
end

-- 搜索Npc信息
function CMiniMapPage.SetSearchInfo(self)
	if not self.m_globalNpcList or #self.m_globalNpcList <= 0 then
		return
	end
	-- 排序
	table.sort(self.m_globalNpcList, function (a, b)
		return a.id < b.id
	end)
	local npcBoxList = self.m_NpcBoxListGrid:GetChildList()
	local oNpcBox = nil
	for i,v in ipairs(self.m_globalNpcList) do
		if i > #npcBoxList then
			oNpcBox = self.m_NpcSeachBoxClone:Clone()
			oNpcBox.m_Icon = oNpcBox:NewUI(1, CSprite)
			oNpcBox.m_Name = oNpcBox:NewUI(2, CLabel)
			self.m_NpcBoxListGrid:AddChild(oNpcBox)
		else
			oNpcBox = npcBoxList[i]
		end
		oNpcBox:AddUIEvent("click", function ()
			self.m_NpcBoxListNode:SetActive(false)
			self:OnClose()
			if g_TeamCtrl:IsJoinTeam() and 
				(not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
				g_NotifyCtrl:FloatMsg("组队状态下只有队长可操作")
				return
			end
			local pos = Vector3.New(v.x, v.y, v.z)
			g_MapTouchCtrl:WalkToPos(pos, v.id, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function ()
				local npcid = g_MapCtrl:GetNpcIdByNpcType(v.id)
				local oNpc = g_MapCtrl:GetNpc(npcid)
				if oNpc and oNpc.Trigger then
					oNpc:Trigger()
				end
				printc(string.format("结束寻路到指定npcid:%s, npctype:%s, %s", npcid, v.id, v.name))

			end)
		end)
		if v.shortName ~= "" then
			oNpcBox.m_Name:SetText(v.shortName)
		else
			oNpcBox.m_Name:SetText(v.name)
		end
		oNpcBox.m_Icon:SpriteAvatar(v.modelId)
		oNpcBox:SetName(v.id .. "_" .. v.name)
		oNpcBox:SetActive(true)
	end

	for i=#self.m_globalNpcList+1,#npcBoxList do
		oNpcBox = npcBoxList[i]
		if not oNpcBox then
			break
		end
		oNpcBox:SetActive(false)
	end
	self.m_NpcBoxListNode:SetActive(true)
end

function CMiniMapPage.IsSwitchBtnShow(self)
	local b = true
	if g_MapCtrl:IsVirtualScene() then 
		b = false
	end
	return b 
end

return CMiniMapPage