-- FileName: introduceLayer.lua 
-- Author:   Li Cong 
-- Date: 14-3-3 
-- Purpose: function description of module 


module("introduceLayer", package.seeall)
require "script/utils/BaseUI"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"

local _bgLayer                  = nil
local backGround 				= nil
local _btnBg 					= nil
local second_bg  				= nil
local name_bg 					= nil
local flop_bg 					= nil
local _curId 					= nil
local _flopData 				= nil
local goodTableView 			= nil
local showName 					= nil
local showLongZhu 				= nil
local showDes 					= nil
local btnTableView 				= nil
local showColor 				= { ccc3(0xff, 0xff, 0xff),
									ccc3(0x1A, 0xFD, 0x02),
									ccc3(0x02, 0xFD, 0xFA),
									ccc3(0xE8, 0x02, 0xFD),
									ccc3(0xFD, 0xA1, 0x02)
								}

function init( ... )
	_bgLayer                    = nil
	backGround 					= nil
	_btnBg 						= nil
	second_bg  					= nil
	name_bg 					= nil
	flop_bg 					= nil
	_curId 						= nil
	_flopData 					= nil
	goodTableView 				= nil
	showName 					= nil
	showLongZhu 				= nil
	showDes 					= nil
	btnTableView 				= nil
end


-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end


