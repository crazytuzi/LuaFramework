local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"


local self = {
    menu = nil,
    yi = nil,
    wan = nil,
}

local function UpdateBossAward()
  local opentime = GlobalHooks.DB.Find("Parameters", {ParamName = "GuildBoss.Daily.OpenTime"})[1].ParamValue
  local timestr = string.split(opentime)
  self.lb_open_time.Text = timestr[1] .. "-" .. timestr[2]

  local items = GlobalHooks.DB.Find("Parameters", {ParamName = "GuildBoss.Reward"})[1].ParamValue
  local itemList = string.split(items)

  self.sp_item_list:Initialize(self.cvs_item.Width+20, self.cvs_item.Height, 1, #itemList, self.cvs_item, 
      function(x, y, cell)
          local code = itemList[x + 1]
          local it = GlobalHooks.DB.Find("Items",code)
          local itshow = Util.ShowItemShow(cell,it.Icon,it.Qcolor)
          Util.NormalItemShowTouchClick(itshow,code)
      end,
      function()

      end
  )
end

local function RefreshCellData(node, data)
  if data == nil then
    node.Visible = false
    return
  else
    node.Visible = true
  end

  local ib_123 = node:FindChildByEditName("ib_123", true)
  local lb_rank = node:FindChildByEditName("lb_rank", true)
  if data.rank <= 3 then
    ib_123.Layout = XmdsUISystem.CreateLayoutFroXmlKey("#static_n/num/num7.xml|num2|"..data.rank, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
    ib_123.Visible = true
    lb_rank.Visible = false
  else
    ib_123.Visible = false
    lb_rank.Visible = true
    lb_rank.Text = data.rank
  end

  local lb_name = node:FindChildByEditName("lb_name", true)
  lb_name.Text = data.name

  local ib_lv_num = node:FindChildByEditName("ib_lv_num", true)
  ib_lv_num.Text = data.level

  MenuBaseU.SetImageBox(node, "ib_icon", "static_n/hud/target/"..data.pro..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)

  local lb_damage = node:FindChildByEditName("lb_damage", true)
  lb_damage.Text = Util.NumberToShow(data.damage)
end


local function GetSelfRankData(dataList)
  for i,v in ipairs(dataList) do
    if v.id == DataMgr.Instance.UserData.RoleID then
      return v
    end
  end
  return nil
end

local function InitRankList(dataList)
  self.sp_rank_list:Initialize(self.cvs_rank_item.Width, self.cvs_rank_item.Height, #dataList, 1, self.cvs_rank_item, 
      function(x, y, cell)
          local index = y + 1
          local data = dataList[index]
          RefreshCellData(cell, data)
      end,
      function()

      end
  )
  
  local data = GetSelfRankData(dataList)
  RefreshCellData(self.cvs_self, data)
end



local function IntrductInfoData()
    self.btn_help.TouchClick = function()
    self.lb_location.Text = Util.GetText(TextConfig.Type.GUILD, "guild_rule")
    self.lb_location.FontColorRGBA = 0xff00a0ff
    local instruction = Util.GetText(TextConfig.Type.GUILD, "guild_notice")
    self.tb_intrduce.Text =  string.format(instruction,"\n","\n","\n","\n","\n","\n","\n") 
      if self.cvs_intrduce.Visible == false then
        self.cvs_intrduce.Visible = true
      else 
        self.cvs_intrduce.Visible = false
      end
  end
    self.btn_intrduce.TouchClick = function()
      if self.cvs_intrduce.Visible == true then
        self.cvs_intrduce.Visible = false
      end
    end 
end


local function OnEnter()
  GDRQ.GetGuildBossInfoRequest(function (data)
    
    self.lb_tips.Visible = data.killed
    self.btn_tiaozhan.Visible = not data.killed
    InitRankList(data.rankList or {})
  end)
end

local function OnExit()
  
end

local ui_names = 
{
  
  {name = 'btn_close'},

  {name = 'sp_rank_list'},
  {name = 'cvs_rank_item'},
  {name = 'cvs_self'},

  {name = 'lb_open_time'},
  {name = 'btn_dingyue'},

  {name = 'cvs_item'},
  {name = 'sp_item_list'},
  {name = 'lb_tips'},
  {name = 'btn_tiaozhan'},
  {name = 'cvs_intrduce'},
  {name = 'lb_location'},
  {name = 'tb_intrduce'},
  {name = 'btn_intrduce'},
  {name = 'btn_help'},
 
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.cvs_rank_item.Visible = false
  self.cvs_self.Visible = false
  self.cvs_self.Enable = false
  self.cvs_item.Visible = false
  self.lb_tips.Visible = false

  self.btn_close.TouchClick = function ()
    self.menu:Close()
  end

  self.btn_tiaozhan.TouchClick = function ()
    GDRQ.EnterGuildBossAreaRequest(function ()
    end)
  end
  self.yi = Util.GetText(TextConfig.Type.GUILD, "guild_yi")
  self.wan = Util.GetText(TextConfig.Type.GUILD, "guild_wan")
  UpdateBossAward()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_boss.gui.xml", GlobalHooks.UITAG.GameUIGuildBoss)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true

  InitCompnent()
  IntrductInfoData()
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
