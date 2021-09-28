-- FileName: LordWar4Layer.lua 
-- Author: licong 
-- Date: 14-8-4 
-- Purpose: 跨服赛 半决赛、决赛 (服内、跨服)


module("LordWar4Layer", package.seeall)

require "script/ui/lordWar/LordWarUtil"
require "script/ui/lordWar/LordWarData"
require "script/ui/lordWar/LordWarService"
require "script/utils/TimeUtil"

---------------------------------------------------- 常量 ------------------------------------------------------
local _timeDesStr = { GetLocalizeStringBy("lic_1187"),
					  GetLocalizeStringBy("lic_1188"),
					  GetLocalizeStringBy("lic_1189"),
					  GetLocalizeStringBy("lic_1190"),
					  GetLocalizeStringBy("lic_1191")
} -- 第一轮比赛倒计时:，第二轮比赛倒计时:，第三轮比赛倒计时:，第四轮比赛倒计时:，第五轮比赛倒计时:

-- 方向标识
local _lineLeft 	  						= 10011 -- 左方向线条
local _lineRight 	  						= 10012 -- 右方向线条

-- tag标识
local _heroIconLightTag 					= 101 -- 玩家头像 亮 tag
local _heroIconGrayTag 						= 102 -- 玩家头像 灰 tag
local _fightSpTag 							= 103 -- 战斗力背景 tag
local _fightLabelTag 						= 104 -- 战斗力Label tag
local _middleMenuTag    					= 105 -- 中间node按钮tag
local _button2Tag 							= 106 -- 2强战报和助威按钮tag

-- 4强线条
local _lightLineTag 						= 1001 -- 线条 亮 tag
local _grayLineTag 							= 1002 -- 线条 暗 tag
-- 冠军线条
local _upGrayLineTag 						= 1003 -- 上方向线条 暗 tag
local _downGrayLineTag  					= 1004 -- 下方向线条 暗 tag
local _upLightLineTag 						= 1005 -- 上方向线条 亮 tag
local _dowLightLineTag  					= 1006 -- 下方向线条 亮 tag
-- 胜负
local _winTag 								= 1007 -- 胜利tag
local _failTag 								= 1008 -- 失败tag
---------------------------------------------------- 变量 ------------------------------------------------------
local _bgLayer 								= nil
local _upUiNode 							= nil -- 上部分ui
local _middleUiNode 						= nil -- 中间ui
local _bottomUiNode 						= nil -- 底部ui
local _refreshCDLabel						= nil -- 更新冷却cd
local _timeBgNode 							= nil -- 阶段倒计时
local _curGroupMenuItem 					= nil -- 当前群组按钮
local _curGroupType 						= nil -- 当前群组标识
local _fourUiTab 							= nil -- 四强位置UI储存table
local _twoUiTab 							= nil -- 二强位置UI储存table
local _guanUi 								= nil -- 冠军UI
local _titleLabel							= nil -- 小标题
local _yiZhuWeiSp 							= nil -- 已助威图标
local _curShowType 							= nil -- 战况回顾显示类型: 跨服or服内
local _touchPriority                        = -600

--[[
	@des 	:初始化变量
--]]
function init( ... )
	_bgLayer 								= nil
	_upUiNode 								= nil
	_middleUiNode 							= nil
	_bottomUiNode 							= nil
	_refreshCDLabel							= nil
	_timeBgNode 							= nil
	_curGroupMenuItem 						= nil
	_curGroupType 							= nil
	_fourUiTab 								= {}
	_twoUiTab 								= {}
	_guanUi 								= nil
	_titleLabel								= nil 
	_yiZhuWeiSp 							= nil
	_curShowType 							= nil
end

------------------------------------------------------ 创建ui方法 -----------------------------------------------
--[[
	@des 	:创建按钮
	@param 	:p_normalFile:正常图片, p_selectFile:选中图片, p_str:按钮文字, p_norStrSize:正常字号, p_selStrSize:选中字号,
			 p_norStrColor:正常按钮字颜色, p_selStrColor:选中按钮字颜色
	@return : CCMenuItemSprite
--]]
function createButtonItem( p_normalFile, p_selectFile, p_arrowFile, p_str, p_norStrSize, p_selStrSize, p_norStrColor, p_selStrColor )
    local btnSize = CCSizeMake(238, 89)
	local normalSprite = CCScale9Sprite:create(p_normalFile)
    normalSprite:setContentSize(btnSize)
	local normal_font = CCLabelTTF:create(p_str , g_sFontPangWa, p_norStrSize)
    normal_font:setColor(p_norStrColor)
    normal_font:setAnchorPoint(ccp(0.5,0.5))
    normal_font:setPosition(ccpsprite(0.5,0.55,normalSprite))
   	normalSprite:addChild(normal_font)

    local selectSprite = CCScale9Sprite:create(p_selectFile)
    selectSprite:setContentSize(btnSize)
    local select_font = CCLabelTTF:create(p_str , g_sFontPangWa, p_selStrSize)
    select_font:setColor(p_selStrColor)
    select_font:setAnchorPoint(ccp(0.5,0.5))
    select_font:setPosition(ccpsprite(0.5,0.55,selectSprite))
   	selectSprite:addChild(select_font)
    local arrowSprite = CCSprite:create(p_arrowFile)
    selectSprite:addChild(arrowSprite)
    arrowSprite:setAnchorPoint(ccp(0.5, 0))
    arrowSprite:setPosition(ccpsprite(0.5, 0, selectSprite))
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
   	return item
end

--[[
	@des 	: 创建助威按钮item
	@param 	: 
	@return : CCMenuItemSprite
--]]
function createZhuMenuItem()
	local normalSprite = CCSprite:create("images/olympic/cheer_up/cheer_n.png")
    local selecteSprite = CCSprite:create("images/olympic/cheer_up/cheer_h.png")
    local disSprite = BTGraySprite:create("images/olympic/cheer_up/cheer_n.png")
	local zhuMenuItem = CCMenuItemSprite:create(normalSprite, selecteSprite, disSprite)
	return zhuMenuItem
end

