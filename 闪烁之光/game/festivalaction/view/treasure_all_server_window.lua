--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 一元夺宝近期获奖全记录
-- @DateTime:    2019-05-16 17:49:23
-- *******************************
TreasureAllServerWindow = TreasureAllServerWindow or BaseClass(BaseView)

local controll = FestivalActionController:getInstance()
local string_format = string.format
function TreasureAllServerWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "festivalaction/treasure_all_server_window"
end

function TreasureAllServerWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
    main_container:getChildByName("Image_2"):getChildByName("Text_1"):setString(TI18N("全服记录"))
    self.btn_close = main_container:getChildByName("btn_close")
    self.recont_srcoll = main_container:getChildByName("recont_srcoll")
    local view_size = self.recont_srcoll:getContentSize()
    local setting = {
        item_class = TreasureAllServerItem,
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 3,
        item_width = 640,
        item_height = 96,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.record_scrollview = CommonScrollViewLayout.new(self.recont_srcoll, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, view_size, setting)
    self.record_scrollview:setSwallowTouches(false)
end
function TreasureAllServerWindow:openRootWnd()
    controll:sender25703()
end
function TreasureAllServerWindow:register_event()
    self:addGlobalEvent(FestivalActionEvent.Treasure_AllServer_Event, function(data)
        if data and data.logs then
            if next(data.logs) == nil then
                commonShowEmptyIcon(self.recont_srcoll, true, {text = TI18N("暂无记录，努力参与吧~~~")})
            else
                self.record_scrollview:setData(data.logs)           
            end
        end
    end)
	registerButtonEventListener(self.background, function()
		controll:openTreasureAllServerView(false)
	end,false, 2)
	registerButtonEventListener(self.btn_close, function()
		controll:openTreasureAllServerView(false)
	end,true, 2)
end
function TreasureAllServerWindow:close_callback()
	if self.record_scrollview then
        self.record_scrollview:DeleteMe()
        self.record_scrollview = nil
    end
	controll:openTreasureAllServerView(false)
end

------------------------------------------
-- 子项
TreasureAllServerItem = class("TreasureAllServerItem", function()
    return ccui.Widget:create()
end)

function TreasureAllServerItem:ctor()
	self:configUI()
end

function TreasureAllServerItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("festivalaction/treasure_all_server_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(640,96))
    local main_container = self.root_wnd:getChildByName("main_container")
    self.time = main_container:getChildByName("time")
    self.time:setString("")
    self.record_get_text = createRichLabel(26, FestivalActionConst.ColorConst[1], cc.p(0, 0.5), cc.p(27, 74), nil, nil, 600)
	main_container:addChild(self.record_get_text)
	
	self.record_count_text = createRichLabel(22, FestivalActionConst.ColorConst[1], cc.p(0, 0.5), cc.p(27, 30), nil, nil, 400)
	main_container:addChild(self.record_count_text)
end

function TreasureAllServerItem:setData(data)
    local num = 0
    if data.awards and data.awards[1] then
        num = data.awards[1].num or 0
    end
    local txt_str = string_format(TI18N("恭喜<div fontcolor=249003> %s </div>夺得 <div fontcolor=d95014>%sx%d</div>"), data.win_name, data.award_name, num)
    self.record_get_text:setString(txt_str)
    local txt_count_str = string_format(TI18N("参与<div fontcolor=249003> %d </div>人次 总共<div fontcolor=d95014> %d </div> 人次"), data.join_num, data.max_num)
    self.record_count_text:setString(txt_count_str)
    self.time:setString(TimeTool.getYMDHMS(data.time))
end
function TreasureAllServerItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end
