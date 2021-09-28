local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"

local filter = nil


local self = {
    menu = nil,
}

local ret = GlobalHooks.DB.Find("GuildSetting", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function GetItemNumFromBag( code )
  local bag_data = DataMgr.Instance.UserData.RoleBag
  local vItem = bag_data:MergerTemplateItem(code)
  return (vItem and vItem.Num) or 0
end

local function RefreshCostLabel()
    local x = GetItemNumFromBag(ret[1].changeName)
    self.tb_num.Text = x.."/"..ret[1].changeNameCost
    if x < ret[1].changeNameCost then
      self.tb_num.FontColor = GameUtil.RGBA2Color(0xf43a1cff)
    else
      self.tb_num.FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
    end
    self.btn_plus.Visible = x < ret[1].changeNameCost
end

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function OnEnter()
  self.MyGuildInfo = GDRQ.GetMyGuildInfo()
  
  self.guildNmae = self.MyGuildInfo.baseInfo.name
  self.ti_name.Input.Text = self.guildNmae
  RefreshCostLabel()
  
  local needItem = GlobalHooks.DB.Find('Items',ret[1].changeName)
  Util.ShowItemShow(self.cvs_icon, needItem.Icon, needItem.Qcolor)
  self.tb_itemName.XmlText = string.format(GetTextConfg("guild_Hall_changnameLeftDay"),self.MyGuildInfo.changeNamePassedDay)

  filter = ItemPack.FilterInfo.New()
  filter.MergerSameTemplateID = true
  filter.CheckHandle = function(item)
      return item.TemplateId == ret[1].changeName
  end
  filter.NofityCB = function(pack, type, index)
      if type == ItemPack.NotiFyStatus.ADDITEM then
          RefreshCostLabel()
      end
  end
  DataMgr.Instance.UserData.RoleBag:AddFilter(filter)

  self.btn_modify.TouchClick = function ()
    if GetItemNumFromBag(ret[1].changeName) < ret[1].changeNameCost then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_SetNmae_changefail"))
      return
    end
    local namestr = self.guildNmae or ""
    GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,  
        string.format(GetTextConfg("guild_Change_Name"),namestr),
        GetTextConfg("guild_Change_NameYes"),
        GetTextConfg("guild_Change_NameNo"),
        nil,
        function()
          GDRQ.changeGuildNameRequest(
            namestr,
            function ()
              self.callfunc(namestr)
              self.menu:Close()
            end)
        end, nil)

  end
end

local function OnExit()
  DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
end

function _M.SetCall(callfunc)
  self.callfunc = callfunc
end

local function initUI()
  self.ti_name.Input.Text = ""
  self.ti_name.event_endEdit = function (sender,txt)
    if txt == nil then txt = "" end
    if string.utf8len(txt) < 9 then
      self.ti_name.Input.Text = tostring(txt)
      self.guildNmae = tostring(txt)
    else
      self.ti_name.Input.Text = self.guildNmae
    end
  end

  self.btn_plus.TouchClick = function ()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, ret[1].changeName)
  end

end

local ui_names = 
{
  
  {name = 'ti_name'},
  {name = 'cvs_icon'},
  {name = 'btn_modify'},
  {name = 'tb_num'},
  {name = 'btn_plus'},
  {name = 'tb_itemName'},
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
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_modify.gui.xml", GlobalHooks.UITAG.GameUIGuildSetName)
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
