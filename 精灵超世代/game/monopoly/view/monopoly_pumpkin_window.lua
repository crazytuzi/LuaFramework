---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/22 21:31:19
-- @description: 大富翁南瓜机
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _num_distance = 100 -- 两个数字之间的距离
local _start_end_dis = 200 -- 起始点和终点之间的距离

MonopolyPumpkinWindow = MonopolyPumpkinWindow or BaseClass(BaseView)

function MonopolyPumpkinWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "monopoly/monopoly_pumpkin_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("monopoly", "monopolyboard"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("monopoly","monopoly_big_bg_1"), type = ResourcesType.single },
    }

    self.is_can_close = false -- 当前是否能关闭界面
    self.cur_result_num = 0 -- 骰子结果数字
    self.cur_ani_time = 0 -- 当前数字动画滚动了多少秒
    self.cur_ani_speed = 600 -- 当前数字滚动的速度
end

function MonopolyPumpkinWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setTouchEnabled(false)
    delayRun(self.background, 0.5, function ()
        self.background:setTouchEnabled(true)
    end)

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self.con_size = container:getContentSize()
    self:playEnterAnimatianByObj(container , 2) 

    self.bg_sp = container:getChildByName("bg_sp")
    loadSpriteTexture(self.bg_sp, PathTool.getPlistImgForDownLoad("monopoly","monopoly_big_bg_1"), LOADTEXT_TYPE)

    -- 数字动画移动的起始、结束点y坐标
    self.ani_start_pos_y = self.con_size.height*0.5-_start_end_dis*0.5
    self.ani_end_pos_y = self.con_size.height*0.5+_start_end_dis*0.5

    self.num_object_list = {}
    for i = 1, 4 do
        local object = {}
        local res_str = PathTool.getResFrame("monopoly", "monopolyboard_num_" .. i, false, "monopolyboard")
        object.num_sp = createSprite(res_str, 360, self.ani_start_pos_y, container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 2)
        object.num = i
        _table_insert(self.num_object_list, object)
    end
end

function MonopolyPumpkinWindow:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickGround), false, 1)

    -- 摇骰子结果
    self:addGlobalEvent(MonopolyEvent.Get_Dice_Result_Event, function ( num )
        self.cur_result_num = num
    end)
end

function MonopolyPumpkinWindow:onClickGround()
    if self.is_can_close then
        _controller:openMonopolyPumpkinWindow(false)
    elseif self.cur_result_num then
        -- 跳过动画
        AudioManager:getInstance():removeEffectBySoundId(self.scroll_audio_effect)
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Recruit, "result_01", false)
        for i, object in ipairs(self.num_object_list) do
            object.num_sp:stopAllActions()
            object.num_sp:setVisible(object.num == self.cur_result_num)
            if object.num == self.cur_result_num then
                object.num_sp:setPosition(360, self.ani_end_pos_y-_start_end_dis*0.5)
            end
        end
        self:handleEffect_1(true, PlayerAction.action_1)
        self:handleEffect_2(true, PlayerAction.action_1)
        self.is_can_close = true
        self:openNumRollTimer(false)
        -- 延迟1秒
        delayRun(self.root_wnd, 1, function ()
            _controller:openMonopolyPumpkinWindow(false)
        end)
    end
end

function MonopolyPumpkinWindow:openRootWnd()
    self.is_can_close = false
    _controller:sender27403(1, 0) -- 请求扔骰子
    self:startPumpkinPlay()
end

-- 开始摇动南瓜机
function MonopolyPumpkinWindow:startPumpkinPlay()
    self.scroll_audio_effect = AudioManager:getInstance():playEffectForHandAudoRemove(AudioManager.AUDIO_TYPE.COMMON,"c_scroll", true)
    self:showRollAniBySpeed(self.cur_ani_speed, true)
    self:openNumRollTimer(true)
    self:handleEffect_1(true, PlayerAction.action_2)
    self:handleEffect_2(true, PlayerAction.action_2)
end

-- 南瓜机底盘
function MonopolyPumpkinWindow:handleEffect_1(status, action_name, is_pool)
    if status == true then
        action_name = action_name or PlayerAction.action_1
        is_pool = is_pool or false
        self.cur_action_name = action_name
        if not tolua.isnull(self.container) and self.effect_1 == nil then
            self.effect_1 = createEffectSpine(Config.EffectData.data_effect_info[1502], cc.p(-25, -280), cc.p(0.5, 0.5), is_pool, action_name, handler(self, self.onEffectCallBack))
            self.container:addChild(self.effect_1, 1)
        elseif self.effect_1 then
            self.effect_1:setToSetupPose()
            self.effect_1:setAnimation(0, action_name, true)
        end
    else
        if self.effect_1 then
            self.effect_1:clearTracks()
            self.effect_1:removeFromParent()
            self.effect_1 = nil
        end
    end
end

function MonopolyPumpkinWindow:onEffectCallBack()
    if self.cur_action_name == PlayerAction.action_2 then
        self:handleEffect_1(true, PlayerAction.action_3, true)
        self:handleEffect_2(true, PlayerAction.action_3, true)
    end
