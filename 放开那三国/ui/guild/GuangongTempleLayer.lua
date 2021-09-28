-- Filename: GuangongTempleLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-21
-- Purpose: 该文件用于: 关公殿

module ("GuangongTempleLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/ui/guild/GuildDataCache"
require "script/network/Network"
require "db/DB_Legion_feast"
require "db/DB_Level_up_exp"
require "script/utils/TimeUtil"
require "script/utils/BaseUI"

function init()
	_bg = nil
	_layerSize = nil
	totalGongxian = nil
	powerLabel = nil
	baiBtn = nil
	returnBtn = nil
	rewardMenuItem = nil

	baiOver = nil
	remainNumber = nil

	label3 = nil

	baiWay = nil
end

function onNodeEvent(event)
	if (event == "enter") then
		GuildDataCache.setIsInGuildFunc(true)
	elseif (event == "exit") then
		--RechargeLayer.registerChargeGoldCb(nil)
		GuildDataCache.setIsInGuildFunc(false)
	end
end

function createTopUI()
	local topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    topBg:setAnchorPoint(ccp(0,1))
    topBg:setPosition(0,_layerSize.height-32*MainScene.elementScale)
    topBg:setScale(g_fScaleX)
    _bgLayer:addChild(topBg)

    --添加战斗力文字图片
    local powerDescLabel = CCSprite:create("images/guild/guangong/alltribute.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.15,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)

    --读取用户信息
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    
    --总贡献
    totalGongxian = GuildDataCache.getSigleDoante()
    powerLabel = CCRenderLabel:create(totalGongxian, g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    powerLabel:setColor(ccc3(0xff, 0xff, 0xff))
    --m_powerLabel:setAnchorPoint(ccp(0,0.5))
    powerLabel:setPosition(topBg:getContentSize().width*0.27,topBg:getContentSize().height*0.66)
    topBg:addChild(powerLabel)
    
    --银币
	silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    silverLabel:setAnchorPoint(ccp(0,0.5))
    silverLabel:setPosition(topBg:getContentSize().width*0.61,topBg:getContentSize().height*0.43)
    topBg:addChild(silverLabel)
    
    --金币
    goldLabel = CCLabelTTF:create(tostring(userInfo.gold_num),g_sFontName,18)
    goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    goldLabel:setAnchorPoint(ccp(0,0.5))
    goldLabel:setPosition(topBg:getContentSize().width*0.82,topBg:getContentSize().height*0.43)
    topBg:addChild(goldLabel)
end

function returnBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/guild/GuildMainLayer"
	local guildMainLayer = GuildMainLayer.createLayer(false)
	MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end

--[[function fnHandlerOfNetwork1(cbFlag, dictData, bRet)
	if not bRet then
        return
    end
    if cbFlag == "guild.getMemberInfo" then
    	if tonumber(dictData.ret.reward_num) <= 0 then
    		AnimationTip.showTip(GetLocalizeStringBy("key_1350"))
    	else
    		AnimationTip.showTip(GetLocalizeStringBy("key_1533"))
    	end
    end
end]]

function createAfterAmazing(gglv)
	powerLabel:setString(GuildDataCache.getSigleDoante())
	--AnimationTip.showTip(GetLocalizeStringBy("key_1533"))
	if tonumber(GuildDataCache.getBaiGuangongTimes()) <= 0 then
		greenCh:setVisible(true)
		if GuildDataCache.getCoinBaiTimes() < tonumber(afterString[1]) then
			normalBai:setVisible(false)
			goldBai:setVisible(true)
			needGold = tonumber(afterString[2])+(GuildDataCache.getCoinBaiTimes())*tonumber(afterString[3])
    		goldNum:setString(tostring(needGold))
		else
			baiBtn:setVisible(false)
			baiOver:setVisible(true)
		end
	end
	local totalNum = GuildDataCache.getMemberLimit()
	local haveNum = GuildDataCache.getGuildRewardTimes()
	--[[if tonumber(totalNum-haveNum) == 0 then
		label3:setVisible(false)
	else]]
	--remainNumber:setString(totalNum-haveNum)
	--end
	require "script/ui/guild/GuanGongRewardLayer"
	local newLayer = GuanGongRewardLayer.createLayer(gglv)
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(newLayer,999,1500)
end

function createAmazing(gglv)
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/guangong/guanggong" ), -1,CCString:create(""))
	spellEffectSprite:setScale(g_fBgScaleRatio)
	spellEffectSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height/2-10*g_fScaleY))
    spellEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
    _bgLayer:addChild(spellEffectSprite,9999)

    local animationEnd = function(actionName,xmlSprite)
   		spellEffectSprite:retain()
		spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)
        baiBtn:setEnabled(true)
        returnBtn:setEnabled(true)
        rewardMenuItem:setEnabled(true)
        createAfterAmazing(gglv)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    spellEffectSprite:setDelegate(delegate)
