local GameCharacter = {}

local m_tile_step = {{0,-1},{1,-1},{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1}}

--自动攻击技能
-- local autoSkill = {
-- 	[GameConst.JOB_ZS] = {
-- 		GameConst.SKILL_TYPE_CiShaJianShu, GameConst.SKILL_TYPE_BanYueWanDao, GameConst.SKILL_TYPE_LieHuoJianFa
-- 	},
-- 	[GameConst.JOB_FS] = {
-- 		GameConst.SKILL_TYPE_MoFaDun, GameConst.SKILL_TYPE_LeiDianShu, GameConst.SKILL_TYPE_BingPaoXiao, GameConst.SKILL_TYPE_DiYuLeiGuang
-- 	},
-- 	[GameConst.JOB_DS] = {
-- 		GameConst.SKILL_TYPE_YouLingDun, GameConst.SKILL_TYPE_ZhaoHuanShenShou, GameConst.SKILL_TYPE_ShiDuShu, GameConst.SKILL_TYPE_LingHunHuoFu
-- 	}
-- }

--辅助技能
local toneUpSKills = {
	GameConst.SKILL_TYPE_JiTiYinShenShu,
	GameConst.SKILL_TYPE_YouLingDun,
	GameConst.SKILL_TYPE_QunTiZhiLiao,
	GameConst.SKILL_TYPE_ShenShengZhanJiaShu
}

--无需目标技能
local noTargetSkills = {
	GameConst.SKILL_TYPE_MoFaDun,
	GameConst.SKILL_TYPE_KangJuHuoHuan,
	GameConst.SKILL_TYPE_DiYuLeiGuang,
	GameConst.SKILL_TYPE_YeManChongZhuang,
}

-- 开关类技能
local flagSkills = {
	GameConst.SKILL_TYPE_LieHuoJianFa, GameConst.SKILL_TYPE_PoTianZhan, skill_type == GameConst.SKILL_TYPE_ZhuRiJianFa
}

--先打开再选择格子技能
local selectGridSkills = {
	-- GameConst.SKILL_TYPE_HuoQiang, 
	GameConst.SKILL_TYPE_JiTiYinShenShu, 
	GameConst.SKILL_TYPE_QunTiZhiLiao, 
	GameConst.SKILL_TYPE_YouLingDun,
	GameConst.SKILL_TYPE_QunTiLeiDianShu,
}

--打开后可持续点击地面释放技能
local castGridSkills = {
	GameConst.SKILL_TYPE_HuoQiang
}

--攻击类技能需要目标
local attackSkills = {
	GameConst.SKILL_TYPE_LeiDianShu, 
	GameConst.SKILL_TYPE_BingPaoXiao, 
	GameConst.SKILL_TYPE_LingHunHuoFu,
	GameConst.SKILL_TYPE_ShiDuShu,
	GameConst.SKILL_TYPE_DanTiShiDuShu,
	GameConst.SKILL_TYPE_SiWangZhiYan,
	GameConst.SKILL_TYPE_ShiBuYiSha,
}
------------------------------------------------------------------------------------------------------------------

local function isTaskTargetMon(mon)
	if GameSocket.mTaskTargetMap ~= GameSocket.mNetMap.mMapID then
		-- print("-------------isTaskTargetMon",GameSocket.mTaskTargetMap,GameSocket.mNetMap.mMapID)
		return true
	end
	if GameSocket.mTaskTargetMon and mon:NetAttr(GameConst.net_type)==GameConst.GHOST_MONSTER then
		-- if GameSocket.mTaskTargetMon == mon:NetAttr(GameConst.net_name) then
			-- print("-------------isTaskTargetMon,net_name",mon:NetAttr(GameConst.net_type),mon:NetAttr(GameConst.net_name))
		-- end
		return GameSocket.mTaskTargetMon == mon:NetAttr(GameConst.net_name)
	else
		-- print("-------------isTaskTargetMon,mon",mon:NetAttr(GameConst.net_type),mon:NetAttr(GameConst.net_name))
		return true
	end
end

local function getMonsterOwner(monster)
	if monster then
		local monId = monster:NetAttr(GameConst.net_id)
		local owner = GameSocket:getMonsterOwner(monId)
		if owner then
			return owner.hiterid
		end
	end
	return 0
end

local function checkMoFaDun(srcid)
	if GameSocket.mNetBuff then
		local tab = GameSocket.mNetBuff[srcid]
		if tab then
			for i=1,10 do
				if tab[30000+i] then return true end
			end
		end
	end
end

local function checkShiDuShu(srcid)
	if GameSocket.mNetBuff then
		local tab = GameSocket.mNetBuff[srcid]
		if tab then
			for i=1,10 do
				if tab[31000+i] then return true end
			end
		end
	end
end

local function checkShengJiaShu(srcid)
	if GameSocket.mNetBuff then
		local tab = GameSocket.mNetBuff[srcid]
		if tab then
			for i=1,13 do
				if tab[32000+i] then return true end
			end
		end
	end
end

-- 自动打怪优先级比较
local function isMonHigherPriority(monA, monB)
	-- print("isMonHigherPriority")
	if GameCharacter._mainAvatar and monA and monB then
		local disA = cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(monA.mX,monA.mY))
		local disB = cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(monB.mX,monB.mY))
		local isBossA = monA:NetAttr(GameConst.net_isboss)
		isBossA = type(isBossA) == "boolean" and 0 or isBossA
		local isBossB = monB:NetAttr(GameConst.net_isboss)
		isBossB = type(isBossB) == "boolean" and 0 or isBossB

		local ownerA = getMonsterOwner(monA)
		-- ownerA = type(ownerA) == "boolean" and 0 or ownerA
		local ownerB = getMonsterOwner(monB)
		-- ownerB = type(ownerB) == "boolean" and 0 or ownerB

		local isOwnerA = (ownerA == GameCharacter.mID or ownerA == 0)
		local isOwnerB = (ownerB == GameCharacter.mID or ownerB == 0)

		local isTargetA = isTaskTargetMon(monA)
		local isTargetB = isTaskTargetMon(monB)
		-- print("monA is", GameCharacter.mID, monA:NetAttr(GameConst.net_name), ownerA, isBossA, disA, isTargetA)
		-- print("monB is", GameCharacter.mID, monB:NetAttr(GameConst.net_name), ownerB, isBossB, disB, isTargetB)
		if (isTargetA == isTargetB) then
			-- 优先判定归属
			-- if (isOwnerA == isOwnerB) then -- 都为我的归属怪或者都不是
				if isBossA == isBossB then
					if isBossA == 1 then -- 同为Boss,优先少血,同少血则优先距离
						--if monA.mHp == monB.mHp then
							return (disA > 0 and disA < disB)
						--else
						--	return monA.mHp < monB.mHp
						--end
					else --同为小怪, 优先距离,同距离则优先少血
						if disA == disB then
							return monA.mHp < monB.mHp
						else
							return (disA > 0 and disA < disB)
						end
					end
				else
					return isBossA == 1
				end
			-- elseif not isOwnerB then
			-- 	if isOwnerA then
			-- 		return true
			-- 	end
			-- 	if ownerA == 0 then
			-- 		return true
			-- 	end
			-- end
		else
			return isTargetA == true
		end
	end
end

-- 自动打怪寻找目标怪物
local function getAutoFightMonster()
	local netMon, tempMon
	local netMons=NetCC:getNearGhost(GameConst.GHOST_MONSTER)
	-- print("getAutoFightMonster", #netMons);
	for _,v in ipairs(netMons) do
		tempMon = GameCharacter.getAimGhost(v)
		-- print("11111111", v, tempMon)
		if tempMon then
			--这段是判断怪物是否可以寻路过去,不可以的话则跳过
			if not netMon or isMonHigherPriority(tempMon, netMon) then
				GameSocket.mTargetMap = GameSocket.mNetMap.mMapID
				GameSocket.mTargetMapX = tempMon:NetAttr(GameConst.net_x)
				GameSocket.mTargetMapY = tempMon:NetAttr(GameConst.net_y)
				--print(GameSocket.mNetMap.mMapID,GameSocket.mTargetMap,GameSocket.mTargetMapX,GameSocket.mTargetMapY)
				if GameCharacter.searchCrossMapPath() then
					netMon = tempMon
				end
			end
			--这段是直接返回怪物,不判断是否可以寻路
			--if GameCharacter.searchCrossMapPath() then
			--	netMon = tempMon
			--end
		end
	end
	return netMon
end

--判断是否增益(辅助)技能(增益技能可对自己释放，伤害技能不能对自己释放)
local function isToneUpSkill(skill_type)
	return table.indexof(toneUpSKills, skill_type)
end

--判断是否无需目标技能
local function isNoTargetSkill(skill_type)
	return table.indexof(noTargetSkills, skill_type)
end

--判断是否点击格子释放技能
local function isSelectGridSkill(skill_type)
	return table.indexof(selectGridSkills, skill_type)
end

local function isCastGridSkill(skill_type)
	return table.indexof(castGridSkills, skill_type)
end

local function isAttackSkill(skill_type)
	return table.indexof(attackSkills, skill_type)
end

------------------技能释放对象相关函数------------------
local function canCastSkillToAimGhost (skill_type, mAimGhost)
	if mAimGhost.mType == GameConst.GHOST_PLAYER then
		return true
	elseif mAimGhost.mType == GameConst.GHOST_MONSTER then
		return true
	elseif mAimGhost.mType == GameConst.GHOST_SLAVE then
		return true
	elseif mAimGhost.mType == GameConst.GHOST_THIS then
		return true
	end
	return false
end

--自动技能相关

local function getDistanceSQ(mAimGhost)
	if mAimGhost then
		return cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(mAimGhost.mX,mAimGhost.mY))
	end
	return -1
end

--战士(战士技能服务器控制)
local function getWarriorAiSkill()
	local skill_type = GameConst.SKILL_TYPE_YiBanGongJi
	if not GameSocket.m_netSkill[GameConst.SKILL_TYPE_ZhuRiJianFa] then
		return skill_type
	end
	if not GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ZhuRiJianFa) then
		return skill_type
	end
	if not GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ZhuRiJianFa) then
		return skill_type
	end
	if not GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_ZhuRiJianFa) then
		return skill_type
	end
	skill_type = GameConst.SKILL_TYPE_ZhuRiJianFa
	return skill_type
end

--法师群攻和单体的自动切换
local function getWizardAiSkill(mAimGhost)
	local skill_type = GameConst.SKILL_TYPE_YiBanGongJi;
	if #NetCC:getGhostsAroundPos(mAimGhost.mX, mAimGhost.mY, GameConst.GHOST_MONSTER) > 1 and GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_BingPaoXiao) then -- 目标附近多只怪物
		if GameSocket.m_netSkill[GameConst.SKILL_TYPE_BingPaoXiao] and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_BingPaoXiao)  then
			skill_type = GameConst.SKILL_TYPE_BingPaoXiao
		end
	end
	
	if (not mAimGhost) or getDistanceSQ(mAimGhost) <= 2  then
		if #NetCC:getGhostsAroundPos(GameCharacter.mX, GameCharacter.mY, GameConst.GHOST_MONSTER) > 1 and GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_DiYuLeiGuang) then -- 自身附近近多只怪物
			if GameSocket.m_netSkill[GameConst.SKILL_TYPE_DiYuLeiGuang] and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_DiYuLeiGuang)  then
				skill_type = GameConst.SKILL_TYPE_DiYuLeiGuang
			end
		end
	end

	if skill_type == GameConst.SKILL_TYPE_YiBanGongJi then
		if GameSocket.m_netSkill[GameConst.SKILL_TYPE_LeiDianShu] and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_LeiDianShu) and GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_LeiDianShu) then
			skill_type = GameConst.SKILL_TYPE_LeiDianShu
		end
	end
	return skill_type
end

--道士目标没有中毒状态则施毒，否则火符
local function getTaoistAiSkill(mAimGhost)
	local skill_type = GameConst.SKILL_TYPE_YiBanGongJi
	local mAimGhostID = mAimGhost:NetAttr(GameConst.net_id)
	if not checkShiDuShu(mAimGhostID) then -- 没有中毒自动施毒术
		if GameSocket.m_netSkill[GameConst.SKILL_TYPE_ShiDuShu] and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ShiDuShu) and GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ShiDuShu) then
			skill_type = GameConst.SKILL_TYPE_ShiDuShu
		end
	end
	if skill_type == GameConst.SKILL_TYPE_YiBanGongJi then
		if GameSocket.m_netSkill[GameConst.SKILL_TYPE_LingHunHuoFu] and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_LingHunHuoFu) then
			skill_type = GameConst.SKILL_TYPE_LingHunHuoFu
		end
	end
	return skill_type
end

-- 有目标时的简单ai技能
local function getEasyAiSkill(mAimGhost)
	local skill_type = GameConst.SKILL_TYPE_YiBanGongJi
	if GameCharacter.mJob == GameConst.JOB_ZS then
		skill_type = getWarriorAiSkill(mAimGhost)
	elseif GameCharacter.mJob == GameConst.JOB_FS then
		skill_type = getWizardAiSkill(mAimGhost)
	elseif GameCharacter.mJob == GameConst.JOB_DS then
		skill_type = getTaoistAiSkill(mAimGhost)
	end
	return skill_type
end

