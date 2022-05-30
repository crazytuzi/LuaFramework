-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: @syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      新人练武场排行榜主界面
-- <br/>Create: 2020-4-12
-- --------------------------------------------------------------------
PractisetowerRankWindow = PractisetowerRankWindow or BaseClass(BaseView)

local controller = PractisetowerController:getInstance()
local model = controller:getModel()
local string_format = string.format


function PractisetowerRankWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        
    }
    self.layout_name = "practisetower/practise_tower_rank_window"

    self.view_list = {}
end

function PractisetowerRankWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    -- 通用进场动效
    ActionHelp.itemUpAction(self.main_container, 720, 0, 0.25)

    self.container = self.main_container:getChildByName("container")
    
    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("排行榜"))

    self.close_btn = main_panel:getChildByName("close_btn")

    self.time_lab = main_panel:getChildByName("time_lab")

    self.tab_container = self.main_container:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("排行榜"),
        [2] = TI18N("排行奖励"),
    }
    self.tab_item_type = {
        [1] = PractisetowerEvent.type.rank,
        [2] = PractisetowerEvent.type.reward,
    }
    self.tab_list = {}
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.title = tab_btn:getChildByName("title")
            object.title:setTextColor(Config.ColorData.data_new_color4[6])
            if tab_name_list[i] then
                object.title:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = self.tab_item_type[i] or PractisetowerEvent.type.rank
            self.tab_list[i] = object
        end
    end
end

function PractisetowerRankWindow:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

end

--关闭
function PractisetowerRankWindow:onClosedBtn()
    controller:openRankWindow(false)
end

--开启的tips倒计时
function PractisetowerRankWindow:setTimeValFormatString(time)
    if time > 0 then
        local str = string_format(TI18N("剩余时间：%s"), TimeTool.GetTimeFormatDayIIIIIIII(time))
        self.time_lab:setString(str)
    else
        self.time_lab:setString("")
    end
end

-- 切换标签页
function PractisetowerRankWindow:changeSelectedTab( index )
    if self.tab_object and self.tab_object.index == index then return end

    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.title:setTextColor(Config.ColorData.data_new_color4[6])
        self.tab_object.title:disableEffect(cc.LabelEffect.SHADOW)
        self.tab_object = nil
    end
    self.cur_tab_index = index
    self.tab_object = self.tab_list[index]

    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.title:setTextColor(Config.ColorData.data_new_color4[1])
        self.tab_object.title:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    end
    if self.pre_panel then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        else
            self.pre_panel:setVisible(false)
        end
    end

    self.pre_panel = self:createSubPanel(self.cur_tab_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        else
            self.pre_panel:setVisible(true)
        end
    end

end

function PractisetowerRankWindow:createSubPanel(index)
    if not self.view_list then return end

    local panel = self.view_list[index]
    if panel == nil then
        if index == PractisetowerEvent.type.rank then --排行榜
            panel = PractisetowerRankPanel.new() 
        elseif index == PractisetowerEvent.type.reward then --排行奖励
            panel = PractisetowerAwardsPanel.new()
        end
        
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end


function PractisetowerRankWindow:openRootWnd()
    if not self.tab_item_type then return end
    
    self:changeSelectedTab(PractisetowerEvent.type.rank)

    local scdata = model:getPractiseTowerData()
    if scdata then
        local time = scdata.last_unixtime-GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.time_lab, time, {callback = function(time) self:setTimeValFormatString(time) end})
    end
end


function PractisetowerRankWindow:close_callback()
    doStopAllActions(self.time_lab)
    if self.view_list then
        for i,v in pairs(self.view_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.view_list = nil
    controller:openRankWindow(false)
end
