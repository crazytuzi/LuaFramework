module(..., package.seeall)
--更新导表
function UpdateData(lDelFileNames, lFileResVersions)
	for i, sDeleteFile in ipairs(lDelFileNames) do
		local filepath = IOTools.GetPersistentDataPath("/data/"..sDeleteFile)
		IOTools.Delete(filepath)
		package.loaded["logic.data."..sDeleteFile] = nil
		data[sDeleteFile] = nil
		printc("DataTools.UpdateData, del:", sDeleteFile)
	end
	for i, dFileResVersion in ipairs(lFileResVersions) do
		local filepath = IOTools.GetPersistentDataPath("/data/"..dFileResVersion.file_name)
		IOTools.SaveByteFile(filepath, dFileResVersion.content)
		package.loaded["logic.data."..dFileResVersion.file_name] = nil
		data[dFileResVersion.file_name] = nil
		printc("DataTools.UpdateData, modify:", dFileResVersion.file_name)
	end
end


--获取数据
function GetAnimEventData(shape, state)
	local t =  data.animeventdata.Data[shape]
	if not t then
		t = data.animeventdata.Data[define.Model.Defalut_Shape]
	end
	return t[state]
end

function GetLineupPos(sType)
	local t = data.lineupdata.GRID_POS_MAP[sType]
	return Vector3.New(t.x, 0,t.z)
end

function GetSchoolSkillData(iSkill)
	local t = data.skilldata.SCHOOL[iSkill]
	if not t then
		t = data.skilldata.SCHOOL[1100]
	end
	return t
end

function GetPassiveSkillData(iSkill)
	local t = data.skilldata.PASSIVE[iSkill]
	if not t then
		t = data.skilldata.PASSIVE[2101]
	end
	return t
end

function GetCultivationData(iSkill)
	local t = data.skilldata.CULTIVATION[iSkill]
	if not t then
		t = data.skilldata.CULTIVATION[4000]
	end
	return t
end

function GetMagicData(iMagic)
	local t = data.magicdata.DATA[iMagic]
	if not t then
		t = {}
		t.name = "未导表"..tostring(iMagic)
	end
	return t
end

-- [[地图数据]]
function GetSceneData(sceneID)
	if data.scenedata.DATA[sceneID] then
		return data.scenedata.DATA[sceneID]
	end
	return {}
end

function GetMapData(mapid)
	if data.mapdata.DATA[mapid] then
		return data.mapdata.DATA[mapid]
	end
	return {resource_id = 1010}
end

function GetSceneDataForMapid(mapid)
	for k,v in pairs(data.scenedata.DATA) do
		if mapid == v.map_id then
			return v
		end
	end
	return {}
end

-- [[道具数据]]
function GetItemData(iShape,mtype)
	local  itemid = tonumber(iShape)
	if itemid == nil then
		return
	end
	local  item = nil
	if mtype then
		item = data.itemdata[mtype][itemid]
	end	
	if not item then   
		for k,v in pairs(data.itemdata) do
			item = v[itemid]
			if item ~= nil then
				break
			end
		end			
	end
	if item then
		return item
	else
		return {
			name='未导表物品'..itemid,
			icon=itemid,
			id=itemid,
		}
	end
end

-- [[NPC数据]]
function GetSchoolNpcID(schoolID, typeName)
	-- 默认取第一个门派，师傅
	schoolID = schoolID or 1
	typeName = typeName or "tutorid"
	local schoolData = data.npcdata.SCHOOL
	local schoolInfo = schoolData[schoolID]
	if schoolInfo and schoolInfo[typeName] then
		return schoolInfo[typeName]
	end
	printerror("没有找到门派Npc，查看导表是否有误。门派 -> | 类型 -> ", schoolID, typeName)
	return ""
end

