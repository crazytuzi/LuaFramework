-- 战斗UI 倒数部分
CombatCounterinfoPanel = CombatCounterinfoPanel or BaseClass()

function CombatCounterinfoPanel:__init(file, mainPanel)
    self.file = file
    self.mainPanel = mainPanel
    self:InitPanel()
end

function CombatCounterinfoPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(self.file))
    self.transform = self.gameObject.transform
    self.combatMgr = CombatManager.Instance
    UIUtils.AddUIChild(self.combatMgr.combatCanvas, self.gameObject)

    self.digitPanel = self.gameObject.transform:FindChild("CountDownContainer/Digit").gameObject
    self.digitRound = self.gameObject.transform:FindChild("RoundImage/RoundContainer/Digit").gameObject
    self.digitRoundPanel = self.gameObject.transform:FindChild("RoundImage").gameObject

    self.atk_formation = self.transform:Find("atk_formation")
    self.dfd_formation = self.transform:Find("dfd_formation")
    self.VSImg = self.transform:Find("VSImage")
    self.atkImg = self.atk_formation:GetComponent(Image)
    self.dfdImg = self.dfd_formation:GetComponent(Image)
    self.atkBtn = self.atk_formation:GetComponent(Button)
    self.dfdBtn = self.dfd_formation:GetComponent(Button)

    self.numberPanel = ImageSpriteGroup.New(self.digitPanel, "Num4_")
    self.roundPanel = ImageSpriteGroup.New(self.digitRound, "Num3_")
    LuaTimer.Add(50, function()
        self.roundPanel:SetNum(1)
    end)
    self.CountDownEndEvent = {}

    -- 数字索引
    self.refCount = 0
    self.watch1 = self.transform:Find("WatchImage").gameObject
    self.watch2 = self.transform:Find("WatchImage2").gameObject
    self.watch1:SetActive(self.mainPanel.combatMgr.isWatching)
    self.watch2:SetActive(self.mainPanel.combatMgr.isWatchRecorder)
    self:SetFormation(self.mainPanel.controller.enterData)
end

function CombatCounterinfoPanel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
end

function CombatCounterinfoPanel:Show()
    self:SetFormation(self.mainPanel.controller.enterData)
    self.refCount = 0
    self.watch1:SetActive(self.mainPanel.combatMgr.isWatching)
    self.watch2:SetActive(self.mainPanel.combatMgr.isWatchRecorder)
end

function CombatCounterinfoPanel:SetRound(round)
    if round == 0 then
        return
    end
    self.roundPanel:SetNum(round)
end

function CombatCounterinfoPanel:StartCountDown(startNum)
    self.refCount = self.refCount + 1
    if startNum > 0 and self.combatMgr.isBrocasting == false then
        self.numberPanel:SetNum(startNum)
        LuaTimer.Add(1000, function(arge) self:ChangeNum({num = startNum, ref = self.refCount, total = startNum}) end)
    else
        self:OnCountDownEnd()
    end
end

function CombatCounterinfoPanel:StopCountDown()
    self.refCount = self.refCount + 1
    self.numberPanel:Release()
end


function CombatCounterinfoPanel:ChangeNum(arge)
    if self.combatMgr.isFighting == false or self.combatMgr.isBrocasting == true then
        self:OnCountDownEnd()
        return
    end
    local countDownNum = arge.num
    local ref = arge.ref
    local total = arge.total
    if ref == self.refCount then
        countDownNum = countDownNum - 1
        if countDownNum > 0 then
            self.numberPanel:SetNum(countDownNum)
            if (countDownNum + 3) <= total and self.mainPanel.isAutoFighting then
                self.numberPanel:Release()
                self:OnCountDownEnd()
            else
                LuaTimer.Add(1000, function(arge2) self:ChangeNum({num = countDownNum, ref = ref, total = total}) end )
            end
        else
            self.numberPanel:Release()
            self:OnCountDownEnd()
        end
    end
end

function CombatCounterinfoPanel:OnCountDownEnd()
    if self.mainPanel.isAutoFighting == false and self.combatMgr.isBrocasting == false and self.mainPanel.functionIconPanel then
        self.mainPanel.functionIconPanel:OnAutoButtonClick()
        Log.Info("战斗回合计时到了变自动")
    end
    for _, func in ipairs(self.CountDownEndEvent) do
        func()
    end
