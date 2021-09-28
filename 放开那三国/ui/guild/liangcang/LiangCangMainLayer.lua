-- FileName: LiangCangMainLayer.lua 
-- Author: licong 
-- Date: 14-11-5 
-- Purpose: 粮仓主界面 

module("LiangCangMainLayer", package.seeall)

require "script/ui/guild/liangcang/LiangTian"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/GuildUtil"
require "script/ui/guild/liangcang/LiangTian"
require "script/ui/guild/liangcang/LiangTian"
require "script/ui/guild/liangcang/BarnService"
require "script/ui/guild/liangcang/BarnData"
require "script/utils/LevelUpUtil"
require "script/utils/BaseUI"
require "script/ui/guild/liangcang/UseRefreshInfo"
require "script/ui/guild/liangcang/LiangTianInfoDialog"
require "db/DB_Item_normal.lua"
require "script/ui/item/ItemUtil"
local _bgLayer 						= nil
local _bgSprite 					= nil
local _topBg						= nil
local _refreshOwnNumFont 			= nil -- 刷新粮田次数
local _refreshAllNumFont 			= nil -- 刷新全部次数
local _fightBookNumFont 			= nil -- 挑战书数量字体
local _guildGrainNumFont 			= nil -- 粮仓储存粮草字体
local _myGrainNumFont 				= nil -- 个人储存粮仓字体
local _fenFont 						= nil -- 分发粮草label
local _timeFont 					= nil -- 发粮倒计时label
local _liangTianSpArr 				= {}  -- 粮田储存数组
local _collectAnimSprite 			= nil -- 割麦子特效
local _animationMaskLayer 			= nil -- 特效屏蔽层
local _liangcangLv 					= nil -- 粮仓等级label
local _gongxianNumFont  			= nil -- 粮仓升级贡献值
local _gongGaoSprite 				= nil -- 使用大丰收公告
local _closeMenuItem 				= nil -- 关闭按钮
local _exchangeMenuItem 			= nil -- 兑换按钮
local _gongxunNumFont 				= nil -- 功勋值label
local _refreshAllMenuItem 			= nil -- 大丰收按钮
local _refreshMenuItem 				= nil -- 重置按钮
local _refreshFontNode 				= nil -- 重置采集费用
local _smallRefreshAllItem 			= nil -- 小丰收按钮
local _smallRefreshAllFontNode 		= nil -- 小丰收消耗node
local _oneKeyMeunItem 				= nil -- 一键采集

local _bulletinLayerSize 			= nil
local _barnLv 						= nil -- 粮仓等级
local _guildGrainNum				= nil -- 军团粮草数量	
local _guildGraninMaxNum 			= nil -- 军团粮草上限	
local _myGrainNum					= nil -- 个人粮草
local _myMeritNum					= nil -- 个人功勋
local _barnNeedExp 					= nil -- 粮仓升级需要贡献值
local _alreadyRefreshOwnNum 		= nil -- 刷新自己粮仓已用次数
local _alreadyRefreshAllNum         = nil -- 全部刷新已用次数
local _refreshOwnMaxNum 			= nil -- 刷新自己粮仓次数上限
local _refreshAllMaxNum 			= nil -- 刷新全部次数上限
local _refreshOwnCost 				= nil -- 刷新自己粮田花费
local _refreshAllCost 				= nil -- 刷新全部花费
local _isOpenRefreshAll             = nil -- 是否开启刷新全部按钮
local _refreshAllNeedVip 			= nil -- 开启全部刷新按钮需要vip等级
local _refreshAllMaxNum 			= nil -- 全部刷新次数上限
local _collectExp 					= nil -- 得到采集获得的经验
local _liangtianNum  				= nil -- 粮田个数
local _shareNextTime 				= nil -- 下次分粮时间 
local _collectCost 					= nil -- 采集花费银币
local _refreshAllAddNum 			= nil -- 刷新全部增加的采集次数
local _maxBarnLv 					= nil -- 粮仓最大等级
local _liangTianLvArr 				= {}  -- 粮田等级数组
local _alreadyUseSmallNum 			= nil -- 已经使用小丰收次数
local _useSmallMaxNum 				= nil -- 使用小丰收最大次数
local _useSmallCost 				= nil -- 使用小丰收消耗建设度值
local _useSmallAddNum 				= nil -- 使用小丰收增加的采集次数
local _collectMaxNum 				= nil -- 粮田可以采集的最大次数
local _tipFont						= nil
-- 粮田坐标
local _liangPosX = {0.22,0.565,0.81,0.22,0.55}
local _liangPosY = {0.22,0.27,0.395,0.56,0.63}


--[[
	@des 	:初始化
	@param 	:
	@return :
--]]
function init( ... )
	_bgLayer 						= nil
	_bgSprite 						= nil
	_topBg							= nil
	_refreshOwnNumFont 				= nil
	_refreshAllNumFont 				= nil
	_fightBookNumFont 				= nil 
	_guildGrainNumFont 				= nil 
	_myGrainNumFont 				= nil
	_timeFont 						= nil 
	_fenFont 						= nil
	_liangTianSpArr 				= {} 
	_collectAnimSprite 				= nil
	_animationMaskLayer 			= nil 
	_liangcangLv 					= nil
	_gongxianNumFont  				= nil
	_gongGaoSprite 					= nil
	_closeMenuItem 					= nil 
	_exchangeMenuItem 				= nil 
	_gongxunNumFont 				= nil
	_refreshAllMenuItem 			= nil
	_refreshMenuItem 				= nil 
	_refreshFontNode 				= nil 
	_smallRefreshAllItem 			= nil 
	_smallRefreshAllFontNode 		= nil 
	_oneKeyMeunItem 				= nil

	_bulletinLayerSize 				= nil
	_barnLv 						= nil 
	_guildGrainNum					= nil
	_guildGraninMaxNum 				= nil		
	_myGrainNum						= nil
	_myMeritNum						= nil
	_barnNeedExp 					= nil
	_alreadyRefreshOwnNum 			= nil 
	_alreadyRefreshAllNum         	= nil
	_refreshOwnMaxNum 				= nil
	_refreshAllMaxNum 				= nil
	_refreshOwnCost 				= nil
	_refreshAllCost 				= nil
	_isOpenRefreshAll             	= nil
	_refreshAllNeedVip 				= nil
	_refreshAllMaxNum 				= nil
	_collectExp 					= nil 
	_liangtianNum  					= nil 
	_shareNextTime 					= nil
	_collectCost 					= nil
	_refreshAllAddNum 				= nil
	_maxBarnLv 						= nil 
	_liangTianLvArr 				= {}
	_alreadyUseSmallNum 			= nil
	_useSmallMaxNum 				= nil
	_useSmallCost 					= nil
	_useSmallAddNum 				= nil
	_collectMaxNum 					= nil
	_tipFont						= nil
end

--------------------------------------------------------- 按钮事件 ----------------------------------------------------
--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
		require "script/audio/AudioUtil"
    	AudioUtil.playBgm("audio/bgm/amb_liangtian.mp3",true)
		GuildDataCache.setIsInGuildFunc(true)
	elseif (event == "exit") then
		require "script/audio/AudioUtil"
    	AudioUtil.playMainBgm()
		GuildDataCache.setIsInGuildFunc(false)
	end
end

