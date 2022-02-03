-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      举报功能
-- <br/> 2019年3月25日
-- --------------------------------------------------------------------
RoleReportedPanel = RoleReportedPanel or BaseClass(BaseView)

local controller = RoleController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local string_len =  string.len
local string_find =  string.find
local string_sub =  string.sub


function RoleReportedPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "roleinfo/role_reported_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    self.default_content_msg = TI18N("点击输入原因, 最多100字")
    self.content_str = ""
    --
    self.select_checkbox = 1

    --聊天之间信息的间隔
    self.space_y = 2

    self.item_list = {}
end

function RoleReportedPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("举报"))

    self.close_btn = self.main_panel:getChildByName("close_btn")


    self.key_reported = self.main_container:getChildByName("key_reported")
    self.key_reported:setString("举报原因:")
    self.key_explain = self.main_container:getChildByName("key_explain")
    self.key_explain:setString("附加说明:")
    self.key_evidence = self.main_container:getChildByName("key_evidence")
    self.key_evidence:setString("举报证据:")
    self.key_evidence2 = self.main_container:getChildByName("key_evidence2")
    self.key_evidence2:setString("勾选发言记录作为证据:")
    self.key_reported_name = self.main_container:getChildByName("key_reported_name")
    self.key_reported_name:setString("被举报玩家:")

    self.reported_name = self.main_container:getChildByName("reported_name")
    
    local check_name_list ={
        [1] = TI18N("昵称不雅"),
        [2] = TI18N("骚扰谩骂"),
        [3] = TI18N("广告刷屏"),
        [4] = TI18N("色情暴力"),
        [5] = TI18N("反动证据"),
        [6] = TI18N("头像违规"),
        [7] = TI18N("其他")
    }
    
    self.checkbox_list = {}
    for i=1,7 do
        local checkbox = self.main_container:getChildByName("checkbox"..i)
        if checkbox then 
            local name = checkbox:getChildByName("name")
            if check_name_list[i] then
                name:setString(check_name_list[i])
            end
            self.checkbox_list[i] = checkbox
        end
    end
    self:setSelectCheckBox()


    local res = PathTool.getResFrame("common","common_99998")
    self.label_content = createRichLabel(22, Config.ColorData.data_color4[151], cc.p(0,1), cc.p(160,560), 6, nil, 450)
    self.label_content:setString(self.default_content_msg)
    self.main_container:addChild(self.label_content)
    --内容输入框
    self.edit_content = createEditBox(self.main_container, res,cc.size(450,110), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content:setAnchorPoint(cc.p(0,1))
    self.edit_content:setPlaceholderFontColor(Config.ColorData.data_color4[63])
    self.edit_content:setFontColor(Config.ColorData.data_color4[66])
    self.edit_content:setPosition(cc.p(158,563))
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_label then  
                self.begin_change_label = false
                self.label_content:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.content_str then
                    if StringUtil.SubStringGetTotalIndex(str) > 100 then
                        str = StringUtil.SubStringUTF8(str, 1, 100)
                    end
                    self.content_str = str
                    self.label_content:setString(str)
                else
                    self.label_content:setString(self.default_content_msg)
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

    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview_size = self.item_scrollview:getContentSize()

    self.look_btn = self.main_container:getChildByName("look_btn")
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("提 交"))
end

function RoleReportedPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickBtnComfirm) ,true, 1)

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.RoleData.data_role_const.game_rule1
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end ,true, 1)

    for i,box in ipairs(self.checkbox_list) do
        box:addEventListener(function ( sender,event_type )
            playButtonSound2()
            self.select_checkbox = i
            self:setSelectCheckBox()
        end)
    end

    self:addGlobalEvent(RoleEvent.ROLE_REPORTED_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)
end

--提交
function RoleReportedPanel:onClickBtnComfirm()
    if not self.data then return end
    local content = self.content_str or ""

    local _type = self.select_checkbox --举报类型
    local msg = self.content_str or ""
    local history = {}
    if self.show_list then
        for i,v in ipairs(self.show_list) do
            if v.is_select then
                table_insert(history, {id = v.id})
            end
        end
    end
    controller:send12770(self.rid, self.srv_id, _type,  msg, history)
    self:onClickBtnClose()
end

--关闭
function RoleReportedPanel:onClickBtnClose()
    controller:openRoleReportedPanel(false)
end

--设置选择框
function RoleReportedPanel:setSelectCheckBox()
    if not self.select_checkbox then return end
    if not self.checkbox_list then return end

    for i,box in ipairs(self.checkbox_list) do
        if self.select_checkbox == i then
            box:setSelected(true)
        else
            box:setSelected(false)
        end
    end
end

--@rid id
--@srv_id 服务器id
--@_type
function RoleReportedPanel:openRootWnd(rid, srv_id, play_name)
    if not rid then return end
    if not srv_id then return end
    if not play_name then return end
    self.rid = rid
    self.srv_id = srv_id
    self.play_name = play_name
    self.reported_name:setString(play_name)
    controller:send12771(rid, srv_id)
end

