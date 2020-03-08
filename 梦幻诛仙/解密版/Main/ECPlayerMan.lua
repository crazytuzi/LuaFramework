local Lplus = require("Lplus")
local ECManager = require("Main.ECManager")
local player_definite_info_data = require("S2C.player_definite_info_data")
local ECElsePlayer = require("Players.ECElsePlayer")
local ECPanelMapRadar = require("GUI.ECPanelMapRadar")
local ECPanelMidmap = require("GUI.ECPanelMidmap")
local pb_helper = require("PB.pb_helper")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECObject = require("Object.ECObject")
local ECFxMan = require("Fx.ECFxMan")
local ECPlayerMan = Lplus.Extend(ECManager, "ECPlayerMan")
local def = ECPlayerMan.define
_G.max_player_loaded_per_frame = 0
def.field("userdata").PlayerRoot = nil
def.field("number").m_UpdateInterval = 0
def.field("boolean").m_ShowElsePlayers = true
def.field("string").OldTargetID = ZeroUInt64
def.final("=>", ECPlayerMan).new = function()
  local obj = ECPlayerMan()
  obj:Init(ECManager.EC_MAN_ENUM.MAN_PLAYER)
  obj.PlayerRoot = GameObject.GameObject("Players")
  return obj
end
local BUFF_BROADCAST_GFX_BIT = LuaUInt64.Make(2147483648, 0)
def.method(player_definite_info_data, "boolean").CreateElsePlayer = function(self, info, bBornInSight)
  local player = ECElsePlayer.new()
  player:Init(info)
  if LuaUInt64.And(player.GfxState, BUFF_BROADCAST_GFX_BIT) == BUFF_BROADCAST_GFX_BIT then
    local cmd = pb_helper.NewCmd("gp_get_broadcast_buff")
    cmd.object_id = player.ID
    pb_helper.Send(cmd)
  end
  self.m_ObjMap[info.id] = player
end
def.override("boolean").Release = function(self, bReleaseScene)
  self.OldTargetID = ZeroUInt64
  ECManager.Release(self, bReleaseScene)
  if bReleaseScene then
    Object.Destroy(self.PlayerRoot)
    self.PlayerRoot = nil
  end
end
def.method().UpdateRadarMarks = function(self)
  local inst = ECPanelMapRadar.Instance()
  if not inst.MapIsShow then
    return
  end
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    if v.m_bReady then
      local m = v.m_RootObj
      local pos = m.position
      inst:UpdateElseMark(k, pos.x, pos.z, v.m_RadarVisible)
    end
  end
end
def.method().UpdateMidmapMarks = function(self)
  local inst = ECPanelMidmap.Instance()
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    local m = v.m_RootObj
    if m then
      local pos = m.position
      inst:UpdateElseMark(k, pos.x, pos.z)
    end
  end
end
def.method().UpdateWarStatus = function(self)
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    if v then
      v:UpdateWarStatus()
    end
  end
end
def.method().LeaveWarStatus = function(self)
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    if v then
      v:LeaveWarStatus()
    end
  end
end
def.method().Update = function(self)
  local ls = self:SortByDistToHost()
  if self.m_UpdateInterval == 1 then
    self.m_UpdateInterval = 0
    self:UpdateVisible(ls)
  else
    self.m_UpdateInterval = 1
  end