--[[
	@des 	: 创建战报按钮item
	@param 	: 
	@return : CCMenuItemSprite
--]]
function createZhanMenuItem()
	local normalSprite = CCSprite:create("images/olympic/checkbutton/check_btn_h.png")
    local selecteSprite = CCSprite:create("images/olympic/checkbutton/check_btn_n.png")
    local disSprite = BTGraySprite:create("images/olympic/checkbutton/check_btn_h.png")
	local zhanMenuItem = CCMenuItemSprite:create(normalSprite, selecteSprite, disSprite)
	return zhanMenuItem
end

--[[
	@des 	: 创建四强头像框
	@param 	: p_lineDirection:横线方向 _lineLeft左 _lineRight右, 
			  p_userData:玩家数据,
	@return : CCSprite
--]]
function create4HeadBg( p_lineDirection, p_userData )
	local headBg = CCSprite:create("images/lord_war/4hero_bg.png")

	-- 背景特效
	local bgAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/txkfaguang/txkfaguang"), -1,CCString:create(""))
    bgAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    bgAnimSprite:setPosition(ccpsprite(0.5,0.5,headBg))
    headBg:addChild(bgAnimSprite,-2)

	-- 4强文字
	local tipFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1198"),g_sFontPangWa,27)
	tipFont:setColor(ccc3(0xd2,0xd2,0xcf))
	tipFont:setAnchorPoint(ccp(0.5,0.5))
	tipFont:setPosition(ccpsprite(0.5,0.5,headBg))
	headBg:addChild(tipFont)

	-- 线条 暗
	local grayLine = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
	grayLine:setScaleX(1.8)
	headBg:addChild(grayLine,-1,_grayLineTag)
	-- 线条 亮
	local lightLine = CCSprite:create("images/olympic/line/horizontalLine_light.png")
	lightLine:setScaleX(1.8)
	headBg:addChild(lightLine,-1,_lightLineTag)
	
	-- 线条方向
	if(p_lineDirection == _lineLeft)then
		-- 左
		-- 暗
		grayLine:setAnchorPoint(ccp(1,0.5))
		grayLine:setPosition(ccp(5,headBg:getContentSize().height*0.5))
		-- 亮
		lightLine:setAnchorPoint(ccp(1,0.5))
		lightLine:setPosition(ccp(5,headBg:getContentSize().height*0.5))
		lightLine:setVisible(false)
	elseif(p_lineDirection == _lineRight)then
		-- 右
		-- 暗
		grayLine:setAnchorPoint(ccp(0,0.5))
		grayLine:setPosition(ccp(headBg:getContentSize().width-5,headBg:getContentSize().height*0.5))
		-- 亮
		lightLine:setAnchorPoint(ccp(0,0.5))
		lightLine:setPosition(ccp(headBg:getContentSize().width-5,headBg:getContentSize().height*0.5))
		lightLine:setVisible(false)
	else
		print("erro p_lineDirection in function create4HeadBg")
	end	

	-- 有数据创建
	if( p_userData and not table.isEmpty(p_userData) )then
		-- 玩家头像
		local lightHeadIcon = HeroUtil.getHeroIconByHTID(p_userData.htid, p_userData.dress["1"],nil, p_userData.vip)
		lightHeadIcon:setAnchorPoint(ccp(0.5,0.5))
		lightHeadIcon:setPosition(ccpsprite(0.5,0.55,headBg))
		headBg:addChild(lightHeadIcon,1,_heroIconLightTag)
		-- 灰头像
		local grayHeadIcon = HeroUtil.getHeroGrayIconByHTID(p_userData.htid, p_userData.dress["1"],nil, p_userData.vip)
		grayHeadIcon:setAnchorPoint(ccp(0.5,0.5))
		grayHeadIcon:setPosition(ccpsprite(0.5,0.55,headBg))
		headBg:addChild(grayHeadIcon,1,_heroIconGrayTag)
		grayHeadIcon:setVisible(false)
		-- 战斗力
		local fightSp = CCSprite:create("images/lord_war/fight_bg.png")
		fightSp:setAnchorPoint(ccp(0.5,0.5))
		fightSp:setPosition(ccp(headBg:getContentSize().width*0.5,5))
		headBg:addChild(fightSp,1,_fightSpTag)
		-- 战斗力数值
		local fightLabel = CCRenderLabel:create( tonumber(p_userData.fightForce), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightLabel:setColor(ccc3(0xff,0x00,0x00))
	    fightLabel:setAnchorPoint(ccp(0,0.5))
	    fightLabel:setPosition(ccp(38,fightSp:getContentSize().height*0.5))
	   	fightSp:addChild(fightLabel,1,_fightLabelTag)
	   	-- 玩家名字
	   	local userNameLabel = CCRenderLabel:create( p_userData.uname, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    userNameLabel:setColor(ccc3(0xff,0xff,0xff))
	    userNameLabel:setAnchorPoint(ccp(0.5,0.5))
	    userNameLabel:setPosition(ccp(headBg:getContentSize().width*0.5,-18))
	   	headBg:addChild(userNameLabel)

	   	-- 是否在服内
	   	local isIn = LordWarData.isInInner(_curShowType)
	   	if(isIn ~= true)then
		   	-- 服务器名字
		   	local serviceNameLabel = CCRenderLabel:create( "(" .. p_userData.serverName  .. ")", g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    serviceNameLabel:setColor(ccc3(0xff,0xff,0xff))
		    serviceNameLabel:setAnchorPoint(ccp(0.5,0.5))
		    serviceNameLabel:setPosition(ccp(headBg:getContentSize().width*0.5,-40))
		   	headBg:addChild(serviceNameLabel)
		end

	   	-- 玩家状态
	   	print("p_userData.userStatus",p_userData.userStatus)
	   	print_t(p_userData)
	   	if(p_userData.userStatus == LordWarData.kUserWin)then
	   		-- 晋级 亮线
	   		lightLine:setVisible(true)
	   		grayLine:setVisible(false)
	   		-- 胜
	   		local winSp = CCSprite:create("images/olympic/win.png")
			winSp:setAnchorPoint(ccp(0.5,0.5))
			winSp:setPosition(ccp(12,80))
			lightHeadIcon:addChild(winSp,1,_winTag)
	   	elseif(p_userData.userStatus == LordWarData.kUserFail)then
	   		-- 淘汰 灰头像
	   		lightHeadIcon:setVisible(false)
			grayHeadIcon:setVisible(true)
			-- vip光圈删除
			if(tolua.cast(headBg:getChildByTag(_heroIconGrayTag):getChildByTag(88888),"CCLayerSprite") ~= nil)then
				print("88888 ..")
				grayHeadIcon:getChildByTag(88888):removeFromParentAndCleanup(true)
			end
			-- 负
			local lostSp = CCSprite:create("images/olympic/lost.png")
			lostSp:setAnchorPoint(ccp(0.5,0.5))
			lostSp:setPosition(ccp(12,80))
			grayHeadIcon:addChild(lostSp,1,_failTag)
	   	else
	   		-- 初始
	   	end
	end

	return headBg
end

--[[
	@des 	: 创建冠军头像框
	@param 	: p_userData:玩家数据
	@return : CCSprite
--]]
function createFirstHeadBg( p_userData )
	local headBg = CCSprite:create("images/lord_war/guan_bg.png")

	-- 背景特效
	local bgAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/ztxkfaguang/ztxkfaguang"), -1,CCString:create(""))
    bgAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    bgAnimSprite:setPosition(ccpsprite(0.5,0.5,headBg))
    headBg:addChild(bgAnimSprite,-2)

	-- 皇冠
	local imagesFile = nil
	local txImagesFile = nil
	if(_curGroupType == LordWarData.kWinLordType)then
		imagesFile = "images/lord_war/worship/hat_2.png"
		txImagesFile = "images/base/effect/jinpai/jinpai"
	elseif(_curGroupType == LordWarData.kLoseLordType)then
		imagesFile = "images/lord_war/worship/hat_3.png"
		txImagesFile = "images/base/effect/tongpai/tongpai"
	else
		print("erro imagesFile in createFirstHeadBg")
	end
	local guanSp = CCSprite:create(imagesFile)
	guanSp:setAnchorPoint(ccp(0.5,0))
	guanSp:setPosition(ccp(headBg:getContentSize().width*0.5,headBg:getContentSize().height-10))
	headBg:addChild(guanSp,2)
	-- 特效
	local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create(txImagesFile), -1,CCString:create(""))
    animSprite:setPosition(ccpsprite(0.5,0.5,guanSp))
    guanSp:addChild(animSprite)
	-- 冠军文字
	local tipFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1199"),g_sFontPangWa,27)
	tipFont:setColor(ccc3(0xd2,0xd2,0xcf))
	tipFont:setAnchorPoint(ccp(0.5,0.5))
	tipFont:setPosition(ccpsprite(0.5,0.5,headBg))
	headBg:addChild(tipFont)

	-- 上方线条 暗
	local upGrayLine = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
	upGrayLine:setAnchorPoint(ccp(1,0.5))
	upGrayLine:setScaleX(1.7)
	upGrayLine:setRotation(90)
	upGrayLine:setPosition(ccp(headBg:getContentSize().width*0.5,headBg:getContentSize().height-15))
	headBg:addChild(upGrayLine,-1,_upGrayLineTag)
	-- 上方线条 亮
	local upLightLine = CCSprite:create("images/olympic/line/horizontalLine_light.png")
	upLightLine:setAnchorPoint(ccp(1,0.5))
	upLightLine:setScaleX(1.7)
	upLightLine:setRotation(90)
	upLightLine:setPosition(ccp(headBg:getContentSize().width*0.5,headBg:getContentSize().height-15))
	headBg:addChild(upLightLine,-1,_upLightLineTag)
	upLightLine:setVisible(false)
	
	-- 下方线条 暗
	local downGrayLine = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
	downGrayLine:setAnchorPoint(ccp(1,0.5))
	downGrayLine:setScaleX(1.7)
	downGrayLine:setRotation(270)
	downGrayLine:setPosition(ccp(headBg:getContentSize().width*0.5,15))
	headBg:addChild(downGrayLine,-1,_downGrayLineTag)
	-- 下方线条 亮
	local downLightLine = CCSprite:create("images/olympic/line/horizontalLine_light.png")
	downLightLine:setAnchorPoint(ccp(1,0.5))
	downLightLine:setScaleX(1.7)
	downLightLine:setRotation(270)
	downLightLine:setPosition(ccp(headBg:getContentSize().width*0.5,15))
	headBg:addChild(downLightLine,-1,_dowLightLineTag)
	downLightLine:setVisible(false)
	
	-- 有数据创建
	if( p_userData and not table.isEmpty(p_userData) )then
		-- 玩家头像
		local headIcon = HeroUtil.getHeroIconByHTID(p_userData.htid, p_userData.dress["1"],nil, p_userData.vip)
		headIcon:setAnchorPoint(ccp(0.5,0.5))
		headIcon:setPosition(ccpsprite(0.5,0.5,headBg))
		headBg:addChild(headIcon,1,_heroIconLightTag)
		-- 战斗力
		local fightSp = CCSprite:create("images/lord_war/fight_bg.png")
		fightSp:setAnchorPoint(ccp(0.5,0.5))
		fightSp:setPosition(ccp(headBg:getContentSize().width*0.5,5))
		headBg:addChild(fightSp,1,_fightSpTag)
		-- 战斗力数值
		local fightLabel = CCRenderLabel:create( tonumber(p_userData.fightForce), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightLabel:setColor(ccc3(0xff,0x00,0x00))
	    fightLabel:setAnchorPoint(ccp(0,0.5))
	    fightLabel:setPosition(ccp(38,fightSp:getContentSize().height*0.5))
	   	fightSp:addChild(fightLabel,1,_fightLabelTag)
	   	-- 玩家名字
	   	local userNameLabel = CCRenderLabel:create( p_userData.uname , g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    userNameLabel:setColor(ccc3(0xff,0xff,0xff))
	    userNameLabel:setAnchorPoint(ccp(0.5,0.5))
	    userNameLabel:setPosition(ccp(headBg:getContentSize().width*0.5,-18))
	   	headBg:addChild(userNameLabel)
	   	-- 是否在服内
	   	local isIn = LordWarData.isInInner(_curShowType)
	   	if(isIn ~= true)then
		   	-- 服务器名字
		   	local serviceNameLabel = CCRenderLabel:create( "(" .. p_userData.serverName  .. ")", g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    serviceNameLabel:setColor(ccc3(0xff,0xff,0xff))
		    serviceNameLabel:setAnchorPoint(ccp(0.5,0.5))
		    serviceNameLabel:setPosition(ccp(headBg:getContentSize().width*0.5,-40))
		   	headBg:addChild(serviceNameLabel)
		end
	end

	return headBg
end

------------------------------------------------------ 按钮事件 -------------------------------------------------
--[[
	@des 	:返回按钮回调
--]]
function backMenuItemCallBack(tag, itemBtn)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	require "script/ui/lordWar/LordWarMainLayer"
	LordWarMainLayer.show()
end

--[[
	@des: 活动说明按钮回调
--]]
function explainButtonCallBack( tag, itemBtn)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	
	require "script/ui/lordWar/LordWarExplainDialog"
	LordWarExplainDialog.show(-454)
end

--[[
	@des 	:我的信息按钮回调
--]]
function myInfoMenuItemCallBack( tag, itemBtn)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/lordWar/MyInfoLayer"
	MyInfoLayer.show(-454,500)
end

--[[
	@des 	:战况回顾按钮回调
--]]
function lookBackMenuItemCallBack( tag, itemBtn)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/lordWar/LordWar32Layer"
	if(_curShowType)then
		LordWar32Layer.show(_curShowType)
	else
		if(TimeUtil.getSvrTimeByOffset(0) >= LordWarData.getRoundStartTime( LordWarData.kInner32To16 )  and TimeUtil.getSvrTimeByOffset(0) <= LordWarData.getRoundEndTime( LordWarData.kInner2To1 ) ) then
			LordWar32Layer.show(LordWarData.kInnerType)
		elseif(TimeUtil.getSvrTimeByOffset(0) >= LordWarData.getRoundStartTime( LordWarData.kCross32To16 )  and TimeUtil.getSvrTimeByOffset(0) <= LordWarData.getRoundEndTime( LordWarData.kCross2To1 ) ) then
			LordWar32Layer.show(LordWarData.kCrossType)
		else
			-- 默认回顾到服内四强 
			LordWar32Layer.show(LordWarData.kInnerType)
		end
	end
end

--[[
	@des 	:助威按钮回调
--]]
function zhuMenuItemCallBack( tag, itemBtn)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("zhu teg ==>",tag)

	local argTab = {}
	argTab.group = _curGroupType
	argTab.rank  = LordWarData.kRank4
	argTab.position_1 = tag
	argTab.position_2 = tag + 1
	argTab.refreshCallback = afterZhuMenuCallBack
	if(tag == _button2Tag)then
		print("2强助威按钮")
		argTab.rank  = LordWarData.kRank2
		argTab.position_1 = 1
		argTab.position_2 = 2
	end

	require "script/ui/lordWar/LordWarCheerLayer"
	LordWarCheerLayer.show(argTab)
end

--[[
	@des 	:助威后回调
	@param 	:p_rank:当前排名，p_uiPos助威人的uiPos
--]]
function afterZhuMenuCallBack( p_rank, p_uiPos )
	print("p_rank",p_rank,"p_uiPos",p_uiPos)
	local headBg = nil
	if(LordWarData.kRank4 == p_rank)then
		headBg = tolua.cast(_fourUiTab[p_uiPos],"CCSprite")
	elseif(LordWarData.kRank2 == p_rank)then
		headBg = tolua.cast(_twoUiTab[p_uiPos],"CCSprite")
	else
	end
	if(headBg ~= nil)then
		local headIcon = headBg:getChildByTag(_heroIconLightTag)
		_yiZhuWeiSp = CCSprite:create("images/lord_war/yizhuwei.png")
		_yiZhuWeiSp:setAnchorPoint(ccp(0,0))
		_yiZhuWeiSp:setPosition(ccp(45,65))
		headIcon:addChild(_yiZhuWeiSp,10)
	end
end

--[[
	@des 	:战报按钮回调 (为了区分助威和战报按钮tag值,战报按钮tag = 助威按钮tag * 10)
--]]
function zhanMenuItemCallBack( tag, itemBtn)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("zhan teg ==>",tag)
	local roundRank = LordWarData.kRank4
	local posData1 = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank4, tag/10 )
	local posData2 = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank4, (tag/10)+1 )

	if(tag == _button2Tag*10)then
		print("2强战报按钮")
		roundRank = LordWarData.kRank2
		posData1 = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank2, 1 )
		posData2 = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank2, 2 )
	end
	if(posData1 ~= nil and posData2 ~= nil)then
		local nextCallBackFun = function ( retData )
			require "script/ui/lordWar/warReport/WarReportLayer"
			-- 是否在服内
	   		local isIn = LordWarData.isInInner(_curShowType)
            local fight_info = {}
            fight_info.hero_1 = posData1
            fight_info.hero_2 = posData2
           	WarReportLayer.showLayer(retData, _touchPriority - 30, 888,isIn, nil, nil, nil, nil, fight_info)
		end
		local teamType = LordWarData.getServerTeamType(_curGroupType)
		local round = LordWarData.getRoundByRoundRank(roundRank,_curShowType)
		LordWarService.getPromotionBtl( round, teamType, posData1.serverId, posData1.uid, posData2.serverId, posData2.uid, nextCallBackFun)
	elseif(posData1 == nil and posData2 == nil)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1206"))
	else
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1208"))
	end
end

--[[
	@des 	:傲视群雄组按钮回调、初出茅庐组按钮回调
--]]
function groupMenuItemCallBack( tag, itemBtn)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	itemBtn:selected()
	if(itemBtn ~= _curGroupMenuItem) then
		if(_curGroupMenuItem)then
			_curGroupMenuItem:unselected()
		end
		_curGroupMenuItem = itemBtn
		_curGroupType = tag
		-- 切换中间ui
		createMiddleNode()
	end
end
------------------------------------------------------ 刷新UI方法 -------------------------------------------------
--[[
	@des 	:刷新ui
--]]
function refreshUICallBack()
	if(tolua.cast(_bgLayer,"CCLayer") ~= nil)then
		-- 四强
	 	for four_index=1,4 do
	 		local fourUserData = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank4, four_index )
	 		if(fourUserData ~= nil)then
	 			local headBg = _fourUiTab[four_index]

	 			-- 已助威
				local curSupportData = LordWarData.getCheerInfo()
				print("curSupport_serverid ==>",curSupportData.support_serverid,"curSupport_uid ==>",curSupportData.support_uid)
				if(tonumber(curSupportData.support_serverid) == tonumber(fourUserData.serverId) and tonumber(curSupportData.support_uid) == tonumber(fourUserData.uid) )then
					local headBg = tolua.cast(_fourUiTab[four_index],"CCSprite")
					if(tolua.cast(_yiZhuWeiSp,"CCSprite") ~= nil)then
						_yiZhuWeiSp:removeFromParentAndCleanup(true)
						_yiZhuWeiSp = nil
					end
					_yiZhuWeiSp = CCSprite:create("images/lord_war/yizhuwei.png")
					_yiZhuWeiSp:setAnchorPoint(ccp(0,0))
					_yiZhuWeiSp:setPosition(ccp(45,65))
					headBg:getChildByTag(_heroIconLightTag):addChild(_yiZhuWeiSp,10)
				end
				
	 			if(fourUserData.userStatus == LordWarData.kUserWin)then
	 				-- 晋级
	 				-- 显示亮线
	 				headBg:getChildByTag(_grayLineTag):setVisible(false)
	 				headBg:getChildByTag(_lightLineTag):setVisible(true)
	 				
	 				-- 当前阶段
					local curRound = LordWarData.getCurRound()
	 				if( curRound == LordWarData.kInner4To2 or curRound == LordWarData.kCross4To2)then
	 					if LordWarData.isShowWinEffect() == true then
	 						-- 胜利特效
	 						print("4强胜利特效")
			 				LordWarUtil.playWinEffect(headBg)
						end
					end

	 				-- 胜
	 				if(tolua.cast(headBg:getChildByTag(_heroIconLightTag):getChildByTag(_winTag),"CCSprite") ~= nil)then
	 					headBg:getChildByTag(_heroIconLightTag):getChildByTag(_winTag):removeFromParentAndCleanup(true)
					end
			   		local winSp = CCSprite:create("images/olympic/win.png")
					winSp:setAnchorPoint(ccp(0.5,0.5))
					winSp:setPosition(ccp(12,80))
					headBg:getChildByTag(_heroIconLightTag):addChild(winSp,1,_winTag)

	 				-- 储存2强ui
	 				if(four_index <= 2)then
	 					_twoUiTab[1] = headBg
	 				else
	 					_twoUiTab[2] = headBg
	 				end
	 			elseif(fourUserData.userStatus == LordWarData.kUserFail)then
	 				-- 淘汰
	 				-- 头像变灰
	 				headBg:getChildByTag(_heroIconLightTag):setVisible(false)
	 				headBg:getChildByTag(_heroIconGrayTag):setVisible(true)
	 				-- vip光圈删除
	 				if(tolua.cast(headBg:getChildByTag(_heroIconGrayTag):getChildByTag(88888),"CCLayerSprite") ~= nil)then
	 					headBg:getChildByTag(_heroIconGrayTag):getChildByTag(88888):removeFromParentAndCleanup(true)
					end
	 				-- 负
	 				if(tolua.cast(headBg:getChildByTag(_heroIconGrayTag):getChildByTag(_failTag),"CCSprite") ~= nil)then
	 					headBg:getChildByTag(_heroIconGrayTag):getChildByTag(_failTag):removeFromParentAndCleanup(true)
					end
			   		local lostSp = CCSprite:create("images/olympic/lost.png")
					lostSp:setAnchorPoint(ccp(0.5,0.5))
					lostSp:setPosition(ccp(12,80))
					headBg:getChildByTag(_heroIconGrayTag):addChild(lostSp,1,_failTag)
	 			else

	 			end
	 		end
	 	end

		-- 冠军
		local guanData = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank1, 1 )
		if( guanData ~= nil)then
			if(_guanUi ~= nil)then
				_guanUi:removeFromParentAndCleanup(true)
				_guanUi = nil
			end
			_guanUi = createFirstHeadBg( guanData )
			_guanUi:setAnchorPoint(ccp(0.5,0.5))
			_guanUi:setPosition(ccpsprite(0.5,0.5,_middleUiNode))
			_middleUiNode:addChild(_guanUi)

			-- 二强
		 	for two_index=1,2 do
	 			local twoUserData = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank2, two_index )
	 			if(twoUserData ~= nil)then
		 			if(twoUserData.userStatus == LordWarData.kUserWin)then
						if(two_index == 1)then
							-- 上边线亮
							_guanUi:getChildByTag(_upGrayLineTag):setVisible(false)
							_guanUi:getChildByTag(_upLightLineTag):setVisible(true)
						else
							-- 下边线亮
							_guanUi:getChildByTag(_downGrayLineTag):setVisible(false)
							_guanUi:getChildByTag(_dowLightLineTag):setVisible(true)
						end	
					end
				end
			end
			
			-- 胜利特效
			-- 当前阶段
			local curRound = LordWarData.getCurRound()
			if( curRound == LordWarData.kInner2To1 or curRound == LordWarData.kCross2To1) then 
				if LordWarData.isShowWinEffect() == true then
					-- 胜利特效
					print("冠军强胜利特效")
	 				LordWarUtil.playWinEffect(_guanUi)
				end
			end
		end
	end
