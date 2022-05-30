--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 回归特权
-- @DateTime:    2019-12-2 17:18:37
-- *******************************
ReturnActionPrivilegePanel = class("ReturnActionPrivilegePanel", function()
    return ccui.Widget:create()
end)
local controller = ReturnActionController:getInstance()
local model = controller:getModel()
local const_data = Config.HolidayReturnNewData.data_constant
local gift_data = Config.HolidayReturnNewData.data_gift
function ReturnActionPrivilegePanel:ctor(bid)
	self.holiday_bid = bid
	self.touch_buy_gift = nil
	self:configUI()
	self:register_event()
end

function ReturnActionPrivilegePanel:configUI( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("returnaction/returnaction_privilege_panel"))
	self.root_wnd:setPosition(-40,-81)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local load_bg = main_container:getChildByName("load_bg")

    local holiday_data = model:getReturnActionData(self.holiday_bid)
    local str = "txt_cn_returnaction1"
    if holiday_data then
    	str = holiday_data.panel_res
    end
	local res = PathTool.getPlistImgForDownLoad("bigbg/returnaction", str,true)
	if not self.bg_load then
		self.bg_load = loadSpriteTextureFromCDN(load_bg, res, ResourcesType.single, self.bg_load)
	end
	
	main_container:getChildByName("Text_1"):setString(TI18N("我们准备了一些特权和奖励\n可以帮你更快地融入游戏"))
	
	main_container:getChildByName("Text_4"):setString(TI18N("剩余时间："))
	self.remain_time = main_container:getChildByName("remain_time")
	self.remain_time:setString("")
	
	self.goods_item = main_container:getChildByName("goods_item")
	self.goods_item:setScrollBarEnabled(false)
	self.btn_buy = main_container:getChildByName("btn_buy")
	self.btn_buy:setVisible(false)
	self.btn_buy_text = self.btn_buy:getChildByName("Text_6")
	self.btn_buy_text:setString("")

	self.desc_val = createRichLabel(20, cc.c4b(0x70,0x6d,0xb7,0xff), cc.p(0, 1), cc.p(100,480),20,nil,530)
    main_container:addChild(self.desc_val)
    self:setData()

	controller:sender27900()
end

function ReturnActionPrivilegePanel:register_event()
	if not self.privilege_event then
        self.privilege_event = GlobalEvent:getInstance():Bind(ReturnActionEvent.Gift_Data_Event,function()
            self:receveSetData()
        end)
    end

	registerButtonEventListener(self.btn_buy,function()
		if self.touch_buy_gift == true then return end
		self.touch_buy_gift = true

		local status = model:getActionGiftStatus()
		if status == 0 then
			controller:sender27901()
			if self.buy_gift_ticket == nil then
                self.buy_gift_ticket = GlobalTimeTicket:getInstance():add(function()
                    self:clearTicket()
                end,2)
            end
		end
	end,true, 1)

end
function ReturnActionPrivilegePanel:clearTicket()
	self.touch_buy_gift = nil
	if self.buy_gift_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_gift_ticket)
        self.buy_gift_ticket = nil
    end
end

--配置表的数据
function ReturnActionPrivilegePanel:setData()
	local period = model:getActionPeriod()
	if not gift_data[period] then return end
	local holiday_data = model:getReturnActionData(self.holiday_bid)
	if holiday_data then
		self.desc_val:setString(holiday_data.tips)	
	end
	

	local data_list = gift_data[period].rewards
    local setting = {}
    setting.scale = 0.9
    setting.max_count = 4
    setting.is_center = true
    -- setting.show_effect_id = 263
    setting.space_x = 10
    self.buy_item_list = commonShowSingleRowItemList(self.goods_item, self.buy_item_list, data_list, setting)

end
--接收服务器返回的数据
function ReturnActionPrivilegePanel:receveSetData()
	local endtime = model:getActionGiftEndTime()
	setCountDownTime(self.remain_time,endtime - GameNet:getInstance():getTime())
	self.btn_buy:setVisible(true)
	
	local status = model:getActionGiftStatus()
	if status == 1 then
		self.btn_buy:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_buy)
		self.btn_buy_text:disableEffect(cc.LabelEffect.OUTLINE)
		self.btn_buy_text:setString(TI18N("已领取"))
	else
		self.btn_buy_text:setString(TI18N("立即领取"))
		self.btn_buy_text:enableOutline(cc.c4b(0x6C,0x2B,0x00,0xff), 2)
	end
	delayRun(self.goods_item, 0.1, function ()
		if self.buy_item_list then
			for k,v in pairs(self.buy_item_list) do
				if v and not tolua.isnull(v) then
					if status == 1 then
						v:showItemEffect(false)
					else
						v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
					end
				end
			end
		end
	end)
end

function ReturnActionPrivilegePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function ReturnActionPrivilegePanel:DeleteMe()
	doStopAllActions(self.goods_item)
	self:clearTicket()
	doStopAllActions(self.remain_time)
	if self.privilege_event then
        GlobalEvent:getInstance():UnBind(self.privilege_event)
        self.privilege_event = nil
    end
  

	if self.bg_load then 
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end
    if self.buy_item_list then
		for i,v in pairs(self.buy_item_list) do
			if v.DeleteMe then
				v:DeleteMe()
			end
        end
        self.buy_item_list = nil
    end
end