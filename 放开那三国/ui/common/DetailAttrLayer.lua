-- FileName: DetailAttrLayer.lua 
-- Author: 	Zhang Zihang 
-- Date: 15-3-10
-- Purpose: 详细属性界面

module("DetailAttrLayer",package.seeall)

require "script/audio/AudioUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/godweapon/godweaponfix/GodWeaponFixData"
require "script/model/affix/HeroAffixModel"
require "script/utils/BaseUI"

local _bgLayer 				--背景层
local _touchPriority 		--触摸优先级
local _zOrder 				--z轴
local _enterTag 			--要显示界面的tag
local _godWeaponInfo 		--神兵信息
local _petAttrInfo 			--宠物属性table
local _petEvolveInfo = nil  --宠物进阶和培养属性
local _hid

kGodTag = 1 				--神兵tag
kPetTag = 2 				--宠物tag

--属性值和百分比对照table
local inflectionTable = {
							[1] = 11, 		--生命
							[4] = 14,		--物防
							[5] = 15,		--法防
							[9] = 19,		--攻击
						}

--[[
	@des 	:初始化函数
--]]
function init()
	_bgLayer = nil
	_touchPriority = nil
	_zOrder = nil
	_enterTag = nil
	_godWeaponInfo = nil
	_petAttrInfo = nil
	_petEvolveInfo = nil
	_hid = nil
end

--[[
	@des 	:触摸函数
	@param 	:点击事件
--]]
function onTouchesHandler(p_eventType)
	if p_eventType == "began" then
	    return true
	end
end

--[[
	@des 	:触摸函数
	@param 	:点击事件
--]]
function onNodeEvent(p_event)
	if p_event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif p_event == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des 	:创建背景UI
--]]
function returnCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:创建武将属性信息
	@param  :要添加到的背景
	@param  :武将hid
	@param  :存放背景高度的table
