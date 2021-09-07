-- 公会战战绩排行 ，每项ITEM
-- @author zgs
GuildFightIntegralItem = GuildFightIntegralItem or BaseClass()

function GuildFightIntegralItem:__init(gameObject, panel)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform

    self.data = nil
    self.index = 1

    self.panel = panel

    self.posImg = self.gameObject.transform:Find("PosImage"):GetComponent(Image)
    self.posText = self.gameObject.transform:Find("TxtPos"):GetComponent(Text)
    self.nameText = self.gameObject.transform:Find("TxtName"):GetComponent(Text)
    self.wincntText = self.gameObject.transform:Find("TxtWinCnt"):GetComponent(Text)
    self.integralText = self.gameObject.transform:Find("TxtIntergral"):GetComponent(Text)
    self.lastLoginext = self.gameObject.transform:Find("TxtLastLogin"):GetComponent(Text)

    self.headImg = self.gameObject.transform:Find("ImgHead/Img"):GetComponent(Image)
    self.bgImg = self.gameObject.transform:Find("ImgOne"):GetComponent(Image)
end

function GuildFightIntegralItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildFightIntegralItem:set_my_index(_index)
    self.index = _index
    if self.index % 2 == 0 then
        self.bgImg.color = ColorHelper.ListItem1 --Color32(43,74,105,255)
    else
        self.bgImg.color = ColorHelper.ListItem2 --Color32(50,91,131,255)
    end
end

--更新内容
function GuildFightIntegralItem:update_my_self(_data, _index)
    self.data = _data
    self:set_my_index(_index)
    local v = self.data
    print( string.format("%s_%s",tostring(v.classes),tostring(v.sex)))
    self.headImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(v.classes),tostring(v.sex)))

    if _index < 4 then
        self.posImg.gameObject:SetActive(true)
        self.posText.gameObject:SetActive(false)
        self.posImg.sprite = self.panel.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_".._index)
    else
        self.posImg.gameObject:SetActive(false)
        self.posText.gameObject:SetActive(true)
        self.posText.text = tostring(_index)
    end

    self.nameText.text = self.data.name
    self.wincntText.text = tostring(self.data.win)
    self.integralText.text = tostring(self.data.score)
    self.lastLoginext.text = tostring(self.data.movability)
end