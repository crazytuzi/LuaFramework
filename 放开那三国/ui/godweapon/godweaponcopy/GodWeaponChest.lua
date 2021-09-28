-- Filename：	GodWeaponChest.lua
-- Author：		LLP
-- Date：		2014-12-12
-- Purpose：		显示神兵宝藏界面

module("GodWeaponChest", package.seeall)
require "script/ui/godweapon/godweaponcopy/RewardMenuSprite"
require "script/ui/item/ItemSprite"
require "db/DB_Overcome"
require "script/ui/hero/HeroPublicLua"

local _bgLayer
local _goldCost 	= 0
local _canBuy 		= true
local _buyNum 		= 0
local _godNormalEffect 	= nil
local _godOpenEffect 	= nil
local _manyBuy 			= false
local _isButtonDisable 	= false

function init()
	_bgLayer 			= nil
	_goldCost 			= 0
	_buyNum 			= 0
	_godNormalEffect 	= nil
	_godOpenEffect 		= nil
	_isButtonDisable 	= false
	_canBuy 			= true
	_manyBuy 			= false
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then

    else

	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--发送获取奖励命令
local function sendCommond()
	--获取当前在第几关
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	--获取奖励信息命令参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
	args:addObject(CCInteger:create(1))
	GodWeaponCopyService.rewardInfo(openGodBoxEffect,args)
end

--点击放弃购买之后回调mark
function afterLeaveChest( ... )
	-- body
	GodWeaponCopyData.setGoldBoxOver()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil


	if( GodWeaponCopyData.justRemainOnce() == true and GodWeaponCopyData.isHavePass() == false )then
		-- 如果其他任务都已经完成所有
		GodWeaponCopyMainLayer.nextSenceEffect()
	else
		GodWeaponCopyMainLayer.refreshFunc()
	end
end

--发送放弃购买宝箱命令
local function leaveChestCommon( ... )
	-- body
	--获取当前在第几关
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	--获取奖励信息命令参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
	GodWeaponCopyService.leaveLuxuryChest(afterLeaveChest,args)
end

--获取奖励信息
function getRewardInfo()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
	GodWeaponCopyData.setluxuryNum(_copyInfo.luxurybox_num+1)
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	local costData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
	local tab = string.split(costData.openCost,",")
	for k,v in pairs(tab) do
		local tem = string.split(v,"|")
		if(tonumber(_copyInfo.luxurybox_num)<=tonumber(tem[1]))then
			_goldCost = tonumber(tem[2])
			break
		else

		end
	end
	ShowRewardLayer.showLayer()
