--
-- @Author: chk
-- @Date:   2018-07-19 10:46:49
--

require('game.scene.map.MapLayer')
require('game.scene.map.MapBlock')
require('game.scene.map.MapSkyBox')

MapManager = MapManager or class("MapManager", BaseManager)
--local MapManager = MapManager

MapManager.screenWidth = 0
MapManager.screenHeight = 0
MapManager.halfScreenHeight = 0;
MapManager.halfScreenWidth = 0;

local Time = Time
local table_insert = table.insert
local table_remove = table.remove
local math_abs = math.abs
local math_sin = math.sin
local math_cos = math.cos
local math_floor = math.floor

function MapManager:ctor()
    MapManager.Instance = self
    self.birth_point = { x = 0, y = 0 }
    self.last_point = nil
    self.crnt_point = nil
    self.events = {};
    self:InitData()
    self:Reset()

    self.map_layer = MapLayer:GetInstance()

    self.camera_pos = { x = 0, y = 0, z = 0 }

    --地块大小
    self.split_map_size = 1
    --地块一行多少个
    self.split_maps_width = 1
    --地图像素宽
    self.map_pixels_width = 1
    --地图像素高
    self.map_pixels_height = 1

    --是否已结束处理时间轴
    self.is_end_handle_timeline = true

    --是否已结束机甲竞速
    self.is_end_race = true 

    -- FixedUpdateBeat:Add(self.Update, self, 3, 1)
    LateUpdateBeat:Add(self.Update, self, 3, 1)
end

function MapManager:Reset()

end

function MapManager.GetInstance()
    if MapManager.Instance == nil then
        MapManager()
    end
    return MapManager.Instance
end

function MapManager:InitData()
    self.pixelsPerUnit = SceneConstant.PixelsPerUnit

    self.camLeftPointExtend = Vector2(0, 0)    --摄像机左边延伸点(像素单位)
    self.camRightPointExtend = Vector2(0, 0)   --摄像机右边延伸点(像素单位)
    self.camUpPointExtend = Vector2(0, 0)      --摄像机上边延伸点(像素单位)
    self.camDownPointExtend = Vector2(0, 0)    --摄像机下边延伸点(像素单位)

    self.sceneCamCanMoveToPosTemp = Vector2(0, 0)          --假定摄像机可以移动到的位置(像素单位)
    self.sceneCamCanMoveToPosWorld = Vector3(0, 0, -10000) --(世界坐标)

    self.needLoadResIDLst = {}

    self.sceneCameraSpeed = Vector2(0, 0)

    self.camera_base_size = AppConfig.scene_camera_size
    -- self.camera_base_size = 9.0

    self.shake_info_list = {}

    self:AdjustScene()

    self:AddEvent()
end

