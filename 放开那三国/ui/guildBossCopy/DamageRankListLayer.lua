-- FileName: DamageRankListLayer.lua 
-- Author: bzx
-- Date: 15-04-02 
-- Purpose: 伤害排行榜

module("DamageRankListLayer", package.seeall)



kAll = 1
kGuild = 2
kGuildCopy = 3

local _layer
local _touchPriority
local _zOrder
local _dialog
local _curType
local _myRankLabel
local _myDamageLabel
local _myAwardLabel
local _bottomTipLabel
local _cellSize
local _rankTableView
local _myRankSprite
local _myProgress

function show( p_touchPriority, p_zOrder )
	_layer = create(p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function init( ... )
	_myRankLabel = nil
	_myDamageLabel = nil
	_myAwardLabel = nil
	_bottomTipLabel = nil
	_cellSize = CCSizeMake(575, 122)
	_rankTableView = nil
	_myRankSprite = nil
	_myProgress = nil
end

function initData( p_touchPriority, p_zOrder )
	_touchPriority = p_touchPriority or -700
	_zOrder = p_zOrder or 100
	_curType = 1
end

function create( p_touchPriority, p_zOrder )
	init()
	initData(p_touchPriority, p_zOrder)
	local dialogInfo = {}
	dialogInfo.size = CCSizeMake(640, 865)
    dialogInfo.priority = _touchPriority - 1
    dialogInfo.swallowTouch = true
    dialogInfo.close = false
    _layer = LuaCCSprite.createDialog_1(dialogInfo)
    _dialog = dialogInfo.dialog
    loadTitle()
    refreshMyRankSprite()
    loadMenu()
    local getRankListCallFunc = function ( ... )
    	loadTableView()
   	end    
   	GuildBossCopyService.getRankList(getRankListCallFunc)
	return _layer
end

function loadTitle( ... )
    -- 排行榜图标
    local title = CCSprite:create("images/match/paihangbang.png")
    _dialog:addChild(title)
    title:setAnchorPoint(ccp(0.5,0.5))
    title:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height))

end

