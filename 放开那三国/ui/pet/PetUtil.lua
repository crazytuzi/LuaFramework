-- Filename：	PetUtil.lua
-- Author：		zhz
-- Date：		2014-3-31
-- Purpose：		宠物的主界面

module("PetUtil", package.seeall)

require "db/DB_Pet"
require "db/DB_Normal_config"
require "script/utils/BaseUI"
require "db/DB_Pet_cost"
require "db/DB_Pet_skill"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"


--[[
	@des:		得到上阵宠物的信息
	@param:		petTId: 宠物的模版ID， showStatus:宠物的状态，1,开启了，有宠物， 2:开启了，无宠物，3:未开启，锁定中 4, 在背包中的宠物
	@return:	图标sprite 
--]]
function getPetIMGById( petTId, showStatus , slotIndex)
	
	local petShowSprite= nil
	
	local slotIndex = slotIndex or 1

	if(showStatus == 1 ) then
		local petData= DB_Pet.getDataById(petTId)
		petShowSprite = CCSprite:create("images/pet/body_img/" .. petData.roleModelID )	
	
	elseif(showStatus == 2) then
		petShowSprite= CCSprite:create("images/pet/pet/horse_dark.png")
		local arrow = CCSprite:create("images/pet/pet/plus_n.png")
		arrow:setPosition(petShowSprite:getContentSize().width*0.6, 163)
		arrow:setAnchorPoint(ccp(0.5,0))
		petShowSprite:addChild(arrow)
		plusAction(arrow)
		local tameSprite= CCSprite:create("images/pet/pet/tame_pet.png")
		tameSprite:setPosition(petShowSprite:getContentSize().width*0.6,112)
		tameSprite:setAnchorPoint(ccp(0.5,0))
		petShowSprite:addChild(tameSprite)

	elseif(showStatus == 3) then 
		petShowSprite= CCSprite:create("images/pet/pet/horse_dark.png")
		local lockSprite = CCSprite:create("images/formation/potential/extralock.png")
		lockSprite:setAnchorPoint(ccp(0.5,0))
		lockSprite:setPosition(petShowSprite:getContentSize().width*0.6, 153)
		petShowSprite:addChild(lockSprite)
		-- local goldSp= CCSprite:create("images/common/gold.png")
		local costGold, needLevel =  getCostFenceGoldBySlot( slotIndex)
		-- local goldLabel = CCRenderLabel:create(costGold ,g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		-- local goldNode = BaseUI.createHorizontalNode({goldSp, goldLabel})
		-- goldNode:setPosition(petShowSprite:getContentSize().width*0.6, 125)
		-- goldNode:setAnchorPoint(ccp(0.5,0))
		-- petShowSprite:addChild(goldNode)

		if(tonumber(needLevel)<999) then
			local needLevelLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1483") ..needLevel.. GetLocalizeStringBy("key_2372"), g_sFontPangWa,23,1, ccc3(0x00,0x00,0x00), type_stroke)
			needLevelLabel:setAnchorPoint(ccp(0.5,0))
			needLevelLabel:setPosition(petShowSprite:getContentSize().width*0.6,125)
			petShowSprite:addChild(needLevelLabel)
		end


	elseif(showStatus == 4) then
		local petData= DB_Pet.getDataById(petTId)
		petShowSprite = CCSprite:create("images/pet/body_img/" .. petData.roleModelID )	

	end

	return petShowSprite
end

-- 加号的动画
function plusAction( sprite)
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeOut:create(1))
	arrActions:addObject(CCFadeIn:create(1))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	sprite:runAction(action)
end

-- 通过模版id来获得宠物的头像
--itid为模板id
--p_tag为menu的下标值
--clickBtnAction为回调函数
--menu_priority为优先级
function getPetHeadIconByItid(itid,p_tag,clickBtnAction,menu_priority)
	--p_tag为用作menu下标的tag值
	local tag = p_tag or itid

	local priority = menu_priority or (-300)

	local petData = DB_Pet.getDataById(itid)

	local headBg = CCSprite:create("images/base/potential/officer_" .. tostring(petData.quality) .. ".png")
	local headSize = headBg:getContentSize()
	local headIconFile = "images/pet/head_icon/" .. tostring(petData.headIcon)

	local menuBar = BTSensitiveMenu:create()
	if(menuBar:retainCount()>1)then
        menuBar:release()
        menuBar:autorelease()
    end
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(priority)
	headBg:addChild(menuBar)

	local pet_btn = CCMenuItemImage:create(headIconFile,headIconFile)
	if(clickBtnAction ~= nil ) then
		pet_btn:registerScriptTapHandler(clickBtnAction)
	end
	pet_btn:setAnchorPoint(ccp(0.5, 0.5))
	pet_btn:setPosition(ccp(headSize.width/2,headSize.height/2))
	menuBar:addChild(pet_btn,1,tonumber(tag))

	return headBg
end

-- 得到最大可以上阵宠物的数量
function getMaxFormationNum()
	local vip = UserModel.getVipLevel()
	require "db/DB_Vip"
	local maxPetFence= DB_Vip.getDataById(vip+1).maxPetFence
	return tonumber(maxPetFence) 
end

function getPetFence( )
	local openPetFenceGold = lua_string_split(DB_Pet_cost.getDataById(1).openPetFenceGold,",") 
end

-- 通过获得对应栏位的所消耗的金币和需要的等级
function getCostFenceGoldBySlot( slotIndex)

	local slotIndex = tonumber(slotIndex)
	local openPetFenceGold = lua_string_split(DB_Pet_cost.getDataById(1).openPetFenceGold,",")
	local petFence = openPetFenceGold[slotIndex]

	local costGold= tonumber(lua_string_split(petFence, "|")[2])
	local costLevel = tonumber(lua_string_split(petFence, "|")[1])
	return costGold, costLevel
