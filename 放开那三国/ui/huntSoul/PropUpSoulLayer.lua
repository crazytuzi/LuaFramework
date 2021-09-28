-- FileName: PropUpSoulLayer.lua 
-- Author: licong 
-- Date: 15/11/2 
-- Purpose: 战魂经验升级战魂


module("PropUpSoulLayer", package.seeall)

local _bgLayer 							= nil
local _levelLabel 						= nil
local _attrNumFontArr 					= {}
local _bgProress 						= nil
local _fsBg 							= nil
local _progressSp 						= nil
local _expLabel 						= nil
local _maxSprrite 						= nil
local _upAnimSprite 					= nil

local _curItemId 						= nil
local _curItemData 						= nil
local _curLv                     		= nil
local _oldLv 							= nil
local _maxLevel     					= nil 
local _maxLvLimit 						= nil
local _needHeroLv 						= nil
local _realExpNum 						= nil 
local _realNeedNum 						= nil

local _touchPriority 					= -230

--[[
	@des 	: 初始化
--]]
function init()
	_bgLayer 							= nil
	_levelLabel 						= nil
	_attrNumFontArr 					= {}
	_bgProress 							= nil
	_fsBg 								= nil
	_progressSp 						= nil
	_expLabel 							= nil
 	_maxSprrite 						= nil
 	_upAnimSprite 						= nil

	_curItemId 							= nil
	_curItemData 						= nil
	_curLv                     			= nil
	_oldLv 								= nil
	_maxLevel     						= nil 
	_maxLvLimit 						= nil
	_needHeroLv 						= nil
	_realExpNum 						= nil 
	_realNeedNum 						= nil

end
------------------------------------------------------------- 按钮事件 -------------------------------------------------------------

--[[
	@des 	: 升1级回调 和 升5级
	@param 	: 
	@return :
--]]
function upMenuItemAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(_curLv >= _maxLvLimit)then 
		-- 等级最大上限
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip(GetLocalizeStringBy("lic_1623"))
		return 
	end
	if(_curLv >= _maxLevel)then
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip(GetLocalizeStringBy("key_3416") .. _needHeroLv .. GetLocalizeStringBy("key_3099"))
		return 
	end

	-- 是否够一级
	if( (_realNeedNum-_realExpNum) > UserModel.getFSExpNum() )then
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip(GetLocalizeStringBy("lic_1726"))
		return
	end

	local function nextCallFun(p_data)
		_curLv = tonumber(p_data.va_item_text.fsLevel)
		UserModel.addFSExpNum( -tonumber(p_data.fs_exp) )
		-- 修改目标装备的等级和经验
		if(_curItemData.equip_hid and tonumber(_curItemData.equip_hid) > 0)then 
			-- 修改装备战魂数据
			HeroModel.addFSLevelOnHerosBy( _curItemData.equip_hid, _curItemData.pos, _curLv,  p_data.va_item_text.fsExp )
		else
			-- 修改背包战魂数据
			DataCache.changeFSLvByItemId(_curItemData.item_id,_curLv,p_data.va_item_text.fsExp)
		end
		-- 修改数据
		_curItemData = HuntSoulData.getDesItemInfoByItemId(_curItemData.item_id)

		-- 升级特效
		upAnimation()
		-- 刷新
		refreshUI()

		-- 漂增加属性提示
		if(tonumber(_oldLv) < tonumber(_curLv))then  
			local tipArr = addAttrNumAndAtrrName(tonumber(_oldLv),tonumber(_curLv))
			require "script/utils/LevelUpUtil"
			LevelUpUtil.showFlyText(tipArr)
			_oldLv = tonumber(_curLv)
		end
   	end
	HuntSoulService.promoteByExp(_curItemId, tag, nextCallFun)
end

------------------------------------------------------------- 创建UI --------------------------------------------------------------

-- 得到增加的属性
function addAttrNumAndAtrrName( oldLeveNum, newLevelNum )
	local retArr = {}
	local cur_tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(_curItemData.item_id), newLevelNum )
	print("cur_tData")
	print_t(cur_tData)
	for k,v in pairs(cur_tData) do
		local temArr = {}
		temArr.txt = v.desc.displayName
		temArr.num = (newLevelNum - oldLeveNum) * tonumber(v.growRealNum)
		temArr.displayNumType = v.desc.type
		table.insert(retArr,temArr)
	end
	return retArr
end

