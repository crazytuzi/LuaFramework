UnlimitedChallengeFrightInfoPanel = UnlimitedChallengeFrightInfoPanel or BaseClass(BasePanel)


function UnlimitedChallengeFrightInfoPanel:__init(model)
    self.model = model
    self.Mgr = UnlimitedChallengeManager.Instance
    self.EffectPath = string.format(AssetConfig.effect, "20180")
    self.bossEffectPath = string.format(AssetConfig.effect, "20181")
    self.resList = {
        {file = AssetConfig.unlimited_frightinfopanel, type = AssetType.Main}
        ,{file = self.EffectPath, type = AssetType.Main}
        ,{file = self.bossEffectPath, type = AssetType.Main}
        ,{file  =  AssetConfig.unlimited_texture, type  =  AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    -- self.teamupdatefunc = function()
    --     self:OnTeamUpdate()
    -- end
    self.end_fightCall = function()
        self.model:CloseFrightInfoPanel()
    end
    self.totalSlot = {}
    self.total_cycleSlot = {}
    self.currSlot = {}
    self.curr_cycleSlot = {}
end

function UnlimitedChallengeFrightInfoPanel:__delete()
    self.Mgr.combatReward = {}
    -- EventMgr.Instance:RemoveListener(event_name.team_info_update, self.teamupdatefunc)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.end_fightCall)
    for i,v in ipairs(self.totalSlot) do
        v:DeleteMe()
    end
    self.totalSlot = nil
    for i,v in ipairs(self.total_cycleSlot) do
        v:DeleteMe()
    end
    self.total_cycleSlot = nil
    for i,v in ipairs(self.currSlot) do
        v:DeleteMe()
    end
    self.currSlot = nil
    for i,v in ipairs(self.curr_cycleSlot) do
        v:DeleteMe()
    end
    self.curr_cycleSlot = nil

end
function UnlimitedChallengeFrightInfoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.unlimited_frightinfopanel))
    self.effect = GameObject.Instantiate(self:GetPrefab(self.EffectPath))
    self.bosseffect = GameObject.Instantiate(self:GetPrefab(self.bossEffectPath))
    UIUtils.AddUIChild(ChatManager.Instance.model.chatCanvas, self.gameObject)
    self.gameObject.name = "UnlimitedChallengeFrightInfoPanel"
    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

    self.WaveStr = self.transform:Find("TopObj/TDesc"):GetComponent(Text)
    self.TopBtn = self.transform:Find("TopObj"):GetComponent(Button)
    self.ShowCon = self.transform:Find("Show")
    self.num1 = self.ShowCon:Find("NumCon/num1"):GetComponent(Image)
    self.num2 = self.ShowCon:Find("NumCon/num2"):GetComponent(Image)

    self.normalbg = self.transform:Find("TopObj/Normalbg").gameObject
    self.bossbg = self.transform:Find("TopObj/Bossbg").gameObject

    self.effect.transform:SetParent(self.ShowCon)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    self.bosseffect.transform:SetParent(self.transform:Find("TopObj"))
    self.bosseffect.transform.localScale = Vector3.one
    self.bosseffect.transform.localPosition = Vector3(0, -110, 0)
    Utils.ChangeLayersRecursively(self.bosseffect.transform, "UI")
    self.bosseffect:SetActive(false)

    self.TopBtn.onClick:AddListener(function()
        self.InfoPanel.gameObject:SetActive(true)
    end)
    self.InfoPanel = self.transform:Find("InfoPanel")
    self.transform:Find("InfoPanel"):GetComponent(Button).onClick:AddListener(function()
        self.InfoPanel.gameObject:SetActive(false)
    end)

    self.TotalRewardCon = self.InfoPanel:Find("bg/List1/Con")
    self.CurrRewardCon = self.InfoPanel:Find("bg/List2/Con")
    self.reward_title2 = self.InfoPanel:Find("bg/Title2/Text"):GetComponent(Text)

    local setting1 = {
        axis = BoxLayoutAxis.X
        ,spacing = 0
        ,Left = 0
    }
    self.TotalLayout = LuaBoxLayout.New(self.TotalRewardCon, setting1)
    self.CurrLayout = LuaBoxLayout.New(self.CurrRewardCon, setting1)
    EventMgr.Instance:AddListener(event_name.end_fight, self.end_fightCall)
    self.WaveStr.text = string.format(TI18N("第%s波"), self.Mgr.currWave)
    self.normalbg:SetActive(DataEndlessChallenge.data_list[self.Mgr.currWave].isboss == 0)
    self.bossbg:SetActive(DataEndlessChallenge.data_list[self.Mgr.currWave].isboss == 1)
    self:reCycleSlot()
    self:UpdateReward()
