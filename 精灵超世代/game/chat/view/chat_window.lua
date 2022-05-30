-- 聊天界面
-- author:cloud
-- date:2016.12.27

ChatWindow = ChatWindow or BaseClass(CommonUI)

local ref_controller = RefController:getInstance()
local chat_controller = ChatController:getInstance()
local chat_model = ChatController:getInstance():getModel()

function ChatWindow:__init(ctrl)
    self.view_tag     = ViewMgrTag.TOP_TAG
    self.control_mode = false
    self.time = 0
    self.is_top = false
    self.requestList = {} -- 好友请求列表
    self.tab_btn_list = {} --标签页按钮列表
    self.cur_selected = nil
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.item_desc_list = {} 
    self.item_code_list = {}
    self.filt_is_show = false
    self.vip_is_show = (self.role_vo.is_show_vip == 1)
    self:initHandle()
end

function ChatWindow:initHandle()
    --默认信息
    self.default_msg = TI18N("请输入信息...")
    self.find_msg    = TI18N("点击查找好友")
    self:registerNotifier(true)
    self:createRootWnd()
    self:updateTabBar()
    self:initView()
    self:initCtrl()

end

function ChatWindow:updateTabBar()
    self.stack_tag =
    {
        [1] = ChatConst.Channel.World,         
        [2] = ChatConst.Channel.Gang, 
        [3] = ChatConst.Channel.Friend,
        [4] = ChatConst.Channel.Notice,
        [5] = ChatConst.Channel.Cross,
        [6] = ChatConst.Channel.Province,
    }
    self.stack_pos =
    {
        [ChatConst.Channel.World]   = 1,
        [ChatConst.Channel.Gang]  = 2,
        [ChatConst.Channel.Friend] = 3,
        [ChatConst.Channel.Notice] = 4,
        [ChatConst.Channel.Cross] = 5,
        [ChatConst.Channel.Province] = 6,
    }
end

--主容器
function ChatWindow:createRootWnd()
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.root_wnd:setAnchorPoint(0,0)

    --遮罩
    self.mask = ccui.Layout:create()
    self.mask:setTouchEnabled(true)
    self.mask:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.mask:setAnchorPoint(0.5,0.5)
    self.mask:setPosition(self.root_wnd:getContentSize().width/2,self.root_wnd:getContentSize().height/2)
    self.root_wnd:addChild(self.mask)
    self.mask:setBackGroundColor(cc.c3b(0,0,0))
    self.mask:setBackGroundColorOpacity(128)
    self.mask:setBackGroundColorType(1)
    self.mask:setScale(display.getMaxScale())

    ViewManager:getInstance():getLayerByTag(self.view_tag):addChild(self.root_wnd)

    local height = display.height
    self.design_height = 1280                         --美术设计的高度
    self.design_width = 720
    local rate = height/self.design_height
    self.real_height = height                         --游戏缩放后实际的高度
    self.offset_height = self.real_height-height      --缩放后增加的高度

    self.free_height = MainuiController:getInstance():getMainUi():getFreeSize()
    self.size = cc.size(SCREEN_WIDTH,self.free_height)
end

function ChatWindow:initView()
    self.back_bg = ccui.Widget:create()
    self.back_bg:setAnchorPoint(cc.p(0,0))

    local bottom_height = MainuiController:getInstance():getMainUi():getBottomHeight()
    self.back_bg:setPosition(cc.p(display.getLeft(self.root_wnd),display.getBottom(self.root_wnd)+bottom_height))
    self.back_bg:setTouchEnabled(true)
    self.back_bg:setContentSize(cc.size(self.size.width, self.size.height))
    self.root_wnd:addChild(self.back_bg,1)

    self.bg1 = createScale9Sprite(PathTool.getResFrame("common","common_1039"),0,0,LOADTEXT_TYPE_PLIST,self.back_bg)
    self.bg1:setCapInsets(cc.rect(300, 71, 10, 10))
    self.bg1:setLocalZOrder(1)
    self.bg1:setContentSize(cc.size(self.size.width,self.free_height-100))
    self.bg1:setAnchorPoint(0.5,1)
    self.bg1:setPosition(cc.p(self.back_bg:getContentSize().width/2,self.back_bg:getContentSize().height-35))

    res = PathTool.getResFrame("common", "common_1034")
    self.bg2 = createScale9Sprite(res, 0,0, LOADTEXT_TYPE_PLIST, self.bg1)
    self.bg2:setLocalZOrder(1)
    --self.bg2:setCapInsets(cc.rect(37, 35, 2, 2))
    local size = self.bg1:getContentSize()
    self.bg2:setContentSize(cc.size(size.width-25,size.height-92-50))
    self.bg2:setAnchorPoint(0,0)
    self.bg2:setPosition(cc.p(12,15))

    --频道背景
    --local bg3 = createScale9Sprite(PathTool.getResFrame("mainui","mainui_chat_1004"),0,0,LOADTEXT_TYPE_PLIST,self.bg2)
    --bg3:setCapInsets(cc.rect(24, 24, 107, 89))
    --bg3:setContentSize(cc.size(size.width-29,size.height-100))
    --bg3:setAnchorPoint(0,0)
    --bg3:setPosition(cc.p(2,2))

    --底部线
    --local line_img = createImage(self.bg2, nil, 0, 0, cc.p(0,0), false, 1)
    --line_img:setCapInsets(cc.rect(24, 24, 107, 89))
    --line_img:setAnchorPoint(0.5,0)
    --line_img:setPosition(cc.p(self.bg2:getContentSize().width/2,6))

    --local bg_res = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_3")
    --self.line_load = loadImageTextureFromCDN(line_img, bg_res, ResourcesType.single, self.line_load)

    --关闭按钮
    self.shrink_btn = CustomButton.New(self.back_bg,PathTool.getResFrame("common", "txt_cn_common_1107"),nil,nil,LOADTEXT_TYPE_PLIST)
    self.shrink_btn:setAnchorPoint(0.5,0.5)
    self.shrink_btn:setPosition(73,27)
    self.shrink_btn:setLocalZOrder(2)

    --频道背景
    local buttomBg = createScale9Sprite(PathTool.getResFrame("common","common_1091"),0,0,LOADTEXT_TYPE_PLIST,self.bg2)
    buttomBg:setContentSize(cc.size(self.bg2:getContentSize().width-4,86))
    buttomBg:setAnchorPoint(0,0)
    buttomBg:setPosition(cc.p(2,22))

    self.container_size = cc.size(self.bg2:getContentSize().width-16,self.bg2:getContentSize().height- buttomBg:getContentSize().height-36)
    --提示文字
    self.notice_label = createLabel(20,cc.c4b(0x7a,0x60,0x41,0xff),nil,buttomBg:getContentSize().width/2,buttomBg:getContentSize().height/2,TI18N("该频道下无法发言"),buttomBg)
    self.notice_label:setAnchorPoint(0.5,0.5)
    self.notice_label:setVisible(false)
    --发送按钮
    self.btn_send = CustomButton.New(buttomBg, PathTool.getResFrame("common", "common_1017"), PathTool.getResFrame("common", "common_1017"),nil,LOADTEXT_TYPE_PLIST)
    --self.btn_send:setSize(cc.size(155,62))
    self.btn_send:setLabelSize(24)

    -- self.btn_send:getButton():setScaleX(0.8)
    self.btn_send:setPosition(cc.p(590,buttomBg:getContentSize().height/2))
    self.btn_send:setBtnLabel(TI18N("发送"))
    self.btn_send:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)

    --self.btn_send:getLabel():enableOutline(cc.c3b(108,43,0),2)
    self.btn_send:setLocalZOrder(4)

    self:createTabBtnList()

    --输入组件
    self.chat_input = ChatInput.new("chatWindow")
    self.chat_input:setPosition(78, buttomBg:getContentSize().height/2-12)
    self.chat_input:setInputFunc(function()
        self:onEditBoxTouch()
    end)
    self.chat_input:setVoiceFunc(function(sender, event)
        self:beginRecord(sender, event)
    end)
    buttomBg:addChild(self.chat_input, 5)

    --伸缩位置
    self.in_x  = self.back_bg:getContentSize().width+100
    self.out_x = 1
    self.back_bg:setPositionX(-self.in_x)
