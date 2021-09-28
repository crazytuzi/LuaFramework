-- Filename: FlipCardLayer.lua
-- Author: Zhang Zihang
-- Date: 2014-08-21
-- Purpose: 创建翻牌界面

module("FlipCardLayer", package.seeall)

require "script/ui/replaceSkill/ReplaceSkillData"
require "script/utils/BaseUI"
require "script/ui/tip/AnimationTip"
require "script/ui/replaceSkill/ReplaceSkillService"
require "script/utils/LevelUpUtil"
require "script/model/user/UserModel"

--[[
                   _ooOoo_
                  o8888888o
                  88" . "88
                  (| -_- |)
                  O\  =  /O
               ____/`---'\____
             .'  \\|     |//  `.
            /  \\|||  :  |||//  \
           /  _||||| -:- |||||-  \
           |   | \\\  -  /// |   |
           | \_|  ''\---/''  |   |
           \  .-\__  `-`  ___/-. /
         ___`. .'  /--.--\  `. . __
      ."" '<  `.___\_<|>_/___.'  >'"".
     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
     \  \ `-.   \_ __\ /__ _/   .-` /  /
======`-.____`-.___\_____/___.-`____.-'======
                   `=---='
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
佛祖保佑             永无BUG             不改需求
--]]

local _touchPriority
local _zOrder
local _bgLayer
local _previewMenuItem 			--预览按钮
local _quickMenuItem 			--一键翻牌
local _rewardMenuItem 			--领奖按钮
local _monkeryNum 				--修行值
local _curFlower 				--当前花型
local _remainTable 				--当前后端返回的牌型
local _scene 					--当前界面
local _redTable 				--红光位置
local _greenTable 				--绿光位置
local _isQuitWithOut 			--是否没领奖就退出
local _maxFlowerLV = 1 			--最高花色代号
local kDesTag = 1 				--花色描述的tag值
local kSpriteTag = 2 			--花色图片tag
local kKissTag = 3 				--亲密度tag
local kCardTag = 100 			--卡牌的tag，用这个tag主要是用于清除卡牌使用
local kNameTag = 200 			--卡牌名字的tag
local kBackTag = 300 			--卡牌背面tag
local kRedTag = 400				--红光特效tag
local kGreenTag = 500 			--绿光特效tag

--用来存放相应花色对应的描述的table
local _desTable = {
						[1] = GetLocalizeStringBy("zzh_1102"),
						[2] = GetLocalizeStringBy("zzh_1103"),
						[3] = GetLocalizeStringBy("zzh_1104"),
						[4] = GetLocalizeStringBy("zzh_1105"),
						[5] = GetLocalizeStringBy("zzh_1106"),
						[6] = GetLocalizeStringBy("zzh_1107"),
						[7] = GetLocalizeStringBy("zzh_1108"),
				  }
local _nameTable = {
						[1] = GetLocalizeStringBy("zzh_1109"),
						[2] = GetLocalizeStringBy("zzh_1110"),
						[3] = GetLocalizeStringBy("zzh_1111"),
						[4] = GetLocalizeStringBy("zzh_1112"),
						[5] = GetLocalizeStringBy("zzh_1113"),
						[6] = GetLocalizeStringBy("zzh_1114"),
						[7] = GetLocalizeStringBy("zzh_1115"),
						[8] = GetLocalizeStringBy("zzh_1116"),
				   }

local _eventTable = {
						[1] = GetLocalizeStringBy("zzh_1123"),
						[2] = GetLocalizeStringBy("zzh_1124"),
						[3] = GetLocalizeStringBy("zzh_1125"),
						[4] = GetLocalizeStringBy("zzh_1126"),
						[5] = GetLocalizeStringBy("zzh_1127"),
						[6] = GetLocalizeStringBy("zzh_1128"),
						[7] = GetLocalizeStringBy("zzh_1129"),
					}	

--卡牌横坐标
local _xPosTable = {
						[1] = 320/640,
						[2] = 530/640,
						[3] = 460/640,
						[4] = 180/640,
						[5] = 110/640,
				   }

local _yPosTable = {
						[1] = 775/960,
						[2] = 555/960,
						[3] = 245/960,
						[4] = 245/960,
						[5] = 555/960,
				   }

local _namePosTable = {
						[1] = 625/960,
						[2] = 405/960,
						[3] = 95/960,
						[4] = 94/960,
						[5] = 405/960,
					  }
