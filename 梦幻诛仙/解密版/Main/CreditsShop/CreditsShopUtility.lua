local Lplus = require("Lplus")
local CreditsShopUtility = Lplus.Class("CreditsShopUtility")
local Vector = require("Types.Vector")
local def = CreditsShopUtility.define
def.static("table", "userdata", "=>", "table").FillCreditsShopUI = function(uiTbl, node)
  uiTbl = {}
  local Img_Bg0 = node:FindDirect("Img_Bg0")
  local Img_Bg1 = node:FindDirect("Img_Bg1")
  local Img_BgItems = Img_Bg1:FindDirect("Img_BgItems")
  local ScrollView_Items = Img_BgItems:FindDirect("Scroll View_Items")
  local Grid_Items = ScrollView_Items:FindDirect("Grid_Items")
  local Img_BgItem = Grid_Items:FindDirect("Img_BgItem")
  uiTbl["Scroll View_Items"] = ScrollView_Items
  uiTbl.Grid_Items = Grid_Items
  uiTbl.Img_BgItem = Img_BgItem
  local Img_BgDetail = Img_Bg1:FindDirect("Img_BgDetail")
  local Group_NoChoice = Img_BgDetail:FindDirect("Group_NoChoice")
  uiTbl.Group_NoChoice = Group_NoChoice
  local Group_ItemInfo = Img_BgDetail:FindDirect("Group_ItemInfo")
  local Group_Detail = Group_ItemInfo:FindDirect("Group_Detail")
  local Group_Buy = Group_ItemInfo:FindDirect("Group_Buy")
  uiTbl.Group_ItemInfo = Group_ItemInfo
  uiTbl.Group_Detail = Group_Detail
  uiTbl.Group_Buy = Group_Buy
  local List_Class = Img_Bg1:FindDirect("Group_Type/Scrollview/List_Class")
  uiTbl.List_Class = List_Class
  return uiTbl
end
def.static("userdata", "userdata", "number", "string").CreateNewGroup = function(groupNew, gridTemplate, count, name)
  groupNew:set_name(string.format(name, count))
  groupNew.parent = gridTemplate
  groupNew:set_localScale(Vector.Vector3.one)
  groupNew:SetActive(true)
end
def.static("number", "string", "userdata").DeleteLastGroup = function(listNum, groupName, gridTemplate)
  local template = gridTemplate:FindDirect(string.format(groupName, listNum))
  Object.Destroy(template)
  template = nil
end
def.static("number", "string", "userdata", "userdata").AddLastGroup = function(listNum, groupName, gridTemplate, groupTemplate)
  local groupNew = Object.Instantiate(groupTemplate)
  CreditsShopUtility.CreateNewGroup(groupNew, gridTemplate, listNum, groupName)
end
def.static("string", "userdata").FillIcon = function(iconId, uiSprite)
  local atlas = RESPATH.COMMONATLAS
  GameUtil.AsyncLoad(atlas, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    uiSprite:set_atlas(atlas)
    uiSprite:set_spriteName(iconId)
  end)
end
return CreditsShopUtility.Commit()
