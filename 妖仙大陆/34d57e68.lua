local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"

local self = {
    menu = nil,
}

local retjobSet = GlobalHooks.DB.Find("GuildSetting", {})
local retjob = GlobalHooks.DB.Find("GuildPosition", {})

local tgmenuNames = 
{
  'tbt_button1',
  'tbt_button2',
  'tbt_button3',
  'tbt_button4',
  'tbt_button5',
}

local tinames = 
  {
    'ti_word1',
    'ti_word2',
    'ti_word3',
    'ti_word4',
    'ti_word5',
  }

local cvsbtns =
{
  'cvs_likebtn1',
  'cvs_likebtn2',
  'cvs_likebtn3',
  'cvs_likebtn4',
  'cvs_likebtn5',
} 

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function FindMineInList()
  local myid = DataMgr.Instance.UserData.RoleID
  self.MembersList = GDRQ.GetMembersList()
  for k,v in pairs(self.MembersList) do
    if v.playerId == myid then
      self.myMemberInfo = v
      break
    end
  end
end

local function FindChangeMemberInfo()
  local changeMemberid = GDRQ.getCurMemberId()
  if changeMemberid then
    for k,v in pairs(self.MembersList) do
      if v.playerId == changeMemberid then
        self.ChangeMemberInfo = v
        break
      end
    end
  end
end

local function ShowTGMenuSet(sender)
  if not self.myMemberInfo then
    FindMineInList()
  end

  for k,v in pairs(tgmenuNames) do
    if sender.EditName == v then
      if self.myMemberInfo.job>=k then
        if self.myMemberInfo.job == 1 then
          self.curTgBtn = sender
          self.ChangeJobNumber = 1
        else
          sender.IsChecked = false
          
          GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
        end
        break
      else
        self.curTgBtn = sender
        self.ChangeJobNumber = k
        break
      end
    end
  end

end

local function ShowSetJobName()
  self.MyGuildInfo = GDRQ.GetMyGuildInfo()
  for k,v in pairs(self.MyGuildInfo.officeNames) do
    self.jobNameStrs[v.job] = v.name
    self[tinames[v.job]].Input.Text = self.jobNameStrs[v.job] 
  end
end

local function ShowSetJob()
  FindChangeMemberInfo()

  self.lb_player.Text = self.ChangeMemberInfo.name
  self.lb_post.Text = string.format(GetTextConfg("guild_cur_job"),retjob[self.ChangeMemberInfo.job].position)

  self.ChangeJobNumber = self.ChangeMemberInfo.job
  self.curTgBtn = self.tbtArr[self.ChangeMemberInfo.job]
  Util.InitMultiToggleButton(function (sender)
          ShowTGMenuSet(sender)
        end,self.curTgBtn,{self.tbt_button1,self.tbt_button2,self.tbt_button3,self.tbt_button4,self.tbt_button5})
end

local function OnEnter()
  self.extParam = self.menu.ExtParam
  
  self.MembersList = GDRQ.GetMembersList()
  if self.extParam == "setobj" then
    self.cvs_choose.Visible = true
    self.cvs_office.Visible = false
    ShowSetJob()
  elseif self.extParam == "setobjname" then
    self.cvs_choose.Visible = false
    self.cvs_office.Visible = true
    ShowSetJobName()
  end
end

local function OnExit()
  self.myMemberInfo = nil
  self.ChangeMemberInfo = nil
end

