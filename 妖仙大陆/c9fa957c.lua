local _M = {}
_M.__index = _M
local SceneMapUtil      	= require "Zeus.UI.XmasterMap.SceneMapUtil"
local Util     				= require "Zeus.Logic.Util"
local ChatUtil              = require "Zeus.UI.Chat.ChatUtil"
local ExchangeUtil          = require "Zeus.UI.ExchangeUtil"
local MapModel 				= require 'Zeus.Model.Map'

local function HandleSendMap(id, str)
    GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL, 
        "<f>" .. str .. "</f>",
        nil,
        nil,
        Util.GetText(TextConfig.Type.FRIEND,'delivery'),
        nil,
        function()
        	MapModel.transByAreaIdRequest(id, function(params)
        		
        		UnityEngine.PlayerPrefs.SetString("DateTimeChangeMap", System.DateTime.Now)
        	end)
        end,
        nil
    )
end

local function OnMapClick(ThirdSenceId, self, mapdata)
    
    
    if self.callBack ~= nil then
        self.callBack(ThirdSenceId, mapdata)
        
        return
    end
    

















































end

local function InitLockMsg(lb_lock, data)
	if data.state == 1 then
        lb_lock.Text = Util.GetText(TextConfig.Type.MAP,'now_map')   
    elseif data.state == 2 then
        
        lb_lock.Text = ""
    elseif data.state == 3 then           
        lb_lock.Text = data.ReqLevel .. Util.GetText(TextConfig.Type.MAP,'lv')  
    elseif data.state == 4 then
        local search_t = {UpOrder = data.ReqUpLevel}
        local ret = GlobalHooks.DB.Find('UpLevel',search_t)
        if ret ~= nil and #ret > 0 then
            lb_lock.Text = ret[1].UpName
            data.UpName = ret[1].UpName
            lb_lock.Visible = true
        else
            lb_lock.Visible = false
        end  
    elseif data.state == 5 then  
        lb_lock.Text = Util.GetText(TextConfig.Type.MAP,'no_open')  
    end

end

local self = {
	menu = nil,
}

local function InitSecondMapUI(ui, node, mapIndex)
    for i = 1, #SceneMapUtil.secondMapSetting[mapIndex][1] do
        
    	local btnName = "ib_worldmap" .. SceneMapUtil.secondMapSetting[mapIndex][1][i]
        
    	
        ui[btnName] = node:FindChildByEditName(btnName, true)
        
        
        
        local ThirdSenceId = ui[btnName].UserData
        
        local data = GlobalHooks.DB.Find('Map.NormalMap',{MapID = tonumber(ThirdSenceId)})[1]
        
        if data ~= nil then
            local search_t = {MapID= tonumber(ThirdSenceId)}
            data.ret = GlobalHooks.DB.Find('Map.NormalMap',search_t)
            if data.AllowedTransfer == 1 then
                if DataMgr.Instance.UserData.SceneId == tonumber(data.MapID) then
                    data.state = 1 
                else
                    
                    if DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0) < data.ReqLevel then
                        data.state = 3   
                    elseif DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL) < data.ReqUpLevel then
                        data.state = 4   
                    else
                        data.state = 2   
                    end
                end
            else
                data.state = 5   
            end
            
            

            ui[btnName].TouchClick = function( ... )
            	
            	
            	OnMapClick(ThirdSenceId, self, data)
            end
        end
    end

    ui.mapbgList = {}
    for i = 1, #SceneMapUtil.secondMapSetting[mapIndex][2] do
        ui.mapbgList[i] = node:FindChildByEditName(SceneMapUtil.secondMapSetting[mapIndex][2][i], true)
    end
end

local function OnClickTeamNumber(data)
	
	
	local InteractiveMenu = require "Zeus.UI.InteractiveMenu"
    EventManager.Fire("Hud.Team.Event.ShowInteractive", {
        type= DataMgr.Instance.TeamData:IsLeader() and "cfg_team_leader" or "cfg_team",
        id = data.id,
        name = data.name,
        level = data.level,
        pro = data.pro,
    })
end

