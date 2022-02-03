-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会成员捐献物品的假面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildvoyageDonateWindow = GuildvoyageDonateWindow or BaseClass(BaseView)

local controller = GuildvoyageController:getInstance()
local model = controller:getModel()
local backpack_model = BackpackController:getInstance():getModel()
local table_insert = table.insert

function GuildvoyageDonateWindow:__init()
	self.order_type = type
	self.win_type = WinType.Mini
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.is_init = false
	self.layout_name = "guildvoyage/guildvoyage_donate_window"
	self.item_list = {}
end 

function GuildvoyageDonateWindow:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    container:getChildByName("win_title"):setString(TI18N("提示"))
    container:getChildByName("donate_title"):setString(TI18N("捐献以下物品:")) 
    container:getChildByName("rewards_title"):setString(TI18N("可得奖励:")) 

    self.container_size = container:getContentSize()

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确认捐献"))

    self.need_item = BackPackItem.new(false, true, false, 1, false, true)
    self.need_item:setPosition(self.container_size.width*0.5, 350)
    container:addChild(self.need_item)

    local res = PathTool.getResFrame("common","common_90026")
	self.addbtn = createButton(container,"",self.container_size.width*0.5,350,cc.size(70, 70),res,24,Config.ColorData.data_color4[1])
	self.addbtn:addTouchEventListener(function(sender,event_type)
		if event_type == ccui.TouchEventType.ended then
			if self.item_bid then
				BackpackController:getInstance():openTipsSource(true,self.item_bid)
			end
		end
	end)
    self.close_btn = container:getChildByName("close_btn") 
	self.container = container 
end

function GuildvoyageDonateWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then 
            controller:openGuildvoyageDonateWindow(false)
        end
    end)

    self.confirm_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then 
			controller:requestDonateTreasure(self.rid, self.srv_id, self.order_id, self.item_bid)
        end
    end)
end

--==============================--
--desc:
--time:2018-07-04 03:50:22
--@rid:
--@srv_id:
--@order_id:
--@item_bid:物品的基础id
--@item_sum:需要的数量
--@return 
--==============================--
function GuildvoyageDonateWindow:openRootWnd(rid, srv_id, order_id, item_bid, item_sum)
	self.need_item:setBaseData(item_bid)
	local total_num = backpack_model:getBackPackItemNumByBid(item_bid)
	self.need_item:setNeedNum(item_sum, total_num)

	self.rid = rid
	self.srv_id = srv_id 
	self.order_id = order_id
	self.item_bid = item_bid

	local config = Config.GuildShippingData.data_donate_reward[item_bid]
	if config and config.assist_rewards then
		self:createRandRewardsList(config.assist_rewards, item_sum)
	end
end

--==============================--
--desc:创建捐献可获得
--time:2018-07-04 03:55:00
--@list:
--@sum:
--@return 
--==============================--
function GuildvoyageDonateWindow:createRandRewardsList(list, sum)
	if list == nil or next(list) == nil then return end
	local item_num = #list
	local space = 10
	local total_width = item_num*BackPackItem.Width + (item_num -1)*space
	local start_x = (self.container_size.width - total_width) / 2
	local item = nil
	for i, v in ipairs(list) do
		if v[1] and v[2] then
			item = BackPackItem.new(false, true, false, 1, false, true) 
			item:setBaseData(v[1], v[2]*sum)
			item:setPosition(start_x + (i - 1) *(BackPackItem.Width + space) + BackPackItem.Width*0.5, 178)
			self.container:addChild(item)
			table_insert(self.item_list, item)
		end
	end 
end 

function GuildvoyageDonateWindow:close_callback()
	for k, item in ipairs(self.item_list) do
		item:DeleteMe()
	end
	self.item_list = nil

    controller:openGuildvoyageDonateWindow(false)
end