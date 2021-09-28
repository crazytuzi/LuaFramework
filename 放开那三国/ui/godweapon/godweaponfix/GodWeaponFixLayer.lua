-- FileName: GodWeaponFixLayer.lua 
-- Author: licong 
-- Date: 15-1-13 
-- Purpose: 神兵洗练信息界面


module("GodWeaponFixLayer", package.seeall)

require "script/ui/godweapon/godweaponfix/GodWeaponFixData"

local _bgLayer 							= nil
local _bgSprite 						= nil

local _showItemId 						= nil -- 洗练的物品itemid
local _showItemInfo 					= nil -- 洗练物品的信息
local _quality 							= nil -- 神兵品质
local _evolveNum 						= nil -- 神兵进阶次数
local _evolveShowNum 					= nil -- 神兵进阶显示阶数
local _isOnHero 						= nil -- 神兵是否装备在英雄上
local _hid 								= nil -- 装备神兵的hid
local _fixNum  							= nil -- 洗练的总层数
local _needQualityTab 					= nil -- 洗练解封需要的品质数组


local _showMark 						= nil -- 界面跳转tag

------------------------------ 常量 -----------------------------------
-- 页面跳转tag
kTagBag 				= 100
kTagFormation 			= 101
-- 界面优先级
local _layer_priority 	= -500
-- 洗练属性背景y坐标
local _attrSpritePosY = {0.5,0.38,0.26,0.14,0.02}

--[[
	@des 	:初始化
--]]
function init()
	_bgLayer 							= nil
	_bgSprite 							= nil

	_showItemId 						= nil
	_showItemInfo 						= nil 
	_quality 							= nil
	_evolveNum 							= nil
	_evolveShowNum 						= nil
	_isOnHero 							= nil
	_hid 								= nil
	_fixNum  							= nil
	_needQualityTab 					= nil

	_showMark 							= nil
end

--[[
	@des 	:初始化数据
--]]
function initData()
	-- 神兵是否在武将上
	_isOnHero = false
	-- 强化神兵的信息
	_showItemInfo = ItemUtil.getItemByItemId(_showItemId)
	if(_showItemInfo == nil)then
		_showItemInfo = ItemUtil.getGodWeaponInfoFromHeroByItemId(_showItemId)
		-- 神兵是装备上的
		_isOnHero = true
		-- 装备神兵的hid
		_hid = _showItemInfo.hid
	end
	-- 强化神兵的品质,进阶次数，显示阶数
	_quality,_evolveNum,_evolveShowNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,_showItemInfo)
	-- 洗练的总层数
	_fixNum = GodWeaponFixData.getGodWeapinFixNum(nil,_showItemId)
	-- 解封需要的品质数组
	_needQualityTab = GodWeaponFixData.getGodWeapinFixNeedQualityTab(nil,_showItemId)
	
end

---------------------------------------------------------------- 界面跳转记忆 --------------------------------------------------------------------
--[[
	@des 	:设置页面跳转记忆
	@param 	:p_mark:页面跳转mark
	@return :
--]]
function setChangeLayerMark( p_mark )
  	_showMark = p_mark
end

--[[
	@des 	:页面跳转记忆
	@param 	:
	@return :
--]]
function changeLayerMark()
  	if(_showMark == kTagBag)then
  		-- 背包
  		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_GodWeapon)
		MainScene.changeLayer(bagLayer, "bagLayer")
  	elseif(_showMark == kTagFormation)then
  		-- 阵容
  		require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer(_hid, false, false, nil, 3)
        MainScene.changeLayer(formationLayer, "formationLayer")
  	else
  		-- 背包
  		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_GodWeapon)
		MainScene.changeLayer(bagLayer, "bagLayer")
  	end
end

