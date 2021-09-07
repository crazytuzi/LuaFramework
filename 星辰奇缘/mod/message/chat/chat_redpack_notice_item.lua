-- -------------------------------
-- 红包领取通知
-- hosr
-- -------------------------------
ChatRedpackNoticeItem = ChatRedpackNoticeItem or BaseClass(MsgItem)

function ChatRedpackNoticeItem:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = mainPanel.container

    self.data = nil
    -- 文本最大宽度
    self.txtMaxWidth = 300
    -- 文本每行的高度
    self.lineSpace = 22

    self.selfWidth = 0
    self.selfHeight = 0
    self.extraWidth = 0
    self.extraHeight = 0
    self.extraWidth = 0
    self.extraHeight = 0
    self.wholeOffsetX = 0

    self:InitPanel()
end

function ChatRedpackNoticeItem:__delete()
    self.mainPanel = nil
    self.parent = nil
    self.data = nil
    self.txtMaxWidth = nil
    self.lineSpace = nil
    self.selfWidth = nil
    self.selfHeight = nil
    self.extraWidth = nil
    self.extraHeight = nil
    self.extraWidth = nil
    self.extraHeight = nil
    self.wholeOffsetX = nil

    self.transform = nil
    self.rect = nil
    self.containerRect = nil
    self.contentRect = nil
    self.button = nil
    self.contentTxt = nil
end

function ChatRedpackNoticeItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self.mainPanel.baseRedpackItem)
    self.transform = self.gameObject.transform
    self.gameObject.name = "ChatRedpackNoticeItem"
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.transform.localPosition = Vector3.zero

    self.containerRect = self.transform:Find("Container"):GetComponent(RectTransform)
    self.button = self.transform:Find("Container"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:ClickBtn() end)

    self.contentRect = self.transform:Find("Container/Text"):GetComponent(RectTransform)
    self.contentTxt = self.transform:Find("Container/Text"):GetComponent(Text)
end

function ChatRedpackNoticeItem:Reset()
    self.needDelete = false
    self:HideImg()
    self:AnchorTop()
    self.contentTxt.text = ""
    self.contentRect.sizeDelta = Vector2(self.txtMaxWidth, self.lineSpace)
    self.wholeOffsetX = 0
    self.extraWidth = 0
    self.extraHeight = 0
end

function ChatRedpackNoticeItem:SetData(data)
    self.data = data
    -- self.contentTxt.text = self.data.msg
    self.msgData = self:GetMsgData(self.data.msg)
    self.contentTxt.text = self.msgData.pureString

    self:Layout()
end

function ChatRedpackNoticeItem:Layout()
    self.gameObject:SetActive(true)
    self.selfHeight = 50
    self.selfWidth = 345

    local width = self.contentTxt.preferredWidth
    if width > self.txtMaxWidth then
        width = self.txtMaxWidth
    end
    local height = self.contentTxt.preferredHeight
    self.contentRect.sizeDelta = Vector2(width, height)

    self.containerRect.sizeDelta = Vector2(width + 50, 50)

    local nx = (self.selfWidth - width - 40 - 10) / 2
    self.containerRect.anchoredPosition = Vector2(nx, 0)

    self.rect.sizeDelta = Vector2(self.selfWidth, self.selfHeight)

    self:Generator()
end

function ChatRedpackNoticeItem:ClickBtn()
    if self.data.channel == MsgEumn.ChatChannel.World then
        RedBagManager.Instance:Send18505(self.data.rid, self.data.platform, self.data.zone_id)
    else
        GuildManager.Instance:request11132(self.data.rid, self.data.zone_id, self.data.platform)
    end
end