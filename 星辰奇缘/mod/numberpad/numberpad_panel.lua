NumberpadPanel = NumberpadPanel or BaseClass(BasePanel)

local function obj_size(trans)
    local half = nil
    if trans == nil then
        half = {w = 0, h = 0}
    else
        half = {w = trans.gameObject:GetComponent(RectTransform).rect.width/2, h = trans.gameObject:GetComponent(RectTransform).rect.height/2}
    end
    return half
end

function NumberpadPanel:__init(model)
    self.model = model
    self.name = "NumberpadWindow"

    self.resList = {
        {file = AssetConfig.number_pad, type = AssetType.Main}
        -- ,{file = AssetConfig.numberpad_textures, type = AssetType.Dep}
    }

    self.btnNumberList = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
    self.btnBackspace = nil
    self.btnReturn = nil
    self.btnAdd = nil
    self.btnMinus = nil
    self.textCount = nil
    self.coverPanelObj = nil
    self.bgPanel = nil
end

function NumberpadPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.number_pad))
    self.gameObject.name = "NumberPad"
    self.AddUIChild(self.model.parentObj, self.gameObject)
    -- self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.attach = self.gameObject.transform:Find("Attach")
    self.panel = self.attach:Find("Panel")
    self.arrow = self.attach:Find("Image")
    for i=1,9 do
        self.btnNumberList[i] = self.attach:Find("Panel/BtnPanel/"..tostring(i)).gameObject:GetComponent(Button)
        self.btnNumberList[i].onClick:RemoveAllListeners()
        self.btnNumberList[i].onClick:AddListener(function ()
            self.model:PressNum(i)
            self.model:CheckForResult()
            self:UpdateResultText()
            self.model:callback()
        end)
    end
    self.gameObject:GetComponent(Canvas).overrideSorting = false
    self.btnNumberList[10] = self.attach:Find("Panel/BtnPanel/0").gameObject:GetComponent(Button)
    self.btnNumberList[10].onClick:RemoveAllListeners()
    self.btnNumberList[10].onClick:AddListener(function ()
        self.model:PressNum(0)
        self.model:CheckForResult()
        self:UpdateResultText()
        self.model:callback()
    end)

    self.btnBackspace = self.attach:Find("Panel/BtnPanel/Backspace").gameObject:GetComponent(Button)
    self.btnBackspace.onClick:RemoveAllListeners()
    self.btnBackspace.onClick:AddListener(function ()
        self.model:Backspace()
        -- self.model:CheckForResult()
        self:UpdateResultText()
        self.model:callback()
    end)

    self.btnReturn = self.attach:Find("Panel/BtnPanel/Return").gameObject:GetComponent(Button)
    self.returnImage = self.attach:Find("Panel/BtnPanel/Return/Image"):GetComponent(Image)
    self.returnText = self.attach:Find("Panel/BtnPanel/Return/Text"):GetComponent(Text)
    self.btnReturn.onClick:RemoveAllListeners()
    self.btnReturn.onClick:AddListener(function ()
        if self.model.BuyIt ~= nil then
            self.model.BuyIt(self.model.result_show)
        end
        if not self.model.result_keep then
            self:OnCloseWindow()
        end
    end)

    self.bgPanel = self.gameObject.transform:Find("Panel").gameObject
    self.bgPanel:GetComponent(Button).onClick:AddListener(function ()
        self:OnCloseWindow()
    end)

    local rect = self.attach:Find("Panel"):GetComponent(RectTransform)
    self.coverPanelObj = self.attach:Find("CoverPanel").gameObject
    if self.model.return_text == nil then
        self.returnImage.gameObject:SetActive(true)
        self.returnText.gameObject:SetActive(false)
    else
        self.returnImage.gameObject:SetActive(false)
        self.returnText.gameObject:SetActive(true)
        self.returnText.text = self.model.return_text
    end
    if not self.model.boolContainCountPanel then
        self.attach:Find("Panel/NumericPanel").gameObject:SetActive(false)
        self.textCount = self.model.textObj
        rect.sizeDelta = Vector2(334.5, 261)
        self:SetPosition()
        self.coverPanelObj:SetActive(false)
        return
    end
    self.coverPanelObj:SetActive(true)
    rect.sizeDelta = Vector2(334.5, 321)
    self.attach:Find("Panel/NumericPanel").gameObject:SetActive(true)

    self.btnAdd = self.attach:Find("Panel/NumericPanel/Add").gameObject:GetComponent(Button)
    self.btnAdd.onClick:RemoveAllListeners()
    self.btnAdd.onClick:AddListener(function ()
        self.model:Add()
        self.model:CheckForResult()
        self:UpdateResultText()
        self.model:callback()
    end)

    self.btnMinus = self.attach:Find("Panel/NumericPanel/Minus").gameObject:GetComponent(Button)
    self.btnMinus.onClick:RemoveAllListeners()
    self.btnMinus.onClick:AddListener(function ()
        self.model:Minus()
        self.model:CheckForResult()
        self:UpdateResultText()
        self.model:callback()
    end)

    self.textCount = self.attach:Find("Panel/NumericPanel/InputField/Text").gameObject:GetComponent(Text)
    self.textCount.text = tostring(self.model.result_show)
    self:SetPosition()
