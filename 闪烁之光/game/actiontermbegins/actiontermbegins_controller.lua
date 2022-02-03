-- --------------------------------------------------------------------
-- 开学季活动boss战
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      开学季活动boss战 后端 锦汉 策划 建军
-- <br/>Create: 2019-08-21
-- --------------------------------------------------------------------
ActiontermbeginsController = ActiontermbeginsController or BaseClass(BaseController)

function ActiontermbeginsController:config()
    self.model = ActiontermbeginsModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function ActiontermbeginsController:getModel()
    return self.model
end

function ActiontermbeginsController:registerEvents()
    
end

function ActiontermbeginsController:registerProtocals()
    self:RegisterProtocal(26700, "handle26700")     --开学副本基础信息
    self:RegisterProtocal(26701, "handle26701")     --关卡购买挑战次数
    self:RegisterProtocal(26702, "handle26702")     --挑战关卡怪物
    self:RegisterProtocal(26703, "handle26703")     --关卡战斗结算

    self:RegisterProtocal(26704, "handle26704")     --提交试卷
    self:RegisterProtocal(26705, "handle26705")     --试卷收集奖励信息
    self:RegisterProtocal(26706, "handle26706")     --领取试卷收集奖励
    self:RegisterProtocal(26707, "handle26707")     --挑战Boss
    self:RegisterProtocal(26708, "handle26708")     --Boss战斗结算
    self:RegisterProtocal(26709, "handle26709")     --扫荡Boss
    self:RegisterProtocal(26710, "handle26710")     --Boss伤害个人排行榜
    self:RegisterProtocal(26711, "handle26711")     --活动页面信息
    self:RegisterProtocal(26712, "handle26712")     --购买准考证
end
--开学副本基础信息
function ActiontermbeginsController:sender26700()
    local protocal ={}
    self:SendProtocal(26700,protocal)
end

function ActiontermbeginsController:handle26700(data)
    GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.TERM_BEGINS_MAIN_EVENT, data)
end
--关卡购买挑战次数
function ActiontermbeginsController:sender26701()
    local protocal = {}
    self:SendProtocal(26701,protocal)
end

function ActiontermbeginsController:handle26701(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.TERM_BEGINS_BUY_COUNT_EVENT, data)
    end
end

--挑战关卡怪物
function ActiontermbeginsController:sender26702()
    local protocal ={}
    self:SendProtocal(26702,protocal)
end

function ActiontermbeginsController:handle26702(data)
    message(data.msg)
end

--关卡战斗结算(推送)
function ActiontermbeginsController:handle26703(data)
    -- data.fight_Type = BattleConst.Fight_Type.TermBegins
    data.item_rewards = data.award_list
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.TermBegins, data)
end

--提交试卷
function ActiontermbeginsController:sender26704(count)
    local protocal ={}
    protocal.count = count
    self:SendProtocal(26704,protocal)
end

function ActiontermbeginsController:handle26704(data)
    if data.code == TRUE then
        message(TI18N("提交成功"))
        GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.TERM_BEGINS_SUBIT_PAPER_EVENT, data)
    else
        message(data.msg)
    end
end

--试卷收集奖励信息
function ActiontermbeginsController:sender26705()
    local protocal ={}
    self:SendProtocal(26705,protocal)
end

function ActiontermbeginsController:handle26705(data)
    GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.TERM_BEGINS_PAPER_REWARD_LIST_EVENT, data)
end

--领取试卷收集奖励
function ActiontermbeginsController:sender26706(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(26706,protocal)
end

function ActiontermbeginsController:handle26706(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.TERM_BEGINS_RECEIVE_PAPER_EVENT, data)
    end
end

--挑战boss
function ActiontermbeginsController:sender26707()
    local protocal ={}
    self:SendProtocal(26707,protocal)
end

function ActiontermbeginsController:handle26707(data)
    message(data.msg)
end


--boss战斗结算(推送)
function ActiontermbeginsController:handle26708(data)
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.TermBeginsBoss, data)
end

--扫荡boss
function ActiontermbeginsController:sender26709(boss_id)
    local protocal ={}
    protocal.boss_id = boss_id
    self:SendProtocal(26709,protocal)
end

