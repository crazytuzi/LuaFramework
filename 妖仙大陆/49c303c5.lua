local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local TERQ = require 'Zeus.Model.guildTech'

local self = {
    menu = nil,
}

local retAttrs = GlobalHooks.DB.Find("Attribute", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function OnEnter()
  
end

local function OnExit()
  
end

local function GetAttrsStr(data)
  local attrStr = ""
  if data then
      local castr = retAttrs[data.id].attName
      attrStr = "<b size='22'>"..castr..":".." <f color='ff00d600'>".."+"..data.value.."</f></b>"
  end
  return attrStr
end

function _M.SetAttr(data)
  local curCount = #data.currentAttrs
  local nexCount = #data.nextAttrs
  for i=1,5 do
    self.curList[i].Visible = i <= curCount
    self.NexList[i].Visible = i <= nexCount
    if i <= curCount then
      self.curList[i].XmlText = GetAttrsStr(data.currentAttrs[i])
    end
    if i <= nexCount then
      self.NexList[i].XmlText = GetAttrsStr(data.nextAttrs[i])
    end
  end

  self.tb_determine.XmlText = string.format(GetTextConfg("guild_Tech_IsUpBUFF1"),data.needFund,data.level+1)
end

local function initUI()
  self.btn_determine.TouchClick = function ()
    TERQ.upgradeGuildBuffRequest(function ()
      EventManager.Fire('Guild.TechUpLevel',{type = 2})
      self.menu:Close()
    end)
  end

  self.curList = {}
  self.NexList = {}
  for i=1,5 do
    self.curList[i] = self.cvs_now:FindChildByEditName("tb_attribute"..i,true)
    self.NexList[i] = self.cvs_next:FindChildByEditName("tb_attribute"..i,true)
  end
end

local ui_names = 
{
  
  {name = 'cvs_now'},
  {name = 'cvs_next'},
  {name = 'btn_determine'},
  {name = 'tb_determine'},
}

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    self.menu:Close()
  end
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_kejiup1.gui.xml", GlobalHooks.UITAG.GameUIGuildTechBuffUpLv)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  InitCompnent()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)
  return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}
