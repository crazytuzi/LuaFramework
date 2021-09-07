-- ----------------------------------------------------------
-- 逻辑模块 - 家园管理器
-- ljh 20160629
-- ----------------------------------------------------------
HomeManager = HomeManager or BaseClass(BaseManager)

local GameObject = UnityEngine.GameObject

function HomeManager:__init()
	HomeManager.Instance = self

	self.model = HomeModel.New()

	self.homeElementsModel = HomeElementsModel.New()

	self.homeCanvasView = nil

    self.Show_Role_Wing_Mark = false
    self.Show_Self_Pet_Mark = false

    HomeManager.Instance.canvasInit = false

    self.isHomeCanvasShow = false
    self.showHomeCanvas = false
    self.FightCache = false

    self.zoomMark = false

    self.showGrid = false

    if LuaBehaviourDownUpBaseWithoutUpdate == nil then
        self.LuaBehaviourName = "LuaBehaviourDownUpBase"
    else
        self.LuaBehaviourName = "LuaBehaviourDownUpBaseWithoutUpdate"
    end

    self.buildFirstInfo = EventLib.New()

    self:InitHandler()

    self._start_scene_load = function(mapid) self:start_scene_load(mapid) end
    EventMgr.Instance:AddListener(event_name.start_scene_load, self._start_scene_load)

    self._scene_load = function(mapid) self:scene_load(mapid) end
    EventMgr.Instance:AddListener(event_name.scene_load, self._scene_load)

    self._RoleEventChange = function(event, ord_event) self:RoleEventChange(event, ord_event) end
    EventMgr.Instance:AddListener(event_name.role_event_change, self._RoleEventChange)

    self._BeginFight = function() self:BeginFight() end
    EventMgr.Instance:AddListener(event_name.begin_fight, self._BeginFight)
    self._EndFight = function() self:EndFight() end
    EventMgr.Instance:AddListener(event_name.end_fight, self._EndFight)
end

function HomeManager:initCanvas()
	if self.homeCanvasView == nil then
        self.homeCanvasView = HomeCanvasView.New()
    end
end


function HomeManager:deleteCanvas()
    if self.homeCanvasView ~= nil then
        self.homeCanvasView:DeleteMe()
        self.homeCanvasView = nil
    end
end

function HomeManager:FixedUpdate()
	self.deltaTime = Time.deltaTime
	self.homeElementsModel:FixedUpdate()
    -- if self.zoomMark then
    --     self:CameraFixedUpdate()
    -- end
end

function HomeManager:OnTick()
	self.homeElementsModel:OnTick()
end

function HomeManager:InitHandler()
	-- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
	self:AddNetHandler(11200, self.On11200)
    self:AddNetHandler(11201, self.On11201)
    self:AddNetHandler(11202, self.On11202)
    self:AddNetHandler(11203, self.On11203)
    self:AddNetHandler(11204, self.On11204)
    self:AddNetHandler(11205, self.On11205)
    self:AddNetHandler(11206, self.On11206)
    self:AddNetHandler(11207, self.On11207)
    -- self:AddNetHandler(11208, self.On11208)
    self:AddNetHandler(11209, self.On11209)
    self:AddNetHandler(11210, self.On11210)
    self:AddNetHandler(11211, self.On11211)
    self:AddNetHandler(11212, self.On11212)
    self:AddNetHandler(11213, self.On11213)
    self:AddNetHandler(11214, self.On11214)
    self:AddNetHandler(11215, self.On11215)

    self:AddNetHandler(11217, self.On11217)
    self:AddNetHandler(11218, self.On11218)
    self:AddNetHandler(11219, self.On11219)
    self:AddNetHandler(11220, self.On11220)
    self:AddNetHandler(11221, self.On11221)
    self:AddNetHandler(11222, self.On11222)
    self:AddNetHandler(11223, self.On11223)
    self:AddNetHandler(11224, self.On11224)
    self:AddNetHandler(11225, self.On11225)
    self:AddNetHandler(11226, self.On11226)
    self:AddNetHandler(11227, self.On11227)
    self:AddNetHandler(11228, self.On11228)
    self:AddNetHandler(11229, self.On11229)

    self:AddNetHandler(11230, self.On11230)
    self:AddNetHandler(11231, self.On11231)
    self:AddNetHandler(11232, self.On11232)
    self:AddNetHandler(11233, self.On11233)

    self:AddNetHandler(11234, self.On11234)

    self:AddNetHandler(11235, self.On11235)