--]]
function createHeroAttrInfo(p_layer,p_hid,p_table,anchorTable,changeTable,waterTable,petEvolveTable)
	local heroInfo = HeroUtil.getHeroInfoByHid(p_hid)

	local heroName
	if HeroModel.isNecessaryHero(heroInfo.localInfo.id) then
		heroName = UserModel.getUserName()
	else
		heroName = heroInfo.localInfo.name
	end

	--英雄属性id
	local heroOriInfo = HeroAffixModel.getAffixByHid(p_hid)
	local heroAttrInfo = {}

	table.hcopy(heroOriInfo,heroAttrInfo)

	--如果是神兵，且那个人正在穿的不是这个神兵
	if _enterTag == kGodTag and p_hid ~= _hid then
		for i = 1,#waterTable do
			local wInfo = waterTable[i]
			local aId = tonumber(wInfo.id)
			local aNum = tonumber(wInfo.realNum)
			if heroAttrInfo[aId] ~= nil then
				heroAttrInfo[aId] = tonumber(heroAttrInfo[aId]) + aNum
			else
				heroAttrInfo[aId] = aNum
			end
		end
	end
    -- 技能属性和培养属性的对应关系
    local affixKeyMap = {[1] = "51",[4] = "54",[5] = "55",[9] = "100"}
    -- 属性和描述文本的映射
    local descLabelMap = {}
	--会改变的元素的值
	for i = 1,#changeTable do
		local attrBaseInfo = changeTable[i]
		local attrId = attrBaseInfo.id
		local affixInfo,dealNum = ItemUtil.getAtrrNameAndNum(attrId,attrBaseInfo.realNum)
		--添加的值
		local addNum = attrBaseInfo.realNum
		--百分比
		local rateNum = heroAttrInfo[inflectionTable[attrId]] == nil and 0 or tonumber(heroAttrInfo[inflectionTable[attrId]])/10000
		--实际增加的值
		local plusNum = addNum*rateNum

		local formatNum = string.format("%.4f",rateNum)

		local _,newDealNum = ItemUtil.getAtrrNameAndNum(attrId,plusNum)
		--四舍五入后的值
		local fiveFourNum = math.floor(newDealNum + 0.5)

		local firstString
		local secString
		print("fiveFourNum",fiveFourNum)
		-- if fiveFourNum <= 0 then
			firstString = "+" .. dealNum
			secString = " "
		-- else
		-- 	firstString = dealNum .. " + " .. fiveFourNum
		-- 	secString = GetLocalizeStringBy("zzh_1290",tonumber(formatNum)*100 .. "%")
		-- end

		local nameLabel = CCLabelTTF:create(affixInfo.displayName .. "：",g_sFontPangWa,23)
		nameLabel:setColor(ccc3(0x00,0xff,0x18))
		local dealNumLabel = CCLabelTTF:create(firstString,g_sFontName,23)
		dealNumLabel:setColor(ccc3(0xff,0xff,0xff))
		descLabelMap[affixKeyMap[attrId]] = dealNumLabel
		local connectNode = nil
		if tonumber(fiveFourNum) > 0 then
			local extraLabel = CCLabelTTF:create(" + "..fiveFourNum,g_sFontName,23)
			extraLabel:setColor(ccc3(0xff,0xff,0x00))
			descLabelMap[affixKeyMap[attrId]] = extraLabel
			connectNode = BaseUI.createHorizontalNode({nameLabel,dealNumLabel,extraLabel})
		else
			connectNode = BaseUI.createHorizontalNode({nameLabel,dealNumLabel})
		end
		-- local plusLabel = CCLabelTTF:create(secString,g_sFontName,23)
		-- plusLabel:setColor(ccc3(0x00,0xff,0x18))
		connectNode:setAnchorPoint(ccp(0,0))
		connectNode:setPosition(ccp(g_winSize.width*115/640,p_table.layerHeight))
		connectNode:setScale(g_fScaleX)
		p_layer:addChild(connectNode)

		p_table.layerHeight = addPosY(connectNode,p_table.layerHeight)
	end
	-- 宠物进阶和培养的属性
	for evolveAttrID,evolveData in pairs(petEvolveTable) do
        if evolveData.displayNum ~= 0 then
			local label = descLabelMap[evolveAttrID]
			if label then
				if evolveData.displayNum ~= 0 then
				    local evolveAttrLabel = CCLabelTTF:create(" + "..evolveData.displayNum,g_sFontName,23 )
		            evolveAttrLabel:setColor(ccc3(0x00,0xff,0x18))
		            evolveAttrLabel:setAnchorPoint(ccp(0,0.5))
		            evolveAttrLabel:setPosition(ccpsprite(1,0.5,label))
		            label:addChild(evolveAttrLabel)
		        end
			else
			    local descLabel= CCLabelTTF:create(evolveData.affixDesc.sigleName .. "：" ,g_sFontPangWa,23 )
	            descLabel:setColor(ccc3(0x00,0xff,0x18))
	            local evolveAttrLabel = CCLabelTTF:create("+".. evolveData.displayNum,g_sFontName,23 )
	            evolveAttrLabel:setColor(ccc3(0x00,0xff,0x18))
	            -- evolveAttrLabel:setAnchorPoint(ccp(0,0.5))
	            -- evolveAttrLabel:setPosition(ccpsprite(1,0.5,descLabel))
	            -- descLabel:addChild(evolveAttrLabel)
	            -- _petPropertyBg:addChild(descLabel)
	           	local connectNode = BaseUI.createHorizontalNode({descLabel,evolveAttrLabel})
				connectNode:setAnchorPoint(ccp(0,0))
				connectNode:setPosition(ccp(g_winSize.width*115/640,p_table.layerHeight))
				connectNode:setScale(g_fScaleX)
				p_layer:addChild(connectNode)
				p_table.layerHeight = addPosY(connectNode,p_table.layerHeight)
			end
		end
	end

	--为不变的元素显示做准备
	--属性数量
	local attrNum = #anchorTable
	--显示条目数量
	local barNum = math.ceil(attrNum*0.5)
	p_table.layerHeight = 30*barNum*g_fScaleX + p_table.layerHeight
	local oriPosY = p_table.layerHeight - 30*g_fScaleX

	local posXTable = {g_winSize.width*0.63,g_winSize.width*0.18}
	local posYTable = {oriPosY,oriPosY - 30*g_fScaleX}
	--不变的元素
	for i = 1,attrNum do
		local attrBaseInfo = anchorTable[i]
		local affixInfo,dealNum = ItemUtil.getAtrrNameAndNum(attrBaseInfo.id,attrBaseInfo.realNum)
		local nameLabel = CCLabelTTF:create(affixInfo.displayName .. "：",g_sFontPangWa,23)
		nameLabel:setColor(ccc3(0x00,0xff,0x18))
		local numLabel = CCLabelTTF:create("+" .. dealNum,g_sFontName,21)
		numLabel:setColor(ccc3(0xff,0xff,0xff))

		local connectNode = BaseUI.createHorizontalNode({nameLabel,numLabel})
		connectNode:setAnchorPoint(ccp(0,0))
		connectNode:setPosition(ccp(posXTable[i%2 + 1],posYTable[math.ceil(i/2)]))
		connectNode:setScale(g_fScaleX)
		p_layer:addChild(connectNode)
	end

	local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.localInfo.potential)

	local titleNode = createInfoTitle(heroName,nil,nameColor)
	titleNode:setAnchorPoint(ccp(0.5,0))
	titleNode:setPosition(ccp(g_winSize.width*0.5,p_table.layerHeight))
	titleNode:setScale(g_fScaleX)
	p_layer:addChild(titleNode)

	p_table.layerHeight = addPosY(titleNode,p_table.layerHeight)
