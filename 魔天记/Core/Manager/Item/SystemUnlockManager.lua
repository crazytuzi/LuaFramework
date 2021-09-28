
require "Core.Manager.ConfigManager";

SystemUnlockManager = { };
SystemUnlockManager.cfList = nil;


function SystemUnlockManager.CheckInit()

    if SystemUnlockManager.cfList == nil then

        local cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SYSTEM);

        local list = { };
        local listIndex = 1;

        local t_num = table.getn(cf);

         for key, value in pairs(cf) do

         if value.foreshow then
            list[listIndex] = value;
            listIndex = listIndex+1;
            end
         end
         local _sortfunc = table.sort 
        -- 需要进行排序
         _sortfunc(list, function(a,b) return a.foreorder < b.foreorder end);

         SystemUnlockManager.cfList = list;
    end

end



-- 获取需要提示的信息
function SystemUnlockManager.TryGetNeedTipInfo()

    SystemUnlockManager.CheckInit()

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    local t_num = table.getn(SystemUnlockManager.cfList);
    for i = 1, t_num do
        local obj = SystemUnlockManager.cfList[i];
        if obj.foreshow then
            if obj.foreorder > my_lv then

               if obj.play_level ~= nil and  my_lv >= obj.play_level   then
                  obj.canShowEff = true;
                  else
                   obj.canShowEff = false;
               end 

                return obj;
            end
        end
    end

    return nil;

end

