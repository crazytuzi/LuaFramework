--[[
地图 model
haohu
2015年4月12日12:09:03
]]

_G.MapModel = Module:new();

MapModel.staticFunctionMap = {
	["Init"]                = true,
	["GetModel"]            = true,
	["GetFreeTeleportTime"] = true,
	["SetFreeTeleportTime"] = true
}

MapModel.allMap = {};
MapModel.freeTeleportTime = 0
MapModel.noTeleportCostPrompt = false -- 是否传送花费提示
MapModel.noTeleportDistansePrompt = false -- 是否传送距离提示

function MapModel:Init()
	self:new( MapConsts.Type_Curr );
	self:new( MapConsts.Type_Local );
end

function MapModel:GetModel( mapType )
	return self.allMap[mapType];
end

function MapModel:GetFreeTeleportTime()
	return self.freeTeleportTime
end

function MapModel:SetFreeTeleportTime( value )
	self.freeTeleportTime = value
end

--------------------------------------------------------------------------------------

MapModel.mapId    = nil;
MapModel.elements = {};
MapModel.mapType  = nil;

function MapModel:new(mapType)
	local map = {};
	for k, v in pairs(self) do
		if type(v) == "function" and not MapModel.staticFunctionMap[k] then
			map[k] = v;
		end
	end
	map.elements = {};
	map.mapType = mapType;
	self.allMap[mapType] = map;
end

--@ return true = 添加成功
--添加一个地图单位
function MapModel:AddElement(elemVO)
	local elements = self.elements;
	local uid = elemVO:ToString();
	if elements[uid] then
		local x, y = elemVO:GetPos();
		local dir = elemVO:GetDir();
		self:MoveElement( uid, x, y, dir );
		MapObjectPool:ReturnObject( elemVO );
		return nil;
	end
	elemVO:SetMapId( self.mapId )
	elements[uid] = elemVO;
	self:sendNotification( NotifyConsts.MapElementAdd, { mapType = self.mapType, elem = elemVO } );
	return elemVO;
end

--移除一个地图单位
function MapModel:RemoveElement(uid)
	local existElem = self.elements[uid];
	if existElem then
		self.elements[uid] = nil;
		self:sendNotification( NotifyConsts.MapElementRemove, { mapType = self.mapType, elem = existElem } );
		MapObjectPool:ReturnObject(existElem);
		return existElem;
	end
	return nil;
end

--清空地图元素
function MapModel:ClearElements()
	for _, elemVO in pairs(self.elements) do
		MapObjectPool:ReturnObject(elemVO);
	end
	self.elements = {};
	self:sendNotification( NotifyConsts.MapElementClear, { mapType = self.mapType } );
end

--更新一个地图单位
function MapModel:UpdateElement(elemVO)
	local uid = elemVO:ToString();
	MapObjectPool:ReturnObject(elemVO);
	local existElem = self.elements[uid];
	if existElem then
		self:sendNotification( NotifyConsts.MapElementUpdate, { mapType = self.mapType, elem = existElem } );
		return true;
	end
	return false;
end

--移动一个图标
function MapModel:MoveElement(uid, x, y, dir)
	local existElem = self.elements[uid];
	if existElem then
		existElem.x   = x;
		existElem.y   = y;
		existElem.dir = dir;
		self:sendNotification( NotifyConsts.MapElementMove, { mapType = self.mapType, elem = existElem } );
		return true;
	end
	return false;
end

--获取某个地图单位
function MapModel:GetElement(uid)
	return self.elements[uid];
end

--设置当前地图
function MapModel:SetMap(mapId)
	if self.mapId ~= mapId then
		self.mapId = mapId;
		self:sendNotification( NotifyConsts.MapChange, { mapType = self.mapType, mapId = mapId } );
	end
end

--获取当前地图ID
function MapModel:GetMapId()
	return self.mapId;
end

--获取当前地图所有地图单位列表
function MapModel:GetElements()
	return self.elements;
end
