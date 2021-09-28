-- Filename：	ChooseChallengerLayer.lua
-- Author：		LLP
-- Date：		2014-12-12
-- Purpose：		选择对手界面

require "db/DB_Overcome"
require "script/model/utils/HeroUtil"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"
require "script/ui/godweapon/godweaponcopy/MakeUpLayer"
require "script/ui/godweapon/godweaponcopy/GodCopyUtil"
require "script/ui/godweapon/godweaponcopy/HeroSpriteCopy"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyService"

module("ChooseChallengerLayer", package.seeall)

local _bgLayer 			= nil
local _OpponentInfo 	= nil			--对手信息
local _copyInfo 		= nil			--副本信息
local _zorder 			= 100

local _hardlv 			= 0 			--难度
local _buyNum 			= 0

local _isAttackBefore 	= false 		--之前是不是已经打过，上一局平局的情况


function init()
	_bgLayer 			= nil
	_OpponentInfo 		= nil
	_hardlv 			= 0 			--难度
	_isAttackBefore 	= false 		--之前是不是已经打过，上一局平局的情况
	_buyNum 			= 0
	_zorder 			= 100
end

--发送获取对手命令
local function setCommond( ... )
	--获取当前在第几关
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
	--调用获取对手命令
	GodWeaponCopyService.getOpponentList(getOpponentInfoFun,args)
end

function getOpponentInfoFun( ... )
	--取对手信息
	_OpponentInfo = GodWeaponCopyData.getOpponentInfo()
	--如果平局 判断是否打过此人
	_isAttackBefore = false
	for _, oppInfo in pairs(_OpponentInfo) do
		if( oppInfo.attackBefore and tonumber(oppInfo.attackBefore) >= 1)then
			_isAttackBefore = true
			break
		end
	end
	--根据数据创建界面
	createLayerAfterCommond()
	-- 隐藏中间
	GodWeaponCopyMainLayer.setMiddleItemVisible(false)
end

--网络回调回来以后创建界面
function createLayerAfterCommond( ... )
	createBackGround()
end

--界面起始结束
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then

    else

	end
end

--layer点击事件
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--返回事件
function backAction(tag,itembtn)
	-- 隐藏中间
	GodWeaponCopyMainLayer.setMiddleItemVisible(true)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

end

--副将界面
function showAddHeroLayer( p_tag,p_itemBtn )
	-- body
	GodWeaponCopyData.setChooseWhich(p_tag)
	AddHeroLayer.showLayer(true)
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--挑战按钮回调
function challengeAction( p_tag,p_itemBtn )
	-- if( _isAttackBefore == true and tonumber(_OpponentInfo[tostring(p_tag)].attackBefore) == 0 )then
	-- 	return
	-- end

	-- body
	-- 背包满了
	if(ItemUtil.isBagFull() == true )then
		return
	end
	_hardlv = tonumber(p_tag)
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
	args:addObject(CCInteger:create(tonumber(p_tag)))
	GodWeaponCopyService.attack(attackCommondCallBack,args)
end

-- 战斗结算面板的确定回调
function afterBattleCallback( isWin )

	if( isWin == true and GodWeaponCopyData.isHavePass() )then
		GodCopyUtil.showPassAllEffect()
	end
	if(isWin == true and GodWeaponCopyData.justRemainOnce() == true )then
		-- 如果战斗胜利 且 已经完成所有
		GodWeaponCopyMainLayer.nextSenceEffect()
	else
		GodWeaponCopyMainLayer.refreshFunc()
	end
end


--战斗命令回调
function attackCommondCallBack( attackInfo )

	backAction()
	-- body

	require "script/battle/BattleLayer"
	require "script/ui/godweapon/godweaponcopy/CopyAfterBattleLayer"

	local base64Data = Base64.decodeWithZip(attackInfo.fightStr)
    local data = amf3.decode(base64Data)

    GodWeaponCopyData.setEnterInfo(attackInfo.va_pass,attackInfo.cur_base,attackInfo.pass_num,attackInfo.point,attackInfo.star_star,attackInfo.lose_num,attackInfo.buy_num)
    print("ChooseChallengerLayer,pass_num",pass_num)
    local layer = CopyAfterBattleLayer.createAfterBattleLayer(attackInfo,data,_hardlv, afterBattleCallback)
	BattleLayer.showBattleWithString(attackInfo.fightStr, nil,layer, "ducheng.jpg",nil,nil,nil,nil,true)
end

