--AchieveInfoData.lua
-- Filename：	AchieveInfoData.lua
-- Author：		llp
-- Date：		2015-5-11
-- Purpose：		成就的数据层

module ("AchieveInfoData", package.seeall)
require "script/ui/achie/AchievementLayer"
require "db/DB_Achie_table"

local achieveData = nil

--设置成就数据
function getServiceAchieveData()
	-- body
	local function getInfoFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			achieveData = dictData.ret
		end
	end
	RequestCenter.getAchieInfo(getInfoFunc)
end
--获取成就数据
function getAchieveData()
	-- body
	return achieveData
end
--是否显示小红圈
function getRedStatus( ... )
	-- body
	local showRed = false

	if(not table.isEmpty((AchievementLayer.childTable)))then
		for i=1,4 do
			local show = false
			for j=1,table.count(AchievementLayer.childTable[i])do
				for k,v in pairs(AchievementLayer.childTable[i][j])do
					if(tonumber(v.status)==1)then
						show = true
						return true
					end
				end
			end
		end
	else
		for k,v in pairs(achieveData)do
			if(tonumber(v.status)==1)then
				showRed=true
				break
			end
		end
		return showRed
	end
end

--强制显示小红圈 用于成就推送
function setRed( num )
	-- body
	if(not table.isEmpty((AchievementLayer.childTable)))then
		for i=1,4 do
			local show = false
			for j=1,table.count(AchievementLayer.childTable[i])do
				for k,v in pairs(AchievementLayer.childTable[i][j])do
					if(tonumber(k)==num)then
						v.status = 1
					end
				end
			end
		end
	else
		for k,v in pairs(achieveData)do
			if(tonumber(k)==num)then
				v.status = 1
			end
		end
	end
	MainBaseLayer.refreshRedBtn(true)
end