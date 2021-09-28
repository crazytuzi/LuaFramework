-- FileName: GodBatchFixLayer.lua 
-- Author: licong 
-- Date: 15/3/25 
-- Purpose: 神兵批量洗练主界面


module("GodBatchFixLayer", package.seeall)

require "script/ui/godweapon/godweaponfix/GodBatchFixService"

local _bgLayer                  		= nil
local _bgSprite 						= nil
local _tableView 						= nil

local _showItemId 						= nil -- 神兵itemid
local _showItemInfo 					= nil -- 神兵信息
local _fixType 							= nil -- 洗练类型
local _fixIndex 						= nil -- 洗练第几层
local _curAttrId 						= nil -- 当前属性
local _showAttrTab 						= nil  -- 批量属性显示
local _curChooseIndex 					= nil -- 当前选择index
local _needGoldNum 						= nil -- 洗练一次需要的金币
local _needItemNum 						= nil -- 洗练一次需要的洗练石
local _isOnHero 						= false -- 装备是否在武将身上
local _hid 								= nil -- 武将hid

local _layer_priority 					= nil -- 界面优先级
local _zOrder 							= nil -- 界面z轴

local _bgSpTag 							= 100
local _chooseMenuTag 					= 101

--[[
    @des    :init
--]]
function init( ... )
	_bgLayer                    		= nil
	_bgSprite 							= nil
	_tableView 							= nil

	_showItemId 						= nil
	_showItemInfo 						= nil
	_fixIndex 							= nil
	_curAttrId 							= nil
	_showAttrTab 						= nil
	_needGoldNum 						= nil
	_needItemNum 						= nil 
	_isOnHero 							= false
	_hid 								= nil 
	_curChooseIndex 					= nil

	_layer_priority 					= nil
	_zOrder 							= nil 
end

--[[
    @des    :初始化数据
--]]
function initData( ... )
	-- 神兵是否在武将上
	_isOnHero = false
	-- 神兵信息
	_showItemInfo = ItemUtil.getItemByItemId(_showItemId)
	if(_showItemInfo == nil)then
		_showItemInfo = ItemUtil.getGodWeaponInfoFromHeroByItemId(_showItemId)
		-- 神兵是装备上的
		_isOnHero = true
		-- 装备神兵的hid
		_hid = _showItemInfo.hid
	end
	print("_showItemInfo=====>") print_t(_showItemInfo)

	-- 当前属性id
	_curAttrId = GodWeaponFixData.getGodWeapinConfirmAttr( _showItemId, _fixIndex)

end

-------------------------------------------------------- 按钮事件 ---------------------------------------------------------
--[[
	@des 	:touch事件处理
--]]
function layerTouch(eventType, x, y)
    return true
end

