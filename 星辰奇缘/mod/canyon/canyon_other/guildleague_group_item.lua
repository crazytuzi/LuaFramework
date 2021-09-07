-- 冠军联赛小组列表Item
-- hzf
-- 2016年10月10日

GuildLeagueGroupItem = GuildLeagueGroupItem or BaseClass()

function GuildLeagueGroupItem:__init(gameObject, panel)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform

    self.data = nil
    self.index = 1

    self.panel = panel

    self.sub1 = self.transform:Find("sub1")
    self.sub1Title = self.sub1:Find("Titlebg/Text"):GetComponent(Text)
    self.sub1List = {}
    for i=1,4 do
        self.sub1List[i] = {}
        self.sub1List[i].transform = self.transform:Find(string.format("sub1/g%s", tostring(i)))
        self.sub1List[i].NameText = self.sub1List[i].transform:Find("NameText"):GetComponent(Text)
        self.sub1List[i].WinText = self.sub1List[i].transform:Find("WinText"):GetComponent(Text)
        self.sub1List[i].ScoreText = self.sub1List[i].transform:Find("ScoreText"):GetComponent(Text)
        self.sub1List[i].icon = self.sub1List[i].transform:Find("icon"):GetComponent(Image)
    end


    self.sub2 = self.transform:Find("sub2")
    self.sub2Title = self.sub2:Find("Titlebg/Text"):GetComponent(Text)
    self.sub2List = {}
    for i=1,4 do
        self.sub2List[i] = {}
        self.sub2List[i].transform = self.transform:Find(string.format("sub2/g%s", tostring(i)))
        self.sub2List[i].NameText = self.sub2List[i].transform:Find("NameText"):GetComponent(Text)
        self.sub2List[i].WinText = self.sub2List[i].transform:Find("WinText"):GetComponent(Text)
        self.sub2List[i].ScoreText = self.sub2List[i].transform:Find("ScoreText"):GetComponent(Text)
        self.sub2List[i].icon = self.sub2List[i].transform:Find("icon"):GetComponent(Image)
    end

    self.subList = {
        [1] = self.sub1List,
        [2] = self.sub2List,
    }

end

function GuildLeagueGroupItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildLeagueGroupItem:set_my_index(_index)
    self.index = _index
    -- if self.index % 2 == 0 then
    --     self.bgImg.color = Color32(43,74,105,255)
    -- else
    --     self.bgImg.color = Color32(50,91,131,255)
    -- end
end

--更新内容
function GuildLeagueGroupItem:update_my_self(_data, _index)
    self.data = _data
    self:set_my_index(_index)
    if self.data[1] ~= nil and self.data[1][1] ~= nil then
        self.sub1Title.text = string.format(TI18N("第%s小组"), tostring(self.data[1][1].group))
    end
    if self.data[2] ~= nil and self.data[2][1] ~= nil then
        self.sub2Title.text = string.format(TI18N("第%s小组"), tostring(self.data[2][1].group))
    end
    self.sub1.gameObject:SetActive(true)
    self.sub2.gameObject:SetActive(true)
    for i=1,2 do
        if self.data[i] ~= nil then
            for ii=1,4 do
                if self.data[i][ii] ~= nil then
                    self.subList[i][ii].transform.gameObject:SetActive(true)
                    self.subList[i][ii].NameText.text = self.data[i][ii].name
                    self.subList[i][ii].WinText.text = string.format("%s/%s/%s", self.data[i][ii].season_win, self.data[i][ii].season_lost, self.data[i][ii].season_draw)
                    self.subList[i][ii].ScoreText.text = self.data[i][ii].season_score
                    self.subList[i][ii].icon.sprite = self.panel.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(self.data[i][ii].totem))
                else
                    self.subList[i][ii].transform.gameObject:SetActive(false)
                end
            end
        else
            if i == 1 then
                self.sub1.gameObject:SetActive(false)
            else
                self.sub2.gameObject:SetActive(false)
            end
        end
    end
end