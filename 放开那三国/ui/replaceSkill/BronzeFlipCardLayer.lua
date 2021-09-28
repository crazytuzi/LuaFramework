-- Filename: BronzeFlipCardLayer.lua
-- Author: Zhang Zihang
-- Date: 2014-08-08
-- Purpose: 创建铜雀翻牌层

module("BronzeFlipCardLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/ui/tip/AnimationTip"
require "script/utils/BaseUI"
require "script/ui/hero/HeroPublicCC"
require "script/ui/replaceSkill/ReplaceSkillData"
require "script/model/user/UserModel"
require "script/ui/replaceSkill/ReplaceSkillService"
require "script/ui/tip/LackGoldTip"

local _touchPriority
local _zOrder
local _baseLayer 			--基础层
local _bgMenu 				--背景按钮层
local _flipNum 				--扣牌次数（因为规则是最多扣4张）
local _cardIndexTable       --记录扣牌的位置id
local _flipMenuItem 		--开始翻牌按钮
local _haveChange			--记录是否已经更换
local _totalMNumLabel 		--当日获得的总修行值label
local _monkeryNum 			--翻牌获得修行值
local _monkeryNumLabel 		--翻牌结束获得的修行值label
local _curFlower 			--当前花色
local _isQuitWithOut 		--是否未领奖退出
local _flipGoldLabel 		--翻牌消耗金币label
local _animateSprite 		--特效图
local _redTable 			--红色特效需要的地方
local _greenTable 			--绿色特效需要的地方
local _flipSecond = 0.2		--翻牌需要的秒数
local kMenuTag = 1000 		--按钮tag
local kBackCardTag = 1500 	--卡牌背面按钮tag
local kGirlTag = 2000 		--众多妹纸卡牌tag
local kBackTipTag = 2500 	--未翻牌时的提示tag
local kMidSpriteTag = 3000 	--中间图标tag
local kRedTag = 3500 		--红色下标
local kGreenTag = 4000		--绿色下标

--五个卡牌的位置
-- 			1
-- 	5 				2
-- 		4 		3
--卡牌横坐标位置表
local cardXTable = {
						[1] = 0.5,
						[2] = 540/640,
						[3] = 465/640,
						[4] = 175/640,
						[5] = 100/640,
				   }
--卡牌纵坐标位置表
local cardYTable = {
						[1] = 630/960,
						[2] = 450/960,
						[3] = 160/960,
						[4] = 160/960,
						[5] = 450/960,
				   }
--花型特效路径
local effectPathTable = {
							[1] = "images/base/effect/qingguoqingcheng/qingguoqingcheng",
							[2] = "images/base/effect/fenghuajuedai/fenghuajuedai",
							[3] = "images/base/effect/guosetianxiang/guosetianxiang",
							[4] = "images/base/effect/hongfenjiaren/hongfenjiaren",
							[5] = "images/base/effect/baihuazhengyan/baihuazhengyan",
							[6] = "images/base/effect/sanhuajuding/sanhuajuding",
							[7] = "images/base/effect/shuangshushuangfei/shuangshushuangfei",
							[8] = "images/base/effect/jiemeiqingsheng/jiemeiqingsheng",
						}

----------------------------------------初始化函数----------------------------------------
local function init()
	_touchPriority = nil
	_zOrder = nil
	_baseLayer = nil
	_bgMenu = nil
	_flipMenuItem = nil
	_totalMNumLabel = nil
	_monkeryNumLabel = nil
	_curFlower = nil
	_flipGoldLabel = nil
	_animateSprite = nil
	_cardIndexTable = {}
	_redTable = {}
	_greenTable = {}
	_flipNum = 0
	_monkeryNum = 0
	_haveChange = false
	_isQuitWithOut = false
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
		_baseLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_baseLayer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_baseLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:五个按钮回调
	@param 	:按钮tag值
	@return :
--]]
function menuCallBack(tag)
	--返回按钮
	if tag == (kMenuTag + 1) then
		--如果未领奖就退出
		if _isQuitWithOut then
			ReplaceSkillData.addRemainData(_cardTidTable,_haveChange)
		end

		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_baseLayer:removeFromParentAndCleanup(true)
		_baseLayer = nil
	end
	
	--翻牌规则按钮
	if tag == (kMenuTag + 2) then
		require "script/ui/replaceSkill/CardIntroductionLayer"
		CardIntroductionLayer.showLayer(-600,1000)
	end
	
	--牌型奖励按钮
	if tag == (kMenuTag + 3) then
		require "script/ui/replaceSkill/ReplaceSkillRewardLayer"
		ReplaceSkillRewardLayer.showLayer(-600,1000)
	end

	--更换卡牌按钮
	if tag == (kMenuTag + 4) then
		--如果已经翻过牌了
		if _haveChange == true then
			AnimationTip.showTip(GetLocalizeStringBy("zzh_1082"))
		--如果没有选择要翻的牌
		elseif table.isEmpty(_cardIndexTable) then
			AnimationTip.showTip(GetLocalizeStringBy("zzh_1081"))
		else
			local shuffleCallBack = function(ret)	
				--更换卡牌封面
				changeCardGirl(ret)

				--存储当前翻到的花型
				_cardTidTable = ret

				--减金币
				UserModel.addGoldNumber(tonumber(-ReplaceSkillData.getResetCardGold(_flipNum)))

				--去除原来黄色和绿色的特效
				for k,v in pairs(_redTable) do
					tolua.cast(_baseLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):retain()
					tolua.cast(_baseLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):autorelease()
					tolua.cast(_baseLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):removeFromParentAndCleanup(true)
				end

				for k,v in pairs(_greenTable) do
					tolua.cast(_baseLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):retain()
					tolua.cast(_baseLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):autorelease()
					tolua.cast(_baseLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):removeFromParentAndCleanup(true)
				end
				
				--清空
				_redTable = {}
				_greenTable = {}

				--根据新牌型处理黄光和绿光特效
				dealAnimatePos(ret)

				--牌旋转过程中上面3个按钮不可点击
				for i = 1,3 do
					local topMenuItem = tolua.cast(_bgMenu:getChildByTag(kMenuTag + i),"CCMenuItemImage")
					topMenuItem:setEnabled(false)
				end

				--按钮不可点击
				tolua.cast(_bgMenu:getChildByTag(kMenuTag + 4),"CCMenuItemSprite"):setEnabled(false)
				tolua.cast(_bgMenu:getChildByTag(kMenuTag + 5),"CCMenuItemSprite"):setEnabled(false)
				_baseLayer:removeChildByTag(kMidSpriteTag,true)
				_baseLayer:getChildByTag(kBackTipTag + 7):setVisible(false)
				_baseLayer:getChildByTag(kBackTipTag + 8):setVisible(false)

				--当前花色
				_curFlower = ret[1]
				_monkeryNum = ReplaceSkillData.getHonorNumById(tonumber(ret[1]))

				for i = 1,#_cardIndexTable do
					--调用动作效果
					if i == #_cardIndexTable then 
						createOpenAnimation(tolua.cast(_baseLayer:getChildByTag(_cardIndexTable[i] - kGirlTag + kBackCardTag),"CCSprite"),
											tolua.cast(_bgMenu:getChildByTag(_cardIndexTable[i]),"CCMenuItemSprite"),nil,resetCallBack)
					else
						createOpenAnimation(tolua.cast(_baseLayer:getChildByTag(_cardIndexTable[i] - kGirlTag + kBackCardTag),"CCSprite"),
											tolua.cast(_bgMenu:getChildByTag(_cardIndexTable[i]),"CCMenuItemSprite"))
					end
				end

				-- for i = 1,5 do
				-- 	local frontMenuItem = tolua.cast(_bgMenu:getChildByTag(kGirlTag + i),"CCMenuItemSprite")
				-- 	frontMenuItem:setEnabled(false)
				-- end

				--扣过牌了
				_haveChange = true

				_isQuitWithOut = true

				--已选中卡牌清空
				_cardIndexTable = {}
			end
			--没钱别重置
			if UserModel.getGoldNumber() < ReplaceSkillData.getResetCardGold(_flipNum) then
				LackGoldTip.showTip()
			else
				ReplaceSkillService.shuffle(shuffleCallBack,_cardIndexTable,kGirlTag)
			end
		end
	end

	--领取奖励按钮
	if tag == (kMenuTag + 5) then
		local getRewardCallBack = function()	
			--去除原来黄色和绿色的特效
			for k,v in pairs(_redTable) do
				tolua.cast(_baseLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):retain()
				tolua.cast(_baseLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):autorelease()
				tolua.cast(_baseLayer:getChildByTag(kRedTag + v),"CCLayerSprite"):removeFromParentAndCleanup(true)
			end

			for k,v in pairs(_greenTable) do
				tolua.cast(_baseLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):retain()
				tolua.cast(_baseLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):autorelease()
				tolua.cast(_baseLayer:getChildByTag(kGreenTag + v),"CCLayerSprite"):removeFromParentAndCleanup(true)
			end
			
			--清空
			_redTable = {}
			_greenTable = {}

			--翻拍过程中5个按钮都不可点击
			for i = 1,5 do
				local topMenuItem = tolua.cast(_bgMenu:getChildByTag(kMenuTag + i),"CCMenuItemImage")
				topMenuItem:setEnabled(false)
			end

			--增加当日修行值
			ReplaceSkillData.addCurDayMonkery(_monkeryNum)
			--增加武将个人修行值
			if ReplaceSkillData.addCurStarFeel(_monkeryNum) then
				--如果增加了修行值宗师升级了
				AnimationTip.showTip(GetLocalizeStringBy("key_1248") .. _monkeryNum .. GetLocalizeStringBy("zzh_1085") .. "，" .. GetLocalizeStringBy("zzh_1095") .. ReplaceSkillData.getCurFeelLv())
			else
				AnimationTip.showTip(GetLocalizeStringBy("key_1248") .. _monkeryNum .. GetLocalizeStringBy("zzh_1085"))
			end
			--今日翻牌获得修行值增加
			_totalMNumLabel:setString(ReplaceSkillData.getCurDayMonkery())

			for i = 1,5 do
				if i == 5 then
					createOpenAnimation(tolua.cast(_bgMenu:getChildByTag(kGirlTag + i),"CCMenuItemSprite"),
									tolua.cast(_baseLayer:getChildByTag(kBackCardTag + i),"CCSprite"),nil,getRewardCallBack)
				else
					createOpenAnimation(tolua.cast(_bgMenu:getChildByTag(kGirlTag + i),"CCMenuItemSprite"),
									tolua.cast(_baseLayer:getChildByTag(kBackCardTag + i),"CCSprite"))
				end

				tolua.cast(_bgMenu:getChildByTag(kGirlTag + i),"CCMenuItemSprite"):setEnabled(true)
			end

			--因为领奖了，所以不会存在没领奖就退出的情况了
			_isQuitWithOut = false
		end
		--如果加了修行值没有超过主角等级
		--如果超了，checkBeyondLevel函数里会弹提示
		if not ReplaceSkillData.checkBeyondLevel(_monkeryNum) then
			--如果有扣下的牌，则代表还没有重置就要翻牌，这是不允许的
			if not table.isEmpty(_cardIndexTable) then
				AnimationTip.showTip(GetLocalizeStringBy("zzh_1091"))
			else
				ReplaceSkillService.getReward(getRewardCallBack)
			end
		end
	end
