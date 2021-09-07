MainuiTraceGodsWarWorShip = MainuiTraceGodsWarWorShip or BaseClass(BaseTracePanel)

function MainuiTraceGodsWarWorShip:__init(main)
    self.main = main

    self.resList = {
        {file = AssetConfig.godswarworshipcontent, type = AssetType.Main},
        {file = AssetConfig.combat_texture, type = AssetType.Dep},
        {file = AssetConfig.combat2_texture, type = AssetType.Dep},
        {file = AssetConfig.godswarworshiptexture, type = AssetType.Dep},
    }

    self.isOnToggle = false

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.stepList = {}
    self.isChallenge = GodsWarWorShipManager.Instance.isHasGorWarShip
    self.updateTime = function()
        local Challenge = GodsWarWorShipManager.Instance.isHasGorWarShip
        if Challenge == 1 then
            self:UpdateChallengeStatus()
        else
            self:UpdateTimer()
        end
    end
    self._updateTime = function() self:UpdateTimer() end
    self._OnUpdateGodsWartrace = function() self:SetData() end   --是否有膜拜  之后的监听事件
    self.ReadyorNot = function(index) self:OnRedayReturn(index) end
    self.ChallengeTime = function() self:UpdateChallengeTimer() end
    self._challengeStatus = function()
        local Challenge = GodsWarWorShipManager.Instance.isHasGorWarShip
        if Challenge == 1 then
            self:UpdateChallengeStatus()
        end
    end
    self._ChallengeSibiTimer = function() self:ChallengeSibiTimer() end

    self.NoticeTextList = {
        {TI18N("活动进入颁奖阶段，玩家可膜拜冠军队伍")}
        ,{TI18N("活动进入备战阶段，诸神王者组冠军成员备战<color='#ffff00'>诸神挑战</color>")}
        ,{TI18N("王者级冠军队员对诸神发起挑战，其他玩家观看挑战，观战过程中可获得宝箱奖励")}
        ,{TI18N("挑战者挑战成功后，全服玩家可获得来自诸神的礼物")}
        ,{TI18N("队伍成员归队，<color='#ffff00'>准备就绪</color>后等待活动开始进入战斗")}
    }

    self.statusList = {TI18N("挑战正在发起"),TI18N("挑战成功"), TI18N("挑战失败"),TI18N("挑战发起失败")}
end

function MainuiTraceGodsWarWorShip:__delete()
    self.OnHideEvent:Fire()

    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
        self.timerId3 = nil
    end
    self.main = nil
end

function MainuiTraceGodsWarWorShip:RemoveListeners()
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipTime:RemoveListener(self._updateTime)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipStatus:RemoveListener(self.updateTime)
    GodsWarWorShipManager.Instance.OnUpdateGodsWartrace:RemoveListener(self._OnUpdateGodsWartrace)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeReadyOrNotStatus:RemoveListener(self.ReadyorNot)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeTime:RemoveListener(self.ChallengeTime)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeStatus:RemoveListener(self._challengeStatus)

    GodsWarWorShipManager.Instance.OnChallengeSibiTimer:RemoveListener(self._ChallengeSibiTimer)

end

function MainuiTraceGodsWarWorShip:AddListeners()
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipTime:AddListener(self._updateTime)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipStatus:AddListener(self.updateTime)

    GodsWarWorShipManager.Instance.OnUpdateGodsWartrace:AddListener(self._OnUpdateGodsWartrace)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeReadyOrNotStatus:AddListener(self.ReadyorNot)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeTime:AddListener(self.ChallengeTime)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarChallengeStatus:AddListener(self._challengeStatus)

    GodsWarWorShipManager.Instance.OnChallengeSibiTimer:AddListener(self._ChallengeSibiTimer)

end

