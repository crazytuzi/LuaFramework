-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会秘境 后端 国辉 策划 松岳
-- <br/>Create: 2019年9月11日 
-- --------------------------------------------------------------------
GuildsecretareaController = GuildsecretareaController or BaseClass(BaseController)

function GuildsecretareaController:config()
    self.model = GuildsecretareaModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function GuildsecretareaController:getModel()
    return self.model
end

function GuildsecretareaController:registerEvents()

end

function GuildsecretareaController:registerProtocals()
    self:RegisterProtocal(26800, "handle26800")     --公会秘境基础信息
    self:RegisterProtocal(26801, "handle26801")     --公会秘境设置Boss
    self:RegisterProtocal(26802, "handle26802")     --挑战公会秘境Boss
    self:RegisterProtocal(26803, "handle26803")     --购买挑战次数
    self:RegisterProtocal(26804, "handle26804")     --领取阶段奖励
    self:RegisterProtocal(26805, "handle26805")     --扫荡公会秘境Boss
    self:RegisterProtocal(26806, "handle26806")     --获得秘境Boss排行榜
    self:RegisterProtocal(26807, "handle26807")     --讨伐开始弹窗
    self:RegisterProtocal(26808, "handle26808")     --boss讨伐成功或失败界面
    self:RegisterProtocal(26809, "handle26809")     --boss小结算界面
    self:RegisterProtocal(26810, "handle26810")     --活跃度刷新
end

--0点更新请求该协议
function GuildsecretareaController:request26800()
    --暂时废弃后端说做不了来
    -- if self.guildsecretarea_main_window then
    --     self:sender26800()
    -- end
end
--公会秘境基础信息
function GuildsecretareaController:sender26800()
    local protocal ={}
    self:SendProtocal(26800,protocal)
end

function GuildsecretareaController:handle26800(data)
    self.model:updateSecretareaData(data)
    GlobalEvent:getInstance():Fire(GuildsecretareaEvent.GUILD_SECRET_AREA_MAIN_EVENT, data)
end

--公会秘境设置Boss
function GuildsecretareaController:sender26801(boss_id)
    local protocal ={}
    protocal.boss_id = boss_id
    self:SendProtocal(26801,protocal)
end

function GuildsecretareaController:handle26801(data)
    message(data.msg)
    if data.flag == TRUE then
        -- GlobalEvent:getInstance():Fire(GuildsecretareaEvent.TERM_BEGINS_BUY_COUNT_EVENT, data)
    end
end

--挑战公会秘境Boss
function GuildsecretareaController:sender26802(boss_id, formation_type, pos_info, hallows_id)
    local protocal ={}
    protocal.boss_id = boss_id
    protocal.formation_type = formation_type
    protocal.pos_info = pos_info
    protocal.hallows_id = hallows_id
    self:SendProtocal(26802,protocal)
end

function GuildsecretareaController:handle26802(data)
    message(data.msg)
end

--购买挑战次数
function GuildsecretareaController:sender26803(boss_id)
    local protocal ={}
    protocal.boss_id = boss_id
    self:SendProtocal(26803,protocal)
end

function GuildsecretareaController:handle26803(data)
    message(data.msg)
    if data.flag == TRUE then
        self.model:updateSecretareaBuyCount(data)
        GlobalEvent:getInstance():Fire(GuildsecretareaEvent.GUILD_SECRET_AREA_BUY_COUNT_EVENT, data)
    end
end

--领取阶段奖励
function GuildsecretareaController:sender26804(boss_id, number)
    local protocal ={}
    protocal.boss_id = boss_id
    protocal.number = number
    self:SendProtocal(26804,protocal)
end

function GuildsecretareaController:handle26804(data)
    message(data.msg)
    if data.flag == TRUE then
        GlobalEvent:getInstance():Fire(GuildsecretareaEvent.TERM_BEGINS_RECEIVE_REWARD_EVENT, data)
    end
end

--扫荡公会秘境Boss
function GuildsecretareaController:sender26805(boss_id)
    local protocal ={}
    protocal.boss_id = boss_id
    self:SendProtocal(26805,protocal)
end

function GuildsecretareaController:handle26805(data)
    message(data.msg)
    if data.flag == TRUE then
        self:sender26800()
        GlobalEvent:getInstance():Fire(GuildsecretareaEvent.GUILD_SECRET_AREA_REFRESH_RANK_EVENT)
    end
end

