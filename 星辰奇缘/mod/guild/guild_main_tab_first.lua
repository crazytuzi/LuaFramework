GuildMainTabFirst = GuildMainTabFirst or BaseClass(BasePanel)

function GuildMainTabFirst:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.guild_main_tab1, type = AssetType.Main}
        ,{file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.bible_rechargepanel_textures,type = AssetType.Dep}
    }

    self.item_list = nil
    self.single_item_height = 0
    self.scroll_con_height = 0
    self.item_con_height = 0

    self.previewComp1 = nil
    self.has_init = false
    self.list_has_init = false
    self.sortType = 0
    self.day_timer_id = 0
    self.scroll_change_count = 0
    self.init_time = BaseUtils.BASE_TIME
    self.OnOpenEvent:AddListener(function()
        --清除退出公会或者被开除的
        if self.parent.model.has_do_last_delete then
            self.parent.model:filter_deleted_mem()
            self:update_member_list()
        else
            self:update_info_mem_model()
        end
        if self.previewComp1 ~= nil then
            self.previewComp1:Show()
        end
    end)

    self.OnHideEvent:Add(function()
        if self.previewComp1 ~= nil then
            self.previewComp1:Hide()
        end
    end)
    return self
end

function GuildMainTabFirst:__delete()
    self.li_ToTem_icon.sprite = nil
    -- 记得这里销毁
    self.has_init = false
    self.list_has_init = false
    self.item_list = nil
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end

    if self.tabpage ~= nil then
        self.tabpage:DeleteMe()
        self.tabpage = nil
    end

    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local item = self.item_list[i]
            item:Release()
        end
    end

    self:stop_day_timer()

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.last_selected_item = nil
    self:AssetClearAll()
end


