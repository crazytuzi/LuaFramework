-- FileName: AchieItem.lua
-- Author: LLP
-- Date: 14-5-14
-- Purpose: function description of module


module("AchieItem", package.seeall)

require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicUI"


local dataCpy = nil
local itemCpy = nil
local tagCpy  = 0
local tagKey = 0
local jKey = 0
local Key = 0
function createCell( tcellData,tag,j )

	tagKey = tag
	dataCpy = tcellData
	local cell = CCNode:create()
	cell:setAnchorPoint(ccp(0.5,1))

	-- 背景
	local fullRect = CCRectMake(0,0,116,150)
	local insetRect = CCRectMake(50,43,16,6)
	local cellBg = CCScale9Sprite:create("images/everyday/cell_bg.png",fullRect, insetRect)
	cellBg:setContentSize(CCSizeMake(574,150))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg,0,tcellData.id)

	-- 图标
	local iconSpriteBg1 = CCSprite:create("images/everyday/headBg1.png")
	iconSpriteBg1:setAnchorPoint(ccp(0,0.5))
	iconSpriteBg1:setPosition(ccp(20,cellBg:getContentSize().height*0.5))
	cellBg:addChild(iconSpriteBg1)
	-- 图标底
	local iconSpriteBg2 = CCSprite:create("images/base/potential/props_" .. tcellData.achie_quality .. ".png")
	iconSpriteBg2:setAnchorPoint(ccp(0.5,0.5))
	iconSpriteBg2:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,iconSpriteBg1:getContentSize().height*0.5))
	iconSpriteBg1:addChild(iconSpriteBg2)
	-- 真正的图标
	local iconSprite = CCSprite:create("images/achie/".. tcellData.achie_icon)
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(iconSpriteBg2:getContentSize().width*0.5,iconSpriteBg2:getContentSize().height*0.5))
	iconSpriteBg2:addChild(iconSprite)

	-- 名字背景
	local nameBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
	nameBg:setContentSize(CCSizeMake(282,33))
	nameBg:setAnchorPoint(ccp(0,1))
	nameBg:setPosition(ccp(135,cellBg:getContentSize().height-20))
	cellBg:addChild(nameBg)
	-- 名字 进度
	local str = tcellData.achie_name or GetLocalizeStringBy("key_10000")
	local name_font = CCLabelTTF:create(str,g_sFontPangWa,24)
 	name_font:setColor(ccc3(0xff,0xff,0xff))
 	name_font:setAnchorPoint(ccp(0,0.5))
 	name_font:setPosition(ccp(14,nameBg:getContentSize().height*0.5))
 	nameBg:addChild(name_font)

 	-- 任务描述
 	local str = tcellData.achie_des or GetLocalizeStringBy("key_10000")
 	local taskDes = CCLabelTTF:create(str,g_sFontName,23)
 	taskDes:setColor(ccc3(0x78,0x25,0x00))
 	taskDes:setAnchorPoint(ccp(0,1))
 	taskDes:setPosition(ccp(135,cellBg:getContentSize().height-65))
 	cellBg:addChild(taskDes)

 	-- 获得的积分
 	local scoreBg = CCSprite:create("images/everyday/score_bg.png")
 	scoreBg:setAnchorPoint(ccp(0,0))
 	scoreBg:setPosition(ccp(135,20))
 	cellBg:addChild(scoreBg)
 	local str = GetLocalizeStringBy("zzh_1246")
 	local hude_font = CCLabelTTF:create(str,g_sFontPangWa,21)
 	hude_font:setColor(ccc3(0xff,0xe4,0x00))
 	hude_font:setAnchorPoint(ccp(0,0.5))
 	hude_font:setPosition(ccp(25,scoreBg:getContentSize().height*0.5))
 	scoreBg:addChild(hude_font)


 	local rewardNode = ItemUtil.getNodeByStr(tcellData.achie_reward,true)

 	hude_font:addChild(rewardNode)
 	rewardNode:setAnchorPoint(ccp(0,0))
 	rewardNode:setPosition(ccp(hude_font:getContentSize().width,0))

 	-- local str = tcellData.dbData.score or GetLocalizeStringBy("key_10000")
 	-- local hude_font = CCLabelTTF:create(str,g_sFontPangWa,21)
 	-- hude_font:setColor(ccc3(0x00,0xff,0x18))
 	-- hude_font:setAnchorPoint(ccp(0,0.5))
 	-- hude_font:setPosition(ccp(125,scoreBg:getContentSize().height*0.5))
 	-- scoreBg:addChild(hude_font)

 	-- 按钮
 	if(tcellData.status==2)then
 		-- 进度 已完成
 		local overSp = CCSprite:create("images/everyday/wancheng.png")
 		overSp:setAnchorPoint(ccp(1,0.5))
 		overSp:setPosition(ccp(cellBg:getContentSize().width-25,cellBg:getContentSize().height*0.5))
 		cellBg:addChild(overSp)
 	elseif(tcellData.status==1)then
 		-- 前往按钮
		local skipMenu = BTSensitiveMenu:create()
		if(skipMenu:retainCount()>1)then
			skipMenu:release()
			skipMenu:autorelease()
		end
		skipMenu:setTouchPriority(-422)
		skipMenu:setPosition(ccp(0,0))
		cellBg:addChild(skipMenu,0,tcellData.id)
		local skipMenuItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png")
		skipMenuItem:setAnchorPoint(ccp(1,0.5))
		skipMenuItem:setPosition(ccp(cellBg:getContentSize().width-25, cellBg:getContentSize().height*0.5))
		skipMenu:addChild(skipMenuItem,1,tcellData.id)
		-- 注册挑战回调
		skipMenuItem:registerScriptTapHandler(skipMenuItemCallFun)
		-- 阵容字体
		local item_font = CCRenderLabel:create( GetLocalizeStringBy("zzh_1247") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    item_font:setAnchorPoint(ccp(0.5,0.5))
	    item_font:setPosition(ccp(skipMenuItem:getContentSize().width*0.5,skipMenuItem:getContentSize().height*0.5))
	   	skipMenuItem:addChild(item_font)
	elseif(tcellData.status==0)then
		local finishArry = string.split(tcellData.finish_arry, "|")
 		local str = ""
 		local finishCount = 0
 		local finishStr = ""
    	if(tonumber(tcellData.finishNum)>=10000)then
    		local big,small = math.modf(tonumber(tcellData.finishNum)/10000)
    		-- if(small~=0)then
    			finishStr = big..GetLocalizeStringBy("key_2593")
    		-- end
    	else
    		finishStr = tostring(tcellData.finishNum)
    	end
 		if((#finishArry)==2)then
 			if(tonumber(tcellData.sort)==1004 or tonumber(tcellData.sort)==1006 or tonumber(tcellData.sort)==1007 or tonumber(tcellData.sort)==2015)then
 				if(tonumber(finishArry[2])>=10000)then
 					local finishN = math.modf(tonumber(finishArry[2])/10000)
 					str = GetLocalizeStringBy("zzh_1248") .. 0 .. "/" .. finishN..GetLocalizeStringBy("key_2593")
 				else
 					str = GetLocalizeStringBy("zzh_1248") .. 0 .. "/" .. finishArry[2]
 				end

 			else
 				if(tonumber(finishArry[2])>=10000)then
 					local finishN = math.modf(tonumber(finishArry[2])/10000)
 					str = GetLocalizeStringBy("zzh_1248") .. finishStr .. "/" .. finishN..GetLocalizeStringBy("key_2593")
 					finishNum = finishArry[2]
 				else
 					str = GetLocalizeStringBy("zzh_1248") .. finishStr .. "/" .. finishArry[2]
 					finishNum = finishArry[2]
 				end
 			end
 		else
 			if(tonumber(tcellData.sort)==1004 or tonumber(tcellData.sort)==1006 or tonumber(tcellData.sort)==1007 or tonumber(tcellData.sort)==2015
 			 or tonumber(tcellData.sort)==2027)then
 				if(tonumber(finishArry[1])>=10000)then
 					local finishN = math.modf(tonumber(finishArry[1])/10000)
 					str = GetLocalizeStringBy("zzh_1248") .. 0 .. "/" .. 1
 				else
 					str = GetLocalizeStringBy("zzh_1248") .. 0 .. "/" .. 1
 				end
 			else
 				if(tonumber(finishArry[1])>=10000)then
 					local finishN = math.modf(tonumber(finishArry[1])/10000)
 					str = GetLocalizeStringBy("zzh_1248") .. finishStr .. "/" .. finishN..GetLocalizeStringBy("key_2593")
	 				finishNum = finishArry[1]
 				else
	 				str = GetLocalizeStringBy("zzh_1248") .. finishStr .. "/" .. finishArry[1]
	 				finishNum = finishArry[1]
	 			end

	 		end
 		end

 		local jindu_font = CCLabelTTF:create(str,g_sFontName,23)
 		jindu_font:setColor(ccc3(0x03,0x93,0x00))
 		jindu_font:setAnchorPoint(ccp(1,0.5))
 		 		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 			jindu_font:setPosition(ccp(cellBg:getContentSize().width-25,cellBg:getContentSize().height*0.5 - 25))
 		else
 			jindu_font:setPosition(ccp(cellBg:getContentSize().width-25,cellBg:getContentSize().height*0.5))
 		end
 		cellBg:addChild(jindu_font)
 	end

	return cell
end

-- 前往 按钮回调
function skipMenuItemCallFun( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(ItemUtil.isBagFull() == true )then
		AchievementLayer.closeAction()
		return
	end
	require "script/ui/hero/HeroPublicUI"
	if HeroPublicUI.showHeroIsLimitedUI() then
		AchievementLayer.closeAction()
    	return
    end
	tagCpy = tag
	itemCpy = itemBtn
	for j=1,table.count(AchievementLayer.childTable[tagKey]) do
		for k = 1,table.count(AchievementLayer.childTable[tagKey][j]) do
			if(tonumber(AchievementLayer.childTable[tagKey][j][k].id) == tonumber(tag))then
				jKey = j
				Key = k
				break
			end
		end
	end
	tolua.cast(itemCpy,"CCMenuItemImage")
	local args = Network.argsHandler(tag, 1)
	RequestCenter.getRewardAchie(dataCallBack,args)
end

-- 网络消息回调
function dataCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.ret == "ok")then
		showRewardById(tagCpy)
		local overSp = CCSprite:create("images/everyday/wancheng.png")
 		overSp:setAnchorPoint(ccp(1,0.5))
 		overSp:setPosition(itemCpy:getPosition())
 		itemCpy:getParent():getParent():addChild(overSp)
		itemCpy:removeFromParentAndCleanup(true)
		itemCpy = nil
		AchievementLayer.freshMainLayer(tagKey,jKey,tagCpy,Key)
	end
end

function showRewardById( achieId )

	require "db/DB_Achie_table"
	require "script/ui/item/ItemUtil"
	require "script/ui/item/ReceiveReward"

	local achieData= DB_Achie_table.getDataById(tonumber(achieId))
	local achie_reward = ItemUtil.getItemsDataByStr( achieData.achie_reward)
    ReceiveReward.showRewardWindow( achie_reward, nil , 10008, -800 )
    ItemUtil.addRewardByTable(achie_reward)

end


























