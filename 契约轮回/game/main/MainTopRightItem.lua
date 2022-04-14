--
-- @Author: LaoY
-- @Date:   2018-09-18 11:14:14
--
MainTopRightItem = MainTopRightItem or class("MainTopRightItem", BaseCloneItem)

MainTopRightItem.ActionTime = 0.3
MainTopRightItem.special_count = 4

function MainTopRightItem:ctor(obj, parent_node, layer)
    self.start_pos = { x = 0, y = 0 }
    self.evade_pos = { x = 0, y = 0 }
    self.hide_pos = { x = 0, y = 0 }
    self.hide_pos2 = { x = 0, y = 0 }
    self.model = MainModel:GetInstance()
    self.model_event_list = {}
    self.is_can_show = true
    self.row_idx = 1
    self.igonre_thrid_idx_move = true
    self.festival_key = "nation"
    self.timeLimitedTreasureHunt_key = "timeLimitedTreasureHunt"
    self.isShowSub = false
    MainTopRightItem.super.Load(self)
end

function MainTopRightItem:dctor()
    self:StopAction()
    self:StopBirthAction()
    self:RemoveEffect()
    self:StopSchedule()
    if self.show_self_event_id then
        GlobalEvent:RemoveListener(self.show_self_event_id)
        self.show_self_event_id = nil
    end

    if self.main_top_right_sub then
        self.main_top_right_sub:destroy()
    end
    self.main_top_right_sub = nil
end

function MainTopRightItem:RemoveEffect()
    if self.effect then
        self.effect:destroy()
        self.effect = nil
    end

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end

    if self.model_event_list then
        self.model:RemoveTabListener(self.model_event_list)
        self.model_event_list = {}
    end
end

function MainTopRightItem:LoadCallBack()
    self.nodes = {
        "con/icon", "con", "timer/timeTex", "timer",
    }
    self:GetChildren(self.nodes)
    self.icon_component = self.icon:GetComponent('Image')
    self.timeTex = GetText(self.timeTex)
    SetVisible(self.timer, false)
    if self.is_need_loadimagetexture then
        self:LoadImageTexture()
    end

    -- self.effect = UIEffect(self.con, 10201, false)
    -- self.effect:SetOrderIndex(99)

    self.red_dot = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.red_dot:SetPosition(25, 20)

    self:AddEvent()
    self:UpdatePos()
end

function MainTopRightItem:AddEvent()
    local level = 1
    local function call_back(target, x, y)
        if not self.config then
            return
        end
        if self.effect then
            self.effect:destroy()
            self.effect = nil
        end
        if not table.isempty(self.config.sub_tab) then
            self:InitSubPanel()
            return
        end
        MainIconOpenLink(self.config.id, self.config.sub_id, self.data.sign)
    end
    AddButtonEvent(self.icon.gameObject, call_back)

    local function callback(target_key)
        local cf = IconConfig.TopRightConfig[self.data.key_str]
        local key = cf.id .. "@" .. cf.sub_id
        if key == target_key then
            self.is_can_show = true
            SetVisible(self.transform, true)
        end
    end
    self.show_self_event_id = GlobalEvent:AddListener(MainEvent.ShowSelfAfterOpen, callback)

    local function call_back(key_str, param, sign)
        if self.config.sub_tab then
            self:UpdateSubRedDot()
            return
        end
        if self.data.key_str == key_str and (not self.data.sign or self.data.sign == sign) then
            self:UpdateRedDot()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.UpdateRedDot, call_back)
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.ChangeThirdTopRightIconPos, handler(self, self.UpdatePos))

    local function call_back()
        if self.main_top_right_sub then
            self.main_top_right_sub:destroy()
            self.isShowSub = false
        end
        self.main_top_right_sub = nil
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.CloseMainRightSub, call_back)
end

function MainTopRightItem:BirthAction()
    self:StopBirthAction()
    local action
    local action_time = 0.6
    -- 屏幕外移动下来，再缩放
    if self.config.action_type == 1 then
        SetLocalPositionXY(self.con, 0, 400)
        local time_1 = action_time * 2 / 3
        action = cc.MoveTo(time_1, 0, 0, 0)
        action = cc.Spawn(action, cc.ScaleTo(time_1, 0.4))
        local time_2 = action_time / 6
        action = cc.Sequence(action, cc.ScaleTo(time_2, 1.5))
        action = cc.Sequence(action, cc.ScaleTo(time_2, 1))
        -- 原地缩放
    elseif self.config.action_type == 2 then
        local time_1 = action_time * 1 / 3
        action = cc.DelayTime(time_1)
        action = cc.ScaleTo(time_1, 0.4)
        local time_2 = action_time / 6
        action = cc.Sequence(action, cc.ScaleTo(time_2, 1.5))
        action = cc.Sequence(action, cc.ScaleTo(time_2, 1))
        -- 闪烁效果
    elseif self.config.action_type == 3 then
        action_time = 0.5
        action = cc.Blink:Create(action_time, 5, self)
    end
    local function end_call_back()

    end
    if not action then
        return
    end
    action = cc.Sequence(action, cc.CallFunc(end_call_back))
    cc.ActionManager:GetInstance():addAction(action, self.con)
