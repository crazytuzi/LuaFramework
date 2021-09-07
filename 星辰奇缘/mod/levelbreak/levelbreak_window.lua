-- ----------------------------------------------------------
-- UI - 等级突破窗口
-- xjlong 20160907
-- ----------------------------------------------------------
LevelBreakWindow = LevelBreakWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function LevelBreakWindow:__init(model)
    self.model = model
    self.name = "LevelBreakWindow"
    self.windowId = WindowConfig.WinID.levelbreakwindow
    self.winLinkType = WinLinkType.Single
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.btnEffect = "prefabs/effect/20119.unity3d"

    self.resList = {
        {file = AssetConfig.levelbreakwindow, type = AssetType.Main}
        ,{file = AssetConfig.levelbreak_texture, type = AssetType.Dep}
        ,{file = AssetConfig.handbook_res, type = AssetType.Dep}
        ,{file = AssetConfig.ride_texture, type = AssetType.Dep}
        ,{file = self.btnEffect, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	self.breakPanelItemList = {}
	self.targetPanelItemList = {}
	------------------------------------------------

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function LevelBreakWindow:__delete()
    self:OnHide()

    if self.item_slot ~= nil then
        self.item_slot:DeleteMe()
        self.item_slot = nil
    end

    if self.gameObject ~= nil then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function LevelBreakWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.levelbreakwindow))
    self.gameObject.name = "LevelBreakWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.container_breakPanel = self.mainTransform:FindChild("BreakPanel/mask/Container")
    self.itemobject_breakPanel = self.container_breakPanel:FindChild("Item").gameObject
    self.itemobject_breakPanel:SetActive(false)

    local setting1 = {
        column = 2
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 210
        ,cellSizeY = 74
    }
    self.grid_breakPanel = LuaGridLayout.New(self.container_breakPanel, setting1)

    self.container_targetPanel = self.mainTransform:FindChild("TargetPanel/mask/Container")
    self.itemobject_targetPanel = self.container_targetPanel:FindChild("Item").gameObject
    self.itemobject_targetPanel:SetActive(false)

    local setting2 = {
        axis = BoxLayoutAxis.Y
    }
    self.box_targetPanel = LuaBoxLayout.New(self.container_targetPanel, setting2)

    self.tipsButton = self.mainTransform:FindChild("BreakPanel/TipsButton").gameObject
    self.tipsButton:GetComponent(Button).onClick:AddListener(function() self:ShowTips() end)

    self.breakButton = self.mainTransform:FindChild("TargetPanel/BreakButton").gameObject
    self.breakButton:GetComponent(Button).onClick:AddListener(function() self:OnBreakButtonClick() end)

    self.item_slot = ItemSlot.New()
    UIUtils.AddUIChild(self.mainTransform:FindChild("TargetPanel/ItemSolt").gameObject, self.item_slot.gameObject)
    self.costName = self.mainTransform:FindChild("TargetPanel/IconNum"):GetComponent(Text)

    self.BreakEffect = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.BreakEffect.transform:SetParent(self.breakButton.transform)
    self.BreakEffect.transform.localScale = Vector3(1, 1, 1)
    self.BreakEffect.transform.localPosition = Vector3(0, 0, -1000)
    Utils.ChangeLayersRecursively(self.BreakEffect.transform, "UI")
    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

function LevelBreakWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function LevelBreakWindow:OnShow()
    LevelBreakManager.Instance:send17400()
    --self:Update()
end

function LevelBreakWindow:OnHide()

end

function LevelBreakWindow:Update()
	self:Update_BreakPanel()
	self:Update_TargetPanel()
end

function LevelBreakWindow:Update_BreakPanel()
    self.grid_breakPanel:ReSet()
    local count = #DataLevBreak.data_lev_break_effect
	for i = 1, count do
        local data = DataLevBreak.data_lev_break_effect[i]
        local breakPanelItem = self.breakPanelItemList[i]
        if breakPanelItem == nil then
            local item = GameObject.Instantiate(self.itemobject_breakPanel)
            item:SetActive(true)
            self.grid_breakPanel:AddCell(item)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

            breakPanelItem = {}
            self.breakPanelItemList[i] = breakPanelItem
            breakPanelItem.obj = item
            breakPanelItem.title = item.transform:FindChild("Title"):GetComponent(Text)
            breakPanelItem.desc = item.transform:FindChild("Desc"):GetComponent(Text)

            local button = item:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:OnBreakPanelItemclick(item, data.tips) end)
        end
        if data ~= nil then
            breakPanelItem.obj:SetActive(true)
            breakPanelItem.obj.name = tostring(data.id)
            breakPanelItem.title.text = data.title
            breakPanelItem.desc.text = data.desc
        end
    end
end

