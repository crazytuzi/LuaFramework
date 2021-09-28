-- FileName: SoulInfoLayer.lua 
-- Author: Zhang zihang
-- Date: 14-2-17 
-- Purpose: 战魂信息面板

module("SoulInfoLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/ui/item/ItemUtil"
require "script/ui/item/ItemSprite"
require "script/ui/huntSoul/HuntSoulData"
require "script/utils/BaseUI"
require "script/model/DataCache"

local _bgLayer
local myScale
local spriteBg

local _itemTempId
local _itemId
local _priority
local _zOrder
local _isChange
local _huntData
local _attributeData
local _h_id 
local _h_pos
local _soulInfo  --对方阵容传过来的战魂信息
local _callFun 	= nil
local _isOnHero = false
local _userLv 	= nil

function init()
	_bgLayer = nil
	myScale = nil
	spriteBg = nil
	_itemTempId = nil
	_itemId = nil
	_priority = nil
	_zOrder = nil
	_isChange = nil
	_huntData = {}
	_attributeData = {}
	_h_id = nil
	_h_pos = nil
	_soulInfo = nil
	_callFun 	= nil
	_isOnHero = false
	_userLv 	= nil
end

-- 星星 最多6星
function getStarByQuality( num )
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(30*tonumber(num),32))
	for i=1,num do
		local sprite = CCSprite:create("images/common/star.png")
		sprite:setAnchorPoint(ccp(0,0))
		sprite:setPosition(ccp((i-1)*(sprite:getContentSize().width+3),0))
		node:addChild(sprite)
	end
	return node
end

