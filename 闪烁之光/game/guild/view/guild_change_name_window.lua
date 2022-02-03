-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会改名面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildChangeNameWindow = GuildChangeNameWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format

function GuildChangeNameWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Mini
	self.set_index = 1
	self.condition_index = 1
	self.layout_name = "guild/guild_change_name_window"
end

function GuildChangeNameWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale()) 

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    self.close_btn = container:getChildByName("close_btn")
    self.confirm_btn = container:getChildByName("confirm_btn")
    self.cost_value = container:getChildByName("cost_value")

    local res = PathTool.getResFrame("common", "common_99998")
    self.edit_title = createEditBox(container, res, cc.size(307, 50), nil, 22, Config.ColorData.data_color4[151], 22, TI18N("公会名字最多六个字"), nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_title:setAnchorPoint(cc.p(0, 0.5))
    self.edit_title:setPlaceholderFontColor(Config.ColorData.data_color4[151])
    self.edit_title:setFontColor(Config.ColorData.data_color4[175])
    self.edit_title:setPosition(cc.p(220, 232))
    self.edit_title:setMaxLength(12) 

    local confirm_label = self.confirm_btn:getChildByName("label")
    confirm_label:setString(TI18N("确定"))

    local win_title  = container:getChildByName("win_title")
    win_title:setString(TI18N("公会改名"))

    local notice = container:getChildByName("notice")
    notice:setString(TI18N("公会大名：")) 

    local cost_title = container:getChildByName("cost_title")
    cost_title:setString(TI18N("改名消耗："))
    local item_img = container:getChildByName("item_img")
    item_img:setScale(0.35)
    local item_config = Config.ItemData.data_get_data(3)
    local res = PathTool.getItemRes(item_config.icon)
    loadSpriteTexture(item_img, res, LOADTEXT_TYPE)
end

function GuildChangeNameWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openGuildChangeNameWindow(false) 
        end
    end) 
    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.role_vo ~= nil then
                local target_name = self.edit_title:getText()
                if target_name == "" then
                    message(TI18N("公会名字不能为空！"))
                elseif target_name == self.role_vo.gname then
                    message(TI18N("公会名字不能与当前一样！")) 
                else
                    controller:requestChangGuildName(target_name)
                end
            end
        end
    end) 
end

function GuildChangeNameWindow:openRootWnd()
    local config  = Config.GuildData.data_const.rename_gold 
    if self.role_vo == nil then
        self.role_vo = RoleController:getInstance():getRoleVo()
    end 
    if config ~= nil and self.role_vo ~= nil then
        local self_total = self.role_vo.gold + self.role_vo.red_gold
        if config.val > self_total then     -- 预留可能会变色
        else
        end
        self.cost_value:setString(string.format("%s/%s", MoneyTool.GetMoneyString(self_total), config.val))
    end
end

function GuildChangeNameWindow:close_callback()
    controller:openGuildChangeNameWindow(false)
end
