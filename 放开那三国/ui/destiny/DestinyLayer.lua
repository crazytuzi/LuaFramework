-- Filename: DestinyLayer.lua
-- Author: zhz
-- Date: 2013-12-17
-- Purpose: 天命系统

module ("DestinyLayer", package.seeall)

require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/destiny/DestinyData"
require "script/ui/destiny/DestinyUtil"
require "script/utils/BaseUI"
require "script/ui/tip/AnimationTip"
require "script/ui/hero/HeroTransferLayer"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"
require "script/utils/LevelUpUtil"
require "script/model/utils/HeroUtil"
require "script/model/hero/FightForceModel"
require "script/model/affix/AffixDef"

local _bgLayer= nil
local _destinyBg= nil 			-- 天命的背景层
local _topBg 					-- 顶部的UI
local _silverLabel				-- 银币
local _goldLabel				-- 金币


local _bottomBg = nil
local _bottmNodeForLead			-- 底部的node 给新手引导
local _captionLabel				-- 统帅的label
local _forceLabel				-- 武力的label
local _intelligenceLabel  		-- 智力的label

local _attLabel					-- 攻击
local _lifeLabel				-- 生命
local _phyDefLabel				-- 物防
local _magDefLabel				-- 法防

local _captionNum				-- 统帅的num
local _forceNum					-- 武力的num
local _intelligenceNum  		-- 智力的

local _attNum					-- 攻击
local _lifeNum					-- 生命
local _phyDefNum				-- 物防
local _magDefNum				-- 法防

local _starContent				-- 显示副本星数
local _lineSp					-- 星座区域的线
local _heroSp					-- 英雄的背景图
local _sealSp					-- 印章：显示攻击
local _sealNode					-- 印章的节点
local _propertyLabel			-- 显示：攻击等 的数值
local _needStarContent
local _needStarNum				-- 需要的副本星数
local _silverContent			-- 需要的银币
local _needSliverNum			-- 需要的银币数目

local _ksPreDestineyTag= 1001	-- 上一个天命的星座的tag
local _ksCurDestineyTag= 2001
local _ksAftDestineyTag= 3001
local _ksDestLabeTag = 101

local _preDestineyItem			-- 上一个天命的星座
local _curDestinyItem			-- 当前天命的星座
local _aftDestinyItem			-- 后一个天命的

local _preDestineyLabel			-- 上一个天命的名字
local _curDestinyLabel 			-- 当前星座的名字
local _aftDestinyLabel			-- 后一个天命的名字

local learnSkillBtn  = nil      -- 主角换技能按钮


local function init( )
	_bgLayer = nil
	_layerSize= {}
	_destinyBg= nil
	_topBg = nil
	_silverLabel= nil
	_goldLabel= nil

	_bottomBg = nil
	_bottmNodeForLead = nil
	_captionLabel = nil
	_forceLabel= nil
	_intelligenceLabel= nil
	_attLabel= nil
	_lifeLabel= nil
	_phyDefLabel= nil
	_magDefLabel= nil
	_sealNode= nil

	-- middleUi
	_starContent=nil
	_lineSp= nil
	_heroSp= nil
	_levelUpContent={}
	_levelUpNode= nil
	_needStarContent={}
	_needStarNum = nil
	_silverContent= {}
	_needSliverNum= nil
	_sealSp= nil
	_propertyLabel= nil

	_preDestineyItem= nil
	_curDestinyItem= nil
	_aftDestinyItem= nil
	learnSkillBtn  = nil



end

--  上标题栏 显示战斗力，银币，金币
function createTopUI( )
	require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
	
	-- _topBg = CCSprite:create("images/hero/another_attr_bg.png")
 --    _topBg:setAnchorPoint(ccp(0,1))
 --    _topBg:setPosition(0,_bgLayer:getContentSize().height)
 --    _topBg:setScale(g_fScaleX)
 --    _bgLayer:addChild(_topBg, 10)
 --    titleSize = _topBg:getContentSize()

 --    local lvSp = CCSprite:create("images/common/lv.png")
 --    lvSp:setAnchorPoint(ccp(0.5,0.5))
 --    lvSp:setPosition(_topBg:getContentSize().width*0.07,_topBg:getContentSize().height*0.43)
 --    _topBg:addChild(lvSp)
    
	-- --  lvLabel = CCRenderLabel:create( userInfo.level , g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- local lvLabel = CCLabelTTF:create(userInfo.level , g_sFontName, 23)
 --    lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
 --    lvLabel:setAnchorPoint(ccp(0.5,0.5))
 --    lvLabel:setPosition(_topBg:getContentSize().width*0.07+lvSp:getContentSize().width ,_topBg:getContentSize().height*0.43)
 --    _topBg:addChild(lvLabel)

	-- --   local nameLabel= CCRenderLabel:create( UserModel.getUserName(), g_sFontName, 23, 1,ccc3(0,0,0), type_stroke)
	-- local nameLabel= CCLabelTTF:create(UserModel.getUserName(), g_sFontName, 23)
 --    nameLabel:setPosition(_topBg:getContentSize().width*0.17, _topBg:getContentSize().height*0.43)
 --    nameLabel:setAnchorPoint(ccp(0,0.5))
 --    nameLabel:setColor(ccc3(0x70,0xff,0x18))
 --    _topBg:addChild(nameLabel)

 --    local vipSp = CCSprite:create ("images/common/vip.png")
	-- vipSp:setPosition(_topBg:getContentSize().width*0.44, _topBg:getContentSize().height*0.43)
	-- vipSp:setAnchorPoint(ccp(0,0.5))
	-- _topBg:addChild(vipSp)

 --    -- VIP对应级别
 --    require "script/libs/LuaCC"
 --    local vipNumSp = LuaCC.createSpriteOfNumbers("images/main/vip", UserModel.getVipLevel() , 15)
 --    vipNumSp:setPosition(_topBg:getContentSize().width*0.44+vipSp:getContentSize().width, _topBg:getContentSize().height*0.43)
 --    vipNumSp:setAnchorPoint(ccp(0,0.5))
 --    _topBg:addChild(vipNumSp)
    
 --    _silverLabel = CCLabelTTF:create( userInfo.silver_num,g_sFontName,18)
 --    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
 --    _silverLabel:setAnchorPoint(ccp(0,0.5))
 --    _silverLabel:setPosition(_topBg:getContentSize().width*0.62,_topBg:getContentSize().height*0.43)
 --    _topBg:addChild(_silverLabel)
    
 --    _goldLabel = CCLabelTTF:create( userInfo.gold_num,g_sFontName,18)
 --    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
 --    _goldLabel:setAnchorPoint(ccp(0,0.5))
 --    _goldLabel:setPosition(_topBg:getContentSize().width*0.84,_topBg:getContentSize().height*0.43)
 --    _topBg:addChild(_goldLabel)
    -- return _topBg

    _topBg,_silverLabel,_goldLabel = HeroUtil.createNewAttrBgSprite(userInfo.level,UserModel.getUserName(),UserModel.getVipLevel(),userInfo.silver_num,userInfo.gold_num)
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,_bgLayer:getContentSize().height)
    _topBg:setScale(g_fScaleX)
    _bgLayer:addChild(_topBg, 10)
end

-- 刷新顶部UI
function refreshTopUI(  )
	_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))  -- modified by yangrui at 2015-12-03
end

function createUpTipLabel( ... )
	
end

