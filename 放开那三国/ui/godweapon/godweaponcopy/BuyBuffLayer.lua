-- Filename：	BuyBuffLayer.lua
-- Author：		LLP
-- Date：		2014-12-16
-- Purpose：		购买buff界面

require "script/model/utils/HeroUtil"
require "script/model/user/UserModel"
require "db/DB_Overcome_buff"
require "script/ui/godweapon/godweaponcopy/MakeUpLayer"
module("BuyBuffLayer", package.seeall)

local _bgLayer
local _buffInfo
local _clickTag
local _buyNum
local _copyInfo
local buffDbInfo

function init()
	_bgLayer = nil
	_buffInfo = nil
	_clickTag = 0
	_buyNum = 0
	_copyInfo = nil
	buffDbInfo = nil
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then

    else

	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -502, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end
--返回回调
function backAction(tag,itembtn)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
	-- 神兵副本
	-- local buffPass = GodWeaponCopyData.isBuffPass()
  	-- if( buffPass == true )then
		-- 如果战斗胜利 且 已经完成所有
		GodWeaponCopyMainLayer.nextSenceEffect()
		GodWeaponCopyMainLayer.refreshBottom()
	-- else
	-- 	GodWeaponCopyMainLayer.nextSenceEffect()
	-- end
end

--购买buff回调
function afterBuyBuff( ... )
	-- body
	local _buyNum = 0
	starNumCache = tonumber(_copyInfo["star_star"])
	starNumCost = tonumber(buffDbInfo.costStar)
	GodWeaponCopyData.setStarNum(starNumCache-starNumCost)
	GodWeaponCopyData.setBuffInfo(_clickTag,1)
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	for k,v in pairs(_copyInfo["va_pass"]["buffShow"])do
		if(tonumber(v.status)==1)then
			_buyNum = _buyNum+1
		end
	end
	_bgLayer:getChildByTag(10):getChildByTag(10):getChildByTag(10):setString(_copyInfo["star_star"])
	if(_buyNum==3)then
		backAction()
		return
	else
		local hasBuy = CCSprite:create("images/godweaponcopy/havebuy.png")
		_bgLayer:getChildByTag(_clickTag):getChildByTag(_clickTag):addChild(hasBuy)
		hasBuy:setAnchorPoint(ccp(0.5,0.5))
		hasBuy:setPosition(ccp(_bgLayer:getChildByTag(_clickTag):getChildByTag(_clickTag):getContentSize().width*0.5,_bgLayer:getChildByTag(_clickTag):getChildByTag(_clickTag):getContentSize().height*0.5))
	end

	local buffNum = tonumber(_copyInfo["va_pass"]["buffShow"][tonumber(_clickTag)]["buff"])
	local buffDbInfo = DB_Overcome_buff.getDataById(buffNum)
	local buffStyle = tonumber(buffDbInfo.color)

	local buffData = buffDbInfo.buff
	local buffArry = string.split(buffData, "|")
	local buffPercent = 0
	if(buffStyle==1)then
		buffPercent = tonumber(buffArry[3])/100
		AnimationTip.showTip(GetLocalizeStringBy("llp_147",buffPercent))
	elseif(buffStyle==2)then
		buffPercent = tonumber(buffArry[5])/100
		AnimationTip.showTip(GetLocalizeStringBy("llp_148",buffPercent))
	elseif(buffStyle==3)then
		buffPercent = tonumber(buffArry[3])/100
		AnimationTip.showTip(GetLocalizeStringBy("llp_149",buffPercent))
	end

	local starIcon = CCSprite:create("images/common/star_big.png")
	starIcon:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(starIcon,100,10)
	starIcon:setAnchorPoint(ccp(0.5,0.5))
	starIcon:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.3))

	local costStarLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_150",starNumCost),g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	starIcon:addChild(costStarLabel)
	costStarLabel:setAnchorPoint(ccp(0,0.5))
	costStarLabel:setPosition(ccp(starIcon:getContentSize().width,starIcon:getContentSize().height*0.5))
	starIcon:setContentSize(CCSizeMake(starIcon:getContentSize().width+costStarLabel:getContentSize().width,starIcon:getContentSize().height))

	local actionArr = CCArray:create()
		--actionArr:addObject(CCDelayTime:create(delayTime))
		--actionArr:addObject(CCFadeIn())
		-- actionArr:addObject(CCCallFuncN:create(function ( ... )
		-- 	descNode:setVisible(true)
		-- end))
		actionArr:addObject(CCEaseOut:create(CCMoveTo:create(2.0, ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.35)),2))
		--actionArr:addObject(CCDelayTime:create(0.2))
		actionArr:addObject(CCFadeOut:create(0.7))
		actionArr:addObject(CCCallFuncN:create(function()
			starIcon:removeFromParentAndCleanup(true)
			starIcon = nil
		end))
	starIcon:runAction(CCSequence:create(actionArr))