function refreshMyProgress( ... )
	if _curType == kGuildCopy then
		if _myProgress == nil then
			local userInfo = GuildBossCopyData.getUserInfo()
			if userInfo.max_pass_copy == "0" then
				return
			end
		    local groupCopyDb = DB_GroupCopy.getDataById(userInfo.max_pass_copy)
			 -- 进度
		    _myProgress = CCRenderLabel:create(GetLocalizeStringBy("key_3092"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		   	_myProgress:setAnchorPoint(ccp(0,0.5))
		    _myProgress:setPosition(ccp(400, _dialog:getContentSize().height - 90))
		    _dialog:addChild(_myProgress)
		    local nextCopyName = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10060"), groupCopyDb.id, groupCopyDb.des), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			_myProgress:addChild(nextCopyName)
			nextCopyName:setAnchorPoint(ccp(0, 0.5))
			nextCopyName:setPosition(ccpsprite(1, 0.5, _myProgress))
			nextCopyName:setColor(ccc3(0xff, 0xf6, 0x00))
		end
	else
		if _myProgress ~= nil then
			_myProgress:removeFromParentAndCleanup(true)
			_myProgress = nil
		end
	end
end

function refreshMyRankSprite( ... )
	--自己排名
	if _myRankSprite ~= nil then
		_myRankSprite:removeFromParentAndCleanup(true)
	end
    if _curType == kGuildCopy then
    	_myRankSprite = CCSprite:create("images/guild/rank/current_rank.png")
    else
    	_myRankSprite = CCSprite:create("images/match/paiming.png")
    end
	_dialog:addChild(_myRankSprite)
	_myRankSprite:setAnchorPoint(ccp(1, 0.5))
	_myRankSprite:setPosition(ccp(260, _dialog:getContentSize().height - 90))
end

function refreshAwardLabel( ... )
	local myRankInfo = getMyRankInfo()
	local exploitsCount = 0
	if myRankInfo ~= nil then
		local groupCopyRewardDb = GuildBossCopyData.getGroupCopyRewardDb(tonumber(myRankInfo.rank))
		exploitsCount = parseField(groupCopyRewardDb.items, 2)[1][3]
	end
	
	if _myAwardLabel == nil then
		local richInfo = {		
			lineAlignment = 1,
			labelDefaultFont = g_sFontPangWa,
			labelDefaultSize = 21,
			defaultType = "CCRenderLabel",
			elements = {
				{
					["type"] = "CCSprite",
					image = "images/guild_boss_copy/exploits_icon.png",
				},
				{
					text = exploitsCount,
					color = ccc3(0x00, 0xff, 0x18),
					font = g_sFontName,
				}
			}
		}		
		_myAwardLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10092"), richInfo)
		_dialog:addChild(_myAwardLabel)
		_myAwardLabel:setAnchorPoint(ccp(0, 0.5))
		_myAwardLabel:setPosition(ccp(419, _dialog:getContentSize().height - 78))
	end
	_myAwardLabel:setVisible(_curType == kAll)
end

function refreshMyDamage( ... )
	if _curType == kGuildCopy then
		if _myDamageLabel ~= nil then
			_myDamageLabel:removeFromParentAndCleanup(true)
			_myDamageLabel = nil
			return
		end
	end
	if _myDamageLabel == nil then
		_myDamageLabel = CCRenderLabel:create(GetLocalizeStringBy("key_10093"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		_dialog:addChild(_myDamageLabel)
		_myDamageLabel:setAnchorPoint(ccp(0, 0.5))
		local damage = tonumber(GuildBossCopyData.getUserInfo().atk_damage)
		local damageText = nil
		if damage >= 10000 then
			damageText = string.format(GetLocalizeStringBy("key_10094"), math.floor(tonumber(damage) / 10000))
		else
			damageText = tostring(damage)
		end
		local damageValueLabel = CCRenderLabel:create(damageText, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		_myDamageLabel:addChild(damageValueLabel)
		damageValueLabel:setAnchorPoint(ccp(0, 0.5))
		damageValueLabel:setPosition(ccp(_myDamageLabel:getContentSize().width + 5, _myDamageLabel:getContentSize().height * 0.5))
		damageValueLabel:setColor(ccc3(0x00, 0xff, 0x18))
	end
	if _curType == kAll then
		_myDamageLabel:setPosition(ccp(383, _dialog:getContentSize().height - 110))
	elseif _curType == kGuild then
		_myDamageLabel:setPosition(ccp(376, _dialog:getContentSize().height - 90))
	end
end

function refreshBottomTip( ... )
	if _bottomTipLabel == nil then
		_bottomTipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_10095"), g_sFontName, 21)
		_dialog:addChild(_bottomTipLabel)
		_bottomTipLabel:setAnchorPoint(ccp(0.5, 0.5))
		_bottomTipLabel:setPosition(ccp(_dialog:getContentSize().width * 0.5, 126))
		_bottomTipLabel:setColor(ccc3(0x78, 0x25, 0x00))
	end
	_bottomTipLabel:setVisible(_curType == kAll)
end

function getMyRankInfo( ... )
	local rankList = GuildBossCopyData.getRankList()
	local myRankInfo = nil
	if _curType == kAll then
		myRankInfo = rankList.myAll
	elseif _curType == kGuild then
		myRankInfo = rankList.myGuild
	elseif _curType == kGuildCopy then
		myRankInfo = rankList.myGuildCopy
	end
	return myRankInfo
end

function refreshMyRank( ... )
	if _myRankLabel ~= nil then
		_myRankLabel = _myRankLabel:removeFromParentAndCleanup(true)
	end
	local myRankInfo = getMyRankInfo()
	if myRankInfo == nil then
		_myRankLabel = CCLabelTTF:create(GetLocalizeStringBy("key_10096"), g_sFontName, 25)
		_myRankLabel:setColor(ccc3(0x78, 0x25, 0x00))
	else
		_myRankLabel = CCRenderLabel:create(myRankInfo.rank, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		_myRankLabel:setColor(ccc3(0x00, 0xff, 0x18))
	end
	_dialog:addChild(_myRankLabel)
	_myRankLabel:setAnchorPoint(ccp(0, 0.5))
	_myRankLabel:setPosition(ccp(270, _dialog:getContentSize().height - 90))
end

function createItem( p_buttonName, p_color)
	local normal = CCScale9Sprite:create(CCRectMake(35,20,1,1), "images/common/btn/tab_button/btn1_n.png")
	normal:setContentSize(CCSizeMake(175,43))
	local selected = CCScale9Sprite:create(CCRectMake(35,20,1,1), "images/common/btn/tab_button/btn1_h.png")
	selected:setContentSize(CCSizeMake(175,53))
	local disabled = CCScale9Sprite:create(CCRectMake(35,20,1,1), "images/common/btn/tab_button/btn1_h.png")
	disabled:setContentSize(CCSizeMake(175,53))

	local item = CCMenuItemSprite:create(normal, selected, disabled)

	local itemLabel =  CCRenderLabel:create(p_buttonName, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	item:addChild(itemLabel)
	itemLabel:setAnchorPoint(ccp(0.5, 0.5))
	itemLabel:setPosition(ccp(item:getContentSize().width * 0.5, item:getContentSize().height * 0.5))
	itemLabel:setColor( p_color or ccc3(0xff, 0xf6, 0x00))
	return item
end

function loadTableView( ... )
	require "script/utils/BaseUI"
	local tableViewBg = BaseUI.createContentBg(CCSizeMake(575,515))
	_dialog:addChild(tableViewBg)
    tableViewBg:setAnchorPoint(ccp(0.5,0))
    tableViewBg:setPosition(ccp(_dialog:getContentSize().width * 0.5, 151))

    local allItem = createItem(GetLocalizeStringBy("key_10097"))
    local guildItem = createItem(GetLocalizeStringBy("key_10098"))
    local guildCopyItem = createItem(GetLocalizeStringBy("key_10212"))

    local radioData = {
	    touch_priority   = _touchPriority - 1,   	-- 触摸优先级
	    space            = 14,   					-- 按钮间距
	    callback         = tabSelectedCallback,   	-- 按钮回调
	    direction        = 1,   					-- 方向 1为水平，2为竖直
	    defaultIndex     = 1,    					-- 默认选择的index
	    items = {
	        allItem,
	        guildItem,
	        guildCopyItem,
	    }
	}
	local radioMenu = LuaCCSprite.createRadioMenuWithItems(radioData)
	tableViewBg:addChild(radioMenu)
	radioMenu:setAnchorPoint(ccp(0.5, 0))
	radioMenu:setPosition(ccp(tableViewBg:getContentSize().width * 0.5, tableViewBg:getContentSize().height - 1))

    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = _cellSize
        elseif (fn == "cellAtIndex") then
           	r = createCell(a1 + 1)
           	if r == nil then
           		r = CCTableViewCell:create()
           	end
        elseif (fn == "numberOfCells") then
            r = #getCurRankInfo()
        elseif (fn == "cellTouched") then
        elseif (fn == "scroll") then
        else
        end
        return r
    end)

    _rankTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_cellSize.width, tableViewBg:getContentSize().height - 10))
    tableViewBg:addChild(_rankTableView)
    _rankTableView:setAnchorPoint(ccp(0, 0))
    _rankTableView:setPosition(ccp(0, 5))
    _rankTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _rankTableView:setTouchPriority(_touchPriority - 2)

end

function getCurRankInfo( ... )
	local curRankInfo = nil
	if _curType == kAll then
		curRankInfo = GuildBossCopyData.getRankList().all
	elseif _curType == kGuild then
		curRankInfo = GuildBossCopyData.getRankList().guild
	elseif _curType == kGuildCopy then
		curRankInfo = GuildBossCopyData.getRankList().guild_copy
	end
	return curRankInfo
end


function createCell(p_index)
	local rankInfo = getCurRankInfo()[p_index]
	local infos = {
		{
			cellBg = CCSprite:create("images/match/first_bg.png"),
			nameColor = ccc3(0xf9,0x59,0xff),
			rankSprite = CCSprite:create("images/match/one.png")
		},
		{
			cellBg = CCSprite:create("images/match/second_bg.png"),
        	nameColor= ccc3(0x00,0xe4,0xff),
        	rankSprite = CCSprite:create("images/match/two.png")
		},
		{
			cellBg = CCSprite:create("images/match/third_bg.png"),
        	nameColor= ccc3(0xff,0xff,0xff),
        	rankSprite = CCSprite:create("images/match/three.png")
        },
        {
        	cellBg = CCSprite:create("images/match/rank_bg.png"),
        	nameColor = ccc3(0xff,0xfb,0xd9),
        	rankSprite = CCRenderLabel:create(rankInfo.rank, g_sFontPangWa, 50, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    	}
	}
	infos[4].rankSprite:setColor(ccc3(0xff, 0xf6, 0x00))
	local info = infos[tonumber(rankInfo.rank)]
	if info == nil then
		info = infos[4]
	end
	local cell = CCTableViewCell:create()
	cell:setContentSize(_cellSize)
	cell:addChild(info.cellBg)
    info.cellBg:setAnchorPoint(ccp(0.5, 0.5))
    info.cellBg:setPosition(ccpsprite(0.5, 0.5, cell))
    
    cell:addChild(info.rankSprite)
    info.rankSprite:setAnchorPoint(ccp(0.5, 0.5))
    info.rankSprite:setPosition(ccp(53, info.cellBg:getContentSize().height * 0.5))
   
   	if _curType == kAll or _curType == kGuild then
	    --“名”汉字
	    local ming = CCSprite:create("images/match/ming.png")
	    info.cellBg:addChild(ming)
	    ming:setAnchorPoint(ccp(0,0))
	    ming:setPosition(ccp(90,20))

	   
	    --头像
	    local iconBg = CCSprite:create("images/match/head_bg.png")
	    info.cellBg:addChild(iconBg)
	    iconBg:setAnchorPoint(ccp(0,0.5))
	    iconBg:setPosition(ccp(138, info.cellBg:getContentSize().height * 0.5))

	    local iconMenu = BTSensitiveMenu:create()
	    iconBg:addChild(iconMenu)
	    iconMenu:setTouchPriority(_touchPriority - 1)
	    iconMenu:setPosition(ccp(0, 0))

	    require "script/model/utils/HeroUtil"
	    local dressId = nil
	    local genderId = nil
	    if not table.isEmpty(rankInfo.dress) and (rankInfo.dress["1"] ~= nil and tonumber(rankInfo.dress["1"]) > 0) then
	        dressId = rankInfo.dress["1"]
	        genderId = HeroModel.getSex(rankInfo.htid)
	    end

	    --vip 特效
	    local vip = rankInfo.vip or 0
	    local heroIcon = HeroUtil.getHeroIconByHTID(rankInfo.htid, dressId, dressId,vip)
	    local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
	    heroIconItem:setAnchorPoint(ccp(0.5,0.5))
	    heroIconItem:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
	    iconMenu:addChild(heroIconItem, 1, p_index)    
	    heroIconItem:registerScriptTapHandler(userFormationItemFun)

	    -- lv.
	    local lvSprite = CCSprite:create("images/common/lv.png")
	    lvSprite:setAnchorPoint(ccp(0,1))
	    lvSprite:setPosition(ccp(300, info.cellBg:getContentSize().height-10))
	    info.cellBg:addChild(lvSprite)
	    -- 等级
	    local lvStr = rankInfo.level
	    local lvData = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    lvData:setAnchorPoint(ccp(0,1))
	    lvData:setColor(ccc3(0xff, 0xf6, 0x00))
	    lvData:setPosition(ccp(lvSprite:getPositionX()+lvSprite:getContentSize().width+5, info.cellBg:getContentSize().height-4))
	    info.cellBg:addChild(lvData)
	    -- 名字
	    local nameStr = rankInfo.uname
	    local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    name:setColor(info.nameColor)
	    name:setAnchorPoint(ccp(0.5,0))
	    name:setPosition(ccp(341,42))
	    info.cellBg:addChild(name)
	    -- 军团名字
	    if rankInfo.guild_name ~= nil then
	        local guildStr = rankInfo.guild_name
	        local guildname = CCRenderLabel:create(guildStr, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	        guildname:setAnchorPoint(ccp(0.5,0))
	        guildname:setPosition(ccp(341,10))
	        info.cellBg:addChild(guildname)
	    end
	    local richInfo = {
	    	alignment = 3,
	    	lineAlignment = 2,
	    	labelDefaultFont = g_sFontPangWa,
	    	labelDefaultSize = 18,
	    	defaultType = "CCRenderLabel",
	    	elements = {
	    		{	
	    			text = rankInfo.damage,
	    			font = g_sFontName,
	    			color = ccc3(0x00, 0xff, 0x18),
	    		},
	    	}
		}
		if tonumber(rankInfo.damage) >= 10000 then
			richInfo.elements[1].text = string.format(GetLocalizeStringBy("key_10094"), math.floor(tonumber(rankInfo.damage) / 10000))
		end
		if _curType == kAll then
			local groupCopyRewardDb = GuildBossCopyData.getGroupCopyRewardDb(p_index)
			local element = {}
			element.type = "CCSprite"
			element.image = "images/guild_boss_copy/exploits_icon.png"
			table.insert(richInfo.elements, 1, element)
			element = {}
			element.text = parseField(groupCopyRewardDb.items, 2)[1][3]
			element.font = g_sFontName
			element.color = ccc3(0x00, 0xff, 0x18)
			table.insert(richInfo.elements, 2, element)
		end
		local text = nil
		if _curType == kAll then
			text = GetLocalizeStringBy("key_10099")
		else
			text = GetLocalizeStringBy("key_10100")
		end
		local label = GetLocalizeLabelSpriteBy_2(text, richInfo)
		info.cellBg:addChild(label)
		label:setAnchorPoint(ccp(1, 0.5))
		label:setPosition(ccp(_cellSize.width - 20, info.cellBg:getContentSize().height * 0.5))
	else
		-- lv.
	    local lvSprite = CCSprite:create("images/common/lv.png")
	    lvSprite:setAnchorPoint(ccp(0,1))
	    lvSprite:setPosition(ccp(130, info.cellBg:getContentSize().height-10))
	    info.cellBg:addChild(lvSprite)
	    -- 等级
	    local lvStr = rankInfo.guild_level
	    local lvData = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    lvData:setAnchorPoint(ccp(0,1))
	    lvData:setColor(ccc3(0xff, 0xf6, 0x00))
	    lvData:setPosition(ccp(lvSprite:getPositionX()+lvSprite:getContentSize().width+5, info.cellBg:getContentSize().height-4))
	    info.cellBg:addChild(lvData)
	    -- 军团
	    local guild = CCSprite:create("images/guild/rank/guild_font.png")
	    guild:setAnchorPoint(ccp(0,0.5))
	    guild:setPosition(ccp(130, info.cellBg:getContentSize().height-55))
	    info.cellBg:addChild(guild)

	    local guildName = CCRenderLabel:create(rankInfo.guild_name, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    guildName:setAnchorPoint(ccp(0,0.5))
	    guildName:setColor(info.nameColor)
	    guildName:setPosition(ccp(200, guild:getPositionY()))
	    info.cellBg:addChild(guildName)
	    -- 战斗力
	    local fightForceSprite = CCSprite:create("images/guild/rank/total_fight_force.png")
	    info.cellBg:addChild(fightForceSprite)
	    fightForceSprite:setAnchorPoint(ccp(0, 0.5))
	    fightForceSprite:setPosition(ccp(130, 25))

	    local fightForce =  CCRenderLabel:create(rankInfo.fight_force, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightForce:setAnchorPoint(ccp(0, 0.5))
	    fightForce:setPosition(ccp(250, fightForceSprite:getPositionY()))
	    info.cellBg:addChild(fightForce)

	    -- 进度
	    local progress = CCRenderLabel:create(GetLocalizeStringBy("key_3092"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	   	progress:setAnchorPoint(ccp(0,1))
	    progress:setPosition(ccp(470, info.cellBg:getContentSize().height-20))
	    info.cellBg:addChild(progress)

	    local groupCopyDb = DB_GroupCopy.getDataById(rankInfo.max_pass_copy)
	    local nextCopyName = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10060"), groupCopyDb.id, groupCopyDb.des), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		info.cellBg:addChild(nextCopyName)
		nextCopyName:setAnchorPoint(ccp(1, 0.5))
		nextCopyName:setPosition(ccp(550, 30))
		nextCopyName:setColor(ccc3(0xff, 0xf6, 0x00))
	end
    return cell
end

--[[
    @des    :点击user头像回调
    @param  :
    @return :
--]]
function userFormationItemFun(tag)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/chat/ChatUserInfoLayer"
    require "db/DB_Heroes"
    local allInfo  = getCurRankInfo()[tag]
    local uname = allInfo.uname
    local ulevel = allInfo.level
    local power = allInfo.fight_force
    local uid = allInfo.uid
    local uGender = HeroModel.getSex(allInfo.htid)
    local htid = allInfo.htid
    local dressInfo = allInfo.dress
    local hero = DB_Heroes.getDataById(htid)
    local imageFile = hero.head_icon_id
    ChatUserInfoLayer.showChatUserInfoLayer(uname,ulevel,power,"images/base/hero/head_icon/" .. imageFile,uid,uGender,htid,dressInfo,_touchPriority - 10)
end

function tabSelectedCallback( p_tag )
	_curType = p_tag
	if _rankTableView ~= nil then
		_rankTableView:reloadData()
	end
	refreshMyRankSprite()
	refreshMyDamage()
	refreshMyRank()
	refreshAwardLabel()
	refreshBottomTip()
	refreshMyProgress()
end

function loadMenu( ... )
	local menu = CCMenu:create()
	_dialog:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setContentSize(_dialog:getContentSize())
	menu:setTouchPriority(_touchPriority - 5)
	    --关闭按钮
    local colseItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1284"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(colseItem)
    colseItem:setAnchorPoint(ccp(0.5, 0.5))
    colseItem:setPosition(ccp(_dialog:getContentSize().width * 0.5, 70))
    colseItem:registerScriptTapHandler(closeCallback)
end

function closeCallback( ... )
	close()
end

function close( ... )
	if _layer ~= nil then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end