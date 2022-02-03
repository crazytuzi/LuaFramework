-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      副本重置窗体
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossResetWindow = GuildBossResetWindow or BaseClass(BaseView)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()
local string_format = string.format

function GuildBossResetWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Mini
    self.reset_type_list = {}
	self.layout_name = "guildboss/guildboss_reset_window"

    self.cur_type = 0
end

function GuildBossResetWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	local container = self.root_wnd:getChildByName("container") 
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("副本重置"))
    container:getChildByName("title_desc"):setString(TI18N("请选择公会副本重置方式：")) 

    self.pass_desc = container:getChildByName("pass_desc")

    self.close_btn = container:getChildByName("close_btn")
    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))

    for i=1,2 do
        local obj = {}
        obj.reset_title = container:getChildByName("reset_title_"..i)
        obj.reset_desc = container:getChildByName("reset_desc_" .. i) 
        obj.reset_notice = container:getChildByName("reset_notice_" .. i) 
        obj.reset_checkbox = container:getChildByName("reset_checkbox_" .. i) 
        obj.reset_desc:setTextAreaSize(cc.size(235, 100))
        obj.index = (i-1)
        obj.reset_checkbox:setSelected(false) 
        self.reset_type_list[i] = obj
    end
end

function GuildBossResetWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openGuildBossResetWindow(false)
        end
    end) 
    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:requestResetGuildDun(self.cur_type)
        end
    end) 

    for k,obj in pairs(self.reset_type_list) do
        obj.reset_checkbox:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self:changeCheckBoxStatus(k)
            end
        end) 
    end
end

function GuildBossResetWindow:changeCheckBoxStatus(index)
    local object = self.reset_type_list[index]
    local check_box = object.reset_checkbox
    local selected_status = check_box:isSelected()
    for k,obj in pairs(self.reset_type_list) do
        if obj.reset_checkbox ~= check_box then
            obj.reset_checkbox:setSelected(not selected_status)
            -- 储存当前选中的
            if selected_status == false then
                self.cur_type = obj.index
            else
                self.cur_type = object.index
            end
        end
    end
end

function GuildBossResetWindow:openRootWnd()
    self:fillBaseInfo()
    self:fillResetDesc()
end

function GuildBossResetWindow:fillBaseInfo()
    local base_info = model:getBaseInfo() 
    if base_info ~= nil then
        for i,obj in ipairs(self.reset_type_list) do
            if obj.index == base_info.type then
                self.cur_type = base_info.type          -- 保存当前的
                obj.reset_checkbox:setSelected(true)
            else
                obj.reset_checkbox:setSelected(false)
            end
            obj.reset_checkbox:setTouchEnabled(base_info.fid > 1)

            if base_info.fid <= 1 then
                if i == 1 then
                    obj.reset_notice:setString(string.format(TI18N("可重置至%s章"), base_info.fid)) 
                elseif i == 2 then
                    obj.reset_notice:setTextColor(Config.ColorData.data_color4[183])
                    obj.reset_notice:setString(TI18N("(未通关第一章无法回退)")) 
                end
            else
                if i == 1 then
                    obj.reset_notice:setString(string.format(TI18N("可重置至%s章"), base_info.fid))
                elseif i == 2 then
                    obj.reset_notice:setTextColor(Config.ColorData.data_color4[181])
                    obj.reset_notice:setString(string.format(TI18N("可回退至%s章"), (base_info.fid-1)))
                end 
            end
        end
        if base_info.fid == 0 then 
            self.pass_desc:setString(TI18N("当前未通关任意章节"))
        else
            self.pass_desc:setString(string.format(TI18N("历史达到最高章节：%s章"), base_info.fid)) 
        end
    end
end

function GuildBossResetWindow:fillResetDesc()
    for i,obj in ipairs(self.reset_type_list) do
        local config = Config.GuildDunData.data_const["reset_desc_"..obj.index]
        if config ~= nil then
            obj.reset_title:setString(config.val) 
            obj.reset_desc:setString(config.desc)
        end
    end
end

function GuildBossResetWindow:close_callback()
    controller:openGuildBossResetWindow(false)
end