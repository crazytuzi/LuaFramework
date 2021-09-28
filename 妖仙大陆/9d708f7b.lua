local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local ItemModel = require 'Zeus.Model.Item'
local TERQ = require 'Zeus.Model.guildTech'
local GdDepotRq = require 'Zeus.Model.GuildDepot'
local GuildUtil = require 'Zeus.UI.XmasterGuild.GuildUtil'

local self = {
    menu = nil,
}

 local fontcolor =
{
  hong = 0xff0000ff,
  nv = 0x00d600ff,
  bai = 0xe7e5d1ff,
}

local retAttrs = GlobalHooks.DB.Find("Attribute", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function setMoneyText()
  self.lb_contribution_num.Text = TERQ.GetMycontribution()
end

local function SplicingMsgg(Ostr,isFormat,value)
  local castr = Ostr..":".." <f color='ff00d600'>".."+"..value.."</f>"

  return castr
end

local function GetLvAndJobColor_str(lv,uplv,jobnum)
  local jobstr = self.retjob[jobnum].position
  local jobc = Util.GetQualityColorARGB(self.retjob[jobnum].positionColor)
  local lvstr = ""
  local lvc = 0
  if uplv>0 then
    lvc = Util.GetQualityColorARGB(self.retCond[GuildUtil.GetCurUplvIndex(uplv)].Qcolor)
    lvstr = self.retCond[GuildUtil.GetCurUplvIndex(uplv)].Condition
  else
    lvc = Util.GetQualityColorARGB(self.retCond[1].Qcolor)
    lvstr = lv..GetTextConfg("guild_Depot_lv")
  end
  return string.format(GetTextConfg("guild_Tech_buyCondition"),lvc,lvstr,jobc,jobstr)
end

local function changeBtn(btn,state)
  if state==2 then
    btn.Text = GetTextConfg("guild_Tech_buyAfter")
    btn.Enable = false
    btn.IsGray = true
  else
    btn.Text = GetTextConfg("guild_Tech_buyBefor")
    btn.Enable = true
    btn.IsGray = false
  end
end

local function update_Skill_List( x, y, node )
  node.Visible = true
  local index = y + 1
  node.UserTag = index
  local msg = self.techInfo.skillList

  local icon = node:FindChildByEditName("ib_jn_icon",true)
  local path = msg[index].icon..'.png'
  local layout = XmdsUISystem.CreateLayoutFromFile(path, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
  icon.Layout = layout

  local lv = node:FindChildByEditName("ib_action_level",true)
  lv.Text = "Lv."..msg[index].level

  local name = node:FindChildByEditName("lb_action_name",true)
  name.Text = GetTextConfg("guild_skill_name_"..index)
    

  local attLabel = node:FindChildByEditName("tb_addition",true)
  local value = msg[index].currentAttrs[1].value
  if msg[index].nextAttrs then
    local valueAdd = msg[index].nextAttrs[1].value
    attLabel.XmlText = "<b size='22'>"..GetTextConfg("guild_skill_name_"..index).."：+"..value.." <f color='ff00d600'>".." +"..valueAdd-value.."</f></b>"
  else
    attLabel.XmlText = "<b size='22'>"..GetTextConfg("guild_skill_name_"..index).."：+"..value.."</b>"
  end
  

  local gongxian = node:FindChildByEditName("lb_contribution_num1",true)
  gongxian.Text = msg[index].needContribution or 0
  gongxian.FontColorRGBA = TERQ.GetMycontribution()<tonumber(gongxian.Text) and fontcolor.hong or fontcolor.nv

  local gold = node:FindChildByEditName("lb_jn_num",true)
  gold.Text = msg[index].needGold or 0
  if ItemModel.GetGold()<tonumber(gold.Text) then
      gold.FontColorRGBA = fontcolor.hong
      self.needCostNum = true
  else
      gold.FontColorRGBA = fontcolor.nv
  end
  

  local upBtn = node:FindChildByEditName("btn_practice",true)
  if TERQ.GetMycontribution()<tonumber(gongxian.Text) or ItemModel.GetGold()<tonumber(gold.Text) then
    upBtn.Enable = false
    upBtn.IsGray = true
  else
    upBtn.Enable = true
    upBtn.IsGray = false
  end
  upBtn.TouchClick = function ()
    TERQ.upgradeGuildSkillRequest(msg[index].id,function ()
      self.techInfo = TERQ.GetMyTechInfo()
      EventManager.Fire('Guild.TechUpLevel',{type = 1})
      
      setMoneyText()
    end)
  end
end

local function ShowSkillUI()
  self.needCostNum = false
  local num = 0
  if self.techInfo and self.techInfo.skillList then 
    num = #self.techInfo.skillList 
  end
  self.cvs_skill1.Visible = false
  self.sp_skill:Initialize(
    self.cvs_skill1.Width, 
    self.cvs_skill1.Height+5, 
    num,
    1,
    self.cvs_skill1, 
    LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
      update_Skill_List(x, y, node)
    end
    ),
    LuaUIBinding.HZTrusteeshipChildInit(function (node)
      
    end)
  )
end

local function SubAttrsStr()
  local attrStr = ""
  if self.techInfo.buffInfo.currentAttrs then
    for i=1,#self.techInfo.buffInfo.currentAttrs do
      local castr = retAttrs[self.techInfo.buffInfo.currentAttrs[i].id].attName
      local curattrvalue = self.techInfo.buffInfo.currentAttrs[i].value
      attrStr = attrStr..SplicingMsgg(castr,self.techInfo.buffInfo.currentAttrs[i].isFormat,curattrvalue).."<br/>"
      self.ti_attribute.Height = 35 * i
    end
  end
  return "<b size='22'>"..attrStr.."</b>"
end

local function RushUI()
  self.lb_lv_num.Text = self.techInfo.level..GetTextConfg("guild_Depot_lv")
  self.ti_attribute.XmlText = ""

  self.ti_attribute.XmlText = SubAttrsStr()

  self.lb_buff_lv.Text = GetTextConfg("guild_build_Lv")..self.techInfo.buffInfo.level
  self.lb_costnumfund.Text = self.techInfo.buffInfo.needFund
  self.lb_costnumfund.FontColorRGBA = self.myGuildMsg.fund<self.techInfo.buffInfo.needFund and fontcolor.hong or fontcolor.nv
  self.lb_gainlvnum.Text = self.myGuildMsg.fund

  local levelLimit = GlobalHooks.DB.Find("GTechnologyLevel", {TechnologyLevel = self.techInfo.level})[1]
  self.lb_techlevel_max.Text = levelLimit.MaxSkill

  setMoneyText()
end

local function TechUpLevelChange(eventname,params)
  if params.type == 1 then
    TERQ.getGuildTechInfoRequest(function ()
      self.techInfo = TERQ.GetMyTechInfo()
      ShowSkillUI()
    end)
  else
    self.techInfo = TERQ.GetMyTechInfo()
    RushUI()
  end
end

function _M.Notify(status, userdata, self)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.GOLD) then
        if self.needCostNum then
            ShowSkillUI()
        end
    end
