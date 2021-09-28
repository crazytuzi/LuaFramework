local _M = {}
_M.__index = _M

local SceneMapUtil      = require "Zeus.UI.XmasterMap.SceneMapUtil"

local self = {
	menu = nil,
}

local function MapNameInit(typeIndex, mapindex)
	
	self.typeIndex = typeIndex
	local str = {
		ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "shijieditu"),
		ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "adlsdalu"),
	}
	if typeIndex == 3 then
		
		self.lb_worldname.Text = self.mapname
	else
		self.lb_worldname.Text = str[typeIndex]
	end
end

local function OnExit()
	
    self.menu:RemoveAllSubMenu()
end

function _M.SecondMapCallBack(ThirdSenceId, mapdata)
	
	print("SecondMapCallBack")
	if ThirdSenceId ~= nil and ThirdSenceId ~= DataMgr.Instance.UserData.SceneId then 
		
		SceneMapUtil.OnMapClick(ThirdSenceId, mapdata, function (changetype)
            
            if changetype ~= nil then
                
                
                
                DataMgr.Instance.UserData:StartSeek(tonumber(ThirdSenceId), "born", 0, "")  
            end
        end)
	else
		self.menu:RemoveAllSubMenu()
		local node,lua_obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUISceneMapUThird, 0, DataMgr.Instance.UserData.SceneId)
		MapNameInit(3)
		lua_obj.callBack = _M.ThirdMapCallBack
		self.menu:AddSubMenu(node)
    end
end

function _M.ThirdMapCallBack( ... )
	
	if self.menu ~= nil then
		self.menu:RemoveAllSubMenu()
		local node,lua_obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUISceneMapUSecond, -1, SceneMapUtil.GetMapIndexBySceneId(DataMgr.Instance.UserData.SceneId))
		MapNameInit(2)
	    lua_obj.callBack = _M.SecondMapCallBack
	    self.menu:AddSubMenu(node)
	else
		print(PrintTable(self))
	end
end

local function OnEnter()

    self.mapname = DataMgr.Instance.UserData.SceneName
    local node,lua_obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUISceneMapUThird, 0, DataMgr.Instance.UserData.SceneId)
    MapNameInit(3)
    lua_obj.callBack = _M.ThirdMapCallBack
    self.menu:AddSubMenu(node)
end

local function InitCompnent(params)
	local btn_close = self.menu:GetComponent('btn_close')
	btn_close.TouchClick = function()
		
		self.menu:Close()
	end

	local btn_back = self.menu:GetComponent('btn_back')
	btn_back.TouchClick = function()
		
		
		if self.typeIndex == 2 then
			_M.SecondMapCallBack(DataMgr.Instance.UserData.SceneId)
		else
			self.menu:Close()
		end
	end

	self.lb_worldname = self.menu:GetComponent('lb_worldname')

	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
	
	self.menu = LuaMenuU.Create("xmds_ui/map/map_main.gui.xml", GlobalHooks.UITAG.GameUISceneMapU)

	self.menu.ShowType = UIShowType.HideBackHud
	InitCompnent(params)
	return self.menu
end

local function New()
	self = {}
	return setmetatable(self, _M)
end

local function Create(params)
	New()
	local node = Init(params)
	return node
end


local function initial()
	
end

return {Create = Create, initial = initial}
