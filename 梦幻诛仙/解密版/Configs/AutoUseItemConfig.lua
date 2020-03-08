local Lplus = require("Lplus")
local ECIvtrItems = require("Inventory.ECIvtrItems")
local config_data = dofile("Configs/auto_use_item.lua")
local l_forse_auto_use_item_map = {}
for _, tid in ipairs(config_data.force_auto_use_items) do
  l_forse_auto_use_item_map[tid] = true
end
local l_force_prompt_items = {}
for _, tid in ipairs(config_data.force_prompt_items) do
  l_force_prompt_items[tid] = true
end
local l_forbid_prompt_items = {}
for _, tid in ipairs(config_data.forbid_prompt_items) do
  l_forbid_prompt_items[tid] = true
end
local AutoUseItemConfig = Lplus.Class("AutoUseItemConfig")
do
  local def = AutoUseItemConfig.define
  def.static(ECIvtrItems.ECIvtrItem, "=>", "boolean").CanForceAutoUseItem = function(item)
    if not item:GetBindState() then
      return false
    end
    if not l_forse_auto_use_item_map[item.tid] then
      return false
    end
    return true
  end
  def.static(ECIvtrItems.ECIvtrItem, "=>", "boolean").IsForcePromptAutoUseItem = function(item)
    return not not l_force_prompt_items[item.tid]
  end
  def.static(ECIvtrItems.ECIvtrItem, "=>", "boolean").CanPromptAutoUseItem = function(item)
    if l_forbid_prompt_items[item.tid] then
      return false
    end
    local ECGame = require("Main.ECGame")
    local hostLevel = ECGame.Instance().m_HostPlayer.InfoData.Lv
    return hostLevel >= config_data.prompt_auto_use_min_level and hostLevel <= config_data.prompt_auto_use_max_level
  end
end
return AutoUseItemConfig.Commit()
