-- --------------------------------
-- 聊天滚动toggle
-- hosr
-- --------------------------------
ChatScrollToggle = ChatScrollToggle or BaseClass()

function ChatScrollToggle:__init(gameObject, mainPanel)
    self.mainPanel = mainPanel
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.openPos = 20
    self.closePos = -20

    self:InitPanel()
end

function ChatScrollToggle:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function ChatScrollToggle:InitPanel()
    self.toggle = self.gameObject:GetComponent(Toggle)
    self.label = self.transform:Find("Label"):GetComponent(Text)

    self.iconImg = self.transform:Find("Background/Icon"):GetComponent(Image)
    self.iconRect = self.transform:Find("Background/Icon"):GetComponent(RectTransform)

    self.toggle.onValueChanged:AddListener(function(val) self:ValueChange(val) end)
end

function ChatScrollToggle:ToggleOn(bool)
    self.toggle.isOn = bool
end

function ChatScrollToggle:ValueChange(bool)
    if bool then
        self.label.text = TI18N("锁定")
        self:TweenOpen()
        self.iconImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, "ChatLockIcon")
    else
        self.label.text = TI18N("滚动")
        self:TweenClose()
        self.iconImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, "ChatUnlockIcon")
    end
    if self.mainPanel.currentChannel ~= nil then
        self.mainPanel.currentChannel:Lock(bool)
    end
end

function ChatScrollToggle:TweenOpen()
    Tween.Instance:MoveX(self.iconRect, self.openPos, 0.2)
end

function ChatScrollToggle:TweenClose()
    Tween.Instance:MoveX(self.iconRect, self.closePos, 0.2)
end