----------------------------------------初始化函数----------------------------------------
local function init()
	_touchPriority = nil
	_zOrder = nil
	_bgLayer = nil
	_previewMenuItem = nil
	_quickMenuItem = nil
	_rewardMenuItem = nil
	_remainTable = {}
	_redTable = {}
	_greenTable = {}
	_isQuitWithOut = false
	_monkeryNum = 0
	_curFlower = 0
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		-- print("began")
	    return true
    elseif (eventType == "moved") then
    else
        -- print("end")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:奖励预览回调
	@param 	:
	@return :
--]]
function previewCallBack()
	require "script/ui/replaceSkill/ReplaceSkillRewardLayer"
	ReplaceSkillRewardLayer.showLayer(-600,1200)
end

--[[
	@des 	:一键翻牌回调
	@param 	:
	@return :
--]]
function quickCallBack()
	if _curFlower ~= _maxFlowerLV then
		local sureConfirm = function(isConfirm)
			if isConfirm then
				if tonumber(UserModel.getGoldNumber()) >= ReplaceSkillData.getOneSetGold() then
					local shuffleCallBack = function(p_ret)
						--减金币
						UserModel.addGoldNumber(tonumber(-ReplaceSkillData.getOneSetGold()))

						--刷街面上的数字
						require "script/ui/replaceSkill/learnSkill/LearnSkillLayer"
						LearnSkillLayer.refreshUserGoldNum()

						--清除卡牌和名字
						removeCardAndName()
						--按钮显示可见
						unvisibleMethod()
						--删除描述文字
						deleteDesNode()

						--当前卡牌数据
						_remainTable = p_ret
						--当前花型
						_curFlower = tonumber(_remainTable[1])
						--当前修行值
						_monkeryNum = ReplaceSkillData.getHonorNumById(_curFlower)

						deleteLightAnimation()
						
						--创建5个卡牌落地的动画效果
						createInterAnimation()
					end
					ReplaceSkillService.shuffle(shuffleCallBack)
				else
					require "script/ui/tip/LackGoldTip"
            		LackGoldTip.showTip()
				end
			end
		end
		require "script/ui/replaceSkill/OneKeyTip"
		OneKeyTip.showAlert(ReplaceSkillData.getOneSetGold(),_curFlower,sureConfirm)
	else
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1099"))
	end
end

--[[
	@des 	:领取奖励回调
	@param 	:
	@return :
--]]
function rewardCallBack()
	local getRewardCallBack = function()
	    --所有奖励已领取
		_isQuitWithOut = false
		--删除未领奖的名将的奖励信息
		ReplaceSkillData.deleteDraw()

		--按钮显示可见
		unvisibleMethod()
		--删除描述文字
		deleteDesNode()

		--卡牌和名字淡出动画
		fadeOutAction()

		--ReplaceSkillData.addCurStarFeel(_monkeryNum)
		--加入爆裂特效
		createBombAnimation()
	end
	if not ReplaceSkillData.checkBeyondLevel(_monkeryNum) then
		ReplaceSkillService.getReward(getRewardCallBack)
	end
end

--[[
	@des 	:关闭页面回调
	@param 	:
	@return :
--]]
function closeCallBack()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:返回回调
	@param 	:
	@return :
--]]
function goBackCallBack()
	if _isQuitWithOut then
		ReplaceSkillData.addRemainData(_remainTable)
	end
	require "script/ui/replaceSkill/learnSkill/LearnSkillLayer"
	LearnSkillLayer.buttomSure()

	closeCallBack()
end
----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建背景UI
	@param 	:
	@return :
