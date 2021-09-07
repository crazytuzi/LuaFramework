GuildBuildWindow  =  GuildBuildWindow or BaseClass(BaseWindow)

function GuildBuildWindow:__init(model)
    self.name  =  "GuildBuildWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_build_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        , {file = AssetConfig.guild_build_icon, type = AssetType.Dep}
        ,{file = AssetConfig.attr_icon,type = AssetType.Dep}
    }


    self.item_ids = {
        Guild = 1001,
        Research = 1004,
        Vault = 1003,
        Store = 1002,
        Pray= 1005,
    }



    self.timer_id = 0
    self.tick_time = 0

    self.item_list = nil
    self.effect = nil
    return self
end


function GuildBuildWindow:__delete()
    if self.effect ~= nil then
        self.effect:DeleteMe()
    end

    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v.ImgIcon.sprite = nil
        end
    end


    self.is_open  =  false
    self.item_go_list = nil
    self.last_selected_item = nil

    self:stop_timer()

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildBuildWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_build_win))
    self.gameObject.name  =  "GuildBuildWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.MainCon = self.transform:FindChild("MainCon").gameObject
    local CloseBtn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseBuildUI() end)


    self.is_open = true
    self.ImgTitleTxt = self.MainCon.transform:Find("ImgTitle/Text"):GetComponent(Text)
    --根据openArgs设置
    if self.openArgs == 2 then
        self.ImgTitleTxt.text = TI18N("元素祝福")
        self.item_data_list = {
            {self.item_ids.Pray , DataGuild.data_get_store_up_data} --祈福
        }
    else
        self.ImgTitleTxt.text = TI18N("公会管理")
        self.item_data_list = {
            {self.item_ids.Guild , DataGuild.data_get_guild_up_data} --公会
            ,{self.item_ids.Vault , DataGuild.data_get_vault_up_data} --厢房
            ,{self.item_ids.Research , DataGuild.data_get_research_up_data} --研究院
            ,{self.item_ids.Store , DataGuild.data_get_store_up_data} --货栈
        }
    end

    self.ConLev = self.MainCon.transform:FindChild("ConLev").gameObject
    self.maskLayer = self.ConLev.transform:FindChild("MaskLayer").gameObject
    self.scrollLayer = self.maskLayer.transform:FindChild("ScrollLayer").gameObject
    self.layoutLayer = self.scrollLayer.transform:FindChild("LayoutLayer").gameObject
    self.TopItem1 = self.layoutLayer.transform:FindChild("TopItem1").gameObject
    self.TopItem2 = self.layoutLayer.transform:FindChild("TopItem2").gameObject
    self.TopItem3 = self.layoutLayer.transform:FindChild("TopItem3").gameObject
    self.TopItem4 = self.layoutLayer.transform:FindChild("TopItem4").gameObject
    self.TopItem5 = self.layoutLayer.transform:FindChild("TopItem5").gameObject
    self.TopItem1:SetActive(false)
    self.TopItem2:SetActive(false)
    self.TopItem3:SetActive(false)
    self.TopItem4:SetActive(false)
    self.TopItem5:SetActive(false)

    self.item_go_list = {}
    table.insert(self.item_go_list, self.TopItem1)
    table.insert(self.item_go_list, self.TopItem2)
    table.insert(self.item_go_list, self.TopItem3)
    table.insert(self.item_go_list, self.TopItem4)
    table.insert(self.item_go_list, self.TopItem5)

    self.ConUnOpen = self.ConLev.transform:FindChild("ConUnOpen").gameObject
    self.TxtDesc1 = self.ConUnOpen.transform:FindChild("TxtDesc1"):GetComponent(Text)
    self.TxtDesc2 = self.ConUnOpen.transform:FindChild("TxtDesc2"):GetComponent(Text)


    self.ConOpen = self.ConLev.transform:FindChild("ConOpen").gameObject
    self.ConMid = self.ConOpen.transform:FindChild("ConMid").gameObject
    self.title_desc = self.ConMid.transform:FindChild("ImgBg"):FindChild("TxtDesc"):GetComponent(Text)


    self.mid_LayoutCon = self.ConMid.transform:FindChild("LayoutCon").gameObject
    self.desc1_txt = self.mid_LayoutCon.transform:FindChild("TxtDesc1"):GetComponent(Text)
    self.desc2_txt = self.mid_LayoutCon.transform:FindChild("TxtDesc2"):GetComponent(Text)
    self.desc3_txt = self.mid_LayoutCon.transform:FindChild("TxtDesc3"):GetComponent(Text)
    self.desc1 = MsgItemExt.New(self.desc1_txt, 350, 16, 23)
    self.desc2 = MsgItemExt.New(self.desc2_txt, 350, 16, 23)
    self.desc3 = MsgItemExt.New(self.desc3_txt, 350, 16, 23)

    self.ConBottom = self.ConOpen.transform:FindChild("ConBottom").gameObject
    self.ConCost = self.ConBottom.transform:FindChild("ConCost").gameObject
    self.ImgTxtBg = self.ConCost.transform:FindChild("ImgTxtBg").gameObject
    self.TxtNum1 = self.ImgTxtBg.transform:FindChild("TxtNum1"):GetComponent(Text)

    self.ConNeed = self.ConBottom.transform:FindChild("ConNeed").gameObject
    self.ImgTxtBg_need = self.ConNeed.transform:FindChild("ImgTxtBg").gameObject
    self.TxtNum1_need = self.ImgTxtBg_need.transform:FindChild("TxtNum1"):GetComponent(Text)

    self.ConHas = self.ConBottom.transform:FindChild("ConHas").gameObject
    self.ImgTxtBg_has = self.ConHas.transform:FindChild("ImgTxtBg").gameObject
    self.TxtNum1_has = self.ImgTxtBg_has.transform:FindChild("TxtNum1"):GetComponent(Text)

    self.BtnCon = self.ConBottom.transform:FindChild("BtnCon")
    self.btn_up = self.BtnCon:FindChild("BtnUp"):GetComponent(Button)
    self.btn_img_green = self.btn_up.image.sprite
    self.btn_img_grey = self.btn_up.transform:FindChild("ImgGrey"):GetComponent(Image).sprite
    self.btn_break = self.BtnCon:FindChild("BtnBreak"):GetComponent(Button)

    self.ProgCon = self.ConBottom.transform:FindChild("ProgCon")
    self.ImgProg = self.ProgCon.transform:FindChild("GrowupProgCon"):FindChild("ImgProg")
    self.ImgProgBar_rect = self.ImgProg.transform:FindChild("ImgProgBar"):GetComponent(RectTransform)
    self.TxtProg = self.ImgProg.transform:FindChild("TxtProg"):GetComponent(Text)
    self.BtnSpeedup = self.ProgCon.transform:FindChild("BtnSpeedup"):GetComponent(Button)
    self.LockBtn = self.ProgCon.transform:FindChild("LockBtn"):GetComponent(Button)

    -- utils.add_down_up_scale(self.ConLost, "GuildBuildWindow:on_click_lost_tips")
    self.btn_up.onClick:AddListener(function() self:on_click_up_btn(1) end)
    self.btn_break.onClick:AddListener(function() self:on_click_up_btn(2) end)
    self.BtnSpeedup.onClick:AddListener(function()
        self.model.speedup_data = self.curSelectItem.data
        -- GuildManager.Instance.request11100()
        self.model:InitBuildSpeedupUI()
    end)
    self.LockBtn.onClick:AddListener(function() self:on_lock_btn() end)

    --GuildManager.Instance.OnUpdateRightInfo:AddListener(function()
        --self:updateLockBtn()
    --end)

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    self:init_view()
end

