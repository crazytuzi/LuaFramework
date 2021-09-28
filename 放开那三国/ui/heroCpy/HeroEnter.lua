-- Filename：	HeroEnter.lua
-- Author：		LiuLiPeng
-- Date：		2014-4-19
-- Purpose：		列传

module ("HeroEnter", package.seeall)
require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/tip/AnimationTip"

local IMG_PATH = "images/herocopy/"				-- 主城场景图片主路径
local layer        = nil								-- 列传入口layer
local hero         =  nil								-- 英雄数据
local htid         = -1 								-- 英雄id
local data         = {}
local bgSprite     = nil
local tipLabel     = nil
local mapNameTable = {}
local mapTable     = {}
local copy_tag     = 1
local mapHardTable = {}
local copyLevel    = 1
local sevenBilyLabel = nil
local sevenLabel = nil
function init()
	IMG_PATH     = "images/herocopy/"				-- 主城场景图片主路径
	layer        = nil								-- 列传入口layer
	hero         =  nil								-- 英雄数据
	htid         = -1 								-- 英雄id
	data         = {}
	bgSprite     = nil
	tipLabel     = nil
	mapNameTable = {}
	mapTable     = {}
	copy_tag     = 1
	mapHardTable = {}
	copyLevel    = 1
	sevenBilyLabel = nil
 	sevenLabel = nil
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return
--]]
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    else
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		layer:registerScriptTouchHandler(onTouchesHandler, false, -302, true)
		layer:setTouchEnabled(true)
	elseif (event == "exit") then
		layer:unregisterScriptTouchHandler()
		IMG_PATH = "images/herocopy/"			-- 主城场景图片主路径
		layer = nil								-- 列传入口layer
		hero =  nil								-- 英雄数据
		htid = -1 								-- 英雄id
		data = {}
		bgSprite = nil
		tipLabel = nil
		mapNameTable = {}
		mapTable = {}
		copy_tag  = 1
		mapHardTable = {}

	end
end


function setId( heroId )
	-- body
	htid = heroId
end

