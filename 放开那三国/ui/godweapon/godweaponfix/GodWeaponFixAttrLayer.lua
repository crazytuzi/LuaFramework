-- FileName: GodWeaponFixAttrLayer.lua 
-- Author: licong 
-- Date: 15-1-15 
-- Purpose: 神兵洗练替换属性界面 


module("GodWeaponFixAttrLayer", package.seeall)

require "script/ui/godweapon/godweaponfix/GodWeaponFixData"
require "script/ui/godweapon/godweaponfix/GodWeaponFixService"

local _bgLayer 							= nil
local _bgSprite 						= nil -- 大背景
local _leftSprite 						= nil -- 左边属性框
local _rightSprite 						= nil -- 右边属性框
local _curRadioMenuItem 				= nil -- 当前选择洗练按钮
local _normalMenuItem 					= nil -- 普通洗练按钮
local _goldMenuItem 					= nil -- 金币洗练按钮
local _haveNumFont 						= nil -- 拥有洗练石个数

local _showItemId 						= nil -- 洗练的物品itemid
local _showItemInfo 					= nil -- 洗练物品的信息
local _quality 							= nil -- 神兵品质
local _evolveNum 						= nil -- 神兵进阶次数
local _evolveShowNum 					= nil -- 神兵进阶显示阶数
local _isOnHero 						= nil -- 神兵是否装备在英雄上
local _hid 								= nil -- 装备神兵的hid
local _curRadioType 					= nil -- 当前选择洗练类型
local _normalTid 						= nil -- 普通洗练消耗物品tid
local _normalNeedNum 					= nil -- 普通洗练需要的物品数量
local _goldTid  						= nil -- 金币洗练需要物品tid
local _goldNeedNum 						= nil -- 金币洗练需要的物品数量
local _goldCostNum 						= nil -- 金币洗练消耗的金币数量
local _fixId 							= nil -- 洗练第几层
local _myHaveNum 						= nil -- 拥有的洗练石个数
local _toConfirmAttrId 					= nil -- 可替换属性
local _confirmAttrId 					= nil -- 已拥有属性
local _myHaveGoldNumFont 				= nil -- 我拥有的金币数量

local _showMark 						= nil -- 跳转记忆

------------------------------ 常量 -----------------------------------
-- 界面优先级
local _layer_priority 	= -500
local _leftType 		= 101 -- 标识坐标属性框
local _rightType  		= 102 -- 标识右边属性框
local _normalTag		= 1001 -- 普通洗练
local _goldTag 			= 1002 -- 金币洗练

--[[
	@des 	:初始化
--]]
function init()
	_bgLayer 							= nil
	_bgSprite 							= nil
	_leftSprite 						= nil
	_rightSprite 						= nil
	_curRadioMenuItem 					= nil
	_normalMenuItem 					= nil
	_goldMenuItem 						= nil
	_haveNumFont 						= nil
	_myHaveGoldNumFont 					= nil

	_showItemId 						= nil
	_showItemInfo 						= nil 
	_quality 							= nil
	_evolveNum 							= nil
	_evolveShowNum 						= nil
	_isOnHero 							= nil
	_hid 								= nil
	_curRadioType 						= nil
	_normalTid 							= nil
	_normalNeedNum 						= nil
	_goldTid  							= nil
	_goldNeedNum 						= nil
	_goldCostNum 						= nil
	_fixId 								= nil
	_myHaveNum 							= nil 
	_toConfirmAttrId 					= nil
	_confirmAttrId 						= nil

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
	print("_showItemInfo=====>") print_t(_showItemInfo)
	-- 强化神兵的品质,进阶次数，显示阶数
	_quality,_evolveNum,_evolveShowNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,_showItemInfo)
	-- 普通消耗需要的tid，数量
	_normalTid,_normalNeedNum = GodWeaponFixData.getGodWeapinOrdinaryFixCost(nil, _showItemId, _fixId )
	-- 金币消耗需要的tid，需要数量，需要金币
	_goldTid,_goldNeedNum,_goldCostNum = GodWeaponFixData.getGodWeapinGoldFixCost(nil, _showItemId, _fixId )
	-- 拥有的洗练石个数
	_myHaveNum = ItemUtil.getCacheItemNumBy(_normalTid)
	-- 可替换属性id
	_toConfirmAttrId = GodWeaponFixData.getGodWeapinToConfirmAttr( _showItemId, _fixId)
	-- 已拥有属性id
	_confirmAttrId = GodWeaponFixData.getGodWeapinConfirmAttr( _showItemId, _fixId)
