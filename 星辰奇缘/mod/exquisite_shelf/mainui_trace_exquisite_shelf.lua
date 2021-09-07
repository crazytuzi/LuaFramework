-- @author 黄耀聪
-- @date 2017年8月21日, 星期一

MainuiTraceExquisiteShelf = MainuiTraceExquisiteShelf or BaseClass(BaseTracePanel)

function MainuiTraceExquisiteShelf:__init(main)
    self.main = main
    self.model = ExquisiteShelfManager.Instance.model

    self.descString = TI18N([[1.等级达到<color='#ffff00'>65级</color>，3人以上组队可以进入宝阁寻宝
2.宝阁有<color='#ffff00'>2种</color>难度，不同等级可以选择<color='#ffff00'>不同难度的挑战</color>
3.击败<color='#ffff00'>外阁王者</color>后可进入内阁挑战古代王者<color='#ffff00'>夺取宝物</color>]])

    self.resList = {
        {file = AssetConfig.exquisite_shelf_content, type = AssetType.Main},
        {file = AssetConfig.exquisite_shelf_textures, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.isInit = false
    self.initReady = false

    self.changeListener = function() self:ChangePhase() end
end

function MainuiTraceExquisiteShelf:__delete()
end

function MainuiTraceExquisiteShelf:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.scene_load, self.changeListener)
    ExquisiteShelfManager.Instance.onUpdateEvent:AddListener(self.changeListener)

    self.gameObject:SetActive(true)
    self:ChangePhase()
end

function MainuiTraceExquisiteShelf:OnHide()
    self:RemoveListeners()
end

function MainuiTraceExquisiteShelf:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exquisite_shelf_content))
    self.gameObject.name = "MainuiTraceExquisiteShelf"

    self.transform = self.gameObject.transform

    local transform = self.transform
    transform:SetParent(self.main.mainObj.transform)
    transform.localScale = Vector3.one
    transform.anchoredPosition = Vector2(0, -47)

    local t = self.transform
    self.titleText = t:Find("Title/Text"):GetComponent(Text)

    local ready = t:Find("Ready")
    self.readyTitleText = ready:Find("Title"):GetComponent(Text)
    self.readyDescExt = MsgItemExt.New(ready:Find("Desc"):GetComponent(Text), 200, 16, 18.53)
    self.readyObj = ready.gameObject

    local battle = t:Find("Battle")
    self.battleTarget = battle:Find("NextTarget")
    self.battleTargetTitleText = self.battleTarget:Find("Title/Text"):GetComponent(Text)
    self.battleTargetNameText = self.battleTarget:Find("Name"):GetComponent(Text)
    self.battleTargetButton = self.battleTarget:GetComponent(Button)
    self.battleTargetButton.onClick:AddListener(function() self:GetNextTarget() end)

    self.battleLevel = battle:Find("NextLevel")
    self.battleLevelTitleText = self.battleLevel:Find("Title"):GetComponent(Text)
    self.battleLevelButton = self.battleLevel:GetComponent(Button)
    self.battleLevelButton.onClick:AddListener(function() self:GoNextLevel() end)

    self.battleConditionText = battle:Find("Condition/Text"):GetComponent(Text)
    self.battleConditionText.transform.anchorMax = Vector2(0.5,0.5)
    self.battleConditionText.transform.anchorMin = Vector2(0.5,0.5)
    self.battleConditionText.transform.pivot = Vector2(0,1)
    self.battleConditionText.alignment = 0
    self.battleConditionExt = MsgItemExt.New(self.battleConditionText, 194, 16, 18.53)
    self.battleConditionObj = battle:Find("Condition").gameObject

    self.battleRewardButton = battle:Find("Reward/Icon"):GetComponent(Button)
    self.battleRewardLoader = SingleIconLoader.New(battle:Find("Reward/Icon").gameObject)
    self.battleRewardBg = battle:Find("Reward/Bg")
    self.battleRewardImage = battle:Find("Reward/Get"):GetComponent(Image)
    self.battleRewardText = battle:Find("Reward/Text"):GetComponent(Text)
    self.battleRewardObj = battle:Find("Reward").gameObject

    local clear = battle:Find("Clear")
    self.clearText = clear:Find("Text"):GetComponent(Text)
    self.clearObj = clear.gameObject

    self.battleObj = battle.gameObject

    local buttonArea = t:Find("ButtonArea")
    self.leftButton = buttonArea:Find("ButtonLeft"):GetComponent(Button)
    self.leftButtonImage = buttonArea:Find("ButtonLeft"):GetComponent(Image)
    self.leftButtonText = buttonArea:Find("ButtonLeft/Text"):GetComponent(Text)
    self.rightButton = buttonArea:Find("ButtonRight"):GetComponent(Button)
    self.rightButtonImage = buttonArea:Find("ButtonRight"):GetComponent(Image)
    self.rightButtonText = buttonArea:Find("ButtonRight/Text"):GetComponent(Text)

    self.layout = LuaBoxLayout.New(t:Find("Battle"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 5})
    self.battleRewardLoader:SetSprite(SingleIconType.Item, 21244)

    self.leftButton.onClick:AddListener(function() print("left") if self.leftCallback ~= nil then self.leftCallback() end end)
    self.rightButton.onClick:AddListener(function() print("right") if self.rightCallback ~= nil then self.rightCallback() end end)
    self.battleRewardButton.onClick:AddListener(function() self:ShowReward() end)

    self.tipsPanel = ExquisiteShelfRewardPreview.New(t:Find("TipsPanel").gameObject)
    self.tipsPanel:Hiden()
