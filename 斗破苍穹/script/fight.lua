require "DictYFire"
require "fightpyros"
require "fightyokes"
require "cocos.cocos2d.json"
local Fighter = require"fighter"

local SHOW_DEBUG_BUTTONS = false
--是否预加载资源
local ENABLE_PRELOAD = false
--是否已经加载资源
local isResourcesLoaded = false

-- [[Fake Fight Data
FAKE_INIT_DATA = {
	maxBigRound = 30,--可为空（即默认30回合），
	allowSpeed3 = false,
	isPVE = true,
	isSelfFirst = false,
	isBoss = false,
	allowSkipFight = true,
	skipEmbattle = false,
	bgImagePath0 = "image/backgroundWar/heijiaoyu02.png",
	bgImagePath1 = "image/backgroundWar/heijiaoyu01.png",
	myData = { --todo rename renxing
		mainForce = {
			{name="主力1",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=1,frameID=1,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			{name="主力2",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=2,frameID=2,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=2,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			{name="主力3",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=3,frameID=3,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=3,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			{name="主力4",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=4,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=4,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			{name="主力5",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=5,frameID=1,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=5,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			{name="主力6",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=6,frameID=2,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=6,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
		},
		substitute = {
			{name="替补1",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=7,frameID=3,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			{name="替补2",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=8,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			{name="替补3",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=9,frameID=1,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
		},
		skillCards = { --todo 最大4个限制
			{id=0500,lv=1,iconID=10073},
			{}, --!!!可以为空表，即技能栏开启，但未装备技能。
			{id=0502,lv=1,iconID=10073},
			{id=0503,lv=1,iconID=10073},
		},
		power = 1000000,
	},
	otherData = {
		{
			mainForce = {
				{name="主力1",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=11,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力2",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=12,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力3",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=13,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力4",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=14,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力5",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=15,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力6",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=16,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			},
			substitute = {
				{name="替补1",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=17,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="替补2",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=18,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="替补3",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=19,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			},
			skillCards = {
				{id=0502,lv=1,iconID=10073},
				{id=0503,lv=1,iconID=10073},
				{id=0504,lv=1,iconID=10073},
				{id=0505,lv=1,iconID=10073}
			},
			power = 1000000,
		},
		{
			mainForce = {
				{name="主力1",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				{name="主力2",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力3",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力4",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力5",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力6",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			},
			substitute = {
				{name="替补1",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				{name="替补2",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="替补3",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			},
			skillCards = {
				{id=0500,lv=1,iconID=10073},
				{id=0501,lv=1,iconID=10073},
				{id=0502,lv=1,iconID=10073},
				{id=0503,lv=1,iconID=10073},
				{id=0504,lv=1,iconID=10073},
				{id=0505,lv=1,iconID=10073}
			},
			power = 1000000,
		},
		{
			mainForce = {
				{name="主力1",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				{name="主力2",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				{name="主力3",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=200,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力4",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力5",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				--{name="主力6",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			},
			substitute = {
				{name="替补1",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				{name="替补2",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
				{name="替补3",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}},
			},
			skillCards = {
				{id=0500,lv=1,iconID=10073},
				{id=0501,lv=1,iconID=10073},
				{id=0502,lv=1,iconID=10073},
				{id=0503,lv=1,iconID=10073},
				{id=0504,lv=1,iconID=10073},
				{id=0505,lv=1,iconID=10073}
			},
			power = 1000000,
		},
	},
	script = {
		{fight = 1,round = 1,order= {reset=true,1,2,3,4,5,6,7,8,9,10,11,12,}}, --order={}可恢复默认出手顺序
		{fight = 1,round = 1,music= {mp3 = "sound/arena.mp3"}},
		{fight = 1,round = 1,bg   = {bgImagePath0 = "image/backgroundWar/shanmaineibu02.png",bgImagePath1 = "image/backgroundWar/shanmaineibu01.png"}},
		{fight = 1,round = 1,talk = {dir=0,name="Name",cardID=1,awoken=false,dialog = "1点击添加Fighter"}},
		{fight = 1,round = 1,enter= {position = 10,upDown = true,data = {name="脚本加入",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}}}},
		{fight = 1,round = 1,exit = {position = 10,upDown = true}},
		{fight = 1,round = 1,intro= {id = 0}},
		{fight = 1,round = 1,talk = {dir=1,name="Name",cardID=1,awoken=false,dialog = "1已经添加Fighter"}},
		--{fight = 1,round = 2,guide= {dir=0,name="Name",cardID=1,dialog = "请按提示点击图标来释放技能"}},
		{fight = 1,round =-1,talk = {dir=1,name="Name",cardID=1,awoken=false,dialog = "第一场胜利结束"}},
		{fight = 1,round = 0,talk = {dir=1,name="Name",cardID=1,awoken=false,dialog = "第一场失败结束"}},
		{fight = 2,round = 2,talk = {dir=1,name="Name",cardID=1,awoken=false,dialog = "2点击添加Fighter"}},
		{fight = 2,round = 2,enter= {position = 11,data = {name="脚本加入",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}}}},
		{fight = 2,round = 2,talk = {dir=0,name="Name",cardID=1,awoken=false,dialog = "2已经添加Fighter"}},
		{fight = 3,round = 3,talk = {dir=0,name="Name",cardID=1,awoken=false,dialog = "3点击添加Fighter"}},
		{fight = 3,round = 3,enter= {position = 12,data = {name="脚本加入",scale=nil,isBoss=false,showBanner=true ,awoken=false ,cardID=51,frameID=4,hp=100,hit=50,dodge=50,hitRatio=50,dodgeRatio=50,crit=50,renxing=50,critRatio=50,renxingRatio=50,critRatioDHAdd=0,critRatioDHSub=0,critPercentAdd=0,critPercentSub=0,bufBurnReduction=0,bufPoisonReduction=0,bufCurseReduction=0,attPhsc=50,attMana=50,defPhsc=50,defMana=50,attPhscRatio=5,attManaRatio=5,defPhscRatio=5,defManaRatio=5,shuxingzengzhi=10,damageIncrease=0,immunityPhscRatio=0.0,immunityManaRatio=0.0,jjCur=1,jjMax=5,wingID=1,yokeID=1,yokeLV=1,yokeEnable=true,sks={{id=0001,lv=1},},pyros={{id=1,lv=1},{id=2,lv=2},{id=4,lv=1},}}}},
		{fight = 3,round = 3,talk = {dir=1,name="Name",cardID=1,awoken=false,dialog = "3已经添加Fighter"}},
		{fight = 3,round =-1,talk = {dir=1,name="Name",cardID=1,awoken=false,dialog = "第三场胜利结束，所有战斗胜利。"}},
		{fight = 3,round = 0,talk = {dir=1,name="Name",cardID=1,awoken=false,dialog = "第三场失败结束，最后战斗失败。"}},
	},
	record = nil,
}
-- Fake Fight Data ]]

--动画个数及路径定义
local PATH_JSON_FIGHTER= "ani/Fighter/Fighter.ExportJson"
local MISSILE_ID_MIN = -13
local MISSILE_ID_MAX = 14
local PATH_JSON_MISSILES = {}
for i = MISSILE_ID_MIN,MISSILE_ID_MAX do
	PATH_JSON_MISSILES[i] = "ani/Missile/Missile" .. i .. "/Missile" .. i .. ".ExportJson"
end
local EFFECT_ID_MIN = 0
local EFFECT_ID_MAX = 21
local PATH_JSON_EFFECTS = {}
for i = EFFECT_ID_MIN,EFFECT_ID_MAX do
	PATH_JSON_EFFECTS[i] = "ani/Effect/Effect" .. i .. "/Effect" .. i .. ".ExportJson"
end
local HALO_ID_MIN = 0
local HALO_ID_MAX = 2
local PATH_JSON_HALOS = {}
for i = HALO_ID_MIN,HALO_ID_MAX do
	PATH_JSON_HALOS[i] = "ani/Halo/Halo" .. i .. "/Halo" .. i .. ".ExportJson"
end
local PATH_JSON_BANNER_FIGHTER= "ani/Banner/Banner/Banner.ExportJson"
local PATH_JSON_BANNER_MINI   = "ani/Banner/Banner_mini/Banner_mini.ExportJson"
local PATH_JSON_BANNER_MANUAL = "ani/Banner/BannerManual/BannerManual.ExportJson"
local PATH_JSON_INDICATOR= "ani/Indicator/Indicator.ExportJson"
local BLACKBASE_ID_MIN = -1
local BLACKBASE_ID_MAX = 1
local PATH_JSON_BLACKBASES = {}
for i = BLACKBASE_ID_MIN,BLACKBASE_ID_MAX do
	PATH_JSON_BLACKBASES[i] = "ani/BlackBase/BlackBase" .. i .. "/BlackBase" .. i .. ".ExportJson"
end
local PATH_JSON_REDBOX = "ani/RedBox/RedBox.ExportJson"
local PATH_JSON_INTRO = "ani/action_renwu/action_renwu.ExportJson"
local PREPARE_ID_MIN = -1
local PREPARE_ID_MAX = 10
local PATH_JSON_PREPARES = {}
for i = PREPARE_ID_MIN,PREPARE_ID_MAX do
	PATH_JSON_PREPARES[i] = "ani/Prepare/Prepare" .. i .. "/Prepare" .. i .. ".ExportJson"
end
local PATH_JSON_BUFFERS={}
for i = 1,BUFFER_TYPE_MAX do
	PATH_JSON_BUFFERS[i] = "ani/Buffer/Buffer" .. i .. "/Buffer" .. i .. ".ExportJson"
end
local PATH_JSON_OPEN = "ani/Open/Open.ExportJson"
local PATH_JSON_SPLASH = "ani/ui_anim/ui_anim70/ui_anim70.ExportJson"
local PATH_JSON_PYRO = "ani/pyro/pyro.ExportJson"
--todo 提交动画后修正。
--翅膀动画路径
local PATH_JSON_WING_LV1 = "ani/ui_anim/ui_anim55/ui_anim55.ExportJson"
local PATH_JSON_WING_LV2 = "ani/ui_anim/ui_anim56/ui_anim56.ExportJson"
local PATH_JSON_WING_LV3 = "ani/ui_anim/ui_anim57/ui_anim57.ExportJson"
--翅膀进阶对应动画名数组，names = {yokeLV=aniName,...}
local WING_ANI_NAMES = {"ui_anim55","ui_anim56","ui_anim57",}
--翅膀进阶对应动作号数组，顺序：ids = {yokeID=actID,...}
local WING_ACT_IDS = {3,1,2,0,4,5,6,8,7,9,10}

--震动幅度
local SHAKE_AMPLITUDE = 20

--导弹类型定义
local MISSILE_TYPE_NONE      = 0 --无  导弹
local MISSILE_TYPE_LIGHTNING = 1 --闪电导弹
local MISSILE_TYPE_SINGLE    = 2 --单体导弹
local MISSILE_TYPE_FULL      = 3 --全屏导弹

--闪电导弹高度定义
local MISSILE_LIGHTNING_HEIGHT = 500

--检测导弹是否为闪电类型
local function isMissileLightning(id)
	local lightnings = {13,14} --闪电类型导弹IDs列表
	for i = 1,#lightnings do
		if lightnings[i] == id then
			return true
		end
	end
	return false
end

--检测单体导弹是否越过
local function isMissileFlyOver(id)
	local flyOvers = {} --单体飞越导弹IDs列表
	for i = 1,#flyOvers do
		if flyOvers[i] == id then
			return true
		end
	end
	return false
end

--时间定义,单位s
local TIME_WALK    = 1.5
local TIME_RUN     = 0.25
local TIME_MISSILE = 0.25

--Boss战
local BOSS_POSITION = 12 --Boss的位置号定义
local BOSS_SCALE    = 2  --Boss的缩放值定义

--速度映射表
local MAPPING_SPEEDS = 
{
	{speed=1.2,pngPath="image/zhandou_sudu1.png"},
	{speed=2.4,pngPath="image/zhandou_sudu2.png"},
	{speed=3.6,pngPath="image/zhandou_sudu3.png"},
bak={speed=3.6,pngPath="image/zhandou_sudu3.png"}, --!!!备份3倍速设置
}

--最大回合数限制
local MAX_ROUND_LIMIT = 30

--Fighter缩放倍数
local FIGHTER_NORMAL_SCALE = 1.2
local FIGHTER_BOSS_SCALE   = 1.4

local POSITIONS = 
{--以下顺序以OpenGL坐标系为准
	{x=142,y=160},{x=320,y=160},{x=496,y=160},
	{x=142,y=363},{x=320,y=363},{x=496,y=363},
	{x=142,y=750},{x=320,y=750},{x=496,y=750},
	{x=142,y=956},{x=320,y=956},{x=496,y=956},
}
--移动到地方的面对距离
local FACE_DISTANCE = 160

local FLOAT_DAMAGE_PERCENT     = 5 --伤害浮动百分系数
local FLOAT_DAMAGE_PERCENT_MIN = 100 - FLOAT_DAMAGE_PERCENT
local FLOAT_DAMAGE_PERCENT_MAX = 100 + FLOAT_DAMAGE_PERCENT
local CRIT_DAMAGE_MAX = 1.8 --暴击倍数上限
local CRIT_DAMAGE_X   = 1.5 --暴击倍数
local CRIT_DAMAGE_MIN = 1.2 --暴击倍数下限

local DAMAGE_TYPE_REGENERATION = 0
local DAMAGE_TYPE_GENERIC      = 1
local DAMAGE_TYPE_CRIT         = 2

local BUFFER_REDUCE_MAX = 0.4 --灼烧中毒诅咒Buffer的减伤百分比上限
local BUFFER_REDUCE_MIN = 0.0 --灼烧中毒诅咒Buffer的减伤百分比下限

local POWER_MAX = 0.90 --战力比上限
local POWER_MIN = 0.75 --战力比下限
local POWER_BASE= 0.05 --战力基础减伤
local POWER_HIGH= 0.20 --战力最高减伤

--fix bug(zOrder confusion)
local ZORDER_OF_GAMENODE         = 0
	--!!! 以 下 zOrder 属于 ZORDER_OF_GAMENODE
	local ZORDER_OF_BGNODE           = 0000
	local ZORDER_OF_WING_HIDDEN      = 0020
	local ZORDER_OF_FIGHTER_HIDDEN   = 0040 --[0040,0051]区间有效
	local ZORDER_OF_CURTAIN          = 0060
	local ZORDER_OF_BLACKBASE        = 0100
	local ZORDER_OF_HALO             = 0200
	local ZORDER_OF_PREPARE_BACKGROUND=0250
	local ZORDER_OF_WING_SHOWN       = 0270
	local ZORDER_OF_FIGHTER_INACTIVE = 0300 --[0300,0311]区间有效
	local ZORDER_OF_FIGHTER_PASSIVE  = 0400 --[0400,0411]区间有效
	local ZORDER_OF_FIGHTER_ACTIVE   = 0500 --[0500,0500]区间有效
	local ZORDER_OF_PREPARE_FOREGROUND=0600
	local ZORDER_OF_MISSILE          = 0700
	local ZORDER_OF_EFFECT           = 0800
	local ZORDER_OF_BLOOD            = 0900
	local ZORDER_OF_BANNER           = 1000
	local ZORDER_OF_REDBOX           = 1000
	local ZORDER_OF_OPEN             = 1050
	local ZORDER_OF_SPLASH           = 1060
	local ZORDER_OF_PYRO             = 1070
	local ZORDER_OF_INTRO            = 1100
	local ZORDER_OF_EMBATTLE         = 1200
	--!!! 以 上 zOrder 属于 ZORDER_OF_GAMENODE
local ZORDER_OF_BANNER_INDICATOR = 1
local ZORDER_OF_BOTTOM_BAR       = 2
local ZORDER_OF_SPEED            = 3
local ZORDER_OF_SUBSTITUTE_HEAD  = 4
local ZORDER_OF_SUBSTITUTE_COVER = 5
local ZORDER_OF_SUBSTITUTE_SPRITE= 6
local ZORDER_OF_SKILL_CARDS      = 7
local ZORDER_OF_SKIP_FIGHT       = 8
local ZORDER_OF_ROUND            = 9
local ZORDER_OF_DIALOG           = 10
local ZORDER_OF_BUTTONS          = 100

--队列中的动作类型
local ACT_ROUND  = 1
local ACT_ENTER  = 2
local ACT_EXIT   = 3
local ACT_COUNTER= 4
local ACT_MANUAL = 5
local ACT_STAND  = 6
local ACT_BURN   = 7
local ACT_POISON = 8
local ACT_CURSE  = 9
local ACT_MMMMMM = 10
local ACT_ENTER2 = 11
local ACT_EXIT2  = 12

--Fighter 动画号
local ANIMATION_STAND   = 0
local ANIMATION_WALK    = 1
local ANIMATION_RUN     = 2
local ANIMATION_DEAD    = 3
local ANIMATION_ATTACK_0= 4
local ANIMATION_ATTACK_1= 5
local ANIMATION_ATTACK_2= 6
local ANIMATION_ATTACK_3= 7
local ANIMATION_ATTACK_4= 8
local ANIMATION_INJURE_0= 9
local ANIMATION_INJURE_1= 10
local ANIMATION_INJURE_2= 11
local ANIMATION_INJURE_3= 12
local ANIMATION_INJURE_4= 13
local ANIMATION_INJURE_5= 14
local ANIMATION_DODGE   = 15
local ANIMATION_IMMUNITY= 16
local ANIMATION_ENTER   = 17
local ANIMATION_EXIT    = 18
local ANIMATION_REVIVE  = 19
local ANIMATION_MAX     = 20

--Buffers动画号
local BUFFERS_CREATE = 0
local BUFFERS_STATUS = 1
local BUFFERS_EFFECT = 2

Fight = {}

--init in doInit()
Fight.isSpeed3Notified = false
Fight.enableSoundEffect = true
Fight.callback = nil
Fight.initData = nil
Fight.randomseed = 0 --为了更随机
Fight.speedIdx = 1
Fight.speed    = 1 --!!!MUST NOT be 0
Fight.customPriorityMap = nil
Fight.scene    = nil
Fight.shakeNode= nil
Fight.bloodNodes=nil
Fight.shakeRef = 0
Fight.bgSprite = nil
Fight.walkDistance = 240 --每场战斗走动的距离
Fight.fighters = nil
Fight.curtainNode    = nil
Fight.fighterBanner  = nil
--Fight.bannerIndicator = nil
Fight.bannerMini     = nil
--Fight.manualBanner   = nil
Fight.blackBaseNode  = nil
Fight.redBoxNode     = nil
Fight.introNode      = nil
Fight.prepareNodeB   = nil
Fight.prepareNodeF   = nil
Fight.missileNodes   = nil
Fight.effectNodes    = nil
Fight.haloNodes      = nil
Fight.openNode       = nil
Fight.splashNode     = nil
Fight.pyroNodes      = nil
Fight.speedSprite    = nil
--Fight.bottomBar      = nil
--Fight.mySubstituteHead  = nil
--Fight.mySubstituteCover = nil
--Fight.mySubstituteSprite= nil
Fight.skipFightBtn      = nil
Fight.roundLabel        = nil
Fight.dialogLayer       = nil
Fight.dialogTop         = nil
Fight.dialogBottom      = nil
Fight.dialogHeadTop     = nil
Fight.dialogHeadBottom  = nil
Fight.dialogDialogTop   = nil
Fight.dialogDialogBottom= nil
Fight.dialogNameTop     = nil
Fight.dialogNameBottom  = nil
Fight.dialogTextTop     = nil
Fight.dialogTextBottom  = nil
Fight.startFight  = nil
Fight.damages     = nil
--!!!修复播放录像时和原始战斗过程不一致的问题。
--原因是：多个并行骨骼动画的事件触发时间顺序会有所不同，导致随机数的获取顺序不一致。
--类似多线程的同步问题。
Fight.FIX_BUG_OF_GET_RANDOM = nil

Fight.debugSpeedLabel = nil
Fight.debugButton1    = nil
Fight.debugButton2    = nil
Fight.debugButton3    = nil
Fight.debugButton4    = nil
Fight.debugButton5    = nil
Fight.debugButton6    = nil

--init in doFight
Fight.isReplay = false
Fight.skipFightFlag = false
Fight.isAutomatic = false
Fight.recordRandomIdx = 0
Fight.recordManualIdx = 1
Fight.recordMMMMMMIdx = 1
Fight.mySubstituteIdx    = 0
Fight.otherSubstituteIdx = 0
Fight.manualDisabled  = true
Fight.mySkillCardsOrder = nil
Fight.otherSkillCardsOrder = nil
Fight.myDeaths   = 0
Fight.otherDeaths= 0
Fight.fightIndex = 1
Fight.roundOrigin= 0 --每一小场战斗的回合数起点，用于修正脚本中的回合数。
Fight.roundIndex = 0
Fight.bigRound   = 0
Fight.scriptIndex= 1
Fight.scriptLastDialogRoundIndex = -1
Fight.actionIndex= 0
Fight.actionHead = nil
Fight.embattleDragPos = nil
Fight.embattleOffsetX = 0
Fight.embattleOffsetY = 0
Fight.missileType     = nil
Fight.myPowerReduction    = nil
Fight.otherPowerReduction = nil

--init in doScript -> onScriptDone
Fight.isExtra  = false
Fight.isEnter  = false
Fight.isExit   = false
Fight.roundSrc = nil
Fight.roundSID = nil
Fight.roundDie = false
Fight.roundSkp = false
Fight.isBurnt  = false
Fight.isPoisoned=false
Fight.isCursed = false
Fight.act = nil
Fight.sid = nil
Fight.slv = nil
Fight.src = nil
Fight.tag = nil --for record
Fight.dst = {}
Fight.yokeDst = 0 --for yokeThunder
Fight.timeLineCount = 0   --For sync
Fight.runType   = 0   --For run
Fight.backupX = 0 --For run back
Fight.backupY = 0 --For run back
Fight.backupS = 0 --For run back
Fight.baseAtt = 0
Fight.pyroAtt = 0
Fight.permAtt = 0
Fight.bufAAtt = 0
Fight.bufDAtt = 0
Fight.incrAtt = 0
Fight.deadAtt = 0
Fight.hphpAtt = 0
Fight.buffAtt = 0

--{{SkillCard类
local SKILL_CARD_STATE_EMPTY  = 0
local SKILL_CARD_STATE_CDING  = 1
local SKILL_CARD_STATE_NORMAL = 2
local SKILL_CARD_STATE_PRESSED= 3
local SKILL_CARD_STATE_RELEASED=4

local ZORDER_OF_SC_BORDER = 1
local ZORDER_OF_SC_BUTTON = 2
local ZORDER_OF_SC_CDING  = 3
local ZORDER_OF_SC_MAN1   = 4
local ZORDER_OF_SC_MAN2   = 5

--My
local MySkillCard = class("MySkillCard",function()return cc.Node:create()end)

function MySkillCard.onSkillCard(skillCard)
	if Fight.isReplay or Fight.manualDisabled or Fight.isAutomatic or not Fight.initData.isPVE then --todo 使用其他状态禁止
		return
	end
	if skillCard:getState() == SKILL_CARD_STATE_NORMAL then
		local manualSkill = Fight.initData.myData.skillCards[skillCard:getTag()]
		Fight.actionPushFront(ACT_MANUAL,manualSkill.id,manualSkill.lv,nil,skillCard:getTag())
		skillCard:setState(SKILL_CARD_STATE_PRESSED)
	end
end

function MySkillCard.create(i)
	local skillCard = MySkillCard.new()
	skillCard:setTag(i)
	skillCard:setPosOfIndex(i)
	skillCard:setLocalZOrder(ZORDER_OF_SKILL_CARDS)
	Fight.scene:addChild(skillCard)
	
	local scData = Fight.initData.myData.skillCards[i]
	local scsid  = scData.id
	if scsid then
		local border = cc.Sprite:create("image/zhandou_kuang2.png")
		border:setLocalZOrder(ZORDER_OF_SC_BORDER)
		skillCard:addChild(border)
		skillCard:setState(SKILL_CARD_STATE_CDING)
		skillCard.cdCount = SkillManager[scsid].cd

		local pngPath = "image/f_" .. DictUI[tostring(scData.iconID)].fileName
		skillCard.button = ccui.Button:create(pngPath,pngPath,pngPath)
		skillCard.button:addTouchEventListener(function(button,type)
				if type == 2 then
					MySkillCard.onSkillCard(button:getParent())
				end
			end
		)
		skillCard.button:setLocalZOrder(ZORDER_OF_SC_BUTTON)
		skillCard:addChild(skillCard.button)
		
		if skillCard.cdCount > 0 then
			skillCard:setState(SKILL_CARD_STATE_CDING)
			skillCard.cdSprite = cc.Sprite:create("image/zhandou_djs_di.png")
			skillCard.cdSprite:setTextureRect(cc.rect(0,(skillCard.cdCount-1)*45,45,45))
			skillCard.cdSprite:setPosition(30,-30)
			skillCard.cdSprite:setLocalZOrder(ZORDER_OF_SC_CDING)
			skillCard:addChild(skillCard.cdSprite)
		else
			skillCard:setState(SKILL_CARD_STATE_NORMAL)
		end
	else --scsid == nil
		local border = cc.Sprite:create("image/zhandou_kuang1.png")
		border:setLocalZOrder(ZORDER_OF_SC_BORDER)
		skillCard:addChild(border)
		skillCard:setState(SKILL_CARD_STATE_EMPTY)
	end
	
	return skillCard
end

function MySkillCard:updateCD()
	if self.state == SKILL_CARD_STATE_CDING and self.cdCount > 0 then
		self.cdCount = self.cdCount - 1
		self.cdSprite:setTextureRect(cc.rect(0,(self.cdCount-1)*45,45,45))
		if self.cdCount == 0 then
			self.cdSprite:setVisible(false)
			self:setState(SKILL_CARD_STATE_NORMAL)
		end
	end
end

function MySkillCard:setState(state)
	self.state = state
	--Normal
	if state == SKILL_CARD_STATE_NORMAL then
		self.man1 = ccs.Armature:create("Manual1")
		self.man1:getAnimation():setSpeedScale(1)
		self.man1:getAnimation():playWithIndex(0,-1,1)
		self.man1:setLocalZOrder(ZORDER_OF_SC_MAN1)
		self:addChild(self.man1)
	elseif self.man1 then
		self.man1:removeFromParent()
		self.man1 = nil
	end
	--Pressed
	if state == SKILL_CARD_STATE_PRESSED then
		self.man2 = cc.ParticleSystemQuad:create("ani/Manual2/Manual2.plist")
		self.man2:setLocalZOrder(ZORDER_OF_SC_MAN2)
		self:addChild(self.man2)
	elseif self.man2 then
		self.man2:removeFromParent()
		self.man2 = nil
	end
	--Released
	if state == SKILL_CARD_STATE_RELEASED then
		self.button:setEnabled(false)
		utils.GrayWidget(self.button,true)
	end
end

function MySkillCard:getState()
	return self.state
end

function MySkillCard:setPosOfIndex(index)
	self:setPosition(19+index*128,57)
end

--Other
local OtherSkillCard = {}
OtherSkillCard.__index = OtherSkillCard

function OtherSkillCard:setTag(t)       self.tag = t end
function OtherSkillCard:getTag() return self.tag     end

function OtherSkillCard:setState(s)       self.state = s end
function OtherSkillCard:getState() return self.state     end

function OtherSkillCard.create(i)
	local skillCard = setmetatable({},OtherSkillCard)
	skillCard:setTag(i)
	local scData = Fight.initData.otherData[1].skillCards[i]
	local scsid  = scData.id
	if scsid then
		skillCard.cdCount = SkillManager[scsid].cd
		if skillCard.cdCount > 0 then
			skillCard:setState(SKILL_CARD_STATE_CDING)
		else
			skillCard:setState(SKILL_CARD_STATE_NORMAL)
		end
	else
		skillCard:setState(SKILL_CARD_STATE_EMPTY)
	end
	return skillCard
end

function OtherSkillCard:updateCD()
	if self.state == SKILL_CARD_STATE_CDING and self.cdCount > 0 then
		self.cdCount = self.cdCount - 1
		if self.cdCount == 0 then
			self:setState(SKILL_CARD_STATE_NORMAL)
		end
	end
end
--}}SkillCard类

--用于震动和翅膀跟随Fighter
function Fight.onUpdate(dt)
	if Fight.shakeRef > 0 then
		Fight.shakeNode:setPositionY(math.random(-SHAKE_AMPLITUDE,SHAKE_AMPLITUDE))
	end
	for i=1,12 do
		local fer = Fight.fighters[i]
		fer:onUpdate(dt) --For Fighter HP TextRect
		local wing= fer.wing
		if wing then
			local scale = fer:getScale()
			wing:setScale(0.5*scale)
			wing:setVisible(fer:isVisible())
			wing:setPosition(fer:getPositionX(),fer:getPositionY()+30*scale)
		end
	end
end

--更新倍速显示
function Fight.updateFightSpeed(isUpdateSprite)
	for i = 1,12 do
		local fer = Fight.fighters[i]
		fer:getAnimation():setSpeedScale(Fight.speed)
		if fer.wing then
			fer.wing:getAnimation():setSpeedScale(Fight.speed)
		end
		for j = 1,BUFFER_TYPE_MAX do
			if fer:getBufferArmature(j) ~= nil then
				fer:getBufferArmature(j):getAnimation():setSpeedScale(Fight.speed)
			end
		end
	end
	Fight.debugSpeedLabel:setString(Fight.speed .. "x")
	if isUpdateSprite then
		local pngPath = MAPPING_SPEEDS[Fight.speedIdx].pngPath
		Fight.speedSprite:loadTextures(pngPath,pngPath,pngPath)
		cc.UserDefault:getInstance():setIntegerForKey("FightSpeedIndex",Fight.speedIdx)
	end
end

--纠正翅膀的ZOrder
function Fight.fixWingZOrder(pos)
	local col = (pos-1) % 3
	if col == 0 then
		return pos + 1
	elseif col == 1 then
		return pos - 1
	else
		return pos
	end
end

--设置Fighter属性
function Fight.setFighterProperties(pos,fst)
	local fer = Fight.fighters[pos]
	fer:setScale(fst.scale and fst.scale or fst.isBoss and FIGHTER_BOSS_SCALE or FIGHTER_NORMAL_SCALE)
	fer:setAwoken(fst.awoken)
	fer:setName(fst.name,fst.frameID)
	fer:setCardID(fst.cardID)
	fer:setFrameID(fst.frameID)
	fer:setJJ(fst.jjCur,fst.jjMax)
	fer:setShowBanner(fst.showBanner)
	fer:setRound(0)
	fer:setHPVisible(true)
	fer:setHPMax(fst.hp)
	fer:setHPLmt(fst.hp)
	fer:setHP(fst.hpCur and fst.hpCur or fst.hp,true)
	fer:setHit(fst.hit)
	fer:setDodge(fst.dodge)
	fer:setHitRatio(fst.hitRatio)
	fer:setDodgeRatio(fst.dodgeRatio)
	fer:setCrit(fst.crit)
	fer:setRenXing(fst.renxing)
	fer:setCritRatio(fst.critRatio)
	fer:setRenXingRatio(fst.renxingRatio)
	fer:setCritRatioDH(fst.critRatioDHAdd,fst.critRatioDHSub)
	fer:setCritPercentAdd(fst.critPercentAdd)
	fer:setCritPercentSub(fst.critPercentSub)
	fer:setBufBurnReduction(fst.bufBurnReduction)
	fer:setBufPoisonReduction(fst.bufPoisonReduction)
	fer:setBufCurseReduction(fst.bufCurseReduction)
	fer:setAttackEx(0)
	fer:setOriginalAttacks(fst.attPhsc,fst.attMana)
	fer:setAttacks(fst.attPhsc,fst.attMana)
	fer:setAttacksRatio(fst.attPhscRatio,fst.attManaRatio)
	fer:setDefenceEx(0)
	fer:setOriginalDefences(fst.defPhsc,fst.defMana)
	fer:setDefences(fst.defPhsc,fst.defMana)
	fer:setDefencesRatio(fst.defPhscRatio,fst.defManaRatio)
	fer:setSXZZ(fst.shuxingzengzhi)
	fer:setSHJC(fst.damageIncrease)
	fer:setImmunityRatio(fst.immunityPhscRatio,fst.immunityManaRatio)
	fer:setSkills(fst.sks)
	fer:setPyros(fst.pyros)
	fer:setHasYokes(
		fst.yokeEnable and fst.yokeID == YOKE_Thunder.id,
		fst.yokeEnable and fst.yokeID == YOKE_Wind.id,
		fst.yokeEnable and fst.yokeID == YOKE_Light.id,
		fst.yokeEnable and fst.yokeID == YOKE_Dark.id
	)
	fer:setPyroLimited(false)
	fer:clearBuffers()
	if fer.wing then
		fer.wing:removeFromParent()
	end
	--服务器发送的wingID、yokeLV会有为0的情况。
	if fst.wingID and fst.wingID > 0 and fst.yokeLV and fst.yokeLV > 0 then
		fer.wing = ccs.Armature:create(WING_ANI_NAMES[fst.yokeLV])
		--fer.wing:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
		--fer.wing:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
		fer.wing:getAnimation():playWithIndex(WING_ACT_IDS[fst.wingID],-1,1)
		fer.wing:setLocalZOrder(ZORDER_OF_WING_SHOWN + 12 - Fight.fixWingZOrder(pos))
		Fight.shakeNode:addChild(fer.wing)
	else
		fer.wing = nil
	end
	--设置免疫伤害次数值
	local pyroLV = fer:getPyroJiuYouJinZuHuo()
	fer:setImmunityCount(false,pyroLV > PYRO_STATE_NULL and PYRO_JiuYouJinZuHuo.var[pyroLV] or 0)
	local pyroLV = fer:getPyroSanQianYanYanHuo()
	fer:setImmunityCount(true ,pyroLV > PYRO_STATE_NULL and PYRO_SanQianYanYanHuo.var[pyroLV] or 0)
	--设置已经复活次数
	fer:setReviveCount(0)
end

--重置异火限制
function Fight.resetLimited()
	local limited7_12 = false
	for i = 1,6 do
		local fer = Fight.fighters[i]
		if fer:isVisible() and not fer:isDead() and fer:getPyroDiYan() > PYRO_STATE_NULL then
			limited7_12 = true
			break
		end
	end
	for i = 7,12 do
		Fight.fighters[i]:setPyroLimited(limited7_12)
	end
	local limited1_6 = false
	for i = 7,12 do
		local fer = Fight.fighters[i]
		if fer:isVisible() and not fer:isDead() and fer:getPyroDiYan() > PYRO_STATE_NULL then
			limited1_6 = true
			break
		end
	end
	for i = 1,6 do
		Fight.fighters[i]:setPyroLimited(limited1_6)
	end
end

--切换Fighter动作，内部处理死亡状态及动作方向
function Fight.setFighterAnimation(pos,index,isLoop)
	local fer = Fight.fighters[pos]
	if index == ANIMATION_STAND and fer:isDead() then --检测死亡
		index = ANIMATION_DEAD
	end
	fer:setJJVisible(index == ANIMATION_STAND)
	if pos > 6 then --检测敌友
		index = index + ANIMATION_MAX
	end
	fer:updateAwokenView()
	fer:getAnimation():playWithIndex(index,-1,isLoop and 1 or 0)
end

--显示伤害值
function Fight.showDamage(damage,damageType,posX,posY)
	--数字宽高定义
	local w1,h1 = 40,55 --恢复数字宽高
	local w2,h2 = 40,55 --掉血数字宽高
	local w3,h3 = 52,70 --暴击数字宽高
	local ww,hh = 170,90--暴击文字宽高
	--切割位置定义createDigit
	local y,w,h = 0,0,0
	if damageType == DAMAGE_TYPE_REGENERATION then
		y,w,h = 0,w1,h1
	elseif damageType == DAMAGE_TYPE_GENERIC then
		y,w,h = h1,w2,h2
	elseif damageType == DAMAGE_TYPE_CRIT then
		y,w,h = h1+h2,w3,h3
	end
	local function createDigit(n)
		return cc.Sprite:create("image/fight_damage.png",cc.rect(n*w,y,w,h))
	end
	local bloodNode = cc.Node:create()
	local digitNode = nil
	local offsetOfX = 0
	repeat
		local nnn
		damage,nnn = math.modf(damage/10)
		digitNode = createDigit(nnn * 10)
		offsetOfX = offsetOfX - digitNode:getContentSize().width
		digitNode:setPosition(offsetOfX,0)
		digitNode:setAnchorPoint(0,0)
		bloodNode:addChild(digitNode)
	until damage == 0
	-- 加、减号
	digitNode = createDigit(10)
	offsetOfX = offsetOfX - digitNode:getContentSize().width
	digitNode:setPosition(offsetOfX,0)
	digitNode:setAnchorPoint(0,0)
	bloodNode:addChild(digitNode)

	local totalWidth = -offsetOfX
	local totalHeight= digitNode:getContentSize().height

	if damageType == DAMAGE_TYPE_CRIT then
		local critSprite = cc.Sprite:create("image/fight_damage.png",cc.rect(0,h1+h2+h3,ww,hh))
		critSprite:setPosition(-totalWidth/2,totalHeight + hh/2)
		bloodNode:addChild(critSprite)
	end
	--坐标修正
	local children = bloodNode:getChildren()
	for i=1,#children do
		local x,y = children[i]:getPosition()
		x = x + totalWidth / 2
		y = y - totalHeight/ 2
		children[i]:setPosition(x,y)
	end
	--动画设计
	if damageType == DAMAGE_TYPE_REGENERATION then
		posX = posX + 0
		posY = posY + 0
		bloodNode:runAction(
			cc.Sequence:create(
				cc.DelayTime:create(1.125),
				cc.CallFunc:create(function()bloodNode:removeFromParent()end)
			)
		)
		for i=1,#children do
			children[i]:setOpacity(0)
			children[i]:runAction(
				cc.Sequence:create(
					cc.FadeIn:create(0.125/Fight.speed),
					cc.DelayTime:create(0.5/Fight.speed),
					cc.FadeOut:create(0.5/Fight.speed)
				)
			)
		end
	elseif damageType == DAMAGE_TYPE_GENERIC then
		--posX = posX + 0
		posY = posY + 90
		bloodNode:setScale(1.3)
		bloodNode:runAction(
			cc.Sequence:create(
				cc.Spawn:create(
					cc.ScaleTo:create(0.27/Fight.speed,1.8),
					cc.MoveBy:create(0.27/Fight.speed,cc.p(0,30))
				),
				cc.ScaleTo:create(0.18/Fight.speed,0.9),
				cc.DelayTime:create(0.72/Fight.speed),
				cc.ScaleTo:create(0.18/Fight.speed,0),
				cc.CallFunc:create(function()bloodNode:removeFromParent()end)
			)
		)
	elseif damageType == DAMAGE_TYPE_CRIT then
		--posX = posX + 0
		posY = posY - 30
		bloodNode:setScale(0.7)
		bloodNode:runAction(
			cc.Sequence:create(
				cc.Spawn:create(
					cc.ScaleTo:create(0.27/Fight.speed,1.2),
					cc.MoveBy:create(0.27/Fight.speed,cc.p(0,30))
				),
				cc.ScaleTo:create(0.18/Fight.speed,0.9),
				cc.DelayTime:create(0.72/Fight.speed),
				cc.ScaleTo:create(0.18/Fight.speed,0),
				cc.CallFunc:create(function()bloodNode:removeFromParent()end)
			)
		)
	end
	bloodNode:setPosition(posX,posY)
	Fight.bloodNodes:addChild(bloodNode)
end

--随机数算法，随机保证，保证序列正确
function Fight.random(...)
	local tag,min,max = ...
	if Fight.isReplay then
		Fight.recordRandomIdx = Fight.recordRandomIdx + 1
		assert(Fight.recordRandomIdx <= #Fight.initData.record.randomNum)
		assert(tag                    ==  Fight.initData.record.randomNum[Fight.recordRandomIdx][2])
		assert(min                    ==  Fight.initData.record.randomNum[Fight.recordRandomIdx][3])
		assert(max                    ==  Fight.initData.record.randomNum[Fight.recordRandomIdx][4])
		return Fight.initData.record.randomNum[Fight.recordRandomIdx][1]
	else
		Fight.randomseed = Fight.randomseed + os.time()
		math.randomseed(Fight.randomseed)
		--精度为0.001
		local ret = math.modf(math.random(...) * 1000) / 1000
		Fight.initData.record.randomNum[#Fight.initData.record.randomNum + 1] = {ret,...}
		return ret
	end
end

function Fight.saveVideo(filePath)
	if Fight.initData.record == nil then
		return
	end
	if true and Fight.initData.script then --todo save optimized script?
		local originScript = Fight.initData.script
		local optimizeScript = {}
		for i=1,#originScript do
			local sData = originScript[i]
			if sData.enter or sData.exit or sData.order then --只记录enter,exit,order
				table.insert(optimizeScript,sData)
			end
		end
		Fight.initData.script = optimizeScript
	end
	local str = json.encode(Fight.initData)
	local videoPath = cc.FileUtils:getInstance():getWritablePath() .. "video.bin"
	local f = io.open(videoPath,"w")
	f:write(str)
	f:flush()
	f:close()
end

function Fight.loadVideo(filePath)
	local videoPath = cc.FileUtils:getInstance():getWritablePath() .. "video.bin"
	local f = io.open(videoPath,"r")
	if f then
		local str = f:read("*a")
		f:close()
		Fight.initData = json.decode(str)
		Fight.fightIndex = 1
		Fight.doFight()
		Fight.debugButton1:setVisible(SHOW_DEBUG_BUTTONS and false)
		Fight.debugButton2:setVisible(SHOW_DEBUG_BUTTONS and false)
		Fight.debugButton3:setVisible(SHOW_DEBUG_BUTTONS and false)
		Fight.debugButton4:setVisible(SHOW_DEBUG_BUTTONS and false)
		Fight.debugButton5:setVisible(SHOW_DEBUG_BUTTONS and true)
		Fight.debugButton6:setVisible(SHOW_DEBUG_BUTTONS and true)
	else
		cclog("没有录像文件")
	end
end

function Fight.updateMySubstitute()
	local nextSubstituteIdx = Fight.mySubstituteIdx + 1
	if nextSubstituteIdx <= #Fight.initData.myData.substitute then
		local fst = Fight.initData.myData.substitute[nextSubstituteIdx]
		local cardData = DictCard[tostring(fst.cardID)]
		local imagePath = "image/" .. DictUI[tostring(cardData.smallUiId)].fileName
		--Fight.mySubstituteHead:setTexture(imagePath)
		--Fight.mySubstituteHead:setVisible(false)
	else
		--Fight.mySubstituteHead:setVisible(false)
	end
	--Fight.mySubstituteSprite:setTextureRect(cc.rect(0,(#Fight.initData.myData.substitute - Fight.mySubstituteIdx)*35,88,35))
end

function Fight.addCardActionArmatureFileInfo(fst)
	if fst == nil then
		return
	end
	local cardData = DictCard[tostring(fst.cardID)]
	local aniFile
	if fst.awoken and cardData.awakeAnima ~= "" then
		aniFile = cardData.awakeAnima
	else
		aniFile = cardData.animationFiles
	end
	if aniFile ~= "" then
		local aniName = aniFile:sub(1,-12)
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/card_action/" .. aniName .. "/" .. aniFile)
	end
end

function Fight.removeCardActionArmatureFileInfo(fst)
	if fst == nil then
		return
	end
	local cardData = DictCard[tostring(fst.cardID)]
	local aniFile
	if fst.awoken and cardData.awakeAnima ~= "" then
		aniFile = cardData.awakeAnima
	else
		aniFile = cardData.animationFiles
	end
	if aniFile ~= "" then
		local aniName = aniFile:sub(1,-12)
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/card_action/" .. aniName .. "/" .. aniFile)
	end
end

function Fight.playEffect(soundName)
	if not Fight.enableSoundEffect then
		return
	end
	local soundPath = "sound/" .. soundName .. ".mp3"
	if cc.FileUtils:getInstance():isFileExist(soundPath) then
		AudioEngine.playEffect(soundPath,false)
	end
end

function Fight.playSound(cardID)
	if not Fight.enableSoundEffect then
		return
	end
	local mp3Name = DictCard[tostring(cardID)].dubTwo
	if mp3Name == "" then
		return
	end
	--todo check exist
	AudioEngine.playEffect("sound/fight/" .. mp3Name .. ".mp3",false)
	--Fight.scene:runAction(
	--	cc.Sequence:create(
	--		cc.DelayTime:create(2/Fight.speed),
	--		cc.CallFunc:create(function()Fight.onSoundDone()end)
	--	)
	--)
end

--function Fight.onSoundDone()
--end

function Fight.tryPreload()
	ENABLE_PRELOAD = true
	Fight.doPreload()
end

function Fight.doPreload()
	if isResourcesLoaded then
		return
	end
	isResourcesLoaded = true
	--init
	Fight.speedIdx = cc.UserDefault:getInstance():getIntegerForKey("FightSpeedIndex",2)
	Fight.speedIdx = math.max(Fight.speedIdx,1)
	Fight.speedIdx = math.min(Fight.speedIdx,3)
	Fight.speed = MAPPING_SPEEDS[Fight.speedIdx].speed
	Fight.scene = cc.Layer:create()
	Fight.scene:setTouchEnabled(false)
	Fight.scene:registerScriptTouchHandler(Fight.onEmbattleTouch,true,0,true)
	Fight.scene:retain()
	--shakeNode
	Fight.shakeNode = cc.Node:create()
	Fight.shakeNode:setLocalZOrder(ZORDER_OF_GAMENODE)
	Fight.scene:addChild(Fight.shakeNode)
	--bloodNodes
	Fight.bloodNodes = cc.Node:create()
	Fight.bloodNodes:setLocalZOrder(ZORDER_OF_BLOOD)
	Fight.shakeNode:addChild(Fight.bloodNodes)
	--Armatures
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_FIGHTER)
	for i = MISSILE_ID_MIN,MISSILE_ID_MAX do
		if cc.FileUtils:getInstance():isFileExist(PATH_JSON_MISSILES[i]) then --todo 某些资源暂时不存在
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_MISSILES[i])
		end
	end
	for i = EFFECT_ID_MIN,EFFECT_ID_MAX do
		if cc.FileUtils:getInstance():isFileExist(PATH_JSON_EFFECTS[i]) then --todo 某些资源暂时不存在
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_EFFECTS[i])
		end
	end
	for i = HALO_ID_MIN,HALO_ID_MAX do
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_HALOS[i])
	end
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_BANNER_FIGHTER)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_BANNER_MINI)
	--ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_BANNER_MANUAL)
	--ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_INDICATOR)
	for i = BLACKBASE_ID_MIN,BLACKBASE_ID_MAX do
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_BLACKBASES[i])
	end
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_REDBOX)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_INTRO)
	for i = PREPARE_ID_MIN,PREPARE_ID_MAX do
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_PREPARES[i])
	end
	for i = 1,BUFFER_TYPE_MAX do
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_BUFFERS[i])
	end
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_OPEN)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_SPLASH)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_PYRO)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_WING_LV1)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_WING_LV2)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(PATH_JSON_WING_LV3)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/GongFang/Gongjia/Gongjia.ExportJson")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/GongFang/Gongjian/Gongjian.ExportJson")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/GongFang/Fangjia/Fangjia.ExportJson")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/GongFang/Fangjian/Fangjian.ExportJson")
	--ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/Manual1/Manual1.ExportJson")
	--fighters
	Fight.fighters = {}
	for i = 1,12 do
		local fer = Fighter:create()
		fer:setTag(i)
		fer:setVisible(false)
		fer:setPosition(POSITIONS[i])
		fer:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
		fer:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
		Fight.shakeNode:addChild(fer)
		Fight.fighters[i] = fer
		fer:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - i)
	end
	--curtainNode
	Fight.curtainNode = cc.LayerColor:create(cc.c4b(0,0,0,0),640,1136+2*SHAKE_AMPLITUDE)
	Fight.curtainNode:setVisible(false)
	Fight.curtainNode:setAnchorPoint(0,0)
	Fight.curtainNode:setPosition(0,-SHAKE_AMPLITUDE)
	Fight.curtainNode:setLocalZOrder(ZORDER_OF_CURTAIN)
	Fight.shakeNode:addChild(Fight.curtainNode)
	--fighterBanner
	Fight.fighterBanner = ccs.Armature:create("Banner")
	Fight.fighterBanner:setVisible(false)
	Fight.fighterBanner:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	Fight.fighterBanner:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	Fight.fighterBanner:getAnimation():setSpeedScale(Fight.speed)
	Fight.shakeNode:addChild(Fight.fighterBanner)
	Fight.fighterBanner:setLocalZOrder(ZORDER_OF_BANNER)
	--bannerIndicator
	--Fight.bannerIndicator = ccs.Armature:create("Indicator")
	--Fight.bannerIndicator:setScale(2)
	--Fight.bannerIndicator:setVisible(false)
	--Fight.bannerIndicator:setLocalZOrder(ZORDER_OF_BANNER_INDICATOR)
	--Fight.scene:addChild(Fight.bannerIndicator)
	--bannerMini
	Fight.bannerMini = ccs.Armature:create("Banner_mini")
	Fight.bannerMini:setScale(2)
	Fight.bannerMini:setVisible(false)
	Fight.bannerMini:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	Fight.bannerMini:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	Fight.bannerMini:getAnimation():setSpeedScale(Fight.speed)
	Fight.shakeNode:addChild(Fight.bannerMini)
	Fight.bannerMini:setLocalZOrder(ZORDER_OF_BANNER)
	--manualBanner
	--Fight.manualBanner = ccs.Armature:create("BannerManual")
	--Fight.manualBanner:setScale(2)
	--Fight.manualBanner:setVisible(false)
	--Fight.manualBanner:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	--Fight.manualBanner:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	--Fight.manualBanner:getAnimation():setSpeedScale(Fight.speed)
	--Fight.shakeNode:addChild(Fight.manualBanner)
	--Fight.manualBanner:setLocalZOrder(ZORDER_OF_BANNER)
	--redBoxNode
	Fight.redBoxNode = ccs.Armature:create("RedBox")
	Fight.redBoxNode:setScale(2)
	Fight.redBoxNode:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	Fight.redBoxNode:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	Fight.shakeNode:addChild(Fight.redBoxNode)
	Fight.redBoxNode:setLocalZOrder(ZORDER_OF_REDBOX)
	Fight.redBoxNode:setPosition(320,568)
	Fight.redBoxNode:setVisible(false)
	--introNode
	Fight.introNode = ccs.Armature:create("action_renwu")
	--Fight.introNode:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	Fight.introNode:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	Fight.shakeNode:addChild(Fight.introNode)
	Fight.introNode:setLocalZOrder(ZORDER_OF_INTRO)
	Fight.introNode:setPosition(320,568)
	Fight.introNode:setVisible(false)
	--openNode
	Fight.openNode = ccs.Armature:create("Open")
	Fight.openNode:setVisible(true)
	Fight.openNode:setPosition(320,568)
	Fight.openNode:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	Fight.openNode:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	Fight.shakeNode:addChild(Fight.openNode)
	Fight.openNode:setLocalZOrder(ZORDER_OF_OPEN)
	--splashNode
	Fight.splashNode = ccs.Armature:create("ui_anim70")
	Fight.splashNode:setVisible(false)
	Fight.splashNode:setPosition(320,568)
	Fight.splashNode:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	Fight.splashNode:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	Fight.shakeNode:addChild(Fight.splashNode)
	Fight.splashNode:setLocalZOrder(ZORDER_OF_SPLASH)
	--pyroNodes
	Fight.pyroNodes={}
	for i = 1,12 do
		local pyroNode = ccs.Armature:create("pyro")
		pyroNode:setTag(i)
		pyroNode:setVisible(false)
		pyroNode:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
		pyroNode:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
		Fight.shakeNode:addChild(pyroNode)
		pyroNode:setLocalZOrder(ZORDER_OF_PYRO)
		pyroNode.particle = cc.ParticleSystemQuad:create("ani/pyro/wanshou_lizi.plist")
		pyroNode:getBone("lizi"):addDisplay(pyroNode.particle,0)
		Fight.pyroNodes[i] = pyroNode
	end
	--speedSprite
	Fight.speedSprite = ccui.Button:create()
	Fight.speedSprite:setAnchorPoint(0,0)
	Fight.speedSprite:setPosition(0,0)
	Fight.speedSprite:addTouchEventListener(function(button,type)
			if type == 2 then
				Fight.speedIdx = Fight.speedIdx + 1
				if Fight.speedIdx > 3 then
					Fight.speedIdx = 1
				end
				if Fight.speedIdx == 3 and not Fight.initData.allowSpeed3 then
					UIManager.showToast("主人，30级才开启3倍速度，一起努力修炼吧！")
				end
				Fight.speed = MAPPING_SPEEDS[Fight.speedIdx].speed
				Fight.updateFightSpeed(true)
			end
		end
	)
	Fight.scene:addChild(Fight.speedSprite)
	Fight.speedSprite:setLocalZOrder(ZORDER_OF_SPEED)
	--bottomBar
	--Fight.bottomBar = cc.Sprite:create("image/zhandou_di.png")
	--Fight.bottomBar:setAnchorPoint(0,0)
	--Fight.scene:addChild(Fight.bottomBar)
	--Fight.bottomBar:setLocalZOrder(ZORDER_OF_BOTTOM_BAR)
	--Fight.bottomBar:setVisible(false)
	--mySubstituteHead
	--Fight.mySubstituteHead = cc.Sprite:create()
	--Fight.mySubstituteHead:setVisible(false)
	--Fight.mySubstituteHead:setPosition(41,64)
	--Fight.scene:addChild(Fight.mySubstituteHead)
	--Fight.mySubstituteHead:setLocalZOrder(ZORDER_OF_SUBSTITUTE_HEAD)
	--mySubstituteCover
	--Fight.mySubstituteCover = cc.Sprite:create("image/zhandou_txk.png")
	--Fight.mySubstituteCover:setPosition(41,64)
	--Fight.scene:addChild(Fight.mySubstituteCover)
	--Fight.mySubstituteCover:setLocalZOrder(ZORDER_OF_SUBSTITUTE_COVER)
	--Fight.mySubstituteCover:setVisible(false)
	--mySubstituteSprite
	--Fight.mySubstituteSprite = cc.Sprite:create("image/zhandou_tibu.png")
	--Fight.mySubstituteSprite:setVisible(false)
	--Fight.mySubstituteSprite:setPosition(cc.vertex2F(40,16))
	--Fight.scene:addChild(Fight.mySubstituteSprite)
	--Fight.mySubstituteSprite:setLocalZOrder(ZORDER_OF_SUBSTITUTE_SPRITE)
	--skipFightBtn
	Fight.skipFightBtn = ccui.Button:create("image/zhandou_tiaoguo.png","image/zhandou_tiaoguo.png")
	Fight.skipFightBtn:addTouchEventListener(
		function(obj,type)
			if type == 2 then
				Fight.skipFightFlag = true
			end
		end
	)
	Fight.skipFightBtn:setVisible(false)
	Fight.skipFightBtn:setAnchorPoint(1,0)
	Fight.skipFightBtn:setPosition(640,0)
	Fight.scene:addChild(Fight.skipFightBtn)
	Fight.skipFightBtn:setLocalZOrder(ZORDER_OF_SKIP_FIGHT)
	--roundLabel
	Fight.roundLabel = cc.Label:createWithTTF("",dp.FONT,32)
	Fight.roundLabel:setAnchorPoint(1,1)
	Fight.roundLabel:setPosition(640,1126)
	Fight.scene:addChild(Fight.roundLabel)
	Fight.roundLabel:setLocalZOrder(ZORDER_OF_ROUND)
	--dialogLayer
	local node = cc.CSLoader:createNode("ui/ui_guide.csb"):getChildren()[1]
    node:setContentSize(display.size)
    ccui.Helper:doLayout(node)
	node:retain()
	node:removeSelf()
	Fight.dialogLayer = node
	Fight.dialogLayer:setVisible(false)
	Fight.dialogLayer:setTouchEnabled(false)
	Fight.dialogLayer:setLocalZOrder(ZORDER_OF_DIALOG)
	Fight.dialogLayer:addTouchEventListener(Fight.onScriptDialogTouch)
	Fight.scene:addChild(Fight.dialogLayer)
	Fight.dialogTop = ccui.Helper:seekNodeByName(Fight.dialogLayer,"image_di_red")
	Fight.dialogBottom = ccui.Helper:seekNodeByName(Fight.dialogLayer,"image_di_green")
	Fight.dialogHeadTop = Fight.dialogTop:getChildByName("image_card")
	Fight.dialogHeadBottom = Fight.dialogBottom:getChildByName("image_card")
	Fight.dialogDialogTop = Fight.dialogTop:getChildByName("image_talk")
	Fight.dialogDialogBottom = Fight.dialogBottom:getChildByName("image_talk")
	local dialogBorderTop = Fight.dialogTop:getChildByName("image_name")
	local dialogBorderBottom = Fight.dialogBottom:getChildByName("image_name")
	Fight.dialogNameTop = cc.FormatText:create(cc.size(1,0))
	Fight.dialogNameTop:setCascadeColorEnabled(true)
	Fight.dialogNameTop:setAnchorPoint(0.5,1)
	Fight.dialogNameTop:setPosition(16,210)
	      dialogBorderTop:addChild(Fight.dialogNameTop)
	Fight.dialogNameBottom = cc.FormatText:create(cc.size(1,0))
	Fight.dialogNameBottom:setCascadeColorEnabled(true)
	Fight.dialogNameBottom:setAnchorPoint(0.5,1)
	Fight.dialogNameBottom:setPosition(16,210)
	      dialogBorderBottom:addChild(Fight.dialogNameBottom)
	Fight.dialogTextTop = cc.FormatText:create(cc.size(240,0))
	Fight.dialogTextTop:setCascadeColorEnabled(true)
	Fight.dialogTextTop:setAnchorPoint(0.5,0.5)
	Fight.dialogTextTop:setPosition(210,110)
	Fight.dialogTextBottom = cc.FormatText:create(cc.size(240,0))
	Fight.dialogTextBottom:setCascadeColorEnabled(true)
	Fight.dialogTextBottom:setAnchorPoint(0.5,0.5)
	Fight.dialogTextBottom:setPosition(180,100)
	Fight.dialogDialogTop:addChild(Fight.dialogTextTop)
	Fight.dialogDialogBottom:addChild(Fight.dialogTextBottom)
	--startFight
	Fight.startFight = ccui.Button:create("image/kaishizhandou_a.png","image/kaishizhandou_b.png")
	Fight.startFight:addTouchEventListener(
		function(obj,type)
			if type == 2 then
				Fight.onEmbattleDone()
			end
		end
	)
	Fight.startFight:setVisible(false)
	Fight.startFight:setPosition(POSITIONS[2].x,(POSITIONS[4].y + POSITIONS[7].y)/2)
	Fight.shakeNode:addChild(Fight.startFight)
	Fight.startFight:setLocalZOrder(ZORDER_OF_EMBATTLE)
	--debugSpeedLabel
	Fight.debugSpeedLabel = cc.Label:createWithTTF("",dp.FONT,40)
	Fight.debugSpeedLabel:setAnchorPoint(cc.vertex2F(1,0))
	Fight.debugSpeedLabel:setPosition(640,550)
	Fight.debugSpeedLabel:setVisible(SHOW_DEBUG_BUTTONS)
	Fight.scene:addChild(Fight.debugSpeedLabel)
	Fight.debugSpeedLabel:setLocalZOrder(ZORDER_OF_SPEED)
	--debugButtons
	local buttonTexts = {"战斗","保存","加载","重播","减速","加速"}
	for i=1,6 do
		Fight["debugButton" .. i] = Fight.newButton(buttonTexts[i])
		Fight["debugButton" .. i]:setTag(i)
		Fight["debugButton" .. i]:setPosition(580,98+120+(6-i)*60)
		Fight.scene:addChild(Fight["debugButton" .. i])
		Fight["debugButton" .. i]:setVisible(true)
		Fight["debugButton" .. i]:setLocalZOrder(ZORDER_OF_BUTTONS)
	end
end

function Fight.doUnload()
	if not isResourcesLoaded then
		return
	end
	isResourcesLoaded = false
	Fight.speedIdx = 1
	Fight.speed    = 1
	Fight.scene:release()
	Fight.scene = nil
	Fight.shakeNode= nil
	Fight.bloodNodes=nil
	Fight.fighters = nil
	Fight.curtainNode    = nil
	Fight.fighterBanner  = nil
	--Fight.bannerIndicator = nil
	Fight.bannerMini     = nil
	--Fight.manualBanner   = nil
	Fight.redBoxNode     = nil
	Fight.introNode      = nil
	Fight.openNode       = nil
	Fight.splashNode     = nil
	Fight.pyroNodes      = nil
	Fight.speedSprite    = nil
	--Fight.bottomBar = nil
	--Fight.mySubstituteHead  = nil
	--Fight.mySubstituteCover = nil
	--Fight.mySubstituteSprite= nil
	Fight.skipFightBtn      = nil
	Fight.roundLabel        = nil
	Fight.dialogLayer       = nil
	Fight.dialogTop         = nil
	Fight.dialogBottom      = nil
	Fight.dialogHeadTop     = nil
	Fight.dialogHeadBottom  = nil
	Fight.dialogDialogTop   = nil
	Fight.dialogDialogBottom= nil
	Fight.dialogNameTop     = nil
	Fight.dialogNameBottom  = nil
	Fight.dialogTextTop     = nil
	Fight.dialogTextBottom  = nil
	Fight.startFight  = nil
	Fight.debugSpeedLabel = nil
	Fight.debugButton1 = nil
	Fight.debugButton2 = nil
	Fight.debugButton3 = nil
	Fight.debugButton4 = nil
	Fight.debugButton5 = nil
	Fight.debugButton6 = nil
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_FIGHTER) --Armatures
	for i = MISSILE_ID_MIN,MISSILE_ID_MAX do
		if cc.FileUtils:getInstance():isFileExist(PATH_JSON_MISSILES[i]) then --todo 某些资源暂时不存在
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_MISSILES[i])
		end
	end
	for i = EFFECT_ID_MIN,EFFECT_ID_MAX do
		if cc.FileUtils:getInstance():isFileExist(PATH_JSON_EFFECTS[i]) then --todo 某些资源暂时不存在
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_EFFECTS[i])
		end
	end
	for i = HALO_ID_MIN,HALO_ID_MAX do
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_HALOS[i])
	end
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_BANNER_FIGHTER)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_BANNER_MINI)
	--ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_BANNER_MANUAL)
	--ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_INDICATOR)
	for i = BLACKBASE_ID_MIN,BLACKBASE_ID_MAX do
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_BLACKBASES[i])
	end
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_REDBOX)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_INTRO)
	for i = PREPARE_ID_MIN,PREPARE_ID_MAX do
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_PREPARES[i])
	end
	for i = 1,BUFFER_TYPE_MAX do
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_BUFFERS[i])
	end
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_OPEN)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_SPLASH)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_PYRO)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_WING_LV1)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_WING_LV2)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(PATH_JSON_WING_LV3)
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/GongFang/Gongjia/Gongjia.ExportJson")
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/GongFang/Gongjian/Gongjian.ExportJson")
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/GongFang/Fangjia/Fangjia.ExportJson")
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/GongFang/Fangjian/Fangjian.ExportJson")
	--ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/Manual1/Manual1.ExportJson")
