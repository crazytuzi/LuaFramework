-- 通用好友选择面板
-- 16-7-27
-- hzf
-- setting:
-- ismulti 是否多选
-- callback 确定回调
-- btnname 按钮显示文字
-- customlist 自定义列表
-- list_type 列表类型 1：在线好友，2：所以好友
-- nofriendtext 没有符合条件的好友时，显示的文字
-- containGroup  是否包含群组列表
-- groupDesc  群组描述（仅在群组item显示，nil 或者 ""时取群组公告）

FriendSelectPanel = FriendSelectPanel or BaseClass(BasePanel)

function FriendSelectPanel:__init(parent, setting)
    self.parent = parent
    self.name = "FriendSelectPanel"
    self.setting = setting

    self.customlist = setting.customlist
    self.ismulti = setting.ismulti ~= nil and setting.ismulti or false
    self.maxnum = setting.maxnum ~= nil and setting.maxnum or 99
    self.callback = setting.callback
    self.btnname = setting.btnname ~= nil and setting.btnname or TI18N("确 定")
    self.list_type = setting.list_type ~= nil and setting.list_type or 1
    self.nofriendtext = setting.nofriendtext ~= nil and setting.nofriendtext or TI18N("当前没有在线好友哟")
    self.containGroup = setting.containGroup ~= nil and setting.containGroup or false
    self.groupDesc = setting.groupDesc ~= nil and setting.groupDesc or ""
    self.localPosition = setting.localPosition ~= nil and setting.localPosition or Vector3(0, 0, 0)
    self.resList = {
        { file = AssetConfig.friendselectpanel, type = AssetType.Main }
        -- ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
        ,{file = AssetConfig.chat_window_res, type = AssetType.Dep}
    }
    self.selectList = { }
    self.OnOpenEvent:AddListener( function() self:OnOpen() end)
    self.OnHideEvent:AddListener( function() self:OnHide() end)
end

function FriendSelectPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FriendSelectPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.friendselectpanel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform.localPosition = self.localPosition

    self.MaskCon = self.transform:Find("Mask")
    self.baseItem = self.transform:Find("Mask/friendItem")
    self.itemHeight = self.baseItem.sizeDelta.y
    self.Con = self.transform:Find("Mask/Con")
    self.ConHeight = self.Con.sizeDelta.y
    self.baseItem.gameObject:SetActive(false)

    self.I18NnoFriendText = self.transform:Find("Mask/I18NnoFriendText").gameObject

    local maxnum = math.ceil(self.ConHeight / self.itemHeight) + 3
    self.ItemList = { }
    for i = 1, maxnum do
        local go = GameObject.Instantiate(self.baseItem.gameObject)
        go.transform:SetParent(self.Con)
        go.transform.localScale = Vector3.one
        go.transform.localPosition = Vector3(5, 50, 0)
        -- go.transform.anchoredPosition = Vector2(5, 50)
        self.ItemList[i] = FriendSelectItem.New(go, self)
        go:SetActive(true)
    end

    self.setting_data = {
        item_list = self.ItemList-- 放了 item类对象的列表
        ,
        data_list = { }-- 数据列表
        ,
        item_con = self.Con-- item列表的父容器
        ,
        single_item_height = self.itemHeight-- 一条item的高度
        ,
        item_con_last_y = self.Con.anchoredPosition.y-- 父容器改变时上一次的y坐标
        ,
        scroll_con_height = self.MaskCon.sizeDelta.y-- 显示区域的高度
        ,
        item_con_height = 0-- item列表的父容器高度
        ,
        scroll_change_count = 0-- 父容器滚动累计改变值
        ,
        data_head_index = 0-- 数据头指针
        ,
        data_tail_index = 0-- 数据尾指针
        ,
        item_head_index = 0-- item列表头指针
        ,
        item_tail_index = 0-- item列表尾指针
    }
    self.vScroll = self.MaskCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener( function()
        BaseUtils.on_value_change(self.setting_data)
    end )
    self.setting_data.data_list = self:GetList()
    BaseUtils.refresh_circular_list(self.setting_data)

    self.OKbtn = self.transform:Find("Sendbtn"):GetComponent(Button)
    self.btnText = self.transform:Find("Sendbtn/Text"):GetComponent(Text)
    self.btnText.text = self.btnname
    self.OKbtn.onClick:AddListener( function()
        if #self.selectList < 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择好友"))
            return
        end
        local temp = { }
        for k, v in pairs(self.selectList) do
            table.insert(temp, v.data)
        end
        if self.callback ~= nil then
            self.callback(temp)
        end
        self:Hiden()
    end )

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener( function()
        self:Hiden()
    end )
end

function FriendSelectPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FriendSelectPanel:OnOpen()
    self:Refresh()
    self:RemoveListeners()
