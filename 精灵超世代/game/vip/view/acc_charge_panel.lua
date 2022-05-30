-- --------------------------------------------------------------------
-- 累充界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-14
-- --------------------------------------------------------------------
AccChargePanel = class("AccChargePanel", function()
    return ccui.Widget:create()
end)

function AccChargePanel:ctor()  
    self:layoutUI()
    self:registerEvents()
end

function AccChargePanel:layoutUI(  )
	self.ctrl = VipController:getInstance()
	self.model = self.ctrl:getModel()
    self.size = cc.size(660,644)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,0))

 	self.main_container = ccui.Widget:create()
 	self.main_container:setAnchorPoint(cc.p(0,0))
 	self.main_container:setContentSize(self.size)
 	self.main_container:setSwallowTouches(false)
 	self:addChild(self.main_container)

    local setting = {
        item_class = AccChargeItem,      -- 单元类
        start_x = 8,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 652,               -- 单元的尺寸width
        item_height = 172,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.main_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, self.size, setting)
    
    self.arrow = createSprite(PathTool.getResFrame("common","common_90034"), self.main_container:getContentSize().width/2-50, -37, self.main_container, cc.p(0.5,0), LOADTEXT_TYPE_PLIST)
    self.arrow:setRotation(90)

    self.ctrl:sender16712()
end

function AccChargePanel:registerEvents(  )
	if self.update_info == nil then 
		self.update_info = GlobalEvent:getInstance():Bind(VipEvent.ACC_RECHARGE_INFO,function ( data )
			--排下序 可领取—未达成—已领取 1 0 2

			local show_list = {}
			for k,v in pairs(data.list) do
				if v.status == 1 then 
					v.order = 1
				elseif v.status == 0 then 
					v.order = 2 
				elseif v.status == 2 then 
					v.order = 3
				end
				table.insert(show_list,v)
			end

			table.sort(show_list,SortTools.tableLowerSorter({"order","id"})) 

			self.item_scrollview:setData(show_list)
		end)
	end
end

function AccChargePanel:setVisibleStatus( status )
	self:setVisible(status)
end

function AccChargePanel:DeleteMe()
	if self.update_info then
        GlobalEvent:getInstance():UnBind(self.update_info)
        self.update_info = nil
    end

    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end


-- --------------------------------------------------------------------
-- 累冲子项
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-14
-- --------------------------------------------------------------------
AccChargeItem = class("AccChargeItem", function()
    return ccui.Widget:create()
end)

function AccChargeItem:ctor()
	self.ctrl = VipController:getInstance()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self:configUI()
	self:register_event()
end

function AccChargeItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/acc_charge_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(652,172))
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)

    self.title = self.main_container:getChildByName("title")

    self.btn = self.main_container:getChildByName("btn")
    self.btn:setTitleText(TI18N("前往"))

    self.coin = self.main_container:getChildByName("coin")
    self.exp = self.main_container:getChildByName("exp")
    self.exp:setString("")

    self.title_label1 = self.main_container:getChildByName("title_label1")
    self.title_label1:setString(TI18N("累充"))
    self.title_label2 = self.main_container:getChildByName("title_label2")
    self.title_label2:setString(TI18N("钻石"))

    self.charge_num = CommonNum.new(21, self.main_container, 1, -2, cc.p(0, 0.5))
    self.charge_num:setScale(0.55)
    self.charge_num:setPosition(53, 160)

    self.get = self.main_container:getChildByName("get")
    self.get:setVisible(false)

    self.goods_con = self.main_container:getChildByName("goods_con")
    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 5,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.9,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.9,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.9
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function AccChargeItem:register_event(  )
	self.btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data.status == 0 then
				self.ctrl:changeMainWindowTab(VIPTABCONST.CHARGE)
			elseif self.data.status == 1 then 
				self.ctrl:sender16713(self.data.id)
			else
				message(TI18N("已经领取啦"))
			end
		end
	end)
end

function AccChargeItem:setData( data )
	self.data = data
	local config = deepCopy(Config.ChargeData.data_charge_reward_data[data.id])
	local reward_list = config.item_list
	local spe_reward = config.spe_item_list
	local checSpec = function(bid)
		if spe_reward and next(spe_reward or {}) ~= nil then
			for i, v in pairs(spe_reward) do
				if v == bid then
					return true
				end
			end
			return false
		end
	end

	local vo_list = {}
	for k,v in pairs(reward_list) do
		local vo = {}
		vo = deepCopy(Config.ItemData.data_get_data(v[1]))
		if vo then 
			vo.quantity = v[2]
			table.insert(vo_list,vo)
		end
	end
	self.item_scrollview:setData(vo_list)

	self.item_scrollview:addEndCallBack(function (  )
		local list = self.item_scrollview:getItemList()
		for k,v in pairs(list) do
			v:setDefaultTip()
			if v.data and v.data.id and checSpec(v.data.id) then
				if v.data.quality >= 4 then
					v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
				else
					v:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
				end
			else
				v:showItemEffect(false)
			end
		end
	end)

	self.charge_num:setNum(config.charge_sum)
	self.charge_num:setCallBack(function (  )
        self.title_label2:setPositionX(self.charge_num:getPositionX()+self.charge_num:getContentSize().width/2+10)
    end)
    if self.charge_num:getContentSize().width>0 then
        self.title_label2:setPositionX(self.charge_num:getPositionX()+self.charge_num:getContentSize().width/2+10)
    end


	if data.status then 
		if data.status == 0 then --未达成
			self.get:setVisible(false)
			self.btn:setVisible(true)
			self.btn:setTitleText(TI18N("去充值"))
			local path = PathTool.getResFrame("common","common_1018")
			self.btn:loadTextures(path,path,nil,LOADTEXT_TYPE_PLIST)
			self.btn.label = self.btn:getTitleRenderer()
		    if self.btn.label ~= nil then
		        self.btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
		    end
		elseif data.status == 1 then --可领取
			self.get:setVisible(false)
			self.btn:setVisible(true)
			self.btn:setTitleText(TI18N("领取"))
			local path = PathTool.getResFrame("common","common_1017")
			self.btn:loadTextures(path,path,nil,LOADTEXT_TYPE_PLIST)
			self.btn.label = self.btn:getTitleRenderer()
		    if self.btn.label ~= nil then
		        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
		    end
		elseif data.status == 2 then 
			self.get:setVisible(true)
			self.btn:setVisible(false)
			self.btn:setTitleText(TI18N("已领取"))
		end
	end

	self.charge_sum = self.ctrl:getChargeSum()
	self.exp:setString(self.charge_sum.."/"..config.charge_sum)
	self.coin:setPositionX(self.exp:getPositionX()-self.exp:getContentSize().width)
end

function AccChargeItem:addCallBack( value )
	self.callback =  value
end

function AccChargeItem:getData( )
	return self.data
end

function AccChargeItem:DeleteMe()
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.charge_num then
        self.charge_num:DeleteMe()
        self.charge_num = nil
    end

	self:removeAllChildren()
	self:removeFromParent()
end