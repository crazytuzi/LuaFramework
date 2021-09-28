-- Filename: NewGuide.lua
-- Author: 李晨阳
-- Date: 2013-08-12
-- Purpose: 新手工具

require "script/guide/ArenaGuide"


module ("NewGuide", package.seeall)

guideClass = ksGuideClose       -- 新手引导全局类型

isBackFiveGiftGuide = false
isBackTenGiftGuide  = false

-- 是否通过第一副本
isPass = false
-- 是否弹节点面板
isNeedOpen = false

local noTouchLayer = nil

local eatTouch = false

--添加屏幕屏蔽层
function OpenNoTouchMode( ... )
	eatTouch = true
	if(noTouchLayer == nil) then
		noTouchLayer = CCLayer:create()
    	noTouchLayer:setTouchEnabled(true)
    	noTouchLayer:setTouchPriority(-5000)
    	noTouchLayer:registerScriptTouchHandler(function ( eventType,x,y)
        	if(eventType == "began") then
        		if(eatTouch == true) then
        			print("return true")
        			return true
        		else
        			print("return false")
        			return false
        		end
        	end
    	end,false, priority or -5000, true)
    	local runningScene = CCDirector:sharedDirector():getRunningScene()
    	runningScene:addChild(noTouchLayer)
	end
end

function closeNoTouchMode( ... )
	eatTouch = false
	print("关闭touch事件")
end

--保存当前引导类型
function saveGuideClass()
	print("new guide save class = ", guideClass)
	CCUserDefault:sharedUserDefault():setStringForKey("guideClass_" .. UserModel.getUserUid(), tostring(guideClass))
	CCUserDefault:sharedUserDefault():flush()
end
--保存当前引导步数
function saveGuideStep(stepNum)
	CCUserDefault:sharedUserDefault():setStringForKey("guideStep_" .. UserModel.getUserUid(), tostring(stepNum))
	CCUserDefault:sharedUserDefault():flush()
end

--得到持久化的引导类型
function getPersistenceGuideClass()
	local tempGuideClass = CCUserDefault:sharedUserDefault():getStringForKey("guideClass_" .. UserModel.getUserUid())
	return tonumber(tempGuideClass)
end

--得到持久化的引导步数
function getPersistenceGuideStep()
	local tempGuideStep = CCUserDefault:sharedUserDefault():getStringForKey("guideStep_" .. UserModel.getUserUid())
	return tonumber(tempGuideStep)
end



--得到当前用户身份信息
function getNowUserUid( ... )
	--得到用户信息
	require "script/model/user/UserModel"
	local userInfo = UserModel.getUserInfo()
	local userUid  = userInfo["uid"]

	require "script/ui/login/ServerList"
	local nowServerInfo = ServerList.getSelectServerInfo()
	local nowGroupId 	= ""
	if(nowServerInfo == nil) then
		nowGroupId = "001"
	else
		nowGroupId = nowServerInfo["group"]
	end
	print("nowGroupId .. userUid = ", nowGroupId .. userUid)
	return nowGroupId .. userUid
end

--保存用户身份
function saveUserUid()

	local userInfoStr = getNowUserUid()
	print("userInfoStr = ",userInfoStr)

	CCUserDefault:sharedUserDefault():setStringForKey("userUid", userInfoStr)
	CCUserDefault:sharedUserDefault():flush()
end

--得到持久化的用户身份
function getPersistenceUserUid()
	local tempGuideStep = CCUserDefault:sharedUserDefault():getStringForKey("userUid")
	return tempGuideStep
end


--数据清除
function cleanNewGuideData( ... )
	CCUserDefault:sharedUserDefault():setStringForKey("guideClass" .. UserModel.getUserUid(), ksGuideClose)
	CCUserDefault:sharedUserDefault():setStringForKey("guideStep"  .. UserModel.getUserUid(), 0)
	CCUserDefault:sharedUserDefault():setStringForKey("userUid", "")

	CCUserDefault:sharedUserDefault():setBoolForKey("fiveLevelRecruitState", false)
	CCUserDefault:sharedUserDefault():setBoolForKey("tenLevelRecruitState", false)
	CCUserDefault:sharedUserDefault():setBoolForKey("fiveLevelisClick", false)
	CCUserDefault:sharedUserDefault():setBoolForKey("tenLevelisClick", false)

	CCUserDefault:sharedUserDefault():flush()

end