end

--[[
	@des 	:刷新助威和战报按钮状态
--]]
function refreshBtnCallBack()
	if(tolua.cast(_middleUiNode,"CCNode") ~= nil)then
		-- 当前阶段
		local curRound = nil
		-- 当前阶段状态
		local curRoundStatus = nil
		if _curShowType == LordWarData.kInnerType then
	        curRound = LordWarData.kInner2To1
	        curRoundStatus = LordWarData.kRoundEnd
	    elseif _curShowType == LordWarData.kCrossType then
	        curRound = LordWarData.kCross2To1
	        curRoundStatus = LordWarData.kRoundEnd
	    else
	    	curRound = LordWarData.getCurRound()
			curRoundStatus = LordWarData.getCurRoundStatus()
	    end
		-- 当前阶段排名
		local curRank = LordWarData.getRoundRank(curRound,curRoundStatus)
		print("curRank == >",curRank)
		print("curRoundStatus == >",curRoundStatus)
		-- 4强 助威 战报按钮
		local zhuMenuItem1 = tolua.cast(_middleUiNode:getChildByTag(_middleMenuTag):getChildByTag(1), "CCMenuItemSprite")
		local zhuMenuItem2 = tolua.cast(_middleUiNode:getChildByTag(_middleMenuTag):getChildByTag(3), "CCMenuItemSprite")
		local zhanMenuItem1 = tolua.cast(_middleUiNode:getChildByTag(_middleMenuTag):getChildByTag(10), "CCMenuItemSprite")
		local zhanMenuItem2 = tolua.cast(_middleUiNode:getChildByTag(_middleMenuTag):getChildByTag(30), "CCMenuItemSprite")
		if(curRank > LordWarData.kRank8)then
			-- 不可助威
			-- 1
			zhuMenuItem1:setVisible(true)
			zhuMenuItem1:setEnabled(false)
			zhanMenuItem1:setVisible(false)
			-- 3
			zhuMenuItem2:setVisible(true)
			zhuMenuItem2:setEnabled(false)
			zhanMenuItem2:setVisible(false)
		elseif(curRank == LordWarData.kRank8)then	
			if(curRoundStatus >= LordWarData.kRoundFighted)then
				print("curRoundStatus kRank8",curRoundStatus)
				-- 可助威
				-- 1
				zhuMenuItem1:setVisible(true)
				zhuMenuItem1:setEnabled(true)
				zhanMenuItem1:setVisible(false)
				-- 3
				zhuMenuItem2:setVisible(true)
				zhuMenuItem2:setEnabled(true)
				zhanMenuItem2:setVisible(false)
			else
				-- 不可助威
				-- 1
				zhuMenuItem1:setVisible(true)
				zhuMenuItem1:setEnabled(false)
				zhanMenuItem1:setVisible(false)
				-- 3
				zhuMenuItem2:setVisible(true)
				zhuMenuItem2:setEnabled(false)
				zhanMenuItem2:setVisible(false)
			end
		else
			-- 可查看战报
			-- 1
			zhuMenuItem1:setVisible(false)
			zhanMenuItem1:setVisible(true)
			zhanMenuItem1:setEnabled(true)
			-- 3
			zhuMenuItem2:setVisible(false)
			zhanMenuItem2:setVisible(true)
			zhanMenuItem2:setEnabled(true)
		end

		-- 2强 助威 战报按钮
		local zhuMenuItem = tolua.cast(_middleUiNode:getChildByTag(_middleMenuTag):getChildByTag(_button2Tag), "CCMenuItemSprite")
		local zhanMenuItem = tolua.cast(_middleUiNode:getChildByTag(_middleMenuTag):getChildByTag(_button2Tag*10), "CCMenuItemSprite")
		if(curRank > LordWarData.kRank4)then
			-- 不可助威
			-- 1
			zhuMenuItem:setVisible(true)
			zhuMenuItem:setEnabled(false)
			zhanMenuItem:setVisible(false)
		elseif(curRank == LordWarData.kRank4)then
			if(curRoundStatus  >= LordWarData.kRoundFighted)then
				print("curRoundStatus kRank4",curRoundStatus)
				-- 可助威
				if(tolua.cast(_yiZhuWeiSp,"CCSprite") ~= nil)then
					_yiZhuWeiSp:removeFromParentAndCleanup(true)
					_yiZhuWeiSp = nil
				end
				-- 1
				zhuMenuItem:setVisible(true)
				zhuMenuItem:setEnabled(true)
				zhanMenuItem:setVisible(false)
			else
				-- 不可助威
				-- 1
				zhuMenuItem:setVisible(true)
				zhuMenuItem:setEnabled(false)
				zhanMenuItem:setVisible(false)
			end
		else
			-- 可查看战报
			-- 1
			zhuMenuItem:setVisible(false)
			zhanMenuItem:setVisible(true)
			zhanMenuItem:setEnabled(true)
		end
	end
