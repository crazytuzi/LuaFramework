-- FileName: AwardPoolLayer.lua 
-- Author: Zhang Zihang
-- Date: 2014/8/5
-- Purpose: 奖池界面

module("AwardPoolLayer",package.seeall)

require "script/audio/AudioUtil"
require "script/ui/olympic/OlympicData"
require "script/model/utils/HeroUtil"
require "script/model/hero/HeroModel"
require "script/ui/olympic/OlympicService"

local _touchPriority
local _zOrder
local _bgLayer
local _redBgSprite 			--红色背景框
local _secondSprite 		--棕色背景框
local _kingChairSprite		--底座背景图
local _wholePoolNum 		--奖池所有奖金数额
local _killerNum			--终结者奖金数额
local _cheerUpNum 			--助威者金额
local _winnerPoolNum 		--奖池总金额
local _winnerRatio 			--冠军分成比例
local _killerRatio 			--终结者分成比例
local _cheerRatio 			--助威者分成比例
local _winnerNumLabel 		--冠军得到奖金label
local _winnerRatioLabel 	--冠军分成label	
local _isInit = false		--是否进行了初始化
local kBodyTag = 1000 		--角色tag值
local kDownTipTag = 1500	--底框tag值
local kUpTipTag = 2000 		--顶框tag值

----------------------------------------初始化函数----------------------------------------
local function init()
	_touchPriority = nil
	_zOrder = nil
	_bgLayer = nil
	_redBgSprite = nil
	_secondSprite = nil
	_kingChairSprite = nil
	_winnerNumLabel = nil
	_winnerRatioLabel = nil
	_wholePoolNum = 0
	_killerNum = 0
	_cheerUpNum = 0
	_winnerPoolNum = 0
	_winnerRatio = 0
	_killerRatio = 0
	_cheerRatio = 0
	_isInit = true
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
        print("end")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:关闭回调
	@param 	:
	@return :
--]]
function closeCallBack()
	_isInit = false
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:推送阶段回调
	@param 	:阶段数
	@return :
--]]
function changeStageCallBack(p_stageNum)
	--阶段8且在这个界面
	--因为在界面才会有初始化
	if (tonumber(p_stageNum) == 8) and (_isInit == true) then
		--如果存在上届冠军
		local lastChampion = OlympicData.getChampionInfo()
		if tonumber(lastChampion.uid) ~= 0 then
			--删除原来角色的图像和名字
			for i = 1,2 do
				_kingChairSprite:removeChildByTag(kBodyTag + i,true)
			end
		end

		--连胜初始化
		local comboTimes = 0
		--创建新冠军
		local championInfo = OlympicData.getWinnerInfo()
		if not table.isEmpty(championInfo) then
			--创建冠军头像
			createKingBody(championInfo)

			--如果这届冠军和上届冠军相同
			if tonumber(championInfo.uid) == OlympicData.lastChampionUid() then
				comboTimes = OlympicData.getComboTimes()
			else
				comboTimes = 1
			end
		end

		_winnerRatio,_killerRatio,_cheerRatio = OlympicData.getAwardPoolRatio(comboTimes)

		--冠军分得的奖金数
		_winnerPoolNum = _wholePoolNum*_winnerRatio
		--终结者分得的奖金数
		_killerNum = _wholePoolNum*_killerRatio
		--助威者分得的奖金数
		_cheerUpNum = _wholePoolNum*_cheerRatio

		--更新连胜次数
		tolua.cast(_brownPicSprite:getChildByTag(kDownTipTag + 1),"CCLabelTTF"):setString(tostring(comboTimes))
		--减战斗力
		tolua.cast(_brownPicSprite:getChildByTag(kDownTipTag + 2),"CCLabelTTF"):setString("-" .. OlympicData.getReduceFightValue(comboTimes) .. "%")
		--冠军分的奖金数
		_winnerNumLabel:setString(tostring(math.ceil(_winnerPoolNum)))
		--冠军分成
		_winnerRatioLabel:setString("（" .. _winnerRatio*100 .. GetLocalizeStringBy("zzh_1083"))
		--终结者获得奖励数
		tolua.cast(_redBgSprite:getChildByTag(kUpTipTag + 2),"CCLabelTTF"):setString(tostring(math.ceil(_killerNum)))
		--助威者奖励数
		tolua.cast(_redBgSprite:getChildByTag(kUpTipTag + 3),"CCLabelTTF"):setString(tostring(math.ceil(_cheerUpNum)))
		--终结者分成
		tolua.cast(_redBgSprite:getChildByTag(kUpTipTag + 4),"CCLabelTTF"):setString("（" .. _killerRatio*100 .. GetLocalizeStringBy("zzh_1083"))
		--助威者分成
		tolua.cast(_redBgSprite:getChildByTag(kUpTipTag + 5),"CCLabelTTF"):setString("（" .. _cheerRatio*100 .. GetLocalizeStringBy("zzh_1083"))
	end