-- 
function createUpLabel( )
	if(_levelUpNode ~= nil ) then
		_levelUpNode:removeFromParentAndCleanup(true)
		_levelUpNode= nil

	end
	local levelUpContent= {}

	if(DestinyData.getUpDestiny()) then 
		if( DestinyData.getUpDestiny() < DestinyData.getFirstBreakId()) then
			-- 紫色
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_1245"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. (DestinyData.destinyNumForQuality( ) - DestinyData.getCurDestiny())
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("key_3106") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("key_2017") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(0xf9,0x59,0xff))
		elseif(DestinyData.getUpDestiny()== DestinyData.getFirstBreakId()) then
			-- 紫色
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_1245"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. (DestinyData.destinyNumForQuality( ) - DestinyData.getCurDestiny())
			if tmp02 == nil or string.len(tmp02) == 0 then
				print("..................194, data is innormal")
				tmp02 = "202"
			end
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("key_3106") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("key_3384") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(0xf9,0x59,0xff))
		elseif( DestinyData.getUpDestiny()<= DestinyData.getIndexBreakId(2)  and DestinyData.getUpDestiny()> DestinyData.getFirstBreakId()) then
			-- 紫色装备羁绊
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_4034"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. DestinyData.getIndexBreakId(2) - DestinyData.getCurDestiny()
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("key_4035") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("key_4036") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(0xe4,0x00,0xff))
			levelUpContent[5]=	CCLabelTTF:create( GetLocalizeStringBy("key_4037") , g_sFontPangWa, 25)
			levelUpContent[5]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[6]=	CCLabelTTF:create( GetLocalizeStringBy("key_4038") , g_sFontPangWa, 25)
			levelUpContent[6]:setColor(ccc3(0xe4,0x00,0xff))
			levelUpContent[7]=	CCLabelTTF:create( GetLocalizeStringBy("key_4039") , g_sFontPangWa, 25)
			levelUpContent[7]:setColor(ccc3(0x80,0xff,0x18))
		elseif(DestinyData.getUpDestiny()<= DestinyData.getIndexBreakId(3)  and DestinyData.getUpDestiny()> DestinyData.getIndexBreakId(2)) then
			-- 紫色宝物羁绊
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_4034"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. DestinyData.getIndexBreakId(3) - DestinyData.getCurDestiny()
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("key_4035") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("key_4036") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(0xe4,0x00,0xff))
			levelUpContent[5]=	CCLabelTTF:create( GetLocalizeStringBy("key_4037") , g_sFontPangWa, 25)
			levelUpContent[5]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[6]=	CCLabelTTF:create( GetLocalizeStringBy("zzh_1171") , g_sFontPangWa, 25)
			levelUpContent[6]:setColor(ccc3(0xe4,0x00,0xff))
			levelUpContent[7]=	CCLabelTTF:create( GetLocalizeStringBy("key_4039") , g_sFontPangWa, 25)
			levelUpContent[7]:setColor(ccc3(0x80,0xff,0x18))
		elseif DestinyData.getUpDestiny()<= DestinyData.getIndexBreakId(4) and DestinyData.getUpDestiny() > DestinyData.getIndexBreakId(3) then
			-- 升橙
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_4034"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. (DestinyData.getIndexBreakId(4) - DestinyData.getCurDestiny())
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("key_3106") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("zzh_1292") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(255,0x84,0))
			levelUpContent[5] = CCLabelTTF:create( GetLocalizeStringBy("zzh_1293") , g_sFontPangWa, 25)
			levelUpContent[5]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[6] = CCLabelTTF:create( GetLocalizeStringBy("zzh_1294") , g_sFontPangWa, 25)
			levelUpContent[6]:setColor(ccc3(255,0x84,0))
		elseif DestinyData.getUpDestiny()<= DestinyData.getIndexBreakId(5) and DestinyData.getUpDestiny() > DestinyData.getIndexBreakId(4) then
			-- 橙色宝物羁绊
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_4034"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. (DestinyData.getIndexBreakId(5) - DestinyData.getCurDestiny())
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("djn_199") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("zzh_1244") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(0xff,0xa5,0x00))
			levelUpContent[5] = CCLabelTTF:create( GetLocalizeStringBy("djn_200") , g_sFontPangWa, 25)
			levelUpContent[5]:setColor(ccc3(0x80,0xff,0x18))
		elseif DestinyData.getUpDestiny()<= DestinyData.getIndexBreakId(6) and DestinyData.getUpDestiny() > DestinyData.getIndexBreakId(5) then
			-- 升红
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_4034"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. (DestinyData.getIndexBreakId(6) - DestinyData.getCurDestiny())
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("key_3106") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("lic_1814") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(255, 0x27, 0x27))
			levelUpContent[5] = CCLabelTTF:create( GetLocalizeStringBy("zzh_1293") , g_sFontPangWa, 25)
			levelUpContent[5]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[6] = CCLabelTTF:create( GetLocalizeStringBy("lic_1817") , g_sFontPangWa, 25)
			levelUpContent[6]:setColor(ccc3(255, 0x27, 0x27))
		elseif DestinyData.getUpDestiny()<= DestinyData.getIndexBreakId(7) and DestinyData.getUpDestiny() > DestinyData.getIndexBreakId(6) then
			-- 红色宝物羁绊
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_4034"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. (DestinyData.getIndexBreakId(7) - DestinyData.getCurDestiny())
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("lgx_1101") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("lgx_1102") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(0xff,0x27,0x27))
			levelUpContent[5] = CCLabelTTF:create( GetLocalizeStringBy("djn_200") , g_sFontPangWa, 25)
			levelUpContent[5]:setColor(ccc3(0x80,0xff,0x18))
		elseif DestinyData.getUpDestiny()<= DestinyData.getIndexBreakId(8) and DestinyData.getUpDestiny() > DestinyData.getIndexBreakId(7) then
			-- 红色宝物羁绊
			levelUpContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_4034"), g_sFontPangWa, 25)
			levelUpContent[1]:setColor(ccc3(0x80,0xff,0x18))
			local tmp02 = "" .. (DestinyData.getIndexBreakId(8) - DestinyData.getCurDestiny())
			levelUpContent[2]= CCLabelTTF:create(tmp02, g_sFontPangWa, 25)
			levelUpContent[2]:setColor(ccc3(0x00,0xe4,0xff))
			levelUpContent[3]=	CCLabelTTF:create( GetLocalizeStringBy("key_3106") , g_sFontPangWa, 25)
			levelUpContent[3]:setColor(ccc3(0x80,0xff,0x18))
			levelUpContent[4]=	CCLabelTTF:create( GetLocalizeStringBy("lcyx_9051") , g_sFontPangWa, 25)
			levelUpContent[4]:setColor(ccc3(0xff,0x27,0x27))
		end
	end

	if(not table.isEmpty(levelUpContent)) then
		_levelUpNode = BaseUI.createHorizontalNode(levelUpContent)
		local bottomBgScale= _bottomBg:getScale()
		_levelUpNode:setPosition(ccp(_layerSize.width/2, _bottomBg:getContentSize().height*bottomBgScale+30*MainScene.elementScale+_bottomBg:getPositionY() ))--_layerSize.height*0.253))
		_levelUpNode:setAnchorPoint(ccp(0.5,0))
		_levelUpNode:setScale(MainScene.elementScale)
		_bgLayer:addChild(_levelUpNode)
	end

end

function tapAthenaCB()
	if not (DataCache.getSwitchNodeState(ksSwitchStarSoul,false)) then
		require "db/DB_Switch"
		local switchDBInfo = DB_Switch.getDataById(ksSwitchStarSoul)
		local switchLv = tonumber(switchDBInfo.level)
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1326",switchLv))
		return
	end
	require "script/ui/athena/AthenaMainLayer"
	AthenaMainLayer.createLayer()
end

