-- --------------------------------------------------------------------
-- 问卷调查（独立的界面）
--
-- --------------------------------------------------------------------
SureveyQuestWindow = SureveyQuestWindow or BaseClass(BaseView)

local controller = WelfareController:getInstance()
local answer_pos = 40 --答案选项之间间距
function SureveyQuestWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "welfare/surveyquest_window"

    self.topic_sprite = {} --答案列表
    self.answer_label = {} --答案文字
    self.topic_layout = {} --点击区域
    self.touchSelect = {} --选中
    self.touchManySelect = {} --多选
    self.item_list = {} -- 奖励
    self.answer_list = {} --答案
    self.index_count = 0 --做题数量
    self.cur_index = nil
    self.titleTopic = nil
    self.answer_ret_temp = nil
    self.topic_length = 10 --初始化
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist},
    }
end

function SureveyQuestWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.btn_start = self.main_container:getChildByName("btn_start")
    self.btn_start.label = self.btn_start:getChildByName("Text_9")
    self.btn_close = self.main_container:getChildByName("btn_close")
    self.answer_scroll = self.main_container:getChildByName("answer_scroll")
    self.answer_scroll:setScrollBarEnabled(false)
    self.answer_scroll:setVisible(false)

    self.main_container:getChildByName("Text_10"):setString(TI18N("小助手的冒险调查"))
    --调查开始的框
    self.text_prompt = self.main_container:getChildByName("text_prompt")
    self.start_title = self.text_prompt:getChildByName("Text_8")
    self.start_title:setString("")
    self.start_memo = self.text_prompt:getChildByName("Text_8_0")
    self.start_memo:setString("")

    --填空框
    self.suggest_panel = self.main_container:getChildByName("suggest_panel")
    self.text_Field = self.suggest_panel:getChildByName("text_Field")
    self.text_Field:setVisible(false)
    local function textFieldEvent(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            sender:setString("")
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
        elseif eventType == ccui.TextFiledEventType.insert_text then
        elseif eventType == ccui.TextFiledEventType.delete_backward then
        end
    end
    self.text_Field:addEventListener(textFieldEvent)
    self.suggest_panel:setVisible(false)


    self.label_content = createRichLabel(22, Config.ColorData.data_color4[151], cc.p(0,1), cc.p(9,370), 6, nil, 450)
    self.label_content:setString("")--TI18N("请输入您宝贵的建议"))
    self.suggest_panel:addChild(self.label_content)
    -- self.label_show = createRichLabel(22, Config.ColorData.data_color4[151], cc.p(0,0.5), cc.p(9, self.suggest_panel:getContentSize().height / 2), 6, nil, 450)
    -- self.label_show:setString("")
    -- self.suggest_panel:addChild(self.label_show)
    --内容输入框
    self.edit_content = createEditBox(self.suggest_panel, PathTool.getResFrame("common","common_99998"),cc.size(400,300), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content:setAnchorPoint(cc.p(0,1))
    self.edit_content:setPlaceholderFontColor(cc.c4b(0x72,0x4E,0x34,0xff))
    self.edit_content:setFontColor(cc.c4b(0x72,0x4E,0x34,0xff))
    self.edit_content:setPosition(cc.p(9, 370))
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_label then  
                self.begin_change_label = false
                self.label_content:setVisible(true)
                -- self.label_show:setVisible(false)
                local str = pSender:getText()
                pSender:setText("")
                -- pSender:setVisible(true)
                if str ~= "" and str ~= self.content_str then
                    self.content_str = str
                    if self.label_content then
                        self.label_content:setString(str)
                    end
                end 
            end
        elseif strEventName == "began" then
            if not self.begin_change_label then
                self.label_content:setVisible(false)
                -- pSender:setText(self.label_content:getString())
                -- pSender:setVisible(false)
                -- self.label_show:setVisible(true)
                -- self.label_show:setString(pSender:getText())
                self.begin_change_label = true
            end
        elseif strEventName == "changed" then
            -- self.label_show:setString(pSender:getText())
        end
    end
    self.edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)
    --奖励框
    self.reward_panel = self.main_container:getChildByName("reward_panel")
    self.reward_panel:setVisible(false)
end

function SureveyQuestWindow:openRootWnd()
    controller:sender24601()
end