--[[
    @des    :回调onEnter和onExit事件
--]]
function onNodeEvent( event )
    if (event == "enter") then
        _bgLayer:registerScriptTouchHandler(layerTouch,false,_layer_priority,true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then
    end
end

--[[
	@des 	:返回按钮回调
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    -- 确定返回回调
	local yesBuyCallBack = function ( ... )
		local nextCallFun = function ( ... )
			if(_isOnHero == true)then 
	    		-- 把可替换的置{}
	    		HeroModel.changeHeroGodWeaponBatchBy(_hid,_showItemId, _fixIndex, {})
		    else
		    	-- 把可替换的置{}
		    	DataCache.changeGodWeaponBatchInBag( _showItemId, _fixIndex, {} )
		    end
			if(_bgLayer)then
				_bgLayer:removeFromParentAndCleanup(true)
				_bgLayer = nil
			end
			-- 刷新
		   	require "script/ui/godweapon/godweaponfix/GodWeaponFixAttrLayer"
		    local mark = GodWeaponFixAttrLayer.getShowMark()
	   		GodWeaponFixAttrLayer.showLayer(_showItemId,_fixIndex, mark)
		end
		-- 发送洗练请求
    	GodBatchFixService.cancel(_showItemId,_fixIndex,nextCallFun)
	end

    -- 当前属性未替换，您确定要返回？（未替换的属性将不被保存）
    local textInfo = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        linespace = 10, -- 行间距
	        elements =
	        {	
	        	{
	            	type = "CCLabelTTF",
	            	text = GetLocalizeStringBy("lic_1517"),
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        }
	 	}
 	local tipNode = LuaCCLabel.createRichLabel(textInfo)
 	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,360))
end

--[[
	@des 	:替换网络请求回调
--]]
function replaceServiceCallback()
	local nextCallFun = function ()
    	if(_isOnHero == true)then 
    		-- 修改英雄身上的数据
    		HeroModel.changeHeroGodWeaponConfirmedBy(_hid, _showItemId, _fixIndex, _showAttrTab[_curChooseIndex].attrId)
    		-- 把可替换的置{}
    		HeroModel.changeHeroGodWeaponBatchBy(_hid,_showItemId, _fixIndex, {})
	    else
	    	-- 修改背包数据
	    	DataCache.changeGodWeaponConfirmedInBag( _showItemId, _fixIndex, _showAttrTab[_curChooseIndex].attrId )
	    	-- 把可替换的置{}
	    	DataCache.changeGodWeaponBatchInBag( _showItemId, _fixIndex, {} )
	    end

	    -- 修改当前可替换属性id
	    _curChooseIndex = nil

	    -- 关闭当前模块
	    if(_bgLayer)then
			_bgLayer:removeFromParentAndCleanup(true)
			_bgLayer = nil
		end
	    -- 刷新
	   	require "script/ui/godweapon/godweaponfix/GodWeaponFixAttrLayer"
	    local mark = GodWeaponFixAttrLayer.getShowMark()
   		GodWeaponFixAttrLayer.showLayer(_showItemId,_fixIndex, mark)
    end
    -- 发送请求
    GodBatchFixService.ensure(_showItemId,_fixIndex,_showAttrTab[_curChooseIndex].attrId,nextCallFun)
end

--[[
	@des 	:替换按钮回调
--]]
function yesMenuItemCallback( tag, sender ) 
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 如果替换属性为空return
    if(_curChooseIndex == nil or _showAttrTab[_curChooseIndex] == nil or _showAttrTab[_curChooseIndex].attrId == nil)then 
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1520"))
    	return
    end

    -- 当前没有拥有属性的情况下 直接替换
    if(_curAttrId == nil)then
    	replaceServiceCallback()
   		return
    end

    -- 当前已拥有属性
   	local confirmAttrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById( _curAttrId )
   	local confirmAttrColor = GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, _fixIndex, _curAttrId )
   	-- 可替换属性
   	local toConfirmAttrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById( _showAttrTab[_curChooseIndex].attrId )
   	local toConfirmAttrColor = GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, _fixIndex, _showAttrTab[_curChooseIndex].attrId )

   	if( tonumber(toConfirmAttrInfo.star) > tonumber(confirmAttrInfo.star) )then
   		-- 可替换属性星级 >= 已拥有的星级 直接替换
   		replaceServiceCallback()
   		return
   	end

   	-- 替换高星级是弹二次确认
    -- 确定替换回调
	local yesBuyCallBack = function ( ... )
		-- 发送洗练请求
		replaceServiceCallback()
	end

    -- 您确定要用XXX x星替换XXX x星吗?
    local textInfo = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        linespace = 10, -- 行间距
	        elements =
	        {	
	        	{
	            	type = "CCRenderLabel", 
	            	text = toConfirmAttrInfo.name,
	            	color = toConfirmAttrColor
	        	},
	        	{
	            	type = "CCRenderLabel", 
	            	text = confirmAttrInfo.name,
	            	color = confirmAttrColor
	        	},
	        }
	 	}
 	local tipNode = GetLocalizeLabelSpriteBy_2("lic_1490", textInfo)
 	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,360))
end