function GetGlobalNpcList(mapID)
	if not mapID then
		return {}
	end
	if mapID and mapID > 0 then
		local npclist = {}
		local globalNpc = data.npcdata.NPC.GLOBAL_NPC
		for _,v in pairs(globalNpc) do
			if mapID == v.sceneId then
				if v.dialogAnimationId and v.dialogAnimationId ~= "" then
					local list = string.split(v.dialogAnimationId, ";")
					local id = 0
					if list and #list > 0 then
						id = list[1]
					end
					local d = g_DialogueAniCtrl:GetFileData(id)
					if not d or not d.CONFIG or d.CONFIG.isStroy ~= 0 then
						table.insert(npclist, v)
					end
				else
					table.insert(npclist, v)	
				end				
			end
		end
		return npclist
	end
	printerror("没有找到NpcList，查看mapID是否错误。mapID -> ", mapID or "nil")
	return {}
end

-- [[伙伴数据]]
function GetPartnerType(typeID)
	local partnerType = data.partnerdata.TYPE
	local typeInfo = partnerType[typeID]
	if typeInfo then
		return typeInfo
	end
	printerror("错误：获取伙伴类型数据，检查伙伴类型ID是否错误：", typeID)
end

function GetPartnerInfo(partnerID)
	local partnerInfo = data.partnerdata.INFO
	local partner = partnerInfo[partnerID]
	if partner then
		return partner
	end
	printerror("错误：获取伙伴数据，检查伙伴ID是否错误：", partnerID)
end

function GetPartnerProp(partnerID)
	local partnerProp = data.partnerdata.PROP
	local propInfo = partnerProp[partnerID]
	if propInfo then
		return propInfo
	end
	printerror("错误：获取伙伴属性数据，检查伙伴ID是否错误：", partnerID)
end

function GetPartnerPoint(partnerID, quality)
	local partnerPoint = data.partnerdata.POINT
	local point = partnerPoint[partnerID]
	if point then
		return point[quality]
	end
	printerror("错误：获取伙伴一级属性，检查伙伴ID是否错误", partnerID)
end

function GetPartnerSkillUnlock(partnerID)
	local partnerSkill = data.partnerdata.SKILLUNLOCK
	local skill = partnerSkill[partnerID]
	if skill then
		return skill
	end
	printerror("错误：获取伙伴技能数据，检查伙伴ID是否错误：", partnerID)
end

function GetPartnerItem(partnerItemID)
	local partnerItem = data.itemdata.PARTNER
	local item = partnerItem[partnerItemID]
	if item then
		return item
	end
	printerror("错误：获取伙伴物品，检查伙伴物品ID是否错误", partnerItemID)
end

function GetPartnerUpperLimit(partnerID, upperID)
	local partnerUpperLimit = data.partnerdata.UPPERLIMIT
	local upperLimit = partnerUpperLimit[partnerID]
	if upperLimit then
		return upperLimit[upperID]
	end
	printerror("错误：获取伙伴突破数据，检查伙伴ID是否错误", partnerID)
end

function GetPartnerQualitycost(partnerID, qualityID)
	local partnerUpperLimit = data.partnerdata.QUALITYCOST
	local qualityCost = partnerUpperLimit[partnerID]
	if qualityCost then
		return qualityCost[qualityID]
	end
	printerror("错误：获取伙伴进阶数据，检查伙伴ID是否错误", partnerID)
end

function GetPartnerUpperRatio(upperID)
	return data.partnerdata.UPPER[upperID]
end

function GetPartnerQualityRatio(qualityID)
	return data.partnerdata.QUALITY[qualityID]
end

function GetPartnerSpecialSkill(skillID)
	return data.partnerdata.SKILL[skillID]
end

-- [[任务数据]]
function GetTaskType(tasktype)
	if tasktype then
		local typeInfo = data.taskdata.TASKTYPE[tasktype]
		if typeInfo then
			return typeInfo
		end
	end
	return {
		name = '未导表任务分类信息:' .. (tasktype or "nil"),
		id = tasktype,
	}
end

function GetTaskData(taskid)
	if taskid then
		local task = data.taskdata.TASK
		for _,v in pairs(task) do
			if v.TASK and v.TASK[taskid] then
				return v.TASK[taskid]
			end
		end
	end
	return {
		name = '未导表任务:' .. taskid,
		id = taskid,
	}
end