end

function MainuiTraceExquisiteShelf:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceExquisiteShelf:Init()
    self.isInit = true
end

function MainuiTraceExquisiteShelf:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.changeListener)
    ExquisiteShelfManager.Instance.onUpdateEvent:RemoveListener(self.changeListener)
end

function MainuiTraceExquisiteShelf:ChangePhase()
    local mapid = SceneManager.Instance:CurrentMapId()

    if mapid == ExquisiteShelfManager.Instance.readyMapId then
        self:PhaseReady()
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.ExquisiteShelf then
        self:ReloadReward()
        if ExquisiteShelfManager.Instance:IsCurrentLevelFinish() then
            self:PhaseLevel()
        else
            self:PhaseTarget()
        end
    end
end

-- 准备区
function MainuiTraceExquisiteShelf:PhaseReady()
    self.readyObj:SetActive(true)
    self.battleObj:SetActive(false)

    if not self.initReady then
        self.readyTitleText.text = string.format(TI18N("挑战副本:%s"), ExquisiteShelfManager.Instance.name)
        self.readyDescExt:SetData(self.descString)

        local size = self.readyDescExt.contentTrans.sizeDelta
        self.readyDescExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, -45.2)
        self.initReady = true
    end
    self.readyObj.transform.sizeDelta = Vector2(226, self.readyDescExt.contentTrans.sizeDelta.y - self.readyDescExt.contentTrans.anchoredPosition.y)
    self.transform.sizeDelta = Vector2(226, self.readyObj.transform.sizeDelta.y - self.readyObj.transform.anchoredPosition.y)
    self.titleText.text = ExquisiteShelfManager.Instance.name

    self:ReloadButtons(1)
end