function ActiontermbeginsController:handle26709(data)
    message(data.msg)
    if data.code == TRUE then
        BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.TermBeginsBoss, data)
    end
end

--伤害排行信息
function ActiontermbeginsController:sender26710(boss_id, start_num, end_num)
    local protocal ={}
    protocal.boss_id = boss_id
    protocal.start_num = start_num or 1
    protocal.end_num = end_num or 100
    self:SendProtocal(26710,protocal)
end

function ActiontermbeginsController:handle26710(data)
    GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.TERM_BEGINS_RANK_EVENT, data)
end

--活动页面信息
function ActiontermbeginsController:sender26711()
    local protocal ={}
    self:SendProtocal(26711,protocal)
end

function ActiontermbeginsController:handle26711(data)
    GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.ACTION_TERM_BEGINS_EVENT, data)
end

--购买准考证@ flag 0: 表示 挑战购买  boss_id 表示扫荡购买(客户端定义)
function ActiontermbeginsController:sender26712(flag)
    local protocal ={}
    protocal.num = 1
    protocal.flag = flag
    self:SendProtocal(26712,protocal)
end

function ActiontermbeginsController:handle26712(data)
    if data.code == TRUE then
        if data.flag == 0 then
            --布阵
            GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.TERM_BEGINS_BOSS_FORM_EVENT)
        else
            --发协议 不是0就是boss_id
            self:sender26709(data.flag)
        end
    end
end

--打开活动主界面
function ActiontermbeginsController:openActiontermbeginsMainWindow(status, setting)
    if status == false then
        if self.action_term_begins_main_window ~= nil then
            self.action_term_begins_main_window:close()
            self.action_term_begins_main_window = nil
        end
    else
        if self.action_term_begins_main_window == nil then
            self.action_term_begins_main_window = ActiontermbeginsMainWindow.New()
        end
        self.action_term_begins_main_window:open(setting)
    end
end

--打开关卡的战斗结算
--boss战斗结算
function ActiontermbeginsController:openActiontermbeginsFightResultPanel(status, data)
    if status == true then
        -- 不能直接出剧情或者引导
        BattleResultMgr:getInstance():setWaitShowPanel(true)
        if not self.term_begins_result_window then 
            self.term_begins_result_window = ActiontermbeginsFightResultPanel.New()
        end
        if self.term_begins_result_window and self.term_begins_result_window:isOpen() == false then
            self.term_begins_result_window:open(data, BattleConst.Fight_Type.TermBeginsBoss)
        end
    else 
        if self.term_begins_result_window then 
            self.term_begins_result_window:close()
            self.term_begins_result_window = nil
            GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
        end
    end
end



--打开收集奖励界面
function ActiontermbeginsController:openActiontermbeginsCollectResultPanel(status, setting)
    if status == false then
        if self.action_term_begins_cellect_reward_panel ~= nil then
            self.action_term_begins_cellect_reward_panel:close()
            self.action_term_begins_cellect_reward_panel = nil
        end
    else
        if self.action_term_begins_cellect_reward_panel == nil then
            self.action_term_begins_cellect_reward_panel = ActiontermbeginsCollectResultPanel.New()
        end
        self.action_term_begins_cellect_reward_panel:open(setting)
    end
end

--打开收集奖励界面
function ActiontermbeginsController:openActionBuyPanel(status, setting)
    if status == false then
        if self.action_buy_panel ~= nil then
            self.action_buy_panel:close()
            self.action_buy_panel = nil
        end
    else
        if self.action_buy_panel == nil then
            self.action_buy_panel = ActionBuyPanel.New()
        end
        self.action_buy_panel:open(setting)
    end
end

--打开排行榜信息
function ActiontermbeginsController:openActiontermbeginsRankMainPanel(status, setting)
    if status == false then
        if self.action_term_begins_rank_main_panel ~= nil then
            self.action_term_begins_rank_main_panel:close()
            self.action_term_begins_rank_main_panel = nil
        end
    else
        if self.action_term_begins_rank_main_panel == nil then
            self.action_term_begins_rank_main_panel = ActiontermbeginsRankMainPanel.New()
        end
        self.action_term_begins_rank_main_panel:open(setting)
    end
end



function ActiontermbeginsController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end