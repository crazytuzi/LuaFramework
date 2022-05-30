-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      实力提升面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
RoleUpgradeMainWindow = RoleUpgradeMainWindow or BaseClass(BaseView) 

local controller = RoleController:getInstance()

function RoleUpgradeMainWindow:__init()
	self.is_full_screen = false
	self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.win_type = WinType.Tips
	self.layout_name = "roleinfo/role_upgrade_main_window"
    self.off_space = 8
end

function RoleUpgradeMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setContentSize(cc.size(SCREEN_WIDTH, display.height))
    self.background:setSwallowTouches(false)

    self.container = self.root_wnd:getChildByName("container")
    self.scrollview = self.container:getChildByName("scrollview")
    self.scrollview_size = self.scrollview:getContentSize()
    self.scrollview:setScrollBarEnabled(false)
end

function RoleUpgradeMainWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            controller:openRoleUpgradeMainWindow(false)
        end
    end)
end

function RoleUpgradeMainWindow:openRootWnd(data)
    local node_pos = self.root_wnd:convertToNodeSpace(data)
    self.container:setPosition(node_pos.x+144, node_pos.y+75)

    local sum = 4
    local max_height = sum * 62 + (sum - 1) * self.off_space
    max_height = math.max(max_height, self.scrollview_size.height)
    self.scrollview:setInnerContainerSize(cc.size(self.scrollview_size.width, max_height))
    for i = 1, sum do
        local item = RoleUpgradeItem.new()
        local _x = self.scrollview_size.width * 0.5
        local _y = max_height - 31 - (i-1)*(62+self.off_space)
        item:setPosition(_x, _y)
        self.scrollview:addChild(item)
    end
end

function RoleUpgradeMainWindow:close_callback()
    controller:openRoleUpgradeMainWindow(false)
end



RoleUpgradeItem = class("RoleUpgradeItem", function()
	return ccui.Layout:create()
end)

function RoleUpgradeItem:ctor()
    self.size = cc.size(218, 62)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self.size)
    self:setTouchEnabled(true)

    self.background = createSprite(PathTool.getResFrame("roleinfo","roleinfo_1"), 109, 31, self, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST)

    self.close_btn = createImage(self, PathTool.getResFrame("roleinfo","roleinfo_2"), 192, 31, cc.p(0.5,0.5), true)
    self.close_btn:setTouchEnabled(true)

    self:registerEvent()
end

function RoleUpgradeItem:registerEvent()
    self:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then

        end
    end)

    self.close_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            
        end
    end)
end

function RoleUpgradeItem:setData(data)
end

function RoleUpgradeItem:DeleteMe()
end