-- 锁按钮点击
function GuildBuildWindow:on_lock_btn()
        -- 副会长、会长以下成员点击锁按钮会有tips提示
    if self.model:get_my_guild_post() <self.model.member_positions.vice_leader then
        NoticeManager.Instance:FloatTipsByString(TI18N("会长设置了贡献额度，请不要多点哟"))
        return
    else
        -- 副会长、会长点击锁按钮会有弹窗，弹窗可支持解锁功能。
        local data = NoticeConfirmData.New()
        local select_item_data = self.curSelectItem.data -- 所选中的公会建筑的数据集
        local item_id = select_item_data[1]
        local select_item_name = ""
        local select_item_level = nil
        local current_restriction = "" -- 当前升级额度

        if (item_id == self.item_ids.Guild) then
            select_item_name = TI18N("公会")
            select_item_level = self.model.my_guild_data.Lev
        elseif (item_id == self.item_ids.Research) then
            select_item_name = TI18N("研究院")
            select_item_level = self.model.my_guild_data.academy_lev
        elseif (item_id == self.item_ids.Vault) then
            select_item_name = TI18N("厢房")
            select_item_level = self.model.my_guild_data.exchequer_lev
        elseif (item_id == self.item_ids.Store) then
            select_item_name = TI18N("商店")
            select_item_level = self.model.my_guild_data.store_lev
        end

        if (self.model.my_guild_data.limit_mode == 1) then
            current_restriction = "25W"
        elseif (self.model.my_guild_data.limit_mode == 2) then
            current_restriction = "50W"
        elseif (self.model.my_guild_data.limit_mode == 3) then
            current_restriction = "100W"
        end


        data.type = ConfirmData.Style.Normal
        data.content = string.format("%s%s%s%s%s%s%s",TI18N("当前升级"),select_item_level,TI18N("级"),select_item_name,TI18N("，贡献额度"),current_restriction,TI18N("银币，是否取消限制"))
        data.sureLabel = TI18N("取消限制")
        data.cancelLabel = TI18N("我再想想")
        data.sureCallback = function()
            GuildManager.Instance:request11197()
        end
        NoticeManager.Instance:ConfirmTips(data)
    end

