-- Filename：	FashionLayer.lua
-- Author：		Li Pan
-- Date：		2014-2-11
-- Purpose：		时装

module("FashionLayer", package.seeall)

require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/utils/BaseUI"

require "script/ui/fashion/FashionData"
require "script/ui/fashion/FashionNet"

require "script/model/utils/ActivityConfig"
require "script/model/utils/HeroUtil"

--图片路径
local iPath = nil

local baseLayer = nil
local _shouldStopBgm = false

local _isInFormation = false

function setMark( p_isInFormation )
	_isInFormation = p_isInFormation
end

function getMark()
	return _isInFormation
end


function createFashion( ... )

	_isInFormation = false

	iPath = "images/fashion/"
	baseLayer = CCLayer:create()
	baseLayer:registerScriptHandler(onNodeEvent)

	local downMenuSize = MenuLayer.getLayerFactSize()
--创建背景
 	local fashionBg = CCSprite:create(iPath.."fashion_bg.jpg")
    baseLayer:addChild(fashionBg)
    fashionBg:setAnchorPoint(ccp(0.5, 0.5))
    fashionBg:setPosition(ccp(g_winSize.width/2, g_winSize.height/2 + 90*g_fElementScaleRatio))
	fashionBg:setScale(g_fBgScaleRatio)

--创建顶部
    createTopUI()

   -- 返回
	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
    backItem:registerScriptTapHandler(closeSelf)
    backItem:setScale(g_fElementScaleRatio)
    local backMenu = CCMenu:createWithItem(backItem)
    baseLayer:addChild(backMenu)
    backMenu:setPosition(ccp(g_winSize.width - backItem:getContentSize().width*g_fElementScaleRatio*1.5, g_winSize.height - BulletinLayer.getLayerHeight()*g_fScaleX - baseLayer:getChildByTag(19876):getContentSize().height*baseLayer:getChildByTag(19876):getScale() - backItem:getContentSize().height*g_fElementScaleRatio*1.5))


-- 时装屋
	local dressRoomBtn = CCMenuItemImage:create("images/dress_room/dress_room_n.png", "images/dress_room/dress_room_h.png")
	backMenu:addChild(dressRoomBtn)
    dressRoomBtn:registerScriptTapHandler(dressRoomCallback)
    dressRoomBtn:setScale(g_fElementScaleRatio)
    dressRoomBtn:setPosition(ccp(backItem:getPositionX() - 90 * g_fElementScaleRatio, backItem:getPositionY()))

-- 时装图鉴
	local fashionSuitBtn = CCMenuItemImage:create("images/fashion/fashionsuit/suit_n.png", "images/fashion/fashionsuit/suit_h.png")
	backMenu:addChild(fashionSuitBtn)
    fashionSuitBtn:registerScriptTapHandler(fashionSuitBtnCallback)
    fashionSuitBtn:setScale(g_fElementScaleRatio)
    fashionSuitBtn:setPosition(ccp(dressRoomBtn:getPositionX() - 90 * g_fElementScaleRatio, dressRoomBtn:getPositionY()))

--属性
    createPro()

	return baseLayer
end

function dressRoomCallback()
 	_shouldStopBgm = false
	require "script/ui/dressRoom/DressRoomLayer"
	DressRoomLayer.show()
end

function cleanSelf( ... )
	iPath = nil
	baseLayer:removeFromParentAndCleanup(true)
	baseLayer = nil
end

function closeSelf( ... )
	cleanSelf()

	local mark = getMark()
	print("mark",mark)
	if(mark == true)then
		require "script/ui/formation/FormationLayer"
        local formationLayer = FormationLayer.createLayer()
        MainScene.changeLayer(formationLayer, "formationLayer")
	else
		require "script/ui/hero/HeroLayer"
		MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
	end
end