function MainuiTraceGodsWarWorShip:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarworshipcontent))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -40, 0)

    self.panel = self.transform:Find("Panel")
    local panel = self.panel
    self.toggleBtn = panel:Find("Toggle"):GetComponent(Button)
    self.toggleTickObj = panel:Find("Toggle/Bg/Tick").gameObject
    self.damakuBtn = panel:Find("Damaku"):GetComponent(Button)
    self.nodamakuBtn = panel:Find("NoDamaku"):GetComponent(Button)

    self.timeText = panel:Find("ImgTitle/TxtDesc"):GetComponent(Text)

    self.button = self.transform:Find("Panel"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:WorShip() end)

    self.toggleTickObj:SetActive(false)
    self.toggleBtn.onClick:AddListener(function() self:OnToggle() end)
    self.nodamakuBtn.onClick:AddListener(function() self:ShowCloseDamaku() end)
    self.damakuBtn.onClick:AddListener(function() self:OpenDamaku() end)

    self.worShipButton = panel:Find("WorShip"):GetComponent(Button)
    self.worShipButton.onClick:AddListener(function() self:WorShip() end)

    self.exitButton = panel:Find("ExitButton"):GetComponent(Button)
    self.exitButton.onClick:AddListener(function() GodsWarWorShipManager.Instance:Exit() end)

    self.descExt = MsgItemExt.New(panel:Find("ImgScrollRect/TxtDesc"):GetComponent(Text), 199, 15, 20.52)
    self.descExt:SetData(TI18N(
        [[1、在封神殿堂内可<color='#ffff00'>膜拜</color>上赛季封神队伍
2、膜拜诸神冠军队可获得冠军给予的<color='#ffff00'>丰厚奖励</color>
3、每人可领取<color='#ffff00'>3次</color>上赛季封神队伍洒下的<color='#ffff00'>宝箱</color>
4、每<color='#ffff00'>5分钟</color>冠军会在场景内洒下宝箱]]
        ))

    self.panel2 = self.transform:Find("Panel2")
    local panel2 = self.panel2

    for i = 1,4 do
        if self.stepList[i] == nil then
            local data = {}
            data.rect = panel2:Find("ImgTitle"..i)
            data.btn = data.rect:GetComponent(Button)
            data.btn.onClick:AddListener(function()
                if i == 1 then
                    self:ClickFirstStep()
                elseif i == 4 then
                    self:ClickEndStep()
                else
                    NoticeManager.Instance:FloatTipsByString(self.NoticeTextList[i][1])
                end
            end)
            data.selected = data.rect:Find("bg")
            data.title = data.rect:Find("TxtDesc"):GetComponent(Text)
            data.content = data.rect:Find("TxtDesc2"):GetComponent(Text)
            data.icon = data.rect:Find("Icon")
            self.stepList[i] = data
        end
    end
    self.bottomCon = panel2:Find("ImgTitleBottom")
    self.bottomCon.gameObject:SetActive(true)
    self.challengeTimer = panel2:Find("ImgTitleBottom/TxtDesc"):GetComponent(Text)
    self.challengeStatus = panel2:Find("ImgTitleBottom/PerpareStatus"):GetComponent(Text)
    self.challengeStatus.text = TI18N("<color='ff0000'>(未准备)</color>")
    --准备相关的文本先屏蔽
    self.challengeStatus.gameObject:SetActive(false)
    self.worShipButton2 = panel2:Find("WorShip"):GetComponent(Button)
    self.worShipButton2.onClick:AddListener(function() self:WorShip() end)
    self.exitButton2 = panel2:Find("ExitButton"):GetComponent(Button)
    self.exitButton2.onClick:AddListener(function() GodsWarWorShipManager.Instance:Exit() end)

    self.bottomLine = panel2:Find("line4")
    self.bottomLine.gameObject:SetActive(true)
    self.panel2.gameObject:SetActive(false)

end

function MainuiTraceGodsWarWorShip:OnInitCompleted()
    self:OnOpen()
    if not self.isChallenge then
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false)
        self.isOnToggle = false
        self.toggleTickObj:SetActive(false)
    end
end

function MainuiTraceGodsWarWorShip:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    GodsWarWorShipManager.Instance:Send17954()
    GodsWarWorShipManager.Instance:Send17938()
    self:SetData()
end

function MainuiTraceGodsWarWorShip:SetData()
    local isChallenge = GodsWarWorShipManager.Instance.isHasGorWarShip
    if isChallenge == 1 then
        self:SetDanMuPos()
        self.panel2.gameObject:SetActive(true)
        self.panel.gameObject:SetActive(false)
        GodsWarWorShipManager.Instance:Send17957()  --请求诸神boss挑战阶段 （未开始 正在战斗 战斗失败等）
    elseif isChallenge == 0 then
        self.panel.gameObject:SetActive(true)
        self.panel2.gameObject:SetActive(false)
        self:UpdateTimer()
        GodsWarWorShipManager.Instance:Send17946()
    end
