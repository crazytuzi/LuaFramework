local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local Player = require "Zeus.Model.Player"

local self = {
    menu = nil,
}

local function UpdateNextAddList(count)
    self.cvs_nextAttr1:FindChildByEditName("lb_pro_cur",true).Text = self.MAXHP*count
    self.cvs_nextAttr1:FindChildByEditName("lb_pro_next",true).Text = self.MAXHP*(count+1)

    self.cvs_nextAttr2:FindChildByEditName("lb_pro_cur",true).Text = self.PHY*count
    self.cvs_nextAttr2:FindChildByEditName("lb_pro_next",true).Text = self.PHY*(count+1)

    self.cvs_nextAttr3:FindChildByEditName("lb_pro_cur",true).Text = self.MAG*count
    self.cvs_nextAttr3:FindChildByEditName("lb_pro_next",true).Text = self.MAG*(count+1)

    self.cvs_nextAttr4:FindChildByEditName("lb_pro_cur",true).Text = self.AC*count
    self.cvs_nextAttr4:FindChildByEditName("lb_pro_next",true).Text = self.AC*(count+1)

    self.cvs_nextAttr5:FindChildByEditName("lb_pro_cur",true).Text = self.RESIST*count
    self.cvs_nextAttr5:FindChildByEditName("lb_pro_next",true).Text = self.RESIST*(count+1)
end

local function UpdateExchangeCost()
    local curGold = tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD))
    local curCul = tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.CULTIVATION))
    self.lb_wenben2.Text = curGold
    self.lb_wenben4.Text = curCul

    if curGold >= self.needGold then
        self.lb_wenben2.FontColor = Util.FontColorGreen
    else
        self.lb_wenben2.FontColor = Util.FontColorRed
    end

    if curCul >= self.needCul then
        self.lb_wenben4.FontColor = Util.FontColorGreen
    else
        self.lb_wenben4.FontColor = Util.FontColorRed
    end
end

local function ReqExchangeAttr(index)
    Player.ExchangePropertyRequest(index,function(data)
        self.lb_count.Text = data.count
        UpdateNextAddList(data.count)
        UpdateExchangeCost()
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ATTRIBUTE, 114))
    end)
end

local function OnEnter()
    Player.ExchangePropertyInfoRequest(function(data)
        self.lb_count.Text = data.count
        UpdateNextAddList(data.count)
        UpdateExchangeCost()
    end)

    self.btn_duihuan.TouchClick = function()
        if tonumber(self.lb_wenben1.Text) > tonumber(self.lb_wenben2.Text) then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ATTRIBUTE, 115))
        else
            ReqExchangeAttr(3)
        end
    end

    self.btn_duihuan2.TouchClick = function()
        if tonumber(self.lb_wenben3.Text) > tonumber(self.lb_wenben4.Text) then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ATTRIBUTE, 116))
        else
            ReqExchangeAttr(2)
        end
    end
end

local function OnExit()

end

local ui_names = 
{
  
  {name = 'btn_close'},

  {name = 'cvs_nextAttr1'},
  {name = 'cvs_nextAttr2'},
  {name = 'cvs_nextAttr3'},
  {name = 'cvs_nextAttr4'},
  {name = 'cvs_nextAttr5'},
  {name = 'sp_pro'},

  {name = 'lb_wenben1'},
  {name = 'lb_wenben2'},
  {name = 'btn_duihuan'},

  {name = 'lb_wenben3'},
  {name = 'lb_wenben4'},
  {name = 'btn_duihuan2'},

  {name = 'lb_count'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.sp_pro.Visible = false

  self.btn_close.TouchClick = function ()
    self.menu:Close()
  end

  self.needGold = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Exchange.Gold"})[1].ParamValue)
  self.needCul = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Exchange.UpExp"})[1].ParamValue)
  self.lb_wenben1.Text = self.needGold
  self.lb_wenben3.Text = self.needCul

  self.MAXHP = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Exchange.AddBlood"})[1].ParamValue)
  self.PHY = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Exchange.AddPhyAttack"})[1].ParamValue)
  self.MAG = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Exchange.AddMagAttack"})[1].ParamValue)
  self.AC = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Exchange.AddPhyDefense"})[1].ParamValue)
  self.RESIST = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Exchange.AddMagDefense"})[1].ParamValue)
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/character/duihuan.gui.xml", GlobalHooks.UITAG.GameUIAttrExchange)
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