end

--计算战斗，战斗录像及结果保存在data.record、data.record.result中。
function Fight.calcFight(data,cb)
	local fightCalc = require"fightcalc"
	fightCalc.doInit(data)
	fightCalc.doFree()
	if cb then
		local result = data.result
		cb(result.isWin,result.fightIndex,result.bigRound,result.myDeaths,result.hpPercent,result.bossDamage,false,result.fightersHP,result.otherDamage)
	end
end

--设置出手扫描顺序
function Fight.resetPriorityMap()
	if Fight.initData.isSelfFirst then
		Fight.customPriorityMap = {4,7,5,8,6,9,1,10,2,11,3,12}
	else
		Fight.customPriorityMap = {7,4,8,5,9,6,10,1,11,2,12,3}
	end
end

function Fight.doInit(data,cb)
	if not ENABLE_PRELOAD then
		Fight.doPreload()
	end
	Fight.fighters[BOSS_POSITION]:setPosition(POSITIONS[BOSS_POSITION]) --Fix 12号位坐标错误的问题。
	Fight.isSpeed3Notified = false
	Fight.enableSoundEffect = dp.soundSwitch
	--setup data
	Fight.callback = cb
	Fight.initData = data
	Fight.randomseed = 0
	--todo remove
	if not Fight.initData then
		Fight.initData = FAKE_INIT_DATA
	end
	if not Fight.initData.bgImagePath0 then
		Fight.initData.bgImagePath0 = FAKE_INIT_DATA.bgImagePath0
	end
	if not Fight.initData.bgImagePath1 then
		Fight.initData.bgImagePath1 = FAKE_INIT_DATA.bgImagePath1
	end
	--设置最大回合数
	if Fight.initData.maxBigRound and Fight.initData.maxBigRound > 0 then --不做上限限制
		MAX_ROUND_LIMIT = Fight.initData.maxBigRound
	else
		MAX_ROUND_LIMIT = 30
	end
	--纠正speed
	if Fight.initData.allowSpeed3 then
		MAPPING_SPEEDS[3] = MAPPING_SPEEDS.bak
	else
		MAPPING_SPEEDS[3] = MAPPING_SPEEDS[2]
		if Fight.speedIdx == 3 then
			Fight.speedIdx = 2
		end
	end
	Fight.speed = MAPPING_SPEEDS[Fight.speedIdx].speed
	Fight.updateFightSpeed(true)
	--纠正数据
	if not Fight.initData.isPVE then --!!! PVP永远只有一场战斗
		Fight.initData.otherData[2] = nil
		Fight.initData.otherData[3] = nil
	end
	if not Fight.initData.myData.substitute then
		Fight.initData.myData.substitute = {}
	end
	--if not Fight.initData.myData.skillCards then
		Fight.initData.myData.skillCards = {}
	--end
	for i = 1,#Fight.initData.otherData do
		if not Fight.initData.otherData[i].substitute then
			Fight.initData.otherData[i].substitute = {}
		end
		--if not Fight.initData.otherData[i].skillCards then
			Fight.initData.otherData[i].skillCards = {}
		--end
	end
	if not Fight.initData.record then
		--calc
		--os.remove("../a.log")
		--os.remove("../c.log")
		local fightCalc = require"fightcalc"
		fightCalc.doInit(Fight.initData)
		fightCalc.doFree()
		--print(Fight.initData.result.isWin)
		--print(Fight.initData.result.fightIndex)
		--print(Fight.initData.result.bigRound)
		--print(Fight.initData.result.myDeaths)
		--print(Fight.initData.result.hpPercent)
		--print(Fight.initData.result.bossDamage)
		--os.rename("../a.log","../c.log")
	end
	Fight.resetPriorityMap()
	Fight.bloodNodes:removeAllChildren()
	--shakeRef
	Fight.shakeRef = 0
	Fight.shakeNode:scheduleUpdateWithPriorityLua(Fight.onUpdate,0)
	--bg
	if Fight.bgSprite ~= nil then --!!!清理上层未正确调用Fight.doFree时产生的节点泄漏。
		Fight.bgSprite:removeFromParent()
		Fight.bgSprite = nil
	end
	local bgImagePath0 = Fight.initData.bgImagePath0
	local bgImagePath1 = Fight.initData.bgImagePath1
	Fight.bgSprite = cc.Sprite:create(bgImagePath0)
    Fight.bgSprite:setEdgeFlag(dp.kEdgeFlagTop + dp.kEdgeFlagBottom)
	Fight.bgSprite:setAnchorPoint(0,0)
	Fight.shakeNode:addChild(Fight.bgSprite)
	Fight.bgSprite:setLocalZOrder(ZORDER_OF_BGNODE)
	local bgSpriteEx = cc.Sprite:create(bgImagePath0)
    bgSpriteEx:setEdgeFlag(dp.kEdgeFlagTop + dp.kEdgeFlagBottom)
	local bgSprite0Height = bgSpriteEx:getContentSize().height
	bgSpriteEx:setTag(1)
	bgSpriteEx:setAnchorPoint(0,0)
	bgSpriteEx:setPositionY(bgSprite0Height)
	Fight.bgSprite:addChild(bgSpriteEx)
	bgSpriteEx = cc.Sprite:create(bgImagePath0)
    bgSpriteEx:setEdgeFlag(dp.kEdgeFlagTop + dp.kEdgeFlagBottom)
	bgSpriteEx:setTag(2)
	bgSpriteEx:setAnchorPoint(0,0)
	bgSpriteEx:setPositionY(2 * bgSprite0Height)
	Fight.bgSprite:addChild(bgSpriteEx)
	local bgSpriteTop = cc.Sprite:create(bgImagePath1)
    bgSpriteTop:setEdgeFlag(dp.kEdgeFlagTop + dp.kEdgeFlagBottom)
	bgSpriteTop:setTag(3)
	bgSpriteTop:setAnchorPoint(0,1)
	bgSpriteTop:setPositionY(3 * bgSprite0Height)
	--Fix Rect
	local size = bgSpriteTop:getContentSize()
	bgSpriteEx:setTextureRect(cc.rect(0,size.height,size.width,bgSprite0Height-size.height))
	--Fix Rect
	Fight.bgSprite:addChild(bgSpriteTop)
	Fight.bgSprite:setPosition(0,-SHAKE_AMPLITUDE)
	Fight.bgSprite:setCascadeOpacityEnabled(true)
	Fight.walkDistance = (3 * bgSprite0Height - 1136 - 2*SHAKE_AMPLITUDE)/3
	--己方，主力
	for i = 1,6 do
		Fight.addCardActionArmatureFileInfo(Fight.initData.myData.mainForce[i])
	end
	--己方，替补
	for i = 1,3 do
		Fight.addCardActionArmatureFileInfo(Fight.initData.myData.substitute[i])
	end
	for j = 1,#Fight.initData.otherData do
		--敌方，主力
		for i = 1,6 do
			Fight.addCardActionArmatureFileInfo(Fight.initData.otherData[j].mainForce[i])
		end
		--敌方，替补
		for i = 1,3 do
			Fight.addCardActionArmatureFileInfo(Fight.initData.otherData[j].substitute[i])
		end
	end
	--脚本
	if Fight.initData.script then
		for i = 1,#Fight.initData.script do
			if Fight.initData.script[i].enter then
				Fight.addCardActionArmatureFileInfo(Fight.initData.script[i].enter.data)
			end
		end
	end
	--blackBaseNode
	Fight.blackBaseNode = nil
	--prepareNode
	Fight.prepareNodeB = nil
	Fight.prepareNodeF = nil
	--missileNodes
	Fight.missileNodes = {}
	--effectNodes
	Fight.effectNodes = {}
	--haloNodes
	Fight.haloNodes = {}
	--damages
	Fight.damages = {}
	--FIX_BUG_OF_GET_RANDOM
	Fight.FIX_BUG_OF_GET_RANDOM = {}

	--cc.Director:getInstance():pushScene(Fight.scene)
	Fight.onInitDone()
