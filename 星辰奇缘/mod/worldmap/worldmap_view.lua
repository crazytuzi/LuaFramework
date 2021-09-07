-- ----------------------------------------------------------
-- UI - 世界地图
-- ----------------------------------------------------------
WorldMapView = WorldMapView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2

function WorldMapView:__init(model)
    self.model = model
    self.name = "WorldMapView"
    self.windowId = WindowConfig.WinID.worldmapwindow
    self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Visible
    self.resList = {
        {file = AssetConfig.worldmap_window, type = AssetType.Main}
        , {file = AssetConfig.minimaps_worldmap, type = AssetType.Dep}
        , {file = AssetConfig.heads, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
	self.npcPointList ={}
	self.npcItemList ={}
	self.mapOffstX = 0
	self.mapOffstY = 0
	self.mapScaleX = 1
	self.mapScaleY = 1
	self.loadPointList = {}
	self.selfRole = nil
	self.scrollrect = nil
	self.coverImage = nil

	self.is_worldmap = true
	self.resloaded = false
	self.count = 0
	self.endX = 0
	self.endY = 0
	------------------------------------------------
    -- self.minimap_path = string.format(AssetConfig.minimaps, tostring(math.floor(ctx.sceneManager.Map.TextureId / 10)))
    self.minimap_path = string.format(AssetConfig.minimaps, SceneManager.Instance.sceneModel.sceneView.textureid)

    table.insert(self.resList, {file = self.minimap_path, type = AssetType.Dep})

    ------------------------------------------------
    self._OnClickClose = function() self:OnClickClose() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function WorldMapView:__delete()
    self:OnHide()
    self.transform:FindChild("Main/WorldMap/Mask/MapBG"):GetComponent(Image).sprite = nil
    self.transform:FindChild("Main/WorldMap/Head/Head"):GetComponent(Image).sprite = nil
    self.transform:FindChild("Main/CurMap/CoverImage"):GetComponent(Image).sprite = nil
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldMapView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldmap_window))
    self.gameObject.name = "WorldMapView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    local transform = self.transform
    local closeBtn = transform:FindChild("Main/WorldMap/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	closeBtn = transform:FindChild("Main/CurMap/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    local btn = transform:FindChild("Main/WorldMap/CurMapButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:opencurmap() end)

    btn = transform:FindChild("Main/CurMap/WorldMapButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:openworldmap() end)

    btn = transform:FindChild("Main/CurMap/NPCButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:shownpcpanel() end)

    btn = transform:FindChild("Main/CurMap/BackToTheCityButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:backtothecity() end)

    btn = transform:FindChild("Main/WorldMap/BackToTheCityButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:backtothecity() end)

    btn = transform:FindChild("Main/WorldMap/BackToHomeButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:backtohome() end)

	self.myPoint = transform:FindChild("Main/CurMap/CoverImage/MyPoint").gameObject
    self.targetPoint = transform:FindChild("Main/CurMap/CoverImage/TargetPoint").gameObject
    self.loadPointObject = transform:FindChild("Main/CurMap/CoverImage/Point").gameObject
    self.npcPointObject = transform:FindChild("Main/CurMap/CoverImage/NPCPoint").gameObject
    self.scrollrect = transform:FindChild("Main/CurMap/NPCPanel/mask"):GetComponent(ScrollRect)

    self.coverImage = transform:FindChild("Main/CurMap/CoverImage").gameObject
    self.coverImage:GetComponent(Button).onClick:AddListener(function() self:curMapClick() end)

    self.selfRole = SceneManager.Instance.sceneElementsModel.self_view

    -- 按钮功能绑定
    local maplist = {10001,10002,10003,10004,10007,10009}
    for i=1, #maplist do
        local mapBtn = transform:FindChild(string.format("Main/WorldMap/MapButton_%s", maplist[i])).gameObject
        mapBtn.name = tostring(maplist[i])
        mapBtn:GetComponent(Button).onClick:AddListener(function() self:onmapbuttonclick(mapBtn.name) end)

        if maplist[i] == 10009 and RoleManager.Instance.RoleData.lev < 90 then
            mapBtn:SetActive(false)
        end
    end

    -------------------------------------------------------------
    self:OnShow()

    -- 清理资源
    LuaTimer.Add(2000, function() AssetPoolManager.Instance:DoUnloadUnusedAssets() end)
end

function WorldMapView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function WorldMapView:OnShow()
    if BaseUtils.is_null(self.gameObject) then
        return
    end
	EventMgr.Instance:AddListener(event_name.scene_load, self._OnClickClose)
	if self.openArgs ~= nil and self.openArgs[1] == 1 then
		self:opencurmap()
	else
		self:openworldmap()
	end

    self:updateworldmap()
	LuaTimer.Add(10, function()
            if not BaseUtils.isnull(self.transform) then
                self.transform:FindChild("Main").gameObject:SetActive(true)
                self:updatecurmap()
            end
        end)
end

function WorldMapView:OnHide()
	EventMgr.Instance:RemoveListener(event_name.scene_load, self._OnClickClose)
end

function WorldMapView:opencurmap()
    self.is_worldmap = false
    self.transform:FindChild("Main/WorldMap").gameObject:SetActive(false)
    self.transform:FindChild("Main/CurMap").gameObject:SetActive(true)
    self.transform:FindChild("Main/CurMap/NPCPanel").gameObject:SetActive(false)
    self.is_shownpcpanel = false
end

function WorldMapView:openworldmap()
    self.is_worldmap = true
    self.transform:FindChild("Main/WorldMap").gameObject:SetActive(true)
    self.transform:FindChild("Main/CurMap").gameObject:SetActive(false)
end

function WorldMapView:shownpcpanel()
    if self.is_shownpcpanel then
        self.transform:FindChild("Main/CurMap/NPCPanel").gameObject:SetActive(false)
        self.is_shownpcpanel = false
    else
        self.transform:FindChild("Main/CurMap/NPCPanel").gameObject:SetActive(true)
        self.is_shownpcpanel = true
    end
end

function WorldMapView:FixedUpdate()
	if not self.is_worldmap and self.selfRole then
        self.myPoint:GetComponent(RectTransform).anchoredPosition
            = Vector2(self.selfRole.gameObject.transform.position.x / self.mapScaleX - self.mapOffstX
            , self.selfRole.gameObject.transform.position.y / self.mapScaleY - self.mapOffstY)

        if BaseUtils.distance_byxy(self.selfRole.gameObject.transform.position.x, self.selfRole.gameObject.transform.position.y, self.endX, self.endY) < 0.1 then
            self:cleanloadpoint()
        end
        if self.count % 5 == 0 then
			if #self.loadPointList == 0 and #self.selfRole.TargetPositionList > 0 then
			    local paths = self.selfRole.TargetPositionList
			    self.endX = paths[#self.selfRole.TargetPositionList].x
			    self.endY = paths[#self.selfRole.TargetPositionList].y
			    self:drawloadpoint()
			else
			    local i = 1
			    while self.loadPointList[i] do
			        local item = self.loadPointList[i]
			        if BaseUtils.distance_byxy(self.myPoint.transform.localPosition.x, self.myPoint.transform.localPosition.y,
			            item.transform.localPosition.x, item.transform.localPosition.y) < 18 then
			            table.remove(self.loadPointList, i)
			            GameObject.DestroyImmediate(item)
			            break
			        else
			            i = i +1
			        end
			    end
			end
		end
		self.count = self.count + 1
    end
end

function WorldMapView:updatedata()
    self.transform:FindChild("Main").gameObject:SetActive(true)
    self:updateworldmap()
    self:updatecurmap()
end

function WorldMapView:updateworldmap()
    local roleheadtransform = self.transform:FindChild("Main/WorldMap/Head")
    roleheadtransform:FindChild("Head"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.heads
        	, string.format("%s_%s", RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.sex))

    local mapbuttontransform = self.transform:FindChild(string.format("Main/WorldMap/%s", SceneManager.Instance:CurrentMapId()))
    if mapbuttontransform ~= nil then
        local anchoredPosition = mapbuttontransform:GetComponent(RectTransform).anchoredPosition
        roleheadtransform:GetComponent(RectTransform).anchoredPosition = Vector2(anchoredPosition.x, anchoredPosition.y + 60)
        roleheadtransform.gameObject:SetActive(true)
    else
        roleheadtransform.gameObject:SetActive(false)
    end
    local worldmapimage = self.transform:FindChild("Main/WorldMap/Mask/MapBG"):GetComponent(Image)
    worldmapimage.sprite = self.assetWrapper:GetSprite(AssetConfig.minimaps_worldmap, "WorldMap")
    worldmapimage.gameObject:SetActive(true)
end

function WorldMapView:onmapbuttonclick(mapId)
    -- if not mod_team.can_run() then
    --     mod_notify.append_scroll_win("在队伍跟随中，不允许操作")
    --     return
    -- end

    local targetmapid = tonumber(mapId)

    self:OnClickClose()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(6)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Transport(targetmapid, 0, 0)

    AutoFarmManager.Instance:stopFarm()
    AutoFarmManager.Instance:StopAncientDemons()
    HomeManager.Instance:CancelFindTree()
end

function WorldMapView:updatecurmap()
	local transform = self.transform
	local map = ctx.sceneManager.Map
    local curMapPanel = transform:FindChild("Main/CurMap").gameObject
    local curMapImage = transform:FindChild("Main/CurMap/Mask/CurMapImage").gameObject
    local coverImage = transform:FindChild("Main/CurMap/CoverImage").gameObject
    curMapImage:GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(self.minimap_path, tostring(math.floor(map.TextureId / 10)))
    curMapImage.gameObject:SetActive(true)
	curMapImage:GetComponent(Image):SetNativeSize()

    local imageWidth = curMapImage:GetComponent(RectTransform).sizeDelta.x
    local imageHeight = curMapImage:GetComponent(RectTransform).sizeDelta.y
    local mapImageHeight = 420 -- 小地图常数，所有小地图的实际图像高度均为512像素，如修改小地图显示大小则需同步修改此常量
    local mapImageWidth = map.Width * (mapImageHeight / map.Height)

    curMapImage.transform:GetComponent(RectTransform).sizeDelta
        = Vector2(imageWidth * mapImageHeight / imageHeight, mapImageHeight)
    imageWidth = curMapImage:GetComponent(RectTransform).sizeDelta.x
	imageHeight = curMapImage:GetComponent(RectTransform).sizeDelta.y
	mapImageWidth = map.Width * (mapImageHeight / map.Height)

    curMapImage.transform:GetComponent(RectTransform).anchoredPosition
        = Vector2((mapImageWidth - imageWidth) / 2, (mapImageHeight - imageHeight) / 2)
    -- curMapImage:GetComponent(Image):SetNativeSize()
    -- curMapImage.transform:GetComponent(RectTransform).anchoredPosition
    --     = Vector2((mapImageWidth - imageWidth) / 2, (mapImageHeight - imageHeight) / 2)

    curMapPanel:GetComponent(RectTransform).sizeDelta
        = Vector2(mapImageWidth + 20, mapImageHeight + 16)

    self.mapScale = map.Width / mapImageWidth
    self.mapScaleX = self.mapScale / map.Width * map.MapWidth
    self.mapScaleY = self.mapScale / map.Height * map.MapHeight


    self.mapOffstX = mapImageWidth / 2
    self.mapOffstY = mapImageHeight / 2

    for i=1, #self.npcPointList do
        GameObject.Destroy(self.npcPointList[i])
    end

    for i=1, #self.npcItemList do
        GameObject.Destroy(self.npcItemList[i])
    end

    self.npcPointList = {}
    self.npcItemList = {}

    local npcPoint
    local NPCItem
    local NPCPanel = self.transform:FindChild("Main/CurMap/NPCPanel/mask/content").gameObject
    local NPCItemObject = NPCPanel.transform:FindChild("NPCItem").gameObject
    NPCItemObject:SetActive(false)
    local npcList = DataWorldNpc.data_world_npc

    local sceneElementsModel = SceneManager.Instance.sceneElementsModel
    for k, v in pairs(npcList) do
        local npcData = v
        local uniqueid = BaseUtils.get_unique_npcid(npcData.id, npcData.battleid)
        local unitdata = sceneElementsModel.WaitForCreateUnitData_List[uniqueid]
        local unitbasedata = nil
		if unitdata == nil then
			local npcView = sceneElementsModel.NpcView_List[uniqueid]
			if npcView ~= nil then
				unitdata = npcView.data
                unitbasedata = DataUnit.data_unit[unitdata.baseid]
			end
        else
            unitbasedata = DataUnit.data_unit[unitdata.baseid]
		end

        if unitdata ~= nil and unitbasedata ~= nil and npcData.mapbaseid == SceneManager.Instance:CurrentMapId() then
            local px = npcData.posx * SceneManager.Instance.Mapsizeconvertvalue / self.mapScaleX - self.mapOffstX
            local py = mapImageHeight - npcData.posy * SceneManager.Instance.Mapsizeconvertvalue / self.mapScaleY - self.mapOffstY
            local function gotoNPC()
                sceneElementsModel:Self_MoveToTarget(uniqueid)
                sceneElementsModel:Self_Change_Top_Effect(1)
                self:OnClickClose()
            end

            if unitdata.unittype == SceneConstData.unittype_npc then
                npcPoint = GameObject.Instantiate(self.npcPointObject)
                UIUtils.AddUIChild(coverImage, npcPoint)
                npcPoint:GetComponent(RectTransform).anchoredPosition = Vector2(px, py)
                -- npcPoint.transform:Find("Text"):GetComponent(Text).text = unitdata.name
                local text = npcPoint.transform:Find("Text"):GetComponent(Text)
                text.text = unitbasedata.map_text
                text.rectTransform.sizeDelta = Vector2(text.preferredWidth, text.preferredHeight)
                npcPoint:GetComponent(Button).onClick:AddListener(gotoNPC)
                table.insert(self.npcPointList, npcPoint)

                if unitbasedata.map_text ~= "" then
                    NPCItem = GameObject.Instantiate(NPCItemObject)
                    UIUtils.AddUIChild(NPCPanel, NPCItem)
                    NPCItem.transform:Find("Text"):GetComponent(Text).text = unitbasedata.map_text
                    NPCItem:GetComponent(Button).onClick:AddListener(gotoNPC)
                    table.insert(self.npcItemList, NPCItem)
                end
            elseif unitdata.unittype == SceneConstData.unittype_teleporter then
				npcPoint = GameObject.Instantiate(self.npcPointObject)
                UIUtils.AddUIChild(coverImage, npcPoint)
                npcPoint:GetComponent(RectTransform).anchoredPosition = Vector2(px, py)
                local text = npcPoint.transform:Find("Text"):GetComponent(Text)
                text.text = string.format("<color='#11D1FF'>%s</color>", unitdata.name)
                text.rectTransform.sizeDelta = Vector2(text.preferredWidth, text.preferredHeight)
                npcPoint.transform:Find("Image").gameObject:SetActive(false)
                npcPoint:GetComponent(Button).onClick:AddListener(gotoNPC)
                table.insert(self.npcPointList, npcPoint)
            end
        end
    end
end

function WorldMapView:curMapClick()
	-- print(string.format("%s %s", Input.mousePosition.x, Input.mousePosition.y))
    local uiCamera = ctx.UICamera
    self.endX = (Input.mousePosition.x - uiCamera:WorldToScreenPoint(self.coverImage.transform.position).x) * 960 / ctx.ScreenWidth
        + self.mapOffstX
    self.endY = (Input.mousePosition.y - uiCamera:WorldToScreenPoint(self.coverImage.transform.position).y) * 540 / ctx.ScreenHeight
        + self.mapOffstY

    self.endX = self.endX * self.mapScaleX
    self.endY = self.endY * self.mapScaleY

    if ctx.sceneManager.Map:Walkable(self.endX, self.endY) then
        local point = Vector2(self.endX, self.endY)
        SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(point.x, point.y)
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        self:drawloadpoint()
        -- sceneManager.AutoWalking = true
    else
        self:cleanloadpoint()
        -- sceneManager.AutoWalking = false
    end
end

function WorldMapView:drawloadpoint()
    self:cleanloadpoint()

    local coverImage = self.transform:FindChild("Main/CurMap/CoverImage").gameObject
    local loadPoint
    local paths = self.selfRole.TargetPositionList
    local lastPoint = Vector2(self.selfRole.gameObject.transform.position.x, self.selfRole.gameObject.transform.position.y)
    for i=1, #paths do
        local vector2
        if i == 1 then
            vector2 = lastPoint
        else
            vector2 = paths[i]
        end
        -- print(string.format("%s %s", vector2.x, vector2.y))
        if BaseUtils.distance_bypoint(lastPoint, vector2) > 0.6 then
            -- 绘制每一个路点
            loadPoint = GameObject.Instantiate(self.loadPointObject)
            UIUtils.AddUIChild(coverImage, loadPoint)
            loadPoint:GetComponent(Image):SetNativeSize()
            loadPoint.transform:SetSiblingIndex(0)
            loadPoint:GetComponent(RectTransform).anchoredPosition
                = Vector2(vector2.x / self.mapScaleX, vector2.y / self.mapScaleY)
            table.insert(self.loadPointList, loadPoint)

            -- 画与上一个路点之间的虚线
            local list = self:addLoadPointList(lastPoint, vector2)
            for k2, v2 in pairs(list) do
				loadPoint = GameObject.Instantiate(self.loadPointObject)
            	UIUtils.AddUIChild(coverImage, loadPoint)
                loadPoint:GetComponent(Image):SetNativeSize()
                loadPoint.transform:SetSiblingIndex(0)
                loadPoint:GetComponent(RectTransform).anchoredPosition
                    = Vector2(v2.x / self.mapScaleX, v2.y / self.mapScaleY)
                table.insert(self.loadPointList, loadPoint)
            end
            lastPoint = vector2
        end
    end

    -- 把最后一个路点与终点连上虚线
    if BaseUtils.distance_bypoint(lastPoint, Vector2(self.endX, self.endY)) > 0.6 then
        local lastList = self:addLoadPointList(lastPoint, Vector2(self.endX, self.endY))
        for k, v in pairs(lastList) do
            loadPoint = GameObject.Instantiate(self.loadPointObject)
			UIUtils.AddUIChild(coverImage, loadPoint)
            loadPoint:GetComponent(Image):SetNativeSize()
            loadPoint.transform:SetSiblingIndex(0)
            loadPoint:GetComponent(RectTransform).anchoredPosition
                = Vector2(v.x / self.mapScaleX, v.y / self.mapScaleY)
            table.insert(self.loadPointList, loadPoint)
        end
    end

    self.targetPoint:GetComponent(RectTransform).anchoredPosition
        = Vector2(self.endX / self.mapScaleX - self.mapOffstX, self.endY / self.mapScaleY - self.mapOffstY)
    self.targetPoint:SetActive(true)
end

function WorldMapView:addLoadPointList(startpoint, endpoint)
	local distance = 0.4
    local list = {}
    local dis = BaseUtils.distance_bypoint(startpoint, endpoint)
    if dis > distance then
        local pointNum = dis / distance
        for i = 0, pointNum do
            local temp = distance / dis * (i + 1)
            local v2 = Vector2(startpoint.x + (endpoint.x - startpoint.x) * temp, startpoint.y + (endpoint.y - startpoint.y) * temp)
            table.insert(list, v2)
        end
    end
    return list
end

function WorldMapView:cleanloadpoint()
    for k, v in pairs(self.loadPointList) do
        GameObject.DestroyImmediate(v)
    end
    self.loadPointList = {}
    self.targetPoint:SetActive(false)
end

function WorldMapView:backtothecity()
    self:OnClickClose()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(6)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
end

function WorldMapView:backtohome()
    self:OnClickClose()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(6)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    HomeManager.Instance:EnterHome()
end