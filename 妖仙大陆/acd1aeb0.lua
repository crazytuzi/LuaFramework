

local Helper    = require 'Zeus.Logic.Helper'
local Util      = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local _M = {}
_M.__index = _M

local MAX_COLUMNS = 2
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
  
  {name = 'btn_yes',click = Close},
  {name = 'sp_see'},
  {name = 'lb_qiao'},
  {name = 'cvs_prop'},
  
}

local function InitComponent(self,tag)
	
	self.menu = LuaMenuU.Create('xmds_ui/common/common_get_normal.gui.xml',tag)
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

  self.cvs_prop.Visible = false
  local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
  self.menu:SetFullBackground(lrt)
end

local function UpdateEachItem(self,node,index)
	local item = self.items[index]
	if not item then
		node.Visible = false
	else
		node.Visible = true
		local cvs_icon = node:FindChildByEditName('cvs_icon',false)
		local lb_propname = node:FindChildByEditName('lb_propname',false)
		local lb_number = node:FindChildByEditName('lb_number',false)
		local tbt_bg = node:FindChildByEditName('tbt_bg',false)

		local detail = ItemModel.GetItemDetailByCode(item.code)
		local itshow = Util.ShowItemShow(cvs_icon,detail.static.Icon,detail.static.Qcolor)

		cvs_icon.Enable = false

		tbt_bg.TouchClick = function (sender)
			if sender.IsChecked then
				detail.bindType = item.bindType or detail.bindType
				EventManager.Fire('Event.ShowItemDetail',
					{data=detail,button1='Event.CloseItemDetail',
						cb=function(d,eventname,param)
							if eventname == 'Event.OnExit' then
								tbt_bg.IsChecked = false
							end
						end
					})
			end
		end

		lb_propname.Text = item.name or detail.static.Name
		lb_propname.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)
		lb_number.Text = item.groupCount
	end

end

local function Set(self,params)

	self.items = params.items
	local max_rows = math.floor(#self.items / MAX_COLUMNS)
	if #self.items % MAX_COLUMNS ~= 0 then
		max_rows = max_rows + 1
	end
	if self.sp_see.Rows <= 0 then
		local cellW = self.sp_see.Width / MAX_COLUMNS
		self.sp_see:Initialize(cellW-8,self.cvs_prop.Height-10,max_rows,MAX_COLUMNS,self.cvs_prop,
		function (gx,gy,node)
			UpdateEachItem(self,node,gy * MAX_COLUMNS + gx + 1)
		end,function ()	end)
	else
		self.sp_see.Rows = max_rows
	end

	if params.title then
		self.lb_qiao.Text = params.title
	end
end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

_M.Create = Create
_M.Close  = Close

_M.Set = Set
return _M
