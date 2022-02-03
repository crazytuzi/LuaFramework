-- --------------------------------------------------------------------
-- 引导控制器
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-06-06
-- --------------------------------------------------------------------
GuideController = GuideController or BaseClass(BaseController)

GuideType = {
    ui = 1,         -- UI引导,这类引导如果剧情触发的时候还处于战斗中,则不会去播,否则播放
    battle = 2      -- 战斗引导,这类引导只存在客户端处于战斗状态下才会播放
}

local table_insert = table.insert

function GuideController:config()
    self.model = GuideModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.guide_list = {} -- 当前需要播放的引导缓存列表
    self.is_guiding = false  -- 当前是否处于引导中

    self.last_guide_id = 0
    self.cur_guide_config = nil
    self.last_guide_pos = nil -- 记录一下最后一个引导手指的位置

    self.guide_finish_step = {}
end

function GuideController:getModel()
    return self.model
end

function GuideController:registerProtocals()
    self:RegisterProtocal(11120, "handle_11120")   -- 播放引导
    self:RegisterProtocal(11121, "handle_11121")   -- 引导心跳包
    self:RegisterProtocal(11123, "handle_11123")   -- 清除所有剧情和引导
end

function GuideController:registerEvents()
    -- 剧情结束,判断是否需要播放引导
    if self.story_over_event == nil then
        self.story_over_event = GlobalEvent:getInstance():Bind(StoryEvent.STORY_OVER, function() 
            if self.guide_list ~= nil and next(self.guide_list) ~= nil then
                local config = table.remove(self.guide_list, 1)
                self:checkGuideToPlay(config)
            end
        end)
    end
    
    -- 升级界面关闭之后,判断是否需要播放引导
    if self.can_play_drama_event == nil then
        self.can_play_drama_event = GlobalEvent:getInstance():Bind(StoryEvent.PREPARE_PLAY_PLOT, function() 
            if self.guide_list ~= nil and next(self.guide_list) ~= nil then
                local config = table.remove(self.guide_list, 1)
                self:checkGuideToPlay(config)
            end
        end)
    end
end

--==============================--
--desc:判断一个引导的状态是否正确,然后去去播
--time:2017-07-28 05:15:10
--@return 
--==============================--
function GuideController:checkGuideToPlay(config)
    if config == nil then return end

    -- 正在播放当前引导,不需要储存了
    if self.cur_guide_config ~= nil and self.cur_guide_config.id == config.id then return end

    -- 待播放引导列表里面存在,也不需要存了
    for k,v in pairs(self.guide_list) do
        if v.id == config.id then
            return
        end
    end

    -- 剧情状态下.不播放引导
    local story_status = StoryController:getInstance():getModel():isStoryState() or false 
    if story_status == true then
        table_insert( self.guide_list, 1, config )
        return
    end

    -- 如果出升级提示
    local is_inlevipgrade = LevupgradeController:getInstance():waitLevupgrade()
    if is_inlevipgrade then
        table_insert( self.guide_list, 1, config )
        return
    end

    -- 如果在引导中的时候,不播,缓存这吧
    if self.cur_guide_config ~= nil then
        table_insert( self.guide_list, 1, config )
        return
    end

    if next(config.act) ~= nil then
        self:playGuide(config)
    end
end

--==============================--
--desc:开始播放客户端引导
--time:2017-07-24 08:06:26
--@status:
--@id:
--@return  
--==============================--
function GuideController:startPlayGuide(status, id, is_skip)
    if status == false then
        -- 这个时候做一个处理吧
        self:delayTouchEnabled()
        if self.guide_view then
            self.guide_view:DeleteMe()
            self.guide_view = nil
        end
        self.is_guiding = false
        self.cur_guide_config = nil
        self:sendServerGuideOver(id, is_skip)

        -- 是否有下一个引导
        if self.guide_list ~= nil and next(self.guide_list) ~= nil then
            if self.guide_list ~= nil and next(self.guide_list) ~= nil then
                local config = table.remove( self.guide_list, 1 )
                self:checkGuideToPlay(config)
            end
        else
            -- 主ui的聊天气泡
            MainuiController:getInstance():setMainUIChatBubbleStatus(true)
        end

        self.model:setGuideID(nil)
        -- 结束引导
        GlobalEvent:getInstance():Fire(GuideEvent.Update_Guide_Status_Event, false)
    else
        -- 如果客户端缓存已经完成了该引导则不需要继续了
        local guide_cache = RoleEnv:getInstance():get(RoleEnv.keys.guide_step_list, {})
        if guide_cache[id] ~= nil then
            if guide_cache[id][RoleEnv.keys.guide_over_step] == true then
                self:startPlayGuide(false, id)
                return 
            end
        end

        local config = Config.DramaData.data_guide[id]
        if config == nil or config.act == nil or next(config.act) == nil then 
            self:startPlayGuide(false, id)
            return 
        end

        -- 判断播放引导
        self:checkGuideToPlay(config)

        -- 播放引导
        GlobalEvent:getInstance():Fire(GuideEvent.Update_Guide_Status_Event, true)
    end
