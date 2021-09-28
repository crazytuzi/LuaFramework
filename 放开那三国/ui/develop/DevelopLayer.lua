-- Filename: DevelopLayer.lua
-- Author: zhangqiang
-- Date: 2014-09-09
-- Purpose: 武将进化界面(橙卡)

module("DevelopLayer", package.seeall)
require "script/ui/develop/DevelopData"
require "script/ui/develop/DevelopService"

local kAdaptiveSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
local kScrollBgSize = CCSizeMake(249, kAdaptiveSize.height-648)
local kScrollSize = CCSizeMake(249, kScrollBgSize.height-20)

kOldLayerTag = {kHeroTag = 1, kFormationTag = 2}

local kMainLayerPriority = -550
local kMenuPriority = -555

local _mainLayer = nil
local _uiNode = nil
local _cardTable = nil
local _attrTable = nil
local _silverTable = nil
local _btnTable = nil
local _oldLayerTag = nil
local _ksTagOrange = 1
local _ksTagRed = 2
local _titleBar = nil --顶端切换橙卡和红卡的菜单
local _curHeroHid = nil
--local _curSelectTag = nil --当前是橙卡进化还是红卡进化
--[[
	@desc :	初始化
	@param:	
	@ret  :	
--]]
function init( p_hid, p_oldLayerTag)
	DevelopData.initDevelopData( p_hid )
	_curHeroHid = p_hid
	_curHeroInfo = HeroModel.getHeroByHid(_curHeroHid)
	_mainLayer = nil
	_uiNode = nil
	_cardTable = {}
	_attrTable = {}
	_silverTable = nil
	_btnTable = {}
	_titleBar = nil
	if p_oldLayerTag ~= nil then
		_oldLayerTag = p_oldLayerTag
	end
	--_curSelectTag = p_selectTag or _ksTagOrange
end

--[[
	@desc :	创建紫卡
	@param:	
	@ret  :	
--]]
function createVioletCard( ... )
	local violetCard = CCSprite:create("images/develop/violet_card.png")
	local size = violetCard:getContentSize()
	
	local menu = CCMenu:create()
	menu:setTouchPriority(kMenuPriority)
	menu:setPosition(0,0)
	violetCard:addChild(menu)

	--添加武将按钮"+"
	local plusBtn = CCMenuItemImage:create("images/pet/pet/plus_n.png","images/pet/pet/plus_n.png")
	plusBtn:registerScriptTapHandler(tapPlusBtnCb)
	plusBtn:setAnchorPoint(ccp(0.5,0.5))
	plusBtn:setPosition(size.width*0.5,size.height*0.5)
	menu:addChild(plusBtn)
	local actionSeq = CCSequence:createWithTwoActions(CCFadeOut:create(1),CCFadeIn:create(1))
	plusBtn:runAction(CCRepeatForever:create(actionSeq))

	--"请选择武将"
	local chooseDescSprite = CCSprite:create("images/develop/choose_label.png")
	chooseDescSprite:setAnchorPoint(ccp(0.5,0))
	chooseDescSprite:setPosition(size.width*0.5, 46)
	violetCard:addChild(chooseDescSprite)

	return violetCard
end

--[[
	@desc :	创建橙卡
	@param:	
	@ret  :	
--]]
function createOrangeCard( ... )
	local orangeCard = CCSprite:create("images/develop/orange_card.png")
	local size = orangeCard:getContentSize()

	local question = CCSprite:create("images/develop/question_small.png")
	question:setAnchorPoint(ccp(0.5,0.5))
	question:setPosition(size.width*0.5, size.height*0.5)
	orangeCard:addChild(question)

	return orangeCard
end

--[[
	@desc :	创建左边的卡牌
	@param:	
	@ret  :	
--]]
function createLeftCard( p_htid, p_dressId)
	local leftCard = nil
	if p_htid ~= nil then
		require "script/ui/hero/HeroPublicCC"
		leftCard = HeroPublicCC.createSpriteCardShow(p_htid, p_dressId)
		leftCard:setScale(0.58)
	else
		leftCard = createVioletCard()
	end

	return leftCard
end

--[[
	@desc :	创建右边的卡牌
	@param:	
	@ret  :	
--]]
function createRightCard( p_htid, p_dressId )
	local rightCard = nil
	if p_htid ~= nil then
		require "script/ui/hero/HeroPublicCC"
		rightCard = HeroPublicCC.createSpriteCardShow(p_htid, p_dressId)
		rightCard:setScale(0.58)
	else
		rightCard = createOrangeCard()
	end

	return rightCard
end