end

function ChatWindow:showAtNotice( status,data )
    if self.at_notice == nil then 
        --self.at_notice = createScale9Sprite(PathTool.getResFrame("common","common_1021"), self.bg2:getContentSize().width-200, 75, LOADTEXT_TYPE_PLIST, self.bg2)
        self.at_notice = createImage(self.bg1, PathTool.getResFrame("mainui","mainui_chat_at_bg"), self.bg1:getContentSize().width-262, 130, cc.p(0.5,0.5), true, 0, true)
        self.at_notice:setCapInsets(cc.rect(41, 27, 2, 2))
        self.at_notice:setContentSize(cc.size(250, 52))
        self.at_notice:setAnchorPoint(0,0)
        
        self.at_notice:setTouchEnabled(true)
        self.at_notice:setLocalZOrder(99)
        self.at_label = createRichLabel(24, 1, cc.p(0,0.5), cc.p(25,self.at_notice:getContentSize().height/2), 0, 0, 150)
        self.at_label:setString(TI18N("有人提到了我"))
        self.at_notice:addChild(self.at_label)

        local line = createScale9Sprite(PathTool.getResFrame("mainui","mainui_chat_at_line"), self.at_label:getPositionX()+self.at_label:getContentSize().width+22, self.at_notice:getContentSize().height/2, LOADTEXT_TYPE_PLIST, self.at_notice)

        self.at_close = CustomButton.New(self.at_notice, PathTool.getResFrame("mainui", "mainui_chat_close"), PathTool.getResFrame("mainui", "mainui_chat_close"),nil,LOADTEXT_TYPE_PLIST)
        self.at_close:setAnchorPoint(0,0.5)
        --self.at_close:setScale(0.7)
        self.at_close:setPosition(self.at_notice:getContentSize().width-self.at_close:getContentSize().width-5,self.at_notice:getContentSize().height/2-2)
    end
    --self.at_notice:setVisible(status)
    local function close_callback(  )
        self.at_notice:setVisible(false)
        chat_model:setAtData({})
        if data and next(data)~=nil then 
            chat_controller:sender12768( data.rid,data.srv_id,data.channel,data.msg )
            --print("=====sender12768===",data.rid,data.srv_id,data.channel,data.msg )
        end 
    end

    handleTouchEnded(self.at_close,function (  )
        close_callback()
    end)
    
    if data and next(data)~=nil then 
        local id = chat_controller:getId(self.channel,data.srv_id,data.rid,data.name,data.msg)
        if self.channelList then
            local scroll = self.channelList[self.channel]
            if scroll and scroll.stack_item then
                local item = scroll.stack_item[id]
                if item then
                    self.at_notice:setVisible(status)
                else
                    self.at_notice:setVisible(false)
                end
            else
                self.at_notice:setVisible(false)
            end
        end
    else
        self.at_notice:setVisible(false)
    end

    self.at_notice:addTouchEventListener(function ( sender,event_type )
        if event_type == ccui.TouchEventType.ended then
            if data and next(data)~=nil then 
                local id = chat_controller:getId(self.channel,data.srv_id,data.rid,data.name,data.msg)
                local scroll = self.channelList[self.channel]
                if scroll and scroll.stack_item then
                    local item = scroll.stack_item[id]
                    if item then
                        local precent = math.floor(((self.channelList[self.channel].realHeight-item:getPositionY()+item:getContentSize().height)/(self.channelList[self.channel].realHeight))*100)
                        scroll:jumpToPercentVertical(precent)
                        close_callback()
                    end
                end               
            end
        end
    end)
