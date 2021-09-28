-- Filename：	PetService.lua
-- Author：		zhz
-- Date：		2014-3-31
-- Purpose：		网络处理

module("PetService", package.seeall)
require "script/ui/pet/PetData"
require "script/ui/pet/PetUtil"
require "db/DB_Pet"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicUI"
require "script/ui/tip/LackGoldTip"

--[[
	@des 	:拉取玩家所有所有宠物的信息
	@param 	:callbackFunc完成回调方法
	@return :
	 {
        array(
            petInfo =>array(
                'petid => array (
                    'petid' => int,宠物id
                    'pet_tmpl' => int, 宠物模板id
                    'level' => int ,宠物等级
                    'exp' => int ,宠物经验
                    'swallow' => int, 已经吞噬宠物的数量
                    'skill_point' => int, 宠物拥有的技能点
                    'va_pet' => array(
                            skillTalent => array(0 => array(id => 0, level => int, status => int)),
                            skillNormal => array(0 => array(id => 0level => int, status => int)),
                            skillProduct => array(0 => array(id => 0, level => int, status => int)),
                    ), 宠物技能相关
                ),),
            keeperInfo =>
                    array(
                            pet_slot => int,宠物仓库已开启数量
                            va_keeper => array(0 => array(petid => int, status => int[0未出战1已出战], producttime => int, traintime => int)),
                            拥有者信息
                         ),
    		);
 	}
--]]
function getAllPet(callbackFunc )

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			PetData.setAllPetInfo(dictData.ret )
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	Network.rpc(requestFunc, "pet.getAllPet", "pet.getAllPet", nil, true)
end


local feedPetByItemCount = 1
--[[
	@des 	:喂养宠物的
	@param 	:petId宠物的ID， $itemId 物品id
	@return :
--]]
function feedPetByItem( petId, item_id,item_tmple_id,callbackFunc )

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then

			local petInfo= PetData.getPetInfoById(petId)
			local expFeed= tonumber(dictData.ret.expFeed)
			local feedExp = expFeed+ tonumber( petInfo.exp)
			
			print("petInfo  is : ")
			print_t(petInfo)
			local pet_tmpl = tonumber(petInfo.pet_tmpl)
			local originLv= tonumber(petInfo.level)
			local expUpgradeID= DB_Pet.getDataById(pet_tmpl).expUpgradeID
			local addExp= DB_Item_feed.getDataById(item_tmple_id).add_exp

			if(tonumber(expFeed) >tonumber(addExp) ) then
				local rate = expFeed/addExp
				PetUtil.showCritExp(rate,expFeed )
			else
				LevelUpUtil.showFloatText(GetLocalizeStringBy("key_2972") .. expFeed ,g_sFontPangWa)
			end
			local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,feedExp)
	

			print("PetData  ...... 99999999 ")
			print_t(PetData.getAllPetInfo() )
			petInfo.level = curLv
			petInfo.exp= feedExp

			-- 计算增加的技能点
			local addPoint= PetUtil.getAddSkillPoint(originLv, curLv,pet_tmpl )
			petInfo.skill_point= tonumber(addPoint)+petInfo.skill_point

			if(tonumber(addPoint) >0 ) then
				AnimationTip.showTip(GetLocalizeStringBy("key_2544").. curLv- originLv .. GetLocalizeStringBy("key_1584") .. addPoint ..GetLocalizeStringBy("key_2429"))
				print(GetLocalizeStringBy("key_2544").. curLv- originLv .. GetLocalizeStringBy("key_1584") .. addPoint ..GetLocalizeStringBy("key_2429"))
			end

			if(callbackFunc ~= nil) then
				callbackFunc()
			end

			if(curLv > originLv) then
				PetFeedLayer.feedEffect(true)
			else
				PetFeedLayer.feedEffect(false)
			end
			ItemUtil.reduceItemByGid(PetFeedLayer.getCurFeededItemId(),1)
			PetFeedLayer.updateAfterFeeded()
		    -- PreRequest.setBagDataChangedDelete(PetFeedLayer.updateAfterFeeded) 
		end
	end

	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	args:addObject(CCInteger:create(item_id))
	args:addObject(CCInteger:create(1))
	feedPetByItemCount = feedPetByItemCount + 1
	Network.rpc(requestFunc, "pet.feedPetByItem_" .. feedPetByItemCount  , "pet.feedPetByItem", args, true)