-- 下一目标
function MainuiTraceExquisiteShelf:PhaseTarget()
    self.battleObj:SetActive(true)
    self.readyObj:SetActive(false)
    self.battleTarget.gameObject:SetActive(true)
    self.battleLevel.gameObject:SetActive(false)
    self.clearObj:SetActive(false)

    local level = ExquisiteShelfManager.Instance:GetCurrentLevel()
    if level == 1 then
        self.battleTargetTitleText.text = string.format(TI18N("第%s个对手"), self.model.shelfData.wave or 1)
    else
        self.battleTargetTitleText.text = TI18N("内阁王者")
    end

    if self.model.shelfData.base_id == nil or DataUnit.data_unit[self.model.shelfData.base_id] == nil then
        self.battleTargetNameText.text = "-----"
    else
        self.battleTargetNameText.text = DataUnit.data_unit[self.model.shelfData.base_id].name
    end

    self.layout:ReSet()
    self.layout:AddCell(self.battleTarget.gameObject)

    if ExquisiteShelfManager.Instance:GetCurrentLevel() == 1 then
        self.titleText.text = string.format(TI18N("%s外阁"), ExquisiteShelfManager.Instance.name)
        self:SetConditionText(string.format(TI18N("击败<color='#00ff00'>%s/%s</color>外阁王者可开启宝箱"), ((self.model.shelfData.wave or 1) - 1) % 2 + 1, 2))
        -- if (self.model.shelfData.wave or 1) > 3 then
        -- else
        --     self:SetConditionText(string.format(TI18N("击败<color='#00ff00'>%s/%s</color>外阁王者可开启宝箱"), (self.model.shelfData.wave or 1), 3))
        -- end
    else
        self.titleText.text = string.format(TI18N("%s内阁"), ExquisiteShelfManager.Instance.name)
        -- self.titleText.text = string.format(TI18N("第%s/%s层"), ExquisiteShelfManager.Instance:GetCurrentLevel() - 1, ExquisiteShelfManager.Instance.finalLevel - 1)
        self:SetConditionText(string.format(TI18N("根据挑战难度开启宝箱<color='#00ff00'>%s</color>/%s"), ExquisiteShelfManager.Instance:GetBoxNum(), 3))
    end

    self:ReloadButtons(2)
    self.layout:AddCell(self.battleConditionObj)
    self.layout:AddCell(self.battleRewardObj)
    self.transform.sizeDelta = Vector2(226, self.layout.panelRect.sizeDelta.y - self.layout.panelRect.anchoredPosition.y)
end

-- 下一层
function MainuiTraceExquisiteShelf:PhaseLevel()
    self.battleObj:SetActive(true)
    self.battleConditionObj:SetActive(false)
    self.readyObj:SetActive(false)
    self.battleTarget.gameObject:SetActive(false)
    self.battleRewardObj:SetActive(false)
    self.layout:ReSet()

    -- 通关
    if ExquisiteShelfManager.Instance:IsAllFinish() then
        self.battleLevel.gameObject:SetActive(false)
        self.clearObj:SetActive(true)
        self.clearText.text = string.format(TI18N("%s全通\n请自行退出"), ExquisiteShelfManager.Instance.name)
        self.titleText.text = string.format(TI18N("%s内阁"), ExquisiteShelfManager.Instance.name)
        self.layout:AddCell(self.clearObj)
        self:ReloadButtons(3)
    else
        self.clearObj:SetActive(false)
        if ExquisiteShelfManager.Instance:GetCurrentLevel() == 1 then
            self.battleLevelTitleText.text = TI18N("前往: 玲珑内阁")
            self.titleText.text = TI18N("玲珑宝阁外阁")
            self:SetConditionText(string.format(TI18N("击败<color='#00ff00'>%s/%s</color>王者可开启宝箱"), ((self.model.shelfData.wave or 1) - 1) % 2 + 1, 2))
        else
            self.titleText.text = string.format(TI18N("%s内阁"), ExquisiteShelfManager.Instance.name) -- string.format(TI18N("第%s/%s层"), ExquisiteShelfManager.Instance:GetCurrentLevel() - 1, ExquisiteShelfManager.Instance.finalLevel - 1)
            self.battleLevelTitleText.text = string.format(TI18N("前往: 内阁<color='#00ff00'>%s</color>层"), ExquisiteShelfManager.Instance:GetCurrentLevel())
            self:SetConditionText(TI18N("击败本层王者可开启宝箱"))
        end
        self.layout:AddCell(self.battleLevel.gameObject)
        self.layout:AddCell(self.battleConditionObj)
        self:ReloadButtons(2)
        self.layout:AddCell(self.battleRewardObj)
    end

    self.transform.sizeDelta = Vector2(226, self.layout.panelRect.sizeDelta.y - self.layout.panelRect.anchoredPosition.y)
end

function MainuiTraceExquisiteShelf:GetNextTarget()
    ExquisiteShelfManager.Instance:GotoMoster()
    -- ExquisiteShelfManager.Instance:on20308({
    --     order = 0,
    --     type = 2,
    --     wave = 1,
    --     gain_list = {},
    --     show_list = {},
    --     })