end

--放弃buff
function leaveBuffAction( ... )
	-- body
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
	args:addObject(CCInteger:create(999))
	local idArray = CCArray:create()
	args:addObject(idArray)
	--调用获取买buff命令
	GodWeaponCopyService.buyBuffInfo(backAction,args)
end

--买buff按钮回调
function addBuffAction( tag,itembtn )
	-- body
	_clickTag = tag
	local buffNum = tonumber(_copyInfo["va_pass"]["buffShow"][tonumber(tag)]["buff"])
	buffDbInfo = DB_Overcome_buff.getDataById(tonumber(buffNum))
	if(tonumber(_copyInfo["va_pass"]["buffShow"][tonumber(tag)]["status"])==0)then
		if(tonumber(_copyInfo["star_star"])>=tonumber(buffDbInfo.costStar))then
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/guanbi.mp3")

			local buffData = buffDbInfo.buff

			local buffArry = string.split(buffData, "|")
			local buffType = tonumber(buffArry[1])

			local clickTable = {}
			for k,v in pairs(_copyInfo["va_pass"]["heroInfo"])do
				table.insert(clickTable,tonumber(k))
			end
			local canClick = false
			if(buffType == 1)then
				--获取买buff命令参数
				local args = CCArray:create()
				args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
				args:addObject(CCInteger:create(tonumber(tag-1)))
				local idArray = CCArray:create()
				for k,v in pairs(clickTable) do
					idArray:addObject(CCInteger:create(v))
				end
				args:addObject(idArray)
				--调用获取买buff命令
				GodWeaponCopyService.buyBuffInfo(afterBuyBuff,args)
			else
				if(buffType==2)then
					for k,v in pairs(_copyInfo["va_pass"]["heroInfo"])do
						if(tonumber(v["currHp"])<tonumber(_copyInfo["percentBase"]) and tonumber(v["currHp"])~=0)then
							canClick = true
							break
						end
					end
					if(canClick==true)then
						_bgLayer:removeFromParentAndCleanup(true)
						_bgLayer = nil
						MakeUpLayer.showLayer(-2500,100,tonumber(tag))
					else
						AnimationTip.showTip(GetLocalizeStringBy("llp_151"))
					end
				elseif(buffType==3)then
						_bgLayer:removeFromParentAndCleanup(true)
						_bgLayer = nil
						MakeUpLayer.showLayer(-2500,100,tonumber(tag))
				elseif(buffType==4)then
					for k,v in pairs(_copyInfo["va_pass"]["heroInfo"])do
						if(tonumber(v["currHp"])==0)then
							canClick = true
							break
						end
					end
					if(canClick)then
						_bgLayer:removeFromParentAndCleanup(true)
						_bgLayer = nil
						MakeUpLayer.showLayer(-2500,100,tonumber(tag))
					else
						AnimationTip.showTip(GetLocalizeStringBy("llp_137"))
					end
				end
			end
		else
			AnimationTip.showTip(GetLocalizeStringBy("llp_141"))
		end
	else
		AnimationTip.showTip(GetLocalizeStringBy("llp_142"))
	end
end

