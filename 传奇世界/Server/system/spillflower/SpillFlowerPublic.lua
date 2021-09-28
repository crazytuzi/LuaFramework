--SpillFlowerPublic.lua
--/*-----------------------------------------------------------------
 --* Module:  SpillFlowerPublic.lua
 --* Author:  liu cheng
 --* Modified: 2016年3月6日 15:49:14
 --* Purpose: Implementation of the class SpillFlowerPublic
 -------------------------------------------------------------------*/

 SpillFlowerPublic = class(nil, Singleton, Timer)

function SpillFlowerPublic:__init()
	self._offlineData = {}

	g_entityDao:loadOffGiveFlower(1)
	
	gTimerMgr:regTimer(self, 1000, 20000)
	print("SpillFlowerPublic Timer ID: ", self._timerID_)
end

function SpillFlowerPublic.LoadOffGiveFlowerDB(roleSID, datas)
	g_SpillFlowerPublic:LoadOffGiveFlowerDBTmp(datas)
end

function SpillFlowerPublic:LoadOffGiveFlowerDBTmp(datas)
	local dataTmp = unserialize(datas)
	if dataTmp.roleID then
		if dataTmp.data then
			local roleSID = tostring(dataTmp.roleID)
			self._offlineData[roleSID] = {}
			self._offlineData[roleSID].change = 2
			self._offlineData[roleSID].allGlamous = dataTmp.data.allGlamous or 0
			self._offlineData[roleSID].glamous = dataTmp.data.glamous or 0 			--player身上的周魅力值
			self._offlineData[roleSID].record = dataTmp.data.record or {}
			self._offlineData[roleSID].basic = dataTmp.data.basic or {}
		end
	end
end

function SpillFlowerPublic:GetOffGiveFlowerGlamour(roleSID)
	if self._offlineData then
		if self._offlineData[roleSID] then
			local glamour = self._offlineData[roleSID].glamous or 0
			local allGlamour = self._offlineData[roleSID].allGlamous or 0
			return glamour, allGlamour
		end
	end
	return 0,0
end

function SpillFlowerPublic:ClearOffGiveFlowerGlamour()
	for i,v in pairs(self._offlineData or {}) do
		if v.glamous and v.glamous>0 then
			v.glamous = 0
			v.change = 3
		end
	end
end

function SpillFlowerPublic:AddOffLineData(roleSID,tRoleSID,giveFlowers,giveType,addGlamour,roleName,tRoleName,tRoleInfo)
	local offLineData = {}
	if not self._offlineData[tRoleSID] then
		self._offlineData[tRoleSID] = {}
	end
	offLineData = self._offlineData[tRoleSID]

	if not offLineData.allGlamous then
		offLineData.allGlamous = 0
	end

	if not offLineData.glamous then
		offLineData.glamous = 0
	end
	offLineData.allGlamous = offLineData.allGlamous + addGlamour
	offLineData.glamous = offLineData.glamous + addGlamour

	if not offLineData.record then
		offLineData.record = {}
	end
	local record = {}
	record.tick = os.time()
	record.Name = roleName
	record.tName = tRoleName
	record.giveType = giveType
	record.giveNum = giveFlowers
	table.insert(offLineData.record, record)
	local tbNum = table.size(offLineData.record)
	--超过10条记录要删除多余的
	if tbNum > SPILLFLOWER_MAX_RECORD then
		table.remove(offLineData.record, 1)
	end

	if not offLineData.basic then
		offLineData.basic = {}
		offLineData.basic.name = ""
		offLineData.basic.school = 1
		offLineData.basic.sex = 1
		offLineData.basic.level = 1
		offLineData.basic.curGlamour = 0 		--离线玩家已有的魅力值
	end

    if tRoleInfo then
  		local tRoleInfoData = unserialize(tRoleInfo)
  		local name = tRoleInfoData.name or ""
  		local school = tRoleInfoData.school or 1
  		local glamour = tRoleInfoData.glamour or 0
  		local sex = tRoleInfoData.sex or 1
  		local level = tRoleInfoData.level or 1

  		--glamour+offLineData.glamous 是player总的周魅力值
  		g_RankMgr:onGlamourChanged2(tRoleSID,name,school,glamour+offLineData.glamous,sex,level)
print("SpillFlowerPublic:AddOffLineData 02", tRoleSID, glamour, offLineData.glamous)
	
		--记录离线玩家基本信息
		if offLineData.basic then
			offLineData.basic.name = name
			offLineData.basic.school = school
			offLineData.basic.sex = sex
			offLineData.basic.level = level
			offLineData.basic.curGlamour = glamour
		end
	end

	if not offLineData.change then 		--数据是否有改动 1为要删除记录  2没改动 3为已修改
		offLineData.change = 3
	end
	offLineData.change = 3
end

function SpillFlowerPublic:SendOffData(operate,roleSID,worldId)
	if operate<0 then return end
	if 1==operate then
		if self._offlineData then
			if self._offlineData[roleSID] then
				local dataTmp = self._offlineData[roleSID]
				if g_SpillFlowerMgr then
					g_SpillFlowerMgr:dealOffData(roleSID,serialize(dataTmp))
				end

				self._offlineData[roleSID].allGlamous = 0
				self._offlineData[roleSID].glamous = 0
				self._offlineData[roleSID].record = {}
				self._offlineData[roleSID].basic = {}
				self._offlineData[roleSID].change = 1
				--self._offlineData[roleSID] = nil
				g_entityDao:deleteOffGiveFlower(roleSID)
			end
		end
	end
end

function SpillFlowerPublic:update()	
	if table.size(self._offlineData)>0 then
		for i,v in pairs(self._offlineData or {}) do
			if v.change and v.change>2 then
				v.change = 2
				local dataSave = serialize(v)
				g_entityDao:updateOffGiveFlower(tostring(i), dataSave)
				--g_entityDao:updateOffGiveFlower(i,dataSave)
				--g_entityDao:deleteOffGiveFlower(i)			
			end
		end
	end
end

--把所有的离线魅力值数据都发给排行榜
function SpillFlowerPublic:sendOffDataToRank()
	for i,v in pairs(self._offlineData or {}) do
		if i and v and v.basic then
			local name = v.basic.name or ""
			local school = v.basic.school or 1
			local glamour = v.basic.curGlamour or 0
			local sex = v.basic.sex or 1
			local level = v.basic.level or 1

			g_RankMgr:onGlamourChanged2(i,name,school,glamour+v.glamous,sex,level)
		end
	end
end

function SpillFlowerPublic.getInstance()
	return SpillFlowerPublic()
end

g_SpillFlowerPublic = SpillFlowerPublic.getInstance()