end

function UnlimitedChallengeFrightInfoPanel:OnOpen()
    local cb = function()
        if BaseUtils.isnull(self.normalbg) then
            return
        end
        if self.Mgr.roundReward ~= nil and #self.Mgr.roundReward > 0 then
            for i,v in ipairs(self.Mgr.roundReward) do
                local msg = string.format("获得{assets_1, %s, %s}", v.assets, v.val)
                if v.assets < 90000 then
                    msg = string.format("获得{item_2, %s, 1, %s}", v.assets, v.val)
                end
                NoticeManager.Instance:FloatTipsByString(msg)
            end
            self.Mgr.roundReward = {}
        end
        LuaTimer.Add(2000, function()
            if self.Mgr.currWave - self.Mgr.lastWave >= 2 then
                local lastdata = DataEndlessChallenge.data_list[self.Mgr.lastWave]
                local msg = string.format(TI18N("神速！%s回合内通关，吓退了%s波敌人"), lastdata.round_limit, tostring(self.Mgr.currWave - self.Mgr.lastWave))
                NoticeManager.Instance:FloatTipsByString(msg)
            end
            if DataEndlessChallenge.data_list[self.Mgr.lastWave].isboss == 1 then
                local str = TI18N("消灭BOSS，魔法值完全恢复！")
                NoticeManager.Instance:FloatTipsByString(str)
                local msgData = MsgData.New()
                msgData.sourceString = str
                msgData.showString = msgData.sourceString
                NoticeManager.Instance.model.calculator:ChangeFoneSize(17)
                local allWidth = NoticeManager.Instance.model.calculator:SimpleGetWidth(msgData.sourceString)
                msgData.allWidth = allWidth
                local chatData = ChatData.New()
                chatData.showType = MsgEumn.ChatShowType.System
                chatData.msgData = msgData
                chatData.prefix = MsgEumn.ChatChannel.System
                chatData.channel = MsgEumn.ChatChannel.System

                ChatManager.Instance.model:ShowMsg(chatData)
            end
            self:ShowNextRound()
            self.WaveStr.text = string.format(TI18N("第%s波"), self.Mgr.currWave)
            self.normalbg:SetActive(DataEndlessChallenge.data_list[self.Mgr.currWave].isboss == 0)
            self.bossbg:SetActive(DataEndlessChallenge.data_list[self.Mgr.currWave].isboss == 1)
        end)
    end
    LuaTimer.Add(2000, function()
        if self.gameObject ~= nil then
            if CombatManager.Instance.isBrocasting and CombatManager.Instance.controller ~= nil then
                CombatManager.Instance.controller.brocastCtx:AddEndEvent(cb)
            else
                cb()
            end
        end
    end)
    self:reCycleSlot()
    self:UpdateReward()
end

function UnlimitedChallengeFrightInfoPanel:OnHide()

end

function UnlimitedChallengeFrightInfoPanel:reCycleSlot()
    for i,v in ipairs(self.totalSlot) do
        v.gameObject:SetActive(false)
        table.insert(self.total_cycleSlot, v)
    end
    self.totalSlot = {}
    for i,v in ipairs(self.currSlot) do
        v.gameObject:SetActive(false)
        table.insert(self.curr_cycleSlot, v)
    end
    self.currSlot = {}
end

