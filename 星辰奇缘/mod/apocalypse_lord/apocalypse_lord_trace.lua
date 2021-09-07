MainuiTraceApocalypseLord = MainuiTraceApocalypseLord or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function MainuiTraceApocalypseLord:__init(main)
    self.main = main
    self.isInit = false

    self.resList = {
        {file = AssetConfig.starchallenge_content, type = AssetType.Main},
    }

    self._Update = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceApocalypseLord:__delete()
    self:RemoveListeners()
end

function MainuiTraceApocalypseLord:Init()
    self.isInit = true
end

function MainuiTraceApocalypseLord:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.starchallenge_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.panel = self.transform:Find("Panel")
    self.panel2 = self.transform:Find("Panel2")

    self.titleText1 = self.panel:Find("Title/Text"):GetComponent(Text)
    self.titleText2 = self.panel2:Find("Title/Text"):GetComponent(Text)

    self.descText1_panel = self.panel:Find("Content/DescText"):GetComponent(Text)
    self.descText1_panel2 = self.panel2:Find("Content/DescText"):GetComponent(Text)

    self.descText2_panel = self.panel:Find("Content/DescText2"):GetComponent(Text)
    self.descText2_panel2 = self.panel2:Find("Content/DescText2"):GetComponent(Text)

    self.rankButton = self.panel:Find("RankButton").gameObject
    self.rankButton:GetComponent(Button).onClick:AddListener(function() self:OnClickRankButton() end)

    self.exitButton = self.panel:Find("ExitButton").gameObject
    self.exitButton:GetComponent(Button).onClick:AddListener(function() self:OnClickExitButton() end)

    self.rankButton = self.panel2:Find("RankButton").gameObject
    self.rankButton:GetComponent(Button).onClick:AddListener(function() self:OnClickRankButton() end)

    self.exitButton2 = self.panel2:Find("ExitButton").gameObject
    self.exitButton2:GetComponent(Button).onClick:AddListener(function() self:OnClickExitButton() end)

    self.transform:Find("Panel/Content"):GetComponent(Button).onClick:AddListener(function() self:OnClickPanelButton() end)
    self.transform:Find("Panel2/Content"):GetComponent(Button).onClick:AddListener(function() self:OnClickPanelButton() end)

end

function MainuiTraceApocalypseLord:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceApocalypseLord:OnShow()
    self:RemoveListeners()
    ApocalypseLordManager.Instance.OnUpdateList:AddListener(self._Update)

    self:Update()
end

function MainuiTraceApocalypseLord:OnHide()
    self:RemoveListeners()
end

function MainuiTraceApocalypseLord:RemoveListeners()
    ApocalypseLordManager.Instance.OnUpdateList:RemoveListener(self._Update)
end

function MainuiTraceApocalypseLord:Update()
    if ApocalypseLordManager.Instance.model.status == 3 then
        self.panel2.gameObject:SetActive(true)
        self.panel.gameObject:SetActive(false)
        self:UpdatePanel2()
    else
        self.panel.gameObject:SetActive(true)
        self.panel2.gameObject:SetActive(false)
        self:UpdatePanel()
    end
end

function MainuiTraceApocalypseLord:UpdatePanel()
    self.titleText1.text = TI18N("天启试练")
    self.descText1_panel.text = TI18N("1.通过任一<color='#ffff00'>门徒</color>考验后可获得天启<color='#ffff00'>挑战资格</color>\n2.龙王、天启资格获得会<color='#ffff00'>相互顶替</color>，以最后挑战的资格为准\n3.每位门徒对应的<color='#ffff00'>挑战资格</color>有限，只有<color='#ffff00'>最近通过挑战</color>的8支队伍可获得")
    self.descText2_panel.text = TI18N("挑战截止时间：<color='#ffff00'>周五12点</color>")
end

function MainuiTraceApocalypseLord:UpdatePanel2()
    self.titleText2.text = TI18N("天启入侵")
    self.descText1_panel2.text = TI18N("1.队伍中<color='#ffff00'>所有人都拥有挑战资格</color>则可挑战天启\n2.天启战斗有多个阶段,<color='#ffff00'>通过的阶段越多</color>奖励越丰富\n3.挑战奖励将在<color='#ffff00'>周一5点</color>通过邮件发放")
    self.descText2_panel2.text = TI18N("挑战截止时间：<color='#ffff00'>周日24点</color>")
end

function MainuiTraceApocalypseLord:OnClickExitButton()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    local name = TI18N("天启试练")
    if ApocalypseLordManager.Instance.model.status == 3 then
    	name = TI18N("天启入侵")
    end
    confirmData.content = string.format(TI18N("你是否要退出%s？"), name)
    confirmData.sureLabel = TI18N("确认")
    confirmData.cancelLabel = TI18N("取消")
    -- confirmData.cancelSecond = 30
    confirmData.sureCallback = function()
            ApocalypseLordManager.Instance:Send20802()
        end

    NoticeManager.Instance:ConfirmTips(confirmData)
end

function MainuiTraceApocalypseLord:OnClickRankButton()
	-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, { 1, 65 })
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ApocalypseLordwindow, {2, false})
end

function MainuiTraceApocalypseLord:OnClickPanelButton()
    local model = ApocalypseLordManager.Instance.model
    if model.status == 2 then
        model:OpenWindow({1, 0})
    elseif model.status == 3 then
        model:OpenWindow({1, -1, 1})
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动暂未开放，请耐心等待{face_1,3}"))
    end
end