--身像点击
function clickAction( tag,item )
	-- body
	HeroSpriteCopy.showLayer(-559,101,tonumber(tag),_OpponentInfo[tostring(tag)]["arrHero"],_OpponentInfo[tostring(tag)].name)
end

itemImageTable = {
	"images/godweaponcopy/chooseeasy.png",
	"images/godweaponcopy/choosenormal.png",
	"images/godweaponcopy/choosehard.png"
}

hardTypeTable = {
	"images/godweaponcopy/jiandan.png",
	"images/godweaponcopy/putong.png",
	"images/godweaponcopy/kunnan.png"
}

--封装按钮
function makeItem(pHardLv)
	--item底和难度
	local itemBg = nil
	local hardlvSprite = nil
	local hardlvBgSprite = nil
	local isGray = false

	local CCSprite = CCSprite
	-- if( _isAttackBefore and tonumber(_OpponentInfo[tostring(pHardLv)].attackBefore) == 0 )then
	-- 	CCSprite 	= BTGraySprite
	-- 	isGray 		= true
	-- end
	local bodyMenu = CCMenu:create()
	bodyMenu:setAnchorPoint(ccp(0,0))
	bodyMenu:setPosition(ccp(0,0))

	itemBg = CCMenuItemSprite:create(CCSprite:create(itemImageTable[pHardLv]),CCSprite:create(itemImageTable[pHardLv]))
	hardlvSprite = CCSprite:create(hardTypeTable[pHardLv])

	bodyMenu:addChild(itemBg)
	itemBg:setTag(pHardLv)

	if(isGray == true)then
		itemBg:setColor(ccc3(0xff,0xff,0xff))
	end
	hardlvBgSprite = CCSprite:create("images/godweaponcopy/1122.png")
	itemBg:setAnchorPoint(ccp(0.5,0.5))
	local sizeItem = CCMenuItemImage:create("images/arena/challenge_normal.png","images/arena/challenge_select.png")
	if(pHardLv==1)then
		itemBg:setPosition(ccp(_bgLayer:getContentSize().width*0.75,_bgLayer:getContentSize().height*0.3))
	elseif(pHardLv==2)then
		itemBg:setPosition(ccp(_bgLayer:getContentSize().width*0.25,_bgLayer:getContentSize().height*0.3))
	elseif(pHardLv==3)then
		itemBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.72))
	end

	--难度
	itemBg:addChild(hardlvBgSprite)
	hardlvBgSprite:setAnchorPoint(ccp(1,1))
	hardlvBgSprite:setPosition(ccp(-2,itemBg:getContentSize().height*0.925))

	hardlvBgSprite:addChild(hardlvSprite)
	hardlvSprite:setAnchorPoint(ccp(0.5,0.5))
	hardlvSprite:setPosition(ccp(hardlvBgSprite:getContentSize().width*0.5,hardlvBgSprite:getContentSize().height*0.5))

	local bodySprite = nil
	for k,v in pairs(_OpponentInfo[tostring(pHardLv)]["arrHero"]) do
		if(HeroModel.isNecessaryHero(tonumber(v.htid)))then
			if(v.dress~=nil and not table.isEmpty(v.dress))then
				bodySprite = HeroUtil.getHeroBodySpriteByHTID(tonumber(v.htid), tonumber(v.dress["1"]))
			else
				bodySprite = HeroUtil.getHeroBodySpriteByHTID(tonumber(v.htid))
			end
		else

		end
		print(k,v)
	end

	--身相
	-- local bodySprite = HeroUtil.getHeroBodySpriteByHTID(UserModel.getAvatarHtid(), 80001)
	-- if(isGray==true)then
	-- 	bodySprite = BTGraySprite:createWithNodeAndItChild(bodySprite)
	-- end
	bodySprite:setScale(0.4)
	itemBg:addChild(bodySprite)
	bodySprite:setAnchorPoint(ccp(0.5,0.5))
	bodySprite:setPosition(ccp(itemBg:getContentSize().width*0.5,itemBg:getContentSize().height*0.6))

	local t_color = ccc3(0xff,0xf6,0x00)
	-- if(isGray == true)then
	-- 	t_color = ccc3(0xff,0xff,0xff)
	-- end

	local richInfo = {}
    richInfo.width = itemBg:getContentSize().width
    richInfo.alignment = 2
    richInfo.labelDefaultFont = g_sFontName
    richInfo.labelDefaultSize = 23
    richInfo.defaultType = "CCRenderLabel"
    richInfo.elements =
    {
        {
            type = "CCSprite",
            image = "images/common/lv.png",
        },
        {
            text = _OpponentInfo[tostring(pHardLv)].level,
            color = t_color
        },
        {
            text = "  ".._OpponentInfo[tostring(pHardLv)].name,
        }
    }
    require "script/libs/LuaCCLabel"
    local richLabel = LuaCCLabel.createRichLabel(richInfo)
    itemBg:addChild(richLabel)
    richLabel:setAnchorPoint(ccp(0.5,1))
    richLabel:setPosition(ccp(itemBg:getContentSize().width*0.5,bodySprite:getContentSize().height*0.5*0.4+bodySprite:getPositionY()))

	--战力Sprite
	local powerSprite = CCSprite:create("images/godweaponcopy/battle.png")
	powerSprite:setAnchorPoint(ccp(0.5,0.5))
	itemBg:addChild(powerSprite)
	--战力值label
	local p_color = ccc3(0x00,0xff,0x18)
	-- if(isGray == true)then
	-- 	p_color = ccc3(0xff,0xff,0xff)
	-- end
	local powerLabel = CCRenderLabel:create(_OpponentInfo[tostring(pHardLv)].fightForce,g_sFontName,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	powerLabel:setColor(p_color)
	powerSprite:addChild(powerLabel)
	powerLabel:setAnchorPoint(ccp(0,0))
	powerLabel:setPosition(ccp(powerSprite:getContentSize().width+10,0))
	powerSprite:setContentSize(CCSizeMake(powerSprite:getContentSize().width+powerLabel:getContentSize().width+10,powerSprite:getContentSize().height))
	powerSprite:setPosition(ccp(itemBg:getContentSize().width*0.5,bodySprite:getPositionY()-bodySprite:getContentSize().height*0.5*0.4+10))

	local starNumData = DB_Overcome.getDataById(_copyInfo.cur_base).baseReward
	local rewardData = string.split(starNumData, ",")
	local type_reward_arr = string.split(rewardData[pHardLv], "|")
	local sizeLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_123",type_reward_arr[2]),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	--得星label
	local getStarLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_121"),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	getStarLabel:setAnchorPoint(ccp(0.5,1))
	getStarLabel:setColor(ccc3(0xff,0xff,0xff))

	--星星Sprite
	local starSprite = CCSprite:create("images/common/star.png")
	getStarLabel:addChild(starSprite)
	starSprite:setAnchorPoint(ccp(0,0.5))
	starSprite:setPosition(ccp(getStarLabel:getContentSize().width+5,getStarLabel:getContentSize().height*0.5))

	--星星数量Lable
	local starNumData = DB_Overcome.getDataById(_copyInfo.cur_base).baseReward
	local rewardData = string.split(starNumData, ",")

	local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))

    local str = dbData.baseReward
    local tab = string.split(str,",")
    local item = {}
    item = string.split(tab[pHardLv],"|")


	local starNumLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_123",item[3]),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	starNumLabel:setColor(ccc3(0xff,0xff,0xff))
	starSprite:addChild(starNumLabel)
	starNumLabel:setAnchorPoint(ccp(0,0.5))
	starNumLabel:setPosition(ccp(starSprite:getContentSize().width+5,starSprite:getContentSize().height*0.5))
	getStarLabel:setContentSize(CCSizeMake(getStarLabel:getContentSize().width+starSprite:getContentSize().width+sizeLabel:getContentSize().width+10,
								starSprite:getContentSize().height))
	getStarLabel:setPosition(ccp(itemBg:getContentSize().width*0.5,bodySprite:getPositionY()-bodySprite:getContentSize().height*0.3*0.4-powerLabel:getContentSize().height-5))

	--得分label
	local getScoreLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_122"),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	getScoreLabel:setAnchorPoint(ccp(0,0))
	getScoreLabel:setColor(ccc3(0xff,0xff,0xff))

	--分数Sprite
	local scoreSprite = CCSprite:create("images/godweaponcopy/score.png")
	getScoreLabel:addChild(scoreSprite)
	scoreSprite:setAnchorPoint(ccp(0,0.5))
	scoreSprite:setPosition(ccp(getScoreLabel:getContentSize().width+5,getScoreLabel:getContentSize().height*0.5))

	--分数数量Lable
	local scoreNumLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_123",type_reward_arr[2]),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	scoreNumLabel:setColor(ccc3(0xff,0xff,0xff))
	scoreSprite:addChild(scoreNumLabel)
	scoreNumLabel:setAnchorPoint(ccp(0,0.5))
	scoreNumLabel:setPosition(ccp(scoreSprite:getContentSize().width+5,scoreSprite:getContentSize().height*0.5))
	getScoreLabel:setContentSize(CCSizeMake(getScoreLabel:getContentSize().width+scoreSprite:getContentSize().width+scoreNumLabel:getContentSize().width+10,
								scoreSprite:getContentSize().height))
	getScoreLabel:setPosition(ccp(itemBg:getContentSize().width*0.5,bodySprite:getPositionY()-bodySprite:getContentSize().height*0.3*0.4-powerLabel:getContentSize().height-5-getStarLabel:getContentSize().height))

	local fullRect = CCRectMake(0,0,96,46)
	local insetRect = CCRectMake(38,18,18,12)
	local grayBg = CCScale9Sprite:create("images/godweaponcopy/whitebg.png",fullRect, insetRect)
	grayBg:setContentSize(CCSizeMake(getScoreLabel:getContentSize().width+30,getScoreLabel:getContentSize().height*2-3))
	grayBg:addChild(getStarLabel)
	getStarLabel:setAnchorPoint(ccp(0,1))
	getStarLabel:setPosition(ccp(10,grayBg:getContentSize().height))
	grayBg:addChild(getScoreLabel)
	getScoreLabel:setPosition(ccp(10,0))
	itemBg:addChild(grayBg)
	grayBg:setAnchorPoint(ccp(0.5,1))
	grayBg:setPosition(ccp(itemBg:getContentSize().width*0.5,powerSprite:getPositionY()-powerSprite:getContentSize().height*0.5))
	--挑战按钮
	local challengeMenu = CCMenu:create()
	itemBg:addChild(challengeMenu)
	challengeMenu:setAnchorPoint(ccp(0,0))
	challengeMenu:setPosition(ccp(0,0))
	challengeMenu:setTouchPriority(-551)


	local challengeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png","images/common/btn/btn_red_h.png",CCSizeMake(150, 73), GetLocalizeStringBy("llp_134"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))
	challengeMenu:addChild(challengeItem,1,pHardLv)
	challengeItem:setAnchorPoint(ccp(0.5,1))
	challengeItem:setPosition(ccp(itemBg:getContentSize().width*0.5,15))
	challengeItem:registerScriptTapHandler(showAddHeroLayer)


	-- if(isGray == true)then
	-- 	local lock_sprite = CCSprite:create("images/godweaponcopy/lock_gray.png")
	-- 	lock_sprite:setAnchorPoint(ccp(0.5, 0.5))
	-- 	lock_sprite:setPosition(ccp(itemBg:getContentSize().width*0.5, itemBg:getContentSize().height*0.6))
	-- 	itemBg:addChild(lock_sprite)
	-- end

	itemBg:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(bodyMenu)
	bodyMenu:setTag(pHardLv)

	itemBg:registerScriptTapHandler(clickAction)
	bodyMenu:setTouchPriority(-551)
