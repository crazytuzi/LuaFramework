FightingCapacityDataManager = {}
FightingCapacityDataManager.hasInit=false;



function FightingCapacityDataManager.CheckInit()
     
    if not FightingCapacityDataManager.hasInit then
        
       local cf  = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FIGHTING_CAPACITY); --require "Core.Config.fighting_capacity";
      local cfItem={};

        for key, value in pairs(cf) do
           local ck = value.nature;
           local v = value.value;
          cfItem[ck]=v;
        end
        FightingCapacityDataManager.cfItem=cfItem;
        FightingCapacityDataManager.hasInit = true;
    end
end


function FightingCapacityDataManager.GetFight(att_key)
  FightingCapacityDataManager.CheckInit();
  return FightingCapacityDataManager.cfItem[att_key];
end

