-- --------------------------------------------------------------------
-- 新的主中心城控制器
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
MainSceneController = MainSceneController or BaseClass(BaseController)

local global_event = GlobalEvent:getInstance()
local table_insert = table.insert

function MainSceneController:config()
    self.dispather              = GlobalEvent:getInstance()
    self.has_init               = false 
end

function MainSceneController:registerProtocals()
    self:RegisterProtocal(10304, "handle10304")
    -- 当前战斗情况
    self:RegisterProtocal(20063, "handle20063")
    self:RegisterProtocal(10955, "handle10955")
end

function MainSceneController:registerEvents()
	if self.init_main_event == nil then
        self.init_main_event = global_event:Bind(EventId.ROLE_CREATE_SUCCESS, function()
			GlobalEvent:getInstance():UnBind(self.init_main_event)
            self.init_main_event = nil
            RenderMgr:getInstance():start()
            GlobalEvent:getInstance():Fire(SceneEvent.FIRST_TIME_LOAD_FINISH)

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                if self.update_self_event == nil then
                    self.update_self_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function( key, value )
                        if key == "lev" or key == "open_day" then -- 判断是否有解锁的
                            self:checkBuildLockStatus()
                        end
                    end)
                end
            end
		end)
	end
    if self.world_lev_event2 == nil then
        self.world_lev_event2 = GlobalEvent:getInstance():Bind(RoleEvent.WORLD_LEV,function()
            self:checkBuildLockStatus()
        end)
    end


    if self.update_drama_max_event == nil then
        self.update_drama_max_event = global_event:Bind(Battle_dramaEvent.BattleDrama_Update_Max_Id, function(max_id)
            if self.has_init == false then
                self.has_init = true
                self:createBuildVo()

                -- 初始化建筑之后,请求建筑的战斗状态
                self:requestFightStatus()
            else
                self:checkBuildLockStatus()
            end
        end)
    end

    if self.move_to_builditem_event == nil then
        self.move_to_builditem_event = global_event:Bind(SceneEvent.MoveToBuildEvent, function(bid, show_figer, delay)
            if self.main_scene then
                self.main_scene:movoToBuildPos(bid,show_figer,delay)
            end
        end)
    end

    if self.battle_enter_event == nil then
        self.battle_enter_event = global_event:Bind(SceneEvent.ENTER_FIGHT, function(combat_type)
            if combat_type == BattleConst.Fight_Type.Nil then return end    -- 假战斗不需要做任何判断
            if BaseView.winMap and next(BaseView.winMap) ~= nil then
                for i, v in ipairs(BaseView.winMap) do
                    if not v.is_before_battle then
                        v.enter_battle_status = v:getVisible()
                        v.is_before_battle = true       -- 是否是在战斗之前就存在的
                        if v.enter_battle_status == true then
                            v:setVisible(false)
                        end
                    end
                end
            end
            self:handleSceneStatus(false)
        end)
    end

    if self.battle_exit_event == nil then
        self.battle_exit_event = global_event:Bind(SceneEvent.EXIT_FIGHT, function(combat_type)
            if combat_type == BattleConst.Fight_Type.Nil then return end    -- 假战斗不需要做任何判断
            local need_show_scene = true
            if BaseView.winMap and next(BaseView.winMap) ~= nil then
                for i, v in ipairs(BaseView.winMap) do
                    if v.setVisible then
                        if v.enter_battle_status == nil then
                            v.enter_battle_status = true
                        end
                        v:setVisible(v.enter_battle_status)
                        if need_show_scene == true then
                            if v.win_type == WinType.Full and v.enter_battle_status == true then
                                need_show_scene = false
                            end
                        end
                        v.is_before_battle = false
                    end
                end
            end
            if need_show_scene == true and not MainuiController:getInstance():isInSkySceneOrDramaScene() then
                self:handleSceneStatus(true)
            end
        end)
    end

    -- 断线重连的时候
    if self.re_link_game_event == nil then
        self.re_link_game_event = global_event:Bind(LoginEvent.RE_LINK_GAME, function()
            -- 初始化建筑之后,请求建筑的战斗状态
            self:requestFightStatus()
        end)
    end
end

--==============================--
--desc:因为存在剧情所以这个时候不能直接显示主城,但是又因为断线重连的时候可能触发
--time:2018-07-12 09:45:52
--@data:
--@return 
--==============================--
function MainSceneController:handle10304(data)
    if self.main_scene == nil then
        self:enterScene(true, data.play_video)
        if log_enter_city then log_enter_city(LoginController:getInstance():getModel():getLoginData().usrName) end
    end
end

