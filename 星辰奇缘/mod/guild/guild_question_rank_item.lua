GuildQuestionRankItem = GuildQuestionRankItem or BaseClass()

function GuildQuestionRankItem:__init(parent, originItem, data, index)
    self.args = args


    self.index = index
    self.gameObject = ctx:InstantiateAndSet(originItem.transform.parent.gameObject, originItem)
    self.gameObject:SetActive(true)
    self.bg = self.gameObject:GetComponent(Image)
    self.ImgCup1 = self.gameObject.transform:FindChild("ImgCup1").gameObject
    self.ImgCup2 = self.gameObject.transform:FindChild("ImgCup2").gameObject
    self.ImgCup3 = self.gameObject.transform:FindChild("ImgCup3").gameObject
    self.TxtIndex = self.gameObject.transform:FindChild("TxtIndex"):GetComponent(Text)
    self.ImgHeadCon = self.gameObject.transform:FindChild("ImgHeadCon").gameObject
    self.ImgHead = self.ImgHeadCon.transform:FindChild("ImgHead"):GetComponent(Image)
    self.TxtName = self.gameObject.transform:FindChild("TxtName"):GetComponent(Text)
    self.ImgTotem = self.gameObject.transform:FindChild("ImgTotem"):GetComponent(Image)
    self.TxtGuildName = self.gameObject.transform:FindChild("TxtGuildName"):GetComponent(Text)
    self.ImgScore = self.gameObject.transform:FindChild("ImgScore").gameObject
    self.self.TxtNum = self.ImgScore.transform:FindChild("TxtNum"):GetComponent(Text)


    if index%2 == 0 then
        --偶数
        item.bg.color = ColorHelper.ListItem1
    else
        --单数
        item.bg.color = ColorHelper.ListItem2
    end

    self:set_rank_item_data(data)
end

function GuildQuestionRankItem:Release()
    self.ImgHead.sprite  = nil
    self.ImgTotem.sprite = nil
end

function GuildQuestionRankItem:InitPanel()

end


function GuildQuestionRankItem:set_rank_item_data(data)
    self.data = data

    self.ImgCup1.gameObject:SetActive(false)
    self.ImgCup2.gameObject:SetActive(false)
    self.ImgCup3.gameObject:SetActive(false)
    self.TxtIndex.gameObject:SetActive(false)
    if self.index == 1 then
        self.ImgCup1.gameObject:SetActive(true)
    elseif self.index == 2 then
        self.ImgCup2.gameObject:SetActive(true)
    elseif self.index == 3 then
        self.ImgCup3.gameObject:SetActive(true)
    else
        self.TxtIndex.gameObject:SetActive(true)
        self.TxtIndex.text = tostring(self.index)
    end

    self.TxtName.text = string.format(ColorHelper.ListItemStr, data.name)
    self.TxtGuildName.text = string.format(ColorHelper.ListItemStr, data.guild_name)
    self.self.TxtNum.text = string.format(ColorHelper.ListItemStr, tostring(data.score))

    self.ImgHead.sprite = ctx.ResourcesManager:GetSprite(config.resources.heads, string.format("%s_%s",tostring(self.data.classes),tostring(self.data.sex)))

    self.ImgTotem.sprite = ctx.ResourcesManager:GetSprite(config.resources.guild_totem_icon, tostring(self.data.totem_id))
end