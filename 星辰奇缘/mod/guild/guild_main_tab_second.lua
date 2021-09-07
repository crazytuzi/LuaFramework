GuildMainTabSecond = GuildMainTabSecond or BaseClass(BasePanel)

function GuildMainTabSecond:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.guild_main_tab2, type = AssetType.Main}
        ,{file = AssetConfig.guild_welfare_bg, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        , {file = AssetConfig.guild_second_bg, type = AssetType.Main}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.welfare_type = {
        store = 1,
        pay = 4,
        npc = 6,
        redbag = 7,
        box = 8,
        mizang = 9,
        skill = 10,
        pray = 11,
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.guildboxcountchange = function ()
        self:UpdateGuildBoxCount()
    end

    EventMgr.Instance:AddListener(event_name.guild_box_count_change, self.guildboxcountchange)
    self.sceneListener = function() self:OnMapLoaded() end
    self.sceneListener1 = function() self:UnitListUpdate() end

    self.imgLoader = nil
    return self
end

function GuildMainTabSecond:UnitListUpdate()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
    self:GoToSpecial()
end

function GuildMainTabSecond:OnMapLoaded()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    self:GoToSpecial()
end


function GuildMainTabSecond:OnShow()
    self:init_left_view()
end

function GuildMainTabSecond:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    self.has_init = false

    self.itemPay = nil
    self.itemStore = nil
    self.itemNpc = nil
    self.itemRedbag = nil
    self.itemBox = nil
    self.itemMizang = nil
    self.itemSkill = nil

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.mem_item_list = nil
    self:AssetClearAll()
    EventMgr.Instance:RemoveListener(event_name.guild_box_count_change, self.guildboxcountchange)
end


function GuildMainTabSecond:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_main_tab2))
    self.gameObject.name = "GuildMainTabSecond"
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)

    self.transform = self.gameObject.transform
    self.welfare_ImgTopBg = self.transform:FindChild("ImgTopBg")
    local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_welfare_bg))
    UIUtils.AddBigbg(self.welfare_ImgTopBg:FindChild("ImgWord"), obj)
    obj.transform:SetAsFirstSibling()

    self.welfare_ImgGuildName = self.welfare_ImgTopBg:FindChild("ImgGuildName").gameObject
    self.welfare_TxtName = self.welfare_ImgGuildName.transform:FindChild("TxtName"):GetComponent(Text)

    self.welfare_ImgGuildGx = self.welfare_ImgTopBg:FindChild("ImgGuildGx").gameObject
    self.welfare_TxtGx = self.welfare_ImgGuildGx.transform:FindChild("TxtName"):GetComponent(Text)
    self.welfare_ImgGuildGx.gameObject:SetActive(true)

    local go = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_second_bg))
    UIUtils.AddBigbg(self.transform:FindChild("ImgTopBg"):FindChild("Con"), go)
    go.transform.localScale = Vector3(1.38, 1.38, 1)

    self.welfare_scroll_rect = self.transform:FindChild("MaskLayer"):FindChild("ScrollLayer").gameObject
    self.scrollRect = self.welfare_scroll_rect.transform:GetComponent(ScrollRect)
    self.welfare_layout_con = self.welfare_scroll_rect.transform:FindChild("LayoutLayer").gameObject
    self.originWfItem = self.welfare_layout_con.transform:FindChild("Item").gameObject
    self.originWfItem.gameObject:SetActive(false)
    self.itemPay = self:create_guild_welfare_item(self.originWfItem, self.welfare_type.pay)

    self.itemStore = self:create_guild_welfare_item(self.originWfItem, self.welfare_type.store)
    self.itemNpc = self:create_guild_welfare_item(self.originWfItem, self.welfare_type.npc)
    self.itemRedBag = self:create_guild_welfare_item(self.originWfItem, self.welfare_type.redbag)
    self.itemBox = self:create_guild_welfare_item(self.originWfItem, self.welfare_type.box)

    if self.imgLoader == nil then
        self.imgLoader = SingleIconLoader.New(self.itemBox.ImgGongxun.gameObject)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 22504)

    self.itemSkill = self:create_guild_welfare_item(self.originWfItem, self.welfare_type.skill)
    self.itemMizang = self:create_guild_welfare_item(self.originWfItem, self.welfare_type.mizang)
    self.itemPray = self:create_guild_welfare_item(self.originWfItem, self.welfare_type.pray)
    self.itemPay.transform:GetComponent(RectTransform).sizeDelta = Vector2(732, 110)
    self.itemPay.transform:GetComponent(RectTransform).anchoredPosition = Vector2(4, 0)
    self.itemNpc.transform:GetComponent(RectTransform).anchoredPosition = Vector2(4, -110)
    self.itemStore.transform:GetComponent(RectTransform).anchoredPosition = Vector2(4, -200)
    self.itemPray.transform:GetComponent(RectTransform).anchoredPosition = Vector2(4, -290)
    self.itemRedBag.transform:GetComponent(RectTransform).anchoredPosition = Vector2(4, -380)
    self.itemBox.transform:GetComponent(RectTransform).anchoredPosition = Vector2(4, -470)
    self.itemSkill.transform:GetComponent(RectTransform).anchoredPosition = Vector2(4, -560)
    self.itemMizang.transform:GetComponent(RectTransform).sizeDelta = Vector2(732, 110)
    self.itemMizang.transform:GetComponent(RectTransform).anchoredPosition = Vector2(4, -650)
    self.itemMizang.TxtDesc.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(380, 60)
    self.itemMizang.TxtDescCon:GetComponent(LayoutElement).preferredHeight = 60
    self.welfare_layout_con.transform:GetComponent(RectTransform).sizeDelta = Vector2(736, 786)

    self.itemPay.TxtPos.text = string.format(TI18N("职位:%s"), GuildManager.Instance.model.member_position_names[GuildManager.Instance.model:get_my_guild_post()])
    self.itemPay.BtnWeek.gameObject:SetActive(true)
    self:SetItemPivot(self.itemPay)
    self:SetItemPivot(self.itemSkill)
    self:SetItemPivot(self.itemBox)
    self:SetItemPivot(self.itemStore)
    self:SetItemPivot(self.itemNpc)
    self:SetItemPivot(self.itemRedBag)
    self:SetItemPivot(self.itemMizang)
    self:SetItemPivot(self.itemPray)
    self:SetSpecielItem(self.itemPay)
    self.has_init = true

    self:init_left_view()


    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end