--==============================--
--desc:因为存在剧情所以这个时候不能直接显示主城,但是又因为断线重连的时候可能触发
--time:2018-07-12 09:45:52
--@status:显示或者隐藏主城
--@return 
--==============================--
function MainSceneController:enterScene(status, play_video)
    if status == false then
        if self.main_scene then
            self.main_scene:DeleteMe()
            self.main_scene = nil
        end
    else
        if self.main_scene == nil then
            local config = Config.city_data[1]
            if USESCENEMAKELIFEBETTER == true then          -- 提审包,马甲包就用这个
                config = Config.city_data[2]
            end
            self.main_scene = CenterCityScene.New(config)
        end
        self:handleSceneStatus(true, true)
    end
end

---播放视频
function MainSceneController:videoPlayer()
    if PLATFORM == cc.PLATFORM_OS_WINDOWS or PLATFORM == cc.PLATFORM_OS_MAC then 
        self:handleSceneStatus(true)
        return 
    end

    local base_res = "res/resource/login/gamecg.mp4"
    local assets_res = cc.FileUtils:getInstance():getWritablePath().."assets/res/resource/login/gamecg.mp4"
    if cc.FileUtils:getInstance():isFileExist(assets_res) then
        base_res = assets_res
    end
    local tryver_res = cc.FileUtils:getInstance():getWritablePath().."tryver/assets/res/resource/login/gamecg.mp4"
    if cc.FileUtils:getInstance():isFileExist(tryver_res) then
        base_res = tryver_res
    end
    if not cc.FileUtils:getInstance():isFileExist(base_res) then
        self:handleSceneStatus(true)
        return 
    end

    if self.is_playing_video == true then return end
    self.is_playing_video = true

    -- 把音乐停掉
    AudioManager:getInstance():stopMusic()
    local parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.LOADING_TAG) 
    local function finish_callback(video)
        video:stop()
        video:runAction(cc.RemoveSelf:create(true))
        self.is_playing_video = false
        self:handleSceneStatus(true)
        RoleController:getInstance():restartPlayRename()        -- 通知弹出创角界面
    end

    local videoPlayer = ccexp.VideoPlayer:create()
    local function onVideoEventCallback(sener, eventType)
        if eventType == ccexp.VideoPlayerEvent.PLAYING then
        elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
        elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
        elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
            finish_callback(videoPlayer)
        end
    end

    videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
    videoPlayer:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    videoPlayer:setFullScreenEnabled(true)
    videoPlayer:setPosition(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
    videoPlayer:addEventListener(onVideoEventCallback)
    parent:addChild(videoPlayer,998)
    if IS_IOS_PLATFORM == true and videoPlayer.setControlStyle then
        videoPlayer:setControlStyle(1)  -- 1取消掉进度条 2显示进度条 3全屏
        videoPlayer:setUserInteractionEnabled(false)
    end
    videoPlayer:setFileName(base_res)
    videoPlayer:play()

    -- 视频触控
    videoPlayer:setTouchEnabled(true)
    videoPlayer:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- sender:stop()
            -- sender:runAction(cc.RemoveSelf:create(true))
            -- video_finish = true
            -- fininsh_callback()
            finish_callback(sender)
        end
    end)
end

--- 是否是播放录像状态
function MainSceneController:getPlayVideoStatus()
    return self.is_playing_video
end

--==============================--
--desc:显示主城以及显示主UI
--time:2018-07-12 09:47:28
--@status:
--@return 
--==============================--
function MainSceneController:handleSceneStatus(status, is_init)
    if self.main_scene == nil then return end
    if is_init == true and NEEDCHANGEENTERSTATUS and NEEDCHANGEENTERSTATUS ~= 0 then
    else
        self.main_scene:setVisible(status)
        if status == true then
            self.main_scene:playBackgroundMusic()
        end
    end
    MainuiController:getInstance():openMainUI(status)
end

-- 主城场景显示特效
function MainSceneController:showMainSceneEffect( status, id, action, num )
    if self.main_scene then
        self.main_scene:showSceneEffectById(status, id, action, num)
    end
end

-- 主城场景移动到中间位置
function MainSceneController:moveToCenterPos(  )
    if self.main_scene then
        self.main_scene:moveToCenterPos()
    end
end

--==============================--
--desc:引导需要,根据这个节点获取相关的东西
--time:2018-06-27 09:34:30
--@return 
--==============================--
function MainSceneController:getMainCenterScene()
    if self.main_scene then
        return self.main_scene.root
    end
end