-- 无目标时默认ai技能
local function getAiSkill()
	local skill_type = GameConst.SKILL_TYPE_YiBanGongJi
	if GameCharacter._mainAvatar:NetAttr(GameConst.net_job) == GameConst.JOB_ZS then
		
	elseif GameCharacter._mainAvatar:NetAttr(GameConst.net_job) == GameConst.JOB_DS then
		if GameSocket.m_netSkill[GameConst.SKILL_TYPE_LingHunHuoFu] then
			skill_type = GameConst.SKILL_TYPE_LingHunHuoFu
		end
	elseif GameCharacter._mainAvatar:NetAttr(GameConst.net_job) == GameConst.JOB_FS then
		if GameSocket.m_netSkill[GameConst.SKILL_TYPE_LeiDianShu] then
			skill_type = GameConst.SKILL_TYPE_LeiDianShu
		end
	end

	return skill_type
end

-- 技能mp检测，如果不足，法师默认雷电，道士默认火符 ???(为啥这么干)
local function updateEnabledSkill(skill_type)
	GameCharacter.updateAttr()
	local aiSkill = skill_type
	if GameCharacter.mJob == GameConst.JOB_FS then
		aiSkill = GameConst.SKILL_TYPE_LeiDianShu
		if GameBaseLogic.checkMpEnough(skill_type) and skill_type ~= GameConst.SKILL_TYPE_YiBanGongJi then
			aiSkill = skill_type
		end
	elseif GameCharacter.mJob == GameConst.JOB_DS then
		aiSkill = GameConst.SKILL_TYPE_LingHunHuoFu
		if GameBaseLogic.checkMpEnough(skill_type) and skill_type ~= GameConst.SKILL_TYPE_YiBanGongJi then
			aiSkill = skill_type
		end
	end
	return aiSkill
end

-- 点击快捷攻击按钮释放的技能
local function checkDefaultSkillAttack()
	local default_skill = GameConst.SKILL_TYPE_YiBanGongJi
	if GameCharacter._mainAvatar then
		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		if job == GameConst.JOB_FS then
			default_skill = GameConst.SKILL_TYPE_LeiDianShu
		elseif job == GameConst.JOB_DS then
			if GameSocket.mChangeAimFirst then -- 切换目标后第一下攻击必毒
				GameSocket.mChangeAimFirst = false
				if GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ShiDuShu) then
					default_skill = GameConst.SKILL_TYPE_ShiDuShu
				end
			else
				default_skill = GameConst.SKILL_TYPE_LingHunHuoFu
				if not checkShiDuShu(GameSocket.mLastAimGhost) then
					default_skill = GameConst.SKILL_TYPE_ShiDuShu
				end
			end
		end
	end
	return default_skill
end

--判断是否和目标位置重合
local function checkSkilCastOnwerPos(mAimGhost)
	if GameCharacter.mX == mAimGhost.mX and GameCharacter.mY == mAimGhost.mY then
		return true
	end
end

-- 判断技能施法距离
local function checkSkillCastDistance(skill_type, mAimGhost)
	local nsd = GameBaseLogic.getSkillDesp(skill_type)
	if nsd then
		if cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(mAimGhost.mX,mAimGhost.mY)) <= nsd.mMaxDis * nsd.mMaxDis then
			return true
		end
	end
	return false
end

-- 判断是否站在物品上
local function checkStandOnItem()
	local netGhost = NetCC:getGhostAtPos(GameCharacter._mainAvatar:PAttr(GameConst.avatar_x),GameCharacter._mainAvatar:PAttr(GameConst.avatar_y),GameConst.GHOST_ITEM)
	if #netGhost>0 then
		local item=NetCC:getGhostByID(netGhost[1])
		local owner = item:NetAttr(GameConst.net_item_owner)
		owner = type(owner) == "boolean" and 0 or owner
		if owner > 0 and owner ~= GameCharacter.mID then
			item=nil
		end

		if item and item:NetAttr(GameConst.net_state) ~= true then
			return true
		end
	end
	return false
end

-- 额外刺杀位（除水平，垂直，对角线）
local function isExtraCiShaPos(mAimGhost, dir)
	if GameCharacter.mX+m_tile_step[dir+1][1]*2==mAimGhost.mX and math.abs(GameCharacter.mY+m_tile_step[dir+1][2]*2-mAimGhost.mY) == 1 then
		print("/////////////isExtraCiShaPos///////////111111")
		return true;
	elseif math.abs(GameCharacter.mX+m_tile_step[dir+1][1]*2-mAimGhost.mX) == 1 and GameCharacter.mY+m_tile_step[dir+1][2]*2 == mAimGhost.mY then
		print("/////////////isExtraCiShaPos///////////222222")
		return true;
	end
end

---------------------------------------------------------以上为内部函数---------------------------------------------------------
local _aimGhostID = 0

function GameCharacter.initVar(isDead)

	-- GameCharacter._isDead = false
	-- GameCharacter._aimGhostID = 0 -- 当前选中目标
	_aimGhostID = 0
	GameCharacter._lastAimID = 0

	GameCharacter._readyUseSkill = true
	GameCharacter._moveToNearAttack = false
	GameCharacter._autoFight = false
	GameCharacter._autoPick = false
	GameCharacter._aiKeepAttack = false
	GameCharacter._aiKeepSkill = nil
	GameCharacter._readyKeepAttack = false
	GameCharacter._aiKeepTime = 0

	GameCharacter._waitSkill = nil

	GameCharacter._curMap = ""
	GameCharacter._mapMonGen = {}
	GameCharacter._runToIndex = nil

	GameCharacter._mapGhostList = {}
	GameCharacter._findToGhostId = nil

	GameCharacter._aiStartPos = nil
	GameCharacter._autoMoving = false
	GameCharacter._targetNPCName = ""
	GameCharacter._moveEndAutoPick = false

	-- GameCharacter._autoFightTime = 0
	GameCharacter._autoItemTime = 0

	GameCharacter._moveAndFinding=false
	GameCharacter._findingDir=0
	GameCharacter._lastFindingDir=0
	-- GameCharacter._pickingItem=0
	-- GameCharacter._lastUseSkill=0
	GameCharacter._statusList = {}
	-- if not retainGhost then
	-- 	GameCharacter._mainAvatar = nil
	-- end
	GameCharacter._mainAvatar = nil

	if not isDead then
		--死亡不清理
		GameCharacter.mDartSprite = nil
		GameCharacter.mDartHalo = nil
		GameCharacter.mDartClothSprite = nil
	end

	GameCharacter._pickItemDelay = nil

	GameCharacter.needCheckPickItem = false
	
	GameCharacter.waiteForRandom = false

end

function GameCharacter.getAimGhostID()
	return _aimGhostID
end

function GameCharacter.setAimGhostID(aimid)
	_aimGhostID = aimid

	GameCharacter._moveAndUseMagic = false
	GameCharacter._moveToUseMagic = nil
	GameCharacter._moveToNearAttack = false
	-- GameCharacter._aiKeepAttack = false
	GameCharacter._aiKeepSkill = false
	GameCharacter._readyKeepAttack = false
	GameCharacter._aiKeepTime = 0
	
	-- 这里需要做一些处理，如果改变之后的对象类型和之前不一样，可能会有问题
end

--当前地图的怪物分布，用于挂机寻怪
function GameCharacter.setMapGhostList(mapid,list)
	if mapid and list then
		if mapid == GameSocket.mNetMap.mMapID then
			GameCharacter._curMap = mapid
			GameCharacter._mapGhostList = clone(list)
		end
	else
		GameCharacter._mapGhostList = {}
	end
end

function GameCharacter.pushGridSkillWait(skill_type,px,py)
	if not GameCharacter._aiKeepAttack and not GameCharacter._readyKeepAttack then
		GameSocket:UseSkill(skill_type, px, py, 0)
	else
		GameCharacter._waitSkill = {type=skill_type,px=px,py=py}
	end
end

-- 点击快捷攻击键攻击(攻击类技能)
function GameCharacter.quickAttack(skill_type)
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	GameCharacter.stopAutoDart()
	GameCharacter.stopAutoFight()

	local noAutoChange = false;
	if not skill_type then GameCharacter._aiKeepAttack = true end
	if skill_type and isAttackSkill(skill_type) then
		noAutoChange = true
		GameCharacter._aiKeepAttack = false
	end
	-- 非攻击类技能直接释放
	if skill_type and not isAttackSkill(skill_type) then
		GameCharacter.startCastSkill(skill_type)
		return
	end

	if GameCharacter.checkCollect() then return end

	if not skill_type then skill_type = checkDefaultSkillAttack() end

	local mAimGhost = _aimGhostID and GameCharacter.getAimGhost(_aimGhostID) or nil
	if not mAimGhost then
		mAimGhost = getAutoFightMonster()
		if mAimGhost then
			CCGhostManager:selectSomeOne(mAimGhost:NetAttr(GameConst.net_id))
		end
	end
	if mAimGhost then
		GameCharacter.startCastSkill(skill_type, noAutoChange)
	end
end

function GameCharacter.checkCollect()
	local mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
	local pixes_main = GameCharacter.updateAttr()
	-- if mAimGhost then
	-- 	print(mAimGhost,mAimGhost.mType,mAimGhost.mCollectTime)
	-- end
	if mAimGhost and mAimGhost.mType == GameConst.GHOST_MONSTER and mAimGhost.mCollectTime and mAimGhost.mCollectTime > 0 then
		-- if mAimGhost.mHp > 0 and not GameSocket.m_bCollecting then
			GameCharacter._moveToNearAttack = true
			if pixes_main then
				pixes_main:clearAutoMove()
			end
			if pixes_main and pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE then
				mainrole_action_start(2,pixes_main)
			end
		-- end
		return true
	end
end

