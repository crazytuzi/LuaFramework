-- Filename：	GuildMainLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-12-20
-- Purpose：		军团主界面

module ("GuildMainLayer", package.seeall)

require "script/ui/battlemission/MissionData"
require "script/ui/guild/GuildBottomSprite"
require "script/ui/guild/GuildUtil"
require "script/ui/guild/GuildBuildingItem"
require "script/ui/guild/UpgradeAlertTip"
require "db/DB_Legion_feast"
require "db/DB_Legion_shop"
require "db/DB_Legion_copy"
require "db/DB_Corps_quest_config"
require "db/DB_Legion_granary"
require "script/ui/guild/city/CityData"
require "script/ui/battlemission/MissionService"
require "script/ui/guild/GuildDataCache"
------------------------------------------- added by bzx
-- require "script/ui/guild/city/CityData"

local CityFireStatus = {
    sign_up     = 1,
    fighting    = 2,
    reward      = 3
}
local _city_fire_status_tag     = nil           -- 城池争夺下面显示的状态
local _timer_refresh_status     = nil
-------------------------------------------


Tag_Hall 		= 2001 -- 军团大厅/忠义堂
Tag_Guanyu 		= 2002 -- 关公殿
Tag_Shop 		= 2003 -- 军团商城
Tag_LiangCang 	= 2004 -- 粮仓
Tag_Book 		= 2005 -- 军团书院
Tag_Military	= 2006 -- 军机大厅
Tag_Science 	= 2007 -- 科技大厅



local va_hall_index 		= 1 	-- 公告等信息的下标
local va_guildHall_index 	= 2 	-- 军团大厅的下标
local va_guanyu_index 		= 3 	-- 关公殿的下标
local va_shop_index 		= 4 	-- 商店的下标
local va_military_index 	= 5 	-- 军机大厅下标
local va_book_index			= 6     -- 军团任务下标
local va_liangcang_index	= 7     -- 军团粮仓下标
local va_science_index		= 8     -- 军团粮仓下标

local buildingPosArr 		= {} 	-- 建筑的坐标



local _bgLayer 			= nil
local _noticeLabel		= nil 	-- 公告


local _hallLvLabel		= nil 	-- 军团等级
local _guanyuLvLabel	= nil 	-- 关公殿等级
local _shopLvLabel 		= nil 	-- 商店等级
local _militaryLvLabel 	= nil 	-- 军机大厅等级
local _liangcangLvLabel = nil   -- 粮仓等级


local _guildInfo 		= nil 	-- 军团信息
local _sigleGuildInfo 	= nil 	-- 个人在军团中的信息

local _guildNameLabel 	= nil 	-- 军团名称
local _sigleDonateLabel	= nil 	-- 个人贡献
local _guildDonateLabel = nil 	-- 军团贡献
local _memberNumLable 	= nil 	-- 成员


local sigleDonateSprite = nil 	-- 个人贡献
local memberSprite 		= nil 	-- 成员
local guildSprite 		= nil 	-- 军团贡献

local _bottomSpite 		= nil 	-- 底部
local b_Sprite 			= nil 	-- 黑色的底


local _upgradeHallItem 		= nil 	-- 军团大厅升级按钮
local _upgradeGuanyuItem 	= nil 	-- 关公殿升级按钮
local _upgradeShopItem 		= nil 	-- 商城升级按钮
local _upgradeMilitaryItem 	= nil 	-- 军机大厅升级按钮
local _upgradeLiangcangItem = nil   -- 粮仓升级按钮
local _upgradeBookItem 		= nil   -- 军团任务大厅升级按钮

local cityFireItem 			= nil   -- 城战按钮
local tipSprite 			= nil 	-- 提示按钮

local timesInfo 			= nil   -- 时间表
local _barnItem	 			= nil   -- 粮仓建筑按钮
local mainMenuBar 			= nil   -- 按钮
local _guildIcon 			= nil   -- 军团图标

local _scrollView 			= nil
local _contentLayer 		= nil
local _bgSprite  			= nil
local _topSprite 			= nil

local _touchPriority 		= -200

local function init()
	_bgLayer 			= nil
	_noticeLabel		= nil

	_hallLvLabel		= nil
	_guanyuLvLabel		= nil
	_shopLvLabel 		= nil 	-- 商店等级
	_liangcangLvLabel 	= nil
	_militaryLvLabel 	= nil

	_guildInfo 			= nil

	buildingPosArr 		= {} 	-- 建筑的坐标

	_bottomSpite 		= nil

	_guildNameLabel 	= nil
	_sigleDonateLabel	= nil
	_guildDonateLabel 	= nil
	_memberNumLable 	= nil
	_sigleGuildInfo 	= nil

	_upgradeHallMenu	= nil
	_upgradeGuanyuMenu 	= nil

	_upgradeHallItem 	= nil 	-- 军团大厅升级按钮
	_upgradeGuanyuItem 	= nil 	-- 关公殿升级按钮
	_upgradeShopItem 	= nil 	-- 商城升级按钮
	_upgradeLiangcangItem = nil
	_upgradeBookItem      = nil
	_upgradeMilitaryItem  = nil

	sigleDonateSprite 	= nil 	-- 个人贡献
	memberSprite 		= nil 	-- 成员
	guildSprite 		= nil 	-- 军团贡献
	b_Sprite 			= nil 	-- 黑色的底

    _city_fire_status_tag   = nil

    _citys_report           = {}

	cityFireItem 		= nil   -- 城战按钮
	_barnItem	 		= nil
	mainMenuBar 		= nil 
	_guildIcon 			= nil

	_scrollView 		= nil
	_contentLayer 		= nil
	_bgSprite  			= nil
	_topSprite 			= nil
end


--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		GuildDataCache.setIsInGuildFunc(true)
	elseif (event == "exit") then
		GuildDataCache.setIsInGuildFunc(false)
        timerRefreshStatusEnd()
	end
end

--[[
	@des 	: 刷新军团图标
--]]
function refreshGuildIcon()
	if(_bgLayer == nil)then
		return
	end

	if(_guildIcon ~= nil)then
		_guildIcon:removeFromParentAndCleanup(true)
		_guildIcon = nil
	end
	local b_Sprite_size = b_Sprite:getContentSize()
	-- 军团图标
	local guildId = GuildDataCache.getGuildIconId()
	if(guildId ~= nil)then
		_guildIcon = GuildUtil.getGuildIcon(guildId)
	    _guildIcon:setAnchorPoint(ccp(0.5, 0))
	    _guildIcon:setPosition(ccp(b_Sprite_size.width*0.1,0))
	    b_Sprite:addChild(_guildIcon)
	    _guildIcon:setScale(_guildIcon:getScale()*0.7)
	end
end

-- 粮仓开启推送 刷新粮仓
function refreshBarnBuildingUI( ... )
	-- 刷新建筑按钮
	if( tolua.cast(_barnItem,"CCMenuItemSprite") ~= nil )then
		_barnItem:removeFromParentAndCleanup(true)
		_barnItem = nil
	end
	_barnItem = GuildBuildingItem.createBuildingItemBy(Tag_LiangCang)
	_barnItem:setAnchorPoint(ccp(0.5, 0.5))
	_barnItem:registerScriptTapHandler(buildingAction)
	_barnItem:setPosition(buildingPosArr[Tag_LiangCang].x, buildingPosArr[Tag_LiangCang].y)
	mainMenuBar:addChild(_barnItem, 1, Tag_LiangCang)

	-- 粮仓标题
	local liangcangTitleSprite = CCSprite:create("images/guild/title_liangcang.png")
	liangcangTitleSprite:setAnchorPoint(ccp(0.5, 0))
	liangcangTitleSprite:setPosition(ccp(70, _barnItem:getContentSize().height))
	_barnItem:addChild(liangcangTitleSprite)
	-- 粮仓等级
	_liangcangLvLabel = CCRenderLabel:create("Lv.99", g_sFontPangWa, 18, 1, ccc3(0,0,0), type_stroke)
	_liangcangLvLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_liangcangLvLabel:setAnchorPoint(ccp(0,0))
	_liangcangLvLabel:setPosition(ccp(0, liangcangTitleSprite:getContentSize().height))
	liangcangTitleSprite:addChild(_liangcangLvLabel)

	-- 刷新建筑等级
	refreshBuildingStatus()

	-- 刷新建筑物升级状态
	refreshBuildingUpgradeStatus()