end

--创建标签按钮
function ChatWindow:createTabBtnList(  )
    self.tabArray = {
        {title = TI18N("同省"), notice = TI18N("等级不足35级"), index = 6, status = true},
        --{title = TI18N("跨服"), notice = TI18N("等级不足50级"), index = 5, status = true},
        {title = TI18N("世界"), index = 1, status = true},
        {title = TI18N("公会"), notice = TI18N("您暂时没有加入公会"), index = 2, status = true},
        {title = TI18N("私聊"), index = 3, status = true},
        {title = TI18N("系统"), index = 4, status = true},
    }

    -- 服务器数量不足2个时，隐藏跨服频道
    --[[local srv_list = LoginController:getInstance():getModel():getServerList()
    if tableLen(srv_list) < 2 then
        table.remove(self.tabArray, 2)
    end--]]

    local widget = ccui.Widget:create()
    widget:setContentSize(cc.size(640,90))
    widget:setAnchorPoint(cc.p(0,1))
    widget:setPosition(cc.p(30, self.bg1:getContentSize().height-20-50))
    self.bg1:addChild(widget)
    widget:setLocalZOrder(0)

    local bgSize = widget:getContentSize()
    local scroll_view_size = cc.size(bgSize.width+20, bgSize.height)
    local setting = {
        item_class = CommonTabBtn,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 15,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 130,               -- 单元的尺寸width
        item_height = 60,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.tab_scrollview = CommonScrollViewLayout.new(widget, cc.p(2, 10) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.tab_scrollview:setData(self.tabArray, handler(self, self._onClickTabBtn), nil, {default_index = 1, tab_size = cc.size(120, 60),title_offset = cc.p(0, -5),red_offset =cc.p(0, -5) })
    self.tab_scrollview:addEndCallBack(function (  )
        self.tab_btn_list = self.tab_scrollview:getItemList()
        for i,v in ipairs(self.tabArray) do
            local is_open = self:checkBtnIsOpen(v.index)
            self:setTabBtnTouchStatus(is_open, v.index)
        end
        self:initChannelRedNum()
        if self.temp_cur_index then
            self:setSelecteTab(self.temp_cur_index)
            self.temp_cur_index = nil
        end
    end)

    -- 筛选按钮
    --[[self.filt_btn = CustomButton.New(widget,PathTool.getResFrame("common", "common_1012"),nil,nil,LOADTEXT_TYPE_PLIST)
    self.filt_btn:setAnchorPoint(0.5,0.5)
    self.filt_btn:setPosition(cc.p(bgSize.width+50,widget:getContentSize().height/2))
    self.filt_btn:setSize(cc.size(68, 62))
    self.filt_btn:setCapInsets(cc.rect(12,12,1,1))
    local res = PathTool.getResFrame("mainui", "mainui_chat_arrow")
    self.filt_btn:setImageLabel(res,1, LOADTEXT_TYPE_PLIST)
    self.filt_btn:addTouchEventListener(function(sender, event)
        if event == ccui.TouchEventType.ended then
            self:_onClickFiltBtn()
        end
    end)--]]
end

function ChatWindow:_onClickTabBtn( tab_btn )
    if self.cur_selected then
        self.cur_selected:setBtnSelectStatus(false)
    end

    if tab_btn then
        self.cur_selected = tab_btn
        self.cur_selected:setBtnSelectStatus(true)

        self:openTagBtn(self.cur_selected.index)

        if self.cur_selected.index == 1 then
            PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.At_notice)
        end
    end
end

function ChatWindow:setSelecteTab(index)
    if self.tab_scrollview then
        local tab_btn
        for k,btn in pairs(self.tab_btn_list) do
            if btn.index == index then
                tab_btn = btn
            end
        end
        if tab_btn then
            self:_onClickTabBtn(tab_btn)
        end
    end
end

--[[function ChatWindow:_onClickFiltBtn(  )
    if not self.filt_layout then
        self.filt_layout = ccui.Layout:create()
        self.filt_layout:setTouchEnabled(true)
        local size = self.bg1:getContentSize()
        self.filt_layout:setContentSize(cc.size(size.width, size.height))
        self.filt_layout:setAnchorPoint(0.5,1)
        self.filt_layout:setPosition(self.back_bg:getContentSize().width/2,self.back_bg:getContentSize().height-65)
        self.filt_layout:setLocalZOrder(1)
        self.back_bg:addChild(self.filt_layout)

        self.filt_layout:addTouchEventListener(function(sender, event)
            if event == ccui.TouchEventType.ended then
                self:_onClickFiltBtn()
            end
        end)

        local filt_bg_size = cc.size(255, 60)
        local filt_bg = createImage(self.filt_layout, PathTool.getResFrame("common", "common_1092"), 0, 0, cc.p(1, 1), true, 1, true)
        filt_bg:setTouchEnabled(true)
        filt_bg:setContentSize(filt_bg_size)
        filt_bg:setAnchorPoint(cc.p(1, 1))
        local world_pos = self.filt_btn:getRoot():convertToWorldSpace(cc.p(0, 0))
        local node_pos = self.filt_layout:convertToNodeSpace(world_pos)
        filt_bg:setPosition(cc.p(node_pos.x+63, node_pos.y))

        local box_list = {
            [1] = TI18N("隐藏VIP标志"),
        }
        for i,desc in ipairs(box_list) do
            local chose_box = self:createChoseBox(desc, i)
            chose_box:setPosition(cc.p(0, filt_bg_size.height - (i-1)*60))
            filt_bg:addChild(chose_box)
        end
    end
    self.filt_is_show = not self.filt_is_show
    self.filt_layout:setVisible(self.filt_is_show)
end--]]

-- 筛选框
--[[function ChatWindow:createChoseBox( desc, index )
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(255, 60))
    layout:setAnchorPoint(0, 1)

    local bg, btn = PathTool.getCheckBoxRes_2()
    local check_box = RadioButton.new(layout, bg, btn, desc, 100, RadioButtonDir.LEFT, 26)
    check_box:setAnchorPoint(cc.p(0, 0.5))
    check_box:setTitleColor(cc.c4b(224, 191, 152, 255))
    check_box:setPosition(cc.p(20, 30))
    check_box:setSelected(self.vip_is_show)
    check_box:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            check_box:setSelected(not check_box:isSelected())
            if index == 1 then
                self.vip_is_show = not self.vip_is_show
                if self.vip_is_show == true then
                    RoleController:getInstance():sender10348(1)
                else
                    RoleController:getInstance():sender10348(0)
                end
            end
        end
    end)

    return layout
end--]]