end



-- 展示暴击获得的禁言
function showCritExp(criTimes,feedExp, criType)
	local alertContent = {}
	local criType= criType or 1
	local word = GetLocalizeStringBy("key_1873")

	if(criType ==1) then
		word= GetLocalizeStringBy("key_1873")
	else
		word= GetLocalizeStringBy("key_3010")
	end	

	alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1733") .. criTimes .. word , g_sFontPangWa, 140,2, ccc3(0x00,0,0),type_stroke)
	alertContent[1]:setColor(ccc3(0xe9, 0xf7, 0x0d))
	alertContent[2] = CCRenderLabel:create(GetLocalizeStringBy("key_2972") .. feedExp , g_sFontPangWa, 140,2, ccc3(0x00,0,0),type_stroke)
	alertContent[2]:setColor(ccc3(0xff, 0x00, 0x00))
	LevelUpUtil.showScaleTxt(alertContent)
end


--[[
	@des 	: 得到对应宠物技能的图标
	@param 	: skillId: 技能id，lv ：等级，status：0，没有锁定，1，锁定
	@return :
--]]
function getNormalSkillIcon( skillId, lv,addlv,status,petId,delegate,menu_priority, zOrderNum)
	local _menu_priority = menu_priority or (-550)
	_itemDelegateAction = itemDelegateAction
	item_tmpl_id = tonumber(item_tmpl_id)
	print("item_tmpl_id", item_tmpl_id)
	print("petId is  ", petId)

	_zOrderNum = zOrderNum or 999

	local skillId= tonumber(skillId)
	local lv = lv or 1
	local status= status or 0
	local item_sprite

	if(skillId == 0) then
		item_sprite= CCSprite:create("images/formation/potential/officer_11.png")
		return item_sprite
	end

	local skillData = DB_Pet_skill.getDataById(skillId)
	local bgFile = "images/base/potential/props_" .. skillData.skillQuality .. ".png"
	local iconFile = "images/pet/skill/" ..skillData.icon .. ".png" 
		
	item_sprite = CCSprite:create(bgFile)

	--品质加等级长方形

	-- if tonumber(lv) > 1 then
		local petSkillQuality = skillData.skillQuality

		local qualityButtom = CCSprite:create("images/base/potential/lv_" .. petSkillQuality .. ".png")
		qualityButtom:setAnchorPoint(ccp(0,1))
		qualityButtom:setPosition(ccp(-1,item_sprite:getContentSize().height))
		item_sprite:addChild(qualityButtom,11)

		local lvNum = CCLabelTTF:create("" .. tonumber(lv)+tonumber(addlv) , g_sFontPangWa ,18)
		lvNum:setAnchorPoint(ccp(0.5,0.5))
		lvNum:setPosition(ccp(qualityButtom:getContentSize().width/2,qualityButtom:getContentSize().height/2))
		qualityButtom:addChild(lvNum,11)
	-- end
	local function clickBtnAction( tag, item)
		require "script/ui/pet/PetSkillInfoLayer"
		PetSkillInfoLayer.showLayer(tag,lv,status,petId,delegate)
	end

	-- 按钮Bar
	local menuBar = BTSensitiveMenu:create()
	if(menuBar:retainCount()>1)then
        menuBar:release()
        menuBar:autorelease()
    end
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(-540)
	item_sprite:addChild(menuBar)
	local item_btn = CCMenuItemImage:create(iconFile,iconFile)
	item_btn:registerScriptTapHandler(clickBtnAction)
	item_btn:setAnchorPoint(ccp(0.5, 0.5))
	item_btn:setPosition(ccp(item_sprite:getContentSize().width/2, item_sprite:getContentSize().height/2))
	menuBar:addChild(item_btn, 1, tonumber(skillId))
	menuBar:setTouchPriority(_menu_priority)

	if(tonumber(status) ==1) then
		local lockSprite = CCSprite:create("images/hero/lock.png")
		lockSprite:setPosition(item_btn:getContentSize().width-2,3)
		lockSprite:setAnchorPoint(ccp(1,0))
		item_btn:addChild(lockSprite)
	end

	return item_sprite
end


--[[
	@des 	: 得到对应宠物技能的图标
	@param 	: skillId: 技能id，lv ：等级，status：0，没有锁定，1，锁定
	@return :
--]]
function getSkillIcon( skillId, lv,status, menu_priority, zOrderNum)
	local _menu_priority = menu_priority
	_itemDelegateAction = itemDelegateAction
	item_tmpl_id = tonumber(item_tmpl_id)
	print("item_tmpl_id", item_tmpl_id)
	_zOrderNum = zOrderNum or 999

	local skillId= tonumber(skillId)

	local lv = lv or 1
	local status= status or 0

	
	if(skillId == 0) then
		item_sprite= CCSprite:create("images/formation/potential/officer_11.png")
		return item_sprite
	end

	local skillData = DB_Pet_skill.getDataById(skillId)
	local bgFile = "images/base/potential/props_" .. skillData.skillQuality .. ".png"
	local iconFile = "images/pet/skill/" ..skillData.icon .. ".png" 

	local item_sprite = CCSprite:create(bgFile)

	if (skillData.isSpecial ==nil or skillData.isSpecial ==0 ) then
		local petSkillQuality = skillData.skillQuality

		local qualityButtom = CCSprite:create("images/base/potential/lv_" .. petSkillQuality .. ".png")
		qualityButtom:setAnchorPoint(ccp(0,1))
		qualityButtom:setPosition(ccp(-1,item_sprite:getContentSize().height))
		item_sprite:addChild(qualityButtom,11)

		local lvNum = CCRenderLabel:create(lv, g_sFontPangWa ,18,1,ccc3(0x00,0x00,0x00),type_stroke)
		lvNum:setAnchorPoint(ccp(0.5,0.5))
		lvNum:setPosition(ccp(qualityButtom:getContentSize().width/2,qualityButtom:getContentSize().height/2))
		qualityButtom:addChild(lvNum,11)
	end
	-- -- 按钮Bar
	local menuBar = BTSensitiveMenu:create()
	if(menuBar:retainCount()>1)then
        menuBar:release()
        menuBar:autorelease()
    end
	menuBar:setPosition(ccp(0, 0))
	item_sprite:addChild(menuBar)
	local item_btn = CCMenuItemImage:create(iconFile,iconFile)
	item_btn:setAnchorPoint(ccp(0.5, 0.5))
	item_btn:setPosition(ccp(item_sprite:getContentSize().width/2, item_sprite:getContentSize().height/2))
	menuBar:addChild(item_btn, 1, tonumber(skillId))

	if(tonumber(status) ==1) then
		local lockSprite = CCSprite:create("images/hero/lock.png")
		lockSprite:setPosition(item_btn:getContentSize().width-2,3)
		lockSprite:setAnchorPoint(ccp(1,0))
		item_btn:addChild(lockSprite)
	end

	return item_sprite
