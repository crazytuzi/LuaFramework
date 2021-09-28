-- Filename：	BagLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-7-10
-- Purpose：		背包入口

module ("BagLayer", package.seeall)

require "script/network/RequestCenter"
require "script/ui/bag/ItemCell"
require "script/ui/bag/EquipBagCell"
require "script/ui/bag/TreasBagCell"
require "script/ui/bag/FashionCell"
require "script/ui/bag/GodWeaponBagCell"
require "script/ui/bag/RuneBagCell"
require "script/ui/bag/PocketBagCell"
require "script/ui/bag/TallyBagCell"
require "script/ui/bag/ChariotCell"

require "script/ui/tip/AnimationTip"
require "script/ui/main/MainScene"
require "script/ui/item/ItemUtil"
require "script/utils/LuaUtil"
require "script/ui/bag/BagUtil"
require "script/model/user/UserModel"
require "script/ui/tip/AlertTip"
require "script/ui/bag/UseItemLayer"
require "script/ui/item/GodWeaponItemUtil"
require "script/ui/chariot/ChariotMainData"


Tag_Init_Props  	= 10001
Tag_Init_Arming 	= 10002
Tag_Init_Treas		= 10003
Tag_Init_ArmFrag	= 10004
Tag_Init_Dress		= 10005
Tag_Init_GodWeapon	= 10006 -- 神兵背包
Tag_Init_GodWeaponFrag	= 10007 -- 神兵碎片背包
Tag_Init_Rune		= 10008 -- 符印背包
Tag_Init_RuneFrag	= 10009 -- 符印碎片背包
Tag_Init_pocket		= 10010 -- 锦囊背包
Tag_Init_Tally		= 10011 -- 兵符背包
Tag_Init_TallyFrag	= 10012 -- 兵符碎片背包
Tag_Init_Chariot    = 10013 -- 战车背包

Type_Bag_Arm_Frag	= 250 -- 主界面装备按钮背包
Type_Bag_Prop_Treas	= 251 -- 主菜单背包按钮背包
Type_Bag_GodWeapon  = 252 -- 主界面神兵按钮背包
Type_Bag_Rune  		= 253 -- 符印按钮背包
Type_Bag_Pocket  	= 254 -- 锦囊按钮背包
Type_Bag_Treas  	= 255 -- 宝物按钮背包
Type_Bag_Tally  	= 256 -- 兵符按钮背包
Type_Bag_Chariot    = 257 -- 战车按钮背包

local Type_Prop_Sell	 			= 1 -- 道具出售
local Type_Arm_Sell	 				= 2 -- 装备出售
local Type_Treas_Sell	 			= 3 -- 宝物出售
local Type_ArmFrag_Sell	 			= 4 -- 装备碎片出售
local Type_Dress_Sell	 			= 5 -- 时装出售
local Type_GodWeapon_Sell	 		= 6 -- 神兵出售 -- 暂不出售
local Type_GodWeaponFrag_Sell	 	= 7 -- 神兵碎片出售 -- 暂不出售

local IMG_PATH = "images/common/"	

local _initTag 						= nil

local bgLayer  						= nil
local myTableView  					= nil

local menu 							= nil -- 按钮Menu

local toolsMenuItem					= nil -- 道具按钮
local equipMenuItem 				= nil -- 装备按钮
local treasMenuItem					= nil -- 宝物按钮
local armFragMenuItem 				= nil -- 装备碎片按钮
local dressMenuItem 				= nil -- 时装按钮
local _godWeaponMenuItem 			= nil -- 神兵背包按钮
local _godWeaponFragMenuItem 		= nil -- 神兵碎片按钮
local _runeMenuItem 				= nil -- 符印背包按钮
local _runeFragMenuItem 			= nil -- 符印碎片按钮
local _pocketMenuItem 				= nil -- 锦囊按钮
local _tallyMenuItem 				= nil -- 兵符按钮
local _tallyFragMenuItem 			= nil -- 兵符碎片按钮
local _chariotMenuItem              = nil -- 战车按钮

local expandBtn						= nil -- 扩充按钮
local sellBtn						= nil -- 出售按钮

local curMenuItem  				    = nil -- 当前按钮

local whichSell 					= nil -- 判断哪类的卖出

local curData 						= {}  -- 背包的数据源


local visiableCellNum			 	= nil --当前机型可视的cell个数

local bagInfo 						= nil

-------------- 使用 -----------------
local curUseItemTempID 		= nil				-- 使用物品的ID
local curUseItemNum 		= nil				-- 使用物品的个数 
local curUseItemGid 		= nil				-- 使用物品的GID
local curUserItemInfo 		= nil				-- 当前使用物品的详细信息

--------------  出售 -----------------
local _sellEquipList 		= nil				-- 选择出售物品的列表 
local _sellBottomSprite 	= nil				-- 出售时的底部背景 

local _itemNumLabel 		= nil 				-- 出售的数量
local _itemTotalCoinLabel 	= nil				-- 总获得


local middleSellMenuBar		= nil				-- 出售时的按钮Bar

local isNeedAnimation 		= true 				-- 是否需要cell动画 

local itemNumbersSprite 	= nil 				-- 装备个数
local btnFrameSp			= nil

local _useItemTableViewOffset = nil

local _bag_type 			= nil 				-- 是哪个背包

local _isInRune 			= false				-- 是否从主界面进入符印背包

--------------- 星级出售 ----------------------------------------
-- 按星级出售层tag
local _ksTagLayerStarSell = 5001
-- 星级出售tag
local _ksTagStarLevelSell = 6001
-- 星级出售面板GetLocalizeStringBy("key_1284")按钮tag
local _ksTagStarSellPanelCloseBtn = 7001
-- 星级出售面板“取消选择”按钮tag
local _ksTagStarSellPanelSelectAll = 7002
-- 星级出售面板“选择全部”按钮tag
local _ksTagStarSellPanelCancel = 7003
-- 星级出售面板“确定”按钮tag
local _ksTagStarSellPanelSure = 7004
-- 星级出售面板菜单tag
local _ksTagStarSellPanelMenu = 8001
-- 全部选择按钮
local _ccButtonSelectAll  = nil
-- 取消选择按钮
local _ccButtonCancel  = nil
-- 按星级出售菜单上的menu
local _ccMenuStarSell	= nil
-- 按星级出售按钮
local starSellBtn = nil
--------------------------------------------
local _tipSprite      = nil        -- 装备碎片标签提示数字
local _tipNum         = 0 		   -- 提示数字	

----------------- 神兵碎片合成个数提示 ---------------------------
local _godWeaponTipSprite     	= nil        -- 神兵碎片标签提示数字
local _godWeaponTipNum         	= 0 		 -- 神兵碎片提示数字	
----------------- 符印碎片合成个数提示 ---------------------------
local _runeTipSprite      		= nil        -- 符印碎片标签提示数字
local _runeTipNum        		= 0 		 -- 符印碎片提示数字	
----------------- 兵符碎片合成个数提示 ---------------------------
local _tallyTipSprite      		= nil        -- 兵符碎片标签提示数字
local _tallyTipNum        		= 0 		 -- 兵符碎片提示数字	

-- 使用物品屏幕偏移位置 	
local _markItemOffsetY 					= nil

local _curOpenIndex 					= nil -- 当前点开的cellindex
local _lastOpenIndex 					= nil -- 上次点开的cellindex

local _openCellHeight 					= 128

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init()
	_initTag 						= nil
	bgLayer  						= nil
	myTableView  					= nil
	menu 							= nil -- 按钮Menu
	toolsMenuItem					= nil -- 道具按钮
	equipMenuItem 					= nil -- 装备按钮
	treasMenuItem					= nil -- 宝物按钮
	armFragMenuItem 				= nil -- 装备碎片按钮
	dressMenuItem 					= nil -- 时装按钮
	_godWeaponMenuItem 				= nil -- 神兵背包按钮
	_godWeaponFragMenuItem 			= nil -- 神兵碎片按钮
	_runeMenuItem 					= nil -- 符印背包按钮
	_runeFragMenuItem 				= nil -- 符印碎片按钮
	_pocketMenuItem 				= nil -- 锦囊按钮
	_tallyMenuItem 					= nil -- 兵符按钮
	_tallyFragMenuItem 				= nil -- 兵符碎片按钮
	expandBtn						= nil -- 扩充按钮
	sellBtn							= nil -- 出售按钮
	curMenuItem  				    = nil -- 当前按钮
	whichSell 						= nil -- 判断哪类的卖出
	curData 						= {}  -- 背包的数据源
	visiableCellNum			 		= nil --当前机型可视的cell个数
	bagInfo 						= nil
	curUseItemTempID 				= nil -- 使用物品的ID
	curUseItemNum 					= nil -- 使用物品的个数 
	curUseItemGid 					= nil -- 使用物品的GID
	curUserItemInfo 				= nil -- 当前使用物品的详细信息
	_sellEquipList 					= nil -- 选择出售物品的列表 
	_sellBottomSprite 				= nil -- 出售时的底部背景 
	_itemNumLabel 					= nil -- 出售的数量
	_itemTotalCoinLabel 			= nil -- 总获得
	middleSellMenuBar				= nil -- 出售时的按钮Bar
	isNeedAnimation 				= true -- 是否需要cell动画 
	itemNumbersSprite 				= nil -- 装备个数
	btnFrameSp						= nil
	_useItemTableViewOffset 		= nil
	_bag_type 						= nil -- 是哪个背包

	_ccButtonSelectAll  			= nil
	_ccButtonCancel 				= nil
	_ccMenuStarSell					= nil
	starSellBtn 					= nil
	_tipSprite      				= nil -- 装备碎片标签提示数字
	_tipNum        					 = 0  -- 提示数字	

	_godWeaponTipSprite     		= nil -- 神兵碎片标签提示数字
	_godWeaponTipNum         		= 0   -- 神兵碎片提示数字	
	_runeTipSprite      			= nil -- 符印碎片标签提示数字
	_runeTipNum        				= 0   -- 符印碎片提示数字	
	_tallyTipSprite      			= nil
	_tallyTipNum        			= 0 
	_isInRune 						= false
	_curOpenIndex 					= nil
	_lastOpenIndex 					= nil

	----------------战车-----------------
	_chariotMenuItem = nil            --战车背包中的战车按钮
end

------------------------------------------------------------- 背包记忆 -------------------------------------------------------------
-- 道具背包
local _markUseItemId 					= nil  	-- 标记使用物品的itemid
local _markUseNextItemId 				= nil	-- 下一个物品
local _propOffset 						= nil 	-- 道具背包偏移量
-- 装备背包
local _equipOffset 						= nil 	
local _markEquipItemId 					= nil
-- 装备碎片背包
local _equipFragOffset					= nil
local _markEquipFragItemId 				= nil 
local _markEquipFragNextItemId 			= nil
-- 宝物背包
local _treasOffset 						= nil 
local _markTreasureItemId 				= nil
-- 时装背包
local _dressOffset 						= nil 
local _markDressItemId 					= nil
-- 神兵背包
local _godWeaponOffset 					= nil 
local _markGodItemId				 	= nil
-- 神兵碎片背包
local _godWeaponFragOffset 				= nil 
local _markGodWeaponFragItemId 			= nil 
local _markGodWeaponFragNextItemId 		= nil
-- 符印背包
local _runeOffset 						= nil 
-- 符印碎片背包
local _runeFragOffset  					= nil
local _markRuneFragItemId 				= nil 
local _markRuneFragNextItemId 			= nil
-- 锦囊背包
local _pocketOffset  					= nil
local _markPocketItemId				 	= nil
-- 兵符背包
local _tallyOffset 						= nil 
local _markTallyItemId				 	= nil
-- 兵符碎片背包
local _tallyFragOffset 					= nil 
local _markTallyFragItemId 				= nil 
local _markTallyFragNextItemId 			= nil


--[[
	@des 	: 设置偏移量
	@param 	: 
	@return : 
--]]
function saveBagLastOffset()
	-- if(bgLayer == nil)then 
	-- 	return
	-- end
	-- if(#curData <= 0)then 
	-- 	return
	-- end
	-- if(curMenuItem == toolsMenuItem) then
	-- 	_propOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == equipMenuItem)then
	-- 	_equipOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == armFragMenuItem)then
	-- 	_equipFragOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == treasMenuItem)then
	-- 	_treasOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == dressMenuItem)then
	-- 	_dressOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == _godWeaponMenuItem)then
	-- 	_godWeaponOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == _godWeaponFragMenuItem)then
	-- 	_godWeaponFragOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == _runeMenuItem)then
	-- 	_runeOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == _runeFragMenuItem)then
	-- 	_runeFragOffset = myTableView:getContentOffset()
	-- elseif(curMenuItem == _pocketMenuItem)then
	-- 	_pocketOffset = myTableView:getContentOffset()
	-- else
	-- end
end