--判断是否开启按钮
function ChatWindow:checkBtnIsOpen( index )
    if index == 2 and RoleController:getInstance():getRoleVo():isHasGuild()==false then
        return false
    elseif index == 5 then
        local cross_config = Config.MiscData.data_const["cross_level"]
        if self.role_vo.lev >= cross_config.val then
            return true
        else
            return false
        end
    --[[elseif index == 6 then
        local province_config = Config.MiscData.data_const["province_level"]
        if province_config and self.role_vo.lev >= province_config.val then
            return true
        else
            return false
        end--]]
    end
    return true
end

--设置按钮是否变灰
function ChatWindow:setTabBtnTouchStatus(status, index)
    if self.tab_scrollview then
        local tab_btn
        for k,btn in pairs(self.tab_btn_list) do
            if btn.index == index then
                tab_btn = btn
            end
        end
        if tab_btn then
            tab_btn:setBtnOpenStatus(status)
        end
    end
end

--==============================--
--desc:初始化聊天的条目
--time:2018-07-27 04:10:01
--@return 
--==============================--
function ChatWindow:initChannelRedNum()
    for i,tab_btn in ipairs(self.tab_btn_list) do
        if tab_btn.index ~= 4 then
            local channel = self.stack_tag[tab_btn.index]
            self:setTabTipsII(channel) 
        end
    end
end

--==============================--
--desc:标签页红点,统一处理
--time:2018-07-27 03:51:03
--@channel:
--@return 
--==============================--
function ChatWindow:setTabTipsII(channel)
    if channel == nil then return end
    if not self.tab_scrollview then return end
    local index = self.stack_pos[channel]
    if index == nil then return end
    local tab_btn
    for k,btn in pairs(self.tab_btn_list) do
        if btn.index == index then
            tab_btn = btn
        end
    end
    if tab_btn then
        local sum = chat_controller:getChannelMsgSum(channel)
        tab_btn:setRedStatus(sum>0, sum)
    end
end

-- 打开关/闭界面伸缩处理
function ChatWindow:playMoveAct(is_open)
    if self.moving then return end
    self.moving = true
    self.back_bg:stopAllActions()
    local offx = 0
    if is_open then
        offx = 0--self.in_x
    else 
         offx = -self.in_x
    end
     local move_action = cc.MoveTo:create(0.2,cc.p(offx + self.out_x, self.back_bg:getPositionY()))
    self.back_bg:runAction(cc.Sequence:create(move_action, cc.CallFunc:create(function()
        self.moving = nil
        if not is_open then
            self:close()
        else
        	if self.commend_ui then
               self.commend_ui:judgeLead()
            end
        end
        if self.is_top  then
            self.back_bg:setPositionY(self.back_bg:getPositionY()-275)
            self.is_top =false
        end
    end)))

    -- 关闭的时候打开
    if not is_open then
        if GuideController:getInstance():isInGuide() == false then
            MainuiController:getInstance():setMainUIChatBubbleStatus(true) 
        end
    end

    --[[if self.filt_is_show then
        self:_onClickFiltBtn()
    end--]]
end

-- 拖动关闭界面
function ChatWindow:addMoveAndClose()
    self.mask:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:playMoveAct()
        end
    end)
    self.back_bg:addTouchEventListener(function(sender, event_type)
        local start_pos, end_pos
        if event_type == ccui.TouchEventType.ended then
            start_pos = cc.p(sender:getTouchBeganPosition())
            end_pos = cc.p(sender:getTouchEndPosition())
            if start_pos.x - end_pos.x > 300 then
                self:playMoveAct()
            end
        end
    end)
end

-- 打开频道
function ChatWindow:openChannel(channel,srv_id,rid)
    --[[if channel == ChatConst.Channel.World then
       channel = ChatConst.Channel.World
    end--]]
    local index = self.stack_pos[channel]
    self.channel = channel
    self.select_srv_id = srv_id
    self.select_rid = rid
    -- 遍历一下是否激活状态
    for i,v in ipairs(self.tabArray) do
        local is_open = self:checkBtnIsOpen(v.index)
        self:setTabBtnTouchStatus(is_open, v.index)
    end
    if not self.tab_btn_list or next(self.tab_btn_list) == nil then
        self.temp_cur_index = index  -- 可能tab按钮还没创建完，那么先缓存一下，创建完再触发选中
    else
        self:setSelecteTab(index)
    end
end

-- 打开频道(只是频道切换)
function ChatWindow:moveToChannel(channel)
    local index = self.stack_pos[channel]
    self.channel = channel
    -- 遍历一下是否激活状态
    for i,v in ipairs(self.tabArray) do
        local is_open = self:checkBtnIsOpen(v.index)
        self:setTabBtnTouchStatus(is_open, v.index)
    end
    self:setSelecteTab(index)
end