end

function Fight.onInitDone()
	Fight.debugButton1:setVisible(SHOW_DEBUG_BUTTONS and true)
	Fight.debugButton2:setVisible(SHOW_DEBUG_BUTTONS and false)
	Fight.debugButton3:setVisible(SHOW_DEBUG_BUTTONS and true)
	Fight.debugButton4:setVisible(SHOW_DEBUG_BUTTONS and false)
	Fight.debugButton5:setVisible(SHOW_DEBUG_BUTTONS and true)
	Fight.debugButton6:setVisible(SHOW_DEBUG_BUTTONS and true)
	if not SHOW_DEBUG_BUTTONS then
		Fight.fightIndex = 1
		Fight.doFight()
	end
end

function Fight.doFree()
	--!!! Dtor order
	--init in doScript -> onScriptDone
	Fight.isExtra  = false
	Fight.isEnter  = false
	Fight.isExit   = false
	Fight.roundSrc = nil
	Fight.roundSID = nil
	Fight.roundDie = false
	Fight.roundSkp = false
	Fight.isBurnt  = false
	Fight.isPoisoned=false
	Fight.isCursed = false
	Fight.act = nil
	Fight.sid = nil
	Fight.slv = nil
	Fight.src = nil
	Fight.tag = nil
	Fight.dst = nil
	Fight.timeLineCount = 0
	Fight.runType   = 0
	Fight.backupX = 0
	Fight.backupY = 0
	Fight.backupS = 0
	Fight.baseAtt = 0
	Fight.pyroAtt = 0
	Fight.permAtt = 0
	Fight.bufAAtt = 0
	Fight.bufDAtt = 0
	Fight.incrAtt = 0
	Fight.deadAtt = 0
	Fight.hphpAtt = 0
	Fight.buffAtt = 0
	--init in doFight
	Fight.isReplay = false
	Fight.skipFightFlag = false
	Fight.isAutomatic = false
	Fight.recordRandomIdx = 0
	Fight.recordManualIdx = 1
	Fight.recordMMMMMMIdx = 1
	Fight.mySubstituteIdx = 0
	Fight.otherSubstituteIdx = 0
	Fight.manualDisabled  = true
	Fight.mySkillCardsOrder = nil
	Fight.otherSkillCardsOrder = nil
	Fight.myDeaths   = 0
	Fight.otherDeaths= 0
	Fight.fightIndex = 1
	Fight.roundOrigin= 0
	Fight.roundIndex = 0
	Fight.bigRound   = 0
	Fight.scriptIndex= 1
	Fight.scriptLastDialogRoundIndex = -1
	Fight.actionIndex= 0
	Fight.actionHead = nil
	Fight.embattleDragPos = nil
	Fight.embattleOffsetX = 0
	Fight.embattleOffsetY = 0
	Fight.missileType     = nil
	Fight.myPowerReduction    = nil
	Fight.otherPowerReduction = nil
	--init in doInit
	--己方，主力
	for i = 1,6 do
		Fight.removeCardActionArmatureFileInfo(Fight.initData.myData.mainForce[i])
	end
	--己方，替补
	for i = 1,3 do
		Fight.removeCardActionArmatureFileInfo(Fight.initData.myData.substitute[i])
	end
	for j = 1,#Fight.initData.otherData do
		--敌方，主力
		for i = 1,6 do
			Fight.removeCardActionArmatureFileInfo(Fight.initData.otherData[j].mainForce[i])
		end
		--敌方，替补
		for i = 1,3 do
			Fight.removeCardActionArmatureFileInfo(Fight.initData.otherData[j].substitute[i])
		end
	end
	--脚本
	if Fight.initData.script then
		for i = 1,#Fight.initData.script do
			if Fight.initData.script[i].enter then
				Fight.removeCardActionArmatureFileInfo(Fight.initData.script[i].enter.data)
			end
		end
	end
	--Fight.isSpeed3Notified = false
	--Fight.enableSoundEffect = true
	Fight.callback = nil
	Fight.initData = nil
	Fight.randomseed = 0
	Fight.customPriorityMap = nil
	Fight.bloodNodes:removeAllChildren()
	Fight.shakeNode:unscheduleUpdate()
	Fight.shakeRef = 0
	Fight.bgSprite:removeFromParent()
	Fight.bgSprite = nil
	Fight.walkDistance = nil
	Fight.blackBaseNode = nil
	Fight.prepareNodeB  = nil
	Fight.prepareNodeF  = nil
	Fight.missileNodes  = nil
	Fight.effectNodes   = nil
	Fight.haloNodes     = nil
	Fight.damages       = nil
	Fight.FIX_BUG_OF_GET_RANDOM = nil
	--
	Fight.onFreeDone()
end

function Fight.onFreeDone()
	if not ENABLE_PRELOAD then
		Fight.doUnload()
	end
	--cc.Director:getInstance():popScene()
end

function Fight.doFight()
	if Fight.fightIndex == 1 then --第一场战斗
		Fight.bgSprite:setPosition(0,-SHAKE_AMPLITUDE)
		Fight.roundLabel:setString("回合：1/" .. MAX_ROUND_LIMIT)
		--己方
		for i = 1,6 do
			local pos = (i < 4) and (i + 3) or (i - 3)
			local fer = Fight.fighters[pos]
			local fst = Fight.initData.myData.mainForce[i]
			fer:setVisible(fst ~= nil)
			if fst then
				fer:setReady(true)
				Fight.setFighterProperties(pos,fst)
				Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
			end
		end
		--敌方
		for i = 1,6 do
			local pos = i + 6
			local fer = Fight.fighters[pos]
			local fst = Fight.initData.otherData[Fight.fightIndex].mainForce[i]
			fer:setVisible(fst ~= nil)
			if Fight.initData.isPVE then
				fer:setPositionY(POSITIONS[pos].y+Fight.walkDistance)
			end
			if fst then
				fer:setReady(true)
				Fight.setFighterProperties(pos,fst)
				Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
			end
		end
		if Fight.initData.isBoss then --Boss战设置
			local fer = Fight.fighters[BOSS_POSITION]
			fer:setPosition(POSITIONS[2].x,(POSITIONS[8].y+POSITIONS[11].y)/2+Fight.walkDistance)
			fer:setScale(BOSS_SCALE)
			fer:setHPVisible(false)
		end
		if Fight.initData.record then
			Fight.isReplay = true
		else
			Fight.isReplay = false
			Fight.initData.record = {randomNum = {},manualAct = {},mmmmmmAct = {},swapPos = {{},{},{}}}
		end
		Fight.skipFightFlag = false
		Fight.isAutomatic = false
		Fight.recordRandomIdx = 0
		Fight.recordManualIdx = 1
		Fight.recordMMMMMMIdx = 1
		Fight.mySubstituteIdx = 0
		Fight.otherSubstituteIdx = 0
		Fight.manualDisabled = true
		Fight.mySkillCardsOrder = {}
		for i = 1,#Fight.initData.myData.skillCards do
			Fight.mySkillCardsOrder[i] = MySkillCard.create(i)
		end
		if not Fight.initData.isPVE then
			Fight.otherSkillCardsOrder = {}
			for i = 1,#Fight.initData.otherData[1].skillCards do
				Fight.otherSkillCardsOrder[i] = OtherSkillCard.create(i)
			end
		end
		Fight.myDeaths    = 0
		Fight.otherDeaths = 0
		Fight.fightIndex  = 1
		Fight.roundOrigin = 0
		Fight.roundIndex  = 0
		Fight.scriptLastDialogRoundIndex = -1
		Fight.bigRound    = 0
		Fight.scriptIndex = 1
		Fight.actionIndex = 0
		Fight.clearActions()
		--Fight.mySubstituteSprite:setVisible(false)
		Fight.updateMySubstitute()
	else --非第一场战斗
		--敌方
		for i = 1,6 do
			local pos = i + 6
			local fer = Fight.fighters[pos]
			local fst = Fight.initData.otherData[Fight.fightIndex].mainForce[i]
			fer:setVisible(fst ~= nil)
			if Fight.initData.isPVE then
				fer:setPositionY(POSITIONS[pos].y+Fight.walkDistance)
			end
			if fst then
				fer:setReady(true)
				Fight.setFighterProperties(pos,fst)
				Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
			end
		end
		Fight.otherSubstituteIdx = 0
		Fight.roundOrigin = Fight.roundIndex
	end
	Fight.myPowerReduction = 0
	Fight.otherPowerReduction = 0
	if not Fight.initData.isPVE then
		local myPower = Fight.initData.myData.power
		local otherPower = Fight.initData.otherData[Fight.fightIndex].power
		if myPower and myPower>1000000 and otherPower and otherPower>1000000 then
			local percent
			if myPower > otherPower then
				percent = otherPower/myPower
				if percent < POWER_MIN then
					Fight.myPowerReduction = POWER_HIGH
				elseif percent < POWER_MAX then
					Fight.myPowerReduction = POWER_BASE+POWER_MAX-percent
				end
			else
				percent = myPower/otherPower
				if percent < POWER_MIN then
					Fight.otherPowerReduction = POWER_HIGH
				elseif percent < POWER_MAX then
					Fight.otherPowerReduction = POWER_BASE+POWER_MAX-percent
				end
			end
		end
	end
	Fight.resetLimited()
	Fight.isExtra = false
	Fight.doOpen()
end

function Fight.onFightDone()
	Fight.debugButton1:setVisible(SHOW_DEBUG_BUTTONS and false)
	Fight.debugButton2:setVisible(SHOW_DEBUG_BUTTONS and true)
	Fight.debugButton3:setVisible(SHOW_DEBUG_BUTTONS and true)
	Fight.debugButton4:setVisible(SHOW_DEBUG_BUTTONS and true)
	Fight.debugButton5:setVisible(SHOW_DEBUG_BUTTONS and true)
	Fight.debugButton6:setVisible(SHOW_DEBUG_BUTTONS and true)
	local result = Fight.initData.result
	cclog("FightResult:" .. (result.isWin and "Won" or "Lost"))
	cclog("WhichFight: " .. result.fightIndex)
	cclog("BigRound:   " .. result.bigRound)
	cclog("MyDeaths:   " .. result.myDeaths)
	cclog("HPPercent:  " .. result.hpPercent)
	cclog("每个血值:  ")
	cclog("SkipFight:  " .. (Fight.skipFightFlag and "true" or "false"))
	cclog("bossDamage: " .. result.bossDamage)
	if Fight.callback then
		--!!!篡改数据
		--result.isWin = true
		--result.fightIndex = 1
		--result.bigRound = 1
		--result.myDeaths = 0
		--result.hpPercent = 1
		--result.bossDamage = 100000000
		--!!!防止战斗结果数据被修改。
		local fc        = require"fightcalc"
		local hpPercent = tostring(result.hpPercent):gsub("%.","")
		local isEqual = true
		isEqual = isEqual and fc.isEncodedNumberEqual(result.hash.isWin      ,fc.encodeNumber(result.isWin and 23987239 or 314587676))
		isEqual = isEqual and fc.isEncodedNumberEqual(result.hash.fightIndex ,fc.encodeNumber(result.fightIndex))
		isEqual = isEqual and fc.isEncodedNumberEqual(result.hash.bigRound   ,fc.encodeNumber(result.bigRound))
		isEqual = isEqual and fc.isEncodedNumberEqual(result.hash.myDeaths   ,fc.encodeNumber(result.myDeaths))
		isEqual = isEqual and fc.isEncodedNumberEqual(result.hash.hpPercent  ,fc.encodeNumber(tonumber(hpPercent)))
		isEqual = isEqual and fc.isEncodedNumberEqual(result.hash.bossDamage ,fc.encodeNumber(result.bossDamage))
		isEqual = isEqual and fc.isEncodedNumberEqual(result.hash.otherDamage,fc.encodeNumber(result.otherDamage))
		if not isEqual then
			result.isWin = false
			result.fightIndex = 1
			result.bigRound = MAX_ROUND_LIMIT
			result.myDeaths = 9
			result.hpPercent = 0
			result.bossDamage = 0
			result.otherDamage = 0
			cclog("	FightResult:" .. (result.isWin and "Won" or "Lost"))
			cclog("	WhichFight: " .. result.fightIndex)
			cclog("	BigRound:   " .. result.bigRound)
			cclog("	MyDeaths:   " .. result.myDeaths)
			cclog("	HPPercent:  " .. result.hpPercent)
			cclog("每个血值:  ")
			cclog("	SkipFight:  " .. (Fight.skipFightFlag and "true" or "false"))
			cclog("	bossDamage: " .. result.bossDamage)
			cclog("otherDamage: " .. result.otherDamage)
		end
		Fight.callback(result.isWin,result.fightIndex,result.bigRound,result.myDeaths,result.hpPercent,result.bossDamage,Fight.skipFightFlag,result.fightersHP,result.otherDamage)
	end
end

