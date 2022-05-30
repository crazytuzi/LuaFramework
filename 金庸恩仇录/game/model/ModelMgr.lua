HeroModel = require("game.model.HeroModel")
PetModel = require("game.model.PetModel")
JingYingModel = require("game.model.JingYingModel")
HuoDongFuBenModel = require("game.model.HuoDongFuBenModel")
ZhenShenModel = require("game.model.ZhenShenModel")
ActStatusModel = require("game.model.ActStatusModel")
SubMapModel = require("game.model.SubMapModel")
HeroSettingModel = require("game.model.HeroSettingModel")
HandBookModel = require("game.model.HandBookModel")
LimitHeroModel = require("game.model.LimitHeroModel")
FriendModel = require("game.model.FriendModel")
GameModel = require("game.model.GameModel")
EquipModel = require("game.model.EquipModel")
PageMemoModel = require("game.model.PageMemoModel")
RankListModel = require("game.model.RankListModel")
MapModel = require("game.model.MapModel").new()
KuafuModel = require("game.kuafuzhan.KuafuModel")
FashionModel = require("game.model.FashionModel")
HelpLineModel = require("game.model.HelpLineModel")
GuildBattleModel = require("game.guild.guildBattle.GuildBattleModel")
KuangHuanModel = require("game.model.KuangHuanModel")
CheatsModel = require("game.model.CheatsModel")
CheatsModel.init()
local ModelMgr = {}
function ModelMgr.removeItem(itemData)
  local itemType = itemData.itemType
  local itemID = itemData.itemId
  local itemNum = itemData.itemNum
  if itemType == 8 then
    local heroList = HeroModel.totalTable
    for i = 1, itemNum do
    end
  end
end
return ModelMgr
