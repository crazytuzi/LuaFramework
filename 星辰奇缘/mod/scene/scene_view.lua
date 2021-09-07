SceneView = SceneView or BaseClass(BaseView)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function SceneView:__init(mode)
    self.gameObject = nil
	self.mode = mode

    self.assetWrapper_ForScene = AssetBatchWrapper_ForScene.New()
    self.loadList = BaseUtils.create_queue()

	------------ 地图信息 ------------
    self.mapid = 0
    self.textureid = nil
    self.currentmap_texturepath = nil
    self.mapHeight = 0

    ------------ 地图切块 ------------
    self.map_textures = {} -- 读取完成的地图切块
    self.map_textures_holdTime = tonumber(DataSystem.data_setting[6]) or 600 -- 离开地图后保持资源的时间
    self.map_textures_cache = {}
    self.map_textures_cache_maxnum = tonumber(DataSystem.data_setting[7]) or 200 -- 最大地图资源缓存数

    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.map_textures_cache_maxnum = tonumber(DataSystem.data_setting[8]) or 100 -- 最大地图资源缓存数

        self.map_textures_holdTime = 30
        self.map_textures_cache_maxnum = 20
    end

    ------------ 小地图拉大 ------------
    self.miniMap = nil
    self.showMiniMap = false
    self.miniMapId = 0
    self.miniMapX = 0
    self.miniMapY = 0
    self.alwaysShowMiniMap = false

    ------------ 各种常量 ------------
    -- self.mapsizeconvertvalue = 0.00526315 -- 摄像机比例
    self.mapsizeconvertvalue = SceneManager.Instance.Mapsizeconvertvalue
    self.sizeconvertvalue = 3/4
    self.cell_size = 256 -- 实际资源大小
    self.cell_size2 = 256 / self.sizeconvertvalue -- 在场景里所占的大小
    self.map_row = 4
    self.map_col = 5
    self.row_max = 0
    self.col_max = 0
    self.map_cells = {}
    self.map_transform = nil

    -- BaseUtils.InitTable(self.map_textures)

    self.transportEffect = nil
end

function SceneView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function SceneView:Clean()
    self.mapid = nil
    self.textureid = nil
    -- self.currentmap_texturepath = nil
    self.mapHeight = 0
    for i, map_cell in ipairs(self.map_cells) do
        if map_cell.active then map_cell.transform.gameObject:SetActive(false) end
        map_cell.active = false
    end
end

-- 加载地图、场景元素
function SceneView:LoadSceneElements()
    print("加载地图、场景元素")
    local resList = {
        {file = AssetConfig.sceneelements, type = AssetType.Main, holdTime = 0}
        , {file = "prefabs/effect/30002.unity3d", type = AssetType.Main, holdTime = 0}
        , {file = "prefabs/effect/30003.unity3d", type = AssetType.Main, holdTime = 0}
        -- , {file = string.format(AssetConfig.effect, 30194), type = AssetType.Main, holdTime = 0}
    }
    self.assetWrapper_ForScene:LoadAssetBundle(resList, function() self:OnLoadSceneElements() end)
end

