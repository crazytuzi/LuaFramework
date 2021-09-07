MainuiTraceMasquerade = MainuiTraceMasquerade or BaseClass(BaseTracePanel)

function MainuiTraceMasquerade:__init(main)
    self.main = main
    self.mgr = MasqueradeManager.Instance
    self.model = self.mgr.model

    self.mgr.panel = self

    self.gameObject = nil
    self.tabObj = nil
    self.isInit = true

    self.resList = {
        {file = AssetConfig.masquerade_content, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }

    self.phaseHandler = {
        [self.mgr.MasqueradeStatusEnum.NoBegin] = function(self) self:PhaseNoBegin() end
        , [self.mgr.MasqueradeStatusEnum.Broadcast] = function(self) self:PhaseBroadcast() end
        , [self.mgr.MasqueradeStatusEnum.Register] = function(self) self:PhaseReady() end
        , [self.mgr.MasqueradeStatusEnum.Battle] = function(self) self:PhaseBattle() end
        , [self.mgr.MasqueradeStatusEnum.Settle] = function(self) self:PhaseSettle() end
    }

    self.timeListener = function() self:OnTime() end
    self.infoListener = function() self:UpdateMy() end
    self.rankListener = function() self:ShowTop3() end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceMasquerade:__delete()
    self:RemoveListeners()
end

function MainuiTraceMasquerade:OnShow()
    self:RemoveListeners()
    self.mgr.onUpdateRank:AddListener(self.rankListener)
    self.mgr.onUpdateTime:AddListener(self.timeListener)
    self.mgr.onUpdateMy:AddListener(self.infoListener)

    self:GotoPhase(self.mgr.status)
end

function MainuiTraceMasquerade:OnHide()
    self:RemoveListeners()
end

function MainuiTraceMasquerade:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceMasquerade:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.masquerade_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    local t = self.transform:Find("Panel")
    self.toggle = t:Find("Toggle"):GetComponent(Toggle)
    self.toggle.transform:Find("Background/Checkmark").gameObject:SetActive(true)
    self.toggle.transform:Find("Background/Checkmark"):GetComponent(RectTransform).anchoredPosition = Vector2(0, 3.15)
    local rect = t:Find("Toggle/Label"):GetComponent(RectTransform)
    rect.anchorMin = Vector2(0,0.5)
    rect.anchorMax = Vector2(0,0.5)
    rect.anchoredPosition = Vector2(92, 0)
    rect.sizeDelta = Vector2(150, 50)
    rect.gameObject:GetComponent(Text).alignment = 5
    self.titleText = t:Find("Title/Text"):GetComponent(Text)
    self.box1Obj = t:Find("BtnArea/Box1").gameObject
    self.box2Obj = t:Find("BtnArea/Box2").gameObject
    self.button1 = t:Find("BtnArea/Box1/Button"):GetComponent(Button)
    self.button2 = t:Find("BtnArea/Box2/Button"):GetComponent(Button)
    self.button1Text = t:Find("BtnArea/Box1/Button/Text"):GetComponent(Text)
    self.button2Text = t:Find("BtnArea/Box2/Button/Text"):GetComponent(Text)
    self.campBgObj = t:Find("CampBg").gameObject
    self.campText = t:Find("CampBg/Text"):GetComponent(Text)
    self.mainRect = t:GetComponent(RectTransform)

    self.phaseObjList = {
        [self.mgr.MasqueradeStatusEnum.Register] = t:Find("PhaseReady").gameObject,
        [self.mgr.MasqueradeStatusEnum.Battle] = t:Find("PhaseBattle").gameObject,
    }

    t = self.phaseObjList[self.mgr.MasqueradeStatusEnum.Register].transform
    self.readyDescRect = t:Find("Desc"):GetComponent(RectTransform)
    self.readyDescText = t:Find("Desc"):GetComponent(Text)
    self.readyTimeText = t:Find("TimeBg/Desc"):GetComponent(Text)
    self.readyExpText = t:Find("ExpBg/Value"):GetComponent(Text)

    t = self.phaseObjList[self.mgr.MasqueradeStatusEnum.Battle].transform
    self.battleMyScoreText = t:Find("My/MyScore/Value"):GetComponent(Text)
    self.battleMyRankText = t:Find("My/Rank/Value"):GetComponent(Text)
    local battleRank = t:Find("Rank")
    self.rankItem = {nil, nil, nil}
    for i=1,3 do
        local tab = {}
        tab.trans = battleRank:Find("Item"..i)
        tab.obj = tab.trans.gameObject
        tab.rankImage = tab.trans:Find("Rank"):GetComponent(Image)
        tab.nameText = tab.trans:Find("Name"):GetComponent(Text)
        tab.scoreText = tab.trans:Find("Score"):GetComponent(Text)
        tab.floorText = tab.trans:Find("Floor"):GetComponent(Text)
        self.rankItem[i] = tab
    end
    self.battleDescText = t:Find("Pre/Desc"):GetComponent(Text)
    self.battleNoticeBtn = t:Find("Pre/Notice"):GetComponent(Button)
    self.battleRewardBtn = t:Find("Pre/Reward"):GetComponent(Button)
    t:Find("My").anchoredPosition = Vector2(0, -17.9)
    t:Find("Rank").anchoredPosition = Vector2(0, -47.6)
    t:Find("Pre").anchoredPosition = Vector2(0, -160.5)

    self.titleText.text = self.mgr.name
    self.toggle.gameObject:SetActive(true)
    self.toggle.onValueChanged:RemoveAllListeners()
    self.toggle.isOn = (self.model.hideStatus == true)
    self.toggle.onValueChanged:AddListener(function(status) self:SetHide(status) end)
    -- self:SetHide(self.model.hideStatus)

    self.campBgObj:SetActive(false)
    self.isInit = true

    self.battleNoticeBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.battleNoticeBtn.gameObject, itemData = {
            TI18N("1.战斗和采集水晶获得<color='#ffff00'>变身能量</color>进入下层"),
            TI18N("2.每层拥有不同的<color='#ffff00'>变身效果</color>，利用变身效果赢取战斗胜利"),
            TI18N("3.第五层可采集<color='#ffff00'>幻境宝箱</color>，获得丰厚奖励"),
            TI18N("4.第五层累积一定变身能量后，会发生<color='#00ff00'>进阶</color>变身，进阶状态战斗失败会<color='#ffff00'>扣分</color>"),
            TI18N("5.最终奖励按<color='#ffff00'>能量</color>发放")
            -- "",
            -- "各层变身效果：",
            -- "<color='#ffff00'>第一层变身效果：</color>每失败一次将获得1层<color='#00ff00'>祝福效果</color>，可无限叠加。<color='#00ff00'>祝福:</color>己方所有单位提升10%生命值和10%攻击力",
            -- "<color='#ffff00'>第二层变身效果：</color>所有单位受到<color='#00ff00'>治疗效果提升30%</color>",
            -- "<color='#ffff00'>第三层变身效果：</color>角色守护在单场战斗首次死亡时，会触发<color='#00ff00'>神佑</color>。恢复20%生命",
            -- "<color='#ffff00'>第四层变身效果：</color>守护<color='#00ff00'>生命值提升30%</color>",
            -- "<color='#ffff00'>第五层变身效果：</color>守护<color='#00ff00'>伤害提升20%</color>",
            -- "<color='#ffff00'>进阶变身效果：</color>战斗获得积分<color='#00ff00'>提升20%</color>",
            -- "<color='#ffff00'>仙桃之力:</color><color='#00ff00'>攻击提升5%</color>和<color='#00ff00'>生命上限提升10%</color>",
            }})
    end)
