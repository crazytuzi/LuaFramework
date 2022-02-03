-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冒险商店
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureShopWindow = AdventureShopWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local game_net = GameNet:getInstance()

function AdventureShopWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.index = 2
	self.layout_name = "adventure/adventure_shop_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("mall", "mall"), type = ResourcesType.plist},
	}
end 

function AdventureShopWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 1)
    container:getChildByName("win_title"):setString(TI18N("冒险商店"))
    container:getChildByName("time_title"):setString(TI18N("商店重置:"))

    self.close_btn = container:getChildByName("close_btn")

    self.list_panel = container:getChildByName("list_panel")
    self.time_value = container:getChildByName("time_value")

    self.empty_tips = container:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("暂无商品，快去寻找冒险商人吧"))

    self.item = container:getChildByName("item")
    self.item:setVisible(false)
end

function AdventureShopWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            controller:openAdventrueShopWindow(false)
        end
    end)
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            controller:openAdventrueShopWindow(false)
        end
    end)
	self:addGlobalEvent(AdventureEvent.UpdateShopTotalEvent, function(data_list)
		self:updateShopTotalList(data_list)
	end)

	self:addGlobalEvent(AdventureEvent.UpdateShopItemEvent, function(id)
		self:updateSingleShopItem(id)
	end)
end

function AdventureShopWindow:updateShopTotalList(data_list)
	if data_list == nil or next(data_list) == nil then
		if self.scroll_view then
			self.scroll_view:setVisible(false)
		end
		self.empty_tips:setVisible(true)
	else
		self.empty_tips:setVisible(false)
		local function clickback(cell, data)
			self:selectItemHandle(cell, data)
		end

		if self.scroll_view == nil then
			local size = self.list_panel:getContentSize()
			local setting = {
				item_class = AdventureShopItem,
				start_x = 0,
				space_x = 0,
				start_y = 0,
				space_y = 4,
				item_width = 306,
				item_height = 143,
				row = 2,
				col = 2,
				need_dynamic = true
			}
			self.scroll_view = CommonScrollViewLayout.new(self.list_panel, nil, nil, nil, size, setting)
		end

		-- 排序
		table_sort(data_list, function(a, b) 
			return a.is_buy < b.is_buy 
		end)

		self.scroll_view:setVisible(true)
		self.scroll_view:setData(data_list, clickback, nil, self.item)
	end
end

--==============================--
--desc:点击单位的时候处理
--time:2019-01-25 12:21:37
--@cell:
--@data:
--@return 
--==============================--
function AdventureShopWindow:selectItemHandle(cell, data)
	if cell == nil or cell.item_config == nil or cell.buy_config == nil then return end
	if data and data.is_buy == 1 then
		message(TI18N("该物品已被购买"))
		return
	end
	local item_config = cell.item_config
	local buy_config = cell.buy_config

	local color = BackPackConst.quality_color_id[item_config.quality] or 0
	local str = string.format("%s<img src=%s visible=true scale=0.3 />%s%s<div fontColor=%s>%s</div>x%s", TI18N("是否消耗"),
		PathTool.getItemRes(buy_config.icon), MoneyTool.GetMoneyString(data.pay_val), TI18N("购买"), tranformC3bTostr(color), item_config.name, data.num)
	
	CommonAlert.show(str, TI18N("确定"), function()
		if data then
			controller:requestBuyShopItem(data.id)
		end
	end, TI18N("取消"), nil, CommonAlert.type.rich)

	self.select_item = cell
	self.select_data = data
end

--==============================--
--desc:更新单个物品
--time:2019-01-25 12:11:14
--@id:
--@return 
--==============================--
function AdventureShopWindow:updateSingleShopItem(id)
	if self.select_item == nil then return end
	if self.select_data.id == id then
		self.select_data.is_buy = 1
	end
	-- 设置已售状态
	self.select_item:updateOverStatus()
end

function AdventureShopWindow:openRootWnd()
	controller:requestShopTotal()

	self:updateEndTime()
end

--==============================--
--desc:更新重置事件
--time:2019-01-25 09:32:36
--@return 
--==============================--
function AdventureShopWindow:updateEndTime()
	self.base_data = model:getAdventureBaseData()
	if self.base_data == nil then return end
	if self.timeticket == nil then
		self:countDownEndTime()
		self.timeticket = GlobalTimeTicket:getInstance():add(function() 
			self:countDownEndTime()
		end, 1)
	end
