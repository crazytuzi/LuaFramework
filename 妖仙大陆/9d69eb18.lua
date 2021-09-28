local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local GdPray = require 'Zeus.Model.guildBless'

local self = {
    menu = nil,
}

local contributeMap = {
  GlobalHooks.DB.Find("GuildContribute", {type = 1})[1],
  GlobalHooks.DB.Find("GuildContribute", {type = 2})[1],
}

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function rushBaseInfo()
  self.cvs_main.Visible = true
  self.CurChildUITag = nil
  local filepath = 'static_n/guild/'..self.MyGuildInfo.baseInfo.guildIcon..'.png'
  local layout = XmdsUISystem.CreateLayoutFromFile(filepath, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
  self.ib_icon.Layout = layout

  self.lb_guildname.Text = self.MyGuildInfo.baseInfo.name
  self.lb_lvnum.Text = self.MyGuildInfo.baseInfo.level
  self.lb_mastername.Text = self.MyGuildInfo.baseInfo.presidentName
  self.lb_mastername.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(self.MyGuildInfo.baseInfo.presidentPro))
  self.lb_qqnum.Text = self.MyGuildInfo.qqGroup or ""
  self.lb_personnelnum.Text = self.MyGuildInfo.baseInfo.memberNum.."/"..self.MyGuildInfo.baseInfo.memberMax
  self.lb_goldnum.Text = self.MyGuildInfo.fund
  self.tb_notice.UnityRichText = self.MyGuildInfo.notice
  self.lb_mynum.Text = self.MyGuildInfo.myInfo.currentContribute
  self.lb_weiwangnum.Text = self.MyGuildInfo.exp or 0
end

local function ChangeHallNotice(eventname, params)
  self.tb_notice.UnityRichText = params.notice
end

local function ChangeHallUI(eventname, params)
  
  if params.Contribute then
    self.lb_mynum.Text = params.Contribute
  elseif params.fund then
    self.lb_goldnum.Text = params.fund
  elseif params.exp then
    self.lb_weiwangnum.Text = params.exp
  end
end

local function GetItemNumFromBag( code )
  local bag_data = DataMgr.Instance.UserData.RoleBag
  local vItem = bag_data:MergerTemplateItem(code)
  return (vItem and vItem.Num) or 0
end

local function SetDonateFlag(visible)
  self.MyGuildInfo = GDRQ.GetMyGuildInfo()
  local baseinfo = self.MyGuildInfo.myInfo
  
  if baseinfo.timesList[1].maxTimes==baseinfo.timesList[1].times and 
    baseinfo.timesList[2].maxTimes==baseinfo.timesList[2].times then
    self.ib_point.Visible = false
  else
    local needVisible = false
    if baseinfo.timesList[1].maxTimes > baseinfo.timesList[1].times then
      local myGold = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)
      if myGold >= contributeMap[1].costAmount then
        needVisible = true
      end
    end
    if not needVisible and baseinfo.timesList[2].maxTimes > baseinfo.timesList[2].times then
      if GetItemNumFromBag(contributeMap[2].costItem) > 0 then
        needVisible = true
      end
    end
    self.ib_point.Visible = needVisible
  end
end

local function SetPrayFlag(eventname, params)
  MenuBaseU.SetVisibleUENode(self.menu,"ib_point1", params.visible)
end

local function SetAppFlag(eventname, params)
  MenuBaseU.SetVisibleUENode(self.menu,"ib_point2", params.visible)
end

local function SetBossFlag(bool)
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_BOSS)
    MenuBaseU.SetVisibleUENode(self.menu,"ib_point3", (num ~= nil and num > 0) and bool)
end

local function SetGuildWarFlag(bool)
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WAR_APPLY) + 
                DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WAR_ACCESS) +
                DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WAR_AWARD)
    MenuBaseU.SetVisibleUENode(self.menu,"ib_point4", (num ~= nil and num > 0) and bool)
end

local function SetGuildAuctionFlag()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_AUCTION) + DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WORLD_AUCTION)
    MenuBaseU.SetVisibleUENode(self.menu,"lb_btn_auction", num ~= nil and num > 0)