--[[
	@des 	:返回按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

	require "script/ui/guild/GuildMainLayer"
	local guildMainLayer = GuildMainLayer.createLayer(false)
	MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end

--[[
	@des 	:分发粮饷按钮回调
	@param 	:
	@return :
--]]
function fenMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("fenMenuItemCallback")

    -- 粮草不足 不让分
    -- 军团粮草
	_guildGrainNum = GuildDataCache.getGuildGrainNum()
	print("_guildGrainNum",_guildGrainNum)
	if(_guildGrainNum <= 0)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1365"))
		return
    end
    -- 分粮界面
    require "script/ui/guild/liangcang/DistributeFodderPanel"
    DistributeFodderPanel.showLayer()
end

--[[
	@des 	:购买挑战书按钮回调
	@param 	:
	@return :
--]]
function buyMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("buyMenuItemCallback")

    -- 判断官职 军团长 副军团长才能发 0为平民，1为会长，2为副会长
    if( GuildDataCache.getMineMemberType() ~= 1 and GuildDataCache.getMineMemberType() ~= 2 )then  
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1394"))
		return
    end

    local fightBookNum = GuildDataCache.getGuildFightBookNum() 
    local fightBookMaxNum = BarnData.getFightBookMaxNum()
    local fightBookCost = BarnData.getZhanShuCost()

    -- 挑战书不为0不能买
    if( fightBookNum > 0 )then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1341"))
		return
    end

    -- 判断挑战书上限
    if( fightBookNum >= fightBookMaxNum )then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1298"))
		return
    end
    -- 建设度不足
	if(GuildDataCache.getGuildDonate() < fightBookCost ) then  
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1381"))
		return
	end

    -- 确定购买回调
	local yesBuyCallBack = function ( ... )
		local nextFunction = function ( ... )
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1405"))
	    	-- 刷新挑战书数量
	    	local fightBookNum = GuildDataCache.getGuildFightBookNum()
	    	_fightBookNumFont:setString(fightBookNum .. "/" .. fightBookMaxNum )
	    end
		-- 发请求
		BarnService.buyFightBook(nextFunction)
	end
	-- 是否消耗图标+数量+军团建设度购买1个抢粮书？
	local tipNode = CCNode:create()
	tipNode:setContentSize(CCSizeMake(550,100))
	-- 第一行
    local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1296"),
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{
	        		type = "CCSprite",
                    image = "images/common/gong.png"
	        	},
	        	{
	            	type = "CCLabelTTF", 
	            	text = fightBookCost,
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{	
	        		type = "CCLabelTTF", 
	        		text =  GetLocalizeStringBy("lic_1297"),
	        		color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font1 = LuaCCLabel.createRichLabel(textInfo1)
 	font1:setAnchorPoint(ccp(0.5, 0.5))
 	font1:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
 	tipNode:addChild(font1)
 	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,360))
end

--[[
	@des 	:兑换按钮回调
	@param 	:
	@return :
--]]
function exchangeMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("exchangeMenuItemCallback")
	require "script/ui/shopall/liangcao/BarnExchangeLayer"
	BarnExchangeLayer.show()
end

--[[
	@des 	:粮田按钮回调
	@param 	:p_id 粮田id
	@return :
--]]
function liangTianCollectCallback( p_id, p_parentNode )
	print("p_id======",p_id)

	--背包判断
    if(ItemUtil.isBagFull() == true )then
        return
    end
	-- 抢粮争夺战中不能采集
    require "script/ui/guild/guildRobList/GuildRobData"
    local isIn = GuildRobData.isRobbing()
    if( isIn )then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1404"))
		return
    end

    -- 剩余采摘次数
    local surplusCollectNum,curLv,curAllExp = GuildDataCache.getSurplusCollectNumAndExpLv(p_id)
    print("surplusCollectNum",surplusCollectNum)
    if( surplusCollectNum <= 0)then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1299"))
		return
    end

    -- 当该粮田等级超过达到上限后 不再增加经验
    local curLiangTianMaxLv = BarnData.getLiangTianMaxLvByBarnLv(_barnLv)
    if(curLv >= curLiangTianMaxLv)then
    	_collectExp = 0
    else
    	_collectExp = BarnData.getCollectExp()
    end

    -- 采集后获得的粮草 个人 军团
    local myMerit,guildGrain = BarnData.getLiangTianProduceGrainNum(p_id,curLv)

    -- 确定采集回调
    local nextFunction = function ( p_retData )
    	-- 减少剩余次数
    	GuildDataCache.setSurplusCollectNumById(p_id,surplusCollectNum-1)
    	-- 更新军团获得粮草
    	_guildGrainNum = tonumber(p_retData[1])
    	GuildDataCache.setGuildGrainNum( _guildGrainNum )
    	-- 更新个人获得功勋
    	local addMyMerit = tonumber(p_retData[2]) - _myMeritNum
    	_myMeritNum = tonumber(p_retData[2])
    	GuildDataCache.setMyselfMeritNum( _myMeritNum )

    	-- 刷新UI
    	_guildGrainNumFont:setString( string.formatBigNumber(_guildGrainNum) .. "/" .. string.formatBigNumber(_guildGraninMaxNum) )
    	_gongxunNumFont:setString( string.formatBigNumber(_myMeritNum) )

    	-- 刷新粮田信息
    	_liangTianSpArr[p_id]:refreshCallFunc()

    	-- 刷新粮田信息界面剩余次数
    	LiangTianInfoDialog.refreshCollectNum( p_id )

    	-- 弹富文本提示框
    	local tipFunction = function ( ... )
    		-- 第一条 采集获得功勋+功勋图标+数量，军团粮仓增加粮草+粮仓粮草图标+数量
			-- 第一行
		    local richInfo = {
	     		width = 600, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        labelDefaultFont = g_sFontPangWa,      -- 默认字体
		        labelDefaultSize = 24,          -- 默认字体大小
		        elements =
		        {	
		        	{
		        		type = "CCRenderLabel",
	                    text = GetLocalizeStringBy("lic_1300",1),
	                    color = ccc3(0xff, 0xf6, 0x00)
		        	},
		        	{
		        		type = "CCSprite",
	                    image = "images/common/gongxun.png"
		        	},
		        	{	
		        		type = "CCRenderLabel", 
		        		text = addMyMerit,
		        		color = ccc3(0x00,0xff,0x18)
		        	}
		        }
		 	}
		 	-- 当超过粮仓上限则不提示
	    	if(_guildGrainNum < _guildGraninMaxNum )then
		    	local element4 = {}
		    	element4.type = "CCRenderLabel"
		    	element4.text = GetLocalizeStringBy("lic_1301")
		    	element4.color = ccc3(0xff, 0xf6, 0x00)
		    	table.insert(richInfo.elements,element4)
		    	local element5 = {}
		    	element5.type = "CCSprite"
		    	element5.image = "images/common/liangcao.png"
		    	table.insert(richInfo.elements,element5)
		    	local element6 = {}
		    	element6.type = "CCRenderLabel"
		    	element6.text = tonumber(p_retData[3])
		    	element6.color = ccc3(0x00,0xff,0x18)
		    	table.insert(richInfo.elements,element6)
		    end
	 
		 	local tipDes1 = LuaCCLabel.createRichLabel(richInfo)
		    tipDes1:setAnchorPoint(ccp(0.5,0.5))

		    --道具信息
		    local propData = p_retData[4] or {}
		    local propData1 = propData.item or {}
		    local posY = 0 
		    for i,data in pairs(propData1) do
		    	-- i为id,data为数量
		    	print("i~~~~~",i)
		    	local itemInfo = DB_Item_normal.getDataById(i) or {}
		    	local imageName = itemInfo.icon_little
		    local richInfo = {
	     		width = 600, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        labelDefaultFont = g_sFontPangWa,      -- 默认字体
		        labelDefaultSize = 24,          -- 默认字体大小
		        elements =
		        {
		        	{
    					type = "CCRenderLabel",
    					text = GetLocalizeStringBy("fqq_056"),
    					color = ccc3(0xe4, 0x00, 0xff)
    				},
	    		 	{
                        type = "CCRenderLabel",
                        text = itemInfo.name,
                        color = ccc3(0xff, 0xf6, 0x00)
                    },
                    {
                        type = "CCSprite",
                        image = "images/base/props/"..imageName
                    },
                    {
                        type = "CCRenderLabel",
                        text = data,
                        color = ccc3(0x00,0xff,0x18)
                    },
                }
            }
           
            local tipFont = LuaCCLabel.createRichLabel(richInfo)
		    tipFont:setAnchorPoint(ccp(0.5,1))
		    posY = posY - 30
		    tipFont:setPosition(ccp(tipDes1:getContentSize().width*0.35,posY))
		    tipDes1:addChild(tipFont)
		end
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(tipDes1,2000)
		    tipDes1:setScale(g_fElementScaleRatio)
		    -- 动画action
			tipDes1:setPosition(ccp(runningScene:getContentSize().width*0.5,runningScene:getContentSize().height*0.5))
		    local nextMoveToP = ccp(runningScene:getContentSize().width*0.5,runningScene:getContentSize().height*0.7)
		    -- 设置遍历子节点  透明度
		    tipDes1:setCascadeOpacityEnabled(true)
		    local actionArr = CCArray:create()
			actionArr:addObject(CCEaseOut:create(CCMoveTo:create(4, nextMoveToP),1))
			actionArr:addObject(CCFadeOut:create(0.8))
			actionArr:addObject(CCCallFuncN:create(function ( ... )
				tipDes1:removeFromParentAndCleanup(true)
				tipDes1 = nil
			end))
			tipDes1:runAction(CCSequence:create(actionArr))

	    	-- 向上飞exp+经验值
	    	-- 默认文本的信息
	    	if(_collectExp > 0)then
			   -- 第一行
			    local textInfo1 = {
		     		width = 200, -- 宽度
			        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
			        labelDefaultFont = g_sFontPangWa,      -- 默认字体
			        labelDefaultSize = 28,          -- 默认字体大小
			        elements =
			        {	
			        	{
			        		type = "CCSprite",
		                    image = "images/common/exp.png"
			        	},
			        	{	
			        		type = "CCRenderLabel", 
			        		text =  "+" .. _collectExp*1,
			        		color = ccc3(0x00,0xff,0x18)
			        	}
			        }
			 	}
			 	local tipDes = LuaCCLabel.createRichLabel(textInfo1)
			    tipDes:setAnchorPoint(ccp(0.5,0.5))
			    p_parentNode:addChild(tipDes,100)
			    -- 动画action
				tipDes:setPosition(ccp(p_parentNode:getContentSize().width*0.5,p_parentNode:getContentSize().height*0.5))
			    local nextMoveToP = ccp(p_parentNode:getContentSize().width*0.5,p_parentNode:getContentSize().height)
			    -- 设置遍历子节点  透明度
			    tipDes:setCascadeOpacityEnabled(true)
			    local actionArr = CCArray:create()
				actionArr:addObject(CCEaseOut:create(CCMoveTo:create(1, nextMoveToP),1))
				actionArr:addObject(CCFadeOut:create(0.8))
				actionArr:addObject(CCCallFuncN:create(function ( ... )
					tipDes:removeFromParentAndCleanup(true)
					tipDes = nil
				end))
				tipDes:runAction(CCSequence:create(actionArr))
			end
    	end

    	-- 割麦子特效  
        local collectAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/guild/liangcang/effect/gemai", 1, CCString:create(""))
        collectAnimSprite:setAnchorPoint(ccp(0.5, 0))
        collectAnimSprite:setPosition(ccp(p_parentNode:getContentSize().width*0.5,p_parentNode:getContentSize().height*0.5))
        p_parentNode:addChild(collectAnimSprite)
        local collectAnimationEndCallBack = function ( ... )
	        -- 弹提示框
	        tipFunction()
        end
        local collectDelegate = BTAnimationEventDelegate:create()
        collectDelegate:registerLayerEndedHandler(collectAnimationEndCallBack)
        collectAnimSprite:setDelegate(collectDelegate)

        -- 割麦子音效
        AudioUtil.playEffect("audio/effect/gemaizi.mp3")    
    end
	-- 发请求
	BarnService.harvest(p_id,1,nextFunction)
end

--[[
	@des 	:粮田按钮回调
	@param 	:
	@return :
--]]
function liangTianMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("liangTianMenuItemCallback")

    -- 粮田没有开启
    local isOpen = BarnData.getLiangTianIsOpenById(tag)
    if( isOpen == false)then
    	-- 弹富文本提示框
    	local richInfo = {}
    	richInfo.elements = {}
    	local element1 = {}
    	element1.type = "CCLabelTTF"
    	element1.text = GetLocalizeStringBy("lic_1330")
    	table.insert(richInfo.elements,element1)
    	local neeLv = BarnData.getOpenLiangTianNeedLv(tag)
    	local element2 = {}
    	element2.type = "CCLabelTTF"
    	element2.text = "Lv." .. neeLv
    	element2.color = ccc3(0x00, 0xff, 0x18)
    	table.insert(richInfo.elements,element2)
    	local element3 = {}
    	element3.type = "CCLabelTTF"
    	element3.text = GetLocalizeStringBy("lic_1331")
    	table.insert(richInfo.elements,element3)

    	require "script/ui/tip/RichAnimationTip"
    	RichAnimationTip.showTip(richInfo)
		return
    end

   require "script/ui/guild/liangcang/LiangTianInfoDialog"
   LiangTianInfoDialog.showLiangTianInfoLayer(tag)
end

--[[
	@des 	:购买采集按钮回调
	@param 	:
	@return :
--]]
function refreshOwnMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("refreshOwnMenuItemCallback")

    -- 是否可以购买 有一块田累计到上限就不能刷新了
    local isReturn = false
    for i=1,_liangtianNum do
    	local isOpen = BarnData.getLiangTianIsOpenById(i)
    	if(isOpen)then
    		-- 开启的粮田的剩余次数
    		local surplusCollectNum,a,b = GuildDataCache.getSurplusCollectNumAndExpLv(i)
    		if(surplusCollectNum >= _collectMaxNum )then 
    			isReturn = true
    		end
    	end
    end
     if( isReturn )then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1303"))
		return
    end

    -- 是否有购买次数
    local surplusRefreshNum = _refreshOwnMaxNum - _alreadyRefreshOwnNum
    if(surplusRefreshNum <= 0)then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1304"))
		return
    end
    -- 金币不足
	if(UserModel.getGoldNumber() < _refreshOwnCost ) then  
		require "script/ui/tip/LackGoldTip"    
		LackGoldTip.showTip()
		return
	end

	-- 确定刷新回调
	local yesBuyCallBack = function ( ... )
		local nextFunction = function ( ... )
	    	-- 扣除金币
	    	UserModel.addGoldNumber(-_refreshOwnCost)
	    	-- 修改已经刷新次数
	    	_alreadyRefreshOwnNum = _alreadyRefreshOwnNum + 1
	    	GuildDataCache.setAlreadyRefreshOwnNum(_alreadyRefreshOwnNum)
	    	-- 修下次刷新花费
	    	if( _alreadyRefreshOwnNum+1 > _refreshOwnMaxNum )then 
				_refreshOwnCost = BarnData.getCurRefreshLiangTianCost( _refreshOwnMaxNum )
			else
				_refreshOwnCost = BarnData.getCurRefreshLiangTianCost( _alreadyRefreshOwnNum + 1 )
			end

	    	-- 重置粮田采集次数
	    	for i=1,_liangtianNum do
		    	local isOpen = BarnData.getLiangTianIsOpenById(i)
		    	if(isOpen)then
		    		-- 开启的粮田的每块采集次数加1 应小鱼要求 前端写死的1
		    		 local surplusCollectNum,a,b = GuildDataCache.getSurplusCollectNumAndExpLv(i)
		    		GuildDataCache.setSurplusCollectNumById(i,surplusCollectNum+1)
		    	end
		    end

		    -- 刷新粮田采集次数UI
			if( not table.isEmpty( _liangTianSpArr ) )then 
				for k,v in pairs(_liangTianSpArr) do
					v:refreshCallFunc()
				end
			end
	    	-- 刷新剩余次数label
	    	_refreshOwnNumFont:setString( _refreshOwnMaxNum - _alreadyRefreshOwnNum .. "/" .. _refreshOwnMaxNum )
	    	-- 刷新重置费用label
	    	if(_refreshFontNode ~= nil)then
	    		_refreshFontNode:removeFromParentAndCleanup(true)
	    		_refreshFontNode = nil
	    	end
	    	local fontTab = {}
		    local refreshFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1290"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    refreshFont:setColor(ccc3(0xff, 0xf6, 0x00))
		    table.insert(fontTab,refreshFont)
		    -- 刷新自己粮田 金币数量
		    local goldNumFont = CCLabelTTF:create(_refreshOwnCost, g_sFontPangWa, 21)
		    goldNumFont:setColor(ccc3(0xff, 0xf6, 0x00))
		    table.insert(fontTab,goldNumFont)
		    -- 金币
		    local goldIcon = CCSprite:create("images/common/gold.png")
		    table.insert(fontTab,goldIcon)
		    _refreshFontNode = BaseUI.createHorizontalNode(fontTab)
		    _refreshFontNode:setAnchorPoint(ccp(0.5, 0.5))
		    _refreshFontNode:setPosition(ccpsprite(0.5, 0.5, _refreshMenuItem))
		    _refreshMenuItem:addChild(_refreshFontNode)
	    end
		-- 发请求
		BarnService.refreshOwn(nextFunction)
	end

	local tipNode = CCNode:create()
	tipNode:setContentSize(CCSizeMake(550,100))
	-- 第一行
    local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1305",_refreshOwnCost),
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{
	        		type = "CCSprite",
                    image = "images/common/gold.png"
	        	},
	        	{	
	        		type = "CCLabelTTF", 
	        		text =  GetLocalizeStringBy("lic_1306"),
	        		color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font1 = LuaCCLabel.createRichLabel(textInfo1)
 	font1:setAnchorPoint(ccp(0.5, 0.5))
 	font1:setPosition(ccp(tipNode:getContentSize().width*0.5,80))
 	tipNode:addChild(font1)

 	-- 第二行
    local textInfo2 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        linespace = 15, -- 行间距
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1364"),
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font2 = LuaCCLabel.createRichLabel(textInfo2)
 	font2:setAnchorPoint(ccp(0.5, 0.5))
 	font2:setPosition(ccp(tipNode:getContentSize().width*0.5,20))
 	tipNode:addChild(font2)
   
	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,360))
end

--[[
	@des 	:大丰收按钮回调
	@param 	:
	@return :
--]]
function refreshAllMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("refreshAllMenuItemCallback")

    -- 是否可以刷新
    if( _isOpenRefreshAll == false )then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1310",_refreshAllNeedVip))
		return
    end
    -- 是否有刷新次数
    local surplusRefreshAllNum = _refreshAllMaxNum - _alreadyRefreshAllNum
    if(surplusRefreshAllNum <= 0)then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1307"))
		return
    end
    -- 金币不足
	if(UserModel.getGoldNumber() < _refreshAllCost ) then  
		require "script/ui/tip/LackGoldTip"    
		LackGoldTip.showTip()
		return
	end

	-- 确定刷新回调
	local yesBuyCallBack = function ( ... )
		local nextFunction = function ( ... )
			-- 提示 恭喜开启大丰收，军团所有成员已开启粮田的采集次数增加X次
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1380", _refreshAllAddNum ))
	    	-- 扣除金币
	    	UserModel.addGoldNumber(-_refreshAllCost)
	    end
		-- 发请求
		BarnService.refreshAll(1,nextFunction)
	end
	local tipNode = CCNode:create()
	tipNode:setContentSize(CCSizeMake(550,200))
	-- 第一行
    local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1308"),
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{
	        		type = "CCSprite",
                    image = "images/common/gold.png"
	        	},
	        	{
	            	type = "CCLabelTTF", 
	            	text = _refreshAllCost,
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{	
	        		type = "CCLabelTTF", 
	        		text =  GetLocalizeStringBy("lic_1309"),
	        		color = ccc3(0x78,0x25,0x00)
	        	},
	        	{	
	        	 	type = "CCRenderLabel", 
	        		text = GetLocalizeStringBy("lic_1345"),
	        		color = ccc3(0xff,0x00,0xe1)
	        	},
	        	{	
	        	 	type = "CCLabelTTF", 
	        		text = "?",
	        		color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font1 = LuaCCLabel.createRichLabel(textInfo1)
 	font1:setAnchorPoint(ccp(0.5, 0.5))
 	font1:setPosition(ccp(tipNode:getContentSize().width*0.5,190))
 	tipNode:addChild(font1)

 	-- 第二行
    local textInfo2 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        linespace = 15, -- 行间距
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1361"),
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{	
	        	 	type = "CCRenderLabel", 
	        		text = GetLocalizeStringBy("lic_1345"),
	        		color = ccc3(0xff,0x00,0xe1)
	        	},
	        	{	
	        		type = "CCLabelTTF", 
	        		text =  GetLocalizeStringBy("lic_1339",_refreshAllAddNum),
	        		color = ccc3(0x78,0x25,0x00)
	        	},
	        }
	 	}
 	local font2 = LuaCCLabel.createRichLabel(textInfo2)
 	font2:setAnchorPoint(ccp(0.5, 0.5))
 	font2:setPosition(ccp(tipNode:getContentSize().width*0.5,130))
 	tipNode:addChild(font2)
   	
   	-- 第三行
    local textInfo3 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        linespace = 15, -- 行间距
	        elements =
	        {	
	            {
	            	type = "CCRenderLabel", 
	            	text = GetLocalizeStringBy("lic_1402",surplusRefreshAllNum),
	            	color = ccc3(0x00,0xff,0x18)
	        	},
	        }
	 	}
 	local font3 = LuaCCLabel.createRichLabel(textInfo3)
 	font3:setAnchorPoint(ccp(0.5, 0.5))
 	font3:setPosition(ccp(tipNode:getContentSize().width*0.5,70))
 	tipNode:addChild(font3)

   	-- 第四行
    local textInfo4 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        linespace = 10, -- 行间距
	        elements =
	        {	
	            {
	            	type = "CCRenderLabel", 
	            	text = GetLocalizeStringBy("lic_1382"),
	            	color = ccc3(0x00,0xe4,0xff)
	        	},
	        }
	 	}
 	local font4 = LuaCCLabel.createRichLabel(textInfo4)
 	font4:setAnchorPoint(ccp(0.5, 0.5))
 	font4:setPosition(ccp(tipNode:getContentSize().width*0.5,10))
 	tipNode:addChild(font4)
   
	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,440))
