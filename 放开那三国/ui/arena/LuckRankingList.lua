-- FileName: LuckRankingList.lua 
-- Author: Li Cong 
-- Date: 13-8-16 
-- Purpose: function description of module 


module("LuckRankingList", package.seeall)

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end


-- 创建幸运排行榜
function createLuckRankingLayer( ... )
	mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(mainLayer,1999,78432)

	-- 创建背景
	local backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    backGround:setContentSize(CCSizeMake(630, 725))
    backGround:setAnchorPoint(ccp(0.5,0.5))
    backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5 - 24))
    mainLayer:addChild(backGround)
    -- 适配
    setAdaptNode(backGround)
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(backGround:getContentSize().width/2, backGround:getContentSize().height-6.6 ))
	backGround:addChild(titlePanel)
	    --兼容东南亚英文版
    local titleLabel
    if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
        titleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_3319"), g_sFontPangWa, 25)
    else
        titleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_3319"), g_sFontPangWa, 34)
    end
	titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	titleLabel:setPosition(ccp(90, 10))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-420)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(backGround:getContentSize().width * 0.955, backGround:getContentSize().height*0.965 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 二级背景
	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
 	local second_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
 	second_bg:setContentSize(CCSizeMake(584,640))
 	second_bg:setAnchorPoint(ccp(0.5,1))
 	second_bg:setPosition(ccp(backGround:getContentSize().width*0.5,backGround:getContentSize().height-45))
 	backGround:addChild(second_bg)

 	-- 上轮幸运排行榜
 	-- 背景
 	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(25, 25, 20, 20)
 	local last_bg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png", fullRect, insetRect)
	last_bg:setContentSize(CCSizeMake(320,456))
	last_bg:setAnchorPoint(ccp(0,1))
	last_bg:setPosition(ccp(10,second_bg:getContentSize().height - 30))
	second_bg:addChild(last_bg)
	-- 标题
	local fullRect = CCRectMake(0, 0, 75, 35)
    local insetRect = CCRectMake(25, 15, 20, 10)
	local last_title_bg = CCScale9Sprite:create("images/common/astro_labelbg.png", fullRect, insetRect)
	last_title_bg:setContentSize(CCSizeMake(196,35))
	last_title_bg:setAnchorPoint(ccp(0.5,0.5))
	last_title_bg:setPosition(ccp(last_bg:getContentSize().width*0.5,last_bg:getContentSize().height-2 ))
	last_bg:addChild(last_title_bg)
	-- 标题字体
	 
    local last_title_font
    if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
        last_title_font =  LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2443"), g_sFontPangWa, 18)
    else
	   last_title_font =  LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2443"), g_sFontPangWa, 24)
    end
	last_title_font:setColor(ccc3(0xff, 0xf6, 0x00))
	last_title_font:setPosition(ccp(25, 3))
	last_title_bg:addChild(last_title_font)
	-- 名次
	local last_position_font = CCLabelTTF:create( GetLocalizeStringBy("key_1741"), g_sFontName,24)
    last_position_font:setColor(ccc3(0xff,0xf6,0x00))
    last_position_font:setAnchorPoint(ccp(0,1))
    last_position_font:setPosition(ccp(20,last_bg:getContentSize().height-25))
    last_bg:addChild(last_position_font)
    -- 姓名
	local last_name_font = CCLabelTTF:create( GetLocalizeStringBy("key_1167"), g_sFontName,24)
    last_name_font:setColor(ccc3(0xff,0xf6,0x00))
    last_name_font:setAnchorPoint(ccp(0.5,1))
    last_name_font:setPosition(ccp(last_bg:getContentSize().width*0.5,last_bg:getContentSize().height-25))
    last_bg:addChild(last_name_font)
    -- 金币
    local last_gold_font = CCLabelTTF:create( GetLocalizeStringBy("key_1491"), g_sFontName,24)
    last_gold_font:setColor(ccc3(0xff,0xf6,0x00))
    last_gold_font:setAnchorPoint(ccp(1,1))
    last_gold_font:setPosition(ccp(last_bg:getContentSize().width-20,last_bg:getContentSize().height-25))
    last_bg:addChild(last_gold_font)
    -- 文字背景
    for i=1,10 do
  	    -- 奇数
      	if( math.floor(i%2) == 1 )then
      		local fullRect = CCRectMake(0, 0, 106, 39)
      		local insetRect = CCRectMake(25, 15, 10, 10)
      		local last_font_bg = CCScale9Sprite:create("images/arena/lucknamebg_qian.png", fullRect, insetRect)
    	  	last_font_bg:setContentSize(CCSizeMake(316,39))
    	  	last_font_bg:setAnchorPoint(ccp(0.5,1))
    	  	last_font_bg:setPosition(ccp(last_bg:getContentSize().width*0.5,last_bg:getContentSize().height-(i-1)*last_font_bg:getContentSize().height-59))
    	  	last_bg:addChild(last_font_bg,1,i)
      	end
      	-- 偶数
      	if( math.floor(i%2) == 0 )then
      		local fullRect = CCRectMake(0, 0, 106, 39)
      		local insetRect = CCRectMake(25, 15, 10, 10)
      		local last_font_bg = CCScale9Sprite:create("images/arena/lucknamebg_shen.png", fullRect, insetRect)
    	  	last_font_bg:setContentSize(CCSizeMake(316,39))
    	  	last_font_bg:setAnchorPoint(ccp(0.5,1))
    	  	last_font_bg:setPosition(ccp(last_bg:getContentSize().width*0.5,last_bg:getContentSize().height-(i-1)*last_font_bg:getContentSize().height-59))
    	  	last_bg:addChild(last_font_bg,1,i)
      	end
    end
    -- 上轮幸运排名玩家数据
    if(ArenaData.luckyListData.last ~= nil and ArenaData.tableCount(ArenaData.luckyListData.last) ~= 0 )then
    	for k,v in pairs(ArenaData.luckyListData.last) do
    		-- 名次数据
    		local last_parent = tolua.cast(last_bg:getChildByTag(tonumber(k)),"CCScale9Sprite")
    		local last_positionData = CCLabelTTF:create(v.position, g_sFontName,24)
		    last_positionData:setColor(ccc3(0xff,0xf6,0x00))
		    last_positionData:setAnchorPoint(ccp(0.5,0.5))
		    last_positionData:setPosition(ccp(42,last_parent:getContentSize().height*0.5-2))
		    last_parent:addChild(last_positionData)
		    -- 名字
            -- 判断是否是npc
            local isNpc = nil
            if(tonumber(v.uid) >= 11001 and tonumber(v.uid) <= 16000)then
                isNpc = true
            end
            if( isNpc )then
                -- npc
                local name = ArenaData.getNpcName( tonumber(v.uid), tonumber(v.utid))
                local last_nameData = CCLabelTTF:create( name , g_sFontName,24)
                last_nameData:setColor(ccc3(0xff,0xff,0xff))
                last_nameData:setAnchorPoint(ccp(0.5,0.5))
                last_nameData:setPosition(ccp(last_parent:getContentSize().width*0.5,last_parent:getContentSize().height*0.5-2))
                last_parent:addChild(last_nameData)
            else
                -- 不是npc
                if(v.uname ~= nil)then
        		    local last_nameData = CCLabelTTF:create(v.uname, g_sFontName,24)
        		    last_nameData:setColor(ccc3(0xff,0xff,0xff))
        		    last_nameData:setAnchorPoint(ccp(0.5,0.5))
        		    last_nameData:setPosition(ccp(last_parent:getContentSize().width*0.5,last_parent:getContentSize().height*0.5-2))
        		    last_parent:addChild(last_nameData)
                end
            end
		    -- 金币数据
    		local last_goldData = CCLabelTTF:create(v.gold, g_sFontName,24)
		    last_goldData:setColor(ccc3(0xff,0xff,0xff))
		    last_goldData:setAnchorPoint(ccp(0.5,0.5))
		    last_goldData:setPosition(ccp(last_parent:getContentSize().width-42,last_parent:getContentSize().height*0.5-2))
		    last_parent:addChild(last_goldData)
    	end
    end

  	-- 本轮幸运排名
  	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(25, 25, 20, 20)
   	local cur_bg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png", fullRect, insetRect)
  	cur_bg:setContentSize(CCSizeMake(235,456))
  	cur_bg:setAnchorPoint(ccp(1,1))
  	cur_bg:setPosition(ccp(second_bg:getContentSize().width-10,second_bg:getContentSize().height - 30))
  	second_bg:addChild(cur_bg)
  	-- 标题
  	local fullRect = CCRectMake(0, 0, 75, 35)
    local insetRect = CCRectMake(25, 15, 20, 10)
  	local cur_title_bg = CCScale9Sprite:create("images/common/astro_labelbg.png", fullRect, insetRect)
  	cur_title_bg:setContentSize(CCSizeMake(196,35))
  	cur_title_bg:setAnchorPoint(ccp(0.5,0.5))
  	cur_title_bg:setPosition(ccp(cur_bg:getContentSize().width*0.5,cur_bg:getContentSize().height-2 ))
  	cur_bg:addChild(cur_title_bg)
  	-- 标题字体
  	--兼容东南亚英文版
local cur_title_font
if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    cur_title_font =  LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2752"), g_sFontPangWa, 18)
else
	     cur_title_font =  LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2752"), g_sFontPangWa, 24)
 end
	cur_title_font:setColor(ccc3(0xff, 0xf6, 0x00))
	cur_title_font:setPosition(ccp(25, 3))
	cur_title_bg:addChild(cur_title_font)
	-- 名次
	local cur_position_font = CCLabelTTF:create( GetLocalizeStringBy("key_1741"), g_sFontName,24)
    cur_position_font:setColor(ccc3(0xff,0xf6,0x00))
    cur_position_font:setAnchorPoint(ccp(0,1))
    cur_position_font:setPosition(ccp(46,cur_bg:getContentSize().height-25))
    cur_bg:addChild(cur_position_font)
    -- 金币
	local cur_gold_font = CCLabelTTF:create( GetLocalizeStringBy("key_1491"), g_sFontName,24)
    cur_gold_font:setColor(ccc3(0xff,0xf6,0x00))
    cur_gold_font:setAnchorPoint(ccp(1,1))
    cur_gold_font:setPosition(ccp(cur_bg:getContentSize().width-28,cur_bg:getContentSize().height-25))
    cur_bg:addChild(cur_gold_font)
    -- 文字背景
    for i=1,10 do
    	-- 奇数
    	if( math.floor(i%2) == 1 )then
    		local fullRect = CCRectMake(0, 0, 106, 39)
    		local insetRect = CCRectMake(25, 15, 10, 10)
    		local cur_font_bg = CCScale9Sprite:create("images/arena/lucknamebg_qian.png", fullRect, insetRect)
		  	cur_font_bg:setContentSize(CCSizeMake(232,39))
		  	cur_font_bg:setAnchorPoint(ccp(0.5,1))
		  	cur_font_bg:setPosition(ccp(cur_bg:getContentSize().width*0.5,cur_bg:getContentSize().height-(i-1)*cur_font_bg:getContentSize().height-59))
		  	cur_bg:addChild(cur_font_bg,1,i)
    	end
    	-- 偶数
    	if( math.floor(i%2) == 0 )then
    		local fullRect = CCRectMake(0, 0, 106, 39)
    		local insetRect = CCRectMake(25, 15, 10, 10)
    		local cur_font_bg = CCScale9Sprite:create("images/arena/lucknamebg_shen.png", fullRect, insetRect)
		  	cur_font_bg:setContentSize(CCSizeMake(232,39))
		  	cur_font_bg:setAnchorPoint(ccp(0.5,1))
		  	cur_font_bg:setPosition(ccp(cur_bg:getContentSize().width*0.5,cur_bg:getContentSize().height-(i-1)*cur_font_bg:getContentSize().height-59))
		  	cur_bg:addChild(cur_font_bg,1,i)
    	end
    end
    -- 本轮幸运排名数据
    if(ArenaData.luckyListData.current ~= nil and ArenaData.tableCount(ArenaData.luckyListData.current) ~= 0 )then
    	for k,v in pairs(ArenaData.luckyListData.current) do
    		-- 名次数据
    		local cur_parent = tolua.cast(cur_bg:getChildByTag(tonumber(k)),"CCScale9Sprite")
    		local cur_positionData = CCLabelTTF:create(v.position, g_sFontName,24)
		    cur_positionData:setColor(ccc3(0xff,0xf6,0x00))
		    cur_positionData:setAnchorPoint(ccp(0.5,0.5))
		    cur_positionData:setPosition(ccp(70,cur_parent:getContentSize().height*0.5-2))
		    cur_parent:addChild(cur_positionData)
		    -- 金币数据
    		local cur_goldData = CCLabelTTF:create(v.gold, g_sFontName,24)
		    cur_goldData:setColor(ccc3(0xff,0xff,0xff))
		    cur_goldData:setAnchorPoint(ccp(0.5,0.5))
		    cur_goldData:setPosition(ccp(cur_parent:getContentSize().width-50,cur_parent:getContentSize().height*0.5-2))
		    cur_parent:addChild(cur_goldData)
    	end
    end

    -- 幸运排名说明
    --[[
    	1.※每轮竞技场结束后，竞技场幸运排名将随机刷新。
        2.※处于幸运排名的玩家将在每轮结束后获得额外的金币奖励。
    --]]
    local str1 = GetLocalizeStringBy("key_1690")
    local luckRankDes_one =  CCLabelTTF:create(str1, g_sFontName,24)
    luckRankDes_one:setColor(ccc3(0x04,0xe4,0xff))
    luckRankDes_one:setAnchorPoint(ccp(0,0))
    luckRankDes_one:setPosition(ccp(10,106))
    second_bg:addChild(luckRankDes_one)
    local str2 = GetLocalizeStringBy("key_2901")
    local luckRankDes_two =  CCLabelTTF:create(str2, g_sFontName,24)
    luckRankDes_two:setColor(ccc3(0x04,0xe4,0xff))
    luckRankDes_two:setAnchorPoint(ccp(0,0))
    luckRankDes_two:setPosition(ccp(10,55))
    second_bg:addChild(luckRankDes_two)
    local str3 = GetLocalizeStringBy("key_1491")
    local luckRankDes_three =  CCLabelTTF:create(str3, g_sFontName,24)
    luckRankDes_three:setColor(ccc3(0xff,0xf6,0x00))
    luckRankDes_three:setAnchorPoint(ccp(0,0))
    luckRankDes_three:setPosition(ccp(luckRankDes_two:getPositionX()+luckRankDes_two:getContentSize().width,55))
    second_bg:addChild(luckRankDes_three)
    local str4 = GetLocalizeStringBy("key_1052")
    local luckRankDes_four =  CCLabelTTF:create(str4, g_sFontName,24)
    luckRankDes_four:setColor(ccc3(0x04,0xe4,0xff))
    luckRankDes_four:setAnchorPoint(ccp(0,0))
    luckRankDes_four:setPosition(ccp(10,15))
    second_bg:addChild(luckRankDes_four)

	return mainLayer
end


-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	mainLayer:removeFromParentAndCleanup(true)
	mainLayer = nil
end

