-- 创建中部的UI
function createMiddleUI(  )
	-- local copyStar= CCSprite:create("images/destney/copy_star.png")
	local height= _layerSize.height - _topBg:getContentSize().height*g_fScaleX-33*MainScene.elementScale
	-- copyStar:setPosition()
	_starContent= {}
	_starContent[1]= CCSprite:create("images/destney/copy_star.png")
	_starContent[2]= CCSprite:create("images/common/star_big.png")
	_starContent[3]= CCRenderLabel:create("X" .. DestinyData.getHasScore() , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)

	local starNode= BaseUI.createHorizontalNode(_starContent)
	starNode:setPosition(12*MainScene.elementScale, height )
	starNode:setAnchorPoint(ccp(0,0.5))
	starNode:setScale(MainScene.elementScale)
	_bgLayer:addChild(starNode)

	local menu= CCMenu:create()
	menu:setPosition(0,0)
	_bgLayer:addChild(menu)

	local backBtn= CCMenuItemImage:create("images/athena/change_n.png", "images/athena/change_h.png")
	backBtn:setPosition(ccp(_layerSize.width-10*g_fScaleX, height-14*MainScene.elementScale ))
	backBtn:setAnchorPoint(ccp(1,0.5))
	backBtn:setScale(MainScene.elementScale)
	backBtn:registerScriptTapHandler(backCallBack)
	menu:addChild(backBtn)

	--主角学习技能 add by zhangqiang
	learnSkillBtn = CCMenuItemImage:create("images/replaceskill/learn_btn_n.png", "images/replaceskill/learn_btn_h.png")
	learnSkillBtn:setAnchorPoint(ccp(1,0.5))
	learnSkillBtn:setPosition(_layerSize.width-135*g_fScaleX, height-14*MainScene.elementScale )
	learnSkillBtn:setScale(MainScene.elementScale)
	learnSkillBtn:registerScriptTapHandler(tapLearnSkillBtnCb)
	menu:addChild(learnSkillBtn)

	local athenaBtn = CCMenuItemImage:create("images/athena/enter_n.png","images/athena/enter_h.png")
	athenaBtn:setAnchorPoint(ccp(1,0.5))
	athenaBtn:setPosition(ccp(_layerSize.width - 260*g_fScaleX,height - 14*MainScene.elementScale))
	athenaBtn:setScale(MainScene.elementScale)
	athenaBtn:registerScriptTapHandler(tapAthenaCB)
	menu:addChild(athenaBtn)

	local autoKeyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(200, 73), GetLocalizeStringBy("djn_249"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(autoKeyBtn)
    autoKeyBtn:setAnchorPoint(ccp(1, 0))
    autoKeyBtn:setPosition(ccpsprite(0.75, 0.06, menu))
    autoKeyBtn:setPosition(ccp(_layerSize.width - 15, _bottomBg:getContentSize().height*g_fScaleX+60*MainScene.elementScale+_bottomBg:getPositionY() ))--_layerSize.height*0.253))

    autoKeyBtn:registerScriptTapHandler(autoKeyAction)
    autoKeyBtn:setScale(MainScene.elementScale)

	--添加红点提示
	-- require "script/ui/replaceSkill/learnSkill/SelectSkillLayer"
	-- SelectSkillLayer.createRedTip(learnSkillBtn)

	-- 文字：点亮X个星座后主角可。。。
	print("(DestinyData.getUpDestiny() : ",DestinyData.getUpDestiny() , "  DestinyData.getFirstBreakId() : ",  DestinyData.getFirstBreakId())
	createUpLabel()

	--	_needStarContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_3337"),g_sFontName , 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_needStarNum= DestinyData.getStarNumForUp()
	_needStarContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_3337"),g_sFontName , 23)
	_needStarContent[1]:setColor(ccc3(0xff,0xff,0xff))
	_needStarContent[2]= CCSprite:create("images/common/star.png")
	--	_needStarContent[3]= CCRenderLabel:create("X" .. DestinyData.getStarNumForUp() ,g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_needStarContent[3]= CCLabelTTF:create("X" .. DestinyData.getStarNumForUp() ,g_sFontName, 23)
	_needStarContent[3]:setColor(ccc3(0xff,0xff,0xff))

	local needStarNode= BaseUI.createHorizontalNode(_needStarContent)
	needStarNode:setPosition(_layerSize.width*0.4, _layerSize.height*0.321)
	needStarNode:setScale(MainScene.elementScale)
	needStarNode:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(needStarNode)

	_silverContent[1]= CCSprite:create("images/common/coin.png")
	local tmp02 = "" .. DestinyData.getSilverNumForUp()
	_needSliverNum = DestinyData.getSilverNumForUp()
	if tmp02 == nil or string.len(tmp02) == 0 then
		print("..................263, data is innormal")
		tmp02 = "302"
	end
	--	_silverContent[2]= CCRenderLabel:create(tmp02 ,g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_silverContent[2]= CCLabelTTF:create(tmp02 ,g_sFontName, 23)
	_silverContent[2]:setColor(ccc3(0xff,0xff,0xff))
	local silverNode = BaseUI.createHorizontalNode(_silverContent)
	silverNode:setPosition(_layerSize.width*0.58, _layerSize.height*0.321)
	silverNode:setScale(MainScene.elementScale)
	silverNode:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(silverNode)

	createSealNode()

end

function createSealNode( )
	if(_sealNode~= nil ) then
		_sealNode:removeFromParentAndCleanup(true)
		_sealNode= nil
	end
	-- and DestinyData.getUpDestiny()~= 
	if(DestinyData.getUpDestiny()== nil ) then
		return 
	end
	-- DestinyData.getUpDestiny() and  DestinyData.get ) then
	if(DestinyData.isBreak() and DestinyData.getFirstBreakId( ) == DestinyData.getUpDestiny() ) then
		_sealNode= createUpLabel_01()
	elseif(DestinyData.isBreak() ) then
		_sealNode = createUpLabel_02()
	else
		_sealNode= DestinyUtil.getSealNode()	
	end
	_sealNode:setPosition(ccp(_layerSize.width/2,_layerSize.height*0.371))
	_sealNode:setAnchorPoint(ccp(0.5,0))
	_sealNode:setScale(MainScene.elementScale)
	_bgLayer:addChild(_sealNode)

	-- print("refreshMiddleUI  refreshMiddleUI refreshMiddleUI  rrrrrrr 66666  ")
end

-- 
function createUpLabel_01( )
	local upContent= {}
	--	upContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_2746") , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	upContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_2746") , g_sFontPangWa, 23)
	upContent[1]:setColor(ccc3(0x00,0xe4,0xff))
	--	upContent[2]= CCRenderLabel:create("5" , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	upContent[2]= CCLabelTTF:create("5" , g_sFontPangWa, 23)
	upContent[2]:setColor(ccc3(0xf9,0x59,0xff))
	--	upContent[3]=  CCRenderLabel:create(GetLocalizeStringBy("key_1119") , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	upContent[3]=  CCLabelTTF:create(GetLocalizeStringBy("key_1119") , g_sFontPangWa, 23)
	upContent[3]:setColor(ccc3(0x00,0xe4,0xff))

	local upNode= BaseUI.createHorizontalNode(upContent)
	return upNode
end

function createUpLabel_02(  )
	local upContent= {}
	--	upContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_1141") , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	upContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_1141") , g_sFontPangWa, 23)
	upContent[1]:setColor(ccc3(0xf9,0x59,0xff))
	--	upContent[2]= CCRenderLabel:create(GetLocalizeStringBy("key_1064") , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	upContent[2]= CCLabelTTF:create(GetLocalizeStringBy("key_1064") , g_sFontPangWa, 23)
	upContent[2]:setColor(ccc3(0x00,0xe4,0xff))

	local upNode= BaseUI.createHorizontalNode(upContent)
	return upNode
end


function refreshMiddleUI(  )
	if(_needStarNum ~= DestinyData.getStarNumForUp()) then
		_needStarContent[3]:setString("X" .. DestinyData.getStarNumForUp())
		_needStarNum = DestinyData.getStarNumForUp()
	end
	_starContent[3]:setString("X" .. DestinyData.getHasScore())
	if( _needSliverNum ~= DestinyData.getSilverNumForUp() ) then
		_silverContent[2]:setString("" .. DestinyData.getSilverNumForUp())
	end

	createSealNode()
	createUpLabel()

end


function createDestinyUI(  )
	
	--创建蓝色的线
	createLineSp()
	--创建主角头像背景
	createHeroSp()
	--创建天命球
	createDestinyItem()


	--DestinyData.isNessaryBreak()
end

-- 创建 武将背景
function createHeroSp( )
	-- 显示武将
	if(_heroSp~= nil) then
		_heroSp:removeFromParentAndCleanup(true)
		_heroSp= nil
	end
	--进阶前后头像不同，所以有两种坐标情况
	_heroSp= DestinyUtil.getCurHeroBg()
	_heroSp:setPosition(_layerSize.width/2,_layerSize.height*0.3)

	if( DestinyData.getCurDestiny() >= DestinyData.getFirstBreakId()) and DestinyData.getCurDestiny() < DestinyData.getIndexBreakId(4) then
		_heroSp:setPosition(_layerSize.width/2,_layerSize.height*0.28)
	elseif DestinyData.getCurDestiny() >= DestinyData.getIndexBreakId(4) then
		_heroSp:setPosition(_layerSize.width/2,_layerSize.height*0.34)
	end

	_heroSp:setAnchorPoint(ccp(0.5,0))
	_heroSp:setScale(MainScene.elementScale)
	_bgLayer:addChild(_heroSp)
end


-- 创建星线
function createLineSp( tpic )
	if(_lineSp ~= nil) then
		_lineSp:removeFromParentAndCleanup(true)
		_lineSp= nil
	end

	print("DestinyData.getCurDestiny  is : ", DestinyData.getCurDestiny())
	--若当前有天赋，则进入第一个if
	if(DestinyData.getCurDestiny() > 0 or tpic) then
		_lineSp= CCSprite:create("images/destney/line.png") 
		_lineSp:setAnchorPoint(ccp(0.5,0.5))
	--若当前没有天赋（即一次天赋也没升过）
	else
		_lineSp= CCSprite:create("images/destney/line_0.png")
		_lineSp:setAnchorPoint(ccp(0.5,0.5))
		
	end
	_lineSp:setPosition(_layerSize.width*0.5,_layerSize.height*0.55)
	_lineSp:setScale(MainScene.elementScale)
	_bgLayer:addChild(_lineSp,101)
end

function createDestinyItem( )
	local menu= CCMenu:create()
	menu:setPosition(0,0)
	_lineSp:addChild(menu)

	-- 当前升级星座
	--得到中间要点击的天命的元素
	_curDestinyItem= DestinyUtil.getCurDestinyItem()
	_curDestinyItem:setPosition(_lineSp:getContentSize().width/2,0.1902*_lineSp:getContentSize().height)
	_curDestinyItem:setAnchorPoint(ccp(0.5,0.5))
	-- local scale = _curDestinyItem:getScale()
	-- _curDestinyItem:setScale(0.7*scale)
	_curDestinyItem:registerScriptTapHandler(destinyItemCB)
	menu:addChild(_curDestinyItem,1,_ksCurDestineyTag)

	--当前升级星座名字
	--默认名字为“未开启”
	local curName= GetLocalizeStringBy("key_3292")

	--DestinyData.getUpDestinyData() 的目的是 得到当前要升级的天命（也就是中间的那个球的数据）
	if( DestinyData.getUpDestinyData() ) then
		--得到要升级的天命的名字
		curName=  DestinyData.getUpDestinyData().name
	end
	if curName == nil or string.len(curName) == 0 then
		print("..................curName, data is innormal")
	end
	--	_curDestinyLabel= CCRenderLabel:create(curName , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_curDestinyLabel= CCLabelTTF:create(curName , g_sFontPangWa, 25)
	_curDestinyLabel:setColor(ccc3(0xff,0xff,0xff))
	_curDestinyLabel:setPosition(_curDestinyItem:getContentSize().width/2, _curDestinyItem:getContentSize().height+1*MainScene.elementScale)
	_curDestinyLabel:setAnchorPoint(ccp(0.5,0))
	_curDestinyItem:addChild(_curDestinyLabel)

	--得到最后天命的元素（最右面的那个）
	_aftDestinyItem= DestinyUtil.getAftDestinyItem()
	_aftDestinyItem:setPosition(0.6734*_lineSp:getContentSize().width ,0.2883*_lineSp:getContentSize().height)
	_aftDestinyItem:setAnchorPoint(ccp(0.5,0.5))
	local scale = _aftDestinyItem:getScale()
	_aftDestinyItem:setScale(0.75*scale)
	menu:addChild(_aftDestinyItem,1,_ksAftDestineyTag)

	--after 升级星座名字
	local afterName= GetLocalizeStringBy("key_3292")
	if( DestinyData.getAftDestinyData() ) then
		afterName=  DestinyData.getAftDestinyData().name
	end
	if afterName == nil or string.len(afterName) == 0 then
		print("..................afterName, data is innormal")
	end
	--	_aftDestinyLabel= CCRenderLabel:create( afterName, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_aftDestinyLabel= CCLabelTTF:create( afterName, g_sFontPangWa, 25)
	_aftDestinyLabel:setColor(ccc3(0xff,0xff,0xff))
	_aftDestinyLabel:setPosition(_aftDestinyItem:getContentSize().width/2, _aftDestinyItem:getContentSize().height+1*MainScene.elementScale)
	_aftDestinyLabel:setAnchorPoint(ccp(0.5,0))
	_aftDestinyItem:addChild(_aftDestinyLabel)

	--当前获得的天命，因为涉及是否是第一次升级天命，所以当前有要升级的天命id不等于0时才有前一个天命
	if(DestinyData.getCurDestiny()~= 0 ) then
		--得到已获得的天命的元素（第一个球）
		_preDestineyItem = DestinyUtil.getPreDestinyItem()
		_preDestineyItem:setPosition(_lineSp:getContentSize().width*0.3266,0.2883*_lineSp:getContentSize().height)
		_preDestineyItem:setAnchorPoint(ccp(0.5,0.5))
		local scale= _preDestineyItem:getScale()
		_preDestineyItem:setScale(0.75*scale)
		_preDestineyItem:registerScriptTapHandler(destinyItemCB)
		menu:addChild(_preDestineyItem,1, _ksPreDestineyTag)
		local tmpName =  DestinyData.getCurDestinyData().name
		if tmpName == nil or string.len(tmpName) == 0 then
			print("..................afterName, data is innormal")
			tmpName = "tmpName"
		end
		--		_preDestineyLabel = CCRenderLabel:create(tmpName , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		_preDestineyLabel = CCLabelTTF:create(tmpName , g_sFontPangWa, 25)
		_preDestineyLabel:setColor(ccc3(0xff,0xff,0xff))
		_preDestineyLabel:setPosition(_preDestineyItem:getContentSize().width/2, _preDestineyItem:getContentSize().height+1*MainScene.elementScale)
		_preDestineyLabel:setAnchorPoint(ccp(0.5,0))
		_preDestineyItem:addChild(_preDestineyLabel)
	-- elseif( DestinyData.getCurDestiny()==0 and tpos == nil ) then
	-- 	_curDestinyItem:setPosition(5*MainScene.elementScale,15*MainScene.elementScale)
	-- 	_aftDestinyItem:setPosition(0.3596*_lineSp:getContentSize().width ,0.2883*_lineSp:getContentSize().height)
	end
end

-- 底部的框，显示统帅，战斗力等东西
function createBottomUi(  )
	_bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
	_bottomBg:setContentSize(CCSizeMake(633,138))
	_bottomBg:setScale(g_fScaleX)
	_bottomBg:setPosition(_bgLayer:getContentSize().width/2, 25*MainScene.elementScale)
	_bottomBg:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(_bottomBg,11)

	-- 创建天命属性sprite
	local destinyLabelBg= CCScale9Sprite:create("images/common/astro_labelbg.png")
	destinyLabelBg:setContentSize(CCSizeMake(183,40))
	destinyLabelBg:setAnchorPoint(ccp(0.5,0.5))
	destinyLabelBg:setPosition(_bottomBg:getContentSize().width/2, _bottomBg:getContentSize().height)
	_bottomBg:addChild(destinyLabelBg)

	--	local destinyLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2123"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local destinyLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2123"), g_sFontPangWa, 24)
	destinyLabel:setColor(ccc3(0xff,0xf6,0x00))
	destinyLabel:setPosition(destinyLabelBg:getContentSize().width/2, destinyLabelBg:getContentSize().height/2)
	destinyLabel:setAnchorPoint(ccp(0.5,0.5))
	destinyLabelBg:addChild(destinyLabel)

	-- 统帅
	local captionSp = CCSprite:create("images/common/caption.png")
	captionSp:setPosition(_bottomBg:getContentSize().width*0.05, _bottomBg:getContentSize().height*0.6812)
	_bottomBg:addChild(captionSp)

	-- 记录统帅的值，若升级时不变， 则不变化
	_captionNum= DestinyData.calHeroProperty(6)
	_captionLabel= CCLabelTTF:create( "+" .. DestinyData.calHeroProperty(6) , g_sFontPangWa, 23)
	_captionLabel:setColor(ccc3(0x70,0xff,0x18))
	_captionLabel:setPosition(_bottomBg:getContentSize().width*0.172 ,_bottomBg:getContentSize().height*0.6812)
	_captionLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_captionLabel)

	-- 武力
	local forceSp = CCSprite:create("images/common/force.png")
	forceSp:setPosition(_bottomBg:getContentSize().width*0.05, _bottomBg:getContentSize().height*0.413)
	_bottomBg:addChild(forceSp)

	_forceNum= DestinyData.calHeroProperty(7) 
	_forceLabel= CCLabelTTF:create( "+" .. DestinyData.calHeroProperty(7) , g_sFontPangWa, 23)
	_forceLabel:setColor(ccc3(0xff,0x17,0x0c))
	_forceLabel:setPosition(_bottomBg:getContentSize().width*0.172 ,_bottomBg:getContentSize().height*0.413)
	_forceLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_forceLabel)

	-- 智力
	local intelligenceSp= CCSprite:create("images/common/intelligence.png")
	intelligenceSp:setPosition(_bottomBg:getContentSize().width*0.05, _bottomBg:getContentSize().height*0.145)
	_bottomBg:addChild(intelligenceSp)
	
	_intelligenceNum =  DestinyData.calHeroProperty(8)
	_intelligenceLabel= CCLabelTTF:create( "+" .. DestinyData.calHeroProperty(8) , g_sFontPangWa, 23)
	_intelligenceLabel:setColor(ccc3(0xf9,0x59,0xff))
	_intelligenceLabel:setPosition(_bottomBg:getContentSize().width*0.172 ,_bottomBg:getContentSize().height*0.145)
	_intelligenceLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_intelligenceLabel)

	-- 攻击

	local attTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1727"),g_sFontName, 23)
	attTitleLabel:setColor(ccc3(0xff,0xff,0xff))
	attTitleLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.415,_bottomBg:getContentSize().height*0.514 ))
	attTitleLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(attTitleLabel)

	_attNum = DestinyData.calHeroProperty(9)
	_attLabel= CCLabelTTF:create("+" .. DestinyData.calHeroProperty(9) ,g_sFontName, 23)
	_attLabel:setColor(ccc3(0x70,0xff,0x18))
	_attLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.52,_bottomBg:getContentSize().height*0.514 ))
	_attLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_attLabel)

	-- 生命
	--	local lifeTitleLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2075"),g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local lifeTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2075"),g_sFontName, 23)
	lifeTitleLabel:setColor(ccc3(0xff,0xff,0xff))
	lifeTitleLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.702,_bottomBg:getContentSize().height*0.514 ))
	lifeTitleLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(lifeTitleLabel)

	_lifeNum= DestinyData.calHeroProperty(1)
	_lifeLabel= CCLabelTTF:create("+" .. DestinyData.calHeroProperty(1),g_sFontName, 23)
	_lifeLabel:setColor(ccc3(0x70,0xff,0x18))
	_lifeLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.815,_bottomBg:getContentSize().height*0.514 ))
	_lifeLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_lifeLabel)

	-- 物防
	--	local phyDefTitleLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2804"),g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local phyDefTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2804"),g_sFontName, 23)
	phyDefTitleLabel:setColor(ccc3(0xff,0xff,0xff))
	phyDefTitleLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.415,_bottomBg:getContentSize().height*0.251 ))
	phyDefTitleLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(phyDefTitleLabel)

	_phyDefNum= DestinyData.calHeroProperty(4)
	_phyDefLabel= CCLabelTTF:create("+" .. DestinyData.calHeroProperty(4),g_sFontName, 23)
	_phyDefLabel:setColor(ccc3(0x70,0xff,0x18))
	_phyDefLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.52,_bottomBg:getContentSize().height*0.251 ))
	_phyDefLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_phyDefLabel)


	-- 法防
	--	local magDefTitleLabel= CCRenderLabel:create(GetLocalizeStringBy("key_1731"),g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local magDefTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1731"),g_sFontName, 23)
	magDefTitleLabel:setColor(ccc3(0xff,0xff,0xff))
	magDefTitleLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.702,_bottomBg:getContentSize().height*0.251 ))
	magDefTitleLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(magDefTitleLabel)

	_magDefNum=  DestinyData.calHeroProperty(5)
	_magDefLabel= CCLabelTTF:create("+" ..  DestinyData.calHeroProperty(5),g_sFontName, 23)
	_magDefLabel:setColor(ccc3(0x70,0xff,0x18))
	_magDefLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.815,_bottomBg:getContentSize().height*0.251 ))
	_magDefLabel:setAnchorPoint(ccp(0,0))
	_bottomBg:addChild(_magDefLabel)

	-- 新手引导
	_bottmNodeForLead= CCNode:create()
	_bottmNodeForLead:setPosition(ccp(0,0))
	_bottmNodeForLead:setContentSize(CCSizeMake(_bottomBg:getContentSize().width, _bottomBg:getContentSize().height+18))
	_bottomBg:addChild(_bottmNodeForLead)


