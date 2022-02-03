-- --------------------------------------------------------------------
-- 新手训练营关卡信息
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-xx-xx
-- --------------------------------------------------------------------
local _controller = TrainingcampController:getInstance()
local _model = _controller:getModel()

TrainingcampTipsWindow =  TrainingcampTipsWindow or BaseClass(BaseView)

function TrainingcampTipsWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "trainingcamp/trainingcamp_tips_view"
    self.cache_list = {}
    self.is_csb_action = true
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("trainingcamp","trainingcamp"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_93"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_94"), type = ResourcesType.single },
	}
    
end

function TrainingcampTipsWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    self.container = self.root_wnd:getChildByName("container")
    self.scroll_view = self.container:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_width = self.scroll_view:getContentSize().width
    self.scroll_height = self.scroll_view:getContentSize().height
    self.win_title = self.container:getChildByName("win_title")
end

function TrainingcampTipsWindow:register_event()
    self.background:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                _controller:openTrainingcampTipsWindow(false)

                delayOnce(function()
                    GlobalEvent:getInstance():Fire(TrainingcampEvent.Show_Close_Effect_Event)
                    self:setVisible(false)
                    self:closeInternal()
                end, 16 / display.DEFAULT_FPS)
            end
        end
    )

end

function TrainingcampTipsWindow:openRootWnd(config)
    if not config then
        return
    end
    self.win_title:setString(config.name)
    self.max_height = 0
    self:setDataList(config.message)
end

function TrainingcampTipsWindow:setDataList(disc)
    local descArr= {}
    local index = string.find(disc, "&&")
    if index then
        descArr = string.split(disc, "&&")
    else
        descArr[1] = disc
    end

    self.render_list = descArr
    for i, v in ipairs(self.render_list) do
        delayRun(
            self.container, i / display.DEFAULT_FPS, function()
                self:createList(v)
            end
        )
    end
end

function TrainingcampTipsWindow:createList(data)
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

function TrainingcampTipsWindow:createTitleContent(data)
    if data == nil then return end
    local container = ccui.Widget:create()
    container:setAnchorPoint(cc.p(0, 1))
    container:setCascadeOpacityEnabled(true)
    
   local _height = 0
   local index = string.find(data, "img")
    if index then
        local bid = string.gsub(data, "img","")
        local res = PathTool.getPlistImgForDownLoad('bigbg/trainingcamp', 'trainingcamp_'..bid)
        local title_bg = createImage(container, res, self.scroll_width/2, 0, cc.p(0.5,1), false, 1, false)

        local _width = self.scroll_width - 8
        _height = title_bg:getContentSize().height
        container:setContentSize(cc.size(_width, _height))
        title_bg:setPositionY(_height - 8)
    else
        -- 重新矫正一下位置坐标
        local content = createRichLabel(20, 175, cc.p(0.5, 1), cc.p(492/2, 0), 5, nil, 480)
        content:setString(data)
        container:addChild(content)
        local _width = self.scroll_width - 8
        _height = content:getContentSize().height
        container:setContentSize(cc.size(_width, _height))
        content:setPositionY(_height - 8)
    end
    return container, _height
end

function TrainingcampTipsWindow:close_callback()
    self.container:stopAllActions()
    _controller:openTrainingcampTipsWindow(false)
end