-- 公会宝箱分配，每项ITEM
-- @author zgs
GuildFightBoxMenberItem = GuildFightBoxMenberItem or BaseClass()

function GuildFightBoxMenberItem:__init(gameObject, panel, isleague)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.isleague = isleague
    self.data = nil
    self.index = 1

    self.panel = panel

    self.isNeedShowTips = true

    self.nameText = self.gameObject.transform:Find("TxtName"):GetComponent(Text)
    self.levText = self.gameObject.transform:Find("TxtLev"):GetComponent(Text)
    self.posText = self.gameObject.transform:Find("TxtPos"):GetComponent(Text)
    self.gxText = self.gameObject.transform:Find("TxtGx"):GetComponent(Text)
    self.cupText = self.gameObject.transform:Find("TxtCup"):GetComponent(Text)
    self.lastLoginext = self.gameObject.transform:Find("TxtLastLogin"):GetComponent(Text)
    self.headImg = self.gameObject.transform:Find("ImgHead/Img"):GetComponent(Image)
    self.headImg.gameObject:SetActive(false)
    self.bgImg = self.gameObject.transform:Find("ImgOne"):GetComponent(Image)
    self.tog = self.gameObject.transform:Find("Toggle"):GetComponent(Toggle)
    self.tog.onValueChanged:AddListener(function(status) self:OnCheck(status) end)
end

function GuildFightBoxMenberItem:OnCheck(status)
    -- Log.Error("==================================")
    local key = BaseUtils.Key(self.data.Rid, self.data.PlatForm, self.data.ZoneId)
    -- print(key)
    if self.panel.localMenberData[key] ~= nil then
        self.panel.localMenberData[key].isTogOn = status
        -- print(self.panel.localMenberData[key].isTogOn)
    end
    self.cntSelected = 0
    for k,v in pairs(self.panel.localMenberData) do
        if v.isTogOn == true then
            self.cntSelected = self.cntSelected + 1
        end
    end
    if status == true then
        if self.panel.countTotal >= self.cntSelected then
            -- self.panel.countTotal = self.panel.countTotal - 1
            self.panel.remindText.text = string.format(TI18N("库存:<color='#2fc823'>%d</color>/50"),(self.panel.countTotal - self.cntSelected))
        else
            -- self.panel.countTotal = self.panel.countTotal - 2 --触发两次false??
            self.tog.isOn = false
            if self.isNeedShowTips == true then
                NoticeManager.Instance:FloatTipsByString(TI18N("库存都没可分配的宝箱"))
            end
        end
    else
        -- self.panel.countTotal = self.panel.countTotal + 1
        self.panel.remindText.text = string.format(TI18N("库存:<color='#2fc823'>%d</color>/50"), (self.panel.countTotal - self.cntSelected))
    end
    self.isNeedShowTips = true
end

function GuildFightBoxMenberItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildFightBoxMenberItem:set_my_index(_index)
    self.index = _index
    if self.index % 2 == 0 then
        self.bgImg.color = ColorHelper.ListItem1
    else
        self.bgImg.color = ColorHelper.ListItem2
    end
end

--更新内容
function GuildFightBoxMenberItem:update_my_self(_data, _index)
    self.data = _data
    self:set_my_index(_index)
    -- self.tog.isOn = self.lastTogOn
    local key = BaseUtils.Key(self.data.Rid, self.data.PlatForm, self.data.ZoneId)
    if self.panel.localMenberData[key] ~= nil and self.panel.localMenberData[key].isTogOn == true then
        self.isNeedShowTips = false
        self.tog.isOn = true
    else
        self.tog.isOn = false
    end
    local v = self.data
    self.headImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(v.Classes),tostring(v.Sex)))
    self.headImg.gameObject:SetActive(true)
    if v.Status == 1 then
        --在线啊
        self.nameText.text = v.Name
        self.levText.text = tostring(v.Lev)
        self.posText.text = GuildManager.Instance.model.member_position_names[v.Post]
        self.gxText.text = string.format("%s/%s", v.TotalGx , v.GongXian)
        self.cupText.text = tostring(v.guildWarScore)

        self.lastLoginext.text = TI18N("在线")
    else
        -- self.nameText.text = string.format("<color='#808080'>%s</color>", v.Name)
        -- self.levText.text = string.format("<color='#808080'>%s</color>", tostring(v.Lev))
        -- self.posText.text = string.format("<color='#808080'>%s</color>", GuildManager.Instance.model.member_position_names[v.Post])
        -- self.gxText.text = string.format("<color='#808080'>%s</color>", string.format("%s/%s",v.TotalGx, v.GongXian))
        -- self.cupText.text = string.format("<color='#808080'>%s</color>", tostring(v.cup))
        self.nameText.text = v.Name
        self.levText.text = tostring(v.Lev)
        self.posText.text = GuildManager.Instance.model.member_position_names[v.Post]
        self.gxText.text = string.format("%s/%s", v.TotalGx , v.GongXian)
        self.cupText.text = tostring(v.guildWarScore)

        local time = os.date("*t", v.LastLogin)
        self.lastLoginext.text = string.format("<color='#808080'>%s</color>", string.format("%s-%s-%s", time.year, time.month, time.day))
    end
    if self:CheckIsGet(v) == true then
        self.nameText.text = string.format("<color='#808080'>%s</color>", v.Name)
        self.levText.text = string.format("<color='#808080'>%s</color>", tostring(v.Lev))
        self.posText.text = string.format("<color='#808080'>%s</color>", GuildManager.Instance.model.member_position_names[v.Post])
        self.gxText.text = string.format("<color='#808080'>%s</color>", string.format("%s/%s",v.TotalGx, v.GongXian))
        self.cupText.text = string.format("<color='#808080'>%s</color>", tostring(v.guildWarScore))
    end
    if self.isleague then
        self.cupText.gameObject:SetActive(false)
    end
end

function GuildFightBoxMenberItem:CheckIsGet(data)
    -- BaseUtils.dump(data,"GuildFightBoxMenberItem:Chec44444444444444444kIsGet(data)")
    for i,v in ipairs(self.panel.model.guildLoot.allocated) do
        if data.Rid == v.rid and data.PlatForm == v.r_platform and data.ZoneId == v.r_zone_id then
            return true
        end
    end
    return false
end
