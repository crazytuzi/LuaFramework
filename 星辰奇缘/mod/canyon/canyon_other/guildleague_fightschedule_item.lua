-- 联赛赛程列表ITem
-- hzf
-- 2016年09月27日

GuildLeagueFightScheduleItem = GuildLeagueFightScheduleItem or BaseClass()

function GuildLeagueFightScheduleItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform

    self.ImgOne = self.transform:GetComponent(Image)
    self.Icon1 = self.transform:Find("Icon1"):GetComponent(Image)
    self.GuildName1 = self.transform:Find("GuildName1"):GetComponent(Text)
    self.up1 = self.transform:Find("up1").gameObject
    self.down1 = self.transform:Find("down1").gameObject
    self.ping1 = self.transform:Find("ping1").gameObject
    self.resuld1Text = self.transform:Find("resuld1Text"):GetComponent(Text)

    self.Icon2 = self.transform:Find("Icon2"):GetComponent(Image)
    self.GuildName2 = self.transform:Find("GuildName2"):GetComponent(Text)
    self.up2 = self.transform:Find("up2").gameObject
    self.down2 = self.transform:Find("down2").gameObject
    self.ping2 = self.transform:Find("ping2").gameObject
    self.resuld2Text = self.transform:Find("resuld2Text"):GetComponent(Text)

    self.midText = self.transform:Find("midText"):GetComponent(Text)
    self.VS = self.transform:Find("VS").gameObject
end

--设置


function GuildLeagueFightScheduleItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildLeagueFightScheduleItem:set_my_index(_index)
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
function GuildLeagueFightScheduleItem:update_my_self(_data, _index)
    if _index ~= nil then
        self:set_my_index(_index)
    end
    for k,v in pairs(_data) do
        if v.side == 1 then
            self.Icon1.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(v.totem))
            self.GuildName1.text = string.format(ColorHelper.ListItemStr, v.name)
            self.resuld1Text.gameObject:SetActive(true)
            self.midText.gameObject:SetActive(false)
            self.VS:SetActive(true)
            self.up1:SetActive(false)
            self.down1:SetActive(false)
            self.ping1:SetActive(false)
            if v.is_win == 1 then
                self.resuld1Text.text = TI18N("胜")
                self.up1:SetActive(true)
            elseif v.is_win == 2 then
                self.resuld1Text.text = TI18N("败")
                self.down1:SetActive(true)
            elseif v.is_win == 3 then
                self.resuld1Text.text = TI18N("平")
                self.ping1:SetActive(true)
            else
                self.resuld1Text.gameObject:SetActive(false)
                self.midText.gameObject:SetActive(true)
                self.VS:SetActive(false)
            end
        else
            self.Icon2.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(v.totem))
            self.GuildName2.text = string.format(ColorHelper.ListItemStr, v.name)
            self.resuld2Text.gameObject:SetActive(true)
            self.midText.gameObject:SetActive(false)
            self.VS:SetActive(true)
            self.up2:SetActive(false)
            self.down2:SetActive(false)
            self.ping2:SetActive(false)
            if v.is_win == 1 then
                self.resuld2Text.text = TI18N("胜")
                self.up2:SetActive(true)
            elseif v.is_win == 2 then
                self.resuld2Text.text = TI18N("败")
                self.down2:SetActive(true)
            elseif v.is_win == 3 then
                self.resuld2Text.text = TI18N("平")
                self.ping2:SetActive(true)
            else
                self.resuld2Text.gameObject:SetActive(false)
                self.midText.gameObject:SetActive(true)
                self.VS:SetActive(false)
            end
        end
    end
end

function GuildLeagueFightScheduleItem:Refresh(args)

end

