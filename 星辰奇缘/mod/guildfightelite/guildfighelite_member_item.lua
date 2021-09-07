-- 公会英雄战，领队选择各成员ITEM
-- @author zgs
GuildFightEliteMemberItem = GuildFightEliteMemberItem or BaseClass()

function GuildFightEliteMemberItem:__init(gameObject, panel, type)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.type = type

    self.data = nil
    self.index = 1

    self.panel = panel

    -- self.posImg = self.gameObject.transform:Find("PosImage"):GetComponent(Image)
    -- self.posText = self.gameObject.transform:Find("TxtPos"):GetComponent(Text)
    self.gameObject:GetComponent(Button).onClick:AddListener(function()
        self.tog.isOn = not self.tog.isOn
    end)
    self.nameText = self.gameObject.transform:Find("TxtName"):GetComponent(Text)
    self.wincntText = self.gameObject.transform:Find("TxtWinCnt"):GetComponent(Text)
    self.integralText = self.gameObject.transform:Find("TxtIntergral"):GetComponent(Text)
    self.lastLoginext = self.gameObject.transform:Find("TxtLastLogin"):GetComponent(Text)
    self.lastLoginextState = self.gameObject.transform:Find("TxtLastLoginState"):GetComponent(Text)

    self.headImg = self.gameObject.transform:Find("ImgHead/Img"):GetComponent(Image)
    self.bgImg = self.gameObject.transform:Find("ImgOne"):GetComponent(Image)

    self.tog = self.gameObject.transform:Find("Toggle"):GetComponent(Toggle)
    self.tog.onValueChanged:AddListener(function(status) self:OnCheck(status) end)
end

function GuildFightEliteMemberItem:OnCheck(status)
    if status == true then
        if self.panel.lastChooseItem ~= nil and self.panel.lastChooseItem ~= self then
            self.panel.lastChooseItem.tog.isOn = false
        end
    end
    self.panel.lastChooseItem = self
    local key = BaseUtils.Key(self.data.Rid, self.data.PlatForm, self.data.ZoneId)
    if self.panel.localMenberData[key] ~= nil then
        -- print(" GuildFightEliteMemberItem:OnCheck(status)"..key)
        -- print(status)
        self.panel.localMenberData[key].isTogOn = status
    end
end

function GuildFightEliteMemberItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildFightEliteMemberItem:set_my_index(_index)
    self.index = _index
    if self.index % 2 == 0 then
        self.bgImg.color = ColorHelper.ListItem1
        -- self.nameText.color = ColorHelper.Default
        -- self.wincntText.color = ColorHelper.Default
        -- self.integralText.color = ColorHelper.Default
        -- self.lastLoginext.color = ColorHelper.Default
        -- self.lastLoginextState.color = ColorHelper.Default
    else
        self.bgImg.color = ColorHelper.ListItem2
        -- self.nameText.color = ColorHelper.DefaultButton4
        -- self.wincntText.color = ColorHelper.DefaultButton4
        -- self.integralText.color = ColorHelper.DefaultButton4
        -- self.lastLoginext.color = ColorHelper.DefaultButton4
        -- self.lastLoginextState.color = ColorHelper.DefaultButton4
    end
end

--更新内容
function GuildFightEliteMemberItem:update_my_self(_data, _index)
    self.data = _data
    self:set_my_index(_index)
    local key = BaseUtils.Key(self.data.Rid, self.data.PlatForm, self.data.ZoneId)
    if self.panel.localMenberData[key] ~= nil and self.panel.localMenberData[key].isTogOn == true then
        -- print(key.._index)
        self.tog.isOn = true
    else
        self.tog.isOn = false
    end
    local v = self.data
    -- print( string.format("%s_%s",tostring(v.classes),tostring(v.sex)))
    self.headImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(v.Classes),tostring(v.Sex)))

    -- if _index < 4 then
    --     self.posImg.gameObject:SetActive(true)
    --     self.posText.gameObject:SetActive(false)
    --     self.posImg.sprite = self.panel.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_".._index)
    -- else
    --     self.posImg.gameObject:SetActive(false)
    --     self.posText.gameObject:SetActive(true)
    --     self.posText.text = tostring(_index)
    -- end

    if v.Status == 1 then
        --在线啊
        self.nameText.text = self.data.Name
        self.wincntText.text = tostring(self.data.Lev)
        self.integralText.text = self:checkPos(self.data)
        self.lastLoginext.text = tostring(self.data.fc)

        self.lastLoginextState.text = TI18N("在线")
    else
        self.nameText.text = string.format("<color='#808080'>%s</color>", v.Name)
        self.wincntText.text = string.format("<color='#808080'>%s</color>", tostring(v.Lev))
        local strTemp ,bo = self:checkPos(self.data)
        if bo == false then
            self.integralText.text = string.format("<color='#808080'>%s</color>", GuildManager.Instance.model.member_position_names[v.Post])
        else
            self.integralText.text  = strTemp
        end
        self.lastLoginext.text = string.format("<color='#808080'>%s</color>", v.fc)

        local time = os.date("*t", v.LastLogin)
        self.lastLoginextState.text = string.format("<color='#808080'>%s</color>", string.format("%s-%s-%s", time.year, time.month, time.day))
    end
end

function GuildFightEliteMemberItem:checkPos(roleData)
    if self.type == 1 then
        -- 当用于冠军联赛的时候
        local bool, pos = GuildLeagueManager.Instance:IsKingTeam(roleData)
        if bool then
            return string.format(TI18N("<color='#ffff00'>%s号王牌领队</color>"), tostring(pos)), true
        end
        return GuildManager.Instance.model.member_position_names[roleData.Post], bool

    end
    for i,v in ipairs(GuildFightEliteManager.Instance.eliteLeaderInfo) do
        if BaseUtils.Key(roleData.Rid, roleData.PlatForm, roleData.ZoneId) == BaseUtils.Key(v.rid, v.platform, v.zone_id) then
            if v.position == 1 then
                return TI18N("<color='#ffff00'>月亮领队</color>") ,true
            elseif v.position == 2 then
                return TI18N("<color='#ffff00'>太阳领队</color>") ,true
            elseif v.position == 3 then
                return TI18N("<color='#ffff00'>星辰领队</color>"),true
            end
        end
    end
    return GuildManager.Instance.model.member_position_names[roleData.Post] ,false
end