--[[
	@des 	:批量洗练按钮回调
--]]
function batchMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 普通消耗需要的tid，数量
	local normalTid,_ = GodWeaponFixData.getGodWeapinOrdinaryFixCost(nil, _showItemId, _fixIndex )
    local myHaveNum = ItemUtil.getCacheItemNumBy(normalTid)

    -- 洗练石个数不够
    if( myHaveNum < _needItemNum )then  
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1481"))
		return
    end
    -- 金币不足
	if(UserModel.getGoldNumber() < _needGoldNum ) then  
		require "script/ui/tip/LackGoldTip"    
		LackGoldTip.showTip()
		return
	end
	-- 确认批量洗练
	local yesBuyCallBack = function ( ... )
	    -- 发请求
	    local nextCallBack = function ( p_retData )
	    	if(_isOnHero == true)then 
	    		-- 修改英雄身上的数据
	    		HeroModel.changeHeroGodWeaponBatchBy(_hid,_showItemId, _fixIndex, p_retData.arrAttrId)
		    else
		    	-- 修改背包数据
		    	DataCache.changeGodWeaponBatchInBag( _showItemId, _fixIndex, p_retData.arrAttrId )
		    end

		    -- 扣除金币
		    UserModel.addGoldNumber(-(_needGoldNum*table.count(p_retData.arrAttrId)))

		    -- 数据
		    _curChooseIndex = nil
		    _showAttrTab = p_retData.arrAttrId
		    -- 构造_showAttrTab数据结构为{ {inde=1,attrId = 1332}, {inde=2,attrId = 1333} }
			_showAttrTab = {}
			for i=1,#p_retData.arrAttrId do
				local temp = {}
				temp.index = i
				temp.attrId = p_retData.arrAttrId[i]
				table.insert(_showAttrTab,temp)
			end
	    	-- 刷新列表
	    	_tableView:reloadData()
	    end
	    require "script/ui/godweapon/godweaponfix/GodBatchFixService"
	    GodBatchFixService.batchWash(_showItemId, _fixType, _fixIndex,nextCallBack) 
	end

    -- 您是否花费XX洗练石（金币）洗练XX次吗？ 
    local textInfo = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        linespace = 10, -- 行间距
	 	}
	 	textInfo.elements = {}
	 	local tipArr = {}
	 	table.insert(textInfo.elements,tipArr)
	 	tipArr.type = "CCLabelTTF"
	 	tipArr.color = ccc3(0x78,0x25,0x00)
	 	if(_fixType == 1)then
	 		local num = nil
			if( math.floor(UserModel.getGoldNumber()/_needGoldNum) >= 10  ) then  
				num = 10
			else
				num = math.floor(UserModel.getGoldNumber()/_needGoldNum)
			end
	 		-- 金币
	 		tipArr.text = GetLocalizeStringBy("lic_1519",_needGoldNum*num, num)
	 	else
	 		-- 洗练石
	 		local num = nil
			if( math.floor(myHaveNum/_needItemNum) >= 10  ) then  
				num = 10
			else
				num = math.floor(myHaveNum/_needItemNum)
			end
	 		-- 金币
	 		tipArr.text = GetLocalizeStringBy("lic_1518",_needItemNum*num, num)
	 	end

 	local tipNode = LuaCCLabel.createRichLabel(textInfo)
 	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,360))
end

--[[
	@des 	:选择按钮回调
--]]
function chooseCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 当前选择id
    _curChooseIndex = tag

    -- 刷新状态
	local offset = _tableView:getContentOffset()
	_tableView:reloadData()
	_tableView:setContentOffset(offset)
end