end

-- 刷新底部的UI
function refreshBottomUI( )
	if(_captionNum ~= DestinyData.calHeroProperty(6) ) then
		_captionLabel:setString("+" .. DestinyData.calHeroProperty(6))
		_captionNum= DestinyData.calHeroProperty(6)
	end
	if(_forceNum ~=  DestinyData.calHeroProperty(7)) then
		_forceLabel:setString( "+" .. DestinyData.calHeroProperty(7))
		_forceNum = DestinyData.calHeroProperty(7)
	end
	if(_intelligenceNum~= DestinyData.calHeroProperty(8)) then
		_intelligenceLabel:setString("+" .. DestinyData.calHeroProperty(8))
		_intelligenceNum= DestinyData.calHeroProperty(8)
	end
	if(_attNum ~= DestinyData.calHeroProperty(9) ) then
		_attLabel:setString("+" .. DestinyData.calHeroProperty(9))
		_attNum = DestinyData.calHeroProperty(9)
	end
	if(_lifeNum~= DestinyData.calHeroProperty(1)) then
		_lifeLabel:setString("+" .. DestinyData.calHeroProperty(1))
		_lifeNum = DestinyData.calHeroProperty(1)
	end
	if(_phyDefNum ~=  DestinyData.calHeroProperty(4)) then
		_phyDefLabel:setString("+" .. DestinyData.calHeroProperty(4))
		_phyDefNum= DestinyData.calHeroProperty(4)
	end

	if( _magDefNum ~= DestinyData.calHeroProperty(5)) then 
		_magDefLabel:setString("+" .. DestinyData.calHeroProperty(5))
		_magDefNum=  DestinyData.calHeroProperty(5)
	end

