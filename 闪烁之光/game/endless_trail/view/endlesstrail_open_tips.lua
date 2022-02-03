-- --------------------------------------------------------------------
-- 
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      下一类型副本开启提示
-- <br/>Create: 2020-3-12
-- --------------------------------------------------------------------
EndlessOpenTips = EndlessOpenTips or BaseClass(BaseView)

local controller = Endless_trailController:getInstance()
local model = Endless_trailController:getInstance():getModel()
local string_format = string.format

function EndlessOpenTips:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.item_list = {}
    self.is_full_screen = false
    self.layout_name = "endlesstrail/endlesstrail_open_tips"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("endless","endless_bg_1"), type = ResourcesType.single },
	}
end

function EndlessOpenTips:open_callback()
    self.background_panel = self.root_wnd:getChildByName("background_panel")
    self.background = self.background_panel:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
    
    self.icon_img = self.main_panel:getChildByName("icon_img")
    self.desc_label = self.main_panel:getChildByName("desc_label")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn.label = self.ok_btn:getChildByName("label")
    self.ok_btn.label:setString(TI18N("确 定"))
    self.title_container = self.main_panel:getChildByName("title_container")
    self.title_label = self.title_container:getChildByName("title_label")
    self.title_label:setString("")
    self.time_label = self.main_panel:getChildByName("time_label")
    
end

function EndlessOpenTips:register_event()
    registerButtonEventListener(self.background_panel, function()
        controller:openEndlessOpenTips(false) 
    end,false, 2)
    
    registerButtonEventListener(self.close_btn, function()
        controller:openEndlessOpenTips(false) 
    end,true, 2)

    registerButtonEventListener(self.ok_btn, function()
        controller:openEndlessOpenTips(false) 
    end,true, 2)
end

function EndlessOpenTips:setData( )
    local data = model:getEndlessData()
    if not data then
        return
    end

    local type_conf = Config.EndlessData.data_new_type[data.next_type]
    if not type_conf then
        return
    end
    
    self.title_label:setString(type_conf.title)
    self.desc_label:setString(type_conf.describe)
    local res = PathTool.getPlistImgForDownLoad("endless", "icon_"..type_conf.icon, false)
    self.icon_img_load = loadSpriteTextureFromCDN(self.icon_img, res, ResourcesType.single, self.icon_img_load)
    local time = data.next_time
    commonCountDownTime(self.time_label, time, {callback = function(time) self:setTimeFormatString(time) end})
end

function EndlessOpenTips:setTimeFormatString(time)
    if time > 0 then
        self.time_label:setString(string_format(TI18N("%s后开启"),TimeTool.GetTimeFormatDayIIIIIII(time)))
    else
        self.time_label:setString("")
    end
end

function EndlessOpenTips:openRootWnd()
    self:setData()
end



function EndlessOpenTips:close_callback()
    doStopAllActions(self.time_label)
    if self.icon_img_load then 
        self.icon_img_load:DeleteMe()
        self.icon_img_load = nil
    end
    controller:openEndlessOpenTips(false)
end