--==============================--
--desc:引导需要
--time:2018-06-27 03:08:17
--@id:
--@return 
--==============================--
function MainSceneController:getCenterCityBuildById(id)
    if self.main_scene then
        return self.main_scene:getBuildById(id)
    end
end 

--==============================--
--desc:场景建筑气泡点击
--time:2018-06-27 09:34:55
--@bid:
--@return 
--==============================--
function MainSceneController:openBuild(bid, extend)
    if bid == CenterSceneBuild.shop then                    -- 商业区
        MallController:getInstance():openMallPanel(true)
        --Area_sceneController:getInstance():openAreaScene(true, Config.city_data[3])
    elseif bid == CenterSceneBuild.seerpalace then          -- 先知殿
        SeerpalaceController:getInstance():openSeerpalaceMainWindow(true)
    -- elseif bid == CenterSceneBuild.fuse then                -- 融合祭坛
    --     HeroController:getInstance():openHeroResetWindow(true, HeroConst.SacrificeType.eHeroFuse)
    elseif bid == CenterSceneBuild.arena then               -- 竞技场
        ArenaController:getInstance():requestOpenArenWindow(extend)
    elseif bid == CenterSceneBuild.summon then              -- 召唤
        PartnersummonController:getInstance():openPartnerSummonWindow(true)
        PartnersummonController:getInstance():getModel():setOpenPartnerSummonFlag(true)
    elseif bid == CenterSceneBuild.library then             -- 图书馆
        HeroController:getInstance():openHeroLibraryMainWindow(true)
    elseif bid == CenterSceneBuild.startower then           -- 星命塔
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.StarTower)
    elseif bid == CenterSceneBuild.mall then                -- 锻造屋
        ForgeHouseController:getInstance():openForgeHouseView(true)
    elseif bid == CenterSceneBuild.variety then             -- 杂货店
        MallController:getInstance():openVarietyStoreWindows(true)
    elseif bid == CenterSceneBuild.guild then               -- 祭坛小屋 分解英雄
        HeroController:getInstance():openHeroResetWindow(true,HeroConst.SacrificeType.eHeroFuse)
    elseif bid == CenterSceneBuild.adventure then           -- 冒险
        AdventureActivityController:getInstance():openAdventureActivityMainWindow(true)
    elseif bid == CenterSceneBuild.ladder then              -- 跨服天梯
        CrossgroundController:getInstance():openCrossGroundMainWindow(true)
    elseif bid == CenterSceneBuild.crossshow then           -- 跨服时空
        CrossshowController:getInstance():openCrossshowMainWindow(true)
    elseif bid == CenterSceneBuild.home then                -- 家园
        HomeworldController:getInstance():requestOpenMyHomeworld()
    elseif bid == CenterSceneBuild.resonate then                -- 共鸣水晶
        HeroController:getInstance():openHeroResonateWindow(true)
    elseif bid == CenterSceneBuild.luckytreasure then                -- 幸运探宝
        ActionController:getInstance():openLuckyTreasureWin(true)
    end
end

--==============================--
--desc:创建场景单位
--time:2018-06-27 09:34:55
--@bid:
--@return 
--==============================--
function MainSceneController:createBuildVo()
    if self.role_vo == nil then return end
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    if drama_data == nil then return end

    self.build_list_vo = {}
    local scene_config = Config.city_data[1]
    if USESCENEMAKELIFEBETTER then
        scene_config = Config.city_data[2] 
    end

    for i,v in ipairs(scene_config.building_list) do
        if v.type == BuildItemType.build then   --是建筑
            local config = Config.CityData.data_base[v.bid]
            if config ~= nil and config.activate ~= nil then
                local is_lock = false
                for i,v in ipairs(config.activate) do
                    local condition_type = v[1]
                    local condition_value = v[2]
                    local max_value = 0
                    if condition_type == "dun" then
                        max_value = drama_data.max_dun_id
                    elseif condition_type == "lev" then
                        max_value = self.role_vo.lev
                    elseif condition_type == "open_day" then
                        max_value = self.role_vo.open_day
                    elseif condition_type == "world_lev" then
                        local world_lev = RoleController:getInstance():getModel():getWorldLev()
                        if world_lev then
                            max_value = world_lev
                        end
                    end
                    if condition_value > max_value then
                        is_lock = true 
                        break
                    end
                end
                local build_vo = BuildVo.New(v, is_lock, config.activate, config.desc, config.is_verifyios)
                -- 缓存的红点状态
                if self.cache_tips_list and self.cache_tips_list[v.bid] then
                    build_vo:setTipsStatus(self.cache_tips_list[v.bid])
                    self.cache_tips_list[v.bid] = nil
                end
                self.build_list_vo[v.bid] = build_vo
            end
        end
    end
    global_event:Fire(SceneEvent.CreateBuildVoOver)
