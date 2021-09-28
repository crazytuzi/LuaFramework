-- FileName: LittleFriendOne.lua 
-- Author: licong 
-- Date: 14-6-23 
-- Purpose: 小伙伴羁绊数量界面 


module("LittleFriendOne", package.seeall)

local _bgNode 					= nil
local _oldLinkNumArr 			= {}  	-- 旧的点亮羁绊个数的lable数组，{hid = num}
local _oldTotalUseNum 			= nil 	-- 旧的
local _newTotalUseNum 			= nil 	-- 新点亮总数
local isNeedSave 				= false
local function init( ... )
	_bgNode 				= nil
	_newTotalUseNum 		= 0
end

-- 初始化界面
local function initLittleFriendOneLayer( ... )
	local str = GetLocalizeStringBy("lic_1088")
	local title_font = CCRenderLabel:create( str, g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	title_font:setAnchorPoint(ccp(0,1))
	title_font:setColor(ccc3(0xff, 0xff, 0xff))
	title_font:setPosition(ccp(20,_bgNode:getContentSize().height-10))
	_bgNode:addChild(title_font,100)

	-- 得到阵上武将信息 创建全身像
	local formationData = LittleFriendData.getHeroInFormationTwo()
	print("阵容信息：")
	print_t(formationData)
	local posX = {0.2,0.5,0.8,0.2,0.5,0.8}
	local posY = {0.78,0.78,0.78,0.38,0.38,0.38}
	if( table.isEmpty(_oldLinkNumArr) )then
		isNeedSave = true
	end
	for i=1,6 do
		local bg = CCSprite:create("images/forge/hero_bg.png")
		bg:setAnchorPoint(ccp(0.5,0.5))
		bg:setPosition(ccp(_bgNode:getContentSize().width*posX[i],_bgNode:getContentSize().height*posY[i]))
		_bgNode:addChild(bg)
		bg:setScale(0.8)
		-- 创建全身像
		if(formationData[i] > 0)then
			-- 英雄信息
			local hid = formationData[i]
			local heroAllInfo = HeroUtil.getHeroInfoByHid(hid)
			-- print("heroAllInfo")
			-- print_t(heroAllInfo)
			local dressId = nil
			if HeroModel.isNecessaryHero(heroAllInfo.htid) then
				dressId = UserModel.getDressIdByPos("1")
			end
			require "script/battle/BattleCardUtil"
			local cardIcon = BattleCardUtil.getFormationPlayerCard(formationData[i], false,heroAllInfo.htid,dressId )
			cardIcon:setAnchorPoint(ccp(0.5, 0))
			cardIcon:setPosition(ccp(bg:getContentSize().width*0.5, 0))
			bg:addChild(cardIcon)

			-- 名字
			local hero_name = nil
			if( HeroModel.isNecessaryHeroByHid(formationData[i]) )then
				-- print("主角hid:",formationData[i])
				hero_name = UserModel.getUserName()
			else
				require "script/ui/redcarddestiny/RedCardDestinyData"
				hero_name = HeroModel.getHeroName(heroAllInfo)
			end
			local nameColor = HeroPublicLua.getCCColorByStarLevel(heroAllInfo.localInfo.potential)
			local name_font = CCRenderLabel:create( hero_name, g_sFontPangWa, 18, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
			name_font:setColor(nameColor)
			name_font:setAnchorPoint(ccp(0.5,1))
			name_font:setPosition(ccp(bg:getPositionX(),bg:getPositionY()-bg:getContentSize().height*0.5*bg:getScale()-2))
			_bgNode:addChild(name_font,100)

			-- 进阶数
			local evolveDes = " "
			if heroAllInfo.evolve_level then
		    	if tonumber(heroAllInfo.localInfo.potential) <= 5 then 
		    		evolveDes = "+" .. heroAllInfo.evolve_level
		    	else
		    		evolveDes = heroAllInfo.evolve_level .. GetLocalizeStringBy("zzh_1159")
		    	end
		    end
			local evolve_font = CCRenderLabel:create(evolveDes, g_sFontPangWa, 18, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
			evolve_font:setColor(ccc3(0x00,0xff,0x18))
			evolve_font:setAnchorPoint(ccp(0.5,1))
			evolve_font:setPosition(ccp(name_font:getPositionX(),name_font:getPositionY()-name_font:getContentSize().height-2))
			_bgNode:addChild(evolve_font,100)

			-- 点亮羁绊数量
			local useNum = FormationUtil.getHeroLinkUseNum(formationData[i])
			local linkNumFont = CCRenderLabel:create(useNum,g_sFontName,18,1, ccc3(0x00, 0x00, 0x00), type_stroke)
			linkNumFont:setAnchorPoint(ccp(1,1))
			linkNumFont:setColor(ccc3(0x00,0xff,0x18))
			linkNumFont:setPosition(ccp(evolve_font:getPositionX()-10,evolve_font:getPositionY()-evolve_font:getContentSize().height-2))
			_bgNode:addChild(linkNumFont,100)

			-- 保存点亮羁绊数量
			if(isNeedSave)then
				-- 只记一次
				_oldLinkNumArr[i] = {}
				_oldLinkNumArr[i].hid = formationData[i]
				_oldLinkNumArr[i].num = useNum
			else
				if( _oldLinkNumArr[i].hid ==  formationData[i] )then
					local arrow = nil
					if(_oldLinkNumArr[i].num > useNum)then
						arrow = "images/item/equipFixed/down.png"
					elseif(_oldLinkNumArr[i].num < useNum)then
						arrow = "images/item/equipFixed/up.png"
					else
					end
					if(arrow ~= nil)then
						local arrowSp = CCSprite:create(arrow)
						arrowSp:setAnchorPoint(ccp(1,0.5))
						arrowSp:setPosition(ccp(linkNumFont:getPositionX()-linkNumFont:getContentSize().width-2,linkNumFont:getPositionY()-5))
						_bgNode:addChild(arrowSp,100)
						local function fnEndCallback()
			                arrowSp:removeFromParentAndCleanup(true)
			                arrowSp = nil
			                _oldLinkNumArr[i].num = useNum
			            end 
			            local spActionArr = CCArray:create()
			            spActionArr:addObject(CCDelayTime:create(0.5))
			            spActionArr:addObject(CCBlink:create(4, 2))
			            spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
			            arrowSp:runAction(CCSequence:create(spActionArr))
					end
				else
					_oldLinkNumArr[i] = {}
					_oldLinkNumArr[i].hid = formationData[i]
					_oldLinkNumArr[i].num = useNum
				end
			end
			_newTotalUseNum = _newTotalUseNum + useNum
			-- 羁绊
			local font1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1091"),g_sFontName,18,1, ccc3(0x00, 0x00, 0x00), type_stroke)
			font1:setAnchorPoint(ccp(0,1))
			font1:setColor(ccc3(0xff,0xff,0xff))
			font1:setPosition(ccp(evolve_font:getPositionX()-10,evolve_font:getPositionY()-evolve_font:getContentSize().height-2))
			_bgNode:addChild(font1,100)
		else
			_oldLinkNumArr[i] = {}
			_oldLinkNumArr[i].hid = formationData[i]
			_oldLinkNumArr[i].num = 0
		end
	end
	-- 只保存一次
	isNeedSave = false
	-- 总量
	local str = GetLocalizeStringBy("lic_1089")
	local totalFont = CCRenderLabel:create( str, g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	totalFont:setAnchorPoint(ccp(0,0))
	totalFont:setColor(ccc3(0xff, 0xff, 0xff))
	totalFont:setPosition(ccp(23,10))
	_bgNode:addChild(totalFont,100)
	-- 总数
	local totalNumFont = CCRenderLabel:create( _newTotalUseNum, g_sFontPangWa, 23,1, ccc3(0x00, 0x00, 0x00), type_stroke)
	totalNumFont:setAnchorPoint(ccp(0,0))
	totalNumFont:setColor(ccc3(0x00, 0xff, 0x18))
	totalNumFont:setPosition(ccp(totalFont:getPositionX()+totalFont:getContentSize().width,totalFont:getPositionY()))
	_bgNode:addChild(totalNumFont,100)

	-- 个
	local font = CCRenderLabel:create( GetLocalizeStringBy("lic_1090"), g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	font:setAnchorPoint(ccp(0,0))
	font:setColor(ccc3(0xff, 0xff, 0xff))
	font:setPosition(ccp(totalNumFont:getPositionX()+totalNumFont:getContentSize().width,totalFont:getPositionY()))
	_bgNode:addChild(font,100)

	-- 箭头
	if( _oldTotalUseNum == nil )then
		-- 只记一次
		_oldTotalUseNum = _newTotalUseNum
	else
		local arrow = nil
		if(_oldTotalUseNum > _newTotalUseNum)then
			arrow = "images/item/equipFixed/down.png"
		elseif(_oldTotalUseNum < _newTotalUseNum)then
			arrow = "images/item/equipFixed/up.png"
		else
		end
		if(arrow ~= nil)then
			local arrowSp = CCSprite:create(arrow)
			arrowSp:setAnchorPoint(ccp(0,0))
			arrowSp:setPosition(ccp(font:getPositionX()+font:getContentSize().width,font:getPositionY()-4))
			_bgNode:addChild(arrowSp,100)
			local function fnEndCallback()
                arrowSp:removeFromParentAndCleanup(true)
                arrowSp = nil
                _oldTotalUseNum = _newTotalUseNum
            end 
            local spActionArr = CCArray:create()
            spActionArr:addObject(CCDelayTime:create(0.5))
            spActionArr:addObject(CCBlink:create(4, 2))
            spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
            arrowSp:runAction(CCSequence:create(spActionArr))
		end
	end

end

-- 创建羁绊数量显示界面
function createLittleFriendOne( ... )
	init()
	_bgNode = CCNode:create()
	-- _bgNode = CCLayerColor:create(ccc4(0,255,0,111))
	-- _bgNode:ignoreAnchorPointForPosition(false) 
	_bgNode:setContentSize(CCSizeMake(358,474))

	-- 初始化的界面
	initLittleFriendOneLayer()
	return _bgNode
end









