--[[
	@desc :	创建属性面板
	@param:	p_dataTable 由方法DevelopData.getCurHeroInfo()和DevelopData.getCurDevelopInfo()获得
			p_state int 是否显示底部描述(只有值为2时才显示底部描述) 
	@ret  :	
--]]
function createAttrPanel(p_dataTable, p_state)
	p_state =tonumber(p_state)
	local labelColor = p_state == 2 and ccc3(0x00,0xff,0x18) or ccc3(0xff,0xff,0xff)
	local scrollBg = CCScale9Sprite:create("images/develop/scroll_bg.png")
	scrollBg:setPreferredSize(kScrollBgSize)

	local scroll = CCScrollView:create()
	scroll:setViewSize(kScrollSize)
	scroll:setDirection(kCCScrollViewDirectionVertical)
	scroll:setTouchPriority(kMenuPriority)
	scroll:setBounceable(true)
	scroll:ignoreAnchorPointForPosition(false)
	scroll:setAnchorPoint(ccp(0.5,0.5))
	scroll:setPosition(kScrollBgSize.width*0.5, kScrollBgSize.height*0.5)
	scrollBg:addChild(scroll)

	--上下滚动箭头
	local arrowData = {
		[1] = {"images/common/arrow_up_h.png", ccp(0.5,1), ccp(kScrollSize.width-30,kScrollSize.height+12)},
		[2] = {"images/common/arrow_down_h.png", ccp(0.5,0), ccp(kScrollSize.width-30,12)},
	}
	local arrows = {}
	for i = 1, 2 do
		arrows[i] = CCSprite:create(arrowData[i][1])
		arrows[i]:setAnchorPoint(arrowData[i][2])
		arrows[i]:setPosition(arrowData[i][3])
		arrows[i]:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(1),CCFadeIn:create(1))))
		arrows[i]:setVisible(false)
		scrollBg:addChild(arrows[i])
	end

	local updateArrow = function ()
		local offset =  scroll:getContentSize().height+ scroll:getContentOffset().y- scroll:getViewSize().height
		if(arrows[1]~= nil )  then
			if(offset>1) then
				arrows[1]:setVisible(true)
			else
				arrows[1]:setVisible(false)
			end
		end
		if(arrows[2] ~= nil) then
			if( scroll:getContentOffset().y <-1) then
				arrows[2]:setVisible(true)
			else
				arrows[2]:setVisible(false)
			end
		end
	end
	schedule(scrollBg, updateArrow, 1)

	local containerSize = CCSizeMake(kScrollSize.width, 0)
	local container = CCLayer:create()
	container:setContentSize(containerSize)

	-- local bottomDesc = {GetLocalizeStringBy("zz_90"), GetLocalizeStringBy("zz_87")}
	-- if p_dataTable ~= nil and p_state == 2 then
	-- 	for k,v in ipairs(bottomDesc) do
	-- 		local label = CCLabelTTF:create(v, g_sFontName, 18)
	-- 		label:setColor(labelColor)
	-- 		label:setAnchorPoint(ccp(0.5,0))
	-- 		label:setPosition(kScrollSize.width*0.5,containerSize.height)
	-- 		container:addChild(label)
	-- 		containerSize.height = containerSize.height + label:getContentSize().height + 5
	-- 	end
	-- end
	-- containerSize.height = containerSize.height + 10

	--怒气技能和普通技能
	local angerSkillDesc = p_dataTable == nil and "?" or p_dataTable.angerSkill.skillName
	local normalSkillDesc = p_dataTable == nil and "?" or p_dataTable.normalSkill.skillName
	local fontName = p_dataTable == nil and g_sFontPangWa or g_sFontName
	local skillData = {
		[1] = {angerSkillDesc, "images/hero/info/anger.png", GetLocalizeStringBy("zz_54")},
		[2] = {normalSkillDesc, "images/hero/info/normal.png", GetLocalizeStringBy("zz_78")},
	}
	require "script/ui/replaceSkill/CreateUI"
	for i = 1,2 do
		local dimensions = CreateUI.getStringDimensions(skillData[i][1], 10, 18)
		local descLabel = CCLabelTTF:create(skillData[i][1], fontName, 18)
		descLabel:setColor(labelColor)
		descLabel:setDimensions(dimensions)
		descLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
		descLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
		descLabel:setAnchorPoint(ccp(0,0))
		descLabel:setPosition(70, containerSize.height)
		container:addChild(descLabel)

		local iconBg = CCSprite:create(skillData[i][2])
		local size = iconBg:getContentSize()
		iconBg:setAnchorPoint(ccp(0,0.5))
		iconBg:setPosition(12, containerSize.height+dimensions.height-9)
		container:addChild(iconBg)

		local iconLabel = CCLabelTTF:create(skillData[i][3], g_sFontName, 25)
		iconLabel:setColor(ccc3(0xff,0xff,0xff))
		iconLabel:setAnchorPoint(ccp(0.5,0.5))
		iconLabel:setPosition(size.width*0.5, size.height*0.5)
		iconBg:addChild(iconLabel)

		containerSize.height = containerSize.height + dimensions.height + 18
	end

	--技能标题
	local skillTitleBg = CCSprite:create("images/hero/info/title_bg.png")
	local size = skillTitleBg:getContentSize()
	skillTitleBg:setAnchorPoint(ccp(0,0))
	skillTitleBg:setPosition(0,containerSize.height)
	container:addChild(skillTitleBg)
	containerSize.height = containerSize.height + size.height + 10

	local skillTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_79"), g_sFontName,25)
	skillTitleLabel:setColor(ccc3(0x00,0x00,0x00))
	skillTitleLabel:setAnchorPoint(ccp(0.5,0.5))
	skillTitleLabel:setPosition(size.width*0.5, size.height*0.5)
	skillTitleBg:addChild(skillTitleLabel)

	--"智慧","武力","统帅","资质"
	local intelligence = p_dataTable == nil and "?" or p_dataTable.intelligence
	local strength = p_dataTable == nil and "?" or p_dataTable.strength
	local command = p_dataTable == nil and "?" or p_dataTable.command
	local aptitude = p_dataTable == nil and "?" or p_dataTable.aptitude
	local attrData = {
		[1] = {intelligence, GetLocalizeStringBy("zz_80"),},
		[2] = {strength, GetLocalizeStringBy("zz_81"),},
		[3] = {command, GetLocalizeStringBy("zz_82"),},
		[4] = {aptitude, 0,},
	}
	for i = 1,4 do
		local descLabel = CCRenderLabel:create(attrData[i][1], g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
		descLabel:setColor(labelColor)
		descLabel:setAnchorPoint(ccp(0,0))
		descLabel:setPosition(88, containerSize.height)
		container:addChild(descLabel)

		local attrNameLabel = nil
		if attrData[i][2] == 0 then
			attrNameLabel = CCSprite:create("images/hero/potential.png")
			attrNameLabel:setScale(0.85)
		else
			attrNameLabel = CCRenderLabel:create(attrData[i][2], g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
			attrNameLabel:setColor(ccc3(0xff,0xff,0xff))
		end
		attrNameLabel:setAnchorPoint(ccp(0,0))
		attrNameLabel:setPosition(15, containerSize.height)
		container:addChild(attrNameLabel)

		containerSize.height = containerSize.height + descLabel:getContentSize().height + 8
	end

	--武将名字背景
	local heroNameBg = CCSprite:create("images/common/red_line.png")
	local heroNameBgSize = heroNameBg:getContentSize()
	heroNameBg:setScale(0.8)
	heroNameBg:setAnchorPoint(ccp(0.5,0))
	heroNameBg:setPosition(containerSize.width*0.5,containerSize.height)
	container:addChild(heroNameBg)
	containerSize.height = containerSize.height + heroNameBgSize.height

	--武将名字和进阶等级
	local heroName = ""
	local evolveLevel = ""
	local nameColor = ccc3(0x00,0xe4,0xff)
	if p_dataTable ~= nil then
		heroName = p_dataTable.heroName .. "   "
		evolveLevel = p_state == 2 and GetLocalizeStringBy("zz_99",p_dataTable.evolveLevel) or "+" .. p_dataTable.evolveLevel
		nameColor = HeroPublicLua.getCCColorByStarLevel(p_dataTable.star_lv)
	end
	local nameData = {
		[1] = {desc=heroName, color=nameColor},
		[2] = {desc=evolveLevel, color=ccc3(0x00,0xff,0x18)},
	}
	local nameTable = createLabel(nameData)
	nameTable.parent:setAnchorPoint(ccp(0.5,0.5))
	nameTable.parent:setPosition(heroNameBgSize.width*0.5, heroNameBgSize.height*0.5)
	nameTable.parent:setScale(1/0.8)
	heroNameBg:addChild(nameTable.parent)

	container:setContentSize(containerSize)
	scroll:setContainer(container)
	scroll:setContentOffset(ccp(0, kScrollSize.height-containerSize.height))

	return scrollBg
end

--[[
	@desc :	创建一行拥有不同颜色的标签
	@param:	p_table 标签内容
	{
		{
			desc = string
			color = ccc3()
			font = string
		}
	}
	@ret :	标签节点
	{
		parent = CCNode
		children = {
			CCRenderLabel1,
			CCRenderLabel2,
			...
		}
	}
--]]
function createLabel( p_table )
	local labelTable = {parent = CCNode:create(), children = {}}
	-- print("createLabel")
	-- print_t(p_table)

	local node = labelTable.parent
	local contentSize = CCSizeMake(0,21)
	for _,v in ipairs(p_table) do
		local font = v.font or g_sFontPangWa
		local label = CCRenderLabel:create(v.desc, font, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
		label:setColor(v.color)
		label:setAnchorPoint(ccp(0,0))
		label:setPosition(contentSize.width,0)
		node:addChild(label)
		contentSize.width = contentSize.width + label:getContentSize().width
		table.insert(labelTable.children, label)
	end
	node:setContentSize(contentSize)

	return labelTable
end

--[[
	@desc :	创建资源消耗列表
	@param:	
	@ret  :	
--]]
function createTable( ... )
	--表格背景
	local tableBg = CCScale9Sprite:create("images/star/intimate/bottom9s.png")
	local tableBgSize = CCSizeMake(634,136)
	tableBg:setPreferredSize(tableBgSize)

	--左右箭头
	local arrowData = {
		[1] = {"images/pet/petfeed/btn_left.png", ccp(1,0.5), ccp(55, tableBgSize.height*0.5)},
		[2] = {"images/pet/petfeed/btn_right.png", ccp(0,0.5), ccp(tableBgSize.width-55, tableBgSize.height*0.5)},
	}
	for i = 1,2 do
		local arrow = CCSprite:create(arrowData[i][1])
		arrow:setAnchorPoint(arrowData[i][2])
		arrow:setPosition(arrowData[i][3])
		tableBg:addChild(arrow)
	end

	--表格
	local costResource = DevelopData.getCurCostResource()
	if costResource ~= nil then
		local tableView = CreateUI.createTableView(1, CCSizeMake(tableBgSize.width-130,115), CCSizeMake(100,115), #costResource.cost, createCell)
		tableView:ignoreAnchorPointForPosition(false)
		tableView:setTouchPriority(kMenuPriority-20)
		tableView:setAnchorPoint(ccp(0.5,0.5))
		tableView:setPosition(tableBgSize.width*0.5, tableBgSize.height*0.5)
		tableBg:addChild(tableView)
	end

	return tableBg
end

--[[
	@desc :	创建各个消耗资源的图标
	@param:	
	@ret  :	
--]]
function createIcon( p_index )
	local data = DevelopData.getCurCostResource().cost[p_index]

	local icon = nil
	if data.type == DevelopData.kItemTag then
		icon = ItemSprite.getItemSpriteById(data.id,nil,nil,nil,kMenuPriority-10, nil, kMenuPriority-30)
	elseif data.type == DevelopData.kHeroTag then
		--icon = HeroUtil.getHeroIconByHTID(data.id)
		icon = ItemSprite.getHeroIconItemByhtid(data.id, kMenuPriority-10, 1000, kMenuPriority-30)
	else

	end
	local size = icon:getContentSize()

	local numLabel = CCRenderLabel:create(data.hasNum .. "/" .. data.needNum, g_sFontName, 18, 1 , ccc3(0x00,0x00,0x00), type_shadow)
	local labelColor = data.hasNum >= data.needNum and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
	numLabel:setColor(labelColor)
	numLabel:setAnchorPoint(ccp(1,0))
	numLabel:setPosition(size.width, 0)
	icon:addChild(numLabel)

	local nameLabel = CCRenderLabel:create(data.name, g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
	nameLabel:setColor(data.nameColor)
	nameLabel:setAnchorPoint(ccp(0.5,1))
	nameLabel:setPosition(size.width*0.5,0)
	icon:addChild(nameLabel)

	return icon
end

--[[
	@desc :	创建表格单元
	@param:	
	@ret  :	
--]]
function createCell( p_index )
	local cell = CCTableViewCell:create()

	local icon = createIcon(p_index)
	icon:setAnchorPoint(ccp(0,0))
	icon:setPosition(0,20)
	cell:addChild(icon)

	return cell
end

--[[
	@desc : 创建标签:消耗银币
	@param:	
	@ret  :	
--]]
function createCostSliverLabel( ... )
	local labelTable = {
		[1] = {desc=GetLocalizeStringBy("zz_89"), color=ccc3(0xff,0xff,0xff), font=g_sFontName},
		[2] = {desc="000", color=ccc3(0xff,0xff,0xff), font=g_sFontName},
	}
	local nodeTable = createLabel(labelTable)

	local silverIcon = CCSprite:create("images/common/coin_silver.png")
	silverIcon:setAnchorPoint(ccp(0,0.5))
	silverIcon:setPosition(nodeTable.children[1]:getContentSize().width, 10)
	nodeTable.parent:addChild(silverIcon)

	local positionX = nodeTable.children[2]:getPositionX()
	nodeTable.children[2]:setPositionX(positionX+silverIcon:getContentSize().width)

	return nodeTable
end

--[[
	@desc :	创建UI
	@param:	
	@ret  :	
--]]
function createUI( ... )
	local node = CCNode:create()
	node:setContentSize(kAdaptiveSize)

	--武将进化
	local developDescSprite = CCSprite:create("images/develop/develop_label.png")
	developDescSprite:setAnchorPoint(ccp(0,0))
	developDescSprite:setPosition(15, kAdaptiveSize.height-67)
	node:addChild(developDescSprite,1)

	local menu = CCMenu:create()
	menu:setTouchPriority(kMenuPriority)
	menu:setPosition(0,0)
	node:addChild(menu,1)

	--预览按钮
	local previewBtn = CCMenuItemImage:create("images/develop/preview_btn_n.png", "images/develop/preview_btn_h.png")
	previewBtn:registerScriptTapHandler(tapPreviewBtnCb)
	previewBtn:setAnchorPoint(ccp(0,0))
	previewBtn:setPosition(491, kAdaptiveSize.height-87)
	menu:addChild(previewBtn)
	--消耗预览
	local costBtn = CCMenuItemImage:create("images/develop/cost_btn_n.png", "images/develop/cost_btn_h.png")
	costBtn:registerScriptTapHandler(tapCostBtnCb)
	costBtn:setAnchorPoint(ccp(1,0))
	costBtn:setPosition(471, kAdaptiveSize.height-87)
	menu:addChild(costBtn)
	----------------
	-- --创建标签
 --    require "script/libs/LuaCCMenuItem"
    
	-- local image_n = "images/active/rob/btn_title_n.png"
	-- local image_h = "images/active/rob/btn_title_h.png"

	-- local rect_full_n 	= CCRectMake(0,0,184,66)
	-- local rect_inset_n 	= CCRectMake(25,20,3,3)

	-- local rect_full_h 	= CCRectMake(0,0,184,66)
	-- local rect_inset_h 	= CCRectMake(35,25,3,3)

	-- local btn_size_n	= CCSizeMake(184,66)
	-- local btn_size_n2	= CCSizeMake(184,66)
	-- local btn_size_h	= CCSizeMake(184,66)
	-- local btn_size_h2	= CCSizeMake(184,66)
	-- local text_color_n	= ccc3(0xff, 0xf6, 0x00)
	-- local text_color_h	= ccc3(0xff, 0xff, 0xff)
	-- local font			= g_sFontPangWa
	-- local font_size		= 30

	-- local strokeCor_n	= ccc3(0xf2, 0xe0, 0xcc)
	-- local strokeCor_h	= ccc3(0x00, 0x00, 0x00)

	-- local stroke_size_n	= 0
 --    local stroke_size_h = 1

	--  --创建menubar用的参数table

 --    local radio_data = {}
 --    radio_data.touch_priority = kMenuPriority
 --    radio_data.space = 30
 --    radio_data.callback = changeTitleAction
 --    radio_data.direction = 1
 --    radio_data.defaultIndex = _curSelectTag
 --    radio_data.items = {}

 --    local orangeButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
 --          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
 --          btn_size_n2, btn_size_h2,btn_size_h2,
 --          GetLocalizeStringBy("djn_230"), text_color_n, text_color_h, text_color_h, font, font_size, 
 --          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
 --   local redButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
 --          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
 --          btn_size_n2, btn_size_h2,btn_size_h2,
 --          GetLocalizeStringBy("djn_231"), text_color_n, text_color_h, text_color_h, font, font_size, 
 --          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

   
 --    table.insert(radio_data.items,orangeButton)
 --    table.insert(radio_data.items,redButton)

 --    _titleBar = LuaCCSprite.createRadioMenuWithItems(radio_data)
 --    _titleBar:setAnchorPoint(ccp(0,0))
 --    _titleBar:setPosition(ccp(30,kAdaptiveSize.height-87))
 --    node:addChild(_titleBar)
    ------------------------

	--紫卡、橙卡和各个属性面板
	--[] = {创建卡牌的函数, htid, dressId, x坐标, 属性面板Scroll底部的描述}
	local cardData = {
		[1] = {createLeftCard, DevelopData.getCurHeroInfo(), 151},
		[2] = {createRightCard, DevelopData.getCurDevelopInfo(), 501},
	}
	-- print("cardData")
	-- print_t(cardData[1][2])
	-- print("cardData..")
	-- print_t(cardData[2][2])
	for i = 1,2 do
		local htid = nil
		if cardData[i][2] ~= nil then
			htid = cardData[i][2].htid
		end
		_cardTable[i] = cardData[i][1](htid, nil)
		_cardTable[i]:setAnchorPoint(ccp(0.5,0.5))
		_cardTable[i]:setPosition(cardData[i][3], kAdaptiveSize.height-230)
		node:addChild(_cardTable[i])

		local color = ccc3(0xff,0xff,0xff)
		if i == 2 and cardData[2][2] ~= nil then
			color = ccc3(0x00,0xff,0x18)
		end
		_attrTable[i] = createAttrPanel(cardData[i][2], i)
		_attrTable[i]:setAnchorPoint(ccp(0.5,0))
		_attrTable[i]:setPosition(cardData[i][3], 240)
		node:addChild(_attrTable[i])
	end

	--右箭头
	local batchNode = CCSpriteBatchNode:create("images/hero/transfer/arrow.png")
	batchNode:setPosition(0,0)
	node:addChild(batchNode)
	local texture = batchNode:getTexture()
	local positionY = {kAdaptiveSize.height-220, 260+kScrollBgSize.height/2}
	for i = 1,2 do
		local arrow = CCSprite:createWithTexture(texture)
		arrow:setScale(0.6)
		arrow:setAnchorPoint(ccp(0.5,0.5))
		arrow:setPosition(325,positionY[i])
		batchNode:addChild(arrow)
	end

	--"进化所需材料"
	local needMaterialLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_83"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
	needMaterialLabel:setColor(ccc3(0xff,0xe4,0x00))
	needMaterialLabel:setAnchorPoint(ccp(0,0))
	needMaterialLabel:setPosition(20,240)
	node:addChild(needMaterialLabel)

	--所需材料的展示列表
	local materialTableBg = createTable()
	materialTableBg:setAnchorPoint(ccp(0.5,0))
	materialTableBg:setPosition(320,100)
	node:addChild(materialTableBg)

	--消耗银币
	_silverTable = createCostSliverLabel()
	_silverTable.parent:setAnchorPoint(ccp(0.5,0))
	_silverTable.parent:setPosition(300,73)
	node:addChild(_silverTable.parent)

	--查看信息按钮
	require "script/libs/LuaCC"
	local btnData = {
		-- [1] = {LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",
		--        CCSizeMake(160,56), GetLocalizeStringBy("zz_84"),ccc3(0xff,0xe4,0x00),30), tapInfoBtnCb, ccp(501,kAdaptiveSize.height-396)},
		[1] = {CreateUI.createScale9MenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png", nil,
			   CCSizeMake(168,65), GetLocalizeStringBy("zz_84"),28), tapInfoBtnCb, ccp(501,kAdaptiveSize.height-415)},
		[2] = {CreateUI.createScale9MenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",
			   "images/common/btn/btn1_g.png", CCSizeMake(196,68), GetLocalizeStringBy("zz_85"), 35), tapGoBackBtnCb, ccp(182,8)},
		[3] = {CreateUI.createScale9MenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",
			   "images/common/btn/btn1_g.png", CCSizeMake(196,68), GetLocalizeStringBy("zz_86"), 35), tapDevelopBtnCb, ccp(464,8)},
	}
	for i = 1,3 do
		local btn = btnData[i][1]
		btn:registerScriptTapHandler(btnData[i][2])
		btn:setAnchorPoint(ccp(0.5,0))
		btn:setPosition(btnData[i][3])
		menu:addChild(btn)
		_btnTable[i] = btn
	end
	--_btnTable[3]:setEnabled(false)

	refreshInfoBtn()
	refreshDevelopBtn()
	refreshSilverLabel()

	return node
end

--[[
	@desc :	刷新查看信息按钮
	@param:	
	@ret  :	
--]]
function refreshInfoBtn( ... )
	if _btnTable == nil or _btnTable[1] == nil then
		return
	end

	if DevelopData.getCurDevelopInfo() == nil then
		_btnTable[1]:setVisible(false)
	else
		_btnTable[1]:setVisible(true)
	end
end

--[[
	@desc :	刷新开始进化按钮
	@param:	
	@ret  :	
--]]
function refreshDevelopBtn( ... )
	if _btnTable == nil or _btnTable[3] == nil then
		return
	end

	if DevelopData.getCurDevelopInfo() == nil then
		_btnTable[3]:setEnabled(false)
	else
		_btnTable[3]:setEnabled(true)
	end
end

--[[
	@desc :	刷新银币
	@param:	
	@ret  :	
--]]
function refreshSilverLabel( ... )
	if _silverTable == nil then
		return
	end

	if DevelopData.getCurHeroInfo() == nil then
		_silverTable.parent:setVisible(false)
		return
	end

	_silverTable.parent:setVisible(true)
	_silverTable.children[2]:setString(DevelopData.getCostSilver())
end

function setUIVisible( p_bool )
	if _uiNode ~= nil then
		_uiNode:setVisible(p_bool)
	end
end

--[[
	@desc :	创建层
	@param:	
	@ret  :	
--]]
function createLayer( p_hid, p_oldLayerTag)
	--init(10265714)

	--init(10036129)
	init(p_hid, p_oldLayerTag)

	_mainLayer = CCLayer:create()
	_mainLayer:setScale(g_fScaleX)
	_mainLayer:registerScriptHandler(onNodeEvent)

	local mainBg = CCSprite:create("images/develop/main_bg.jpg")
	mainBg:setScale(MainScene.bgScale/g_fScaleX)
	mainBg:setAnchorPoint(ccp(0.5,0))
	mainBg:setPosition(320,0)
	_mainLayer:addChild(mainBg)

	_uiNode = createUI()
	_uiNode:setAnchorPoint(ccp(0.5,0))
	_uiNode:setPosition(320,0)
	_mainLayer:addChild(_uiNode)

	-- 武将进阶新手
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		addGuideHeroDevelopGuide3()
	end))
	_mainLayer:runAction(seq)

	return _mainLayer
