-- --------------------------------------------------------------------
-- Vip特权界面
--
-- --------------------------------------------------------------------
VipPanel = class("VipPanel", function()
    return ccui.Widget:create()
end)

local supre_reward_data = Config.ChargeData.data_supre_reward_data
function VipPanel:ctor()  
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function VipPanel:config(  )
	self.ctrl = VipController:getInstance()
	self.model = self.ctrl:getModel()
    self.size = cc.size(660,647)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,0))

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/vip_panel"))
    self:addChild(self.root_wnd)
    self.root_wnd:setPositionY(-4)
    self:setCascadeOpacityEnabled(true)

    self.role_vo = RoleController:getInstance():getRoleVo()

    self.item_list = {}
    self.desc_list = {}
    self.super_card_status = nil

    self.ctrl:sender16707()
    self.ctrl:sender16710()
    self.ctrl:setIsFirst(false)
end

function VipPanel:layoutUI()
	self.main_container = self.root_wnd:getChildByName("main_container")

	self.chargeCon = self.main_container:getChildByName("chargeCon")

	self.goods_scroll = self.chargeCon:getChildByName("goods_scroll")
	self.item_scroll = createScrollView(390,120,10,0,self.goods_scroll,ccui.ScrollViewDir.horizontal)
	self.item_scroll:setTouchEnabled(true)
	self.giftCon = self.chargeCon:getChildByName("giftCon")
	self.buy_btn = self.chargeCon:getChildByName("buy_btn")
	self.buy_btn:setVisible(true)
	self.buy_complete = self.chargeCon:getChildByName("buy_complete")
	self.buy_complete:setVisible(false)
	self.buy_btn_label = self.buy_btn:getChildByName("buy_btn_label")
	
	self.buy_red = self.buy_btn:getChildByName("red")
	self.buy_red:setVisible(false)
	self.info_scroll = createScrollView(self.giftCon:getContentSize().width,self.giftCon:getContentSize().height,0,0,self.giftCon,ccui.ScrollViewDir.vertical)
	self.title = self.chargeCon:getChildByName("title")
	
	self.old_price = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0), cc.p(self.buy_btn:getPositionX(),96))
	self.chargeCon:addChild(self.old_price)

	self.buy_price = createRichLabel(24, 175, cc.p(0.5,0.5), cc.p(self.buy_btn:getPositionX()-63,57))
	self.chargeCon:addChild(self.buy_price)

	--月卡领取
	self.supre_good_con = self.main_container:getChildByName("Sprite_1"):getChildByName("good_con")
	local scroll_view_size = self.supre_good_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 6,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.60,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.60,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.60
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.supre_good_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    
	self.supre_card_get = self.main_container:getChildByName("Sprite_1"):getChildByName("btn_get")
	self.supre_card_get:setVisible(false)
	self.supre_card_get_label = self.supre_card_get:getChildByName("Text_3_0")
	self.supre_card_get_label:setString(TI18N("领取"))

	self.des_labellist = {}
	self.chargeCon:getChildByName("gift_title"):setString(TI18N("特权礼包"))
	self.red_line = createSprite(PathTool.getResFrame("common","common_1073"),70,14,self.old_price,cc.p(0.5,0.5))
	self.desc_label = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(250,450),nil,nil,1000)
	self.main_container:addChild(self.desc_label)

	if self.role_vo.vip_lev > Config.VipData.data_get_reward_length-1 then
		self:setData(Config.VipData.data_get_reward_length-1)
	else
		self:setData(self.role_vo.vip_lev)
	end
end

