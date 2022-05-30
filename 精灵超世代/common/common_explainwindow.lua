-- --------------------------------------------------------------------
-- 通用的规则说明面板,只需要传固定格式的就行了
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
CommonExplainWindow =  CommonExplainWindow or BaseClass(BaseView)

function CommonExplainWindow:__init(ctrl,title_str,summon)
    self.ctrl = ctrl
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "common/common_explain_view"
    self.cache_list = {}
    self.title_str = title_str or TI18N("规则")
    self.is_summon = summon or nil --对召唤做处理
end

function CommonExplainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    -- self:playEnterAnimatianByObj(self.container)
    self.close_btn = self.container:getChildByName("close_btn")
    self.scroll_view = self.container:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_width = self.scroll_view:getContentSize().width
    self.scroll_height = self.scroll_view:getContentSize().height
    self.win_title = self.container:getChildByName("win_title")
    self.win_title:setString(self.title_str)
end

function CommonExplainWindow:register_event()
    self.background:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self.ctrl:openCommonExplainView(false)
            end
        end
    )

    self.close_btn:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self.ctrl:openCommonExplainView(false)
            end
        end
    )
end

function CommonExplainWindow:openRootWnd(config)
    self.max_height = 0
    self:setDataList(config)
end

function CommonExplainWindow:setDataList(list)
    self.render_list = list
    for i, v in ipairs(self.render_list) do
        delayRun(
            self.container, i / display.DEFAULT_FPS, function()
                self:createList(v)
            end
        )
    end
end

function CommonExplainWindow:createList(data)
    local container, height = self:createTitleContent(data)
    self.scroll_view:addChild(container)

    table.insert(self.cache_list, container)
    self.max_height = self.max_height + height + 30

    local max_height = math.max(self.max_height, self.scroll_height)
	self.scroll_view:setInnerContainerSize(cc.size(self.scroll_width, max_height))
    local off_y = 0
    for i,v in ipairs(self.cache_list) do
        v:setPosition(0, max_height-off_y)
        off_y = off_y + v:getContentSize().height + 30
    end

end

function CommonExplainWindow:createTitleContent(data)
    if data == nil then return end
    local container = ccui.Widget:create()
    container:setAnchorPoint(cc.p(0, 1))
    container:setCascadeOpacityEnabled(true)
    
   local _height = 0
    if data.title == " " or data.title == "" then
        local content = createRichLabel(22, 175, cc.p(0, 1), cc.p(0, 0), 5, nil, 605)
        content:setString(splitDataStr(data.desc))
        container:addChild(content)
        local _width = self.scroll_width - 8
        _height = content:getContentSize().height
        container:setContentSize(cc.size(_width, _height))
        content:setPositionY(_height - 8)
    else
        -- 重新矫正一下位置坐标
        local title_bg = createScale9Sprite(PathTool.getResFrame("common", "common_90003"), 0, 0, LOADTEXT_TYPE_PLIST, container)
        title_bg:setAnchorPoint(cc.p(0, 1))
        title_bg:setContentSize(cc.size(617, 42))
        title_bg:setCapInsets(cc.rect(15, 1, 1, 1))
        
        --目前只对召唤做处理
        if self.is_summon and data.id and data.id >= 2 and data.id <= 5 then
            local detail_bg = createImage(title_bg, PathTool.getResFrame("common", "common_1093"), 580, 21, cc.p(0.5,0.5), true, 1, true)
            detail_bg:setContentSize(cc.size(40, 40))
            detail_bg:setScale(0.8)
            detail_bg:setTouchEnabled(true)
            registerButtonEventListener(detail_bg, function()
                SeerpalaceController:getInstance():openSeerpalacePreviewWindow(true, data.id, 1 )
            end)
            local title = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0.5,0.5), cc.p(-55, detail_bg:getContentSize().height * 0.5))
            title:setString(string.format("<div href=xxx>%s</div>", TI18N("查看详情")))
            detail_bg:addChild(title)
            title:addTouchLinkListener(function(type, value, sender, pos)
                SeerpalaceController:getInstance():openSeerpalacePreviewWindow(true, data.id, 1 )
            end, { "click", "href" })
        end

        local title = createLabel(22, Config.ColorData.data_new_color4[6], nil, 25, title_bg:getContentSize().height * 0.5, data.title, title_bg, nil, cc.p(0, 0.5))
        local content = createRichLabel(22, 175, cc.p(0, 1), cc.p(25, 0), 5, nil, 580)
        content:setString(splitDataStr(data.desc))
        container:addChild(content)
        local _width = self.scroll_width - 8
        _height = title_bg:getContentSize().height + content:getContentSize().height
        container:setContentSize(cc.size(_width, _height))
        title_bg:setPositionY(_height - 8)
        content:setPositionY(title_bg:getPositionY() - title_bg:getContentSize().height - 8)
    end
    return container, _height
end

function CommonExplainWindow:close_callback()
    self.container:stopAllActions()
    self.ctrl:openCommonExplainView(false)
end