GuildMemManageWindow  =  GuildMemManageWindow or BaseClass(BaseWindow)

function GuildMemManageWindow:__init(model)
    self.name  =  "GuildMemManageWindow"
    self.model  =  model
    -- 缓存
    -- self.cacheMode = CacheMode.Visible

    self.resList  =  {
        {file  =  AssetConfig.guild_mem_manage_win, type  =  AssetType.Main}
    }

    self.windowId = WindowConfig.WinID.guild_mem_manage_win


    self.is_open = false
    self.list_has_init = false

    self.max_word_num = 100

    self.item_list = {}
    self.selected_list = {}
    self.selected_num = 0

    self.OnOpenEvent:Add(function() self:OnShow() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)

    return self
end

function GuildMemManageWindow:OnShow()
    self:update_mem_list()
end

function GuildMemManageWindow:__delete()

    for i=1,#self.item_list do
        local item = self.item_list[i]
        if item ~= nil then
            item:Release()
        end
    end

    self.is_open = false
    self.list_has_init = false

    self.item_list = nil
    self.selected_list = nil
    GameObject.DestroyImmediate(self.gameObject)

    self.gameObject = nil
    self:AssetClearAll()
end


function GuildMemManageWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_mem_manage_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "GuildMemManageWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    local close_btn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function()
        self.model:CloseGuildMemManageUI()
    end)


    self.ConTop = self.MainCon:FindChild("ConTop")
    self.BtnMember = self.ConTop:FindChild("BtnInfo"):GetComponent(Button)
    self.BtnMail = self.ConTop:FindChild("BtnMail"):GetComponent(Button)
    self.tab_un_select = self.BtnMail.image.sprite
    self.tab_select = self.BtnMember.image.sprite
    self.tab_text_color1 = self.BtnMember.transform:FindChild("Text"):GetComponent(Text).color
    self.tab_text_color2 = self.BtnMail.transform:FindChild("Text"):GetComponent(Text).color

    self.BtnMember.onClick:AddListener( function() self:on_click_info_btn(1) end)
    self.BtnMail.onClick:AddListener( function() self:on_click_info_btn(2) end)

    self.ConMember = self.MainCon:FindChild("ConMember")
    self.MemberList = self.ConMember:FindChild("MemberList")
    self.MaskLayer = self.MemberList:FindChild("MaskLayer")
    self.ScrollLayer = self.MaskLayer:FindChild("ScrollLayer")
    self.item_con = self.ScrollLayer:FindChild("Container")
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.ScrollLayer:GetComponent(ScrollRect)

    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        local go = self.item_con:FindChild(tostring(i)).gameObject
        local item = GuildMemManageItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.ScrollLayer:GetComponent(RectTransform).sizeDelta.y


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


    self.BtnSet = self.ConMember:FindChild("BtnSet"):GetComponent(Button)
    self.BtnFire = self.ConMember:FindChild("BtnFire"):GetComponent(Button)
    self.BtnGuildList = self.ConMember:FindChild("BtnGuildList"):GetComponent(Button)
    self.BtnSetFreshMan = self.ConMember:FindChild("BtnSetFreshMan"):GetComponent(Button)

    self.grey_sprite = self.BtnSet.image.sprite
    self.blue_sprite = self.BtnFire.image.sprite

    self.BtnSet.image.sprite = self.blue_sprite
    self.ConMember:FindChild("BtnSet"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton1

    self.title_con = self.MemberList:FindChild("ImgTitle")
    self.title_lev = self.title_con:FindChild("TxtLev"):GetComponent(Button)
    self.title_gx = self.title_con:FindChild("TxtGx"):GetComponent(Button)
    self.title_pos = self.title_con:FindChild("TxtPosition"):GetComponent(Button)
    self.title_cup = self.title_con:FindChild("ImgCup"):GetComponent(Button)
    self.title_lastlogin = self.title_con:FindChild("TxtLastLogin"):GetComponent(Button)
    self.title_tips_huoyue = self.title_con:FindChild("BtnHuoyue"):GetComponent(Button)

    self.title_lev.onClick:AddListener( function() self:on_mem_title_up_callback(1)  end)
    self.title_gx.onClick:AddListener( function() self:on_mem_title_up_callback(3)  end)
    self.title_pos.onClick:AddListener( function() self:on_mem_title_up_callback(2)  end)
    self.title_cup.onClick:AddListener( function() self:on_mem_title_up_callback(4)  end)
    self.title_lastlogin.onClick:AddListener( function() self:on_mem_title_up_callback(5)  end)
    self.title_tips_huoyue.onClick:AddListener( function()
        local tips = {}
        table.insert(tips, TI18N("<color='#ffff00'>活跃</color>反映玩家最近5天的活跃度"))
        table.insert(tips, TI18N("<color='#ffff00'>能力</color>反映玩家战力和竞技场实力"))
        TipsManager.Instance:ShowText({gameObject = self.title_tips_huoyue.gameObject, itemData = tips})
    end)

    --邮件逻辑
    self.ConMail = self.MainCon:FindChild("ConMail")
    self.MailContent = self.ConMail:FindChild("MailContent")
    self.MailInput = self.MailContent:FindChild("MailInput"):GetComponent(InputField)
    self.MailInput.textComponent = self.MailInput.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.MailInput.placeholder = self.MailInput.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.MailInput.characterLimit  =  self.max_word_num
    self.MailTxtNum = self.ConMail:FindChild("TxtNum"):GetComponent(Text)
    self.BtnSend = self.ConMail:FindChild("BtnSend"):GetComponent(Button)

    self.MailTxtNum.text = string.format("%s<color='%s'>%s</color>%s", TI18N("当前还可输入："), ColorHelper.color[5], self.max_word_num, TI18N("字"))

    self.MailInput.onEndEdit:AddListener(function(str)
        local word_list = StringHelper.ConvertStringTable(str)
        local word_num = #word_list
        local left_num = self.max_word_num - word_num - 1
        if str ~= "" and #word_list == 0 then
            left_num = self.max_word_num - 1
        elseif str == "" then
            left_num = self.max_word_num
        end
        left_num = left_num < 0 and 0 or left_num
        if left_num == 0 then
            self.MailTxtNum.text = string.format("%s<color='%s'>%s</color>%s", TI18N("当前还可输入："), ColorHelper.colorObject[4], left_num, TI18N("字"))
        else
            self.MailTxtNum.text = string.format("%s<color='%s'>%s</color>%s", TI18N("当前还可输入："), ColorHelper.colorObject[4], left_num, TI18N("字"))
        end
    end)




    self.BtnSet.onClick:AddListener(function()
        self:on_open_set_position_win()
    end)

    self.BtnFire.onClick:AddListener(function()
        self:on_fire_mem()
    end)

    self.BtnSend.onClick:AddListener(function()
        self:on_send_mail()
    end)

    self.BtnGuildList.onClick:AddListener(function()
        self.model:InitFindUI()
    end)

    self.BtnSetFreshMan.onClick:AddListener(function()
        local myPost = self.model:get_my_guild_post()
        if myPost == self.model.member_positions.leader or myPost == self.model.member_positions.vice_leader then --会长和副会长才有权限设置
            self.model:InitSetFreshManLevUI()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("会长与副会长才可进行设置哦"))
        end
    end)

    self:update_mem_list()
