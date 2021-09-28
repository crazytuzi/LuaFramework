local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local LeftRightNavExt = require "Zeus.Logic.LeftRightNavExt"
local GdDepotRq = require 'Zeus.Model.GuildDepot'

local self = {
    menu = nil,
}

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function GetCurUplvIndex(lv,uplv,retCond)
  if retCond then
    if uplv>0 then
      for k,v in pairs(retCond) do
        if uplv == v.UpLevel then
          return k
        end
      end
    else
      for k,v in pairs(retCond) do
        if lv == v.RoleLevel then
          return k
        end
      end
    end
    return 1
  end
  return 1
end

local function rushUI()
  local qColor1 = self.qualityIdxForm-1
  local qColor2 = self.qualityIdxTo-1
  self.qualityLv1:selectIdx(self.qualityIdxForm)
  self.lb_quality.Text = self.iconQualityAndColor[self.qualityIdxForm].qualityname
  self.lb_quality.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(self.iconQualityAndColor[self.qualityIdxForm].color))
  
  self.qualityLv2:selectIdx(self.qualityIdxTo)
  self.lb_quality1.Text = self.iconQualityAndColor[self.qualityIdxTo].qualityname
  self.lb_quality1.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(self.iconQualityAndColor[self.qualityIdxTo].color))

  self.lb_grade.Text = self.jobAndColor[self.FilterJob].jobname
  self.lb_grade.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(self.jobAndColor[self.FilterJob].color))

  for i=1,#self.FilterLvNode do
    if i==1 then
      self.FilterLvNode[i].Text = self.retCondOnlyRole[self.FilterLv[i].num].Condition
      self.FilterLvNode[i].FontColorRGBA = Util.GetQualityColorRGBA(self.retCondOnlyRole[self.FilterLv[i].num].Qcolor)
    else
      self.FilterLvNode[i].Text = self.retCond[self.FilterLv[i].num].Condition
      self.FilterLvNode[i].FontColorRGBA = Util.GetQualityColorRGBA(self.retCond[self.FilterLv[i].num].Qcolor)
    end
  end
end

local function OnEnter()
  self.AllCond = GdDepotRq.GetDepotInfo()
  if self.AllCond==nil then return end
  local conds = self.AllCond.depotCond
  
  self.qualityIdxForm = conds.minCond.qColor + 1 -2
  self.qualityIdxTo = conds.maxCond.qColor + 1 - 2
  local lvid1 = GetCurUplvIndex(conds.useCond.level,conds.useCond.upLevel,self.retCondOnlyRole)
  
  local lvid2 = GetCurUplvIndex(conds.minCond.level,conds.minCond.upLevel,self.retCond)
  
  local lvid3 = GetCurUplvIndex(conds.maxCond.level,conds.maxCond.upLevel,self.retCond)
  self.FilterLv = {{num = lvid1},{num = lvid2},{num = lvid3}}
  self.FilterJob = 6-conds.useCond.job
  rushUI()
end

local function OnExit()
  self.qualityIdxFormChange = false
  self.qualityIdxToChange = false
end

local function SetAllCond(sender)
  
  local lv1 = self.retCondOnlyRole[self.FilterLv[1].num].RoleLevel
  local uplv1 = self.retCondOnlyRole[self.FilterLv[1].num].UpLevel
  local lv2 = self.retCond[self.FilterLv[2].num].RoleLevel
  local uplv2 = self.retCond[self.FilterLv[2].num].UpLevel
  local lv3 = self.retCond[self.FilterLv[3].num].RoleLevel
  local uplv3 = self.retCond[self.FilterLv[3].num].UpLevel
  local qColor1 = self.qualityIdxForm-1+2
  local qColor2 = self.qualityIdxTo-1+2
  local c2s_condition = 
    {
      useCond = 
      {
        level = lv1,
        upLevel = uplv1,
        job = (6-self.FilterJob),
      },
      minCond = 
      {
        level = lv2,
        upLevel = uplv2,
        qColor1 = qColor1
      },
      maxCond = 
      {
        level = lv3,
        upLevel = uplv3,
        qColor2 = qColor2
      },
    }
    

  GdDepotRq.setConditionRequest(lv1,uplv1,(6-self.FilterJob),lv2,uplv2,qColor1,
    lv3,uplv3,qColor2,
    function ()
      self.menu:Close()
    end
  )