end

--[[
    @desc: 
    author:{author}
    time:2018-05-25 15:14:11
    return
]]
function MainSceneController:getBuildList()
    return self.build_list_vo
end

--==============================--
--desc:返回主场景上面的一个建筑的数据
--time:2018-07-13 09:54:06
--@id: CenterSceneBuild,取这里
--@return 
--==============================--
function MainSceneController:getBuildVo(id)
    if self.build_list_vo and self.build_list_vo[id] then 
        return self.build_list_vo[id]
    end
end

--[[
    @desc:检测建筑是否开启
    author:{author}
    time:2018-05-25 16:46:31
    --@dun_id:当前通关的最大副本
    return
]]
function MainSceneController:checkBuildLockStatus()
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    if drama_data == nil or self.role_vo == nil then return end

    local role_vo = self.role_vo
    if self.build_list_vo and role_vo then
        for i, vo in pairs(self.build_list_vo) do
            if vo.activate ~= nil and vo.is_lock == true then
                local is_lock = false
                for i,v in ipairs(vo.activate) do
                    local condition_type = v[1]
                    local condition_value = v[2]
                    local max_value = 0
                    if condition_type == "dun" then
                        max_value = drama_data.max_dun_id
                    elseif condition_type == "lev" then
                        max_value = self.role_vo.lev
                    elseif condition_type == "open_day" then
                        max_value = self.role_vo.open_day
                    elseif condition_type == "world_lev" then
                        local world_lev = RoleController:getInstance():getModel():getWorldLev()
                        if world_lev then
                            max_value = world_lev
                        end
                    end
                    if condition_value > max_value then
                        is_lock = true 
                        break
                    end
                end
                if is_lock ~= vo.is_lock then
                    vo:setLockStatus(is_lock)
                end
            end
        end
    end
end

--- 召唤弱引导
function MainSceneController:handle10955(data)
    if self.build_list_vo == nil then return end
    
    local id = CenterSceneBuild.summon
    local build_vo = self.build_list_vo[id]
    if build_vo and data.key == 1 then    -- (1: 召唤软引导)
        build_vo:setSpecialGroupId(data.val)
    end
end

--- 召唤弱引导
function MainSceneController:send10956(group_id)
    local protocal = {}
    protocal.key = 1                -- 现在特殊处理死 (1: 召唤软引导)
    protocal.val = group_id
    self:SendProtocal(10956, protocal)
end

--[[
    @desc:设置建筑红点状态
    author:{author}
    time:2018-05-25 16:52:47
    --@id:
	--@data:红点状态可以是单个 boolean,也可以是 {bid=XX,status=boolean},也可以是{{bid=XX,status=boolean}, {bid=YY,status=boolean}} ,其他格式不做处理
    return
]]
function MainSceneController:setBuildRedStatus(id, data)
    if self.build_list_vo == nil or self.build_list_vo[id] == nil then
        if self.cache_tips_list == nil then
            self.cache_tips_list = {}
        end
        if type(data) == "table" then
            if self.cache_tips_list[id] == nil then
                self.cache_tips_list[id] = {}
            end
            if #data > 1 then   -- 这个就是表示有多个table
                for k,v in pairs(data) do
                    if v.bid ~= nil and type(v.bid) == "number" then
                        self.cache_tips_list[id][v.bid] = v
                    end
                end
            else
                if data.bid ~= nil and type(data.bid) == "number" then
                    self.cache_tips_list[id][data.bid] = data
                end
            end
        else
            self.cache_tips_list[id] = data
        end
    else
        local build_vo = self.build_list_vo[id]
        build_vo:setTipsStatus(data)
    end
    -- 监测红点
    MainuiController:getInstance():checkMainSceneIconStatus()
end

--==============================--
--desc:清空某个建筑气泡的所有红点状态
--time:2018-06-07 10:02:00
--@id:
--@return 
--==============================--
function MainSceneController:clearBuildRedStatus(id)
    if self.build_list_vo == nil or self.build_list_vo[id] == nil then return end
    if self.cache_tips_list == nil then
        self.cache_tips_list = {}
    end
    self.cache_tips_list[id] = nil
    local build_vo = self.build_list_vo[id]
    if build_vo ~= nil then
        build_vo:clearTipsStatus()
    end

    -- 监测红点
    MainuiController:getInstance():checkMainSceneIconStatus()
end

