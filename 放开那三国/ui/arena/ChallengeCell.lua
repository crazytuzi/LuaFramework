-- FileName: ChallengeCell.lua 
-- Author: Li Cong 
-- Date: 13-8-14 
-- Purpose: function description of module 

require "script/ui/item/ItemUtil" 
module("ChallengeCell", package.seeall)

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
	if( tonumber(tCellValue.uid) == UserModel.getUserUid() )then
		-- 如果是主角
		fileName = "images/arena/rankings_selfcellbg.png"
	else
		fileName = "images/arena/arena_cellbg.png"
	end
	local cellBg = CCSprite:create( fileName )
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg,1,tonumber(tCellValue.position))

	-- 玩家名字
	-- 名字背景
	local fullRect = CCRectMake(0,0,47,27)
	local insetRect = CCRectMake(15,12,5,5)
	local name_bg = CCScale9Sprite:create("images/arena/heroname_bg.png", fullRect, insetRect)
	name_bg:setContentSize(CCSizeMake(380,26))
	name_bg:setAnchorPoint(ccp(0,1))
	name_bg:setPosition(ccp(20,cellBg:getContentSize().height-15))
	cellBg:addChild(name_bg)
	-- lv.
	local lv_sprite = CCSprite:create("images/common/lv.png")
	lv_sprite:setAnchorPoint(ccp(0,0.5))
	lv_sprite:setPosition(ccp(10,name_bg:getContentSize().height*0.5))
	name_bg:addChild(lv_sprite)
	-- 等级
	local lvData = tCellValue.level or 0
	local lv_data = CCRenderLabel:create( lvData, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
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
	    name:setPosition(ccp(lv_data:getPositionX()+lv_data:getContentSize().width+10,name_bg:getContentSize().height-1))
	   	name_bg:addChild(name)
   	else
   		-- 非npc 名字
	   	name = CCRenderLabel:create( tCellValue.uname , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    name:setColor(ccc3(0xff, 0xff, 0xff))
	    name:setPosition(ccp(lv_data:getPositionX()+lv_data:getContentSize().width+10,name_bg:getContentSize().height-1))
	   	name_bg:addChild(name)
   	end

   	-- 军团名字
   	if(tCellValue.guild_name)then
        local guildNameStr = tCellValue.guild_name or " "
        local guildNameFont = CCRenderLabel:create( "[" .. guildNameStr .. "]" , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        guildNameFont:setAnchorPoint(ccp(0,1))
        guildNameFont:setColor(ccc3(0xff, 0xf6, 0x00))
        guildNameFont:setPosition(ccp(name:getPositionX()+name:getContentSize().width+10,name_bg:getContentSize().height-1))
        name_bg:addChild(guildNameFont)
    end

   	-- 排名
   	-- 幸
   	if(tonumber(tCellValue.luck) == 1)then
	   	local luckSprite = CCSprite:create("images/arena/luckicon.png")
	   	luckSprite:setAnchorPoint(ccp(0,1))
	   	luckSprite:setPosition(ccp(name_bg:getPositionX()+name_bg:getContentSize().width+3,cellBg:getContentSize().height-4))
	   	cellBg:addChild(luckSprite)
	end
   	-- 排名
   	local curRankings_font = CCRenderLabel:create(GetLocalizeStringBy("key_1442") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curRankings_font:setColor(ccc3(0xff, 0xf6, 0x01))
    curRankings_font:setPosition(ccp(name_bg:getPositionX()+name_bg:getContentSize().width+45,cellBg:getContentSize().height-12))
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
	   	local function updateRewardTime2()
	   		-- print("updateRewardTime2")
	   		if (ArenaData.getAwardTime() <= 0) then 
	   			-- 到期取消定时器
	   			timeDown:setString(GetLocalizeStringBy("key_2723"))
	   			if(ArenaData.arenaScheduleId[2] ~= nil)then
	   				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.arenaScheduleId[2])
	   				ArenaData.arenaScheduleId[2] = nil
	   			end
	   			return
	   		end
	   		local timeStr = TimeUtil.getTimeString(ArenaData.getAwardTime())
	   		-- print(timeStr)
	   		timeDown:setString(timeStr)
	   	end
	   	
	   	timeDown:registerScriptHandler(function ( eventType,node )
	   		if(eventType == "enter") then
	   			if (ArenaData.getAwardTime() > 0 ) then 
			   		-- 启动定时器 只能启动一次
			   		if( ArenaData.arenaScheduleId[2] == nil )then
			   			ArenaData.arenaScheduleId[2] = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateRewardTime2, 1, false)
			   		end
	   			end
	   		end
			if(eventType == "exit") then
				if(ArenaData.arenaScheduleId[2] ~= nil)then
	   				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.arenaScheduleId[2])
	   				ArenaData.arenaScheduleId[2] = nil
		   		end
			end
		end)
	else
		-- 挑战按钮
		local challengeMenu = BTSensitiveMenu:create()
		if(challengeMenu:retainCount()>1)then
			challengeMenu:release()
			challengeMenu:autorelease()
		end
		challengeMenu:setPosition(ccp(0,0))
		cellBg:addChild(challengeMenu,1,tonumber(tCellValue.uid))

		local myPos = ArenaData.getSelfRanking()
		if( tonumber(tCellValue.position) < myPos )then
			local challengeItem = CCMenuItemImage:create("images/arena/challenge_normal.png", "images/arena/challenge_select.png")
			challengeItem:setAnchorPoint(ccp(0.5,0.5))
			challengeItem:setScale(0.8)
			challengeItem:setPosition(ccp(cellBg:getContentSize().width-85, cellBg:getContentSize().height/2 - 10))
			challengeMenu:addChild(challengeItem,1,tonumber(tCellValue.position))
			-- 注册挑战回调
			challengeItem:registerScriptTapHandler(ChallengeItemCallFun)
		else
			-- 挑战 
			local challengeItem = CCMenuItemImage:create("images/arena/small_n.png", "images/arena/small_h.png")
			challengeItem:setAnchorPoint(ccp(0.5,0.5))
			-- challengeItem:setScale(0.8)
			challengeItem:setPosition(ccp(cellBg:getContentSize().width-85, cellBg:getContentSize().height*0.59))
			challengeMenu:addChild(challengeItem,1,tonumber(tCellValue.position))
			-- 注册挑战回调
			challengeItem:registerScriptTapHandler(ChallengeItemCallFun)
			-- 战十次
			local normalSprite = CCScale9Sprite:create("images/common/btn/green01_n.png")
			normalSprite:setContentSize(CCSizeMake(150,64))
		    local selectSprite = CCScale9Sprite:create("images/common/btn/green01_h.png")
		    selectSprite:setContentSize(CCSizeMake(150,64))
		    local tenChallengeItem = CCMenuItemSprite:create(normalSprite,selectSprite)
			tenChallengeItem:setAnchorPoint(ccp(0.5,0.5))
			tenChallengeItem:setPosition(ccp(cellBg:getContentSize().width-85, cellBg:getContentSize().height*0.22))
			challengeMenu:addChild(tenChallengeItem,1,tonumber(tCellValue.position))
			-- 注册挑战回调
			tenChallengeItem:registerScriptTapHandler(tenChallengeItemCallFun)
			-- 文字
			local strSp = CCSprite:create("images/arena/tenstr.png")
			strSp:setAnchorPoint(ccp(0.5,0.5))
			strSp:setPosition(tenChallengeItem:getContentSize().width*0.5,tenChallengeItem:getContentSize().height*0.5)
			tenChallengeItem:addChild(strSp,10)
		end
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


-- 挑战按钮回调
function ChallengeItemCallFun(tag, item_obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print("here is 挑战回调! 挑战位置:" .. tag)
	-- 缓存敌人的信息
	-- enemyUid:对方的uid 
	local challenge_uid = item_obj:getParent():getTag()
	-- print("here challenge_uid is = ", challenge_uid)
	-- enemyUtid:敌方性别 1:女, 2:男
	-- enemyName:敌人名字
	-- enemyFightData:敌方战斗力
	local enemyData = ArenaData.getHeroDataByUid(challenge_uid)
	-- 下一步创建与数据有关UI
    local function createNext( atk, isNeedReload, isUp, position, flopData)
    	if(atk == nil or table.isEmpty(atk) )then
    		return
    	end
    	print("111111111111111111")
    	print_t(flopData)
		local function nextCallFun()
			-- 更新竞技列表
			if(isNeedReload)then
				-- 更新玩家列表UI
				ArenaData.allUserData = ArenaData.getOpponentsData()
				ArenaChallenge.challengeTableView:reloadData()
				-- 设置偏移量 让自己居中
				local cellBg = CCSprite:create("images/arena/arena_cellbg.png")
				local cellSize = cellBg:getContentSize() 
				local index = nil
				for k,v in pairs(ArenaData.allUserData) do
					if( tonumber(v.uid) == UserModel.getUserUid() )then
						-- 如果是主角
						index = tonumber(k)
					end
				end
				-- 1默认显示在顶部,2名正常显示,11名显示底部,其他显示中间
				if(index ~= 1 and index ~= 2 and index ~= 11)then
					-- 设置偏移量 把自己显示在中间
					ArenaChallenge.challengeTableView:setContentOffset( ccp(0, (index-10)*(cellSize.height+10)-18 ))
				end
				-- 如果是最后一名 
				if(index == 11)then
					-- 设置偏移量 把自己显示在最底部
					ArenaChallenge.challengeTableView:setContentOffset( ccp(0, (index-11)*(cellSize.height+10)+15 ))
				end
			end
			-- 更新菜单栏银币
			local coin = nil
			local soul = nil
			local exp = nil
			local prestige = nil
			if(atk[1].appraisal ~= "E" and atk[1].appraisal ~= "F")then
				-- 胜利 
				coin,soul,exp,prestige = ArenaData.getCoinAndSoulForWin()
			else
				coin,soul,exp,prestige = ArenaData.getCoinAndSoulForFail()
			end
			-- 加银币
			UserModel.addSilverNumber(coin)
			-- 加将魂
			UserModel.addSoulNum(soul)
			-- 加经验
			UserModel.addExpValue(exp,"challenge")
			-- 加声望
			UserModel.addPrestigeNum(prestige)
			-- 刷新声望
			if(ArenaChallenge.m_prestigeLabel ~= nil)then
				ArenaChallenge.m_prestigeLabel:setString( UserModel.getPrestigeNum() )
			end
			-- 更新菜单栏当前排名
			local curData = ArenaData.getSelfRanking()
			if(ArenaChallenge.curRanking ~= nil)then
				ArenaChallenge.curRanking:setString( curData )
			end
			-- 更新剩余耐力值
			if(ArenaLayer._staminaLabel ~= nil)then
				ArenaLayer._staminaLabel:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
			end
			-- 如果抽取的是抢夺或银币 加银币
			if(flopData ~= nil and not table.isEmpty(flopData) )then
				for k,v in pairs(flopData[1]) do
					if(k == "real")then
						for i,j in pairs(v) do
							if(i == "rob")then
								-- 加银币
								-- print(GetLocalizeStringBy("key_1081"),j)
								UserModel.addSilverNumber(tonumber(j))
								ArenaLayer.m_silverLabel:setString( string.convertSilverUtilByInternational(UserModel.getSilverNumber()) )
							elseif(i == "silver")then
								-- 加银币
								-- print(GetLocalizeStringBy("key_3407"),j)
								UserModel.addSilverNumber(tonumber(j))
								ArenaLayer.m_silverLabel:setString( string.convertSilverUtilByInternational(UserModel.getSilverNumber()) )
							elseif(i == "soul")then
								-- 加将魂
								-- print(GetLocalizeStringBy("key_2279"),j)
								UserModel.addSoulNum(tonumber(j))
							elseif(i == "gold")then
								-- 加金币
								-- print(GetLocalizeStringBy("key_3148"),j)
								UserModel.addGoldNumber(tonumber(j))
								ArenaLayer.m_goldLabel:setString( UserModel.getGoldNumber() )
							end
						end
					end
				end
			end
			-- 刷新银币
			if(ArenaLayer.m_silverLabel ~= nil)then
				ArenaLayer.m_silverLabel:setString( string.convertSilverUtilByInternational(UserModel.getSilverNumber()) )
			end
			-- 金币
			ArenaLayer.refreshArenaGold()
			-- 发战斗结束通知
			-- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
		end
		-- 调用战斗接口 参数:atk 
		require "script/battle/BattleLayer"
		require "script/ui/arena/AfterBattleLayer"
		local coin = nil
		local soul = nil
		local exp = nil
		local prestige = nil
		if(atk[1].appraisal ~= "E" and atk[1].appraisal ~= "F")then
			-- 胜利 
			coin,soul,exp,prestige = ArenaData.getCoinAndSoulForWin()
		else
			coin,soul,exp,prestige = ArenaData.getCoinAndSoulForFail()
		end
		local function afterOKcallFun()
			local str = nil
			if(isUp)then
		        str = GetLocalizeStringBy("key_1768") .. position .. GetLocalizeStringBy("key_2323") .. GetLocalizeStringBy("key_2486") .. prestige .. GetLocalizeStringBy("key_1069")
		    else
		         str = GetLocalizeStringBy("key_1757") .. GetLocalizeStringBy("key_2486") .. prestige .. GetLocalizeStringBy("key_1069")
		    end
		    -- 返回后提示
	        if(str ~= nil)then
	            require "script/ui/tip/AnimationTip"
	            AnimationTip.showTip(str)
	        end
		end
		print("challenge_uid",challenge_uid)


		-- createAfterBattleLayer( appraisal, enemyUid, enemyDataTab, enemyFightData,silverData, expData, flopData, afterOKCallFun )
		local afterBattleLayer = AfterBattleLayer.createAfterBattleLayer( atk[1].appraisal, challenge_uid, enemyData, atk[1].force, coin, exp, flopData[1], afterOKcallFun, atk[1].fightRet )
		BattleLayer.showBattleWithString(atk[1].fightRet, nextCallFun, afterBattleLayer,"zhuoretudi.jpg","music11.mp3",nil,nil,nil,true)
	end

	-- addby chengliang
    PreRequest.setIsCanShowAchieveTip(false)

    -- 调用后端接口
	ArenaService.challenge(tag, challenge_uid, 1, createNext)
end






--[[
	@des 	: 战10次
	@param 	: 
	@return :
--]]
function tenChallengeItemCallFun( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- enemyUid:对方的uid 
	local challenge_uid = itemBtn:getParent():getTag()

	-- 挑战次数
	local maxNum = 10
	local curNum =  math.floor(UserModel.getStaminaNumber()/2)
	local challengeNum = 1
	if(curNum >= 1 )then
		if( curNum < maxNum )then
			challengeNum = curNum
		else
			challengeNum = maxNum
		end
	end

	local nextCallFun = function ( p_atk, isNeedReload, isUp, position, p_flopData )
		if(p_atk == nil or table.isEmpty(p_atk) )then
    		return
    	end

    	-- 更新竞技列表
		if(isNeedReload)then
			-- 更新玩家列表UI
			ArenaData.allUserData = ArenaData.getOpponentsData()
			ArenaChallenge.challengeTableView:reloadData()
			-- 设置偏移量 让自己居中
			local cellBg = CCSprite:create("images/arena/arena_cellbg.png")
			local cellSize = cellBg:getContentSize() 
			local index = nil
			for k,v in pairs(ArenaData.allUserData) do
				if( tonumber(v.uid) == UserModel.getUserUid() )then
					-- 如果是主角
					index = tonumber(k)
				end
			end
			-- 1默认显示在顶部,2名正常显示,11名显示底部,其他显示中间
			if(index ~= 1 and index ~= 2 and index ~= 11)then
				-- 设置偏移量 把自己显示在中间
				ArenaChallenge.challengeTableView:setContentOffset( ccp(0, (index-10)*(cellSize.height+10)-18 ))
			end
			-- 如果是最后一名 
			if(index == 11)then
				-- 设置偏移量 把自己显示在最底部
				ArenaChallenge.challengeTableView:setContentOffset( ccp(0, (index-11)*(cellSize.height+10)+15 ))
			end
		end

    	-- 加数据
    	local addPrestige = 0
    	for k,v in pairs(p_atk) do
    		local coin = nil
			local soul = nil
			local exp = nil
			local prestige = nil
			if(v.appraisal ~= "E" and v.appraisal ~= "F")then
				-- 胜利 
				coin,soul,exp,prestige = ArenaData.getCoinAndSoulForWin()
			else
				coin,soul,exp,prestige = ArenaData.getCoinAndSoulForFail()
			end
			-- 加银币
			UserModel.addSilverNumber(coin)
			-- 加将魂
			UserModel.addSoulNum(soul)
			-- 加经验
			UserModel.addExpValue(exp,"challenge")
			-- 加声望
			UserModel.addPrestigeNum(prestige)
			addPrestige = addPrestige + prestige
    	end

    	-- 如果抽取的是抢夺或银币 加银币
		if(not table.isEmpty(p_flopData) )then
			for k_num,v_data in pairs(p_flopData) do
				for k,v in pairs(v_data) do
					if(k == "real")then
						for i,j in pairs(v) do
							if(i == "rob")then
								-- 加银币
								-- print(GetLocalizeStringBy("key_1081"),j)
								UserModel.addSilverNumber(tonumber(j))
							elseif(i == "silver")then
								-- 加银币
								-- print(GetLocalizeStringBy("key_3407"),j)
								UserModel.addSilverNumber(tonumber(j))
							elseif(i == "soul")then
								-- 加将魂
								-- print(GetLocalizeStringBy("key_2279"),j)
								UserModel.addSoulNum(tonumber(j))
							elseif(i == "gold")then
								-- 加金币
								-- print(GetLocalizeStringBy("key_3148"),j)
								UserModel.addGoldNumber(tonumber(j))
							end
						end
					end
				end
			end
		end

    	-- 刷新声望
		if(ArenaChallenge.m_prestigeLabel ~= nil)then
			ArenaChallenge.m_prestigeLabel:setString( UserModel.getPrestigeNum() )
		end
		-- 刷新银币
		if(ArenaLayer.m_silverLabel ~= nil)then
			print("==>11",UserModel.getSilverNumber())
			ArenaLayer.m_silverLabel:setString( string.convertSilverUtilByInternational(UserModel.getSilverNumber()) )
		end
		-- 金币
		ArenaLayer.refreshArenaGold()
		-- 更新菜单栏当前排名
		local curData = ArenaData.getSelfRanking()
		if(ArenaChallenge.curRanking ~= nil)then
			ArenaChallenge.curRanking:setString( curData )
		end
		-- 更新剩余耐力值
		if(ArenaLayer._staminaLabel ~= nil)then
			ArenaLayer._staminaLabel:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
		end

		-- 确定板子按钮回调
		local callFun = function ( ... )
			local str = GetLocalizeStringBy("key_1757") .. GetLocalizeStringBy("key_2486") .. addPrestige .. GetLocalizeStringBy("key_1069")
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip(str)
		end
		
		-- 结算板子
		require "script/ui/arena/ChallengeTenDialog"
		ChallengeTenDialog.showLayer( p_atk, p_flopData,callFun, -600, 1010 )
	end

	-- addby chengliang
    PreRequest.setIsCanShowAchieveTip(false)

	-- 调用后端接口
	ArenaService.challenge(tag, challenge_uid, challengeNum, nextCallFun)
end










