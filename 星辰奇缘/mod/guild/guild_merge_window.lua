GuildMergeWindow = GuildMergeWindow or BaseClass(BaseWindow)

function GuildMergeWindow:__init(model)
    self.name = "GuildMergeWindow"
    self.model = model

    self.windowId = WindowConfig.WinID.guild_merge_win


    self.resList = {
        {file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
        ,{file = AssetConfig.guild_merge_win, type = AssetType.Main}
    }
    self.effect = nil
    self.fps = nil

    self.is_search_state = false

    self.last_selected_item = nil

    self.item_init_num = 10 --初始化滚动区域有10个存在
    self.list_has_init = false
    self.item_list = nil
    return self
end

function GuildMergeWindow:__delete()
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:Release()
        end
    end
    self.item_list = nil
    self.last_selected_item = nil
    self.list_has_init = false
    self.is_open = false
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function GuildMergeWindow:InitPanel()
    if self.gameObject ~= nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_merge_win))
    self.gameObject.name = "GuildMergeWindow"

    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.main_con = self.transform:FindChild("MainCon").gameObject.transform

    local close_btn = self.main_con:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseGuildMergeUI() end)

    self.title_txt = self.transform:FindChild("ImgTitle"):FindChild("Text"):GetComponent(Text)

    self.l_bottom_con= self.main_con:FindChild("BottomCon")
    self.Search_btn=self.l_bottom_con:FindChild("BtnSearch"):GetComponent(Button)
    self.Return_btn=self.l_bottom_con:FindChild("BtnReturn"):GetComponent(Button)
    self.BtnContectLeader=self.l_bottom_con:FindChild("BtnContectLeader"):GetComponent(Button)
    self.BtnMerge=self.l_bottom_con:FindChild("BtnMerge"):GetComponent(Button)
    self.BtnMerge_txt = self.BtnMerge.transform:FindChild("Text"):GetComponent(Text)

    self.l_bottom_input=self.l_bottom_con:FindChild("InputField"):GetComponent(InputField)
    self.l_bottom_input.textComponent = self.l_bottom_input.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.l_bottom_input.placeholder = self.l_bottom_input.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)

    self.l_top_con=self.main_con:FindChild("TopCon").gameObject
    self.UnOpenCon = self.l_top_con.transform:FindChild("UnOpenCon").gameObject
    self.TxtUnOpen = self.UnOpenCon.transform:FindChild("TxtUnOpen"):GetComponent(Text)
    self.mask_con = self.l_top_con.transform:FindChild("ItemCon"):FindChild("MaskCon")
    self.scroll_con = self.mask_con:FindChild("ScrollLayer")
    self.Container = self.scroll_con:FindChild("Container")
    self.item = self.Container:FindChild("Cloner").gameObject
    self.item:SetActive(false)
    self.UnOpenCon:SetActive(false)

    self.Search_btn.onClick:AddListener(function() self:on_click_btn(1)  end)
    self.BtnContectLeader.onClick:AddListener(function() self:on_click_btn(2)  end)
    self.BtnMerge.onClick:AddListener(function() self:on_click_btn(3)  end)
    self.Return_btn.onClick:AddListener(function() self:on_click_btn(4)  end)

    self.is_open = true


    self.grey_img = self.Search_btn.image.sprite
    self.green_img = self.BtnContectLeader.image.sprite
    self.blue_img  = self.BtnMerge.image.sprite


    if self.model.merge_type == 1 then
        self.title_txt.text = TI18N("申请合入")
        self.BtnMerge_txt.text = TI18N("发起申请")
        GuildManager.Instance:request11171()
        self.TxtUnOpen.text = TI18N("当前没有可申请合入的公会")
    else
        self.title_txt.text = TI18N("请求列表")
        self.BtnMerge_txt.text = TI18N("发起合并")
        GuildManager.Instance:request11170()
        self.TxtUnOpen.text = TI18N("当前无公会请求合入本公会")
    end

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end