function SureveyQuestWindow:register_event()
    registerButtonEventListener(self.btn_close, function()
        controller:openSureveyQuestView(false)
    end,true, 2)
    registerButtonEventListener(self.btn_start, function()
        local open_data = controller:getModel():getQuestOpenData()
        if open_data and open_data.flag ~= 0 then
            controller:sender24604()
            return
        end
        if self.index_count > self.topic_length then return end
        self.index_count = self.index_count + 1
        if self.questNaire_list then
            local status_return = true
            
            local last_data = self.questNaire_list[self.index_count-1]
            --单选和多选
            if self.questNaire_list[self.index_count-1].specific_type ~= QuestConst.fill_blank then
                if self.answer_ret_temp then
                    if #self.answer_ret_temp ~= 0 then
                        local tab = {}
                        tab.id = last_data.id
                        tab.topic_type = last_data.specific_type
                        local str = '' --拼接发给服务端的
                        if type(self.answer_ret_temp) == "table" then
                            self.answer_ret_temp = table.concat(self.answer_ret_temp, ",")
                        else
                            str = self.answer_ret_temp
                        end
                        tab.ret = tostring(self.answer_ret_temp)
                        table.insert(self.answer_list, tab)
                    end
                end

                for i,v in pairs(self.answer_list) do
                    if v.id == last_data.id then
                        if v.ret ~= nil then
                            status_return = false
                            break
                        end
                    end
                end
                if last_data.must == 1 then
                    if last_data.specific_type ~= QuestConst.fill_blank then
                        if status_return == true then 
                            self.index_count = self.index_count - 1
                            message(TI18N("必须选择一个答案"))
                            return 
                        end
                    end
                end
            else
                if last_data.must == 1 then
                    -- if self.text_Field:getString() == "" then 
                    --     self.index_count = self.index_count - 1
                    --     message(TI18N("填空题需写入文字哦")) 
                    --     return 
                    -- end
                    -- print("self.label_content:getString().... ",self.label_content:getString())
                    if self.label_content:getString() == "" then 
                        self.index_count = self.index_count - 1
                        message(TI18N("填空题需写入文字哦")) 
                        return 
                    end
                    
                end
                local tab = {}
                tab.id = last_data.id
                tab.topic_type = last_data.specific_type
                -- tab.ret = self.text_Field:getString()
                tab.ret = self.label_content:getString()
                table.insert(self.answer_list, tab)
                self.label_content:setString("")
                self.edit_content:setText("")
            end
        end
        
        if self.index_count == 1 then
            controller:sender24602()
        end
        if self.topic_length+1 == self.index_count then
            self.answer_scroll:setVisible(false)
            self.suggest_panel:setVisible(false)
            if self.titleTopic then
                self.titleTopic:setVisible(false)
            end
            self:getRewardList()
        else
            self.answer_ret_temp = nil
            -- self.text_Field:setString("")
            -- self.text_Field:setPlaceHolder(TI18N("请输入您宝贵的建议"))
            -- self.label_content:setString(TI18N("请输入您宝贵的建议"))
            self:startTopicAnswer(self.questNaire_list)
            self.text_prompt:setVisible(false)
            self.btn_start.label:setString(TI18N("下一页"))
        end
    end,true, 2)

    self:addGlobalEvent(WelfareEvent.Get_SureveyQuest_Basic, function(data)
        if not data or next(data) == nil then return end
        local open = controller:getModel():getQuestOpenData()
        if open and open.status == 0 then
            return
        end
        self.answer_reward_list = data.rewards
        local open_data = controller:getModel():getQuestOpenData()
        if open_data then
            if open_data.flag == 0 then
                self.start_title:setString(TI18N("亲爱的冒险者大人："))
                self.start_memo:setString(TI18N("辛苦您参加小助手的冒险调查，小助手为大人\n\n准备了小小谢礼，放在了问卷的最后哦~"))
            else
                self:getRewardList(open_data.flag)
            end
        end
    end)

    self:addGlobalEvent(WelfareEvent.Get_SureveyQuest_Topic_Content, function(data)
        if not data or next(data) == nil then return end
        local open = controller:getModel():getQuestOpenData()
        if open and open.status == 0 then
            return
        end
        self.topic_length = tableLen(data.questionnaire_list)
        self.questNaire_list = data.questionnaire_list
        self:startTopicAnswer(self.questNaire_list)
    end)
    self:addGlobalEvent(WelfareEvent.Get_SureveyQuest_Get_Reward, function(data)
        if not data or next(data) == nil then return end
        local open = controller:getModel():getQuestOpenData()
        if open and open.status == 0 then
            return
        end
        self.btn_start.label:setString(TI18N("已完成"))
        self.btn_start.label:disableEffect(cc.LabelEffect.OUTLINE)
        setChildUnEnabled(true, self.btn_start)
        self.btn_start:setTouchEnabled(false)
    end)
end