-- 刷新全部ui
function refreshAll( ... )
	require "script/ui/fashion/FashionLayer"
	local mark = FashionLayer.getMark()
	local fashionLayer = FashionLayer:createFashion()
	MainScene.changeLayer(fashionLayer, "FashionLayer")		
	FashionLayer.setMark(mark)
end

--时装属性
function createPro( ... )
--数据位置
	require "script/model/hero/HeroModel"
	local fashionInfo = HeroModel.getNecessaryHero().equip.dress
	print("the fashionInfo is .. ")

	print_t(fashionInfo)
	-- print("the fashionInfo is .. ", fashionInfo["1"])

--时装的htid
	local dressHtid = nil
	local dressItem_id = nil
	local dressLevel = 0
	print("The dressHtid is ",dressHtid)
	local isDress = true
	if(table.count(fashionInfo) == 0 or tonumber(fashionInfo["1"]) == 0) then
		isDress = false	
		dressHtid = 0
		-- print("?????????????___________")
		-- print_t(fashionInfo)
	else
		dressHtid = fashionInfo["1"].item_template_id
		-- print("?????????????")
		-- print_t(fashionInfo)
		dressItem_id = fashionInfo["1"].item_id
		dressLevel = fashionInfo["1"].va_item_text.dressLevel
	end
	print("the isDress is ><>>",isDress)

	local downMenuSize = MenuLayer.getLayerFactSize()

	local _bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
	_bottomBg:setContentSize(CCSizeMake(633,138))
	_bottomBg:setScale(g_fScaleX)
	_bottomBg:setPosition(baseLayer:getContentSize().width/2, 25*MainScene.elementScale + downMenuSize.height)
	_bottomBg:setAnchorPoint(ccp(0.5,0))
	baseLayer:addChild(_bottomBg,11)

	-- 创建天命属性sprite
	local destinyLabelBg= CCScale9Sprite:create("images/common/astro_labelbg.png")
	destinyLabelBg:setContentSize(CCSizeMake(183,40))
	destinyLabelBg:setAnchorPoint(ccp(0.5,0.5))
	destinyLabelBg:setPosition(_bottomBg:getContentSize().width/2, _bottomBg:getContentSize().height)
	_bottomBg:addChild(destinyLabelBg)

	--	local destinyLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2123"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local destinyLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1385"), g_sFontPangWa, 24)
	destinyLabel:setColor(ccc3(0xff,0xf6,0x00))
	destinyLabel:setPosition(destinyLabelBg:getContentSize().width/2, destinyLabelBg:getContentSize().height/2)
	destinyLabel:setAnchorPoint(ccp(0.5,0.5))
	destinyLabelBg:addChild(destinyLabel)

	-- 统帅
	local captionSp = CCSprite:create("images/common/caption.png")
	captionSp:setPosition(_bottomBg:getContentSize().width*0.05, _bottomBg:getContentSize().height*0.6812)
	_bottomBg:addChild(captionSp)

	-- 记录统帅的值，若升级时不变， 则不变化
	_captionNum = getDressData(dressHtid, 6,dressItem_id) 
	_captionLabel= CCLabelTTF:create(_captionNum, g_sFontPangWa, 23)
	_captionLabel:setColor(ccc3(0x70,0xff,0x18))
	_captionLabel:setPosition(_bottomBg:getContentSize().width*0.172 ,_bottomBg:getContentSize().height*0.6812)
	_captionLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_captionLabel)

	-- 武力
	local forceSp = CCSprite:create("images/common/force.png")
	forceSp:setPosition(_bottomBg:getContentSize().width*0.05, _bottomBg:getContentSize().height*0.413)
	_bottomBg:addChild(forceSp)

	_forceNum = getDressData(dressHtid, 7,dressItem_id)
	_forceLabel= CCLabelTTF:create(_forceNum, g_sFontPangWa, 23)
	_forceLabel:setColor(ccc3(0xff,0x17,0x0c))
	_forceLabel:setPosition(_bottomBg:getContentSize().width*0.172 ,_bottomBg:getContentSize().height*0.413)
	_forceLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_forceLabel)

	-- 智力
	local intelligenceSp= CCSprite:create("images/common/intelligence.png")
	intelligenceSp:setPosition(_bottomBg:getContentSize().width*0.05, _bottomBg:getContentSize().height*0.145)
	_bottomBg:addChild(intelligenceSp)
	
	_intelligenceNum = getDressData(dressHtid, 8,dressItem_id)
	_intelligenceLabel= CCLabelTTF:create(_intelligenceNum, g_sFontPangWa, 23)
	_intelligenceLabel:setColor(ccc3(0xf9,0x59,0xff))
	_intelligenceLabel:setPosition(_bottomBg:getContentSize().width*0.172 ,_bottomBg:getContentSize().height*0.145)
	_intelligenceLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_intelligenceLabel)

	-- 攻击
	local attTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1727"),g_sFontName, 23)
	attTitleLabel:setColor(ccc3(0xff,0xff,0xff))
	attTitleLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.415,_bottomBg:getContentSize().height*0.514 ))
	attTitleLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(attTitleLabel)

	_attNum = getDressData(dressHtid, 9,dressItem_id)
	_attLabel= CCLabelTTF:create(_attNum, g_sFontName, 23)
	_attLabel:setColor(ccc3(0x70,0xff,0x18))
	_attLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.52,_bottomBg:getContentSize().height*0.514 ))
	_attLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_attLabel)

	-- 生命
	--	local lifeTitleLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2075"),g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local lifeTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2075"),g_sFontName, 23)
	lifeTitleLabel:setColor(ccc3(0xff,0xff,0xff))
	lifeTitleLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.702,_bottomBg:getContentSize().height*0.514 ))
	lifeTitleLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(lifeTitleLabel)

	_lifeNum = getDressData(dressHtid, 1,dressItem_id)
	_lifeLabel= CCLabelTTF:create(_lifeNum, g_sFontName, 23)
	_lifeLabel:setColor(ccc3(0x70,0xff,0x18))
	_lifeLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.815,_bottomBg:getContentSize().height*0.514 ))
	_lifeLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_lifeLabel)

	-- 物防
	--	local phyDefTitleLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2804"),g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local phyDefTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2804"),g_sFontName, 23)
	phyDefTitleLabel:setColor(ccc3(0xff,0xff,0xff))
	phyDefTitleLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.415,_bottomBg:getContentSize().height*0.251 ))
	phyDefTitleLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(phyDefTitleLabel)

	_phyDefNum = getDressData(dressHtid, 4,dressItem_id)
	_phyDefLabel= CCLabelTTF:create(_phyDefNum, g_sFontName, 23)
	_phyDefLabel:setColor(ccc3(0x70,0xff,0x18))
	_phyDefLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.52,_bottomBg:getContentSize().height*0.251 ))
	_phyDefLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_phyDefLabel)

	-- 法防
	--	local magDefTitleLabel= CCRenderLabel:create(GetLocalizeStringBy("key_1731"),g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local magDefTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1731"),g_sFontName, 23)
	magDefTitleLabel:setColor(ccc3(0xff,0xff,0xff))
	magDefTitleLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.702,_bottomBg:getContentSize().height*0.251 ))
	magDefTitleLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(magDefTitleLabel)

	_magDefNum = getDressData(dressHtid, 5,dressItem_id)
	_magDefLabel= CCLabelTTF:create(_magDefNum, g_sFontName, 23)
	_magDefLabel:setColor(ccc3(0x70,0xff,0x18))
	_magDefLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.815,_bottomBg:getContentSize().height*0.251 ))
	_magDefLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_magDefLabel)

