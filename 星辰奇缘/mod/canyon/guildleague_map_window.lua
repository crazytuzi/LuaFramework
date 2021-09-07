-- ----------------------------------------------------------
-- UI - 世界地图
-- ----------------------------------------------------------
GuildLeagueMapWindow = GuildLeagueMapWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2

function GuildLeagueMapWindow:__init(model)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.name = "GuildLeagueMapWindow"
    -- self.windowId = WindowConfig.WinID.worldmapwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.guildleague_mapwindow, type = AssetType.Main}
        , {file = AssetConfig.minimaps_worldmap, type = AssetType.Dep}
        , {file = AssetConfig.guildleague_texture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.selfcolor = Color(20/255, 201/255, 245/255)
    self.othercolor = Color(227/255, 60/255, 59/255)
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

    self.is_worldmap = false
    self.resloaded = false
    self.count = 0
    self.endX = 0
    self.endY = 0
    ------------------------------------------------
    self.minimap_path = string.format(AssetConfig.minimaps, tostring(math.floor(ctx.sceneManager.Map.TextureId / 10)))

    table.insert(self.resList, {file = self.minimap_path, type = AssetType.Dep})

    ------------------------------------------------
    self._OnClickClose = function() self:OnClickClose() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.update_tower_info = function()
        self:UpdateMapInfo()
    end
end

function GuildLeagueMapWindow:__delete()
    self.OnHideEvent:Fire()
    GuildLeagueManager.Instance.LeagueTowerChange:RemoveListener(self.update_tower_info)
    self.selfbar = nil
    self.otherbar = nil
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildLeagueMapWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_mapwindow))
    self.gameObject.name = "GuildLeagueMapWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    local transform = self.transform

    local closeBtn = transform:FindChild("Main/CurMap/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.myPoint = transform:FindChild("Main/CurMap/CoverImage/MyPoint").gameObject
    self.targetPoint = transform:FindChild("Main/CurMap/CoverImage/TargetPoint").gameObject
    self.loadPointObject = transform:FindChild("Main/CurMap/CoverImage/Point").gameObject
    self.npcPointObject = transform:FindChild("Main/CurMap/CoverImage/NPCPoint").gameObject
    -- self.scrollrect = transform:FindChild("Main/CurMap/NPCPanel/mask"):GetComponent(ScrollRect)

    self.coverImage = transform:FindChild("Main/CurMap/CoverImage").gameObject
    self.coverImage:GetComponent(Button).onClick:AddListener(function() self:curMapClick() end)

    self.CurMap = self.transform:Find("Main/CurMap")
    -- self.NPCPanel = self.transform:Find("Main/CurMap/NPCPanel")
    self.curMapPanel = self.transform:FindChild("Main/CurMap").gameObject
    self.curMapImage = self.transform:FindChild("Main/CurMap/Mask/CurMapImage").gameObject
    self.coverImage = self.transform:FindChild("Main/CurMap/CoverImage").gameObject

    self.elements = self.transform:Find("Main/CurMap/elements")

    self.side1 = self.transform:Find("Main/CurMap/elements/side1")
    self.homebg1 = self.transform:Find("Main/CurMap/elements/side1/homebg")
    self.homeText1 = self.transform:Find("Main/CurMap/elements/side1/homebg/cannonText"):GetComponent(Text)
    self.TopTower1 = self.transform:Find("Main/CurMap/elements/side1/TopTower")
    self.MidTower1 = self.transform:Find("Main/CurMap/elements/side1/MidTower")
    self.BotTower1 = self.transform:Find("Main/CurMap/elements/side1/BotTower")

    self.side2 = self.transform:Find("Main/CurMap/elements/side2")
    self.homebg2 = self.transform:Find("Main/CurMap/elements/side2/homebg")
    self.homeText2 = self.transform:Find("Main/CurMap/elements/side2/homebg/cannonText"):GetComponent(Text)
    self.BotTower2 = self.transform:Find("Main/CurMap/elements/side2/BotTower")
    self.MidTower2 = self.transform:Find("Main/CurMap/elements/side2/MidTower")
    self.TopTower2 = self.transform:Find("Main/CurMap/elements/side2/TopTower")

    self.crystalList = {
        [1] = {
            bar = self.transform:Find("Main/CurMap/elements/side1/TopTower/bar")
            ,Length = self.transform:Find("Main/CurMap/elements/side1/TopTower/bar/Length")
            ,RateText = self.transform:Find("Main/CurMap/elements/side1/TopTower/bar/RateText"):GetComponent(Text)
            ,broken = self.transform:Find("Main/CurMap/elements/side1/TopTower/broken")
            ,Text = self.transform:Find("Main/CurMap/elements/side1/TopTower/broken/Text"):GetComponent(Text)
        },
        [2] = {
            bar = self.transform:Find("Main/CurMap/elements/side1/MidTower/bar")
            ,Length = self.transform:Find("Main/CurMap/elements/side1/MidTower/bar/Length")
            ,RateText = self.transform:Find("Main/CurMap/elements/side1/MidTower/bar/RateText"):GetComponent(Text)
            ,broken = self.transform:Find("Main/CurMap/elements/side1/MidTower/broken")
            ,Text = self.transform:Find("Main/CurMap/elements/side1/MidTower/broken/Text"):GetComponent(Text)
        },
        [3] = {
            bar = self.transform:Find("Main/CurMap/elements/side1/BotTower/bar")
            ,Length = self.transform:Find("Main/CurMap/elements/side1/BotTower/bar/Length")
            ,RateText = self.transform:Find("Main/CurMap/elements/side1/BotTower/bar/RateText"):GetComponent(Text)
            ,broken = self.transform:Find("Main/CurMap/elements/side1/BotTower/broken")
            ,Text = self.transform:Find("Main/CurMap/elements/side1/BotTower/broken/Text"):GetComponent(Text)
        },
        [4] = {
            bar = self.transform:Find("Main/CurMap/elements/side2/TopTower/bar")
            ,Length = self.transform:Find("Main/CurMap/elements/side2/TopTower/bar/Length")
            ,RateText = self.transform:Find("Main/CurMap/elements/side2/TopTower/bar/RateText"):GetComponent(Text)
            ,broken = self.transform:Find("Main/CurMap/elements/side2/TopTower/broken")
            ,Text = self.transform:Find("Main/CurMap/elements/side2/TopTower/broken/Text"):GetComponent(Text)
        },
        [5] = {
            bar = self.transform:Find("Main/CurMap/elements/side2/MidTower/bar")
            ,Length = self.transform:Find("Main/CurMap/elements/side2/MidTower/bar/Length")
            ,RateText = self.transform:Find("Main/CurMap/elements/side2/MidTower/bar/RateText"):GetComponent(Text)
            ,broken = self.transform:Find("Main/CurMap/elements/side2/MidTower/broken")
            ,Text = self.transform:Find("Main/CurMap/elements/side2/MidTower/broken/Text"):GetComponent(Text)
        },
        [6] = {
            bar = self.transform:Find("Main/CurMap/elements/side2/BotTower/bar")
            ,Length = self.transform:Find("Main/CurMap/elements/side2/BotTower/bar/Length")
            ,RateText = self.transform:Find("Main/CurMap/elements/side2/BotTower/bar/RateText"):GetComponent(Text)
            ,broken = self.transform:Find("Main/CurMap/elements/side2/BotTower/broken")
            ,Text = self.transform:Find("Main/CurMap/elements/side2/BotTower/broken/Text"):GetComponent(Text)
        },
    }
    self.cannonText = self.transform:Find("Main/CurMap/elements/cannonbg/cannonText"):GetComponent(Text)

    self.selfRole = SceneManager.Instance.sceneElementsModel.self_view
    self.selfbar = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "selfside")
    self.otherbar = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "otherside")
    -- 按钮功能绑定
    -------------------------------------------------------------
    self:OnShow()

    -- 清理资源
    LuaTimer.Add(2000, function() AssetPoolManager.Instance:DoUnloadUnusedAssets() end)
    self:InitColorSet()
    self:UpdateMapInfo()
    GuildLeagueManager.Instance.LeagueTowerChange:AddListener(self.update_tower_info)