-- 地图、场景元素加载完成
function SceneView:OnLoadSceneElements()
    print("地图、场景元素加载完成")
    if BaseUtils.IsWideScreen() then
        self.map_col = 6
    end

    -- SceneElements
    local gameObject = GameObject.Instantiate(self.assetWrapper_ForScene:GetMainAsset(AssetConfig.sceneelements))
    gameObject.name = "SceneElements"
    gameObject.transform.localPosition = Vector3(0, 0, 0)
    gameObject.transform.localScale = Vector3(1, 1, 1)

    GameObject.DontDestroyOnLoad(gameObject)
    self.gameObject = gameObject

    -- 地图背景
    local m = gameObject.transform:FindChild("Map").gameObject
    local mapCollider = m.transform:FindChild("collider")
    self.mode.mapclicker = m:AddComponent(MapClicker)
    self.map_transform = m.transform

    local LuaBehaviourName = "LuaBehaviourDownUpBase"
    if LuaBehaviourDownUpBaseWithoutUpdate ~= nil then
        LuaBehaviourName = "LuaBehaviourDownUpBaseWithoutUpdate"
    end
    local ctrl = m:AddComponent(LuaBehaviourName)
    ctrl:SetClass("MapController")


    local offset = self.cell_size2 * self.mapsizeconvertvalue
    local length = self.map_col * self.map_row
    for i = 1, length do
        local cell = m.transform:FindChild(tostring(i))
        table.insert(self.map_cells, { transform = cell, sharedMaterial = cell.gameObject.renderer.sharedMaterial, loaded = true, active = true, file = nil })

        cell.localScale = Vector3(offset, offset, 1)
    end

    if not BaseUtils.IsWideScreen() then
        for i = length + 1, 24 do
            local cell = m.transform:FindChild(tostring(i))
            cell.gameObject:SetActive(false)
        end
    end

    -- 审核服处理人审，对地图进行变色
    if BaseUtils.IsVerify then
        for i = 1, length do
            self.map_cells[i].sharedMaterial.color = BaseUtils.GetVerifyColor()
        end
    end

    local index = 1
    for i = self.map_row, 1, -1 do
        for j = 1, self.map_col do
            local offsetX = (j - (self.map_col + 1) / 2) * offset
            local offsetY = (i - (self.map_row + 1) / 2) * offset
            self.map_cells[index].transform.position = Vector3(offsetX, offsetY, 50)
            index = index + 1
        end
    end
    local oldScale = mapCollider.transform.localScale
    mapCollider.transform.localScale = Vector3(oldScale.x * offset, oldScale.y * offset, 1)
    m.transform.position = Vector3(-5, -5, 0)

    -- EventMgr.Instance:AddListener(event_name.map_move, mod_scene_manager.map_move)

    -- 小地图拉大
    self.miniMap = m.transform:FindChild("MiniMap").gameObject
    self.showMiniMap = false
    self.miniMapId = 0

    -- 点击特效
    local effectObject
    effectObject = GameObject.Instantiate(self.assetWrapper_ForScene:GetMainAsset("prefabs/effect/30003.unity3d"))
    effectObject.transform:SetParent(self.gameObject.transform)
    effectObject.name = "TargetPointEffect"
    effectObject.transform.localPosition = Vector3(-5, -5, 0)
    effectObject.transform.rotation = Quaternion.identity
    effectObject.transform:Rotate(Vector3(25, 0, 0))

    effectObject = GameObject.Instantiate(self.assetWrapper_ForScene:GetMainAsset("prefabs/effect/30003.unity3d"))
    effectObject.transform:SetParent(self.gameObject.transform)
    effectObject.name = "TargetPointEffect2"
    effectObject.transform.localPosition = Vector3(-5, -5, 0)
    effectObject.transform.rotation = Quaternion.identity
    effectObject.transform:Rotate(Vector3(25, 0, 0))

    effectObject = GameObject.Instantiate(self.assetWrapper_ForScene:GetMainAsset("prefabs/effect/30003.unity3d"))
    effectObject.transform:SetParent(self.gameObject.transform)
    effectObject.name = "TargetPointEffect3"
    effectObject.transform.localPosition = Vector3(-5, -5, 0)
    effectObject.transform.rotation = Quaternion.identity
    effectObject.transform:Rotate(Vector3(25, 0, 0))

    -- 选中特效
    effectObject = GameObject.Instantiate(self.assetWrapper_ForScene:GetMainAsset("prefabs/effect/30002.unity3d"))
    effectObject.transform:SetParent(self.gameObject.transform:FindChild("InstantiateObject"))
    effectObject.name = "SelectedEffect"
    effectObject.transform.localPosition = Vector3(-5, -5, 0)
    effectObject.transform.rotation = Quaternion.identity
    effectObject.transform:Rotate(Vector3(-20, 0, 0))

    -- 过场景特效
    local sceneTexture = gameObject.transform:FindChild("SceneTexture")
    sceneTexture:SetParent(ctx.MainCamera.transform)
    sceneTexture.localScale = Vector3(8.58, 3.9, 1)
    sceneTexture.localPosition = Vector3(0, 0, 0)
    SceneManager.Instance.MainCamera.sceneTexture = sceneTexture.gameObject

    -- mod_scene_manager.add_connection_handler()
    -- EventMgr.Instance:AddListener(event_name.begin_fight, mod_scene_manager.begin_fight)
    -- EventMgr.Instance:AddListener(event_name.end_fight, mod_scene_manager.end_fight)
    -- EventMgr.Instance:AddListener(event_name.enter_home, mod_scene_manager.enter_home)
    -- EventMgr.Instance:AddListener(event_name.exit_home, mod_scene_manager.exit_home)

    -- mod_scene_elements_manager.addlistener()

    -- if BaseUtils.GetPlatform() == "ios" then
    --     local role = self.gameObject.transform:FindChild("InstantiateObject/Role")
    --     role:FindChild("RoleName"):GetComponent("TextMesh").tabSize = 4
    --     role:FindChild("RoleName"):GetComponent("TextMesh").fontSize = 22
    --     role:FindChild("RoleNameShadow"):GetComponent("TextMesh").tabSize = 4
    --     role:FindChild("RoleNameShadow"):GetComponent("TextMesh").fontSize = 22
    --     role:FindChild("GuildName"):GetComponent("TextMesh").tabSize = 4
    --     role:FindChild("GuildName"):GetComponent("TextMesh").fontSize = 22
    --     role:FindChild("GuildNameShadow"):GetComponent("TextMesh").tabSize = 4
    --     role:FindChild("GuildNameShadow"):GetComponent("TextMesh").fontSize = 22
    -- end

    -- self.transportEffectClone = GameObject.Instantiate(self.assetWrapper_ForScene:GetMainAsset(string.format(AssetConfig.effect, 30194)))
    -- self.transportEffectClone.transform:SetParent(self.gameObject.transform)
    -- Utils.ChangeLayersRecursively(self.transportEffectClone.transform, "Default")
    -- -- self.transportEffect.transform.localRotation = Quaternion.identity
    -- -- self.transportEffect.transform:Rotate(Vector3(-20, 0, 0))
    -- -- self.transportEffect.transform.localScale = Vector3.one
    -- self.transportEffectClone:SetActive(false)

    self.mode.scene_elements = self.gameObject
    SceneManager.Instance.sceneElementsModel:OnLoadSceneElements()