--设置item的锚点
function GuildMainTabSecond:SetItemPivot(item)
    item.transform.anchorMax = Vector2(0, 1)
    item.transform.anchorMin = Vector2(0, 1)
    item.transform.pivot = Vector2(0, 1)
end

--设置公会分红特殊处理
function GuildMainTabSecond:SetSpecielItem(item)
    item.imgCon:GetComponent(RectTransform).anchoredPosition = Vector2(-317.4, 12)
end

--更新剩余兑换次数
function GuildMainTabSecond:update_left_num()
    if self.has_init then
        self:update_welfare_item(self.itemNpc)
    end
end

function GuildMainTabSecond:init_left_view()
    GuildManager.Instance:request11120()
    GuildManager.Instance:request11115()

    self:update_welfare_item(self.itemStore)
    self:update_welfare_item(self.itemNpc)
    self:update_welfare_item(self.itemRedBag)
    self:update_welfare_item(self.itemBox)
    self:update_welfare_item(self.itemMizang)
    self:update_welfare_item(self.itemSkill)
    self:update_welfare_item(self.itemPray)
    local mySelf = self.parent.model:get_mine_member_data()
    if mySelf == nil then
        self.welfare_TxtName.text = string.format(TI18N("<color='#7eb9f7'>公会名称:</color><color='#ffff00'>%s</color>"), self.parent.model.my_guild_data.Name)
    else
        self.welfare_TxtName.text = string.format(TI18N("<color='#7eb9f7'>公会名称:</color><color='#ffff00'>%s</color>"), self.parent.model.my_guild_data.Name)
        self.welfare_TxtGx.text = string.format(TI18N("<color='#7eb9f7'>我的贡献</color><color='#ffff00'>%s/%s</color>"), mySelf.TotalGx, mySelf.GongXian)
    end
    self.welfare_TxtName.transform:GetComponent(RectTransform).sizeDelta = Vector2(self.welfare_TxtName.preferredWidth+14, 24)
    self.welfare_ImgGuildName.transform:GetComponent(RectTransform).sizeDelta = Vector2(self.welfare_TxtName.preferredWidth+24, 24)

    self.welfare_TxtGx.transform:GetComponent(RectTransform).sizeDelta = Vector2(self.welfare_TxtGx.preferredWidth, 24)
    self.welfare_ImgGuildGx.transform:GetComponent(RectTransform).sizeDelta = Vector2(self.welfare_TxtGx.preferredWidth+14, 24)

    -- self.welfare_TxtGx.text =
end

