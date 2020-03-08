local Lplus = require("Lplus")
local AtlasMan = require("GUI.AtlasMan")
local ECEquipDesc = require("Data.ECEquipDesc")
local EC = require("Types.Vector3")
local l_allConfigs = dofile("Configs/input_limit.lua").getAllConfigs()
local ECLuaString = require("Utility.ECFilter").ECLuaString
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECGUITools = Lplus.Class("ECGUITools")
local def = ECGUITools.define
def.static("string", "userdata", "function").UpdateGridImageInner = function(imagePath, grid, cb)
  if string.len(imagePath) ~= 0 then
    local function callback(atlasComponent)
      if grid and not grid.isnil then
        local sprite = grid:GetComponent("UISprite")
        if sprite then
          sprite.atlas = nil
          sprite.atlas = atlasComponent
          sprite.spriteName = "Sprite"
        end
      end
    end
    local sprite = grid:GetComponent("UISprite")
    local atlas = sprite.gameObject:GetComponent("UIAtlas")
    if not atlas then
      atlas = sprite.gameObject:AddComponent("UIAtlas")
      atlas.alone = true
      sprite.atlas = atlas
    end
    AtlasMan.Instance():UpdateGridImage(imagePath, atlas, cb or callback)
  else
    AtlasMan.Instance():GetAtlas(RESPATH.InventoryAtlas, function(atlas)
      if not atlas then
        return
      end
      if not grid or grid.isnil then
        return
      end
      local sprite = grid:GetComponent("UISprite")
      sprite.atlas = atlas
      sprite.spriteName = "Grid_Time"
    end)
  end
end
def.static("string", "userdata").UpdateLable = function(description, label)
  local label = label:GetComponent("UILabel")
  if label then
    label:set_text(description)
  end
end
def.static("userdata", "userdata").SetLableColor = function(color, label)
  local label = label:GetComponent("UILabel")
  if label and color then
    label.color = color
  end
end
def.static("number", "=>", "string").GetBorderName = function(quality)
  if quality < 0 or quality > 5 then
    return "Grid"
  end
  if quality == 0 then
    return "Equip_Frame01"
  end
  local spriteName = {
    "Equip_Frame01",
    "Equip_Frame02",
    "Equip_Frame03",
    "Equip_Frame04",
    "Equip_Frame05"
  }
  return spriteName[quality]
end
def.static("number", "=>", "string").GetBackgroundName = function(quality)
  if quality <= 0 or quality > 5 then
    return "Grid"
  end
  local spriteName = {
    "Equip_Compart01",
    "Equip_Compart02",
    "Equip_Compart03",
    "Equip_Compart04",
    "Equip_Compart05"
  }
  return spriteName[quality]
end
def.static("number", "=>", "string").GetTipBgSpriteName = function(quality)
  if quality <= 0 or quality > 5 then
    return "TipsBg01"
  end
  local spriteName = {
    "TipsBg01",
    "TipsBg02",
    "TipsBg03",
    "TipsBg04",
    "TipsBg05"
  }
  return spriteName[quality]
end
def.static("number", "=>", "string").SetMoneyString = function(money)
  if money < 0 then
    return ""
  end
  local desc = ""
  local num = math.floor(money / 1000000)
  if num == 0 then
    num = math.floor(money / 1000)
    if num == 0 then
      desc = tostring(money) .. "\230\150\135"
    else
      local money = math.fmod(money, 1000)
      if money ~= 0 then
        desc = tostring(num) .. "\228\184\164" .. tostring(money) .. "\230\150\135"
      else
        desc = tostring(num) .. "\228\184\164"
      end
    end
  else
    desc = tostring(math.floor(money / 1000000)) .. "\233\148\173"
    money = math.fmod(money, 1000000)
    num = math.floor(money / 1000)
    if num ~= 0 then
      local money = math.fmod(money, 1000)
      if money ~= 0 then
        desc = desc .. tostring(num) .. "\228\184\164" .. tostring(money) .. "\230\150\135"
      else
        desc = desc .. tostring(num) .. "\228\184\164"
      end
    end
  end
  return desc
end
def.static("boolean", "number", "=>", "string").SetMoneyStringAndColor = function(moneytype, money)
  if money < 0 then
    return ""
  end
  local moneyString = ECGUITools.SetMoneyString(money)
  local color = ""
  local packMoney = 0
  if moneytype then
    packMoney = ECGame.Instance().m_HostPlayer.Package.NormalPack.BindMoney
  else
    packMoney = ECGame.Instance().m_HostPlayer.Package.NormalPack.Money
  end
  if money <= packMoney then
    color = "[00FF00]"
  else
    color = "[FF0000]"
  end
  return color .. moneyString .. "[-]"