--]]
function createUI()
	--标题
	local titleSprite = CCSprite:create("images/replaceskill/newflip/learnevent.png")
	titleSprite:setAnchorPoint(ccp(0,0.5))
	titleSprite:setPosition(ccp(g_winSize.width*15/640,g_winSize.height*915/960))
	titleSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(titleSprite,2)

	--按钮层
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	_bgLayer:addChild(bgMenu,2)

	--奖励预览图
	_previewMenuItem = CCMenuItemImage:create("images/replaceskill/newflip/rewardevent_n.png","images/replaceskill/newflip/rewardevent_h.png")
	_previewMenuItem:setAnchorPoint(ccp(0.5,0.5))
	_previewMenuItem:setPosition(ccp(g_winSize.width*470/640,g_winSize.height*900/960))
	_previewMenuItem:registerScriptTapHandler(previewCallBack)
	_previewMenuItem:setScale(g_fElementScaleRatio)
	bgMenu:addChild(_previewMenuItem)

	_goBackMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	_goBackMenuItem:setAnchorPoint(ccp(0.5,0.5))
	_goBackMenuItem:setPosition(ccp(g_winSize.width*590/640,g_winSize.height*900/960))
	_goBackMenuItem:registerScriptTapHandler(goBackCallBack)
	_goBackMenuItem:setScale(g_fElementScaleRatio)
	bgMenu:addChild(_goBackMenuItem)

	--一键翻卡按钮
	_quickMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(280,75),GetLocalizeStringBy("zzh_1097"),ccc3(0xfe, 0xdb, 0x1c))
	_quickMenuItem:setAnchorPoint(ccp(0.5,0.5))
	_quickMenuItem:setPosition(ccp(g_winSize.width/4,g_winSize.height*50/960))
	_quickMenuItem:setScale(g_fElementScaleRatio)
	_quickMenuItem:registerScriptTapHandler(quickCallBack)
	bgMenu:addChild(_quickMenuItem)

	--领取奖励按钮
	_rewardMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("zz_31"),ccc3(0xfe, 0xdb, 0x1c))
	_rewardMenuItem:setAnchorPoint(ccp(0.5,0.5))
	_rewardMenuItem:setPosition(ccp(g_winSize.width*3/4,g_winSize.height*50/960))
	_rewardMenuItem:setScale(g_fElementScaleRatio)
	_rewardMenuItem:registerScriptTapHandler(rewardCallBack)
	bgMenu:addChild(_rewardMenuItem)

	--创建五张卡的背面
	---始创建是因为播动画效果要在该牌上面加
	--初始状态卡牌背面不可见
	createCardBack()

	--如果当前宗师有未领取的牌
	--这种情况出现的情况是，播特效的时候崩了
	--为了防止这样，后端做了记忆
	if not table.isEmpty(ReplaceSkillData.remainRewardInfo()) then
		--当前剩余的牌
		_remainTable = ReplaceSkillData.remainRewardInfo()
		--当前花型
		_curFlower = tonumber(_remainTable[1])
		--当前修行值
		_monkeryNum = ReplaceSkillData.getHonorNumById(_curFlower)

		--创建文字描述node
		createDesNode()

		--创建五张图和名字
		createFiveCardAndName(true)

		--处理黄光和绿光的背景特效位置
		dealAnimatePos(_remainTable)
		--创建红光绿光特效
		createAroundAnimate()
	else
		--按钮不可见设置
		unvisibleMethod()

		local drawCallBack = function(p_dictData)
			--翻到的牌
			_remainTable = p_dictData.ret
			--存在没领奖就退出的可能性
			_isQuitWithOut = true

			--如果免费次数用光了
			if ReplaceSkillData.getFreeFlipNum() == 0 then
				--减金币
				UserModel.addGoldNumber(tonumber(-ReplaceSkillData.getUseGoldNum()))
			end

			require "script/ui/replaceSkill/learnSkill/LearnSkillLayer"
			--LearnSkillLayer.refreshGoldLabel()
			LearnSkillLayer.refreshUserGoldNum()
			
			--加一次翻牌次数
			ReplaceSkillData.addFlipNum()

			--刷新下一次翻牌所需金币数量
			LearnSkillLayer.refreshGoldLabel()

			--刷新剩余翻牌次数
			LearnSkillLayer.refreshRemainLabel()

			--当前花型
			_curFlower = tonumber(_remainTable[1])
			--当前修行值
			_monkeryNum = ReplaceSkillData.getHonorNumById(_curFlower)

			--创建5个卡牌落地的动画效果
			createInterAnimation()
		end
		ReplaceSkillService.draw(drawCallBack)
	end
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_zOrder)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	--创建背景屏蔽层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,200))
	_bgLayer:registerScriptHandler(onNodeEvent)

    _scene = CCDirector:sharedDirector():getRunningScene()
    _scene:addChild(_bgLayer,_zOrder)

    --创建UI
    createUI()
end

----------------------------------------工具函数----------------------------------------
--[[
	@des 	:按钮设置可见
	@param 	:
	@return :
--]]
function visibleMethod()
	_previewMenuItem:setVisible(true)
	_rewardMenuItem:setVisible(true)
	_quickMenuItem:setVisible(true)
	_goBackMenuItem:setVisible(true)
end

--[[
	@des 	:按钮不设置可见
	@param 	:
	@return :
--]]
function unvisibleMethod()
	_previewMenuItem:setVisible(false)
	_rewardMenuItem:setVisible(false)
	_quickMenuItem:setVisible(false)
	_goBackMenuItem:setVisible(false)
