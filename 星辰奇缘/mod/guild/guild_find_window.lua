GuildFindWindow = GuildFindWindow or BaseClass(BaseWindow)

function GuildFindWindow:__init(model)
    self.name = "GuildFindWindow"
    self.model = model

    self.windowId = WindowConfig.WinID.guild_find_win


    self.resList = {
        {file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
        ,{file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        ,{file = AssetConfig.guild_find_win, type = AssetType.Main}
    }
    self.effect = nil
    self.fps = nil
    self.timerId = 0


    self.item_list = nil
    self.single_item_height = 0
    self.scroll_con_height = 0
    self.item_con_height = 0

    self.is_search_state = false

    self.item_init_num = 10 --初始化滚动区域有10个存在
    self.model.guild_list = nil
    self.data_pointer = 1 --数据指针
    self.left_scale = 1/7 --剩余区域比例，超过该比例则检查是否有还有数据要显示
    self.path_load_num = 5 --每个批量加载多少个
    self.list_has_init = false

    self.find_item_list = nil
    return self
end

function GuildFindWindow:__delete()
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:Release()
        end
    end
    self.item_list = nil
    self.single_item_height = 0
    self.scroll_con_height = 0
    self.item_con_height = 0

    self.list_has_init = false
    self.is_open = false
    self.find_item_list=nil

    if self.tabpage ~= nil then
        self.tabpage:DeleteMe()
        self.tabpage = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end



    self:AssetClearAll()
    -- LuaTimer.Delete(self.timerId)
end


function GuildFindWindow:InitPanel()
    if self.gameObject ~= nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_find_win))
    self.gameObject.name = "guild_find_win"

    local gtr = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.main_con = gtr:FindChild("MainCon").gameObject.transform

    local close_btn = self.main_con:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseFindUI() end)

    self.left_con=self.main_con:FindChild("LeftCon")
    self.l_bottom_con=self.left_con:FindChild("BottomCon")
    self.l_search_btn=self.l_bottom_con:FindChild("BtnSearch"):GetComponent(Button)
    self.btn_one_key_apply=self.l_bottom_con:FindChild("BtnOneKeyApply"):GetComponent(Button)
    self.l_bottom_input=self.l_bottom_con:FindChild("InputField"):GetComponent(InputField)

    self.l_bottom_input.textComponent = self.l_bottom_input.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.l_bottom_input.placeholder = self.l_bottom_input.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.l_search_btn_txt = self.l_search_btn.gameObject.transform:FindChild("Text"):GetComponent(Text)
    self.l_top_con=self.left_con:FindChild("TopCon").gameObject

    self.mask_con = self.l_top_con.transform:FindChild("ItemCon"):FindChild("MaskCon")
    self.scroll_con = self.mask_con:FindChild("ScrollLayer")
    self.item_con = self.scroll_con:FindChild("Container")
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.scroll_con:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        local go = self.item_con:FindChild(tostring(i)).gameObject
        local item = GuildFindItem.New(go, self)
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

    self.right_con=self.main_con:FindChild("RightCon").gameObject
    self.bottom_con=self.right_con.transform:FindChild("BottomCon").gameObject

    self.txt_zongzhi = self.right_con.transform:FindChild("TxtZongzhi"):GetComponent(Text)

    self.TitleTxt = self.right_con.transform:FindChild("TitleCon"):FindChild("Text"):GetComponent(Text)

    self.Panel1 = self.right_con.transform:FindChild("Panel1")
    self.ToggleGroup = self.right_con.transform:FindChild("ToggleGroup")
    local panel = self.Panel1:Find("MaskScroll").gameObject
    self.tabpage = TabbedPanel.New(panel, 2, 214)
    self.tabpage.MoveEndEvent:AddListener(
        function(page)
            for i=1,2 do
                self.ToggleGroup:Find(tostring(i)):GetComponent(Toggle).isOn = (i==page)
            end
            if page == 1 then
                self.TitleTxt.text = TI18N("公会宗旨")
            else
                self.TitleTxt.text  = TI18N("公会公告")
            end
        end
    )

    self.board_con_1 = self.Panel1:Find("MaskScroll"):FindChild("Container"):FindChild("Page1")
    self.txt_zongzhi_1 = self.board_con_1:FindChild("TxtZongzhi"):GetComponent(Text)

    self.board_con_2 = self.Panel1:Find("MaskScroll"):FindChild("Container"):FindChild("Page2")
    self.txt_zongzhi_2 = self.board_con_2:FindChild("TxtZongzhi"):GetComponent(Text)

    self.btn_create_guild=self.bottom_con.transform:FindChild("BtnCreateGuild"):GetComponent(Button)
    self.btn_connect_leader = self.bottom_con.transform:FindChild("BtnConnectLeader"):GetComponent(Button)
    self.btn_apply_guild = self.bottom_con.transform:FindChild("BtnApply"):GetComponent(Button)

    self.btn_create_guild.onClick:AddListener(function() self:on_click_btn(1)  end)
    self.btn_one_key_apply.onClick:AddListener(function() self:on_click_btn(2)  end)
    self.l_search_btn.onClick:AddListener(function() self:on_click_btn(3)  end)

    self.btn_connect_leader.onClick:AddListener(function() self:on_click_btn(4)  end)
    self.btn_apply_guild.onClick:AddListener(function() self:on_click_btn(5)  end)

    self.is_open = true


    self.grey_img = self.btn_create_guild.image.sprite
    self.green_img = self.btn_apply_guild.image.sprite
    self.blue_img  = self.btn_connect_leader.image.sprite
    local lev = RoleManager.Instance.world_lev - 15
    lev = lev > 50 and 50 or lev
    if RoleManager.Instance.RoleData.lev < 20 then
        self.btn_create_guild.image.sprite = self.grey_img
        self.bottom_con.transform:Find("BtnCreateGuild/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
    else
        self.btn_create_guild.image.sprite = self.blue_img
        self.bottom_con.transform:Find("BtnCreateGuild/Text"):GetComponent(Text).color = ColorHelper.TabButton2Normal
    end

    --判断下是否已经有公会了
    if self.model:check_has_join_guild() then
        self.btn_create_guild.image.sprite = self.grey_img
        self.btn_apply_guild.image.sprite = self.grey_img
        self.btn_one_key_apply.image.sprite = self.grey_img
        self.bottom_con.transform:Find("BtnCreateGuild/Text"):GetComponent(Text).color = ColorHelper.TabButton2Normal
        self.l_bottom_con:Find("BtnOneKeyApply/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
        self.bottom_con.transform:Find("BtnApply/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
    end

    GuildManager.Instance:request11106()

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end



function GuildFindWindow:on_click_btn(index)
    if index == 1 then
        if self.model:check_has_join_guild() then
             NoticeManager.Instance:FloatTipsByString(TI18N("你当前已有公会"))
            return
        end
        local lev = RoleManager.Instance.world_lev - 15
        lev = lev > 50 and 50 or lev
        if RoleManager.Instance.RoleData.lev < 20 then
            NoticeManager.Instance:FloatTipsByString(string.format("%s<color='#4dd52b'>%s</color>%s", TI18N("需要升到"), 20 , TI18N("级才能创建公会")))
            return
        end
        if RoleManager.Instance.RoleData.cross_type == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("跨服区暂未开放此功能，敬请期待"))
            return
        end
        self.model:InitCreateUI()
    elseif index == 2 then
        if self.model:check_has_join_guild() then
             NoticeManager.Instance:FloatTipsByString(TI18N("你当前已有公会"))
            return
        end
        self.model:one_key_apply_all_guild()
    elseif index == 3 then
        if self.is_search_state then --返回
            if self.is_search_state == true then
                self.is_search_state = false
                self:display_all_guild()
            end
            return
        end

        --搜索
        if self.l_bottom_input.text == "" then
            print(TI18N("请输入要搜索的公会名称"))
            -- mod_notify.append_scroll_win(TI18N("请输入要搜索的公会名称"))
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入要搜索的公会名称"))
            return
        end
        GuildManager.Instance:request11102(self.l_bottom_input.text)
    elseif index == 4 then
        --联系会长
        if self.last_selected_item == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先选中列表中的公会再使用联系会长"))
            return
        end
        local temp_data = self.last_selected_item.data
        local f_data = {id = temp_data.LeaderRid, platform = temp_data.LeaderPlatform, zone_id = temp_data.LeaderZoneId, sex = temp_data.LeaderSex, classes = temp_data.LeaderClasses, lev = temp_data.LeaderLev, name = temp_data.LeaderName}
        FriendManager.Instance:AddUnknowMan(f_data) --加入到最近联系人
        FriendManager.Instance:TalkToUnknowMan(f_data)
    elseif index == 5 then
        if self.model:check_has_join_guild() then
             NoticeManager.Instance:FloatTipsByString(TI18N("你当前已有公会"))
            return
        end
        --申请入会
        if self.last_selected_item == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有公会可以申请，创建公会你就能成为全服第一个会长"))
            return
        end
        self.model:OpenApplyMsgWindow(self.last_selected_item.data)
        -- GuildManager.Instance:request11104(self.last_selected_item.data.GuildId,self.last_selected_item.data.PlatForm,self.last_selected_item.data.ZoneId)
    end
end

--更新公会列表
function GuildFindWindow:update_view()
    if self.is_open == true then
         self:display_all_guild()
    end
end

function GuildFindWindow:display_all_guild()
    self.l_search_btn_txt.text = TI18N("搜索")
    if self.model.guild_list ~= nil then
        self:display_items(self.model.guild_list)
    end
end

function GuildFindWindow:display_search_result_list(templist)
    self.is_search_state = true
    self.l_search_btn_txt.text = TI18N("返回")
    if templist ~= nil then
        self:display_items(templist)
    end
end

function GuildFindWindow:display_back()
    if self.is_search_state == true then
        self:display_all_guild()
    end
end


function GuildFindWindow:display_items(list)
    self.l_bottom_input.text = ""
    if self.list_has_init == false then
        self.current_data_list = self.model.guild_list
    else
        self.current_data_list = list
    end

    self:confuse_data_list()

    self.setting_data.data_list = self.current_data_list
    BaseUtils.refresh_circular_list(self.setting_data)
    self.list_has_init = true
end

--打乱数据列表的顺勋
function GuildFindWindow:confuse_data_list()
    if #self.current_data_list == 0 or #self.current_data_list == 1 then
        return
    end
    local head_index = 1
    for i=1,math.ceil(#self.current_data_list/2) do
        local index = Random.Range(1,  #self.current_data_list)
        local temp_data = self.current_data_list[head_index]
        self.current_data_list[head_index] = self.current_data_list[index]
        self.current_data_list[index] = temp_data
        head_index = head_index + 1
    end
end

function GuildFindWindow:RefreshAllItemsData()
    -- self.vScroll:RefreshData({})
end

function GuildFindWindow:on_select_update_right(item)
    if self.last_selected_item ~= nil then
        self.last_selected_item:on_set_selected_state(false)
    end
    item:on_set_selected_state(true)
    self.last_selected_item = item

    -- self.txt_zongzhi.text = self.last_selected_item.data.Board

    self.txt_zongzhi_1.text = self.last_selected_item.data.Board
    self.txt_zongzhi_2.text = self.last_selected_item.data.Announcement
end

function GuildFindWindow:set_item_has_apply(data)
    if self.find_item_list == nil then
        return
    end
    for i=1,#self.find_item_list do
        local it = self.find_item_list[i]
        if it.my_data.GuildId == data.GuildId and data.PlatForm == it.my_data.PlatForm and data.ZoneId == it.my_data.ZoneId then
            it.my_data.hasApply = true
            self:set_has_apply(it,it.my_data.hasApply)
        end
    end
end
