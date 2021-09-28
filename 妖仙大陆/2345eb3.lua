
local _M = {}
_M.__index = _M

local cjson = require "cjson"
local helper = require "Zeus.Logic.Helper"
local bit = require "bit"

local skillData = {}  
local skillDetail = {}  

_M.SkillChangeCallback = {
  skillChangeCb = {},
  SPChangeCb = {},
  ShortcutCb = {}
}

function _M.DescFormat(str, params)
  local cfgStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "detail_font")
  for i=1,#params do
    local value = string.format('%.2f', params[i])
    local replaceStr = string.format(cfgStr, value)
    
    str = string.gsub(str,'<$'..i..'>', replaceStr)
  end
  return str
end

function _M.Notify(status, userdata)
  
  
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
  

  if userdata:ContainsKey(status, UserData.NotiFyStatus.SP) then
    for key,val in pairs(_M.SkillChangeCallback.SPChangeCb) do
      val(userdata:TryToGetIntAttribute(UserData.NotiFyStatus.SP, 0))
    end
  end
  if userdata:ContainsKey(status, UserData.NotiFyStatus.SKILLKEY) then
    for key,val in pairs(_M.SkillChangeCallback.ShortcutCb) do
      val()
    end
  end
end

function _M.RemoveShortcutListener(key)
  _M.SkillChangeCallback.ShortcutCb[key] = nil
end

function _M.AddShortcutListener(key, cb)
  _M.SkillChangeCallback.ShortcutCb[key] = cb
end

function _M.RemoveSPChangeListener(key)
  _M.SkillChangeCallback.SPChangeCb[key] = nil
end

function _M.AddSPChangeListener(key, cb)
  _M.SkillChangeCallback.SPChangeCb[key] = cb
end

function _M.RemoveSkillChangeListener(key)
  _M.SkillChangeCallback.skillChangeCb[key] = nil
end

function _M.AddSkillChangeListener(key, cb)
  _M.SkillChangeCallback.skillChangeCb[key] = cb
end

function _M.CanShortcut()
  return skillData.canShortcut
  
end

function _M.GetShortcut()
  local shortcut = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.SKILLKEY)
  return shortcut
end

function _M.GetUserAtb(status, default)
  default = default == nil and 0 or default
  return DataMgr.Instance.UserData:TryToGetIntAttribute(status, default)
end

function _M.UnlockSkill( skillId, cb )
  Pomelo.SkillHandler.unlockSkillRequest(skillId, function( ex, sjson )
    
    
    if ex == nil then
      
      
      cb()
    end
  end, nil)
end

function _M.RequestSaveShortcut(savedata)
  Pomelo.SkillKeysHandler.saveSkillKeysRequest(savedata, function( ex, sjson )
    
  end, nil)
end

function _M.UpgradeSkill( skillId, cb )
  Pomelo.SkillHandler.upgradeSkillRequest(skillId, function( ex, sjson )
    
    
    if ex == nil then
      
      
      cb()
    end
  end, nil)
end

function _M.UpgradeSkillOneKey( cb )
  Pomelo.SkillHandler.upgradeSkillOneKeyRequest(function( ex, sjson )


    if ex == nil then
      local param = sjson:ToData()
      skillData.skills.skillList = param.skillList
      if cb ~= nil then
        cb(skillData.skills.skillList)
      end
    end
  end, nil)
  return skillData.skills.skillList
end


function _M.GetSkillDetail(skill, isForceReq, cb)
  
  if not isForceReq and skillDetail[skill.skillId] ~= nil then 
      
      
      if skill.detailNeedRefresh == false then  
          if cb ~= nil then
            cb(skillDetail[skill.skillId])
          end
          return
      end
  end

  
  Pomelo.SkillHandler.getSkillDetailRequest(skill.skillId, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      local data = param.s2c_skill
      
      
      
      
      skillDetail[skill.skillId] = data
      skill.detailNeedRefresh = false
      
      if cb ~= nil then
        cb(data)
      end
    end
  end, nil)
end

function _M.GetSkillList(cb, timeoutcb)
  






  Pomelo.SkillHandler.getAllSkillRequest(function( ex, sjson )
    
    if ex == nil then
      
      local param = sjson:ToData()
      local skills = param
      skillData.skills = skills
      skillData.canShortcut = param.hubLock
      if cb ~= nil then
        cb(skillData.skills)
      end
    end
  end, XmdsNetManage.PackExtData.New(true, true, timeoutcb))

  return skillData.skills
end

local function UpdateSkill(oldT, newT)
  for key,val in pairs(newT) do
    oldT[key] = val
  end
end

local function ConvertValue(t)
  local ret = {}
  for i=1, #t do
    local key = t[i].key
    local value = t[i].value
    if t[i].type == 1 then  
      value = tonumber(t[i].value)
    end
    ret[key] = value
  end
  return ret
end

function GlobalHooks.DynamicPushs.OnSkillUpdatePush(ex, json)
  
  

  if skillData.skills == nil then
    return
  end

  if ex == nil then
    local param = json:ToData()
    local skills = param.s2c_data
    skillData.canShortcut = param.hubLock
    if skills ~= nil then
      for i=1,#skills do
        local skillNew = skills[i]
        local skills = skillData.skills.skillList
        for _,skill in pairs(skillData.skills.skillList) do
          if skill.skillId == skillNew.skillId then
            UpdateSkill(skill, skillNew)
            for _,val in pairs(_M.SkillChangeCallback.skillChangeCb) do
              val(skill)
            end
            break
          end
        end
      end
    end
  end
end

function _M.initial()
  
  DataMgr.Instance.UserData:AttachLuaObserver(GlobalHooks.UITAG.GameUISkillMain, _M)
end

function _M.fin()
  
  DataMgr.Instance.UserData:DetachLuaObserver(GlobalHooks.UITAG.GameUISkillMain)
end

function _M.InitNetWork()
  
  
  Pomelo.GameSocket.skillUpdatePush(GlobalHooks.DynamicPushs.OnSkillUpdatePush)
end

return _M
