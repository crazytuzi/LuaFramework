-- FileName: ShowTenGetDialog.lua 
-- Author: licong 
-- Date: 14-7-15 
-- Purpose: 展示召唤十次后获得的战魂


module("ShowTenGetDialog", package.seeall)


local _bgLayer                  	= nil
local _backGround 					= nil
local _second_bg  					= nil

local _showItems 					= nil
local _extraData 					= nil
local _isActivity 					= nil
local _materialData 				= nil

function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil
	_second_bg  					= nil

	_showItems 						= nil
	_extraData 						= nil
	_isActivity 					= false
	_materialData 					= nil

end

--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:创建展示tableView的cell
	@param 	:p_data cell数据, p_index 第几次召唤
	@return :
--]]
function createCell( p_data, p_index )
	print("p_data")
	print_t(p_data)
	local cell = CCTableViewCell:create()

	local index = p_index
	if(_isActivity)then
		index = index - 1
	end
	if(table.isEmpty(p_data))then
		-- 第1行 额外获得中秋道具
		local str = GetLocalizeStringBy("lic_1222")
		local font1 = CCLabelTTF:create(str,g_sFontName,23)
		font1:setColor(ccc3(0xff,0xff,0xff))
		font1:setAnchorPoint(ccp(0,1))
		font1:setPosition(ccp(10,100))
		cell:addChild(font1)
		if(not table.isEmpty(_extraData))then
			local i = 0
			local posY = font1:getPositionY()-font1:getContentSize().height-30
			for k,v in pairs(_extraData) do
				i = i + 1 
				local itemData = ItemUtil.getItemById(k)
				local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
				-- 道具图标
		        local itemFont = {}
		        itemFont[1] = CCSprite:create("images/common/yuebing.png")
		        itemFont[2] = CCLabelTTF:create(itemData.name, g_sFontName, 23)
		        itemFont[2]:setColor(name_color)
		        itemFont[3] = CCLabelTTF:create(" * " .. v, g_sFontName, 23)
		        local font2 = BaseUI.createHorizontalNode(itemFont)
		        font2:setAnchorPoint(ccp(0,0))
				font2:setPosition(ccp(10,posY))
				cell:addChild(font2)
				posY = posY - 30
			end
		else
			local str = GetLocalizeStringBy("lic_1223")
			local font2 = CCLabelTTF:create(str,g_sFontName,23)
			font2:setColor(ccc3(0xff,0xff,0xff))
			font2:setAnchorPoint(ccp(0,1))
			font2:setPosition(ccp(10,font1:getPositionY()-font1:getContentSize().height-10))
			cell:addChild(font2)
		end
		return cell
	end

	-- 掉落材料
	if( p_data.isMaterial == true )then 
		-- 第1行 获得战魂材料
		local str = GetLocalizeStringBy("lic_1638")
		local font1 = CCLabelTTF:create(str,g_sFontName,23)
		font1:setColor(ccc3(0xff,0xff,0xff))
		font1:setAnchorPoint(ccp(0,1))
		font1:setPosition(ccp(10,100))
		cell:addChild(font1)
	
		local i = 0
		local posY = font1:getPositionY()-font1:getContentSize().height-30
		for k,v in pairs(_materialData) do 
			i = i + 1 
			local itemData = ItemUtil.getItemById(k)
			local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
			-- 道具图标
	        local itemFont = {}
	        itemFont[1] = CCLabelTTF:create(itemData.name, g_sFontName, 23)
	        itemFont[1]:setColor(name_color)
	        itemFont[2] = CCLabelTTF:create(" * " .. v, g_sFontName, 23)
	        local font2 = BaseUI.createHorizontalNode(itemFont)
	        font2:setAnchorPoint(ccp(0,0))
			font2:setPosition(ccp(10,posY))
			cell:addChild(font2)
			posY = posY - 30
		end
		
		return cell
	end

	-- 第1行 第几次召唤
	local str = string.format(GetLocalizeStringBy("lic_1154"), index)
	local font1 = CCLabelTTF:create(str,g_sFontName,23)
	font1:setColor(ccc3(0xff,0xff,0xff))
	font1:setAnchorPoint(ccp(0,1))
	font1:setPosition(ccp(10,100))
	cell:addChild(font1)

	-- 第2行 将魂龙珠
	local str = GetLocalizeStringBy("lic_1156")
	local font2 = CCLabelTTF:create(str,g_sFontName,23)
	font2:setColor(ccc3(0xff,0xff,0xff))
	font2:setAnchorPoint(ccp(0,1))
	font2:setPosition(ccp(10,font1:getPositionY()-font1:getContentSize().height-2))
	cell:addChild(font2)
	-- 猎到的战魂名字
	local itemStr = nil
	local itemColor = nil
	if(p_data[2])then
		local itemData = ItemUtil.getItemById(p_data[2].item_template_id)
		itemColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
		itemStr = itemData.name
	else
		itemStr = GetLocalizeStringBy("lic_1223")
		itemColor = ccc3(0xff,0xff,0xff)
	end
	local itemName = CCLabelTTF:create(itemStr,g_sFontName,23)
	itemName:setColor(itemColor)
	itemName:setAnchorPoint(ccp(0,1))
	itemName:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width,font2:getPositionY()))
	cell:addChild(itemName)
	

	-- 第3行 金魂龙珠
	local font3 = nil
	if(p_data[3])then
		local str = GetLocalizeStringBy("lic_1157")
		font3 = CCLabelTTF:create(str,g_sFontName,23)
		font3:setColor(ccc3(0xff,0xff,0xff))
		font3:setAnchorPoint(ccp(0,1))
		font3:setPosition(ccp(10,font2:getPositionY()-font2:getContentSize().height-2))
		cell:addChild(font3)
		-- 猎到的战魂名字
		local itemData = ItemUtil.getItemById(p_data[3].item_template_id)
		local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
		local itemName = CCLabelTTF:create(itemData.name,g_sFontName,23)
		itemName:setColor(name_color)
		itemName:setAnchorPoint(ccp(0,1))
		itemName:setPosition(ccp(font3:getPositionX()+font3:getContentSize().width,font3:getPositionY()))
		cell:addChild(itemName)
	end

	-- 第4行 额外获得经验战魂
	if(p_data[1])then
		local str = GetLocalizeStringBy("lic_1158")
		local font4 = CCLabelTTF:create(str,g_sFontName,23)
		font4:setColor(ccc3(0xff,0xff,0xff))
		font4:setAnchorPoint(ccp(0,1))
		cell:addChild(font4)
		if(p_data[3] and font3 ~= nil)then
			font4:setPosition(ccp(10,font3:getPositionY()-font3:getContentSize().height-2))
		else
			font4:setPosition(ccp(10,font2:getPositionY()-font2:getContentSize().height-2))
		end
		-- 猎到的战魂名字
		local itemData = ItemUtil.getItemById(p_data[1].item_template_id)
		local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
		local itemName = CCLabelTTF:create(itemData.name,g_sFontName,23)
		itemName:setColor(name_color)
		itemName:setAnchorPoint(ccp(0,1))
		itemName:setPosition(ccp(font4:getPositionX()+font4:getContentSize().width,font4:getPositionY()))
		cell:addChild(itemName)
	end

	return cell