--[[
	@des 	: 刷新UI
	@param 	: 
	@return :
--]]
function refreshUI()
	-- 刷新等级
	_levelLabel:setString( "Lv." .. _curLv )
	-- 属性
	local cur_tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(_curItemData.item_id) )
	print("cur_tData ..")
	print_t(cur_tData)
	for k,v in pairs(_attrNumFontArr) do
		if( cur_tData[k] ~= nil )then
			_attrNumFontArr[k]:setString( cur_tData[k].displayNum )
		end
	end
	-- 进度条
	_realExpNum,_realNeedNum = LevelUpUtil.getCurExp(_curItemData.itemDesc.upgradeID,_curItemData.va_item_text.fsExp,_curItemData.va_item_text.fsLevel)
	-- 经验条
	local rate = _realExpNum/_realNeedNum
	if(rate > 1)then
		rate = 1
	end
	if( _curLv < _maxLevel )then 
		_maxSprrite:setVisible(false)
		_progressSp:setContentSize(CCSizeMake(570 * rate, 22))
		-- 经验值
		_expLabel:setString(_realExpNum .. "/" .. _realNeedNum)
	else
		_progressSp:setContentSize(CCSizeMake(570, 22))
		_maxSprrite:setVisible(true)
		_expLabel:setVisible(false)
	end

	-- 下级需要的经验
	local str = nil
    if( _curLv < _maxLvLimit and  _curLv < _maxLevel and _realNeedNum-_realExpNum > 0)then
    	str = _realNeedNum-_realExpNum
    else
    	str = GetLocalizeStringBy("lic_1707")
    end
	_needNumFont:setString(str)
	-- 拥有的经验
	_haveNumFont:setString(UserModel.getFSExpNum())
end

--[[
	@des 	: 升级特效
	@param 	: 
	@return :
--]]
function upAnimation()
	local function fnupAnimSpriteEnd( ... )
		if(not tolua.isnull(_upAnimSprite) )then
			_upAnimSprite:removeFromParentAndCleanup(true)
			_upAnimSprite = nil
		end
	end
	if( not tolua.isnull(_upAnimSprite) )then
		_upAnimSprite:removeFromParentAndCleanup(true)
		_upAnimSprite = nil
	end
    _upAnimSprite = XMLSprite:create("images/base/effect/fightSoulUp/wuhunshengji")
    _upAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    _upAnimSprite:setPosition(ccp(122,122))
    _fsBg:addChild(_upAnimSprite,888)
   	_upAnimSprite:registerEndCallback( fnupAnimSpriteEnd )
end

--[[
	@des 	: 星星 最多6星
	@param 	: 
	@return :
--]]
function getStarByQuality( num )
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(40*tonumber(num),32))
	for i=1,num do
		local sprite = CCSprite:create("images/common/star.png")
		sprite:setAnchorPoint(ccp(0,0))
		sprite:setPosition(ccp((i-1)*(sprite:getContentSize().width+10),0))
		node:addChild(sprite)
		-- if(i <= tonumber(num))then
			-- local starSprite = CCSprite:create("images/common/star.png")
			-- starSprite:setAnchorPoint(ccp(0.5,0.5))
			-- starSprite:setPosition(ccp(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5))
			-- sprite:addChild(starSprite)
		-- end
	end
	return node
end

