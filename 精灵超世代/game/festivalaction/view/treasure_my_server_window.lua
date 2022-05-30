--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 一元夺宝个人记录
-- @DateTime:    2019-05-17 09:40:23
-- *******************************
TreasureMyServerWindow = TreasureMyServerWindow or BaseClass(BaseView)

local controll = FestivalActionController:getInstance()
local string_format = string.format
function TreasureMyServerWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "festivalaction/treasure_my_server_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("treasure", "treasure"), type = ResourcesType.plist},
    }
end

function TreasureMyServerWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    
    self:playEnterAnimatianByObj(main_container, 2)
    main_container:getChildByName("Image_2"):getChildByName("Text_1"):setString(TI18N("个人记录"))
    self.btn_close = main_container:getChildByName("btn_close")
    self.btn_sure = main_container:getChildByName("btn_sure")
    
    self.my_recont_scroll = main_container:getChildByName("my_recont_scroll")
    local view_size = self.my_recont_scroll:getContentSize()
    local setting = {
        item_class = TreasureMyServerItem,
        start_x = 2,
        space_x = 0,
        start_y = 0,
        space_y = 0,
        item_width = 606,
        item_height = 274,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.my_scrollview = CommonScrollViewLayout.new(self.my_recont_scroll, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, view_size, setting)
    self.my_scrollview:setSwallowTouches(false)
end
function TreasureMyServerWindow:openRootWnd()
    controll:sender25704()
end
function TreasureMyServerWindow:register_event()
    self:addGlobalEvent(FestivalActionEvent.Treasure_MyServer_Event, function(data)
        if data and data.logs then
            if next(data.logs) == nil then
                commonShowEmptyIcon(self.my_recont_scroll, true, {text = TI18N("暂无记录，努力参与吧~~~")})
            else
                self.my_scrollview:setData(data.logs)
            end
        end
    end)

	registerButtonEventListener(self.btn_sure, function()
		controll:openTreasureMyServerView(false)
	end,false, 2)
	registerButtonEventListener(self.btn_close, function()
		controll:openTreasureMyServerView(false)
	end,true, 2)
end
function TreasureMyServerWindow:close_callback()
	if self.my_scrollview then
        self.my_scrollview:DeleteMe()
        self.my_scrollview = nil
    end
	controll:openTreasureMyServerView(false)
end

------------------------------------------
-- 子项
TreasureMyServerItem = class("TreasureMyServerItem", function()
    return ccui.Widget:create()
end)

function TreasureMyServerItem:ctor()
	self.my_number_list = {}
	self:configUI()
end

function TreasureMyServerItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("festivalaction/treasure_my_server_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(606,274))
    local main_container = self.root_wnd:getChildByName("main_container")
    self.name = main_container:getChildByName("name")
    self.name:setString("")
    self.time = main_container:getChildByName("time")
    self.time:setString("")
    self.is_open_text = main_container:getChildByName("is_open_text")
    self.is_open_text:setString("")
    main_container:getChildByName("luckly_text"):setString(TI18N("幸运号码："))
    self.luckly_num = main_container:getChildByName("luckly_num")
    self.luckly_num:setString("")
    main_container:getChildByName("luckly_text_0"):setString(TI18N("个人参与人次："))
    self.my_join_num = main_container:getChildByName("my_join_num")
    self.my_join_num:setString("")

    self.join_num = createRichLabel(24, FestivalActionConst.ColorConst[1], cc.p(0, 0.5), cc.p(297, 142), nil, nil, 100)
	main_container:addChild(self.join_num)
	
    main_container:getChildByName("luckly_text_0_0"):setString(TI18N("我的号码："))
    self.open_spr = main_container:getChildByName("open_spr")
    self.open_spr:setVisible(false)
    self.no_open_spr = main_container:getChildByName("no_open_spr")
    self.no_open_spr:setVisible(false)

    local my_num_scroll = main_container:getChildByName("my_num_scroll")
    local view_size = my_num_scroll:getContentSize()
    local setting = {
        item_class = MyServerNumberItem,
        start_x = 0,
        space_x = -13,
        start_y = 0,
        space_y = 0,
        item_width = 100,
        item_height = 30,
        row = 1,
        col = 5,
        need_dynamic = true
    }
    self.my_number_scroll = CommonScrollViewLayout.new(my_num_scroll, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, view_size, setting)
    self.my_number_scroll:setSwallowTouches(false)

    self.goods_item = BackPackItem.new(nil,true,nil,0.8,false)
    main_container:addChild(self.goods_item)
    self.goods_item:setPosition(cc.p(63, 173))
end

function TreasureMyServerItem:setData(data)
    self.name:setString(data.award_name)

    --未开奖
    if data.time == 0 then
        if data.win_num == 0 then --活动期间未开奖
            self.is_open_text:setString(TI18N("未开奖"))
            self.luckly_num:setString("？？？")
            self.no_open_spr:setVisible(false)
            self.open_spr:setVisible(false)
        elseif data.win_num == 1 then --已退货
            self.is_open_text:setString(TI18N("未开奖"))
            self.luckly_num:setString("未达到最低开奖人数")
            self.no_open_spr:setVisible(true)
            self.open_spr:setVisible(false)
        end
        self.time:setString("")
    else --开奖
        if data.is_win == 0 then --未中奖
            self.time:setString(TimeTool.getYMDHMS(data.time))
        else --已中奖
            self.time:setString(TimeTool.getYMDHMS(data.time))
        end
        self.luckly_num:setString(data.win_num)
        self.is_open_text:setString(TI18N("已开奖"))
        self.no_open_spr:setVisible(data.is_win == 0)
        self.open_spr:setVisible(data.is_win == 1)
    end
    self.my_join_num:setString(#data.buy_nums)
    if self.my_number_scroll then
        self.my_number_scroll:setData(data.buy_nums,nil,nil,data.win_num)
    end

	if self.goods_item then
        if data.awards and data.awards[1] then
    		self.goods_item:setBaseData(data.awards[1].id, data.awards[1].num)
        end
	end
end

function TreasureMyServerItem:DeleteMe()
	if self.goods_item then 
       self.goods_item:DeleteMe()
       self.goods_item = nil
    end
    if self.my_number_scroll then
        self.my_number_scroll:DeleteMe()
        self.my_number_scroll = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end

--******************************
--我的号码子项
MyServerNumberItem = class("MyServerNumberItem", function()
    return ccui.Widget:create()
end)

function MyServerNumberItem:ctor()
    self:configNumberUI()
end

function MyServerNumberItem:configNumberUI()
    self:setContentSize(cc.size(100, 30))
end

function MyServerNumberItem:setExtendData(win_num)
    self.win_num = win_num
end
function MyServerNumberItem:setData(data)
    if not data then return end
    if not self.luckly_num then
        self.luckly_num = createLabel(22,FestivalActionConst.ColorConst[3],nil,0,15,"",self,nil, cc.p(0,0.5))
    end
    if data.num == self.win_num then
        self.luckly_num:setTextColor(FestivalActionConst.ColorConst[4])
    else
        self.luckly_num:setTextColor(FestivalActionConst.ColorConst[3])
    end
    self.luckly_num:setString(data.num)
end
function MyServerNumberItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
