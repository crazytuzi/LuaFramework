--[[
地图元素VO
haohu
2014年8月15日09:34:36
]]

_G.MapElementVO = {}

MapElementVO.id    = nil;
MapElementVO.cid   = nil;
MapElementVO.x     = nil;
MapElementVO.y     = nil;
MapElementVO.dir   = nil;
MapElementVO.mapId = nil;

function MapElementVO:new()
	local vo = {};
	setmetatable(vo, {__index = self});
	vo.id   = 0;
	vo.cid  = "0_0";
	vo.x    = 0;
	vo.y    = 0;
	vo.dir  = 0;
	return vo;
end

function MapElementVO:Init(id, cid, x, y, dir, flag)
	self.id   = id or 0;
	self.cid  = cid or "0_0";
	self.x    = x or 0;
	self.y    = y or 0;
	self.dir  = dir or 0;
	self:ParseFlag(flag)
end

function MapElementVO:SetMapId(mapId)
	self.mapId = mapId
end

function MapElementVO:ParseFlag( flag )
	self.flag = flag;
end

function MapElementVO:GetClass()
	return MapElementVO;
end

function MapElementVO:GetId()
	return self.id;
end

function MapElementVO:GetCid()
	return self.cid;
end

function MapElementVO:GetPos()
	return self.x, self.y;
end

function MapElementVO:GetDir()
	return self.dir;
end

function MapElementVO:GetRotation()
	return 0;
end

-- 获取2D坐标
function MapElementVO:Get2DPos()
	local x, y = MapUtils:Point3Dto2D(self.x, self.y, self.mapId);
	return toint(x, -1), toint(y, -1);
end

-- 获取在地图上显示的层级 top middle bottom
function MapElementVO:GetLayer()
	return "middle";
end

-- 图标是否相应鼠标事件
function MapElementVO:IsInteractive()
	return true;
end

function MapElementVO:IsAvailableInMap(mapName)
	return true;
end

function MapElementVO:GetType()
	return "";
end

-- 获取地图图标label
function MapElementVO:GetLabel()
	return "";
end

-- 获取地图图标tips文本
function MapElementVO:GetTipsTxt()
	return "";
end

function MapElementVO:GetAsLinkage(mapName)
	return "";
end

function MapElementVO:ToString()
	local typeStr = self:GetType();
	return typeStr .. self.cid;
end

function MapElementVO:Dispose()

end