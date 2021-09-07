-- @author 黄耀聪
-- @date 2017年3月2日

LoveConnection = LoveConnection or BaseClass(BasePanel)

function LoveConnection:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "LoveConnection"

    self.resList = {
        {file = AssetConfig.love_connection, type = AssetType.Main},
        {file = AssetConfig.valentine_textures, type = AssetType.Dep},
        {file = AssetConfig.backend_textures , type = AssetType.Dep},
        {file = AssetConfig.wishlove_title, type = AssetType.Dep},
        {file = AssetConfig.guidesprite, type = AssetType.Main},
        {file = AssetConfig.iconbigbg,type = AssetType.Main},
    }

    self.itemList = {}
    self.timeString = TI18N("<color='#00ff00'>活动时间:%s-%s</color>")
    self.dateString = TI18N("%s年%s月%s日")
    --self.campDataId = 707

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.SetDataListener = function() self:ReplyData() end
end

function LoveConnection:__delete()
    ValentineManager.Instance.onUpdateWishData:RemoveListener(self.SetDataListener)
    self.OnHideEvent:Fire()

    if self.leftEffect ~= nil then
        self.leftEffect:DeleteMe()
        self.leftEffect = nil
    end

    if self.rightEffect ~= nil then
        self.rightEffect:DeleteMe()
        self.rightEffect = nil
    end

    if self.leftBtnEffect ~= nil then
        self.leftBtnEffect:DeleteMe()
        self.leftBtnEffect = nil
    end

    if self.rightBtnEffect ~= nil then
        self.rightBtnEffect:DeleteMe()
        self.rightBtnEffect = nil
    end

    if self.bigTitle ~= nil then
        BaseUtils.ReleaseImage(self.bigTitle)
        self.bigTitle = nil
    end

    self:AssetClearAll()
end

function LoveConnection:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_connection))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.timeText = t:Find("Time"):GetComponent(Text)
    self.timeText.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-124,99)
    local bg = t:Find("Bg"):GetComponent(RectTransform)
    bg.anchoredPosition = Vector2(0,-1.8)

    if self.bg ~= nil then
        UIUtils.AddBigbg(t:Find("BigBg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    end

    local bigBgRtr = t:Find("BigBg"):GetComponent(RectTransform)
    bigBgRtr.anchoredPosition = Vector2(-7,-80.8)

    self.bigTitle = t:Find("Bigtitle"):GetComponent(Image)
    self.bigTitle.sprite = self.assetWrapper:GetSprite(AssetConfig.wishlove_title,"wishloveTitleI18N")


    self.campData = DataCampaign.data_list[self.campId]
    local start_time = self.campData.cli_start_time[1]
    local end_time = self.campData.cli_end_time[1]

    self.timeText.text = string.format(self.timeString,
            string.format(self.dateString, tostring(start_time[1]), tostring(start_time[2]), tostring(start_time[3])),
            string.format(self.dateString, tostring(end_time[1]), tostring(end_time[2]), tostring(end_time[3]))
        )
    self.timeText.transform.anchoredPosition = Vector2(-104, 129.3)

    self.Desc = t:Find("Desc")
    self.Desc.anchoredPosition = Vector2(-110, 98)

    ------------------------------------------------------------------------
    self.bigBgContainerTr = t:Find("TalkBg")
    self.bigBgContainerTr:GetComponent(RectTransform).anchoredPosition = Vector2(-38.49,-33.4)
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.iconbigbg))
    UIUtils.AddBigbg(self.bigBgContainerTr,bigObj)

    self.leftIcon = t:Find("IconContainer/LeftBg/WishIcon")
    self.leftIcon:GetComponent(Button).onClick:AddListener(function() self:ApplyLeftButton() end)
    self.leftButton = t:Find("IconContainer/LeftBg/WishButton"):GetComponent(Button)
    self.leftButton.onClick:AddListener(function() self:ApplyLeftButton() end)
    self.leftText = t:Find("IconContainer/LeftBg/WishButton/Text"):GetComponent(Text)
    self.leftEffect = BibleRewardPanel.ShowEffect(20372, self.leftIcon.gameObject.transform, Vector3.one, Vector3(1.8, 13.5, -400))


    self.rightIcon = t:Find("IconContainer/RightBg/WishBackIcon")
    self.rightButton = t:Find("IconContainer/RightBg/WishButtn"):GetComponent(Button)
    self.rightButton.onClick:AddListener(function() self:ApplyRightButton() end)
    self.rightIcon:GetComponent(Button).onClick:AddListener(function() self:ApplyRightButton() end)
    self.rightText = t:Find("IconContainer/RightBg/WishButtn/Text"):GetComponent(Text)
    self.rightEffect = BibleRewardPanel.ShowEffect(20371, self.rightIcon.gameObject.transform, Vector3.one, Vector3(0, 10, -400))

    self.rightNoticeText = t:Find("IconContainer/RightBg/Text"):GetComponent(Text)
    self.rightNoticeText.text = "予人玫瑰，手有余香，帮助他人实现愿望会有<color='#ffff00'>丰厚奖励</color>哦"
    self.leftBtnEffect = BibleRewardPanel.ShowEffect(20370, self.leftButton.gameObject.transform, Vector3.one, Vector3(0, -9, -400))
    self.rightBtnEffect = BibleRewardPanel.ShowEffect(20370, self.rightButton.gameObject.transform, Vector3.one, Vector3(0, -9, -400))

    self.redPoint = t:Find("IconContainer/LeftBg/WishButton/RedPoint")
    self.rightRedPoint = t:Find("IconContainer/RightBg/WishButtn/RedPoint")

    self:OnOpen()
