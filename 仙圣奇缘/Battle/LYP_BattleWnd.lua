--------------------------------------------------------------------------------------
-- 文件名:	LKA_battle.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	游戏战斗
-- 应  用:  本例子使用一般方法的实现Scene

-- 修改人:  yupingli
-- 日  期:	2013-12-26 11:00
-- 版  本:	2.0
-- 描  述:	修改设计
---------------------------------------------------------------------------------------

Enum_EffectLayer = {
	BaseLayer = 10,
	FireEffect = 20,
	StatusEffect = 30,
	FlyEffect = 40,
	AreaEffect = 50,
	BloclEffect = 60,
	HitEffect = 70,
	DeadEffect = 80,
	TiBuEffect = 90,
}

Enum_MeshLayer = {
	BaseLayer = 0,
	Line1 = 1000,
	Line2 = 2000,
	Line3 = 3000,
	FlyEffect = 4000,
	AreaEffect = 5000,
	Damage = 6000,
	SkillName = 7000,
	StatusWord = 8000,
	DamageEffectWord = 9000,
}

Enum_PosLayer = {
	FireEffect = 1000,
	StatusEffect = 2000,
	Damage = 3000,
	DamageEffectWord = 4000,
}

g_AutoAccelerateOpenLevel = nil
if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
	g_AutoAccelerateOpenLevel = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
		[6] = 1,
		[7] = 1,
	}
	g_AutoAccelerateOpenVIPLevel = {
		[1] = 0,
		[2] = 0,
		[3] = 1,
		[4] = 2,
		[5] = 3,
		[6] = 4,
		[7] = 5,
	}
elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
	g_AutoAccelerateOpenLevel = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
		[6] = 1,
		[7] = 1,
	}
	g_AutoAccelerateOpenVIPLevel = {
		[1] = 0,
		[2] = 0,
		[3] = 1,
		[4] = 2,
		[5] = 3,
		[6] = 4,
		[7] = 5,
	}
else
	g_AutoAccelerateOpenLevel = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
		[6] = 1,
		[7] = 1,
	}
	g_AutoAccelerateOpenVIPLevel = {
		[1] = 0,
		[2] = 0,
		[3] = 1,
		[4] = 2,
		[5] = 3,
		[6] = 4,
		[7] = 5,
	}
end

g_tbCardPos = {
	--左边九宫格
	[3]= {tbPos = ccp(-130,120),Scale = 1.0, nBattleLayer = Enum_MeshLayer.Line1,},	    --客户端1号位
	[6]= {tbPos = ccp(-161,10),Scale = 1.05, nBattleLayer = Enum_MeshLayer.Line2,},		--客户端2号位
	[9]= {tbPos = ccp(-202,-128),Scale = 1.1, nBattleLayer = Enum_MeshLayer.Line3,},	    --客户端3号位
	[2]= {tbPos = ccp(-270,120),Scale = 1.0, nBattleLayer = Enum_MeshLayer.Line1+1,},	    --客户端4号位
	[5]= {tbPos = ccp(-333,10),Scale = 1.05, nBattleLayer = Enum_MeshLayer.Line2+1,},		--客户端5号位
	[8]= {tbPos = ccp(-413,-128),Scale = 1.1, nBattleLayer = Enum_MeshLayer.Line3+1,},		--客户端6号位
	[1]= {tbPos = ccp(-411,120),Scale = 1.0, nBattleLayer = Enum_MeshLayer.Line1+2,},		--客户端7号位
	[4]= {tbPos = ccp(-505,10),Scale = 1.05, nBattleLayer = Enum_MeshLayer.Line2+2,},		--客户端8号位
	[7]= {tbPos = ccp(-623,-128),Scale = 1.1, nBattleLayer = Enum_MeshLayer.Line3+2,},		--客户端9号位
	--右边九宫格
	[13]= {tbPos = ccp(130,120),Scale = 1.0, nBattleLayer = Enum_MeshLayer.Line1,},		--客户端1号位
	[16]= {tbPos = ccp(161,10),Scale = 1.05, nBattleLayer = Enum_MeshLayer.Line2,},		--客户端2号位
	[19]= {tbPos = ccp(202,-128),Scale = 1.1, nBattleLayer = Enum_MeshLayer.Line3,},		--客户端3号位
	[12]= {tbPos = ccp(270,120),Scale = 1.0, nBattleLayer = Enum_MeshLayer.Line1+1,},		--客户端4号位
	[15]= {tbPos = ccp(333,10),Scale = 1.05, nBattleLayer = Enum_MeshLayer.Line2+1,},		--客户端5号位
	[18]= {tbPos = ccp(413,-128),Scale = 1.1, nBattleLayer = Enum_MeshLayer.Line3+1,},		--客户端6号位
	[11]= {tbPos = ccp(411,120),Scale = 1.0, nBattleLayer = Enum_MeshLayer.Line1+2,},		--客户端7号位
	[14]= {tbPos = ccp(505,10),Scale = 1.05, nBattleLayer = Enum_MeshLayer.Line2+2,},		--客户端8号位
	[17]= {tbPos = ccp(623,-128),Scale = 1.1, nBattleLayer = Enum_MeshLayer.Line3+2,},		--客户端9号位
}

--如果飞行特效类型是4，特效根据受击目标所在的列，进行如下处
g_tbEffectPos = {
	[1]= {tbPos = ccp(50,120), Scale = 0.9, nBattleLayer = Enum_MeshLayer.Line1,},
	[2]= {tbPos = ccp(50,0), Scale = 0.95, nBattleLayer = Enum_MeshLayer.Line2,},
	[3]= {tbPos = ccp(50, -120), Scale = 1.0, nBattleLayer = Enum_MeshLayer.Line3,},
	[11]= {tbPos = ccp(-50,120), Scale = 0.9, nBattleLayer = Enum_MeshLayer.Line1,},
	[12]= {tbPos = ccp(-50,0), Scale = 0.95, nBattleLayer = Enum_MeshLayer.Line2,},
	[13]= {tbPos = ccp(-50, -120), Scale = 1.0, nBattleLayer = Enum_MeshLayer.Line3,},
}

g_fStatusEffectDelayTime = 1
g_nManaOffset = 8
g_nCardScale = 0.6
g_nAnimationSpeed = 0.5
g_nBaseSpeed = 1.5

g_nIdleSpeedParam = 0.5
g_nSpineIdleAccelaration = 0.35
g_nSpineWalkSpeedParam = 0.5
g_nSpineWalkAccelaration = 0.0
g_nSpineCelebrateSpeedParam = 0.75
g_nSpineCelebrateAccelaration = 0.4
g_nSpineAttackSpeedParam = 0.75
g_nSpineAttackAccelaration = 0.65
g_nSpineMutipleAttackSpeedParam = 0.25
g_nSpineMutipleAttackAccelaration = 1.25
g_nSpineHurtSpeedParam = 0.75
g_nSpineHurtAccelaration = 0.3

g_nPiaoZiAccelaration = 0.0
g_nActionAccelaration = 0.9
g_nWalkAccelaration = 0.4
g_nProcessJsonAniAccelaration = 0.5
g_nCocosJsonAniAccelaration = 0.5
g_nSpineJsonAniAccelaration = 0.2

g_nFlyEffectSpeed = 1000
g_nMaxFigthersIcon = 9

local TbBattleWnd = nil

if g_Cfg.Platform == kTargetAndroid then
	g_RunInScreenDelay = {
		[1] = 0.1,
		[2] = 0.2,
		[3] = 0.3,
		[4] = 0.4,
		[5] = 0.5,
		[6] = 0.6,
		[7] = 0.8,
	}
else
	g_RunInScreenDelay = {
		[1] = 0.0,
		[2] = 0.0,
		[3] = 0.0,
		[4] = 0.05,
		[5] = 0.1,
		[6] = 0.15,
		[7] = 0.2,
	}
end


local tbFightersImageIconPosition =
{
    {
        tbPosX = {5, 65,125,185,245,305,365,425,485},
        nOffsetX = 14,
    }
}

eumn_battle_side_wnd = {
	attack = 1,
	defence = 2
}

Game_Battle = class("Game_Battle")
Game_Battle.__index = Game_Battle

--数据接口
--[[
	tbServerMsg = {
		["battle_type"] = 1,
		["defarmylist"]=  {
			{
				["preattack"] = 0,
				["cardinfo"]=  {
					{
						["phy_defence"] = 72045,
						["is_card"] = false,
						["preattack"] = 0,
						["skill_defence"] = 65721,
						["arraypos"] = 1,
						["skill_attack"] = 137662,
						["attend_step"] = 0,
						["max_sp"] = 8,
						["skill_lv_list"]=  {8,        8,        8,        },
						["powerful_skill_lv"] = 1,
						["star_lv"] = 3,
						["mag_attack"] = 143398,
						["card_lv"] = 115,
						["configid"] = 2400113,
						["cardid"] = 0,
						["is_def"] = true,
						["phy_attack"] = 167942,
						["mag_defence"] = 63269,
						["block_chance"] = 1500,
						["breachlv"] = 8,
						["sp"] = 2,
						["hp"] = 349111,
						["max_hp"] = 349111,
						["normal_skill_lv"] = 1,
					},
					{
						--defencer
					},
				},
			},
			{
				["preattack"] = 0,
				["cardinfo"]=  {
					{
						--defencer
					},
				},
			},
			{
				["preattack"] = 0,
				["cardinfo"]=  {
					{
						--defencer
					},
				},
			},
		},
		["mapid"] = 240013,
		["atkarmy"]= {
			["preattack"] = 15174,
			["cardinfo"]=  {
				{
					["phy_defence"] = 10317,
					["is_def"] = false,
					["configid"] = 1004,
					["is_card"] = true,
					["cardid"] = 200,
					["preattack"] = 3185,
					["skill_defence"] = 6514,
					["arraypos"] = 6,
					["skill_lv_list"]=  {1,        1,        1,        },
					["skill_attack"] = 9791,
					["critical_strikeresistance"] = 149,
					["attend_step"] = 0,
					["max_sp"] = 8,
					["critical_strike"] = 10,
					["block_chance"] = 1020,
					["powerful_skill_lv"] = 1,
					["star_lv"] = 3,
					["mag_attack"] = 9807,
					["card_lv"] = 135,
					["dodge_chance"] = 221,
					["penetrate_chance"] = 35,
					["hit_change"] = 152,
					["hp"] = 33068,
					["phy_attack"] = 14757,
					["mag_defence"] = 6444,
					["critical_chance"] = 203,
					["breachlv"] = 1,
					["sp"] = 2,
					["critical_resistance"] = 910,
					["max_hp"] = 33068,
					["normal_skill_lv"] = 1,
				},
				{
					--attacker
				},
			},
		},
	}
]]--

