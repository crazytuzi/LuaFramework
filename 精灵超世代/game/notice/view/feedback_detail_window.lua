-- --------------------------------------------------------------------
-- 
-- 
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-1-4
-- --------------------------------------------------------------------
FeedbackDetailWindow = FeedbackDetailWindow or BaseClass(BaseView)

local _controller = NoticeController:getInstance()
function FeedbackDetailWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "notice/feedback_detail_window"
    self.win_type = WinType.Big
    self.is_full_screen = true
    self.title_height = 0
    self.title = ""
     self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg","pattern/pattern_3"), type = ResourcesType.single},
    }
    self.cache_list = {}
    self.cache_list_2 = {}
    self.choose_star_list = {}
    self.star = {}
    self.choose_star = 0
    self.txt_title = TI18N("当前状态：")
    self.text_info = {
            TI18N("已提交"),TI18N("已回复"), TI18N("未评价"), TI18N("已完成"), TI18N("已完成"),
        }
    self.is_shrink = false
    self.container_list_2 = {}
    self.container_list_1 = {}
    self.is_first_1 = true
end

function FeedbackDetailWindow:open_callback()
    local bg = self.root_wnd:getChildByName("backpanel")
    bg:setScale(display.getMaxScale())
    self.background = bg:getChildByName("background")
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.top_panel = self.main_panel:getChildByName("top_panel")
    self.top_panel:getChildByName("title_label"):setString(TI18N("问题详情"))

    local res = PathTool.getPlistImgForDownLoad("bigbg","pattern/pattern_3")  --底部花纹
    if res ~= nil then
        local pattern_1 = createSprite(res, self.main_panel:getContentSize().width/2, 25, self.main_panel, cc.p(0.5,0.5),LOADTEXT_TYPE)
        pattern_1:setScaleX(0.85)
    end
    self.main_container = self.main_panel:getChildByName("main_container")
    self.layout_quest = self.main_container:getChildByName("layout_quest")  --问题内容区
    self.quest_title_bg = self.layout_quest:getChildByName("quest_title_bg")
    self.quest_title_desc = self.quest_title_bg:getChildByName("quest_title_desc")
    self.btn_quest_release = self.quest_title_bg:getChildByName("btn_quest_release")
    self.btn_quest_release:setVisible(false)
    self.layout_quest_content = self.layout_quest:getChildByName("layout_quest_content")
    self.quest_scroll = self.layout_quest:getChildByName("quest_scroll")
    self.quest_scroll:setScrollBarEnabled(false)
    self.quest_scroll_size = self.quest_scroll:getContentSize()

    self.layout_reply = self.main_container:getChildByName("layout_reply") --回复内容区
    self.reply_title_bg = self.layout_reply:getChildByName("reply_title_bg")
    self.reply_title_desc = self.reply_title_bg:getChildByName("reply_title_desc")
    self.reply_title_desc:setString(TI18N("客服回复："))
    self.reply_scroll = self.layout_reply:getChildByName("reply_scrol")
    self.reply_scroll:setScrollBarEnabled(false)
    self.reply_scroll:setPositionY(400)
    self.reply_scroll_size = self.reply_scroll:getContentSize()
    
    self.txt_first_label = self.layout_reply:getChildByName("txt_first_label")
    self.txt_first_label:setVisible(false)
    --self.txt_first_label:setString(TI18N("      亲爱的冒险者大人：您的问题已经成功提交，客服\n将在接到消息后1~2个工作日内给您反馈，请您耐心\n等待~"))
    self.layout_reply_content = self.layout_reply:getChildByName("layout_reply_content")

    self.layout_continue_reply = self.main_container:getChildByName("layout_continue_reply") --追问内容区
    self.layout_continue_reply:setPositionY(325)
    self.continue_reply_title_bg = self.layout_continue_reply:getChildByName("continue_reply_title_bg")
    self.continue_scroll = self.continue_reply_title_bg:getChildByName("continue_scroll")
    self.continue_scroll:setScrollBarEnabled(false)
    self.continue_reply_title_desc = self.layout_continue_reply:getChildByName("continue_reply_title_desc")
    self.continue_reply_title_desc:setString(TI18N("继续提问："))

    self.btn_continue = self.layout_continue_reply:getChildByName("btn_continue")
    self.btn_continue_label = self.btn_continue:getChildByName("btn_continue_label")
    self.btn_continue_label:setString(TI18N("继续提问"))

    self.btn_ok = self.layout_continue_reply:getChildByName("btn_ok")
    self.btn_ok_label = self.btn_ok:getChildByName("btn_ok_label")
    self.btn_ok_label:setString(TI18N("继续提交"))
    self.btn_ok:setVisible(false)

    self.btn_finish = self.layout_continue_reply:getChildByName("btn_finish")
    self.btn_finish_label = self.btn_finish:getChildByName("btn_finish_label")
    self.btn_finish_label:setString(TI18N("已解决"))

    self.btn_cancel = self.layout_continue_reply:getChildByName("btn_cancel")
    self.btn_cancel_label = self.btn_cancel:getChildByName("btn_cancel_label")
    self.btn_cancel_label:setString(TI18N("取消"))
    self.btn_cancel:setVisible(false)

    self.layout_evaluate = self.main_container:getChildByName("layout_evaluate") --评价内容区
    self.txt_evaluate = self.layout_evaluate:getChildByName("txt_evaluate") --评价内容区
    self.txt_evaluate:setString(TI18N("对本次服务进行评价"))
    self.layout_star = self.layout_evaluate:getChildByName("layout_star") --评价内容区

    for i=1,5 do 
        local star_shadow = self.layout_star:getChildByName("shadow_star_"..i)
        star_shadow:setVisible(true)
        local star = self.layout_star:getChildByName("star_"..i)
        star_shadow:setTouchEnabled(true)
        star:setVisible(false)
        self.choose_star_list[i] = star_shadow
        self.choose_star_list[i].index = i
        self.star[i] = star
    end


    self.layout_continue_reply:setVisible(false)
    self.layout_evaluate:setVisible(false)

    self.txt_cur_status = self.main_container:getChildByName("txt_cur_status") --状态及时间
    self.txt_cur_status:setString(TI18N("已提交"))

    self.txt_time_evaluate = self.main_container:getChildByName("txt_time_evaluate") --状态及时间
    self.txt_time_evaluate:setString("2020-01-01")

    self.txt_time_finish = self.main_container:getChildByName("txt_time_finish") --状态及时间
    self.txt_time_finish:setString("2020-01-01")

    self.txt_time_commit = self.main_container:getChildByName("txt_time_commit") --状态及时间
    self.txt_time_commit:setString("2020-01-01")

    self:createProblemContentBox()
