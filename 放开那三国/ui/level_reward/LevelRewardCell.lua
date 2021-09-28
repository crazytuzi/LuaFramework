-- Filename: LevelRewardCell.lua
-- Author: zhz
-- Date: 2013-8-29
-- Purpose: 该文件用于: 等级礼包cell

module("LevelRewardCell", package.seeall)

require "script/ui/level_reward/GoodsCell"

require "script/ui/tip/AnimationTip"
require "script/ui/level_reward/LevelRewardUtil"
require "script/model/user/UserModel"
require "script/network/RequestCenter"
require "script/ui/item/ItemUtil"
require "db/DB_Level_reward"
require "script/utils/ItemDropUtil"

local getLevelRewardOverCallback = nil

local _itemBtn
local _all_good = {}
local cellBackground = nil
local _tag
-- 在界面上显示得到的奖励
local function getRewardAction(reward_type,reward_values)

	local type = tonumber(reward_type)
	local userInfo = UserModel.getUserInfo()
	if(type == 1) then
		UserModel.addSilverNumber(reward_values)
	elseif(type == 3) then
		UserModel.addGoldNumber(reward_values)
	elseif(type == 4) then
		UserModel.addEnergyValue(reward_values)
	elseif(type == 5) then
		UserModel.addStaminaNumber(reward_values)
	elseif(type == 2) then
		UserModel.addSoulNum(reward_values)
	elseif(type == 8) then
		local silver = tonumber(reward_values)*tonumber(userInfo.level)
		UserModel.addSilverNumber(silver)
	elseif(type == 9) then
		local soul  = tonumber(reward_values)*tonumber(userInfo.level)
		UserModel.addSoulNum(soul)
	end

end
-- 向服务器传递领取Id的回调函数 reward_values
local function receiveCallback(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	local curReceiveID = LevelRewardUtil.getCurRewardID()
	print(curReceiveID)
	require "db/DB_Level_reward"
	local receiveData = DB_Level_reward.getDataById(curReceiveID)
	local desc = GetLocalizeStringBy("key_1914")
	for i=1, tonumber(receiveData.reward_num) do
		local rewardNum = LevelRewardUtil.getRewardNum(receiveData["reward_type" .. i],receiveData["reward_values" .. i])
		desc = desc .. receiveData["reward_desc" .. i] .. "*" .. rewardNum
		if( i < tonumber(receiveData.reward_num))  then
			desc = desc .. "\n"
		end
		getRewardAction(receiveData["reward_type" .. i],receiveData["reward_values" .. i])
	end
	_itemBtn:setVisible(false)
	LevelRewardLayer.refresh(_tag-1000)
 	LevelRewardUtil.addRewardInfo(curReceiveID)
 	if(getLevelRewardOverCallback ~= nil)then
		getLevelRewardOverCallback()
	end
	
	local all_good = getGoosTable(receiveData)
	ItemDropUtil.showGiftLayer( all_good)
end

-- 领取按钮的回调函数
local function receiveCb(tag, itemBtn)
	---[==[等级礼包新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.09
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideFiveLevelGift) then
			require "script/guide/LevelGiftBagGuide"
			LevelGiftBagGuide.changLayer()
		end
		---------------------end-------------------------------------
	--]==]
	local curReceiveID = tag -1000
	LevelRewardUtil.setCurRewardID(curReceiveID)

	local receiveData =  DB_Level_reward.getDataById(curReceiveID)

	-- 判断背包是否已满
	local isItem = false
	for i=1, tonumber(receiveData.reward_num) do
		if( tonumber(receiveData["reward_type" .. i]) == 6 or tonumber(receiveData["reward_type" .. i]) == 7  )  then
			isItem= true
			break
		end
	end
	if( isItem  and ItemUtil.isBagFull() == true )then
		require "script/ui/level_reward/LevelRewardLayer"
		LevelRewardLayer.closeCb()
		return
	end
	-- 判断武将是否已满
	require "script/model/hero/HeroModel"
	local isHero = false
	
	for i=1, tonumber(receiveData.reward_num) do
		if( tonumber(receiveData["reward_type" .. i]) == 10 )  then
			isHero= true
			break
		end
	end
    require "script/ui/hero/HeroPublicUI"
	if( isHero and HeroPublicUI.showHeroIsLimitedUI()) then
		require "script/ui/level_reward/LevelRewardLayer"
		LevelRewardLayer.closeCb()
		return
	end

	local args = CCArray:create()
	_itemBtn = itemBtn
	_tag = tag
	-- itemBtn:setVisible(false)
	args:addObject(CCInteger:create(curReceiveID))
	RequestCenter.levelfund_gainLevelfundPrize(receiveCallback, args)

end