end

function MainTopRightItem:StopBirthAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.con)
end

function MainTopRightItem:StartMoveAction()
    self:StopMoveAction()
    local pos = self.model.is_showing_model_predi and self.evade_pos or self.start_pos
    local action = cc.MoveTo(0.2, pos.x, pos.y, pos.z)
    cc.ActionManager:GetInstance():addAction(action, self)
    self.move_action = action
end

function MainTopRightItem:StopMoveAction()
    if self.move_action then
        cc.ActionManager:GetInstance():removeAction(self.move_action)
        self.move_action = nil
    end
end

function MainTopRightItem:StartAction(time, visible, switch_type)
    if not self.is_loaded then
        return
    end
    self:StopAction()
    local is_visible = visible
    local pos
    if visible then
        --正在展示模型预告
        pos = self.start_pos
        if self.row_idx == 3 then
            pos = self.model.is_showing_model_predi and self.evade_pos or pos
        end
        if self.is_can_show then
            self:SetVisible(visible)
        end
    else
        pos = switch_type == MainModel.SwitchType.City and self.hide_pos or self.hide_pos2
        if self.row_idx == 3 and self.isShow then
            pos = self.model.is_showing_model_predi and self.evade_pos or pos
        end
        -- if switch_type == MainModel.SwitchType.City and self.config and not self.config.is_hide then
        --if switch_type == MainModel.SwitchType.City and self.index <= MainTopRightItem.special_count then
        --    is_visible = true
        --end
        if switch_type == MainModel.SwitchType.City and self.isShow then
            is_visible = true
        end
    end
    -- local rate = self:GetActionTimeRate(visible,switch_type)
    -- local time = MainTopRightItem.ActionTime * rate
    local moveAction = cc.MoveTo(time, pos.x, pos.y, 0)
    local function end_call_back()
        if self.is_can_show then
            self:SetVisible(is_visible)
        end
    end
    local call_action = cc.CallFunc(end_call_back)
    local action = cc.Sequence(moveAction, call_action)
    cc.ActionManager:GetInstance():addAction(action, self.transform)
end

function MainTopRightItem:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end

function MainTopRightItem:SetData(data)
    self.data = data
    self.config = data.cf

    self.transform.name = self.data.key_str
    self:UpdateInfo()
    self:SetEffect()
end
function MainTopRightItem:SetEffect()
    if self.config.is_eff then
        self.effect = UIEffect(self.con, 10201, false)
        local c = {}
        c.scale = 0.8
        self.effect:SetConfig(c)
        --self.effect:SetOrderIndex(99)
    end
end

-- 更新数据 倒计时、图标、红点 都用同一个接口
function MainTopRightItem:UpdateInfo()
    if self.data.key == "escort" then
        -- Yzprint('--LaoY ======>', data)
    end
    --是否忽略倒计时处理
    self.icon_data = GetTopRightConfigByKey(self.data.key)
    if self.data.del_time and (not self.icon_data.is_ignore_cd) then
        SetVisible(self.timer, true)
        if self.data.is_notice then
            self:SetTimeColor(Color(1, 29 / 225, 18 / 255, 1))
            self.isReady = true
        else
            if self.data.is_show_end then
                self:SetTimeColor(Color(1, 29 / 225, 18 / 255, 1))
            else
                self:SetTimeColor(Color(26 / 255, 255 / 255, 54 / 255, 1))
            end
            self.isReady = false
        end
        self:ShowCountDown()

    else
        SetVisible(self.timer, false)
        self:StopSchedule()
    end
    self:LoadImageTexture()
    self:UpdateRedDot()
end

function MainTopRightItem:UpdateRedDot()
    if self.config.sub_tab then
        --local param = self.model:GetSubRedDotParam(self.data.key_str)
        --self.red_dot:SetRedDotParam(param)
        local isRed = false
        for i, v in pairs(self.config.sub_tab) do
            if self.model:GetRedDotParam(v) then
                isRed = true
                break
            end

        end
        self.red_dot:SetRedDotParam(isRed)
        return
    end
    local param = self.model:GetRedDotParam(self.data.key_str, self.data.sign)
    self.red_dot:SetRedDotParam(param)

end

