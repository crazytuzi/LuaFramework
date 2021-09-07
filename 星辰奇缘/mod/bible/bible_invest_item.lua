BibleInvestItem = BibleInvestItem or BaseClass()

function BibleInvestItem:__init(model, gameObject, callback)
    self.model = model
    self.gameObject = gameObject

    local t = gameObject.transform
    self.receivedObj = t:Find("ReceivedMark").gameObject
    self.receiveBtn = t:Find("Button"):GetComponent(Button)
    self.receiveText = t:Find("Button/Text"):GetComponent(Text)
    self.receiveImage = t:Find("Button"):GetComponent(Image)
    self.dayText = t:Find("Day"):GetComponent(Text)
    self.goldText = t:Find("Diamond/Text"):GetComponent(Text)
    self.rect = t:GetComponent(RectTransform)
end

function BibleInvestItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function BibleInvestItem:SetData(data, index)
    self.dayText.text = string.format(TI18N("第%s天"), tostring(index))
    self.goldText.text = tostring(data.reward[1][2])
    self.receiveBtn.onClick:RemoveAllListeners()
    self.receiveBtn.onClick:AddListener(function() self:OnReceive(index) end)
    self.receivedObj:SetActive(data.state == 2)
    self.receiveBtn.gameObject:SetActive(data.state ~= 2)

    if data.state ~= 1 then
        self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.receiveText.text = TI18N("未达成")
    else
        self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.receiveText.text = TI18N("领 取")
    end


    self:SetActive(true)
end

function BibleInvestItem:OnReceive(index)
    if #self.model.invest_data == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你还未购买伊芙的钻石袋"))
    elseif self.model.invest_data[index] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("登陆天数没达到条件，暂时不能领取"))
    else
        BibleManager.Instance:send15301(index)
    end
end

function BibleInvestItem:__delete()
end
