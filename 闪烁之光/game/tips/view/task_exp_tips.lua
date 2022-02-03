-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      荣誉墙 任务历练 tips
-- <br/> 2019年6月3日
-- --------------------------------------------------------------------
TaskExpTips = TaskExpTips or BaseClass(BaseView)

local controller = TipsController:getInstance()

function TaskExpTips:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/task_exp_tips"
    self.win_type = WinType.Mini   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {}
end

function TaskExpTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_panel")
    self.task_name = self.main_container:getChildByName("task_name")
    self.have_time = self.main_container:getChildByName("have_time")
    self.player_name_key = self.main_container:getChildByName("player_name_key")
    self.player_name_key:setString(TI18N("达成者:"))
    self.player_name = self.main_container:getChildByName("player_name")

    self.task_desc = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5), cc.p(38,80), nil, nil, 370)
    self.main_container:addChild(self.task_desc)
    
    -- self.close_btn = self.main_container:getChildByName("close_btn")
end

function TaskExpTips:register_event()
    registerButtonEventListener(self.background, function() self:onCloseBtn()  end ,false, 2)
    -- registerButtonEventListener(self.close_btn, function() self:onCloseBtn()  end ,true, 2)

end

function TaskExpTips:onCloseBtn(  )
    controller:openTaskExpTips(false)
end
--@setting.id Config.RoomFeatData.data_exp_info 表的id
--@setting.finish_time 完成时间
--@setting.have_name 玩家名字
function TaskExpTips:openRootWnd(setting)
    local setting = setting or {}
    local id = setting.id
    local finish_time = setting.finish_time or 0
    local have_name = setting.have_name or ""

    local config = Config.RoomFeatData.data_exp_info[id]
    if config then
        self.task_name:setString(config.name)        
        self.task_desc:setString(config.desc)
    end
    self.have_time:setString(TimeTool.getYMD3(finish_time or 0))
    
    self.player_name:setString(have_name)
end




function TaskExpTips:close_callback()

    controller:openTaskExpTips(false)
end