function MainTopRightItem:UpdateSubRedDot()
    local isRed = false
    for i, v in pairs(self.config.sub_tab) do
        if self.model:GetRedDotParam(v) then
            isRed = true
            break
        end
    end
    self.red_dot:SetRedDotParam(isRed)
end

function MainTopRightItem:ShowCountDown()
    if self.data.is_show_end then
        self:StopSchedule()
        self.timeTex.text = "Ended"
    else
        if self.isReady then
            self.countTime = self.data.time_str
        else
            self.countTime = self.data.del_time
        end
        if self.data.is_yy_act and (not self.data.is_show_end) then
            self.countTime = self.data.time_str
        end
        local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.countTime)
        if timeTab then
            self:StopSchedule()
            self.schedule = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
            self:StartCountDown();
        end
    end
end

function MainTopRightItem:StartCountDown()
    local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.countTime)
    local timestr = ""
    if timeTab then
        timeTab.day = timeTab.day or 0
        timeTab.min = timeTab.min or 0;
        timeTab.hour = timeTab.hour or 0;
        timeTab.sec = timeTab.sec or 0
        local is_not_enought_one_day = false
        if timeTab.day == 0 then
            is_not_enought_one_day = true
        end
        local rSec = (timeTab.min * 60) + (timeTab.hour * 3600) + timeTab.sec
        --   local cTime = 1200 + (tonumber(self.data.del_time) - tonumber(self.data.time_str))
        if self.isReady then
            if rSec > 1200 then
                self.timeTex.text = string.format("<color=#ff1d12>%s</color>", os.date("%H:%M", self.data.time_str) .. "Open")
                return
            end
        end
        --运营活动
        if self.data.is_yy_act then
            --不足一天
            if is_not_enought_one_day then
                if timeTab.hour then
                    timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
                end
                if timeTab.min then
                    timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
                end
                if timeTab.sec then
                    timestr = timestr .. string.format("%02d", timeTab.sec);
                end
                self.timeTex.text = timestr
            else
                if timeTab.day and timeTab.day ~= 0 then
                    timestr = timestr .. string.format("%d", timeTab.day) .. "Days";
                end
                if timeTab.hour then
                    timestr = timestr .. string.format("%d", timeTab.hour) .. "hr";
                end
                self.timeTex.text = timestr
            end
        else

            if self.data.key == "compete" then
                -- Yzprint('--LaoY ======>', data)
                local is_not_enought_one_day = false
                if timeTab.day == 0 then
                    is_not_enought_one_day = true
                end

                if is_not_enought_one_day then
                    if timeTab.hour then
                        timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
                    end
                    if timeTab.min then
                        timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
                    end
                    if timeTab.sec then
                        timestr = timestr .. string.format("%02d", timeTab.sec);
                    end
                else
                    if timeTab.day and timeTab.day ~= 0 then
                        timestr = timestr .. string.format("%d", timeTab.day) .. "Days";
                    end
                    if timeTab.hour then
                        timestr = timestr .. string.format("%d", timeTab.hour) .. "hr";
                    end
                end
                local activeCfg = Config.db_activity[self.data.sign]
                if activeCfg then
                    local reqs = String2Table(activeCfg.reqs)
                    if not table.isempty(reqs) then
                        local curPeriod
                        if type(reqs[2]) == "number" then
                            curPeriod = reqs[2]
                        else
                            curPeriod = reqs[1][2]
                        end
                        if enum.COMPETE_PERIOD.COMPETE_PERIOD_ENROLL == curPeriod then
                            --准备阶段
                            timestr = "Register" .. "\n" .. timestr
                        elseif enum.COMPETE_PERIOD.COMPETE_PERIOD_SELECT == curPeriod then
                            timestr = "Knockout" .. "\n" .. timestr
                        elseif enum.COMPETE_PERIOD.COMPETE_PERIOD_RANK == curPeriod then
                            timestr = "Brawl" .. "\n" .. timestr
                        end
                    end

                end
            else
                if timeTab.hour then
                    timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
                end
                if timeTab.min then
                    timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
                end
                if timeTab.sec then
                    timestr = timestr .. string.format("%02d", timeTab.sec);
                end
            end

            self.timeTex.text = timestr;
        end
    else
        if self.icon_data.is_auto or self.icon_data.is_countdown_hide then
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, self.data.key, false, id)
        else
            SetVisible(self.timer, false)
        end
        self:StopSchedule()
    end
end

function MainTopRightItem:StopSchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end

