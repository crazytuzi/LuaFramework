-- Filename：	PetHandbookLayer.lua
-- Author：		bzx
-- Date：		2015-10-9
-- Purpose：		宠物图鉴

module("PetHandbookLayer", package.seeall)

local _layer
local _allHandbookInfo
local _tableView
local _arrow_left
local _arrow_right

function show()
	_layer = create()
    MainScene.changeLayer(_layer, "PetHandBookLayer")
end

function init( ... )
	_allHandbookInfo = PetData.getAllHandbookInfo()
	_tableView = nil
	_arrow_right = nil
	_arrow_left = nil
end

function create( ... )
	init()
	_layer = CCLayer:create()
	loadBg()
	loadTop()
	loadTableView()
	loadButtomTip()
	return _layer
end

function loadBg( ... )
	local bg = CCSprite:create("images/pet/handbook/bg.png")
    _layer:addChild(bg)
    bg:setScale(MainScene.bgScale)
    
    -- 上面的花边
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local border_filename = "images/recharge/mystery_merchant/border.png"
    local border_top = CCSprite:create(border_filename)
    _layer:addChild(border_top)
    border_top:setAnchorPoint(ccp(0, 0))
    border_top:setScale(g_fScaleX)
    border_top:setScaleY(-g_fScaleX)
    local border_top_y = g_winSize.height - 75 * g_fScaleX
    border_top:setPosition(0, border_top_y)
end

function loadTop( ... )
	loadPlayerInfo()
	local menu = CCMenu:create()
	_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))

	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	menu:addChild(backItem)
	backItem:setScale(MainScene.elementScale)
    backItem:registerScriptTapHandler(backCallback)
    backItem:setScale(MainScene.elementScale)
    backItem:setPosition(ccp(g_winSize.width - 100 * MainScene.elementScale, g_winSize.height - 160 * g_fScaleX))

    local title = CCSprite:create("images/pet/handbook/title.png")
    _layer:addChild(title)
    title:setAnchorPoint(ccp(0.5, 1))
    title:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 110 * g_fScaleX))
    title:setScale(MainScene.elementScale)
end

function loadPlayerInfo( )
	require "script/model/user/UserModel"

    local _topBg = HeroUtil.createNewAttrBgSprite(UserModel.getHeroLevel(), UserModel.getUserName(),UserModel.getVipLevel(),UserModel.getSilverNumber(), UserModel.getGoldNumber())
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0, _layer:getContentSize().height - BulletinLayer.getLayerHeight()*g_fScaleX)
    _topBg:setScale(g_fScaleX)
    _layer:addChild(_topBg, 1, 19876)
	return _topBg
end

function loadButtomTip( ... )
	local tip1 = CCLabelTTF:create(GetLocalizeStringBy("key_10334"), g_sFontName, 21)
	_layer:addChild(tip1)
	tip1:setAnchorPoint(ccp(0.5, 0))
	tip1:setPosition(ccp(g_winSize.width * 0.5, MenuLayer.getHeight() + 40 * g_fScaleX))
	tip1:setScale(g_fScaleX)
	-- tip:setColor(ccc3(0x78, 0x25, 0x00))
	local tip2 = CCLabelTTF:create(GetLocalizeStringBy("key_10335"), g_sFontName, 21)
	_layer:addChild(tip2)
	tip2:setAnchorPoint(ccp(0.5, 0))
	tip2:setPosition(ccp(g_winSize.width * 0.5, MenuLayer.getHeight() + 15 * g_fScaleX))
	tip2:setScale(g_fScaleX)
end

function backCallback( ... )
  	local layer= PetMainLayer.createLayer()
  	MainScene.changeLayer(layer, "PetMainLayer")
end