end
local openOperation = {
  Panel_Char = function()
    local ECPanel = require("GUI.ECPanelChar")
    ECPanel.Instance():Toggle(2)
  end,
  Panel_Arena = function()
    local ECPanel = require("GUI.ECPanelArena")
    ECPanel.Instance():Toggle()
  end,
  Panel_HeroFight = function()
    local ECPanel = require("GUI.ECPanelHeroFight")
    ECPanel.Instance():ShowPanel(true)
  end,
  Panel_QuestSeriesNew = function()
    local ECPanel = require("GUI.ECPanelQuestSeriesNew")
    ECPanel.OpenSelfServe(1)
  end,
  Panel_Faction = function()
    local ECPanel = require("GUI.ECPanelFaction")
    ECPanel.Instance():Toggle()
  end,
  Panel_Plant = function()
    local ECPanel = require("GUI.ECPanelPlant")
    ECPanel.Instance():Toggle()
  end,
  Panel_ChallengeMain = function()
    local ECPanel = require("GUI.ECPanelChallengeMain")
    ECPanel.Instance():Toggle()
  end,
  Panel_Plant = function()
    local ECPanel = require("GUI.ECPanelPlant")
    ECPanel.Instance():Toggle()
  end
}
def.static("string", "table").OpenPanel = function(panelName, location)
  if not location then
    warn("\230\178\161\230\156\137\229\161\171location")
    return
  end
  if location.type == "custom" then
    local op = location.target
    op()
  end
end
local Enum = require("Utility.Enum")
def.const("table").LeanDirect = Enum.make({
  "none",
  "hori",
  "vert",
  "all"
})
def.static("userdata", "userdata", "userdata").AdjustPanelPos = function(panel, boxcolliderGO, bg)
  ECGUITools.AdjustPanelPosHori(panel, boxcolliderGO, bg, bg)
  ECGUITools.AdjustPanelPosVert(panel, boxcolliderGO, bg, bg)
  return
end
def.static("userdata", "userdata", "userdata", "userdata").AdjustPanelPosVert = function(panel, boxcolliderGO, alignObj1, alignObj2)
  if not panel or panel.isnil then
    return
  end
  local worldCorners = alignObj1:GetComponent("UIWidget").worldCorners
  local worldCorners2 = alignObj2:GetComponent("UIWidget").worldCorners
  local camera = ECGUIMan.Instance().m_camera
  if not camera then
    return
  end
  local wleftbottom, wrighttop
  local offsetxpanel = 0
  local offsetypanel = 0
  if boxcolliderGO and not boxcolliderGO.isnil then
    local box = boxcolliderGO:GetComponent("BoxCollider")
    if not box then
      return
    end
    local center = box.center
    local lx = center.x - box.size.x / 2
    local ly = center.y - box.size.y / 2
    local lx2 = center.x + box.size.x / 2
    local ly2 = center.y + box.size.y / 2
    wleftbottom = box.gameObject:TransformPoint(EC.Vector3.new(lx, ly, 0))
    wrighttop = box.gameObject:TransformPoint(EC.Vector3.new(lx2, ly2, 0))
    offsetxpanel = 0
    offsetypanel = wrighttop.y - worldCorners[3].y
    local tmp = {}
    for i = 1, 4 do
      tmp[i] = worldCorners[i] + EC.Vector3.new(offsetxpanel, offsetypanel, 0)
    end
    local tmpPt = {
      [1] = camera:WorldToScreenPoint(tmp[1]),
      [2] = camera:WorldToScreenPoint(tmp[2]),
      [3] = camera:WorldToScreenPoint(tmp[3]),
      [4] = camera:WorldToScreenPoint(tmp[4])
    }
    if 0 > tmpPt[1].y then
      local adjustPt = camera:ScreenToWorldPoint(EC.Vector3.new(tmpPt[1].x, 5, 0))
      offsetypanel = adjustPt.y - worldCorners[1].y
    end
    panel:Translate(EC.Vector3.new(offsetxpanel, offsetypanel, 0), 0)
  end
