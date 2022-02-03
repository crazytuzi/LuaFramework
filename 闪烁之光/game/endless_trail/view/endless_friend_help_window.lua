-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼好友援助主界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessFriendHelpWindow = EndlessFriendHelpWindow or BaseClass(BaseView)

local controller = Endless_trailController:getInstance()
local model = Endless_trailController:getInstance():getModel()
local string_format = string.format

function EndlessFriendHelpWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big

    self.is_full_screen = false
    self.layout_name = "endlesstrail/endlesstrail_friend_help_window"
    self.selected_tab = nil -- 当前选中的标签
    self.tab_list = {}
    self.panel_list = {}
end

function EndlessFriendHelpWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.root_csb = self.root_wnd:getChildByName("main_container")
    self.main_panel = self.root_csb:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 1)
    self.main_view = self.main_panel:getChildByName("container")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.win_title = self.main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("好友支援"))

    local tab_container = self.main_view:getChildByName("tab_container")
    for i = 1, 2 do
        local tab_btn = tab_container:getChildByName("tab_btn_" .. i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
            if i == 1 then
                title:setString(TI18N("支援我的"))
            elseif i == 2 then
                title:setString(TI18N("我的支援"))
            end
            title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            local red_point = tab_btn:getChildByName("red_point")
            red_point:setVisible(false)
            if i == 2 then
                red_point:setVisible(model:getIsSendPartner())
            end
            tab_btn:setBright(false)
            tab_btn.index = i
            tab_btn.label = title
            tab_btn.red_point = red_point
            self.tab_list[i] = tab_btn
        end
    end
    self.scroll_container = self.main_view:getChildByName("scroll_container")
end 

function EndlessFriendHelpWindow:register_event()
    for k, tab_btn in pairs(self.tab_list) do
        tab_btn:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(sender.index)
                end
            end
        )
    end
    if self.background then
        self.background:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playCloseSound()
                    controller:openEndlessFriendHelpView(false) 
                end
            end
        )
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(
            function(sender, event_type)
                customClickAction(sender,event_type)
                if event_type == ccui.TouchEventType.ended then
                    playCloseSound()
                    controller:openEndlessFriendHelpView(false) 
                end
            end
        )
    end
     if not self.send_partner_red_point_event then
        self.send_partner_red_point_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_REDPOINT_SENDPARTNER_DATA,function()
            self:updateTabListRedPoint()
        end)
    end
end

function EndlessFriendHelpWindow:updateTabListRedPoint()
    if self.tab_list and next(self.tab_list or {}) ~= nil and self.tab_list[2] and not tolua.isnull(self.tab_list[2]) then
        local bool = model:getIsSendPartner()
        if bool == nil then
            bool = false
        end
        self.tab_list[2].red_point:setVisible(bool)
    end
end

function EndlessFriendHelpWindow:openRootWnd(type)
    type = type or Endless_trailEvent.helptype.friend
    self:changeSelectedTab(type)
end

--==============================--
--desc:切换标签页
--time:2018-06-12 10:51:51
--@index:
--@return
--==============================--
function EndlessFriendHelpWindow:changeSelectedTab(index)
    if self.selected_tab ~= nil then
        if self.selected_tab.index == index then
            return
        end
    end
    if self.selected_tab then
        self.selected_tab.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
        self.selected_tab:setBright(false)
        self.selected_tab = nil
    end
    self.selected_tab = self.tab_list[index]
    if self.selected_tab then
        self.selected_tab.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
        self.selected_tab:setBright(true)
    end
    if self.cur_panel ~= nil then
        self.cur_panel:setNodeVisible(false)
        self.cur_panel = nil
    end

    self.cur_panel = self.panel_list[index]
    if self.cur_panel == nil then
        if index == Endless_trailEvent.helptype.friend then
            self.cur_panel = EndlessHelpMePanel.new()
        elseif index ==  Endless_trailEvent.helptype.me then
            self.cur_panel = EndlessMeHelpPanel.new()
        end
        self.panel_list[index] = self.cur_panel
        self.scroll_container:addChild(self.cur_panel)
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent()
        end

    end
    self.cur_panel:setNodeVisible(true)
end

function EndlessFriendHelpWindow:close_callback()
    controller:openEndlessFriendHelpView(false)

    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = {}
    if self.send_partner_red_point_event then
        GlobalEvent:getInstance():UnBind(self.send_partner_red_point_event)
        self.send_partner_red_point_event = nil
    end
end