end

function getLockIcon(  )

	local bgFile = "images/formation/potential/officer_11.png"
	local iconFile = "images/formation/potential/lock.png"

	local item_sprite = CCSprite:create(bgFile)
	local iconSP= CCSprite:create(iconFile)

	iconSP:setPosition(item_sprite:getContentSize().width/2, item_sprite:getContentSize().height/2)
	iconSP:setAnchorPoint(ccp(0.5,0.5))
	item_sprite:addChild(iconSP)

	return item_sprite
	
end


-- 获得增加的宠物技能点数
function getAddSkillPoint(levelBeforeFeed, lvAfterFeed,pet_tmpl  )
	local addPoint= 0

	if(tonumber(levelBeforeFeed)== tonumber(lvAfterFeed) ) then
		return addPoint
	end

	local petData= DB_Pet.getDataById(tonumber(pet_tmpl))
	for levelTmp= levelBeforeFeed + 1, lvAfterFeed do 
		if(levelTmp% petData.graspCd==0 ) then
			addPoint=addPoint+ petData.graspGrowth
		end
	end

	return addPoint
end


-- 得到普通技能的加成
function getNormalSkill(skillId, lv)
	
	local skillProperty= {}
	local lv= lv or 1

	if(tonumber(skillId)==0) then
		return skillProperty
	end

	local affixGrow= DB_Pet_skill.getDataById(tonumber(skillId)).affixGrow

	affixGrow= lua_string_split(affixGrow, ",")

	for i=1, #affixGrow do
		local tempTable= {}
		local affix = lua_string_split(affixGrow[i], "|")
		local affixId= tonumber(affix[1])
		local affIxNum= tonumber(affix[2])*lv
		tempTable.affixDesc,tempTable.displayNum,tempTable.realNum = ItemUtil.getAtrrNameAndNum(affixId,affIxNum)
		table.insert(skillProperty,tempTable )
	end

	return skillProperty
	
end

-- 通过技能的ID，和等级来获得技能信息
function getProdceInfo(skillId, lv)

	local skillId = tonumber(skillId)	
	print(GetLocalizeStringBy("key_1937"),skillId)
	local specialReward=DB_Pet_skill.getDataById(skillId).specialReward
	local lv=lv or 1

	if(specialReward == nil) then
		print(" error, specialReward can not be null!  ")
		return
	end
	local rewardInfos = lua_string_split(specialReward, ",")
	local rewardInfo= {}

	if( tonumber(lv) > table.count(rewardInfos) ) then
		rewardInfo= rewardInfos[ table.count(rewardInfos)] 
	else
		rewardInfo = rewardInfos[tonumber(lv) ]
	end

	local  rewardData =lua_string_split(rewardInfo, "|")

	return rewardData
	
end