function GameCharacter.startCastSkill(skill_type, noAutoChange)
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	--判断是否是持续施放技能的类型， 是的话，点击技能按钮需要取消
	if isCastGridSkill(skill_type) then
		if not GameSocket.mCastGridSkill then
			GameSocket.mCastGridSkill = skill_type
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_GROUND_SKILL_STATE, skill_type = skill_type})
		else
			if skill_type ~= GameSocket.mCastGridSkill then
				GameSocket.mCastGridSkill = skill_type
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_GROUND_SKILL_STATE})
			else
				GameSocket.mCastGridSkill = nil
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_GROUND_SKILL_STATE, skill_type = skill_type})
			end
		end
		return
	end

	if isSelectGridSkill(skill_type) then
		if not GameSocket.mSelectGridSkill then -- 置为选中技能等待点击地面释放
			GameSocket.mSelectGridSkill = skill_type
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_GRID_SKILL_STATE})
		else -- 已有选中技能，则取消
			if not (skill_type == GameSocket.mSelectGridSkill) then
				GameSocket.mSelectGridSkill = skill_type
			else
				GameSocket.mSelectGridSkill = nil
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_GRID_SKILL_STATE})
		end
		return
	end

	-- if GameSocket.actionMoving then
	-- 	return false
	-- end

	skill_type = updateEnabledSkill(skill_type)

	if not skill_type then return end

	if skill_type == GameConst.SKILL_TYPE_ShiDuShu then
		GameSocket.mChangeAimFirst = false
	end

	local isFlagSkill = false
	if skill_type == GameConst.SKILL_TYPE_LieHuoJianFa
	or skill_type == GameConst.SKILL_TYPE_PoTianZhan or skill_type == GameConst.SKILL_TYPE_ZhuRiJianFa 
		or skill_type == GameConst.SKILL_TYPE_GongShaJianShu or skill_type == GameConst.SKILL_TYPE_BanYueWanDao
		or skill_type == GameConst.SKILL_TYPE_JiuJieJianFa
		 or skill_type == GameConst.SKILL_TYPE_GuiYouZhan
		  or skill_type == GameConst.SKILL_TYPE_ShenXuanJianFa
		   or skill_type == GameConst.SKILL_TYPE_ZhanLongJianFa
		    or skill_type == GameConst.SKILL_TYPE_PoKongJianFa then
		isFlagSkill = true
		--开关技能无需目标
	end
	local mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
	local pixes_main = GameCharacter.updateAttr()

	-- if mAimGhost and mAimGhost.mType == GameConst.GHOST_MONSTER and mAimGhost.mCollectTime and mAimGhost.mCollectTime > 0 then
	-- 	if mAimGhost.mHp > 0 and not GameSocket.m_bCollecting then
	-- 		GameCharacter._moveToNearAttack = true
	-- 		if pixes_main then
	-- 			pixes_main:clearAutoMove()
	-- 		end
	-- 		if pixes_main and (pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE or pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_PREPARE) then
	-- 			mainrole_action_start(2,pixes_main)
	-- 		end
	-- 	end
	-- 	return true
	-- end

	if not isFlagSkill and skill_type ~= GameConst.SKILL_TYPE_YiBanGongJi then
		
		if not GameBaseLogic.checkSkillCD(skill_type) then
			return false
		end

		if mAimGhost then
			if skill_type == GameConst.SKILL_TYPE_LeiDianShu or skill_type == GameConst.SKILL_TYPE_BingPaoXiao or skill_type==GameConst.SKILL_TYPE_LingHunHuoFu
					 or skill_type == GameConst.SKILL_TYPE_LiuXingHuoYu or skill_type == GameConst.SKILL_TYPE_ShiDuShu then
				if pixes_main then
					-- 位置重合，走一步
					if checkSkilCastOnwerPos(mAimGhost) or not checkSkillCastDistance(skill_type, mAimGhost) then
						if not GameCharacter._moveToUseMagic then
							-- pixes_main:autoMoveOneStep(pixes_main:findAttackPosition(_aimGhostID,1))
							GameCharacter._moveToUseMagic = skill_type
							GameCharacter._moveAndUseMagic = true
							if pixes_main and pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE then
								mainrole_action_start(2,pixes_main)
							end
						end
						return
					-- elseif not checkSkillCastDistance(skill_type, mAimGhost) then
					-- 	print("checkSkillCastDistance2",skill_type)
					-- 	-- if not GameCharacter._moveToUseMagic and (not GameBaseLogic.isTouchingRocker()) then
					-- 	if not GameCharacter._moveToUseMagic then
					-- 		-- pixes_main:autoMoveOneStep(pixes_main:findAttackPosition(_aimGhostID,1))
					-- 		GameCharacter._moveToUseMagic = skill_type
					-- 		GameCharacter._moveAndUseMagic = true
					-- 	end
					-- 	return
					end
				end
			end

			--有目标的情况
			local dir = GameCharacter.mDir
			if skill_type ~= GameConst.SKILL_TYPE_YeManChongZhuang then
				dir = GameBaseLogic.getLogicDirection(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(mAimGhost.mX,mAimGhost.mY))
				if dir ~= GameCharacter.mDir then
					--修正服务器方向
					GameSocket:Turn(dir)
				end
			end
			if isToneUpSkill(skill_type) then
				if mAimGhost.mType == GameConst.GHOST_PLAYER or mAimGhost.mType == GameConst.GHOST_THIS or mAimGhost.mType == GameConst.GHOST_SLAVE then
					--辅助类技能针对玩家目标施放
					GameSocket:UseSkill(skill_type,mAimGhost.mX,mAimGhost.mY,mAimGhost.mID)
				else
					--目标为怪物则辅助技能针对空地施放
					GameSocket:UseSkill(skill_type,mAimGhost.mX,mAimGhost.mY,0)
				end
			elseif isNoTargetSkill(skill_type) then
				GameSocket:UseSkill(skill_type,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
			else
				-- 伤害类技能不能对自己放
				-- print("-------------------", mAimGhost.mType, mAimGhost.mID, GameCharacter.mID, mAimGhost.mType == GameConst.GHOST_THIS);
				if not (mAimGhost.mType == GameConst.GHOST_THIS) then
					--针对群体,雷电术自动转冰咆哮
					if not noAutoChange then

					--法师
						if skill_type == GameConst.SKILL_TYPE_LeiDianShu and #NetCC:getGhostsAroundPos(mAimGhost.mX,mAimGhost.mY,GameConst.GHOST_MONSTER) > 1 
							and GameSocket.m_netSkill[GameConst.SKILL_TYPE_BingPaoXiao] and GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_BingPaoXiao) then
							skill_type = GameConst.SKILL_TYPE_BingPaoXiao
						end

						if skill_type == GameConst.SKILL_TYPE_LeiDianShu and #NetCC:getGhostsAroundPos(GameCharacter.mX,GameCharacter.mY,GameConst.GHOST_MONSTER) > 1
							and GameSocket.m_netSkill[GameConst.SKILL_TYPE_DiYuLeiGuang] and GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_DiYuLeiGuang) 
							and getDistanceSQ(mAimGhost) <= 2 then
							skill_type = GameConst.SKILL_TYPE_DiYuLeiGuang
						end

						--道士
						if skill_type == GameConst.SKILL_TYPE_LingHunHuoFu then
							local mAimGhostID = mAimGhost:NetAttr(GameConst.net_id)
							if not checkShiDuShu(mAimGhostID) then -- 没有中毒自动施毒术
								if GameSocket.m_netSkill[GameConst.SKILL_TYPE_ShiDuShu] and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ShiDuShu) and GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ShiDuShu) then
									skill_type = GameConst.SKILL_TYPE_ShiDuShu
									if checkSkilCastOnwerPos(mAimGhost) or not checkSkillCastDistance(skill_type, mAimGhost) then
										if not GameCharacter._moveToUseMagic then
											-- pixes_main:autoMoveOneStep(pixes_main:findAttackPosition(_aimGhostID,1))
											GameCharacter._moveToUseMagic = skill_type
											GameCharacter._moveAndUseMagic = true
											if pixes_main and pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE then
												mainrole_action_start(2,pixes_main)
											end
										end
										return
									end
								end
							end
						end
					end		
					
					GameSocket:UseSkill(skill_type,mAimGhost.mX,mAimGhost.mY,mAimGhost.mID)
				else
					GameSocket:alertLocalMsg("不能以自己为目标","alert")
					return
				end
			end
		else
			--无目标
			if skill_type == GameConst.SKILL_TYPE_LeiDianShu or skill_type == GameConst.SKILL_TYPE_BingPaoXiao or skill_type==GameConst.SKILL_TYPE_LingHunHuoFu
			or skill_type == GameConst.SKILL_TYPE_HuoLongQiYan or skill_type == GameConst.SKILL_TYPE_LiuXingHuoYu or skill_type == GameConst.SKILL_TYPE_ShiDuShu then -- or skill_type == GameConst.SKILL_TYPE_HuoQiang 
				-- local dx,dy = GameBaseLogic.getDirectionPoint(GameCharacter.mDir,5,GameCharacter.mX,GameCharacter.mY)
				-- local mNearby = NetCC:getNearestGhost(GameConst.GHOST_MONSTER,true)
				-- if mNearby and G_AutoLock > 0 then
				-- 	mAimGhost=mNearby
				-- 	--优先寻找附近的怪物施放
				-- 	dx = mNearby:NetAttr(GameConst.net_x)
				-- 	dy = mNearby:NetAttr(GameConst.net_y)

				-- 	CCGhostManager:selectSomeOne(mNearby:NetAttr(GameConst.net_id))

				-- 	GameSocket:UseSkill(skill_type,dx,dy,mNearby:NetAttr(GameConst.net_id))
				-- elseif G_AutoLock > 0 and GameSocket.mAttackMode ~= 101 then
				-- 	--随机找一个人打
				-- 	local player_id = GameCharacter.getNearGhostSort()
				-- 	if player_id then
				-- 		local mNearPlayer = NetCC:getGhostByID(player_id)
				-- 		if mNearPlayer then
				-- 			dx = mNearPlayer:NetAttr(GameConst.net_x)
				-- 			dy = mNearPlayer:NetAttr(GameConst.net_y)
				-- 			CCGhostManager:selectSomeOne(mNearPlayer:NetAttr(GameConst.net_id))
				-- 			GameSocket:UseSkill(skill_type,dx,dy,mNearPlayer:NetAttr(GameConst.net_id))
				-- 		end
				-- 	else
				-- 		--毫无目标,依然施放在前方5格位置
				-- 		GameSocket:UseSkill(skill_type,dx,dy,0)
				-- 	end
				-- else
				-- 	--默认施放在前方5格位置
				-- 	GameSocket:UseSkill(skill_type,dx,dy,0)
				-- end
				return false
			else
				--默认在自己身上
				GameSocket:UseSkill(skill_type,GameCharacter.mX,GameCharacter.mY,0)
			end
		end

		if skill_type == GameConst.SKILL_TYPE_LeiDianShu or skill_type == GameConst.SKILL_TYPE_LingHunHuoFu
		or skill_type == GameConst.SKILL_TYPE_BingPaoXiao or skill_type == GameConst.SKILL_TYPE_ShiDuShu then
		-- or skill_type == GameConst.SKILL_TYPE_YeManChongZhuang
			if mAimGhost and not GameCharacter._aiKeepAttack then
				-- GameCharacter._aiKeepAttack = true
				GameCharacter._readyKeepAttack = true
				-- GameCharacter._aiKeepSkill = skill_type
				-- GameCharacter._autoFightTime = GameBaseLogic.getTime()
				if pixes_main then
					pixes_main:clearAutoMove()
				end
			end
			--点击技能后持续攻击
		end
		-- GameCharacter._readyUseSkill = false
		return true
	else
		--开关技能或普通攻击
		-- if GameBaseLogic.getTime() - GameSocket.mCastSkillTime < 720 and skill_type ~= GameConst.SKILL_TYPE_LieHuoJianFa
		-- and skill_type ~= GameConst.SKILL_TYPE_PoTianZhan and skill_type ~= GameConst.SKILL_TYPE_ZhuRiJianFa then
		-- 	--非预存技能且间隔过短
		-- 	return false
		-- end
		if skill_type == GameConst.SKILL_TYPE_YiBanGongJi then
			-- 普通攻击最小间隔720毫秒
			if not GameBaseLogic.checkSkillCD(skill_type) then
				return false
			end
		end
		--随机找个人打
		if not mAimGhost and G_AutoLock > 0 then
			-- local mNearby = NetCC:getNearestGhost(GameConst.GHOST_MONSTER,true)
			-- if mNearby then
			-- 	CCGhostManager:selectSomeOne(mNearby:NetAttr(GameConst.net_id))
			-- 	_aimGhostID = mNearby:NetAttr(GameConst.net_id)
			-- 	mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
			-- elseif GameSocket.mAttackMode ~= 101 then
			-- 	local player_id = GameCharacter.getNearGhostSort()
			-- 	if player_id then
			-- 		local mNearPlayer = NetCC:getGhostByID(player_id)
			-- 		if mNearPlayer then
			-- 			CCGhostManager:selectSomeOne(mNearPlayer:NetAttr(GameConst.net_id))
			-- 			_aimGhostID = player_id
			-- 			mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
			-- 		end
			-- 	end
			-- end
		end
		if isFlagSkill then
			--开关技能
			GameSocket:UseSkill(skill_type,GameCharacter.mX,GameCharacter.mY,0)
		elseif mAimGhost and pixes_main then
			local selfpos = (pixes_main:NetAttr(GameConst.net_x)==mAimGhost.mX and pixes_main:NetAttr(GameConst.net_y)==mAimGhost.mY)
			if selfpos then
				local aghosts = NetCC:getGhostsAroundPos(GameCharacter.mX,GameCharacter.mY,GameConst.GHOST_MONSTER,true)
				local aghost = nil
				if aghosts and #aghosts>1 then
					for i=1,#aghosts do
						aghost = NetCC:getGhostByID(aghosts[i])
						if aghost then
							if aghost:NetAttr(GameConst.net_x)~=GameCharacter.mX or aghost:NetAttr(GameConst.net_y)~=GameCharacter.mY then
								_aimGhostID = aghosts[i]
								CCGhostManager:selectSomeOne(_aimGhostID)
								mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
								break
							end
						end
					end
				end
			end

			local dir = GameBaseLogic.getLogicDirection(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(mAimGhost.mX,mAimGhost.mY))
			-- if dir ~= GameCharacter.mDir then
			-- 	--修正服务器方向
			-- 	GameSocket:Turn(dir)
			-- end
			--有目标普通攻击
			-- local dis = math.floor(cc.pGetDistance(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(mAimGhost.mX,mAimGhost.mY)))
			local dis = cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(mAimGhost.mX,mAimGhost.mY))
			local space = 1
			if GameSocket.m_bCiShaOn and not GameSocket.m_bBanYueOn and GameSocket.m_netSkill[GameConst.SKILL_TYPE_CiShaJianShu] and not GameSocket.m_bLiehuoAction then
				space = 2
			end
			local cishapos = false
			if space==2 and GameCharacter.mX+m_tile_step[dir+1][1]*2==mAimGhost.mX and GameCharacter.mY+m_tile_step[dir+1][2]*2==mAimGhost.mY then
				cishapos = true
			end
			local attackpos = dis < 4
			if (cishapos and not selfpos) or (attackpos and not selfpos) then
				GameSocket:UseSkill(skill_type,mAimGhost.mX,mAimGhost.mY,mAimGhost.mID)
			else
				GameCharacter._moveToNearAttack = true
				pixes_main:clearAutoMove()

				if pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE then
					mainrole_action_start(2,pixes_main)
				end
			end
			-- if (not cishapos and not attackpos) or selfpos then then
			-- 	GameCharacter._moveToNearAttack = true
			-- 	pixes_main:clearAutoMove()

			-- 	if pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE then
			-- 		mainrole_action_start(2,pixes_main)
			-- 	end
			-- else
			-- 	GameSocket:UseSkill(skill_type,mAimGhost.mX,mAimGhost.mY,mAimGhost.mID)
			-- end
		else
			--无目标普通攻击
			-- GameSocket:UseSkill(skill_type,GameCharacter.mX+m_tile_step[GameCharacter.mDir+1][1],GameCharacter.mY+m_tile_step[GameCharacter.mDir+1][2],0)
			return false
		end
		if skill_type == GameConst.SKILL_TYPE_YiBanGongJi then
			if mAimGhost and not GameCharacter._aiKeepAttack then
				-- GameCharacter._aiKeepAttack = true
				GameCharacter._readyKeepAttack = true
				-- GameCharacter._aiKeepSkill = skill_type
				-- GameCharacter._autoFightTime = GameBaseLogic.getTime()
				if pixes_main then
					pixes_main:clearAutoMove()
				end
			end
			--点击技能后持续攻击
		end
		return true
	end
	return false
end

function GameCharacter.getAimGhost(ghostID)
	-- local mAimGhost = CCGhostManager:getPixesGhostByID(ghostID)
	local mAimGhost = NetCC:getGhostByID(ghostID)
	if mAimGhost then
		mAimGhost.mX = mAimGhost:NetAttr(GameConst.net_x)
		mAimGhost.mY = mAimGhost:NetAttr(GameConst.net_y)
		mAimGhost.mType = mAimGhost:NetAttr(GameConst.net_type)
		mAimGhost.mID = mAimGhost:NetAttr(GameConst.net_id)
		mAimGhost.mCollectTime = mAimGhost:NetAttr(GameConst.net_collecttime)
		mAimGhost.mHp = mAimGhost:NetAttr(GameConst.net_hp)
		return mAimGhost
	end
