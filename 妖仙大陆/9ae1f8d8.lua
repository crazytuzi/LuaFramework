local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"


local self = {
    menu = nil,
}

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function OnEnter()
  self.myGuildMsg = GDRQ.GetMyGuildInfo()
  self.IsChangeLvOrMode = false

  local ulv = self.myGuildMsg.baseInfo.entryUpLevel
  local lv = self.myGuildMsg.baseInfo.entryLevel

  for k,v in pairs(self.retCond) do
    if ulv==0 then
      if tonumber(v.RoleLevel) == lv then
        self.factorLv = v.LevelID
        break
      end
    else
      if tonumber(v.UpLevel) == ulv then
        self.factorLv = v.LevelID
        break
      end
    end
  end

  self.lb_lv.Text = self.retCond[self.factorLv].Condition
  self.lb_lv.FontColorRGBA = Util.GetQualityColorRGBA(self.retCond[self.factorLv].Qcolor)

  local slectTog = self.tbt_left
  local str = GetTextConfg("guild_Factor_need")
  if self.myGuildMsg.baseInfo.guildMode == 1 then
    slectTog = self.tbt_right
    str = GetTextConfg("guild_Factor_autoadd")
  end
  Util.InitMultiToggleButton(function (sender)
          self.togname = sender.EditName
          if not self.isinit then  
            self.isinit = true
          else
            self.IsChangeLvOrMode = true
          end
        end,slectTog,{self.tbt_left,self.tbt_right})
  local stringLv = ulv==0 and (self.lb_lv.Text..GetTextConfg("guild_Depot_lv")) or self.lb_lv.Text
  self.lb_now.Text = string.format(GetTextConfg("guild_Factor_curcondition"),stringLv,str)
end

local function OnExit()
  self.togname = nil
end

local function ModNum()
  local num = 2
  if self.togname then
    if self.togname == "tbt_right" then
      num = 1
    end
  else
    num = self.myGuildMsg.baseInfo.entryLevel
  end
  return num
end

local function initUI()
  self.retCond = GlobalHooks.DB.Find("GuildCondition", {})

  self.btn_left.TouchClick = function ()
    if self.factorLv>1 then
      self.factorLv = self.factorLv - 1
    else
      self.factorLv = #self.retCond
    end
    self.lb_lv.Text = self.retCond[self.factorLv].Condition
    self.lb_lv.FontColorRGBA = Util.GetQualityColorRGBA(self.retCond[self.factorLv].Qcolor)
    self.IsChangeLvOrMode = true
  end

  self.btn_right.TouchClick = function ()
    if self.factorLv < (#self.retCond) then
      self.factorLv = self.factorLv + 1
    else
      self.factorLv = 1
    end
    self.lb_lv.Text = self.retCond[self.factorLv].Condition
    self.lb_lv.FontColorRGBA = Util.GetQualityColorRGBA(self.retCond[self.factorLv].Qcolor)
    self.IsChangeLvOrMode = true
  end

  self.lb_lv.Text = self.retCond[1].Condition

  self.btn_yes.TouchClick = function ()
    if self.IsChangeLvOrMode then
      local modenum = tonumber(ModNum())
      
      GDRQ.setGuildInfoRequest(self.retCond[self.factorLv].RoleLevel,modenum,self.retCond[self.factorLv].UpLevel,function ()
        
      end)
    end
    self.menu:Close()
  end
end

local ui_names = 
{
  
  {name = 'btn_yes'},
  {name = 'tbt_left'},
  {name = 'tbt_right'},
  {name = 'btn_left'},
  {name = 'btn_right'},
  {name = 'lb_lv'},
  {name = 'lb_now'},
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
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_condition.gui.xml", GlobalHooks.UITAG.GameUIGuildFactor)
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