end

function FriendSelectPanel:OnHide()
    self:Refresh()
    self:RemoveListeners()
end

function FriendSelectPanel:RemoveListeners()
end

function FriendSelectPanel:SetPlayerItem(item, data)
    local its = item.transform
    its:Find("Slot/icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes .. "_" .. data.sex)
    its:Find("name"):GetComponent(Text).text = data.name

    its:Find("male").gameObject:SetActive(data.sex == 1)
    its:Find("classes"):GetComponent(Text).text = KvData.classes_name[data.classes]
    its:Find("classes").gameObject:SetActive(true)
    local glp = its:Find("name"):GetComponent(Text).gameObject.transform.localPosition
    its:Find("name"):GetComponent(Text).gameObject.transform.localPosition = Vector3(150, glp.y, 0)
    if data.isGroup then
        its:Find("male").gameObject:SetActive(false)
        its:Find("Female").gameObject:SetActive(false)
        its:Find("classes").gameObject:SetActive(false)
        its:Find("I18Ntext"):GetComponent(Text).text = data.content
        its:Find("name"):GetComponent(Text).gameObject.transform.localPosition = Vector3(125, glp.y, 0)
    end
    its:GetComponent(Button).onClick:RemoveAllListeners()
    its:GetComponent(Button).onClick:AddListener( function() self:OnClickItem(item, data) end)
    its:Find("select").gameObject:SetActive(self:IsSelect(data))
    -- its:Find("Cross").gameObject:SetActive(not BaseUtils.IsTheSamePlatform(data.platform, data.zone_id))
end

function FriendSelectPanel:OnClickItem(item, data)
    local selectgo = item.transform:Find("select").gameObject
    if self.ismulti then
        if selectgo.activeSelf then
            selectgo:SetActive(false)
            local kk = 0
            for k, v in pairs(self.selectList) do
                if data.name == v.data.name then
                    kk = k
                    break
                end
            end
            table.remove(self.selectList, kk)
        else
            if #self.selectList >= self.maxnum then
                local old = self.selectList[1]
                old.item.transform:Find("select").gameObject:SetActive(false)
                table.remove(self.selectList, 1)
            end
            selectgo:SetActive(true)
            table.insert(self.selectList, { item = item, data = data })
        end
    else
        if selectgo.activeSelf then
            return
        else
            if self.selectList[1] ~= nil then
                self.selectList[1].item.transform:Find("select").gameObject:SetActive(false)
            else
                self.selectList[1] = { }
            end
            self.selectList[1].item = item
            self.selectList[1].data = data
            selectgo:SetActive(true)
        end
    end
end

function FriendSelectPanel:IsSelect(data)
    for k, v in pairs(self.selectList) do
        if data.name == v.data.name then
            return true
        end
    end
    return false
end

function FriendSelectPanel:Refresh()
    self.selectList = { }
    local list = self:GetList()
    self.I18NnoFriendText:SetActive(#list < 1)
    self.I18NnoFriendText:GetComponent(Text).text = self.nofriendtext
    self.setting_data.data_list = list

    BaseUtils.static_refresh_circular_list(self.setting_data)
end

function FriendSelectPanel:GetList()
    if self.customlist ~= nil then
        return self.customlist
    end
    local tab = { }
    local recTab = { }
    if self.list_type == 1 then
        tab = FriendManager.Instance:GetOnlineList()
    elseif self.list_type == 2 then
        tab = FriendManager.Instance:GetSortFriendList()
    elseif self.list_type == 3 then
        tab = FriendManager.Instance:GetCrossOnlineList()
    end
    if self.containGroup then
        local tab2 = FriendGroupManager.Instance:GetSortList()
        for k, v in pairs(tab2) do
            if v.group_rid > 0 then
                local v2 = { }
                local gdata = FriendGroupManager.Instance:GetGroupData(v.group_rid, v.group_platform, v.group_zone_id)
                local onLineStr = ""
                if gdata ~= nil then
                    local onlinenum = 0
                    for i, v in ipairs(gdata.members) do
                        if v.online == 1 then
                            onlinenum = onlinenum + 1
                        end
                    end
                    onLineStr = string.format("(%s/%s)", onlinenum, #gdata.members)
                end
                v2.platform = v.group_platform
                v2.classes = v.owner_classes
                v2.content = v.group_content
                if self.groupDesc ~= "" then
                    v2.content = self.groupDesc
                end
                v2.zone_id = v.group_zone_id
                v2.sex = v.owner_sex
                v2.id = v.group_rid
                v2.name = v.group_name .. onLineStr
                v2.isGroup = true
                table.insert(recTab, v2)
            end
        end
    end
    for k, v in pairs(tab) do
        v.isGroup = false
        table.insert(recTab, v)
    end
    return recTab
end