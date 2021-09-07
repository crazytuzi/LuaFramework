ImproveWindow = ImproveWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function ImproveWindow:__init(model)
    self.model = model
    self.name = "ImproveWindow"
    self.improveMgr = self.model.improveMgr
    self.effectPath = "prefabs/effect/20107.unity3d"
    self.effect = nil
    self.resList = {
        {file = AssetConfig.improvewin, type = AssetType.Main}
    }

    if RoleManager.Instance.RoleData.lev <= 20 then
        table.insert(self.resList, {file = self.effectPath, type = AssetConfig.Main})
    end

    --------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end


function ImproveWindow:__delete()
    self:OnHide()
    self:ClearDepAsset()
end

function ImproveWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.improvewin))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.baseItem = self.transform:Find("Con/Mask/Button").gameObject
    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,border = 2
    }
    self.Con = self.transform:Find("Con")
    self.Con.anchoredPosition3D = Vector3(-755, -66, 0)
    self.itemCon = self.transform:Find("Con/Mask/Layout")
    self.layout = LuaBoxLayout.New(self.itemCon, setting1)
    self:UpdateLocat()
    self:InitList()
    if self.improveMgr.red ~= nil then
        self.improveMgr.red.gameObject:SetActive(false)
    end
    self.transform:Find("Con/GuidButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseWin() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {3, 1})
 end)

    GuideManager.Instance:OpenWindow(17)

    if RoleManager.Instance.RoleData.lev <= 20 and self:CheckGuide() then
        self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
        if self.effect ~= nil then
            local obj = self.layout.cellList[1]
            self.effect.name = "GuideEffect"
            local etras = self.effect.transform
            etras:SetParent(obj.transform)
            etras.localScale = Vector3.one
            etras.localPosition = Vector3(0, -20, -1500)
            Utils.ChangeLayersRecursively(etras, "UI")
            self.effect:SetActive(true)
            LuaTimer.Add(200, function()
                TipsManager.Instance:ShowGuide({gameObject = obj, data = TI18N("可以<color='#ffff00'>升级技能</color>啦"), forward = TipsEumn.Forward.Right})
            end)
        end
    end

    --------------------------------------
    self:OnShow()
end

function ImproveWindow:OnShow()
    local roleData = RoleManager.Instance.RoleData
    if roleData.lev >= 40 then
        BuffPanelManager.Instance.model:OpenPrewarPanel()
    end
end

function ImproveWindow:OnHide()
    BuffPanelManager.Instance.model:ClosePrewarPanel()
end

function ImproveWindow:OnBtnClose()
    self.model:CloseMyMain()
end

function ImproveWindow:UpdateLocat()
    if CombatManager.Instance.isFighting then
        self.Con.position = Vector3(-1.786962, 0.5484391,0.002625942)
    else
        local icon = MainUIManager.Instance.MainUIIconView:getbuttonbyid(17)
        self.Con.position = icon.transform.position
    end
end

function ImproveWindow:InitList()
    local data_List = self.improveMgr.lastList
    for i,v in ipairs(data_List) do
        local item = GameObject.Instantiate(self.baseItem)
        item.gameObject.name = v.name
        item.transform:Find("Text"):GetComponent(Text).text = v.name
        item.transform:GetComponent(Button).onClick:AddListener(function() v.func() end)
        self.layout:AddCell(item.gameObject)
    end

    if #data_List == 0 then
        self.Con.gameObject:SetActive(false)
    else
        self.Con.gameObject:SetActive(true)
    end
end

function ImproveWindow:CheckGuide()
    local quest = QuestManager.Instance:GetQuest(10170)
    if quest ~= nil and quest.finish == 1 then
        return true
    end

    local quest1 = QuestManager.Instance:GetQuest(22170)
    if quest1 ~= nil and quest1.finish == 1 then
        return true
    end

    return false
end