end


function CombatCounterinfoPanel:SetFormation(enterData)
    -- if enterData.combat_type == 6 then
    local atk_formation = enterData.atk_formation
    local dfd_formation = enterData.dfd_formation
    local atk_lev = enterData.atk_formation_lev
    local dfd_lev = enterData.dfd_formation_lev
    if self.mainPanel.controller.selfData.group == 1 then
        local temp
        temp = atk_formation
        atk_formation = dfd_formation
        dfd_formation = temp
        temp = atk_lev
        atk_lev = dfd_lev
        dfd_lev = temp
    end
    if (atk_formation>8) then
        atk_formation = 1
    end
    if (dfd_formation>8) then
        dfd_formation = 1
    end
    self.atkImg.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.formation_icon, tostring(atk_formation))
    if atk_formation <= 8 and atk_formation>1 then
        local Info = DataFormation.data_list[string.format("%s_%s", tostring(atk_formation), tostring(atk_lev))]
        self.atkBtn.onClick:RemoveAllListeners()
        local Isrestrain, strong = self:Isrestrain(dfd_formation, atk_formation)
        local srestrainStr = ""
        if Isrestrain then
            if strong then
                srestrainStr = TI18N("<color='#ff0000'>(被强克制)</color>")
            else
                srestrainStr = TI18N("<color='#ff0000'>(被弱克制)</color>")
            end
        end
        self.atkBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.atk_formation.gameObject, itemData = {
            string.format(TI18N("<color='#FFCC66'>%s</color>%s"), Info.name, srestrainStr),
            -- string.format(TI18N("<color='#FFCC66'><size=21>%s</size></color><size=17>%s</size>"), Info.name, srestrainStr),
            TI18N("位置1:"..(Info["up_1"]=="" and "无效果" or Info["up_1"])..Info["down_1"]),
            TI18N("位置2:"..(Info["up_2"]=="" and "无效果" or Info["up_2"])..Info["down_2"]),
            TI18N("位置3:"..(Info["up_3"]=="" and "无效果" or Info["up_3"])..Info["down_3"]),
            TI18N("位置4:"..(Info["up_4"]=="" and "无效果" or Info["up_4"])..Info["down_4"]),
            TI18N("位置5:"..(Info["up_5"]=="" and "无效果" or Info["up_5"])..Info["down_5"]),
            string.format(TI18N("<color='#ffff00'>强克制:%s</color>"),self:GetRestrain(atk_formation,true)),
            string.format(TI18N("<color='#ffff00'>弱克制:%s</color>"),self:GetRestrain(atk_formation,false)),
            TI18N("<color='#ffff00'>强克制己方全体免伤+10%，弱克值己方全体免伤+5%</color>"),
            -- TI18N(string.format("被克制:%s",self:GetBeRestrain(atk_formation))),
            }})
        end)
    else
        self.atkBtn.onClick:RemoveAllListeners()
        self.atkBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.atk_formation.gameObject, itemData = {
            TI18N("普通阵")..((atk_formation == 1 and dfd_formation == 1) and "" or TI18N("<color='#ff0000'>（被强克制）</color>")),
            TI18N("无阵法效果")
            }})
        end)
    end

    self.dfdImg.sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.formation_icon, tostring(dfd_formation))
    if dfd_formation <= 8 and dfd_formation>1 then
        local Info = DataFormation.data_list[string.format("%s_%s", tostring(dfd_formation), tostring(dfd_lev))]
        self.dfdBtn.onClick:RemoveAllListeners()
        local Isrestrain, strong = self:Isrestrain(atk_formation,dfd_formation)
        local srestrainStr = ""
        if Isrestrain then
            if strong then
                srestrainStr = TI18N("<color='#ff0000'>(被强克制)</color>")
            else
                srestrainStr = TI18N("<color='#ff0000'>(被弱克制)</color>")
            end
        end
        self.dfdBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.dfd_formation.gameObject, itemData = {
            string.format("<color='#FFCC66'>%s</color>%s", Info.name, srestrainStr),
            -- string.format("<color='#FFCC66'><size=21>%s</size></color><size=17>%s</size>", Info.name, srestrainStr),
            TI18N("位置1:") ..(Info["up_1"]=="" and TI18N("无效果") or Info["up_1"])..Info["down_1"],
            TI18N("位置2:") ..(Info["up_2"]=="" and TI18N("无效果") or Info["up_2"])..Info["down_2"],
            TI18N("位置3:") ..(Info["up_3"]=="" and TI18N("无效果") or Info["up_3"])..Info["down_3"],
            TI18N("位置4:") ..(Info["up_4"]=="" and TI18N("无效果") or Info["up_4"])..Info["down_4"],
            TI18N("位置5:") ..(Info["up_5"]=="" and TI18N("无效果") or Info["up_5"])..Info["down_5"],
            string.format(TI18N("<color='#ffff00'>强克制:%s</color>"), self:GetRestrain(dfd_formation,true)),
            string.format(TI18N("<color='#ffff00'>弱克制:%s</color>"), self:GetRestrain(dfd_formation,false)),
            TI18N("<color='#ffff00'>强克制己方全体伤害+5%，免伤+5%，弱克制己方全体伤害+5%</color>"),
            -- TI18N(string.format("被克制:%s",self:GetBeRestrain(dfd_formation))),
            }})
        end)
    else
        self.dfdBtn.onClick:RemoveAllListeners()
        self.dfdBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.dfd_formation.gameObject, itemData = {
            TI18N("普通阵") .. ((atk_formation == 1 and dfd_formation == 1) and "" or TI18N("<color='#ff0000'>（被强克制）</color>")),
            TI18N("无阵法效果"),
            }})
        end)
    end
    if (atk_formation == 1 and dfd_formation == 1)
        or enterData.combat_type == 60 -- 爵位挑战不显示阵法
        or enterData.combat_type == 62 -- 龙王挑战不显示阵法
        or enterData.combat_type == 70 -- 天启挑战不显示阵法
        then
        self.VSImg.gameObject:SetActive(false)
        self.atk_formation.gameObject:SetActive(false)
        self.dfd_formation.gameObject:SetActive(false)
    else
        self.VSImg.gameObject:SetActive(true)
        self.atk_formation.gameObject:SetActive(true)
        self.dfd_formation.gameObject:SetActive(true)
    end