end

--升级按钮点击
function GuildBuildWindow:on_click_up_btn(_type)
    if _type == 1 then
        local data = self.curSelectItem.data
        local item_id = data[1]
        local index = 0
        if item_id == self.item_ids.Guild then --公会
            index = 0
        elseif item_id == self.item_ids.Research then --研究院
            index = 1
        elseif item_id == self.item_ids.Vault then --厢房
            index = 2
        elseif item_id == self.item_ids.Store then --商店
            index = 3
        elseif item_id == self.item_ids.Pray then -- 祈福
            index = 4
        end
        if index == 4 then
            --祈福解锁
            -- self:PlayBuildEffect()
            GuildManager.Instance:request11189()
        else
            print("aaaaaaaaaaaaaaaa")
            if self.model:get_my_guild_post() < self.model.member_positions.elder then
                NoticeManager.Instance:FloatTipsByString(TI18N("长老以上才可以升级公会建筑"))
                return
            end
            --设置升级按钮状态
            if self.model:check_has_build_lev_up() then
                NoticeManager.Instance:FloatTipsByString(TI18N("当前有其他建筑正在升级"))
                return
            end
            -- GuildManager.Instance:request11111(index)
            self.model:InitBuildRestrictionSelectUI(index,self.curSelectItem)
        end
    elseif _type == 2 then
        if self.model:get_my_guild_post() < self.model.member_positions.vice_leader then
            NoticeManager.Instance:FloatTipsByString(TI18N("副会长以上才可以拆除公会建筑"))
            return
        end

        local data = self.curSelectItem.data
        local item_id = data[1]
        local build_name = ""
        if item_id == self.item_ids.Guild then --公会
            build_name = TI18N("公会")
        elseif item_id == self.item_ids.Research then --研究院
            build_name = TI18N("研究院")
        elseif item_id == self.item_ids.Vault then --厢房
            build_name = TI18N("厢房")
        elseif item_id == self.item_ids.Store then --厢房
            build_name = TI18N("商店")
        elseif item_id == self.item_ids.Pray then --祈福
            build_name = TI18N("祈福")
        end

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format("%s%s%s", TI18N("是否要降低"), build_name, TI18N("等级"))
        data.sureLabel = TI18N("拆除")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            local data = self.curSelectItem.data
            local item_id = data[1]
            local index = 0
            local lev = self.model.my_guild_data.Lev
            if item_id == self.item_ids.Guild then --公会
                index = 0
                lev = self.model.my_guild_data.Lev
            elseif item_id == self.item_ids.Research then --研究院
                index = 1
                lev = self.model.my_guild_data.academy_lev
            elseif item_id == self.item_ids.Vault then --厢房
                index = 2
                lev = self.model.my_guild_data.exchequer_lev
            elseif item_id == self.item_ids.Store then --货栈
                index = 3
                lev = self.model.my_guild_data.store_lev
            elseif item_id == self.item_ids.Pray then --祈福
                index = 4
                lev = 0
            end
            if lev == 0 then
                NoticeManager.Instance:FloatTipsByString(TI18N("<color='#4dd52b'>0级建筑</color>不能再拆啦"))
                return
            end
            GuildManager.Instance:request11117(index)
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end