end

--[[
	@des 	:翻牌开始游戏回调
	@param 	:
	@return :
--]]
function dieCallBack()
	local drawCallBack = function(dictData)
		--记录下当前翻到的牌型	
		_cardTidTable = dictData.ret

		_monkeryNum = ReplaceSkillData.getHonorNumById(tonumber(_cardTidTable[1]))

		_curFlower = tonumber(_cardTidTable[1])

		--处理黄光和绿光的特效
		dealAnimatePos(_cardTidTable)

		--如果免费次数用光了
		if ReplaceSkillData.getFreeFlipNum() == 0 then
			--减金币
			UserModel.addGoldNumber(tonumber(-ReplaceSkillData.getUseGoldNum()))
		end

		--加一次翻牌次数
		ReplaceSkillData.addFlipNum()
		--刷新剩余翻牌次数显示
		tolua.cast(_baseLayer:getChildByTag(kBackTipTag + 3),"CCLabelTTF"):setString(ReplaceSkillData.getFreeFlipNum())
		tolua.cast(_baseLayer:getChildByTag(kBackTipTag + 4),"CCLabelTTF"):setString(ReplaceSkillData.getGoldFilpNum())

		--建立5个卡牌正面
		for i = 1,5 do
			--卡牌正面
			local frontGirlSprite = HeroPublicCC.createSpriteCardShow(tonumber(_cardTidTable[i + 1]))
			local girlMenuItem = CCMenuItemSprite:create(frontGirlSprite,frontGirlSprite)
			girlMenuItem:setAnchorPoint(ccp(0.5,0))
			girlMenuItem:setPosition(ccp(g_winSize.width*cardXTable[i],g_winSize.height*cardYTable[i]))
			girlMenuItem:setScale(0.5*g_fElementScaleRatio)
			girlMenuItem:registerScriptTapHandler(flipCallBack)
			girlMenuItem:setVisible(false)
			girlMenuItem:setEnabled(false)
			_bgMenu:addChild(girlMenuItem,1,kGirlTag + i)
		end

		--翻牌间隔时间
		local gapTime = 0

		--不允许点击翻牌
		_flipMenuItem:setEnabled(false)

		for i = 1,3 do
			local topMenuItem = tolua.cast(_bgMenu:getChildByTag(kMenuTag + i),"CCMenuItemImage")
			topMenuItem:setEnabled(false)
		end

		--五个牌全部展开
		for i = 1,5 do
			--要翻过去的object
			local turnOverObj = tolua.cast(_baseLayer:getChildByTag(kBackCardTag + i),"CCSprite")
			--要反过来的object
			local turnBackObj = tolua.cast(_bgMenu:getChildByTag(kGirlTag + i),"CCMenuItemSprite")

			--调用动作效果
			if i ~= 5 then
				createOpenAnimation(turnOverObj,turnBackObj,gapTime)
			else
				createOpenAnimation(turnOverObj,turnBackObj,gapTime,dieOverCallBack)
			end

			gapTime = gapTime + _flipSecond*2
		end

		--如果翻牌了，还没领的时候存在没领就退出的可能性，所以先记录下，领了奖再置为false
		--传说中的加锁操作
		_isQuitWithOut = true
	end

	--如果没有翻牌次数了
	if ReplaceSkillData.getFreeFlipNum() + ReplaceSkillData.getGoldFilpNum() <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1084"))
	--如果使用金币翻牌，还没钱了
	elseif (ReplaceSkillData.getFreeFlipNum() == 0) and (UserModel.getGoldNumber() < ReplaceSkillData.getUseGoldNum()) then
		LackGoldTip.showTip()
	--如果满级了
	elseif ReplaceSkillData.isFullExp() then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1086"))
	else
		ReplaceSkillService.draw(drawCallBack)
	end
