FriendGroupList = FriendGroupList or BaseClass()


function FriendGroupList:__init(Mainwin)
    self.Mainwin = Mainwin
    self.friendMgr = self.Mainwin.friendMgr
    self.groupMgr = FriendGroupManager.Instance
    self.groupmodel = self.groupMgr.model
    self.model = self.Mainwin.model
    self.layout = self.Mainwin.Layout3
    self.itemSlot_list = {}

    self.ListCon = self.Mainwin.LeftConGroup[3]:Find("Layout")
    self.BaseItem = self.ListCon:GetChild(0).gameObject
    self.updateListener = function()
        self:UpdateGroupList()
    end
    self:InitGroupList()
end

function FriendGroupList:__delete()
    self.groupMgr.OnGroupDataUpdate:Remove(self.updateListener)
    self.groupMgr.OnGroupListUpdate:Remove(self.updateListener)
    if self.item_list ~= nil then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
    end
    self.item_list = nil
    self.setting_data = nil
end

function FriendGroupList:InitGroupList()
    local list = self.groupMgr:GetSortList()
    self.item_list = {}
    self.item_con = self.ListCon
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.single_item_height = self.BaseItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.Mainwin.LeftConGroup[3]:GetComponent(RectTransform).sizeDelta.y
    for i=1,8 do
        local go = self.item_con:GetChild(i-1).gameObject
        local item = GroupItem.New(go, self)
        table.insert(self.item_list, item)
    end
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
    self.vScroll = self.Mainwin.LeftConGroup[3]:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
    self.groupMgr.OnGroupDataUpdate:Add(self.updateListener)
    self.groupMgr.OnGroupListUpdate:Add(self.updateListener)
end

function FriendGroupList:UpdateGroupList()
    local list = self.groupMgr:GetSortList()
    -- self.Mainwin:CheckoutRequest()

    if self.setting_data == nil then
        return
    end
    for k,v in pairs(self.item_list) do
        v.gameObject:SetActive(true)
    end
    self.setting_data.data_list = list
    -- if changetype then
        BaseUtils.refresh_circular_list(self.setting_data)
    -- else
    --     BaseUtils.static_refresh_circular_list(self.setting_data)
    -- end
    self.Mainwin:UpdateCurrFriendList()
end

function FriendGroupList:CreatGroup()
    self.groupmodel:OpenCreatePanel()
end