end

function GameCharacter.updateAttr()
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	GameCharacter._mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()
	if GameCharacter._mainAvatar then
		GameCharacter.mID = GameCharacter._mainAvatar:NetAttr(GameConst.net_id)
		GameCharacter.mX = GameCharacter._mainAvatar:NetAttr(GameConst.net_x)
		GameCharacter.mY = GameCharacter._mainAvatar:NetAttr(GameConst.net_y)
		GameCharacter.mDir = GameCharacter._mainAvatar:NetAttr(GameConst.net_dir)
		GameCharacter.mJob = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)

		return GameCharacter._mainAvatar
	end
end

function GameCharacter.startAutoFight(tag)
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	--print("///////////GameCharacter.startAutoFight//////////////", tag)

	-- if GameBaseLogic.checkMainTaskPaused() then return end -- 主线屏蔽挂机功能
	GameCharacter.stopAutoPick()
	GameCharacter.stopAutoFight()

	GameCharacter._mainAvatar:clearAutoMove()
	GameCharacter._autoMoving = false
	
	GameCharacter.updateAttr()
	GameCharacter._aiStartPos = cc.p(GameCharacter.mX,GameCharacter.mY)
	GameCharacter._autoFight = true
	GameCharacter._aiKeepAttack = true

	GameCharacter.doAutoFight()

	GUIMain.showAutoActionAnima(50005)
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_QUICKBUTTON_STATE ,state = "start", key = "fight"})
end

function GameCharacter.stopAutoFight()
	GameCharacter._autoFight = false
	GameCharacter._aiKeepAttack = false
	GameCharacter._readyKeepAttack = false
	GameCharacter._aiKeepSkill = nil
	GameCharacter._moveAndFinding = false
	GameCharacter._runToIndex = nil
	GameCharacter._findToGhostId = nil
	GameCharacter._moveToUseMagic = nil
	GameCharacter._moveAndUseMagic = nil

	GameCharacter._pickItemDelay = nil
	-- _aimGhostID = 0 -- 清除目标
	GUIMain.hideAutoActionAnima(50005)
	GameSocket:PushLuaTable("player.stopFightRand","")
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_QUICKBUTTON_STATE ,state = "stop", key = "fight"})
end

function GameCharacter.startAutoPick()
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	-- if GameBaseLogic.checkMainTaskPaused() then return end -- 主线屏蔽自动拾取功能
	GameCharacter.stopAutoFight()
	GameCharacter._autoPick = true
	GameCharacter.doAutoPick()
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_QUICKBUTTON_STATE , key = "pick"})
end

function GameCharacter.stopAutoPick()
	GameCharacter._autoPick = false
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_QUICKBUTTON_STATE , key = "pick"})
end

function GameCharacter.doNearAttack()
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	local mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
	if mAimGhost then
		GameCharacter.updateAttr()

		local dx = mAimGhost:NetAttr(GameConst.net_x)
		local dy = mAimGhost:NetAttr(GameConst.net_y)
		if mAimGhost.mType == GameConst.GHOST_MONSTER and mAimGhost.mCollectTime and mAimGhost.mCollectTime > 0 then
			if mAimGhost.mHp > 0 and not GameSocket.m_bCollecting then--进度条结束后m_bCollecting应该设为false
				GameSocket:StartCollect(mAimGhost.mID)
			end
		else
			-- if GameCharacter._mainAvatar:NetAttr(GameConst.net_job) == GameConst.JOB_ZS then
			-- 	if G_AutoBanyue==1 and GameSocket.m_netSkill[GameConst.SKILL_TYPE_BanYueWanDao] and (#NetCC:getGhostsAroundPos(GameCharacter.mX,GameCharacter.mY,GameConst.GHOST_MONSTER) > 1 or GameCharacter._lastUseSkill == GameConst.SKILL_TYPE_BanYueWanDao) and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_BanYueWanDao) then
			-- 		GameSocket:UseSkill(GameConst.SKILL_TYPE_BanYueWanDao,dx,dy,mAimGhost:NetAttr(GameConst.net_id))
			-- 	else
			-- 		GameSocket:UseSkill(GameConst.SKILL_TYPE_YiBanGongJi,dx,dy,mAimGhost:NetAttr(GameConst.net_id))
			-- 	end
			-- else
				GameSocket:UseSkill(GameConst.SKILL_TYPE_YiBanGongJi,dx,dy,mAimGhost:NetAttr(GameConst.net_id))
			-- end
		end
	end
end

function GameCharacter.update()
	
	local curTime = GameBaseLogic.getTime()

	if GameSocket.m_bCollecting then
		if curTime > GameSocket.m_collectTime then
			GameSocket.m_bCollecting = false
		end
	end

	if GameCharacter._mainAvatar and not GameCharacter._mainAvatar:NetAttr(GameConst.net_dead) then
		if curTime - GameCharacter._autoItemTime > 500 then
			GameCharacter._autoItemTime=curTime
			GameCharacter.autoUseItem()
		end

		if GameCharacter._mainAvatar:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE then
			if GameCharacter._waitSkill then
				GameSocket:UseSkill(GameCharacter._waitSkill.type,GameCharacter._waitSkill.px,GameCharacter._waitSkill.py, 0)
				GameCharacter._waitSkill = nil
			elseif GameCharacter.autoSkillCheckAndCast() then

			else
				GameCharacter.keepEasyAi()
			end

			if GameCharacter._autoFight then
				if GameBaseLogic.checkSkillCD(getAiSkill()) then
					GameCharacter.doAutoFight()
				end
			else
				if not GameCharacter._autoMoving and not GameCharacter._aiKeepAttack and not GameCharacter._readyKeepAttack then
					if GameCharacter._targetNPCName and GameCharacter._targetNPCName~="" then
						GameCharacter.MoveToContinueTask()
					end
				end
			end
		end

		GameCharacter._isDead = false
	else
		if not GameCharacter._isDead then 
			GameCharacter._isDead = true 
			GameCharacter.initVar(true)
			GameCharacter._mainAvatar = GameCharacter.updateAttr()
			GUIMain.hideUIPlayer() -- 死亡隐藏头像
		end
	end

	--更新镖车光圈位置
	if GameUtilSenior.isObjectExist(GameCharacter.mDartSprite) then
		if GameUtilSenior.isObjectExist(GameCharacter.mDartHalo) then
			local posX,posY = GameCharacter.mDartSprite:getPosition()
			GameCharacter.mDartHalo:setPosition(posX + TILE_WIDTH * 0.5, posY - TILE_HEIGHT * 0.5)
			if GameUtilSenior.isObjectExist(GameCharacter.mDartClothSprite) then
				GameCharacter.mDartHalo:setOpacity(GameCharacter.mDartClothSprite:getOpacity())
			end
		end
	else
		if GameUtilSenior.isObjectExist(GameCharacter.mDartHalo) then
			GameCharacter.mDartHalo:removeFromParent()
			GameCharacter.mDartHalo = nil
		end
	end

	if GameCharacter._pickItemDelay and curTime >= GameCharacter._pickItemDelay then
		GameCharacter.pickUpItemUnderFoot()
		GameCharacter._moveEndAutoPick=false
		GameCharacter._pickItemDelay = nil
		if GameCharacter._autoFight then
			GameCharacter.startAutoFight(6)
		end
	end
end

function GameCharacter.stopAutoDart()
	GameSocket:PushLuaTable("gui.PanelDart.handlePanelData",GameUtilSenior.encode({actionid = "reqStopAuto"}))
end

-- local hpDrag = {10173, 10006, 10005, 10004}
local hpDrug  = {
	20001006, 20001005, 20001004, 20001003, 20001002, 20001001 
}

local mpDrug  = {
	20001003, 20001002, 20001001
}


function GameCharacter.autoUseItem()
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	-- if GameCharacter._autoFight and G_SmartLowHP==1 then --优先回城
	-- print("GameCharacter.autoUseItem11111111", G_SmartLowHP, G_SmartEatHP, G_SmartEatMP)
	-- print("GameCharacter.autoUseItem22222222", G_SmartLowHPPercent, G_SmartEatHPPercent, G_SmartEatMPPercent, G_AutoPickEquipLevel)
	--特殊地图屏蔽吃药
	-- print("/////////////////autoUseItem/////////////////", GameSocket.mNetMap.mMapID)
	if GameSocket.mNetMap.mMapID == "diyi" then return end

	if G_SmartLowHP==1 then --优先回城，去除挂机限制
		local hpPercent = math.floor(GameCharacter._mainAvatar:NetAttr(GameConst.net_hp)/GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp)*100)
		if hpPercent <= tonumber(G_SmartLowHPPercent) then
			-- 低血量触发（回城石）
			-- print("___________",GameSocket:getServerParam(1002))
			-- if GameSocket:getServerParam(1002) > 0 then
				-- GameSocket:PushLuaTable("item.chuansong.luaitem","huicheng")
				local stoneId = GameSetting.getConf("SmartLowHPItem")
				if tonumber(stoneId) > 0 then
					local pos = GameSocket:getNetItemById(stoneId)
					if pos then
						GameSocket:BagUseItem(pos,stoneId,1)
					 -------------etClient:alertLocalMsg("血量低于"..G_SmartLowHPPercent.."%，自动回城。","bottom")
						GameCharacter.stopAutoFight()
					end
				end
			-- end
		end
	end

	if G_SmartEatHP==1 then -- 自动吃回血药
		local hpPercent = math.floor(GameCharacter._mainAvatar:NetAttr(GameConst.net_hp)/GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp)*100)
		if hpPercent <= tonumber(G_SmartEatHPPercent) then
			for i=1,#hpDrug do
				local pos = GameSocket:getItemPosByType(hpDrug[i])
				if pos >= 0 then
					GameSocket:BagUseItem(pos,hpDrug[i])
					return
				end
			end
		end
	end
	if G_SmartEatMP==1 then -- 自动吃回魔药
		local mpPercent = math.floor(GameCharacter._mainAvatar:NetAttr(GameConst.net_mp)/GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp)*100)
		if mpPercent <= tonumber(G_SmartEatMPPercent) then
			for i=1,#mpDrug do
				local pos = GameSocket:getItemPosByType(mpDrug[i])
				if pos >= 0 then
					GameSocket:BagUseItem(pos,mpDrug[i])
					return
				end
			end
		end
	end
end

--这个函数是我加的,之前是自动触发,现在改成随攻击触发
function GameCharacter.flagSkillCheckAndCast()
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	local pixes_main = GameCharacter.updateAttr()
	if pixes_main then
		if pixes_main:NetAttr(GameConst.net_job) == GameConst.JOB_ZS then
			-- print("GameCharacter.autoSkillCheckAndCast", GameSocket.mLiehuoAction, GameSocket.mLiehuoType)
			if not GameSocket.mLiehuoAction then
				--这一段是后加的
				local skillList = {GameConst.SKILL_TYPE_ZhuRiJianFa,
									GameConst.SKILL_TYPE_LieHuoJianFa,
									GameConst.SKILL_TYPE_JiuJieJianFa,
									GameConst.SKILL_TYPE_GuiYouZhan,
									GameConst.SKILL_TYPE_ShenXuanJianFa,
									GameConst.SKILL_TYPE_ZhanLongJianFa,
									GameConst.SKILL_TYPE_PoKongJianFa}
				local skillListTmp = {}
				for i=1,#skillList do
					if GameBaseLogic.getSkillUseState(skillList[i]) then
						skillListTmp[#skillListTmp+1]=skillList[i]
					end
				end
				if #skillListTmp>0 then
					local index = math.random(1,#skillListTmp)
					if GameBaseLogic.getSkillUseState(skillListTmp[index]) and GameSocket.m_netSkill[skillListTmp[index]] then
						if GameBaseLogic.checkMpEnough(skillListTmp[index]) and GameBaseLogic.checkSkillCD(skillListTmp[index]) then
							GameSocket:UseSkill(skillListTmp[index],GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
							return true
						end	
					end
				end
				--[[
				if GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ZhuRiJianFa) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_ZhuRiJianFa] then
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ZhuRiJianFa) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_ZhuRiJianFa) then
						GameSocket:UseSkill(GameConst.SKILL_TYPE_ZhuRiJianFa,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				elseif GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_LieHuoJianFa) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_LieHuoJianFa] then
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_LieHuoJianFa) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_LieHuoJianFa) then
						print("GameCharacter.autoSkillCheckAndCast", GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_LieHuoJianFa), GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_LieHuoJianFa))
						GameSocket:UseSkill(GameConst.SKILL_TYPE_LieHuoJianFa,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				elseif GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_JiuJieJianFa) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_JiuJieJianFa] then
					--print("GameCharacter.autoSkillCheckAndCast", GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_JiuJieJianFa), GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_JiuJieJianFa))
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_JiuJieJianFa) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_JiuJieJianFa) then
						--print("GameCharacter.autoSkillCheckAndCast", GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_JiuJieJianFa), GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_JiuJieJianFa))
						GameSocket:UseSkill(GameConst.SKILL_TYPE_JiuJieJianFa,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				elseif GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_GuiYouZhan) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_GuiYouZhan] then
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_GuiYouZhan) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_GuiYouZhan) then
						print("GameCharacter.autoSkillCheckAndCast", GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_GuiYouZhan), GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_GuiYouZhan))
						GameSocket:UseSkill(GameConst.SKILL_TYPE_GuiYouZhan,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				elseif GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ShenXuanJianFa) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_ShenXuanJianFa] then
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ShenXuanJianFa) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_ShenXuanJianFa) then
						print("GameCharacter.autoSkillCheckAndCast", GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ShenXuanJianFa), GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_ShenXuanJianFa))
						GameSocket:UseSkill(GameConst.SKILL_TYPE_ShenXuanJianFa,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				elseif GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ZhanLongJianFa) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_ZhanLongJianFa] then
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ZhanLongJianFa) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_ZhanLongJianFa) then
						print("GameCharacter.autoSkillCheckAndCast", GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ZhanLongJianFa), GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_ZhanLongJianFa))
						GameSocket:UseSkill(GameConst.SKILL_TYPE_ZhanLongJianFa,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				elseif GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_PoKongJianFa) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_PoKongJianFa] then
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_PoKongJianFa) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_PoKongJianFa) then
						print("GameCharacter.autoSkillCheckAndCast", GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_PoKongJianFa), GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_PoKongJianFa))
						GameSocket:UseSkill(GameConst.SKILL_TYPE_PoKongJianFa,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				end
				]]
			end
		elseif pixes_main:NetAttr(GameConst.net_job) == GameConst.JOB_FS then

		elseif pixes_main:NetAttr(GameConst.net_job) == GameConst.JOB_DS then
			
		end
	end
