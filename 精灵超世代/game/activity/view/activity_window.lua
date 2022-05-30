--[[
活动主界面
--]]
ActivityWindow = ActivityWindow or BaseClass(BaseView)

local table_sort = table.sort
local roleVo = RoleController:getInstance():getRoleVo()
local controller = ActivityController:getInstance()
function ActivityWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full 
    
    self.title_str = TI18N("限时活动")
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("activity", "activity"), type = ResourcesType.plist}
    }
end

function ActivityWindow:open_callback()
    self.activityRoot = createCSBNote(PathTool.getTargetCSB("activity/activity_window"))
    self.activityRoot:setPosition(5,-26)
    self.container:addChild(self.activityRoot)
    self._main_container = self.activityRoot:getChildByName("main_container")
    self._scoreView = self._main_container:getChildByName("scoreView")
    local scroll_view_size = self._scoreView:getContentSize()

    local setting = {
        item_class = ActivityItem,      -- 单元类
        start_x = 7.5,                  -- 第一个单元的X起点
        space_x = 6,                    -- x方向的间隔
        start_y = 3,                    -- 第一个单元的Y起点
        space_y = 0,                    -- y方向的间隔
        item_width = 605,               -- 单元的尺寸width
        item_height = 165,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        delay = 2
    }
    self.itemScrollview = CommonScrollViewLayout.new(self._scoreView, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function ActivityWindow:register_event()
    self:addGlobalEvent(ActivityEvent.EscortCount, function()
        if self.itemScrollview then
            local item_list = self.itemScrollview:getItemList()
            if item_list then
                for k,item in pairs(item_list) do
                    item:changeEscortCount()
                end
            end
        end
    end)
    if roleVo then
        self:addGlobalEvent(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key == "lev" then
                if self.itemScrollview and next(self.dataInfo) ~= nil then
                    self.itemScrollview:setData(self.dataInfo)
                end
            end
        end)
    end
end

function ActivityWindow:openRootWnd()
end

function ActivityWindow:updateItemListRedStatus()
    local item_list = self.itemScrollview:getItemList()
    if item_list then
        for k,item in pairs(item_list) do
            item:updateRedStatus()
        end
    end
end

function ActivityWindow:close_callback()
    self.build_vo = nil
    if self.itemScrollview then
        self.itemScrollview:DeleteMe()
        self.itemScrollview = nil
    end
    controller:openActivityView(false)
end