function VipPanel:registerEvents()
	self.buy_btn:addTouchEventListener(function ( sender,event_type )
		customClickAction(sender,event_type)
    	if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			
			local role_vip = RoleController:getInstance():getRoleVo().vip_lev
			local is_vip = RoleController:getInstance():getRoleVo().is_vip
			if role_vip == 0 and is_vip == FALSE then
				if self.config.lev == 0 then --0礼包
					self.ctrl:sender16711(self.index)
				else
					local str = string.format(TI18N('未达到VIP%s'), self.config.lev)
					message(str)
				end
			else --如果是vip先判断等级足够不
				if self.config then
					if self.config.lev > role_vip then
						local str = string.format(TI18N("未达到VIP%s"),self.config.lev)
						message(str)
					else
						self.ctrl:sender16711(self.index)
					end
				end
			end
        end
    end)

    if self.update_buy == nil then
    	self.update_buy = GlobalEvent:getInstance():Bind(VipEvent.UPDATE_GET_LIST,function ( )
    		local get_list = self.model:getGetGiftList()
			if get_list[self.index] then
				self.buy_price:setVisible(false)
				self.buy_btn:setVisible(false)
				self.buy_complete:setVisible(true)
			else
				self.buy_price:setVisible(true)
				self.buy_btn:setVisible(true)
				self.buy_complete:setVisible(false)
			end
			self:updateRed()
    	end)
    end

    if self.role_vo then
		if self.role_update_event == nil then
			self.role_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
				if key == "vip_lev" then
					self:updateRed()
        		end
    		end)
		end
	end

	if self.supre_get_event == nil then
    	self.supre_get_event = GlobalEvent:getInstance():Bind(VipEvent.SUPRE_CARD_GET,function(status)
    		self.supre_card_get:setVisible(true)
    		self.super_card_status = status
    		if status == 1 then
				setChildUnEnabled(false, self.supre_card_get)
				self.supre_card_get_label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
    			addRedPointToNodeByStatus(self.supre_card_get,true,7,10)
    			self.supre_card_get_label:setString(TI18N("领取"))
    		else
    			addRedPointToNodeByStatus(self.supre_card_get,false)
    			if status == 0 then
					setChildUnEnabled(false, self.supre_card_get)
					self.supre_card_get_label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
    				self.supre_card_get_label:setString(TI18N("待激活"))
    			else
    				setChildUnEnabled(true, self.supre_card_get)
					self.supre_card_get_label:setString(TI18N("已领取"))
					self.supre_card_get_label:disableEffect()
	    		end
    		end
    	end)
    end
	registerButtonEventListener(self.supre_card_get, function()
		if self.super_card_status then
			if self.super_card_status == 0 then
				JumpController:jumpViewByEvtData({44})
			else
				self.ctrl:sender16708()
			end
		end
    end, true, 1)
end

function VipPanel:updateRed()
	local get_list = self.model:getGetGiftList()
	local len = #get_list
	if self.index == self.role_vo.vip_lev then
		if get_list[self.index]==nil and self.ctrl:getIsFirst() then
			self.buy_red:setVisible(true)
		else
			self.buy_red:setVisible(false)
		end
	else
		self.buy_red:setVisible(false)
	end
end

