-- Filename：	RankLayer.lua
-- Author：		DJN
-- Date：		2014-9-3
-- Purpose：		排行榜系统


module ("RankLayer", package.seeall)
require "script/ui/rank/RankService"
require "script/ui/rank/RankData"
require "db/DB_Switch"
require "script/model/user/UserModel"

local _bgLayer 
local _buttomLayer = nil     --顶端scrollview的layer
local _topBgSp               --顶端scrollview的背景
local _scrollView             --顶端scrollview
local _mainMenu             
local _oldTag                --记录顶端button选定项
local _tagArray              --保存顶端button tag的数组
local _curTag                --当前选定的tag
local _defaultIndex          --进入页面时默认显示的index
local _topBar                --顶端金币银币
local _userBg                --显示个人排名的背景
local _openMatch
local _openPet
local _openTower

local _ksTagMainMenu 		= 1001
local _tagFightForce        = 2001
local _tagLevel             = 2002
local _tagCopy              = 2003
local _tagPet               = 2004
local _tagGuild             = 2005
local _tagMatch             = 2006
local _tagTower             = 2007
local _tagAren              = 2008
local _touchPriority 
local _ZOrder
local _m_rankTableView
local _rankTabViewInfo = nil
--[[
    @des    :初始化
    @param  :
    @return :
--]]
local function init( )
	_bgLayer= nil
	_buttomLayer= nil
	_topBgSp= nil
	_scrollView= nil
	_mainMenu= nil
	_oldTag = 0
	_tagArray= {}
	_curTag = _tagFightForce   --默认进入时展示战斗力排行
	_defaultIndex = nil
	_touchPriority = nil
    _ZOrder = nil
    _m_rankTableView = nil
    _rankTabViewInfo = nil
    _topBar = nil
    _userBg = nil

 --    if(DB_Switch.getDataById(7).level == nil or tonumber(UserModel.getHeroLevel()) >= tonumber(DB_Switch.getDataById(7).level) )then
	-- 	_openMatch= true
	-- else
	-- 	_openMatch = false
	-- end

	-- if(DB_Switch.getDataById(26).level == nil or tonumber(UserModel.getHeroLevel()) >= tonumber(DB_Switch.getDataById(26).level) )then
	-- 	_openTower= true
	-- else
	-- 	_openTower = false
	-- end	

	-- if(DB_Switch.getDataById(10).level == nil or tonumber(UserModel.getHeroLevel()) >= tonumber(DB_Switch.getDataById(10).level) )then
	-- 	_openPet= true
	-- else
	-- 	_openPet = false
	-- end	
end
--[[
    @des    :触点
    @param  :
    @return :
--]]
function onTouchesHandler( eventType, x, y )
	if(eventType == "began") then
		print("( eventType" , eventType)
		_touchBeganPoint = ccp(x, y)
		return true
	elseif(eventType == "moved") then
	
	else

	end
end

--[[
	@desc :	创建顶部的主角属性栏
	@param:	
	@ret  :
--]]
function createTopBar( ... )
	-- 添加顶部状态栏：战斗力 银币 金币
	local topBar = CCSprite:create("images/hero/avatar_attr_bg.png")

	local fightDesc = CCSprite:create("images/common/fight_value.png")
	fightDesc:setAnchorPoint(ccp(0,0.5))
	fightDesc:setPosition(52,21)
	topBar:addChild(fightDesc)

	-- 战斗力
	require "script/model/user/UserModel"
	local fightNum = CCRenderLabel:create(UserModel.getFightForceValue(), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fightNum:setAnchorPoint(ccp(0,0.5))
	fightNum:setPosition(140,20)
	topBar:addChild(fightNum)

	-- 银币
	-- modified by yangrui at 2015-12-03
	silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)
	silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	silverLabel:setAnchorPoint(ccp(0, 0.5))
	silverLabel:setPosition(ccp(375, 20))
	topBar:addChild(silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0.5))
	_goldLabel:setPosition(ccp(520, 20))
	topBar:addChild(_goldLabel)

	return topBar
end