end

--[[
	@des 	:小丰收丰收按钮回调
	@param 	:
	@return :
--]]
function smallRefreshAllMenuItemCallback( tag, sender )
	 -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("smallRefreshAllMenuItemCallback")

   	-- 判断官职 军团长 副军团长才能发 0为平民，1为会长，2为副会长
    if( GuildDataCache.getMineMemberType() ~= 1 and GuildDataCache.getMineMemberType() ~= 2 )then  
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1358"))
		return
    end

    -- 是否有小丰收使用次数
    local surplusNum = _useSmallMaxNum - _alreadyUseSmallNum
    if(surplusNum <= 0)then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1359"))
		return
    end
    -- 军团建设度不足
	if(GuildDataCache.getGuildDonate() < _useSmallCost ) then  
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1360"))
		return
	end

	-- 确定刷新回调
	local yesBuyCallBack = function ( ... )
		local nextFunction = function ( ... )
			-- 提示 恭喜开启小丰收，军团所有成员已开启粮田的采集次数增加X次
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1379", _useSmallAddNum ))
	    	-- 扣除军团建设度
	    	GuildDataCache.addGuildDonate(-_useSmallCost)
	    end
		-- 发请求
		BarnService.refreshAll(2,nextFunction)
	end
	local tipNode = CCNode:create()
	tipNode:setContentSize(CCSizeMake(550,200))
	-- 第一行
    local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1362"),
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{
	        		type = "CCSprite",
                    image = "images/common/gong.png"
	        	},
	        	{
	            	type = "CCLabelTTF", 
	            	text = _useSmallCost,
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{	
	        		type = "CCLabelTTF", 
	        		text =  GetLocalizeStringBy("lic_1393"),
	        		color = ccc3(0x78,0x25,0x00)
	        	},
	        	{	
	        	 	type = "CCRenderLabel", 
	        		text = GetLocalizeStringBy("lic_1363"),
	        		color = ccc3(0x00,0xff,0x18)
	        	},
	        	{	
	        	 	type = "CCLabelTTF", 
	        		text = "?",
	        		color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font1 = LuaCCLabel.createRichLabel(textInfo1)
 	font1:setAnchorPoint(ccp(0.5, 0.5))
 	font1:setPosition(ccp(tipNode:getContentSize().width*0.5,190))
 	tipNode:addChild(font1)

 	-- 第二行
    local textInfo2 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        linespace = 15, -- 行间距
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1361",_useSmallCost),
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{	
	        	 	type = "CCRenderLabel", 
	        		text = GetLocalizeStringBy("lic_1363"),
	        		color = ccc3(0x00,0xff,0x18)
	        	},
	        	{	
	        		type = "CCLabelTTF", 
	        		text =  GetLocalizeStringBy("lic_1339",_useSmallAddNum),
	        		color = ccc3(0x78,0x25,0x00)
	        	},
	        }
	 	}
 	local font2 = LuaCCLabel.createRichLabel(textInfo2)
 	font2:setAnchorPoint(ccp(0.5, 0.5))
 	font2:setPosition(ccp(tipNode:getContentSize().width*0.5,130))
 	tipNode:addChild(font2)

 	-- 第三行
    local textInfo3 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        linespace = 15, -- 行间距
	        elements =
	        {	
	            {
	            	type = "CCRenderLabel", 
	            	text = GetLocalizeStringBy("lic_1403",surplusNum),
	            	color = ccc3(0x00,0xff,0x18)
	        	},
	        }
	 	}
 	local font3 = LuaCCLabel.createRichLabel(textInfo3)
 	font3:setAnchorPoint(ccp(0.5, 0.5))
 	font3:setPosition(ccp(tipNode:getContentSize().width*0.5,70))
 	tipNode:addChild(font3)

 	-- 第三行
    local textInfo3 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        linespace = 10, -- 行间距
	        elements =
	        {	
	            {
	            	type = "CCRenderLabel", 
	            	text = GetLocalizeStringBy("lic_1383"),
	            	color = ccc3(0x00,0xe4,0xff)
	        	},
	        }
	 	}
 	local font3 = LuaCCLabel.createRichLabel(textInfo3)
 	font3:setAnchorPoint(ccp(0.5, 0.5))
 	font3:setPosition(ccp(tipNode:getContentSize().width*0.5,10))
 	tipNode:addChild(font3)
   
	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,440))
