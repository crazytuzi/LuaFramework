-- Filename：	TransferData.lua
-- Author：		bzx
-- Date：		2015-05-28
-- Purpose：		定向变身选择界面

module ("TransferData", package.seeall)

require "db/DB_Normal_config"
require "db/DB_Heroes"

function getFixedTransferCost( heroData )
	local normalConfig = DB_Normal_config.getDataById(1)
	local costInfo = parseField(normalConfig.changeOrderCardCost, 2)
	local heroDb = DB_Heroes.getDataById(heroData.htid)
	local costIndex
	if heroDb.heroQuality == 12 then
		costIndex = 1
	elseif heroDb.heroQuality == 13 then
		costIndex = 2
	elseif heroDb.heroQuality == 15 then
		local srcHeroDb = DB_Heroes.getDataById(heroDb.model_id)
		if srcHeroDb.heroQuality == 12 then
			costIndex = 3
		elseif srcHeroDb.heroQuality == 13 then
			costIndex = 4
		end
	end
	local costCount = costInfo[costIndex][tonumber(heroData.evolve_level) + 1]
	return costCount
end