function GuildMainTabFirst:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_main_tab1))
    self.gameObject.name = "GuildMainTabFirst"
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)


    self.transform = self.gameObject.transform
    self.BtnQuit = self.transform:FindChild("BtnQuit"):GetComponent(Button)
    self.BtnDelete = self.transform:FindChild("BtnDelete"):GetComponent(Button)
    self.BtnApply = self.transform:FindChild("BtnApply"):GetComponent(Button)
    self.BtnBuild = self.transform:FindChild("BtnBuild"):GetComponent(Button)
    self.BtnBack = self.transform:FindChild("BtnBack"):GetComponent(Button)

    self.ConLeft = self.transform:FindChild("ConLeft")
    self.l_ConTop = self.ConLeft:FindChild("ConTop")
    self.lt_BtnInfo = self.l_ConTop:FindChild("BtnInfo"):GetComponent(Button)
    self.lt_BtnMem = self.l_ConTop:FindChild("BtnMem"):GetComponent(Button)
    self.tab_un_select = self.lt_BtnMem.image.sprite
    self.tab_select = self.lt_BtnInfo.image.sprite
    self.tab_text_color1 = self.lt_BtnInfo.transform:FindChild("Text"):GetComponent(Text).color
    self.tab_text_color2 = self.lt_BtnMem.transform:FindChild("Text"):GetComponent(Text).color

    self.l_ConBottomInfo = self.ConLeft:FindChild("ConBottomInfo").gameObject
    local itemCon = self.l_ConBottomInfo.transform:FindChild("MaskLayer"):FindChild("ScrollLayer"):FindChild("ConItems")
    self.li_Item0 = itemCon:FindChild("Item0")
    self.BtnToTemChange = self.li_Item0:FindChild("ImgChangeIcon"):GetComponent(Button)
    self.BtnToTemChange.gameObject:SetActive(false)
    self.txt_name = self.li_Item0:FindChild("TxtName"):GetComponent(Text)
    self.txt_lev = self.li_Item0:FindChild("TxtLev"):GetComponent(Text)
    self.BtnHealthyTanHao = self.li_Item0:FindChild("BtnTanHao"):GetComponent(Button)
    self.BtnChangeName = self.li_Item0:FindChild("BtnChangeName"):GetComponent(Button)
    local totem_con = self.li_Item0:FindChild("ImgTuTeng")
    self.totem_con_btn = totem_con:GetComponent(Button)
    self.li_ToTem_icon = totem_con:FindChild("ImgIcon"):GetComponent(Image)
    self.li_ToTem_icon.gameObject:SetActive(false)
    self.li_Item3 = itemCon:FindChild("Item3")
    self.li_Item4 = itemCon:FindChild("Item4")
    self.li_Item6 = itemCon:FindChild("Item6")
    self.li_Item7 = itemCon:FindChild("Item7")
    self.BtnTanHao = self.li_Item7:FindChild("BtnTanHao"):GetComponent(Button)

    self.conBtn = self.li_Item4:FindChild("BtnTanHao"):GetComponent(Button)
    self.conBtn.onClick:AddListener(function()
        if self.parent.model.my_guild_data.MaxAssets <= self.parent.model.my_guild_data.Assets then
            NoticeManager.Instance:FloatTipsByString(TI18N("你的公会资金已达上限"))
        else
            local gameObject = self.conBtn.gameObject
            local itemData = ItemData.New()
            itemData:SetBase(DataItem.data_get[90015])
            TipsManager.Instance:ShowItem({gameObject = gameObject, itemData = itemData, extra = {nobutton = false, inbag = false}})
        end
         end)


    --公会宗旨和公会公告
    self.li_ConBottom = itemCon:FindChild("ConBottom")
    self.lic_BtnChange = self.li_ConBottom:FindChild("BtnChange"):GetComponent(Button)
    self.lic_TxtContent = self.li_ConBottom:FindChild("ImgTxtBg"):FindChild("TxtContent"):GetComponent(Text)


    self.Panel1 = itemCon:FindChild("Panel1")
    self.ToggleGroup = itemCon:FindChild("ToggleGroup")
    local panel = self.Panel1:Find("MaskScroll").gameObject
    self.tabpage = TabbedPanel.New(panel, 2, 219)
    self.tabpage.MoveEndEvent:AddListener(
        function(page)
            for i=1,2 do
                self.ToggleGroup:Find(tostring(i)):GetComponent(Toggle).isOn = (i==page)
            end
        end
    )

    self.board_con_1 = self.Panel1:Find("MaskScroll"):FindChild("Container"):FindChild("Page1"):FindChild("ConBottom")
    self.board_con_2 = self.Panel1:Find("MaskScroll"):FindChild("Container"):FindChild("Page2"):FindChild("ConBottom")
    self.lic_BtnChange = self.board_con_1:FindChild("BtnChange"):GetComponent(Button)
    self.lic_BtnReport = self.board_con_1:FindChild("BtnReport"):GetComponent(Button)
    self.lic_BtnReport.gameObject:SetActive(false)   --//暂时屏蔽公会公告举报
    self.lic_TxtContent = self.board_con_1:FindChild("ImgTxtBg"):FindChild("TxtContent"):GetComponent(Text)

    self.lic_BtnChange2 = self.board_con_2:FindChild("BtnChange"):GetComponent(Button)
    self.lic_BtnReport2 = self.board_con_2:FindChild("BtnReport"):GetComponent(Button)
    self.lic_BtnReport2.gameObject:SetActive(false)  --//暂时屏蔽公会宗旨举报
    self.lic_TxtContent2 = self.board_con_2:FindChild("ImgTxtBg"):FindChild("TxtContent"):GetComponent(Text)

    self.l_ConBottomMem = self.ConLeft:FindChild("ConBottomMem").gameObject
    local trs = self.l_ConBottomMem.transform
    self.lm_preview_bg = trs:FindChild("ImgBg"):GetComponent(Image)
    self.lm_Preview = trs:FindChild("Preview").gameObject
    -- self.lmb_BtnFriend = trs:FindChild("BtnFriend"):GetComponent(Button)
    -- self.lmb_BtnFriend.gameObject:SetActive(false)
    self.lm_MidCon = trs:FindChild("MidCon")
    self.lmm_Item1 = self.lm_MidCon:FindChild("Item1")
    self.lmm_Item2 = self.lm_MidCon:FindChild("Item2")
    self.lmm_BtnEdit1 =self.lmm_Item1:FindChild("BtnEdit"):GetComponent(Button)
    self.lmm_BtnRecommend = self.lmm_Item1:FindChild("BtnRecommend"):GetComponent(Button)
    self.lmm_BtnEdit2 =self.lmm_Item2:FindChild("BtnEdit"):GetComponent(Button)
    self.lmm_BtnRecommendAgree = self.lmm_Item2:FindChild("BtnRecommendAgree"):GetComponent(Button)

    self.lmm_BtnRecommend.onClick:AddListener( function() self:on_recommend(1) end)
    self.lmm_BtnRecommendAgree.onClick:AddListener( function() self:on_recommend(2) end)

    self.lm_BottomCon = trs:FindChild("BottomCon")
    self.lmb_BtnChat = self.lm_BottomCon:FindChild("BtnChat"):GetComponent(Button)
    self.lmb_BtnTeam = self.lm_BottomCon:FindChild("BtnTeam"):GetComponent(Button)

    self.lmb_BtnFriend = self.lm_BottomCon:FindChild("BtnFriend"):GetComponent(Button)
    self.lmb_BtnSpace = self.lm_BottomCon:FindChild("BtnSpace"):GetComponent(Button)

    self.lmb_unenable_img = self.lmb_BtnChat.image.sprite
    self.lmb_enable_img = self.lmb_BtnTeam.image.sprite

    self.lm_ConClasses = trs:FindChild("ConClasses")
    self.lmc_TxtClasses = self.lm_ConClasses:FindChild("TxtClasses"):GetComponent(Text)
    self.lm_ImgClasses = self.lm_ConClasses:FindChild("ImgClasses"):GetComponent(Image)

    self.ConRight = self.transform:FindChild("ConRight")
    self.ImgTitle = self.ConRight:FindChild("ImgTitle")
    self.title_lev = self.ImgTitle:FindChild("TxtLev"):GetComponent(Button)
    self.title_gx = self.ImgTitle:FindChild("TxtGx"):GetComponent(Button)
    self.title_tips_gx = self.ImgTitle:FindChild("BtnGx"):GetComponent(Button)
    self.title_tips_huoyue = self.ImgTitle:FindChild("BtnHuoyue"):GetComponent(Button)
    self.title_pos = self.ImgTitle:FindChild("TxtPos"):GetComponent(Button)
    self.title_cup = self.ImgTitle:FindChild("ImgCup"):GetComponent(Button)
    self.title_require = self.ImgTitle:FindChild("TxtNeed"):GetComponent(Button)


    self.ImgTitle:FindChild("TxtLev"):GetComponent(Text).text = TI18N("等级")
    self.ImgTitle:FindChild("TxtGx"):GetComponent(Text).text = TI18N("活跃")
    self.ImgTitle:FindChild("TxtPos"):GetComponent(Text).text = TI18N("职位")
    self.ImgTitle:FindChild("TxtNeed"):GetComponent(Text).text = TI18N("需求")
    self.ImgTitle:FindChild("ImgCup"):GetComponent(Text).text = TI18N("能力")

    self.mem_mask_con = self.ConRight:FindChild("MaskLayer")
    self.scroll_con = self.mem_mask_con:FindChild("ScrollLayer")
    self.item_con = self.scroll_con:FindChild("Container")
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.scroll_con:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        local go = self.item_con:FindChild(tostring(i)).gameObject
        local item = GuildMemberItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.scroll_con:GetComponent(RectTransform).sizeDelta.y


    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.item_con  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.BtnQuit.onClick:AddListener( function() self:on_click_info_btn(self.BtnQuit.gameObject) end)
    self.BtnDelete.onClick:AddListener( function() self:on_click_info_btn(self.BtnDelete.gameObject) end)
    self.BtnApply.onClick:AddListener( function() self:on_click_info_btn(self.BtnApply.gameObject) end)
    self.BtnBuild.onClick:AddListener( function() self:on_click_info_btn(self.BtnBuild.gameObject) end)
    self.BtnBack.onClick:AddListener( function() self:on_click_info_btn(self.BtnBack.gameObject) end)
    self.lt_BtnInfo.onClick:AddListener( function() self:on_click_info_btn(self.lt_BtnInfo.gameObject) end)
    self.lt_BtnMem.onClick:AddListener( function() self:on_click_info_btn(self.lt_BtnMem.gameObject) end)

    self.lic_BtnChange.onClick:AddListener( function()
        self.parent.model.board_announcement_type = 1
        self.parent.model:InitPurposeUI()
    end)
    self.lic_BtnChange2.onClick:AddListener( function()
        self.parent.model.board_announcement_type = 2
        self.parent.model:InitPurposeUI()
    end)

    self.lic_BtnReport.onClick:AddListener( function()
        ReportManager.Instance:Send14703()
    end)
    self.lic_BtnReport2.onClick:AddListener( function()
        ReportManager.Instance:Send14703()
    end)



    self.lmm_BtnEdit2.onClick:AddListener( function() self:on_set_mem_position() end)
    self.lmm_BtnEdit1.onClick:AddListener( function() self:on_change_mem_signature(self.lmm_BtnEdit1.gameObject) end)
    self.BtnToTemChange.onClick:AddListener( function() self:on_change_ToTem() end)
    self.BtnTanHao.onClick:AddListener( function()
        self:on_tips_study_mem(self.BtnTanHao.gameObject)
    end)

    self.BtnHealthyTanHao.onClick:AddListener( function()
        self.parent.model:InitGuildMergeTipsUI()
    end)

    self.BtnChangeName.onClick:AddListener( function()
        self.parent.model:InitChangeNameLookUI()
    end)

    self.title_lev.onClick:AddListener( function() self:on_mem_title_up_callback(1)  end)
    self.title_gx.onClick:AddListener( function() self:on_mem_title_up_callback(3)  end)
    self.title_pos.onClick:AddListener( function() self:on_mem_title_up_callback(2)  end)
    self.title_cup.onClick:AddListener( function() self:on_mem_title_up_callback(4)  end)
    self.title_require.onClick:AddListener( function() self:on_mem_title_up_callback(5)  end)
    self.title_tips_gx.gameObject:SetActive(false)
    -- self.title_tips_gx.onClick:AddListener( function()
    --     local tips = {}
    --     table.insert(tips, TI18N("反映玩家战力和竞技场实力"))
    --     TipsManager.Instance:ShowText({gameObject = self.title_tips_gx.gameObject, itemData = tips})
    -- end)
    self.title_tips_huoyue.onClick:AddListener( function()
        local tips = {}
        table.insert(tips, TI18N("<color='#ffff00'>活跃</color>反映玩家最近5天的活跃度"))
        table.insert(tips, TI18N("（以玩家<color='#00ff00'>聊天活跃度</color>和参与<color='#00ff00'>公会活动次数</color>为依据）"))
        table.insert(tips, TI18N("<color='#ffff00'>能力</color>反映玩家战力和竞技场实力"))
        table.insert(tips, TI18N("（以玩家<color='#00ff00'>战力评分</color>和<color='#00ff00'>竞技场杯数</color>为依据）"))
        TipsManager.Instance:ShowText({gameObject = self.title_tips_huoyue.gameObject, itemData = tips})
    end)

    self.lmb_BtnChat.onClick:AddListener(function() self:on_click_info_btn(self.lmb_BtnChat.gameObject)  end)
    self.lmb_BtnFriend.onClick:AddListener(function() self:on_click_info_btn(self.lmb_BtnFriend.gameObject)  end)
    self.lmb_BtnSpace.onClick:AddListener(function() self:on_click_info_btn(self.lmb_BtnSpace.gameObject)  end)
    self.lmb_BtnTeam.onClick:AddListener(function() self:on_click_info_btn(self.lmb_BtnTeam.gameObject)  end)

    self.totem_con_btn.onClick:AddListener(function() self:on_change_ToTem(self.totem_con_btn.gameObject)  end)

    self.l_ConBottomInfo:SetActive(true)
    self.l_ConBottomMem:SetActive(false)


    self:do_init()

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    self.has_init = true

    self.init_time = BaseUtils.BASE_TIME
    self:start_day_timer()