end

function GameCharacter.autoSkillCheckAndCast()
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	local pixes_main = GameCharacter.updateAttr()
	if pixes_main then
		-- 自动上魔法盾
		if GameSocket.m_netSkill[GameConst.SKILL_TYPE_MoFaDun] and pixes_main:NetAttr(GameConst.net_mount)<=0 then
			if G_AutoShield==1 and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_MoFaDun) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_MoFaDun) then
				if not checkMoFaDun(GameCharacter.mID) then
				-- if table.nums(status)<=0 or not status["dura"] or status["dura"]<=0 then
					-- print("autoSkillCheckAndCast mofadun")
					GameSocket:UseSkill(GameConst.SKILL_TYPE_MoFaDun,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
					return true
				end
			end
		end
		if pixes_main:NetAttr(GameConst.net_job) == GameConst.JOB_ZS then
			-- print("GameCharacter.autoSkillCheckAndCast", GameSocket.mLiehuoAction, GameSocket.mLiehuoType)
			--[[
			if not GameSocket.mLiehuoAction then
				if GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ZhuRiJianFa) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_ZhuRiJianFa] then
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ZhuRiJianFa) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_ZhuRiJianFa) then
						GameSocket:UseSkill(GameConst.SKILL_TYPE_ZhuRiJianFa,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				elseif GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_LieHuoJianFa) and GameSocket.m_netSkill[GameConst.SKILL_TYPE_LieHuoJianFa] then
					if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_LieHuoJianFa) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_LieHuoJianFa) then
						--print("GameCharacter.autoSkillCheckAndCast", GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_LieHuoJianFa), GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_LieHuoJianFa))
						GameSocket:UseSkill(GameConst.SKILL_TYPE_LieHuoJianFa,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				end
			end
			]]
		elseif pixes_main:NetAttr(GameConst.net_job) == GameConst.JOB_FS then
			
		elseif pixes_main:NetAttr(GameConst.net_job) == GameConst.JOB_DS then
			if GameSocket.mSlaveState==0 and GameSocket.m_netSkill[GameConst.SKILL_TYPE_ZhaoHuanShenShou] and GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_ZhaoHuanShenShou) then
				if GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_ZhaoHuanShenShou) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_ZhaoHuanShenShou) then
					GameSocket:UseSkill(GameConst.SKILL_TYPE_ZhaoHuanShenShou,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
					return true
				end
			end
			--自动圣甲术
			if GameSocket.m_netSkill[GameConst.SKILL_TYPE_YouLingDun] and pixes_main:NetAttr(GameConst.net_mount)<=0 then
				if GameBaseLogic.getSkillUseState(GameConst.SKILL_TYPE_YouLingDun) and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_YouLingDun) and GameBaseLogic.checkSkillCD(GameConst.SKILL_TYPE_YouLingDun) then
					if not checkShengJiaShu(GameCharacter.mID) then
						GameSocket:UseSkill(GameConst.SKILL_TYPE_YouLingDun,GameCharacter.mX,GameCharacter.mY,GameCharacter.mID)
						return true
					end
				end
			end
		end
	end
end

function GameCharacter.handleAttacked(attacker)
	--print("GameCharacter.handleAttacked(attacker)111",_aimGhostID);
	local aimGhost=GameCharacter.getAimGhost(_aimGhostID)
	local acker=NetCC:getGhostByID(attacker)
	if not aimGhost then
		--print("GameCharacter.handleAttacked(attacker)222");
		if acker and ((acker:NetAttr(GameConst.net_type)==GameConst.GHOST_MONSTER) or (acker:NetAttr(GameConst.net_type)==GameConst.GHOST_PLAYER)) then
			CCGhostManager:selectSomeOne(attacker)
		end
	elseif (acker:NetAttr(GameConst.net_type)==GameConst.GHOST_PLAYER) and (aimGhost:NetAttr(GameConst.net_type)==GameConst.GHOST_MONSTER) then
		--print("GameCharacter.handleAttacked(attacker)333");
		CCGhostManager:selectSomeOne(attacker)
	end
	--print("GameCharacter.handleAttacked(attacker)444");
	if GameCharacter._autoFight and G_AutoFightBack then
		local aimGhost=GameCharacter.getAimGhost(_aimGhostID)
		if aimGhost then
			if aimGhost:NetAttr(GameConst.net_type)==GameConst.GHOST_PLAYER and GameSocket.mAttackMode ~= 101 then
				GameCharacter.startCastSkill(getAiSkill())
			elseif aimGhost:NetAttr(GameConst.net_type)==GameConst.GHOST_MONSTER and not GameCharacter._moveEndAutoPick then--自动捡物品的时候不能被怪物打断
				GameCharacter.startCastSkill(getAiSkill())
			end
		end
	end
end

function GameCharacter.doAutoFight()
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	-- print("GameCharacter.doAutoFight11111111", GameCharacter._autoFight)
	if GameCharacter._autoFight and not GameCharacter._aiKeepAttack and not GameCharacter._readyKeepAttack then
		-- local mainAvatar = CCGhostManager:getMainAvatar()
		local pixes_main = GameCharacter.updateAttr()

		if not pixes_main or pixes_main:PAttr(GameConst.avatar_state) ~= GameConst.STATE_IDLE then
			return
		end

		--不会打断寻路
		-- print("GameCharacter.doAutoFight22222222", GameCharacter._autoMoving, GameCharacter._moveAndFinding)
		if not GameCharacter._autoMoving and not GameCharacter._moveAndFinding then
			local aimGhost = nil
			if _aimGhostID > 0 then aimGhost = GameCharacter.getAimGhost(_aimGhostID) end
			-- print("-------------------------doAutoFight")
			-- 自动挂机只打任务怪
			if aimGhost and not isTaskTargetMon(aimGhost) then aimGhost = nil end
			--print("-------------------------aimGhost",aimGhost)
			if not aimGhost or aimGhost:NetAttr(GameConst.net_type)~=GameConst.GHOST_MONSTER or aimGhost:NetAttr(GameConst.net_dead) or aimGhost:NetAttr(GameConst.net_hp) <= 0 then
				if GameCharacter.doAutoPick(true) then
					return
				end

				local mMonster = NetCC:getNearestGhost(GameConst.GHOST_MONSTER)
				local mMonster = getAutoFightMonster()
				--print("-------------------------getAutoFightMonster",mMonster:NetAttr(GameConst.net_name))
				if mMonster and not isTaskTargetMon(mMonster) then mMonster = nil end
				--print("-------------------------mMonster",mMonster)
				--只会找到活的怪物
				if mMonster then
					CCGhostManager:selectSomeOne(mMonster:NetAttr(GameConst.net_id))
					-- -- GameCharacter.doAutoFight()
					-- aimGhost = GameCharacter.getAimGhost(_aimGhostID) 
					-- if aimGhost then
					-- 	GameCharacter.startCastSkill(getAiSkill())
					-- end
				else
					--print("-------------------------mTaskTargetMon",mTaskTargetMon)
					--print(GameBaseLogic.wanderFight,GameSocket.mTaskTargetMon)
					if not GameBaseLogic.wanderFight and not GameSocket.mTaskTargetMon then
						--print("-------------------------mTaskTargetMon1",mTaskTargetMon)
						if pixes_main and pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE then
							print("-------------------------mTaskTargetMon3",mTaskTargetMon)
							mainrole_action_start(2,pixes_main)
						end
						GameCharacter._moveAndFinding=true
						if cc.pDistanceSQ(GameCharacter._aiStartPos,cc.p(GameCharacter.mX,GameCharacter.mY)) > 15*15 and GameCharacter._mainAvatar then --距离挂机起始点超过一定距离返回
							GameCharacter._mainAvatar:startAutoMoveToPos(GameCharacter._aiStartPos.x,GameCharacter._aiStartPos.y)
							GameCharacter._autoMoving = true
						end
					else
						--print("-------------------------mTaskTargetMon2",mTaskTargetMon)
						GameCharacter._moveAndFinding=true
						if pixes_main and pixes_main:PAttr(GameConst.avatar_state)==GameConst.STATE_IDLE then
							mainrole_action_start(2,pixes_main)
						end
					end
				end
			else
				-- 距离超过8*8,重新选择目标
				-- if cc.pDistanceSQ(cc.p(aimGhost:NetAttr(GameConst.net_x),aimGhost:NetAttr(GameConst.net_y)),cc.p(GameCharacter.mX,GameCharacter.mY)) > 8*8 then
				-- 	local mMonster = NetCC:getNearestGhost(GameConst.GHOST_MONSTER)
				-- 	if mMonster then
				-- 		CCGhostManager:selectSomeOne(mMonster:NetAttr(GameConst.net_id))
				-- 		GameCharacter.startCastSkill(getAiSkill())
				-- 	else
				-- 		print("monster error")
				-- 	end
				-- else
				if GameSocket.mCDWaitNextSKill and GameBaseLogic.checkSkillCD(GameSocket.mCDWaitNextSKill) then
					GameCharacter.startCastSkill(GameSocket.mCDWaitNextSKill)
					GameSocket.mCDWaitNextSKill = nil
					GameCharacter.stopAutoFight()
				else
					GameCharacter.startCastSkill(getAiSkill())
				end
				-- end
			end
		else
			if GameCharacter.waiteForRandom==false then
				GameCharacter.waiteForRandom = true
				GameSocket:PushLuaTable("player.autoFightRand","")
			end
		end
	end
end

--挂机时调用自动拾取时 autoFight为true， 仅自动拾取时 autoFight为nil
function GameCharacter.doAutoPick(autoFight)
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	print("------>GameCharacter.doAutoPick:")
	if GameCharacter._autoPick or autoFight then
		GameCharacter.updateAttr()
		if not GameBaseLogic.bagFullFlag then
			local items=NetCC:getNearGhost(GameConst.GHOST_ITEM)
			--这里写捡物品的优先逻辑
			if #items>0 then
				local _equip=nil
				local _item=nil
				local _equipdis = nil
				local _itemdis = nil

				local mainAvatarPos = cc.p(GameCharacter.mX, GameCharacter.mY)
				for _,v in ipairs(items) do
					local item=NetCC:getGhostByID(v)
					if item then
						-- print("check item picked", v, item:NetAttr(GameConst.net_state), item:NetAttr(GameConst.net_id), tostring(item))
						local itemPosition = cc.p(item:NetAttr(GameConst.net_x), item:NetAttr(GameConst.net_y))
						-- if item:NetAttr(GameConst.net_state) ~= true and (itemPosition.x ~= GameCharacter.mX or itemPosition.y ~= GameCharacter.mY) then
						if item:NetAttr(GameConst.net_state) ~= true then
							local owner = item:NetAttr(GameConst.net_item_owner)
							local ittype = item:NetAttr(GameConst.net_itemtype)
							if type(owner) == "number" and (owner <=0 or owner == GameCharacter.mID) then
								if GameBaseLogic.getPickState(ittype) then
									local tempdis = cc.pGetLength(cc.p((mainAvatarPos.x - itemPosition.x) * 48, (mainAvatarPos.y - itemPosition.y) * 32))
									if GameBaseLogic.IsEquipment(ittype) then
										if not _equipdis or (_equipdis > tempdis) then
											_equipdis = tempdis
											_equip=item
										end
									else
										if not _itemdis or (_itemdis > tempdis) then
											_itemdis = tempdis
											_item=item
										end
									end
								end
							end
						end
					end
				end

				local target=_item
				if _equip then target=_equip end
				if target then
					if GameCharacter._mainAvatar then
						GameCharacter._moveEndAutoPick=true
						GameCharacter._autoMoving = true
						GameCharacter._mainAvatar:startAutoMoveToPos(target:NetAttr(GameConst.net_x),target:NetAttr(GameConst.net_y))
						CCGhostManager:selectSomeOne(target:NetAttr(GameConst.net_id))--自动捡物品则选中
						return true
					end
				end
			end
		end
	end
end

--打了一次怪物之后一直打
function GameCharacter.keepEasyAi()
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	if GameCharacter._aiKeepAttack or GameCharacter._readyKeepAttack then
		local mCurGhost = GameCharacter.getAimGhost(_aimGhostID)
		if not mCurGhost or mCurGhost:NetAttr(GameConst.net_dead) then
			GameCharacter._aiKeepAttack = false
			GameCharacter._readyKeepAttack = false
		else
			if GameCharacter._aiKeepAttack then
				local skill_type=getEasyAiSkill(mCurGhost)
				if GameBaseLogic.checkSkillCD(skill_type) then
					GameCharacter.startCastSkill(skill_type)
					return 1
				end
			end
		end
	end