end

--[[
	@des 	:得到显示标记
--]]
function getShowMark()
	return _showMark
end
---------------------------------------------------------------- 按钮事件 -------------------------------------------------------------------
--[[
	@des 	:返回按钮回调
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	-- 返回洗练信息界面
	require "script/ui/godweapon/godweaponfix/GodWeaponFixLayer"
	GodWeaponFixLayer.showLayer(_showItemId)
	-- 设置界面记忆
	GodWeaponFixLayer.setChangeLayerMark( _showMark )
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
	@des 	:批量洗练属性按钮回调
--]]
function batchMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    local fixType = nil
    local needGold = 0
    local needItemNum = 0
    if(_curRadioType == _goldTag)then
    	-- 金币洗练
    	fixType = 1
    	needGold = _goldCostNum
    	needItemNum = _goldNeedNum
    else
    	-- 普通洗练
    	fixType = 0
    	needGold = 0
    	needItemNum = _normalNeedNum
    end

    -- 洗练石个数不够
    if( _myHaveNum < needItemNum )then  
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1481"))
		return
    end
    -- 金币不足
	if(UserModel.getGoldNumber() < needGold ) then  
		require "script/ui/tip/LackGoldTip"    
		LackGoldTip.showTip()
		return
	end

    -- 确定批量回调
	local yesBuyCallBack = function ( ... )
		-- 发请求
	    local nextCallBack = function ( p_retData )
	    	if(_isOnHero == true)then 
	    		-- 修改英雄身上的数据
	    		HeroModel.changeHeroGodWeaponBatchBy(_hid,_showItemId, _fixId, p_retData.arrAttrId)
		    else
		    	-- 修改背包数据
		    	DataCache.changeGodWeaponBatchInBag( _showItemId, _fixId, p_retData.arrAttrId )
		    end

		    -- 扣除金币
		    UserModel.addGoldNumber(-(needGold*table.count(p_retData.arrAttrId)))

		    -- 修改洗练石个数
		    _myHaveNum = _myHaveNum - needItemNum*table.count(p_retData.arrAttrId)
		    -- 刷新个数
		    _haveNumFont:setString("X " .. _myHaveNum )
		    -- 刷新金币数量
		    _myHaveGoldNumFont:setString(UserModel.getGoldNumber())

	    	require "script/ui/godweapon/godweaponfix/GodBatchFixLayer"
	   		GodBatchFixLayer.showLayer( _showItemId, fixType, _fixId, p_retData.arrAttrId, needGold, needItemNum )
	    end
	    require "script/ui/godweapon/godweaponfix/GodBatchFixService"
	    GodBatchFixService.batchWash(_showItemId, fixType, _fixId,nextCallBack)
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
	 	if(fixType == 1)then
	 		local num = nil
			if( math.floor(UserModel.getGoldNumber()/needGold) >= 10  ) then  
				num = 10
			else
				num = math.floor(UserModel.getGoldNumber()/needGold)
			end
	 		-- 金币
	 		tipArr.text = GetLocalizeStringBy("lic_1519",needGold*num, num)
	 	else
	 		-- 洗练石
	 		local num = nil
			if( math.floor(_myHaveNum/needItemNum) >= 10  ) then  
				num = 10
			else
				num = math.floor(_myHaveNum/needItemNum)
			end
	 		-- 金币
	 		tipArr.text = GetLocalizeStringBy("lic_1518",needItemNum*num, num)
	 	end

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
    		HeroModel.changeHeroGodWeaponConfirmedBy(_hid, _showItemId, _fixId, _toConfirmAttrId)
    		-- 把可替换的置nil
    		HeroModel.changeHeroGodWeaponToConfirmBy(_hid,_showItemId, _fixId, nil)
	    else
	    	-- 修改背包数据
	    	DataCache.changeGodWeaponConfirmedInBag( _showItemId, _fixId, _toConfirmAttrId )
	    	-- 把可替换的置nil
	    	DataCache.changeGodWeaponToConfirmInBag( _showItemId, _fixId, nil )
	    end

	    -- 修改当前已替换属性id
	    _confirmAttrId = _toConfirmAttrId
	    -- 刷新右边UI
	    refreshLeftUI()

	    -- 修改当前可替换属性id
	    _toConfirmAttrId = nil
	    -- 刷新右边UI
	    refreshRightUI()

	    -- 修改洗练石个数
	    _myHaveNum = ItemUtil.getCacheItemNumBy(_normalTid)
	    -- 刷新个数
	    _haveNumFont:setString("X " .. _myHaveNum )
    end
    -- 发送请求
    GodWeaponFixService.replace(_showItemId,_fixId,nextCallFun)
