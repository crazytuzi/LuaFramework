

local Helper = require'Zeus.Logic.Helper'
local Util = require'Zeus.Logic.Util'

local _M = {}
_M.__index = _M

local Text = {
  AlreadyMin = Util.GetText(TextConfig.Type.ITEM,'alreadyMin'),
  AlreadyMax = Util.GetText(TextConfig.Type.ITEM,'alreadyMax'),
}

local function Close(self)
  self.menu:Close()  
end

local function SetNum(self,num)
  self.Num = num
  self.ti_nim.Input.Text = tostring(self.Num)

  if self.ChangeCB then
    self.ChangeCB(self,self.Num)
  end
end

local function Minus(self)
  if self.Num > self.MinNum then
    SetNum(self,self.Num - 1)
  elseif not self.is_show then
    self.is_show = true
    GameAlertManager.Instance:ShowNotify(Text.AlreadyMin)
  end  
end

local function Add(self)
  if self.Num < self.MaxNum then
    SetNum(self,self.Num + 1)
  elseif not self.is_show then
    self.is_show = true
    if self.TipMax then
        GameAlertManager.Instance:ShowNotify(self.TipMax)
    else
        GameAlertManager.Instance:ShowNotify(Text.AlreadyMax)
    end
    
  end 
end
local ui_names = 
{
  
  
  {name = 'lb_title'},
  {name = 'tb_con1'},
  {name = 'tb_con2'},
  {name = 'tb_cost'},
  {name = 'cvs_icon'},
  {name = 'bt_no',click = Close},
  {name = 'ti_nim'},
  {name = 'btn_jian',click = function (self)
    Minus(self)
    self.is_show = nil
  end},
  {name = 'btn_jia',click = function (self)
    Add(self)
    self.is_show = nil
  end},
  {name = 'btn_max',click = function (self)
    SetNum(self,self.MaxNum)
  end},
  {name = 'bt_yes',click = function (self)
    local result = tonumber(self.ti_nim.Input.Text)
    if result and self.ResultCallBack then
      self.ResultCallBack(self,result)
    end
    self:Close()
  end},
}


local function OnEnter(self)
  SetNum(self,self.Num)
end

local function OnExit(self)
  if self.ExitCB then
    self.ExitCB(self)
  end
end
local function InitComponent(self,tag)
  
  self.menu = LuaMenuU.Create('xmds_ui/common/common_num.gui.xml',tag)
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  self.ti_nim.Input.characterLimit = 30
  self.ti_nim.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
  self.ti_nim.event_endEdit = function (sender,txt)
    local num = tonumber(txt) 
    if not num or num < self.MinNum then
      num = 1
    elseif num > self.MaxNum then
      num = self.MaxNum
    end
    SetNum(self,num)  
  end
  
  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    
  end)
  local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
  self.menu:SetFullBackground(lrt)
  
  self.tb_con1.TextComponent.Anchor = TextAnchor.L_C
  self.tb_con2.TextComponent.Anchor = TextAnchor.L_C
  self.tb_cost.TextComponent.Anchor = TextAnchor.C_C
  self.ti_nim.TextSprite.Anchor = TextAnchor.C_C 
  self.btn_jian.LongPressSecond = 0.5
  self.btn_jian.event_LongPoniterDownStep = function (sender)
    Minus(self)
  end
  self.btn_jian.event_PointerUp = function (sender)
    self.is_show = nil
  end

  self.btn_jia.LongPressSecond = 0.5
  self.btn_jia.event_LongPoniterDownStep = function (sender)
    Add(self) 
  end

  self.btn_jian.event_PointerUp = function (sender)
    self.is_show = nil
  end
end


local function Create(tag)
  local ret = {MinNum = 1, Num = 1, MaxNum = 1}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

local function Set(self, t)
  self.MinNum = t.min or self.MinNum
  self.MaxNum = t.max or self.MaxNum
  self.TipMax = t.tip
  
  if t.item and type(t.item) == 'table' then
    Util.ShowItemShow(self.cvs_icon,t.item.icon,t.item.quality,1)
  end
  self.lb_title.Text = t.title or ''
  if t.txt and type(t.txt) == 'table' then
    self.tb_con1.XmlText = t.txt[1] or ''
    self.tb_con2.XmlText = t.txt[2] or ''
    self.tb_cost.XmlText = t.txt[3] or ''
  end
  self.ResultCallBack = t.cb
  self.ChangeCB = t.change_cb
  self.ExitCB = t.exit_cb
  SetNum(self,t.num or self.Num)
end

local function OnShowNumInputUI(eventname, params)
  local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUINumInput,-1)
  obj:Set(params)
end

local function initial()
  EventManager.Subscribe("Event.ShowNumInput", OnShowNumInputUI)
end

_M.Close = Close
_M.Create = Create
_M.initial = initial
_M.Set = Set

return _M