function RoleReportedPanel:setData(data)
    self.data = data
    local channel_name = {
        [ChatConst.Channel.World] = TI18N("世界"),
        [2] = TI18N("公会"),
        [3] = TI18N("私聊"),
        [4] = TI18N("系统"),
        [ChatConst.Channel.Cross] = TI18N("跨服"),
        [ChatConst.Channel.Province] = TI18N("同省")
    }

    table_sort(self.data.history,  function(a, b) return a.id < b.id end)

    self.show_list = {}
    for i,v in ipairs(self.data.history) do
        local channel_str 
        channel_str = channel_name[v.channel]
        if channel_str == nil then
            channel_str = TI18N("未知")
        end
        local msg = self:filterFace(v.msg)
        v.show_info = string_format("[%s] <div fontcolor=#249003>%s:</div> %s", channel_str, self.play_name, msg)
        if msg and string_len(msg) > 0 then
            table_insert(self.show_list, v)
        end
    end
    
    self:updateList()
end


--过滤表情
function RoleReportedPanel:filterFace(msg)
    if not msg then return end
    
    local len = string_len(msg)
    if len == 0 then
        return ""
    end
    local pos, pos1 = string_find(msg, "(#%d+)")
    if pos == nil then
        return msg
    end

    --表情最多就三位(#99).多就不算了
    if pos1 > pos + 2 then
        pos1 = pos + 2 
    end 

    local str1 = ""
    local str2 = ""
    if pos == 1 then
        if pos1 >= len then
            return ""
        end
        str2 = string_sub(msg, pos1+1, len)
    elseif pos1 >= len then
        str1 = string.sub(msg, 1, pos -1)
    else
        str1 = string.sub(msg, 1, pos -1)
        str2 = string.sub(msg, pos1+1, len)
    end
    local msg = str1..str2
    return self:filterFace(msg)
end



function RoleReportedPanel:updateList()
    if not self.show_list then return end
    -- self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    -- self.item_scrollview:setScrollBarEnabled(false)
    -- self.item_scrollview:setSwallowTouches(false)
    -- self.item_scrollview_size = self.item_scrollview:getContentSize()
    local total_height = self:initPositionInfo() or 0
    local max_height = math.max(self.item_scrollview_size.height, total_height)
    self.item_scrollview:setInnerContainerSize(cc.size(self.item_scrollview_size.width,max_height))

    if max_height == self.item_scrollview_size.height then
        self.item_scrollview:setTouchEnabled(false)
    else
        self.item_scrollview:setTouchEnabled(true)
    end

    for i,v in ipairs(self.item_list) do
        v:setVisible(false)
    end
    for i,v in ipairs(self.show_list) do
        if self.item_list[i] == nil then
            self.item_list[i] =  RoleReportedItem.new()
            self.item_scrollview:addChild(self.item_list[i])
        else
            self.item_list[i]:setVisible(true)
        end
        self.item_list[i]:setPosition(0, max_height - v.y)
        self.item_list[i]:setData(v)
    end
end

--初始化位置信息 返回高度
function RoleReportedPanel:initPositionInfo( )
    if not self.show_list then return end
    if self.test_content == nil then
        self.test_content = createRichLabel(24, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0,1), cc.p(-10000,257), 6, nil, 400)
        self.main_container:addChild(self.test_content)
    end
    local height = 0
    local single_height = RoleReportedItem.HEIGHT - RoleReportedItem.OFFSET
    for i,v in ipairs(self.show_list) do
        self.test_content:setString(v.show_info)
        v.y = height
        local size = self.test_content:getContentSize()
        if size.height > single_height then
            height = height + size.height + RoleReportedItem.OFFSET 
            v.is_middle = false
        else
            height = height + RoleReportedItem.HEIGHT
            v.is_middle = true
        end
        height = height + self.space_y
    end
    return height
end


function RoleReportedPanel:close_callback()

    controller:openRoleReportedPanel(false)
end



------------------------------------------
-- 子项
RoleReportedItem = class("RoleReportedItem", function()
    return ccui.Widget:create()
end)

RoleReportedItem.WIDTH = 475
RoleReportedItem.HEIGHT = 54

RoleReportedItem.OFFSET = 6

function RoleReportedItem:ctor()
    self:configUI(RoleReportedItem.WIDTH, RoleReportedItem.HEIGHT)
    self:register_event()
end

function RoleReportedItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self:setAnchorPoint(cc.p(0,1))
    local csbPath = PathTool.getTargetCSB("roleinfo/role_reported_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.checkbox = self.root_wnd:getChildByName("checkbox")
    self.checkbox:setSelected(false)
    --购买描述
    local y = RoleReportedItem.HEIGHT - RoleReportedItem.OFFSET
    self.msg_label = createRichLabel(24, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0,1), cc.p(70, y), 2, nil, 400)
    self.root_wnd:addChild(self.msg_label)
end

function RoleReportedItem:register_event( )
    self.checkbox:addEventListener(function ( sender,event_type )
        playButtonSound2()
        if self.data then
            self.data.is_select = self.checkbox:isSelected()
        end
    end)
end

function RoleReportedItem:setData( data )
    if not data then return end
    self.data = data
    self.msg_label:setString(data.show_info)
    if data.is_middle then
        self.msg_label:setPositionY(40)
    end
end

function RoleReportedItem:DeleteMe( )

    self:removeAllChildren()
    self:removeFromParent()
end