end

--[[
	@des 	:替换按钮回调
--]]
function changeMenuItemCallback( tag, sender ) 
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    -- 如果替换属性为空return
    if(_toConfirmAttrId == nil)then 
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1491"))
    	return
    end

    -- 当前没有拥有属性的情况下 直接替换
    if(_confirmAttrId == nil)then
    	replaceServiceCallback()
   		return
    end

    -- 当前已拥有属性
   	local confirmAttrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById( _confirmAttrId )
   	local confirmAttrColor = GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, _fixId, _confirmAttrId )
   	-- 可替换属性
   	local toConfirmAttrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById( _toConfirmAttrId )
   	local toConfirmAttrColor = GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, _fixId, _toConfirmAttrId )

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
	@des 	:洗练网络请求回调
--]]
function washServiceCallback()
    local argType = nil
    local needGold = 0
    local needItemNum = 0
    if(_curRadioType == _goldTag)then
    	-- 金币洗练
    	argType = 1
    	needGold = _goldCostNum
    	needItemNum = _goldNeedNum
    else
    	-- 普通洗练
    	argType = 0
    	needGold = 0
    	needItemNum = _normalNeedNum
    end

    -- 洗练石个数不够
    if( _myHaveNum < needItemNum )then  
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1481"))
		return
    end
    -- 金币不足
	if(UserModel.getGoldNumber() < needGold ) then  
		require "script/ui/tip/LackGoldTip"    
		LackGoldTip.showTip()
		return
	end

    local nextCallFun = function ( p_retId )
    	if(_isOnHero == true)then 
    		-- 修改英雄身上的数据
    		HeroModel.changeHeroGodWeaponToConfirmBy(_hid,_showItemId, _fixId, p_retId)
	    else
	    	-- 修改背包数据
	    	DataCache.changeGodWeaponToConfirmInBag( _showItemId, _fixId, p_retId )
	    end

	    -- 扣除金币
	    UserModel.addGoldNumber(-needGold)
	
	    -- 修改当前可替换属性id
	    _toConfirmAttrId = p_retId
	    -- 刷新右边UI
	    refreshRightUI()

	    -- 修改洗练石个数
	    _myHaveNum = _myHaveNum - needItemNum
	    -- 刷新个数
	    _haveNumFont:setString("X " .. _myHaveNum )
	    -- 刷新金币数量
	    _myHaveGoldNumFont:setString(UserModel.getGoldNumber())
    end
    
    -- 发送强求
    GodWeaponFixService.wash(_showItemId,argType,_fixId,nextCallFun)
end

--[[
	@des 	:洗练按钮回调
--]]
function fixMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    -- 当前是否是高品质属性
   	local isGood = GodWeaponFixData.getGodWeapinFixAttrIsGood( _showItemId, _fixId, _toConfirmAttrId )

   	if(isGood == false)then
   		-- 不是高品质 不做提示直接洗练
		washServiceCallback()
		return
   	end

   	-- 是高品质属性 弹二次确认
   	local curAttrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById( _toConfirmAttrId )
   	local curAttrColor = GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, _fixId, _toConfirmAttrId )
    -- 确定洗练回调
	local yesBuyCallBack = function ( ... )
		-- 发送洗练请求
		washServiceCallback()
	end

    -- 当前属性为高品质属性 XXX 8星，您确定要继续洗练？
    local textInfo = {
     		width = 450, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        linespace = 10, -- 行间距
	        elements =
	        {	
	        	{
	            	type = "CCRenderLabel", 
	            	text = curAttrInfo.name,
	            	color = curAttrColor
	        	},
	        }
	 	}
 	local tipNode = GetLocalizeLabelSpriteBy_2("lic_1489", textInfo)
 	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,360))
end