end

function createBackGround()
	--三种难度 三个人
    for i=1,3 do
    	makeItem(i)
    end
end

function createLayer( ... )
	-- body

	-- 底层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 选择对手Sprite
	local chooseChallengerSprite = CCSprite:create("images/godweaponcopy/xuanzeduishou.png")
	chooseChallengerSprite:setAnchorPoint(ccp(0.5,0.5))

	-- 选择对手bg
	local fullRect = CCRectMake(0,0,209,49)
	local insetRect = CCRectMake(86,14,45,20)
	local grayBg = CCScale9Sprite:create("images/godweaponcopy/choosegray.png",fullRect, insetRect)
	grayBg:setPreferredSize(CCSizeMake(chooseChallengerSprite:getContentSize().width+100,chooseChallengerSprite:getContentSize().height+50))
	grayBg:setAnchorPoint(ccp(0.5,1))
	grayBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-20))
	grayBg:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(grayBg)
	grayBg:addChild(chooseChallengerSprite)
	chooseChallengerSprite:setPosition(ccp(grayBg:getContentSize().width*0.5,grayBg:getContentSize().height*0.5))
	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    _bgLayer:addChild(menu,99)
    local ccBtnSure = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    ccBtnSure:setAnchorPoint(ccp(1,1))
    ccBtnSure:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height))
    ccBtnSure:registerScriptTapHandler(backAction)
    ccBtnSure:setScale(g_fElementScaleRatio)
    menu:addChild(ccBtnSure)

    --发送获取对手命令
	setCommond()

	return _bgLayer
end

function showLayer()
	init()

	local pLayer = createLayer()

	--把layer加到runningScene上
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(pLayer,_zorder)
end