function GuildMergeWindow:on_click_btn(index)
   if index == 1 then
        --搜索公会
        if self.l_bottom_input.text == "" then
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入要搜索的公会名称"))
            return
        end

        local new_list = {}
        for i=1,#self.current_data_list do
            local d = self.current_data_list[i]
            if string.find(d.Name, self.l_bottom_input.text) ~= nil then
                table.insert(new_list, d)
            end
        end
        if #new_list == 0 then
            NoticeManager.Instance:FloatTipsByString(string.format("%s<color='#df3435'>%s</color>%s", TI18N("不存在包含名字为"), self.l_bottom_input.text, TI18N("的公会")))
            return
        else
            self.Search_btn.gameObject:SetActive(false)
            self.Return_btn.gameObject:SetActive(true)
            self:display_items(new_list)
        end
    elseif index == 2 then
        --联系会长
        if self.last_selected_item == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先选中列表中的公会再使用联系会长"))
            return
        end
        local temp_data = self.last_selected_item.data
        local f_data = {id = temp_data.LeaderRid, platform = temp_data.LeaderPlatform, zone_id = temp_data.LeaderZoneId, sex = temp_data.LeaderSex, classes = temp_data.LeaderClasses, lev = temp_data.LeaderLev, name = temp_data.LeaderName}
        FriendManager.Instance:AddUnknowMan(f_data) --加入到最近联系人
        FriendManager.Instance:TalkToUnknowMan(f_data)
    elseif index == 3 then
        --请求列表
        if self.last_selected_item == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先选中列表中的公会"))
            return
        end
        local data = self.last_selected_item.data
        if self.model.merge_type == 1 then

            local n_data = NoticeConfirmData.New()
            n_data.type = ConfirmData.Style.Normal
            n_data.content = string.format("%s<color='#2fc823'>%s</color>%s", TI18N("对方同意合并后，本公会所有成员将合并到"), data.Name, TI18N("，确认是否要申请合入"))
            n_data.sureLabel = TI18N("确认")
            n_data.cancelLabel = TI18N("取消")
            n_data.sureCallback = function()
                GuildManager.Instance:request11172(data.GuildId, data.PlatForm, data.ZoneId)
            end
            NoticeManager.Instance:ConfirmTips(n_data)
        else
            local n_data = NoticeConfirmData.New()
            n_data.type = ConfirmData.Style.Normal
            n_data.content = string.format("%s<color='#2fc823'>%s</color>%s", TI18N("合并后对方将变为你公会的成员，确认是否要与"), data.Name, TI18N("合并"))
            n_data.sureLabel = TI18N("确认")
            n_data.cancelLabel = TI18N("取消")
            n_data.sureCallback = function()
                GuildManager.Instance:request11173(data.GuildId, data.PlatForm, data.ZoneId)
            end
            NoticeManager.Instance:ConfirmTips(n_data)
        end
    elseif index == 4 then
        --返回
        self.Search_btn.gameObject:SetActive(true)
        self.Return_btn.gameObject:SetActive(false)
        self:display_items(self.model.merge_list)
        self.l_bottom_input.text = TI18N("输入公会名称")
    end
end

function GuildMergeWindow:display_items(list, _type)
    self.l_bottom_input.text = ""
    self.current_data_list = list

    if _type ~= nil then
        if #list == 0 then
            self.UnOpenCon:SetActive(true)
        else
            self.UnOpenCon:SetActive(false)
        end
    end

    if self.item_list == nil then
        self.item_list = {}
    else
        for i=1,#self.item_list do
            local item = self.item_list[i]
            item.gameObject:SetActive(false)
        end
    end

    for i=1,#self.current_data_list do
        local data = self.current_data_list[i]
        local item = self.item_list[i]
        if item == nil then
            item = GuildMergeItem.New(self, self.item, i)
            table.insert(self.item_list, item)
        end
        item:InitPanel(data)
        item.gameObject:SetActive(true)
    end

    local newH = 47*#self.current_data_list
    local rect = self.Container:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(0, newH)
end

function GuildMergeWindow:on_select_item(item)
    if self.last_selected_item ~= nil then
        self.last_selected_item:on_set_selected_state(false)
    end
    self.last_selected_item = item
    self.last_selected_item:on_set_selected_state(true)

end