-- --------------------------------------------------------------------
-- 客服中心
-- 
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-1-4
-- --------------------------------------------------------------------
ServiceCenterWindow = ServiceCenterWindow or BaseClass(BaseView)

local controller = NoticeController:getInstance()
local role_vo = RoleController:getInstance():getRoleVo()
local login_model = LoginController:getInstance():getModel()
local titleConst =         --标题类型
    { 
        contact_service          = 1 , --联系客服
        history_feedback         = 2 , --历史反馈
    }

function ServiceCenterWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big
    self.is_full_screen = true
    self.layout_name = "notice/service_center_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg","pattern/pattern_3"), type = ResourcesType.single},
    }
    self.btn_list = {}
    self.choose_btn_list = {}
    self.choost_status = 1
    self.quest_content_str, self.phone_num_str, self.email_str, self.warning_str = "", "", "",""
    
    CUSTOMER_QQ = CUSTOMER_QQ or 800185843 
    self.placeholder_list  = {  string.format(TI18N("    请详细描述您遇到的问题或建议(字数不少于\n10字)，如遇到紧急问题，请联系QQ公众号：\n%s"), CUSTOMER_QQ),
                                TI18N("请输入手机号码"),
                                TI18N("请输入邮箱地址")
                            }
    self.cell_data_list = {}
    self.cache_list = {}
end


function ServiceCenterWindow:open_callback()
    local bg = self.root_wnd:getChildByName("backpanel")
    bg:setScale(display.getMaxScale())
    self.background = bg:getChildByName("background")
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 2)
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.top_panel = self.main_panel:getChildByName("top_panel")
    self.top_panel:getChildByName("title_label"):setString(TI18N("客服中心"))

    local res = PathTool.getPlistImgForDownLoad("bigbg","pattern/pattern_3")  --底部花纹
    if res ~= nil then
        local pattern_1 = createSprite(res, self.main_panel:getContentSize().width/2, 25, self.main_panel, cc.p(0.5,0.5),LOADTEXT_TYPE)
        pattern_1:setScaleX(0.85)
    end
    self.tab_container = self.main_panel:getChildByName("tab_container")

    for i=1,2 do 
        local btn = self.tab_container:getChildByName("tab_btn_"..i)
        local label = btn:getChildByName("title")
        local red_tips = btn:getChildByName("red_tips")
        btn.red_tips = red_tips
        btn.label = label
        self.btn_list[i] = btn
        btn.red_tips:setVisible(false)
        btn:setBright(false)
        btn.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
        self.btn_list[i].index = i
        if i == 1 then
            label:setString(TI18N("联系客服"))
        else
            label:setString(TI18N("历史反馈"))
        end
    end

    self.contact_container = self.main_panel:getChildByName("contact_container")

    self.contact_container:getChildByName("question_desc"):setString(TI18N("问题描述*："))
    self.Image_21 = self.contact_container:getChildByName("Image_21")
    self.quest_scroll = self.Image_21:getChildByName("quest_scroll")
    self.quest_scroll:setScrollBarEnabled(false)
    self.quest_scroll:setTouchEnabled(false)

    self:createProblemContentBox() --问题反馈输入框

    self.tab_info = self.contact_container:getChildByName("tab_info")
    self.txt_feedback_type = self.tab_info:getChildByName("txt_feedback_type")
    self.txt_feedback_type:setString(TI18N("反馈类型*："))
    self.CheckBox_choose_1 = self.txt_feedback_type:getChildByName("CheckBox_choose_1")
    self.CheckBox_choose_2 = self.txt_feedback_type:getChildByName("CheckBox_choose_2")
    self.CheckBox_choose_3 = self.txt_feedback_type:getChildByName("CheckBox_choose_3")
    local hoose_label_list = { TI18N("Bug反馈"), TI18N("功能建议"),TI18N("其他反馈") }
    for i=1,3 do 
        local labe1 = self.txt_feedback_type:getChildByName("txt_choose_"..i)
        labe1:setString(hoose_label_list[i])
        local choose_btn = self.txt_feedback_type:getChildByName("CheckBox_choose_"..i)
        self.choose_btn_list[i] = choose_btn
        self.choose_btn_list[i].index = i

    end

    self.tel_info = self.tab_info:getChildByName("tel_info")
    self.tel_info:setString(TI18N("手机号码："))
    self.tel_input = self.tel_info:getChildByName("tel_input")
    self.txt_tel_error = self.tel_input:getChildByName("txt_tel_error")
    self.txt_tel_error:setString(TI18N("填写不正确"))
    self.txt_tel_error:setVisible(false)
    self:createPhoneNumBox()   --手机号输入框
    
   
    self.mail_info = self.tab_info:getChildByName("mail_info")
    self.mail_info:setString(TI18N("邮箱地址："))

    self.email_input = self.mail_info:getChildByName("email_input")
    self.txt_email_error = self.email_input:getChildByName("txt_email_error")
    self.txt_email_error:setString(TI18N("填写不正确"))
    self.txt_email_error:setVisible(false)
    self:createEmailBox()  --邮箱

    self.srv_info = self.tab_info:getChildByName("srv_info")
    self.srv_info:setString(TI18N("区服信息："))
    self.txt_srv_name = self.srv_info:getChildByName("txt_srvname")

    self.role_info = self.tab_info:getChildByName("role_info")
    self.role_info:setString(TI18N("角色名字："))
    self.txt_role_name = self.role_info:getChildByName("txt_rolename")

    self.device_info = self.tab_info:getChildByName("device_info")
    self.device_info:setString(TI18N("设备信息："))
    self.txt_device_name = self.device_info:getChildByName("txt_device_name")
    self.device_info_str = self:getDeviceInfo()
    self.txt_device_name:setString(self.device_info_str)

    self.commit_btn = self.contact_container:getChildByName("commit_btn")

    self.explain_label = self.commit_btn:getChildByName("explain_label")
    self.explain_label:setString(TI18N("*标注为必填项"))

    self.commit_label = self.commit_btn:getChildByName("label")
    self.commit_label:setString(TI18N("提交反馈"))

    if role_vo then
        self.txt_srv_name:setString(login_model:getLoginData().srv_name)
        self.txt_role_name:setString(role_vo.name)
    end

    self.feedback_container = self.main_panel:getChildByName("feedback_container")
    self.contact_container:setVisible(false)
    self.feedback_container:setVisible(false)
    self.list_info_layout = self.feedback_container:getChildByName("list_info_layout")
    self.num_all_questions = self.list_info_layout:getChildByName("num_all_questions")
    self.num_replied = self.list_info_layout:getChildByName("num_replied")
    self.num_wait = self.list_info_layout:getChildByName("num_wait")
    self.num_all_questions:setString(TI18N("问题数：0"))
    self.num_replied:setString(TI18N("已回复：0"))
    self.num_wait:setString(TI18N("待回复：0"))

    self.scroll_view = self.feedback_container:getChildByName("scroll_view")

    self:setCheckBoxStatus()

    if self:getIsChangePlaceHolder() == true then
        self.tel_info:setVisible(false)
        self.mail_info:setVisible(false)
        self.srv_info:setPositionY(230)
        self.role_info:setPositionY(160)
        self.device_info:setPositionY(90)
    end
