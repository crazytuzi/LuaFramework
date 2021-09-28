local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"


local self = {
    menu = nil,
}

local fontcolor =
{
  hong = 0xff0000ff,
  nv = 0x00d600ff,
}

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function update_pan_List(x,y,node)
  local index = y+1
  node.UserTag = index
  local msg = self.GulidList[index]

  local gudname = node:FindChildByEditName("lb_guildname",true)
  gudname.Text = msg.baseInfo.name

  
  
  
  

  local gudlv = node:FindChildByEditName("lb_lv",true)
  gudlv.Text = msg.baseInfo.level

  local gudusname = node:FindChildByEditName("lb_name",true)
  gudusname.Text = msg.baseInfo.presidentName
  gudusname.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(msg.baseInfo.presidentPro))

  local ppnum = node:FindChildByEditName("lb_num",true)
  ppnum.Text = msg.baseInfo.memberNum.."/"..msg.baseInfo.memberMax
  ppnum.FontColor = GameUtil.RGBA2Color(msg.baseInfo.memberNum==msg.baseInfo.memberMax and fontcolor.hong or fontcolor.nv )

  local ulv = msg.baseInfo.entryUpLevel
  local lv = msg.baseInfo.entryLevel
  local color = fontcolor.nv
  if ulv==0 then
    color = msg.baseInfo.entryLevel>DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL) and fontcolor.hong or fontcolor.nv
  else
    color = msg.baseInfo.entryUpLevel>DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL) and fontcolor.hong or fontcolor.nv
  end

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

  local gudlimit = node:FindChildByEditName("lb_limitnum",true)
  if self.factorLv then
    gudlimit.Text = self.retCond[self.factorLv].Condition
  else
    gudlimit.Text = lv
  end
  gudlimit.FontColor = GameUtil.RGBA2Color(color)
  local btncall = node:FindChildByEditName("btn_call",true)
  btncall.TouchClick = function ()
      local FriendModel = require "Zeus.Model.Friend"
      FriendModel.friendApplyRequest(msg.baseInfo.presidentId, function()
        local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.LEADERBOARD, "FriendTips1")
        GameAlertManager.Instance:ShowNotify(string.format(tips, msg.baseInfo.presidentName))
      end)     
  end

  local maxpp = node:FindChildByEditName("lb_state",true)
  maxpp.Visible = msg.baseInfo.memberNum==msg.baseInfo.memberMax

  local isapp = node:FindChildByEditName("lb_apply",true)
  isapp.Visible = msg.applyState==1

  local btnapply = node:FindChildByEditName("btn_apply",true)
  btnapply.Visible = msg.baseInfo.memberNum~=msg.baseInfo.memberMax and not isapp.Visible
  if msg.baseInfo.memberNum~=msg.baseInfo.memberMax and not isapp.Visible then
    btnapply.TouchClick = function ()
      
      
      
      
      GDRQ.joinGuildRequest(msg.baseInfo.guildId,function ()
        btnapply.Visible = false
        isapp.Visible = true
        msg.applyState = 1
      end)
    end
  end

end

local function rushScrollpan(issearch,msg)
  if not issearch then
    self.GulidList = GDRQ.GetGuildList()
  else
    self.GulidList = msg
  end
  
  if self.GulidList==nil then self.GulidList={} end
  local num = #self.GulidList
  self.sp_see:Initialize(
      self.cvs_single.Width, 
      self.cvs_single.Height+5, 
      num,
      1,
      self.cvs_single, 
      LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        update_pan_List(x, y, node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        
      end)
    )
end

local function InitUi()
  self.retCond = GlobalHooks.DB.Find("GuildCondition", {})
  self.ti_search.Input.Text = ""
  self.ti_search.event_endEdit = function (sender,txt)
    if string.len(txt) <= 24 then
      self.searchGdName = txt
    else
      self.ti_search.Input.Text = self.searchGdName
    end
    if self.isSearchToName and string.len(txt)<1 then
      GDRQ.getGuildListRequest(nil,function ()
          rushScrollpan(false,nil)
        end)
    end
  end
end

local function IsInGuildFuc()
  self.menu:Close()
  GDRQ.getMyGuildInfoRequest(function (myguildinfo)
      if table.getCount(myguildinfo)<1 then
        GDRQ.getGuildListRequest(nil,function ()
          GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIApplyGuild,0)
      end)
    else
      GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildHall,0)
    end
  end)
end

local function OnEnter()
  EventManager.Subscribe('Event.Menu.InGuild', IsInGuildFuc)
  self.cvs_single.Visible = false
  GDRQ.getGuildListRequest(nil,function ()
    self.searchGdName = ""
    rushScrollpan(false,nil)
  end)
end

local function OnExit()
  EventManager.Unsubscribe('Event.Menu.InGuild',IsInGuildFuc)
  self.ti_search.Input.Text = ""
end

local function InitBtn()
  self.btn_button1.TouchClick = function ()
    local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBuildGuild,0)
    obj.SetBackCall(function ()
      self.menu:Close()
    end)
  end

  self.btn_button2.TouchClick = function ()
    if self.searchGdName then
      self.isSearchToName = true
      GDRQ.getGuildListRequest(self.searchGdName,function (msg)
          rushScrollpan(true,msg)
        end)
    else
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Apply_rightname"))
    end
  end
end

local ui_names = 
{
  
  {name = 'sp_see'},
  {name = 'cvs_single'},
  {name = 'ti_search'},
  {name = 'btn_button2'},
  {name = 'btn_button1'},
  
  
  
}

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    self.menu:Close()
  end
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  InitBtn()
  InitUi()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_establish.gui.xml", GlobalHooks.UITAG.GameUIApplyGuild)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  self.menu.ShowType = UIShowType.HideBackHud
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