end

local function LvReduce(ttf,value)
  if value==3 then
    if self.FilterLv[3].num <= self.FilterLv[2].num then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Privilege_equipshort"))
      return
    elseif self.FilterLv[3].num - self.FilterLv[2].num == 1 and  self.qualityIdxForm >= self.qualityIdxTo then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Privilege_equipshort"))
      return
    end
  end
  if self.FilterLv[value].num>1 then
    self.FilterLv[value].num = self.FilterLv[value].num - 1
  else
    if value == 1 then
      self.FilterLv[value].num = #self.retCondOnlyRole
    end
  end
  if value == 1 then
    self.FilterLvNode[value].Text = self.retCondOnlyRole[self.FilterLv[value].num].Condition
    self.FilterLvNode[value].FontColorRGBA = Util.GetQualityColorRGBA(self.retCondOnlyRole[self.FilterLv[value].num].Qcolor)
  else
    self.FilterLvNode[value].Text = self.retCond[self.FilterLv[value].num].Condition
    self.FilterLvNode[value].FontColorRGBA = Util.GetQualityColorRGBA(self.retCond[self.FilterLv[value].num].Qcolor)
  end
end

local function LvAdd(ttf,value)
  if value == 2 then
    if self.FilterLv[3].num <= self.FilterLv[2].num+1 then
      if self.qualityIdxForm<#self.iconQualityAndColor then
        if self.qualityIdxForm>=self.qualityIdxTo then
          self.qualityIdxTo = self.qualityIdxForm + 1
          self.qualityLv2:selectIdx(self.qualityIdxTo)
          self.lb_quality1.Text = self.iconQualityAndColor[self.qualityIdxTo].qualityname
          self.lb_quality1.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(self.iconQualityAndColor[self.qualityIdxTo].color))
        end
      else
        if self.FilterLv[3].num < (#self.retCond) then
          self.FilterLv[3].num = self.FilterLv[3].num + 1 
          self.FilterLvNode[3].Text = self.retCond[self.FilterLv[3].num].Condition
          self.FilterLvNode[3].FontColorRGBA = Util.GetQualityColorRGBA(self.retCond[self.FilterLv[3].num].Qcolor)
        else
          GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Privilege_notchoose"))
          return
        end
      end
      if self.FilterLv[3].num < (#self.retCond) and self.FilterLv[3].num==self.FilterLv[2].num then
        self.FilterLv[3].num = self.FilterLv[3].num + 1 
        self.FilterLvNode[3].Text = self.retCond[self.FilterLv[3].num].Condition
        self.FilterLvNode[3].FontColorRGBA = Util.GetQualityColorRGBA(self.retCond[self.FilterLv[3].num].Qcolor)
      end
    end
  end

  if value == 1 then
    self.FilterLv[value].num = (self.FilterLv[value].num % #self.retCondOnlyRole) + 1
  elseif self.FilterLv[value].num < (#self.retCond) then
    self.FilterLv[value].num = self.FilterLv[value].num + 1
  end
  if value == 1 then
    self.FilterLvNode[value].Text = self.retCondOnlyRole[self.FilterLv[value].num].Condition
    self.FilterLvNode[value].FontColorRGBA = Util.GetQualityColorRGBA(self.retCondOnlyRole[self.FilterLv[value].num].Qcolor)
  else
    self.FilterLvNode[value].Text = self.retCond[self.FilterLv[value].num].Condition
    self.FilterLvNode[value].FontColorRGBA = Util.GetQualityColorRGBA(self.retCond[self.FilterLv[value].num].Qcolor)
  end
end

local function initUI()
  self.retCondOnlyRole = GlobalHooks.DB.Find("GuildCondition", {})
  self.retCond = GlobalHooks.DB.Find("WareHouseCondition", {})
  self.FilterLv = {{num = 1},{num = 1},{num = 1}}
  self.FilterLvNode = {self.lb_rank_number,self.lb_equip_level,self.cvs_equip_level1}
  self.btn_left.TouchClick = function () LvReduce(self.lb_rank_number,1) end
  self.btn_right.TouchClick = function () LvAdd(self.lb_rank_number,1) end

  self.btn_left2.TouchClick = function () LvReduce(self.lb_equip_level,2) end
  self.btn_right2.TouchClick = function () LvAdd(self.lb_equip_level,2) end

  self.btn_left4.TouchClick = function () LvReduce(self.cvs_equip_level1,3) end
  self.btn_right4.TouchClick = function () LvAdd(self.cvs_equip_level1,3) end

  local retjob = GlobalHooks.DB.Find("GuildPosition", {})
  self.jobAndColor = 
  {
    {color = 0,jobname = retjob[5].position},
    {color = 1,jobname = retjob[4].position},
    {color = 2,jobname = retjob[3].position},
    {color = 3,jobname = retjob[2].position},
    {color = 4,jobname = retjob[1].position},
  }
  self.FilterJob = 1
  self.btn_left1.TouchClick = function ()
    if self.FilterJob>1 then
      self.FilterJob = self.FilterJob - 1
    else
      self.FilterJob = #self.jobAndColor
    end
    self.lb_grade.Text = self.jobAndColor[self.FilterJob].jobname
    self.lb_grade.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(self.jobAndColor[self.FilterJob].color))
  end
  self.btn_right1.TouchClick = function ()
    if self.FilterJob<#self.jobAndColor then
      self.FilterJob = self.FilterJob + 1
    else
      self.FilterJob = 1
    end
    self.lb_grade.Text = self.jobAndColor[self.FilterJob].jobname
    self.lb_grade.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(self.jobAndColor[self.FilterJob].color))
  end

  local reticon = GlobalHooks.DB.Find("WareHouseCondition2", {})
  self.iconQualityAndColor = 
  {
    
    
    {color = 2,qualityname = reticon[1].ConditionName},
    {color = 3,qualityname = reticon[2].ConditionName},
    {color = 4,qualityname = reticon[3].ConditionName},
    {color = 5,qualityname = reticon[4].ConditionName},
  }
  self.qualityIdxForm = 1
  local function QualityChangeFromCallBack(idx, data)
    if self.FilterLv[2].num == self.FilterLv[3].num then
      if self.qualityIdxTo <= idx then
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Privilege_equipshort"))
        self.qualityLv1:selectIdx(self.qualityIdxForm)
        return
      end
    end
    self.qualityIdxFormChange = true
    self.qualityIdxForm = idx
    self.lb_quality.Text = self.iconQualityAndColor[self.qualityIdxForm].qualityname
    self.lb_quality.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(self.iconQualityAndColor[self.qualityIdxForm].color))
  end

  self.qualityLv1 = LeftRightNavExt.New(
        self.btn_left3,
        self.btn_right3,
        QualityChangeFromCallBack,
        self.iconQualityAndColor,
        false
    )

  self.qualityIdxTo = 4
  local function QualityChangeToCallBack(idx,data)
    if self.FilterLv[2].num == self.FilterLv[3].num then
      if self.qualityIdxForm >= idx then
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Privilege_equipshort"))
        self.qualityLv2:selectIdx(self.qualityIdxTo)
        return
      end
    end
    self.qualityIdxToChange = true
    self.qualityIdxTo = idx
    self.lb_quality1.Text = self.iconQualityAndColor[self.qualityIdxTo].qualityname
    self.lb_quality1.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(self.iconQualityAndColor[self.qualityIdxTo].color))
  end
  self.qualityLv2 = LeftRightNavExt.New(
        self.btn_left5,
        self.btn_right5,
        QualityChangeToCallBack,
        self.iconQualityAndColor,
        false
    )

  self.btn_setup.TouchClick = SetAllCond
end

local ui_names = 
{
  
  {name = 'btn_left'},
  {name = 'lb_rank_number'},
  {name = 'btn_right'},
  {name = 'btn_left2'},
  {name = 'lb_equip_level'},
  {name = 'btn_right2'},
  {name = 'btn_left4'},
  {name = 'cvs_equip_level1'},
  {name = 'btn_right4'},
  {name = 'btn_left3'},
  {name = 'lb_quality'},
  {name = 'btn_right3'},
  {name = 'btn_left5'},
  {name = 'lb_quality1'},
  {name = 'btn_right5'},
  {name = 'btn_left1'},
  {name = 'lb_grade'},
  {name = 'btn_right1'},
  {name = 'btn_setup'},
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
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_cangkusave.gui.xml", GlobalHooks.UITAG.GameUIGuildWareHousePrivilege)
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
