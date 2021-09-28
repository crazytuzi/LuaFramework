local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local GuildUtil = require 'Zeus.UI.XmasterGuild.GuildUtil'
local ServerTime = require 'Zeus.Logic.ServerTime'


local self = {
    menu = nil,
}

local nameColorIndex = {3,2,1,4,0}

local TypePageName = 
{
  'cvs_memberlist',
  'cvs_audit',
}

local togTabName = 
{
  'tbt_member',
  'tbt_audit',
}

local retGuildRecord = GlobalHooks.DB.Find("GuildRecord", {})

local function GetTextConfg(key, ...)
  return Util.GetText(TextConfig.Type.GUILD, key, ...)
end

local function SetAppFlag(msg,isFire)
  local num = 0
  if msg then
    num = #msg
  end
  MenuBaseU.SetVisibleUENode(self.menu,"ib_redpoint", num ~= 0 and self.retJob[GDRQ.GetMyInfoFromGuild().job].right3==1)
  if isFire then EventManager.Fire("Event.UI.ChangeAppFlag",{visible = num~=0 and self.retJob[GDRQ.GetMyInfoFromGuild().job].right3==1}) end
end

local function update_Apply_List(x,y,node)
  local index = y + 1
  node.UserTag = index
  local msg = self.applyList[index]

  local applyname = node:FindChildByEditName("lb_name",true)
  applyname.Text = msg.name
  applyname.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(msg.pro))

  local applylv = node:FindChildByEditName("lb_lv",true)
  
    applylv.Text = msg.level
    
  
    
    
  

  local applyRl = node:FindChildByEditName("lb_zhanli",true)
  applyRl.Text = msg.fightPower

  local refuseApp = node:FindChildByEditName("btn_no",true)
  refuseApp.TouchClick = function ()
    GDRQ.dealApplyRequest(msg.applyId,0,function ()
      for k,v in pairs(self.applyList) do
        if v.applyId == msg.applyId then
          table.remove(self.applyList,k)
          self.sp_see_factor:ResetRowsAndColumns(table.getCount(self.applyList),1)
          SetAppFlag(self.applyList,true)
          break
        end
      end
    end)
  end

  local AgreeApp = node:FindChildByEditName("btn_yes",true)
  AgreeApp.TouchClick = function ()
    GDRQ.dealApplyRequest(msg.applyId,1,function ()
      for k,v in pairs(self.applyList) do
        if v.applyId == msg.applyId then
          table.remove(self.applyList,k)
          self.sp_see_factor:ResetRowsAndColumns(table.getCount(self.applyList),1)
          SetAppFlag(self.applyList,true)
          break
        end
      end
    end)
  end
end

local function ShowApplyList()
  local num=0
  if self.applyList then
    num = #self.applyList
  end
  self.sp_see_factor:Initialize(
      self.cvs_single_factor.Width, 
      self.cvs_single_factor.Height+5, 
      num,
      1,
      self.cvs_single_factor, 
      LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        update_Apply_List(x, y, node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        
      end)
    )
end

local function findJobNumForPlayerId(playerId)
  if playerId==nil then
    playerId = DataMgr.Instance.UserData.RoleID
  end
  for k,v in pairs(self.membersList) do
    if v.playerId == playerId then
      return v.job
    end
  end
end