function Fight.onButton(button,type)
	if type == 2 then
		if button:getTag() == 1 then
			Fight.fightIndex = 1
			Fight.doFight()
			Fight.debugButton1:setVisible(SHOW_DEBUG_BUTTONS and false)
			Fight.debugButton2:setVisible(SHOW_DEBUG_BUTTONS and false)
			Fight.debugButton3:setVisible(SHOW_DEBUG_BUTTONS and false)
			Fight.debugButton4:setVisible(SHOW_DEBUG_BUTTONS and false)
			Fight.debugButton5:setVisible(SHOW_DEBUG_BUTTONS and true)
			Fight.debugButton6:setVisible(SHOW_DEBUG_BUTTONS and true)
		elseif button:getTag() == 2 then
			Fight.saveVideo()
		elseif button:getTag() == 3 then
			Fight.loadVideo()
		elseif button:getTag() == 4 then
			os.remove("../__.log")
			os.rename("../a.log","../__.log")
			Fight.fightIndex = 1
			Fight.doFight()
			Fight.debugButton1:setVisible(SHOW_DEBUG_BUTTONS and false)
			Fight.debugButton2:setVisible(SHOW_DEBUG_BUTTONS and false)
			Fight.debugButton3:setVisible(SHOW_DEBUG_BUTTONS and false)
			Fight.debugButton4:setVisible(SHOW_DEBUG_BUTTONS and false)
			Fight.debugButton5:setVisible(SHOW_DEBUG_BUTTONS and true)
			Fight.debugButton6:setVisible(SHOW_DEBUG_BUTTONS and true)
		elseif button:getTag() == 5 then
			Fight.speed = Fight.speed/2
			Fight.updateFightSpeed(false)
		elseif button:getTag() == 6 then
			Fight.speed = Fight.speed*2
			Fight.updateFightSpeed(false)
		end
	end
end

function Fight.newButton(text)
	local btn = ccui.Button:create("image/fight_debug_button.png")
	btn:setTouchEnabled(true)
	btn:addTouchEventListener(Fight.onButton)
	if text then
		btn:setTitleText(text)
		btn:setTitleFontSize(50)
	end
	return btn
end

--是否大回合结束
function Fight.isBigRoundOver()
	for i = 1,#Fight.customPriorityMap do
		local fer = Fight.fighters[Fight.customPriorityMap[i]]
		if fer:isVisible() and fer:isReady() then
			return false
		end
	end
	return true
end

--获取本回合主动方,存储于Fight.src变量
function Fight.getSrc()
	if Fight.isBigRoundOver() then
		for i = 1,12 do
			Fight.fighters[i]:setReady(true)
		end
	end
	for i = 1,#Fight.customPriorityMap do
		local src = Fight.fighters[Fight.customPriorityMap[i]]
		if src:isVisible() and src:isReady() then
			src:setReady(false)
			Fight.src = Fight.customPriorityMap[i]
			return
		end
	end
end