--初始化
function GuildBuildWindow:init_view()
    self.item_list = {}

    local selected_item = nil
    for i=1, #self.item_data_list do
        local data = self.item_data_list[i]
        local item = self.item_list[i]
        if item == nil then
            item = self:create_top_item(self.item_go_list[i])
        end
        self:set_item_data(item, data)
        table.insert(self.item_list, item)
        if item.building then
            selected_item = item
        end
    end

    --默认选中第一条
    if selected_item == nil then
        selected_item = self.item_list[1]
    end
    self:on_select_item(selected_item)
end

--协议更新调用,-------------------------------------------------------------------
function GuildBuildWindow:update_view()
    if self.curSelectItem ~= nil then
        self:set_item_data(self.curSelectItem, self.curSelectItem.data)
        self:set_selected_item(self.curSelectItem)
    end
end


---创建item
function GuildBuildWindow:create_top_item(originItem)

    local item = {}
    item.go = originItem
    item.go:SetActive(true)

    item.ImgIcon = item.go.transform:FindChild("ImgIcon"):GetComponent(Image)
    item.TxtName = item.go.transform:FindChild("TxtName"):GetComponent(Text)
    item.TxtLev = item.go.transform:FindChild("TxtLev"):GetComponent(Text)

    item.ImgSelectedArrow = item.go.transform:FindChild("ImgSelectedArrow").gameObject
    item.ImgUnSelectedArrow = item.go.transform:FindChild("ImgUnSelectedArrow").gameObject
    item.TxtBuildIng = item.go.transform:FindChild("TxtBuildIng").gameObject
    item.selBg = item.go.transform:FindChild("ImgSelectedBg").gameObject
    item.selBg:SetActive(false)
    item.TxtBuildIng:SetActive(false)
    item.ImgSelectedArrow:SetActive(false)
    item.ImgUnSelectedArrow:SetActive(true)

    item.go:GetComponent(Button).onClick:AddListener(function() self:on_select_item(item) end)

    return item
end

function GuildBuildWindow:set_item_data(item, data)
    item.data = data
    local item_id = data[1]
    local name_str = ""
    local lev_str = ""
    local left_time = 0
    item.building = false
    if item_id == self.item_ids.Guild then --公会
        left_time = self.model.my_guild_data.lev_time
        name_str =TI18N("公会规模")
        lev_str = string.format("Lv.%s", self.model.my_guild_data.Lev)
    elseif item_id == self.item_ids.Research then --研究院
        left_time = self.model.my_guild_data.academy_time
        name_str = TI18N("研究院")
        lev_str = string.format("Lv.%s", self.model.my_guild_data.academy_lev)
    elseif item_id == self.item_ids.Vault then --厢房
        left_time = self.model.my_guild_data.exchequer_time
        name_str = TI18N("厢房")
        lev_str = string.format("Lv.%s", self.model.my_guild_data.exchequer_lev)
    elseif item_id == self.item_ids.Store then --货栈
        left_time = self.model.my_guild_data.store_time
        name_str = TI18N("商店")
        lev_str = string.format("Lv.%s", self.model.my_guild_data.store_lev)
    elseif item_id == self.item_ids.Pray then --祈福
        left_time = self.model.my_guild_data.store_time
        name_str = TI18N("祭坛")
        local img = item.go.transform:FindChild("bg"):GetComponent(Image)
        local lock = item.go.transform:FindChild("ImgLock").gameObject
        if RoleManager.Instance.world_lev < 70 then
            BaseUtils.SetGrey(img, true)
            lock:SetActive(true)
            lev_str = TI18N("世界等级70级开启")
        else
            BaseUtils.SetGrey(img, false)
            lock:SetActive(false)
            if #self.model.my_guild_data.element_info > 0 then
                local tempLev = 0
                for k, v in pairs(self.model.my_guild_data.element_info) do
                    tempLev = tempLev + v.lev
                end
                lev_str = string.format("Lv.%s", tempLev)
            else
                lev_str = TI18N("未建造")
            end
        end
    end

    if left_time > 0 then
        item.building = true
        item.TxtBuildIng:SetActive(true)
    else
        item.TxtBuildIng:SetActive(false)
    end

    item.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_build_icon , tostring(data[1]))
    item.TxtName.text = name_str
    item.TxtLev.text = lev_str
end