end



function GuildMainTabFirst:do_init()
    GuildManager.Instance:request11100()
    GuildManager.Instance:request11101()
    GuildManager.Instance:request11123()
    GuildManager.Instance:request11115()
end

--------切换左边选项卡逻辑
function GuildMainTabFirst:switch_tab(selectTab, selectBtn)
    if self.has_init == false then
        return
    end
    self.lt_BtnMem.image.sprite = self.tab_un_select
    self.lt_BtnInfo.image.sprite = self.tab_un_select
    self.lt_BtnInfo.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color2
    self.lt_BtnMem.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color2
    selectBtn.image.sprite = self.tab_select
    selectBtn.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color1
    self.l_ConBottomInfo:SetActive(false)
    self.l_ConBottomMem:SetActive(false)
    selectTab:SetActive(true)
end


---------------------------------更新逻辑
--更新公会图腾图标
function GuildMainTabFirst:update_ToTem_icon(totem)
    if self.has_init == false then
        return
    end
    if self.li_ToTem_icon ~= nil then
        self.li_ToTem_icon.gameObject:SetActive(true)
        self.li_ToTem_icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(totem))
    end
end

--更新公会图腾按钮状态
function GuildMainTabFirst:update_totem_btn()
    if self.has_init == false then
        return
    end

    local post = self.parent.model:get_my_guild_post()
    if self.BtnToTemChange == nil then
        return
    end
    if post == GuildManager.Instance.model.member_positions.leader then --我是会长
        self.BtnToTemChange.gameObject:SetActive(true)
    else
        self.BtnToTemChange.gameObject:SetActive(false)
    end
end

--更新公会祈祷按钮的红点状态
function GuildMainTabFirst:update_info_pray()
    if self.has_init == false then
        return
    end

    local count = 0
    count = self.parent.model.my_guild_data.insist_pray
end


--更新申请按钮的红点状态
function GuildMainTabFirst:update_info_apply_list()
    if self.has_init == false then
        return
    end

    local count = 0
    count = #self.parent.model.apply_list


    local ImgPoint = self.BtnApply.gameObject.transform:FindChild("ImgPoint").gameObject

    ImgPoint:SetActive(false)
    if self.parent.model:get_my_guild_post() < GuildManager.Instance.model.member_positions.elder then --我是会长
        return
    end

    if count > 0 then
        ImgPoint:SetActive(true)
    else
        ImgPoint:SetActive(false)
    end
end