--获取本回合被动方,存储于Fight.dst变量
function Fight.getDst()
	Fight.dst = {}
	--从指定表中随机n个
	local function randomOfTable(teamAll,count)
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[i]
			end
		end
		if #Fight.dst > count then --减少至指定个数
			repeat
				table.remove(Fight.dst,Fight.random(0,1,#Fight.dst))
			until #Fight.dst <= count
		end
	end
	--switch
	if SkillManager[Fight.sid].target == SkillManager_OWN_RANDOM_3 then --己方随机3个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({4,5,6,1,2,3}	,3)
		else
			randomOfTable({7,8,9,10,11,12}	,3)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_RANDOM_2 then --己方随机2个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({4,5,6,1,2,3}	,2)
		else
			randomOfTable({7,8,9,10,11,12}	,2)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_RANDOM_1 then --己方随机1个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({4,5,6,1,2,3}	,1)
		else
			randomOfTable({7,8,9,10,11,12}	,1)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_OTHER then --己方除自己
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_OWN_OTHER")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_OWN_OTHER")
		local teamAll
		if Fight.src < 7 then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		for i=1,6 do
			if teamAll[i] ~= Fight.src and Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[i]
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_100 then --己方血量百分比最大
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		local strongIndex = nil
		local strongPercent = 0
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				local percent = Fight.fighters[teamAll[i]]:getHP()/Fight.fighters[teamAll[i]]:getHPMax()
				if percent > strongPercent then
					strongIndex = i
					strongPercent = percent
				end
			end
		end
		if strongIndex then
			Fight.dst = {teamAll[strongIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_0 then --己方血量百分比最小
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		local weakIndex = nil
		local weakPercent = 2
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				local percent = Fight.fighters[teamAll[i]]:getHP()/Fight.fighters[teamAll[i]]:getHPMax()
				if percent < weakPercent then
					weakIndex = i
					weakPercent = percent
				end
			end
		end
		if weakIndex then
			Fight.dst = {teamAll[weakIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_STRONG then --己方最强
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		local strongIndex = nil
		local strongHP = 0
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				if Fight.fighters[teamAll[i]]:getHP() > strongHP then
					strongIndex = i
					strongHP = Fight.fighters[teamAll[i]]:getHP()
				end
			end
		end
		if strongIndex then
			Fight.dst = {teamAll[strongIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_WEAK then --己方最弱
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		local weakIndex = nil
		local weakHP = 99999999999999999999999999999999
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				if Fight.fighters[teamAll[i]]:getHP() < weakHP then
					weakIndex = i
					weakHP = Fight.fighters[teamAll[i]]:getHP()
				end
			end
		end
		if weakIndex then
			Fight.dst = {teamAll[weakIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_SELF then --己方自己
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_OWN_SELF")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_OWN_SELF")
		if Fight.fighters[Fight.src]:isVisible() and not Fight.fighters[Fight.src]:isDead() then
			Fight.dst = {Fight.src}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_ALL then --己方所有((等同随机6个))
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({4,5,6,1,2,3}	,6)
		else
			randomOfTable({7,8,9,10,11,12}	,6)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_FRONT then --单体前排
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_SINGLE_FRONT")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_SINGLE_FRONT")
		local teamAll
		local col = math.floor((Fight.src-1)%3)+1
		if Fight.src < 7 then
				if col == 1 then teamAll = {7,8,9,10,11,12}
			elseif col == 2 then teamAll = {8,7,9,11,10,12}
			elseif col == 3 then teamAll = {9,8,7,12,11,10}
			end
		else
				if col == 1 then teamAll = {4,5,6,1,2,3}
			elseif col == 2 then teamAll = {5,4,6,2,1,3}
			elseif col == 3 then teamAll = {6,5,4,3,2,1}
			end
		end
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst = {teamAll[i]}
				break
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_BACK then --单体后排
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_SINGLE_BACK")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_SINGLE_BACK")
		local teamAll
		local col = math.floor((Fight.src-1)%3)+1
		if Fight.src < 7 then
				if col == 1 then teamAll = {10,11,12,7,8,9}
			elseif col == 2 then teamAll = {11,10,12,8,7,9}
			elseif col == 3 then teamAll = {12,11,10,9,8,7}
			end
		else
				if col == 1 then teamAll = {1,2,3,4,5,6}
			elseif col == 2 then teamAll = {2,1,3,5,4,6}
			elseif col == 3 then teamAll = {3,2,1,6,5,4}
			end
		end
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst = {teamAll[i]}
				break
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_WEAK then --单体最弱
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		local weakIndex
		local weakHP = 99999999999999999999999999999999
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				if Fight.fighters[teamAll[i]]:getHP() < weakHP then
					weakIndex = i
					weakHP = Fight.fighters[teamAll[i]]:getHP()
				end
			end
		end
		if weakIndex then
			Fight.dst = {teamAll[weakIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_STRONG then --单体最强
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		local strongIndex
		local strongHP = 0
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				if Fight.fighters[teamAll[i]]:getHP() > strongHP then
					strongIndex = i
					strongHP = Fight.fighters[teamAll[i]]:getHP()
				end
			end
		end
		if strongIndex then
			Fight.dst = {teamAll[strongIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_0 then --单体血量百分比最小
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		local weakIndex
		local weakPercent = 2
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				local percent = Fight.fighters[teamAll[i]]:getHP()/Fight.fighters[teamAll[i]]:getHPMax()
				if percent < weakPercent then
					weakIndex = i
					weakPercent = percent
				end
			end
		end
		if weakIndex then
			Fight.dst = {teamAll[weakIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_100 then --单体血量百分比最大
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		local strongIndex
		local strongPercent = 0
		for i=1,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				local percent = Fight.fighters[teamAll[i]]:getHP()/Fight.fighters[teamAll[i]]:getHPMax()
				if percent > strongPercent then
					strongIndex = i
					strongPercent = percent
				end
			end
		end
		if strongIndex then
			Fight.dst = {teamAll[strongIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_COUNTER then --单体反击
		assert(Fight.act == ACT_COUNTER,"Only ACT_COUNTER can select target: SkillManager_SINGLE_COUNTER")
		if Fight.fighters[Fight.roundSrc]:isVisible() and not Fight.fighters[Fight.roundSrc]:isDead() then
			Fight.dst = {Fight.roundSrc}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_ROW_1 then --前排
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		for i=1,3 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[i]
			end
		end
		if #Fight.dst == 0 then
			for i=4,6 do
				if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
					Fight.dst[#Fight.dst+1] = teamAll[i]
				end
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_ROW_2 then --后排
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		for i=4,6 do
			if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[i]
			end
		end
		if #Fight.dst == 0 then
			for i=1,3 do
				if Fight.fighters[teamAll[i]]:isVisible() and not Fight.fighters[teamAll[i]]:isDead() then
					Fight.dst[#Fight.dst+1] = teamAll[i]
				end
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_COLS  then --本列
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_MULTI_COLS")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_MULTI_COLS")
		local teamAll
		local col = math.floor((Fight.src-1)%3)+1
		if Fight.src < 7 then
				if col == 1 then teamAll = {7,10,8,11,9,12}
			elseif col == 2 then teamAll = {8,11,7,10,9,12}
			elseif col == 3 then teamAll = {9,12,8,11,7,10}
			end
		else
				if col == 1 then teamAll = {4,1,5,2,6,3}
			elseif col == 2 then teamAll = {5,2,4,1,6,3}
			elseif col == 3 then teamAll = {6,3,5,2,4,1}
			end
		end
		for i=1,3 do
			if Fight.fighters[teamAll[2*i-1]]:isVisible() and not Fight.fighters[teamAll[2*i-1]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[2*i-1]
			end
			if Fight.fighters[teamAll[2*i-0]]:isVisible() and not Fight.fighters[teamAll[2*i-0]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[2*i-0]
			end
			if #Fight.dst ~= 0 then
				break
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_1 then --随机1个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,1)
		else
			randomOfTable({4,5,6,1,2,3}	,1)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_2 then --随机2个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,2)
		else
			randomOfTable({4,5,6,1,2,3}	,2)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_3 then --随机3个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,3)
		else
			randomOfTable({4,5,6,1,2,3}	,3)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_4 then --随机4个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,4)
		else
			randomOfTable({4,5,6,1,2,3}	,4)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_5 then --随机5个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,5)
		else
			randomOfTable({4,5,6,1,2,3}	,5)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_ALL then --全体(等同随机6个)
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,6)
		else
			randomOfTable({4,5,6,1,2,3}	,6)
		end
	end
end

--返回值：
--		是否需要run
--		run的位置
function Fight.getRunAndPosition()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		return 0,nil
	end
	if SkillManager[Fight.sid].regeFunc or SkillManager[Fight.sid].clearFunc then
		return 0,nil
	end
	local x,y
	local dst = Fight.dst[1]
	local skill = SkillManager[Fight.sid]
	if skill.runType == 1 then
		if skill.target == SkillManager_SINGLE_FRONT then
			x = Fight.fighters[dst]:getPositionX()
			y = Fight.fighters[dst]:getPositionY() + (dst < 7 and FACE_DISTANCE or -FACE_DISTANCE)
			return skill.runType,{x=x,y=y}
		elseif skill.target == SkillManager_MULTI_ROW_1 then
			x = 320
			y = Fight.fighters[dst]:getPositionY() + (dst < 7 and FACE_DISTANCE or -FACE_DISTANCE)
			return skill.runType,{x=x,y=y}
		elseif skill.target == SkillManager_MULTI_COLS then
			x = Fight.fighters[dst]:getPositionX()
			y = dst < 7 and Fight.fighters[4]:getPositionY()+FACE_DISTANCE or Fight.fighters[7]:getPositionY()-FACE_DISTANCE
			return skill.runType,{x=x,y=y}
		elseif skill.target == SkillManager_MULTI_ALL then
			x = 320
			y = dst < 7 and Fight.fighters[4]:getPositionY()+FACE_DISTANCE or Fight.fighters[7]:getPositionY()-FACE_DISTANCE
			return skill.runType,{x=x,y=y}
		end
	elseif skill.runType == 2 then
		if skill.target == SkillManager_SINGLE_FRONT
				or skill.target == SkillManager_SINGLE_BACK
				or skill.target == SkillManager_SINGLE_WEAK
				or skill.target == SkillManager_SINGLE_STRONG
				or skill.target == SkillManager_SINGLE_COUNTER
				or skill.target == SkillManager_MULTI_RANDOM_1 then
			x = Fight.fighters[dst]:getPositionX()
			y = Fight.fighters[dst]:getPositionY()
			return skill.runType,{x=x,y=y}
		end
	elseif skill.runType == 3 or skill.runType == 4 then
		x = 320
		y = dst < 7 and (POSITIONS[8].y + POSITIONS[11].y)/2 or POSITIONS[5].y
		return skill.runType,{x=x,y=y}
	end
	return 0,nil
end

--开场开始
function Fight.doOpen()
	Fight.skipFightBtn:setVisible(false)
	if Fight.fightIndex == 1 then
		Fight.openNode:setVisible(true)
		Fight.openNode:getAnimation():setSpeedScale(1)
		Fight.openNode:getAnimation():playWithIndex(0,-1,0)
	else
		Fight.onOpenDone()
	end
end

--开场完成
function Fight.onOpenDone()
	Fight.openNode:setVisible(false)
	Fight.doWalk()
end

--前进开始
function Fight.doWalk()
	if Fight.initData.isPVE then
		for i = 1,6 do
			local fer = Fight.fighters[i]
			if fer:isVisible() and not fer:isDead() then
				Fight.setFighterAnimation(i,ANIMATION_WALK,true)
			end
		end
		for i = 7,12 do
			Fight.fighters[i]:runAction(cc.MoveBy:create(TIME_WALK/Fight.speed,{x=0,y=-Fight.walkDistance}))
		end
		Fight.bgSprite:runAction(
			cc.Sequence:create(
				cc.MoveBy:create(TIME_WALK/Fight.speed,{x=0,y=-Fight.walkDistance}),
				cc.CallFunc:create(function()Fight.onWalkDone()end)
			)
		)
	else
		Fight.onWalkDone()
	end
end

--前进完成
function Fight.onWalkDone()
	if Fight.initData.isPVE then
		for i = 1,6 do
			local fer = Fight.fighters[i]
			if fer:isVisible() and not fer:isDead() then
				Fight.setFighterAnimation(i,ANIMATION_STAND,true)
			end
		end
	end
	Fight.doEmbattle()
end

function Fight.doEmbattle()
	if Fight.initData.isPVE then
		if Fight.isReplay then
			local swapTable = Fight.initData.record.swapPos[Fight.fightIndex]
			for i = 1,#swapTable do
				Fight.swapFighter(swapTable[i][1],swapTable[i][2])
			end
			Fight.onEmbattleDone()
		elseif Fight.initData.skipEmbattle or Fight.isAutomatic then
			Fight.onEmbattleDone()
		else
			Fight.scene:setTouchEnabled(true)
			Fight.startFight:setVisible(true)
		end
	else
		Fight.onEmbattleDone()
	end
end

function Fight.onEmbattleDone()
	if Fight.initData.isPVE then
		if Fight.isReplay then
		else
			Fight.scene:setTouchEnabled(false)
			Fight.startFight:setVisible(false)
		end
		for i = 1,6 do
			Fight.fighters[i]:setReady(true)
		end
	end
	Fight.skipFightBtn:setVisible(Fight.initData.allowSkipFight)
	Fight.doSplash()
end

function Fight.doSplash()
	if not Fight.initData.script and Fight.fightIndex == 1 then
		Fight.splashNode:setVisible(true)
		Fight.splashNode:getAnimation():setSpeedScale(1.5)
		Fight.splashNode:getAnimation():playWithIndex(0,-1,0)
	else
		Fight.onSplashDone()
	end
end

function Fight.onSplashDone()
	Fight.splashNode:setVisible(false)
	Fight.doPyrosPreFight()
end

function Fight.getPyrosPreFight(pos)
	local fer = Fight.fighters[pos]
	local pyroTable = {}
	if fer:isVisible() and not fer:isDead() then
		local pyroLV
		pyroLV = fer:getPyroWanShouLingYan()   ; if pyroLV == PYRO_STATE_BERSERK then table.insert(pyroTable,PYRO_WanShouLingYan) end
		pyroLV = fer:getPyroGuLingLengHuo()    ; if pyroLV == PYRO_STATE_BERSERK then table.insert(pyroTable,PYRO_GuLingLengHuo) end
		pyroLV = fer:getPyroSanQianYanYanHuo() ; if pyroLV == PYRO_STATE_BERSERK then table.insert(pyroTable,PYRO_SanQianYanYanHuo) end
		pyroLV = fer:getPyroJiuYouJinZuHuo()   ; if pyroLV == PYRO_STATE_BERSERK then table.insert(pyroTable,PYRO_JiuYouJinZuHuo) end
		pyroLV = fer:getPyroDiYan()            ; if pyroLV == PYRO_STATE_BERSERK then table.insert(pyroTable,PYRO_DiYan) end
	end
	return pyroTable
end

--异火列表开始
function Fight.doPyro(pos,callback,pyrosTable)
	local pyroNode = Fight.pyroNodes[pos]
	if callback and pyrosTable then
		pyroNode.callback = callback
		pyroNode.pyrosTable = pyrosTable
	end
	local pyroItem = pyroNode.pyrosTable[#pyroNode.pyrosTable]
	local pyroID   = pyroItem.id
	local pyroColor= pyroItem.color
	pyroNode.particle:resetSystem()
	pyroNode.particle:setStartColor(pyroColor)
	pyroNode.particle:setStartColorVar(pyroColor)
	pyroNode.particle:setEndColor(pyroColor)
	pyroNode.particle:setEndColorVar(pyroColor)
	pyroNode:setVisible(true)
	pyroNode:setPosition(Fight.fighters[pos]:getPosition())
	local pngPath = "image/fireImage/" .. DictUI[tostring(DictYFire[tostring(pyroID)].bigUiId)].fileName
	pyroNode:getBone("yihuo"):addDisplay(ccs.Skin:create(pngPath),0)
	pyroNode:getAnimation():setSpeedScale(Fight.speed/4.8)
	pyroNode:getAnimation():playWithIndex(0,-1,0)
end

--异火列表完成
function Fight.onPyroDone(pos)
	local pyroNode = Fight.pyroNodes[pos]
	local pyroItem = table.remove(pyroNode.pyrosTable)
	pyroNode.particle:stopSystem()
	if #pyroNode.pyrosTable > 0 then
		Fight.doPyro(pos)
	else
		pyroNode:setVisible(false)
		local callback = pyroNode.callback
		pyroNode.callback = nil
		pyroNode.pyrosTable = nil
		callback(pos)
	end
end

--战斗前异火开始
function Fight.doPyrosPreFight()
	if Fight.fightIndex == 1 then
		local pyrosTimeLineCount = 1 --测试性调用
		local function callOnPyroAllDone(pos) --pos为0时为测试性调用
			pyrosTimeLineCount = pyrosTimeLineCount - 1
			if pyrosTimeLineCount == 0 then
				Fight.onPyrosPreFightDone()
			end
		end
		for i = 1,12 do
			local pyroTable = Fight.getPyrosPreFight(i)
			if #pyroTable > 0 then
				pyrosTimeLineCount = pyrosTimeLineCount + 1
				Fight.doPyro(i,callOnPyroAllDone,pyroTable)
			end
		end
		callOnPyroAllDone(0) --测试性调用
	else
		Fight.onPyrosPreFightDone()
	end
end

--战斗前异火完成
function Fight.onPyrosPreFightDone()
	Fight.doScript()
end

function Fight.swapFighter(posSrc,posDst)
	local src = Fight.fighters[posSrc]
	local dst = Fight.fighters[posDst]
	src:setTag(posDst)
	src:setPosition(POSITIONS[posDst])
	Fight.fighters[posDst] = src
	dst:setTag(posSrc)
	dst:setPosition(POSITIONS[posSrc])
	Fight.fighters[posSrc] = dst
end

function Fight.onEmbattleTouch(type,pos)
	local touchX,touchY,id = pos[1],pos[2],pos[3]
	if id ~= 0 then --只支持单点
		return
	end
	local halfRowSpacing = (POSITIONS[4].y - POSITIONS[1].y)/2
	local halfColSpacing = (POSITIONS[2].x - POSITIONS[1].x)/2
	if type=="began" then
		Fight.embattleDragPos = nil
		for i = 1,6 do
			local fer = Fight.fighters[i]
			if fer:isVisible() and POSITIONS[i].x - halfColSpacing < touchX and touchX < POSITIONS[i].x + halfColSpacing and POSITIONS[i].y - halfRowSpacing < touchY and touchY < POSITIONS[i].y + halfRowSpacing then
				fer:setLocalZOrder(ZORDER_OF_FIGHTER_ACTIVE)
				Fight.embattleOffsetX = touchX - POSITIONS[i].x
				Fight.embattleOffsetY = touchY - POSITIONS[i].y
				Fight.embattleDragPos = i
				break
			end
		end
	elseif type=="moved" then
		if Fight.embattleDragPos then
			Fight.fighters[Fight.embattleDragPos]:setPosition(touchX - Fight.embattleOffsetX,touchY - Fight.embattleOffsetY)
		end
	elseif type=="ended" then
		if Fight.embattleDragPos then
			local fer = Fight.fighters[Fight.embattleDragPos]
			local swapped = false
			for i = 1,6 do
				if POSITIONS[i].x - halfColSpacing < touchX and touchX < POSITIONS[i].x + halfColSpacing and POSITIONS[i].y - halfRowSpacing < touchY and touchY < POSITIONS[i].y + halfRowSpacing then
					if Fight.embattleDragPos ~= i then
						Fight.swapFighter(Fight.embattleDragPos,i)
						local swapTable = Fight.initData.record.swapPos[Fight.fightIndex]
						swapTable[#swapTable + 1] = {Fight.embattleDragPos,i}
						swapped = true
					end
					break
				end
			end
			if not swapped then
				fer:setPosition(POSITIONS[Fight.embattleDragPos].x,POSITIONS[Fight.embattleDragPos].y)
			end
			fer:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - Fight.embattleDragPos)
			Fight.embattleDragPos = nil
		end
	elseif type=="cancelled" then
		if Fight.embattleDragPos then
			local fer = Fight.fighters[Fight.embattleDragPos]
			fer:setPosition(POSITIONS[Fight.embattleDragPos].x,POSITIONS[Fight.embattleDragPos].y)
			fer:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - Fight.embattleDragPos)
			Fight.embattleDragPos = nil
		end
	end
end

--ScriptDialog开始
function Fight.doScriptDialog()
	local dlg = Fight.initData.script[Fight.scriptIndex].talk
	local pngPath = nil
	if dlg.cardID then --兼容imageNamge
		local cardData = DictCard[tostring(dlg.cardID)]
		pngPath = "image/" .. DictUI[tostring(dlg.awoken and cardData.awakeBigUiId or cardData.bigUiId)].fileName
	else
		pngPath = "image/" .. dlg.imageName
	end
	Fight.dialogLayer:setVisible(true)
	local function enableTouch()
		Fight.dialogLayer:setTouchEnabled(true)
	end
	if dlg.dir == 0 then
		Fight.dialogHeadTop:loadTexture(pngPath)
		Fight.dialogDialogTop:setVisible(false)
		Fight.dialogDialogTop:setPositionX(Fight.dialogDialogTop:getPositionX()+15)
		if dlg.name == Fight.dialogNameTop:getText() then
			Fight.dialogHeadTop:setPositionX(Fight.dialogHeadTop:getPositionX()-15)
			Fight.dialogHeadTop:runAction(
				cc.Sequence:create(
					cc.MoveBy:create(0.1,cc.p(15,0)),
					cc.CallFunc:create(function()
							Fight.dialogDialogTop:runAction(cc.Sequence:create(
									cc.DelayTime:create(0.2),
									cc.CallFunc:create(function() Fight.dialogDialogTop:setVisible(true) end),
									cc.MoveBy:create(0.15,cc.p(-15,0)),
									cc.CallFunc:create(enableTouch)
								)
							)
						end
					)
				)
			)
		else
			Fight.dialogTop:setPositionX(Fight.dialogTop:getPositionX()-640)
			Fight.dialogTop:runAction(
				cc.Sequence:create(
					cc.MoveBy:create(0.1,cc.p(640,0)),
					cc.CallFunc:create(function()
							Fight.dialogDialogTop:runAction(cc.Sequence:create(
									cc.DelayTime:create(0.2),
									cc.CallFunc:create(function() Fight.dialogDialogTop:setVisible(true) end),
									cc.MoveBy:create(0.15,cc.p(-15,0)),
									cc.CallFunc:create(enableTouch)
								)
							)
						end
					)
				)
			)
		end

		cc.FormatText:setDefault(dp.FONT,24,0x400903)
		Fight.dialogTextTop:setText(dlg.dialog)

		cc.FormatText:setDefault(dp.FONT,32,0xFFFFFF)
		Fight.dialogNameTop:setText(dlg.name)

		Fight.dialogTop:setVisible(true)
		Fight.dialogTop:setColor(cc.c3b(0xFF,0xFF,0xFF))
		if Fight.scriptLastDialogRoundIndex ~= Fight.roundIndex then
			Fight.dialogBottom:setVisible(false)
		end
		Fight.dialogBottom:setColor(cc.c3b(0x60,0x60,0x60))
	else
		Fight.dialogHeadBottom:loadTexture(pngPath)
		Fight.dialogDialogBottom:setVisible(false)
		Fight.dialogDialogBottom:setPositionX(Fight.dialogDialogBottom:getPositionX()-15)
		if dlg.name == Fight.dialogNameBottom:getText() then
			Fight.dialogHeadBottom:setPositionX(Fight.dialogHeadBottom:getPositionX()+15)
			Fight.dialogHeadBottom:runAction(
				cc.Sequence:create(
					cc.MoveBy:create(0.1,cc.p(-15,0)),
					cc.CallFunc:create(function()
							Fight.dialogDialogBottom:runAction(cc.Sequence:create(
									cc.DelayTime:create(0.2),
									cc.CallFunc:create(function() Fight.dialogDialogBottom:setVisible(true) end),
									cc.MoveBy:create(0.15,cc.p(15,0)),
									cc.CallFunc:create(enableTouch)
								)
							)
						end
					)
				)
			)
		else
			Fight.dialogBottom:setPositionX(Fight.dialogBottom:getPositionX()+640)
			Fight.dialogBottom:runAction(
				cc.Sequence:create(
					cc.MoveBy:create(0.1,cc.p(-640,0)),
					cc.CallFunc:create(function()
							Fight.dialogDialogBottom:runAction(cc.Sequence:create(
									cc.DelayTime:create(0.2),
									cc.CallFunc:create(function() Fight.dialogDialogBottom:setVisible(true) end),
									cc.MoveBy:create(0.15,cc.p(15,0)),
									cc.CallFunc:create(enableTouch)
								)
							)
						end
					)
				)
			)
		end

		cc.FormatText:setDefault(dp.FONT,24,0x400903)
		Fight.dialogTextBottom:setText(dlg.dialog)

		cc.FormatText:setDefault(dp.FONT,32,0xFFFFFF)
		Fight.dialogNameBottom:setText(dlg.name)

		Fight.dialogBottom:setVisible(true)
		Fight.dialogBottom:setColor(cc.c3b(0xFF,0xFF,0xFF))
		if Fight.scriptLastDialogRoundIndex ~= Fight.roundIndex then
			Fight.dialogTop:setVisible(false)
		end
		Fight.dialogTop:setColor(cc.c3b(0x60,0x60,0x60))
	end
	Fight.scriptLastDialogRoundIndex = Fight.roundIndex
end

--ScriptDialog点击
function Fight.onScriptDialogTouch(obj,type)
	if type==ccui.TouchEventType.ended then
		Fight.dialogLayer:setVisible(false)
		Fight.dialogLayer:setTouchEnabled(false)
		Fight.onScriptDialogDone()
	end
end

--ScriptDialog完成
function Fight.onScriptDialogDone()
	Fight.doScriptNext()
end

----ScriptGuide开始
--function Fight.doScriptGuide()
--	local skillCard = nil
--	for i = 1,#Fight.mySkillCardsOrder do
--		if Fight.mySkillCardsOrder[i]:getState() == SKILL_CARD_STATE_NORMAL then
--			skillCard = Fight.mySkillCardsOrder[i]
--			break
--		end
--	end
--	if not skillCard then
--		Fight.onScriptGuideDone()
--		return
--	end
--	local dlg = Fight.initData.script[Fight.scriptIndex].guide
--	if dlg.dir == 1 then
--		Fight.dialogLeft:setVisible(false)
--		Fight.dialogRight:setVisible(true)
--		Fight.dialogRight:loadTexture("image/" .. dlg.imageName)
--		Fight.dialogNameR:setString(dlg.name)
--	else
--		Fight.dialogLeft:setVisible(true)
--		Fight.dialogRight:setVisible(false)
--		Fight.dialogLeft:loadTexture("image/" .. dlg.imageName)
--		Fight.dialogNameL:setString(dlg.name)
--	end
--	Fight.dialogText:setString(dlg.dialog)
--	Fight.dialogLayer:setVisible(true)
--	Fight.dialogLayer:setTouchEnabled(false)
--	-- Finger
--	UIGuidePeople.addGuideUI(UIFightMain,skillCard.button,nil,Fight.onScriptGuideCallback)
--end

----ScriptGuide回调
--function Fight.onScriptGuideCallback()
--	local skillCard = nil
--	for i = 1,#Fight.mySkillCardsOrder do
--		if Fight.mySkillCardsOrder[i]:getState() == SKILL_CARD_STATE_NORMAL then
--			skillCard = Fight.mySkillCardsOrder[i]
--			break
--		end
--	end
--	local manualSkill = Fight.initData.myData.skillCards[skillCard:getTag()]
--	Fight.actionPushFront(ACT_MANUAL,manualSkill.id,manualSkill.lv,nil,skillCard:getTag())
--	skillCard:setState(SKILL_CARD_STATE_PRESSED)

--	Fight.dialogLayer:setVisible(false)
--	Fight.dialogLayer:setTouchEnabled(false)
--	Fight.onScriptGuideDone()
--end

----ScriptGuide完成
--function Fight.onScriptGuideDone()
--	Fight.doScriptNext()
--end

--ScriptEnter开始
function Fight.doScriptEnter()
	local ent = Fight.initData.script[Fight.scriptIndex].enter
	local pos = ent.position
	local fst = ent.data
	local fer = Fight.fighters[pos]
	Fight.setFighterProperties(pos,fst)
	Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
	fer:setVisible(true)
	fer:setReady(true)
	fer:setLocalZOrder(ZORDER_OF_FIGHTER_ACTIVE)
	if ent.upDown then
		fer:retain()
		fer:removeFromParent()
		local scale = fer:getScale()
		local rect  = {x=-1280,y=-90*scale,width=3840,height=6816}
		local color = {r=0,g=0,b=0,a=0}
		local drawNode = cc.DrawNode:create()
		drawNode:drawPolygon({{x=rect.x,y=rect.y},{x=rect.x+rect.width,y=rect.y},{x=rect.x+rect.width,y=rect.y+rect.height},{x=rect.x,y=rect.y+rect.height}},4,color,1,color)
		local clippingNode = cc.ClippingNode:create()
		clippingNode:setStencil(drawNode)
		clippingNode:setPosition(fer:getPosition())
		clippingNode:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - pos)
		clippingNode:addChild(fer)
		Fight.shakeNode:addChild(clippingNode)
		fer:setPosition(0,-220*scale)
		fer:runAction(
			cc.Sequence:create(
				cc.MoveBy:create(3.6/Fight.speed,cc.p(0,220*scale)),
				cc.CallFunc:create(function()Fight.onScriptEnterDone()end)
			)
		)
		local wing = fer.wing
		if wing then
			wing:retain()
			wing:removeFromParent()
			clippingNode:addChild(wing)
		end
	else
		fer:setScale(3.0)
		fer:runAction(
			cc.Sequence:create(
				cc.ScaleTo:create(0.3/Fight.speed,fst.scale and fst.scale or fst.isBoss and FIGHTER_BOSS_SCALE or FIGHTER_NORMAL_SCALE),
				cc.CallFunc:create(function()Fight.startShake()end),
				cc.DelayTime:create(0.3/Fight.speed),
				cc.CallFunc:create(function()Fight.stopShake()Fight.onScriptEnterDone()end)
			)
		)
	end
end

--ScriptEnter完成
function Fight.onScriptEnterDone()
	local ent = Fight.initData.script[Fight.scriptIndex].enter
	local pos = ent.position
	local fer = Fight.fighters[pos]
	if ent.upDown then
		local parent = fer:getParent()
		fer:setPosition(parent:getPosition())
		fer:removeFromParent()
		parent:removeFromParent()
		Fight.shakeNode:addChild(fer)
		fer:release()
		local wing = fer.wing
		if wing then
			wing:removeFromParent()
			Fight.shakeNode:addChild(wing)
			wing:release()
		end
	else
		--nothing
	end
	fer:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - pos)
	Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
	Fight.resetLimited()
	Fight.doPyrosPostScriptEnter(pos)
end

--脚本上场后异火开始
function Fight.doPyrosPostScriptEnter(pos)
	local pyroTable = Fight.getPyrosPreFight(pos)
	if #pyroTable > 0 then
		Fight.doPyro(pos,function(pos)Fight.onPyrosPostScriptEnterDone()end,pyroTable)
	else
		Fight.onPyrosPostScriptEnterDone()
	end
end

--脚本上场后异火完成
function Fight.onPyrosPostScriptEnterDone()
	Fight.doScriptNext()
end

--ScriptExit开始
function Fight.doScriptExit()
	local ext = Fight.initData.script[Fight.scriptIndex].exit
	local pos = ext.position
	local fer = Fight.fighters[pos]
	Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
	fer:setLocalZOrder(ZORDER_OF_FIGHTER_ACTIVE)
	if ext.upDown then
		fer:retain()
		fer:removeFromParent()
		local scale = fer:getScale()
		local rect  = {x=-1280,y=-90*scale,width=3840,height=6816}
		local color = {r=0,g=0,b=0,a=0}
		local drawNode = cc.DrawNode:create()
		drawNode:drawPolygon({{x=rect.x,y=rect.y},{x=rect.x+rect.width,y=rect.y},{x=rect.x+rect.width,y=rect.y+rect.height},{x=rect.x,y=rect.y+rect.height}},4,color,1,color)
		local clippingNode = cc.ClippingNode:create()
		clippingNode:setStencil(drawNode)
		clippingNode:setPosition(fer:getPosition())
		clippingNode:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - pos)
		clippingNode:addChild(fer)
		Fight.shakeNode:addChild(clippingNode)
		fer:setPosition(0,0)
		fer:runAction(
			cc.Sequence:create(
				cc.MoveBy:create(3.6/Fight.speed,cc.p(0,-220*scale)),
				cc.CallFunc:create(function()Fight.onScriptExitDone()end)
			)
		)
		local wing = fer.wing
		if wing then
			wing:retain()
			wing:removeFromParent()
			clippingNode:addChild(wing)
		end
	else
		fer:runAction(
			cc.Sequence:create(
				cc.ScaleTo:create(0.3/Fight.speed,2.0),
				cc.CallFunc:create(function()Fight.onScriptExitDone()end)
			)
		)
	end
end

--ScriptExit完成
function Fight.onScriptExitDone()
	local ext = Fight.initData.script[Fight.scriptIndex].exit
	local pos = ext.position
	local fer = Fight.fighters[pos]
	if ext.upDown then
		local parent = fer:getParent()
		fer:setPosition(parent:getPosition())
		fer:removeFromParent()
		parent:removeFromParent()
		Fight.shakeNode:addChild(fer)
		fer:release()
		local wing = fer.wing
		if wing then
			wing:removeFromParent()
			Fight.shakeNode:addChild(wing)
			wing:release()
		end
	else
		--nothing
	end
	fer:setVisible(false)
	fer:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - pos)
	Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
	Fight.resetLimited()
	Fight.doScriptNext()
end

--ScriptIntro开始
function Fight.doScriptIntro()
	local intro = Fight.initData.script[Fight.scriptIndex].intro
	Fight.introNode:setVisible(true)
	Fight.introNode:getAnimation():setSpeedScale(Fight.speed)
	Fight.introNode:getAnimation():playWithIndex(intro.id,-1,0)
end

--ScriptIntro完成
function Fight.onScriptIntroDone()
	Fight.introNode:setVisible(false)
	Fight.doScriptNext()
end

--ScriptBG开始
function Fight.doScriptBG()
	local BG_SWITCH_TIME = 0.3 --todo 背景切换时间
	local bg = Fight.initData.script[Fight.scriptIndex].bg
	Fight.bgSprite:runAction(
		cc.Sequence:create(
			cc.FadeOut:create(BG_SWITCH_TIME),
			cc.CallFunc:create(
				function()
					Fight.bgSprite:setTexture(bg.bgImagePath0)
					Fight.bgSprite:getChildByTag(1):setTexture(bg.bgImagePath0)
					local spriteToCut = Fight.bgSprite:getChildByTag(2)
					local spriteOfTop = Fight.bgSprite:getChildByTag(3)
					spriteToCut:setTexture(bg.bgImagePath0)
					spriteOfTop:setTexture(bg.bgImagePath1)
					--Fix Rect
					local ssss = spriteToCut:getContentSize()
					local size = spriteOfTop:getContentSize()
					spriteToCut:setTextureRect(cc.rect(0,size.height,size.width,ssss.height-size.height))
				end
			),
			cc.FadeIn:create(BG_SWITCH_TIME),
			cc.CallFunc:create(function()Fight.onScriptBGDone()end)
		)
	)
end

--ScriptBG完成
function Fight.onScriptBGDone()
	Fight.doScriptNext()
end

--ScriptMusic开始
function Fight.doScriptMusic()
	local music = Fight.initData.script[Fight.scriptIndex].music
	if cc.FileUtils:getInstance():isFileExist(music.mp3) then
		AudioEngine.playMusic(music.mp3,true)
	end
	Fight.onScriptMusicDone()
end

--ScriptMusic完成
function Fight.onScriptMusicDone()
	Fight.doScriptNext()
end

--ScriptOrder开始
function Fight.doScriptOrder()
	local order = Fight.initData.script[Fight.scriptIndex].order
	if order.reset then
		for i = 1,12 do
			Fight.fighters[i]:setReady(true)
		end
	end
	if #order == 0 then
		Fight.resetPriorityMap()
	else
		Fight.customPriorityMap = order
	end
	Fight.onScriptOrderDone()
end

--ScriptOrder完成
function Fight.onScriptOrderDone()
	Fight.doScriptNext()
end

--脚本(下一回合的脚本)开始
function Fight.doScript()
	Fight.skipFightBtn:setVisible(false)
	if Fight.skipFightFlag then
		Fight.onScriptDone()
		return
	end
	-- fast forward for fightIndex
	if Fight.initData.script and Fight.scriptIndex <= #Fight.initData.script and Fight.fightIndex > Fight.initData.script[Fight.scriptIndex].fight then
		local found = false
		for i = Fight.scriptIndex+1,#Fight.initData.script do
			if Fight.fightIndex <= Fight.initData.script[i].fight then
				Fight.scriptIndex = i
				found = true
				break
			end
		end
		if not found then
			Fight.scriptIndex = #Fight.initData.script + 1
		end
	end
	local needIDX = Fight.isFightWin() and -1 or 0
	-- fast forward for zero round
	if Fight.initData.script and Fight.scriptIndex <= #Fight.initData.script and (Fight.isFightOver() or Fight.bigRound == MAX_ROUND_LIMIT) then
		for i = Fight.scriptIndex,#Fight.initData.script do
			Fight.scriptIndex = i
			if Fight.fightIndex ~= Fight.initData.script[i].fight or Fight.initData.script[i].round == needIDX then
				break
			end
		end
	end
	-- execute
	if Fight.initData.script and Fight.scriptIndex <= #Fight.initData.script and Fight.fightIndex == Fight.initData.script[Fight.scriptIndex].fight
			and
			( 	(Fight.isFightOver() or Fight.bigRound == MAX_ROUND_LIMIT) 
				and Fight.initData.script[Fight.scriptIndex].round == needIDX
				or Fight.roundIndex-Fight.roundOrigin+1 == Fight.initData.script[Fight.scriptIndex].round
			)
			then
		local sData = Fight.initData.script[Fight.scriptIndex]
		if sData.talk then
			Fight.doScriptDialog()
		--elseif sData.guide then
		--	if Fight.isReplay then
		--		Fight.doScriptNext()
		--	else
		--		Fight.doScriptGuide()
		--	end
		elseif sData.enter then
			Fight.doScriptEnter()
		elseif sData.exit then
			Fight.doScriptExit()
		elseif sData.intro then
			Fight.doScriptIntro()
		elseif sData.bg then
			Fight.doScriptBG()
		elseif sData.music then
			Fight.doScriptMusic()
		elseif sData.order then
			Fight.doScriptOrder()
		else
			cclog("doScriptUnsupported")
			Fight.doScriptNext()
		end
	else
		Fight.onScriptDone()
	end
end

--脚本(下一回合的脚本)下一条
function Fight.doScriptNext()
	Fight.scriptIndex = Fight.scriptIndex + 1
	Fight.doScript() --loop next
end

--脚本(下一回合的脚本)完成
function Fight.onScriptDone()
	local bigRound = Fight.bigRound + 1
	if bigRound > MAX_ROUND_LIMIT then
		bigRound = MAX_ROUND_LIMIT
	end
	Fight.roundLabel:setString("回合：" .. bigRound .. "/" .. MAX_ROUND_LIMIT)
	local function callOnFightDone()
		for i= 1,#Fight.mySkillCardsOrder do
			Fight.mySkillCardsOrder[i]:removeFromParent()
		end
		Fight.mySkillCardsOrder = nil
		Fight.otherSkillCardsOrder = nil
		if Fight.bigRound > 0 then --特殊处理一下
			Fight.roundLabel:setString("回合：" .. Fight.bigRound .. "/" .. MAX_ROUND_LIMIT)
		end
		Fight.onFightDone()
	end
	Fight.skipFightBtn:setVisible(Fight.initData.allowSkipFight)
	if Fight.skipFightFlag then
		callOnFightDone()
	elseif Fight.bigRound == MAX_ROUND_LIMIT then
		callOnFightDone()
	elseif Fight.isFightOver() then
		if Fight.isSelfAlive() and Fight.fightIndex ~= #Fight.initData.otherData then
			Fight.fightIndex = Fight.fightIndex + 1
			Fight.doFight()
		else
			callOnFightDone()
		end
	else
		Fight.doExtra()
	end
end

--额外回合开始
function Fight.doExtra()
	Fight.roundIndex = Fight.roundIndex + 1
	cclog("##################################################### " .. Fight.roundIndex)

	Fight.isEnter  = false
	Fight.isExit   = false
	Fight.getSrc()
	Fight.roundSrc = Fight.src
	Fight.roundDie = false
	Fight.isBurnt  = false
	Fight.isPoisoned=false
	Fight.isCursed = false
	
	if Fight.isExtra then
		Fight.doPyro(Fight.src,function(pos)Fight.onExtraDone()end,{PYRO_JingLianYaoHuo})
	else
		Fight.onExtraDone()
	end
end

--额外回合完成
function Fight.onExtraDone()
	Fight.doRegeOfPyro()
end

--RegeOfPyro开始
function Fight.doRegeOfPyro()
	local fer = Fight.fighters[Fight.roundSrc]
	if fer:hasBufferData(BUFFER_TYPE_FREEZE) or fer:hasBufferData(BUFFER_TYPE_STUN) or fer:hasBufferData(BUFFER_TYPE_SEAL) then
		local pyroLV = fer:getPyroYunLuoXinYan()
		if pyroLV > PYRO_STATE_NULL and Fight.random(1) < PYRO_YunLuoXinYan.var[pyroLV] then
			fer:setHP(fer:getHPMax())
			Fight.doPyro(Fight.src,function(pos)Fight.onRegeOfPyroDone()end,{PYRO_YunLuoXinYan})
			return
		end
	end
	Fight.onRegeOfPyroDone()
end

--RegeOfPyro完成
function Fight.onRegeOfPyroDone()
	Fight.doRid()
end

--摆脱开始
local isRid --Only for Rid
function Fight.doRid()
	isRid = false
	local fer = Fight.fighters[Fight.roundSrc]
	if fer:hasBufferData(BUFFER_TYPE_FREEZE) or fer:hasBufferData(BUFFER_TYPE_STUN) or fer:hasBufferData(BUFFER_TYPE_SEAL) then
		local pyroLV = fer:getPyroShengLingZhiYan()
		isRid = pyroLV > PYRO_STATE_NULL and Fight.random(2) < PYRO_ShengLingZhiYan.var[pyroLV]
		if isRid then
			Fight.doPyro(Fight.src,function(pos)Fight.onRidDone()end,{PYRO_ShengLingZhiYan})
			return
		end
	end
	Fight.onRidDone()
end

--摆脱完成
function Fight.onRidDone()
	if isRid then
		local fer = Fight.fighters[Fight.roundSrc]
		fer:setBufferData(BUFFER_TYPE_FREEZE,nil)
		fer:setBufferData(BUFFER_TYPE_STUN,nil)
		fer:setBufferData(BUFFER_TYPE_SEAL,nil)
	end
	Fight.doRegeOfBuffer()
end

--RegeOfBuffer开始
function Fight.doRegeOfBuffer()
	local src = Fight.fighters[Fight.roundSrc]
	if src:hasBufferData(BUFFER_TYPE_REGE) then
		local bufferArmature = src:getBufferArmature(BUFFER_TYPE_REGE)
		bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
		local damage = math.floor(src:getBufferDamage(BUFFER_TYPE_REGE)/3) --!!!调整伤害公式所需的同步修改 /3
		src:addHP(damage)
		Fight.showDamage(damage,DAMAGE_TYPE_REGENERATION,src:getPosition())
	else
		Fight.onRegeOfBufferDone()
	end
end

--RegeOfBuffer完成
function Fight.onRegeOfBufferDone()
	local src = Fight.fighters[Fight.roundSrc]
	if src:hasBufferData(BUFFER_TYPE_REGE) then
		local bufferArmature = src:getBufferArmature(BUFFER_TYPE_REGE)
		bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
		src:decBufferData(BUFFER_TYPE_REGE)
	end
	Fight.doRound()
end

--回合开始
function Fight.doRound()
	local fer = Fight.fighters[Fight.roundSrc]
	fer:addRound()
	if fer:hasBufferData(BUFFER_TYPE_FREEZE) or fer:hasBufferData(BUFFER_TYPE_STUN) or fer:hasBufferData(BUFFER_TYPE_SEAL) then
		Fight.roundSID = nil
		Fight.roundSkp = true
		Fight.actionPushBack(ACT_STAND,nil,nil,Fight.roundSrc)
	else
		local sid,slv = fer:getRoundSkill(nil)
		assert(sid,"错误：" .. Fight.src .. "号位置第" .. fer:getRound() .. "回合没有可释放技能!")
		Fight.roundSID = sid
		Fight.roundSkp = false
		Fight.actionPushBack(ACT_ROUND,sid,slv,Fight.roundSrc)
	end
	Fight.doAction()
	Fight.manualDisabled = false
end

--回合完成
function Fight.onRoundDone()
	Fight.manualDisabled = true
	--回合结束类技能
	local fer = Fight.fighters[Fight.roundSrc]
	--!!!修复跳过战斗时报错的问题，问题来源：使用了顺序错误的随机数。
	--!!!跳过战斗时同时跳过回合结束类技能。
	if fer:isVisible() and not fer:isDead() and not Fight.skipFightFlag then
		local passiveFINISkillID,passiveFINISkillLV = fer:getPassiveFINISkill()
		if passiveFINISkillID then
			local attPercent,defPercent,hpPercent = SkillManager[passiveFINISkillID].finishFunc(passiveFINISkillLV,Fight.random(3))
			fer:addAttackEx(attPercent)
			fer:addDefenceEx(defPercent)
			fer:addHP(math.floor(fer:getHPMax() * hpPercent))
		end
	end
	if Fight.isExtra then
		Fight.isExtra = false
	elseif not Fight.skipFightFlag then --!!!跳过战斗时同时跳过此异火功能。
		local pyroLV = fer:getPyroJingLianYaoHuo()
		Fight.isExtra = pyroLV > PYRO_STATE_NULL and Fight.random(4) < PYRO_JingLianYaoHuo.var[pyroLV] or false
		fer:setReady(Fight.isExtra)
	end
	if Fight.skipFightFlag then
		Fight.doScript()
	elseif Fight.isFightOver() then
		Fight.bigRound = Fight.bigRound + 1
		Fight.doManualUpdate()
	elseif Fight.isBigRoundOver() then
		Fight.bigRound = Fight.bigRound + 1
		Fight.doManualUpdate()
	else
		Fight.doScript()
	end
end

function Fight.doManualUpdate()
	for i = 1,#Fight.mySkillCardsOrder do
		Fight.mySkillCardsOrder[i]:updateCD()
	end
	if not Fight.initData.isPVE then
		for i = 1,#Fight.otherSkillCardsOrder do
			Fight.otherSkillCardsOrder[i]:updateCD()
		end
	end
	Fight.onManualUpdateDone()
end

function Fight.onManualUpdateDone()
	Fight.doScript()
end

-------------------------------------
--队列的一些操作函数

--清空队列
function Fight.clearActions()
	Fight.actionHead = nil
end

--队列中是否还有动作
function Fight.existActions()
	return Fight.actionHead ~= nil
end

--插入队列头
function Fight.actionPushFront(act,sid,slv,src,tag)
	if act ~= ACT_MANUAL and act ~= ACT_MMMMMM then--!!!只能是ACT_MANUAL or ACT_MMMMMM
		return
	end
	if Fight.actionHead == nil or (Fight.actionHead.act ~= ACT_MANUAL and Fight.actionHead.act ~= ACT_MMMMMM) then
		Fight.actionHead = {act = act,sid = sid,slv = slv,src = src,tag = tag,next = Fight.actionHead}
	else
		local pre = Fight.actionHead
		local cur = pre.next
		while cur and (cur.act == ACT_MANUAL or cur.act == ACT_MMMMMM) do
			pre = cur
			cur = cur.next
		end
		pre.next = {act = act,sid = sid,slv = slv,src = src,tag = tag,next = cur}
	end
end

--追加队列尾
function Fight.actionPushBack(act,sid,slv,src)
	local e = {act = act,sid = sid,slv = slv,src = src,next = nil}
	if Fight.actionHead == nil then
		Fight.actionHead = e
	else
		if act == ACT_EXIT then --!!!修正队列中的无效动作
			local i = Fight.actionHead
			while i.next do
				if i.next.src == src then
					i.next = i.next.next
				else
					i = i.next
				end
			end
			i.next = e
			if Fight.actionHead.src == src then
				Fight.actionHead = Fight.actionHead.next
			end
		else
			local i = Fight.actionHead
			while i.next do
				i = i.next
			end
			i.next = e
		end
	end
end

--移除队列头
function Fight.actionRemoveFront()
	Fight.actionHead = Fight.actionHead.next
end

--获取队列头
function Fight.actionPopFront()
	Fight.act = Fight.actionHead.act
	Fight.sid = Fight.actionHead.sid
	Fight.slv = Fight.actionHead.slv
	Fight.src = Fight.actionHead.src
	Fight.tag = Fight.actionHead.tag
	Fight.dst = {}
	Fight.actionHead = Fight.actionHead.next
end

--获取队列尾
--function Fight.actionPopBack()
--end

--打印队列
function Fight.debugPrintActions(isSingle)
	if Fight.actionHead ~= nil then
		cclog("########")
		local name = {"普通","上场","下场","反击","手动","站立","掉血","中毒","诅咒","回血","敌手","异火入场","异火下场"}
		local curr = Fight.actionHead
		repeat
			cclog(name[curr.act] .. " " .. ((curr.act == ACT_MANUAL or curr.act == ACT_MMMMMM) and curr.tag or curr.src))
			if isSingle then
				break
			end
			curr = curr.next
		until curr == nil
	end
end

--动作开始
function Fight.doAction()
	--replay 检查插入
	if Fight.isReplay then
		local act = Fight.initData.record.manualAct[Fight.recordManualIdx]
		if #Fight.initData.record.manualAct >= Fight.recordManualIdx
				and Fight.actionIndex + 1 == act.index
				and Fight.roundIndex == act.rIndex then
			local manualSkill = Fight.initData.myData.skillCards[act.tag]
			Fight.actionPushFront(ACT_MANUAL,manualSkill.id,manualSkill.lv,nil,act.tag)
			Fight.recordManualIdx = Fight.recordManualIdx + 1
		end
		--!!! 以 下 代码从设计规则上来说不会被执行。
		--local act = Fight.initData.record.mmmmmmAct[Fight.recordMMMMMMIdx]
		--if #Fight.initData.record.mmmmmmAct >= Fight.recordMMMMMMIdx
		--		and Fight.actionIndex + 1 == act.index
		--		and Fight.roundIndex == act.rIndex then
		--	local mmmmmmSkill = Fight.initData.otherData[1].skillCards[act.tag]
		--	Fight.actionPushFront(ACT_MMMMMM,mmmmmmSkill.id,mmmmmmSkill.lv,nil,act.tag)
		--	Fight.recordMMMMMMIdx = Fight.recordMMMMMMIdx + 1
		--end
		--!!! 以 上 代码从设计规则上来说不会被执行。
	end
	
	Fight.debugPrintActions(true)

	--pop
	Fight.actionPopFront()
	Fight.actionIndex = Fight.actionIndex + 1

	--replay 检查追加
	if Fight.isReplay then
		local act = Fight.initData.record.manualAct[Fight.recordManualIdx]
		if #Fight.initData.record.manualAct >= Fight.recordManualIdx
				and Fight.actionIndex + 1 == act.index
				and Fight.roundIndex == act.rIndex then
			local manualSkill = Fight.initData.myData.skillCards[act.tag]
			Fight.actionPushFront(ACT_MANUAL,manualSkill.id,manualSkill.lv,nil,act.tag)
			Fight.recordManualIdx = Fight.recordManualIdx + 1
		end
		local act = Fight.initData.record.mmmmmmAct[Fight.recordMMMMMMIdx]
		if #Fight.initData.record.mmmmmmAct >= Fight.recordMMMMMMIdx
				and Fight.actionIndex + 1 == act.index
				and Fight.roundIndex == act.rIndex then
			local mmmmmmSkill = Fight.initData.otherData[1].skillCards[act.tag]
			Fight.actionPushFront(ACT_MMMMMM,mmmmmmSkill.id,mmmmmmSkill.lv,nil,act.tag)
			Fight.recordMMMMMMIdx = Fight.recordMMMMMMIdx + 1
		end
	elseif Fight.act == ACT_MANUAL then
		Fight.initData.record.manualAct[#Fight.initData.record.manualAct + 1] = {index=Fight.actionIndex,tag = Fight.tag,rIndex=Fight.roundIndex}
	elseif Fight.act == ACT_MMMMMM then
		Fight.initData.record.mmmmmmAct[#Fight.initData.record.mmmmmmAct + 1] = {index=Fight.actionIndex,tag = Fight.tag,rIndex=Fight.roundIndex}
	end
	if Fight.isReplay then
		if Fight.act == ACT_MANUAL then
			Fight.mySkillCardsOrder[Fight.tag]:setState(SKILL_CARD_STATE_PRESSED)
		elseif Fight.act == ACT_MMMMMM then
			Fight.otherSkillCardsOrder[Fight.tag]:setState(SKILL_CARD_STATE_PRESSED)
		end
	end
	
	--do
	if Fight.act == ACT_ROUND then
		Fight.doSelectTarget()
	elseif Fight.act == ACT_ENTER then
		local fst = nil
		if Fight.src < 7 then
			if Fight.mySubstituteIdx >= #Fight.initData.myData.substitute then
				Fight.onActionDone()
				return
			end
			Fight.mySubstituteIdx = Fight.mySubstituteIdx + 1
			Fight.updateMySubstitute()
			fst = Fight.initData.myData.substitute[Fight.mySubstituteIdx]
		else
			if Fight.otherSubstituteIdx >= #Fight.initData.otherData[Fight.fightIndex].substitute then
				Fight.onActionDone()
				return
			end
			Fight.otherSubstituteIdx = Fight.otherSubstituteIdx + 1
			fst = Fight.initData.otherData[Fight.fightIndex].substitute[Fight.otherSubstituteIdx]
		end
		local src = Fight.fighters[Fight.src]
		Fight.setFighterProperties(Fight.src,fst)
		Fight.sid,Fight.slv = src:getEnterSkill() --补充上场技能sid
		Fight.doEnter()
	elseif Fight.act == ACT_EXIT then
		if Fight.sid then
			Fight.doSelectTarget()
		else
			Fight.doRevive()
		end
	elseif Fight.act == ACT_COUNTER then
		Fight.doSelectTarget()
	elseif Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		Fight.doSelectTarget()
	elseif Fight.act == ACT_STAND then
		Fight.doStand()
	elseif Fight.act == ACT_BURN then
		Fight.doBurn()
	elseif Fight.act == ACT_POISON then
		Fight.doPoison()
	elseif Fight.act == ACT_CURSE then
		Fight.doCurse()
	elseif Fight.act == ACT_ENTER2 then
		Fight.doPyroEnter()
	elseif Fight.act == ACT_EXIT2 then
		Fight.doPyroExit()
	end
end

--动作完成
function Fight.onActionDone()
	--debug status
	cclog(string.format("-------------------------------------------------"))
	for i=10,1,-3 do
		local logstr = "|"
		for j=0,2 do
			local fer = Fight.fighters[i + j]
			if not fer:isVisible() or fer:isDead() then
				logstr = logstr .. "               |"
			else
				logstr = logstr .. string.format(" %4d %-8d |",fer:getRound(),fer:getHP())
			end
		end
		cclog(logstr)
	end
	cclog(string.format("-------------------------------------------------"))
	
	if Fight.act == ACT_MANUAL then
		Fight.mySkillCardsOrder[Fight.tag]:setState(SKILL_CARD_STATE_RELEASED)
	elseif Fight.act == ACT_MMMMMM then
		Fight.otherSkillCardsOrder[Fight.tag]:setState(SKILL_CARD_STATE_RELEASED)
	end
	if Fight.skipFightFlag then
		Fight.clearActions()
		Fight.onRoundDone()
		return
	end
	--检查连锁反应
	--dst 反击
	if Fight.act == ACT_ROUND or Fight.act == ACT_ENTER2 or Fight.act == ACT_EXIT2 then
		for i=1,#Fight.dst do
			local dst = Fight.fighters[Fight.dst[i]]
			if dst:isVisible() and not dst:isDead() and dst:isCounter() and not dst:hasBufferData(BUFFER_TYPE_FREEZE) and not dst:hasBufferData(BUFFER_TYPE_STUN) and not dst:hasBufferData(BUFFER_TYPE_SEAL) then --!!! 没有禁止行动Buffer时才可反击
				local sid,slv = dst:getCounterSkill()
				if sid then
					if SkillManager[sid].counterProbability > Fight.random(5) then
						Fight.actionPushBack(ACT_COUNTER,sid,slv,Fight.dst[i])
					end
				end
			end
		end
	end
	--dst 死亡
	for i=1,#Fight.dst do
		local pos = Fight.dst[i]
		local dst = Fight.fighters[pos]
		if dst:isVisible() and dst:isDead() then
			if pos == Fight.roundSrc then
				Fight.roundDie = true
			end
			local sid,slv = dst:getExitSkill()
			Fight.actionPushBack(ACT_EXIT,sid,slv,pos)
			Fight.actionPushBack(ACT_ENTER,nil,nil,pos)
		end
	end
	--src 死亡
	if Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM and Fight.act ~= ACT_EXIT then --手动技和下场技不检测src死亡
		local pos = Fight.src
		local src = Fight.fighters[pos]
		if src:isVisible() and src:isDead() then --!!! 循环死亡的Bug.
			if pos == Fight.roundSrc then
				Fight.roundDie = true
			end
			local sid,slv = src:getExitSkill()
			Fight.actionPushBack(ACT_EXIT,sid,slv,pos)
			Fight.actionPushBack(ACT_ENTER,nil,nil,pos)
		end
	end
	--如果队列中还有动作
	if Fight.existActions() then
		Fight.doAction()
		return
	end
	--如果该角色死亡则结束其回合
	if Fight.roundDie then
		Fight.onRoundDone()
		return
	end
	--否则该角色继续其他技能
	if not Fight.roundSkp then
		local fer = Fight.fighters[Fight.roundSrc]
		if fer:hasBufferData(BUFFER_TYPE_FREEZE) or fer:hasBufferData(BUFFER_TYPE_STUN) or fer:hasBufferData(BUFFER_TYPE_SEAL) then
			Fight.roundSkp = true
		else
			local sid,slv = fer:getRoundSkill(Fight.roundSID)
			if sid then
				Fight.roundSID = sid
				Fight.actionPushBack(ACT_ROUND,sid,slv,Fight.roundSrc)
				Fight.doAction()
				return
			end
			--异火入场技
			if not Fight.isEnter then
				Fight.isEnter = true
				local sid,slv = fer:getEnterSkill()
				if sid then
					local pyroLV = fer:getPyroJinDiFenTianYan()
					if pyroLV > PYRO_STATE_NULL and Fight.random(6) < PYRO_JinDiFenTianYan.var[pyroLV] then
						Fight.actionPushBack(ACT_ENTER2,sid,slv,Fight.roundSrc)
						Fight.doAction()
						return
					end
				end
			end
			--异火下场技
			if not Fight.isExit then
				Fight.isExit = true
				local sid,slv = fer:getExitSkill()
				if sid then
					local pyroLV = fer:getPyroXuWuTunYan()
					if pyroLV > PYRO_STATE_NULL and Fight.random(7) < PYRO_XuWuTunYan.var[pyroLV] then
						Fight.actionPushBack(ACT_EXIT2,sid,slv,Fight.roundSrc)
						Fight.doAction()
						return
					end
				end
			end
		end
	end
	--所有该角色的主动操作完毕，检测其回合结束触发的Buffer
	local fer = Fight.fighters[Fight.roundSrc]
	if fer:hasBufferData(BUFFER_TYPE_BURN) and not Fight.isBurnt then
		Fight.isBurnt = true
		Fight.actionPushBack(ACT_BURN,nil,nil,Fight.roundSrc)
		Fight.doAction()
		return
	end
	if fer:hasBufferData(BUFFER_TYPE_POISON) and not Fight.isPoisoned then
		Fight.isPoisoned = true
		Fight.actionPushBack(ACT_POISON,nil,nil,Fight.roundSrc)
		Fight.doAction()
		return
	end
	if fer:hasBufferData(BUFFER_TYPE_CURSE) and not Fight.isCursed then
		Fight.isCursed = true
		Fight.actionPushBack(ACT_CURSE,nil,nil,Fight.roundSrc)
		Fight.doAction()
		return
	end
	--若是PVP则自动释放手动技能 --todo 谁先手
	--己方
	if not Fight.isReplay and (not Fight.initData.isPVE or Fight.isAutomatic) and Fight.isBigRoundOver() then
		for i = 1,#Fight.mySkillCardsOrder do
			if Fight.mySkillCardsOrder[i]:getState() == SKILL_CARD_STATE_NORMAL then
				Fight.mySkillCardsOrder[i]:setState(SKILL_CARD_STATE_PRESSED)
				local manualSkill = Fight.initData.myData.skillCards[i]
				Fight.actionPushFront(ACT_MANUAL,manualSkill.id,manualSkill.lv,nil,i)
				Fight.doAction()
				return
			end
		end
	end
	--敌方
	if not Fight.isReplay and not Fight.initData.isPVE and Fight.isBigRoundOver() then
		for i = 1,#Fight.otherSkillCardsOrder do
			if Fight.otherSkillCardsOrder[i]:getState() == SKILL_CARD_STATE_NORMAL then
				Fight.otherSkillCardsOrder[i]:setState(SKILL_CARD_STATE_PRESSED)
				local mmmmmmSkill = Fight.initData.otherData[1].skillCards[i]
				Fight.actionPushFront(ACT_MMMMMM,mmmmmmSkill.id,mmmmmmSkill.lv,nil,i)
				Fight.doAction()
				return
			end
		end
	end
	--回合结束
	Fight.onRoundDone()
end

--开始震动
function Fight.startShake()
	--todo assert(Fight.shakeRef >= 0)
	Fight.shakeRef = Fight.shakeRef + 1
end

--停止震动
function Fight.stopShake()
	Fight.shakeRef = Fight.shakeRef - 1
	--todo assert(Fight.shakeRef >= 0)
	if Fight.shakeRef == 0 then
		Fight.shakeNode:setPosition(0,0)
	end
end

--Fighter 动画帧事件时
function Fight.onFighterFrameEventCallBack(bone,eventName,originFrameIndex,currentFrameIndex)
	--if eventName == "zd0" then --处理开始震动 0 == 开
	--	Fight.startShake()
	--	return
	--end
	--if eventName == "zd1" then --处理停止震动 1 == 关
	--	Fight.stopShake()
	--	return
	--end
		if eventName == "Stand" then
	elseif eventName == "Walk" then
	elseif eventName == "Run" then
	elseif eventName == "Dead" then
	elseif eventName == "Attack" then
		Fight.onAttackTrigger()
	elseif eventName == "Injure" then
		--Fight.onInjureTrigger(bone:getArmature():getTag())
	elseif eventName == "Enter" then
	elseif eventName == "Exit" then
	elseif eventName == "Effect" then
		Fight.onEffectTrigger(bone:getArmature():getTag())
	elseif eventName == "Halo" then
	elseif eventName == "Banner" or eventName == "BannerManual" then
		Fight.onBannerTrigger()
	elseif eventName == "BlackBase" then
	elseif eventName == "RedBox" then
	elseif eventName == "Prepare" then
		Fight.onPrepareTrigger()
	elseif eventName == "Sjl" then
		Fight.onSJLTrigger()
	elseif eventName == "Missile" then
		if Fight.missileType == MISSILE_TYPE_NONE then
		elseif Fight.missileType == MISSILE_TYPE_LIGHTNING then
			Fight.onMissileLightningTrigger(bone:getArmature():getTag())
		elseif Fight.missileType == MISSILE_TYPE_SINGLE then
		elseif Fight.missileType == MISSILE_TYPE_FULL then
			Fight.onMissileFullTrigger()
		end
	elseif eventName == "Simida" then
		if Fight.missileType == MISSILE_TYPE_NONE then
		elseif Fight.missileType == MISSILE_TYPE_LIGHTNING then
			Fight.onSimidaTrigger(bone:getArmature():getTag())
		elseif Fight.missileType == MISSILE_TYPE_SINGLE then
		elseif Fight.missileType == MISSILE_TYPE_FULL then
		end
	elseif eventName == "Buffer_0" then
	elseif eventName == "Buffer_1" then
	elseif eventName == "Buffer_2" then
	else
		cclog("ERROR: Unsupport FrameEventName: " .. eventName)
	end
end

--Fighter 动画动作事件时
function Fight.onFighterMovementEventCallBack(armature,movementType,movementName)
	if movementName:find("Stand")
			or movementName:find("Walk")
			or movementName:find("Run")
			or movementName:find("Dead") then
		return
	end
	if movementType == ccs.MovementEventType.start then --不关注开始事件，只关注完成（或循环完成）事件
		return
	end
		if movementName:find("Stand")    then
	elseif movementName:find("Walk")     then
	elseif movementName:find("Run")      then
	elseif movementName:find("Dead")     then
	elseif movementName:find("Attack")   then
		Fight.onAttackDone()
	elseif movementName:find("Injure")   then
		Fight.onInjureDone(armature:getTag())
	elseif movementName:find("Dodge")    then
		Fight.onDodgeDone(armature:getTag())
	elseif movementName:find("Immunity") then
		Fight.onImmunityDone(armature:getTag())
	elseif movementName:find("Enter")    then
		Fight.onEnterDone()
	elseif movementName:find("Exit")     then
		Fight.onExitDone()
	elseif movementName:find("Revive")     then
		Fight.onReviveDone()
	elseif movementName:find("Effect") then
		Fight.onEffectDone(armature:getTag())
	elseif movementName:find("Halo") then
		Fight.onHaloDone(armature:getTag())
	elseif movementName:find("Open") then
		Fight.onOpenDone()
	elseif movementName:find("ui_anim70") then
		Fight.onSplashDone()
	elseif movementName:find("pyro") then
		Fight.onPyroDone(armature:getTag())
	elseif movementName:find("Banner") then
		Fight.onBannerDone()
	elseif movementName:find("BlackBase") then
		Fight.onBlackBaseDone()
	elseif movementName:find("RedBox") then
		Fight.onRedBoxDone()
	elseif movementName:find("action_renwu") then
		Fight.onScriptIntroDone()
	elseif movementName:find("Prepare") then
		Fight.onPrepareFDone()
	elseif movementName:find("Missile") then
		if Fight.missileType == MISSILE_TYPE_NONE then
		elseif Fight.missileType == MISSILE_TYPE_LIGHTNING then
			Fight.onMissileLightningDone(armature:getTag())
		elseif Fight.missileType == MISSILE_TYPE_SINGLE then
		elseif Fight.missileType == MISSILE_TYPE_FULL then
			Fight.onMissileFullDone()
		end
	elseif movementName:find("Buffer_0") then
		Fight.onBufferCreateDone(armature:getParent():getTag(),armature)
	elseif movementName:find("Buffer_1") then
	elseif movementName:find("Buffer_2") then
		local tag = armature:getTag()
		if tag == BUFFER_TYPE_FREEZE then
			Fight.onStandDone()
		elseif tag == BUFFER_TYPE_STUN then
			Fight.onStandDone()
		elseif tag == BUFFER_TYPE_SEAL then
			Fight.onStandDone()
		elseif tag == BUFFER_TYPE_POISON then
			Fight.onPoisonDone()
		elseif tag == BUFFER_TYPE_BURN then
			Fight.onBurnDone()
		elseif tag == BUFFER_TYPE_CURSE then
			Fight.onCurseDone()
		elseif tag == BUFFER_TYPE_INCREASE then
			Fight.onBufferIncreaseDone()
		elseif tag == BUFFER_TYPE_DECREASE then
			Fight.onBufferDecreaseDone()
		elseif tag == BUFFER_TYPE_REDUCTION then
			Fight.onReductionDone(armature:getParent():getTag())
		elseif tag == BUFFER_TYPE_CURELESS then
			Fight.onCurelessDone(armature:getParent():getTag())
		elseif tag == BUFFER_TYPE_REGE then
			Fight.onRegeOfBufferDone()
		end
	else
		cclog("ERROR: Unsupport MovementName: " .. movementName)
	end
end

--异火入场特效开始
function Fight.doPyroEnter()
	Fight.doPyro(Fight.src,function(pos)Fight.onPyroEnterDone()end,{PYRO_JinDiFenTianYan})
end

--异火入场特效完成
function Fight.onPyroEnterDone()
	Fight.doSelectTarget()
end

--异火下场特效开始
function Fight.doPyroExit()
	Fight.doPyro(Fight.src,function(pos)Fight.onPyroExitDone()end,{PYRO_XuWuTunYan})
end

--异火下场特效完成
function Fight.onPyroExitDone()
	Fight.doSelectTarget()
end

--选择目标开始
function Fight.doSelectTarget()
	Fight.damages = {}
	Fight.getDst()
	if #Fight.dst > 0 then
		Fight.yokeDst = Fight.dst[Fight.random(25,1,#Fight.dst)]
	else
		Fight.yokeDst = 0 -- or nil
	end
	for i = 1,#Fight.dst do --重置反击参数
		Fight.fighters[Fight.dst[i]]:setCounter(false)
	end
	Fight.onSelectTargetDone()
end

--选择目标完成
function Fight.onSelectTargetDone()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM or #Fight.dst ~= 0 then
		Fight.doPyrosPreSkill()
	elseif Fight.act == ACT_EXIT then
		Fight.doRevive()
	else
		Fight.onActionDone()
	end
end

--技能前异火开始
function Fight.doPyrosPreSkill()
	local src = Fight.fighters[Fight.src]
	local pyroTable = {}
	local pyroLV
	pyroLV = src:getPyroQingLianDiXinHuo() ; if pyroLV == PYRO_STATE_BERSERK and src:getHP() == src:getHPMax()    then table.insert(pyroTable,PYRO_QingLianDiXinHuo) end
	pyroLV = src:getPyroHaiXinYan()        ; if pyroLV == PYRO_STATE_BERSERK and SkillManager[Fight.sid].regeFunc then table.insert(pyroTable,PYRO_HaiXinYan) end
	if #pyroTable > 0 then
		Fight.doPyro(Fight.src,function(pos)Fight.onPyrosPreSkillDone()end,pyroTable)
	else
		Fight.onPyrosPreSkillDone()
	end
end

--技能前异火完成
function Fight.onPyrosPreSkillDone()
	Fight.doBufferIncrease()
end

--增幅Buffer开始
function Fight.doBufferIncrease()
	--base
	Fight.isMana  = SkillManager[Fight.sid].isMana
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		--基础攻击
		Fight.baseAtt = 0
		--异火攻击加成
		Fight.pyroAtt = 0
		--攻击永久增幅
		Fight.permAtt = 0
	else
		local src = Fight.fighters[Fight.src]
		--基础攻击
		Fight.baseAtt = math.floor(src:getAttack(Fight.isMana))
		--增幅类技能:物攻转法攻or法攻转物攻
		local passiveTRANSkillID,passiveTRANSkillLV = src:getPassiveTRANSkill()
		if passiveTRANSkillID then
			Fight.baseAtt = Fight.baseAtt + math.floor(
				SkillManager[passiveTRANSkillID].addFunc(
					passiveTRANSkillLV,
					Fight.isMana,
					src:getAttack(false), --取消math.floor
					src:getAttack(true),  --取消math.floor
					Fight.random(27)
				)
			)
		end
		--异火攻击加成
		local pyroLV = src:getPyroQingLianDiXinHuo()
		if pyroLV > PYRO_STATE_NULL and src:getHP() == src:getHPMax() then
			Fight.pyroAtt = math.floor(PYRO_QingLianDiXinHuo.var[pyroLV] * Fight.baseAtt)
		else
			Fight.pyroAtt = 0
		end
		--攻击永久增幅
		Fight.permAtt = math.floor(src:getAttackEx() * Fight.baseAtt)
	end
	
	--do
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		Fight.bufAAtt = 0
		Fight.onBufferIncreaseDone()
	else
		local src = Fight.fighters[Fight.src]
		--攻击Buffer增幅
		if src:hasBufferData(BUFFER_TYPE_INCREASE) then
			local bufferArmature = src:getBufferArmature(BUFFER_TYPE_INCREASE)
			bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
			Fight.bufAAtt = math.floor(src:getBufferAttackPercent(BUFFER_TYPE_INCREASE) * Fight.baseAtt + src:getBufferAttackNumber(BUFFER_TYPE_INCREASE))
		else
			Fight.bufAAtt = 0
			Fight.onBufferIncreaseDone()
		end
	end
end

--增幅Buffer完成
function Fight.onBufferIncreaseDone()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
	else
		local src = Fight.fighters[Fight.src]
		if src:hasBufferData(BUFFER_TYPE_INCREASE) then
			local bufferArmature = src:getBufferArmature(BUFFER_TYPE_INCREASE)
			bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
			src:decBufferData(BUFFER_TYPE_INCREASE)
		else
		end
	end
	Fight.doBufferDecrease()
end

--减幅Buffer开始
function Fight.doBufferDecrease()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		Fight.bufDAtt = 0
		Fight.onBufferDecreaseDone()
	else
		local src = Fight.fighters[Fight.src]
		--攻击Buffer减幅
		if src:hasBufferData(BUFFER_TYPE_DECREASE) then
			local bufferArmature = src:getBufferArmature(BUFFER_TYPE_DECREASE)
			bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
			Fight.bufDAtt = math.floor(src:getBufferAttackPercent(BUFFER_TYPE_DECREASE) * Fight.baseAtt + src:getBufferAttackNumber(BUFFER_TYPE_DECREASE))
		else
			Fight.bufDAtt = 0
			Fight.onBufferDecreaseDone()
		end
	end
end

--减幅Buffer完成
function Fight.onBufferDecreaseDone()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
	else
		local src = Fight.fighters[Fight.src]
		if src:hasBufferData(BUFFER_TYPE_DECREASE) then
			local bufferArmature = src:getBufferArmature(BUFFER_TYPE_DECREASE)
			bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
			src:decBufferData(BUFFER_TYPE_DECREASE)
		else
		end
	end

	Fight.timeLineCount = 0
	Fight.doBanner()
end

--RunTo开始
function Fight.doRunTo()
	local runPosition
	Fight.runType,runPosition = Fight.getRunAndPosition()
	if Fight.runType == 0 then
		Fight.onRunToDone()
	elseif Fight.runType == 1 or Fight.runType == 2 then
		Fight.backupX,Fight.backupY = Fight.fighters[Fight.src]:getPosition()
		Fight.fighters[Fight.src]:runAction(
			cc.Sequence:create(
				cc.MoveTo:create(TIME_RUN/Fight.speed,runPosition),
				cc.CallFunc:create(function()Fight.onRunToDone()end)
			)
		)
	elseif Fight.runType == 3 or Fight.runType == 4 then
		Fight.backupX,Fight.backupY = Fight.fighters[Fight.src]:getPosition()
		Fight.backupS = Fight.fighters[Fight.src]:getScale()
		--todo 跑动起始位置
		--Fight.fighters[Fight.src]:setPosition(runPosition.x,Fight.src < 7 and runPosition.y - 100 or runPosition.y + 100)
		Fight.fighters[Fight.src]:setOpacity(0)
		if Fight.runType == 3 then
			Fight.fighters[Fight.src]:runAction(
				cc.Sequence:create(
					cc.Spawn:create(
						cc.ScaleTo:create(0.166/Fight.speed,1.7),
						cc.MoveTo:create(0.166/Fight.speed,runPosition),
						cc.FadeIn:create(0.166/Fight.speed)
					),
					cc.DelayTime:create(0.08333),
					cc.ScaleTo:create(0.333/Fight.speed,0.4),
					cc.CallFunc:create(function()Fight.onRunToDone()end), --!!!跑动结束后，继续异步缩放。
					cc.ScaleTo:create(0.166/Fight.speed,1.5)
				)
			)
		else
			Fight.fighters[Fight.src]:runAction(
				cc.Sequence:create(
					cc.Spawn:create(
						cc.ScaleTo:create(0.166/Fight.speed,1.2),
						cc.MoveTo:create(0.166/Fight.speed,runPosition),
						cc.FadeIn:create(0.166/Fight.speed)
					),
					cc.CallFunc:create(function()Fight.onRunToDone()end), --!!!跑动结束后，继续异步缩放。
					cc.ScaleTo:create(0.664/Fight.speed,1.8),
					cc.ScaleTo:create(0.166/Fight.speed,0.8),
					cc.ScaleTo:create(0.083/Fight.speed,1.5)
				)
			)
		end
		Fight.curtainNode:setVisible(true)
		Fight.curtainNode:runAction(cc.FadeTo:create(0.416/Fight.speed,255))
		local s = Fight.src < 7 and 1 or 7
		local e = Fight.src < 7 and 6 or 12
		for i=s,e do
			local fer = Fight.fighters[i]
			fer:setLocalZOrder(ZORDER_OF_FIGHTER_HIDDEN)
			if fer.wing then
				fer.wing:setLocalZOrder(ZORDER_OF_WING_HIDDEN + 12 - Fight.fixWingZOrder(i))
			end
		end
	end
	if Fight.runType ~= 0 then
		Fight.setFighterAnimation(Fight.src,ANIMATION_RUN,true)
		local src = Fight.fighters[Fight.src]
		src:setLocalZOrder(ZORDER_OF_FIGHTER_ACTIVE)
		if src.wing then
			src.wing:setLocalZOrder(ZORDER_OF_WING_SHOWN + 12 - Fight.fixWingZOrder(Fight.src))
		end
	end
end

--RunTo完成
function Fight.onRunToDone()
	if Fight.runType ~= 0 then
		Fight.setFighterAnimation(Fight.src,ANIMATION_STAND,true)
	end
	Fight.doPrepareB()
	Fight.doPrepareF()
end

--Indicator开始
function Fight.doIndicator()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		if Fight.act == ACT_MANUAL then
			--Fight.bannerIndicator:setPosition(320,0)
			--Fight.bannerIndicator:setRotation(0)
		else --elseif Fight.act == ACT_MMMMMM then
			--Fight.bannerIndicator:setPosition(320,1136)
			--Fight.bannerIndicator:setRotation(180)
		end
		--Fight.bannerIndicator:getAnimation():setSpeedScale(Fight.speed)
		--Fight.bannerIndicator:getAnimation():playWithIndex(0,-1,0)
		--Fight.bannerIndicator:setVisible(true)
	end
end

--Indicator完成
function Fight.onIndicatorDone()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		--Fight.bannerIndicator:setVisible(false)
	end
end

--横幅开始
function Fight.doBanner()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		local iconID
		if Fight.act == ACT_MANUAL then
			iconID = Fight.initData.myData.skillCards[Fight.tag].iconID
		else --elseif Fight.act == ACT_MMMMMM then
			iconID = Fight.initData.otherData[1].skillCards[Fight.tag].iconID
		end
		local pngPath = "image/fight_banner_icon_" .. iconID .. ".png"
		local iconSkin1 = ccs.Skin:create(pngPath)
		local iconSkin2 = ccs.Skin:create(pngPath)
		if iconSkin1 == nil or iconSkin2 == nil then
			iconSkin1 = ccs.Skin:create() --todo default
			iconSkin2 = ccs.Skin:create() --todo default
		end
		--Fight.manualBanner:getBone("Head1"):addDisplay(iconSkin1,0)
		--Fight.manualBanner:getBone("Head2"):addDisplay(iconSkin2,0)
		--Fight.manualBanner:getBone("Name"):addDisplay(ccs.Skin:create(SkillManager[Fight.sid].animation),0)
		--Fight.manualBanner:getAnimation():setSpeedScale(Fight.speed)
		--Fight.manualBanner:getAnimation():playWithIndex(0,-1,0)
		--Fight.manualBanner:setPosition(320,568)
		--Fight.manualBanner:setVisible(true)
		Fight.playEffect("SkillBanner")
		Fight.doIndicator()
	else
		if SkillManager[Fight.sid].bannerType == nil then
			Fight.onBannerDone()
		elseif SkillManager[Fight.sid].bannerType == false then
			Fight.bannerMini:getAnimation():playWithIndex(0,-1,0)
			Fight.bannerMini:getAnimation():setSpeedScale(Fight.speed)
			Fight.bannerMini:getBone("zi"):addDisplay(cc.Label:createWithTTF(SkillManager[Fight.sid].name,dp.FONT,16),0)
			Fight.bannerMini:setPosition(Fight.fighters[Fight.src]:getPosition())
			Fight.bannerMini:setVisible(true)
			if SkillManager[Fight.sid].shout then
				Fight.playSound(Fight.fighters[Fight.src]:getCardID())
			end
		elseif Fight.fighters[Fight.src]:isShowBanner() then
			local cardData = DictCard[tostring(Fight.fighters[Fight.src]:getCardID())]
			local pngPath = "image/" .. DictUI[tostring(Fight.fighters[Fight.src]:isAwoken() and cardData.awakeBigUiId or cardData.bigUiId)].fileName
			local iconSkin = ccs.Skin:create(pngPath)
			Fight.fighterBanner:getBone("card"):addDisplay(iconSkin,0)
			local name01 = cc.Label:createWithTTF(SkillManager[Fight.sid].name,dp.FONT,56)
			local name02 = cc.Label:createWithTTF(SkillManager[Fight.sid].name,dp.FONT,56)
			name01:setTextColor(cc.c4b(0xFF,0xF5,0x57,0xFF))
			name02:setTextColor(cc.c4b(0xFF,0xF5,0x57,0xFF))
			name01:enableOutline(cc.c4b(0xFF,0,0,0xFF),3)
			name02:enableOutline(cc.c4b(0xFF,0,0,0xFF),3)
			Fight.fighterBanner:getBone("name01"):addDisplay(name01,0)
			Fight.fighterBanner:getBone("name02"):addDisplay(name02,0)
			Fight.fighterBanner:getAnimation():playWithIndex(0,-1,0)
			Fight.fighterBanner:getAnimation():setSpeedScale(Fight.speed)
			Fight.fighterBanner:setPosition(320,568)
			Fight.fighterBanner:setVisible(true)
			Fight.playEffect("FighterBanner")
			if SkillManager[Fight.sid].shout then
				Fight.playSound(Fight.fighters[Fight.src]:getCardID())
			end
		else
			Fight.onBannerDone()
		end
	end
end

--横幅触发
function Fight.onBannerTrigger()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		if SkillManager[Fight.sid].bgAction then
			Fight.doBlackBase()
			Fight.doRedBox()
		end
	else
	end
end

--横幅完成
function Fight.onBannerDone()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		--Fight.manualBanner:setVisible(false)
		Fight.onIndicatorDone()
	else
		if SkillManager[Fight.sid].bannerType == nil then
		elseif SkillManager[Fight.sid].bannerType == false then
			Fight.bannerMini:setVisible(false)
		elseif Fight.fighters[Fight.src]:isShowBanner() then
			Fight.fighterBanner:setVisible(false)
		else
		end
	end
	Fight.doRunTo()
end

--BlackBase开始
function Fight.doBlackBase()
	Fight.timeLineCount = Fight.timeLineCount + 1
	Fight.playEffect("BlackBase" .. SkillManager[Fight.sid].bgAction)
	Fight.blackBaseNode = ccs.Armature:create("BlackBase" .. SkillManager[Fight.sid].bgAction)
	local actionCount = Fight.blackBaseNode:getAnimation():getMovementCount()
	if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then
		if actionCount == 3 then
			Fight.blackBaseNode:setRotation(180)
		end
	else
		if actionCount == 2 then
			Fight.blackBaseNode:setRotation(180)
		end
	end
	Fight.blackBaseNode:setScale(2)
	Fight.blackBaseNode:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	Fight.blackBaseNode:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	Fight.shakeNode:addChild(Fight.blackBaseNode)
	Fight.blackBaseNode:setLocalZOrder(ZORDER_OF_BLACKBASE)
	Fight.blackBaseNode:setPosition(320,568)
	Fight.blackBaseNode:getAnimation():setSpeedScale(Fight.speed)
	Fight.blackBaseNode:getAnimation():playWithIndex(0,-1,0)
end

--BlackBase完成
function Fight.onBlackBaseDone()
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.blackBaseNode:removeFromParent()
	Fight.doSetupBufferOfYokeLight()
end

--RedBox开始
function Fight.doRedBox()
	Fight.timeLineCount = Fight.timeLineCount + 1
	Fight.redBoxNode:setVisible(true)
	Fight.redBoxNode:getAnimation():setSpeedScale(Fight.speed)
	Fight.redBoxNode:getAnimation():playWithIndex(0,-1,0)
end

--RedBox完成
function Fight.onRedBoxDone()
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.redBoxNode:setVisible(false)
	Fight.doSetupBufferOfYokeLight()
end

--准备B开始
function Fight.doPrepareB()
	Fight.timeLineCount = Fight.timeLineCount + 1
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM or not SkillManager[Fight.sid].prepareActionF or not SkillManager[Fight.sid].prepareActionB then
		Fight.onPrepareBDone()
	else
		--Fight.playEffect("Prepare" .. SkillManager[Fight.sid].prepareActionB) --背景不播放声效
		local prepareArmature = ccs.Armature:create("Prepare" .. SkillManager[Fight.sid].prepareActionB)
		prepareArmature:setScale(3)
		prepareArmature:setPosition(Fight.fighters[Fight.src]:getPosition())
		prepareArmature:getAnimation():setSpeedScale(Fight.speed)
		--prepareArmature:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack) --无帧事件
		prepareArmature:getAnimation():setMovementEventCallFunc(
			function(armature,movementType,movementName)
				if movementType ~= ccs.MovementEventType.start then --不关注开始事件，只关注完成（或循环完成）事件
					Fight.onPrepareBDone()
				end
			end
		)
		prepareArmature:getAnimation():playWithIndex(0,-1,0)
		prepareArmature:setLocalZOrder(ZORDER_OF_PREPARE_BACKGROUND)
		Fight.shakeNode:addChild(prepareArmature)
		Fight.prepareNodeB = prepareArmature
	end
end

--准备B完成
function Fight.onPrepareBDone()
	Fight.timeLineCount = Fight.timeLineCount - 1
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM or not SkillManager[Fight.sid].prepareActionF or not SkillManager[Fight.sid].prepareActionB then
		--nothing
	else
		Fight.prepareNodeB:removeFromParent()
		Fight.doSetupBufferOfYokeLight()
	end
end

--准备F开始
function Fight.doPrepareF()
	Fight.timeLineCount = Fight.timeLineCount + 1
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM or not SkillManager[Fight.sid].prepareActionF then
		Fight.onPrepareFDone()
	else
		Fight.playEffect("Prepare" .. SkillManager[Fight.sid].prepareActionF)
		local prepareArmature = ccs.Armature:create("Prepare" .. SkillManager[Fight.sid].prepareActionF)
		prepareArmature:setScale(3)
		prepareArmature:setPosition(Fight.fighters[Fight.src]:getPosition())
		prepareArmature:getAnimation():setSpeedScale(Fight.speed)
		prepareArmature:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
		prepareArmature:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
		prepareArmature:getAnimation():playWithIndex(0,-1,0)
		prepareArmature:setLocalZOrder(ZORDER_OF_PREPARE_FOREGROUND)
		Fight.shakeNode:addChild(prepareArmature)
		Fight.prepareNodeF = prepareArmature
	end
end

--准备F触发
function Fight.onPrepareTrigger()
	Fight.doAttack()
end

--准备F触发2
function Fight.onSJLTrigger()
	if SkillManager[Fight.sid].bgAction then
		Fight.doBlackBase()
	end
end

--准备F完成
function Fight.onPrepareFDone()
	Fight.timeLineCount = Fight.timeLineCount - 1
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM or not SkillManager[Fight.sid].prepareActionF then
		Fight.doAttack()
	else
		Fight.prepareNodeF:removeFromParent()
		Fight.doSetupBufferOfYokeLight()
	end
end

--攻击开始
function Fight.doAttack()
	Fight.timeLineCount = Fight.timeLineCount + 1
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		--手动技能，攻击增幅类技能数值为0
		Fight.incrAtt = 0
		Fight.deadAtt = 0
	else
		local src = Fight.fighters[Fight.src]
		--攻击增幅类技能，概率判定
		Fight.incrAtt = 0
		local passivePROBSkillID,passivePROBSkillLV = src:getPassivePROBSkill()
		if passivePROBSkillID then
			Fight.incrAtt = math.floor(SkillManager[passivePROBSkillID].addFunc(passivePROBSkillLV,Fight.isMana,Fight.baseAtt,Fight.random(8)))
		end
		--攻击增幅类技能，死亡人数判定
		Fight.deadAtt = 0
		local passiveDEADSkillID,passiveDEADSkillLV = src:getPassiveDEADSkill()
		if passiveDEADSkillID then
			Fight.deadAtt = math.floor(
				SkillManager[passiveDEADSkillID].addFunc(
					passiveDEADSkillLV,
					Fight.baseAtt,
					Fight.src < 7 and Fight.myDeaths    or Fight.otherDeaths,
					Fight.src < 7 and Fight.otherDeaths or Fight.myDeaths
				)
			)
		end
	end
	for i=1,#Fight.dst do
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+0] = Fight.random(9)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+12] = Fight.random(10)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+24] = Fight.random(11)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+36] = Fight.random(12,FLOAT_DAMAGE_PERCENT_MIN,FLOAT_DAMAGE_PERCENT_MAX)/100
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+48] = Fight.random(13)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+60] = Fight.random(14)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+72] = Fight.random(15)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+84] = Fight.random(16)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+96] = Fight.random(17)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+108] = Fight.random(18)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+120] = Fight.random(19)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+132] = Fight.random(20)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+144] = Fight.random(21)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+156] = Fight.random(22)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+168] = Fight.random(23)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+192] = Fight.random(25)
	end
	--!!!不判断Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM，assert:Fight.dst不包含Fight.src
	Fight.FIX_BUG_OF_GET_RANDOM[Fight.src+180] = Fight.random(24)
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		Fight.onAttackDone()
	else
		Fight.playEffect("FighterAttack" .. SkillManager[Fight.sid].attackAction)
		Fight.setFighterAnimation(Fight.src,ANIMATION_ATTACK_0 + SkillManager[Fight.sid].attackAction,false)
	end