---------------------------------------------------------------- 按钮事件 -------------------------------------------------------------------
--[[
	@des 	:返回按钮回调
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	-- 跳转界面
	changeLayerMark()
end

--[[
	@des 	:传承按钮回调
--]]
function inheritMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    require "script/ui/godweapon/godinherit/GodInheritLayer"
    GodInheritLayer.showLayer( _showItemId  )
    GodInheritLayer.setChangeLayerMark( _showMark )
end

--[[
	@des 	:可洗练属性按钮回调
--]]
function showMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    require "script/ui/godweapon/godweaponfix/ShowCanFixDialog"
    ShowCanFixDialog.showLayer( _showItemId, _layer_priority-10, 1000 )
end

--[[
	@des 	:洗练按钮回调
--]]
function fixMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

   print("fixMenuItemCallback .. tag:",tag)

   require "script/ui/godweapon/godweaponfix/GodWeaponFixAttrLayer"
   GodWeaponFixAttrLayer.showLayer(_showItemId,tag, _showMark)

end
----------------------------------------------------------------------- 创建UI -------------------------------------------------------------------------
--[[
	@des 	:创建底部UI
	@param 	:p_fixId:洗练属性层id
	@return :sprite
--]]
function createAttrUI(p_fixId)

	-- 该层封印是否解封
	local isOpen = GodWeaponFixData.getGodWeapinFixIsOpneByFixNum(nil, _showItemId, p_fixId)

	local retSprite = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	retSprite:setContentSize(CCSizeMake(588, 97))

	-- 洗练按钮
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_layer_priority-2)
    retSprite:addChild(menu)

    -- 创建洗练按钮
    local normalSp = CCSprite:create("images/god_weapon/xi_n.png")
    local selectSp = CCSprite:create("images/god_weapon/xi_h.png")
    local disSp = BTGraySprite:create("images/god_weapon/xi_n.png")
	local fixMenuItem = CCMenuItemSprite:create(normalSp, selectSp, disSp)
	fixMenuItem:setAnchorPoint(ccp(1, 0.5))
	fixMenuItem:setPosition(ccp( retSprite:getContentSize().width,retSprite:getContentSize().height*0.5 ))
	menu:addChild(fixMenuItem,1,tonumber(p_fixId))
	fixMenuItem:registerScriptTapHandler(fixMenuItemCallback)

	local titleSp 				= nil -- 标题背景
	local fontColor 			= nil -- 标题颜色
	local iconArr				= {"lv.png","lan.png","zi.png","cheng.png","hong.png"} -- 层图标
	local iconSprite 			= nil -- 层图标

	if(isOpen)then
		fixMenuItem:setEnabled(true)
		titleSp = CCSprite:create("images/common/red_2.png")
		fontColor = ccc3(0xff,0xf6,0x00)
		iconSprite = CCSprite:create( "images/god_weapon/fix/" .. iconArr[p_fixId] )
	else
		-- 未开启置灰
		fixMenuItem:setEnabled(false)
		titleSp = BTGraySprite:create("images/common/red_2.png")
		fontColor = ccc3(0xca, 0xca, 0xca)
		iconSprite = BTGraySprite:create( "images/god_weapon/fix/" .. iconArr[p_fixId] )
	end

	-- 标题背景
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height))
	retSprite:addChild(titleSp)
	-- 标题
	local titleArr = {GetLocalizeStringBy("lic_1457"),GetLocalizeStringBy("lic_1458"),GetLocalizeStringBy("lic_1459"),GetLocalizeStringBy("lic_1460"),GetLocalizeStringBy("llp_515")}
	local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1456",titleArr[p_fixId]) ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleFont:setColor(fontColor)
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
	titleSp:addChild(titleFont)

	-- 层图标
	iconSprite:setAnchorPoint(ccp(0,0.5))
	iconSprite:setPosition(ccp(12,retSprite:getContentSize().height*0.5))
	retSprite:addChild(iconSprite)

	-- 属性描述
	if(isOpen)then
		local attrId = GodWeaponFixData.getGodWeapinConfirmAttr( _showItemId, p_fixId)
		print("attrId",attrId,"p_fixId",p_fixId)
		if(attrId == nil)then
			local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1480") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			tipFont:setColor(ccc3(0xff,0xff,0xff))
			tipFont:setAnchorPoint(ccp(0.5,0.5))
			tipFont:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height*0.5))
			retSprite:addChild(tipFont)
		else
			-- 属性数据
			local attrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(attrId)
			local attrColor = GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, p_fixId, attrId )
			-- 属性名字
			local attrNameFont = CCRenderLabel:create(attrInfo.name,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrNameFont:setColor(attrColor)
			attrNameFont:setAnchorPoint(ccp(0,0.5))
			attrNameFont:setPosition(ccp(148,retSprite:getContentSize().height-43))
			retSprite:addChild(attrNameFont)

			-- 星数
			local starFont = CCRenderLabel:create(attrInfo.star,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			starFont:setColor(attrColor)
			starFont:setAnchorPoint(ccp(0,0.5))
			starFont:setPosition(ccp(307,retSprite:getContentSize().height-43))
			retSprite:addChild(starFont)
			-- 星星sp
			local starSprite = CCSprite:create("images/formation/star.png")
			starSprite:setAnchorPoint(ccp(0,0.5))
			starSprite:setPosition(ccp(starFont:getPositionX()+starFont:getContentSize().width,starFont:getPositionY()))
			retSprite:addChild(starSprite)

			-- 描述
		    local textInfo = {
		     		width = 318, -- 宽度
			        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
			        labelDefaultFont = g_sFontName,      -- 默认字体
			        labelDefaultSize = 18,          -- 默认字体大小
			        linespace = 2, -- 行间距
			        elements =
			        {	
			            {
			            	type = "CCRenderLabel", 
			            	text = attrInfo.dis,
			            	color = ccc3(0xff,0xff,0xff)
			        	}
			        }
			 	}
		 	local desFont = LuaCCLabel.createRichLabel(textInfo)
		 	desFont:setAnchorPoint(ccp(0, 1))
		 	desFont:setPosition(ccp(148,retSprite:getContentSize().height-60))
		 	retSprite:addChild(desFont)
		end
	else
    	local attrId = GodWeaponFixData.getGodWeapinConfirmAttr( _showItemId, p_fixId)
		print("attrId",attrId,"p_fixId",p_fixId)
		if(attrId == nil)then
			-- 未开启 提示
			local tipFont1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1468",titleArr[p_fixId]) ,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			tipFont1:setColor(ccc3(0xca, 0xca, 0xca))
			tipFont1:setAnchorPoint(ccp(0,0.5))
			tipFont1:setPosition(ccp(147,retSprite:getContentSize().height*0.56))
			retSprite:addChild(tipFont1)

			-- 洗练开启条件
			require "script/ui/hero/HeroPublicLua"
			local richInfo = {}
	        richInfo.defaultType = "CCRenderLabel"
	        richInfo.labelDefaultColor = ccc3(0xff, 0xff, 0xff)
	       	richInfo.labelDefaultSize = 23
	       	richInfo.labelDefaultFont = g_sFontName
	        richInfo.elements = {
	        	{
	        		text = HeroPublicLua.getCCColorDesByStarLevel(tonumber(_needQualityTab[p_fixId])) ,
	        		color = HeroPublicLua.getCCColorByStarLevel(tonumber(_needQualityTab[p_fixId]))
	        	}
	    	}
	    	local tipFont2 = GetLocalizeLabelSpriteBy_2("lic_1469", richInfo)
	    	tipFont2:setAnchorPoint(ccp(0, 0.5))
	    	tipFont2:setPosition(ccp(147,retSprite:getContentSize().height*0.24))
	    	retSprite:addChild(tipFont2)
		else
			-- 属性数据
			local attrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(attrId)
			local attrColor = ccc3(0xca, 0xca, 0xca)
			-- 属性名字
			local attrNameFont = CCRenderLabel:create(attrInfo.name,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrNameFont:setColor(attrColor)
			attrNameFont:setAnchorPoint(ccp(0,0.5))
			attrNameFont:setPosition(ccp(148,retSprite:getContentSize().height-43))
			retSprite:addChild(attrNameFont)

			-- 星数
			local starFont = CCRenderLabel:create(attrInfo.star,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			starFont:setColor(attrColor)
			starFont:setAnchorPoint(ccp(0,0.5))
			starFont:setPosition(ccp(307,retSprite:getContentSize().height-43))
			retSprite:addChild(starFont)
			-- 星星sp
			local starSprite = BTGraySprite:create("images/formation/star.png")
			starSprite:setAnchorPoint(ccp(0,0.5))
			starSprite:setPosition(ccp(starFont:getPositionX()+starFont:getContentSize().width,starFont:getPositionY()))
			retSprite:addChild(starSprite)

			-- 描述
		    local textInfo = {
		     		width = 318, -- 宽度
			        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
			        labelDefaultFont = g_sFontName,      -- 默认字体
			        labelDefaultSize = 18,          -- 默认字体大小
			        linespace = 2, -- 行间距
			        elements =
			        {	
			            {
			            	type = "CCRenderLabel", 
			            	text = attrInfo.dis,
			            	color = attrColor
			        	}
			        }
			 	}
		 	local desFont = LuaCCLabel.createRichLabel(textInfo)
		 	desFont:setAnchorPoint(ccp(0, 1))
		 	desFont:setPosition(ccp(148,retSprite:getContentSize().height-60))
		 	retSprite:addChild(desFont)
		end
	end


	return retSprite
end

--[[
	@des 	:创建上部分UI
--]]
function createTopUI()
	-- 神兵洗练标题
    local titleSp = CCSprite:create("images/god_weapon/fix/title.png")
    titleSp:setAnchorPoint(ccp(0,1))
    titleSp:setPosition(ccp(10,_bgLayer:getContentSize().height-13*g_fElementScaleRatio ))
    _bgLayer:addChild(titleSp)
    titleSp:setScale(g_fElementScaleRatio)

    --名称底
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBgSprite:setContentSize(CCSizeMake(215,45))
	nameBgSprite:setAnchorPoint(ccp(0.5,1))
	nameBgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-15*g_fElementScaleRatio))
	_bgLayer:addChild(nameBgSprite,10)
	nameBgSprite:setScale(g_fElementScaleRatio)

	--名字+阶数
	local nameLabel = CCRenderLabel:create(_showItemInfo.itemDesc.name .. GetLocalizeStringBy("lic_1428",_evolveShowNum) ,g_sFontPangWa,25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_quality))
	nameLabel:setAnchorPoint(ccp(0.5,0.5))
	nameLabel:setPosition(ccp(nameBgSprite:getContentSize().width*0.5,nameBgSprite:getContentSize().height*0.5))
	nameBgSprite:addChild(nameLabel)

	--五行图片
	local fiveSprite = CCSprite:create("images/god_weapon/five/" .. _showItemInfo.itemDesc.type .. ".png")
	fiveSprite:setAnchorPoint(ccp(1,1))
	fiveSprite:setPosition(ccp(30,-30))
	nameBgSprite:addChild(fiveSprite,10)

	-- 大阵法特效
	local bigAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/god_weapon/effect/shenbingjinjiehuang/shenbingjinjiehuang" ), -1,CCString:create(""))
    bigAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    bigAnimSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.55))
    _bgLayer:addChild(bigAnimSprite)
    bigAnimSprite:setScale(g_fElementScaleRatio)

	--神兵全身像
	local godWeaponBodySprite = GodWeaponItemUtil.getWeaponBigSprite(nil,nil,_hid,_showItemInfo)
	godWeaponBodySprite:setAnchorPoint(ccp(0.5,0))
	godWeaponBodySprite:setPosition(ccp(0,0))
	bigAnimSprite:addChild(godWeaponBodySprite,3)

	-- 返回按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-2)
    _bgLayer:addChild(menuBar)

    -- 创建返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1, 1))
	closeMenuItem:setPosition(ccp( _bgLayer:getContentSize().width-10*g_fElementScaleRatio,_bgLayer:getContentSize().height-10*g_fElementScaleRatio ))
	menuBar:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeButtonCallback)
	closeMenuItem:setScale(g_fElementScaleRatio)

	-- 创建可洗练属性按钮
	local showMenuItem = CCMenuItemImage:create("images/god_weapon/fix/show_n.png","images/god_weapon/fix/show_h.png")
	showMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	showMenuItem:setPosition(ccp( 60*g_fElementScaleRatio, _bgLayer:getContentSize().height*0.76 ))
	menuBar:addChild(showMenuItem)
	showMenuItem:registerScriptTapHandler(showMenuItemCallback)
	showMenuItem:setScale(g_fElementScaleRatio)

	-- 创建传承按钮
	local inheritMenuItem = CCMenuItemImage:create("images/god_weapon/inherit_n.png","images/god_weapon/inherit_h.png")
	inheritMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	inheritMenuItem:setPosition(ccp( 60*g_fElementScaleRatio, _bgLayer:getContentSize().height*0.64 ))
	menuBar:addChild(inheritMenuItem)
	inheritMenuItem:registerScriptTapHandler(inheritMenuItemCallback)
	inheritMenuItem:setScale(g_fElementScaleRatio)

