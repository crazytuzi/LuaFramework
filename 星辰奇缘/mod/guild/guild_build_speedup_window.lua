GuildBuildSpeedupWindow  =  GuildBuildSpeedupWindow or BaseClass(BasePanel)

function GuildBuildSpeedupWindow:__init(model)
    self.name  =  "GuildBuildSpeedupWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_speedup_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_build_icon, type = AssetType.Dep}
    }

    self.item_ids = {
        Guild = 1001,
        Research = 1004,
        Vault = 1003,
        Store = 1002,
        Pray= 1005,
    }

    self.item_data_list = {
        {self.item_ids.Guild , DataGuild.data_get_guild_up_data} --公会
        ,{self.item_ids.Vault , DataGuild.data_get_vault_up_data} --厢房
        ,{self.item_ids.Research , DataGuild.data_get_research_up_data} --研究院
        ,{self.item_ids.Store , DataGuild.data_get_store_up_data} --货栈
        ,{self.item_ids.Pray , DataGuild.data_get_store_up_data} --祈福
    }

    self.updateInfoListener = function()
        self:update_info()
    end
    self.restoreFrozen_btn1 = nil
    self.restoreFrozen_btn2 = nil
    self.restoreFrozen_btn3 = nil


    self.tick_time = 0
    self.timer_id = 0
    self.is_open = false
    return self
end


function GuildBuildSpeedupWindow:__delete()
    GuildManager.Instance.OnUpdateSpeedUpWin:RemoveListener(self.updateInfoListener)
    self.ImgIcon.sprite = nil
    if self.restoreFrozen_btn1 ~= nil then
        self.restoreFrozen_btn1:DeleteMe()
    end
    if self.restoreFrozen_btn2 ~= nil then
        self.restoreFrozen_btn2:DeleteMe()
    end
    if self.restoreFrozen_btn3 ~= nil then
        self.restoreFrozen_btn3:DeleteMe()
    end

    self.is_open = false
    self:stop_timer()
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildBuildSpeedupWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_speedup_win))
    self.gameObject.name  =  "GuildBuildSpeedupWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseBuildSpeedupUI() end)


    self.MainCon = self.transform:FindChild("MainCon")
    self.TopCon = self.MainCon:FindChild("TopCon")
    self.GrowupProgCon = self.TopCon:FindChild("GrowupProgCon")
    self.ImgProg = self.GrowupProgCon:FindChild("ImgProg")
    self.ImgProgBar_rect = self.ImgProg:FindChild("ImgProgBar"):GetComponent(RectTransform)
    self.TxtProg = self.ImgProg:FindChild("TxtProg"):GetComponent(Text)

    self.ImgTanhao = self.TopCon:FindChild("ImgTanhao"):GetComponent(Button)

    self.MidCon = self.MainCon:FindChild("MidCon")
    self.ImgIcon = self.MidCon:FindChild("ImgIcon"):GetComponent(Image)
    self.TxtName = self.MidCon:FindChild("TxtName"):GetComponent(Text)
    self.TxtDesc = self.MidCon:FindChild("TxtDesc"):GetComponent(Text)

    self.TxtDesc.transform:GetComponent(RectTransform).pivot = Vector2(0, 1)
    self.TxtDesc.transform:GetComponent(RectTransform).anchorMax = Vector2(0, 1)
    self.TxtDesc.transform:GetComponent(RectTransform).anchorMin = Vector2(0, 1)
    self.TxtDesc.transform:GetComponent(RectTransform).anchoredPosition = Vector2(100, -30)

    self.TxtDesc_msg = MsgItemExt.New(self.TxtDesc, 180, 16, 23)

    self.BottomCon = self.MainCon:FindChild("BottomCon")
    self.BtnSpeedup1 = self.BottomCon:FindChild("BtnSpeedup1"):GetComponent(Button)
    self.TxtVal_1 = self.BtnSpeedup1.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_1 = self.BtnSpeedup1.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.BtnSpeedup1Img = self.BtnSpeedup1:GetComponent(Image)

    self.BtnSpeedup2 = self.BottomCon:FindChild("BtnSpeedup2"):GetComponent(Button)
    self.TxtVal_2 = self.BtnSpeedup2.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_2 = self.BtnSpeedup2.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.BtnSpeedup2Img = self.BtnSpeedup2:GetComponent(Image)

    self.BtnSpeedup3 = self.BottomCon:FindChild("BtnSpeedup3"):GetComponent(Button)
    self.TxtVal_3 = self.BtnSpeedup3.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_3 = self.BtnSpeedup3.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.BtnSpeedup3Img = self.BtnSpeedup3:GetComponent(Image)

    self.GrayButtonSprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"DefaultButton4")
    self.BlueButtonSprite = self.BtnSpeedup1Img.sprite

    self.restoreFrozen_btn1 = GuildSpeedFrozenButton.New(self.BtnSpeedup1)
    self.restoreFrozen_btn2 = GuildSpeedFrozenButton.New(self.BtnSpeedup2)
    self.restoreFrozen_btn3 = GuildSpeedFrozenButton.New(self.BtnSpeedup3)

    GuildManager.Instance.OnUpdateSpeedUpWin:AddListener(self.updateInfoListener)


    self.ImgTanhao.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("1.倒计时结束建筑将自动升级"))
        table.insert(tips, TI18N("2.公会成员可消耗银币加速进度"))
        TipsManager.Instance:ShowText({gameObject = self.ImgTanhao.gameObject, itemData = tips})
    end)
    self.BtnSpeedup1.onClick:AddListener(function()
        GuildManager.Instance:request11112 (self.cur_type, self.model.speedup_type.type1)
    end)
    self.BtnSpeedup2.onClick:AddListener(function()
        GuildManager.Instance:request11112 (self.cur_type, self.model.speedup_type.type2)
    end)
    self.BtnSpeedup3.onClick:AddListener(function()
        GuildManager.Instance:request11112 (self.cur_type, self.model.speedup_type.type3)
    end)

    self.is_open = true
    self:update_info()