--[[
	@des 	: 得到宠物特殊奖励技能奖励的图标
	@param 	: 
	@return :iconSprite
--]]
--[[
	1、银币
	2、将魂
	3、金币
	4、体力
	5、耐力
	6、物品
	7、多个物品
	8、等级*银币
	9、等级*将魂
	10、英雄ID（单个英雄）
	11、魂玉（新加）
	12、声望（新加）
	13、多个英雄（数量可大于1）
	14、宝物碎片（填写方式与7相同）
--]]
-- iconType＝＝1 ，未sprite, 否则未icon
function getProduceIcon( skillId,lv , iconType , zOrder, touchPriority)
	
	-- local skillId = tonumber(skillId)	
	-- print(GetLocalizeStringBy("key_1937"),skillId)
	-- local specialReward=DB_Pet_skill.getDataById(skillId).specialReward

	-- local rewardInfo= lua_string_split(specialReward, "|")

	local rewardInfo = getProdceInfo(skillId, lv)

	local rewardType= tonumber(rewardInfo[1]) 
	local rewardId = tonumber(rewardInfo[2])
	local rewardNum= tonumber(rewardInfo[3])

	print("rewardInfo  is : ========== ")
	print_t(rewardInfo)

	local item_sprite= nil

	local iconType= iconType or 1
	if(rewardType ==1) then
		item_sprite = ItemSprite.getSiliverIconSprite()

	elseif(rewardType ==2) then
		item_sprite= ItemSprite.getSoulIconSprite()

	elseif(rewardType==3) then
		item_sprite= ItemSprite.getGoldIconSprite()

	elseif(rewardType == 4) then
		item_sprite= getEnergyIconSprite()

	elseif(rewardType ==5) then
		item_sprite= getEnergyIconSprite()

	elseif(rewardType ==6) then
		if(iconType ==1) then
			item_sprite= ItemSprite.getItemSpriteByItemId(rewardId)
		-- else
		-- 	item_sprite= 
		end	

	elseif(rewardType ==7) then
		item_sprite= ItemSprite.getItemSpriteByItemId(rewardId)

	elseif(rewardType ==8) then
		item_sprite = ItemSprite.getSiliverIconSprite()

	elseif(rewardType ==9) then
		item_sprite = ItemSprite.getSoulIconSprite()
	elseif(rewardType ==10) then
		item_sprite = getHeroIcon(rewardId ) --ItemSprite.getHeroIconItemByhtid(rewardId,-10)

	elseif(rewardType==11) then
		item_sprite = ItemSprite.getJewelSprite(rewardId)

	elseif(rewardType ==12) then
		item_sprite = ItemSprite.getPrestigeSprite(rewardId)

	elseif(rewardType ==13) then
		item_sprite = getHeroIcon(rewardId )  --ItemSprite.getHeroIconItemByhtid(rewardId,-10)

	elseif(rewardType ==14) then
		item_sprite= ItemSprite.getItemSpriteByItemId(rewardId,-10)
	end


	-- borderSp:addChild(item_sprite)
	-- item_sprite:setPosition(ccp(borderSp:getContentSize().width/2,borderSp:getContentSize().height/2 ))
	-- item_sprite:setAnchorPoint(ccp(0.5,0.5))


	print(GetLocalizeStringBy("key_2940"),rewardNum)

	print(GetLocalizeStringBy("key_1232"),rewardNum)

	if(rewardNum>1) then
		local numLabel= CCLabelTTF:create(tostring(rewardNum),g_sFontPangWa,18)
		numLabel:setColor(ccc3(0x00,0xff,0x18))
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(ccp(item_sprite:getContentSize().width-6 , 3))
		item_sprite:addChild(numLabel,99)
	end

	return item_sprite
end

-- 对普通技能进行排序
function sortSkillNormal(skillNormal )

	local function keySort ( skillNormal_1, skillNormal_2 )
        return tonumber(skillNormal_1.id ) > tonumber(skillNormal_2.id)
    end
    table.sort( skillNormal, keySort)
end

function sortSkillNormal_2( skillNormal )
    
    for i=1, #skillNormal do
        if( tonumber(skillNormal[i].id) ==0 and not table.isEmpty(skillNormal[i+1]) ) then
            local c= skillNormal[i]
            skillNormal[i]=skillNormal[i+1]
            skillNormal[i+1]= c
        end
    end
end

function getProduceName( skillId, lv)

	-- local skillId = tonumber(skillId)
	-- local specialReward=DB_Pet_skill.getDataById(skillId).specialReward

	-- local rewardInfo= lua_string_split(specialReward, "|")

	local rewardInfo = getProdceInfo(skillId, lv)

	local rewardType= tonumber(rewardInfo[1]) 
	local rewardId = tonumber(rewardInfo[2])
	local rewardNum= tonumber(rewardInfo[3])

	local itemName= nil

	if(rewardType ==1) then
		itemName = GetLocalizeStringBy("key_1687")

	elseif(rewardType ==2) then
		itemName = GetLocalizeStringBy("key_1616")

	elseif(rewardType==3) then
		itemName = GetLocalizeStringBy("key_1491")
	elseif(rewardType == 4) then
		itemName = GetLocalizeStringBy("key_3221")

	elseif(rewardType ==5) then
		itemName = GetLocalizeStringBy("key_1451")

	elseif(rewardType ==6) then

		itemName = ItemUtil.getItemById(rewardId).name

	elseif(rewardType ==7) then
		itemName = ItemUtil.getItemById(rewardId).name

	elseif(rewardType ==8) then
		itemName = GetLocalizeStringBy("key_1878")

	elseif(rewardType ==9) then
		itemName = GetLocalizeStringBy("key_1475")
	elseif(rewardType ==10) then
		require "db/DB_Heroes"
		itemName = DB_Heroes.getDataById(rewardId).name

	elseif(rewardType==11) then
		itemName = GetLocalizeStringBy("key_1510")

	elseif(rewardType ==12) then
		itemName = GetLocalizeStringBy("key_2231")

	elseif(rewardType ==13) then
		itemName = DB_Heroes.getDataById(rewardId).name

	elseif(rewardType ==14) then
		itemName = ItemUtil.getItemById(rewardId).name

	end
	print(GetLocalizeStringBy("key_1882"),rewardNum)
	return itemName, rewardNum , rewardType
	
end


-- 获得体力的icon
function getEnergyIconSprite()
    local potentialSprite = CCSprite:create("images/base/potential/props_3.png")
    local iconSprite  = CCSprite:create("images/online/reward/energy_big.png")
    iconSprite:setAnchorPoint(ccp(0.5, 0.5))
    iconSprite:setPosition(ccp(potentialSprite:getContentSize().width*0.5, potentialSprite:getContentSize().height*0.5))
    potentialSprite:addChild(iconSprite)
    return potentialSprite
end

-- 获得耐力的icon
function getEnergyIconSprite()
    local potentialSprite = CCSprite:create("images/base/potential/props_3.png")
    local iconSprite  = CCSprite:create("images/online/reward/stain_big.png")
    iconSprite:setAnchorPoint(ccp(0.5, 0.5))
    iconSprite:setPosition(ccp(potentialSprite:getContentSize().width*0.5, potentialSprite:getContentSize().height*0.5))
    potentialSprite:addChild(iconSprite)
    return potentialSprite
end