function MainTopRightItem:LoadImageTexture()
    if not self.is_loaded then
        self.is_need_loadimagetexture = true
        return
    end
    self.is_need_loadimagetexture = false

    --特殊处理
    --节日活动
    if self.data.key_str == self.festival_key then
        local id = self.data.cur_act_id
        local img_name = OperateModel.GetInstance():GetIconNameByKey(self.festival_key, id)
        local function callBack(sprite)
            self.icon_component.sprite = sprite
            self.icon_component:SetNativeSize()
        end
        --	lua_resMgr:SetImageTexture(self, self.icon_component, abName, assetName, true, callBack)
        lua_resMgr:SetImageTexture(self, self.icon_component, "main_image", img_name, true, callBack)
        return
    end

    --特殊处理
    --限时寻宝
    if self.data.key_str == self.timeLimitedTreasureHunt_key then
        local target_cfg
        --从已开启的活动中找到当期限时寻宝活动的id
        local key  = "191@1"
        for k,v in pairs(OperateModel:GetInstance().act_list) do
            local cfg = Config.db_yunying[v.id]
            if cfg and cfg.panel == key then
                target_cfg = cfg
                break
            end
        end
        --根据icon字段加载图标
        local img_name = target_cfg.icon
        local function callBack(sprite)
            self.icon_component.sprite = sprite
            self.icon_component:SetNativeSize()
        end
        lua_resMgr:SetImageTexture(self, self.icon_component, "main_image", img_name, true, callBack)
        return
    end

    local icon = self.data.res
    if not icon and self.config then
        icon = self.config.icon
    end
    if not icon then
        return
    end
    local res_tab = string.split(icon, ":")
    local abName = res_tab[1]
    local assetName = res_tab[2]
    if self.res_name == assetName then
        return
    end
    self.res_name = assetName
    local function callBack(sprite)
        self.icon_component.sprite = sprite
        self.icon_component:SetNativeSize()
    end
    lua_resMgr:SetImageTexture(self, self.icon_component, abName, assetName, false, callBack)
end

function MainTopRightItem:GetActionTimeRate(visible, switch_type)
    local pos
    local hide_pos = switch_type == MainModel.SwitchType.City and self.hide_pos or self.hide_pos2
    if visible then
        pos = self.start_pos
    else
        pos = hide_pos
    end
    local cur_pos_x, cur_pos_y = self:GetPosition()
    local cur_pos = { x = cur_pos_x, y = cur_pos_y }
    local dis1 = Vector2.Distance(hide_pos, self.start_pos)
    local dis2 = Vector2.Distance(pos, cur_pos)
    return dis2 / dis1
end

function MainTopRightItem:SetRowIdx(idx)
    self.row_idx = idx
end

function MainTopRightItem:SetStartPos(x, y)
    self.start_pos.x = x
    self.start_pos.y = y
end

function MainTopRightItem:SetHidePos(pos1, pos2)
    self.hide_pos.x = pos1.x
    self.hide_pos.y = pos1.y

    self.hide_pos2.x = pos2.x
    self.hide_pos2.y = pos2.y
end

function MainTopRightItem:SetEvadeX(x, y)
    self.evade_pos.x = x or self.start_pos.x
    self.evade_pos.y = y
end

function MainTopRightItem:SetLineIndex(line, line_index, index, isShow)
    self.line = line
    self.line_index = line_index
    self.index = index
    self.isShow = isShow
end

function MainTopRightItem:SetIsCanShow(flag)
    self.is_can_show = flag
end

function MainTopRightItem:SetTimeColor(color)
    self.timeTex.color = color
end

function MainTopRightItem:UpdatePos(switch_state)
    if self.row_idx ~= 3 then
        return
    end
    local mainpanel = lua_panelMgr:GetPanelOrCreate(MainUIView)
    local state = mainpanel.main_top_right.switch_state
    local is_can_set = false
    --在展开状态的时候
    if state then
        is_can_set = true
    elseif self.isShow then
        --只有正在显示的可以设置位置
        is_can_set = true
    end

    if not is_can_set then
        return
    end
    switch_state = switch_state or MainModel.GetSwitchType()
    if self.igonre_thrid_idx_move and self.model.is_showing_model_predi then
        self.igonre_thrid_idx_move = false
        self:StopAction()
        self:SetPosition(self.evade_pos.x, self.evade_pos.y)
    else
        self:StartAction(0.1, true, switch_state)
    end
end

function MainTopRightItem:GetCurPosition()
    local x, y, z = GetLocalPosition(self.icon.transform)
    local v3 = Vector3(x, y, z)
    local result = self.icon.transform:TransformPoint(v3)
    return result.x, result.y, result.z
end

function MainTopRightItem:InitSubPanel()
    --self.config.sub_tab
    self.isShowSub = not self.isShowSub
    if  not self.main_top_right_sub  then
        self.main_top_right_sub = MainTopRightSub(self.transform)
    end
    self.main_top_right_sub:SetVisible(self.isShowSub)
    if self.isShowSub then
        self.main_top_right_sub:SetData(self.config,self.line_index)
    end

end