end

--[[
	@des 	:增加奖池金额回调
	@param 	:
	@return :
--]]
function addSilverPoolCallBack()
	print("是否初始化",_isInit)
	if _isInit == true then
		--奖池总金额
	    _wholePoolNum = OlympicData.getSilverPoolNum()

	    --冠军分得的奖金数
		_winnerPoolNum = _wholePoolNum*_winnerRatio
		--终结者分得的奖金数
		_killerNum = _wholePoolNum*_killerRatio
		--助威者分得的奖金数
		_cheerUpNum = _wholePoolNum*_cheerRatio

		--冠军分的奖金数
		_winnerNumLabel:setString(tostring(math.ceil(_winnerPoolNum)))
		--总金额数
		tolua.cast(_redBgSprite:getChildByTag(kUpTipTag + 1),"CCLabelTTF"):setString(tostring(_wholePoolNum))
		--终结者获得奖励数
		tolua.cast(_redBgSprite:getChildByTag(kUpTipTag + 2),"CCLabelTTF"):setString(tostring(math.ceil(_killerNum)))
		--助威者奖励数
		tolua.cast(_redBgSprite:getChildByTag(kUpTipTag + 3),"CCLabelTTF"):setString(tostring(math.ceil(_cheerUpNum)))
	end
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建背景UI
	@param 	:
	@return :
--]]
function createBgUI()
	--主背景图
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(620,840))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
	bgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(bgSprite)

	--标题背景
	local titleSprite = CCSprite:create("images/common/viewtitle1.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
	bgSprite:addChild(titleSprite)

	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1061"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
	titleSprite:addChild(titleLabel)

	--红色标题背景
	_redBgSprite = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
	_redBgSprite:setContentSize(CCSizeMake(465,160))
	_redBgSprite:setAnchorPoint(ccp(0.5,1))
	_redBgSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 60))
	bgSprite:addChild(_redBgSprite)

	--二级背景
	_secondSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_secondSprite:setContentSize(CCSizeMake(570,500))
	_secondSprite:setAnchorPoint(ccp(0.5,0))
	_secondSprite:setPosition(ccp(bgSprite:getContentSize().width/2,95))
	bgSprite:addChild(_secondSprite)

	--两行提示表
	local tipTable = {
						[1] = "zzh_1062",
						[2] = "zzh_1063",
					 }
	--两行提示
	--坚持代码重用基本方针100年不动摇 - - ！
	for i = 1,2 do
		local tipLabel = CCLabelTTF:create(GetLocalizeStringBy(tipTable[i]),g_sFontPangWa,23)
		tipLabel:setColor(ccc3(0x78,0x25,0x00))
		tipLabel:setAnchorPoint(ccp(0.5,0))
		tipLabel:setPosition(ccp(bgSprite:getContentSize().width/2,65 - 35*(i - 1)))
		bgSprite:addChild(tipLabel)
	end

	--背景层
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(bgMenu)

	--关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)