end

--[[
	@desc :	显示层
	@param:	
	@ret  :	
--]]
function showLayer( p_hid, p_oldLayerTag )
	local mainLayer = createLayer(p_hid, p_oldLayerTag)

	MainScene.changeLayer(mainLayer, "DevelopLayer")
	MainScene.setMainSceneViewsVisible(false,false,false)
end

-----------------------------------------------------------[[ 特效 ]]---------------------------------------------------------
--[[
	@desc :	进化到进化成功界面前的切换特效
	@param:	
	@ret  :
--]]
function changeLayerEffect(  )
	local scene = CCDirector:sharedDirector():getRunningScene()
	local changeEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hero/transfer/zhuangchang"), -1, CCString:create(""))
	changeEffect:setAnchorPoint(ccp(0.5,0.5))
	changeEffect:setPosition(0, g_winSize.height)
	changeEffect:setScale(g_fScaleX)
	scene:addChild(changeEffect,12)

	local effectDelegate = BTAnimationEventDelegate:create()
	changeEffect:setDelegate(effectDelegate)

	local endedCb = function ( actionName,xmlSprite )
		changeEffect:removeFromParentAndCleanup(true)
		-- require "script/ui/develop/DevelopSuccessLayer"
		-- setUIVisible(false)
		-- DevelopSuccessLayer.showLayer()
	end

	local changedCb = function ( frameIndex, xmlSprite)
		if frameIndex == 23 then
			require "script/ui/develop/DevelopSuccessLayer"
			setUIVisible(false)
			DevelopSuccessLayer.showLayer()
		end
	end
	effectDelegate:registerLayerEndedHandler(endedCb)
	effectDelegate:registerLayerChangedHandler(changedCb)
