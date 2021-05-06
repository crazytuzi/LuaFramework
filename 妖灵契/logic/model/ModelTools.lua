module(..., package.seeall)

g_StateToHash = {}
g_HashToState = {}

function GetModelConfig(iShape)
	local t = data.modeldata.CONFIG[iShape]
	if not t then
		t = data.modeldata.CONFIG[0]
	end
	return t
end

function GetTravelModelConfig(iShape)
	local t = data.traveldata.MODEL_CONFIG[iShape]
	if not t then
		t = data.traveldata.MODEL_CONFIG[0]
	end
	return t
end

function StateToHash(sState)
	local iHash = g_StateToHash[sState]
	if not iHash then
		local sHashStr = string.format("BaseLayer.%s", sState)
		iHash = UnityEngine.Animator.StringToHash(sHashStr)
		g_StateToHash[sState] = iHash
		g_HashToState[iHash] = sState
	end
	return iHash
end

function HashToState(iHash)
	return g_HashToState[iHash]
end

function FrameToTime(iFrame)
	return iFrame * Utils.g_FrameDelta
end

function TimeToFrame(iTime)
	return math.max(0, math.floor(iTime/Utils.g_FrameDelta + 0.5))
end

function IsCommonState(sState)
	return table.index(data.modeldata.COMMON_STATE, sState) ~= nil
end

function GetAllState(iShape)
	local list = table.copy(data.modeldata.COMMON_STATE)
	table.extend(list, data.modeldata.SOCIAL_STATE)
	local dExtra = data.comboactdata.DATA[iShape]
	if iShape and dExtra then
		for k, v in pairs(dExtra) do
			table.insert(list, 1, k)
		end
	end
	return list
end


function GetAllModelShape()
	local list = {}
	if Utils.IsEditor() then
		local dirs = System.IO.Directory.GetDirectories(IOTools.GetAssetPath("/GameRes/Model/Character/"))
		for i=0, dirs.Length-1 do
			local iShape = tonumber(System.IO.Path.GetFileName(dirs[i]))
			table.insert(list, iShape)
		end
	else
		list = table.keys(data.editordata.SHAPE)
	end
	table.sort(list)
	return list
end

function GetAllWeaponShape()
	local list = {}
	if Utils.IsEditor() then
		local dirs = System.IO.Directory.GetDirectories(IOTools.GetAssetPath("/GameRes/Model/Weapon/"))
		for i=0, dirs.Length-1 do
			local iShape = tonumber(System.IO.Path.GetFileName(dirs[i]))
			table.insert(list, iShape)
		end
	else
		list = table.keys(data.editordata.WEAPON)
	end
	table.sort(list)
	return list
end

function GetAnimClipInfo(iShape, sState, iAnimatorIdx)
	local tInfo
	local tShape = data.animclipdata.DATA[iShape]
	if tShape then
		iAnimatorIdx = iAnimatorIdx or 1
		local tAnimator = tShape[iAnimatorIdx]
		if tAnimator then
			sState = iAnimatorIdx > 1 and string.format("%s_%d",sState, iAnimatorIdx) or sState
			tInfo = tAnimator[sState]
		end
	end
	if not tInfo then
		tInfo = {frame=30, length=1}
	end
	return tInfo
end

function NormalizedToFixed(iShape, animatorIdx,sState, normalized)
	local length = GetAnimClipInfo(iShape, sState, animatorIdx).length
	return length * normalized
end

function GetWeaponModelID(iWeaponID)
	local dEquip = data.itemdata.EQUIP[iWeaponID]
	if dEquip and dEquip.model ~= 0 then
		return dEquip.model
	end
end

function GetMountList(iShape, iModel)
	local dInfo = data.modeldata.MOUNT[iShape]
	if not dInfo then
		return
	end
	local sKey = GetWeaponKey(iModel)
	return dInfo[sKey]
end

function GetWeaponKey(iWeapon)
	if 2000 <= iWeapon and iWeapon <= 2099 then
		return "Bow"
	elseif 2100 <= iWeapon and iWeapon <= 2199 then
		return "Sword"
	elseif 2200 <= iWeapon and iWeapon <= 2299 then
		return "Book"
	elseif 2300 <= iWeapon and iWeapon <= 2399 then
		return "Glove"
	elseif 2400 <= iWeapon and iWeapon <= 2499 then
		return "Axe"
	elseif 2500 <= iWeapon and iWeapon <= 2599 then
		return "Yue"
	end
end

function GetAnimatorIdx(iShape, iWeapon)
	local idx = 1
	iShape = data.modeldata.SHARE_ANIM[iShape] or iShape
	local dInfo =  data.modeldata.ANIMATOR[iShape]
	if dInfo then
		local sKey = GetWeaponKey(iWeapon)
		if sKey and dInfo[sKey] then
			idx = dInfo[sKey]
		end
	end
	return idx
end

function ModelInfoScale(dInfo, iScale)
	if dInfo.scale then
		if dInfo.scale == 0 then
			dInfo.scale = nil
		else
			dInfo.scale = dInfo.scale * iScale
		end
	end
end