function GetTaskPick(pickid)
	local taskData = data.taskdata.TASK
	for k,v in pairs(taskData) do
		if v and v.PICK and v.PICK[pickid] then
			return v.PICK[pickid]
		end
	end

	printerror("没有找到任务采集物品，使用默认配置，查看导表是否有误。ID -> ", pickid)
	return {
		id = pickid or 1001,
		name = '未导表任务Pick:' .. pickid,
		finishTip=[[采集完成]],
		useTime=3,
		usedTip=[[采集中]],
	}
end

function GetTaskItem(itemid)
	local taskData = data.taskdata.TASK
	for k,v in pairs(taskData) do
		if v and v.ITEM and v.ITEM[itemid] then
			return v.ITEM[itemid]
		end
	end

	printerror("没有找到任务使用物品，使用默认配置，查看导表是否有误。ID -> ", itemid)
	return {
		description=[[未导表任务Item]],
		finishTip=[[使用完成]],
		icon=10001,
		id = itemid or 10001,
		name = '未导表任务Item:' .. (itemid or ""),
		useTime=3,
		usedTip=[[使用中]],
	}
end

-- [[奖励数据]]
function GetReward(rewardType, rewardID)
	local rewardData = data.rewarddata[rewardType]
	if not rewardData then
		printc("没有找到奖励类型，查看导表是否有误。类型：", rewardType, rewardID)
		return
	end
	local id = tonumber(rewardID)
	if not id then
		printerror("错误：不合法的任务奖励ID：", rewardID)
		return
	end
	if rewardData[id] then
		return rewardData[id]
	end
	printerror("没有找到任务奖励，查看导表是否有误。类型 -> | ID -> ", rewardType, rewardID)
	return
end

-- [[日程数据]]
function GetScheduleData(scheduleid)
	local dSchedule = data.scheduledata.SCHEDULE[scheduleid]
	if dSchedule then
		return dSchedule
	end
	printerror("没有找到对应下标日程ID，查看导表是否有误。scheduleid -> ", scheduleid)
end

-- [[挂机]]
function GetAutoteamData(level)
	local result = {}
	for k,v in pairs(data.teamdata.AUTO_TEAM) do
		if v.unlock_level <= level then
			table.insert(result, v)
		end
	end

	local sort = function(data1, data2)
		return data1.sort < data2.sort
	end
	table.sort(result, sort)
	return result
end

function GetStoreData(storeid)
	if storeid == define.Currency.Type.GoldCoin then
		return data.storedata.GOLDCOINSTORE
	elseif storeid == define.Currency.Type.Gold then
		return data.storedata.GOLDSTORE
	elseif storeid == define.Currency.Type.Silver then
		return data.storedata.SILVERSTORE
	end	
end

function GetGlobalData(key)
	local info = data.globaldata.GLOBAL[key]
	if info then
		return info
	end
	return {
		name = '未导表全局配置信息:' .. key,
		id = key,
	}
end

--获取指定门派、部位、等级的装备列表
--@param iSchool 门派,全部门派为-1
--@param iPos 装备部位，全部位为-1
--@param iLevel 装备等级，全等级为-1
function GetEquipListByLevel(iSchool, iSex, iLevel, iPos)
	iSchool = 0 --TODO:陪标未完成
	iSchool = iSchool or -1
	iSex = iSex or -1
	iLevel = iLevel or -1
	iPos = iPos or -1
	local result = {}
	for k,v in pairs(data.itemdata.EQUIP) do
		local euqipData = v
		if iSex ~= -1 and v.sex ~= 0 and 
			v.sex ~= iSex then
			euqipData = nil
		end 
		if iSchool ~= -1 and v.school ~= iSchool then
			euqipData = nil
		end
		if iPos ~= -1 and v.equipPos ~= iPos then
			euqipData = nil
		end
		local equipLevel = tonumber(v.equipLevel)
		if iLevel ~= -1 and 
			(equipLevel < iLevel or equipLevel >= iLevel + 10) then --该过滤条件不确定
			euqipData = nil
		end
		if euqipData then
			table.insert(result, euqipData)
		end
	end
	function sort(data1, data2)
		return data1.id < data2.id
	end
	table.sort(result, sort)
	return result
end

