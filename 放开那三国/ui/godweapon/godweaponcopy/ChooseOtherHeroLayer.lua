-- Filename：	ChooseOtherHeroLayer.lua
-- Author：		LLP
-- Date：		2015-1-16
-- Purpose：		选择将领

module ("ChooseOtherHeroLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/model/hero/HeroModel"
require "script/ui/formation/FOfficerCell"
require "script/ui/formation/FormationUtil"
require "script/ui/tip/AnimationTip"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroFightSimple"
require "script/ui/formation/LittleFriendData"
require "script/ui/main/MainScene"

local _bgLayer				= nil	-- 背景
local _curHid 				= nil   -- hid
local _fPosition 			= nil	-- 阵型位置 从0开始
local _herosTableView 		= nil	-- tableView
local _curCallbackFunc 		= nil

local _herosData 			= {}	-- 可上阵的将领
local _f_hid 				= nil	-- 上一个武将
local Tag_CellBg = 10001
local _isLittleFriend 		= false
local _index 				= 1
local _chooseData  			= {}



-- 返回
function backAction( ... )
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	AddHeroLayer.showLayer(true)
	_bgLayer:setVisible(false)
	_bgLayer:removeFromParentAndCleanup(true)
end

-- 更换武将回调
function addHeroCallback( cbFlag, dictData, bRet )
	backAction()
end

-- 选中哪个
function selectedHerosDelegate( s_hid )
	if (s_hid and s_hid>0)then
		local allHeros = HeroModel.getAllHeroes()
		local htid = allHeros[s_hid..""].htid
		local modelId = HeroModel.getHeroModelId(htid)
		-- if(_isLittleFriend == true)then
		-- 	if( LittleFriendData.isSwapHeroOnLittleFriendByHid(s_hid,_fPosition) == false or FormationUtil.isHadSameTemplateOnFormation(s_hid) )then
		-- 		AnimationTip.showTip(GetLocalizeStringBy("key_2788"))
		-- 	else
		-- 	end
		-- else
			if( FormationUtil.isSwapHeroOnFormationByHid(s_hid,_fPosition) == false )then
				AnimationTip.showTip(GetLocalizeStringBy("key_2788"))
			else
				local haveSame = false
				for i,v in ipairs(_chooseData) do
					local modelIdCopy = HeroModel.getHeroModelId(allHeros[v..""].htid)
					if(tonumber(modelIdCopy)==tonumber(modelId))then
						AnimationTip.showTip(GetLocalizeStringBy("key_2788"))
						haveSame = true
						break
					end
				end
				if(haveSame==false)then
					_curHid = s_hid
					if(table.count(_chooseData)<2)then
						table.insert(_chooseData,s_hid)
					else
						_chooseData[_index] = s_hid
					end
					GodWeaponCopyData.setChooseHeroData(_chooseData)
					local args = Network.argsHandler(s_hid, _fPosition)
				end
			end
		-- end
		backAction()
	end
end

function checkedAction( tag, itemMenu )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	---------------------新手引导---------------------------------
	require "script/guide/NewGuide"
	if(NewGuide.guideClass ==  ksGuideFormation) then
	    require "script/guide/FormationGuide"
	    FormationGuide.changLayer()
	end
    ---------------------end-------------------------------------
	if (_curCallbackFunc) then
		_curCallbackFunc(tag)
	end
end

local function heroCb(exchange_hero_id,itemBtn)
	require "script/ui/shop/HeroExchange"
	local data = getHeroData(exchange_hero_id)
	require "script/ui/main/MainScene"
	require "script/ui/hero/HeroInfoLayer"

	HeroInfoLayer.createLayer(data, {isPanel=true})
end

function createOfficerCell(heroInfo, callbackFunc)
	_curCallbackFunc = callbackFunc

	local tCell = CCTableViewCell:create()

	-- 背景
	local cellBg = CCSprite:create("images/formation/changeofficer/cellbg.png")
	tCell:addChild(cellBg, 1, Tag_CellBg)
	local cellBgSize = cellBg:getContentSize()

	local officer_data = HeroUtil.getHeroInfoByHid(heroInfo.hid)

	-- 国家
	local countryStr = HeroModel.getCiconByCidAndlevel(officer_data.localInfo.country, officer_data.localInfo.potential)
	if(countryStr)then
		local countrySp = CCSprite:create(countryStr)
		countrySp:setAnchorPoint(ccp(0, 1))
		countrySp:setPosition((ccp(cellBgSize.width*0.02, cellBgSize.height*0.95)))
		cellBg:addChild(countrySp)
	end

	local menu = CCMenu:create()

	menu:setPosition(ccp(0,0))
	cellBg:addChild(menu)

	local heroSprite = HeroPublicCC.createHeroHeadIcon({hid=heroInfo.hid})
	heroSprite:setPosition(ccp(12,16))
	menu:addChild(heroSprite, 1, heroInfo.hid)

	-- 等级
   	local levelLabel = CCLabelTTF:create( "LV." .. heroInfo.level, g_sFontName,21)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setAnchorPoint(ccp(0, 1))
    levelLabel:setPosition(cellBgSize.width*0.1, cellBgSize.height*0.86)
    cellBg:addChild(levelLabel)

	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(officer_data.localInfo.potential)
	local nameLabel = CCLabelTTF:create(officer_data.localInfo.name, g_sFontName, 22)
	nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	nameLabel:setColor(nameColor)
	nameLabel:setPosition(ccp(cellBgSize.width*210/640, cellBgSize.height*0.78))
    cellBg:addChild(nameLabel)
    if(HeroModel.isNecessaryHeroByHid(heroInfo.hid)) then
		nameLabel:setString(UserModel.getUserName())
	end
    -- stars
    for i=1, officer_data.localInfo.potential do
    	local starSprite = CCSprite:create("images/hero/star.png")
    	starSprite:setAnchorPoint(ccp(0.5, 0.5))
    	starSprite:setPosition(ccp( cellBgSize.width * 300/640 + starSprite:getContentSize().width*1.2 * (i-1) , cellBgSize.height * 0.8))
    	cellBg:addChild(starSprite)
    end

    -- 战斗力
    local fightNumLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3083") .. officer_data.localInfo.heroQuality, g_sFontName, 24)
	fightNumLabel:setAnchorPoint(ccp(0, 0.5))
	fightNumLabel:setColor(ccc3(0x48, 0x1b, 0x00))
	fightNumLabel:setPosition(ccp(cellBgSize.width*115/640, cellBgSize.height*0.39))
    cellBg:addChild(fightNumLabel)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setTouchPriority(-1001)
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,9,9)
	-- 复选框
	checkedBtn = LuaMenuItem.createItemImage("images/formation/changeofficer/btn_onformation_n.png",  "images/formation/changeofficer/btn_onformation_h.png", checkedAction)
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*0.75, cellBgSize.height*0.4))
    checkedBtn:registerScriptTapHandler(checkedAction)

	menuBar:addChild(checkedBtn, 1, heroInfo.hid)


	return tCell