end

--[[
	@des 	:扣牌回调
	@param 	:点击的tag值
	@return :
--]]
function flipCallBack(tag)
	--扣牌次数加1
	if _haveChange == true then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1082"))
		return
	end

	_flipNum = _flipNum + 1
	--规则是最多扣牌4次
	if _flipNum < 5 then
		--调用动作效果
		createOpenAnimation(tolua.cast(_bgMenu:getChildByTag(tag),"CCMenuItemSprite"),
							tolua.cast(_baseLayer:getChildByTag(tag - kGirlTag + kBackCardTag),"CCSprite"))
		--记录下扣的牌
		table.insert(_cardIndexTable,tag)

		if _baseLayer:getChildByTag(kRedTag + tag - kGirlTag) ~= nil then
			tolua.cast(_baseLayer:getChildByTag(kRedTag + tag - kGirlTag),"CCLayerSprite"):setVisible(false)
		end
		if _baseLayer:getChildByTag(kGreenTag + tag - kGirlTag) ~= nil then
			tolua.cast(_baseLayer:getChildByTag(kGreenTag + tag - kGirlTag),"CCLayerSprite"):setVisible(false)
		end

		_goldNumLabel:setString(ReplaceSkillData.getResetCardGold(_flipNum))
	else
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1073"))
		--翻牌次数不能超过4，防止多动症玩家在那里没事瞎点 - - ！
		_flipNum = 4
	end
