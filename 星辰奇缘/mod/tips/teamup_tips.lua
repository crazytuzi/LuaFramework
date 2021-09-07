-- ------------------------------
-- 道具tips
-- hzf
-- ------------------------------
TeamUpTips = TeamUpTips or BaseClass(BaseTips)

function TeamUpTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.teamup_tips, type = AssetType.Main},
        {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }
    self.mgr = TipsManager.Instance
    self.gameObject = nil

    self.Lcall = nil
    self.Mcall = nil
    self.Rcall = nil

end

function TeamUpTips:__delete()
    self.mgr = nil
end

function TeamUpTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamup_tips))
    self.gameObject.name = "TeamUpTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform:SetSiblingIndex(1)
    self.transform:Find("Main/CloseButton").anchoredPosition = Vector2(221,110)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.DescCom = self.transform:Find("Main/Con/DescText"):GetComponent(Text)
    self.descExt = MsgItemExt.New(self.DescCom, 257, 17, 30)
    self.Lbtn = self.transform:Find("Main/Con/Left"):GetComponent(Button)
    self.Rbtn = self.transform:Find("Main/Con/Right"):GetComponent(Button)
    self.Mbtn = self.transform:Find("Main/Con/Mid"):GetComponent(Button)

    self.LText = self.transform:Find("Main/Con/LText"):GetComponent(Text)
    self.MText = self.transform:Find("Main/Con/MText"):GetComponent(Text)
    self.RText = self.transform:Find("Main/Con/RText"):GetComponent(Text)
    self.LText.supportRichText = true
    self.MText.supportRichText = true
    self.RText.supportRichText = true

    self.LGreen = self.transform:Find("Main/Con/Left/Icon").gameObject
    self.MGreen = self.transform:Find("Main/Con/Mid/Icon").gameObject
    self.RGreen = self.transform:Find("Main/Con/Right/Icon").gameObject

    self.Lbtn.onClick:AddListener(function()
        if self.Lcall ~= nil then
            self.Lcall()
        end
        self:Hiden()
    end)
    self.Mbtn.onClick:AddListener(function()
        if self.Mcall ~= nil then
            self.Mcall()
        end
        self:Hiden()
    end)
    self.Rbtn.onClick:AddListener(function()
        if self.Rcall ~= nil then
            self.Rcall()
        end
        self:Hiden()
    end)
end

-- {
--     Desc = "说啥呢"
--     Ltxt = "",
--     Mtxt = "",
--     Rtxt = "",
--     LGreen = false,
--     MGreen = false,
--     RGreen = false,
--     LCallback = nil,
--     MCallback = nil,
--     RCallback = nil,
-- }

function TeamUpTips:SetData(data)
    -- self.DescCom.text = data.Desc
    self.descExt:SetData(data.Desc)
    self.LText.text = data.Ltxt
    self.MText.text = data.Mtxt
    self.RText.text = data.Rtxt
    self.LText.gameObject:SetActive(data.Ltxt ~= nil and data.Ltxt ~= "")
    self.MText.gameObject:SetActive(data.Mtxt ~= nil and data.Mtxt ~= "")
    self.RText.gameObject:SetActive(data.Rtxt ~= nil and data.Rtxt ~= "")
    self.LGreen:SetActive(data.LGreen == true)
    self.MGreen:SetActive(data.MGreen == true)
    self.RGreen:SetActive(data.RGreen == true)
    if data.LGreen then
        local r,g,b = CombatUtil.TryParseHtmlString(ColorHelper.ButtonLabelColor.Green)
        self.LText.color = Color(r/255, g/255, b/255)
    else
        local r,g,b = CombatUtil.TryParseHtmlString(ColorHelper.ButtonLabelColor.Green)
        self.LText.color = Color(r/255, g/255, b/255)
    end
    if data.MGreen then
        local r,g,b = CombatUtil.TryParseHtmlString(ColorHelper.ButtonLabelColor.Green)
        self.MText.color = Color(r/255, g/255, b/255)
    else
        local r,g,b = CombatUtil.TryParseHtmlString(ColorHelper.ButtonLabelColor.Blue)
        self.MText.color = Color(r/255, g/255, b/255)
    end
    if data.RGreen then
        local r,g,b = CombatUtil.TryParseHtmlString(ColorHelper.ButtonLabelColor.Green)
        self.RText.color = Color(r/255, g/255, b/255)
    else
        local r,g,b = CombatUtil.TryParseHtmlString(ColorHelper.ButtonLabelColor.Blue)
        self.RText.color = Color(r/255, g/255, b/255)
    end

    self.Lbtn.gameObject:SetActive(data.Ltxt ~= nil and data.Ltxt ~= "")
    self.Rbtn.gameObject:SetActive(data.Rtxt ~= nil and data.Rtxt ~= "")
    self.Mbtn.gameObject:SetActive(data.Mtxt ~= nil and data.Mtxt ~= "")

    self.Lcall = data.LCallback
    self.Mcall = data.MCallback
    self.Rcall = data.RCallback
end