end

function ServiceCenterWindow:getDeviceInfo()
    local str, device_str = "" , device.getDeviceName()
    if device_str ~= nil then
        str = device_str
    else
        str = TI18N("无法显示")
    end
    return str
end

function ServiceCenterWindow:createProblemContentBox() -- 问题描述
    local res = PathTool.getResFrame("common","common_99998")
    if not self.problem_inputBox then
        self.problem_inputBox = createEditBox(self.quest_scroll, res, cc.size(520,140), Config.ColorData.data_color3[274], 24, cc.c3b(0x8c,0x8c,0x8b), 24, self.placeholder_list[1], cc.p(5,295), 150, LOADTEXT_TYPE_PLIST)
    end
    if self:getIsChangePlaceHolder() == true then
        self.problem_inputBox:setPlaceHolder(TI18N("        请详细描述您遇到的问题或建议（字数\n不少于10字）"))
    end
    self.problem_inputBox:setAnchorPoint(cc.p(0,1))
        local function editTitleBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_title then  
                self.begin_change_title = false
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.quest_content_str then
                    self.quest_scroll:setTouchEnabled(false)
                    self.quest_content_str = str
                    self.problem_inputBox:setText(self.quest_content_str)
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

function ServiceCenterWindow:getMaxLength( str , length)

    local len = StringUtil.SubStringGetTotalIndex(str)
    local max_str = ""
    if len <= length then
        max_str = str
    else
        max_str = StringUtil.SubStringUTF8(str, 1, length) .. ".."
    end
    return max_str
end