end

--[[
	@des 	:创建scrollView
	@param  :背景大小
	@return :创建好的scrollView
--]]
function createScrollView(p_bgSize)
	local viewHeight = p_bgSize.height*0.89

	local contentScrollView = CCScrollView:create()
	contentScrollView:setViewSize(CCSizeMake(p_bgSize.width,viewHeight))

	--内部layer
	local scrollLayer = CCLayer:create()
	contentScrollView:setContainer(scrollLayer)

	--layer高度
	local heightTable = { layerHeight = 5*g_fScaleX }

	--获得阵上信息
	local formationInfo = DataCache.getSquad() or {}

	local anchorTable,changeTable,waterTable
	if _enterTag == kGodTag then
		anchorTable,changeTable,waterTable = dealGodAttr(p_hid)
	else
		anchorTable,changeTable = dealPetAttr()
	end

	for i = 1,table.count(formationInfo) do
		local posId = table.count(formationInfo) - i
		local heroHid = tonumber(formationInfo[tostring(posId)])
		if heroHid >0 then
			createHeroAttrInfo(scrollLayer,heroHid,heightTable,anchorTable,changeTable,waterTable,_petEvolveInfo)
		end
	end

	scrollLayer:setContentSize(CCSizeMake(p_bgSize.width,heightTable.layerHeight))
	scrollLayer:setPosition(ccp(0,viewHeight - heightTable.layerHeight))

	return contentScrollView
end

--[[
	@des 	:创建背景UI
--]]
function createBgUI()
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	_bgLayer:addChild(bgMenu)
	--返回按钮
	local returnMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	returnMenuItem:setAnchorPoint(ccp(1,1))
	returnMenuItem:setPosition(ccp(g_winSize.width*0.98,g_winSize.height*0.99))
	returnMenuItem:setScale(g_fElementScaleRatio)
	returnMenuItem:registerScriptTapHandler(returnCallBack)
	bgMenu:addChild(returnMenuItem)
end

