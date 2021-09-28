--TargetHelper.lua
--/*-----------------------------------------------------------------
 --* Module:  TargetHelper.lua
 --* Author:  seezon
 --* Modified: 2014年4月9日
 --* Purpose: 任务目标工厂
 -------------------------------------------------------------------*/

require "system.task.target.TOwnMat"
require "system.task.target.TKillMonster"
require "system.task.target.TEquipStrength"
require "system.task.target.TEquipInherit"
require "system.task.target.TEquipDecompose"
require "system.task.target.TSkillLevelUp"
require "system.task.target.TWingPromote"
require "system.task.target.TDailySign"
require "system.task.target.TDoneDailyTask"
require "system.task.target.TJoinArena"
require "system.task.target.TJoinCopy"
require "system.task.target.TAddFriend"
require "system.task.target.TCreateTeam"
require "system.task.target.TGiveFlower"
require "system.task.target.TKillWorldBoss"
require "system.task.target.TLottery"
require "system.task.target.TUseIngot"
require "system.task.target.TUseBindIngot"
require "system.task.target.TUseMat"
require "system.task.target.TLevelUp"
require "system.task.target.TUpStarTask"
require "system.task.target.TGetActiveReWard"
require "system.task.target.TUseTile"
require "system.task.target.TGetMat"
require "system.task.target.TUseSkill"
require "system.task.target.TGiveItem"
require "system.task.target.TEquipBaptize"
require "system.task.target.TPubliseReward"
require "system.task.target.TAcceptReward"
require "system.task.target.TFinishReward"
require "system.task.target.TEnterCopy"
require "system.task.target.TAdore"
require "system.task.target.TUpmedal"
require "system.task.target.TBuyMysGood"
require "system.task.target.TBuyMysPos"
require "system.task.target.TBlessWeapon"
require "system.task.target.TJoinFac"
require "system.task.target.TKillOther"
require "system.task.target.TDart"
require "system.task.target.TKillDart"
require "system.task.target.TUpSkill"
require "system.task.target.TDrink"
require "system.task.target.TStone"
require "system.task.target.TYanhuo"
require "system.task.target.TPersonalEscort"
require "system.task.target.TSingleKillMonster"
require "system.task.target.TNPCUseGot"
require "system.task.target.TMonsterUseGot"
require "system.task.target.TChangeMode"
require "system.task.target.TEquipCompound"
require "system.task.target.TPickReward"
require "system.task.target.TEnterPreBook"

TargetHelper =
{
	["TOwnMat"]		= TOwnMat,
	["TKillMonster"]= TKillMonster,
	["TEquipStrength"]= TEquipStrength,
	["TEquipInherit"]= TEquipInherit,
	["TEquipDecompose"]= TEquipDecompose,
	["TSkillLevelUp"]= TSkillLevelUp,
	["TWingPromote"]= TWingPromote,
	["TDailySign"]= TDailySign,
	["TDoneDailyTask"]= TDoneDailyTask,
	["TJoinArena"]= TJoinArena,
	["TJoinCopy"]= TJoinCopy,
	["TAddFriend"]= TAddFriend,
	["TCreateTeam"]= TCreateTeam,
	["TGiveFlower"]= TGiveFlower,
	["TKillWorldBoss"]= TKillWorldBoss,
	["TLottery"]= TLottery,
	["TUseIngot"]= TUseIngot,
	["TUseBindIngot"]= TUseBindIngot,
	["TUseMat"]= TUseMat,
	["TLevelUp"]= TLevelUp,
	["TUpStarTask"]= TUpStarTask,
	["TGetActiveReWard"]= TGetActiveReWard,
	["TUseTile"]= TUseTile,
	["TGetMat"]= TGetMat,
	["TUseSkill"]= TUseSkill,
	["TGiveItem"]= TGiveItem,
	["TEquipBaptize"]= TEquipBaptize,
	["TPubliseReward"]= TPubliseReward,
	["TAcceptReward"]= TAcceptReward,
	["TFinishReward"]= TFinishReward,
	["TEnterCopy"]= TEnterCopy,
	["TAdore"]= TAdore,
	["TUpmedal"]= TUpmedal,
	["TBuyMysGood"]= TBuyMysGood,
	["TBuyMysPos"]= TBuyMysPos,
	["TBlessWeapon"]= TBlessWeapon,
	["TJoinFac"]= TJoinFac,
	["TKillOther"]= TKillOther,
	["TDart"]= TDart,
	["TKillDart"]= TKillDart,
	["TUpSkill"]= TUpSkill,
	["TDrink"]= TDrink,
	["TStone"]= TStone,
	["TYanhuo"]= TYanhuo,
	["TPersonalEscort"]= TPersonalEscort,
	["TSingleKillMonster"]= TSingleKillMonster,
	["TNPCUseGot"]= TNPCUseGot,
	["TMonsterUseGot"]= TMonsterUseGot,
	["TChangeMode"]= TChangeMode,
	["TEquipCompound"]= TEquipCompound,
	["TPickReward"]= TPickReward,
	["TEnterPreBook"]= TEnterPreBook,
}

--构造任务目标的函数
function TargetHelper.createTarget(name, task, context, state, loadDB)
	if TargetHelper[name] then
		return TargetHelper[name](task, context, state, loadDB)
	end
end