--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-10 20:58:15
-- @description    : 
		-- 基金奖励预览界面
---------------------------------
ActionFundAwardWindow = ActionFundAwardWindow or BaseClass(BaseView)

local _controller = ActionController:getInstance() 

function ActionFundAwardWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "action/action_fund_award_window"

end

function ActionFundAwardWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
	local win_title = self.container:getChildByName("win_title")
	win_title:setString(TI18N("奖励预览"))

	local list_panel = self.container:getChildByName("list_panel")
	local scroll_size = list_panel:getContentSize()
	local setting = {
        item_class = FuncAwardItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 4,                    -- x方向的间隔
        start_y = 15,                    -- 第一个单元的Y起点
        space_y = 25,                   -- y方向的间隔
        item_width = 115,               -- 单元的尺寸width
        item_height = 129,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 5,                         -- 列数，作用于垂直滚动类型
        once_num = 5,
    }
    self.item_scrollview = CommonScrollViewLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_size, setting)
end

function ActionFundAwardWindow:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)

end

function ActionFundAwardWindow:_onClickCloseBtn(  )
	_controller:openActionFundAwardWindow(false)
end

function ActionFundAwardWindow:openRootWnd( group_id, fund_id )
	local award_config = Config.MonthFundData.data_fund_award[group_id] or {}

	local award_data = {}
	for day,award in ipairs(award_config) do
		local day_award = {}
		day_award.day = day
		day_award.award = award
		day_award.fund_id = fund_id
		table.insert(award_data, day_award)
	end
	self.item_scrollview:setData(award_data)
end

function ActionFundAwardWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openActionFundAwardWindow(false)
end

----------------------@ 子项
FuncAwardItem = class("FuncAwardItem", function()
    return ccui.Widget:create()
end)

function FuncAwardItem:ctor()
	self:configUI()
	self:register_event()
end

function FuncAwardItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_fund_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(115, 129))
    self:setAnchorPoint(0,0)

    self.container = self.root_wnd:getChildByName("container")

    local image_bg = self.container:getChildByName("image_bg")
    image_bg:loadTexture(PathTool.getResFrame("actionfund","actionfund_1001"), LOADTEXT_TYPE_PLIST)
    self.txt_time = self.container:getChildByName("txt_time")
    self.txt_time:setTextColor(Config.ColorData.data_new_color4[1])
end

function FuncAwardItem:register_event(  )
	
end

function FuncAwardItem:setData( data )
	if not data then return end

    self.txt_time:setString(string.format(TI18N("累计%d天"), data.day or 1))

    local bid = data.award[1][1]
    local num = data.award[1][2]
    if not self.item_node then
        self.item_node = BackPackItem.new(false, true, false, 0.6, false, true, false)
        self.item_node:setDefaultTip(true,false)
        local container_size = self.container:getContentSize()
        self.item_node:setPosition(cc.p(container_size.width/2, 88))
        self.container:addChild(self.item_node)
    end
    self.item_node:setBaseData(bid, num)
end

function FuncAwardItem:DeleteMe(  )
    if self.item_node then
        self.item_node:DeleteMe()
        self.item_node = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end