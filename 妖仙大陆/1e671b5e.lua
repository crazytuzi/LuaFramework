



local _M = {}
_M.__index = _M

local Helper = require"Zeus.Logic.Helper"
local cjson = require"cjson"
local Player = require"Zeus.Model.Player"

local data = {}

local function GetData(index)
  print("GetData", index)
  for _, p in pairs(data) do
    if p.pos == index then
      return p
    end
  end
end

local function GetAllData()
  print("GetAllData")
  return data
end

    
        
        
        
        
        
        
        
        
    

_M.GetAllSlot = function()
  local all = DataMgr.Instance.UserData.RoleEquipBag.AllData
  local t = {}
  local iter = all:GetEnumerator()
  while iter:MoveNext() do
    local data = iter.Current
    t[data.Key] = data.Value
  end
  return t
end

_M.IsCanUp = function(part)
   local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
   if part.level >= lv then
     return false
   end
   if part.level >= 100 then
     return false
   end
   if part.quality < part.upgradeLimitQuality then
     return false
   end
   return true
end

local function Upgrade(pos, cb)
  Pomelo.MasteryHandler.upgradeRequest(pos, function(ex,sjson)
    print("Upgrade")
    if not ex then
      local param = sjson:ToData()
      
      cb()
    end
  end)
end

local function UpQuality(pos, cb)
  Pomelo.MasteryHandler.upqualityRequest(pos, function(ex,sjson)
    print("Upgrade")
    if not ex then
      local param = sjson:ToData()
      
      cb()
    end
  end)
end

function GlobalHooks.DynamicPushs.OnMasteryDynamicPush(ex, json)
    print("---------OnMasteryDynamicPush------------",type(ex), "===", json)
    if not ex then
      print(json)
      local old, new
      local t = json:ToData()
      
      local parts = t.s2c_data
      for _, p in pairs(parts) do
        for i, org in pairs(data) do
          if org.pos == p.pos then
            old = org
            data[i] = p
            new = p
            break
          end
        end
        table.insert(data, p)
        new = p
      end
      local param = {old = old, new = new}
      EventManager.Fire("Event.UI.ShowAffectResult", {param = cjson.encode(param)})
end
end

function _M.InitNetWork()
  
  
end

function _M.initial()
  print("Affect initial") 
  
	
  
  
  
  
  
  
  data = Player.GetBindPlayerData().masterys
end

_M.GetData = GetData
_M.UpQuality = UpQuality
_M.Upgrade = Upgrade
_M.GetAllData = GetAllData
return _M