end

function NumberpadPanel:UpdateResultText()
    self.textCount.text = tostring(self.model.result_show)
end

function NumberpadPanel:OnCloseWindow()
    self.model:Close()
end

function NumberpadPanel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function NumberpadPanel.AddUIChild(parentObj, childObj)
    local trans = childObj.transform
    trans:SetParent(parentObj.transform)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3.zero
    trans.localRotation = Quaternion.identity

    local rect = childObj:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero
    rect.localScale = Vector3.one
    rect.localPosition = Vector3.zero
    rect.anchoredPosition = Vector2.zero
    -- rect.sizeDelta = Vector2(ctx.ScreenWidth, ctx.ScreenHeight)
    childObj:SetActive(true)
end

function NumberpadPanel:SetPosition()
    local tempParent = self.model.attachObj.transform.parent
    local index = self.model.attachObj.transform:GetSiblingIndex()
    self.model.attachObj.transform:SetParent(self.gameObject.transform)

    local attachRect = self.model.attachObj:GetComponent(RectTransform)

    local panelRect = self.panel:GetComponent(RectTransform)    -- 数字面板Rect

    local scaleWidth = nil
    local scaleHeight = nil
    local width = 960
    local height = 540

    local screenWidth = ctx.ScreenWidth
    local screenHeight = ctx.ScreenHeight

    scaleWidth = width
    scaleHeight = width * screenHeight / screenWidth

    local size = attachRect.sizeDelta                           -- 绑定GameObject尺寸
    local pos = attachRect.anchoredPosition                     -- 绑定GameObject位置
    pos = Vector2(scaleWidth * attachRect.anchorMax.x - 0, scaleHeight * attachRect.anchorMax.y - 0) + pos

    local pivot = attachRect.pivot

    local panelSize = self.panel.sizeDelta
    local arrowSize = self.arrow.sizeDelta

    local scale = 0.8

    self.arrow.rotation = Quaternion.Euler(0, 0, 0)
    if scaleHeight - (pos.y + (1 - pivot.y) * size.y) >= panelSize.y + arrowSize.y * self.arrow.pivot.y then       -- 绑定GameObject的上边
        self.arrow.rotation = Quaternion.Euler(0, 0, 0)
        if panelRect.sizeDelta.x * scale < pos.x - size.x * pivot.x + size.x / 2 then
            self.arrow.anchoredPosition = Vector2(panelRect.sizeDelta.x * scale, 0)
            self.attach.anchoredPosition = Vector2(pos.x - size.x * (1 - pivot.x) + size.x / 2 - panelRect.sizeDelta.x * scale, pos.y + pivot.y * size.y + arrowSize.y * (1 - self.arrow.pivot.y))
        else
            self.arrow.anchoredPosition = Vector2(panelRect.sizeDelta.x * (1 - scale), 0)
            self.attach.anchoredPosition = Vector2(pos.x - size.x * (1 - pivot.x) + size.x / 2 - panelRect.sizeDelta.x * (1 - scale), pos.y + pivot.y * size.y + arrowSize.y * (1 - self.arrow.pivot.y))
        end
    elseif pos.y - pivot.y * size.y >= panelSize.y + arrowSize.y * self.arrow.pivot.y then             -- 绑定GameObject的下边
        self.arrow.rotation = Quaternion.Euler(0, 0, 180)
        if panelRect.sizeDelta.x * scale < pos.x - size.x * pivot.x + size.x / 2 then
            self.arrow.anchoredPosition = Vector2(panelRect.sizeDelta.x * scale, panelRect.sizeDelta.y)
            self.attach.anchoredPosition = Vector2(pos.x - size.x * (1 - pivot.x) + size.x / 2 - panelRect.sizeDelta.x * scale, pos.y - (panelSize.y + size.y * pivot.y + arrowSize.y * (1 - self.arrow.pivot.y)))
        else
            self.arrow.anchoredPosition = Vector2(panelRect.sizeDelta.x * (1 - scale), panelRect.sizeDelta.y)
            self.attach.anchoredPosition = Vector2(pos.x - size.x * (1 - pivot.x) + size.x / 2 - panelRect.sizeDelta.x * (1 - scale), pos.y - (panelSize.y + size.y * pivot.y + arrowSize.y * (1 - self.arrow.pivot.y)))
        end
    elseif scaleWidth - (pos.x + (1 - pivot.x) * size.x) >= panelSize.x + arrowSize.y * self.arrow.pivot.y then    -- 绑定GameObject的右边
        self.arrow.rotation = Quaternion.Euler(0, 0, 270)
        if panelRect.sizeDelta.y * scale < pos.y - size.y * pivot.y + size.y / 2 then
            self.arrow.anchoredPosition = Vector2(0, panelRect.sizeDelta.y * scale)
            self.attach.anchoredPosition = Vector2(pos.x + size.x * (1 - pivot.x) + arrowSize.y * self.arrow.pivot.y, pos.y + size.y * (1 - pivot.y) - size.y / 2 - panelRect.sizeDelta.y * scale)
        else
            self.arrow.anchoredPosition = Vector2(0, panelRect.sizeDelta.y * (1 - scale))
            self.attach.anchoredPosition = Vector2(pos.x + size.x * (1 - pivot.x) + arrowSize.y * self.arrow.pivot.y, pos.y + size.y * (1 - pivot.y) - size.y / 2 - panelRect.sizeDelta.y * (1 - scale))
        end
    elseif pos.x - pivot.x * size.x >= panelSize.x + arrowSize.y * self.arrow.pivot.y then             -- 绑定GameObject的左边
        self.arrow.rotation = Quaternion.Euler(0, 0, 90)
        if panelRect.sizeDelta.y * scale < pos.y - size.y * pivot.y + size.y / 2 then
            self.arrow.anchoredPosition = Vector2(panelRect.sizeDelta.x, panelRect.sizeDelta.y * scale)
            self.attach.anchoredPosition = Vector2(pos.x - size.x * pivot.x - arrowSize.y * self.arrow.pivot.y - panelRect.sizeDelta.x, pos.y + size.y * (1 - pivot.y) - size.y / 2 - panelRect.sizeDelta.y * scale)
        else
            self.arrow.anchoredPosition = Vector2(panelRect.sizeDelta.x, panelRect.sizeDelta.y * (1 - scale))
            self.attach.anchoredPosition = Vector2(pos.x - size.x * pivot.x - arrowSize.y * self.arrow.pivot.y - panelRect.sizeDelta.x, pos.y + size.y * (1 - pivot.y) - size.y / 2 - panelRect.sizeDelta.y * (1 - scale))
        end
    else
        print("<color='#ff0000'>WTF!!!!!!!——The numberpad can't be placed here!!!!!</color>")
    end

    self.model.attachObj.transform:SetParent(tempParent)
    self.model.attachObj.transform:SetSiblingIndex(index)
end

