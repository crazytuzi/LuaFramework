-- --------------------------------------------------------------------
-- 新手训练营完成所有提示信息
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-xx-xx
-- --------------------------------------------------------------------
local _controller = TrainingcampController:getInstance()
local _model = _controller:getModel()

TrainingcampAllfinishTipsWindow =  TrainingcampAllfinishTipsWindow or BaseClass(BaseView)

function TrainingcampAllfinishTipsWindow:__init()
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

function TrainingcampAllfinishTipsWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    self.container = self.root_wnd:getChildByName("container")
    self.scroll_view = self.container:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_view:setTouchEnabled(false)
    self.scroll_width = self.scroll_view:getContentSize().width
    self.scroll_height = self.scroll_view:getContentSize().height
    self.win_title = self.container:getChildByName("win_title")
end

function TrainingcampAllfinishTipsWindow:register_event()
    self.background:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self.is_exist_ui_end = false			
                playCloseSound()
                _controller:openTrainingcampAllfinishTipsWindow(false)
            end
        end
    )
end

function TrainingcampAllfinishTipsWindow:openRootWnd()
    self.max_height = 0
    self:setData()
end

function TrainingcampAllfinishTipsWindow:setData()
    local disc =  ""
    if Config.TrainingCampData.data_const.tips_content then
        disc = Config.TrainingCampData.data_const.tips_content.desc
    end

    if Config.TrainingCampData.data_const.tips_title then
        self.win_title:setString(Config.TrainingCampData.data_const.tips_title.desc)
    end
    
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

function TrainingcampAllfinishTipsWindow:createList(data)
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

function TrainingcampAllfinishTipsWindow:createTitleContent(data)
    if data == nil then return end
    local container = ccui.Widget:create()
    container:setAnchorPoint(cc.p(0, 1))
    container:setCascadeOpacityEnabled(true)
    
   local _height = 0
   local index = string.find(data, "img")
    if index then
        local bid = string.gsub(data, "img","")
        local res = PathTool.getResFrame('trainingcamp', 'txt_cn_trainingcamp_'..bid)
        local title_bg = createSprite(res, self.scroll_width/4*3, 0,container, cc.p(0.5,1),LOADTEXT_TYPE_PLIST)

        local _width = self.scroll_width - 8
        _height = title_bg:getContentSize().height
        container:setContentSize(cc.size(_width, _height))
        title_bg:setPositionY(_height - 150)
    else
        -- 重新矫正一下位置坐标
        local content = createRichLabel(22, 274, cc.p(0, 1), cc.p(0, 0), 30, nil, 480)
        content:setString("        "..data)
        container:addChild(content)
        local _width = self.scroll_width - 8
        _height = content:getContentSize().height
        container:setContentSize(cc.size(_width, _height))
        content:setPositionY(_height - 130)
    end
    return container, _height
end

function TrainingcampAllfinishTipsWindow:close_callback()
    self.container:stopAllActions()
    _controller:openTrainingcampAllfinishTipsWindow(false)
end