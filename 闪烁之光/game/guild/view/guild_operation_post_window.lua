-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      任命或者免职以及踢人面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildOperationPostWindow = GuildOperationPostWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format

function GuildOperationPostWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Mini
	self.set_index = 1
	self.condition_index = 1
	self.layout_name = "guild/guild_operation_post_window"
end 

function GuildOperationPostWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale()) 
    
    local container = self.root_wnd:getChildByName("container")
    
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("管理设置"))
    self.notice = container:getChildByName("notice")
    self.close_btn = container:getChildByName("close_btn")

    self.setleader_btn = container:getChildByName("setleader_btn")              -- 转让会长
    self.setleader_btn:getChildByName("label"):setString(TI18N("转让会长"))

    self.setmember_btn = container:getChildByName("setmember_btn")              -- 设置副会长或者罢免
    self.setmember_btn_label = self.setmember_btn:getChildByName("label")       

    self.center_y = self.setmember_btn:getPositionY()

    self.kickout_btn = container:getChildByName("kickout_btn")                  -- 踢人
    self.kickout_btn:getChildByName("label"):setString(TI18N("移除出公会")) 
end

function GuildOperationPostWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openGuildOperationPostWindow(false)
        end
    end)
    registerButtonEventListener(self.background, function()
        controller:openGuildOperationPostWindow(false)
    end ,false, 2)

    registerButtonEventListener(self.setleader_btn,function()
        if self.data ~= nil then
            local str = string.format(TI18N("转让后您的身份将变为普通成员，是否确认将会长职位转让给【%s】？"),self.data.name)
            local function call_back()
                controller:requestOperationPost(self.data.rid, self.data.srv_id, GuildConst.post_type.leader) 
            end
            CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil,{timer=5, timer_for=true, off_y = 10},26)
        end
    end,true)


    self.setmember_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if sender.index ~= nil and self.data ~= nil then
                controller:requestOperationPost(self.data.rid, self.data.srv_id, sender.index)
            end
        end
    end) 
    self.kickout_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data ~= nil then
                controller:requestKickoutMember(self.data.rid, self.data.srv_id, self.data.name)
            end
        end
    end)  
end

--==============================--
--desc:
--time:2018-06-05 11:19:48
--@list: 列表中 对应的1：转让会长 2：任命副会长 3：罢免副会长 4：踢出公会
--@return 
--==============================--
function GuildOperationPostWindow:openRootWnd(data)
    if data ~= nil then
        self.data = data
        self.notice:setString(string.format(TI18N("你要对【%s】玩家执行的操作是"), data.name))
        if data.role_post == GuildConst.post_type.leader then
            if data.post == GuildConst.post_type.assistant then     -- 自己是帮主，目标是帮帮主
                self.setmember_btn_label:setString(TI18N("罢免副会长")) 
                self.setmember_btn.index = GuildConst.post_type.member
            else
                self.setmember_btn.index = GuildConst.post_type.assistant
                self.setmember_btn_label:setString(TI18N("任命副会长")) 
            end
        elseif data.role_post == GuildConst.post_type.assistant then    -- 自己是帮帮主
            if data.post == GuildConst.post_type.member then            -- 目标是成员，只有踢出
                self.kickout_btn:setPositionY(self.center_y)
                self.setleader_btn:setVisible(false)
                self.setmember_btn:setVisible(false) 
            else
                self.kickout_btn:setVisible(false)
                self.setleader_btn:setVisible(false)
                self.setmember_btn:setVisible(false) 
            end 
        end
    end
end

function GuildOperationPostWindow:close_callback()
    CommonAlert.closeAllWin()
    controller:openGuildOperationPostWindow(false)
end