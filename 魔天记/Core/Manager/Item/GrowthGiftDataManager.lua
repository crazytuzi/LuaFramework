GrowthGiftDataManager = {};

GrowthGiftDataManager.hasInit = false;

function GrowthGiftDataManager.CheckInit()
     
     if not GrowthGiftDataManager.hasInit then
       
       GrowthGiftDataManager.cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GROWTH_GIFT);
      GrowthGiftDataManager.hasInit = true;
     end

end


function GrowthGiftDataManager.GetConfigList()
    
    GrowthGiftDataManager.CheckInit();
    return GrowthGiftDataManager.cf;

end