end

-- 设置地图信息
function SceneView:SetMapData()
    if self.textureid == 0 then self.textureid = math.floor(ctx.sceneManager.Map.TextureId / 10) end
    self.currentmap_texturepath = self:GetMapTexturePath(self.textureid)

	local map = ctx.sceneManager.Map
    -- self.row_max = math.ceil(map.Height * self.sizeconvertvalue / self.cell_size)
    -- self.col_max = math.ceil(map.Width * self.sizeconvertvalue / self.cell_size)
    self.row_max = map.Height * self.sizeconvertvalue / self.cell_size
    self.col_max = map.Width * self.sizeconvertvalue / self.cell_size
    if self.row_max % 1 > 0.005 then
        self.row_max = math.ceil(self.row_max)
    else
        self.row_max = math.floor(self.row_max)
    end
    if self.col_max % 1 > 0.005 then
        self.col_max = math.ceil(self.col_max)
    else
        self.col_max = math.floor(self.col_max)
    end
    -- print(string.format("<color='#00ff00'>map.Width %s map.Height %s self.row_max %s self.col_max %s</color>", map.Width, map.Height, self.row_max, self.col_max))
    -- print(string.format("<color='#00ff00'>%s %s</color>", map.Height * self.sizeconvertvalue / self.cell_size, map.Width * self.sizeconvertvalue / self.cell_size))
    self.mapHeight = map.Height