end

--[[
	@des 	:翻牌结束后回调
	@param 	:
	@return :
--]]
function dieOverCallBack()
	--翻牌按钮不可见
	_flipMenuItem:setVisible(false)

	for k,v in pairs(_redTable) do
		createShiningAnimate(1,tonumber(v))
	end

	for k,v in pairs(_greenTable) do
		createShiningAnimate(2,tonumber(v))
	end

	if tonumber(_curFlower) ~= 9 then 
		createFlipAnimate(dieAnimateFunction)
	else
		dieAnimateFunction()
	end

	_monkeryNumLabel:setString("+" .. _monkeryNum)
end

--[[
	@des 	:领奖后回调
	@param 	:
	@return :
--]]
function getRewardCallBack()
	--翻牌按钮可见
	_flipMenuItem:setVisible(true)
	_flipMenuItem:setEnabled(true)

	_baseLayer:removeChildByTag(kMidSpriteTag,true)

	if ReplaceSkillData.getFreeFlipNum() == 0 then
		if _flipGoldLabel == nil then
			_flipGoldLabel = CCLabelTTF:create(ReplaceSkillData.getUseGoldNum(),g_sFontPangWa,21)
			_flipGoldLabel:setColor(ccc3(0xff,0xf6,0x00))

			local flipGoldSprite = CCSprite:create("images/common/gold.png")

			local goldNode = BaseUI.createHorizontalNode({_flipGoldLabel,flipGoldSprite})
			goldNode:setAnchorPoint(ccp(0.5,0))
			goldNode:setPosition(ccp(_flipMenuItem:getContentSize().width/2,20))
			_flipMenuItem:addChild(goldNode)
		else
			_flipGoldLabel:setString(ReplaceSkillData.getUseGoldNum())
		end
	end

	--底部两个按钮不显示
	--删除五个卡牌
	for i = 1,5 do
		local topMenuItem = tolua.cast(_bgMenu:getChildByTag(kMenuTag + i),"CCMenuItemSprite")

		--底部两个按钮不可见
		if i >= 4 then
			topMenuItem:setVisible(false)
		end

		topMenuItem:setEnabled(true)

		--删除背面的卡牌图像
		_bgMenu:removeChildByTag(kGirlTag + i,true)
	end

	--提示显示问题
	for i = 1,8 do
		local beginTipLabel = _baseLayer:getChildByTag(kBackTipTag + i)

		if i >= 5 then
			beginTipLabel:setVisible(false)
		else
			beginTipLabel:setVisible(true)
		end
	end

	--是否已改变牌置为false
	_haveChange = false
	--累计改变牌数量变为0
	_flipNum = 0

	--充值所需金币置为0
	_goldNumLabel:setString("0")
end

--[[
	@des 	:重置卡牌后回调
	@param 	:
	@return :
--]]
function resetCallBack()
	for k,v in pairs(_redTable) do
		createShiningAnimate(1,tonumber(v))
	end

	for k,v in pairs(_greenTable) do
		createShiningAnimate(2,tonumber(v))
	end

	if tonumber(_curFlower) ~= 9 then 
		createFlipAnimate(resetAnimateFunction)
	else
		resetAnimateFunction()
	end
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建背景UI
	@param 	:
	@return :
