-- ----------------------------------------------------------
-- UI - 拜访家园窗口
-- ljh 20160718
-- ----------------------------------------------------------
VisitHomeWindow = VisitHomeWindow or BaseClass(BaseWindow)

function VisitHomeWindow:__init(model)
    self.model = model
    self.name = "VisitHomeWindow"
    self.windowId = WindowConfig.WinID.visithomewindow

    self.resList = {
        {file = AssetConfig.visithomewindow, type = AssetType.Main}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.tabGroupObj = nil
    self.tabGroup = nil

    self.index = 1
    ------------------------------------------------
    self.container_item_list = {}

    self.container_setting_data = {}

    ------------------------------------------------
    self._update = function(type) self:update(type) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function VisitHomeWindow:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function VisitHomeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.visithomewindow))
    self.gameObject.name = "VisitHomeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end)

    self.panel = self.mainTransform:Find("Panel").gameObject
    self.container = self.panel.transform:FindChild("Panel/Container")
    self.cloner = self.container.transform:FindChild("1").gameObject
    self.container_vScroll =  self.panel.transform:FindChild("Panel"):GetComponent(ScrollRect)
    self.container_vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.container_setting_data)
    end)

    for i=1, 10 do
        local go = self.container.transform:FindChild(tostring(i)).gameObject
        local item = VisitHomeMemberItem.New(go, self)
        table.insert(self.container_item_list, item)
    end

    self.container_single_item_height = self.cloner.transform:GetComponent(RectTransform).sizeDelta.y
    self.container_scroll_con_height = self.panel.transform:FindChild("Panel"):GetComponent(RectTransform).sizeDelta.y
    self.container_item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y

    self.container_setting_data = {
       item_list = self.container_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.container_single_item_height --一条item的高度
       ,item_con_last_y = self.container_item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.container_scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    ----------------------------

    self:OnShow()
end

function VisitHomeWindow:OnClickClose()
    self:OnHide()
    WindowManager.Instance:CloseWindow(self)
end

function VisitHomeWindow:OnShow()
    EventMgr.Instance:AddListener(event_name.home_visit_info_update, self._update)
    local currtime = Time.time
    -- if self.model.updateVisitTime == 0 or currtime - self.model.updateVisitTime > 1800 then
    --     self.model.updateVisitTime = currtime
        HomeManager.Instance:Send11223(1)
        HomeManager.Instance:Send11223(2)
    -- else
    --     self:refresh_list()
    -- end
end

function VisitHomeWindow:OnHide()
    EventMgr.Instance:RemoveListener(event_name.home_visit_info_update, self._update)
end

function VisitHomeWindow:ChangeTab(index)
    if self.index == index then return end
    self.index = index

    self:refresh_list()
end

function VisitHomeWindow:update(type)
    if self.index == type then
        self:refresh_list()
    end
end

function VisitHomeWindow:refresh_list()
    local datalist = {}
    if self.index == 1 then
        -- local list = self.model.home_friend_list
        -- for _, home_data in ipairs(list) do
        --     local uid = BaseUtils.Key(home_data.mid, home_data.mplatform, home_data.mzone_id)
        --     local friend_data = FriendManager.Instance.friend_List[uid]
        --     if friend_data ~= nil then
        --         local data = BaseUtils.copytab(friend_data)
        --         data.type = "friend"
        --         data.home_data = home_data
        --         table.insert(datalist, data)
        --     end
        -- end
        for key, friend_data in pairs(FriendManager.Instance.friend_List) do
            local data = BaseUtils.copytab(friend_data)
            data.type = "friend"
            table.insert(datalist, data)
            for _, home_data in ipairs(self.model.home_friend_list) do
                local uid = BaseUtils.Key(home_data.mid, home_data.mplatform, home_data.mzone_id)
                if uid == key then
                    data.home_data = home_data
                else
                    uid = BaseUtils.Key(home_data.lid, home_data.lplatform, home_data.lzone_id)
                    if uid == key then
                        data.home_data = home_data
                    end
                end
            end
        end
        local function sortfun(a,b)
            return a.home_data ~= nil and b.home_data == nil
        end
        table.sort(datalist, sortfun)
    elseif self.index == 2 then
        if GuildManager.Instance.model.guild_member_list ~= nil then
            local roleData = RoleManager.Instance.RoleData 
            local role_uid = BaseUtils.get_unique_roleid(roleData.id, roleData.zone_id, roleData.platform)
            local list = self.model.home_guild_list
            for __, guild_data in ipairs(GuildManager.Instance.model.guild_member_list) do
                for _, home_data in ipairs(list) do
                    local uid = BaseUtils.get_unique_roleid(home_data.mid, home_data.mzone_id, home_data.mplatform)
                    local love_uid = BaseUtils.get_unique_roleid(home_data.lid, home_data.lzone_id, home_data.lplatform)
                    if guild_data.Unique == uid or guild_data.Unique == love_uid then
                        local data = BaseUtils.copytab(guild_data)
                        data.type = "guild"
                        data.home_data = home_data
                        table.insert(datalist, data)
                        if role_uid == uid or role_uid == love_uid then
                            data.home_data.isSelf = true 
                        end
                        break
                    end
                end
            end
        end
    end

    self.container_setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.container_setting_data)
end

function VisitHomeWindow:OnClickOkButton()
	HomeManager.Instance:Send11201()
    self:OnClickClose()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gethome)
end