--------更新逻辑
function GuildMainTabSecond:update_welfare_pay_item()
    if self.has_init == false then
        return
    end
    if self.itemPay ~= nil then
        self:update_welfare_item(self.itemPay)
        self.itemPay.ClockCon.gameObject:SetActive(true)
    end
end

----------item逻辑
--公会福利item
function GuildMainTabSecond:create_guild_welfare_item(_origin_item, _type)
    local item = {}

    item.go = GameObject.Instantiate(_origin_item)
    item.transform = item.go.transform
    item.go:SetActive(true)

    item.transform:SetParent(_origin_item.transform.parent)
    item.transform.localPosition = Vector3(0, 0, 0)
    item.transform.localScale = Vector3(1, 1, 1)

    item.imgCon = item.transform:FindChild("ImgCon")

    item.ImgGongZiBuild = item.imgCon:FindChild("ImgGongZiBuild"):GetComponent(Image)
    item.ImgStoreBuild = item.imgCon:FindChild("ImgStoreBuild"):GetComponent(Image)
    item.ImgExchangeBuild = item.imgCon:FindChild("ImgExchangeBuild"):GetComponent(Image)
    item.ImgRedBag = item.imgCon:FindChild("ImgRedBag"):GetComponent(Image)
    item.ImgGongxun = item.imgCon:FindChild("ImgGongxun"):GetComponent(Image)
    item.ImgMizang = item.imgCon:FindChild("ImgMizang"):GetComponent(Image)
    item.ImgSkill = item.imgCon:FindChild("ImgSkill"):GetComponent(Image)
    item.ImgPray = item.imgCon:FindChild("ImgPray"):GetComponent(Image)

    item.ImgGongZiBuild.gameObject:SetActive(false)
    item.ImgSkill.gameObject:SetActive(false)
    item.ImgStoreBuild.gameObject:SetActive(false)
    item.ImgExchangeBuild.gameObject:SetActive(false)
    item.ImgRedBag.gameObject:SetActive(false)
    item.ImgGongxun.gameObject:SetActive(false)
    item.ImgMizang.gameObject:SetActive(false)
    item.ImgPray.gameObject:SetActive(false)

    item.TxtName=item.transform:FindChild("TxtName"):GetComponent(Text)
    item.TxtPos = item.transform:FindChild("TxtPos"):GetComponent(Text)
    item.BtnWeek = item.transform:FindChild("BtnWeek"):GetComponent(Button)
    item.TxtDescCon = item.transform:FindChild("LayoutCon"):FindChild("TxtDescCon")
    item.TxtDesc=item.TxtDescCon:FindChild("TxtDesc"):GetComponent(Text)
    item.TxtDesc_icon = item.TxtDescCon.transform:FindChild("ImgIcon").gameObject
    item.TxtDesc_icon:SetActive(false)

    item.ClockCon = item.transform:FindChild("LayoutCon"):FindChild("ClockCon")
    item.SkillCon = item.transform:FindChild("LayoutCon"):FindChild("SkillCon")
    item.BtnLifeSkill = item.transform:FindChild("LayoutCon"):FindChild("SkillCon"):FindChild("BtnLifeSkill"):GetComponent(Button)
    item.BtnStrongerSkill = item.transform:FindChild("LayoutCon"):FindChild("SkillCon"):FindChild("BtnStrongerSkill"):GetComponent(Button)
    item.TxtStrongerLev = item.transform:FindChild("LayoutCon"):FindChild("SkillCon"):FindChild("TxtStrongerLev"):GetComponent(Text)
    item.TxtClockDesc = item.ClockCon:FindChild("TxtDesc"):GetComponent(Text)
    item.ClockCon2 = item.ClockCon:FindChild("ClockCon")
    item.ImgClockIcon = item.ClockCon2:FindChild("ImgClock"):GetComponent(Image)
    item.TxtClock = item.ClockCon2:FindChild("TxtClock"):GetComponent(Text)
    item.ImgClockIcon1 = item.ClockCon2:FindChild("ImgClock1"):GetComponent(Image)
    item.TxtClock1 = item.ClockCon2:FindChild("TxtClock1"):GetComponent(Text)
    item.ImgTanHao = item.transform:FindChild("ImgTanHao"):GetComponent(Button)
    item.ImgTanHao.gameObject:SetActive(false)
    item.BtnWeek.gameObject:SetActive(false)


    item.ImgTanHao.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("以下职位在领取分红时\n将获得额外加成："))
        table.insert(tips, TI18N("会长   <color='#ffa500'>+80%</color>"))
        table.insert(tips, TI18N("副会长  <color='#ffa500'>+30%</color>"))
        table.insert(tips, TI18N("长老   <color='#ffa500'>+20%</color>"))
        table.insert(tips, TI18N("兵长   <color='#ffa500'>+15%</color>"))
        table.insert(tips, TI18N("宝贝   <color='#ffa500'>+15%</color>"))
        table.insert(tips, TI18N("精英   <color='#ffa500'>+5%</color>"))

        TipsManager.Instance:ShowText({gameObject = item.ImgTanHao.gameObject, itemData = tips})
    end)

    item.BtnLook = item.transform:FindChild("BtnLook"):GetComponent(Button)
    item.BtnLook_grey = item.BtnLook.transform:FindChild("ImgGrey"):GetComponent(Image).sprite
    item.BtnLook_blue = item.BtnLook.image.sprite
    item.TxtFinish = item.transform:FindChild("TxtFinish"):GetComponent(Text)
    item.ImgWeekDesc = item.transform:FindChild("ImgWeekDesc")
    item.ImgWeekDescTxt = item.transform:FindChild("ImgWeekDesc"):FindChild("TxtFinish"):GetComponent(Text)
    item.TxtBtn = item.BtnLook.transform:FindChild("Text"):GetComponent(Text)
    item.ImgPoint = item.transform:FindChild("ImgPoint").gameObject
    item.ImgPoint:SetActive(false)

    local on_click_btn = function()
        self:on_click_btn(item)
    end

    item.BtnLook.onClick:AddListener(on_click_btn)

    if _type == self.welfare_type.pay then
        local on_click_week_btn = function()
            self:on_click_week_btn(item)
        end
        item.BtnWeek.onClick:AddListener(on_click_week_btn)
    end

    if _type == self.welfare_type.skill then
        local on_life_btn = function()
            self:on_life_btn(item)
        end
        local on_stronger_btn = function()
            self:on_stronger_btn(item)
        end
        item.BtnLifeSkill.onClick:AddListener(on_life_btn)
        item.BtnStrongerSkill.onClick:AddListener(on_stronger_btn)
    end


    item.researchData = nil
    item.storeData = nil
    item.forgeData = nil
    item.hotelData = nil
    item.type = 0
    item.type = _type

    return item