end

--更新信息
function GuildBuildSpeedupWindow:update_info()
    if self.is_open == false then
        return
    end
    local cur_data_table = self.model.speedup_data[2]
    local item_id = self.model.speedup_data[1]

    local cfg_data = nil --cur_data_table[1]
    local cfg_next_data = nil
    local lev = 0
    local name = ""
    local build_left_time = 0
    self.speedup_fenmu = 0

    self.cur_type = 0

    if item_id == self.item_ids.Guild then --公会
        build_left_time = self.model.my_guild_data.lev_time
        self.cur_type = 0
        cur_data_table = DataGuild.data_get_guild_up_data
        cfg_data = cur_data_table[self.model.my_guild_data.Lev]
        cfg_next_data = cur_data_table[self.model.my_guild_data.Lev+1]

        lev = self.model.my_guild_data.Lev

        name = TI18N("公会规模")
    elseif item_id == self.item_ids.Research then --研究院
        build_left_time = self.model.my_guild_data.academy_time
        self.cur_type = 1
        cfg_data = cur_data_table[self.model.my_guild_data.academy_lev]
        cfg_next_data = cur_data_table[self.model.my_guild_data.academy_lev+1]

        lev = self.model.my_guild_data.academy_lev

        name = TI18N("研究院")
    elseif item_id == self.item_ids.Vault then --厢房
        build_left_time = self.model.my_guild_data.exchequer_time
        self.cur_type = 2
        -- local lev = self.model.my_guild_data.exchequer_lev
        -- lev = lev == 0 and 1 or lev
        cfg_data = cur_data_table[self.model.my_guild_data.exchequer_lev]
        cfg_next_data = cur_data_table[self.model.my_guild_data.exchequer_lev + 1]

        lev = self.model.my_guild_data.exchequer_lev

        name = TI18N("厢房")
    elseif item_id == self.item_ids.Store then --货栈
        build_left_time = self.model.my_guild_data.store_time
        self.cur_type = 3
        cfg_data = cur_data_table[self.model.my_guild_data.store_lev]
        cfg_next_data = cur_data_table[self.model.my_guild_data.store_lev+1]
        lev = self.model.my_guild_data.store_lev
        name = TI18N("商店")
    elseif item_id == self.item_ids.Pray then --货栈
        build_left_time = self.model.my_guild_data.upgrade_element_time
        self.cur_type = 11
        cfg_data = cur_data_table[self.model.my_guild_data.store_lev]
        cfg_next_data = nil
        lev = -1
        name = TI18N("祈福")

        self.TxtDesc_msg:SetData("对祭坛建设进行加速")
        for k, v in pairs(DataGuild.data_guild_element) do
            if v.lev == 1 then
                self.speedup_fenmu = v.need_time*6
                break
            end
        end
    end

    self.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_build_icon , tostring(item_id))
    if lev ~= -1 then
        self.TxtName.text = string.format("%sLv.%s", name, lev)
    else
        self.TxtName.text = string.format("%s", name)
    end

    if cfg_next_data ~= nil then
        self.TxtDesc_msg:SetData(QuestEumn.FilterContent(cfg_next_data.desc))
        self.speedup_fenmu = cfg_next_data.need_time
    end

    local btn_data_1 = DataGuild.data_get_speedup[1]
    local btn_data_2 = DataGuild.data_get_speedup[2]
    local btn_data_3 = DataGuild.data_get_speedup[3]

    self.TxtVal_1.text = tostring(btn_data_1.cost_coin)
    self.TxtVal_2.text = tostring(btn_data_2.cost_coin)
    self.TxtVal_3.text = tostring(btn_data_3.cost_coin)

    local hour1 = btn_data_1.reduce_time/3600
    local hour2 = btn_data_2.reduce_time/3600
    local hour3 = btn_data_3.reduce_time/3600

    self.TxtDesc_1.text = string.format("%s%s%s<color='#FFFF9A'>%s</color>", TI18N("加速"), hour1, TI18N("小时，获得"), btn_data_1.gain_donation)
    self.TxtDesc_2.text = string.format("%s%s%s<color='#FFFF9A'>%s</color>", TI18N("加速"), hour2, TI18N("小时，获得"), btn_data_2.gain_donation)
    self.TxtDesc_3.text = string.format("%s%s%s<color='#FFFF9A'>%s</color>", TI18N("加速"), hour3, TI18N("小时，获得"), btn_data_3.gain_donation)


    build_left_time = build_left_time - BaseUtils.BASE_TIME

    if build_left_time <= 0 then
        GuildManager.Instance:request11100()
        self.model:CloseBuildSpeedupUI()
    else
        --处理进度条
        self.tick_time = build_left_time
        self:start_timer()
    end

    -- 加速按钮变灰检测
    local total_donate = self.model.my_guild_data.total_donate
    local limit_mode = self.model.my_guild_data.limit_mode

    if self.BtnSpeedup1 == nil or total_donate == nil or limit_mode == nil then
        return
    end


    -- 限制额度为100W
    if limit_mode == 3 then

        if total_donate > 750000 then
            self.BtnSpeedup1Img.sprite = self.GrayButtonSprite
        end
        if total_donate > 500000 then
            self.BtnSpeedup2Img.sprite = self.GrayButtonSprite
        end
        if total_donate ~= 0 then
            self.BtnSpeedup3Img.sprite = self.GrayButtonSprite
        end

    -- 限制额度为50W
    elseif limit_mode == 2 then
        if total_donate > 250000 then
            self.BtnSpeedup1Img.sprite = self.GrayButtonSprite
        end
        if total_donate ~= 0 then
            self.BtnSpeedup2Img.sprite = self.GrayButtonSprite
        end
        self.BtnSpeedup3Img.sprite = self.GrayButtonSprite


    -- 限制额度为25W
    elseif limit_mode == 1 then
        if total_donate ~= 0 then
            self.BtnSpeedup1Img.sprite = self.GrayButtonSprite
        end
        self.BtnSpeedup2Img.sprite = self.GrayButtonSprite
        self.BtnSpeedup3Img.sprite = self.GrayButtonSprite

    -- 没有限制额度
    elseif limit_mode == 0 then
        self.BtnSpeedup1Img.sprite = self.BlueButtonSprite
        self.BtnSpeedup2Img.sprite = self.BlueButtonSprite
        self.BtnSpeedup3Img.sprite = self.BlueButtonSprite
    -- 不用对加速按钮进行操作

    end
end



---------------------------计时器逻辑

--计时关掉界面
function GuildBuildSpeedupWindow:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function GuildBuildSpeedupWindow:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function GuildBuildSpeedupWindow:timer_tick()
    self.tick_time = self.tick_time - 1

    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.tick_time)
    my_hour = my_hour >= 10 and tostring(my_hour) or string.format("0%s", my_hour)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)

    self.ImgProgBar_rect.sizeDelta = Vector2(135*self.tick_time/self.speedup_fenmu, self.ImgProgBar_rect.rect.height)
    self.TxtProg.text = string.format("%s:%s:%s", my_hour, my_minute, my_second)
    if self.tick_time <= 0 then
        self:stop_timer()
        self.TxtProg.text = "--:--:--"
    end
end