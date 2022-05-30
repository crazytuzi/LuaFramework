-- --------------------------------------------------+
-- sdk辅助UI
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/

SdkView = class("SdkView", function()
    return ccui.Widget:create()
end)

function SdkView:ctor(parent)
	self.size = parent:getContentSize()
    self:setContentSize(self.size)
    parent:addChild(self)
    self:setPosition(cc.p(display.cx, 0))
    self:setAnchorPoint(cc.p(0.5,0))

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("login/login_sdk_view"))
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.confirm_btn = self.main_container:getChildByName("confirm_btn")
    self.notice_label = self.main_container:getChildByName("notice_label")
    self.notice_label:setTextAreaSize(cc.size(430, 130))

    local btn_label = self.cancel_btn:getChildByName("label") 
    if btn_label then
        btn_label:setString(TI18N("取消")) 
    end
    btn_label = self.confirm_btn:getChildByName("label") 
    if btn_label then
        btn_label:setString(TI18N("确定")) 
    end
end

function SdkView:show(msg, ok_label, ok_func, cancel_label, cancel_func)
    self.notice_label:setString(msg)
    -- if self.confirm_btn_label then
    --     self.confirm_btn_label:setString(ok_label)
    -- end
    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            ok_func()
            self:close()
        end
    end)
    if cancel_label then
        -- if self.cancel_btn_label then
        --     self.cancel_btn_label:setString(cancel_label)
        -- end
        self.cancel_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if cancel_func then cancel_func() end
                self:close()
            end
        end)
    else
        self.cancel_btn:setVisible(false)
        self.confirm_btn:setPositionX(self.main_container:getContentSize().width/2)
    end
end

function SdkView:close()
    if not tolua.isnull(self) then
        self:setVisible(false)
        self:removeFromParent()
    end
end