end

-------- 定时程序
local _updateTimeScheduler 	= nil	-- scheduler

-- 停止scheduler
function stopScheduler()
	if(_updateTimeScheduler ~= nil)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

-- 启动scheduler
function startScheduler()
	if(_updateTimeScheduler == nil) then
		_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updatePetExp, 1, false)
	end
end

local perCDAddExpD = tonumber(DB_Pet_cost.getDataById(1).fenseExp)

-- 倒计时加经验
function updatePetExp()
	-- print("updatePetExp")
	local allPetInfo = PetData.getAllPetInfo()
	--setpet结构
	--{
	--	petid
	--	status
	--	producttime
	--	traintime 由后端得到
	--}
	local petOnFormation = allPetInfo.keeperInfo.va_keeper.setpet
	if(table.isEmpty(petOnFormation) == true)then
		-- 
		return
	end
	local cdTime = 60
	--循环遍历所有宠物，找到需要增加经验的来增加经验
	for k,f_petInfo in pairs(petOnFormation) do
		--f_petInfo.traintime为宠物上次训练结束的时间，加上cd时间，如果服务器时间到了则可以增加经验
		if(  tonumber(f_petInfo.petid) > 0 and tonumber(f_petInfo.traintime)>0 and TimeUtil.getSvrTimeByOffset()>=(tonumber(f_petInfo.traintime) + cdTime) )then
			local p_petInfo= PetData.getPetInfoById(f_petInfo.petid)
			--宠物等级只能低于玩家等级
			if(tonumber(p_petInfo.level) >= UserModel.getHeroLevel() )then
				break
			end
			local  callbackFunc = nil
			if(PetMainLayer.getCurPetId()~=nil and PetMainLayer.getCurPetId() == tonumber(f_petInfo.petid) )then
				callbackFunc = PetMainLayer.autoAddPetExpRefresh
			end
			addPetAutoAddExpby(f_petInfo.petid, perCDAddExpD, callbackFunc)
			f_petInfo.traintime = tonumber(f_petInfo.traintime) + cdTime
		end
	end
end

-- 定时自动加宠物经验
function addPetAutoAddExpby(petId, perCDAddExp, callbackFunc)
	print ("perCDAddExp===", perCDAddExp)
	--petInfo结构
	--		petInfo =>array(
	--			'petid => array (
	--				'petid' => int,宠物id
    -- 				'pet_tmpl' => int, 宠物模板id
    -- 				'level' => int ,宠物等级
    -- 				'exp' => int ,宠物经验
    -- 				'swallow' => int, 已经吞噬宠物的数量
    -- 				'skill_point' => int, 宠物拥有的技能点
    -- 				'va_pet' => array(
    --					skillTalent => array(0 => array(id => 0, level => int, status => int)),
    --                  skillNormal => array(0 => array(id => 0level => int, status => int)),
    --                  skillProduct => array(0 => array(id => 0, level => int, status => int)),
    --				), 宠物技能相关
	--			),
	--		),
	local petInfo= PetData.getPetInfoById(petId)
	local perCDAddExp= tonumber(perCDAddExp)
	local feedExp = perCDAddExp+ tonumber( petInfo.exp)

	local pet_tmpl = tonumber(petInfo.pet_tmpl)
	local originLv= tonumber(petInfo.level)
	local expUpgradeID= DB_Pet.getDataById(pet_tmpl).expUpgradeID
	
	--得到当前级别，当前经验和升级所需经验
	local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,feedExp)

	petInfo.level = curLv
	petInfo.exp= feedExp

	-- 计算增加的技能点
	local addPoint= PetUtil.getAddSkillPoint(originLv, curLv,pet_tmpl )
	petInfo.skill_point= tonumber(addPoint)+petInfo.skill_point

	-- if(tonumber(addPoint)>0 ) then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2544").. curLv- originLv .. GetLocalizeStringBy("key_1584") .. addPoint ..GetLocalizeStringBy("key_2429"))
	-- end

	if(callbackFunc ~= nil) then
		callbackFunc()
		LevelUpUtil.showFloatText(GetLocalizeStringBy("key_2972") .. perCDAddExp ,g_sFontPangWa)
		if(curLv > originLv) then
			--增加经验特效
			PetMainLayer.feedEffect(true)
		else
			PetMainLayer.feedEffect(false)
		end
	end
	
