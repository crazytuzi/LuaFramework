local Lplus = require("Lplus")
local ItemAccessMgr = Lplus.Class("ItemAccessMgr")
local def = ItemAccessMgr.define
local ItemAccessDlg = require("Main.Item.ui.ItemAccessDlg")
local _instance
def.field("table").position = nil
def.static("=>", ItemAccessMgr).Instance = function()
  if _instance == nil then
    _instance = ItemAccessMgr()
  end
  return _instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResItemAccessWay", ItemAccessMgr._OnSource)
end
def.method("table", "number", "number", "number", "number", "number").ShowSources = function(self, itemIds, sourceX, sourceY, sourceW, sourceH, prefer)
  self.position = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local ids = {}
  for k, v in pairs(itemIds) do
    table.insert(ids, v)
  end
  local cAccess = require("netio.protocol.mzm.gsp.item.CReqItemAccessWay").new(ids)
  gmodule.network.sendProtocol(cAccess)
end
def.method("number", "number", "number", "number", "number", "number").ShowSiftSource = function(self, siftID, sourceX, sourceY, sourceW, sourceH, prefer)
  self.position = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local p = require("netio.protocol.mzm.gsp.item.CReqItemSiftCfg").new(siftID)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number", "number", "number", "number", "number").ShowSource = function(self, itemId, sourceX, sourceY, sourceW, sourceH, prefer)
  self.position = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local ids = {}
  local fakeItemCfg = DynamicData.GetRecord(CFG_PATH.DATA_FAKE_ITEM_CFG, itemId)
  if fakeItemCfg ~= nil then
    local idStruct = fakeItemCfg:GetStructValue("fakeItemStruct")
    local size = idStruct:GetVectorSize("fakeItemList")
    for i = 0, size - 1 do
      local rec = idStruct:GetVectorValueByIdx("fakeItemList", i)
      table.insert(ids, rec:GetIntValue("subItem"))
    end
  else
    table.insert(ids, itemId)
  end
  local cAccess = require("netio.protocol.mzm.gsp.item.CReqItemAccessWay").new(ids)
  gmodule.network.sendProtocol(cAccess)
end
def.method("number").ShowItemTipsAndSource = function(self, itemId)
  require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithPos(itemId, {
    x = 183,
    y = 0,
    vAlign = "center"
  }, true)
  self:ShowSource(itemId, 183, 153, 366, 0, -1)
end
def.static("table")._OnSource = function(p)
  local AccessType = require("consts.mzm.gsp.item.confbean.ItemAccessType")
  local source = {}
  local repeatCheck = {}
  local npcRepeatCheck = {}
  local activityRepeatCheck = {}
  local baotuRepeatCheck = {}
  for itemId, accessWay in pairs(p.itemAccessWay) do
    for k, v in pairs(accessWay.accessWays) do
      if v.accessWayType then
        local type = v.accessWayType
        if v.accessWayType == AccessType.GAGN_DRUG_SHOP then
          if repeatCheck[type] then
            table.insert(repeatCheck[type].itemIds, itemId)
          else
            local itemIds = {}
            table.insert(itemIds, itemId)
            local data = {
              type = type,
              id = nil,
              itemIds = itemIds
            }
            repeatCheck[type] = data
            table.insert(source, data)
          end
        elseif v.accessWayType == AccessType.VITALITY_EXCHANGE then
          if repeatCheck[type] then
            table.insert(repeatCheck[type].itemIds, itemId)
          else
            local itemIds = {}
            table.insert(itemIds, itemId)
            local data = {
              type = type,
              id = nil,
              itemIds = itemIds
            }
            repeatCheck[type] = data
            table.insert(source, data)
          end
        elseif v.accessWayType == AccessType.FURNITURE_SHOP then
          if repeatCheck[type] then
            table.insert(repeatCheck[type].itemIds, itemId)
          else
            local itemIds = {}
            table.insert(itemIds, itemId)
            local data = {
              type = type,
              id = nil,
              itemIds = itemIds
            }
            repeatCheck[type] = data
            table.insert(source, data)
          end
        elseif v.accessWayType == AccessType.CHANGE_MODEL_CARD_LOTTERY then
          if repeatCheck[type] then
            table.insert(repeatCheck[type].itemIds, itemId)
          else
            local itemIds = {}
            table.insert(itemIds, itemId)
            local data = {
              type = type,
              id = nil,
              itemIds = itemIds
            }
            repeatCheck[type] = data
            table.insert(source, data)
          end
        else
          for k1, v1 in pairs(v.idList) do
            if type == AccessType.NPC_SHOP then
              local serviceId = v1
              local npcIds = require("Main.npc.NPCInterface").GetNpcByServiceId(serviceId)
              if npcIds ~= nil then
                for k2, v2 in ipairs(npcIds.npcIds) do
                  if npcRepeatCheck[v2] then
                    table.insert(npcRepeatCheck[v2].itemIds, itemId)
                  else
                    local itemIds = {}
                    table.insert(itemIds, itemId)
                    local data = {
                      type = type,
                      id = v2,
                      service = serviceId,
                      itemIds = itemIds
                    }
                    npcRepeatCheck[v2] = data
                    table.insert(source, data)
                  end
                end
              end
            elseif type == AccessType.ACTIVITY then
              local activityId = v1
              if activityRepeatCheck[activityId] then
                table.insert(activityRepeatCheck[activityId].itemIds, itemId)
              else
                local itemIds = {}
                table.insert(itemIds, itemId)
                local data = {
                  type = type,
                  id = activityId,
                  itemIds = itemIds
                }
                activityRepeatCheck[activityId] = data
                table.insert(source, data)
              end
            elseif type == AccessType.BAOTU then
              local baotuId = v1
              if baotuRepeatCheck[baotuId] then
                table.insert(baotuRepeatCheck[baotuId].itemIds, itemId)
              else
                local itemIds = {}
                table.insert(itemIds, itemId)
                local data = {
                  type = type,
                  id = baotuId,
                  itemIds = itemIds
                }
                baotuRepeatCheck[baotuId] = data
                table.insert(source, data)
              end
            else
              local id = v1
              if repeatCheck[type] then
                table.insert(repeatCheck[type].itemIds, itemId)
              else
                local itemIds = {}
                table.insert(itemIds, itemId)
                local data = {
                  type = type,
                  id = id,
                  itemIds = itemIds
                }
                repeatCheck[type] = data
                table.insert(source, data)
              end
            end
          end
        end
      end
    end
  end
  if #source > 0 then
    table.sort(source, function(a, b)
      local aSort = ItemAccessMgr.GetSourceSort(a.type)
      local bSort = ItemAccessMgr.GetSourceSort(b.type)
      return aSort < bSort
    end)
    _instance:_Show(source)
  else
    Toast(textRes.Item[31])
  end
end
local typeSort = {}
def.static("number", "=>", "number").GetSourceSort = function(sourceType)
  if typeSort[sourceType] then
    return typeSort[sourceType]
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEMSOURCE_CFG, sourceType)
  if record then
    local sort = record:GetIntValue("sort")
    typeSort[sourceType] = sort
    return sort
  else
    return math.huge
  end
end
def.method("table")._Show = function(self, source)
  ItemAccessDlg.ShowItemSource(source, self.position)
end
ItemAccessMgr.Commit()
return ItemAccessMgr