--------------------------------------------------- 创建ui ------------------------------------------------------------------------
--[[
	@des 	:createCell
	@param 	:
	@return :cell
--]]
function createCell( p_attrTab )
	print("createCell",p_attrTab.index,p_attrTab.attrId)
	local cell = CCTableViewCell:create()

	local bgSp = CCScale9Sprite:create("images/common/bg/bg_9s_7.png")
	bgSp:setContentSize(CCSizeMake(500,50))
	bgSp:setAnchorPoint(ccp(0,1))
	bgSp:setPosition(ccp(0,94))
	cell:addChild(bgSp,1,_bgSpTag)

	local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_layer_priority-2)
    bgSp:addChild(menu,1,_chooseMenuTag)

	local chooseMenuItem = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png","images/common/btn/radio_selected.png")
	chooseMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	chooseMenuItem:setPosition(72, bgSp:getContentSize().height * 0.5)
	menu:addChild(chooseMenuItem,1,p_attrTab.index)
	chooseMenuItem:registerScriptTapHandler(chooseCallback)

	-- 名字属性
	local attrId = p_attrTab.attrId
	local attrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(attrId)
	local attrColor =  GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, _fixIndex, attrId )
	local attrNameFont = CCRenderLabel:create(attrInfo.name,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	attrNameFont:setColor(attrColor)
	attrNameFont:setAnchorPoint(ccp(0,0.5))
	attrNameFont:setPosition(ccp(170,bgSp:getContentSize().height * 0.5))
	bgSp:addChild(attrNameFont)
	-- 星数
	local starFont = CCRenderLabel:create(attrInfo.star,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	starFont:setColor(attrColor)
	starFont:setAnchorPoint(ccp(0,0.5))
	starFont:setPosition(ccp(100,attrNameFont:getPositionY()))
	bgSp:addChild(starFont)
	-- 星星sp
	local starSprite = CCSprite:create("images/formation/star.png")
	starSprite:setAnchorPoint(ccp(0,0.5))
	starSprite:setPosition(ccp(starFont:getPositionX()+starFont:getContentSize().width,starFont:getPositionY()))
	bgSp:addChild(starSprite)


	local attrDesFont = CCRenderLabel:create(attrInfo.dis,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	attrDesFont:setColor(attrColor)
	attrDesFont:setAnchorPoint(ccp(0,0.5))
	attrDesFont:setPosition(ccp(340,bgSp:getContentSize().height * 0.5))
	bgSp:addChild(attrDesFont)

	return cell
end

--[[
	@des 	:创建展示tableView
	@param 	:
	@return :
--]]
function createTableView( ... )
	-- 背景
	local second_bg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	second_bg:setContentSize(CCSizeMake(508, 413))
	second_bg:setAnchorPoint(ccp(0.5,1))
	second_bg:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height-76))
	_bgSprite:addChild(second_bg) 

	-- 洗练多少次
	_fixCountFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1516", table.count(_showAttrTab)) ,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_fixCountFont:setColor(ccc3(0xff,0xf6,0x00))
	_fixCountFont:setAnchorPoint(ccp(0.5,0.5))
	_fixCountFont:setPosition(ccp(second_bg:getContentSize().width*0.5,second_bg:getContentSize().height-18))
	second_bg:addChild(_fixCountFont)

	-- 创建tableView
	local cellSize = CCSizeMake(500, 94)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = createCell(_showAttrTab[a1+1])
			-- 保持选择状态
			if(_showAttrTab[a1+1] ~= nil and _showAttrTab[a1+1].index == _curChooseIndex )then 
				print("_showAttrTab[a1+1].index",_showAttrTab[a1+1].index,"_curChooseIndex",_curChooseIndex)
				a2:getChildByTag(_bgSpTag):getChildByTag(_chooseMenuTag):getChildByTag(_showAttrTab[a1+1].index):selected()
			end
			r = a2
		elseif fn == "numberOfCells" then
			r = #_showAttrTab
		else
		end
		return r
	end)

	_tableView = LuaTableView:createWithHandler(h, CCSizeMake(500, 362))
	_tableView:setBounceable(true)
	_tableView:setTouchPriority(_layer_priority-1)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5,0))
	_tableView:setPosition(ccp(second_bg:getContentSize().width*0.5,10))
	second_bg:addChild(_tableView)
	-- 设置单元格升序排列
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
	@des 	: 创建UI
