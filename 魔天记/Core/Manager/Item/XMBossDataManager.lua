XMBossDataManager = { };

XMBossDataManager.tong_monsterCf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TONG_MONSTER); --require "Core.Config.tong_monster";
XMBossDataManager.tong_activity_awardCf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TONG_ACTIVITY_AWARD); --require "Core.Config.tong_activity_award";


function XMBossDataManager.GetActivetyAward(lv)
   
    return XMBossDataManager.tong_activity_awardCf[tonumber(lv)];
end

function XMBossDataManager.Get_model_scale_rate(mid)

    local list = XMBossDataManager.tong_monsterCf;
    local t_num = table.getn(list);
    for i = 1, t_num do
        if list[i].monster_id == mid then
            return list[i].model_scale_rate;
        end
    end

    return 1;
end




