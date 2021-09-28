local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"


local self = {
    menu = nil,
}
local ret = {
  GlobalHooks.DB.Find("GuildContribute", {type = 1})[1],
  GlobalHooks.DB.Find("GuildContribute", {type = 2})[1],
}

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function GetItemNumFromBag( code )
  local bag_data = DataMgr.Instance.UserData.RoleBag
  local vItem = bag_data:MergerTemplateItem(code)
  return (vItem and vItem.Num) or 0
end

local function rushChangeUi()
  if self.donateType == 1 then
    self.cvs_donate1:FindChildByEditName("lb_num2", true).Text = (ret[1].costAmount or 0)*self.curGoldTime
    self.cvs_donate1:FindChildByEditName("lb_num4", true).Text = "+"..(ret[1].guildFunds or 0)*self.curGoldTime
    self.cvs_donate1:FindChildByEditName("lb_num6", true).Text = "+"..(ret[1].guildPoints or 0)*self.curGoldTime
    self.cvs_donate1:FindChildByEditName("lb_num5", true).Text = "+"..(ret[1].guildExp or 0)*self.curGoldTime
    if (tonumber(ret[1].costAmount or 0))*self.curGoldTime > tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)) then
      self.cvs_donate1:FindChildByEditName("lb_num3", true).FontColor = GameUtil.RGBA2Color(0xf43a1cff)
    else
      self.cvs_donate1:FindChildByEditName("lb_num3", true).FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
    end
  else
    self.cvs_donate2:FindChildByEditName("lb_num2", true).Text = (ret[2].costAmount or 0)*self.curBoxTime
    self.cvs_donate2:FindChildByEditName("lb_num4", true).Text = "+"..(ret[2].guildFunds or 0)*self.curBoxTime
    self.cvs_donate2:FindChildByEditName("lb_num6", true).Text = "+"..(ret[2].guildPoints or 0)*self.curBoxTime
    self.cvs_donate2:FindChildByEditName("lb_num5", true).Text = "+"..(ret[2].guildExp or 0)*self.curBoxTime

    if self.curBoxTime > self.boxNum then
      self.cvs_donate2:FindChildByEditName("lb_num3", true).FontColor = GameUtil.RGBA2Color(0xf43a1cff)
    else
      self.cvs_donate2:FindChildByEditName("lb_num3", true).FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
    end
  end
end

local function rushUI()
  local baseinfo = self.MyGuildInfo.myInfo
  local lb_surplusnum = self.cvs_donate1:FindChildByEditName("tb_num1", true)
  lb_surplusnum.Text = (baseinfo.timesList[1].times).."/"..baseinfo.timesList[1].maxTimes
  if baseinfo.timesList[1].maxTimes==baseinfo.timesList[1].times then
    lb_surplusnum.FontColor = GameUtil.RGBA2Color(0xf43a1cff)
  else
    lb_surplusnum.FontColor = GameUtil.RGBA2Color(0x00d600ff)
  end
  local lb_donatenum = self.cvs_donate1:FindChildByEditName("lb_num2", true)
  lb_donatenum.Text = ret[1].costAmount*self.curGoldTime
  local lb_havenum = self.cvs_donate1:FindChildByEditName("lb_num3", true)
  lb_havenum.Text = tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD))
  if tonumber(ret[1].costAmount*self.curGoldTime) > tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)) then
    lb_havenum.FontColor = GameUtil.RGBA2Color(0xf43a1cff)
  else
    lb_havenum.FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
  end
  self.cvs_donate1:FindChildByEditName("lb_num4", true).Text = "+"..(ret[1].guildFunds*self.curGoldTime)
  self.cvs_donate1:FindChildByEditName("lb_num6", true).Text = "+"..(ret[1].guildPoints*self.curGoldTime)
  self.cvs_donate1:FindChildByEditName("lb_num5", true).Text = "+"..(ret[1].guildExp*self.curGoldTime)


  local lb_surplusnum2 = self.cvs_donate2:FindChildByEditName("tb_num1", true)
  lb_surplusnum2.Text = (baseinfo.timesList[2].times).."/"..baseinfo.timesList[2].maxTimes
  if baseinfo.timesList[2].maxTimes==baseinfo.timesList[2].times then
    lb_surplusnum2.FontColor = GameUtil.RGBA2Color(0xf43a1cff)
  else
    lb_surplusnum2.FontColor = GameUtil.RGBA2Color(0x00d600ff)
  end
  local lb_donatenum2 = self.cvs_donate2:FindChildByEditName("lb_num2", true)
  lb_donatenum2.Text = ret[2].costAmount*self.curBoxTime

  local x = GetItemNumFromBag(ret[2].costItem)
  local lb_havenum2 = self.cvs_donate2:FindChildByEditName("lb_num3", true)
  lb_havenum2.Text = x
  if x<self.curBoxTime then
    lb_havenum2.FontColor = GameUtil.RGBA2Color(0xf43a1cff) 
  else
    lb_havenum2.FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
  end
  self.cvs_donate2:FindChildByEditName("lb_num4", true).Text = "+"..(ret[2].guildFunds*self.curBoxTime)
  self.cvs_donate2:FindChildByEditName("lb_num6", true).Text = "+"..(ret[2].guildPoints*self.curBoxTime)
  self.cvs_donate2:FindChildByEditName("lb_num5", true).Text = "+"..(ret[2].guildExp or 0)*self.curBoxTime


  if self.donateType == 1 then
    self.ti_num.Input.Text = self.curGoldTime
  else
    self.ti_num.Input.Text = self.curBoxTime
  end