function GuildBuildWindow:on_select_item(item)
    if item.data[1] == self.item_ids.Pray then --祈福
        if RoleManager.Instance.world_lev < 70 then
            return
        else
            local leftTime = self.model.my_guild_data.upgrade_element_time - BaseUtils.BASE_TIME
            if #self.model.my_guild_data.element_info > 0 and leftTime  <= 0 then
                --已经为解锁
                self.model:InitPrayUI()
                return
            end
        end
    end
    if self.last_selected_item ~= nil then
        self.last_selected_item.selBg:SetActive(false)
        self.last_selected_item.ImgUnSelectedArrow:SetActive(true)
        self.last_selected_item.ImgSelectedArrow:SetActive(false)
    end

    self:set_selected_item(item)
    self.last_selected_item = item
end

function GuildBuildWindow:set_selected_item(item)
    self.curSelectItem = item
    self.curSelectItem.selBg:SetActive(true)
    self.curSelectItem.ImgUnSelectedArrow:SetActive(false)
    self.curSelectItem.ImgSelectedArrow:SetActive(true)
    self:update_right_info()
end


---右边面板内容更新 ----------------------------------------------------
function GuildBuildWindow:update_right_info()
    local data = self.curSelectItem.data
    local cur_data_table = data[2]
    local item_id = data[1]
    local cfg_data = nil --cur_data_table[1]
    local cfg_next_data = nil

    local title_desc_str = ""

    local desc_str_1 = ""
    local desc_str_2 = ""
    local desc_str_3 = ""
    local need_num_1 = 0
    local need_num_2 = 0

    local build_left_time = 0

    if self.model.my_guild_data.limit_mode == 0 then
        self.speedup_fenmu = 0
        self.btn_up.gameObject:SetActive(false)
        self.btn_break.gameObject:SetActive(false)
    end


    if item_id == self.item_ids.Guild then --公会
        build_left_time = self.model.my_guild_data.lev_time

        cur_data_table = DataGuild.data_get_guild_up_data
        cfg_data = cur_data_table[self.model.my_guild_data.Lev]
        cfg_next_data = cur_data_table[self.model.my_guild_data.Lev+1]

        title_desc_str = string.format("%s%s%s", TI18N("公会等级："), self.model.my_guild_data.Lev, TI18N("级"))
        self.btn_up.gameObject:SetActive(true)
        self.btn_break.gameObject:SetActive(true)
        self.btn_up.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(90, 0)
        self.btn_break.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-90, 0)

        if cfg_next_data ~= nil then
            need_num_1 = cfg_next_data.cost
            need_num_2 = cfg_next_data.need
            self.speedup_fenmu = cfg_next_data.need_time
            desc_str_1 = string.format("%s%s", TI18N("下级效果："), cfg_data.desc)
            desc_str_2 = string.format("%s%s%s%s", TI18N("升级："), TI18N("每级提升"), cfg_next_data.upkeep, TI18N("维护费/小时"))
            desc_str_3 = string.format("%s%s", TI18N("条件："), cfg_next_data.up_desc)
        else
            desc_str_2 = TI18N("已达到最高等级")
        end
    elseif item_id == self.item_ids.Research then --研究院
        build_left_time = self.model.my_guild_data.academy_time

        cfg_data = cur_data_table[self.model.my_guild_data.academy_lev]
        title_desc_str = string.format("%s%s%s", TI18N("研究院等级："), self.model.my_guild_data.academy_lev, TI18N("级"))

        self.btn_up.gameObject:SetActive(true)
        self.btn_break.gameObject:SetActive(true)
        self.btn_up.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(90, 0)
        self.btn_break.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-90, 0)

        -- if cfg_data ==nil or self.model.my_guild_data.Lev < cfg_data.need_lev then --未开启
        --     self:set_unopen_desc(self.item_ids.Research)
        --     return
        -- end

        cfg_next_data = cur_data_table[self.model.my_guild_data.academy_lev+1]
       if cfg_next_data ~= nil then
            self.speedup_fenmu = cfg_next_data.need_time
            need_num_1 = cfg_next_data.cost
            need_num_2 = cfg_next_data.need
            desc_str_1 = string.format("%s%s", TI18N("效果："), cfg_next_data.desc)
            desc_str_2 = string.format("%s%s%s%s", TI18N("升级："), TI18N("每级提升"), cfg_next_data.upkeep, TI18N("维护费/小时"))

            if self.model.my_guild_data.academy_lev == 0 then
                desc_str_3 = TI18N("当前建筑可升级")
            else
                desc_str_3 = string.format("%s%s", TI18N("条件："), cfg_next_data.up_desc)
            end
        else
            desc_str_2 = TI18N("已达到最高等级")
        end

    elseif item_id == self.item_ids.Vault then --厢房
        build_left_time = self.model.my_guild_data.exchequer_time
        local lev = self.model.my_guild_data.exchequer_lev
        lev = lev == 0 and 1 or lev
        cfg_data = cur_data_table[lev]
        cfg_next_data = cur_data_table[lev+1]

        title_desc_str = string.format("%s%s%s", TI18N("厢房等级："), lev, TI18N("级"))

        self.btn_up.gameObject:SetActive(true)
        self.btn_break.gameObject:SetActive(true)
        self.btn_up.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(90, 0)
        self.btn_break.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-90, 0)

       if cfg_next_data ~= nil then
            self.speedup_fenmu = cfg_next_data.need_time
            need_num_1 = cfg_next_data.cost
            need_num_2 = cfg_next_data.need
            desc_str_1 = string.format("%s%s", TI18N("效果："), cfg_next_data.desc)
            desc_str_2 = string.format("%s%s%s%s", TI18N("升级："), TI18N("每级提升"), cfg_next_data.upkeep, TI18N("维护费/小时"))

            if self.model.my_guild_data.exchequer_lev == 0 then
                desc_str_3 = TI18N("当前建筑可升级")
            else
                desc_str_3 = string.format("%s%s", TI18N("条件："), cfg_next_data.up_desc)
            end
        else
            desc_str_2 = TI18N("已达到最高等级")
        end
    elseif item_id == self.item_ids.Store then --货栈
        build_left_time = self.model.my_guild_data.store_time
        cfg_data = cur_data_table[self.model.my_guild_data.store_lev]
        title_desc_str = string.format("%s%s%s", TI18N("商店等级："), self.model.my_guild_data.store_lev, TI18N("级"))

        self.btn_up.gameObject:SetActive(true)
        self.btn_break.gameObject:SetActive(true)
        self.btn_up.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(90, 0)
        self.btn_break.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-90, 0)

        cfg_next_data = cur_data_table[self.model.my_guild_data.store_lev+1]
        if cfg_next_data ~= nil then
            self.speedup_fenmu = cfg_next_data.need_time
            need_num_1 = cfg_next_data.cost
            need_num_2 = cfg_next_data.need
            desc_str_1 = string.format("%s%s", TI18N("效果："), cfg_next_data.desc)
            desc_str_2 = string.format("%s%s%s%s", TI18N("升级："), TI18N("每级提升"), cfg_next_data.upkeep, TI18N("维护费/小时"))

            if self.model.my_guild_data.store_lev == 0 then
                desc_str_3 = TI18N("当前建筑可升级")
            else
                desc_str_3 = string.format("%s%s", TI18N("条件："), cfg_next_data.up_desc)
            end
        else
            desc_str_2 = TI18N("已达到最高等级")
        end
    elseif item_id == self.item_ids.Pray then --祈福
        title_desc_str = TI18N("祭坛")
        desc_str_1 =  TI18N("效果：元素祭坛开启后，公会成员可在祭坛中获得<color='#ffff00'>能力祝福</color>，一段时间内大幅<color='#ffff00'>提升各项属性</color>")
        desc_str_2 =  TI18N("升级：建造元素祭坛后，可进行<color='#ffff00'>公会祈福</color>")
        for k, v in pairs(DataGuild.data_guild_element) do
            if v.lev == 1 then
                need_num_1 = need_num_1 + v.cost
                need_num_2 = need_num_2 + v.need
            end
        end
        self.btn_up.gameObject:SetActive(true)
        self.btn_break.gameObject:SetActive(false)
        self.btn_up.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
        build_left_time = self.model.my_guild_data.upgrade_element_time

        for k, v in pairs(DataGuild.data_guild_element) do
            if v.lev == 1 then
                self.speedup_fenmu = v.need_time*6
                break
            end
        end


        print('==================sssssssssssssssssssssss')
        print(build_left_time - BaseUtils.BASE_TIME)
        print(self.speedup_fenmu)
    end

    self.title_desc.text = title_desc_str

    self.desc1:SetData(QuestEumn.FilterContent(desc_str_1))
    self.desc2:SetData(QuestEumn.FilterContent(desc_str_2))
    self.desc3:SetData(QuestEumn.FilterContent(desc_str_3))

    local num_str_1 = need_num_1 > self.model.my_guild_data.Assets and string.format("<color='%s'>%s</color>", "c3692c", need_num_1) or string.format("<color='%s'>%s</color>", "#00ff00", need_num_1)
    local num_str_2 = need_num_2 > self.model.my_guild_data.Assets and string.format("<color='%s'>%s</color>", "c3692c", need_num_2) or string.format("<color='%s'>%s</color>", "#00ff00", need_num_2)
    self.TxtNum1.text = num_str_1
    self.TxtNum1_need.text = num_str_2
    self.TxtNum1_has.text = tostring(self.model.my_guild_data.Assets)

    self.ConOpen:SetActive(true)
    self.ConUnOpen:SetActive(false)

    --设置升级按钮状态
    if self.model:check_has_build_lev_up() then
        self.btn_up.image.sprite = self.btn_img_grey
    else
        self.btn_up.image.sprite = self.btn_img_green
    end

    --处理底部加速升级逻辑
    self.BtnCon.gameObject:SetActive(false)
    self.ProgCon.gameObject:SetActive(false)
    self.LockBtn.gameObject:SetActive(false)
    self.tick_time = build_left_time - BaseUtils.BASE_TIME

    if self.tick_time <= 0 then
        self.BtnCon.gameObject:SetActive(true)
    else
        self.ProgCon.gameObject:SetActive(true)
        --if (self.model.my_guild_data.limit_mode > 0) then
           -- self.LockBtn.gameObject:SetActive(true)
        --end
        if (self.model.my_guild_data.limit_mode > 0) then
            self.LockBtn.gameObject:SetActive(true)
            end
        --处理进度条
        self:start_timer()
    end
