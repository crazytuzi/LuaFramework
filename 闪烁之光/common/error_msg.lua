-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/8/25
-- Time: 13:55
-- 文件功能：专门显示出错信息的界面
ErrorMessage = ErrorMessage or BaseClass()

function ErrorMessage:getInstance()
    if not self.init_view then
        self.init_view = true
        self:initCallBack()
    end
    return self
end

function ErrorMessage:initCallBack()
    self:openCallBack()
    self:registerCallBack()
end

function ErrorMessage:openCallBack()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("common/error_message"))
    self.root_wnd:retain()
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(cc.p(SCREEN_WIDTH/2, SCREEN_HEIGHT/2))

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.scroll_view = self.main_panel:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
end

function ErrorMessage:setErrorMsg(msg, title)
    self.msg = msg 

    local font_size = 16
    if title then 
        self.scroll_view:setTouchEnabled(false)
    end
    if self.error_txt ~= nil then
        if self.error_txt:getParent() ~= nil then
            self.error_txt:removeFromParent()
        end
        self.error_txt = nil
    end
    self.error_txt = self:recoutTextFieldSize(msg, 570, font_size)
    local size = self.error_txt:getContentSize()
    self.error_txt:setPosition(cc.p(10, size.height - 10))
    local scroll_size = self.scroll_view:getContentSize()
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(scroll_size.width-10, size.height))
    layout:addChild(self.error_txt)
    local max_height = math.max(size.height, scroll_size.height) - 30
    local layout2 = ccui.Layout:create()
    layout2:setContentSize(cc.size(scroll_size.width-10, max_height))
    layout:setAnchorPoint(cc.p(0, 1))
    layout:setPosition(cc.p(0, max_height))
    layout2:addChild(layout)
    self.scroll_view:setInnerContainerSize(cc.size(scroll_size.width, max_height))
    self.scroll_view:addChild(layout2)
end


function ErrorMessage:registerCallBack()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:close()
        end
    end)
end

-- 从新计算文本的大小
function ErrorMessage:recoutTextFieldSize(str_label, width, font_size)
    local label = createWithSystemFont(str_label, DEFAULT_FONT, font_size)
    label:setAnchorPoint(cc.p(0, 1))
    label:setTextColor(Config.ColorData.data_color4[63])
    if width ~= nil then
        local label_width = label:getContentSize().width
        local label_height = label:getContentSize().height
        if label_width > width then
            local line_num = math.ceil(label_width/width)
            label:setContentSize(cc.size(width, label_height*line_num))
            label:setWidth(width)
            label:setHeight(label_height*line_num)
        end
    end
    return label
end

function ErrorMessage.show(msg, title)
    local error_msg = ErrorMessage:getInstance()
    if error_msg.msg ~= nil then return end
    error_msg:open()
    error_msg:setErrorMsg(msg, title)
    return error_msg
end

function ErrorMessage:open()
    if self.root_wnd and self.parent == nil then
        self.parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
        self.parent:addChild(self.root_wnd)
    end
    self.root_wnd:setVisible(true)
end

function ErrorMessage:close()
    if self.close_callback then 
        self.close_callback()
        self.close_callback = nil 
    end
    self.msg = nil
    self.root_wnd:setVisible(false)
end

-- 设置关闭回调
function ErrorMessage:setCloseCallBack(close_callback)
    self.close_callback = close_callback
end