end

function HomeManager:Send11200()
    -- print("Send11200")
    Connection.Instance:send(11200, { })
end

function HomeManager:On11200(data)
    self:InitHome()
    self.model:On11200(data)
end

function HomeManager:Send11201()
    Connection.Instance:send(11201, { })
end

function HomeManager:On11201(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gethome)
    end
end

function HomeManager:Send11202(fid, platform, zone_id)
    Connection.Instance:send(11202, { fid = fid, platform = platform, zone_id = zone_id })
end

function HomeManager:On11202(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self:InitHome()
    end
end

function HomeManager:Send11203()
    Connection.Instance:send(11203, { })
end

function HomeManager:On11203(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11204(id, x, y, gx, gy, dir)
    Connection.Instance:send(11204, { id = id, x = x, y = y, gx = gx, gy = gy, dir = dir })
end

function HomeManager:On11204(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag ~= 1 then
        HomeManager.Instance.homeElementsModel:SetEditById(data.id)
    end
end

function HomeManager:Send11205()
    Connection.Instance:send(11205, { })
end

function HomeManager:On11205(data)
    self.model:On11205(data)
end

function HomeManager:Send11206()
    Connection.Instance:send(11206, { })
end

function HomeManager:On11206(data)
    BaseUtils.dump(data, "11206")
    -- print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")
    local roleData = RoleManager.Instance.RoleData
    roleData.fid = data.fid --家园id
    roleData.family_platform = data.platform --平台标识
    roleData.family_zone_id = data.zone_id --区号
end

function HomeManager:Send11207(id)
    Connection.Instance:send(11207, { id = id })
end

function HomeManager:On11207(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11209(bad_type)
    Connection.Instance:send(11209, { bad_type = bad_type })
end

function HomeManager:On11209(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then

    end
end

function HomeManager:Send11210(bad_type)
    Connection.Instance:send(11210, { bad_type = bad_type })
end

function HomeManager:On11210(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11211()
    Connection.Instance:send(11211, {})
end

function HomeManager:On11211(data)
    self.model:On11211(data)
end

function HomeManager:Send11212(id, num)
    Connection.Instance:send(11212, {id = id, num = num})
end

function HomeManager:On11212(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11213()
    Connection.Instance:send(11213, { })
end

function HomeManager:On11213(data)
    self.model:On11213(data)
end

function HomeManager:Send11214(id, train_id)
    Connection.Instance:send(11214, { id = id, train_id = train_id })
end

function HomeManager:On11214(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11215()
    Connection.Instance:send(11215, { })
end

function HomeManager:On11215(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11217()
    Connection.Instance:send(11217, { })
end

function HomeManager:On11217(data)
    self.model:On11217(data)
end

function HomeManager:Send11218()
    Connection.Instance:send(11218, { })
end

function HomeManager:On11218(data)
    self.model:On11218(data)
end

function HomeManager:Send11219(id)
    Connection.Instance:send(11219, { id = id })
end

function HomeManager:On11219(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11220()
    Connection.Instance:send(11220, { })
end

function HomeManager:On11220(data)
    self.model:On11220(data)
end

function HomeManager:Send11221()
    self.last11221 = os.date("%d", BaseUtils.BASE_TIME)
    Connection.Instance:send(11221, { })
end

function HomeManager:On11221(data)
    self.model:On11221(data)
end

function HomeManager:Send11222(lock_lev)
    Connection.Instance:send(11222, { lock_lev = lock_lev })
end

function HomeManager:On11222(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11223(type)
    Connection.Instance:send(11223, { type = type })
end

function HomeManager:On11223(data)
    self.model:On11223(data)
end

function HomeManager:Send11224()
    Connection.Instance:send(11224, { })
end

function HomeManager:On11224(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(SceneManager.Instance.MainCamera.transform)
            effectObject.transform.localScale = Vector3(1, 1, 1)
            effectObject.transform.localPosition = Vector3(0, 0, 0)
            effectObject.transform.localRotation = Quaternion.identity

            -- Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        end
        BaseEffectView.New({effectId = 30130, time = nil, callback = fun})
    end
end

--豌豆数据
function HomeManager:Send11225()
    Connection.Instance:send(11225, { })
end

function HomeManager:On11225(data)
    -- BaseUtils.dump(data,"<color='#ffff00'>豌豆数据啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊</color>")
    self.model:on11225(data)
end

--培育豌豆
function HomeManager:Send11226(fid, platform, zone_id)
    Connection.Instance:send(11226, {fid = fid, platform = platform, zone_id = zone_id})
end

function HomeManager:On11226(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--领取豌豆奖励
function HomeManager:Send11227()
    Connection.Instance:send(11227, { })
end

function HomeManager:On11227(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--领取豌豆奖励
function HomeManager:Send11228(inviters)
    Connection.Instance:send(11228, {inviters = inviters})
end

function HomeManager:On11228(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--领取豌豆奖励
function HomeManager:Send11229(id)
-- print("领取id："..id)
    Connection.Instance:send(11229, {id = id})
end

function HomeManager:On11229(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11230()
    Connection.Instance:send(11230, { })
end

function HomeManager:On11230(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11231()
    Connection.Instance:send(11231, { })
end

function HomeManager:On11231(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:Send11232()
    Connection.Instance:send(11232, { })
end

function HomeManager:On11232(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self:InitHome()
    end
end


function HomeManager:Send11233(rid, platform, zone_id)
    if rid == 0 then
        return
    end
    Connection.Instance:send(11233, {rid = rid, platform = platform, zone_id = zone_id})
    self.model:CloseMagicBeenPanel()
end

function HomeManager:On11233(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self:InitHome()
    end
end

function HomeManager:Send11234(train_id)
    Connection.Instance:send(11234, {train_id = train_id})
end

function HomeManager:On11234(data)
    -- print("-----------------收到11234")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        -- self:InitHome()
    end
end

function HomeManager:Send11235(id)
    Connection.Instance:send(11235, {id = id})
end

function HomeManager:On11235(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HomeManager:RequestInitData()
    self.isHomeCanvasShow = false
    self.Show_Role_Wing_Mark = true
    self.Show_Self_Pet_Mark = true
    self.findTreeMark = false
    self.findTreeTimerId = nil

    self.model.editType = false
    self.model.previewType = false
    self.model.home_lev = 1 -- 家园等级
    self.model.home_name = "" -- 家园名字
    self.model.master_name = "" -- 主人名字
    self.model.visit_lock = 1 -- 权限(1 所有 2 好友 3 公会 4好友与公会 5 关闭
    self.model.updateVisitTime = 0 -- 上次更新好友、公会家园列表时间
    self.model.cleanness = 0 -- 清洁度
    self.model.housekeeper_action_times = 0 -- 管家劳动次数
    self.model.env_val = 0 -- 繁华度
    self.model.warehouse_list = {} -- 仓库列表
    self.model.furniture_list = {} -- 家具列表
    self.model.build_list = {} -- 建筑列表
    self.model.shop_datalist = {} -- 家具商店数据
    self.model.effect_list = {} -- 家具建筑效果
    self.model.use_info = {} -- 建筑使用次数信息
    self.model.train_info = {} -- 宠物训练信息
    self.model.home_friend_list = {} -- 好友家园信息列表
    self.model.home_guild_list = {} -- 公会成员家园信息列表
    self.model.fid = 0 --家园id
    self.model.platform = "" --平台标识
    self.model.zone_id = 0 --区号
    self.model.map_id = 0 --地图id
    self.model.floor_lev = 1 --地板等级
    self.model.eidtIndex = 1 -- 编辑家具的临时id，每编辑一个家具加一
    self.model.zoomIndex = 2
    self.model.zooming = false
    self.model.battle_id = nil
    self.model.confirmMark = true
    self.model.isGuidePlay = false
    self.mapGrid = {}

    self.homeElementsModel.removeOutView = true
    self.homeElementsModel.flower_action = nil
    self.homeElementsModel.functionUnit = nil

    -- self:Send11200()
    self:Send11211()
    self:Send11217()
    self:Send11220()
    self:Send11221()
    self:Send11225()
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- 进入家园
function HomeManager:InitHome()
    self:initCanvas()
    self:ShowCanvas(true)
end

-- 进入家园
function HomeManager:EnterHome()
    if RoleManager.Instance.RoleData.fid ~= 0 then
        -- self:InitHome()
        --成功进入家园再init
        -- local roleData = RoleManager.Instance.RoleData
        -- print(string.format("%s %s %s", roleData.fid, roleData.family_platform, roleData.family_zone_id))
        -- self:Send11202(roleData.fid, roleData.family_platform, roleData.family_zone_id)
        self:Send11232()
    else
        -- NoticeManager.Instance:FloatTipsByString("当前未创建家园")
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("您现在还没有家园哦，是否前往<color='#ffff00'>圣心城</color>家园管家<color='#00ff00'>小暖</color>处创建家园。")
        data.sureLabel = TI18N("马上前往")
        data.cancelLabel = TI18N("我考虑下")
        data.sureCallback = function()
            SceneManager.Instance.sceneElementsModel:Self_PathToTarget(BaseUtils.get_unique_npcid(55, 1))
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

-- 进入家园
function HomeManager:EnterOtherHome(fid, family_platform, family_zone_id)
    if fid ~= 0 then
        self.model:HideEditPanel()
        -- self:InitHome()
        --成功进入家园再init
        print(string.format("EnterOtherHome %s %s %s", fid, family_platform, family_zone_id))
        local roleData = RoleManager.Instance.RoleData
        if fid == roleData.fid and family_platform == roleData.family_platform and family_zone_id == roleData.family_zone_id then
            self:Send11232()
        else
            self:Send11202(fid, family_platform, family_zone_id)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("目标未创建家园"))
    end
end

-- 离开家园
function HomeManager:ExitHome()
	self:ShowCanvas(false)
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Home then
        self:Send11203()
    end

    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.model:DeleteMapArea()
        self.model:DeleteEditPanel()
        self:deleteCanvas()
    end
end

function HomeManager:RoleEventChange(event, ord_event)
    if ord_event == RoleEumn.Event.Home and event ~= RoleEumn.Event.Home then
        self:ShowCanvas(false)
    end
end

-- 清理家园
function HomeManager:Clean()
	self.homeElementsModel:CleanElements()
end

function HomeManager:BeginFight()
    if CombatManager.Instance.isFighting then
        self.FightCache = self.isHomeCanvasShow
        self:ShowCanvas(false)
    end
end

function HomeManager:EndFight()
    if self.FightCache then
        self:ShowCanvas(true)
    end
end

function HomeManager:ShowCanvas(show)
    self.isHomeCanvasShow = show
    if self.homeCanvasView ~= nil and self.homeCanvasView.gameObject ~= nil then
        if show then
            self.homeCanvasView.rect.anchoredPosition = Vector2.zero
            self.model:ShowMapArea()
        else
            self.homeCanvasView.rect.anchoredPosition = Vector2(0, -2000)
            self.model:HideMapArea()
            self.model:HideEditPanel()
        end

        self:ShowOtherUI()
    end
end

function HomeManager:ShowOtherUI()
    if self.isHomeCanvasShow then
        self.showHomeCanvas = true

        local editType = self.model.editType
        local previewType = self.model.previewType
        local mainUi = MainUIManager.Instance

        if mainUi.MainUIIconView ~= nil and mainUi.MainUIIconView.gameObject ~= nil then
            if editType then
                mainUi:HideIconPanel()
            elseif mainUi.isMainUIShow then
                mainUi:ShowIconPanel()
            end
            mainUi.MainUIIconView:hidebaseicon2()
            -- mainUi.MainUIIconView:hidebaseicon3()
            mainUi.MainUIIconView:Set_ShowTop(false)
        end

        if mainUi.mainuitracepanel ~= nil and mainUi.mainuitracepanel.mainObj ~= nil then
            -- if editType then
                if mainUi.mainuitracepanel.mainObj.activeSelf then
                    self.show_mainuitracepanel = true
                    mainUi.mainuitracepanel:TweenHiden()
                end
            -- else
            --     if self.show_mainuitracepanel and not mainUi.mainuitracepanel.mainObj.activeSelf then
            --         self.show_mainuitracepanel = false
            --         mainUi.mainuitracepanel:TweenShow()
            --     end
            -- end
        end

        if mainUi.mapInfoView ~= nil then
            -- mainUi.mapInfoView:ShowCanvas(false)
            mainUi.mapInfoView:TweenHide()
        end

        if mainUi.expInfoView ~= nil then
            mainUi.expInfoView:ShowCanvas(not editType and mainUi.isMainUIShow)
        end

        print(previewType)

        if mainUi.roleInfoView ~= nil then
            -- mainUi.roleInfoView:ShowCanvas(not previewType and mainUi.isMainUIShow)
            if not previewType and mainUi.isMainUIShow then
                mainUi.roleInfoView:TweenShow()
            else
                mainUi.roleInfoView:TweenHide()
            end
        end

        if mainUi.petInfoView ~= nil then
            -- mainUi.petInfoView:ShowCanvas(not previewType and mainUi.isMainUIShow)
            if not previewType and mainUi.isMainUIShow then
                mainUi.petInfoView:TweenShow()
            else
                mainUi.petInfoView:TweenHide()
            end
        end

        ChatManager.Instance.model:ShowCanvas(not editType)

        if self.homeCanvasView ~= nil and self.homeCanvasView.gameObject ~= nil then
            self.homeCanvasView:HideExtendButton()
        end
    elseif self.showHomeCanvas then
        self.showHomeCanvas = false
        local mainUi = MainUIManager.Instance
        if mainUi.mainuitracepanel ~= nil and self.show_mainuitracepanel then
            self.show_mainuitracepanel = false
            mainUi.mainuitracepanel:TweenShow()
        end

        if mainUi.MainUIIconView ~= nil and mainUi.MainUIIconView.gameObject ~= nil then
            -- if mainUi.isMainUIShow then
                mainUi:ShowIconPanel()
                mainUi.MainUIIconView:showbaseicon2()
                -- mainUi.MainUIIconView:showbaseicon3()
                mainUi.MainUIIconView:Set_ShowTop(true)
            -- end
        end

        if mainUi.mapInfoView ~= nil then
            -- mainUi.mapInfoView:ShowCanvas(true)
            mainUi.mapInfoView:TweenShow()
        end

        if mainUi.expInfoView ~= nil then
            mainUi.expInfoView:ShowCanvas(true)
        end

        if mainUi.roleInfoView ~= nil then
            -- mainUi.roleInfoView:ShowCanvas(true)
            mainUi.roleInfoView:TweenShow()
        end

        if mainUi.petInfoView ~= nil then
            -- mainUi.petInfoView:ShowCanvas(true)
            mainUi.petInfoView:TweenShow()
        end

        ChatManager.Instance.model:ShowCanvas(true)
    end
end

function HomeManager:start_scene_load(mapid)
    self.model.zoomIndex = 2
    self.model.zooming = false

    if SceneManager.Instance.MainCamera.camera.orthographicSize ~= SceneManager.Instance.DefaultCameraSize then
        SceneManager.Instance.MainCamera.camera.orthographicSize = SceneManager.Instance.DefaultCameraSize
    end

    local sceneElementsModel = SceneManager.Instance.sceneElementsModel
    if mapid == 30012 or mapid == 30013 then
        self:Send11200()
        if sceneElementsModel.Show_Role_Wing_Mark then
            self.Show_Role_Wing_Mark = true
            sceneElementsModel:Show_Role_Wing(false)
        end
        if sceneElementsModel.Show_Self_Pet_Mark then
            self.Show_Self_Pet_Mark = true
            sceneElementsModel:Show_Self_Pet(false)
        end
    else
        self.model:HideFloor()
        if self.Show_Role_Wing_Mark then
            self.Show_Role_Wing_Mark = false
            sceneElementsModel:Show_Role_Wing(true)
        end
        if self.Show_Self_Pet_Mark then
            self.Show_Self_Pet_Mark = false
            sceneElementsModel:Show_Self_Pet(true)
        end
    end

    self:CancelFindTree()
end

function HomeManager:scene_load(mapid)
    if mapid == 30012 or mapid == 30013 then
        self.model:InitMapGrid()

        if self.findTreeMark and self.model:CanEditHome() then
            self.findTreeTimerId = LuaTimer.Add(1000, function()
                local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
                for key, value in ipairs(units) do
                    if value.baseid == 20081 then
                        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(value.uniqueid)
                        return
                    end
                end
            end)
        end
    end
end

function HomeManager:FindTree()
    self.findTreeMark = true
    self:EnterHome()
end

function HomeManager:CancelFindTree()
    self.findTreeMark = false
    if self.findTreeTimerId ~= nil then
        LuaTimer.Delete(self.findTreeTimerId)
        self.findTreeTimerId = nil
    end
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function HomeManager:CameraFixedUpdate()
    local mainCamera = SceneManager.Instance.MainCamera
    if mainCamera.sceneModel.map_loaded then
        local mark = false
        local proportion = mainCamera.camera.orthographicSize / SceneManager.Instance.DefaultCameraSize

        local MapWidth = mainCamera.MapWidth
        local MapHeight = mainCamera.MapHeight
        local CameraOffsetX = mainCamera.CameraOffsetX * proportion
        local CameraOffsetY = mainCamera.CameraOffsetY * proportion
        local pox = mainCamera.transform.position.x
        local poy = mainCamera.transform.position.y

        if pox < CameraOffsetX then
            pox = CameraOffsetX
            mark = true
        elseif pox > (MapWidth - CameraOffsetX) then
            pox = MapWidth - CameraOffsetX
            mark = true
        end

        if poy < CameraOffsetY then
            poy = CameraOffsetY
            mark = true
        elseif poy > (MapHeight - CameraOffsetY) then
            poy = MapHeight - CameraOffsetY
            mark = true
        end

        if mark then
            mainCamera.transform.position = Vector3(pox, poy, -10)
        end
    end
end


function HomeManager:Utils_MakeGrid(grid_string)
    local list = { }
    local args = StringHelper.Split(grid_string, ",")
    for i = 1, #args - 1 do
        local string_list = StringHelper.ConvertStringTable(args[i])
        local temp = {}
        for j = 1, #string_list do
            table.insert(temp, tonumber(string_list[j]))
        end
        table.insert(list, temp)
    end

    -- local list = {
    --                 { 0, 1, 0, 1, 0}
    --                 ,{ 0, 1, 0, 1, 0}
    --                 ,{ 0, 1, 0, 1, 0}
    --                 ,{ 0, 1, 0, 1, 0}
    --                 ,{ 0, 1, 0, 1, 0}
    --             }
    local row = #list
    local col = #list[1]
    if row % 2 == 0 or col % 2 == 0 then print("矩阵行列数不为单数") end
    local centerY = (row + 1) / 2
    local centerX = (col + 1) / 2
    local point = ""
    for i = 1, row do
        for j = 1, col do
            if list[i][j] == 1 then
                if point == "" then
                    point = string.format("{%s,%s}", i - centerY, j - centerX)
                else
                    point = string.format("%s, {%s,%s}", point, i - centerY, j - centerX)
                end
            end
        end
    end
    Log.Error(point)
end

function HomeManager:FlowerNum2ActionName(num)
        return "Stand1"
    -- if num == 0 then
    --     return "Stand1"
    -- elseif num == 1 then
    --     return "Stand2"
    -- elseif num == 2 then
    --     return "Stand3"
    -- elseif num == 3 then
    --     return "Stand4"
    -- elseif num == 4 then
    --     return "Stand5"
    -- elseif num == 5 then
    --     return "Stand6"
    -- end
end

function HomeManager:PrintMapGrid()
    local grid = ctx.sceneManager.Map.Grid
    local str = ""
    local first = true
    for i=1,ctx.sceneManager.Map.Collumn do
        for j=0,ctx.sceneManager.Map.Row-1 do
            if grid[i][j].Status ~= 1 then
                if first then
                    first = false
                    str = string.format("{%s,%s}", i-1, ctx.sceneManager.Map.Row-j-1)
                else
                    str = string.format("%s,{%s,%s}", str, i-1, ctx.sceneManager.Map.Row-j-1)
                end
            end
        end
    end
    print(str)
end

function HomeManager:PrintGrid(x, y)
    local px = self.model:GetMapGridByX(x * SceneManager.Instance.Mapsizeconvertvalue)
    local py = self.model:GetMapGridByY(y * SceneManager.Instance.Mapsizeconvertvalue)
    print(string.format("(%s, %s) 对应的格子坐标是 (%s, %s)", x, y, px, py))
end

-- 是否在家园里面
function HomeManager:IsAtHome()
    local currmapid = SceneManager.Instance:CurrentMapId()
    return currmapid == 30012 or currmapid == 30013
end