end

--[[
	@des 	:创建红色背景中的UI
	@param 	:
	@return :
--]]
function  createUpperUI()
	--钱包图标（Lamborghini牌子的哦）
	local pocketSprite = CCSprite:create("images/olympic/awardpool/lvbaobao.png")
	pocketSprite:setAnchorPoint(ccp(0.5,0.5))
	pocketSprite:setPosition(ccp(50,_redBgSprite:getContentSize().height/2))
	_redBgSprite:addChild(pocketSprite)

	--标题文字表
	local tipNameTable = {
							[1] = "zzh_1067",
							[2] = "zzh_1068",
							[3] = "zzh_1069",
						 }
	--标题位置表
	local tipNameYTable = {
								[1] = _redBgSprite:getContentSize().height - 10,
								[2]	= _redBgSprite:getContentSize().height - 45,
								[3] = _redBgSprite:getContentSize().height - 100,
						  }

	--红框内描述文字
	for i = 1,3 do
		--提示文字
		local tipNameLabel = CCLabelTTF:create(GetLocalizeStringBy(tipNameTable[i]),g_sFontPangWa,18)
		tipNameLabel:setAnchorPoint(ccp(1,1))
		tipNameLabel:setPosition(ccp(_redBgSprite:getContentSize().width - 170,tipNameYTable[i]))
		_redBgSprite:addChild(tipNameLabel)

		--银币图标
		local coinSprite = CCSprite:create("images/common/coin.png")
		coinSprite:setAnchorPoint(ccp(0,1))
		coinSprite:setPosition(ccp(_redBgSprite:getContentSize().width - 170,tipNameYTable[i]))
		_redBgSprite:addChild(coinSprite)

		local coinNumLabel

		if i == 1 then
			coinNumLabel = CCLabelTTF:create(tostring(math.ceil(_wholePoolNum)),g_sFontPangWa,18)
			tipNameLabel:setColor(ccc3(0xe4,0x00,0xff))
		end
		if i == 2 then
			coinNumLabel = CCLabelTTF:create(tostring(math.ceil(_killerNum)),g_sFontPangWa,18)
			tipNameLabel:setColor(ccc3(0x00,0xe4,0xff))
		end
		if i == 3 then
			coinNumLabel = CCLabelTTF:create(tostring(math.ceil(_cheerUpNum)),g_sFontPangWa,18)
			tipNameLabel:setColor(ccc3(0xff,0xff,0xff))
		end

		coinNumLabel:setColor(ccc3(0xff,0xf6,0x00))
		coinNumLabel:setAnchorPoint(ccp(0,1))
		coinNumLabel:setPosition(ccp(_redBgSprite:getContentSize().width - 160 + coinSprite:getContentSize().width,tipNameYTable[i]))
		_redBgSprite:addChild(coinNumLabel,1,kUpTipTag + i)
	end

	--奖池比例描述文字
	for i = 1,2 do
		local ratioLabel
		--终结者分成
		if i == 1 then
			ratioLabel = CCLabelTTF:create("（" .. _killerRatio*100 .. GetLocalizeStringBy("zzh_1083"),g_sFontName,18)
		end
		--助威者分成
		if i == 2 then
			ratioLabel = CCLabelTTF:create("（" .. _cheerRatio*100 .. GetLocalizeStringBy("zzh_1083"),g_sFontName,18)
		end
		ratioLabel:setColor(ccc3(0x00,0xff,0x18))
		ratioLabel:setAnchorPoint(ccp(0,1))
		ratioLabel:setPosition(ccp(_redBgSprite:getContentSize().width - 250,_redBgSprite:getContentSize().height - 75 - 55*(i - 1)))
		_redBgSprite:addChild(ratioLabel,1,kUpTipTag + i + 3)
	end
end