function VipPanel:setData(index)
	local config = Config.VipData.data_get_reward[index]
	if config == nil then return end

	local list = {}
	for i,v in pairs(supre_reward_data[index].reward) do
		local tab = {}
		tab.bid = v[1]
		tab.quantity = v[2]
		table.insert(list,tab)
	end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
    end)

	self.config = config
	self.title:setString(TI18N("VIP")..index..TI18N("特权"))
	self.index = index
	local role_vip = RoleController:getInstance():getRoleVo().vip_lev
	local is_vip = RoleController:getInstance():getRoleVo().is_vip
	local vip_exp = RoleController:getInstance():getRoleVo().vip_exp

	local desc_str = string.format(TI18N("累计充值<div fontcolor=#249013>%s </div><img src=%s scale=0.3 visible=true />即可享受以下特权"),self.config.gold,PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold))
	self.desc_label:setString(desc_str)
	
	--特权礼包内容
	local items = config.items
	local spec_item = config.spe_reward
	local scale = 0.65
	local single_width = BackPackItem.Width * scale
	local max_width = math.max((single_width+15)*#items,self.item_scroll:getContentSize().width) 
	self.item_scroll:setInnerContainerSize(cc.size(max_width,self.item_scroll:getContentSize().height))
	self:clearItemList()
	local checSpec = function (bid)
		if spec_item and next(spec_item or {}) ~= nil then
			for i,v in pairs(spec_item) do
				if v == bid then
					return  true
				end
			end
			return  false
		end
	end
	local item 
	for k,v in pairs(items) do
		local bid = v[1]
		local num = v[2]
		if not self.item_list[k] then
			local item = BackPackItem.new(true,true)
			item.bid = bid
			self.item_list[k] = item
			self.item_scroll:addChild(item)
		end
		local item_config = deepCopy(Config.ItemData.data_get_data(bid))
		item_config.quantity = num
		item = self.item_list[k]
		item:setData(item_config)
		item:setAnchorPoint(0,0.5)
		item:setVisible(true)
		item:setDefaultTip()
		item:setScale(scale)
		item:setPosition(5+(single_width+15)*(k-1),self.item_scroll:getContentSize().height/2-10)
		if spec_item and next(spec_item or {}) ~= nil then
			if checSpec(bid) then
				if Config.ItemData.data_get_data(bid).quality >= 4 then
					item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
				else
					item:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
				end
			else
				item:showItemEffect(false)
			end
		end
		self.item_list[k] = item
	end

	--特权信息
	local desc_list = config.spe_desc

	local max_height = math.max((30+12)*#desc_list,self.info_scroll:getContentSize().height) 
	self.info_scroll:setInnerContainerSize(cc.size(self.info_scroll:getContentSize().width,max_height))
	local lable_num = #desc_list
	local desc_hasnum = 0 
	for k,v in pairs(self.desc_list) do
		if k>lable_num then
			self.desc_list[k]:setVisible(false)
		else
			self.desc_list[k]:setVisible(true)
		end
		desc_hasnum = desc_hasnum + 1
	end
	for k,v in pairs(desc_list)  do
		if self.desc_list[k] then
			self.desc_list[k]:setString(v)
			self.desc_list[k]:setPosition(5,max_height+10-((self.desc_list[k]:getContentSize().height+12)*k))
		else 
			local delta = k - desc_hasnum
			delayRun(self.info_scroll,0.05*delta,function (  )
				if not self.desc_list[k] then
					local label = createRichLabel(22, 58, cc.p(0,0), cc.p(0,0), 0, 0, self.info_scroll:getContentSize().width)		
					self.desc_list[k] = label	
					label:setString(v)			
					self.info_scroll:addChild(label)
				else
					self.desc_list[k]:setString(v)
				end
				self.desc_list[k]:setPosition(5,max_height+10-((self.desc_list[k]:getContentSize().height+12)*k))
			end)
		end
	end
	self.buy_price:setString(string.format(TI18N("<img src=%s scale=0.3 visible=true />"),PathTool.getItemRes(Config.ItemData.data_get_data(config.price[1][1]).icon)))
	self.old_price:setString(string.format(TI18N("原价<img src=%s scale=0.3 visible=true />%s"),PathTool.getItemRes(Config.ItemData.data_get_data(config.old_price[1][1]).icon),config.old_price[1][2]))
	self.buy_btn_label:setString(string.format(TI18N("%d 购买"),config.price[1][2]))

	local get_list = self.model:getGetGiftList()
	if get_list and get_list[index] then
		--购买过
		self.buy_price:setVisible(false)
		self.buy_btn:setVisible(false)
		self.buy_complete:setVisible(true)
	else
		self.buy_price:setVisible(true)
		self.buy_btn:setVisible(true)
		self.buy_complete:setVisible(false)
	end
	self:updateRed()
end

function VipPanel:clearItemList()
    if self.item_list then
        for k, item in pairs(self.item_list) do
            if not tolua.isnull(item) then
				item:setVisible(false)
            end
        end
    end
end

function VipPanel:setVisibleStatus(status)
	self:setVisible(status)
end

function VipPanel:DeleteMe()
	for k,item in pairs(self.item_list) do
		item:DeleteMe()
	end
	self.item_list = nil

	if self.update_buy then
        GlobalEvent:getInstance():UnBind(self.update_buy)
        self.update_buy = nil
    end
    if self.supre_get_event then
        GlobalEvent:getInstance():UnBind(self.supre_get_event)
        self.supre_get_event = nil
    end
    if self.role_vo then
        if self.role_update_event ~= nil then
            self.role_vo:UnBind(self.role_update_event)
            self.role_update_event = nil
        end
        self.role_vo = nil
    end
end