end

function fnHandlerOfNetwork(cbFlag, dictData, bRet)
	if not bRet then
        return
    end
    if (cbFlag == "guild.reward") then
    	if dictData.ret.ret == "ok" then
    		baiBtn:setEnabled(false)
    		returnBtn:setEnabled(false)
    		rewardMenuItem:setEnabled(false)


    		print(GetLocalizeStringBy("key_1905"),baiWay)
    		if tonumber(baiWay) == 0 then
    			print(GetLocalizeStringBy("key_2043"))
	    		GuildDataCache.addBaiGuangongTimes(-1)
	    		GuildDataCache.addSigleDonate(-DB_Legion_feast.getDataById(1).contributeCost)
	    	elseif tonumber(baiWay) == 1 then
	    		print(GetLocalizeStringBy("key_2039"))
	    		UserModel.addGoldNumber(-tonumber(needGold))
	    		GuildDataCache.addCoinBaiTimes(1)
	    		refreshGold()
	    		greenCh:setString(GetLocalizeStringBy("key_1109") .. tostring(afterString[1] - GuildDataCache.getCoinBaiTimes()))
	    	end
    		require "script/model/user/UserModel"
    		local nowLevel = dictData.ret.level
    		local guanGongInfo = DB_Legion_feast.getDataById(1)
    		local growTili = math.floor(guanGongInfo.baseExecution+guanGongInfo.growExecution*nowLevel/100)
    		UserModel.addEnergyValue(growTili)

    		local growNaili = math.floor(guanGongInfo.baseStamina+guanGongInfo.growStamina*nowLevel/100)
    		UserModel.addStaminaNumber(growNaili)

    		local itemNumP = math.floor(guanGongInfo.basePrestige+guanGongInfo.growPrestige*nowLevel/100)
    	    UserModel.addPrestigeNum(tonumber(itemNumP))

    	    local itemNumS = math.floor(guanGongInfo.baseSoul+guanGongInfo.growSoul*nowLevel/100)
    	    UserModel.addSoulNum(tonumber(itemNumS))

    	    local itemNumSi = math.floor(guanGongInfo.baseSilver+guanGongInfo.growSilver*nowLevel/100)
    	    UserModel.addSilverNumber(tonumber(itemNumSi))

    	    local itemNumG = math.floor(guanGongInfo.baseGold+guanGongInfo.growGold*nowLevel/100)
    	    UserModel.addGoldNumber(tonumber(itemNumG))
			--GuildDataCache.addGuildRewardTimes(1)
	    	
	    	createAmazing(dictData.ret.level)
	    end
	    if dictData.ret.ret == "failed" then
	    	AnimationTip.showTip(GetLocalizeStringBy("key_2668"))
	    	_bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
	    	require "script/ui/guild/GuildImpl"
            GuildImpl.showLayer()
		end
		if dictData.ret.ret == "exceed" then
			remainNumber:setString("0")
			--label3:setVisible(false)
			AnimationTip.showTip(GetLocalizeStringBy("key_2258"))
		end
    end
end