--]]
function createBgUI()
	--是否翻了牌没有领取奖励
	local isRemainPrize = false
	--没有领取的牌型
	local remainTable = {}
	--如果后端返回的数据中该宗师翻了牌未领取
	if not table.isEmpty(ReplaceSkillData.remainRewardInfo()) then
		isRemainPrize = true
		remainTable = ReplaceSkillData.remainRewardInfo()
		_monkeryNum = ReplaceSkillData.getHonorNumById(tonumber(remainTable[1]))
	end

	--处理黄光和绿光的背景特效位置
	dealAnimatePos(remainTable)

	--创建主背景
	local bgSprite = CCSprite:create("images/replaceskill/flipcard/bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	bgSprite:setScale(g_fBgScaleRatio)
	_baseLayer:addChild(bgSprite)

	--背景按钮层
	_bgMenu = CCMenu:create()
	_bgMenu:setAnchorPoint(ccp(0,0))
	_bgMenu:setPosition(ccp(0,0))
	_bgMenu:setTouchPriority(_touchPriority - 1)
	_baseLayer:addChild(_bgMenu,2)

	--顶部三个按钮
	--坚持代码重用 恩 - - ！
	local menuImageeTable = {
								[1] = "images/common/close_btn_n.png",
								[2] = "images/common/close_btn_h.png",
								[3] = "images/replaceskill/flipcard/howtoplay_n.png",
								[4] = "images/replaceskill/flipcard/howtoplay_h.png",
								[5] = "images/replaceskill/flipcard/cardreward_n.png",
								[6] = "images/replaceskill/flipcard/cardreward_h.png",
							}
	for i = 1,3 do
		local curMenuItem = CCMenuItemImage:create(menuImageeTable[i*2 - 1], menuImageeTable[i*2])
		curMenuItem:setAnchorPoint(ccp(0.5,0.5))
		curMenuItem:setPosition(ccp(g_winSize.width*(640 - 50 - 120*(i - 1))/640,g_winSize.height*910/960))
		curMenuItem:setScale(g_fElementScaleRatio)
		curMenuItem:registerScriptTapHandler(menuCallBack)
		_bgMenu:addChild(curMenuItem,2,kMenuTag + i)
	end 

	--标题
	local gameTitleSprite = CCSprite:create("images/replaceskill/flipcard/fliptitle.png")
	gameTitleSprite:setAnchorPoint(ccp(0.5,0.5))
	gameTitleSprite:setPosition(ccp(g_winSize.width*100/640,g_winSize.height*910/960))
	gameTitleSprite:setScale(g_fElementScaleRatio)
	_baseLayer:addChild(gameTitleSprite)

	--中间的圈圈图
	local midQuanSprite = CCSprite:create("images/replaceskill/flipcard/midquan.png")
	midQuanSprite:setAnchorPoint(ccp(0.5,0.5))
	midQuanSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*465/960))
	midQuanSprite:setScale(g_fElementScaleRatio)
	_baseLayer:addChild(midQuanSprite)

	--开始翻牌按钮
	_flipMenuItem = CCMenuItemImage:create("images/replaceskill/flipcard/gotodie_n.png","images/replaceskill/flipcard/gotodie_h.png")
	_flipMenuItem:setAnchorPoint(ccp(0.5,0.5))
	_flipMenuItem:setPosition(ccp(g_winSize.width/2,g_winSize.height*465/960))
	_flipMenuItem:setScale(g_fElementScaleRatio)
	_flipMenuItem:setVisible(not isRemainPrize)
	_flipMenuItem:registerScriptTapHandler(dieCallBack)
	_bgMenu:addChild(_flipMenuItem)

	--金币图标
	--如果免费次数用光了用光了
	if ReplaceSkillData.getFreeFlipNum() == 0 then
		_flipGoldLabel = CCLabelTTF:create(ReplaceSkillData.getUseGoldNum(),g_sFontPangWa,21)
		_flipGoldLabel:setColor(ccc3(0xff,0xf6,0x00))

		local flipGoldSprite = CCSprite:create("images/common/gold.png")

		local goldNode = BaseUI.createHorizontalNode({_flipGoldLabel,flipGoldSprite})
		goldNode:setAnchorPoint(ccp(0.5,0))
		goldNode:setPosition(ccp(_flipMenuItem:getContentSize().width/2,20))
		_flipMenuItem:addChild(goldNode)
	end

	for k,v in pairs(_redTable) do
		createShiningAnimate(1,tonumber(v))
	end

	for k,v in pairs(_greenTable) do
		createShiningAnimate(2,tonumber(v))
	end

	for i = 1,5 do
		--圈
		local littleQuanSprite = CCSprite:create("images/replaceskill/flipcard/quan.png")
		littleQuanSprite:setAnchorPoint(ccp(0.5,0.5))
		littleQuanSprite:setPosition(ccp(g_winSize.width*cardXTable[i],g_winSize.height*cardYTable[i] + 110*g_fElementScaleRatio))
		littleQuanSprite:setScale(g_fElementScaleRatio*1.1)
		_baseLayer:addChild(littleQuanSprite)

		--卡牌背面
		local backCardSprite = CCSprite:create("images/shop/pub/card_opp.png")
		backCardSprite:setAnchorPoint(ccp(0.5,0))
		backCardSprite:setPosition(ccp(g_winSize.width*cardXTable[i],g_winSize.height*cardYTable[i]))
		backCardSprite:setScale(0.5*g_fElementScaleRatio)
		backCardSprite:setVisible(not isRemainPrize)
		_baseLayer:addChild(backCardSprite,4,kBackCardTag + i)

		if isRemainPrize then
			--卡牌正面
			local frontGirlSprite = HeroPublicCC.createSpriteCardShow(tonumber(remainTable[i + 1]))
			local girlMenuItem = CCMenuItemSprite:create(frontGirlSprite,frontGirlSprite)
			girlMenuItem:setAnchorPoint(ccp(0.5,0))
			girlMenuItem:setPosition(ccp(g_winSize.width*cardXTable[i],g_winSize.height*cardYTable[i]))
			girlMenuItem:setScale(0.5*g_fElementScaleRatio)
			girlMenuItem:registerScriptTapHandler(flipCallBack)
			_bgMenu:addChild(girlMenuItem,1,kGirlTag + i)

			--如果已经重置过了卡牌
			if tonumber(remainTable[7]) == 1 then
				--卡牌已经重置了
				_haveChange = true
				girlMenuItem:setEnabled(false)
			end
		end
	end

	--剩余提示
	local remainNameTable = {
								[1] = "zzh_1074",
								[2] = "zzh_1075",
							}

	--两行未翻牌时的剩余翻牌次数提示
	for i = 1,2 do
		local remainTipLabel = CCLabelTTF:create(GetLocalizeStringBy(remainNameTable[i]),g_sFontName,23)
		remainTipLabel:setColor(ccc3(0x00,0xff,0x18))
		remainTipLabel:setAnchorPoint(ccp(1,0))
		remainTipLabel:setPosition(ccp(g_winSize.width*400/640,g_winSize.height*(105 - 40*(i - 1))/960))
		remainTipLabel:setScale(g_fElementScaleRatio)
		remainTipLabel:setVisible(not isRemainPrize)
		_baseLayer:addChild(remainTipLabel,1,kBackTipTag + i)

		--剩余次数数字
		local remainNumLabel
		if i == 1 then
			remainNumLabel = CCLabelTTF:create(tostring(ReplaceSkillData.getFreeFlipNum()),g_sFontName,23)
		else
			remainNumLabel = CCLabelTTF:create(tostring(ReplaceSkillData.getGoldFilpNum()),g_sFontName,23)
		end
		remainNumLabel:setColor(ccc3(0xff,0xff,0xff))
		remainNumLabel:setAnchorPoint(ccp(0,0))
		remainNumLabel:setPosition(ccp(g_winSize.width*400/640,g_winSize.height*(105 - 40*(i - 1))/960))
		remainNumLabel:setScale(g_fElementScaleRatio)
		remainNumLabel:setVisible(not isRemainPrize)
		_baseLayer:addChild(remainNumLabel,1,kBackTipTag + i + 2)
	end

	--扣牌翻牌规则
	local flipTipLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1076"),g_sFontPangWa,23)
	flipTipLabel:setColor(ccc3(0x00,0xe4,0xff))
	flipTipLabel:setAnchorPoint(ccp(0.5,0))
	flipTipLabel:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*105/960))
	flipTipLabel:setScale(g_fElementScaleRatio)
	flipTipLabel:setVisible(isRemainPrize)
	_baseLayer:addChild(flipTipLabel,1,kBackTipTag + 5)

	--今日获得总修行值文字
	local totalMonkeryLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1077"),g_sFontPangWa,18)
	totalMonkeryLabel:setColor(ccc3(0xff,0xf6,0x00))
	_totalMNumLabel = CCLabelTTF:create(ReplaceSkillData.getCurDayMonkery(),g_sFontPangWa,18)
	_totalMNumLabel:setColor(ccc3(0x00,0xff,0x18))
	--修行node
	local totalNode = BaseUI.createHorizontalNode({totalMonkeryLabel,_totalMNumLabel})
	totalNode:setAnchorPoint(ccp(0.5,0))
	totalNode:setPosition(ccp(g_winSize.width/2,g_winSize.height*80/960))
	totalNode:setScale(g_fElementScaleRatio)
	totalNode:setVisible(isRemainPrize)
	_baseLayer:addChild(totalNode,1,kBackTipTag + 6)

	--更换卡牌按钮
	local changeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(250,75),"",ccc3(0xfe, 0xdb, 0x1c))
	changeMenuItem:setAnchorPoint(ccp(0.5,0))
	changeMenuItem:setPosition(ccp(g_winSize.width/4,g_winSize.height*10/960))
	changeMenuItem:setScale(g_fElementScaleRatio)
	changeMenuItem:registerScriptTapHandler(menuCallBack)
	changeMenuItem:setVisible(isRemainPrize)
	_bgMenu:addChild(changeMenuItem,1,kMenuTag + 4)
	--更换卡牌提示
	local changeLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1078"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	changeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	changeLabel:setAnchorPoint(ccp(0,0.5))
	changeLabel:setPosition(ccp(20,changeMenuItem:getContentSize().height/2))
	changeMenuItem:addChild(changeLabel)
	--更换卡牌所需金币数
	_goldNumLabel = CCLabelTTF:create("0",g_sFontPangWa,21)
	_goldNumLabel:setColor(ccc3(0xff,0xf6,0x00))
	_goldNumLabel:setAnchorPoint(ccp(0,0.5))
	_goldNumLabel:setPosition(ccp(165,changeMenuItem:getContentSize().height/2))
	changeMenuItem:addChild(_goldNumLabel)
	--金币图标
	local goldSprite = CCSprite:create("images/common/gold.png")
	goldSprite:setAnchorPoint(ccp(1,0.5))
	goldSprite:setPosition(ccp(changeMenuItem:getContentSize().width - 20,changeMenuItem:getContentSize().height/2))
	changeMenuItem:addChild(goldSprite)
	
	--领取奖励按钮
	local rewardMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("zz_31"),ccc3(0xfe, 0xdb, 0x1c))
	rewardMenuItem:setAnchorPoint(ccp(0.5,0))
	rewardMenuItem:setPosition(ccp(g_winSize.width*3/4,g_winSize.height*10/960))
	rewardMenuItem:setScale(g_fElementScaleRatio)
	rewardMenuItem:registerScriptTapHandler(menuCallBack)
	rewardMenuItem:setVisible(isRemainPrize)
	_bgMenu:addChild(rewardMenuItem,1,kMenuTag + 5)

	--当前牌型
	local curFlowerLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1079"),g_sFontPangWa,23)
	curFlowerLabel:setColor(ccc3(0xff,0xff,0xff))
	curFlowerLabel:setAnchorPoint(ccp(0.5,0))
	curFlowerLabel:setPosition(ccp(g_winSize.width/2,g_winSize.height*490/960))
	curFlowerLabel:setScale(g_fElementScaleRatio)
	curFlowerLabel:setVisible(isRemainPrize)
	_baseLayer:addChild(curFlowerLabel,1,kBackTipTag + 7)

	--如果翻了牌没有领取奖励，则根据当前牌型创建花色提示文字
	if isRemainPrize then
		local flowerSprite = CCSprite:create("images/replaceskill/flipcard/" .. remainTable[1] .. ".png")
		flowerSprite:setAnchorPoint(ccp(0.5,0.5))
		flowerSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*465/960))
		flowerSprite:setScale(g_fElementScaleRatio)
		_baseLayer:addChild(flowerSprite,1,kMidSpriteTag)
	end

	--修行值label
	local tipNumLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1080"),g_sFontName,21)
	tipNumLabel:setColor(ccc3(0xff,0xf6,0x00))
	_monkeryNumLabel = CCLabelTTF:create("+" .. _monkeryNum,g_sFontName,21)
	_monkeryNumLabel:setColor(ccc3(0x00,0xff,0x18))
	local curMonkeryNode = BaseUI.createHorizontalNode({tipNumLabel,_monkeryNumLabel})
	curMonkeryNode:setAnchorPoint(ccp(0.5,1))
	curMonkeryNode:setPosition(ccp(g_winSize.width/2,g_winSize.height*440/960))
	curMonkeryNode:setScale(g_fElementScaleRatio)
	curMonkeryNode:setVisible(isRemainPrize)
	_baseLayer:addChild(curMonkeryNode,10,kBackTipTag + 8)
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_zOrder)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	--创建基础层
	_baseLayer = CCLayer:create()
	_baseLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_baseLayer,_zOrder)

    --创建背景UI
    createBgUI()