-- 初始化操作
function ChatWindow:initCtrl()
    self:registerNotifier(true)
    self:addMoveAndClose()

    --收起按钮
    self.shrink_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:playMoveAct()
        end
    end)

    --发送按钮
    handleTouchEnded(self.btn_send, function()
        self:onEditBoxTouch()
    end)
end

-- 录音
function ChatWindow:beginRecord(sender, event)
    local channel = self.channel
    if channel == ChatConst.Channel.Multi or channel == ChatConst.Channel.Event then
        channel = ChatConst.Channel.World
    end
    ChatHelp.RecordTouched(sender, event, channel)
end

-- 切换标签按钮
function ChatWindow:openTagBtn(index)
    if index == self.select_index or not self.stack_tag or not self.chat_input then return end
    self.select_index = index
    self.channel = self.stack_tag[index]
    chat_controller:setLastChannel(self.channel)
    self.chat_input:setChatChannel(self.channel)
    
    --队伍、宗门、综合、事件频道
    self:setCoseListDisable()
    self:showCoseList(self.channel)

    self.chat_input:setVisible(true)

    --[[self.filt_btn:setVisible(self:isShowFiltBtn(self.channel))
    if self.filt_is_show then
        self:_onClickFiltBtn()
    end--]]

    if self.channel == ChatConst.Channel.Event or self.channel == ChatConst.Channel.Notice then
        self.chat_input:setVisible(false)
        self.notice_label:setVisible(true)
    elseif self.channel == ChatConst.Channel.Province then
        local province_config = Config.MiscData.data_const["province_level"]
        if not province_config or self.role_vo.lev < province_config.val then
            self.chat_input:setVisible(false)
            self.notice_label:setVisible(false)
        else
            self.chat_input:setVisible(true)
            self.notice_label:setVisible(false)
        end
    else
        self.notice_label:setVisible(false)
    end

    -- 同省、跨服、世界、公会可以@人
    if index == 1 or index == 2 or index == 5 or index == 6 then 
        local data = chat_model:getAtData()
        if data and next(data)~=nil then 
            self:showAtNotice(true,data)
        end
        -- 文字太长，界面放不下 [2021/9/30 pjl]
        -- self.chat_input.edit_box:setPlaceHolder(TI18N("请输入,长按头像可快捷@人"))
        self.chat_input.edit_box:setPlaceHolder(TI18N(""))
    else
        self.chat_input.edit_box:setPlaceHolder(TI18N("请输入信息"))
    end

    -- 切到同省频道则清一下输入框数据（同省频道屏蔽了道具等信息发送）
    if index == 6 then
        self:cleatInputText()
    end

    self:checkFindInput()
    --加入宗门提示
    self:analyseGang()
end

-- 查找框UI调整
function ChatWindow:checkFindInput()
    if --[[not self.find_scroll and not self.commend_ui and not self.apply_scroll or]] self.channel==ChatConst.Channel.Event or self.channel==ChatConst.Channel.Notice then
        self.btn_send:setVisible(false)
        if self.find_input then
            self.f_edit_box:setPosition(70,0)
        end
    elseif self.channel == ChatConst.Channel.Province then
        local province_config = Config.MiscData.data_const["province_level"]
        if not province_config or self.role_vo.lev < province_config.val then
            self.btn_send:setVisible(false)
        else
            self.btn_send:setVisible(true)
        end
    else
        self.btn_send:setVisible(true)
        if  self.channel==ChatConst.Channel.Mail then
            self.btn_send:setBtnLabel(TI18N("返回"))

        else
            self.btn_send:setBtnLabel(TI18N("发送"))
        end
        if self.find_input then
            self.f_edit_box:setPosition(18,0)
        end
    end
end



-- 宗门频道显示处理
function ChatWindow:analyseGang()
    if self.channel==ChatConst.Channel.Gang and not RoleController:getInstance():getRoleVo():isHasGuild() then
        chat_controller:clearChatLog(self.channel)
        local scroll = self:getCostList(ChatConst.Channel.Gang)
        if scroll then
            scroll:reset()
        end
        self:showJoinGang(true)
    else
        self:showJoinGang(false)
    end
end

-- 添加宗门提示
function ChatWindow:showJoinGang(bool)
    if bool then
        if self.help_text == nil then
            self.help_text =createRichLabel(24, Config.ColorData.data_color4[66], cc.p(0.5,0.5), cc.p(0,0), nil, nil, 300)
            local str = TI18N("您暂时没有加入公会")
            self.help_text:setString(str)
            self.help_text:setAnchorPoint(0.5,0.5)
            self.help_text:setPosition(self.bg1:getContentSize().width/2, self.bg1:getContentSize().height/2-90)
            self.bg1:addChild(self.help_text)

            if self.no_img == nil then 
                local res = PathTool.getEmptyMark()
                self.no_img = createImage(self.bg1, res, self.bg1:getContentSize().width/2, self.bg1:getContentSize().height/2-2, cc.p(0.5,0.5), false, 1, false)
                self.no_img:setScale(1.2)
            end
        end
    else
        doRemoveFromParent(self.help_text)
        self.help_text = nil
        if self.no_img then
            doRemoveFromParent(self.no_img)
            self.no_img = nil
        end
    end
end