end

function SceneView:GetMapTexturePath(textureId)
    local path = string.format("textures/maps/%s", textureId)
    if textureId == 10001 and self.mode.mapSeason == SceneConstData.MapSeason.Winter then
        path = "textures/maps/10001winter"
    end
    return path
end

-- 读取进入地图所需的图片
function SceneView:InitMapTexture(CameraX, CameraY)
    -- print(string.format("MapTransformX %s, MapTransformY %s", SceneManager.Instance.MainCamera.MapTransformX, SceneManager.Instance.MainCamera.MapTransformY))
    -- print(string.format("CameraX %s, CameraY %s", CameraX, CameraY))
    local map_row = self.map_row
    local map_col = self.map_col
    local cell_size = self.cell_size
    -- print("player.MapY    "..player.MapY)
    -- print("player.MapOffectY    "..player.MapOffectY)
    -- print("player.MapOffectY2    "..player.MapOffectY2)
    local x = math.floor(CameraX / self.mapsizeconvertvalue * self.sizeconvertvalue / cell_size + 0.5) * cell_size
    local y = math.floor(CameraY / self.mapsizeconvertvalue * self.sizeconvertvalue / cell_size + 0.5) * cell_size

    local mapHeight = self.mapHeight * self.sizeconvertvalue
    if mapHeight % cell_size ~= 0 then
        mapHeight = math.ceil(mapHeight / cell_size) * cell_size
    end
    local begin_row
    local begin_col
    -- print(string.format("x %s, y %s", x, y))
    -- print(string.format("x %s, y %s", CameraX / self.mapsizeconvertvalue* self.sizeconvertvalue, CameraY / self.mapsizeconvertvalue* self.sizeconvertvalue))

    if map_row % 2 == 0 then -- 行数为双数，直接镜头居中
        begin_row = (mapHeight - y - cell_size * map_row / 2) / cell_size
    else
        if SceneManager.Instance.MainCamera.MapOffectY > 0 then -- 如果镜头偏下，则创建图片也需要偏下
            begin_row = (mapHeight - y - cell_size * ((map_row + 1) / 2)) / cell_size
        else -- 如果镜头偏上，则创建图片也需要偏上
            begin_row = (mapHeight - y - cell_size * ((map_row - 1) / 2)) / cell_size
        end
    end

    if map_col % 2 == 0 then -- 列数为双数，直接镜头居中
        begin_col = (x - cell_size * map_col / 2) / cell_size
    else
        if SceneManager.Instance.MainCamera.MapOffectX < 0 then -- 如果镜头偏左，则创建图片也需要偏左
            begin_col = (x - cell_size * ((map_col + 1) / 2)) / cell_size
        else -- 如果镜头偏右，则创建图片也需要偏右
            begin_col = (x - cell_size * ((map_col - 1) / 2)) / cell_size
        end
    end

    -- print(string.format("mapHeight %s, cell_size %s, map_col %s, map_row %s ", mapHeight, cell_size, map_col, map_row))
    -- print(string.format("begin_row %s, begin_col %s ", begin_row, begin_col))
    -- print(string.format("MapOffectX %s, MapOffectX2 %s ", SceneManager.Instance.MainCamera.MapOffectX, SceneManager.Instance.MainCamera.MapOffectX2))
    -- print(string.format("MapOffectY %s, MapOffectY2 %s ", SceneManager.Instance.MainCamera.MapOffectY, SceneManager.Instance.MainCamera.MapOffectY2))

    local index = 1
    for i = 0, map_row-1 do
        for j = 0, map_col-1 do
            local row = begin_row+i
            local col = begin_col+j
            if row >= 0 and col >= 0 and row < self.row_max and col < self.col_max then
                local file = string.format("%s/map%s_%s.unity3d", self.currentmap_texturepath, col, row)
                local map_cell = self.map_cells[index]
                map_cell.file = file
                map_cell.loaded = false
            end

            index = index + 1
        end
    end

    local resources = {}
    for i = 0, map_row-1 do
        for j = 0, map_col-1 do
            local row = begin_row + i
            local col = begin_col + j
            if row >= 0 and col >= 0 and row < self.row_max and col < self.col_max then
                local file = string.format("%s/map%s_%s.unity3d", self.currentmap_texturepath, col, row)
                -- print(string.format("读取地图切片 %s", file))
                -- table.insert(resources, {file = file, type = AssetType.Main, holdTime = self.map_textures_holdTime, mapid = self.mapid, sceneAssetType = SceneConstData.MapCell })
                if not self.assetWrapper_ForScene:InAssetPoor(file) then
                    -- print(string.format("读取地图切片 %s", file))
                    -- Log.Debug(string.format("从内存读取地图 %s", file))
                    table.insert(resources, {file = file, type = AssetType.Main, holdTime = self.map_textures_holdTime, mapid = self.mapid, sceneAssetType = SceneConstData.MapCell})
                else
                    -- Log.Debug(string.format("从缓存读取地图 %s", file))
                    local asset = self.assetWrapper_ForScene:GetAssetPoorCache(file)
                    asset.leavetime = nil
                end
            end
        end
    end

    local fun = function()
        for key,map_cell in pairs(self.map_cells) do
            if not map_cell.loaded then
                -- print(string.format("              读取地图切块成功 %s", map_cell.file))
                local mainTexture = self.assetWrapper_ForScene:GetMainAsset(map_cell.file)
                if BaseUtils.IsVerify then
                    mainTexture = BaseUtils.VestMapTexture(map_cell.file)
                end
                map_cell.sharedMaterial.mainTexture = mainTexture
                map_cell.loaded = true
                if mainTexture == nil then
                    if map_cell.active then map_cell.transform.gameObject:SetActive(false) end
                    map_cell.active = false
                else
                    if not map_cell.active then map_cell.transform.gameObject:SetActive(true) end
                    map_cell.active = true
                end
                mainTexture = nil
            end
        end
        self.mode:LoadMapTextureCompelete()

        local resources2 = {}
        for i = -1, map_row do
            for j = -1, map_col do
                local row = begin_row + i
                local col = begin_col + j
                if row >= 0 and col >= 0 and row < self.row_max and col < self.col_max then
                    local file = string.format("%s/map%s_%s.unity3d", self.currentmap_texturepath, col, row)
                    -- print(string.format("读取地图切片 %s", file))
                    -- table.insert(resources2, {file = file, type = AssetType.Main, holdTime = self.map_textures_holdTime, mapid = self.mapid, sceneAssetType = SceneConstData.MapCell})
                    if not self.assetWrapper_ForScene:InAssetPoor(file) then
                        -- print(string.format("读取地图切片 %s", file))
                        -- Log.Debug(string.format("从内存读取地图 %s", file))
                        table.insert(resources2, {file = file, type = AssetType.Main, holdTime = self.map_textures_holdTime, mapid = self.mapid, sceneAssetType = SceneConstData.MapCell})
                    else
                        -- Log.Debug(string.format("从缓存读取地图 %s", file))
                        local asset = self.assetWrapper_ForScene:GetAssetPoorCache(file)
                        asset.leavetime = nil
                    end
                end
            end
        end

        local fun2 = function()
            self.mode:LoadMapTextureCompelete2()
        end
        local subResources = SubpackageManager.Instance:MapResources(resources2)
        if #subResources == #resources2 and not self.alwaysShowMiniMap then
            self:ShowMiniMapTexture(false)
        else
            self:ShowMiniMapTexture(false)
            self:ShowMiniMapTexture(true)
        end
        LuaTimer.Add(0, 1, function(id) LuaTimer.Delete(id) self.assetWrapper_ForScene:LoadAssetBundle(subResources, fun2)     end)
    end

    local subResources = SubpackageManager.Instance:MapResources(resources)
    if #subResources == #resources and not self.alwaysShowMiniMap then
        self:ShowMiniMapTexture(false)
    else
        self:ShowMiniMapTexture(false)
        self:ShowMiniMapTexture(true)
    end
    self.assetWrapper_ForScene:LoadAssetBundle(subResources, fun)