end

local function ChangeNumFromShop(eventname,params)
  
    self.boxNum = GetItemNumFromBag(ret[2].costItem)
    local lb_havenum2 = self.cvs_donate2:FindChildByEditName("lb_num3", true)
    lb_havenum2.Text = self.boxNum
    if self.boxNum<self.curBoxTime then
      lb_havenum2.FontColor = GameUtil.RGBA2Color(0xf43a1cff) 
    else
      lb_havenum2.FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
    end
  
end

local function Filter()
  if self.filter then return end
  
  local filter = ItemPack.FilterInfo.New()
  self.filter = filter
  filter.MergerSameTemplateID = true
    filter.CheckHandle = function(item)
        return item.TemplateId == ret[2].costItem
    end
    filter.NofityCB = function(pack, type, index)
        ChangeNumFromShop()
    end
    DataMgr.Instance.UserData.RoleBag:AddFilter(filter)
end

local function SwitchDonateType(sender)
  self.ti_num.Input.Text = 1
  self.donateType = sender.UserTag
  self.cvs_donate1.Visible = self.donateType == 1
  self.cvs_donate2.Visible = self.donateType == 2
  self.ib_choose1.Visible = self.donateType == 1
  self.ib_choose2.Visible = self.donateType == 2
end

local function OnEnter()
  
  self.boxNum = GetItemNumFromBag(ret[2].costItem)

  self.MyGuildInfo = GDRQ.GetMyGuildInfo()
  
  self.maxGoldTime = self.MyGuildInfo.myInfo.timesList[1].maxTimes - self.MyGuildInfo.myInfo.timesList[1].times
  self.maxBoxNum = self.MyGuildInfo.myInfo.timesList[2].maxTimes - self.MyGuildInfo.myInfo.timesList[2].times
  self.curGoldTime = self.maxGoldTime==0 and 0 or 1
  self.curBoxTime = self.maxBoxNum==0 and 0 or 1
  rushUI()
  Filter()
end

local function OnExit()
  
  if self.filter then
    DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.filter)
    self.filter = nil
  end
end