-- 零时写法
function getHeroIcon(id )
	require "db/DB_Heroes"
	local db_hero = DB_Heroes.getDataById(tonumber(id))
	local sHeadIconImg="images/base/hero/head_icon/" .. db_hero.head_icon_id
	local sQualityBgImg="images/hero/quality/"..db_hero.star_lv .. ".png"
	-- 头像item背景
	local item_bg = CCSprite:create(sQualityBgImg)
	local headIcon_n = CCSprite:create(sHeadIconImg)
	headIcon_n:setAnchorPoint(ccp(0.5,0.5))
	headIcon_n:setPosition(ccp(item_bg:getContentSize().width*0.5,item_bg:getContentSize().height*0.5))
	item_bg:addChild(headIcon_n,1)

	return item_bg

end

-- 得到宠物生产时间
function getProduceTime(skillId, lv )

	-- print("skillId is : ", skillId)
	local skillData = DB_Pet_skill.getDataById(tonumber(skillId))
	local rewardCd = lua_string_split(skillData.rewardCd , ",")
	local cdTime= 0

	for i=1, #rewardCd do
		local rewardTime= lua_string_split( rewardCd[i] ,"|")
		if(tonumber(lv)== tonumber(rewardTime[1])) then
			cdTime= rewardTime[2]
			break
		end
	end

	return cdTime
end

-- 
function addProduceItem( skillId, lv  )

	-- local skillId = tonumber(skillId)
	-- local specialReward=DB_Pet_skill.getDataById(skillId).specialReward

	-- local rewardInfo= lua_string_split(specialReward, "|")

	local rewardInfo = getProdceInfo(skillId, lv)

	local rewardType= tonumber(rewardInfo[1]) 
	local rewardId = tonumber(rewardInfo[2])
	local rewardNum = tonumber(rewardInfo[3])

	if(rewardType ==1) then
		UserModel.addSilverNumber(rewardNum)

	elseif(rewardType ==2) then
		 UserModel.addSoulNum(rewardNum)

	elseif(rewardType==3) then
		 UserModel.addGoldNumber(rewardNum)
	elseif(rewardType == 4) then
		 UserModel.addEnergyValue(rewardNum)

	elseif(rewardType ==5) then
		 UserModel.addStaminaNumber(rewardNum)

	elseif(rewardType ==6) then

	elseif(rewardType ==7) then

	elseif(rewardType ==8) then
		-- itemName = GetLocalizeStringBy("key_1878")
		local silver = tonumber(rewardNum)*UserModel.getHeroLevel()
        UserModel.addSilverNumber(silver)

	elseif(rewardType ==9) then
		-- itemName = GetLocalizeStringBy("key_1475")

		local soul  = tonumber(rewardNum)*UserModel.getHeroLevel()
        UserModel.addSoulNum(soul)
	elseif(rewardType ==10) then

	elseif(rewardType==11) then
		-- itemName = GetLocalizeStringBy("key_1510")
		UserModel.addJewelNum(rewardNum)

	elseif(rewardType ==12) then
		-- itemName = GetLocalizeStringBy("key_2231")
		UserModel.addPrestigeNum(rewardNum)

	elseif(rewardType ==13) then
		
	elseif(rewardType ==14) then

	end
end


	-- 11、魂玉（新加）
	-- 12、声望（新加）
	-- 13、多个英雄（数量可大于1）
	-- 14、宝物碎片（填写方式与7相同）
function showProduceItem( skillId, lv )
	-- local skillId = tonumber(skillId)
	-- local specialReward=DB_Pet_skill.getDataById(skillId).specialReward

	-- local rewardInfo= lua_string_split(specialReward, "|")

	local rewardInfo = getProdceInfo(skillId, lv)

	local rewardType= tonumber(rewardInfo[1]) 
	local rewardId = tonumber(rewardInfo[2])
	local rewardNum = tonumber(rewardInfo[3])

	local items ={}

	local item= {}

	if(rewardType ==1) then
		item.type = "silver"
		item.num = rewardNum
		item.name = GetLocalizeStringBy("key_2889") .. rewardNum

	elseif(rewardType ==2) then
		item.type = "soul"
		item.num = rewardNum
		item.name = GetLocalizeStringBy("key_1603") .. rewardNum

	elseif(rewardType==3) then
		item.type = "gold"
		item.num =rewardNum 
		item.name = GetLocalizeStringBy("key_1443") .. rewardNum	
	elseif(rewardType == 4) then
		item.type = "execution"
		item.num = rewardNum
		item.name = GetLocalizeStringBy("key_3162") ..rewardNum

	elseif(rewardType ==5) then
		item.type = "stamina"
		item.num = rewardNum
		item.name = GetLocalizeStringBy("key_2996") .. rewardNum

	elseif(rewardType ==6) then
		item.tid = rewardId
		item.num = rewardNum
		item.type = "item"
		item.name = ItemUtil.getItemById(tonumber(item.tid)).name 
	elseif(rewardType ==7) then
		item.tid = rewardId
		item.num = rewardNum
		item.type = "item"
		item.name = ItemUtil.getItemById(tonumber(item.tid)).name 

	elseif(rewardType ==8) then
		-- itemName = GetLocalizeStringBy("key_1878")
		item.type = "silver"
		item.num = rewardNum*UserModel.getHeroLevel()
		item.name = GetLocalizeStringBy("key_2889") .. item.num

	elseif(rewardType ==9) then
		-- itemName = GetLocalizeStringBy("key_1475")

		item.type = "soul"
		item.num = rewardNum*UserModel.getHeroLevel()
		item.name = GetLocalizeStringBy("key_2889") .. item.num
	elseif(rewardType ==10) then
		item.type = "hero"
		item.tid = rewardNum
		item.num = rewardNum
		item.name =  DB_Heroes.getDataById(item.tid).name

	elseif(rewardType==11) then
		item.type = "jewel"
		item.num = rewardNum
		item.name = GetLocalizeStringBy("key_1539") .. rewardNum

	elseif(rewardType ==12) then
			item.type = "prestige"
		item.num = rewardNum
		item.name = GetLocalizeStringBy("key_2919") .. rewardNum

	elseif(rewardType ==13) then
		item.type = "hero"
		item.tid = rewardId
		item.num = rewardNum
		item.name =  DB_Heroes.getDataById(item.tid).name
		
	elseif(rewardType ==14) then
		item.tid = rewardId
		item.num = rewardNum
		item.type = "item"
		item.name = ItemUtil.getItemById(tonumber(item.tid)).name 

	end

	table.insert(items,  item)

	 require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( items, nil , 1111, -800 )
