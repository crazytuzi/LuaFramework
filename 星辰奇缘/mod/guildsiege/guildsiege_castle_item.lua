-- @author 黄耀聪
-- @date 2017年2月22日

-- 一座城

GuildSiegeCastleItem = GuildSiegeCastleItem or BaseClass()

function GuildSiegeCastleItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform

    self.titleText = t:Find("Title/Classes/Title"):GetComponent(Text)
    self.titleText1 = t:Find("Title/Classes/Title1"):GetComponent(Text)
    self.titleText2 = t:Find("Title/Title2"):GetComponent(Text)
    self.titleText3 = t:Find("Title/Title3"):GetComponent(Text)
    self.titleTrans = t:Find("Title")
    self.houseImage = t:Find("House"):GetComponent(Image)
    self.houseImage.transform.sizeDelta = Vector2(100, 100)
    self.starBg = t:Find("StarBg").gameObject
    self.starList = {t:Find("StarBg/Star1"):GetComponent(Image), t:Find("StarBg/Star2"):GetComponent(Image), t:Find("StarBg/Star3"):GetComponent(Image)}
    self.classImage = t:Find("Title/Classes"):GetComponent(Image)
    self.defend = t:Find("Defend")
    self.defendText = t:Find("Defend/Text"):GetComponent(Text)
    self.btn = gameObject:GetComponent(Button)
end

function GuildSiegeCastleItem:__delete()
    self.gameObject = nil
    self.assetWrapper = nil
    self.data = nil
    self.classImage.sprite = nil
    self.houseImage.sprite = nil
    for _,star in ipairs(self.starList) do
        star.sprite = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.shieldEffect ~= nil then
        self.shieldEffect:DeleteMe()
        self.shieldEffect = nil
    end
    if self.destroyEffect ~= nil then
        self.destroyEffect:DeleteMe()
        self.destroyEffect = nil
    end
end

function GuildSiegeCastleItem:SetData(data, index)
    self:update_my_self(data, index)
end

function GuildSiegeCastleItem:update_my_self(data, index)
    -- BaseUtils.dump(data, "Castle")
    self.data = data
    local castleData = DataGuildSiege.data_castle[data.order] or {x = 0, y = 0, type = 0}
    self.transform.anchoredPosition = Vector2(castleData.x, -castleData.y) -- / (self.transform.parent.parent.rect.width / 960))

    if data.type == 1 then
        self.titleText.text = string.format("<color='#23f0f7'>%s.%s</color>", data.order, data.name)
    else
        self.titleText.text = string.format("<color='#ff5e58'>%s.%s</color>", data.order, data.name)
    end
    self.titleText1.text = string.format("%s.%s", data.order, data.name)
    if castleData.type == 0 then
        self.titleText2.text = string.format("[%s]", GuildSiegeEumn.CastleType[castleData.type])
        self.titleText3.text = string.format("[%s]",  GuildSiegeEumn.CastleType[castleData.type])
    else
        self.titleText2.text = string.format(TI18N("<color='#d781f2'>[%s]</color>"), GuildSiegeEumn.CastleType[castleData.type])
        self.titleText3.text = string.format(TI18N("[%s]"), GuildSiegeEumn.CastleType[castleData.type])
    end

    for i=1,3 do
        if i <= data.loss_star then
            self.starList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star")
        else
            self.starList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "DarkStar")
        end
    end

    if castleData.type == 1 then -- 侦查岗哨
        if data.loss_star ~= 3 then
            if self.effect ~= nil then
                self.effect:DeleteMe()
            end
            self.effect = BibleRewardPanel.ShowEffect(20307, self.transform, Vector3(1, 1, 1), Vector3(0, 76, -400))
            self:ResetTitlePos(true)
        else
            if self.effect ~= nil then
                self.effect:DeleteMe()
                self.effect = nil
            end
            self:ResetTitlePos(false)
        end
    elseif castleData.type == 2 then -- 军团连锁
        if data.loss_star ~= 3 then
            self:SetShild(true, true)
        else
            self:SetShild(false, true)
        end
    elseif castleData.type == 3 then -- 荣耀之地
        if data.loss_star ~= 3 then
            if self.effect ~= nil then
                self.effect:DeleteMe()
            end
            self.effect = BibleRewardPanel.ShowEffect(20308, self.transform, Vector3(1, 1, 1), Vector3(0, 76, -400))
            self:ResetTitlePos(true)
        else
            if self.effect ~= nil then
                self.effect:DeleteMe()
                self.effect = nil
            end
            self:ResetTitlePos(false)
        end
    else
        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end
        self:ResetTitlePos(false)
    end

    if data.loss_star == 3 then
        if castleData.type == 0 then
            self.houseImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Destroyed0")
        else
            self.houseImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Destroyed")
        end
        if self.destroyEffect ~= nil then
            self.destroyEffect:SetActive(true)
        else
            self.destroyEffect = BibleRewardPanel.ShowEffect(20326, self.transform, Vector3(1, 1, 1), Vector3(-16, 18, -400))
        end
    else
        if self.destroyEffect ~= nil then
            self.destroyEffect:SetActive(false)
        end
        self.houseImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Castle" .. castleData.type)
    end
    self.classImage.sprite = PreloadManager.Instance:GetClassesSprite(data.classes)

    -- self.classImage.transform.anchoredPosition = Vector2(-(self.classImage.transform.sizeDelta.x + self.titleText.preferredWidth + self.titleText.transform.anchoredPosition.x) / 2, -17)
    self.classImage.enabled = false
    self.classImage.transform.anchoredPosition = Vector2(-(2 * self.classImage.transform.sizeDelta.x + self.titleText.preferredWidth + self.titleText.transform.anchoredPosition.x) / 2, -17)

    if data.is_combat == 1 then
        if self.effect ~= nil then
            self.effect:DeleteMe()
        end
        self.effect = BibleRewardPanel.ShowEffect(10096, self.transform, Vector3(150, 150, 1), Vector3(0, 55, -400))
        self:ResetTitlePos(true)
    end

    self.defend.gameObject:SetActive(data.def_win_times >= 3)
    self.defendText.text = data.def_win_times