end

--[[
	@des 	:刷新全部方法
--]]
function refreshAllCallback( p_round, p_status, p_event )
    if p_event ~= "roundChange" then
        return
    end
    print("LordWar4Layer.refreshAllCallback", p_round, p_status, p_event)
	if(tolua.cast(_bgLayer,"CCLayer") == nil)then
        print("不在当前界面，不刷新")
        return
    end
    if _curShowType ~= nil then
        return
    end
    if p_status == LordWarData.kRoundFighted then
        LordWarData.setShowWinEffect(true)
        LordWarService.getPromotionInfo(function ( ... )
            if(tolua.cast(_bgLayer,"CCLayer") ~= nil)then
                -- ui
                refreshUICallBack()
                LordWarData.setShowWinEffect(false)
                -- 助威和战报按钮
                refreshBtnCallBack()
                if(p_round == LordWarData.kInner2To1 or p_round == LordWarData.kCross2To1) and p_status == LordWarData.kRoundFighted then
                    local actions = CCArray:create()
                    actions:addObject(CCDelayTime:create(3))
                    actions:addObject(CCCallFunc:create(LordWarMainLayer.show))
                    _bgLayer:runAction(CCSequence:create(actions))
                end
            end
        end)
    else
        -- 助威和战报按钮
        refreshBtnCallBack()
    end
