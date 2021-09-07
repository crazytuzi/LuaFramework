--作者:hzf
--09/12/2016 21:18:54
--功能:冠军联赛追踪

MainuiTraceAnimalChess = MainuiTraceAnimalChess or BaseClass(BaseTracePanel)
function MainuiTraceAnimalChess:__init(main)
    self.main = main
    self.name = "MainuiTraceAnimalChess"
    self.resList = {
        {file = AssetConfig.mainui_trace_animal, type = AssetType.Main},
        {file = AssetConfig.teamquest, type = AssetType.Dep},
    }

    self.descString = TI18N([[1.每次操作可<color='#ffff00'>打开</color>一个箱子或将<color='#ffff00'>移动</color>自己单位一格
2.<color='#ffff00'>帅>将>校>尉>士>兵>帅</color>
3.同级单位<color='#ffff00'>先手</color>可击杀对方
4.回合上限为<color='#ffff00'>80</color>回合
5.占据<color='#ffff00'>更大优势</color>的一方将取得胜利!]])

    self.btnString1 = TI18N("求和")
    self.btnString2 = TI18N("认输")

    self.updateListener = function(status)  end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.isInit = false
end

function MainuiTraceAnimalChess:__delete()
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MainuiTraceAnimalChess:OnHide()
    self:RemoveListeners()
end

function MainuiTraceAnimalChess:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.updateListener)
end

function MainuiTraceAnimalChess:OnShow()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_event_change, self.updateListener)

    self.descText.text = self.descString
    self.bgTrans.sizeDelta = Vector2(226,218)
end

function MainuiTraceAnimalChess:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mainui_trace_animal))
    self.gameObject.name = "MainuiTraceAnimalChess"

    self.transform = self.gameObject.transform

    local transform = self.transform
    transform:SetParent(self.main.mainObj.transform)
    transform.localScale = Vector3.one
    transform.anchoredPosition = Vector2(0, -47)

    self.descText = self.transform:Find("ImgBg/Text"):GetComponent(Text)

    self.bgTrans = self.transform:Find("ImgBg")
    self.transform:Find("ImgBg/Exit"):GetComponent(Button).onClick:AddListener(function() AnimalChessManager.Instance:OnSurrender() end)
    self.transform:Find("ImgBg/Peace"):GetComponent(Button).onClick:AddListener(function() AnimalChessManager.Instance:WantPeace() end)

    self.isInit = true
    self:OnOpen()
end

function MainuiTraceAnimalChess:OnInitCompleted()
    self:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function MainuiTraceAnimalChess:Init()
end

