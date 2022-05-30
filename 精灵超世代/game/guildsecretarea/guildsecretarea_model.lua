-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会秘境 后端 国辉 策划 松岳
-- <br/>Create: 2019年9月11日 
-- --------------------------------------------------------------------
GuildsecretareaModel = GuildsecretareaModel or BaseClass()

function GuildsecretareaModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function GuildsecretareaModel:config()
    --BattleConst.Fight_Type.GuildSecretArea

    --boss的排行信息
    self.dic_boss_rank_info = {}
end
--公会秘境数据..用于判定红点用
function GuildsecretareaModel:updateSecretareaData( data )
    self.secretarea_data = data
    self:checkRedPoint(true)
end
function GuildsecretareaModel:updateSecretareaBuyCount(data)
    if data and self.secretarea_data then
        self.secretarea_data.count = data.count
        self.secretarea_data.last_buy_time = data.last_buy_time
        self:checkRedPoint(true)
    end
end

function GuildsecretareaModel:checkRedPoint(is_check_main)
    local status = false
    if self.secretarea_data then
        if self.secretarea_data.bid == 0 then return false end

        if self.secretarea_data.count > 0 and self.secretarea_data.end_time > GameNet:getInstance():getTime() then
            --有挑战次数
            status = true
        else   
            --是否能量领奖
            if self.secretarea_data.is_reward == 1 then
            --已领奖励信息
                local dic_progress_reward = {}
                for i,v in ipairs(self.secretarea_data.progress_reward) do
                    dic_progress_reward[v.order] = true
                end
                if Config.GuildSecretAreaData and Config.GuildSecretAreaData.data_box_reward then
                    local box_reward_list = Config.GuildSecretAreaData.data_box_reward[self.secretarea_data.bid]
                    if box_reward_list and next(box_reward_list) ~= nil then
                        table.sort( box_reward_list, function(a, b) return a.number < b.number end )
                        local per_hp = self.secretarea_data.hp * 100/ self.secretarea_data.max_hp 
                        for i,config in ipairs(box_reward_list) do
                            local per = config.progress/10
                            if not dic_progress_reward[config.number] and per_hp <= per then
                                status = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    if is_check_main then
        local redpoint = {bid = GuildConst.red_index.guild_secret_area, status = status}
        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, redpoint)
    end
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildRedStatus, GuildConst.red_index.guild_secret_area, status)
    return status
end

function GuildsecretareaModel:updateBossRankInfo(data)
    if not data then return end
    self.dic_boss_rank_info[data.boss_id] = data
end

function GuildsecretareaModel:getBossRankInfoByBossID(boss_id)
    if self.dic_boss_rank_info then
        return self.dic_boss_rank_info[boss_id]
    end
    return nil
end

function GuildsecretareaModel:clearBossRankInfo()
    self.dic_boss_rank_info = {}
end

--讨伐信息更新
function GuildsecretareaModel:updateStartCrusadeInfo(data)
    self.start_crusade_data = data
end
--是否显示开始讨伐窗口
function GuildsecretareaModel:isShowStartCrusade()
    if self.start_crusade_data and self.start_crusade_data.flag == 0 then
        self.start_crusade_data.flag = 1
        return true
    end
    return false
end

function GuildsecretareaModel:__delete()
end