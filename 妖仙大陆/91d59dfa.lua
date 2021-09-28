local _M = {}
_M.__index = _M
local NPC               = require 'Zeus.Model.Npc'
local Util              = require "Zeus.Logic.Util"
local SceneMapUtil      = require "Zeus.UI.XmasterMap.SceneMapUtil"
local SceneMapSeekPath  = require "Zeus.UI.XmasterMap.SceneMapSeekPath"

local SceneMapInfo   	= require "Zeus.UI.XmasterMap.SceneMapInfo"
local SceneMapQuickdelivery = require "Zeus.UI.XmasterMap.SceneMapQuickdelivery"
local MapModel          = require 'Zeus.Model.Map'

local self = {
	menu = nil,
	sceneId = nil,
	selectIndex = nil,
	mapInfo = nil,
}

local function InitInfoList()
	SceneMapInfo.InitInfo(self.mapData, self)
	if self.mapData.monsterList ~= nil and #self.mapData.monsterList > 0 and self.mapData.monsterList[1].sid ~= nil then
		MapModel.getAliveMonsterLineInfoRequest(function(params)
			
			
			
			if self ~= nil and self.menu ~= nil then
				SceneMapInfo.SetMonsterData(params, self)
			end
		end)
	end
	
	
	
	
	

	self.TeamData = SceneMapUtil.DealTeamList()
end

local function InitUI(ui, node)
	local UIName = {
        "cvs_scenemap",
        "lb_mapname",
        "cvs_dotaera", 
        "cvs_role",
        "btn_return",
        "cvs_rolehead",
        "ib_transferpoint",
        "btn_ditufenxian",
        "lb_mapName",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function OnClickReturn( ... )
	
	if self.callBack ~= nil then
		self.callBack()
		
	end
end

local function InitSceneMap()
	InitUI(self.scenemapself, self.menu)

	
	SceneMapQuickdelivery.Init(self, self.menu)
	SceneMapSeekPath.InitSeekPath(self, self.menu)
	SceneMapInfo.InitSceneMapInfo(self, self.menu, function(params)
		
		
		if self.sceneId == DataMgr.Instance.UserData.SceneId then
			SceneMapSeekPath.SeekPath(params.x, params.y, nil, self)
		else
			SceneMapQuickdelivery.OnClickByScene(self.sceneId, self, function(changetype)
				
                DataMgr.Instance.QuestManager.autoControl.AutoQuest = nil;
                GameSceneMgr.Instance.BattleRun.BattleClient:StopSeek()
                DataMgr.Instance.UserData:StopSeek()
                EventManager.Fire("Event.Delivery.Close", {});
				if changetype == nil then
					DataMgr.Instance.UserData:StartSeekAfterChangeScene(self.sceneId, params.x, params.y)
				else
					DataMgr.Instance.UserData:Seek(self.sceneId, params.x, params.y)
				end
				MenuMgrU.Instance:CloseAllMenu()
			end)
		end
	end)

	self.scenemapself.btn_return.TouchClick = OnClickReturn
    self.scenemapself.btn_ditufenxian.TouchClick = function()
        EventManager.Fire("Event.OnShowChangeLineMenu", {})
    end
	LuaUIBinding.HZPointerEventHandler({node = self.scenemapself.cvs_dotaera, click = function (displayNode, pos)
        DataMgr.Instance.QuestManager.autoControl.AutoQuest = nil;
        GameSceneMgr.Instance.BattleRun.BattleClient:StopSeek()
        DataMgr.Instance.UserData:StopSeek()
        EventManager.Fire("Event.Delivery.Close", {})
		local tp = displayNode:ScreenToLocalPoint2D(pos)
		local smallMapX = (tp.x - self.mapInfo.imgOffX) / self.mapInfo.scaleX
		local smallMapY = (tp.y - self.mapInfo.imgOffY) / self.mapInfo.scaleY
		if self.sceneId == DataMgr.Instance.UserData.SceneId then
			
			if smallMapX>0 and smallMapY>0 then
				SceneMapSeekPath.SeekPath(smallMapX, smallMapY, nil, self)
			end
		else
			SceneMapQuickdelivery.OnClickByScene(self.sceneId, self, function(changetype)
				
				if changetype == nil then
					if smallMapX>0 and smallMapY>0 then
						DataMgr.Instance.UserData:StartSeekAfterChangeScene(self.sceneId, smallMapX, smallMapY)
					end
				else
					if smallMapX>0 and smallMapY>0 then
						DataMgr.Instance.UserData:Seek(self.sceneId, smallMapX, smallMapY)
					end
				end
				MenuMgrU.Instance:CloseAllMenu()
			end)
		end
    end})

end

local function ShowSceneMap()
	

	self.sceneId = tonumber(self.menu.ExtParam)
	local mapDetail = GlobalHooks.DB.Find("Map", self.sceneId)
	if mapDetail == nil then
		if self.sceneId == DataMgr.Instance.UserData.SceneId then
			mapDetail = GlobalHooks.DB.Find("Map", DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.MAPID)) or {}
		else
			mapDetail = {}
		end
	end
	if mapDetail.SceneSmallMap ~= nil then
		Util.HZSetImage(self.scenemapself.cvs_scenemap, "dynamic_n/map/scenemap/" .. mapDetail.SceneSmallMap .. ".png", false)
	else
		
		GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "maperror"))
	end
    self.listTransport = {}
    local data = DataMgr.Instance.RegionManager:AllRegions()
    local ib_transferpoint = self.scenemapself.ib_transferpoint
    for i = 1, data.Count do
		if (data[i-1].Attributes ~= nil and data[i-1].Attributes.Length > 0 and data[i-1].Attributes[0] == "type_transfer") then
            local point = ib_transferpoint:Clone()
            point.X = data[i-1].X
            point.Y = data[i-1].Y
            point.Visible = true
            self.scenemapself.cvs_scenemap:AddChild(point)
            table.insert(self.listTransport,point)


		end
	end

	
	
	
	
	self.mapData = SceneMapUtil.GetSceneSnapData(self.sceneId)

	SceneMapQuickdelivery.SetNpcData(self, self.mapData.npcList)
	SceneMapSeekPath.ClearSeekPathPoint(self)
	InitInfoList()
	Util.HZSetImage(self.scenemapself.cvs_rolehead, "static_n/hud/target/" .. DataMgr.Instance.UserData.Pro .. ".png", false)
    local lineText = Util.GetText(TextConfig.Type.MAP,'lineLua') 
    lineText = string.format(lineText,GameSceneMgr.Instance.SceneLineIndex)
    self.scenemapself.lb_mapName.Text = DataMgr.Instance.UserData.SceneName ..  "(" .. lineText .. ")"
    