end

-- 刷新所有UI
function refreshAllUI()
	-- 刷新公告
	refreshNotice()
	-- 刷新建筑等级
	refreshBuildingStatus()
	-- 刷新军团等级等
	refreshGuildAttr()
	-- 刷新建筑物升级状态
	refreshBuildingUpgradeStatus()
end

-- 刷新公告
function refreshNotice()
	_noticeLabel:setString(_guildInfo.va_info[va_hall_index].post)
end

-- 刷新建筑等级
function refreshBuildingStatus()
	-- body
	_hallLvLabel:setString("Lv." .. _guildInfo.guild_level)
	_guanyuLvLabel:setString("Lv." .. _guildInfo.va_info[va_guanyu_index].level)
	_shopLvLabel:setString("Lv." .. _guildInfo.va_info[va_shop_index].level)
	_militaryLvLabel:setString("Lv." .. _guildInfo.va_info[va_military_index].level)
	_bookLvLabel:setString("Lv." .._guildInfo.va_info[va_book_index].level )
	_liangcangLvLabel:setString("Lv." .._guildInfo.va_info[va_liangcang_index].level )
end

-- 刷新军团等级等
function refreshGuildAttr()
	if( tolua.cast(_bgLayer,"CCLayer") == nil )then 
		return
	end

	local bottomSpiteSize = _bottomSpite:getContentSize()
	local bgLayerSize = _bgLayer:getContentSize()
	-- 军团名字标题
	if(_guildNameLabel)then
		_guildNameLabel:removeFromParentAndCleanup(true)
		_guildNameLabel = nil
	end
	_guildNameLabel = CCRenderLabel:create(_guildInfo.guild_name .. "  Lv." .. _guildInfo.guild_level, g_sFontPangWa, 20, 1, ccc3(0,0,0), type_stroke)
	_guildNameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_guildNameLabel:setAnchorPoint(ccp(0, 0.5))
	_guildNameLabel:setPosition(ccp(b_Sprite:getContentSize().width*0.2, b_Sprite:getContentSize().height*0.7))
	b_Sprite:addChild(_guildNameLabel)

	-- 个人贡献Label
	if(_sigleDonateLabel)then
		_sigleDonateLabel:removeFromParentAndCleanup(true)
		_sigleDonateLabel = nil
	end
	_sigleDonateLabel = CCRenderLabel:create(_sigleGuildInfo.contri_point, g_sFontPangWa, 20, 1, ccc3(0,0,0), type_stroke)
	_sigleDonateLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_sigleDonateLabel:setAnchorPoint(ccp(0, 0.5))
	_sigleDonateLabel:setPosition(ccp( sigleDonateSprite:getContentSize().width+ 5, sigleDonateSprite:getContentSize().height*0.5))
	sigleDonateSprite:addChild(_sigleDonateLabel)

	-- 成员Label
	if(_memberNumLable)then
		_memberNumLable:removeFromParentAndCleanup(true)
		_memberNumLable = nil
	end
	require "script/ui/guild/GuildDataCache"
	_memberNumLable = CCRenderLabel:create(_guildInfo.member_num .. "/" .. GuildDataCache.getMemberLimit(), g_sFontPangWa, 20, 1, ccc3(0,0,0), type_stroke)
	_memberNumLable:setColor(ccc3(0xff, 0xff, 0xff))
	_memberNumLable:setAnchorPoint(ccp(0, 0.5))
	_memberNumLable:setPosition(ccp( memberSprite:getContentSize().width+ 5, memberSprite:getContentSize().height*0.5))
	memberSprite:addChild(_memberNumLable)

	-- 军团贡献Label
	if(_guildDonateLabel)then
		_guildDonateLabel:removeFromParentAndCleanup(true)
		_guildDonateLabel = nil
	end
	_guildDonateLabel = CCRenderLabel:create(_guildInfo.curr_exp, g_sFontPangWa, 20, 1, ccc3(0,0,0), type_stroke)
	_guildDonateLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_guildDonateLabel:setAnchorPoint(ccp(0, 0.5))
	_guildDonateLabel:setPosition(ccp( guildSprite:getContentSize().width + 5, guildSprite:getContentSize().height*0.5))
	guildSprite:addChild(_guildDonateLabel)

end

-- 刷新建筑物升级状态
function refreshBuildingUpgradeStatus()

	local mineSigleInfo = GuildDataCache.getMineSigleGuildInfo()
	if(tonumber(mineSigleInfo.member_type) == 0 )then

		_upgradeHallItem:setVisible(false)
		_upgradeGuanyuItem:setVisible(false)
		_upgradeShopItem:setVisible(false)
		_upgradeMilitaryItem:setVisible(false)
		_upgradeBookItem:setVisible(false)
		_upgradeLiangcangItem:setVisible(false)
		return
	end

	-- 军团大厅
	if( tonumber(_guildInfo.guild_level) < GuildUtil.getMaxGuildLevel() )then
		local hallNeedExp = GuildUtil.getNeedExpByLv(tonumber(_guildInfo.guild_level) +1 )
		if(tonumber(_guildInfo.curr_exp)>= tonumber(hallNeedExp) )then
			_upgradeHallItem:setVisible(true)
		else
			_upgradeHallItem:setVisible(false)
		end
	else
		_upgradeHallItem:setVisible(false)
	end

	-- 关公殿
	if( tonumber(_guildInfo.va_info[va_guanyu_index].level) < math.ceil(tonumber(_guildInfo.guild_level)*DB_Legion_feast.getDataById(1).levelRatio/100) )then
		local guanyuNeedExp = GuildUtil.getGuanyuNeedExpByLv(tonumber(_guildInfo.va_info[va_guanyu_index].level) + 1)
		if( tonumber(_guildInfo.curr_exp)>= tonumber(guanyuNeedExp) )then
			_upgradeGuanyuItem:setVisible(true)
		else
			_upgradeGuanyuItem:setVisible(false)
		end
	else
		_upgradeGuanyuItem:setVisible(false)
	end

	-- 商城
	if( tonumber(_guildInfo.va_info[va_shop_index].level) < math.ceil(tonumber(_guildInfo.guild_level)*DB_Legion_shop.getDataById(1).levelRatio/100) )then
		local shopNeedExp = GuildUtil.getShopNeedExpByLv(tonumber(_guildInfo.va_info[va_shop_index].level) + 1)
		if( tonumber(_guildInfo.curr_exp)>= tonumber(shopNeedExp) )then
			_upgradeShopItem:setVisible(true)
		else
			_upgradeShopItem:setVisible(false)
		end
	else
		_upgradeShopItem:setVisible(false)
	end

	-- 军机大厅
	if( tonumber(_guildInfo.va_info[va_military_index].level) < math.ceil(tonumber(_guildInfo.guild_level)*DB_Legion_copy.getDataById(1).levelRatio/100) )then
		local militaryNeedExp = GuildUtil.getMilitaryNeedExpByLv(tonumber(_guildInfo.va_info[va_military_index].level) + 1)
		if( tonumber(_guildInfo.curr_exp)>= tonumber(militaryNeedExp) )then
			_upgradeMilitaryItem:setVisible(true)
		else
			_upgradeMilitaryItem:setVisible(false)
		end
	else
		_upgradeMilitaryItem:setVisible(false)
	end

	-- 军团书院（军团任务）
	if( tonumber(_guildInfo.va_info[va_book_index].level) < math.ceil(tonumber(_guildInfo.guild_level)*DB_Corps_quest_config.getDataById(1).levelRatio/100) )then
		local needExp = GuildUtil.getTaskNeedExpByLv(tonumber(_guildInfo.va_info[va_book_index].level) + 1)
		if( tonumber(_guildInfo.curr_exp)>= tonumber(needExp) )then
			_upgradeBookItem:setVisible(true)
		else
			_upgradeBookItem:setVisible(false)
		end
	else
		_upgradeBookItem:setVisible(false)
	end


	-- 军团粮仓
	local isOpen = GuildDataCache.getBarnIsOpen()
	if(isOpen and tonumber(_guildInfo.va_info[va_liangcang_index].level) < math.ceil(tonumber(_guildInfo.guild_level)*DB_Legion_granary.getDataById(1).levelRatio/100) )then
		local barnNeedExp = GuildUtil.getLiangCangNeedExpByLv(tonumber(_guildInfo.va_info[va_liangcang_index].level) + 1)
		if( tonumber(_guildInfo.curr_exp)>= tonumber(barnNeedExp) )then
			_upgradeLiangcangItem:setVisible(true)
		else
			_upgradeLiangcangItem:setVisible(false)
		end
	else
		_upgradeLiangcangItem:setVisible(false)
	end

