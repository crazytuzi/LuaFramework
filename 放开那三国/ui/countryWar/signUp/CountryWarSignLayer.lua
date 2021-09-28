-- FileName: CountryWarSignLayer.lua
-- Author: shengyixian
-- Date: 2015-11-02
-- Purpose: 国战报名界面
module("CountryWarSignLayer",package.seeall)
require "script/ui/countryWar/signUp/CountryWarSignController"
require "script/ui/countryWar/signUp/CountryWarSignData"

-- 向左滑动的标志
local kLeftDirection = "left"
-- 向右滑动的标志
local kRightDirection = "right"
-- 阵营移动一个区间需要的时间
local kMoveTime = 0.5
-- 各个阵营图标相对于X正方向的起始夹角
local kAngleAry = {math.pi * 1.5,math.pi,math.pi * 0.5,0}
-- 阵营不透明度的数组
local kOpacityAry = {255,200,180,200}
-- 旋转中心
local _centerPoint = nil
-- 水平方向的旋转半径
local _radiusX = nil
-- 垂直方向的旋转半径
local _radiusY = nil
-- 存储阵营旋转过程中的夹角
local _tempAngleAry = nil
-- 旋转角速度
local _radSpeed = nil
local _layer = nil
-- 阵容层
local _touchPriority = -411
-- 报名奖励说明
local _rewardExplainLabel = nil
-- 选择国家的文本
local _chooseCampSp = nil
-- 阵营数组
local _campAry = nil
-- 阵营坐标数组
local _campPosAry = nil
-- 阵营缩放系数数组
local _campScaleAry = nil
-- 阵营zOrder数组
local _campZOrderAry = nil
-- 阵营名字数组
local _campNameAry = nil
-- 阵营名字颜色的数组
local _campNameColorAry = nil
-- 选择阵营的滑动过程中上次的触摸位置
local _lastX = nil
-- 阵营转动的方向
local _moveDiretion = nil
-- 当前选择阵营文本
local _currCampLabel = nil
-- 当前选择阵营人数比例
local _currCampPercentage = nil
-- 已经选择的阵营ID，如果有值，则表明玩家已有阵营
local _campID = nil
-- 当前正在选择的阵营
local _currCamp = nil
-- 倒计时显示
local _countdownTimer = nil
-- 报名按钮
local _signBtn = nil
-- 按钮层
local _menuLayer = nil
-- 箭头的容器
local _arrowContainer = nil
function init( ... )
	-- body
	_layer = nil
	_lastX = nil
	_moveDiretion = nil
	_rewardExplainLabel = nil
	_campID = nil
	_currCamp = nil
	_chooseCampSp = nil
	_countdownTimer = nil
	_signBtn = nil
	_menuLayer = nil
	_tempAngleAry = nil
	_arrowContainer = nil
	_centerPoint = nil
	_radiusX = nil
	_radiusY = nil
	_radSpeed = nil
end

