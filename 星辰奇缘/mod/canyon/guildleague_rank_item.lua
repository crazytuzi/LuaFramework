GuildLeagueRankItem = GuildLeagueRankItem or BaseClass()

function GuildLeagueRankItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform
    self.Rank = self.transform:Find("Rank"):GetComponent(Text)
    self.RankIcon = self.transform:Find("RankIcon"):GetComponent(Image)
    self.GuildName = self.transform:Find("GuildName"):GetComponent(Text)
    self.Score = self.transform:Find("Score"):GetComponent(Text)
    self.SvrName = self.transform:Find("SvrName"):GetComponent(Text)
    self.LeaderName = self.transform:Find("LeaderName"):GetComponent(Text)
    self.Member = self.transform:Find("Group"):GetComponent(Text)
    self.Group = self.transform:Find("Member"):GetComponent(Text)
    self.Up = self.transform:Find("Up")
    self.Down = self.transform:Find("Down")

    self.Bg = self.transform:Find("Bg").gameObject
    self.Select = self.transform:Find("Select").gameObject
end

--设置


function GuildLeagueRankItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildLeagueRankItem:set_my_index(_index)
    self.item_index = _index
    if self.item_index%2 == 0 then
        --偶数
        self.ImgOne.color = ColorHelper.ListItem1
    else
        --单数
        self.ImgOne.color = ColorHelper.ListItem2
    end
end

--更新内容
function GuildLeagueRankItem:update_my_self(_data, _index)
    local index = tonumber(_index)
    self.data = _data
    self.RankIcon.gameObject:SetActive(true)
    if index == 1 then
        self.RankIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconFirst")
    elseif index == 2 then
        self.RankIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconsecond")
    elseif index == 3 then
        self.RankIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconthree")
    else
        self.RankIcon.gameObject:SetActive(false)
    end
    self.Bg:SetActive(index%2==0)
    self.Rank.text = tostring(_index)
    self.GuildName.text = _data.name
    if self.parent.index1 == 1 then
        self.Score.text = "--"
    else
        self.Score.text = _data.season_score
    end
    local serverName = ""
    for k, v in pairs(DataServerList.data_server_name) do
        if v.platform == _data.ld_platform and v.zone_id == _data.ld_zone_id then
            serverName = v.platform_name
            break
        end
    end
    self.SvrName.text = serverName
    self.LeaderName.text = _data.leader_name
    self.Member.text = _data.season_win
    -- if self.parent.index1 == 1 then
    --     self.Group.text = "--"
    -- else
    --     self.Group.text = string.format(("第%s小组"), _data.group)
    -- end
    self.Up.gameObject:SetActive(false)
    self.Down.gameObject:SetActive(false)

    local my_guild_data = GuildManager.Instance.model.my_guild_data
    if my_guild_data.LeaderRid == _data.ld_id and my_guild_data.LeaderPlatform == _data.ld_platform and my_guild_data.LeaderZoneId == _data.ld_zone_id then
        self.Select:SetActive(true)
    else
        self.Select:SetActive(false)
    end
end

function GuildLeagueRankItem:Refresh(args)

end