--]]
function createUI()

	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	_bgSprite:setContentSize(CCSizeMake(544,582))
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(_bgSprite)
	setAdaptNode(_bgSprite)

	-- 标题背景
	local titleSp = CCSprite:create("images/common/red_2.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height))
	_bgSprite:addChild(titleSp)
	-- 标题
	local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1511") ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleFont:setColor(ccc3(0xff,0xf6,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
	titleSp:addChild(titleFont)

	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-2)
    _bgSprite:addChild(menuBar)

    -- 创建返回按钮 
	local closeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(146, 73), GetLocalizeStringBy("lic_1512"),ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	closeMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	closeMenuItem:setPosition(ccp( _bgSprite:getContentSize().width*0.2, 42 ))
	menuBar:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeButtonCallback)

	-- 替换按钮
	local yesMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(146, 73), GetLocalizeStringBy("lic_1513"),ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	yesMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	yesMenuItem:setPosition(ccp( _bgSprite:getContentSize().width*0.5, 42 ))
	menuBar:addChild(yesMenuItem)
	yesMenuItem:registerScriptTapHandler(yesMenuItemCallback)

	-- 批量洗练按钮
	local batchMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(164, 73), GetLocalizeStringBy("lic_1514"),ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	batchMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	batchMenuItem:setPosition(ccp( _bgSprite:getContentSize().width*0.8, 42 ))
	menuBar:addChild(batchMenuItem)
	batchMenuItem:registerScriptTapHandler(batchMenuItemCallback)

	-- 当前属性
	local curFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1515") ,g_sFontPangWa,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	curFont:setColor(ccc3(0xff,0xf6,0x00))
	curFont:setAnchorPoint(ccp(0,0.5))
	curFont:setPosition(ccp(50,_bgSprite:getContentSize().height-44))
	_bgSprite:addChild(curFont)

	-- 属性名字
	print("_curAttrId",_curAttrId)
	if(_curAttrId ~= nil)then
		local attrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(_curAttrId)
		local attrColor =  GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, _fixIndex, _curAttrId )
		local attrNameFont = CCRenderLabel:create(attrInfo.name,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameFont:setColor(attrColor)
		attrNameFont:setAnchorPoint(ccp(0,0.5))
		attrNameFont:setPosition(ccp(150,curFont:getPositionY()))
		_bgSprite:addChild(attrNameFont)
		-- 星数
		local starFont = CCRenderLabel:create(attrInfo.star,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		starFont:setColor(attrColor)
		starFont:setAnchorPoint(ccp(0,0.5))
		starFont:setPosition(ccp(280,attrNameFont:getPositionY()))
		_bgSprite:addChild(starFont)
		-- 星星sp
		local starSprite = CCSprite:create("images/formation/star.png")
		starSprite:setAnchorPoint(ccp(0,0.5))
		starSprite:setPosition(ccp(starFont:getPositionX()+starFont:getContentSize().width,starFont:getPositionY()))
		_bgSprite:addChild(starSprite)

		local attrDesFont = CCRenderLabel:create(attrInfo.dis,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrDesFont:setColor(attrColor)
		attrDesFont:setAnchorPoint(ccp(0,0.5))
		attrDesFont:setPosition(ccp(360,curFont:getPositionY()))
		_bgSprite:addChild(attrDesFont)
	else
		local curFontTip = CCRenderLabel:create(GetLocalizeStringBy("lic_1480") ,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		curFontTip:setColor(ccc3(0xff,0xff,0xff))
		curFontTip:setAnchorPoint(ccp(0,0.5))
		curFontTip:setPosition(ccp(190,curFont:getPositionY()))
		_bgSprite:addChild(curFontTip)
	end

	--创建tableView
	createTableView()
	
end

--[[
	@des 	: 显示可洗练属性界面
	@param 	:p_godWeaponItemId:神兵itemid, p_index:第几层属性, p_layer_priority:界面优先级, p_zOrder:界面Z轴
	@return :
--]]
function showLayer( p_godWeaponItemId, p_type, p_index, p_showAttrTab, p_needGoldNum, p_needItemNum, p_layer_priority, p_zOrder )
	print("p_godWeaponItemId",p_godWeaponItemId, "p_type",p_type, "p_index",p_index, "p_showAttrTab",p_showAttrTab, "p_needGoldNum",p_needGoldNum, "p_needItemNum",p_needItemNum, "p_layer_priority",p_layer_priority, "p_zOrder",p_zOrder)
	-- 初始化
	init()

	-- 接收参数
	_showItemId = p_godWeaponItemId
	_fixType = p_type
	_fixIndex = p_index
	_layer_priority = p_layer_priority or -600
	_zOrder = p_zOrder or 1000
	
	_needGoldNum = p_needGoldNum
	_needItemNum = p_needItemNum

	-- 构造_showAttrTab数据结构为{ {inde=1,attrId = 1332}, {inde=2,attrId = 1333} }
	_showAttrTab = {}
	for i=1,#p_showAttrTab do
		local temp = {}
		temp.index = i
		temp.attrId = p_showAttrTab[i]
		table.insert(_showAttrTab,temp)
	end

	-- 初始化数据
	initData()

	-- 创建ui
	_bgLayer = CCLayerColor:create(ccc4(8,8,8,150))
    _bgLayer:registerScriptHandler(onNodeEvent) 
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder,1)

    -- 创建ui
    createUI()
end












