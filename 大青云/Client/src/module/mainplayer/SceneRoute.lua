_G.SceneRoute = {}
SceneRoute.drawTable = {}
SceneRoute.routePfx = "v_zidong.pfx"
SceneRoute.pfxs = {}
SceneRoute.minDis = 20

local v1 = _Vector3.new()
local v2 = _Vector3.new()
local v3 = _Vector3.new()
function SceneRoute:MoreRoute(p1, p2)
	v1.x, v1.y, v1.z = p1.x, p1.y, p1.z
	v2.x, v2.y, v2.z = p2.x, p2.y, p2.z
	_Vector3.sub(v1, v2, v3)
	local dis = GetDistanceTwoPoint(p1, p2)
	local num = math.floor(dis/SceneRoute.minDis)
	v3:normalize()
	for i= 1, num do
		local pos = _Vector3.new()
		_Vector3.mul(v3, (i-1) * SceneRoute.minDis, pos)
		pos = _Vector3.add(v2, pos)
		table.insert(SceneRoute.drawTable, pos)
	end
end

function SceneRoute:InitRoute(pathList)
	SceneRoute:ClearRoute()
	if not UIAutoRunIndicator:GetAutoRun() then
		return
	end
	if not pathList then
		return
	end
	for index = 1, #pathList do
		if pathList[index] and not pathList[index].portal and pathList[index+1] then
			SceneRoute:MoreRoute(pathList[index+1], pathList[index])
		end
	end
	table.insert(SceneRoute.drawTable, pathList[#pathList])
end

function SceneRoute:UpdateRoute()
	if #SceneRoute.drawTable < 1 then
		return
	end
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	local selfPos = selfPlayer:GetPos()
	if not selfPos then
		return
	end
	local endPos = SceneRoute.drawTable[#SceneRoute.drawTable]
	if not endPos then
		return
	end
	local dis = GetDistanceTwoPoint(selfPos, endPos)
	if dis < SceneRoute.minDis then
		SceneRoute:ClearRoute()
	else
		SceneRoute:DrawRoute()
	end
end

function SceneRoute:DrawRoute()
	local selfPos = MainPlayerController:GetPlayer():GetPos()
	local dis = 0
	local count = #SceneRoute.drawTable - 1
	for index = 1, count do
		local pos = SceneRoute.drawTable[index]
		if pos then
			dis = GetDistanceTwoPoint(selfPos, pos)
			if dis < SceneRoute.minDis then
				for i = 1, index do
					SceneRoute:StopPfxByIndex(i)
				end
				for j = index + 1, math.min(index + 7, count + 1) do
					SceneRoute:PlayPfxByIndex(j)
				end
				break
			end
		end
	end
end

function SceneRoute:ClearRoute()
	for index, _ in pairs(SceneRoute.pfxs) do
		SceneRoute:StopPfxByIndex(index)
	end
	SceneRoute.drawTable = {}
	SceneRoute.pfxs = {}
end

function SceneRoute:StopPfxByIndex(index)
	local pfx = SceneRoute.pfxs[index]
	if pfx then
		CPlayerMap.objSceneMap:StopPfxByName(pfx)
		SceneRoute.pfxs[index] = nil
	end
end

function SceneRoute:PlayPfxByIndex(index)
	local pos = SceneRoute.drawTable[index]
	if pos and not SceneRoute.pfxs[index] then
		local pfxName = "scene_route_" .. index
		CPlayerMap.objSceneMap:PlayPfxByPos(pfxName, SceneRoute.routePfx, pos)
		SceneRoute.pfxs[index] = pfxName
	end
end