end
function tipSure()
	-- body
	_manyBuy=true
	if(ItemUtil.isGodWeaponBagFull(true,GodWeaponChest.afterLeaveChest) == true)then
		-- _bgLayer:removeFromParentAndCleanup(true)
		-- _bgLayer = nil
		return
	end

	if(ItemUtil.isGodWeaponFragBagFull(true,GodWeaponChest.afterLeaveChest) == true)then
		-- _bgLayer:removeFromParentAndCleanup(true)
		-- _bgLayer = nil
		return
	end
	if(_canBuy)then
        require "script/utils/SelectNumDialog"
        local dialog = SelectNumDialog:create()
        dialog:setTitle(GetLocalizeStringBy("llp_217"))
        dialog:show(-1000, 800)

        local contentMsgInfo = {}
        contentMsgInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
        contentMsgInfo.labelDefaultSize = 25
        contentMsgInfo.defaultType = "CCRenderLabel"
        contentMsgInfo.lineAlignment = 1
        contentMsgInfo.labelDefaultFont = g_sFontName
        contentMsgInfo.elements = {
            {
                text = GetLocalizeStringBy("llp_218"),
                color = itemColor,
                font = g_sFontPangWa,
                size = 30,
            }
        }
        contentMsgNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("llp_220"), contentMsgInfo)
        contentMsgNode:setAnchorPoint(ccp(0.5,0.5))
        contentMsgNode:setPosition(ccpsprite(0.5, 0.74, dialog))
        dialog:addChild(contentMsgNode)
        local costData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
		local tab = string.split(costData.openCost,",")
        local lastTem = string.split(tab[table.count(tab)],"|")
		local lastNum = tonumber(lastTem[1])-tonumber(_copyInfo.luxurybox_num)
        dialog:setLimitNum(lastNum)
        local childNodes = {}
        childNodes[1] = CCRenderLabel:create(GetLocalizeStringBy("llp_219"),g_sFontName, 25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        childNodes[1]:setColor(ccc3(0xff, 0xf6, 0x00))

        childNodes[2] = CCSprite:create("images/common/gold.png")

        _copyInfo = GodWeaponCopyData.getCopyInfo()
        local costData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
		local tab = string.split(costData.openCost,",")
		local costNum = 0
		for i=tonumber(_copyInfo.luxurybox_num+1),tonumber(_copyInfo.luxurybox_num)+dialog:getNum() do
			for k,v in pairs(tab) do
				local tem = string.split(v,"|")
				if((i)<=tonumber(tem[1]))then
					costNum = costNum+tem[2]
					break
				end
			end
		end
        childNodes[3] = CCRenderLabel:create(tostring(costNum),g_sFontName, 30, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        childNodes[3]:setColor(ccc3(0xff, 0xf6, 0x00))

        contentCostNode = BaseUI.createHorizontalNode(childNodes)
        contentCostNode:setAnchorPoint(ccp(0.5,0.5))
        contentCostNode:setPosition(ccpsprite(0.5, 0.3, dialog))
        dialog:addChild(contentCostNode)


        dialog:registerOkCallback(function ()
            -- 背包满了
            if(ItemUtil.isBagFull() == true )then
                return
            end
            --获取当前在第几关
            _buyNum = dialog:getNum()
			_copyInfo = GodWeaponCopyData.getCopyInfo()
			--获取奖励信息命令参数
			local costData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
			local tab = string.split(costData.openCost,",")
			local cost = 0
			for i=tonumber(_copyInfo.luxurybox_num+1),tonumber(_copyInfo.luxurybox_num)+dialog:getNum() do
				for k,v in pairs(tab) do
					local tem = string.split(v,"|")
					if((i)<=tonumber(tem[1]))then
						cost = cost+tem[2]
						break
					end
				end
			end
			_goldCost = cost

			local args = CCArray:create()
			args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
			args:addObject(CCInteger:create(1))
			args:addObject(CCInteger:create(dialog:getNum()))
			GodWeaponCopyService.rewardInfo(openGodBoxEffect,args)
        end)
        dialog:registerChangeCallback(function ( pNum )
        	local costData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
			local tab = string.split(costData.openCost,",")
			local cost = 0
			for i=tonumber(_copyInfo.luxurybox_num+1),tonumber(_copyInfo.luxurybox_num)+dialog:getNum() do
				for k,v in pairs(tab) do
					local tem = string.split(v,"|")
					if((i)<=tonumber(tem[1]))then
						cost = cost+tem[2]
						break
					end
				end
			end
			-- _goldCost = cost
            childNodes[3]:setString(tostring(cost))
        end)
		-- local goldNum = UserModel.getGoldNumber()
		-- if(_goldCost<=goldNum)then
		-- 	if(_isButtonDisable == true)then
		-- 		-- 防止重复点击
		-- 		return
		-- 	end
		-- 	_isButtonDisable = true
		-- 	sendCommond()
		-- 	require "script/audio/AudioUtil"
		-- 	AudioUtil.playEffect("audio/effect/guanbi.mp3")

		-- else
		-- 	require "script/ui/tip/LackGoldTip"
		-- 	LackGoldTip.showTip()
		-- end

	else
		AnimationTip.showTip(GetLocalizeStringBy("llp_144"))
	end
end

function makeSure()
	--背包判断
	_manyBuy = false
	if(ItemUtil.isGodWeaponBagFull(true,GodWeaponChest.afterLeaveChest) == true)then
		-- _bgLayer:removeFromParentAndCleanup(true)
		-- _bgLayer = nil
		return
	end

	if(ItemUtil.isGodWeaponFragBagFull(true,GodWeaponChest.afterLeaveChest) == true)then
		-- _bgLayer:removeFromParentAndCleanup(true)
		-- _bgLayer = nil
		return
	end
	if(_canBuy)then
		local goldNum = UserModel.getGoldNumber()
		if(_goldCost<=goldNum)then
			if(_isButtonDisable == true)then
				-- 防止重复点击
				return
			end
			_isButtonDisable = true
			sendCommond()
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/guanbi.mp3")

		else
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
		end
	else
		AnimationTip.showTip(GetLocalizeStringBy("llp_144"))
	end
end

function sureAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(not table.isEmpty(_copyInfo["va_pass"]["chestShow"]) and tonumber(_copyInfo["va_pass"]["chestShow"]["goldChest"])==1 and not table.isEmpty(_copyInfo["va_pass"]["buffShow"]))then
		if( GodWeaponCopyData.justRemainOnce() == true )then
			-- 如果其他任务都已经完成所有
			GodWeaponCopyMainLayer.nextSenceEffect()
		else
			GodWeaponCopyMainLayer.refreshFunc()
		end

	elseif(not table.isEmpty(_copyInfo["va_pass"]["chestShow"]) and tonumber(_copyInfo["va_pass"]["chestShow"]["goldChest"])==0)then
		-- 设置普通宝箱已经完成
		GodWeaponCopyData.setNormalBoxOver()
		GodWeaponCopyData.setluxuryNum(_copyInfo.luxurybox_num+_buyNum)
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
		GodWeaponChest.showLayer()
	end
end

-- 打开宝箱
function openGodBoxEffect( )
	-- body
	local itemsTable={}
	UserModel.addGoldNumber(-tonumber(_goldCost))
	if(_manyBuy==true)then
		local _rewardInfo = GodWeaponCopyData.getRewardInfo()
		local rewardTable = {}
		for k,v in pairs(_rewardInfo)do
			rewardData = DB_Overcome_chest.getDataById(tonumber(v))
			table.insert(rewardTable,rewardData.RewardItem)
		end

		for i=1,table.count(rewardTable) do
			local rewardArrySp = ItemUtil.getItemsDataByStr(rewardTable[i])
			table.insert(itemsTable,rewardArrySp[1])
		end
		ReceiveReward.showRewardWindow( itemsTable, sureAction, 1000,-1000 )

		--增加动画监听
	    local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerChangedHandler(function( frameIndex,xmlSprite )
        	if(_godNormalEffect ~= nil)then
		    	_godNormalEffect:removeFromParentAndCleanup(true)
				_godNormalEffect = nil

			end
	    end)

	    _godNormalEffect:setDelegate(delegate)
		return
	end
	--增加动画监听
    local delegate_n = BTAnimationEventDelegate:create()
    delegate_n:registerLayerEndedHandler(
    	function ( ... )

    		performCallfunc(function ( ... )
    			AudioUtil.playEffect("audio/effect/hualidakai.mp3")
    		end, 0.5)

			local godOpenEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/hualidakai/hualidakai"), 1,CCString:create(""));
			godOpenEffect:setPosition(g_winSize.width*0.5+30, g_winSize.height*0.5+50)
			godOpenEffect:setScale(g_fElementScaleRatio)
			_bgLayer:addChild(godOpenEffect)

			--增加动画监听
		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(
		    	function ( ... )
					godOpenEffect:removeFromParentAndCleanup(true)
					godOpenEffect = nil
					getRewardInfo()
				end
		    )
	        delegate:registerLayerChangedHandler(function( frameIndex,xmlSprite )
	        	if(_godNormalEffect ~= nil)then
			    	_godNormalEffect:removeFromParentAndCleanup(true)
					_godNormalEffect = nil

				end
		    end)
		    godOpenEffect:setDelegate(delegate)
		end
    )
    _godNormalEffect:setDelegate(delegate_n)

end

-- 神兵宝箱
function addGodBoxEffect()
	_godNormalEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/hualichangtai/hualichangtai"), 1,CCString:create(""));
	_godNormalEffect:setPosition(g_winSize.width*0.5, g_winSize.height*0.5)
	_godNormalEffect:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(_godNormalEffect)
end

--放弃购买金币宝箱
function leaveAction()
	leaveChestCommon()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
end

function createBackGround()
	_copyInfo = GodWeaponCopyData.getCopyInfo()
    --神兵宝藏Sprite
	local addbuffSprite = CCSprite:create("images/godweaponcopy/chest.png")
	addbuffSprite:setAnchorPoint(ccp(0.5,0.5))
	--神兵宝藏Bg
	local fullRect = CCRectMake(0,0,209,49)
	local insetRect = CCRectMake(86,14,45,20)
	local grayBg = CCScale9Sprite:create("images/godweaponcopy/choosegray.png",fullRect, insetRect)
	grayBg:setPreferredSize(CCSizeMake(addbuffSprite:getContentSize().width+100,addbuffSprite:getContentSize().height+50))
	grayBg:setAnchorPoint(ccp(0.5,1))
	grayBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.85))
	_bgLayer:addChild(grayBg)
	grayBg:setScale(g_fElementScaleRatio)
	grayBg:addChild(addbuffSprite)
	addbuffSprite:setPosition(ccp(grayBg:getContentSize().width*0.5,grayBg:getContentSize().height*0.5))

	local data = {}

	local bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
	bottomBg:setScale(g_fElementScaleRatio)
	local bgSprite = CCSprite:create()
	local rewardItem = nil
	local costArry = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
	local tab = string.split(costArry.goldShow,",")
	local index = 1
	for k,v in pairs(tab) do
		local tem = string.split(v,"|")
		data[index] = tem[2]
		index = index+1
	end

	for i=1,table.count(tab) do

		rewardItem = ItemSprite.getItemSpriteById(tonumber(data[i]),nil,nil,nil,-551)
		local itemData = ItemUtil.getItemById(data[i])
		--下方奖励名称
		local rewardItemNameLabel = CCLabelTTF:create(itemData.name,g_sFontName,21)
		rewardItemNameLabel:setAnchorPoint(ccp(0.5,1))
		rewardItemNameLabel:setPosition(ccp(rewardItem:getContentSize().width*0.5,-10))
		rewardItem:addChild(rewardItemNameLabel,1,i)
		local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
		rewardItemNameLabel:setColor(nameColor)
		bgSprite:addChild(rewardItem,1,i)
	end

	-- 神兵宝箱特效
	addGodBoxEffect()

	for i=1,table.count(tab) do
		bgSprite:getChildByTag(i):setAnchorPoint(ccp(0.5,0))
		bgSprite:getChildByTag(i):setPosition(ccp(bgSprite:getChildByTag(i):getContentSize().width*((i-1)*1.5 + 0.5),bgSprite:getChildByTag(i):getChildByTag(i):getContentSize().height+10))
	end

	local spriteWidth = bgSprite:getChildByTag(table.count(tab)):getPositionX()-bgSprite:getChildByTag(1):getPositionX()+bgSprite:getChildByTag(table.count(tab)):getContentSize().width
	local labelWidth = bgSprite:getChildByTag(table.count(tab)):getChildByTag(table.count(tab)):getPositionX()-bgSprite:getChildByTag(1):getChildByTag(1):getPositionX()+bgSprite:getChildByTag(1):getChildByTag(1):getContentSize().width*0.5+bgSprite:getChildByTag(table.count(tab)):getChildByTag(table.count(tab)):getContentSize().width*0.5
	-- else
	if(spriteWidth>labelWidth)then
		bottomBg:setContentSize(CCSizeMake(spriteWidth+60,bgSprite:getChildByTag(table.count(tab)):getContentSize().height+10+bgSprite:getChildByTag(table.count(tab)):getChildByTag(table.count(tab)):getContentSize().height+60))
	else
		bottomBg:setContentSize(CCSizeMake(labelWidth+60,bgSprite:getChildByTag(table.count(tab)):getContentSize().height+10+bgSprite:getChildByTag(table.count(tab)):getChildByTag(table.count(tab)):getContentSize().height+60))
	end
	-- end
	if(spriteWidth>labelWidth)then
		bgSprite:setContentSize(CCSizeMake(spriteWidth,bgSprite:getChildByTag(table.count(tab)):getContentSize().height+10+bgSprite:getChildByTag(table.count(tab)):getChildByTag(table.count(tab)):getContentSize().height))
	else
		bgSprite:setContentSize(CCSizeMake(labelWidth,bgSprite:getChildByTag(table.count(tab)):getContentSize().height+10+bgSprite:getChildByTag(table.count(tab)):getChildByTag(table.count(tab)):getContentSize().height))
	end

	bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(bottomBg:getContentSize().width*0.5, bottomBg:getContentSize().height*0.5)

    bottomBg:addChild(bgSprite)
    bottomBg:setAnchorPoint(ccp(0.5,0.5))
    bottomBg:setPosition(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.25)


    _bgLayer:addChild(bottomBg)
 --    local pString="1|10,3|20,5|40,7|80,8|120"
	-- local tab = string.split(pString,",")
	-- local cost = 0
	-- for i=1,4 do
	-- 	for k,v in pairs(tab) do
	-- 		local tem = string.split(v,"|")
	-- 		if((i)<=tonumber(tem[1]))then
	-- 			cost = cost+tem[2]
	-- 			print("tem[2]",tem[2])
	-- 			break
	-- 		end
	-- 	end
	-- end
	-- print("cost====",cost)

	local costData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
	local tab = string.split(costData.openCost,",")
	for k,v in pairs(tab) do
		local tem = string.split(v,"|")
		if(tonumber(_copyInfo.luxurybox_num+1)<=tonumber(tem[1]))then
			_goldCost = tonumber(tem[2])
			break
		else
		end
	end
	local lastTem = string.split(tab[table.count(tab)],"|")
	local lastNum = tonumber(lastTem[1])-tonumber(_copyInfo.luxurybox_num)
	if(tonumber(_copyInfo.luxurybox_num+1)<=tonumber(lastTem[1]))then
	else
		_canBuy = false
	end
	-- AnimationTip.showTip("本次你会花费".._goldCost.."金")

	-- 关闭按钮
    local menu = CCMenu:create()
    -- menu:setScale(g_fElementScaleRatio)
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    _bgLayer:addChild(menu,99)

    local ccBtnSure = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("llp_129"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))
    ccBtnSure:setScale(g_fElementScaleRatio)
    ccBtnSure:setPosition(ccp(_bgLayer:getContentSize().width*0.2,bottomBg:getPositionY()-bottomBg:getContentSize().height*0.5*g_fElementScaleRatio-10))
    ccBtnSure:setAnchorPoint(ccp(0.5,1))
    ccBtnSure:registerScriptTapHandler(leaveAction)
    menu:addChild(ccBtnSure)
    -- ccBtnSure:setScale(g_fElementScaleRatio)

    local force_occupy_btn_info = {
        normal = "images/star/intimate/btn_blue_n.png",
        selected = "images/star/intimate/btn_blue_h.png",
        size = CCSizeMake(200, 64),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("llp_130"),
        text_size = 28,
        number = tostring(_goldCost)
    }

    local ccBtnOpen = LuaCCSprite.createNumberMenuItem(force_occupy_btn_info)
    ccBtnOpen:setScale(g_fElementScaleRatio)
    ccBtnOpen:setPosition(ccp(_bgLayer:getContentSize().width*0.5,bottomBg:getPositionY()-bottomBg:getContentSize().height*0.5*g_fElementScaleRatio-10))
    ccBtnOpen:setAnchorPoint(ccp(0.5,1))
    ccBtnOpen:registerScriptTapHandler(makeSure)
    menu:addChild(ccBtnOpen)

    local ccBtnManyOpen = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("llp_216"),ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    ccBtnManyOpen:setScale(g_fElementScaleRatio)
    ccBtnManyOpen:setPosition(ccp(_bgLayer:getContentSize().width*0.8,bottomBg:getPositionY()-bottomBg:getContentSize().height*0.5*g_fElementScaleRatio-10))
    ccBtnManyOpen:setAnchorPoint(ccp(0.5,1))
    ccBtnManyOpen:registerScriptTapHandler(tipSure)
    menu:addChild(ccBtnManyOpen)
    -- ccBtnOpen:setScale(g_fElementScaleRatio)

    local lastTimeNameLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_152",lastNum),g_sFontName,22,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    lastTimeNameLabel:setColor(ccc3(0x00,0xff,0x18))
    lastTimeNameLabel:setScale(g_fElementScaleRatio)
    lastTimeNameLabel:setAnchorPoint(ccp(0.5,1))
    lastTimeNameLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.7,bottomBg:getPositionY()-bottomBg:getContentSize().height*0.5*g_fElementScaleRatio-15-ccBtnOpen:getContentSize().height*g_fElementScaleRatio))
    _bgLayer:addChild(lastTimeNameLabel,10)

    local richInfo = {}
    richInfo.width = bottomBg:getContentSize().width
    richInfo.alignment = 2
    richInfo.labelDefaultFont = g_sFontName
    richInfo.labelDefaultSize = 23
    richInfo.elements =
    {
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_125"),
            color = ccc3(0xff,0xff,0xff)
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_126"),
            color = ccc3(0xff,0x6c,0x00)
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_127"),
            color = ccc3(0xe4,0x00,0xff)
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_128"),
            color = ccc3(0xff,0xff,0xff)
        }
    }
    require "script/libs/LuaCCLabel"
    local richLabel = LuaCCLabel.createRichLabel(richInfo)
    richLabel:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(richLabel)
    richLabel:setAnchorPoint(ccp(0.5,0))
    richLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,bottomBg:getPositionY()+bottomBg:getContentSize().height*0.5*g_fElementScaleRatio))
end

function createLayer( ... )
	-- body
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,200))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBackGround()

	return _bgLayer
end

function showLayer()
	init()

	createLayer()

	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,100,1500)
end
