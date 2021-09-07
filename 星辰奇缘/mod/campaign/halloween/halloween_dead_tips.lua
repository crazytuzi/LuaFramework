-- 万圣节南瓜精死亡倒计时
-- ljh  20161026

HalloweenDeadTips = HalloweenDeadTips or BaseClass(BaseView)

function HalloweenDeadTips:__init(model)
    self.model = model
    self.name = "HalloweenDeadTips"
    self.windowId = WindowConfig.WinID.halloweendeadtips

    self.resList = {
        {file = AssetConfig.halloweendeadtips, type = AssetType.Main},
        -- {file = AssetConfig.halloween_textures, type = AssetType.Dep},
    }

    --------------------------------------
    self.timerId = nil
    self.cooldown_time = 0
    --------------------------------------
    self._Update = function()
        self:Update()
    end
    self:LoadAssetBundleBatch()
end

function HalloweenDeadTips:__delete()
    self:Hide()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HalloweenDeadTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweendeadtips))
    self.gameObject.name = "HalloweenDeadTips"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local transform = self.gameObject.transform
    -- transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.timeText = transform:FindChild("TimeText"):GetComponent(Text)
    self.descText = transform:FindChild("DescText"):GetComponent(Text)
    self.killerNameText = transform:FindChild("KillerNameText"):GetComponent(Text)
    self.damakuBtn = transform:Find("DamakuBtn"):GetComponent(Button)

    self.damakuBtn.onClick:AddListener(function() self:OnDamaku() end)

    self.descText.text = TI18N("1、被识破后，需要等待<color='#ffff00'>20s</color>才能复活\n2、复活倒计时内无法操作也不会被识破\n3、倒计时结束后，将传送至<color='#ffff00'>随机点</color>并<color='#ffff00'>重新复活</color>")
    self.killerNameText.text = ""

    self:Show()

    self:ClearMainAsset()
end


function HalloweenDeadTips:Show()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(true)
        self.cooldown_time = 20
        self:Update()
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 1000, self._Update)
        end
    end
end

function HalloweenDeadTips:Hide()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
    end
end

function HalloweenDeadTips:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function HalloweenDeadTips:Update()
    if self.cooldown_time >= 0 then
        self.timeText.text = tostring(self.cooldown_time)
        self.cooldown_time = self.cooldown_time - 1

        if self.model.killerName ~= nil then
            self.killerNameText.text = string.format(TI18N("识破者：<color='#ffff00'>%s</color>"), self.model.killerName)
        end
    else
        self.model.killerName = nil
        self:Hide()
    end
end

function HalloweenDeadTips:OnDamaku()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pumpkin_damaku_window)
end
