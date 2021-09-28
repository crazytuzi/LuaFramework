-- Filename：	ShowAwardWayLayer.lua
-- Author：		Cheng Liang
-- Date：		2014-4-9
-- Purpose：		显示该物品的获得途径

module("ShowAwardWayLayer", package.seeall)

--require "script/ui/copy/ShowAwardWaySprite"
require "script/ui/copy/FortsLayout"

local _bgLayer 				= nil
local _bgSprite 			= nil
local _gid 					= nil

local _fullItemInfo 		= nil
local _dropCopyStrongholds 	= nil		-- 掉落的副本和据点表

local function init()
	_bgLayer 				= nil
	_bgSprite 				= nil
	_gid 					= nil
	_fullItemInfo 			= nil
	_dropCopyStrongholds 	= nil		-- 掉落的副本和据点表
end


--[[
	@desc	 处理touches事件
	@para 	 string event
	@return
--]]
local function onTouchesHandler( eventType, x, y )

	if (eventType == "began") then
		print("began fortinfoLayer")

	    return true
    elseif (eventType == "moved") then

    else
        print("end")
	end
end

--[[
	@desc	 回调onEnter和onExit时间
	@para 	 string event
	@return  void
--]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -410, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 神兵碎片 获得跳转回调
function godWeaponItemCallFun(tag, itembtn )
	-- 功能节点判断
	if not DataCache.getSwitchNodeState(ksSwitchGodWeapon) then
		return
	end
	-- 背包满了
	if(ItemUtil.isBagFull() == true )then
		closeAction()
		return
	end
	closeAction()
	-- 神兵副本
	require "script/ui/godweapon/godweaponcopy/GodWeaponCopyMainLayer"
	local pLayer = GodWeaponCopyMainLayer.createLayer()
	MainScene.setMainSceneViewsVisible(false,false,false)
	MainScene.changeLayer(pLayer,"GodWeaponCopyMainLayer")
end

-- 兵符碎片 获得跳转回调
function tallyItemCallFun(tag, itembtn )
	-- 功能节点判断
	if not DataCache.getSwitchNodeState(ksSwitchMoon) then
		return
	end
	-- 背包满了
	if(ItemUtil.isBagFull() == true )then
		closeAction()
		return
	end
	closeAction()
	-- 水月之境
	require "script/ui/moon/MoonLayer"
	MoonLayer.show()
end

-- 关闭
function closeAction( tag, itembtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

-- 创建内容
local function createContentBg()

	local height = 600

	local bgSpriteSize = _bgSprite:getContentSize()
	-- 掉落物品背景
	local bg_sprite_1 = CCScale9Sprite:create("images/common/bg/9s_1.png")
	bg_sprite_1:setContentSize(CCSizeMake(585, height))
	bg_sprite_1:setAnchorPoint(ccp(0.5, 1))
	-- bg_sprite_1:setScale(MainScene.elementScale)
	bg_sprite_1:setPosition(ccp(bgSpriteSize.width*0.5, bgSpriteSize.height - 165))
	_bgSprite:addChild(bg_sprite_1)
	-- 掉落标题
	local titleSprite = CCScale9Sprite:create("images/common/astro_labelbg.png")
	titleSprite:setContentSize(CCSizeMake(200, 35))
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- titleSprite:setScale(MainScene.elementScale)
	titleSprite:setPosition(ccp(bg_sprite_1:getContentSize().width*0.5, bg_sprite_1:getContentSize().height))
	bg_sprite_1:addChild(titleSprite)
	-- 标题文字
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3356"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width*0.5 - titleLabel:getContentSize().width*0.5, titleSprite:getContentSize().height*0.5 + titleLabel:getContentSize().height*0.5))
    titleSprite:addChild(titleLabel)

    -- 神兵碎片特殊处理
    if( tonumber(_fullItemInfo.itemDesc.id) >= 7000001 and tonumber(_fullItemInfo.itemDesc.id) <= 8000000 ) then
    	local bgSprite = CCSprite:create("images/active/activeList/activeItem_bg.png")
		bgSprite:setAnchorPoint(ccp(0.5,1))
		bgSprite:setPosition(ccp(bg_sprite_1:getContentSize().width*0.5,bg_sprite_1:getContentSize().height-20))
    	bg_sprite_1:addChild(bgSprite)
    	bgSprite:setScale(0.98)

    	require "script/ui/active/ActiveList"
    	local menu = CCMenu:create()
    	menu:setAnchorPoint(ccp(0,0))
    	menu:setPosition(ccp(0,0))
    	menu:setTouchPriority(-411)
    	bgSprite:addChild(menu)
    	local meunItem = ActiveList.createActiveMenuItem({name = "godweapon",tag = ActiveList._ksTagGodWeaponCopy, switchId = ksSwitchGodWeapon },true)
    	meunItem:setAnchorPoint(ccp(0.5,0.5))
    	meunItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5))
    	menu:addChild(meunItem)
    	meunItem:registerScriptTapHandler(godWeaponItemCallFun)

    	-- 点击前往
    	local passedSprite = CCSprite:create("images/copy/forward.png")
	    passedSprite:setAnchorPoint(ccp(0, 0.5))
	    passedSprite:setPosition(ccp(meunItem:getContentSize().width*0.7, meunItem:getContentSize().height*0.32))
	    meunItem:addChild(passedSprite,10,2)
	elseif( tonumber(_fullItemInfo.itemDesc.id) >= 9000001 and tonumber(_fullItemInfo.itemDesc.id) <= 9100000 ) then
		-- 兵符碎片
    	local bgSprite = CCSprite:create("images/active/activeList/activeItem_bg.png")
		bgSprite:setAnchorPoint(ccp(0.5,1))
		bgSprite:setPosition(ccp(bg_sprite_1:getContentSize().width*0.5,bg_sprite_1:getContentSize().height-20))
    	bg_sprite_1:addChild(bgSprite)
    	bgSprite:setScale(0.98)

    	require "script/ui/active/ActiveList"
    	local menu = CCMenu:create()
    	menu:setAnchorPoint(ccp(0,0))
    	menu:setPosition(ccp(0,0))
    	menu:setTouchPriority(-411)
    	bgSprite:addChild(menu)
    	local meunItem = ActiveList.createActiveMenuItem({name = "shuiyue",tag = ActiveList._ksTagShuiYue, switchId = ksSwitchMoon },true)
    	meunItem:setAnchorPoint(ccp(0.5,0.5))
    	meunItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5))
    	menu:addChild(meunItem)
    	meunItem:registerScriptTapHandler(tallyItemCallFun)

    	-- 点击前往
    	local passedSprite = CCSprite:create("images/copy/forward.png")
	    passedSprite:setAnchorPoint(ccp(0, 0.5))
	    passedSprite:setPosition(ccp(meunItem:getContentSize().width*0.7, meunItem:getContentSize().height*0.32))
	    meunItem:addChild(passedSprite,10,2)
    else
	    if(table.isEmpty(_dropCopyStrongholds) == true)then
	    	-- 标题文字
			local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3078"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    tipLabel:setColor(ccc3(0xff, 0xff, 0xff))
		    tipLabel:setAnchorPoint(ccp(0.5, 0.5))
		    tipLabel:setPosition(ccp(bg_sprite_1:getContentSize().width*0.5 , bg_sprite_1:getContentSize().height*0.5))
		    bg_sprite_1:addChild(tipLabel)
	    else
			-- 创建TableView
			local tableView = createTableView(height-40)
			tableView:setPosition(ccp(5, 20))
			bg_sprite_1:addChild(tableView)
		end
	end
