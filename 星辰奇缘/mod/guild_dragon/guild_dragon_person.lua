-- @author 黄耀聪
-- @date 2017年11月14日, 星期二

GuildDragonPerson = GuildDragonPerson or BaseClass()

function GuildDragonPerson:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.transform = gameObject.transform

    local t = self.transform
    if t:Find("Bg") ~= nil then
        self.bgImage = t:Find("Bg"):GetComponent(Image)
    end
    self.rankText = t:Find("Rank"):GetComponent(Text)
    self.rankImage = t:Find("RankImage"):GetComponent(Image)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.classText = t:Find("Classes"):GetComponent(Text)
    self.guildText = t:Find("Guild"):GetComponent(Text)
    self.scoreText = t:Find("Score"):GetComponent(Text)
end

function GuildDragonPerson:__delete()
    if self.rankImage ~= nil then
        self.rankImage.sprite = nil
    end
    self.assetWrapper = nil
    self.gameObject = nil
    self.model = nil
end

function GuildDragonPerson:update_my_self(data, index)
    local color = ColorHelper.Default
    if data.rank_index == 0 then
        self.rankImage.gameObject:SetActive(false)
        self.rankText.text = TI18N("未上榜")
    elseif data.rank_index > 3 then
        self.rankImage.gameObject:SetActive(false)
        self.rankText.text = data.rank_index
    else
        if data.rank_index == 1 then
            color =Color(218/255, 72/255, 72/255)
        elseif data.rank_index == 2 then
            color = Color(159/255, 55/255, 231/255)
        elseif data.rank_index == 3 then
            color = Color(103/255, 81/255, 207/255)
        end
        self.rankText.text = ""
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_" .. data.rank_index)
    end

    if self.bgImage ~= nil and index ~= nil then
        if index % 2 == 1 then
            self.bgImage.color = ColorHelper.ListItem1
        else
            self.bgImage.color = ColorHelper.ListItem2
        end
    end
    self.nameText.color = color
    self.classText.color = color
    self.guildText.color = color
    self.scoreText.color = color

    if data.rank_type == GuildDragonEnum.Rank.Personal then
        self.nameText.text = data.target_name
        self.classText.text = KvData.classes_name[data.classes]

        if data.guild_name == "" then
            self.guildText.text = TI18N("暂无公会")
        else
            self.guildText.text = data.guild_name
        end
    else
        self.nameText.text = data.guild_name
        self.guildText.text = data.target_name
        self.classText.text = data.lev
    end
    self.scoreText.text = data.point
end

function GuildDragonPerson:SetData(data, index)
    self:update_my_self(data, index)
end

function GuildDragonPerson:SetActive(bool)
    self.gameObject:SetActive(bool)
end


