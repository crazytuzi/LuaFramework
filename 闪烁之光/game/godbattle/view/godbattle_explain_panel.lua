-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      众神战场规则说明标签
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GodBattleExplainPanel = GodBattleExplainPanel or BaseClass()

function GodBattleExplainPanel:__init(parent)
	self.is_init = false
	self.parent = parent
    self.cache_list = {}
    self.max_height = 0
	self:createRoorWnd()
	self:registerEvent()
end

function GodBattleExplainPanel:createRoorWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("godbattle/godbattle_explain_panel"))

    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.container = self.root_wnd:getChildByName("container")

    self.scroll_view = self.root_wnd:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_width = self.scroll_view:getContentSize().width
    self.scroll_height = self.scroll_view:getContentSize().height
end

function GodBattleExplainPanel:registerEvent()
end

function GodBattleExplainPanel:addToParent(status)
	if not tolua.isnull(self.root_wnd) then
		self.root_wnd:setVisible(status)
	end
	if status == true and self.is_init == false then
        self.is_init = true
        local config = Config.ZsWarData.data_explain 
        self:setDataList(config)
	end
end

function GodBattleExplainPanel:setDataList(list)
    self.render_list = list
    for i, v in ipairs(self.render_list) do
        delayRun(
            self.container, i / display.DEFAULT_FPS, function()
                self:createList(v)
            end
        )
    end
end

function GodBattleExplainPanel:createList(data)
    local container, height = self:createTitleContent(data)
    self.scroll_view:addChild(container)

    table.insert(self.cache_list, container)
    self.max_height = self.max_height + height + 30

    local max_height = math.max(self.max_height, self.scroll_height)
	self.scroll_view:setInnerContainerSize(cc.size(self.scroll_width, max_height))
    local off_y = 0
    for i,v in ipairs(self.cache_list) do
        v:setPosition(8, max_height-off_y)
        off_y = off_y + v:getContentSize().height + 30
    end
end

function GodBattleExplainPanel:createTitleContent(data)
    if data == nil then return end
    local container = ccui.Widget:create()
    container:setAnchorPoint(cc.p(0, 1))
    container:setCascadeOpacityEnabled(true)
    
   local _height = 0
    if data.title == " " or data.title == "" then
        local content = createRichLabel(24, 175, cc.p(0, 1), cc.p(0, 0), 5, nil, 605)
        content:setString(splitDataStr(data.desc))
        container:addChild(content)
        local _width = self.scroll_width - 8
        _height = content:getContentSize().height
        container:setContentSize(cc.size(_width, _height))
        content:setPositionY(_height - 8)
    else
        -- 重新矫正一下位置坐标
        local title_bg = createScale9Sprite(PathTool.getResFrame("common", "common_90025"), 0, 0, LOADTEXT_TYPE_PLIST, container)
        title_bg:setAnchorPoint(cc.p(0, 1))
        -- title_bg:setCapInsets(cc.rect(170, 20, 1, 1))
        title_bg:setContentSize(cc.size(617, 44))
        local title = createLabel(26, Config.ColorData.data_color4[175], nil, 5, title_bg:getContentSize().height * 0.5, data.title, title_bg, nil, cc.p(0, 0.5))
        local content = createRichLabel(24, 175, cc.p(0, 1), cc.p(0, 0), 5, nil, 605)
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

function GodBattleExplainPanel:__delete()
    doStopAllActions(self.container)
end 
