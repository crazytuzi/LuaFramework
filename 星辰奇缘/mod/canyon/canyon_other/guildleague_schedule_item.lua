GuildLeagueScheduleItem = GuildLeagueScheduleItem or BaseClass()

function GuildLeagueScheduleItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform

    self.ImgOne = self.transform:GetComponent(Image)
    self.Rank = self.transform:Find("Rank"):GetComponent(Text)
    self.RankIcon = self.transform:Find("RankIcon"):GetComponent(Image)
    self.GuildName = self.transform:Find("GuildName"):GetComponent(Text)
    self.Score = self.transform:Find("Score"):GetComponent(Text)
    self.SvrName = self.transform:Find("SvrName"):GetComponent(Text)
    self.LeaderName = self.transform:Find("LeaderName"):GetComponent(Text)
    self.Member = self.transform:Find("Member"):GetComponent(Text)
    self.Up = self.transform:Find("Up")
    self.uoText = self.transform:Find("Up/Text"):GetComponent(Text)
    self.Down = self.transform:Find("Down")
    self.downText = self.transform:Find("Down/Text"):GetComponent(Text)
end

--设置


function GuildLeagueScheduleItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildLeagueScheduleItem:set_my_index(_index)
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
function GuildLeagueScheduleItem:update_my_self(_data, _index)
    self.Rank.text = tostring(_index)
    if _index < 4 then
        self.RankIcon.gameObject:SetActive(true)
        -- self.RankIcon.sprit =
    else
        self.RankIcon.gameObject:SetActive(false)

    end
end

function GuildLeagueScheduleItem:Refresh(args)

end