--[[
	@desc	活动图标
	@para 	none
	@return void
--]]
local function createScrollView( ... )
	print("createScrollView")
	if( _scrollView~= nil ) then
		_scrollView:removeFromParentAndCleanup(true)
		_scrollView=nil
		--topBgSp:removeChildByTag(2000,true)
	end

	local width = 513
	_scrollView = CCScrollView:create()
    _scrollView:setContentSize(CCSizeMake(width, _topBgSp:getContentSize().height))
    _scrollView:setViewSize(CCSizeMake(513, _topBgSp:getContentSize().height))
    _scrollView:setPosition(66,0)
    _scrollView:setTouchPriority(_touchPriority-1)
    _scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _scrollView:setContentOffset(ccp(0,0))
    _topBgSp:addChild(_scrollView,1,2000)

    _mainMenu = BTMenu:create()
	_mainMenu:setPosition(0,0)
	-- mainMenu:setTouchPriority(-299)
	_mainMenu:setScrollView(_scrollView)
	_scrollView:addChild(_mainMenu,1 , _ksTagMainMenu)
	_mainMenu:setStyle(kMenuRadio)
	--local  POTENTIAL_Base = "images/bag/gift/30001.png"
	local count = 0
	local firstItem = nil


	local rankTable = {
	

		{  
		    --战斗力
			rank_name = GetLocalizeStringBy("djn_39"), 
			img= {images_n = "images/rank/force_n.png", images_h = "images/rank/force_h.png",},
			tag= _tagFightForce,
			note_data= {
			    --isOpen决定是否显示
				isOpen= true,	
			},

		},

	

		{
			--等级
			rank_name = GetLocalizeStringBy("djn_40"), 
			img= {images_n = "images/rank/level_n.png", images_h = "images/rank/level_h.png" ,},
			tag= _tagLevel,
			note_data= {
				isOpen= true,	
			},

		},
        
        {
			--军团
			rank_name = GetLocalizeStringBy("djn_44"), 
			img= {images_n = "images/rank/guild_n.png", images_h ="images/rank/guild_h.png",},
		    tag= _tagGuild,
			note_data= {
				isOpen= true,	
			},

		},
		
		{
			--副本
			rank_name = GetLocalizeStringBy("djn_41"), 
			img= {images_n = "images/rank/copy_n.png", images_h ="images/rank/copy_h.png",},
		    tag= _tagCopy,
			note_data= {
				isOpen= true,	
			},

		},

		{
			--比武
			rank_name = GetLocalizeStringBy("djn_42"), 
			img= {images_n = "images/rank/match_n.png", images_h = "images/rank/match_h.png",},
		    tag= _tagMatch,
			note_data= {
	    	  isOpen= true,
			},

		},

		{
			--爬塔
			rank_name = GetLocalizeStringBy("djn_43"), 
			img= {images_n = "images/rank/tower_n.png", images_h ="images/rank/tower_h.png",},
		    tag= _tagTower,
			note_data= {
			   --isOpen = _openTower,
			   isOpen = true,
			},

		},


		{
			--宠物
			rank_name = GetLocalizeStringBy("djn_41"), 
			img= {images_n = "images/rank/pet_n.png", images_h = "images/rank/pet_h.png",},
		    tag= _tagPet,
			note_data= {
			   --isOpen = _openPet,
			   isOpen = true,
			},

		},
		{
			--竞技
			rank_name = GetLocalizeStringBy("djn_45"), 
			img= {images_n = "images/rank/arena_n.png", images_h ="images/rank/arena_h.png",},
		    tag= _tagAren,
			note_data= {
				--isOpen= true,	
				isOpen = true,
			},

		},


	}



	for i=1, #rankTable do
		if( rankTable[i].note_data.isOpen ) then
			-- local img_n = CCSprite:create(rankTable[i].img.images_n)
			-- local img_h = CCSprite:create(rankTable[i].img.images_h)
			-- img_n:setScale(1.2)
			-- img_h:setScale(1.2)
			local img_n = rankTable[i].img.images_n
			local img_h = rankTable[i].img.images_h
			local menuItem = CCMenuItemImage:create(img_n , img_h)
			local normal = menuItem:getNormalImage()
			normal:setAnchorPoint(ccp(0.5,0.5))
			normal:setPosition(ccpsprite(0.5,0.5,menuItem))
			local selected = menuItem:getSelectedImage()
			selected:setAnchorPoint(ccp(0.5,0.5))
			selected:setPosition(ccpsprite(0.5,0.5,menuItem))
			menuItem:setScale(0.85)
			_mainMenu:addChild(menuItem)
			menuItem:ignoreAnchorPointForPosition(false)
			menuItem:setAnchorPoint(ccp(0.5,0.5))
			
			menuItem:setPosition(ccp(60+120*count , _scrollView:getContentSize().height/2))
			menuItem:registerScriptTapHandler(touchButton)
			menuItem:setTag(rankTable[i].tag )
			
			print("rankTable[i] name  is " , rankTable[i].rank_name )

			count = count + 1
			-- if(firstItem == nil)then
			-- 	firstItem = menuItem
			-- end
		end 
	end

	print("_defaultIndex = ",_defaultIndex)
	if(_defaultIndex == nil)then
		_defaultIndex = _curTag
	end
	local menuItem = tolua.cast(_mainMenu:getChildByTag(_defaultIndex),"CCMenuItemImage") 
	menuItem:selected()
	-- print("menuItem获取tag")
	-- print(menuItem:getTag())
	touchButton(menuItem:getTag())
	updateScrollViewContainerPosition(menuItem,0.1)


	-- elseif(firstItem ~= nil)then
	-- 	print("+===== =================  ")
	-- 	firstItem:selected()
	-- 	touchButton(firstItem:getTag())
	-- end
	if(count >= 4)then
        print("count > 3")
    	_scrollView:setContentSize(CCSizeMake(120 * count,  _topBgSp:getContentSize().height-50))
    end