end


--[[
	@des 	:一键采集按钮回调
	@param 	:
	@return :
--]]
function oneKeyMeunItemCallBack( tag, sender )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --判断背包
    if(ItemUtil.isBagFull() == true )then
        return
    end
    local curLvTab = {}
    -- 没有次数不能使用
    local isReturn = true
    for i=1,_liangtianNum do
    	local isOpen = BarnData.getLiangTianIsOpenById(i)
    	if(isOpen)then
    		-- 开启的粮田的剩余次数
    		local surplusCollectNum,curLv,curAllExp = GuildDataCache.getSurplusCollectNumAndExpLv(i)
    		curLvTab[i] = curLv
    		if(surplusCollectNum > 0 )then 
    			isReturn = false
    		end
    	end
    end
     if( isReturn )then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1565"))
		return
    end

    local nextFunction = function ( p_retData )
    	-- 修改数据
    	for i=1,_liangtianNum do
	    	local isOpen = BarnData.getLiangTianIsOpenById(i)
	    	if(isOpen)then
	    		-- 清空 开启的粮田的剩余次数
    			GuildDataCache.setSurplusCollectNumById(i,0)
	    	end
	    end
    	-- 更新军团获得粮草
    	_guildGrainNum = tonumber(p_retData[1])
    	GuildDataCache.setGuildGrainNum( _guildGrainNum )
    	-- 更新个人获得功勋
    	local addMyMerit = tonumber(p_retData[2]) - _myMeritNum
    	_myMeritNum = tonumber(p_retData[2])
    	GuildDataCache.setMyselfMeritNum( _myMeritNum )

    	-- 刷新UI
    	_guildGrainNumFont:setString( string.formatBigNumber(_guildGrainNum) .. "/" .. string.formatBigNumber(_guildGraninMaxNum) )
    	_gongxunNumFont:setString( string.formatBigNumber(_myMeritNum) )

    	-- 刷新粮田信息
    	for i=1,_liangtianNum do
    		_liangTianSpArr[i]:refreshCallFunc()
    	end

    	 -- 浮动提示
    	local tipSp = CCSprite:create()
    	tipSp:setContentSize(CCSizeMake(600,278))
    	tipSp:setAnchorPoint(ccp(0.5,0.5))
    	local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(tipSp,2000)
	    tipSp:setScale(g_fElementScaleRatio)
	    -- 动画action
		tipSp:setPosition(ccp(runningScene:getContentSize().width*0.5,runningScene:getContentSize().height*0.4))
	    local nextMoveToP = ccp(runningScene:getContentSize().width*0.5,runningScene:getContentSize().height*0.55)
	    -- 设置遍历子节点  透明度
	    tipSp:setCascadeOpacityEnabled(true)
	    local actionArr = CCArray:create()
		actionArr:addObject(CCEaseOut:create(CCMoveTo:create(4, nextMoveToP),1))
		actionArr:addObject(CCFadeOut:create(0.8))
		actionArr:addObject(CCCallFuncN:create(function ( ... )
			tipSp:removeFromParentAndCleanup(true)
			tipSp = nil
		end))
		tipSp:runAction(CCSequence:create(actionArr))

		-- 第一条 采集获得功勋+功勋图标+数量，军团粮仓增加粮草+粮仓粮草图标+数量
		-- 第一行
	    local richInfo = {
     		width = 600, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontPangWa,      -- 默认字体
	        labelDefaultSize = 24,          -- 默认字体大小
	        elements =
	        {	
	        	{
	        		type = "CCRenderLabel",
                    text = GetLocalizeStringBy("lic_1300",tonumber(p_retData[4])),
                    color = ccc3(0xff, 0xf6, 0x00)
	        	},
	        	{
	        		type = "CCSprite",
                    image = "images/common/gongxun.png"
	        	},
	        	{	
	        		type = "CCRenderLabel", 
	        		text = addMyMerit,
	        		color = ccc3(0x00,0xff,0x18)
	        	},
	        	{
	        		type = "CCRenderLabel",
                    text = GetLocalizeStringBy("lic_1301"),
                    color = ccc3(0xff, 0xf6, 0x00)
	        	},
	        	{
	        		type = "CCSprite",
                    image = "images/common/liangcao.png"
	        	},
	        	{	
	        		type = "CCRenderLabel", 
	        		text = tonumber(p_retData[3]),
	        		color = ccc3(0x00,0xff,0x18)
	        	}
	        }
	 	}
	 	local tipDes1 = LuaCCLabel.createRichLabel(richInfo)
	    tipDes1:setAnchorPoint(ccp(0.5,1))
	    tipDes1:setPosition(ccp(tipSp:getContentSize().width*0.5,tipSp:getContentSize().height))
	    tipSp:addChild(tipDes1)

	    local posY = tipSp:getContentSize().height- tipDes1:getContentSize().height -10
	    for k,v in pairs(p_retData[5]) do
		    local richInfo = {
	     		width = 600, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        labelDefaultFont = g_sFontPangWa,      -- 默认字体
		        labelDefaultSize = 24,          -- 默认字体大小
		        elements =
		        {	
		        	{
		        		type = "CCRenderLabel",
	                    text = GetLocalizeStringBy("lic_1566",tonumber(k)),
	                    color = ccc3(0xff, 0xff, 0xff)
		        	},
		        	{
		        		type = "CCSprite",
	                    image = "images/common/exp.png"
		        	},
		        	{	
		        		type = "CCRenderLabel", 
		        		text = "+" .. v[1],
		        		color = ccc3(0x00,0xff,0x18)
		        	}
		        }
		 	}
		 	-- 升级提示
	    	if(curLvTab[tonumber(k)] < tonumber(v[2]))then
		    	local element1 = {}
		    	element1.type = "CCRenderLabel"
		    	element1.text = GetLocalizeStringBy("lic_1567",tonumber(v[2]))
		    	element1.color = ccc3(0xff, 0xff, 0xff)
		    	table.insert(richInfo.elements,element1)
		    end
		 	_tipFont = LuaCCLabel.createRichLabel(richInfo)
		    _tipFont:setAnchorPoint(ccp(0.5,0))
		    posY = posY - 30
		    _tipFont:setPosition(ccp(tipSp:getContentSize().width*0.5,posY))
		    tipSp:addChild(_tipFont)
	    end
	    -- 掉落道具名称 + 图标 + 数量
	    print("p_retData")
	    print_t(p_retData)
	    	-- 道具信息
	    	local propData = p_retData[6] or {}
	    	local propData1 = propData.item or {}
	    	local data = p_retData[5]
	    	local number = table.count(data) 
	    	local posY = tipSp:getContentSize().height- tipDes1:getContentSize().height -10- _tipFont:getContentSize().height *number
	    	for i,data in pairs(propData1) do
	    		-- i 为id ,data 为数量
	    		local itemInfo = DB_Item_normal.getDataById(i) or {}
	    		local imageName = itemInfo.icon_little
	    		local richInfo = {
	     		width = 600, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        labelDefaultFont = g_sFontPangWa,      -- 默认字体
		        labelDefaultSize = 24,          -- 默认字体大小
		        elements =
		        {
		        	{
    					type = "CCRenderLabel",
    					text = GetLocalizeStringBy("fqq_056"),
    					color = ccc3(0xe4, 0x00, 0xff)
    				},
	    		 	{
                        type = "CCRenderLabel",
                        text = itemInfo.name,
                        color = ccc3(0xff, 0xf6, 0x00)
                    },
                    {
                        type = "CCSprite",
                        image = "images/base/props/"..imageName
                    },
                    {
                        type = "CCRenderLabel",
                        text = data,
                        color = ccc3(0x00,0xff,0x18)
                    }
                }
            } 
            local tipFont1 = LuaCCLabel.createRichLabel(richInfo)
		    tipFont1:setAnchorPoint(ccp(0.5,0))
		    posY = posY - 30
		    tipFont1:setPosition(ccp(tipSp:getContentSize().width*0.5,posY))
		    tipSp:addChild(tipFont1)
		    print("tipFont~~~~",tipFont1:getContentSize().height)
	    	end
    end
    -- 发请求
    BarnService.quickHarvest(nextFunction)