end

function GuideController:delayTouchEnabled()
    local layout = ViewManager:getInstance():getLayerByTag(ViewMgrTag.DEBUG_TAG)
    if not tolua.isnull(layout) then
        layout:setSwallowTouches(true)
        GlobalTimeTicket:getInstance():add(function()
            layout:setSwallowTouches(false)
        end, 0.2, 1, "lock_touchenable_debugtag")
    end
end

function GuideController:playGuide(config)
    if self.is_guiding == true then return end
    self.cur_guide_config = config
    self.is_guiding = true   
    
    if config.is_close == 1 then
        BaseView.closeAllView()
    end
    BaseView.closeSomeWin()

    -- 主ui的聊天气泡
    MainuiController:getInstance():setMainUIChatBubbleStatus(false)

    if self.guide_view == nil then
        self.guide_view = GuideMainView.new(self)
    end
    if self.guide_view.is_open == false then
        self.guide_view:open(config)
    end
end

-- 记录最后一次引导的手指位置
function GuideController:setGuideLastPos( pos )
    self.last_guide_pos = pos
end

function GuideController:getGuideLastPos(  )
    return self.last_guide_pos
end

--==============================--
--desc:伙伴进阶面板不但需要判断是否在剧情中,还需要判断是否是指定的引导才决定是否关闭全部面板
--time:2017-08-11 09:41:26
--@return 
--==============================--
function GuideController:getGuideConfig()
    return self.cur_guide_config
end

--==============================--
--desc:返回当前全部引导列表
--time:2017-08-11 10:38:06
--@return 
--==============================--
function GuideController:getGuideList()
    return self.guide_list
end

--==============================--
--desc:是否有待播放的引导
--time:2017-08-17 04:01:26
--@return 
--==============================--
function GuideController:inGuideQueue()
    return self.guide_list and next(self.guide_list) ~= nil
end

function GuideController:isInGuide()
    return self.is_guiding
end

function GuideController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

--==============================--
--desc:服务器通知播放引导，如果这个时候客户端正在播放该id的引导，则不处理，可能是短线重连引起的，客户端按照自己节奏继续播
--time:2017-08-18 10:03:48
--@data:
--@return 
--==============================--
function GuideController:handle_11120(data)
    if data == nil or data.id == nil or data.id == 0 then return end
    if self.cur_guide_config ~= nil and self.cur_guide_config.id == data.id then return end
    -- 如果没有引导数据,直接结束掉
    local config = Config.DramaData.data_guide[data.id]
    if config == nil then 
        self:startPlayGuide(false, data.id)
        return
    end
    self.model:setGuideID(data.id)
    --引导前给需要特殊处理界面抛事件
    GlobalEvent:getInstance():Fire(GuideEvent.Update_Guide_Open_Event)

    -- 储存服务器发送过来的该引导已经完成的步数
    self:startPlayGuide(true, data.id)
end

--==============================--
--desc:获取服务器发送过来的上次完成该引导的步数
--time:2018-01-10 06:39:36
--@id:
--@return 
--==============================--
function GuideController:getGuideFinishStep(id)
    if self.guide_finish_step ~= nil and self.guide_finish_step[id] ~= nil then
        return self.guide_finish_step[id]
    end
    return 0
end

--==============================--
--desc:关键步引导通知服务端,确认网络是正常的才下一步
--time:2017-08-17 03:06:59
--@guide_id:
--@step:
--@return 
--==============================--
function GuideController:checkNetWorkNormal(guide_id, step)
    local protocal = {}
    protocal.id = guide_id
    protocal.n = step
    self:SendProtocal(11121, protocal)
end

function GuideController:handle_11121(data)
    if self.guide_view then
        self.guide_view:doNextGuideFromServer(data.id, data.n)
    end
end

--==============================--
--desc:通知服务端引导结束
--time:2017-08-17 03:20:37
--@id:
--@return 
--==============================--
function GuideController:sendServerGuideOver(id, is_skip)
    if is_skip == true then
        is_skip = TRUE
    else
        is_skip = FALSE
    end

    local protocal = {}
    protocal.id = id
    protocal.is_skip = is_skip
    self:SendProtocal(11122, protocal)
end

--==============================--
--desc:收到这条协议要清除掉当前的剧情
--time:2017-08-17 03:29:26
--@data:
--@return 
--==============================--
function GuideController:handle_11123(data)
    local story_status = StoryController:getInstance():getModel():isStoryState() or false 
    if story_status == true then
        GlobalEvent:getInstance():Fire(StoryEvent.SKIP_STORY)
    end

    if self.cur_guide_config ~= nil then
        self:startPlayGuide(false, self.cur_guide_config.id)
    end
end