-- 事件处理
function ChatWindow:registerNotifier(bool)
    if bool then
        --隐藏关闭按钮
        if not self.close_btn_event then
            self.close_btn_event = GlobalEvent:getInstance():Bind(EventId.CHAT_CLOSEBTN_VISIBLE, function(bool)
                self.shrink_btn:setVisible(true)
            end)
        end

        --更新聊天
        if not self.world_msg_evt then
            self.world_msg_evt = GlobalEvent:getInstance():Bind(EventId.CHAT_UDMSG_WORLD, function(channel, is_self)
                if self.is_open then
                    self:updateCoseList(channel, is_self)
                end
            end)
        end

        --更新系统频道聊天
        if not self.multi_msg_evt then
            self.multi_msg_evt = GlobalEvent:getInstance():Bind(EventId.CHAT_UDMSG_ASSETS, function()
                if self.is_open then
                    self:updateCoseList(ChatConst.Channel.Notice)
                end
            end)
        end

        --清除输入文本
        if not self.clear_input_event then
            self.clear_input_event = GlobalEvent:getInstance():Bind(EventId.CHAT_CLEAR_INPUT, function(is_private)
                self:cleatInputText()
            end)
        end

        --删除输入文字
        if not self.backspace_evt then
            self.backspace_evt = GlobalEvent:getInstance():Bind(EventId.CHAT_BACKSPACE, function(from_name)
                if from_name == "chatPanel" then
                    self:handleBackSpace()
                end
            end)
        end

        --添加表情
        if not self.add_face_evt then
            self.add_face_evt = GlobalEvent:getInstance():Bind(EventId.CHAT_SELECT_FACE, function(face_id, from_name)
                if from_name == "chatWindow" then
                    self:onEditTextAddFace(face_id)
                end
            end)
        end
        --添加物品
        if not self.add_item_evt then
            self.add_item_evt = GlobalEvent:getInstance():Bind(EventId.CHAT_SELECT_ITEM, function(data, from_name)
                if from_name == "chatWindow" then
                    self:onEditTextAddItem(data)
                end
            end)
        end

        --更新翻译内容
        if not self.adjust_event then
            self.adjust_event = GlobalEvent:getInstance():Bind(ChatConst.Voice_Translate_Panel, function()
                self:adjustPosAfterTranslate()
            end)
        end

        --点击发送按钮
        if not self.touch_send_evt then
            self.touch_send_evt = GlobalEvent:getInstance():Bind(EventId.CHAT_QUICK_SEND, function(from_name)
                if --[[not chat_controller:isPrivateOpen() and]] from_name == "chatPanel" then
                    self:onEditBoxTouch()
                end
            end)
        end

        --有公会的时候更改下状态
        if self.role_vo then
            if self.role_update_lev_event == nil then
                self.role_update_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
                    if key == "gsrv_id" or key == "gid" then
                        if self.role_vo:isHasGuild() then
                            self:setTabBtnTouchStatus(true, 2)
                        end
                    end
                end)
            end
        end

        --私聊的红点更新
        -- if not self.update_private_red then
        --     self.update_private_red = GlobalEvent:getInstance():Bind(ChatEvent.UpdatePrivateChatRed,function (  )
        --         if self.tab_btn_list[3] then
        --             self:setTabTipsII(chat_model:getRedCount(), 3)
        --         end
        --     end)
        -- end

        if self.new_msg_add_event == nil then
            self.new_msg_add_event = GlobalEvent:getInstance():Bind(EventId.CHAT_NEWMSG_FLAG, function(channel)
                self:setTabTipsII(channel)
            end)
        end

        --创建完成聊天列表 更新下信息
        if not self.update_at then
            self.update_at = GlobalEvent:getInstance():Bind(ChatEvent.EndCallBack,function (  )
                if self.channel == ChatConst.Channel.Gang or self.channel == ChatConst.Channel.World then 
                    local data = chat_model:getAtData()
                    if data and next(data)~=nil then 
                        self:showAtNotice(true,data)
                    end
                    --self.chat_input.edit_box:setPlaceHolder(TI18N("请输入信息,长按头像可快捷@人"))
                else
                    --self.chat_input.edit_box:setPlaceHolder(TI18N("请输入信息"))
                end
            end)
        end

        if not self.enter_fight then
            self.enter_fight = GlobalEvent:getInstance():Bind(SceneEvent.ENTER_FIGHT,function ()
                self:playMoveAct()
            end)
        end
    else
        if self.close_btn_event then
            GlobalEvent:getInstance():UnBind(self.close_btn_event)
            self.close_btn_event = nil
        end
        if self.world_msg_evt then
            GlobalEvent:getInstance():UnBind(self.world_msg_evt)
            self.world_msg_evt = nil
        end
        if self.multi_msg_evt then
            GlobalEvent:getInstance():UnBind(self.multi_msg_evt)
            self.multi_msg_evt = nil
        end
        if self.clear_input_event then
            GlobalEvent:getInstance():UnBind(self.clear_input_event)
            self.clear_input_event = nil
        end
        if self.backspace_evt then
            GlobalEvent:getInstance():UnBind(self.backspace_evt)
            self.backspace_evt = nil
        end
        if self.add_face_evt then
            GlobalEvent:getInstance():UnBind(self.add_face_evt)
            self.add_face_evt = nil
        end
        if self.add_item_evt then
            GlobalEvent:getInstance():UnBind(self.add_item_evt)
            self.add_item_evt = nil
        end
        if self.touch_send_evt then
            GlobalEvent:getInstance():UnBind(self.touch_send_evt)
            self.touch_send_evt = nil
        end

        if self.adjust_event then
            GlobalEvent:getInstance():UnBind(self.adjust_event)
            self.adjust_event = nil
        end

        if self.role_vo then
            if self.role_update_lev_event then
                self.role_vo:UnBind(self.role_update_lev_event)
                self.role_update_lev_event = nil
            end
        end

        -- if self.update_private_red then
        --     GlobalEvent:getInstance():UnBind(self.update_private_red)
        --     self.update_private_red = nil
        -- end

        if self.new_msg_add_event then
            GlobalEvent:getInstance():UnBind(self.new_msg_add_event)
            self.new_msg_add_event = nil
        end

        if self.update_at then
            GlobalEvent:getInstance():UnBind(self.update_at)
            self.update_at = nil
        end

        if self.enter_fight then
            GlobalEvent:getInstance():UnBind(self.enter_fight)
            self.enter_fight = nil
        end
    end
end