end

function GuildLeagueMapWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function GuildLeagueMapWindow:OnShow()
    if BaseUtils.is_null(self.gameObject) then
        return
    end
    if self.Mgr.model.activity_time ~= nil and self.Mgr.model.activity_time - Time.time <= 48*60 then
        self.cannonText.text = TI18N("炮台\n<color='#00ff00'>已开启</color>")
    else
        self.cannonText.text = TI18N("炮台\n<color='#ff0000'>未开启</color>")
    end
    if self.ticker == nil then
        self.ticker = LuaTimer.Add(0, 50, function() self:FixedUpdate() end)
    end
    EventMgr.Instance:AddListener(event_name.scene_load, self._OnClickClose)
    self:opencurmap()

    LuaTimer.Add(10, function()
            self.transform:FindChild("Main").gameObject:SetActive(true)
            self:updatecurmap()
        end)
end

function GuildLeagueMapWindow:OnHide()
    if self.ticker ~= nil then
        LuaTimer.Delete(self.ticker)
        self.ticker = nil
    end
    self:cleanloadpoint()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self._OnClickClose)
end

function GuildLeagueMapWindow:opencurmap()
    self.is_worldmap = false
    self.CurMap.gameObject:SetActive(true)
    -- self.NPCPanel.gameObject:SetActive(false)
    self.is_shownpcpanel = false
