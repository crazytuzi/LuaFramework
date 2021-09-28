--WorldBossReader.lua
--/*-----------------------------------------------------------------
--* Module:  WorldBossReader.lua
--* Author:  HE Ningxu 
--* Modified: 2014年8月07日
--* Purpose: Implementation of the WorldBoss Data
-------------------------------------------------------------------*/

WorldBossTable = {}
FieldBossInfo = {}			--野外boss刷新信息	20150703
WorldBossChange = {}
WorldBossDBRefTime = {}

function loadWorldBossDB()
	if package.loaded["data.WorldBossDB"] then
		package.loaded["data.WorldBossDB"] = nil
	end

	WorldBossTable = {}
	local WorldBossDatas = require "data.WorldBossDB"	
	for _, record in pairs(WorldBossDatas or {}) do		
		local boss = {}	
		boss.monID = tonumber(record.q_mon_id) or 0
		boss.monID2 = tonumber(record.q_mon_Tid) or 0
		boss.dropID = tonumber(record.q_drop_id) or 0
		boss.count = tonumber(record.q_reward_num) or 0
		boss.reward = StrSplit(record.q_reward_id, ",") or {}
		for i = 1, boss.count do
			boss.reward[i] = tonumber(boss.reward[i])
		end
		boss.refresh = record.q_refresh_times or ""
		boss.lv = record.q_monster_lv or 0
		boss.name = record.gwmz or ""
		boss.mapname = record.cxdd or ""
		boss.mapID = record.Map_ID or 0
		boss.live = 0		
		boss.nextFresh = "10:35"
		boss.activeTick = 0
		WorldBossTable[boss.monID] = boss

		if boss.monID2 ~= boss.monID then
			WorldBossChange[boss.monID2] = boss.monID
		end
	end	

	loadFieldBossInfo()

end
function loadFieldBossInfo()
	FieldBossInfo = {}
	local worldBossRefreshInfo = ""
	local FieldBoss = require "data.MonsterInfoDB"
	for i, v in pairs(FieldBoss or {}) do
--[[		
		if 'Little Boss' == v.q_bossRelive then
			if v.q_monster_model then
				FieldBossInfo[v.q_monster_model] = {}
				FieldBossInfo[v.q_monster_model].KillTime = 0												--野外boss击杀时间
				FieldBossInfo[v.q_monster_model].refreshTime = v.q_reliveTime/1000 + FIELDBOSS_QUITTIME		--野外boss刷新间隔	单位秒
			end			
		end
]]		
		--'*,*,*,*,10:35:00-10:35:05;*,*,*,*,12:35:00-12:35:05;*,*,*,*,15:30:00-15:30:05;*,*,*,*,18:05:00-18:05:05;*,*,*,*,21:05:00-21:05:05'
		if v.q_monster_model and 6001 == v.q_monster_model then
			worldBossRefreshInfo = v.q_bossRelive
			break
		end
	end

	if #worldBossRefreshInfo > 0 then
		WorldBossDBRefTime = myStrSplit(worldBossRefreshInfo, ';')
	end
end

function myStrSplit(str, split)
	local strTab={}
	local sp=split or "&"
	local tb = {}
	while type(str)=="string" and string.len(str)>0 do
		local f=string.find(str,sp)
		local ele
		if f then
			ele=string.sub(str,f-8,f-1)
			str=string.sub(str,f+1)
		else
			local strLen = string.len(str)
			ele=string.sub(str,strLen-7,strLen)
		end

		local curStrLen = string.len(ele)
		if curStrLen > 0 then
			local h = string.sub(ele,1,curStrLen-6)
			local m = string.sub(ele,curStrLen-4,curStrLen-3)
			local s = string.sub(ele,curStrLen-1,curStrLen)
			local show = string.sub(ele,1,curStrLen-3)
			local refreshTime = {hour = tonumber(h), min = tonumber(m), sec = tonumber(s), showT = tostring(show)}
			table.insert(tb, refreshTime)
		end
		
		if not f then break	end
	end
	return tb
end