--初始化新手引导状态
function init( ... )

	print("NewGuide init")
	--判断当前用户身份
	local persistenceUserInfoStr = getPersistenceUserUid()
	local nowUserInfoStr 		 = getNowUserUid()
	print("persistenceUserInfoStr = ",persistenceUserInfoStr)
	print("nowUserInfoStr =", nowUserInfoStr)
	if(persistenceUserInfoStr ~= nowUserInfoStr) then
		--如果用户不相同，则不读取记忆步数
		print(GetLocalizeStringBy("key_3100"))
		--数据清除
		cleanNewGuideData()
		return
	end


	local guideEnmu = getPersistenceGuideClass()
	print("guideEnmu=", guideEnmu)
	if(guideEnmu == ksGuideFormation) then
		--阵型的记忆引导策略
		formationGuideLogic()
	elseif(guideEnmu == ksGuideForge) then
		--强化所的记忆引导策略
		forgeGuideLoginc()
	elseif(guideEnmu == ksGuideFiveLevelGift) then
		--五级等级礼包记忆引导策略
		--fiveLevelGiftGuideLogic()
	elseif(guideEnmu == ksGuideCopyBox) then
		--副本箱子记忆引导策略
		copyBoxGuideLoginc()
	elseif(guideEnmu == ksGuideTenLevelGift) then
		--10级等级礼品记忆引导策略
		tenLevelGiftGuideLogic()
	elseif(guideEnmu == ksGuideSignIn) then
		--签到记忆引导策略
		SignInGuideLogic()
	elseif(guideEnmu == ksGuideForthFormation) then
		--第四个上阵位置引导策略
		ForthFormationGuideLogic()
	elseif(guideEnmu == ksGuideEliteCopy) then
		--精英副本引导策略
		eliteCopyGuideLogic()
	elseif(guideEnmu == ksGuideGreatSoldier) then
		--名将系统引导策略
		greatSoldierGuideLogic()
	elseif(guideEnmu == ksGuideArena) then
		--竞技场引导策略
		arenaGuideLogic()
	elseif(guideEnmu == ksGuideContest) then
		--比武场引导策略
		matchGuideLogic()
	elseif(guideEnmu == ksGuidePet) then
		--宠物系统引导策略
		petGuideLogic()
	elseif(guideEnmu == ksGuideResource) then
		--资源矿引导策略
		resourceGuideLogic()
	elseif(guideEnmu == ksGuideAstrology) then
		--占星引导策略
		astrologyGuideLogic()
	elseif(guideEnmu == ksGuideGeneralUpgrade) then
		-- 武将进阶新手引导
		GuideGeneralUpgrade()
	end
end

--阵型的记忆引导策略
function formationGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 5) then
		require "script/guide/NewGuide"
  		NewGuide.guideClass  = ksGuideFormation
  		BTUtil:setGuideState(true)
	    require "script/guide/FormationGuide"

        CCLuaLog("start fromation guide")
        local formationButton = MenuLayer.getMenuItemNode(2)
        local touchRect       = getSpriteScreenRect(formationButton)
        FormationGuide.show(1, touchRect)
	end
end

--强化所的记忆引导策略
function forgeGuideLoginc( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 9) then
		print("start StrengthenGuide")
        require "script/guide/NewGuide"
        require "script/guide/StrengthenGuide"
        NewGuide.guideClass = ksGuideForge
    	BTUtil:setGuideState(true)

        require "script/ui/main/MainBaseLayer"
        local strengthenButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHero)
        local touchRect = getSpriteScreenRect(strengthenButton)
        StrengthenGuide.show(1, touchRect)
	end
end

--五级等级礼包记忆引导策略
function fiveLevelGiftGuideLogic( ... )
	isBackFiveGiftGuide = true
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 2.5) then
		require "script/guide/NewGuide"
        NewGuide.guideClass  = ksGuideFiveLevelGift
        BTUtil:setGuideState(true)
        print("start LevelGiftBagGuide guide")
        require "script/guide/LevelGiftBagGuide"
        require "script/ui/level_reward/LevelRewardBtn"
        local levelGiftBagGuide_button = LevelRewardBtn.getReardBtn()
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(1, touchRect)
	end

	if(persistenceStepNum > 2 and getFiveLevelRecruite() == false) then
		require "script/guide/NewGuide"
		print("g_guideClass = ", NewGuide.guideClass)
	    require "script/guide/LevelGiftBagGuide"
	    NewGuide.guideClass  = ksGuideFiveLevelGift

        require "script/ui/main/MenuLayer"
        local levelGiftBagGuide_button = MenuLayer.getMenuItemNode(5)
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(4, touchRect)
	end

	if(getFiveLevelRecruite() and persistenceStepNum < 13 and persistenceStepNum > 2.5) then
		require "script/guide/NewGuide"
		print("g_guideClass = ", NewGuide.guideClass)
	    require "script/guide/LevelGiftBagGuide"
	    NewGuide.guideClass  = ksGuideFiveLevelGift

        require "script/ui/main/MenuLayer"
    	local levelGiftBagGuide_button = MenuLayer.getMenuItemNode(2)
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(9, touchRect)
	end

	if(persistenceStepNum > 12 and persistenceStepNum < 18) then

		require "script/guide/NewGuide"
		print("g_guideClass = ", NewGuide.guideClass)
	    require "script/guide/LevelGiftBagGuide"
	    NewGuide.guideClass  = ksGuideFiveLevelGift
        
        require "script/ui/main/MenuLayer"
        local levelGiftBagGuide_button = MenuLayer.getMenuItemNode(3)
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(17, touchRect)
	end

