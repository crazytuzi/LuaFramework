QualifyMainRankItem = QualifyMainRankItem or BaseClass()

function QualifyMainRankItem:__init(gameObject, args)
    self.gameObject = gameObject
    self.data = nil
    self.args = args

    self.transform = self.gameObject.transform

    self.bg = self.transform:FindChild("bg"):GetComponent(Image)
    self.selBg = self.transform:FindChild("selBg").gameObject
    self.TxtIndex = self.transform:FindChild("TxtIndex"):GetComponent(Text)
    self.ImgIndex3 = self.transform:FindChild("ImgIndex3").gameObject
    self.ImgIndex2 = self.transform:FindChild("ImgIndex2").gameObject
    self.ImgIndex1 = self.transform:FindChild("ImgIndex1").gameObject
    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtZone = self.transform:FindChild("TxtZone"):GetComponent(Text)
    self.TxtNum = self.transform:FindChild("TxtNum"):GetComponent(Text)
    self.TxtRate = self.transform:FindChild("TxtRate"):GetComponent(Text)

    self.TxtIndex.supportRichText = true
    self.TxtIndex.gameObject:SetActive(false)
    self.ImgIndex3:SetActive(false)
    self.ImgIndex2:SetActive(false)
    self.ImgIndex1:SetActive(false)

    -- args.item_index
end

function QualifyMainRankItem:Release()

end

function QualifyMainRankItem:Refresh(args)

end

function QualifyMainRankItem:InitPanel(_data)
    if _data == nil then
        return
    end
    self.data = _data.data
    self.ImgIndex1:SetActive(false)
    self.ImgIndex2:SetActive(false)
    self.ImgIndex3:SetActive(false)
    self.TxtIndex.gameObject:SetActive(false)
    if _data.item_index == 1 then
        self.ImgIndex1:SetActive(true)
    elseif _data.item_index == 2 then
        self.ImgIndex2:SetActive(true)
    elseif _data.item_index == 3 then
        self.ImgIndex3:SetActive(true)
    else
        self.TxtIndex.gameObject:SetActive(true)
        self.TxtIndex.text = string.format(ColorHelper.ListItemStr, tostring(_data.item_index))
    end

    if _data.item_index%2 == 0 then
        --偶数
        self.bg.color = ColorHelper.ListItem1
    else
        --单数
        self.bg.color = ColorHelper.ListItem2
    end

    local name_str = DataQualifying.data_qualify_data_list[self.data.rank_lev].lev_name

    local name_t = StringHelper.ConvertStringTable(name_str)
    name_str = ""
    for i=3, #name_t do
        name_str = string.format("%s%s", name_str, name_t[i])
    end
    self.TxtNum.text = string.format(ColorHelper.ListItemStr, string.format("%s\n(%s)", name_str, self.data.rank_point)) --分数
    self.TxtRate.text = string.format(ColorHelper.ListItemStr, string.format("%s/%s", self.data.season_win_count, self.data.season_combat_count))

    self.TxtName.text = string.format(ColorHelper.ListItemStr, self.data.name)
    self.TxtZone.text = string.format(ColorHelper.ListItemStr, string.format("%s%s", self.data.zone_id, TI18N("区")))
end