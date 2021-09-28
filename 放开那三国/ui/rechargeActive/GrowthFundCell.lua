-- Filename: GrowthFundCell.lua.
-- Author: zhz  
-- Date: 2013-09-30
-- Purpose: 该文件用于成长基金cell
module("GrowthFundCell",package.seeall)

require "script/ui/shop/RechargeLayer"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/network/RequestCenter"


local _addGoldNum = 0
local _index 
local cellBackground
-- 向服务器传递数据
local function receiveCallback(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	require "script/ui/rechargeActive/GrowthFundLayer"
	local goldArray = GrowthFundLayer.getGrowthData()
	AnimationTip.showTip(GetLocalizeStringBy("key_2394") .. goldArray[_index+1].num )
	UserModel.addGoldNumber(tonumber(goldArray[_index+1].num))
	ActiveCache.addPrezedArray(tonumber(_index))
	GrowthFundLayer.updataTableView()

end

--  接受按钮的回调函数
local function receiveCb(tag, itemBtn)
	if(ActiveCache.getPrizeInfo() == "unactived") then
		AnimationTip.showTip(GetLocalizeStringBy("key_2879"))
		print("in    cell  the prizeInfo is : ")
		print_t(ActiveCache.getPrizeInfo())
		return
	end
	
	-- itemBtn:setVisible(false)
	-- -- itemBtn = tolua.cast(itemBtn, "CCMenuItemSprite")
	-- -- local disableSprite = itemBtn:getDisabledImage() ---,"CCSprite")
	-- -- local label = tolua.cast(disableSprite:getChildByTag(101) , "CCRenderLabel")
	-- -- label:setString(GetLocalizeStringBy("key_1369"))
	-- local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
 --    hasReceiveItem:setAnchorPoint(ccp(0,0.5))
 --    hasReceiveItem:setPosition(ccp(440,cellBackground:getContentSize().height*0.5))
 --    cellBackground:addChild(hasReceiveItem) 
	local args = CCArray:create()
	_index = tag -1000
	print("index is :" ,_index )
	args:addObject(CCInteger:create(_index))
	RequestCenter.growup_fetchPrize(receiveCallback, args)
end

function createCell( cellValues)
	local tCell = CCTableViewCell:create()

	-- cell 的背景
	cellBackground = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
	cellBackground:setContentSize(CCSizeMake(582,109))
	tCell:addChild(cellBackground)

	-- n 级成长基金 文字
	local moneyBg = CCScale9Sprite:create("images/friend/friend_name_bg.png")
	moneyBg:setContentSize(CCSizeMake(279,34))
	moneyBg:setPosition(ccp(8,56))
	cellBackground:addChild(moneyBg)

	local moneyLabel =  CCRenderLabel:create ( cellValues.level .. GetLocalizeStringBy("key_1347"), g_sFontName ,23,1,ccc3(0x00,0x00,0x0),type_stroke)
	moneyLabel:setColor(ccc3(0xff,0x7e,0xf8))
	moneyLabel:setPosition(ccp(12,moneyBg:getContentSize().height/2 ))
	moneyLabel:setAnchorPoint(ccp(0,0.5))
	moneyBg:addChild(moneyLabel)

	-- 达到x级即可领取x金币
	local descLabel =  CCRenderLabel:create( GetLocalizeStringBy("key_1636") .. cellValues.level ..GetLocalizeStringBy("key_2080") ..  cellValues.num ..GetLocalizeStringBy("key_1491"), g_sFontName ,23,1,ccc3(0x00,0x00,0x0),type_stroke)
	descLabel:setColor(ccc3(0xff,0xf6,0x00))
	descLabel:setPosition(ccp(18,22))
	descLabel:setAnchorPoint(ccp(0,0))
	cellBackground:addChild(descLabel)

	-- 金币头像
	local goldSp = ItemSprite.getGoldIconSprite()--CCSprite:create("images/common/gold_big.png")
	goldSp:setPosition(ccp(331,cellBackground:getContentSize().height/2))
	goldSp:setAnchorPoint(ccp(0,0.5))
	cellBackground:addChild(goldSp)

	-- 金币的数量
	local goldLabel = CCRenderLabel:create("" .. cellValues.num, g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_shadow)
	goldLabel:setColor(ccc3(0x00,0xff,0x18))
	goldLabel:setAnchorPoint(ccp(1,0))
	goldLabel:setPosition(ccp(goldSp:getContentSize().width -5,4))
	goldSp:addChild(goldLabel)


	-- 按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	cellBackground:addChild(menu)

	local normalReceiveSprite = CCScale9Sprite:create("images/level_reward/receive_btn_n.png")

	local btnSize = normalReceiveSprite:getContentSize()
	-- normalReceiveSprite:setContentSize(CCSizeMake(134,83))
	local normalLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1715"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	normalLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	normalLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
	normalLabel:setAnchorPoint(ccp(0.5,0.5))
	normalReceiveSprite:addChild(normalLabel,0,101)
	-- selectedSprite,
	local selectReceiveSprite = CCScale9Sprite:create("images/level_reward/receive_btn_h.png")
	-- selectReceiveSprite:setContentSize(CCSizeMake(134,83))
	local selectLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1715"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	selectLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	selectLabel:setAnchorPoint(ccp(0.5,0.5))
	selectLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
	selectReceiveSprite:addChild(selectLabel,0,101)
	-- disable Sprite
	local disabledReceiveSprite = BTGraySprite:create("images/level_reward/receive_btn_n.png")
	local disabledLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1715"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	disabledLabel:setColor(ccc3(0xab,0xab,0xab))
	disabledLabel:setAnchorPoint(ccp(0.5,0.5))
	disabledLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
	disabledReceiveSprite:addChild(disabledLabel,0,101)
	local receiveBtn = CCMenuItemSprite:create(normalReceiveSprite,selectReceiveSprite, disabledReceiveSprite)
	receiveBtn:setPosition(ccp(440,cellBackground:getContentSize().height*0.5))
	receiveBtn:setAnchorPoint(ccp(0,0.5))
	receiveBtn:registerScriptTapHandler(receiveCb)
	menu:addChild(receiveBtn,0, cellValues.index+1000)

	-- activeCacheinfo 
	local prizeInfo = ActiveCache.getPrizeInfo()
	print("in    cell  the prizeInfo is : ")
	print_t(prizeInfo)
	local userInfo = UserModel.getUserInfo()
	if(tonumber(cellValues.level) > tonumber(userInfo.level)) then
		receiveBtn:setEnabled(false)
	end

	if(not table.isEmpty(prizeInfo.prized)) then
		-- if(tonumber(cellValues.level) > tonumber(userInfo.level)) then
		-- 	receiveBtn:setEnabled(false)
		-- end

		for k, v in pairs(prizeInfo.prized) do
			if(tonumber(v) == tonumber(cellValues.index) ) then
				print("k is : ", k,"  v is : ", v)
				-- receiveBtn:setEnabled(false)
				-- disabledLabel:setString(GetLocalizeStringBy("key_1369"))
				receiveBtn:setVisible(false)
				local hasReceiveItem = CCSprite:create("images/sign/receive_already.png")
		        hasReceiveItem:setAnchorPoint(ccp(0,0.5))
		        hasReceiveItem:setPosition(ccp(440,cellBackground:getContentSize().height*0.5))
		        cellBackground:addChild(hasReceiveItem) 
			end
		end
	end

	return tCell
end
