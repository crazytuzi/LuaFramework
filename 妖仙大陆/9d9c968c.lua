local _M = {}
_M.__index = _M

local SceneMapUtil      = require "Zeus.UI.XmasterMap.SceneMapUtil"
local ChatUtil  		= require "Zeus.UI.Chat.ChatUtil"

local function RcvPointNode(name, node, self)
	table.insert(self.pointNode[name], node)
end

local function GetPointNode(name, self)
	local point = nil
	point = self.scenemapInfo.cvs_enemy3:Clone()
	SceneMapUtil.InitNodeLayout(point, name)
	return point
end

local function AddPoint(pData, anchor, colortype, self)
	local point = GetPointNode(pData.icon, self)
	point:RemoveAllChildren(true)
	local textdes = self.scenemapInfo.lb_leadname:Clone()
	if pData.name ~= nil then
		textdes.Text = pData.name
		textdes.FontColor = CommonUnity3D.UGUI.UIUtils.UInt32_ARGB_To_Color(SceneMapUtil.chatcolor["colortype" .. colortype])
	else
		textdes.Text = ""
	end
	textdes.Y = 30
	textdes.X = -(textdes.Width - point.Width)/ 2
	point:AddChild(textdes)
	point.TouchClick = function()
		
		if self.nodeCallBack ~= nil then
			self.nodeCallBack(pData)
		end
	end
	if point == nil then
		return
	end
	
	point.Visible = true
	self.scenemapInfo.cvs_dotaera:AddChild(point)
	SceneMapUtil.SetPointPos(point, pData.x, pData.y, anchor, self.mapInfo)
	return point
end

local function InitUI(ui, node)
    local UIName2 = {
        "cvs_enemy3",
        "lb_leadname", 
        "cvs_dotaera", 
        "lb_mapname",
    }

    for i = 1, #UIName2 do
        ui[UIName2[i]] = node:FindChildByEditName(UIName2[i], true)
        ui[UIName2[i]].Visible = false
    end
    ui.lb_mapname.Visible = true
end

local function InitInfoList(data, self, colortype)
	
	local num = #data
	local list = {}
	
	for i=1,num do
		local pData = data[i]
		list[i] = AddPoint(pData, SceneMapUtil.pointAnchor.center, colortype, self)
	end
	return list
end

local function ClearTeamNode(self)
	
	for i = 1, #self.TeamNode do
		self.TeamNode[i].node.Visible = false
	end
end

local function GetTeamNode(data, self, colortype)
	
	for i = 1, #self.TeamNode do
		if self.TeamNode[i].id == data.id then
			self.TeamNode[i].node.Visible = true
			return self.TeamNode[i].node
		end
	end
	local point = {}
	point.id = data.id
	point.node = GetPointNode("#dynamic_n/dynamic_new/map/map.xml|map|3", self)
	point.node.Enable = false
	point.node.Size2D = Vector2.New(11,11)
	self.TeamNode[#self.TeamNode + 1] = point
	self.scenemapInfo.cvs_dotaera:AddChild(point.node)

	local textdes = self.scenemapInfo.lb_leadname:Clone()
	if data.name ~= nil then
		textdes.Text = data.name
		textdes.FontColor = CommonUnity3D.UGUI.UIUtils.UInt32_ARGB_To_Color(SceneMapUtil.chatcolor["colortype" .. colortype])
	else
		textdes.Text = ""
	end
	textdes.Y = 15
	textdes.X = -(textdes.Width - point.node.Width)/ 2
	point.node:AddChild(textdes)

	return point.node
end

function _M.SetMonsterData(data, self)
	for i = 1, #self.monsterNode do 
		self.monsterNode[i].Visible = false
	end
	if data.s2c_monsterInfos == nil then
		return
	end
	for i = 1, #data.s2c_monsterInfos do
		local  stringnum = tostring(data.s2c_monsterInfos[i])
		for j = 1, #self.mapData.monsterList do
			
			if stringnum == self.mapData.monsterList[j].sid then
				self.monsterNode[j].Visible = true
			end
		end
	end
end

function _M.InitInfo(data, self)
	self.mapInfo = {}
	self.mapInfo.name = data.name
	self.mapInfo.mapW = data.mapW
	self.mapInfo.mapH = data.mapH
	self.mapInfo.imgBoxW = self.scenemapInfo.cvs_dotaera.Width
	self.mapInfo.imgBoxH = self.scenemapInfo.cvs_dotaera.Height
	
	self.mapInfo.scaleX = data.mapW > data.mapH and self.mapInfo.imgBoxW / self.mapInfo.mapW or self.mapInfo.imgBoxH / self.mapInfo.mapH
	self.mapInfo.scaleY = self.mapInfo.scaleX
	
	self.mapData = data

	self.mapInfo.imgOffX = data.mapW > data.mapH and 0 or (self.mapInfo.imgBoxW - self.mapInfo.imgBoxH * data.mapW / data.mapH) / 2
	self.mapInfo.imgOffY = data.mapH > data.mapW and 0 or (self.mapInfo.imgBoxH - self.mapInfo.imgBoxW * data.mapH / data.mapW) / 2

	self.scenemapInfo.lb_mapname.Text = self.mapInfo.name

	
	
	
	self.monsterNode = InitInfoList(data.monsterList, self, 8)
	
	InitInfoList(data.otherList, self, 7)
end


function _M.ShowRegion(self)
	local data = DataMgr.Instance.RegionManager:AllRegions()
	for i = 1, data.Count do
		if (data[i-1].Attributes ~= nil and data[i-1].Attributes.Length > 0 and data[i-1].Attributes[0] == "type_transfer") then
            AddPoint("cvs_home", i, data[i-1].X, data[i-1].Y, SceneMapUtil.pointAnchor.center, nil, nil, self)
		end
	end
end

function _M.UpdateTeamMembersPos(data, self)
	
	ClearTeamNode(self)
	for i = 1, #data do
		
		
			
		local teamdata
		if not IsNil(GameSceneMgr.Instance.BattleRun.BattleClient) then
			teamdata = GameSceneMgr.Instance.BattleRun.BattleClient:GetPlayerUnitByUUID(data[i].id)
		end

		if teamdata ~= nil and teamdata.X and teamdata.Y then
			
			SceneMapUtil.SetPointPos(GetTeamNode(data[i], self, 4), teamdata.X, teamdata.Y, SceneMapUtil.pointAnchor.center, self.mapInfo)
		end
		
	end
end


function _M.InitSceneMapInfo(self, node, nodeCallBack)
	self.scenemapInfo = {}
	self.pointNode = {}
	self.TeamNode = {}
	self.monsterNode = {}
	self.nodeCallBack = nodeCallBack
	InitUI(self.scenemapInfo, node)
	self.scenemapInfo.cvs_dotaera.Visible = true
end

function _M.OnExitMapInfo(self)
	self.scenemapInfo.cvs_dotaera:RemoveAllChildren(true)
	self.TeamNode = {}
	self.monsterNode = {}
end

return _M
