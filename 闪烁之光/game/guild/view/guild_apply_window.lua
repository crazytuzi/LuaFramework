-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会申请列表
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildApplyWindow = GuildApplyWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format

function GuildApplyWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Big
	self.title_str = TI18N("申请列表")
end

function GuildApplyWindow:open_callback()
	local main_view = createCSBNote(PathTool.getTargetCSB("guild/guild_apply_window"))
	self.container:addChild(main_view)
	
    main_view:getChildByName("Text_1"):setString(TI18N("可通过点击列表中玩家的头像查看玩家信息哦"))
    self.item_gods = main_view:getChildByName("item_gods")

    self.empty_tips = main_view:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("当前没有申请列表"))
end

function GuildApplyWindow:register_event()
    if self.update_apply_event == nil then
        self.update_apply_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateApplyListInfo, function() 
            self:updateApplyList()
        end)
    end
end

function GuildApplyWindow:openRootWnd()
    controller:requestGuildApplyList()
    model:clearApplyRedStatus()
end

function GuildApplyWindow:updateApplyList()
    local list = model:getGuildApplyList()
    if next(list) == nil then
        self.empty_tips:setVisible(true)
        if self.scroll_view then
            self.scroll_view:setVisible(false)
        end
    else
        self.empty_tips:setVisible(false) 
        if self.scroll_view == nil then
            local item_gods_size = self.item_gods:getContentSize()
            local list_setting = {
                item_class = GuildApplyItem,
                start_x = 4,
                space_x = 0,
                start_y = 0,
                space_y = - 3,
                item_width = 600,
                item_height = 135,
                row = 0,
                col = 1
            }
            self.scroll_view = CommonScrollViewLayout.new(self.item_gods, cc.p(0, 5), nil, nil, item_gods_size, list_setting) 
        end
        self.scroll_view:setData(list)
    end
end

function GuildApplyWindow:close_callback()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    if self.update_apply_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_apply_event)
        self.update_apply_event = nil
    end
    controller:openGuildApplyWindow(false)
end



-- -------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      申请列表danlie
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildApplyItem = class("GuildApplyItem", function()
	return ccui.Layout:create()
end)

function GuildApplyItem:ctor()
	self.awards_list = {}           -- 富文本奖励列表
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guild/guild_apply_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	local container = self.root_wnd:getChildByName("container")

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.cancel_btn = container:getChildByName("cancel_btn")
    self.role_name = container:getChildByName("role_name")
    self.role_online = container:getChildByName("role_online")

    self.confirm_btn:getChildByName("label"):setString(TI18N("接受"))
    self.cancel_btn:getChildByName("label"):setString(TI18N("忽略")) 

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(70, 63)
    container:addChild(self.role_head)
    self.role_head:setLev(99) 
	
	self:registerEvent()
end

function GuildApplyItem:registerEvent()	
	self.confirm_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            if self.data ~= nil then
                controller:requestOperationApply(1, self.data.rid, self.data.srv_id)
            end
		end
	end)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data ~= nil then
                controller:requestOperationApply(2, self.data.rid, self.data.srv_id)
            end 
        end
    end)
    self.role_head:addCallBack(function()
        if self.data ~= nil then
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        end
    end, false)
end

function GuildApplyItem:addCallBack(call_back)
	self.call_back = call_back
end

function GuildApplyItem:setData(data)
	self.data = data
    if data ~= nil then
        if data.is_online == TRUE then
            self.role_online:setString(TI18N("在线"))
        else
            self.role_online:setTextColor(Config.ColorData.data_color4[183]) 
            self.role_online:setString(TI18N("离线")) 
        end
        self.role_name:setString(data.name)
        self.role_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.role_head:setLev(data.lev)
    end
end

function GuildApplyItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 