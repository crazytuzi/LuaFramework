-- @author 黄耀聪
-- @date 2017年11月14日, 星期二

GuildDragonSlayer = GuildDragonSlayer or BaseClass()

function GuildDragonSlayer:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.assetWrapper = assetWrapper

    local t = self.transform
    self.bgImage = t:Find("Bg"):GetComponent(Image)
    self.rankText = t:Find("Rank"):GetComponent(Text)
    self.rankImage = t:Find("RankImage"):GetComponent(Image)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.scoreText = t:Find("Score/Text"):GetComponent(Text)
    self.classExt = MsgItemExt.New(t:Find("Score/Classes"):GetComponent(Text), 210, 16, 18.5)
    self.headSlot = HeadSlot.New()
    NumberpadPanel.AddUIChild(t:Find("Head"), self.headSlot.gameObject)
    self.levText = t:Find("Lev/Text"):GetComponent(Text)
    self.button = t:Find("Button"):GetComponent(Button)
    self.buttonImage = t:Find("Button"):GetComponent(Image)
    self.clockObj = t:Find("Clock").gameObject
    self.timeText = t:Find("Time"):GetComponent(Text)

    self.scoreText.gameObject:SetActive(false)

    -- if IS_DEBUG then
    --     self.delta = 2
    -- else
        self.delta = 20
    -- end

    self.max_time = 10

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function GuildDragonSlayer:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.classExt ~= nil then
        self.classExt:DeleteMe()
        self.classExt = nil
    end
    if self.rankImage ~= nil then
        self.rankImage.sprite = nil
    end
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    self.assetWrapper = nil
    self.gameObject = nil
    self.model = nil
end

function GuildDragonSlayer:update_my_self(data, index)
    self.data = data
    self.index = index

    if data.rank_index > 3 then
        self.rankText.text = data.rank_index
        self.rankImage.gameObject:SetActive(false)
    else
        self.rankText.text = ""
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_" .. data.rank_index)
    end
    self.headSlot:SetAll(data)
    -- self.scoreText.text = string.format(TI18N("积分: <color='#fff000'>%s</color>"), data.point)
    -- self.classExt.text = string.format(TI18N("职业: %s"), KvData.classes_name[data.classes])

    self.classExt:SetData(string.format(TI18N("掠夺成功可获得<color='#ffff00'>%s</color>{assets_2,90054}"), math.ceil(data.point / 10)))

    local doCountdown = data.looted_time ~= 0 and data.looted_time > BaseUtils.BASE_TIME
    local colorStr = nil
    local guildData = GuildManager.Instance.model.my_guild_data
    local roleData = RoleManager.Instance.RoleData

    if (data.g_id ~= 0 and data.g_id == guildData.GuildId and data.g_platform == guildData.PlatForm and data.g_zone_id == guildData.ZoneId)
        or data.id == roleData.id and data.platform == roleData.platform and data.zone_id == roleData.zone_id
        then
        doCountdown = false
        colorStr = ColorHelper.color[1]
        self.buttonImage.color = Color(0.5, 0.5, 0.5)
    else
        colorStr = ColorHelper.color[6]
        self.buttonImage.color = Color(1, 1, 1)
    end

    if data.g_id == 0 then
        self.nameText.text = BaseUtils.string_cut_utf8(string.format("<color='%s'>【%s】</color>%s", colorStr, TI18N("暂无公会"), data.role_name), 14, 12)
    else
        self.nameText.text = BaseUtils.string_cut_utf8(string.format("<color='%s'>【%s】</color>%s", colorStr, data.guild_name, data.role_name), 14, 12)
        if data.g_id == guildData.GuildId and data.g_platform == guildData.PlatForm and data.g_zone_id == guildData.ZoneId then
        else
            self.buttonImage.color = Color(1, 1, 1)
        end
    end

    local rankIndex = (GuildDragonManager.Instance:GetMyRank() or {}).rank_index or 1
    if data.rank_index > rankIndex + self.delta or data.rank_index < rankIndex - self.delta or data.looted_num >= self.max_time then
        self.buttonImage.color = Color(0.5, 0.5, 0.5)
    end

    self.levText.text = data.lev

    if doCountdown then
        self.clockObj.gameObject:SetActive(true)
        self.timeText.gameObject:SetActive(true)
        self.button.gameObject:SetActive(false)
        self:BeginCount(data.looted_time)
    else
        self.clockObj.gameObject:SetActive(false)
        self.timeText.gameObject:SetActive(false)
        self.button.gameObject:SetActive(true)
        self:BeginCount(0)
    end
end

function GuildDragonSlayer:SetData(data, index)
    self:update_my_self(data, index)
end

function GuildDragonSlayer:BeginCount(stemp)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    local m = nil
    local s = nil
    if stemp > 0 then
        self.timerId = LuaTimer.Add(0, 50, function()
            local dis = stemp - BaseUtils.BASE_TIME
            if dis > 0 then
                m,s = math.floor(dis / 60), dis % 60
                if s > 9 then
                    self.timeText.text = string.format("%s:%s", m, s)
                else
                    self.timeText.text = string.format("%s:0%s", m, s)
                end
            else
                self:update_my_self(self.data, self.index)
            end
        end)
    end
end

function GuildDragonSlayer:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function GuildDragonSlayer:OnClick()
    local roleData = RoleManager.Instance.RoleData
    if roleData.id == self.data.id and roleData.platform == self.data.platform and roleData.zone_id == self.data.zone_id then
        NoticeManager.Instance:FloatTipsByString(TI18N("干嘛打自己那么想不开？"))
    else
        local guildData = GuildManager.Instance.model.my_guild_data
        if self.data.g_id ~= 0 and self.data.g_id == guildData.GuildId and self.data.g_platform == guildData.PlatForm and self.data.g_zone_id == guildData.ZoneId then
            NoticeManager.Instance:FloatTipsByString(TI18N("TA是自己人，放过TA吧"))
        else
            local rankIndex = (GuildDragonManager.Instance:GetMyRank() or {}).rank_index or #(self.model.loot_list or {})
            if self.data.rank_index > rankIndex + self.delta or self.data.rank_index < rankIndex - self.delta then
                NoticeManager.Instance:FloatTipsByString(TI18N("TA与您实力相差太大了，放过TA吧！"))
            elseif self.data.looted_num >= self.max_time then
                NoticeManager.Instance:FloatTipsByString(TI18N("TA已经被挑战10次了，放过TA吧！"))
            else
                WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddragon_rod, false)
                GuildDragonManager.Instance:send20507(self.data.id, self.data.platform, self.data.zone_id)
            end
        end
    end
end