--[[
	@des 	: 进阶回调
	@param 	: 
	@return :
--]]
function developButtonCallBack( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 橙色进阶需要人物等级
	if( tonumber(_huntData.itemDesc.quality) >= 6 )then
		local needLv = HuntSoulData.getDevelopRedNeedLv()
		if( UserModel.getHeroLevel() < needLv )then
			require "script/ui/tip/AnimationTip"
	        AnimationTip.showTip(GetLocalizeStringBy("lic_1830",needLv))
			return
		end
	end

	closeAction()

	require "script/ui/huntSoul/developSoul/DevelopSoulLayer"
	DevelopSoulLayer.showLayer(_itemId)
	if( _isChange )then 
		DevelopSoulLayer.setLayerMark(DevelopSoulLayer.kTagFormation)
	else
		DevelopSoulLayer.setLayerMark(DevelopSoulLayer.kTagBag)
	end
end

--[[
	@des 	: 精炼回调
	@param 	: 
	@return :
--]]
function evolveButtonCallBack( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	closeAction()

	require "script/ui/huntSoul/evolveSoul/EvolveSoulLayer"
	EvolveSoulLayer.showLayer(_itemId)
	if( _isChange )then 
		EvolveSoulLayer.setLayerMark(EvolveSoulLayer.kTagFormation)
	else
		EvolveSoulLayer.setLayerMark(EvolveSoulLayer.kTagBag)
	end
end

--[[
	@des 	: 重铸回调
	@param 	: 
	@return :
--]]
function recastButtonCallBack( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 重铸后战魂变为0级，经验转化为%s战魂经验。\n您确定要花费%s%s重铸%s吗？
    local yesCallBack = function ()
    	-- 等级得大于0 或者 战魂精炼等级大于0
	    local isCan = false
	    if( (_huntData.va_item_text.fsLevel and tonumber(_huntData.va_item_text.fsLevel) > 0)
	    	or (_huntData.va_item_text.fsEvolve ~= nil and tonumber(_huntData.va_item_text.fsEvolve) >0) )then
	    	isCan = true
	    else
	    	isCan = false
	    end
	    if( isCan == false )then
	    	require "script/ui/tip/AnimationTip"
	        AnimationTip.showTip(GetLocalizeStringBy("lic_1737"))
	        return
	    end

    	-- 判断背包是否满了
    	-- 战魂背包满了
		if(ItemUtil.isFightSoulBagFull(true))then
			closeAction()
			return
		end
		-- 道具背包满了
		if(ItemUtil.isPropBagFull(true))then
			closeAction()
			return
		end
    	-- 判断银币是否够
    	if(UserModel.getSilverNumber() < 100) then
			require "script/ui/tip/AnimationTip"
	        AnimationTip.showTip(GetLocalizeStringBy("lic_1720"))
	        return
	    end
        closeAction()
        local nextCallFun = function (p_retData )
        	-- 扣银币
        	UserModel.addSilverNumber(-100)
        	-- 修改选择的战魂
        	if( _isOnHero )then 
        		HeroModel.addFSLevelOnHerosBy( _huntData.equip_hid, _huntData.pos, 0, 0 )
        		HeroModel.changeHeroFightSoulEvolveLv(_huntData.equip_hid, _huntData.pos, 0)
        	else
				DataCache.changeFSLvByItemId( _huntData.item_id, 0, 0 )
				DataCache.changeFightSouEvolveLvInBag( _huntData.item_id, 0 )
			end
        	-- 添加奖励
			local rewardTab = {}
			if( p_retData.silver )then
				local tab1 = {}
				tab1.type = "silver"
		        tab1.num  = tonumber(p_retData.silver)
		        tab1.tid  = 0
		        table.insert(rewardTab,tab1)
		    end
	        if( p_retData.fs_exp )then
				local tab2 = {}
				tab2.type = "fs_exp"
		        tab2.num  = tonumber(p_retData.fs_exp)
		        tab2.tid  = 0
		        table.insert(rewardTab,tab2)
		    end
	        -- 选择战魂
	        local tab3 = {}
			tab3.type = "item"
	        tab3.num  = 1
	        tab3.tid  = _huntData.item_template_id
	        table.insert(rewardTab,tab3)
	        if(not table.isEmpty(p_retData.item) )then
		        for k_tid,v_num in pairs(p_retData.item) do
		        	local tab = {}
					tab.type = "item"
			        tab.num  = tonumber(v_num)
			        tab.tid  = k_tid
			        table.insert(rewardTab,tab)
		        end
		    end

	        ItemUtil.addRewardByTable(rewardTab)

	        -- 弹奖励
			require "script/ui/item/ReceiveReward"
			ReceiveReward.showRewardWindow( rewardTab, _callFun, 1010, _priority-30, nil, {rewardTab} )
        end
        require "script/ui/huntSoul/HuntSoulService"
        HuntSoulService.rebornFightSoul(_huntData.item_id,nextCallFun)
    end

    local tipNode = CCNode:create()
    tipNode:setContentSize(CCSizeMake(400,100))
    local textInfo = {
            width = 400, -- 宽度
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 25,          -- 默认字体大小
            labelDefaultColor = ccc3(0x78,0x25,0x00),
            linespace = 10, -- 行间距
            defaultType = "CCLabelTTF",
            elements =
            {   
            	{
                    type = "CCLabelTTF", 
                    text = _huntData.va_item_text.fsExp,
                    color = ccc3(0x78,0x25,0x00),
                },
                {
                    type = "CCLabelTTF", 
                    text = 100,
                    color = ccc3(0x78,0x25,0x00),
                },
                {
                    type = "CCSprite", 
                    image = "images/common/coin.png",
                },
                {
                    type = "CCRenderLabel", 
                    text = _huntData.itemDesc.name,
                    color = HeroPublicLua.getCCColorByStarLevel(_huntData.itemDesc.quality),
                }
            }
        }
    local tipDes = GetLocalizeLabelSpriteBy_2("lic_1735", textInfo)
    tipDes:setAnchorPoint(ccp(0.5, 0.5))
    tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
    tipNode:addChild(tipDes)
    require "script/ui/tip/TipByNode"
    TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(500,360))
end

function layerToucCb(eventType, x, y)
	return true
end

function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

	require "script/ui/huntSoul/FightSoulLayer"
	FightSoulLayer.setMarkSoulItemId( _itemId )
end

function createBg()
	spriteBg = CCScale9Sprite:create("images/common/viewbg1.png")
	spriteBg:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
	spriteBg:setScale(myScale)
	spriteBg:setAnchorPoint(ccp(0.5,0.5))
	_bgLayer:addChild(spriteBg)

	if( tonumber(_huntData.itemDesc.quality) < 6 )then 
		spriteBg:setContentSize(CCSizeMake(620,590))
	else
		spriteBg:setContentSize(CCSizeMake(620,640))
	end

	local titileSprite = CCSprite:create("images/common/viewtitle1.png")
	titileSprite:setPosition(ccp(spriteBg:getContentSize().width/2,spriteBg:getContentSize().height))
	titileSprite:setAnchorPoint(ccp(0.5,0.5))
	spriteBg:addChild(titileSprite)

	local menuLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1489"), g_sFontPangWa, 33, 1,ccc3(0x00,0x00,0x00), type_stroke)
	menuLabel:setColor(ccc3(0xff,0xe4,0x00))
	menuLabel:setPosition(ccp(titileSprite:getContentSize().width*0.5,titileSprite:getContentSize().height*0.5+3))
	menuLabel:setAnchorPoint(ccp(0.5,0.5))
	titileSprite:addChild(menuLabel)

	local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-1)
    spriteBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(spriteBg:getContentSize().width*1.03,spriteBg:getContentSize().height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeAction)
    menu:addChild(closeBtn)
end

function upgradeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/huntSoul/UpgradeFightSoulLayer"

	if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
		return
	end

	local upgradeFightSoulLayer 

	local tArgs = {}
	tArgs.hid = _h_id

	--_isChange为真表示在阵容中，为假表示在背包中
	if _isChange == true then
		tArgs.sign = "equipFightSoul"
	else
		tArgs.sign = "fightSoulBag"
	end

	upgradeFightSoulLayer = UpgradeFightSoulLayer.createUpgradeFightSoulLayer(_itemId,tArgs)

	closeAction()

	MainScene.changeLayer(upgradeFightSoulLayer,"upgradeFightSoulLayer")
end

function changeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/formation/ChangeEquipLayer"
	local changeEquipLayer = ChangeEquipLayer.createLayer( nil, _h_id, _h_pos, false, true)
	require "script/ui/main/MainScene"
	MainScene.changeLayer(changeEquipLayer, "changeEquipLayer")
	closeAction()
end

function downAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	closeAction()

	-- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end

	-- 卸下
	require "script/ui/huntSoul/developSoul/DevelopSoulService"
	local removeCallFun = function ( ... )
		
		local allHeros = HeroModel.getAllHeroes()
		allHeros["" .. _h_id].equip.fightSoul["".._h_pos] = "0"

		--刷新战魂相关缓存属性
		HeroAffixFlush.onChangeFightSoul(_h_id)

		-- 刷新阵容
		require "script/ui/formation/FormationLayer"
		FormationLayer.refreshFightSoulAndBottom()

		local lastFightSoulAttrs = {}
		require "script/ui/huntSoul/HuntSoulData"
		local lastFightSoulAttrs = HuntSoulData.getFightSoulAttrByItem_id(_huntData.item_id, nil, _huntData)
	
		local curFightSoulAttrs = {}

		ItemUtil.showFightSoulAttrChangeInfo( lastFightSoulAttrs, curFightSoulAttrs, true )

	end
	DevelopSoulService.removeFightSoul(_h_id, _h_pos, removeCallFun)

end


function createContent()
	--图片
	local flowerBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	flowerBg:setAnchorPoint(ccp(0.5,1))
	spriteBg:addChild(flowerBg)

	if( tonumber(_huntData.itemDesc.quality) < 6 )then 
		flowerBg:setContentSize(CCSizeMake(535,290))
	else
		flowerBg:setContentSize(CCSizeMake(535,345))
	end
	flowerBg:setPosition(ccp(spriteBg:getContentSize().width/2,spriteBg:getContentSize().height-40))

	-- icon
	local huntSprite = nil
	if _itemId ~= nil then
		huntSprite = ItemSprite.getItemSpriteByItemId(_itemTempId,_huntData.va_item_text.fsLevel,false)
	else
		huntSprite = ItemSprite.getItemSpriteByItemId(_itemTempId,0,false)
	end
	huntSprite:setPosition(ccp(100,flowerBg:getContentSize().height*0.55))
	huntSprite:setAnchorPoint(ccp(0.5,0.5))
	flowerBg:addChild(huntSprite)

	require "script/ui/hero/HeroPublicLua"

	local huntName = CCRenderLabel:create(_huntData.itemDesc.name,  g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	huntName:setPosition(flowerBg:getContentSize().width/2, flowerBg:getContentSize().height-10)
	huntName:setAnchorPoint(ccp(0.5,1))
	huntName:setColor(HeroPublicLua.getCCColorByStarLevel(_huntData.itemDesc.quality))
	flowerBg:addChild(huntName)

	-- 星星
	local starSprite = getStarByQuality(_huntData.itemDesc.quality)
	starSprite:setAnchorPoint(ccp(0.5,0.5))
	starSprite:setPosition(ccp(huntSprite:getContentSize().width*0.5,-20))
	huntSprite:addChild(starSprite)

	-- 类型
	local descName = CCRenderLabel:create( GetLocalizeStringBy("key_3024"),  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	descName:setColor(ccc3(0xff, 0xe4, 0x00))
	local descContent = CCRenderLabel:create(_huntData.itemDesc.desc,  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	descContent:setColor(ccc3(0xff, 0xff, 0xff))
	local descInfo = BaseUI.createHorizontalNode({descName, descContent})
    descInfo:setAnchorPoint(ccp(0, 0))
	descInfo:setPosition(ccp(flowerBg:getContentSize().width/2, flowerBg:getContentSize().height-110))
	flowerBg:addChild(descInfo)

	local lineSprite1 = CCSprite:create("images/hunt/brownline.png")
	lineSprite1:setAnchorPoint(ccp(0,0))
	lineSprite1:setPosition(ccp(descInfo:getPositionX(),descInfo:getPositionY()-10))
	lineSprite1:setScaleX(flowerBg:getContentSize().width/2/116)
	flowerBg:addChild(lineSprite1)

	-- 等级
	local levelName = CCRenderLabel:create( GetLocalizeStringBy("key_1986"),  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	levelName:setColor(ccc3(0xff, 0xe4, 0x00))
	local levelNum = nil
	if _itemId ~= nil then
		levelNum = CCRenderLabel:create(_huntData.va_item_text.fsLevel .. "/" .. HuntSoulData.getMaxLvByFSTempId(_itemTempId,_userLv),  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	elseif _soulInfo ~= nil and _soulInfo.va_item_text ~= nil then
		local curLevel = _soulInfo.va_item_text.fsLevel or 0
		levelNum = CCRenderLabel:create(curLevel.."/" .. HuntSoulData.getMaxLvByFSTempId(_itemTempId,_userLv),  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	else
		levelNum = CCRenderLabel:create("0/" .. HuntSoulData.getMaxLvByFSTempId(_itemTempId,_userLv),  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	end
	levelNum:setColor(ccc3(0xff, 0xff, 0xff))

	local levelInfo = BaseUI.createHorizontalNode({levelName, levelNum})
    levelInfo:setAnchorPoint(ccp(0, 0))
	levelInfo:setPosition(ccp(flowerBg:getContentSize().width/2, lineSprite1:getPositionY()-50))
	flowerBg:addChild(levelInfo)

	local lineSprite2 = CCSprite:create("images/hunt/brownline.png")
	lineSprite2:setAnchorPoint(ccp(0,0))
	lineSprite2:setPosition(ccp(levelInfo:getPositionX(),levelInfo:getPositionY()-10))
	lineSprite2:setScaleX(flowerBg:getContentSize().width/2/116)
	flowerBg:addChild(lineSprite2)
		
	-- 基础属性
	local newAttriData = {}
	local tempTable = {}
	table.hcopy(_attributeData,tempTable)

	for k,v in pairs(tempTable) do
		if tonumber(v.desc.id) == 9 then
			v.sortId = 0
		else
			v.sortId = tonumber(v.desc.id)
		end
		table.insert(newAttriData,v)
	end

	local sortFunction = function(x,y)
		return x.sortId < y.sortId
	end

	table.sort(newAttriData,sortFunction)

	local beginY = lineSprite2:getPositionY()
	if not table.isEmpty(newAttriData) then
		for i = 1,#newAttriData do
			beginY = beginY-35
			local v = newAttriData[i]
			--print(v.desc.displayName)
			local attributeName = CCRenderLabel:create(v.desc.displayName .. "：",  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attributeName:setColor(ccc3(0xff, 0xe4, 0x00))
			local attributeNum = CCRenderLabel:create("+" .. v.displayNum,  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attributeNum:setColor(ccc3(0xff, 0xff, 0xff))

			local attributeInfo = BaseUI.createHorizontalNode({attributeName, attributeNum})
		    attributeInfo:setAnchorPoint(ccp(0, 0))
			attributeInfo:setPosition(ccp(flowerBg:getContentSize().width/2, beginY))
			flowerBg:addChild(attributeInfo)
		end
	else
		local expName = CCRenderLabel:create(GetLocalizeStringBy("key_2004"),  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		expName:setColor(ccc3(0xff, 0xe4, 0x00))
		local expNum
		--如果已获得的经验宝物，则显示当前的经验数据。否则显示表里的基础数据
		if _itemId ~= nil then
			expNum = CCRenderLabel:create("+" .. _huntData.va_item_text.fsExp + _huntData.itemDesc.baseExp,  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		else
			expNum = CCRenderLabel:create("+" .. _huntData.itemDesc.baseExp,  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		end
		expNum:setColor(ccc3(0xff, 0xff, 0xff))

		beginY = beginY-35
		local expInfo = BaseUI.createHorizontalNode({expName, expNum})
	    expInfo:setAnchorPoint(ccp(0, 0))
		expInfo:setPosition(ccp(flowerBg:getContentSize().width/2, beginY))
		flowerBg:addChild(expInfo)
	end

	-- 精炼等级
	if( tonumber(_huntData.itemDesc.quality) >= 6)then

		beginY = beginY-10

		local lineSprite3 = CCSprite:create("images/hunt/brownline.png")
		lineSprite3:setAnchorPoint(ccp(0,0))
		lineSprite3:setPosition(ccp(levelInfo:getPositionX(),beginY))
		lineSprite3:setScaleX(flowerBg:getContentSize().width/2/116)
		flowerBg:addChild(lineSprite3)

	    local jinglianFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1650") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    jinglianFont:setColor(ccc3(0xff, 0xe4, 0x00))
	    jinglianFont:setAnchorPoint(ccp(0,0))
	    jinglianFont:setPosition(ccp(flowerBg:getContentSize().width/2,lineSprite3:getPositionY()-40))
	    flowerBg:addChild(jinglianFont)
	    -- 当前洗练等级
	    local curEvolveLv = 0
		if( not table.isEmpty(_huntData.va_item_text) and _huntData.va_item_text.fsEvolve )then 
			curEvolveLv = tonumber(_huntData.va_item_text.fsEvolve)
		end
	    local jinglianNum = CCRenderLabel:create( curEvolveLv , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    jinglianNum:setColor(ccc3(0xff,0xff,0xff))
	    jinglianNum:setAnchorPoint(ccp(0,0))
	    jinglianNum:setPosition(ccp(jinglianFont:getPositionX()+jinglianFont:getContentSize().width+5, jinglianFont:getPositionY()))
	    flowerBg:addChild(jinglianNum)
	    local gemSp = CCSprite:create("images/common/fs_j.png")
		gemSp:setAnchorPoint(ccp(0,0))
		gemSp:setPosition(ccp(jinglianNum:getPositionX()+jinglianNum:getContentSize().width+3, jinglianFont:getPositionY()))
		flowerBg:addChild(gemSp)

		require "script/ui/huntSoul/evolveSoul/EvolveSoulData"
		local num = EvolveSoulData.getEvolveAttrByItemInfo( _huntData.itemDesc.id, curEvolveLv )
	 	local leixingDes = CCRenderLabel:create(GetLocalizeStringBy("lic_1649",num), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    leixingDes:setColor(ccc3(0x00,0xff,0x18))
	    leixingDes:setAnchorPoint(ccp(0,1))
	    leixingDes:setPosition(ccp(jinglianFont:getPositionX(),jinglianFont:getPositionY()-5))
	    flowerBg:addChild(leixingDes)
	end

	--按钮
	local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-1)
    spriteBg:addChild(menu,99)

    local buttonPositionY = spriteBg:getContentSize().height-70-flowerBg:getContentSize().height

	local upgradeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("key_2298"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	upgradeButton:setAnchorPoint(ccp(0.5, 0.5))
    upgradeButton:registerScriptTapHandler(upgradeAction)
	menu:addChild(upgradeButton)
	upgradeButton:setVisible(false)

	local changeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("key_2761"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	changeButton:setAnchorPoint(ccp(0.5, 0.5))
    changeButton:registerScriptTapHandler(changeAction)
	menu:addChild(changeButton)
	changeButton:setVisible(false)

	local downButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("lic_1701"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	downButton:setAnchorPoint(ccp(0.5, 0.5))
    downButton:registerScriptTapHandler(downAction)
	menu:addChild(downButton)
	downButton:setVisible(false)

	local closeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("key_1284"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
    closeButton:registerScriptTapHandler(closeAction)
	menu:addChild(closeButton)
	closeButton:setVisible(false)

	-- 进阶
	local developButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("lic_1645"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	developButton:setAnchorPoint(ccp(0.5, 0.5))
    developButton:registerScriptTapHandler(developButtonCallBack)
	menu:addChild(developButton)
	developButton:setVisible(false)

	-- 精炼
	local evolveButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("lic_1646"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	evolveButton:setAnchorPoint(ccp(0.5, 0.5))
    evolveButton:registerScriptTapHandler(evolveButtonCallBack)
	menu:addChild(evolveButton)
	evolveButton:setVisible(false)

	-- 战魂重铸
	local recastButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73),GetLocalizeStringBy("lic_1734"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	recastButton:setAnchorPoint(ccp(0.5, 0.5))
    recastButton:registerScriptTapHandler(recastButtonCallBack)
	menu:addChild(recastButton)
	recastButton:setVisible(false)

	local lvNum = HuntSoulData.getSoulMaterialLv()
	if _isChange == true then

	   	if( _huntData.itemDesc.is_evolve and tonumber(_huntData.itemDesc.is_evolve) == 1 
	   		and tonumber(_huntData.va_item_text.fsLevel) >= tonumber(_huntData.itemDesc.needSoreLevel) 
	   		and UserModel.getHeroLevel() >= lvNum and tonumber(_huntData.itemDesc.quality) < 6 )then
	   		recastButton:setVisible(true)
			recastButton:setPosition(ccp(spriteBg:getContentSize().width*0.2,buttonPositionY-70))
			developButton:setVisible(true)
			developButton:setPosition(ccp(spriteBg:getContentSize().width*0.5,buttonPositionY-70))
			upgradeButton:setVisible(true)
			upgradeButton:setPosition(ccp(spriteBg:getContentSize().width*0.8,buttonPositionY-70))
	   		changeButton:setVisible(true)
			changeButton:setPosition(ccp(spriteBg:getContentSize().width*0.3,buttonPositionY-150))
			downButton:setVisible(true)
			downButton:setPosition(ccp(spriteBg:getContentSize().width*0.7,buttonPositionY-150))
		elseif( _huntData.itemDesc.is_evolve and tonumber(_huntData.itemDesc.is_evolve) == 1 
	   		and tonumber(_huntData.va_item_text.fsLevel) >= tonumber(_huntData.itemDesc.needSoreLevel) 
	   		and UserModel.getHeroLevel() >= lvNum and tonumber(_huntData.itemDesc.quality) == 6 )then
	   		recastButton:setVisible(true)
			recastButton:setPosition(ccp(spriteBg:getContentSize().width*0.2,buttonPositionY-70))
			developButton:setVisible(true)
			developButton:setPosition(ccp(spriteBg:getContentSize().width*0.5,buttonPositionY-70))
			upgradeButton:setVisible(true)
			upgradeButton:setPosition(ccp(spriteBg:getContentSize().width*0.8,buttonPositionY-70))
	   		changeButton:setVisible(true)
			changeButton:setPosition(ccp(spriteBg:getContentSize().width*0.2,buttonPositionY-150))
			downButton:setVisible(true)
			downButton:setPosition(ccp(spriteBg:getContentSize().width*0.8,buttonPositionY-150))
			evolveButton:setVisible(true)
			evolveButton:setPosition(ccp(spriteBg:getContentSize().width*0.5,buttonPositionY-150))
	   	elseif( tonumber(_huntData.itemDesc.quality) > 6 )then
	   		recastButton:setVisible(true)
			recastButton:setPosition(ccp(spriteBg:getContentSize().width*0.2,buttonPositionY-70))
			evolveButton:setVisible(true)
			evolveButton:setPosition(ccp(spriteBg:getContentSize().width*0.5,buttonPositionY-70))
			upgradeButton:setVisible(true)
			upgradeButton:setPosition(ccp(spriteBg:getContentSize().width*0.8,buttonPositionY-70))
	   		changeButton:setVisible(true)
			changeButton:setPosition(ccp(spriteBg:getContentSize().width*0.3,buttonPositionY-150))
			downButton:setVisible(true)
			downButton:setPosition(ccp(spriteBg:getContentSize().width*0.7,buttonPositionY-150))
	   	else
	   		recastButton:setVisible(true)
			recastButton:setPosition(ccp(spriteBg:getContentSize().width*0.3,buttonPositionY-70))
			upgradeButton:setVisible(true)
			upgradeButton:setPosition(ccp(spriteBg:getContentSize().width*0.7,buttonPositionY-70))
	   		changeButton:setVisible(true)
			changeButton:setPosition(ccp(spriteBg:getContentSize().width*0.3,buttonPositionY-150))
			downButton:setVisible(true)
			downButton:setPosition(ccp(spriteBg:getContentSize().width*0.7,buttonPositionY-150))
	   	end
	else
		if( _huntData.itemDesc.is_evolve and tonumber(_huntData.itemDesc.is_evolve) == 1 
			and _huntData.va_item_text and tonumber(_huntData.va_item_text.fsLevel) >= tonumber(_huntData.itemDesc.needSoreLevel)
			and UserModel.getHeroLevel() >= lvNum and tonumber(_huntData.itemDesc.quality) < 6 )then
			recastButton:setVisible(true)
			recastButton:setPosition(ccp(spriteBg:getContentSize().width*0.2,buttonPositionY/2))
	   		developButton:setVisible(true)
			developButton:setPosition(ccp(spriteBg:getContentSize().width*0.5,buttonPositionY/2))
			upgradeButton:setVisible(true)
			upgradeButton:setPosition(ccp(spriteBg:getContentSize().width*0.8,buttonPositionY/2))
	   	elseif( _huntData.itemDesc.is_evolve and tonumber(_huntData.itemDesc.is_evolve) == 1 
			and _huntData.va_item_text and tonumber(_huntData.va_item_text.fsLevel) >= tonumber(_huntData.itemDesc.needSoreLevel)
			and UserModel.getHeroLevel() >= lvNum and tonumber(_huntData.itemDesc.quality) == 6 )then
	   		recastButton:setVisible(true)
			recastButton:setPosition(ccp(spriteBg:getContentSize().width*0.2,buttonPositionY-70))
			developButton:setVisible(true)
			developButton:setPosition(ccp(spriteBg:getContentSize().width*0.5,buttonPositionY-70))
	   		evolveButton:setVisible(true)
			evolveButton:setPosition(ccp(spriteBg:getContentSize().width*0.5,buttonPositionY-150))
			upgradeButton:setVisible(true)
			upgradeButton:setPosition(ccp(spriteBg:getContentSize().width*0.8,buttonPositionY-70))
		elseif( tonumber(_huntData.itemDesc.quality) > 6 )then
	   		recastButton:setVisible(true)
			recastButton:setPosition(ccp(spriteBg:getContentSize().width*0.2,buttonPositionY/2))
	   		evolveButton:setVisible(true)
			evolveButton:setPosition(ccp(spriteBg:getContentSize().width*0.5,buttonPositionY/2))
			upgradeButton:setVisible(true)
			upgradeButton:setPosition(ccp(spriteBg:getContentSize().width*0.8,buttonPositionY/2))
	   	else
	   		recastButton:setVisible(true)
			recastButton:setPosition(ccp(spriteBg:getContentSize().width*0.3,buttonPositionY/2))
			upgradeButton:setVisible(true)
			upgradeButton:setPosition(ccp(spriteBg:getContentSize().width*0.7,buttonPositionY/2))
	   	end
	end

	if _itemId == nil then
		upgradeButton:setVisible(false)
		changeButton:setVisible(false)
		developButton:setVisible(false)
		evolveButton:setVisible(false)
		recastButton:setVisible(false)
		closeButton:setVisible(true)
		closeButton:setPosition(ccp(spriteBg:getContentSize().width/2,buttonPositionY/2))
	end

	-- 提示
	local fightSoulDes = CCRenderLabel:create(GetLocalizeStringBy("zzh_1033"),  g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fightSoulDes:setColor(HeroPublicLua.getCCColorByStarLevel(3))
	fightSoulDes:setAnchorPoint(ccp(0.5,1))
	fightSoulDes:setPosition(ccp(spriteBg:getContentSize().width/2,flowerBg:getPositionY()-flowerBg:getContentSize().height-20))
	spriteBg:addChild(fightSoulDes)
end

function createUI()
	--信息处理
	if _itemId ~= nil then
		_huntData = ItemUtil.getItemInfoByItemId(_itemId)
		if( _huntData == nil )then
			-- 背包中没有 检查英雄身上是否有该战魂
			_huntData = ItemUtil.getFightSoulInfoFromHeroByItemId(_itemId)
			_isOnHero = true
		end
		-- print("----------")
		-- print_t(_huntData)
		_attributeData = HuntSoulData.getFightSoulAttrByItem_id(_itemId)
	elseif _soulInfo ~= nil then
		
		_huntData = _soulInfo
		_attributeData = HuntSoulData.getFSoulAttrBaseDescByItemInfo(_soulInfo)
	else
		_huntData = {}
		_attributeData = HuntSoulData.getFSoulAttrBaseDescByTempId(_itemTempId)
	end

	if(table.isEmpty(_huntData.itemDesc))then
		_huntData.itemDesc = ItemUtil.getItemById(_itemTempId)
	end

	-- print(GetLocalizeStringBy("key_1489"))
	-- print_t(_huntData)

	createBg()

	createContent()
end

function showLayer(item_template_id,item_id,isChange, h_id, h_pos, priority,zOrder,p_SoulInfo,p_callFun,p_userLv)
	init()
	--print("priority",priority)
	_itemTempId = item_template_id
	_itemId = item_id
	_isChange = isChange
	_h_id = h_id
	_h_pos = h_pos
    _soulInfo = p_SoulInfo
    _callFun = p_callFun
    _userLv = p_userLv
    -- print("对方阵容传过来的战魂信息")
    -- print_t(_soulInfo)
	if priority ~= nil then
		_priority = priority
	else
		_priority = -550
	end

	if zOrder ~= nil then
		_zOrder = zOrder
	else
		_zOrder = 999
	end
	--print("_priority",_priority)

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))

    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,_priority,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder,2013)

	myScale = MainScene.elementScale

	createUI()
end