end

-----------------------------------------------------------[[回调函数]]---------------------------------------------------------
--[[
	@desc :	层创建和释放时的回调
	@param:	
	@ret  :	
--]]
function onNodeEvent( p_evnetType )
	local touchLayerCb = function (  )
		return true
	end

	if p_evnetType == "enter" then
		_mainLayer:registerScriptTouchHandler(touchLayerCb, false, kMainLayerPriority, true)
		_mainLayer:setTouchEnabled(true)
	elseif p_evnetType == "exit" then
		_mainLayer:unregisterScriptTouchHandler()
	else

	end
end

--[[
	@desc :	六星级武将预览按钮回调
	@param:	
	@ret  :	
--]]
function tapPreviewBtnCb( p_tag, p_item )
	require "script/ui/develop/orangePreview/OrangePreviewLayer"
	OrangePreviewLayer.showLayer(kMenuPriority - 10)
end
--[[
	@desc :	进化消耗预览按钮回调
	@param:	
	@ret  :	
--]]
function tapCostBtnCb( p_tag, p_item )
	require "script/ui/develop/costPreview/CostPreviewLayer"
	CostPreviewLayer.showLayer(kMenuPriority - 10)
end
--[[
	@desc :	选择武将按钮回调
	@param:	
	@ret  :	
--]]
function tapPlusBtnCb( p_tag, p_item )
	require "script/ui/develop/SelectHeroLayer"
	SelectHeroLayer.showLayer()