end

function MainuiTraceMasquerade:GotoPhase(phase)
    if self.isInit then
        -- print(debug.traceback())
        for k,v in pairs(self.phaseObjList) do
            v:SetActive(false)
        end
        if phase == nil or self.phaseObjList[phase] == nil then
            return
        end
        self.phaseObjList[phase]:SetActive(true)
        self.phaseHandler[phase](self)
        self:OnTime()
        -- print("<color=#FF0000>---------------------------</color> "..tostring(phase))
    end
end

function MainuiTraceMasquerade:PhaseNoBegin()
end

function MainuiTraceMasquerade:PhaseBroadcast()
end

function MainuiTraceMasquerade:PhaseReady()
    self.box1Obj:SetActive(false)
    self.box2Obj:SetActive(true)
    -- self.button1Text.text = TI18N("查看排名")
    self.button2Text.text = TI18N("退出")
    self.readyDescText.text = self.mgr.ruleDesc
    -- self.toggle.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(5, 46)

    self.titleText.text = self.mgr.name
    -- if self.model.myInfo.series ~= nil then
    --     self.titleText.text = DataHeroData.data_series[self.model.myInfo.series].name
    -- else
    -- end

    self.readyDescRect.anchoredPosition = Vector2(0, -26.5)
    -- self.readyDescRect.sizeDelta = Vector2(200, 40)

    self.button2.onClick:RemoveAllListeners()
    self.button2.onClick:AddListener(function() self.mgr:OnQuit() end)
    self.mainRect.sizeDelta = Vector2(230, 250)
    self.mainRect.anchoredPosition = Vector2(0, -10)
    self.toggle.gameObject:SetActive(false)

    self:UpdateMy()
