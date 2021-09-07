RulesTips = RulesTips or BaseClass(BaseTips)

function RulesTips:__init(model)
    self.model = model

    self.resList = {
        {file = AssetConfig.rule_tips, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.maxWidth = 400
    self.width = 50
    self.height = 50
    self.buttons = {}
    self.DefaultSize = Vector2(315, 0)
    self.lastTime = 0

    self.msgExtTab = {}

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
end

function RulesTips:__delete()
    self.mgr = nil
    for k,v in pairs(self.msgExtTab) do
        if v ~= nil then
            v:DeleteMe()
            self.msgExtTab[k] = nil
        end
    end
    self.msgExtTab = nil
    self.height = 20
    self:RemoveTime()
end

function RulesTips:RemoveTime()
    self.mgr.updateCall = nil
end

function RulesTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rule_tips))
    self.gameObject.name = "RulesTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.rect = self.gameObject:GetComponent(RectTransform)

    local btn = self.gameObject:GetComponent(Button)
    if btn == nil then
        btn = self.gameObject:AddComponent(Button)
    end
    btn.onClick:AddListener(function()
        self.model:Closetips()
    end)

    self.titleText = self.transform:Find("Title/Text"):GetComponent(Text)
    self.textExt = MsgItemExt.New(self.transform:Find("Text"):GetComponent(Text), 400, 18, 20.85)
end

function RulesTips:UpdateInfo(info)
    -- self:Default()

    self.itemData = info

    self.width = info.width or 500
    local width = self.width - 40
    self.textExt.selfWidth = width
    self.textExt.txtMaxWidth = width
    self.textExt:SetData(info.text)

    self.height = self.textExt.contentTrans.sizeDelta.y + 55 + 20
    self.transform.sizeDelta = Vector2(self.width, self.height)
    self.titleText.text = info.title
    self.mgr.updateCall = self.updateCall
end

function RulesTips:UnRealUpdate()
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end