end

function GuildLeagueMapWindow:openworldmap()
    self.is_worldmap = true
    self.curMapPanel:SetActive(false)
end

function GuildLeagueMapWindow:shownpcpanel()
    if self.is_shownpcpanel then
        -- self.NPCPanel.gameObject:SetActive(false)
        self.is_shownpcpanel = false
    else
        -- self.NPCPanel.gameObject:SetActive(true)
        self.is_shownpcpanel = true
    end
end

function GuildLeagueMapWindow:FixedUpdate()
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

function GuildLeagueMapWindow:updatedata()
    self.transform:FindChild("Main").gameObject:SetActive(true)
    self:updatecurmap()
end


function GuildLeagueMapWindow:onmapbuttonclick(mapId)
    -- if not mod_team.can_run() then
    --     mod_notify.append_scroll_win("在队伍跟随中，不允许操作")
    --     return
    -- end

    local targetmapid = tonumber(mapId)
    if targetmapid == 10009 then
        -- NoticeManager.Instance:FloatTipsByString(TI18N("浮空岛家园暂未开放，敬请期待"))
        -- if mod_role.role_info.lev < 15 then
        --     mod_notify.append_scroll_win("15级开放浮空岛")
        --     return
        -- end
        -- SubsceneManager.Instance:IntoHome()
    else
        self:OnClickClose()
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(6)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_Transport(targetmapid, 0, 0)
    end
end

function GuildLeagueMapWindow:updatecurmap()
    local transform = self.transform
    local map = ctx.sceneManager.Map
    self.curMapImage:GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(self.minimap_path, tostring(math.floor(map.TextureId / 10)))
    self.curMapImage.gameObject:SetActive(true)
    self.curMapImage:GetComponent(Image):SetNativeSize()

    local imageWidth = self.curMapImage:GetComponent(RectTransform).sizeDelta.x
    local imageHeight = self.curMapImage:GetComponent(RectTransform).sizeDelta.y
    local mapImageHeight = 420 -- 小地图常数，所有小地图的实际图像高度均为512像素，如修改小地图显示大小则需同步修改此常量
    local mapImageWidth = map.Width * (mapImageHeight / map.Height)

    self.curMapImage.transform:GetComponent(RectTransform).sizeDelta
        = Vector2(imageWidth * mapImageHeight / imageHeight, mapImageHeight)
    imageWidth = self.curMapImage:GetComponent(RectTransform).sizeDelta.x
    imageHeight = self.curMapImage:GetComponent(RectTransform).sizeDelta.y
    mapImageWidth = map.Width * (mapImageHeight / map.Height)

    self.curMapImage.transform:GetComponent(RectTransform).anchoredPosition
        = Vector2((mapImageWidth - imageWidth) / 2, (mapImageHeight - imageHeight) / 2)
    -- curMapImage:GetComponent(Image):SetNativeSize()
    -- curMapImage.transform:GetComponent(RectTransform).anchoredPosition
    --     = Vector2((mapImageWidth - imageWidth) / 2, (mapImageHeight - imageHeight) / 2)

    self.curMapPanel:GetComponent(RectTransform).sizeDelta
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

end

function GuildLeagueMapWindow:curMapClick()
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

