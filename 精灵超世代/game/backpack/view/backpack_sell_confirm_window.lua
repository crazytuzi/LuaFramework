----------------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-05-06 11:17:52
-- @Description:	出售装备获得奖励确认
----------------------------------
BackPackSellConfirmWindow = BackPackSellConfirmWindow or BaseClass(BaseView)

local controller = BackpackController:getInstance()
local model = BackpackController:getInstance():getModel()
local string_format = string.format
local table_insert = table.insert

function BackPackSellConfirmWindow:__init()
	self.win_type = WinType.Mini
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "backpack/backpack_sell_confirm_window"

    self.wait_sell_list = {} --待出售列表
end

function BackPackSellConfirmWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
    self.total_width = self.container:getContentSize().width

    self.cancel_btn = self.container:getChildByName("cancel_btn")
    self.confirm_btn = self.container:getChildByName("confirm_btn")

    self.cancel_btn:getChildByName("label"):setString(TI18N("取消"))

    self.confirm_label = self.confirm_btn:getChildByName("label")
    self.win_title = self.container:getChildByName("win_title")

    self.sell_title = self.container:getChildByName("sell_title")
    local sell_desc = self.container:getChildByName("sell_desc")
    sell_desc:setString("")

    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)

    self.rich_desc = createRichLabel(24, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0.5, 0.5), cc.p(0,0),nil,nil,1000)
    sell_desc:addChild(self.rich_desc)
    self.rich_desc:setVisible(false)
end

function BackPackSellConfirmWindow:register_event()
	registerButtonEventListener(self.cancel_btn, function()
        controller:openSellConfirmWindow(false)
    end, true, 2)

    registerButtonEventListener(self.confirm_btn, function()
    	if self.bag_code == BackPackConst.Bag_Code.EQUIPS then
    		self:onComfirm()
    	end
    end, true, 1)

    self:addGlobalEvent(BackpackEvent.BACKPACK_SELL_CONFIRM, function(data)
        if not data then return end
        self:setData(data.items)
    end)
end

-- 出售获得价值物品列表
function BackPackSellConfirmWindow:openRootWnd(callback, bag_code, is_show_tips, item_count)
	self.callback = callback
    self.bag_code = bag_code
    self.is_show_tips = is_show_tips

    local title, confirm_lbl
	if bag_code == BackPackConst.Bag_Code.EQUIPS then
        title = TI18N("装备出售")
        confirm_lbl = TI18N("出售")
    end
    self.confirm_lbl = confirm_lbl
    self.win_title:setString(title)
    self.sell_title:setString(string_format(TI18N("本次%s包含%d件装备,可获得如下奖励："), confirm_lbl, item_count))
    self.rich_desc:setString(string_format(TI18N("(注意：本次出售包含<div fontcolor=#d95014>橙色</div>或<div fontcolor=#d95014>红色</div>装备！)")))

    if not is_show_tips then
    	self.confirm_label:setString(confirm_lbl)
    else
    	self.rich_desc:setVisible(true)
    	self.timer = 3
    	setChildUnEnabled(true, self.confirm_btn)
    	self.confirm_btn:setTouchEnabled(false)
    	self.confirm_label:setString(TI18N(string_format("%s(%d)", confirm_lbl, self.timer)))
    	self.confirm_label:enableOutline(Config.ColorData.data_color4[84],2)
    	self:openTimer(true)
    end
end

--打开特殊品质售出倒计时
function BackPackSellConfirmWindow:openTimer(status)
	if status == true then
		if self.show_tips_ticket == nil then
            self.show_tips_ticket = GlobalTimeTicket:getInstance():add(function()
                self.timer = self.timer - 1
                if self.timer > 0 then
                	self.confirm_label:setString(string.format("%s(%s)", self.confirm_lbl, self.timer))
                else
                	setChildUnEnabled(false, self.confirm_btn)
		            self.confirm_btn:setTouchEnabled(true)
		            if self.confirm_label then
		                self.confirm_label:enableOutline(Config.ColorData.data_color4[264],2)
		            end 
		            self.confirm_label:setString(string.format("%s", self.confirm_lbl))

		            if self.show_tips_ticket ~= nil then
			            GlobalTimeTicket:getInstance():remove(self.show_tips_ticket)
			            self.show_tips_ticket = nil
			        end
                end
            end, 1)
        end
	else
		if self.show_tips_ticket ~= nil then
            GlobalTimeTicket:getInstance():remove(self.show_tips_ticket)
            self.show_tips_ticket = nil
        end
	end
end

function BackPackSellConfirmWindow:onComfirm()
	if self.callback then
        self.callback()
    end
    controller:openSellConfirmWindow(false)
end

function BackPackSellConfirmWindow:setData(list)
    if not list then return end
    
    local data_list = {}
    for i,v in ipairs(list) do
        local item = {}
        item[1] = v.bid
        item[2] = v.num
        local name = Config.ItemData.data_get_data(v.bid).name
        item[3] = name
        table_insert(data_list, item)
    end

    if #data_list == 0 then
        commonShowEmptyIcon(self.item_scrollview, true, {font_size = 22,scale = 1, text = TI18N("无出售奖励")})
        return
    end
    
    local setting = {}
    setting.scale = 1
    setting.max_count = 5
    setting.is_center = true
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
end

function BackPackSellConfirmWindow:close_callback()
	if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)

    self:openTimer(false)
end
