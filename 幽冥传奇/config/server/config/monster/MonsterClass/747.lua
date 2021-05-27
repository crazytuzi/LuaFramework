return {
{
	entityid = 747,
	name = Lang.EntityName.m747,
	modelid = 70,
	icon = 0,
	level = 390,
	entityType = 1,
	race = 2,
	camp = 1,
	monsterType = 4,
	aiConfigId = 69,
	exp = 400000,
	innerExp = 1490,
	nMaxHp = 5000000,
	nMaxMp = 10,
	nPhysicalAttackMin = 5489,
	nPhysicalAttackMax = 7944,
	nMagicAttackMin = 5489,
	nMagicAttackMax = 7944,
	nWizardAttackMin = 5489,
	nWizardAttackMax = 7944,
	nHysicalDefenceMin = 590,
	nHysicalDefenceMax = 1178,
	nMagicDefenceMin = 590,
	nMagicDefenceMax = 1178,
	nHitrate = 59,
	nDogerate = 11,
	fMagicHitRate = 0.5,
	fMagicDogerate = 0,
	fToxicDogerate = 0,
	fToxicRenew = 0.5,
	fHpRenew = 2.5,
	fMpRenew = 0,
	nHpRenewAdd = 0,
	nLuck = 0,
	nCurse = 0,
	nMaxHardLevel = 100,
	fLevelA = 0,
	fLevelB = 0,
	fLevelC = 200,
	fPropA = 0.0095,
	fPropB = 0.0129,
	fPropC = 0.0115,
	nNearAttackRate = 10000,
	nNearAttackType = 1,
	attackLevel = 100,
	attackInterval = 1000,
	nAttackSpeed = 750,
	nMoveOneSlotTime = 700,
	reSelTargetRate = 10,
	maxDropHp = 0,
	attackMusicId = 203,
	dieMusicId = 221,
	targetMusicId = 0,
	damageMusicId = 1,
	attackMusicRate = 50,
	dieMusicRate = 100,
	targetMusicTate = 30,
	damageMusicRate = 50,
	weaponid = 0,
	swingid = 0,
	hatsid = 0,
	dir = 1,
	flags = {
		DenyMove = true,
		DenyBeMove = true,
		DenyAutoAddHp = true,
		DenyAutoAddMp = true,
		CanSeeHideActor = true,
		DenyDieSubExp = true,
		DenyUseNearAttack = true,
		CanAllLootItem = true,
		CanDropCoinGround = true,
		AttackKiller = true,
		AttackPet = true,
		CanAlwaysEnter = true,
		DenyAddNumber = true,
		noReturnHome = true,
		CanGrowUp = true,
	},
	monstercolor = {
 		0,255,255,0,
	},
	priorTarget = {
	},
	drops = {
{type=3,id=0,count=20000,propability=1,group=0},
{type=3,id=0,count=5000,propability=1,group=0},
{ group = 0, type = 0, id = 4234, count = 15, propability = 1, },
{ group = 0, type = 0, id = 4003, count = 1, propability = 4, bind = 1, },
--#include "..\drops\drops747.lua"
	},
},
}