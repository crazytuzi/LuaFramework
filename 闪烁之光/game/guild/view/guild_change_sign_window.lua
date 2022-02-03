-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会宣言修改
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildChangeSignWindow = GuildChangeSignWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format

function GuildChangeSignWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Mini
	self.set_index = 1
	self.condition_index = 1
	self.layout_name = "guild/guild_change_sign_window"
end 

function GuildChangeSignWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale()) 

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    self.close_btn = container:getChildByName("close_btn")
    self.confirm_btn = container:getChildByName("confirm_btn")

    local notice = container:getChildByName("notice")
    notice:setString(TI18N("公会宣言：")) 

    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("修改宣言")) 

    local confirm_label = self.confirm_btn:getChildByName("label")
    confirm_label:setString(TI18N("确定")) 

    local res = PathTool.getResFrame("common", "common_99998")
    self.edit_title  = createEditBox(container, res, cc.size(390, 130), nil, 22, Config.ColorData.data_color4[151], 22, TI18N("请输入公会宣言内容"), nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_title:setAnchorPoint(cc.p(0, 1))
    self.edit_title:setPlaceholderFontColor(Config.ColorData.data_color4[151])
    self.edit_title:setFontColor(Config.ColorData.data_color4[175])
    self.edit_title:setPosition(cc.p(174, 271))
    self.edit_title:setMaxLength(100) 
end

function GuildChangeSignWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openGuildChangeSignWindow(false)
		end
	end)
	self.confirm_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if isQingmingShield and isQingmingShield() then
                return
            end

			playButtonSound2()
            local target_name = self.edit_title:getText()
            if target_name == "" then
                message(TI18N("宣言不能为空！"))
            else
                controller:requestChangeGuildSign(target_name)
            end
		end
	end)
end 

function GuildChangeSignWindow:openRootWnd()
end

function GuildChangeSignWindow:close_callback()
    controller:openGuildChangeSignWindow(false) 
end