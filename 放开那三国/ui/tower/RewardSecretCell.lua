-- FileName: RewardSecretCell.lua
-- Author: LLP
-- Date: 14-4-10
-- Purpose: 神秘层弹出layer中的cell


module("RewardSecretCell", package.seeall)

require "script/model/user/UserModel"

require "db/DB_Heroes"

local copyId = -1
local strongId = -1
local labelCpy = nil
local dataCpy = nil
local cost = -1
function createCell( rewardData,trueRewardData,index)
	local id = -1
	local endTime = -1
	local getTimes = -1

	dataCpy = trueRewardData
	local tCell = CCTableViewCell:create()

	local cellBg = CCScale9Sprite:create("images/reward/secret_cell_back.png")
	cellBg:setContentSize(CCSizeMake(563,201))
	tCell:addChild(cellBg)

	--  挑战图片
	local towerChallengeItem = CCMenuItemImage:create("images/reward/Challenge1.png", "images/reward/Challenge2.png")

	towerChallengeItem:registerScriptTapHandler(challengeAction)
	local challengeMenu = CCMenu:create()
	challengeMenu:setTouchPriority(-500)
	challengeMenu:setPosition(ccp(0, 0))
	challengeMenu:setAnchorPoint(ccp(0,0))
	cellBg:addChild(challengeMenu)


	local itemsBg= CCScale9Sprite:create("images/reward/secret_item_back.png")
	itemsBg:setContentSize(CCSizeMake(250,127))
	itemsBg:setPosition(ccp(cellBg:getContentSize().width*0.25 ,cellBg:getContentSize().height*0.15))
	itemsBg:setAnchorPoint(ccp(0,0))
	cellBg:addChild(itemsBg)

	--  显示物品的bg
	require "db/DB_Tower_layer"
	cp = DB_Tower.getDataById(1)
	local x = 0
	for k,v in pairs (trueRewardData) do
		x = x + 1
		if(x == tonumber(index))then
			id = v[1]
			copyId = k

			strongId = v[1]
			endTime = v[2]
			getTimes = v[3]

			challengeMenu:addChild(towerChallengeItem,0,copyId)
			challengeMenu:setTag(strongId)

			towerChallengeItem:setPosition(ccp(cellBg:getContentSize().width*0.25+itemsBg:getContentSize().width,cellBg:getContentSize().height*0.15))
			break
		elseif(x ~= tonumber(index))then
		end
	end

	--国家图标
	require "db/DB_Stronghold"
    local countryId = DB_Stronghold.getDataById(strongId)

    local strName = countryId.name
    local nameLabel = CCRenderLabel:create(strName, g_sFontPangWa, 27, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
    nameLabel:setAnchorPoint(ccp(0.5, 1))
    nameLabel:setPosition(ccp(cellBg:getContentSize().width*0.5, cellBg:getContentSize().height-10))
    cellBg:addChild(nameLabel)

    local country_icon = nil
    if(countryId ~= nil)then
    	if(tonumber(countryId.towerCountry)==1)then
    		country_icon = HeroModel.getCiconByCidAndlevel(countryId.towerCountry, 4)
    	elseif(tonumber(countryId.towerCountry)==2) then
    		country_icon = HeroModel.getCiconByCidAndlevel(countryId.towerCountry, 7)
    	elseif(tonumber(countryId.towerCountry)==3) then
    		country_icon = HeroModel.getCiconByCidAndlevel(countryId.towerCountry, 3)
    	elseif(tonumber(countryId.towerCountry)==4) then
    		country_icon = HeroModel.getCiconByCidAndlevel(countryId.towerCountry, 6)
    end
		local countrySprite = CCSprite:create(country_icon);
		cellBg:addChild(countrySprite)
		countrySprite:setPosition(ccp(countrySprite:getContentSize().width*0.5,cellBg:getContentSize().height-countrySprite:getContentSize().height))
	end
	--神秘层倒计时汉字label
    local _secretTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2422"), g_sFontPangWa, 23)
	_secretTimeLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_secretTimeLabel:setAnchorPoint(ccp(0.5, 1))
	_secretTimeLabel:setPosition(ccp(_secretTimeLabel:getContentSize().width*0.6, itemsBg:getContentSize().height*0.3))
	-- _secretTimeLabel:setScale(g_fElementScaleRatio)
	itemsBg:addChild(_secretTimeLabel)

	--神秘层倒计时数字label
	leftTimeInterval = tonumber(endTime)+cp.hideLayerTime - TimeUtil.getSvrTimeByOffset()
	local _secretTimeNumLabel = CCLabelTTF:create(TimeUtil.getTimeString(leftTimeInterval), g_sFontPangWa, 23)--
	_secretTimeNumLabel:setColor(ccc3(0xbf, 0x01, 0x01))
	_secretTimeNumLabel:setAnchorPoint(ccp(0, 1))
	_secretTimeNumLabel:setPosition(ccp(_secretTimeLabel:getContentSize().width*1.1, itemsBg:getContentSize().height*0.3))
	-- _secretTimeNumLabel:setScale(g_fElementScaleRatio)
	itemsBg:addChild(_secretTimeNumLabel)
	labelCpy = _secretTimeNumLabel
	local function refreshTime( ... )
	-- body
		if(cp~=nil)then
		leftTimeInterval = tonumber(endTime)+cp.hideLayerTime - TimeUtil.getSvrTimeByOffset()
		_secretTimeNumLabel:setString(TimeUtil.getTimeString(leftTimeInterval))
		end
	end

	local delay = CCDelayTime:create(1)
    local callfunc = CCCallFunc:create(function ( ... )refreshTime() end)
    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
    local action = CCRepeatForever:create(sequence)
    _secretTimeNumLabel:runAction(action)

    --神秘层攻打次数汉字
	local _secretAttackLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2626"), g_sFontPangWa, 23)
	_secretAttackLabel:setAnchorPoint(ccp(0.5, 1))
	_secretAttackLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_secretAttackLabel:setPosition(ccp(_secretAttackLabel:getContentSize().width*0.6, itemsBg:getContentSize().height*0.8))
	-- _secretAttackLabel:setScale(g_fElementScaleRatio)
	itemsBg:addChild(_secretAttackLabel)

	--神秘层攻打次数数字
	local _secretAttackCount = CCLabelTTF:create(cp.attackTime-getTimes, g_sFontPangWa, 23)
	_secretAttackCount:setAnchorPoint(ccp(0, 1))
	_secretAttackCount:setColor(ccc3(0x0b, 0x9d, 0x00))
	_secretAttackCount:setPosition(ccp(_secretAttackLabel:getContentSize().width*1.1, itemsBg:getContentSize().height*0.8))
	-- _secretAttackCount:setScale(g_fElementScaleRatio)
	itemsBg:addChild(_secretAttackCount)

	--消耗体力
	local _secretCostLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2069"), g_sFontPangWa, 23)
	_secretCostLabel:setAnchorPoint(ccp(0.5, 1))
	_secretCostLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_secretCostLabel:setPosition(ccp(_secretCostLabel:getContentSize().width*0.6, itemsBg:getContentSize().height*0.55))
	-- _secretCostLabel:setScale(g_fElementScaleRatio)
	itemsBg:addChild(_secretCostLabel)

	--消耗体力
	local _secretCistCount = CCLabelTTF:create(countryId.cost_energy_simple, g_sFontPangWa, 23)
	_secretCistCount:setAnchorPoint(ccp(0, 1))
	_secretCistCount:setColor(ccc3(0x0b, 0x9d, 0x00))
	_secretCistCount:setPosition(ccp(_secretCostLabel:getContentSize().width*1.1, itemsBg:getContentSize().height*0.55))
	-- _secretCistCount:setScale(g_fElementScaleRatio)
	itemsBg:addChild(_secretCistCount)

	--  神秘层图片
	local towerSp = CCSprite:create("images/tower/secret1.png")
	cellBg:addChild(towerSp)
	towerSp:setPosition(ccp(cellBg:getContentSize().width*0.05,cellBg:getContentSize().height*0.15))

	return tCell
end

function challengeAction( tag,item )
	-- body
	if(ItemUtil.isBagFull() == true)then
	return
	end
	local x = tonumber(tag)
	local menuTag = item:getParent():getTag()
	print("menuTag======="..menuTag)
	local countryId = DB_Stronghold.getDataById(menuTag)
	cost = countryId.cost_energy_simple;
	print("countryId.cost_energy_simple"..cost)

	TowerMainLayer.setStrongId(tag)

	local powerNum = UserModel.getEnergyValue()
	if(powerNum>=cost)then
		require "script/battle/BattleLayer"
		_towerInfo = TowerCache.getTowerInfo()
		_curFloorDesc = TowerUtil.getTowerFloorDescBy(_towerInfo.cur_level)

		BattleLayer.enterBattle(x, menuTag, 0, TowerMainLayer.doSecretBattleCallback, 5,false)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		local layerCpy = runningScene:getChildByTag(121)
		layerCpy:setVisible(false)
		labelCpy:stopAllActions()
		runningScene:removeChildByTag(121,true)
	elseif(powerNum<cost)then
		require "script/ui/item/EnergyAlertTip"
		EnergyAlertTip.showTip()
	end
end
