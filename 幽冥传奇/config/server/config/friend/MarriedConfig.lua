
MarriedConfig =
{
    chuansongId=1,
	chinaSceendId = 50,
	chinaRange = {63,152,1,1},
	chinaMFrange = {150,63,1,1},
	westSceendId = 105,
	westRange = {72,142,1,1},
	westMFrange = {149,58,1,1},
	templeSceenId = 106,
	templeRange = {63,149,1,1},
	tempMFrange = {149,62,1,1},
	miSceneId = 107,
	miRange = {48,57,3,4},
	miyueFubenId = 33,
	miYueSceneId = 108,
	miyueX = 47,
	miyueY  =49,
	enterX = 39,
	enterY = 40,
	nUseCoin = 20000,
	hunCheNeedCoin = 300000,
	hunCheNeedYb = 99,
	hunCheModelid = 1,
	specialModelid = 2,
	aviteItemId = 972,
	aviteNeedYb = 3,
	callNeedYb = 1000000,
	CallActorCdTime = 20,
	callNeedLevel = 60,
	itemId = {1326,1327,1328,1329,1330,1331,1332,1333,1334,1335,1336,1337,1338,1339,1340,1341,1342,1343},
	kissDress = {892,893,1326,1327,1328,1329,1330,1331,1332,1333,1334,1335,1336,1337,1338,1339,1340,1341,1342,1343},
	path =
	{
		{Modelid = 2,vehicleId = 3,pathId = 3,posX = 70,posY = 145,},
		{Modelid = 2,vehicleId = 4,pathId = 4,posX = 70,posY = 145,},
		{Modelid = 2,vehicleId = 5,pathId = 5,posX = 70,posY = 145,},
	},
	LoopTime = 15000,
	Awards=
	{
		{ type = 20, id = 3, count = 20, strong = 0, quality = 0, bind = 0 },
	},
	broadLoveFlowers = 18,
	loveDipeffect = {effectId = 6,liveTime = 60,effectX = 48,effectY = 50,},
	FlyFlowersInDongFang = {needYb = 18,liveTime = 60,effectId = 1,},
	exitSceenId = 3,
	exitRange = {87,126,3,3},
	weddingNeedCoin = 50000,
	requestWeddingNeedCoin = 1000,
	requestWeddingCd = 20,
	divorceNeedCoin = 100000,
	marryLevel = 60,
	loveEffect =
	{
		needYb = 3,
		effectConfig =
		{
--#include "marry\loveFlowers1.lua"
--#include "marry\loveFlowers2.lua"
--#include "marry\loveFlowers3.lua"
		},
	},
	weddingGiftBag =
	{
		{
			itemId = 881,
			needYb = 58,
		},
		{
			itemId = 882,
			needYb = 2013,
		},
		{
			itemId = 883,
			needYb = 2013,
		},
		{
			itemId = 884,
			needYb = 18888,
		},
	},
	FlowersBag =
	{
	},
	buyBankNeedYb = 132,
	BankConfig =
	{
--#include "marry\band1.lua"
--#include "marry\band2.lua"
--#include "marry\band3.lua"
	},
	inviteToMarryCoin = 200000,
	DressConfig =
	{
		{
			itemId = 888,
			needYb = 798,
		},
		{
			itemId = 889,
			needYb = 798,
		},
		{
			itemId = 890,
			needYb = 798,
		},
		{
			itemId = 891,
			needYb = 798,
		},
		{
			itemId = 892,
			needYb = 13920,
		},
		{
			itemId = 893,
			needYb = 13920,
		},
	},
	HandFlowersId = 358,
	ButHandFlowersNeedYb = 13140,
	ringId = 435,
	ringNeedYb = 520,
	saluteNeedYb = 200000,
	BuySaluteCdTime = 20,
	saluteMusic = 34,
	saluteLiveTime = 4,
	saluteList =
	{
--#include "marry\salute1.lua"
--#include "marry\salute2.lua"
--#include "marry\salute3.lua"
	},
	fireWorksNeedYb = 100,
	RoseFlowersNeedYb = 200000,
	BuyRoseFlowerCdTime = 20,
	roseEffect = {id = 1,	time = 60},
	RedBagConfig =
	{
		{
			needCoin = 88888,
			effectId = 5,
			effectTime = 10,
		},
		{
			needCoin = 888888,
			effectId = 5,
			effectTime = 10,
		},
		{
			needCoin = 888,
			effectId = 5,
			effectTime = 10,
		},
		{
			needCoin = 8888,
			effectId = 5,
			effectTime = 20,
		},
	},
	candyItemId = 878,
	buyCandyNeedCoin = 3,
	windItemId = 879,
	buyWindNeedYb = 18,
}
