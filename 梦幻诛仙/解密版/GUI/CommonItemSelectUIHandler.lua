local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GUIHandlerBase = require("GUI.GUIHandlerBase")
local CommonItemSelectUIHandler = Lplus.Extend(GUIHandlerBase, MODULE_NAME)
local Cls = CommonItemSelectUIHandler
local def = Cls.define
local GUIUtils = require("GUI.GUIUtils")
def.field("userdata").m_listGO = nil
def.method("string").SetTitle = function(self, title)
  local Label_Title = self.m_rootGO:FindDirect("Img_Bg/Img_BgTitle/Label_Title")
  GUIUtils.SetText(Label_Title, title)
end
def.method("string").SetTips = function(self, tips)
  local Label_Tips = self.m_rootGO:FindDirect("Img_Bg/Label_Tips")
  GUIUtils.SetText(Label_Tips, tips)
end
def.method("table", "function").SetItemList = function(self, items, onSetItemObj)
  onSetItemObj = onSetItemObj or self.SetItemObj
  local listView = self.m_rootGO:FindDirect("Img_Bg/Img_Background/Scroll View/Grid")
  self.m_listGO = listView
  local itemNum = #items
  local listItems = GUIUtils.InitUIList(listView, itemNum, true)
  for i = 1, itemNum do
    local itemObj = listItems[i]
    local item = items[i]
    onSetItemObj(self, i, itemObj, item)
  end
  GUIUtils.Reposition(listView, "UIList", 0.01)
end
def.method("number", "userdata", "table").SetItemObj = function(self, index, itemObj, itemViewData)
  local nameLabel = itemObj:FindDirect("Label_Name")
  local levelLabel = itemObj:FindDirect("Label_Lv")
  local bgSprite = itemObj:FindDirect("Img_BgIcon")
  local iconTexture = itemObj:FindDirect("Img_BgIcon/Img_Icon")
  GUIUtils.SetText(nameLabel, itemViewData.nameText)
  GUIUtils.SetText(levelLabel, itemViewData.levelText)
  GUIUtils.SetSprite(bgSprite, itemViewData.iconBGSpriteName)
  GUIUtils.SetTexture(iconTexture, itemViewData.iconId)
end
def.method("userdata").SetIconBGAtlas = function(self, atlas)
  local listView = self.m_rootGO:FindDirect("Img_Bg/Img_Background/Scroll View/Grid")
  local childCount = listView.childCount
  for i = 1, childCount do
    local itemObj = listView:GetChild(i - 1)
    local Img_BgIcon = itemObj:FindDirect("Img_BgIcon")
    local uiSprite = Img_BgIcon:GetComponent("UISprite")
    uiSprite:set_atlas(atlas)
  end
end
def.method("userdata", "=>", "boolean").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local isCaptured = true
  if id:find("^item_") then
    local index = self:FindObjIndex(clickObj)
    if index > 0 then
      self:SendEvent("OnClickItem", clickObj, index)
    end
  elseif id == "Img_BgIcon" then
    local index = self:FindObjIndex(clickObj)
    if index > 0 then
      self:SendEvent("OnClickItemIcon", clickObj, index)
    end
  elseif id == "Btn_Confirm" then
    self:SendEvent("OnClickConfirmBtn")
  else
    isCaptured = false
  end
  return isCaptured
end
def.method("userdata", "=>", "number").FindObjIndex = function(self, obj)
  local MAX_DEPTH = 5
  local index = -1
  for i = 1, MAX_DEPTH do
    local parentObj = obj.parent
    if parentObj == nil then
      break
    end
    if parentObj:IsEq(self.m_listGO) then
      index = tonumber(obj.name:split("_")[2])
    end
    obj = parentObj
  end
  return index
end
return Cls.Commit()