-- 创建layer
function ShowIntroduceLayer( ... )
	init()

	-- 默认第一个场景
	_curId = 1

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1999,78432)

	-- 创建背景
	backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    backGround:setContentSize(CCSizeMake(600, 745))
    backGround:setAnchorPoint(ccp(0.5,0.5))
    backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5 - 24))
    _bgLayer:addChild(backGround)
    -- 适配
    setAdaptNode(backGround)
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(backGround:getContentSize().width/2, backGround:getContentSize().height-6.6 ))
	backGround:addChild(titlePanel)
	local titleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_1930"), g_sFontPangWa, 34)
	titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-420)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(backGround:getContentSize().width * 0.955, backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 按钮背景
    local fullRect = CCRectMake(0,0,64,69)
	local insetRect = CCRectMake(30,30,4,6)
   	_btnBg = CCScale9Sprite:create("images/hunt/btn_bg.png", fullRect, insetRect)
   	_btnBg:setAnchorPoint(ccp(0.5,1))
   	_btnBg:setPosition(ccp(backGround:getContentSize().width*0.5,backGround:getContentSize().height-50))
   	backGround:addChild(_btnBg,10)
   	_btnBg:setContentSize(CCSizeMake(556,69))

	-- 两个方向
	local left_Sprite = CCSprite:create("images/hunt/right.png")
	left_Sprite:setAnchorPoint(ccp(1,0.5))
	left_Sprite:setPosition(ccp(28,_btnBg:getContentSize().height*0.5))
	_btnBg:addChild(left_Sprite,2)
	left_Sprite:setScale(left_Sprite:getScaleX()*-1)

	local right_Sprite = CCSprite:create("images/hunt/right.png")
	right_Sprite:setAnchorPoint(ccp(1,0.5))
	right_Sprite:setPosition(ccp(_btnBg:getContentSize().width-28,_btnBg:getContentSize().height*0.5))
	_btnBg:addChild(right_Sprite,2)
		
	-- 创建按钮tableView
	createBtnTableView()

	-- 创建下方不动UI
	createNoChangeUI()

end


-- 创建按钮tableView
function createBtnTableView( ... )
	local showIdTable = { {id = 1}, {id = 2}, {id = 3}, {id = 4}, {id = 5} }
	print(GetLocalizeStringBy("key_3198"))
	print_t(showIdTable)
	local isSave = true
	local cellSize = CCSizeMake(143, 59)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
            a2 = CCTableViewCell:create()
		    a2:setContentSize(cellSize)
		    local menu = BTSensitiveMenu:create()
		    if(menu:retainCount()>1)then
				menu:release()
				menu:autorelease()
			end
			menu:setAnchorPoint(ccp(0,0))
			menu:setPosition(ccp(0,0))
			a2:addChild(menu,1,1)
			menu:setTouchPriority(-422)
			
			local menuItem = createPlaceBtn(tonumber(showIdTable[a1+1].id))
			menuItem:setAnchorPoint(ccp(0,0.5))
			menuItem:setPosition(ccp(10,59*0.5))
			menu:addChild(menuItem,1,tonumber(showIdTable[a1+1].id))
			menuItem:registerScriptTapHandler(menuItemAction)
			if(_curId == tonumber(showIdTable[a1+1].id))then
				menuItem:setEnabled(false)
			end
			print("==",tonumber(showIdTable[a1+1].id),a1)
			r = a2
		elseif fn == "numberOfCells" then
			local num = #showIdTable
			r = num
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	btnTableView = LuaTableView:createWithHandler(h, CCSizeMake(438, 59))
	btnTableView:setBounceable(true)
	btnTableView:setDirection(kCCScrollViewDirectionHorizontal)
	btnTableView:setPosition(ccp(58, 5))
	btnTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_btnBg:addChild(btnTableView)
	btnTableView:setTouchPriority(-423)

end

-- 创建龙珠 1，2，3，4，5
function createLongZhuAnimSpriteById( id )
	local placeName = {"lzhui","lzlv","lzlan","lzzi","lzcheng"}
	local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/zhuzi/" .. placeName[tonumber(id)] .. "/" .. placeName[tonumber(id)] ), -1,CCString:create(""))
	return animSprite
end

-- 创建场景按钮
function createPlaceBtn( id )
	local data = {
		-- 1
		{normalFile = "po_n.png", selectFile = "po_h.png"},
		-- 2
		{normalFile = "zhu_n.png", selectFile = "zhu_h.png"},
		-- 3
		{normalFile = "ying_n.png", selectFile = "ying_h.png"},
		-- 4
		{normalFile = "jiang_n.png", selectFile = "jiang_h.png"},
		-- 5
		{normalFile = "jin_n.png", selectFile = "jin_h.png"}
	}
	if(name_sprite)then
		name_sprite:removeFromParentAndCleanup(true)
		name_sprite = nil
	end
	local item = CCMenuItemImage:create("images/hunt/" .. data[id].normalFile,"images/hunt/" .. data[id].selectFile, "images/hunt/" .. data[id].selectFile)
	return item
end


-- 创建不变ui
function createNoChangeUI( ... )
	-- 二级背景
 	second_bg = BaseUI.createContentBg(CCSizeMake(535,595))
 	second_bg:setAnchorPoint(ccp(0.5,1))
 	second_bg:setPosition(ccp(backGround:getContentSize().width*0.5,backGround:getContentSize().height-_btnBg:getContentSize().height-45))
 	backGround:addChild(second_bg)

 	-- 名字背景
 	name_bg = CCScale9Sprite:create("images/common/line2.png")
 	name_bg:setContentSize(CCSizeMake(236,38))
 	name_bg:setAnchorPoint(ccp(0.5,1))
 	name_bg:setPosition(ccp(second_bg:getContentSize().width*0.5,576))
 	second_bg:addChild(name_bg)

 	-- 花纹 右边
 	local hua1 = CCSprite:create("images/hunt/hua.png")
 	hua1:setAnchorPoint(ccp(1,1))
 	hua1:setPosition(ccp(second_bg:getContentSize().width-10,second_bg:getContentSize().height-10))
 	second_bg:addChild(hua1)
 	-- 左边
 	local hua2 = CCSprite:create("images/hunt/hua.png")
 	hua2:setAnchorPoint(ccp(1,1))
 	hua2:setPosition(ccp(10,second_bg:getContentSize().height-10))
 	second_bg:addChild(hua2)
 	hua2:setRotation(270)
 	-- 左下
 	local hua3 = CCSprite:create("images/hunt/hua.png")
 	hua3:setAnchorPoint(ccp(1,1))
 	hua3:setPosition(ccp(10,330))
 	second_bg:addChild(hua3)
 	hua3:setRotation(180)
 	-- 右下
 	local hua3 = CCSprite:create("images/hunt/hua.png")
 	hua3:setAnchorPoint(ccp(1,1))
 	hua3:setPosition(ccp(second_bg:getContentSize().width-10,330))
 	second_bg:addChild(hua3)
 	hua3:setRotation(90)


 	-- 下方掉落背景
 	flop_bg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	flop_bg:setContentSize(CCSizeMake(516, 318))
	flop_bg:setAnchorPoint(ccp(0.5, 0))
	flop_bg:setPosition(ccp(second_bg:getContentSize().width*0.5, 7))
	second_bg:addChild(flop_bg)

	-- 上下箭头
	local upSprite = CCSprite:create("images/hunt/right.png")
	upSprite:setAnchorPoint(ccp(1,0.5))
	upSprite:setPosition(ccp(flop_bg:getContentSize().width*0.5,flop_bg:getContentSize().height-5))
	flop_bg:addChild(upSprite,2)
	upSprite:setRotation(270)
	local downSprite = CCSprite:create("images/hunt/right.png")
	downSprite:setAnchorPoint(ccp(1,0.5))
	downSprite:setPosition(ccp(flop_bg:getContentSize().width*0.5,5))
	flop_bg:addChild(downSprite,2)
	downSprite:setRotation(90)

	-- 创建掉落物品tableView
	createItemTableView()

	-- 创建默认场景 1
	createChangeUIByShowId(_curId)
end


-- 创建物品列表
function createItemTableView()
	_flopData = {}
	local cellSize = CCSizeMake(516, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.2,0.5,0.8}
			for i=1,3 do
				if(_flopData[a1*3+i] ~= nil)then
					local item_sprite = createRewardCell(_flopData[a1*3+i])
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(516*posArrX[i],130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_flopData
			r = math.ceil(num/3)
			print("num is : ", num)
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(516, 246))
	goodTableView:setBounceable(true)
	goodTableView:setTouchPriority(-423)
	-- 上下滑动
	goodTableView:setDirection(kCCScrollViewDirectionVertical)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	goodTableView:setPosition(ccp(0,33))
	flop_bg:addChild(goodTableView)
end


-- 创建物品图标
function createRewardCell( cellValues )
	-- 物品
	local iconBg =  ItemSprite.getItemSpriteById(tonumber(cellValues.tid),nil, nil, nil, -422,11112)
	local itemData = ItemUtil.getItemById(cellValues.tid)
    local iconName = itemData.name
   	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.2))
	iconBg:addChild(descLabel)
	return iconBg