--==============================--
--desc:这个时候计算一下时间
--time:2018-07-27 05:36:53
--@return 
--==============================--
function MainSceneController:changeMainCityTimeType(type)
    if self.main_scene then
        self.main_scene:setTimeType(type)
    end
end

--==============================--
--desc:获取主场景
--time:2018-07-30 09:42:48
--@return 
--==============================--
function MainSceneController:getMainScene()
    return self.main_scene
end

--==============================--
--desc:获取建筑
--time:2018-07-19 09:47:27
--@return 
--==============================--
function MainSceneController:getBuildVoList()
    return self.build_list_vo
end
         
function MainSceneController:DeleteMe()
    self:enterScene(false)
    if self.role_vo ~= nil then
        if self.update_self_event ~= nil then
            self.role_vo:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.role_vo = nil
    end
    if self.init_main_event ~= nil then
        global_event:UnBind(self.init_main_event)
        self.init_main_event = nil
    end
    if self.update_drama_max_event ~= nil then
        global_event:UnBind(self.update_drama_max_event)
        self.update_drama_max_event = nil
    end
    if self.move_to_builditem_event ~= nil then
        global_event:UnBind(self.move_to_builditem_event)
        self.move_to_builditem_event = nil
    end
    if self.battle_enter_event ~= nil then
        global_event:UnBind(self.battle_enter_event)
        self.battle_enter_event = nil
    end
    if self.battle_exit_event ~= nil then
        global_event:UnBind(self.battle_exit_event)
        self.battle_exit_event = nil
    end
    if self.re_link_game_event ~= nil then
        global_event:UnBind(self.re_link_game_event)
        self.re_link_game_event = nil
    end
end

function MainSceneController:requestFightStatus()
    self:SendProtocal(20063,{})
end

--- 各个场景建筑泡泡的战斗情况
function MainSceneController:handle20063(data)
    if self.build_list_vo == nil or next(self.build_list_vo ) == nil then return end

    local status_list = {}
    for k,v in pairs(Config.CityData.data_base) do
        status_list[k] = {}
    end
    BattleController:getInstance():setCurFightInfo(data.type_list)

    if data.type_list then
        for i,v in ipairs(data.type_list) do
            local key = self:getBuildIdByCombat(v.combat_type) -- 这个标识在战斗中
            if key then  -- 现在只处理场景上面几个战斗类型
                status_list[key][v.combat_type] = true
            end
        end
    end
    for k,v in pairs(status_list) do
        local buildvo = self.build_list_vo[k]
        if buildvo then
            buildvo:setFightStatus(v)
        end
    end
end

--- 根据战斗类型获取场景建筑id(显示战斗标志)
function MainSceneController:getBuildIdByCombat(combat_type)
    if combat_type == BattleConst.Fight_Type.Arena then
        return CenterSceneBuild.arena
    elseif combat_type == BattleConst.Fight_Type.StarTower then
        return CenterSceneBuild.startower
    elseif combat_type == BattleConst.Fight_Type.Adventrue or combat_type == BattleConst.Fight_Type.AdventrueMine or combat_type == BattleConst.Fight_Type.ElementWar or combat_type == BattleConst.Fight_Type.HeavenWar then
        return CenterSceneBuild.adventure
    elseif combat_type == BattleConst.Fight_Type.LadderWar 
        or combat_type == BattleConst.Fight_Type.EliteMatchWar 
        or combat_type == BattleConst.Fight_Type.EliteKingMatchWar 
        or combat_type == BattleConst.Fight_Type.CrossArenaWar
        or combat_type == BattleConst.Fight_Type.Arean_Team
         or combat_type == BattleConst.Fight_Type.CrossChampion then
        return CenterSceneBuild.ladder
    end
end

--==============================--
--desc:监测场景检出是否可以开启
--time:2018-10-15 11:12:17
--@id:
--@return 
--==============================--
function MainSceneController:checkBuildIsOpen(id)
    local config = Config.CityData.data_base[id]
    if config == nil then return false end
    local drama = BattleDramaController:getInstance():getModel():getDramaData()
    local role_vo = RoleController:getInstance():getRoleVo()
    if config ~= nil and config.activate ~= nil then
        local activate = config.activate[1]
        local condition = activate[1]
        local value = activate[2]
        local cur_value = 0
        if condition == "dun" then
            if drama then
                cur_value = drama.max_dun_id
            end
        elseif condition == "lev" then
            if role_vo then
                cur_value = role_vo.lev
            end
        elseif condition == "world_lev" then
            local world_lev = RoleController:getInstance():getModel():getWorldLev()
            if world_lev then
                cur_value = world_lev
            end
        end
        return cur_value >= value, config.desc
    end
    return false, config.desc
end
