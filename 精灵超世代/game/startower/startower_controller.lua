-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--星命塔
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-07
-- --------------------------------------------------------------------
StartowerController = StartowerController or BaseClass(BaseController)

function StartowerController:config()
    self.model = StartowerModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function StartowerController:getModel()
    return self.model
end

function StartowerController:registerEvents()
end

function StartowerController:registerProtocals()
    self:RegisterProtocal(11320, "handle11320")     --星命塔信息
    self:RegisterProtocal(11321, "handle11321")     --购买挑战次数
    self:RegisterProtocal(11322, "handle11322")     --挑战星命塔
    self:RegisterProtocal(11323, "handle11323")     --推送星命塔结算
    self:RegisterProtocal(11324, "handle11324")     --扫荡星命塔
    self:RegisterProtocal(11325, "handle11325")     --请求星命塔通关录像
    self:RegisterProtocal(11326, "handle11326")     --推送星命塔有解锁
    self:RegisterProtocal(11333, "handle11333")     --分享通关录像
    self:RegisterProtocal(11327, "handle11327")     -- 星命塔排行榜

    self:RegisterProtocal(11328, "handle11328")     --通关奖励
    self:RegisterProtocal(11329, "handle11329")
end

function StartowerController:checkIsOpen(show_desc)
	local open_config = Config.StarTowerData.data_tower_const.open_floor 
	if open_config == nil then return false end

    local is_open = MainuiController:getInstance():checkIsOpenByActivate(open_config.val)
    if is_open == false and show_desc == true then
        message(open_config.desc)
    end
    return is_open
end

--==============================--
--desc:引导需要
--time:2018-07-17 11:51:36
--@return 
--==============================--
function StartowerController:getStarTowerRoot()
    if self.main_view then
        return self.main_view.root_wnd
    end
end

--==============================--
--desc:引导需要
--time:2018-07-17 12:01:44
--@return 
--==============================--
function StartowerController:getStarTowerChallengeRoot()
    if self.star_tower_window then
        return self.star_tower_window.root_wnd
    end
end

--打开主界面
function StartowerController:openMainView(bool)
    if bool == false then
        if self.main_view ~= nil then
            self.main_view:close()
            self.main_view = nil
        end
    else
        if self:checkIsOpen(true) == false then
            return
        end

        if not self.main_view then 
            self.main_view = StarTowerWindow.New()
        end
        if self.main_view and self.main_view:isOpen() == false then
            self.main_view:open()
        end
    end
end
--打开挑战主界面
function StartowerController:openStarTowerMainView(bool,data)
    if bool == true then
        if not self.star_tower_window then 
            self.star_tower_window = StarTowerMainWindow.New(data)
        end
        if self.star_tower_window and self.star_tower_window:isOpen() == false then
            self.star_tower_window:open()
        end

    else 
        if self.star_tower_window then 
            self.star_tower_window:close()
            self.star_tower_window = nil
        end
    end
end
--打开奖励总览
function StartowerController:openAwardWindow(bool)
    if bool == true then
        if not self.award_window then 
            self.award_window = StarTowerAwardWindow.New()
        end
        if self.award_window and self.award_window:isOpen() == false then
            self.award_window:open()
        end

    else 
        if self.award_window then 
            self.award_window:close()
            self.award_window = nil
        end
    end
end

--打开录像界面
function StartowerController:openVideoWindow(bool,data,tower)
    if bool == true then
        if not self.video_window then 
            self.video_window = StarTowerVideoWindow.New(data,tower)
        end
        if self.video_window and self.video_window:isOpen() == false then
            self.video_window:open()
        end

    else 
        if self.video_window then 
            self.video_window:close()
            self.video_window = nil
        end
    end
end

--==============================--
--desc:星命塔结算
--time:2018-08-01 08:43:24
--@return 
--==============================--
function StartowerController:getResultWindow()
    return self.result_window
end