end

function GameCharacter.startAutoMoveToMap(mapname,tx,ty,flag)
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	if GameSocket.mJinGuFlag then
		return
	end	
	if GameSocket.mNetBuff[GameCharacter.mID] then
		if GameSocket.mNetBuff[GameCharacter.mID][20] then
			return
		end
	end


	-- local MainAvatar = CCGhostManager:getMainAvatar()
	-- print("GameCharacter.startAutoMoveToMap",mapname,tx,ty,flag)
	GameCharacter._mainAvatar = GameCharacter.updateAttr()

	if not GameCharacter._mainAvatar then return end

	GameCharacter._mainAvatar:clearAutoMove()
	GameCharacter.stopAutoFight()
	GameSocket.mTargetMap = mapname
	-- print("1111111111111111", GameSocket.mNetMap.mMapID, mapname, GameSocket.mNetMap.mMapID == mapname)
	if GameSocket.mNetMap.mMapID == mapname then
		GameCharacter._mainAvatar:startAutoMoveToPos(tx,ty,flag)
	else
		GameSocket.mTargetMapX = tx
		GameSocket.mTargetMapY = ty
		if GameCharacter.searchCrossMapPath() then
			GameSocket.mCrossAutoMove = true
			local mapConn = GameSocket.mMapConn[GameSocket.mCrossMapPath[#GameSocket.mCrossMapPath]]
			if mapConn then
				GameCharacter._mainAvatar:startAutoMoveToPos(mapConn.mFromX,mapConn.mFromY)
				-- self.mMoveToCross=true
				table.remove(GameSocket.mCrossMapPath)
			end
		else
			-- --在未知暗殿自动回城
			-- if table.indexof({"v200","v401","v402"}, GameSocket.mNetMap.mMapID) or (type(GameSocket.mNetMap.mName) == "string" and string.find(GameSocket.mNetMap.mName,"未知暗殿")) then
			-- 	--如果目标是暗殿使者这不回城
			-- 	local pTask = GameSocket.mTasks[1000]
			-- 	if pTask and pTask.mInfo and type(pTask.mInfo.task_target) == "string" then
			-- 		-- print("-------------",pTask.mInfo.task_target)
			-- 		if string.find(pTask.mInfo.task_target,"暗殿使者")  then
			-- 			GameCharacter.startAutoFight()
			-- 			return
			-- 		end
			-- 	end
			-- 	GameSocket:PushLuaTable("item.chuansong.luaitem","andian")
			-- end
		end
	end
end

function GameCharacter.searchCrossMapPath()
	-- print("GameCharacter.searchCrossMapPath", GameUtilSenior.encode(GameSocket.mMiniMapConn))
	while #GameSocket.mCrossMapPath > 0 do
		table.remove(GameSocket.mCrossMapPath)
	end
	local q ={}
	local closeList = {}
	local visitSet = {}
	local curNode = {name="",parent=-1}
	curNode.name = GameSocket.mNetMap.mMapID  --当前所在地图的mapid
	curNode.parent = -1
	table.insert(q,curNode)
	while #q > 0 do
		curNode = q[#q]
		table.remove(q)
		table.insert(closeList,curNode)
		if curNode.name == GameSocket.mTargetMap then
			while curNode.parent ~= -1 do
				table.insert(GameSocket.mCrossMapPath,curNode.name)
				curNode = closeList[curNode.parent]
			end
			return true
		end
		local p = #closeList
		local node = GameSocket.mMiniMapConn[curNode.name]
		local size = 0
		if node then
			size = #node
		end
		for i=1,size do
			if visitSet[node[i]] == nil then --已经遍历过的传送地图就不要再加进来了， 每个传送点都会对应传送到的地图名字
				visitSet[node[i]] = node[i]
				local cur={name="",parent=-1}
				cur.name = node[i]
				cur.parent = p
				table.insert(q,cur)
			end
		end
	end
	return false
end

function GameCharacter.checkAutoMove()
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	if GameSocket.mCrossAutoMove then
		if GameSocket.mTargetMap ~= GameSocket.mNetMap.mMapID then
			if #GameSocket.mCrossMapPath > 0 then
				local mapConn = GameSocket.mMapConn[GameSocket.mCrossMapPath[#GameSocket.mCrossMapPath]]
				if mapConn then
					GameCharacter._mainAvatar:startAutoMoveToPos(mapConn.mFromX,mapConn.mFromY)
				end
				-- self.mMoveToCross=true
				table.remove(GameSocket.mCrossMapPath)
			else
				----print("The cross path list is already empty!")
				GameSocket.mCrossAutoMove = false
			end
		else
			GameSocket.mCrossAutoMove = false
			GameCharacter._mainAvatar:startAutoMoveToPos(GameSocket.mTargetMapX,GameSocket.mTargetMapY,2)
		end
	end
end

function auto_move_start(targetX,targetY,flag)

	--print("startAutoMoveToMap")
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	if GameSocket.mJinGuFlag then
		return
	end
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	-- if cc.pDistanceSQ(cc.p(targetX, targetY), cc.p(MainAvatar:PAttr(GameConst.AVATAR_X), MainAvatar:PAttr(GameConst.AVATAR_Y))) >= 30*30 then--超过一定距离才显示骑马
		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING , btn = "main_mount" , visible = true})
	-- end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_AUTOMOVE_START,"auto_move_start")


function GameCharacter.MoveToContinueTask()
	-- 借用此处设个变量
	GameCharacter._readyKeepAttack = false

	if GameCharacter._mainAvatar then
		GameCharacter._mainAvatar:clearAutoMove()
	end

	if GameCharacter._targetNPCName=="autofightstart" then
		GameCharacter._targetNPCName = ""
		GameCharacter.startAutoFight(1)
	elseif GameCharacter._targetNPCName~="" then
		local pGhost=NetCC:findGhostByName(GameCharacter._targetNPCName)
		if pGhost then
			if pGhost:NetAttr(GameConst.net_type)==GameConst.GHOST_NPC then
				local netId = pGhost:NetAttr(GameConst.net_id)
				if netId then
					GameCharacter.updateAttr()
					if cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(pGhost:NetAttr(GameConst.net_x),pGhost:NetAttr(GameConst.net_y))) <= 8 then
						GameSocket:NpcTalk(netId,"100")
						GameCharacter._targetNPCName = ""
					end
				end
			elseif pGhost:NetAttr(GameConst.net_type)==GameConst.GHOST_MONSTER then
				GameCharacter._targetNPCName = ""
				GameCharacter.startAutoFight(2)
			end
		end
	end
end

function auto_move_end(targetX,targetY,flag)
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	if GameSocket.mJinGuFlag then
		return
	end
	print("auto_move_end", GameCharacter._pickItemDelay)

	

	GameCharacter._autoMoving = false
	if GameCharacter._pickItemDelay then return end
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	-- if MainAvatar then
		GameCharacter._mainAvatar:clearAutoMove()
	-- end
	-- print(targetX,targetY)
	local result = NetCC:getGhostAtPos(targetX, targetY, GameConst.GHOST_NPC)
	if result and result[1] then
		local targetGhost = CCGhostManager:getPixesAvatarByID(result[1])
		if targetGhost then
			local npcGhost = CCGhostManager:getPixesAvatarByID(result[1])
			if npcGhost and npcGhost:NetAttr(GameConst.net_type) == GameConst.GHOST_NPC then
				-- print("GameSocket:NpcTalk11")
				GameSocket:NpcTalk(result[1],"100")
			end
		end
	end

	GameCharacter.MoveToContinueTask()

	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING , btn = "main_mount" , visible = false})
	-----------------寻路终止自动显示挂机-------- ---------
	-- if (#(NetCC:getNearGhost(GameConst.GHOST_MONSTER)) > 0 or #(NetCC:getNearGhost(GameConst.GHOST_ITEM)) > 0) then
	-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING , btn = "main_auto" , visible = true})
	-- end

	-----------------寻路终止自动捡物品-----------------
	if GameCharacter._moveEndAutoPick then
		if not GameCharacter._pickItemDelay and checkStandOnItem() then
			GameCharacter._pickItemDelay = GameBaseLogic.getTime() + 400
		end
		-- GameCharacter.pickUpItemUnderFoot()
		-- GameCharacter._moveEndAutoPick=false
	end

	if not GameCharacter._pickItemDelay then

		if GameCharacter._autoFight then
			GameCharacter.doAutoFight()
		end
		if GameCharacter._autoPick then
			GameCharacter.doAutoPick()
		end
	end

	GUIMain.hideAutoActionAnima(50004)

	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_MOVE_END})
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_FLY})
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_AUTOMOVE_END,"auto_move_end")

local function findNearestItemMonster(PixesMainAvatar)
	if PixesMainAvatar then
		local mItem
		local tempItem = NetCC:getNearestItem(0)
		if tempItem and tempItem:NetAttr(GameConst.net_state) ~= true and 
			(tempItem:NetAttr(GameConst.net_x)~=PixesMainAvatar:NetAttr(GameConst.net_x) or 
			tempItem:NetAttr(GameConst.net_y)~=PixesMainAvatar:NetAttr(GameConst.net_y)) then
			mItem = tempItem
			local owner = mItem:NetAttr(GameConst.net_item_owner) or 0
			local ittype = mItem:NetAttr(GameConst.net_itemtype) or 0
			if owner >0 and owner ~= GameCharacter.mID then
				mItem=nil
			end
			if not GameBaseLogic.getPickState(ittype) then
				mItem=nil
			end
		end
		local mMonster = NetCC:getNearestGhost(GameConst.GHOST_MONSTER)
		if mMonster and not isTaskTargetMon(mMonster) then mMonster = nil end
		if GameSocket:isBagFull() then mItem = nil end
		return mItem,mMonster
	end
end

function mainrole_action_start(index,PixesMainAvatar)
	if GameSocket.mMabiFlag or GameSocket.mBingdongFlag then
		return
	end
	if GameSocket.mJinGuFlag then
		return
	end
	if PixesMainAvatar then
		if index == 1 then
			if GameCharacter._moveToUseMagic and not GameCharacter._moveAndUseMagic then
				GameCharacter.startCastSkill(GameCharacter._moveToUseMagic, true)
				GameCharacter._moveToUseMagic = nil
				-- GameCharacter._aiKeepAttack = true
			elseif GameCharacter._readyKeepAttack then
				-- GameCharacter._aiKeepAttack = true
				GameCharacter._readyKeepAttack = false
			elseif GameCharacter._waitSkill then
				GameSocket:UseSkill(GameCharacter._waitSkill.type,GameCharacter._waitSkill.px,GameCharacter._waitSkill.py, 0)
				GameCharacter._waitSkill = nil
				return 1 -- 返回1,action被lua劫持, 不执行c++
			-- elseif GameCharacter.autoSkillCheckAndCast() then
			-- 	return 1
			end
			if not GameCharacter._moveToNearAttack and not GameCharacter._moveAndUseMagic then
				return GameCharacter.keepEasyAi()
			end
		elseif index == 2 then
			if GameCharacter._moveAndUseMagic then
				local  mAimGhost = nil
				if _aimGhostID > 0 then
					mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
				end
				if mAimGhost and mAimGhost:NetAttr(GameConst.net_type) ~= GameConst.GHOST_NPC then
					if mAimGhost and not mAimGhost:NetAttr(GameConst.net_dead) then
						GameCharacter.updateAttr()
						if GameCharacter._moveToUseMagic and (checkSkilCastOnwerPos(mAimGhost) or not checkSkillCastDistance(GameCharacter._moveToUseMagic, mAimGhost)) then
							PixesMainAvatar:autoMoveOneStep(PixesMainAvatar:findAttackPosition(_aimGhostID,1))
						else
							if GameCharacter._moveToUseMagic then
								local _moveToUseMagic = GameCharacter._moveToUseMagic
								GameCharacter._moveToUseMagic = nil
								GameCharacter.startCastSkill(_moveToUseMagic, true)
								GameCharacter._moveToUseMagic = nil
								-- GameCharacter._aiKeepAttack = true
								GameCharacter._moveAndUseMagic = false
							end
						end
						return 1
					end
				end
				GameCharacter._moveAndUseMagic = false
			elseif GameCharacter._moveToNearAttack then
				local  mAimGhost = nil
				if _aimGhostID > 0 then
					mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
				end
				if mAimGhost and mAimGhost:NetAttr(GameConst.net_type) ~= GameConst.GHOST_NPC then
					if mAimGhost and not mAimGhost:NetAttr(GameConst.net_dead) then
						if not PixesMainAvatar:autoMoveOneStep(PixesMainAvatar:findAttackPosition(_aimGhostID)) then
							GameCharacter.doNearAttack()
							--寻找到刺杀位之后砍一次就停止，等待手动操作
							GameCharacter._moveToNearAttack=false
							-- GameCharacter._aiKeepAttack = true
						end
						return 1
					else
						GameCharacter._moveToNearAttack=false
					end
				end
			-- end
			elseif GameCharacter._runToIndex and GameCharacter._mapMonGen[GameCharacter._runToIndex] then
				local tmon = GameCharacter._mapMonGen[GameCharacter._runToIndex]
				local mItem,mMonster = findNearestItemMonster(PixesMainAvatar)
				if mItem or mMonster then
					GameCharacter._moveAndFinding=false
					GameCharacter._runToIndex = nil
					GameCharacter.startAutoFight(3)

				elseif cc.pDistanceSQ(cc.p(PixesMainAvatar:NetAttr(GameConst.net_x),PixesMainAvatar:NetAttr(GameConst.net_y)),cc.p(tmon.x,tmon.y))
					< 3*3 then
					if not GameCharacter._mapMonGen[GameCharacter._runToIndex].visit then
						GameCharacter._mapMonGen[GameCharacter._runToIndex].visit = 0
					end
					GameCharacter._mapMonGen[GameCharacter._runToIndex].visit = GameCharacter._mapMonGen[GameCharacter._runToIndex].visit + 1
					GameCharacter._runToIndex = nil
				end
			elseif GameCharacter._findToGhostId and GameCharacter._mapGhostList[GameCharacter._findToGhostId] then
				local tmon = GameCharacter._mapGhostList[GameCharacter._findToGhostId]
				local mItem,mMonster = findNearestItemMonster(PixesMainAvatar)
				if mItem or mMonster then
					GameCharacter._moveAndFinding=false
					GameCharacter._findToGhostId = nil
					GameCharacter.startAutoFight(4)

				elseif cc.pDistanceSQ(cc.p(PixesMainAvatar:NetAttr(GameConst.net_x),PixesMainAvatar:NetAttr(GameConst.net_y)),cc.p(tmon.x,tmon.y))
					< 5*5 then
					-- print("near monster ",GameCharacter._findToGhostId)
					GameCharacter._mapGhostList[GameCharacter._findToGhostId] = nil
					GameCharacter._findToGhostId = nil
				end
			elseif GameCharacter._moveAndFinding then
				local mItem,mMonster = findNearestItemMonster(PixesMainAvatar)
				if not mItem and not mMonster then
					--print("===========1")
					-- GameCharacter._findingDir=GameCharacter.mDir
					-- GameCharacter.randMove()
					GameCharacter._runToIndex = GameCharacter.RunToMapMonster()
					if GameCharacter._runToIndex and GameCharacter._mapMonGen[GameCharacter._runToIndex] then
						--print("===========2")
						local tmon = GameCharacter._mapMonGen[GameCharacter._runToIndex]
						GameCharacter._mainAvatar:startAutoMoveToPos(tmon.x,tmon.y)
						if GameBaseLogic.isAutoMove then
							return 1
						end
					elseif GameCharacter.RunToFindMonster() then
						--print("===========3")
						local tmon = GameCharacter._mapGhostList[GameCharacter._findToGhostId]
						GameCharacter._mainAvatar:startAutoMoveToPos(tmon.x,tmon.y)
						return 1
					else
						--print("===========4",GameSocket.mMapGhostReq,GameBaseLogic.wanderFight)
						if not GameSocket.mMapGhostReq and GameBaseLogic.wanderFight then
							--print("=======##########====reqFindMapGhost======###########===",table.concat(GameSocket.mNetMap))
							GameSocket:reqFindMapGhost(GameSocket.mNetMap.mMapID,10)
						elseif GameSocket.mMapGhostRes then
							--print("===========5")
							GameCharacter._moveAndFinding=false
						end
					end
				else
					--print("===========5")
					GameCharacter._moveAndFinding=false
					-- GameCharacter.doAutoFight()
					-- GameCharacter.doAutoPick()
				end
			-- else
				-- GameCharacter.doAutoFight()
			end
		end
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAINROLE_ACTIONSTART,"mainrole_action_start")

