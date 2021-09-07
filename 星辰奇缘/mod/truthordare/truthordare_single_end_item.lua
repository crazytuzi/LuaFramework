--大冒险单轮结束面板item
--pwj
TruthordareSingleEndItem = TruthordareSingleEndItem or BaseClass()

function TruthordareSingleEndItem:__init(model, gameObject, assetWrapper)
    self.assetWrapper = assetWrapper
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    local t = self.transform
    self.img = self.gameObject:GetComponent(Image)
    self.rankText = t:Find("RankValue"):GetComponent(Text)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.rankImage.gameObject:SetActive(false)
    self.rankCampImage = t:Find("RankValue/Camp"):GetComponent(Image)

    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.iconObj = t:Find("Character/Icon").gameObject
    self.headSlot = HeadSlot.New()
    self.headSlot:SetRectParent(t:Find("Character/Icon/Image"))
    --self.characterImage = t:Find("Character/Icon/Image"):GetComponent(Image)
    t:Find("Character/Icon/Image"):GetComponent(RectTransform).localScale = Vector2(1.1,1.1)

    self.FlowerImg = t:Find("FloweNum"):GetComponent(Image)
    self.FlowerImg.sprite = self.assetWrapper:GetSprite(AssetConfig.truthordare_textures, "Icon1")
    self.FlowerNum = t:Find("FloweNum/Job"):GetComponent(Text)
    self.EggImg = t:Find("EggNum"):GetComponent(Image)
    self.EggImg.sprite = self.assetWrapper:GetSprite(AssetConfig.truthordare_textures, "Icon2")
    self.EggNum = t:Find("EggNum/Job"):GetComponent(Text)
    self.CallImg = t:Find("CallNum"):GetComponent(Image)
    self.CallImg.sprite = self.assetWrapper:GetSprite(AssetConfig.truthordare_textures, "Icon3")
    self.CallNum = t:Find("CallNum/Job"):GetComponent(Text)

    self.data = nil
end

function TruthordareSingleEndItem:update_my_self(data, index)
    
    self.data = data
    if data.rank < 4 then
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.truthordare_textures, "place_"..data.rank)
        self.rankText.text = ""
    else
        self.rankText.text = data.rank
        self.rankImage.gameObject:SetActive(false)
    end
    self.iconObj:SetActive(true)
    self.headSlot.gameObject:SetActive(true)
    self.headSlot:HideSlotBg(true, 0)
    data.id = data.rid
    self.headSlot:SetAll(data, {isSmall = true})
    --self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
    self.nameText.gameObject:SetActive(true)
    self.nameText.text = data.role_name
    self.FlowerNum.text = tostring(data.flower_num)
    self.EggNum.text = tostring(data.egg_num)
    self.CallNum.text = tostring(data.call_num)
end

function TruthordareSingleEndItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function TruthordareSingleEndItem:__delete()
    --sprite置空  loader置空
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end

    if self.FlowerImg ~= nil then
        BaseUtils.ReleaseImage(self.FlowerImg)
        self.FlowerImg = nil
    end
    self.assetWrapper = nil
    self.nameText = nil
    self.gameObject = nil
    self.model = nil
end