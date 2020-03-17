--[[
地图element:主玩家
2015年4月3日16:46:31
haohu
]]

_G.MapMainPlayerVO = MapElementVO:new();

-- 获取在地图上显示的层级
function MapMainPlayerVO:GetLayer()
	return "top";
end

function MapMainPlayerVO:GetClass()
	return MapMainPlayerVO;
end

function MapMainPlayerVO:GetRotation()
	return MapUtils:DirtoRotation(self.dir,CPlayerMap:GetCurMapID());
end

function MapMainPlayerVO:GetType()
	return MapConsts.Type_MainPlayer;
end

-- 图标是否相应鼠标事件
function MapMainPlayerVO:IsInteractive()
	return false;
end

-- 获取地图图标tips文本
function MapMainPlayerVO:GetTipsTxt()
	return nil;
end

function MapMainPlayerVO:GetAsLinkage()
	return "player";
end

function MapMainPlayerVO:ToString()
	return MapUtils:GetMainPlayerMapUid();
end