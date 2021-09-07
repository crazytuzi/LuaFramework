MainuiTraceCrossArena = MainuiTraceCrossArena or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function MainuiTraceCrossArena:__init(main)
    self.main = main
    self.isInit = false

    self.resList = {
        {file = AssetConfig.crossarenatracecontent, type = AssetType.Main},
    }

    self._Update = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceCrossArena:__delete()
    self:RemoveListeners()
end

function MainuiTraceCrossArena:Init()
    self.isInit = true
end

function MainuiTraceCrossArena:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenatracecontent))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.panel = self.transform:Find("Panel")

    -- self.titleText1 = self.panel:Find("Title/Text"):GetComponent(Text)
    -- self.titleText2 = self.panel:Find("Title2/Text"):GetComponent(Text)

    self.panel:Find("Text"):GetComponent(Text).text = TI18N("1.<color='#ffff00'>创建房间</color>可与跨服玩家进行约战切磋\n2.<color='#ffff00'>发布战书</color>让所有跨服玩家可见，并寻找同实力对手\n3.战斗可使用<color='#ffff00'>擂台药品</color>，且战斗后不消耗变身次数")

    self.okButton = self.panel:Find("OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:OnClickOkButton() end)

    self.exitButton = self.panel:Find("ExitButton").gameObject
    self.exitButton:GetComponent(Button).onClick:AddListener(function() self:OnClickExitButton() end)
end

function MainuiTraceCrossArena:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceCrossArena:OnShow()
    -- self:RemoveListeners()
    -- StarChallengeManager.Instance.OnUpdateList:AddListener(self._Update)

    self:Update()
end

function MainuiTraceCrossArena:OnHide()
    self:RemoveListeners()
end

function MainuiTraceCrossArena:RemoveListeners()
    -- StarChallengeManager.Instance.OnUpdateList:RemoveListener(self._Update)
end

function MainuiTraceCrossArena:Update()

end

function MainuiTraceCrossArena:OnClickExitButton()
    CrossArenaManager.Instance:ExitScene()
end

function MainuiTraceCrossArena:OnClickOkButton()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.crossarenawindow)
end