end

----------------------------------------工具函数----------------------------------------
--[[
	@des 	:翻牌动画
	@param 	:$ p_turnOverObj 翻转过去的object
	@param 	:$ p_turnBackObj 翻转过来的object
	@param 	:$ p_gapTime 翻牌之间隔时间（默认为0）
	@param  :$ p_callBackFunc 翻牌过后的回调函数（如果为nil则不调）
	@return :
--]]
function createOpenAnimation(p_turnOverObj,p_turnBackObj,p_gapTime,p_callBackFunc)
	local gapTime = p_gapTime or 0
	--回调函数
	local callBackFunc = p_callBackFunc or nil

	--动画动作容器
	local array = CCArray:create()
	--如果间隔时间不为0，则
	--插入每个卡牌翻拍的间隔时间
	if gapTime ~= 0 then
		array:addObject(CCDelayTime:create(gapTime))
	end
	--加入正面牌的翻转动画
	array:addObject(CCOrbitCamera:create(_flipSecond, 1, 0, 0, 90, 0, 0))
	--正面翻转结束后，正面小时，背面显示，开始翻转背面
	array:addObject(CCCallFunc:create(function()
		--背面不可见
		p_turnOverObj:setVisible(false)

		--正面可见
		p_turnBackObj:setVisible(true)

		--要翻转过来的动画
		local frontArray = CCArray:create()
		frontArray:addObject(CCOrbitCamera:create(_flipSecond, 1, 0, 270, 90, 0, 0))
		--如果有回调函数，则调取回调函数
		if callBackFunc ~= nil then
			frontArray:addObject(CCCallFunc:create(function()
				callBackFunc()
			end))
		end
		p_turnBackObj:runAction(CCSequence:create(frontArray))
	end))
	p_turnOverObj:runAction(CCSequence:create(array))
