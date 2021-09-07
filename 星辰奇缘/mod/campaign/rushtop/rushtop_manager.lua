RushTopManager = RushTopManager or BaseClass(BaseManager)

function RushTopManager:__init()
    if RushTopManager.Instance then
        return
    end
    RushTopManager.Instance = self

    self.model = RushTopModel.New()


    self.on20421 = EventLib.New()
    self.on20422 = EventLib.New()
    self.on20425 = EventLib.New()
    self.on20427 = EventLib.New()
    self.on20428 = EventLib.New()
    self.on20429 = EventLib.New()
    self.on20431 = EventLib.New()
    self.on20432 = EventLib.New()
    self.on20433 = EventLib.New()


    self.timerList = {}
    self:InitHandler()


end

function RushTopManager:__delete()
end

function RushTopManager:InitHandler()
    self:AddNetHandler(20421, self.On20421)
    self:AddNetHandler(20422, self.On20422)
    self:AddNetHandler(20423, self.On20423)
    self:AddNetHandler(20424, self.On20424)
    self:AddNetHandler(20425, self.On20425)
    self:AddNetHandler(20426, self.On20426)
    self:AddNetHandler(20427, self.On20427)
    self:AddNetHandler(20428, self.On20428)
    self:AddNetHandler(20429, self.On20429)
    self:AddNetHandler(20430, self.On20430)
    self:AddNetHandler(20431, self.On20431)
    self:AddNetHandler(20432, self.On20432)
    self:AddNetHandler(20433, self.On20433)
    EventMgr.Instance:AddListener(event_name.role_event_change, function() self:OnEventChange() end)
end

function RushTopManager:RequestInitData()
    self:Send20421()
    self:Send20429(true)
    self:Send20433()
    LuaTimer.Add(300, function()
        EventMgr.Instance:AddListener(event_name.role_event_change, function() self:MainUIIcon() end)
    end)
    EventMgr.Instance:AddListener(event_name.role_event_change, function()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTop or RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTopPlay then
            self:Send20433()
            self.model:OpenMainPanel()
        else
            self.model:CloseMainPanel()
        end
    end)
    EventMgr.Instance:AddListener(event_name.scene_load, function()
        if SceneManager.Instance:CurrentMapId() == 53013  then
            self:Send20433()
        end
    end)
end

function RushTopManager:Send20421()
    Connection.Instance:send(20421, {})
end

function RushTopManager:On20421(data)
    self.model.rules = data
    -- BaseUtils.dump(self.model.rules,"On20421")
    self.on20421:Fire()
end

function RushTopManager:Send20422()
    Connection.Instance:send(20422, {})
end

function RushTopManager:On20422(data)
    -- BaseUtils.dump(data, "当前活动状态")
    if self.model.rules == nil then
        self:Send20421()
    end
    self.model.status = data.state_code
    self.model.nexttime = data.timeout
    self:SetIcon(data)
    if data.state_code ~= RushTopEnum.State.Idle then

        self:Send20429()
    else
        self.model.curquestion = nil
        self.model.curanswer = nil
        self.model.playerInfo = nil
        self.model.myanswer = {}
        self.model.rightanswer = {}
        self.model.answershow = {}
        self.model.leftplayer = 0
        self.model.lost = false
    end
    -- if data.state_code == RushTopEnum.State.Answer and (RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTop or RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTopPlay) then
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main, {frist = true})
    -- end

    self:RushTopNotice()
    self.on20422:Fire()
end


function RushTopManager:Send20423()
    Connection.Instance:send(20423, {})
end

function RushTopManager:On20423(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        -- self.model.playerInfo.sign = 1
        -- if self.model.signUpWin ~= nil then
        --     self.model.signUpWin:SetStatus()
        -- end
        if self.model.status == RushTopEnum.State.Ready then
            self:Send20424(1)
        end
    end
end


function RushTopManager:Send20424(type)
    Connection.Instance:send(20424, {type = type})
end

function RushTopManager:On20424(data)
    BaseUtils.dump(data, "进出场景")
    if data.result == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
    if data.type == 2 and data.result == 1 then
        MainUIManager.Instance.MainUIIconView:showbaseicon3()
        MainUIManager.Instance.MainUIIconView:showbaseicon5()
        -------------------------------------------------------------------------tohuashi
        -- WindowManager.Instance:CloseWindowById(WindowConfig.WinID.rushtop_main)
    elseif data.type == 1 and data.result == 1 then

        local icon = MainUIManager.Instance.MainUIIconView:getbuttonbyid(379)
        if icon ~= nil then
            icon.gameObject:SetActive(true)
            icon.gameObject:GetComponent(RectTransform).localPosition = Vector2(-755, -70)
        end
        MainUIManager.Instance.MainUIIconView:hidebaseicon3()
        MainUIManager.Instance.MainUIIconView:hidebaseicon5()

        if self.model.status > RushTopEnum.State.Ready then
            if self.model.playerInfo.sign == 0 then
                --未报名
                self.watch = true
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main, {watch = 1})
            elseif self.model.playerInfo.is_lost == 0 then
                --未答错
                return
            elseif self.model.curquestion ~= nil and self.model.playerInfo.index == self.model.curquestion.question_index then
                -- 答错可复活
                return
            else
                -- 淘汰
                self.watch = true
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main, {watch = 2})
            end
        end
    end