function SureveyQuestWindow:getRewardList(flag)
    flag = flag or 1
    self.reward_panel:setVisible(true)
    self.end_memo = self.reward_panel:getChildByName("Text_1")
    self.end_memo:setString(TI18N("亲爱的冒险者大人~\n\n请收下小助手的一点心意"))
    
    if flag == 2 then
        self.btn_start.label:setString(TI18N("已完成"))
        self.btn_start.label:disableEffect(cc.LabelEffect.OUTLINE)
        setChildUnEnabled(true, self.btn_start)
        self.btn_start:setTouchEnabled(false)
    else
        self.btn_start.label:setString(TI18N("领取奖励"))
    end
    local good_cons = self.reward_panel:getChildByName("good_cons")

    if self.answer_reward_list then
        local items = {}
        for i,v in pairs(self.answer_reward_list) do
           local tab = {}
           tab.bid = v.bid
           tab.quantity = v.num
           table.insert(items,tab)
        end
        local scroll_view_size = good_cons:getContentSize()
        local setting = {
            item_class = BackPackItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 10,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = BackPackItem.Width,               -- 单元的尺寸width
            item_height = BackPackItem.Height,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 0,                         -- 列数，作用于垂直滚动类型
        }
        self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
        self.item_scrollview:setSwallowTouches(false)
        self.item_scrollview:setData(items)
        local open_data = controller:getModel():getQuestOpenData()
        if open_data and open_data.flag == 0 then
            controller:sender24603(self.answer_list)
        end
    end
end