end

function MainuiTraceGodsWarWorShip:SetDanMuPos()
    self.damakuBtn.transform:SetParent(self.panel2)
    self.nodamakuBtn.transform:SetParent(self.panel2)
    local Danrect = self.damakuBtn.transform:GetComponent(RectTransform)
    Danrect.anchorMax = Vector2(0, 0)
    Danrect.anchorMin = Vector2(0, 0)
    local NoDanrect = self.damakuBtn.transform:GetComponent(RectTransform)
    NoDanrect.anchorMax = Vector2(0, 0)
    NoDanrect.anchorMin = Vector2(0, 0)

    self.damakuBtn.transform.anchoredPosition = Vector2(-84,35.1)
    self.nodamakuBtn.transform.anchoredPosition = Vector2(-28,35.1)
end

function MainuiTraceGodsWarWorShip:OnHide()
    self:RemoveListeners()

    -- if self.timerId ~= nil then
    --     LuaTimer.Delete(self.timerId)
    --     self.timerId = nil
    -- end
    -- if self.timerId2 ~= nil then
    --     LuaTimer.Delete(self.timerId2)
    --     self.timerId2 = nil
    -- end
    -- if self.timerId3 ~= nil then
    --     LuaTimer.Delete(self.timerId3)
    --     self.timerId3 = nil
    -- end
end
--计时器
 function MainuiTraceGodsWarWorShip:UpdateTimer()
    if GodsWarWorShipManager.Instance.godsWarStatus == nil then
        return
    end

     local baseTime = BaseUtils.BASE_TIME
     local endTime = nil
    if GodsWarWorShipManager.Instance.godsWarStatus == 1 or GodsWarWorShipManager.Instance.godsWarStatus == 2 then
        endTime = GodsWarWorShipManager.Instance.godsWarEndTime
        --print("233333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333")
    elseif GodsWarWorShipManager.Instance.godsWarStatus == 3 and GodsWarWorShipManager.Instance.sabiTime ~= nil then
        endTime = GodsWarWorShipManager.Instance.sabiTime
    elseif GodsWarWorShipManager.Instance.godsWarStatus == 4 then
        self.timeText.text = "活动<color='#ffff00'>已结束</color>,可自由退出"
    else
        return
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if GodsWarWorShipManager.Instance.godsWarStatus ~= 4 then
        self.timestamp = 0
        if endTime >= baseTime then
            self.timestamp = endTime - baseTime
        end
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(10, 1000, function() self:TimeLoop() end)
        end
    end
end


function MainuiTraceGodsWarWorShip:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp - (h * 3600)) / 60 )
        local ss = math.floor(self.timestamp - (h * 3600) - (mm * 60))
        if h >0 then
          self.timeText.text = h .. "时" .. mm .. "分" .. ss .. "秒"
        elseif mm > 0 then
          self.timeText.text = mm .. "分" .. ss .. "秒"
        else
          self.timeText.text = ss .. "秒"
        end
        if GodsWarWorShipManager.Instance.godsWarStatus == 1 then
            if GodsWarWorShipManager.Instance.isHasGorWarShip ~= nil and GodsWarWorShipManager.Instance.isHasGorWarShip == true then
                self.timeText.text = string.format("<color='#ffff00'>%s</color>后开始冠军仪式",self.timeText.text)
            else
                self.timeText.text = string.format("<color='#ffff00'>%s</color>后开始膜拜冠军",self.timeText.text)
            end
        elseif GodsWarWorShipManager.Instance.godsWarStatus == 2 then
            self.timeText.text = string.format("<color='#ffff00'>%s</color>后开始膜拜冠军",self.timeText.text)
        elseif GodsWarWorShipManager.Instance.godsWarStatus == 3 then
            self.timeText.text = string.format("<color='#ffff00'>%s</color>后撒币(<color='#ffff00'>%s</color>/%s)",self.timeText.text,GodsWarWorShipManager.Instance.sabiData.next_round,GodsWarWorShipManager.Instance.sabiData.all_round)
        end
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end