local function callback( tag,item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- body
	if(tag == 1) then
		copyLevel = 1
	elseif(tag == 2) then
		copyLevel = 2
	elseif(tag == 0) then
		copyLevel = 3
	else
		copyLevel = 1
	end
	updateLabel()

	if(StarUtil.isHeroCopyPassed(htid, 1) == false and copyLevel ==2) then
		AnimationTip.showTip(GetLocalizeStringBy("llp_5"))
		return
	end

	print("callback tag ", tag)

	tolua.cast(item,"CCMenuItemSprite")
	item:selected()
	if(copy_tag~=tag)then
		local itemcp = item:getParent():getChildByTag(copy_tag)
		tolua.cast(itemcp,"CCMenuItemSprite")
		itemcp:unselected()
		copy_tag = tag
		if(tonumber(tag)~=0)then
			copyFileLua = "db/heroCXml/hero_" .. mapTable[tag]
			_G[copyFileLua] = nil
			package.loaded[copyFileLua] = nil
			require (copyFileLua)
			bgSprite:setTexture( CCTextureCache:sharedTextureCache():addImage("images/copy/ncopy/overallimage/" .. HeroCXml.background))
			mapName:removeFromParentAndCleanup(true)
			mapName = CCSprite:create("images/copy/ncopy/nameimage/"..tostring(mapNameTable[tag]))
			copyNameBg:addChild(mapName)
			mapName:setAnchorPoint(ccp(0.5,0.5))
			mapName:setPosition(ccp(copyNameBg:getContentSize().width*0.5,copyNameBg:getContentSize().height*0.5))
			-- mapName:setTexture(CCTextureCache:sharedTextureCache():addImage("images/copy/ncopy/nameimage/"..tostring(mapNameTable[tag])))
			-- mapName:setScale(g_fBgScaleRatio)
		else
			item:setColor(ccc3(125,125,125))
			AnimationTip.showTip(GetLocalizeStringBy("key_3426"))
		end
	end
end

function showLayer(htidCpy)
	-- body
	layer = CCLayer:create()
	layer:registerScriptHandler(onNodeEvent)
	local runScene = CCDirector:sharedDirector():getRunningScene()
	runScene:addChild(layer,2000)
	layer:setTouchPriority(-301)
	layer:setPosition(ccp(0,0))

	setId(htidCpy)
	if(tonumber(htidCpy)~=-1)then
       require "db/DB_Heroes"
       hero = DB_Heroes.getDataById(htidCpy)
    end

    local copy_ids = string.split(hero.hero_copy_id, ",")
	require "db/DB_Hero_copy"
	for k,type_copy in pairs(copy_ids) do
		local type_copy_arr = string.split(type_copy, "|")
		copy = DB_Hero_copy.getDataById(type_copy_arr[1])
		table.insert(mapTable,type_copy_arr[1])
		table.insert(mapHardTable,type_copy_arr[2])
		table.insert(mapNameTable,copy.image)
	end
	copyFileLua = nil
	if( StarUtil.isHeroCopyPassed(htid,3) ~= true and StarUtil.isHeroCopyPassed(htid,1) == true)then
		copyFileLua = "db/heroCXml/hero_" .. mapTable[2]
		copy_tag = 2
	else
		copyFileLua = "db/heroCXml/hero_" .. mapTable[1]
	end
	_G[copyFileLua] = nil
	package.loaded[copyFileLua] = nil
	require (copyFileLua)

	-- bgSprite
	bgSprite = CCSprite:create("images/copy/ncopy/overallimage/" .. HeroCXml.background)
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp( g_winSize.width*0.5,g_winSize.height*0.5))
	-- bgSprite:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height))
	bgSprite:setScale(g_fBgScaleRatio)
	layer:addChild(bgSprite)


 --    --武将列传四个字
 --    local lieLabel = CCRenderLabel:create( GetLocalizeStringBy("key_2037"), g_sFontPangWa, 33, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- lieLabel:setAnchorPoint(ccp(0.5,0.5))
 --    lieLabel:setColor(ccc3(0xff, 0xe4, 0x00))
 --    lieLabel:setPosition(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height)
 --    bgSprite:addChild(lieLabel)

	-- 武将label
	local heroLabel = CCRenderLabel:create( hero.name..GetLocalizeStringBy("key_2903"), g_sFontPangWa, 28, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	heroLabel:setAnchorPoint(ccp(0.5,0.5))
    heroLabel:setColor(ccc3(0x00, 0xff, 0x18))

    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	layer:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-426)


    -- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/close_btn_n.png", "images/common/close_btn_h.png", closeAction )
	closeBtn:setScale(g_fElementScaleRatio)
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(g_winSize.width-closeBtn:getContentSize().width*g_fElementScaleRatio, g_winSize.height*0.93))
	closeMenuBar:addChild(closeBtn)

	--副本名字
	copyNameBg = CCSprite:create("images/copy/acopy/namebg.png")
	layer:addChild(copyNameBg)
	copyNameBg:setAnchorPoint(ccp(0,0.5))
	copyNameBg:setPosition(ccp(0,g_winSize.height-copyNameBg:getContentSize().height))
	copyNameBg:setScale(g_fBgScaleRatio)

	mapName = CCSprite:create("images/copy/ncopy/nameimage/"..tostring(mapNameTable[1]))
	copyNameBg:addChild(mapName)
	mapName:setAnchorPoint(ccp(0.5,0.5))
	mapName:setPosition(ccp(copyNameBg:getContentSize().width*0.5,copyNameBg:getContentSize().height*0.5))

	--英雄描述诗句
	local str = hero.poem

	local strArry = string.split(str,"\n")

	local label = CCLabelTTF:create(strArry[1],g_sFontPangWa,21)

	local count = #strArry

	-- scaleSprite:setPreferredSize(CCSizeMake(label:getContentSize().width+30,label:getContentSize().height*count+15*(count-1)+20))
	for i=1,#strArry  do
		desLabel = CCRenderLabel:create(strArry[i],g_sFontPangWa,25, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
		desLabel:setAnchorPoint(ccp(0.5,0.5))
		desLabel:setColor(ccc3(0xff, 0xff, 0xff))
		heroLabel:addChild(desLabel)
		desLabel:setTag(i)

		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
			desLabel:setAnchorPoint(ccp(1,0.5))
			desLabel:setPosition(ccp(heroLabel:getContentSize().width*0.5 + 110,-heroLabel:getContentSize().height*0.5-50*(i-1)))
		else
			desLabel:setPosition(ccp(heroLabel:getContentSize().width*0.5,-heroLabel:getContentSize().height*0.5-50*(i-1)))
		end
	end


	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
		heroLabel:setPosition(ccp(g_winSize.width-135*g_fElementScaleRatio,g_winSize.height*0.5+desLabel:getContentSize().height*0.5*count+50*(count-1)*0.5))
	else
		heroLabel:setPosition(ccp(g_winSize.width-desLabel:getContentSize().width*0.5*g_fElementScaleRatio-5*g_fElementScaleRatio,g_winSize.height*0.5+desLabel:getContentSize().height*0.5*count+50*(count-1)*0.5))
	end
    layer:addChild(heroLabel,1)
    heroLabel:setScale(g_fElementScaleRatio)

    --武将全身像
    require"script/model/utils/HeroUtil"
    local heroSprite = HeroUtil.getHeroBodySpriteByHTID(hero.id)
    heroSprite:setAnchorPoint(ccp(0.5,0.5))
    heroSprite:setPosition(ccp(g_winSize.width*0.25,g_winSize.height*0.6))
    layer:addChild(heroSprite)
    heroSprite:setScale(g_fElementScaleRatio)

    --开始剧情按钮
    local buttonbg = CCSprite:create("images/common/bg/firedi.png")

    breakDownButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1597"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    breakDownButton:registerScriptTapHandler(startStory)
    breakDownButton:setAnchorPoint(ccp(0.5,0.5))
    breakDownButton:setScale(g_fElementScaleRatio)
    breakDownButton:setPosition(ccp(g_winSize.width*0.5,breakDownButton:getContentSize().height*g_fElementScaleRatio))
    closeMenuBar:addChild(breakDownButton)

    breakDownButton:addChild(buttonbg)
    buttonbg:setAnchorPoint(ccp(0.5,0.5))
    buttonbg:setPosition(ccp(breakDownButton:getContentSize().width*0.5,breakDownButton:getContentSize().height*0.5))
    breakDownButton:reorderChild(buttonbg,-1)

	--临时获取高度sprite
	local shortSprite = CCSprite:create("images/famoushero/hard_n.png")
    --九分图
	local scaleSprite = CCScale9Sprite:create("images/common/bg/black_bg.png")
	-- scaleSprite:setContentSize(CCSizeMake(g_winSize.width*0.8,shortSprite:getContentSize().height*g_fElementScaleRatio+20*g_fElementScaleRatio))
	layer:addChild(scaleSprite)
	scaleSprite:setAnchorPoint(ccp(0.5,0))
	scaleSprite:setPosition(ccp(g_winSize.width*0.5,breakDownButton:getContentSize().height*2*g_fElementScaleRatio))
	scaleSprite:setScale(g_fElementScaleRatio)

	-- local chooseDifLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_1"), g_sFontPangWa, 28, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- chooseDifLabel:setScale(g_fElementScaleRatio)
	-- chooseDifLabel:setColor(ccc3(0xff,0xf6,0x00))
	-- scaleSprite:addChild(chooseDifLabel)
	-- chooseDifLabel:setAnchorPoint(ccp(0.5,0.5))
	-- chooseDifLabel:setPosition(ccp(scaleSprite:getContentSize().width*0.5,scaleSprite:getContentSize().height))
    --难度menu
    local difficultyMenu = CCMenu:create()
    difficultyMenu:setPosition(ccp(0, 0))
	scaleSprite:addChild(difficultyMenu)
	difficultyMenu:setTouchPriority(-426)
    --简单按钮
    local easy_btn = nil
   	easy_btn = CCMenuItemImage:create("images/famoushero/easy_n.png","images/famoushero/easy_h.png")
   	if( StarUtil.isHeroCopyPassed(htid,2) ~= true )then
    	easy_btn:selected()
    end
	easy_btn:registerScriptTapHandler(callback)
	easy_btn:setAnchorPoint(ccp(0.5, 0.5))
	easy_btn:setPosition(ccp(scaleSprite:getContentSize().width * 0.2, scaleSprite:getContentSize().height * 0.5))
	-- easy_btn:setScale(g_fElementScaleRatio)
	difficultyMenu:addChild(easy_btn, 1, 1)


    --普通按钮
    local normal_btn = nil
   	if( StarUtil.isHeroCopyPassed(htid, 1)) then
   		 normal_btn = CCMenuItemImage:create("images/famoushero/normal_n.png","images/famoushero/normal_h.png")
   	else
   		local norSprite = BTGraySprite:create("images/famoushero/normal_n.png")
   		local selSprite = BTGraySprite:create("images/famoushero/normal_h.png")
   		normal_btn = CCMenuItemSprite:create(norSprite, selSprite)
   	end
   	if( StarUtil.isHeroCopyPassed(htid,3) ~= true and StarUtil.isHeroCopyPassed(htid,1) == true)then
   		easy_btn:unselected()
    	normal_btn:selected()
    end
	normal_btn:registerScriptTapHandler(callback)
	normal_btn:setAnchorPoint(ccp(0.5, 0.5))
	normal_btn:setPosition(ccp(scaleSprite:getContentSize().width * 0.5, scaleSprite:getContentSize().height * 0.5))
	-- normal_btn:setScale(g_fElementScaleRatio)
	difficultyMenu:addChild(normal_btn, 1, 2)
	if( StarUtil.isHeroCopyPassed(htidCpy,1) == false )then
		normal_btn:setColor(ccc3(125,125,125))
	end

    --困难按钮
    local hard_btn = nil
   	if( false ) then --困难本次更新不开启
   		 hard_btn = CCMenuItemImage:create("images/famoushero/hard_n.png","images/famoushero/hard_h.png")
   	else
   		local norSprite = BTGraySprite:create("images/famoushero/hard_n.png")
   		local selSprite = BTGraySprite:create("images/famoushero/hard_h.png")
   		hard_btn = CCMenuItemSprite:create(norSprite, selSprite)
   	end
	hard_btn:registerScriptTapHandler(callback)
	hard_btn:setAnchorPoint(ccp(0.5, 0.5))
	hard_btn:setPosition(ccp(scaleSprite:getContentSize().width * 0.8, scaleSprite:getContentSize().height * 0.5))
	-- hard_btn:setScale(g_fElementScaleRatio)
	difficultyMenu:addChild(hard_btn, 1, 0)
	hard_btn:setColor(ccc3(125,125,125))


	--第七天赋node
    local node = CCNode:create()
    scaleSprite:addChild(node)

	--第七天赋label
	sevenBilyLabel = CCRenderLabel:create( GetLocalizeStringBy("key_2561") .. GetLocalizeStringBy("lic_" .. (1035 + copyLevel)) .. GetLocalizeStringBy("zzh_1283") , g_sFontPangWa, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	sevenBilyLabel:setAnchorPoint(ccp(0.5,0))
    sevenBilyLabel:setColor(ccc3(0xff, 0xff, 0xff))
    sevenBilyLabel:setPosition(sevenBilyLabel:getContentSize().width*0.5,0)
    node:addChild(sevenBilyLabel)

    if( StarUtil.isHeroCopyPassed(htid,3) ~= true and StarUtil.isHeroCopyPassed(htid,1) == true)then
		copyLevel = 2
	else
		copyLevel = 1
	end

    --第七天赋label2
	sevenLabel = CCRenderLabel:create( GetLocalizeStringBy("lcy_" .. (1001 + copyLevel)), g_sFontPangWa, 28, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	sevenLabel:setAnchorPoint(ccp(0.5,0))
    sevenLabel:setColor(ccc3(0x00, 0xe4, 0xff))
    sevenLabel:setPosition(sevenBilyLabel:getContentSize().width+5+sevenLabel:getContentSize().width*0.5,0)
    node:addChild(sevenLabel)
    -- node:setScale(g_fElementScaleRatio)

    node:ignoreAnchorPointForPosition(false)
    node:setAnchorPoint(ccp(0.5,0))
    node:setContentSize(CCSizeMake(sevenLabel:getContentSize().width+sevenBilyLabel:getContentSize().width,sevenBilyLabel:getContentSize().height))
    node:setPosition(ccp(scaleSprite:getContentSize().width*0.5,sevenLabel:getContentSize().height*0.5*g_fElementScaleRatio))

end


function updateLabel( ... )
	sevenBilyLabel:setString(GetLocalizeStringBy("key_2561") .. GetLocalizeStringBy("lic_" .. (1035 + copyLevel)).. GetLocalizeStringBy("zzh_1283"))
	sevenLabel:setString(GetLocalizeStringBy("lcy_" .. (1001 + copyLevel)))
end


function startStory( ... )
	require "script/ui/tip/AnimationTip"
	require "script/ui/star/StarUtil"

	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(UserModel.getHeroLevel()<50)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_170"))
		return
	end

	if(ItemUtil.isBagFull() == true )then
		closeAction()
		return
	end

	-- if(StarUtil.isHeroCopyPassed(htid, copyLevel) == true) then
	-- 	local hero_copy_id 		= DB_Heroes.getDataById(htid).hero_copy_id
	-- 	local hero_copy_talent 	= string.split(hero_copy_id, ",")
	-- 	local evolveLevel 		= tonumber(string.split(hero_copy_talent[copyLevel],"|")[3])
	-- 	AnimationTip.showTip(GetLocalizeStringBy("llp_171").. evolveLevel .. GetLocalizeStringBy("key_8006") ..GetLocalizeStringBy("lcy_" .. (1001 + copyLevel)))
	-- 	return
	-- end
	-- if(StarUtil.isHeroCopyPassed(htid, 2) == false) then
	-- 	local hero_copy_id 		= DB_Heroes.getDataById(htid).hero_copy_id
	-- 	local hero_copy_talent 	= string.split(hero_copy_id, ",")
	-- 	local evolveLevel 		= tonumber(string.split(hero_copy_talent[copyLevel],"|")[3])
	-- 	AnimationTip.showTip(GetLocalizeStringBy("llp_171").. evolveLevel .. GetLocalizeStringBy("key_8006") ..GetLocalizeStringBy("lcy_" .. (1001 + copyLevel)))
	-- 	return
	-- end


	if(copy_tag~=0)then
		print(tostring(StarUtil.isHeroCopyPassed(htid,1)).."haohoaohaoah"..copy_tag)
		if(StarUtil.isHeroCopyPassed(htid,1) == false and tonumber(copy_tag)==2)then
			AnimationTip.showTip(GetLocalizeStringBy("llp_5"))
			return
		end
		if( StarUtil.isHeroCopyPassed(htid,mapHardTable[copy_tag]) == true )then
			local hero_copy_id 		= DB_Heroes.getDataById(htid).hero_copy_id
			local hero_copy_talent 	= string.split(hero_copy_id, ",")
			-- 去掉武将列传Id判断，heroes表修改 20160407 lgx
			local evolveLevel 		= tonumber(string.split(hero_copy_talent[copyLevel],"|")[2])
			AnimationTip.showTip(GetLocalizeStringBy("llp_171").. evolveLevel .. GetLocalizeStringBy("llp_172") ..GetLocalizeStringBy("lcy_" .. (1001 + copyLevel)))
			return
		end
		local isUp = FormationUtil.isHadSameTemplateOnFormationByHtid(htid)
		if(isUp == true)then
			local tempArgs = CCArray:create()
	        if(hero.hero_copy_id~=nil)then
	            tempArgs:addObject(CCInteger:create(mapTable[copy_tag]))
	            tempArgs:addObject(CCInteger:create(mapHardTable[copy_tag]))
	            RequestCenter.Hcopy_getCopyInfo(HeroEnter.getHeroCopyCallback,tempArgs)
	        else
	            AnimationTip.showTip(GetLocalizeStringBy("key_1208"))
	        end
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_2387"))
		end
	end

end

function closeAction( ... )
	-- body
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	layer:setVisible(false)
	layer:removeFromParentAndCleanup(true)
	layer = nil
end

function getHeroCopyCallback( cbFlag, dictData, bRet )
	-- body
	if(dictData and dictData.ret) then
		require "script/ui/heroCpy/HeroLayout"
		print("HeroEnter copy_tag===="..copy_tag)
		local fortsLayer = HeroLayout.createFortsLayout(dictData.ret, htid,copy_tag)
		MainScene.changeLayer(fortsLayer, "fortsLayer")

		layer:setVisible(false)
		layer:removeFromParentAndCleanup(true)
		layer = nil

		local runing_scene = CCDirector:sharedDirector():getRunningScene()
    	runing_scene:removeChildByTag(10,true)
	end
end