--[[
	@des 	:选择洗练按钮回调 普通 or 金币
--]]
function radioCallback( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    itemBtn:selected()
    itemBtn:setEnabled(false)
	if(itemBtn ~= _curRadioMenuItem) then
		_curRadioMenuItem:unselected()
		_curRadioMenuItem:setEnabled(true)
		_curRadioMenuItem = itemBtn
		_curRadioType = tag

		print("_curRadioType == ",_curRadioType)
	end

end

----------------------------------------------------------------------- 创建UI -------------------------------------------------------------------------

--[[
	@des 	:刷新右边UI
--]]
function refreshRightUI()
	if(_rightSprite ~= nil)then
		_rightSprite:removeFromParentAndCleanup(true)
		_rightSprite = nil
	end
	-- 创建右边
	_rightSprite = createAttrUI(_toConfirmAttrId, _rightType)
	_rightSprite:setAnchorPoint(ccp(0.5,0.5))
	_rightSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.75,_bgLayer:getContentSize().height*0.36))
	_bgLayer:addChild(_rightSprite)
	_rightSprite:setScale(g_fElementScaleRatio)
end

--[[
	@des 	:刷新左边UI
--]]
function refreshLeftUI()
	if(_leftSprite ~= nil)then
		_leftSprite:removeFromParentAndCleanup(true)
		_leftSprite = nil
	end
	-- 创建左边
	_leftSprite = createAttrUI(_confirmAttrId, _leftType)
	_leftSprite:setAnchorPoint(ccp(0.5,0.5))
	_leftSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.25,_bgLayer:getContentSize().height*0.36))
	_bgLayer:addChild(_leftSprite)
	_leftSprite:setScale(g_fElementScaleRatio)
end

