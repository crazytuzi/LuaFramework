local Lplus = require("Lplus")
local PresentUtility = Lplus.Class("PresentUtility")
local Vector = require("Types.Vector")
local def = PresentUtility.define
def.static("table", "userdata", "=>", "table").FillPresentUI = function(uiTbl, node)
  uiTbl = {}
  local Img_Bg0 = node:FindDirect("Img_Bg0")
  local Group_Tab = Img_Bg0:FindDirect("Group_Tab")
  local Tab_Item = Group_Tab:FindDirect("Tab_Item")
  local Tab_Present = Group_Tab:FindDirect("Tab_Present")
  uiTbl.Tab_Item = Tab_Item
  uiTbl.Tab_Present = Tab_Present
  local List = Img_Bg0:FindDirect("List")
  local ScrollView_EquipList = List:FindDirect("Scroll View_EquipList")
  local Grid_List = ScrollView_EquipList:FindDirect("Grid_List")
  uiTbl["Scroll View_EquipList"] = ScrollView_EquipList
  uiTbl.Grid_List = Grid_List
  local Group_Flower = Img_Bg0:FindDirect("Group_Flower")
  local Group_Item = Img_Bg0:FindDirect("Group_Item")
  uiTbl.Group_Flower = Group_Flower
  uiTbl.Group_Item = Group_Item
  return uiTbl
end
def.static("table", "userdata", "=>", "table").FillPresentItemUI = function(uiTbl, node)
  uiTbl = {}
  local Group_Bag = node:FindDirect("Group_Bag")
  local ScrollView_Bag = Group_Bag:FindDirect("Scroll View_Bag")
  local Grid_Bag = ScrollView_Bag:FindDirect("Grid_Bag")
  uiTbl["Scroll View_Bag"] = ScrollView_Bag
  uiTbl.Grid_Bag = Grid_Bag
  local Img_ItemPresent = node:FindDirect("Img_ItemPresent")
  local Grid_Present = Img_ItemPresent:FindDirect("Grid_Present")
  uiTbl.Grid_Present = Grid_Present
  local Group_Slider = node:FindDirect("Group_Slider")
  local Group_Times = Group_Slider:FindDirect("Group_Times")
  local Img_BgSlider1 = Group_Times:FindDirect("Img_BgSlider1")
  uiTbl.Img_BgSlider1 = Img_BgSlider1
  local Group_Price = Group_Slider:FindDirect("Group_Price")
  local Img_BgSlider2 = Group_Price:FindDirect("Img_BgSlider2")
  uiTbl.Img_BgSlider2 = Img_BgSlider2
  return uiTbl
end
def.static("table", "userdata", "=>", "table").FillPresentGiftUI = function(uiTbl, node)
  uiTbl = {}
  local Group_Bag = node:FindDirect("Group_Bag")
  local ScrollView_Bag = Group_Bag:FindDirect("Scroll View_Bag")
  local Grid_Bag = ScrollView_Bag:FindDirect("Grid_Bag")
  uiTbl["Scroll View_Bag"] = ScrollView_Bag
  uiTbl.Grid_Bag = Grid_Bag
  local Img_FlowerPresent = node:FindDirect("Img_FlowerPresent")
  local Grid_Present = Img_FlowerPresent:FindDirect("Grid_Present")
  uiTbl.Grid_Present = Grid_Present
  local Label_Num = node:FindDirect("Label_Num")
  local Img_BgInput = node:FindDirect("Img_BgInput")
  local Label_Message = Img_BgInput:FindDirect("Label_Message")
  uiTbl.Label_Num = Label_Num
  uiTbl.Img_BgInput = Img_BgInput
  uiTbl.Label_Message = Label_Message
  return uiTbl
end
def.static("number", "=>", "number").GetItemPresentMax = function(levelD)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PRESENT_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local minLevelDelta = DynamicRecord.GetIntValue(entry, "minLevelDelta")
    local maxLevelDelta = DynamicRecord.GetIntValue(entry, "maxLevelDelta")
    local giveNum = DynamicRecord.GetIntValue(entry, "giveNum")
    if levelD >= minLevelDelta and levelD <= maxLevelDelta then
      DynamicDataTable.FastGetRecordEnd(entries)
      return giveNum
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return 0
end
def.static("userdata", "=>", "number", "number").GetMallPresentMax = function(yuanbao)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PRESENT_MALL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local minYuanbao = DynamicRecord.GetIntValue(entry, "minYuanbao")
    local maxYuanbao = DynamicRecord.GetIntValue(entry, "maxYuanbao")
    local totalYuanbao = DynamicRecord.GetIntValue(entry, "totalYuanbao")
    if Int64.ge(yuanbao, minYuanbao) and Int64.le(yuanbao, maxYuanbao) then
      DynamicDataTable.FastGetRecordEnd(entries)
      return totalYuanbao, minYuanbao
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return 0, 0
end
def.static("string", "=>", "number").GetPresentConsts = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PRESENT_CONST_CFG, name)
  return DynamicRecord.GetIntValue(record, "value")
end
def.static("number", "=>", "table").GetFlowerInfo = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FLOWER_CFG, itemId)
  local info = {}
  info.id = record:GetIntValue("id")
  info.addIntimacyNum = record:GetIntValue("addIntimacyNum")
  info.rankPoint = record:GetIntValue("rankPoint")
  info.effectid = record:GetIntValue("effectid")
  info.isbulletin = record:GetCharValue("isbulletin") ~= 0
  info.isservereffect = record:GetCharValue("isservereffect") ~= 0
  return info
end
return PresentUtility.Commit()