--更新公会信息 --次复杂
function GuildMainTabFirst:update_left_guild_info()
    if self.has_init == false then
        return
    end

    -- local name = self.li_Item1:FindChild("TxtVal"):GetComponent(Text)
    -- local lev = self.li_Item2:FindChild("TxtVal"):GetComponent(Text)

    local leader = self.li_Item3:FindChild("TxtVal"):GetComponent(Text)
    local assets = self.li_Item4:FindChild("TxtVal"):GetComponent(Text)
    local mem_num = self.li_Item6:FindChild("TxtVal"):GetComponent(Text)
    local study_num = self.li_Item7:FindChild("TxtVal"):GetComponent(Text)

    local exchequer_cfg_data = DataGuild.data_get_vault_up_data[self.parent.model.my_guild_data.exchequer_lev]

    self.txt_name.text = self.parent.model.my_guild_data.Name
    self.txt_lev.text = string.format("%s:%s%s", TI18N("等级"), self.parent.model.my_guild_data.Lev, TI18N("级"))
    leader.text = self.parent.model.my_guild_data.LeaderName


    if self.parent.model.my_guild_data.MaxAssets <= self.parent.model.my_guild_data.Assets then
        assets.text = tostring("<color='#ee3900'>" .. self.parent.model.my_guild_data.Assets .. "</color>")
    else
        assets.text = tostring(self.parent.model.my_guild_data.Assets)
    end



    mem_num.text = string.format("%s/%s",tostring(self.parent.model.my_guild_data.MemNum), tostring(exchequer_cfg_data.mem))
    study_num.text = string.format("%s/%s", tostring(self.parent.model.my_guild_data.FreshNum), tostring(exchequer_cfg_data.fresh))
    if self.parent.model.my_guild_data.Board ~= "" then
        self.lic_TxtContent.text = self.parent.model.my_guild_data.Board
    else
        self.lic_TxtContent.text = TI18N("招收各职业成员，公会战勇夺第一！")
    end
    if self.parent.model.my_guild_data.Announcement ~= "" then
        self.lic_TxtContent2.text = self.parent.model.my_guild_data.Announcement
    else
        self.lic_TxtContent2.text = TI18N("每天必做玩法：做满10次职业任务，打满10张藏宝图，30环悬赏任务，2次多人副本，天空之塔尽量打满")
    end

    self.li_ToTem_icon.gameObject:SetActive(true)
    self.li_ToTem_icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(self.parent.model.my_guild_data.ToTem))


    self:update_guild_red_point()
end

--更新公会建筑按钮红点
function GuildMainTabFirst:update_guild_red_point()
    if self.has_init == false then
        return
    end
    local ImgPoint = self.BtnBuild.gameObject.transform:FindChild("ImgPoint").gameObject
    if self.parent.model.my_guild_data.lev_time > 0 or self.parent.model.my_guild_data.academy_time > 0 or self.parent.model.my_guild_data.exchequer_time > 0 or self.parent.model.my_guild_data.store_time > 0 then
        ImgPoint:SetActive(true)
    else
        ImgPoint:SetActive(false)
    end
end

--更新称号
function GuildMainTabFirst:update_guild_signature(_signature)
    if self.has_init == false then
        return
    end
    local signature = self.lmm_Item1:FindChild("TxtVal"):GetComponent(Text)
    signature.text = _signature
end

--更新选中公会成员信息,--这个最复杂
function GuildMainTabFirst:update_left_guild_mem()
    if self.has_init == false then
        return
    end

    local signature = self.lmm_Item1:FindChild("TxtVal"):GetComponent(Text)
    local pos = self.lmm_Item2:FindChild("TxtVal"):GetComponent(Text)
    signature.text = self.selected_mem_data.Signature
    pos.text = self.parent.model.member_position_names[self.selected_mem_data.Post]
    self.lmc_TxtClasses.text = KvData.classes_name[self.selected_mem_data.Classes]
    self.lmc_TxtClasses.color = ColorHelper.DefaultButton10
    -- if FriendManager.Instance:IsFriend(self.selected_mem_data.Rid, self.selected_mem_data.PlatForm, self.selected_mem_data.ZoneId) then
    --     self.lmb_BtnFriend.gameObject:SetActive(false)
    -- else
    --     self.lmb_BtnFriend.gameObject:SetActive(true)
    -- end


    self.lm_ImgClasses.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(self.selected_mem_data.Classes))


    if RoleManager.Instance.RoleData.id == self.selected_mem_data.Rid and RoleManager.Instance.RoleData.zone_id == self.selected_mem_data.ZoneId and RoleManager.Instance.RoleData.platform == self.selected_mem_data.PlatForm then
        --选中自己，则按钮全部失效
        self.lmb_BtnChat.enabled = false
        self.lmb_BtnTeam.enabled = false
        self.lmb_BtnFriend.enabled = false
        self.lmb_BtnSpace.enabled = false

        self.lmb_BtnChat.image.sprite = self.lmb_unenable_img
        self.lmb_BtnTeam.image.sprite = self.lmb_unenable_img
        self.lmb_BtnFriend.image.sprite = self.lmb_unenable_img
        self.lmb_BtnSpace.image.sprite = self.lmb_unenable_img
    else
        self.lmb_BtnChat.enabled = true
        self.lmb_BtnTeam.enabled = true
        self.lmb_BtnFriend.enabled = true
        self.lmb_BtnSpace.enabled = true

        self.lmb_BtnChat.image.sprite = self.lmb_enable_img
        self.lmb_BtnTeam.image.sprite = self.lmb_enable_img
        self.lmb_BtnFriend.image.sprite = self.lmb_enable_img
        self.lmb_BtnSpace.image.sprite = self.lmb_enable_img
    end
    if self.cur_left_model_data ~= nil and self.cur_left_model_data.Rid == self.selected_mem_data.Rid and self.cur_left_model_data.ZoneId == self.selected_mem_data.ZoneId and self.cur_left_model_data.PlatForm == self.selected_mem_data.PlatForm then
        return --选中同一个成员，则无需重新请求模型数据
    end
    self.cur_left_model_data = self.selected_mem_data
    --更新模型,请求模型数据
    GuildManager.Instance:request11140(self.cur_left_model_data.Rid, self.cur_left_model_data.PlatForm, self.cur_left_model_data.ZoneId)
end

--删除成员列表里面某个成员
function GuildMainTabFirst:delete_fire_member(d)
    if self.has_init == false then
        return
    end

    if self.selected_mem_data ~= nil and d ~= nil then
        if  d.Rid == self.selected_mem_data.Rid and d.PlatForm == self.selected_mem_data.PlatForm and d.ZoneId == self.selected_mem_data.ZoneId then
            self.selected_mem_data = nil
        end
    end

    EventMgr.Instance:Fire(event_name.guild_member_update, {data = d})