--[[
	@des 	:创建属性框UI
	@param 	:p_attrId:洗练属性id， p_type:左边还是右边标识
	@return :sprite
--]]
function createAttrUI(p_attrId, p_type)
	local retSprite = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	retSprite:setContentSize(CCSizeMake(254, 215))

	-- 属性id不为空
	if(p_attrId ~= nil)then
		print("p_attrId",p_attrId)
		-- 属性数据
		local attrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(p_attrId)
		local attrColor =  GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, _fixId, p_attrId )
		-- 属性名字
		local attrNameFont = CCRenderLabel:create(attrInfo.name,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameFont:setColor(attrColor)
		attrNameFont:setAnchorPoint(ccp(0,0.5))
		attrNameFont:setPosition(ccp(35,retSprite:getContentSize().height-38))
		retSprite:addChild(attrNameFont)

		-- 星数
		local starFont = CCRenderLabel:create(attrInfo.star,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		starFont:setColor(attrColor)
		starFont:setAnchorPoint(ccp(0,0.5))
		starFont:setPosition(ccp(180,retSprite:getContentSize().height-38))
		retSprite:addChild(starFont)
		-- 星星sp
		local starSprite = CCSprite:create("images/formation/star.png")
		starSprite:setAnchorPoint(ccp(0,0.5))
		starSprite:setPosition(ccp(starFont:getPositionX()+starFont:getContentSize().width,starFont:getPositionY()))
		retSprite:addChild(starSprite)

		-- 描述
	    local textInfo = {
	     		width = 200, -- 宽度
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
	 	desFont:setPosition(ccp(35,retSprite:getContentSize().height-62))
	 	retSprite:addChild(desFont)
	end

	-- 两处不一样的UI
	if(p_type == _leftType)then 
		-- 左边 层图标
		local iconArr = {"lv.png","lan.png","zi.png","cheng.png","hong.png"} -- 层图标
		local iconSprite = CCSprite:create( "images/god_weapon/fix/" .. iconArr[_fixId] ) 
		iconSprite:setAnchorPoint(ccp(0.5,0))
		iconSprite:setPosition(ccp(55,retSprite:getContentSize().height+3))
		retSprite:addChild(iconSprite)
		-- 标题
		local titleArr = {GetLocalizeStringBy("lic_1457"),GetLocalizeStringBy("lic_1458"),GetLocalizeStringBy("lic_1459"),GetLocalizeStringBy("lic_1460"),GetLocalizeStringBy("llp_515")}
		local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1456",titleArr[_fixId]) ,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		titleFont:setColor(ccc3(0xff,0xf6,0x00))
		titleFont:setAnchorPoint(ccp(0.5,0))
		titleFont:setPosition(ccp(iconSprite:getContentSize().width*0.5,0))
		iconSprite:addChild(titleFont)
		-- 提示
		if(p_attrId == nil)then
			local tipFont1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1492") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			tipFont1:setColor(ccc3(0xff,0xff,0xff))
			tipFont1:setAnchorPoint(ccp(0.5,0.5))
			tipFont1:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height*0.6))
			retSprite:addChild(tipFont1)
		end

		-- 当前层最高可洗练XX星
		local maxStar = GodWeaponFixData.getGodWeapinFixMaxStar(nil, _showItemId, _fixId )
	    local textInfo = {
	     		width = 254, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        labelDefaultFont = g_sFontName,      -- 默认字体
		        labelDefaultSize = 18,          -- 默认字体大小
		        labelDefaultColor = ccc3(0xff, 0xff, 0xff),
		        linespace = 2, -- 行间距
		        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
		        elements =
		        {	
		        	{
		            	type = "CCRenderLabel", 
		            	text = maxStar,
		            	color = ccc3(0xff, 0x84, 0x00)
		        	},
		        	{
		        		type = "CCSprite",
	                    image = "images/formation/star.png"
		        	}
		        }
		 	}
	 	local tipNode = GetLocalizeLabelSpriteBy_2("lic_1493", textInfo)
 		tipNode:setAnchorPoint(ccp(0.5,0.5))
		tipNode:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height*0.11))
		retSprite:addChild(tipNode)
	elseif(p_type == _rightType)then 
		-- 右边 洗练属性
		local titleSp = CCSprite:create("images/common/red_2.png")
		titleSp:setAnchorPoint(ccp(0.5,0.5))
		titleSp:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height))
		retSprite:addChild(titleSp)
		-- 标题
		local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1471") ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		titleFont:setColor(ccc3(0xff,0xf6,0x00))
		titleFont:setAnchorPoint(ccp(0.5,0.5))
		titleFont:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
		titleSp:addChild(titleFont)
		-- 提示
		if(p_attrId == nil)then
			local tipFont1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1478") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			tipFont1:setColor(ccc3(0xff,0xff,0xff))
			tipFont1:setAnchorPoint(ccp(0.5,0.5))
			tipFont1:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height*0.6))
			retSprite:addChild(tipFont1)
			local tipFont2 = CCRenderLabel:create(GetLocalizeStringBy("lic_1479") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			tipFont2:setColor(ccc3(0xff,0xff,0xff))
			tipFont2:setAnchorPoint(ccp(0.5,0.5))
			tipFont2:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height*0.5))
			retSprite:addChild(tipFont2)
		end
	else
		print("erro")
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

	-- 可洗练属性按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-2)
    _bgLayer:addChild(menuBar)

	-- 创建可洗练属性按钮
	local showMenuItem = CCMenuItemImage:create("images/god_weapon/fix/show_n.png","images/god_weapon/fix/show_h.png")
	showMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	showMenuItem:setPosition(ccp( 60*g_fElementScaleRatio, _bgLayer:getContentSize().height*0.7 ))
	menuBar:addChild(showMenuItem)
	showMenuItem:registerScriptTapHandler(showMenuItemCallback)
	showMenuItem:setScale(g_fElementScaleRatio)

end

--[[
	@des 	:创建中部UI
--]]
function createMiddleUI()
	-- 创建左边
	_leftSprite = createAttrUI(_confirmAttrId, _leftType)
	_leftSprite:setAnchorPoint(ccp(0.5,0.5))
	_leftSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.25,_bgLayer:getContentSize().height*0.36))
	_bgLayer:addChild(_leftSprite)
	_leftSprite:setScale(g_fElementScaleRatio)

	-- 创建右边
	_rightSprite = createAttrUI(_toConfirmAttrId, _rightType)
	_rightSprite:setAnchorPoint(ccp(0.5,0.5))
	_rightSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.75,_bgLayer:getContentSize().height*0.36))
	_bgLayer:addChild(_rightSprite)
	_rightSprite:setScale(g_fElementScaleRatio)

	-- 两个箭头
	local arrows1 = CCSprite:create("images/common/right.png")
    arrows1:setAnchorPoint(ccp(0.5, 0.5))
    arrows1:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height*0.41))
    _bgLayer:addChild(arrows1)
    arrows1:setRotation(180)
    arrows1:setScale(g_fElementScaleRatio)

    local arrows2 = CCSprite:create("images/common/right.png")
    arrows2:setAnchorPoint(ccp(0.5, 0.5))
    arrows2:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height*0.31))
    _bgLayer:addChild(arrows2)
    arrows2:setRotation(180)
    arrows2:setScale(g_fElementScaleRatio)
