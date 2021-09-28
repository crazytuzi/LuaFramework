-- FileName: NewYearCell.lua 
-- Author: Li Cong 
-- Date: 14-1-18 
-- Purpose: function description of module 


module("NewYearCell", package.seeall)
require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"
require "script/ui/rechargeActive/RechargeActiveMain"
local _costNum = nil
local cellBg
function createCell(tCellValues)
	_costNum = tonumber(tCellValues.cost)
	print("tCellValues--")
	print_t(tCellValues)
	print("tCellValues.id",tCellValues.id)
	local tCell = CCTableViewCell:create()
	-- 背景
	cellBg = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
	cellBg:setContentSize(CCSizeMake(588,202))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	tCell:addChild(cellBg)
	-- 描述
	local  descBg= CCScale9Sprite:create("images/sign/sign_bottom.png")
	descBg:setContentSize(CCSizeMake(284,55))
	descBg:setPosition(ccp(3,cellBg:getContentSize().height*0.72))
	cellBg:addChild(descBg)

	local desStr = tCellValues.des or " "
	local desLabel = CCRenderLabel:create( desStr, g_sFontName,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	desLabel:setColor(ccc3(0xff,0xfb,0xd9))
	desLabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height*0.5+2))
	desLabel:setAnchorPoint(ccp(0.5,0.5))
	descBg:addChild(desLabel)

	-- 领取按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	cellBg:addChild(menu)
	menu:setTouchPriority(-134)
	local normalSprite  = CCSprite:create("images/level_reward/receive_btn_n.png")
    local selectSprite  = CCSprite:create("images/level_reward/receive_btn_h.png")
    local disabledSprite = BTGraySprite:create("images/level_reward/receive_btn_n.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    item:setAnchorPoint(ccp(1,0.5))
    item:setPosition(ccp(cellBg:getContentSize().width-10,cellBg:getContentSize().height*0.5))
    menu:addChild(item,1,tonumber(tCellValues.id))
    item:registerScriptTapHandler(itemCallFun)

  
    --累计登陆规则改变   add by fuqiongqiong 2016.3.2
    --先判断id与登陆天数，若小于
    local isHaveGet = ActiveCache.isHaveGetNewYearRewardById(tCellValues.id)
    print("tCellValues.id~~~",tCellValues.id)
    print("isHaveGet~~~")
    print_t(isHaveGet)
    local id = tonumber(tCellValues.id)
    local dayNum = ActiveCache.getTobayNum() or " "
    print("dayNum",dayNum)
    if id < dayNum then
    	--如果有已领取的
    	if(isHaveGet)then
    		--已经领取
  --   		local fontStr = GetLocalizeStringBy("key_1369")
  --   			--兼容东南亚英文版
  --   			local itemFont
  --   			if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout")then
  --   				itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
  --   			else
  --   				itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 35, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
  --   			end
  --   	itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
		-- itemFont:setAnchorPoint(ccp(0.5,0.5))
		-- itemFont:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
		-- item:addChild(itemFont,1,123)
		-- -- 按钮不可点，文字颜色置灰
		item:setVisible(false)
		local hasReceiveItem = CCSprite:create("images/sign/receive_already.png")
		hasReceiveItem:setAnchorPoint(ccp(1,0.5))
		hasReceiveItem:setPosition(ccp(cellBg:getContentSize().width-10,cellBg:getContentSize().height*0.5))
		cellBg:addChild(hasReceiveItem)
		else
		--为补签
		local fontStr = GetLocalizeStringBy("fqq_057")
		--兼容东南亚英文版
    	local itemFont
    		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout")then
    			itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    		else
    			itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 35, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    		end
    	itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
		itemFont:setAnchorPoint(ccp(0.5,0.5))
		itemFont:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
		item:addChild(itemFont,1,123)
		end
	elseif id == dayNum then
		--在这个情况下只有领取和已领取的可能性
		--当已领取时
		if(isHaveGet)then
			--已经领取
  --   		local fontStr = GetLocalizeStringBy("key_1369")
  --   			--兼容东南亚英文版
  --   			local itemFont
  --   			if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout")then
  --   				itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
  --   			else
  --   				itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 35, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
  --   			end
  --   	itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
		-- itemFont:setAnchorPoint(ccp(0.5,0.5))
		-- itemFont:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
		-- item:addChild(itemFont,1,123)
		-- -- 按钮不可点，文字颜色置灰
		-- item:setEnabled(false)
		item:setVisible(false)
		local hasReceiveItem = CCSprite:create("images/sign/receive_already.png")
		hasReceiveItem:setAnchorPoint(ccp(1,0.5))
		hasReceiveItem:setPosition(ccp(cellBg:getContentSize().width-10,cellBg:getContentSize().height*0.5))
		cellBg:addChild(hasReceiveItem)
		else
		local fontStr = GetLocalizeStringBy("key_1085") --领取
				--兼容东南亚英文版
		local itemFont
    		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    		itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    		else
			itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 35, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
			end
		itemFont:setColor(ccc3(0xfe,0xdb,0x1c))
		itemFont:setAnchorPoint(ccp(0.5,0.5))
		itemFont:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
		item:addChild(itemFont,1,123)
		end
	else
		local fontStr = GetLocalizeStringBy("key_1085") --领取
				--兼容东南亚英文版
		local itemFont
    	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    		itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    	else
			itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 35, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
		end
		itemFont:setColor(ccc3(0xfe,0xdb,0x1c))
		itemFont:setAnchorPoint(ccp(0.5,0.5))
		itemFont:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
		item:addChild(itemFont,1,123)
		-- 判断是否够资格领取
		if id > dayNum then
			-- 登录天数不够 不够资格领取 按钮不可点且置灰
			item:setEnabled(false)
			itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
		end
 	end
   
   
	

	-- 物品背景
	local rewardBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png") 
	rewardBg:setContentSize(CCSizeMake(423,132))
	rewardBg:setPosition(ccp(10,10))
	cellBg:addChild(rewardBg)

	-- 创建goods列表
	-- print("str***",tCellValues.reward)
	local all_good = ActiveCache.getItemsDataByStr(tCellValues.reward)
	print("all_good++")
	print_t(all_good)
	local cellSize = CCSizeMake(101, 120)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           a2 = createGoodListCell(all_good[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			local num = #all_good
			r = num
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(420, 120))
	goodTableView:setBounceable(true)
	goodTableView:setTouchEnabled(false)
	if( table.count(all_good) > 4) then
		goodTableView:setTouchEnabled(true)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setPosition(ccp(1, 0))
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	rewardBg:addChild(goodTableView)
	goodTableView:setTouchPriority(-133)

	--添加一个右侧屏蔽layer 优先级为-131
	-- touch事件处理
	local pingbiLayer = CCLayer:create()
	local function cardLayerTouch(eventType, x, y)
		local rect = getSpriteScreenRect(pingbiLayer)
		if(rect:containsPoint(ccp(x,y))) then
			return true
		else
			return false
		end
	end
	-- local pingbiLayer = CCLayerColor:create(ccc4(255,0,0,255))
	pingbiLayer:setContentSize(CCSizeMake(155,185))
	pingbiLayer:setTouchEnabled(true)
	pingbiLayer:registerScriptTouchHandler(cardLayerTouch,false,-131,true)
	pingbiLayer:ignoreAnchorPointForPosition(false)
	pingbiLayer:setAnchorPoint(ccp(1,0))
	pingbiLayer:setPosition(cellBg:getContentSize().width,0)
	cellBg:addChild(pingbiLayer)

	return tCell
end

-- 查看物品信息返回回调 为了显示下排按钮
function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, false)
end

-- 创建展示物品列表cell
function createGoodListCell( cellValues )
	print("//////////")
	print_t(cellValues)
	local cell = CCTableViewCell:create()
	local iconBg = nil
	local iconName = nil
	local nameColor = nil
	if(cellValues.type == "silver") then
		-- 银币
		iconBg= ItemSprite.getSiliverIconSprite()
		iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "soul") then
		-- 将魂
		iconBg= ItemSprite.getSoulIconSprite()
		iconName = GetLocalizeStringBy("key_1616")
		local quality = ItemSprite.getSoulQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "gold") then
		-- 金币
		iconBg= ItemSprite.getGoldIconSprite()
		iconName = GetLocalizeStringBy("key_1491")
		local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "item") then
		-- 物品
		iconBg =  ItemSprite.getItemSpriteById(tonumber(cellValues.tid),nil, showDownMenu, nil, -130, nil, -500)
		local itemData = ItemUtil.getItemById(cellValues.tid)
        iconName = itemData.name
        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	elseif(cellValues.type == "hero") then
		-- 英雄
		require "db/DB_Heroes"
		iconBg = ItemSprite.getHeroIconItemByhtid(cellValues.tid,-130)
		local heroData = DB_Heroes.getDataById(cellValues.tid)
		iconName = heroData.name
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	elseif(cellValues.type == "prestige") then
		-- 声望
		iconBg= ItemSprite.getPrestigeSprite()
		iconName = GetLocalizeStringBy("key_2231")
		local quality = ItemSprite.getPrestigeQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "jewel") then
		-- 魂玉
		iconBg= ItemSprite.getJewelSprite()
		iconName = GetLocalizeStringBy("key_1510")
		local quality = ItemSprite.getJewelQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "execution") then
		-- 体力
		iconBg= ItemSprite.getExecutionSprite()
		iconName = GetLocalizeStringBy("key_1032")
		local quality = ItemSprite.getExecutionQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "stamina") then
		-- 耐力
		iconBg= ItemSprite.getStaminaSprite()
		iconName = GetLocalizeStringBy("key_2021")
		local quality = ItemSprite.getStaminaQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	end
	iconBg:setAnchorPoint(ccp(0,1))
	iconBg:setPosition(ccp(10,120))
	cell:addChild(iconBg)

	-- 物品数量
	if( tonumber(cellValues.num) > 1 )then
		local numberLabel =  CCRenderLabel:create("" .. cellValues.num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
		numberLabel:setColor(ccc3(0x00,0xff,0x18))
		numberLabel:setAnchorPoint(ccp(0,0))
		local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
		numberLabel:setPosition(ccp(width,5))
		iconBg:addChild(numberLabel)
	end

	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.1-2))
	iconBg:addChild(descLabel)

	return cell