end

----------------------------------------------------- 创建UI -----------------------------------------------------
--[[
	@des 	:创建上部分ui
--]]
function createUpNode( ... )
	_upUiNode = CCNode:create()
	_upUiNode:setContentSize(CCSizeMake(640,256))
	_upUiNode:setAnchorPoint(ccp(0.5,1))
	_upUiNode:setPosition(ccpsprite(0.5, 1, _bgLayer))
	_bgLayer:addChild(_upUiNode,2)
	-- 适配
	_upUiNode:setScale(g_fScaleX)

	-- 上边分割线线
	local lineSprite = CCSprite:create("images/copy/fort/top_cutline.png")
	lineSprite:setAnchorPoint(ccp(0.5,0.5))
	lineSprite:setPosition(ccpsprite(0.5, 0, _upUiNode))
	_upUiNode:addChild(lineSprite)

	-- 按钮创建
	local upMenuBar = CCMenu:create()
	upMenuBar:setAnchorPoint(ccp(0,0))
	upMenuBar:setPosition(ccp(0,0))
	_upUiNode:addChild(upMenuBar)

	-- 返回按钮
	local backMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	backMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	backMenuItem:registerScriptTapHandler(backMenuItemCallBack)
	backMenuItem:setPosition(ccp(588, 213))
	upMenuBar:addChild(backMenuItem)

	-- 活动说明按钮
	local explainButton = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
	explainButton:setAnchorPoint(ccp(0.5, 0.5))
	explainButton:registerScriptTapHandler(explainButtonCallBack)
	explainButton:setPosition(ccp(56, 199))
	upMenuBar:addChild(explainButton)

	-- 标题
	local titleSprite = LordWarUtil.createTitleSprite()
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(320, 224))
	_upUiNode:addChild(titleSprite)

	-- 小标题
	_titleLabel = LordWarUtil.getRoundTitle()
	_titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	_titleLabel:setPosition(ccp(320, 180))
	_upUiNode:addChild(_titleLabel)
    
    -- 倒计时
    local timeNode = LordWarUtil.getTimeTitle()
    _upUiNode:addChild(timeNode)
    timeNode:setAnchorPoint(ccp(0.5, 0.5))
    timeNode:setPosition(ccp(320, 128))

	-- 傲视群雄组按钮
	local aoMenuItem = createButtonItem( "images/lord_war/audio_btn2_n.png", "images/lord_war/audio_btn2_h.png", "images/lord_war/arrow2.png", GetLocalizeStringBy("lic_1192"), 33, 30, ccc3( 0xff, 0xff, 0xff), ccc3( 0xac, 0x85, 0xc6) )
	aoMenuItem:setAnchorPoint(ccp(0.5,0.5))
	aoMenuItem:setPosition(ccp(165.5, 59))
	upMenuBar:addChild(aoMenuItem,1,LordWarData.kWinLordType)
	aoMenuItem:registerScriptTapHandler(groupMenuItemCallBack)

	-- 初出茅庐组按钮
	local chuMenuItem = createButtonItem( "images/lord_war/audio_btn1_n.png", "images/lord_war/audio_btn1_h.png", "images/lord_war/arrow1.png", GetLocalizeStringBy("lic_1193"), 33, 30, ccc3( 0xff, 0xff, 0xff), ccc3( 0x8c, 0xc5, 0x84) )
	chuMenuItem:setAnchorPoint(ccp(0.5,0.5))
	chuMenuItem:setPosition(ccp(474.5, 59))
	upMenuBar:addChild(chuMenuItem,1,LordWarData.kLoseLordType)
	chuMenuItem:registerScriptTapHandler(groupMenuItemCallBack)

	-- 默认选中玩家所在组
	_curGroupType = LordWarData.kWinLordType
	_curGroupMenuItem = aoMenuItem
	_curGroupMenuItem:selected()