--获取装备洗炼的条件
--@param iPos 装备位置
--@param iLevel 装备等级 
function GetWashInfo(iPos, iLevel)
	for k,v in pairs(data.equipdata.WASH) do
		if v.level == iLevel and v.pos == iPos then
			return v 
		end
	end
	return nil
end

--获取武器属性的波动范围
--return result table {min, max}
function GetEquipAttrRange()
	local result = {}
	local iMin = 100
	local iMax = 100
	for k,v in pairs(data.equipdata.EQUIP_LEVEL) do
		iMin = math.min(iMin, v.min)
		iMax = math.max(iMax, v.max)
	end
	result.min = iMin
	result.max = iMax
	return result
end

--获取物品的分解结果 装备or神魂可分解,分解数据不同
--return result table
function GetDecomposeList(citem)
	local result = {}

	local tData = nil
	for k,v in pairs(data.equipdecomposedata.EQUIP_DECOMPOSE) do
		if citem:GetValue("pos") == v.pos and 
			citem:GetValue("equip_level") == v.level and
			citem:GetValue("itemlevel") == v.quality then
			tData = v
			break
		end
	end
	if tData then
		for k,v in pairs(data.equipdecomposedata.DECOMPOSE_DATA) do
			if v.fenjie_id == tData.fenjie_id then
				table.insert(result, v)
			end
		end
		return result
	end

	tData = data.itemdata.EQUIPSOUL[itemid]
	if tData then
		return tData.deCompose
	end
	return result
end

--获取指定部位的神兵之魂
--@param iEquipPos 装备位置 小于等于0为全选
--@param result table
function GetEquipSoulListByPos(iEquipPos)
	local result = {}
	for k,v in pairs(data.equipdata.SOUL_EFFECT) do
		local dData = GetItemData(v.sid)
		if dData.pos == iEquipPos or iEquipPos <= 0 then
			dData.effect = v
			dData.merge = data.equipdata.SOUL_MERGE[v.sid]
			table.insert(result, dData)
		end
	end
	local function sort(data1, data2)
		if data1.pos == data2.pos then
			return data1.level > data2.level 
		end
		if data1.pos == data2.pos and data1.level == data2.level then
			return data1.effect.ratio > data2.effect.ratio
		end
		return data1.pos < data2.pos
	end
	table.sort(result, sort)
	return result
end

--获取指定部位的强化效果
--@param iPos 装备部位
--@param iLevel 强化等级
--@return table
function GetEquipStrengthData(iPos, iLevel)
	for k,v in pairs(data.equipdata.STRENGTH) do
		if v.pos == iPos and v.strengthLevel == iLevel then
			local func = loadstring("return "..v.strength_effect) 
			return func()
		end
	end
	return nil
end

--获取指定部位的强化所需材料
--@param iPos 装备部位
--@param iLevel 强化等级
--@return table
function GetEquipStrengthMaterial(iPos, iLevel)
	for k,v in pairs(data.equipdata.STRENGTH_MATERIAL) do
		if v.pos == iPos and v.level == iLevel then
			return v
		end
	end
end

--获取角色的门派和性别描述
--@param iSex 性别
function GetRoleType(iSex)
	for k,v in pairs(data.roletypedata.DATA) do
		if v.sex == iSex then
			return v
		end
	end
	return nil
end

--编辑器下才刷新数据 Start
function RefreshData()
	GenDynamicAtlas()
	-- GenEditorData()
	--GenLineupGridData()
end

function SaveLineupData()
	local dSavedata = data.lineupdata
	local sOut = "module(...)\n"
	sOut = sOut.."--editorLineup生成数据\n"
	local lKeys = {"LINEUP_TYPE", "PRIOR_POS"}
	for i, v in ipairs(lKeys) do
		sOut = sOut..table.dump(dSavedata[v], v).."\n"
	end
	sOut = sOut.."--DataTools.GenLinupGridData(r, c)生成数据\n%s\n%s"
	sOut = string.format(sOut, table.dump(dSavedata.GRID_POS_MAP, "GRID_POS_MAP"), table.dump(dSavedata.GRID_POS_KEY, "GRID_POS_KEY"))
	
	local sOutPath = IOTools.GetAssetPath("/Lua/logic/data/lineupdata.lua")
	local fileobj = io.open(sOutPath, "w")
	
	fileobj:write(sOut)
	fileobj:close()
	g_NotifyCtrl:FloatMsg("站位保存成功!"..sOutPath)
