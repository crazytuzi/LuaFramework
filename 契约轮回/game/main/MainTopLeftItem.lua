-- @Author: lwj
-- @Date:   2019-12-15 16:43:47 
-- @Last Modified time: 2019-12-15 16:43:49

MainTopLeftItem = MainTopLeftItem or class("MainTopLeftItem", BaseCloneItem)

MainTopLeftItem.ActionTime = 0.3
MainTopLeftItem.special_count = 4

function MainTopLeftItem:ctor(obj, parent_node, layer)
    self.start_pos = { x = 0, y = 0 }
    self.model = MainModel:GetInstance()
    self.model_event_list = {}
    self.is_can_show = true
    self.row_idx = 1
    self.igonre_thrid_idx_move = true
    self.festival_key = "nation"

    MainTopLeftItem.super.Load(self)
end

function MainTopLeftItem:dctor()
    self:StopAction()
    self:StopBirthAction()
    self:RemoveEffect()
    self:StopSchedule()
end

function MainTopLeftItem:RemoveEffect()
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

function MainTopLeftItem:LoadCallBack()
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

end

function MainTopLeftItem:AddEvent()
    local level = 1
    local function call_back(target, x, y)
        if not self.config then
            return
        end


        if self.data.key_str == "race" then
            RaceModel.GetInstance().is_active_open = not(self.isReady or self.data.is_show_end)
        end

        if self.effect then
            self.effect:destroy()
            self.effect = nil
        end
        MainIconOpenLink(self.config.id, self.config.sub_id, self.data.sign)
    end
    AddButtonEvent(self.icon.gameObject, call_back)

    local function call_back(key_str, param, sign)
        if self.data.key_str == key_str and (not self.data.sign or self.data.sign == sign) then
            self:UpdateRedDot()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.UpdateRedDot, call_back)
end

function MainTopLeftItem:BirthAction()
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

function MainTopLeftItem:StopBirthAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.con)
end

function MainTopLeftItem:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end

function MainTopLeftItem:SetData(data)
    self.data = data
    self.config = data.cf

    self.transform.name = self.data.key_str
    self:UpdateInfo()
    self:SetEffect()
end
function MainTopLeftItem:SetEffect()
    if self.config.is_eff then
        self.effect = UIEffect(self.con, 10201, false)
		local c = {}
		c.scale = 0.8
		self.effect:SetConfig(c)
        --self.effect:SetOrderIndex(99)
    end
end

-- 更新数据 倒计时、图标、红点 都用同一个接口
function MainTopLeftItem:UpdateInfo()
    if self.data.key == "escort" then
        -- Yzprint('--LaoY ======>', data)
    end
    --是否忽略倒计时处理
    self.icon_data = GetTopLeftConfigByKey(self.data.key)
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

function MainTopLeftItem:UpdateRedDot()
    local param = self.model:GetRedDotParam(self.data.key_str, self.data.sign)
    self.red_dot:SetRedDotParam(param)
end

function MainTopLeftItem:ShowCountDown()
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

function MainTopLeftItem:StartCountDown()
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
                    self.timeTex.text = string.format("<color=#1AFF18>%s</color>",timestr);
                end
            else

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
                        timestr = timestr .. string.format("%d", timeTab.day) .. "天";
                    end
                    if timeTab.hour then
                        timestr = timestr .. string.format("%d", timeTab.hour) .. "时";
                    end
                end
                
                self.timeTex.text = timestr;
            end


        end
    else
        if self.icon_data.is_auto then
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, self.data.key, false, id)
        else
            SetVisible(self.timer, false)
        end
        self:StopSchedule()
    end
end

function MainTopLeftItem:StopSchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
        self.schedule = nil
    end
end

function MainTopLeftItem:LoadImageTexture()
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
        lua_resMgr:SetImageTexture(self, self.icon_component, "main_image", img_name, true, nil, callBack)
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

function MainTopLeftItem:SetRowIdx(idx)
    self.row_idx = idx
end

function MainTopLeftItem:SetStartPos(x, y)
    self.start_pos.x = x
    self.start_pos.y = y
    SetLocalPosition(self.transform, x, y)
end

function MainTopLeftItem:SetLineIndex(line, line_index, index, isShow)
    self.line = line
    self.line_index = line_index
    self.index = index
    self.isShow = isShow
end

function MainTopLeftItem:SetIsCanShow(flag)
    self.is_can_show = flag
end

function MainTopLeftItem:SetTimeColor(color)
    self.timeTex.color = color
end

function MainTopLeftItem:GetCurPosition()
    local x, y, z = GetLocalPosition(self.icon.transform)
    local v3 = Vector3(x, y, z)
    local result = self.icon.transform:TransformPoint(v3)
    return result.x, result.y, result.z
end