end


-- 创建场景相关ui
function createChangeUIByShowId( curId )
	require "db/DB_Huntsoul"
	local data = DB_Huntsoul.getDataById(tonumber(curId))
	
	-- 场景名字
	if(showName)then
		showName:removeFromParentAndCleanup(true)
		showName = nil
	end
	showName = CCRenderLabel:create( data.name, g_sFontPangWa, 28, 1, ccc3(0, 0, 0), type_stroke)
	showName:setAnchorPoint(ccp(0.5, 0.5))
	showName:setColor(showColor[tonumber(curId)])
	showName:setPosition(ccp(name_bg:getContentSize().width*0.5,name_bg:getContentSize().height*0.5))
	name_bg:addChild(showName)

	-- 龙珠
	if(showLongZhu)then
		showLongZhu:removeFromParentAndCleanup(true)
		showLongZhu = nil
	end
	showLongZhu = createLongZhuAnimSpriteById(tonumber(curId))
	showLongZhu:setAnchorPoint(ccp(0.5,0.5))
	showLongZhu:setPosition(ccp(second_bg:getContentSize().width*0.5,450))
	second_bg:addChild(showLongZhu)

	-- 描述
	if(showDes)then
		showDes:removeFromParentAndCleanup(true)
		showDes = nil
	end
	showDes = getDesByCurId(tonumber(curId))
	-- 设置layer锚点
	showDes:ignoreAnchorPointForPosition(false)
	showDes:setAnchorPoint(ccp(0.5,0))
	showDes:setPosition(ccp(second_bg:getContentSize().width*0.5,355))
	second_bg:addChild(showDes,2)

	-- 掉落物品
	print(GetLocalizeStringBy("key_2179"))
	print(data.soulId)
	local itemArr = string.split(data.soulId, ",")
	print_t(itemArr)
	local itemDataArr = {}
	for k,v in pairs(itemArr) do
		local data = {}
		data.tid = v
		table.insert(itemDataArr,data)
	end
	_flopData = {}
	_flopData = itemDataArr
	print(GetLocalizeStringBy("key_2539"))
	print_t(_flopData)
	goodTableView:reloadData()
end


-- 场景按钮回调
function menuItemAction( tag, itemBtn )
	print(GetLocalizeStringBy("key_1954") .. tag)
	-- 音效
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	itemBtn:setEnabled(false)
	if (_curId ~= tag) then
		local curCell = btnTableView:cellAtIndex(_curId-1)
		if(curCell)then
			local menu = tolua.cast(curCell:getChildByTag(1),"CCMenu")
			local menuItem = tolua.cast(menu:getChildByTag(_curId),"CCMenuItemImage")
			menuItem:setEnabled(true)
			menuItem:unselected()
		end
		_curId = tag
		itemBtn:setEnabled(false)
		-- 切换场景
		createChangeUIByShowId(tag)
	end
