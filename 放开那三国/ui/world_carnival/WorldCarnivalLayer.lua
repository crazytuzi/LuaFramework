-- Filename: WorldCarnivalLayer.lua
-- Author: bzx
-- Date: 2014-08-27
-- Purpose: 跨服嘉年华

module("WorldCarnivalLayer", package.seeall)

btimport "script/ui/world_carnival/WorldCarnivalUtil"
btimport "script/ui/world_carnival/WorldCarnivalService"
btimport "script/ui/world_carnival/WorldCarnivalEventDispatcher"

local _layer = nil
local _touchPriority = nil
local _zOrder = nil
local _topSprite = nil
local _bottomSprite = nil
local _centerSprite = nil
local _positionDatas = nil

local LineType = {
	STRAIGHT 	= 1,
	BENT		= 2,
}

function show( p_touchPriority, p_zOrder )
	if WorldCarnivalData.isFighter() or WorldCarnivalData.isWatcher() then
		_layer = create(p_touchPriority, p_zOrder)
		MainScene.changeLayer(_layer, "WorldCarnivalLayer")
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_10328"))
	end
end

function create( p_touchPriority, p_zOrder )
	init(p_touchPriority, p_zOrder)
	initPositions()
	_layer = CCLayer:create()
	MainScene.setMainSceneViewsVisible(false, false, false)
	loadBg()
	loadTop()
	loadBottom()
	playBgm()
	local rpcCallback = function ( ... )
		WorldCarnivalEventDispatcher.open()
		loadTimeDescSprite()
		refreshCenter()
		WorldCarnivalEventDispatcher.addListener("WorldCarnivalLayer.onStatusChange", onStatusChange)
		WorldCarnivalService.re_worldcarnival_update()
	end
	WorldCarnivalService.getCarnivalInfo(rpcCallback)
	return _layer
end

function init( p_touchPriority, p_zOrder )
	_touchPriority = p_touchPriority or -420
	_zOrder = p_zOrder or 100
	_centerSprite = nil
end

--[[
	@desc:		初始化人物，线条，按钮的位置信息
--]]
 function initPositions( ... )
 	local l = function(lineType, position, scaleX, scaleY, rotation, length)
        return {["lineType"] = lineType, ["position"] = position, ["scaleX"] = scaleX, ["scaleY"] = scaleY, ["rotation"] = rotation, ["length"] = length}
    end
    _positionDatas = {
        [4] = {
        	-- 台子
            stagePositions = {
                ccp(90, 70), ccp(230, 70), ccp(410, 70), ccp(550, 70)
            },
            -- 晋级线
            lineDatas = {
                l(LineType.BENT, ccp(110, 200), nil, -1), l(LineType.BENT, ccp(210, 200), nil, nil, 180), 
                l(LineType.BENT, ccp(430, 200), nil, -1), l(LineType.BENT, ccp(530, 200), nil, nil, 180),
                l(LineType.STRAIGHT, ccp(160, 280), nil, nil, 90), l(LineType.STRAIGHT, ccp(480, 280), nil, nil, 90),
            },
            -- 查看战报按钮
            btnPositions = {
                ccp(160, 230), ccp(480, 230)
            }
        },
        [2] = {
        	stagePositions = {
                ccp(160, 300), ccp(480, 300)
            },
            lineDatas = {
                l(LineType.BENT, ccp(232, 370), nil, -1, nil, 158), l(LineType.BENT, ccp(408, 370), nil, nil, 180, 158), l(LineType.STRAIGHT, ccp(320, 450), nil, nil, 90),
            },
            btnPositions = {
                ccp(320, 400)
            }
        },
        [1] = {
            stagePositions = {
                ccp(319, 450)
            },
        }
    }
 end

-- 背景
function loadBg( ... )
	local bgSprite = CCSprite:create("images/olympic/playoff_bg.jpg")
	_layer:addChild(bgSprite)
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccpsprite(0.5, 0.5, _layer))
	bgSprite:setScale(MainScene.bgScale)
end