local function createGoodTableView(cellValues,rewardBg)

	-- 把奖励改成需要的形式
	local all_good = getGoosTable(cellValues)
	
	--_all_good = all_good

	local cellSize = CCSizeMake(101, 121)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           a2 = GoodsCell.createCell(all_good[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			local num = #all_good
			r = num
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(417, 120))
	goodTableView:setBounceable(true)
	if(tonumber(cellValues.reward_num)> 4) then
		goodTableView:setTouchPriority(-560)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setPosition(ccp(7, 2))
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	rewardBg:addChild(goodTableView)

end

function getGoosTable( cellValues )

	local all_good = {}
	for i=1,cellValues.reward_num do
	    if(cellValues["reward_type" .. i]~= nil) then
	        local t = {}
	        t.reward_type = cellValues["reward_type" .. i]
	        t.reward_quality = cellValues["reward_quality" ..i]
	        t.reward_desc = cellValues["reward_desc" .. i]
	        if(t.reward_type == 6) then
	            t.reward_ID = cellValues["reward_values" .. i]
	            t.reward_values = 1
	        elseif(t.reward_type == 7) then
	            t.reward_ID =  lua_string_split(cellValues["reward_values" .. i],'|')[1]
	            t.reward_values = lua_string_split(cellValues["reward_values" .. i],'|')[2]
	            elseif(t.reward_type == 10) then
	            	t.reward_ID = cellValues["reward_values" .. i]
	            	t.reward_values = 1
	        else
	            t.reward_values =  cellValues["reward_values" .. i]
	        end
	        table.insert(all_good,t)
	    end
	end

	return all_good
end


function createCell(cellValues,isChange,tag)

	local tCell = CCTableViewCell:create()

	-- cell的背景
	cellBackground = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
	cellBackground:setContentSize(CCSizeMake(583, 181))
	tCell:addChild(cellBackground)

	-- 文字 ：达到x级可以领取
	-- local canReceiveLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1636").. cellValues.level .. GetLocalizeStringBy("key_2091"),  g_sFontName, 24)
	local canReceiveLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1636").. cellValues.level .. GetLocalizeStringBy("key_2091"),  g_sFontName, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	canReceiveLabel:setColor(ccc3(0xff,0xe4,0x00))
	canReceiveLabel:setPosition(ccp(52,174))
	cellBackground:addChild(canReceiveLabel)

	-- 物品背景
	local rewardBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png") 
	rewardBg:setContentSize(CCSizeMake(425,128))
	rewardBg:setPosition(ccp(11,13))
	cellBackground:addChild(rewardBg)

	-- 获取升级嘉奖活动信息
	local rewardInfo = LevelRewardUtil.getRewardInfo()
	local userInfo = UserModel.getUserInfo()
	-- print("rewardInfo is : " )
	-- print_t(rewardInfo)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-560)
	tCell:addChild(menu,0,101)

	local btnSize = CCSizeMake(20,61)
	-- normal sprite  ababab 
	local text = {GetLocalizeStringBy("key_1715"),GetLocalizeStringBy("key_1369")}
	local normalReceiveSprite = CCSprite:create("images/level_reward/receive_btn_n.png")
	local normalLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2213"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x00),type_stroke)
	normalLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	normalLabel:setAnchorPoint(ccp(0.5,0.5))
	normalLabel:setPosition(ccp(normalReceiveSprite:getContentSize().width*0.5,normalReceiveSprite:getContentSize().height*0.5))
	normalReceiveSprite:addChild(normalLabel,0,101)
	-- selectedSprite,local btnSize = CCSizeMake(normalReceiveSprite:getContentSize().width , normalReceiveSprite:getContentSize().height)
	local selectReceiveSprite = CCSprite:create("images/level_reward/receive_btn_h.png")
	local selectLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2213"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	selectLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	selectLabel:setAnchorPoint(ccp(0.5,0.5))
	selectLabel:setPosition(ccp(selectReceiveSprite:getContentSize().width*0.5,selectReceiveSprite:getContentSize().height*0.5))
	selectReceiveSprite:addChild(selectLabel,0,101)
	-- disable Sprite
	local disabledReceiveSprite = BTGraySprite:create("images/level_reward/receive_btn_n.png")
	local disabledLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1715"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	disabledLabel:setColor(ccc3(0xab,0xab,0xab))
	disabledLabel:setAnchorPoint(ccp(0.5,0.5))
	disabledLabel:setPosition(ccp(disabledReceiveSprite:getContentSize().width*0.5,disabledReceiveSprite:getContentSize().height*0.5))
	disabledReceiveSprite:addChild(disabledLabel,0,101)
	local receiveBtn = CCMenuItemSprite:create(normalReceiveSprite,selectReceiveSprite, disabledReceiveSprite)
	receiveBtn:setPosition(ccp(450,cellBackground:getContentSize().height*0.5))
	receiveBtn:setAnchorPoint(ccp(0,0.5))
	receiveBtn:registerScriptTapHandler(receiveCb)
	menu:addChild(receiveBtn, 0,1000 + cellValues.id)
	if(table.isEmpty(rewardInfo)) then
		if(tonumber(cellValues.level) > tonumber(userInfo.level)) then
			receiveBtn:setEnabled(false)
		end
	else
		if(tonumber(cellValues.level) > tonumber(userInfo.level)) then
			receiveBtn:setEnabled(false)
		end
		for k, v in pairs(rewardInfo) do
			if(tonumber(v) == tonumber(cellValues.id )) then
				-- receiveBtn:setEnabled(false)
				-- disabledLabel:setString(GetLocalizeStringBy("key_1369"))
				receiveBtn:setVisible(false)
				local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
                receive_alreadySp:setPosition(ccp(450,cellBackground:getContentSize().height*0.5))
                receive_alreadySp:setAnchorPoint(ccp(0,0.5))
                tCell:addChild(receive_alreadySp)
			end
		end
		if(not table.isEmpty(rewardInfo)) then
			print("第1=========")
			print("tag----",tag)
			print("cellValues.id",cellValues.id)
			if(tag == tonumber(cellValues.id))then
				print("第2=========")
				if(isChange)then
					print("第3=========")
					receiveBtn:setVisible(false)
					local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
		            receive_alreadySp:setPosition(ccp(450,cellBackground:getContentSize().height*0.5))
		            receive_alreadySp:setAnchorPoint(ccp(0,0.5))
		            tCell:addChild(receive_alreadySp)
				end
			end
		end
	end


	-- 下面显示物品的TableView
	createGoodTableView(cellValues,rewardBg)
	
	return tCell
end



--add by lichenyang
function regisgerGetLevelRewardOverCallback( p_callback )
	getLevelRewardOverCallback = p_callback
end









