-- 主界面 地图
MapInfoView = MapInfoView or BaseClass(BaseView)

function MapInfoView:__init()
    self.model = model
	self.resList = {
        {file = AssetConfig.worldmaparea, type = AssetType.Main}
    }

    self.originPos = Vector2(0, 0)

    self.name = "MapInfoView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self._update = function()
    	self:update()
	end

    self.adaptListener = function() self:AdaptIPhoneX() end

	self:LoadAssetBundleBatch()
end

function MapInfoView:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end

    if bool then
        BaseUtils.ChangeLayersRecursively(self.transform, "UI")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = true
        end
    else
        BaseUtils.ChangeLayersRecursively(self.transform, "Water")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = false
        end
    end
end

function MapInfoView:__delete()
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)
    BaseUtils.CancelIPhoneXTween(self.transform)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MapInfoView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldmaparea))
    self.gameObject.name = "MapInfoView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

    self.gameObject.transform:SetAsFirstSibling()

    self.mainRect = self.transform:FindChild("Main"):GetComponent(RectTransform)
    self.mainRect.anchoredPosition = self.originPos
    -----------------------------
    self.transform:FindChild("Main/MapAreaButton"):GetComponent(Button).onClick:AddListener(function() self:worldmapiconclick() end)
    self.transform:FindChild("Main/CurMapButton"):GetComponent(Button).onClick:AddListener(function() self:curmapiconclick() end)

    self.mapname_text = self.transform:FindChild("Main/MapAreaButton/MapNameText"):GetComponent(Text)
    self.coords_text = self.transform:FindChild("Main/MapAreaButton/CoordsText"):GetComponent(Text)

    -----------------------------
    self:update()
    EventMgr.Instance:AddListener(event_name.scene_load, self._update)
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)

    self.isShow = true

    self:ClearMainAsset()

    self:AdaptIPhoneX()

    if BaseUtils.IsVerify then
        self.gameObject:SetActive(false)
    end
end

function MapInfoView:update()
    self:update_mapname()
end

function MapInfoView:update_mapname()
    if not SceneManager.Instance.sceneModel.map_loaded then return end

    local mapName = ctx.sceneManager.Map.Name
    local map_data = DataMap.data_list[ctx.sceneManager.Map.MapId]
    if map_data then mapName = map_data.name end
    self.mapname_text.text = mapName
    self:update_coords()

    if BaseUtils.IsVerify then
        self.mapname_text.text = "当前坐标"
    end
end

function MapInfoView:update_coords()
    if self.coords_text == nil then return end

    local self_view = SceneManager.Instance.sceneElementsModel.self_view
    if self_view ~= nil and self_view.gameObject ~= nil then
        local position = self_view:GetCachedTransform().position
        local gx = ctx.sceneManager.Map:GetMapGridByX(position.x)
        local gy = ctx.sceneManager.Map:GetMapGridByY(position.y)
        if self.coords_x ~= gx or self.coords_y ~= gy then
            self.coords_text.text = string.format("%s,%s", gx, gy)
            self.coords_x = gx
            self.coords_y = gy
        end
    end
end

function MapInfoView:cleanText()
    if self.gameObject == nil then return end
    self.mapname_text.text = ""
    self.coords_x = nil
    self.coords_y = nil
    if self.coords_text == nil then return end
    self.coords_text.text = ""
end

