--**********************
--我的推荐吗
--**********************
InviteCodeMyPanel = class("InviteCodeMyPanel", function()
    return ccui.Widget:create()
end)
local controller = InviteCodeController:getInstance()
local tesk_list = Config.InviteCodeData.data_tesk_list
local string_format = string.format
function InviteCodeMyPanel:ctor()
    self.is_init = true
    self:layoutUI()
    self:registerEvents()
end
function InviteCodeMyPanel:layoutUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("invitecode/invitecode_my_panel"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(720,640))

    local main_container = self.root_wnd:getChildByName("main_container")

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = InviteCodeMyItem,      -- 单元类
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
end
function InviteCodeMyPanel:registerEvents()
    if not self.invite_code_event then
        self.invite_code_event = GlobalEvent:getInstance():Bind(InviteCodeEvent.InviteCode_My_Event,function()
            self:getTeskData()
        end)
    end
end
--读取任务
function InviteCodeMyPanel:getTeskData()
    local list = controller:getModel():getInviteCodeTeskData()
    if self.item_scrollview and next(list) ~= nil then
        if self.is_init == true then
            self.is_init = false
            self.item_scrollview:setData(list)
        else
            self.item_scrollview:resetAddPosition(list)
        end
    end
end
function InviteCodeMyPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function InviteCodeMyPanel:DeleteMe()    
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    if self.invite_code_event then
        GlobalEvent:getInstance():UnBind(self.invite_code_event)
        self.invite_code_event = nil
    end
end

--******************
--我的推荐吗子项
--******************
InviteCodeMyItem = class("InviteCodeMyItem", function()
    return ccui.Widget:create()
end)

function InviteCodeMyItem:ctor()
    self:configUI()
    self:register_event()
end

function InviteCodeMyItem:configUI()
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
function InviteCodeMyItem:setData(data)
    if not data or next(data) == nil then return end
    self.data = data
    if tesk_list[data.id] then
        self.title_name:setString(tesk_list[data.id].desc or "")
    end

    local tesk_data = controller:getModel():getInviteCodeFinishData(data.id)
    if tesk_data and next(tesk_data) then
        self.btn_goto:setVisible(false)
        local num = tesk_data.num or 0
        local str = string_format("(%d/%d)",num,data.num)
        self.tesk_num:setString(str)
        local had = tesk_data.had or 0
        if num > had then
            self.has_spr:setVisible(false)
            self.btn_get:setVisible(true)
        else
            self.has_spr:setVisible(true)
            self.btn_get:setVisible(false)
        end
    else
        self.has_spr:setVisible(false)
        self.btn_goto:setVisible(true)
        local str = string_format("(%d/%d)",0,data.num)
        self.tesk_num:setString(str)
    end
   
    local list = {}
    if tesk_list[data.id] then
        for k, v in pairs(tesk_list[data.id].items) do
            local vo = {}
            vo.bid = v[1]
            vo.quantity = v[2]
            table.insert(list, vo)
        end
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
function InviteCodeMyItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data then
            controller:sender19805(self.data.id)
        end
    end,true, 1)
    registerButtonEventListener(self.btn_goto, function()
        message(TI18N("您邀请的用户还未达成目标哦~~~"))
    end,true, 1)
end
function InviteCodeMyItem:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    self:removeAllChildren()
    self:removeFromParent()
end