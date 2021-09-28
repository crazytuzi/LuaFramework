-- Filename：	HeroSpriteCopy.lua
-- Author：		LLP
-- Date：		2014-12-16
-- Purpose：		阵容界面

module ("HeroSpriteCopy", package.seeall)

require "script/ui/main/MainScene"
require "script/model/DataCache"
require "db/DB_Heroes"
require "script/model/user/UserModel"
require "script/battle/BattleCardUtil"

local _priority				--触摸优先级
local _zorder				--z轴
local _bgLayer				--主界面
local _inFormationInfo 		--上阵武将信息
							--一个数组，内容为0表示位置开启但无上阵将领 内容为-1表示位置未开启 其余为武将id
local _heroCardsTable		--存放卡牌图片
local _touchBeganPoint		--触摸位置
local _began_pos			--初始卡牌编号
local _began_heroSprite		--初始开牌
local _began_hero_position	--初始卡牌位置
local _began_hero_ZOrder	--初始卡牌z轴
local _end_pos				--卡牌结束位置
local _h_AnimatedDuration	--动画时长
local _max_zOrder			--最高z轴
local _haveClick
local heroXScale
local heroYScale
local original_pos
local _copyInfo
local clickTable
local _itemNum
local _buffInfo
local _maxNum
local _clickNum
local _buyNum
local _buffdbInfo
local _standData
local _mainName

local function init()
	_priority 				= nil
	_zorder 				= nil
	_bgLayer				= nil
	_touchBeganPoint		= nil
	_began_pos				= nil
	_began_heroSprite 		= nil
	_began_hero_position	= nil
	_began_hero_ZOrder		= nil
	_end_pos				= nil
	original_pos 			= nil
	_inFormationInfo 		= {}
	_heroCardsTable			= {}
	heroXScale				= {}
	heroYScale				= {}
	_max_zOrder 			= 9999
	_h_AnimatedDuration		= 0.2
	_copyInfo 				= nil
	clickTable 				= {}
	_itemNum	  			= 0
	_maxNum 				= 0
	_clickNum 				= 0
	_buyNum 				= 0
	_buffInfo 				= nil
	_buffdbInfo 			= nil
	_haveClick 				= false
	_standData 				= nil
	_mainName 				= nil
end

local function onTouchesHandler(eventType, x, y)
	if eventType == "began" then
    	return true
	elseif eventType == "moved" then

	end
end

function backAction( ... )
	-- body
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	BuyBuffLayer.showLayer(_copyInfo["va_pass"]["buffShow"])
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer =nil
	end
end

function closeAction()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function dealWithData(pData)
	require "script/ui/formation/FormationUtil"
	_inFormationInfo = {}
	local index = 0

	for h_id,v in pairs(pData) do
		if(tonumber(v["htid"])>0)then
			_inFormationInfo[index] = tonumber(v["hid"])
		else
			_inFormationInfo[index] = 0
		end
		index = index + 1
	end
end