end

-- 给相应的宠物加经验
function addPetExpBy( petId, item_tmple_id, expFeed, callbackFunc)
	local petInfo= PetData.getPetInfoById(petId)
	local expFeed= tonumber(expFeed)
	local feedExp = expFeed+ tonumber( petInfo.exp)

	local pet_tmpl = tonumber(petInfo.pet_tmpl)
	local originLv= tonumber(petInfo.level)
	local expUpgradeID= DB_Pet.getDataById(pet_tmpl).expUpgradeID
	local addExp= DB_Item_feed.getDataById(item_tmple_id).add_exp

	if(tonumber(expFeed) >tonumber(addExp) ) then
		local rate = expFeed/addExp
		PetUtil.showCritExp(rate,expFeed )
	else
		LevelUpUtil.showFloatText(GetLocalizeStringBy("key_2972") .. expFeed ,g_sFontPangWa)
	end
	local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,feedExp)

	petInfo.level = curLv
	petInfo.exp= feedExp

	-- 计算增加的技能点
	local addPoint= PetUtil.getAddSkillPoint(originLv, curLv,pet_tmpl )
	petInfo.skill_point= tonumber(addPoint)+petInfo.skill_point

	if(callbackFunc ~= nil) then
		callbackFunc()
	end

	if(curLv > originLv) then
		PetMainLayer.feedEffect(true)
	else
		PetMainLayer.feedEffect(false)
	end
end

--[[
	@des 	:一键喂养宠物
	@param 	:petId宠物的ID
	@return :
--]]
function feedPetByOne( petId, callbackFunc)

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then

			local totalExp= tonumber(dictData.ret.feedArr.totalExp)
			local criTimes = tonumber(dictData.ret.feedArr.criTimes)

			local petInfo= PetData.getPetInfoById(petId)
			local pet_tmpl = tonumber(petInfo.pet_tmpl)
			local originLv= tonumber(petInfo.level)
			local expUpgradeID= DB_Pet.getDataById(pet_tmpl).expUpgradeID
			local feedExp = totalExp+ tonumber( petInfo.exp)

			if( criTimes>0) then
				PetUtil.showCritExp(criTimes,totalExp, 2 )
			else
				LevelUpUtil.showFloatText(GetLocalizeStringBy("key_2972") .. totalExp ,g_sFontPangWa)
			end

			if(callbackFunc ~= nil) then
				callbackFunc()
			end


			local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,feedExp)
			print("curLv is ; ",  curLv,curExp,needExp)
			petInfo.level = curLv
			petInfo.exp= feedExp
				-- 计算增加的技能点
			local addPoint= PetUtil.getAddSkillPoint(originLv, curLv,pet_tmpl )
			petInfo.skill_point= tonumber(addPoint)+petInfo.skill_point

			if(tonumber(addPoint)>0 ) then
				AnimationTip.showTip(GetLocalizeStringBy("key_2544").. curLv- originLv .. GetLocalizeStringBy("key_1584") .. addPoint ..GetLocalizeStringBy("key_2429"))
			end

			if(curLv > originLv) then
				PetFeedLayer.feedEffect(true)
			else
				PetFeedLayer.feedEffect(false)
			end
		    PreRequest.setBagDataChangedDelete(PetFeedLayer.updateAfterFeeded)  
		end
	end

	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	Network.rpc(requestFunc, "pet.feedToLimitation", "pet.feedToLimitation", args, true)
end