local function initUI()
  self.tbt_1.UserTag = 1
  self.tbt_2.UserTag = 2
  Util.InitMultiToggleButton(function (sender)
    SwitchDonateType(sender)
  end,self.tbt_1,{self.tbt_1,self.tbt_2})

  self.cvs_htmlp.TouchClick = function ()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, ret[2].costItem)
  end

  self.btn_reduce.TouchClick = function ()
    if self.donateType == 1 then
      if self.curGoldTime>1 then
        self.curGoldTime = self.curGoldTime - 1
        self.ti_num.Input.Text = self.curGoldTime
        rushChangeUi()
      end
    else
      if self.curBoxTime>1 then
        self.curBoxTime = self.curBoxTime - 1
        self.ti_num.Input.Text = self.curBoxTime
        rushChangeUi()
      end
    end
  end

  self.btn_plus.TouchClick = function ()
    if self.donateType == 1 then
      if self.curGoldTime<self.maxGoldTime then
        self.curGoldTime = self.curGoldTime + 1
        self.ti_num.Input.Text = self.curGoldTime
        rushChangeUi()
      end
    else
      if self.curBoxTime<self.maxBoxNum then
        self.curBoxTime = self.curBoxTime + 1
        self.ti_num.Input.Text = self.curBoxTime
        rushChangeUi()
      end
    end
  end

  self.btn_max.TouchClick = function ()
    if self.donateType == 1 then
      local myGold = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)
      local maxTimes = math.floor(myGold / ret[1].costAmount)
      local minVlaue = math.min(self.maxGoldTime, maxTimes)
      if minVlaue <= 0 then return end
      self.curGoldTime = minVlaue
      self.ti_num.Input.Text = tostring(self.curGoldTime)
      rushChangeUi()
      if self.curGoldTime==0 then
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Donate_Over"))
      end
    else
      local minValue = math.min(self.maxBoxNum, self.boxNum)
      if minValue <= 0 then return end
      self.curBoxTime = minValue
      self.ti_num.Input.Text = tostring(self.curBoxTime)
      rushChangeUi()
      if self.curBoxTime==0 then
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Donate_Over"))
      end
    end
  end

  self.ti_num.event_endEdit = function (sender,txt)
    if self.donateType == 1 then
      local num = tonumber(txt)
      if self.maxGoldTime == 0 then
        self.ti_num.Input.Text = "0"
        return
      end
      if not num or num < 1 then
        num = 1
      elseif num > self.maxGoldTime then
        num = self.maxGoldTime
      end
      self.curGoldTime = num
    
      self.ti_num.Input.Text = tostring(num)
      rushChangeUi()
    else
      local num = tonumber(txt)
      if self.maxBoxNum  == 0 then
        self.ti_num.Input.Text = "0"
        return
      end
      if not num or num < 1 then
        num = 1
      elseif num > self.maxBoxNum then
        num = self.maxBoxNum
      end
      self.curBoxTime = num
      self.ti_num.Input.Text = tostring(num)
      rushChangeUi()
    end
  end


  self.btn_immediately.TouchClick = function ()
    if self.donateType == 1 then
      local x = ret[1].costAmount or "0"
      if self.curGoldTime == 0 then 
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Donate_Over"))
        return 
      end
      if tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)) < self.curGoldTime*x then
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Donate_nogold"))
        return
      end
  
      GDRQ.contributeToGuildRequest(1,self.curGoldTime,function ()
        local str = string.format(GetTextConfg("guild_Donate_addmore"),
          self.curGoldTime*ret[1].guildExp,
          self.curGoldTime*ret[1].guildFunds,
          self.curGoldTime*ret[1].guildPoints)
        GameAlertManager.Instance:ShowNotify(str)
        OnEnter()
        self.callfuc()
      end)
    else
        if self.curBoxTime == 0 then 
          GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Donate_Over"))
          return 
        end
        if self.boxNum < self.curBoxTime then
          GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, ret[2].costItem)
          return
        end
        GDRQ.contributeToGuildRequest(2,self.curBoxTime,function ()
          local str = string.format(GetTextConfg("guild_Donate_addmore"),
            self.curBoxTime*ret[2].guildExp,
            self.curBoxTime*ret[2].guildFunds,
            self.curBoxTime*ret[2].guildPoints)
          GameAlertManager.Instance:ShowNotify(str)
          OnEnter()
          self.callfuc()
        end)
    end
  end

  self.ti_num.TextSprite.Anchor = TextAnchor.C_C
  self.ti_num.Input.characterLimit = 3
  self.ti_num.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
end

function _M.setCall(callfuc)
  self.callfuc = callfuc
end

local ui_names = 
{
  
  {name = 'tbt_1'},
  {name = 'tbt_2'},
  {name = 'cvs_donate1'},
  {name = 'cvs_donate2'},
  {name = 'ib_choose1'},
  {name = 'ib_choose2'},
  {name = 'btn_reduce'},
  {name = 'btn_plus'},
  {name = 'btn_max'},
  {name = 'ti_num'},
  {name = 'btn_immediately'},
  {name = 'cvs_htmlp'},
}

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    self.menu:Close()
  end
  
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.menu.event_PointerClick = function (sender)
    if self and self.menu then
      self.menu:Close()
    end
  end

  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_donate.gui.xml", GlobalHooks.UITAG.GameUIGuildDonate)
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