end

function GenLineupGridData()
	local col = 10
	local row = 10
	local base = {}
	local minPos = Vector3.New(-5.44, 0, -5.44)
	local maxPos = Vector3.New(5.44, 0, 5.44)
	for r = 1, row do
		local t = {}
		for c = 1, col do
			t[c] = {["x"]=Mathf.Lerp(minPos.x, maxPos.x, (c-1)/(col-1)), 
					["z"]=Mathf.Lerp(minPos.z, maxPos.z, (r-1)/(row-1))}
		end
		base[r] = t
	end
	local rA, cA = 2, 8
	local rB, cB = 9, 3
	local rc = {
		A1 = {r=rA,c=cA},
		A2 = {r=rA+1,c=cA+1},
		A3 = {r=rA-1,c=cA-1},
		A4 = {r=rA+2,c=cA+2},
		A5 = {r=rA+1,c=cA-1},
		A6 = {r=rA+2,c=cA},
		A7 = {r=rA,c=cA-2},
		A8 = {r=rA+3,c=cA+1},
		A9 = {r=rA+2,c=cA-2},
		A10 = {r=rA+3,c=cA-1},
		A11 = {r=rA-1,c=cA+1},
		A12 = {r=rA,c=cA+2},
		B1 = {r=rB,c=cB},
		B2 = {r=rB-1,c=cB-1},
		B3 = {r=rB+1,c=cB+1},
		B4 = {r=rB-2,c=cB-2},
		B5 = {r=rB-1,c=cB+1},
		B6 = {r=rB-2,c=cB},
		B7 = {r=rB,c=cB+2},
		B8 = {r=rB-3,c=cB-1},
		B9 = {r=rB-2,c=cB+2},
		B10 = {r=rB-3,c=cB+1},
		B11 = {r=rB+1,c=cB-1},
		B12 = {r=rB,c=cB-2},
	}
	local map = {}
	for k, v in pairs(rc) do
		map[k] =base[v.r][v.c]
	end
	local single = {
		AA1 = {"A5", "A6"},
		AA2 = {"A1", "A3"},
		AA3 = {"A1", "A2"},
		AA4 = {"A2", "A4"},

		BB1 = {"B5", "B6"},
		BB2 = {"B1", "B3"},
		BB3 = {"B1", "B2"},
		BB4 = {"B2", "B4"},
	}
	for k, v in pairs(single) do
		local pos1, pos2 = map[v[1]], map[v[2]] 
		map[k] = {x = (pos1.x+pos2.x)/ 2, z=(pos1.z+pos2.z)/2}
	end

	local dTemp = {
		["single"] = {
			[1]	= {[1]="XX3"},
			[2] = {[1]="XX3", [5]="XX1"},
			[3] = {[1]="XX3", [5]="X5", [2]="X6"},
			[4] = {[1]="XX3", [5]="XX1", [2]="XX2", [3]="XX4"},
			[5] = {[1]="XX3", [5]="X5", [2]="X6", [3]="XX2", [4]="XX4"},
		},
		["team"] = {
			[2] = {[1]="X1", [2]="X2", [3]="X3", [4]="X4", [5]="X5", [6]="X6"},
			[3] = {[1]="XX3", [2]="XX2", [3]="XX4", [4]="X6", [5]="X5", [6]="X7", [7]="X8"},
			[4] = {[1]="X1", [2]="X2", [3]="X3", [4]="X4", [5]="X5", [6]="X6", [7]="X7", [8]="X8"},
		}
	}
	local dData = {}
	for k, v in pairs(dTemp) do
		local t = {}
		for k1, v1 in pairs(v) do
			local t1 = {[1] = {[9]="A9", [10]="A10"}, [2] = {[9]="B9", [10]="B10"}}
			for k2, v2 in pairs(v1) do
				t1[1][k2] = string.gsub(v2, "X", "A")
				t1[2][k2] = string.gsub(v2, "X", "B")
			end
			t[k1] = t1
		end
		dData[k] = t
	end
	map.Center = {x=(map.A10.x+map.B10.x)/2, z=(map.A10.z+map.B10.z)/2}
	-- local sOut = "module(...)\n--DataTools.GenLinupGridData(r, c)生成数据\n%s\n%s"
	-- sOut = string.format(sOut, table.dump(map, "GRID_POS_MAP"), table.dump(dData, "GRID_POS_KEY"))
	-- local sOutPath = IOTools.GetAssetPath("/Lua/logic/data/lineupdata.lua")
	-- local fileobj = io.open(sOutPath, "w")
	-- fileobj:write(sOut)
	-- fileobj:close()
	data.lineupdata.GRID_POS_MAP = map
	data.lineupdata.GRID_POS_KEY = dData
	SaveLineupData()