--[[
	@des 	: 保存使用前偏移量
	@param 	: 
	@return : 
--]]
function saveUseLastOffset( p_curUseItemId )
	if( p_curUseItemId ~= nil and not tolua.isnull(myTableView) )then 
		local nIndex = 0
        for i=1, #curData do
        	if ( tonumber(curData[i].item_id ) == tonumber(p_curUseItemId) )then
        		nIndex = #curData-i
        		break
        	end
        end
		local curOffset = myTableView:getContentOffset()
		if(_curOpenIndex ~= nil)then 
			curOffset.y = curOffset.y + _openCellHeight*myScale
		end
		_markItemOffsetY = (#curData-nIndex)*cellSize.height*myScale + curOffset.y
	else
		_markItemOffsetY =  nil
	end
end

--[[
	@des 	: 得到偏移量
	@param 	: 
	@return : 
--]]
function getBagLastOffset()
	local retOffset = nil
	local maskItemId = nil
	local maskNextItemId = nil
	if(curMenuItem == toolsMenuItem) then
		retOffset = _propOffset
		maskItemId = _markUseItemId
		maskNextItemId = _markUseNextItemId
	elseif(curMenuItem == equipMenuItem)then
		retOffset = _equipOffset
		maskItemId = _markEquipItemId
	elseif(curMenuItem == armFragMenuItem)then 
		retOffset = _equipFragOffset
		maskItemId = _markEquipFragItemId
		maskNextItemId = _markEquipFragNextItemId
	elseif(curMenuItem == treasMenuItem)then
		retOffset = _treasOffset
		maskItemId = _markTreasureItemId
	elseif(curMenuItem == dressMenuItem)then
		retOffset = _dressOffset
		maskItemId = _markDressItemId
	elseif(curMenuItem == _godWeaponMenuItem)then
		retOffset = _godWeaponOffset
		maskItemId = _markGodItemId
	elseif(curMenuItem == _godWeaponFragMenuItem)then
		retOffset = _godWeaponFragOffset
		maskItemId = _markGodWeaponFragItemId
		maskNextItemId = _markGodWeaponFragNextItemId
	elseif(curMenuItem == _runeMenuItem)then
		retOffset = _runeOffset
	elseif(curMenuItem == _runeFragMenuItem)then
		retOffset = _runeFragOffset
		maskItemId = _markRuneFragItemId
		maskNextItemId = _markRuneFragNextItemId
	elseif(curMenuItem == _pocketMenuItem)then
		retOffset = _pocketOffset
		maskItemId = _markPocketItemId
	elseif(curMenuItem == _tallyMenuItem)then 
		retOffset = _tallyOffset
		maskItemId = _markTallyItemId
	elseif(curMenuItem == _tallyFragMenuItem)then 
		retOffset = _tallyFragOffset
		maskItemId = _markTallyFragItemId
		maskNextItemId = _markTallyFragNextItemId
	else
	end
	if( maskItemId ~= nil )then
		local nIndex = 0
        for i=1, #curData do
        	if ( tonumber(curData[i].item_id ) == tonumber(maskNextItemId) )then
        		-- tableViwe 创建是反的所以找使用物品上一条数据 (显示位置是使用物品下方)
        		nIndex = #curData-i
        		-- print("next",nIndex)
        	end
        	if ( tonumber(curData[i].item_id ) == tonumber(maskItemId) )then
        		nIndex = #curData-i
        		-- print("use",nIndex)
        		break
        	end
        end
        -- print("nIndex",nIndex,#curData,visiableCellNum,myTableViewHeight,cellSize.height)
		local offsety = 0
		if(nIndex == 0 )then
			offsety = myTableViewHeight - #curData*cellSize.height*myScale
			-- print("33333",offsety)
		elseif( (#curData-nIndex) < visiableCellNum )then
			offsety = 0
			-- print("4444",offsety)
		else
			if(_markItemOffsetY)then
				-- print("_markItemOffsetY",_markItemOffsetY)
				offsety = -((#curData-nIndex)*cellSize.height*myScale-_markItemOffsetY)
			else
				offsety = myTableViewHeight - (#curData-nIndex)*cellSize.height*myScale
				-- print("1111",_markItemOffsetY)
			end
		end
		retOffset= ccp(0, offsety)
	end

	-- 当物品少于 visiableCellNum 是默认显示第一个
	if( #curData <= visiableCellNum )then
		if(_curOpenIndex ~= nil)then 
			retOffset = ccp(0, myTableViewHeight - #curData*cellSize.height*myScale-_openCellHeight*myScale)
		else
			retOffset = ccp(0, myTableViewHeight - #curData*cellSize.height*myScale)
		end
		-- print("2222",retOffset.y)
	end
	-- if(retOffset ~= nil)then
	-- 	print("retOffset==>",retOffset.y)
	-- end
	return retOffset
end
------------------------------------------------------------- 创建UI --------------------------------------------------------------
function addBringSprite()
	-- 物品个数背景
    itemNumbersSprite = CCScale9Sprite:create("images/common/bgng_lefttimes.png", CCRectMake(0,0,33,33), CCRectMake(20,8,5,1))
    
    itemNumbersSprite:setAnchorPoint(ccp(0.5, 0))
    itemNumbersSprite:setPosition(bgLayer:getContentSize().width/2, bgLayer:getContentSize().height*0.015)
    
    bgLayer:addChild(itemNumbersSprite, 2)

    -- 携带数标题：
    local bringNumLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1838"), g_sFontName, 24, 1, ccc3(0, 0, 0), type_stroke)
    bringNumLabel:setAnchorPoint(ccp(0.5, 0.5))
    local hOffset = 6
    local tSizeOfText = bringNumLabel:getContentSize()
    bringNumLabel:setPosition(tSizeOfText.width/2+hOffset, itemNumbersSprite:getContentSize().height/2-1)
    itemNumbersSprite:addChild(bringNumLabel)

    local allBagInfo = DataCache.getRemoteBagInfo()
    local bagInfo = DataCache.getBagInfo()
    local displayNum = 0
    if(curMenuItem == toolsMenuItem) then
    	displayNum = #curData .. "/" .. allBagInfo.gridMaxNum.props
    elseif(curMenuItem == equipMenuItem) then
    	local bagArm = bagInfo.arm
    	local length = 0
    	if( not table.isEmpty(bagArm) )then
    		length = #bagArm
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.arm
    elseif(curMenuItem == treasMenuItem)then

    	local bagTreas = bagInfo.treas
    	local length = 0
    	if( not table.isEmpty(bagTreas) )then
    		length = #bagTreas
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.treas
    elseif(curMenuItem == armFragMenuItem)then
    	local bagArmFrag = bagInfo.armFrag
    	local length = 0
    	if( not table.isEmpty(bagArmFrag) )then
    		length = #bagArmFrag
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.armFrag
    elseif(curMenuItem == dressMenuItem)then
    	local bagDress = bagInfo.dress
    	local length = 0
    	if( not table.isEmpty(bagDress) )then
    		length = #bagDress
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.dress
    elseif(curMenuItem == _godWeaponMenuItem )then 
    	local bagGodWeapon = bagInfo.godWp
    	local length = 0
    	if( not table.isEmpty(bagGodWeapon) )then
    		length = #bagGodWeapon
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.godWp
    elseif(curMenuItem == _godWeaponFragMenuItem)then
    	local bagGodWeaponFrag = bagInfo.godWpFrag
    	local length = 0
    	if( not table.isEmpty(bagGodWeaponFrag) )then
    		length = #bagGodWeaponFrag
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.godWpFrag
    elseif(curMenuItem == _runeMenuItem)then
    	local bagRune = bagInfo.rune
    	local length = 0
    	if( not table.isEmpty(bagRune) )then
    		length = #bagRune
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.rune
    elseif(curMenuItem == _runeFragMenuItem)then
    	local bagRuneFrag = bagInfo.runeFrag
    	local length = 0
    	if( not table.isEmpty(bagRuneFrag) )then
    		length = #bagRuneFrag
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.runeFrag
    elseif(curMenuItem == _pocketMenuItem)then 
    	local bagPocket = bagInfo.pocket
    	local length = 0
    	if( not table.isEmpty(bagPocket) )then
    		length = #bagPocket
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.pocket
    elseif(curMenuItem == _tallyMenuItem)then  
    	local bagData = bagInfo.tally
    	local length = 0
    	if( not table.isEmpty(bagData) )then
    		length = #bagData
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.tally
    elseif(curMenuItem == _tallyFragMenuItem)then   
    	local bagData = bagInfo.tallyFrag
    	local length = 0
    	if( not table.isEmpty(bagData) )then
    		length = #bagData
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.tallyFrag
	elseif(curMenuItem == _chariotMenuItem)then
		local bagData = bagInfo.chariotBag
    	local length = 0
    	if( not table.isEmpty(bagData) )then
    		length = #bagData
    	end
    	displayNum = length .. "/" .. allBagInfo.gridMaxNum.chariotBag
    else
    end
    -- 携带数数据：
    local numLabel = CCRenderLabel:create(displayNum, g_sFontName, 24, 1, ccc3(0, 0, 0), type_stroke)
    numLabel:setColor(ccc3(0x36, 255, 0))
    numLabel:setAnchorPoint(ccp(0.5, 0.5))
    local tSizeOfNum = numLabel:getContentSize()
    local x = tSizeOfText.width + hOffset + tSizeOfNum.width/2
    numLabel:setPosition(x-10, itemNumbersSprite:getContentSize().height/2-2)
    itemNumbersSprite:addChild(numLabel)

    local nWidth = x + tSizeOfNum.width/2
	
    itemNumbersSprite:setPreferredSize(CCSizeMake(nWidth, 33))
end

-- 物品个数
function createItemNumbersSprite( ... )
	if( tolua.isnull(bgLayer) )then
		return 
	end
	if(itemNumbersSprite)then
		itemNumbersSprite:removeFromParentAndCleanup(true)
		itemNumbersSprite = nil
	end
	addBringSprite()
end 


-- 添加出售列表
local function checkedSellCell( gid )

	local isIn = false
	local sellList = BagLayer.getSellEquipList()
	if ( table.isEmpty(sellList) ) then
		sellList = {}
		table.insert(sellList, gid)
	else
		
		local index = -1
		for k,g_id in pairs(sellList) do
			if ( tonumber(g_id) == tonumber(gid) ) then
				isIn = true
				index = k
				break
			end
		end
		if (isIn) then
			table.remove(sellList, index)
		else
			table.insert(sellList, gid)
		end
	end
	BagLayer.setSellEquipList(sellList)
	return isIn
end

--[[
	@desc   背包tableView的创建
	@para 	none
	@return void
--]]
local function createBagTableView( ... )
	if(itemNumbersSprite)then
		itemNumbersSprite:removeFromParentAndCleanup(true)
		itemNumbersSprite = nil
	end
	if(curMenuItem == toolsMenuItem or curMenuItem == equipMenuItem or curMenuItem == treasMenuItem or curMenuItem == armFragMenuItem or curMenuItem == dressMenuItem 
		or curMenuItem == _godWeaponMenuItem or curMenuItem == _godWeaponFragMenuItem or curMenuItem == _runeMenuItem or curMenuItem == _runeFragMenuItem
		or curMenuItem == _pocketMenuItem or curMenuItem == _tallyMenuItem or curMenuItem == _tallyFragMenuItem or curMenuItem == _chariotMenuItem)then  
		createItemNumbersSprite()
	end
	local cellBg = CCSprite:create("images/bag/item/item_cellbg.png")
	if(curMenuItem == treasMenuItem or whichSell == Type_Treas_Sell )then
		cellSize = CCSizeMake(640,240)
	elseif(curMenuItem == _pocketMenuItem)then
		cellSize = CCSizeMake(640,225)
	elseif(curMenuItem == _godWeaponMenuItem or curMenuItem == _chariotMenuItem)then
		cellSize = CCSizeMake(640,190)
	else
		cellSize = cellBg:getContentSize()			--计算cell大小
	end

    myScale = bgLayer:getContentSize().width/cellSize.width/bgLayer:getElementScale()
    myTableViewHeight = bgLayer:getContentSize().height*0.88/bgLayer:getElementScale()
	visiableCellNum = math.floor(myTableViewHeight /cellSize.height) + 1 --计算可视的有几个cell
	
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			if( BagUtil.isSupportBagCell() and _curOpenIndex == a1 )then 
				r = CCSizeMake(cellSize.width*myScale, (cellSize.height+_openCellHeight)*myScale)
			else
				r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
			end
		elseif fn == "cellAtIndex" then
			if (curMenuItem == toolsMenuItem)then	
                a2 = ItemCell.createItemCell(curData[a1 + 1], false, useItemAction,refreshMyTableView)
            elseif (curMenuItem == armFragMenuItem)then	
                a2 = ItemCell.createItemCell(curData[a1 + 1], false, useItemAction, refreshMyTableView)
            elseif (curMenuItem == equipMenuItem) then
            	a2 = EquipBagCell.createEquipCell(curData[a1 + 1], false, refreshMyTableView, true, a1)
            elseif (curMenuItem == treasMenuItem) then
            	a2 = TreasBagCell.createTreasCell( curData[a1 + 1], false, refreshMyTableView, nil, nil, nil, true, a1)
            elseif (curMenuItem == dressMenuItem) then
            	a2 = FashionCell.createFashionCell(curData[a1 + 1], false, refreshMyTableView,nil,nil,true,a1)
           	elseif (curMenuItem == _godWeaponFragMenuItem)then	
                a2 = ItemCell.createItemCell(curData[a1 + 1], false, useItemAction, refreshMyTableView)
            elseif (curMenuItem == _godWeaponMenuItem) then
            	a2 = GodWeaponBagCell.createCell( curData[a1 + 1], refreshMyTableView,nil,nil,nil,nil,nil,nil,nil,true,a1)
            elseif (curMenuItem == _runeFragMenuItem)then	
                a2 = ItemCell.createItemCell(curData[a1 + 1], false, useItemAction, refreshMyTableView)
            elseif (curMenuItem == _runeMenuItem) then
            	a2 = RuneBagCell.createCell(curData[a1 + 1], refreshMyTableView)
            elseif (curMenuItem == _pocketMenuItem) then 
            	a2 = PocketBagCell.createCell( curData[a1 + 1], refreshMyTableView, nil, nil, nil, true, a1 )
            elseif (curMenuItem == _tallyMenuItem) then 
            	a2 = TallyBagCell.createCell(curData[a1 + 1], refreshMyTableView)
            elseif (curMenuItem == _tallyFragMenuItem) then 
            	a2 = ItemCell.createItemCell(curData[a1 + 1], false, useItemAction, refreshMyTableView)
        	elseif (curMenuItem == _chariotMenuItem) then
        		a2 = ChariotCell.createCell(curData[a1 + 1], a1, true, nil)
        	elseif (curMenuItem == sellBtn) then
        		if(whichSell == Type_Prop_Sell)then
        			a2 = ItemCell.createItemCell(curData[a1 + 1], true, nil,refreshMyTableView)
        		elseif(whichSell == Type_Arm_Sell)then
        			a2 = EquipBagCell.createEquipCell(curData[a1 + 1], true, refreshMyTableView)
        		elseif(whichSell == Type_Treas_Sell)then
        			a2 = TreasBagCell.createTreasCell(curData[a1 + 1], true, refreshMyTableView)
        		elseif(whichSell == Type_ArmFrag_Sell)then
        			a2 = ItemCell.createItemCell(curData[a1 + 1], true, nil,refreshMyTableView)
        		elseif(whichSell == Type_Dress_Sell)then
            		a2 = FashionCell.createFashionCell(curData[a1 + 1], false,refreshMyTableView)
        		else
        		end
        	end
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #curData
		elseif fn == "cellTouched" then
			
			if (curMenuItem == sellBtn) then
				local m_data = curData[a1:getIdx()+1]

				local cellBg = tolua.cast(a1:getChildByTag(1), "CCSprite")
				local menubar_m = tolua.cast(cellBg:getChildByTag(9898), "CCMenu")
				local menuBtn_M = tolua.cast(menubar_m:getChildByTag(tonumber(m_data.gid)), "CCMenuItemSprite")
				
				local isIn = checkedSellCell(tonumber(m_data.gid))
				if(isIn == true) then
					menuBtn_M:unselected()
				else
					menuBtn_M:selected()
				end
			end
		elseif (fn == "scroll") then
		end
		return r
	end)
	myTableView = LuaTableView:createWithHandler(h, CCSizeMake(bgLayer:getContentSize().width/bgLayer:getElementScale(),myTableViewHeight))
	myTableView:setBounceable(true)
	myTableView:ignoreAnchorPointForPosition(false)
    myTableView:setAnchorPoint(ccp(0.5,0))
	bgLayer:addChild(myTableView)
	if(curMenuItem == sellBtn)then
		myTableView:setPosition(bgLayer:getContentSize().width*0.5,0)
	else
   		myTableView:setPosition(bgLayer:getContentSize().width*0.5,10*myScale)
   	end

	local bFocusHid = false

	-- 偏移量记忆
	local offset = getBagLastOffset()
	local curShowIndex = #curData-visiableCellNum
	if( offset ~= nil)then
		bFocusHid = true
		print("offset.y==>",offset.y)
		myTableView:setContentOffset(offset)
		curShowIndex = math.abs(offset.y/cellSize.height)
	end

	-- if not bFocusHid then
		-- print("curShowIndex==>",curShowIndex)
		local curMaxShow = curShowIndex+visiableCellNum
		local maxAnimateIndex = visiableCellNum
		if (visiableCellNum > #curData) then
			maxAnimateIndex = #curData
		end
		-- print("curMaxShow==>",curMaxShow,maxAnimateIndex)
		for i=1, maxAnimateIndex do
			local itemCell = myTableView:cellAtIndex( curMaxShow -i )
			if ( not tolua.isnull(itemCell) ) then
				EquipBagCell.startEquipCellAnimate(itemCell, i)
			end
		end
	-- end
end


-- 获得准备出售的装备列表
function  getSellEquipList( )
	return _sellEquipList
end

-- 设置准备出售的装备列表
function setSellEquipList( sellList )
	_sellEquipList = sellList

	local totalNumber = 0
	local totalPrice = 0
	if (table.isEmpty(_sellEquipList) == false) then
		for k,g_id in pairs(_sellEquipList) do
			for k,m_data in pairs(curData) do
				if(tonumber(m_data.gid) == tonumber(g_id)) then
					totalNumber = totalNumber +1
					totalPrice = totalPrice + getPriceByEquipData(m_data) * tonumber(m_data.item_num)
					break
				end
			end
		end
	end
	_itemNumLabel:setString(totalNumber)
	_itemTotalCoinLabel:setString(totalPrice)
end

function getPriceByEquipData( equip_data )
	local price = 0
	if(whichSell == Type_Prop_Sell)then
		price = tonumber(equip_data.itemDesc.sell_num)
	elseif(whichSell == Type_Arm_Sell)then
		price = tonumber(equip_data.itemDesc.sellNum)
		-- 获取强化相关数值
		if( not table.isEmpty(equip_data.va_item_text) and equip_data.va_item_text.armReinforceCost )then
			
			price = price + tonumber(equip_data.va_item_text.armReinforceCost)
		end
	elseif(whichSell == Type_Treas_Sell)then
		price = tonumber(equip_data.itemDesc.sellNum)
	elseif(whichSell == Type_ArmFrag_Sell)then
		price = tonumber(equip_data.itemDesc.sell_num)
	elseif(whichSell == Type_Dress_Sell)then
		price = tonumber(equip_data.itemDesc.sell_num)
	end


	return tonumber(price)
end

-- 出售的回调
function sellActionCallback( cbFlag, dictData, bRet )
	if (dictData.err == "ok") then
		local coinStr = _itemTotalCoinLabel:getString()
		AnimationTip.showTip(GetLocalizeStringBy("key_1675") .. coinStr)
		UserModel.addSilverNumber(tonumber(coinStr))
		setSellEquipList(nil)
	end
end

-- 刷新Tableview
function refreshMyTableView()
	print("refreshMyTableView")
	if( tolua.cast(bgLayer,"CCLayer") == nil or tolua.cast(myTableView,TOLUA_CAST_TABLEVIEW) == nil)then
		return
	end
	--  当前不是出售按钮时
	if(curMenuItem == sellBtn)then
		MainScene.setMainSceneViewsVisible(false,true,true)
	end
	
	if (curMenuItem == toolsMenuItem or curMenuItem == equipMenuItem or curMenuItem == treasMenuItem or curMenuItem == armFragMenuItem or curMenuItem == dressMenuItem 
		or curMenuItem == _godWeaponMenuItem or curMenuItem == _godWeaponFragMenuItem or curMenuItem == _runeMenuItem or curMenuItem == _runeFragMenuItem
		or curMenuItem == _pocketMenuItem  or curMenuItem == _tallyMenuItem or curMenuItem == _tallyFragMenuItem) then 
		if(myTableView)then
			-- 刷新tebleview
			myTableView:reloadData()
			-- 偏移量记忆
			local offset = getBagLastOffset()
			if( offset ~= nil)then
				myTableView:setContentOffset(offset)
			end
		end
		createItemNumbersSprite()

		-- 刷新小红点
		if(_tipNum <= 0 or _godWeaponTipNum <= 0  or _runeTipNum <= 0 or _tallyTipNum <= 0 )then 
			MenuLayer.refreshMenuItemTipSprite()
		end
	elseif( curMenuItem == sellBtn)then
		myTableView:reloadData()
	else
		print("refreshMyTableView no")
	end
end

-- 批量出售的action
function sellAction( tag, item )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if (table.isEmpty(_sellEquipList) ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1077"))
	else
		local hasHighQuality = false
		local equipArgs = CCArray:create()
		for k,g_id in pairs(_sellEquipList) do
			for k,m_data in pairs(curData) do
				if(tonumber(m_data.gid) == tonumber(g_id)) then
					local equipArr = CCArray:create()
					equipArr:addObject(CCInteger:create(g_id))
					equipArr:addObject(CCInteger:create(tonumber(m_data.item_id)))
					equipArr:addObject(CCInteger:create(tonumber(m_data.item_num)))
					equipArgs:addObject(equipArr)
					if(m_data.itemDesc.quality > 4) then
						hasHighQuality = true
					end
					break
				end
			end
		end
		local tempArgs = CCArray:create()
		tempArgs:addObject(equipArgs)
		RequestCenter.bag_sellItems(sellActionCallback, tempArgs)

	end
end

-- 返回到非出售界面
function sellMenuBarAction( tag, itemMenu  )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local bagInfo = DataCache.getBagInfo()
	if (tag == 50001) then
		if(whichSell == Type_Prop_Sell)then
			middleSellMenuBar:setVisible(false)
			menu:setVisible(true)
			MainScene.setMainSceneViewsVisible(true, true,true)

			curMenuItem:unselected()
			curMenuItem = toolsMenuItem
			curMenuItem:selected()
			myTableView:removeFromParentAndCleanup(true)
			myTableView = nil
			_propOffset = nil

			curData = {}
			for k,v in pairs(bagInfo.props) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
			createBagTableView()

			setSellEquipList(nil)
			if(_sellBottomSprite)then
				_sellBottomSprite:removeFromParentAndCleanup(true)
				_sellBottomSprite = nil
			end
		elseif(whichSell == Type_Arm_Sell)then
			middleSellMenuBar:setVisible(false)
			menu:setVisible(true)
			MainScene.setMainSceneViewsVisible(true, true,true)

			curMenuItem:unselected()
			curMenuItem = equipMenuItem
			curMenuItem:selected()
			myTableView:removeFromParentAndCleanup(true)
			myTableView = nil
			_equipOffset = nil

			curData = {}
			local herosEquips = ItemUtil.getEquipsOnFormation()
			for k,v in pairs(bagInfo.arm) do
				table.insert(curData, v)
			end
			for k,v in pairs(herosEquips) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
			createBagTableView()

			setSellEquipList(nil)
			if(_sellBottomSprite)then
				_sellBottomSprite:removeFromParentAndCleanup(true)
				_sellBottomSprite = nil
			end
		elseif(whichSell == Type_Treas_Sell)then
			middleSellMenuBar:setVisible(false)
			menu:setVisible(true)
			MainScene.setMainSceneViewsVisible(true, true,true)

			curMenuItem:unselected()
			curMenuItem = treasMenuItem
			curMenuItem:selected()
			myTableView:removeFromParentAndCleanup(true)
			myTableView = nil
			_treasOffset = nil

			curData = {}
			local herosTreas = ItemUtil.getTreasOnFormation()
			for k,v in pairs(bagInfo.treas) do
				table.insert(curData, v)
			end
			for k,v in pairs(herosTreas) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
			createBagTableView()

			setSellEquipList(nil)
			if(_sellBottomSprite)then
				_sellBottomSprite:removeFromParentAndCleanup(true)
				_sellBottomSprite = nil
			end
		elseif(whichSell == Type_ArmFrag_Sell)then
			middleSellMenuBar:setVisible(false)
			menu:setVisible(true)
			MainScene.setMainSceneViewsVisible(true, true,true)

			curMenuItem:unselected()
			curMenuItem = armFragMenuItem
			curMenuItem:selected()
			myTableView:removeFromParentAndCleanup(true)
			myTableView = nil
			_equipFragOffset = nil

			curData = {}
			for k,v in pairs(bagInfo.armFrag) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
			createBagTableView()

			setSellEquipList(nil)
			if(_sellBottomSprite)then
				_sellBottomSprite:removeFromParentAndCleanup(true)
				_sellBottomSprite = nil
			end
		elseif(whichSell == Type_Dress_Sell)then
			middleSellMenuBar:setVisible(false)
			menu:setVisible(true)
			MainScene.setMainSceneViewsVisible(true, true,true)

			curMenuItem:unselected()
			curMenuItem = dressMenuItem
			curMenuItem:selected()
			myTableView:removeFromParentAndCleanup(true)
			myTableView = nil
			_dressOffset = nil

			curData = {} 
			for k,v in pairs(bagInfo.dress) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
			createBagTableView()

			setSellEquipList(nil)
			if(_sellBottomSprite)then
				_sellBottomSprite:removeFromParentAndCleanup(true)
				_sellBottomSprite = nil
			end
		end
		whichSell = nil
	elseif (tag == 50002) then
		createLayerStarSell()
	end
end 

-- 出售 的背景
local function createSellBottom()
	_sellBottomSprite = CCSprite:create("images/common/sell_bottom.png")
	_sellBottomSprite:setAnchorPoint(ccp(0.5, 1))
	_sellBottomSprite:setPosition(ccp(bgLayer:getContentSize().width/2,0))
	bgLayer:addChild(_sellBottomSprite)
	local myScale = bgLayer:getContentSize().width/_sellBottomSprite:getContentSize().width/bgLayer:getElementScale()
	_sellBottomSprite:setScale(myScale)
	
	-- 已选择装备
	local equipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3299"), g_sFontName, 25)
	equipLabel:setColor(ccc3(0xff, 0xff, 0xff))
	equipLabel:setAnchorPoint(ccp(0.5, 0.5))
	equipLabel:setPosition(ccp(_sellBottomSprite:getContentSize().width*0.11, _sellBottomSprite:getContentSize().height*0.4))
	_sellBottomSprite:addChild(equipLabel)

	-- 总计出售
	local sellTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2274"), g_sFontName, 25)
	sellTitleLabel:setColor(ccc3(0xff, 0xff, 0xff))
	sellTitleLabel:setAnchorPoint(ccp(0.5, 0.5))
	sellTitleLabel:setPosition(ccp(_sellBottomSprite:getContentSize().width*0.45, _sellBottomSprite:getContentSize().height*0.4))
	_sellBottomSprite:addChild(sellTitleLabel) 

	-- 物品数量背景
	local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local itemNumSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	itemNumSprite:setPreferredSize(CCSizeMake(65, 38))
	itemNumSprite:setAnchorPoint(ccp(0.5,0.5))
	itemNumSprite:setPosition(ccp(_sellBottomSprite:getContentSize().width* 172/640, _sellBottomSprite:getContentSize().height*0.4))
	_sellBottomSprite:addChild(itemNumSprite)

	-- 物品数量
	_itemNumLabel = CCLabelTTF:create(0, g_sFontName, 25)
	_itemNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_itemNumLabel:setAnchorPoint(ccp(0.5, 0.5))
	_itemNumLabel:setPosition(ccp(itemNumSprite:getContentSize().width*0.5, itemNumSprite:getContentSize().height*0.4))
	itemNumSprite:addChild(_itemNumLabel)

	-- 总计出售背景
	local totalSellSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	totalSellSprite:setPreferredSize(CCSizeMake(150, 38))
	totalSellSprite:setAnchorPoint(ccp(0.5,0.5))
	totalSellSprite:setPosition(ccp(_sellBottomSprite:getContentSize().width* 420/640, _sellBottomSprite:getContentSize().height*0.4))
	_sellBottomSprite:addChild(totalSellSprite)
	-- 钱币背景
	local coinBg = CCSprite:create("images/common/coin.png")
	coinBg:setAnchorPoint(ccp(0.5, 0.5))
	coinBg:setPosition(ccp(totalSellSprite:getContentSize().width*0.13, totalSellSprite:getContentSize().height*0.45))
	totalSellSprite:addChild(coinBg)

	-- 物品数量
	_itemTotalCoinLabel = CCLabelTTF:create(0, g_sFontName, 25)
	_itemTotalCoinLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_itemTotalCoinLabel:setAnchorPoint(ccp(0.5, 0.5))
	_itemTotalCoinLabel:setPosition(ccp(totalSellSprite:getContentSize().width*0.6, totalSellSprite:getContentSize().height*0.4))
	totalSellSprite:addChild(_itemTotalCoinLabel)

	-- 出售按钮
	local sellMenuBar = CCMenu:create()
	sellMenuBar:setPosition(ccp(0,0))
	_sellBottomSprite:addChild(sellMenuBar)
	sellMenuBar:setTouchPriority(-402)
	local sellBtn =  LuaMenuItem.createItemImage("images/bag/equip/btn_sell_n.png", "images/bag/equip/btn_sell_h.png" )
	sellBtn:setAnchorPoint(ccp(0.5, 0.5))
    sellBtn:setPosition(ccp(_sellBottomSprite:getContentSize().width*560/640, _sellBottomSprite:getContentSize().height*0.4))
    sellBtn:registerScriptTapHandler(sellAction)

	sellMenuBar:addChild(sellBtn)


end

--[[
	@desc	背包按钮切换的Action
	@para 	tag， menuItem
	@return void
--]]
function itemMenuAction( tag, menuItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	-- 保存偏移量
	saveBagLastOffset()

	menuItem:selected()
	if( curMenuItem ~= menuItem) then
		if (menuItem ~= expandBtn and menuItem ~= sellBtn) then
			curMenuItem:unselected()
			curMenuItem = menuItem
			if(myTableView) then
				myTableView:removeFromParentAndCleanup(true)
				myTableView = nil
			end
			_curOpenIndex = nil
		else
			menuItem:unselected()
		end
		bagInfo = DataCache.getBagInfo()
		if(menuItem == expandBtn) then
			setOpenIndex(nil)
			local bagType = nil
			if(curMenuItem == toolsMenuItem) then
				bagType = BagUtil.PROP_TYPE
			elseif(curMenuItem == equipMenuItem) then
				bagType = BagUtil.EQUIP_TYPE
			elseif(curMenuItem == treasMenuItem) then
				bagType = BagUtil.TREASURE_TYPE
			elseif(curMenuItem == armFragMenuItem) then
				bagType = BagUtil.EQUIPFRAG_TYPE
			elseif(curMenuItem == dressMenuItem) then
				bagType = BagUtil.DRESS_TYPE
			elseif(curMenuItem == _godWeaponMenuItem) then 
				bagType = BagUtil.GODWEAPON_TYPE
			elseif(curMenuItem == _godWeaponFragMenuItem) then 
				bagType = BagUtil.GODWEAPONFRAG_TYPE
			elseif(curMenuItem == _runeMenuItem) then 
				bagType = BagUtil.RUNE_TYPE
			elseif(curMenuItem == _runeFragMenuItem) then 
				bagType = BagUtil.RUNEFRAG_TYPE
			elseif(curMenuItem == _pocketMenuItem) then 
				bagType = BagUtil.POCKET_TYPE
			elseif(curMenuItem == _tallyMenuItem) then 
				bagType = BagUtil.TALLY_TYPE
			elseif(curMenuItem == _tallyFragMenuItem) then 
				bagType = BagUtil.TALLYFRAG_TYPE
			elseif(curMenuItem == _chariotMenuItem) then
				bagType = BagUtil.CHARIOT_TYPE
			end
			require "script/ui/bag/BagEnlargeDialog"
			BagEnlargeDialog.showLayer(bagType, createItemNumbersSprite)
		elseif (curMenuItem == toolsMenuItem) then
			curData = {}
			for k,v in pairs(bagInfo.props) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
		elseif(curMenuItem == equipMenuItem) then
			curData = {}
			local herosEquips = ItemUtil.getEquipsOnFormation()
			for k,v in pairs(bagInfo.arm) do
				table.insert(curData, v)
			end
			for k,v in pairs(herosEquips) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
		elseif (curMenuItem == treasMenuItem) then
			curData = {}
			for k,v in pairs(bagInfo.treas) do
				table.insert(curData, v)
			end
			local herosTreas = ItemUtil.getTreasOnFormation()
			for k,v in pairs(herosTreas) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
		elseif (curMenuItem == armFragMenuItem) then
			curData = {}
			if (bagInfo) then
				-- 把能合成的提出来 能合成的排在最前边
				local data = {}
				for k,v in pairs(bagInfo.armFrag) do
					if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
						table.insert(data,v)
					else
						table.insert(curData,v)
					end
				end
				for k,v in pairs(data) do
					table.insert(curData,v)
				end
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(true)
		elseif (curMenuItem == dressMenuItem) then
			curData = {}
			for k,v in pairs(bagInfo.dress) do
				table.insert(curData, v)
			end
			local herosDress = ItemUtil.getDressOnFormation()
			for k,v in pairs(herosDress) do
				table.insert(curData, v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(false)
		elseif(curMenuItem == _godWeaponMenuItem) then 
			curData = {}
			local herosEquips = HeroUtil.getAllGodWeaponOnHeros()
			for k,v in pairs(bagInfo.godWp) do
				table.insert(curData, v)
			end
			-- 按hid大小排序
			local temData = {}
			for k,v in pairs(herosEquips) do
				table.insert(temData,v)
			end
			function equipHidSort( data1, data2 )
				return tonumber(data1.equip_hid) < tonumber(data2.equip_hid)
			end
			table.sort( temData, equipHidSort )
			for i=1,#temData do
				table.insert(curData, temData[i])
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(false)
		elseif (curMenuItem == _godWeaponFragMenuItem) then 
			curData = {}
			if (bagInfo) then
				-- 把能合成的提出来 能合成的排在最前边
				local data = {}
				for k,v in pairs(bagInfo.godWpFrag) do
					if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
						table.insert(data,v)
					else
						table.insert(curData,v)
					end
				end
				for k,v in pairs(data) do
					table.insert(curData,v)
				end
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(false)	
		elseif(curMenuItem == _runeMenuItem) then 
			-- 符印
			curData = {}
			for k,v in pairs(bagInfo.rune) do
				table.insert(curData, v)
			end
			-- 阵上已镶嵌的
			local herosEquips = HeroUtil.getAllRuneOnHeros()
			for k,v in pairs(herosEquips) do
				table.insert(curData,v)
			end
			-- 宝物背包已镶嵌的
			local treasEquips = DataCache.getAllRuneInTreasureBag()
			for k,v in pairs(treasEquips) do
				table.insert(curData,v)
			end

			expandBtn:setVisible(true)
			sellBtn:setVisible(false)
		elseif (curMenuItem == _runeFragMenuItem) then 
			curData = {}
			-- 把能合成的提出来 能合成的排在最前边
			local data = {}
			for k,v in pairs(bagInfo.runeFrag) do
				if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
					table.insert(data,v)
				else
					table.insert(curData,v)
				end
			end
			for k,v in pairs(data) do
				table.insert(curData,v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(false)	
		elseif(curMenuItem == _pocketMenuItem) then 
			-- 锦囊
			curData = {}
			local equipTab = {} -- 可装备锦囊
			for k,itemInfo in pairs(bagInfo.pocket) do
				-- 筛选经验锦囊
				if( tonumber(itemInfo.itemDesc.is_exp) == 1 )then
					table.insert(curData,itemInfo)
				else
					table.insert(equipTab,itemInfo)
				end
			end
			-- 可装备的
			for k,v in pairs(equipTab) do
				table.insert(curData, v)
			end
			-- 按hid大小排序
			local temData = {}
			local herosEquips = HeroUtil.getAllPocketOnHeros()
			for k,v in pairs(herosEquips) do
				table.insert(temData,v)
			end
			function equipHidSort( data1, data2 )
				return tonumber(data1.equip_hid) < tonumber(data2.equip_hid)
			end
			table.sort( temData, equipHidSort )
			for i=1,#temData do
				table.insert(curData, temData[i])
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(false)
		elseif(curMenuItem == _tallyMenuItem) then 
			-- 兵符
			curData = {}
			for k,v in pairs(bagInfo.tally) do 
				table.insert(curData, v)
			end
			-- 阵上已装备的
			local herosEquips = HeroUtil.getAllTallyOnHeros()
			local equipData = {}
			for k,v in pairs(herosEquips) do
				table.insert(equipData,v)
			end
			table.sort( equipData, BagUtil.tallySortForBag )
			for k,v in pairs(equipData) do
				table.insert(curData,v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(false)
		elseif (curMenuItem == _tallyFragMenuItem) then 
			-- 兵符碎片
			curData = {}
			-- 把能合成的提出来 能合成的排在最前边
			local data = {}
			for k,v in pairs(bagInfo.tallyFrag) do
				if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
					table.insert(data,v)
				else
					table.insert(curData,v)
				end
			end
			for k,v in pairs(data) do
				table.insert(curData,v)
			end
			expandBtn:setVisible(true)
			sellBtn:setVisible(false)
		elseif (curMenuItem == _chariotMenuItem) then
			--战车
			curData = getAllChariot()
			expandBtn:setVisible(true)
			sellBtn:setVisible(false)

			--查看战车背包后，拥有新战车的状态置为false
			BagUtil.setNewChariot(false)
		else
		end
		--  出售按钮
		if(menuItem == sellBtn) then
			if(myTableView) then
				myTableView:removeFromParentAndCleanup(true)
				myTableView = nil
			end
			setOpenIndex(nil)
			middleSellMenuBar:setVisible(true)
			menu:setVisible(false)
			MainScene.setMainSceneViewsVisible(false, true,true)
			createSellBottom()
			curData = {}
			if(curMenuItem == toolsMenuItem) then
				curData = {}
				for k,v in pairs(bagInfo.props) do
					if(v.itemDesc.sellable ~= nil)then
						if(tonumber(v.itemDesc.sellable) == 1)then
							curData[#curData+1] = v
						end
					end
				end
				curMenuItem = menuItem
				whichSell = Type_Prop_Sell
				-- 隐藏按星级卖出按钮
				starSellBtn:setVisible(false)
			elseif(curMenuItem == equipMenuItem) then
				if (bagInfo) then
					curData = {}
					for k,v in pairs(bagInfo.arm) do
						-- 三星一下才能卖
						if(v.itemDesc.quality<=3)then
							table.insert(curData, v)
						end
					end
				end
				curMenuItem = menuItem
				whichSell = Type_Arm_Sell
				-- 隐藏按星级卖出按钮
				starSellBtn:setVisible(true)
			elseif(curMenuItem == treasMenuItem)then
				curData = {}
				for k,v in pairs(bagInfo.treas) do
					-- 三星一下才能卖
					if(v.itemDesc.quality<=3)then
						table.insert(curData, v)
					end
				end
				curMenuItem = menuItem
				whichSell = Type_Treas_Sell
				-- 隐藏按星级卖出按钮
				starSellBtn:setVisible(false)
			elseif (curMenuItem == armFragMenuItem) then
				curData = {}
				for k,v in pairs(bagInfo.armFrag) do
					table.insert(curData, v)
				end
				curMenuItem = menuItem
				whichSell = Type_ArmFrag_Sell
				-- 隐藏按星级卖出按钮
				starSellBtn:setVisible(false)
			elseif (curMenuItem == dressMenuItem) then
				curData = {}
				for k,v in pairs(bagInfo.dress) do
					table.insert(curData, v)
				end
				curMenuItem = menuItem
				whichSell = Type_Dress_Sell
				-- 隐藏按星级卖出按钮
				starSellBtn:setVisible(false)
			else
			end
		end

		if (menuItem ~= expandBtn) then
			createBagTableView()
		end
	end	
end

--[[
	@desc	添加背包按钮
	@para 	void
	@return void
--]]
local function addBagMenus()
	menu = CCMenu:create()
	menu:setTouchPriority(-130)
    
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--条件背景
	btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 120))
	btnFrameSp:setAnchorPoint(ccp(0.5, 0))
	btnFrameSp:setPosition(ccp(bgLayer:getContentSize().width/2 , bgLayer:getContentSize().height*0.88))
	btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	bgLayer:addChild(btnFrameSp)

	require "script/ui/common/LuaMenuItem"
	if(_bag_type == Type_Bag_Arm_Frag)then
		local title_item = {GetLocalizeStringBy("key_1791"), GetLocalizeStringBy("key_1971"), GetLocalizeStringBy("key_1312")}
		for i=1,3 do
			local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i], 30)
			itemImage:setAnchorPoint(ccp(0,0))
	        itemImage:setPosition(ccp(btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
	        itemImage:registerScriptTapHandler(itemMenuAction)
			menu:addChild(itemImage, i, 1000+i)
			if (i == 1) then
				equipMenuItem = itemImage
			elseif (i == 2) then
				armFragMenuItem = itemImage
			elseif (i == 3) then
				dressMenuItem = itemImage
			end 
		end
	elseif(_bag_type == Type_Bag_Prop_Treas)then
		local title_item = {GetLocalizeStringBy("key_1409")}
		for i=1,#title_item do
			local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i])
			itemImage:setAnchorPoint(ccp(0,0))
	        itemImage:setPosition(ccp(btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
	        itemImage:registerScriptTapHandler(itemMenuAction)
			menu:addChild(itemImage, i, 1000+i)
			if (i == 1) then
				toolsMenuItem = itemImage
			else
			end 
		end
	elseif(_bag_type == Type_Bag_GodWeapon)then 
		local title_item = {GetLocalizeStringBy("lic_1416"), GetLocalizeStringBy("lic_1417")}
		for i=1,2 do
			local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i] ,30)
			itemImage:setAnchorPoint(ccp(0,0))
	        itemImage:setPosition(ccp(btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
	        itemImage:registerScriptTapHandler(itemMenuAction)
			menu:addChild(itemImage, i, 1000+i)
			if (i == 1) then
				_godWeaponMenuItem = itemImage
			elseif (i == 2) then
				_godWeaponFragMenuItem = itemImage
			end 
		end
	elseif(_bag_type == Type_Bag_Rune)then 
		local title_item = {GetLocalizeStringBy("lic_1535"), GetLocalizeStringBy("lic_1532")}
		for i=1,2 do
			local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i] ,30)
			itemImage:setAnchorPoint(ccp(0,0))
	        itemImage:setPosition(ccp(btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
	        itemImage:registerScriptTapHandler(itemMenuAction)
			menu:addChild(itemImage, i, 1000+i)
			if (i == 1) then
				_runeMenuItem = itemImage 
			elseif (i == 2) then
				_runeFragMenuItem = itemImage
			end 
		end
	elseif(_bag_type == Type_Bag_Pocket)then  
		local title_item = {GetLocalizeStringBy("lic_1624")}
		for i=1,#title_item do
			local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i] ,30)
			itemImage:setAnchorPoint(ccp(0,0))
	        itemImage:setPosition(ccp(btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
	        itemImage:registerScriptTapHandler(itemMenuAction)
			menu:addChild(itemImage, i, 1000+i)
			if (i == 1) then
				_pocketMenuItem = itemImage
			end 
		end
	elseif(_bag_type == Type_Bag_Treas)then  
		local title_item = {GetLocalizeStringBy("key_3280")}
		for i=1,#title_item do
			local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i] ,30)
			itemImage:setAnchorPoint(ccp(0,0))
	        itemImage:setPosition(ccp(btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
	        itemImage:registerScriptTapHandler(itemMenuAction)
			menu:addChild(itemImage, i, 1000+i)
			if (i == 1) then
				treasMenuItem = itemImage
			end 
		end
	elseif(_bag_type == Type_Bag_Tally)then   
		local title_item = {GetLocalizeStringBy("lic_1771"),GetLocalizeStringBy("lic_1772")}
		for i=1,#title_item do
			local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i] ,30)
			itemImage:setAnchorPoint(ccp(0,0))
	        itemImage:setPosition(ccp(btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
	        itemImage:registerScriptTapHandler(itemMenuAction)
			menu:addChild(itemImage, i, 1000+i)
			if (i == 1) then
				_tallyMenuItem = itemImage  
			elseif (i == 2) then
				_tallyFragMenuItem = itemImage
			end 
		end
	elseif(_bag_type == Type_Bag_Chariot)then
		local title_item = {GetLocalizeStringBy("zq_0019")}   --”战车“
		for i=1,#title_item do
			local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i] ,30)
			itemImage:setAnchorPoint(ccp(0,0))
	        itemImage:setPosition(ccp(btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
	        itemImage:registerScriptTapHandler(itemMenuAction)
			menu:addChild(itemImage, i, 1000+i)
			if (i == 1) then
				_chariotMenuItem = itemImage	
			end 
		end	
	else
	end

	if(_initTag == Tag_Init_Props)then
		curMenuItem = toolsMenuItem
	elseif(_initTag == Tag_Init_Arming)then
		curMenuItem = equipMenuItem
	elseif(_initTag == Tag_Init_Treas)then
		curMenuItem = treasMenuItem
	elseif(_initTag == Tag_Init_ArmFrag)then
		curMenuItem = armFragMenuItem
	elseif(_initTag == Tag_Init_Dress)then
		curMenuItem = dressMenuItem
	elseif(_initTag == Tag_Init_GodWeapon)then   
		curMenuItem = _godWeaponMenuItem
	elseif(_initTag == Tag_Init_GodWeaponFrag)then
		curMenuItem = _godWeaponFragMenuItem
	elseif(_initTag == Tag_Init_Rune)then
		curMenuItem = _runeMenuItem
	elseif(_initTag == Tag_Init_RuneFrag)then
		curMenuItem = _runeFragMenuItem
	elseif(_initTag == Tag_Init_pocket)then
		curMenuItem = _pocketMenuItem
	elseif(_initTag == Tag_Init_Tally)then 
		curMenuItem = _tallyMenuItem
	elseif(_initTag == Tag_Init_TallyFrag)then
		curMenuItem = _tallyFragMenuItem
	elseif(_initTag == Tag_Init_Chariot)then
		curMenuItem = _chariotMenuItem
		--默认打开战车背包时，拥有新战车的状态置为false
		BagUtil.setNewChariot( false )
	else
	end
	curMenuItem:selected()
    menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	btnFrameSp:addChild(menu)

	-- 扩充按钮
	expandBtn =  LuaMenuItem.createItemImage("images/common/btn/btn_expand_n.png", "images/common/btn/btn_expand_h.png" )
	expandBtn:setAnchorPoint(ccp(0.5, 0))
    expandBtn:setPosition(ccp(btnFrameSp:getContentSize().width*510/640,btnFrameSp:getContentSize().height*0.1))
    expandBtn:registerScriptTapHandler(itemMenuAction)
	menu:addChild(expandBtn, 3, 1003)


	-- 出售按钮
	sellBtn =  LuaMenuItem.createItemImage("images/common/btn/btn_sale_n.png", "images/common/btn/btn_sale_h.png" )
	sellBtn:setAnchorPoint(ccp(0.5, 0))
    sellBtn:setPosition(ccp(btnFrameSp:getContentSize().width*600/640,btnFrameSp:getContentSize().height*0.1))
    sellBtn:registerScriptTapHandler(itemMenuAction)
	menu:addChild(sellBtn, 4, 1004)

	--出手时的按钮Bar
	middleSellMenuBar = CCMenu:create()
	middleSellMenuBar:setTouchPriority(-130)
	middleSellMenuBar:setPosition(ccp(0,0))
	btnFrameSp:addChild(middleSellMenuBar)

	-- 返回到非出售界面
	local backBtn = LuaMenuItem.createItemImage("images/formation/changeequip/btn_back_n.png",  "images/formation/changeequip/btn_back_h.png", sellMenuBarAction)
	backBtn:setAnchorPoint(ccp(0.5, 0))
	backBtn:setPosition(ccp(btnFrameSp:getContentSize().width*560/640,btnFrameSp:getContentSize().height*0.1))
	middleSellMenuBar:addChild(backBtn, 1, 50001)

	-- 按星级出售按钮 add by licong
	starSellBtn = LuaMenuItem.createItemImage("images/hero/btn_star_sell_n.png",  "images/hero/btn_star_sell_h.png", sellMenuBarAction)
	starSellBtn:setAnchorPoint(ccp(0.5, 0))
	starSellBtn:setPosition(ccp(btnFrameSp:getContentSize().width*330/640,btnFrameSp:getContentSize().height*0.1))
	middleSellMenuBar:addChild(starSellBtn, 1, 50002)

	middleSellMenuBar:setVisible(false)

	------------------ 装备碎片标签上的提示数字 by licong ----------------------
	-- 显示红色数字
	if(_bag_type == Type_Bag_Arm_Frag)then
		require "script/utils/ItemDropUtil"
		_tipNum = BagUtil.getCanCompoundNumByArmFrag()
		_tipSprite = ItemDropUtil.getTipSpriteByNum( _tipNum )
		_tipSprite:setAnchorPoint(ccp(1,1))
		_tipSprite:setPosition(armFragMenuItem:getContentSize().width *0.98, armFragMenuItem:getContentSize().height*0.97)
		armFragMenuItem:addChild(_tipSprite)
		if(_tipNum <= 0)then
			_tipSprite:setVisible(false)
		end
	end
	-------------------------------------------------------------------------

	------------------ 神兵碎片标签上的提示数字 by licong ----------------------
	-- 显示红色数字
	if(_bag_type == Type_Bag_GodWeapon )then 
		require "script/utils/ItemDropUtil"
		_godWeaponTipNum = BagUtil.getCanCompoundNumByGodWeaponFrag()
		_godWeaponTipSprite = ItemDropUtil.getTipSpriteByNum( _godWeaponTipNum )   
		_godWeaponTipSprite:setAnchorPoint(ccp(1,1))
		_godWeaponTipSprite:setPosition(_godWeaponFragMenuItem:getContentSize().width *0.98, _godWeaponFragMenuItem:getContentSize().height*0.97)
		_godWeaponFragMenuItem:addChild(_godWeaponTipSprite)
		if(_godWeaponTipNum <= 0)then
			_godWeaponTipSprite:setVisible(false)
		end
	end
	-------------------------------------------------------------------------
	------------------ 符印碎片标签上的提示数字 by licong ----------------------
	-- 显示红色数字
	if(_bag_type == Type_Bag_Rune )then
		require "script/utils/ItemDropUtil"
		_runeTipNum = BagUtil.getCanCompoundNumByRuneFrag()
		_runeTipSprite = ItemDropUtil.getTipSpriteByNum( _runeTipNum )   
		_runeTipSprite:setAnchorPoint(ccp(1,1))
		_runeTipSprite:setPosition(_runeFragMenuItem:getContentSize().width *0.98, _runeFragMenuItem:getContentSize().height*0.97)
		_runeFragMenuItem:addChild(_runeTipSprite)
		if(_runeTipNum <= 0)then
			_runeTipSprite:setVisible(false)
		end
	end
	-------------------------------------------------------------------------
	------------------ 兵符碎片标签上的提示数字 by licong ----------------------
	-- 显示红色数字
	if(_bag_type == Type_Bag_Tally )then  
		require "script/utils/ItemDropUtil"
		_tallyTipNum = BagUtil.getCanCompoundNumByTallyFrag()
		_tallyTipSprite = ItemDropUtil.getTipSpriteByNum( _tallyTipNum )   
		_tallyTipSprite:setAnchorPoint(ccp(1,1))
		_tallyTipSprite:setPosition(_tallyFragMenuItem:getContentSize().width *0.98, _tallyFragMenuItem:getContentSize().height*0.97)
		_tallyFragMenuItem:addChild(_tallyTipSprite)
		if(_tallyTipNum <= 0)then
			_tallyTipSprite:setVisible(false)
		end
	end
	-------------------------------------------------------------------------

	-- 出售按钮隐藏 神兵背包 符印背包
	if( curMenuItem == dressMenuItem or curMenuItem == _godWeaponMenuItem or curMenuItem == _godWeaponFragMenuItem  or curMenuItem == _runeMenuItem  
		or curMenuItem == _runeFragMenuItem  or curMenuItem == _pocketMenuItem or curMenuItem == _tallyMenuItem or curMenuItem == _tallyFragMenuItem 
		or curMenuItem == _chariotMenuItem)then 
		sellBtn:setVisible(false)
	end

	------------------ 神兵录按钮 by licong ----------------------
	if(_bag_type == Type_Bag_GodWeapon )then 
		-- 扩充按钮位置
		expandBtn:setPosition(ccp(btnFrameSp:getContentSize().width*600/640,btnFrameSp:getContentSize().height*0.1))
		-- 神兵按钮
		local godWeaponPreviewBtn = LuaMenuItem.createItemImage("images/god_weapon/preview/entrance_n.png",  "images/god_weapon/preview/entrance_h.png", godWeaponPreviewBtnCallBack)
		godWeaponPreviewBtn:setAnchorPoint(ccp(0.5, 0))
		godWeaponPreviewBtn:setPosition(ccp(btnFrameSp:getContentSize().width*370/640,btnFrameSp:getContentSize().height*0.1))
		menu:addChild(godWeaponPreviewBtn)
	end
	-------------------------------------------------------------------------
	------------------ 兵符录按钮 by licong ----------------------
	if(_bag_type == Type_Bag_Tally )then 
		-- 扩充按钮位置
		expandBtn:setPosition(ccp(btnFrameSp:getContentSize().width*600/640,btnFrameSp:getContentSize().height*0.1))
		-- 兵符录按钮
		local tallyPreviewBtn = LuaMenuItem.createItemImage("images/tally/bing_n.png",  "images/tally/bing_h.png", tallyPreviewBtnCallBack)
		tallyPreviewBtn:setAnchorPoint(ccp(0.5, 0))
		tallyPreviewBtn:setPosition(ccp(btnFrameSp:getContentSize().width*370/640,btnFrameSp:getContentSize().height*0.1))
		menu:addChild(tallyPreviewBtn)
	end
	-------------------------------------------------------------------------
	-- 符印背包返回按钮
	if(_bag_type == Type_Bag_Rune )then 
		--符印合成按钮
		require "script/ui/runeCompound/RuneCompoundConst"
		if RuneCompoundConst.ShowEntry == true then   --是否打开符印合成入口
			local btnPreview = LuaMenuItem.createItemImage("images/runecompound/rune_compound_icon_n.png",  "images/runecompound/rune_compound_icon_h.png", tapRuneCompoundCb)
			btnPreview:setAnchorPoint(ccp(0.5, 0))
			btnPreview:setPosition(ccp(btnFrameSp:getContentSize().width*415/640,btnFrameSp:getContentSize().height*0.1))
			menu:addChild(btnPreview)
		end

		local shuiyueBtn = LuaMenuItem.createItemImage("images/common/close_btn_n.png",  "images/common/close_btn_h.png", shuiyueBtnCallBack)
		shuiyueBtn:setAnchorPoint(ccp(1, 0))
		shuiyueBtn:setPosition(ccp(btnFrameSp:getContentSize().width*635/640,btnFrameSp:getContentSize().height*0.1))
		menu:addChild(shuiyueBtn)
	end

	-------------------------战车 zhangqiang--------------------------------
	if(_bag_type == Type_Bag_Chariot)then
		-- 扩充按钮位置
		expandBtn:setPosition(ccp(btnFrameSp:getContentSize().width*600/640,btnFrameSp:getContentSize().height*0.1))

		-- 战车图鉴按钮
		local btnPreview = LuaMenuItem.createItemImage("images/chariot/btn_chariot_illustrate_n.png",  "images/chariot/btn_chariot_illustrate_h.png", tapChariotPreview)
		btnPreview:setAnchorPoint(ccp(0.5, 0))
		btnPreview:setPosition(ccp(btnFrameSp:getContentSize().width*510/640,btnFrameSp:getContentSize().height*0.1))
		menu:addChild(btnPreview)
	end
end 

--[[
	@des 	:神兵录按钮回调
--]]
function godWeaponPreviewBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/godweapon/GodWeaponPreviewLayer"
 	GodWeaponPreviewLayer.showLayer()
end

--[[
	@des 	:神兵录按钮回调
--]]
function tallyPreviewBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/tally/preview/TallyPreviewLayer"
 	TallyPreviewLayer.showLayer()
end

--[[
	@des    : 符印合成按钮回调
--]]
function tapRuneCompoundCb( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/runeCompound/RuneCompoundCtrl"
	RuneCompoundCtrl.showLayer()
end

--[[
	@des    : 战车图鉴按钮回调
--]]
function tapChariotPreview( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- AlertTip.showAlert("chariot preview")
	require "script/ui/chariot/illustrate/ChariotIllustrateController"
	ChariotIllustrateController.getChariotBook(function()
		require "script/ui/chariot/illustrate/ChariotIllustrateLayer"
		ChariotIllustrateLayer.showLayer(-888,1100)
	end)
end


-- 使用回调
function useItemCallback( cbFlag, dictData, bRet )
	if (dictData.err == "ok" and (not table.isEmpty(dictData.ret)) ) then
		-- 是不是武将形象
		local isHeroDress = (curUserItemInfo.itemDesc.hero_dress ~= nil and tonumber(curUserItemInfo.itemDesc.hero_dress) > 0)
		if(curUserItemInfo.itemDesc.item_type == 5)then
			local itemName= ItemUtil.getItemNameByItmTid(curUserItemInfo.itemDesc.aimItem)
			AnimationTip.showTip(  GetLocalizeStringBy("key_3311") ..  itemName)
			----------------------- 刷新提示数字 ----------------
			require "script/utils/ItemDropUtil"
			_tipNum = _tipNum - 1
			-- 刷新小红圈数字
			ItemDropUtil.refreshNum( _tipSprite, _tipNum )
			----------------------------------------------------
		elseif(curUserItemInfo.itemDesc.item_type == 17)then
			-- 神兵碎片合成
			local itemName= ItemUtil.getItemNameByItmTid(curUserItemInfo.itemDesc.aimGodarm)
			AnimationTip.showTip(  GetLocalizeStringBy("key_3311") ..  itemName)
			----------------------- 刷新提示数字 ----------------
			require "script/utils/ItemDropUtil"
			_godWeaponTipNum = _godWeaponTipNum - 1 
			-- 刷新小红圈数字
			ItemDropUtil.refreshNum( _godWeaponTipSprite, _godWeaponTipNum )
		elseif(curUserItemInfo.itemDesc.item_type == 19)then
			-- 符印碎片合成
			local itemName= ItemUtil.getItemNameByItmTid(curUserItemInfo.itemDesc.aimFuyin)
			AnimationTip.showTip(  GetLocalizeStringBy("key_3311") ..  itemName)
			----------------------- 刷新提示数字 ----------------
			require "script/utils/ItemDropUtil"
			_runeTipNum = _runeTipNum - 1 
			-- 刷新小红圈数字
			ItemDropUtil.refreshNum( _runeTipSprite, _runeTipNum )
		elseif(curUserItemInfo.itemDesc.item_type == 21)then
			-- 兵符碎片合成
			local itemName= ItemUtil.getItemNameByItmTid(curUserItemInfo.itemDesc.aimBingfu)
			AnimationTip.showTip(  GetLocalizeStringBy("key_3311") ..  itemName)
			----------------------- 刷新提示数字 ----------------
			require "script/utils/ItemDropUtil"
			_tallyTipNum = _tallyTipNum - 1 
			-- 刷新小红圈数字
			ItemDropUtil.refreshNum( _tallyTipSprite, _tallyTipNum )
		elseif( isHeroDress ) then
			-- 武将形象
			local turnId = tonumber(curUserItemInfo.itemDesc.hero_dress)
			require "script/ui/turnedSys/HeroTurnedData"
			local turnInfo = HeroTurnedData.getTurnDBInfoById(turnId)
			-- 提示
			AnimationTip.showTip(GetLocalizeStringBy("lgx_1128",turnInfo.name,turnInfo.dress_name))

			-- 解锁幻化图鉴
			HeroTurnedData.activeTurnByIdAndModelId(turnId,turnInfo.model_id)
		elseif( not table.isEmpty(dictData.ret.drop) )then
			UseItemLayer.showDropResult( dictData.ret.drop, 1 ,0,true)
		else
			UseItemLayer.showResult( curUseItemTempID )
			if( tonumber(curUseItemTempID) >= 13001 and tonumber(curUseItemTempID) <= 14000 and DataCache.getSwitchNodeState(ksSwitchPet))then
				-- 使用的是宠物蛋
				require "script/ui/pet/PetData"
				if( not table.isEmpty(dictData.ret.pet) )then
					for k,v in pairs(dictData.ret.pet) do
						PetData.addPetInfo(v)
					end
				end
			end
		end
	end
	
end

-- 道具背包刷新 add by liong
function refreshProps( curUseItemGid, curUseItemNum )
	bagInfo = DataCache.getBagInfo()
	curData = {}
	for k,v in pairs(bagInfo.props) do
		table.insert(curData, v)
	end
	_useItemTableViewOffset = myTableView:getContentOffset()
	refreshMyTableView()
end

-- 刷新
function refreshDataByType()
	bagInfo = DataCache.getBagInfo()
	if (curMenuItem == toolsMenuItem) then
		curData = {}
		for k,v in pairs(bagInfo.props) do
			table.insert(curData, v)
		end
	elseif(curMenuItem == equipMenuItem) then
		curData = {}
		local herosEquips = ItemUtil.getEquipsOnFormation()
		for k,v in pairs(bagInfo.arm) do
			table.insert(curData, v)
		end
		for k,v in pairs(herosEquips) do
			table.insert(curData, v)
		end
	elseif(curMenuItem == armFragMenuItem) then
		curData = {}
		if (bagInfo) then
			-- 把能合成的提出来 能合成的排在最前边
			local data = {}
			for k,v in pairs(bagInfo.armFrag) do
				if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
					table.insert(data,v)
				else
					table.insert(curData,v)
				end
			end
			for k,v in pairs(data) do
				table.insert(curData,v)
			end
		end
	elseif (curMenuItem == treasMenuItem) then
		curData = {}
		for k,v in pairs(bagInfo.treas) do
			table.insert(curData, v)
		end
		local herosTreas = ItemUtil.getTreasOnFormation()
		for k,v in pairs(herosTreas) do
			table.insert(curData, v)
		end
	elseif (curMenuItem == dressMenuItem) then
			curData = {}
			for k,v in pairs(bagInfo.dress) do
				table.insert(curData, v)
			end
			local herosDress = ItemUtil.getDressOnFormation()
			for k,v in pairs(herosDress) do
				table.insert(curData, v)
			end
	elseif(curMenuItem == _godWeaponMenuItem) then 
			curData = {}
			local herosEquips = HeroUtil.getAllGodWeaponOnHeros()
			for k,v in pairs(bagInfo.godWp) do
				table.insert(curData, v)
			end
			-- 按hid大小排序
			local temData = {}
			for k,v in pairs(herosEquips) do
				table.insert(temData,v)
			end
			function equipHidSort( data1, data2 )
				return tonumber(data1.equip_hid) < tonumber(data2.equip_hid)
			end
			table.sort( temData, equipHidSort )
			for i=1,#temData do
				table.insert(curData, temData[i])
			end
	elseif (curMenuItem == _godWeaponFragMenuItem) then 
		curData = {}
		if (bagInfo) then
			-- 把能合成的提出来 能合成的排在最前边
			local data = {}
			for k,v in pairs(bagInfo.godWpFrag) do
				if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
					table.insert(data,v)
				else
					table.insert(curData,v)
				end
			end
			for k,v in pairs(data) do
				table.insert(curData,v)
			end
		end
	elseif(curMenuItem == _runeMenuItem) then 
		-- 符印
		curData = {}
		for k,v in pairs(bagInfo.rune) do
			table.insert(curData, v)
		end
		-- 阵上已镶嵌的
		local herosEquips = HeroUtil.getAllRuneOnHeros()
		for k,v in pairs(herosEquips) do
			table.insert(curData,v)
		end
		-- 宝物背包已镶嵌的
		local treasEquips = DataCache.getAllRuneInTreasureBag()
		for k,v in pairs(treasEquips) do
			table.insert(curData,v)
		end
	elseif (curMenuItem == _runeFragMenuItem) then 
		curData = {}
		-- 把能合成的提出来 能合成的排在最前边
		local data = {}
		for k,v in pairs(bagInfo.runeFrag) do
			if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
				table.insert(data,v)
			else
				table.insert(curData,v)
			end
		end
		for k,v in pairs(data) do
			table.insert(curData,v)
		end
	elseif (curMenuItem == _pocketMenuItem) then 
		-- 锦囊
		curData = {}
		local equipTab = {} -- 可装备锦囊
		for k,itemInfo in pairs(bagInfo.pocket) do
			-- 筛选经验锦囊
			if( tonumber(itemInfo.itemDesc.is_exp) == 1 )then
				table.insert(curData,itemInfo)
			else
				table.insert(equipTab,itemInfo)
			end
		end
		-- 可装备的
		for k,v in pairs(equipTab) do
			table.insert(curData, v)
		end

		-- 按hid大小排序
		local temData = {}
		local herosEquips = HeroUtil.getAllPocketOnHeros()
		for k,v in pairs(herosEquips) do
			table.insert(temData,v)
		end
		function equipHidSort( data1, data2 )
			return tonumber(data1.equip_hid) < tonumber(data2.equip_hid)
		end
		table.sort( temData, equipHidSort )
		for i=1,#temData do
			table.insert(curData, temData[i])
		end
	elseif(curMenuItem == _tallyMenuItem) then 
		-- 兵符
		curData = {}
		for k,v in pairs(bagInfo.tally) do 
			table.insert(curData, v)
		end
		-- 阵上已装备的
		local herosEquips = HeroUtil.getAllTallyOnHeros()
		local equipData = {}
		for k,v in pairs(herosEquips) do
			table.insert(equipData,v)
		end
		table.sort( equipData, BagUtil.tallySortForBag )
		for k,v in pairs(equipData) do
			table.insert(curData,v)
		end
	elseif (curMenuItem == _tallyFragMenuItem) then 
		-- 兵符碎片
		curData = {}
		-- 把能合成的提出来 能合成的排在最前边
		local data = {}
		for k,v in pairs(bagInfo.tallyFrag) do
			if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
				table.insert(data,v)
			else
				table.insert(curData,v)
			end
		end
		for k,v in pairs(data) do
			table.insert(curData,v)
		end
	elseif (curMenuItem == _chariotMenuItem) then
		--战车
		curData = getAllChariot()
	else
	end

	-- 出售
	if( curMenuItem == sellBtn)then
		if(whichSell == Type_Prop_Sell)then
			-- 道具出售
			curData = {}
			for k,v in pairs(bagInfo.props) do
				if(v.itemDesc.sellable ~= nil)then
					if(tonumber(v.itemDesc.sellable) == 1)then
						curData[#curData+1] = v
					end
				end
			end
		elseif(whichSell == Type_Arm_Sell)then
			-- 装备出售
			curData = {}
			for k,v in pairs(bagInfo.arm) do
				-- 三星一下才能卖
				if(tonumber(v.itemDesc.quality)<=3)then
					table.insert(curData, v)
				end
			end
		elseif(whichSell == Type_Treas_Sell)then
			-- 宝物出售
			curData = {}
			for k,v in pairs(bagInfo.treas) do
				-- 三星一下才能卖
				if(tonumber(v.itemDesc.quality)<=3)then
					table.insert(curData, v)
				end
			end
		elseif(whichSell == Type_ArmFrag_Sell)then
			-- 装备碎片出售
			curData = {}
			for k,v in pairs(bagInfo.armFrag) do
				table.insert(curData, v)
			end
			-------------  添加出售后 小红圈数字重新算 add by licong -----------
			_tipNum = BagUtil.getCanCompoundNumByArmFrag()
			-- 刷新小红圈数字
			ItemDropUtil.refreshNum( _tipSprite, _tipNum )
			----------------------------------------------------------------
		elseif(whichSell == Type_Dress_Sell)then
			-- 时装出售
			curData = {}
			for k,v in pairs(bagInfo.dress) do
				table.insert(curData, v)
			end
		else
		end
	end

	refreshMyTableView()
end

-- 判断ItemId 是否为随机礼包 added by zhz
function isItemTidInRandGift( itemTid )
	itemTid = tonumber(itemTid)
	if(itemTid >= 30001 and itemTid <= 40000) then
		return true
	end
	return false
end

-- 使用物品 tag = gid
function useItemAction( tag, itemMenu )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	curUserItemInfo = nil

	for i=1,#curData do
		if(tonumber( curData[i].gid )== tag) then
			curUseItemTempID = curData[i].item_template_id
			curUseItemNum = 1
			curUseItemGid = curData[i].gid
			curUserItemInfo = curData[i]
			if(curMenuItem == toolsMenuItem) then
				-- 标记使用哪一个物品
				_markUseItemId = curUserItemInfo.item_id
				if(not table.isEmpty(curData[i-1]) )then
					_markUseNextItemId = curData[i-1].item_id
				end
			elseif(curMenuItem == armFragMenuItem )then 
				_markEquipFragItemId = curUserItemInfo.item_id
				if(not table.isEmpty(curData[i-1]) )then
					_markEquipFragNextItemId = curData[i-1].item_id
				end
			elseif(curMenuItem == _godWeaponFragMenuItem )then 
				_markGodWeaponFragItemId = curUserItemInfo.item_id
				if(not table.isEmpty(curData[i-1]) )then
					_markGodWeaponFragNextItemId = curData[i-1].item_id
				end
			elseif(curMenuItem == _runeFragMenuItem )then 
				_markRuneFragItemId = curUserItemInfo.item_id
				if(not table.isEmpty(curData[i-1]) )then 
					_markRuneFragNextItemId = curData[i-1].item_id
				end
			elseif(curMenuItem == _tallyFragMenuItem )then 
				_markTallyFragItemId = curUserItemInfo.item_id
				if(not table.isEmpty(curData[i-1]) )then
					_markTallyFragNextItemId = curData[i-1].item_id
				end
			else 
			end
			-- 保存老的偏移量
			saveUseLastOffset( curUserItemInfo.item_id )
			break
		end
	end

	if (curUserItemInfo) then

		-- 使用称号后端不想用原来的 bag.useItem 用 stylish.activeTitle , 所以根据sign字段判断是否是称号
		if ( curUserItemInfo.itemDesc.sign ~= nil and tonumber(curUserItemInfo.itemDesc.sign) > 0 ) then
			-- 激活(使用)称号
			require "script/ui/title/TitleController"
			TitleController.activeTitleWithItemInfo(curUserItemInfo)
			return
		end

		-- 幻化形象 判断功能节点是否开启
		if ( curUserItemInfo.itemDesc.hero_dress ~= nil and tonumber(curUserItemInfo.itemDesc.hero_dress) > 0 ) then
			if ( not DataCache.getSwitchNodeState(ksSwitchHeroTurned) ) then
				return
			end
		end

		if( tonumber(curUserItemInfo.item_template_id ) == 60012) then
			require "script/ui/main/ChangeUserNameLayer"
			ChangeUserNameLayer.showLayer(1)
			return
		end
		if( curUserItemInfo.itemDesc.award_item_id )then
			if(ItemUtil.isBagFull() == true)then
				return
			end
		end
		if( curUserItemInfo.itemDesc.getPet)then

			-- 蠢物
			if not DataCache.getSwitchNodeState(ksSwitchPet) then
				return
			end
			require "script/ui/pet/PetData"
			if tonumber(PetData.getPetNum()) >= tonumber(PetData.getOpenBagNum()) then
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("key_2357"))
				return
			end
		end
		-- 当奖励为 award_card_id( 即奖励的可能为武将时)存在并且 item_template_id 在 随机礼包的范围时
		if( curUserItemInfo.itemDesc.award_card_id or  isItemTidInRandGift(curUserItemInfo.item_template_id ) ) then
            require "script/ui/hero/HeroPublicUI"
            if HeroPublicUI.showHeroIsLimitedUI() then
                return
            end
		end

		-- 4星武魂包 和 5星武魂包 不做判断
		if(curUserItemInfo.itemDesc.item_type == 8 and curUserItemInfo.itemDesc.id ~= 30021 and curUserItemInfo.itemDesc.id ~= 30022) then
			-- 5星武将包
			if(curUserItemInfo.itemDesc.id == 30201)then
	            if HeroPublicUI.showHeroIsLimitedUI() then
	                return
	            end
			elseif(ItemUtil.isBagFull() == true)then
				return
			end
		end

		-- 最大等级不能使用经验丹
		if(curUserItemInfo.itemDesc.item_type == 3 and curUserItemInfo.itemDesc.id >= 15001 and curUserItemInfo.itemDesc.id <= 15004) then
			if( UserModel.getHeroLevel() >= UserModel.getUserMaxLevel() )then
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("lic_1530"))
				return
			end
		end
		
		if(curUserItemInfo.itemDesc.item_type == 5 or curUserItemInfo.itemDesc.item_type == 17 or curUserItemInfo.itemDesc.item_type == 19 or curUserItemInfo.itemDesc.item_type == 21)then
			if(curUserItemInfo.itemDesc.item_type == 5)then
				if(ItemUtil.isEquipBagFull(true) == true)then
					return
				end
			end

			if(curUserItemInfo.itemDesc.item_type == 17)then
				if(ItemUtil.isGodWeaponBagFull(true) == true)then
					return
				end
			end

			if(curUserItemInfo.itemDesc.item_type == 19)then
				if(ItemUtil.isRuneBagFull(true) == true)then
					return
				end
			end

			if(curUserItemInfo.itemDesc.item_type == 21)then
				if(ItemUtil.isTallyBagFull(true) == true)then
					return
				end
			end

			if( tonumber(curUserItemInfo.itemDesc.need_part_num) > tonumber(curUserItemInfo.item_num) )then
				AnimationTip.showTip( curUserItemInfo.itemDesc.need_part_num .. GetLocalizeStringBy("key_1632"))
			else
				curUseItemNum = tonumber(curUserItemInfo.itemDesc.need_part_num)
				local args = Network.argsHandler(curUserItemInfo.gid, curUserItemInfo.item_id, curUseItemNum,1)
				RequestCenter.bag_useItem(useItemCallback, args)
			end
		elseif(curUserItemInfo.itemDesc.item_type == 8 )then
			-- 金银铜箱子 钥匙 使用限制
			local limitTab = {30001,30002,30003,30011,30012,30013,}
			local isIn = false
			for i=1,#limitTab do
				if( tonumber(curUserItemInfo.itemDesc.id) == limitTab[i] )then
					isIn = true
					break
				end
			end
			local vip,needLv = BagUtil.getUseGoldBoxLimit()
			if( isIn )then
				if( UserModel.getVipLevel() < vip and UserModel.getHeroLevel() < needLv )then 
					AnimationTip.showTip( GetLocalizeStringBy("lic_1615",vip,needLv))
					return 
				end
			end
			if(curUserItemInfo.itemDesc.use_needItem and curUserItemInfo.itemDesc.use_needItem > 0)then
				local t_info = ItemUtil.getCacheItemInfoBy( curUserItemInfo.itemDesc.use_needItem )
				if( table.isEmpty(t_info) or (tonumber(t_info.item_num) < tonumber(curUserItemInfo.itemDesc.use_needNum)) )then
					local tt_info = ItemUtil.getItemById(curUserItemInfo.itemDesc.use_needItem)
					AnimationTip.showTip(GetLocalizeStringBy("key_2702") .. curUserItemInfo.itemDesc.use_needNum .. GetLocalizeStringBy("key_2557") .. tt_info.name )
				else
					local maxNum = math.floor( tonumber(t_info.item_num)/tonumber(curUserItemInfo.itemDesc.use_needNum) )
					local maxCanUseNum = math.min(maxNum, tonumber(curUserItemInfo.item_num))
					if(maxCanUseNum > 1)then
						require "script/ui/bag/BatchUseLayer"
						BatchUseLayer.showBatchUseLayer(curUserItemInfo, maxCanUseNum)
					else
						local args = Network.argsHandler(curUserItemInfo.gid, curUserItemInfo.item_id, curUseItemNum,1)
						RequestCenter.bag_useItem(useItemCallback, args)
					end
				end
			else
				if(tonumber(curUserItemInfo.item_num) > 1)then
					-- 批量
					require "script/ui/bag/BatchUseLayer"
					BatchUseLayer.showBatchUseLayer(curUserItemInfo, curUserItemInfo.item_num)
				else
					local args = Network.argsHandler(curUserItemInfo.gid, curUserItemInfo.item_id, curUseItemNum,1)
					RequestCenter.bag_useItem(useItemCallback, args)
					-- 使用道具获得金币和VIP经验 add by yangrui at 16-01-06
					BagUtil.userProductGoldAndVipExpItem(curUserItemInfo,curUseItemNum)
				end
			end
		elseif(curUserItemInfo.itemDesc.item_type == 3 )then
			-- 使用宠物蛋限制
			if( tonumber(curUserItemInfo.item_template_id) >= 13001 and tonumber(curUserItemInfo.item_template_id) <= 14000 )then
				-- 功能节点未开启
				if not DataCache.getSwitchNodeState(ksSwitchPet) then
					return
				end
				-- 宠物背包满了
				require "script/ui/pet/PetUtil"
				if PetUtil.isPetBagFull() == true then
					return
				end
			end
			-- 是否是武将幻化形象，武将形象不能批量使用，而且只能使用一次，多余的只能卖出
			local isHeroDress = (curUserItemInfo.itemDesc.hero_dress ~= nil and tonumber(curUserItemInfo.itemDesc.hero_dress) > 0)
			if ( isHeroDress ) then
				local turnId = tonumber(curUserItemInfo.itemDesc.hero_dress)
				require "script/ui/turnedSys/HeroTurnedData"
				local modelId = HeroTurnedData.getHeroModelIdById(turnId)
				local isUnlock = HeroTurnedData.isUnLockedByIdAndModelId(turnId,modelId)
				if ( isUnlock ) then
					AnimationTip.showTip(GetLocalizeStringBy("lgx_1126"))
					return
				end
			end
			if(tonumber(curUserItemInfo.item_num) > 1 and isHeroDress == false)then
				-- 批量
				require "script/ui/bag/BatchUseLayer"
				BatchUseLayer.showBatchUseLayer(curUserItemInfo, curUserItemInfo.item_num)
			else
				-- 一个
				local args = Network.argsHandler(curUserItemInfo.gid, curUserItemInfo.item_id, curUseItemNum,1)
				RequestCenter.bag_useItem(useItemCallback, args)
			end
		elseif(curUserItemInfo.itemDesc.item_type == 9)then
			-- 名将礼物
			if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
				return
			end
            require "script/ui/star/StarLayer"
            local starLayer = StarLayer.createLayer()
            MainScene.changeLayer(starLayer, "starLayer")

		elseif(curUserItemInfo.itemDesc.item_type == 4)then
			-- 蠢物
			if not DataCache.getSwitchNodeState(ksSwitchPet) then
				return
			end
			require "script/ui/pet/PetMainLayer"
    		local layer= PetMainLayer.createLayer()
    		MainScene.changeLayer(layer, "PetMainLayer")
    	elseif(curUserItemInfo.itemDesc.item_type == 6 )then
    		-- 五星武魂选择包 不做背包判断
    		if(curUserItemInfo.itemDesc.id ~= 20006 and curUserItemInfo.itemDesc.id ~= 20007 )then
	    		-- 物品背包满了
				require "script/ui/item/ItemUtil"
				if(ItemUtil.isBagFull() == true )then
					return
				end
				-- 武将满了
				require "script/ui/hero/HeroPublicUI"
			    if HeroPublicUI.showHeroIsLimitedUI() then
			    	return
			    end
			end
		    if(curUserItemInfo.itemDesc.choose_items ~= nil)then
				-- 礼包类物品 使用后选择一个领取
				require "script/ui/bag/UseGiftLayer"
				UseGiftLayer.showTipLayer(curUserItemInfo,nil,nil,true)
			end
		else
			local args = Network.argsHandler(curUserItemInfo.gid, curUserItemInfo.item_id, curUseItemNum,1)
			RequestCenter.bag_useItem(useItemCallback, args)
		end
	end
end

function bagInfoCallbck( cbFlag, dictData, bRet )
	if (dictData.err == "ok") then
		-- local  dictData.ret
		DataCache.setBagInfo( BagUtil.handleBagInfos(dictData.ret) )
	end
	local bagInfo = DataCache.getBagInfo()
	if (bagInfo)then
		if(_initTag == Tag_Init_Props  and bagInfo.props) then
			curData = {}
			for k,v in pairs(bagInfo.props) do
				table.insert(curData, v)
			end
		elseif( _initTag == Tag_Init_Arming and bagInfo.arm)then
			
			curData = {}
			local herosEquips = ItemUtil.getEquipsOnFormation()
			for k,v in pairs(bagInfo.arm) do
				table.insert(curData, v)
			end
			for k,v in pairs(herosEquips) do
				table.insert(curData, v)
			end
		elseif( _initTag == Tag_Init_Treas and bagInfo.treas)then
			curData = {}
			for k,v in pairs(bagInfo.treas) do
				table.insert(curData, v)
			end
			local herosTreas = ItemUtil.getTreasOnFormation()
			for k,v in pairs(herosTreas) do
				table.insert(curData, v)
			end
		elseif( _initTag == Tag_Init_ArmFrag and bagInfo.armFrag)then
			curData = {}
			for k,v in pairs(bagInfo.armFrag) do
				table.insert(curData, v)
			end
		elseif( _initTag == Tag_Init_Dress and bagInfo.dress)then
			curData = {}
			for k,v in pairs(bagInfo.dress) do
				table.insert(curData, v)
			end
			local herosDress = ItemUtil.getDressOnFormation()
			for k,v in pairs(herosDress) do
				table.insert(curData, v)
			end
		elseif( _initTag == Tag_Init_GodWeapon and bagInfo.godWp )then 
			-- 神兵
			curData = {}
			local herosEquips = HeroUtil.getAllGodWeaponOnHeros()
			for k,v in pairs(bagInfo.godWp) do
				table.insert(curData, v)
			end
			-- 按hid大小排序
			local temData = {}
			for k,v in pairs(herosEquips) do
				table.insert(temData,v)
			end
			function equipHidSort( data1, data2 )
				return tonumber(data1.equip_hid) < tonumber(data2.equip_hid)
			end
			table.sort( temData, equipHidSort )
			for i=1,#temData do
				table.insert(curData, temData[i])
			end
		elseif( _initTag == Tag_Init_GodWeaponFrag and bagInfo.godWpFrag )then 
			-- 神兵碎片
			curData = {}
			for k,v in pairs(bagInfo.godWpFrag) do
				table.insert(curData, v)
			end
		elseif( _initTag == Tag_Init_Rune and bagInfo.rune )then 
			-- 符印
			curData = {}
			for k,v in pairs(bagInfo.rune) do
				table.insert(curData, v)
			end
			-- 阵上已镶嵌的
			local herosEquips = HeroUtil.getAllRuneOnHeros()
			for k,v in pairs(herosEquips) do
				table.insert(curData,v)
			end
			-- 宝物背包已镶嵌的
			local treasEquips = DataCache.getAllRuneInTreasureBag()
			for k,v in pairs(treasEquips) do
				table.insert(curData,v)
			end
		elseif( _initTag == Tag_Init_RuneFrag and bagInfo.runeFrag )then 
			-- 符印碎片
			curData = {}
			-- 把能合成的提出来 能合成的排在最前边
			local data = {}
			for k,v in pairs(bagInfo.runeFrag) do
				if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
					table.insert(data,v)
				else
					table.insert(curData,v)
				end
			end
			for k,v in pairs(data) do
				table.insert(curData,v)
			end
		elseif( _initTag == Tag_Init_pocket and bagInfo.pocket )then 
			-- 锦囊
			curData = {}
			local equipTab = {} -- 可装备锦囊
			for k,itemInfo in pairs(bagInfo.pocket) do
				-- 筛选经验锦囊
				if( tonumber(itemInfo.itemDesc.is_exp) == 1 )then
					table.insert(curData,itemInfo)
				else
					table.insert(equipTab,itemInfo)
				end
			end
			-- 可装备的
			for k,v in pairs(equipTab) do
				table.insert(curData, v)
			end
			-- 按hid大小排序
			local temData = {}
			local herosEquips = HeroUtil.getAllPocketOnHeros()
			for k,v in pairs(herosEquips) do
				table.insert(temData,v)
			end
			function equipHidSort( data1, data2 )
				return tonumber(data1.equip_hid) < tonumber(data2.equip_hid)
			end
			table.sort( temData, equipHidSort )
			for i=1,#temData do
				table.insert(curData, temData[i])
			end
		elseif( _initTag == Tag_Init_Tally and bagInfo.tally )then  
			-- 兵符
			curData = {}
			for k,v in pairs(bagInfo.tally) do
				table.insert(curData, v)
			end
			-- 阵上已装备的
			local herosEquips = HeroUtil.getAllTallyOnHeros()
			local equipData = {}
			for k,v in pairs(herosEquips) do
				table.insert(equipData,v)
			end
			table.sort( equipData, BagUtil.tallySortForBag )
			for k,v in pairs(equipData) do
				table.insert(curData,v)
			end
			
		elseif( _initTag == Tag_Init_TallyFrag and bagInfo.tallyFrag )then 
			-- 兵符碎片
			curData = {}
			-- 把能合成的提出来 能合成的排在最前边
			local data = {}
			for k,v in pairs(bagInfo.tallyFrag) do
				if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
					table.insert(data,v)
				else
					table.insert(curData,v)
				end
			end
			for k,v in pairs(data) do
				table.insert(curData,v)
			end
		elseif(_initTag == Tag_Init_Chariot and bagInfo.chariotBag)then
			--战车
			curData = getAllChariot()
		else
		end
	end 
	createBagTableView()
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		PreRequest.setBagDataChangedDelete(refreshDataByType)
	elseif (event == "exit") then
		-- 保存偏移量
		saveBagLastOffset()

		PreRequest.setBagDataChangedDelete(nil)

		-- 把上个背包type置nil
		_bag_type = nil
	end
end

function createLayer(init_tag, bag_type)
	init()

	_initTag = init_tag or Tag_Init_Props
	_bag_type = bag_type
	if(_bag_type == nil)then
		if(_initTag == Tag_Init_Props)then
			_bag_type = Type_Bag_Prop_Treas
		elseif(_initTag ==  Tag_Init_GodWeapon or _initTag == Tag_Init_GodWeaponFrag)then  
			_bag_type = Type_Bag_GodWeapon
		elseif(_initTag ==  Tag_Init_Rune or _initTag == Tag_Init_RuneFrag)then   
			_bag_type = Type_Bag_Rune
		elseif( _initTag == Tag_Init_pocket )then
			_bag_type = Type_Bag_Pocket
		elseif( _initTag == Tag_Init_Treas )then
			_bag_type = Type_Bag_Treas
		elseif(_initTag ==  Tag_Init_Tally or _initTag == Tag_Init_TallyFrag)then     
			_bag_type = Type_Bag_Tally 
		elseif(_initTag == Tag_Init_Chariot)then
			_bag_type = Type_Bag_Chariot --战车
		else
			_bag_type = Type_Bag_Arm_Frag
		end
	end

	if(_bag_type == Type_Bag_Prop_Treas )then
		-- 清除提示小气泡
		PreRequest.clearNewuseItemNum()
		MenuLayer.refreshMenuItemTipSprite()
	end

	require "script/ui/main/MainScene"
	bgLayer = MainScene.createBaseLayer("images/main/module_bg.png")
	bgLayer:registerScriptHandler(onNodeEvent)
	addBagMenus()
	bagInfo = DataCache.getBagInfo()
	-- print_table("bagInfo ============= chariotBag", bagInfo.chariotBag)
	if (bagInfo == nil) then
		RequestCenter.bag_bagInfo(BagLayer.bagInfoCallbck)
	else 
		if (bagInfo)then
			if(_initTag == Tag_Init_Props  and bagInfo.props) then
				curData = {}
				for k,v in pairs(bagInfo.props) do
					table.insert(curData, v)
				end
			elseif( _initTag == Tag_Init_Arming and bagInfo.arm)then
				curData = {}
				for k,v in pairs(bagInfo.arm) do
					table.insert(curData, v)
				end
				local herosEquips = ItemUtil.getEquipsOnFormation()
				for k,v in pairs(herosEquips) do
					table.insert(curData, v)
				end
			elseif( _initTag == Tag_Init_Treas and bagInfo.treas)then
				curData = {}
				for k,v in pairs(bagInfo.treas) do
					table.insert(curData, v)
				end
				local herosTreas = ItemUtil.getTreasOnFormation()
				for k,v in pairs(herosTreas) do
					table.insert(curData, v)
				end
			elseif( _initTag == Tag_Init_ArmFrag and bagInfo.armFrag)then
				curData = {}
				for k,v in pairs(bagInfo.armFrag) do
					table.insert(curData, v)
				end
			elseif( _initTag == Tag_Init_Dress and bagInfo.dress)then
				curData = {} 
				for k,v in pairs(bagInfo.dress) do
					table.insert(curData, v)
				end
				local herosDress = ItemUtil.getDressOnFormation()
				for k,v in pairs(herosDress) do
					table.insert(curData, v)
				end
			elseif( _initTag == Tag_Init_GodWeapon and bagInfo.godWp )then 
				-- 神兵
				curData = {}
				local herosEquips = HeroUtil.getAllGodWeaponOnHeros()
				for k,v in pairs(bagInfo.godWp) do
					table.insert(curData, v)
				end
				-- 按hid大小排序
				local temData = {}
				for k,v in pairs(herosEquips) do
					table.insert(temData,v)
				end
				function equipHidSort( data1, data2 )
					return tonumber(data1.equip_hid) < tonumber(data2.equip_hid)
				end
				table.sort( temData, equipHidSort )
				for i=1,#temData do
					table.insert(curData, temData[i])
				end
			elseif( _initTag == Tag_Init_GodWeaponFrag and bagInfo.godWpFrag )then 
				-- 神兵碎片
				curData = {}
				for k,v in pairs(bagInfo.godWpFrag) do
					table.insert(curData, v)
				end
			elseif( _initTag == Tag_Init_Rune and bagInfo.rune )then 
				-- 符印
				curData = {}
				for k,v in pairs(bagInfo.rune) do
					table.insert(curData, v)
				end
				-- 阵上已镶嵌的
				local herosEquips = HeroUtil.getAllRuneOnHeros()
				for k,v in pairs(herosEquips) do
					table.insert(curData,v)
				end
				-- 宝物背包已镶嵌的
				local treasEquips = DataCache.getAllRuneInTreasureBag()
				for k,v in pairs(treasEquips) do
					table.insert(curData,v)
				end
			elseif( _initTag == Tag_Init_RuneFrag and bagInfo.runeFrag )then 
				-- 符印碎片
				curData = {}
				-- 把能合成的提出来 能合成的排在最前边
				local data = {}
				for k,v in pairs(bagInfo.runeFrag) do
					if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
						table.insert(data,v)
					else
						table.insert(curData,v)
					end
				end
				for k,v in pairs(data) do
					table.insert(curData,v)
				end
			elseif( _initTag == Tag_Init_pocket and bagInfo.pocket )then 
				-- 锦囊
				curData = {}
				local equipTab = {} -- 可装备锦囊
				for k,itemInfo in pairs(bagInfo.pocket) do
					-- 筛选经验锦囊
					if( tonumber(itemInfo.itemDesc.is_exp) == 1 )then
						table.insert(curData,itemInfo)
					else
						table.insert(equipTab,itemInfo)
					end
				end
				-- 可装备的
				for k,v in pairs(equipTab) do
					table.insert(curData, v)
				end
				-- 按hid大小排序
				local temData = {}
				local herosEquips = HeroUtil.getAllPocketOnHeros()
				for k,v in pairs(herosEquips) do
					table.insert(temData,v)
				end
				function equipHidSort( data1, data2 )
					return tonumber(data1.equip_hid) < tonumber(data2.equip_hid)
				end
				table.sort( temData, equipHidSort )
				for i=1,#temData do
					table.insert(curData, temData[i])
				end
			elseif( _initTag == Tag_Init_Tally and bagInfo.tally )then  
				-- 兵符
				curData = {}
				for k,v in pairs(bagInfo.tally) do
					table.insert(curData, v)
				end
				-- 阵上已装备的
				local herosEquips = HeroUtil.getAllTallyOnHeros()
				local equipData = {}
				for k,v in pairs(herosEquips) do
					table.insert(equipData,v)
				end
				table.sort( equipData, BagUtil.tallySortForBag )
				for k,v in pairs(equipData) do
					table.insert(curData,v)
				end
				
			elseif( _initTag == Tag_Init_TallyFrag and bagInfo.tallyFrag )then 
				-- 兵符碎片
				curData = {}
				-- 把能合成的提出来 能合成的排在最前边
				local data = {}
				for k,v in pairs(bagInfo.tallyFrag) do
					if(tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num))then
						table.insert(data,v)
					else
						table.insert(curData,v)
					end
				end
				for k,v in pairs(data) do
					table.insert(curData,v)
				end
			elseif(_initTag == Tag_Init_Chariot and bagInfo.chariotBag)then
				--战车
				curData = getAllChariot()
			else
			end
		end 
		createBagTableView()
	end
	
	return bgLayer
end

--获取所有战车数据(背包，阵上)
function getAllChariot( ... )
	--战车
	local tbAll = {}

	--背包中的战车
	bagInfo = DataCache.getBagInfo()
	for k,v in ipairs(bagInfo.chariotBag) do
		table.insert(tbAll, v)
		v.bag = 1
	end
	-- print("---------getAllChariot---------")
	-- print_t(bagInfo.chariotBag)
	-- print("---------getAllChariot---------")

	--阵上战车
	local mapFormationCharoit = ChariotMainData.getEquipChariotInfo()
	-- print("BagLayer getAllChariot ======== mapFormationCharoit")
	-- print_t(mapFormationCharoit)
	local arrFormationCharoit = {}
	if not table.isEmpty(mapFormationCharoit) then
		for nPosition, tbCharoit in pairs(mapFormationCharoit) do
			if not table.isEmpty(tbCharoit) then
				table.insert(arrFormationCharoit, tbCharoit)
			end
		end
		table.sort(arrFormationCharoit, BagUtil.sortChariotForBag)

		for k,v in ipairs(arrFormationCharoit) do
			table.insert(tbAll, v)
		end
	end

	return tbAll
end

------------------------------------------------ 按星级出售 -------------------------------------

-- 星级数据数组
local _star_level_data = {
	{number=1, tag=_ksTagStarLevelSell+1, },
	{number=2, tag=_ksTagStarLevelSell+2, },
	{number=3, tag=_ksTagStarLevelSell+3, },
}

-- 按星级出售菜单项回调处理
local function fnHandlerOfMenuItemStarLevelSell(tag, item_obj)
	-- “关闭”按钮事件处理
	if tag==_ksTagStarSellPanelCloseBtn or tag==_ksTagStarSellPanelSure then
		for i=1, #_star_level_data do
			local item = tolua.cast(_ccMenuStarSell:getChildByTag(_star_level_data[i].tag), "CCMenuItemImage")
			if item then
				local ccSelected = tolua.cast(item:getChildByTag(_star_level_data[i].tag), "CCSprite")
				if (ccSelected:isVisible()) then
					_star_level_data[i].isSelected = true
				end
			end
		end
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:removeChildByTag(_ksTagLayerStarSell, true)
		fnUpdateTableViewAfterStarSell()
	-- “全部选择”按钮事件处理
	elseif (tag == _ksTagStarSellPanelSelectAll) then
		_ccButtonSelectAll:setVisible(false)
		_ccButtonCancel:setVisible(true)
		for i=1, #_star_level_data do
			local item = tolua.cast(_ccMenuStarSell:getChildByTag(_star_level_data[i].tag), "CCMenuItemImage")
			if item then
				local ccSelected = tolua.cast(item:getChildByTag(_star_level_data[i].tag), "CCSprite")
				ccSelected:setVisible(true)
			end
		end
	-- “取消选择”按钮事件处理
	elseif tag == _ksTagStarSellPanelCancel then
		_ccButtonSelectAll:setVisible(true)
		_ccButtonCancel:setVisible(false)
		for i=1, #_star_level_data do
			local item = tolua.cast(_ccMenuStarSell:getChildByTag(_star_level_data[i].tag), "CCMenuItemImage")
			if item then
				local ccSelected = tolua.cast(item:getChildByTag(_star_level_data[i].tag), "CCSprite")
				ccSelected:setVisible(false)
			end
		end
	-- 各星级点击事件处理
	elseif (tag >= _ksTagStarLevelSell and tag <= _ksTagStarLevelSell+#_star_level_data) then
		local item = tolua.cast(_ccMenuStarSell:getChildByTag(tag), "CCMenuItemImage")
		local ccSelected = tolua.cast(item:getChildByTag(tag), "CCSprite")
		if (ccSelected:isVisible() == true) then
			ccSelected:setVisible(false)
		else
			ccSelected:setVisible(true)
		end
	end
end

-- 创建星级菜单项方法
local function createStarLevelMenuItem(star_level_data)
	local item = CCMenuItemImage:create("images/hero/star_sell/item_bg_n.png", "images/hero/star_sell/item_bg_h.png")
	item:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	-- 几星文本显示
	local ccLabelNumber = CCLabelTTF:create(star_level_data.number, g_sFontName, 30)
	ccLabelNumber:setColor(ccc3(0xff, 0xed, 0x55))
	ccLabelNumber:setPosition(ccp(78, 8))
	item:addChild(ccLabelNumber)
	-- 星图片
	local ccSpriteStar = CCSprite:create("images/hero/star.png")
	ccSpriteStar:setPosition(ccp(120, 14))
	item:addChild(ccSpriteStar)
	-- 是否选中显示
	local ccSpriteSelected = CCSprite:create("images/common/checked.png")
	ccSpriteSelected:setPosition(ccp(176, 10))
	ccSpriteSelected:setVisible(false)
	item:addChild(ccSpriteSelected, 0, star_level_data.tag)

	return item
end
local function fnFilterTouchEvent(event, x, y)
	return true
end

-- 创建按星级出售层  add by licong
function createLayerStarSell()
	local layer = CCLayerColor:create(ccc4(11,11,11,166))
	-- 背景九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	local ccStarSellBG = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	ccStarSellBG:setPreferredSize(CCSizeMake(524, 438))
	local bg_size = ccStarSellBG:getContentSize()
	ccStarSellBG:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	ccStarSellBG:setAnchorPoint(ccp(0.5, 0.5))
	-- 按星级出售标题背景
	local ccTitleBG = CCSprite:create("images/common/viewtitle1.png")
	ccTitleBG:setPosition(ccp(bg_size.width/2, bg_size.height-6))
	ccTitleBG:setAnchorPoint(ccp(0.5, 0.5))
	ccStarSellBG:addChild(ccTitleBG)
	-- 按星级出售标题文本
	local ccLabelTitle = CCLabelTTF:create (GetLocalizeStringBy("key_1487"), g_sFontName, 35, CCSizeMake(315, 61), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	ccLabelTitle:setPosition(ccp(ccTitleBG:getContentSize().width/2, (ccTitleBG:getContentSize().height-1)/2))
	ccLabelTitle:setAnchorPoint(ccp(0.5, 0.5))
	ccLabelTitle:setColor(ccc3(0xff, 0xf0, 0x49))
	ccTitleBG:addChild(ccLabelTitle)
	-- “请选择星级”文本显示
	local ccLabelTip = CCRenderLabel:create(GetLocalizeStringBy("key_3317"), g_sFontName, 30, 1, ccc3(0, 0, 0), type_stroke)
	ccLabelTip:setAnchorPoint(ccp(0.5, 0))
	ccLabelTip:setPositionX(bg_size.width/2)
	ccLabelTip:setColor(ccc3(0xff, 0xed, 0x55))
	ccLabelTip:setPositionY(356)
	ccStarSellBG:addChild(ccLabelTip)

	local menu = CCMenu:create()
	menu:setContentSize(bg_size)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(-454)
	-- 星级MenuItem
	local pos_y = 140
	for i=1, #_star_level_data do
		local item = createStarLevelMenuItem(_star_level_data[#_star_level_data-i+1])
		item:setPosition(ccp(bg_size.width/2, pos_y))
		item:setAnchorPoint(ccp(0.5, 0))
		menu:addChild(item, 0, _star_level_data[#_star_level_data-i+1].tag)
		pos_y = pos_y + item:getContentSize().height+10
	end

	local ccButtonClose = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	ccButtonClose:setAnchorPoint(ccp(1, 1))
	ccButtonClose:setPosition(ccp(bg_size.width+14, bg_size.height+14))
	ccButtonClose:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(ccButtonClose, 0, _ksTagStarSellPanelCloseBtn)

	ccStarSellBG:addChild(menu, 0, _ksTagStarSellPanelMenu)

	require "script/libs/LuaCC"
	_ccButtonSelectAll = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2776"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))

	-- 全部选择按钮
	_ccButtonSelectAll:setAnchorPoint(ccp(0.5, 0))
	_ccButtonSelectAll:setPosition(bg_size.width*0.3, 48)
	_ccButtonSelectAll:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(_ccButtonSelectAll, 0, _ksTagStarSellPanelSelectAll)
	-- 取消选择按钮
	_ccButtonCancel = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2982"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))

	_ccButtonCancel:setAnchorPoint(ccp(0.5, 0))
	_ccButtonCancel:setPosition(bg_size.width*0.3, 48)
	_ccButtonCancel:setVisible(false)
	_ccButtonCancel:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(_ccButtonCancel, 0, _ksTagStarSellPanelCancel)

-- 确定按钮
	local ccBtnSure = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2229"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))

	ccBtnSure:setAnchorPoint(ccp(0.5, 0))
	ccBtnSure:setPosition(bg_size.width*0.7, 48)
	ccBtnSure:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(ccBtnSure, 0, _ksTagStarSellPanelSure)

	_ccMenuStarSell = menu

	setAdaptNode(ccStarSellBG)
	layer:addChild(ccStarSellBG)
	layer:setTouchPriority(-451)
	layer:setTouchEnabled(true)
	layer:registerScriptTouchHandler(fnFilterTouchEvent,false,-450, true)

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, 1000, _ksTagLayerStarSell)
end

-- 更新英雄列表勾选状态方法(在按星级出售选择之后)
fnUpdateTableViewAfterStarSell = function ()
	local t_sellList = {}
	for i=1, #_star_level_data do
		if _star_level_data[i].isSelected then
			fnUpdateTableViewCellSelectionStatus(_star_level_data[i].number,t_sellList)
		end
		_star_level_data[i].isSelected = nil
	end


	-- 设置出售列表
	setSellEquipList(t_sellList)
	-- 更新tableView
	myTableView:reloadData()
end

-- 打钩
fnUpdateTableViewCellSelectionStatus = function (star_lv,tab)
	local sellList = {}
	for i = 1, #curData do
		if ( tonumber(curData[i].itemDesc.quality) == tonumber(star_lv)) then
			table.insert(tab,curData[i].gid)
		end
	end
end

-------------------------------------------- 神兵背包记忆 ---------------------------------------
--[[
	@des 	:保存记忆神兵itemid
	@param 	:p_itemId:目标itemid
	@return :
--]]
function setMarkGodWeaponItemId( p_itemId )
	_markGodItemId = p_itemId
	saveUseLastOffset( _markGodItemId )
end

-------------------------------------------- 兵符背包记忆 ---------------------------------------
--[[
	@des 	:保存记忆兵符itemid
	@param 	:p_itemId:目标itemid
	@return :
--]]
function setMarkTallyItemId( p_itemId )
	_markTallyItemId = p_itemId
	saveUseLastOffset( _markTallyItemId )
end


-------------------------------------------- 装备背包记忆 ---------------------------------------
--[[
	@des 	:保存记忆装备itemid
	@param 	:p_itemId:目标itemid
	@return :
--]]
function setMarkEquipItemId( p_itemId )
	_markEquipItemId = p_itemId
	saveUseLastOffset( _markEquipItemId )
end

-------------------------------------------- 时装背包记忆 ---------------------------------------
--[[
	@des 	:保存记忆时装itemid
	@param 	:p_itemId:目标itemid
	@return :
--]]
function setMarkDressItemId( p_itemId )
	_markDressItemId = p_itemId
	saveUseLastOffset( _markDressItemId )
end

-------------------------------------------- 宝物背包记忆 ---------------------------------------
--[[
	@des 	:保存记忆宝物itemid
	@param 	:p_itemId:目标itemid
	@return :
--]]
function setMarkTreasureItemId( p_itemId )
	_markTreasureItemId = p_itemId
	saveUseLastOffset( _markTreasureItemId )
end

-------------------------------------------- 锦囊背包记忆 ---------------------------------------
--[[
	@des 	:保存记忆锦囊itemid
	@param 	:p_itemId:目标itemid
	@return :
--]]
function setMarkPocketItemIdItemId( p_itemId )
	_markPocketItemId = p_itemId
	saveUseLastOffset( _markPocketItemId )
end

--[[
	@des 	:去往水月之境
	@param 	:
	@return :
--]]
function shuiyueBtnCallBack( ... )
	if(_isInRune)then
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
	else
		require "script/ui/moon/MoonLayer"
	    MoonLayer.show()
	end
end

--[[
	@des 	:得到显示背包的类型
	@param 	:
	@return :
--]]
function getShowBagType( ... )
	return _bag_type
end

--[[
	@des 	:设置是否从主界面进入符印背包
	@param 	:p_isIn true or false
	@return :
--]]
function setIsInRune( p_isIn )
	_isInRune = p_isIn
end

--[[
	@des 	:设置展开的cellIndex
	@param 	:pIndex
	@return :
--]]
function setOpenIndex( pIndex )
	_lastOpenIndex = _curOpenIndex
	_curOpenIndex = pIndex
end

--[[
	@des 	:得到展开的cellIndex
	@param 	:
	@return :pIndex
--]]
function getOpenIndex()
	return _curOpenIndex
end

--[[
	@des 	:得到展开的cellIndex
	@param 	:
	@return :pIndex
--]]
function refreshBagTableView( pAddHeight,pIndex )
	if(tolua.isnull(bgLayer))then  
		return
	end
	-- print("_curOpenIndex",_curOpenIndex)
	-- 偏移量记忆
	local offset = myTableView:getContentOffset()
	-- print("refreshBagTableView offset==>",offset.y,pIndex)
	myTableView:reloadData()
	-- print("visiableCellNum,",visiableCellNum,#curData)
	if( (_lastOpenIndex == 0 or pIndex == 0) and visiableCellNum <= #curData  )then
		offset.y = 0
	elseif( _lastOpenIndex == nil or _lastOpenIndex == pIndex )then
		offset.y = offset.y-pAddHeight*myScale
	end
	-- print("refreshBagTableView offset==>2",offset.y,_lastOpenIndex,pIndex)
	myTableView:setContentOffset(offset)
end
