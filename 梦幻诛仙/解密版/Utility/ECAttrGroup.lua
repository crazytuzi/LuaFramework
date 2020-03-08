local Lplus = require("Lplus")
local ElementData = require("Data.ElementData")
local Exptypes = require("Data.Exptypes")
local Expdef = require("Data.Expdef")
local MISC = Expdef.MISCELLANEOUS
local ECAttrGroup = Lplus.Class("ECAttrGroup")
do
  local def = ECAttrGroup.define
  def.static("number", "number", "number", "=>", "number").GetRandValue = function(rand, low, hight)
    local value = rand * (hight - low + 0.999999)
    value = math.floor(value / 100)
    return value + low
  end
  def.static("number", "=>", "table").FillAddon = function(id)
    local pAddon = ElementData.getAddon(id)
    if not pAddon then
      warn("can not open addon with id:" .. id)
      return nil
    end
    local data = {}
    data.name = pAddon.name
    data.type = pAddon.type
    data.param1 = pAddon.param1
    data.param2 = pAddon.param2
    data.param3 = pAddon.param3
    data.num = pAddon.num_params
    data.quality = pAddon.quality
    data.rand = pAddon.param1
    return data
  end
  def.static("table", "table").FillBaseAddon = function(pGroup, AddonList)
    for i = 1, MISC.EXP_ADDONGRP_BASIC_COUNT do
      local id = pGroup.id_basic_addon[i]
      if id > 0 then
      end
    end
  end
  def.static("table", "table").FillAppendAddon = function(pGroup, AddonList)
    for i = 1, MISC.EXP_ADDON_GROUP_ADDON_COUNT do
      local id = pGroup.addons[i].id
      local odds = pGroup.addons[i].odds
      if id > 0 then
        local data = ECAttrGroup.FillAddon(id)
        if data then
          table.insert(AddonList, data)
        end
      end
    end
  end
  def.static("table", "table").FillRandAddon = function(pGroup, AddonList)
    for i = 1, MISC.EXP_ADDONGRP_GEN_COUNT + 1 do
      local id = pGroup.gen_random_bycount_odds[i]
      if id > 0 then
      end
    end
  end
  def.static("table", "table").FillSkillAddon = function(pGroup, AddonList)
    for i = 1, MISC.EXP_ADDONGRP_SKILLPROP_COUNT + 1 do
      local id = pGroup.skillprops[i].id
      if id > 0 then
      end
    end
  end
  def.static("number", "table").FillAddonList = function(groupid, AddonList)
    local pGroup = ElementData.getAddonGroup(groupid)
    if not pGroup then
      warn("can not open addon group with id:" .. groupid)
      return
    end
    ECAttrGroup.FillBaseAddon(pGroup, AddonList)
    ECAttrGroup.FillRandAddon(pGroup, AddonList)
    ECAttrGroup.FillAppendAddon(pGroup, AddonList)
    ECAttrGroup.FillSkillAddon(pGroup, AddonList)
  end
  def.static("table", "=>", "table", "number").UniqueAddonForType = function(AddonList)
    local addonCount = #AddonList
    local addonList = {}
    local count = 0
    for i = 1, addonCount do
      local data = AddonList[i]
      local val = addonList[data.type]
      if not val then
        addonList[data.type] = {
          rand = data.rand,
          quality = data.quality
        }
        count = count + 1
      else
        addonList[data.type].rand = addonList[data.type].rand + data.rand
      end
    end
    return addonList, count
  end
end
return ECAttrGroup.Commit()