end

--更新成员列表
function GuildMainTabFirst:update_member_list()
    if self.has_init == false then
        return
    end

    local myPost = self.parent.model:get_my_guild_post()
    if myPost==GuildManager.Instance.model.member_positions.leader then --我是会长
        self.BtnQuit.transform:FindChild("Text"):GetComponent(Text).text = TI18N("转让会长")
    else
        self.BtnQuit.transform:FindChild("Text"):GetComponent(Text).text = TI18N("脱离公会")
    end

    if #self.parent.model.guild_member_list == 1 then
        self.BtnQuit.transform:FindChild("Text"):GetComponent(Text).text = TI18N("解散公会")
    end

    local member_list_post_sort = function(a, b)
        return a.Post > b.Post
    end

    local member_list_online_sort = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.Post > b.Post
        end
    end

    table.sort(self.parent.model.guild_member_list, member_list_post_sort)
    table.sort(self.parent.model.guild_member_list, member_list_online_sort)

    local index = 2
    self.current_mem_data_list = {}
    --把自己放到第一位
    for i=1,#self.parent.model.guild_member_list do
        local d = self.parent.model.guild_member_list[i]
        if d.deleted ~= true then
            if d.Rid == RoleManager.Instance.RoleData.id  and d.PlatForm == RoleManager.Instance.RoleData.platform  and  d.ZoneId == RoleManager.Instance.RoleData.zone_id  then
                self.current_mem_data_list[1] = d
            else
                self.current_mem_data_list[index] = d
                index = index + 1
            end
        end
    end
    local hasIn = false
    if self.selected_mem_data ~= nil then
        for k, v in pairs( self.current_mem_data_list) do
            if v.Rid == self.selected_mem_data.Rid  and v.PlatForm == self.selected_mem_data.PlatForm  and  v.ZoneId == self.selected_mem_data.ZoneId  then
                    hasIn = true
                    break
            end
        end
    end
    if hasIn == false then
        self.selected_mem_data = nil
    end

    self.setting_data.data_list = self.current_mem_data_list
    BaseUtils.refresh_circular_list(self.setting_data)
end

--点击选中某个成员
function GuildMainTabFirst:on_click_mem_item(data, _type)
    for i=1,#self.item_list do
        self.item_list[i].ImgSelected.gameObject:SetActive(false)
    end

    self.selected_mem_data = data
    self:update_left_guild_mem()

    if _type == nil then
        --强制切换
        self:switch_tab(self.l_ConBottomMem, self.lt_BtnMem)
    end
end

--更新单个成员信息
function GuildMainTabFirst:update_one_member(member_data)
    if self.has_init == false then
        return
    end

    if self.selected_mem_data ~= nil then
        if member_data.Rid == self.selected_mem_data.Rid and member_data.PlatForm == self.selected_mem_data.PlatForm and member_data.ZoneId == self.selected_mem_data.ZoneId then
            self:update_left_guild_mem()
        end
    end
    --派发更新
    EventMgr.Instance:Fire(event_name.guild_member_update, {data = member_data})
end

------------------------------监听器逻辑
--打开自荐逻辑
function GuildMainTabFirst:on_recommend(index)
    if index == 1 then
        --除会长以外的人都可以自荐做会长
        if self.parent.model:get_my_guild_post() == GuildManager.Instance.model.member_positions.leader then
            NoticeManager.Instance:FloatTipsByString(TI18N("您已经是会长了"))
            return
        end
        GuildManager.Instance:request11158()
    elseif index == 2 then
        --所有人都可以点开看自荐列表
        self.parent.model:InitRecommendUI()
    end
end

--更改成员签名
function GuildMainTabFirst:on_change_mem_signature(g)
    self.parent.model.change_signature_data = self.selected_mem_data
    if self.parent.model:get_my_guild_post() == GuildManager.Instance.model.member_positions.leader then --我是会长
        if self.parent.model.my_guild_data.Signable == 0 then
             NoticeManager.Instance:FloatTipsByString(TI18N("该成员本周设置称号次数达到上限"))
        else
            self.parent.model:InitChangeSignatureUI()
        end
    else --我不是会长
        -- local temp = {}
        -- table.insert(temp,TI18N("1.称号由会长设置"))
        -- table.insert(temp,TI18N("2.每周限定称号设置称号次数"))
        -- table.insert(temp,TI18N("3.称号设置次数与城堡等级挂钩"))
        -- local t = {trans=g.transform,content=temp}
        -- mod_tips.general_tips(t)
    end
end

--设置成员职位
function GuildMainTabFirst:on_set_mem_position()
    local myPost = self.parent.model:get_my_guild_post()
    if myPost==GuildManager.Instance.model.member_positions.leader or myPost==GuildManager.Instance.model.member_positions.vice_leader then --会长和副会长才有权限设置职位
        if self.selected_mem_data == nil then
            NoticeManager.Instance:FloatTipsByString(self.parent.model.guild_lang.GUILD_INFO_NOTIFY_WORD_1)
            return
        elseif RoleManager.Instance.RoleData.id == self.selected_mem_data.Rid and RoleManager.Instance.RoleData.zone_id == self.selected_mem_data.ZoneId and RoleManager.Instance.RoleData.platform == self.selected_mem_data.PlatForm then
            NoticeManager.Instance:FloatTipsByString(self.parent.model.guild_lang.GUILD_INFO_NOTIFY_WORD_2)
            return
        elseif self.selected_mem_data.Post >= myPost then
            NoticeManager.Instance:FloatTipsByString(self.parent.model.guild_lang.GUILD_INFO_NOTIFY_WORD_3)
            return
        end
        self.parent.model.select_mem_oper_data = {}
        self.parent.model.select_mem_oper_data.guildMemData = self.selected_mem_data
        self.parent.model:InitPositionUI()
    else
        NoticeManager.Instance:FloatTipsByString(self.parent.model.guild_lang.GUILD_INFO_NOTIFY_WORD_4)
    end
end


--修改公会图腾
function GuildMainTabFirst:on_change_ToTem()
    self.parent.model:InitTotemUI()
end