end

local function OnEnter()
  self.tbt_inf.IsChecked = true
  self.btn_science.IsChecked = false
  self.btn_territory.IsChecked = false
  self.btn_cangku.IsChecked = false
  self.btn_auction.IsChecked = false

  
  EventManager.Subscribe("Event.UI.ChangeHallNotice", ChangeHallNotice)
  EventManager.Subscribe("Event.UI.ChangeHallUI", ChangeHallUI)
  EventManager.Subscribe("Event.UI.ChangeAppFlag", SetAppFlag)
  EventManager.Subscribe("Event.UI.ChangePrayFlag", SetPrayFlag)

  GDRQ.getMyGuildInfoRequest(function ()
    GDRQ.getMyGuildMembersRequest(function ()
    end)
    self.MyGuildInfo = GDRQ.GetMyGuildInfo()
    
    if self.callFunc then
      self.callFunc()
    end
    self.noticeStr = self.MyGuildInfo.notice
    SetDonateFlag()
    rushBaseInfo()
  end)

  GDRQ.getApplyListRequest(function (msg)
      MenuBaseU.SetVisibleUENode(self.menu,"ib_point2", #(msg or {}) ~= 0 and self.retJob[GDRQ.GetMyInfoFromGuild().job].right3==1)
    end)

  GdPray.getMyBlessInfoRequest(function ()
    local params = {visible = false}
    local myPrayInfo = GdPray.GetMyPrayInfo()
    if myPrayInfo and myPrayInfo.myInfo then
      for i,v in ipairs(myPrayInfo.myInfo.receiveState) do
        if v == 1 then
          params.visible = true
          break
        end
      end
    end
    SetPrayFlag("", params)
  end)

  SetBossFlag(true)
  SetGuildWarFlag(true)
end

local function OnExit()
  self.callFunc = nil
  EventManager.Unsubscribe("Event.UI.ChangeHallNotice",ChangeHallNotice)
  EventManager.Unsubscribe("Event.UI.ChangeHallUI",ChangeHallUI)
  EventManager.Unsubscribe("Event.UI.ChangeAppFlag", SetAppFlag)
  EventManager.Unsubscribe("Event.UI.ChangePrayFlag", SetPrayFlag)
end

local function addMoney(sender)
  local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildDonate,0)
  obj.setCall(function ()
    self.MyGuildInfo = GDRQ.GetMyGuildInfo()
    self.lb_goldnum.Text = self.MyGuildInfo.fund
    self.lb_mynum.Text = self.MyGuildInfo.myInfo.currentContribute
    self.lb_weiwangnum.Text = self.MyGuildInfo.exp
    SetDonateFlag()
  end)
end

local function setCall(func)
  self.callFunc = func
end

local function Switch2ChildUI(sender)
  SetGuildAuctionFlag()

  self.cvs_main.Visible = sender == self.tbt_inf
  if self.CurChildUITag ~= nil then
    MenuMgrU.Instance:CloseMenuByTag(self.CurChildUITag)
  end
  if sender == self.tbt_inf then
    self.CurChildUITag = nil
  elseif sender == self.btn_science then
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildTech,0)
    self.CurChildUITag = GlobalHooks.UITAG.GameUIGuildTech
  elseif sender == self.btn_territory then
    
    GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILD, "guild_notopen"))
    self.CurChildUITag = nil
  elseif sender == self.btn_cangku then
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWareHouse,0)
    self.CurChildUITag = GlobalHooks.UITAG.GameUIGuildWareHouse
  elseif sender == self.btn_auction then
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildAuction,0)
    self.CurChildUITag = GlobalHooks.UITAG.GameUIGuildAuction
  end
end

