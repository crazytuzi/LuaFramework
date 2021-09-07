AnimalChessOperation = AnimalChessOperation or BaseClass(BasePanel)

function AnimalChessOperation:__init(model)
    self.model = model
    self.name = "AnimalChessOperation"
    self.resList = {
        {file = AssetConfig.animal_chess_operation, type = AssetType.Main}
    }

    self.originAreaPos = Vector2(-10, -12)
    self.traceListener = function() self:HideOrShowTrace() end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function AnimalChessOperation:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.animal_chess_operation))
    self.gameObject.name = self.name

    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

    local skillArea = self.transform:Find("SkillArea")
    self.slotList = {}
    for i=1,2 do
        local tab = {}
        tab.transform = skillArea:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        tab.image = SingleIconLoader.New(tab.transform:Find("Image").gameObject)
        tab.button = tab.gameObject:GetComponent(Button)
        self.slotList[i] = tab
    end
    self.skillContainer = skillArea

    self.slotList[1].nameText.text = TI18N("投降")
    self.slotList[2].nameText.text = TI18N("求和")

    self.slotList[1].button.onClick:AddListener(function() AnimalChessManager.Instance:OnSurrender() end)
    self.slotList[2].button.onClick:AddListener(function() AnimalChessManager.Instance:WantPeace() end)

    self.slotList[1].image:SetSprite(SingleIconType.SkillIcon, 60156)
    self.slotList[2].image:SetSprite(SingleIconType.SkillIcon, 60161)

    self:AdaptIPhoneX()
end

function AnimalChessOperation:__delete()
    self.OnHideEvent:Fire()
    for _,v in pairs(self.slotList) do
        if v ~= nil then
            v.image:DeleteMe()
        end
    end
    self:AssetClearAll()
end

function AnimalChessOperation:OnInitCompleted()
    self:OnShow()
end

function AnimalChessOperation:OnShow()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.trace_quest_hide, self.traceListener)
    EventMgr.Instance:AddListener(event_name.trace_quest_show, self.traceListener)

    self.skillContainer.anchoredPosition = self.originAreaPos
    self:HideOrShowTrace()
end

function AnimalChessOperation:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.trace_quest_hide, self.traceListener)
    EventMgr.Instance:RemoveListener(event_name.trace_quest_show, self.traceListener)
end

function AnimalChessOperation:HideOrShowTrace()
    local show = (MainUIManager.Instance.mainuitracepanel ~= nil) and (MainUIManager.Instance.mainuitracepanel.isShow == true)
    self.skillContainer.gameObject:SetActive(not show)
end

function AnimalChessOperation:OnHide()
    self:RemoveListeners()
end

function AnimalChessOperation:AdaptIPhoneX()
    if MainUIManager.Instance.adaptIPhoneX then
        if Screen.orientation == ScreenOrientation.LandscapeRight then
            self.originAreaPos = Vector2(-10, -12)
        else
            self.originAreaPos = Vector2(-50, -12)
        end
    else
        self.originAreaPos = Vector2(-10, -12)
    end
end