end

--[[
	@des 	:创建描述node
	@param 	:
	@return :
--]]
function createDesNode()
	--花色名称图片
	local flowerSprite = CCSprite:create("images/replaceskill/newflip/flower/" .. _curFlower .. ".png")
	flowerSprite:setAnchorPoint(ccp(0.5,0.5))
	flowerSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*545/960))
	flowerSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(flowerSprite,2,kSpriteTag)
	--花色描述文字
	local desLabel = CCLabelTTF:create("（" .. _desTable[_curFlower] .. "）",g_sFontPangWa,21)
	desLabel:setColor(ccc3(0xff,0xf6,0x00))
	desLabel:setAnchorPoint(ccp(0.5,0.5))
	desLabel:setPosition(ccp(g_winSize.width/2,g_winSize.height*505/960))
	desLabel:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(desLabel,2,kDesTag)
	--亲密度文字
	local honeyLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1098"),g_sFontPangWa,21)
	honeyLabel:setColor(ccc3(0xe4,0x00,0xff))
	--加的亲密度数值
	local addNumLabel = CCLabelTTF:create("+" .. _monkeryNum,g_sFontPangWa,21)
	addNumLabel:setColor(ccc3(0x00,0xff,0x18))

	--创建 牌型（描述）亲密度 +XXX 的node
	local connectNode = BaseUI.createHorizontalNode({honeyLabel,addNumLabel})
	connectNode:setAnchorPoint(ccp(0.5,0.5))
	connectNode:setPosition(ccp(g_winSize.width/2,g_winSize.height*465/960))
	connectNode:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(connectNode,2,kKissTag)
end

--[[
	@des 	:清除卡牌和卡牌名字
	@param 	:
	@return :
--]]
function removeCardAndName()
	for i = 1,5 do
		_bgLayer:removeChildByTag(kCardTag + i,true)
		_bgLayer:removeChildByTag(kNameTag + i,true)
	end
end

--[[
	@des 	:翻牌特效结束后回调
	@param 	:
	@return :
--]]
function drawOverCallBack()
	--按钮显示
	visibleMethod()
	--创建描述node
	createDesNode()
end

--[[
	@des 	:创建五个卡牌和相应的名字
	@param 	:卡牌和名字是否可见，默认为可见
	@return :
--]]
function createFiveCardAndName(p_visible)
	local visible = p_visible or false

	--创建牌型	
	for i = 1,5 do
		--当前卡牌id
		local cardId = tonumber(_remainTable[i + 1])
		--卡牌图片
		local cardSprite = CCSprite:create("images/replaceskill/newflip/cardback.png")
		cardSprite:setAnchorPoint(ccp(0.5,0.5))
		cardSprite:setPosition(ccp(g_winSize.width*_xPosTable[i],g_winSize.height*_yPosTable[i]))
		cardSprite:setScale(g_fElementScaleRatio)
		cardSprite:setVisible(visible)
		_bgLayer:addChild(cardSprite,2,kCardTag + i)

		local personSprite = CCSprite:create("images/replaceskill/newflip/cardface/" .. cardId .. ".jpg")
		personSprite:setAnchorPoint(ccp(0.5,0.5))
		personSprite:setPosition(ccp(cardSprite:getContentSize().width/2,cardSprite:getContentSize().height/2))
		personSprite:setScale(0.43)
		-- cardSprite:setVisible(visible)
		-- _bgLayer:addChild(cardSprite,1,kCardTag + i)
		cardSprite:addChild(personSprite,1,i)

		--卡牌名字
		local cardName = CCLabelTTF:create(_nameTable[cardId],g_sFontPangWa,21)
		cardName:setColor(ccc3(0xff,0xff,0xff))
		cardName:setPosition(ccp(g_winSize.width*_xPosTable[i],g_winSize.height*_namePosTable[i]))
		cardName:setAnchorPoint(ccp(0.5,0.5))
		cardName:setScale(g_fElementScaleRatio)
		cardName:setVisible(visible)
		_bgLayer:addChild(cardName,2,kNameTag + i)
	end
end

--[[
	@des 	:创建卡牌背面图
	@param 	:
	@return :
--]]
function createCardBack()
	for i = 1,5 do
		--卡牌图片
		local cardSprite = CCSprite:create("images/replaceskill/newflip/cardback.png")
		cardSprite:setAnchorPoint(ccp(0.5,0.5))
		cardSprite:setPosition(ccp(g_winSize.width*_xPosTable[i],g_winSize.height*_yPosTable[i]))
		cardSprite:setVisible(false)
		_bgLayer:addChild(cardSprite,2,kBackTag + i)
	end