end


function requestCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		print("天命回调")
		print_t(dictData)
		-- print_t(dictData.ret)
		--dictData.ret结构 摘自 后端文档
		--[
		--	uid 			玩家uid
		--	cur_break 		当前的突破表id
		--	cur_destiny 	当前的天命Id
		--	va_destiny 		暂时没用
		--	has_score 		当前剩余的副本星数
		--	all_score 		所有的副本星数
		--]
		--DestinyData中保存dictData.ret数据
		DestinyData.setDestinyInfo(dictData.ret)

		--创建包括统帅，武力，智力，攻击，物防，生命，法防的天赋属性框
		createBottomUi()
		--创建背景蓝色的线，主角头像背景，天赋球
		createDestinyUI()
		--创建返回按钮，说明文字
		createMiddleUI()
		--下面这个函数里没有内容（华仔忘删了）
		didCreateOver()
		-- 天命新手第2步
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideDestinyGuide2()
			-- 主角换技能2
			addGuideChangeSkillGuide2()
		end))
		_bgLayer:runAction(seq)

	end
end

function createLayer( )
	init()
	_bgLayer = CCLayer:create()

	MainScene.getAvatarLayerObj():setVisible(false)
	MenuLayer.getObject():setVisible(true)
	BulletinLayer.getLayer():setVisible(true)

	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local avatarLayerSize = MainScene.getAvatarLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()

	_layerSize = {width= 0, height=0}
	_layerSize.width= g_winSize.width 
	_layerSize.height =g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX

	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))

	-- 背景
	_destinyBg = CCScale9Sprite:create("images/destney/destney_bg.png")
	_destinyBg:setScale(g_fBgScaleRatio)
	_destinyBg:setAnchorPoint(ccp(0.5, 0.5))
	_destinyBg:setPosition(ccp(_layerSize.width/2,_layerSize.height/2))
	_bgLayer:addChild(_destinyBg)

	-- 顶部
	--包括人物等级，姓名，vip等级，银币，金币
	createTopUI()
	
	Network.rpc(requestCallback, "destiny.getDestinyInfo", "destiny.getDestinyInfo", nil, true)
	return _bgLayer