--[[
	@desc:		显示顶部UI
--]]
function loadTop( ... )
	_topSprite = WorldCarnivalUtil.createTopSprite(_touchPriority - 5)
    _layer:addChild(_topSprite)
    _topSprite:setAnchorPoint(ccp(0.5, 1))
    _topSprite:setPosition(ccpsprite(0.5, 1, _layer))
    _topSprite:setScale(g_fScaleX)
end

--[[
	@desc:		时间提示
--]]
function loadTimeDescSprite( ... )
	local timeDescSprite = WorldCarnivalUtil.getTimeDescSprite()
	_topSprite:addChild(timeDescSprite)
	timeDescSprite:setAnchorPoint(ccp(0.5, 0.5))
	timeDescSprite:setPosition(ccpsprite(0.5, 0.2, _topSprite))
end

--[[
	@desc:		显示底部UI
--]]
function loadBottom()
    _bottomSprite = WorldCarnivalUtil.createBottomSprite(_touchPriority - 1)
    _layer:addChild(_bottomSprite)
    _bottomSprite:setScale(g_fScaleX)
    _bottomSprite:setAnchorPoint(ccp(0.5, 0))
    _bottomSprite:setPosition(ccpsprite(0.5, 0, _layer))
end


--[[
	@desc:		显示更新战斗信息的提示
--]]
function showUpdateTip( ... )
	AnimationTip.showTip(GetLocalizeStringBy("lic_1599"))
end

