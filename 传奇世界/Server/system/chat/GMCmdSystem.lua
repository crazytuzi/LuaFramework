--GMCmdSystem.lua
require "event.EventSetDoer"
require "system.chat.ShellSystem"
--require "game.ShellSystemConfig"
----------


local logger = Logger.getLogger()
local evtFct = EventFactory.getInstance()
local evtMgr = EventManager.getInstance()
local chatSys=ChatSystem.getInstance()
--local ptManager=PetManager:getInstance()
--part of single global ShellSystem object
GMSystem={}
--------------------------------------------------------------------------------------------------------
	local propertyFunctions ={}

	propertyFunctions.hp=function ( role ,number )
	--role：角色
	--number：数量（范围：0～）
	--设置目标角色的hp。
		if not role then return end
		role:setHP(tonumber(number))
	end
	propertyFunctions.xp=function ( role ,number )
	--role：角色
	--number：数量（范围：0～）
	--设置目标角色的hp。
		if not role then return end
		role:setXP(tonumber(number))
	end
	propertyFunctions.maxhp=function ( role ,number )
	--role：角色
	--number：数量（范围：0～）
	--设置目标角色的最大hp。
		if not role then return end
		role:setMaxHP(tonumber(number))
	end
	propertyFunctions.mp=function ( role ,number )
	--role：角色
	--number：数量（范围：0～）
	--设置目标角色的mp。
		if not role  then return end
		role:setMP(tonumber(number))
	end
	propertyFunctions.maxmp=function ( role ,number )
	--role：角色
	--number：数量（范围：0～）
	--设置目标角色的最大mp。
		if not role then return end
		role:setMaxMP(tonumber(number))
	end
	propertyFunctions.vital=function ( role ,number )
	--role：角色
	--number：数量（范围：0～）
	--设置目标角色的真气。
		if not (role and role:getType() == eClsTypePlayer) then return end 
		role:setVital(tonumber(number))
	end
	
	propertyFunctions.minatk=function(role, number)
	--最小攻击力
		if role:getSchool() == 1 then
			role:setMinAT(tonumber(number))
		elseif role:getSchool() == 2 then
			role:setMinMT(tonumber(number))
		elseif role:getSchool() == 3 then
			role:setMinDT(tonumber(number))
		end
	end
	propertyFunctions.maxatk=function(role, number)
	--最大攻击力
		if role:getSchool() == 1 then
			role:setMaxAT(tonumber(number))
		elseif role:getSchool() == 2 then
			role:setMaxMT(tonumber(number))
		elseif role:getSchool() == 3 then
			role:setMaxDT(tonumber(number))
		end
	end
	propertyFunctions.minmf=function(role, number)
	--最小魔法防御力
		role:setMinMF(tonumber(number))
	end
	propertyFunctions.maxmf=function(role, number)
	--最大魔法防御力
		role:setMaxMF(tonumber(number))
	end
	propertyFunctions.mindf=function(role, number)
	--最小防御力
		role:setMinDF(tonumber(number))
	end
	propertyFunctions.maxdf=function(role, number)
	--最大防御力
		role:setMaxDF(tonumber(number))
	end

	propertyFunctions.pj=function(role, number)
	--护身
		role:setProject(tonumber(number))
	end

	propertyFunctions.pf=function(role, number)
	--破护身
		role:setProjectDef(tonumber(number))
	end

	propertyFunctions.bb=function(role, number)
	--麻痹
		role:setBenumb(tonumber(number))
	end

	propertyFunctions.bf=function(role, number)
	--麻痹抵抗
		role:setBenumbDef(tonumber(number))
	end

	propertyFunctions.pk=function(role, number)
	--PK值
		role:setPK(tonumber(number))
	end

	propertyFunctions.lu=function(role, number)
		--幸运
		--print("before change lu", role:getLuck())
		role:setLuck(number)
		--print("after change lu", role:getLuck())
	end

	propertyFunctions.sp=function(role, number)
		--移动速度
		--print("before change sp", role:getMoveSpeed())
		role:setMoveSpeed(number)
		--print("after change sp", role:getMoveSpeed())
	end

	propertyFunctions.hit=function(role, number)
		--命中
		--print("before change hit", role:getHit())
		role:setHit(number)
		--print("after change hit", role:getHit())
	end

	propertyFunctions.mis=function(role, number)
		--闪避
		--print("before change mis", role:getDodge())
		role:setDodge(number)
		--print("after change mis", role:getDodge())
	end

	propertyFunctions.cri=function(role, number)
		--暴击
		--print("before change cri", role:getCrit())
		role:setCrit(number)
		--print("after change cri", role:getCrit())
	end

	propertyFunctions.res=function(role, number)
		--韧性
		--print("before change res", role:getTenacity())
		role:setTenacity(number)
		--print("after change res", role:getTenacity())
	end

