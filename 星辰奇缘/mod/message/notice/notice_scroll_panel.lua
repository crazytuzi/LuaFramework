-- @author 黄耀聪
-- @date 2016年8月30日

NoticeScrollPanel = NoticeScrollPanel or BaseClass(BasePanel)

function NoticeScrollPanel:__init(model)
    self.model = model
    self.name = "NoticeScrollPanel"

    self.resList = {
        {file = AssetConfig.notice_scroll_panel, type = AssetType.Main}
        --,{file = AssetConfig.crossvoicetexture, type = AssetType.Dep}
    }

    self.contentQueueHead = {}
    self.contentTail = {}
    self.isScrolling = {}
    self.container = {}
    self.msgExt = {}
    self.imgObj = {}
    self.img = {}
    self.scroll = {}

    self.moveSpeed = 50          -- 单位：像素每秒

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NoticeScrollPanel:__delete()
    self.OnHideEvent:Fire()
    if self.msgExt ~= nil then
        for _,v in pairs(self.msgExt) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.msgExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NoticeScrollPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.notice_scroll_panel))
    self.gameObject:SetActive(false)

    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.noticeCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform.anchoredPosition = Vector2(0, 42)

    self.scroll[1] = t:Find("Img1/Scroll")
    self.imgObj[1] = t:Find("Img1")
    self.img[1] = self.imgObj[1]:GetComponent(Image)
    self.img[1].color = Color(1, 1, 1, 0)
    self.container[1] = self.scroll[1]:Find("Container")
    self.msgExt[1] = MsgItemExt.New(self.scroll[1]:Find("Text"):GetComponent(Text), 100, 18, 21.5)

    self.scroll[2] = t:Find("Img2/Scroll")
    self.imgObj[2] = t:Find("Img2")
    self.img[2] = self.imgObj[2]:GetComponent(Image)
    self.img[2].color = Color(1, 1, 1, 0)
    self.container[2] = self.scroll[2]:Find("Container")
    self.msgExt[2] = MsgItemExt.New(self.scroll[2]:Find("Text"):GetComponent(Text), 100, 18, 21.5)
end

function NoticeScrollPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NoticeScrollPanel:OnOpen()
    self:RemoveListeners()
    self.gameObject:SetActive(true)
    self.imgObj[1].gameObject:SetActive(false)
    self.imgObj[2].gameObject:SetActive(false)
end

function NoticeScrollPanel:OnHide()
    self:RemoveListeners()
end

function NoticeScrollPanel:RemoveListeners()
end

function NoticeScrollPanel:AddContent(content)
    if self.isScrolling[2] == true then
        self:Add(content, 1)
    elseif self.isScrolling[1] == true then
        self:Add(content, 2)
    else
        self:Add(content, 1)
    end
end

function NoticeScrollPanel:Add(content, i)
    if self.contentTail[i] == nil then
        self.contentTail[i] = {content = content, next = nil}
        self.contentQueueHead[i] = self.contentTail[i]
    else
        local tail = {content = content, next = nil}
        self.contentTail[i].next = tail
        self.contentTail[i] = tail
    end

    self:Scroll(i)
end

function NoticeScrollPanel:Scroll(i)
    if self.isScrolling[i] == true then
        return
    end
    if self.contentQueueHead[i] == nil then
        Tween.Instance:Alpha(self.imgObj[i], 0, 0.7, function() self.imgObj[i].gameObject:SetActive(false) end, LeanTweenType.linear)
        return
    end
    --测试代码
    if self.contentQueueHead[i].content.type == 52 or self.contentQueueHead[i].content.type == 53 then
        local imgNum = self.contentQueueHead[i].content.type % 50
        self.img[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.crossvoiceimgtexture, "TextBg"..imgNum)
        --self.moveSpeed = 30
        if i == 1 then
            self.imgObj[1].anchoredPosition = Vector2(0, -130)
        elseif i == 2 then
            self.imgObj[2].anchoredPosition = Vector2(0, -190)
        end
        self.imgObj[i].sizeDelta = Vector2(500, 60)
        self.imgObj[i].gameObject:SetActive(true)
        self.img[i].color = Color(1, 1, 1, 1)
    else
        self.img[i].color = Color(1, 1, 1, 0.7)
        self.img[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemBg13")
        -- if self.contentQueueHead[i].content.type == 51 then
        --     self.moveSpeed = 30
        -- else
        --     self.moveSpeed = 50
        -- end
        if i == 1 then
            self.imgObj[1].anchoredPosition = Vector2(0, -145.6)
        elseif i == 2 then
            self.imgObj[2].anchoredPosition = Vector2(0, -175)
        end
        self.imgObj[i].sizeDelta = Vector2(500, 30)
        self.imgObj[i].gameObject:SetActive(true)
        Tween.Instance:Alpha(self.imgObj[i], 0.7, 0.3, function() end, LeanTweenType.linear)
    end
    self.isScrolling[i] = true
    local msg = self.contentQueueHead[i].content.msg
    local temptype = self.contentQueueHead[i].content.type
    self.contentQueueHead[i] = self.contentQueueHead[i].next
    if self.contentQueueHead[i] == nil then
        self.contentTail[i] = nil
    end

    self.msgExt[i].selfWidth = self.model.calculator:SimpleGetWidth(msg)
    self.msgExt[i].txtMaxWidth = self.msgExt[i].selfWidth
    msg = AnnounceModel.TransferString(nil, msg)
    self.msgExt[i]:SetData(msg)

    local size = self.msgExt[i].contentRect.sizeDelta
    local t = self.msgExt[i].contentTrans
    t:SetParent(self.container[i])
    t.localScale = Vector3.one
    t.anchoredPosition = Vector2(0, 0)
    local rect = self.scroll[i].gameObject:GetComponent(RectTransform)
    if temptype == 52 or temptype == 53 then
        self.container[i].anchoredPosition = Vector2(500, size.y / 2 - 4)
        rect.offsetMin = Vector2(30, 0)
        rect.offsetMax = Vector2(-30, 0)
    else
        self.container[i].anchoredPosition = Vector2(500, size.y / 2)
        rect.offsetMin = Vector2(5, 0)
        rect.offsetMax = Vector2(-5, 0)
    end
    --self.container[i].anchoredPosition = Vector2(500, size.y / 2)
    self.msgExt[i].contentTrans.gameObject:SetActive(true)

    local w = size.x
    if w < 500 then
        w = 500
    end
    local CrossVoiceFun = function()
        if temptype == 51 then
            self.container[i].anchoredPosition = Vector2(500, size.y / 2)
        else
            self.container[i].anchoredPosition = Vector2(500, size.y / 2 - 4)
        end
        Tween.Instance:MoveX(self.container[i], -size.x + 10, w / self.moveSpeed, function() self:AfterScrolling(i) end, LeanTweenType.linear)
    end
    if temptype == 51 or temptype == 52 or temptype == 53 then
        Tween.Instance:MoveX(self.container[i], -size.x + 10, w / self.moveSpeed, function() CrossVoiceFun() end, LeanTweenType.linear)
    else
        Tween.Instance:MoveX(self.container[i], -size.x + 10, w / self.moveSpeed, function() self:AfterScrolling(i) end, LeanTweenType.linear)
    end
end

function NoticeScrollPanel:AfterScrolling(i)
    self.isScrolling[i] = false
    self.msgExt[i].contentTrans.gameObject:SetActive(false)
    self:Scroll(i)
end
