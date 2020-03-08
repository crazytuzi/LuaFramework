local Lplus = require("Lplus")
local HomelandProtocol = Lplus.Class("HomelandProtocol")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local FurnitureBag = require("Main.Homeland.FurnitureBag")
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = HomelandProtocol.define
local function getColoredName(itemBase)
  local name = itemBase.name
  local namecolor = itemBase.namecolor
  local color = HtmlHelper.NameColor[namecolor]
  local coloredName = string.format("<font color=#%s>%s</font>", color, name)
  return coloredName
end
def.static().Init = function()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HomelandProtocol.OnLeaveWorld)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SSynHomelandRes", HomelandProtocol.OnSSynHomelandRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SSynOwnFurnitureRes", HomelandProtocol.OnSSynOwnFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SInHomeRes", HomelandProtocol.OnSInHomeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SSendDivorceNoHomeRes", HomelandProtocol.OnSSendDivorceNoHomeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SSynFengshuiRes", HomelandProtocol.OnSSynFengshuiRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SSynCourtYardBeautifulRes", HomelandProtocol.OnSSynCourtYardBeautifulRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SUseFurnitureItemRes", HomelandProtocol.OnSUseFurnitureItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SDisplayFurnitureRes", HomelandProtocol.OnSDisplayFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SDisplayCourtYardFurnitureRes", HomelandProtocol.OnSDisplayCourtYardFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SUnDisplayFurnitureRes", HomelandProtocol.OnSUnDisplayFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SUnDisplayCourtYardFurnitureRes", HomelandProtocol.OnSUnDisplayCourtYardFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SUnDisplayAllRes", HomelandProtocol.OnSUnDisplayAllRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SMoveFurnitureRes", HomelandProtocol.OnSMoveFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SMoveFurnitureFailedRes", HomelandProtocol.OnSMoveFurnitureFailedRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SChangeWallRes", HomelandProtocol.OnSChangeWallRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SChangeFloortieRes", HomelandProtocol.OnSChangeFloortieRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SChangeCourtYardFurnitureSuccess", HomelandProtocol.OnSChangeCourtYardFurnitureSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SAddFurnitureRes", HomelandProtocol.OnSAddFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SDecFurnitureRes", HomelandProtocol.OnSDecFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SCleanHomeRes", HomelandProtocol.OnSCleanHomeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SSynCleanlinessRes", HomelandProtocol.OnSSynCleanlinessRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SCommonResultRes", HomelandProtocol.OnSCommonResultRes)
end
def.static("table", "table").OnLeaveWorld = function()
end
def.static().CReturnHomeReq = function()
  local p = require("netio.protocol.mzm.gsp.homeland.CReturnHomeReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CVisitHomeReq = function(roleid)
  local p = require("netio.protocol.mzm.gsp.homeland.CVisitHomeReq").new(roleid)
  gmodule.network.sendProtocol(p)
end
def.static("table", "function").CDisplayFurnitureReq = function(params, callback)
  local DisplayFurnitureInfo = require("netio.protocol.mzm.gsp.homeland.DisplayFurnitureInfo")
  local displayFurnitureInfo = DisplayFurnitureInfo.new(params.x, params.y, params.dir, params.itemId)
  local uuid = params.uuid
  local p = require("netio.protocol.mzm.gsp.homeland.CDisplayFurnitureReq").new(uuid, displayFurnitureInfo)
  gmodule.network.sendProtocol(p)
end
def.static("table", "function").CMoveFurnitureReq = function(params, callback)
  local DisplayFurnitureInfo = require("netio.protocol.mzm.gsp.homeland.DisplayFurnitureInfo")
  local displayFurnitureInfo = DisplayFurnitureInfo.new(params.x, params.y, params.dir, params.itemId)
  local uuid = params.uuid
  local p = require("netio.protocol.mzm.gsp.homeland.CMoveFurnitureReq").new(uuid, displayFurnitureInfo)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "function").CUnDisplayFurnitureReq = function(uuid, callback)
  local p = require("netio.protocol.mzm.gsp.homeland.CUnDisplayFurnitureReq").new(uuid)
  gmodule.network.sendProtocol(p)