end

--[[
	@desc : 一键领取多个宠物的产出
	@param: pProductSkills = {
		[1] = {
			skillid = int,
			skilllevel   = int,
		},
		[2] = {
			skillid = int,
			skilllevel   = int,
		},
		...
	}
	@ret  :
--]]
function showProduceItemAll( pProductSkills )
	if table.isEmpty(pProductSkills) then
		print("showProduceItemAll is empty")
		return
	end

	local tbAllItems = {}
	local mapAllItems = {}   --用于查寻是否是已拥有的产出
	for k, tbData in pairs(pProductSkills) do
		local tbItem = parseProduceByIdAndLv(tbData.skillid, tbData.skilllevel)

		if not table.isEmpty(tbItem) then
			local tbResult = mapAllItems[tbItem.tid]
			if table.isEmpty(tbResult) then   --若已记录中的产出不包含该类型，则重新记录
				table.insert(tbAllItems, tbItem)
				mapAllItems[tbItem.tid] = tbItem
			else                              --若已记录中的产出包含该类型，则累加，并修改描述
				tbResult.num = tbResult.num + tbItem.num
				if tbResult.type ~= "item" and tbResult.type ~= "hero" then
					tbResult.name = tbResult.desc .. tbResult.num
				end
			end
		end
	end

	require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( tbAllItems, nil , 1111, -800 )
end

--[[
	@desc : 根据产出技能id和登记 解析宠物产出
	@param: 
	@ret  :
--]]
function parseProduceByIdAndLv( pSkillId, pLevel )
	local rewardInfo = getProdceInfo(pSkillId, pLevel)
	if table.isEmpty(rewardInfo) then
		return {}
	end

	local rewardType= tonumber(rewardInfo[1]) 
	local rewardId = tonumber(rewardInfo[2])
	local rewardNum = tonumber(rewardInfo[3])

	local item= {}

	if(rewardType ==1) then
		item.tid  = rewardType
		item.type = "silver"
		item.num = rewardNum
		item.desc = GetLocalizeStringBy("key_2889")
		item.name = item.desc .. rewardNum

	elseif(rewardType ==2) then
		item.tid  = rewardType
		item.type = "soul"
		item.num = rewardNum
		item.desc = GetLocalizeStringBy("key_1603")
		item.name = item.desc .. rewardNum

	elseif(rewardType==3) then
		item.tid  = rewardType
		item.type = "gold"
		item.num =rewardNum 
		item.desc = GetLocalizeStringBy("key_1443")
		item.name = item.desc .. rewardNum
	elseif(rewardType == 4) then
		item.tid  = rewardType
		item.type = "execution"
		item.num = rewardNum
		item.desc = GetLocalizeStringBy("key_3162")
		item.name = item.desc .. rewardNum

	elseif(rewardType ==5) then
		item.tid  = rewardType
		item.type = "stamina"
		item.num = rewardNum
		item.desc = GetLocalizeStringBy("key_2996")
		item.name = item.desc .. rewardNum

	elseif(rewardType ==6) then
		item.tid = rewardId
		item.num = rewardNum
		item.type = "item"
		item.desc = ItemUtil.getItemById(tonumber(item.tid)).name 
		item.name = item.desc
	elseif(rewardType ==7) then
		item.tid = rewardId
		item.num = rewardNum
		item.type = "item"
		item.desc = ItemUtil.getItemById(tonumber(item.tid)).name 
		item.name = item.desc

	elseif(rewardType ==8) then
		item.tid  = rewardType
		-- itemName = GetLocalizeStringBy("key_1878")
		item.type = "silver"
		item.num = rewardNum*UserModel.getHeroLevel()
		item.desc = GetLocalizeStringBy("key_2889")
		item.name = item.desc .. item.num

	elseif(rewardType ==9) then
		-- itemName = GetLocalizeStringBy("key_1475")
		item.tid  = rewardType
		item.type = "soul"
		item.num = rewardNum*UserModel.getHeroLevel()
		item.desc = GetLocalizeStringBy("key_2889")
		item.name = item.desc .. item.num
	elseif(rewardType ==10) then
		item.type = "hero"
		-- item.tid = rewardNum
		 item.tid = rewardId
		item.num = rewardNum
		item.desc = DB_Heroes.getDataById(item.tid).name
		item.name = item.desc

	elseif(rewardType==11) then
		item.tid  = rewardType
		item.type = "jewel"
		item.num = rewardNum
		item.desc = GetLocalizeStringBy("key_1539")
		item.name = item.desc .. rewardNum

	elseif(rewardType ==12) then
		item.tid  = rewardType
			item.type = "prestige"
		item.num = rewardNum
		item.desc = GetLocalizeStringBy("key_2919")
		item.name = item.desc .. rewardNum

	elseif(rewardType ==13) then
		item.type = "hero"
		item.tid = rewardId
		item.num = rewardNum
		item.desc = DB_Heroes.getDataById(item.tid).name
		item.name = item.desc
		
	elseif(rewardType ==14) then
		item.tid = rewardId
		item.num = rewardNum
		item.type = "item"
		item.desc = ItemUtil.getItemById(tonumber(item.tid)).name 
		item.name = item.desc

	end

	return item