local function InitTeamInfoItem(node, data, isSelf)
	
	local ui = node:FindChildByEditName("cvs_headinfo", true)
	ui:RemoveAllChildren(true)
	if isSelf == true or data ~= nil then
		local pos = 0
		ui.Visible = true
		if isSelf == true then
			local ib_selfhead = node:FindChildByEditName("ib_selfhead", true)
			ib_selfhead:AddChild(self.ib_selfheadPos)
            self.ib_selfheadPos.Visible = true
		end
		if data ~= nil then
			for i = 1, #data do
				local headnode = self.cvs_teamhead:Clone()
				local ib_headicon = headnode:FindChildByEditName("ib_headicon", true)
        		Util.HZSetImage(ib_headicon, "static_n/hud/target/" .. data[i].pro .. ".png", false)
				headnode.X = pos + headnode.Width * (i - 1)
				headnode.TouchClick = function( ... )
					
					OnClickTeamNumber(data[i])
				end
				ui:AddChild(headnode)
				if data[i].status ~= 3 then
					headnode.IsGray = false
				else
					headnode.IsGray = true
				end
			end
		end
	else
		ui.Visible = false
	end
end

local function InitTeamInfo(mapIndex, ui)
	
	self.teamData = {}
	local teamData = SceneMapUtil.DealTeamList()
	for i = 1, #teamData do
		if self.teamData["" .. teamData[i].areaId] == nil then
			self.teamData["" .. teamData[i].areaId] = {}
		end
		table.insert(self.teamData["" .. teamData[i].areaId], teamData[i])
	end

	for i = 1, #SceneMapUtil.secondMapSetting[mapIndex][1] do
		local areaId = tonumber(SceneMapUtil.secondMapSetting[mapIndex][1][i])
		local node = ui["cvs_" .. areaId]
    	if node ~= nil then
    		local data = self.teamData["" .. areaId]
    		
			if areaId == DataMgr.Instance.UserData.SceneId then
				
				InitTeamInfoItem(node, data, true)
			else
				
				InitTeamInfoItem(node, data, false)
			end
		end
	end
end

local function RefreshSecondMapUI(ui)
	
	if self.mapData.s2c_mapIds == nil then
		return
	end
	for i = 1, #self.mapData.s2c_mapIds do
		local node = ui["cvs_" .. self.mapData.s2c_mapIds[i]]
    	if node ~= nil then
    		local lb_lock = node:FindChildByEditName("lb_lock", true)
    		lb_lock.Visible = false
    	end
    end
end


local function UpdateMapBgShow()
	
	for i = 1, #self.mapbgList do
		local x = self.mapbgList[i].X + self.sp_worldmapinfo.Scrollable.Container.X
		local y = self.mapbgList[i].Y + self.sp_worldmapinfo.Scrollable.Container.Y
		
		if x + self.mapbgList[i].Width < 0 or y + self.mapbgList[i].Height < 0 
			or x > self.sp_worldmapinfo.Scrollable.ScrollRect2D.width or y > self.sp_worldmapinfo.Scrollable.ScrollRect2D.height then
			self.mapbgList[i].Visible = false
		else
			self.mapbgList[i].Visible = true
		end
	end
end

local function Notify(status, userdata, opt)
	local mapIndex = tonumber(self.menu.ExtParam)
	
end

local function OnExit()
	
	RemoveUpdateEvent("Event.UI.SceneMapUSecond.Update", true)
	DataMgr.Instance.TeamData:DetachLuaObserver(GlobalHooks.UITAG.GameUITeamInfo)
end

local function OnEnter()
	
	
	
	
	
	
    
	local mapIndex = tonumber(self.menu.ExtParam)
	InitSecondMapUI(self, self.menu, mapIndex)
	
	
	
	
	
	
	
	
	
	
	
	
	
    

    

    AddUpdateEvent("Event.UI.SceneMapUSecond.Update", function(deltatime)
		
	end)
    MapModel.getMapListRequest(SceneMapUtil.secondMapSetting[mapIndex][3], function(params)
		
		
		self.mapData = params
		
	end)
	
	DataMgr.Instance.TeamData:AttachLuaObserver(GlobalHooks.UITAG.GameUITeamInfo, {Notify = Notify})
end

local function OnClickReturn( ... )
	
	if self.callBack ~= nil then
		self.callBack()
		
	end
end

local function InitUI(ui, node)
	local UIName = {
        "btn_return",
        "cvs_firstlevel",


    }


    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function InitCompnent(params)
	InitUI(self, self.menu)
	self.btn_return.TouchClick = OnClickReturn
	self.btn_return.Visible = true
	

	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory(function()
		
        self = nil
    end)
end

local function Init(params)
	
	self.menu = LuaMenuU.Create("xmds_ui/map/map_firstlevel.gui.xml", GlobalHooks.UITAG.GameUISceneMapUSecond)
	self.menu.Enable = false
	
	InitCompnent(params)
	return self.menu
end

local function Create(params)
	self = {}
	setmetatable(self, _M)
	local node = Init(params)
	return self
end


local function initial()
	print("SceneMap.initial")
end

return {Create = Create, initial = initial}