end

-- 修改公告
function modifyAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/guild/GuildDeclarationLayer"
	GuildDeclarationLayer.showLayer(1002)
end

-- 创建公告
function createTop()
	require "script/ui/main/BulletinLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	_topSprite = CCSprite:create("images/guild/bg_notice.png")
	_topSprite:setAnchorPoint(ccp(0.5, 1))
	_topSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height-bulletinLayerSize.height*g_fScaleX))
	_bgLayer:addChild(_topSprite,30)
	_topSprite:setScale(g_fScaleX)

	-- 标题
	local noticeTittleSprite = CCSprite:create("images/guild/notice_title.png")
	noticeTittleSprite:setAnchorPoint(ccp(0.5, 1))
	noticeTittleSprite:setPosition(ccp(_topSprite:getContentSize().width*0.5, _topSprite:getContentSize().height))
	_topSprite:addChild(noticeTittleSprite)

	local topSpriteSize = _topSprite:getContentSize()

	-- 公告
	_noticeLabel = CCLabelTTF:create("", g_sFontName, 22, CCSizeMake(580, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	_noticeLabel:setAnchorPoint(ccp(0.5, 0.5))
	_noticeLabel:setPosition(ccp(topSpriteSize.width*0.5, topSpriteSize.height*0.5))
	_topSprite:addChild(_noticeLabel)

	local topMenuBar = CCMenu:create()
	topMenuBar:setPosition(ccp(0,0))
	_topSprite:addChild(topMenuBar)
	topMenuBar:setTouchPriority(_touchPriority-50)

	local mineSigleInfo = GuildDataCache.getMineSigleGuildInfo()
	if( tonumber(mineSigleInfo.member_type) == 1 or tonumber(mineSigleInfo.member_type) == 2)then
		-- 修改的按钮
		local modifyBtn = CCMenuItemImage:create("images/guild/btn_modify_n.png","images/guild/btn_modify_h.png")
		modifyBtn:setAnchorPoint(ccp(0.5, 0.5))
		modifyBtn:registerScriptTapHandler(modifyAction)
		modifyBtn:setPosition(ccp(topSpriteSize.width*0.85, topSpriteSize.height*0.25))
		topMenuBar:addChild(modifyBtn)
	end
end

-- 创建底部
function createBottom()
	_bottomSpite = GuildBottomSprite.createBottomSprite(true)
	_bgLayer:addChild(_bottomSpite,30)
	_bottomSpite:setScale(g_fScaleX)
end

-- 建筑Action
function buildingAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == Tag_Hall)then
		-- 军团大厅
		-- require "script/ui/guild/GuildHallLayer"
		-- local guildHallLayer = GuildHallLayer.createLayer()
		-- MainScene.changeLayer(guildHallLayer, "guildHallLayer")

		RequestCenter.guild_record(recordCallBack)

	elseif(tag == Tag_Guanyu)then
		-- 关公殿
		require "script/ui/guild/GuangongTempleLayer"
		local guangongTempleLayer = GuangongTempleLayer.showLayer()
		MainScene.changeLayer(guangongTempleLayer, "guangongTempleLayer")
	elseif( tag == Tag_Shop )then
		-- 商城
		-- require "script/ui/guild/GuildShopLayer"
		-- local guildShopLayer= GuildShopLayer.createLayer()
		-- MainScene.changeLayer(guildShopLayer, "guildShopLayer")
		require "script/ui/shopall/GuildShopLayer"
		GuildShopLayer.show()
		 -- MainScene.changeLayer(guildShopLayer, "guildShopLayer")
	elseif( tag == Tag_Military)then
		-- 军机大厅
		require "script/ui/guild/copy/GuildCopyLayer"
		local guildCopyLayer= GuildCopyLayer.createLayer()
		MainScene.changeLayer(guildCopyLayer, "guildCopyLayer")
	elseif (tag == Tag_Book) then
		require "script/ui/battlemission/MissionLayer"
		MissionLayer.showLayer()
	elseif (tag == Tag_LiangCang) then 
		local isOpen = GuildDataCache.getBarnIsOpen()
		require "script/ui/guild/liangcang/BarnData"
		local needLvTab = BarnData.getNeedGuildLvForBarn()
		if( isOpen == false)then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1336",needLvTab[1],needLvTab[2],needLvTab[3],needLvTab[4],needLvTab[5]))
			return
		end
		require "script/ui/guild/liangcang/LiangCangMainLayer"
		local liangcangLayer= LiangCangMainLayer.createLiangCangLayer()
		MainScene.changeLayer(liangcangLayer, "LiangCangMainLayer")
	elseif (tag == Tag_Science) then
		-- 军团科技
		local isSkillOpen = GuildDataCache.getGuildSkillIsOpen()
		local openNeedTab = GuildUtil.getGuildSkillOpenNeedLv()
		if (isSkillOpen == false) then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lgx_1000",openNeedTab[1]))
			return
		end
		require "script/ui/guild/guildskill/GuildSkillLayer"
		GuildSkillLayer.show()
	else
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_3212"))
	end
end

-- 拉数据回调
function recordCallBack( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		GuildDataCache._recordList = dictData.ret

		require "script/ui/guild/GuildHallLayer"
		local guildHallLayer = GuildHallLayer.createLayer()
		MainScene.changeLayer(guildHallLayer, "guildHallLayer")
	end
end

-- 升级回调
function afterUpgradeDelegate( upgrade_building_type )
	if(upgrade_building_type == Tag_Hall)then

	elseif(upgrade_building_type == Tag_Guanyu)then

	elseif(upgrade_building_type == Tag_Shop)then

	end

	-- 特效特效
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/guild/jianzhushengji"), 1,CCString:create(""));
    spellEffectSprite:retain()
    spellEffectSprite:setScale(g_fElementScaleRatio)
    spellEffectSprite:setPosition(buildingPosArr[upgrade_building_type])
   	_contentLayer:addChild(spellEffectSprite,9999);
    spellEffectSprite:release()

    local animationEnd = function(actionName,xmlSprite)
    	spellEffectSprite:retain()
		spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)

    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)

	refreshAllUI()