end

--[[
	@des 	:删除描述node
	@param 	:
	@return :
--]]
function deleteDesNode()
	for i = 1,3 do
		_bgLayer:removeChildByTag(i,true)
	end
end

--[[
	@des 	:创建落牌动画
	@param 	:位置index
	@return :
--]]
function createDownAnimation(p_pos)
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/luopai/luopai"), -1,CCString:create(""))
	spellEffectSprite:setPosition(ccp(g_winSize.width*_xPosTable[p_pos],g_winSize.height*_yPosTable[p_pos]))
    spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
    spellEffectSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(spellEffectSprite,9999)

    local animationEnd = function(actionName,xmlSprite)
   		spellEffectSprite:retain()
		spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)

        --翻牌
        flipCardAction(p_pos)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    spellEffectSprite:setDelegate(delegate)
end

--[[
	@des 	:翻牌
	@param 	:位置index
	@return :
--]]
function flipCardAction(p_pos)
	--翻牌所需的秒数
	local flipSec = 0.2	
	--卡牌背面
	local cardBackSprite = tolua.cast(_bgLayer:getChildByTag(kBackTag + p_pos),"CCSprite")
	--卡牌正面
	local cardFaceSprite = tolua.cast(_bgLayer:getChildByTag(kCardTag + p_pos),"CCSprite")

	--卡背面可见
	cardBackSprite:setVisible(true)

	local array = CCArray:create()
	array:addObject(CCOrbitCamera:create(flipSec, 1, 0, 0, 90, 0, 0))
	array:addObject(CCCallFunc:create(function()
		--背面不可见
		cardBackSprite:setVisible(false)

		--正面可见
		cardFaceSprite:setVisible(true)

		--要翻转过来的动画
		local frontArray = CCArray:create()
		frontArray:addObject(CCOrbitCamera:create(flipSec, 1, 0, 270, 90, 0, 0))

		frontArray:addObject(CCCallFunc:create(function()
			tolua.cast(_bgLayer:getChildByTag(kNameTag + p_pos),"CCLabelTTF"):setVisible(true)
			--如果是最后一张牌
			if p_pos == 5 then
				--创建文字描述node
				createDesNode()
				--按钮显示可见
				visibleMethod()

				--处理黄光和绿光的背景特效位置
				dealAnimatePos(_remainTable)
				--创建红光绿光特效
				createAroundAnimate()
			end
		end))
		--如果有回调函数，则调取回调函数
		cardFaceSprite:runAction(CCSequence:create(frontArray))
	end))
	cardBackSprite:runAction(CCSequence:create(array))
end

--[[
	@des 	:创建五张牌落地的动画效果（都放到这个方法里了）
	@param 	:
	@return :
--]]
function createInterAnimation()
	--先创建，但不显示，方便加特效用
	createFiveCardAndName()
	--牌落地时间间隔
	local gapTime = 0
	
	--五张牌落地
	for i = 1,5 do
		local array = CCArray:create()
		--加入牌和牌之间的间隔时间
		array:addObject(CCDelayTime:create(gapTime))
		array:addObject(CCCallFunc:create(function()
			--播放相应位置的特效
			createDownAnimation(i)
		end))
		--对于相应的牌，运行特效
		tolua.cast(_bgLayer:getChildByTag(kBackTag + i),"CCSprite"):runAction(CCSequence:create(array))
		--增加间隔时间
		gapTime = gapTime + 0.2
	end
end

--[[
	@des 	:爆炸特效
	@param 	:
	@return :
--]]
function createBombAnimation()
	for i = 1,5 do
		local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/baokai/baokai"), -1,CCString:create(""))
		spellEffectSprite:setPosition(ccp(g_winSize.width*_xPosTable[i],g_winSize.height*_yPosTable[i]))
	    spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
	    spellEffectSprite:setScale(g_fElementScaleRatio)
	    _bgLayer:addChild(spellEffectSprite,9999)

	    local animationEnd = function(actionName,xmlSprite)
	        if i == 5 then
	        	_bgLayer:setVisible(false)
	        end
	        xmlSprite:retain()
			xmlSprite:autorelease()
			createParticleEffect(i, xmlSprite)
			xmlSprite:removeFromParentAndCleanup(true)
	    end

	    local animationFrameChanged = function(frameIndex,xmlSprite)
	    end

	    local delegate = BTAnimationEventDelegate:create()
	    delegate:registerLayerEndedHandler(animationEnd)
	    delegate:registerLayerChangedHandler(animationFrameChanged)
	    
	    spellEffectSprite:setDelegate(delegate)
	end
