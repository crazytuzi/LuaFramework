local Lplus = require("Lplus")
local ECObject = require("Object.ECObject")
local EC = require("Types.Vector3")
local ECGame = Lplus.ForwardDeclare("ECGame")
local AtlasMan = require("GUI.AtlasMan")
local HUDMan = Lplus.Class("HUDMan")
local def = HUDMan.define
local HudFntCfg = {
  EXP = {
    RESPATH.FntExp,
    "ExpFont"
  },
  MONEY = {
    RESPATH.FntMoney,
    "MoneyFont"
  },
  HP_REDUCE = {
    RESPATH.FntReduce,
    "HPSubFont"
  },
  HP_RESTORE = {
    RESPATH.FntRestore,
    "HPAddFont"
  },
  DAMAGE = {
    RESPATH.FntDamage,
    "DamageFont"
  },
  CRIT = {
    RESPATH.FntCrit,
    "CritFont"
  },
  CREDIT = {
    RESPATH.FntCredit,
    "CreditFont"
  },
  PENETRATE = {
    RESPATH.FntPenetrate,
    "PenetrateFont"
  },
  WITHSTAND = {
    RESPATH.FntWithstand,
    "WithstandFont"
  }
}
def.static().PreloadHudFnts = function()
end
def.static("number", "function").ShowHostNewGetExp = function(num, cb)
  local hp = ECGame.Instance().m_HostPlayer
  if not hp.m_bReady then
    return
  end
  local fontName = HudFntCfg.EXP[2]
  local text = "A" .. tostring(num)
  local font_size = 20
  local lifeTime = 1
  local velocity = EC.Vector3.new(0, 100, 0)
  local useGravity = false
  local canOverlapped = false
  GameUtil.SetHudText(hp.m_RootObj, text, fontName, font_size, lifeTime, velocity, useGravity, canOverlapped)
end
local TranslateMoneyToHUDString = function(money)
  if money < 0 then
    return ""
  end
  local desc = ""
  local d = math.floor(money / 1000000)
  local l = math.floor(math.fmod(money, 1000000) / 1000)
  local w = math.fmod(money, 1000)
  if d > 0 then
    desc = desc .. tostring(d) .. "D"
  end
  if l > 0 then
    desc = desc .. tostring(l) .. "L"
  end
  if w > 0 then
    desc = desc .. tostring(w) .. "W"
  end
  return desc
end
def.static("boolean", "number", "function").ShowHostNewGetMoney = function(bind, num, cb)
  local hp = ECGame.Instance().m_HostPlayer
  if not hp.m_bReady then
    return
  end
  local prefix = "B"
  if bind then
    prefix = "A"
  end
  local fontName = HudFntCfg.MONEY[2]
  local text = prefix .. TranslateMoneyToHUDString(num)
  local font_size = 22
  local lifeTime = 1
  local velocity = EC.Vector3.new(0, 100, 0)
  local useGravity = false
  local canOverlapped = false
  GameUtil.SetHudText(hp.m_RootObj, text, fontName, font_size, lifeTime, velocity, useGravity, canOverlapped)
end
def.static("number").ShowHostHPChange = function(num)
  local hp = ECGame.Instance().m_HostPlayer
  if not hp.m_bReady then
    return
  end
  local fontName = HudFntCfg.HP_RESTORE[2]
  local canOverlapped = num < 0
  if num < 0 then
    fontName = HudFntCfg.HP_REDUCE[2]
    num = -num
  end
  local text = tostring(num)
  local font_size = 18
  local velocity = EC.Vector3.new(0, 100, 0)
  local useGravity = false
  local lifeTime = 1
  GameUtil.SetHudText(hp.m_RootObj, text, fontName, font_size, lifeTime, velocity, useGravity, canOverlapped)
end
local repu_hud_cfg = {
  [REPUID.NATION_WAR] = HudFntCfg.CREDIT[2]
}
def.static("number", "number").ShowHostRepuChange = function(repu_id, num)
  local hp = ECGame.Instance().m_HostPlayer
  if not hp.m_bReady then
    return
  end
  local fontName = repu_hud_cfg[repu_id]
  if fontName == nil then
    return
  end
  local text = "A" .. tostring(num)
  local font_size = 18
  local velocity = EC.Vector3.new(0, 100, 0)
  local useGravity = false
  local lifeTime = 1
  local canOverlapped = true
  GameUtil.SetHudText(hp.m_RootObj, text, fontName, font_size, lifeTime, velocity, useGravity, canOverlapped)
end
def.static("string", "number", "boolean", "boolean", "boolean").ShowTargetDamage = function(target_id, num, is_crit, is_parry, is_broken_parry)
  local world = ECGame.Instance().m_CurWorld
  local target = world:FindObject(target_id)
  if target == nil or not target.m_bReady then
    return
  end
  local fontName = HudFntCfg.DAMAGE[2]
  if is_crit then
    fontName = HudFntCfg.CRIT[2]
  end
  if is_broken_parry then
    fontName = HudFntCfg.PENETRATE[2]
  end
  if is_parry then
    fontName = HudFntCfg.WITHSTAND[2]
  end
  local text = tostring(num)
  local font_size = 18
  if is_crit then
    text = "A" .. tostring(num)
    font_size = 24
  end
  if is_broken_parry then
    text = "A" .. tostring(num)
    font_size = 24
  end
  if is_parry then
    text = "A" .. tostring(num)
    font_size = 24
  end
  local velocity = EC.Vector3.new(math.random(-150, 150), 100, 0)
  local useGravity = true
  local lifeTime = 1
  local canOverlapped = true
  GameUtil.SetHudText(target.m_RootObj, text, fontName, font_size, lifeTime, velocity, useGravity, canOverlapped)
end
def.static("number").ShowReciveScore = function(num)
  local hp = ECGame.Instance().m_HostPlayer
  if not hp.m_bReady then
    return
  end
  local fontName = HudFntCfg.HP_RESTORE[2]
  local text = "+" .. tostring(num)
  local font_size = 24
  local velocity = EC.Vector3.new(0, 100, 0)
  local useGravity = false
  local lifeTime = 1
  local canOverlapped = false
  GameUtil.SetHudText(hp.m_RootObj, text, fontName, font_size, lifeTime, velocity, useGravity, canOverlapped)
end
HUDMan.Commit()
_G.HUDMan = HUDMan
return HUDMan
