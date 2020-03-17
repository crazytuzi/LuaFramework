--[[
跨地图寻路
lizhuangzhuang
2015年1月6日14:50:41
]]

_G.MapPathFinder = {};

--获取路径
--@param startMap 起点地图
--@param endMap	  终点地图
--@return 
function MapPathFinder:FindPath(startMap,endMap)
	if startMap == endMap then
		return {};
	end
	local endPathIndex = self:GetMapPathIndex(endMap);
	if not endPathIndex then return false; end
	--玩家在主城
	if startMap == MapPath.MainCity then
		return self:GetPathInPath(startMap,endMap,endPathIndex);
	end
	local startPathIndex = self:GetMapPathIndex(startMap);
	--起点和终点在同一条路径
	if startPathIndex == endPathIndex then
		return self:GetPathInPath(startMap,endMap,endPathIndex);
	end
	local list = {};
	--先走到主城,从主城到目标点
	local startPath = self:GetPathInPath(startMap,MapPath.MainCity,startPathIndex);
	local endPath = self:GetPathInPath(MapPath.MainCity,endMap,endPathIndex);
	if not startPath or not endPath then return list; end
	for i,id in ipairs(startPath) do
		table.push(list,id);
	end
	for i,id in ipairs(endPath) do
		table.push(list,id);
	end
	return list;
end


--获得地图所在的路径索引
function MapPathFinder:GetMapPathIndex(mapId)
	for i,pathlist in ipairs(MapPath) do
		for k,id in ipairs(pathlist) do
			if id == mapId then
				return i;
			end
		end
	end
	return false;
end


--获取在一条地图路径内的行走
function MapPathFinder:GetPathInPath(startMap,endMap,pathIndex)
	local pathlist = MapPath[pathIndex];
	if not pathlist then return false; end
	local startIndex,endIndex = 0,0;
	for i,id in ipairs(pathlist) do
		if id == startMap then
			startIndex = i;
		end
		if id == endMap then
			endIndex = i;
		end
	end
	if startIndex==0 or endIndex==0 then return false; end
	if startIndex == endIndex then
		return {};
	end
	local list = {};
	if startIndex<endIndex then
		for i=startIndex+1,endIndex,1 do
			table.push(list,pathlist[i]);
		end
	else
		for i=startIndex-1,endIndex,-1 do
			table.push(list,pathlist[i]);
		end
	end
	return list;
end