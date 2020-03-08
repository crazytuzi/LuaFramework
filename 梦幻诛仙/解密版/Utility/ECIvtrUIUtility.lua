local Lplus = require("Lplus")
local ECIvtrItems = require("Inventory.ECIvtrItems")
local ECItemTools = require("Inventory.ECItemTools")
local ECUIUtility = require("Utility.ECUIUtility")
local ECGUITools = require("GUI.ECGUITools")
local ECIvtrUIUtility = Lplus.Class("ECIvtrUIUtility")
do
  local def = ECIvtrUIUtility.define
  def.static("userdata", ECIvtrItems.ECIvtrItem).SetIcon = function(itemControl, item)
    return ECIvtrUIUtility.SetIconInternal(itemControl, item, false)
  end
  def.static("userdata", ECIvtrItems.ECIvtrItem, "boolean").SetIconEx = function(itemControl, item, bShowUpDown)
    return ECIvtrUIUtility.SetIconInternal(itemControl, item, bShowUpDown)
  end
  def.static("userdata", "number", "number").SetIconEx2 = function(itemControl, tid, num)
    local ElementData = require("Data.ElementData")
    local data, datatype = ElementData.getEssence(tid)
    if not data then
      warn("can not find item with tid = ", tid)
      return
    end
    local Img_Item = itemControl:FindChild("Img_Item")
    local Img_Color = itemControl:FindChild("Img_Color")
    local Txt_Num = itemControl:FindChild("Txt_Num")
    local Img_Bind = itemControl:FindChild("Img_Bind")
    ECUIUtility.SetIvtrItemIcon(Img_Item:GetComponent("UISprite"), tid)
    if data.common_prop ~= nil then
      local borderName = ECGUITools.GetBorderName(data.common_prop.quality)
      Img_Color:SetActive(true)
      Img_Color:GetComponent("UISprite").spriteName = borderName
    else
      Img_Color:SetActive(false)
    end
    if num == 0 or num == 1 then
      Txt_Num:SetActive(false)
    else
      Txt_Num:SetActive(true)
      Txt_Num:GetComponent("UILabel").text = tostring(num)
    end
    if Img_Bind ~= nil then
      Img_Bind:SetActive(false)
    end
  end
  def.static("userdata", "number", "boolean").SetMoneyIcon = function(itemControl, count, isBind)
    local Img_Item = itemControl:FindChild("Img_Item")
    local Img_Color = itemControl:FindChild("Img_Color")
    local Txt_Num = itemControl:FindChild("Txt_Num")
    local Img_Bind = itemControl:FindChild("Img_Bind")
    local Img_Quest = itemControl:FindChild("Img_Quest")
    local Img_Non = itemControl:FindChild("Img_Non")
    local Img_Up = itemControl:FindChild("Img_Up")
    local Img_Down = itemControl:FindChild("Img_Down")
    local money_icon = trade_money_icon_id
    if isBind then
      money_icon = bound_money_icon_id
    end
    Img_Item:SetActive(true)
    ECUIUtility.SetIconByPathId(Img_Item, money_icon)
    if count == 0 then
      Txt_Num:SetActive(false)
    else
      Txt_Num:SetActive(true)
      Txt_Num:GetComponent("UILabel").text = ECGUITools.SetMoneyString(count)
    end
    if Img_Bind ~= nil then
      Img_Bind:SetActive(isBind)
    end
    Img_Color:SetActive(false)
    if Img_Quest ~= nil then
      Img_Quest:SetActive(false)
    end
    if Img_Non ~= nil then
      Img_Non:SetActive(false)
    end
    if Img_Up ~= nil then
      Img_Up:SetActive(false)
    end
    if Img_Down ~= nil then
      Img_Down:SetActive(false)
    end
  end
  def.static("userdata", ECIvtrItems.ECIvtrItem, "boolean").SetIconInternal = function(itemControl, item, bShowUpDown)
    local Img_Item = itemControl:FindChild("Img_Item")
    local Txt_Num = itemControl:FindChild("Txt_Num")
    local Img_Bind = itemControl:FindChild("Img_Bind")
    local Img_Color = itemControl:FindChild("Img_Color")
    local Img_Quest = itemControl:FindChild("Img_Quest")
    local Img_Non = itemControl:FindChild("Img_Non")
    local Img_Up = itemControl:FindChild("Img_Up")
    local Img_Down = itemControl:FindChild("Img_Down")
    if not item then
      Img_Item:SetActive(false)
      Txt_Num:SetActive(false)
      if Img_Bind ~= nil then
        Img_Bind:SetActive(false)
      end
      Img_Color:SetActive(false)
      if Img_Quest ~= nil then
        Img_Quest:SetActive(false)
      end
      if Img_Non ~= nil then
        Img_Non:SetActive(false)
      end
      if Img_Up ~= nil then
        Img_Up:SetActive(false)
      end
      if Img_Down ~= nil then
        Img_Down:SetActive(false)
      end
      return
    end
    local isEquip, isBind, isQuest, isUp, canUse, coldtime, coldID, num, expathID, borderName = ECItemTools.GetGridState(item)
    Img_Item:SetActive(true)
    ECUIUtility.SetIvtrItemIcon(Img_Item:GetComponent("UISprite"), item.tid)
    if num == 0 then
      Txt_Num:SetActive(false)
    else
      Txt_Num:SetActive(true)
      Txt_Num:GetComponent("UILabel").text = num .. ""
    end
    if Img_Bind ~= nil then
      Img_Bind:SetActive(isBind)
    end
    if borderName:len() ~= 0 then
      Img_Color:SetActive(true)
      Img_Color:GetComponent("UISprite").spriteName = borderName
    else
      Img_Color:SetActive(false)
    end
    if Img_Quest ~= nil then
      if isQuest then
        Img_Quest:SetActive(true)
        ECGUITools.UpdateGridImage(datapath.GetPathByID(expathID), Img_Quest)
      else
        Img_Quest:SetActive(false)
      end
    end
    if Img_Non ~= nil then
      Img_Non:SetActive(ECItemTools.UseRedColor(item))
    end
    if bShowUpDown and Img_Up ~= nil and Img_Down ~= nil then
      Img_Up:SetActive(isEquip and isUp)
      Img_Down:SetActive(isEquip and not isUp)
    end
  end
end
return ECIvtrUIUtility.Commit()