function baiGuangong()
	local curTime = TimeUtil.getSvrTimeByOffset()
	local date = os.date("*t", curTime)
	local nowHour = date.hour
	local nowMin = date.min
	local nowSec = date.sec

	local nowTime = tonumber(nowHour)*10000 + tonumber(nowMin)*100 + tonumber(nowSec)
	
	if tonumber(GuildDataCache.getBaiGuangongTimes()) > 0 then
		if tonumber(GuildDataCache.getBaiGuangongTimes()) <= 0 then
	    	AnimationTip.showTip(GetLocalizeStringBy("key_1350"))
	    elseif tonumber(DB_Legion_feast.getDataById(1).contributeCost) > tonumber(totalGongxian) then
	    	AnimationTip.showTip(GetLocalizeStringBy("key_2405"))
	    elseif ((tonumber(nowTime) < tonumber(DB_Legion_feast.getDataById(1).beginTime)) or (tonumber(nowHour) > tonumber(DB_Legion_feast.getDataById(1).endTime))) then
	    	AnimationTip.showTip(GetLocalizeStringBy("key_1829"))
	    	baiBtn:setVisible(false)
	    	baiOver:setVisible(true)
	    else
	    	print(GetLocalizeStringBy("key_1203"))
	    	baiWay = 0
	    	local subArg = CCArray:create()
	    	subArg:addObject(CCInteger:create(0))
	    	Network.rpc(fnHandlerOfNetwork, "guild.reward","guild.reward", subArg, true)
	    end
	else
		if tonumber(GuildDataCache.getCoinBaiTimes()) >= tonumber(afterString[1]) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1350"))
		elseif ((tonumber(nowTime) < tonumber(DB_Legion_feast.getDataById(1).beginTime)) or (tonumber(nowHour) > tonumber(DB_Legion_feast.getDataById(1).endTime))) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1829"))
	    	baiBtn:setVisible(false)
	    	baiOver:setVisible(true)
		else
			local function confirmCBFunc()
				require "script/model/user/UserModel"
				if UserModel.getGoldNumber() < needGold then
					-- 金币不足
					require "script/ui/tip/LackGoldTip"
			    	LackGoldTip.showTip()
				else
					print(GetLocalizeStringBy("key_1491"))
					baiWay = 1
					local subArg = CCArray:create()
			    	subArg:addObject(CCInteger:create(1))
					Network.rpc(fnHandlerOfNetwork, "guild.reward","guild.reward", subArg, true)
				end
			end

			require "script/ui/tip/AlertTipGold"
			if tonumber(needGold) >= 100 then
				AlertTipGold.showAlert( GetLocalizeStringBy("key_2403"), needGold, confirmCBFunc)
			else
				AlertTipGold.showAlert( GetLocalizeStringBy("key_2024"), needGold, confirmCBFunc)
			end
		end
	end
end

function fnRewardMenuAction()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/guild/ShowGuangongReward"

    local layer = ShowGuangongReward.createLayer()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer,999)
end