end

-- 南瓜机
function MonopolyPumpkinWindow:handleEffect_2(status, action_name, is_pool)
    if status == true then
        action_name = action_name or PlayerAction.action_1
        is_pool = is_pool or false
        if not tolua.isnull(self.container) and self.effect_2 == nil then
            self.effect_2 = createEffectSpine(Config.EffectData.data_effect_info[1501], cc.p(-25, -280), cc.p(0.5, 0.5), is_pool, action_name)
            self.container:addChild(self.effect_2, 3)
        elseif self.effect_2 then
            self.effect_2:setToSetupPose()
            self.effect_2:setAnimation(0, action_name, true)
        end
    else
        if self.effect_2 then
            self.effect_2:clearTracks()
            self.effect_2:removeFromParent()
            self.effect_2 = nil
        end
    end
end

-- 定时器
function MonopolyPumpkinWindow:openNumRollTimer(status)
    if status == true then
        if self.roll_timer == nil then
            self.roll_timer = GlobalTimeTicket:getInstance():add(function()
                self.cur_ani_time = self.cur_ani_time + 1
                if self.cur_ani_time >= 1.5 and self.cur_ani_speed ~= 350 then
                    self:showRollAniBySpeed(350)
                elseif self.cur_ani_time >= 2.5 then
                    self:showRollAniBySpeed(180)
                    self.ani_over_flag = true
                    GlobalTimeTicket:getInstance():remove(self.roll_timer)
                    self.roll_timer = nil
                end
            end, 1)
        end
    else
        if self.roll_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.roll_timer)
            self.roll_timer = nil
        end
    end
end

-- 根据速度显示数字滚动动画
function MonopolyPumpkinWindow:showRollAniBySpeed(speed, is_first)
    self.cur_ani_speed = speed
    local ani_once_time = _start_end_dis/speed
    for i, object in ipairs(self.num_object_list) do
        object.num_sp:stopAllActions()
        local call_back = function ()
            local once_delay = (#self.num_object_list*_num_distance-_start_end_dis)/speed
            local move_act_1 = cc.MoveTo:create(0, cc.p(360, self.ani_start_pos_y))
            local move_act_2 = cc.MoveTo:create(ani_once_time*0.5, cc.p(360, self.ani_end_pos_y-_start_end_dis*0.5))
            local once_middle_back = cc.CallFunc:create(function ()
                if self.ani_over_flag and self.cur_result_num == object.num then -- 动画时间到了
                    self:stopAllNumAni()
                end
            end)
            local move_act_3 = cc.MoveTo:create(ani_once_time*0.5, cc.p(360, self.ani_end_pos_y))
            local sequence = cc.Sequence:create(move_act_1, cc.DelayTime:create(once_delay), move_act_2, once_middle_back, move_act_3)
            object.num_sp:runAction(cc.RepeatForever:create(sequence))
        end
    
        local cur_pos_y = object.num_sp:getPositionY()
        local first_time = (self.ani_end_pos_y-cur_pos_y)/speed
        local first_move = cc.MoveTo:create(first_time, cc.p(360, self.ani_end_pos_y))
        local delay_time = 0
        if is_first then
            delay_time = (i-1)*(_num_distance/speed)
        elseif cur_pos_y == self.ani_start_pos_y then
            delay_time = 0
            for k = 1, 3 do
                local index = i-k
                if index < 1 then
                    index = index + 4
                end
                local pre_object = self.num_object_list[index]
                if pre_object then
                    local pre_pos_y = pre_object.num_sp:getPositionY()
                    if pre_pos_y ~= self.ani_start_pos_y then
                        delay_time = k*(_num_distance/speed) - (pre_pos_y - self.ani_start_pos_y)/speed
                        break
                    end
                end
            end
        end
        object.num_sp:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time), first_move, cc.CallFunc:create(call_back)))
    end
end

-- 结束数字滚动动画
function MonopolyPumpkinWindow:stopAllNumAni()
    AudioManager:getInstance():removeEffectBySoundId(self.scroll_audio_effect)
    AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Recruit, "result_01", false)
    for i, object in ipairs(self.num_object_list) do
        object.num_sp:stopAllActions()
        object.num_sp:setVisible(object.num == self.cur_result_num)
    end
    self:handleEffect_1(true, PlayerAction.action_1, true)
    self:handleEffect_2(true, PlayerAction.action_1, true)
    self.is_can_close = true
    self:openNumRollTimer(false)
    -- 延迟1秒
    delayRun(self.root_wnd, 1, function ()
        _controller:openMonopolyPumpkinWindow(false)
    end)
end

function MonopolyPumpkinWindow:close_callback()
    AudioManager:getInstance():removeEffectBySoundId(self.scroll_audio_effect)
    self:handleEffect_1(false)
    self:handleEffect_2(false)
    for i, object in ipairs(self.num_object_list) do
        object.num_sp:stopAllActions()
    end
    if self.cur_result_num and self.cur_result_num > 0 then
        GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Role_Move_Event, self.cur_result_num)
    end
    self:openNumRollTimer(false)
    _controller:openMonopolyPumpkinWindow(false)
end