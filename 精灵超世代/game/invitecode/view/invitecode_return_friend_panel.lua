--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 老友召回
-- @DateTime:    2019-06-12 15:05:04
-- *******************************
InviteCodeReturnFriendPanel = class("InviteCodeReturnFriendPanel", function()
    return ccui.Widget:create()
end)
local controller = InviteCodeController:getInstance()
local model = controller:getModel()
local string_format = string.format
function InviteCodeReturnFriendPanel:ctor()
    self.is_init = true
    self:layoutUI()
    self:registerEvents()
end
function InviteCodeReturnFriendPanel:layoutUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("invitecode/invitecode_my_panel"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(720,640))

    local main_container = self.root_wnd:getChildByName("main_container")

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = InviteCodeReturnFriendItem,      -- 单元类
        start_x = 16,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                    -- y方向的间隔
        item_width = 690,               -- 单元的尺寸width
        item_height = 147,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    model:setFriendReturnData()
    self:getTeskData()
end
function InviteCodeReturnFriendPanel:registerEvents()
    if not self.return_friend_event then
        self.return_friend_event = GlobalEvent:getInstance():Bind(InviteCodeEvent.Return_InviteCode_Event,function()
            self:getTeskData()
        end)
    end
end
--读取任务
function InviteCodeReturnFriendPanel:getTeskData()
    local list = model:getFriendReturnData()
    if list then
        for i,v in pairs(list) do
            v.status = 0
            v.value = 0
            local data = model:getReturnReawrdList(v.id)
            if data then
                if data.num >= data.had then
                    if data.num == data.had and data.num < v.num then
                        v.status = 0
                        if data.num == data.had then
                            v.status = 4
                        end
                    elseif data.num == data.had and data.num == v.num then
                        v.status = 2
                    else
                        v.status = 1
                    end
                end
                v.value = data.num
            end
        end
        model:setSortItem(list)
        if self.is_init == true then
            self.is_init = false
            self.item_scrollview:setData(list)
        else
            self.item_scrollview:resetAddPosition(list)
        end
    end
end
function InviteCodeReturnFriendPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function InviteCodeReturnFriendPanel:DeleteMe()    
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    if self.return_friend_event then
        GlobalEvent:getInstance():UnBind(self.return_friend_event)
        self.return_friend_event = nil
    end
    if self.updata_return_friend_event then
        GlobalEvent:getInstance():UnBind(self.updata_return_friend_event)
        self.updata_return_friend_event = nil
    end
end

--**************
--子项
InviteCodeReturnFriendItem = class("InviteCodeReturnFriendItem", function()
    return ccui.Widget:create()
end)

function InviteCodeReturnFriendItem:ctor()
    self:configUI()
    self:register_event()
end

function InviteCodeReturnFriendItem:configUI()
    self.rootWnd = createCSBNote(PathTool.getTargetCSB("invitecode/invitecode_my_item"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.rootWnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(690,147))

    local main_container = self.rootWnd:getChildByName("main_container")
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:setVisible(false)
    self.btn_get:getChildByName("Text_1"):setString(TI18N("领取"))
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:setVisible(false)
    self.btn_goto:getChildByName("Text_1"):setString(TI18N("未达成"))
    self.has_spr = main_container:getChildByName("has_spr")
    self.has_spr:setVisible(false)
    self.tesk_num = main_container:getChildByName("tesk_num")
    self.tesk_num:setString("")
    self.title_name = main_container:getChildByName("title_name")
    self.title_name:setString("")
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_item_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 3,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.70,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.70,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.70,                     -- 缩放
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_item_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end
function InviteCodeReturnFriendItem:setData(data)
    if not data then return end
    self.data = data
   
    self.title_name:setString(data.desc)
    local str = string_format("(%d/%d)",data.value,data.num)
    self.tesk_num:setString(str)
    self.btn_goto:setVisible(data.status == 0)
    self.btn_get:setVisible(data.status == 1)
    self.has_spr:setVisible(data.status == 2 or data.status == 4)

    local list = {}
    for k, v in pairs(data.items) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        table.insert(list, vo)
    end
    if #list > 5 then
        self.item_scrollview:setClickEnabled(true)
    else
        self.item_scrollview:setClickEnabled(false)
    end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end
function InviteCodeReturnFriendItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data and self.data.id then
            controller:sender19812(self.data.id)
        end
    end,true, 1)
    registerButtonEventListener(self.btn_goto, function()
        message(TI18N("您邀请的用户还未达成目标哦~~~"))
    end,true, 1)
end
function InviteCodeReturnFriendItem:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    self:removeAllChildren()
    self:removeFromParent()
end