function MainuiTraceGodsWarWorShip:EndTime()
    if GodsWarWorShipManager.Instance.godsWarStatus == 3 and GodsWarWorShipManager.Instance.sabiData.next_round == 0 then
        self.timeText.text = "活动结束"
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end


function MainuiTraceGodsWarWorShip:OnToggle()
    self.isOnToggle = not self.isOnToggle
    self.toggleTickObj:SetActive(self.isOnToggle)
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.isOnToggle)
end

function MainuiTraceGodsWarWorShip:ShowCloseDamaku()
    GodsWarWorShipManager.Instance.model:OpenDamakuSetting()
end

function MainuiTraceGodsWarWorShip:OpenDamaku()
      self.damakuCallback = self.damakuCallback or function(msg)
        GodsWarWorShipManager.Instance:SendDanmaku(msg)
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip then
            ChatManager.Instance:Send(10400, {channel = MsgEumn.ChatChannel.Scene, msg = msg})
        end
      end
      DanmakuManager.Instance.model:OpenPanel({sendCall = self.damakuCallback})
    -- end
end

function MainuiTraceGodsWarWorShip:WorShip()
    local isHasNpc = false
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for k,v in pairs(units) do
        if v.baseid == 43088 then
           SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(v.uniqueid)
           isHasNpc = true
           break
        end
    end

    if isHasNpc == false then
        NoticeManager.Instance:FloatTipsByString("暂未可以膜拜")
    end

end

--阶段status变化
function MainuiTraceGodsWarWorShip:UpdateChallengeStatus()
    --有仪式
    if GodsWarWorShipManager.Instance.godsWarStatus == nil then
        return
    end
    local status = GodsWarWorShipManager.Instance.godsWarStatus
    print("诸神殿堂阶段change"..status)

    local code = nil
    if status == 1 or status == 2 or status == 5 then
        code = 1
    elseif status == 6 then
        code = 2
    elseif status == 8 or status == 7 then
        self:EndTime2()
        self:EndTime3()
        code = 3
    elseif status == 3 then
        self:EndTime2()
        code = 4
    elseif status == 4 then
        self:EndTime2()
        self:EndTime3()
        code = 4
    end
    self:ChangeItem(code)
    local bossStatus = GodsWarWorShipManager.Instance.BossStatus
    if bossStatus == 2 then
        self.challengeTimer.text = TI18N("挑战成功")
    elseif bossStatus == 3 then
        self.challengeTimer.text = TI18N("挑战失败")
    elseif bossStatus == 4 then
        self.challengeTimer.text = TI18N("挑战发起失败")
    end
    --print(status.."&&"..bossStatus)
    if status == 8 then
        if bossStatus == 1 then
            self.challengeTimer.text = TI18N("挑战正在发起")
        else
            self.challengeTimer.text = TI18N("等待发起挑战")
        end
    elseif status == 7 then
        if bossStatus == 0 or bossStatus == 4 then
            self.challengeTimer.text = TI18N("挑战发起失败")
        elseif bossStatus == 1 then
            self.challengeTimer.text = TI18N("挑战正在发起")
        end
    elseif status == 4 and bossStatus ~= 0 then
        self.challengeTimer.text = TI18N("活动结束请自行离场")
    end
end

function MainuiTraceGodsWarWorShip:ChangeItem(code)
    local bossStatus = GodsWarWorShipManager.Instance.BossStatus
    local status = GodsWarWorShipManager.Instance.godsWarStatus
    for i,v in ipairs(self.stepList) do
        if code == i then
            v.selected.gameObject:SetActive(true)
            v.icon.gameObject:SetActive(true)
        else
            v.selected.gameObject:SetActive(false)
            v.icon.gameObject:SetActive(false)
        end
    end
end

function MainuiTraceGodsWarWorShip:ClickFirstStep()
    local status = GodsWarWorShipManager.Instance.godsWarStatus
    if status == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动正在准备中，请等待活动开启"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动进入颁奖阶段，玩家可膜拜冠军队伍"))
    end
end