end

function GuildMainTabSecond:update_welfare_item(item)
    if self.has_init == false then
        return
    end

    if item == nil then
        return
    end

    if  item.type ==  self.welfare_type.store then
        item.TxtName.text = TI18N("商店")
        item.TxtBtn.text = self.parent.model.guild_lang.GUILD_FORGE_BTN_STR
        self:set_icon_guild_welfare(item, item.ImgStoreBuild)

        item.TxtDesc.text = TI18N("消耗<color='#c3692c'>公会贡献</color>、<color='#c3692c'>兄弟币</color>可在商店中兑换<color='#248813'>物品</color>")
        item.ImgPoint:SetActive(false)

        if self.parent.model.my_guild_data.store_lev < 1 then
            item.BtnLook.image.sprite = item.BtnLook_grey
            item.transform:FindChild("BtnLook"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
        else
            item.BtnLook.image.sprite = item.BtnLook_blue
            item.ImgPoint:SetActive(self.parent.model.guild_store_has_refresh)
            item.transform:FindChild("BtnLook"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
        end
        item.BtnLook.gameObject:SetActive(true)
    elseif  item.type ==  self.welfare_type.pay then
        item.TxtName.text = TI18N("公会分红")

        item.ImgTanHao.gameObject:SetActive(true)

        if self.parent.model.pay_data.daily == 1 then
            item.TxtBtn.text = self.parent.model.guild_lang.GUILD_HOTEL_BTN_STR
            item.TxtFinish.gameObject:SetActive(false)
            item.BtnLook.gameObject:SetActive(true)

            local time_gap = BaseUtils.BASE_TIME - self.parent.model:get_my_join_guild_time()
            if time_gap >= 172800 then
                item.ImgPoint:SetActive(true)
            else
                item.ImgPoint:SetActive(false)
            end
        else
            item.TxtFinish.gameObject:SetActive(true)
            item.BtnLook.gameObject:SetActive(false)
            item.ImgPoint:SetActive(false)
            -- item.TxtBtn.text = TI18N("已领取")
        end
        self:set_icon_guild_welfare(item, item.ImgGongZiBuild)

        local str =string.format("%s<color='#c3692c'>%s%s</color>", TI18N("当前研究院："), self.parent.model.my_guild_data.academy_lev, TI18N("级"))
        item.TxtDesc.text = string.format("%s%s", str, TI18N("(升级研究院可提高分红)"))

        local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
        if currentWeek == 0 then
            currentWeek = 7
        end
        local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
        local currentMin = tonumber(os.date("%M", BaseUtils.BASE_TIME))
        if currentWeek == 7 then
            --星期天
            item.ClockCon2.gameObject:SetActive(false)
            item.BtnLook.gameObject:SetActive(false)
            item.ImgPoint:SetActive(false)
            item.ImgWeekDesc.gameObject:SetActive(true)
            item.TxtClockDesc.text = TI18N("<color='#c3692c'>今日<color='#00ff00'>11：50</color>将通过邮件发放本周工资</color>")
            local tempStr = ""
            if currentHour > 11 then
                tempStr = TI18N("已发放")
            else
                if currentHour == 11 and currentMin >= 50 then
                    tempStr = TI18N("已发放")
                else
                    tempStr = TI18N("11:50发放")
                end
            end
            item.ImgWeekDescTxt.text = tempStr
        else
            item.ImgWeekDesc.gameObject:SetActive(false)
            item.TxtFinish.text = TI18N("已领取")
            item.TxtClockDesc.text = TI18N("今日分红")
            local cfg_data = DataGuild.data_get_research_up_data[self.parent.model.my_guild_data.academy_lev]
            local my_post = self.parent.model:get_my_guild_post()
            local reward = 70000
            local daily_exp = 66
            if cfg_data ~= nil then
                daily_exp = cfg_data.daily_exp
                reward = cfg_data.daily_coin
            end

            local radio = 1
            if my_post == self.parent.model.member_positions.stduy then
                radio = 1
            elseif my_post == self.parent.model.member_positions.mem then
                radio = 1
            elseif my_post == self.parent.model.member_positions.elite then
                radio = 1.05
            elseif my_post == self.parent.model.member_positions.sergeant then
                radio = 1.15
            elseif my_post == self.parent.model.member_positions.elder then
                radio = 1.2
            elseif my_post == self.parent.model.member_positions.baby then
                radio = 1.2
            elseif my_post == self.parent.model.member_positions.vice_leader then
                radio = 1.3
            elseif my_post == self.parent.model.member_positions.leader then
                radio = 1.8
            end
            reward = math.floor(reward*radio)
            daily_exp = math.floor(daily_exp*radio)


            item.ImgClockIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,"Assets90000")
            item.TxtClock.text = tostring(reward)

            item.ImgClockIcon1.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,"Assets90013")
            item.TxtClock1.text = tostring(daily_exp)
            item.ClockCon2.gameObject:SetActive(true)
        end

        item.ClockCon.gameObject:SetActive(true)
    elseif item.type == self.welfare_type.npc then
        self:set_icon_guild_welfare(item, item.ImgExchangeBuild)
        item.TxtName.text = TI18N("兑换贡献")
        item.TxtDesc.text = string.format("%s<color='#248813'>%s</color>", TI18N("消耗银币可兑换公会贡献,本周还可兑换"), self.parent.model.npc_exchange_left_num, TI18N("次"))
        item.TxtBtn.text = TI18N("兑换")
        item.TxtDesc_icon:SetActive(true)
        item.TxtDesc_icon.transform:GetComponent(RectTransform).anchoredPosition = Vector2( item.TxtDesc.preferredWidth, -5)
        item.BtnLook.gameObject:SetActive(true)
        -- local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
        -- if currentWeek == 0 then
        --     currentWeek = 7
        -- end

        -- if currentWeek == 1 then
        --     --周一
        --     local GuildConvert = PlayerPrefs.GetInt("GuildConvert")
        --     if GuildConvert == nil then
        --         item.ImgPoint:SetActive(true)
        --         PlayerPrefs.SetInt("GuildConvert", 0)
        --     end
        -- end

    elseif item.type == self.welfare_type.redbag then
        self:set_icon_guild_welfare(item, item.ImgRedBag)
        item.TxtName.text = TI18N("公会红包")
        item.TxtDesc.text = TI18N("每天可发出红包或者获取其他成员的红包")
        item.TxtBtn.text = TI18N("发红包")
        item.BtnLook.gameObject:SetActive(true)
    elseif item.type == self.welfare_type.box then
        self:set_icon_guild_welfare(item, item.ImgGongxun)
        item.TxtName.text = TI18N("功勋宝箱")
        item.TxtDesc.text = TI18N("会长分配，奖励为公会做出卓越贡献的成员")
        item.TxtBtn.text = TI18N("分配")
        item.TxtClockDesc.text = string.format("%s:<color='#248813'>%s/%s</color>", TI18N("库存"), self:CalNum(), 100)
        item.ClockCon.gameObject:SetActive(false)
        item.BtnLook.gameObject:SetActive(true)
    elseif item.type == self.welfare_type.mizang then
        -- print("-----------------------------更新密藏")
        -- self.model.guildTreasure   item.TxtClockDesc.text
        self:set_icon_guild_welfare(item, item.ImgMizang)
        item.TxtName.text = TI18N("公会秘藏")
        item.TxtDesc.text = TI18N("公会战胜利方可开启公会秘藏，公会战失败方如果参与达到一定人数，可开启激励宝藏")
        item.TxtBtn.text = TI18N("预约")
        item.TxtClockDesc.text = ""
        item.ClockCon.gameObject:SetActive(false)
        item.ClockCon2.gameObject:SetActive(false)
        item.TxtFinish.gameObject:SetActive(false)
        item.BtnLook.gameObject:SetActive(true)

        if GuildManager.Instance.model.guildTreasure ~= nil then
            -- bugly #29777756 hosr 20160722
            if GuildManager.Instance.model.guildTreasure.setting_chance ==0 and GuildManager.Instance.model.guildTreasure.setting_time > 0 then
                local dayTemp = tostring(os.date("%d", BaseUtils.BASE_TIME))
                local dayTempSet = tostring(os.date("%d", GuildManager.Instance.model.guildTreasure.setting_time))
                if dayTemp < dayTempSet then
                    item.TxtClockDesc.text = TI18N(string.format("开启时间：明天 (<color='#248813'>%s:%s</color>)"
                        ,tostring(os.date("%H", GuildManager.Instance.model.guildTreasure.setting_time))
                        ,tostring(os.date("%M", GuildManager.Instance.model.guildTreasure.setting_time))
                        )
                    )
                    -- item.ClockCon.gameObject:SetActive(true)
                elseif GuildManager.Instance.model.guildTreasure.setting_time + 1200 < BaseUtils.BASE_TIME then
                    -- Log.Error("---------------------------------")
                    -- print(BaseUtils.BASE_TIME - GuildManager.Instance.model.guildTreasure.setting_time)
                    item.TxtClockDesc.text = ""
                    item.TxtFinish.gameObject:SetActive(true)
                    item.BtnLook.gameObject:SetActive(false)
                    item.TxtFinish.supportRichText = true
                    item.TxtFinish.text = TI18N("未获得")
                else
                    item.TxtClockDesc.text = string.format(TI18N("开启时间：今天 (<color='#248813'>%s:%s</color>)")
                        ,tostring(os.date("%H", GuildManager.Instance.model.guildTreasure.setting_time))
                        ,tostring(os.date("%M", GuildManager.Instance.model.guildTreasure.setting_time))
                        )
                    -- item.ClockCon.gameObject:SetActive(true)
                end
            elseif GuildManager.Instance.model.guildTreasure.setting_chance > 0 and GuildManager.Instance.model.guildTreasure.setting_time > 0 then
                item.TxtClockDesc.text = TI18N("开启时间未预约 (默认<color='#248813'>13:00</color>)")
                -- item.ClockCon.gameObject:SetActive(true)
            elseif GuildManager.Instance.model.guildTreasure.setting_chance == 0
                and GuildManager.Instance.model.guildTreasure.setting_time == 0
                and GuildManager.Instance.model.guildTreasure.can_open == 0 then
                item.TxtClockDesc.text = ""
                item.TxtFinish.gameObject:SetActive(true)
                item.BtnLook.gameObject:SetActive(false)
                item.TxtFinish.supportRichText = true
                item.TxtFinish.text = TI18N("未获得")
            end
        end
    elseif item.type == self.welfare_type.skill then
        item.TxtName.text = TI18N("公会技能")
        item.TxtDesc.text = TI18N("公会贡献可用于提升<color='#c3692c'>生活技能</color>与<color='#c3692c'>强壮精通</color>")
        item.ClockCon.gameObject:SetActive(false)
        item.BtnLook.gameObject:SetActive(false)
        item.SkillCon.gameObject:SetActive(true)
        self:set_icon_guild_welfare(item, item.ImgSkill)

        local curLev = 0
        local maxLev = 0
        for k, v in pairs(DataSkillLife.data_data) do
            if v.id == 10008 and v.lev > maxLev and v.open_lev <= RoleManager.Instance.RoleData.lev then
                maxLev = v.lev
            end
        end
        local life_skills = SkillManager.Instance.model.life_skills
        for k, v in pairs(life_skills) do
            if v.id == 10008 then
                curLev = v.lev
                break
            end
        end
        item.TxtStrongerLev.text = string.format(TI18N("（等级:<color='%s'>%s</color>/%s）"), ColorHelper.color[1], curLev, maxLev)
    elseif item.type == self.welfare_type.pray then
        self:set_icon_guild_welfare(item, item.ImgPray)
        item.TxtName.text = TI18N("公会祈福")
        item.TxtBtn.text = TI18N("祈福")
        item.ClockCon.gameObject:SetActive(false)
        item.BtnLook.gameObject:SetActive(true)
        local str = ""
        if RoleManager.Instance.world_lev < 70 then
            str = TI18N("消耗{assets_2, 90011}、{assets_2, 90000}等获得元素祝福，提升能力，世界等级达到<color='#0000ff'>70</color>时可开启")
        else
            if #self.parent.model.my_guild_data.element_info <= 0 then
                str = TI18N("消耗{assets_2, 90011}、{assets_2, 90000}等获得元素祝福，提升能力，世界等级达到<color='#0000ff'>70</color>时可开启")
            else
                str = TI18N("消耗{assets_2, 90011}、{assets_2, 90000}等获得元素祝福，提升能力")
            end
        end
        if item.TxtDescMsg == nil then
            item.TxtDescMsg = MsgItemExt.New(item.TxtDesc, 380, 17, 23)
        end
        item.TxtDescMsg:SetData(QuestEumn.FilterContent(str))
    end
