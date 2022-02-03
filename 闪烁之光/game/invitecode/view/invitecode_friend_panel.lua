--**************************
--已邀请好友
--**************************
InviteCodeFriendPanel = class("InviteCodeFriendPanel", function()
    return ccui.Widget:create()
end)
local controller = InviteCodeController:getInstance()
local string_format = string.format
function InviteCodeFriendPanel:ctor()  
    self:layoutUI()
    self:registerEvents()
end
function InviteCodeFriendPanel:layoutUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("invitecode/invitecode_friend_panel"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(720,640))

    local main_container = self.root_wnd:getChildByName("main_container")
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = InviteCodeFriendItem,      -- 单元类
        start_x = 16,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                    -- y方向的间隔
        item_width = 690,               -- 单元的尺寸width
        item_height = 117,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    self.empty_bg = main_container:getChildByName("empty_bg")
	self.empty_bg:setVisible(false)
	self.empty_bg:getChildByName("Text_2"):setString(TI18N("暂无邀请的用户，赶快去邀请吧~"))

	--初始化好友
    self:setFriendList()
end

function InviteCodeFriendPanel:setFriendList()
	if self.item_scrollview then
		local list = controller:getModel():getAlreadyFriendData()
		if #list == 0 then
			self.empty_bg:setVisible(true)
			loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3'), LOADTEXT_TYPE)
		else
			self.empty_bg:setVisible(false)
			self.item_scrollview:setData(list)
		end
	end
end

function InviteCodeFriendPanel:registerEvents()
	if not self.bind_updata_event then
        self.bind_updata_event = GlobalEvent:getInstance():Bind(InviteCodeEvent.InviteCode_BindRole_Updata_Event,function()
        	if self.empty_bg then
                self.empty_bg:setVisible(false)
            end
        	local list = controller:getModel():getAlreadyFriendData()
        	if self.item_scrollview then
                self.item_scrollview:resetAddPosition(list)
			end
        end)
    end
end
function InviteCodeFriendPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function InviteCodeFriendPanel:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    if self.bind_updata_event then
        GlobalEvent:getInstance():UnBind(self.bind_updata_event)
        self.bind_updata_event = nil
    end
end

--******************
--已邀请好友子项
InviteCodeFriendItem = class("InviteCodeFriendItem", function()
    return ccui.Widget:create()
end)

function InviteCodeFriendItem:ctor()
    self:configUI()
    self:register_event()
end

function InviteCodeFriendItem:configUI()
    self.rootWnd = createCSBNote(PathTool.getTargetCSB("invitecode/invitecode_friend_item"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.rootWnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(690,117))

    local main_container = self.rootWnd:getChildByName("main_container")
    self.btn_chat = main_container:getChildByName("btn_chat")
    main_container:getChildByName("Text_2"):setString(TI18N("战力："))
    self.power_text = main_container:getChildByName("power_text")
    self.power_text:setString("0")
    self.name_text = main_container:getChildByName("name_text")
    self.name_text:setString("")

    self.play_head = PlayerHead.new(PlayerHead.type.circle)
    main_container:addChild(self.play_head)
    self.play_head:setPosition(cc.p(67,62))
    self.play_head:setAnchorPoint(cc.p(0.5,0.5))
    self.play_head:setTouchEnabled(true)

    self.vip_num = CommonNum.new(19, main_container, 1, 1, cc.p(0, 0))
    self.vip_num:setPosition(162, 87)
end
function InviteCodeFriendItem:setData(data)
    if not data or next(data) == nil then return end
    self.data = data

    self.vip_num:setNum(data.vip or 0)
    local face = data.face or data.face_id
    self.play_head:setHeadRes(face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
    self.play_head:setLev(data.lev)
    self.power_text:setString(data.power)
    
    local server_type = RoleController:getInstance():isTheSameSvr(data.srv_id)
    local server_name = "跨服"
    if server_type == true then
        server_name = "本服"
    end
    local is_return_text = ""
    if data.is_return == 1 then
        is_return_text = "( 回归 )"
    end
    local str = string_format(TI18N("[%s]%s  %s"),server_name,data.name,is_return_text)
    self.name_text:setString(str)
end
function InviteCodeFriendItem:register_event()
    registerButtonEventListener(self.btn_chat, function()
        if self.data then
            local temp_data = {}
            temp_data.rid = self.data.rid
            temp_data.srv_id = self.data.srv_id
            ChatController:getInstance():openChatPanel(ChatConst.Channel.Friend,"friend",temp_data)
        end
    end,true, 1)
    registerButtonEventListener(self.play_head, function(param,sender,event_type)
        if self.data then
            local roleVo = RoleController:getInstance():getRoleVo()
            local touchPos = cc.p(sender:getTouchEndPosition().x+320,sender:getTouchEndPosition().y)
            local rid = self.data.rid
            local srv_id = self.data.srv_id
            if roleVo.rid== rid and roleVo.srv_id == srv_id then return end
            local vo = {rid = rid, srv_id = srv_id}
            ChatController:getInstance():openFriendInfo(vo,touchPos)
        end
    end,true, 1)
end
function InviteCodeFriendItem:DeleteMe()
    if self.play_head then 
        self.play_head:DeleteMe()
        self.play_head = nil
    end
    if self.vip_num then
        self.vip_num:DeleteMe()
        self.vip_num = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end