end

--[[
	@desc	显示选中的副本中据点的信息
	@para 	table fortData 据点的信息
	@return void
--]]
local function showLayoutsByFort( tempCopyInfo )
	closeAction()
	local fortsLayer = FortsLayout.createFortsLayout(tempCopyInfo, tempCopyInfo.targetStronghold.id)
	MainScene.changeLayer(fortsLayer, "fortsLayer")
end

-- 创建TableView
function createTableView(height)
	local cellBg = CCSprite:create("images/copy/copyframe.png")
	cellSize = cellBg:getContentSize()			--计算cell大小

	local myScale = 575.0/640

	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
			-- r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			require "script/ui/copy/ShowAwardWayCell"
			a2 = ShowAwardWayCell.createCopyCell(_dropCopyStrongholds[a1 +1 ])
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_dropCopyStrongholds
		elseif fn == "cellTouched" then

			print("cellTouched:dddd " .. (a1:getIdx() + 1))
            require "script/ui/hero/HeroPublicUI"
			if(ItemUtil.isBagFull() == true)then
				--AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
				closeAction()
				return
			elseif HeroPublicUI.showHeroIsLimitedUI() then
				closeAction()
                return
			end

			local tempCopyInfo = _dropCopyStrongholds[a1:getIdx() + 1]
			if(tempCopyInfo.isGray and tempCopyInfo.isGray == true)then
				AnimationTip.showTip(GetLocalizeStringBy("key_2669"))
			else
				showLayoutsByFort(tempCopyInfo)
			end

		elseif (fn == "scroll") then

		end
		return r
	end)
	myTableView = LuaTableView:createWithHandler(h, CCSizeMake(575, height))
    myTableView:setAnchorPoint(ccp(0,0))
	myTableView:setBounceable(true)
	myTableView:setTouchPriority(-411)
	return myTableView