end

local function Notify(status, userdata, opt)
	self.TeamData = SceneMapUtil.DealTeamList()
end

local function OnExit()
	
    RemoveUpdateEvent("Event.UI.SceneMapU.Update", true)
    
    SceneMapSeekPath.OnExitSeekPath(self)
    SceneMapInfo.OnExitMapInfo(self)
    SceneMapQuickdelivery.OnExit(self)
    DataMgr.Instance.TeamData:DetachLuaObserver(GlobalHooks.UITAG.GameUITeamInfo)
end

local function OnEnter()
	ShowSceneMap()
	self.timeCount = 0
	if self.sceneId == DataMgr.Instance.UserData.SceneId then
		self.scenemapself.cvs_role.Visible = true
		AddUpdateEvent("Event.UI.SceneMapU.Update", function(deltatime)
			SceneMapSeekPath.UpdateMyPos(self.scenemapself.cvs_role, self)
			self.timeCount = self.timeCount + 1
			if self.timeCount >= 10 then
				self.timeCount = 0
				SceneMapInfo.UpdateTeamMembersPos(self.TeamData, self)
			end
		end)
	else
		self.scenemapself.cvs_role.Visible = false
		SceneMapInfo.UpdateTeamMembersPos({}, self)
	end
	DataMgr.Instance.TeamData:AttachLuaObserver(GlobalHooks.UITAG.GameUITeamInfo, {Notify = Notify})
	SceneMapSeekPath.OnEnterSeekPath(self)
	SceneMapQuickdelivery.OnEnter(self)

	local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
	self.scenemapself.btn_return.Visible = sceneType == PublicConst.SceneType.Normal or sceneType == PublicConst.SceneType.CrossServer
end

local function InitCompnent(params)
	self.scenemapself = {}
	InitSceneMap()

	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
	
	self.menu = LuaMenuU.Create("xmds_ui/map/map_thirdlv.gui.xml", GlobalHooks.UITAG.GameUISceneMapUThird)
	self.menu.Enable = false
	self.menu.ShowType = UIShowType.Cover
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
	
end

return {Create = Create, initial = initial}