--[[
	@des 	:创建棕色背景中的UI
	@param 	:
	@return :
--]]
function createDownUI()
	--棕色背景图
	_brownPicSprite = CCSprite:create("images/olympic/awardpool/brownbottom.jpg")
	_brownPicSprite:setAnchorPoint(ccp(0.5,0.5))
	_brownPicSprite:setPosition(ccp(_secondSprite:getContentSize().width/2,_secondSprite:getContentSize().height/2))
	_secondSprite:addChild(_brownPicSprite)

	--台子图
	_kingChairSprite = CCSprite:create("images/olympic/kingChair.png")
	_kingChairSprite:setAnchorPoint(ccp(0.5,0))
	_kingChairSprite:setPosition(ccp(_brownPicSprite:getContentSize().width/2,20))
	_kingChairSprite:setScale(1.6)
	_brownPicSprite:addChild(_kingChairSprite)

	--红光
	local kingLightSprite = CCSprite:create("images/olympic/kingLight.png")
	kingLightSprite:setAnchorPoint(ccp(0.5,0))
	kingLightSprite:setPosition(ccp(_kingChairSprite:getContentSize().width/2,70))
	_kingChairSprite:addChild(kingLightSprite)

	--冠军全身像
	--如果在阶段8
	local championInfo
	--连胜次数
	local comboTimes = 0
	if OlympicData.getStage() == OlympicData.kAfterStage then
		--如果冠军不为空
		championInfo = OlympicData.getWinnerInfo()
		if not table.isEmpty(championInfo) then
			--创建冠军头像
			createKingBody(championInfo)

			--如果这届冠军和上届冠军相同
			-- if tonumber(championInfo.uid) == OlympicData.lastChampionUid() then
			-- 	comboTimes = OlympicData.getComboTimes() + 1
			-- else
			-- 	comboTimes = 1
			-- end
			comboTimes = OlympicData.getComboTimes()
		end
	--如果在其他阶段，则得到上届冠军信息
	else
		--得到上届冠军
		championInfo = OlympicData.getChampionInfo()
		print("上届管局你是谁")
		print_t(championInfo)
		if tonumber(championInfo.uid) ~= 0 then
			--创建冠军头像
			createKingBody(championInfo)

			--连胜次数
			comboTimes = OlympicData.getComboTimes()
		end
	end

	_winnerRatio,_killerRatio,_cheerRatio = OlympicData.getAwardPoolRatio(comboTimes)

	--冠军分得的奖金数
	_winnerPoolNum = _wholePoolNum*_winnerRatio
	--终结者分得的奖金数
	_killerNum = _wholePoolNum*_killerRatio
	--助威者分得的奖金数
	_cheerUpNum = _wholePoolNum*_cheerRatio

	--连击表
	local comboTable = {
							[1] = "zzh_1064",
							[2] = "zzh_1065",
					   }

	--连胜次数和下届擂台赛战斗力提示
	for i = 1,2 do
		local comboLabel = CCLabelTTF:create(GetLocalizeStringBy(comboTable[i]),g_sFontPangWa,21)
		comboLabel:setColor(ccc3(0xff,0xf6,0x00))
		comboLabel:setAnchorPoint(ccp(1,1))
		comboLabel:setPosition(ccp(230,_brownPicSprite:getContentSize().height - 5 - 55*(i - 1)))
		_brownPicSprite:addChild(comboLabel)

		local comboTimeLabel
		if i == 1 then
			comboTimeLabel = CCLabelTTF:create(tostring(comboTimes),g_sFontPangWa,21)
			comboTimeLabel:setColor(ccc3(0x00,0xff,0x18))
		elseif i == 2 then
			comboTimeLabel = CCLabelTTF:create("-" .. OlympicData.getReduceFightValue(comboTimes) .. "%",g_sFontPangWa,21)
			comboTimeLabel:setColor(ccc3(0xff,0x00,0x00))
		end
		comboTimeLabel:setAnchorPoint(ccp(0,1))
		comboTimeLabel:setPosition(ccp(230,_brownPicSprite:getContentSize().height - 5 - 55*(i - 1)))
		_brownPicSprite:addChild(comboTimeLabel,1,kDownTipTag + i)
	end

	--下部BaseUI
	--当前冠军奖金，label
	local curWinnerLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1066"),g_sFontPangWa,21)
	curWinnerLabel:setColor(ccc3(0xff,0xf6,0x00))
	--银币图标
	local silverSprite = CCSprite:create("images/common/coin.png")
	--冠军获得奖金数
	_winnerNumLabel = CCLabelTTF:create(tostring(math.ceil(_winnerPoolNum)),g_sFontPangWa,21)
	_winnerNumLabel:setColor(ccc3(0x00,0xff,0x18))
	--冠军分成
	_winnerRatioLabel = CCLabelTTF:create("（" .. _winnerRatio*100 .. GetLocalizeStringBy("zzh_1083"),g_sFontName,21)
	_winnerRatioLabel:setColor(ccc3(0x00,0xff,0x18))
	_winnerRatioLabel:setAnchorPoint(ccp(0.5,1))
	_winnerRatioLabel:setPosition(ccp(400,_brownPicSprite:getContentSize().height - 40))
	_brownPicSprite:addChild(_winnerRatioLabel)

	--下部UINode
	local downBaseUI = BaseUI.createHorizontalNode({curWinnerLabel,silverSprite,_winnerNumLabel})
	downBaseUI:setAnchorPoint(ccp(0,1))
	downBaseUI:setPosition(ccp(270,_brownPicSprite:getContentSize().height - 5))
	_brownPicSprite:addChild(downBaseUI)
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_zOrder)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    --奖池总金额
    _wholePoolNum = OlympicData.getSilverPoolNum()
    
    --创建背景UI
    createBgUI()
    --创建下面的UI
    createDownUI()
    --创建上面的UI
    createUpperUI()

    --增加奖池金额推送
    OlympicService.re_olympic_refreshSilverPool(addSilverPoolCallBack)
