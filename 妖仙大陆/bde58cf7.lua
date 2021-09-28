

local Helper = require'Zeus.Logic.Helper'
local Util = require'Zeus.Logic.Util'
local cjson = require"cjson"  
local PlayerModel = require 'Zeus.Model.Player'
local _M = {}
_M.__index = _M

local MAX_COLUMNS = 2

local Text = {
  mapName = Util.GetText(TextConfig.Type.MAP,'mapName'),
  lineNow = Util.GetText(TextConfig.Type.MAP,'lineNow'),
}

local function Close(self)
  self.menu:Close()  
end

local ui_names = 
{
	{name = 'btn_close',click = Close},
	{name = 'lb_name'},
	{name = 'lb_now'},
	{name = 'cvs_mapline'},
	{name = 'cvs_line'},
	{name = 'sp_star'},
}


local function UpdateEachItem(self, node, index)

	local item = self.data[index]
	if not item then
		node.Visible = false
		return
	end
	node.Visible = true
	local bt_choosesever = node:FindChildByEditName('bt_choosesever',false)
	local ib_redlight = node:FindChildByEditName('ib_redlight',false)
	local ib_greenlight = node:FindChildByEditName('ib_greenlight',false)
	local lb_line = node:FindChildByEditName('lb_line',false)
	lb_line.Text = Util.GetText(TextConfig.Type.MAP,'line',item.index)
	if item.state == 0 then
		lb_line.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Green)
	else
		lb_line.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
	end
	ib_greenlight.Visible = item.state == 0
	ib_redlight.Visible = not ib_greenlight.Visible
	bt_choosesever.TouchClick = function (sender)
		PlayerModel.RequestTransByInstanceId(item.instanceId)
		
	end
end











local function Set(self,data)

	
	self.lb_now.Text = ''

	self.lb_now.Text = Util.GetText(TextConfig.Type.MAP,'lineNow',GameSceneMgr.Instance.SceneLineIndex)
	
	
	
	
	
	
	
	self.data = data
	self.lb_name.Text = Util.GetText(TextConfig.Type.MAP,'mapName',DataMgr.Instance.UserData.SceneName)
	

	local max_rows = math.floor(#data / MAX_COLUMNS)
	if #data % MAX_COLUMNS ~= 0 then
		max_rows = max_rows + 1
	end
	if self.sp_star.Rows <= 0 then
		local cellW = self.sp_star.Width / MAX_COLUMNS
		self.sp_star:Initialize(cellW-8,self.cvs_line.Height-10,max_rows,MAX_COLUMNS,self.cvs_line,
		function (gx,gy,node)
			UpdateEachItem(self,node,gy * MAX_COLUMNS + gx + 1)
		end,function ()	end)
	else
		self.sp_star.Rows = max_rows
	end
end

local function OnEnter(self)
  
 
	
	
	
	
	
	
	
	
	
	PlayerModel.RequestMapLineInfo(function (data)
		Set(self,data)
	end)
	
end

local function OnExit(self)
  
end

local function OnDestory(self)
  
end


local function InitComponent(self,tag)
	self.menu = LuaMenuU.Create('xmds_ui/map/map_line.gui.xml',tag)
	
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

local function Create(tag,type_str)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag,type_str)
  return ret
end

local function OnShowChangeLineMenu(eventname,params)
    
    
    local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
    if sceneType == PublicConst.SceneType.Dungeon then return end

	if GameSceneMgr.Instance.SceneLineIndex == 0 then
		GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP,'lineWarn'))
	else
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChangeLine,0)
	end
end

local function initial()

	EventManager.Subscribe("Event.OnShowChangeLineMenu", OnShowChangeLineMenu)
end


_M.Create = Create
_M.initial = initial
_M.Close = Close

return _M