local function initUI()
  self.tbtArr = 
  {
    self.tbt_button1,
    self.tbt_button2,
    self.tbt_button3,
    self.tbt_button4,
    self.tbt_button5,
  }

  self.jobNameStrs = {}
  for i=1,#tinames do
    self[tinames[i]].event_endEdit = function (sender,txt)
      if txt == nil then txt = "" end
      if string.utf8len(txt)<=retjobSet[1].maxLen then
        self.isChangeJobNmae = true
        self[tinames[i]].Input.Text = txt
        self.jobNameStrs[i] = tostring(txt)
        self[tinames[i]].Input.Text = self.jobNameStrs[i]
      else
        self[tinames[i]].Input.Text = self.jobNameStrs[i]
      end
    end
  end


  self.btn_sure.TouchClick = function ( ... )
    if self.ChangeJobNumber ~= self.ChangeMemberInfo.job then
      local id = self.ChangeMemberInfo.playerId
      if self.ChangeJobNumber==1 then
        
        GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,  
        GetTextConfg("guild_Main_BossToMb"),
        GetTextConfg("guild_Main_BossToMbYes"),
        GetTextConfg("guild_Main_BossToMbNO"),
        nil,
        function()
          GDRQ.transferPresidentRequest(id,function ( ... )
            if self.callfuc then self.callfuc(nil,nil) end
          end)
        end, nil)
      else
        GDRQ.setMemberJobRequest(self.ChangeMemberInfo.playerId,self.ChangeJobNumber,function ( ... )
          
          self.MyGuildInfo = GDRQ.GetMyGuildInfo()
          if self.callfuc then 
            self.callfuc(self.ChangeJobNumber,self.MyGuildInfo.officeNames[self.ChangeJobNumber].name) 
          end
        end)
      end
    end
    self.menu:Close()
  end

  self.btn_yes.TouchClick = function ( ... )
    if self.isChangeJobNmae then
      local tab = {}
      for i=1,5 do
        local tabcell = {}
        tabcell.job = i
        tabcell.name = self.jobNameStrs[i]
        table.insert(tab,tabcell)
      end

      GDRQ.changeOfficeNameRequest(tab,function ()
        if self.callfuc then
          self.callfuc() 
        end
        self.menu:Close()
      end)
    end
  end

  local jobAtFirstTab = 
  {
    {job = 1,name = retjob[1].position},
    {job = 2,name = retjob[2].position},
    {job = 3,name = retjob[3].position},
    {job = 4,name = retjob[4].position},
    {job = 5,name = retjob[5].position},
  }
  self.btn_recovery.TouchClick = function ()
    
    
    
    
    
    self.isChangeJobNmae = true
    for i=1,5 do
      self[tinames[i]].Input.Text = jobAtFirstTab[i].name
      self.jobNameStrs[i] = jobAtFirstTab[i].name
    end
  end

  local function changeBtnToCvs(sender)
    for k,v in pairs(cvsbtns) do
      if sender.EditName == v then
        self.curTgBtn = self.tbtArr[k]
        self.curTgBtn.IsChecked = true
      end
    end
  end
  local btnstr = "cvs_likebtn"
  for i=1,5 do
    self[btnstr..i].TouchClick = changeBtnToCvs
  end

end

function _M.SetCallFuc(callfuc)
  self.callfuc = callfuc
end

local ui_names = 
{
  
  {name = 'cvs_office'},
  {name = 'cvs_choose'},
  {name = 'btn_recovery'},
  {name = 'btn_yes'},
  {name = 'btn_close2',click = function ()
    self.menu:Close()
  end},
  {name = 'ti_word1'},
  {name = 'ti_word2'},
  {name = 'ti_word3'},
  {name = 'ti_word4'},
  {name = 'ti_word5'},
  {name = 'lb_player'},
  {name = 'lb_post'},
  {name = 'btn_sure'},
  {name = 'tbt_button1'},
  {name = 'tbt_button2'},
  {name = 'tbt_button3'},
  {name = 'tbt_button4'},
  {name = 'tbt_button5'},
  {name = 'cvs_likebtn1'},
  {name = 'cvs_likebtn2'},
  {name = 'cvs_likebtn3'},
  {name = 'cvs_likebtn4'},
  {name = 'cvs_likebtn5'},
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
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_office.gui.xml", GlobalHooks.UITAG.GameUIGuildSetJob)
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
