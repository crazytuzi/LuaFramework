-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      竞技场进入循环赛的面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaEnterLoopView = class("ArenaEnterLoopView", function()
    return ccui.Layout:create()
end)

function ArenaEnterLoopView:ctor()
    self.text_list = {}
    self.statue_list = {}
    self.ctrl = ArenaController:getInstance()
    self.model = self.ctrl:getModel()

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_enter_loop_view"))
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local btn_container = self.root_wnd:getChildByName("btn_container")
    self.close_btn = btn_container:getChildByName("close_btn")

    self.enter_btn = btn_container:getChildByName("enter_btn")
    local enter_btn_label = self.enter_btn:getChildByName("label")
    enter_btn_label:setString(TI18N("进入挑战"))
    self.enter_tips = self.enter_btn:getChildByName("tips")
    self.enter_tips:setVisible(false)

    local dec_container = self.root_wnd:getChildByName("dec_container")
    self.tips_btn = dec_container:getChildByName("tips_btn")            -- 规则说明
    self.buy_btn = dec_container:getChildByName("buy_btn")              -- 购买次数按钮

    local worship_title = self.root_wnd:getChildByName("worship")              -- 被膜拜次数
    worship_title:setString(TI18N("被膜拜次数："))
    self.worship = self.root_wnd:getChildByName("worship_num")
    self.worship:setString(1000)

    local label = nil
    for i=1,5 do
        local text_obj = {}
        label = dec_container:getChildByName("label_"..i)               -- 文字描述
        if label then
            label:setString(self:getTitleLabel(i))
        end
        text_obj.label = label
        label = dec_container:getChildByName("label_value_" .. i)
        if label ~= nil then            -- 赛季剩余时间使用的是富文本，所以这里有判断
            text_obj.value = label
            self.text_list[i] = text_obj   -- 1：我的积分 2：我的排名 3：挑战次数 4：赛季时间 5：一般描述
            if i == 5 then
                label:setString(TI18N("赛季结束时将通过邮件发放排名奖励"))
            end
        end
    end

    self.match_desc = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(210, 80), nil, nil, 560)
    dec_container:addChild(self.match_desc)

    self.dec_container = dec_container

    local statue = nil
    for i=1,3 do
        statue = self.root_wnd:getChildByName("statue_"..i)
        statue.role_name = statue:getChildByName("role_name")                   -- 角色名字
        statue.desc = statue:getChildByName("desc")                             -- 虚位以待
        statue.desc:setString(TI18N("虚位以待"))
        statue.btn = statue:getChildByName("worship_btn")                       -- 点赞按钮
        statue.worship_label = statue.btn:getChildByName("label")               -- 点赞数量
        statue.worship_label:setString("")
        statue.model = statue:getChildByName("model")                           -- 存放模型的容器
        statue.model = statue:getChildByName("model")                           -- 存放模型的容器
        statue.size = statue.model:getContentSize()
        statue.index = i
        statue.btn.index = i
        self.statue_list[i] = statue
    end
    self:registerEvent()
end

function ArenaEnterLoopView:registerEvent()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openArenaEnterWindow(false)
        end
    end)

    self.buy_btn:addTouchEventListener( function(sender, event_type)
        customClickAction(sender, event_type, 0.6)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            -- ArenaController:getInstance():requestBuyChallengeTimes()
            ArenaController:getInstance():openArenaLoopChallengeBuy(true)
        end
    end)

    self.enter_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.ctrl:requestOpenArenaLoopMathWindow(true)
        end
    end)

    self.tips_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            MainuiController:getInstance():openCommonExplainView(true, Config.ArenaData.data_explain)
        end
    end)
    
    for k,statue in pairs(self.statue_list) do
        statue.btn:addTouchEventListener(
            function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    if sender.data ~= nil then
                        RoleController:getInstance():requestWorshipRole(sender.data.rid, sender.data.srv_id, sender.index)
                    end
                end
            end
        )
    end
end

function ArenaEnterLoopView:getTitleLabel(i)
    if i == 1 then
        return TI18N("我的积分:")
    elseif i == 2 then
        return TI18N("我的排名:")
    elseif i == 3 then
        return TI18N("挑战劵数:")
    elseif i == 4 then
        return TI18N("赛季时间:")
    else
        return TI18N("系统提示:")
    end
end

function ArenaEnterLoopView:addToParent(status)
    self:setVisible(status)
    self:handleEvent(status)
    self:updateMyData()
    if status == true then
        self.ctrl:requestLoopChallengeStatueList()
        self:checkRedStatus()
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo ~= nil then
        self.worship:setString(role_vo.worship)
    end
end

function ArenaEnterLoopView:updateMyData()
    local data = self.model:getMyLoopData()
    local config = self.model:getZoneConfig() -- 积分区间配置

    if data ~= nil and config ~= nil then
        local test_obj = self.text_list[1]              -- 取第一个是积分
        test_obj.value:setString(string.format("%s", data.score))

        if self.cup_index ~= config.index then
            self.cup_index = config.index
        end
        test_obj = self.text_list[2]
        if data.rank == 0 then
            test_obj.value:setString(TI18N("千里之外"))
        else
            test_obj.value:setString(data.rank)
        end

        local id = Config.ArenaData.data_const.arena_ticketcost.val[1][1]
        local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(id)
        test_obj = self.text_list[3]
        test_obj.value:setString(count)


        local less_time = data.end_time - GameNet:getInstance():getTime()
        if less_time < 0 then
            less_time = 0
        end
        self.match_desc:setString(
            string.format(
                TI18N("%s-%s<div fontcolor=%s>\n（剩余时间:%s）</div>"),
                TimeTool.getMD(data.start_time),
                TimeTool.getMD(data.end_time),
                Config.ColorData.data_new_color_str[12],
                TimeTool.GetTimeFormatTwo(less_time)
            )
        )
    end