end



-- 创建背景
local function createBgSprite()

	local height = 820

	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	_bgSprite:setContentSize(CCSizeMake(630, height))
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setScale(MainScene.elementScale)
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(_bgSprite)

	local bgSpriteSize = _bgSprite:getContentSize()

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	_bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-411)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.95, _bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

    -- 碎片图标
    local iconSprite = ItemSprite.getItemSpriteByItemId(_fullItemInfo.itemDesc.id)
    iconSprite:setAnchorPoint(ccp(0, 1))
    iconSprite:setPosition(ccp(50, bgSpriteSize.height - 50))
    _bgSprite:addChild(iconSprite)

    -- 名称
    local itemName = _fullItemInfo.itemDesc.name
	if(tonumber(_fullItemInfo.item_template_id) >= 1800000 and tonumber(_fullItemInfo.item_template_id)<= 1900000 ) then
		itemName = ItemSprite.getStringByFashionString(itemName)
	end
    local nameColor = HeroPublicLua.getCCColorByStarLevel(_fullItemInfo.itemDesc.quality)
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(160, bgSpriteSize.height - 50))
    _bgSprite:addChild(nameLabel)

    -- 描述
    -- added by zhz
    local itemDesc= _fullItemInfo.itemDesc.desc
	if(tonumber(_fullItemInfo.item_template_id) >= 1800000 and tonumber(_fullItemInfo.item_template_id)<= 1900000 ) then
		itemDesc = ItemSprite.getStringByFashionString(itemDesc)
	end

	local descLabel = CCLabelTTF:create(itemDesc, g_sFontName, 23, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(160, bgSpriteSize.height - 110))
	_bgSprite:addChild(descLabel)

	-- 星级
	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0, 0.5))
    starSp:setPosition(ccp(430, bgSpriteSize.height - 50))
    _bgSprite:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(_fullItemInfo.itemDesc.quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setAnchorPoint(ccp(0, 0.5))
    potentialLabel:setPosition(ccp(400, bgSpriteSize.height - 50))
    _bgSprite:addChild(potentialLabel)
end

-- 处理一些数据
function handleData()
	_fullItemInfo = ItemUtil.getFullItemInfoByGid(_gid)
	_dropCopyStrongholds = {}
	if( _fullItemInfo.itemDesc.dropStrongHold ~= nil and _fullItemInfo.itemDesc.dropStrongHold ~= "" )then
		local stronghold_arr = string.split(_fullItemInfo.itemDesc.dropStrongHold, ",")

		local remoteNCopyInfo = DataCache.getReomteNormalCopyData()
		require "db/DB_Stronghold"
		require "db/DB_Copy"
		for k,s_id in pairs(stronghold_arr) do
			local strongholdInfo = DB_Stronghold.getDataById(s_id)
			local r_copyInfo = nil
			for k, copyInfo in pairs(remoteNCopyInfo) do
				if( tonumber(copyInfo.copy_id)== tonumber(strongholdInfo.copy_id))then
					-- 能找到说明已经开启
					r_copyInfo = copyInfo
					r_copyInfo.copyInfo = DB_Copy.getDataById(copyInfo.copy_id)
					r_copyInfo.targetStronghold = strongholdInfo
					break
				end
			end
			if(r_copyInfo == nil)then
				-- 该副本未开启
				r_copyInfo = {}
				r_copyInfo.uid = UserModel.getUserUid()
				r_copyInfo.copy_id = tonumber(strongholdInfo.copy_id)
				r_copyInfo.score = 0
				r_copyInfo.prized_num = 0
				r_copyInfo.isGray = true
				r_copyInfo.va_copy_info = {}
				r_copyInfo.va_copy_info.progress = {}
				r_copyInfo.va_copy_info.defeat_num = {}
				r_copyInfo.va_copy_info.reset_num = {}
				r_copyInfo.copyInfo = DB_Copy.getDataById(r_copyInfo.copy_id)
				r_copyInfo.targetStronghold = strongholdInfo

			end
			table.insert(_dropCopyStrongholds, r_copyInfo)
		end
	end
end


-- 创建并展示
function showLayer(gid)
	init()
	print("gid====", gid)
	_gid = gid

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 处理一些数据
	handleData()

	-- 创建背景
	createBgSprite()
	-- 创建内容
	createContentBg()

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 999)
end
