-- ---------------------------
-- 信息扩展项
-- 外部传人text组件来new
-- hosr
-- ---------------------------
MsgItemExt = MsgItemExt or BaseClass(MsgItem)

function MsgItemExt:__init(text, maxWidth, fontSize, lineSpace, isSceneFace)
    self.imgTab = {}
    self.btnTab = {}
    self.faceTab = {}

    self.wholeOffsetX = 0
    self.selfHeight = 0

    -- 字体大小
    self.fontSize = fontSize or 17
    -- 每行的高度, 用来进行换行计算想
    self.lineSpace = lineSpace or 25
    self.selfWidth = maxWidth
    self.txtMaxWidth = maxWidth
    self.contentTxt = text
    self.contentRect = text.gameObject:GetComponent(RectTransform)
    self.contentTrans = text.gameObject.transform
    self.isSceneFace = isSceneFace or false
end

function MsgItemExt:__delete()
    self.wholeOffsetX = nil
    self.selfHeight = nil
    self.fontSize = nil
    self.lineSpace = nil
    self.selfWidth = nil
    self.txtMaxWidth = nil
    self.contentTxt = nil
    self.contentRect = nil
    self.contentTrans = nil
    self.msgData = nil
end

function MsgItemExt:SetData(contentStr, isDialog, sprite)
    -- contentStr = string.gsub(contentStr, "<.->", "")
    self.msgData = self:GetMsgData(contentStr)
    -- self.msgData = MessageParser.GetMsgData(contentStr, self.fontSize)
    -- self:ShowElements(self.msgData.elements)
    if isDialog then
        self.msgData.showString = QuestEumn.FilterContent(self.msgData.showString)
    end
    -- self.contentTxt.text = self.msgData.showString
    self.contentTxt.text = self.msgData.pureString
    self.smallSprite = sprite
    self:Layout()
end

-- 一定要传入最大宽度
function MsgItemExt:Layout()
    self.selfWidth = math.ceil(self.contentTxt.preferredWidth)
    if self.selfWidth > self.txtMaxWidth then
        self.selfWidth = self.txtMaxWidth
    end
    -- self.contentRect.sizeDelta = Vector2(self.selfWidth + 10, math.ceil(self.contentTxt.preferredHeight))
    self.contentRect.sizeDelta = Vector2(self.selfWidth, math.ceil(self.contentTxt.preferredHeight))
    self.selfHeight = math.ceil(self.contentTxt.preferredHeight)
    -- self.contentRect.sizeDelta = Vector2(self.selfWidth + 10, self.selfHeight)
    self.contentRect.sizeDelta = Vector2(self.selfWidth, self.selfHeight)
    self:Generator()
end