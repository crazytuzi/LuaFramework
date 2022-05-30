-- --------------------------------------------------------------------
-- 签到
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-12
-- --------------------------------------------------------------------
SignPanel = class("SignPanel", function()
    return ccui.Widget:create()
end)

function SignPanel:ctor()
	self.ctrl = WelfareController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self:configUI()
	self:register_event()
end

function SignPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/sign_panel"))
    self:addChild(self.root_wnd)
    -- self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_con = self.main_container:getChildByName("title_con")
    self.title_img = self.title_con:getChildByName("title_img")
    self.tips_btn = self.title_con:getChildByName("tips_btn")

    local res = PathTool.getWelfareBannerRes("txt_cn_welfare_banner2")
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.title_img) then
    			loadSpriteTexture(self.title_img, res , LOADTEXT_TYPE)
    		end
    	end,self.item_load)
    end

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.empty_tips = self.goods_con:getChildByName("empty_tips")
    self.empty_tips:setVisible(false)
    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = SignItem,      -- 单元类
        start_x = 20,                  -- 第一个单元的X起点
        space_x = 28,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 20,                   -- y方向的间隔
        item_width = 107,               -- 单元的尺寸width
        item_height = 107,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 5                         -- 列数，作用于垂直滚动类型
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    
    -- 引导中不给滑动列表
    if GuideController:getInstance():isInGuide() then
        self.item_scrollview:setClickEnabled(false)
    end

    self.sign_btn = self.main_container:getChildByName("sign_btn")
    self.ctrl:sender14100()
end

function SignPanel:createList( data )
	local config = Config.CheckinData.data_award
    local now_time = GameNet:getInstance():getTime()
    local month = tonumber(os.date("%m", now_time)) 
    local data_list = deepCopy(config[month])

    local has_day = data.day
    local now_day = 0
    for k,v in pairs(data_list) do
    	if data.status >0 then 
	    	if k< has_day then --累计的
	    		v.status = 2 --已领取全部奖励
	    	elseif k == has_day then --今天
	    		v.status = data.status
	    		--v.now_day = k
	    	else--之后的
	    		v.status = 0 --没领
	    	end
	    	v.now_day = has_day
	    	now_day = has_day
	    elseif data.status == 0 then 
	    	if k<= has_day then --累计的
	    		v.status = 2 --已领取全部奖励
	    	elseif k == has_day+1 then --今天
	    		v.status = data.status
	    	else--之后的
	    		v.status = 0 --没领
	    	end
	    	v.now_day = has_day+1 
	    	now_day = has_day+1
	    end
    end
    --print("=====len==",month,#data_list)

    self.item_scrollview:setData(data_list,function ( cell )
    	local data = cell:getData()
    	--print("=====now_day====",data.now_day,data.day)
    	if data.status == 1 and data.now_day == data.day and self.model:getRechargeCount()==0 then
    		local str = TI18N("当天充值<div fontcolor=289b14>任意金额</div>可<div fontcolor=289b14>额外</div>获得一次奖励\n　　　　　（单笔1元以上）")
	        local function fun()
				VipController:getInstance():openVipMainWindow(true,VIPTABCONST.CHARGE)
				--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
	        end
	        CommonAlert.show(str,TI18N("确认"),fun,TI18N("取消"),nil,CommonAlert.type.rich)
	    elseif data.day > data.now_day then 
	    	message(TI18N("未达到签到天数"))
    	else
    		self.ctrl:sender14101()
    	end
    end)

    self.item_scrollview:addEndCallBack(function ()
    	local list = self.item_scrollview:getItemList()
    	local pos 
    	for k, v in pairs(list) do
    		local vo = v:getData()
    		if vo.day == 26 then
    			pos = v:getItemPosition()
    		end
    	end
	    if now_day >= 25 then 
	    	self.item_scrollview:jumpToMove(cc.p(pos.x,pos.y+self.item_scrollview:getContentSize().height/2),0.1)
	    end
	end)
end

function SignPanel:register_event(  )
	if self.update_sign_info == nil then 
		self.update_sign_info = GlobalEvent:getInstance():Bind(WelfareEvent.Update_Sign_Info,function ( data )
			self:createList(data)
		end)
	end

	if self.sign_success == nil then 
		self.sign_success = GlobalEvent:getInstance():Bind(WelfareEvent.Sign_Success,function ( data )
			self:createList(data)
		end)
	end

	self.tips_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			TipsManager:getInstance():showCommonTips(Config.CheckinData.data_const.checkin_rules.desc,sender:getTouchBeganPosition())
		end
	end)

	-- 引导中不给滑动列表
	if self.update_guide_status == nil then 
		self.update_guide_status = GlobalEvent:getInstance():Bind(GuideEvent.Update_Guide_Status_Event,function ( in_guide )
			if in_guide then
	            self.item_scrollview:setClickEnabled(false)
	        else
	            self.item_scrollview:setClickEnabled(true)
	        end
		end)
	end
