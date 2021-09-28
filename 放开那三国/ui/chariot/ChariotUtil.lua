-- FileName: ChariotUtil.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车工具类(公共方法)

module("ChariotUtil", package.seeall)

require "script/ui/chariot/ChariotMainData"
require "script/ui/chariot/ChariotDef"
require "script/ui/item/ItemSprite"
require "script/utils/BaseUI"
require "script/ui/hero/HeroPublicLua"

--[[
	@desc	: 创建战车名称标签(包括底板)
	@param	: pName 战车名称
	@param	: pBgSize 背景大小
	@param	: pQuality 战车品质 可为nil或0则默认颜色
	@param	: pLevel 战车等级 可为nil或0则不显示
	@return : CCScale9Sprite 战车名称标签
--]]
function createChariotNameLabByNameAndLv( pName, pBgSize, pQuality, pLevel )
	-- 名字背景
	local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBg:setContentSize(pBgSize)
	nameBg:setAnchorPoint(ccp(0.5,0.5))

	-- 等级 和 名称
	local lvTab = {}
	local i = 1
	local namePx = 0.5 -- 名称的偏移
	if (pLevel and pLevel > 0) then
	    lvTab[i] = CCSprite:create("images/common/lv.png")
	    i = i+1
	    lvTab[i] = CCRenderLabel:create(pLevel, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    lvTab[i]:setColor(ccc3(0xff,0xf6,0x00))
	    i = i+1
	    namePx = 0.56
	end

	local lvFont = BaseUI.createHorizontalNode(lvTab)
    lvFont:setAnchorPoint(ccp(1,0.5))
	lvFont:setPosition(ccp(nameBg:getContentSize().width*0.25,nameBg:getContentSize().height*0.5))
	nameBg:addChild(lvFont)

	local nameTab = {}
	local i = 1
    nameTab[i] = CCRenderLabel:create(pName, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    if (pQuality and pQuality > 0) then
    	nameTab[i]:setColor(HeroPublicLua.getCCColorByStarLevel(pQuality))
    else
	    nameTab[i]:setColor(ccc3(0xff, 0xf6, 0x00))
	end
	i = i+1

	-- 进阶等级 下版有
	-- if(pDevelopLv and pDevelopLv > 0) then
	-- 	nameTab[i] = CCRenderLabel:create(" ".. pDevelopLv .. GetLocalizeStringBy("zzh_1159"), g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- 	nameTab[i]:setColor(ccc3(0x00,0xff,0x18))
	-- end

    local nameFont = BaseUI.createHorizontalNode(nameTab)
    nameFont:setAnchorPoint(ccp(0.5,0.5))
	nameFont:setPosition(ccp(nameBg:getContentSize().width*namePx,nameBg:getContentSize().height*0.5))
	nameBg:addChild(nameFont)

	return nameBg
end

--[[
	@desc	: 创建战车大图标按钮
	@param	: pChariotTid 战车模板id
	@param	: pIsGary 是否置灰
	@param	: pClickCallback 点击回调函数
	@param 	: pTag 按钮的下标值
	@param	: pMenuPriority 菜单优先级
	@return : CCSprite 战车的大图标(Icon)
--]]
function createChariotBigItemByTid( pChariotTid, pIsGary, pClickCallback, pTag, pMenuPriority )
	local tag = pTag or pChariotTid
	local priority = pMenuPriority or (-300)

	local chariotData = DB_Item_warcar.getDataById(pChariotTid)

	local TempSprite = nil
	if (pIsGary) then
		TempSprite = BTGraySprite
	else
		TempSprite = CCSprite
	end

	local itemBg = CCSprite:create()
	local bigIconFile = "images/base/warcar/big/" .. chariotData.icon_big
	-- show 为 0 敬请期待 复用时装的图
    if (chariotData.show == ChariotDef.kIllustrateStatusHide) then
    	bigIconFile = "images/base/fashion/big/" .. chariotData.icon_big
    end
	local bigIconSp = TempSprite:create(bigIconFile)
	itemBg:setContentSize(bigIconSp:getContentSize())

	local menuBar = BTSensitiveMenu:create()
	if (menuBar:retainCount() > 1) then
        menuBar:release()
        menuBar:autorelease()
    end
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(priority)
	itemBg:addChild(menuBar)

	local chariotBtn = CCMenuItemSprite:create(bigIconSp,bigIconSp)
	if(pClickCallback ~= nil ) then
		chariotBtn:registerScriptTapHandler(pClickCallback)
	end
	chariotBtn:setAnchorPoint(ccp(0.5, 0.5))
	chariotBtn:setPosition(ccpsprite(0.5,0.5,itemBg))
	menuBar:addChild(chariotBtn,1,tonumber(tag))

	return itemBg
end

--[[
	@desc	: 创建战车形象(包括图标和底板)
	@param	: pChariotTid 战车模板id
	@param	: pIsGary 是否置灰
	@param 	: pIsShow 是否显示(敬请期待)
	@return : CCSprite 战车形象
--]]
function createChariotSpriteByTid( pChariotTid, pIsGary, pIsShow )
	-- 战车形象底板
	local chariotBg = nil
	local isGary = pIsGary or false
	local isShow = pIsShow
	if (isGary) then
		chariotBg = CCSprite:create("images/chariot/gary_chariot_bg.png")
	else
		chariotBg = CCSprite:create("images/chariot/chariot_bg.png")
	end

	-- 图标
	local chariotSprite = createChariotBigItemByTid(pChariotTid,isGary)
	chariotBg:addChild(chariotSprite, 2)
	chariotSprite:setAnchorPoint(ccp(0.5, 0.5))
	chariotSprite:setPosition(ccpsprite(0.5, 0.5, chariotBg))

	if (isShow) then
		chariotSprite:setScale(0.5)

		-- 底
		local shadowSprite = CCSprite:create("images/chariot/chariot_shadow.png")
		chariotBg:addChild(shadowSprite)
		shadowSprite:setAnchorPoint(ccp(0.5, 0.5))
		shadowSprite:setPosition(ccp(chariotSprite:getPositionX(),chariotSprite:getPositionY()-chariotSprite:getContentSize().height*0.18))
		shadowSprite:setScale(0.5)
	end

	return chariotBg
end


--[[
	@desc	: 根据战车信息创建组合中战车形象
    @param	: pChariot 战车信息
    @return	: CCSprite 战车形象
—]]
function createChariotSuitSpriteByInfo( pChariot )
	local chariotBg = CCSprite:create()
	if ( not table.isEmpty(pChariot) ) then
		local chariotTid = pChariot.id
		local isGary = not pChariot.isGot
		local chariotName = pChariot.name
		local isIllustrateShow = (pChariot.show == ChariotDef.kIllustrateStatusShow)

		chariotBg = createChariotSpriteByTid(chariotTid,isGary,isIllustrateShow)

		local name = CCRenderLabel:create(chariotName, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		chariotBg:addChild(name,10)
		name:setAnchorPoint(ccp(0.5, 0.5))
		name:setPosition(ccpsprite(0.5, 0.9, chariotBg))
		name:setColor(HeroPublicLua.getCCColorByStarLevel(pChariot.quality))

		-- 未获得
		if ( isGary ) then
			if ( isIllustrateShow ) then
				local noTipSprite = CCSprite:create("images/dress_room/not_get.png")
				chariotBg:addChild(noTipSprite,20)
				noTipSprite:setAnchorPoint(ccp(0.5, 0.5))
				noTipSprite:setPosition(ccpsprite(0.5, 0.5, chariotBg))
			end
			name:setColor(ccc3(0x82, 0x82, 0x82))
		end
	end

	return chariotBg
end

--[[
	@desc	: 创建装备属性文字背景
	@param	: pTitle 标题
	@param	: pBgSize 背景大小
	@return : CCScale9Sprite 文字背景
--]]
function createProBgByTitleAndSize( pTitle, pBgSize )
	-- 战车属性
	local proBg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	proBg:setContentSize(pBgSize)

	-- 属性 title
    local proLabelBg = CCScale9Sprite:create("images/common/astro_labelbg.png")
    proLabelBg:setContentSize(CCSizeMake(183,40))
    proLabelBg:setAnchorPoint(ccp(0.5,0.5))
    proLabelBg:setPosition(proBg:getContentSize().width/2, proBg:getContentSize().height)
    proBg:addChild(proLabelBg)

    local proTitleLabel = CCRenderLabel:create(pTitle, g_sFontPangWa, 25,1, ccc3(0x00,0x00,0x00),type_stroke )
    proTitleLabel:setColor(ccc3(0xff,0xf6,0x00))
    proTitleLabel:setPosition(proLabelBg:getContentSize().width/2, proLabelBg:getContentSize().height/2)
    proTitleLabel:setAnchorPoint(ccp(0.5,0.5))
    proLabelBg:addChild(proTitleLabel)

    return proBg
end

--[[
	@desc	: 根据战车信息创建属性技能UI
	@param	: pChariot 战车信息 为nil则返回说明
	@param	: pTouchPriority 父节点层触摸优先级
	@return : CCScale9Sprite 属性技能UI
--]]
function createChariotAttrUIByInfo( pChariot, pTouchPriority )
		local proTitleStr = pChariot and GetLocalizeStringBy("lgx_1090") or GetLocalizeStringBy("key_3223")
		local touchPriority = pTouchPriority or -700
		-- 战车属性
	    local attrBg = createProBgByTitleAndSize(proTitleStr,CCSizeMake(636,218))

		if (pChariot) then
			-- ScrollView
			local scrollView = CCScrollView:create()
			scrollView:setTouchPriority(touchPriority-3)
			local scrollViewHeight = attrBg:getContentSize().height - 30
			scrollView:setViewSize(CCSizeMake(attrBg:getContentSize().width, scrollViewHeight))
			scrollView:setDirection(kCCScrollViewDirectionVertical)

			local contentLayer = CCLayer:create()
			contentLayer:setContentSize(CCSizeMake(attrBg:getContentSize().width,attrBg:getContentSize().height+30))

			-- 记录高度
			local contentHeight = 0

			-- 属性技能
			local chariotTid = pChariot.item_template_id
			local chariotDB = pChariot.itemDesc
			local curLv = tonumber(pChariot.va_item_text.chariotEnforce)

			-- 攻击方式 
		    local attackLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1072"), g_sFontPangWa, 23,1, ccc3(0x00,0x00,0x00),type_stroke )
		    attackLabel:setColor(ccc3(0xff,0xf6,0x00))
		    attackLabel:setPosition(contentLayer:getContentSize().width*0.25, contentLayer:getContentSize().height-25)
		    attackLabel:setAnchorPoint(ccp(1,1))
		    contentLayer:addChild(attackLabel)

		    -- 攻击描述
		    local attackTab = {}
		    attackTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lgx_1076",chariotDB.round), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    attackTab[1]:setColor(ccc3(0x00,0xff,0x18))
		    attackTab[2] = CCRenderLabel:create( GetLocalizeStringBy("lgx_1077"), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    attackTab[2]:setColor(ccc3(0xff,0xff,0xff))

		    local attackFont = BaseUI.createHorizontalNode(attackTab)
		    attackFont:setAnchorPoint(ccp(0,1))
			attackFont:setPosition(ccp(contentLayer:getContentSize().width*0.26,contentLayer:getContentSize().height-30))
			contentLayer:addChild(attackFont)

		    -- 战车属性 
		    local curAttrLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1073"), g_sFontPangWa, 23,1, ccc3(0x00,0x00,0x00),type_stroke )
		    curAttrLabel:setColor(ccc3(0xff,0xf6,0x00))
		    curAttrLabel:setPosition(contentLayer:getContentSize().width*0.25, contentLayer:getContentSize().height-65)
		    curAttrLabel:setAnchorPoint(ccp(1,1))
		    contentLayer:addChild(curAttrLabel)

		    -- 属性数值
		    local attrPy = 0
		    local attrInfo = ChariotMainData.getSortedChariotAttrInfoByTidAndLv(chariotTid,curLv)
		    for i,v in ipairs(attrInfo) do
		    	local row = math.floor((i-1)/2)+1
	 			local col = (i-1)%2+1
		    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(v.id,v.num)
		    	local attrStr = affixDesc.sigleName .. "+" .. displayNum

		    	local attrStrLabel = CCRenderLabel:create(attrStr,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				attrStrLabel:setColor(ccc3(0x00,0xff,0x18))
				attrStrLabel:setAnchorPoint(ccp(0,1))
				attrStrLabel:setPosition(ccp(contentLayer:getContentSize().width*0.26+160*(col-1), contentLayer:getContentSize().height-(70+30*(row-1))))
				contentLayer:addChild(attrStrLabel)

				attrPy = contentLayer:getContentSize().height-(70+30*(row-1))
		    end
		    contentHeight = contentHeight + attrPy + 35

		    local attrNoticeLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1091"),g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrNoticeLabel:setColor(ccc3(0xff,0xff,0xff))
			attrNoticeLabel:setAnchorPoint(ccp(0,1))
			attrNoticeLabel:setPosition(ccp(contentLayer:getContentSize().width*0.26, attrPy-30))
			contentLayer:addChild(attrNoticeLabel)
			contentHeight = contentHeight + 30

		    -- 技能类型 
		    local chariotTypeLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1074"), g_sFontPangWa, 23,1, ccc3(0x00,0x00,0x00),type_stroke )
		    chariotTypeLabel:setColor(ccc3(0xff,0xf6,0x00))
		    chariotTypeLabel:setPosition(contentLayer:getContentSize().width*0.25, attrPy-60)
		    chariotTypeLabel:setAnchorPoint(ccp(1,1))
		    contentLayer:addChild(chariotTypeLabel)

		    -- 技能描述
		    local skillName,skillDesc = ChariotMainData.getSkillNameAndDescById(chariotDB.warcar_skill)
		 	local textInfo = {
		     		width = attrBg:getContentSize().width*0.70, -- 宽度
			        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
			        labelDefaultFont = g_sFontName, -- 默认字体
			        labelDefaultSize = 23, -- 默认字体大小
			        elements =
			        {	
			        	{
			            	type = "CCRenderLabel", 
			            	text = skillName.." ",
			            	color = ccc3(0x85,0x00,0x7a)
			        	},
			        	{
			            	type = "CCRenderLabel", 
			            	text = skillDesc,
			            	color = ccc3(0xff,0xff,0xff)
			        	}
			        }
			 	}
		 	local typeStrLabel = LuaCCLabel.createRichLabel(textInfo)
		 	typeStrLabel:setAnchorPoint(ccp(0,1))
			typeStrLabel:setPosition(ccp(contentLayer:getContentSize().width*0.26, attrPy-65))
		 	contentLayer:addChild(typeStrLabel)
			contentHeight = contentHeight + typeStrLabel:getContentSize().height + 5
			-- print("typeStrLabel height => ",typeStrLabel:getContentSize().height)

			-- 设置 contentLayer size
			print("contentHeight => ",contentHeight)
			contentLayer:setContentSize(CCSizeMake(attrBg:getContentSize().width,contentHeight))
			scrollView:setContainer(contentLayer)
			scrollView:setPosition(ccp(0,10))
			attrBg:addChild(scrollView)
			scrollView:setContentOffset(ccp(0,scrollView:getViewSize().height-contentLayer:getContentSize().height+60))
		else
			-- 说明
			local textInfo = {
		     		width = 580, -- 宽度
			        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
			        labelDefaultFont = g_sFontName, -- 默认字体
			        labelDefaultSize = 28, -- 默认字体大小
			        elements =
			        {	
			        	{
			            	type = "CCRenderLabel", 
			            	text = GetLocalizeStringBy("lgx_1071"),
			            	color = ccc3(0x00, 0xff, 0x18)
			        	}
			        }
			 	}
		 	local descLabel = LuaCCLabel.createRichLabel(textInfo)
		    descLabel:setAnchorPoint(ccp(0.5, 0.5))
		    descLabel:setPosition(attrBg:getContentSize().width*0.5, attrBg:getContentSize().height*0.5+15)
		    attrBg:addChild(descLabel)

		    -- 注
		    local noticeLabel = CCRenderLabel:create("("..GetLocalizeStringBy("lgx_1096")..")", g_sFontName, 28,1, ccc3(0x00,0x00,0x00),type_stroke )
		    noticeLabel:setColor(ccc3(0xff, 0xff, 0xff))
		    noticeLabel:setPosition(attrBg:getContentSize().width*0.5, 50)
		    noticeLabel:setAnchorPoint(ccp(0.5,0.5))
		    attrBg:addChild(noticeLabel)
		end

		return attrBg
end

--[[
	@desc	: 创建图鉴属性文字背景
	@param	: pTitle 标题
	@param	: pBgSize 背景大小
	@param	: pIsGary 是否置灰
	@return : CCScale9Sprite 文字背景
--]]
function createTextBgByTitleAndSize( pTitle, pBgSize, pIsGary )
	local isGary = pIsGary or false
	local textBg = nil
	if (isGary) then
		textBg = CCScale9Sprite:create("images/dress_room/gray_attribute_bg.png")
	else
		textBg = CCScale9Sprite:create("images/dress_room/attribute_bg.png")
	end

	textBg:setPreferredSize(pBgSize)

	local textTitleBg = CCScale9Sprite:create("images/common/astro_labelbg.png")
	textBg:addChild(textTitleBg)
	textTitleBg:setAnchorPoint(ccp(0.5, 0.5))
	textTitleBg:setPosition(ccpsprite(0.5, 1, textBg))
	textTitleBg:setPreferredSize(CCSizeMake(211, 40))

	local textTitle = CCLabelTTF:create(pTitle, g_sFontPangWa, 25)
	textTitleBg:addChild(textTitle)
	textTitle:setAnchorPoint(ccp(0.5, 0.5))
	textTitle:setPosition(ccpsprite(0.5, 0.53, textTitleBg))
	textTitle:setColor(ccc3(0xff, 0xf6, 0x00))

	return textBg
end

--[[
	@desc	: 创建箭头闪烁动画
	@param	: pArrow 箭头精灵
	@return : 
--]]
function runArrowAction( pArrow )
	local actionArrs = CCArray:create()
	actionArrs:addObject(CCFadeOut:create(1))
	actionArrs:addObject(CCFadeIn:create(1))
	local sequenceAction = CCSequence:create(actionArrs)
	local foreverAction = CCRepeatForever:create(sequenceAction)
	pArrow:runAction(foreverAction)
end

--[[
    @desc   : 创建上下浮动的动画
    @param  : pNode 浮动的节点
    @return : 
--]]
function runUpAndDownAction( pNode )
    local actionArrs = CCArray:create()
    actionArrs:addObject(CCMoveBy:create(1,ccp(0,20)))
    actionArrs:addObject(CCMoveBy:create(1,ccp(0,-20)))
    local sequenceAction = CCSequence:create(actionArrs)
    local foreverAction = CCRepeatForever:create(sequenceAction)
    pNode:runAction(foreverAction)
end


--[[
	@desc	: 创建属性框展出动画
    @param	: pNode 执行节点 pNodeScale 节点原本缩放比
    @return	:   
—]]
function runShowAction( pNode, pNodeScale )
	local nodeScale = pNodeScale or 1.0
	pNode:setScale(0)
    local scaleTo = CCScaleTo:create(0.3,1.0*nodeScale)
    pNode:runAction(scaleTo)
end

--[[
	@desc 	: 成功装备战车 属性加成飘字提示 
	@param	: pCurChariot 新装备的战车信息
	@param	: pOldChariot 之前装备的战车信息
	@return	: 
--]]
function showChariotAttrTip( pCurChariot, pOldChariot )
	if (table.isEmpty(pCurChariot) and table.isEmpty(pOldChariot)) then
		return
	end

	-- 当前属性
	local curAttr = nil
	if (not table.isEmpty(pCurChariot)) then
		curAttr = ChariotMainData.getChariotAttrByInfo(pCurChariot)
	end

	-- 之前属性
	local oldAttr = nil
	if (not table.isEmpty(pOldChariot)) then
		oldAttr = ChariotMainData.getChariotAttrByInfo(pOldChariot)
	end

	-- 合并数据
	local retAttr = {}
	if (curAttr) then
		-- 装备
		retAttr = curAttr
		if (oldAttr) then
			-- 更换
			for k,v in pairs(retAttr) do
				if ( oldAttr[k] ~= nil ) then
					v.num = v.num - oldAttr[k].num
					retAttr[k] = v
				end
			end
		end
	else
		-- 卸下
		retAttr = {}
		for k,v in pairs(oldAttr) do
			if ( oldAttr[k] ~= nil ) then
				v.num = -oldAttr[k].num
				retAttr[k] = v
			end
		end
	end

	local textTab = {}
    for k,v in pairs(retAttr) do
    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v.num)
    	if (v.num ~= 0) then	
	    	local text = {}
			text.txt = affixDesc.sigleName
			text.num = displayNum
			table.insert(textTab,text)
		end
    end

	if (table.isEmpty(textTab)) then
		return
	end

	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(textTab)
end

--[[
	@desc 	: 成功强化战车 属性加成飘字提示 
	@param	: pChariot 战车信息
	@param	: pAddLv 强化增加的等级
	@return	: 
--]]
function showChariotEnforceAttrTip( pChariot, pAddLv )
	if (table.isEmpty(pChariot)) then
		return
	end

	-- 属性飘字
	local chariotTid = tonumber(pChariot.item_template_id)
	local chariotLv = tonumber(pChariot.va_item_text.chariotEnforce)
	local curAttr = ChariotMainData.getChariotAttrInfoByTidAndLv(chariotTid,chariotLv+pAddLv)
	local oldAttr = ChariotMainData.getChariotAttrInfoByTidAndLv(chariotTid,chariotLv)
	-- 合并数据
	for k,v in pairs(curAttr) do
		if ( oldAttr[k] ~= nil ) then
			v.num = v.num - oldAttr[k].num
			curAttr[k] = v
		end
	end

	local textTab = {}
    for k,v in pairs(curAttr) do
    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v.num)
    	if (v.num ~= 0) then	
	    	local text = {}
			text.txt = affixDesc.sigleName
			text.num = displayNum
			table.insert(textTab,text)
		end
    end

	if (table.isEmpty(textTab)) then
		return
	end

	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(textTab)

	-- 提升等级特效
	require "script/ui/common/PublicSpecialEffects"
	PublicSpecialEffects.enhanceResultEffect(pAddLv)
end
