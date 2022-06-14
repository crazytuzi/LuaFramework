
dataConfig = {}

dataConfig.configs = {}

-- add include below when need new table config
include("uiConfig")
include("unitConfig")
include("skillConfig")
include("buffConfig")
include("serverlistConfig")
include("serverlistpbConfig")
include("serverlistappsConfig")
include("magicConfig")
include("sceneConfig")
include("stageConfig")
include("MainBaseConfig")
include("unitCompatableConfig")
include("itemConfig")
include("useItemConfig")
include("equipConfig")
include("debrisConfig") 
include("strengthenConfig") 
include("shipConfig")
include("AdventureConfig") 
include("ChapterConfig")
include("MagicTowerConfig")
include("stageConfig")
include("priceConfig")
include("ConfigConfig")
include("vipConfig")
include("vigorRewardConfig")
include("playerConfig")
include("characterConfig")
include("dialogueConfig")
include("IncidentConfig")
include("dailyTaskConfig")
include("levelRewardConfig")
include("loginRewardConfig")
include("shopConfig")
include("PvpOnlineConfig")
include("PvpOfflineConfig")
include("nameConfig")
include("iconConfig")
include("challengeDamageConfig")
include("challengeSpeedConfig")
include("mapsConfig")
include("magicRoundConfig")
include("remouldConfig")
include("rechargeConfig")
include("stageModelConfig")
include("guideConfig")
include("filterConfig")
include("tipsConfig")
include("pushConfig")
include("limitActivityConfig")
include("limitActivityContentConfig")
include("blockVIPConfig")
include("crusadeLevelConfig")
include("challengeStageConfig")
include("activityInfoConfig")
include("idolStatueConfig")
include("itemPrimalInfoConfig")
include("miracleConfig")
include("redEnvelopeConfig")
include("guildWarConfig")
include("guildWarRankConfig")
include("guildWarPerConfig")

function dataConfig.loadConfig(name,file)
	--[[
 assert(dataConfig.configs[name]  == nil,
        "dataConfig.loadConfig() name: "..name.." exist!! ") 		
	 dataConfig.configs[name] = json.decode(resManager.loadFile(file))	

     --]]
end

function dataConfig.loadConfigXml(name,file)
 --[[
	 assert(dataConfig.configs[name]  == nil,
        "dataConfig.loadConfig() name: "..name.." exist!! ") 			
	 dataConfig.configs[name] = XmlParser:ParseXmlText(resManager.loadFile(file))	
	 --]]
end


function dataConfig.Init()
	--dataConfig.loadConfig("Confcrop","Media/Config/Confcrop.json")	
	--dataConfig.loadConfig("testBattle","Media/Config/testBattle.json")	
	--dataConfig.loadConfigXml("battleField_config","Media/Scene/BattleField.config")--xml

end

function dataConfig.getConfig(name,file)
	if(dataConfig.configs[name] == nil)then
		dataConfig.loadConfig(name,file)
	end			
	return dataConfig.configs[name] 
end

--dataConfig.Init()