end

--[[
	@desc :	查看信息按钮回调
	@param:	
	@ret  :
--]]
function tapInfoBtnCb( p_tag, p_item )
	-- local curDevelopInfo = DevelopData.getCurDevelopInfo()
	-- if curDevelopInfo == nil then
	-- 	return
	-- end
	--local data = DevelopData.getHeroData(curDevelopInfo.htid)
	local data = DevelopData.getDevelopHeroData()
	--HeroInfoLayer.createLayer(_arrHeroesValue[tag-_ksTagHeroBegin], {isPanel=true},nil,nil,true, refreshTableView)
    HeroInfoLayer.createLayer(data, {isPanel=true},nil,nil)
end

--[[
	@desc :	返回按钮回调
	@param:	
	@ret  :
--]]
function tapGoBackBtnCb( p_tag, p_item )
	-- require "script/ui/develop/SelectHeroLayer"
	-- SelectHeroLayer.showLayer()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if _oldLayerTag == kOldLayerTag.kHeroTag then
		require "script/ui/hero/HeroLayer"
		MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
	elseif _oldLayerTag == kOldLayerTag.kFormationTag then
		require "script/ui/formation/FormationLayer"
		 MainScene.changeLayer(FormationLayer.createLayer(), "formationLayer")
	else
		
	end