end

local function OnEnter()
  self.needCostNum = false

  EventManager.Subscribe('Guild.TechUpLevel',TechUpLevelChange)
  TERQ.getGuildTechInfoRequest(function ()
    self.techInfo = TERQ.GetMyTechInfo()
    self.myGuildMsg = GDRQ.GetMyGuildInfo()
    ShowSkillUI()
    RushUI()
  end)

  DataMgr.Instance.UserData:AttachLuaObserver(self.menu.Tag, self)
  self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)
end

local function OnExit()
  DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)
  EventManager.Unsubscribe('Guild.TechUpLevel',TechUpLevelChange)
end

function _M.SetCall(callfunc)
  self.callfunc = callfunc
end

local function InitBtnClick()
  self.btn_write2.TouchClick = function ()
    if self.retjob[GDRQ.GetMyInfoFromGuild().job].right8 ~= 1 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildTechUpLv,0)
  end
  self.btn_up.TouchClick = function ()
    if self.retjob[GDRQ.GetMyInfoFromGuild().job].right9 ~= 1 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    if self.techInfo.buffInfo.level == 10 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Tech_BUFFMAXLV"))
      return
    end
    
    
    
    
    
    
    
    
    
    
    
    local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildTechBuffUpLv,0)
    obj.SetAttr(self.techInfo.buffInfo)
  end
end

local function initUI()
  self.retCond = GlobalHooks.DB.Find("GuildCondition", {})
  self.retjob = GlobalHooks.DB.Find("GuildPosition", {})

  InitBtnClick()
end

local ui_names = 
{
  
  {name = 'cvs_information'},
  {name = 'lb_lv_num'},
  {name = 'btn_write2'},
  {name = 'ti_attribute'},
  {name = 'lb_gainlvnum'},
  {name = 'lb_costnumfund'},
  {name = 'btn_up'},
  {name = 'lb_buff_lv'},
  {name = 'lb_contribution_num'},
  {name = 'lb_techlevel_max'},
  {name = 'cvs_skill1'},
  {name = 'sp_skill'},
  
  
  
  
  
  
  
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_keji.gui.xml", GlobalHooks.UITAG.GameUIGuildTech)
  self.menu.Enable = false
  self.menu.mRoot.Enable = false
  
  
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
