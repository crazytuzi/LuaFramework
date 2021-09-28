-- Filename: SignRewardCell.lua
-- Author: zhz
-- Date: 2013-07-31
-- Purpose: 该文件用于:连续签到的cell

module("SignRewardCell", package.seeall)


require "script/ui/sign/SignCache"
require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemSprite"


local _curItem = nil
local _curReceiveSp = nil
local _id 
local _all_good

local getCallback = nil


-- 网络的回调函数
local function signNormalCB(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok" )then
	 	return
	 end
	 
	 if(getCallback ~= nil)then
		getCallback()
	end

	_curItem:setVisible(false)
	_curReceiveSp:setVisible(true)
	 
	SignCache.changeSignInfoStatus(_id)

	-- for 
	local tip = SignCache.getTipByReward(_all_good)
	--AnimationTip.showTip(tip)

	SignCache.addUserReward(_all_good)

	ItemDropUtil.showGiftLayer(_all_good)

end


-- 领取按钮的回调
local function receiveAction( tag,item )

	require "script/ui/sign/SignRewardLayer"
	require "script/ui/item/ItemUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- tag 里面存的是 id	
	_id	= tonumber(tag)	
	_all_good = SignCache.getRewardTable(tag)
	local isItem= false
	for i=1, #_all_good do
		if(_all_good[i].reward_type == 6 or _all_good[i].reward_type ==7) then
			isItem = true
			break
		end
	end
	
	if(isItem and ItemUtil.isBagFull() ) then
		require "script/ui/sign/SignRewardLayer"
		SignRewardLayer.cancelBtnCallBack()
		return 
    end

    local isHero= false
    for i=1, #_all_good do
		if(_all_good[i].reward_type == 10) then
			isHero = true
			break
		end
	end
     require "script/ui/hero/HeroPublicUI"
	if( isHero and HeroPublicUI.showHeroIsLimitedUI()) then
		require "script/ui/sign/SignRewardLayer"
		SignRewardLayer.cancelBtnCallBack()
		return 
	end

    _curItem = item
    local receivedSp = item:getParent():getParent():getChildByTag(4)
	-- receivedSp:setVisible(true)
	_curReceiveSp = receivedSp

	local args = CCArray:create()
	args:addObject(CCInteger:create(tag))
	RequestCenter.sign_gainNormalSignReward(signNormalCB, args)
end


function createCell(cellValues)

	local tCell = CCTableViewCell:create()

	local cellbg = CCSprite:create("images/sign/cellbg.png")
	tCell:addChild(cellbg,1,1)

	-- 登录第几天 的底
	local signBottom = CCSprite:create("images/sign/sign_bottom.png")
	signBottom:setPosition(ccp(3,cellbg:getContentSize().height*0.72))
	cellbg:addChild(signBottom)

	local signDaysLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2600") .. cellValues.continue_login_days .. GetLocalizeStringBy("key_2825"), g_sFontName,30,2,ccc3(0x00,0x00,0x00),type_stroke)
	signDaysLabel:setColor(ccc3(0xff,0xfb,0xd9)) -- 0xff,0xfb,0xd9
	signDaysLabel:setPosition(ccp(signBottom:getContentSize().width*0.2,signBottom:getContentSize().height*0.8))
	signBottom:addChild(signDaysLabel)

	local all_good = SignCache.getRewardTable(cellValues.id)
	-- print("all_good  is : ")
	-- print_t(all_good)

	for i=1,4 do 
		if(not table.isEmpty(all_good[i])) then
			local iconBg
			local iconSp
			if(all_good[i].reward_type == 6 or all_good[i].reward_type == 7) then
				iconBg = ItemSprite.getItemSpriteById(tonumber(all_good[i].reward_ID),nil,itemDelegateAction, nil, -600,1000)
				iconBg:setPosition(ccp(cellbg:getContentSize().width*0.055+cellbg:getContentSize().width*(i-1)*0.18,cellbg:getContentSize().height*0.23))
				cellbg:addChild(iconBg)
			else
				iconBg = CCSprite:create( "images/item/bg/itembg_" .. all_good[i].reward_quality .. ".png")		
				iconBg:setPosition(ccp(cellbg:getContentSize().width*0.055+cellbg:getContentSize().width*(i-1)*0.18,cellbg:getContentSize().height*0.23))
				cellbg:addChild(iconBg)
				iconSp = SignCache.getItemSp(all_good[i])
				iconSp:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().width*0.5))
				iconSp:setAnchorPoint(ccp(0.5,0.5))
				iconBg:addChild(iconSp)
			end
		
			local desc = CCLabelTTF:create(all_good[i].reward_desc,g_sFontName,21)
			desc:setColor(ccc3(0x78,0x25,0x00))
			desc:setPosition(ccp(iconBg:getContentSize().width*0.5,-23))
			desc:setAnchorPoint(ccp(0.5,0))
			iconBg:addChild(desc)
			--print("all_good[i].reward_values is : ", all_good[i].reward_values)

			-- 越南版本
			if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
				desc:setVisible(false)
			end

			if(tonumber(all_good[i].reward_values)> 1 ) then
				local valuesLabel = CCRenderLabel:create("" .. all_good[i].reward_values, g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
				local width = iconBg:getContentSize().width - valuesLabel:getContentSize().width- 6
				valuesLabel:setPosition(ccp(width,iconBg:getContentSize().height*0.3))
				valuesLabel:setColor(ccc3(0x00,0xff,0x18))
				iconBg:addChild(valuesLabel)
			end
		end
	end

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-551)
	cellbg:addChild(menu,11,101)
	-- 领取奖励的按钮
	local normalSp = CCSprite:create("images/sign/receive/receive_n.png")
	local selectedSp = CCSprite:create("images/sign/receive/receive_h.png")
	local disabledSp = BTGraySprite:create("images/sign/receive/receive_n.png")
	local receiveBtn = CCMenuItemSprite:create(normalSp,selectedSp, disabledSp)
	receiveBtn:setPosition(ccp(cellbg:getContentSize().width*420/551,cellbg:getContentSize().height*0.5))
	receiveBtn:setAnchorPoint(ccp(0,0.5))
	receiveBtn:registerScriptTapHandler(receiveAction)
	menu:addChild(receiveBtn,1 ,cellValues.id)

	local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
	receive_alreadySp:setPosition(ccp(cellbg:getContentSize().width*0.76,cellbg:getContentSize().height*72/182))
	receive_alreadySp:setAnchorPoint(ccp(0,0))
	receive_alreadySp:setVisible(false)
	cellbg:addChild(receive_alreadySp,0,4)
	
	local normalList = SignCache.getNormalList()
	local status = tonumber(normalList[tostring(cellValues.id)])
	if( status == 2) then 
		receiveBtn:setEnabled(false)
	end
	if(status == 1) then
		receive_alreadySp:setVisible(true)
		receiveBtn:setVisible(false)
	end

	return tCell

end

-- 
function itemDelegateAction( )
    MainScene.setMainSceneViewsVisible(true, true, true)
end


function registerGetCallback( p_callback)
	getCallback = p_callback
end