end

--[[
	@des 	:更换卡牌封面
	@param 	:改变后的table
	@return :
--]]
function changeCardGirl(p_newGirlTable)
	for i = 1,#_cardIndexTable do
		_bgMenu:removeChildByTag(_cardIndexTable[i],true)

		local newGirlSprite = HeroPublicCC.createSpriteCardShow(p_newGirlTable[_cardIndexTable[i] - kGirlTag + 1])
		local girlMenuItem = CCMenuItemSprite:create(newGirlSprite,newGirlSprite)
		girlMenuItem:setAnchorPoint(ccp(0.5,0))
		girlMenuItem:setPosition(ccp(g_winSize.width*cardXTable[_cardIndexTable[i] - kGirlTag],g_winSize.height*cardYTable[_cardIndexTable[i] - kGirlTag]))
		girlMenuItem:setScale(0.5*g_fElementScaleRatio)
		girlMenuItem:registerScriptTapHandler(flipCallBack)
		girlMenuItem:setVisible(false)
		_bgMenu:addChild(girlMenuItem,1,_cardIndexTable[i])
	end
end

--[[
	@des 	:重置卡牌特效结束后动作
	@param 	:
	@return :
--]]
function resetAnimateFunction()
	tolua.cast(_bgMenu:getChildByTag(kMenuTag + 4),"CCMenuItemSprite"):setEnabled(true)
	tolua.cast(_bgMenu:getChildByTag(kMenuTag + 5),"CCMenuItemSprite"):setEnabled(true)
	_baseLayer:getChildByTag(kBackTipTag + 7):setVisible(true)
	_baseLayer:getChildByTag(kBackTipTag + 8):setVisible(true)

	local flowerSprite = CCSprite:create("images/replaceskill/flipcard/" .. _curFlower .. ".png")
	flowerSprite:setAnchorPoint(ccp(0.5,0.5))
	flowerSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*465/960))
	flowerSprite:setScale(g_fElementScaleRatio)
	_baseLayer:addChild(flowerSprite,1,kMidSpriteTag)

	for i = 1,3 do
		local topMenuItem = tolua.cast(_bgMenu:getChildByTag(kMenuTag + i),"CCMenuItemImage")
		topMenuItem:setEnabled(true)
	end

	_monkeryNumLabel:setString("+" .. _monkeryNum)