-------------------------------------------------------------------------------

	GMSystem.hb=function (me,roleID, tMoney, number,targetID )
	--number：数量。（范围：1～99999999）
	--角色获得指定数量的货币。
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		if tMoney == '0' then
			role:setIngot(tonumber(number))
		elseif tMoney == '1' then
			role:setBindIngot(tonumber(number))
		elseif tMoney == '2' then
			role:setMoney(tonumber(number))
		elseif tMoney == '3' then
			role:setBindMoney(tonumber(number))
		elseif tMoney == '5' then
			role:setSoulScore(tonumber(number))
		elseif tMoney == '6' then
			role:setVital(tonumber(number))
		else
		end
		return true
	end

	GMSystem.addt=function(me,roleID,taskID ,targetID)
	--增加任务：taskID:任务配置ID
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_taskServlet:receiveTask(role, TaskType.Main, tonumber(taskID))
		return true
	end

	GMSystem.addb=function(me,roleID,taskID ,targetID)
	--增加任务：taskID:任务配置ID
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_taskServlet:receiveTask(role, TaskType.Branch, tonumber(taskID))
		return true
	end

	GMSystem.addd=function(me,roleID, loop ,targetID)
	--增加任务：taskID:任务配置ID
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		loop = tonumber(loop)
		local dailyTaskId = g_LuaTaskDAO:getDailyTaskByLevel(role:getLevel())
		g_taskServlet:receiveTask(role, TaskType.Daily, dailyTaskId, loop)
		return true
	end

	GMSystem.endt=function(me,roleID,targetID)
	--完成任务：taskID:任务配置ID
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_taskServlet:GMfinishTask(role, 1)
		return true
	end

	GMSystem.fintask = function(me, roleID, taskType, targetID)
		-- 完成某类型的当前任务
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		taskType = tonumber(taskType)
		g_taskServlet:GMfinishTask(role, taskType)
	end
	
	--接收指定主线任务
	GMSystem.totask = function ( me, roleID, taskID, targetID )
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_taskServlet:receiveTask(role, TaskType.Main, tonumber(taskID))
	end

	--设置行会任务状态
	GMSystem.sethhrwst=function(me,roleID,state)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return false end
		local factionID = role:getFactionID()
		local factionTaskInfo = g_factionMgr:getFactionTaskInfo(factionID)
		local istate = tonumber(state)
		if factionTaskInfo then
			factionTaskInfo:setFactionTaskTargetStates(istate)
		end
		return true
	end

	--设置行会任务ID
	GMSystem.sethhrwid=function(me,roleID,taskId)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return false end
		local factionID = role:getFactionID()
		local factionTaskInfo = g_factionMgr:getFactionTaskInfo(factionID)
		local itaskId = tonumber(taskId)
		if factionTaskInfo then
			factionTaskInfo:setFactionTaskId(itaskId)
		end
		return true
	end

	-- --重置行会商店
	-- GMSystem.hhsdcz = function(me, roleID, targetID)
	-- 	local role = GMSystem.getRole(GMSystem,roleID)
	-- 	if not role then return end
	-- 	local info = g_tradeMgr:getUserInfo(role:getID())
	-- 	if info then

	-- 	end
	-- end

	--重置行会祈福
	GMSystem.hhqfcz = function(me, roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local faction = g_factionMgr:getFaction(role:getFactionID())
		if faction then
			local factionInfo = faction:getMember(role:getSerialID())
			if factionInfo then
				 factionInfo._dayPrayCounts = {}
			end
		end

	end

	GMSystem.skup=function (me,roleID, targetID )
	--将升级的技能直接学会 。
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local skillMgr = role:getSkillMgr()
		if skillMgr then
			skillMgr:learnAllLevelSkill(0)
		end
		return true
	end

	GMSystem.qieditu =function(me,rolID,mapID,x,y,targetID)
	--targetID: 目标ID
	--mapID:地图ID
	--x，y：坐标
	--切地图
		local role=GMSystem.getRole(GMSystem,rolID)
		if not role then return end
		local mapID,x,y =tonumber(mapID),tonumber(x),tonumber(y)
		if not (type(mapID)=='number' and type(x)=='number' and type(y)=='number' ) then  return end
		if not g_sceneMgr:posValidate(mapID,x,y,false) then logger:error("tele mapId %d, x %d,y %d is invalid",mapID,x,y) return end

		g_sceneMgr:enterPublicScene(role:getID(), mapID, x, y)
	end

	GMSystem.cjhh=function (me,roleID, facName,targetID )
	--facName: 行会名字
	--创建行会
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_factionMgr:createFaction(role, facName, CREATE_MODE.Force)
		--role:setAttributeValue(Attribute.pot, tonumber(number))
	end

	GMSystem.go=function (me, roleID,name, targetID)
	--name：角色名称
	--飞到指定玩家身边
		local role=g_entityMgr:getPlayerByName(tostring(name))
		local role2=GMSystem.getRole(GMSystem, tonumber(roleID))
		if not role or not role2 then return end
		local position = role:getPosition()
		local mapid = role:getMapID()
		local x, y = position.x+3, position.y+3
		print(mapid, x, y)
		if not g_sceneMgr:posValidate(mapid,x,y,false) then print(string.format("tele mapId %d, x %d,y %d is invalid",mapid,x,y)) return end

		g_sceneMgr:enterPublicScene(role2:getID(), mapid, x, y)
		return true
	end

	--获取入会日期
	GMSystem.guildday = function(me, roleID, roleName,targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then 
			warning('not find player')
			return 
		end
		local role1=g_entityMgr:getPlayerByName(tostring(roleName))
		if not role1 then
			warning('not find player:'..roleName)
			return
		end

		local faction = g_factionMgr:getFaction(role1:getFactionID())
		if faction then
			local member = faction:getMember(role1:getSerialID())
			if member then
				local info = time.tostring(tonumber(member:getJoinTime()))
				g_ChatSystem:CallTestMsg(role:getSerialID(),role:getName(),0,info,1)
			end
		end 
	end

	GMSystem.las=function ( me,roleID, skillID,targetID)
	--skillID:技能ID
	--学习指定ID的技能
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		--if skillType == '1' then
			--普通技能
		local skillMgr = role:getSkillMgr()
		skillMgr:learnAllLevelSkill(skillID)
		--end
		return true
	end

	GMSystem.lass=function ( me,roleID, skillID, level, targetID)
	--skillID:待升级技能ID,ID为0则医学技能全部升级
	--level:等级
	--设置指定技能到level等级
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		level = tonumber(level)
		skillID = tonumber(skillID)
		local skillMgr = role:getSkillMgr()
		if skillMgr then
			skillMgr:upgradeAllSkill(skillID, level)
		end
	end

	--接口对调  GMSystem.jianyin-->GMSystem.jy
	GMSystem.jianyin=function ( me,roleID, name, lastTime,targetID)
		print("gm cmd jianyin",me,roleID, name, lastTime,targetID)
		local role=g_entityMgr:getPlayerByName(name)
		if not role then return end
		--targetPlayer:setSpeakTick(noSpeakTime)
		role:setSpeakTick(lastTime)

		return true
	end

	GMSystem.zg =function ( me,roleID,itemID,number, targetID)
	--itemID 物品ID
	--number：数量。（范围：1～100）
	--添加物品
		itemID = tonumber(itemID)
		number = tonumber(number)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local itemMgr = role:getItemMgr()
		itemMgr:addBagItem(itemID, number)
		return true
	end
	GMSystem.zg1 =function ( me,roleID,itemID,number,bind, targetID)
	--itemID 物品ID
	--number：数量。（范围：1～100）
	--添加物品
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local itemMgr = role:getItemMgr()
		if bind == '1' then
			itemMgr:addBagItem(itemID, number, true)
		else
			itemMgr:addBagItem(itemID, number, false)
		end
		return true
	end

	GMSystem.uplv =function ( me,roleID,lvl,targetID)
	--lvl:等级
	--调等级
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		lvl = tonumber(lvl)
		if lvl > 70 then
			lvl = 70
		end
		role:setLevel(lvl)
		return true
	end

	GMSystem.sudu =function ( me,roleID,speed,targetID)
	--roleSId:改变速度
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		speed = tonumber(speed)
		role:setMoveSpeed(speed)
	end

	GMSystem.add=function(me,roleID,attrName,value,targetID)
	--设置玩家属性
		if not targetID then return end
		local role=GMSystem.getRole(GMSystem,roleID)
		local setAttrFunction=propertyFunctions[attrName]
		if not role  or not setAttrFunction then return end
		setAttrFunction(role,value)
		return true
	end

	GMSystem.qb=function ( me,roleID,targetID)
	--number：数量。（范围：1～100）
	--清除包裹
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local itemMgr = role:getItemMgr()
		itemMgr:clearBag()
		return true
	end

	GMSystem.settime=function(me,roleID,time,password)
		if password=="" or password==nil then
			password = "Z3PWDi4uYaVF2uS"--1000服的root密码
		end
		--2016-09-29_19:00:00
		local strDate = string.sub(time,1,10)
		local strTime = string.sub(time,12)
		print("get strDate and strTime:",strDate,strTime)
		local cmd = string.format([[echo %s|sudo date -s "%s %s"]],password,strDate,strTime)
		os.execute(cmd)
	end

	GMSystem.guai=function ( me,roleID, monID,num ,targetID)
	--monID:怪物ID
	--num：怪物数量
	--刷新怪物（在玩家周围3格内随机刷出来）
		if not targetID then return end
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		local mapID = 0
		local position = role:getPosition()
		local infodb = require("data.MonsterInfoDB")
		monID = tonumber(monID)
		moninfoID = 0
		for i, tmp in pairs(infodb) do
			if monID == tmp.q_monster_model then
				mapID = tmp.q_mapid
				moninfoID = tmp.q_id
				g_sceneMgr:enterPublicScene(role:getID(), tmp.q_mapid, tmp.q_center_x,tmp.q_center_y)
				break
			end
		end
		if mapID > 0 and moninfoID > 0 then
			local scene = g_sceneMgr:getPublicScene(mapID)
			local MonsterPos = 
			{
				-1,0,  -1,1,  0,1,   1,1,   1,0,   1,-1,   0,-1,  -1,-1, 
				-2,0,  -2,1,  -2,2,  -1,2,  0,2,   1,2,    2,2,   2,1,  2,0,  2,-1,  2,-2,  1,-2,  0,-2,  -1,-2,  -2,-2,  -2,-1,
				-3,0,  -3,1,  -3,2,  -3,3,  -2,3,  -1,3,   0,3,   1,3,  2,3,  3,3,   3,2,   3,1,   3,0,   3,-1,   3,-2,    3,-3,
				2,-3,  1,-3,  0,-3,  -1,-3, -2,-3, -3,-3,  -3,-2, -3,-1
			}
			for i=1, tonumber(num) do
				local mon = g_entityMgr:getFactory():createMonster(monID)
				if mon and scene and scene:addMonsterInfoByID(mon, moninfoID) then
					g_sceneMgr:enterPublicScene(mon:getID(), mapID, position.x+MonsterPos[i*2-1], position.y+MonsterPos[i*2], role:getCurrentLine())
					scene:addMonster(mon)
				end
			end
		end		
		return true
	end
	
	GMSystem.mon=function ( me,roleID, monID,num ,targetID)
	--monID:怪物ID
	--num：怪物数量
	--刷新怪物（在玩家周围3格内随机刷出来）
		if not targetID then return end
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		local mapID = role:getMapID()
		local position = role:getPosition()
		local infodb = require("data.MonsterInfoDB")
		monID = tonumber(monID)	
		if mapID > 0 then
			local scene = g_sceneMgr:getPublicScene(mapID)
			local MonsterPos = 
			{
				-1,0,  -1,1,  0,1,   1,1,   1,0,   1,-1,   0,-1,  -1,-1, 
				-2,0,  -2,1,  -2,2,  -1,2,  0,2,   1,2,    2,2,   2,1,  2,0,  2,-1,  2,-2,  1,-2,  0,-2,  -1,-2,  -2,-2,  -2,-1,
				-3,0,  -3,1,  -3,2,  -3,3,  -2,3,  -1,3,   0,3,   1,3,  2,3,  3,3,   3,2,   3,1,   3,0,   3,-1,   3,-2,    3,-3,
				2,-3,  1,-3,  0,-3,  -1,-3, -2,-3, -3,-3,  -3,-2, -3,-1
			}
			for i=1, tonumber(num) do
				local mon = g_entityMgr:getFactory():createMonster(monID)
				if mon and scene then
					g_sceneMgr:enterPublicScene(mon:getID(), mapID, position.x+MonsterPos[i*2-1], position.y+MonsterPos[i*2], role:getCurrentLine())
					scene:addMonster(mon)
				end
			end
		end		
		return true
	end

	--杀死周围所有怪 
	GMSystem.kl=function ( me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local scene = role:getScene()
		if scene then
			local position = role:getPosition()
			local aroundEntitys = scene:getEntities(0, position.x, position.y, 20, eClsTypeMonster, targetID) or {}
			for i=1, #aroundEntitys do
				local monster = g_entityMgr:getMonster(aroundEntitys[i])
				if monster and monster:getSerialID() ~= 9001 and monster:getSerialID() ~= 9002 then
					g_copyMgr:onMonsterKill(monster:getSerialID(), role:getID(), monster:getID())
					--monster:reward()
					g_FactionCopyMgr:onMonsterKill(monster:getSerialID(), role:getID(), monster:getID())
					monster:quitScene()
				end
			end
		end
		return true
	end
	GMSystem.zj =function ( me,roleID,itemID,number, star, strength, quality, targetID)
	--itemID 物品ID
	--number：数量。（范围：1～100）
	--star, strength, quality
	--添加装备 star, strength, quality 星级， 强化等级，品质
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local configMgr = g_entityMgr:getConfigMgr()
		proto = configMgr:getItemProto(itemID)
		if proto and proto.type == 1 then
			local itemMgr = role:getItemMgr()
			for i=1, number do
				local slotIdx = itemMgr:findFreeSlot()
				local err = 0
				if itemMgr:addItemBySlot(Item_BagIndex_Bag, slotIdx, itemID, 1, false, err)  then
					local item = itemMgr:findItem(slotIdx)
					if item then
						local equipProp = item:getEquipProp()
						if equipProp then
							equipProp:setStarLevel(star)
							equipProp:setStrengthLevel(strength)
							equipProp:setQualityLevel(quality)
						end
					end
				end
			end
		end
		
		return true
	end
	
	--重载脚本模块 script文件夹下的模块路径
	--TODO:已经注册过的 Singleton 模块特殊处理 需要先删除注册表中的旧模块
	--CopySystem.lua
	--if CopySystem then
	--	print("已经创建过 CopySystem")
	--	g_eventMgr:removeEventListener(CopySystem.getInstance())
	--end

	GMSystem.reload = function( me,roleID, modulestr)
		print("重载",modulestr)
		reloadModule(modulestr)
	end

	GMSystem.zi =function ( me,roleID, slot, type, value, targetID)
	--设置装备属性:比如星级，强化等级，品质，升级经验
	--slot 装备包裹位置
	--type 想要设置的类型
	--value 想要设置的值
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		value = math.abs(value)
		local itemMgr = role:getItemMgr()
		local equip = itemMgr:findItem(slot, Item_BagIndex_EquipmentBar)
		if equip then
			local equipProp = equip:getEquipProp()
			if equipProp then
				if type == "1" then
					equip:unloadProp(role)
					equipProp:setStarLevel(value)
				elseif type == "2" then
					equip:unloadProp(role)
					equipProp:setStrengthLevel(value)
				elseif type == "3" then
					equip:unloadProp(role)
					equipProp:setQualityLevel(value)
				elseif type == "4" then
					equipProp:setStrengthXp(value)
				end
				equip:loadProp(role)
				itemMgr:syOneEquipment(slot)
			end
		end
	end

	GMSystem.gy =function ( me,roleID, level, star, targetID)
	--调整光翼等级
	--光翼ID
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		level = tonumber(level)
		star = tonumber(star)
		if level > 7 or level < 1 then return end
		if star < 1 or star > 5 then return end
		local  school = role:getSchool()
		local  wingID = (school + 3) * 1000 + level * 10 + star
		g_wingMgr:dealPomoteGM(role:getSerialID(), wingID)
	end

	GMSystem.gyjn =function ( me,roleID, pos,level, targetID)
	--调整光翼技能等级
	--光翼ID
		pos = tonumber(pos)
		level = tonumber(level)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end

		g_wingMgr:learnSkillGM(role:getSerialID(), pos, level)
	end

	GMSystem.zbqh =function ( me,roleID, pos, level, targetID)
	--调整装备强化等级
	--光翼ID
		pos = tonumber(pos)
		level = tonumber(level)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local itemMgr = role:getItemMgr()
		if pos == 0 then
			for i=1,11 do
				itemMgr:GMquipStrength(i, level)
			end
		else
			itemMgr:GMquipStrength(pos, level)
		end
	end

	GMSystem.gfm = function( me,roleID, money,targetID)
	--增加帮会资源
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local factionID = role:getFactionID()
		local faction = g_factionMgr:getFaction(factionID)
		if faction then
			local m = faction:getMoney()
			faction:setMoney(m + tonumber(money))
		end
	end

	GMSystem.rfm = function( me,roleID, money,targetID)
	--减少帮会资源
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local factionID = role:getFactionID()
		local faction = g_factionMgr:getFaction(factionID)
		if faction then
			local m = faction:getMoney()
			m = m-tonumber(money)
			if m < 0 then m = 0 end
			faction:setMoney(m)
		end
	end

	GMSystem.sfl = function( me,roleID, level,targetID)
	--设置帮会等级
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local factionID = role:getFactionID()
		local faction = g_factionMgr:getFaction(factionID)
		if faction then
			level = math.abs(tonumber(level))
			if level > 9 then level = 9 end
			faction:setLevel(level)
			faction:setFactionSyn(true)
			if faction:getBannerLvl() > level then
				faction:setBannerLvl(level)
			end
		end
	end

	GMSystem.rcy = function( me,roleID,targetID)
	--重置副本CD数据
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local copyPlayer = g_copyMgr:getCopyPlayer(role:getID())
		if copyPlayer then
			copyPlayer:GMClear()
		end
	end

	GMSystem.rstTower = function(me,roleID,targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local copyPlayer = g_copyMgr:getCopyPlayer(role:getID())
		if copyPlayer then
			copyPlayer:setTowerCopyResetNum(0)
			copyPlayer:setTowerCopyProgress(1)
			ret = 0
			local retStr = {}
			retStr.roleId = roleID
			retStr.result = ret
			fireProtoMessage(roleID, COPY_SC_RESETTOWERCOPY, 'CopyResetTowerCopyRetProtocol', retStr)
			copyPlayer:setUpdateCopyCnt(true)
		end
	end
	GMSystem.rstShareTask = function(me,roleID,targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(role:getSerialID())
		if not roleTaskInfo then
			return
		end
		roleTaskInfo:freshSharedTaskStamp()
	end

	GMSystem.wudi = function( me,roleID,targetID)
	--设置玩家无敌
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		role:setMinAT(1000000)
		role:setMaxAT(1000000)
		role:setMinMT(1000000)
		role:setMaxMT(1000000)
		role:setMinDT(1000000)
		role:setMaxDT(1000000)
		role:setMinDF(1000000)
		role:setMaxDF(1000000)

		role:setMinMF(1000000)
		role:setMaxMF(1000000)
		role:setMinDT(1000000)
		role:setMinDT(1000000)
	end

	GMSystem.xp = function( me,roleID,xpValue,targetID)
	--设置玩家经验
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		--role:setXP(xpValue)
		--Tlog[PlayerExpFlow]
		local old = role:getXP()
		addExpToPlayer(role,xpValue-old,-3)
	end

	GMSystem.jjc = function( me,roleID,rank,targetID)
	--设置竞技场排名
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		--g_sinpvpMgr:changeRank(role:getSerialID(), tonumber(rank))
	end

	GMSystem.jjc2 = function( me,roleID,value,targetID)
	--设置竞技场次数
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end		
		--g_sinpvpMgr:setCount(role:getSerialID(), tonumber(value))
	end

	GMSystem.sh = function( me,roleID,layer,targetID)
	--设置最后打的守护副本层数 
	--layer是层数不是副本ID
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		layer = tonumber(layer)
		g_copyMgr:setLastGuardLayer(role:getID(), layer)
	end

	GMSystem.cb = function( me,roleID,targetID)
	--清空BUFF
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		role:getBuffMgr():clearAllBuff()
	end

	GMSystem.addbuff = function(me, roleID, buffID, time, targetID)
		-- 添加buff
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local  eCode
		role:getBuffMgr():addBuff(tonumber(buffID), eCode, nil, true, tonumber(time))
	end

	--清除一个buff
	GMSystem.delbuff = function(me, roleID, buffID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local  eCode
		role:getBuffMgr():delBuff(tonumber(buffID))
	end

	GMSystem.rcyg = function( me,roleID,targetID)
	--重置副本CD数据
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local copyPlayer = g_copyMgr:getCopyPlayer(role:getID())
		if copyPlayer then
			copyPlayer:GMClearGuard()
		end
	end
	--热更新
	GMSystem.hot = function( me,roleID, hotstr, targetID)
		HotUpdateFun(hotstr)
		--[[if hotstr == "hot1" then
			require "system.hotUpdate.HotUpdate1"
		elseif hotstr == "hot2" then
			require "system.hotUpdate.HotUpdate2"
		elseif  hotstr == "hot3" then
			package.loaded["system.chargeactivity.ChargeActivityConstants"]=nil
			require "system.chargeactivity.ChargeActivityConstants"
		end]]
		if hotstr == "1" or hotstr == "2" or hotstr == "3" then
			g_DataMgr:hotUpdata(tonumber(hotstr))
		end
	end
	--打印战斗力
	GMSystem.zl = function( me,roleID,targetID)
	--重置副本CD数据
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		print("---roleBattle",role:getbattle())
	end
	GMSystem.goto =function(me,rolID,mapID,x,y,targetID)
		GMSystem.qieditu(me,rolID,mapID,x,y,targetID)
	end	
	GMSystem.changet=function(me,roleID,targetRoleSId,taskID ,targetID)
	--增加任务：taskID:任务配置ID
		local role=GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local targetPlayer=g_entityMgr:getPlayerBySID(tonumber(targetRoleSId))
		if targetPlayer then
			g_taskServlet:receiveTask(targetPlayer, TaskType.Main, tonumber(taskID))
		end
		return true
	end
	--设置玩家元宝充值
	GMSystem.cz=function (me,roleID, value, czType, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		value = tonumber(value)
		if value > 10000000 then
			value = 10000000
		end

		czType = tonumber(czType)

		if not czType then
			czType = 0
		end
		
		value =  value * 10
		role:setIngot(role:getIngot() + value)
		g_listHandler:notifyListener("onPlayerCharge", role, value, czType)
		return true
	end

	--打开聊天框GM命令
	GMSystem.opGM=function (me,roleID, value, targetID)
		value = tonumber(value)
		if value ==  0 then
			g_isOpenShellCmd = false
		else
			g_isOpenShellCmd = true
		end
		return true
	end

	--禁言
	GMSystem.jy=function (me,roleID, targetSID, noSpeakTime, targetID)
		--name：禁言对象名字
		--lastTime:禁言持续时间
		print("gm cmd jy",toString(me),roleID, targetSID, noSpeakTime, targetID)
		targetSID = tonumber(targetSID)
		noSpeakTime = tonumber(noSpeakTime)
		local targetPlayer = g_entityMgr:getPlayerBySID(targetSID)
		if not targetPlayer then
			return
		end
		
		--ChatSystem.getInstance():doSilent(role:getSerialID(), lastTime)
		ChatSystem.getInstance():doSilent(targetPlayer:getSerialID(), noSpeakTime)
		return true
	end

	--世界boss重生
	GMSystem.sjiboss=function (me, roleID, bossID, targetID)		
		bossID = tonumber(bossID)
		g_WorldBossMgr:GMReliveWorldBoss(bossID)
	end

	--重置世界boss衰弱
	GMSystem.sjibsczsr=function(me, roleID, targetID)
		g_WorldBossMgr:resetWordBossWeak()
	end

	--活动控制
	GMSystem.hdkq=function (me,roleID, id, isOpen, targetID)
		id = tonumber(id)
		isOpen = tonumber(isOpen)
		if id > 0 then			
			if isOpen > 0 then
				g_normalLimitMgr:gmOn(id)
			else
				g_normalLimitMgr:gmOff(id)
			end
			return true
		elseif id == 0 then
			local data = g_normalLimitMgr:getAllActivityConfig()
			for _, v in pairs(data) do
				if isOpen > 0 then
					g_normalLimitMgr:gmOn(v.activityID)
				else
					g_normalLimitMgr:gmOff(v.activityID)
				end
			end
		end
	end
	
	--加载排行榜
	GMSystem.lRank=function (me,roleID, targetID)
		g_RankMgr:rankInit()
		return true
	end

	-- 通过GM命令统计本周魅力榜
	GMSystem.phb =function ()
		g_RankMgr:GMupdateGlamous()
		return true
	end

	--功能控制
	GMSystem.gnkg=function (me,roleID, msgId, isOpen, errId, targetID)
		msgId = tonumber(msgId)
		isOpen = tonumber(isOpen)
		errId = tonumber(errId)
		
	
		if isOpen > 0 then
			g_frame:deleSheildMsg(msgId)
		else
			g_frame:addSheildMsg(msgId, errId)
		end

		return true
	end
	--开启领地战
	GMSystem.ldz=function (me,roleID, manorID, isOpen, targetID)
		manorID = tonumber(manorID)
		isOpen = tonumber(isOpen)
		if isOpen > 0 and not g_manorWarMgr:isManorActing(manorID) then
			g_manorWarMgr:openManor(manorID)
		end

		if isOpen == 0 and g_manorWarMgr:isManorActing(manorID) then
			g_manorWarMgr:closeManor(manorID)
		end
	end

	--设置领地公会
	GMSystem.ldgs=function(me, roleID, manorID, facName, targetID)
		g_manorWarMgr:GmSetManorFac(manorID, facName)
	end

	--开启关闭沙巴克
	GMSystem.shabake=function (me,roleID, isOpen, targetID)
		isOpen = tonumber(isOpen)

		if isOpen > 0 then
			if not g_shaWarMgr:getOpenState() then
				g_shaWarMgr:openSha()
			end
		else
			if g_shaWarMgr:getOpenState() then
				g_shaWarMgr:closeSha()
			end
		end
	end

	--设置沙巴克公会
	GMSystem.sgs=function(me, roleID, facName, targetID)
		g_shaWarMgr:GmSetShaFac(facName)
	end

	--设置角色属性值
	GMSystem.sx=function (me,roleID, id, value, targetID)
		id = tonumber(id)
		value = tonumber(value)
		local player = GMSystem.getRole(GMSystem,roleID)
		
		if not player then
			return
		end
		
		if id == 1 then	--攻击力下限
		   player:setMinAT(value)
		elseif id == 2 then--攻击力上限
			player:setMaxAT(value)
		elseif id == 3 then--魔法攻击力下限
			player:setMinMT(value)
		elseif id == 4 then--魔法攻击力上限
			player:setMaxMT(value)
		elseif id == 5 then--道术攻击力下限
			player:setMinDT(value)
		elseif id == 6 then--道术攻击力上限
			player:setMaxDT(value)
		elseif id == 7 then--物理防御力下限
			player:setMinDF(value)
		elseif id == 8 then--物理防御力上限
			player:setMaxDF(value)
		elseif id == 9 then--魔法防御力下限
			player:setMinMF(value)
		elseif id == 10 then--魔法防御力上限
			player:setMaxMF(value)
		elseif id == 11 then--血量最大值
			player:setMaxHP(value)
		elseif id == 12 then--魔法量最大值
			player:setMaxMP(value)		
		elseif id == 19 then--命中
			player:setDodge(value)
		elseif id == 20 then--闪避
			player:setHit(value)
		elseif id == 21 then--幸运
			player:setLuck(value)
		elseif id == 22 then--暴击
			player:setCrit(value)
		elseif id == 23 then--韧性
			player:setTenacity(value)
		elseif id == 24 then--护身
			player:setProject(value)
		elseif id == 25 then--护身穿透
			player:setProjectDef(value)
		elseif id == 26 then--麻痹
			player:setBenumb(value)
		elseif id == 27 then--麻痹抵抗
			player:setBenumbDef(value)
		elseif id == 28 then--当前血量
			player:setHP(value)
		elseif id == 29 then--当前魔法
			player:setMP(value)
		end
	end

	
	--设置角色PK值
	GMSystem.pkz=function (me,roleID, pkValue, targetID)
		pkValue = tonumber(pkValue)
		local player = GMSystem.getRole(GMSystem,roleID)
		
		if not player then
			return
		end

		player:setPK(pkValue)
	end

	--设置角色测试数据
	GMSystem.cqsj=function (me,roleID, targetID)
		local player = GMSystem.getRole(GMSystem,roleID)
		
		if not player then
			return
		end

		player:setLevel(40)
		player:setIngot(10000000)
		player:setBindIngot(10000000)
		player:setMoney(10000000)
		player:setVital(10000000)
		player:setSoulScore(10000000)
		local itemMgr = player:getItemMgr()
		itemMgr:addBagItem(1001, 99)
		itemMgr:addBagItem(1094, 99)
		itemMgr:addBagItem(30000, 99)
		itemMgr:addBagItem(1100, 99)
		itemMgr:addBagItem(1100, 99)
		GMSystem.addt(me,roleID, 10147,targetID)
		g_rideMgr:firstActiveRide(player)
		g_wingMgr:firstActiveWing(player)

		--给勋章
		local itemID = 30004
		if player:getSchool() == 2 then
			itemID = 30005
		elseif player:getSchool() == 3 then
			itemID = 30006
		end
		
		local itemMgr = player:getItemMgr()
		itemMgr:addItem(1, itemID, 1, 1, 0, 0, 0, 0)
	end

	--设置角色测试数据
	GMSystem.sw=function (me,roleID, num, targetID)
		local player = GMSystem.getRole(GMSystem,roleID)
		num = tonumber(num)
		if not player then
			return
		end
		player:setVital(num)
	end

	GMSystem.hhcf=function (me,roleID, num, targetID)
		num = tonumber(num)
		local player = GMSystem.getRole(GMSystem,roleID)
		
		if not player then
			return
		end
		local faction = g_factionMgr:getFaction(player:getFactionID())
		if not faction then
			return
		end
		faction:setMoney(faction:getMoney() + num)
	end

	GMSystem.hhjy=function (me,roleID, num, targetID)
		num = tonumber(num)
		local player = GMSystem.getRole(GMSystem,roleID)
		
		if not player then
			return
		end
		local faction = g_factionMgr:getFaction(player:getFactionID())
		if not faction then
			return
		end
		faction:addXp(num)
	end

	GMSystem.bg=function (me,roleID, num, targetID)
		num = tonumber(num)
		local player = GMSystem.getRole(GMSystem,roleID)
		
		if not player then
			return
		end
		local faction = g_factionMgr:getFaction(player:getFactionID())
		if not faction then
			return
		end

		local facMem = faction:getMember(player:getSerialID())
		if facMem then
			facMem:setContribution(num)
		end

		faction:addUpdateMem(roleSID)
	end

	GMSystem.xtkg=function (me,roleID, funId, isActive, targetID)
		funId = tonumber(funId)
		isActive = tonumber(isActive)

		local switch = isActive > 0 and true or false

		g_gameSwitchMgr:setFunActive(funId, switch)
	end

	--显示玩家战斗力
	GMSystem.zdl=function (me,roleID, targetID)
		pkValue = tonumber(pkValue)
		local player = GMSystem.getRole(GMSystem,roleID)
		
		if not player then
			return
		end
		
		local tb = {}
		for i=1,9 do
			tb[i] = player:getSysBattle(i)
		end

		local str = "guangyi="..tb[1]..",zuoqi="..tb[2]..",jineng="..tb[3]..",chengjiu="..tb[4]..",zhanji="..tb[5]..",chenghao="..tb[6]..",shuxing="..tb[8]..",zhuangbei="..tb[9]

		g_ChatSystem:CallTestMsg(player:getSerialID(),player:getName(),0,str,7)
	end

	GMSystem.pz=function (me,roleID, isOpen, targetID)
		local player = GMSystem.getRole(GMSystem,roleID)
		if not player then
			return
		end
		isOpen = toNumber(isOpen)
		if isOpen > 0 then
			COMPETITION_ONCE_TIME = 60			--拼战的持续时间
			COMPETITION_NEXT_ACTIVE_TIME = 60 		--下次拼战激活时间
			COMPETITION_DAILY_TIME = 4				--每天最大拼战次数
		else
			COMPETITION_ONCE_TIME = 10 * 60			--拼战的持续时间
			COMPETITION_NEXT_ACTIVE_TIME = 25 * 60 		--下次拼战激活时间
			COMPETITION_DAILY_TIME = 4				--每天最大拼战次数
		end
	end

	

	--重置行会副本
	GMSystem.hhfb=function (me,roleID, targetID)
		g_FactionCopyMgr:resetCopy()
		return true
	end
	
	--重置行会副本设置次数
	GMSystem.clearhhfb=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return false end
		local factionID = role:getFactionID()
		local faction = g_factionMgr:getFaction(factionID)
		if faction then
			g_FactionCopyMgr:clearFactionCopyOpenTimes(factionID)
			return true
		end
		return false
	end

	--设置行会副本开启时间
	GMSystem.sethhfb = function( me,roleID,copyID,strtime,roleMID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local factionID = role:getFactionID()
		local faction = g_factionMgr:getFaction(factionID)
		if faction and roleMID ~= nil then
			local copyID = tonumber(copyID)
			local proto = g_LuaFactionCopyDAO:getProto(copyID)
			if not proto then
				g_ChatSystem:QueryMsgIntoChat(roleID, "#sethhfb copyID is invalid "..tostring(copyID))
				return
			end
			
			if #strtime > 10 then
				g_ChatSystem:QueryMsgIntoChat(roleID, "#sethhfb strtime is error string"..strtime)
				return
			end

			--正在活动中
			if g_FactionCopyMgr:getCopyBookByFaction(factionID) then
				g_ChatSystem:QueryMsgIntoChat(roleID, "#sethhfb factioncopy is in progress")
				return
			end

			
			local tt, sectime, retstrtime = g_FactionCopyMgr:getOpenSecTimes(strtime)
			if sectime == 0 then
				g_ChatSystem:QueryMsgIntoChat(roleID, "#sethhfb strtime is error string"..strtime)
				return
			end

			g_FactionCopyMgr:setFactionCopyOpenTimer(factionID,copyID,strtime)

			--通知所有在线行会玩家行会副本开启时间更改
			local ret = {}
			ret.copyID = copyID
			ret.openTime = retstrtime
			g_factionMgr:sendProtoMsg2AllMem(factionID, FACTIONCOPY_SC_NOTIFY_SETOPEN, "FactionCopySetOpenNotify", ret)
		else
			g_ChatSystem:QueryMsgIntoChat(roleID, "#sethhfb error params")
		end
		return true
	end

	--重置计数副本
	GMSystem.clearfb=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local copyPlayer = g_copyMgr:getCopyPlayer(role:getID())
		if copyPlayer then
			local allCDData = copyPlayer:getCopyCDCount()
			for mainID, count in pairs(allCDData) do
				copyPlayer:clearEnterCDCount(mainID)
			end
		end
		return true
	end

	--重载支付配置
	GMSystem.reloadMidasCfg=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_tPayMgr:ReloadMidasCfg()
		g_ChatSystem:QueryMsgIntoChat(roleID, "ReloadMidasCfg sucess!")
		return true
	end
	
	--开启支付
	GMSystem.openPay=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_tPayMgr:SetPaySwitch(true)
		g_ChatSystem:QueryMsgIntoChat(roleID, "NOW PAY OPEN!")
		return true
	end

	--关闭支付
	GMSystem.closePay=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_tPayMgr:SetPaySwitch(false)
		g_ChatSystem:QueryMsgIntoChat(roleID, "NOW PAY CLOSE!")
		return true
	end
	
	--开启支付测试
	GMSystem.openPayCS=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_tPayMgr:SetPayTest(true)
		g_ChatSystem:QueryMsgIntoChat(roleID, "NOW IS PAY TEST!")
		return true
	end

	--关闭支付测试
	GMSystem.closePayCS=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_tPayMgr:SetPayTest(false)
		g_ChatSystem:QueryMsgIntoChat(roleID, "NOW IS NOT PAY TEST!")
		return true
	end

	--设置支付操作间隔(秒)
	GMSystem.setPayOp=function (me,roleID, strvalue, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		if targetID == nil then return end

		local value = tonumber(strvalue)
		g_tPayMgr:SetPayOpInterval(value)
		return true
	end

	--设置支付流水重做允许失败的次数 
	GMSystem.setPayFailed=function (me,roleID, strvalue, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		if targetID == nil then return end

		local value = tonumber(strvalue)
		g_tPayMgr:SetPayRedoFailedTotalTimes(value)
		g_ChatSystem:QueryMsgIntoChat(roleID, "NOW RedoPayFailed times " .. tostring(value))
		return true
	end

	--重新载入重做流水
	GMSystem.reloadRedo=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_tPayMgr:ReloadRedo()
		g_ChatSystem:QueryMsgIntoChat(roleID, "reloadRedo sucess! ")
		return true
	end

	--查看系统支付信息
	GMSystem.getPayInfo=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local info = g_tPayMgr:GetPayInfo()
		g_ChatSystem:QueryMsgIntoChat(roleID, info)
		print(info)
		return true
	end

	--查看加速校验信息
	GMSystem.getSpeedCheck=function (me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end

		local value = g_entityMgr:getSpeedCheckInterval()
		g_ChatSystem:QueryMsgIntoChat(roleID, "Sys SpeedCheck Interval(s) " .. tostring(value))
		print(value)
		return true
	end

	--设置加速校验间隔时间(/min) 0为关闭检测
	GMSystem.setSpeedCheck=function (me,roleID, strvalue, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		if targetID == nil then return end

		local value = tonumber(strvalue) * 60
		g_entityMgr:setSpeedCheckInterval(value)
		g_ChatSystem:QueryMsgIntoChat(roleID, "Sys SpeedCheck Interval(s) " .. tostring(value))
		return true
	end

	GMSystem.getRole=function (me,targetID)
		if not targetID then return nil end
		local role=g_entityMgr:getPlayerBySID(targetID)
		return role
	end

	-- 重置镖车
	GMSystem.czbc=function (me,roleID,targetID)
		g_commonMgr:resetDart(tonumber(targetID))
		return true
	end

	-- 设置称号
	GMSystem.szch=function (me,roleID,titleID)
		local player = GMSystem.getRole(GMSystem,roleID)
		if player then
			g_achieveMgr:GMaddTitle(player:getSerialID(), tonumber(titleID))
		end
	end

	-- 清除活动配置数值及活动数据
	GMSystem.clearActivity=function()
		g_DataMgr:clearConfig()
	end

	-- 悬赏任务GM测试指令
	GMSystem.xuanshang = function( me,roleID,actiontype,param1,param2)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		print("in xuanshang", me, roleID, actiontype, param1, param2)
		
		actiontype = toNumber(actiontype)
		param1 = toNumber(param1)
		param2 = toNumber(param2)
		
		if actiontype == 0 then --发布悬赏任务
			print("发布悬赏任务")
			g_RewardTaskMgr:create(roleID, param1)
		elseif actiontype == 1 then --查询悬赏任务
			print("查询悬赏任务")
			g_RewardTaskMgr:select(roleID, param1, param2)
		elseif actiontype == 2 then --领取悬赏任务
			print("领取悬赏任务")
			g_RewardTaskMgr:receive(roleID, param1, param2)
		elseif actiontype == 3 then --完成悬赏任务
			print("完成悬赏任务")
			g_RewardTaskMgr:finish(roleID, param1)
		elseif actiontype == 4 then --删除悬赏任务
			print("删除悬赏任务")
			g_RewardTaskMgr:delete(roleID, param1)
		elseif actiontype == 5 then --获取悬赏任务
			print("获取悬赏任务")
			g_RewardTaskMgr:selectmine(roleID)
		elseif actionType == 6 then --放弃自己领取的悬赏任务
			print("放弃自己领取的悬赏任务")
			g_RewardTaskMGr:giveup(roleID)
		else
			print("悬赏任务非法操作类型")
		end
	end
	
	-- 玩家无敌
	GMSystem.wd = function( me,roleID,type)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		role:setWD(toNumber(type))
		
		local message = "setwd "..tostring(type)
		local retBuff = g_ChatSystem:getComMsgBuffer(0, "", 0, message, Channel_ID_System, false, "", 0, 0, {})
		g_engine:fireLuaEvent(role:getID(), retBuff)
	end
	
	-- 重载怪物AI规则
	GMSystem.rlai = function(me,roleID,modelId)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		role:reloadMonsterRules(toNumber(modelId))
		
		local message = "rlai "..tostring(modelId)
		local retBuff = g_ChatSystem:getComMsgBuffer(0, "", 0, message, Channel_ID_System, false, "", 0, 0, {})
		g_engine:fireLuaEvent(role:getID(), retBuff)
	end
	
	GMSystem.ailog = function(me,roleID,serialId)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		
		role:setAILogMonsterSerialId(toNumber(serialId))
		
		local message = "ailog "..tostring(serialId)
		local retBuff = g_ChatSystem:getComMsgBuffer(0, "", 0, message, Channel_ID_System, false, "", 0, 0, {})
		g_engine:fireLuaEvent(role:getID(), retBuff)
	end
	
	--未知暗殿获取Boss的位置
	GMSystem.wz = function (me,roleID, targetID)
		local player = GMSystem.getRole(GMSystem,roleID)
		if player then
			local str = g_UndefinedMgr:GMGetBossPos()
			g_ChatSystem:CallTestMsg(player:getSerialID(),player:getName(),0,str,1)
		end
	end

	--未知暗殿boss刷新
	GMSystem.wzsx = function(me,roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_UndefinedMgr:GMFreshBoss()
	end
	
	--重载掉落表
	GMSystem.reloadDrop = function()
		print("reloading DropDB")
		require "itemEntry"
		reloadDropItem()	--必须在最前面
		g_DigBossMgr:loadDropItem()
		g_XunBaoMgr:loadProBasic()
	end
	
	--重载怪物表
	GMSystem.reloadMon = function()
		print("reloading MonsterDB")
		require "entityEntry"
		reloadMonsterConfigs()	--必须在最前面
		g_commonMgr:loadMonsterDrop()
		g_MonAttackMgr:loadMonBossName()
	end	
	--重载怪物刷新表
	GMSystem.reloadMonInfo = function()
		print("reloading MonsterInfoDB")
		require "sceneEntry"
		reloadMonsters()	--必须在最前面
		g_MonAttackMgr:loadMonsterInfo()
		loadFieldBossInfo()
		g_YanhuoMgr:loadMonsterInfo()
		g_shaWarMgr:loadMonsterInfo()
		g_LuoxiaMgr:loadMonsterInfo()
		g_FactionCopyMgr:loadMonsterInfo()
		g_EnvoyMgr:loadMonsterInfo()
	end
	GMSystem.version = function(me,roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		g_taskServlet:sendErrMsg2Client(role:getID(), -89, 1,{g_serverVersion})
	end

	--自杀
	GMSystem.wyzs = function(me,roleID)
		local  role = GMSystem.getRole(GMSystem, roleID)
		if not role then return end
		--role:setHP(0)
		print("kill self")
		local skillMgr = role:getSkillMgr()
		if skillMgr then
			skillMgr:suicide()
		end
	end

	GMSystem.wyzb = function(me, roleID)
		--角色模组
		local role = GMSystem.getRole(GMSystem, roleID)
		if not role then return end
		role:setLevel(70)
		g_taskServlet:receiveTask(role, TaskType.Main, 10183)
		local sex = role:getSex()
		local school = role:getSchool()

		local itemMgr = role:getItemMgr()
		if itemMgr then
			--包裹和仓库扩充到最大
			local bags = {Item_BagIndex_Bag,Item_BagIndex_Bank}
			for _, v in pairs(bags) do
				local bag = itemMgr:getBag(v)
				if bag then
					local cap = bag:getCapacity()
					itemMgr:extendBagFree(0,Item_Bag_Max_Capacity - cap,v)
				end
			end			
		
			--橙色装备+20
			require "system.chat.GMConstant"			
			for i, v in pairs(EQUIP_INDEX) do
				local itemID = THIRD_EQUIP[school][i][1]
				if i == "UpperBody" then
					itemID = THIRD_EQUIP[school][i][sex]
				end
				local cnt = 1
				local equipPos = EQUIP_INDEX[i]
				if i == "Wrist" or i == "Ring" then
					cnt = 2
					equipPos = 0
				end
				local ret = itemMgr:addItem(Item_BagIndex_Bag,itemID, cnt, false, 0, 0,20, 0)
				-- local bag = itemMgr:getBag(Item_BagIndex_Bag)
				if ret then
					for j=1,cnt do
						local item = itemMgr:findItemByItemID(itemID, Item_BagIndex_Bag)
						if item then						
							local slot = item:getSlotIndex()
							if slot then
								itemMgr:install(Item_BagIndex_Bag, slot, 3, 0, 0)
							end
						end						
					end					
				end
			end
			--清理包裹
			itemMgr:clearBag(Item_BagIndex_Bag, true)
			--加金币			
			role:setIngot(9989988)
			role:setBindIngot(9989988)
			role:setMoney(9989988)
			role:setBindMoney(9989988)
			role:setSoulScore(9989988)

			itemMgr:addBagItem(1219, 900, false, 0, 0)
			itemMgr:addBagItem(1074, 990, false, 0, 0)
			itemMgr:addBagItem(1043, 99, false, 0, 0)
			itemMgr:addBagItem(1001, 99, false, 0, 0)
			itemMgr:addBagItem(1000, 99, false, 0, 0)
			itemMgr:addBagItem(20036, 99, false, 0, 0)
			itemMgr:addBagItem(20037, 99, false, 0, 0)
			itemMgr:addBagItem(20023, 99, false, 0, 0)
			itemMgr:addBagItem(6010, 1, false, 0, 0)
			itemMgr:addBagItem(6011, 1, false, 0, 0)
			itemMgr:addBagItem(6012, 1, false, 0, 0)
			itemMgr:addBagItem(6013, 1, false, 0, 0)
		end

		--增加新坐骑
		g_rideMgr:addNewRide(role:getID(), 3101)
		g_rideMgr:addNewRide(role:getID(), 8888)
		--仙翼
		if school == 1 then
			g_wingMgr:dealPomoteGM(role:getSerialID(), 4041)
		elseif school == 2 then
			g_wingMgr:dealPomoteGM(role:getSerialID(), 5041)
		elseif school == 3 then
			g_wingMgr:dealPomoteGM(role:getSerialID(), 6041)
		end
		for i=1,4 do
			g_wingMgr:learnSkillGM(role:getSerialID(), i, 2)
		end
		--学习全部技能
		local skillMgr = role:getSkillMgr()
		if skillMgr then
			skillMgr:learnAllLevelSkill(0)
		end
		return true
	end

--[[
	GMSystem.ghzy = function(me, roleID, targetSchool)
		-- 更换职业
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end

		local school = role:getSchool()
		--print("school, targetSchool", school, targetSchool)
		if school == targetSchool then
			return true
		end
		role:setSchool(targetSchool)

		local itemMgr = role:getItemMgr()
		if itemMgr then
			for i=1,11 do
				itemMgr:deleteItem(Item_BagIndex_EquipmentBar, i, 0)
			end		
			local item =  itemMgr:findItem(Item_EquipPosition_Medal, Item_BagIndex_EquipmentBar)
			if item then
				item:setProtoID(MEDAL_ID[targetSchool])
				itemMgr:syOneEquipment(Item_EquipPosition_Medal)
			end
		end
		return true
	end

	GMSystem.ghxb = function(me, roleID, toSex)
		-- 变更性别
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local sex = role:getSex()
		if sex == toSex then return true end

		role:setSex(toSex)
		local itemMgr = role:getItemMgr()
		if itemMgr then
			for i=1,11 do
				itemMgr:deleteItem(Item_BagIndex_EquipmentBar, i, 0)
			end
		end
		return true
	end
]]
	GMSystem.cjhjh = function(me, roleID)
		-- 激活所有成就
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local playerAchieve = g_achieveMgr:getAchievePlayer(role:getSerialID())
		if not playerAchieve then  return end
		local data = require "data.AchieveDB" or {}

		for _, v in pairs(data) do
			playerAchieve:finishAchievememt(v.q_id)
		end		
	end

	GMSystem.cjjh = function(me, roleID, achieveID)
		-- 激活一个成就
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local playerAchieve = g_achieveMgr:getAchievePlayer(role:getSerialID())
		if not playerAchieve then  return end

		playerAchieve:finishAchievememt(tonumber(achieveID))
	end

	GMSystem.cjhcz = function(me, roleID)
		-- 重置所有成就
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local playerAchieve = g_achieveMgr:getAchievePlayer(role:getSerialID())
		if not playerAchieve then return end
		playerAchieve:init()
		local doneAchieve = playerAchieve:getDoneAchieve()
		if doneAchieve then
			doneAchieve = {}
			playerAchieve:castAchieve2DB()
		end
	end

	--多人守卫公主血量锁定
	GMSystem.drgzhp = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then return end
		local copyPlayer = g_copyMgr._playerCopyData[role:getID()]
		if copyPlayer then
			-- print("copy player ")
			local curCopyID = copyPlayer:getCurrentCopyID()
			local curInstId = copyPlayer:getCurCopyInstID()
			local proto = g_copyMgr:getProto(curCopyID)
			-- print("curCopyID, curInstId", curCopyID, curInstId)
			if proto and curInstId > 0 then
				local copyType = proto:getCopyType()
				if copyType and copyType == CopyType.MultiCopy then
					-- print("copy type is multicopy")
					local book = g_copyMgr:getCopyBookById(curInstId, copyType)
					if book then
						-- print("get book")
						local statue = g_entityMgr:getMonster(book:getStatueID())
						if statue then
							-- print("get statue entity")
							statue:getBuffMgr():addBuff(16, eCode, nil, true, 0)
						end
					end
				end
			end
		end
	end

	-- --锁定恶魔城公主血量
	-- GMSystem.emcgzhp = function(me, roleID)
	-- 	local role = GMSystem.getRole(GMSystem,roleID)
	-- 	if not role then return end
	-- 	local copyPlayer = g_copyMgr._playerCopyData[role:getID()]
	-- 	if copyPlayer then
	-- 		local curCopyID = copyPlayer:getCurrentCopyID()
	-- 		local curInstId = copyPlayer:getCurCopyInstID()
	-- 		local proto = g_copyMgr:getProto(curCopyID)
	-- 		if proto and curInstId > 0 then
	-- 			local copyType = proto:getCopyType()
	-- 			if copyType and copyType == CopyType.GuardCopy then
	-- 				local book = g_copyMgr:getCopyBookById(curInstId, copyType)
	-- 				if book then
	-- 					local statue = g_entityMgr:getMonster(book:getStatueID())
	-- 					if statue then
	-- 						statue:getBuffMgr():addBuff(16, eCode, nil, true, 0)
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	--yx测试
	GMSystem.qlmb=function(me, roleID)
		local player = GMSystem.getRole(GMSystem,roleID)
		if player then
			g_adoreMgr:gmFreshAdore(player:getID())
		end
	end

	--战队3v3
	GMSystem.zd3v3=function(me, roleID, param1, param2, param3)
		local player = GMSystem.getRole(GMSystem,roleID)
		if player then
			if tonumber(param1) == 1 then
				g_configMgr:gmOpenFighTeamGame(tonumber(param2), tonumber(param3))
			elseif tonumber(param1) == 2 then
				g_configMgr:gmEnterFighTeamGame(player:getSerialID())
			end
		end
	end

	--yx测试
	GMSystem.yxtest = function(me, roleID, param1, param2, param3)
		local player = GMSystem.getRole(GMSystem,roleID)
		if player then
			g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.DART)
		end
	end

	--给自己发邮件
	GMSystem.sendselfmail=function(me, roleID, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then 
			warning('cannot get player')
			return 
		end		
		local offlineMgr = g_entityMgr:getOfflineMgr()
		if offlineMgr then
			local email = offlineMgr:createEamil()
			if email then
				email:setDesc('TEST')
				offlineMgr:recvEamil(role:getSerialID(), email)
			end
		end
	end

	--发红包
	GMSystem.fhb=function(me, roleID, num, type, param)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then 
			warning('cannot get player')
			return
		end	
		g_RedBagMgr:sendRedBag(role, toNumber(num, 1), toNumber(type, 0), param)
	end

	--设置师徒任务ID
	GMSystem.strw=function(me, roleID, taskID)
		g_masterMgr:gmSetTaskID(toNumber(taskID, 1))
	end

	--完成师徒任务
	GMSystem.wcstrw=function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then 
			warning('cannot get player')
			return
		end	
		g_masterMgr:gmFinishTask(tonumber(roleID))
	end

	--签到
	GMSystem.singin=function(me, roleID, times)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then 
			warning('cannot get player')
			return
		end	
		g_ActivityMgr:gmSingIn(role:getID(), tonumber(times))
	end

	--设置活动开服第几天
	GMSystem.day=function(me, roleID, day)
		day = toNumber(day, 1)
		if day < 20 then
			g_ActivityMgr:GMsetStartTime(day)
		end
	end

	--全服广播
	GMSystem.qfgb=function(me, roleID, content)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then 
			warning('cannot get player')
			return
		end
		local msg = tostring(content)
		g_ChatSystem:SystemMsgIntoChat(0, 1, msg, EVENT_PUSH_MESSAGE, 0, 0)
	end

	--全服倍率修改
	GMSystem.baolv = function(me, roleID, num, targetID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then 
			warning('cannot get player')
			return
		end

		g_commonMgr:gmReardTimes(tonumber(num))
	end
	--modify qingyizhi 
	GMSystem.qyz = function(me, roleID, value1, value2,value3)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
		end
		require "system.swornbrothers.SwornBrosManager"
		local sworn = g_swornBrosMgr:getSwornBrosByPlayer(role)
		if not sworn then
			return
		end
		local value = tonumber(value1)
		if value > 0 then	
			sworn:increaseRelation(value, false)
		elseif value == 0 then
			sworn:decreaseRelation()
		end
	end
	GMSystem.qyzsp = function(me, roleID, value)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
		end
		require "system.swornbrothers.SwornBrosManager"
		local sworn = g_swornBrosMgr:getSwornBrosByPlayer(role)
		if not sworn then
			return
		end
		local v = tonumber(value)
		sworn:setSkillPoints(v)
		sworn:saveSkills()
	end
	GMSystem.jieyi = function(me, roleID, value1)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
		end
		local sworn = g_swornBrosMgr:getSwornBrosByPlayer(role)
		if sworn then
			sworn:printAllData()
		end
		if tonumber(value1) == 1 then
			reloadModule("system.swornbrothers.SwornBrosConstant")
		elseif tonumber(value1) == 2 then
			if sworn then
				local props = sworn:getAllPsvSkillsProp()
				for k,v in pairs(props) do
					print(k..":"..v)
				end
			end
		end
	end

	-- 接取指定:悬赏任务
	GMSystem.xsrw = function(me, roleID, taskID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end
		if not taskID then return end
		g_RewardTaskMgr:create(role:getSerialID(), 0, true, toNumber(taskID))
	end

	-- 坐骑
	GMSystem.zq = function(me, roleID, ride)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		if ride then
			local rideType = tonumber(ride)
			if rideType == 2 then
				g_rideMgr:addNewRide(role:getID(), 3101)
			elseif rideType == 3 then
				g_rideMgr:addNewRide(role:getID(), 8888)
			elseif rideType == 1 then
				g_rideMgr:firstActiveRide(role)
			end
		end
	end

	-- 删除坐骑
	GMSystem.sczq = function(me, roleID, idx)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		if idx then
			g_rideMgr:deleRideByIndex(role:getID(), tonumber(idx))
		end
	end

	-- 活跃度
	GMSystem.hyd = function(me, roleID, val)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		local info = g_normalMgr:getPlayerInfo(role:getID())
		if info then
			info:setIntegral(tonumber(val))
		end
	end

	--迷仙阵
	--进入
	GMSystem.mazeEnter = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end
		
		g_mazeMgr:enterMaze(role)
	end

	--重置
	GMSystem.mazeReset = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		g_mazeMgr:resetMaze(role)
	end
	
	--前进 (北)0 (东)1 (南)2 (西)3
	GMSystem.mazeMove = function(me, roleID, dir)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		if dir then
			g_mazeMgr:enterNext(role, tonumber(dir))
		end
	end

	--跳跃
	GMSystem.mazeJump = function(me, roleID, index)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		if index then
			g_mazeMgr:jumpOther(role, tonumber(index))
		end
	end

	--退出
	GMSystem.mazeExit = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		g_mazeMgr:exitMaze(role)
	end

	--Dump
	GMSystem.mazeDump = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		g_mazeMgr:dumpMyMaze(role)
	end

	--开始
	GMSystem.mazeStart = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		g_mazeMgr:mazeNodeGameStart(role)
	end

	--领奖
	GMSystem.mazePrize = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		g_mazeMgr:mazeNodeGamePrize(role)
	end

	--设置事件类型
	GMSystem.setMazeType = function(me, roleID, type, index, id)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end
		
		print('setMazeType ', type, index)
		local ret = false
		if id then
			ret = g_mazeMgr:setMazeNodeEventType(role, tonumber(type), tonumber(index))
		else
			ret = g_mazeMgr:setMazeNodeEventType(role, tonumber(type))
		end

		g_ChatSystem:QueryMsgIntoChat(roleID, 'setMazeType '..tostring(ret))
	end

	--设置事件类型
	GMSystem.setMazeState = function(me, roleID, state, index, id)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end
		
		print('setMazeType ', state, index)
		local ret = false
		if id then
			ret = g_mazeMgr:setMazeNodeEventState(role, tonumber(state), tonumber(index))
		else
			ret = g_mazeMgr:setMazeNodeEventState(role, tonumber(state))
		end
		g_ChatSystem:QueryMsgIntoChat(roleID, 'setMazeState '..tostring(ret))
	end

	--重置设置次数
	GMSystem.resetMazeTime = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end
		
		local ret = g_mazeMgr:resetTime(role)
		g_ChatSystem:QueryMsgIntoChat(roleID, 'resetMazeTime '..tostring(ret))
	end

	--照亮迷仙阵
	GMSystem.zhaoliangMaze = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end
		
		local ret = g_mazeMgr:zhaoliangMaze(role)
		g_ChatSystem:QueryMsgIntoChat(roleID, 'zhaoliangMaze '..tostring(ret))
	end

	--重载迷仙阵怪物
	GMSystem.reloadMazeEvent = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end

		LoadMazeEventCfg()
		g_ChatSystem:QueryMsgIntoChat(roleID, 'reloadMazeEvent sucess')
	end

	--重载拍卖行数据
	GMSystem.rlstall = function(me, roleID)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end		
		loadStallConfig()
		g_ChatSystem:QueryMsgIntoChat(roleID, 'reloadMazeEvent sucess')
	end

	GMSystem.tulong = function(me, roleID, param1, param2)
		local role = GMSystem.getRole(GMSystem,roleID)
		if not role then
			warning('cannot get player')
			return
		end
		local copyPlayer = g_copyMgr:getCopyPlayer(role:getID())
		if not copyPlayer then

			warning("cannot get copyPlayer")
		end
		local p1 = tonumber(param1)
		local p2 = tonumber(param2)
		if p1 == 1 then  		--完成
			g_copyMgr:onFinishSingleInst(copyPlayer, p2)
		elseif p1 == 2 then --finish inst from client
			copyPlayer:reqFinishSingleInst(p2)
		elseif p1 == 3 then --remove passed inst 
			copyPlayer:removePassedSingleInst(p2)
		elseif p1 == 4 then --reset daily inst
			copyPlayer:resetDailyInst()
		elseif p1 == 5 then --pass all
			copyPlayer:passAllSingleInsts()			
		elseif p1 == 6 then --print data
			copyPlayer:printSingleInstData()
		end
	end

	GMSystem.qsj = function(me, roleID, param1)
		param1 = tonumber(param1)
		
		local str
		if param1 == 1 then
			str = "shawar"
		else
			str = "manorwar"
		end


		sql = string.format("truncate %s;",str)
		apiEntry.exeSQL(sql, rId)
	end

	GMSystem.xgdl = function(me, roleID, monID)	
		require "itemEntry"
		local role = GMSystem.getRole(GMSystem, roleID)
		if not role then
			warning('not find player')
			return
		end
		if not monID then
			return
		end
		local id = tonumber(monID)
		if id > 0 then
			local monsterDatas = reloadModule('data.MonsterDB')
			local monsterdata = MONSTER_DATA:new()
			local dropID = 0
			for _, record in pairs(monsterDatas or {}) do
				if tonumber(record.q_id) == id then
					dropID = tonumber(record.diaol) or 0
					break
				end
			end
			if dropID > 0 then
				changeDropItem(dropID)
			end
		end
	end