end
--[[
	@des:	更新scrollView位置
]]
function updateScrollViewContainerPosition( selectNode,time)

	local posX = selectNode:getPositionX() - _scrollView:getViewSize().width/2
	local lnx,px,vw = 0,selectNode:getPositionX(),_scrollView:getViewSize().width
	if(px+ selectNode:getContentSize().width< vw ) then
		lnx = 0
	else
		lnx = px - vw*0.5 + selectNode:getContentSize().width/2
		if(lnx > px + selectNode:getContentSize().width  - vw) then
			lnx = px + selectNode:getContentSize().width - vw
		end
	end
	_scrollView:setContentOffsetInDuration(ccp(-lnx, 0), time or 0.5)
end
--[[
	@des:按钮回调
]]
function touchButton( tag )
	
	local call_back = function()
		_m_rankTableView:cleanup()
		_curTag = tag
		--print("刷新界面")
        --用于获取排名数据后判断是否有排名数据及刷新tableView
		if(table.count(_rankTabViewInfo) == 0 )then
			-- print("检测到列表为空，输出一次列表")
			-- print_t(_rankTabViewInfo)
	        --提示暂无排名
			AnimationTip.showTip(GetLocalizeStringBy("key_3175"))
		end
		if(_userBg ~= nil)then
			_userBg:removeFromParentAndCleanup(true)
	
		end
			
		--AnimationTip.showTip("刷新userbg")
		--_userBg = CCScale9Sprite:create("images/common/bg/bg_9s_1.png")
		--_userBg:setContentSize(CCSizeMake(500,90))
		_userBg = RankCell.createUserBg(_curTag)
		_userBg:setScale(g_fScaleX)
		_userBg:setAnchorPoint(ccp(0.5,1))
		_userBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-_topBar:getContentSize().height*g_fScaleX-137*g_fScaleX))
	    _bgLayer:addChild(_userBg,_ZOrder+1)

		_m_rankTableView:reloadData()
	    --print("刷新了table数据")
	  
	end
	
	if(_m_rankTableView == nil)then
		--创建tablevieww
		--默认进来显示_curTag的排行，拉一次数据，防止UI并行创建的时候数据为空
	        RankService.getFightForceInfo(function ( ... )
	    	--RankService.getPetInfo(function ( ... )
	    	--RankService.getGuildInfo(function ( ... )
	        _rankTabViewInfo = RankData.getRankListData(_curTag) or {}
	        createRankTabView()
	        call_back()
	    end)
    else
    	-- 音效
	    require "script/audio/AudioUtil"
	    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    	if(_curTag == tag)then
			return
	    end
		require "script/ui/tip/AnimationTip"
		
	    
	    -- print("当前选定的tag")
	    -- print(_curTag)

		if(tag == _tagFightForce)then
			--战力
			--AnimationTip.showTip("fightforce")

			RankService.getFightForceInfo(function ()
	            _rankTabViewInfo = RankData.getRankListData(tag) or {}
			    -- print("++++++++++战斗力数据")
			    -- print_t(_rankTabViewInfo)
			    -- print("++++++++战斗力数据结束")
	            call_back()
	        end)
	    elseif(tag == _tagLevel)then
			--等级
			--AnimationTip.showTip("level")

			RankService.getLevelInfo(function ()
	            _rankTabViewInfo = RankData.getRankListData(tag) or {}
			    -- print("++++++++++等级数据")
			    -- print_t(_rankTabViewInfo)
			    -- print("++++++++等级数据结束")
	            call_back()
	            
	        end)

		elseif(tag == _tagMatch)then
			--比武
			--AnimationTip.showTip("match")

		   -- if(DB_Switch.getDataById(7).level == nil or tonumber(UserModel.getHeroLevel()) >= tonumber(DB_Switch.getDataById(7).level) )then
		   if(DataCache.getSwitchNodeState(ksSwitchContest))then
		    	RankService.getMatchUserInfo(function ()
	            --_rankTabViewInfo = RankData.getRankListData(_curTag) or {}
			    
				    RankService.getMatchInfo(function ()
	                    _rankTabViewInfo = RankData.getRankListData(tag) or {}
	       --              print("++++++++++比武数据")
				    -- print_t(_rankTabViewInfo)
				    -- print("++++++++比武数据结束")
				    	call_back()
				    end)
			    
				end)
				
			else
				--AnimationTip.showTip(GetLocalizeStringBy("djn_54")..DB_Switch.getDataById(7).level..GetLocalizeStringBy("djn_55"))
			end
			        
	        

		elseif(tag == _tagTower) then
			--AnimationTip.showTip("tower")
			--爬塔
			--if(DB_Switch.getDataById(26).level == nil or tonumber(UserModel.getHeroLevel()) >= tonumber(DB_Switch.getDataById(26).level) )then
			if(DataCache.getSwitchNodeState(ksSwitchTower))then
				RankService.getTowerInfo(function ()
		            _rankTabViewInfo = RankData.getRankListData(tag) or {}
				    -- print("++++++++++爬塔数据")
				    -- print_t(_rankTabViewInfo)
				    -- print("++++++++爬塔数据结束")
				   
		        	call_back()
	        	end)
			else
				--AnimationTip.showTip(GetLocalizeStringBy("djn_54")..DB_Switch.getDataById(26).level..GetLocalizeStringBy("djn_55"))
			end	
			  

			
		elseif(tag== _tagGuild) then
			--AnimationTip.showTip("guild")
			--军团
			RankService.getGuildInfo(function ()
	            _rankTabViewInfo = RankData.getRankListData(tag) or {}
	      --   	print("++++++++++军团数据")
			    -- print_t(_rankTabViewInfo)
			    -- print("++++++++军团数据结束")
			    call_back()
	        end)  
	        	
			
		elseif(tag== _tagCopy) then
			--AnimationTip.showTip("copy")
			--副本
			--print("发送副本请求")
			RankService.getCopyInfo(function ()
	            _rankTabViewInfo = RankData.getRankListData(tag) or {}
			    -- print("++++++++++副本数据")
			    -- print_t(_rankTabViewInfo)
			    -- print("++++++++f副本数据结束")
			    -- print("请求成功，刷新数据ß")
			    call_back()
	        end)
	    elseif(tag== _tagPet) then
			--AnimationTip.showTip("pet")
			--宠物
			if(DataCache.getSwitchNodeState(ksSwitchPet))then
			--if(DB_Switch.getDataById(10).level == nil or tonumber(UserModel.getHeroLevel()) >= tonumber(DB_Switch.getDataById(10).level) )then
				RankService.getPetInfo(function ()
		            _rankTabViewInfo = RankData.getRankListData(tag) or {}
				    -- print("++++++++++宠物数据")
				    -- print_t(_rankTabViewInfo)
				    -- print("++++++++宠物数据结束")
			    	call_back()
	        	end)
			else
				--AnimationTip.showTip(GetLocalizeStringBy("djn_54")..DB_Switch.getDataById(10).level..GetLocalizeStringBy("djn_55"))
			end
			
	    elseif(tag== _tagAren) then
			--AnimationTip.showTip("aren")
			--竞技场
			RankService.getArenaUserInfo(function ()
	 
			    RankService.getArenInfo(function ()
			    	_rankTabViewInfo = RankData.getRankListData(tag) or {}
				    -- print("++++++++++竞技场数据======================")
				    -- print_t(_rankTabViewInfo)
				    -- print("++++++++竞技数据结束======================")
			    	call_back()
			    end)
			    
	        end)

		end

		-- if(table.count(_rankTabViewInfo) == 0 )then
		-- 	print("检测到列表为空，输出一次列表")
		-- 	print_t(_rankTabViewInfo)
	 --        --提示暂无排名
		-- 	AnimationTip.showTip(GetLocalizeStringBy("key_3175"))
		-- end
		-- _m_rankTableView:reloadData()
	 --    print("刷新了table数据")
	end
	
end

--[[
    @des    :创建排行榜tabelView
    @param  :
    @return :
--]]
function createRankTabView( ... )

    -- 显示单元格背景的size
    local cell_bg_size = { width = g_winSize.width, height = 125*g_fScaleX } 
    -- 得到列表数据
    require "script/ui/rank/RankCell"
    --require "script/ui/main/MainScene"
    --local cellnum = table.count(_rankTabViewInfo)
    
   
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        --local tabViewInfo = table.hcopy(_rankTabViewInfo,{})
        local cellnum = #_rankTabViewInfo
        if (fn == "cellSize") then
            r = CCSizeMake(cell_bg_size.width , cell_bg_size.height)
        elseif (fn == "cellAtIndex") then
            --a2 = RankCell.createCell(_rankTabViewInfo[a1+1],_curTag)
            a2 = RankCell.createCell(_rankTabViewInfo[a1+1],a1+1)
            r=a2
        elseif (fn == "numberOfCells") then
            r = cellnum
        elseif (fn == "cellTouched") then
        
        elseif (fn == "scroll") then
        
        else
        end
        return r
    end)

    _m_rankTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_bgLayer:getContentSize().width-5,
    	               _bgLayer:getContentSize().height-_topBar:getContentSize().height*g_fScaleX-_topBgSp:getContentSize().height*g_fScaleX-60*g_fScaleX))
    --_m_rankTableView:setScale(g_fScaleX)
    _m_rankTableView:setBounceable(true)
    _m_rankTableView:setAnchorPoint(ccp(0,1))
    _m_rankTableView:ignoreAnchorPointForPosition(false)
    _m_rankTableView:setPosition(ccp(5,
    	               _bgLayer:getContentSize().height-_topBar:getContentSize().height*g_fScaleX-_topBgSp:getContentSize().height*g_fScaleX-50*g_fScaleX))
    _bgLayer:addChild(_m_rankTableView,_ZOrder+10)
    -- 设置单元格升序排列
    _m_rankTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    _m_rankTableView:setTouchPriority(_touchPriority-1)
