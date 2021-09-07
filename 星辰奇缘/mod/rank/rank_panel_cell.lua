 RankPanelCell = RankPanelCell or BaseClass()

function RankPanelCell:__init(gameObject, args)
    self.gameObject = gameObject
    self.data = nil
    self.args = args
    self.model = args.model

    self.count = 1

    local t = self.gameObject.transform

    self.rankText = t:Find("RankValue"):GetComponent(Text)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.iconObj = t:Find("Character/Icon").gameObject
    self.characterImage = t:Find("Character/Icon/Image"):GetComponent(Image)
    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.centernameText = t:Find("Character/CenterName"):GetComponent(Text)
    self.jobText = t:Find("Job"):GetComponent(Text)
    self.scoreText = t:Find("Score"):GetComponent(Text)
    self.selectObj = t:Find("Select").gameObject
    self.bgObj = t:Find("Bg").gameObject
    self.button = self.gameObject:GetComponent(Button)

    -- self:LoadAssetBundleBatch()
end

function RankPanelCell:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self.gameObject = nil
end

function RankPanelCell:InitPanel(data)
    local model = self.model
    local datalist = model.datalist[model.currentMain][model.currentSub]
    self.data = datalist[data.index]
    self.assetWrapper = self.args.assetWrapper
    if self.data == nil then
        return
    end

    local rankType = model.classList[model.currentMain].subList[model.currentSub].type
    if self.data.rank % 2 == 1 then
        self.bgObj:SetActive(true)
    else
        self.bgObj:SetActive(false)
    end

    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self:OnButClick() end)

    self.rankText.text = tostring(self.data.rank)
    self.rankImage.gameObject:SetActive(true)
    self.selectObj:SetActive(false)
    if self.data.rank < 4 then
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..self.data.rank)
    else
        self.rankImage.gameObject:SetActive(false)
    end

    if rankType == model.rank_type.Lev then             -- 等级
        self.iconObj:SetActive(true)
        self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = self.data.name
        self.jobText.text = model.className[self.data.classes]
        self.scoreText.text = tostring(self.data.lev)
    elseif rankType == model.rank_type.RenQi
        or rankType == model.rank_type.GetFlower
        or rankType == model.rank_type.SendFlower
        or rankType == model.rank_type.WarriorNewTalent
        or rankType == model.rank_type.WarriorElite
        or rankType == model.rank_type.WarriorCourage
        or rankType == model.rank_type.WarriorNewTalent
        or rankType == model.rank_type.Duanwei
        then
        self.iconObj:SetActive(true)
        self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = self.data.name
        self.jobText.text = model.className[self.data.classes]
        self.scoreText.text = tostring(self.data.val1)
    elseif rankType == model.rank_type.Jingji_cup then          -- 竞技场
        self.iconObj:SetActive(true)
        self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = self.data.name
        self.jobText.text = model.className[self.data.classes]
        self.scoreText.text = tostring(self.data.val1)
    elseif rankType == model.rank_type.Guild then               -- 公会
        self.iconObj:SetActive(false)
        self.centernameText.text = self.data.desc
        self.jobText.text = tostring(self.data.val1)
        self.scoreText.text = tostring(self.data.val2)
    elseif rankType == model.rank_type.Weapon
        or rankType == model.rank_type.Cloth
        or rankType == model.rank_type.Belt
        or rankType == model.rank_type.Pant
        or rankType == model.rank_type.Shoes
        or rankType == model.rank_type.Ring
        or rankType == model.rank_type.Nacklace
        or rankType == model.rank_type.Bracelet
        or rankType == model.rank_type.Pet
        or rankType == model.rank_type.Shouhu
        then
        self.iconObj:SetActive(true)
        self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = self.data.name
        self.jobText.text = self.data.desc
        self.scoreText.text = tostring(self.data.val1)
    end
end

function RankPanelCell:OnButClick()
    self.args.callback(self.gameObject, self.data)
end


function RankPanelCell:Release()
    self.iconObj:SetActive(false)
    self.nameText.gameObject:SetActive(false)
    self.centernameText.gameObject:SetActive(false)
    self.gameObject:SetActive(false)
end