function UnlimitedChallengeFrightInfoPanel:GetSlot(type)
    local slot
    if type == 1 then
        if #self.total_cycleSlot > 0 then
            slot = self.total_cycleSlot[#self.total_cycleSlot]
            table.remove( self.total_cycleSlot)
            table.insert(self.totalSlot, slot)
        else
            slot = self:GetNewSlot()
            table.insert(self.totalSlot, slot)
        end
    else
        if #self.curr_cycleSlot > 0 then
            slot = self.curr_cycleSlot[#self.curr_cycleSlot]
            table.remove( self.curr_cycleSlot)
            table.insert(self.currSlot, slot)
        else
            slot = self:GetNewSlot()
            table.insert(self.currSlot, slot)
        end
    end
    return slot
end

function UnlimitedChallengeFrightInfoPanel:GetNewSlot()
    local slot = ItemSlot.New()
    -- local info = ItemData.New()
    -- local base = DataItem.data_get[baseid]
    -- info:SetBase(base)
    -- local extra = {inbag = false, nobutton = true}
    -- slot:SetAll(info, extra)
    return slot
end

function UnlimitedChallengeFrightInfoPanel:UpdateReward()
    self.reward_title2.text = string.format(TI18N("第%s波奖励"), tostring(self.Mgr.currWave))
    self.TotalLayout:ReSet()
    self.CurrLayout:ReSet()
    for i,v in ipairs(self.Mgr.combatReward) do
        local slot = self:GetSlot(1)
        local info = ItemData.New()
        local base = DataItem.data_get[v.assets]
        info:SetBase(base)
        info.quantity = v.val
        local extra = {inbag = false, nobutton = true}
        slot:SetAll(info, extra)
        self.TotalLayout:AddCell(slot.gameObject)
    end
    local rewardid = DataEndlessChallenge.data_list[self.Mgr.currWave]
    if rewardid == nil then
        return
    else
        rewardid = rewardid.reward_id
    end
    local starindex = GloryManager.Instance.model.level_id
    local roundReward = {}
    for i = starindex , 0, -1 do
        local Key = string.format("%s_%s", tostring(rewardid), tostring(i))
        if DataEndlessChallenge.data_reward[Key] ~= nil then
            roundReward = DataEndlessChallenge.data_reward[Key].show_drop
            break
        end
    end
    for i,v in ipairs(roundReward) do
        local slot = self:GetSlot(2)
        local info = ItemData.New()
        local base = DataItem.data_get[v[1]]
        info:SetBase(base)
        info.quantity = v[2]
        local extra = {inbag = false, nobutton = true}
        slot:SetAll(info, extra)
        self.CurrLayout:AddCell(slot.gameObject)
    end
end

function UnlimitedChallengeFrightInfoPanel:ShowNextRound()
    if self.Mgr.currWave == self.Mgr.lastWave then
        return
    end
    self:SetNum(self.Mgr.currWave)
    if DataEndlessChallenge.data_list[self.Mgr.currWave].isboss == 1 then
        self.bosseffect:SetActive(false)
        self.bosseffect:SetActive(true)
        LuaTimer.Add(2500, function()
            if not BaseUtils.isnull(self.bosseffect) then
                self.bosseffect:SetActive(false)
            end
        end)
    else
        self.ShowCon.localPosition = Vector3(-575, 150, 0)
        self.effect:SetActive(false)
        self.effect:SetActive(true)
        self.ShowCon.gameObject:SetActive(true)
        local second = function()
            LuaTimer.Add(500, function()
                if not BaseUtils.isnull(self.ShowCon) then
                    Tween.Instance:MoveLocalX(self.ShowCon.gameObject, 575, 0.5, endfunc, LeanTweenType.easeOutSine)
                end
            end)
        end
        local endfunc = function()
            self.ShowCon.gameObject:SetActive(false)
        end
        Tween.Instance:MoveLocalX(self.ShowCon.gameObject, 0, 0.5, second, LeanTweenType.easeOutSine)
    end
end

function UnlimitedChallengeFrightInfoPanel:SetNum(num)
    local first = math.floor(num/10)
    local second = num%10
    if BaseUtils.isnull(self.num1) or BaseUtils.isnull(self.num2) then
        return
    end
    if first ~= 0 then
        self.num1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_4, "Num4_"..tostring(first))
        self.num2.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_4, "Num4_"..tostring(second))
        self.num1:SetNativeSize()
        self.num2:SetNativeSize()
        local scale1 = 40/self.num1.transform.sizeDelta.y
        local scale2 = 40/self.num2.transform.sizeDelta.y
        self.num1.transform.localScale = Vector3.one*scale1
        self.num2.transform.localScale = Vector3.one*scale2
        self.num1.transform.anchoredPosition = Vector2(-self.num1.transform.sizeDelta.x/2*scale1, 0)
        self.num2.transform.anchoredPosition = Vector2(self.num2.transform.sizeDelta.x/2*scale2, 0)
        self.num1.gameObject:SetActive(true)
        self.num2.gameObject:SetActive(true)
    else
        self.num1.gameObject:SetActive(false)
        self.num2.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_4, "Num4_"..tostring(second))
        self.num2:SetNativeSize()
        local scale2 = 40/self.num2.transform.sizeDelta.y
        self.num2.transform.localScale = Vector3.one*scale2
        self.num2.transform.anchoredPosition = Vector2.zero
        self.num2.gameObject:SetActive(true)
    end
end