end

--副本箱子记忆引导策略
function copyBoxGuideLoginc( ... )
	-- local persistenceStepNum = getPersistenceGuideStep()
	-- print("formationGuideLogic stepNum = ", persistenceStepNum)
	-- if(persistenceStepNum < 3) then
	-- 	require "script/guide/NewGuide"
	-- 	require "script/guide/CopyBoxGuide"
	-- 	NewGuide.guideClass =  ksGuideCopyBox 
	-- 	require "script/ui/main/MenuLayer"
	--     local copyBoxGuide_button = MenuLayer.getMenuItemNode(3)
	-- 	local touchRect = getSpriteScreenRect(copyBoxGuide_button)
	-- 	CopyBoxGuide.show(7, touchRect)
	-- end

	-- if(persistenceStepNum > 2 and persistenceStepNum < 6) then
	-- 	require "script/guide/NewGuide"
	-- 	require "script/guide/CopyBoxGuide"
	--     NewGuide.guideClass =  ksGuideCopyBox
	-- 	require "script/ui/main/MenuLayer"
 --        local copyBoxGuide_button = MenuLayer.getMenuItemNode(5)
	-- 	local touchRect = getSpriteScreenRect(copyBoxGuide_button)
	-- 	CopyBoxGuide.show(4, touchRect)
	-- end
end

--10级等级礼品记忆引导策略
function tenLevelGiftGuideLogic( ... )
	isBackTenGiftGuide = true
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 3) then
		require "script/guide/NewGuide"
		require "script/guide/TenLevelGiftGuide"
		NewGuide.guideClass =  ksGuideTenLevelGift
		BTUtil:setGuideState(true)
        local formationButton = LevelRewardBtn.getReardBtn()
        local touchRect       = getSpriteScreenRect(formationButton)
        TenLevelGiftGuide.show(1, touchRect)
	end
--去掉十级等级礼包招将断点
--[[
	if(persistenceStepNum > 2 and getTenLevelRecruite() == false) then
		--显示商店
		require "script/ui/main/MenuLayer"
		require "script/guide/TenLevelGiftGuide"
		NewGuide.guideClass =  ksGuideTenLevelGift
        local formationButton = MenuLayer.getMenuItemNode(5)
        local touchRect       = getSpriteScreenRect(formationButton)
        TenLevelGiftGuide.show(4, touchRect)
	end 
]]
	if(getTenLevelRecruite() == true and persistenceStepNum < 12) then
		--到阵容
		require "script/ui/main/MenuLayer"
		require "script/guide/TenLevelGiftGuide"
		NewGuide.guideClass =  ksGuideTenLevelGift
		local formationButton = MenuLayer.getMenuItemNode(2)
        local touchRect       = getSpriteScreenRect(formationButton)
        TenLevelGiftGuide.show(6, touchRect)
	end
end

--签到记忆引导策略
function SignInGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 3) then
		require "script/guide/NewGuide"
		NewGuide.guideClass = ksGuideSignIn
		BTUtil:setGuideState(true)

		require "script/guide/SignInGuide"
        require "script/guide/FormationGuide"
        require "script/ui/sign/SignRewardLayer"
        local formationButton = SignRewardLayer.getSignBtn()
        local touchRect       = getSpriteScreenRect(formationButton)
        SignInGuide.show(1, touchRect)
	end
end