-- 判断有木有时装
	local iconName = nil
	if UserModel.getDressIdByPos(1) == nil then
		local oldhtid = UserModel.getAvatarHtid()
		local heroLocalInfo = DB_Heroes.getDataById(tonumber(oldhtid))
		iconName = "images/base/hero/body_img/" .. heroLocalInfo.body_img_id
	else
		require "script/model/utils/HeroUtil"
		iconName = HeroUtil.getHeroBodyImgByHTID(UserModel.getAvatarHtid(), UserModel.getDressIdByPos(1) ,UserModel.getUserSex())

		-- local heroBodyIcon = getIconPath(dressHtid, "changeModel")
		-- print("the heroBodyIcon is ",heroBodyIcon)
		-- require "db/DB_Heroes"
  --       heroBodyIcon = DB_Heroes.getDataById(heroBodyIcon).body_img_id
		-- print("the heroBodyIcon is ",heroBodyIcon)
		-- iconName = "images/base/fashion/body_img/" .. heroBodyIcon
	end
	local heroImg = CCSprite:create(iconName)
	baseLayer:addChild(heroImg, 2)
	heroImg:setAnchorPoint(ccp(0.5, 0.5))
	heroImg:setPosition(ccp(g_winSize.width/2, g_winSize.height/2 + 50*g_fElementScaleRatio))
	heroImg:setScale(g_fElementScaleRatio)