function createUI( ... )
	_campID = CountryWarSignData.getSignedCountryID()
	_menuLayer = CCMenu:create()
	_menuLayer:setTouchPriority(_touchPriority - 1)
	_menuLayer:setPosition(ccp(0,0))
	_layer:addChild(_menuLayer)
	createBtn()
	local campTitlePath = nil
	local btnText = nil
	local isSignedUp = CountryWarSignData.isSignedUp()
	local currPhase = CountryWarMainData.getCurStage()
	-- 倒计时
   	_countdownTimer = CountryWarUtil.getCountdownSprite()
	_countdownTimer:setAnchorPoint(ccp(0.5, 1))
	_countdownTimer:setScale(g_fElementScaleRatio)
	_layer:addChild(_countdownTimer)
	if isSignedUp then
		campTitlePath = "images/country_war/signup/my_camp_title.png"
		_countdownTimer:setPosition(ccp(g_winSize.width * 0.5,g_winSize.height * 0.1))
	else
		campTitlePath = "images/country_war/signup/select_title.png"
		if (currPhase == CountryWarDef.SIGNUP) then
			createRewardInfo()
			_countdownTimer:setPosition(ccp(g_winSize.width * 0.5,g_winSize.height * 0.05))
		else
			_countdownTimer:setPosition(ccp(g_winSize.width * 0.5,g_winSize.height * 0.1))
		end
	end
	-- 标题两边的装饰
	local decorationLeft = CCSprite:create("images/country_war/signup/decoration.png")
	decorationLeft:setAnchorPoint(ccp(0,0.5))
	decorationLeft:setPosition(ccp(g_winSize.width / 2 - 330 * g_fBgScaleRatio,g_winSize.height * 0.85 + 10 * g_fBgScaleRatio))
	decorationLeft:setScale(0.9 * g_fElementScaleRatio)
	_layer:addChild(decorationLeft)
	local decorationRight = CCSprite:create("images/country_war/signup/decoration.png")
	decorationRight:setAnchorPoint(ccp(0,0.5))
	decorationRight:setPosition(ccp(g_winSize.width / 2 + 330 * g_fBgScaleRatio,decorationLeft:getPositionY()))
	decorationRight:setRotation(180)
	decorationRight:setScale(0.9 * g_fElementScaleRatio)
	decorationRight:setFlipY(true)
	_layer:addChild(decorationRight)
	createCampTitle(campTitlePath)
   	-- 国家选择说明信息
   	local selectExplainLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1029") , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    selectExplainLabel:setColor(ccc3( 0x00, 0xff, 0x18))
    selectExplainLabel:setAnchorPoint(ccp(0.5,0.5))
    selectExplainLabel:setPosition(ccp(g_winSize.width * 0.5,g_winSize.height * 0.23))
    selectExplainLabel:setScale(g_fElementScaleRatio)
   	_layer:addChild(selectExplainLabel)
   	-- 已参加阵营说明
   	local campExplainLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1036") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	campExplainLabel:setAnchorPoint(ccp(0.5,0.5))
   	campExplainLabel:setPosition(ccp(g_winSize.width * 0.3,g_winSize.height * 0.28))
   	campExplainLabel:setScale(g_fElementScaleRatio)
   	_layer:addChild(campExplainLabel)
   	_currCampLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1032") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	_currCampLabel:setColor(ccc3( 0xff, 0x00, 0x00))
   	_currCampLabel:setAnchorPoint(ccp(0,0.5))
   	_currCampLabel:setPosition(ccpsprite(1,0.5,campExplainLabel))
   	campExplainLabel:addChild(_currCampLabel)
   	local percentageExplainLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1037") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	percentageExplainLabel:setAnchorPoint(ccp(0,0.5))
   	percentageExplainLabel:setPosition(ccpsprite(1,0.5,_currCampLabel))
   	_currCampLabel:addChild(percentageExplainLabel)
   	_currCampPercentage = CCRenderLabel:create(GetLocalizeStringBy("yr_5000",0), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	_currCampPercentage:setColor(ccc3( 0xff, 0xff, 0x00))
   	_currCampPercentage:setAnchorPoint(ccp(0,0.5))
   	_currCampPercentage:setPosition(ccpsprite(1,0.5,percentageExplainLabel))
   	percentageExplainLabel:addChild(_currCampPercentage)
   	createCamp()
   	-- 注册对阶段变更的侦听
	CountryWarObserver.registerListener(phaseChangedCallBack)
end
--[[
	@des 	: 创建奖励信息
	@param 	: 
	@return : 
--]]
function createRewardInfo( ... )
   	local richInfo = {
        linespace = 2, -- 行间距
        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontPangWa,
        labelDefaultColor = ccc3( 0xfe, 0x7e, 0x00),
        labelDefaultSize = 23,
        defaultType = "CCRenderLabel",
        elements =
        {
            {
                type = "CCRenderLabel", 
                newLine = false,
                text = GetLocalizeStringBy("syx_1030"),
                renderType = 2,-- 1 描边， 2 投影
            },
        }
    }
   	local rewardAry = CountryWarSignData.getSignReward()
   	for i,v in ipairs(rewardAry) do
	   	local imagePath = nil
	   	local textColor = nil
	   	local rewardNum = v.num
	   	if v.type == "silver" then
	   		imagePath = "images/common/coin.png"
	   		textColor = ccc3( 0xff, 0xff, 0xff)
		else
			imagePath = "images/common/gold.png"
			textColor = ccc3( 0xff, 0xf6, 0x00)
	   	end
	   	local rewardInfo = {
	   						{
	   							type = "CCRenderLabel",
	   							newLine = false,
	   							text = rewardNum,
            					renderType = 2,
            					color = textColor		   							
	   						},
	   						{
	   							type = "CCSprite",
            					image = imagePath
	   						}
	   			 		 }
	   	richInfo.elements = table.connect({richInfo.elements,rewardInfo})
   	end
   	_rewardExplainLabel = LuaCCLabel.createRichLabel(richInfo)
	_rewardExplainLabel:setAnchorPoint(ccp(0.5, 1))
	_rewardExplainLabel:setScale(g_fElementScaleRatio)
	_rewardExplainLabel:setPosition(ccp(g_winSize.width*0.5, g_winSize.height * 0.13 - _signBtn:getContentSize().height * g_fBgScaleRatio * 0.5))
	_layer:addChild(_rewardExplainLabel)
end
--[[
	@des 	: 箭头的动画
	@param 	: 
	@return : 
--]]
function arrowAction( arrow)
	local arrActions_2 = CCArray:create()
	arrActions_2:addObject(CCFadeOut:create(1))
	arrActions_2:addObject(CCFadeIn:create(1))
	local sequence_2 = CCSequence:create(arrActions_2)
	local action_2 = CCRepeatForever:create(sequence_2)
	arrow:runAction(action_2)
end
--[[
	@des 	: 创建阵营
	@param 	: 
	@return : 
--]]
function createCamp( ... )
	_centerPoint = ccp(g_winSize.width * 0.5,g_winSize.height * 0.5 + 130 * g_fBgScaleRatio)
	_radiusX = 160 * g_fElementScaleRatio
	_radiusY = 80 * g_fElementScaleRatio
	_radSpeed = 0.06 / g_fElementScaleRatio
	_tempAngleAry = table.hcopy(kAngleAry,{})
	local campImagePathAry = {
		"images/country_war/signup/wei.png",
		"images/country_war/signup/shu.png",
		"images/country_war/signup/wu.png",
		"images/country_war/signup/qun.png",
	}
	_campNameAry = {
		GetLocalizeStringBy("syx_1032"),
		GetLocalizeStringBy("syx_1033"),
		GetLocalizeStringBy("syx_1034"),
		GetLocalizeStringBy("syx_1035"),
	}
	_campNameColorAry = {
		ccc3( 0x00, 0x80, 0xff),
		ccc3( 0xff, 0x00, 0x00),
		ccc3( 0x00, 0xff, 0x00),
		ccc3( 0xff, 0xd7, 0x00),
	}
	if _campID then
		_currCamp = CCSprite:create(campImagePathAry[_campID])
		_currCamp.campID = _campID
		_currCamp:setAnchorPoint(ccp(0.5,0.5))
		_currCamp:setPosition(ccp(_centerPoint.x,_centerPoint.y - _radiusY))
		_currCamp:setScale(g_fElementScaleRatio)
		_layer:addChild(_currCamp)
	else
		_campPosAry = {
			ccp(_centerPoint.x,_centerPoint.y - _radiusY),
			ccp(_centerPoint.x - _radiusX,_centerPoint.y),
			ccp(_centerPoint.x,_centerPoint.y + _radiusY),
			ccp(_centerPoint.x + _radiusX,_centerPoint.y)
		}
		_campScaleAry = {1 * g_fElementScaleRatio,0.7 * g_fElementScaleRatio,0.4 * g_fElementScaleRatio,0.7 * g_fElementScaleRatio}
		_campZOrderAry = {104,103,102,103}
		_campAry = {}
		local countryIDAry = getSortByNumAry()
		for i=1,4 do
			local countryID = countryIDAry[i]
			local camp = CCSprite:create(campImagePathAry[countryID])
			camp.campID = countryID
			camp:setAnchorPoint(ccp(0.5,0.5))
			camp:setPosition(_campPosAry[i])
			camp:setScale(_campScaleAry[i])
			camp:setOpacity(kOpacityAry[i])
			_layer:addChild(camp,_campZOrderAry[i])
			table.insert(_campAry,camp)
		end
		_currCamp = _campAry[1]
		_arrowContainer = CCSprite:create()
		_arrowContainer:setContentSize(g_winSize)
		_arrowContainer:setPosition(ccp(0,0))
		_layer:addChild(_arrowContainer)
		-- 箭头
		local arrowLeft = CCSprite:create("images/country_war/signup/arrow.png")
		arrowLeft:setPosition(ccp(g_winSize.width * 0.25,320 * g_fBgScaleRatio))
		arrowLeft:setAnchorPoint(ccp(0.5,0.5))
		arrowLeft:setScale(g_fElementScaleRatio)
		_arrowContainer:addChild(arrowLeft)
		arrowAction(arrowLeft)
		local arrowRight = CCSprite:create("images/country_war/signup/arrow.png")
		arrowRight:setPosition(ccp(g_winSize.width * 0.75,320 * g_fBgScaleRatio))
		arrowRight:setAnchorPoint(ccp(0.5,0.5))
		arrowRight:setFlipY(true)
		arrowRight:setRotation(180)
		arrowRight:setScale(g_fElementScaleRatio)
		_arrowContainer:addChild(arrowRight)
		arrowAction(arrowRight)
	end
	updateCampInfo()
end
--[[
	@des 	: 按每个国家的报名人数排序，人数最少的默认排在第一位
	@param 	: 
	@return : 
--]]
function getSortByNumAry( ... )
	local countryIDAry = {}
	-- 报名人数最少的国家ID
	local minCountryID = CountryWarSignData.getMinNumCountry()
	-- 将minCountryID放在国家ID数组的首位，并依次将其余的国家ID装入数组
	-- 例如minCountryID=3，则数组中元素依次为3，4，1，2
	for i=minCountryID,4 do
		table.insert(countryIDAry,i)
	end
	for i=1,minCountryID - 1 do
		table.insert(countryIDAry,i)
	end
	return countryIDAry
end

function createLayer( ... )
	-- body
	init()
	_layer = CCLayer:create()
	_layer:registerScriptTouchHandler(onTouchHandler,false,_touchPriority,true)
	_layer:setTouchEnabled(true)
	createUI()
	return _layer
end

function onTouchHandler( eventType,x,y )
	if not _campID then
		local ret = y > g_winSize.height * 0.30 and y < g_winSize.height * 0.83
		if ret then
			if (eventType == "began") then
				return onTouchBegan(x,y)
			elseif (eventType == "moved") then
				onTouchMoved(x,y)
			end
		end
		if (eventType == "ended") then
			onTouchEnded(x,y)
		end
	else
		if (eventType == "began") then
			return true
		end
	end
end
--[[
	@des 	: 
	@param 	: 
	@return : 
--]]
function phaseChangedCallBack( phase )
	if (phase == CountryWarDef.ASSIGN_ROOM) then
		createBtn()
		removeExplainLabel()
	elseif (phase == CountryWarDef.AUDITION_READY) then
		-- 特效
        local effect = XMLSprite:create("images/country_war/effect/jinrusaichang/jinrusaichang",60)
        effect:setAnchorPoint(ccp(0.5,0.5))
        effect:setPosition(ccpsprite(0.5,0.5,_signBtn))
        effect:setScale(0.85)
        _signBtn:addChild(effect)
	end
end

function signCallBack( tag,item )
	-- body
	local phase = CountryWarMainData.getCurStage()
	local countryId = _currCamp.campID
	local richInfo = {
	            linespace = 2, -- 行间距
	            alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	            lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
	            labelDefaultFont = g_sFontPangWa,
	            labelDefaultColor = ccc3( 0xff, 0xf6, 0x00),
	            labelDefaultSize = 24,
	            defaultType = "CCRenderLabel",
	            elements =
	            {
	                {
	                    type = "CCRenderLabel", 
	                    newLine = false,
	                    text = GetLocalizeStringBy("syx_1043"),
	                    renderType = 2,-- 1 描边， 2 投影
	                },
	                {
	                    type = "CCRenderLabel", 
	                    newLine = false,
	                    text = _campNameAry[countryId],
	                    renderType = 2,-- 1 描边， 2 投影
	                    color = _campNameColorAry[countryId],
	                },
	                {
	                    type = "CCRenderLabel", 
	                    newLine = true,
	                    text = GetLocalizeStringBy("syx_1044"),
	                    renderType = 2,-- 1 描边， 2 投影
	                },
	            }
	        }
	if phase == CountryWarDef.SIGNUP then
		if (_campID) then
			AnimationTip.showTip(GetLocalizeStringBy("syx_1049"))
		else
			require "script/ui/tip/RichAlertTip"
	   		RichAlertTip.showAlert(richInfo,function ( isConfirm )
		   		if not isConfirm then 
		   			return
		   		end
		   		CountryWarSignController.signForOneCountry(countryId)
		   	end,true)
		end
	elseif phase == CountryWarDef.ASSIGN_ROOM then
		AnimationTip.showTip(GetLocalizeStringBy("syx_1049"))
	elseif phase == CountryWarDef.AUDITION or phase == CountryWarDef.AUDITION_READY then
   		if  not _campID then
   			require "script/ui/tip/RichAlertTip"
	   		RichAlertTip.showAlert(richInfo,function ( isConfirm )
		   		if not isConfirm then 
		   			return
		   		end
		   		require "script/ui/countryWar/war/CountryWarPlaceLayer"
				CountryWarPlaceLayer.showLayer()
	   		end,true)
	   	else
   			require "script/ui/countryWar/war/CountryWarPlaceLayer"
			CountryWarPlaceLayer.showLayer()
   		end
	end
end
--[[
	@des 	: 报名成功后刷新界面
	@param 	: 
	@return : 
--]]
function refreshAfterSignUp( ... )
	-- body
	_campID = _currCamp.campID
	updatePercentage()
	playCampsFadeAnimation()
	createCampTitle("images/country_war/signup/my_camp_title.png")
	createBtn()
	removeExplainLabel()
end
--[[
	@des 	: 创建按钮
	@param 	: pStatus : 按钮的状态，1表示报名，2表示进入赛场
	@return : 
--]]
function createBtn()
	-- body
	if (_signBtn) then
		_signBtn:removeFromParentAndCleanup(true)
		_signBtn = nil
	end
	local isSignedUp = CountryWarSignData.isSignedUp()
	local currPhase = CountryWarMainData.getCurStage()
	local normalSprite = nil
	local selectSprite = nil
	local btnStr = nil
	if currPhase == CountryWarDef.SIGNUP and not isSignedUp then
		normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
	    selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
	    btnStr = GetLocalizeStringBy("key_8266")
	else
		normalSprite  = CCScale9Sprite:create("images/common/btn/anniu_blue_btn_n.png")
	    selectSprite  = CCScale9Sprite:create("images/common/btn/anniu_blue_btn_h.png")
	    btnStr = GetLocalizeStringBy("lcy_10049")
	end
    normalSprite:setContentSize(CCSizeMake(180,64))
    selectSprite:setContentSize(CCSizeMake(180,64))
	_signBtn = CCMenuItemSprite:create(normalSprite,selectSprite)
	_signBtn:setAnchorPoint(ccp(0.5,0.5))
	_signBtn:setPosition(g_winSize.width * 0.5,g_winSize.height * 0.15)
	_menuLayer:addChild(_signBtn)
	_signBtn:setScale(g_fElementScaleRatio)
	_signBtn:registerScriptTapHandler(signCallBack)
	local btnLabel = CCRenderLabel:create(btnStr , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    btnLabel:setColor(ccc3( 0xfe, 0xdb, 0x1c))
    btnLabel:setAnchorPoint(ccp(0.5,0.5))
	btnLabel:setPosition(ccp(_signBtn:getContentSize().width*0.5,_signBtn:getContentSize().height*0.5))
   	_signBtn:addChild(btnLabel)
   	if (currPhase == CountryWarDef.AUDITION_READY or currPhase == CountryWarDef.AUDITION) then
		-- 特效
        local effect = XMLSprite:create("images/country_war/effect/jinrusaichang/jinrusaichang",60)
        effect:setAnchorPoint(ccp(0.5,0.5))
        effect:setPosition(ccpsprite(0.5,0.5,_signBtn))
        effect:setScale(0.85)
        _signBtn:addChild(effect)
	end
end
--[[
	@des 	: 播放阵营消失动画
	@param 	: 
	@return : 
--]]
function playCampsFadeAnimation( ... )
	if not _campAry[2] then
		return 
	end
	for i=2,4 do
		local camp = _campAry[i]
		local fadeAct = CCFadeTo:create(0.5,0)
		fadeAct = CCEaseSineIn:create(fadeAct)
		local callBack = CCCallFunc:create(function ( ... )
			-- body
			_campAry[i]:removeFromParentAndCleanup(true)
			_campAry[i] = nil
		end)
		local sequence = CCSequence:createWithTwoActions(fadeAct,callBack)
		camp:runAction(sequence)
	end
	-- 移除箭头
	if _arrowContainer then
		_arrowContainer:removeFromParentAndCleanup(true)
		_arrowContainer = nil
	end
end

function removeExplainLabel( ... )
	-- body
	if _rewardExplainLabel then
		_rewardExplainLabel:removeFromParentAndCleanup(true)
		_rewardExplainLabel = nil
		_countdownTimer:setPosition(ccp(g_winSize.width * 0.5,g_winSize.height * 0.1))
	end
end

function createCampTitle( fileName )
	-- body
	if _chooseCampSp then
		_chooseCampSp:removeFromParentAndCleanup(true)
	end
	_chooseCampSp = CCSprite:create(fileName)
    _chooseCampSp:setAnchorPoint(ccp(0.5,0.5))
    _chooseCampSp:setPosition(ccp(g_winSize.width / 2,g_winSize.height * 0.86))
    _chooseCampSp:setScale(1.5 * g_fElementScaleRatio)
   	_layer:addChild(_chooseCampSp)
end
--[[
	@des 	: 切换选择的阵营时，同步显示各个阵营的信息
	@param 	: 
	@return : 
--]]
function updateCampInfo( ... )
	-- 更新阵营名称
	_currCampLabel:setString(_campNameAry[_currCamp.campID])
	_currCampLabel:setColor(_campNameColorAry[_currCamp.campID])
	-- 更新百分比
	updatePercentage()
end

function updatePercentage( ... )
	local percentage = CountryWarSignData.getCountrySignNumByID(_currCamp.campID)
	_currCampPercentage:setString(GetLocalizeStringBy("yr_5000",percentage))
	_currCampPercentage:setColor(_campNameColorAry[_currCamp.campID])
end

function onTouchBegan( x,y )
	-- body
	_lastX = x
	if _currCamp:numberOfRunningActions() > 0 then
		for i,v in ipairs(_campAry) do
			v:stopAllActions()
		end
	end
	return true
end
--[[
	@des 	: 获取当前页面默认选择的id
	@param 	: 
	@return : 
--]]
function getCurCampID( ... )
	return _currCamp.campID
end

function onTouchMoved( x,y )
	-- body
	if (_lastX == nil) then 
		return 
	end
	local offsetX = x - _lastX
	if (offsetX < 0) then
		_moveDiretion = kLeftDirection
	elseif (offsetX > 0) then
		_moveDiretion = kRightDirection
	else
		return
	end
	for i,camp in ipairs(_campAry) do
		if (_moveDiretion == kLeftDirection) then
			_tempAngleAry[i] = _tempAngleAry[i] - _radSpeed
		else
			_tempAngleAry[i] = _tempAngleAry[i] + _radSpeed
		end
		local nowPos = camp:getPosition()
		local nextPos = ccp(0,0)
		nextPos.x = _radiusX * math.cos(_tempAngleAry[i]) + _centerPoint.x
		nextPos.y = _radiusY * math.sin(_tempAngleAry[i]) + _centerPoint.y
		camp:setPosition(nextPos)

		local scaleSpace = _campScaleAry[1] - _campScaleAry[3]
		local ratio = (_campPosAry[3].y - nextPos.y) / (_campPosAry[3].y - _campPosAry[1].y)
	   	nextScale = _campScaleAry[3] + scaleSpace * ratio
	   	camp:setScale(nextScale)
	end
	if (_moveDiretion == kRightDirection) then
		if _campAry[1]:getPositionX() >= _campPosAry[1].x + _radiusX * 0.5 then
			updateCampArrayCopy()
			updateCampZOrder()
		end
	else
		if _campAry[1]:getPositionX() <= _campPosAry[2].x + _radiusX * 0.5 then
			updateCampArrayCopy()
			updateCampZOrder()
		end
	end
	_lastX = x
end

function onTouchEnded( x,y )
	if _currCamp:getPositionX() ~= _campPosAry[1].x then
		if (_moveDiretion == kRightDirection) then
			if _campAry[1]:getPositionX() <= _campPosAry[1].x + _radiusX * 0.5 and _currCamp:getPositionX() > _campPosAry[1].x then
				updateCampArrayCopy()
				updateCampZOrder()
			end
		else
			if _campAry[1]:getPositionX() >= _campPosAry[2].x + _radiusX * 0.5 and _currCamp:getPositionX() < _campPosAry[1].x then
				updateCampArrayCopy()
				updateCampZOrder()
			end
		end
	end
	moveToPosAfterTouchEnded()
end

function updateCampZOrder( ... )
	for i,camp in ipairs(_campAry) do
		_layer:reorderChild(camp,_campZOrderAry[i])
		camp:setOpacity(kOpacityAry[i])
	end
end

function updateCampArrayCopy( ... )
	if _moveDiretion == kLeftDirection then
		local camp = table.remove(_campAry)
		table.insert(_campAry,1,camp)
		local angle = table.remove(_tempAngleAry)
		table.insert(_tempAngleAry,1,angle)
	else
		local camp = table.remove(_campAry,1)
		table.insert(_campAry,camp)
		local angle = table.remove(_tempAngleAry,1)
		table.insert(_tempAngleAry,angle)
	end
	_currCamp = _campAry[1]
	updateCampInfo()
end
--[[
	@des 	: 触摸结束后将阵营移动到指定位置
	@param 	: 
	@return : 
--]]
function moveToPosAfterTouchEnded()
	local ratio = math.abs((_campPosAry[1].x - _currCamp:getPositionX()) / _radiusX)
	local moveTime = kMoveTime * ratio
	for i=1,4 do
		local moveAct = CCMoveTo:create(moveTime,_campPosAry[i])
		local scaleAct = CCScaleTo:create(moveTime,_campScaleAry[i])
		local spawn = CCSpawn:createWithTwoActions(moveAct,scaleAct)
		_campAry[i]:runAction(spawn)
	end
	_tempAngleAry = table.hcopy(kAngleAry,{})
end
--[[
	@des 	: 关闭
	@param 	: 
	@return : 
--]]
function closeCallFunc( ... )
    if _layer then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
		--移除对阶段变更的侦听
		CountryWarObserver.removeListener(phaseChangedCallBack)
	end
end