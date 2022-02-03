-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      订单结算选在单双倍奖励面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildvoyageChooseConfirmWindow = GuildvoyageChooseConfirmWindow or BaseClass(BaseView)

local controller = GuildvoyageController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function GuildvoyageChooseConfirmWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.is_init = false
    self.item_list = {}
    self.res_list = {
    }
    self.layout_name = "guildvoyage/guildvoyage_choose_confirm_window"
end

function GuildvoyageChooseConfirmWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName('win_title'):setString(TI18N("奖励选择确认"))
    container:getChildByName('title_1'):setString(TI18N("单倍奖励"))
    container:getChildByName('title_2'):setString(TI18N("双倍奖励"))
    self.close_btn = container:getChildByName("close_btn")

    self.scroll_view_1 = container:getChildByName("scroll_view_1")
    self.scroll_view_1:setScrollBarEnabled(false)

    self.scroll_view_2 = container:getChildByName("scroll_view_2")
    self.scroll_view_2:setScrollBarEnabled(false)

    self.scroll_size = self.scroll_view_1:getContentSize()

    self.cancel_btn = container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("单倍奖励"))

    self.confirm_btn = container:getChildByName("confirm_btn")
	self.confirm_btn_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(105,31))
	self.confirm_btn:addChild(self.confirm_btn_label)
end

function GuildvoyageChooseConfirmWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then 
            controller:openGuildvoyageChooseConfirmWindow(false)
        end
    end)
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then 
            controller:openGuildvoyageChooseConfirmWindow(false)
        end
    end)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender,event_type)
        if event_type == ccui.TouchEventType.ended then 
            if self.order then
                controller:requestSubmitVoyage(self.order.order_id, 0)
            end
        end
    end)
    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender,event_type)
        if event_type == ccui.TouchEventType.ended then 
            if self.order then
                controller:requestSubmitVoyage(self.order.order_id, 1)
            end
        end
    end)
end

function GuildvoyageChooseConfirmWindow:openRootWnd(order)
    if order == nil then return end
    self.order = order
    self:createRewardsList()
    self:createDoubleRewardsList()

    if order.config then
        local str = string.format("<img src=%s visible=true scale=0.35 />,<div fontcolor=#ffffff fontsize=24 outline=1,#c45a14>%s %s</div>", PathTool.getItemRes(15), order.config.double_cost, TI18N("双倍奖励"))
		self.confirm_btn_label:setString(str)
    end
end

--[[
    @desc:创建基础奖励,包含了固定和概率 
    author:{author}
    time:2018-08-09 20:15:56
    --@list: 
    @return:
]]
function GuildvoyageChooseConfirmWindow:createRewardsList()
    if self.order == nil or self.order.config == nil then return end
    local order = self.order
    local list = {}
    local is_gain = order.is_gain -- 是否有双倍奖励
    for i,v in ipairs(order.config.rewards) do
        table_insert(list, {bid=v[1], num=v[2], is_gain=2})
    end
    for i,v in ipairs(order.config.rand_rewards) do
        table_insert(list, {bid=v[1], num=v[2], is_gain=is_gain})
    end
    if list == nil or next(list) == nil then return end

	local item_num = #list
    local space = 40
	local scale = 0.9
    local start_x = 20
    local _y = 65
    local _x = 0
    local item = nil
    local total_width = item_num * BackPackItem.Width * scale + ( item_num - 1 ) * space
    total_width = math.max(self.scroll_size.width, total_width)
    self.scroll_view_1:setInnerContainerSize(cc.size(total_width, self.scroll_size.height))

    for i, v in ipairs(list) do
        delayRun(self.scroll_view_1, 2*i/display.DEFAULT_FPS, function() 
            if v.bid and v.num then
                item = BackPackItem.new(false, true, false, scale, false, true)
                item:setBaseData(v.bid, v.num)
                _x = start_x + (i - 1) * (BackPackItem.Width * scale + space) + BackPackItem.Width * scale * 0.5
                item:setPosition(_x, _y)
                item:setDefaultTip(true)
                if v.is_gain == 1 then
                    setChildUnEnabled(true,item)
                end
                self.scroll_view_1:addChild(item)
                table_insert(self.item_list, item)
            end
        end)
    end 
end

--[[
    @desc: 创建双倍奖励
    author:{author}
    time:2018-08-09 20:44:02
    @return:
]]
function GuildvoyageChooseConfirmWindow:createDoubleRewardsList()
    if self.order == nil or self.order.config == nil then return end
    local order = self.order
    local list = {}
    local is_gain = order.is_gain -- 是否有双倍奖励
    for i, v in ipairs(order.config.rewards) do
        table_insert(list, {bid = v[1], num = v[2]*2, is_gain = 2})
    end
    for i, v in ipairs(order.config.rand_rewards) do
        table_insert(list, {bid = v[1], num = v[2]*2, is_gain = is_gain})
    end
    if list == nil or next(list) == nil then return end

    local item_num = #list
    local space = 40
    local scale = 0.9
    local start_x = 20
    local _y = 65
    local _x = 0
    local item = nil
    local total_width = item_num * BackPackItem.Width * scale + (item_num - 1) * space
    total_width = math.max(self.scroll_size.width, total_width)
    self.scroll_view_2:setInnerContainerSize(cc.size(total_width, self.scroll_size.height))

    for i, v in ipairs(list) do
        delayRun(
            self.scroll_view_2,
            4 * i / display.DEFAULT_FPS,
            function()
                if v.bid and v.num then
                    item = BackPackItem.new(false, true, false, scale, false, true)
                    item:setBaseData(v.bid, v.num)
                    _x = start_x + (i - 1) * (BackPackItem.Width * scale + space) + BackPackItem.Width * scale * 0.5
                    item:setPosition(_x, _y)
                    item:setDefaultTip(true)
                    if v.is_gain == 1 then
                        setChildUnEnabled(true, item)
                    else
                        item:setDoubleIcon(true)
                    end
                    self.scroll_view_2:addChild(item)
                    table_insert(self.item_list, item)
                end
            end
        )
    end
end

function GuildvoyageChooseConfirmWindow:close_callback()
    doStopAllActions(self.scroll_view_1)
    doStopAllActions(self.scroll_view_2)
    for i, item in ipairs(self.item_list) do
        item:DeleteMe()
    end
    self.item_list = nil
    controller:openGuildvoyageChooseConfirmWindow(false)
end