end

function LoveConnection:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LoveConnection:OnOpen()
    ValentineManager.Instance.onUpdateWishData:AddListener(self.SetDataListener)
    ValentineManager.Instance:send17828()
    if 2 - ValentineManager.Instance.model.votiveCount  == 0 then
        self.rightBtnEffect:SetActive(false)
    else
        self.rightBtnEffect:SetActive(true)
    end

    if 1 - ValentineManager.Instance.model.wishCount == 0 then
        self.leftBtnEffect:SetActive(false)
    else
        self.leftBtnEffect:SetActive(true)
        self.rightBtnEffect:SetActive(false)
    end



    self:ReplyData()
    self:RemoveListeners()
end


function LoveConnection:ReplyData()


    if 1 - ValentineManager.Instance.model.wishCount == 0 then
        self.leftText.text = TI18N("<color='#ffff00'>已许愿</color>")
        self.redPoint.gameObject:SetActive(false)
    else
        self.redPoint.gameObject:SetActive(true)
        self.leftText.text = string.format(TI18N("许愿(%s/1)"), 1 - ValentineManager.Instance.model.wishCount)
    end



    if 2 - ValentineManager.Instance.model.votiveCount == 0 then
        self.rightText.text = TI18N("已还愿")
    else
        self.rightText.text = string.format(TI18N("还愿(%s/2)"), 2 - ValentineManager.Instance.model.votiveCount)
    end

    if 1 - ValentineManager.Instance.model.wishCount == 0 and 2 - ValentineManager.Instance.model.votiveCount == 2 then
        self.rightRedPoint.gameObject:SetActive(true)
    elseif 1 - ValentineManager.Instance.model.wishCount == 0 and 2 - ValentineManager.Instance.model.votiveCount ~= 2 then
        self.rightRedPoint.gameObject:SetActive(false)
    end

end

function LoveConnection:OnHide()
    self:RemoveListeners()
end

function LoveConnection:RemoveListeners()
    ValentineManager.Instance.onUpdateWishData:RemoveListener(self.SetDataListener)
end

function LoveConnection:ApplyLeftButton()
    if 1 - ValentineManager.Instance.model.wishCount ~= 0 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.love_wish)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("您已经完成了今天的许愿，请等待有缘人还愿吧{face_1,3}"))
    end
end

function LoveConnection:ApplyRightButton()
    if 2 - ValentineManager.Instance.model.votiveCount ~= 0 and 1 - ValentineManager.Instance.model.wishCount == 0 then
        ValentineManager.Instance:send17830(1)
    elseif 2 - ValentineManager.Instance.model.votiveCount ~= 0 and 1 - ValentineManager.Instance.model.wishCount == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("今天还没<color='#ffff00'>许愿</color>呢，许愿后才能还愿哦{face_1,3}"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("您已经完成了今天的还愿，明天再来吧{face_1,3}"))
    end
end

function LoveConnection:ReplyLeftButton()
end

function LoveConnection:ReplyRightButton()

end



