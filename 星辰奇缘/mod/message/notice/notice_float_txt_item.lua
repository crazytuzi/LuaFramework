-- ----------------------------
-- 上浮提示元素
-- hosr
-- 规则说明:
-- 1.界面上最多显示6条
-- 2.每条信息的活动是1.7s持续显示时间，0.3s渐隐消失(没有缓动往上飘)
-- 3.新的直接把旧的往上顶，最后一条直接干掉，轮回到第一条用
-- 4.每条最大宽度 480， 最小宽度240
-- ----------------------------
NoticeFloatTxtItem = NoticeFloatTxtItem or BaseClass()

function NoticeFloatTxtItem:__init(transform)
    self.id = 0

    self.transform = transform
    self.gameObject = transform.gameObject
    self.gameObject:SetActive(false)
    self.image = self.gameObject:GetComponent(Image)
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.label = transform:Find("Text"):GetComponent(Text)
    self.label_rect = self.label.gameObject:GetComponent(RectTransform)
    self.contentTrans = self.label.gameObject.transform
    self.gameObject:GetComponent(CanvasGroup).blocksRaycasts = false
    self.width = 0
    self.height = 0

    self.showing = false
    self.timeId = 0
    self.tweenDesc = nil
    self.alphaDesc = nil
    self.target = 0
    self.defaultColor = Color(0,1,0,1)
    self.image.color = Color(1,1,1,0)
    self.greenColor = Color(0,1,0,1)

    self.imgTab = {}
    self.faceTab = {}
    self.lineSpace = 20
    self.label.fontSize = 22

    self.useCount = 0

    -- 道具和宠物要显示头像在前面
    self.extX = 0
    self.extY = 0

    self.callback = nil
    self.EndCallback = function() self:End() end
    self.updateback = function(val) self:UpdateValue(val) end
end

function NoticeFloatTxtItem:__delete()
    self.defaultColor = nil
    self.image.color = nil
    self.greenColor = nil
    self.imgTab = nil
    self.faceTab = nil
    self.EndCallback = nil
    self.updateback = nil
end

function NoticeFloatTxtItem:Reset()
    self.showing = false
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
        self.timeId = 0
    end
    self.target = 50
    self.transform.localPosition = Vector3(0, self.target, 0)
    self.label.color = self.defaultColor
    self.label.text = ""
    self.extX = 0
    self.extY = 0

    for i,v in ipairs(self.imgTab) do
        v.gameObject:SetActive(false)
    end

    for i,v in ipairs(self.faceTab) do
        v:DeleteMe()
        v = nil
    end
    self.faceTab = {}

    self.useCount = self.useCount + 1
    self.useCount = math.min(self.useCount, 2)
end

function NoticeFloatTxtItem:SetData(showString)
    self:Reset()

    self.showing = true
    self.label.text = showString

    self:Layout()

    self.gameObject:SetActive(true)
    self:BeginAlive()
end

-- 处理宽高
function NoticeFloatTxtItem:Layout()
    self.height = self.label.preferredHeight

    local preferredWidth = self.label.preferredWidth
    self.label_rect.sizeDelta = Vector2(preferredWidth, self.height)
    -- self.label_rect.anchoredPosition = Vector2.zero

    -- 加上上下左右空隙作为最外层容器宽高
    self.width = math.max(preferredWidth, 240)
    self.txtMaxWidth = self.width
    self.width = self.width + 40
    self.height = self.height + 20
    self.rect.sizeDelta = Vector2(self.width, self.height)
    self.label_rect.anchoredPosition = Vector2((self.width - math.ceil(preferredWidth)) / 2, -10)
end

function NoticeFloatTxtItem:ExtLayout()
    if self.extY ~= 0 then
        self.height = self.extY + 6
    end
    self.width = math.max(self.label.preferredWidth, 240)
    self.txtMaxWidth = self.width
    self.width = self.width + self.extX * 2 + 40
    self.rect.sizeDelta = Vector2(self.width, self.height)
    self.label_rect.anchoredPosition = Vector2(self.extX, -2)
end

-- 开始生存周期
function NoticeFloatTxtItem:BeginAlive()
    self.timeId = LuaTimer.Add(50, function() self:Move() end)
end

function NoticeFloatTxtItem:Move()
    self.tweenDesc = Tween.Instance:MoveLocalY(self.gameObject, self.target + 50, 0.4, function() self:Dying() end)
end

-- 消失
function NoticeFloatTxtItem:Dying()
    Tween.Instance:ValueChange(255, 0, 0.3, function() self:End() end, nil, function(val) self:UpdateValue(val) end)
end

function NoticeFloatTxtItem:UpdateValue(val)
    self.label.color = Color(0,1,0, val/255)
end

-- 生存周期完成
function NoticeFloatTxtItem:End()
    self.showing = false
    self.gameObject:SetActive(false)

    if self.callback ~= nil then
        self.callback()
    end
end

function NoticeFloatTxtItem:ForceEnd()
    self.showing = false
    self.gameObject:SetActive(false)
end