end



function GenDynamicAtlas()
	local dict = {}
	local sFormat = "Atlas/DynamicAtlas/%s/%s.prefab"
	local function walk(dir, filename)
		local typename, idx = string.match(filename, "(%a+)Atlas(%d+)%.prefab$")
		idx = tonumber(idx)
		if typename and idx then
			if not dict[typename] then
				dict[typename] = {}
			end
			local atlasname = string.format("%sAtlas%d", typename, idx)
			local respath = string.format(sFormat, atlasname, atlasname)
			local prefab = C_api.ResourceManager.Load(respath)
			if prefab then
				local oComponent = prefab:GetComponent(classtype.UIAtlas)
				local arr = oComponent:GetListOfSprites()

				if arr then
					for j = 0, arr.Length - 1 do
						local key = tonumber(arr[j]) or arr[j]
						if key then
							dict[typename][key] = {atlas=atlasname, sprite=arr[j]}
						else
							print("ResInit Error", typename, idx, key)
						end
					end
				end
			end
		end
	end

	local datapath = UnityEngine.Application.dataPath
	local sPath = IOTools.GetGameResPath("/Atlas/DynamicAtlas")
	IOTools.WalkDir(sPath, walk)

	local sOut = "module(...)\n--DataTools.GenDynamicAtlas 生成数据\n%s"
	sOut = string.format(sOut, table.dump(dict, "DATA"))
	local sOutPath = IOTools.GetAssetPath("/Lua/logic/data/dynamicatlasdata.lua")
	IOTools.SaveTextFile(sOutPath, sOut)
	data.dynamicatlasdata.DATA = dict
end
--编辑器下才刷新数据 End

function GetSpineConfig(iShape)
	local tDefault = {
		relative_size=1,
		size=1,
		ui_size=1,
	}
	return data.spinedata.CONFIG[tostring(iShape)] or tDefault
end

--DataTools.GetChapterConfig()
function GetChapterConfig(chaptertype, chapterid, level)
	local t = {}
	chaptertype = chaptertype or 1
	if chapterid and level then
		if data.chapterfubendata.Config[chaptertype] and data.chapterfubendata.Config[chaptertype][chapterid] then
			t = data.chapterfubendata.Config[chaptertype][chapterid][level]	
		end
	elseif chapterid then
		if data.chapterfubendata.Config[chaptertype] then
			 t = data.chapterfubendata.Config[chaptertype][chapterid]
		end 		
	else	
		t = data.chapterfubendata.Config[chaptertype]
	end 
	return t
end

--DataTools.GetChapterStarReward()
function GetChapterStarReward(chaptertype, chapterid, rewardidx)
	chaptertype = chaptertype or 1
	if chapterid and rewardidx then
		return data.chapterfubendata.StarReward[chaptertype][chapterid][rewardidx]
	elseif chapterid then
		return data.chapterfubendata.StarReward[chaptertype][chapterid]
	else
		return data.chapterfubendata.StarReward[chaptertype]
	end
end

--DataTools.GetChapterInfo
function GetChapterInfo(chaptertype, chapterid)
	chaptertype = chaptertype or 1
	if chapterid then
		return data.chapterfubendata.ChapterInfo[chaptertype][chapterid]
	else
		return data.chapterfubendata.ChapterInfo[chaptertype]
	end
end