local function easyCompDistance(pos,pos1,pos2)
	return (math.abs(pos1.x-pos.x)+math.abs(pos1.y-pos.y))<(math.abs(pos2.x-pos.x)+math.abs(pos2.y-pos.y))
end

function GameCharacter.RunToFindMonster()
	local pixes_main = GameCharacter.updateAttr()
	local mpos = {x=GameCharacter.mX,y=GameCharacter.mY}
	local ret = nil
	GameCharacter._findToGhostId = nil

	for k,v in pairs(GameCharacter._mapGhostList) do
		if mpos.x~=v.x or mpos.y~=v.y then
			if not ret then
				ret = v
			end
			if easyCompDistance(mpos,v,ret) then
				ret = v
			end
		end
	end

	if ret then
		GameCharacter._findToGhostId = ret.id
		-- print("=======##########====GameCharacter._findToGhostId======",GameCharacter._findToGhostId)
		return ret.id
	end
end

function GameCharacter.RunToMapMonster()
	if not GameCharacter._mapMonGen or GameCharacter._curMap ~= GameSocket.mNetMap.mMapID then
		if GameSocket.mMapMonGen and #GameSocket.mMapMonGen>0  and GameSocket.mMapMonGenId == GameSocket.mNetMap.mMapID then
			GameCharacter._mapMonGen = clone(GameSocket.mMapMonGen)
			GameCharacter._curMap = GameSocket.mNetMap.mMapID
		else
			GameCharacter._mapMonGen = {}
			GameCharacter._curMap = ""
		end
	end
	if #GameCharacter._mapMonGen>0 then
		local pixes_main = GameCharacter.updateAttr()
		local mpos = {x=GameCharacter.mX,y=GameCharacter.mY}
		local idx,ret
		local size = #GameCharacter._mapMonGen
		for i=1,size do
			if GameSocket.mTaskTargetMon then
				if GameCharacter._mapMonGen[i].name == GameSocket.mTaskTargetMon then
					ret = GameCharacter._mapMonGen[i]
					idx = i
					break
				end
			else
				if not GameCharacter._mapMonGen[i].visit then
					GameCharacter._mapMonGen[i].visit = 0
				end
				if mpos.x~=GameCharacter._mapMonGen[i].x or mpos.y~=GameCharacter._mapMonGen[i].y then
					if not ret then
						ret = GameCharacter._mapMonGen[i]
						idx = i
					end
					if GameCharacter._mapMonGen[i].visit < ret.visit then
						ret = GameCharacter._mapMonGen[i]
						idx = i
					elseif GameCharacter._mapMonGen[i].visit == ret.visit and easyCompDistance(mpos,GameCharacter._mapMonGen[i],ret) then
						ret = GameCharacter._mapMonGen[i]
						idx = i
					end
					-- print(ret)
				end
			end
		end
		if ret then
			-- print("===========GameCharacter.RunToMapMonster============",idx)
			return idx
		end
	end
end

function GameCharacter.randMove()
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	-- if MainAvatar then
		if GameCharacter._mainAvatar:actionWalk(GameCharacter._findingDir) >0 then
			return
		else
			local dirb=(GameCharacter._findingDir+4)%8
			local dir2=GameCharacter._findingDir
			local dirs={0,1,2,3,4,5,6,7}
			table.removebyvalue(dirs,dirb)
			table.removebyvalue(dirs,dir2)

			while #dirs>0 do
				local key=math.floor(math.random(0,100))%(#dirs)
				key=key+1
				if GameCharacter._mainAvatar:actionWalk(dirs[key]) >0 then
					GameCharacter._findingDir=dirs[key]
					return
				else
					table.remove(dirs,key)
				end
			end
		end
	-- end
end

function GameCharacter.getNearGhostSort()
	local mGhost = NetCC:getNearGhost(GameConst.GHOST_PLAYER,true)
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	local mResult = {}
	if #mGhost>0 then
		for _,v in ipairs(mGhost) do
			local nearplayer=NetCC:getGhostByID(v)
			if nearplayer then
				local mplayer = {}
				local sameGroup = false
				local sameGuild = false
				if #GameSocket.mGroupMembers > 0 then
					for i=1,#GameSocket.mGroupMembers do
						if GameSocket.mGroupMembers[i].name == nearplayer:NetAttr(GameConst.net_name) then
							sameGroup = true
						end
					end
				end
				if nearplayer:NetAttr(GameConst.net_guild_name) ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name) then
					sameGuild = true
				end
				if not sameGroup and not sameGuild then
					mplayer.id = v
					mplayer.dis = cc.pDistanceSQ(cc.p(nearplayer:NetAttr(GameConst.net_x),nearplayer:NetAttr(GameConst.net_y)),
											cc.p(GameCharacter._mainAvatar:NetAttr(GameConst.net_x),GameCharacter._mainAvatar:NetAttr(GameConst.net_y)))
					table.insert(mResult,mplayer)
				end
			end
		end
	end
	local sortfunction = function(q,w) return tonumber(w.dis) < tonumber(q.dis) end
	table.sort( mResult, sortfunction )
	if #mResult > 0 then
		return mResult[1].id
	end
	return nil
end

function GameCharacter.showSkillName(skill_type)
	-- if skill_type == GameConst.SKILL_TYPE_YiBanGongJi or not GameCharacter._mainAvatar then return end -- 一般攻击不显示技能名称
	-- 	local mSprite = GameCharacter._mainAvatar:getSprite()
	-- 	if mSprite then
	-- 		local skill_name = ccui.ImageView:create()
	-- 		local filepath = "image/typeface/skillname"..skill_type..".png"
	-- 		skill_name:setPosition(24,60);
	-- 		mSprite:addChild(skill_name,20)
	-- 		asyncload_callback(filepath, skill_name, function(filepath, texture)
	-- 			skill_name:loadTexture(filepath)
	-- 			skill_name:runAction(cc.Sequence:create(
	-- 				cca.spawn(
	-- 					{cc.Sequence:create(
	-- 						cc.EaseSineIn:create(cca.scaleTo(0.3,1.5)),
	-- 						cc.EaseSineOut:create(cca.scaleTo(0.2,1)),
	-- 						cc.EaseQuarticActionIn:create(cc.ScaleTo:create(0.5, 0.5))
	-- 						),
	-- 						cca.moveTo(1.0,100,150)
	-- 					}
	-- 				),
	-- 				cca.removeSelf()
	-- 			))
	-- 		end)
	-- end
end

function GameCharacter.checkMonKilled(paramID)
	if paramID and paramID > 0 then
		local netGhost = NetCC:getGhostByID(paramID)
		if netGhost and GameSocket.mTasks[1000] and GameSocket.mTasks[1000].mInfo then
			if netGhost:NetAttr(GameConst.net_name) == GameSocket.mTasks[1000].mInfo.target_name then
				--向服务器发送变装请求
				-- local mainGhost = NetCC:getMainGhost()
				if GameCharacter._mainAvatar and GameCharacter._mainAvatar:NetAttr(GameConst.net_bemonster) == 1 then
					GameSocket:PushLuaTable("task.task1000.onClientData","")
				end
			end
		end
	end
end

local needShiftEquips = {
		-- ["审判之杖"]	={
		-- 	old = {name = "炼狱斧",		id = 20008},
		-- 	new = {name = "审判之杖",	id = 20011},
		-- },
		-- ["骨玉法杖"]	={
		-- 	old = {name = "魔杖",		id = 20009},
		-- 	new = {name = "骨玉法杖",	id = 20012},
		-- },
		-- ["无极刀"]	={
		-- 	old = {name = "天尊银蛇",	id = 20010},
		-- 	new = {name = "无极刀",		id = 20013},
		-- },

		-- ["战将屠龙"]	={
		-- 	old = {name = "审判之杖",	id = 20011},
		-- 	new = {name = "战将屠龙",	id = 20014},
		-- },
		-- ["法灵龙牙"]	={
		-- 	old = {name = "骨玉法杖",	id = 20012},
		-- 	new = {name = "法灵龙牙",	id = 20015},
		-- },
		-- ["道尊灵扇"]	={
		-- 	old = {name = "无极刀",		id = 20013},
		-- 	new = {name = "道尊灵扇",	id = 20016},
		-- },
}

function GameCharacter.checkShiftEquip()
	local weaponDressed = GameSocket:getNetItem(GameConst.ITEM_WEAPON_POSITION)
	if weaponDressed then
		local itemdef = GameSocket:getItemDefByID(weaponDressed.mTypeID)
		if itemdef and needShiftEquips[itemdef.mName]then
			local equipData = needShiftEquips[itemdef.mName]
			if weaponDressed.mLevel == 0 then
				for pos=0, GameConst.ITEM_BAG_SIZE - 1 do
					local weaponInBag = GameSocket:getNetItem(pos)
					if weaponInBag then
						local itemdef2 = GameSocket:getItemDefByID(weaponInBag.mTypeID)
						if itemdef2 and itemdef2.mName == equipData.old.name then
							if weaponInBag.mLevel > 0 then
								GameSocket:PushLuaTable("gui.moduleGuide.onClientData", GameUtilSenior.encode({actionid = "showshift", param = {itemdef.mName}}))
							end
						end
					end
				end
			end
		end
	end
end