function loadTableView( ... )
	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(300, 680)
		elseif fn == "cellAtIndex" then
			a2 = createCell(a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_allHandbookInfo
		elseif fn == "scroll" then
			refreshHeroArrows()
		end
		return r
	end)
	require "script/ui/mergeServer/accumulate/AccumulateActivity"
 	_tableView = LuaTableView:createWithHandler(h, CCSizeMake(600, 650))
 	_layer:addChild(_tableView)
 	_tableView:setDirection(kCCScrollViewDirectionHorizontal)
 	_tableView:setAnchorPoint(ccp(0.5, 0.5))
 	_tableView:ignoreAnchorPointForPosition(false)
 	_tableView:setPosition(ccp(g_winSize.width * 0.5, (g_winSize.height -  200 * g_fScaleX) * 0.5 + 130 * g_fScaleX))
 	_tableView:reloadData()
 	_tableView:setScale(MainScene.elementScale)

 	-- 向上的箭头
	_arrow_left = CCSprite:create( "images/common/arrow_up_h.png")
    _layer:addChild(_arrow_left)
	_arrow_left:setPosition(10, g_winSize.height * 0.5)
	_arrow_left:setAnchorPoint(ccp(0.5,1))
	_arrow_left:setVisible(false)
	_arrow_left:setRotation(-90)
	_arrow_left:setScale(MainScene.elementScale)

	-- 向下的箭头
	_arrow_right = CCSprite:create( "images/common/arrow_down_h.png")
    _layer:addChild(_arrow_right)
	_arrow_right:setPosition(g_winSize.width - 10, g_winSize.height * 0.5)
	_arrow_right:setAnchorPoint(ccp(0.5,0))
	_arrow_right:setVisible(true)
	_arrow_right:setRotation(270)
	_arrow_right:setScale(MainScene.elementScale)

	arrowAction(_arrow_left)
	arrowAction(_arrow_right)
end

function arrowAction( arrow)
	local arrActions_2 = CCArray:create()
	arrActions_2:addObject(CCFadeOut:create(1))
	arrActions_2:addObject(CCFadeIn:create(1))
	local sequence_2 = CCSequence:create(arrActions_2)
	local action_2 = CCRepeatForever:create(sequence_2)
	arrow:runAction(action_2)
end

function refreshHeroArrows()
    if _tableView == nil then
        return
    end
    local offset = _tableView:getContentSize().width + _tableView:getContentOffset().x - _tableView:getViewSize().width
	if _arrow_right ~= nil then
		if offset > 1 or offset < -1 then
			_arrow_right:setVisible(true)
		else
			_arrow_right:setVisible(false)
		end
	end

	if _arrow_left ~= nil  then
		if _tableView:getContentOffset().x < 0 then
			_arrow_left:setVisible(true)
		else
			_arrow_left:setVisible(false)
		end
	end
end

