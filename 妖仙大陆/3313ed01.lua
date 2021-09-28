local _M = {}
_M.__index = _M

local SceneMapUtil      = require "Zeus.UI.XmasterMap.SceneMapUtil"
local Util      		= require "Zeus.Logic.Util"

local function DealPath(path, length, scaleX, scaleY)
    local dealpath = {}
    local lastitem = {
        X = nil,
        Y = nil,
    }
    local item = {
        X = nil,
        Y = nil,
    }
    item.X = path[0].x * scaleX
    item.Y = path[0].y * scaleY
    lastitem.X = item.X 
    lastitem.Y = item.Y 
    table.insert(dealpath, item)

    if(path.Count == 1) then 
        return dealpath
    end

    for i = 2, path.Count do
        local curPoint = {}
        curPoint.X = path[i - 1].x * scaleX
        curPoint.Y = path[i - 1].y * scaleY
        local dx = curPoint.X - lastitem.X
        local dy = curPoint.Y - lastitem.Y

        local max_len = math.sqrt(dx * dx + dy * dy)
        local pointCount = math.ceil(max_len / length)
        local space = max_len / pointCount
        local cur_len = space

        while cur_len < max_len do
            local item = {
                X = nil,
                Y = nil,
            }
            local addx = dx * cur_len / max_len
            local addy = dy * cur_len / max_len
            item.X = lastitem.X + addx
            item.Y = lastitem.Y + addy

            cur_len = cur_len + space

            table.insert(dealpath, item)
        end
        table.insert(dealpath, curPoint)
        lastitem = curPoint
    end

    local item = {
        X = nil,
        Y = nil,
    }
    item.X = path[path.Count - 1].x * scaleX
    item.Y = path[path.Count - 1].y * scaleY
    table.insert(dealpath, item)

    return dealpath
end

local function DrawPathByPoint(path, node, parent, self)
	if(path == nil)then
		return
	end

	local dealpath = DealPath(path, 20, self.mapInfo.scaleX, self.mapInfo.scaleY)
	for i = 1, #dealpath do
		if(self.drawLine[i] == nil)then
			self.drawLine[i] = node:Clone()
			
			parent:AddChild(self.drawLine[i])
		end
		self.drawLine[i].Visible = true
		self.drawLine[i].X = dealpath[i].X + self.mapInfo.imgOffX - node.Width / 2
		self.drawLine[i].Y = dealpath[i].Y + self.mapInfo.imgOffY - node.Height / 2
	end

	for i = #dealpath, #self.drawLine do
		self.drawLine[i].Visible = false
	end

	self.drawLineTime = 0
end

local function DrawPathFadeOut(pos, length, self)
	
	local findnode = false
	local posx = pos.x * self.mapInfo.scaleX + self.mapInfo.imgOffX
	local posy = pos.y * self.mapInfo.scaleY + self.mapInfo.imgOffY
	

	for i = 1, #self.drawLine do
		if(self.drawLine[i].Visible == true)then
			findnode = true
			if(self.drawLine[i].X < posx + length * 0.2 and self.drawLine[i].X > posx - length * 0.2
				and self.drawLine[i].Y < posy + length * 0.2  and self.drawLine[i].Y > posy - length * 0.2)then
				for j = 1, i do
					self.drawLine[j].Visible = false
				end
			end
		end
	end
	return findnode
end

local function InitUI(ui, node)
	local UIName = {
        "cvs_mapinfoarror",
        "ib_mappoint",
        "cvs_scenemap",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function OnEnterGetPath(path, self)
	if self.sceneId == DataMgr.Instance.UserData.SceneId then
		if path ~= nil then
			SceneMapUtil.SetPointPos(self.scenemapSeekPath.cvs_mapinfoarror, path[path.Count - 1].x, path[path.Count - 1].y - 3, SceneMapUtil.pointAnchor.bottom, self.mapInfo)
			DrawPathByPoint(path, self.scenemapSeekPath.ib_mappoint, self.scenemapSeekPath.cvs_scenemap, self)

			self.scenemapSeekPath.cvs_mapinfoarror.Visible = true
		else
			self.scenemapSeekPath.cvs_mapinfoarror.Visible = false
			_M.ClearSeekPathPoint(self)
		end
	end
end

function _M.SeekPath(x, y, mdata, self)
	
	
	GameSceneMgr.Instance.BattleRun.BattleClient:StartSeek(x, y, 0, mdata)
end

function _M.ClearSeekPathPoint(self)
	
	for i = 1, #self.drawLine do
		self.drawLine[i].Visible = false
	end
end

function _M.UpdateMyPos(cvs_role, self)
	
	if self.mapInfo == nil then
		return
	end

	local pos = DataMgr.Instance.UserData.Position
	SceneMapUtil.SetPointPos(cvs_role, pos.x, pos.y, SceneMapUtil.pointAnchor.center, self.mapInfo)
	cvs_role.Visible = true

	if #self.drawLine > 0 then
		local findnode = DrawPathFadeOut(pos, 60, self)
		if findnode == false then
			if self.scenemapSeekPath.cvs_mapinfoarror.Visible then
				GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISceneMapU)
			end
			self.scenemapSeekPath.cvs_mapinfoarror.Visible = false
		end
		return findnode
	end
end

function _M.OnExitSeekPath(self, node)
	
	
	if self.scenemapSeekPath.cvs_choosenNode ~= nil then
		self.scenemapSeekPath.cvs_choosenNode.Visible = false
		self.scenemapSeekPath.cvs_choosenNode = nil
	end
	self.scenemapSeekPath.cvs_mapinfoarror.Visible = false
	DataMgr.Instance.UserData.seekPathChange = nil
end

function _M.OnEnterSeekPath(self)
	
	OnEnterGetPath(DataMgr.Instance.UserData.Seekpath, self)
	DataMgr.Instance.UserData.seekPathChange = function(path)
		
		OnEnterGetPath(path, self)
	end
	
end

function _M.InitSeekPath(self, node)
	
	self.scenemapSeekPath = {}
	InitUI(self.scenemapSeekPath, node)
	self.scenemapSeekPath.ib_mappoint.Visible = false
	self.scenemapSeekPath.cvs_mapinfoarror.Visible = false
	self.drawLine = {}
end

return _M
