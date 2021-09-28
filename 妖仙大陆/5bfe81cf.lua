
local Util      = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local _M = {}
_M.__index = _M


local Text = {
  
}

local MAX_COLUMNS = 4

local Deafult_Pos_X = {180,125,80,15}

local function AddScaleAction(self, node, scale, duration, cb)
  local scaleAction = ScaleAction.New()
  scaleAction.ScaleX = scale
  scaleAction.ScaleY = scale
  scaleAction.Duration = duration
  node:AddAction(scaleAction)
  scaleAction.ActionFinishCallBack = cb
end

local function Close(self)
  self.btn_close.Enable = false
  self.btn_yes.Enable = false
  AddScaleAction(self, self.cvs_scale, 1.1, 0.15, function()
    AddScaleAction(self, self.cvs_scale, 0.5, 0.2, function()
      RemoveLateUpdate("Event.GameUINewItems.Update", true)
      self.menu:Close()
    end)
  end)
end

local function DoScaleAction(self)
  local x = self.cvs_scale.X
  local y = self.cvs_scale.Y
  local w = self.cvs_scale.Width
  local h = self.cvs_scale.Height

  AddLateUpdate("Event.GameUINewItems.Update", function(dt)
    self.cvs_scale.X = x - (self.cvs_scale.Scale.x-1)*w/2
    self.cvs_scale.Y = y - (self.cvs_scale.Scale.y-1)*h/2
    end)

  AddScaleAction(self, self.cvs_scale, 0.25, 0.01, function()
    AddScaleAction(self, self.cvs_scale, 1.1, 0.2, function()
      AddScaleAction(self, self.cvs_scale, 1, 0.2, function()
        self.btn_close.Enable = true
        self.btn_yes.Enable = true
      end)
    end)
  end)
end

local function OnEnter(self)
  self.cvs_scale.X = 0
  self.cvs_scale.Y = 0
  self.cvs_scale.Scale = Vector3.New(1, 1, 1)
  self.btn_close.Enable = false
  self.btn_yes.Enable = false
  DoScaleAction(self)
end

local function OnExit(self)
	self.cvs_show1:RemoveAllChildren(true)
end

local function OnDestory(self)

end

local ui_names = 
{
  
  {name = 'btn_yes',click = Close},
  {name = 'btn_close',click = Close},
  {name = 'sp_show'},
  {name = 'cvs_show1'},
  {name = 'cvs_icon'},
  {name = 'cvs_scale'},
}

local function InitComponent(self,tag)
	
	self.menu = LuaMenuU.Create('xmds_ui/common/common_boxinfo.gui.xml',tag)
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

  self.cvs_icon.Visible = false
  self.canWidth = self.sp_show.Width
  self.nodeWidth = self.cvs_icon.Width
  local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
  self.menu:SetFullBackground(lrt)
end

local function UpdateEachItem(self,node,index)
	local item = self.items[index]
	if not item then
		node.Visible = false
	else
		node.Visible = true
		node:FindChildByEditName('lb_num',false).Text = item.groupCount
		local detail = ItemModel.GetItemDetailByCode(item.code)
		
		local ib_icon = node:FindChildByEditName('ib_icon',false)
		ib_icon.EnableChildren = true
		local itshow = Util.ShowItemShow(ib_icon,detail.static.Icon,detail.static.Qcolor)
		Util.NormalItemShowTouchClick(itshow,item.code,false)
	end
end

local function Set(self,params)
	self.items = params.items
	local columns = #self.items
	if columns > MAX_COLUMNS then
		self.sp_show:Initialize(self.cvs_icon.Width+20,self.cvs_icon.Height,1,columns,self.cvs_icon,
			function (gx,gy,node)
				UpdateEachItem(self,node,gx + 1)
			end,function ()	end)
		
	else
		for i=1,columns do
			local node = self.cvs_icon:Clone()
			UpdateEachItem(self,node,i)
			node.X = Deafult_Pos_X[columns] + (i-1)*110
			node.Y = 10
			self.cvs_show1:AddChild(node)
		end
	end
	self.sp_show.Visible = columns > 4
	self.cvs_show1.Visible = columns <= 4
end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

local function OnPreviewItems(eventname, params)
  local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPreviewItems,0)
  obj:Set(params)
end

local function initial()
  EventManager.Subscribe("Event.OnPreviewItems", OnPreviewItems)
end

_M.Create = Create
_M.Close  = Close
_M.initial = initial
_M.Set = Set
return _M
