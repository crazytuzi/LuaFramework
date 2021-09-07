SceneModel = SceneModel or BaseClass(BaseModel)

local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2

function SceneModel:__init()
    self.sceneView = nil
    self.mapclicker = nil

    ------------ 标记信息 ------------
    self.map_loaded = false -- 地图读取完成
    self.map_data_cache = nil -- 地图正在加载，新的地图协议又来了，就先缓存起来

    ------------ 地图信息 ------------
    self.mapHeight = 0

    self.map_list = {} -- 去过的地图列表 {mapid = 地图id, time = 离开时间}

    ------------ 各种常量 ------------
    -- self.mapsizeconvertvalue = 0.00526315
    self.mapsizeconvertvalue = SceneManager.Instance.Mapsizeconvertvalue

    ------------------------------------
    self.change_map_pos_list = {}
    ------------------------------------
    self.maincamera_effect_snow = nil -- 飘雪特效
    self.mapSeason = self:GetMapSeason()
end

function SceneModel:__delete()

end

function SceneModel:InitSceneView()
    if self.sceneView == nil then
        self.sceneView = SceneView.New(self)
        self.sceneView:LoadSceneElements()
    end
end

function SceneModel:CloseSceneView()
    if self.sceneView ~= nil then
        self.sceneView:DeleteMe()
        self.sceneView = nil
    end
end

function SceneModel:Clean(active)
    if self.sceneView ~= nil then
        self.sceneView:Clean()
    end
    self.map_loaded = false -- 地图读取完成
    self.map_data_cache = nil
    self.mapHeight = 0
end

function SceneModel:SetSceneActive(active)
    if self.sceneView ~= nil and self.sceneView.gameObject ~= nil then
        self.sceneView.gameObject:SetActive(active)
    end
end

function SceneModel:jump_map_by_cache()
    print("jump_map_by_cache")
    if self.map_data_cache ~= nil then
        self:jump_map(self.map_data_cache)
    end
end

function SceneModel:jump_map(data)
    self.map_data_cache = nil

    self.enterSceneX = data.x
    self.enterSceneY = data.y

    self:Loadmap(data.base_id, data.res_id)

    -- if data.base_id == self.sceneView.mapid and (data.res_id == 0 or data.res_id == self.sceneView.textureid) and self.map_loaded then
    --     self:JumpInSamemap()
    -- else
    --     self:Loadmap(data.base_id, data.res_id)
    -- end
end

