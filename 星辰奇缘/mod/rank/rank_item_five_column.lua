RankItemFiveColumn = RankItemFiveColumn or BaseClass()

function RankItemFiveColumn:__init(model, gameObject, assetWrapper)
    self.assetWrapper = assetWrapper
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    local t = self.transform

    self.img = self.gameObject:GetComponent(Image)
    self.rankText = t:Find("RankValue"):GetComponent(Text)
    self.rankRect = t:Find("RankValue"):GetComponent(RectTransform)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.charactor1NameText = t:Find("Character1/Name"):GetComponent(("Text"))
    self.charactor1CenterText = t:Find("Character1/CenterName"):GetComponent(Text)
    self.charactor1Image = t:Find("Character1/Icon/Image"):GetComponent(Image)
    t:Find("Character1/Icon/Image"):GetComponent(RectTransform).localScale = Vector2(1.1,1.1)
    self.charactor1Rect = t:Find("Character1"):GetComponent(RectTransform)
    self.charactor2NameText = t:Find("Character2/Name"):GetComponent(("Text"))
    self.charactor2CenterText = t:Find("Character2/CenterName"):GetComponent(Text)
    self.charactor2Image = t:Find("Character2/Icon/Image"):GetComponent(Image)
    t:Find("Character2/Icon/Image"):GetComponent(RectTransform).localScale = Vector2(1.1,1.1)
    self.charactor2Rect = t:Find("Character2"):GetComponent(RectTransform)
    self.scoreText = t:Find("Score"):GetComponent(Text)
    self.scoreImage = t:Find("Score/Image"):GetComponent(Image)
    self.scoreRect = t:Find("Score"):GetComponent(RectTransform)
    self.masterText = t:Find("Master"):GetComponent(Text)
    self.masterImage = t:Find("Master/Image"):GetComponent(Image)
    self.masterRect = t:Find("Master"):GetComponent(RectTransform)
    self.bgObj = t:Find("Bg").gameObject
    self.bgObj:SetActive(false)
    self.selectObj = t:Find("Select").gameObject
    self.button = self.gameObject:GetComponent(Button)

    self.scoreBtn = self.scoreImage.gameObject:GetComponent(Button)
    if self.scoreBtn == nil then
        self.scoreBtn = self.scoreImage.gameObject:AddComponent(Button)
    end

    self.rectList = {self.rankRect, self.charactor1Rect, self.charactor2Rect, self.scoreRect, self.masterRect}
    self.width = {}
    for k,v in pairs(self.rectList) do
        self.width[k] = v.sizeDelta.x
    end
end

