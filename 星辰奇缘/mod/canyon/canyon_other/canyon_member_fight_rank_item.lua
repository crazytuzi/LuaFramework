-- 峡谷之巅排行榜单条item
-- @author hze
-- @date 2018/07/23

CanYonMemberFightRankItem = CanYonMemberFightRankItem or BaseClass()

function CanYonMemberFightRankItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform

    self.parent = parent

    self.data = nil
    self.index = 1

    self.posImg = self.transform:Find("PosImage"):GetComponent(Image)
    self.posText = self.transform:Find("TxtPos"):GetComponent(Text)
    self.nameText = self.transform:Find("TxtName"):GetComponent(Text)
    self.wincntText = self.transform:Find("TxtWinCnt"):GetComponent(Text)
    self.integralText = self.transform:Find("TxtIntergral"):GetComponent(Text)
    self.lastLoginext = self.transform:Find("TxtLastLogin"):GetComponent(Text)
    self.headImg = self.transform:Find("ImgHead/Img"):GetComponent(Image)
    self.bgImg = self.transform:Find("ImgOne"):GetComponent(Image)
    self.lookBtn = self.transform:Find("LookBtn"):GetComponent(Button)
    self.lookBtn.onClick:AddListener(function() self:ShowTeamNumber() end)
end

function CanYonMemberFightRankItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function CanYonMemberFightRankItem:set_my_index(_index)
    self.index = _index
    if self.index % 2 == 0 then
        self.bgImg.color = ColorHelper.ListItem1
    else
        self.bgImg.color = ColorHelper.ListItem2
    end
end

--更新内容
function CanYonMemberFightRankItem:update_my_self(_data, _index)
    self.data = _data
    self:set_my_index(_index)
    self.headImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(self.data.classes),tostring(self.data.sex)))

    self.lookBtn.gameObject:SetActive(self.parent.showTeamInfo)

    if _index < 4 then
        self.posImg.gameObject:SetActive(true)
        self.posText.gameObject:SetActive(false)
        self.posImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_".._index)
    else
        self.posImg.gameObject:SetActive(false)
        self.posText.gameObject:SetActive(true)
        self.posText.text = tostring(_index)
    end

    self.nameText.text = self.data.name
    self.wincntText.text = tostring(self.data.score)
    self.integralText.text = tostring(self.data.movability)
    self.lastLoginext.text = CanYonEumn.CampNames[self.data.side]
end

function CanYonMemberFightRankItem:ShowTeamNumber()
    --查看队伍信息
    -- self.model:OpenCanYonOtherTeamPanle(self.data)
end
