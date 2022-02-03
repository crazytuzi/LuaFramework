--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-30 16:53:21
-- @description    : 
		-- 对同省频道玩家举报
---------------------------------
ChatRepoprtWindow = ChatRepoprtWindow or BaseClass(BaseView)

local _controller = ChatController:getInstance()
local friend_controller = FriendController:getInstance()
local friend_model = friend_controller:getModel()

function ChatRepoprtWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Mini
	self.layout_name = "friend/chat_report_window"
end

function ChatRepoprtWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale()) 
    
    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("操作提示"))
    self.notice_txt = container:getChildByName("notice")

    self.close_btn = container:getChildByName("close_btn")
    self.friend_btn = container:getChildByName("friend_btn")
    self.friend_btn_label = self.friend_btn:getChildByName("label")
    self.friend_btn_label:setString(TI18N("加好友"))
    self.friend_btn:setVisible(false)

    self.report_btn = container:getChildByName("report_btn")
    self.report_btn:getChildByName("label"):setString(TI18N("举报"))
    self.blacklist_btn = container:getChildByName("blacklist_btn")
    self.blacklist_btn_label = self.blacklist_btn:getChildByName("label")
    self.blacklist_btn_label:setString(TI18N("加黑名单"))
end

function ChatRepoprtWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openChatReportWindow(false)
	end, false, 2)

	registerButtonEventListener(self.close_btn, function (  )
		_controller:openChatReportWindow(false)
	end, true, 2)

    registerButtonEventListener(self.friend_btn, handler(self, self.onClickFriendBtn), true)
	registerButtonEventListener(self.report_btn, handler(self, self.onClickReportBtn), true)

	registerButtonEventListener(self.blacklist_btn, handler(self, self.onClickBlacklistBtn), true)
end

function ChatRepoprtWindow:onClickFriendBtn(  )
    if not self.data then return end
    if friend_model:isFriend(self.data.srv_id,self.data.rid) then
        _controller:openChatPanel(ChatConst.Channel.Friend,"friend",self.data)
        _controller:openChatReportWindow(false)
    else
        friend_controller:addOther(self.data.srv_id,self.data.rid)
        _controller:openChatReportWindow(false)
    end
end

function ChatRepoprtWindow:onClickReportBtn(  )
	if not self.data then return end
    local role_lv_cfg = Config.RoleData.data_role_const.role_reported_lev_limit
    local role_vo = RoleController:getInstance():getRoleVo() or {}
    local lev = role_vo.lev or 0
    if role_lv_cfg and lev < role_lv_cfg.val then
        message(role_lv_cfg.val..TI18N("级开放举报功能"))
        return
    end
    RoleController:getInstance():openRoleReportedPanel(true, self.data.rid, self.data.srv_id, self.data.name)
    _controller:openChatReportWindow(false)
end

function ChatRepoprtWindow:onClickBlacklistBtn(  )
	if not self.data then return end

	if FriendController:getInstance():getModel():isBlack(self.data.rid, self.data.srv_id) then
        ChatController:getInstance():closeChatUseAction()
        FriendController:getInstance():openFriendWindow(true, FriendConst.Type.BlackList)
    else
        local call_back = function()
            FriendController:getInstance():addToBlackList(self.data.rid, self.data.srv_id)
        end
        local str = string.format(TI18N("被列入黑名单后将无法接收到该玩家发出的消息\n是否确认将<div fontColor=#289b14 fontsize= 26>%s</div>列入黑名单？\n（若为好友则会把该玩家从好友列表里删除）"), self.data.name)
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil)    
    end
    _controller:openChatReportWindow(false)
end

function ChatRepoprtWindow:openRootWnd( data, view_type )
	self.data = data
	self.view_type = view_type or 1
    self.notice_txt:setString(string.format(TI18N("您需要对玩家【%s】执行的操作是"), self.data.name or ""))
    if self.view_type == 1 then
        if friend_model:isBlack(self.data.rid, self.data.srv_id) then
            self.blacklist_btn_label:setString(TI18N("黑名单"))
        else
            self.blacklist_btn_label:setString(TI18N("加黑名单"))
        end
        self.blacklist_btn:setVisible(true)
        self.blacklist_btn:setPositionY(120)
        self.report_btn:setPositionY(238)
    else
        self.blacklist_btn:setVisible(false)
        if friend_model:isFriend(data.srv_id, data.rid) then --只有好友才有私聊
            self.friend_btn:setVisible(true)
            self.friend_btn_label:setString(TI18N("私聊"))
        elseif friend_model:isBlack(data.rid, data.srv_id) then
            self.friend_btn:setVisible(false)
            self.report_btn:setPositionY(180)
        end
    end
    
end

function ChatRepoprtWindow:close_callback(  )
	_controller:openChatReportWindow(false)
end