end
def.static("function").CUnDisplayAllReq = function(uuid, callback)
  local p = require("netio.protocol.mzm.gsp.homeland.CUnDisplayAllReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CUseFurnitureItemReq = function(uuid)
  local p = require("netio.protocol.mzm.gsp.homeland.CUseFurnitureItemReq").new(uuid)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata").CChangeWallReq = function(furnitureId, furnitureUUID)
  local p = require("netio.protocol.mzm.gsp.homeland.CChangeWallReq").new(furnitureId, furnitureUUID)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata").CChangeFloortieReq = function(furnitureId, furnitureUUID)
  local p = require("netio.protocol.mzm.gsp.homeland.CChangeFloortieReq").new(furnitureId, furnitureUUID)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata").CChangeCourtYardFurnitureReq = function(furnitureId, furnitureUUID)
  local p = require("netio.protocol.mzm.gsp.homeland.CChangeCourtYardFurnitureReq").new(furnitureId, furnitureUUID)
  gmodule.network.sendProtocol(p)
end
def.static("table").CMoveServantReq = function(findpath)
  local Location = require("netio.protocol.mzm.gsp.map.Location")
  local keyPointPath = {}
  for i = 0, #findpath do
    local lp = Location.new()
    lp.x = findpath[i].x
    lp.y = findpath[i].y
    table.insert(keyPointPath, lp)
  end
  local p = require("netio.protocol.mzm.gsp.homeland.CTransferMaidToReq").new(keyPointPath)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSSynHomelandRes = function(p)
  HomelandModule.Instance().m_haveHome = true
  HomelandModule.Instance().m_playerIsOwner = p.isOwner == 1
  local myDisplayFurniture = {}
  for k, v in pairs(p.my_display_room_furniture_uuid_set) do
    myDisplayFurniture[tostring(k)] = {
      scene = HomelandModule.Area.House
    }
  end
  for k, v in pairs(p.my_display_courtyard_furniture_uuid_set) do
    myDisplayFurniture[tostring(k)] = {
      scene = HomelandModule.Area.Courtyard
    }
  end
  HomelandModule.Instance().myDisplayFurniture = myDisplayFurniture
  local HouseMgr = require("Main.Homeland.HouseMgr")
  HouseMgr.Instance():SyncHouseInfo(p)
  local CourtyardMgr = require("Main.Homeland.CourtyardMgr")
  CourtyardMgr.Instance():SyncCourtyardInfo(p)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeGeomancyChange, nil)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeCleannessChange, nil)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardBeautyChange, nil)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardCleannessChange, nil)
end
def.static("table").OnSDisplayFurnitureRes = function(p)
  local TOTAL_FENGSHUI_MAX = 1
  local FURNITURE_TYPE_FENGSHUI_MAX = 2
  local uuid = p.furnitureUuId
  local furnitureInfo = p.furnitureInfo
  local furnitureId = furnitureInfo.furnitureId
  local addFengshui = p.addFengshui
  local tomaxtype = p.tomaxtype or TOTAL_FENGSHUI_MAX
  FurnitureBag.Instance():RemoveFurniture(uuid)
  HomelandModule.Instance():AddMyDisplayFurniture(uuid, {
    scene = HomelandModule.Area.House
  })
  local HouseMgr = require("Main.Homeland.HouseMgr")
  local house = HouseMgr.Instance():GetMyHouse()
  local lastGeomancy = house:GetGeomancy()
  local currentGeomancy = lastGeomancy + addFengshui
  house:SetGeomancy(currentGeomancy)
  HomelandUtils.CheckGeomancyChange(lastGeomancy, currentGeomancy)
  if lastGeomancy ~= currentGeomancy then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeGeomancyChange, nil)
  end
  local itemBase = ItemUtils.GetItemBase(furnitureId)
  if itemBase then
    local name = itemBase.name
    local namecolor = itemBase.namecolor
    local color = HtmlHelper.NameColor[namecolor]
    local coloredName = string.format("<font color=#%s>%s</font>", color, name)
    local text
    if addFengshui > 0 then
      text = string.format(textRes.Homeland[24], coloredName, addFengshui)
    elseif tomaxtype == TOTAL_FENGSHUI_MAX then
      text = string.format(textRes.Homeland[59], coloredName)
    else
      text = string.format(textRes.Homeland[69], coloredName)
    end
    Toast(text)
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
end
def.static("table").OnSDisplayCourtYardFurnitureRes = function(p)
  local TOTAL_BEAUTY_MAX = 1
  local FURNITURE_TYPE_BEAUTY_MAX = 2
  local uuid = p.furnitureUuId
  local furnitureInfo = p.furnitureInfo
  local furnitureId = furnitureInfo.furnitureId
  local add_beautiful_value = p.add_beautiful_value
  local to_max_type = p.to_max_type or TOTAL_BEAUTY_MAX
  FurnitureBag.Instance():RemoveFurniture(uuid)
  HomelandModule.Instance():AddMyDisplayFurniture(uuid, {
    scene = HomelandModule.Area.Courtyard
  })
  local CourtyardMgr = require("Main.Homeland.CourtyardMgr")
  local courtyard = CourtyardMgr.Instance():GetMyCourtyard()
  local lastBeauty = courtyard:GetBeauty()
  local currentBeauty = lastBeauty + add_beautiful_value
  courtyard:SetBeauty(currentBeauty)
  HomelandUtils.CheckBeautyChange(lastBeauty, currentBeauty)
  if lastBeauty ~= currentBeauty then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardBeautyChange, nil)
  end
  local itemBase = ItemUtils.GetItemBase(furnitureId)
  if itemBase then
    local name = itemBase.name
    local namecolor = itemBase.namecolor
    local color = HtmlHelper.NameColor[namecolor]
    local coloredName = string.format("<font color=#%s>%s</font>", color, name)
    local text
    if add_beautiful_value > 0 then
      text = string.format(textRes.Homeland[98], coloredName, add_beautiful_value)
    elseif tomaxtype == TOTAL_BEAUTY_MAX then
      text = string.format(textRes.Homeland[104], coloredName)
    else
      text = string.format(textRes.Homeland[102], coloredName)
    end
    Toast(text)
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
end
def.static("table").OnSMoveFurnitureRes = function(p)
  local uuid = p.furnitureUuId
  local furnitureInfo = p.furnitureInfo
  local furnitureId = furnitureInfo.furnitureId
