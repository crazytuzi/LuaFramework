CrossArenaLogItem = CrossArenaLogItem or BaseClass()

function CrossArenaLogItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.parent = parent
    self.transform = self.gameObject.transform
    self.ImgBg = self.transform:GetComponent(Image)

    self.TxtTime = self.transform:Find("TxtTime"):GetComponent(Text)
    self.ImgHead1 = self.transform:Find("ImgHead1")
    self.ImgHeadSprite1 = self.transform:Find("ImgHead1/Img"):GetComponent(Image)
    self.TxtName1 = self.transform:Find("TxtName1"):GetComponent(Text)
    self.ImgHead2 = self.transform:Find("ImgHead2")
    self.ImgHeadSprite2 = self.transform:Find("ImgHead2/Img"):GetComponent(Image)
    self.TxtName2 = self.transform:Find("TxtName2"):GetComponent(Text)
    self.TxtLev = self.transform:Find("TxtLev"):GetComponent(Text)
    self.TxtMark = self.transform:Find("TxtMark"):GetComponent(Text)
    self.ImgMvp = self.transform:FindChild("ImgMvp"):GetComponent(Image)
    self.transform:Find("BtnLook"):GetComponent(Button).onClick:AddListener(function()
            CrossArenaManager.Instance:Send20716(self.data.r_id, self.data.r_platform, self.data.r_zone_id)
        end)
    self.transform:GetComponent(Button).onClick:AddListener(function()
            CrossArenaManager.Instance:Send20716(self.data.r_id, self.data.r_platform, self.data.r_zone_id)
        end)

    self.item_index = 1
end

function CrossArenaLogItem:Release()
    self.ImgHeadSprite1.sprite = nil
    self.ImgHeadSprite2.sprite = nil
end

--设置索引
function CrossArenaLogItem:SetMyIndex(index)
    self.item_index = index
    if self.item_index%2 == 0 then  --偶数
        self.ImgBg.color = Color(155/255, 199/255, 239/255, 1)
    else --单数
        self.ImgBg.color = Color(129/255, 179/255, 233/255, 1)
    end
end

--更新内容
function CrossArenaLogItem:update_my_self(data, index)
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
    -- self.TxtLev.text = tostring(data.avg_lev)

    local dis = BaseUtils.BASE_TIME - data.time
    if dis < 60 then
        self.TxtTime.text = TI18N("1分钟前")
    elseif dis < 3600 then
        self.TxtTime.text = string.format(TI18N("%s分钟前"), math.ceil(dis / 60))
    elseif dis < 86400 then
        self.TxtTime.text = string.format(TI18N("%s小时前"), math.ceil(dis / 3600))
    else
        self.TxtTime.text = string.format(TI18N("%s天前"), math.ceil(dis / 86400))
    end

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

    local mvpSprite = ""
    if self.data.best_result == 1 then
        mvpSprite = "I18NGodLike"
    elseif self.data.best_result == 2 then
        mvpSprite = "Attacker"
    elseif self.data.best_result == 3 then
        mvpSprite = "Killer"
    elseif self.data.best_result == 4 then
        mvpSprite = "Mvp"
    elseif self.data.best_result == 5 then
        mvpSprite = "Defender"
    elseif self.data.best_result == 6 then
        mvpSprite = "Ctr"
    end
    if mvpSprite == "" then
        self.ImgMvp.gameObject:SetActive(false)
    else
        self.ImgMvp.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.no1inworld_textures , mvpSprite)
        self.ImgMvp.gameObject:SetActive(true)
    end
end