--公会新秀叹号tips
function GuildMainTabFirst:on_tips_study_mem(g)
    local tips = {}
    table.insert(tips, string.format("%s<color='#ffff00'>%s</color>%s", TI18N("1.等级≤"), self.parent.model.unfresh_man_lev, TI18N("级的角色加入公会自动成为【公会新秀】")))
    table.insert(tips, TI18N("2.离线时间＞<color='#ffff00'>24小时</color>系统自动踢出"))
    table.insert(tips, string.format("%s<color='#ffff00'>%s</color>%s", TI18N("3.等级＞"), self.parent.model.unfresh_man_lev, TI18N("级自动转为正式成员")))
    table.insert(tips, TI18N("4.会长可直接通过设置职位转为正式成员"))
    table.insert(tips, TI18N("5.会长、副会长可以设置新秀转为正式成员等级"))
    TipsManager.Instance:ShowText({gameObject = g, itemData = tips})
end

--按钮点击监听
function GuildMainTabFirst:on_click_info_btn(g)
    if self.BtnQuit.gameObject == g then
        local notifyStr = ""
        if RoleManager.Instance.RoleData.id == self.selected_mem_data.Rid and RoleManager.Instance.RoleData.zone_id == self.selected_mem_data.ZoneId and RoleManager.Instance.RoleData.platform == self.selected_mem_data.PlatForm then
            --选中自己，且自己是会长
            if self.parent.model:get_my_guild_post() == GuildManager.Instance.model.member_positions.leader and #self.parent.model.guild_member_list > 1  then
                NoticeManager.Instance:FloatTipsByString(TI18N("你已经是会长了，不要闹"))
                return
            elseif self.parent.model:get_my_guild_post() == GuildManager.Instance.model.member_positions.leader and #self.parent.model.guild_member_list == 1  then
                --自己不是会长,或者自己是会长但是公会只有自己的时候，则退出公会
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("解散公会你可以选择更好的，不再是寂寞一个人的公会，是否要解散？")
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    GuildManager.Instance:request11105()
                end
                NoticeManager.Instance:ConfirmTips(data)
            else
                --自己不是会长,则退出公会
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("脱离公会后将扣除<color='#4dd52b'>100</color>{assets_2, 90011}，你确定要离开公会？<color='#2fc823'>重新加入公会需要3天后才能参加公会战</color>")
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    GuildManager.Instance:request11105()
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        else
            --没选中自己
            if self.parent.model:get_my_guild_post() == GuildManager.Instance.model.member_positions.leader then --出现确认框
                --自己是会长，则转让会长
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                local str1 = string.format("%s<color='#ff0000'>%s</color>?", TI18N("当前操作将把会长转让给"), self.selected_mem_data.Name)
                str1 = string.format("%s\n<color='#2fc823'>（%s）</color>", str1, TI18N("每个公会每天只可更换一次会长"))
                data.content = str1
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    GuildManager.Instance:request11121(self.selected_mem_data.Rid, self.selected_mem_data.PlatForm, self.selected_mem_data.ZoneId)
                end
                NoticeManager.Instance:ConfirmTips(data)
            else
                --自己不是会长，则退出公会
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("脱离公会后将扣除<color='#4dd52b'>100</color>{assets_2, 90011}，你确定要离开公会？<color='#2fc823'>重新加入公会需要3天后才能参加公会战</color>")
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    GuildManager.Instance:request11105()
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    elseif self.BtnDelete.gameObject == g then
        self.parent.model.update_mem_mange_data = self.selected_mem_data
        self.parent.model:InitGuildMemManageUI()

        if true then
            return
        end

        --开除成员操作
        if RoleManager.Instance.RoleData.id == self.selected_mem_data.Rid and RoleManager.Instance.RoleData.zone_id == self.selected_mem_data.ZoneId and RoleManager.Instance.RoleData.platform == self.selected_mem_data.PlatForm then
            NoticeManager.Instance:FloatTipsByString(TI18N("无法对自己执行开除成员操作"))
            return
        end
        local myPost = self.parent.model:get_my_guild_post()
        if myPost >=GuildManager.Instance.model.member_positions.elder then --出现确认框
            if self.selected_mem_data.Post == GuildManager.Instance.model.member_positions.stduy then
                --开除公会新秀
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format("%s%s", TI18N("是否踢除"), self.selected_mem_data.Name)
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    GuildManager.Instance:request11109(self.selected_mem_data.Rid, self.selected_mem_data.PlatForm, self.selected_mem_data.ZoneId)
                end
                NoticeManager.Instance:ConfirmTips(data)
            else
                local msg = string.format(self.parent.model.guild_lang.GUILD_INFO_OUT_NOTIFY_3, self.selected_mem_data.Name)
                local time_gap = BaseUtils.BASE_TIME - self.selected_mem_data.LastLogin
                if time_gap <= 86400 then
                    msg = TI18N("开除该成员将消耗5活力，是否继续？")
                end
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = msg
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    GuildManager.Instance:request11109(self.selected_mem_data.Rid, self.selected_mem_data.PlatForm, self.selected_mem_data.ZoneId)
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        else
            local tips = {}
            table.insert(tips, self.parent.model.guild_lang.GUILD_INFO_OUT_NOTIFY_4)
            TipsManager.Instance:ShowText({gameObject = self.BtnDelete.gameObject, itemData = tips})
        end
    elseif self.BtnApply.gameObject == g then
        self.parent.model:InitApplyListUI()
    elseif self.BtnBuild.gameObject == g then
        self.parent.model:InitBuildUI(1)
    elseif self.BtnBack.gameObject == g then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon and DungeonManager.Instance.activeType == 5 then
            DungeonManager.Instance:ExitDungeon()
        else
            GuildManager.Instance:request11128()
        end
    elseif self.lt_BtnInfo.gameObject == g then
        self:switch_tab(self.l_ConBottomInfo, self.lt_BtnInfo)
        self:update_left_guild_info()
    elseif self.lt_BtnMem.gameObject == g then
        self:switch_tab(self.l_ConBottomMem, self.lt_BtnMem)
        -- self:update_member_list()
    elseif self.lmb_BtnChat.gameObject == g then
        local f_data = {id = self.selected_mem_data.Rid, platform = self.selected_mem_data.PlatForm, zone_id = self.selected_mem_data.ZoneId, sex = self.selected_mem_data.Sex, classes = self.selected_mem_data.Classes, lev = self.selected_mem_data.Lev, name = self.selected_mem_data.Name}
        FriendManager.Instance:AddUnknowMan(f_data) --加入到最近联系人
        FriendManager.Instance:TalkToUnknowMan(f_data)
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friend)
    elseif self.lmb_BtnFriend.gameObject == g then
        FriendManager.Instance:Require11804(self.selected_mem_data.Rid, self.selected_mem_data.PlatForm, self.selected_mem_data.ZoneId)
    elseif self.lmb_BtnSpace.gameObject == g then
        ZoneManager.Instance:OpenOtherZone(self.selected_mem_data.Rid, self.selected_mem_data.PlatForm, self.selected_mem_data.ZoneId)
    elseif self.lmb_BtnTeam.gameObject == g then

        local func = nil
        local uniqueroleid = BaseUtils.get_unique_roleid(self.selected_mem_data.Rid, self.selected_mem_data.ZoneId, self.selected_mem_data.PlatForm)
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            -- 自己是队长的时候的处理
            if TeamManager.Instance:IsInMyTeam(uniqueroleid) then -- TI18N("踢出队伍")
                func = function(rid, platform, zone) TeamManager.Instance:KickOut(rid, platform, zone) end
            else --TI18N("组队")
                func = function(rid, platform, zone) TeamManager.Instance:Send11702(rid, platform, zone) end
            end
        else
            -- 自己不是队长的时候
            func = function(rid, platform, zone) TeamManager.Instance:Send11702(rid, platform, zone) end
        end

        func(self.selected_mem_data.Rid, self.selected_mem_data.PlatForm, self.selected_mem_data.ZoneId)

    end