function createCell(index)
	local cell = CCTableViewCell:create()

	local cellSize = CCSizeMake(300, 660)
	cell:setContentSize(cellSize)
	local bg = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	cell:addChild(bg)
	bg:setPreferredSize(CCSizeMake(292, 600))
	bg:setAnchorPoint(ccp(0.5, 0))
	bg:setPosition(ccpsprite(0.5, 0, cell))
	
	local petDb = _allHandbookInfo[index + 1]

	local TempSprite = CCSprite
	local notGetTagSprite = nil
	if not PetData.isGot(petDb.id) then
		TempSprite = BTGraySprite
		notGetTagSprite = CCSprite:create("images/dress_room/not_get.png")
	end
	local petBg = CCSprite:create("images/pet/handbook/cell_up_bg.png")
	bg:addChild(petBg)
	petBg:setAnchorPoint(ccp(0.5, 1))
	petBg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 7))

	local petSprite = TempSprite:create("images/pet/body_img/" .. petDb.roleModelID)
	petBg:addChild(petSprite, 2)
	petSprite:setAnchorPoint(ccp(0.5, 0.5))
	petSprite:setPosition(ccpsprite(0.5, 0.5, petBg))
	petSprite:setScale(0.5)

	
	if notGetTagSprite ~= nil then
		petBg:addChild(notGetTagSprite, 4)
		notGetTagSprite:setAnchorPoint(ccp(0.5, 0.5))
		notGetTagSprite:setPosition(ccpsprite(0.5, 0.5, petBg))
	else
		local effectDown = XMLSprite:create("images/base/effect/chongwudown/chongwudown")
		petBg:addChild(effectDown, 1)
		effectDown:setPosition(ccpsprite(0.5, 0.2, petBg))

		local effectUp = XMLSprite:create("images/base/effect/chongwuup/chongwuup")
		petBg:addChild(effectUp, 3)
		effectUp:setPosition(ccpsprite(0.5, 0.2, petBg))
	end

	local nameBg = CCScale9Sprite:create(CCRectMake(86, 30, 4, 8), "images/pet/pet/pethandbook_bg.png")
	bg:addChild(nameBg, 10)
	--nameBg:setPreferredSize(CCSizeMake(258, 53))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 10))

	local name = CCLabelTTF:create(petDb.roleName, g_sFontPangWa, 27)
	nameBg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccp(nameBg:getContentSize().width * 0.5, nameBg:getContentSize().height * 0.5 + 8))
	name:setColor(HeroPublicLua.getCCColorByStarLevel(petDb.quality))


	local bgSize = cellSize
	if petDb.extra_affix ~= nil then
		local textBg = nil
		if PetData.isGot(petDb.id) then
			textBg = CCScale9Sprite:create("images/dress_room/attribute_bg.png")
		else
			textBg = CCScale9Sprite:create("images/dress_room/gray_attribute_bg.png")
		end
		bg:addChild(textBg)
		textBg:setPreferredSize(CCSizeMake(255, 170))
		textBg:setAnchorPoint(ccp(0.5, 0))
		textBg:setPosition(ccp(bgSize.width * 0.5, 30))

		local textTitleBg = CCScale9Sprite:create("images/common/astro_labelbg.png")
		textBg:addChild(textTitleBg)
		textTitleBg:setAnchorPoint(ccp(0.5, 0.5))
		textTitleBg:setPosition(ccpsprite(0.5, 1, textBg))
		textTitleBg:setPreferredSize(CCSizeMake(211, 40))

		local textTitle = CCLabelTTF:create(GetLocalizeStringBy("key_8347"), g_sFontPangWa, 25)
		textTitleBg:addChild(textTitle)
		textTitle:setAnchorPoint(ccp(0.5, 0.5))
		textTitle:setPosition(ccpsprite(0.5, 0.53, textTitleBg))
		textTitle:setColor(ccc3(0xff, 0xf6, 0x00))
		local extraAffixDatas = parseField(petDb.extra_affix, 2)
		for i=1, #extraAffixDatas do
			local affixId = extraAffixDatas[i][1]
			local affixDB = DB_Affix.getDataById(affixId)
			local affixName = CCLabelTTF:create(affixDB.sigleName, g_sFontName, 21)
			textBg:addChild(affixName)
			affixName:setAnchorPoint(ccp(0, 0.5))
			affixName:setPosition(ccp(50 , textBg:getContentSize().height - 20 -  i * 27))

			local affixDesc, affix = ItemUtil.getAtrrNameAndNum(affixId, extraAffixDatas[i][2])

			local affixValue = CCLabelTTF:create("+" .. tostring(affix), g_sFontName, 21)
			textBg:addChild(affixValue)
			affixValue:setAnchorPoint(ccp(0, 0.5))
			affixValue:setPosition(ccp(150, affixName:getPositionY()))

			if not PetData.isGot(petDb.id) then
				affixName:setColor(ccc3(0x82, 0x82, 0x82))
				affixValue:setColor(ccc3(0x82, 0x82, 0x82))
			end
		end
	end

	local menu = CCMenu:create()
	bg:addChild(menu)
	menu:setPosition(ccp(0, 0))

	local checkPetInfoItem = CCMenuItemImage:create("images/olympic/checkbutton/check_btn_h.png", "images/olympic/checkbutton/check_btn_n.png")
	menu:addChild(checkPetInfoItem)
	checkPetInfoItem:setPosition(ccp(bgSize.width - 50, 530))
	checkPetInfoItem:setAnchorPoint(ccp(0.5, 0.5))
	checkPetInfoItem:registerScriptTapHandler(checkPetInfoCallback)
	checkPetInfoItem:setTag(petDb.id)
	return cell
end

-- 查看宠物获得途径
function checkPetInfoCallback( p_tag )
	local petID = p_tag
	require "script/ui/pet/PetGetInfoLayer"
	PetGetInfoLayer.show(petID)
end
