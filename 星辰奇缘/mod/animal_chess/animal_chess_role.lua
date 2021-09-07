AnimalChessRole = AnimalChessRole or BaseClass()

function AnimalChessRole:__init(gameObject, assetWrapper)
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.transform = gameObject.transform

    self:InitPanel()
end

function AnimalChessRole:InitPanel()
    self.headSlot = HeadSlot.New()
    NumberpadPanel.AddUIChild(self.transform:Find("Slot"), self.headSlot.gameObject)

    self.nameText = self.transform:Find("Name"):GetComponent(Text)
    self.sliderRect = self.transform:Find("Value")
    self.expText = self.transform:Find("Exp"):GetComponent(Text)
    self.statusImage = self.transform:Find("Status"):GetComponent(Image)
end

function AnimalChessRole:__delete()
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    if self.statusImage ~= nil then
        self.statusImage.sprite = nil
        self.statusImage = nil
    end
    self.assetWrapper = nil
    self.transform = nil
    self.gameObject = nil
end

function AnimalChessRole:SetData(data)
    local headData = {
        id = data.id,
        platform = data.platform,
        zone_id = data.zone_id,
        sex = data.sex,
        classes = data.classes,
    }
    self.headSlot:SetAll(data, {isSmall = true})
    self.nameText.text = data.name
    self.expText.text = DataCampAnimalChess.data_grade[data.grade].name

    self:SetSlider((data.score or 0) / DataCampAnimalChess.data_grade[data.grade].next_grade)
end

function AnimalChessRole:SetStatus(isMyTurn)
    if isMyTurn then
        self.statusImage.sprite = self.assetWrapper:GetSprite(AssetConfig.animal_chess_textures, "MoveI18N")
    else
        self.statusImage.sprite = self.assetWrapper:GetSprite(AssetConfig.animal_chess_textures, "WaitI18N")
    end
end

function AnimalChessRole:SetSlider(value)
    if value > 1 then
        value = 1
    elseif value < 0 then
        value  = 0
    end
    self.sliderRect.sizeDelta = Vector2(98 * value, 18)
end

