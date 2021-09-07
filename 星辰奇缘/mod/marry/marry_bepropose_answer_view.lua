Marry_BeProposeAnswerView = Marry_BeProposeAnswerView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_BeProposeAnswerView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_propose_answer_window
    self.name = "Marry_BeProposeAnswerView"
    self.resList = {
        {file = AssetConfig.marry_propose_answer_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.text1 = nil
    self.text2 = nil

    self.itemSolt = nil

    self.data = nil
    -----------------------------------------
end

function Marry_BeProposeAnswerView:__delete()
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end
    self:ClearDepAsset()
end

function Marry_BeProposeAnswerView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_propose_answer_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function()
            self:Close()
            NoticeManager.Instance:FloatTipsByString(TI18N("可以前往圣心城-丘比特进行申请举办典礼"))
            MarryManager.Instance:Send15008(0)
        end)

    self.text1 = self.transform:FindChild("Main/Panel1/Text"):GetComponent(Text)
    self.text2 = self.transform:FindChild("Main/Panel2/Text"):GetComponent(Text)

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/Panel2/Item").gameObject, self.itemSolt.gameObject)

    local btn = nil
    btn = self.transform:FindChild("Main/Panel1/WeddingLaterButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:WeddingLaterButtonClick() end)

    btn = self.transform:FindChild("Main/Panel1/WeddingNowButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:WeddingNowButtonClick() end)

    -- btn = self.transform:FindChild("Main/Panel1/TeamButton"):GetComponent(Button)
    -- btn.onClick:AddListener(function() self:TeamButtonClick() end)
    -- btn.gameObject:SetActive(false)
    btn = self.transform:FindChild("Main/Panel2/Button"):GetComponent(Button)
    btn.onClick:AddListener(function() self:Close() end)

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.data = self.openArgs[1]
        self:Update()
    end
end

function Marry_BeProposeAnswerView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_propose_answer_window)
end

function Marry_BeProposeAnswerView:Update()
	if self.data.type == 2 then
        self.transform:FindChild("Main/Panel1").gameObject:SetActive(true)
        self.transform:FindChild("Main/Panel2").gameObject:SetActive(false)
        self.text1.text = string.format(TI18N("恭喜你！<color='#00ff00'>%s</color>答应了你的结缘申请，已经成为你的有缘人，举办典礼后你们将成为合法伴侣！"), self.data.name)

        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.transform:FindChild("Main/Panel1/WeddingNowButton"))
            effectObject.transform.localScale = Vector3(1, 1, 1)
            effectObject.transform.localPosition = Vector3(-50, 28, -10)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        BaseEffectView.New({effectId = 20118, time = nil, callback = fun})
    else
        self.transform:FindChild("Main/Panel1").gameObject:SetActive(false)
        self.transform:FindChild("Main/Panel2").gameObject:SetActive(true)
        self.text2.text = string.format(TI18N("很遗憾！<color='#00ff00'>%s</color>十分感动，但还是拒绝了你的结缘申请，同时给你发了一张好人卡，不要伤心，前方还有更广阔的花丛在等待你！"), self.data.name)
        local itembase = BackpackManager.Instance:GetItemBase(20047)
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        self.itemSolt:SetAll(itemData)
        -- self.itemSolt:ShowBg(false)
    end
end

function Marry_BeProposeAnswerView:WeddingLaterButtonClick()
    NoticeManager.Instance:FloatTipsByString(TI18N("可以前往圣心城-丘比特进行申请举办典礼"))
    MarryManager.Instance:Send15008(0)
    self:Close()
end

function Marry_BeProposeAnswerView:WeddingNowButtonClick()
    self:Close()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_wedding_window, { self.data })
end

function Marry_BeProposeAnswerView:TeamButtonClick()
    -- TeamManager.Instance:Send11708()
    TeamManager.Instance:Send11702(self.data.id, self.data.platform, self.data.zone_id)
end