end
def.static("userdata", "userdata", "userdata", "userdata").AdjustPanelPosVertDown = function(panel, boxcolliderGO, alignObj1, alignObj2)
  if not panel or panel.isnil then
    return
  end
  local worldCorners = alignObj1:GetComponent("UIWidget").worldCorners
  local worldCorners2 = alignObj2:GetComponent("UIWidget").worldCorners
  local camera = ECGUIMan.Instance().m_camera
  if not camera then
    return
  end
  local wleftbottom, wrighttop
  local offsetxpanel = 0
  local offsetypanel = 0
  if boxcolliderGO and not boxcolliderGO.isnil then
    local box = boxcolliderGO:GetComponent("BoxCollider")
    if not box then
      return
    end
    local center = box.center
    local lx = center.x - box.size.x / 2
    local ly = center.y - box.size.y / 2
    local lx2 = center.x + box.size.x / 2
    local ly2 = center.y + box.size.y / 2
    wleftbottom = box.gameObject:TransformPoint(EC.Vector3.new(lx, ly, 0))
    wrighttop = box.gameObject:TransformPoint(EC.Vector3.new(lx2, ly2, 0))
    offsetxpanel = 0
    offsetypanel = wleftbottom.y - worldCorners[2].y
    local tmp = {}
    for i = 1, 4 do
      tmp[i] = worldCorners[i] + EC.Vector3.new(offsetxpanel, offsetypanel, 0)
    end
    local tmpPt = {
      [1] = camera:WorldToScreenPoint(tmp[1]),
      [2] = camera:WorldToScreenPoint(tmp[2]),
      [3] = camera:WorldToScreenPoint(tmp[3]),
      [4] = camera:WorldToScreenPoint(tmp[4])
    }
    if 0 > tmpPt[1].y then
      local adjustPt = camera:ScreenToWorldPoint(EC.Vector3.new(tmpPt[1].x, 5, 0))
      offsetypanel = adjustPt.y - worldCorners[1].y
    end
    panel:Translate(EC.Vector3.new(offsetxpanel, offsetypanel, 0), 0)
  end
end
def.const("function").AdjustPanelPosHori = function(panel, boxcolliderGO, alignObj1, alignObj2, btnState)
  btnState = btnState or 0
  if not panel or panel.isnil then
    return
  end
  local worldCorners = alignObj1:GetComponent("UIWidget").worldCorners
  local worldCorners2 = alignObj2:GetComponent("UIWidget").worldCorners
  local camera = ECGUIMan.Instance().m_camera
  if not camera then
    return
  end
  local wleftbottom, wrighttop
  local offsetxpanel = 0
  local offsetypanel = 0
  if boxcolliderGO and not boxcolliderGO.isnil then
    local box = boxcolliderGO:GetComponent("BoxCollider")
    if not box then
      return
    end
    local center = box.center
    local lx = center.x - box.size.x / 2
    local ly = center.y - box.size.y / 2
    local lx2 = center.x + box.size.x / 2
    local ly2 = center.y + box.size.y / 2
    wleftbottom = box.gameObject:TransformPoint(EC.Vector3.new(lx, ly, 0))
    wrighttop = box.gameObject:TransformPoint(EC.Vector3.new(lx2, ly2, 0))
    offsetxpanel = wrighttop.x - worldCorners[1].x
    offsetypanel = 0
    local tmp = {}
    for i = 1, 4 do
      tmp[i] = worldCorners[i] + EC.Vector3.new(offsetxpanel, offsetypanel, 0)
    end
    local tmpPt = {
      [1] = camera:WorldToScreenPoint(tmp[1]),
      [2] = camera:WorldToScreenPoint(tmp[2]),
      [3] = camera:WorldToScreenPoint(tmp[3]),
      [4] = camera:WorldToScreenPoint(tmp[4])
    }
    local spaceX = 0
    if alignObj1 ~= alignObj2 then
      local l, r = camera:WorldToScreenPoint(worldCorners2[2]), camera:WorldToScreenPoint(worldCorners2[3])
      spaceX = r.x - l.x
    end
    if tmpPt[3].x > Screen.width - spaceX then
      if btnState < 0 then
        offsetxpanel = wleftbottom.x - worldCorners2[3].x
      else
        offsetxpanel = wleftbottom.x - worldCorners[3].x
      end
    end
    panel:Translate(EC.Vector3.new(offsetxpanel, offsetypanel, 0), 0)
  end
end
local setTextAndColor = function(obj, text, color)
  local label = obj:GetComponent("UILabel")
  label.text = text
  if color then
    label.textColor = color
  end
end
local function setTextAndColor2(obj, text, quality)
  local label = obj:GetComponent("UILabel")
  if string.len(text) == 0 or not quality or quality < 0 then
    label.text = text
    return
  end
  local color = ECEquipDesc.GetTextColor(quality)
  local desc = color .. text .. "[-]"
  label.text = desc
end
local function setTextAndColor3(obj, text, greenOrRed)
  local label = obj:GetComponent("UILabel")
  if string.len(text) == 0 then
    label.text = text
    return
  end
  local color
  if greenOrRed then
    color = ECEquipDesc.GetTextColor(11)
  else
    color = ECEquipDesc.GetTextColor(12)
  end
  local desc = color .. text .. "[-]"
  label.text = desc
end
local setFontSizeAndStyle = function(obj, size, style)
  if not size and not style then
    return
  end
  local label = obj:GetComponent("UILabel")
  if size then
    label.fontSize = size
  end
  if style then
    label.fontStyle = style
  end