end

function MainuiTraceExquisiteShelf:GoNextLevel()
    ExquisiteShelfManager.Instance:GotoTransport()
end

function MainuiTraceExquisiteShelf:ReloadButtons(phase)
    if phase == 1 then
        self.leftButton.transform.anchoredPosition = Vector2(-57, 0)
        self.rightButton.gameObject:SetActive(true)

        self.leftButtonText.text = TI18N("组 队")
        self.rightButtonText.text = TI18N("退 出")
        self.rightCallback = function() ExquisiteShelfManager.Instance:ExitReady() end
        self.leftCallback = function() ExquisiteShelfManager.Instance:OnTeam() end
    elseif phase == 2 then
        self.leftButton.transform.anchoredPosition = Vector2.zero
        self.rightButton.gameObject:SetActive(false)

        self.leftButtonText.text = TI18N("退 出")

        self.leftCallback = function() ExquisiteShelfManager.Instance:Exit() end
    elseif phase == 3 then
        self.leftButton.transform.anchoredPosition = Vector2.zero
        self.rightButton.gameObject:SetActive(false)

        self.leftButtonText.text = TI18N("退 出")

        self.leftCallback = function() ExquisiteShelfManager.Instance:Exit() end
    end
end

function MainuiTraceExquisiteShelf:ShowReward()
    -- local standardLev = RoleManager.Instance.RoleData.lev
    -- for k,member in pairs(TeamManager.Instance.memberTab) do
    --     if member.status == 1 then
    --         standardLev = member.lev
    --     end
    -- end

    -- local reward = nil
    -- for _,data in pairs(DataExquisiteShelf.data_group) do
    --     if standardLev >= data.min_lev and standardLev <= data.max_lev then
    --         reward = data.reward
    --         break
    --     end
    -- end
    local list = DataExquisiteShelf.data_reward[string.format("%s_%s", ExquisiteShelfManager.Instance:GetCurrentShelfLev(), self.model.shelfData.wave)].cost
    if #list == 1 then
        TipsManager.Instance:ShowItem({gameObject = self.battleRewardLoader.gameObjectm, itemData = DataItem.data_get[list[1][1]]})
    else
        self.tipsPanel:Show({list = list})
    end
end

function MainuiTraceExquisiteShelf:ReloadReward()
    local maxWave = ExquisiteShelfManager.Instance.model.shelfData.max_wave or 0
    local wave = ExquisiteShelfManager.Instance.model.shelfData.wave or 1
    local curWave = ExquisiteShelfManager.Instance:GetCurrentLevel()

    self.battleRewardText.gameObject:SetActive(false)

    if (curWave == 1 and maxWave < wave) or (curWave > 1 and maxWave < ExquisiteShelfManager.Instance.finalWave) then
        self.battleRewardLoader.gameObject.transform.anchoredPosition = Vector2(0, 0)
        self.battleRewardBg.anchoredPosition = Vector2(0, 0)
        self.battleRewardImage.gameObject:SetActive(false)
    else
        self.battleRewardLoader.gameObject.transform.anchoredPosition = Vector2(-37.6, 0)
        self.battleRewardBg.anchoredPosition = Vector2(-37.6, 0)
        self.battleRewardImage.gameObject:SetActive(true)
    end

    local list = DataExquisiteShelf.data_reward[string.format("%s_%s", ExquisiteShelfManager.Instance:GetCurrentShelfLev(), self.model.shelfData.wave or 1)].cost
    if #list == 1 then
        self.battleRewardLoader:SetSprite(SingleIconType.Item, DataItem.data_get[list[1][1]].icon)
    else
        self.battleRewardLoader:SetSprite(SingleIconType.Item, 21244)
    end
end

function MainuiTraceExquisiteShelf:SetConditionText(str)
    self.battleConditionExt:SetData(str)
    local size = self.battleConditionExt.contentTrans.sizeDelta
    self.battleConditionExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
    self.battleConditionObj.transform.sizeDelta = Vector2(size.x + 10, size.y + 10)
end