-- 读地图数据
function SceneModel:Loadmap(map_id, res_id)
    if DataMap.data_list[map_id] == nil then
        Log.Debug(string.format("传送的目标地图不存在 %s, 请找服务端提交 data_map.lua", map_id))
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("传送的目标地图不存在 %s"), map_id))
    else
        if self.sceneView.mapid ~= nil then
            table.insert(self.map_list, {mapid = self.sceneView.mapid, time = Time.time})
            self.sceneView.assetWrapper_ForScene:Set_MapCellAsset_Leavetime(self.sceneView.mapid)

            local map_cell_num = self.sceneView.assetWrapper_ForScene:Get_MapCellAsset_Num()
            -- print(string.format("map_cell_num %s ", map_cell_num))
            print(string.format(TI18N("<color='#00ff00'>缓存的地图图块数量 %s %s</color>"), map_cell_num, self.sceneView.map_textures_cache_maxnum))
            if map_cell_num > self.sceneView.map_textures_cache_maxnum then
                local onSort = function(a, b)
                    return a.time < b.time
                end
                table.sort(self.map_list, onSort)

                while #self.map_list > 0 and map_cell_num > self.sceneView.map_textures_cache_maxnum do
                    local data = self.map_list[1]
                    table.remove(self.map_list, 1)
                    local del_cell_num = self.sceneView.assetWrapper_ForScene:Set_MapCellAsset_DelNow(self.sceneView.mapid, map_id)
                    if del_cell_num == 0 then
                        map_cell_num = 0
                    else
                        map_cell_num = map_cell_num - del_cell_num
                    end
                end
            end
        end

        self.sceneView.alwaysShowMiniMap = false
        EventMgr.Instance:Fire(event_name.start_scene_load, map_id)
        self.sceneView.mapid = map_id
        self.sceneView.textureid = res_id

        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(false)

        -- SceneManager.Instance.MainCamera:Screenshot()
        -- SceneManager.Instance.MainCamera:Screenshot_AndAlpha()
        SceneManager.Instance.MainCamera:UnloadAssets()
        -- self.sceneView:ShowTransportEffect()

        self.map_loaded = false
        SceneManager.Instance.sceneElementsModel:CleanElements()
        HomeManager.Instance.homeElementsModel:CleanElements()
        self.change_map_pos_list = {}
        self:PlayBGM()
        if self.mapSeason == SceneConstData.MapSeason.Winter then
            self:ShowEffect() -- 圣心城雪花特效
        end
        -- LuaTimer.Add(300, function()
            -- SceneManager.Instance.MainCamera:ScreenshotAlpha()
            -- SceneManager.Instance.MainCamera:Screenshot_AndAlpha()
            ctx.sceneManager:EnterScene(tonumber(self.sceneView.mapid))
        -- end)


        -- if BaseUtils.IsWideScreen() then
        --     SceneManager.Instance.DefaultCameraSize = 1.73
        -- else
        --     SceneManager.Instance.DefaultCameraSize = 1.95
        -- end
        -- SceneManager.Instance.MainCamera.camera.orthographicSize = SceneManager.Instance.DefaultCameraSize
    end
end

function SceneModel:PlayBGM()
    --播放背景场景音乐
    local bgm_data = DataSystem.data_bgm[self.sceneView.mapid]
    if bgm_data == nil then
        SoundManager.Instance:PlayBGM(SoundEumn.Background_MainCity)
    else
        SoundManager.Instance:PlayBGM(bgm_data.bgmid)
    end
end

function SceneModel:ShowEffect()
    local timeToSnow = false
    local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    if currentHour >= 18 and currentHour <= 23 then
        timeToSnow = true
    end
    if SettingManager.Instance:GetResult(SettingManager.Instance.THideEffect) then
        timeToSnow = false
    end

    if self.sceneView.mapid == 10001 and timeToSnow then
        if self.maincamera_effect_snow == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(SceneManager.Instance.MainCamera.gameObject.transform)
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = Vector3(0, 0, 0)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "SceneEffect")

                if BaseUtils.IsWideScreen() then
                    local scaleX = (ctx.ScreenWidth / ctx.ScreenHeight) / (16 / 9)
                    effectObject.transform.localScale = Vector3(scaleX, 1, 1)
                else
                    local scaleY = (ctx.ScreenHeight/ ctx.ScreenWidth) / (9 / 16)
                    effectObject.transform.localScale = Vector3(1, scaleY, 1)
                end
            end
            self.maincamera_effect_snow = BaseEffectView.New({effectId = 30163, time = nil, callback = fun})
        end
    else
        if self.maincamera_effect_snow ~= nil then
            GameObject.Destroy(self.maincamera_effect_snow.gameObject)
            self.maincamera_effect_snow = nil
        end
    end

end
-- 地图数据读取完成
function SceneModel:LoadMapTexture()
    print("LoadMapTexture")
    -- SceneManager.Instance.Send10122()

    self.mapHeight = ctx.sceneManager.Map.Height
    self.sceneView:SetMapData()
    SceneManager.Instance.MainCamera:SetMapData()

    local p = self:transport_small_pos(self.enterSceneX, self.enterSceneY)
    -- SceneManager.Instance.MainCamera:JumpTo(p.x, p.y)
    SceneManager.Instance.MainCamera:SetPosition_InitMap(p.x, p.y)
    -- self.sceneView:InitMap(p.x, p.y)
end

