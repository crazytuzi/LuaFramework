CombatVedioItem = CombatVedioItem or BaseClass()

function CombatVedioItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.parent = parent
    self.transform = self.gameObject.transform
    self.ImgBg = self.transform:GetComponent(Image)

    self.ImgHead1 = self.transform:Find("ImgHead1")
    self.ImgHeadSprite1 = self.transform:Find("ImgHead1/Img"):GetComponent(Image)
    self.TxtName1 = self.transform:Find("TxtName1"):GetComponent(Text)
    self.ImgHead2 = self.transform:Find("ImgHead2")
    self.ImgHeadSprite2 = self.transform:Find("ImgHead2/Img"):GetComponent(Image)
    self.TxtName2 = self.transform:Find("TxtName2"):GetComponent(Text)
    self.TxtLev = self.transform:Find("TxtLev"):GetComponent(Text)
    self.TxtMark = self.transform:Find("TxtMark"):GetComponent(Text)
    self.TxtPlay = self.transform:Find("TxtPlay"):GetComponent(Text)

    self.transform:Find("TxtName2"):GetComponent(RectTransform).sizeDelta = Vector2(102, 30)
    self.transform:Find("TxtName2"):GetComponent(RectTransform).anchoredPosition = Vector2(6.5, 0)
    self.item_index = 1
    self.transform:GetComponent(Button).onClick:AddListener(function()
        CombatManager.Instance:Send10753(self.data.type, self.data.rec_id, self.data.platform, self.data.zone_id)
    end)
end

function CombatVedioItem:Release()
    self.ImgHeadSprite1.sprite = nil
    self.ImgHeadSprite2.sprite = nil
end

--设置索引
function CombatVedioItem:SetMyIndex(index)
    self.item_index = index
    if self.item_index%2 == 0 then  --偶数
        self.ImgBg.color = Color(155/255, 199/255, 239/255, 1)
    else --单数
        self.ImgBg.color = Color(129/255, 179/255, 233/255, 1)
    end
end

--更新内容
function CombatVedioItem:update_my_self(data, index)
    self.data = data
    self:SetMyIndex(index)
    -- self.parent.currentMain
    -- self.parent.currentSub

    --玩家就有头像，不是玩家就没有头像
    if data.atk_classes == 0 then
        --没攻击者头像数据
        self.ImgHead1.gameObject:SetActive(false)
    else
        self.ImgHead1.gameObject:SetActive(true)
        self.ImgHeadSprite1.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(data.atk_classes),tostring(data.atk_sex)))
    end
    if data.dfd_classes == 0 then
        --没防御者头像数据
        self.ImgHead2.gameObject:SetActive(false)
    else
        self.ImgHead2.gameObject:SetActive(true)
        self.ImgHeadSprite2.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(data.dfd_classes),tostring(data.dfd_sex)))
    end
    --
    -- self.ImgHead2
    self.TxtName1.text = data.atk_name
    self.TxtName2.text = data.dfd_name
    self.TxtLev.text = tostring(data.avg_lev)

    self.TxtPlay.text = tostring(data.replayed)

    -- if data.atk_name == "随忆" and data.dfd_name == "镜魔" then
    --     print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk")
    --     BaseUtils.dump(data)
    -- end

    if data.combat_type == 110 or data.combat_type == 111 then
        self.TxtMark.text = TI18N("诸神之战")
    else
        self.TxtMark.text = Combat_Type[data.combat_type]--tostring(data.liked)
    end
    -- ,{uint8,   combat_type, "战斗类型"}
end