end

--[[
	@des 	:创建中间部分ui   
		 	 半决赛位置:	1    2    
				 		3    4   
			 决赛位置:   1
			 			2
			 冠军位置:   固定中间
--]]
function createMiddleNode()
	if(tolua.cast(_middleUiNode,"CCNode") ~= nil)then
		_middleUiNode:removeFromParentAndCleanup(true)
		_middleUiNode = nil
	end
	_middleUiNode = CCNode:create()
	_middleUiNode:setContentSize(CCSizeMake(640,598))
	_middleUiNode:setAnchorPoint(ccp(0.5,0.5))
	local middleHeight = _bgLayer:getContentSize().height -_upUiNode:getContentSize().height*MainScene.elementScale- _bottomUiNode:getContentSize().height*MainScene.elementScale
	_middleUiNode:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bottomUiNode:getContentSize().height*MainScene.elementScale + middleHeight*0.5))
	_bgLayer:addChild(_middleUiNode,2)
	-- 适配 缩放比例还是太小，在pad上超出，所以乘个系数
    _middleUiNode:setScale(MainScene.elementScale*0.92)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setAnchorPoint(ccp(0.5,0.5))
	menuBar:setPosition(ccp(0,0))
	_middleUiNode:addChild(menuBar,10,_middleMenuTag)
	-- 4强
	local posX = {0.2,0.8,0.2,0.8}
	local posY = {0.83,0.83,0.2,0.2}
	local lineDirection = {_lineRight,_lineLeft,_lineRight,_lineLeft}
	for four_index=1,4 do
		-- 4强数据
 		local fourUserData = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank4, four_index )
 		-- 4强位置ui
 		local headBg = create4HeadBg( lineDirection[four_index], fourUserData )
		headBg:setAnchorPoint(ccp(0.5,0.5))
		headBg:setPosition(ccpsprite(posX[four_index],posY[four_index],_middleUiNode))
		_middleUiNode:addChild(headBg)
		-- 4强助威和战报按钮
		if( four_index == 1 or four_index ==3)then
			-- 助威按钮
			local zhuMenuItem = createZhuMenuItem()
			zhuMenuItem:setAnchorPoint(ccp(0.5,0.5))
			zhuMenuItem:setPosition(ccpsprite(0.5,posY[four_index],_middleUiNode))
			menuBar:addChild(zhuMenuItem,1,four_index)
			zhuMenuItem:registerScriptTapHandler(zhuMenuItemCallBack)
			zhuMenuItem:setVisible(false)

			-- 战报按钮
			local zhanMenuItem = createZhanMenuItem()
			zhanMenuItem:setAnchorPoint(ccp(0.5,0.5))
			zhanMenuItem:setPosition(ccpsprite(0.5,posY[four_index],_middleUiNode))
			menuBar:addChild(zhanMenuItem,1,four_index*10)
			zhanMenuItem:registerScriptTapHandler(zhanMenuItemCallBack)
			zhanMenuItem:setVisible(false)
		end
		-- 储存四强位置Ui
		_fourUiTab[four_index] = headBg

		-- 已助威
		if( fourUserData ~= nil )then
			local curSupportData = LordWarData.getCheerInfo()
			print("curSupport_serverid ==>",curSupportData.support_serverid,"curSupport_uid ==>",curSupportData.support_uid)
			if(tonumber(curSupportData.support_serverid) == tonumber(fourUserData.serverId) and tonumber(curSupportData.support_uid) == tonumber(fourUserData.uid) )then
				local headBg = tolua.cast(_fourUiTab[four_index],"CCSprite")
				if(tolua.cast(_yiZhuWeiSp,"CCSprite") ~= nil)then
					_yiZhuWeiSp:removeFromParentAndCleanup(true)
					_yiZhuWeiSp = nil
				end
				_yiZhuWeiSp = CCSprite:create("images/lord_war/yizhuwei.png")
				_yiZhuWeiSp:setAnchorPoint(ccp(0,0))
				_yiZhuWeiSp:setPosition(ccp(45,65))
				headBg:getChildByTag(_heroIconLightTag):addChild(_yiZhuWeiSp,10)
			end
		end
 	end

	-- 冠军
	-- 冠军数据
	local guanData = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank1, 1 )
	-- 冠军位置ui
	_guanUi = createFirstHeadBg( guanData )
	_guanUi:setAnchorPoint(ccp(0.5,0.5))
	_guanUi:setPosition(ccpsprite(0.5,0.5,_middleUiNode))
	_middleUiNode:addChild(_guanUi)

	-- 冠军助威按钮
	local zhuMenuItem = createZhuMenuItem()
	zhuMenuItem:setAnchorPoint(ccp(0.5,0.5))
	zhuMenuItem:setPosition(ccpsprite(0.67,0.5,_middleUiNode))
	menuBar:addChild(zhuMenuItem,1,_button2Tag)
	zhuMenuItem:registerScriptTapHandler(zhuMenuItemCallBack)
	zhuMenuItem:setVisible(false)

	-- 冠军战报按钮
	local zhanMenuItem =  createZhanMenuItem()
	zhanMenuItem:setAnchorPoint(ccp(0.5,0.5))
	zhanMenuItem:setPosition(ccpsprite(0.67,0.5,_middleUiNode))
	menuBar:addChild(zhanMenuItem,1,_button2Tag*10)
	zhanMenuItem:registerScriptTapHandler(zhanMenuItemCallBack)
	zhanMenuItem:setVisible(false)

	-- 助威和战报按钮
	refreshBtnCallBack()

	-- 有冠军
	if( guanData ~= nil)then
		-- 2强
	 	for two_index=1,2 do
			local twoUserData = LordWarData.getProcessPromotionInfoBy( _curGroupType, LordWarData.kRank2, two_index )
            if twoUserData ~= nil then
                if(guanData.serverPos == twoUserData.serverPos)then
                    -- 晋级
                    -- 显示亮线
                    if(two_index == 1)then
                        -- 上边线亮
                        _guanUi:getChildByTag(_upGrayLineTag):setVisible(true)
                        _guanUi:getChildByTag(_upLightLineTag):setVisible(true)
                    else
                        -- 下边线亮
                        _guanUi:getChildByTag(_downGrayLineTag):setVisible(true)
                        _guanUi:getChildByTag(_dowLightLineTag):setVisible(true)
                    end
                    break				
                end
            end
		end
	end	