function ServiceCenterWindow:getIsChangePlaceHolder()
    local channel = device.getChannel()
    if  channel == "66_1" or channel == "65_1" or channel == "51_1" or channel == "53_1" or  channel == "52_1" or
        channel == "64_1" or channel == "69_1" or channel == "70_1" or channel == "55_1" or  channel == "71_1" or
        channel == "58_1" or channel == "56_1" or channel == "54_1" or channel == "83_1"   then
        return true
    else
        return false
    end
end

function ServiceCenterWindow:createPhoneNumBox()  --电话号码框
    local res = PathTool.getResFrame("common","common_99998")
    if not self.pnonenum_inputBox then
        self.pnonenum_inputBox = createEditBox(self.tel_input, res,cc.size(250,45), Config.ColorData.data_color3[274], 24,  cc.c3b(0x8c,0x8c,0x8b), 22, self.placeholder_list[2], cc.p(0,45), 11, LOADTEXT_TYPE_PLIST,cc.EDITBOX_INPUT_MODE_PHONENUMBER, cc.KEYBOARD_RETURNTYPE_DONE)
    end
    if self:getIsChangePlaceHolder() == true then
        self.pnonenum_inputBox:setPlaceHolder("")
    end
    self.pnonenum_inputBox:setAnchorPoint(cc.p(0,1))
        local function editPhoneNumBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_phonenum then  
                self.begin_change_phonenum = false

                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.phone_num_str then
                    self.phone_num_str = str 
                    self.pnonenum_inputBox:setText(str)
                    if  tonumber(self.phone_num_str) and #self.phone_num_str == 11  then
                        self.txt_tel_error:setVisible(false)
                    elseif self.phone_num_str == "" then
                        self.txt_tel_error:setVisible(false)
                    else
                        self.txt_tel_error:setVisible(true)
                    end
                end 
            end
        elseif strEventName == "began" then
            if not self.begin_change_phonenum then
                self.txt_tel_error:setVisible(false)
                self.begin_change_phonenum = true
            end
        elseif strEventName == "changed" then

        end
    end
    self.pnonenum_inputBox:registerScriptEditBoxHandler(editPhoneNumBoxTextEventHandle)
end

function ServiceCenterWindow:createEmailBox( ... )
    local res = PathTool.getResFrame("common","common_99998")
    if not self.email_inputBox then
        self.email_inputBox = createEditBox(self.email_input, res, cc.size(250,45), Config.ColorData.data_color3[274], 24, cc.c3b(0x8c,0x8c,0x8b), 22, self.placeholder_list[3], cc.p(0,45), nil, LOADTEXT_TYPE_PLIST, cc.EDITBOX_INPUT_MODE_EMAILADDR)
    end
    if self:getIsChangePlaceHolder() == true then
        self.email_inputBox:setPlaceHolder("")
    end
    self.email_inputBox:setAnchorPoint(cc.p(0,1))
        local function editEmailBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_email then  
                self.begin_change_email = false
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= self.email_str then
                    local max_length_str = self:getMaxLength(str, 18) --18长度显示 不影响真实长度
                    self.email_str = str or ""
                    self.email_inputBox:setText(max_length_str)
                    if self:isRightEmail(tostring(self.email_str)) or self.email_str == ""  then
                        self.txt_email_error:setVisible(false) 
                    else
                        self.txt_email_error:setVisible(true)
                    end
                end 
            end
        elseif strEventName == "began" then
            if not self.begin_change_email then
                self.txt_email_error:setVisible(false)
                self.begin_change_email = true
            end
        elseif strEventName == "changed" then

        end
    end
    self.email_inputBox:registerScriptEditBoxHandler(editEmailBoxTextEventHandle)
end



function ServiceCenterWindow:isRightEmail(str)
    if string.len(str or "") < 6 then return false end
    local b,e = string.find(str or "", '@')
    local bstr = ""
    local estr = ""
    if b then
        bstr = string.sub(str, 1, b-1)
        estr = string.sub(str, e+1, -1)
    else
        return false
    end

    local p1,p2 = string.find(bstr, "[%w_]+")
    if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
    
    if string.find(estr, "^[%.]+") then return false end
    if string.find(estr, "%.[%.]+") then return false end
    if string.find(estr, "@") then return false end
    if string.find(estr, "[%.]+$") then return false end

    _,count = string.gsub(estr, "%.", "")
    if (count < 1 ) or (count > 3) then
        return false
    end
    return true
end