end

function FeedbackDetailWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            _controller:openFeedbackDetailWindow(false)
        end
    end)

    self.btn_quest_release:addTouchEventListener(function(sender, event_type)   
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:shrinkQuestScroll()
        end
    end)

    if self.background then
        registerButtonEventListener(self.background, function()
            _controller:openFeedbackDetailWindow(false)
            
         end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    end

    if self.btn_continue then
        registerButtonEventListener(self.btn_continue, function()
            self.btn_continue:setVisible(false)
            self.btn_ok:setVisible(true)
            self.btn_finish:setVisible(false)
            self.btn_cancel:setVisible(true)
            self:setSolveState(1)
            
         end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    end

    if self.btn_ok then
        registerButtonEventListener(self.btn_ok, function()
            _controller:sender10810(4, self.title_str, self.quest_content_str, "", "", "", self.question_id)
            
         end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    end


    if self.btn_finish then  --点击解决
        registerButtonEventListener(self.btn_finish, function() 
            _controller:sender10811(self.question_id, 0)
             end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    end

    if self.btn_cancel then
        registerButtonEventListener(self.btn_cancel, function()
            self:setSolveState(2)
         end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    end

    self:addGlobalEvent(NoticeEvent.Feedback_Evaluate_Success_Event, function(data) --评价成功
        if data == nil then return end
        if data.code == 1 then
            message(data.msg)
        end
    end)

    self:addGlobalEvent(NoticeEvent.Feedback_Success_Event, function(data) --追问
        if data == nil then return end

        if data.code == 1 then
            self:setSolveState(2)
            message(data.msg)
            self.problem_inputBox:setText("")
        end
    end)




    self:addGlobalEvent(NoticeEvent.All_Question_Info_List_Event, function()
        self:RemoveAll()
        self:setTraceDataList() --问题列表
        self:createAnswerList() --回复列表
        self:setTime()
    end)

    for k, object in pairs(self.choose_star_list) do  --评价
        self.choose_star_list[k]:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:setStarStatus(k)
                _controller:sender10811(self.question_id, tonumber(k))
            end
        end)
    end
end

function FeedbackDetailWindow:shrinkQuestScroll( ... )
    -- self.is_shrink = not self.is_shrink
    -- self.layout_quest:setContentSize(cc.size(600,500))
    -- self.quest_title_bg:setPositionY(self.layout_quest:getContentSize().height)
    -- self.quest_scroll:setPositionY(self.layout_quest:getContentSize().height - 45)
    -- self.quest_scroll:setContentSize(cc.size(600,self.layout_quest:getContentSize().height - 45))
    -- self.quest_scroll_size = self.quest_scroll:getContentSize()

end



function FeedbackDetailWindow:RemoveAll( ... )
    self.answer_list = {}
    self.render_list = {}
    self.cache_list  = {}
    self.cache_list_2 = {}
    self.reply_scroll:removeAllChildren()
    self.quest_scroll:removeAllChildren()
    -- body
end

function FeedbackDetailWindow:setTime()
    local time_data = _controller:getModel():getTimeData()
    self.txt_time_commit:setString( TI18N("提交时间：") .. TimeTool.getYMDHMS(time_data.start_time) )
    self.txt_time_finish:setString( TI18N("完成时间：") .. TimeTool.getYMDHMS(time_data.finish_time) )
    self.txt_cur_status:setString( TI18N("当前状态：") .. self.text_info[time_data.state])
    self.txt_time_evaluate:setString( TI18N("评价时间：")..TimeTool.getYMDHMS(time_data.score_time) )
    self:setTimeOpacityState(time_data.state)
    if time_data.state == 5 then
        self.txt_first_label:setVisible(true)
        self.txt_first_label:setString(TI18N("         亲爱的冒险者大人：您的问题已经为您解答，记\n得查看哟，系统将自动为您关闭工单，如有疑问可以\n再次联系小客服反馈哟~"))
        self.reply_scroll:setPositionY(335)
    end
    self:setLayoutStatus(time_data.state)
end

function FeedbackDetailWindow:setTimeOpacityState(time_color_status)  --设置文本颜色和位置及透明度
    local time_color = time_color_status or 1
    if time_color == 1 or time_color == 2 then  --已提交 ，已回复
        self.txt_time_commit:setVisible(true)
        self.txt_time_commit:setPositionY(80)

        self.txt_time_finish:setVisible(false)
        self.txt_time_evaluate:setVisible(false)

    elseif time_color == 3 then --未评价
        self.txt_time_finish:setVisible(false)

        self.txt_time_evaluate:setVisible(true)
        self.txt_time_evaluate:setPositionY(80)

        self.txt_time_commit:setVisible(true)
        self.txt_time_commit:setOpacity(178)
        self.txt_time_commit:setPositionY(50)

    elseif time_color == 4 or time_color == 5 then --已解决(已经评价) 
        self.txt_time_commit:setVisible(true)
        self.txt_time_commit:setOpacity(178)
        self.txt_time_commit:setPositionY(20)

        self.txt_time_finish:setVisible(true)
        self.txt_time_finish:setOpacity(178)
        self.txt_time_finish:setPositionY(50)

        self.txt_time_evaluate:setPositionY(80)
        self.txt_time_evaluate:setOpacity(255)
        self.txt_time_evaluate:setVisible(true)
    end
end

function FeedbackDetailWindow:setStarStatus(index)
    local index = index or 1
    for i=1,index do 
        self.star[i]:setVisible(true)
    end
end

--追问内容输入
function FeedbackDetailWindow:createProblemContentBox() -- 问题描述
    local res = PathTool.getResFrame("common","common_99998")
    if not self.problem_inputBox then
        self.problem_inputBox = createEditBox(self.continue_scroll, res, cc.size(533,90), Config.ColorData.data_color3[274], 24, cc.c3b(0x8c,0x8c,0x8b), 24, TI18N("请进一步描述您的问题,(不少于10字)"), cc.p(0,300), 150, LOADTEXT_TYPE_PLIST)
    end
    self.problem_inputBox:setAnchorPoint(cc.p(0,1))
        local function editTitleBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_title then  
                self.begin_change_title = false
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.quest_content_str then
                    if StringUtil.SubStringGetTotalIndex(str) <= 10 then
                        message(TI18N("内容长度不符合要求"))
                        self.problem_inputBox:setText("")
                        self.quest_content_str = ""
                    else
                        self.problem_inputBox:setText(str)
                        self.quest_content_str = str
                    end
                end 
            end
        elseif strEventName == "began" then
            if not self.begin_change_title then
                self.begin_change_title = true
            end
        elseif strEventName == "changed" then

        end
    end
    self.problem_inputBox:registerScriptEditBoxHandler(editTitleBoxTextEventHandle) 
end

function FeedbackDetailWindow:createAnswerList(  )
    self.answer_list = _controller:getModel():getAnswerContentData()
    -- if self.answer_list and #self.answer_list > 0 and #self.answer_list == #self.cache_list_2 then 
    --     return
    -- else
    --     self.cache_list_2 = {}
    --     self.reply_scroll:removeAllChildren()
    -- end
    if self.answer_list ~= nil and next(self.answer_list) ~= nil then
        for i, v in ipairs(self.answer_list) do
            delayRun(
                self.reply_scroll, i / display.DEFAULT_FPS, function()
                    self:createList_2(v)
                end)
        end
    end
end

function FeedbackDetailWindow:setTraceDataList()
    self.render_list = _controller:getModel():getTraceContentData()
    -- if #self.render_list > 0 and #self.render_list == #self.cache_list then 
    --     return
    -- else
    --     self.cache_list = {}
    --     self.quest_scroll:removeAllChildren()
    -- end
    for i, v in ipairs(self.render_list) do
        delayRun(
            self.quest_scroll, i / display.DEFAULT_FPS, function()
                self:createList_1(v)
            end
        )
    end
end


--创建回复列表
function FeedbackDetailWindow:createList_2(data)
   
    local container, height = self:createTitleContent_2(data)
    self.reply_scroll:addChild(container)

    table.insert(self.cache_list_2, container)
    self.max_height_reply = self.max_height_reply + height + 30

    local max_height_reply = math.max(self.max_height_reply, self.reply_scroll_size.height)
    self.reply_scroll:setInnerContainerSize(cc.size(self.reply_scroll_size.width, max_height_reply))
    local off_y = 0
    for i,v in ipairs(self.cache_list_2) do
        v:setPosition(0, max_height_reply-off_y)
        if i == 1 then
            v:setOpacity(255)
            v:setPositionX(-20)
        else
            v:setOpacity(178)
        end
        off_y = off_y + v:getContentSize().height 
    end

end

function FeedbackDetailWindow:createTitleContent_2(data)
    if data == nil then return end
    local container = ccui.Widget:create()
    container:setAnchorPoint(cc.p(0, 1))
    container:setCascadeOpacityEnabled(true)
    
    local _height = 0
    local txt_desc_tips = createLabel(13, cc.c3b(0x95,0x53,0x22), nil, 26, -20, TI18N("● "), container, nil, cc.p(0,1))
    local txt_timer = createLabel(22, cc.c3b(0x95,0x53,0x22), nil, 52, -20, TimeTool.getYMDHMS(data.answer_timer), container, nil, cc.p(0,1))
    local txt_content = createLabel(22, cc.c3b(0x95,0x53,0x22), nil, 52, -50, data.answer_content, container, nil, cc.p(0,1))
    txt_content:setMaxLineWidth(560)

    _height = txt_content:getContentSize().height + txt_timer:getContentSize().height + 35

    local _width = self.reply_scroll_size.width - 8
    container:setContentSize(cc.size(_width, _height))
    txt_timer:setPositionY(_height - 15)
    txt_desc_tips:setPositionY(_height - 18)
    txt_content:setPositionY(txt_timer:getPositionY() - 35)
    return container, _height
end




function FeedbackDetailWindow:getMaxLength( str, length)
    local len = StringUtil.SubStringGetTotalIndex(str)
    local max_str = ""
    if len <= length then
        max_str = str
    else
        max_str = StringUtil.SubStringUTF8(str, 1, length) .. ".."
    end
    return max_str
end

--创建信息列表
function FeedbackDetailWindow:createList_1(data)
    local container, height = self:createTitleContent_1(data)
    self.quest_scroll:addChild(container)
    table.insert(self.cache_list, container)
    self.max_height_quest = self.max_height_quest + (height + 10)
    local max_height_quest = math.max(self.max_height_quest, self.quest_scroll_size.height)
    self.quest_scroll:setInnerContainerSize(cc.size(self.quest_scroll_size.width, max_height_quest))
    local off_y = 0
    for i,v in ipairs(self.cache_list) do
        v:setPosition(0, max_height_quest-off_y)
        if i == 1 then
            v:setOpacity(255)
        else
            v:setOpacity(178)
        end
        off_y = off_y + v:getContentSize().height + 10
    end

end

function FeedbackDetailWindow:createTitleContent_1(data)
    if data == nil then return end
    local container = ccui.Widget:create()
    container:setAnchorPoint(cc.p(0, 1))
    container:setCascadeOpacityEnabled(true)
    local _height = 0
    local txt_desc = createLabel(24, cc.c3b(0x64,0x32,0x23), nil, 32, -20, TI18N("详细描述："), container, nil, cc.p(0,1))
    local txt_desc_tips = createLabel(15, cc.c3b(0x64,0x32,0x23), nil, 10, -20, TI18N("● "), container, nil, cc.p(0,1))
    local txt_timer = createLabel(22, cc.c3b(0x64,0x32,0x23), nil, 160, -20, TimeTool.getYMDHMS(data.questions_timer), container, nil, cc.p(0,1))
    local txt_content = createLabel(22, cc.c3b(0x64,0x32,0x23), nil, 32, -50, data.questions_content, container, nil, cc.p(0,1))
    txt_content:setMaxLineWidth(560)

    _height = txt_content:getContentSize().height + txt_timer:getContentSize().height + 35

    local _width = self.quest_scroll_size.width - 8
    container:setContentSize(cc.size(_width, _height))
    txt_desc:setPositionY(_height - 15)
    txt_desc_tips:setPositionY(_height - 20)
    txt_timer:setPositionY(_height - 15)
    txt_content:setPositionY(txt_timer:getPositionY() - 35)
    return container, _height
end



function FeedbackDetailWindow:openRootWnd(id, title, state)
    self.question_id = id or 0
    self.max_height_quest = 0
    self.max_height_reply = 0
    self.status = state
    self.txt_cur_status:setString(self.txt_title .. self.text_info[self.status])
    local str = TI18N("问题：")
    self.title_str = self:getMaxLength(title, 13)

    self.continue_status = 1
    self.max_length_str = ""
    self.btn_continue_status = 1
    if self.title_str ~= nil then
        str = str .. self.title_str
    end
    self.quest_title_desc:setString(str)

    _controller:sender10814(self.question_id)

    self:setLayoutStatus(self.status)

    -- if self.status ==  2 then --已回复
    --     self:setSolveState(2)
    --     self.layout_continue_reply:setVisible(true)
    --     self.continue_reply_title_desc:setPosition(175,107)
    --     self.continue_reply_title_bg:setVisible(false)
    -- elseif self.status == 3 then --未评价
    --     self.layout_evaluate:setVisible(true)
    -- end
end

function FeedbackDetailWindow:setLayoutStatus(status )
    local layout_status = status or 1
    self.layout_quest:setVisible(true)
    self.layout_reply:setVisible(true)
    if layout_status == 1 or layout_status == 4 then
        self.layout_evaluate:setVisible(false)
        self.layout_continue_reply:setVisible(false)
    elseif  layout_status ==  2 then --已回复
        self:setSolveState(2)
        self.layout_continue_reply:setVisible(true)
        self.continue_reply_title_desc:setPosition(175,107)
        self.continue_reply_title_bg:setVisible(false)
        self.layout_evaluate:setVisible(false)
    elseif layout_status == 3 then --未评价
        self.layout_evaluate:setVisible(true)
        self.reply_scroll:setTouchEnabled(false)
        self.layout_continue_reply:setVisible(false)
    end
end

function FeedbackDetailWindow:setSolveState(status)  --有无输入框状态
    self.btn_continue_status = status  or 2
    if status == 1 then  --有输入框
        self.layout_continue_reply:setVisible(true)
        self.layout_continue_reply:setContentSize(cc.size(560,210))
        self.layout_continue_reply:setPositionY(325)
        self.continue_reply_title_desc:setPosition(230,107)
        self.continue_reply_title_desc:setString(TI18N("继续提问"))
        self.continue_reply_title_bg:setVisible(true)
        self.btn_continue:setVisible(false)
        self.btn_cancel:setVisible(true)
        self.btn_ok:setVisible(true)
        self.btn_finish:setVisible(false)
    else --无输入框
        self.layout_continue_reply:setVisible(true)
        self.layout_continue_reply:setContentSize(cc.size(560,150))
        self.layout_continue_reply:setPositionY(265)
        self.continue_reply_title_desc:setPosition(175,107)
        self.continue_reply_title_desc:setString(TI18N("您得问题是否已解决？"))
        self.continue_reply_title_bg:setVisible(false)
        self.btn_continue:setVisible(true)
        self.btn_cancel:setVisible(false)
        self.btn_ok:setVisible(false)
        self.btn_finish:setVisible(true)
    end
    
end

function FeedbackDetailWindow:close_callback()
    _controller:sender10813()
    self:RemoveAll()
    doStopAllActions(self.main_panel)
    _controller:openFeedbackDetailWindow(false)
end