end

--[[
	@des 	:创建底部UI
--]]
function createBottomUI()
	local bottomBg = CCScale9Sprite:create("images/forge/tip_bg.png")
	bottomBg:setAnchorPoint(ccp(0.5,0))
	bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,60*g_fElementScaleRatio))
	_bgLayer:addChild(bottomBg)
	bottomBg:setScale(g_fElementScaleRatio)

	-- 三个按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-2)
    bottomBg:addChild(menuBar)

    -- 返回按钮
    local closeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(146, 73),GetLocalizeStringBy("lic_1472"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	closeMenuItem:setAnchorPoint(ccp(0.5 , 1))
    closeMenuItem:setPosition(ccp(bottomBg:getContentSize().width*0.08,5))
    closeMenuItem:registerScriptTapHandler(closeButtonCallback)
	menuBar:addChild(closeMenuItem)

	-- 替换按钮
    local changeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(146, 73),GetLocalizeStringBy("lic_1473"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	changeMenuItem:setAnchorPoint(ccp(0.5 , 1))
    changeMenuItem:setPosition(ccp(bottomBg:getContentSize().width*0.34,5))
    changeMenuItem:registerScriptTapHandler(changeMenuItemCallback)
	menuBar:addChild(changeMenuItem)

	-- 批量洗练按钮
    local batchMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(186, 73),GetLocalizeStringBy("lic_1514"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	batchMenuItem:setAnchorPoint(ccp(0.5 , 1))
    batchMenuItem:setPosition(ccp(bottomBg:getContentSize().width*0.63,5))
    batchMenuItem:registerScriptTapHandler(batchMenuItemCallback)
	menuBar:addChild(batchMenuItem)

	-- 洗练按钮
	local fixMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(146, 73),GetLocalizeStringBy("lic_1474"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	fixMenuItem:setAnchorPoint(ccp(0.5 , 1))
	fixMenuItem:setPosition(ccp(bottomBg:getContentSize().width*0.92,5))
    fixMenuItem:registerScriptTapHandler(fixMenuItemCallback)
	menuBar:addChild(fixMenuItem)

	-- 标题 洗练消耗
	local titleFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1475") ,g_sFontPangWa,28,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleFont:setColor(ccc3(0xff,0xf6,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(bottomBg:getContentSize().width*0.53,bottomBg:getContentSize().height-10))
	bottomBg:addChild(titleFont)

	-- 分界线
	local line = CCScale9Sprite:create("images/common/line_4.png")
	line:setAnchorPoint(ccp(0.5,0.5))
	line:setPosition(ccp(bottomBg:getContentSize().width*0.5,bottomBg:getContentSize().height*0.45))
	bottomBg:addChild(line)

	-- 普通洗练
	_normalMenuItem = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png","images/common/btn/radio_selected.png")
	_normalMenuItem:setAnchorPoint(ccp(0, 0.5))
	_normalMenuItem:setPosition(20, bottomBg:getContentSize().height * 0.65)
	menuBar:addChild(_normalMenuItem, 1, _normalTag)
	_normalMenuItem:registerScriptTapHandler(radioCallback)

	-- 普通洗练消耗文字
	local normalIcon = CCSprite:create("images/item/equipFixed/normal_fixed.png")
	normalIcon:setAnchorPoint(ccp(0,0.5))
	normalIcon:setPosition(ccp( _normalMenuItem:getPositionX()+_normalMenuItem:getContentSize().width+15,_normalMenuItem:getPositionY()))
	bottomBg:addChild(normalIcon)
	-- 普通花费
	local normalCostFont =  CCRenderLabel:create( GetLocalizeStringBy("lic_1476") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	normalCostFont:setColor(ccc3(0xff,0xff,0xff))
	normalCostFont:setAnchorPoint(ccp(0,0.5))
	normalCostFont:setPosition(ccp(normalIcon:getPositionX()+normalIcon:getContentSize().width+37,_normalMenuItem:getPositionY()))
	bottomBg:addChild(normalCostFont)
	-- 洗练石图标
	local normalIconSprite = ItemSprite.getItemBigSpriteById( _normalTid )
	normalIconSprite:setAnchorPoint(ccp(0,0.5))
	normalIconSprite:setPosition(ccp( normalCostFont:getPositionX()+normalCostFont:getContentSize().width,_normalMenuItem:getPositionY()))
	bottomBg:addChild(normalIconSprite)
	normalIconSprite:setScale(0.2)
	-- 消耗个数
	local normalNeedNumFont =  CCRenderLabel:create(_normalNeedNum ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	normalNeedNumFont:setColor(ccc3(0x00,0xe4,0xff))
	normalNeedNumFont:setAnchorPoint(ccp(0,0.5))
	normalNeedNumFont:setPosition(ccp(normalIconSprite:getPositionX()+normalIconSprite:getContentSize().width*normalIconSprite:getScale()+10,_normalMenuItem:getPositionY()))
	bottomBg:addChild(normalNeedNumFont)

	-- 金币洗练
	_goldMenuItem = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png","images/common/btn/radio_selected.png")
	_goldMenuItem:setAnchorPoint(ccp(0, 0.5))
	_goldMenuItem:setPosition(20, bottomBg:getContentSize().height * 0.25)
	menuBar:addChild(_goldMenuItem, 1, _goldTag)
	_goldMenuItem:registerScriptTapHandler(radioCallback)

	-- 金币洗练消耗文字
	local goldIcon = CCSprite:create("images/item/equipFixed/high_fixed.png")
	goldIcon:setAnchorPoint(ccp(0,0.5))
	goldIcon:setPosition(ccp( _goldMenuItem:getPositionX()+_goldMenuItem:getContentSize().width+15,_goldMenuItem:getPositionY()))
	bottomBg:addChild(goldIcon)
	-- 金币花费
	local goldCostFont =  CCRenderLabel:create( GetLocalizeStringBy("lic_1476") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	goldCostFont:setColor(ccc3(0xff,0xff,0xff))
	goldCostFont:setAnchorPoint(ccp(0,0.5))
	goldCostFont:setPosition(ccp(goldIcon:getPositionX()+goldIcon:getContentSize().width+37,_goldMenuItem:getPositionY()))
	bottomBg:addChild(goldCostFont)
	-- -- 洗练石图标
	-- local goldIconSprite = ItemSprite.getItemBigSpriteById( _goldTid )
	-- goldIconSprite:setAnchorPoint(ccp(0,0.5))
	-- goldIconSprite:setPosition(ccp( goldCostFont:getPositionX()+goldCostFont:getContentSize().width,_goldMenuItem:getPositionY()))
	-- bottomBg:addChild(goldIconSprite)
	-- goldIconSprite:setScale(0.2)
	-- -- 消耗个数
	-- local goldNeedNumFont =  CCRenderLabel:create(_goldNeedNum ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- goldNeedNumFont:setColor(ccc3(0x00,0xe4,0xff))
	-- goldNeedNumFont:setAnchorPoint(ccp(0,0.5))
	-- goldNeedNumFont:setPosition(ccp(goldIconSprite:getPositionX()+goldIconSprite:getContentSize().width*goldIconSprite:getScale()+10,_goldMenuItem:getPositionY()))
	-- bottomBg:addChild(goldNeedNumFont)
	-- 金币图标
	local goldSp = CCSprite:create("images/common/gold.png")
	goldSp:setAnchorPoint(ccp(0,0.5))
	goldSp:setPosition(ccp( goldCostFont:getPositionX()+goldCostFont:getContentSize().width,_goldMenuItem:getPositionY()))
	bottomBg:addChild(goldSp)
	-- 金币数量
	local goldCostNumFont =  CCRenderLabel:create(_goldCostNum ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	goldCostNumFont:setColor(ccc3(0xff,0xf6,0x00))
	goldCostNumFont:setAnchorPoint(ccp(0,0.5))
	goldCostNumFont:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width+10,_goldMenuItem:getPositionY()))
	bottomBg:addChild(goldCostNumFont)


	-- 默认选择普通洗练
	_curRadioMenuItem = _normalMenuItem
	_curRadioMenuItem:selected()
	_curRadioMenuItem:setEnabled(false)
	_curRadioType = _normalTag

	-- 拥有的洗练石个数
	local myHaveFont =  CCRenderLabel:create( GetLocalizeStringBy("lic_1477") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	myHaveFont:setColor(ccc3(0xff,0xff,0xff))
	myHaveFont:setAnchorPoint(ccp(0,0.5))
	myHaveFont:setPosition(ccp(400,bottomBg:getContentSize().height+10))
	bottomBg:addChild(myHaveFont)
	-- 洗练石图标
	local haveIconSprite = ItemSprite.getItemBigSpriteById( _normalTid )
	haveIconSprite:setAnchorPoint(ccp(0,0.5))
	haveIconSprite:setPosition(ccp( myHaveFont:getPositionX()+myHaveFont:getContentSize().width-15,myHaveFont:getPositionY()))
	bottomBg:addChild(haveIconSprite)
	haveIconSprite:setScale(0.15)
	-- 拥有个数
	_haveNumFont =  CCRenderLabel:create("X " .. _myHaveNum ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_haveNumFont:setColor(ccc3(0x00,0xff,0x18))
	_haveNumFont:setAnchorPoint(ccp(0,0.5))
	_haveNumFont:setPosition(ccp(haveIconSprite:getPositionX()+haveIconSprite:getContentSize().width*haveIconSprite:getScale(),myHaveFont:getPositionY()))
	bottomBg:addChild(_haveNumFont)

	-- 拥有金币数量
	local myGoldFont =  CCRenderLabel:create( GetLocalizeStringBy("lic_1477") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	myGoldFont:setColor(ccc3(0xff,0xff,0xff))
	myGoldFont:setAnchorPoint(ccp(0,0.5))
	myGoldFont:setPosition(ccp(10,bottomBg:getContentSize().height+10))
	bottomBg:addChild(myGoldFont)
	-- 金币图标
	local goldSprite = CCSprite:create("images/common/gold.png")
	goldSprite:setAnchorPoint(ccp(0,0.5))
	goldSprite:setPosition(ccp( myGoldFont:getPositionX()+myGoldFont:getContentSize().width,myGoldFont:getPositionY()))
	bottomBg:addChild(goldSprite)
	-- 拥有个数
	_myHaveGoldNumFont =  CCRenderLabel:create( UserModel.getGoldNumber(),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_myHaveGoldNumFont:setColor(ccc3(0xff,0xe2,0x44))
	_myHaveGoldNumFont:setAnchorPoint(ccp(0,0.5))
	_myHaveGoldNumFont:setPosition(ccp(goldSprite:getPositionX()+goldSprite:getContentSize().width,myGoldFont:getPositionY()))
	bottomBg:addChild(_myHaveGoldNumFont)
end

--[[
	@des 	:创建神兵洗练属性界面
	@param 	:p_item_id:洗练神兵itemid， p_fixId:洗练第几层， p_mark:界面跳转记忆
	@return :
--]]
function createLayer( p_item_id,  p_fixId, p_mark )
	-- 初始化变量
	init()

	-- 接收参数
	_showItemId = tonumber(p_item_id)
	-- 洗练第几层属性
	_fixId = p_fixId
	-- 跳转记忆
	_showMark = p_mark
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
    -- 创建中间UI
    createMiddleUI()
    -- 创建下部分UI
    createBottomUI()

    -- 如果有批量属性未替换显示批量属性界面
    if(not table.isEmpty(_showItemInfo.va_item_text.btc) )then 
    	if( not table.isEmpty(_showItemInfo.va_item_text.btc[tostring(_fixId)]) )then
    		require "script/ui/godweapon/godweaponfix/GodBatchFixLayer"
   			GodBatchFixLayer.showLayer( _showItemId, 0, _fixId, _showItemInfo.va_item_text.btc[tostring(_fixId)], 0, _normalNeedNum )
    	end
    end

    return _bgLayer
end

--[[
	@des 	:显示神兵洗练属性界面
	@param 	:p_item_id:洗练神兵itemid， p_fixId:洗练第几层， p_mark:界面跳转记忆
	@return :
--]]
function showLayer( p_item_id, p_fixId, p_mark  )
	local layer = createLayer( p_item_id, p_fixId, p_mark )
	MainScene.changeLayer(layer, "GodWeaponFixAttrLayer")
end






