end

--[[
	@des 	:翻牌特效结束后动作
	@param 	:
	@return :
--]]
function dieAnimateFunction()
	local flowerSprite = CCSprite:create("images/replaceskill/flipcard/" .. _curFlower .. ".png")
	flowerSprite:setAnchorPoint(ccp(0.5,0.5))
	flowerSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*465/960))
	flowerSprite:setScale(g_fElementScaleRatio)
	_baseLayer:addChild(flowerSprite,1,kMidSpriteTag)

	--顶部3个按钮可点击
	--底部两个按钮可显示
	--五个卡牌可点击
	for i = 1,5 do
		local topMenuItem = tolua.cast(_bgMenu:getChildByTag(kMenuTag + i),"CCMenuItemSprite")

		if i < 4 then
			topMenuItem:setEnabled(true)
		else
			topMenuItem:setVisible(true)
		end

		--几个女孩可点击
		local frontGirlMenu = tolua.cast(_bgMenu:getChildByTag(kGirlTag + i),"CCMenuItemSprite")
		frontGirlMenu:setEnabled(true)
	end

	--提示显示问题
	for i = 1,8 do
		local beginTipLabel = _baseLayer:getChildByTag(kBackTipTag + i)

		if i >= 5 then
			beginTipLabel:setVisible(true)
		else
			beginTipLabel:setVisible(false)
		end
	end
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
		if (cardKind ~= 1) and (cardKind ~= 3) and (cardKind ~= 9) and (cardKind ~= 5) then
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

		if (cardKind == 1) or (cardKind == 3) then
			for i = 1,5 do
				table.insert(_redTable,i)
			end
		elseif cardKind == 2 then
			for i = 1,2 do
				if table.count(dealTable[i]) == 4 then
					_redTable = dealTable[i]
					break
				end
			end
		elseif cardKind == 4 then
			for i = 1,2 do
				if table.count(dealTable[i]) == 3 then
					_redTable = dealTable[i]
				elseif table.count(dealTable[i]) == 2 then
					_greenTable = dealTable[i]
				end
			end
		elseif cardKind == 5 then
			for i = 1,5 do
				local cardHtid = tonumber(p_cardTable[i + 1])
				--如果是大乔，小乔，黄月英，蔡文姬中的一个的话	
				if (cardHtid == 10039) or (cardHtid == 10038) or (cardHtid == 10033) or (cardHtid == 10046) then
					table.insert(_redTable,i)
				end
			end
		elseif cardKind == 6 then
			for i = 1,3 do
				if table.count(dealTable[i]) == 3 then
					_redTable = dealTable[i]
					break
				end
			end
		elseif cardKind == 7 then
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
		elseif cardKind == 8 then
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
	@des 	:创建红光或绿光特效
	@param 	:$ p_kind 光的种类 1为红光，2为绿光
			 $ p_pos 位置id
	@return :
--]]
function createShiningAnimate(p_kind,p_pos)
	local spellEffectSprite
	--红光
	if p_kind == 1 then
		spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/huangdi/huangdi"), -1,CCString:create(""))
	else
		spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/lvdi/lvdi"), -1,CCString:create(""))
	end
	spellEffectSprite:setPosition(ccp(g_winSize.width*cardXTable[p_pos],g_winSize.height*cardYTable[p_pos] + 110*g_fElementScaleRatio))
    spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
    spellEffectSprite:setScale(g_fElementScaleRatio*2.5)
    if p_kind == 1 then
    	_baseLayer:addChild(spellEffectSprite,1,kRedTag + p_pos)
    else
    	_baseLayer:addChild(spellEffectSprite,1,kGreenTag + p_pos)
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
	@des 	:创建翻牌特效
	@param 	:回调函数
	@return :
--]]
function createFlipAnimate(p_callBack)
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(effectPathTable[tonumber(_curFlower)]), -1,CCString:create(""))
	spellEffectSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*465/960))
    spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
    spellEffectSprite:setScale(g_fElementScaleRatio)
    spellEffectSprite:setFPS_interval(1/20)
    _baseLayer:addChild(spellEffectSprite,9999)

    local animationEnd = function(actionName,xmlSprite)
   	 	p_callBack()

   		spellEffectSprite:retain()
		spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    spellEffectSprite:setDelegate(delegate)
end