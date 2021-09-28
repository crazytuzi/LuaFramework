WorldMapConst = {}

WorldMapConst.MapId = {
	[1] = {mapId = 1001},	--长安城
	[2] = {mapId = 2001},	--天圣古城
	[3] = {mapId = 2002},	--南郡
	[4] = {mapId = 2010},	--灵石矿洞
	[5] = {mapId = 2003},	--从雨森林
	[6] = {mapId = 2004},   --暮秀雨林
	[7] = {mapId = 2109},	--巨人野3
	[8] = {mapId = 2108},	--巨人野2
	[9] = {mapId = 2107},	--巨人野1
	[10] = {mapId = 2111},	--断壁谷2
	[11] = {mapId = 2110},	--断壁谷1
	[12] = {mapId = 2112},  --断壁谷3
	[13] = {mapId = 2104}, 	--青云岭1
	[14] = {mapId = 2105},	--青云岭2
	[15] = {mapId = 2106},  --青云岭3
	[16] = {mapId = 2113},  --轩辕台1
	[17] = {mapId = 2114},  --轩辕台2
	[18] = {mapId = 2115},  --轩辕台3
	[19] = {mapId = 2101},  --不周山1
	[20] = {mapId = 2102},  --不周山2
	[21] = {mapId = 2103},  --不周山3
	[22] = {mapId = 2008},  --阪泉
	[23] = {mapId = 2007},  --西烈荒原
	[24] = {mapId = 2006},  --赤水
	[25] = {mapId = 2005},  --琅琊战场
	[26] = {mapId = 2009},  --天尊洞府
	[27] = {mapId = 2011},  --神印矿洞
}

--需要底部显示的地图
WorldMapConst.NeedBottom = {}

WorldMapConst.ClosePanel = "EventName_ClosePanel"  --关闭界面
WorldMapConst.BossStateChange = "WorldMapConst.BossStateChange"

WorldMapConst.AutoWalkPath = nil -- 自动行走路线
-- isFull 是否全程跑路
function WorldMapConst.GetPath(start, target, isFull)
	local result = MapUtil.GetScenePath(start, target)
	local path = nil
	local isCrossMainCity = false -- 是否经过主城
	if result then
		-- print("找到路径：", #MapUtil.pathes)
		local tmp = nil
		local nodeNum = 1000
		for i=1, #MapUtil.pathes do
			tmp = MapUtil.pathes[i]
			-- print("节点：",#tmp)
			if #tmp < nodeNum then
				nodeNum = #tmp
				path = tmp
			end
		end
		-- print("最后选择节点数:", #path)
		for i,v in ipairs(path) do
			if v.toMapId == 1001 then
				isCrossMainCity = true -- 经过主城
				break
			end
		end
		-- 去掉走去主城那部分
		if isCrossMainCity and not isFull then
			for i=#path,1,-1 do
				local v = path[i]
				if v.mapId == 1001 then
					break
				else
					table.remove(path, i)
				end
			end
		end
	end
	WorldMapConst.AutoWalkPath = path
	return isCrossMainCity
end