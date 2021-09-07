-- 跨服擂台发起决斗窗口
-- ljh 20190329
CrossArenaFighterWindow = CrossArenaFighterWindow or BaseClass(BasePanel)

function CrossArenaFighterWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.CrossArenaFighterWindow

    self.resList = {
        {file = AssetConfig.crossarenafighterwindow, type = AssetType.Main},
        {file = AssetConfig.teamquest, type = AssetType.Dep},
    }

    -----------------------------------------------------------
    self.windowType = 1
    self.roomType = 1
    -----------------------------------------------------------
    
    self.levelMin = 1
    self.levelMax = 1

    self.selectEnemyPanel = nil
    -----------------------------------------------------------

    self.updateListener = function() self:Update() end

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function CrossArenaFighterWindow:__delete()
    self.OnHideEvent:Fire()

    if self.selectEnemyPanel ~= nil then
        self.selectEnemyPanel:DeleteMe()
        self.selectEnemyPanel = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CrossArenaFighterWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenafighterwindow))
    self.gameObject.name = "CrossArenaFighterWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    	
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform = self.transform:FindChild("Main")
    self.mainTransform:FindChild("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
    self.mainTransform.localPosition = Vector3(0, 0, -500)

    self.nameInput = self.mainTransform.transform:FindChild("NameInput"):GetComponent(InputField)
    self.nameInput.textComponent = self.nameInput.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.nameInput.placeholder = self.nameInput.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.nameInput.characterLimit = 15
    self.nameButton = self.mainTransform.transform:FindChild("NameButton"):GetComponent(Button)
    self.nameButton.onClick:AddListener(function() self:OnClickNameButton() end)
    self.nameInput.transform:FindChild("Placeholder"):GetComponent(Text).text = TI18N("请输入决斗对手名称，限本服")

    self.msgItemExt = MsgItemExt.New(self.mainTransform.transform:FindChild("Text"):GetComponent(Text), 350, 18, 34)
    self.msgItemExt:SetData(TI18N("1、发起决斗将消耗{assets_1, 90002, 500}并在本服公告传闻\n2、对方可在30分钟内应战，超时则算不战而胜\n3、战斗获胜可获得【决斗勇气礼盒】\n4、发起后房间将自动锁定，仅受邀人在对方队伍中才可开战，离开房间或下线则不返还任何费用或奖励"))

    self.okButton = self.mainTransform:FindChild("OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function() self:OnClickOkButton() end)
end

function CrossArenaFighterWindow:OnClickClose()
    self.model:CloseCrossArenaFighterWindow()
end

function CrossArenaFighterWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CrossArenaFighterWindow:OnOpen()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        
    end

    self:Update()

    -- StarChallengeManager.Instance.OnUpdateList:RemoveListener(self.updateListener)
    -- StarChallengeManager.Instance.OnUpdateList:AddListener(self.updateListener)
end

function CrossArenaFighterWindow:OnHide()
    -- StarChallengeManager.Instance.OnUpdateList:RemoveListener(self.updateListener)
end

function CrossArenaFighterWindow:Update()
    
end

function CrossArenaFighterWindow:OnClickNameButton()
    if self.selectEnemyPanel == nil then
        local setting = {
            ismulti = false,
            callback = function(list) self:OnSelectEnemy(list) end,
            list_type = 1,
            btnname = TI18N("确 定"),
            localPosition = Vector3(0, 0, -300)
        }
        self.selectEnemyPanel = FriendSelectPanel.New(self.gameObject, setting)
    end
    self.selectEnemyPanel:Show()
end

function CrossArenaFighterWindow:OnSelectEnemy(list)
    BaseUtils.dump(list[1])
    local data = list[1]
    if data ~= nil then
        self.nameInput.text = data.name
        self.data = data
    end
end

function CrossArenaFighterWindow:OnClickOkButton()
    if self.data ~= nil then
        CrossArenaManager.Instance:Send20733(self.data.id, self.data.platform, self.data.zone_id)
    elseif self.nameInput.text ~= "" then
        CrossArenaManager.Instance:Send20734(self.nameInput.text)
    end
    self:OnClickClose()
end