-- 文本框操作
function ChatWindow:onEditBoxTouch()
    local text, srv_id = self.chat_input:getInputText()
    srv_id = srv_id or ""
    --if self.channel == ChatConst.Channel.Friend then return end
    if self.channel == ChatConst.Channel.Event then
        message(TI18N("事件频道不能发言"))
        return
    end
    if self.chat_input:isNothing() then
        message(TI18N("请输入聊天信息"))
        return
    end

    local data = WordCensor:getInstance():relapceFaceIconTag(text)
    if data[1] > 5 then
        message(TI18N("发言中不能超过5个表情"))
        return
    end
    local tar_channel
    text = WordCensor:getInstance():relpaceChatTag(text)
    -- 展示物品替换
    if self.item_desc_list and next(self.item_desc_list) then
        for k,v in pairs(self.item_desc_list) do
            text = string.gsub(text, k, v, 1)
        end
    end

    if self.channel == ChatConst.Channel.World then     --世界聊天
        tar_channel = 1
        text = self:repleaceAtPeopleText(text, srv_id)
    elseif self.channel == ChatConst.Channel.Cross then --跨服聊天
        tar_channel = 1024
        text = self:repleaceAtPeopleText(text, srv_id)
    elseif self.channel == ChatConst.Channel.Province then -- 同省聊天
        tar_channel = 2048
        text = self:repleaceAtPeopleText(text, srv_id)
    elseif self.channel == ChatConst.Channel.Scene then --场景聊天
        tar_channel = 2
    elseif self.channel == ChatConst.Channel.Team then --队伍聊天
        tar_channel = 8
    elseif self.channel == ChatConst.Channel.Gang  then --帮派聊天
        if RoleController:getInstance():getRoleVo():isHasGuild() then
            tar_channel = 4
            text = self:repleaceAtPeopleText(text, srv_id)
        else
            message(TI18N("加入公会即可在此频道发言"))
        end
    elseif self.channel == ChatConst.Channel.Friend then --私聊频道
        tar_channel = nil
        local user_data = self.channelList[self.channel]:getUserData()
        if user_data and next(user_data)~=nil then
            chat_controller:sender12720(user_data.srv_id, user_data.rid, 0, text)
            self:cleatInputText()
        else
            message(TI18N("当前没人可以聊天~"))
        end
        
    end
    if tar_channel then
        if GameNet:getInstance():getTime() - self.time > 1 then
            self.time =  GameNet:getInstance():getTime()
            local is_success = chat_controller:sendChatMsg(tar_channel, 0, text)
            if is_success then
                self:cleatInputText()
            end
        end
    end
end

function ChatWindow:repleaceAtPeopleText( text, srv_id )
    local num1 = string.find(text,"@")
    local num2 = string.find(text," ")
    local len = string.len(text)
    if num1 and num2 then
        local at = string.sub(text,num1,num2)
        local rep = string.format("<div href=atpeople srvid=%s>%s</div>",srv_id,at)
        text = string.gsub(text,at,rep)
    end
    return text
end

function ChatWindow:cleatInputText()
	self.chat_input:setInputText("")
	self.item_desc_list = {}
    self.item_code_list = {} 
end 

-- 删除输入的信息
function ChatWindow:handleBackSpace()
    local text = self.chat_input:getInputText()
    if text ~= "" then
        local str_list, length = StringUtil.splitStr(text)
        local words = ""
        for i=1, #str_list-1 do
            words = words.. tostring(str_list[i].char)
        end
        self.chat_input:setInputText(words)
    end
end

-- 输入框添加表情
function ChatWindow:onEditTextAddFace(face_id)
    local text = self.chat_input:getInputText()
    if text == self.default_msg then
        text = ""
    end

    self.chat_input:setInputText(text..face_id)
end

-- 输入框添加表情
function ChatWindow:onEditTextAddItem(data)
    if data == nil then return end

    local text = self.chat_input:getInputText()
    if text == self.default_msg then
        text = ""
    end

    -- 如果没有文字内容，则清一下数据
    if text == "" then
        self.item_desc_list = {} 
        self.item_code_list = {}
    end

    local base_id = data.base_id
    local share_id = data.share_id
    local count = data.count
    local role_vo =  RoleController:getInstance():getRoleVo()
    local item_config = Config.ItemData.data_get_data(base_id)
    local code = data.code

    if item_config then
        local key = string.format("{%s,%s}", share_id, item_config.name)
        local desc = ref_controller:buildItemMsg(base_id, role_vo.srv_id, share_id, count)

        if self.item_code_list[code] then
            local cur_object = self.item_code_list[code]
            local cur_key = cur_object.key
            local cur_desc = cur_object.desc

            -- 获取原有的
            text = string.gsub(text, cur_key, key, 1)
        else
            text = text..key
        end
        self.item_code_list[code] = {key=key, desc=desc}

        self.item_desc_list[key] = desc
        self.chat_input:setInputText(text)
    end
end 

-- 获取输入文本内容
function ChatWindow:getEditText()
    return self.chat_input:getInputText()
end

-- 打开界面
function ChatWindow:open()
    if not self.is_open then
        self.is_open = true
        self:playMoveAct(true)
    end
    self.root_wnd:setVisible(true)
    self:addClock(false)
    self:registerNotifier(true)
    self:setCommonUIZOrder(self.root_wnd)
    self:initChannelRedNum()
    chat_controller:openChatUITimer(false)    
end

-- 关闭界面
function ChatWindow:close()
    SysEnv:getInstance():save()
    ChatMgr:getInstance():showReportUI(false)
    RefController:getInstance():closeView()
    self.root_wnd:setVisible(false)
    self.is_open = false
    self.select_index = nil
    self:registerNotifier(false)
    self:setCoseListDisable()
    if self.mail_ui then
       self.mail_ui:SetEnabled(false)
    end
    if self.friend_ui then
       self.friend_ui:SetEnabled(false)
    end
    self:addClock(true)
    
    if GuideController:getInstance():isInGuide() == false then
        MainuiController:getInstance():setMainUIChatBubbleStatus(true)
    end 

    chat_controller:openChatUITimer(true)