--名字背景
--[[
	if(isDress) then
		local fullRect = CCRectMake(0, 0, 111, 32)
	    local insetRect = CCRectMake(40, 15, 1, 1)
	    local nameBg = CCScale9Sprite:create("images/boss/boss_name_bg.png", fullRect, insetRect)
	    nameBg:setPreferredSize(CCSizeMake(400, 60))
	    nameBg:setAnchorPoint(ccp(0.5, 0))
	    nameBg:setScale(g_fElementScaleRatio)
	    nameBg:setPosition(ccp(g_winSize.width/2, 25*MainScene.elementScale*g_fElementScaleRatio + downMenuSize.height + _bottomBg:getContentSize().height*g_fElementScaleRatio + destinyLabelBg:getContentSize().height/2*g_fElementScaleRatio + 5*g_fElementScaleRatio))
	    -- 350*g_fElementScaleRatio))
	    baseLayer:addChild(nameBg, 1)	
	    --名字
	    local quality = DB_Item_dress.getDataById(dressHtid).quality
    	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	    local dressName = getIconPath(dressHtid, "name")
	    local nameLabel = CCRenderLabel:create(dressName, g_sFontPangWa, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(nameColor)
	    -- nameLabel:setColor(ccc3( 0xff, 0xff, 0xff))

	    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	    nameLabel:setPosition(ccp(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2))
	    nameBg:addChild(nameLabel)    
	end
    ]]
-- 时装按钮
	local fashionItem = CCMenuItemImage:create("images/common/t_equipborder.png", "images/common/t_equipborder.png")
    fashionItem:registerScriptTapHandler(showFashionInfo)
    fashionItem:setScale(g_fElementScaleRatio)
    local fashionMenu = CCMenu:createWithItem(fashionItem)
    baseLayer:addChild(fashionMenu, 3)
	-- fashionMenu:setPosition(ccp(500*g_fElementScaleRatio, 350*g_fElementScaleRatio))
    fashionMenu:setPosition(ccp(g_winSize.width - fashionItem:getContentSize().width*g_fElementScaleRatio*1.3, 400*g_fElementScaleRatio))

    local iconBg = nil