end

--[[
	@des 	:创建粒子爆
	@param 	:
	@return :
--]]
function createParticleEffect(index, csObj)
	math.randomseed(os.time()) 

	local particalNum = 60

	for i=1, particalNum do
		local csParticle=CCSprite:create("images/replaceskill/newflip/lizih.png")
		local x=g_winSize.width*_xPosTable[index] + math.random(-117,117)*g_fElementScaleRatio
		local y=g_winSize.height*_yPosTable[index] + math.random(-135,135)*g_fElementScaleRatio
		csParticle:setPosition(x, y)
		csParticle:setScale(g_fElementScaleRatio*math.random()*2)
		csParticle:setOpacity(math.random(0,255))
		_scene:addChild(csParticle)
		local arrActions = CCArray:create()
		--arrActions:addObject(CCDelayTime:create(math.random()))
		--arrActions:addObject(CCMoveTo:create(1.0, ccp(g_winSize.width*160/640*g_fScaleX, g_winSize.height*480/960*g_fScaleX)))
		arrActions:addObject(CCMoveTo:create(1.0, ccp(170*g_fScaleX, 380*g_fScaleX + MenuLayer.getLayerContentSize().height*g_fScaleX)))
		--arrActions:addObject(CCDelayTime:create(math.random()))
		local g_y
		local g_x
		-- if (i%2 == 0) then
		-- g_y = g_winSize.height*480/960 + math.random(-110,110)*g_fElementScaleRatio
		-- g_x = g_winSize.width*180/640 + math.random(-120,40)*g_fElementScaleRatio
		-- arrActions:addObject(CCMoveTo:create(0.1, ccp(g_x, g_y)))
		--arrActions:addObject(CCDelayTime:create(1.1))
		-- else
		-- 	g_y = g_winSize.height*480/960 + math.random(-110,110)*g_fElementScaleRatio
		-- 	g_x = g_winSize.width*460/640 + math.random(-40,120)*g_fElementScaleRatio
		-- 	arrActions:addObject(CCMoveTo:create(0.1, ccp(g_x, g_y)))
		-- end
		arrActions:addObject(CCCallFuncN:create(function (obj)
			if index == 5 and i == particalNum then
				local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/baokai/baokai"), -1,CCString:create(""))
				spellEffectSprite:setPosition(ccp(170*g_fScaleX,380*g_fScaleX + MenuLayer.getLayerContentSize().height*g_fScaleX))
			    spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
			    spellEffectSprite:setScale(g_fElementScaleRatio)
			    _scene:addChild(spellEffectSprite,9999)

			    local animationEnd = function(actionName,xmlSprite)
			    	spellEffectSprite:retain()
					spellEffectSprite:autorelease()
			        spellEffectSprite:removeFromParentAndCleanup(true)

			        LevelUpUtil.showFlyText({{txt= GetLocalizeStringBy("zzh_1117"), num = _monkeryNum}})
					ReplaceSkillData.addCurStarFeel(_monkeryNum)
					require "script/ui/replaceSkill/learnSkill/LearnSkillLayer"
					LearnSkillLayer.buttomSure()

					closeCallBack()
			  --       if i == 5 then
			  --       	closeCallBack()
			  --       end
			  --       xmlSprite:retain()
					-- xmlSprite:autorelease()
					-- createParticleEffect(i, xmlSprite)
					-- xmlSprite:removeFromParentAndCleanup(true)
			    end

			    local animationFrameChanged = function(frameIndex,xmlSprite)
			    end

			    local delegate = BTAnimationEventDelegate:create()
			    delegate:registerLayerEndedHandler(animationEnd)
			    delegate:registerLayerChangedHandler(animationFrameChanged)
			    
			    spellEffectSprite:setDelegate(delegate)
			end
			obj:removeFromParentAndCleanup(true)
		end))
		local sequence = CCSequence:create(arrActions)
		csParticle:runAction(sequence)
	end
end