end

-- 升级建筑物
function upgradeBuildingAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == Tag_Hall)then
		--军团大厅
		local hallNeedExp = GuildUtil.getNeedExpByLv( tonumber(_guildInfo.guild_level) + 1 )
		UpgradeAlertTip.showAlert(Tag_Hall, hallNeedExp, tonumber(_guildInfo.guild_level), afterUpgradeDelegate)
	elseif(tag == Tag_Guanyu)then
		--关公殿
		local guanyuNeedExp = GuildUtil.getGuanyuNeedExpByLv(tonumber(_guildInfo.va_info[va_guanyu_index].level) + 1 )
		UpgradeAlertTip.showAlert(Tag_Guanyu, guanyuNeedExp, tonumber(_guildInfo.va_info[va_guanyu_index].level), afterUpgradeDelegate)
	elseif(tag == Tag_Shop)then
		-- 军团商城
		local shopNeedExp = GuildUtil.getShopNeedExpByLv(tonumber(_guildInfo.va_info[va_shop_index].level) + 1 )
		UpgradeAlertTip.showAlert(Tag_Shop, shopNeedExp, tonumber(_guildInfo.va_info[va_shop_index].level), afterUpgradeDelegate)
	elseif(tag == Tag_Military)then
		-- 军团军机大厅
		local militaryNeedExp = GuildUtil.getMilitaryNeedExpByLv(tonumber(_guildInfo.va_info[va_military_index].level) + 1 )
		UpgradeAlertTip.showAlert(Tag_Military, militaryNeedExp, tonumber(_guildInfo.va_info[va_military_index].level), afterUpgradeDelegate)
	elseif(tag== Tag_Book ) then
		-- 军团任务大厅的升级
		local bookNeedExp =	GuildUtil.getTaskNeedExpByLv(tonumber(_guildInfo.va_info[ va_book_index].level) + 1 )
		UpgradeAlertTip.showAlert(Tag_Book, bookNeedExp, tonumber(_guildInfo.va_info[va_book_index].level), afterUpgradeDelegate)
	elseif(tag==Tag_LiangCang ) then 
		-- 军团粮仓升级
		local liangcangNeedExp = GuildUtil.getLiangCangNeedExpByLv(tonumber(_guildInfo.va_info[ va_liangcang_index].level) + 1 )
		UpgradeAlertTip.showAlert(Tag_LiangCang, liangcangNeedExp, tonumber(_guildInfo.va_info[va_liangcang_index].level), afterUpgradeDelegate)
	else
		print(GetLocalizeStringBy("key_2411"))

	end
end

-- 其他军团的Action
function otherGuildAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/guild/GuildListLayer"
	local guildListLayer = GuildListLayer.createLayer(true)
	MainScene.changeLayer(guildListLayer, "guildListLayer")
end



-- 城池争夺Action
function cityFireAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 城战限制 军团大厅限制和人物等级限制
	require "script/ui/tip/AnimationTip"
	local hallLv,userLv = CityData.getLimitForCityWar()
	local my_userLv = UserModel.getHeroLevel()
	local my_hallLv = GuildDataCache.getGuildHallLevel()
	if(my_userLv < userLv and my_hallLv < hallLv)then
		local str = GetLocalizeStringBy("lic_1114") .. hallLv .. GetLocalizeStringBy("lic_1115") .. userLv .. GetLocalizeStringBy("lic_1116")
		AnimationTip.showTip(str)
		return
	elseif(my_userLv < userLv)then
		local str = GetLocalizeStringBy("lic_1117") .. userLv .. GetLocalizeStringBy("lic_1116")
		AnimationTip.showTip(str)
		return
	elseif(my_hallLv < hallLv)then
		local str = GetLocalizeStringBy("lic_1118") .. hallLv .. GetLocalizeStringBy("lic_1116")
		AnimationTip.showTip(str)
		return
	else
		-- 小红圈 设置false
		-- CityData.setIsShowTip(false)

		require "script/ui/copy/BigMap"
		local fortsLayer = BigMap.createFortsLayout()
		MainScene.changeLayer(fortsLayer, "BigMap")
	end
end

local function leaveMessage()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/guild/MessageBoardLayer"
	MessageBoardLayer.showLayer()
end