function ServiceCenterWindow:register_event()
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openServiceCenterWindow(false)
            end
        end)
    end

    if self.commit_btn then  --提交反馈
        self.commit_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self:isCanCommit() then
                    local str_content = self:getProblemTitle()
                    controller:sender10810(tonumber(self.choost_status), str_content, self.quest_content_str, self.phone_num_str, self.email_str, self.device_info_str)
                    --self:setEmptyString()
                else
                    local str = self.warning_str .. TI18N("填写不正确")
                    CommonAlert.show(str, TI18N("确定"), nil, nil, nil, CommonAlert.type.common)
                end
            end
        end)
    end

    for k, object in pairs(self.btn_list) do
        if object then
            self.btn_list[k]:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

    for k, object in pairs(self.choose_btn_list) do
        self.choose_btn_list[k]:addEventListenerCheckBox(function(sender, event_type)
                playButtonSound2()
                self.choost_status  = k
                self:setCheckBoxStatus()
        end)
    end
    

   self:addGlobalEvent(NoticeEvent.All_Feedback_Event_Data, function()
        --if data ~= nil and next(data) ~= nil then
            self:setData()
            self:setRedStatus()
    end)

    self:addGlobalEvent(NoticeEvent.Feedback_Success_Event, function(data)
        if data ~= nil and next(data) ~= nil then
            if data.code ==  1 then
                local function func()

                    local str = self.quest_content_str or "" 
                    controller:openFeedbackDetailWindow(true, data.id, str, 1)
                    --self:changeSelectedTab(titleConst.history_feedback)
                    --self:setEmptyString()
                    self.problem_inputBox:setText("")
                    self.email_inputBox:setText("")
                    self.pnonenum_inputBox:setText("")

                end
                CommonAlert.show(TI18N("您的问题已提交成功！"), TI18N("前往查看"), func, nil, nil, CommonAlert.type.common)
            end
        end
    end)
end

function ServiceCenterWindow:setRedStatus()
    local red_status = controller:getModel():getRedStatus() or false
    self.btn_list[2].red_tips:setVisible(red_status)
end