function GuildLeagueMapWindow:drawloadpoint()
    self:cleanloadpoint()

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
            UIUtils.AddUIChild(self.coverImage, loadPoint)
            loadPoint:GetComponent(Image):SetNativeSize()
            loadPoint.transform:SetSiblingIndex(0)
            loadPoint:GetComponent(RectTransform).anchoredPosition
                = Vector2(vector2.x / self.mapScaleX, vector2.y / self.mapScaleY)
            table.insert(self.loadPointList, loadPoint)

            -- 画与上一个路点之间的虚线
            local list = self:addLoadPointList(lastPoint, vector2)
            for k2, v2 in pairs(list) do
                loadPoint = GameObject.Instantiate(self.loadPointObject)
                UIUtils.AddUIChild(self.coverImage, loadPoint)
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
            UIUtils.AddUIChild(self.coverImage, loadPoint)
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

function GuildLeagueMapWindow:addLoadPointList(startpoint, endpoint)
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

function GuildLeagueMapWindow:cleanloadpoint()
    for k, v in pairs(self.loadPointList) do
        GameObject.DestroyImmediate(v)
    end
    self.loadPointList = {}
    self.targetPoint:SetActive(false)
end

function GuildLeagueMapWindow:backtothecity()
    self:OnClickClose()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(6)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
end

function GuildLeagueMapWindow:backtohome()
    self:OnClickClose()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(6)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    HomeManager.Instance:EnterHome()
end

function GuildLeagueMapWindow:InitColorSet()
    -- if self.Mgr.my_guild_side == 1 then
        for i=1, 3 do
            self.crystalList[i].Text.color = self.selfcolor
            self.crystalList[i].Length:GetComponent(Image).sprite = self.selfbar
        end
        for i=4, 6 do
            self.crystalList[i].Text.color = self.othercolor
            self.crystalList[i].Length:GetComponent(Image).sprite = self.otherbar
        end
        self.homeText1.color = self.selfcolor
        self.homeText2.color = self.othercolor
    if self.Mgr.my_guild_side == 1 then
        self.homeText1.text = self.Mgr.my_guild_name
        self.homebg1.sizeDelta = Vector2(self.homeText1.preferredWidth+10, 24)
        self.homeText2.text = self.Mgr.other_guild_name
        self.homebg2.sizeDelta = Vector2(self.homeText2.preferredWidth+10, 24)
    else
        self.homeText2.text = self.Mgr.my_guild_name
        self.homebg2.sizeDelta = Vector2(self.homeText2.preferredWidth+10, 24)
        self.homeText1.text = self.Mgr.other_guild_name
        self.homebg1.sizeDelta = Vector2(self.homeText1.preferredWidth+10, 24)
    end
    -- else
    --     for i=1, 3 do
    --         self.crystalList[i].Text.color = self.othercolor
    --         self.crystalList[i].Length:GetComponent(Image).sprite = self.otherbar
    --     end
    --     for i=4, 6 do
    --         self.crystalList[i].Length:GetComponent(Image).sprite = self.selfbar
    --         self.crystalList[i].Text.color = self.selfcolor
    --     end
    --     self.homeText2.color = self.selfcolor
    --     self.homeText2.text = self.Mgr.my_guild_name
    --     self.homebg2.sizeDelta = Vector2(self.homeText2.preferredWidth+10, 24)
    --     self.homeText1.color = self.othercolor
    --     self.homeText1.text = self.Mgr.other_guild_name
    --     self.homebg1.sizeDelta = Vector2(self.homeText1.preferredWidth+10, 24)
    -- end
end

function GuildLeagueMapWindow:UpdateMapInfo()
    if self.Mgr.towerData ~= nil then
        for k,v in pairs(self.Mgr.towerData) do
            if self.crystalList[v.unit_id] ~= nil then
                local rate = math.ceil(v.duration/DataGuildLeague.data_tower_info[v.unit_id].duration*100)
                local target = self.crystalList[v.unit_id]
                if rate <= 0 then
                    target.bar.gameObject:SetActive(false)
                    target.broken.gameObject:SetActive(true)
                else
                    target.Length.sizeDelta = Vector2(66*rate/100, 11)
                    target.RateText.text = string.format("%s%%", tostring(rate))
                    target.broken.gameObject:SetActive(false)
                    target.bar.gameObject:SetActive(true)
                end
            end
        end
    end
end