end


--[[
    @des    :UI函数
    @param  :进入时默认显示的index项
    @return :
--]]
function createLayer( index )
	--count = 0
	if(index ~= nil)then
		_defaultIndex = index
    end
	----------------------------------------------
    --_bgLayer:registerScriptHandler(onNodeEvent)
    require "script/ui/main/BulletinLayer"
    require "script/ui/main/MainScene"
    require "script/ui/main/MenuLayer"

    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    -- local avatarLayerSize = MainScene.getAvatarLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
    local layerSize = {}
    -- 层高等于设备总高减去“公告层”，“avatar层”，GetLocalizeStringBy("key_2785")高
    layerSize.height =  g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX
    layerSize.width = g_winSize.width

    _bgLayer:setContentSize(CCSizeMake(layerSize.width, layerSize.height))
    _bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
    --_bgLayer:setScale(g_fScaleX)

    local ccSpriteBg = CCSprite:create("images/main/module_bg.png")
    -- ccSpriteBg:setScale(g_fBgScaleRatio)
    ccSpriteBg:setAnchorPoint(ccp(0.5, 0.5))
    ccSpriteBg:setPosition(ccp(layerSize.width/2, layerSize.height/2))
    ccSpriteBg:setScale(g_fScaleX)
    _bgLayer:addChild(ccSpriteBg,_ZOrder)
    
    --设置显示公告层和avatar层
    MainScene.getAvatarLayerObj():setVisible(false)
    MenuLayer.getObject():setVisible(true)
    BulletinLayer.getLayer():setVisible(true)

    --顶端金币银币
	_topBar = createTopBar()
	_topBar:setAnchorPoint(ccp(0.5,1))
	_topBar:setPosition(ccp(layerSize.width*0.5 ,layerSize.height-3))
	_topBar:setScale(g_fScaleX)
	_bgLayer:addChild(_topBar,_ZOrder+1)
    
	--scrollView背景	
	--local winHeight = CCDirector:sharedDirector():getWinSize().height
	_topBgSp = CCScale9Sprite:create("images/formation/topbg.png")
	-- local myScale = bgLayer:getContentSize().width/topBgSp:getContentSize().width/bgLayer:getElementScale()
	_topBgSp:setAnchorPoint(ccp(0.5,1))
	--topBgSp:setPosition(ccp(CCDirector:sharedDirector():getWinSize().width/2, winHeight - BulletinLayer.getLayerHeight()*g_fScaleX))
	_topBgSp:setPosition(ccp(layerSize.width*0.5 ,layerSize.height-3-_topBar:getContentSize().height*g_fScaleX))
	_bgLayer:addChild(_topBgSp, _ZOrder+1)
	if(g_fScaleX ~= 0)then
		_topBgSp:setContentSize(CCSizeMake(layerSize.width/g_fScaleX,140))
	else
		_topBgSp:setContentSize(CCSizeMake(layerSize.width,140))
    end
	_topBgSp:setScale(g_fScaleX)
	
     
    local topMenuBar = CCMenu:create()
    topMenuBar:setPosition(ccp(0, 0))
    _topBgSp:addChild(topMenuBar)

	--左右翻页的按钮
	require "script/ui/common/LuaMenuItem"
	--左按钮
	local leftBtn = LuaMenuItem.createItemImage("images/formation/btn_left.png",  "images/formation/btn_left.png", topMenuItemAction )
	leftBtn:setAnchorPoint(ccp(0.5, 0.5))
	--leftBtn:setScale(g_fScaleX)
	leftBtn:setPosition(ccp(_topBgSp:getContentSize().width*0.06, _topBgSp:getContentSize().height/2))
	topMenuBar:addChild(leftBtn, 10001, 10001)
	-- 右按钮
	local rightBtn = LuaMenuItem.createItemImage("images/formation/btn_right.png",  "images/formation/btn_right.png", topMenuItemAction )
	rightBtn:setAnchorPoint(ccp(0.5, 0.5))
	--rightBtn:setScale(g_fScaleX)
	rightBtn:setPosition(ccp(_topBgSp:getContentSize().width*0.94, _topBgSp:getContentSize().height/2))
	topMenuBar:addChild(rightBtn, 10002, 10002)

	-- --创建tablevieww
	-- --默认进来显示_curTag的排行，拉一次数据，防止UI并行创建的时候数据为空
 --    RankService.getGuildInfo(function ( ... )
 --        --print("+++++++++++++++++++++++++kaishidiaoshuju")
 --        _rankTabViewInfo = RankData.getRankListData(_curTag) or {}
 --        -- print("+++++++++++++++++++++++diaowanshuju")
 --        createRankTabView()
 --    end)
    --顶端滑动scrollview
	createScrollView()
	_buttomLayer = CCLayer:create()
	_buttomLayer:setScale(g_fScaleX)
	_buttomLayer:setPosition(ccp(0,0))
	_buttomLayer:registerScriptTouchHandler(onTouchesHandler)
	_buttomLayer:setTouchEnabled(true)
	_bgLayer:addChild(_buttomLayer)

    --个人排名下面那条线
	local line = CCSprite:create("images/common/separator_top.png")
	line:setScale(g_fScaleX)
	line:setPosition(ccp(0,_bgLayer:getContentSize().height-_topBar:getContentSize().height*g_fScaleX-_topBgSp:getContentSize().height*g_fScaleX-62*g_fScaleX))
	_bgLayer:addChild(line,_ZOrder+1)

	-- _userBg = CCScale9Sprite:create("images/common/bg/bg_9s_1.png")
	-- _userBg:setContentSize(CCSizeMake(500,90))
	-- _userBg:setScale(g_fScaleX)
	-- _userBg:setAnchorPoint(ccp(0.5,1))
	-- _userBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-_topBar:getContentSize().height*g_fScaleX-70))
 --    _bgLayer:addChild(_userBg,_ZOrder+1)
	

end
--[[
    @des    :获得touchpriority
    @param  :
    @return :
--]]
function getTouchPriority( ... )
	return _touchPriority
end
--[[
    @des    :获得列表数据
    @param  :
    @return :
--]]
function getTabViewInfo( ... )
	return _rankTabViewInfo
end
--[[
    @des    :返回_curTag
    @param  :
    @return :
--]]
function getCurTag( ... )
	return _curTag
end
--[[
    @des    :入口函数
    @param  :进入时默认显示的index项
    @return :
--]]
function showLayer(index,p_touchPriority,p_ZOrder)
	
	init()
	_touchPriority = p_touchPriority or -550
	_ZOrder = p_ZOrder or 999
    _bgLayer = CCLayer:create()
	-- _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	-- _bgLayer:registerScriptHandler(onNodeEvent)
	--local curScene = CCDirector:sharedDirector():getRunningScene()
    --curScene:addChild(_bgLayer,_ZOrder)

    createLayer(index)
      
	return _bgLayer

end

