local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"


local self = {
    menu = nil,
}

local ret = GlobalHooks.DB.Find("GuildSetting", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function updatascroll(x, y, node)
  local index = 3*y+x+1
  if index>self.maxiconnum then
    node.Visible = false
    return
  else
    node.Visible = true
  end
  
  local icon = node:FindChildByEditName("ib_pic",true)
  local filepath = 'static_n/guild/'..index..'.png'
  local layout = XmdsUISystem.CreateLayoutFromFile(filepath, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
  icon.Layout = layout

  node.TouchClick = function ()
    self.guildIcon = tostring(index)
    self.ib_icon.Layout = layout
    self.cvs_choose.Visible = false
  end
end

local function initScrollpan()
  self.cvs_icon1.Visible = false
  self.maxiconnum = 8
  local row = math.ceil(self.maxiconnum/3)
  self.sp_see:Initialize(
      self.cvs_icon1.Width+25, 
      self.cvs_icon1.Height+10, 
      row,
      3,
      self.cvs_icon1, 
      LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        updatascroll(x, y, node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        node.event_PointerDown = function ()
          node:FindChildByEditName("ib_choosepic",true).Visible = true
        end
        node.event_PointerUp = function ()
          node:FindChildByEditName("ib_choosepic",true).Visible = false
        end
      end)
    )
end

local function randIocn()
  self.cvs_choose.Visible = false

  math.randomseed(os.time())
  local nums = math.random(1,8)
  self.guildIcon = tostring(nums)
  local filepath = 'static_n/guild/'..nums..'.png'
  local layout = XmdsUISystem.CreateLayoutFromFile(filepath, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
  self.ib_icon.Layout = layout

  self.lb_costnum.Text = ret[1].cost
  local diamond = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.DIAMOND)
  if diamond<ret[1].cost then
    self.lb_costnum.FontColor = GameUtil.RGBA2Color(0xff0000ff) 
  else
    self.lb_costnum.FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
  end

  local string = string.format(GetTextConfg("creatGuildNeedLv1"),ret[1].joinLv)
  local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
  if lv<ret[1].joinLv then
    string = string.format(GetTextConfg("creatGuildNeedLv2"),ret[1].joinLv)
  end
  self.lb_costrule.XmlText = string
end

local function OnEnter()
  self.GdName = ""
  randIocn()
end

local function OnExit()
  self.ti_name.Input.Text = ""
  self.guildIcon = nil
end

local function initUI()
  self.cvs_choose.Visible = false
  initScrollpan()

  self.btn_modify.TouchClick = function ()
    if self.cvs_choose.Visible then
      self.cvs_choose.Visible = false
    else
      self.cvs_choose.Visible = true
    end
  end

  self.cvs_choose.TouchClick = function ()
      self.cvs_choose.Visible = false
  end

  self.ti_name.Input.Text = ""
  self.ti_name.event_ValueChanged = function (sender,txt)
    if string.utf8len(txt) <= 6 then
      self.GdName = txt
      self.ti_name.Input.Text = self.GdName
    else
      self.ti_name.Input.Text = self.GdName
      local text = Util.GetText(TextConfig.Type.GUILD, "guild_words_toolong")
      GameAlertManager.Instance:ShowNotify(text)
    end
  end

  self.btn_establish.TouchClick = function ()
    if self.guildIcon == nil then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("nullIcon"))
    elseif self.GdName == "" then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("inputName"))
    else
      Util.checkRecharge(ret[1].cost,function ()
        GDRQ.createGuildRequest(self.guildIcon,self.GdName,"",function ()
          if self.backcall then self.backcall() end
          self.menu:Close()
          GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildHall,0)
        end)
      end)
    end
  end
end

function _M.SetBackCall(callfuc)
  self.backcall = callfuc
end

local ui_names = 
{
  
  {name = 'btn_modify'},
  {name = 'btn_establish'},
  {name = 'ib_icon'},
  {name = 'lb_costnum'},
  {name = 'ti_name'},
  {name = 'cvs_choose'},
  {name = 'cvs_chooseicon'},
  {name = 'sp_see'},
  {name = 'cvs_icon1'},
  {name = 'lb_costrule'},
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
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_setup.gui.xml", GlobalHooks.UITAG.GameUIBuildGuild)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
  self.menu:SetFullBackground(lrt)
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