end

--------------------------------------[[ 回调事件 ]]---------------------------------------------------

function fnEndCallback( )

	-- _curDestinyItem:removeFromParentAndCleanup(true)
	-- _curDestinyItem= nil

	-- _aftDestinyItem:removeFromParentAndCleanup(true)
	-- _aftDestinyItem= nil

	-- createDestinyItem()
	_aftDestinyItem:setVisible(true)
	_curDestinyItem:setEnabled(true)
	
end

function releaseDestinyItem( ... )

	if(_preDestineyItem ~= nil ) then
		_preDestineyItem:removeFromParentAndCleanup(true)
		_preDestineyItem= nil
	end
	if(_curDestinyItem ~= nil ) then
		_curDestinyItem:removeFromParentAndCleanup(true)
		_curDestinyItem= nil
	end
	if(_aftDestinyItem ~= nil ) then
		_aftDestinyItem:removeFromParentAndCleanup(true)
		_aftDestinyItem= nil
	end

end

-- 天命星座的action 动画
function destinyItemRun( )
	-- if(_preDestineyItem ~= nil ) then
	-- 	_preDestineyItem:removeFromParentAndCleanup(true)
	-- 	_preDestineyItem= nil
	-- end
	releaseDestinyItem()
	createDestinyItem()
	_aftDestinyItem:setVisible(false)

	_preDestineyItem:setPosition(_lineSp:getContentSize().width/2,0.1902*_lineSp:getContentSize().height)
	_preDestineyItem:setScale(MainScene.elementScale)

	local preDestMoveTo = ccp(_lineSp:getContentSize().width*0.3266,0.2883*_lineSp:getContentSize().height)
	local actionArr = CCArray:create()
	actionArr:addObject(CCMoveTo:create(1, preDestMoveTo))
	actionArr:addObject(CCScaleTo:create(1, _curDestinyItem:getScale() * 0.75))
	_preDestineyItem:runAction(CCSpawn:create(actionArr))

	_curDestinyItem:setPosition(0.6734*_lineSp:getContentSize().width ,0.2883*_lineSp:getContentSize().height)
	_curDestinyItem:setScale(0.75*MainScene.elementScale)
	_curDestinyItem:setEnabled(false)

	local cuDestMoveTo= ccp(_lineSp:getContentSize().width/2,0.1902*_lineSp:getContentSize().height)
	local actionArr_01	= CCArray:create()
	local spawnActions 	= CCArray:create()
	spawnActions:addObject(CCMoveTo:create(1,cuDestMoveTo))
	spawnActions:addObject(CCScaleTo:create(1, 1*_aftDestinyItem:getScale()/0.75))
	local spawn = CCSpawn:create(spawnActions)
	actionArr_01:addObject(spawn)
	actionArr_01:addObject(CCCallFuncN:create(fnEndCallback))
	_curDestinyItem:runAction(CCSequence:create(actionArr_01))


end

function backCallBack( tag, item )
	require "script/ui/replaceSkill/EquipmentLayer"
		local closeCb = function ( ... )
			local destinyLayer = DestinyLayer.createLayer()
  			MainScene.changeLayer(destinyLayer, "destinyLayer")
		end
	EquipmentLayer.showLayer(closeCb)
end