end
def.static("table").OnSMoveFurnitureFailedRes = function(p)
  local uuid = p.furnitureUuId
  Toast(textRes.Homeland[49])
end
def.static("table").OnSChangeWallRes = function(p)
  local itemId = p.furnitureId
  local changeFengshui = p.changeFengshui
  FurnitureBag.Instance():RemoveFurniture(p.furnitureUuId)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
  local HouseMgr = require("Main.Homeland.HouseMgr")
  local house = HouseMgr.Instance():GetMyHouse()
  local lastGeomancy = house:GetGeomancy()
  local currentGeomancy = lastGeomancy + changeFengshui
  house:SetGeomancy(currentGeomancy)
  HomelandUtils.CheckGeomancyChange(lastGeomancy, currentGeomancy)
  if lastGeomancy ~= currentGeomancy then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeGeomancyChange, nil)
  end
  local fengshuiText
  if changeFengshui > 0 then
    fengshuiText = string.format(textRes.Homeland[71], changeFengshui)
  elseif changeFengshui < 0 then
    fengshuiText = string.format(textRes.Homeland[72], changeFengshui)
  else
    fengshuiText = textRes.Homeland[73]
  end
  local itenName = HtmlHelper.GetColoredItemName(itemId)
  local text = string.format(textRes.Homeland[74], itenName, fengshuiText)
  Toast(text)
end
def.static("table").OnSChangeFloortieRes = function(p)
  local itemId = p.furnitureId
  local changeFengshui = p.changeFengshui
  FurnitureBag.Instance():RemoveFurniture(p.furnitureUuId)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
  local HouseMgr = require("Main.Homeland.HouseMgr")
  local house = HouseMgr.Instance():GetMyHouse()
  local lastGeomancy = house:GetGeomancy()
  local currentGeomancy = lastGeomancy + changeFengshui
  house:SetGeomancy(currentGeomancy)
  HomelandUtils.CheckGeomancyChange(lastGeomancy, currentGeomancy)
  if lastGeomancy ~= currentGeomancy then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeGeomancyChange, nil)
  end
  local fengshuiText
  if changeFengshui > 0 then
    fengshuiText = string.format(textRes.Homeland[71], changeFengshui)
  elseif changeFengshui < 0 then
    fengshuiText = string.format(textRes.Homeland[72], changeFengshui)
  else
    fengshuiText = textRes.Homeland[73]
  end
  local itenName = HtmlHelper.GetColoredItemName(itemId)
  local text = string.format(textRes.Homeland[75], itenName, fengshuiText)
  Toast(text)