end

--切换tab逻辑
function GuildMemManageWindow:on_click_info_btn(index)
    if index == 1 then
        self:switch_tab(self.ConMember, self.BtnMember)
    elseif index == 2 then
        self:switch_tab(self.ConMail, self.BtnMail)
    end
end

function GuildMemManageWindow:switch_tab(selectTab, selectBtn)
    if self.has_init == false then
        return
    end
    self.BtnMember.image.sprite = self.tab_un_select
    self.BtnMail.image.sprite = self.tab_un_select
    self.BtnMail.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color2
    self.BtnMember.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color2
    selectBtn.image.sprite = self.tab_select
    selectBtn.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color1
    self.ConMail.gameObject:SetActive(false)
    self.ConMember.gameObject:SetActive(false)
    selectTab.gameObject:SetActive(true)
end


--------------------------------------------更新成员列表
function GuildMemManageWindow:update_mem_list()
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

    table.sort(self.model.guild_member_list, member_list_post_sort)
    table.sort(self.model.guild_member_list, member_list_online_sort)

    local temp_first_data = self.model.update_mem_mange_data
    if temp_first_data == nil then
        temp_first_data = {Rid = RoleManager.Instance.RoleData.id, PlatForm = RoleManager.Instance.RoleData.platform, ZoneId = RoleManager.Instance.RoleData.zone_id}
    end

    local index = 2
    local first_data = nil
    self.current_mem_data_list = {}
    --把自己放到第一位
    for i=1,#self.model.guild_member_list do
        local d = self.model.guild_member_list[i]
        if d.deleted ~= true then
            if d.Rid == temp_first_data.Rid  and d.PlatForm == temp_first_data.PlatForm  and  d.ZoneId == temp_first_data.ZoneId then
                first_data = d
                break
            end
        end
    end

    if first_data ~= nil then
        index = 2
        self.current_mem_data_list[1] = first_data
    else
        index = 1
    end

    for i=1,#self.model.guild_member_list do
        local d = self.model.guild_member_list[i]
        if d.deleted ~= true then
            if d.Rid ~= temp_first_data.Rid  or d.PlatForm ~= temp_first_data.PlatForm  or  d.ZoneId ~= temp_first_data.ZoneId then
                self.current_mem_data_list[index] = d
                index = index + 1
            end
        end
    end

    self.setting_data.data_list = self.current_mem_data_list
    BaseUtils.refresh_circular_list(self.setting_data)