end


-- 领取回调
function itemCallFun( tag, item)
	local dayNum = ActiveCache.getTobayNum()
	--判断是从领取还是补签的回调,若小于则是补签
	if tag < dayNum then
		-- 提示
        local richInfo = {
            elements = {
                
                {
                    text = _costNum
                },
                {
                	["type"] = "CCSprite",
                	image = "images/common/gold.png"
           		 }
            }
        }
        local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("fqq_058"), richInfo)  
        local alertCallback = function ( isConfirm, _argsCB )
            if not isConfirm then
                return
            end
            --判断金币
            if _costNum > UserModel.getGoldNumber() then
        		AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
        		return
    		end
            ButtonCallback(tag, item )
        end
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil)
    else
    	ButtonCallback(tag, item )
	end
	
end


function ButtonCallback( tag, item )
	-- 判断活动是否结束
	print(GetLocalizeStringBy("key_2300"), BTUtil:getSvrTimeInterval())
	print(GetLocalizeStringBy("key_2737"),ActiveCache.getNewYearEndTime())
	if( BTUtil:getSvrTimeInterval()<ActiveCache.getNewYearStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getNewYearEndTime() ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2365"))
		return
	end	
	-- 物品背包满了
	require "script/ui/item/ItemUtil"
	if(ItemUtil.isBagFull() == true )then
		return
	end
	-- 武将满了
	require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
    	return
    end
	local function requestCallback( cbFlag, dictData, bRet  )
		if(dictData.err == "ok") then
			-- 按钮置灰
			item:setVisible(false)
		-- 	-- 已经领取
		-- 	tolua.cast(item:getChildByTag(123),"CCRenderLabel"):removeFromParentAndCleanup(true)
		-- 	local fontStr = GetLocalizeStringBy("key_1369")
		-- 			--兼容东南亚英文版
		-- local itemFont
  --   	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
  --   		itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
  --   	else
		-- 	itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 35, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
		-- end
		-- 	itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
		-- 	itemFont:setAnchorPoint(ccp(0.5,0.5))
		-- 	itemFont:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
		-- 	item:addChild(itemFont,1,123)
			-- local hasReceiveItem = CCSprite:create("images/sign/receive_already.png")
			-- hasReceiveItem:setAnchorPoint(ccp(1,0.5))
			-- hasReceiveItem:setPosition(ccp(item:getContentSize().width-10,item:getContentSize().height*0.5))
			-- print("已领取-------")
			-- item:addChild(hasReceiveItem)
			-- 把这条奖励加入已领取列表
			ActiveCache.addHaveGetNewYearRewardId(tag)
			-- 加奖励数据
			ActiveCache.addNewYearRewardById(tag)
			NewYearLayer.updataTableView()
			-- 展示活动的奖励
			require "script/ui/item/ReceiveReward"
		    local data = ActivityConfig.ConfigCache.signActivity.data[tag]
		    local thisData = ActiveCache.getItemsDataByStr(data.reward)
 			ReceiveReward.showRewardWindow( thisData )
 			--扣金币
 			local dayNum = ActiveCache.getTobayNum()
 			--刷新小红点
 			RechargeActiveMain.refreshNewYearTip()
		--判断是从领取还是补签的回调,若小于则是补签
			if tag < dayNum then
				-- 刷新成功，减去金币
        	UserModel.addGoldNumber(- _costNum)
			end
		end
	end
	local args= CCArray:create()
	args:addObject(CCInteger:create(tag))
	Network.rpc(requestCallback, "signactivity.gainSignactivityReward", "signactivity.gainSignactivityReward", args, true)
end
