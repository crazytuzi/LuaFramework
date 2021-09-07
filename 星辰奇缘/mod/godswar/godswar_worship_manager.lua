GodsWarWorShipManager = GodsWarWorShipManager or BaseClass(BaseManager)

function GodsWarWorShipManager:__init()
    if GodsWarWorShipManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    GodsWarWorShipManager.Instance = self

    self.model = GodsWarWorShipModel.New()
    self:InitHandler()

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:UpdateEvent(event, old_event) end)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:SceneLoad() end)


    self.GodsWarDamakuSystemValue = 1
    self.GodsWarDamakuPlayerValue = 1
    self.isCanGodWarWorship = false
    self.beginPlot = false
    self.IsUpdateEvent = false
    self.godsWarMsgList = {}
    self.OnUpdateGodsWarWorShipData = EventLib.New()
    self.OnUpdateGodsWarWorShipDanMu = EventLib.New()
    self.OnUpdateGodsWarWorShipMsg = EventLib.New()
    self.OnUpdateGodsWarWorShipButton = EventLib.New()
    self.OnUpdateGodsWarWorShipTime = EventLib.New()
    self.OnUpdateGodsWarChallengeTime = EventLib.New()
    self.OnUpdateGodsWarWorShipStatus = EventLib.New()
    self.OnUpdateGodsWarWorShipVedioTime = EventLib.New()
    self.OnUpdateGodsWarChallengeStatus = EventLib.New()
    self.OnUpdateGodsWarChallengeBossStatus = EventLib.New()
    self.OnUpdateGodsWarChallengeReadyOrNotStatus = EventLib.New()
    self.OnChallengeSibiTimer = EventLib.New()
    self.OnUpdateGodsWartrace = EventLib.New()
    self.IsOpenIcon = false

    self.godsChallengeStatus = 0
    self.currStatusEndTime = 0

    self.HasAudienceReward = 0
    self.IsReadyChallenge = false  --是否王者组已准备
    self.BossStatus = 0

end

function GodsWarWorShipManager:__delete()
    self.model:DeleteMe()
end

function GodsWarWorShipManager:InitHandler()
    self:AddNetHandler(17938, self.On17938)
    self:AddNetHandler(17939, self.On17939)
    self:AddNetHandler(17940, self.On17940)
    self:AddNetHandler(17941, self.On17941)
    self:AddNetHandler(17942, self.On17942)
    self:AddNetHandler(17943, self.On17943)
    self:AddNetHandler(17944, self.On17944)
    self:AddNetHandler(17945, self.On17945)
    self:AddNetHandler(17946, self.On17946)
    self:AddNetHandler(17947, self.On17947)
    self:AddNetHandler(17948, self.On17948)
    self:AddNetHandler(17949, self.On17949)
    self:AddNetHandler(17950, self.On17950)
    self:AddNetHandler(17951, self.On17951)
    self:AddNetHandler(17952, self.On17952)
    self:AddNetHandler(17953, self.On17953)

    --诸神boss战
    self:AddNetHandler(17954, self.On17954)
    self:AddNetHandler(17955, self.On17955)
    self:AddNetHandler(17956, self.On17956)
    self:AddNetHandler(17957, self.On17957)
    self:AddNetHandler(17958, self.On17958)
    self:AddNetHandler(17965, self.On17965)
end

function GodsWarWorShipManager:RequestInitData()
    self.nextConection = true
    self:Send17938()
    self:Send17953()
    self:Send17956()  --诸神挑战阶段
end

function GodsWarWorShipManager:DeletePlot()
    if DramaManager.Instance ~= nil and DramaManager.Instance.model.normalActionModel ~= nil then
        DramaManager.Instance.model.normalActionModel:EndActions()
    end
end
function GodsWarWorShipManager:Send17938()
-- print("发送协议17938=============================================================")

    self:Send(17938,{})