end

--[[
	@des 	:创建底部UI
--]]
function createBottomUI()
	-- 创建每一条洗练属性
	local cell_icon_count = _fixNum
	local cell_size = CCSizeMake(600,120)

	h = LuaEventHandler:create(function(function_name, table_t, a1, cell)
		if function_name == "cellSize" then
			return cell_size
		elseif function_name == "cellAtIndex" then
			cell = CCTableViewCell:create()
			local cellSprite = createAttrUI(a1+1)
			cell:addChild(cellSprite)
			return cell
		elseif function_name == "numberOfCells" then
			return _fixNum
		elseif function_name == "cellTouched" then
			print("a1=====", a1:getIdx())
		elseif (function_name == "scroll") then
		end
	end)
	local _head_table_view = LuaTableView:createWithHandler(h, CCSizeMake(600, 400))
    _head_table_view:ignoreAnchorPointForPosition(false)
    _head_table_view:setAnchorPoint(ccp(0.5, 0))
	_head_table_view:setBounceable(true)
	_head_table_view:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, 0))
	_head_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    _head_table_view:setTouchPriority(_layer_priority - 2)
	_bgLayer:addChild(_head_table_view,1)
	_head_table_view:setScale(g_fElementScaleRatio)

	-- for i=1,_fixNum do
	-- 	local attrSprite = createAttrUI(i)
	-- 	attrSprite:setAnchorPoint(ccp(0.5,0))
	-- 	attrSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*_attrSpritePosY[ i+(#_attrSpritePosY-_fixNum) ]))
	-- 	_bgLayer:addChild(attrSprite)
	-- 	attrSprite:setScale(g_fElementScaleRatio)
	-- end
end

--[[
	@des 	:创建神兵洗练界面
	@param 	:p_item_id
	@return :
--]]
function createLayer( p_item_id  )
	-- 初始化变量
	init()

	-- 接收参数
	_showItemId = tonumber(p_item_id)

	-- 隐藏下排按钮
	MainScene.setMainSceneViewsVisible(false, false, false)

	_bgLayer = CCLayer:create()

    -- 大背景
    _bgSprite = CCSprite:create("images/god_weapon/evolve_bg.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)
	
    -- 初始化数据
    initData()

    -- 创建上部分UI
    createTopUI()

    -- 创建下部分UI
    createBottomUI()

    return _bgLayer
end

--[[
	@des 	:显示神兵洗练界面
	@param 	:p_item_id
	@return :
--]]
function showLayer( p_item_id  )
	local layer = createLayer( p_item_id )
	MainScene.changeLayer(layer, "GodWeaponFixLayer")
end
































