end

--开除公会成员监听器
function GuildMainTabFirst:on_fire_mem_call_back()
    GuildManager.Instance:request11109(self.selected_mem_data.Rid, self.selected_mem_data.PlatForm, self.selected_mem_data.ZoneId)
end



---------------------------------右边公会成员列表逻辑

function GuildMainTabFirst:on_select_mem_item(item)
    if self.last_selected_item ~= nil then
        self:set_mem_item_selected(self.last_selected_item, false)
    end

    self:set_mem_item_selected(item, true)

    --请求模型数据
    self.selected_mem_data = item.data

    self:switch_tab(self.l_ConBottomMem, self.lt_BtnMem)
    self:update_left_guild_mem()

    self.last_selected_item = item
end



--点击成员列表标题，进行列表排序
function GuildMainTabFirst:on_mem_title_up_callback(index)
    --公会成员列表排序逻辑

    if index == 1 then --按钮等级进行排序
        if self.sortType == 1 then
            table.sort(self.parent.model.guild_member_list, self.parent.model.lev_sort2)
            table.sort(self.parent.model.guild_member_list, self.parent.model.lev_sort4)
            self.sortType = 11
        else
            table.sort(self.parent.model.guild_member_list, self.parent.model.lev_sort)
            table.sort(self.parent.model.guild_member_list, self.parent.model.lev_sort3)
            self.sortType = 1
        end
    elseif index == 2 then--按职位进行排序
        if self.sortType == 2 then
            table.sort(self.parent.model.guild_member_list, self.parent.model.post_sort2)
            table.sort(self.parent.model.guild_member_list, self.parent.model.post_sort4)
            self.sortType = 21
        else
            table.sort(self.parent.model.guild_member_list, self.parent.model.post_sort)
            table.sort(self.parent.model.guild_member_list, self.parent.model.post_sort3)
            self.sortType = 2
        end
    elseif index == 3 then --按贡献进行排序
        if self.sortType == 3 then
            table.sort(self.parent.model.guild_member_list, self.parent.model.gx_sort2)
            table.sort(self.parent.model.guild_member_list, self.parent.model.gx_sort4)
            self.sortType = 31
        else
            table.sort(self.parent.model.guild_member_list, self.parent.model.gx_sort)
            table.sort(self.parent.model.guild_member_list, self.parent.model.gx_sort3)
            self.sortType = 3
        end
    elseif index == 4 then
        if self.sortType == 4 then
            table.sort(self.parent.model.guild_member_list, self.parent.model.cup_sort2)
            table.sort(self.parent.model.guild_member_list, self.parent.model.cup_sort4)
            self.sortType = 41
        else
            table.sort(self.parent.model.guild_member_list, self.parent.model.cup_sort)
            table.sort(self.parent.model.guild_member_list, self.parent.model.cup_sort3)
            self.sortType = 4
        end
    elseif index == 5 then
        if self.sortType == 5 then
            table.sort(self.parent.model.guild_member_list, self.parent.model.require_sort2)
            table.sort(self.parent.model.guild_member_list, self.parent.model.require_sort4)
            self.sortType = 51
        else
            table.sort(self.parent.model.guild_member_list, self.parent.model.require_sort)
            table.sort(self.parent.model.guild_member_list, self.parent.model.require_sort3)
            self.sortType = 5
        end
    end


        --把自己放到第一位
    local index = 2
    local myself = nil
    self.current_mem_data_list = {}
    --把自己放到第一位
    for i=1,#self.parent.model.guild_member_list do
        local d = self.parent.model.guild_member_list[i]
        if d.Rid == RoleManager.Instance.RoleData.id  and d.PlatForm == RoleManager.Instance.RoleData.platform  and  d.ZoneId == RoleManager.Instance.RoleData.zone_id  then
            self.current_mem_data_list[1] = d
        else
            self.current_mem_data_list[index] = d
            index = index + 1
        end
    end

    -- self:refresh_item_list()
    self.setting_data.data_list = self.current_mem_data_list
    BaseUtils.refresh_circular_list(self.setting_data)
end


----------------------------------列表跨天计时器
--开始计时
function GuildMainTabFirst:start_day_timer()
    self:stop_day_timer()
    self.day_timer_id = LuaTimer.Add(0, 1000, function() self:day_timer_tick() end)
end

--结束计时
function GuildMainTabFirst:stop_day_timer()
    if self.day_timer_id ~= 0 then
        LuaTimer.Delete(self.day_timer_id)
        self.day_timer_id = 0
    end
end