--第四个上阵位置引导策略
function ForthFormationGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 3) then
		print("start ForthFormationGuide guide")
        require "script/guide/NewGuide"
        NewGuide.guideClass  = ksGuideForthFormation
        BTUtil:setGuideState(true)
        require "script/guide/ForthFormationGuide"
        require "script/ui/main/MenuLayer"
        local forthFormationGuide_button = MenuLayer.getMenuItemNode(2)
        local touchRect = getSpriteScreenRect(forthFormationGuide_button)
        ForthFormationGuide.show(1, touchRect)
	end
end

--精英副本引导策略
function eliteCopyGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 5) then
		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideEliteCopy
		BTUtil:setGuideState(true)
		require "script/guide/EliteCopyGuide"
       	require "script/ui/main/MenuLayer"
        local eliteButton = MenuLayer.getMenuItemNode(3)
        local touchRect   = getSpriteScreenRect(eliteButton)
        EliteCopyGuide.show(1, touchRect)
	end
end

--名将系统引导策略
function greatSoldierGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 5) then
		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideGreatSoldier
		BTUtil:setGuideState(true)
		require "script/guide/StarHeroGuide"
       	require "script/ui/main/MainBaseLayer"
        local starHeroButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagFair)
        local touchRect   = getSpriteScreenRect(starHeroButton)
        StarHeroGuide.show(1, touchRect)
	end
end

--竞技场引导策略
function arenaGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 3) then
		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideArena
		BTUtil:setGuideState(true)
		require "script/guide/ArenaGuide"
       	require "script/ui/main/MenuLayer"
        local arenaButton = MenuLayer.getMenuItemNode(4)
        local touchRect   = getSpriteScreenRect(arenaButton)
        ArenaGuide.show(1, touchRect)
	end
end

-- 比武场引导策略
function matchGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 3) then
		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideContest
		BTUtil:setGuideState(true)
		require "script/guide/MatchGuide"
       	require "script/ui/main/MenuLayer"
        local matchButton = MenuLayer.getMenuItemNode(4)
        local touchRect   = getSpriteScreenRect(matchButton)
        MatchGuide.show(1, touchRect)
	end
end

--宠物系统引导策略
function petGuideLogic( ... )
	-- local persistenceStepNum = getPersistenceGuideStep()
	-- print("formationGuideLogic stepNum = ", persistenceStepNum)
	-- if(persistenceStepNum < 4) then
	-- 	require "script/guide/NewGuide"
	-- 	NewGuide.guideClass  = ksGuidePet
	-- 	BTUtil:setGuideState(true)
	-- 	require "script/guide/PetGuide"
 --       	require "script/ui/main/MainBaseLayer"
 --        local petButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagPet)
 --        local touchRect   = getSpriteScreenRect(petButton)
 --        PetGuide.show(1, touchRect)
	-- end
end

--资源矿引导策略
function resourceGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 3) then
		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideResource
		BTUtil:setGuideState(true)
		require "script/guide/MineralGuide"
       	require "script/ui/main/MenuLayer"
        local mineralButton = MenuLayer.getMenuItemNode(4)
        local touchRect   = getSpriteScreenRect(mineralButton)
        MineralGuide.show(1, touchRect)
	end
end

--占星引导策略
function astrologyGuideLogic( ... )
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 4) then
		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideAstrology
		BTUtil:setGuideState(true)
		require "script/guide/AstrologyGuide"
       	require "script/ui/main/MainBaseLayer"
        local astrologyButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHoroscope)
        local touchRect   = getSpriteScreenRect(astrologyButton)
        AstrologyGuide.show(1, touchRect)
	end
end

--武将进阶引导测量
function GuideGeneralUpgrade( ... )
	require "script/guide/GeneralUpgradeGuide"
	local persistenceStepNum = getPersistenceGuideStep()
	print("formationGuideLogic stepNum = ", persistenceStepNum)
	if(persistenceStepNum < 4) then
		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideGeneralUpgrade
		BTUtil:setGuideState(true)
       	require "script/ui/main/MainBaseLayer"
     	local equipButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHero)
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(1,touchRect)
	end
end

----------------------------招将特殊处理-------------------------------
-- 是否点击选择战将，良将，神将按钮
function saveRecruitInfo( ... )
	if(guideClass == ksGuideFiveLevelGift) then
		--五级等级礼包
		CCUserDefault:sharedUserDefault():setBoolForKey("fiveLevelRecruitState", true)
	elseif(guideClass == ksGuideTenLevelGift) then
		--10级等级礼包
		CCUserDefault:sharedUserDefault():setBoolForKey("tenLevelRecruitState", true)
	end
	CCUserDefault:sharedUserDefault():flush()
end

function getTenLevelRecruite( )
	return CCUserDefault:sharedUserDefault():getBoolForKey("tenLevelRecruitState")	
