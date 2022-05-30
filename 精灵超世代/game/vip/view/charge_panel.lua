-- --------------------------------------------------------------------
-- 充值界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-30
-- --------------------------------------------------------------------
ChargePanel = class("ChargePanel", function()
    return ccui.Widget:create()
end)

function ChargePanel:ctor()  
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ChargePanel:config(  )
	self.ctrl = VipController:getInstance()
	self.model = self.ctrl:getModel()
    self.size = cc.size(690,470)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,0))

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/charge_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)

    self.item_list = {}
    self.select_item = nil
end

function ChargePanel:layoutUI(  )
	self.main_container = self.root_wnd:getChildByName("main_container")
	self.scrollCon = self.main_container:getChildByName("scrollCon")

	self.scrollView = createScrollView(self.scrollCon:getContentSize().width,self.scrollCon:getContentSize().height,0,0,self.scrollCon,ccui.ScrollViewDir.vertical)

	self.ctrl:sender16700()
	self.ctrl:sender21005()
	WelfareController:getInstance():sender16705()
	
end

function ChargePanel:registerEvents(  )
	if self.update_event == nil then
		self.update_event = GlobalEvent:getInstance():Bind(VipEvent.UPDATE_CHARGE_LIST,function(list )
			dump(list,"list")
			for k,v in pairs(list) do
				if Config.ChargeData.data_charge_data[v.id] then
					v.sort = Config.ChargeData.data_charge_data[v.id].sort
				end
			end
			table.sort( list, SortTools.KeyLowerSorter("id") )
			self:createItemList(list)
		end)
	end

	if self.tips_btn then
		self.tips_btn:addTouchEventListener(function ( sender,event_type )
	    	if event_type == ccui.TouchEventType.ended then
	        	playButtonSound2()
	        	TipsManager:getInstance():showCommonTips(Config.ChargeData.data_constant.triple_charge_rule.desc,sender:getTouchBeganPosition())
	        end
	    end)
	end
end

function ChargePanel:createItemList( tmp_list )
	if tmp_list == nil then return end
	local list = {}
	if PLATFORM_NAME == "demo" then
		list = tmp_list
	else
		for i,v in ipairs(tmp_list) do
			if v.id >= 2001 or v.id <= 2010 then
				table.insert(list,v)
			end
		end
	end

	local item_height = 124
	
	local height = math.max(self.scrollView:getContentSize().height, #list * item_height)
    self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,height))
	doStopAllActions(self.scrollView)
	for k,v in ipairs(list) do
		delayRun(self.scrollView,0.05*k,function (  )
			if self.item_list[k] == nil then
				local item = ChargeItem.new(self.ctrl)
				item:setPosition(cc.p(0, height - (k-1) *item_height))
				item:addCallBack(function ( item )
					if self.select_item ~= nil and self.select_item:getData().id~= item:getData().id then
						self.select_item:setSeclet(false)
					end
					self.select_item = item
				end)
				self.scrollView:addChild(item)
				self.item_list[k] = item
			end
			self.item_list[k]:setData(v)
		end)
	end

end

function ChargePanel:setVisibleStatus( status )
	self:setVisible(status)
end

function ChargePanel:DeleteMe()
	doStopAllActions(self.scrollView)

	if self.item_list then
		for k,v in pairs(self.item_list) do
			if v and v["DeleteMe"] then
				v:DeleteMe()
			end
		end
		self.item_list = nil
	end


	if self.update_event then
        GlobalEvent:getInstance():UnBind(self.update_event)
        self.update_event = nil
    end

    if self.update_three then
        GlobalEvent:getInstance():UnBind(self.update_three)
        self.update_three = nil
    end
end


-- --------------------------------------------------------------------
-- 充值子项
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-30
-- --------------------------------------------------------------------
ChargeItem = class("ChargeItem", function()
	return ccui.Widget:create()
end)

function ChargeItem:ctor(ctrl)
	self.ctrl = ctrl
	self:configUI()
end

function ChargeItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/charge_item"))
	
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(690,124))
	self:setTouchEnabled(true)
	self:setSwallowTouches(false)

    self.main_container = self.root_wnd:getChildByName("main_container")

	self.price_container = self.main_container:getChildByName("price_container")
    self.coin = self.price_container:getChildByName("coin")
    self.price = self.price_container:getChildByName("price")
    self.icon = self.main_container:getChildByName("icon")

	self.charge_btn = self.main_container:getChildByName("charge_btn")
    self.charge_price = self.charge_btn:getChildByName("label")
	
    self.extra_bg = self.main_container:getChildByName("extra_bg")
	self.extra_desc = self.extra_bg:getChildByName("give")
	self.extra_desc:setString(TI18N("再赠!"))

    self.extra_label = createRichLabel(24, Config.ColorData.data_new_color4[15], cc.p(0,0.5), cc.p(0,0))
    self.extra_bg:addChild(self.extra_label)

	self.first_bg = self.main_container:getChildByName("first")
	self.first_bg:setVisible(false)
	self.first_label = self.first_bg:getChildByName("first_label")
	self.first_label:setString(TI18N("首次"))
	
	self:registerEvent()
end

function ChargeItem:setData( data )
	self.data = data
	self.charge_price:setString(string.format(TI18N("%s元"), (data.need_rmb/100)))
	self.price:setString(data.get_gold)
	self.extra_bg:setVisible(false)
	if data.is_first == TRUE then
		self.first_bg:setVisible(true)
	else
		self.first_bg:setVisible(false)
	end
	if data.add_gold > 0 then
		self.extra_bg:setVisible(true)
		self.extra_label:setString(string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#d63636>%s</div>"),PathTool.getItemRes(Config.ItemData.data_get_data(4).icon),data.add_gold))
	else
		self.price_container:setPositionY(80)
	end	
	loadSpriteTexture(self.icon, PathTool.getResFrame("vip","vip_icon"..data.pic), LOADTEXT_TYPE_PLIST)

	-- 提审不是普通充值不显示上面的标签
	if MAKELIFEBETTER == true and data.get_gold == 0 then
		self.price_container:setVisible(false)
	end
end

function ChargeItem:addCallBack( value )
	self.callback =  value
end

function ChargeItem:changeDayTips(status,num,total )
end

function ChargeItem:registerEvent(  )
	self.charge_btn:addTouchEventListener(function(sender, event_type) 
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.callback then
				self:callback()
			end
			sdkOnPay(self.data.need_rmb / 100, nil, self.data.id, self.data.name) 
		end
	end)
end

function ChargeItem:getData(  )
	return self.data
end

function ChargeItem:setSeclet( status )
end

function ChargeItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end