end

--[[
	@des 	:创建底部分ui
--]]
function createBottomNode( ... )
	_bottomUiNode = CCNode:create()
	_bottomUiNode:setContentSize(CCSizeMake(640,115))
	_bottomUiNode:setAnchorPoint(ccp(0.5,0))
	_bottomUiNode:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
	_bgLayer:addChild(_bottomUiNode,2)
	-- 适配
	_bottomUiNode:setScale(g_fScaleX)

	-- 底部分割线线
	local lineSprite = CCSprite:create("images/common/separator_bottom.png")
	lineSprite:setAnchorPoint(ccp(0.5,1))
	lineSprite:setPosition(ccp(_bottomUiNode:getContentSize().width/2,_bottomUiNode:getContentSize().height))
	_bottomUiNode:addChild(lineSprite)

	-- 按钮创建
	local bottomMenuBar = CCMenu:create()
	bottomMenuBar:setTouchPriority(_touchPriority - 1)
	bottomMenuBar:setAnchorPoint(ccp(0,0))
	bottomMenuBar:setPosition(ccp(0,0))
	_bottomUiNode:addChild(bottomMenuBar)

	--我的信息按钮
	local myInfoMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("lic_1179"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	myInfoMenuItem:setAnchorPoint(ccp(0,0))
	myInfoMenuItem:setPosition(ccp(1,20))
	myInfoMenuItem:registerScriptTapHandler(myInfoMenuItemCallBack)
	bottomMenuBar:addChild(myInfoMenuItem)

	-- 更新战斗信息按钮
	local refreshFightMenuItem = LordWarUtil.createUpdateInfoButton("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(240,73),-430)
    refreshFightMenuItem:setAnchorPoint(ccp(0.5,0))
	refreshFightMenuItem:setPosition(ccp(_bottomUiNode:getContentSize().width/2,20))
	_bottomUiNode:addChild(refreshFightMenuItem)

	-- 战况回顾按钮
	local lookBackMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("lic_1181"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	lookBackMenuItem:setAnchorPoint(ccp(1,0))
	lookBackMenuItem:setPosition(ccp(_bottomUiNode:getContentSize().width - 1,20))
	lookBackMenuItem:registerScriptTapHandler(lookBackMenuItemCallBack)
	bottomMenuBar:addChild(lookBackMenuItem)
end

--[[
	@des 	: 创建4强界面
	@param 	: p_InnerOrCross 服内 or 跨服
	@return : CCLayer
--]]
function createLordWar4Layer( p_InnerOrCross )
	-- 初始化
	init()
	-- 战况回顾用 跨服还是服内标识
	_curShowType = p_InnerOrCross
	print("_curShowType",_curShowType)
	-- layer
	_bgLayer = CCLayer:create()

	-- 大背景
	local bgSprite = CCSprite:create("images/lord_war/bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height/2))
	bgSprite:setScale(MainScene.bgScale)
	_bgLayer:addChild(bgSprite)

	-- 创建上部分ui
	createUpNode()

	-- 创建下部分ui
	createBottomNode()

	-- 创建中间部分ui
	createMiddleNode()
    LordWarEventDispatcher.addListener("LordWar4Layer.refreshAllCallback", refreshAllCallback)
	--LordWarUtil.addRoundChangeEvent("LordWar4Layer",refreshAllCallback)
	return _bgLayer
end

--[[
	@des 	: 入口函数 显示4强界面
	@param 	:p_InnerOrCross 服内 or 跨服
	@return :
--]]
function show( p_InnerOrCross )
	local layer = LordWar4Layer.createLordWar4Layer( p_InnerOrCross )
	MainScene.changeLayer(layer, "LordWar4Layer")
	MainScene.setMainSceneViewsVisible(false,false,false)
end













