function MapInfoView:worldmapiconclick()
    if BaseUtils.IsVerify then
        return
    end

    if SceneManager.Instance:CurrentMapId() == 30003 then
        --在段位赛里面
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("当前正进行时空段位赛，是否退出场景？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 180
        data.sureCallback = function()
            QualifyManager.Instance:request13513()
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Hero or RoleManager.Instance.RoleData.event == RoleEumn.Event.HeroReady then
        -- 武道大会
        HeroManager.Instance:OnQuit()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFightReady then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
            if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.guildfight ~= nil then
                MainUIManager.Instance.mainuitracepanel.guildfight:fightingAreaExit()
            end
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFightReady then
            if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.guildfight ~= nil then
                MainUIManager.Instance.mainuitracepanel.guildfight:readyAreaExit()
            end
        end
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_cere or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_guest or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_guest_cere then
        --在典礼里面
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否要退出典礼殿堂？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
            SceneManager.Instance.MainCamera:SetFolloewObject(SceneManager.Instance.sceneElementsModel.self_view.gameObject)
            MarryManager.Instance:Send15010()
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon or DungeonManager.Instance:IsDunMap() then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否退出副本？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            DungeonManager.Instance:ExitDungeon()
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
        CanYonManager.Instance:Send21102()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then
        CanYonManager.Instance.model:OpenMapWindow()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.WarriorReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.Warrior then
        local phase = WarriorManager.Instance.model.phase
        if phase == 3 then
            WarriorManager.Instance:OnExit(1)
        elseif phase == 4 or phase == 5 or phase == 6 then
            WarriorManager.Instance:OnExit(2)
        end
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.StarChallenge then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否退出龙王试练地图？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 180
        data.sureCallback = function()
            StarChallengeManager.Instance.model:ExitScene(args)
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.ExquisiteShelf then
        ExquisiteShelfManager.Instance:Exit()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragon or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonFight or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonRod then
        GuildDragonManager.Instance:Exit()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Provocation or RoleManager.Instance.RoleData.event == RoleEumn.Event.ProvocationRoom then
        CrossArenaManager.Instance:ExitScene()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.ApocalypseLord then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否退出天启试练地图？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 180
        data.sureCallback = function()
            ApocalypseLordManager.Instance.model:ExitScene(args)
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    end
    WorldMapManager.Instance.model:OpenWindow({2})
end

function MapInfoView:curmapiconclick()
    if BaseUtils.IsVerify then
        return
    end
    
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Match then
        --在段位赛里面
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("当前正进行时空段位赛，是否退出场景？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 180
        data.sureCallback = function()
            QualifyManager.Instance:request13513()
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.TopCompete then
        if TopCompeteManager.Instance.model.top_compete_status_data ~= nil and TopCompeteManager.Instance.model.top_compete_status_data.status == 2 then

            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("退出巅峰对决之后无法再次进入，确定是否退出")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                TopCompeteManager.Instance:request15102()
            end
            NoticeManager.Instance:ConfirmTips(data)
            return
        end
        TopCompeteManager.Instance:request15102()
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFightReady then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFight then
            if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.guildfight ~= nil then
                MainUIManager.Instance.mainuitracepanel.guildfight:fightingAreaExit()
            end
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildFightReady then
            if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.guildfight ~= nil then
                MainUIManager.Instance.mainuitracepanel.guildfight:readyAreaExit()
            end
        end
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_cere or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_guest or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_guest_cere then
        --在典礼里面
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否要退出典礼殿堂？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
            SceneManager.Instance.MainCamera:SetFolloewObject(SceneManager.Instance.sceneElementsModel.self_view.gameObject)
            MarryManager.Instance:Send15010()
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
        CanYonManager.Instance:Send21102()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then
            CanYonManager.Instance.model:OpenMapWindow()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.StarChallenge then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否退出龙王试练地图？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 180
        data.sureCallback = function()
            StarChallengeManager.Instance.model:ExitScene(args)
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Provocation or RoleManager.Instance.RoleData.event == RoleEumn.Event.ProvocationRoom then
        CrossArenaManager.Instance:ExitScene()
        return
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.ApocalypseLord then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否退出天启试练地图？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 180
        data.sureCallback = function()
            ApocalypseLordManager.Instance.model:ExitScene(args)
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    end

    WorldMapManager.Instance.model:OpenWindow({1})
end

function MapInfoView:TweenHide()
    if not BaseUtils.is_null(self.mainRect) then
        Tween.Instance:Move(self.mainRect, Vector3(self.originPos.x, 100, 0), 0.2)
        self.isShow = false
    end
end

function MapInfoView:TweenShow()
    if not BaseUtils.is_null(self.mainRect) then
        Tween.Instance:Move(self.mainRect, Vector3(self.originPos.x, self.originPos.y, 0), 0.2)
        self.isShow = true
    end
end

function MapInfoView:AdaptIPhoneX()
    BaseUtils.AdaptIPhoneX(self.transform)
end
