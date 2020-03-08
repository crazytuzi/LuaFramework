local Lplus = require("Lplus")
local raw_data = dofile("Configs/pate_fx_status.lua")
local ECObject = Lplus.ForwardDeclare("ECObject")
require("Common.ECNetDef")
local PateFxStatus = Lplus.Class("PateFxStatus")
do
  local def = PateFxStatus.define
  def.static(ECObject, "=>", "table").GetFxList = function(obj)
    local fxArr = {}
    local priorityArr = {}
    PateFxStatus.fillGfxStateFx(obj, fxArr, priorityArr)
    assert(#fxArr == #priorityArr)
    local indexArr = {}
    for i = 1, #fxArr do
      indexArr[i] = i
    end
    table.sort(indexArr, function(iLeft, iRight)
      return priorityArr[iLeft] > priorityArr[iRight]
    end)
    local result = priorityArr
    for i = 1, #fxArr do
      local index = indexArr[i]
      local pathId = fxArr[index]
      result[i] = datapath.GetPathByID(pathId)
    end
    return result
  end
  def.static(ECObject, "table", "table").fillGfxStateFx = function(obj, fxArr, priorityArr)
    local gfxState_configs = raw_data.gfxState
    local gfxState = obj.GfxState
    local gfxStateParams = obj.GfxStateParams
    local GFX_STATE_PARAMS_COUNT = GP_MISC.GFX_STATE_PARAMS_COUNT
    local high_bits, low_bits = LuaUInt64.GetHighAndLow(gfxState)
    for gfx_id = 64 - GFX_STATE_PARAMS_COUNT, 63 do
      local stateBit = bit.lshift(1, gfx_id - 32)
      local bHasState = bit.band(high_bits, stateBit) ~= 0
      if bHasState then
        local f = gfxState_configs[gfx_id]
        if f then
          local paramIndex = gfx_id - (64 - GFX_STATE_PARAMS_COUNT) + 1
          local param = gfxStateParams[paramIndex] or 0
          local fx_path, priority = f(param)
          if fx_path then
            fxArr[#fxArr + 1] = fx_path
            priorityArr[#priorityArr + 1] = priority
          end
        end
      end
    end
  end
end
return PateFxStatus.Commit()