end

function RushTopManager:Send20425()
    Connection.Instance:send(20425, {})
end

function RushTopManager:On20425(data)
    BaseUtils.dump(data, "冲顶答题题目")
    BaseUtils.dump(BaseUtils.BASE_TIME,"当前时间")
    self.model.curquestion = data
    if self.watch ~= true then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main)
    end
    self.on20425:Fire()
end

function RushTopManager:Send20426(index,option)
    Connection.Instance:send(20426, {index = index,option = option})
    self.model.myanswer[index] = option
end

function RushTopManager:On20426(data)
    BaseUtils.dump(data,"答题返回")
    if data.result == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已作答，请等候答案揭晓{face_1,3}"))
    end
end

function RushTopManager:Send20427()
    Connection.Instance:send(20427, {})
end

function RushTopManager:On20427(data)
    BaseUtils.dump(data, "冲顶答题统计")
    self.model.curanswer = data
    if self.watch ~= true then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main)
    end
    if data.answer == 1 then
        self.model.leftplayer = data.option_a
    elseif data.answer == 2 then
        self.model.leftplayer = data.option_b
    elseif data.answer == 3 then
        self.model.leftplayer = data.option_c
    end
    self.on20427:Fire()
end

function RushTopManager:Send20428()
    Connection.Instance:send(20428, {})
end

function RushTopManager:On20428(data)
    BaseUtils.dump(data, "冲顶答题复活")
    if data.result == 1 then
        self.model.playerInfo.is_lost = 0
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.on20428:Fire()
end

function RushTopManager:Send20429(isNext)
    self.isNext = isNext or false
    Connection.Instance:send(20429, {})
end

function RushTopManager:On20429(data)
    self.model.playerInfo = data
    BaseUtils.dump(data)
    if data.in_map == 1 then
        -- LuaTimer.Add(0, function() self:Send20433() end)
        LuaTimer.Add(1000, function()
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTop or RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTopPlay then
                    self.inRushTop = true
                    MainUIManager.Instance.MainUIIconView:hidebaseicon3()
                    MainUIManager.Instance.MainUIIconView:hidebaseicon5()
                    local icon = MainUIManager.Instance.MainUIIconView:getbuttonbyid(379)
                    if icon ~= nil then
                        icon.gameObject:SetActive(true)
                        icon.gameObject:GetComponent(RectTransform).localPosition = Vector2(-755, -70)
                    end
            end
        end)
    end
    self.on20429:Fire()
    if self.isNext == true then
        self:Send20422()
        self.isNext = false
    end
end

function RushTopManager:Send20430(msg)
    Connection.Instance:send(20430, {msg = msg})
    if self.model.playerInfo.ply_barrage == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前弹幕已关闭，开启后可查看弹幕{face_1,9}"))
    end
end

function RushTopManager:On20430(data)
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTop or
        RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTopPlay then
        if data.flag == 1 then
            NoticeManager.Instance:On9902({type = MsgEumn.NoticeType.NormalDanmaku, msg = data.msg})
        end
    end
end

function RushTopManager:Send20431(type,value)
    Connection.Instance:send(20431, {type = type,value = value})
end

function RushTopManager:On20431(data)
    -- BaseUtils.dump(data,"on20431")
     if data.flag == 1 then
        if data.type == RushTopEnum.DamakuType.System then
            self.model.playerInfo.sys_barrage = data.value
        else
            self.model.playerInfo.ply_barrage = data.value
            if data.value == 1 then
                NoticeManager.Instance:FloatTipsByString(TI18N("已开启弹幕，快分享正确答案吧{face_1,15}"))
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("已关闭玩家弹幕（当前弹幕消失后生效）{face_1,2}"))
            end
        end
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
    self.on20431:Fire()




end

function RushTopManager:Send20432()
    Connection.Instance:send(20432, {})
end

