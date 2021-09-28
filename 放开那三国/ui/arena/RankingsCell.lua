-- FileName: RankingsCell.lua 
-- Author: Li Cong 
-- Date: 13-8-14 
-- Purpose: function description of module 

module("RankingsCell", package.seeall)

local timeDown             -- 倒计时

-- 创建挑战单元格
function createCell( tCellValue )
	-- print(GetLocalizeStringBy("key_2154"))
	-- print_t(tCellValue)

	local cell = CCTableViewCell:create()
	-- 判断是否是npc
	local isNpc = nil
	if(tonumber(tCellValue.uid) >= 11001 and tonumber(tCellValue.uid) <= 16000)then
		isNpc = true
	end
	-- 背景
	-- 区分自己和别的玩家
	local fileName = nil
		if(tonumber(tCellValue.position) < 4)then
			fileName = "images/arena/" .. tCellValue.position .. ".png"
		else
			fileName = "images/arena/rankings_cellbg.png"
		end
	-- end
	local cellBg = CCSprite:create( fileName )
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg,1,tonumber(tCellValue.position))

	-- 玩家名字
	-- 名字背景
	local fullRect = CCRectMake(0,0,47,27)
	local insetRect = CCRectMake(15,12,5,5)
	local name_bg = CCScale9Sprite:create("images/arena/heroname_bg.png", fullRect, insetRect)
	name_bg:setContentSize(CCSizeMake(372,26))
	name_bg:setAnchorPoint(ccp(0,1))
	name_bg:setPosition(ccp(20,cellBg:getContentSize().height-15))
	cellBg:addChild(name_bg)
	-- lv.
	local lv_sprite = CCSprite:create("images/common/lv.png")
	lv_sprite:setAnchorPoint(ccp(0,0.5))
	lv_sprite:setPosition(ccp(10,name_bg:getContentSize().height*0.5))
	name_bg:addChild(lv_sprite)
	-- 等级
	local lv_data = CCRenderLabel:create( tCellValue.level , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,name_bg:getContentSize().height-3))
   	name_bg:addChild(lv_data)
   	-- 名字
   	local name = nil
   	if(isNpc)then
   		-- npc 性别
   		local utid = tonumber(tCellValue.utid)
   		local npc_name = ArenaData.getNpcName( tonumber(tCellValue.uid), utid)
   		-- npc 名字
   		name = CCRenderLabel:create( npc_name , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    name:setColor(ccc3(0xff, 0xff, 0xff))
	    name:setAnchorPoint(ccp(0,1))
	    name:setPosition(ccp(lv_data:getPositionX()+lv_data:getContentSize().width+18,name_bg:getContentSize().height-1))
	   	name_bg:addChild(name)
   	else
   		-- 非npc 名字
	   	name = CCRenderLabel:create( tCellValue.uname , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    name:setColor(ccc3(0xff, 0xff, 0xff))
	    name:setAnchorPoint(ccp(0,1))
	    name:setPosition(ccp(lv_data:getPositionX()+lv_data:getContentSize().width+18,name_bg:getContentSize().height-1))
	   	name_bg:addChild(name)
   	end

   	-- 军团名字
   	if(tCellValue.guild_name)then
        local guildNameStr = tCellValue.guild_name or " "
        local guildNameFont = CCRenderLabel:create( "[" .. guildNameStr .. "]" , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        guildNameFont:setAnchorPoint(ccp(0,1))
        guildNameFont:setColor(ccc3(0xff, 0xf6, 0x00))
        guildNameFont:setPosition(ccp(name:getPositionX()+name:getContentSize().width+20,name_bg:getContentSize().height-1))
        name_bg:addChild(guildNameFont)
    end

   	-- 排名
   	-- 幸
   	if(tonumber(tCellValue.luck) == 1)then
	   	local luckSprite = CCSprite:create("images/arena/luckicon.png")
	   	luckSprite:setAnchorPoint(ccp(0,1))
	   	luckSprite:setPosition(ccp(name_bg:getPositionX()+name_bg:getContentSize().width+15,cellBg:getContentSize().height-4))
	   	cellBg:addChild(luckSprite)
	end
   	-- 排名
   	local curRankings_font = CCRenderLabel:create(GetLocalizeStringBy("key_1442") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curRankings_font:setColor(ccc3(0xff, 0xf6, 0x01))
    curRankings_font:setPosition(ccp(name_bg:getPositionX()+name_bg:getContentSize().width+55,cellBg:getContentSize().height-12))
   	cellBg:addChild(curRankings_font)
   	-- 排名数据
   	local curRankings = CCRenderLabel:create( tCellValue.position, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curRankings:setColor(ccc3(0x36, 0xff, 0x00))
    curRankings:setPosition(ccp(curRankings_font:getPositionX()+curRankings_font:getContentSize().width+7,cellBg:getContentSize().height-12))
   	cellBg:addChild(curRankings)


   	-- 按钮
   	if( tonumber(tCellValue.uid) == UserModel.getUserUid() )then
		-- 如果是主角
		-- 显示领奖倒计时
		local timeDownFont = CCRenderLabel:create( GetLocalizeStringBy("key_3180") , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    timeDownFont:setColor(ccc3(0xff, 0xff, 0xff))
	    timeDownFont:setPosition(ccp(495, cellBg:getContentSize().height-65))
	   	cellBg:addChild(timeDownFont)
		-- 倒计时数据
		local timeStr = nil
		-- 判断是否在领奖中 倒计时时间小于等于0
		if( ArenaData.getAwardTime() <= 0 )then
			timeStr = GetLocalizeStringBy("key_2723")
		else
			-- 倒计时大于0
			timeStr = TimeUtil.getTimeString(ArenaData.getAwardTime())
		end
	   	timeDown = CCLabelTTF:create( timeStr, g_sFontName, 20)
	    timeDown:setColor(ccc3(0x00, 0xf0, 0xff))
	    timeDown:setAnchorPoint(ccp(0,1))
	    timeDown:setPosition(ccp(507, cellBg:getContentSize().height-95))
	   	cellBg:addChild(timeDown)
	   -- 更新倒计时
	   	local function updateRewardTime3()
	   		-- print("updateRewardTime3")
	   		if (ArenaData.getAwardTime() <= 0) then 
	   			-- 到期取消定时器
	   			timeDown:setString(GetLocalizeStringBy("key_2723"))
	   			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.rankScheduleId)
	   			return
	   		end
	   		local timeStr = TimeUtil.getTimeString(ArenaData.getAwardTime())
	   		timeDown:setString(timeStr)
	   	end
	   	
	   	timeDown:registerScriptHandler(function ( eventType,node )
	   		if(eventType == "enter") then
	   			if (ArenaData.getAwardTime() > 0 ) then 
			   		-- 启动定时器
			   		if(ArenaData.rankScheduleId == nil)then
			   			ArenaData.rankScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateRewardTime3, 1, false)
			   		end
			   	end
	   		end
			if(eventType == "exit") then
				if(ArenaData.rankScheduleId ~= nil)then
	   				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.rankScheduleId)
	   				ArenaData.rankScheduleId = nil
		   		end
			end
		end)
	else
		-- 阵容按钮
		local squadMenu = BTSensitiveMenu:create()
		if(squadMenu:retainCount()>1)then
			squadMenu:release()
			squadMenu:autorelease()
		end
		squadMenu:setPosition(ccp(0,0))
		cellBg:addChild(squadMenu,1,tonumber(tCellValue.uid))
		local squadMenuItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png")
		squadMenuItem:setAnchorPoint(ccp(1,0.5))
		squadMenuItem:setPosition(ccp(cellBg:getContentSize().width-20, cellBg:getContentSize().height*0.5))
		if(isNpc)then
	        squadMenu:addChild(squadMenuItem,1,tonumber(tCellValue.armyId))
	    else
	        squadMenu:addChild(squadMenuItem,1,tonumber(tCellValue.uid))
	    end
		-- 注册挑战回调
		squadMenuItem:registerScriptTapHandler(squadMenuItemCallFun)
		-- 阵容字体
		local fontSize = 30
		--兼容东南亚英文版
		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
			fontSize = 18
		end
		local squad_font = CCRenderLabel:create( GetLocalizeStringBy("key_1953") , g_sFontPangWa, fontSize, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    squad_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    squad_font:setPosition(ccp(24,squadMenuItem:getContentSize().height-11))
	   	squadMenuItem:addChild(squad_font)
	end
   

   	-- 名将背景
   	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
   	local hero_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
   	hero_bg:setContentSize(CCSizeMake(444,100))
   	hero_bg:setAnchorPoint(ccp(0,0.5))
   	hero_bg:setPosition(ccp(23,cellBg:getContentSize().height*0.5))
   	cellBg:addChild(hero_bg)

   	if( isNpc )then
   		-- 创建NPC名将头像
	   	local numTem = 0
	   	for k,v in pairs(tCellValue.squad) do
	   		numTem = numTem + 1
	   		local heroIcon = ArenaData.getNpcIconByhid(tonumber(v))
	   		heroIcon:setAnchorPoint(ccp(0,0.5))
	   		heroIcon:setPosition(ccp(5+(heroIcon:getContentSize().width+14)*(numTem-1),hero_bg:getContentSize().height*0.5))
	   		hero_bg:addChild(heroIcon,1,numTem)
	   	end
   	else
	   	-- 创建非NPC名将头像
	   	local numTem = 0
	   	-- added by zhz , vip 特效
	   	local vip = tCellValue.vip or 0
	   	for k,v in pairs(tCellValue.squad) do
	   		numTem = numTem + 1
	   		local dressId = nil
	   		local genderId = nil
	   		if( not table.isEmpty(v.dress) and (v.dress["1"])~= nil and tonumber(v.dress["1"]) > 0 )then
				dressId = v.dress["1"]
				genderId = HeroModel.getSex(v.htid)
			end
			local heroIcon = HeroUtil.getHeroIconByHTID(v.htid, dressId, genderId, vip)
	   		heroIcon:setAnchorPoint(ccp(0,0.5))
	   		heroIcon:setPosition(ccp(5+(heroIcon:getContentSize().width+14)*(numTem-1),hero_bg:getContentSize().height*0.5))
	   		hero_bg:addChild(heroIcon,1,numTem)
	   	end
   	end

   	-- 获得的奖励
   	local silverData,prestigeData,itemStr = ArenaData.getAwardItem(tCellValue.position,tCellValue.level)
   	-- 获得奖励文字
   	local jiangli = CCRenderLabel:create( GetLocalizeStringBy("key_1400"), g_sFontBold, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	jiangli:setAnchorPoint(ccp(0,0.5))
    jiangli:setColor(ccc3(0xff, 0xff, 0xff))
    jiangli:setPosition(ccp(55,25))
   	cellBg:addChild(jiangli)
   	-- 银币
   	local silver_icon = CCSprite:create("images/common/coin_silver.png")
   	silver_icon:setAnchorPoint(ccp(0,0.5))
   	silver_icon:setPosition(ccp(150,jiangli:getPositionY()))
   	cellBg:addChild(silver_icon)
   	-- 银币数据
   	local silver = CCRenderLabel:create( silverData, g_sFontBold, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	silver:setAnchorPoint(ccp(0,0.5))
    silver:setColor(ccc3(0xff, 0xff, 0xff))
    silver:setPosition(ccp(silver_icon:getPositionX()+silver_icon:getContentSize().width,silver_icon:getPositionY()))
   	cellBg:addChild(silver)
   	-- 声望
   	local prestige_icon = CCSprite:create("images/common/prestige.png")
   	prestige_icon:setAnchorPoint(ccp(0,0.5))
   	prestige_icon:setPosition(ccp(265,jiangli:getPositionY()))
   	cellBg:addChild(prestige_icon)
   	-- 声望数据
   	local prestige = CCRenderLabel:create( GetLocalizeStringBy("key_2919") .. prestigeData, g_sFontBold, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    prestige:setAnchorPoint(ccp(0,0.5))
    prestige:setColor(ccc3(0xff, 0xff, 0xff))
    prestige:setPosition(ccp(prestige_icon:getPositionX()+prestige_icon:getContentSize().width,prestige_icon:getPositionY()))
   	cellBg:addChild(prestige)

   	-- 称号奖励
   	if( itemStr )then
	   	local title_icon = CCSprite:create("images/common/chenghao.png")
	   	title_icon:setAnchorPoint(ccp(0,0.5))
	   	title_icon:setPosition(ccp(400,jiangli:getPositionY()))
	   	cellBg:addChild(title_icon)

	   	local tab = string.split(itemStr, ",")
	   	local num = table.count(tab)
	   	local titleNum = CCRenderLabel:create( num, g_sFontBold, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    titleNum:setAnchorPoint(ccp(0,0.5))
	    titleNum:setColor(ccc3(0xff, 0xff, 0xff))
	    titleNum:setPosition(ccp(title_icon:getPositionX()+title_icon:getContentSize().width+7,title_icon:getPositionY()))
	   	cellBg:addChild(titleNum)
   	end

	return cell
end


-- 阵容按钮回调
function squadMenuItemCallFun(tag, item_obj)
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2710") .. tag )
    -- local str1 = GetLocalizeStringBy("key_3038")
    -- require "script/ui/tip/AnimationTip"
    -- AnimationTip.showTip(str1)
    require "script/ui/active/RivalInfoLayer"
    -- 该玩家uid
    local item = tolua.cast(item_obj,"CCMenuItemImage")
    local uid = item:getParent():getTag()
    -- 判断是否是npc
	local isNpc = nil
	if(tonumber(uid) >= 11001 and tonumber(uid) <= 16000)then
		isNpc = true
	end
    if(isNpc)then
    	print("NPC")
    	local utid = nil
    	for k,v in pairs(ArenaData.rankListData) do
    		if( tonumber(v.uid) == uid )then
    			utid = v.utid
    		end
    	end
    	local npc_name = ArenaData.getNpcName( uid,utid)
        -- print(GetLocalizeStringBy("key_2710") .. tag )
        RivalInfoLayer.createLayer(tonumber(tag),true,npc_name)
    else
        -- print(GetLocalizeStringBy("key_2710") .. tag )
        RivalInfoLayer.createLayer(tonumber(tag))
    end
end

