--计时进行中
function GuildMainTabFirst:day_timer_tick()
    --判断下是否跨天了，是的话，就刷新公会成员列表

    local last_month = tonumber(os.date("%m", self.init_time))
    local last_day = tonumber(os.date("%d", self.init_time))
    local cur_time = BaseUtils.BASE_TIME - 15
    local cur_month = tonumber(os.date("%m", cur_time))
    local cur_day = tonumber(os.date("%d", cur_time))


    if last_month < cur_month then
        self:stop_day_timer()
        GuildManager.Instance:request11101()
    elseif last_day < cur_day then
        self:stop_day_timer()
        GuildManager.Instance:request11101()
    end
end


----------------------------------公会成员模型逻辑
--更新模型
function GuildMainTabFirst:update_info_mem_model(looks)
    if self.selected_mem_data == nil then
        return
    end
    local _looks = looks
    if _looks == nil then
        _looks = self.cur_looks
    end
    self.cur_looks = _looks

    if _looks == nil then
        return
    end

    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end

    local setting = {
        name = "GuildRole"
        ,orthographicSize = 0.8
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Role, classes = self.selected_mem_data.Classes, sex = self.selected_mem_data.Sex, looks = _looks}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)

        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function() self.previewComp1:Hide() end)
        self.OnOpenEvent:AddListener(function() self.previewComp1:Show() end)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--模型完成加载
function GuildMainTabFirst:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.lm_Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end



-------------------------------------------循环列表逻辑
--根据数据列表，刷新item列表，初始化调用，或者数据列表重置时调用
-- function GuildMainTabFirst:refresh_item_list()
--     --将所有item setActive false
--     for i=1,#self.item_list do
--         self.item_list[i]:SetActive(false)
--     end

--     --重置双指针
--     self.data_head_index = 1 --数据头指针
--     self.data_tail_index = #self.current_mem_data_list > #self.item_list and #self.item_list or #self.current_mem_data_list --数据尾指针

--     self.item_head_index = 1 --item头指针
--     self.item_tail_index = #self.current_mem_data_list > #self.item_list and #self.item_list or #self.current_mem_data_list --数据尾指针

--     --设置容器高度
--     self:set_item_parent_height()

--     --设置容器的坐标到零点
--     self.item_con:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)

--     --设置每个item到初始坐标
--     self:reset_item_pos()

--     --设置数据
--     for i=1,#self.current_mem_data_list do
--         if i <= #self.item_list then
--             local item = self.item_list[i]
--             local data = self.current_mem_data_list[i]
--             item:update_my_self(data, i)
--             item:SetActive(true)
--         else
--             --超过了最大的item个数，就break掉不必再遍历
--             break
--         end
--     end
-- end

-- --根据data的个数，设置item的父容器高度
-- function GuildMainTabFirst:set_item_parent_height()
--     if self.current_mem_data_list == nil then
--         --设置高度为0
--         self.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, 0)
--         return
--     end
--     if #self.current_mem_data_list == 0 then
--         --设置高度为0
--         self.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, 0)
--         return
--     end
--     local newH = #self.current_mem_data_list*self.single_item_height
--     self.item_con_height = newH
--     self.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, newH)
-- end

-- --根据item所在的列表位置，将其重置到初始坐标
-- function GuildMainTabFirst:reset_item_pos()
--     for i=1,#self.item_list do
--         local newY = (i-1)*-50
--         self.item_list[i].transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, newY)
--     end
-- end

-- --scroll滚动监听
-- function GuildMainTabFirst:on_scroll_value_change(val)
--     --核心逻辑，这里执行循环设置item的pos和data
--     local cur_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y

--     self.scroll_change_count = self.scroll_change_count + math.abs(cur_y - self.item_con_last_y)

--     if self.scroll_change_count < self.single_item_height then
--         --累计还没达到一个item的高度变化
--         self.item_con_last_y = cur_y
--         return
--     end

--     --计算运动个数
--     local cross_step = math.floor(self.scroll_change_count/self.single_item_height)

--     for i=1,cross_step do
--         if cur_y <= self.item_con_last_y then
--             --向下拉
--             if self.data_head_index ~= 1 and cur_y < (self.item_con_height - self.scroll_con_height) then
--                 --还没到顶

--                 local tail_item = self.item_list[self.item_tail_index]
--                 local oldY = tail_item.transform:GetComponent(RectTransform).anchoredPosition.y
--                 --判断下尾item是否已经在显示区域之外
--                 if math.abs(oldY) > (math.abs(cur_y)+self.scroll_con_height+2*self.single_item_height) then

--                     --取尾指针所指的item放到头指针所指item的顶部，同时改变头尾item指针
--                     self.data_head_index = self.data_head_index - 1
--                     self.data_tail_index = self.data_tail_index - 1

--                     local mem_data = self.current_mem_data_list[self.data_head_index]
--                     tail_item:update_my_self(mem_data, self.data_head_index) --设置数据
--                     --挪位， 将tail_item放到顶部
--                     local newY = oldY + #self.item_list*50
--                     tail_item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, newY)
--                     self.item_head_index = self.item_tail_index
--                     self.item_tail_index = self.item_tail_index - 1
--                     if self.item_tail_index <= 0 then
--                         self.item_tail_index = #self.item_list
--                     end
--                 end
--             end
--         elseif cur_y > self.item_con_last_y then
--             --向上拉
--             if self.data_tail_index ~= #self.current_mem_data_list and cur_y >= self.single_item_height then
--                 --还没到底

--                 local head_item = self.item_list[self.item_head_index]
--                 local oldY = head_item.transform:GetComponent(RectTransform).anchoredPosition.y
--                 --判断下头item是否已经在显示区域之外
--                 if math.abs(oldY) < math.abs(cur_y) - 2*self.single_item_height then

--                     --取头指针所指的item放到尾指针所指的item的底部，同时改变头尾item指针
--                     self.data_tail_index = self.data_tail_index + 1
--                     self.data_head_index = self.data_head_index + 1

--                     local mem_data = self.current_mem_data_list[self.data_tail_index]
--                     head_item:update_my_self(mem_data, self.data_tail_index) --设置数据
--                     --挪位，将head_item放到底部
--                     local newY = oldY - #self.item_list*50
--                     head_item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, newY)
--                     self.item_tail_index = self.item_head_index
--                     self.item_head_index = self.item_head_index + 1
--                     if self.item_head_index > #self.item_list then
--                         self.item_head_index = 1
--                     end
--                 end
--             end
--         end
--         self.scroll_change_count = self.scroll_change_count - self.single_item_height
--     end
--     self.item_con_last_y = cur_y
-- end