end
def.static("table").OnSChangeCourtYardFurnitureSuccess = function(p)
  local itemId = p.furniture_cfg_Id
  local furniture_uuId = p.furniture_uuId
  local change_beautiful_value = p.change_beautiful_value
  local replacedItemId = p.unfurniture_cfg_Id
  FurnitureBag.Instance():RemoveFurniture(furniture_uuId)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
  local CourtyardMgr = require("Main.Homeland.CourtyardMgr")
  local courtyard = CourtyardMgr.Instance():GetMyCourtyard()
  local lastBeauty = courtyard:GetBeauty()
  local currentBeauty = lastBeauty + change_beautiful_value
  courtyard:SetBeauty(currentBeauty)
  HomelandUtils.CheckBeautyChange(lastBeauty, currentBeauty)
  if lastBeauty ~= currentBeauty then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardBeautyChange, nil)
  end
  local beautyText
  if change_beautiful_value > 0 then
    beautyText = string.format(textRes.Homeland[94], change_beautiful_value)
  elseif change_beautiful_value < 0 then
    beautyText = string.format(textRes.Homeland[95], change_beautiful_value)
  else
    beautyText = textRes.Homeland[96]
  end
  local itenName = HtmlHelper.GetColoredItemName(itemId)
  local replacedItenName = HtmlHelper.GetColoredItemName(replacedItemId)
  local text = string.format(textRes.Homeland[97], replacedItenName, itenName, beautyText)
  Toast(text)
end
def.static("table").OnSAddFurnitureRes = function(p)
  local uuid = p.furnitureUuId
  local furnitureId = p.furnitureId
  local furnitureInfo = {
    uuid = uuid,
    id = furnitureId,
    area = p.area
  }
  FurnitureBag.Instance():AddFurniture(furnitureInfo)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
end
def.static("table").OnSDecFurnitureRes = function(p)
  local uuid = p.furnitureUuId
  FurnitureBag.Instance():RemoveFurniture(uuid)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
end
def.static("table").OnSUnDisplayAllRes = function(p)
end
def.static("table").OnSInHomeRes = function(p)
end
def.static("table").OnSSendDivorceNoHomeRes = function(p)
  HomelandModule.Instance().m_haveHome = false
  HomelandModule.Instance().m_playerIsOwner = false
  HomelandModule.Instance().myDisplayFurniture = nil
end
def.static("table").OnSSynFengshuiRes = function(p)
  local HouseMgr = require("Main.Homeland.HouseMgr")
  local house = HouseMgr.Instance():GetMyHouse()
  local lastGeomancy = house:GetGeomancy()
  local currentGeomancy = p.fengshui
  house:SetGeomancy(currentGeomancy)
  if lastGeomancy ~= currentGeomancy then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeGeomancyChange, nil)
  end
  if gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHomeland() then
    HomelandUtils.CheckGeomancyChange(lastGeomancy, currentGeomancy)
  end
end
def.static("table").OnSSynCourtYardBeautifulRes = function(p)
  local courtyard = HomelandModule.Instance():GetMyCourtyard()
  local lastBeauty = courtyard:GetBeauty()
  local currentBeauty = p.beautiful
  courtyard:SetBeauty(currentBeauty)
  if lastBeauty ~= currentBeauty then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardBeautyChange, nil)
  end
  if gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHomeland() then
    HomelandUtils.CheckBeautyChange(lastBeauty, currentBeauty)
  end