--开始答题 
function SureveyQuestWindow:startTopicAnswer(data)
    if not data or next(data) == nil then return end

    if not data[self.index_count] then
        return
    end

    local answer = data[self.index_count].specific_type

    --题目标题
    if not self.titleTopic then
        self.titleTopic = createRichLabel(24, cc.c4b(0x4d,0x30,0x1b,0xff), cc.p(0, 0.5), cc.p(115,570), 10, nil, 510)
        self.main_container:addChild(self.titleTopic)
    end
    self.titleTopic:setString(data[self.index_count].title)
    for i,v in pairs(self.topic_sprite) do
        v:setVisible(false)
    end
    for i,v in pairs(self.topic_layout) do
        v:setVisible(false)
    end
    --打钩图片
    for i,v in pairs(self.touchSelect) do
        v:setVisible(false)
    end
    for i,v in pairs(self.answer_label) do
        v:setVisible(false)
    end
    local str = string.gsub(data[self.index_count].option, "\\r", "")
    str = string.gsub(str, "\\", "")
    local ret = assert(loadstring("return "..str))() or 'error'

    if answer == QuestConst.fill_blank then
        self.answer_scroll:setVisible(false)
        self.suggest_panel:setVisible(true)
    else
        self.answer_scroll:setVisible(true)
        self.suggest_panel:setVisible(false)

        local sum_height = {}
        local is_double_col = true
        for i=1, tableLen(ret) do
            if ret[i] and ret[i][2] then
                local len = self:getStringCharCount(ret[i][2])
                if len > 5 then
                    is_double_col = false
                    break
                end
            end
        end
        for i=1, tableLen(ret) do
            if not self.topic_sprite[i] then
                self.topic_sprite[i] = createImage(self.answer_scroll, PathTool.getResFrame("common", "common_1030"), 20, 100*i, cc.p(0.5,0.5), true, 0, true)                 
                self.answer_label[i] = createRichLabel(24, cc.c4b(0x4d,0x30,0x1b,0xff), cc.p(0, 1), cc.p(47,31), nil, nil, 480)
                self.answer_label[i]:setVisible(false)
                self.topic_sprite[i]:addChild(self.answer_label[i])

                self.topic_layout[i] = ccui.Layout:create()
                self.topic_layout[i]:setAnchorPoint(0, 0.5)
                self.topic_layout[i]:setContentSize(cc.size(150, 60))
                self.topic_layout[i]:setPosition(cc.p(0,15))
                self.topic_sprite[i]:addChild(self.topic_layout[i])

                self.topic_sprite[i]:setVisible(false)
                self.topic_layout[i]:setTouchEnabled(true)

                self.touchSelect[i] = createSprite(PathTool.getResFrame("common", "common_1043"), 18, 18, self.topic_sprite[i], cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST)
                self.touchSelect[i]:setVisible(false)
            end
            if self.topic_sprite[i] then
                self.answer_label[i]:setString(ret[i][2])
                self.answer_label[i]:setVisible(false)
                if is_double_col then
                    if math.fmod(i, 2) == 1 then
                        sum_height[i] = self.answer_label[i]:getContentSize().height + answer_pos
                    else
                        sum_height[i] = 0
                    end
                else
                    sum_height[i] = self.answer_label[i]:getContentSize().height + answer_pos
                end
            end
        end
        local total = self:sunTotal(sum_height)
        local max_height = math.max(self.answer_scroll:getContentSize().height, total)
        self.answer_scroll:setInnerContainerSize(cc.size(self.answer_scroll:getContentSize().width, max_height))

        local multiple_answer = {} --多选答案
        for i=1, tableLen(ret) do
            if self.topic_layout[i] and self.touchSelect[i] then
                registerButtonEventListener(self.topic_layout[i], function()
                    if answer == QuestConst.single then
                        if self.cur_tab ~= nil then
                            self.cur_tab:setVisible(false)
                        end
                        self.cur_index = i
                        self.cur_tab = self.touchSelect[self.cur_index]
                        if self.cur_tab ~= nil then
                            self.cur_tab:setVisible(true)
                        end
                        self.answer_ret_temp = ret[i][1]
                    elseif answer == QuestConst.multiple then
                        if self.touchSelect[i]:isVisible() == true then
                            self.touchSelect[i]:setVisible(false)
                            for val=#multiple_answer,1,-1 do
                                if multiple_answer[val] == ret[i][1] then
                                    table.remove(multiple_answer, val)
                                end
                            end
                        else
                            if tableLen(multiple_answer)+1 > 3 then
                                self.touchSelect[i]:setVisible(false)
                                message(TI18N("多选题最多只能选择3个哦"))
                                return
                            end
                            self.touchSelect[i]:setVisible(true)
                            table.insert(multiple_answer, ret[i][1])
                        end
                        self.answer_ret_temp = multiple_answer
                    end
                end,true, 1)
            end

            --选项
            if self.topic_sprite[i] then
                self.topic_layout[i]:setVisible(true)
                self.topic_sprite[i]:setVisible(true)
                self.answer_label[i]:setVisible(true)
                
                local res = answer == QuestConst.single and PathTool.getResFrame("common", "common_1030") or PathTool.getResFrame("common", "common_1044")
                self.topic_sprite[i]:loadTexture(res, LOADTEXT_TYPE_PLIST)
                self.answer_label[i]:setString(ret[i][2])
                
                if is_double_col then
                    local line = math.ceil(i / 2)
                    if line == 1 then
                        if math.fmod(i, 2) == 1 then
                            local pos_y = self.answer_scroll:getInnerContainerSize().height - 30
                            self.topic_sprite[i]:setPosition(cc.p(20, pos_y))
                        else
                            local pos_y = self.answer_scroll:getInnerContainerSize().height - 30
                            self.topic_sprite[i]:setPosition(cc.p(260, pos_y))
                        end
                    else
                        if math.fmod(i, 2) == 1 then
                            local pos_y = self.topic_sprite[i-1]:getPositionY() - self.answer_label[i-1]:getContentSize().height - answer_pos
                            self.topic_sprite[i]:setPosition(cc.p(20, pos_y))
                        else
                            local pos_y = self.topic_sprite[i-1]:getPositionY()
                            self.topic_sprite[i]:setPosition(cc.p(260, pos_y))
                        end
                    end
                else
                    if i == 1 then
                        local pos_y = self.answer_scroll:getInnerContainerSize().height - 30
                        self.topic_sprite[i]:setPosition(cc.p(20, pos_y))
                    else
                        local pos_y = self.topic_sprite[i-1]:getPositionY() - self.answer_label[i-1]:getContentSize().height - answer_pos
                        self.topic_sprite[i]:setPosition(cc.p(20, pos_y))
                    end
                end
            end
        end
    end
end

function SureveyQuestWindow:getStringCharCount(str)
    local lenInByte = #str
    local charCount = 0
    local i = 1
    while (i <= lenInByte) do
        local curByte = string.byte(str, i)
        local byteCount = 1

        if curByte > 239 then
            byteCount = 4  -- 4字节字符
        elseif curByte > 223 then
            byteCount = 3  -- 汉字
        elseif curByte > 128 then
            byteCount = 2  -- 双字节字符
        else
            byteCount = 1  -- 单字节字符
        end

        local char = string.sub(str, i, i + byteCount - 1)
        i = i + byteCount -- 重置下一字节的索引
        charCount = charCount + 1 -- 字符的个数（长度）
    end
    return charCount
end

function SureveyQuestWindow:sunTotal(arr)
    local total = 0
    for i,v in ipairs(arr) do
        total = total + v
    end
    return total
end

function SureveyQuestWindow:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    controller:openSureveyQuestView(false)
end
