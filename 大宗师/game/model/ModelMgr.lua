
HeroModel        	= require("game.model.HeroModel")
JingYingModel 		= require("game.model.JingYingModel")
HuoDongFuBenModel 	= require("game.model.HuoDongFuBenModel")
ActStatusModel 		= require("game.model.ActStatusModel")
SubMapModel 		= require("game.model.SubMapModel")
HeroSettingModel 	= require("game.model.HeroSettingModel")
HandBookModel 		= require("game.model.HandBookModel")
LimitHeroModel 		= require("game.model.LimitHeroModel")
FriendModel 		= require("game.model.FriendModel")

GameModel 			= require("game.model.GameModel")

EquipModel          = require("game.model.EquipModel")

PageMemoModel       = require("game.model.PageMemoModel")

RankListModel    	= require("game.model.RankListModel")

local ModelMgr = {}

function ModelMgr.removeItem(itemData)
	local itemType = itemData.itemType
	local itemID   = itemData.itemId
	local itemNum  = itemData.itemNum
	 
	 if itemType == 8 then -- 武将
	 	local heroList = HeroModel.totalTable
	 	for i = 1,itemNum do
	 	end

	 end

end
-- if param.type == 7 or param.type == 11 or param.type == 12 then
--  		-- 7：可使用物品、11：礼品、12材料
-- elseif param.type == 4 or param.type == 9 or param.type == 10 then
-- 		-- 4: 内外功、 9：内功碎片、 10：外功碎片 
-- 	elseif param.type == 1 or param.type == 2 or param.type == 3 then
-- 		-- 1：装备、 2：时装、 3：装备碎片 
-- 	elseif param.type == 5 or param.type == 8 then 
-- 		-- 5：武将碎片、 8：武将
-- end

return ModelMgr