--[[
	@des 	:军团宝箱按钮回调
	@param 	:
	@return :
--]]
function treasureBoxMenuItemCallBack( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("treasureBoxMenuItemCallBack")

    require "script/ui/guild/guildbox/GuildBoxLayer"
    GuildBoxLayer.showGuildBoxLayer()
end


--[[
	@des 	:抢粮按钮回调
	@param 	:
	@return :
--]]
function robGrainMenuItemCallBack( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("robGrainMenuItemCallBack")

	require "script/ui/guild/guildRobList/GuildRobListLayer"
	GuildRobListLayer.show()
end

-- 创建主场景, 建筑物 UI
function createMainUI()
	-- ScrollView
	_scrollView = CCScrollView:create()
	_scrollView:setTouchPriority(_touchPriority-10)
	_scrollView:setViewSize(CCSizeMake(_bgLayer:getContentSize().width, _bgLayer:getContentSize().height))
	_scrollView:setDirection(kCCScrollViewDirectionVertical)
	_bgLayer:addChild(_scrollView)
	_scrollView:setBounceable(false)

	-- 内容
	_contentLayer = CCLayer:create()
	_contentLayer:setScale(g_fScaleX)
	-- 大背景
	_bgSprite = CCSprite:create("images/guild/guild_bg.jpg")
	_bgSprite:setAnchorPoint(ccp(0,0))
	_bgSprite:setPosition(0,0)
	_contentLayer:addChild(_bgSprite)

	-- 设置scrollview
	_contentLayer:setContentSize(CCSizeMake(_bgSprite:getContentSize().width,_bgSprite:getContentSize().height))
	_scrollView:setContainer(_contentLayer)
	_scrollView:ignoreAnchorPointForPosition(false)
	_scrollView:setAnchorPoint(ccp(0.5,0.5))
	_scrollView:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_scrollView:setContentOffset(ccp(0,_scrollView:getViewSize().height-_contentLayer:getContentSize().height*g_fScaleX))

	mainMenuBar = BTSensitiveMenu:create()
	mainMenuBar:setPosition(ccp(0,0))
	mainMenuBar:setTouchPriority(_touchPriority)
	_contentLayer:addChild(mainMenuBar)
	mainMenuBar:setTag(101)

	local bgLayerSize = _contentLayer:getContentSize()

------ 建筑物的坐标
	buildingPosArr[Tag_Hall]		= ccp(bgLayerSize.width*0.5, bgLayerSize.height*0.6)
	buildingPosArr[Tag_Guanyu]		= ccp(bgLayerSize.width*0.51, bgLayerSize.height*0.37)
	buildingPosArr[Tag_Book]		= ccp(bgLayerSize.width*0.18, bgLayerSize.height*0.67)
	buildingPosArr[Tag_LiangCang]	= ccp(bgLayerSize.width*0.84, bgLayerSize.height*0.67)
	buildingPosArr[Tag_Shop]		= ccp(bgLayerSize.width*0.16, bgLayerSize.height*0.47)
	buildingPosArr[Tag_Military]	= ccp(bgLayerSize.width*0.85, bgLayerSize.height*0.47)
	buildingPosArr[Tag_Science]		= ccp(bgLayerSize.width*0.18, bgLayerSize.height*0.27)

----- 五个建筑
----- 军团大厅
	local hallItem = GuildBuildingItem.createBuildingItemBy(Tag_Hall)
	hallItem:setAnchorPoint(ccp(0.5, 0.5))
	hallItem:registerScriptTapHandler(buildingAction)
	hallItem:setPosition(buildingPosArr[Tag_Hall].x, buildingPosArr[Tag_Hall].y) --   ccp(bottomSize.width*0.6, bottomSize.height*0.4))
	mainMenuBar:addChild(hallItem, 1, Tag_Hall)
	-- hallItem:setScale(g_fElementScaleRatio)
	-- 标题
	local hallTitleSprite = CCSprite:create("images/guild/title_hall.png")
	hallTitleSprite:setAnchorPoint(ccp(0.5, 0))
	hallTitleSprite:setPosition(ccp(130, 280))
	hallItem:addChild(hallTitleSprite, 2)
	-- 军团等级
	_hallLvLabel = CCRenderLabel:create("Lv.99", g_sFontPangWa, 18, 1, ccc3(0,0,0), type_stroke)
	_hallLvLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_hallLvLabel:setAnchorPoint(ccp(0,0))
	_hallLvLabel:setPosition(ccp(0, hallTitleSprite:getContentSize().height))
	hallTitleSprite:addChild(_hallLvLabel)

------ 关公殿MissionAfterBattle
	local guanyuItem = GuildBuildingItem.createBuildingItemBy(Tag_Guanyu)
	guanyuItem:setAnchorPoint(ccp(0.5, 0.5))
	guanyuItem:registerScriptTapHandler(buildingAction)
	guanyuItem:setPosition(buildingPosArr[Tag_Guanyu].x, buildingPosArr[Tag_Guanyu].y)
	mainMenuBar:addChild(guanyuItem, 1, Tag_Guanyu)
	-- guanyuItem:setScale(g_fElementScaleRatio)
	-- 标题
	local guanyuTitleSprite = CCSprite:create("images/guild/title_guanyu.png")
	guanyuTitleSprite:setAnchorPoint(ccp(0.5, 0))
	guanyuTitleSprite:setPosition(ccp(70, 170))
	guanyuItem:addChild(guanyuTitleSprite)
	-- 关公殿等级
	_guanyuLvLabel = CCRenderLabel:create("Lv.99", g_sFontPangWa, 18, 1, ccc3(0,0,0), type_stroke)
	_guanyuLvLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_guanyuLvLabel:setAnchorPoint(ccp(0,0))
	_guanyuLvLabel:setPosition(ccp(0, guanyuTitleSprite:getContentSize().height))
	guanyuTitleSprite:addChild(_guanyuLvLabel)

	--策划要求，增加可以参拜提示
	require "script/ui/guild/GuildDataCache"
	if GuildDataCache.isCanBaiGuangong() then
		local alertSprite = CCSprite:create("images/common/tip_2.png")
        alertSprite:setAnchorPoint(ccp(0.5,0.5))
        alertSprite:setPosition(ccp(guanyuItem:getContentSize().width*0.8,guanyuItem:getContentSize().height*0.8))
        guanyuItem:addChild(alertSprite)
	end

----- 军团商城
	local shopItem = GuildBuildingItem.createBuildingItemBy(Tag_Shop)
	shopItem:setAnchorPoint(ccp(0.5, 0.5))
	shopItem:registerScriptTapHandler(buildingAction)
	shopItem:setPosition(buildingPosArr[Tag_Shop].x, buildingPosArr[Tag_Shop].y) --   ccp(bottomSize.width*0.6, bottomSize.height*0.4))
	mainMenuBar:addChild(shopItem, 1, Tag_Shop)
	-- shopItem:setScale(g_fElementScaleRatio)
	-- 标题
	local shopTitleSprite = CCSprite:create("images/guild/title_shop.png")
	shopTitleSprite:setAnchorPoint(ccp(0.5, 0))
	shopTitleSprite:setPosition(ccp(70, 180))
	shopItem:addChild(shopTitleSprite)
	-- 商店等级
	_shopLvLabel = CCRenderLabel:create("Lv.99", g_sFontPangWa, 18, 1, ccc3(0,0,0), type_stroke)
	_shopLvLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_shopLvLabel:setAnchorPoint(ccp(0,0))
	_shopLvLabel:setPosition(ccp(0, shopTitleSprite:getContentSize().height))
	shopTitleSprite:addChild(_shopLvLabel)

----- 军机大厅
	local militaryItem = GuildBuildingItem.createBuildingItemBy(Tag_Military)
	militaryItem:setAnchorPoint(ccp(0.5, 0.5))
	militaryItem:registerScriptTapHandler(buildingAction)
	militaryItem:setPosition(buildingPosArr[Tag_Military].x, buildingPosArr[Tag_Military].y) --   ccp(bottomSize.width*0.6, bottomSize.height*0.4))
	mainMenuBar:addChild(militaryItem, 2, Tag_Military)
	-- militaryItem:setScale(g_fElementScaleRatio)

	-- 按照策划的要求，增加提示提示
	require "script/utils/ItemDropUtil"
	require "script/ui/guild/copy/GuildTeamData"
	local atkNum=  GuildTeamData.getLeftGuildAtkNum()
	print("atkNum  is : ",atkNum)

	if( atkNum > 0) then
		local militaryTipSp= ItemDropUtil.getTipSpriteByNum(atkNum)
		militaryTipSp:setPosition(militaryItem:getContentSize().width*0.8 ,militaryItem:getContentSize().height*0.8)
		militaryItem:addChild(militaryTipSp)
	end

	-- 标题
	local militaryTitleSprite = CCSprite:create("images/guild/title_military.png")
	militaryTitleSprite:setAnchorPoint(ccp(0.5, 0))
	militaryTitleSprite:setPosition(ccp(70,180))
	militaryItem:addChild(militaryTitleSprite)
	-- 商店等级
	_militaryLvLabel = CCRenderLabel:create("Lv.99", g_sFontPangWa, 18, 1, ccc3(0,0,0), type_stroke)

	_militaryLvLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_militaryLvLabel:setAnchorPoint(ccp(0,0))
	_militaryLvLabel:setPosition(ccp(0, militaryTitleSprite:getContentSize().height))
	militaryTitleSprite:addChild(_militaryLvLabel)