end

function MainuiTraceMasquerade:PhaseBattle()
    local model = self.model
    self.box1Obj:SetActive(true)
    self.box2Obj:SetActive(true)
    self.button1Text.text = TI18N("查看排行")
    self.button2Text.text = TI18N("退出")

    -- self.battleStatusText.text = self.mgr.statusDesc[1]
    -- if self.model.myInfo.group ~= nil then
    --     self.campText.text = self.mgr.campNames[self.model.myInfo.group]..TI18N("代表队")
    -- else
    --     self.campText.text = ""
    -- end

    self:ShowTop3()
    self.battleMyScoreText.text = tostring(model.myInfo.score)
    if model.myInfo.rank == 0 then
        self.battleMyRankText.text = TI18N("榜外")
    else
        self.battleMyRankText.text = tostring(model.myInfo.rank or TI18N("榜外"))
    end

    self.toggle.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(5, 10)
    self.button2.onClick:RemoveAllListeners()
    self.button2.onClick:AddListener(function() self.mgr:OnQuit() end)
    self.button1.onClick:RemoveAllListeners()
    self.button1.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.masquerade_rank_window) end)
    self.mainRect.sizeDelta = Vector2(230, 255)
    self.mainRect.anchoredPosition = Vector2(0, -10)
    self.toggle.gameObject:SetActive(true)
end

function MainuiTraceMasquerade:PhaseReward()
    self.box1Obj:SetActive(false)
    self.box2Obj:SetActive(true)
    self.button2Text.text = TI18N("退出")

    self.battleStatusText.text = self.mgr.statusDesc[2]
    -- if self.model.myInfo.group ~= nil then
    --     self.campText.text = self.mgr.campNames[self.model.myInfo.group]..TI18N("代表队")
    -- else
    --     self.campText.text = ""
    -- end

    self.button2.onClick:RemoveAllListeners()
    self.button2.onClick:AddListener(function() self.mgr:OnQuit() end)
    self.mainRect.sizeDelta = Vector2(230, 220)
end

function MainuiTraceMasquerade:PhaseSettle()
    self.box1Obj:SetActive(false)
    self.box2Obj:SetActive(true)
    self.button2Text.text = TI18N("退出")
end

function MainuiTraceMasquerade:PhaseEnded()
end

function MainuiTraceMasquerade:RemoveListeners()
    self.mgr.onUpdateRank:RemoveListener(self.rankListener)
    self.mgr.onUpdateTime:RemoveListener(self.timeListener)
    self.mgr.onUpdateMy:RemoveListener(self.infoListener)