end

--------------------------------------------------------- 推送刷新 ----------------------------------------------------
--[[
	@des 	: 刷新挑战书
	@param 	:
	@return :
--]]
function refreshFightBookNum( ... )
	-- 挑战书数量
	if(tolua.cast(_fightBookNumFont,"CCRenderLabel") ~= nil)then
		local fightBookNum = GuildDataCache.getGuildFightBookNum() 
    	local fightBookMaxNum = BarnData.getFightBookMaxNum()
		_fightBookNumFont:setString(fightBookNum .. "/" .. fightBookMaxNum)
	end
end

--[[
	@des 	: 刷新粮草数量
	@param 	:
	@return :
--]]
function refreshGuildGrainNum( ... )
	if(_bgLayer ~= nil)then 
		if(_guildGrainNumFont ~= nil)then
			-- 军团粮草
			_guildGrainNum = GuildDataCache.getGuildGrainNum()
			-- 刷新军团粮草
			_guildGrainNumFont:setString( string.formatBigNumber(_guildGrainNum) .. "/" .. string.formatBigNumber(_guildGraninMaxNum) )
		end
	end
end

--[[
	@des 	: 刷新函数 粮田开启 推送
	@param 	:
	@return :
--]]
function linagTianOpenPushUpdateUI( ... )
	-- 刷新数据
	-- 粮仓等级
	_barnLv = GuildDataCache.getGuildBarnLv()
	-- 军团粮草
	_guildGrainNum = GuildDataCache.getGuildGrainNum()
	-- 升级粮仓所需贡献
	_barnNeedExp = GuildUtil.getLiangCangNeedExpByLv(_barnLv + 1 )

	-- 刷新粮仓等级
	_liangcangLv:setString("Lv." .. _barnLv)
	-- 刷新军团粮草
	_guildGrainNumFont:setString( string.formatBigNumber(_guildGrainNum) .. "/" .. string.formatBigNumber(_guildGraninMaxNum) )
	-- 升级所需贡献值
	local str = nil
	if( _barnLv >= _maxBarnLv)then 
		str = "--"
	else
		str = _barnNeedExp
	end
	_gongxianNumFont:setString(str)

	-- 刷新粮田ui 
	if( not table.isEmpty( _liangTianSpArr ) )then 
		for k,v in pairs(_liangTianSpArr) do
			v:refreshCallFunc()
		end
	end
end

--[[
	@des 	:全部刷新推送 刷新ui函数
	@param 	:
	@return :
--]]
function refreshAllPushUpdateUI( ... )
	-- 修改大丰收已经刷新次数
	_alreadyRefreshAllNum = GuildDataCache.getAlreadyRefreshAllNum()

	-- 修改小丰收已经刷新次数
	_alreadyUseSmallNum = GuildDataCache.getAlreadyUseSmallNum()

	-- 使用小丰收消耗建设度值
	local a,b = nil,nil
	a, b, _useSmallCost = BarnData.getSmallRefreshMaxNum()
	-- 刷新建设度消耗值
	if( tolua.cast(_smallRefreshAllFontNode, "CCNode" ) ~= nil) then
		_smallRefreshAllFontNode:removeFromParentAndCleanup(true)
		_smallRefreshAllFontNode = nil
	end
    local fontTab = {}
    -- 建设度
    local goldIcon = CCSprite:create("images/common/gong.png")
    table.insert(fontTab,goldIcon)
    local goldNumFont = CCRenderLabel:create(_useSmallCost, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    goldNumFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(fontTab,goldNumFont)
    _smallRefreshAllFontNode = BaseUI.createHorizontalNode(fontTab)
    _smallRefreshAllFontNode:setAnchorPoint(ccp(0.5, 0.5))
    _smallRefreshAllFontNode:setPosition(ccpsprite(0.5, -0.15, _smallRefreshAllItem))
    _smallRefreshAllItem:addChild(_smallRefreshAllFontNode)

	-- 刷新粮田ui 
	if( not table.isEmpty( _liangTianSpArr ) )then 
		for k,v in pairs(_liangTianSpArr) do
			v:refreshCallFunc()
			-- 信息界面次数刷新
			LiangTianInfoDialog.refreshCollectNum( k )
		end
	end

	-- 显示大丰收公告
	local userInfo = BarnData.getRefreshAllInfo()
	print("userInfo")
	print_t(userInfo)
	if(not table.isEmpty(userInfo) )then
		if(tolua.cast(_gongGaoSprite,"CCSprite") ~= nil)then
			_gongGaoSprite:removeFromParentAndCleanup(true)
			_gongGaoSprite = nil
		end
		_gongGaoSprite = UseRefreshInfo.createUseRefreshAllSprite()
		if( _gongGaoSprite ~= nil)then
			_gongGaoSprite:setAnchorPoint(ccp(0.5,1))
			_bgLayer:addChild(_gongGaoSprite)
			_gongGaoSprite:setScale(g_fScaleX)
			local posY = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX
			_gongGaoSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))

			local posY = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX-_gongGaoSprite:getContentSize().height*g_fScaleX-85*g_fElementScaleRatio
			_closeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.98,posY))

			_exchangeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.82,_closeMenuItem:getPositionY()))

		else
			local posY = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX-85*g_fElementScaleRatio
			_closeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.98,posY))
			
			_exchangeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.82,_closeMenuItem:getPositionY()))

		end
	end
end

--[[
	@des 	:采集后推送刷新经验和等级 刷新ui函数
	@param 	:
	@return :
--]]
function refreshLvAndExpPushUpdateUI( ... )
	print("---------------------2------------------------")
	print_t(_liangTianLvArr)
	-- 刷新粮田ui 
	if( not table.isEmpty( _liangTianSpArr ) )then 
		local newLvTab = {}
		local upCount = 0
		local posY = {0.58,0.46,0.34,0.22,0.1}
		for k=1,#_liangTianSpArr do
			-- 刷新经验等级
			_liangTianSpArr[k]:refreshCallFunc()

			-- 刷新信息界面的经验条
			LiangTianInfoDialog.refreshProress(k)

			-- 新的等级
			local a,b = nil,nil
			a,newLvTab[k],b = GuildDataCache.getSurplusCollectNumAndExpLv(k)

			-- 如果升级 播放升级特效
			if( newLvTab[k] > _liangTianLvArr[k] )then 
				upCount = upCount + 1
				print("newLvTab[k]",newLvTab[k],"_liangTianLvArr[k]",_liangTianLvArr[k])
				local upAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/guild/liangcang/effect/maitianshengji", 1, CCString:create(""))
		        upAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
		        upAnimSprite:setPosition(ccp(_bgLayer:getContentSize().width*_liangPosX[k],_bgLayer:getContentSize().height*_liangPosY[k]))
		        _bgLayer:addChild(upAnimSprite,300)
		        upAnimSprite:setScale(g_fElementScaleRatio)

		        -- 刷新信息界面的升级信息
				LiangTianInfoDialog.refreshUiForUpgrade(k)

		    	-- local actionArr = CCArray:create()
		    	-- actionArr:addObject(CCDelayTime:create(2.5*upCount))
		    	-- actionArr:addObject(CCCallFunc:create(function ( ... )
		    		-- 弹悬浮框 
		    		local myMerit,guildGrain = BarnData.getLiangTianProduceGrainNum(k, newLvTab[k])
		        	showUpTipUi( k, newLvTab[k], guildGrain, myMerit,0.5,posY[upCount])
		    	-- end))
		    	-- _liangTianSpArr[k]:runAction(CCSequence:create(actionArr))
			end
		end
		-- 更新新的等级信息
		_liangTianLvArr = newLvTab
	end