--主角学习技能按钮回调 add by zhangqiang
function tapLearnSkillBtnCb( p_tag, p_item )
	---[==[ 主角换技能 新手引导屏蔽层
	---------------------新手引导---------------------------------
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideChangeSkill) then
		require "script/guide/ChangeSkillGuide"
		ChangeSkillGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	--功能节点是否开启
	if not DataCache.getSwitchNodeState(ksChangeSkill) then
		return
	end

	require "script/ui/replaceSkill/ReplaceSkillData"
	require "script/ui/tip/SingleTip"
	if ReplaceSkillData.getAllInfo() == nil then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_68"))
		return
	end

	require "script/ui/replaceSkill/learnSkill/SelectSkillLayer"
	SelectSkillLayer.showLayer()
end

function destinyItemCB( tag, item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("  DestinyData.isBreak() 888 000 is :  ",DestinyData.isBreak() )
	--若当前点击的为要升级的球
	--（其实剩下的两个球都不能点，华仔这么写是为了方便扩展，毕竟策划酷爱一时兴起无理由暴走）
	if(tag==_ksCurDestineyTag) then

		---[==[天命 新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.29
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideDestiny) then
			require "script/guide/DestinyGuide"
			DestinyGuide.changLayer()
		end
		---------------------end-------------------------------------
		--]==]
		print(GetLocalizeStringBy("key_3394"))

		print(" DestinyData.getUpDestiny()  is : ",  DestinyData.getUpDestiny() )
		--当前要点击的天命未开启
		if( DestinyData.getUpDestiny()== nil ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2139"))
			return 
		end
		--升级银币不足
		if(UserModel.getSilverNumber() < DestinyData.getSilverNumForUp() ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1197"))
			return
		end
		--副本星值不足
		if(DestinyData.getHasScore() <DestinyData.getStarNumForUp() ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2738"))
			return 
		end
		print(" DestinyData.isNessaryBreak( ) is : ",  DestinyData.isNessaryBreak( ))
		--到达了突破点，且主角满足了突破所需的进阶条件
		if(  DestinyData.isBreak( ) and  not DestinyData.isNessaryBreak( ) ) then
			--DestinyData.getTransferNum() 读表得到主角突破要满足的进阶等级
			AnimationTip.showTip(GetLocalizeStringBy("key_1883").. DestinyData.getTransferNum() ..GetLocalizeStringBy("key_1693"))
			return
		end

		print("  DestinyData.isBreak() 888 000 is :  ",DestinyData.isBreak() )
 		local args = CCArray:create()
 		args:addObject(CCInteger:create( DestinyData.getUpDestiny()))
		Network.rpc(activatCallback, "destiny.activateDestiny", "destiny.activateDestiny", args, true)
	end
end

function activatCallback( cbFlag, dictData, bRet )
	if(dictData.err~= "ok") then
		return 
	end
	--dictData.ret返回的是扣除的副本星数
	DestinyData.addHasScore(-tonumber(dictData.ret))

	UserModel.addSilverNumber(- tonumber(DestinyData.getSilverNumForUp()) )

	-------

	local function starActionCallBack( ... )
		if(tonumber(DestinyData.getCurDestiny() ) == 0 ) then
			
			--传入参数true是为了改变蓝线的图（在我看来可以用是否是当前升级的天命来判断）
			createLineSp(true)
			createDestinyItem()
		end

		if( DestinyData.isBreak() == true) then		
			local heroData=HeroModel.getNecessaryHero()
			-- print(" heroData 01  is : ")
			-- print_t(heroData)
			local fightForce= FightForceModel.getHeroDisplayAffix(heroData.hid )
			-- print("UserModel   UserModel.getAvatarHt1",  UserModel.getAvatarHtid())
			DestinyData.changeHeroHtid()
			-- print("UserModel   UserModel.getAvatarHt3 +++++++++++++++++++++++++",  UserModel.getAvatarHtid())
			local heroData_2=HeroModel.getNecessaryHero()
			-- heroData_2.htid=  UserModel.getAvatarHtid()
			
			if DestinyData.getUpDestiny() == DestinyData.getIndexBreakId(4) 
				or DestinyData.getUpDestiny() == DestinyData.getIndexBreakId(6)
				or DestinyData.getUpDestiny() == DestinyData.getIndexBreakId(8)
			then
				HeroModel.setHeroEvolveLevelByHid(heroData_2.hid,0)
			end

			-- print_t(heroData_2)
			local fightForce_2= FightForceModel.getHeroDisplayAffix(heroData_2.hid )
			fnCreateTransferEffect(fightForce, fightForce_2)
		end
		
		DestinyData.setCurDestiny(DestinyData.getUpDestiny())
		--更新属性缓存
		local UserInfo = HeroModel.getNecessaryHero()
		DestinyData.getDestinyAffix(UserInfo.hid,true)
		createHeroSp()

		local descTables = DestinyData.getAddHeroProperty()
		--漂浮的文字
		LevelUpUtil.showFlyText(descTables)
	
		refreshBottomUI()
		refreshMiddleUI()
		--天命球的移动，当前球前进，下一个球出来
		destinyItemRun()
		refreshTopUI()

		--刷新羁绊属性
		require "script/model/utils/UnionProfitUtil"
		UnionProfitUtil.refreshUnionProfitInfo()
		-- 天命新手第3步
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideDestinyGuide3()
		end))
		_bgLayer:runAction(seq)
	end
	
	-- 星星的动画
	playStarEffect(_starContent[2], _curDestinyItem, starActionCallBack)

end



---------------------------------------[[ 动画特效 ]]---------------------------------------------

function didCreateOver( ... )
	-- playStarEffect(_starContent[2], _curDestinyItem,function ( ... )
	-- 	print(GetLocalizeStringBy("key_1617"))
	-- end)
end


function playStarEffect( beginNode, endNode, callBackFunc )
	local effectLayer 	= BaseUI.createMaskLayer(-1000, nil, nil, 0)
	local runningScene  = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(effectLayer, 1000)

	--播放次数
	local playCount = 4
	local playNum   = 0
	local endNum 	= 0
	local baginPostion = beginNode:convertToWorldSpace(ccp(beginNode:getContentSize().width * 0.5, beginNode:getContentSize().height * 0.5))
	local endPostion   = endNode:convertToWorldSpace(ccp(endNode:getContentSize().width * 0.5, endNode:getContentSize().height * 0.5))
	local moveEndFunc = function ( actionNode )
		actionNode:removeFromParentAndCleanup(true)

		local endBaoEffect =  CCLayerSprite:layerSpriteWithName(CCString:create("images/destney/effect/bao/bao"), -1,CCString:create(""));
		endBaoEffect:setPosition(endPostion)
		effectLayer:addChild(endBaoEffect,1)

		local endBaoEndFunc = function ( ... )
			endBaoEffect:retain()
			endBaoEffect:autorelease()
			endBaoEffect:removeFromParentAndCleanup(true)
			endNum  = endNum + 1
			if(endNum >= playCount) then
				effectLayer:removeFromParentAndCleanup(true)
				effectLayer = nil
				callBackFunc()
			end
			print("end .............. 0")
		end
		local endBaoDelegate = BTAnimationEventDelegate:create()
		endBaoDelegate:registerLayerEndedHandler(endBaoEndFunc)
    	endBaoEffect:setDelegate(endBaoDelegate)
	end

	local beginBaoEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/destney/effect/xingxingbao/xingxingbao"), -1,CCString:create(""));
	beginBaoEffect:setPosition(baginPostion)
	effectLayer:addChild(beginBaoEffect,1)

	local beginBaoEnd = function( ... )
		beginBaoEffect:retain()
		beginBaoEffect:autorelease()
		beginBaoEffect:removeFromParentAndCleanup(true)
		beginBaoEffect = nil
	end

	--粒子系统，李晨阳写的，我还在学习中
	local createStar = function ( i )
		local cNum = 0
		if(i%2 == 0) then
			cNum = -1
		else
			cNum = 1
		end
		local starParticle 	  =  CCParticleSystemQuad:create("images/destney/star_particle.plist")
		starParticle:setPosition(baginPostion)
		starParticle:setAnchorPoint(ccp(0.5, 0.5))
		effectLayer:addChild(starParticle,2)

		local actions 		  = CCArray:create()
		local bezier    	  =ccBezierConfig:new()
		math.randomseed(os.time())
	    bezier.controlPoint_1 = ccp(baginPostion.x + math.random(os.time())%200 * cNum + i * 60 - 150 , baginPostion.y + math.random(os.time())%200 *cNum + i * 60 - 150)
	    bezier.controlPoint_2 = ccp(endPostion.x   + math.random(os.time())%200 * cNum + i * 60 - 150 , endPostion.y   + math.random(os.time())%200 *cNum + i * 60 - 150)
	    bezier.endPosition    = endPostion
	    local bezierTo 		  = CCBezierTo:create(0.4 + 0.2 * i ,bezier)
	    actions:addObject(bezierTo)
		actions:addObject(CCCallFuncN:create(moveEndFunc))
		local seqAction 	  = CCSequence:create(actions)
		starParticle:runAction(seqAction)
	end

	local seqArr = CCArray:create()
	for i=1,4 do
		createStar(i)
	end
    local beginBaoDelegate = BTAnimationEventDelegate:create()
    beginBaoDelegate:registerLayerEndedHandler(beginBaoEnd)
    beginBaoEffect:setDelegate(beginBaoDelegate)
end



-- 创建进阶特效
function fnCreateTransferEffect(pForceValues01, pForceValues02)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
	print("infun  fnCreateTransferEffect   ")
	colorLayer:setTouchEnabled(true)
	colorLayer:setTouchPriority(-32767)
	local function fnHandlerOfTouch(event, x, y)
		if event == "ended" then
			colorLayer:removeFromParentAndCleanup(true)
		end
		return true
	end

	colorLayer:registerScriptTouchHandler(fnHandlerOfTouch, false, -32767, true)
	-- 等级、生命、物攻、法攻、物防、法防
	local nHeightOfAttrBg = 360*g_fScaleY
	local cs9Attr = CCScale9Sprite:create("images/hero/transfer/level_up/bg_ng_attr.png", CCRectMake(0, 0, 209, 49), CCRectMake(86, 14, 45, 20))
	cs9Attr:setPreferredSize(CCSizeMake(g_winSize.height, nHeightOfAttrBg))
	cs9Attr:setPosition(0, 10*g_fScaleY)
	--	cs9Attr:setScale(g_fScaleX)
	colorLayer:addChild(cs9Attr, 10, 1000)

	local nHeightOfUnit = nHeightOfAttrBg/5
	local pics = {"magic_defend", "physical_defend", "attack", "life", "level"}
	-- print("pForceValues01  is : ========== ==== ================ ======== ===    ===   ===   ===  ")
	print_t(pForceValues01)
	local values = {
		pForceValues01[AffixDef.MAGIC_DEFEND],--, pForceValues02.magicDefend},
		pForceValues01[AffixDef.PHYSICAL_DEFEND],--, pForceValues02.physicalDefend},
		pForceValues01[AffixDef.GENERAL_ATTACK],--, pForceValues02.generalAttack},
		pForceValues01[AffixDef.LIFE],--, pForceValues02.life},
		UserModel.getHeroLevel() ,--, pForceValues01.level},
	}
	-- print("values  is : ========== ==== ================ ======== ===    ===   ===   ===  ")
	-- print_t(values)

	local values_02 = {
		pForceValues02[AffixDef.MAGIC_DEFEND],
		 pForceValues02[AffixDef.PHYSICAL_DEFEND],
		 pForceValues02[AffixDef.GENERAL_ATTACK],
		 pForceValues02[AffixDef.LIFE],
		 UserModel.getHeroLevel(),
	}
	local addedValues = {
		tonumber(pForceValues02[AffixDef.MAGIC_DEFEND]) - tonumber(pForceValues01[AffixDef.MAGIC_DEFEND]),
		tonumber(pForceValues02[AffixDef.PHYSICAL_DEFEND]) - tonumber(pForceValues01[AffixDef.PHYSICAL_DEFEND]),
		tonumber(pForceValues02[AffixDef.GENERAL_ATTACK]) - tonumber(pForceValues01[AffixDef.GENERAL_ATTACK]),
		tonumber(pForceValues02[AffixDef.LIFE]) - tonumber(pForceValues01[AffixDef.LIFE]),
		0,
	}
	local y=nHeightOfUnit/2

	for i=1, #pics do
		local csAttrName=CCSprite:create("images/hero/transfer/level_up/"..pics[i]..".png")
		csAttrName:setScale(g_fElementScaleRatio)
		csAttrName:setAnchorPoint(ccp(0, 0.5))
		csAttrName:setPosition(0.117*g_winSize.width, y)
		cs9Attr:addChild(csAttrName, 1001, 1001)

		local csAttrValue01 = CCLabelTTF:create(""..  values[i], g_sFontName, 35)
		csAttrValue01:setScale(g_fElementScaleRatio)
		csAttrValue01:setColor(ccc3(255, 0x6c, 0))
		csAttrValue01:setPosition(0.297*g_winSize.width, y)
		csAttrValue01:setAnchorPoint(ccp(0, 0.5))
		cs9Attr:addChild(csAttrValue01, 1001, 1002)
		-- 箭头特效
		local sImgPathArrow=CCString:create("images/base/effect/hero/transfer/jiantou")
		local clsEffectArrow=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathArrow:getCString(), -1, CCString:create(""))
		clsEffectArrow:setScale(g_fElementScaleRatio)
		clsEffectArrow:setAnchorPoint(ccp(0, 0.5))
		clsEffectArrow:setPosition(0.578*g_winSize.width, y)
		cs9Attr:addChild(clsEffectArrow, 1001, 1003)

		local csAttrValue02 = CCLabelTTF:create("" .. values_02[i], g_sFontName, 35)
		csAttrValue02:setScale(g_fElementScaleRatio)
		csAttrValue02:setPosition(0.7*g_winSize.width, y)
		csAttrValue02:setColor(ccc3(0x67, 0xf9, 0))
		csAttrValue02:setAnchorPoint(ccp(0, 0.5))
		cs9Attr:addChild(csAttrValue02, 1001, 1004)

		if addedValues[i] > 0 then
			local csArrowGreen = CCSprite:create("images/hero/transfer/arrow_green.png")
			csArrowGreen:setScale(g_fElementScaleRatio)
			csArrowGreen:setPosition(0.98*g_winSize.width, y)
			csArrowGreen:setAnchorPoint(ccp(1, 0.5))
			cs9Attr:addChild(csArrowGreen, 1001, 1005)
		end

		y = y + nHeightOfUnit
	end
	-- 转光特效
	local sImgPath=CCString:create("images/base/effect/hero/transfer/zhuanguang")
	local clsEffectZhuanGuang=CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), -1, CCString:create(""))
	clsEffectZhuanGuang:setPosition(g_winSize.width/2, 740*g_fScaleY)
	clsEffectZhuanGuang:setScale(g_fElementScaleRatio)
	colorLayer:addChild(clsEffectZhuanGuang, 11, 100)
	clsEffectZhuanGuang:setVisible(false)

	
	-- 进阶成功特效
	local sImgPathSuccess=CCString:create("images/destney/effect/xinjitisheng/xinjitisheng")
	local clsEffectSuccess=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathSuccess:getCString(), -1, CCString:create(""))
	clsEffectSuccess:setAnchorPoint(ccp(0.5, 0.5))
	clsEffectSuccess:setScale(g_fElementScaleRatio)
	clsEffectSuccess:setPosition(g_winSize.width/2, 460*g_fScaleY)
	colorLayer:addChild(clsEffectSuccess, 999, 999)
	local ccDelegateSuccess=BTAnimationEventDelegate:create()
	ccDelegateSuccess:registerLayerEndedHandler(function (actionName, xmlSprite)
		clsEffectSuccess:cleanup()
	end)
	ccDelegateSuccess:registerLayerChangedHandler(function (index, xmlSprite)

	end)
	clsEffectSuccess:setDelegate(ccDelegateSuccess)

	-- if _tHeroTransferedAttr then
	-- print(" DestinyData.changeHeroHtid()  is : ",  DestinyData.changeHeroHtid())
		local csCardShow = HeroPublicCC.createSpriteCardShow( DestinyData.changeHeroHtid() )
		csCardShow:setAnchorPoint(ccp(0.5, 0.5))
		csCardShow:setScale(g_fElementScaleRatio)
		csCardShow:setPosition(g_winSize.width/2, 740*g_fScaleY)
		colorLayer:addChild(csCardShow, 999, 999)
		csCardShow:setScale(1.5*g_fElementScaleRatio)
		local sequence = CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 0.8*g_fElementScaleRatio),
			CCCallFunc:create(function ( ... )
				clsEffectZhuanGuang:setVisible(true)
				require "script/audio/AudioUtil"
				AudioUtil.playEffect("audio/effect/zhuanguang.mp3")
			end))
		csCardShow:runAction(sequence)
	-- end
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")
	runningScene:addChild(colorLayer, 32767, 32767)
