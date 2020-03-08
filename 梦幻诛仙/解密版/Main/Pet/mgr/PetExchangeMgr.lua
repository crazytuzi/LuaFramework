local Lplus = require("Lplus")
local PetExchangeMgr = Lplus.Class("PetExchangeMgr")
local PetModule = Lplus.ForwardDeclare("PetModule")
local CGoldPetRedeemReq = require("netio.protocol.mzm.gsp.pet.CGoldPetRedeemReq")
local CMoShouPetRedeemReq = require("netio.protocol.mzm.gsp.pet.CMoShouPetRedeemReq")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local PetUtility = require("Main.Pet.PetUtility")
local PetExChangePanel = require("Main.Pet.ui.PetExChangePanel")
local PetTuJianPanel = require("Main.Pet.ui.PetTuJianPanel")
local PetShopMgr = require("Main.Pet.mgr.PetShopMgr")
local def = PetExchangeMgr.define
def.const("number").PET_SHENSHOU_EXCHANGE_SERVICE = CGoldPetRedeemReq.REDEEM_NPC_SERVICE_ID
def.const("number").PET_MOSHOU_EXCHANGE_SERVICE = CMoShouPetRedeemReq.REDEEM_NPC_SERVICE_ID
local instance
def.static("=>", PetExchangeMgr).Instance = function()
  if instance == nil then
    instance = PetExchangeMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PetExchangeMgr.OnAcceptNPCService)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TARGET_SERVICE, PetExchangeMgr.OnAcceptNPCTargetService)
end
def.method("number", "=>", "table").GetRandomExchangeConsume = function(self, petType)
  local cfg = PetUtility.GetPetRandomExchangeCfg(petType)
  if not cfg.items[1] then
    local needitem = {itemId = 210100000, itemCount = 0}
  end
  return needitem
end
def.method("number").HandleRandomExchangeRequest = function(self, petType)
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemModule = require("Main.Item.ItemModule")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local consume = self:GetRandomExchangeConsume(petType)
  local idlist = ItemUtils.GetItemTypeRefIdList(consume.itemTypeId)
  local itemId = idlist[1]
  local itemBase = ItemUtils.GetItemBase(itemId)
  local coloredItemName = string.format("[%s]%s[-]", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  local count = consume.itemCount
  local haveCount = 0
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  for k, item in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase.itemType == consume.itemTypeId then
      haveCount = haveCount + item.number
    end
  end
  local corloredCount = count
  if count <= haveCount then
    corloredCount = string.format("[00ff00]%s[-]", corloredCount)
  else
    corloredCount = string.format("[ff0000]%s[-]", corloredCount)
  end
  local petTypeText = textRes.Pet.Type[petType]
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Pet[111], string.format(textRes.Pet[112], corloredCount, coloredItemName, petTypeText, petTypeText), function(s)
    if s == 0 then
      return
    end
    if haveCount < count then
      corloredCount = string.format("<font color=#00ff00>%s</font>", count)
      coloredItemName = string.format("<font color=#%s>%s</font>", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
      Toast(string.format(textRes.Pet[114], corloredCount, coloredItemName))
    end
    if petType == PetType.SHENSHOU then
      self:CGoldPetRedeemReq()
    elseif petType == PetType.MOSHOU then
      self:CMoShouPetRedeemReq()
    else
      Toast("Not handled!")
    end
  end, nil)
end
def.method("number", "=>", "table").GetTargetPetsCfg = function(self, targetType)
  local cfg = PetUtility.GetShenShoePetsByType(targetType)
  local ret = {}
  for idx, petCfg in pairs(cfg) do
    if not PetShopMgr.Instance():IsPetInBanList(petCfg.id) then
      table.insert(ret, petCfg)
    end
  end
  return ret
end
def.method().ShowTuJianPanel = function(self)
  PetTuJianPanel.Instance():ShowPanel()
end
def.method("number").ShowSpecifyTuJianPanel = function(self, targetId)
  PetTuJianPanel.Instance():ShowPanelWithPetTemplateId(targetId)
end
def.method("number", "=>", "table").GetShenShouDuiHuanNeedItems = function(self, targetId)
  local NeedCfg = PetUtility.GetPetExchangeCfg(targetId)
  if NeedCfg == nil then
    return nil
  end
  local itemTypeList = NeedCfg.items
  local needItemList = {}
  local ItemUtils = require("Main.Item.ItemUtils")
  for k, v in pairs(itemTypeList) do
    local itemTypeId = v.itemTypeId
    local itemIdList = ItemUtils.GetItemTypeRefIdList(itemTypeId)
    if itemIdList then
      local itemCfg = {}
      itemCfg.itemCount = v.itemCount
      itemCfg.itemIdList = itemIdList
      table.insert(needItemList, itemCfg)
    end
  end
  return needItemList
end
def.static("table", "table").OnAcceptNPCService = function(params, param2)
  local serviceID = params[1]
  local NPCID = params[2]
  local userParam = params[3]
  if userParam and userParam.petexchange then
    if userParam.petexchange == PetType.SHENSHOU then
      serviceID = PetExchangeMgr.PET_SHENSHOU_EXCHANGE_SERVICE
    elseif userParam.petexchange == PetType.MOSHOU then
      serviceID = PetExchangeMgr.PET_MOSHOU_EXCHANGE_SERVICE
    end
  end
  local targetType = 0
  if serviceID == PetExchangeMgr.PET_SHENSHOU_EXCHANGE_SERVICE then
    targetType = PetType.SHENSHOU
  elseif serviceID == PetExchangeMgr.PET_MOSHOU_EXCHANGE_SERVICE then
    targetType = PetType.MOSHOU
  else
    return
  end
  PetExChangePanel.Instance():ShowPanel(targetType)
end
def.static("table", "table").OnAcceptNPCTargetService = function(params, param2)
  PetExchangeMgr.OnAcceptNPCService(params, param2)
end
def.method("number").CGoldPetRedeemReq = function(self, targetPetId)
  if PetShopMgr.Instance():IsPetInBanList(targetPetId) then
    Toast(textRes.Pet[164])
    return
  end
  local p = require("netio.protocol.mzm.gsp.pet.CGoldPetRedeemReq").new(targetPetId)
  gmodule.network.sendProtocol(p)
end
def.method("number").CMoShouPetRedeemReq = function(self, targetPetId)
  if PetShopMgr.Instance():IsPetInBanList(targetPetId) then
    Toast(textRes.Pet[164])
    return
  end
  local p = require("netio.protocol.mzm.gsp.pet.CMoShouPetRedeemReq").new(targetPetId)
  gmodule.network.sendProtocol(p)
end
return PetExchangeMgr.Commit()