end

--攻击触发
function Fight.onAttackTrigger()
	Fight.doSelectMissile()
end

--攻击完成
function Fight.onAttackDone()
	Fight.timeLineCount = Fight.timeLineCount - 1
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		Fight.doSelectMissile()
	else
		Fight.setFighterAnimation(Fight.src,ANIMATION_STAND,true)
		Fight.doSetupBufferOfYokeLight()
	end
end

--选择导弹开始
function Fight.doSelectMissile()
	Fight.onSelectMissileDone()
end

--选择导弹完成
function Fight.onSelectMissileDone()
	--!!! 导弹（闪电、单体、群体）只会打敌人!!!
	if SkillManager[Fight.sid].regeFunc or SkillManager[Fight.sid].clearFunc or not SkillManager[Fight.sid].missileAction then
		Fight.missileType = MISSILE_TYPE_NONE
		Fight.doMissileNone()
	elseif SkillManager[Fight.sid].missileAction >= 0 then --单体导弹
		if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM or #Fight.dst == 0 then
			Fight.missileType = MISSILE_TYPE_NONE
			Fight.doMissileNone()
		elseif isMissileLightning(SkillManager[Fight.sid].missileAction) then --闪电导弹
			Fight.missileType = MISSILE_TYPE_LIGHTNING
			Fight.doMissileLightning(1)
		else
			Fight.missileType = MISSILE_TYPE_SINGLE
			Fight.doMissileSingle()
		end
	else --全屏导弹
		Fight.missileType = MISSILE_TYPE_FULL
		Fight.doMissileFull()
	end