end

--[[
	@desc :	开始进化按钮回调
	@param:	
	@ret  :
--]]
require "script/ui/tip/SingleTip"
function tapDevelopBtnCb( p_tag, p_item )
	
	local status, tipStr = DevelopData.meetCondition()
	if status == false then
		SingleTip.showSingleTip(tipStr)
		return
	end
	local alertStr = nil
    
	if _curHeroInfo.localInfo.star_lv == 5 then
		alertStr = GetLocalizeStringBy("zz_102")
	elseif _curHeroInfo.localInfo.star_lv == 6 then
		alertStr = GetLocalizeStringBy("djn_232")
	end
	-- local argsTable = DevelopData.getArgsTable()
	-- local callBackFunc = function ()
	-- 	--切换到进化成功界面
	-- 	changeLayerEffect()

	-- 	DevelopData.consumeResource( argsTable.hidArr, DevelopData.getCostSilver())
	-- end
	-- DevelopService.startDevelop(DevelopData.getCurHeroInfo().hid, argsTable.hidArr, argsTable.itemArr, callBackFunc)
	AlertTip.showAlert(alertStr, tapComfirmBtnCb,true)
end

--[[
	@desc :	开始进化按钮回调
	@param:	
	@ret  :
--]]
function tapComfirmBtnCb( p_isTrue )
	if p_isTrue == false then
		return
	end

	-- local status, tipStr = DevelopData.meetCondition()
	-- if status == false then
	-- 	SingleTip.showSingleTip(tipStr)
	-- 	return
	-- end
	if _curHeroInfo.localInfo.star_lv == 5 then
		--进化橙卡
		local argsTable, hasLittleFriend = DevelopData.getArgsTable()
		local callBackFunc = function ()
			--切换到进化成功界面
			changeLayerEffect()

			DevelopData.consumeResource( argsTable.hidArr, DevelopData.getCostSilver())
		end
		DevelopService.startDevelopPurple(DevelopData.getCurHeroInfo().hid, argsTable.hidArr, argsTable.itemArr, callBackFunc)
	elseif _curHeroInfo.localInfo.star_lv == 6 then
		--进化紫卡
		local argsTable, hasLittleFriend = DevelopData.getArgsTable()
		local callBackFunc = function ()
			--切换到进化成功界面
			changeLayerEffect()

			DevelopData.consumeResource( argsTable.hidArr, DevelopData.getCostSilver())
		end
		DevelopService.startDevelopOrange(DevelopData.getCurHeroInfo().hid, argsTable.hidArr, argsTable.itemArr, callBackFunc)
	end
end
-- --切换橙卡和红卡的标签
-- function changeTitleAction( p_tag)
-- 	-- body
-- end

---[==[武将进化 第3步
---------------------新手引导---------------------------------
function addGuideHeroDevelopGuide3( ... )
	require "script/guide/NewGuide"
	require "script/guide/HeroDevelopGuide"
    if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 2) then
        HeroDevelopGuide.show(3, nil)
    end
end
---------------------end-------------------------------------
--]==]