end

--[[
	@des 	:分完粮后刷新方法
	@param 	:
	@return :
--]]
function refreshUIAfterShare( ... )
	print("refreshUIAfterShare")
	-- 军团粮草
	_guildGrainNum = GuildDataCache.getGuildGrainNum()
	-- 个人粮仓
	_myGrainNum = GuildDataCache.getMyselfGrainNum()
	-- 刷新军团粮草
	_guildGrainNumFont:setString( string.formatBigNumber(_guildGrainNum) .. "/" .. string.formatBigNumber(_guildGraninMaxNum) )
	_myGrainNumFont:setString( string.formatBigNumber(_myGrainNum) )
	-- 分粮后刷新cd
	showShareNextTimeDown()
end

--[[
	@des 	:显示发粮食倒计时
	@param 	:
	@return :
--]]
function showShareNextTimeDown( ... )
	print("showShareNextTimeDown")
	-- 倒计时
	if(_timeFont ~= nil)then
		_timeFont:removeFromParentAndCleanup(true)
		_timeFont = nil
	end
	_timeFont = CCLabelTTF:create("00:00:00", g_sFontName, 18)
	_timeFont:setColor(ccc3(0x00,0xff,0x18))
	_timeFont:setAnchorPoint(ccp(0,0.5))
	_timeFont:setPosition(ccp(_fenFont:getPositionX(),_fenFont:getPositionY()))
	_topBg:addChild(_timeFont)
	-- 下次分粮时间
	_shareNextTime = GuildDataCache.getGuildShareNextTime()
	print("TimeUtil.getSvrTimeByOffset(0)",TimeUtil.getSvrTimeByOffset(0),"_shareNextTime",_shareNextTime)
	if( TimeUtil.getSvrTimeByOffset(0) < _shareNextTime )then
		-- 需要倒计时
		local function showTimeDown ( ... )
			if(_shareNextTime - TimeUtil.getSvrTimeByOffset(0) < 0)then
				_timeFont:stopAllActions()
				_timeFont:setString("00:00:00")
				return
			end
			_timeFont:setString(TimeUtil.getTimeString(_shareNextTime - TimeUtil.getSvrTimeByOffset(0)))

			local actionArray = CCArray:create()
			actionArray:addObject(CCDelayTime:create(1))
			actionArray:addObject(CCCallFunc:create(showTimeDown))
			_timeFont:runAction(CCSequence:create(actionArray))
		end
		showTimeDown()
	end
end
-------------------------------------------------------------------------- 创建ui -----------------------------------------------

--[[
	@des 	:显示升级后提示悬浮框
	@param 	:
	@return :
--]]
function showUpTipUi( p_id, p_lv, p_guildGrain, p_myMerit,p_posX,p_posY)
	-- X号粮田等级提升至X，军团粮草产量提示至粮草图标+这一级粮草数量，个人获得功勋提升至功勋图标+下一级功勋数量
	local richInfo = {}
	richInfo.elements = {}
	local element1 = {}
	element1.type = "CCLabelTTF"
	element1.text = p_id
	table.insert(richInfo.elements,element1)
	local element2 = {}
	element2.type = "CCLabelTTF"
	element2.text = GetLocalizeStringBy("lic_1396")
	table.insert(richInfo.elements,element2)
	local element3 = {}
	element3.type = "CCLabelTTF"
	element3.text = p_lv
	table.insert(richInfo.elements,element3)
	local element4 = {}
	element4.type = "CCLabelTTF"
	element4.text = GetLocalizeStringBy("lic_1397")
	table.insert(richInfo.elements,element4)
	local element5 = {}
	element5.type = "CCSprite"
	element5.image = "images/common/liangcao.png"
	table.insert(richInfo.elements,element5)
	local element6 = {}
	element6.type = "CCLabelTTF"
	element6.text = p_guildGrain
	table.insert(richInfo.elements,element6)

	require "script/ui/tip/RichAnimationTip"
	RichAnimationTip.showTip(richInfo,p_posX,p_posY)
end