end

function GuildBuildWindow:updateLockBtn()
    if self.model.my_guild_data.limit_mode > 0 then
        self.LockBtn.gameObject:SetActive(true)
    else
        self.LockBtn.gameObject:SetActive(false)

    end
end

--设置未开启状态的描述
function GuildBuildWindow:set_unopen_desc(item_id)
    self.ConOpen:SetActive(false)
    self.ConUnOpen:SetActive(true)


    if item_id == self.item_ids.Research then
        local cfg_data = DataGuild.data_get_research_up_data[1]
        self.TxtDesc1.text = string.format("%s%s%s", TI18N("公会达到"), cfg_data.need_lev, TI18N("级自动开启研究院"))
        self.TxtDesc2.text = TI18N("(可获取公会任务加成、强化加成效果)")
    elseif item_id == self.item_ids.Store then

        local  cfg_data = DataGuild.data_get_store_up_data[1]
        self.TxtDesc1.text = string.format("%s%s%s", TI18N("公会达到"), cfg_data.need_lev, TI18N("级自动开启商店"))
        self.TxtDesc2.text = TI18N("(可消耗贡献兑换稀有物品)")
    end
end


---------------------------计时器逻辑

--计时关掉界面
function GuildBuildWindow:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function GuildBuildWindow:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function GuildBuildWindow:timer_tick()
    self.tick_time = self.tick_time - 1

    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.tick_time)
    my_hour = my_hour + my_date*24
    my_hour = my_hour >= 10 and tostring(my_hour) or string.format("0%s", my_hour)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)

    self.ImgProgBar_rect.sizeDelta = Vector2(150*self.tick_time/self.speedup_fenmu, self.ImgProgBar_rect.rect.height)
    self.TxtProg.text = string.format("%s:%s:%s", my_hour, my_minute, my_second)
    if self.tick_time <= 0 then
        self:stop_timer()
        self.TxtProg.text = "--:--:--"
        if self.openArgs == 2 then
            self.model:CloseBuildUI()
            self.model:InitPrayUI()
        end
    end
end

--建造新的建筑
function GuildBuildWindow:PlayBuildEffect()
    if self.effect ~= nil then
        return
    end
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(ctx.CanvasContainer.transform)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, -2000)
        effectObject.transform.localRotation = Quaternion.identity
        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        SoundManager.Instance:Play(240)
    end
    self.effect = BaseEffectView.New({effectId = 20165, time = 2000, callback = fun})

    LuaTimer.Add(2000, function()
        if self.effect ~= nil then
            self.effect:DeleteMe()
        end
        self.effect = nil
        GuildManager.Instance:request11189()
    end)
end