end

-- function MainuiTraceMasquerade:OnTime()
--     local restTime = self.model.restTime
--     if restTime == nil or restTime < 0 then restTime = 0 end

--     if self.mgr.phase == HeroEumn.Phase.Ready then
--         local m = nil
--         local s = nil
--         _,_,m,s = BaseUtils.time_gap_to_timer(restTime)
--         self.readyTimeText.text = string.format(self.mgr.readyDescPattern, string.format("%s:%s",tostring(m), tostring(s)))
--     end
-- end

function MainuiTraceMasquerade:SetHide(isHide)
    self.mgr:SetMasqHide(isHide)
end

function MainuiTraceMasquerade:ShowTop3(justMyself)
    local model = self.model
    local datalist = {nil, nil, nil}
    local used = {}

    for i=1,3 do
        local data = nil
        local key = nil
        for k,v in pairs(model.playerList) do
            if v ~= nil and used[k] == nil then
                if datalist[i] == nil then
                    datalist[i] = v
                    key = k
                    data = v

                    if justMyself then
                        break
                    end
                else
                    if self.mgr:Cmp(v, datalist[i]) then
                        datalist[i] = v
                        data = v
                        key = k
                    end
                end
            end
        end
        if key ~= nil then used[key] = true end
        local tab = self.rankItem[i]
        if data == nil then
            tab.obj:SetActive(false)
        else
            tab.obj:SetActive(true)
            tab.nameText.text = data.name
            tab.scoreText.text = tostring(data.score)
            tab.floorText.text = tostring(DataElf.data_map[data.map_base_id].id)
        end
    end

    if #datalist == 0 then
        model:AddPlayer({platform = RoleManager.Instance.RoleData.platform, rid = RoleManager.Instance.RoleData.id, r_zone_id = RoleManager.Instance.RoleData.zone_id,classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, lev = RoleManager.Instance.RoleData.lev, name = RoleManager.Instance.RoleData.name, score = 0, rank = 1, map_base_id = 71000}, 1)
        self:ShowTop3(true)
    end
end

function MainuiTraceMasquerade:UpdateMy()
    local model = self.model
    if model.myInfo == nil or model.myInfo.map_base_id == nil or DataElf.data_map[model.myInfo.map_base_id] == nil then
        return
    end
    if self.mgr.status == self.mgr.MasqueradeStatusEnum.Register then
        if model.myInfo.exp ~= nil then
            self.readyExpText.text = tostring(model.myInfo.exp)
        else
            self.readyExpText.text = "0"
        end
    elseif self.mgr.status == self.mgr.MasqueradeStatusEnum.Battle then
        self.battleMyScoreText.text = tostring(model.myInfo.score)
        if model.myInfo.rank == 0 then
            self.battleMyRankText.text = TI18N("榜外")
        else
            self.battleMyRankText.text = tostring(model.myInfo.rank or TI18N("榜外"))
        end
        local floor = DataElf.data_map[model.myInfo.map_base_id].id
        self.battleDescText.text = TI18N("进度满后进入<color='#00ff00'>下一层</color>\n<color='#00ff00'>第五层</color>可以开启")
        if model.myInfo.group ~= nil then
            self.titleText.text = string.format(TI18N("第%s/%s层"), tostring(floor), tostring(model.max_floor))
        else
            self.titleText.text = self.mgr.name
        end
    end
end

function MainuiTraceMasquerade:OnTime()
    local time = self.mgr.time - BaseUtils.BASE_TIME
    -- print(time)
    if self.mgr.status == self.mgr.MasqueradeStatusEnum.Register then
        local m = nil
        local s = nil
        local _ = nil
        _,_,m,s = BaseUtils.time_gap_to_timer(time)
        self.readyTimeText.text = string.format(TI18N("距活动开启:<color='#FFDC5F'>%s</color>"), string.format("%s:%s", tostring(m), tostring(s)))
    elseif self.mgr.status == self.mgr.MasqueradeStatusEnum.Battle then
    else
    end
end