end

--==============================--
--desc:计时器
--time:2019-01-25 09:32:43
--@return 
--==============================--
function AdventureShopWindow:countDownEndTime()
	if self.base_data == nil then 
		self:clearEneTime()
		return 
	end
	local end_time = self.base_data.end_time - game_net:getTime()
	if end_time <= 0 then
		end_time = 0
		self:clearEneTime()
	end
	self.time_value:setString(TimeTool.GetTimeFormat(end_time))
end

--==============================--
--desc:清理计时器
--time:2019-01-25 09:32:50
--@return 
--==============================--
function AdventureShopWindow:clearEneTime()
	if self.timeticket then
		GlobalTimeTicket:getInstance():remove(self.timeticket)
		self.timeticket = nil
	end
end

function AdventureShopWindow:close_callback()
    controller:openAdventrueShopWindow(false)
	self:clearEneTime()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冒险商店单利
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureShopItem = class("AdventureShopItem", function()
	return ccui.Layout:create()
end)

function AdventureShopItem:ctor()
	self.is_completed = false
end

function AdventureShopItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)
        self.root_wnd:setVisible(true)

        self.name = self.root_wnd:getChildByName("name")

        local count_bg = self.root_wnd:getChildByName("count_bg")
        self.coin = count_bg:getChildByName("coin")            -- 商品图标
        self.price = count_bg:getChildByName("price")               -- 商品价格

        self.discount = self.root_wnd:getChildByName("discount")                    -- 打折背景
        self.discount_num = self.discount:getChildByName("discount_num")            -- 折扣价格
        self.sold = self.root_wnd:getChildByName("sold")            -- 已售
        self.grey = self.root_wnd:getChildByName("grey")            -- 暗背景

        self.item_container = self.root_wnd:getChildByName("item_container")
        self.backpack_item = BackPackItem.new(false, true, false, 1, false, true) 
        self.backpack_item:setPosition(60, 60)
        self.item_container:addChild(self.backpack_item)

        self.grey:setVisible(false)
				
		self:registerEvent()
	end
end

function AdventureShopItem:registerEvent()
	registerButtonEventListener(self.root_wnd, function()
		if self.call_back then
			self:call_back(self.data)
		end
	end, false, 1) 
end

--==============================--
--desc:设置已售完状态
--time:2019-01-25 12:22:04
--@return 
--==============================--
function AdventureShopItem:updateOverStatus()
	if self.data == nil then return end
	if self.data.is_buy == 1 then
		self.sold:setVisible(true)
		self.grey:setVisible(true)
	else
		self.sold:setVisible(false)
		self.grey:setVisible(false)
	end
end

function AdventureShopItem:setData(data)
	self.data = data
	if data then
		local item_config = Config.ItemData.data_get_data(data.bid)
		local buy_config = Config.ItemData.data_get_data(data.pay_type)
		self.item_config = item_config
		self.buy_config = buy_config
		if item_config and buy_config then
			self.backpack_item:setBaseData(data.bid, data.num)

			-- 物品名字
			self.name:setString(item_config.name)

			-- 资源类型
			local res_id = PathTool.getItemRes(buy_config.icon)
			if self.icon_res_id ~= res_id then
				self.icon_res_id = res_id
				self.coin:loadTexture(res_id, LOADTEXT_TYPE) 
			end
		end

		-- 价格
		self.price:setString(MoneyTool.GetMoneyString(data.pay_val)) 

		-- 折扣
		if data.discount ~= 0 then
			self.discount:setVisible(true)
			self.discount_num:setString(data.discount..TI18N("折"))
		else
			self.discount:setVisible(false)
		end

		self:updateOverStatus()
	end
end

function AdventureShopItem:addCallBack(call_back)
	self.call_back = call_back
end 

function AdventureShopItem:suspendAllActions()
end

function AdventureShopItem:DeleteMe()
    if self.backpack_item then
        self.backpack_item:DeleteMe()
    end
    self.backpack_item = nil
	self:removeAllChildren()
	self:removeFromParent()
end 