end

function SignPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)    
end

function SignPanel:DeleteMe()
	if self.update_sign_info ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_sign_info)
        self.update_sign_info = nil
    end

    if self.sign_success ~= nil then
        GlobalEvent:getInstance():UnBind(self.sign_success)
        self.sign_success = nil
    end

    if self.update_guide_status ~= nil then
    	GlobalEvent:getInstance():UnBind(self.update_guide_status)
    	self.update_guide_status = nil
    end

    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
end

-- --------------------------------------------------------------------
-- 签到子项
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-12
-- --------------------------------------------------------------------
SignItem = class("SignItem", function()
    return ccui.Widget:create()
end)


function SignItem:ctor()
	self:configUI()
	self:register_event()
end

function SignItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/sign_item"))
    self:addChild(self.root_wnd)
    -- self:setCascadeOpacityEnabled(true)
    --self:setSwallowTouches(false)
    self:setContentSize(cc.size(107,107))
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)

    self.get = self.main_container:getChildByName("get")
    self.get:setLocalZOrder(20)
    self.get:setVisible(false)
    self.get2 = self.main_container:getChildByName("get2")
    self.img = self.get2:getChildByName("img")
    self.get2:setLocalZOrder(20)
    self.get2:setVisible(false)
    doStopAllActions(self.img) 

    self.goods_item = BackPackItem.new(true,true)
	--self.goods_item:setData(Config.ItemData.data_get_data(1))
	self.goods_item:setScale(0.9)
	self.goods_item:setAnchorPoint(0.5,0.5)
	self.goods_item:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
	self.goods_item:setTouchEnabled(false)
	self.goods_item:setSwallowTouches(false)
	self.main_container:addChild(self.goods_item)
end

function SignItem:register_event(  )
	self.main_container:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
				self.touch_end = sender:getTouchEndPosition()
				local is_click = true
				if self.touch_began ~= nil then
					is_click =
						math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
						math.abs(self.touch_end.y - self.touch_began.y) <= 20
				end
				if is_click == true then
					playButtonSound2()
					if self.callback then
						self:callback()
					end
				end
			elseif event_type == ccui.TouchEventType.moved then
			elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
			elseif event_type == ccui.TouchEventType.canceled then
			end
	end)
end

function SignItem:setData( data )
	if data == nil then return end
	self.data = data

	-- 引导需要
	if data._index then
		self.main_container:setName("sign_btn_" .. data._index)
	end

	local vo = {}
	vo = deepCopy(Config.ItemData.data_get_data(data.rewards[1][1]))
	vo.quantity = data.rewards[1][2]
	self.goods_item:setData(vo)
	if data.status then 
		if data.status == 0 then  --没领
			if data.now_day == data.day then --是今天 
				if self.effect == nil then 
					self.effect = createEffectSpine(PathTool.getEffectRes(262), cc.p(self.main_container:getContentSize().width/2,self.main_container:getContentSize().height/2), cc.p(0.5, 0.5), true, "action") 
					self.effect:setScale(1)
					self.main_container:addChild(self.effect)
				end
				self.effect:setVisible(true)
			else
				if self.effect then 
					self.effect:setVisible(false)
				end
			end
			self.main_container:setTouchEnabled(true)
			self.get2:setVisible(false)
    		doStopAllActions(self.img) 
			self.get:setVisible(false)

		elseif data.status == 1 then --领取普通奖励
			if self.effect then 
				self.effect:setVisible(false)
			end
			self.get2:setVisible(true)
			--breatheShineAction(self.img)
			self.get:setVisible(false)
			self.main_container:setTouchEnabled(true)
		elseif data.status == 2 then --领取vip奖励
			if self.effect then 
				self.effect:setVisible(false)
			end
    		doStopAllActions(self.img) 
			self.get2:setVisible(false)
			self.get:setVisible(true)
			self.main_container:setTouchEnabled(false)
		end
	end

	if data.is_show then
		if data.is_show==1 then
			self.goods_item:showItemEffect(true,263,PlayerAction.action_2,true,1.1)
		else
			self.goods_item:showItemEffect(false)
		end
	end
end

function SignItem:addCallBack( value )
	self.callback =  value
end

function SignItem:getData( )
	return self.data
end

function SignItem:getItemPosition()
    if self then
        return cc.p(self:getPosition())
    end
end
	

function SignItem:DeleteMe()
    doStopAllActions(self.img) 
	if self.goods_item then 
		self.goods_item:DeleteMe()
	end
	self:removeAllChildren()
	self:removeFromParent()
end