function MapManager:AddEvent()
    self.event_id_list = {}
    local function call_back()
        if not LoadingCtrl:GetInstance().loadingPanel then
            self:CheckArenaFight()
        end
    end
    self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

    local function call_back()
        self:CheckArenaFight()
    end
    self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.DestroyLoading, call_back)
    
    local function call_back()
       self.is_end_handle_timeline = false
    end
    self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.StartHandleTimeline, call_back)
    local function call_back()
        self.is_end_handle_timeline = true
     end
     self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.EndHandleTimeline, call_back)

     local function call_back()
        self.is_end_race = false
     end
     self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.StartRace, call_back)
     local function call_back()
         self.is_end_race = true
      end
      self.event_id_list[#self.event_id_list+1] = GlobalEvent:AddListener(EventName.EndRace, call_back)
end

--切换场景后检查相机动作配置
function MapManager:CheckArenaFight()
    local scene_id = SceneManager:GetInstance():GetSceneId()
    local cf = SceneCameraActionConfig[scene_id]
    if cf then
        --是否正在执行相机动作配置
        self.is_scene_camera_action = true

        --相机动作已执行时间
        self.scene_camera_all_time = 0

        --相机开始视野大小
        self.scene_camera_start_size = cf.Scale * AppConfig.scene_camera_size

        --相机开始视野大小与正常视野大小的差距
        self.scene_camera_offset_size = AppConfig.scene_camera_size - self.scene_camera_start_size

        --相机延迟结束时间
        self.scene_camera_delta_end_time = Time.time + cf.DelayTime

        --相机动作配置
        self.scene_camera_action_cf = cf

        self:SetCameraSize(self.scene_camera_start_size)
        
        if cf.PosType == 1 then
            --1 锁定位置 固定在中间
            local x = self.map_pixels_width * 0.5
            local y = self.map_pixels_height * 0.5
            local z = self.sceneCamCanMoveToPosWorld.z
            self:SceneCamMove(x,y)
            self:SetCameraPos(x * 0.01,y * 0.01,z)
        end
    else
        self.is_scene_camera_action = false
        self.scene_camera_action_cf = nil
        self:SetCameraSize(AppConfig.scene_camera_size)
    end 
end

--相机动作配置执行
function MapManager:UpdateArenaFight(deltaTime)
    if not self.is_scene_camera_action or not self.scene_camera_action_cf then
        return
    end
    if self.scene_camera_delta_end_time - Time.time > 0 then
        --延迟未结束 不执行动作
        return
    end

    --刷新相机动作已执行时间
    self.scene_camera_all_time = self.scene_camera_all_time + deltaTime

    --计算时间比例
    local t = self.scene_camera_all_time/self.scene_camera_action_cf.ActionTime
    if t > 1 then
        t = 1
    end

    --根据比例刷新相机视野大小
    local new_size = self.scene_camera_start_size + t * self.scene_camera_offset_size
    self:SetCameraSize(new_size)

    if self.cur_camera_size == 1 then
        self.is_scene_camera_action = false
    end
end

function MapManager:AdjustScene()
    self.sceneCamera = GameObject.Find("SceneCamera"):GetComponent('Camera')
    self.uiCamera = GameObject.Find("UICamera"):GetComponent('Camera')

    -- 剔除阻挡
    self.uiCamera.useOcclusionCulling = false
    -- 允许渲染高动态色彩画面
    self.uiCamera.allowHDR = false
    -- 允许进行硬件抗锯齿
    self.uiCamera.allowMSAA = false
    -- 动态缩放
    self.uiCamera.allowDynamicResolution = false

    self:SetCameraSize(self.camera_base_size)
    self.sceneCamera_transform = self.sceneCamera.transform
    -- self.sceneCamera_transform.position = Vector3(width, self.camera_base_size, -1000)
    SetLocalPosition(self.sceneCamera_transform,width, self.camera_base_size, -1000)

    self:TestAdaptation()
end

---设置场景相机是否可用
function MapManager:SetSceneCameraEnable(bool)
    if(self.sceneCamera) then
       SetVisible(self.sceneCamera.gameObject, bool)
    end
end

function MapManager:SetCameraSize(size)
    if self.cur_camera_size == size then
        return
    end
    local resRatio = Screen.height / Screen.width
    local width = size / resRatio

    -- local screenWidth = width * 100 * 2
    -- local screenHeight = size * 100 * 2
    local halfScreenWidth = width * 100
    local halfScreenHeight = size * 100

    if size > self.camera_base_size and not self.is_scene_camera_action then
        if self.camera_pos.x <= halfScreenWidth or self.camera_pos.x >= self.map_pixels_width - halfScreenWidth or
                self.camera_pos.y <= halfScreenHeight or self.camera_pos.y >= self.map_pixels_height - halfScreenHeight then
            return false
        end
    end

    self.screenWidth = width * 100 * 2
    self.screenHeight = size * 100 * 2

    self.halfScreenWidth = halfScreenWidth
    self.halfScreenHeight = halfScreenHeight

    self.cur_camera_size = size
    self.sceneCamera.orthographicSize = size

    GlobalEvent:Brocast(EventName.UpdateCameraSize)
    return true
end

--根据坐标创建地图
-- 像素坐标
function MapManager:CreateMap(x, y)
    -- print('--chk MapManager.lua,line 70-- self.split_maps_width=',self.split_maps_width)
    if not self.SceneId or self.split_maps_width == 0 then
        -- self.split_maps_width判断这个是因为 还没加载场景数据,除0 或者模0会无穷大
        return
    end
    if not x or not y then
        return
    end
    local _x, _y = x, y
    x = x / self.pixelsPerUnit
    y = y / self.pixelsPerUnit
    if self.last_point and self.last_point.x == x and self.last_point.y == y then
        return
    end
    -- print('--chk MapManager.lua,line 82-- data=',data)
    self:SetCameraCanMoveToPos(x, y)
    -- Notify.ShowText(x, y)
    -- self:SetCameraSpeed(_x,_y)
    self:CalculateCameraFourExtenPoint()
    self.last_point = { x = x, y = y }
end

--计算摄像机位置的4个延伸点
function MapManager:CalculateCameraFourExtenPoint()
    self.camLeftPointExtend.x = self.sceneCamCanMoveToPosTemp.x - self.halfScreenWidth - self.split_map_size
    self.camLeftPointExtend.y = self.sceneCamCanMoveToPosTemp.y
    self.camRightPointExtend.x = self.sceneCamCanMoveToPosTemp.x + self.halfScreenWidth + self.split_map_size
    self.camRightPointExtend.y = self.sceneCamCanMoveToPosTemp.y
    self.camUpPointExtend.x = self.sceneCamCanMoveToPosTemp.x
    self.camUpPointExtend.y = self.sceneCamCanMoveToPosTemp.y + self.halfScreenHeight + self.split_map_size
    self.camDownPointExtend.x = self.sceneCamCanMoveToPosTemp.x
    self.camDownPointExtend.y = self.sceneCamCanMoveToPosTemp.y - self.halfScreenHeight - self.split_map_size

    --超出左边界
    if self.camLeftPointExtend.x < 0 then
        self.camLeftPointExtend.x = 0
    end

    --超出右边界
    if self.camRightPointExtend.x > self.map_pixels_width then
        self.camRightPointExtend.x = self.map_pixels_width
    end

    --超出上边界
    if self.camUpPointExtend.y > self.map_pixels_height then
        self.camUpPointExtend.y = self.map_pixels_height
    end

    --超出下边界
    if self.camDownPointExtend.y < 0 then
        self.camDownPointExtend.y = 0
    end
end

--x转成阻挡格子的x位置
--y转成阻挡格子的y位置
function MapManager:GetMask(x, y)

    if x < 0 or y < 0 then
        return 0
    end
    if not self.is_loaded then
        return 0
    end

    return mapMgr:GetMask(y, x)
end

--加载地图信息
function MapManager:LoadMapInfo(SceneId)
    --print("aaaaaaaaaaaaaaaaaaaaa___", SceneId)
    self.map_layer.need_load_list = nil;
    --print2(debug.traceback() .. "l;dajslkdjalksjdlkajsdlkjasld");
    mapMgr:CleanMap()
    self.SceneId = SceneId
    self.is_loaded = false
    self.txtrPath = AppConst.MapAssetDir .. "mapres_"
    local abName = "mapasset/mapmask_" .. SceneId
    local assetName = tostring(SceneId)
    local LoadCallBack = function(objs)
        if objs and objs[0] then
            local text = objs[0]
            mapMgr:Load(tostring(SceneId), text)
            local x, y
            if self.last_point then
                x, y = self.last_point.x, self.last_point.y
                self.last_point = nil
            else
                x, y = self.birth_point.x, self.birth_point.y
            end
            --self.split_map_size = 768;--mapMgr.SplitMapSize
            --self.split_maps_width = math.ceil(mapMgr.MapPixelsWidth / 768)--mapMgr.SplitMapsWidth
            self.split_map_size = mapMgr.SplitMapSize
            self.split_maps_width = mapMgr.SplitMapsWidth
            self.map_pixels_width = mapMgr.MapPixelsWidth
            self.map_pixels_height = mapMgr.MapPixelsHeight            
            self.ref_scene_id = mapMgr.refSceneId
            if self.ref_scene_id == 0 then
                self.ref_scene_id = nil
            end
            -- self:SetScreenRect()
            -- self:CreateMap(x, y)

            Yzprint('--LaoY MapManager.lua,line 301--',SceneId,self.map_pixels_width,self.map_pixels_height)
        else
            Yzprint('--LaoY MapManager.lua,line 303--',SceneId)
            logError("地图记载错误",SceneId)
        end
        self.is_loaded = true
        self.map_layer:ChangeSceneEnd()
        -- 添加到场景资源管理，切换场景释放合适的场景资源
        --lua_resMgr:AddSceneReference(SceneId,abName)

        local after_close_loading = function()
            if self.closeLoadingSchedule then
                GlobalSchedule.StopFun(self.closeLoadingSchedule);
            end
            self.closeLoadingSchedule = nil;
            GlobalEvent:Brocast(EventName.CLOSE_LOADING, SceneId);
            lua_resMgr:CheckUnUseAssset(true);
        end

        local call_back1 = function()
            if MapLayer:GetInstance().is_load_fuzzy then
                if self.map_layer.need_load_list then
                    local loadingmapTab = self.map_layer.scene_map_list[self.map_layer.cur_scene_id];
                    local isLoadAll = true;
                    for k, v in pairs(loadingmapTab) do
                        if v.isLoadMapFinish then
                        else
                            isLoadAll = false;
                        end
                    end
                    if isLoadAll then
                        after_close_loading();
                    end
                end
            end
        end

        if self.closeLoadingSchedule then
            GlobalSchedule.StopFun(self.closeLoadingSchedule);
            self.closeLoadingSchedule = nil;
        end
        -- self.closeLoadingSchedule = GlobalSchedule.StartFun(call_back1, 1, -1);

        local status, err = pcall(GlobalEvent.Brocast,GlobalEvent,EventName.ChangeSceneEnd, SceneId)
        if not status then
            logError("切换场景失败：",err)
            local sceneMgr = SceneManager:GetInstance()
            sceneMgr:SetChangeSceneState(false)
            lua_resMgr:CheckUnLoadSceneAssset()
            if not LoadingCtrl:GetInstance().loadingPanel then
                local main_role = SceneManager:GetInstance():GetMainRole()
                main_role:SetPosition(sceneMgr.scene_info_data.actor.coord.x, sceneMgr.scene_info_data.actor.coord.y)
                main_role:ChangeSceneEndFlyDown()
                main_role:SetReName()
            end
        end

        -- 需要手动执行一下 update
        self:Update(Time.deltaTime)
        OperationManager:GetInstance():RestartAStar();
        self.map_layer:LoadFuzzyLayer()

        MapLayer:GetInstance():Update()
        -- if not LoadingCtrl:GetInstance().loadingPanel then
        --     MapLayer:GetInstance():Update()
        -- end
        -- self:UpdateCamera(false)
    end
    lua_resMgr:LoadTextAssets(self,abName, assetName, LoadCallBack,Constant.LoadResLevel.Urgent,true)
end
function MapManager:CloseLoadingSchedule()
    if self.closeLoadingSchedule then
        GlobalSchedule.StopFun(self.closeLoadingSchedule);
        self.closeLoadingSchedule = nil;

    end
end

--根据资源id，获取行列号
function MapManager:GetRowColumnByResID(resId)
    local row = math.floor(resId / self.split_maps_width)
    local column = resId % self.split_maps_width
    return row, column
end

function MapManager:SetScreenRect()
    local w = self.screenWidth + self.split_map_size * 2
    local h = self.screenHeight + self.split_map_size * 2
    mapMgr:SetScreenRect(-self.split_map_size, -self.split_map_size, w, h)
end

--设置摄像机可以移动到的位置
function MapManager:SetCameraCanMoveToPos(playerInWorldPosx, playerInWorldPosy)
    local playerInMapPosx = playerInWorldPosx * self.pixelsPerUnit
    local playerInMapPosy = playerInWorldPosy * self.pixelsPerUnit
    self.sceneCamCanMoveToPosTemp.x = playerInMapPosx
    local main_role = SceneManager:GetInstance():GetMainRole()
    if main_role then
        local body_pos = main_role:GetBodyPosition()
        local height = 180 -- main_role:GetBodyHeight()
        self.sceneCamCanMoveToPosTemp.y = playerInMapPosy + height * 0.5 + body_pos.y
        --self.sceneCamCanMoveToPosTemp.y = playerInMapPosy
    else
        self.sceneCamCanMoveToPosTemp.y = playerInMapPosy
    end

    -- 判断越界
    if self.sceneCamCanMoveToPosTemp.x - self.halfScreenWidth < 0 then
        self.sceneCamCanMoveToPosTemp.x = self.halfScreenWidth
    end
    if self.sceneCamCanMoveToPosTemp.x + self.halfScreenWidth > self.map_pixels_width then
        self.sceneCamCanMoveToPosTemp.x = self.map_pixels_width - self.halfScreenWidth
    end

    if self.sceneCamCanMoveToPosTemp.y - self.halfScreenHeight < 0 then
        self.sceneCamCanMoveToPosTemp.y = self.halfScreenHeight
    end
    if self.sceneCamCanMoveToPosTemp.y + self.halfScreenHeight > self.map_pixels_height then
        self.sceneCamCanMoveToPosTemp.y = self.map_pixels_height - self.halfScreenHeight
    end

    self.sceneCamCanMoveToPosTemp.x = math.round(self.sceneCamCanMoveToPosTemp.x)
    self.sceneCamCanMoveToPosTemp.y = math.round(self.sceneCamCanMoveToPosTemp.y)

    self.last_target_pos = self.last_target_pos or { x = 0, y = 0 }
    self.last_target_pos.x = self.sceneCamCanMoveToPosTemp.x
    self.last_target_pos.y = self.sceneCamCanMoveToPosTemp.y

    self.sceneCamCanMoveToPosWorld.x = self.sceneCamCanMoveToPosTemp.x / self.pixelsPerUnit
    self.sceneCamCanMoveToPosWorld.y = self.sceneCamCanMoveToPosTemp.y / self.pixelsPerUnit
end

function MapManager:Update(deltaTime)
    if SceneManager:GetInstance():GetChangeSceneState() then
        return
    end
    
    if not self.is_end_handle_timeline or not self.is_end_race then
        --时间轴未处理完 或机甲竞速未结束 不能进行摄像机update
       return
    end

    self:UpdateCamera()
    self:UpdateSize()
    self:UpdateShake()
    self:UpdateArenaFight(deltaTime)
end

function MapManager:UpdateSize()
    if self.is_scene_camera_action then
        return  
    end
    local main_role = SceneManager:GetInstance():GetMainRole()
    if not main_role then
        return
    end
    -- do
    --     return
    -- end
    self.cur_size = self.cur_size or 0
    self.size_speed = self.size_speed or 0
    local body_pos = main_role:GetBodyPosition()
    local cur_size_rate = body_pos.y
    if cur_size_rate ~= 0 and self.is_lock_size then
        return
    end
    if self.cur_size ~= cur_size_rate then
        if cur_size_rate == 0 then
            self.is_lock_size = false
        end
        local is_smooth = true
        if cur_size_rate > self.cur_size then
            is_smooth = false
        end
        local range = self.cur_size * 0.5
        -- local smoot_time = is_smooth and 0.25 or 0.125
        local smoot_time = MapManager.smootTime
        local dis = math.abs(self.cur_size - cur_size_rate)
        -- if dis < 6*6 then
        --     smoot_time = smoot_time * 0.3
        -- end
        local new_size
        if dis <= 1 or SceneManager:GetInstance():GetChangeSceneState() then
            new_size = cur_size_rate
        else
            new_size,self.size_speed = Smooth(self.cur_size, cur_size_rate, self.size_speed, smoot_time, Time.deltaTime)
            -- new_size,self.size_speed = Vector2.SmoothDamp(self.cur_size, cur_size_rate, self.size_speed, smoot_time, Time.deltaTime)
            -- new_size = cur_size_rate
            -- new_size, self.size_speed = Smooth(self.cur_size, cur_size_rate, self.size_speed, smoot_time, Time.fixedDeltaTime)
        end
        range = new_size * 0.5
        local bo = self:SetCameraSize(self.camera_base_size + range / self.pixelsPerUnit)
        if bo then
            self.is_update_size = true
            self.cur_size = new_size
            local rate = self.cur_camera_size / self.camera_base_size
            if cur_size_rate <= 5 then
                rate = 1
            end
            main_role:SetRateScale(rate)
        end
        if bo == false then
            self.is_lock_size = true
        end
    end
end

function MapManager:IsUpdateCameraSize()
    return self.is_update_size
end

function MapManager:UpdateCamera(is_smooth)
    if self.is_scene_camera_action then
        return
    end
    local pos
    local main_role = SceneManager:GetInstance():GetMainRole()
    local sceneMgr = SceneManager:GetInstance()
    if sceneMgr:GetChangeSceneState() or not main_role or not main_role.position then
        if sceneMgr.scene_info_data and sceneMgr.scene_info_data.actor then
            pos = sceneMgr.scene_info_data.actor.coord
        end
    else
        pos = main_role.position
    end
    if not pos then
        return
    end
    -- self:SceneCamMove(main_role.position.x, main_role.position.y + main_role:GetBodyHeight() * 0.5)
    self.last_main_pos = self.last_main_pos or { x = 0, y = 0 }
    -- if self.last_main_pos.x == pos.x and self.last_main_pos.y == pos.y then
    --     return
    -- end
    is_smooth = is_smooth == nil and true or is_smooth
    local body_pos
    if main_role then
        body_pos = main_role:GetBodyPosition()
    end
    local height = 0
    -- if body_pos and body_pos.y then
    --     height = body_pos.y
    -- end
    -- height = height * 0.3
    self:SceneCamMove(pos.x, pos.y + height, is_smooth)
    self.last_main_pos.x = pos.x
    self.last_main_pos.y = pos.y
end

MapManager.smootTime = 0.05

function MapManager:SceneCamMove(to_x, to_y, is_smooth)
    if not self.sceneCamera then
        return
    end
    is_smooth = is_smooth == nil and true or is_smooth
    is_smooth = false;
    self:CreateMap(to_x, to_y)
    -- Notify.ShowText(to_x, to_y)
    if self.last_camer_pos and self.last_camer_pos.x == self.sceneCamCanMoveToPosWorld.x and self.last_camer_pos.y == self.sceneCamCanMoveToPosWorld.y then
        self.sceneCameraSpeed.x = 0
        self.sceneCameraSpeed.y = 0
        return
    end

    local pos = Vector3(GetGlobalPosition(self.sceneCamera_transform))
    local dis = Vector2.Distance(pos * self.pixelsPerUnit, self.sceneCamCanMoveToPosWorld * self.pixelsPerUnit)
    local vec
    -- if dis > 1000 or dis <= 1 then
    if dis > 1000 then
        self.sceneCameraSpeed.x = 0
        self.sceneCameraSpeed.y = 0
        vec = Vector3(self.sceneCamCanMoveToPosWorld.x, self.sceneCamCanMoveToPosWorld.y, self.sceneCamCanMoveToPosWorld.z)
    end
    if not vec then
        if is_smooth then
            --Notify.ShowText(dis)
            local smoot_time = MapManager.smootTime
            -- if dis < 6*6 then
            --     smoot_time = smoot_time * 0.2
            -- end
            local cur_pos = Vector2(pos.x, pos.y)
            local target_pos = Vector2(self.sceneCamCanMoveToPosWorld.x, self.sceneCamCanMoveToPosWorld.y)
            local last_speed = self.sceneCameraSpeed
            local delta_time = Fps.fps
            -- vec, self.sceneCameraSpeed = Smooth(cur_pos, target_pos, self.sceneCameraSpeed, smoot_time, delta_time)
            -- if Vector2.DistanceNotSqrt(cur_pos, vec) > Vector2.DistanceNotSqrt(cur_pos, target_pos) then
            --     vec = target_pos
            --     self.sceneCameraSpeed = last_speed
            -- end

            -- vec, self.sceneCameraSpeed = Vector2.SmoothDamp(cur_pos, target_pos, self.sceneCameraSpeed, smoot_time,nil,delta_time)
            vec, self.sceneCameraSpeed = Vector2.SmoothDamp(cur_pos, target_pos, self.sceneCameraSpeed, smoot_time,nil,Time.deltaTime)
            -- vec = target_pos
            -- self.sceneCameraSpeed = last_speed
            if vec ~= target_pos then                
                vec.x = math.round(vec.x * self.pixelsPerUnit) / self.pixelsPerUnit
                vec.y = math.round(vec.y * self.pixelsPerUnit) / self.pixelsPerUnit
                vec = Vector3(vec.x, vec.y, self.sceneCamCanMoveToPosWorld.z)
            end
        else
            vec = Vector3(self.sceneCamCanMoveToPosWorld.x, self.sceneCamCanMoveToPosWorld.y, self.sceneCamCanMoveToPosWorld.z)
        end
    end
    if not self.last_camer_pos then
        self.last_camer_pos = Vector2(vec.x, vec.y)
    else
        self.last_camer_pos.x = vec.x
        self.last_camer_pos.y = vec.y
    end
    if not vec.z then
        vec = Vector3(vec.x, vec.y, self.sceneCamCanMoveToPosWorld.z)
    end
    self:SetCameraPos(vec.x, vec.y, vec.z)
end

function MapManager:SetCameraPos(x, y, z)

    local function step()
        self.camera_pos.x = x * self.pixelsPerUnit
        self.camera_pos.y = y * self.pixelsPerUnit
        self.camera_pos.z = z * self.pixelsPerUnit
        SetGlobalPosition(self.sceneCamera_transform, x, y, z)
    end
    step()
    -- self.time_id = GlobalSchedule:StartOnce(step,1.0)
    -- if self.time_id then
    --     GlobalSchedule:Stop(self.time_id)
    -- end

    -- if self.time_id then
    --     GlobalSchedule:Stop(self.time_id)
    -- end

    -- local _x = x * SceneConstant.PixelsPerUnit - self.halfScreenWidth - self.split_map_size
    -- local _y = y * SceneConstant.PixelsPerUnit - self.halfScreenHeight - self.split_map_size
    -- mapMgr:SetScreenRectPos(_x , _y )
end

function MapManager:AddShakeInfo(shake_start_time, shake_type, shake_lase_time, shake_max_range, shake_angle, start_angle)
    -- if not SettingModel:GetInstance().isShakeScreen then
    --     return ;
    -- end
    local shake_info = {
        shake_start_time = shake_start_time,
        shake_type = shake_type,
        shake_lase_time = shake_lase_time,
        shake_max_range = shake_max_range or 15,
        shake_angle = shake_angle or 180,
        start_angle = start_angle,
        add_list_time = Time.time,
    }
    table_insert(self.shake_info_list, shake_info)
end

function MapManager:UpdateShake()
    if self.is_scene_camera_action then
        return  
    end
    if table.isempty(self.shake_info_list) then
        return
    end
    local main_role = SceneManager:GetInstance():GetMainRole()
    if not main_role then
        return
    end
    local delete_list = {}
    local curr_shake_range_x = 0
    local curr_shake_range_y = 0
    local curr_shake_range_s = 0
    local curr_shake_range = 0
    local ratio = 0
    local radian_off = 0
    local past_time = 0
    for i, shake_info in ipairs(self.shake_info_list) do
        past_time = Time.time - shake_info.add_list_time
        if past_time >= shake_info.shake_start_time then
            ratio = (past_time - shake_info.shake_start_time) / shake_info.shake_lase_time
            ratio = ratio > 1 and 1 or ratio
            curr_shake_range = shake_info.shake_max_range * math_sin((ratio * shake_info.shake_angle + shake_info.start_angle) * math.pi / 180)
            if shake_info.shake_type == 1 then
                --上下
                if math_abs(curr_shake_range) > math_abs(curr_shake_range_y) then
                    curr_shake_range_y = curr_shake_range
                end
            elseif shake_info.shake_type == 2 then
                --左右
                if math_abs(curr_shake_range) > math_abs(curr_shake_range_x) then
                    curr_shake_range_x = curr_shake_range
                end
            elseif shake_info.shake_type == 3 then
                --拉伸
                if math_abs(curr_shake_range) > math_abs(curr_shake_range_s) then
                    curr_shake_range_s = curr_shake_range
                end
            end
            if ratio >= 1 then
                table_insert(delete_list, i)
            end
        end
    end
    local delete_index = 0
    for i, v in ipairs(delete_list) do
        table.remove(self.shake_info_list, v - delete_index)
        delete_index = delete_index + 1
    end

    local main_role_pos = main_role:GetPosition()
    if curr_shake_range_x ~= 0 or curr_shake_range_y ~= 0 then
        if math_abs(self.camera_pos.x - main_role_pos.x - curr_shake_range_x) > 10 or math_abs(self.camera_pos.y - main_role_pos.y - 0 - curr_shake_range_y) > 10 then
            self:SceneCamMove(main_role_pos.x + curr_shake_range_x, main_role_pos.y + curr_shake_range_y)
        else
            self:SceneCamMove(main_role_pos.x + curr_shake_range_x, main_role_pos.y + curr_shake_range_y, false)
        end
    end
    if curr_shake_range_s ~= 0 then
        self:SetCameraSize(self.camera_base_size + curr_shake_range_s / self.pixelsPerUnit)
    end

    if table.isempty(self.shake_info_list) then
        self:SetCameraSize(self.camera_base_size)
        self:SceneCamMove(main_role_pos.x, main_role_pos.y, false)
    end
end

Rect = UnityEngine.Rect
function MapManager:TestAdaptation()
    -- local offsetRate = 80/DeviceResolutionWidth
    -- self.uiCamera.rect = Rect(offsetRate, 0, 1, 1)
    -- -- self.sceneCamera.rect = Rect(offsetRate, 0, 1, 1)

    -- local layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Layer)
    -- DebugLog('--LaoY MapManager.lua,line 750--',layer)
    -- if layer then
    --     local scale = (DeviceResolutionWidth - 80)/DeviceResolutionWidth
    --     SetLocalScale(layer,scale,scale,scale)
    -- end
end