--[[
	@des 	:吞噬宠物
	@param 	:petId宠物的ID，bePetIds:被吞噬宠物的id数组， callbackFunc
	@return :
--]]
function swallowPet(petId,  swallowedPetId, callbackFunc)

	-- print("bePetIds bePetIds ========================= ")
	-- print(swallowedPetId)

	-- local petInfo = PetData.getPetInfoById(tonumber(petId))
	-- local swallowedPetInfo = PetData.getPetInfoById(tonumber(swallowedPetId))
	-- print_t(swallowedPetInfo)

	-- local curPetTmpl, swallowNum= petInfo.pet_tmpl , petInfo.swallow 
	-- local petDbData = DB_Pet.getDataById(tonumber(curPetTmpl) )
	-- local canSwallowNum= PetUtil.getCanSwallowNum( curPetTmpl, petInfo.level )
	-- print("canSwallowNum is ", canSwallowNum )
	
	-- local expUpgradeID= petDbData.expUpgradeID


	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then

			-- local retPetInfo= dictData.ret

			-- local orginPetExp = tonumber(petInfo.exp)
			-- local originLv = tonumber(petInfo.level )
			
			-- local swallowExp =tonumber(swallowedPetInfo.exp) 
			-- local swallowPoint =  retPetInfo.skill_point - petInfo.skill_point --petDbData.swallow*( tonumber(swallowedPetInfo.swallow)+1)
			-- local allExp= tonumber(retPetInfo.exp )--+ swallowExp --tonumber(swallowedPetInfo.exp)
			-- local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,allExp)

			-- local curLv= tonumber(retPetInfo.level) 

			-- local levelPoint = PetUtil.getAddSkillPoint(originLv, curLv,curPetTmpl)
	

			-- if(originLv >=UserModel.getHeroLevel() ) then
			-- 	swallowExp= 0
			-- end

			

			-- if(swallowExp >0) then
			-- 	LevelUpUtil.showFloatText(GetLocalizeStringBy("key_2972") .. swallowExp ,g_sFontPangWa)
			-- end
			-- if(curLv > originLv) then
			-- 	PetMainLayer.feedEffect(true)
			-- else
			-- 	PetMainLayer.feedEffect(false)
			-- end

		
			-- local addLv= curLv- originLv 
			-- if( addLv >0 ) then
			-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2544").. curLv- originLv .. GetLocalizeStringBy("key_1584") ..  swallowPoint ..GetLocalizeStringBy("key_2429"))
			-- elseif( swallowPoint >0 ) then
			-- 	AnimationTip.showTip(GetLocalizeStringBy("key_1984") .. swallowPoint ..GetLocalizeStringBy("key_2429"))
			-- end	

			-- petInfo.level = curLv
			-- petInfo.exp= allExp
			-- petInfo.skill_point= retPetInfo.skill_point --tonumber(swallowPoint)+petInfo.skill_point+ tonumber(levelPoint)
			-- petInfo.swallow= retPetInfo.swallow  --tonumber(petInfo.swallow) + swallowedPetInfo.swallow+1
			-- PetData.removePetById(swallowedPetId)

			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end


	-- if(canSwallowNum<= tonumber(petInfo.swallow)+ tonumber( swallowedPetInfo.swallow)  ) then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2289"))
	-- 	return
	-- end

	-- if(tonumber(petInfo.level )>= UserModel.getHeroLevel() and  tonumber(swallowedPetInfo.pet_tmpl)~= tonumber(petInfo.pet_tmpl)) then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_3171"))
 --        return
	-- end

	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	local bePetIds= CCArray:create()
	bePetIds:addObject(CCInteger:create(tonumber(swallowedPetId)) )
	args:addObject(bePetIds)
	print(12345,petId,swallowedPetId)
	Network.rpc(requestFunc, "pet.swallowPetArr", "pet.swallowPetArr", args, true)
end


--[[
	@des 	:开启上阵栏位
	@param 	:slotIndex:第几个上阵栏位
	@return :
--]]
function openSquandSlot( slotIndex, pGoldOrItem, callbackFunc )

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then	

			PetData.addPetSetpet()
			if(pGoldOrItem==0)then
				local costGold= PetUtil.getCostFenceGoldBySlot(slotIndex+1)
				UserModel.addGoldNumber(-costGold)
			end
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end

	local args = CCArray:create()	
	args:addObject(CCInteger:create(pGoldOrItem))
	Network.rpc(requestFunc, "pet.openSquandSlot", "pet.openSquandSlot", args, true)
 	
 end 