-- 时装icon，没有用加号
	local icon = nil
	if(not isDress) then
		iconBg = CCSprite:create("images/common/border.png")

		icon = CCSprite:create("images/common/add_new.png")
		fashionItem:setTag(0)
	else
		-- local quality = DB_Item_dress.getDataById(dressHtid).quality
		-- iconBg = CCSprite:create("images/base/potential/props_"..quality..".png")

		-- --htid
		-- local heroBodyIcon = getIconPath(dressHtid, "icon_small")
		-- iconName = "images/base/fashion/small/" .. heroBodyIcon
		-- icon = CCSprite:create(iconName)
		-- fashionItem:setTag(1)

		-- 修改by licong
		iconBg = CCSprite:create("images/common/border.png")
		iconBg:setVisible(false)
		require "script/ui/item/ItemSprite"
		icon = ItemSprite.getItemSpriteByItemId(dressHtid)
		fashionItem:setTag(1)
	end
	fashionItem:addChild(iconBg)
	iconBg:setAnchorPoint(ccp(0.5, 0.5))
	iconBg:setPosition(ccp(fashionItem:getContentSize().width/2, fashionItem:getContentSize().height/2))

	fashionItem:addChild(icon, 3)
	icon:setPosition(ccp(fashionItem:getContentSize().width/2, fashionItem:getContentSize().height/2))
	icon:setAnchorPoint(ccp(0.5, 0.5))
	if(not isDress) then
		local arrActions_2 = CCArray:create()
		arrActions_2:addObject(CCFadeOut:create(1))
		arrActions_2:addObject(CCFadeIn:create(1))
		local sequence_2 = CCSequence:create(arrActions_2)
		local action_2 = CCRepeatForever:create(sequence_2)
		icon:runAction(action_2)
	else
		local quality = DB_Item_dress.getDataById(dressHtid).quality
    	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	    local dressName = getIconPath(dressHtid, "name")
	    local nameLabel = CCRenderLabel:create(dressName, g_sFontPangWa, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(nameColor)
	    -- nameLabel:setColor(ccc3( 0xff, 0xff, 0xff))

	    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	    nameLabel:setPosition(ccp(fashionItem:getContentSize().width/2, - 20))
	    fashionItem:addChild(nameLabel) 
	   	
	   	-- 时装等级
		local levelLabel = CCLabelTTF:create("+" .. dressLevel, g_sFontPangWa, 25)
		levelLabel:setColor(ccc3(0x70,0xff,0x18))
		levelLabel:setAnchorPoint(ccp(0.5, 0.5))
		levelLabel:setPosition(ccp(fashionItem:getContentSize().width/2,-50))
		fashionItem:addChild(levelLabel)   
	end

---------------------------------------------------------------------------------------------------------------------------
-- 技能按钮
-- add by DJN 2014/08/21
	local skillItem = CCMenuItemImage:create("images/common/t_equipborder.png", "images/common/t_equipborder.png")
    skillItem:registerScriptTapHandler(showSkillInfo)
    skillItem:setScale(g_fElementScaleRatio)
    local skillMenu = CCMenu:createWithItem(skillItem)
    baseLayer:addChild(skillMenu, 3)
  
    skillMenu:setPosition(ccp(40*g_fElementScaleRatio, 400*g_fElementScaleRatio))
    require "script/ui/replaceSkill/ReplaceSkillData"
    require "script/ui/replaceSkill/ReplaceSkillLayer"
    require "db/DB_Heroes"
    require "db/skill"
     
	local rageSkill,fromType = UserModel.getUserRageSkill()  --技能id
	--当前技能的图标
	-- if(tonumber(fromType) ~= 2)then
	local iconSprite = ReplaceSkillData.createSkillIcon(rageSkill)
	skillItem:addChild(iconSprite,3)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(skillItem:getContentSize().width/2, skillItem:getContentSize().height/2))
 --    end
	--技能名称
	--技能名称的颜色和时装的名称的颜色相同，如果当前没有时装，默认技能名称为紫色
	local nameColor = nil
	if(dressHtid ~= 0)then
		require "db/DB_Item_dress"
		local quality = DB_Item_dress.getDataById(dressHtid).quality
		nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	else
		nameColor = ccc3(0xe4,0x00,0xff)
	end
    local nameStr = skill.getDataById(rageSkill).name 
    local nameLabel  = CCRenderLabel:create(nameStr,g_sFontPangWa,25,2,ccc3(0x00,0x00,0x00),type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setPosition(ccp(skillItem:getContentSize().width/2,-4))
    skillItem:addChild(nameLabel)
    --等级
    --if tonumber(ReplaceSkillData.getChangeSkillInfo()) ~= 0 then
    if(tonumber(fromType) == 1 )then
    	--装备的别人的技能有等级，自己的技能没有等级，来自星魂的技能也没有等级
	    local lvImage = CCSprite:create("images/common/lv.png")
	    lvImage:setAnchorPoint(ccp(1,0))
	    lvImage:setPosition(ccp(skillItem:getContentSize().width/2+1,-60))
	    skillItem:addChild(lvImage)

	    local allInfo = ReplaceSkillData.getAllInfo().star_list
	    local curStar = ReplaceSkillData.getAllInfo().va_act_info.skill
	    local skillList = ReplaceSkillData.getSkillInfoBySid(curStar)
	    local skillInfo = ReplaceSkillData.getSkillById(skillList,allInfo[curStar].feel_skill)
	    local levelStr = skillInfo.skillLevel

	    local levelLabel = CCRenderLabel:create(levelStr,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	    levelLabel:setColor(ccc3(0xff,0xf6,0x00))
	    levelLabel:setAnchorPoint(ccp(0,0))
	    levelLabel:setPosition(ccp(skillItem:getContentSize().width/2+3,-60))
	    skillItem:addChild(levelLabel)
    end

-------------------------------------------------------------------------------------------------------------------------

    -- 时装字


	 -- local fashionLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2020"), g_sFontPangWa, 23, 1.5, ccc3(0, 0, 0), type_stroke)
	 --    fashionLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	 --    fashionLabel:setPosition(ccp(fashionItem:getContentSize().width/2, - 20))
	 --    fashionLabel:setAnchorPoint(ccp(0.5, 0.5))
	 --    fashionItem:addChild(fashionLabel)
end

function showFashionInfo(tag, sender)
	_shouldStopBgm = false
	print("showFashionInfo")
	if(tag == 0) then
		require "script/ui/fashion/ChangeFashion"
		local changeLayer = ChangeFashion.create()
		MainScene.changeLayer(changeLayer, "changeLayer")
	else
		require "script/ui/fashion/FashionInfo"

		local fashionInfo = HeroModel.getNecessaryHero().equip.dress
		local dressHtid = fashionInfo["1"].item_template_id
--时装的htid
		FashionInfo.create(dressHtid,tonumber(fashionInfo["1"].item_id),true,true,refreshAll)
	end
end

--根据男女不同得到不同的路径时装
function getIconPath(htid, path)
	local localData = DB_Item_dress.getDataById(htid)
	print_t(localData)
	print("the paht is "..path)
	local dataArray = localData[path]
	print_t(dataArray)

	local prosArray = lua_string_split(dataArray, ",")

	local oldhtid = UserModel.getAvatarHtid()
	local model_id = DB_Heroes.getDataById(tonumber(oldhtid)).model_id
	-- print("the model_id is"..model_id)

	local content = nil
    for k,v in pairs(prosArray) do
    	local array = lua_string_split(v, "|")
    	-- print("the array is")
    	-- print_t(array)
    	if(tonumber(array[1]) == tonumber(model_id)) then
			content = array[2]
			break
    	end
    end
	return content
end

function getDressData(htid, pro, item_id)
	-- 统帅 = 6，武力 = 7， 智力 = 8， 攻击 = 9，物防 = 4， 生命 = 1， 法防 = 5
	  -- 获得相关数值
 	local descString = "+0" --GetLocalizeStringBy("key_2137") .. enhanceLv .. "\n"
 	if(htid == 0) then
 		return descString
 	end
 	local itemData = nil
	if(item_id)then
		itemData = ItemUtil.getItemInfoByItemId(item_id)
		--print("itemData----1 ")
 		--print_t(itemData)
		if( itemData == nil )then
			-- 背包中没有 检查英雄身上
			itemData = ItemUtil.getFashionFromHeroByItemId(item_id)
			if( not table.isEmpty(itemData))then
				require "db/DB_Item_dress"
				itemData.itemDesc = DB_Item_arm.getDataById(itemData.item_template_id)
			end
			-- print("itemData----2 ")
 			-- print_t(itemData)
		end
 	end
 	print("htid ",htid, "pro ",pro, "item_id ",item_id )
 	print("itemData----3 ")
 	print_t(itemData)
	require "db/DB_Item_dress"
	local localData = DB_Item_dress.getDataById(htid)
	local monsterIds = {}
	if( itemData )then
		monsterIds = FashionData.getAttrByItemData(itemData,itemData.va_item_text.dressLevel)
	else
		monsterIds = FashionData.getAttrByItemData(localData,0)
	end
	-- print("the monsterIds is ")
	print_t(monsterIds)
	for k,v in pairs(monsterIds) do
		if(tonumber(k) == pro) then
			descString = "+".. v.displayNum
			break
		end
	end
	return descString
end

--添加属性
function addPro(htid, subDress,item_id, subDressData)
	local t_text = {}
	local itemData = nil
	if(item_id)then
		itemData = ItemUtil.getItemInfoByItemId(item_id)
		if( itemData == nil )then
			-- 背包中没有 检查英雄身上
			itemData = ItemUtil.getFashionFromHeroByItemId(item_id)
			if( not table.isEmpty(itemData))then
				require "db/DB_Item_dress"
				itemData.itemDesc = DB_Item_arm.getDataById(itemData.item_template_id)
			end
		end
 	end
 	if(subDressData)then
 		itemData = subDressData
 	end
 	print("htid ",htid, "pro ",pro, "item_id ",item_id )
 	print("itemData---- ")
 	print_t(itemData)
	require "db/DB_Item_dress"
	local localData = DB_Item_dress.getDataById(htid)
	local monsterIds = {}
	if( itemData )then
		monsterIds = FashionData.getAttrByItemData(itemData,itemData.va_item_text.dressLevel)
	else
		monsterIds = FashionData.getAttrByItemData(localData,0)
	end
	-- print("the monsterIds is ")
	print_t(monsterIds)
	for k,v in pairs(monsterIds) do
		local displayNum = 0
		if(subDress) then
    		displayNum = - tonumber(v.displayNum)
    	else
    		displayNum = tonumber(v.displayNum)
    	end
		local o_text = {}
        o_text.txt = v.desc.displayName
		o_text.num = displayNum
		table.insert(t_text, o_text)
	end
	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(t_text)
end


function createTopUI( )
	require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
	------------------------------------change by DJN 2014/11/13 新改版，用zihang封装的方法创建
    local _topBg = HeroUtil.createNewAttrBgSprite(userInfo.level,UserModel.getUserName(),UserModel.getVipLevel(),userInfo.silver_num,userInfo.gold_num)
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0, baseLayer:getContentSize().height - BulletinLayer.getLayerHeight()*g_fScaleX)
    _topBg:setScale(g_fScaleX)
    baseLayer:addChild(_topBg, 1, 19876)
	return _topBg
	-- local _topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
 --    _topBg:setAnchorPoint(ccp(0,1))
 --    _topBg:setPosition(0, baseLayer:getContentSize().height - BulletinLayer.getLayerHeight()*g_fScaleX)
 --    _topBg:setScale(g_fScaleX)
 --    baseLayer:addChild(_topBg, 1, 19876)

 --    titleSize = _topBg:getContentSize()

 --    local lvSp = CCSprite:create("images/common/lv.png")
 --    lvSp:setAnchorPoint(ccp(0.5,0.5))
 --    lvSp:setPosition(_topBg:getContentSize().width*0.08, _topBg:getContentSize().height*0.43)
 --    _topBg:addChild(lvSp)
    
	--  lvLabel = CCRenderLabel:create( userInfo.level , g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	--local lvLabel = CCLabelTTF:create(userInfo.level, g_sFontName, 23)
    -- lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    -- lvLabel:setAnchorPoint(ccp(0.5,0.5))
    -- lvLabel:setPosition(_topBg:getContentSize().width*0.08+lvSp:getContentSize().width ,_topBg:getContentSize().height*0.43)
    -- _topBg:addChild(lvLabel)

	--   local nameLabel= CCRenderLabel:create( UserModel.getUserName(), g_sFontName, 23, 1,ccc3(0,0,0), type_stroke)
	--local nameLabel= CCLabelTTF:create(UserModel.getUserName(), g_sFontName, 23)
    -- nameLabel:setPosition(_topBg:getContentSize().width*0.18, _topBg:getContentSize().height*0.43)
    -- nameLabel:setAnchorPoint(ccp(0,0.5))
    -- nameLabel:setColor(ccc3(0x70,0xff,0x18))
    -- _topBg:addChild(nameLabel)

 --    local vipSp = CCSprite:create ("images/common/vip.png")
	-- vipSp:setPosition(_topBg:getContentSize().width*0.372, _topBg:getContentSize().height*0.43)
	-- vipSp:setAnchorPoint(ccp(0,0.5))
	-- _topBg:addChild(vipSp)

    -- VIP对应级别
    --require "script/libs/LuaCC"
   -- local vipNumSp = LuaCC.createSpriteOfNumbers("images/main/vip", UserModel.getVipLevel() , 23)
    -- vipNumSp:setPosition(_topBg:getContentSize().width*0.382+vipSp:getContentSize().width, _topBg:getContentSize().height*0.43)
    -- vipNumSp:setAnchorPoint(ccp(0,0.5))
    -- _topBg:addChild(vipNumSp)
    
   -- _silverLabel = CCLabelTTF:create( userInfo.silver_num,g_sFontName,18)
    -- _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    -- _silverLabel:setAnchorPoint(ccp(0,0.5))
    -- _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    -- _topBg:addChild(_silverLabel)
    
    --_goldLabel = CCLabelTTF:create( userInfo.gold_num,g_sFontName,18)
    -- _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    -- _goldLabel:setAnchorPoint(ccp(0,0.5))
    -- _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    -- _topBg:addChild(_goldLabel)
    
    ---------------------------------------------------------------------------------------
end
--add by DJN
--技能图标按钮的回调，用于跳转到技能更换界面
function showSkillInfo( ... )
	_shouldStopBgm = false
	require "script/ui/replaceSkill/EquipmentLayer"
	local closeCb = function ( ... )
		MainScene.getAvatarLayerObj():setVisible(false)
        local mark = FashionLayer.getMark()
        local fashionLayer = FashionLayer:createFashion()
        MainScene.changeLayer(fashionLayer, "FashionLayer")     
        FashionLayer.setMark(mark)
	end
	EquipmentLayer.showLayer(closeCb)	
end

function onNodeEvent( event )
	if event == "enter" then
		playBgm()
	elseif event == "exit" then
		if _shouldStopBgm == true then
			stopBgm()
		end
		_shouldStopBgm = true
	end
end

function playBgm( ... )
	local bgmFile = "audio/bgm/music16.mp3"
	if AudioUtil.getBgmFile() ~= bgmFile then
		AudioUtil.playBgm(bgmFile)
	end
end

function stopBgm( ... )
	local bgmFile = "audio/bgm/music09.mp3"
	if bgmFile ~= AudioUtil.getBgmFile() then
		AudioUtil.playBgm(bgmFile)
	end
end

--[[
	@des 	: 时装套装回调
	@param 	: 
	@return :
--]]
function fashionSuitBtnCallback( ... )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    _shouldStopBgm = false
    
	require "script/ui/fashion/fashionsuit/FashionSuitLayer"
	FashionSuitLayer.showLayer()
end