end
--更新库存
function GuildMainTabSecond:UpdateGuildBoxCount()
    -- body
    if self.itemBox ~= nil then
        self:update_welfare_item(self.itemBox)
    end
end

function GuildMainTabSecond:CalNum()
    local count = 0
    -- for i,v in ipairs(self.model.guildLoot.items) do
    --     count = count + v.num
    -- end
    if GuildManager.Instance.model.guildLoot ~= nil and GuildManager.Instance.model.guildLoot.items[1] ~= nil then
        count = GuildManager.Instance.model.guildLoot.items[1].num
    end
    if GuildManager.Instance.model.guildLeagueLoot ~= nil and GuildManager.Instance.model.guildLeagueLoot.items[1] ~= nil then
        count = count + GuildManager.Instance.model.guildLeagueLoot.items[1].num
    end
    return count
end

function GuildMainTabSecond:drag_welfare_item_begin(data)
    self.scrollRect:OnInitializePotentialDrag(data)
    self.scrollRect:OnBeginDrag(data)
end

--公会成员条目拖动
function GuildMainTabSecond:drag_welfare_item(data)
    self.scrollRect:OnDrag(data)
end

function GuildMainTabSecond:drag_welfare_item_end(data)
    self.scrollRect:OnEndDrag(data)
end