--获得秘境Boss排行榜
function GuildsecretareaController:sender26806(boss_id, num)
    local protocal ={}
    protocal.boss_id = boss_id
    protocal.num = num
    self:SendProtocal(26806,protocal)
end

function GuildsecretareaController:handle26806(data)
    self.model:updateBossRankInfo(data)
    GlobalEvent:getInstance():Fire(GuildsecretareaEvent.GUILD_SECRET_AREA_RANK_COUNT_EVENT, data)
end
--讨伐开始弹窗
function GuildsecretareaController:sender26807()
    local protocal ={}
    self:SendProtocal(26807,protocal)
end

function GuildsecretareaController:handle26807(data)
    self.model:updateStartCrusadeInfo(data)
    if data.flag == 0 and data.end_time ~= 0 then
        self:openGuildsecretareaStartCrusadePanel(true)
    end
end

--boss讨伐成功或失败界面
function GuildsecretareaController:sender26808()
    local protocal ={}
    self:SendProtocal(26808,protocal)
end
--boss讨伐成功或失败界面(推送的)
function GuildsecretareaController:handle26808(data)
    self:openGuildsecretareaEndCrusadePanel(true, data.flag, data)
end

--boss小结算界面
function GuildsecretareaController:sender26809()
    local protocal ={}
    self:SendProtocal(26809,protocal)
end
--boss小结算界面(推送)
function GuildsecretareaController:handle26809(data)
    self:sender26800()
    GlobalEvent:getInstance():Fire(GuildsecretareaEvent.GUILD_SECRET_AREA_REFRESH_RANK_EVENT)
    
    data.item_rewards = data.reward
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.GuildSecretArea, data)
end

--活跃度
function GuildsecretareaController:sender26810()
    local protocal ={}
    self:SendProtocal(26810,protocal)
end

--活跃度
function GuildsecretareaController:handle26810(data)
    local my_guild_info = GuildController:getInstance():getModel():getMyGuildInfo()
    if my_guild_info then
        my_guild_info:setGuildAttribute("vitality", data.vitality)
    end
end


--打开公会秘境
function GuildsecretareaController:openGuildsecretareaMainWindow(status, setting)
    if RoleController:getInstance():getRoleVo():isHasGuild() == false then
        message(TI18N("您当前未加入任何公会，加入公会后才能参与该玩法！"))
        return
    end
    if status == false then
        if self.guildsecretarea_main_window ~= nil then
            self.guildsecretarea_main_window:close()
            self.guildsecretarea_main_window = nil
        end
    else
        if self.guildsecretarea_main_window == nil then
            self.guildsecretarea_main_window = GuildsecretareaMainWindow.New()
        end
        self.guildsecretarea_main_window:open(setting)
    end
end

--打开开始讨伐弹窗
function GuildsecretareaController:openGuildsecretareaStartCrusadePanel(status, setting)
    if status == false then
        if self.guildsecretarea_start_crusade_panel ~= nil then
            self.guildsecretarea_start_crusade_panel:close()
            self.guildsecretarea_start_crusade_panel = nil
        end
    else
        if self.guildsecretarea_start_crusade_panel == nil then
            self.guildsecretarea_start_crusade_panel = GuildsecretareaStartCrusadePanel.New()
        end
        self.guildsecretarea_start_crusade_panel:open(setting)
    end
end

--打开讨伐成功失败界面
function GuildsecretareaController:openGuildsecretareaEndCrusadePanel(status, result, setting)
    if status == false then
        if self.guildsecretarea_end_crusade_panel ~= nil then
            self.guildsecretarea_end_crusade_panel:close()
            self.guildsecretarea_end_crusade_panel = nil
        end
    else
        if self.guildsecretarea_end_crusade_panel == nil then
            self.guildsecretarea_end_crusade_panel = GuildsecretareaEndCrusadePanel.New(result)
        end
        self.guildsecretarea_end_crusade_panel:open(setting)
    end
end

--打开宝物奖励展示界面
function GuildsecretareaController:openGuildsecretareaRewardWindow(status,boss_id)
    if status == false then
        if self.guildsecretarea_raward_window ~= nil then
            self.guildsecretarea_raward_window:close()
            self.guildsecretarea_raward_window = nil
        end
    else
        if self.guildsecretarea_raward_window == nil then
            self.guildsecretarea_raward_window = GuildsecretareaRewardWindow.New()
        end
        self.guildsecretarea_raward_window:open(boss_id)
    end
end
function GuildsecretareaController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end