--[[
	@des 	:创建scrollView相关UI
--]]
function createScrollUI()
	-- local underSprite = CCSprite:create("images/god_weapon/buttom_flower.png")
	-- underSprite:setAnchorPoint(ccp(0.5,0))

	local viewBgSize = CCSizeMake(g_winSize.width,g_winSize.height*580/960)

	local viewBgSprite = CCScale9Sprite:create(CCRectMake(84,10,12,8),"images/god_weapon/view_bg_2.png")
	viewBgSprite:setContentSize(viewBgSize)
	viewBgSprite:setAnchorPoint(ccp(0.5,0))
	viewBgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*250/960))
	_bgLayer:addChild(viewBgSprite)

	--花边
	local buttomSprite = CCSprite:create("images/god_weapon/buttom_flower.png")
	buttomSprite:setAnchorPoint(ccp(0.5,0))
	buttomSprite:setPosition(ccp(viewBgSize.width*0.5,0))
	buttomSprite:setScale(g_fScaleX)
	viewBgSprite:addChild(buttomSprite)

	local xOffset = 10*g_fScaleX

	--左青龙
	local leftFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
	leftFlowerSprite:setAnchorPoint(ccp(0,0.5))
	leftFlowerSprite:setPosition(ccp(-xOffset,viewBgSize.height))
	leftFlowerSprite:setScale(g_fScaleX)
	viewBgSprite:addChild(leftFlowerSprite)

	--右白虎
	local rightFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
	rightFlowerSprite:setScaleX(-g_fScaleX)
	rightFlowerSprite:setScaleY(g_fScaleX)
	rightFlowerSprite:setAnchorPoint(ccp(0,0.5))
	rightFlowerSprite:setPosition(ccp(viewBgSize.width + xOffset,viewBgSize.height))
	viewBgSprite:addChild(rightFlowerSprite)

	local pathTable = {
							[kGodTag] = "images/god_weapon/god_attr_title.png",
							[kPetTag] = "images/god_weapon/pet_attr_title.png"
					  }

	--标题
	local titleSprite = CCSprite:create(pathTable[_enterTag])
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(viewBgSize.width*0.5,viewBgSize.height))
	titleSprite:setScale(g_fElementScaleRatio)
	viewBgSprite:addChild(titleSprite)
	if _enterTag == kPetTag then
		-- 说明
	    local richInfo = {
	        linespace = 2, -- 行间距
	        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
	        labelDefaultFont = g_sFontPangWa,
	        labelDefaultColor = ccc3( 0xff, 0xff, 0xff),
	        labelDefaultSize = 21,
	        defaultType = "CCRenderLabel",
	        elements =
	        {
	            {
	                type = "CCRenderLabel",
	                newLine = false,
	                text = GetLocalizeStringBy("syx_1103"),
	                renderType = 2,-- 1 描边， 2 投影
	            },
	            {
	                type = "CCRenderLabel",
	                newLine = false,
	                color = ccc3(0xff,0xff,0x00),
	                text = GetLocalizeStringBy("syx_1104"),
	                renderType = 2,-- 1 描边， 2 投影
	            },
	            {
	                type = "CCRenderLabel",
	                newLine = false,
	                text = GetLocalizeStringBy("syx_1105"),
	                renderType = 2,-- 1 描边， 2 投影
	            },
	            {
	                type = "CCRenderLabel",
	                newLine = false,
	                color = ccc3(0x00,0xff,0x18),
	                text = GetLocalizeStringBy("syx_1106"),
	                renderType = 2,-- 1 描边， 2 投影
	            },
	            {
	                type = "CCRenderLabel",
	                newLine = false,
	                text = GetLocalizeStringBy("syx_1107"),
	                renderType = 2,-- 1 描边， 2 投影
	            },
	        }
	    }
	    require "script/libs/LuaCCLabel"
	    local sayLabel = LuaCCLabel.createRichLabel(richInfo)
	    sayLabel:setAnchorPoint(ccp(0.5, 0.5))
	    sayLabel:setPosition(ccp(viewBgSize.width*0.5,viewBgSize.height * 0.95))
	    sayLabel:setScale(g_fElementScaleRatio)
	    viewBgSprite:addChild(sayLabel)
	end
	--scrollView
	local bgScrollView = createScrollView(viewBgSize)
	bgScrollView:setDirection(kCCScrollViewDirectionVertical)
	bgScrollView:setAnchorPoint(ccp(0,0))
	bgScrollView:setPosition(ccp(0,viewBgSize.height*0.05))
	bgScrollView:setTouchPriority(_touchPriority - 1)
	viewBgSprite:addChild(bgScrollView)
end

--[[
	@des 	:创建UI
--]]
function createUI()
	--创建背景UI
	createBgUI()
	--创建scrollView相关UI
	createScrollUI()
end

--[[
	@des 	:入口函数
	@param  :需要显示的tag
	@param  :触摸优先级
	@param  :Z轴
	@param  :神兵信息
	@param  :宠物属性信息
	@param  :穿着这个人的hid
--]]
function showLayer(p_enterTag,p_touchPriority,p_zOrder,p_godWeaponInfo,p_petAttrInfo,p_wearHid,p_petEvolveInfo)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999
	_enterTag = p_enterTag

	_godWeaponInfo = p_godWeaponInfo
	_petAttrInfo = p_petAttrInfo
	_petEvolveInfo = p_petEvolveInfo or {}
	_hid = tonumber(p_wearHid)

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createUI()

	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)