function GuildMainTabSecond:set_icon_guild_welfare(item, img)
    item.ImgGongZiBuild.gameObject:SetActive(false)
    item.ImgSkill.gameObject:SetActive(false)
    item.ImgStoreBuild.gameObject:SetActive(false)
    item.ImgExchangeBuild.gameObject:SetActive(false)
    item.ImgRedBag.gameObject:SetActive(false)
    item.ImgGongxun.gameObject:SetActive(false)
    item.ImgPray.gameObject:SetActive(false)
    item.ImgMizang.gameObject:SetActive(false)
    img.gameObject:SetActive(true)
end

function GuildMainTabSecond:set_store_data(item,data)
    item.type = 1
    item.storeData = data
    item.TxtName.text = self.parent.model.guild_lang.GUILD_BUILD_NAME_4
    item.TxtBtn.text = self.parent.model.guild_lang.GUILD_STORE_BTN_STR
    self:set_icon_guild_welfare(item, item.ImgStoreBuild)
    if storeData ~= nil then --0级的时候就~取出nil
        self:ClockInit()
        item.TxtDesc.text = self.parent.model.guild_lang.GUILD_STORE_EFFECT_STR
        item.TxtClock.text = ""
        selectTime = mod_guild.store_flesh_time
        if selectTime == 0 then
            item.TxtClock.text = "--:--:--"
        else --加入计时器
            TxtClock = item.TxtClock
            -- welfare_timer_event = ctx.TimerManager:GetIntervalTimeEvent(1,"self:welfare_tick_callback")
            -- welfare_timer_event:AddListener(self:welfare_tick_callback)
        end

    else
        item.TxtDesc.text = self.parent.model.guild_lang.GUILD_STORE_EFFECT_STR_0
        item.ClockCon.gameObject:SetActive(false)
    end