----- 军团粮仓
	_barnItem = GuildBuildingItem.createBuildingItemBy(Tag_LiangCang)
	_barnItem:setAnchorPoint(ccp(0.5, 0.5))
	_barnItem:registerScriptTapHandler(buildingAction)
	_barnItem:setPosition(buildingPosArr[Tag_LiangCang].x, buildingPosArr[Tag_LiangCang].y) --   ccp(bottomSize.width*0.6, bottomSize.height*0.4))
	mainMenuBar:addChild(_barnItem, 1, Tag_LiangCang)
	-- _barnItem:setScale(g_fElementScaleRatio)

	-- 粮仓标题
	local liangcangTitleSprite = CCSprite:create("images/guild/title_liangcang.png")
	liangcangTitleSprite:setAnchorPoint(ccp(0.5, 0))
	liangcangTitleSprite:setPosition(ccp(70, _barnItem:getContentSize().height))
	_barnItem:addChild(liangcangTitleSprite)
	-- 粮仓等级
	_liangcangLvLabel = CCRenderLabel:create("Lv.99", g_sFontPangWa, 18, 1, ccc3(0,0,0), type_stroke)
	_liangcangLvLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_liangcangLvLabel:setAnchorPoint(ccp(0,0))
	_liangcangLvLabel:setPosition(ccp(0, liangcangTitleSprite:getContentSize().height))
	liangcangTitleSprite:addChild(_liangcangLvLabel)
	-- 小红圈
	local alertSprite = CCSprite:create("images/common/tip_2.png")
    alertSprite:setAnchorPoint(ccp(0.5,0.5))
    alertSprite:setPosition(ccp(_barnItem:getContentSize().width*0.9,_barnItem:getContentSize().height*0.8))
    _barnItem:addChild(alertSprite)
    alertSprite:setVisible(false)
	-- 有剩余粮草 添加小红圈
	if( GuildDataCache.getAllSurplusCollectNum() > 0 ) then
		alertSprite:setVisible(true)
	end

----- 军团书院（军团任务）
	local bookItem = GuildBuildingItem.createBuildingItemBy(Tag_Book)
	bookItem:setAnchorPoint(ccp(0.5, 0.5))
	bookItem:registerScriptTapHandler(buildingAction)
	bookItem:setPosition(buildingPosArr[Tag_Book].x, buildingPosArr[Tag_Book].y) --   ccp(bottomSize.width*0.6, bottomSize.height*0.4))
	mainMenuBar:addChild(bookItem, 1, Tag_Book)
	-- bookItem:setScale(g_fElementScaleRatio)

	local doBattleCallback = function ()
        MissionService.getTaskInfo(function ()
            _missionTable = addRedFunction(cbFlag, dictData, bRet)
        end)
    end

	doBattleCallback()
	-- 标题
	local boolTitleSprite = CCSprite:create("images/guild/title_task.png")
	boolTitleSprite:setAnchorPoint(ccp(0.5, 0))
	boolTitleSprite:setPosition(ccp(70, 160))
	bookItem:addChild(boolTitleSprite)
	-- 商店等级
	_bookLvLabel = CCRenderLabel:create("Lv.99", g_sFontPangWa, 18, 1, ccc3(0,0,0), type_stroke)
	_bookLvLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_bookLvLabel:setAnchorPoint(ccp(0,0))
	_bookLvLabel:setPosition(ccp(0, boolTitleSprite:getContentSize().height))
	boolTitleSprite:addChild(_bookLvLabel)
----- 军团科技
	_scienceItem = GuildBuildingItem.createBuildingItemBy(Tag_Science)
	_scienceItem:setAnchorPoint(ccp(0.5, 0.5))
	_scienceItem:registerScriptTapHandler(buildingAction)
	_scienceItem:setPosition(buildingPosArr[Tag_Science].x, buildingPosArr[Tag_Science].y) --   ccp(bottomSize.width*0.6, bottomSize.height*0.4))
	mainMenuBar:addChild(_scienceItem, 1, Tag_Science)

	-- 军团科技标题
	local scienceTitleSprite = CCSprite:create("images/guild/title_science.png")
	scienceTitleSprite:setAnchorPoint(ccp(0.5, 0))
	scienceTitleSprite:setPosition(ccp(70, _scienceItem:getContentSize().height))
	_scienceItem:addChild(scienceTitleSprite)
	

---------- 各个建筑升级的按钮
	local upgradeMenuBar = CCMenu:create()
	upgradeMenuBar:setAnchorPoint(ccp(0,0))
	upgradeMenuBar:setPosition(ccp(0,0))
	_contentLayer:addChild(upgradeMenuBar)
	upgradeMenuBar:setTouchPriority(_touchPriority-1)

	-- 大厅
	_upgradeHallItem = CCMenuItemImage:create("images/guild/btn_upgrade_n.png", "images/guild/btn_upgrade_h.png")
	_upgradeHallItem:setAnchorPoint(ccp(1,0))
	_upgradeHallItem:setPosition(buildingPosArr[Tag_Hall].x, buildingPosArr[Tag_Hall].y)
	_upgradeHallItem:registerScriptTapHandler(upgradeBuildingAction)
	upgradeMenuBar:addChild(_upgradeHallItem, 1, Tag_Hall)

	-- 关公殿
	_upgradeGuanyuItem = CCMenuItemImage:create("images/guild/btn_upgrade_n.png", "images/guild/btn_upgrade_h.png")
	_upgradeGuanyuItem:setAnchorPoint(ccp(0,0))
	_upgradeGuanyuItem:setPosition(buildingPosArr[Tag_Guanyu].x, buildingPosArr[Tag_Guanyu].y)
	_upgradeGuanyuItem:registerScriptTapHandler(upgradeBuildingAction)
	upgradeMenuBar:addChild(_upgradeGuanyuItem, 1, Tag_Guanyu)

	-- 商城
	_upgradeShopItem = CCMenuItemImage:create("images/guild/btn_upgrade_n.png", "images/guild/btn_upgrade_h.png")
	_upgradeShopItem:setAnchorPoint(ccp(0,0))
	_upgradeShopItem:setPosition(buildingPosArr[Tag_Shop].x, buildingPosArr[Tag_Shop].y)
	_upgradeShopItem:registerScriptTapHandler(upgradeBuildingAction)
	upgradeMenuBar:addChild(_upgradeShopItem, 1, Tag_Shop)

	-- 军机大厅
	_upgradeMilitaryItem = CCMenuItemImage:create("images/guild/btn_upgrade_n.png", "images/guild/btn_upgrade_h.png")
	_upgradeMilitaryItem:setAnchorPoint(ccp(0,0))
	_upgradeMilitaryItem:setPosition(buildingPosArr[Tag_Military].x, buildingPosArr[Tag_Military].y)
	_upgradeMilitaryItem:registerScriptTapHandler(upgradeBuildingAction)
	upgradeMenuBar:addChild(_upgradeMilitaryItem, 1, Tag_Military)

	-- 军团书院(也就是军团任务)
	_upgradeBookItem = CCMenuItemImage:create("images/guild/btn_upgrade_n.png", "images/guild/btn_upgrade_h.png")
	_upgradeBookItem:setAnchorPoint(ccp(0,0))
	_upgradeBookItem:setPosition(buildingPosArr[Tag_Book].x, buildingPosArr[Tag_Book].y)
	_upgradeBookItem:registerScriptTapHandler(upgradeBuildingAction)
	upgradeMenuBar:addChild(_upgradeBookItem, 1, Tag_Book )

	-- 军团粮仓
	_upgradeLiangcangItem = CCMenuItemImage:create("images/guild/btn_upgrade_n.png", "images/guild/btn_upgrade_h.png")
	_upgradeLiangcangItem:setAnchorPoint(ccp(0,0))
	_upgradeLiangcangItem:setPosition(bgLayerSize.width*0.7, bgLayerSize.height*0.63)
	_upgradeLiangcangItem:registerScriptTapHandler(upgradeBuildingAction)
	upgradeMenuBar:addChild(_upgradeLiangcangItem, 1, Tag_LiangCang )

----------
	local bottomSpiteSize = _bottomSpite:getContentSize()

