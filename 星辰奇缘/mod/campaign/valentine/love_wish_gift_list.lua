LoveWishGiftList = LoveWishGiftList or BaseClass()

function LoveWishGiftList:__init(gameObject, index,id)
    self.gameObject = gameObject
    self.index = index
    local transform = gameObject.transform
    self.transform = transform

    self.selectBg = transform:Find("Select").gameObject
    self.selectBg:SetActive(false)
    self.tick = transform:Find("Tick").gameObject
    self.tick:SetActive(false)
    self.title = transform:Find("Name").gameObject:GetComponent(Text)
    self.title.text = string.format("<color='#0c52b0'>%s</color>",DataWedding.data_whiteday[id].title)
    self.rewardImgTr = transform:Find("Reward/Gift")
    self.imgLoader = nil 
    if self.imgLoader == nil then
        self.imgLoader = SingleIconLoader.New(self.rewardImgTr.gameObject)
    end
    local baseId = DataWedding.data_whiteday[id].rewardid
    local iconId = DataItem.data_get[baseId].icon
    self.imgLoader:SetSprite(SingleIconType.Item,iconId)

    self:InitButton()

    self.onSelect = EventLib.New()
end

function LoveWishGiftList:__delete()
    self.gameObject = nil
    self.transform = nil
    if self.imgLoader ~= nil then
       self.imgLoader:DeleteMe()
    end
end

function LoveWishGiftList:InitButton()
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnSelect() end)
end

function LoveWishGiftList:OnSelect()
    self.onSelect:Fire(self.index)
end

function LoveWishGiftList:ShowSelectBg(show)
    self.selectBg:SetActive(show)
    self.tick:SetActive(show)
end