end
local rand = math.random
def.method("table").UpdateVisible = function(self, ls)
  local count = #ls
  if count == 0 then
    return
  end
  local hp = ECGame.Instance().m_HostPlayer
  local objmap = self.m_ObjMap
  local oldtarid = self.OldTargetID
  local targetid = hp.TargetID
  self.OldTargetID = targetid
  local target
  if targetid ~= ZeroUInt64 then
    target = objmap[targetid]
  else
    target = nil
  end
  if not self.m_ShowElsePlayers then
    if target then
      target:SetCullingVisible(true, false)
    end
    if oldtarid ~= targetid and oldtarid ~= ZeroUInt64 then
      local oldtar = objmap[oldtarid]
      if oldtar then
        oldtar:SetCullingVisible(false, false)
      end
    end
    return
  end
  local far_dist_count = 0
  for i = max_visible_player_inner + 1, count do
    local v = ls[i]
    if v.m_FarDistToHost then
      far_dist_count = far_dist_count + 1
    end
  end
  local left_count = count - max_visible_player_inner
  local new_count = max_visible_player_outer - far_dist_count
  local shuffle_count = 0
  if new_count > 0 and left_count > max_visible_player_outer then
    for i = 1, max_visible_player_outer do
      local start = max_visible_player_inner + i
      local v = ls[start]
      local rd = rand(start, count)
      local ve = ls[rd]
      ls[start] = ve
      ls[rd] = v
      if not ve.m_FarDistToHost then
        shuffle_count = shuffle_count + 1
        if new_count <= shuffle_count then
          break
        end
      end
    end
  end
  local war_status = ECFxMan.Instance().IsInNationWar
  local selfnation = hp.InfoData.Nation
  local cur_time = Time.time
  far_dist_count = 0
  local vcount = 0
  local radarcount = 0
  for i = 1, count do
    local v = ls[i]
    if not v.m_ModelHidden then
      if v == target then
        v:SetCullingVisible(true, false)
        v.m_RadarVisible = true
      else
        local forcehide = false
        if war_status then
          if selfnation == v.InfoData.Nation then
            if not show_nationwar_friend_player then
              forcehide = true
            end
          elseif not show_nationwar_enemy_player then
            forcehide = true
          end
        end
        if vcount <= max_visible_player_inner then
          if v.m_FarDistToHost then
            v.m_FarDistProtectTime = cur_time
            v.m_FarDistToHost = false
            if not forcehide then
              if v.m_HideMode then
                v:ResumeFromHideMode()
              else
                v:ChangeSimpleModel(false, false)
              end
            end
          end
          v:SetCullingVisible(not forcehide, false)
          vcount = vcount + 1
          if radarcount < max_visible_radar then
            radarcount = radarcount + 1
            v.m_RadarVisible = true
          else
            v.m_RadarVisible = false
          end
        elseif not v.m_FarDistToHost then
          if new_count > far_dist_count then
            v.m_FarDistToHost = true
            if forcehide then
              v:SetCullingVisible(false, false)
            else
              v:ChangeSimpleModel(true, false)
              v:SetCullingVisible(true, false)
            end
            far_dist_count = far_dist_count + 1
          elseif v.m_FarDistProtectTime ~= 0 then
            if cur_time > v.m_FarDistProtectTime + 5 then
              v:SetCullingVisible(false, false)
              v.m_FarDistProtectTime = 0
            end
          else
            v:SetCullingVisible(false, false)
          end
        else
          v:SetCullingVisible(not forcehide, false)
        end
      end
    end
  end
end
def.method("boolean").DisplayElsePlayers = function(self, show)
  self.m_ShowElsePlayers = show
  if not show then
    local hp = ECGame.Instance().m_HostPlayer
    local objmap = self.m_ObjMap
    local target = hp.TargetID
    if target ~= ZeroUInt64 then
      target = objmap[target]
    else
      target = nil
    end
    for k, v in pairs(objmap) do
      if v ~= target then
        v:SetCullingVisible(false, false)
      end
    end
  end
end
def.override("string", "boolean").OnCmd_ObjectLeaveScene = function(self, id, outofsight)
  local v = self.m_ObjMap[id]
  if v then
    v:LeaveWarStatus()
  end
  ECManager.OnCmd_ObjectLeaveScene(self, id, outofsight)
  ECPanelMapRadar.Instance():RemoveElseMark(id)
  ECPanelMidmap.Instance():RemoveElseMark(id)
end
def.method("string", "=>", ECElsePlayer).GetElsePlayer = function(self, id)
  return self.m_ObjMap[id]
end
ECPlayerMan.Commit()
return ECPlayerMan
