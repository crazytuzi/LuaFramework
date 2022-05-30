-- --------------------------------------------------------------------
-- @author: htp
--   限时活动通用模板(有倒计时时间的)
-- 目前用：融合祝福、升星有礼
-- <br/>Create: 
-- --------------------------------------------------------------------
ActionLimitCommonPanel = class("ActionLimitCommonPanel", function()
    return ccui.Widget:create()
end)
local controller = ActionController:getInstance()
function ActionLimitCommonPanel:ctor(bid)
	self.holiday_bid = bid
	self:configUI()
	self:register_event()
end

function ActionLimitCommonPanel:configUI( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_common_panel"))
	self.root_wnd:setPosition(-40,-105)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()

    local title_con = self.main_container:getChildByName("title_con")
	title_con:getChildByName("time_title"):setString(TI18N("剩余时间:"))
	self.time_val = title_con:getChildByName("time_val")
    self.goods_con = self.main_container:getChildByName("goods_con")

    -- 横幅图片
    local title_img = title_con:getChildByName("title_img")
    local str = "txt_cn_welfare_banner15"
    if self.holiday_bid == ActionRankCommonType.updata_star then
        str = "txt_cn_welfare_banner16"
    end
    if not self.item_load then
        self.item_load = createResourcesLoad(PathTool.getWelfareBannerRes(str), ResourcesType.single, function()
            if not tolua.isnull(title_img) then
                loadSpriteTexture(title_img, PathTool.getWelfareBannerRes(str), LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    local bgSize = self.goods_con:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local setting = {
        item_class = ActionLimitCommonItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 688,               -- 单元的尺寸width
        item_height = 152,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

--设置倒计时
function ActionLimitCommonPanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    doStopAllActions(self.time_val)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    doStopAllActions(self.time_val)
                    self.time_val:setString("00:00:00")
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function ActionLimitCommonPanel:setTimeFormatString(time)
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
    else
        self.time_val:setString("00:00:00")
    end
end

function ActionLimitCommonPanel:register_event(  )
	if not self.limin_common_event  then
		self.limin_common_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
			if data.bid == self.holiday_bid then
                controller:getModel():sortItemList(data.aim_list)
                local tab = {}
                tab.bid = data.bid
                self.item_scrollview:setData(data.aim_list,nil,nil,tab)
                -- 活动剩余时间
                local time = data.remain_sec
                if time <= 0 then
                    time = 0
                end
                self:setLessTime(time)
			end
		end)
	end
end

function ActionLimitCommonPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
    	controller:cs16603(self.holiday_bid)
    end
end

function ActionLimitCommonPanel:DeleteMe(  )
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

	if self.limin_common_event then
        GlobalEvent:getInstance():UnBind(self.limin_common_event)
        self.limin_common_event = nil
    end
    doStopAllActions(self.time_val)
    if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
end

------------------------------------------
-- 子项
ActionLimitCommonItem = class("ActionLimitCommonItem", function()
    return ccui.Widget:create()
end)

function ActionLimitCommonItem:ctor()
	self.ctrl = ActionController:getInstance()
	self:configUI()
	self:register_event()
end

function ActionLimitCommonItem:configUI(  )
	self.size = cc.size(688,152)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("action/action_limit_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_6"):setString(TI18N("前往"))
    self.btn_goto:setVisible(false)
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:getChildByName("Text_5"):setString(TI18N("领取"))
    self.btn_get:setVisible(false)
    self.btn_has = main_container:getChildByName("btn_has")
    self.btn_has:setVisible(false)

    self.goods_con = main_container:getChildByName("good_cons")
    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.80                     -- 缩放
    }
    self.item_scrollview_son = CommonScrollViewLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview_son:setSwallowTouches(false)

    self.title_desc = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5), cc.p(14,129), nil, nil, 400)
    main_container:addChild(self.title_desc)

    self.goal_desc = createRichLabel(24, cc.c4b(0x68,0x45,0x2a,0xff), cc.p(0.5,0.5), cc.p(596,127), nil, nil, 400)
    main_container:addChild(self.goal_desc)
end

function ActionLimitCommonItem:register_event( )
    registerButtonEventListener(self.btn_get, function()
        if self.holiday_item_bid and self.data then
            self.ctrl:cs16604(self.holiday_item_bid,self.data.aim)
        end
    end,true, 1)

    registerButtonEventListener(self.btn_goto, function()
        local num
        if self.holiday_item_bid == ActionRankCommonType.updata_star then
            num = 404
        elseif self.holiday_item_bid == ActionRankCommonType.fusion_blessing then
            num = 155
        end
        StrongerController:getInstance():clickCallBack(num)
    end,true, 1)
end

function ActionLimitCommonItem:setExtendData(data)
    self.holiday_item_bid = data.bid
    -- self.finish = data.finish
end

function ActionLimitCommonItem:setData( data )
	self.data = data
    self.title_desc:setString(data.aim_str)

    local cur_count = keyfind('aim_args_key', 6, data.aim_args) or 0
    local totle_count = keyfind('aim_args_key', 4, data.aim_args) or 0    
    local str = string.format("(<div fontColor=#2c7d08>%d</div>/%d)", cur_count.aim_args_val, totle_count.aim_args_val)
    self.goal_desc:setString(str)

    if cur_count.aim_args_val >= totle_count.aim_args_val and data.status == 0 then
        data.status = 2
    end
    self.btn_goto:setVisible(data.status == 0)
    self.btn_get:setVisible(data.status == 1)
    self.btn_has:setVisible(data.status == 2)

    
    -- if data.status == 0 and self.finish == true then
    --     setChildUnEnabled(true, self.btn_goto)
    --     self.btn_goto:setTouchEnabled(false)
    -- end
	-- 物品列表
	local item_list = data.item_list
    local list = {}
    for k, v in pairs(item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        if vo then
            vo.quantity = v.num
            table.insert(list, vo)
        end
    end
    self.item_scrollview_son:setData(list)
    self.item_scrollview_son:addEndCallBack(function()
        local list = self.item_scrollview_son:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end

function ActionLimitCommonItem:DeleteMe( )
	if self.item_scrollview_son then
        self.item_scrollview_son:DeleteMe()
        self.item_scrollview_son = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end