end

function ArenaEnterLoopView:updateStatueInfo(list)
    list = list or {}
    local data = nil
    local role_vo = RoleController:getInstance():getRoleVo()
    for i, statue in ipairs(self.statue_list) do
        data = list[statue.index]
        if data == nil then
            statue.role_name:setVisible(false)
            statue.desc:setVisible(true)
            statue.btn:setVisible(false)
        else
            statue.role_name:setVisible(true)
            statue.desc:setVisible(false)
            statue.btn:setVisible(true)
            statue.role_name:setString(data.name)
            statue.worship_label:setString(data.worship)
            statue.worship_num = data.worship               -- 缓存一下当前被赞的数量，这样用于点赞成功之后的数量更改

            if data.worship_status == TRUE or role_vo:isSameRole(data.srv_id, data.rid) then
                statue.btn:setTouchEnabled(false)
                setChildUnEnabled(true, statue.btn, Config.ColorData.data_color4[1])
                statue.worship_label:enableOutline(Config.ColorData.data_color4[2], 2)
            else
                statue.btn:setTouchEnabled(true)
                setChildUnEnabled(false, statue.btn, Config.ColorData.data_color4[175])
                statue.worship_label:enableOutline(Config.ColorData.data_new_color4[9], 2)
            end
        end
        statue.btn.data = data
        -- 延迟创建模型，避免打开面板的时候卡
        delayRun(self.dec_container, 5*i/display.DEFAULT_FPS, function() 
            self:setStatueModel(statue)
        end)
    end
end

function ArenaEnterLoopView:setStatueModel(statue)
    if tolua.isnull(statue) then return end
    local data = statue.btn.data
    if data == nil then
        if  statue.spine ~= nil then
            if statue.spine ~= nil then
                statue.spine:DeleteMe()
                statue.spine = nil
            end
            statue.spine_id = nil
        end
        return
    end

    if statue.spine_id == data.lookid then return end    
    if statue.spine ~= nil then
        statue.spine:DeleteMe()
        statue.spine = nil
    end
    statue.spine_id = data.lookid
    statue.spine = BaseRole.new(BaseRole.type.role, data.lookid)
    statue.spine:setAnimation(0, PlayerAction.show, true)
    statue.spine:setPosition(cc.p(statue.size.width*0.5, 145))
    statue.spine:setAnchorPoint(cc.p(0.5, 0))
    -- statue.spine:setScale(0.72)
    statue.model:addChild(statue.spine)
end

function ArenaEnterLoopView:handleEvent(status)
    if status == false then
        if self.update_self_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        if self.update_statue_list_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_statue_list_event)
            self.update_statue_list_event = nil
        end
        if self.update_worship_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_worship_event)
            self.update_worship_event = nil
        end
        if self.update_arena_red_event then
            GlobalEvent:getInstance():UnBind(self.update_arena_red_event)
            self.update_arena_red_event = nil
        end
    else
        if self.update_self_event == nil then
            self.update_self_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateMyLoopData, function() 
                self:updateMyData()
            end)
        end
        if self.update_statue_list_event == nil then
            self.update_statue_list_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateLoopChallengeStatueList, function(list)
                self:updateStatueInfo(list)
            end)
        end
        if self.update_worship_event == nil then
            self.update_worship_event = GlobalEvent:getInstance():Bind(RoleEvent.WorshipOtherRole, function(rid, srv_id, idx)
                if idx ~= nil then
                    local statue = self.statue_list[idx]
                    if statue ~= nil and statue.worship_label ~= nil and statue.worship_num ~= nil then
                        statue.worship_num = statue.worship_num + 1
                        statue.worship_label:setString(statue.worship_num)
                        statue.btn:setTouchEnabled(false)
                        setChildUnEnabled(true, statue.btn, Config.ColorData.data_color4[1])
                        statue.worship_label:enableOutline(Config.ColorData.data_color4[2], 2)
                    end
                end
            end)
        end
        if self.update_arena_red_event == nil then
            self.update_arena_red_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateArenaRedStatus, function(type, status)
                self:checkRedStatus()
            end)
        end
    end
end

--[[
    @desc: 监测进入挑战按钮红点状态
    author:{author}
    time:2018-08-10 17:16:18
    @return:
]]
function ArenaEnterLoopView:checkRedStatus()
    local red_status = self.model:checkLoopMatchRedStatus()
    self.enter_tips:setVisible(red_status)
end

function ArenaEnterLoopView:DeleteMe()
    doStopAllActions(self.dec_container)
    self:handleEvent(false)
    for i, statue in ipairs(self.statue_list) do
        if statue.spine ~= nil then
            if statue.spine ~= nil then
                statue.spine:DeleteMe()
                statue.spine = nil
            end
        end
    end
    self.status_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end