function LevelBreakWindow:Update_TargetPanel()
    if self.model.targetData == nil then return end

    local times = self.model.targetData.times + 1
    local breakdata = DataLevBreak.data_lev_break_times[times]
    if breakdata == nil then return end

    self.box_targetPanel:ReSet()
    local costInfo = breakdata.loss[RoleManager.Instance.RoleData.classes]
    local hasNum = BackpackManager.Instance:GetItemCount(costInfo[2])
    local itemData = BackpackManager.Instance:GetItemBase(costInfo[2])

    itemData.quantity = hasNum
    itemData.need = costInfo[3]
    self.item_slot:SetAll(itemData)
    self.costName.text = itemData.name

    self.breakGoalTab = {}
    for k,v in ipairs(self.model.targetData.goals) do
        local data = DataLevBreak.data_lev_break_goal[times.."_"..v.id]
        if data then
            local value = {}
            value.goal = v
            value.data = data
            table.insert(self.breakGoalTab, value)
        end
    end

    table.sort(self.breakGoalTab, function(a,b) return a.data.sortIndex < b.data.sortIndex end)

    for i,v in ipairs(self.breakGoalTab) do
        local targetPanelItem
        if v.data.id == 1001 then
            targetPanelItem = self:GetTargetItem(i, v.data.action)
            targetPanelItem.desc.text = string.format(TI18N("%s<color='#ffff9a'>(%d/%d)</color>"), v.data.desc, v.goal.progress[1].value, v.goal.progress[1].target_val)
        elseif v.data.id == 1002 then
            targetPanelItem = self:GetTargetItem(i, "9999:")
            if v.goal.finish == 1 then
                targetPanelItem.desc.text = v.data.desc
            else
                targetPanelItem.desc.text = string.format(TI18N("%s<color='#ffff9a'>(0/1)</color>"), v.data.desc)
            end
        elseif v.data.id == 1008 then--1008为挑战目标
            targetPanelItem = self:GetTargetItem(i, "9998:")
            if v.goal.finish == 1 then
                targetPanelItem.desc.text = v.data.desc
            else
                targetPanelItem.desc.text = string.format(TI18N("%s<color='#ffff9a'>(0/1)</color>"), v.data.desc)
            end
        else
            targetPanelItem = self:GetTargetItem(i, v.data.action)
            targetPanelItem.desc.text = v.data.desc
        end

        targetPanelItem.obj.name = tostring(v.data.id)
        targetPanelItem.name.text = v.data.name
        if v.goal.finish == 1 then
            targetPanelItem.gotoBtn:SetActive(false)
            targetPanelItem.finishImage:SetActive(true)
            targetPanelItem.RedPointImage:SetActive(false)
            targetPanelItem.GreenPointImage:SetActive(true)
        else
            targetPanelItem.gotoBtn:SetActive(true)
            targetPanelItem.finishImage:SetActive(false)
            targetPanelItem.RedPointImage:SetActive(true)
            targetPanelItem.GreenPointImage:SetActive(false)
        end
    end

    if self.model:CheckAllQuestFinished() and hasNum >= costInfo[3] then
        self.BreakEffect:SetActive(true)
    else
        self.BreakEffect:SetActive(false)
    end
end

function LevelBreakWindow:GetTargetItem(i, action)
    local targetPanelItem = self.targetPanelItemList[i]
    if targetPanelItem == nil then
        local item = GameObject.Instantiate(self.itemobject_targetPanel)
        item:SetActive(true)
        self.box_targetPanel:AddCell(item)
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

        targetPanelItem = {}
        self.targetPanelItemList[i] = targetPanelItem
        targetPanelItem.obj = item
        targetPanelItem.desc = item.transform:FindChild("Desc"):GetComponent(Text)
        targetPanelItem.name = item.transform:FindChild("Name"):GetComponent(Text)
        targetPanelItem.gotoBtn = item.transform:FindChild("GotoButton").gameObject
        targetPanelItem.finishImage = item.transform:FindChild("Finish").gameObject
        targetPanelItem.RedPointImage = item.transform:FindChild("RedPoint").gameObject
        targetPanelItem.GreenPointImage = item.transform:FindChild("GreenPoint").gameObject

        local button = targetPanelItem.gotoBtn:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:OnGoto(action) end)
    end

    return targetPanelItem
end

function LevelBreakWindow:OnBreakPanelItemclick(item, tips)
    TipsManager.Instance:ShowText({gameObject = item
            , itemData = {tips}
            })
end

function LevelBreakWindow:ShowTips()
    TipsManager.Instance:ShowText({gameObject = self.tipsButton
            , itemData = {
                TI18N("1、完成所有<color='#ffff00'>突破目标</color>后可进行突破")
                , TI18N("2、突破后变为<color='#ffff00'>1转95级</color>，开放<color='#ffff00'>110</color>级上限")
                , TI18N("3、突破后减少<color='#ffff00'>25个属性点</color>，升级<color='#ffff00'>额外重获</color>属性点")
                , TI18N("4、突破后依旧<color='#ffff00'>可以携带</color>原来的宠物，但宠物等级超过自身当前5级后将<color='#ffff00'>无法获得</color>经验")
                }
            })
end

function LevelBreakWindow:OnBreakButtonClick()
    if self.model:CheckAllQuestFinished() then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() LevelBreakManager.Instance:send17401() end
        --confirmData.sureCallback = function() LevelBreakManager.Instance:on17401() end

        confirmData.content = TI18N("突破后变为<color='#ffff00'>1转95级</color>，开放<color='#ffff00'>110</color>级上限")
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("达成所有目标后可突破"))
    end
end

function LevelBreakWindow:OnGoto(action)
    local strList = StringHelper.Split(action, ":")
    local type = strList[1]
    strList = StringHelper.Split(strList[2], ",")

    if type == "1" then
        local args = {}
        for i=2,#strList do
            table.insert(args, tonumber(strList[i]))
        end
        WindowManager.Instance:OpenWindowById(tonumber(strList[1]), args)
        WindowManager.Instance:CloseWindow(self)
    elseif type == "2" then
        QuestManager.Instance.model:FindNpc(strList[1].."_"..strList[2])
        WindowManager.Instance:CloseWindow(self)
    elseif type == "9998" then
        if self.model:CheckChallenge() then
            local data = DataLevBreak.data_lev_break_boss[73030]
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.map, "73030_36", nil, nil, true)
            WindowManager.Instance:CloseWindow(self)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请完成其他目标后再挑战心魔"))
        end
    elseif type == "9999" then--9999用于boss特殊
        if self.model:CheckWolrdCollected() then
            local data = DataLevBreak.data_lev_break_boss[73020]
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.map, "73020_36", nil, nil, true)
            WindowManager.Instance:CloseWindow(self)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("收集目标未完成"))
        end
    end
end