function RankItemFiveColumn:update_my_self(data, index)

    if data.virtual == true then
        self.gameObject:SetActive(false)
        self.isVirtual = true
        return
    else
        self.gameObject:SetActive(true)
        self.isVirtual = false
    end
    local model = self.model
    local type = model.currentType
    local day = nil
    local min = nil
    local sec = nil
    local hour = nil
    local pageIndex = model.rankTypeToPageIndexList[type]
    local titleIndex = model.classList[pageIndex.main].subList[pageIndex.sub].titleIndex or {1, 2, 3, 4, 5}
    local color = ""
    if type ==  model.rank_type.Child or
        type == model.rank_type.Guild or
        type == model.rank_type.GuildBattle or
        type == model.rank_type.GoodVoice or
        type == model.rank_type.GoodVoice2 then
        if index < 4 then
            color = model.colorList[index]
        else
            color = ColorHelper.ListItem
        end
    else
        color = ColorHelper.ListItem
    end

    self.scoreText.color = color
    self.masterText.color = color
    self.charactor1NameText.color = color
    self.charactor2NameText.color = color
    self.charactor1CenterText.color = color
    self.charactor2CenterText.color = color

    if index % 2 == 1 then
        self.img.color = ColorHelper.ListItem1
    else
        self.img.color = ColorHelper.ListItem2
    end

    self.data = data
    self.scoreBtn.onClick:RemoveAllListeners()

    if (type ==  model.rank_type.Child or
        type == model.rank_type.Guild or
        type == model.rank_type.GuildBattle or
        type == model.rank_type.GoodVoice or
        type == model.rank_type.GoodVoice2) and
        index < 4 then
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..data.rank)
        self.rankText.text = ""
    else
        self.rankImage.gameObject:SetActive(false)
        self.rankText.text = string.format(ColorHelper.ListItemStr, tostring(data.rank))
    end

    if type == model.rank_type.Guild then
        self.charactor1CenterText.text = data.desc
        self.charactor1Image.transform.parent.gameObject:SetActive(false)
        self.charactor1NameText.gameObject:SetActive(false)
        self.charactor1CenterText.gameObject:SetActive(true)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)
        self.scoreText.text = tostring(data.val1)
        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)
        self.charactor2CenterText.text = tostring(data.val2)
        self.masterText.text = tostring(data.name)
    elseif type == model.rank_type.GuildBattle then
        self.charactor1CenterText.text = data.desc
        self.charactor1Image.transform.parent.gameObject:SetActive(false)
        self.charactor1NameText.gameObject:SetActive(false)
        self.charactor1CenterText.gameObject:SetActive(true)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)
        self.scoreText.text = tostring(data.val2)
        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)
        self.charactor2CenterText.text = tostring(data.val1)
        self.masterText.text = tostring(data.name)
    elseif type == model.rank_type.ClassesChallenge
        then
        self.charactor1Image.transform.parent.gameObject:SetActive(true)
        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1CenterText.gameObject:SetActive(false)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)

        self.charactor1NameText.text = data.name
        self.charactor1Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
        self.scoreText.text = KvData.classes_name[data.classes]
        self.masterText.text = tostring(data.val1)..TI18N("星")
        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)
        day,hour,min,sec = BaseUtils.time_gap_to_timer(data.val2)
        if hour > 0 then
            self.charactor2CenterText.text = string.format(TI18N("%s小时%s分%s秒"), hour, min, sec)
        else
            self.charactor2CenterText.text = string.format(TI18N("%s分%s秒"), min, sec)
        end
    elseif type == model.rank_type.TopChallenge
        then
        self.charactor1Image.transform.parent.gameObject:SetActive(true)
        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1CenterText.gameObject:SetActive(false)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)

        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1Image.gameObject:SetActive(true)
        self.charactor1NameText.text = data.name
        self.charactor1Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
        self.charactor2CenterText.text = tostring(data.val1)
        self.scoreText.text = tostring(data.val2)
        self.masterText.text = KvData.classes_name[data.classes]
        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)
    elseif type == model.rank_type.MasqNewTalent
        or type == model.rank_type.MasqElite
        or type == model.rank_type.MasqCourage
        or type == model.rank_type.MasqHero
        then
        self.charactor1Image.transform.parent.gameObject:SetActive(true)
        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1CenterText.gameObject:SetActive(false)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)

        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1Image.gameObject:SetActive(true)
        self.charactor1NameText.text = data.name
        self.charactor1Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
        self.masterText.text = tostring(data.val1)
        self.charactor2CenterText.text = tostring(data.lev)
        self.scoreText.text = KvData.classes_name[data.classes]
        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)
    elseif type == model.rank_type.LoveHistory
        or type == model.rank_type.LoveWeekly
        then
        self.charactor1Image.transform.parent.gameObject:SetActive(true)
        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1CenterText.gameObject:SetActive(false)
        self.charactor2Image.transform.parent.gameObject:SetActive(true)
        self.charactor2NameText.gameObject:SetActive(true)
        self.charactor2CenterText.gameObject:SetActive(false)

        self.charactor1Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.male_classes.."_"..data.male_sex)
        self.charactor1NameText.text = data.male_name
        self.charactor2Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.female_classes.."_"..data.female_sex)
        self.charactor2NameText.text = data.female_name
        self.masterText.text = tostring(data.val1)
        self.scoreText.text = ""
        self.masterImage.gameObject:SetActive(false)
        self.scoreImage.gameObject:SetActive(false)
        if data.val2 == 2 then
            --self.scoreImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "Luxury")
            self.scoreText.text = TI18N("<color=#FF66FF>豪华</color>")
        elseif data.val2 == 1 then
            --self.scoreImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "TrueLove")
            self.scoreText.text = TI18N("挚爱")
        else
            -- self.scoreImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "TrueLove")
            self.scoreImage.gameObject:SetActive(false)
        end
        self.scoreBtn.onClick:AddListener(function() self:OnClickWedding() end)
    elseif type == model.rank_type.Home
        then
        -- BaseUtils.dump(data, "data")
        self.charactor1Image.transform.parent.gameObject:SetActive(true)
        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1CenterText.gameObject:SetActive(false)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)

        self.charactor2CenterText.text = DataFamily.data_home_data[data.val4].name

        self.charactor1NameText.text = data.name
        self.charactor1Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
        self.scoreText.text = DataFamily.data_home_data[data.val4].name2
        self.masterText.text = tostring(data.val1)
        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)
    elseif type == model.rank_type.Lev then
        self.charactor1Image.transform.parent.gameObject:SetActive(true)
        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1CenterText.gameObject:SetActive(false)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)

        self.charactor2CenterText.text = KvData.classes_name[data.classes]
        self.scoreText.text = tostring(data.val1)

        self.charactor1NameText.text = data.name
        self.charactor1Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
        self.masterText.text = tostring(data.val2)
        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)

        -- self.iconObj:SetActive(true)
        -- self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
        -- self.nameText.gameObject:SetActive(true)
        -- self.nameText.text = data.name
        -- self.jobText.text =
        -- self.scoreText.text = tostring(data.lev)
    elseif type == model.rank_type.StarChallenge then
        self.charactor1Image.transform.parent.gameObject:SetActive(true)
        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1CenterText.gameObject:SetActive(false)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)

        self.scoreText.text = string.format(TI18N("第%s阶段"), data.wave)
        if data.use_time < 3600 then
            self.masterText.text = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.MIN)
        else
            self.masterText.text = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.HOUR)
        end
        self.charactor2CenterText.text = KvData.classes_name[data.classes]

        self.charactor1NameText.text = data.name
        self.charactor1Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)

        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)
    elseif type == model.rank_type.ApocalypseLord then
        self.charactor1Image.transform.parent.gameObject:SetActive(true)
        self.charactor1NameText.gameObject:SetActive(true)
        self.charactor1CenterText.gameObject:SetActive(false)
        self.charactor2Image.transform.parent.gameObject:SetActive(false)
        self.charactor2NameText.gameObject:SetActive(false)
        self.charactor2CenterText.gameObject:SetActive(true)

        self.scoreText.text = string.format(TI18N("第%s阶段"), data.wave)
        if data.use_time < 3600 then
            self.masterText.text = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.MIN)
        else
            self.masterText.text = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.HOUR)
        end
        self.charactor2CenterText.text = KvData.classes_name[data.classes]

        self.charactor1NameText.text = data.name
        self.charactor1Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)

        self.scoreImage.gameObject:SetActive(false)
        self.masterImage.gameObject:SetActive(false)
    end

    local x = 0
    for i,v in ipairs(titleIndex) do
        self.rectList[v].anchoredPosition = Vector2(x, 0)
        x = x + self.width[v]
    end

    local data_cpy = BaseUtils.copytab(data)
    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function()
        if model.currentSelectItem ~= nil then
            model.currentSelectItem:SetActive(false)
        end
        model.selectIndex = index
        self.selectObj:SetActive(true)
        model.currentSelectItem = self.selectObj

        -- 添加点击事件
        if type == model.rank_type.Guild
            or type == model.rank_type.TopChallenge
            or type == model.rank_type.Home
            or type == model.rank_type.Lev
         then
            TipsManager.Instance:ShowPlayer({id = data_cpy.role_id, zone_id = data_cpy.zone_id, platform = data_cpy.platform, sex = data_cpy.sex, classes = data_cpy.classes, name = data_cpy.name, guild = data_cpy.desc, lev = data.lev, noChatStranger = true})
        elseif type == model.rank_type.StarChallenge then
            TipsManager.Instance:ShowPlayer({id = data_cpy.rid, zone_id = data_cpy.zone_id, platform = data_cpy.platform, sex = data_cpy.sex, classes = data_cpy.classes, name = data_cpy.name, lev = data.lev, noChatStranger = true})
        end
    end)
    self.selectObj:SetActive(model.selectIndex == index)