end


---------------------------------- 新手引导 --------------------------------------
-- 获得要突破的天命按钮，即中间的按钮
function getCurItem( )
 	return _curDestinyItem	
end  

-- 获得底部显示“天命属性” 的sprite
function getBottomNode( ... )
	return _bottmNodeForLead
end

-- 获得主角换技能按钮
function getSkillBtn( ... )
	return learnSkillBtn
end

---[==[天命 第2步
---------------------新手引导---------------------------------
function addGuideDestinyGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/DestinyGuide"
    if(NewGuide.guideClass ==  ksGuideDestiny and DestinyGuide.stepNum == 1) then
        local destinyButton = getCurItem()
        local touchRect   = getSpriteScreenRect(destinyButton)
        DestinyGuide.show(2, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[天命 第3步
---------------------新手引导---------------------------------
function addGuideDestinyGuide3( ... )
	require "script/guide/NewGuide"
	require "script/guide/DestinyGuide"
    if(NewGuide.guideClass ==  ksGuideDestiny and DestinyGuide.stepNum == 2) then
        local destinyButton = getBottomNode()
        local touchRect   = getSpriteScreenRect(destinyButton)
        DestinyGuide.show(3, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


---[==[主角换技能 第2步
---------------------新手引导---------------------------------
function addGuideChangeSkillGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/ChangeSkillGuide"
    if(NewGuide.guideClass ==  ksGuideChangeSkill and ChangeSkillGuide.stepNum == 1) then
        local button = getSkillBtn()
        local touchRect   = getSpriteScreenRect(button)
        ChangeSkillGuide.show(2, touchRect)
    end
end