local function SlectCallFuc(id,data)
  if id == 28 then
    
    local kickMaxCount = GlobalHooks.DB.Find("GuildSetting", {})[1].fireNum
    local kickStr = string.format("%d/%d", GDRQ.GetRemainKickCount(), kickMaxCount)
    GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,  
      GetTextConfg("guild_Main_removeMember", kickStr),
      GetTextConfg("guild_Main_removeYes"),
      GetTextConfg("guild_Main_removeNO"),
      nil,
      function()
        GDRQ.kickMemberRequest(data.playerId,function (remainTimes)
          GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_kick_num", remainTimes))
          for k,v in pairs(self.membersList) do
            if v.playerId == data.playerId then
              table.remove(self.membersList,k)
              self.sp_see:ResetRowsAndColumns(#self.membersList,1)
            end
          end
        end)
      end, nil)
  elseif id==27 then
    
    GDRQ.impeachGuildPresidentRequest(function ()
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Main_removeBoss"))
    end)
  elseif id == 26 then
    
    GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,  
      GetTextConfg("guild_Main_BossToMb"),
      GetTextConfg("guild_Main_BossToMbYes"),
     GetTextConfg("guild_Main_BossToMbNO"),
      nil,
      function()
        GDRQ.transferPresidentRequest(data.playerId,function ( ... )
          self.membersList = GDRQ.GetMembersList()
          self.sp_see:ResetRowsAndColumns(#self.membersList,1)
        end)
      end, nil)
  elseif id==25 then
    
    
    if (findJobNumForPlayerId(nil) < findJobNumForPlayerId(data.playerId)) then
      GDRQ.ChangeMemberToId(data.playerId)
      local node,job = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildSetJob,0,"setobj")
      job.SetCallFuc(function (jobnum,jobname)
        self.membersList[self.memberIndex].job = jobnum
        self.membersList[self.memberIndex].jobName = jobname
        self.sp_see:ResetRowsAndColumns(#self.membersList,1)
      end)
    else
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
    end
  end
end

local function update_Member_List(x, y, node)
  local index = y + 1
  node.UserTag = index
  local msg = self.membersList[index]

  local membername = node:FindChildByEditName("lb_name",true)
  membername.Text = msg.name
  membername.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(msg.pro))

  local memberLv = node:FindChildByEditName("lb_lv",true)
  
    memberLv.Text = msg.level
    
  
  
  
  

  local memberObj = node:FindChildByEditName("lb_post",true)
  memberObj.Text = msg.jobName
  
  memberObj.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(nameColorIndex[msg.job]))

  local cont = node:FindChildByEditName("lb_cont",true)
  cont.Text = msg.currentContribute

  local maxcont = node:FindChildByEditName("lb_total",true)
  maxcont.Text = msg.totalContribute

  local isOnline = node:FindChildByEditName("lb_state",true)
  if msg.onlineState==1 then
    isOnline.Text = GetTextConfg("guild_Main_MBIsOnline")
    isOnline.FontColor = GameUtil.RGBA2Color(0x00D600FF)
  else
    local cd = ServerTime.GetServerUnixTime() - msg.lastActiveTime
    local time = 0
    local formatText = nil
    if cd < 3600 then
      formatText = "gulid_outTime1"
      time = math.floor(cd / 60)
    elseif cd < 3600 * 24 then
      formatText = "gulid_outTime2"
      time = math.floor(cd / 3600)
    elseif cd < 3600 * 24 * 30 then
      formatText = "gulid_outTime3"
      time = math.floor(cd / 3600 / 24)
    else
      formatText = "gulid_outTime4"
    end
    if time < 1 then time = 1 end

    isOnline.Text = Util.GetText(TextConfig.Type.GUILD, formatText, time)
    isOnline.FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
  end

  local function findmineJob()
    for k,v in pairs(self.membersList) do
      if v.playerId==DataMgr.Instance.UserData.RoleID then
        return v.job
      end
    end
  end
  local setObj = node:FindChildByEditName("btn_modify",true)
  setObj.Visible = DataMgr.Instance.UserData.RoleID ~= msg.playerId
  setObj.Visible = findmineJob()<msg.job
  setObj.TouchClick = function ()
    GDRQ.ChangeMemberToId(msg.playerId)
    local node,job = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildSetJob,0,"setobj")
    job.SetCallFuc(function (jobnum,jobname)
      local pos = self.sp_see.ContainerPanel.Position2D
      if jobnum then
        self.membersList[index].job = jobnum
        self.membersList[index].jobName = jobname
        self.sp_see:ResetRowsAndColumns(#self.membersList,1)
      else
        self.membersList = GDRQ.GetMembersList()
        self.sp_see:ResetRowsAndColumns(#self.membersList,1)
      end
      self.sp_see.ContainerPanel.Position2D = pos
    end)
  end

  local slect = node:FindChildByEditName("btn_op",true)
  slect.Visible = DataMgr.Instance.UserData.RoleID ~= msg.playerId
  local function slectfuc()
      node:FindChildByEditName("is_slect",true).Visible = true
      if DataMgr.Instance.UserData.RoleID == msg.playerId then
        node:FindChildByEditName("is_slect",true).Visible = false
        return
      end
      self.memberIndex = index
      self.myGuildMsg = GDRQ.GetMyGuildInfo()
      local typestr = "cfg_guild_member1"
      if self.myGuildMsg.baseInfo.presidentId == DataMgr.Instance.UserData.RoleID then 
        typestr = "cfg_guild_Master"
      elseif self.retJob[GDRQ.GetMyInfoFromGuild().job].right4 == 1 then 
        if self.myGuildMsg.baseInfo.presidentId == msg.playerId then
          typestr = "cfg_guild_SecondMaster1"
        else
          typestr = "cfg_guild_SecondMaster2"
        end
      elseif self.myGuildMsg.baseInfo.presidentId == msg.playerId then 
        typestr = "cfg_guild_member2"
      end
      EventManager.Fire("Event.ShowInteractive", {
            type=typestr,
            player_info={
            name=msg.name, lv=msg.level,
            upLv = msg.upLevel,
            guildName = msg.guildName,
            playerId = msg.playerId,
            pro = msg.pro,
            lv = msg.level,
            activeMenuCb = function (id, data)
              node:FindChildByEditName("is_slect",true).Visible = false
              SlectCallFuc(id,data)
            end,
            }
        })
  end
  slect.TouchClick = slectfuc
  
end

local function ShowMemberList()
  self.membersList = GDRQ.GetMembersList() or {}
  local num = #self.membersList
  self.sp_see:Initialize(
      self.cvs_single.Width, 
      self.cvs_single.Height+5, 
      num,
      1,
      self.cvs_single, 
      LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        update_Member_List(x, y, node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        
      end)
    )
end

local function setBtnClick_Two( ... )
  self.btn_button1.Visible = true
  self.btn_button2.Visible = true
  self.btn_button3.Visible = true
  self.btn_button4.Visible = true

  self.btn_button1.Text = GetTextConfg("guild_Main_rushList")
  self.btn_button1.TouchClick = function ()
    GDRQ.getApplyListRequest(function (msg)
      self.applyList = msg
      if self.applyList then
        self.sp_see_factor:ResetRowsAndColumns(table.getCount(self.applyList),1)
      else
        self.sp_see_factor:ResetRowsAndColumns(1,0)
      end
      SetAppFlag(self.applyList,false)
    end)
  end
  self.btn_button2.Text = GetTextConfg("guild_Mian_addcondition")
  self.btn_button2.TouchClick = function ( ... )
    if self.retJob[GDRQ.GetMyInfoFromGuild().job].right3 ~= 1 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildFactor,0)
  end
  self.btn_button3.Text = GetTextConfg("guild_Main_allNO")
  self.btn_button3.TouchClick = function ( ... )
    GDRQ.dealApplyRequest("",2,function ()
      self.sp_see_factor:ResetRowsAndColumns(1,0)
      self.applyList = {}
      SetAppFlag(self.applyList,true)
    end) 
  end
  self.btn_button4.Text = GetTextConfg("guild_Main_allYES")
  self.btn_button4.TouchClick = function ( ... )
    GDRQ.dealApplyRequest("",3,function ()
      self.sp_see_factor:ResetRowsAndColumns(1,0)
      self.applyList = {}
      SetAppFlag(self.applyList,true)
    end)
  end
end

local function setBtnClick_One()
  self.btn_button1.Visible = true
  self.btn_button2.Visible = true
  self.btn_button3.Visible = true
  self.btn_button4.Visible = true

  self.btn_button1.Text = GetTextConfg("guild_Main_Exit")
  self.btn_button1.TouchClick = function ()
    local time = GlobalHooks.DB.Find("GuildSetting", {})[1].selfOut
    local timeStr = ServerTime.GetCDStrCut(time * 60)
    local memberCount = table.getCount(self.membersList)
    if memberCount > 1 then
      GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,  
        GetTextConfg("guild_Main_ExitSure", timeStr),
        GetTextConfg("guild_Main_ExitYes"),
        GetTextConfg("guild_Main_ExitNO"),
        nil,
        function()
          GDRQ.exitGuildRequest(function ()
            MenuMgrU.Instance:CloseAllMenu()
          end)
      end, nil)
    else
      GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,  
        GetTextConfg("guild_Main_DestroySure"),
        GetTextConfg("guild_Main_DestroyYes"),
        GetTextConfg("guild_Main_DestroyNO"),
        nil,
        function()
          GDRQ.exitGuildRequest(function ()
            MenuMgrU.Instance:CloseAllMenu()
          end)
      end, nil)
    end
  end

  self.btn_button2.Text = GetTextConfg("guild_Mian_addcondition")
  self.btn_button2.TouchClick = function ( ... )
    if self.retJob[GDRQ.GetMyInfoFromGuild().job].right3 ~= 1 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildFactor,0)
  end

  self.btn_button3.Text = GetTextConfg("guild_Main_JobName")
  self.btn_button3.TouchClick = function ( ... )
    self.myGuildMsg = GDRQ.GetMyGuildInfo()
    if self.myGuildMsg.baseInfo.presidentId ~= DataMgr.Instance.UserData.RoleID then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    local node,job = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildSetJob,0,"setobjname")
    job.SetCallFuc(function ( ... )
      GDRQ.getMyGuildMembersRequest(function ()
        ShowMemberList()
      end)
    end)
  end
  self.btn_button4.Text = GetTextConfg("guild_Main_guildrank")
  self.btn_button4.TouchClick = function ( ... )
      local Leaderboard = require "Zeus.Model.Leaderboard"
      MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard, 0, Leaderboard.LBType.GUILD_LEVEL)
  end