end

--选中某一条
function GuildMemManageWindow:on_click_mem_item(item)
    if item.selected_state then
        self.selected_mem_data = item.data
        self.selected_list[item.item_index] = item.data
    else
        self.selected_mem_data = nil
        self.selected_list[item.item_index] = nil
        if self.model.update_mem_mange_data ~= nil then
            if item.data.Rid == self.model.update_mem_mange_data.Rid and item.data.PlatForm == self.model.update_mem_mange_data.PlatForm and item.data.ZoneId == self.model.update_mem_mange_data.ZoneId then
                self.model.update_mem_mange_data = nil
            end
        end
    end

    local num = 0
    for k, v in pairs(self.selected_list) do
        num = num + 1
    end
    self.selected_num = num

    if self.selected_num > 1 then
        self.BtnSet.image.sprite = self.grey_sprite
        self.ConMember:FindChild("BtnSet"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4

    else
        self.BtnSet.image.sprite = self.blue_sprite
        self.ConMember:FindChild("BtnSet"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton1
    end
end


--设置职位
function GuildMemManageWindow:on_open_set_position_win()
    if self.selected_num == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("先选中需要设置职位的成员"))
        return
    end

    if self.selected_num > 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("只能对选中一个成员进行职位设置"))
        return
    end

    if self.selected_mem_data == nil then
        for k, v in pairs(self.selected_list) do
            if v ~= nil then
                self.selected_mem_data = v
            end
        end
    end

    local myPost = self.model:get_my_guild_post()
    if myPost == self.model.member_positions.leader or myPost == self.model.member_positions.vice_leader then --会长和副会长才有权限设置职位
        if self.selected_mem_data == nil then
            NoticeManager.Instance:FloatTipsByString(self.model.guild_lang.GUILD_INFO_NOTIFY_WORD_1)
            return
        elseif RoleManager.Instance.RoleData.id == self.selected_mem_data.Rid and RoleManager.Instance.RoleData.zone_id == self.selected_mem_data.ZoneId and RoleManager.Instance.RoleData.platform == self.selected_mem_data.PlatForm then
            NoticeManager.Instance:FloatTipsByString(self.model.guild_lang.GUILD_INFO_NOTIFY_WORD_2)
            return
        elseif self.selected_mem_data.Post >= myPost then
            NoticeManager.Instance:FloatTipsByString(self.model.guild_lang.GUILD_INFO_NOTIFY_WORD_3)
            return
        end
        self.model.select_mem_oper_data = {}
        self.model.select_mem_oper_data.guildMemData = self.selected_mem_data
        self.model:InitPositionUI()
    else
        NoticeManager.Instance:FloatTipsByString(self.model.guild_lang.GUILD_INFO_NOTIFY_WORD_4)
    end
end

--开除成员
function GuildMemManageWindow:on_fire_mem()
    if self.selected_num == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("先选中需要开除的成员"))
        return
    end

    local myPost = self.model:get_my_guild_post()
    local huoli_cost = 0
    if myPost >=GuildManager.Instance.model.member_positions.elder then --出现确认框
        for k, v in pairs(self.selected_list) do
            if v ~= nil then
                local data = v
                if data.Rid ~= RoleManager.Instance.RoleData.id or data.PlatForm ~= RoleManager.Instance.RoleData.platform or data.ZoneId ~=    RoleManager.Instance.RoleData.zone_id then
                    if data.Post > GuildManager.Instance.model.member_positions.stduy then
                        local time_gap = BaseUtils.BASE_TIME - data.LastLogin
                        if time_gap <= 86400 then
                            huoli_cost = huoli_cost + 5
                        end
                    end
                end
            end
        end
    else
        local tips = {}
        table.insert(tips, self.model.guild_lang.GUILD_INFO_OUT_NOTIFY_4)
        TipsManager.Instance:ShowText({gameObject = self.BtnFire.gameObject, itemData = tips})
        return
    end

    local msg_str = ""
    if huoli_cost == 0 then
        msg_str = TI18N("是否将选中的人踢出公会")
    else
        msg_str = string.format("%s<color='#4dd52b'>%s</color>%s", TI18N("是否消耗"), huoli_cost, TI18N("{assets_2,90006}踢除已选中的成员"))
    end

    local data = {}
    data.huoli_cost = 0
    data.selected_list = self.selected_list
    data.msg_str = msg_str
    data.sureCallback = function()
        for k, v in pairs(self.selected_list) do
            if v ~= nil then
                local data = v
                if data.Rid ~= RoleManager.Instance.RoleData.id or data.PlatForm ~= RoleManager.Instance.RoleData.platform or data.ZoneId ~= RoleManager.Instance.RoleData.zone_id then
                    GuildManager.Instance:request11109(data.Rid, data.PlatForm, data.ZoneId)
                end
                for i=1, #self.item_list do
                    local item = self.item_list[i]
                    if item ~= nil and item.data ~= nil then
                        if data.Rid == item.data.Rid or data.PlatForm == item.data.PlatForm or data.ZoneId == item.data.ZoneId then
                            item:reset_selected()
                            break
                        end
                    end
                end
            end
        end
        self.selected_list = {}
        self.selected_num = 0
    end
    self.model:InitMemDeleteUI(data)