end
function GodsWarWorShipManager:On17938(data)
    -- BaseUtils.dump(data,"接收协议17938============")
    self.godsWarStatus = data.status
    -- print("诸神殿堂当前阶段"..data.status)
    self.godsWarEndTime = data.end_time
    self:SetInfo()

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip then
            local mapId = SceneManager.Instance:CurrentMapId()
            if mapId == 53011 then
                if self.godsWarStatus == 1 then
                    SceneManager.Instance.sceneElementsModel:Show_Npc(false)
                elseif self.godsWarStatus == 3 or self.godsWarStatus == 2 then
                    if DramaManager.Instance.model.plotPlaying  ~= true then
                        SceneManager.Instance.sceneElementsModel:Show_Npc(true)
                    end
                end

                if self.godsWarStatus == 2 or self.godsWarStatus == 3 then
                    self.beginPlot = true
                    self:Send17948()
                end
            end
    end

    if self.IsUpdateEvent == true then
        self:ApplyEvent()
        self.IsUpdateEvent = false
    end

    self:OpenGodsWarWorShipIcon()
    self.OnUpdateGodsWarWorShipStatus:Fire()

    if self.isHasGorWarShip ~= nil and self.isHasGorWarShip == 1 and self.godsWarStatus == 3 then
        --诸神决赛周挑战完成之后请求撒宝箱倒计时
        self:Send17965()
    end
    self:Send17952()
end

function GodsWarWorShipManager:Send17939()
-- print("发送协议17939=============================================================")
    self:Send(17939,{})
end