function createUI()
	_layerSize = _bgLayer:getContentSize()

	local bgPicture = CCSprite:create("images/guild/guangong/guangongbg.jpg")
	bgPicture:setAnchorPoint(ccp(0.5,0.5))
	bgPicture:setPosition(g_winSize.width/2,g_winSize.height/2)
	bgPicture:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgPicture)

	createTopUI()

	local goldGuangong = CCSprite:create("images/guild/guangong/greatguangong.png")
	goldGuangong:setPosition(ccp(10*MainScene.elementScale,_layerSize.height-90*g_fScaleY))
	goldGuangong:setAnchorPoint(ccp(0,1))
	_bgLayer:addChild(goldGuangong)
	goldGuangong:setScale(MainScene.elementScale)

	local guangongLevel = GuildDataCache.getGuanyuTempleLevel()
	local guangongLv = CCRenderLabel:create("Lv." .. guangongLevel, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	guangongLv:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    guangongLv:setPosition(ccp(250*MainScene.elementScale,_layerSize.height-95*g_fScaleY))
else
	guangongLv:setPosition(ccp(180*MainScene.elementScale,_layerSize.height-120*g_fScaleY))
end
	guangongLv:setAnchorPoint(ccp(0,1))
	_bgLayer:addChild(guangongLv)
	guangongLv:setScale(MainScene.elementScale)

	local totalDonate = CCRenderLabel:create(GetLocalizeStringBy("key_1185"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	totalDonate:setColor(ccc3(0xfe, 0xdb, 0x1c))
	local donateNumber = CCRenderLabel:create(GuildDataCache.getGuildDonate(), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	donateNumber:setColor(ccc3(0xff,0xff,0xff))

	local label1 = BaseUI.createHorizontalNode({totalDonate, donateNumber})
    label1:setAnchorPoint(ccp(0, 1))
	label1:setPosition(ccp(15*MainScene.elementScale,_layerSize.height-90*g_fScaleY-goldGuangong:getContentSize().height*g_fScaleY))
	_bgLayer:addChild(label1)
	label1:setScale(MainScene.elementScale)

	local nextNeed = CCRenderLabel:create(GetLocalizeStringBy("key_3041"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nextNeed:setColor(ccc3(0xfe, 0xdb, 0x1c))
	local expid = DB_Legion_feast.getDataById(1).expId
	local nextLv = GuildDataCache.getGuanyuTempleLevel()+1
	local expNum = DB_Level_up_exp.getDataById(tonumber(expid))["lv_" .. nextLv]

	require "script/ui/guild/GuildUtil"
	local needNumber
	if guangongLevel >= tonumber(GuildUtil.getMaxGongyuLevel()) then
		needNumber = CCRenderLabel:create("--", g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	else
 		needNumber = CCRenderLabel:create(expNum, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 	end
	needNumber:setColor(ccc3(0xff,0xff,0xff))

	local label2 = BaseUI.createHorizontalNode({nextNeed, needNumber})
    label2:setAnchorPoint(ccp(0, 1))
	label2:setPosition(ccp(15*MainScene.elementScale,_layerSize.height-120*g_fScaleY-goldGuangong:getContentSize().height*g_fScaleY))
	_bgLayer:addChild(label2)
	label2:setScale(MainScene.elementScale)

	local remainNum = CCRenderLabel:create(GetLocalizeStringBy("key_1956"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	remainNum:setColor(ccc3(0xfe, 0xdb, 0x1c))
	local totalNum = GuildDataCache.getMemberLimit()
	local guildInfo = GuildDataCache.getGuildInfo()
	print("blabla")
	print_t(guildInfo)
	local haveNum = GuildDataCache.getGuildRewardTimes()
	print(GetLocalizeStringBy("key_3205"),totalNum,haveNum)
	remainNumber = CCRenderLabel:create(totalNum-haveNum, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	remainNumber:setColor(ccc3(0xff,0xff,0xff))

	local remainNum2 = CCRenderLabel:create(GetLocalizeStringBy("key_2126"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	remainNum2:setColor(ccc3(0xfe, 0xdb, 0x1c))

	label3 = BaseUI.createHorizontalNode({remainNum, remainNumber,remainNum2})
    label3:setAnchorPoint(ccp(0, 1))
	label3:setPosition(ccp(15*MainScene.elementScale,_layerSize.height-150*g_fScaleY-goldGuangong:getContentSize().height*g_fScaleY))
	_bgLayer:addChild(label3)
	label3:setScale(MainScene.elementScale)

	--[[if tonumber(totalNum-haveNum) == 0 then
		label3:setVisible(false)
	end]]

	local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    _bgLayer:addChild(menu,99)

    --关公殿奖励预览按钮
	rewardMenuItem = CCMenuItemImage:create("images/guild/guangong/reward_n.png","images/guild/guangong/reward_h.png")
	rewardMenuItem:registerScriptTapHandler(fnRewardMenuAction)
	rewardMenuItem:setScale(MainScene.elementScale)
	rewardMenuItem:setAnchorPoint(ccp(1,0))
	rewardMenuItem:setPosition(_layerSize.width-120*MainScene.elementScale,_layerSize.height-175*g_fScaleY)
	menu:addChild(rewardMenuItem)

	returnBtn = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	returnBtn:registerScriptTapHandler(returnBack)
	--returnBtn:setScale(MainScene.elementScale)
	--returnBtn:setContentSize(CCSizeMake(rewardMenuItem:getContentSize().width,rewardMenuItem:getContentSize().height))
	returnBtn:setScale(MainScene.elementScale)
	returnBtn:setAnchorPoint(ccp(1,0))
	returnBtn:setPosition(_layerSize.width-10*MainScene.elementScale,_layerSize.height-175*g_fScaleY)
	menu:addChild(returnBtn)

	local curTime = TimeUtil.getSvrTimeByOffset()
	local date = os.date("*t", curTime)
	local nowHour = date.hour
	local nowMin = date.min
	local nowSec = date.sec

	local nowTime = tonumber(nowHour)*10000 + tonumber(nowMin)*100 + tonumber(nowSec)

	baiBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),"",ccc3(0xfe, 0xdb, 0x1c))
	baiBtn:registerScriptTapHandler(baiGuangong)
	baiBtn:setScale(MainScene.elementScale)
	baiBtn:setAnchorPoint(ccp(0.5,0.5))
	baiBtn:setPosition(_layerSize.width/2,_layerSize.height/2-290*g_fScaleY)
	menu:addChild(baiBtn)
	baiBtn:setVisible(false)

	normalBai = CCRenderLabel:create(GetLocalizeStringBy("key_2595"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	normalBai:setColor(ccc3(0xfe, 0xdb, 0x1c))
	normalBai:setAnchorPoint(ccp(0.5,0.5))
	normalBai:setPosition(ccp(baiBtn:getContentSize().width/2,baiBtn:getContentSize().height/2))
	baiBtn:addChild(normalBai)
	normalBai:setVisible(false)

	local goldCan = CCRenderLabel:create(GetLocalizeStringBy("key_2595"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	goldCan:setColor(ccc3(0xfe, 0xdb, 0x1c))
	local goldPic = CCSprite:create("images/common/gold.png")
	require "db/DB_Vip"
    require "script/model/user/UserModel"
    local vipLevel = UserModel.getVipLevel()
    local dbVip = DB_Vip.getDataById(vipLevel+1)
    local vipString = dbVip.legionFeastCost
    afterString = lua_string_split(vipString,"|")
    needGold = tonumber(afterString[2])+(GuildDataCache.getCoinBaiTimes())*tonumber(afterString[3])
    goldNum = CCLabelTTF:create(tostring(needGold),g_sFontName,32)
    goldNum:setColor(ccc3(0xff,0xff,0xff))

    goldBai = BaseUI.createHorizontalNode({goldCan ,goldPic, goldNum})
    goldBai:setAnchorPoint(ccp(0.5,0.5))
    goldBai:setPosition(ccp(baiBtn:getContentSize().width/2,baiBtn:getContentSize().height/2))
    baiBtn:addChild(goldBai)
    goldBai:setVisible(false)

	baiOver = CCRenderLabel:create(GetLocalizeStringBy("key_3071"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	baiOver:setColor(ccc3(0xff,0xff,0xff))
	baiOver:setScale(MainScene.elementScale)
	baiOver:setAnchorPoint(ccp(0.5,0.5))
	baiOver:setPosition(_layerSize.width/2,_layerSize.height/2-290*g_fScaleY)
	_bgLayer:addChild(baiOver)
	baiOver:setVisible(false)

	greenCh = CCLabelTTF:create(GetLocalizeStringBy("key_1109") .. tostring(afterString[1] - GuildDataCache.getCoinBaiTimes()),g_sFontName,25)
	greenCh:setColor(ccc3(0x00,0xff,0x18))
	greenCh:setAnchorPoint(ccp(0.5,0.5))
	greenCh:setPosition(ccp(_layerSize.width/2,_layerSize.height/2-340*g_fScaleY))
	_bgLayer:addChild(greenCh)
	greenCh:setScale(MainScene.elementScale)

	if (tonumber(nowTime) >= tonumber(DB_Legion_feast.getDataById(1).beginTime)) and (tonumber(nowHour) <= tonumber(DB_Legion_feast.getDataById(1).endTime))then
		if tonumber(GuildDataCache.getBaiGuangongTimes()) <= 0 then
			if GuildDataCache.getCoinBaiTimes() >= tonumber(afterString[1]) then
				baiBtn:setVisible(false)
				baiOver:setVisible(true)
			else
				baiBtn:setVisible(true)
				normalBai:setVisible(false)
				goldBai:setVisible(true)
				baiOver:setVisible(false)
			end
		else
			greenCh:setVisible(false)
			baiBtn:setVisible(true)
			normalBai:setVisible(true)
			goldBai:setVisible(false)
			baiOver:setVisible(false)
		end
	end

	
	local wenzi1 = CCRenderLabel:create(GetLocalizeStringBy("key_3268"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	wenzi1:setColor(ccc3(0xfe, 0xdb, 0x1c))

	local bHour = math.ceil(DB_Legion_feast.getDataById(1).beginTime/10000)
	local eHour = math.ceil(DB_Legion_feast.getDataById(1).endTime/10000)

	local wenzi2 = CCRenderLabel:create(bHour .. GetLocalizeStringBy("key_2142") .. eHour ..GetLocalizeStringBy("key_2132"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	wenzi2:setColor(ccc3(0x00, 0xe4, 0xff))

	local wenzi3 = CCRenderLabel:create(GetLocalizeStringBy("key_2846"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	wenzi3:setColor(ccc3(0xfe, 0xdb, 0x1c))

    aleteNode1 = BaseUI.createHorizontalNode({wenzi1, wenzi2, wenzi3})
    aleteNode1:setAnchorPoint(ccp(0.5, 0.5))
	aleteNode1:setPosition(ccp(_layerSize.width/2, _layerSize.height/2-160*g_fScaleY))
	_bgLayer:addChild(aleteNode1)
	aleteNode1:setScale(MainScene.elementScale)



	local wenzi4 = CCRenderLabel:create(GetLocalizeStringBy("key_2814"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	wenzi4:setColor(ccc3(0xfe, 0xdb, 0x1c))
	wenzi4:setAnchorPoint(ccp(0.5,0.5))
	wenzi4:setPosition(ccp(_layerSize.width/2, _layerSize.height/2-170*g_fScaleY-aleteNode1:getContentSize().height*g_fScaleY))
	_bgLayer:addChild(wenzi4)
	wenzi4:setScale(MainScene.elementScale)

	local wenzi5 = CCRenderLabel:create(GetLocalizeStringBy("key_2445"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	wenzi5:setColor(ccc3(0xf7,0x3e,0xf9))

	local wenzi6 = CCRenderLabel:create(DB_Legion_feast.getDataById(1).contributeCost, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	wenzi6:setColor(ccc3(0xfe, 0xdb, 0x1c))

	local aleteNode2 = BaseUI.createHorizontalNode({wenzi5, wenzi6})
    aleteNode2:setAnchorPoint(ccp(0.5, 0.5))
	aleteNode2:setPosition(ccp(_layerSize.width/2, _layerSize.height/2-180*g_fScaleY-aleteNode1:getContentSize().height*g_fScaleY-wenzi4:getContentSize().height*g_fScaleY))
	_bgLayer:addChild(aleteNode2)
	aleteNode2:setScale(MainScene.elementScale)
end

function showLayer()
	init()

	MainScene.getAvatarLayerObj():setVisible(false)
	require "script/ui/main/MenuLayer"
	MenuLayer.getObject():setVisible(false)

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	require "script/ui/guild/GuildBottomSprite"
	local bottomSprite = GuildBottomSprite.createBottomSprite()
	_bgLayer:addChild(bottomSprite,20)
	bottomSprite:setScale(g_fScaleX)
	bottomSprite:setAnchorPoint(ccp(0.5,0))
	bottomSprite:setPosition(ccp(g_winSize.width/2,0))

	createUI()

	return _bgLayer
end

function refreshSilver()
	local userInfo = UserModel.getUserInfo()
	silverLabel:setString(string.convertSilverUtilByInternational(tonumber(userInfo.silver_num)))  -- modified by yangrui at 2015-12-03
end

function refreshGold()
	local userInfo = UserModel.getUserInfo()
	goldLabel:setString(userInfo.gold_num)
end

function refreshBaiNum(nowNum)
	local totalNum = GuildDataCache.getMemberLimit()
	remainNumber:setString(tostring(totalNum-nowNum))
	GuildDataCache.addGuildRewardTimes(1)
end
