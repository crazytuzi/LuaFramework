-- -------------------------------
-- 屏幕底部传闻
-- hosr
-- -------------------------------
NoticeBottomPanel = NoticeBottomPanel or BaseClass(BasePanel)

function NoticeBottomPanel:__init(model)
    self.model = model
    self.path = AssetConfig.notice_bottom_panel

    -- 第二字体现在不用了，安卓直接把第一字体改为静态，ios就独立用动态
    -- if Application.platform == RuntimePlatform.Android
    --     or Application.platform == RuntimePlatform.WindowsEditor
    --     or Application.platform == RuntimePlatform.WindowsPlayer
    --     then
    --     self.path = AssetConfig.notice_bottom_panel_android
    -- end

    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.timeId = 0
    self.isShow = false
    self.showPos = 0
    self.hidePos = -40
    self.screentWidth = ctx.ScreenWidth
end

function NoticeBottomPanel:__delete()
    if self.msg ~= nil then
        self.msg:DeleteMe()
        self.msg = nil
    end
end

function NoticeBottomPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "NoticeBottomPanel"
    self.gameObject:SetActive(false)
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.noticeCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, self.hidePos)
    self.rect.sizeDelta = Vector2(self.screentWidth, 30)
    self.label = self.transform:Find("Text"):GetComponent(Text)
    self.labelRect = self.label.gameObject:GetComponent(RectTransform)
    self.msg = MsgItemExt.New(self.label, self.screentWidth, 16, 20)

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function NoticeBottomPanel:ShowMsg(msgData)
    self.msgData = msgData
    self:ShowEnd()
    if not self.isShow then
        self:TweenShow()
    end
end

function NoticeBottomPanel:Layout()
    local x = (self.screentWidth - self.msg.selfWidth) / 2
    self.labelRect.anchoredPosition = Vector2(x, -5)
end

function NoticeBottomPanel:TimeOut()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
        self.timeId = 0
    end
    self:TweenHide()
end

function NoticeBottomPanel:TweenShow()
    self.gameObject:SetActive(true)
    Tween.Instance:MoveY(self.rect, self.showPos, 0.2)
end

function NoticeBottomPanel:TweenHide()
    Tween.Instance:MoveY(self.rect, self.hidePos, 0.2, function() self:HideEnd() end)
end

function NoticeBottomPanel:ShowEnd()
    self.gameObject:SetActive(true)
    self.isShow = true
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
        self.timeId = 0
    end
    self.rect.anchoredPosition = Vector2(0, self.showPos)
    self.timeId = LuaTimer.Add(4000, function() self:TimeOut() end)
    self.msg:SetData(self.msgData)
    self:Layout()
end

function NoticeBottomPanel:HideEnd()
    self.isShow = false
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    self.rect.anchoredPosition = Vector2(0, self.hidePos)
end
