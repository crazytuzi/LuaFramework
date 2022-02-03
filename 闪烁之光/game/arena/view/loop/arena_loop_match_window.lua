-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      竞技场循环赛面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopMatchWindow = ArenaLoopMatchWindow or BaseClass(BaseView)

local controller = ArenaController:getInstance() 
local model = ArenaController:getInstance():getModel()

function ArenaLoopMatchWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true

    self.cur_type = 0

    self.title_str = TI18N("竞技场")

    self:initConfig()
    --结算跳转回来这里的用途 --by lwc
    self.check_class_name = "ArenaLoopMatchWindow" 
    self.panel_list = {}
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
    }

    self.tab_info_list = {
        {label = TI18N("挑战"), index = ArenaConst.loop_index.challenge, status = true},
        {label = TI18N("排名榜"),index = ArenaConst.loop_index.rank, status = RankController:getInstance():checkRankIsShow(), notice = string.format(TI18N("%d级开启"), RankConstant.limit_open_lev)},
        {label = TI18N("日常奖励"),index = ArenaConst.loop_index.activity, status = true},
        {label = TI18N("排名奖励"),index = ArenaConst.loop_index.awards, status = true},
    }
end

function ArenaLoopMatchWindow:initConfig()
    local id = BattleController:getInstance():curBattleResId(BattleConst.Fight_Type.Arena)
    self.background_path = string.format("resource/bigbg/battle_bg/%s/b_bg.jpg", id)
end


function ArenaLoopMatchWindow:open_callback()
end

function ArenaLoopMatchWindow:register_event()
    if self.update_my_data == nil then
        self.update_my_data = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateMyLoopData, function(key, value)
            self:updateMyInfoData(key, value)
        end)
    end

    -- 这里会计算一下红点状态
    if self.update_challenge_activity == nil then
        self.update_challenge_activity = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateLoopChallengeTimesList, function()
            self:updateChallengeActivityStatus()
        end)
    end

    if self.update_arena_red_event == nil then
        self.update_arena_red_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateArenaRedStatus, function(type, status)
            self:checkActivityStstus(type, status)
        end)
    end
end

function ArenaLoopMatchWindow:openRootWnd(type)
    type = type or ArenaConst.loop_index.challenge
    self:setSelecteTab(type, true)

    -- 判断活跃宝箱标签是否要显示红点
    self:checkActivityStstus()
end

function ArenaLoopMatchWindow:selectedTabCallBack(index)
    self:changeTabPanel(index)
end

function ArenaLoopMatchWindow:changeTabPanel(index)
    if self.cur_panel ~= nil then
        self.cur_panel:setNodeVisible(false)
        self.cur_panel = nil
    end
    self.cur_type  = index
    self.cur_panel = self.panel_list[index]
    if self.cur_panel == nil then
        if index == ArenaConst.loop_index.challenge then
            self.cur_panel = ArenaLoopChallengePanel.new()
        elseif index == ArenaConst.loop_index.activity then
            self.cur_panel = ArenaLoopActivityPanel.new()
        elseif index == ArenaConst.loop_index.rank then
            self.cur_panel = ArenaLoopRankPanel.new()
        elseif index == ArenaConst.loop_index.awards then
            self.cur_panel = ArenaLoopAwardsPanel.new()
        end
        self.panel_list[index] = self.cur_panel
        self.container:addChild(self.cur_panel)
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent()
        end
    end
    if self.cur_panel ~= nil then
        self.cur_panel:setNodeVisible(true)
        if self.cur_panel.updatePanelInfo then
            self.cur_panel:updatePanelInfo(false)
        end
    end
end

--[[
    @desc:针对需要根据自身信息做更新的面板
    author:{author}
    time:2018-05-14 21:43:04
    --@key:
	--@value: 
    return
]]
function ArenaLoopMatchWindow:updateMyInfoData()
    if self.cur_panel ~= nil and self.cur_panel.updatePanelInfo then
        self.cur_panel:updatePanelInfo(true)
    end
end

--[[
    @desc:添加宝箱标签页红点，以及如果是当前标签，则更新相关数据的
    author:{author}
    time:2018-05-14 21:43:19
    return
]]
function ArenaLoopMatchWindow:updateChallengeActivityStatus()
    local panel = self.panel_list[ArenaConst.loop_index.activity]
    if panel ~= nil then
        panel:updatePanelInfo(true)
    end
end

function ArenaLoopMatchWindow:checkActivityStstus(type, status)
    if type == nil then
        local red_status = model:getLoopMatchRedStatus(ArenaConst.red_type.loop_challenge)
        -- self:setTabTips(red_status, ArenaConst.loop_index.challenge)

        red_status = model:getLoopMatchRedStatus(ArenaConst.red_type.loop_artivity)
        self:setTabTips(red_status, ArenaConst.loop_index.activity)
    else
        if type == ArenaConst.red_type.loop_challenge then
            -- self:setTabTips(status, ArenaConst.loop_index.challenge)
        elseif type == ArenaConst.red_type.loop_artivity then
            self:setTabTips(status, ArenaConst.loop_index.activity)
        elseif type == ArenaConst.red_type.loop_log then
            if self.cur_type == ArenaConst.loop_index.challenge then
                if self.cur_panel and self.cur_panel.updateMyLogTips then
                    self.cur_panel:updateMyLogTips()
                end
            end
        end
    end
end

function ArenaLoopMatchWindow:beforeClose()
    controller:openArenaEnterWindow(true)
end

function ArenaLoopMatchWindow:close_callback()
    -- 还原ui战斗类型
    MainuiController:getInstance():resetUIFightType()
    
    controller:openArenaLoopMathWindow(false, self.cur_type)
    if self.update_my_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_my_data)
        self.update_my_data = nil
    end

    if self.update_challenge_activity ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_challenge_activity)
        self.update_challenge_activity = nil
    end

    if self.update_arena_red_event == nil then
        GlobalEvent:getInstance():UnBind(self.update_arena_red_event)
        self.update_arena_red_event = nil
    end

    for k, panel in pairs(self.panel_list) do
        if panel.DeleteMe then
            panel:DeleteMe()
        end
    end
    self.panel_list = nil
end