local function createUI()
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local changeFormationSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
	changeFormationSprite:setPreferredSize(CCSizeMake(620, 590))
	changeFormationSprite:setAnchorPoint(ccp(0.5, 0.5))
	changeFormationSprite:setPosition(ccp(_bgLayer:getContentSize().width/2, _bgLayer:getContentSize().height/2))
	changeFormationSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(changeFormationSprite)

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(changeFormationSprite:getContentSize().width/2, changeFormationSprite:getContentSize().height))
	changeFormationSprite:addChild(titleSp)
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_118") , g_sFontName, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
    titleSp:addChild(titleLabel)

    local backToFormationBar = CCMenu:create()
	backToFormationBar:setPosition(ccp(0, 0))
	backToFormationBar:setTouchPriority(-2001)
	changeFormationSprite:addChild(backToFormationBar)

	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(changeFormationSprite:getContentSize().width*0.97, changeFormationSprite:getContentSize().height*0.98))
	backToFormationBar:addChild(closeBtn)


	heroXScale = { 0.2, 0.5, 0.8, 0.2, 0.5, 0.8 }
	heroYScale = { 0.75, 0.75, 0.75, 0.30, 0.30, 0.30 }

	local underZorder = 10
	local upZorder = 20
	local index = 0
	local totalIndex = table.count(_inFormationInfo)
	--setCardHp
	--setCardAnger
	_heroCardsTable = {}

	local kIndex = 0
	local standDataCpy = {}
	for k,v in pairs(_standData)do
		standDataCpy[kIndex] = v
		kIndex = kIndex+1
	end
	for k, xScale in pairs(heroXScale) do
		index = index + 1
		local hid = _inFormationInfo[(k-1)]

		if(hid ~= nil)then
			local heroSp = nil
			local hero = DB_Heroes.getDataById(tonumber(standDataCpy[k-1]["htid"]))
			if(hero==nil)then
				heroSp = BattleCardUtil.getBattlePlayerCardImage(hid, nil)
			else
				heroSp = BattleCardUtil.getBattlePlayerCardImage(hid, nil,tonumber(standDataCpy[k-1]["htid"]))
			end

			heroSp:getChildByTag(10):setVisible(false)
			heroSp:setAnchorPoint(ccp(0.5, 0.5))
			heroSp:setPosition(ccp(changeFormationSprite:getContentSize().width*xScale,changeFormationSprite:getContentSize().height*heroYScale[k]))
			--------------------------------------
			hid = tonumber(hid)

		    local myHtid   = htid
		    local heroInfo = nil
		    local htid = nil
		    if(hero~=nil)then
		    	htid = tonumber(standDataCpy[k-1]["htid"])
		    end

		    if(htid~=nil)then

		        require "db/DB_Heroes"
		        local hero = DB_Heroes.getDataById(htid)

		        if(hero==nil)then
		            require "db/DB_Monsters_tmpl"
		            hero = DB_Monsters_tmpl.getDataById(htid)
		        end

		        grade = hero.star_lv
		        imageFile = hero.action_module_id
		        cardName  = hero.name
		        heroInfo  = hero
		    elseif(hid<10000000) then
		        require "db/DB_Monsters"
		        local monster = DB_Monsters.getDataById(hid)

		        if(monster==nil) then
		           monster = DB_Monsters.getDataById(3014201)
		        end

		        require "db/DB_Monsters_tmpl"
		        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)

		        grade     = monsterTmpl.star_lv
		        imageFile = monsterTmpl.action_module_id
		        cardName  = monsterTmpl.name
		        myHtid    = monster.htid
		        heroInfo  = monsterTmpl
		    else
		        require "script/model/hero/HeroModel"
		        require "script/utils/LuaUtil"
		        local allHeros = HeroModel.getAllHeroes()
		        if(allHeros==nil or allHeros[hid..""] == nil)then

		            grade = hid%6+1
		            imageFile = "zhan_jiang_guojia.png"
		        else
		            local htid = allHeros[hid..""].htid
		            myHtid = htid
		            require "db/DB_Heroes"
		            local hero = DB_Heroes.getDataById(htid)

		            grade = hero.star_lv
		            imageFile = hero.action_module_id
		            cardName  = hero.name
		            myHtid = htid
		            heroInfo  = hero
		        end
		    end
		    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.potential)
			--------------------------------------
			----------------------------
			local heroBgSize = heroSp:getContentSize()

			local heroBg = CCSprite:create("images/godweaponcopy/01.png")
			heroBg:setAnchorPoint(ccp(0.5,1))
			heroBg:setPosition(ccp(heroBgSize.width/2, -heroBgSize.height*0.15))
			heroSp:addChild(heroBg)

			-- lv
			local lvSp = CCSprite:create("images/common/lv.png")
			lvSp:setAnchorPoint(ccp(0,1))
			heroSp:addChild(lvSp)

			-- 等级
			local levelLabel = CCRenderLabel:create( standDataCpy[k-1]["level"] , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
		    heroSp:addChild(levelLabel)
		    local sPositionX = (heroBgSize.width -levelLabel:getContentSize().width - lvSp:getContentSize().width)  * 0.5
		    lvSp:setPosition(ccp(sPositionX, -heroBgSize.height*0.15-2))
		    levelLabel:setPosition(ccp( sPositionX + lvSp:getContentSize().width, -heroBgSize.height*0.15-2))

		    local heroName
		    require "db/DB_Heroes"
	        local hero = DB_Heroes.getDataById(tonumber(standDataCpy[k-1]["htid"]))

	        if(hero==nil)then
	            require "db/DB_Monsters"
		        local monster = DB_Monsters.getDataById(hid)

		        if(monster==nil) then
		           monster = DB_Monsters.getDataById(3014201)
		        end

		        require "db/DB_Monsters_tmpl"
		        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
		        hero = monsterTmpl
	        end
	        local cardName  = hero.name
	        if(cardName==GetLocalizeStringBy("llp_153") or cardName == GetLocalizeStringBy("llp_154"))then
	        	cardName = _mainName
	        end

		    heroName = CCRenderLabel:create(cardName,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
		    heroName:setColor(nameColor)

		    local envolveNum = CCRenderLabel:create("",g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)




		    if tonumber(standDataCpy[k-1]["evolve_level"]) ~= 0 then
		    	if(tonumber(heroInfo.potential)==6)then
		    		envolveNum:setString(tonumber(standDataCpy[k-1]["evolve_level"]) .. GetLocalizeStringBy("zzh_1159"))
		    	else
		    		envolveNum:setString("+" .. tonumber(standDataCpy[k-1]["evolve_level"]))
		    	end
		    end
		    envolveNum:setColor(ccc3(0x76,0xfc,0x06))

			require "script/utils/BaseUI"
		    local underString = BaseUI.createHorizontalNode({heroName, envolveNum})
		    underString:setAnchorPoint(ccp(0.5,1))
		    underString:setPosition(ccp(heroBgSize.width/2,-heroBgSize.height*0.15-lvSp:getContentSize().height-5))
		    heroSp:addChild(underString,1000)
			----------------------------

			--设置怒气
			--setCardAnger
			local curRange = tonumber(standDataCpy[k-1]["currRage"])
			BattleCardUtil.setCardAnger(heroSp,curRange)

			if tonumber(k) >= 4 then
				changeFormationSprite:addChild(heroSp, underZorder, hid)
			else
				changeFormationSprite:addChild(heroSp,upZorder,hid)
			end
			if(hid>=0)then
				_heroCardsTable[k] = heroSp
			end
		end
	end
end

function createLayer( ... )
	-- body
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

    dealWithData(_standData)

    createUI()

    return _bgLayer
end

function showLayer(touch_priority,zorder,pNum,pData,pName)
	init()

	_priority = touch_priority or (-550)
	_zorder	= zorder or 999
	_itemNum = pNum
	_standData = pData
	_mainName = pName

	local pLayer = createLayer()

	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(pLayer,_zorder)
end