end

function GuildMainTabSecond:welfare_tick_callback()
    local tim = TimerManager.BASE_TIME
    if selectTime < tim then
        TxtClock.text = "--:--:--"
        -- welfare_timer_stop()
        return
    end
    local leftTime = selectTime - tim
    if leftTime > 0 then
        TxtClock.text = TimerManager.FormateTimeGap(leftTime,  ':',  0, TimerManager.TIME_FORMATE.HOUR)
    else
        TxtClock.text = "--:--:--"
        -- welfare_timer_stop()
    end
end

local clockHasInit = false
function GuildMainTabSecond:ClockInit()
    if clockHasInit == false then
        clockHasInit = true
        ClockCon.gameObject:SetActive(true)
        ImgTanHao.gameObject:SetActive(true)

        -- utils.add_down_up_scale(ImgTanHao.gameObject,  "self:on_click_tanhao_tips")
    end
end

function GuildMainTabSecond:on_click_tanhao_tips(g)
    local temp = {}
    local tipsStr = self.parent.model.guild_lang.GUILD_WELFARE_TIME_PREFIX --.Replace("{0end",  hourstr..":" + minStr..":" + secStr)
    table.insert(temp,  tipsStr)
    local t = {trans=g.transform,content=temp}
    -- mod_tips.general_tips(t)