local function initAllBtn()
  Util.InitMultiToggleButton(function (sender)
    Switch2ChildUI(sender)
  end,self.tbt_inf,{self.tbt_inf,self.btn_science,self.btn_territory,self.btn_cangku,self.btn_auction})


  self.btn_list.TouchClick = function ()
      GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildMain,0,1)
  end

  self.btn_dynamic.TouchClick = function ()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildDynamic,0)
  end

  self.btn_qifu.TouchClick = function ()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildPray,0)
  end

  self.btn_shop.TouchClick = function ()
    EventManager.Fire('Event.Goto', {id = "GuildShop"})
  end

  self.btn_boss.TouchClick = function ()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildBoss,0)
    SetBossFlag(false)
  end

  self.btn_judian.TouchClick = function ()
    self.menu:Close()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarMain,0)
  end

  self.btn_up.TouchClick = function ( ... )
    local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildUpLv,0)
    obj.SetCall(function ()
      self.MyGuildInfo = GDRQ.GetMyGuildInfo()
      rushBaseInfo()
    end)
  end

  self.btn_donate.TouchClick = addMoney
  self.btn_plus.TouchClick = addMoney

  self.btn_qq.TouchClick = function ()
    local myjobnum = GDRQ.GetMyInfoFromGuild().job
    
    if self.retJob[myjobnum].right7~=1 then
      if string.len(self.MyGuildInfo.qqGroup)>1 then
        PlatformMgr.SetPasteboard(self.MyGuildInfo.qqGroup)
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Hall_copyQQ"))
      else
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      end
    else
      local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildSetQQ,0)
      obj.SetCall(function (str)
        self.lb_qqnum.Text = str
      end)
    end
  end

  self.btn_write2.TouchClick = function ()
    if self.MyGuildInfo.baseInfo.presidentId ~= DataMgr.Instance.UserData.RoleID then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    local ret = GlobalHooks.DB.Find("GuildSetting", {})
    if self.MyGuildInfo.changeNamePassedDay < ret[1].changeNameCD then
      GameAlertManager.Instance:ShowNotify(string.format(GetTextConfg("guild_Hall_changname"),ret[1].changeNameCD))
      return
    end
    local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildSetName,0)
    obj.SetCall(function (str)
      self.lb_guildname.Text = str
    end)
  end

  self.btn_write.TouchClick = function ()
    if self.retJob[GDRQ.GetMyInfoFromGuild().job].right1 ~= 1 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildSetNotice,0,self.noticeStr)
    obj.setCall(function (str)
      if str then
        self.noticeStr = str
        self.tb_notice.UnityRichText = self.noticeStr
      end
    end)
  end

  self.btn_chat.TouchClick = function ()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatMainSecond, 0, 2)
  end
end

local function initUI()
  self.cvs_main.Enable = false
  self.retJob = GlobalHooks.DB.Find("GuildPosition", {})
  initAllBtn()
  
  
  
end

local ui_names = 
{
  
  {name = 'cvs_main'},
  {name = 'btn_list'},
  {name = 'tbt_inf'},
  {name = 'btn_science'},
  {name = 'btn_dynamic'},
  {name = 'btn_shop'},
  {name = 'btn_boss'},
  {name = 'btn_territory'},
  {name = 'btn_up'},
  {name = 'btn_donate'},
  {name = 'lb_mastername'},
  {name = 'lb_qqnum'},
  {name = 'btn_qq'},
  {name = 'lb_personnelnum'},
  {name = 'lb_goldnum'},
  {name = 'ib_icon'},
  {name = 'lb_guildname'},
  {name = 'lb_lvnum'},
  {name = 'btn_write2'},
  {name = 'btn_write'},
  {name = 'tb_notice'},
  {name = 'btn_plus'},
  {name = 'lb_mynum'},
  {name = 'btn_cangku'},
  {name = 'btn_qifu'},
  {name = 'ib_point1'},
  {name = 'lb_weiwangnum'},
  {name = 'btn_chat'},
  {name = 'btn_auction'},
  {name = 'lb_btn_auction'},
  {name = 'btn_judian'},
  {name = 'ib_point'},
  {name = 'ib_point2'},
  {name = 'ib_point3'},
  {name = 'ib_point4'},
  
  
  
}

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    
    MenuMgrU.Instance:CloseAllMenu()
  end
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_hall.gui.xml", GlobalHooks.UITAG.GameUIGuildHall)
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

_M.addMoney = addMoney
_M.setCall = setCall
return {Create = Create}