function MainuiTraceGodsWarWorShip:ClickEndStep()
    --分三种情况
    -- 活动未结束：挑战者挑战成功后，全服玩家可获得来自诸神的礼物
    -- 挑战胜利：挑战已成功，快到<color='#ffff00'>神战天使</color>处领取奖励吧{face_1,10}
    -- 挑战失败：很遗憾，挑战者们对诸神们发起挑战失败，诸神们已扬长而去{face_1,41}
    local bossStatus = GodsWarWorShipManager.Instance.BossStatus
    if bossStatus == 0 or bossStatus == 1 or bossStatus == 4 then
        NoticeManager.Instance:FloatTipsByString("挑战者挑战成功后，全服玩家可获得来自诸神的礼物")
    elseif bossStatus == 2 then
        NoticeManager.Instance:FloatTipsByString("挑战已成功，快查收你的奖励吧{face_1,10}")
    elseif bossStatus == 3 then
        NoticeManager.Instance:FloatTipsByString("很遗憾，挑战者们对诸神们发起挑战失败，诸神们已扬长而去{face_1,41}")
    elseif bossStatus == 4 then
        NoticeManager.Instance:FloatTipsByString("挑战者们未能对诸神发起挑战，活动失败{face_1,22}")
    end
end

function MainuiTraceGodsWarWorShip:OnRedayReturn(index)
    if index == 0 then
        self.challengeStatus.text = TI18N("<color='ff0000'>(未准备)</color>")
    elseif index == 1 then
        self.challengeStatus.text = TI18N("<color='00ff00'>(准备就绪)</color>")
    end
end

--诸神boss 挑战倒计时回调
function MainuiTraceGodsWarWorShip:UpdateChallengeTimer()
    local bossStatus = GodsWarWorShipManager.Instance.BossStatus
    local endTime = GodsWarWorShipManager.Instance.bossTime
    local status = GodsWarWorShipManager.Instance.godsWarStatus
    if status == 1 or status == 2 or status == 5 or status == 6 then
        self.timeVal = endTime - BaseUtils.BASE_TIME
        self:BeginTime()
    end
end

function MainuiTraceGodsWarWorShip:BeginTime()
    self:EndTime2()
    if self.timeVal > 0 then
        self.timerId2 = LuaTimer.Add(0, 1000, function() self:Loop() end)
    end
end

function MainuiTraceGodsWarWorShip:Loop()
    self.timeVal = self.timeVal - 1
    if self.timeVal < 0 then
        self:EndTime2()
    else
        self.challengeTimer.text = string.format(TI18N("挑战开启:%s"),BaseUtils.formate_time_gap(self.timeVal, ":", 0, BaseUtils.time_formate.MIN))
    end
end

function MainuiTraceGodsWarWorShip:EndTime2()
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
end

function MainuiTraceGodsWarWorShip:ChallengeSibiTimer()
    local endTime = nil
    if GodsWarWorShipManager.Instance.godsWarStatus == 3 and GodsWarWorShipManager.Instance.ChallengeSabiTime ~= nil and GodsWarWorShipManager.Instance.isHasGorWarShip then
        endTime = GodsWarWorShipManager.Instance.ChallengeSabiTime
    end
    if endTime == nil then return end
    self.bossStatus = GodsWarWorShipManager.Instance.BossStatus
    if GodsWarWorShipManager.Instance.godsWarStatus ~= 4 then
        self.timestamp_2 = 0
        local baseTime = BaseUtils.BASE_TIME
        if endTime >= baseTime then
            self.timestamp_2 = endTime - baseTime
        end
        if self.timestamp_2 > 0 then
            self:EndTime3()
            self.timerId3 = LuaTimer.Add(10, 1000, function() self:TimeLoop_2() end)
        end
    end
end

function MainuiTraceGodsWarWorShip:TimeLoop_2()
    self.timestamp_2 = self.timestamp_2 - 1
    if self.timestamp_2 < 0 then
        self:EndTime3()
    else
        self.challengeTimer.text = string.format(TI18N("%s,%s后撒币"), self.statusList[self.bossStatus], BaseUtils.formate_time_gap(self.timestamp_2, ":", 0, BaseUtils.time_formate.MIN))
    end
end

function MainuiTraceGodsWarWorShip:EndTime3()
    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
        self.timerId3 = nil
    end
end