----- 底部黑色背景
	b_Sprite = CCScale9Sprite:create("images/common/bg/9s_guild.png")
	b_Sprite:setContentSize(CCSizeMake(640, 100))
	b_Sprite:setAnchorPoint(ccp(0.5, 0))
	b_Sprite:setScale(g_fScaleX)
	b_Sprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, (bottomSpiteSize.height-15)*g_fScaleX))
	_bgLayer:addChild(b_Sprite,30)

	local b_Sprite_size = b_Sprite:getContentSize()

	-- 军团图标
	local guildId = GuildDataCache.getGuildIconId()
	if(guildId ~= nil)then
		_guildIcon = GuildUtil.getGuildIcon(guildId)
	    _guildIcon:setAnchorPoint(ccp(0.5, 0))
	    _guildIcon:setPosition(ccp(b_Sprite_size.width*0.1,0))
	    b_Sprite:addChild(_guildIcon)
	    _guildIcon:setScale(_guildIcon:getScale()*0.7)
	end

	-- 个人贡献
	sigleDonateSprite = CCSprite:create("images/guild/sigle_donate.png")
	sigleDonateSprite:setAnchorPoint(ccp(0, 0.5))
	sigleDonateSprite:setPosition(ccp(b_Sprite_size.width*0.6, b_Sprite_size.height*0.3))
	b_Sprite:addChild(sigleDonateSprite)


	-- 成员
	memberSprite = CCSprite:create("images/guild/member.png")
	memberSprite:setAnchorPoint(ccp(0, 0.5))
	memberSprite:setPosition(ccp(b_Sprite_size.width*0.2, b_Sprite_size.height*0.3))
	b_Sprite:addChild(memberSprite)


	-- 军团贡献
	guildSprite = CCSprite:create("images/guild/guild_donate.png")
	guildSprite:setAnchorPoint(ccp(0, 0.5))
	guildSprite:setPosition(ccp(b_Sprite_size.width*0.6, b_Sprite_size.height*0.7))
	b_Sprite:addChild(guildSprite)


--------其他的按钮
----- 上部黑色背景
	local topMenuBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	topMenuBg:setContentSize(CCSizeMake(640, 100))
	topMenuBg:setAnchorPoint(ccp(0.5, 1))
	topMenuBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _topSprite:getPositionY()-_topSprite:getContentSize().height*g_fScaleX+10))
	_bgLayer:addChild(topMenuBg,8)
	topMenuBg:setScale(g_fScaleX)

-- 上部分屏蔽层
	-- 加屏蔽层 
	local maskLayer = CCLayer:create()
	_bgLayer:addChild(maskLayer)
	local maskHeight = _bgLayer:getContentSize().height-topMenuBg:getPositionY()+topMenuBg:getContentSize().height*g_fScaleX
	maskLayer:setContentSize(CCSizeMake(640,maskHeight/g_fScaleX))
	maskLayer:ignoreAnchorPointForPosition(false)
	maskLayer:setAnchorPoint(ccp(0.5,1))
	maskLayer:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height)
	maskLayer:setScale(g_fScaleX)

	maskLayer:setTouchEnabled(true)
    maskLayer:registerScriptTouchHandler(function ( eventType,x,y )
       	local rect = getSpriteScreenRect(maskLayer)
		if(rect:containsPoint(ccp(x,y))) then
			return true
		else
			return false
		end
    end,false, _touchPriority-45, true)

	local otherGuildMenuBar = CCMenu:create()
	otherGuildMenuBar:setAnchorPoint(ccp(0,0))
	otherGuildMenuBar:setPosition(ccp(0,0))
	_bgLayer:addChild(otherGuildMenuBar,10)
	otherGuildMenuBar:setTouchPriority(_touchPriority-50)

	-- 其他军团按钮
	local otherGuildItem = CCMenuItemImage:create("images/guild/btn_otherguild_n.png", "images/guild/btn_otherguild_h.png")
	otherGuildItem:setAnchorPoint(ccp(0.5,0))
	otherGuildItem:setPosition(_bgLayer:getContentSize().width*0.9, bottomSpiteSize.height*g_fScaleX + 80*g_fElementScaleRatio)
	otherGuildItem:registerScriptTapHandler(otherGuildAction)
	otherGuildMenuBar:addChild(otherGuildItem)
	otherGuildItem:setScale(g_fElementScaleRatio)

    --军团留言板
    local messageBoard = CCMenuItemImage:create("images/guild/note_n.png","images/guild/note_h.png")
    messageBoard:setAnchorPoint(ccp(0.5,0))
    messageBoard:setPosition(_bgLayer:getContentSize().width*0.73, bottomSpiteSize.height*g_fScaleX + 80*g_fElementScaleRatio)
    messageBoard:registerScriptTapHandler(leaveMessage)
    otherGuildMenuBar:addChild(messageBoard)
    messageBoard:setScale(g_fElementScaleRatio)

    -- --军团宝箱按钮
    -- local treasureBoxMenuItem = CCMenuItemImage:create("images/guild/guild_box_n.png","images/guild/guild_box_h.png")
    -- treasureBoxMenuItem:setAnchorPoint(ccp(0.5,0))
    -- treasureBoxMenuItem:setPosition(bgLayerSize.width*0.7, bgLayerSize.height*0.79)
    -- treasureBoxMenuItem:registerScriptTapHandler(treasureBoxMenuItemCallBack)
    -- otherGuildMenuBar:addChild(treasureBoxMenuItem)

    local posY = _topSprite:getPositionY()-_topSprite:getContentSize().height*g_fScaleX-85*g_fElementScaleRatio
    -- 城池争夺
	cityFireItem = CCMenuItemImage:create("images/guild/city_n.png", "images/guild/city_h.png")
	cityFireItem:setAnchorPoint(ccp(0.5, 0))
	cityFireItem:setPosition(_bgLayer:getContentSize().width*0.9, posY)
	cityFireItem:registerScriptTapHandler(cityFireAction)
	otherGuildMenuBar:addChild(cityFireItem)
	cityFireItem:setScale(g_fElementScaleRatio)
	-- 小红圈
	tipSprite = CCSprite:create("images/common/tip_2.png")
    tipSprite:setAnchorPoint(ccp(0.5,0.5))
    tipSprite:setPosition(ccp(cityFireItem:getContentSize().width*0.8,cityFireItem:getContentSize().height*0.8))
    cityFireItem:addChild(tipSprite,1,10)
    tipSprite:setVisible(false)

    -- 抢粮战按钮
    local robGrainMenuItem = CCMenuItemImage:create("images/guild/rob_grain_n.png","images/guild/rob_grain_h.png")
    robGrainMenuItem:setAnchorPoint(ccp(0.5,0))
    robGrainMenuItem:setPosition(_bgLayer:getContentSize().width*0.7, posY)
    robGrainMenuItem:registerScriptTapHandler(robGrainMenuItemCallBack)
    otherGuildMenuBar:addChild(robGrainMenuItem)
    robGrainMenuItem:setScale(g_fElementScaleRatio)

    -- 攻城掠地
    local guildBossCopyItem = CCMenuItemImage:create("images/guild_boss_copy/attack_n.png", "images/guild_boss_copy/attack_h.png")
    otherGuildMenuBar:addChild(guildBossCopyItem)
    guildBossCopyItem:setAnchorPoint(ccp(0.5, 0))
   	guildBossCopyItem:setPosition(_bgLayer:getContentSize().width*0.5, posY)
    guildBossCopyItem:registerScriptTapHandler(guildBossCopyCallback)
    guildBossCopyItem:setScale(g_fElementScaleRatio)
    
    local bossCopyGetUserInfoCallback = function ( ... )
    	if GuildBossCopyData.couldOpenBoxOrReceive() then
			local redTip = CCSprite:create("images/common/tip_2.png")
			guildBossCopyItem:addChild(redTip)
			redTip:setPosition(ccpsprite(0.6, 0.6, guildBossCopyItem))
		end
    end
    require "script/ui/guildBossCopy/GuildBossCopyData"
    local guildLevel = GuildDataCache.getGuildHallLevel()
	local guildLevelLimit = GuildBossCopyData.getGuildLevelLimit()[1][2]
	if guildLevel >= guildLevelLimit then
		require "script/ui/guildBossCopy/GuildBossCopyService"
    	GuildBossCopyService.getUserInfo(bossCopyGetUserInfoCallback)
	end
    
    

    _city_fire_status_tag = CCSprite:create("images/citybattle/signup.png")
    cityFireItem:addChild(_city_fire_status_tag)
    _city_fire_status_tag:setAnchorPoint(ccp(0.5, 1))
    _city_fire_status_tag:setPosition(ccp(cityFireItem:getContentSize().width * 0.5, 0))
    _city_fire_status_tag:setVisible(false)

    -- 城战限制 军团大厅限制和人物等级限制
	require "script/ui/guild/city/CityData"
	require "script/model/user/UserModel"
	local hallLv,userLv = CityData.getLimitForCityWar()
	local my_userLv = UserModel.getHeroLevel()
	local my_hallLv = GuildDataCache.getGuildHallLevel()
	if(my_userLv >= userLv and my_hallLv >= hallLv)then
    	-- 时间表
		timesInfo = CityData.getTimeTable()
		if(table.isEmpty(timesInfo))then
			local function signUpCallBack( cbFlag, dictData, bRet )
				-- 改数据
				CityData.setCityServiceInfo(dictData)
				timesInfo = CityData.getTimeTable()
	            ---------------------------- added by bzx
	            timerRefreshStatusStart()
	            ----------------------------
			end
			local data = GuildDataCache.getMineSigleGuildInfo()
			local tempArgs = CCArray:create()
			tempArgs:addObject(CCInteger:create(data.guild_id))
			RequestCenter.GuildSignUpInfo(signUpCallBack, tempArgs)
		else
	        ---------------------------- added by bzx
	        timerRefreshStatusStart()
	        ----------------------------
		end
	end