function RushTopManager:On20432(data)
    -- BaseUtils.dump(data,"个人答题情况")
    self.model.rightanswer[data.index] = data.answer
    if self.watch ~= true then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main)
    end
    if data.answer == data.option then
        self.on20432:Fire(true)
    else
        self.on20432:Fire(false)
    end
end

function RushTopManager:Send20433()
    Connection.Instance:send(20433, {})
end

function RushTopManager:On20433(data)
    -- BaseUtils.dump(data,"重连请求")

    self.model.curquestion = data
    self.model.leftplayer = data.role_num
    self.on20433:Fire()

    if data.question_index == 0 and self.model.status == RushTopEnum.State.Answer and SceneManager.Instance:CurrentMapId() == 53013                    then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main, {frist = true})
    end
    -- if self.model.playerInfo.sign == 0 then
    --     --未报名
    --     self.watch = true
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main, {watch = 1})
    -- elseif self.model.playerInfo.is_lost == 0 then
    --     --未答错
    --     return
    -- elseif self.model.playerInfo.index == self.model.curquestion.question_index then
    --     -- 答错可复活
    --     return
    -- else
    --     -- 淘汰
    --     self.watch = true
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_main, {watch = 2})
    -- end
end


function RushTopManager:SetIcon(data)
    MainUIManager.Instance:DelAtiveIcon(379)
    if data.state_code ~= RushTopEnum.State.Idle and data.state_code ~= 0 then
        MainUIManager.Instance:DelAtiveIcon(379)
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[379]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        if data.state_code == RushTopEnum.State.Signup then
            self.activeIconData.timestamp = data.timeout - BaseUtils.BASE_TIME + Time.time
            self.activeIconData.clickCallBack = function()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_signup_window, {data.timeout})
            end
        elseif data.state_code == RushTopEnum.State.Ready then
            self.activeIconData.text = TI18N("<color='#ffff00'>报名入场</color>")
            self.activeIconData.clickCallBack = function()
                if self.model.playerInfo == nil or self.model.playerInfo.sign == 0 then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_signup_window, {data.timeout})
                else
                    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTop and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTopPlay  then
                        self:Send20424(1)
                    else
                        NoticeManager.Instance:FloatTipsByString(TI18N("正在参与活动喔{face_1,9}"))
                    end
                end
            end
        else
            self.activeIconData.text = TI18N("<color='#ffff00'>火热进行</color>")
            self.activeIconData.clickCallBack = function()
                if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTop and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTopPlay  then
                    self:Send20424(1)
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("正在参与活动喔{face_1,9}"))
                end
            end
        end
        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    end
end


function RushTopManager:MainUIIcon()

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTop or RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTopPlay then
        self.inRushTop = true
        MainUIManager.Instance.MainUIIconView:hidebaseicon3()
        MainUIManager.Instance.MainUIIconView:hidebaseicon5()
        local icon = MainUIManager.Instance.MainUIIconView:getbuttonbyid(379)
        if icon ~= nil then
            icon.gameObject:SetActive(true)
            icon.gameObject:GetComponent(RectTransform).localPosition = Vector2(-755, -70)
        end


    elseif self.inRushTop == true then
        self.inRushTop = false
        MainUIManager.Instance.MainUIIconView:showbaseicon3()
        MainUIManager.Instance.MainUIIconView:showbaseicon5()

    end

end

function RushTopManager:RushTopNotice()
    -- print("当前是什么阶段:" .. self.model.status)
    local index = nil
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTop or RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTopPlay or RoleManager.Instance.RoleData.lev < 40 then
        return
    end

    if (self.model.status == RushTopEnum.State.Signup and self.model.playerInfo ~= nil and self.model.playerInfo.sign == 0) or (self.model.status == RushTopEnum.State.Ready and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTop and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTopPlay) or (self.model.status == RushTopEnum.State.Answer and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTop and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTopPlay) then
        if self.model.status == RushTopEnum.State.Signup and self.model.playerInfo.sign == 0 then
            index = 1
        elseif self.model.status == RushTopEnum.State.Ready and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTop and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.RushTopPlay then
            index = 2
        else
            index = 3
        end
        math.randomseed((RoleManager.Instance.RoleData.exp + 1) * (RoleManager.Instance.RoleData.id  + 1)* BaseUtils.BASE_TIME)
        local time = math.floor(math.random() * 10000)

        if self.timerList[index] ~= nil then
            LuaTimer.Delete(self.timerList[index])
            self.timerList[index] = nil
        end
        self.timerList[index] = LuaTimer.Add(time, function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_signup_window)
        end)

    end
end

function RushTopManager:OnEventChange()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTop and self.model.status ~= nil and self.model.status ~= RushTopEnum.State.Answer  then
        self.model:OpenDescPanel()
    end
end