end


-- 创建tableview
local function createOfficerTableView(  )
	local cellBg = CCSprite:create("images/formation/changeofficer/cellbg.png")
	cellSize = cellBg:getContentSize()			--计算cell大小

    local myScale = _bgLayer:getContentSize().width/cellBg:getContentSize().width/_bgLayer:getElementScale()

	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
				local value = _herosData[a1+1]
                a2 = createOfficerCell(value, selectedHerosDelegate)
                a2:setScale(myScale)
            -- end
			r = a2
		elseif fn == "numberOfCells" then
			r = #_herosData
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then

		end
		return r
	end)
	herosTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width/_bgLayer:getElementScale(), _bgLayer:getContentSize().height*(0.885)/_bgLayer:getElementScale()))
    herosTableView:setAnchorPoint(ccp(0,0))
	herosTableView:setBounceable(true)
	herosTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

	_bgLayer:addChild(herosTableView,10)
end

-- 开始创建
local function create( ... )
	local bglayerSize = _bgLayer:getContentSize()
	local myScale = bglayerSize.width/640/_bgLayer:getElementScale()

	-- 创建topView
	-- 背景
	local topBg = CCSprite:create("images/formation/changeofficer/topbar.png")
	topBg:setAnchorPoint(ccp(0.5, 1))
	topBg:setPosition(ccp(bglayerSize.width/2, bglayerSize.height))
	topBg:setScale(myScale)
	_bgLayer:addChild(topBg)

	-- 标题
	local titleSprite = nil
	if(_isLittleFriend == true)then
		titleSprite = CCSprite:create("images/formation/littlef_title.png")
	else
		titleSprite = CCSprite:create("images/formation/changeofficer/title.png")
	end
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(topBg:getContentSize().width * 0.2, topBg:getContentSize().height*0.6))
	topBg:addChild(titleSprite)

	-- 返回按钮
	local topMenuBar = CCMenu:create()
	topMenuBar:setTouchPriority(-1001)
	topMenuBar:setPosition(ccp(0,0))
	topBg:addChild(topMenuBar)
	local backBtn = LuaMenuItem.createItemImage("images/formation/changeequip/btn_back_n.png",  "images/formation/changeequip/btn_back_h.png", backAction)
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
	backBtn:setPosition(ccp(topBg:getContentSize().width*0.85, topBg:getContentSize().height*0.6))

	topMenuBar:addChild(backBtn)

	createOfficerTableView()

end

local function init(  )
	_bgLayer		= nil	-- 背景
	_curHid 		= nil   -- hid
	_fPosition 		= nil	-- 阵型位置
	_herosTableView = nil	-- tableView
	_herosData		= HeroUtil.getFreeBenchHerosInfo()  -- 空闲的将领
	_curCallbackFunc 		= nil
	_index 			= 1
	_chooseData  	= {}
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then

    else

	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -4250, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer =nil
	end
end

function createLayer(p_index)

	init()
	_chooseData = GodWeaponCopyData.getChooseHeroData()
	_index = p_index
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", false, false, false)

	create()

	return _bgLayer
end