end

-- 清掉聊天列表数据
function ChatWindow:clearChatList(  )
    if not self.channelList then self.channelList = {} end
    for channel,scroll in pairs(self.channelList) do
        if channel ~= ChatConst.Channel.Friend then
            scroll:reset()
        end
    end
end

-- 打开状态
function ChatWindow:isOpen()
    return self.is_open
end

-- 创建聊天列表
function ChatWindow:showCoseList(channel)
    if not self.channelList then self.channelList = {} end
    if self:isChatChannel(channel) then
        for i,v in pairs(self.channelList) do
            if i ~= ChatConst.Channel.Friend then
                if v then
                    v:showNewMessage(false)
                    v:setVisible(false)
                end
            else
                if v then
                    v:setVisibleStatus(false)
                end
            end
        end
        local scroll = self.channelList[channel]
        local size = self.container_size
        local pos = cc.p(20,123)
        local bg1size = self.bg1:getContentSize()
        if not scroll then
            if channel ~= ChatConst.Channel.Friend then
                scroll = NewCoseList.new(size,self.bg1)
                scroll:setPosition(pos)
                self.bg1:addChild(scroll,22)
            else
                chat_controller:openPrivatePanel(true,nil,self.bg2)
                scroll = chat_controller:getChatPanel()
            end
            self.channelList[channel] = scroll
        else
            if channel ~= ChatConst.Channel.Friend then
                scroll:SetEnabled(true)
            end
        end
        if channel ~= ChatConst.Channel.Friend then
            if chat_controller.stack_list == nil then return end
            delayRun(self.bg1, 1/display.DEFAULT_FPS, function()
                if self.channelList and self.channel and self.channelList[self.channel] and self.channelList[self.channel]["createMsg"] then
                    self.channelList[self.channel]:createMsg(chat_controller.stack_list[self.channel], self.channel)
                end
            end) 
        else
            self.channelList[self.channel]:setVisibleStatus(true)
            self.channelList[self.channel]:updateData(self.select_srv_id,self.select_rid)
        end
    end
end

-- 更新当前频道数据
function ChatWindow:updateCoseList(channel, is_self)
    if not self.channelList then return end
    if self:isChatChannel(self.channel) and self.channel == channel then
        local scroll = self.channelList[self.channel]
        if self.channel ~= ChatConst.Channel.Friend then
            if scroll and scroll:isSame(self.channel) then
                scroll:SetEnabled(true)
                scroll:initData(chat_controller.stack_list[self.channel])
                scroll:updateMsg(is_self)
            end
        else
            local scroll1 = scroll:getCostList()
            if scroll1 and scroll1:isSame(self.channel) then
                scroll1:SetEnabled(true)
                scroll1:initData(chat_controller.stack_list[self.channel])
                scroll1:updateMsg()
            end

        end
    end
end

-- 翻译内容更新
function ChatWindow:adjustPosAfterTranslate()
    if self.channelList then
        for k, v in pairs(self.channelList) do
            if k~=ChatConst.Channel.Friend then
                v:adjustItemPos()
            else
                local vo = self:getCostList(k)
                if vo and vo["adjustItemPos"] then
                    vo:adjustItemPos()
                end
            end
        end
    end
end

-- 隐藏所有的聊天内容
function ChatWindow:setCoseListDisable()
    if self.channelList then
        for k, v in pairs(self.channelList) do
            if k~=  ChatConst.Channel.Friend then      
                v:SetEnabled(false)
            else
                v:setVisibleStatus(false)
            end
        end
    end
end

-- 获取某一个频道滚动组件
function ChatWindow:getCostList(channel)
    if self.channelList then
        if channel ~= ChatConst.Channel.Friend then
            return self.channelList[channel]
        else
            return self.channelList[channel]
        end
    end
end

-- 清掉所有数据
function ChatWindow:clearAllChatMsg(  )
    if self.channelList then
        for k, v in pairs(self.channelList) do
            if k~=  ChatConst.Channel.Friend then      
                v:reset()
            end
        end
    end
end

-- 判断是否是聊天频道#
function ChatWindow:isChatChannel(channel)
    if channel==ChatConst.Channel.Gang
        or channel==ChatConst.Channel.World
        or channel == ChatConst.Channel.Notice
        or channel == ChatConst.Channel.Friend
        or channel == ChatConst.Channel.Province
        or channel == ChatConst.Channel.Cross then
        -- or channel == ChatConst.Channel.Scene 
        -- or channel == ChatConst.Channel.Team then
        return true
    end
    return false
end

-- 判断是否要显示下拉筛选按钮
function ChatWindow:isShowFiltBtn( channel )
    if FILTER_CHARGE then return false end -- 屏蔽充值相关
    if channel==ChatConst.Channel.World
        or channel == ChatConst.Channel.Gang
        or channel == ChatConst.Channel.Cross then
        return true
    end
    return false
end

-- 添加定时清理
function ChatWindow:addClock(bool)
    if self.clock_id then
        GlobalTimeTicket:getInstance():remove(self.clock_id)
        self.clock_id = nil
    end
    if bool then
        local del_key
        local count = 0
        local clean_list = {
            [10] = ChatConst.Channel.Gang,
            [30] = ChatConst.Channel.World,
            [40] = "friend",
            [50] = "mail",
        }
        self.clock_id = GlobalTimeTicket:getInstance():add(function()
            count = count + 1
            del_key = clean_list[count]
            if del_key then
                local scroll = self:getCostList(del_key)
                if scroll then
                    -- scroll:stopRunning()
                    scroll:reset()
                end

            end
        end, 1, 61)
    end
end