function GodsWarWorShipManager:On17939(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GodsWarWorShipManager:Send17940()
-- print("发送协议17941=============================================================")
    self:Send(17940,{})
end

function GodsWarWorShipManager:On17940(data)
    -- BaseUtils.dump(data,"接收协议17941==================================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GodsWarWorShipManager:Send17941()
    -- print("发送协议17941=============================================================")
    self:Send(17941,{})
end

function GodsWarWorShipManager:On17941(data)
    -- BaseUtils.dump(data,"接收协议17941==================================================================")
    self.godsWarWorShipData = data.champion_teams
    table.sort(self.godsWarWorShipData,function(a,b)
               if a.serial_id ~= b.serial_id then
                    return a.serial_id < b.serial_id
                else
                    return false
                end
            end)
    self.nowChampionTeams = #data.champion_teams
    --BaseUtils.dump(self.godsWarWorShipData[self.nowChampionTeams],"&&&&&&&&&&&&&")
    if self.isEventChange == true and self.godsWarWorShipData ~= nil then
        self.isEventChange = false
        --WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {3, 1})
    end
    self.model:CheckMyselfChampaign()

    self.plotIsCompelete = true
    for i,v in ipairs(self.godsWarWorShipData[#data.champion_teams].members) do
        if #self.godsWarWorShipData[#data.champion_teams].members == 7 then
            v.baseid = self.model.plotInformation[i].baseid
            v.x = self.model.plotInformation[i].x
            v.y = self.model.plotInformation[i].y
            v.unit_id = self.model.plotInformation[i].unit_id
            v.battle_id = self.model.plotInformation[i].battle_id
        elseif #self.godsWarWorShipData[#data.champion_teams].members == 6 then
            v.baseid = self.model.plotInformation2[i].baseid
            v.x = self.model.plotInformation2[i].x
            v.y = self.model.plotInformation2[i].y
            v.unit_id = self.model.plotInformation2[i].unit_id
            v.battle_id = self.model.plotInformation2[i].battle_id
        elseif #self.godsWarWorShipData[#data.champion_teams].members == 5 then
            v.baseid = self.model.plotInformation3[i].baseid
            v.x = self.model.plotInformation3[i].x
            v.y = self.model.plotInformation3[i].y
            v.unit_id = self.model.plotInformation3[i].unit_id
            v.battle_id = self.model.plotInformation3[i].battle_id
        else
            self.plotIsCompelete = false
        end
    end

    -- BaseUtils.dump(self.model.plotInformation,"队伍数据============================dfsfjsdkljflksdjf")

    if self.beginPlot == true then
        self:Send17953()
    end

    for i,v in ipairs(self.godsWarWorShipData) do
        for i2,v2 in ipairs(v.members) do
            math.randomseed(RoleManager.Instance.RoleData.id)
            local randomIndex = math.random(1,10)

            v2.randomIndex = randomIndex
        end

        table.sort(v.members,function(a,b)
               if a.randomIndex ~= b.randomIndex then
                    return a.randomIndex < b.randomIndex
                else
                    return false
                end
            end)

    end


    self.OnUpdateGodsWarWorShipData:Fire()
end

function GodsWarWorShipManager:Send17942(myTid,myPlatfrom,myZone_id)
    -- print("发送协议17942=============================================================")

    self:Send(17942,{tid = myTid,platfrom = myPlatfrom,zone_id = myZone_id})
end

function GodsWarWorShipManager:On17942(data)
        -- BaseUtils.dump(data,"接收协议17942==================================================================")

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GodsWarWorShipManager:Send17943(myType,myValue)
    -- print("发送协议17943=============================================================")

    self:Send(17943,{type = myType,value = myValue})
end

function GodsWarWorShipManager:On17943(data)
            -- BaseUtils.dump(data,"接收协议17943==================================================================")

    if data.flag == 1 then
        if data.type == 1 then
            self.GodsWarDamakuSystemValue = data.value
        elseif data.type == 2 then
            self.GodsWarDamakuPlayerValue = data.value
        end
    end
    self.OnUpdateGodsWarWorShipDanMu:Fire()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GodsWarWorShipManager:Send17944(msg)
    -- print("发送协议17944=============================================================:" .. msg)

    self:Send(17944,{msg = msg})
end

function GodsWarWorShipManager:On17944(data)
     -- BaseUtils.dump(data,"接收协议17944==================================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GodsWarWorShipManager:Send17945()
    -- print("发送协议17945=============================================================")

    self:Send(17945,{})
end

function GodsWarWorShipManager:On17945(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        self.godsWarMsgList = data.msg_list
        table.sort(self.godsWarMsgList,function(a,b)
               if a.msg_id ~= b.msg_id then
                    return a.msg_id < b.msg_id
                else
                    return false
                end
            end)
        self.OnUpdateGodsWarWorShipMsg:Fire()
    end
end

function GodsWarWorShipManager:Send17946()
-- BaseUtils.dump(data,"发送协议17946===================================================================")

    self:Send(17946,{})
end

function GodsWarWorShipManager:On17946(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.sabiData = data
    if data.err_code == 1 then
        self.sabiTime = data.start_time
        self.OnUpdateGodsWarWorShipTime:Fire()
    end
end

function GodsWarWorShipManager:Send17947()
    -- print("发送协议17947=============================================================")

    self:Send(17947,{})
end

function GodsWarWorShipManager:On17947(data)
     -- BaseUtils.dump(data,"接收协议17947==================================================================")
    self.isGodWarWorship = data.flag
    self.OnUpdateGodsWarWorShipButton:Fire()
end

function GodsWarWorShipManager:Send17948()
    -- print("发送协议17948=============================================================")

    self:Send(17948,{})
end

function GodsWarWorShipManager:On17948(data)
    self.plotData = data
    -- BaseUtils.dump(data,"17948======================================================")
    if data.flag == 0 and self.beginPlot == true then
        self:Send17941()
    end

    if self.IsOpenIcon == true then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip then
            if self.godsWarStatus == 3 or (self.godsWarStatus == 2 and data.flag == 1) or self.godsWarStatus == 5 or self.godsWarStatus == 6 or self.godsWarStatus == 7 or self.godsWarStatus == 8 then
                print(self.godsWarStatus.."self.godsWarStatus")
                self.model:OpenGodsWarWorShipIcon()
            else
                self.model:CloseGodsWarWorShipIcon()
            end
        end
        self.IsOpenIcon = false
    end

    -- print(self.model.isPalyGodsWarPlotEnd)
    if self.model.isPalyGodsWarPlotEnd == false and data.flag == 1 then
            LuaTimer.Add(90000, function()
                if self.model.isPalyGodsWarPlotEnd == false and data.flag == 1 then
                    self.model:ClearPlot()
                end
            end)
    end
end

function GodsWarWorShipManager:Send17949()
    -- print("发送协议17949=============================================================")

    self:Send(17949,{})
end

function GodsWarWorShipManager:On17949(data)

end

function GodsWarWorShipManager:Send17950()
    -- print("发送协议17950=============================================================")

    self:Send(17950,{})
end

function GodsWarWorShipManager:On17950(data)
    -- BaseUtils.dump(data,"接收协议17950==================================================================")



    self.godWarWorShipVedioList = data.video_list
    self.godWarWorShipFactVedioList = {}
    for i,v in ipairs(self.godWarWorShipVedioList) do
        for k2,v2 in pairs(v.gods_duel_video) do
            v2.niceType =  v.list_id
            table.insert(self.godWarWorShipFactVedioList,v2)
        end
    end
    self.OnUpdateGodsWarWorShipVedioTime:Fire()

end

function GodsWarWorShipManager:Send17951()
    -- print("发送协议17951=============================================================")

    self:Send(17951,{})
end

function GodsWarWorShipManager:On17951(data)
    -- BaseUtils.dump(data,"接收协议17951==================================================================")
    self.godWarWorShipVedioNiceList = data.gods_duel_champion_videos
    self.OnUpdateGodsWarWorShipVedioTime:Fire()
end

function GodsWarWorShipManager:Send17952()
    -- print("发送协议17950=============================================================")

    self:Send(17952,{})
end

function GodsWarWorShipManager:On17952(data)
    -- BaseUtils.dump(data,"接收协议17952==================================================================")

    self.godsWarWorshipAllTime = data.end_time
    self:SetIcon()
end

function GodsWarWorShipManager:Send17953()
    --print("发送协议17953=============================================================")

    self:Send(17953,{})
end

function GodsWarWorShipManager:On17953(data)
    -- BaseUtils.dump(data,"接收协议17953==========是否有（膜拜）仪式")
    --self.isHasGorWarShip  是否有（膜拜）仪式
    self.isHasGorWarShip = data.flag

    if self.beginPlot == true and self.plotData ~= nil and self.plotData.flag == 0 and self.godsWarStatus ~= nil and (self.godsWarStatus == 2 or (self.godsWarStatus == 3 and self.isHasGorWarShip == 1)) and RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip  then
        local nowTime = BaseUtils.BASE_TIME
        self.model:BeginGodsWarWorShipPlot()
        self.beginPlot = false
    end
    self.OnUpdateGodsWartrace:Fire()
end




function GodsWarWorShipManager:GodsWarWorShipEnter()
        self:Send17939()
end


function GodsWarWorShipManager:UpdateEvent(event, old_event)
    self.nowEvent = event
    -- print("当前状态==============================================================================================：" .. self.nowEvent)
    self.nowOldEvent = old_event
    if self.godsWarStatus ~= nil then
        self:ApplyEvent()
    else
        self:Send17938()
        self.IsUpdateEvent = true
    end


end

function GodsWarWorShipManager:ApplyEvent()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip then
        self.isEventChange = true
        self:Send17941()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, true)
        end
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip then

    elseif self.nowOldEvent == RoleEumn.Event.GodsWarWorShip then
        self.model:CloseGodsWarWorShipIcon()

        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, false)
        end
    end
end

function GodsWarWorShipManager:OpenGodsWarWorShipIcon()
    if self.IsOpenIcon == false then
        self.IsOpenIcon = true
        self:Send17948()
    end

end




function GodsWarWorShipManager:Exit()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    local name = nil
    if self.godsWarStatus == 2 then
        name = TI18N("诸神冠军仪式")
    elseif self.godsWarStatus == 3 then
        name = TI18N("诸神膜拜")
    elseif self.godsWarStatus == 7 then
        name = TI18N("诸神BOSS")
    end
    confirmData.content = "你是否要退出<color='#ffff00'>诸神殿堂</color>"
    confirmData.sureLabel = TI18N("确认")
    confirmData.cancelLabel = TI18N("取消")
    -- confirmData.cancelSecond = 30
    confirmData.sureCallback = function()
            self:Send17940()
        end

    NoticeManager.Instance:ConfirmTips(confirmData)
end

function GodsWarWorShipManager:SendDanmaku(msg)
    self:Send17944(msg)
end

function GodsWarWorShipManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon(378)
    if (self.godsWarStatus ~= 4 and self.godsWarStatus ~= 0) and RoleManager.Instance.RoleData.lev >= 50 then


        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[378]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        --暂时去掉准备阶段的操作
        if self.godsWarStatus == 1 then
            self.activeIconData.timestamp = nil
            self.activeIconData.text = "准备中"
        elseif self.godsWarStatus == 2 or self.godsWarStatus == 3  or self.godsWarStatus == 5 then
            if self.isHasGorWarShip == 1 then
                self.activeIconData.timestamp = nil
                self.activeIconData.text = "颁奖中"
            elseif self.isHasGorWarShip == 0 then
                --非决赛周
                self.activeIconData.timestamp = self.godsWarWorshipAllTime - BaseUtils.BASE_TIME + Time.time
            end

            --self.activeIconData.timestamp = self.godsWarWorshipAllTime - BaseUtils.BASE_TIME + Time.time
        elseif self.godsWarStatus == 6 then
            self.activeIconData.timestamp = nil
            self.activeIconData.text = "备战中"
        elseif self.godsWarStatus == 8 or self.godsWarStatus == 7 then
            self.activeIconData.timestamp = nil
            self.activeIconData.text = "挑战中"
        end

        self.activeIconData.clickCallBack = function()

            if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GodsWarWorShip then
                GodsWarWorShipManager.Instance:GodsWarWorShipEnter()
            end
            if self.isHasGorWarShip == 1 and self.godsWarStatus ~= 0 then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {7, 1, isChoose = true})
            else
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {3, 1})
            end
        end

        MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
    end
end

function GodsWarWorShipManager:SceneLoad()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip then
        local mapId = SceneManager.Instance:CurrentMapId()
        if mapId == 53011 then
            self:Send17938()
            if t ~= nil then
                t:Set_ShowTop(false, {17, 107})
            end
        end
    end
end

function GodsWarWorShipManager:SetInfo()
    if ((self.godsWarStatus == 3 and self.BossStatus == 0) or self.godsWarStatus == 1 or self.godsWarStatus == 2 or self.godsWarStatus == 7 ) and RoleManager.Instance.RoleData.lev >= 80 then
        local titleName = TI18N("封神殿堂活动已开启，是否前往参加？")
        if self.godsWarStatus == 7 then
            titleName = TI18N("诸神挑战活动已开启，是否前往观战？")
        end
        local mapId = SceneManager.Instance:CurrentMapId()
        if mapId ~= 53011 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = titleName
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            -- 打开商店第三个标签的第二个Panel
            data.sureCallback = function ()

                self:GodsWarWorShipEnter()

            end
            NoticeManager.Instance:ConfirmTips(data)
        end
    end
end

--诸神挑战倒计时时间戳
function GodsWarWorShipManager:Send17954()
    --print("发送协议17954")
    self:Send(17954,{})
end
function GodsWarWorShipManager:On17954(data)
    --BaseUtils.dump(data,"接收协议17954")
    if data ~= nil then
        self.bossTime = data.first_time
        self.DelaybossTime = data.manual_time
    end
    self.OnUpdateGodsWarChallengeTime:Fire()
end
--准备状态
function GodsWarWorShipManager:Send17955()
    --print("发送协议17955")
    self:Send(17955,{})
end
function GodsWarWorShipManager:On17955(data)
    --BaseUtils.dump(data,"接收协议17955")
    self.OnUpdateGodsWarChallengeReadyOrNotStatus:Fire(data.err_code)
end

--诸神挑战阶段
function GodsWarWorShipManager:Send17956()
    --print("发送协议17956")
    self:Send(17956,{})
end
function GodsWarWorShipManager:On17956(data)
    -- BaseUtils.dump(data,"接收协议17956")
    self.BossStatus = data.status
    self.OnUpdateGodsWarChallengeStatus:Fire()
end
--诸神页签数据
function GodsWarWorShipManager:Send17957()
    --print("发送协议17957")
    local seasonId = GodsWarManager.Instance.season
    self:Send(17957,{season_id = seasonId})
end
function GodsWarWorShipManager:On17957(data)
    --BaseUtils.dump(data,"接收协议17957")
    if data ~= nil then
        self.BossCombatId = data.id
        self.OnUpdateGodsWarChallengeBossStatus:Fire(data)
    end
end
--诸神boss结算面板
function GodsWarWorShipManager:Send17958()
end

function GodsWarWorShipManager:On17958(data)
    --BaseUtils.dump(data,"接收协议17958")
    --self.model:OpenSettlePanel({Querdata})
    if data ~= nil then
        local result = data.result
        self.model:OpenSettlePanel({data})
    end
end

--诸神挑战后续撒宝箱倒计时
function GodsWarWorShipManager:Send17965()
    --print("发送协议17965")
    self:Send(17965,{})
end

function GodsWarWorShipManager:On17965(data)
    --BaseUtils.dump(data,"接收协议17965")
    if data ~= nil and data.err_code == 1 then
        self.ChallengeSabiTime = data.start_time
        self.OnChallengeSibiTimer:Fire()
    end
end