end

function CombatCounterinfoPanel:Isrestrain(atk, dfd)
    local atk_data = DataFormation.data_list[string.format("%s_1", tostring(atk))]
    -- local dfd_data = DataFormation.data_list[string.format("%s_1", tostring(dfd))]
    for i,v in ipairs(atk_data.strong_restrain) do
        if v == dfd then
            return true, true
        end
    end
    for i,v in ipairs(atk_data.weak_restrain) do
        if v == dfd then
            return true, false
        end
    end
    return false
end

function CombatCounterinfoPanel:GetRestrain(atk, strong)
    if atk == 0 then
        atk = 1
    end
    local atk_data = DataFormation.data_list[string.format("%s_1", tostring(atk))]
    local str = ""
    if strong == true then
        for i,v in ipairs(atk_data.strong_restrain) do
            if v > 1 and v <= 8 then
                local name = DataFormation.data_list[string.format("%s_1", tostring(v))].name
                if str == "" then
                    str = string.format("<color='#ffff00'>%s</color>", name)
                else
                    str = string.format("%s、<color='#ffff00'>%s</color>", str, name)
                end
            end
        end
    elseif strong == false then
        for i,v in ipairs(atk_data.weak_restrain) do
            if v > 1 and v <= 8 then
                local name = DataFormation.data_list[string.format("%s_1", tostring(v))].name
                if str == "" then
                    str = string.format("<color='#ffff00'>%s</color>", name)
                else
                    str = string.format("%s、<color='#ffff00'>%s</color>", str, name)
                end
            end
        end
    end
    return str == "" and TI18N("无") or str
end
function CombatCounterinfoPanel:GetBeRestrain(dfd)
    if dfd == 0 then
        dfd = 1
    end
    local str = ""
    for i=2, 6 do
        local name = DataFormation.data_list[string.format("%s_1", tostring(i))].name
        local Isrestrain, strong = self:Isrestrain(i, dfd)
        if Isrestrain then
            if str == "" then
                str = string.format("<color='#ffff00'>%s</color>", name)
            else
                str = string.format("%s、<color='#ffff00'>%s</color>", str, name)
            end
        end
    end
    return str == "" and TI18N("无") or str
end