end

--[[
	@des 	:创建展示tableView
	@param 	:
	@return :
--]]
function createTableView( ... )
	local cellSize = CCSizeMake(450, 115)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			r = createCell(_showItems[a1+1],a1+1)
		elseif fn == "numberOfCells" then
			r =  #_showItems
		else
		end
		return r
	end)

	local tableView = LuaTableView:createWithHandler(h, CCSizeMake(450, 370))
	tableView:setBounceable(true)
	tableView:setTouchPriority(-423)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	tableView:setPosition(ccp(_second_bg:getContentSize().width*0.5,_second_bg:getContentSize().height*0.5))
	_second_bg:addChild(tableView)
		-- 设置单元格升序排列
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,-420,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(525, 540))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-425)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1152"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 提示
	local fontTip = CCRenderLabel:create(GetLocalizeStringBy("lic_1153"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTip:setAnchorPoint(ccp(0.5,1))
    fontTip:setColor(ccc3(0x00, 0xff, 0x18))
    fontTip:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-45))
    _backGround:addChild(fontTip)

	-- 二级背景
	_second_bg = BaseUI.createContentBg(CCSizeMake(450,370))
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-85))
 	_backGround:addChild(_second_bg)
	
	-- 确定按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
    normalSprite:setContentSize(CCSizeMake(160,64))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
    selectSprite:setContentSize(CCSizeMake(160,64))
    local yesMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    yesMenuItem:setAnchorPoint(ccp(0.5,0))
    yesMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.5, 20))
    yesMenuItem:registerScriptTapHandler(closeButtonCallback)
    menu:addChild(yesMenuItem)
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1097"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0.5,0.5))
    itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont1:setPosition(ccp(yesMenuItem:getContentSize().width*0.5,yesMenuItem:getContentSize().height*0.5))
    yesMenuItem:addChild(itemfont1)

    -- 创建列表
    createTableView()
end


--[[
	@des 	:召唤十次获得的战魂提示框
	@param 	:p_items 获得的所有战魂,p_tExtra 活动额外掉落道具
	@return :
--]]
function showTip( p_items, p_tExtra, p_p_material )
	-- 初始化
	init()

	-- 十次结果
	_showItems = HuntSoulData.getDataForCallTenTip(p_items)
	-- print("_showItems")
	-- print_t(_showItems)
	-- 是否开启额外掉落活动
    require "script/ui/rechargeActive/ActiveCache"
	_isActivity = ActiveCache.getIsExtraDropAcitiveInHunt()
	-- 活动额外掉落数据
	_extraData = p_tExtra
	-- 掉落材料
	_materialData = p_p_material

	if(_isActivity)then
		local tab = {}
		table.insert(_showItems,1,tab)
	end

	-- 掉落材料
	if( not table.isEmpty(_materialData) )then 
		local tab = {["isMaterial"] = true}
		table.insert(_showItems,tab)
	end

	-- 创建提示layer
	createTipLayer()
end








