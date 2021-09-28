

local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local EventDetail = require 'Zeus.UI.EventItemDetail'
local self = {menu = nil,}

function AddLeftEquipChoosePart(self)
	if self.left_choose_part_menu == nil then
	  local menu,obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIEquipReworkLeftChoose,-1)
	  self.left_choose_part = obj
	  self.left_choose_part_menu = menu
	  menu.Visible = true
	  self.cvs_main_left:RemoveAllChildren(true)
	  self.cvs_main_left:AddChild(menu)
	
	
	 self.left_choose_part:SetReWorkMain(self)
	end
  
end

function AddRightTogglePart(self)
  if self.right_toggle_menu == nil then
	local menu,obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIEquipReworkRightToggle,-1)
	 self.right_toggle_part = obj
	 self.right_toggle_menu = menu
	 menu.Visible = true
	 self.cvs_main_right:RemoveAllChildren(true)
	 self.cvs_main_right:AddChild(menu)
	
	 self.right_toggle_part:SetReWorkMain(self,self.defaultOpenPage)
  end
end


local function OnBuySuccess()
	if self.right_toggle_part ~= nil then
		self.right_toggle_part:OnBuySuccess()
	end
end

local function OnUpdateRedPoint(self,status,flagData)
	if self.right_toggle_part ~= nil then
    	self.right_toggle_part:OnUpdateRedPoint(status,flagData)
    end
end

local ui_names = 
{
	{name = 'cvs_main_left'},
	{name = 'cvs_main_right'},
	{name = 'cvs_main_center'},
    {name = 'cvs_main_build'},
	{name = 'btn_close'},
	{name = 'lb_title'},
}

local function OnEnter()
  AddLeftEquipChoosePart(self)
  AddRightTogglePart(self)
  EventManager.Subscribe("Event.ShopMall.BuySuccess",OnBuySuccess)
  DataMgr.Instance.FlagPushData:AttachLuaObserver(self.menu.Tag, self)
end

local function OnExit()
  	if self.right_toggle_part ~= nil then
		self.right_toggle_part:OnExit()
	end
end

local function Close()
	EventManager.Unsubscribe("Event.ShopMall.BuySuccess", OnBuySuccess)
	DataMgr.Instance.FlagPushData:DetachLuaObserver(self.menu.Tag)
  	self.menu:Close()  
end

function _M.Notify(status, flagData,self)
    if self ~= nil and self.menu ~= nil then
        OnUpdateRedPoint(self,status,flagData)
    end
end

local function InitComponent(tag,params)
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_main.gui.xml",tag)
  self.menu.ShowType = UIShowType.HideBackHud
  
  self.defaultOpenPage = params

  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  
  self.btn_close.TouchClick = function (sender)
      Close(self)
    end

	self.menu:SubscribOnEnter(function ()
		OnEnter(self)
	end)
    self.menu:SubscribOnExit(function ()
	OnExit(self)
	end)

    
    
end

local function Create(tag,params)
  self = {}
  setmetatable(self, _M)
  InitComponent(tag,params)
  return self
end

_M.Create = Create
_M.Close  = Close
return _M