end

function makeBagLarger()
 	require "script/ui/bag/BagUtil"
	require "script/ui/bag/BagEnlargeDialog"
	BagEnlargeDialog.showLayer(BagUtil.PET_TYPE, nil)
end

function isPetBagFull()
	local isFull = false
	if DataCache.getSwitchNodeState(ksSwitchPet, false) then

		require "script/ui/pet/PetData"
		require "db/DB_Pet_cost"
		require "script/ui/tip/AlertTip"
		local baseFenseTable = DB_Pet_cost.getDataById(1)
		if tonumber(PetData.getPetNum()) >= tonumber(PetData.getOpenBagNum()) then
			isFull = true
			local tipText = GetLocalizeStringBy("key_2942") 
			AlertTip.showAlert(tipText, makeBagLarger, false, nil, GetLocalizeStringBy("key_2297"))
		end
	end
	return isFull
end


-- 通过宠物的模版ID， 获得天赋技能的信息
function getTalentSkillByTmpId(tmpId )
	local petData= DB_Pet.getDataById(tonumber(tmpId))

	local talentSkills = lua_string_split(petData.talentSkills , ",")
	local talentSkillsId= {}

	for i=1,table.count(talentSkills) do
		local skillId= lua_string_split(talentSkills[i], "|")
		talentSkillsId[i]= skillId[1]
	end

	return talentSkillsId
end

-- 通过宠物的模版ID，和等级获得宠物的可以吞噬的数量
function getCanSwallowNum(pet_tmpl, level )
	if( pet_tmpl == nil ) then
		return
	end
	local pet_tmpl = tonumber(pet_tmpl)
	local level = tonumber(level)

	local petData= DB_Pet.getDataById(pet_tmpl)
	local swallowPet= lua_string_split(petData.swallowPet, "," )
	local number =0 -- 可以吞噬的数量

	local maxSwalNum= table.count(swallowPet)
	for i=1, table.count(swallowPet) do
		local swallowArr= lua_string_split(swallowPet[i], "|")
		if(level <= tonumber(swallowArr[1])) then
			number= tonumber(swallowArr[2] )
			break
		end
	end

	-- if(level > )
	return number
end

-- 通过宠物的模版ID，获得所有可以领悟的普通技能
function getNorSkillByTmpl( pet_tmpl)

	local pet_tmpl = tonumber(pet_tmpl)

	local petData= DB_Pet.getDataById(pet_tmpl)
	local randSkills= lua_string_split(petData.randSkills, "," )

	local basicSkills= {}

	for i=1, #randSkills do
		local tempTable = getNormalSkill(tonumber(randSkills[i]), 1)
		tempTable.id = randSkills[i]
		table.insert(basicSkills, tempTable )
	end

	return basicSkills
end



-- 得到增加的宠物技能
function getAddSkillByTalentSkill(  skillTalent)
	local addSkill= {addNormalSkillLevel = 0, addSpecialSkillLevel=0 }

	local skillTalent = skillTalent or {}

	if(table.isEmpty(skillTalent) ) then
		return addSkill
	end

	for i=1, #skillTalent do
		local petSkill= tonumber(skillTalent[i].id)
		local skillData= DB_Pet_skill.getDataById(petSkill)
		if(skillData.addNormalSkillLevel ) then
				addSkill.addNormalSkillLevel= addSkill.addNormalSkillLevel+ tonumber(skillData.addNormalSkillLevel) 
		end

		if(skillData.addSpecialSkillLevel ) then
			addSkill.addSpecialSkillLevel= addSkill.addSpecialSkillLevel+ tonumber(skillData.addSpecialSkillLevel)
		end
	end

	return addSkill

end


-- 通过宠物的天赋技能得到,为李晨阳战斗中的所用,
function getPetValueByInfo( pPetInfo )
	
	local petProperty= {}

	if( table.isEmpty(pPetInfo) ) then
		return petProperty
	end
	local arrSkill = pPetInfo.arrSkill

	if( table.isEmpty(arrSkill) ) then
		return petProperty
	end

	local skillNormal = arrSkill.skillNormal
	local addNormalSkillLevel =  getAddSkillByTalentSkill(arrSkill.skillTalent).addNormalSkillLevel  --getAddSkillByTalent().addNormalSkillLevel

	-- 宠物进阶的技能等级加成
    local evolveAddSkillLv = 0
    if (pPetInfo) then
	    local evolveLv = tonumber(pPetInfo.evolveLevel) or 0
	    evolveAddSkillLv = PetData.getPetEvolveSkillLevel(pPetInfo,evolveLv)
    end
    print("PetUtil getPetValueByInfo evolveAddSkillLv => ",evolveAddSkillLv)

	local retTable= {}
	local tInfo = {}
	

	for i=1, table.count(skillNormal) do
		local skillId, level = tonumber(skillNormal[i].id), tonumber(skillNormal[i].level)+addNormalSkillLevel+evolveAddSkillLv

		if(skillId >0) then	
			local skillProperty= PetUtil.getNormalSkill(skillId, level ) 
			table.insert(tInfo , skillProperty)
		end
	end

	for i=1,#tInfo do
		for j=1,#tInfo[i] do
			local v = tInfo[i][j]
			if(retTable[tostring(v.affixDesc[1])] == nil) then
				retTable[tostring(v.affixDesc[1])] = v
			else
				retTable[tostring(v.affixDesc[1])].realNum = retTable[tostring(v.affixDesc[1])].realNum + v.realNum
				retTable[tostring(v.affixDesc[1])].displayNum = retTable[tostring(v.affixDesc[1])].displayNum + v.displayNum
			end
			-- if(retTable[] )
			
		end
	end

	for k,v in pairs( retTable) do
		local tempvalue = {}
		tempvalue.displayNum= v.displayNum
		tempvalue.id= v.affixDesc[1]
		tempvalue.desc= v.affixDesc[2]

		petProperty[tostring(tempvalue.id)] = tempvalue
		-- table.insert(petProperty, tempvalue)
	end
	return petProperty