end

--无导弹开始
function Fight.doMissileNone()
	Fight.timeLineCount = Fight.timeLineCount + 1
	Fight.onMissileNoneDone()
end

--无导弹完成
function Fight.onMissileNoneDone()
	Fight.timeLineCount = Fight.timeLineCount - 1
	for i=1,#Fight.dst do
		Fight.doEffect(Fight.dst[i])
		Fight.doHalo(Fight.dst[i])
	end
	Fight.doSetupBufferOfYokeLight()
end

--闪电开始
function Fight.doMissileLightning(idx) --!!!NOT pos
	Fight.timeLineCount = Fight.timeLineCount + 1
	local srcX,srcY
	if idx == 1 then
		srcX,srcY = Fight.fighters[Fight.src]:getPosition()
	else
		srcX,srcY = Fight.fighters[Fight.dst[idx-1]]:getPosition()
	end
	local dstX,dstY = Fight.fighters[Fight.dst[idx]]:getPosition()
	Fight.playEffect("Missile" .. SkillManager[Fight.sid].missileAction)
	local missileArmature = ccs.Armature:create("Missile" .. SkillManager[Fight.sid].missileAction)
	missileArmature:setTag(idx)
	missileArmature:setScale(2,2*math.sqrt(math.pow(dstX - srcX,2)+math.pow(dstY - srcY,2))/MISSILE_LIGHTNING_HEIGHT)
	missileArmature:setRotation(math.deg(math.atan2(dstX - srcX,dstY - srcY)))
	missileArmature:setPosition(srcX,srcY)
	missileArmature:getAnimation():setSpeedScale(Fight.speed)
	missileArmature:getAnimation():playWithIndex(0,-1,0)
	missileArmature:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	missileArmature:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	missileArmature:setLocalZOrder(ZORDER_OF_MISSILE)
	Fight.shakeNode:addChild(missileArmature)
	Fight.missileNodes[idx] = missileArmature
end

--闪电触发
function Fight.onMissileLightningTrigger(idx) --!!!NOT pos
	local pos = Fight.dst[idx]
	Fight.doEffect(pos)
	Fight.doHalo(pos)
end

--闪电触发
function Fight.onSimidaTrigger(idx) --!!!NOT pos
	if idx < #Fight.dst then
		Fight.doMissileLightning(idx + 1)
	end
end

--闪电完成
function Fight.onMissileLightningDone(idx) --!!!NOT pos
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.missileNodes[idx]:removeFromParent()
	Fight.doSetupBufferOfYokeLight()
end

--单体导弹开始
function Fight.doMissileSingle()
	Fight.timeLineCount = Fight.timeLineCount + 1
	local srcX,srcY = Fight.fighters[Fight.src]:getPosition()
	Fight.playEffect("Missile" .. SkillManager[Fight.sid].missileAction)
	local isFlyOver = isMissileFlyOver(SkillManager[Fight.sid].missileAction)
	local maxt = 0
	for i=1,#Fight.dst do
		local dstX,dstY = Fight.fighters[Fight.dst[i]]:getPosition()
		local missileArmature = ccs.Armature:create("Missile" .. SkillManager[Fight.sid].missileAction)
		missileArmature:setScale(3)
		missileArmature:setPosition(srcX,srcY)
		missileArmature:getAnimation():setSpeedScale(Fight.speed)
		missileArmature:getAnimation():playWithIndex(0,-1,1)
		missileArmature:setRotation(math.deg(math.atan2(dstX - srcX,dstY - srcY)))
		local deltaX,deltaY = dstX - srcX,dstY - srcY
		local outX,outY = dstX,dstY
		local tttt = 0
		if deltaX ~= 0 or deltaY ~= 0 then
			repeat
				tttt = tttt + 1
				outX = outX + deltaX
				outY = outY + deltaY
			until outX < -320 or outX > 960 or outY < -568 or outY > 2272
		end
		if tttt > maxt then
			maxt = tttt
		end
		local actions = {}
		table.insert(actions,cc.MoveTo:create(TIME_MISSILE/Fight.speed,cc.vertex2F(dstX,dstY)))
		if isFlyOver then
			table.insert(actions,cc.MoveTo:create(TIME_MISSILE/Fight.speed * tttt,cc.vertex2F(outX,outY)))
		end
		missileArmature:runAction(cc.Sequence:create(actions))
		Fight.shakeNode:addChild(missileArmature)
		missileArmature:setLocalZOrder(ZORDER_OF_MISSILE)
		Fight.missileNodes[Fight.dst[i]] = missileArmature
	end
	local actions = {}
	table.insert(actions,cc.DelayTime:create(TIME_MISSILE/Fight.speed))
	table.insert(actions,cc.CallFunc:create(function()Fight.onMissileSingleTrigger()end))
	if isFlyOver then
		table.insert(actions,cc.DelayTime:create(TIME_MISSILE/Fight.speed * maxt))
	end
	table.insert(actions,cc.CallFunc:create(function()Fight.onMissileSingleDone()end))
	Fight.missileNodes[Fight.dst[1]]:runAction(cc.Sequence:create(actions))
end

--单体导弹触发
function Fight.onMissileSingleTrigger()
	for i=1,#Fight.dst do
		Fight.doEffect(Fight.dst[i])
		Fight.doHalo(Fight.dst[i])
	end
end

--单体导弹完成
function Fight.onMissileSingleDone()
	Fight.timeLineCount = Fight.timeLineCount - 1
	for i=1,#Fight.dst do
		Fight.missileNodes[Fight.dst[i]]:removeFromParent()
	end
	Fight.doSetupBufferOfYokeLight()
end

--全屏导弹开始
function Fight.doMissileFull()
	Fight.timeLineCount = Fight.timeLineCount + 1
	Fight.playEffect("Missile" .. SkillManager[Fight.sid].missileAction)
	local missileArmature = ccs.Armature:create("Missile" .. SkillManager[Fight.sid].missileAction)
	local actionCount = missileArmature:getAnimation():getMovementCount()
	missileArmature:setScale(2)
	if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then
		if actionCount == 3 then
			missileArmature:setRotation(180)
		end
		missileArmature:setPosition(320,853)
	else
		if actionCount == 2 then
			missileArmature:setRotation(180)
		end
		missileArmature:setPosition(320,261)
	end
	missileArmature:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	missileArmature:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	missileArmature:getAnimation():setSpeedScale(Fight.speed)
	missileArmature:getAnimation():playWithIndex(0,-1,0)
	missileArmature:setLocalZOrder(ZORDER_OF_MISSILE)
	Fight.shakeNode:addChild(missileArmature)
	Fight.missileNodes[1] = missileArmature --!!!use index 1
end

--全屏导弹触发
function Fight.onMissileFullTrigger()
	for i = 1,#Fight.dst do
		Fight.doEffect(Fight.dst[i])
		Fight.doHalo(Fight.dst[i])
	end
end

--全屏导弹完成
function Fight.onMissileFullDone()
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.missileNodes[1]:removeFromParent() --!!!use index 1
	Fight.doSetupBufferOfYokeLight()
end