--[[
	@desc: 		中间部分
--]]
function refreshCenter( ... )
	if _centerSprite == nil then
		_centerSprite = CCSprite:create()
		--_centerSprite = CCLayerColor:create(ccc4(250, 0, 0, 100), 640, 655)
		_centerSprite:ignoreAnchorPointForPosition(false)
		_centerSprite:setContentSize(CCSizeMake(640,655))
		_centerSprite:setAnchorPoint(ccp(0.5,0.5))
		_centerSprite:setPosition(ccpsprite(0.5, 0.45, _layer))
		_centerSprite:setScale(MainScene.elementScale)
		_layer:addChild(_centerSprite)
	else
		_centerSprite:removeAllChildrenWithCleanup(true)
	end
	
	local normalBgPositions = {ccp(162, 140), ccp(478, 140)}
	local titleImages = {"images/carnival/chaofanrushengzu.png", "images/carnival/jushiwushuangzu.png"}
	local effectPaths = {"images/base/effect/chaofanrushengzu/chaofanrushengzu", "images/base/effect/jushiwushuangzu/jushiwushuangzu"}
	for i = 1, 2 do
		local normalBg = CCScale9Sprite:create("images/recharge/feedback_active/content_bg.png")
   		_centerSprite:addChild(normalBg)
   		normalBg:setAnchorPoint(ccp(0.5, 0.5))
   		normalBg:setContentSize(CCSizeMake(270, 310))
   		normalBg:setRotation(90)
   		normalBg:setPosition(normalBgPositions[i])

   		local titleSprite = CCSprite:create(titleImages[i])
   		_centerSprite:addChild(titleSprite)
   		titleSprite:setAnchorPoint(ccp(0.5, 0.5))
   		titleSprite:setPosition(ccp(normalBgPositions[i].x, 10))

   		local effect = XMLSprite:create(effectPaths[i])
   		titleSprite:addChild(effect)
   		effect:setPosition(ccpsprite(0.5, 0.5, titleSprite))
	end

	
	
	local menu = CCMenu:create()
	_centerSprite:addChild(menu, 5)
	menu:setPosition(ccp(0, 0))
	local fighters = WorldCarnivalData.getFighters()
	local rank = 4
	while rank >= 1 do
		local positionData = _positionDatas[rank]
		for i = 1, #positionData.stagePositions do
			local stagePosition = positionData.stagePositions[i]
			local stage = createStage(rank, i)
			_centerSprite:addChild(stage, 2)
			stage:setAnchorPoint(ccp(0.5,0))
			stage:setPosition(stagePosition)
		end
		if positionData.lineDatas ~= nil then
			for i=1, #positionData.lineDatas do
				local lineData = positionData.lineDatas[i]
				local lineImage = nil
				if lineData.lineType == LineType.STRAIGHT then
					local rankPosition1 = (i - rank) * 2
					local rankPosition2 = rankPosition1 - 1
					local hero1Status = WorldCarnivalData.getHeroStatusByRank(rank, rankPosition1)
					local hero2Status = WorldCarnivalData.getHeroStatusByRank(rank, rankPosition2)
					if hero1Status == WorldCarnivalConstant.STATUS_WIN or hero2Status == WorldCarnivalConstant.STATUS_WIN then
						lineImage = "images/olympic/line/horizontalLine_light.png"
					else
						lineImage = "images/olympic/line/horizontalLine_gray.png"
					end
				elseif lineData.lineType == LineType.BENT then
					local heroStatus = WorldCarnivalData.getHeroStatusByRank(rank, i)
					if heroStatus == WorldCarnivalConstant.STATUS_WIN then
						lineImage = "images/olympic/line/downRightLine_light.png"
					else
						lineImage = "images/olympic/line/downRightLine_gray.png"
					end
				end
				local line = CCScale9Sprite:create(lineImage)
				_centerSprite:addChild(line)
				line:setAnchorPoint(ccp(0.5, 0.5))
				line:setPosition(lineData.position)
				if lineData.scaleY ~= nil then
					line:setScaleY(lineData.scaleY)
				end
				if lineData.scaleX ~= nil then
					line:setScaleX(lineData.scaleX)
				end
				if lineData.rotation ~= nil then
					line:setRotation(lineData.rotation)
				end
				if lineData.length ~= nil then
					line:setContentSize(CCSizeMake(lineData.length, line:getContentSize().height))
				end
			end
		end
		if positionData.btnPositions ~= nil then
			for i=1, #positionData.btnPositions do
				local btnPosition = positionData.btnPositions[i]
				local btnSize = CCSizeMake(70, 70)
				local normalSprite = CCLayerColor:create(ccc4(100, 0, 0, 0), btnSize.width, btnSize.height)
				local normalIcon = CCSprite:create("images/olympic/checkbutton/check_btn_h.png")
				normalSprite:addChild(normalIcon)
				normalIcon:setAnchorPoint(ccp(0.5, 0.5))
				normalIcon:setPosition(ccpsprite(0.5, 0.5, normalSprite))

				local slectedSprite = CCLayerColor:create(ccc4(100, 0, 0, 0), btnSize.width, btnSize.height)
				local slectedIcon = CCSprite:create("images/olympic/checkbutton/check_btn_n.png")
				slectedSprite:addChild(slectedIcon)
				slectedIcon:setAnchorPoint(ccp(0.5, 0.5))
				slectedIcon:setPosition(ccpsprite(0.5, 0.5, slectedSprite))

				local checkItem = CCMenuItemSprite:create(normalSprite, slectedSprite)
				menu:addChild(checkItem)
				checkItem:setPosition(btnPosition)
				checkItem:setAnchorPoint(ccp(0.5, 0.5))
				checkItem:registerScriptTapHandler(WorldCarnivalController.checkBattleReportCallback)
				local round = WorldCarnivalData.getRoundByRank(rank, i)
				checkItem:setTag(round)
				if not WorldCarnivalData.isHaveBattleReport(round) then
					local disabledSprite = CCLayerColor:create(ccc4(100, 0, 0, 0), btnSize.width, btnSize.height)
					local disabledIcon = BTGraySprite:create("images/olympic/checkbutton/check_btn_h.png")
					disabledSprite:addChild(disabledIcon)
					disabledIcon:setAnchorPoint(ccp(0.5, 0.5))
					disabledIcon:setPosition(ccpsprite(0.5, 0.5, disabledSprite))
					checkItem:setDisabledImage(disabledSprite)
					checkItem:setEnabled(false)
				end
			end
		end
		rank = rank * 0.5
	end
end