-- 地图资源读取完成,  读取完当前需要显示的地图
function SceneModel:LoadMapTextureCompelete()
    self.map_loading = false
    self.map_loaded = true
    SceneManager.Instance:Send10120()
    SceneManager.Instance:Send10122()

    local mainCamera = SceneManager.Instance.MainCamera
    mainCamera.transform.position = Vector3(mainCamera.x, mainCamera.y, -10)
    self.sceneView.map_transform.position = Vector3(mainCamera.MapTransformX, mainCamera.MapTransformY, 0)

    local self_view = SceneManager.Instance.sceneElementsModel.self_view
    if self_view ~= nil then
        -- print(string.format("self.enterSceneX, self.enterSceneY   %s %s", self.enterSceneX, self.enterSceneY))
        self_view:JumpTo_by_big_pos(self.enterSceneX, self.enterSceneY)
    end
    SceneManager.Instance.sceneElementsModel.mapid = self.sceneView.mapid
    SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
end

-- 地图资源读取完成,  读取完当前食野周围的地图
function SceneModel:LoadMapTextureCompelete2()
    SceneManager.Instance:Send10112()

    LuaTimer.Add(50, function()
        -- print("LoadMapTextureCompelete2")

        if self.map_data_cache == nil then
            EventMgr.Instance:Fire(event_name.scene_load, self.sceneView.mapid)
        else
            self:jump_map_by_cache()
        end

        -- local count = 0
        -- for i = 1, 999999999 do
        --     count = count + 1
        -- end
    end)
end

function SceneModel:JumpInSamemap()
    -- print("JumpInSamemap")
    self.map_loaded = true
    self.map_loading = false

    -- SceneManager.Instance.MainCamera:Screenshot_AndAlpha()
    SceneManager.Instance.MainCamera:UnloadAssets()
    self:LoadMapTexture()

    -- local self_view = SceneManager.Instance.sceneElementsModel.self_view
    -- if self_view ~= nil then
    --     print(string.format("self.enterSceneX, self.enterSceneY   %s %s", self.enterSceneX, self.enterSceneY))
    --     self_view:JumpTo_by_big_pos(self.enterSceneX, self.enterSceneY)
    -- end

    -- -- mod_scene_elements_manager.check_elements()
    -- -- mod_scene_manager.path()
    -- -- EventMgr.Instance:Fire(event_name.map_loaded)
    -- EventMgr.Instance:Fire(event_name.scene_load)
end

function SceneModel:ChangeMapUnwalk(data)
    print("ChangeMapUnwalk")  print("!") print("!") print("!") print("!") print("!")
    local row = ctx.sceneManager.Map.Row
    for _,value in ipairs(data.pos) do
        value.y = row - 1 - value.y
    end
    -- BaseUtils.dump(data, "<color=#ff0000>ChangeMapUnwalk</color>")
    local map_data = {}
    map_data.base_id = data.base_id
    map_data.flag = 1
    map_data.pos = data.pos
    ctx.sceneManager:ModifyMap(map_data)

    -- xpcall(function() ctx.sceneManager:ModifyMap(map_data) end
    --     ,function(err) 
    --         local errorMsg = { x_min = 999, x_max = -999, y_min = 999, y_max = -999}
    --         for _,value in ipairs(data.pos) do
    --             value.y = row - 1 - value.y

    --             if value.x > errorMsg.x_max then
    --                 errorMsg.x_max = value.x
    --             end
    --             if value.x < errorMsg.x_min then
    --                 errorMsg.x_min = value.x
    --             end
    --             if value.y > errorMsg.y_max then
    --                 errorMsg.y_max = value.y
    --             end
    --             if value.y < errorMsg.y_min then
    --                 errorMsg.y_min = value.y
    --             end
    --         end
    --         Log.Error(string.format("动态地图出错了: map_base_id = %s, x_min = %s, x_max = %s, y_min = %s, y_max = %s, ", data.base_id, errorMsg.x_min, errorMsg.x_max, errorMsg.y_min, errorMsg.y_max) .. tostring(err))
    --     end)
        
    self.change_map_pos_list = {}
    for _,value in ipairs(data.pos) do
        table.insert(self.change_map_pos_list, { flag = 1, x = value.x, y = value.y })
    end

    HomeManager.Instance.model:UpdateMapGrid(map_data)