end

----------------------------------------------------列表排序逻辑
--点击成员列表标题，进行列表排序
function GuildMemManageWindow:on_mem_title_up_callback(index)
    --公会成员列表排序逻辑

    if index == 1 then --按钮等级进行排序
        if self.sortType == 1 then
            table.sort(self.model.guild_member_list, self.model.lev_sort2)
            self.sortType = 11
        else
            table.sort(self.model.guild_member_list, self.model.lev_sort)
            self.sortType = 1
        end
    elseif index == 2 then--按职位进行排序
        if self.sortType == 2 then
            table.sort(self.model.guild_member_list, self.model.post_sort2)
            self.sortType = 21
        else
            table.sort(self.model.guild_member_list, self.model.post_sort)
            self.sortType = 2
        end
    elseif index == 3 then --按贡献进行排序
        if self.sortType == 3 then
            table.sort(self.model.guild_member_list, self.model.gx_sort2)
            self.sortType = 31
        else
            table.sort(self.model.guild_member_list, self.model.gx_sort)
            self.sortType = 3
        end
    elseif index == 4 then
        if self.sortType == 4 then
            table.sort(self.model.guild_member_list, self.model.cup_sort2)
            self.sortType = 41
        else
            table.sort(self.model.guild_member_list, self.model.cup_sort)
            self.sortType = 4
        end
    elseif index == 5 then
        if self.sortType == 5 then
            -- table.sort(self.model.guild_member_list, self.model.last_login_sort2)
            table.sort(self.model.guild_member_list, function(a, b)
                    if a.Status ~= b.Status then
                        return a.Status < b.Status
                    else
                        return a.LastLogin < b.LastLogin
                    end
                end
            )
            self.sortType = 51
        else
            -- table.sort(self.model.guild_member_list, self.model.last_login_sort)
            table.sort(self.model.guild_member_list, function(a, b)
                    if a.Status ~= b.Status then
                        return a.Status > b.Status
                    else
                        return a.LastLogin > b.LastLogin
                    end
                end
            )
            self.sortType = 5
        end
    end


    local temp_first_data = self.model.update_mem_mange_data
    if temp_first_data == nil then
        temp_first_data = {Rid = RoleManager.Instance.RoleData.id, PlatForm = RoleManager.Instance.RoleData.platform, ZoneId = RoleManager.Instance.RoleData.zone_id}
    end

    local index = 2
    local first_data = nil
    self.current_mem_data_list = {}
    --把自己放到第一位
    for i=1,#self.model.guild_member_list do
        local d = self.model.guild_member_list[i]
        if d.deleted ~= true then
            if d.Rid == temp_first_data.Rid  and d.PlatForm == temp_first_data.PlatForm  and  d.ZoneId == temp_first_data.ZoneId then
                first_data = d
                break
            end
        end
    end

    if first_data ~= nil then
        index = 2
        self.current_mem_data_list[1] = first_data
    else
        index = 1
    end

    for i=1,#self.model.guild_member_list do
        local d = self.model.guild_member_list[i]
        if d.deleted ~= true then
            if d.Rid ~= temp_first_data.Rid  or d.PlatForm ~= temp_first_data.PlatForm  or  d.ZoneId ~= temp_first_data.ZoneId then
                self.current_mem_data_list[index] = d
                index = index + 1
            end
        end
    end

    for k, v in pairs(self.selected_list) do
        self.selected_list[k] = nil
    end

    self.setting_data.data_list = self.current_mem_data_list
    BaseUtils.refresh_circular_list(self.setting_data)
end


----------------------------------------------------发送邮件
function GuildMemManageWindow:on_send_mail()

    if self.MailInput.text == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先输入邮件内容再发送"))
        return
    end
    GuildManager.Instance:request11168(TI18N("公会邮件"), self.MailInput.text)
    self.MailInput.text = ""
end