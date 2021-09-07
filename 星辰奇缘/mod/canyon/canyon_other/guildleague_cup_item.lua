-- 冠军联赛历史冠军item
-- hzf
--2016年11月19日15:00:09

GuildLeagueCupItem = GuildLeagueCupItem or BaseClass()

function GuildLeagueCupItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform
    self.season = self.transform:Find("season"):GetComponent(Text)
    self.Image = self.transform:Find("Image"):GetComponent(Image)
    self.name = self.transform:Find("name"):GetComponent(Text)
    self.server = self.transform:Find("server"):GetComponent(Text)

    self.ImgOne = self.transform:GetComponent(Image)
    -- self.Select = self.transform:Find("Select").gameObject
end

--设置


function GuildLeagueCupItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildLeagueCupItem:set_my_index(_index)
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
function GuildLeagueCupItem:update_my_self(_data, _index)
    local index = tonumber(_index)
    self.data = _data
    self.season.text = string.format(ColorHelper.ListItemStr, string.format(TI18N("第%s届"), tostring(_data.season)))
    self.Image.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(_data.top3[1].totem))
    self.name.text = string.format(ColorHelper.ListItemStr, _data.top3[1].name1)
    local serverName = ""
    for k, v in pairs(DataServerList.data_server_name) do
        if v.platform == _data.top3[1].platform and v.zone_id == _data.top3[1].zone_id then
            serverName = v.platform_name
            break
        end
    end
    self.server.text = string.format(ColorHelper.ListItemStr, serverName)
    self:set_my_index(_index)
end