function makeItem(pHardLv,pData)

	--点击menu
	local clickmenu = CCMenu:create()
	clickmenu:setTouchPriority(-2001)
	clickmenu:setAnchorPoint(ccp(0,0))
	clickmenu:setPosition(ccp(0,0))
	_bgLayer:addChild(clickmenu,1,pHardLv)
	--底板做成item方便点击test
	local clickItem = CCMenuItemImage:create("images/godweaponcopy/cardbg.png","images/godweaponcopy/cardbg.png")
	clickItem:setScale(g_fElementScaleRatio)
	clickmenu:addChild(clickItem,1,pHardLv)

	clickItem:registerScriptTapHandler(addBuffAction)

	--单条buff表里数据
	local buffData = DB_Overcome_buff.getDataById(tonumber(pData.buff))
	--恢复指定武将Label
	local addLabel = CCRenderLabel:create(buffData.name,g_sFontName,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	addLabel:setColor(ccc3(0xff,0xff,0xff))
	addLabel:setAnchorPoint(ccp(0.5,1))
	clickItem:addChild(addLabel)
	addLabel:setPosition(ccp(clickItem:getContentSize().width*0.5,clickItem:getContentSize().height*0.97))
	--何种buff|Sprite
	buffSprite = CCSprite:create("images/godweaponcopy/"..buffData.picture)
	if(pHardLv == 1)then
		clickItem:setAnchorPoint(ccp(0,0.5))
		clickItem:setPosition(ccp(0,_bgLayer:getContentSize().height*0.5))
	elseif(pHardLv==2)then
		clickItem:setAnchorPoint(ccp(0.5,0.5))
		clickItem:setPosition(ccp(_bgLayer:getContentSize().width*0.25*pHardLv,_bgLayer:getContentSize().height*0.5))
	elseif(pHardLv==3)then
		clickItem:setAnchorPoint(ccp(1,0.5))
		clickItem:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.5))
	end

	clickItem:addChild(buffSprite)
	buffSprite:setAnchorPoint(ccp(0.5,1))
	buffSprite:setPosition(ccp(addLabel:getPositionX(),clickItem:getContentSize().height*0.92))
	--星星图片
	local starSprite = CCSprite:create("images/common/star_big.png")
	clickItem:addChild(starSprite)
	starSprite:setAnchorPoint(ccp(0.5,0.5))
	starSprite:setPosition(ccp(clickItem:getContentSize().width*0.5,clickItem:getContentSize().height*0.92-buffSprite:getContentSize().height))
	--消耗星星数量
	local starNumLabel = CCRenderLabel:create(buffData.costStar,g_sFontName,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	starNumLabel:setColor(ccc3(0xff,0xff,0xff))
	starSprite:addChild(starNumLabel)
	starNumLabel:setAnchorPoint(ccp(0.5,0.5))
	starNumLabel:setPosition(ccp(starSprite:getContentSize().width*0.5,starSprite:getContentSize().height*0.5))

	local buffNum = tonumber(_copyInfo["va_pass"]["buffShow"][tonumber(pHardLv)]["buff"])
	local buffDbInfo = DB_Overcome_buff.getDataById(tonumber(buffNum))
	local buffData = buffDbInfo.tips
	local buffArry = string.split(buffData, "|")
	local colorType = buffDbInfo.color

	local colorNum = nil
	if(tonumber(colorType)==1)then
		colorNum = ccc3(0xd4,0x00,0x00)
	elseif(tonumber(colorType)==2)then
		colorNum = ccc3(0x00,0x6d,0x2f)
	elseif(tonumber(colorType)==3)then
		colorNum = ccc3(0x00,0x6d,0x2f)
	elseif(tonumber(colorType)==4)then
		colorNum = ccc3(0x00,0x2c,0x6d)
	end

	-- --指定英雄某项属性得到提高
	-- local str3Data = {
	-- 	{
 --            type = "CCLabelTTF",
 --            text = buffArry[1],
 --            color = ccc3(0xd4,0x00,0x00)
 --        },
 --        {
 --            type = "CCLabelTTF",
 --            text = buffArry[2],
 --            color = ccc3(0x00,0x6d,0x2f)
 --        },
 --        {
 --            type = "CCLabelTTF",
 --            text = buffArry[3],
 --            color = ccc3(0x00,0x2c,0x6d)
 --        }
	-- }

	-- local str4Data = {
	-- 	{
 --            type = "CCLabelTTF",
 --            text = buffArry[1],
 --            color = ccc3(0xd4,0x00,0x00)
 --        },
 --        {
 --            type = "CCLabelTTF",
 --            text = buffArry[2],
 --            color = ccc3(0x00,0x6d,0x2f)
 --        },
 --        {
 --            type = "CCLabelTTF",
 --            text = buffArry[3],
 --            color = ccc3(0x00,0x2c,0x6d)
 --        }
	-- }

	local richInfo = {}
    richInfo.width = clickItem:getContentSize().width*0.7
    richInfo.alignment = 1
    richInfo.labelDefaultFont = g_sFontName
    richInfo.labelDefaultSize = 18
    if(tonumber(table.count(buffArry))==3)then
	    richInfo.elements =
	    {
	        {
	            type = "CCLabelTTF",
	            text = buffArry[1],
	            color = ccc3(0x78,0x25,0x00)
	        },
	        {
	            type = "CCLabelTTF",
	            text = buffArry[2],
	            color = colorNum
        	},
	        {
	            type = "CCLabelTTF",
	            text = buffArry[3],
	            color = ccc3(0x78,0x25,0x00)
	        }
	    }
	else
		richInfo.elements =
	    {
	        {
	            type = "CCLabelTTF",
	            text = buffArry[1],
	            color = ccc3(0x78,0x25,0x00)
	        },
	        {
	            type = "CCLabelTTF",
	            text = buffArry[2],
	            color = colorNum
        	},
	        {
	            type = "CCLabelTTF",
	            text = buffArry[3],
	            color = ccc3(0x78,0x25,0x00)
	        },
	        {
	            type = "CCLabelTTF",
	            text = buffArry[4],
	            color = colorNum
	        },
	    }
	end

    require "script/libs/LuaCCLabel"
    local richLabel = LuaCCLabel.createRichLabel(richInfo)
    clickItem:addChild(richLabel)
    richLabel:setAnchorPoint(ccp(0.5,1))
    local buffData = buffDbInfo.buff

	local buffTypeArry = string.split(buffData, "|")
	local buffType = tonumber(buffTypeArry[1])
	if(buffType==4)then
		richLabel:setPosition(ccp(clickItem:getContentSize().width*0.5,clickItem:getContentSize().height*0.92-buffSprite:getContentSize().height-starSprite:getContentSize().height*0.5))
	else
    	richLabel:setPosition(ccp(clickItem:getContentSize().width*0.5,clickItem:getContentSize().height*0.92-buffSprite:getContentSize().height-starSprite:getContentSize().height))
    end
    --buff增加数量label
    local addPercentLabel = CCRenderLabel:create(buffDbInfo.precent_tips,g_sFontName,23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    addPercentLabel:setColor(ccc3(0x00,0xff,0x18))
    clickItem:addChild(addPercentLabel)
    addPercentLabel:setAnchorPoint(ccp(1,1))
    if(tonumber(table.count(buffArry))==3)then
    	addPercentLabel:setAnchorPoint(ccp(0.5,1))
    	addPercentLabel:setPosition(ccp(clickItem:getContentSize().width*0.5,richLabel:getPositionY()-richLabel:getContentSize().height))
    else
    	if(buffType==4)then
    		addPercentLabel:setAnchorPoint(ccp(0.5,1))
    		addPercentLabel:setPosition(ccp(clickItem:getContentSize().width*0.5,richLabel:getPositionY()-richLabel:getContentSize().height))
    	else
    		addPercentLabel:setPosition(ccp(clickItem:getContentSize().width*0.8,richLabel:getPositionY()-richLabel:getContentSize().height*0.5))
    	end
    end

    --判断买没买过
	-- for k,v in pairs(_copyInfo["va_pass"]["buffShow"])do
	-- 	if(tonumber(v.status)==1)then
	-- 		local hasBuy = CCSprite:create("images/common/0.png")
	-- 		_bgLayer:getChildByTag(pHardLv):getChildByTag(pHardLv):addChild(hasBuy)
	-- 		hasBuy:setAnchorPoint(ccp(1,1))
	-- 		hasBuy:setPosition(ccp(clickItem:getContentSize().width,clickItem:getContentSize().height))
	-- 		break
	-- 	end
	-- end
	if(tonumber(_copyInfo["va_pass"]["buffShow"][pHardLv]["status"])==1)then
		local hasBuy = CCSprite:create("images/godweaponcopy/havebuy.png")
		clickItem:addChild(hasBuy)
		hasBuy:setAnchorPoint(ccp(0.5,0.5))
		hasBuy:setPosition(ccp(clickItem:getContentSize().width*0.5,clickItem:getContentSize().height*0.5))
	end
end

function createBackGround()

	--选择对手Sprite
	local addbuffSprite = CCSprite:create("images/godweaponcopy/zi.png")
	addbuffSprite:setAnchorPoint(ccp(0.5,0.5))
	--选择对手bg
	local fullRect = CCRectMake(0,0,209,49)
	local insetRect = CCRectMake(86,14,45,20)
	local grayBg = CCScale9Sprite:create("images/godweaponcopy/choosegray.png",fullRect, insetRect)
	grayBg:setPreferredSize(CCSizeMake(addbuffSprite:getContentSize().width+100,addbuffSprite:getContentSize().height+50))
	grayBg:setAnchorPoint(ccp(0.5,1))
	grayBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.85))
	_bgLayer:addChild(grayBg)
	grayBg:addChild(addbuffSprite)
	grayBg:setScale(g_fElementScaleRatio)
	addbuffSprite:setPosition(ccp(grayBg:getContentSize().width*0.5,grayBg:getContentSize().height*0.5))

	--消耗星数购买属性加成
	local costLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_131"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	costLabel:setColor(ccc3(0xff,0xff,0xff))
	grayBg:addChild(costLabel)
	costLabel:setAnchorPoint(ccp(0.5,1))
	costLabel:setPosition(ccp(grayBg:getContentSize().width*0.5,-costLabel:getContentSize().height*0.5-5))
	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-2001)
    _bgLayer:addChild(menu,99,1)

    -- local ccBtnSure = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    -- ccBtnSure:setScale(g_fElementScaleRatio)
    -- ccBtnSure:setAnchorPoint(ccp(1,1))
    -- ccBtnSure:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height))
    -- ccBtnSure:registerScriptTapHandler(leaveBuffAction)
    -- menu:addChild(ccBtnSure)
    -- ccBtnSure:setVisible(false)
    for i=1,3 do
    	makeItem(i,_buffInfo[i])
    end
    --剩余星数label
    local lastStarNumLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_117"),g_sFontPangWa,23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    lastStarNumLabel:setScale(g_fElementScaleRatio)
    lastStarNumLabel:setColor(ccc3(0xff,0xff,0xff))
    _bgLayer:addChild(lastStarNumLabel,1,10)
    --星星图片
    local starSprite = CCSprite:create("images/common/star_big.png")
	lastStarNumLabel:addChild(starSprite,1,10)
	starSprite:setAnchorPoint(ccp(0,0.5))
	starSprite:setPosition(ccp(lastStarNumLabel:getContentSize().width+5,lastStarNumLabel:getContentSize().height*0.5))
	--消耗星星数量
	local starNumLabel = CCRenderLabel:create(_copyInfo["star_star"],g_sFontPangWa,23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	starNumLabel:setColor(ccc3(0xff,0xff,0xff))
	starSprite:addChild(starNumLabel,1,10)
	starNumLabel:setAnchorPoint(ccp(0,0.5))
	starNumLabel:setPosition(ccp(starSprite:getContentSize().width+5,starSprite:getContentSize().height*0.5))

	lastStarNumLabel:setAnchorPoint(ccp(0.5,0))
	lastStarNumLabel:setContentSize(CCSizeMake(lastStarNumLabel:getContentSize().width+10+starSprite:getContentSize().width+starNumLabel:getContentSize().width,starSprite:getContentSize().height))
	lastStarNumLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.2))

	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))

	local nextBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_145"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	nextBtn:setAnchorPoint(ccp(0.5, 0.5))
	nextBtn:setScale(g_fElementScaleRatio)
	nextBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.2-nextBtn:getContentSize().height*g_fElementScaleRatio))
	nextBtn:registerScriptTapHandler(nextAction)
	menu:addChild(nextBtn)
	_bgLayer:addChild(menu)
	menu:setTouchPriority(-2001)
end

function nextAction( pTag,pItem )
	-- body
	AlertTip.showAlert(GetLocalizeStringBy("llp_146"), sureUpgrade, true, nil, GetLocalizeStringBy("key_1985"),GetLocalizeStringBy("key_1202"))
end

function sureUpgrade(sureUp)
    print("sureUp",sureUp)
    if sureUp == true then
    	leaveBuffAction()
    end
end

function createLayer( ... )
	-- body
	GodWeaponCopyMainLayer.setMiddleItemVisible(true)

	_bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	_bgLayer:registerScriptHandler(onNodeEvent)

    createBackGround()

    return _bgLayer
end

function showLayer(pData)
	init()
	-- 隐藏中间

	_copyInfo = GodWeaponCopyData.getCopyInfo()
	_buffInfo = pData

	createLayer()
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,100,1500)
end