--[[
	@des 	:恭喜主公亲密度漂浮文字
	@param 	:$ p_name 主公名字
	@param 	:$ p_lv 亲密等级
	@return :
--]]
function showFLyTip(p_name,p_lv)
	local conLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1118"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	conLabel:setColor(ccc3(0x76,0xfc,0x06))

	local heroNameLable = CCRenderLabel:create(p_name,g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	heroNameLable:setColor(ccc3(0xe4,0x00,0xff))

	local honeyLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1119") .. p_lv,g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	honeyLabel:setColor(ccc3(0x76,0xfc,0x06))

	local heartSprite = CCSprite:create("images/replaceskill/affinity.png")

	local allNode = BaseUI.createHorizontalNode({conLabel,heroNameLable,honeyLabel,heartSprite})
	allNode:setScale( g_fElementScaleRatio)
	allNode:setAnchorPoint(ccp(0.5,0.5))
	allNode:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	allNode:setVisible(false)
	CCDirector:sharedDirector():getRunningScene():addChild(allNode,2013)

	local nextMoveToP = ccp(g_winSize.width*0.5, g_winSize.height*0.68)

	local actionArr = CCArray:create()
	actionArr:addObject(CCDelayTime:create(1.0))
	--actionArr:addObject(CCFadeIn()) 
	actionArr:addObject(CCCallFuncN:create(function ( ... )
		allNode:setVisible(true)
	end))
	actionArr:addObject(CCEaseOut:create(CCMoveTo:create(1.3, nextMoveToP),2))
	--actionArr:addObject(CCDelayTime:create(0.2))
	actionArr:addObject(CCFadeOut:create(0.2))
	actionArr:addObject(CCCallFuncN:create(function()
		allNode:removeFromParentAndCleanup(true)
		allNode = nil
	end))

	allNode:runAction(CCSequence:create(actionArr))
end

--[[
	@des 	:装备技能后弹出的漂浮文字
	@param 	:技能名字
	@return :
--]]
function getSkillTip(p_skillName)
	local conLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1131"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	conLabel:setColor(ccc3(0x76,0xfc,0x06))
	local nameLabel = CCRenderLabel:create(p_skillName,g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	nameLabel:setColor(ccc3(0xe4,0x00,0xff))

	local allNode = BaseUI.createHorizontalNode({conLabel,nameLabel})
	allNode:setScale( g_fElementScaleRatio)
	allNode:setAnchorPoint(ccp(0.5,0.5))
	allNode:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	allNode:setVisible(false)
	CCDirector:sharedDirector():getRunningScene():addChild(allNode,2013)

	local nextMoveToP = ccp(g_winSize.width*0.5, g_winSize.height*0.68)

	local actionArr = CCArray:create()
	actionArr:addObject(CCDelayTime:create(1.0))
	--actionArr:addObject(CCFadeIn()) 
	actionArr:addObject(CCCallFuncN:create(function ( ... )
		allNode:setVisible(true)
	end))
	actionArr:addObject(CCEaseOut:create(CCMoveTo:create(1.3, nextMoveToP),2))
	--actionArr:addObject(CCDelayTime:create(0.2))
	actionArr:addObject(CCFadeOut:create(0.2))
	actionArr:addObject(CCCallFuncN:create(function()
		allNode:removeFromParentAndCleanup(true)
		allNode = nil
	end))

	allNode:runAction(CCSequence:create(actionArr))
end

--[[
	@des 	:处理那些地方放红光，哪些地方放绿光
			 看不懂可以问Zhang Zihang
	@param 	:信息table
	@return :
--]]
function dealAnimatePos(p_cardTable)
	if table.isEmpty(p_cardTable) then
		return
	else
		local cardKind = tonumber(p_cardTable[1])
		local dealTable = {
							[1] = {},
							[2] = {},
							[3] = {},
							[4] = {},
						  }
		--如果不是5个相同或者没有相同
		if (cardKind ~= 1) and (cardKind ~= 7) then
			local beginPos = 1
			for i = 1,5 do
				local heroId = p_cardTable[i + 1]
				for j = 1,4 do
					if table.isEmpty(dealTable[j]) then
						table.insert(dealTable[j],i)
						break
					elseif heroId == p_cardTable[dealTable[j][1] + 1] then
						table.insert(dealTable[j],i)
						break
					end
				end
			end
		end

		--如果五个相同
		if (cardKind == 1) then
			for i = 1,5 do
				table.insert(_redTable,i)
			end
		--如果四个相同
		elseif cardKind == 2 then
			for i = 1,2 do
				if table.count(dealTable[i]) == 4 then
					_redTable = dealTable[i]
					break
				end
			end
		--如果3个相同+2个相同
		elseif cardKind == 3 then
			for i = 1,2 do
				if table.count(dealTable[i]) == 3 then
					_redTable = dealTable[i]
				elseif table.count(dealTable[i]) == 2 then
					_greenTable = dealTable[i]
				end
			end
		--如果3个相同
		elseif cardKind == 4 then
			for i = 1,3 do
				if table.count(dealTable[i]) == 3 then
					_redTable = dealTable[i]
					break
				end
			end
		--如果两对儿相同
		elseif cardKind == 5 then
			local haveOne = false
			for i = 1,3 do
				if table.count(dealTable[i]) == 2 then
					if haveOne == false then
						_redTable = dealTable[i]
					else
						_greenTable = dealTable[i]
						break
					end
					haveOne = true
				end
			end
		--如果一对儿相同
		elseif cardKind == 6 then
			for i = 1,4 do
				if table.count(dealTable[i]) == 2 then
					_redTable = dealTable[i]
					break
				end
			end
		end
	end
end

--[[
	@des 	:创建红光和绿光特效
	@param 	:
	@return :
--]]
function createAroundAnimate()
	for k,v in pairs(_redTable) do
		createShiningAnimate(1,tonumber(v))
	end

	for k,v in pairs(_greenTable) do
		createShiningAnimate(2,tonumber(v))
	end
end

--[[
	@des 	:创建红光或绿光特效
	@param 	:$ p_kind 光的种类 1为红光，2为绿光
			 $ p_pos 位置id
	@return :
--]]
function createShiningAnimate(p_kind,p_pos)
	local spellEffectSprite
	--红光
	if p_kind == 1 then
		spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/huangbei/huangbei"), -1,CCString:create(""))
	else
		spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/lvbei/lvbei"), -1,CCString:create(""))
	end
	spellEffectSprite:setPosition(ccp(g_winSize.width*_xPosTable[p_pos],g_winSize.height*_yPosTable[p_pos]))
    spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
    spellEffectSprite:setScale(g_fElementScaleRatio)
    if p_kind == 1 then
    	_bgLayer:addChild(spellEffectSprite,1,kRedTag + p_pos)
    else
    	_bgLayer:addChild(spellEffectSprite,1,kGreenTag + p_pos)
    end

    local animationEnd = function(actionName,xmlSprite)

    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    spellEffectSprite:setDelegate(delegate)
end

--[[
	@des 	:清除原有的红光和绿光特效
	@param 	:
	@return :
--]]
function deleteLightAnimation()
	--去除原来黄色和绿色的特效
	for k,v in pairs(_redTable) do
		tolua.cast(_bgLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):retain()
		tolua.cast(_bgLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):autorelease()
		tolua.cast(_bgLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):removeFromParentAndCleanup(true)
	end

	for k,v in pairs(_greenTable) do
		tolua.cast(_bgLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):retain()
		tolua.cast(_bgLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):autorelease()
		tolua.cast(_bgLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):removeFromParentAndCleanup(true)
	end
	
	--清空
	_redTable = {}
	_greenTable = {}
end

--[[
	@des 	:淡出效果
	@param 	:
	@return :
--]]
function fadeOutAction()
	for i = 1,5 do
		local array_1 = CCArray:create()
		array_1:addObject(CCFadeOut:create(1))

		local array_2 = CCArray:create()
		array_2:addObject(CCFadeOut:create(1))

		local array_3 = CCArray:create()
		array_3:addObject(CCFadeOut:create(1))

		local array_4 = CCArray:create()
		array_4:addObject(CCFadeOut:create(1))

		local array_5 = CCArray:create()
		array_5:addObject(CCFadeOut:create(1))

		_bgLayer:getChildByTag(kCardTag + i):runAction(CCSequence:create(array_1))
		_bgLayer:getChildByTag(kNameTag + i):runAction(CCSequence:create(array_2))
		_bgLayer:getChildByTag(kCardTag + i):getChildByTag(i):runAction(CCSequence:create(array_3))

		if _bgLayer:getChildByTag(kRedTag + i) ~= nil then
			tolua.cast(_bgLayer:getChildByTag(kRedTag + i),"CCLayerSprite"):runAction(CCSequence:create(array_4))
		end

		if _bgLayer:getChildByTag(kGreenTag + i) ~= nil then
			tolua.cast(_bgLayer:getChildByTag(kGreenTag + i),"CCLayerSprite"):runAction(CCSequence:create(array_5))
		end
	end
end