--打开结算界面
function StartowerController:openResultWindow(bool,data)
    if bool == true then
        -- 不能直接出剧情或者引导
        LevupgradeController:getInstance():waitForOpenLevUpgrade(true) 
        BattleResultMgr:getInstance():setWaitShowPanel(true)
        if not self.result_window then 
            self.result_window = StarTowerResultWindow.New(data.result, BattleConst.Fight_Type.StarTower)
        end
        if self.result_window and self.result_window:isOpen() == false then
            self.result_window:open(data, BattleConst.Fight_Type.StarTower)
        end
    else 
        if self.result_window then 
            self.result_window:close()
            self.result_window = nil

            if self.is_show_lock == true and self.show_data then 
                -- self:openGetWindow(true,self.show_data.tower)
            else
                GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
            end
        end
        
        self.is_show_lock =false
        self.show_data = nil
    end
end

--打开结算界面
function StartowerController:openGetWindow(bool,data)
    if bool == true then

        if not self.get_window then 
            self.get_window = StarTowerGetWindow.New(data)
        end
        if self.get_window and self.get_window:isOpen() == false then
            self.get_window:open()
        end

    else 
        if self.get_window then 
            self.get_window:close()
            self.get_window = nil
        end
    end
end

--打开tips界面
function StartowerController:openTipsWindow(bool,data)
    if bool == true then
        if not self.tips_window then 
            self.tips_window = StarTowerTipsWindow.New()
        end
        if self.tips_window and self.tips_window:isOpen() == false then
            self.tips_window:open(data)
        end
    else 
        if self.tips_window then 
            self.tips_window:close()
            self.tips_window = nil
        end
    end
end


--请求星命塔数据
function StartowerController:sender11320()
    self:SendProtocal(11320,{})
end
function StartowerController:handle11320( data )
    self.model:setStarTowerData(data)
end

--购买挑战次数
function StartowerController:sender11321()
    local protocal ={}
    self:SendProtocal(11321,protocal)
end
function StartowerController:handle11321( data )
    message(data.msg)
    self.model:updateLessCount(data)
end
--挑战星命塔
function StartowerController:sender11322(tower)
    local protocal ={}
    protocal.tower = tower
    self:SendProtocal(11322,protocal)
end
function StartowerController:handle11322( data )
    message(data.msg)
    self:openStarTowerMainView(false)
end
--推送星命塔结算
function StartowerController:handle11323( data )
    if data.result == 1 then
        if data.is_skip == 1 then--是否跳过战斗打开怪物逃跑界面
            self:openTipsWindow(true,data)
        else
            BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.StarTower, data)
        end        
        self.model:updateMaxTower(data) 
        self.model:updateLessCount(data)
        GlobalEvent:getInstance():Fire(StartowerEvent.Fight_Success_Event)
    else
        BattleController:getInstance():openFailFinishView(true, BattleConst.Fight_Type.StarTower, data.result, data)
    end 
end
--扫荡星命塔
function StartowerController:sender11324(tower)
    local protocal ={}
    protocal.tower = tower
    self:SendProtocal(11324,protocal)    
end
function StartowerController:handle11324( data )
    message(data.msg)
    self.model:updateLessCount(data)
end
--请求星命塔通关录像
function StartowerController:sender11325(tower)
    local protocal ={}
    protocal.tower = tower
    self:SendProtocal(11325,protocal)
end
function StartowerController:handle11325( data )
    message(data.msg)

    GlobalEvent:getInstance():Fire(StartowerEvent.Video_Data_Event,data)
end

function StartowerController:handle11326( data )
    self.show_data = data
    self.is_show_lock = true
--    self:openGetWindow(true,data.tower)
end

--分享通关录像
function StartowerController:sender11333(replay_id,channel,tower)
    local protocal ={}
    protocal.replay_id = replay_id
    protocal.channel = channel
    protocal.tower = tower
    self:SendProtocal(11333,protocal)
end
function StartowerController:handle11333( data )
    message(data.msg)
    if data.result == 1 then
        self:openVideoWindow(false)
    end
end

function StartowerController:requestStarTowerRank()
    self:SendProtocal(11327,{})
end
function StartowerController:handle11327(data)
    GlobalEvent:getInstance():Fire(StartowerEvent.Update_Top3_rank, data.rank_lists)
end
--领取通关奖励
function StartowerController:sender11328(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(11328, proto)
end
function StartowerController:handle11328(data)
    message(data.msg)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(StartowerEvent.Update_Reward_Event)
    end
end
function StartowerController:handle11329(data)
    self.model:setRewardData(data.award_list)
    GlobalEvent:getInstance():Fire(StartowerEvent.Update_First_Reward_Msg)
end

function StartowerController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end