end

function GuildSiegeCastleItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

-- 获取y的区间
function GuildSiegeCastleItem:GetSectionY()
    local pivotY = self.transform.pivot.y
    local posY = self.transform.anchoredPosition.y
    local sizeY = self.transform.sizeDelta.y
    return posY - (1 - pivotY) * sizeY, posY + pivotY * sizeY
end

-- 盾牌特效
function GuildSiegeCastleItem:SetShild(bool, bigger)
    -- local scale = nil
    -- if bigger == true then
    --     if self.shieldEffect == nil then
    --         self.shieldEffect = BibleRewardPanel.ShowEffect(20306, self.transform, Vector3(1, 1, 1), Vector3(0, 21, -400))
    --     else
    --         self.shieldEffect:SetActive(true)
    --     end
    -- else
    --     if self.shieldEffect == nil then
    --         self.shieldEffect = BibleRewardPanel.ShowEffect(20323, self.transform, Vector3(1, 1, 1), Vector3(0, 21, -400))
    --     else
    --         self.shieldEffect:SetActive(true)
    --     end
    -- end
    if bool == true and self.data.loss_data ~= 3 then
        if self.shieldEffect == nil then
            if bigger == true then
                self.shieldEffect = BibleRewardPanel.ShowEffect(20323, self.transform, Vector3(1, 1, 1), Vector3(0, 21, -400))
                self:ResetTitlePos(true)
            else
                self.shieldEffect = BibleRewardPanel.ShowEffect(20306, self.transform, Vector3(1, 1, 1), Vector3(0, 21, -400))
                self:ResetTitlePos(false)
            end
        else
            self.shieldEffect:SetActive(true)
        end
    else
        if self.shieldEffect ~= nil then
            self.shieldEffect:SetActive(false)
        end
    end
end

function GuildSiegeCastleItem:ResetTitlePos(bool)
    if bool == true then
        self.titleTrans.anchoredPosition = Vector2(0, 90)
    else
        -- self.titleText.transform.anchoredPosition = Vector2(14, 125)
        -- self.titleText1.transform.anchoredPosition = Vector2(14, 124)
        -- self.titleText2.transform.anchoredPosition = Vector2(0, 101)
        -- self.titleText3.transform.anchoredPosition = Vector2(0, 102)

        self.titleTrans.anchoredPosition = Vector2(0, 48)
    end
end

function GuildSiegeCastleItem:HideEffects()
    if self.shieldEffect ~= nil then
        self.shieldEffect:SetActive(false)
    end
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

