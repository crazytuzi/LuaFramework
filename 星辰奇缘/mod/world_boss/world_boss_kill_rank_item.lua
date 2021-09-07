WorldBossKillRankItem = WorldBossKillRankItem or BaseClass()

function WorldBossKillRankItem:__init(gameObject, parent)
    self.parent = parent
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(true)

    self.ImgIndex1 = self.gameObject.transform:FindChild("ImgIndex1").gameObject
    self.ImgIndex2 = self.gameObject.transform:FindChild("ImgIndex2").gameObject
    self.ImgIndex3 = self.gameObject.transform:FindChild("ImgIndex3").gameObject

    self.TxtIndex = self.gameObject.transform:FindChild("TxtIndex"):GetComponent(Text)
    self.HeadCon = self.gameObject.transform:FindChild("HeadCon").gameObject
    self.Head = self.HeadCon.transform:FindChild("Img"):GetComponent(Image)
    self.TxtName = self.gameObject.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtScene = self.gameObject.transform:FindChild("TxtScene"):GetComponent(Text)
    self.BtnBack = self.gameObject.transform:FindChild("BtnBack"):GetComponent(Button)

    self.Head.gameObject:SetActive(false)

    self.BtnBack.onClick:AddListener(function() self:on_click_btn_back() end)
end

function WorldBossKillRankItem:Release()
    self.Head.sprite  = nil
end

function WorldBossKillRankItem:InitPanel(_data)

end


function WorldBossKillRankItem:on_click_btn_back()
    if self.data.type == 1 then
        WorldBossManager.Instance:request13003(self.parent.model.boss_rank_id, self.data.finished)
    elseif self.data.type == 2 then
        WorldBossManager.Instance:request13006(self.parent.model.boss_rank_id)
    elseif self.data.type == 3 then
        WorldBossManager.Instance:request13005(self.data.rid, self.data.platform, self.data.zone_id, self.parent.model.boss_rank_id)
    end
end

function WorldBossKillRankItem:update_my_self(data, item_index)
    self.data = data
    if data.index == 1 then
        self.ImgIndex1:SetActive(true)
        self.ImgIndex2:SetActive(false)
        self.ImgIndex3:SetActive(false)
        self.TxtIndex.gameObject:SetActive(false)
    elseif data.index == 2 then
        self.ImgIndex1:SetActive(false)
        self.ImgIndex2:SetActive(true)
        self.ImgIndex3:SetActive(false)
        self.TxtIndex.gameObject:SetActive(false)
    elseif data.index == 3 then
        self.ImgIndex1:SetActive(false)
        self.ImgIndex2:SetActive(false)
        self.ImgIndex3:SetActive(true)
        self.TxtIndex.gameObject:SetActive(false)
    else
        self.ImgIndex1:SetActive(false)
        self.ImgIndex2:SetActive(false)
        self.ImgIndex3:SetActive(false)
        self.TxtIndex.gameObject:SetActive(true)
        self.TxtIndex.text = tostring(data.index)
    end

    self.TxtName.text = data.name
    self.TxtScene.text = string.format(TI18N("%s回合"), data.round)

    self.Head.sprite =self.parent.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s",tostring(data.classes),tostring(data.sex)))
    self.Head.gameObject:SetActive(true)
end