-- 数据接口
-- local tbBattleScenceInfo = {}
-- tbBattleScenceInfo.battle_type = self.battle_type
-- tbBattleScenceInfo.mapid = self.mapid
-- tbBattleScenceInfo.atkarmy = {}
-- tbBattleScenceInfo.atkarmy.cardinfo = self:getFighterInfoListBySide(eumn_battle_side_wnd.attack)
-- tbBattleScenceInfo.def_name = self.def_name
function proLoadBattleRersouce(tbBattleScenceInfo, tbServerMsg)
	preLoadCommonBattleAni()
	preLoadCommonSkillLightEffect()
    g_BattleMgr:addNpcFighters()
    TbBattleReport = {}
    TbBattleReport.tbBattleScenceInfo = tbBattleScenceInfo
    TbBattleReport.tbServerMsg = tbServerMsg
	TbBattleReport.tbBattleSoundName = {}
	
	--竞技场不能手动战斗
	local nBattleType = TbBattleReport.tbBattleScenceInfo.battle_type
	if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
		or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
		or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
		or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
	then --竞技场
		TbBattleReport.IsAutoFight = true
	else
		TbBattleReport.IsAutoFight = CCUserDefault:sharedUserDefault():getBoolForKey("IsAutoFight", false) --重新初始化
	end
	--初始化战斗加速
	TbBattleReport.nAccelerateSpeed = CCUserDefault:sharedUserDefault():getIntegerForKey("nAccelerateSpeed", 1) --重新初始化
	
	--初始化战斗加速时间加速参数
	g_TimeSpeed = 1/(g_nBaseSpeed+g_nActionAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
	g_TimeSpeedWalk = 1/(g_nBaseSpeed+g_nWalkAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)

	
	local tbFighterList_Atk = TbBattleReport.tbBattleScenceInfo["atkarmy"]["cardinfo"]
	if tbFighterList_Atk == nil then
    	SendError("服务器下发的战斗数据异常，客户端不能初始化战斗")
    	return false
	end
	
    TbBattleReport.tbSkillData = {}
    TbBattleReport.tbGameFighters_OnWnd = {}
	
    local tbFighterList_Atk_Temp = {}
    for nAtkIndex = 1, #tbFighterList_Atk do
		local tbFighter_Atk = tbFighterList_Atk[nAtkIndex]
        if tbFighter_Atk.arraypos < 10 then
			table.insert(tbFighterList_Atk_Temp, tbFighter_Atk)
        end
    end

    --客户端防报错
    if not tbServerMsg.defarmylist[1] then
    	SendError("服务器下发的战斗数据异常，客户端不能初始化战斗")
    	return false
    end

    local tbFighterList_Def = tbServerMsg.defarmylist[1].cardinfo
    local tbFighterList_Def_Temp = {}
    for nDefIndex = 1, #tbFighterList_Def do
        local tbFighter_Def = tbFighterList_Def[nDefIndex]
        if tbFighter_Def.arraypos < 10 then
            table.insert(tbFighterList_Def_Temp, tbFighter_Def)
        end
    end

    local nLoadSpineResouceCount = 0
    local nFighterList_Atk_Temp_Count = #tbFighterList_Atk_Temp
    local nLoadSpineResouceMaxCount = #tbFighterList_Def_Temp + nFighterList_Atk_Temp_Count
	
	--一次性把攻防两方的资源加载进来
    local function preLoadSpineResouce()
        if nLoadSpineResouceMaxCount == nLoadSpineResouceCount then --遍历结束进入副本
            local function openWnd_Game_Battle()		
			    g_WndMgr:closeWnd("Game_LoadingBattle")
                g_WndMgr:openWnd("Game_Battle", tbBattleScenceInfo)
            end
            g_Timer:pushTimer(0.1, openWnd_Game_Battle)
			-- openWnd_Game_Battle()
            return true
        end

       nLoadSpineResouceCount = nLoadSpineResouceCount + 1
       if nLoadSpineResouceCount <= nFighterList_Atk_Temp_Count then -- 加载攻方的
            local tbFighterInfo_Atk = tbFighterList_Atk_Temp[nLoadSpineResouceCount]
			if not tbFighterInfo_Atk then
				return true
			end
			
            local nPos = tbFighterInfo_Atk.arraypos
			local nUniqueId = nPos
            if tbFighterInfo_Atk.is_card then --是卡牌的话那就是攻方的伙伴
	            local GameFighter_Card = CCardPlayer.new()
			    GameFighter_Card:initData(tbFighterInfo_Atk, 1, nil)
				
				--释放再加载
                if TbBattleReport.tbGameFighters_OnWnd[nPos] then TbBattleReport.tbGameFighters_OnWnd[nPos]:release() end
			    TbBattleReport.tbGameFighters_OnWnd[nPos] = GameFighter_Card
            else --不是卡牌的话那就是攻方的npc
	       	    local GameFighter_Npc = CMonsterPlayer.new()
			    GameFighter_Npc:initData(tbFighterInfo_Atk, 1, nil)
				
				--释放再加载
                if TbBattleReport.tbGameFighters_OnWnd[nPos] then TbBattleReport.tbGameFighters_OnWnd[nPos]:release() end
			    TbBattleReport.tbGameFighters_OnWnd[nPos] = GameFighter_Npc
            end
       else
            local tbFighterInfo_Def = tbFighterList_Def_Temp[nLoadSpineResouceCount-nFighterList_Atk_Temp_Count]
            if not tbFighterInfo_Def then
                return true
            end

            local nPos = tbFighterInfo_Def.arraypos
			local nUniqueId = nPos
            --加载怪物的
            if tbFighterInfo_Def.is_card then --是卡牌的话那就是攻守的伙伴，如竞技场里
                local GameFighter_Card = CCardPlayer.new()
                GameFighter_Card:initData(tbFighterInfo_Def, 2, nil)
				
				--释放再加载
                if TbBattleReport.tbGameFighters_OnWnd[nPos + 10] then TbBattleReport.tbGameFighters_OnWnd[nPos + 10]:release() end
                TbBattleReport.tbGameFighters_OnWnd[nPos + 10] = GameFighter_Card
            else --不是卡牌的话那就是守方的怪物
                local GameFighter_Monster = CMonsterPlayer.new()
                GameFighter_Monster:initData(tbFighterInfo_Def, 2, nil)
				
                --释放再加载
                if TbBattleReport.tbGameFighters_OnWnd[nPos + 10] then TbBattleReport.tbGameFighters_OnWnd[nPos + 10]:release() end
                TbBattleReport.tbGameFighters_OnWnd[nPos + 10] = GameFighter_Monster
            end
       end

	   local wndInstance = g_WndMgr:getWnd("Game_LoadingBattle")
	   if wndInstance then
		  wndInstance:showProcess()
	   end
    end
	
	g_WndMgr:releaseAllUnOpenRootWidget()

	g_BattleData:initBattleData()

    g_WndMgr:showWnd("Game_LoadingBattle", {nLoop = nLoadSpineResouceMaxCount, func = preLoadSpineResouce})
	if TbBattleReport.tbBattleScenceInfo["battle_type"] == macro_pb.Battle_Atk_Type_dujie then
		g_FormMsgSystem:SendFormMsg(FormMsg_BattBuZhenDuJie_Wnd, nil)
	end
end

function Game_Battle:initGameAttackerBornAction(funcInitBornAllEndCall, bHelperBornAction, nHelperBornAction)
    local tbFighterInfoList_Atk = TbBattleReport.tbBattleScenceInfo["atkarmy"]["cardinfo"]
	TbBattleReport.tbSubsitutionFighterList_Atk = {}

	local nBornFighterCount = 0
	local nBornFighterMaxCount = 0
    local function executeFighterIdleAniCount()
        nBornFighterCount = nBornFighterCount + 1
        if nBornFighterMaxCount == nBornFighterCount then
			if funcInitBornAllEndCall then
				funcInitBornAllEndCall()
			end
		end
    end

    local function funcRunInScreenEndCall(GameFighter_Attacker)
		local function executeFighterIdleAni()
            GameFighter_Attacker:addSPAnimation()
            GameFighter_Attacker:runSpineIdle()
            executeFighterIdleAniCount()
	    end
        return executeFighterIdleAni
    end

	local function sortTbFighterInfoList_Atk(tbFighterInfo_AtkA, tbFighterInfo_AtkB)
		local nPosA = tbFighterInfo_AtkA.arraypos
		local nPosB = tbFighterInfo_AtkB.arraypos
		local nClientPosA = tbServerToClientPosConvert[nPosA]
		local nClientPosB = tbServerToClientPosConvert[nPosB]
		if nClientPosA > nClientPosB then
			return false
		else
			return true
		end
	end
	table.sort(tbFighterInfoList_Atk, sortTbFighterInfoList_Atk)
	
	local nAccelerateSpeed = TbBattleReport.nAccelerateSpeed or 1
	nAccelerateSpeed = math.max(nAccelerateSpeed, 1)
	nAccelerateSpeed = math.min(nAccelerateSpeed, 7)
	local fDelayTime = g_RunInScreenDelay[nAccelerateSpeed]
	
	for nFighterIndex = 1, #tbFighterInfoList_Atk do
		local tbFighterInfo_Atk = tbFighterInfoList_Atk[nFighterIndex]
		local nPos = tbFighterInfo_Atk.arraypos
		if nPos < 10 then
			if tbFighterInfo_Atk.is_card then --伙伴
				local GameFighter_Card = TbBattleReport.tbGameFighters_OnWnd[nPos]
				local tbCardPos = g_tbCardPos[nPos]
				TbBattleReport.Mesh:addChild(GameFighter_Card, tbCardPos.nBattleLayer)
				if GameFighter_Card then
					if bHelperBornAction then
						if nHelperBornAction == 1 then  --一起出场
							GameFighter_Card:startRunInScreen(funcRunInScreenEndCall(GameFighter_Card), fDelayTime)
						else
							GameFighter_Card:startRunInScreen(funcRunInScreenEndCall(GameFighter_Card), fDelayTime)
						end
					else
						GameFighter_Card:startRunInScreen(funcRunInScreenEndCall(GameFighter_Card), fDelayTime)
					end
				end
				nBornFighterMaxCount = nBornFighterMaxCount + 1
			else--怪物
				local GameFighter_Npc = TbBattleReport.tbGameFighters_OnWnd[nPos]
				local tbCardPos = g_tbCardPos[nPos]
				TbBattleReport.Mesh:addChild(GameFighter_Npc, tbCardPos.nBattleLayer)
				if GameFighter_Npc then
					if bHelperBornAction then
						if nHelperBornAction == 1 then  --一起出场
							GameFighter_Npc:startRunInScreen(funcRunInScreenEndCall(GameFighter_Npc), fDelayTime)
							nBornFighterMaxCount = nBornFighterMaxCount + 1
						else
							-- 不需要出场
						end
					else
						GameFighter_Npc:startRunInScreen(funcRunInScreenEndCall(GameFighter_Npc), fDelayTime)
						nBornFighterMaxCount = nBornFighterMaxCount + 1
					end
				end
			end
		else
			--说明到了替补了
			TbBattleReport.tbSubsitutionFighterList_Atk[nPos] = tbFighterInfo_Atk
		end
	end

	TbBattleReport.GameObj_BattleProcess:playFootStepSound(2)
    initFighterImageIconList(eumn_battle_side_wnd.attack)
	return true
end


local function getCurrentUseSkillFighterIndex(nPos)
    local nEumnBattleSideWnd = 1
    if nPos and nPos > 10 then
        nEumnBattleSideWnd = 2
    end
	
	if TbBattleReport and TbBattleReport.tbFightersPosListByIndex then
		local tbFightersPosListByIndex = TbBattleReport.tbFightersPosListByIndex[nEumnBattleSideWnd]
		if tbFightersPosListByIndex then
			  for nFighterIndex = 1, #tbFightersPosListByIndex do
				if tbFightersPosListByIndex[nFighterIndex] == nPos then
					return nFighterIndex, nEumnBattleSideWnd
				end
			end
		end
	end
	
    return nil, nEumnBattleSideWnd
end

local function moveCursorTo(index, nType)
    widget:setPosition(point)
end

local function moveCursorBy(nTime, widget)
    local arrAct = CCArray:create()
    local moveBy = CCMoveBy:create(nTime, CCPoint(0, -20))
    arrAct:addObject(moveBy)
    local action = CCSequence:create(arrAct)
    widget:runAction(action)
end

local function scaleToImageFighter(nTime, Image_Fighter)
    if not Image_Fighter then  return end
    local arrAct = CCArray:create()
    local actionScaleTo = CCScaleTo:create(nTime, 1)
    arrAct:addObject(actionScaleTo)
    local action = CCSequence:create(arrAct)
    Image_Fighter:runAction(action)
end

local Image_Cursor_Last = nil
local function setFighterImageIconCursor(Image_Fighter_Cursor, Image_Fighter)
    if Image_Cursor_Last then
        local Image_Cursor = Image_Cursor_Last:getChildByName("Image_Cursor")
        Image_Cursor:setVisible(false)
    end
    Image_Fighter_Cursor:removeFromParentAndCleanup(true)
    Image_Fighter:addNode(Image_Fighter_Cursor)

    local Image_Cursor = Image_Fighter:getChildByName("Image_Cursor")
    Image_Cursor:setVisible(true)
    Image_Cursor_Last = Image_Fighter
end

--nEumnBattleSideWnd 1是角色 2是怪物
local function showScaleAction(widget, nActionIndex, nEumnBattleSideWnd)
	
    local nMaxFightersOnSide = #TbBattleReport.tbFightersPosListByIndex[nEumnBattleSideWnd]
    if nMaxFightersOnSide == 1 then
        return
    end

    local tbFightersIamgeIconList_OnSide = TbBattleWnd.tbFightersIamgeIconList[nEumnBattleSideWnd]
    local tbImageIconPosition = tbFightersImageIconPosition[nEumnBattleSideWnd]
    local tbPosXAdjust = tbImageIconPosition.tbPosX
    local nPosY = -40
    local nPosX = tbImageIconPosition.nOffsetX
    local fTime = 0.4*g_TimeSpeed

	--等于0时，全部一起缩小 在所有头像缩小动画播完后 光标移动到下一个单位。
	if nActionIndex and nActionIndex == 0 then
		for nIconIndex = 1, nMaxFightersOnSide do
			local Image_Fighter = tbFightersIamgeIconList_OnSide[nIconIndex]
			if Image_Fighter then
				local actionScaleTo = CCScaleTo:create(fTime, 0.8)
				local actionMoveTo = CCMoveTo:create(fTime, CCPoint(tbPosXAdjust[nIconIndex], nPosY))
				local actionSpawn =  CCSpawn:createWithTwoActions(actionScaleTo, actionMoveTo)
				Image_Fighter:runAction(actionSpawn)
			end
		end

        local function moveCursorToNext()
           local tbFighterSequenceList = g_BattleMgr:getFighterSequenceList()
           for nSequenceIdex = 1, #tbFighterSequenceList do
               if nEumnBattleSideWnd - 1 == tbFighterSequenceList[nSequenceIdex].atkno then
                  local nActionIndex, nEumnBattleSideWnd = getCurrentUseSkillFighterIndex(tbFighterSequenceList[nSequenceIdex].atkno*10 + tbFighterSequenceList[nSequenceIdex].apos)
                  local Image_Fighter = tbFightersIamgeIconList_OnSide[nActionIndex]
                  setFighterImageIconCursor(tbFightersIamgeIconList_OnSide.Image_Fighter_Cursor, Image_Fighter)
                  break
               end
           end
        end
        g_Timer:pushTimer(fTime, moveCursorToNext)
	elseif nActionIndex and nActionIndex == nMaxFightersOnSide then
		for nIconIndex = 1, nMaxFightersOnSide do
			local Image_Fighter = tbFightersIamgeIconList_OnSide[nIconIndex]
			if Image_Fighter then
				if nIconIndex == nActionIndex then
					local actionScaleTo = CCScaleTo:create(fTime, 1)
					local actionMoveTo = CCMoveTo:create(fTime, CCPoint(tbPosXAdjust[nIconIndex], nPosY))
					local actionSpawn =  CCSpawn:createWithTwoActions(actionScaleTo, actionMoveTo)
					Image_Fighter:runAction(actionSpawn)
                    setFighterImageIconCursor(tbFightersIamgeIconList_OnSide.Image_Fighter_Cursor, Image_Fighter)
				else
					if nIconIndex == 1 then
						local actionScaleTo = CCScaleTo:create(fTime, 0.8)
						local actionMoveTo = CCMoveTo:create(fTime, CCPoint(tbPosXAdjust[nIconIndex], nPosY))
						local actionSpawn =  CCSpawn:createWithTwoActions(actionScaleTo, actionMoveTo)
						Image_Fighter:runAction(actionSpawn)
					else
						local actionScaleTo = CCScaleTo:create(fTime, 0.8)
						local actionMoveTo = CCMoveTo:create(fTime, CCPoint(tbPosXAdjust[nIconIndex], nPosY))
						local actionSpawn =  CCSpawn:createWithTwoActions(actionScaleTo, actionMoveTo)
						Image_Fighter:runAction(actionSpawn)
					end
				end
			end
		end
	else
		for nIconIndex = 1, nMaxFightersOnSide do
			local Image_Fighter = tbFightersIamgeIconList_OnSide[nIconIndex]
			if Image_Fighter then
				if nActionIndex and nActionIndex == nIconIndex then
					local actionScaleTo = CCScaleTo:create(fTime, 1)
					local actionMoveTo = CCMoveTo:create(fTime, CCPoint(tbPosXAdjust[nIconIndex], nPosY))
					local actionSpawn =  CCSpawn:createWithTwoActions(actionScaleTo, actionMoveTo)
					Image_Fighter:runAction(actionSpawn)
                    setFighterImageIconCursor(tbFightersIamgeIconList_OnSide.Image_Fighter_Cursor, Image_Fighter)
				else
					if nActionIndex and nActionIndex > nIconIndex then
						local actionScaleTo = CCScaleTo:create(fTime, 0.8)
						local actionMoveTo = CCMoveTo:create(fTime, CCPoint(tbPosXAdjust[nIconIndex], nPosY))
						local actionSpawn =  CCSpawn:createWithTwoActions(actionScaleTo, actionMoveTo)
						Image_Fighter:runAction(actionSpawn)
					else
						local actionScaleTo = CCScaleTo:create(fTime, 0.8)
						local actionMoveTo = CCMoveTo:create(fTime, CCPoint(tbPosXAdjust[nIconIndex]+nPosX, nPosY))
						local actionSpawn =  CCSpawn:createWithTwoActions(actionScaleTo, actionMoveTo)
						Image_Fighter:runAction(actionSpawn)
					end
				end
			end
		end
	end
end

local function showArmatureFoot(nPos)
    if nPos < 10 then
        local GameFighter_Attacker = TbBattleReport.tbGameFighters_OnWnd[nPos]
		if not GameFighter_Attacker then return end
        TbBattleWnd.ArmatureFoot:removeFromParentAndCleanup(true)
        TbBattleWnd.ArmatureFoot:setOpacity(255)
        GameFighter_Attacker.Image_Shadow:addNode(TbBattleWnd.ArmatureFoot)
        local userAnimation = TbBattleWnd.ArmatureFoot:getAnimation()
        userAnimation:playWithIndex(0)

		TbBattleWnd.ArmatureArrow:removeFromParentAndCleanup(true)
        TbBattleWnd.ArmatureArrow:setOpacity(255)
		TbBattleWnd.ArmatureArrow:setPositionXY(GameFighter_Attacker.tbFighterBase.HPBarX, GameFighter_Attacker.tbFighterBase.HPBarY+80)
        GameFighter_Attacker.Image_Shadow:addNode(TbBattleWnd.ArmatureArrow)
        local userAnimation = TbBattleWnd.ArmatureArrow:getAnimation()
        userAnimation:playWithIndex(0)
    end
end

function adjustFighterImageIconCursor(nPos)
    local nFighterIndex, nEumnBattleSideWnd = getCurrentUseSkillFighterIndex(nPos)
    local tbFightersIamgeIconList_OnSide = TbBattleWnd.tbFightersIamgeIconList[nEumnBattleSideWnd]
    if not tbFightersIamgeIconList_OnSide then return end

    if not TbBattleReport.nEumnBattleSideWnd then
        local nTime = 0.4*g_TimeSpeed
        scaleToImageFighter(nTime, tbFightersIamgeIconList_OnSide[nFighterIndex])
    else
        if TbBattleReport.nEumnBattleSideWnd ~= nEumnBattleSideWnd then
            showScaleAction(nil, 0, TbBattleReport.nEumnBattleSideWnd)
        end
        showScaleAction(tbFightersIamgeIconList_OnSide[nFighterIndex], nFighterIndex, nEumnBattleSideWnd)
    end

    showArmatureFoot(nPos)
    TbBattleReport.nEumnBattleSideWnd = nEumnBattleSideWnd
end

 local function onPressing_Button_Skill(pSender, nTag)
    local nCurrentAttackPos = TbBattleReport.nCurrentAttackPos
    if not nCurrentAttackPos or nCurrentAttackPos  > 10 then
        return
    end

    local tbSkillData = TbBattleReport.tbSkillData[nCurrentAttackPos]
    local tbSkill = tbSkillData[nTag]
	--[[
	a，使用之前写的g_OnShowTip函数
	b，显示格式为第一行技能名称，第二行技能攻击范围，第三行技能描述
	c，攻击范围根据技能表攻击范围字段在g_SkillBaseAttackArea的table中找到其中文名
	增加怒气值（NeedEnergy字段）消耗的Tip显示，显示在最后，格式是“需要x点怒气”
	]]
	local tbString = {}
    local tbSkillDesc = {}
    table.insert(tbSkillDesc, tbSkill.Name)
    table.insert(tbString, tbSkillDesc)

    local AttackArea = tbSkill["AttackArea"]
    local AttackAreaText = g_SkillBaseAttackArea[AttackArea]
    tbSkillDesc = {}
    table.insert(tbSkillDesc, AttackAreaText)
    table.insert(tbString, tbSkillDesc)

    tbSkillDesc = {}
    table.insert(tbSkillDesc, tbSkill.Desc)
    table.insert(tbString, tbSkillDesc)

    tbSkillDesc = {}
    table.insert(tbSkillDesc, string.format(_T("需要%d点怒气"), tbSkill.NeedEnergy) )
    table.insert(tbString, tbSkillDesc)
	--[4] = {"可通过招财神符获得大量铜钱", ccc3(255,165,122)}

    local tbPos = pSender:getWorldPosition()
	tbPos.x = tbPos.x
	tbPos.y = tbPos.y + 160
	
	g_ClientMsgTips:showTip(tbString, tbPos, 3)
end


local function fadeOut(widget, funcCallBack)
    local function remove()
        widget:setVisible(false)
    end
    funcCallBack = funcCallBack or remove
    local arrAct = CCArray:create()
    local fadeout = CCFadeOut:create(0.5*g_TimeSpeed)
	arrAct:addObject(fadeout)
    if(funcCallBack)then
		arrAct:addObject(CCCallFuncN:create(funcCallBack))
	end

	local action = CCSequence:create(arrAct)

    widget:runAction(action)
end

local function onClickConfirmBuZhen()
    TbBattleReport.bResetBuZhen = nil
    local tbGameFighterIdListInPos = {}
    for nPos, GameFighter in pairs(TbBattleReport.tbGameFighters_OnWnd) do
        if nPos < 10 then
            tbGameFighterIdListInPos[nPos] = GameFighter.cardid
            GameFighter.Layout_CardClickArea:setTouchEnabled(true)
        end
    end

    TbBattleReport.TbBattleWnd.Image_BuZhen:stopAllActions()
    fadeOut(TbBattleWnd.Image_BuZhen)
    g_BattleMgr:resetArrayPos(tbGameFighterIdListInPos)

    --暂时先隐藏
    for nIconIndex = 1, g_nMaxFigthersIcon do
        local tbFightersIamgeIconList_Atk = TbBattleWnd.tbFightersIamgeIconList[eumn_battle_side_wnd.attack]
		tbFightersIamgeIconList_Atk[nIconIndex]:setVisible(false)
		tbFightersIamgeIconList_Atk.Image_Fighter_Cursor:setVisible(false)
    end
    initFighterImageIconList(eumn_battle_side_wnd.attack)
    initFighterImageIconList(eumn_battle_side_wnd.defence)
    TbBattleReport.GameObj_BattleProcess:showBattleStartAnimation()
end

local function onPressed_Button_Skill(pSender, nIndex)
    --not TbBattleReport or TbBattleReport.IsAutoFight or not TbBattleWnd.bShow or TbBattleReport.bUseSkll
	if not TbBattleReport or TbBattleReport.IsAutoFight or not TbBattleWnd.bShow then 
		return
	end

	local nCurrentAttackPos = TbBattleReport.nCurrentAttackPos
	if not nCurrentAttackPos or nCurrentAttackPos  > 10 then
		return
	end
	
	local CCNode_Guide = pSender:getNodeByTag(919)
	if CCNode_Guide then
		pSender:removeNodeByTag(919)
	end
	
	local GameFighter_Attacker = TbBattleReport.tbGameFighters_OnWnd[nCurrentAttackPos]
	if nIndex > 1 and GameFighter_Attacker and  not GameFighter_Attacker:checkUseSkill(nIndex) then
		pSender:getNodeByTag(1)
		return
	end

	local function useSkillCallBack()
--		TbBattleReport.bUseSkll = nil
	end

	local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("SkillPressEffect", nil, useSkillCallBack, 2, nil, true)
	if nIndex == 1 then
		armature:setScale(1.8)
	else
		armature:setScale(1)
	end
	pSender:addNode(armature, 10)
	userAnimation:playWithIndex(0)
--	TbBattleReport.bUseSkll = true

	--强制执行一次隐藏操作
	hidePlayerSkillIcon()

	GameFighter_Attacker.nAutoSkillIndex = nIndex
	g_BattleMgr:setFighterUseSkillIndex(0, nCurrentAttackPos, nIndex)
	TbBattleReport.GameObj_BattleProcess:startBattleTurnProcess(nCurrentAttackPos)
end

function Game_Battle:registerBtnEvent()
	local Panel_BackGround = self.rootWidget:getChildByName("Panel_BackGround")
	local Image_BottomLeftPNL = Panel_BackGround:getChildByName("Image_BottomLeftPNL")
	local Image_TopRightPNL = Panel_BackGround:getChildByName("Image_TopRightPNL")
	
    --是否自动战斗
	local function onClickAutoFight(pSender, nTag)
		if not TbBattleReport or TbBattleReport.bOver then  return end
		
		local nBattleType = g_BattleData:getEctypeType()
		if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
			or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
			or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
			or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
		then --竞技场

			g_ClientMsgTips:showMsgConfirm(_T("在竞技场里面只能自动战斗哟亲~"))
			return
		end
		
        if TbBattleReport.bEscape then
			EscapeClearAllResouce(false, false)
			return
        end

        if TbBattleReport.bResetBuZhen then
			return
		end

		if TbBattleReport.IsAutoFight then
			TbBattleReport.IsAutoFight = false
			CCUserDefault:sharedUserDefault():setBoolForKey("IsAutoFight", false)
		else
			TbBattleReport.IsAutoFight = true
			CCUserDefault:sharedUserDefault():setBoolForKey("IsAutoFight", true)

			if TbBattleReport.nCurrentAttackPos and TbBattleWnd.bShow then
				autoUseSkill(0, TbBattleReport.nCurrentAttackPos)
				TbBattleReport.GameObj_BattleProcess:startBattleTurnProcess(TbBattleReport.nCurrentAttackPos)
				TbBattleReport.nCurrentAttackPos = nil
                hidePlayerSkillIcon()
			end		

		end
		TbBattleReport.TbBattleWnd.tbWidgetSkillIcon[1]:removeAllNodes()
		self:showButtonAniAutoFight()
    end

	self.Button_AutoFight = tolua.cast(Image_BottomLeftPNL:getChildByName("Button_AutoFight"),"Button")

	g_SetBtnWithGuideCheck(self.Button_AutoFight, nil, onClickAutoFight, true, nil, nil, true)


	local function onClickAccelerate(pSender, nTag)
        --战斗教学加速按钮 和 正常战斗
		if g_BattleTeachSystem and g_BattleTeachSystem.bTeachIng or g_Hero:getMasterCardLevel() < 2 then
			g_ClientMsgTips:showMsgConfirm(_T("通关灵仙岛1后达到2级解锁战斗加速"))
			return
		end
		
		if not TbBattleReport or TbBattleReport.bOver then  return end

        if TbBattleReport.bEscape then
            EscapeClearAllResouce(false, false)
            return
        end
		
		if TbBattleReport.bResetBuZhen then
			return
		end
		
		pSender:removeAllNodes()
		
		local nAccelerateSpeed = CCUserDefault:sharedUserDefault():getIntegerForKey("nAccelerateSpeed", 1)
		nAccelerateSpeed = nAccelerateSpeed + 1

		if g_Cfg.Platform == kTargetWindows then
			if nAccelerateSpeed > 30 then
				nAccelerateSpeed = 1
			end
		else
			if g_AutoAccelerateOpenVIPLevel[nAccelerateSpeed] then
				if g_VIPBase:getVIPLevelId() < g_AutoAccelerateOpenVIPLevel[nAccelerateSpeed] then
					if g_AutoAccelerateOpenLevel[nAccelerateSpeed] then 
						if g_Hero:getMasterCardLevel() < g_AutoAccelerateOpenLevel[nAccelerateSpeed] then
							if not self.bHasShowAccelerateSpeed then
								g_ClientMsgTips:showMsgConfirm(string.format(_T("需要VIP%d或者主角等级达到%d级开放%d倍速"), g_AutoAccelerateOpenVIPLevel[nAccelerateSpeed], g_AutoAccelerateOpenLevel[nAccelerateSpeed], nAccelerateSpeed))
								self.bHasShowAccelerateSpeed = true
								nAccelerateSpeed = nAccelerateSpeed - 1
							else
								self.bHasShowAccelerateSpeed = false
								nAccelerateSpeed = 1
							end
						end
					else
						nAccelerateSpeed = 1
					end
				end
			else
				nAccelerateSpeed = 1
			end
		end
		
		TbBattleReport.nAccelerateSpeed = nAccelerateSpeed
		CCUserDefault:sharedUserDefault():setIntegerForKey("nAccelerateSpeed", nAccelerateSpeed)
		
		g_TimeSpeed = 1/(g_nBaseSpeed+g_nActionAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
		g_TimeSpeedWalk = 1/(g_nBaseSpeed+g_nWalkAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
		
		local BitmapLabel_Accelerate = tolua.cast(pSender:getChildByName("BitmapLabel_Accelerate"),"LabelBMFont")
		BitmapLabel_Accelerate:setText("×"..nAccelerateSpeed)
		self:showButtonAniAccelerate()
		--数字越大,光效越快
		for key, value in pairs(TbBattleReport.tbGameFighters_OnWnd) do
			if(value.AniStatusLightEffect)then
				value.AniStatusLightEffect:getAnimation():setSpeedScale(g_nBaseSpeed+g_nCocosJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
			end
			if value.bIsInIdleStatus then
				value.CCNode_Skeleton:setSpeed(g_nBaseSpeed+g_nSpineIdleAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed*g_nIdleSpeedParam)
			else
				value.CCNode_Skeleton:setSpeed(g_nBaseSpeed+g_nSpineAttackAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed*g_nSpineAttackSpeedParam)
			end
		end
    end
	self.Button_Accelerate = tolua.cast(Image_BottomLeftPNL:getChildByName("Button_Accelerate"),"Button")
	g_SetBtnWithGuideCheck(self.Button_Accelerate, nil, onClickAccelerate, true, nil, nil, true)

    local function onClickDropItems()
		if g_BattleTeachSystem and g_BattleTeachSystem.bTeachIng then return end
		
		if g_PlayerGuide:checkIsInGuide() and g_PlayerGuide:checkIsInGuide() <= 3 then
			return
		end
        g_WndMgr:showWnd("Game_BattleDrop")
    end
	self.Button_DropItems = tolua.cast(Image_BottomLeftPNL:getChildByName("Button_DropItems"),"Button")
	g_SetBtnWithGuideCheck(self.Button_DropItems, nil, onClickDropItems, true, nil, nil, nil)

	local function onClickSetting()
		if g_BattleTeachSystem and g_BattleTeachSystem.bTeachIng then
			g_ClientMsgTips:showMsgConfirm(_T("处于战斗剧情副本中, 无法使用战斗设置功能"))
			return
		end
        g_WndMgr:showWnd("Game_BattleSetting")
    end
	self.Button_Setting = tolua.cast(Image_TopRightPNL:getChildByName("Button_Setting"),"Button")
	g_SetBtnWithGuideCheck(self.Button_Setting, nil, onClickSetting, true, nil, nil, nil)
end

function Game_Battle:initWnd()
	TbBattleWnd = {}
	--背景地a图
	TbBattleWnd.Scene = tolua.cast(self.rootWidget:getChildByName("Image_Scene"),"ImageView")
	TbBattleWnd.Scene:setVisible(true)

    TbBattleWnd.Image_BuZhen = tolua.cast(TbBattleWnd.Scene:getChildByName("Image_BuZhen"),"ImageView")
	TbBattleWnd.Image_BuZhen:setVisible(false)
	for i = 1, 9 do
		local widget = TbBattleWnd.Image_BuZhen:getChildByName("Button_BattlePos"..i)
		widget:setTag(tbClientToServerPosConvert[i])
        widget:setTouchEnabled(false)
	end

	--网格
	TbBattleWnd.Mesh = tolua.cast(TbBattleWnd.Scene:getChildByName("Image_Mesh"),"ImageView")
	TbBattleWnd.Mesh:setVisible(true)
	
	local Panel_BackGround = self.rootWidget:getChildByName("Panel_BackGround")
	local Image_TopLeftPNL = Panel_BackGround:getChildByName("Image_TopLeftPNL")
	local Image_BottomLeftPNL = Panel_BackGround:getChildByName("Image_BottomLeftPNL")
	local Image_BottomRightPNL = Panel_BackGround:getChildByName("Image_BottomRightPNL")
	
	TbBattleWnd.Label_EctypeName = tolua.cast(Image_TopLeftPNL:getChildByName("Label_EctypeName"),"Label")
	
	local Image_RoundIndex = Image_TopLeftPNL:getChildByName("Image_RoundIndex")
	TbBattleWnd.BitmapLabel_RoundIndex = tolua.cast(Image_RoundIndex:getChildByName("BitmapLabel_RoundIndex"),"LabelBMFont")
	TbBattleWnd.BitmapLabel_RoundIndex:setPositionX(Image_RoundIndex:getSize().width + 10)
	TbBattleWnd.Label_EctypeName:setPositionX(Image_RoundIndex:getSize().width + TbBattleWnd.BitmapLabel_RoundIndex:getSize().width + 18)
	
	local Button_DropItems = Image_BottomLeftPNL:getChildByName("Button_DropItems")
    TbBattleWnd.Image_ItemsIcon = Button_DropItems:getChildByName("Image_ItemsIcon")
    TbBattleWnd.Label_ItemNum = tolua.cast(Button_DropItems:getChildByName("Label_ItemNum"),"Label")

    TbBattleWnd.tbWidgetSkillIcon = {}
    TbBattleWnd.tbWidgetSkillPos = {}
    local Button_NormalSkill = Image_BottomRightPNL:getChildByName("Button_NormalSkill")
    Button_NormalSkill:setZOrder(5)
    table.insert(TbBattleWnd.tbWidgetSkillIcon, Button_NormalSkill)
    table.insert(TbBattleWnd.tbWidgetSkillPos, Button_NormalSkill:getPosition())
	g_SetBtnWithPressingEvent(Button_NormalSkill, 1, nil, onPressed_Button_Skill, nil, true, 0.25)
	
    local Panel_Stencil = tolua.cast(Button_NormalSkill:getChildByName("Panel_Stencil"), "Layout")
    Panel_Stencil:setTouchEnabled(false)
    Panel_Stencil:setClippingEnabled(true)
    Panel_Stencil:setRadius(67)

    for i= 1, 3 do
        local Button_Skill = Image_BottomRightPNL:getChildByName("Button_Skill"..i)
        table.insert(TbBattleWnd.tbWidgetSkillIcon, Button_Skill)
        table.insert(TbBattleWnd.tbWidgetSkillPos, Button_Skill:getPosition())
        Button_Skill:setPosition(TbBattleWnd.tbWidgetSkillPos[1])
		g_SetBtnWithPressingEventAndGuide(Button_Skill, i+1, onPressing_Button_Skill, onPressed_Button_Skill, g_OnCloseTip, true, 0.25)
        Button_Skill:setCascadeOpacityEnabled(true)
        Button_Skill:setCascadeColorEnabled(true)
    end


    TbBattleWnd.tbFightersIamgeIconList = {}
    local tbFightersIamgeIconList_Atk = {}
    for nIconIndex = 1, g_nMaxFigthersIcon do
        local Image_Fighter = Image_TopLeftPNL:getChildByName("Image_Fighter"..nIconIndex)
		Image_Fighter:removeAllNodes()
        table.insert(tbFightersIamgeIconList_Atk, Image_Fighter)
        Image_Fighter:setCascadeOpacityEnabled(true)
        Image_Fighter:setCascadeColorEnabled(true)
    end

    local armature, userAnimation = g_CreateCoCosAnimation("BattleFighterCursor", nil, 6)
    tbFightersIamgeIconList_Atk.Image_Fighter_Cursor = armature
    userAnimation:playWithIndex(0)

    table.insert(TbBattleWnd.tbFightersIamgeIconList, tbFightersIamgeIconList_Atk)
    tbFightersIamgeIconList_Atk = nil
    TbBattleWnd.bShow = true
    hidePlayerSkillIcon()

    TbBattleWnd.ArmatureFoot = g_CreateCoCosAnimation("BattleCurrentFighterA", nil, 6)
	TbBattleWnd.ArmatureFoot:setScale(1.5)
	TbBattleWnd.ArmatureFoot:setTag(1)
    TbBattleWnd.ArmatureFoot:retain()

	TbBattleWnd.ArmatureArrow = g_CreateCoCosAnimation("BattleCurrentFighterArrow", nil, 6)
	TbBattleWnd.ArmatureArrow:setScale(1)
	TbBattleWnd.ArmatureArrow:setTag(2)
    TbBattleWnd.ArmatureArrow:retain()

    self:registerBtnEvent()

    TbBattleWnd.Panel_Energy = tolua.cast(Button_NormalSkill:getChildByName("Panel_Energy"), "Layout")
    TbBattleWnd.Panel_Energy:setTouchEnabled(false)
    local Image_EnergyPNL =  TbBattleWnd.Panel_Energy:getChildByName("Image_EnergyPNL")
    Image_EnergyPNL:setOpacity(0)
	Image_EnergyPNL:setScaleX(1.3)
	Image_EnergyPNL:setScaleY(1.26)
	Image_EnergyPNL:setRotation(-1)

    local armature,userAnimation = g_CreateCoCosAnimation("EnergyNormal", nil, 6)
    TbBattleWnd.EnergyNormal = armature
	Image_EnergyPNL:removeAllNodes()
    Image_EnergyPNL:addNode(armature)
    userAnimation:playWithIndex(0)
    armature:setPositionXY(0,-1)
	
	TbBattleWnd.Image_GoGoGo = tolua.cast(self.rootWidget:getChildByName("Image_GoGoGo"), "ImageView")
	TbBattleWnd.Image_GoGoGo:setVisible(false)
	
	cclog("===============Game_Battle=================初始化完窗口了")
end

local function spawnIn(duration)
    local arrAct = CCArray:create()
	local action_MoveTo = CCMoveTo:create(duration, TbBattleWnd.tbWidgetSkillPos[1])
	local action_MoveToEase = CCEaseBackIn:create(action_MoveTo)
	arrAct:addObject(action_MoveToEase)

	return CCSequence:create(arrAct)
end

local function spawnOut(duration, point, nIndex)
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventStart", "Game_Battle") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end

    local arrAct = CCArray:create()
	local action_MoveTo = CCMoveTo:create(duration, point)
	local action_MoveToEase = CCEaseBackOut:create(action_MoveTo)
	arrAct:addObject(action_MoveToEase)
	local function executeActionEndCall()
		if nIndex == 3 then -- 战斗教学的		
			if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_Battle") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeActionEndCall))
	
	return CCSequence:create(arrAct)
end

function hidePlayerSkillIcon()
    if not TbBattleWnd.bShow then
        return
    end
    TbBattleWnd.bShow = nil
    --TbBattleWnd.tbWidgetSkillIcon[1]:runAction(CCRotateTo:create(0.3, -720))
    TbBattleWnd.tbWidgetSkillIcon[2]:stopAllActions()
    TbBattleWnd.tbWidgetSkillIcon[3]:stopAllActions()
    TbBattleWnd.tbWidgetSkillIcon[4]:stopAllActions()
    TbBattleWnd.tbWidgetSkillIcon[2]:runAction(spawnIn(0.4))
    TbBattleWnd.tbWidgetSkillIcon[3]:runAction(spawnIn(0.4))
    TbBattleWnd.tbWidgetSkillIcon[4]:runAction(spawnIn(0.4))
end

local function setFighterSkillIcon(nPos)
    local tbSkillData = TbBattleReport.tbSkillData[nPos]
	if not tbSkillData then return end
    for nSkillIndex = 2, 4 do
        local Button_Skill = TbBattleWnd.tbWidgetSkillIcon[nSkillIndex]
        Button_Skill:setVisible(true)
        local Panel_SkillIcon = tolua.cast(Button_Skill:getChildByName("Panel_SkillIcon"), "Layout")
        Panel_SkillIcon:setTouchEnabled(false)
		Panel_SkillIcon:setClippingEnabled(true)
		Panel_SkillIcon:setRadius(39)
		local Image_SkillIcon = tolua.cast(Panel_SkillIcon:getChildByName("Image_SkillIcon"), "ImageView")
        Image_SkillIcon:loadTexture(getIconImg(tbSkillData[nSkillIndex].Icon))
    end
end

function showPlayerSkillIcon()
    local nCurrentAttackPos = TbBattleReport.nCurrentAttackPos
	
	if not TbBattleReport.tbGameFighters_OnWnd then 
		SendError("客户端战斗调试======TbBattleReport.tbGameFighters_OnWnd 为空 showPlayerSkillIcon")
		return 
	end
	
    local GameFighter_Attacker = TbBattleReport.tbGameFighters_OnWnd[nCurrentAttackPos]
    if GameFighter_Attacker then
        GameFighter_Attacker:setAttackSkillIconSpine()
	else
		SendError("客户端战斗调试=======TbBattleReport.tbGameFighters_OnWnd[nCurrentAttackPos] 为空 showPlayerSkillIcon")
		return 
    end
	
    if TbBattleWnd.bShow or TbBattleReport.IsAutoFight then
        return
    end

    setFighterSkillIcon(nCurrentAttackPos)

    local bAutoUseSkill = true
    for i = 2, 4 do
		local bCanUse, nNeedEnergy = GameFighter_Attacker:checkUseSkill(i)
        local Button_Skill = TbBattleWnd.tbWidgetSkillIcon[i]
		Button_Skill:removeAllNodes()
		local Image_NeedEnergy = tolua.cast(Button_Skill:getChildByName("Image_NeedEnergy"), "ImageView")
		local Label_NeedEnergy = tolua.cast(Image_NeedEnergy:getChildByName("Label_NeedEnergy"), "Label")
        Label_NeedEnergy:setText(tostring(nNeedEnergy))
        if bCanUse then
        	local armature,userAnimation = g_CreateCoCosAnimation("IconEffectCircle", nil, 6)
			armature:setScale(1.5)
			Button_Skill:addNode(armature, 10)
			userAnimation:playWithIndex(0)

            Label_NeedEnergy:setColor(ccc3(0,255,0))
            bAutoUseSkill = nil
			
			local Panel_SkillIcon = tolua.cast(Button_Skill:getChildByName("Panel_SkillIcon"), "Layout")
            local Image_SkillIcon = tolua.cast(Panel_SkillIcon:getChildByName("Image_SkillIcon"),"ImageView")
            g_setImgShader(Image_SkillIcon, pszNormalFragSource)
        else
            Label_NeedEnergy:setColor(ccc3(255,0,0))
			
			local Panel_SkillIcon = tolua.cast(Button_Skill:getChildByName("Panel_SkillIcon"), "Layout")
            local Image_SkillIcon = tolua.cast(Panel_SkillIcon:getChildByName("Image_SkillIcon"),"ImageView")
            g_setImgShader(Image_SkillIcon, pszGreyFragSource)
        end
    end

	TbBattleWnd.bShow = true
	TbBattleWnd.tbWidgetSkillIcon[2]:stopAllActions()
	TbBattleWnd.tbWidgetSkillIcon[3]:stopAllActions()
	TbBattleWnd.tbWidgetSkillIcon[4]:stopAllActions()
	TbBattleWnd.tbWidgetSkillIcon[2]:runAction(spawnOut(0.4, TbBattleWnd.tbWidgetSkillPos[2], 3))
	TbBattleWnd.tbWidgetSkillIcon[3]:runAction(spawnOut(0.35, TbBattleWnd.tbWidgetSkillPos[3], 2))
	TbBattleWnd.tbWidgetSkillIcon[4]:runAction(spawnOut(0.3, TbBattleWnd.tbWidgetSkillPos[4], 1))

end

local function setFighterImageIcon(nIconIndex, nPos, nEumnBattleSideWnd)
    local GameObj_Fighter_OnWnd = TbBattleReport.tbGameFighters_OnWnd[nPos]
    if not GameObj_Fighter_OnWnd then return end
    GameObj_Fighter_OnWnd:setLoadingBarSp(true)

    local tbFightersIamgeIconList_OnSide = TbBattleWnd.tbFightersIamgeIconList[nEumnBattleSideWnd]
    if tbFightersIamgeIconList_OnSide then
        local Image_Fighter = tbFightersIamgeIconList_OnSide[nIconIndex]
        if Image_Fighter then
            Image_Fighter:setVisible(true)
            Image_Fighter:setScale(0.8)
			Image_Fighter:setOpacity(255)
            Image_Fighter:setColor(ccc3(255,255,255))
			local tbPosX = tbFightersImageIconPosition[nEumnBattleSideWnd].tbPosX
            Image_Fighter:setPositionX(tbPosX[nIconIndex])
			
            local Image_FighterIcon = tolua.cast(Image_Fighter:getChildByName("Image_FighterIcon"), "ImageView")
            Image_FighterIcon:loadTexture(getIconImg(GameObj_Fighter_OnWnd.tbFighterBase.SpineAnimation))

            local Image_Cursor = Image_Fighter:getChildByName("Image_Cursor")
            Image_Cursor:setVisible(false)
        end
    end
end

function updateFighterManaBar(nPos)
    local nFighterIndex, nEumnBattleSideWnd = getCurrentUseSkillFighterIndex(nPos)
    if not nFighterIndex or not nEumnBattleSideWnd then
        return
    end

    local GameFighter_Attacker = TbBattleReport.tbGameFighters_OnWnd[nPos]
	if not GameFighter_Attacker then return end 
    GameFighter_Attacker:setLoadingBarSp(true)
end

local function fadeInImageFighter(Image_Fighter, funcCallBack)
    Image_Fighter:setOpacity(0)
    local arrAct = CCArray:create()
    local fadein = CCFadeIn:create(1.2*g_TimeSpeed)
	arrAct:addObject(fadein)
    if funcCallBack then
		arrAct:addObject(CCCallFuncN:create(funcCallBack))
	end
	local action = CCSequence:create(arrAct)

    Image_Fighter:runAction(action)
end

--初始化队伍头像列表
function initFighterImageIconList(nEumnBattleSideWnd)
	TbBattleReport.tbFightersPosListByIndex = TbBattleReport.tbFightersPosListByIndex or {}
	local tbFighterSequenceList = g_BattleMgr:getFighterSequenceList()
	local tbFighterPosList = {}
	for nFighterSequenceIndex = 1, #tbFighterSequenceList do
		local nPos = tbFighterSequenceList[nFighterSequenceIndex].atkno*10 + tbFighterSequenceList[nFighterSequenceIndex].apos
		local GameFighter_Attacker = TbBattleReport.tbGameFighters_OnWnd[nPos]
		if not GameFighter_Attacker then
		end
		if tbFighterSequenceList[nFighterSequenceIndex].atkno == nEumnBattleSideWnd - 1 and GameFighter_Attacker then
			table.insert(tbFighterPosList, 1, nPos)
		end

		if nPos <= 10 and GameFighter_Attacker then
			GameFighter_Attacker.cardid = tbFighterSequenceList[nFighterSequenceIndex].cardid
		end
	end
	
	tbFighterPosList.nCursorPos = #tbFighterPosList
	TbBattleReport.tbFightersPosListByIndex[nEumnBattleSideWnd] = tbFighterPosList

	local tbFighterPosList = TbBattleReport.tbFightersPosListByIndex[nEumnBattleSideWnd]
	local tbFightersIamgeIconList_OnSide = TbBattleWnd.tbFightersIamgeIconList[nEumnBattleSideWnd]
	if not tbFightersIamgeIconList_OnSide then return end

	local nFighterPosListCount = #tbFighterPosList
	if nFighterPosListCount == 0 then 
		return
	end
	
	for nIconIndex = 1, nFighterPosListCount do
		local nPos = tbFighterPosList[nIconIndex]
		setFighterImageIcon(nIconIndex, nPos, nEumnBattleSideWnd)
		fadeInImageFighter(tbFightersIamgeIconList_OnSide[nIconIndex])
	end

	for nIconIndex = nFighterPosListCount + 1, g_nMaxFigthersIcon do
		tbFightersIamgeIconList_OnSide[nIconIndex]:setVisible(false)
	end

	tbFightersIamgeIconList_OnSide.Image_Fighter_Cursor:setVisible(true)
	tbFightersIamgeIconList_OnSide.Image_Fighter_Cursor:removeFromParentAndCleanup(true)
	local Image_Fighter = tbFightersIamgeIconList_OnSide[nFighterPosListCount]
	if Image_Fighter then
		Image_Cursor_Last = nil
		setFighterImageIconCursor(tbFightersIamgeIconList_OnSide.Image_Fighter_Cursor, Image_Fighter)
	end

	fadeInImageFighter(tbFightersIamgeIconList_OnSide.Image_Fighter_Cursor)

	local tbFightersPosListByIndex = TbBattleReport.tbFightersPosListByIndex[nEumnBattleSideWnd]
	tbFightersPosListByIndex.nCursorPos = nFighterPosListCount

	if nEumnBattleSideWnd == 1 then
		local nPos = tbFighterPosList[1]
		setFighterSkillIcon(nPos)
	end
end


local function showPlayerIconDead(widget)
    local actionToBlack = CCTintTo:create(0.24*g_TimeSpeed,100,100,100)     -- 参数：--（0,0,0）为颜色变黑---0.5为时间
	local actionFade = CCFadeTo:create(0.48*g_TimeSpeed, 128)            --渐隐，参数：时间
    local arrAct = CCArray:create()

	arrAct:addObject(actionToBlack)
    arrAct:addObject(actionFade)

    local action = CCSequence:create(arrAct)
	widget:runAction(action)
end

local function showPlayerIconRelive(widget)
    local actionToBlack = CCTintTo:create(0.24*g_TimeSpeed, 255,255,255)     -- 参数：--（0,0,0）为颜色变黑---0.5为时间
	local actionFade = CCFadeTo:create(0.48*g_TimeSpeed, 255)            --渐隐，参数：时间
    local arrAct = CCArray:create()
	arrAct:addObject(actionToBlack)
    arrAct:addObject(actionFade)

    local action = CCSequence:create(arrAct)
	widget:runAction(action)
end


--nType 1 死亡 2 替换
function updateSkillPlayerList(nType, nPos)
    local nFighterIndex, nEumnBattleSideWnd = getCurrentUseSkillFighterIndex(nPos)
    if not nFighterIndex or nEumnBattleSideWnd == eumn_battle_side_wnd.defence then return end--warning

    local tbBattlePlayerIcon = TbBattleWnd.tbFightersIamgeIconList[nEumnBattleSideWnd]
    local widget = tbBattlePlayerIcon[nFighterIndex]
    if nType == 1 then
       showPlayerIconDead(widget)
    elseif nType == 2 then
       setFighterImageIcon(nFighterIndex, nPos, nEumnBattleSideWnd)
       showPlayerIconRelive(widget)
    end
end

function autoUseSkill(nEumnBattleSide, nPosInBattleMgr)
    if TbBattleReport.bEscape then
        EscapeClearAllResouce(false, false)
        return
    end

    local nCurrentAttackPos = nEumnBattleSide * 10 + nPosInBattleMgr
    local GameFighter = TbBattleReport.tbGameFighters_OnWnd[nCurrentAttackPos]
    if not GameFighter then return end 
	if GameFighter then 
		GameFighter:setAttackSkillIconSpine()
	end

    local nAutoSkillIndex = GameFighter.nAutoSkillIndex
    if not nAutoSkillIndex  then
        nAutoSkillIndex = 1
    end
    nAutoSkillIndex = nAutoSkillIndex + 1
    local nCurrentAutoSkillIndex = nAutoSkillIndex
    if nCurrentAutoSkillIndex > 4 then
        nCurrentAutoSkillIndex = 2
    end
	local bIsEnergyEnough, nNeedEnergy = GameFighter:checkUseSkill(nCurrentAutoSkillIndex)
	cclog("==释放技能者=="..GameFighter:getName().."==释放技能nSkillIndex=="..nAutoSkillIndex.."==释放技能nCurrentSkillIndex=="..nCurrentAutoSkillIndex.."==bIsEnergyEnough=="..tostring(bIsEnergyEnough).."==nNeedEnergy=="..nNeedEnergy)
    if bIsEnergyEnough == true then
        g_BattleMgr:setFighterUseSkillIndex(nEumnBattleSide, nPosInBattleMgr, nCurrentAutoSkillIndex)
        GameFighter.nAutoSkillIndex = nCurrentAutoSkillIndex
        return
    end
    g_BattleMgr:setFighterUseSkillIndex(nEumnBattleSide, nPosInBattleMgr, 1)
end

function Game_Battle:showButtonAniAutoFight()
	if TbBattleReport.IsAutoFight then
		if not self.Button_AutoFight:getNodeByTag(1) then
			local armature,userAnimation = g_CreateCoCosAnimation("IconEffectCircleA", nil, 6)
			armature:setScale(1.6)
			armature:setPositionY(-2)
			armature:setTag(1)
			self.Button_AutoFight:addNode(armature)
			userAnimation:playWithIndex(0)
		end
	else
		self.Button_AutoFight:removeAllNodes()
	end
end

function Game_Battle:showButtonAniAccelerate()
	if TbBattleReport.nAccelerateSpeed >= 2 then
		if not self.Button_Accelerate:getNodeByTag(1) then
			local armature,userAnimation = g_CreateCoCosAnimation("IconEffectCircleA", nil, 6)
			armature:setScale(1.6)
			armature:setPositionY(-2)
			armature:setTag(1)
			self.Button_Accelerate:addNode(armature)
			userAnimation:playWithIndex(0)
		end
	else
		self.Button_Accelerate:removeAllNodes()
	end
end

function Game_Battle:showButtonAni()
	self:showButtonAniAutoFight()
	self:showButtonAniAccelerate()
end

function Game_Battle:checkAccelerationAnimation()
    if TbBattleReport.IsSettingOpening then
        if TbBattleReport.IsAutoFight then
            if TbBattleReport.bResetBuZhen then
                onClickConfirmBuZhen()
            end
            TbBattleReport.IsSettingOpening = nil
        end
		
		local nBattleType = TbBattleReport.tbBattleScenceInfo.battle_type
		if g_PlayerGuide:checkIsInGuide() then
			if g_PlayerGuide.nCurrentGuideID <= 2 and g_PlayerGuide.nCurrentGuideIndex <= 15 then
				TbBattleReport.IsAutoFight = false
				CCUserDefault:sharedUserDefault():setBoolForKey("IsAutoFight", TbBattleReport.IsAutoFight) --重新初始化
				TbBattleReport.nAccelerateSpeed = 1
				CCUserDefault:sharedUserDefault():setIntegerForKey("nAccelerateSpeed", TbBattleReport.nAccelerateSpeed) 
			elseif g_PlayerGuide:checkIsInGuide() <= 14 then
				TbBattleReport.IsAutoFight = true
				CCUserDefault:sharedUserDefault():setBoolForKey("IsAutoFight", TbBattleReport.IsAutoFight) --重新初始化
				TbBattleReport.nAccelerateSpeed = 2
				CCUserDefault:sharedUserDefault():setIntegerForKey("nAccelerateSpeed", TbBattleReport.nAccelerateSpeed)
			else
				if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
					or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
					or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
					or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
				then --竞技场
					TbBattleReport.IsAutoFight = true
				else
					TbBattleReport.IsAutoFight = CCUserDefault:sharedUserDefault():getBoolForKey("IsAutoFight", false) --重新初始化
				end
				TbBattleReport.nAccelerateSpeed = CCUserDefault:sharedUserDefault():getIntegerForKey("nAccelerateSpeed", 1) --重新初始化
			end
		else
			if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
				or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
				or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
				or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
			then --竞技场
				TbBattleReport.IsAutoFight = true
			else
				TbBattleReport.IsAutoFight = CCUserDefault:sharedUserDefault():getBoolForKey("IsAutoFight", false) --重新初始化
			end
			TbBattleReport.nAccelerateSpeed = CCUserDefault:sharedUserDefault():getIntegerForKey("nAccelerateSpeed", 1) --重新初始化
		end

        TbBattleReport.nAccelerateSpeed = CCUserDefault:sharedUserDefault():getIntegerForKey("nAccelerateSpeed", 1)
		
		--战斗加速和自动战斗转圈动画
        self:showButtonAni()
    end
end

function  Game_Battle:resetBattleWndUiData()
    TbBattleWnd.Image_ItemsIcon:setPositionXY(0,0)
    TbBattleWnd.Label_ItemNum:setText("")
	TbBattleWnd.BitmapLabel_RoundIndex:setText("01/30")

	TbBattleReport.Mesh = TbBattleWnd.Mesh
	TbBattleReport.Mesh:removeAllChildrenWithCleanup(true)
	TbBattleWnd.Scene:setPositionXY(640, -5)

    --暂时先隐藏
    for nIconIndex = 1, g_nMaxFigthersIcon do
        local tbWidget = TbBattleWnd.tbFightersIamgeIconList[eumn_battle_side_wnd.attack]
		if tbWidget then
			if tbWidget[nIconIndex] and tbWidget[nIconIndex]:isExsit() then
				tbWidget[nIconIndex]:setVisible(false)
			end
			if g_OnExitGame then
				if tbWidget.Image_Fighter_Cursor and tbWidget.Image_Fighter_Cursor:isExsit() then
					tbWidget.Image_Fighter_Cursor:setVisible(false)
				end
			else
				if tbWidget.Image_Fighter_Cursor then
					tbWidget.Image_Fighter_Cursor:setVisible(false)
				end
			end
			
		end
    end

    hidePlayerSkillIcon()

    local widget = TbBattleWnd.Image_BuZhen
    widget:setVisible(false)

    local Panel_BackGround = self.rootWidget:getChildByName("Panel_BackGround")
    Panel_BackGround:setVisible(false)

    local Image_CoverBottom = self.rootWidget:getChildByName("Image_CoverBottom")
    Image_CoverBottom:setCascadeOpacityEnabled(true)
    Image_CoverBottom:setOpacity(255)

    local Image_CoverTop = self.rootWidget:getChildByName("Image_CoverTop")
    Image_CoverTop:setCascadeOpacityEnabled(true)
    Image_CoverTop:setOpacity(255)

	local BitmapLabel_Accelerate = tolua.cast(self.Button_Accelerate:getChildByName("BitmapLabel_Accelerate"),"LabelBMFont")
	BitmapLabel_Accelerate:setText("×"..TbBattleReport.nAccelerateSpeed)
	
	--战斗加速和自动战斗转圈动画
	self:showButtonAni()
end

function Game_Battle:setBuZhenData(Button_Pos, index)
	if(Button_Pos and index)then
        local nPos = tbClientToServerPosConvert[index]
        local tbCheckPos = g_Hero:getCurZhenFaIndex(nPos)
		local imageNormal = getBattleImg("Btn_BattlePos"..index)
        local imageClick = getBattleImg("Btn_BattlePos"..index.."_Check")
		local imageDisabled = getBattleImg("Btn_BattlePos"..index.."_Disabled")
        if tbCheckPos then
            Button_Pos:loadTextures(imageNormal,imageClick,imageDisabled)
            Button_Pos:setTouchEnabled(true)

            local tbCardBattle = g_Hero:getBattleCardByBuZhenPos(nPos)
		    if(tbCardBattle)then
                Button_Pos:setTag(nPos)
	            Button_Pos:addTouchEventListener(onClickResetBuZhen)

                local CSV_CardBase = tbCardBattle:getCsvBase()
                local GameFighter_Attacker = TbBattleReport.tbGameFighters_OnWnd[nPos]
			    if(CSV_CardBase and GameFighter_Attacker)then
                    local Image_Card = GameFighter_Attacker.Image_Card
                    if Image_Card then
						local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1)
                        Image_Card:removeAllNodes()
						Image_Card:loadTexture(getUIImg("Blank"))
						Image_Card:setPositionXY(CSV_CardBase.Pos_X, CSV_CardBase.Pos_Y)
                        Image_Card:addNode(CCNode_Skeleton )
                        g_runSpineAnimation(CCNode_Skeleton, "idle", true)
                        GameFighter_Attacker.CCNode_Skeleton = CCNode_Skeleton
                    end

                    local tbCardPos = g_tbCardPos[nPos]
                    GameFighter_Attacker:setPosition(tbCardPos.tbPos)
                    GameFighter_Attacker:setScale(tbCardPos.Scale)
                    GameFighter_Attacker:setZOrder(tbCardPos.nBattleLayer)
                    GameFighter_Attacker.Layout_CardClickArea:setTag(nPos)
                end
		    end
        else
            Button_Pos:loadTextures(imageDisabled,imageClick,imageDisabled)
            Button_Pos:setTouchEnabled(false)

            if( TbBattleReport.tbGameFighters_OnWnd[nPos])then
                local ImageView_Fighter = TbBattleReport.tbGameFighters_OnWnd[nPos].Image_Card
                if ImageView_Fighter then
                    ImageView_Fighter:removeAllNodes()
                end
            end
        end
	end
end

function Game_Battle:refreshSelectZhenFa()
    local widget = TbBattleReport.TbBattleWnd.Image_BuZhen
    --布阵的格子
    for i=1, 9 do
        local Button_Pos = tolua.cast(widget:getChildByName("Button_BattlePos"..i), "Button")
		self:setBuZhenData(Button_Pos, i)
    end
end

local function runMoveAction(widget, nBeginPos, nOffset, funcCallBack, nActionTime)
    widget:setPositionY(nBeginPos - nOffset )
    nActionTime = nActionTime or 0.4
    local actionMove = CCMoveBy:create(nActionTime*g_TimeSpeed, ccp(0,nOffset))
    local arrAct = CCArray:create()
	arrAct:addObject(actionMove)

	if(funcCallBack)then
		arrAct:addObject(CCCallFuncN:create(funcCallBack))
	end
    local action = CCSequence:create(arrAct)
    widget:runAction(action)
end

function Game_Battle:hideUICallBack()
    local tbGameFighters_OnWnd = TbBattleReport.tbGameFighters_OnWnd
	for nPos, GameFighter in pairs(tbGameFighters_OnWnd) do
		if GameFighter and GameFighter ~= {} then
			GameFighter:removeFromParentAndCleanup(true)
		end
		if TbBattleReport.tbGameFighters_OnWnd[nPos] and TbBattleReport.tbGameFighters_OnWnd[nPos] ~= {} then
			TbBattleReport.tbGameFighters_OnWnd[nPos]:release()
			TbBattleReport.tbGameFighters_OnWnd[nPos] = nil
		end
	end

    local function reStartBattle()
       local function initBattleEndCall(tbBattleScenceInfo)
            proLoadBattleRersouce(TbBattleReport.tbBattleScenceInfo, TbBattleReport.tbServerMsg)
	    end

        g_BattleMgr:resetBattle(initBattleEndCall)
    end
    g_Timer:pushTimer(0.5, reStartBattle)
end

function Game_Battle:hideUIAnimation(func)
    local function showUI()
		local Panel_BackGround = self.rootWidget:getChildByName("Panel_BackGround")
		local Image_BottomLeftPNL = Panel_BackGround:getChildByName("Image_BottomLeftPNL")
		local Image_BottomRightPNL = Panel_BackGround:getChildByName("Image_BottomRightPNL")
		local Image_TopRightPNL = Panel_BackGround:getChildByName("Image_TopRightPNL")
		local Image_TopLeftPNL = Panel_BackGround:getChildByName("Image_TopLeftPNL")
		
        runMoveAction(Image_BottomLeftPNL,-160,-160)
        runMoveAction(Image_BottomRightPNL,-160,-160)
        runMoveAction(Image_TopRightPNL,840,120)
        runMoveAction(Image_TopLeftPNL,840,120, func)
    end


   if TbBattleWnd.bShow then
      hidePlayerSkillIcon()
      g_PushLoopTimer(0.4, showUI, self.rootWidget)
   else
      showUI()
   end
end

function Game_Battle:showUIAnimation(func)
    local function showUI()
		local Panel_BackGround = self.rootWidget:getChildByName("Panel_BackGround")
		local Image_BottomLeftPNL = Panel_BackGround:getChildByName("Image_BottomLeftPNL")
		local Image_BottomRightPNL = Panel_BackGround:getChildByName("Image_BottomRightPNL")
		local Image_TopRightPNL = Panel_BackGround:getChildByName("Image_TopRightPNL")
		local Image_TopLeftPNL = Panel_BackGround:getChildByName("Image_TopLeftPNL")
		
        runMoveAction(Image_BottomLeftPNL,0,80)
        runMoveAction(Image_BottomRightPNL,0,160)
        runMoveAction(Image_TopRightPNL,685,-120)
        runMoveAction(Image_TopLeftPNL,720,-120, func)

        Panel_BackGround:setVisible(true)
    end

    local Image_CoverBottom = self.rootWidget:getChildByName("Image_CoverBottom")
    Image_CoverBottom:setVisible(true)
    fadeOut(Image_CoverBottom)

    local Image_CoverTop = self.rootWidget:getChildByName("Image_CoverTop")
    Image_CoverTop:setVisible(true)
    fadeOut(Image_CoverTop, showUI)
end

function Game_Battle:showBattleUIWithoutTalkMoveSkillIcon()
	local Panel_BackGround = self.rootWidget:getChildByName("Panel_BackGround")
	local Image_BottomRightPNL = Panel_BackGround:getChildByName("Image_BottomRightPNL")
    runMoveAction(Image_BottomRightPNL,0,160)
end

--[[3.2非剧情模式的战斗流程
A.跟原来的流程变化比较大，非剧情模式不显示水墨边
1，一显示出战斗地图，下面的战斗UI移动到屏幕内（跟下面并行）。
左上角的头像。
右上角的土地名称。
左下角的按钮。
右下角的技能按钮暂时先不移动。
2，同时双方人物同时出场。
3，出场完后所有人同时播放celebrate动画。
4，所有人celebrate动画播放完毕后，进入布阵状态。
布阵的砖块按钮淡出。
同时右下角的按钮移动到屏幕内。
5，点击开战按钮后，播放开战BattleStart动画，进入战斗流程。（原来是点击开战的时候播放celebrate动画的，感觉体验一般，所以去掉了）]]
function Game_Battle:showUIWithoutTalk()
	local Panel_BackGround = self.rootWidget:getChildByName("Panel_BackGround")
	local Image_BottomLeftPNL = Panel_BackGround:getChildByName("Image_BottomLeftPNL")
	local Image_BottomRightPNL = Panel_BackGround:getChildByName("Image_BottomRightPNL")
	local Image_TopRightPNL = Panel_BackGround:getChildByName("Image_TopRightPNL")
	local Image_TopLeftPNL = Panel_BackGround:getChildByName("Image_TopLeftPNL")
	
    local Image_CoverBottom = self.rootWidget:getChildByName("Image_CoverBottom")
    Image_CoverBottom:setVisible(false)
    local Image_CoverTop = self.rootWidget:getChildByName("Image_CoverTop")
    Image_CoverTop:setVisible(false)

    runMoveAction(Image_BottomLeftPNL,0,80)
   -- runMoveAction(Image_BottomRightPNL,0,160)
    runMoveAction(Image_TopRightPNL,685,-120)
    runMoveAction(Image_TopLeftPNL,720,-120)

    Image_BottomRightPNL:setPositionY(-160 )
    Panel_BackGround:setVisible(true)
end

function Game_Battle:showBattleUIConverOutWithTalk(func)
    local function showUIIn()
        self:showUIAnimation(func)
    end

    local Image_CoverBottom = self.rootWidget:getChildByName("Image_CoverBottom")
    Image_CoverBottom:setVisible(true)
    runMoveAction(Image_CoverBottom,-80,-80)

    local Image_CoverTop = self.rootWidget:getChildByName("Image_CoverTop")
    Image_CoverTop:setVisible(true)
    runMoveAction(Image_CoverTop,800,80, showUIIn)
end

function Game_Battle:showUICoverInWithTalk()
    local Image_CoverBottom = self.rootWidget:getChildByName("Image_CoverBottom")
    Image_CoverBottom:setVisible(true)
    runMoveAction(Image_CoverBottom,0,80)

    local Image_CoverTop = self.rootWidget:getChildByName("Image_CoverTop")
    Image_CoverTop:setVisible(true)
    runMoveAction(Image_CoverTop,720,-80)
    TbBattleReport.bHaveTalk = true
end

function Game_Battle:openWnd(tbBattleScenceInfo)
    if not tbBattleScenceInfo then return end
	
	--重新初始化化战斗加速和其转圈动画
	self:checkAccelerationAnimation()
	self:resetBattleWndUiData(tbBattleScenceInfo)
	TbBattleReport.TbBattleWnd = TbBattleWnd

    TbBattleWnd.Label_EctypeName:setText(g_BattleData:getEctypeName())

	local GameObj_BattleProcess = CBattleProcess.new()
	TbBattleReport.GameObj_BattleProcess = GameObj_BattleProcess
    GameObj_BattleProcess:loadBattleBGMusic()

	local nTalkID = 0
	local nAlpha = 0
	if g_BattleTeachSystem and g_BattleTeachSystem:IsTeaching() then
		nTalkID = 1110002
		nAlpha = 100
	else
		nTalkID = g_Hero:getDialogTalkID()
		nAlpha = 0
	end
	
	if nTalkID and nTalkID > 0 then
		local CSV_Dialogue = g_DataMgr:getDialogueCsv(nTalkID)
		if CSV_Dialogue and g_BattleMgr:getIsFirstInThisBattle() then
			if CSV_Dialogue[1].DialogueEvent == 1 then
				local function funcInitBornEndCall()
					local function funDialogueEndCall() 
						GameObj_BattleProcess:startBattleProcess()
					end 
					g_DialogueData:showDialogueSequence(nTalkID, g_DialogueData.statusType.begin, funDialogueEndCall, nAlpha)
				end
				--左边人物进场完后，如果有对话则进行对话
				local nBattleType = g_BattleData:getEctypeType()
				if nBattleType == macro_pb.Battle_Atk_Type_normal_pass then
					local nMapEctypeSubCsvId = g_BattleData:getEctypeID()
					local CSV_MapEctypeSub = g_DataMgr:getMapEctypeSubCsv(nMapEctypeSubCsvId)
					if CSV_MapEctypeSub.HelperID > 0 then
						self:initGameAttackerBornAction(funcInitBornEndCall, true, CSV_MapEctypeSub.HelperBornAction)
					else
						self:initGameAttackerBornAction(funcInitBornEndCall)
					end
				else
					self:initGameAttackerBornAction(funcInitBornEndCall)
				end
			else
				--左边人物进场完后，如果有对话则进行对话
				local nBattleType = g_BattleData:getEctypeType()
				if nBattleType == macro_pb.Battle_Atk_Type_normal_pass then
					local nMapEctypeSubCsvId = g_BattleData:getEctypeID()
					local CSV_MapEctypeSub = g_DataMgr:getMapEctypeSubCsv(nMapEctypeSubCsvId)
					if CSV_MapEctypeSub.HelperID > 0 then
						self:initGameAttackerBornAction(nil, true, CSV_MapEctypeSub.HelperBornAction)
						GameObj_BattleProcess:startBattleProcess()
					else
						self:initGameAttackerBornAction()
						GameObj_BattleProcess:startBattleProcess()
					end
				else
					self:initGameAttackerBornAction()
					GameObj_BattleProcess:startBattleProcess()
				end
			end
		else
			self:initGameAttackerBornAction()
			GameObj_BattleProcess:startBattleProcess()
		end
		self:showUICoverInWithTalk()
	else
		self:initGameAttackerBornAction()
		GameObj_BattleProcess:startBattleProcess()
		self:showUICoverInWithTalk()
	end
	cclog("===============Game_Battle=================打开完窗口了")
end

function Game_Battle:closeWnd()
    if self ~= nil then
        g_RemoveAllBattlePlistResource()
        self:destroyWnd()
		if TbBattleReport then
		
			if TbBattleReport.Mesh then
				TbBattleReport.Mesh:removeAllChildrenWithCleanup(true)
				TbBattleReport.Mesh:removeAllNodes()
			end
			
			 for k,v in pairs(TbBattleReport.tbGameFighters_OnWnd) do
				v:release()
			end
			TbBattleReport = nil
		end
		self.rootWidget:removeAllNodes()
    end
	
	local wndInstance = g_WndMgr:getWnd("Game_EctypeList")
	if wndInstance then
		wndInstance.Image_Background:loadTexture(getBackgroundJpgImg("Bamboo1"))
	end

    if TbBattleWnd.ArmatureFoot then TbBattleWnd.ArmatureFoot:release() TbBattleWnd.ArmatureFoot = nil end
    if TbBattleWnd.ArmatureArrow then TbBattleWnd.ArmatureArrow:release() TbBattleWnd.ArmatureArrow = nil  end
end

--清理数据
function Game_Battle:destroyWnd()
end

--刷新控件位置
--[[按钮的初始状态
Image_ItemsIcon的坐标设置为（0,0）
Label_ItemNum的透明度设置为0，坐标设置为（0,0）。
当有第一个掉落的时候做动态效果
Image_ItemsIcon移动到（0,10）
Label_ItemNum移动到（0，-20），同时透明度渐变到255
]]
function Game_Battle:refreshDropInfo(tbDropInfo)
    local bShowMoveAction = nil
    if tbDropInfo then
        for i=1, #tbDropInfo do
            local nItemType = tbDropInfo[i].drop_item_type
            if nItemType < macro_pb.ITEM_TYPE_MASTER_EXP then
                local nItemNum = tbDropInfo[i].drop_item_num
				local nCsvID = tbDropInfo[i].drop_item_config_id
				local nStarLev = tbDropInfo[i].drop_item_star_lv

                local tbReward = {
					DropItemType = tbDropInfo[i].drop_item_type,
					DropItemID = tbDropInfo[i].drop_item_config_id,
					DropItemStarLevel = tbDropInfo[i].drop_item_star_lv,
					DropItemNum = tbDropInfo[i].drop_item_num,
					DropItemEvoluteLevel = 1,
					}

                if not TbBattleReport.tbDropInfo then
                   TbBattleReport.tbDropInfo = {}
                   bShowMoveAction = true
                end
                table.insert(TbBattleReport.tbDropInfo, tbReward)
            end
        end
    end

    if TbBattleReport.tbDropInfo then
        if bShowMoveAction then
            runMoveAction(TbBattleWnd.Image_ItemsIcon,7,7)
            runMoveAction(TbBattleWnd.Label_ItemNum,-30,-30)          
        end

        TbBattleWnd.Label_ItemNum:setText(tostring(#TbBattleReport.tbDropInfo))
    else
        TbBattleWnd.Image_ItemsIcon:setPositionXY(0,0)
        TbBattleWnd.Label_ItemNum:setPositionXY(0,0)
        TbBattleWnd.Label_ItemNum:setText("")
    end
end

