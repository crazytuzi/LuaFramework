Marry_BeProposeView = Marry_BeProposeView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_BeProposeView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_bepropose_window
    self.name = "Marry_BeProposeView"
    self.resList = {
        {file = AssetConfig.marry_bepropose_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.text = nil
    self.itemSolt = nil
    self.okButton = nil
    self.noButton = nil

    self.data = nil

    self.time_text = nil
    self.time_count = 0
    self.timer_id = nil
    -----------------------------------------
    self._TimeUpdate = function() self:TimeUpdate() end
end

function Marry_BeProposeView:__delete()
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end

    if self.timer_id ~= nil then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = nil
    end
    self:ClearDepAsset()
end

function Marry_BeProposeView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_bepropose_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.text = self.transform:FindChild("Main/Mask/Text"):GetComponent(Text)
    self.time_text = self.transform:FindChild("Main/TimeText"):GetComponent(Text)
    self.time_text.gameObject:SetActive(false)

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/Item").gameObject, self.itemSolt.gameObject)

    self.okButton = self.transform:FindChild("Main/OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function() self:okButtonClick() end)

    self.noButton = self.transform:FindChild("Main/NoButton"):GetComponent(Button)
    self.noButton.onClick:AddListener(function() self:noButtonClick() end)

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.data = self.openArgs[1]
        self:Update()
    end

    self.time_count = 90
    -- self.timer_id = LuaTimer.Add(5, 1000, self._TimeUpdate)

    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.transform:FindChild("Main/OkButton"))
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(-50, 28, -10)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    BaseEffectView.New({effectId = 20118, time = nil, callback = fun})
end

function Marry_BeProposeView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_bepropose_window)
end

function Marry_BeProposeView:Update()
	self.text.text = string.format(TI18N("<color='#00ff00'>%s</color>手拿钻戒，单膝下跪深情的对你说：<color='#ff3333'>%s</color>"), self.data.name, self.data.str)

	local itembase = BackpackManager.Instance:GetItemBase(20044)
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    self.itemSolt:SetAll(itemData)
    self.itemSolt:ShowBg(false)

end

function Marry_BeProposeView:TimeUpdate()
    self.time_text.text = string.format(TI18N("<color='#00ff00'>%s</color>秒后自动拒绝"), self.time_count)
    self.time_count = self.time_count - 1
    if self.time_count == 0 then
        self:noButtonClick()
    end
end

function Marry_BeProposeView:okButtonClick()
    if self.data == nil then return end
    MarryManager.Instance:Send15002(self.data.id, self.data.platform, self.data.zone_id, 1)
	self:Close()
end

function Marry_BeProposeView:noButtonClick()
    if self.data == nil then return end
    MarryManager.Instance:Send15002(self.data.id, self.data.platform, self.data.zone_id, 0)
	self:Close()
end