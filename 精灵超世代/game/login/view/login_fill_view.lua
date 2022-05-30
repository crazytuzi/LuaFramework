-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      适配的地图
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
FillView = class("FillView", function()
	return ccui.Widget:create()
end) 

function FillView:ctor()
	self.size = cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
	self:setContentSize(self.size)
    self:setAnchorPoint(0.5, 0.5)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("login/login_fill_view"))
	self:addChild(self.root_wnd)

    self.left_panel = self.root_wnd:getChildByName("left_panel")
    self.right_panel = self.root_wnd:getChildByName("right_panel")

    local extend_width = (display.width - SCREEN_WIDTH) * 0.5

    -- 特殊处理--4.4
    if needMourning() then
	    setChildUnEnabled(true, self.left_panel, cc.c4b(0xff,0xff,0xff,0xff))
        setChildUnEnabled(true, self.right_panel, cc.c4b(0xff,0xff,0xff,0xff))
    end

    self.left_panel:setContentSize(cc.size(extend_width, display.height))
    self.right_panel:setContentSize(cc.size(extend_width, display.height))
end

 