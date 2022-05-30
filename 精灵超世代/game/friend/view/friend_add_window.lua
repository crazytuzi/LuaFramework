-- --------------------------------------------------------------------
-- 竖版添加好友
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendAddWindow = FriendAddWindow or BaseClass(BaseView)

function FriendAddWindow:__init()
    self.ctrl = FriendController:getInstance()
    self.is_full_screen = false
    self.title_str = TI18N("添加好友")
    self.empty_res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("friend","friend"), type = ResourcesType.plist },
        { path = self.empty_res, type = ResourcesType.single },
    }

    self.win_type = WinType.Big    
    self.scroll_width = 620
    self.scroll_height = 570

    self.create_index = 1

    self.rend_list = Array.New()
    self.cache_list = {}
    self.is_init = true

    self.default_msg = TI18N("请输入玩家姓名")
end

function FriendAddWindow:open_callback()
    local csbPath = PathTool.getTargetCSB("friend/friend_find_panel")
    local root = cc.CSLoader:createNode(csbPath)
    self.container:addChild(root)

    self.main_panel = root:getChildByName("main_panel")

    self.top_panel = self.main_panel:getChildByName("top_panel")
    self.recommend_label = self.top_panel:getChildByName("recommend_label")
    self.recommend_label:setString(TI18N("推荐好友"))

    --查找好友
    self.find_btn = self.top_panel:getChildByName("find_btn")
    self.find_btn:setTitleText(TI18N("查找"))
    local title = self.find_btn:getTitleRenderer()   
    title:enableOutline(Config.ColorData.data_color4[278],2)

    --刷新按钮
    self.flash_btn = self.main_panel:getChildByName("flash_btn")
    self.flash_btn:setTitleText(TI18N("刷新"))
    local title = self.flash_btn:getTitleRenderer()   
    title:enableOutline(Config.ColorData.data_color4[278],2)

    local size = cc.size(453,52)
    local res = PathTool.getResFrame("common", "common_1021")
    self.edit_box =  createEditBox(self.main_panel, res,size, nil, 24, Config.ColorData.data_color3[151], 20, self.default_msg, nil, nil, LOADTEXT_TYPE_PLIST, nil, nil--[[, cc.KEYBOARD_RETURNTYPE_SEND]])
    self.edit_box:setAnchorPoint(cc.p(0,0))
    self.edit_box:setPlaceholderFontColor(Config.ColorData.data_color4[151])
    self.edit_box:setFontColor(Config.ColorData.data_color4[66])
    self.edit_box:setPosition(cc.p(25,730))
    self.edit_box:setMaxLength(14)
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" then
            local str = pSender:getText()
            if GmCmd and GmCmd.show_from_chat and GmCmd:show_from_chat(str) then return end
        end
    end
    if not tolua.isnull(self.edit_box) then
        self.edit_box:registerScriptEditBoxHandler(editBoxTextEventHandle)
    end

    local size = self.container:getContentSize()
    self.scroll_view = createScrollView( self.scroll_width,self.scroll_height,size.width/2,98,self.main_panel,ccui.ScrollViewDir.vertical)
    self.scroll_view:setLocalZOrder(10)
    self.scroll_view:setAnchorPoint(cc.p(0.5,0))

    self.num_label = createRichLabel(24, cc.c4b(0x76,0x45,0x19,0xff), cc.p(0,0), cc.p(89,28), 0, 0, 400)
    self.main_panel:addChild(self.num_label)

    local online_num, all_num = self.ctrl:getModel():getFriendOnlineAndTotal() 
    local str = string.format(TI18N("好友数：%s/%s"),all_num,100)
    self.num_label:setString(str)
    
   
end

function FriendAddWindow:register_event()
    --申请好友列表返回
    if not self.apply_list_event then 
        self.apply_list_event = GlobalEvent:getInstance():Bind(FriendEvent.UD_COMMEND_LIST,function(data_list)
            self:updateFriendList(data_list)
        end)
    end
    if not self.find_friend_event then 
        self.find_friend_event = GlobalEvent:getInstance():Bind(FriendEvent.FRIEND_QUERY_RESULT, function(data_list)
            
            self.recommend_label:setString(TI18N("搜索结果"))
            self:updateFriendList(data_list)
            
        end)
    end

    self.flash_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.ctrl:recommend()
            self.recommend_label:setString(TI18N("推荐好友"))
        end
    end)

    self.find_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local name = self.edit_box:getText() or ""
            if name == "" then
                message(self.default_msg)
                return
            end
            self.ctrl:queryFind(name)
        end
    end)

     --请求推荐列表
     self.ctrl:recommend()
end

--显示空白
function FriendAddWindow:showEmptyIcon(bool)
    if not self.empty_con and bool == false then return end
    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setPosition(cc.p(335,370))
        self.container:addChild(self.empty_con,100)

        local bg = createImage(self.empty_con, self.empty_res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(24,cc.c4b(0x76,0x45,0x19,0xff),nil,size.width/2,-10,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = TI18N("未搜索到玩家")
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end

function FriendAddWindow:openRootWnd(type)
    type = type or FriendConst.Type.MyFriend
end

function FriendAddWindow:updateFriendList(data_list)
    for i,v in pairs(self.cache_list) do 
        v:setVisible(false)
    end
    self.create_index = 1
    local list = Array.New()
    for i,v in pairs(data_list) do 
        list:PushBack(v)
    end
    self.rend_list = list or Array.New()

    self:showEmptyIcon(false)
    if list:GetSize()<=0 then 
        self:showEmptyIcon(true)
        return
    end
    if self.is_init == true then 
        self:setscheduleUpdate(true)
        self.is_init = false
    else
        for i=1,list:GetSize() do 
            self:createItem(list:Get(i-1))
        end
    end
end

function FriendAddWindow:setscheduleUpdate(status)
    if status == true then
        if self.queue_timer == nil then
            self.queue_timer = GlobalTimeTicket:getInstance():add(function()
                local vo = self.rend_list:Get(self.create_index-1)
                if vo then
                    self:createItem(vo)
                end
                if self.create_index >=self.rend_list:GetSize()+1 then 
                    self:setscheduleUpdate(false)
                end
            end, 1/display.DEFAULT_FPS)
        end
    else
        if self.queue_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.queue_timer)
            self.queue_timer = nil
        end
    end
end

function FriendAddWindow:createItem(vo)
    local item
    if self.cache_list[self.create_index] == nil then
        item = FriendListItem.new(self.create_index,5)
        self.cache_list[self.create_index] = item
        self.scroll_view:addChild(item)
    end
    item = self.cache_list[self.create_index]
    local offy = self.scroll_height-120*self.create_index
    item:setPosition(cc.p(self.scroll_view:getContentSize().width/2,offy))
    item:setVisible(true)
    item:setExtendData(5)
    item:setData(vo)
    self.create_index = self.create_index +1
end
--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function FriendAddWindow:setPanelData()
end

function FriendAddWindow:close_callback()
    self.ctrl:openFriendFindWindow(false)
    self:setscheduleUpdate(false)
    for i,v in pairs(self.cache_list) do 
        if v and v["DeleteMe"] then 
            v:DeleteMe()
        end
    end
    self.cache_list = nil
    if self.apply_list_event then 
        GlobalEvent:getInstance():UnBind(self.apply_list_event)
        self.apply_list_event = nil
    end
    if self.find_friend_event then 
        GlobalEvent:getInstance():UnBind(self.find_friend_event)
        self.find_friend_event = nil
    end
end