end
def.static("table").OnSUnDisplayFurnitureRes = function(p)
  local uuid = p.furnitureUuId
  local furnitureId = p.furnitureId
  local decFengshui = p.decFengshui
  local furnitureInfo = {
    uuid = uuid,
    id = furnitureId,
    area = HomelandModule.Area.House
  }
  local isMyFurniture = false
  if HomelandModule.Instance():IsMyDisplayFurniture(uuid) then
    FurnitureBag.Instance():AddFurniture(furnitureInfo)
    HomelandModule.Instance():RemoveMyDisplayFurniture(uuid)
    isMyFurniture = true
  end
  local HouseMgr = require("Main.Homeland.HouseMgr")
  local house = HouseMgr.Instance():GetMyHouse()
  local lastGeomancy = house:GetGeomancy()
  local currentGeomancy = lastGeomancy - decFengshui
  house:SetGeomancy(currentGeomancy)
  HomelandUtils.CheckGeomancyChange(lastGeomancy, currentGeomancy)
  if lastGeomancy ~= currentGeomancy then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeGeomancyChange, nil)
  end
  local itemBase = ItemUtils.GetItemBase(furnitureId)
  if itemBase then
    local coloredName = getColoredName(itemBase)
    local text
    if isMyFurniture then
      if decFengshui > 0 then
        text = string.format(textRes.Homeland[25], coloredName, decFengshui)
      else
        text = string.format(textRes.Homeland[70], coloredName)
      end
    else
      local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
      if mateInfo then
        local mateName = mateInfo.mateName
        if decFengshui > 0 then
          text = string.format(textRes.Homeland[89], coloredName, mateName, decFengshui)
        else
          text = string.format(textRes.Homeland[90], coloredName, mateName)
        end
      end
    end
    if text then
      Toast(text)
    end
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
end
def.static("table").OnSUnDisplayCourtYardFurnitureRes = function(p)
  local uuid = p.furnitureUuId
  local furnitureId = p.furnitureId
  local dec_beautiful = p.dec_beautiful
  local furnitureInfo = {
    uuid = uuid,
    id = furnitureId,
    area = HomelandModule.Area.Courtyard
  }
  local isMyFurniture = false
  if HomelandModule.Instance():IsMyDisplayFurniture(uuid) then
    FurnitureBag.Instance():AddFurniture(furnitureInfo)
    HomelandModule.Instance():RemoveMyDisplayFurniture(uuid)
    isMyFurniture = true
  end
  local CourtyardMgr = require("Main.Homeland.CourtyardMgr")
  local courtyard = CourtyardMgr.Instance():GetMyCourtyard()
  local lastBeauty = courtyard:GetBeauty()
  local currentBeauty = lastBeauty - dec_beautiful
  courtyard:SetBeauty(currentBeauty)
  HomelandUtils.CheckBeautyChange(lastBeauty, currentBeauty)
  if lastBeauty ~= currentBeauty then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardBeautyChange, nil)
  end
  local itemBase = ItemUtils.GetItemBase(furnitureId)
  if itemBase then
    local coloredName = getColoredName(itemBase)
    local text
    if isMyFurniture then
      if dec_beautiful > 0 then
        text = string.format(textRes.Homeland[99], coloredName, dec_beautiful)
      else
        text = string.format(textRes.Homeland[103], coloredName)
      end
    else
      local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
      if mateInfo then
        local mateName = mateInfo.mateName
        if dec_beautiful > 0 then
          text = string.format(textRes.Homeland[100], coloredName, mateName, dec_beautiful)
        else
          text = string.format(textRes.Homeland[101], coloredName, mateName)
        end
      end
    end
    if text then
      Toast(text)
    end
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
end
def.static("table").OnSSynOwnFurnitureRes = function(p)
  local furnitureBag = FurnitureBag.Instance()
  furnitureBag:Clear()
  for id, uuids in pairs(p.furnitures) do
    for uuid, _ in pairs(uuids.uuids) do
      local furnitureInfo = {
        uuid = uuid,
        id = id,
        area = HomelandModule.Area.House
      }
      furnitureBag:AddFurniture(furnitureInfo)
    end
  end
  for id, uuids in pairs(p.court_yard_furnitures) do
    for uuid, _ in pairs(uuids.uuids) do
      local furnitureInfo = {
        uuid = uuid,
        id = id,
        area = HomelandModule.Area.Courtyard
      }
      furnitureBag:AddFurniture(furnitureInfo)
    end
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
end
def.static("table").OnSUseFurnitureItemRes = function(p)
  local uuid = p.furnitureUuId
  local furnitureId = p.furnitureId
  local furnitureInfo = {
    uuid = uuid,
    id = furnitureId,
    area = p.area
  }
  FurnitureBag.Instance():AddFurniture(furnitureInfo)
  local itemBase = ItemUtils.GetItemBase(furnitureId)
  if itemBase then
    local coloredName = getColoredName(itemBase)
    local text = string.format(textRes.Homeland[26], coloredName, decFengshui)
    Toast(text)
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
end
def.static("table").OnSCleanHomeRes = function(p)
  if p.area == HomelandModule.Area.Courtyard then
    local CourtyardMgr = require("Main.Homeland.CourtyardMgr")
    CourtyardMgr.OnSCleanCourtyardRes(p)
  else
    local HouseMgr = require("Main.Homeland.HouseMgr")
    HouseMgr.OnSCleanHomeRes(p)
  end
end
def.static("table").OnSSynCleanlinessRes = function(p)
  if p.area == HomelandModule.Area.Courtyard then
    local CourtyardMgr = require("Main.Homeland.CourtyardMgr")
  else
    local HouseMgr = require("Main.Homeland.HouseMgr")
    HouseMgr.OnSSynCleanlinessRes(p)
  end
end
def.static("table").OnSCommonResultRes = function(p)
  local text = textRes.Homeland.SCommonResultRes[p.res]
  if text then
    Toast(text)
  else
    warn(string.format("OnSCommonResultRes p.res=%d not handle", p.res))
  end
end
return HomelandProtocol.Commit()