--[[
	@des 	:宠物上阵
	@param 	: $petid 要上阵的宠物id,$pos 要上阵的位置(这里是从0开始的。)
	@return :
--]]
function squandUpPet( petId, pos,callbackFunc)

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
		PetData.getPetAffixValue(true)	
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end
	local isSelf= false
	local petInfo =PetData.getPetInfoById(tonumber(petId))
	local curPetInfo= PetData.getPetInfoByPos(tonumber(pos) ) -- 在此位置的宠物信息

	if( tonumber(petInfo.pet_tmpl)== tonumber(curPetInfo.pet_tmpl) ) then
		isSelf = true
	end
	

	if( isSelf== false and PetData.isPetUpByPetTmpl(petInfo.pet_tmpl)== true) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1200"))
        return 
	end

	-- 求以上阵的位置
	local posIndex = PetData.getUpPosIndex()
	if(posIndex and posIndex ==pos ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1549"))
        return 
	end

	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	args:addObject(CCInteger:create(pos) )
	Network.rpc(requestFunc, "pet.squandUpPet", "pet.squandUpPet", args, true)
end

--[[
	@des 	:宠物下阵
	@param 	: $petid 要上阵的宠物id,$pos 要上阵的位置(这里是从0开始的。)
	@return :
--]]
function squandDownPet( petId, pos,callbackFunc)

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
		PetData.getPetAffixValue(true)	
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
			-- print(" =================== pos ", pos)
			-- local PetMainLayer= PetMainLayer.createLayer( pos)
			-- MainScene.changeLayer( PetMainLayer,"PetMainLayer")
		end
	end

	local petInfo= PetData.getPetInfoById(tonumber(petId))

	if(tonumber(petInfo.setpet.status )==1 ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_3211"))
		return
	end

	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	Network.rpc(requestFunc, "pet.squandDownPet", "pet.squandDownPet", args, true)
end



--[[
	@des 	:宠物出战
	@param 	: $petid 要出战的宠物
	@return :
--]]
function fightUpPet(petId,callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then	
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end

	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	Network.rpc(requestFunc, "pet.fightUpPet", "pet.fightUpPet", args, true)	
end

--[[
	@des 	: 领悟技能或栏位
	@param 	: $petid 要领悟的宠物id
	@return :
--]]
function learnSkill( petId,callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if callbackFunc then
				callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	Network.rpc(requestFunc, "pet.learnSkill", "pet.learnSkill", args, true)	
end

--[[
	@des 	: 宠物技能重置
	@param 	: $petid 要重置的宠物id
	@return :
--]]
function resetSkill( petId,callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then	
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	Network.rpc(requestFunc, "pet.resetSkill", "pet.resetSkill", args, true)	
end

--[[
	@des 	: 宠物技能重置
	@param 	: $petid 要重置的宠物id
	@return :
--]]
function collectProduction( petId,callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then	
			
			local petInfo = PetData.getPetInfoById(tonumber(petId))
			local skillId= tonumber(petInfo.va_pet.skillProduct[1].id ) 
			local level = PetData.getPetSkillLevel( tonumber(petId) ) --tonumber(petInfo.va_pet.skillProduct[1].level )
			PetUtil.addProduceItem(skillId, level)
			PetUtil.showProduceItem(skillId, level)
			PetData.setProducttimeById(tonumber(petId), BTUtil:getSvrTimeInterval())

			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end


	local petInfo = PetData.getPetInfoById(tonumber(petId))
	local skillId= tonumber(petInfo.va_pet.skillProduct[1].id ) 
	local level = tonumber(petInfo.va_pet.skillProduct[1].level )
	local specialReward=DB_Pet_skill.getDataById(skillId).specialReward

	local rewardInfo= PetUtil.getProdceInfo(skillId, level)  --lua_string_split(specialReward, "|")
	local rewardType= tonumber(rewardInfo[1]) 
	local rewardId = tonumber(rewardInfo[2])
	local rewardNum= tonumber(rewardInfo[3])

	if(rewardType == 7 or rewardType==6 ) then
		if(ItemUtil.isBagFull()) then
			return
		end
	end

	if(rewardType == 10 or rewardType== 13) then
		if(HeroPublicUI.showHeroIsLimitedUI() ) then
			return
		end
	end


	local args = CCArray:create()	
	args:addObject(CCInteger:create(petId))
	Network.rpc(requestFunc, "pet.collectProduction", "pet.collectProduction", args, true)	
end

--[[
	/**
	 * 一键领取宠物特殊技能产出的东西
	 * @return array
	 * <code>
	 * {
	 *     'err' => 'ok' or 'addProErr' 后者表示添加物品没有成功
	 *     'petIdsArr' => array($petid....)已经领取的宠物id
	 * }
	 * </code>
	 */
	public function collectAllProduction();
	@des 	: 一键领取所有宠物产出
	@param 	:
	@return :
--]]
function collectAllProduction( pCallback )
	local updatePetDataById = function ( pPetIds )
		if table.isEmpty(pPetIds) then
			print("collectProduction pPetIds is empty")
			return
		end

		local nSvrTime = BTUtil:getSvrTimeInterval()
		local tbAllProductSkills = {}
		for k, nPetId in pairs(pPetIds) do
			local petInfo = PetData.getPetInfoById(tonumber(nPetId))
			local skillId= tonumber(petInfo.va_pet.skillProduct[1].id ) 
			local level = PetData.getPetSkillLevel( tonumber(nPetId) ) --tonumber(petInfo.va_pet.skillProduct[1].level )
			PetUtil.addProduceItem(skillId, level)
			PetData.setProducttimeById(tonumber(nPetId), nSvrTime)

			local tbProductSkill = {}
			tbProductSkill.skillid, tbProductSkill.skilllevel = skillId, level
			table.insert(tbAllProductSkills, tbProductSkill)
		end

		--显示所有产出
		PetUtil.showProduceItemAll( tbAllProductSkills )
	end

	local requestFunc = function ( pFlag, pDictData, pRet )
		if pDictData.err == "ok" then
			if pDictData.ret.err == "ok" then
				--领取成功
				updatePetDataById(pDictData.ret.petIdsArr)

			elseif petDbData.ret.err == "addProErr" then
				--领取失败
				AnimationTip.showTip(GetLocalizeStringBy("zq_0018"))
				return
			else

			end

			if pCallback ~= nil then
				pCallback(pDictData.ret)
			end
		end
	end

	Network.rpc(requestFunc, "pet.collectAllProduction", "pet.collectAllProduction", nil, true)
end


function sellPets( callbackFunc, sellPetIds )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if (dictData.err == "ok") then	
				for i=1, #sellPetIds do
					PetData.removePetById(tonumber(sellPetIds[i]) )
				end
				-- print("sellPets success!")
				-- print_t(dictData)
				if(callbackFunc ~= nil) then
					callbackFunc(dictData.ret)
				end
			end
		end
	end

	local args = CCArray:create()

	local args_1= CCArray:create()

	for i=1, #sellPetIds do
		args_1:addObject(CCInteger:create( sellPetIds[i]))
	end

	args:addObject(args_1)
	Network.rpc(requestFunc, "pet.sellPet","pet.sellPet",args, true)

end


-- added by bzx
-- /**
--  * 宠物图鉴相关信息
--  * 
--  * @return arrray
--  * [
--  * 		模板id，模板id...
--  * ]
--  * 
--  */
function getPetHandbookInfo(p_callback)
	local requestCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		PetData.setHandbookInfo(dictData.ret)
		PetData.getExtenseAffixes(true)
		if p_callback ~= nil then
			p_callback()
		end
	end
	Network.rpc(requestCallback, "pet.getPetHandbookInfo","pet.getPetHandbookInfo", nil, true)
end
--[[
	@des 	:宠物进阶
	@param 	:
	@return :
--]]
function evolve( pPetId,pCallback )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pPetId })
	Network.rpc(requestFunc,"pet.evolve","pet.evolve",args,true)
end
--[[
	@des 	:宠物洗练
	@param 	:
	@return :
--]]
function wash( pPetId,pGrade,pNum,pCallback,pIsForce )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pPetId,pGrade,pNum,pIsForce })
	Network.rpc(requestFunc,"pet.wash","pet.wash",args,true)
end
--[[
	@des 	:洗练后确认属性
	@param 	:
	@return :
--]]
function ensure( pPetId,pCallback )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pPetId })
	Network.rpc(requestFunc,"pet.ensure","pet.ensure",args,true)
end
--[[
	@des 	:洗练后取消属性
	@param 	:
	@return :
--]]
function giveUp( pPetId,pCallback )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pPetId })
	Network.rpc(requestFunc,"pet.giveUp","pet.giveUp",args,true)
end
--[[
	@des 	:宠物资质兑换
	@param 	:
	@return :
--]]
function exchange( pPetID,pSwapPetID,pCallback )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pPetID,pSwapPetID })
	Network.rpc(requestFunc,"pet.exchange","pet.exchange",args,true)
end