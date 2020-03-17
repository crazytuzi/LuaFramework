--[[
玩家常量
lizhuangzhuang
2014年8月18日14:01:44
]]
_G.classlist['PlayerConsts'] = 'PlayerConsts'
_G.PlayerConsts = {};
PlayerConsts.objName = 'PlayerConsts'
--性别
PlayerConsts.Sex_man = 1;--男
PlayerConsts.Sex_woman = 0;--女

--复活类型
_G.REVIVE_TYPE = {
	IN_SITU_REVIVE = 1, --原地复活
	BACK_TO_REVIVE = 2, --回城复活
}

--角色状态
_G.PlayerState = {
    UNIT_BIT_MOVING = 1, 	                --移动中
    UNIT_BIT_DEAD = 2,			            --死亡
    UNIT_BIT_CASTING = 3,		            --施法中
    UNIT_BIT_GOD = 4,			            --无敌中
    UNIT_BIT_STEALTH = 5,		            --隐身中
    UNIT_BIT_STIFF = 6,			            --硬直中
    UNIT_BIT_POISONED = 7,		            --中毒中
    UNIT_BIT_HOLD = 8,			            --定身中
    UNIT_BIT_PALSY = 9,			            --麻痹中
    UNIT_BIT_STUN = 10,			            --眩晕中
    UNIT_BIT_SILENCE = 11,                  --沉默中
    UNIT_BIT_INCOMBAT = 12,		            --战斗中
    UNIT_BIT_INBACK = 13,	                --归位中
    UNTT_BIT_CHANGE_SCENE = 14,             --切换场景中
    UNIT_BIT_FORBID_USERITEM = 15,          --禁用物品状态
    UNIT_BIT_FORBID_RIDE = 16,              --不可骑乘
    UNIT_BIT_FORBID_RECOVER_HP = 17,        --不可恢复生命
    UNIT_BIT_FORBID_RECOVER_MP = 18,        --不可恢复魔法
    UNIT_BIT_FORBID_RECOVER_SP = 19,        --不可恢复体力
    UNIT_BIT_CERTAINLY_CRIT = 20,           --必定暴击
    UNIT_BIT_CERTAINLY_HIT = 21,            --必定命中
    UNIT_BIT_IN_PK = 22,                    --PK状态
    UNIT_BIT_IN_SAFE_AREA = 23,             --安全区
    UNIT_BIT_WITH_FLAG = 24,                --旗帜
    UNIT_BIT_RAMPAGE = 25,                  --狂暴
    UNIT_BIT_MIDNIGHT = 26,                 --午夜PK状态
    UNIT_BIT_BIANSHEN = 30,                 --变身
    UNIT_BIT_AI_LOCKED = 31,                 --被怪物锁定
}

_G.ChanSkillState = {
    StateInit = 0,
    StateOne = 1,
    StateTwo = 2,
}


--获取职业名
function PlayerConsts:GetProfName(prof)
	if prof==enProfType.eProfType_Sickle then
		return StrConfig["commonProf1"];
	elseif prof==enProfType.eProfType_Sword then
		return StrConfig["commonProf2"];
    elseif prof==enProfType.eProfType_Human then
        return StrConfig["commonProf3"];
    elseif prof==enProfType.eProfType_Woman then
        return StrConfig["commonProf4"];
	end
	return StrConfig["commonNoLimit"];
end

--获取性别名
function PlayerConsts.GetSexName(sex)
	if sex==PlayerConsts.Sex_man then
		return StrConfig["commonSex1"];
	elseif sex==PlayerConsts.Sex_woman then
		return StrConfig["commonSex0"];
	end
	return StrConfig["commonNoLimit"];
end

function PlayerConsts:GetMaxLevel()
    return t_consts[40].val1
end

function PlayerConsts:GetManulLevel()
    return t_consts[43].val1
end

PlayerConsts.RemindAddPoint = 20

-- 不能传送的失败结果,对应FloatManager文字提示
-- 参见 1)MainPlayerController:IsSpecialState() 
--      2)MainPlayerController:IsCanTeleport()
PlayerConsts.CannotTeleportRemindDic = {
    [-2]   = StrConfig['map219'], -- 技能          技能施放中，无法传送
    [-3]   = StrConfig['map219'], -- 技能
    [-4]   = StrConfig['map219'], -- 技能
    [-6]   = StrConfig['map219'], -- 技能
    [-15]  = StrConfig['map219'], -- 技能
    [-16]  = StrConfig['map219'], -- 技能
    [-10]  = StrConfig['map222'], -- 传送          传送中，请稍后再试
    [-12]  = StrConfig['map222'], -- 传送 
    [-1]   = StrConfig['map218'], -- 死亡          死亡状态，无法传送
    [-5]   = StrConfig['map220'], -- 采集          采集中，无法传送
    [-9]   = StrConfig['map221'], -- 切换地图      切换地图中，无法传送
    [-11]  = StrConfig['map223'], -- 换线          换线中，请稍后再试
    [-14]  = StrConfig['map224'], -- 变身状态      变身状态，无法传送
    [-101] = StrConfig['map225'], -- 请求打坐中    打坐状态切换中，无法传送
    [-102] = StrConfig['map226'] -- 请求请求骑乘中 骑乘状态切换中，无法传送
}