end

function GuildMainTabSecond:on_click_btn(item)
    if item.type==self.welfare_type.store then --货栈
        if self.parent.model.my_guild_data.store_lev < 1 then
            local tips = {}
            table.insert(tips, TI18N("商店建筑1级可开启"))
            TipsManager.Instance:ShowText({gameObject = item.BtnLook.gameObject, itemData = tips})
            return
        end

        self.parent.model:InitStoreUI()
    elseif item.type == self.welfare_type.pay then --公会分红
        GuildManager.Instance:request11116(1)
    elseif item.type == self.welfare_type.npc then
        -- item.ImgPoint:SetActive(false)
        -- local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
        -- if currentWeek == 0 then
        --     currentWeek = 7
        -- end
        -- if currentWeek ~= 1 then
        --     local str = PlayerPrefs.GetString("GuildConvert")
        --     if str ~= nil then
        --         PlayerPrefs.DeleteKey("GuildConvert")
        --     end
        -- end
        self.parent.model:InitGuildNpcExchangeUI()
    elseif item.type == self.welfare_type.redbag then
        --打开发红包界面
        GuildManager.Instance.model:InitRedBagSetUI()
    elseif item.type == self.welfare_type.box then
        --公会功勋宝箱
        GuildManager.Instance.model:InitGiveGuildFightBoxUI()
    elseif item.type == self.welfare_type.mizang then
        --公会秘藏
        GuildfightManager.Instance.model:GoToGuildArea()
    elseif item.type == self.welfare_type.pray  then
        --公会祈祷
        if RoleManager.Instance.world_lev < 70 then
            NoticeManager.Instance:FloatTipsByString(TI18N("世界等级达到<color='#ff000'>70</color>后可由<color='#23F0F7'>会长/副会长</color>开启"))
            return
        else
            if #GuildManager.Instance.model.my_guild_data.element_info <= 0 or GuildManager.Instance.model.my_guild_data.upgrade_element_time > 0 then
                --点击寻路到公会领地，点击祭坛。
                self:FindSpecialUnit()
            else
                GuildManager.Instance.model:InitPrayUI()
            end
        end
    end
end


function GuildMainTabSecond:FindSpecialUnit()
    if SceneManager.Instance:CurrentMapId() == 30001 then
        self:GoToSpecial()
    else
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
        QuestManager.Instance:Send(11128, {})
    end
end

function GuildMainTabSecond:GoToSpecial()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)

    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, tostring(20101)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end
    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, tostring(20101)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end

    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, tostring(20102)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end
    for uniqueid,_ in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, tostring(20102)) ~= nil then
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_AutoPath(30001, uniqueid)
            return
        end
    end
end



--周工资
function GuildMainTabSecond:on_click_week_btn(item)

    if GuildManager.Instance.model:get_my_guild_post() == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#00ff00'>新秀</color>无法领取本周工资"))
        return
    end
    GuildManager.Instance.model:InitWeekRewardUI()
end

function GuildMainTabSecond:on_life_btn(item)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill, {3})
end

function GuildMainTabSecond:on_stronger_btn(item)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill, {4})
end
