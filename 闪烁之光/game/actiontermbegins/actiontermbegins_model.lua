-- --------------------------------------------------------------------
-- 开学季活动boss战
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      开学季活动boss战 后端 锦汉 策划 建军
-- <br/>Create: 2019-08-21
-- --------------------------------------------------------------------
ActiontermbeginsModel = ActiontermbeginsModel or BaseClass()

function ActiontermbeginsModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ActiontermbeginsModel:config()
end


function ActiontermbeginsModel:getRankRewardByRank(rank)
    local config_list = Config.HolidayTermBeginsData.data_rank_reward
    if config_list then
        for i,v in ipairs(config_list) do
            if rank > v.rank1 and rank <= v.rank2 then
                return v.award
            end
        end
        return config_list[1].award
    end

    return {}
end

function ActiontermbeginsModel:__delete()
end