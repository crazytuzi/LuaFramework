-- Filename：	MakeUpLayer.lua
-- Author：		LLP
-- Date：		2014-12-16
-- Purpose：		阵容界面

module ("MakeUpLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/model/DataCache"
require "script/battle/BattleCardUtil"
-- require "script/battle/BattleCardUtil"

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
local heroCardsTable    = {}
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
	heroCardsTable    = {}
	_itemNum	  			= 0
	_maxNum 				= 0
	_clickNum 				= 0
	_buyNum 				= 0
	_buffInfo 				= nil
	_buffdbInfo 			= nil
	_haveClick 				= false
end

local function onTouchesHandler(eventType, x, y)
	if eventType == "began" then
		_touchBeganPoint = ccp(x, y)
		_began_pos = nil
		_began_heroSprite = nil
		_began_hero_position = nil
		_began_hero_ZOrder = nil
		original_pos = nil
		print("began")
		print_t(_inFormationInfo)
		print("began")
		local canClick = false
        --local isTouch = false
        local copyInfo = GodWeaponCopyData.getCopyInfo()
		local buffNum = tonumber(copyInfo["va_pass"]["buffShow"][tonumber(_itemNum)]["buff"])
		local buffInfo = DB_Overcome_buff.getDataById(tonumber(buffNum))
		local buffData = buffInfo.buff

		local buffArry = string.split(buffData, "|")
		local buffType = tonumber(buffArry[1])
		-- 加buff
    	for pos, heroCard in pairs(_heroCardsTable) do
    		local bPosition = heroCard:convertToNodeSpace(_touchBeganPoint)
    		if ( bPosition.x >0 and bPosition.x <  heroCard:getContentSize().width and bPosition.y > 0 and bPosition.y < heroCard:getContentSize().height ) then
	        	print("点到卡牌上了")
	        	print("pos=="..pos.."_inFormationInfo[pos]".._inFormationInfo[pos])
	        	if (tonumber(_inFormationInfo[pos])>0) then
						local haveClick = true
						for k,v in pairs(clickTable)do
							if(tonumber(v)==heroCard:getTag())then
								haveClick = false
								break
							end
						end
			        	if(not haveClick)then
			        		AnimationTip.showTip(GetLocalizeStringBy("llp_138"))
			        	else
			        		local clickCount = table.count(clickTable)
			        		if(clickCount<tonumber(_maxNum))then
				        		local spriteTouch = CCSprite:create()
				        		heroCard:addChild(spriteTouch,0,0)
				        		if(buffType == 2)then
				        			for k,v in pairs(_copyInfo["va_pass"]["heroInfo"])do
										if(tonumber(k)==tonumber(heroCard:getTag()))then
											if(tonumber(v["currHp"])<tonumber(_copyInfo["percentBase"])and tonumber(v["currHp"])~=0)then
												--播加血动画
												local currHp = v["currHp"]
												local totalHp = tonumber(_copyInfo["percentBase"])
												local addHp = tonumber(buffArry[3])
												local scale = (currHp+totalHp*addHp/10000)/totalHp
												BattleCardUtil.setCardHp(heroCard,scale)
												table.insert(clickTable,heroCard:getTag())
				        						GodWeaponCopyData.setClickTable(clickTable)
												break
											else
												if(tonumber(v["currHp"])>=tonumber(_copyInfo["percentBase"]))then
													AnimationTip.showTip(GetLocalizeStringBy("llp_135"))
												else
													AnimationTip.showTip(GetLocalizeStringBy("llp_139"))
												end
											end
										end
									end
				        		elseif(buffType == 3)then
				        			for k,v in pairs(_copyInfo["va_pass"]["heroInfo"])do
										if(tonumber(k)==tonumber(heroCard:getTag()))then
											if(tonumber(v["currHp"])~=0)then
												local curRange = v["currRage"]
												local addRange = tonumber(buffArry[3])
												local totalRange = curRange+addRange
												BattleCardUtil.setCardAnger(heroCard,totalRange)
												table.insert(clickTable,heroCard:getTag())
				        						GodWeaponCopyData.setClickTable(clickTable)
												break
											else
												AnimationTip.showTip(GetLocalizeStringBy("llp_136"))
											end
										end
									end
				        		elseif(buffType == 4)then
				        			for k,v in pairs(_copyInfo["va_pass"]["heroInfo"])do
										if(tonumber(k)==tonumber(heroCard:getTag()))then
											if(tonumber(v["currHp"])==0)then
												--播加血动画
												local totalHp = tonumber(_copyInfo["percentBase"])
												local addHp = tonumber(buffArry[3])
												local scale = (totalHp*addHp/10000)/totalHp
												BattleCardUtil.setCardHp(heroCard,scale)
												table.insert(clickTable,heroCard:getTag())
				        						GodWeaponCopyData.setClickTable(clickTable)
				        						-- _clickNum = _clickNum + 1

				        						heroCard:getChildByTag(tonumber(k)):setVisible(false)
				        						heroCard:getChildByTag(tonumber(k)):removeFromParentAndCleanup(true)
												break
											else
												AnimationTip.showTip(GetLocalizeStringBy("llp_137"))
											end
										end
									end
				        		end
				        	else
				        		AnimationTip.showTip(GetLocalizeStringBy("llp_140"))
				        	end
					        -- else
					        -- 	AnimationTip.showTip("施主，这个人你摸过了")
					        -- end
			        	end
					-- end
	        	break
	        	end
	        end
    	end

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

function sureAction( ... )
	if(table.isEmpty(clickTable))then
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
		_copyInfo = GodWeaponCopyData.getCopyInfo()
		BuyBuffLayer.showLayer(_copyInfo["va_pass"]["buffShow"])
		return
	end
	local buffNum = tonumber(_copyInfo["va_pass"]["buffShow"][tonumber(_itemNum)]["buff"])
	_buffdbInfo = DB_Overcome_buff.getDataById(tonumber(buffNum))

	if(tonumber(_copyInfo["star_star"])>=tonumber(_buffdbInfo.costStar))then
		--获取买buff命令参数
		local args = CCArray:create()
		args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
		args:addObject(CCInteger:create(tonumber(_itemNum)-1))
		local idArray = CCArray:create()
		for k,v in pairs(clickTable) do
			idArray:addObject(CCInteger:create(v))
		end
		args:addObject(idArray)
		--调用获取买buff命令
		GodWeaponCopyService.buyBuffInfo(closeAction,args)
	else
		AnimationTip.showTip(GetLocalizeStringBy("llp_141"))
	end

end

function closeAction()

	local buffNum = tonumber(_copyInfo["va_pass"]["buffShow"][tonumber(_itemNum)]["buff"])
	local buffInfo = DB_Overcome_buff.getDataById(tonumber(buffNum))
	local buffData = buffInfo.buff

	local buffArry = string.split(buffData, "|")
	local buffType = tonumber(buffArry[1])

	if(buffType==2)then
		for i=1,table.count(clickTable)do
			local newHp = _copyInfo["va_pass"]["heroInfo"][tostring(clickTable[i])]["currHp"]+tonumber(_copyInfo["percentBase"])*tonumber(buffArry[3])/10000
			GodWeaponCopyData.setHpNum(newHp,clickTable[i])
		end
	elseif(buffType==3)then
		for i=1,table.count(clickTable)do
			local newRange = _copyInfo["va_pass"]["heroInfo"][tostring(clickTable[i])]["currRage"]+tonumber(buffArry[3])
			GodWeaponCopyData.setRangeNum(newRange,clickTable[i])
		end
	elseif(buffType==4)then
		for i=1,table.count(clickTable)do
			local newHp = _copyInfo["va_pass"]["heroInfo"][tostring(clickTable[i])]["currHp"]+tonumber(_copyInfo["percentBase"])*tonumber(buffArry[3])/10000
			GodWeaponCopyData.setHpNum(newHp,clickTable[i])
		end
	end
	starNumCache = tonumber(_copyInfo["star_star"])
	starNumCost = tonumber(_buffdbInfo.costStar)
	GodWeaponCopyData.setStarNum(starNumCache-starNumCost)
	GodWeaponCopyData.setBuffInfo(_itemNum,1)
	for k,v in pairs(_copyInfo["va_pass"]["buffShow"])do
		if(tonumber(v.status)==1)then
			_buyNum = _buyNum+1
		end
	end

	if(_buyNum==3)then
		if(_bgLayer~=nil)then
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/guanbi.mp3")
			_bgLayer:removeFromParentAndCleanup(true)
			_bgLayer = nil
			-- 神兵副本
  			require "script/ui/godweapon/godweaponcopy/GodWeaponCopyMainLayer"
			GodWeaponCopyMainLayer.nextSenceEffect()
			GodWeaponCopyMainLayer.refreshBottom()
		end
	else
		if(_bgLayer~= nil) then
			AudioUtil.playEffect("audio/effect/guanbi.mp3")
			_bgLayer:removeFromParentAndCleanup(true)
			_bgLayer = nil
			_copyInfo = GodWeaponCopyData.getCopyInfo()
			BuyBuffLayer.showLayer(_copyInfo["va_pass"]["buffShow"])
		end
	end

end

function dealWithData(pData)
	local pData = GodWeaponCopyData.getCopyInfo()

    require "script/ui/formation/FormationUtil"
    local real_formation = DataCache.getFormationInfo()

    local index = 0
    print("afklsdfkjdf")
    print_t(pData.va_pass.formation)
    print("afklsdfkjdf")
    print_t(pData.va_pass.bench)
    print("afklsdfkjdf")
    print_t(pData.va_pass.formation)
    print("afklsdfkjdf")
    if(not table.isEmpty(pData.va_pass.formation))then
        for h_id,v in pairs(pData.va_pass.formation) do
            index = index + 1
            if(tonumber(v)>0)then
                _inFormationInfo[index-1] = tonumber(v)
            elseif(FormationUtil.isOpenedByPosition(index-1))then
                _inFormationInfo[index-1] = 0
            else
                _inFormationInfo[index-1] = -1
            end
        end
        if(not table.isEmpty(pData.va_pass.bench))then
            -- for k,v in pairs(pData.va_pass.bench) do
            --     if(tonumber(v)~=0)then
            --         _inFormationInfo[tonumber(index+k-1)]=tonumber(v)
            --     end
            -- end
            for i=1,2 do
                -- if(tonumber(pData.va_pass.bench[i])~=0)then
                    _inFormationInfo[tonumber(index+i-1)] = tonumber(pData.va_pass.bench[i])
                -- end
            end
        end
    else
        local haveSame = false

        for f_pos, f_hid in pairs(real_formation) do
            if(tonumber(f_hid)>0)then
                _inFormationInfo[tonumber(f_pos)] = tonumber(f_hid)
            elseif(FormationUtil.isOpenedByPosition(f_pos))then
                _inFormationInfo[tonumber(f_pos)] = 0
            else
                _inFormationInfo[tonumber(f_pos)] = -1
            end
            index = index + 1
        end

        if(not table.isEmpty(pData.va_pass.bench))then
            for k,v in pairs(pData.va_pass.bench) do
                if(tonumber(v)~=0)then
                    for k,v in pairs(pData.va_pass.bench) do
                        _inFormationInfo[tonumber(k+1)]=pData.va_pass.bench[tonumber(k+1)]
                    end
                end
            end
        end

    end
    print("!!!!!!!!!!")
    print_t(_inFormationInfo)
    print("~~~~~~~~~~")
end

local function createUI()
	local _copyInfo = GodWeaponCopyData.getCopyInfo()

    dealWithData()
	-- 底层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-1)
    _bgLayer:addChild(menu,99)

    --  返回
    local _BackItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(213,73),GetLocalizeStringBy("key_8100"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _BackItem:setAnchorPoint(ccp(0.5,0))
    _BackItem:setPosition(_bgLayer:getContentSize().width*0.25, 8)
    _BackItem:setScale(MainScene.elementScale )
    _BackItem:registerScriptTapHandler(sureAction)
    menu:addChild(_BackItem,1)

    _BackItem:setPosition(ccp(_bgLayer:getContentSize().width*0.5, 8))

    local styleSprite = CCScale9Sprite:create("images/godweaponcopy/now.png")

    local fullRect = CCRectMake(0,0,187,30)
	local insetRect = CCRectMake(84,10,12,18)
	local bgSprite = CCScale9Sprite:create("images/godweaponcopy/blackred.png", fullRect, insetRect)
	bgSprite:setContentSize(CCSizeMake(g_winSize.width, g_winSize.height-8-styleSprite:getContentSize().height*MainScene.elementScale*0.5))
	_bgLayer:addChild(bgSprite,0,1)
	bgSprite:setAnchorPoint(ccp(0.5,1))

	local bottomLineSprite = CCSprite:create("images/godweaponcopy/21.png")
    bottomLineSprite:setScale(MainScene.elementScale )
	bottomLineSprite:setAnchorPoint(ccp(0.5,0))
	bgSprite:addChild(bottomLineSprite)
	bottomLineSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,0))


    styleSprite:setAnchorPoint(ccp(0.5,0.5))
    styleSprite:setScale(MainScene.elementScale )
    styleSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(styleSprite)

    bgSprite:setPosition(ccp(g_winSize.width*0.5, g_winSize.height-styleSprite:getContentSize().height*0.5))

    local leftFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    leftFlower:setScale(MainScene.elementScale )
    leftFlower:setAnchorPoint(ccp(1,0.5))
    leftFlower:setPosition(ccp(bgSprite:getContentSize().width*0.5-styleSprite:getContentSize().width*MainScene.elementScale*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(leftFlower)

    local rightFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    rightFlower:setScale(MainScene.elementScale )
    rightFlower:setScaleX(-1)
    rightFlower:setAnchorPoint(ccp(1,0.5))
    rightFlower:setPosition(ccp(bgSprite:getContentSize().width*0.5+styleSprite:getContentSize().width*MainScene.elementScale*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(rightFlower)

    local desLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_155"),g_sFontPangWa,25)
    desLabel:setVisible(false)
    desLabel:setScale(MainScene.elementScale )
    bgSprite:addChild(desLabel)
    desLabel:setAnchorPoint(ccp(0.5,0))
    desLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,bottomLineSprite:getContentSize().height*MainScene.elementScale))

    local _desBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _desBg:setScale(MainScene.elementScale )
    _desBg:setContentSize(CCSizeMake(581,114))
    _desBg:setPosition(bgSprite:getContentSize().width/2, desLabel:getPositionY()+desLabel:getContentSize().height*MainScene.elementScale)
    _desBg:setAnchorPoint(ccp(0.5,0))
    _desBg:setVisible(false)
    local index = 1
    if(not table.isEmpty(_copyInfo.va_pass.unionInfo))then
        for k,v in pairs(_copyInfo.va_pass.unionInfo)do
            local unionData = DB_Affix.getDataById(tonumber(k))
            local value = tonumber(v)/10000
            local str = unionData.displayName.."+"..value.."%"
            local unionLabel = CCLabelTTF:create(str,g_sFontPangWa,25)
            _desBg:addChild(unionLabel,1)
            unionLabel:setAnchorPoint(ccp(0.5,0.5))
            if(index<=2)then
                unionLabel:setPosition(ccp(_desBg:getContentSize().width*0.25+_desBg:getContentSize().width*0.5*(index-1),unionLabel:getContentSize().height*1.5))
            elseif(index>2 and index<=4)then
                unionLabel:setPosition(ccp(_desBg:getContentSize().width*0.25+_desBg:getContentSize().width*0.5*(index-3),unionLabel:getContentSize().height-15))
            elseif(index>4 and index<=6)then
                unionLabel:setPosition(ccp(_desBg:getContentSize().width*0.25+_desBg:getContentSize().width*0.5*(index-5),unionLabel:getContentSize().height*0.5-30))
            end
            index = index + 1
        end
    end
    bgSprite:addChild(_desBg,11,10)

    local buffAddSprite = CCScale9Sprite:create("images/godweaponcopy/buffadd.png")
    -- buffAddSprite:setScale(MainScene.elementScale )
    buffAddSprite:setAnchorPoint(ccp(0.5,0.5))
    buffAddSprite:setPosition(ccp(_desBg:getContentSize().width*0.5,_desBg:getContentSize().height))
    _desBg:addChild(buffAddSprite,0,10)

    --珍下武将
    for i=6,7 do
    	local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setScale(MainScene.elementScale )
        card:setAnchorPoint(ccp(0.5,0))
        card:setPosition(ccp(bgSprite:getContentSize().width*0.25+bgSprite:getContentSize().width*(i-6)*0.5,_desBg:getPositionY()+_desBg:getContentSize().height*MainScene.elementScale+buffAddSprite:getContentSize().height*0.5*MainScene.elementScale))
        bgSprite:addChild(card,0,i)

        local addItem = nil
        print("i===="..i)
        if(not table.isEmpty(_copyInfo.va_pass.bench) and _copyInfo.va_pass.bench[i-5]~=nil)then
        	print("_copyInfo.va_pass.bench[i-5]==",_copyInfo.va_pass.bench[i-5])
            if(tonumber(_copyInfo.va_pass.bench[i-5])~=0)then
                local heroSp = BattleCardUtil.getBattlePlayerCardImage(_copyInfo.va_pass.bench[i-5], false)
                -- heroSp:setNameVisible(false)
                -- addItem = CCMenuItemSprite:create(bodySprite,bodySprite)
                _heroCardsTable[i] = heroSp
                ----------------------------
				-- lv
				local hid = _copyInfo.va_pass.bench[i-5]
				local lvSp = CCSprite:create("images/common/lv.png")
				lvSp:setAnchorPoint(ccp(0,1))
				heroSp:addChild(lvSp)
				local heroAllInfo = HeroUtil.getHeroInfoByHid(hid)
				local heroBgSize = heroSp:getContentSize()
				-- 等级
				local levelLabel = CCRenderLabel:create( heroAllInfo.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
			    heroSp:addChild(levelLabel)
			    local sPositionX = (heroBgSize.width -levelLabel:getContentSize().width - lvSp:getContentSize().width)  * 0.5
			    lvSp:setPosition(ccp(sPositionX, -heroBgSize.height*0.15))
			    levelLabel:setPosition(ccp( sPositionX + lvSp:getContentSize().width, -heroBgSize.height*0.15))

			    require "db/DB_Heroes"
			    require "script/model/user/UserModel"

			 --    local heroName
			 --    if HeroModel.isNecessaryHero(heroAllInfo.htid) then
			 --    	local cutName = HeroUtil.getOriginalName(UserModel.getUserName())
			 --    	heroName = CCRenderLabel:create(cutName,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
			 --    else
			 --    	heroName = CCRenderLabel:create(DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).name,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
			 --    end
			 --    heroName:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).potential))

			 --    local envolveNum = CCRenderLabel:create("",g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
			 --    local heroModelInfo = HeroModel.getHeroByHid(heroAllInfo.hid)
			 --    if tonumber(heroModelInfo.evolve_level) ~= 0 then
			 --    	if tonumber(DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).potential) <= 5 then
			 --    		envolveNum:setString("+" .. heroModelInfo.evolve_level)
			 --    	else
			 --    		envolveNum:setString(heroModelInfo.evolve_level .. GetLocalizeStringBy("zzh_1159"))
			 --    	end
			 --    end
			 --    envolveNum:setColor(ccc3(0x76,0xfc,0x06))

				-- require "script/utils/BaseUI"
			 --    local underString = BaseUI.createHorizontalNode({heroName, envolveNum})
			 --    underString:setAnchorPoint(ccp(0.5,0))
			 --    underString:setPosition(ccp(heroBgSize.width/2,heroSp:getContentSize().height))
			 --    heroSp:addChild(underString,1000)
				----------------------------


				--设置血量
				--setCardHp
				local currHp = tonumber(_copyInfo["va_pass"]["heroInfo"][tostring(hid)]["currHp"])
				local totalHp = tonumber(_copyInfo["percentBase"])
				local scale = currHp/totalHp

				BattleCardUtil.setCardHp(heroSp,scale)

				--设置怒气
				--setCardAnger
				local curRange = tonumber(_copyInfo["va_pass"]["heroInfo"][tostring(hid)]["currRage"])
				BattleCardUtil.setCardAnger(heroSp,curRange)

				-- if tonumber(k) >= 4 then
				-- 	changeFormationSprite:addChild(heroSp, underZorder, hid)
				-- else
				-- 	changeFormationSprite:addChild(heroSp,upZorder,hid)
				-- end
				-- if(hid>=0)then
				-- 	_heroCardsTable[k] = heroSp
				-- end
				-- -- changeFormationSprite:setTag(tonumber(k))
				-- local heroBg = CCSprite:create("images/formation/changeformation/herobg.png")
				-- heroBg:setAnchorPoint(ccp(0.5,0.5))
				-- heroBg:setPosition(ccp(changeFormationSprite:getContentSize().width*xScale,changeFormationSprite:getContentSize().height*heroYScale[k]))
				-- changeFormationSprite:addChild(heroBg)
				-- heroBg:setTag(hid)

				if(currHp == 0)then
					local deadSprite = CCSprite:create("images/godweaponcopy/dead.png")
					heroSp:addChild(deadSprite,1000,hid)
					deadSprite:setAnchorPoint(ccp(0,1))
					deadSprite:setPosition(ccp(-30,heroSp:getContentSize().height+40))
				end
                heroSp:setAnchorPoint(ccp(0.5,0.5))
                card:addChild(heroSp,0,hid)
                heroSp:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            else
                local bodySprite = CCNode:create()
                -- addItem = CCMenuItemSprite:create(bodySprite,bodySprite)
                bodySprite:ignoreAnchorPointForPosition(false)
                bodySprite:setContentSize(CCSizeMake(128, 150))
                heroCardsTable[i] = bodySprite
                bodySprite:setAnchorPoint(ccp(0.5,0.5))
                card:addChild(bodySprite,0,i)
                bodySprite:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            end
        else
            -- local addMenu = CCMenu:create()
            -- addMenu:setTouchPriority(-551)
            -- card:addChild(addMenu,0,i)
            -- addMenu:setPosition(ccp(0,0))
            -- addItem = CCMenuItemImage:create("images/common/add.png","images/common/add.png")
            -- -- addItem:setScale(MainScene.elementScale )
            -- local arrActions_2 = CCArray:create()
            -- arrActions_2:addObject(CCFadeOut:create(1))
            -- arrActions_2:addObject(CCFadeIn:create(1))
            -- local sequence_2 = CCSequence:create(arrActions_2)
            -- local action_2 = CCRepeatForever:create(sequence_2)
            -- addItem:runAction(action_2)
            -- addItem:setAnchorPoint(ccp(0.5,0.5))
            -- addMenu:addChild(addItem,0,i)
            -- addItem:registerScriptTapHandler(addAction)
            -- addItem:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            -- print("_isAttackBefore"..tostring(_isAttackBefore))
        end


        -- addItem:setAnchorPoint(ccp(0.5,0.5))
        -- card:addChild(addItem,0,i)
        -- addItem:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
    end

    local downHeroSprite = CCSprite:create("images/godweaponcopy/downhero.png")
    downHeroSprite:setScale(MainScene.elementScale )

    local leftLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    leftLine:setScale(MainScene.elementScale )
    leftLine:setAnchorPoint(ccp(1,0.5))
    leftLine:setPosition(ccp(bgSprite:getContentSize().width*0.5-styleSprite:getContentSize().width*MainScene.elementScale*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*MainScene.elementScale+downHeroSprite:getContentSize().height*MainScene.elementScale*0.5+30))
    bgSprite:addChild(leftLine)

    local rightLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    local scale = tonumber(MainScene.elementScale)
    rightLine:setScale(-scale )
    -- rightLine:setScaleX(-1)
    rightLine:setAnchorPoint(ccp(1,0.5))
    rightLine:setPosition(ccp(bgSprite:getContentSize().width*0.5+styleSprite:getContentSize().width*MainScene.elementScale*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*MainScene.elementScale+downHeroSprite:getContentSize().height*MainScene.elementScale*0.5+30))
    bgSprite:addChild(rightLine)

    bgSprite:addChild(downHeroSprite)
    downHeroSprite:setAnchorPoint(ccp(0.5,0.5))
    downHeroSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*MainScene.elementScale+downHeroSprite:getContentSize().height*MainScene.elementScale*0.5+30))

    --当前阵型
    local index = 0
    local totalIndex = table.count(_inFormationInfo)
    print("0909090909")
    print_t(_inFormationInfo)
    print("0909090909")
    for i=0,5 do
        local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setScale(MainScene.elementScale )
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setAnchorPoint(ccp(0.5,0))
        bgSprite:addChild(card,0,i)
        index = index + 1
        if(index <= totalIndex)then
            local hid = _inFormationInfo[(i)]
            if(tonumber(hid)~=0)then
                local heroSp = BattleCardUtil.getBattlePlayerCardImage(hid, false)
                _heroCardsTable[i] = heroSp
                ----------------------------
				-- lv
				local lvSp = CCSprite:create("images/common/lv.png")
				lvSp:setAnchorPoint(ccp(0,1))
				heroSp:addChild(lvSp)
				local heroAllInfo = HeroUtil.getHeroInfoByHid(hid)
				local heroBgSize = heroSp:getContentSize()
				-- 等级
				local levelLabel = CCRenderLabel:create( heroAllInfo.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
			    heroSp:addChild(levelLabel)
			    local sPositionX = (heroBgSize.width -levelLabel:getContentSize().width - lvSp:getContentSize().width)  * 0.5
			    lvSp:setPosition(ccp(sPositionX, -heroBgSize.height*0.15))
			    levelLabel:setPosition(ccp( sPositionX + lvSp:getContentSize().width, -heroBgSize.height*0.15))

			    require "db/DB_Heroes"
			    require "script/model/user/UserModel"

			    local heroName
			    if HeroModel.isNecessaryHero(heroAllInfo.htid) then
			    	local cutName = HeroUtil.getOriginalName(UserModel.getUserName())
			    	heroName = CCRenderLabel:create(cutName,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
			    else
			    	heroName = CCRenderLabel:create(DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).name,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
			    end
			    heroName:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).potential))

			    local envolveNum = CCRenderLabel:create("",g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
			    local heroModelInfo = HeroModel.getHeroByHid(heroAllInfo.hid)
			    if tonumber(heroModelInfo.evolve_level) ~= 0 then
			    	if tonumber(DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).potential) <= 5 then
			    		envolveNum:setString("+" .. heroModelInfo.evolve_level)
			    	else
			    		envolveNum:setString(heroModelInfo.evolve_level .. GetLocalizeStringBy("zzh_1159"))
			    	end
			    end
			    envolveNum:setColor(ccc3(0x76,0xfc,0x06))

				-- require "script/utils/BaseUI"
			 --    local underString = BaseUI.createHorizontalNode({heroName, envolveNum})
			 --    underString:setAnchorPoint(ccp(0.5,0))
			 --    underString:setPosition(ccp(heroBgSize.width/2,heroSp:getContentSize().height))
			 --    heroSp:addChild(underString,1000)
				----------------------------


				--设置血量
				--setCardHp
				local currHp = tonumber(_copyInfo["va_pass"]["heroInfo"][tostring(hid)]["currHp"])
				local totalHp = tonumber(_copyInfo["percentBase"])
				local scale = currHp/totalHp

				BattleCardUtil.setCardHp(heroSp,scale)

				--设置怒气
				--setCardAnger
				local curRange = tonumber(_copyInfo["va_pass"]["heroInfo"][tostring(hid)]["currRage"])
				BattleCardUtil.setCardAnger(heroSp,curRange)

				-- if tonumber(k) >= 4 then
				-- 	changeFormationSprite:addChild(heroSp, underZorder, hid)
				-- else
				-- 	changeFormationSprite:addChild(heroSp,upZorder,hid)
				-- end
				-- if(hid>=0)then
				-- 	_heroCardsTable[k] = heroSp
				-- end
				-- -- changeFormationSprite:setTag(tonumber(k))
				-- local heroBg = CCSprite:create("images/formation/changeformation/herobg.png")
				-- heroBg:setAnchorPoint(ccp(0.5,0.5))
				-- heroBg:setPosition(ccp(changeFormationSprite:getContentSize().width*xScale,changeFormationSprite:getContentSize().height*heroYScale[k]))
				-- changeFormationSprite:addChild(heroBg)
				-- heroBg:setTag(hid)

				if(currHp == 0)then
					local deadSprite = CCSprite:create("images/godweaponcopy/dead.png")
					heroSp:addChild(deadSprite,1000,hid)
					deadSprite:setAnchorPoint(ccp(0,1))
					deadSprite:setPosition(ccp(-30,heroSp:getContentSize().height+40))
				end
                heroSp:setAnchorPoint(ccp(0.5, 0.5))
                card:addChild(heroSp,0,hid)
                heroSp:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            else
                local heroSp = CCNode:create()
                heroSp:ignoreAnchorPointForPosition(false)
                heroSp:setContentSize(CCSizeMake(128, 150))
                _heroCardsTable[i] = heroSp
                heroSp:setAnchorPoint(ccp(0.5, 0.5))
                card:addChild(heroSp,0,i)
                heroSp:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            end
        end
        if(i<3)then
            card:setPosition(ccp(bgSprite:getContentSize().width*0.25+bgSprite:getContentSize().width*(i)*0.25,rightLine:getPositionY()+downHeroSprite:getContentSize().height*MainScene.elementScale*0.5+card:getContentSize().height*MainScene.elementScale+160))
        else
            card:setPosition(ccp(bgSprite:getContentSize().width*0.25+bgSprite:getContentSize().width*(i-3)*0.25,rightLine:getPositionY()+downHeroSprite:getContentSize().height*MainScene.elementScale*0.5+70))
        end
    end

    -- local midDesLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_156"),g_sFontPangWa,18)
    -- midDesLabel:setScale(MainScene.elementScale )
    -- midDesLabel:setColor(ccc3(0xff,0xf6,0x00))
    -- bgSprite:addChild(midDesLabel)
    -- midDesLabel:setAnchorPoint(ccp(0.5,0))
    -- midDesLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,rightLine:getPositionY()+downHeroSprite:getContentSize().height*MainScene.elementScale*0.5+20))
end

function createLayer( ... )
	-- body
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	dealWithData(_copyInfo["va_pass"]["heroInfo"])

    createUI()

	return _bgLayer
end

function showLayer(touch_priority,zorder,pNum)
	init()

	_priority = touch_priority or (-550)
	_zorder	= zorder or 999
	_itemNum = pNum
	_copyInfo = GodWeaponCopyData.getCopyInfo()

	local buffNum = tonumber(_copyInfo["va_pass"]["buffShow"][tonumber(pNum)]["buff"])
	_buffInfo = DB_Overcome_buff.getDataById(tonumber(buffNum))
	local buffData = _buffInfo.buff
	local buffArry = string.split(_buffInfo.buff, "|")
	_maxNum = buffArry[2]

	createLayer()

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zorder)
end