end

--[[
	@des 	:创建两个分割线中间标题的node
	@param 	:标题string
	@param 	:标题字体大小
	@param 	:标题颜色
	@return :node
--]]
function createInfoTitle(p_string,p_size,p_color)
	local frontSize = p_size or 24
	local frontColor = p_color or ccc3(0xff,0xf6,0x00)

	--左分隔符
	local leftSprite = CCSprite:create("images/god_weapon/cut_line.png")
	leftSprite:setAnchorPoint(ccp(0,0.5))
	--右分隔符
	local rightSprite = CCSprite:create("images/god_weapon/cut_line.png")
	rightSprite:setScaleX(-1)
	rightSprite:setAnchorPoint(ccp(0,0.5))
	--名称
	local nameLabel = CCLabelTTF:create(p_string,g_sFontPangWa,frontSize)
	nameLabel:setColor(frontColor)
	nameLabel:setAnchorPoint(ccp(0.5,0.5))

	local nodeContentSize = CCSizeMake(leftSprite:getContentSize().width*2 + 115,nameLabel:getContentSize().height)

	--底层node
	local bgNode = CCNode:create()
	bgNode:setContentSize(nodeContentSize)

	local yPos = nodeContentSize.height*0.5
	
	leftSprite:setPosition(ccp(0,yPos))
	nameLabel:setPosition(ccp(nodeContentSize.width*0.5,yPos))
	rightSprite:setPosition(ccp(nodeContentSize.width,yPos))

	bgNode:addChild(leftSprite)
	bgNode:addChild(rightSprite)
	bgNode:addChild(nameLabel)

	return bgNode
end

--[[
	@des 	:增加y坐标的值
	@param 	:新增加的node
	@param 	:y坐标
	@param 	:额外高度，默认为5
	@return :增加后的y坐标
--]]
function addPosY(p_node,p_y,p_ex)
	local exHeight = p_ex or 5
	return (exHeight + p_node:getContentSize().height)*g_fScaleX + p_y
end

--[[
	@des 	:处理神兵属性数据
	@return :处理好的属性不变的table
	@return :处理好的属性改变的table
--]]
function dealGodAttr(p_hid)
	local attrInfo = GodWeaponItemUtil.getWeaponAbility(nil,nil,_godWeaponInfo)

	local waterInfo = GodWeaponFixData.getGodWeapinFixAttrForFight(_godWeaponInfo.item_id)

	local waterInFlectTable = {}
	for i = 1,#waterInfo do
		local wInfo = waterInfo[i]
		waterInFlectTable[tonumber(wInfo.id)] = tonumber(wInfo.realNum)
	end

	local anchorTable = {}
	local changeTable = {}
	for i = 1,#attrInfo do
		local innerTable = {}
		local attrTable = attrInfo[i]
		local attrId = tonumber(attrTable.id)
		--武力或智力
		--不会有加成的元素
		innerTable.id = attrId
		innerTable.realNum = tonumber(attrTable.realNum)
		
		if waterInFlectTable[attrId] ~= nil then
			innerTable.realNum = innerTable.realNum + waterInFlectTable[attrId]
		end

		if attrId == 7 or attrId == 8 then
			table.insert(anchorTable,innerTable)
		else
			table.insert(changeTable,innerTable)
		end
	end

	return anchorTable,changeTable,waterInfo
end

--[[
	@des 	:处理宠物属性数据
	@return :处理好的属性不变的table
	@return :处理好的属性改变的table
--]]
function dealPetAttr()
	local anchorTable = {}
	local changeTable = {}
	local attrInfo = _petAttrInfo
	for i = 1,#attrInfo do
		local innerTable = {}
		local attrTable = attrInfo[i]
		local attrId = tonumber(attrTable.affixDesc.id)
		--武力或智力
		--不会有加成的元素
		innerTable.id = attrId
		innerTable.realNum = tonumber(attrTable.realNum)

		if attrId == 7 or attrId == 8 then
			table.insert(anchorTable,innerTable)
		else
			table.insert(changeTable,innerTable)
		end
	end
	return anchorTable,changeTable
end