end
--[[
    @des    :创建英雄信息面板
    @param  :
    @return :
--]]
function createHeroInfoPanel( ... )
	-- body
	local panel = HeroUtil.createNewAttrBgSprite(UserModel.getHeroLevel(), UserModel.getUserName(),UserModel.getVipLevel(),UserModel.getSilverNumber(), UserModel.getGoldNumber())
	return panel
end
--[[
    @des    :创建宠物属性信息面板
    @param  :
    @return :
--]]
function createPetAttrInfoPanel( pPetInfo,pColor,pLv,pLvColor )
	-- body
	-- 背景
	local petAttrData = PetData.getPetEvolveAttrByLv(pPetInfo,pLv)
	-- print("petAttrData")
	-- print_t(petAttrData)
	local areaBg = CCScale9Sprite:create("images/god_weapon/attr_bg.png")
	local attrNum = table.count(petAttrData)
	local fontSize = 24
	local width = 180
	local height = 164
	areaBg:setContentSize(CCSizeMake(width,height))
	-- 标题背景
    local aptitudeTitleSp = CCSprite:create("images/common/red_2.png")
    aptitudeTitleSp:setAnchorPoint(ccp(0.5,1))
    aptitudeTitleSp:setPosition(ccp(areaBg:getContentSize().width*0.5,areaBg:getContentSize().height))
    areaBg:addChild(aptitudeTitleSp)
  	local nameLabel= CCRenderLabel:create(pPetInfo.petDesc.roleName,g_sFontPangWa,fontSize,1,ccc3(0,0,0),type_stroke )
    nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(pPetInfo.petDesc.quality))
    nameLabel:setAnchorPoint(ccp(0.5,0))
    nameLabel:setPosition(ccpsprite(0.45,0,aptitudeTitleSp))
    aptitudeTitleSp:addChild(nameLabel)
    local advanceLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",pLv),g_sFontPangWa,fontSize - 2,1,ccc3(0,0,0),type_stroke )
    advanceLvLabel:setColor(pLvColor)
    advanceLvLabel:setAnchorPoint(ccp(0,0.5))
    advanceLvLabel:setPosition(ccpsprite(1.1,0.5,nameLabel))
    nameLabel:addChild(advanceLvLabel)
	for i,attrData in ipairs(petAttrData) do
		-- 属性名称文本
		local attrNameLabel = CCRenderLabel:create(attrData.affixDesc.sigleName.."：",g_sFontName,fontSize,1,ccc3(0x00,0x00,0x00),type_shadow)
		attrNameLabel:setPosition(ccp(30,height - 10 - i * fontSize))
		areaBg:addChild(attrNameLabel)
		-- 属性数目文本
		local attrNumLabel = CCRenderLabel:create("+"..attrData.displayNum,g_sFontName,fontSize,1,ccc3(0x00,0x00,0x00),type_shadow)
		attrNumLabel:setColor(pColor)
		attrNumLabel:setAnchorPoint(ccp(0,0.5))
		attrNumLabel:setPosition(ccpsprite(1,0.5,attrNameLabel))
		attrNameLabel:addChild(attrNumLabel)
	end
	-- 技能等级加成
	-- 背景
	local lvBg = CCSprite:create("images/pet/evolve/lv_bg.png")
	lvBg:setAnchorPoint(ccp(0.5,1))
	lvBg:setPosition(ccpsprite(0.5,0.2,areaBg))
	areaBg:addChild(lvBg)
	local lvLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1084").."：",g_sFontName,fontSize,1,ccc3(0x00,0x00,0x00),type_shadow)
	lvLabel:setAnchorPoint(ccp(0,0.5))
	lvLabel:setPosition(ccp(30,lvBg:getPositionY() - lvBg:getContentSize().height / 2))
	areaBg:addChild(lvLabel)
	local skillLvNum = PetData.getPetEvolveSkillLevel(pPetInfo,pLv)
	local lvValueLabel = CCRenderLabel:create("+"..skillLvNum,g_sFontName,fontSize,1,ccc3(0x00,0x00,0x00),type_shadow)
	lvValueLabel:setAnchorPoint(ccp(0,0.5))
	lvValueLabel:setColor(pColor)
	lvValueLabel:setPosition(ccpsprite(1,0.5,lvLabel))
	lvLabel:addChild(lvValueLabel)
	return areaBg
end
--[[
    @des    :根据宠物数据生成宠物Sp
    @param  :
    @return :
--]]
function createPetSpByPetInfo( pPetInfo )
	-- body
	local petTid = nil 
    local petDb = nil
    if(pPetInfo.petDesc) then 
        petTid= pPetInfo.petDesc.id
        petDb = DB_Pet.getDataById(petTid)
    end
    local showStatus=  pPetInfo.showStatus
    local slotIndex= i
    -- local offsetY = 0
    -- if petDb ~= nil then
    --     offsetY = petDb.Offset or 0
    -- end
    return getPetIMGById(petTid ,showStatus, slotIndex)
end
--[[
    @des    :获取宠物进阶培养资质互换等层的尺寸
    @param  :
    @return :
--]]
function getPetLayerSize( ... )
	-- body
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
	local layerSize = CCSizeMake(0,0)
	layerSize.width= g_winSize.width 
	layerSize.height = g_winSize.height - (bulletinLayerSize.height + menuLayerSize.height) * g_fScaleX
	return layerSize
end











