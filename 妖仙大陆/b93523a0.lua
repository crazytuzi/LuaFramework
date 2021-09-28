

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local _M = {}
_M.__index = _M

local function Close(self)
  self.menu:Close()  
end



local Text = {
  
}

local function OnEnter(self)
  
end

local function OnExit(self)
  
end

local function OnDestory(self)
  
end

local ui_names = 
{
	{name = 'cvs_main'},
	{name = 'btn_yes',click = Close},
	{name = 'lb_number'},
	{name = 'ib_getnum'},
	{name = 'lb_goodsname'},
	{name = 'ib_cover'},
	{name = 'ib_under'},
	{name = 'ib_title'},
	{name = 'ib_fishicon'},
	{name = 'ib_colourful'},
}

local function Set(self,params)
	self.items = params.items

	local item = self.items[1]
	local detail = ItemModel.GetItemDetailByCode(item.code)
	local it = Util.ShowItemShow(self.ib_fishicon,detail.static.Icon,detail.static.Qcolor)
	MenuBaseU.SetEnableUENode(self.ib_fishicon,false,true)
	it.EnableTouch = true
	it.TouchClick = function (sender)
		detail.bindType = item.bindType or detail.bindType
		EventManager.Fire('Event.ShowItemDetail',{data=detail,button1='Event.CloseItemDetail'})
	end
	self.lb_goodsname.Text = detail.static.Name
	self.lb_goodsname.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)
	self.ib_getnum.Text = item.groupCount

end


local function InitComponent(self,tag)
	
	self.menu = LuaMenuU.Create('xmds_ui/common/common_fish.gui.xml',tag)
	Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
  end)
  self.menu.ShowType = UIShowType.Cover
end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

local function OnGameUIFishItem(eventname,params)
	if params and params.items and #params.items > 0 then
		if #params.items == 1 then
	  	local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFishItem,0)
	  	Set(obj,params)
	  else
	  	EventManager.Fire('Event.OnShowNewItems',{items=params.items})
	  end
	end
end

local function initial()
	EventManager.Subscribe("Event.UI.GameUIFishItem", OnGameUIFishItem)	
end

_M.Create = Create
_M.Close  = Close
_M.initial = initial
return _M