--[[
	@des 	: 创建经验进度条
	@param 	: 
	@return :
--]]
function createExpProgress()
	_realExpNum,_realNeedNum = LevelUpUtil.getCurExp(_curItemData.itemDesc.upgradeID,_curItemData.va_item_text.fsExp,_curItemData.va_item_text.fsLevel)
	-- print(" createExpProgress _realNeedNum",_realNeedNum,_realExpNum)
	_bgProress = CCScale9Sprite:create("images/hunt/exp_bg.png")
	_bgProress:setContentSize(CCSizeMake(_bgLayer:getContentSize().width/g_fScaleX, 49))
	_bgProress:setAnchorPoint(ccp(0.5, 0.5))
	local posY = _fsBg:getPositionY()-_fsBg:getContentSize().height*0.5*g_fScaleX-10*g_fScaleX-_bgProress:getContentSize().height*0.5*g_fScaleX
	_bgProress:setPosition(ccp(_bgLayer:getContentSize().width*0.5, posY))
	_bgLayer:addChild(_bgProress)
	_bgProress:setScale(g_fScaleX)

	-- 经验条
	local rate = _realExpNum/_realNeedNum
	if(rate > 1)then
		rate = 1
	end
	_progressSp = CCScale9Sprite:create("images/hunt/real_exp_line.png")
	_progressSp:setAnchorPoint(ccp(0, 0.5))
	_progressSp:setPosition(ccp(35, _bgProress:getContentSize().height * 0.5+1))
	_bgProress:addChild(_progressSp)

	_maxSprrite = CCSprite:create("images/common/max.png")
	_maxSprrite:setAnchorPoint(ccp(0.5, 0.5))
	_maxSprrite:setPosition(ccp(_bgProress:getContentSize().width*0.5, _bgProress:getContentSize().height * 0.5))
	_bgProress:addChild(_maxSprrite,10)
	_maxSprrite:setVisible(false)

	-- 经验值
	_expLabel = CCLabelTTF:create(_realExpNum .. "/" .. _realNeedNum, g_sFontName, 23)
	_expLabel:setColor(ccc3(0x00, 0x00, 0x00))
	_expLabel:setAnchorPoint(ccp(0.5, 0.5))
	_expLabel:setPosition(ccp(_bgProress:getContentSize().width*0.5, _bgProress:getContentSize().height*0.5))
	_bgProress:addChild(_expLabel)

	if( _curLv < _maxLevel and _curLv < _maxLvLimit )then 
		_maxSprrite:setVisible(false)
		_progressSp:setContentSize(CCSizeMake(570 * rate, 22))
		_expLabel:setVisible(true)
	else
		_progressSp:setContentSize(CCSizeMake(570, 22))
		_maxSprrite:setVisible(true)
		_expLabel:setVisible(false)
	end

	-- 升级所需要经验
	local needFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1724"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    needFont:setColor(ccc3(0xff,0xe4,0x00))
    needFont:setAnchorPoint(ccp(0,0.5))
    needFont:setPosition(ccp(50*g_fElementScaleRatio,_bgProress:getPositionY()-_bgProress:getContentSize().height*0.5*g_fScaleX-30*g_fElementScaleRatio))
    _bgLayer:addChild(needFont)
    needFont:setScale(g_fElementScaleRatio)

    -- 战魂经验图标
    local fsExpSp = CCSprite:create("images/common/fs_exp_small.png")
    fsExpSp:setAnchorPoint(ccp(0,0.5))
    fsExpSp:setPosition(ccp(needFont:getContentSize().width,needFont:getContentSize().height*0.5-2))
    needFont:addChild(fsExpSp)

    -- 需要经验值
    local str = nil
    if( _curLv < _maxLvLimit and  _curLv < _maxLevel and _realNeedNum-_realExpNum > 0)then 
    	str = _realNeedNum-_realExpNum
    else
    	str = GetLocalizeStringBy("lic_1707")
    end
    _needNumFont = CCRenderLabel:create(str, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _needNumFont:setColor(ccc3(0xff,0xff,0xff))
    _needNumFont:setAnchorPoint(ccp(0,0.5))
    _needNumFont:setPosition(ccp(fsExpSp:getContentSize().width+fsExpSp:getPositionX(),fsExpSp:getPositionY()))
    needFont:addChild(_needNumFont)

    -- 拥有经验
	local haveFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1725"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    haveFont:setColor(ccc3(0xff,0xe4,0x00))
    haveFont:setAnchorPoint(ccp(0,0.5))
    haveFont:setPosition(ccp(50*g_fElementScaleRatio,needFont:getPositionY()-needFont:getContentSize().height*0.5*g_fScaleX-20*g_fElementScaleRatio))
    _bgLayer:addChild(haveFont)
    haveFont:setScale(g_fElementScaleRatio)

    -- 战魂经验图标
    local fsExpSp = CCSprite:create("images/common/fs_exp_small.png")
    fsExpSp:setAnchorPoint(ccp(0,0.5))
    fsExpSp:setPosition(ccp(haveFont:getContentSize().width,haveFont:getContentSize().height*0.5-2))
    haveFont:addChild(fsExpSp)

    -- 拥有经验值
    _haveNumFont = CCRenderLabel:create(UserModel.getFSExpNum(), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _haveNumFont:setColor(ccc3(0x00,0xff,0x18))
    _haveNumFont:setAnchorPoint(ccp(0,0.5))
    _haveNumFont:setPosition(ccp(fsExpSp:getContentSize().width+fsExpSp:getPositionX(),fsExpSp:getPositionY()))
    haveFont:addChild(_haveNumFont)
end

--[[
	@des 	: 创建战魂信息
	@param 	: 
	@return :
--]]
function createFightSoulInfo( ... )
	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()

	-- 创建战魂背景
	_fsBg = CCSprite:create("images/hunt/fsoul_bg.png")
	_fsBg:setAnchorPoint(ccp(0.5,0.5))
	local fs_bgPoy = _bgLayer:getContentSize().height-148*g_fScaleX- _fsBg:getContentSize().height*0.5*g_fScaleX-bulletinLayerSize.height*g_fScaleX
	_fsBg:setPosition(ccp(_bgLayer:getContentSize().width*0.23,fs_bgPoy))
	_bgLayer:addChild(_fsBg)
	_fsBg:setScale(g_fScaleX)

	-- 战魂icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(_curItemData.item_template_id,_curItemData.va_item_text.fsLevel,false)
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(_fsBg:getContentSize().width*0.5,_fsBg:getContentSize().height*0.5))
	_fsBg:addChild(iconSprite)

	-- 星星
	local star_sprite = getStarByQuality(_curItemData.itemDesc.quality)
	star_sprite:setAnchorPoint(ccp(0.5,0))
	star_sprite:setPosition(ccp(_fsBg:getContentSize().width*0.5,0))
	_fsBg:addChild(star_sprite)

	-- 战魂名字
	local name_color = HeroPublicLua.getCCColorByStarLevel(_curItemData.itemDesc.quality)
 	local nameLabel = CCRenderLabel:create(_curItemData.itemDesc.name, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(name_color)
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setPosition(ccp(400,_fsBg:getContentSize().height*0.8))
    _fsBg:addChild(nameLabel,2)
    -- 分割线
    local lineSprite = CCScale9Sprite:create("images/hunt/brownline.png")
    lineSprite:setContentSize(CCSizeMake(185,4))
    lineSprite:setAnchorPoint(ccp(0.5,1))
    lineSprite:setPosition(ccp(nameLabel:getPositionX(),nameLabel:getPositionY()-nameLabel:getContentSize().height-3))
    _fsBg:addChild(lineSprite,2)

    -- 基础类型
    local leixing_font = CCRenderLabel:create( GetLocalizeStringBy("key_2519") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leixing_font:setColor(ccc3(0xff,0xe4,0x00))
    leixing_font:setAnchorPoint(ccp(0,1))
    leixing_font:setPosition(ccp(310,lineSprite:getPositionY()-lineSprite:getContentSize().height-10))
    _fsBg:addChild(leixing_font,2)
	-- 类型
 	local leixingLabel = CCRenderLabel:create(_curItemData.itemDesc.desc, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leixingLabel:setColor(ccc3(0xff,0xff,0xff))
    leixingLabel:setAnchorPoint(ccp(0,1))
    leixingLabel:setPosition(ccp(leixing_font:getPositionX()+leixing_font:getContentSize().width+5,leixing_font:getPositionY()))
    _fsBg:addChild(leixingLabel)
    -- 分割线
    local lineSprite = CCScale9Sprite:create("images/hunt/brownline.png")
    lineSprite:setContentSize(CCSizeMake(185,4))
    lineSprite:setAnchorPoint(ccp(0,1))
    lineSprite:setPosition(ccp(leixing_font:getPositionX()-5,leixing_font:getPositionY()-leixing_font:getContentSize().height-3))
    _fsBg:addChild(lineSprite,2)

    -- 等级
    local levelFont = CCRenderLabel:create( GetLocalizeStringBy("key_1178") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelFont:setColor(ccc3(0xff,0xe4,0x00))
    levelFont:setAnchorPoint(ccp(0,1))
    levelFont:setPosition(ccp(leixing_font:getPositionX(),lineSprite:getPositionY()-lineSprite:getContentSize().height-10))
    _fsBg:addChild(levelFont,2)
	-- 等级
 	_levelLabel = CCRenderLabel:create("Lv." .. _curLv, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _levelLabel:setColor(ccc3(0xff,0xff,0xff))
    _levelLabel:setAnchorPoint(ccp(0,1))
    _levelLabel:setPosition(ccp(levelFont:getPositionX()+levelFont:getContentSize().width+5,levelFont:getPositionY()))
    _fsBg:addChild(_levelLabel)
    -- 分割线
    local lineSprite = CCScale9Sprite:create("images/hunt/brownline.png")
    lineSprite:setContentSize(CCSizeMake(185,4))
    lineSprite:setAnchorPoint(ccp(0,1))
    lineSprite:setPosition(ccp(levelFont:getPositionX()-5,levelFont:getPositionY()-levelFont:getContentSize().height-3))
    _fsBg:addChild(lineSprite,2)

	--  属性
	local cur_tData = HuntSoulData.getFightSoulAttrByItem_id( tonumber(_curItemData.item_id) )
	print("cur_tData ..")
	print_t(cur_tData)
	local index = 0
	for k,v in pairs(cur_tData) do
		local displayName = v.desc.displayName
		local displayNum = v.displayNum
		index = index + 1
	    local atrr_font = CCRenderLabel:create(displayName .. ":", g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    atrr_font:setColor(ccc3(0xff,0xe4,0x00))
	    atrr_font:setAnchorPoint(ccp(0,1))
	    atrr_font:setPosition(ccp(leixing_font:getPositionX(),lineSprite:getPositionY()-lineSprite:getContentSize().height-(10*index+(index-1)*24)))
	    _fsBg:addChild(atrr_font,2)
		-- 属性值
	 	local atrrLabel = CCRenderLabel:create(displayNum, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    atrrLabel:setColor(ccc3(0xff,0xff,0xff))
	    atrrLabel:setAnchorPoint(ccp(0,1))
	    atrrLabel:setPosition(ccp(atrr_font:getPositionX()+atrr_font:getContentSize().width+5,atrr_font:getPositionY()))
	    _fsBg:addChild(atrrLabel)

	    -- 保存
		_attrNumFontArr[k] = atrrLabel
	end
end

--[[
	@des 	: 创建经验升级界面
	@param 	: 
	@return :
--]]
function createLayer( p_itemId )
	init()

	_bgLayer = CCLayer:create()

	-- 升级按钮
	local menuBar = CCMenu:create()
	menuBar:setTouchPriority(_touchPriority-5)
	menuBar:setPosition(ccp(0, 0))
	_bgLayer:addChild(menuBar)

	-- 升5级
	local fiveMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(178, 73),GetLocalizeStringBy("lic_1722"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	fiveMenuItem:setAnchorPoint(ccp(0.5,0))
	fiveMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.3,MenuLayer.getHeight()+10*g_fScaleX))
	menuBar:addChild(fiveMenuItem,1,5)
	fiveMenuItem:registerScriptTapHandler(upMenuItemAction)
	fiveMenuItem:setScale(g_fScaleX)

	-- 升1级
	local oneMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(178, 73),GetLocalizeStringBy("lic_1723"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	oneMenuItem:setAnchorPoint(ccp(0.5,0))
	oneMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.7,MenuLayer.getHeight()+10*g_fScaleX))
	menuBar:addChild(oneMenuItem,1,1)
	oneMenuItem:registerScriptTapHandler(upMenuItemAction)
	oneMenuItem:setScale(g_fScaleX)

	-- 下方线条
	local downSprite = CCSprite:create("images/hunt/down_line.png")
	downSprite:setAnchorPoint(ccp(0.5,0))
	local posY = oneMenuItem:getPositionY()+oneMenuItem:getContentSize().height*g_fScaleX+15*g_fScaleX
	downSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
	_bgLayer:addChild(downSprite,10)
	downSprite:setScale(g_fScaleX)

	-- 准备数据
	_curItemId = p_itemId
	-- 要升级的目标战魂信息
	_curItemData = HuntSoulData.getDesItemInfoByItemId(_curItemId)
	-- 升级前等级
	_curLv = tonumber(_curItemData.va_item_text.fsLevel)
	_oldLv = _curLv
	-- print("_curItemData")
	-- print_t(_curItemData)
	-- 可以强化到的最大等级
	_maxLevel = HuntSoulData.getMaxLvByFSTempId(_curItemData.item_template_id)
	print("_maxLevel",_maxLevel)
	-- 战魂级别最大上限
	_maxLvLimit = tonumber(_curItemData.itemDesc.maxLevel)

	-- 提升强化等级上限需要英雄的级数（玩家当前等级/10+1 ）*10 向下取整
	_needHeroLv = math.floor(UserModel.getHeroLevel()/10+1)*10

	-- 创建战魂信息
	createFightSoulInfo()
	
	-- 创建经验条
	createExpProgress()
	
	return _bgLayer
end