end
local function setDefaultIcon(obj, cid)
  local ECIvtrItems = require("Inventory.ECIvtrItems")
  local spriteName = ""
  local res = RESPATH.ActivityAtlas
  if cid == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_UNKNOWN then
    spriteName = "Map_QuestDone"
    res = RESPATH.CommonAtlas
  elseif cid == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_MEDICINE then
    spriteName = "ActivityAll"
  elseif cid == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_ESTONE then
    spriteName = "ActivityHot"
  elseif cid == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_SSTONE then
    spriteName = "ActivityHotHover"
  end
  ECGUITools.setImgIcon(obj, "", spriteName, res)
end
local function setImgIcon(obj, path, spriteName, res)
  local sprite = obj:GetComponent("UISprite")
  local function _callback(atlas)
    if atlas and obj and not obj.isnil then
      local sprite = obj:GetComponent("UISprite")
      sprite.atlas = nil
      sprite.atlas = atlas
      sprite.spriteName = spriteName
    end
  end
  if string.len(path) == 0 then
    spriteName = spriteName or "Grid"
    res = res or RESPATH.InventoryAtlas
    AtlasMan.Instance():GetAtlas(res, _callback)
  else
    spriteName = spriteName or "Sprite"
    ECGUITools.UpdateGridImage(path, obj, _callback)
  end
end
local setSprite = function(obj, spriteName)
  spriteName = spriteName or "Sprite"
  obj:GetComponent("UISprite").spriteName = spriteName
end
local setVisible = function(obj, visible)
  obj:SetActive(visible)
end
local setEnable = function(obj, enable)
  local uibutton = obj:GetComponent("UIButton")
  if uibutton then
    uibutton.isEnabled = enable
  else
    if obj.collider.enabled == enable then
      return
    end
    obj.collider.enabled = enable
  end
end
local setTween = function(obj, val, duration)
  duration = duration or 0
  TweenAlpha.Begin(obj, duration, val)
end
local setToggle = function(obj, boolean_)
  obj:GetComponent("UIToggle").value = boolean_
end
local setSlider = function(obj, value)
  obj:GetComponent("UISlider").value = value
end
local function UpdateGridImage(imagepath, obj, cb)
  ECGUITools.UpdateGridImageInner(imagepath, obj, cb)
end
local function SetInputString(panelName, text, index)
  index = index or 1
  local panel = ECGUIMan.Instance():FindPanelByName(panelName)
  if not panel then
    warn("No Panel")
    return
  end
  local configs = l_allConfigs[panelName][index]
  if not configs then
    warn(index, "No Input Configs", panelName)
    return
  end
  if not configs.txtComponent then
    warn("No Input txtComponentGO")
    return
  end
  local inputGO = panel.m_panel:FindChild(configs.txtComponent)
  local numberGO
  if configs.numComponent then
    numberGO = panel.m_panel:FindChild(configs.numComponent)
  end
  if not inputGO then
    warn(panelName, "\230\178\161\230\156\137\230\137\190\229\136\176\232\190\147\229\133\165\230\161\134")
    return ""
  end
  local inputCP = inputGO:FindChild("Label"):GetComponent("UILabel")
  if inputCP and configs then
    local maxLen = configs.maxLen
    local _, aNum, hNum = ECLuaString.Len(text)
    local inputLen = math.floor(aNum / 3) + hNum
    local num = maxLen - inputLen
    if num <= 0 then
      num = 0
      inputGO:GetComponent("UIInput").isFull = true
      inputGO:GetComponent("UIInput").characterLimit = maxLen
    else
      inputGO:GetComponent("UIInput").isFull = false
      inputGO:GetComponent("UIInput").characterLimit = 0
    end
    if numberGO then
      local numberCP = numberGO:GetComponent("UILabel")
      if numberCP then
        numberCP.text = tostring(num)
      end
    end
    return inputCP.text
  else
    warn("Bad Augrment:", panelName, configs)
    return ""
  end
end
def.const("function").setFontSizeAndStyle = setFontSizeAndStyle
def.const("function").setTextAndColor = setTextAndColor
def.const("function").setTextAndColor2 = setTextAndColor2
def.const("function").setTextAndColor3 = setTextAndColor3
def.const("function").setDefaultIcon = setDefaultIcon
def.const("function").setImgIcon = setImgIcon
def.const("function").setSprite = setSprite
def.const("function").setEnable = setEnable
def.const("function").setVisible = setVisible
def.const("function").setTween = setTween
def.const("function").setToggle = setToggle
def.const("function").setSlider = setSlider
def.const("function").UpdateGridImage = UpdateGridImage
def.const("function").SetInputString = SetInputString
ECGUITools.Commit()
return ECGUITools