end

local function ShowSwitchPage(index)
  self[TypePageName[index]].Visible = true
  if index==1 then
    GDRQ.getMyGuildMembersRequest(function ()
        ShowMemberList()
        setBtnClick_One()
      end)
  elseif index==2 then
    GDRQ.getApplyListRequest(function (msg)
      self.applyList = msg
      ShowApplyList()
      setBtnClick_Two()
    end)
  end
end

local function OnSwitch(sender)
  local showIndex = 1
  for i=1,#togTabName do
    if togTabName[i]==sender.EditName then
      showIndex = i
    else
      self[TypePageName[i]].Visible = false
    end
  end
  ShowSwitchPage(showIndex)
end

local function OnEnter()
  self.cvs_single_factor.Visible = false
  self.cvs_single.Visible = false
  local tab = {self.tbt_member,self.tbt_audit}
  local SwitchNum = tonumber(self.menu.ExtParam)
  Util.InitMultiToggleButton(function (sender)
          OnSwitch(sender)
        end,tab[SwitchNum],{self.tbt_member,self.tbt_audit})

  GDRQ.getApplyListRequest(function (msg)
      SetAppFlag(msg,false)
    end)
end

local function OnExit()

end

local function initUI()
  self.retCond = GlobalHooks.DB.Find("UpLevelExp", {})
  self.retJob = GlobalHooks.DB.Find("GuildPosition", {})

  self.ib_redpoint.Visible = false
end

local ui_names = 
{
  
  {name = 'cvs_memberlist'},
  {name = 'cvs_audit'},
  {name = 'sp_see_factor'},
  {name = 'cvs_single_factor'},
  {name = 'sp_see'},
  {name = 'cvs_single'},
  {name = 'sp_see_title'},
  {name = 'tbh_cell'},
  {name = 'cvs_tab'},
  {name = 'tbt_member'},
  {name = 'tbt_audit'},
  {name = 'btn_button1'},
  {name = 'btn_button2'},
  {name = 'btn_button3'},
  {name = 'btn_button4'},
  {name = 'ib_redpoint'},
  
  
  
  {name = 'btn_close',click = function ()
    self.menu:Close()
  end},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_main.gui.xml", GlobalHooks.UITAG.GameUIGuildMain)
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