function mainrole_action_end(PixesMainAvatar)
	-- if GameCharacter._moveAndFinding then
	-- 	local mItem
	-- 	local tempItem = NetCC:getNearestItem(0)
	-- 	if tempItem and tempItem:NetAttr(GameConst.net_state) ~= true and 
	-- 		(tempItem:NetAttr(GameConst.net_x)~=PixesMainAvatar:NetAttr(GameConst.net_x) or 
	-- 		tempItem:NetAttr(GameConst.net_y)~=PixesMainAvatar:NetAttr(GameConst.net_y)) then
	-- 		mItem = tempItem
	-- 		local owner = mItem:NetAttr(GameConst.net_item_owner) or 0
	-- 		local ittype = mItem:NetAttr(GameConst.net_itemtype) or 0
	-- 		if owner >0 and owner ~= GameCharacter.mID then
	-- 			mItem=nil
	-- 		end
	-- 		if not GameBaseLogic.getPickState(ittype) then
	-- 			mItem=nil
	-- 		end
	-- 	end
	-- 	local mMonster = NetCC:getNearestGhost(GameConst.GHOST_MONSTER)
	-- 	if not mItem and not mMonster then
	-- 		GameCharacter._findingDir=GameCharacter.mDir
	-- 		GameCharacter.randMove()
	-- 	else
	-- 		GameCharacter._moveAndFinding=false
	-- 		GameCharacter.doAutoFight()
	-- 		GameCharacter.doAutoPick()
	-- 	end
	-- else
	-- 	GameCharacter.doAutoFight()
	-- end
	-- print("mainrole_action_end", GameCharacter._mainAvatar, GameCharacter._mainAvatar:PAttr(GameConst.avatar_state), GameConst.STATE_WALK)
	-- if GameCharacter._mainAvatar then
	-- 	if not GameCharacter._pickItemDelay then
	-- 		GameCharacter._pickItemDelay = GameBaseLogic.getTime() + 400
	-- 	end
		-- GameCharacter.pickUpItemUnderFoot()
	-- end
	local mNpc = NetCC:getNearestGhost(GameConst.GHOST_NPC)
	GUIRightCenter.showNpcName(mNpc,PixesMainAvatar)
	if GameCharacter.needCheckPickItem then --action结束之后需要检测当前位置有没有需要拾取的道具
		--print("////////////////////rocker mainrole_action_end//////////////")
		GameCharacter.pickUpItemUnderFoot()
		GameCharacter.needCheckPickItem = false
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAINROLE_ACTIONEND,"mainrole_action_end")

function handle_ghost_die(srcid,avatar)
	local ghostType
	if avatar and avatar.remEffect then
		ghostType = avatar:NetAttr(GameConst.net_type)
		if ghostType~=GameConst.GHOST_PLAYER then
			avatar:remEffect("selected")
		end
	end
	if srcid == _aimGhostID then 
		_aimGhostID = 0
		-- GameCharacter.doAutoFight() 
		-- GameCharacter.doAutoPick()
	end
	if srcid == GameCharacter.mID then
		GUIMain.hideUIPlayer()
		CCGhostManager:selectSomeOne(0)
	else
		ghost_map_bye(srcid)
	end
	-- 死亡刷新名字
	if ghostType == GameConst.GHOST_MONSTER then
		show_monster_title(srcid, avatar:getNameSprite())
	elseif ghostType == GameConst.GHOST_PLAYER then
		show_player_title(srcid, avatar:getNameSprite())
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_GHOST_DIE,"handle_ghost_die")

function GameCharacter.setStatus(statusid,dura,param)
	-- if GameCharacter._statusList[statusid] then
	-- 	if dura > 0 then
	-- 		GameCharacter._statusList[statusid].id = statusid
	-- 		GameCharacter._statusList[statusid].dura = dura
	-- 		GameCharacter._statusList[statusid].param = param
	-- 	else
	-- 		GameCharacter._statusList[statusid] = nil
	-- 	end
	-- else
	-- 	if dura > 0 then
	-- 		GameCharacter._statusList[statusid] = {}
	-- 		GameCharacter._statusList[statusid].id = statusid
	-- 		GameCharacter._statusList[statusid].dura = dura
	-- 		GameCharacter._statusList[statusid].param = param
	-- 	end
	-- end
end

function GameCharacter.getStatuSize()
	local size = 0
	-- if GameCharacter._statusList then
	-- 	for id,status in pairs(GameCharacter._statusList) do
	-- 		if status.dura and status.dura > 0 then
	-- 			size = size + 1
	-- 		end
	-- 	end
	-- end
	return size
end

function GameCharacter.addGhostEffect(srcid,binid,mtype)
	local ghost = NetCC:getGhostByID(srcid)
	local pixesAvatar = CCGhostManager:getPixesAvatarByID(srcid)
	if ghost and (ghost:NetAttr(GameConst.net_type) == GameConst.GHOST_PLAYER or ghost:NetAttr(GameConst.net_type) == GameConst.GHOST_THIS) then
		if mtype == "relive" then
			if ghost:NetAttr(GameConst.net_dead) and ghost:NetAttr(GameConst.net_hp) > 0 then
				if pixesAvatar then
					local mSprite = pixesAvatar:getSprite()
					if mSprite then
						if not mSprite:getChildByName("relive_action") then
							-- local reliveAnim = cc.AnimManager:getInstance():getBinAnimate(4,binid,0,true)
							if reliveAnim then
								local topAnim = cc.Sprite:create()
									:align(display.CENTER, 5, 60)
									:addTo(mSprite,10)
									:setName("relive_action")
									:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})

								topAnim:runAction(cca.seq({
									reliveAnim,
									cca.removeSelf()
								}))
							end
						end
					end
				end
			end
		elseif mtype == "entermap" then
			if pixesAvatar then
				local mSprite = pixesAvatar:getSprite()
				if mSprite then
					if not mSprite:getChildByName("fly_action") then
						-- local reliveAnim = cc.AnimManager:getInstance():getBinAnimate(4,binid,0,true)
						if reliveAnim then
							local topAnim = cc.Sprite:create()
								:align(display.CENTER, 5, 100)
								:addTo(mSprite,10)
								:setName("fly_action")
								:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})

							topAnim:runAction(cca.seq({
								reliveAnim,
								cca.removeSelf()
							}))
						end
					end
				end
			end
		end
	end
end

function GameCharacter.handleEquipChange(pos)
	-- local mainAvatar = CCGhostManager:getMainAvatar()
	-- if not mainAvatar then return end
	-- local mSprite = mainAvatar:getSprite()
	-- if not mSprite then return end
	-- if pos == GameConst.ITEM_CLOTH_POSITION then
	-- 	local netItem = GameSocket:getNetItem(pos)
	-- 	mainAvatar:remEffect("protectBody")
	-- 	if netItem and netItem.mLevel >= 0 then
	-- 		local res = 980001 + math.floor((netItem.mLevel - 1) / 3) + 1
	-- 		mainAvatar:addEffect("protectBody",res,-10,cc.p(14,50),0,true)
	-- 	end
	-- end
end

function GameCharacter.pickUpItemUnderFoot() --拾取打怪掉落的道具
	--print("///////////GameCharacter.pickUpItemUnderFoot////////", tag)
	if not GameBaseLogic.bagFullFlag then
		local netGhost = NetCC:getGhostAtPos(GameCharacter._mainAvatar:PAttr(GameConst.avatar_x),GameCharacter._mainAvatar:PAttr(GameConst.avatar_y),GameConst.GHOST_ITEM)
		if #netGhost>0 then
			local item=NetCC:getGhostByID(netGhost[1])
			local owner = item:NetAttr(GameConst.net_item_owner)
			owner = type(owner) == "boolean" and 0 or owner
			if owner > 0 and owner ~= GameCharacter.mID then
				item=nil
			end

			if item and item:NetAttr(GameConst.net_state) ~= true then
				item:setNetValue(GameConst.net_state, true)
				--print("real pick")
				GameSocket:PickUp(netGhost[1], item:NetAttr(GameConst.net_x) , item:NetAttr(GameConst.net_y))
			end
		end
	end
end


--强化特效

function GameCharacter.handleQiangHuaChange(level)
	local mainAvatar = GameCharacter.updateAttr()
	if not mainAvatar then return end
	local mSprite = mainAvatar:getSprite()
	if not mSprite then return end
	mainAvatar:remEffect("haloLater")
	mainAvatar:remEffect("haloPre")
	local resid = GameBaseLogic.getQiangHuaResid(level)
	if resid then
		mainAvatar:addEffect("haloPre",resid.resPre,10,cc.p(0,50),0,true)--腰间光换前
		mainAvatar:addEffect("haloLater",resid.resLater,-10,cc.p(0,50),0,true)--腰间光环后
	end
end

function GameCharacter.isMySlave(id)
	if GameCharacter._mainAvatar and id then
		local mAimGhost = GameCharacter.getAimGhost(id)
		if mAimGhost:NetAttr(GameConst.net_type) == GameConst.GHOST_SLAVE then
			-- local name = mAimGhost:NetAttr(GameConst.net_name)
			local ownerID = mAimGhost:NetAttr(GameConst.net_item_owner)
			-- local myName = GameCharacter._mainAvatar:NetAttr(GameConst.net_name)
			local myID = GameCharacter._mainAvatar:NetAttr(GameConst.net_id)
			-- if string.find(name, myName) then
			-- 	return true
			-- end
			return myID == ownerID
		end
	end
	return false
end

function GameCharacter.getGhostDistance(ghost)
	local ghostX = ghost:NetAttr(GameConst.net_x)
	local ghostY = ghost:NetAttr(GameConst.net_y)
	GameCharacter.updateAttr()
	local disX = GameCharacter.mX - ghostX
	local disY = GameCharacter.mY - ghostY
	return math.sqrt(disX * disX + disY * disY)
end

function GameCharacter.completeCollect(srcid)
	local mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
	if mAimGhost and srcid == mAimGhost.mID then
		if GameSocket.m_bCollecting then
			GameSocket.m_bCollecting = false
		end
	end
end

-------------------------------战士技能逻辑-------------------------------
-- if pixes_main and GameSocket.m_bCiShaOn and not GameSocket.m_bBanYueOn and GameSocket.m_netSkill[GameConst.SKILL_TYPE_CiShaJianShu] and pixes_main:NetAttr(GameConst.net_weapon)>0 and not GameSocket.m_bLiehuoAction then
-- 	space = 2
-- end
local cDirWalkX = {0,1,1,1,0,-1,-1,-1}
local cDirWalkY = {-1,-1,0,1,1,1,0,-1}
local function NextX(x, dir)
	return x + cDirWalkX[dir + 1]
end
local function NextY(y, dir)
	return y + cDirWalkY[dir + 1]
end
local function hasWeapon()
	-- return GameCharacter._mainAvatar:NetAttr(GameConst.net_weapon) > 0
	return true
end

local function canCastCiSha()
	local mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
	if mAimGhost then
		GameCharacter.updateAttr()
		if GameSocket.m_bCiShaOn and GameSocket.m_netSkill[GameConst.SKILL_TYPE_CiShaJianShu] then
			if math.abs(GameCharacter.mX-mAimGhost.mX)<=2 and math.abs(GameCharacter.mY-mAimGhost.mY)<=2 then
				return true
			end
		end

		-- local dir = GameBaseLogic.getLogicDirection(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(mAimGhost.mX,mAimGhost.mY))
		-- local space = 1
		-- if GameSocket.m_bCiShaOn and not GameSocket.m_bBanYueOn and GameSocket.m_netSkill[GameConst.SKILL_TYPE_CiShaJianShu] then
		-- 	space = 2
		-- end
		-- local cishapos = false
		-- if space==2 and GameCharacter.mX+m_tile_step[dir+1][1]*2==mAimGhost.mX and GameCharacter.mY+m_tile_step[dir+1][2]*2==mAimGhost.mY then
		-- 	cishapos = true
		-- end
		-- return cishapos
	end
end

local function canCastBanYue()
	if GameSocket.m_bBanYueOn and GameSocket.m_netSkill[GameConst.SKILL_TYPE_BanYueWanDao] then
		-- 判断目标周围怪物数量
		GameCharacter.updateAttr()
		local monNum = 0
		local pos_x, pos_y, result
		for i= -1, 2 do
			pos_x = NextX(GameCharacter.mX, (GameCharacter.mDir+i+8)%8)
			pos_y = NextY(GameCharacter.mY, (GameCharacter.mDir+i+8)%8)
			result = NetCC:getGhostAtPos(pos_x, pos_y, GameConst.GHOST_PLAYER)
			if result and #result > 0 then
				monNum = monNum + #result
			end
			if monNum >= 2 then
				break
			end
			result = NetCC:getGhostAtPos(pos_x, pos_y, GameConst.GHOST_MONSTER)
			if result and #result > 0 then
				monNum = monNum + #result
			end
			if monNum >= 2 then
				break
			end
			result = NetCC:getGhostAtPos(pos_x, pos_y, GameConst.GHOST_SLAVE)
			--增加护卫归属判断
			if result and #result > 0 then
				for i,v in ipairs(result) do
					if not GameCharacter.isMySlave(v) then
						monNum = monNum + 1
					end
				end
			end
			if monNum >= 2 then
				break
			end
		end
		if monNum >= 2 then
			return true
		end
	end
end

function GameCharacter.getWarriorSkill()
	local skill_type = GameConst.SKILL_TYPE_YiBanGongJi
	if canCastBanYue() and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_BanYueWanDao) then
		skill_type = GameConst.SKILL_TYPE_BanYueWanDao
	elseif canCastCiSha() and GameBaseLogic.checkMpEnough(GameConst.SKILL_TYPE_CiShaJianShu) then
		skill_type = GameConst.SKILL_TYPE_CiShaJianShu
	end
	return skill_type
end

function GameCharacter.canCastLieHuo()
	local mAimGhost = GameCharacter.getAimGhost(_aimGhostID)
	if mAimGhost then
		GameCharacter.updateAttr()
		if math.abs(GameCharacter.mX-mAimGhost.mX)<2 and math.abs(GameCharacter.mY-mAimGhost.mY)<2 then
			return true
		end
	end
end

GameCharacter.checkDefaultSkillAttack = checkDefaultSkillAttack
GameCharacter.isAttackSkill = isAttackSkill
GameCharacter.isSelectGridSkill = isSelectGridSkill
GameCharacter.isCastGridSkill = isCastGridSkill

return GameCharacter