--[[
	@desc:	 			创建英雄
	@param 	p_rank		英雄所站位置的rank
	@param  p_position  英雄在对应的rank的位置 
--]]
function createStage( p_rank, p_position)
	local stage = nil
	-- 如果是冠军
	if p_rank == 1 then
		stage = CCSprite:create("images/carnival/champion_stage.png")
	    local lightEffectSprite_2 = XMLSprite:create("images/base/effect/guangjun/guangjuntai")
		lightEffectSprite_2:setPosition(ccpsprite(0.5, 0.78, stage))
	    lightEffectSprite_2:setAnchorPoint(ccp(0.5, 0))
	    stage:addChild(lightEffectSprite_2,20)
	else
		stage = CCSprite:create("images/carnival/normal_stage.png")
	end
	local fighters = WorldCarnivalData.getFighters()
	local fighterInfo = nil
	if fighters[p_rank] ~= nil then
		fighterInfo = fighters[p_rank][p_position]
	end
	if fighterInfo ~= nil then
		local heroBodyPath = nil
		if not table.isEmpty(fighterInfo.dress) then
			heroBodyPath = HeroUtil.getHeroBodyImgByHTID(fighterInfo.htid, fighterInfo.dress["1"])
		else
			heroBodyPath = HeroUtil.getHeroBodyImgByHTID(fighterInfo.htid)
		end
		local heroBody = nil
		if p_rank > 1 then
			local heroStatus = WorldCarnivalData.getHeroStatusByRank(p_rank, p_position)
			local heroStatusSprite = nil
			if heroStatus == WorldCarnivalConstant.STATUS_LOSING then
				heroStatusSprite = CCSprite:create("images/olympic/lost.png")
				heroBody = BTGraySprite:create(heroBodyPath)
			elseif heroStatus == WorldCarnivalConstant.STATUS_WIN then
				heroStatusSprite = CCSprite:create("images/olympic/win.png")
			end
			if heroStatusSprite ~= nil then
				stage:addChild(heroStatusSprite, 11)
				heroStatusSprite:setPosition(ccp(0, 140))
			end
		else
			local championSprite = CCSprite:create("images/olympic/king_hat.png")
			stage:addChild(championSprite, 11)
			championSprite:setAnchorPoint(ccp(0.5, 0.5))
			championSprite:setPosition(ccpsprite(0.5, 2, stage))
		end
		if heroBody == nil then
			heroBody = CCSprite:create(heroBodyPath)
		end
		stage:addChild(heroBody, 10)
		heroBody:setScale(0.35)
		heroBody:setAnchorPoint(ccp(0.5, 0))
		if p_rank > 1 then
			heroBody:setPosition(ccpsprite(0.5, 0.5, stage))
		else
			heroBody:setPosition(ccpsprite(0.5, 0.6, stage))
		end
		local nameLabel = CCRenderLabel:create(fighterInfo.uname, g_sFontPangWa,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		stage:addChild(nameLabel, 22)
		nameLabel:setAnchorPoint(ccp(0.5, 0.5))
		

		local fightForceBg = CCSprite:create("images/lord_war/fight_bg.png")
		stage:addChild(fightForceBg, 12)
		fightForceBg:setAnchorPoint(ccp(0.5, 0.5))

		local fightForceLabel = CCRenderLabel:create(fighterInfo.fight_force, g_sFontPangWa,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		fightForceBg:addChild(fightForceLabel)
		fightForceLabel:setAnchorPoint(ccp(0, 0.5))
		fightForceLabel:setPosition(ccp(34, fightForceBg:getContentSize().height * 0.5))
		fightForceLabel:setColor(ccc3(0xff, 0x00, 0x00))
		
		local serverNameLabel = CCLabelTTF:create("(" .. fighterInfo.server_name .. ")", g_sFontName, 18)
		stage:addChild(serverNameLabel, 12)
		serverNameLabel:setAnchorPoint(ccp(0.5, 0.5))
		if p_rank > 1 then
			nameLabel:setPosition(ccpsprite(0.5, 0.35, stage))
			fightForceBg:setPosition(ccpsprite(0.55, -0.1, stage))
			serverNameLabel:setPosition(ccpsprite(0.5, -0.5, stage))
		else
			nameLabel:setPosition(ccpsprite(0.5, 0.37, stage))
			fightForceBg:setPosition(ccpsprite(0.55, 0.13, stage))
			serverNameLabel:setPosition(ccpsprite(0.5, -0.08, stage))
		end
		local menu = CCMenu:create()
		stage:addChild(menu)
		menu:setContentSize(stage:getContentSize())
		menu:setAnchorPoint(ccp(0.5, 0))
		menu:ignoreAnchorPointForPosition(false)
		menu:setPosition(ccpsprite(0.5, 0, stage))
		menu:setTouchPriority(_touchPriority)

		local normal = CCLayerColor:create(ccc4(255, 0, 0, 0), 130, 160)
		local lookFormationBtn = CCMenuItemSprite:create(normal, normal)
		menu:addChild(lookFormationBtn)
		lookFormationBtn:registerScriptTapHandler(lookFormationCallback)
		lookFormationBtn:setTag(tonumber(fighterInfo.pos))
		lookFormationBtn:setAnchorPoint(ccp(0.5, 0))
		lookFormationBtn:setPosition(ccpsprite(0.5, 0, menu))
	end
	return stage
end

-- 查看阵容
function lookFormationCallback( p_tag )
	local pos = p_tag
	local fighterInfo = WorldCarnivalData.getFighterInfoByPos(pos)
	btimport "script/ui/active/RivalInfoLayer"
	RivalInfoLayer.createLayer(nil, false, nil, false, false, false, fighterInfo.pid, fighterInfo.server_id)
end

-- 比赛状态变化时的回调
function onStatusChange( p_round, p_status, p_subRound, p_subStatus, p_tag )
	if tolua.isnull(_layer) then
		return
	end
	if p_tag ~= "statusChange" then
		return
	end
	if p_subStatus == WorldCarnivalConstant.STATUS_DONE then
		refreshCenter()
	end
	local lastRound = WorldCarnivalEventDispatcher.getLastStatus()
	if lastRound ~= p_round then
		playRoundStartEffect(p_round)
	end
end

-- 播放背景音乐
function playBgm()
	AudioUtil.playBgm("audio/bgm/music15.mp3")
end

-- 停止背景音乐
function stopBgm( ... )
	AudioUtil.stopBgm()
end

-- 每一大轮开始时播放特效
function playRoundStartEffect(p_round, p_zOrder)
	p_zOrder = p_zOrder or 999
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local animationLayer = CCLayer:create()
	animationLayer:setScale(g_fScaleX)
	animationLayer:setContentSize(CCSizeMake(640,960))
	runningScene:addChild(animationLayer,p_zOrder)

	local separatorSprite = CCSprite:create("images/olympic/stage_animation/separator.png")
	separatorSprite:setAnchorPoint(ccp(0.5,0.5))
	separatorSprite:setPosition(320,480)
	animationLayer:addChild(separatorSprite)

	local leftImages = {
		[WorldCarnivalConstant.ROUND_1] = "images/carnival/cfrs.png",
		[WorldCarnivalConstant.ROUND_2] = "images/carnival/jsws.png",
		[WorldCarnivalConstant.ROUND_3] = "images/olympic/stage_animation/guanjun_left.png",
	}

	local leftSprite = CCSprite:create(leftImages[p_round])
	leftSprite:setAnchorPoint(ccp(1,0.5))
	leftSprite:setPosition(0,500)
	animationLayer:addChild(leftSprite)
	leftSprite:runAction(CCMoveTo:create(0.2,ccp(360, 500)))

	local rightSprite = CCSprite:create("images/olympic/stage_animation/zhengba_right.png")
	rightSprite:setAnchorPoint(ccp(0,0.5))
	rightSprite:setPosition(640,460)
	animationLayer:addChild(rightSprite)
	local rightAnimationEndCb = function ()
		separatorSprite:runAction(CCFadeOut:create(0.5))
		leftSprite:runAction(CCFadeOut:create(0.5))

		local rightSpriteFadeOutActionCb = function ()
			animationLayer:removeFromParentAndCleanup(true)
		end
		local layerActionSequence = CCSequence:createWithTwoActions(CCFadeOut:create(0.5),CCCallFunc:create(rightSpriteFadeOutActionCb))
		rightSprite:runAction(layerActionSequence)
	end
	local rightActionSequence = CCSequence:createWithTwoActions(CCMoveTo:create(0.2,ccp(340,460)), CCCallFunc:create(rightAnimationEndCb))
	rightSprite:runAction(rightActionSequence)
end

-- 关闭界面
function close( ... )
	stopBgm()
	_layer:removeFromParentAndCleanup(true)
end