end

function guildBossCopyCallback( ... )
	require "script/ui/guildBossCopy/GuildBossCopyLayer"
	GuildBossCopyLayer.show()
end


function addRedFunction()
	local num = DB_Corps_quest_config.getDataById(1).questMaxNum - MissionData.getTaskInfo().task_num
	local tipSprite = getTipSpriteWithNum(num)
	local item = _contentLayer:getChildByTag(101):getChildByTag(Tag_Book)
	tipSprite:setPosition(item:getContentSize().width*0.70, item:getContentSize().height*0.98)
	tipSprite:setAnchorPoint(ccp(1,1))
	item:addChild(tipSprite,1)
end

-- 创建提示sprite
-- 参数num 为提示里的数字
function getTipSpriteWithNum(num)
	require "script/ui/rechargeActive/ActiveCache"
	local tipSprite= CCSprite:create("images/common/tip_2.png")
	-- tipSprite:setAnchorPoint(ccp(1,1))
	tipSprite:setVisible(false)
	if(num>0) then
		if(tipSprite:getChildByTag(10)~=nil)then
			tipSprite:removeChildByTag(10,true)
		else

		end
		local countLabel = CCLabelTTF:create(num,g_sFontName,18)
		countLabel:setAnchorPoint(ccp(0.5,0.5))
		tipSprite:addChild(countLabel)
		countLabel:setTag(10)
		countLabel:setPosition(ccp(tipSprite:getContentSize().width*0.5,tipSprite:getContentSize().height*0.5))
		tipSprite:setVisible(true)
	end

	return tipSprite
end

function timerRefreshStatus(time)

    if _city_fire_status_tag == nil then
        return
    end

    local status = getCityFireStatus()
    local status_frame = nil
    if status == CityFireStatus.sign_up then
        status_frame = CCSpriteFrame:create("images/citybattle/signup.png", CCRectMake(0, 0, 83, 36))
    elseif status == CityFireStatus.fighting then
        status_frame = CCSpriteFrame:create("images/citybattle/battle.png", CCRectMake(0, 0, 83, 36))
    elseif status == CityFireStatus.reward then
        status_frame = CCSpriteFrame:create("images/citybattle/reward.png", CCRectMake(0, 0, 83, 36))
    end
    if status_frame ~= nil then
        _city_fire_status_tag:setDisplayFrame(status_frame)
        _city_fire_status_tag:setVisible(true)
        -- 加小红圈 add by licong
        tipSprite:setVisible(true)
        -- CityData.setIsShowTip(true)
    else
        _city_fire_status_tag:setVisible(false)
        -- 加小红圈 add by licong
        tipSprite:setVisible(false)
        -- CityData.setIsShowTip(false)
    end
end

---------------------------------- added by bzx
function getCityFireStatus()
    local time_table = timesInfo
    local current_time = BTUtil:getSvrTimeInterval()
    local status = nil
    if current_time > time_table.signupStart and current_time < time_table.signupEnd then
        status = CityFireStatus.sign_up
    elseif current_time > time_table.signupEnd and
    current_time < tonumber(time_table.arrAttack[2][2]) then
        if not table.isEmpty(CityData.getSignCity()) then
            status = CityFireStatus.fighting
        end
    elseif current_time > time_table.rewardStart and current_time < time_table.rewardEnd then
        local reward_city_id = CityData.getRewardCity()
        if reward_city_id ~= "0" then
            status = CityFireStatus.reward
        end
    end
    return status
end

-- 加按钮下标签
function timerRefreshStatusStart()
    timerRefreshStatus(nil)
    if _timer_refresh_status == nil then
        local director = CCDirector:sharedDirector()
        _timer_refresh_status = director:getScheduler():scheduleScriptFunc(timerRefreshStatus, 1, false)
    end
end

function timerRefreshStatusEnd()
    local director = CCDirector:sharedDirector()
    if _timer_refresh_status ~= nil then
        director:getScheduler():unscheduleScriptEntry(_timer_refresh_status)
        _timer_refresh_status = nil
    end
end
----------------------------------


-- 创建UI
function createUI()
-- 创建Top
	createTop()
-- 创建Bottom
	createBottom()
-- 创建主场景, 建筑物 UI
	createMainUI()
end


-- 军团请求回调
function getGuildInfoCallback(  cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		_guildInfo 		= dictData.ret
		_sigleGuildInfo = GuildDataCache.getMineSigleGuildInfo()
		if(not table.isEmpty(_guildInfo))then
			require "script/ui/guild/GuildDataCache"
			GuildDataCache.setGuildInfo(_guildInfo)
			loadingUI()
		end
	end
end

-- 开始加载界面
function loadingUI()
	createUI()
	refreshAllUI()
end

-- 创建 param 是否强制拉数据
function createLayer( isForceRequest )
	init()
	isForceRequest = isForceRequest or false

	-- _bgLayer = MainScene.createBaseLayer("images/guild/guild_bg.jpg", false, false, true)
	MainScene.setMainSceneViewsVisible(false,false,true)
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	if(isForceRequest == true )then
		RequestCenter.guild_getGuildInfo(getGuildInfoCallback)
	else
		_guildInfo 		= GuildDataCache.getGuildInfo()
		_sigleGuildInfo = GuildDataCache.getMineSigleGuildInfo()
		if(not table.isEmpty(_guildInfo))then
			loadingUI()
		else
			RequestCenter.guild_getGuildInfo(getGuildInfoCallback)
		end
	end

	return _bgLayer
end