end

function RankItemFiveColumn:__delete()
    self.rankImage.sprite = nil
    self.scoreImage.sprite = nil
    self.masterImage.sprite = nil
    self.charactor1Image.sprite = nil
    self.charactor2Image.sprite = nil

    self.assetWrapper = nil

    self.rankText = nil
    self.rankImage = nil
    self.charactor1NameText = nil
    self.charactor1CenterText = nil
    self.charactor1Image = nil
    self.charactor2NameText = nil
    self.charactor2CenterText = nil
    self.charactor2Image = nil
    self.jobText = nil
    self.scoreText = nil
    self.masterText = nil
    self.bgObj = nil
    self.selectObj = nil
    self.button = nil
    self.model = nil
end

function RankItemFiveColumn:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function RankItemFiveColumn:OnClickWedding()
    if self.data.val2 == 1 then
        TipsManager.Instance:ShowText({gameObject = self.scoreImage.gameObject, itemData = {TI18N("挚爱典礼")}})
    elseif self.data.val2 == 2 then
        TipsManager.Instance:ShowText({gameObject = self.scoreImage.gameObject, itemData = {TI18N("豪华典礼")}})
    else
        -- TipsManager.Instance:ShowText({gameObject = self.scoreImage.gameObject, itemData = {TI18N("挚爱典礼")}})
    end
end