--[[
	@des 	:创建挑战书
	@param 	:
	@return :
--]]
function createFightBookUi( ... )
	-- 初始化
	_fightBookNumFont = nil
	-- 挑战书
	local fullRect = CCRectMake(0, 0, 41, 31)
	local insetRect = CCRectMake(17, 10, 10, 7)
	local fightBookBg = CCScale9Sprite:create("images/guild/liangcang/f_bg.png",fullRect,insetRect)
	fightBookBg:setContentSize(CCSizeMake(205,33))

    local fontTab = {}
    fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1283"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[1]:setColor(ccc3(0x00,0xe4,0xff))
    fontTab[2] = CCSprite:create("images/common/zhanshu.png")
    fontTab[3] = CCRenderLabel:create(": ", g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[3]:setColor(ccc3(0x00,0xe4,0xff))
    local tiaozhanFont = BaseUI.createHorizontalNode(fontTab)
    tiaozhanFont:setAnchorPoint(ccp(0,0.5))
	tiaozhanFont:setPosition(ccp(15,fightBookBg:getContentSize().height*0.5))
	fightBookBg:addChild(tiaozhanFont)
	-- 挑战书数量
	_fightBookNumFont = CCRenderLabel:create( GuildDataCache.getGuildFightBookNum() .. "/" .. BarnData.getFightBookMaxNum() , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _fightBookNumFont:setColor(ccc3(0x00,0xe4,0xff))
	_fightBookNumFont:setAnchorPoint(ccp(0,0.5))
	_fightBookNumFont:setPosition(ccp(tiaozhanFont:getPositionX()+tiaozhanFont:getContentSize().width,tiaozhanFont:getPositionY()))
	fightBookBg:addChild(_fightBookNumFont)

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(-500)
	fightBookBg:addChild(menuBar)

	-- 购买挑战书按钮
	local buyMenuItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png","images/common/btn/btn_plus_n.png")
	buyMenuItem:setAnchorPoint(ccp(0, 0.5))
	buyMenuItem:registerScriptTapHandler(buyMenuItemCallback)
	buyMenuItem:setPosition(ccp(fightBookBg:getPositionX()+fightBookBg:getContentSize().width-38,fightBookBg:getContentSize().height * 0.5))
	menuBar:addChild(buyMenuItem)

	-- 购买挑战书按钮 只有军团长和副军团长才能看到
    if( GuildDataCache.getMineMemberType() == 1 or GuildDataCache.getMineMemberType() == 2 )then
    	buyMenuItem:setVisible(true)
    else
    	buyMenuItem:setVisible(false)
    end

	return fightBookBg
end

--[[
	@des 	:创建上半部分ui
	@param 	:
	@return :
--]]
function createTopUI( ... )
	-- 背景
	_topBg = CCScale9Sprite:create("images/formation/topbg.png")
	_topBg:setContentSize(CCSizeMake(640,152))
	_topBg:setAnchorPoint(ccp(0.5,1))
	local posY = _bgLayer:getContentSize().height - _bulletinLayerSize.height
	_topBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))
	_bgLayer:addChild(_topBg)
	_topBg:setScale(g_fScaleX)

	-- 军团粮仓图标
	local titleSp = CCSprite:create("images/guild/liangcang/title.png")
	titleSp:setAnchorPoint(ccp(0,0.5))
	titleSp:setPosition(ccp(20,_topBg:getContentSize().height-32))
	_topBg:addChild(titleSp)

	-- 粮仓等级
	_liangcangLv = CCRenderLabel:create("Lv." .. _barnLv, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_liangcangLv:setColor(ccc3(0xff,0xf6,0x00))
	_liangcangLv:setAnchorPoint(ccp(0,0.5))
	_liangcangLv:setPosition(ccp(titleSp:getPositionX()+titleSp:getContentSize().width,titleSp:getPositionY()))
	_topBg:addChild(_liangcangLv)

--- 军团粮草
	local fontTab1 = {}
    fontTab1[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1284"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab1[1]:setColor(ccc3(0xff,0xff,0xff))
    fontTab1[2] = CCRenderLabel:create(": ", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab1[2]:setColor(ccc3(0xff,0xff,0xff))
    fontTab1[3] = CCSprite:create("images/common/liangcao.png")
    local liangcaoFont = BaseUI.createHorizontalNode(fontTab1)
    liangcaoFont:setAnchorPoint(ccp(0,0.5))
	liangcaoFont:setPosition(ccp(10,_topBg:getContentSize().height-72))
	_topBg:addChild(liangcaoFont)
	-- 粮草数量
	_guildGrainNumFont = CCRenderLabel:create( string.formatBigNumber(_guildGrainNum) .. "/" .. string.formatBigNumber(_guildGraninMaxNum), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_guildGrainNumFont:setColor(ccc3(0x00,0xff,0x18))
	_guildGrainNumFont:setAnchorPoint(ccp(0,0.5))
	_guildGrainNumFont:setPosition(ccp(liangcaoFont:getPositionX()+liangcaoFont:getContentSize().width,liangcaoFont:getPositionY()))
	_topBg:addChild(_guildGrainNumFont)
--- 升级所需贡献
	local fontTab2 = {}
    fontTab2[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1285"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab2[1]:setColor(ccc3(0xff,0xf6,0x00))
    fontTab2[2] = CCRenderLabel:create(": ", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab2[2]:setColor(ccc3(0xff,0xff,0xff))
    fontTab2[3] = CCSprite:create("images/common/gong.png")
    local gongxianFont = BaseUI.createHorizontalNode(fontTab2)
    gongxianFont:setAnchorPoint(ccp(0,0.5))
	gongxianFont:setPosition(ccp(10,liangcaoFont:getPositionY()-liangcaoFont:getContentSize().height*0.5-28))
	_topBg:addChild(gongxianFont)
	-- 贡献值
	local str = nil
	if( _barnLv >= _maxBarnLv)then 
		str = "--"
	else
		str = string.formatBigNumber(_barnNeedExp)
	end
	_gongxianNumFont = CCRenderLabel:create(str, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_gongxianNumFont:setColor(ccc3(0x00,0xff,0x18))
	_gongxianNumFont:setAnchorPoint(ccp(0,0.5))
	_gongxianNumFont:setPosition(ccp(gongxianFont:getPositionX()+gongxianFont:getContentSize().width,gongxianFont:getPositionY()))
	_topBg:addChild(_gongxianNumFont)
--- 个人粮草
	local fontTab3 = {}
    fontTab3[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1286"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab3[1]:setColor(ccc3(0xff,0xff,0xff))
    fontTab3[2] = CCRenderLabel:create(": ", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab3[2]:setColor(ccc3(0xff,0xff,0xff))
    fontTab3[3] = CCSprite:create("images/common/xiaomai.png")
    local geliangcaoFont = BaseUI.createHorizontalNode(fontTab3)
    geliangcaoFont:setAnchorPoint(ccp(0,0.5))
	geliangcaoFont:setPosition(ccp(297,liangcaoFont:getPositionY()))
	_topBg:addChild(geliangcaoFont)
	-- 粮草值
	_myGrainNumFont = CCRenderLabel:create( string.formatBigNumber(_myGrainNum), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_myGrainNumFont:setColor(ccc3(0x00,0xff,0x18))
	_myGrainNumFont:setAnchorPoint(ccp(0,0.5))
	_myGrainNumFont:setPosition(ccp(geliangcaoFont:getPositionX()+geliangcaoFont:getContentSize().width,geliangcaoFont:getPositionY()))
	_topBg:addChild(_myGrainNumFont)
--- 个人功勋值
	local fontTab4 = {}
    fontTab4[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1287"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab4[1]:setColor(ccc3(0xff,0xff,0xff))
    fontTab4[2] = CCRenderLabel:create(": ", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab4[2]:setColor(ccc3(0xff,0xff,0xff))
    fontTab4[3] = CCSprite:create("images/common/gongxun.png")
    local gongxunFont = BaseUI.createHorizontalNode(fontTab4)
    gongxunFont:setAnchorPoint(ccp(0,0.5))
	gongxunFont:setPosition(ccp(297,gongxianFont:getPositionY()))
	_topBg:addChild(gongxunFont)
	-- 功勋值
	_gongxunNumFont = CCRenderLabel:create(string.formatBigNumber(_myMeritNum), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_gongxunNumFont:setColor(ccc3(0x00,0xff,0x18))
	_gongxunNumFont:setAnchorPoint(ccp(0,0.5))
	_gongxunNumFont:setPosition(ccp(gongxunFont:getPositionX()+gongxunFont:getContentSize().width,gongxunFont:getPositionY()))
	_topBg:addChild(_gongxunNumFont)

-- 分发粮饷按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(-420)
	_topBg:addChild(menuBar)

	local fenMenuItem = CCMenuItemImage:create("images/guild/liangcang/fen_n.png","images/guild/liangcang/fen_h.png")
	fenMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	fenMenuItem:registerScriptTapHandler(fenMenuItemCallback)
	fenMenuItem:setPosition(ccp(550,_topBg:getContentSize().height*0.5))
	menuBar:addChild(fenMenuItem)
	-- 分发冷却倒计时
	_fenFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1288"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_fenFont:setColor(ccc3(0x00,0xff,0x18))
	_fenFont:setAnchorPoint(ccp(1,0.5))
	_fenFont:setPosition(ccp(550,fenMenuItem:getPositionY()-fenMenuItem:getContentSize().height*0.5-10))
	_topBg:addChild(_fenFont)

	-- 发粮倒计时
	showShareNextTimeDown()
end

--[[
	@des 	:创建下半部分ui
	@param 	:
	@return :
--]]
function createBottomUI( ... )
	--添加一个描述图片
	local desPicture = CCSprite:create("images/guild/liangcang/zizi.png")
	desPicture:setAnchorPoint(ccp(0,1))
	desPicture:setScale(g_fScaleX)
	desPicture:setPosition(ccp(10,_bgLayer:getContentSize().height-39*g_fScaleX -_topBg:getContentSize().height*g_fScaleX))
	_bgLayer:addChild(desPicture)
	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(-420)
	_bgLayer:addChild(menuBar,10)

	-- 创建返回按钮
	_closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	_closeMenuItem:setAnchorPoint(ccp(1, 0))
	menuBar:addChild(_closeMenuItem)
	_closeMenuItem:registerScriptTapHandler(closeButtonCallback)
	_closeMenuItem:setScale(g_fElementScaleRatio)

	-- 创建兑换按钮
	_exchangeMenuItem = CCMenuItemImage:create("images/guild/liangcang/dui_n.png","images/guild/liangcang/dui_h.png")
	_exchangeMenuItem:setAnchorPoint(ccp(1, 0))
	menuBar:addChild(_exchangeMenuItem)
	_exchangeMenuItem:registerScriptTapHandler(exchangeMenuItemCallback)
	_exchangeMenuItem:setScale(g_fElementScaleRatio)

	-- 大丰收按钮
    _refreshAllMenuItem = CCMenuItemImage:create("images/guild/liangcang/da_n.png","images/guild/liangcang/da_h.png")
    _refreshAllMenuItem:setAnchorPoint(ccp(0.5,0))
    _refreshAllMenuItem:registerScriptTapHandler(refreshAllMenuItemCallback)
    menuBar:addChild(_refreshAllMenuItem)
    _refreshAllMenuItem:setScale(g_fElementScaleRatio)
    _refreshAllMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.11,30*g_fElementScaleRatio))
    -- 大丰收 金币数量
    local fontTab = {}
    -- 金币
    local goldIcon = CCSprite:create("images/common/gold.png")
    table.insert(fontTab,goldIcon)
    local goldNumFont = CCRenderLabel:create(_refreshAllCost, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    goldNumFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(fontTab,goldNumFont)
    local refreshAllFontNode = BaseUI.createHorizontalNode(fontTab)
    refreshAllFontNode:setAnchorPoint(ccp(0.5, 0.5))
    refreshAllFontNode:setPosition(ccpsprite(0.5, -0.15, _refreshAllMenuItem))
    _refreshAllMenuItem:addChild(refreshAllFontNode)

    -- 大丰收按钮只有V8及以上VIP等级的玩家才能看的到，且军团长和副军团长也能看到
    if(_isOpenRefreshAll == true or GuildDataCache.getMineMemberType() == 1 or GuildDataCache.getMineMemberType() == 2 )then
    	_refreshAllMenuItem:setVisible(true)
    else
    	_refreshAllMenuItem:setVisible(false)
    end

    -- 小丰收按钮
    _smallRefreshAllItem = CCMenuItemImage:create("images/guild/liangcang/xiao_n.png","images/guild/liangcang/xiao_h.png")
    _smallRefreshAllItem:setAnchorPoint(ccp(0.5,0))
    _smallRefreshAllItem:registerScriptTapHandler(smallRefreshAllMenuItemCallback)
    menuBar:addChild(_smallRefreshAllItem)
    _smallRefreshAllItem:setScale(g_fElementScaleRatio)
    _smallRefreshAllItem:setPosition(ccp(_bgLayer:getContentSize().width*0.89,30*g_fElementScaleRatio))
    -- 小丰收 建设度数量
    local fontTab = {}
    -- 建设度
    local goldIcon = CCSprite:create("images/common/gong.png")
    table.insert(fontTab,goldIcon)
    local goldNumFont = CCRenderLabel:create(_useSmallCost, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    goldNumFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(fontTab,goldNumFont)
    _smallRefreshAllFontNode = BaseUI.createHorizontalNode(fontTab)
    _smallRefreshAllFontNode:setAnchorPoint(ccp(0.5, 0.5))
    _smallRefreshAllFontNode:setPosition(ccpsprite(0.5, -0.15, _smallRefreshAllItem))
    _smallRefreshAllItem:addChild(_smallRefreshAllFontNode)

    -- 小丰收按钮要做成只有军团长和副军团长才能看到
    if( GuildDataCache.getMineMemberType() == 1 or GuildDataCache.getMineMemberType() == 2 )then
    	_smallRefreshAllItem:setVisible(true)
    else
    	_smallRefreshAllItem:setVisible(false)
    end

	-- 使用全部刷新功能玩家公告
	_gongGaoSprite = UseRefreshInfo.createUseRefreshAllSprite()
	if( _gongGaoSprite ~= nil)then
		_gongGaoSprite:setAnchorPoint(ccp(0.5,1))
		_bgLayer:addChild(_gongGaoSprite)
		_gongGaoSprite:setScale(g_fScaleX)
		local posY = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX
		_gongGaoSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,posY))

		local posY = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX-_gongGaoSprite:getContentSize().height*g_fScaleX-88*g_fElementScaleRatio
		_closeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.98,posY))

		_exchangeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.82,_closeMenuItem:getPositionY()))
		
	else
		local posY = _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX-88*g_fElementScaleRatio
		_closeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.98,posY))

		_exchangeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.82,_closeMenuItem:getPositionY()))

	end

	-- 创建粮田
	for i=1,_liangtianNum do
		local liang = LiangTian:create(i)
		liang:setAnchorPoint(ccp(0.5,0.5))
		liang:setPosition(ccp(_bgLayer:getContentSize().width*_liangPosX[i],_bgLayer:getContentSize().height*_liangPosY[i]))
		_bgLayer:addChild(liang)
		liang:setScale(g_fElementScaleRatio)
		liang:registerScriptCallFunc(liangTianMenuItemCallback)
		-- 根据粮田id储存对象
		_liangTianSpArr[i] = liang
		-- 储存粮田当前等级
		local a = nil
		local b = nil
		a,_liangTianLvArr[i],b = GuildDataCache.getSurplusCollectNumAndExpLv(i)
	end

	print("---------------------1------------------------")
	print_t(_liangTianLvArr)

	-- 购买采集
	local normalSprite  = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSprite:setContentSize(CCSizeMake(200,70))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSprite:setContentSize(CCSizeMake(200,70))
    _refreshMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    _refreshMenuItem:setAnchorPoint(ccp(0.5,0))
    _refreshMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.35, 42*g_fElementScaleRatio))
    _refreshMenuItem:registerScriptTapHandler(refreshOwnMenuItemCallback)
    menuBar:addChild(_refreshMenuItem)
    _refreshMenuItem:setScale(g_fElementScaleRatio)
    local fontTab = {}
    local refreshFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1290"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    refreshFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(fontTab,refreshFont)
    -- 购买采集 金币数量
    local goldNumFont = CCLabelTTF:create(_refreshOwnCost, g_sFontPangWa, 21)
    goldNumFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(fontTab,goldNumFont)
    -- 金币
    local goldIcon = CCSprite:create("images/common/gold.png")
    table.insert(fontTab,goldIcon)
    _refreshFontNode = BaseUI.createHorizontalNode(fontTab)
    _refreshFontNode:setAnchorPoint(ccp(0.5, 0.5))
    _refreshFontNode:setPosition(ccpsprite(0.5, 0.5, _refreshMenuItem))
    _refreshMenuItem:addChild(_refreshFontNode)

    -- 每日可购买采集田次数
    local refreshDes = CCRenderLabel:create(GetLocalizeStringBy("lic_1291"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    refreshDes:setColor(ccc3(0x00, 0xff, 0x18))
    refreshDes:setAnchorPoint(ccp(0,0.5))
    _bgLayer:addChild(refreshDes)
    refreshDes:setScale(g_fElementScaleRatio)
    -- 购买次数
    _refreshOwnNumFont = CCRenderLabel:create(_refreshOwnMaxNum - _alreadyRefreshOwnNum .. "/" .. _refreshOwnMaxNum, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _refreshOwnNumFont:setColor(ccc3(0xff, 0xff, 0xff))
    _refreshOwnNumFont:setAnchorPoint(ccp(0,0.5))
    _bgLayer:addChild(_refreshOwnNumFont)
    _refreshOwnNumFont:setScale(g_fElementScaleRatio)
    local posX = (_bgLayer:getContentSize().width- refreshDes:getContentSize().width*g_fElementScaleRatio - _refreshOwnNumFont:getContentSize().width*g_fElementScaleRatio)*0.5
    refreshDes:setPosition(ccp(posX,20*g_fElementScaleRatio))
    _refreshOwnNumFont:setPosition(ccp(refreshDes:getPositionX()+refreshDes:getContentSize().width*g_fElementScaleRatio,refreshDes:getPositionY()))

    -- 一键采集
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    normalSprite:setContentSize(CCSizeMake(200,70))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
    selectSprite:setContentSize(CCSizeMake(200,70))
    _oneKeyMeunItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    _oneKeyMeunItem:setAnchorPoint(ccp(0.5,0))
    _oneKeyMeunItem:setPosition(ccp(_bgLayer:getContentSize().width*0.67, 42*g_fElementScaleRatio))
    _oneKeyMeunItem:registerScriptTapHandler(oneKeyMeunItemCallBack)
    menuBar:addChild(_oneKeyMeunItem)
    _oneKeyMeunItem:setScale(g_fElementScaleRatio)
    local onekeyFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1564"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    onekeyFont:setColor(ccc3(0xff, 0xf6, 0x00))
    onekeyFont:setAnchorPoint(ccp(0.5,0.5))
    onekeyFont:setPosition(ccpsprite(0.5, 0.5, _oneKeyMeunItem))
    _oneKeyMeunItem:addChild(onekeyFont)

    -- 您当前加入军团未满72小时，无法获得粮草分发
    local joinTime = GuildDataCache.getMyJoinGuildTime()
    local limitTime = BarnData.getShareLimitTime()
    local shareTime = tonumber(joinTime) + limitTime
    local curTime = TimeUtil.getSvrTimeByOffset(0)
    local subTime = shareTime - curTime
    if(subTime > 0)then
    	local limitTipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1589",math.floor(limitTime/3600)), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    limitTipFont:setColor(ccc3(0xff, 0x00, 0x00))
	    limitTipFont:setAnchorPoint(ccp(0.5,0.5))
	    limitTipFont:setPosition(ccp(_bgLayer:getContentSize().width*0.5,120*g_fElementScaleRatio))
	    _bgLayer:addChild(limitTipFont)
	    limitTipFont:setScale(g_fElementScaleRatio)

    	local callFun = function ( ... )
    		if( tolua.cast(limitTipFont,"CCRenderLabel") ~= nil )then 
	    		limitTipFont:removeFromParentAndCleanup(true)
	    		limitTipFont = nil
	    	end
	    end
	    -- 延时Action
	    performWithDelay(_bgLayer,callFun, subTime)
    end

end

--[[
	@des 	:初始化数据
	@param 	:
	@return :
--]]
function initData( ... )
	-- 粮仓等级
	_barnLv = GuildDataCache.getGuildBarnLv()
	
	-- 军团粮草
	_guildGrainNum = GuildDataCache.getGuildGrainNum()
	-- 军团粮草储存上限
	_guildGraninMaxNum = BarnData.getSaveGrainMaxNum(_barnLv)
	-- 个人粮仓
	_myGrainNum = GuildDataCache.getMyselfGrainNum()
	-- 个人功勋值
	_myMeritNum = GuildDataCache.getMyselfMeritNum()
	-- 升级粮仓所需贡献
	_barnNeedExp = GuildUtil.getLiangCangNeedExpByLv(_barnLv + 1 )
	-- 刷新粮田已用次数
	_alreadyRefreshOwnNum = GuildDataCache.getAlreadyRefreshOwnNum() 
	-- 刷新全部已用次数
	_alreadyRefreshAllNum = GuildDataCache.getAlreadyRefreshAllNum()
	-- 刷新粮田次数上限
	_refreshOwnMaxNum = BarnData.getMaxRefreshLiangTianNum()
	-- 刷新自己粮田花费
	if( _alreadyRefreshOwnNum+1 > _refreshOwnMaxNum )then 
		_refreshOwnCost = BarnData.getCurRefreshLiangTianCost( _refreshOwnMaxNum )
	else
		_refreshOwnCost = BarnData.getCurRefreshLiangTianCost( _alreadyRefreshOwnNum + 1 )
	end
	-- 是否开启刷新全部按钮,开启需要vip等级,刷新全部花费,刷新全部次数上限
	_isOpenRefreshAll,_refreshAllNeedVip,_refreshAllCost = BarnData.getIsOpenRefreshAll()
	-- 采集获得的经验
	_collectExp = BarnData.getCollectExp()
	-- 粮田个数
	_liangtianNum = BarnData.getLiangTianAllNum()
	-- 采集花费银币
	_collectCost = BarnData.getCollectCost()
	-- 全部刷新次上限,增加粮田次数
	_refreshAllMaxNum,_refreshAllAddNum	= BarnData.getRefreshAllMaxNumAndAddNum()
	-- 粮仓最大等级
	_maxBarnLv = GuildUtil.getMaxBarnLevel()
	-- 已经使用小丰收次数
	_alreadyUseSmallNum = GuildDataCache.getAlreadyUseSmallNum()
	-- 最大使用小丰收次数，使用小丰收增加的采集次数，使用小丰收消耗建设度值
	_useSmallMaxNum, _useSmallAddNum, _useSmallCost = BarnData.getSmallRefreshMaxNum()
	-- 粮田可以采集的次数上限
	_collectMaxNum = BarnData.getLiangTianCollectMaxNum()

end

--[[
	@des 	:创建军团粮仓主界面
	@param 	:
	@return :
--]]
function createLiangCangLayer( ... )
	-- 初始化
	init()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 隐藏下排按钮
	MainScene.setMainSceneViewsVisible(false, false, true)
	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    _bulletinLayerSize = BulletinLayer.getLayerFactSize()

    -- 粮仓大背景
    _bgSprite = XMLSprite:create("images/guild/liangcang/effect/liangtiancj")
    -- _bgSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild/liangcang/effect/liangtiancj"), -1,CCString:create(""))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 初始化粮仓数据
    initData()

    -- 创建上半部分
	createTopUI()

    -- 拉取谁使用了全部刷新功能
    local nextFunction = function ( ... )
    	-- 创建下半部分
		createBottomUI()
    end
    -- 发请求
	BarnService.getRefreshInfo(nextFunction)

	return _bgLayer
end





