end

-- 移动地图，更新地图图片
function SceneView:MapMove(MapTransformX, MapTransformY, CameraX, CameraY)
    self.map_transform.position = Vector3(MapTransformX, MapTransformY, 0)
    self:MoveMiniMapTexture()
    -- print(string.format("MapTransformX %s, MapTransformY %s", MapTransformX, MapTransformY))
    -- print(string.format("CameraX %s, CameraY %s", CameraX, CameraY))
    local map_row = self.map_row
    local map_col = self.map_col
    local cell_size = self.cell_size
    -- print("player.MapY    "..player.MapY)
    -- print("player.MapOffectY    "..player.MapOffectY)
    -- print("player.MapOffectY2    "..player.MapOffectY2)
    local x = math.floor(CameraX / self.mapsizeconvertvalue * self.sizeconvertvalue / cell_size + 0.5) * cell_size
    local y = math.floor(CameraY / self.mapsizeconvertvalue * self.sizeconvertvalue / cell_size + 0.5) * cell_size

    local mapHeight = self.mapHeight * self.sizeconvertvalue
    if mapHeight % cell_size ~= 0 then
        mapHeight = math.ceil(mapHeight / cell_size) * cell_size
    end
    local begin_row
    local begin_col
    -- print(string.format("x %s, y %s", x, y))

    if map_row % 2 == 0 then -- 行数为双数，直接镜头居中
        begin_row = (mapHeight - y - cell_size * map_row / 2) / cell_size
    else
        if SceneManager.Instance.MainCamera.MapOffectY > 0 then -- 如果镜头偏下，则创建图片也需要偏下
            begin_row = (mapHeight - y - cell_size * ((map_row + 1) / 2)) / cell_size
        else -- 如果镜头偏上，则创建图片也需要偏上
            begin_row = (mapHeight - y - cell_size * ((map_row - 1) / 2)) / cell_size
        end
    end

    if map_col % 2 == 0 then -- 列数为双数，直接镜头居中
        begin_col = (x - cell_size * map_col / 2) / cell_size
    else
        if SceneManager.Instance.MainCamera.MapOffectX < 0 then -- 如果镜头偏左，则创建图片也需要偏左
            begin_col = (x - cell_size * ((map_col + 1) / 2)) / cell_size
        else -- 如果镜头偏右，则创建图片也需要偏右
            begin_col = (x - cell_size * ((map_col - 1) / 2)) / cell_size
        end
    end

    -- print(string.format("mapHeight %s, cell_size %s, map_col %s, map_row %s ", mapHeight, cell_size, map_col, map_row))
    -- print(string.format("begin_row %s, begin_col %s ", begin_row, begin_col))
    -- print(string.format("MapOffectX %s, MapOffectX2 %s ", SceneManager.Instance.MainCamera.MapOffectX, SceneManager.Instance.MainCamera.MapOffectX2))
    -- print(string.format("MapOffectY %s, MapOffectY2 %s ", SceneManager.Instance.MainCamera.MapOffectY, SceneManager.Instance.MainCamera.MapOffectY2))

    local index = 1
    for i = 0, map_row-1 do
        for j = 0, map_col-1 do
            self:LoadMapCellTexture(index, begin_row+i, begin_col+j)
            index = index + 1
        end
    end

    local resources = {}
    for i = -1, map_row do
        for j = -1, map_col do
            local row = begin_row + i
            local col = begin_col + j
            if row >= 0 and col >= 0 and row < self.row_max and col < self.col_max then
                local file = string.format("%s/map%s_%s.unity3d", self.currentmap_texturepath, col, row)
                if not self.assetWrapper_ForScene:InAssetPoor(file) then
                    -- print(string.format("读取地图切片 %s", file))
                    -- Log.Debug(string.format("从内存读取地图 %s", file))
                    table.insert(resources, {file = file, type = AssetType.Main, holdTime = self.map_textures_holdTime, mapid = self.mapid, sceneAssetType = SceneConstData.MapCell})
                else
                    -- Log.Debug(string.format("从缓存读取地图 %s", file))
                    local asset = self.assetWrapper_ForScene:GetAssetPoorCache(file)
                    asset.leavetime = nil
                end
            end
        end
    end

    -- print(string.format("读取地图切片 数量%s", #resources))
    if #resources > 0 then
        local subResources = SubpackageManager.Instance:MapResources(resources)
        if #subResources ~= #resources or self.alwaysShowMiniMap then
            self:ShowMiniMapTexture(false)
            self:ShowMiniMapTexture(true)
        end

        local fun = function()
            for key,map_cell in pairs(self.map_cells) do
                if not map_cell.loaded and self.assetWrapper_ForScene:InAssetPoor(map_cell.file) then
                    -- print(string.format("              读取地图切块成功 %s", map_cell.file))
                    map_cell.sharedMaterial.mainTexture = self.assetWrapper_ForScene:GetMainAsset(map_cell.file)
                    if BaseUtils.IsVerify then
                        map_cell.sharedMaterial.mainTexture = BaseUtils.VestMapTexture(map_cell.file)
                    end
                    map_cell.loaded = true
                    if not map_cell.active then map_cell.transform.gameObject:SetActive(true) end
                    map_cell.active = true
                end
            end
            if #subResources == #resources and not self.alwaysShowMiniMap then
                self:ShowMiniMapTexture(false)
            end
        end
        self.assetWrapper_ForScene:LoadAssetBundle(subResources, fun)
    end
end

function SceneView:LoadMapCellTexture(cell, row, col)
    -- print(string.format("cell %s row %s col %s", cell, row, col))
    if row >= 0 and col >= 0 and row < self.row_max and col < self.col_max then
        local file = string.format("%s/map%s_%s.unity3d", self.currentmap_texturepath, col, row)
        local map_cell = self.map_cells[cell]
        map_cell.file = file

        -- print(string.format("查找缓存记录 %s", file))
        -- print(string.format("cell %s file %s", cell, file))
        if self.assetWrapper_ForScene:InAssetPoor(file) then
            -- print(string.format("显示地区地图切块 %s", file))
            map_cell.sharedMaterial.mainTexture = self.assetWrapper_ForScene:GetMainAsset(file)
            if BaseUtils.IsVerify then
                map_cell.sharedMaterial.mainTexture = BaseUtils.VestMapTexture(file)
            end
            map_cell.loaded = true
            if not map_cell.active then map_cell.transform.gameObject:SetActive(true) end
            map_cell.active = true
        else
            -- print(string.format("没有缓存记录 %s", file))
            map_cell.loaded = false
            if map_cell.active then map_cell.transform.gameObject:SetActive(false) end
            map_cell.active = false
            -- map_cell.sharedMaterial.mainTexture = nil
        end
    else
        local map_cell = self.map_cells[cell]
        if map_cell.active then map_cell.transform.gameObject:SetActive(false) end
        map_cell.active = false
    end
end

function SceneView:ShowMiniMapTexture(show)
    if show then
        if self.miniMapId ~= self.textureid then
            self.miniMapId = self.textureid

            local resList = {{file = string.format(AssetConfig.minimaps, self.miniMapId), type = AssetType.Main}}
            local OnCompleted = function() self:OnLoadMiniMapTexture() end
            self:LoadAssetBundleBatch(resList, OnCompleted)
        elseif not self.showMiniMap then
            self.miniMap:SetActive(true)
            self.showMiniMap = true
        end
    else
        if self.showMiniMap then
            self.miniMap:SetActive(false)
        end
        self.showMiniMap = false
        self.miniMapId = 0
    end
end

function SceneView:OnLoadMiniMapTexture()
    if self.miniMapId == self.textureid then
        if not self.showMiniMap then
            self.miniMap:SetActive(true)
            self.showMiniMap = true
            local file = string.format(AssetConfig.minimaps, self.miniMapId)
            local sharedMaterial = self.assetWrapper:GetMainAsset(file)
            if BaseUtils.IsVerify then
                sharedMaterial = BaseUtils.VestMiniMapTexture(self.miniMapId)
            end
            self.miniMap.renderer.sharedMaterial.mainTexture  = sharedMaterial

            local map = ctx.sceneManager.Map
            local height = map.Height * self.mapsizeconvertvalue
            local width = height
            if map.MapWidth > map.MapHeight then
                width = height * 2
                self.miniMap.transform.localScale = Vector3(width, height, 1)
            else
                self.miniMap.transform.localScale = Vector3(width, height, 1)
            end
            local miniMapWidth = map.Width * height / map.Height

            self.miniMapX = width/2 + (miniMapWidth - width)
            self.miniMapY = height/2
            self.miniMap.transform.position = Vector3(self.miniMapX, self.miniMapY, 60)

            if BaseUtils.IsVerify then
                self.miniMap.renderer.sharedMaterial.color = BaseUtils.GetVerifyColor()
            end
        end
    end
end

function SceneView:MoveMiniMapTexture()
    if self.showMiniMap and self.miniMapId == self.textureid then
        self.miniMap.transform.position = Vector3(self.miniMapX, self.miniMapY, 60)
    end
end

function SceneView:ShowTransportEffect()
    -- if self.gameObject == nil then
    --     return
    -- end

    -- if self.transportEffectTimerId ~= nil then
    --     LuaTimer.Delete(self.transportEffectTimerId)
    --     self.transportEffectTimerId = nil
    -- end
    -- self.transportEffectTimerId = LuaTimer.Add(300, function()
    --     if not BaseUtils.is_null(self.transportEffect) then
    --         self.transportEffect:SetActive(false)
    --     end
    -- end)

    -- if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
    --     if BaseUtils.is_null(self.transportEffect) then
    --         self.transportEffect = GameObject.Instantiate(self.transportEffectClone)
    --         self.transportEffect.transform:SetParent(SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform)
    --     end

    --     self.transportEffect:SetActive(false)
    --     self.transportEffect:SetActive(true)


    --     self.transportEffect.transform.localRotation = Quaternion.identity
    --     self.transportEffect.transform:Rotate(Vector3(-20, 0, 0))
    --     self.transportEffect.transform.localScale = Vector3.one
    --     local p = SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform.position
    --     self.transportEffect.transform.position = Vector3(p.x, p.y, -20)
    -- end
end

-- 资源加载
function SceneView:LoadAssetBundleBatch(resList, OnCompleted)
    if self.assetWrapper == nil then
        self.assetWrapper = AssetBatchWrapper.New()
        local callback = function()
            OnCompleted()
            self:OnResLoadCompleted()
        end
        self.assetWrapper:LoadAssetBundle(resList, callback)
    else
        BaseUtils.enqueue(self.loadList, { resList = resList, OnCompleted = OnCompleted })
    end
end

-- 资源加载完成，加载下一波资源
function SceneView:OnResLoadCompleted()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if self.gameObject == nil then return end

    local loadData = BaseUtils.dequeue(self.loadList)
    if loadData ~= nil then
        self:LoadAssetBundleBatch(loadData.resList, loadData.OnCompleted)
    end
end
