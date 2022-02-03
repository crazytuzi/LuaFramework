-- --------------------------------------------------------------------
-- bug反馈
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-8-8
-- --------------------------------------------------------------------
BugPanel = BugPanel or BaseClass(BaseView)

function BugPanel:__init()
    self.ctrl = NoticeController:getInstance()
    self.layout_name = "notice/bug_panel"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Mini
    self.btn_list = {}
    self.label_list = {}
    self.default_title_msg = TI18N("请输入标题")
    self.default_content_msg = TI18N("请输入内容")
    self.title_str = ""
    self.content_str = ""
    self.cur_select = nil
end

function BugPanel:open_callback()
    -- self.root_wnd = 
    local bg = self.root_wnd:getChildByName("backpanel")
    bg:setScale(display.getMaxScale())
    self.background = bg:getChildByName("background")
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 2) 
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn:setTitleText(TI18N("提交"))
    self.ok_btn.label = self.ok_btn:getTitleRenderer()
    if self.ok_btn.label ~= nil then
        self.ok_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    end

    self.tab_container = self.main_panel:getChildByName("tab_container")

    for i=1,2 do 
        local btn = self.tab_container:getChildByName("tab_btn_"..i)
        local label = btn:getChildByName("title")
        btn.label = label
        self.btn_list[i] = btn
        btn:setBright(false)
        btn.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
        self.btn_list[i].index = i
        if i == 1 then
            label:setString(TI18N("提交建议"))
        else
            label:setString(TI18N("BUG反馈"))
        end
    end

    --各种文本
    local edit_box_title = self.main_panel:getChildByName("edit_box_title")
    edit_box_title:setString(TI18N("标题:"))
    local edit_box_content = self.main_panel:getChildByName("edit_box_content")
    edit_box_content:setString(TI18N("内容:"))

    local player_label = createLabel(24,Config.ColorData.data_color4[175],nil,45,448,TI18N("亲爱的冒险者大人："),self.main_panel,nil, cc.p(0,0))
    local desc_label = createRichLabel(22, Config.ColorData.data_color4[175], cc.p(1,1), cc.p(575,445), 6, nil, 530)
    self.main_panel:addChild(desc_label)
    local str = ""
    CUSTOMER_QQ = CUSTOMER_QQ or 800185843 
    if BUG_PANEL_DESC then
        str = string.format(BUG_PANEL_DESC, GAME_NAME)
    else
        str = string.format(TI18N("    欢迎您进驻《%s》的冒险世界，如您在游戏中发现BUG或有什么建议。欢迎您填写留言并提交给我们，我们会认真查看每一条留言，让冒险世界做的更好！如有紧急问题，请联系QQ公众号：%s"),GAME_NAME, CUSTOMER_QQ)
    end
    desc_label:setString(str)
    --创建输入框
    --标题输入框
    local res = PathTool.getResFrame("common","common_99998")
    self.edit_title = createEditBox(self.main_panel, res,cc.size(300,30), nil, 22, Config.ColorData.data_color4[151], 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_title:setAnchorPoint(cc.p(0,0))
    self.edit_title:setPlaceholderFontColor(Config.ColorData.data_color4[151])
    self.edit_title:setFontColor(Config.ColorData.data_color4[66])
    self.edit_title:setPosition(cc.p(126,268))
    self.edit_title:setMaxLength(40)

    self.title_content = createRichLabel(22, Config.ColorData.data_color4[151], cc.p(0,1), cc.p(130,296), 6, nil, 300)
    self.title_content:setString(self.default_title_msg)
    self.main_panel:addChild(self.title_content)

    local function editTitleBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_title then  
                self.begin_change_title = false
                self.title_content:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.title_str then
                    self.title_str = str
                    if self.title_content then
                        self.title_content:setString(str)
                    end
                end 
            end
        elseif strEventName == "began" then
            if not self.begin_change_title then
                self.title_content:setVisible(false)
                self.begin_change_title = true
            end
        elseif strEventName == "changed" then

        end
    end
    self.edit_title:registerScriptEditBoxHandler(editTitleBoxTextEventHandle)

    self.label_content = createRichLabel(22, Config.ColorData.data_color4[151], cc.p(0,1), cc.p(130,257), 6, nil, 300)
    self.label_content:setString(self.default_content_msg)
    self.main_panel:addChild(self.label_content)
    --内容输入框
    self.edit_content = createEditBox(self.main_panel, res,cc.size(400,130), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content:setAnchorPoint(cc.p(0,1))
    self.edit_content:setPlaceholderFontColor(Config.ColorData.data_color4[63])
    self.edit_content:setFontColor(Config.ColorData.data_color4[66])
    self.edit_content:setPosition(cc.p(133,258))
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_label then  
                self.begin_change_label = false
                self.label_content:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
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
                self.begin_change_label = true
            end
        elseif strEventName == "changed" then

        end
    end
    self.edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)

    self:changeIndex(1)
end

function BugPanel:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            -- self.ctrl:openBatchUseItemView(false)
            playButtonSound2()
            self.ctrl:closeBugPanel()
        end
    end)
    for i=1,2 do 
        self.btn_list[i]:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:changeIndex(i)
            end
        end)
    end
    self.ok_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.cur_select then return end
            local issue_type = self.cur_select.index  or 1
            local title = self.title_str or ""
            if string.len(title) == 0 or title == self.default_title_msg then 
                message(TI18N("请输入标题"))
                return
            end
            local content = self.content_str or ""
            if string.len(content) == 0 or content == self.default_content_msg then 
                message(TI18N("请输入内容"))
                return
            end
            self.ctrl:sender10810(issue_type+1, title, content)
            if self.title_content then
                self.title_content:setString(self.default_title_msg)
            end
            if self.label_content then
                self.label_content:setString(self.default_content_msg)
            end
        end
    end)
    
end

function BugPanel:changeIndex(index)
    if self.cur_select and self.cur_select.index == index then return end
    index = index or 1
    if index <1 or index >2 then 
        index = 1
    end

    if self.cur_select ~= nil then
        self.cur_select.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
        self.cur_select:setBright(false)
    end

    self.cur_select = self.btn_list[index]

    if self.cur_select ~= nil then
        self.cur_select.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
        self.cur_select:setBright(true)
    end

end

function BugPanel:setData(vo)
    if not vo then return end
    self.data = vo
end



function BugPanel:close_callback()
    self.ctrl:closeBugPanel()
end