end

function SceneModel:ChangeMap(data)
    local row = ctx.sceneManager.Map.Row
    -- BaseUtils.dump(data, "<color=#ff0000>ChangeMap</color>")
    for _,value in ipairs(data.pos) do
        value.y = row - 1 - value.y
    end
    local map_data = {}
    map_data.base_id = data.base_id
    map_data.flag = data.flag
    map_data.pos = data.pos
    ctx.sceneManager:ModifyMap(map_data)

    -- xpcall(function() ctx.sceneManager:ModifyMap(map_data) end
    --     ,function(err) 
    --         local errorMsg = { x_min = 999, x_max = -999, y_min = 999, y_max = -999}
    --         for _,value in ipairs(data.pos) do
    --             value.y = row - 1 - value.y

    --             if value.x > errorMsg.x_max then
    --                 errorMsg.x_max = value.x
    --             end
    --             if value.x < errorMsg.x_min then
    --                 errorMsg.x_min = value.x
    --             end
    --             if value.y > errorMsg.y_max then
    --                 errorMsg.y_max = value.y
    --             end
    --             if value.y < errorMsg.y_min then
    --                 errorMsg.y_min = value.y
    --             end
    --         end
    --         Log.Error(string.format("动态地图出错了: map_base_id = %s, x_min = %s, x_max = %s, y_min = %s, y_max = %s, ", data.base_id, errorMsg.x_min, errorMsg.x_max, errorMsg.y_min, errorMsg.y_max) .. tostring(err))
    --     end)

    for _,value in ipairs(data.pos) do
        local mark = true
        for __,value2 in ipairs(self.change_map_pos_list) do
            if value.x == value2.x and value.y == value2.y then
                value2.flag = data.flag
                mark = false
            end
        end
        if mark then
            table.insert(self.change_map_pos_list, { flag = data.flag, x = value.x, y = value.y })
        end
    end

    HomeManager.Instance.model:UpdateMapGrid(map_data)
end

function SceneModel:GetChangeMapPos(x, y)
    -- BaseUtils.dump(self.change_map_pos_list)
    for _,value in ipairs(self.change_map_pos_list) do
        if value.x == x and value.y == y then
            return value.flag
        end
    end
    return nil
end


--******************************--
--******************************--
------------ Mark 地图工具 ------------
--******************************--
--******************************--
--转换坐标系(小坐标)
function SceneModel:get_py_small(_y)
    return math.abs(self.mapHeight * self.mapsizeconvertvalue - _y)
end

--转换坐标系(大坐标)
function SceneModel:get_py_big(_y)
    return math.abs(self.mapHeight - _y)
end

--大坐标转换成小坐标
function SceneModel:transport_small_pos(_x, _y)
    return Vector2(_x * self.mapsizeconvertvalue, math.abs(self.mapHeight - _y) * self.mapsizeconvertvalue)
end

--小坐标转换成大坐标
function SceneModel:transport_big_pos(_x, _y)
    return Vector2(_x / self.mapsizeconvertvalue, math.abs(self.mapHeight - _y / self.mapsizeconvertvalue))
end

--暂用立冬11月8日，立春2月4日判断
function SceneModel:GetMapSeason()
    local month = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local day = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    if month > 11 or month < 2 then
        return SceneConstData.MapSeason.Winter
    end
    if month == 11 and day >= 8 then
        return SceneConstData.MapSeason.Winter
    end
    if month == 2 and day <= 4 then
        return SceneConstData.MapSeason.Winter
    end
    return SceneConstData.MapSeason.None
end