--打击光效开始
function Fight.doEffect(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	Fight.playEffect("Effect" .. SkillManager[Fight.sid].effectAction)
	local effectArmature = ccs.Armature:create("Effect" .. SkillManager[Fight.sid].effectAction)
	effectArmature:setTag(pos)
	effectArmature:setScale(3)
	effectArmature:getAnimation():setSpeedScale(Fight.speed)
	effectArmature:getAnimation():playWithIndex(0,-1,0)
	effectArmature:setPosition(Fight.fighters[pos]:getPosition())
	effectArmature:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
	effectArmature:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
	Fight.shakeNode:addChild(effectArmature)
	effectArmature:setLocalZOrder(ZORDER_OF_EFFECT)
	Fight.effectNodes[pos] = effectArmature
end

--打击光效触发
function Fight.onEffectTrigger(pos)
	local dst = Fight.fighters[pos]
	--回复
	if SkillManager[Fight.sid].regeFunc then
		if dst:hasBufferData(BUFFER_TYPE_CURELESS) then
			Fight.doCureless(pos)
		else
			Fight.doRege(pos)
		end
	else
		if SkillManager[Fight.sid].clearFunc then
			Fight.doClear(pos)
		else
			--闪避
			local function isDodge()
				if SkillManager[Fight.sid].target > 0 and Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
					local src = Fight.fighters[Fight.src]
					--闪避率=0.4*敌方闪避/(敌方闪避+本方命中)+0.6*敌方闪避率*(1-4*本方命中率)
					local dodgeRatio = (0.4*dst:getDodge()/(dst:getDodge()+src:getHit()) + 0.6*dst:getDodgeRatio()*(1-4*src:getHitRatio()))
					dodgeRatio = dodgeRatio < 0.00 and 0.00 or dodgeRatio
					dodgeRatio = dodgeRatio > 0.15 and 0.15 or dodgeRatio
					if Fight.FIX_BUG_OF_GET_RANDOM[pos+0] < dodgeRatio then
						return true
					end
				end
				return false
			end
			local dodgable = true
			if Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
				local src = Fight.fighters[Fight.src]
				local pyroLV = src:getPyroWanShouLingYan()
				if pyroLV > PYRO_STATE_NULL then
					dodgable = not PYRO_WanShouLingYan.var[pyroLV]
				end
			end
			if dodgable and isDodge() then
				Fight.doDodge(pos)
			else
				--免疫攻击
				local passiveIMATSkillID,passiveIMATSkillLV = dst:getPassiveIMATSkill()
				if SkillManager[Fight.sid].target > 0 and not SkillManager[Fight.sid].ignoreIMRE
					and (
							(passiveIMATSkillID and SkillManager[passiveIMATSkillID].immunityAttackFunc(passiveIMATSkillLV,Fight.isMana,Fight.FIX_BUG_OF_GET_RANDOM[pos+12]))
							or Fight.FIX_BUG_OF_GET_RANDOM[pos+168] < (Fight.isMana and dst:getImmunityManaRatio() or dst:getImmunityPhscRatio())
						)
					then
					Fight.doImmunity(pos)
				else--承受
					if SkillManager[Fight.sid].attackFunc then
						Fight.doInjure(pos)
					else
						Fight.doSetupBufferOfSkill(pos)
					end
				end
			end
		end
	end
end

--打击光效完成
function Fight.onEffectDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.effectNodes[pos]:removeFromParent()
	Fight.doSetupBufferOfYokeLight()
end

--光晕开始
function Fight.doHalo(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	if SkillManager[Fight.sid].haloAction then
		local haloArmature = ccs.Armature:create("Halo" .. SkillManager[Fight.sid].haloAction)
		haloArmature:setTag(pos)
		haloArmature:setScale(3)
		haloArmature:getAnimation():setSpeedScale(Fight.speed)
		haloArmature:getAnimation():playWithIndex(0,-1,0)
		haloArmature:setPosition(Fight.fighters[pos]:getPosition())
		Fight.shakeNode:addChild(haloArmature)
		haloArmature:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
		haloArmature:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
		haloArmature:setLocalZOrder(ZORDER_OF_HALO)
		Fight.haloNodes[pos] = haloArmature
	else
		Fight.onHaloDone(pos)
	end
end

--光晕完成
function Fight.onHaloDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	if SkillManager[Fight.sid].haloAction then
		Fight.haloNodes[pos]:removeFromParent()
		Fight.doSetupBufferOfYokeLight()
	end
end

--无法被治疗开始
function Fight.doCureless(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	local dst = Fight.fighters[pos]
	local bufferArmature = dst:getBufferArmature(BUFFER_TYPE_CURELESS)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
end

--无法被治疗完成
function Fight.onCurelessDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	local dst = Fight.fighters[pos]
	local bufferArmature = dst:getBufferArmature(BUFFER_TYPE_CURELESS)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
	dst:decBufferData(BUFFER_TYPE_CURELESS)
	Fight.doClear(pos)
end

--回复开始
function Fight.doRege(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	local dst = Fight.fighters[pos]
	local regeHP = math.floor(SkillManager[Fight.sid].regeFunc(Fight.slv,Fight.baseAtt + Fight.pyroAtt + Fight.permAtt + Fight.bufAAtt - Fight.bufDAtt)/3) --!!!调整伤害公式所需的同步修改 /3
	local pyroLV = Fight.fighters[Fight.src]:getPyroHaiXinYan()
	if pyroLV > PYRO_STATE_NULL then
		regeHP = dst:getHPMax()
		dst:addDefenceEx(PYRO_HaiXinYan.var[pyroLV])
	end
	dst:addHP(regeHP)
	dst:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(0.5/Fight.speed), --!!!为了延长时间轴
			cc.CallFunc:create(function()Fight.onRegeDone(pos)end)
		)
	)
	Fight.showDamage(regeHP,DAMAGE_TYPE_REGENERATION,dst:getPosition())
	--Fight.onRegeDone(pos)
end

--回复完成
function Fight.onRegeDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.doClear(pos)
end

--清除Buffer开始
function Fight.doClear(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	if SkillManager[Fight.sid].clearFunc then
		local dst = Fight.fighters[pos]
		local bufferIDs = SkillManager[Fight.sid].clearFunc(Fight.slv)
		for i=1,#bufferIDs do
			dst:setBufferData(bufferIDs[i],nil)
		end
	end
	Fight.onClearDone(pos)
end

--清除Buffer完成
function Fight.onClearDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.doSetupBufferOfYokeLight()
end

--闪避开始
function Fight.doDodge(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	Fight.fighters[pos]:setLocalZOrder(ZORDER_OF_FIGHTER_PASSIVE + 12 - pos)
	Fight.setFighterAnimation(pos,ANIMATION_DODGE,false)
end

--闪避完成
function Fight.onDodgeDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.fighters[pos]:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - pos)
	Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
	Fight.doSetupBufferOfYokeLight()
end

--免疫开始
function Fight.doImmunity(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	Fight.fighters[pos]:setLocalZOrder(ZORDER_OF_FIGHTER_PASSIVE + 12 - pos)
	Fight.setFighterAnimation(pos,ANIMATION_IMMUNITY,false)
end

--免疫完成
function Fight.onImmunityDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.fighters[pos]:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - pos)
	Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
	Fight.doSetupBufferOfYokeLight()
end

--Buffer减伤开始
function Fight.doReduction(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	local dst = Fight.fighters[pos]
	local bufferArmature = dst:getBufferArmature(BUFFER_TYPE_REDUCTION)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
end

--Buffer减伤完成
function Fight.onReductionDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	local dst = Fight.fighters[pos]
	local bufferArmature = dst:getBufferArmature(BUFFER_TYPE_REDUCTION)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
	dst:decBufferData(BUFFER_TYPE_REDUCTION)
	Fight.doSetupBufferOfYokeLight()
end

--受伤开始
function Fight.doInjure(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	Fight.fighters[pos]:setLocalZOrder(ZORDER_OF_FIGHTER_PASSIVE + 12 - pos)
	Fight.setFighterAnimation(pos,ANIMATION_INJURE_0 + SkillManager[Fight.sid].injureAction,false)
	Fight.onInjureTrigger(pos)
	if SkillManager[Fight.sid].shakable then
		Fight.startShake()
	end
end

--受伤触发
function Fight.onInjureTrigger(pos)
	if not SkillManager[Fight.sid].attackFunc then
		return
	end

	local dst = Fight.fighters[pos]
	local def = math.floor(dst:getDefence(Fight.isMana))
	def = def + math.floor(def * dst:getDefenceEx()) --防御永久增幅
	local damageType = DAMAGE_TYPE_GENERIC
	local skilAtt = 0
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		--计算技能攻击值
		skilAtt = math.floor(SkillManager[Fight.sid].attackFunc(
			Fight.slv,
			Fight.baseAtt + Fight.pyroAtt + Fight.permAtt + Fight.bufAAtt - Fight.bufDAtt,
			Fight.isMana,
			0,
			0,
			dst:getHP(),
			dst:getHPMax(),
			Fight.act == ACT_MANUAL and Fight.myDeaths or Fight.otherDeaths,
			Fight.act == ACT_MMMMMM and Fight.myDeaths or Fight.otherDeaths,
			Fight.FIX_BUG_OF_GET_RANDOM[pos+108],
			{},
			dst:getBufferTypes(),
			Fight.initData.isBoss
		))
		--手动技能，攻击增幅类技能数值为0
		Fight.hphpAtt = 0 --攻击增幅类技能，血量对比判定
		Fight.buffAtt = 0 --攻击增幅类技能，目标Buff判定
	else
		local src = Fight.fighters[Fight.src]
		--计算技能攻击值
		skilAtt = math.floor(SkillManager[Fight.sid].attackFunc(
			Fight.slv,
			Fight.baseAtt + Fight.pyroAtt + Fight.permAtt + Fight.bufAAtt - Fight.bufDAtt,
			Fight.isMana,
			src:getHP(),
			src:getHPMax(),
			dst:getHP(),
			dst:getHPMax(),
			Fight.src < 7 and Fight.myDeaths    or Fight.otherDeaths,
			Fight.src < 7 and Fight.otherDeaths or Fight.myDeaths,
			Fight.FIX_BUG_OF_GET_RANDOM[pos+108],
			src:getBufferTypes(),
			dst:getBufferTypes(),
			Fight.initData.isBoss
		))
		--暴击
		local function isCrit()
			if dst:getRenXing() == 0 then
				return true
			end
			--暴击率=0.4*本方暴击/(本方暴击+敌方韧性)+0.6*本方暴击率*(1-4*敌方韧性率)+斗魂本方增暴击/2-敌方斗魂减暴击/2              韧性率==抗暴率
			local critRatio = 0.4*src:getCrit()/(src:getCrit()+dst:getRenXing()) + 0.6*src:getCritRatio()*(1-4*dst:getRenXingRatio()) + src:getCritRatioDHAdd()/2 - dst:getCritRatioDHSub()/2
			critRatio = critRatio < 0.0 and 0.0 or critRatio
			critRatio = critRatio > 0.3 and 0.3 or critRatio
			if Fight.FIX_BUG_OF_GET_RANDOM[pos+24] < critRatio then
				return true
			end
			return false
		end
		if isCrit() then
			damageType = DAMAGE_TYPE_CRIT
		end
		--攻击增幅类技能，血量对比判定
		Fight.hphpAtt = 0
		local passiveHPHPSkillID,passiveHPHPSkillLV = src:getPassiveHPHPSkill()
		if passiveHPHPSkillID then
			Fight.hphpAtt = math.floor(SkillManager[passiveHPHPSkillID].addFunc(passiveHPHPSkillLV,Fight.baseAtt,src:getHP(),dst:getHP()))
		end
		--攻击增幅类技能，目标Buff判定
		Fight.buffAtt = 0
		local passiveBUFFSkillID,passiveBUFFSkillLV = src:getPassiveBUFFSkill()
		if passiveBUFFSkillID then
			local bufferTypes = dst:getBufferTypes()
			Fight.buffAtt = math.floor(SkillManager[passiveBUFFSkillID].addFunc(passiveBUFFSkillLV,Fight.baseAtt,bufferTypes))
		end
	end
	--计算综合攻击值
	local att = skilAtt + Fight.incrAtt + Fight.hphpAtt + Fight.buffAtt + Fight.deadAtt
	--计算伤害值公式：伤害=攻击/3*(1-减伤比)	!!!!	减伤比=防御/(防御+属性增值*70)
	local reducePercent = def/(def+dst:getSXZZ()*70)
	reducePercent = math.min(reducePercent,0.3)
	reducePercent = math.max(reducePercent,0.0)
	local damageOri=math.floor(att/4*(1-reducePercent))
	if damageOri < 10 then
		damageOri = 10
	end
	damageOri = math.floor(damageOri * SkillManager[Fight.sid].damageRatio)
	damageOri = math.floor(damageOri * Fight.FIX_BUG_OF_GET_RANDOM[pos+36])
	local damageCur = damageOri
	--是否无视减伤
	local isIgnoreIMRE = false
	if Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
		local src = Fight.fighters[Fight.src]
		local pyroLV = src:getPyroWanShouLingYan()
		isIgnoreIMRE = pyroLV > PYRO_STATE_NULL
	end
	if not isIgnoreIMRE and not SkillManager[Fight.sid].ignoreIMRE then
		--减伤类技能
		local passiveREDUSkillID,passiveREDUSkillLV = dst:getPassiveREDUSkill()
		if passiveREDUSkillID then
			damageCur = damageCur - math.floor(SkillManager[passiveREDUSkillID].reduceFunc(passiveREDUSkillLV,Fight.isMana,damageCur,Fight.FIX_BUG_OF_GET_RANDOM[pos+48]))
		end
		--减伤Buffer
		if dst:hasBufferData(BUFFER_TYPE_REDUCTION) then
			damageCur = damageCur - math.floor(dst:getBufferDamagePercent(BUFFER_TYPE_REDUCTION) * damageOri + dst:getBufferDamageNumber(BUFFER_TYPE_REDUCTION))
			Fight.doReduction(pos)
		end
	end
	--风系羁绊增加伤害
	if Fight.fighters[Fight.src]:hasYokeWind() then
		if Fight.FIX_BUG_OF_GET_RANDOM[pos+144] < YOKE_Wind.chance then
			damageCur = math.floor(damageCur * (1+YOKE_Wind.damageIncrease))
		end
	end
	--暴击
	if damageType == DAMAGE_TYPE_CRIT then
		local critDamageX = CRIT_DAMAGE_X
		if Fight.act ~= ACT_MANUAL or Fight.act ~= ACT_MMMMMM then
			local src = Fight.fighters[Fight.src]
			critDamageX = critDamageX + src:getCritPercentAdd() - dst:getCritPercentSub()
			critDamageX = math.min(critDamageX,CRIT_DAMAGE_MAX)
			critDamageX = math.max(critDamageX,CRIT_DAMAGE_MIN)
		end
		damageCur = math.floor(damageCur * critDamageX)
	end
	--修正最终伤害值
	if damageCur < 0 then
		damageCur = 0
	end
	damageCur = math.floor(damageCur * (1+Fight.fighters[Fight.src]:getSHJC()/100))
	--战力减伤
	if pos < 7 then
		damageCur = math.floor(damageCur * (1-Fight.myPowerReduction))
	else
		damageCur = math.floor(damageCur * (1-Fight.otherPowerReduction))
	end
	Fight.damages[pos] = damageCur
	local immunityCount = dst:getImmunityCount(Fight.isMana)
	if not Fight.initData.isBoss and immunityCount > 0 then
		dst:setImmunityCount(Fight.isMana,immunityCount - 1)
	else
		local hpLimit
		if SkillManager[Fight.sid].subHpLimit then
			if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
				hpLimit = math.floor(SkillManager[Fight.sid].subHpLimit(
					Fight.slv,
					damageCur,
					Fight.FIX_BUG_OF_GET_RANDOM[pos+192],
					0,
					0,
					dst:getHP(),
					dst:getHPMax(),
					Fight.act == ACT_MANUAL and Fight.myDeaths or Fight.otherDeaths,
					Fight.act == ACT_MMMMMM and Fight.myDeaths or Fight.otherDeaths,
					{},
					dst:getBufferTypes()
				))
			else
				local src = Fight.fighters[Fight.src]
				hpLimit = math.floor(SkillManager[Fight.sid].subHpLimit(
					Fight.slv,
					damageCur,
					Fight.FIX_BUG_OF_GET_RANDOM[pos+192],
					src:getHP(),
					src:getHPMax(),
					dst:getHP(),
					dst:getHPMax(),
					Fight.src < 7 and Fight.myDeaths    or Fight.otherDeaths,
					Fight.src < 7 and Fight.otherDeaths or Fight.myDeaths,
					src:getBufferTypes(),
					dst:getBufferTypes()
				))
			end
		end
		dst:subHP(damageCur,hpLimit)
		if not Fight.initData.isBoss or Fight.src ~= BOSS_POSITION then
			local passiveREBOUNDSkillID,passiveREBOUNDSkillLV = dst:getPassiveREBOUNDSkill()
			if passiveREBOUNDSkillID then
				local reboundDamage = math.floor(SkillManager[passiveREBOUNDSkillID].reboundFunc(passiveREBOUNDSkillLV,damageCur,dst:getBufferTypes()))
				if reboundDamage and reboundDamage > 0 then
					local src = Fight.fighters[Fight.src]
					src:subHP(reboundDamage)
					Fight.showDamage(reboundDamage,DAMAGE_TYPE_GENERIC,src:getPosition())
				end
			end
		end
		--暗系羁绊吸血
		if Fight.fighters[Fight.src]:hasYokeDark() then
			if Fight.FIX_BUG_OF_GET_RANDOM[pos+156] < YOKE_Dark.chance then
				Fight.fighters[Fight.src]:addHP(math.floor(damageCur * YOKE_Dark.lifeSteal))
			end
		end
		dst:setCounter(damageCur ~= 0) --!!! 伤害为0时不反击
		if damageType ~= DAMAGE_TYPE_REGENERATION and SkillManager[Fight.sid].blood then
			if damageType == DAMAGE_TYPE_CRIT then
				damageType = DAMAGE_TYPE_GENERIC
			end
			local d   = math.floor(damageCur/5)
			local x,y = dst:getPosition()
			Fight.bloodNodes:runAction(
				cc.Sequence:create(
					--cc.DelayTime:create(math.random(0,6)/10), --todo 第一次不延迟
					cc.CallFunc:create(function()Fight.showDamage(d,damageType,x+math.random(-30,30),y+math.random(-5,5))end),
					cc.DelayTime:create(0.1),
					cc.CallFunc:create(function()Fight.showDamage(d,damageType,x+math.random(-30,30),y+math.random(-5,5))end),
					cc.DelayTime:create(0.1),
					cc.CallFunc:create(function()Fight.showDamage(d,damageType,x+math.random(-30,30),y+math.random(-5,5))end),
					cc.DelayTime:create(0.1),
					cc.CallFunc:create(function()Fight.showDamage(d,damageType,x+math.random(-30,30),y+math.random(-5,5))end),
					cc.DelayTime:create(0.1),
					cc.CallFunc:create(function()Fight.showDamage(d,damageType,x+math.random(-30,30),y+math.random(-5,5))end)
				)
			)
		else
			Fight.showDamage(damageCur,damageType,dst:getPosition())
		end
	end
	--结算类技能
	if Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
		local src = Fight.fighters[Fight.src]
		if src:isVisible() and not src:isDead() then
			local passiveSETASkillID,passiveSETASkillLV = src:getPassiveSETASkill()  --主动方
			if passiveSETASkillID then
				local attPercent,defPercent,hpPercent = SkillManager[passiveSETASkillID].sattlementFunc(passiveSETASkillLV,Fight.FIX_BUG_OF_GET_RANDOM[pos+60])
				if attPercent >= 0 then --att
					src:addAttackEx(attPercent)
				else
					dst:addAttackEx(attPercent)
				end
				if defPercent >= 0 then --def
					src:addDefenceEx(defPercent)
				else
					dst:addDefenceEx(defPercent)
				end
				src:addHP(math.floor(damageCur * hpPercent)) --吸血
			end
		end
	end
	local passiveSETPSkillID,passiveSETPSkillLV = dst:getPassiveSETPSkill() --被动方
	if passiveSETPSkillID then
		local attPercent,defPercent = SkillManager[passiveSETPSkillID].sattlementFunc(passiveSETPSkillLV,Fight.FIX_BUG_OF_GET_RANDOM[pos+72])
		if attPercent >= 0 then --att
			dst:addAttackEx(attPercent)
		elseif Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
			Fight.fighters[Fight.src]:addAttackEx(attPercent)
		end
		if defPercent >= 0 then --def
			dst:addDefenceEx(defPercent)
		elseif Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
			Fight.fighters[Fight.src]:addDefenceEx(defPercent)
		end
	end
end

--受伤完成
function Fight.onInjureDone(pos)
	if SkillManager[Fight.sid].shakable then
		Fight.stopShake()
	end
	Fight.timeLineCount = Fight.timeLineCount - 1
	Fight.fighters[pos]:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - pos)
	Fight.setFighterAnimation(pos,ANIMATION_STAND,true)
	Fight.doSetupBufferOfSkill(pos)
end

--BufferCreate动画开始
function Fight.doBufferCreate(pos,bufferType,callback)
	Fight.timeLineCount = Fight.timeLineCount + 1
	local fer = Fight.fighters[pos]
	if not fer:isDead() then --活着才安装
		local armature = fer:getBufferArmature(bufferType)
		if armature == nil then
			armature = ccs.Armature:create("Buffer" .. bufferType)
			armature:setTag(bufferType)
			armature:getAnimation():setFrameEventCallFunc(Fight.onFighterFrameEventCallBack)
			armature:getAnimation():setMovementEventCallFunc(Fight.onFighterMovementEventCallBack)
			armature:getAnimation():setSpeedScale(Fight.speed)
			fer:setBufferArmature(bufferType,armature)
		end
		Fight.playEffect("Buffer" .. bufferType)
		armature.callback = callback
		armature:getAnimation():playWithIndex(BUFFERS_CREATE,-1,0)
		fer:setBufferArmatureVisible(bufferType,true)
		return
	end
	Fight.onBufferCreateDone(pos,nil)
end

--BufferCreate动画完成
function Fight.onBufferCreateDone(pos,armature)
	Fight.timeLineCount = Fight.timeLineCount - 1
	local fer = Fight.fighters[pos]
	if armature and not fer:isDead() then --活着才安装
		armature.callback(pos) --!!!该回调仅用于处理bufferData数据或其他及时性处理。(armature.callback可以不清理)
	end
end

--安装BufferOfSkill开始
function Fight.doSetupBufferOfSkill(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	local fer = Fight.fighters[pos]
	if not fer:isDead() and SkillManager[Fight.sid].setupBuffer then --活着才安装
		--assert 每个技能只带一个Buffer
		local fakeBuffer = SkillManager[Fight.sid].setupBuffer(Fight.slv,Fight.baseAtt + Fight.permAtt,Fight.damages[pos],0) --!!!必出fakeBuffer
		Fight.doBufferCreate(pos,fakeBuffer.type,function(pos)Fight.onSetupBufferOfSkillDone(pos)end)
		return
	end
	Fight.onSetupBufferOfSkillDone(pos)
end

--安装BufferOfSkill完成
function Fight.onSetupBufferOfSkillDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	local fer = Fight.fighters[pos]
	if not fer:isDead() and SkillManager[Fight.sid].setupBuffer then --活着才安装
		local buffer = SkillManager[Fight.sid].setupBuffer(Fight.slv,Fight.baseAtt + Fight.permAtt,Fight.damages[pos],Fight.FIX_BUG_OF_GET_RANDOM[pos+84])
		if buffer then
			local passiveIMBFSkillID,passiveIMBFSkillLV = fer:getPassiveIMBFSkill()
			if not passiveIMBFSkillID or not SkillManager[passiveIMBFSkillID].immunityBufferFunc(passiveIMBFSkillLV,buffer.type,Fight.FIX_BUG_OF_GET_RANDOM[pos+96]) then
				fer:setBufferData(buffer.type,buffer)
			end
		end
		local fakeBuffer = SkillManager[Fight.sid].setupBuffer(Fight.slv,Fight.baseAtt + Fight.permAtt,Fight.damages[pos],0) --!!!必出fakeBuffer
		local bufferType = fakeBuffer.type
		if fer:hasBufferData(bufferType) then
			fer:getBufferArmature(bufferType):getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
			fer:setBufferArmatureVisible(bufferType,true)
		else
			fer:setBufferArmatureVisible(bufferType,false)
		end
	end
	Fight.doSetupBufferOfYokeThunder(pos)
end

--安装BufferOfYokeThunder开始
function Fight.doSetupBufferOfYokeThunder(pos)
	Fight.timeLineCount = Fight.timeLineCount + 1
	local fer = Fight.fighters[pos]
	if not fer:isDead() and Fight.fighters[Fight.src]:hasYokeThunder() and Fight.yokeDst == pos and SkillManager[Fight.sid].target > 0 then --活着才安装，!!!Fix且目标必须是对方
		Fight.doBufferCreate(pos,BUFFER_TYPE_STUN,function(pos)Fight.onSetupBufferOfYokeThunderDone(pos)end)
		return
	end
	Fight.onSetupBufferOfYokeThunderDone(pos)
end

--安装BufferOfYokeThunder完成
function Fight.onSetupBufferOfYokeThunderDone(pos)
	Fight.timeLineCount = Fight.timeLineCount - 1
	local fer = Fight.fighters[pos]
	if not fer:isDead() and Fight.fighters[Fight.src]:hasYokeThunder() and Fight.yokeDst == pos and SkillManager[Fight.sid].target > 0 then --活着才安装，!!!Fix且目标必须是对方
		--雷系羁绊产生眩晕Buffer
		if Fight.FIX_BUG_OF_GET_RANDOM[pos+120] < YOKE_Thunder.chance then
			local buffer = createBufferStun(YOKE_Thunder.bufStrength,YOKE_Thunder.bufTimes)
			local passiveIMBFSkillID,passiveIMBFSkillLV = fer:getPassiveIMBFSkill()
			if not passiveIMBFSkillID or not SkillManager[passiveIMBFSkillID].immunityBufferFunc(passiveIMBFSkillLV,buffer.type,Fight.FIX_BUG_OF_GET_RANDOM[pos+132]) then
				fer:setBufferData(buffer.type,buffer)
			end
		end
		if fer:hasBufferData(BUFFER_TYPE_STUN) then
			fer:getBufferArmature(BUFFER_TYPE_STUN):getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
			fer:setBufferArmatureVisible(BUFFER_TYPE_STUN,true)
		else
			fer:setBufferArmatureVisible(BUFFER_TYPE_STUN,false)
		end
	end
	Fight.doSetupBufferOfYokeLight()
end

--安装BufferOfYokeLight开始
function Fight.doSetupBufferOfYokeLight()
	if Fight.timeLineCount ~= 0 then
		return
	end
	local fer = Fight.fighters[Fight.src]
	if not fer:isDead() and fer:hasYokeLight() then --活着才安装
		Fight.doBufferCreate(Fight.src,BUFFER_TYPE_REDUCTION,function(unused)Fight.onSetupBufferOfYokeLightDone()end)
		return
	end
	Fight.onSetupBufferOfYokeLightDone()
end

--安装BufferOfYokeLight完成
function Fight.onSetupBufferOfYokeLightDone()
	local fer = Fight.fighters[Fight.src]
	if not fer:isDead() and fer:hasYokeLight() then --活着才安装
		--光系羁绊产生护盾Buffer
		if Fight.FIX_BUG_OF_GET_RANDOM[Fight.src+180] < YOKE_Light.chance then
			local buffer = createBufferReduction(YOKE_Light.bufStrength,YOKE_Light.bufTimes,YOKE_Light.bufPercent,YOKE_Light.bufNumber)
			fer:setBufferData(buffer.type,buffer)
		end
		if fer:hasBufferData(BUFFER_TYPE_REDUCTION) then
			fer:getBufferArmature(BUFFER_TYPE_REDUCTION):getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
			fer:setBufferArmatureVisible(BUFFER_TYPE_REDUCTION,true)
		else
			fer:setBufferArmatureVisible(BUFFER_TYPE_REDUCTION,false)
		end
	end
	Fight.doRunBack()
end

--RunBack开始
function Fight.doRunBack()
	if Fight.runType == 0 then
		Fight.onRunBackDone()
	elseif Fight.runType == 1 or Fight.runType == 2 then
		Fight.fighters[Fight.src]:runAction(
			cc.Sequence:create(
				cc.MoveTo:create(TIME_RUN/Fight.speed,{x = Fight.backupX,y = Fight.backupY}),
				cc.CallFunc:create(function()Fight.onRunBackDone()end)
			)
		)
		Fight.setFighterAnimation(Fight.src,ANIMATION_RUN,true)
	elseif Fight.runType == 3 or Fight.runType == 4 then
		Fight.fighters[Fight.src]:runAction(
			cc.Sequence:create(
				cc.Spawn:create(
					cc.MoveTo:create(TIME_RUN/Fight.speed,{x = Fight.backupX,y = Fight.backupY}),
					cc.ScaleTo:create(TIME_RUN/Fight.speed,Fight.backupS)
				),
				cc.CallFunc:create(function()Fight.onRunBackDone()end)
			)
		)
		Fight.setFighterAnimation(Fight.src,ANIMATION_RUN,true)
		Fight.curtainNode:runAction(cc.FadeTo:create(TIME_RUN/Fight.speed,0))
	end
end

--RunBack完成
function Fight.onRunBackDone()
	if Fight.runType ~= 0 then
		Fight.fighters[Fight.src]:setOpacity(255)
		Fight.setFighterAnimation(Fight.src,ANIMATION_STAND,true)
		Fight.fighters[Fight.src]:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - Fight.src)
		if Fight.runType == 3 or Fight.runType == 4 then
			Fight.curtainNode:setVisible(false)
			local s = Fight.src < 7 and 1 or 7
			local e = Fight.src < 7 and 6 or 12
			for i=s,e do
				local fer = Fight.fighters[i]
				fer:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - i)
				if fer.wing then
					fer.wing:setLocalZOrder(ZORDER_OF_WING_SHOWN + 12 - Fight.fixWingZOrder(i))
				end
			end
			Fight.fighters[Fight.src]:stopAllActions()        --!!! Fix Bug
			Fight.fighters[Fight.src]:setScale(Fight.backupS) --!!! Fix Bug
		end
	end
	if Fight.act == ACT_EXIT then
		Fight.doRevive()
	else
		Fight.onActionDone()
	end
end

--上场开始
function Fight.doEnter()
	Fight.fighters[Fight.src]:setLocalZOrder(ZORDER_OF_FIGHTER_ACTIVE)
	Fight.fighters[Fight.src]:setVisible(true)
	Fight.setFighterAnimation(Fight.src,ANIMATION_ENTER,false)
end

--上场完成
function Fight.onEnterDone()
	Fight.fighters[Fight.src]:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - Fight.src)
	Fight.setFighterAnimation(Fight.src,ANIMATION_STAND,true)
	Fight.resetLimited()
	Fight.doPyrosPostEnter()
end

--上场后异火开始
function Fight.doPyrosPostEnter()
	local pyroTable = Fight.getPyrosPreFight(Fight.src)
	if #pyroTable > 0 then
		Fight.doPyro(Fight.src,function(pos)Fight.onPyrosPostEnterDone()end,pyroTable)
	else
		Fight.onPyrosPostEnterDone()
	end
end

--上场后异火完成
function Fight.onPyrosPostEnterDone()
	if Fight.sid then
		Fight.doSelectTarget()
	else
		Fight.onActionDone()
	end
end

--复活开始
local isRevive --Only For Revive
function Fight.doRevive()
	--是否统计死亡次数
	local fer = Fight.fighters[Fight.src]
	local reviveCount = fer:getReviveCount()
	local passiveREVIVESkillID,passiveREVIVESkillLV = fer:getPassiveREVIVESkill()
	if passiveREVIVESkillID and SkillManager[passiveREVIVESkillID].reviveFunc(passiveREVIVESkillLV,reviveCount+1,Fight.random(26)) then
		isRevive = true
		fer:setReviveCount(reviveCount + 1)
		local hpLmt,hpCur,phscA,manaA,phscD,manaD = SkillManager[passiveREVIVESkillID].hpAttackDefence(
			passiveREVIVESkillLV,reviveCount + 1,
			fer:getHPMax(),fer:getHPLmt(),
			fer:getOriginalAttack(false),fer:getOriginalAttack(true),
			fer:getOriginalDefence(false),fer:getOriginalDefence(true)
		)
		fer:setHPLmt(math.floor(hpLmt))
		fer:setHP(math.floor(hpCur))
		fer:setAttacks(phscA,manaA)
		fer:setDefences(phscD,manaD)
		fer:clearBuffers()
		fer:setLocalZOrder(ZORDER_OF_FIGHTER_ACTIVE)
		Fight.setFighterAnimation(Fight.src,ANIMATION_REVIVE,false)
	else
		isRevive = false
		Fight.onReviveDone()
	end
end

--复活完成
function Fight.onReviveDone()
	if isRevive then
		Fight.fighters[Fight.src]:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - Fight.src)
		Fight.setFighterAnimation(Fight.src,ANIMATION_STAND,true)
		Fight.actionRemoveFront() --移除队列中下一条上场动作
		Fight.onActionDone()
	else
		Fight.doExit()
	end
end

--下场开始
function Fight.doExit()
	Fight.fighters[Fight.src]:setLocalZOrder(ZORDER_OF_FIGHTER_ACTIVE)
	Fight.setFighterAnimation(Fight.src,ANIMATION_EXIT,false)
end

--下场完成
function Fight.onExitDone()
	Fight.fighters[Fight.src]:setLocalZOrder(ZORDER_OF_FIGHTER_INACTIVE + 12 - Fight.src)
	Fight.setFighterAnimation(Fight.src,ANIMATION_STAND,true)
	Fight.fighters[Fight.src]:setVisible(false)
	if Fight.src < 7 then
		Fight.myDeaths = Fight.myDeaths + 1
	else
		Fight.otherDeaths = Fight.otherDeaths + 1
	end
	Fight.resetLimited()
	Fight.onActionDone()
end

--站立开始
function Fight.doStand()
	local src = Fight.fighters[Fight.src]
	local which = src:hasBufferData(BUFFER_TYPE_FREEZE) and BUFFER_TYPE_FREEZE
		or src:hasBufferData(BUFFER_TYPE_STUN) and BUFFER_TYPE_STUN
		or BUFFER_TYPE_SEAL
	local bufferArmature = src:getBufferArmature(which)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
end

--站立完成
function Fight.onStandDone()
	local src = Fight.fighters[Fight.src]
	local which = src:hasBufferData(BUFFER_TYPE_FREEZE) and BUFFER_TYPE_FREEZE
		or src:hasBufferData(BUFFER_TYPE_STUN) and BUFFER_TYPE_STUN
		or BUFFER_TYPE_SEAL
	local bufferArmature = src:getBufferArmature(which)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
	src:decBufferData(which)
	Fight.onActionDone()
end

--Burn开始
function Fight.doBurn()
	local src = Fight.fighters[Fight.src]
	local bufferArmature = src:getBufferArmature(BUFFER_TYPE_BURN)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
	local bufferReduce = src:getBufBurnReduction()
	bufferReduce = math.min(bufferReduce,BUFFER_REDUCE_MAX)
	bufferReduce = math.max(bufferReduce,BUFFER_REDUCE_MIN)
	local damage = math.floor(src:getBufferDamage(BUFFER_TYPE_BURN) * (1-bufferReduce))
	src:subHP(damage)
	Fight.showDamage(damage,DAMAGE_TYPE_GENERIC,src:getPosition())
end

--Burn完成
function Fight.onBurnDone()
	local src = Fight.fighters[Fight.src]
	local bufferArmature = src:getBufferArmature(BUFFER_TYPE_BURN)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
	src:decBufferData(BUFFER_TYPE_BURN)
	Fight.onActionDone()
end

--Poison开始
function Fight.doPoison()
	local src = Fight.fighters[Fight.src]
	local bufferArmature = src:getBufferArmature(BUFFER_TYPE_POISON)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
	local bufferReduce = src:getBufPoisonReduction()
	bufferReduce = math.min(bufferReduce,BUFFER_REDUCE_MAX)
	bufferReduce = math.max(bufferReduce,BUFFER_REDUCE_MIN)
	local damage = math.floor(src:getBufferDamage(BUFFER_TYPE_POISON) * (1-bufferReduce))
	src:subHP(damage)
	Fight.showDamage(damage,DAMAGE_TYPE_GENERIC,src:getPosition())
end

--Poison完成
function Fight.onPoisonDone()
	local src = Fight.fighters[Fight.src]
	local bufferArmature = src:getBufferArmature(BUFFER_TYPE_POISON)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
	src:decBufferData(BUFFER_TYPE_POISON)
	Fight.onActionDone()
end

--Curse开始
function Fight.doCurse()
	local src = Fight.fighters[Fight.src]
	local bufferArmature = src:getBufferArmature(BUFFER_TYPE_CURSE)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_EFFECT,-1,0)
	local bufferReduce = src:getBufCurseReduction()
	bufferReduce = math.min(bufferReduce,BUFFER_REDUCE_MAX)
	bufferReduce = math.max(bufferReduce,BUFFER_REDUCE_MIN)
	local damage = math.floor(src:getBufferDamage(BUFFER_TYPE_CURSE) * (1-bufferReduce))
	src:subHP(damage)
	Fight.showDamage(damage,DAMAGE_TYPE_GENERIC,src:getPosition())
end

--Curse完成
function Fight.onCurseDone()
	local src = Fight.fighters[Fight.src]
	local bufferArmature = src:getBufferArmature(BUFFER_TYPE_CURSE)
	bufferArmature:getAnimation():playWithIndex(BUFFERS_STATUS,-1,1)
	src:decBufferData(BUFFER_TYPE_CURSE)
	Fight.onActionDone()
end

--检测己方是否还活着
function Fight.isSelfAlive()
	for i = 1,6 do
		local fer = Fight.fighters[i]
		if fer:isVisible() and not fer:isDead() then
			return true
		end
	end
	return false
end

--检测敌方是否还活着
function Fight.isOtherAlive()
	for i = 7,12 do
		local fer = Fight.fighters[i]
		if fer:isVisible() and not fer:isDead() then
			return true
		end
	end
	return false
end

--检测战斗是否结束
function Fight.isFightOver()
	return not (Fight.isSelfAlive() and Fight.isOtherAlive())
end

--检测本场战斗是否胜利
function Fight.isFightWin()
	if Fight.bigRound < MAX_ROUND_LIMIT then
		return Fight.isSelfAlive()
	elseif Fight.bigRound == MAX_ROUND_LIMIT then
		return not Fight.isOtherAlive()
	elseif Fight.bigRound > MAX_ROUND_LIMIT then
		return false
	end
end

--检测战斗是否胜利
function Fight.isWin()
	--todo 临时修复外部调用时，未使用战斗真实结果的问题（使用的是当时的战场情况）。
	if Fight.initData.result then
		return Fight.initData.result.isWin
	end
	if Fight.bigRound < MAX_ROUND_LIMIT then
		return Fight.isSelfAlive()
	elseif Fight.bigRound == MAX_ROUND_LIMIT then
		if Fight.fightIndex ~= #Fight.initData.otherData then
			return false
		end
		return not Fight.isOtherAlive()
	elseif Fight.bigRound > MAX_ROUND_LIMIT then
		return false
	end
end

return Fight