function ServiceCenterWindow:setData( )
    if self.common_scrollview == nil then
        local scroll_view_size = self.scroll_view:getContentSize()
        local setting = {
            start_x = 7,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 4,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 580,                -- 单元的尺寸width
            item_height = 121,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
            need_dynamic   = true
        }
        self.common_scrollview = CommonScrollViewSingleLayout.new(self.scroll_view, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    --local sort_func = SortTools.tableLowerSorter({"end_msg_time"})

    --table.sort(data, sort_func)
    self.cell_data_list = controller:getModel():getFeedBackData() or {}
    local num_list = controller:getModel():getCount()
    self.num_all_questions:setString(TI18N("问题数：") .. num_list.all_count)
    self.num_replied:setString(TI18N("已回复：") .. num_list.replied_count)
    self.num_wait:setString(TI18N("待评价：") .. num_list.wait_count)
    self.common_scrollview:reloadData()
    if next(self.cell_data_list) ~= nil then
        commonShowEmptyIcon(self.scroll_view, false)
    else
        commonShowEmptyIcon(self.scroll_view, true, {font_size = 22,scale = 1, offset_y = 6, text = TI18N("暂无反馈")})
    end
end



--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ServiceCenterWindow:createNewCell(width, height)
    local cell = FeedBackHistoryItem.new(width, height, self)
    return cell
end
--获取数据数量
function ServiceCenterWindow:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ServiceCenterWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

-- --点击cell .需要在 createNewCell 设置点击事件
-- function ServiceCenterWindow:setCellTouched(cell)
--     if not cell.index then return end
--     local cell_data = self.cell_data_list[cell.index]
--     if not cell_data then return end
--      --按钮
--     if cell_data.status == 1 then
--         --可领取
--         self.ctrl:send21201(cell_data.id)    
--     end

-- end


function ServiceCenterWindow:getProblemTitle()  --获取标题
    if not self.quest_content_str then return end
    local str = ""
    local len = StringUtil.SubStringGetTotalIndex(self.quest_content_str)
    if len <= 13 then
        str = self.quest_content_str
    else
        str = StringUtil.SubStringUTF8(self.quest_content_str, 1, 13)
    end
    return str
end

function ServiceCenterWindow:setEmptyString()
    -- self.quest_content_str, self.phone_num_str, self.email_str, self.warning_str = "", "", "",""
    -- self.quest_content:setString("")
    -- self.email_content:setString("")
    -- self.pnonenum_content:setString("")
    -- self:createProblemContentBox()
    -- self:createEmailBox()
    -- self:createPhoneNumBox()
end

function ServiceCenterWindow:isCanCommit(  )
    local len = StringUtil.SubStringGetTotalIndex(self.quest_content_str)
    if len <= 10 then
        self.warning_str = TI18N("问题描述")
        return false
    end
    if tonumber(self.phone_num_str) and #self.phone_num_str == 11 then
    elseif self.phone_num_str == "" then
    else
        self.warning_str = TI18N("手机号码")
        return false
    end
    if self:isRightEmail(self.email_str) or self.email_str == "" then
    else
        self.warning_str = TI18N("邮箱地址")
        return false
    end
    return true
     
end

function ServiceCenterWindow:setCheckBoxStatus()
    for i=1,3 do
        if self.choost_status == i then
            self.choose_btn_list[i]:setSelectedState(true)
        else
            self.choose_btn_list[i]:setSelectedState(false)
        end
    end
end
-- 切换标签页
function ServiceCenterWindow:changeSelectedTab( index )
    if self.selected_tab ~= nil then
        if self.selected_tab.index == index then
            return
        end
    end
    if self.selected_tab then
        self.selected_tab:setBright(false)
        self.selected_tab = nil
    end
    self.selected_tab = self.btn_list[index]
    if self.selected_tab then
        self.selected_tab:setBright(true)
    end
    self.contact_container:setVisible(self.selected_tab.index == titleConst.contact_service)
    self.feedback_container:setVisible(self.selected_tab.index == titleConst.history_feedback)
end


function ServiceCenterWindow:openRootWnd(index)
    self.selected_index =  index or titleConst.contact_service
    self:changeSelectedTab(self.selected_index)
    controller:sender10813()
end

function ServiceCenterWindow:close_callback()
    controller:openServiceCenterWindow(false)
end



-- 子项
FeedBackHistoryItem = class("feedback_history_item", function()
    return ccui.Widget:create()
end)

function FeedBackHistoryItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function FeedBackHistoryItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("notice/feedback_history_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.txt_item_title = self.container:getChildByName("txt_item_title")
    self.txt_item_time = self.container:getChildByName("txt_item_time")
    self.txt_item_status = self.container:getChildByName("txt_item_status")
end

function FeedBackHistoryItem:register_event( )
    registerButtonEventListener(self, function() controller:openFeedbackDetailWindow(true,self.id, self.title_label, self.state)  end ,false, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    --registerButtonEventListener(self, function() print("lc-------详情")  end , false, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
end

function FeedBackHistoryItem:setData(data)
    if not data then return end
    self.data = data
    self.id = data.id
    self.title_label = self:getTitleContent(data.content)
    self.state = data.state
    self.txt_item_title:setString(self.title_label)
    if data.end_msg_time == 0 then
        self.txt_item_time:setString(TimeTool.getYMDHMS(data.start_time))
    else
        self.txt_item_time:setString(TimeTool.getYMDHMS(data.end_msg_time))
    end
    local _str, _color = self:getTextInfo(data.state)
    self.txt_item_status:setString(_str)
    self.txt_item_status:setTextColor(_color)

end

function FeedBackHistoryItem:getTextInfo( state )
    local text_info = {
            [1] = { str = TI18N("已提交"), color = cc.c3b(0x24,0x90,0x03)},
            -- [1] = { str = TI18N("待回复"), color = cc.c3b(0x24,0x90,0x03)},
            [2] = { str = TI18N("已回复"), color = cc.c3b(0xd9,0x50,0x14)},
            [3] = { str = TI18N("未评价"), color = cc.c3b(0xd9,0x50,0x14)},
            [4] = { str = TI18N("已完成"), color = cc.c3b(0x95,0x53,0x22)},
            [5] = { str = TI18N("已完成"), color = cc.c3b(0x95,0x53,0x22)},
        }
    return text_info[state].str, text_info[state].color
end


function FeedBackHistoryItem:getTitleContent(str)  --获取标题
    if not str then return "" end
    local len = StringUtil.SubStringGetTotalIndex(str)
    local title_content_str = ""
    if len <= 13 then
        title_content_str = str
    else
        title_content_str = StringUtil.SubStringUTF8(str, 1, 13) .. ".."
    end
    return title_content_str
end

function FeedBackHistoryItem:DeleteMe()
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)

    self:removeAllChildren()
    self:removeFromParent()
end