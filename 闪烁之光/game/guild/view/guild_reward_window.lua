-- --------------------------------------------------------------------

-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      奖励一览的总界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
GuildRewardWindow = GuildRewardWindow or BaseClass(BaseView)
local controller = GuildController:getInstance()
local string_format = string.format
function GuildRewardWindow:__init( ... )
   self.is_full_screen = false
    self.layout_name = "guild/guild_reward_window"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_scrollview = nil
end

function GuildRewardWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    local main_panel = self.main_container:getChildByName("main_panel")
    self.win_title = main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("奖励一览"))
    self.close_btn = main_panel:getChildByName("close_btn")

    local container = main_panel:getChildByName("container")
    self.scroll_size = container:getContentSize()
    local setting = {
        item_class = GuildRewardItem,      -- 单元类
        start_x = 4,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 599,               -- 单元的尺寸width
        item_height = 159,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(container, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top,self.scroll_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    
end

function GuildRewardWindow:register_event( ... )
    if self.background then
        self.background:addTouchEventListener(function(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                controller:openGuildRewardWindow(false)
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function (sender,event_type)
            customClickAction(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                controller:openGuildRewardWindow(false)
            end
        end)
    end
end

function GuildRewardWindow:openRootWnd()
    local list = Config.GuildQuestData.data_lev_data
    self.item_scrollview:setData(list)
end

function GuildRewardWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
   controller:openGuildRewardWindow(false)
end

--子项
GuildRewardItem = class("GuildRewardItem", function()
    return ccui.Widget:create()
end)

function GuildRewardItem:ctor()
    self.item_list = {}
    self:configUI()
end

function GuildRewardItem:configUI( )
    self.size = cc.size(599,159)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("guild/guild_reward_item")
    local root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(root_wnd)

    local container = root_wnd:getChildByName("container")
    self.goods = container:getChildByName("goods")
    self.goods:setScrollBarEnabled(false)
    self.desc_label = createRichLabel(26, cc.c4b(0x68,0x45,0x2A,0xff), cc.p(0, 0.5), cc.p(22,130),nil,nil,1000)
    container:addChild(self.desc_label)
end

function GuildRewardItem:setData( data )
    local str = string_format(TI18N("活跃到达 <div fontcolor=#249003>%d</div> 级领取"),data.lev)
    self.desc_label:setString(str)

    local total_width = BackPackItem.Width * #data.items * 0.8 + #data.items * 10
    local max_width = math.max(self.goods:getContentSize().width, total_width)
    self.goods:setInnerContainerSize(cc.size(max_width, self.goods:getContentSize().height))

    if total_width >= self.goods:getContentSize().width then
        self.goods:setTouchEnabled(true)
    else
        self.goods:setTouchEnabled(false)
    end
        
    for i,v in pairs(self.item_list) do
        v:setVisible(false)
    end

    for i=1, #data.items do
        if not self.item_list[i] then
            local item = BackPackItem.new(true,true,nil,0.8)
            item:setAnchorPoint(0, 0.5)
            item:setSwallowTouches(false)
            self.goods:addChild(item)
            self.item_list[i] = item
        end
        item = self.item_list[i]
        if item then
            item:setVisible(true)
            item:setPosition((i - 1)*(BackPackItem.Width*0.8+10), 45)
            item:setBaseData(data.items[i][1], data.items[i][2])
            item:setDefaultTip()
        end
    end

end

function GuildRewardItem:DeleteMe()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self:removeAllChildren()
end 