end

function getFiveLevelRecruite( )
	return CCUserDefault:sharedUserDefault():getBoolForKey("fiveLevelRecruitState")
end

-- 保存是否点击招募神将按钮状态
function saveClickInfo( ... )
	if(guideClass == ksGuideFiveLevelGift) then
		--五级等级礼包
		-- 是否点击招募神将按钮状态
		CCUserDefault:sharedUserDefault():setBoolForKey("fiveLevelisClick", true)
	elseif(guideClass == ksGuideTenLevelGift) then
		--10级等级礼包
		-- 是否点击招募神将按钮状态
		CCUserDefault:sharedUserDefault():setBoolForKey("tenLevelisClick", true)
	end
	CCUserDefault:sharedUserDefault():flush()
end

function getFiveLevelClick( )
	return CCUserDefault:sharedUserDefault():getBoolForKey("fiveLevelisClick")
end

function getTenLevelClick( )
	return CCUserDefault:sharedUserDefault():getBoolForKey("tenLevelisClick")	
end


-- 保存是否通关第一个据点
function saveOneCopyStatus()
	if(isPass == true)then
		return
	end
	local function requestFunc( cbFlag, dictData, bRet )
		
	end
	local args = CCArray:create()
	args:addObject(CCString:create("isPassOneCopy"))
	args:addObject(CCString:create("true"))
	Network.rpc(requestFunc, "user.setArrConfig", "user.setArrConfig", args, true)
end


-- 获得是否通关第一个据点
function getOneCopyStatus( callFun )
	local function requestFunc( cbFlag, dictData, bRet )
		print("user.getArrConfig")
		if(bRet == true)then
			print_t(dictData.ret)
			local status = dictData.ret.isPassOneCopy	
			print("status++++",status)
			require "script/ui/main/MainScene"
			
    		if( status == "true" or status == true )then
    			print(GetLocalizeStringBy("key_2335"))
    			-- 通关第一个据点直接进主场景
    			isNeedOpen = false
    			isPass = true
				MainScene.enter()
    		else
    			require "script/model/user/UserModel"
 				if(UserModel.getHeroLevel() >= 2)then
 					print("老号在此进。。")
 					isNeedOpen = false
    				isPass = true
    				MainScene.enter()
    			else
	    			-- 没通关第一个据点进第一个据点战斗
	    			local runningScene = CCDirector:sharedDirector():getRunningScene()
	    			runningScene:removeAllChildrenWithCleanup(true)
	    			local battleCallback = function ( ... )
	    				print(GetLocalizeStringBy("key_2436"))
	    				isNeedOpen = true
	    				isPass = true
						MainScene.enter()
			   	 	end
			   	 	print("zhand+++")
			   	 	require "script/battle/BattleLayer"
			    	BattleLayer.enterBattle(1, 1001, 0, battleCallback ,1)
			    end
    		end
		end
	end
	Network.rpc(requestFunc, "user.getArrConfig", "user.getArrConfig", nil, true)
end


-------------------------------------------------------------- 新手引导语音 ------------------------------------------------------------------
--[[
	@des 	: 播放新手语音
	@param 	: 
	@return : 
--]]
local _lastEffectId = nil

function playGuideAudio(pGuideTypeId, pStepNum)
	require "script/audio/AudioUtil"
	-- 先停止上一步音效
	if(_lastEffectId)then
		AudioUtil.stopEffect(_lastEffectId)
	end
	local audioName = getGuideAudio( pGuideTypeId, pStepNum )
	if(audioName == nil)then
		print("新手语音:",audioName,pGuideTypeId,pStepNum)
		return
	end
	-- 播放音效
	local pathStr = "audio/sound/" .. audioName
	print("新手语音:",pathStr,pGuideTypeId,pStepNum)
    _lastEffectId = AudioUtil.playEffect(pathStr)
end

--[[
	@des 	: 得到新手语音
	@param 	: 
	@return : 
--]]
function getGuideAudio(pGuideTypeId, pStepNum)
	require "db/DB_Soundguide"
	local retData = nil
	local dbData = DB_Soundguide.getDataById(pGuideTypeId)
	if( dbData and dbData.soundeffect )then
		local aStrTab = string.split(dbData.soundeffect,",")
		for i,v_str in ipairs(aStrTab) do
			local audioTab = string.split(v_str,"|")
			if( tonumber(pStepNum) == tonumber(audioTab[1]) )then
				retData = audioTab[2]
				break
			end
		end
	end
	return retData
end




