end


-- 场景描述文字 
function getDesByCurId( id )
	-- 文本内容数据
	local textInfo = {}
	local str = nil
	if(id == 1)then
		str = CCRenderLabel:create(GetLocalizeStringBy("key_1290") , g_sFontName,23,1,ccc3(0x00, 0x00, 0x00),type_stroke)
		str:setColor(ccc3(0xff, 0xff, 0xff))
		-- 文本宽度
		textInfo.width = str:getContentSize().width+6
		textInfo[1] = { content=GetLocalizeStringBy("key_1290"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
	elseif(id == 2)then
		str = CCRenderLabel:create(GetLocalizeStringBy("key_2772") , g_sFontName,23,1,ccc3(0x00, 0x00, 0x00),type_stroke)
		str:setColor(ccc3(0x1A, 0xFD, 0x02))
		-- 文本宽度
		textInfo.width = str:getContentSize().width+6
		textInfo[1] = { content=GetLocalizeStringBy("key_2280"), ntype="label", fontSize=23, color=ccc3(0x1A, 0xFD, 0x02), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[2] = { content=GetLocalizeStringBy("key_1786"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[3] = { content=GetLocalizeStringBy("key_1374"), ntype="label", fontSize=23, color=ccc3(0x1A, 0xFD, 0x02), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[4] = { content=GetLocalizeStringBy("key_3023"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
	elseif(id == 3)then
		str = CCRenderLabel:create(GetLocalizeStringBy("key_3220") , g_sFontName,23,1,ccc3(0x00, 0x00, 0x00),type_stroke)
		str:setColor(ccc3(0x02, 0xFD, 0xFA))
		-- 文本宽度
		textInfo.width = str:getContentSize().width+6
		textInfo[1] = { content=GetLocalizeStringBy("key_1747"), ntype="label", fontSize=23, color=ccc3(0x02, 0xFD, 0xFA), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[2] = { content=GetLocalizeStringBy("key_1786"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[3] = { content=GetLocalizeStringBy("key_1374"), ntype="label", fontSize=23, color=ccc3(0x1A, 0xFD, 0x02), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[4] = { content=GetLocalizeStringBy("key_3023"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
	elseif(id == 4)then
		str = CCRenderLabel:create(GetLocalizeStringBy("key_1496") , g_sFontName,23,1,ccc3(0x00, 0x00, 0x00),type_stroke)
		str:setColor(ccc3(0xE8, 0x02, 0xFD))
		-- 文本宽度
		textInfo.width = str:getContentSize().width+6
		textInfo[1] = { content=GetLocalizeStringBy("key_2311"), ntype="label", fontSize=23, color=ccc3(0xE8, 0x02, 0xFD), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[2] = { content=GetLocalizeStringBy("key_3160"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[3] = { content=GetLocalizeStringBy("key_1374"), ntype="label", fontSize=23, color=ccc3(0x1A, 0xFD, 0x02), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[4] = { content="、", ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[5] = { content=GetLocalizeStringBy("key_1087"), ntype="label", fontSize=23, color=ccc3(0x02, 0xFD, 0xFA), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[6] = { content=GetLocalizeStringBy("key_3023"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
	else
		str = CCRenderLabel:create(GetLocalizeStringBy("key_2880") , g_sFontName,23,1,ccc3(0x00, 0x00, 0x00),type_stroke)
		str:setColor(ccc3(0xFD, 0xA1, 0x02))
		-- 文本宽度
		textInfo.width = str:getContentSize().width+6
		textInfo[1] = { content=GetLocalizeStringBy("key_2330"), ntype="label", fontSize=23, color=ccc3(0xFD, 0xA1, 0x02), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[2] = { content=GetLocalizeStringBy("key_3160"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[5] = { content=GetLocalizeStringBy("key_1087"), ntype="label", fontSize=23, color=ccc3(0x02, 0xFD, 0xFA), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[4] = { content="、", ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[3] = { content=GetLocalizeStringBy("key_3374"), ntype="label", fontSize=23, color=ccc3(0xE8, 0x02, 0xFD), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
		textInfo[6] = { content=GetLocalizeStringBy("key_3042"), ntype="label", fontSize=23, color=ccc3(0xff, 0xff, 0xff), strokeSize=1,strokeColor=ccc3(0x00,0x00,0x00) }
	end
	local text_font = nil 
	-- 越南版本
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
		text_font = str
	else
		text_font = LuaCCLabel.createRichText(textInfo)
	end
	return text_font or " "
end