end

----------------------------------------工具函数----------------------------------------
--[[
	@des 	:创建人物形象
	@param 	:冠军信息
	@return :
--]]
function createKingBody(p_kingInfo)

	print("p_kingInfo.htid",p_kingInfo.htid)

	local playerGender = HeroModel.getSex(p_kingInfo.htid)
	local imagePath
	if not table.isEmpty(p_kingInfo.dress) then
		imagePath = HeroUtil.getHeroBodyImgByHTID(p_kingInfo.htid,p_kingInfo.dress["1"],playerGender)
	else
		imagePath = HeroUtil.getHeroBodyImgByHTID(p_kingInfo.htid)
	end
	local playerBodySprite = CCSprite:create(tostring(imagePath))
	playerBodySprite:setAnchorPoint(ccp(0.5,0))
	playerBodySprite:setPosition(ccp(_kingChairSprite:getContentSize().width/2,70))
	playerBodySprite:setScale(0.35)
	_kingChairSprite:addChild(playerBodySprite,1,kBodyTag + 1)

	--级别提示
	local lvLabel = CCRenderLabel:create("LV." .. p_kingInfo.level,g_sFontPangWa,22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	lvLabel:setColor(ccc3(0xff,0xf6,0x00))

	--名字
	local playerNameLabel = CCRenderLabel:create(" " .. p_kingInfo.uname,g_sFontPangWa,22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)

	local levelName = BaseUI.createHorizontalNode({lvLabel,playerNameLabel})
	levelName:setAnchorPoint(ccp(0.5,0))
	levelName:setPosition(ccp(_kingChairSprite:getContentSize().width/2,60))
	--5/8 就是 1/1.6
	levelName:setScale(5/8)
	_kingChairSprite:addChild(levelName,1,kBodyTag + 2)
end