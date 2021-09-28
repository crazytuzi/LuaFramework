-- FileName: CountryWarWorshipLayer.lua
-- Author: yangrui
-- Date: 2015-11-16
-- Purpose: 国战膜拜主界面

module("CountryWarWorshipLayer", package.seeall)

require "script/ui/countryWar/worship/CountryWarWorshipData"
require "script/ui/countryWar/worship/CountryWarWorshipService"
require "script/ui/countryWar/worship/CountryWarWorshipController"
require "script/ui/title/TitleUtil"

local _bgLayer                  = nil
local _worshipRewardBg          = nil  -- 膜拜奖励背景
local _worshipRewardPanelHeight = nil  -- 膜拜奖励面板的高
local _worshipBtn               = nil  -- 膜拜奖励按钮

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer                  = nil
	_worshipRewardBg          = nil  -- 膜拜奖励背景
	_worshipRewardPanelHeight = nil  -- 膜拜奖励面板的高
	_worshipBtn               = nil  -- 膜拜奖励按钮
end

--[[
	@des 	: 创建膜拜的对象
	@param 	: 
	@return : 
--]]
function createWorshipObj( ... )
	-- 膜拜对象数据
	local worshipObjInfo = CountryWarMainData.getWorShipInfo()
	-- 冠军的htid
    local userHtid = worshipObjInfo.htid
	if worshipObjInfo.server_name == nil then
		worshipObjInfo = UserModel.getUserInfo()
		userHtid = UserModel.getAvatarHtid()
	end
	-- 冠军名字的颜色
	local heroInfo = HeroUtil.getHeroLocalInfoByHtid(userHtid)
	local winNameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.star_lv)
 	-- 宝座
 	local baseChairSp = CCSprite:create("images/dress_room/stage.png")
 	baseChairSp:setAnchorPoint(ccp(0.5,0))
 	baseChairSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,(_worshipRewardPanelHeight+150)*g_fScaleY))
 	baseChairSp:setScale(MainScene.elementScale)
 	_bgLayer:addChild(baseChairSp)
	-- 冠军
	-- 判断是否有时装
	local dressId = nil
        if worshipObjInfo.dress then
            if ( not table.isEmpty(worshipObjInfo.dress) and (worshipObjInfo.dress["1"]) ~= nil and tonumber(worshipObjInfo.dress["1"]) > 0 ) then
                dressId = worshipObjInfo.dress["1"]
            end
        end
	local winSp = HeroUtil.getHeroBodySpriteByHTID(worshipObjInfo.htid,dressId,HeroModel.getSex(worshipObjInfo.htid))
	winSp:setAnchorPoint(ccp(0.5,0))
	winSp:setPosition(ccp(baseChairSp:getContentSize().width*0.5,baseChairSp:getContentSize().height*0.5))
	winSp:setScale(0.85)
	baseChairSp:addChild(winSp)
	-- 皇冠
	local kingHat = CCSprite:create("images/country_war/worship/countrywar_winner_hat.png")
	kingHat:setAnchorPoint(ccp(0.5,0))
	kingHat:setPosition(ccp(winSp:getContentSize().width*0.5, winSp:getContentSize().height*0.82))
	winSp:addChild(kingHat)
	-- 称号
	local titleId = tonumber(worshipObjInfo.title)
	if(titleId ~= nil and titleId > 0) then
		kingHat:setPosition(ccp(winSp:getContentSize().width*0.5, winSp:getContentSize().height*0.95))
	    local titleSp = TitleUtil.createTitleNormalSpriteById(titleId)
	    titleSp:setAnchorPoint(ccp(0.5,0.5))
	    titleSp:setPosition(ccp(kingHat:getContentSize().width*0.5,-winSp:getContentSize().height*0.07))
		kingHat:addChild(titleSp)
	end
	-- 名字 等级 背景
	local desNodeBg = CCScale9Sprite:create("images/treasure/name_bg.png")
	desNodeBg:setPreferredSize(CCSizeMake(224,35))
	desNodeBg:setAnchorPoint(ccp(0.5,1))
	desNodeBg:setPosition(ccp(baseChairSp:getContentSize().width*0.5,-2))
	baseChairSp:addChild(desNodeBg)
	-- 名字&等级
	require "script/libs/LuaCCLabel"
    local richInfo = {
        linespace = 2, -- 行间距
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontPangWa,
        labelDefaultColor = ccc3(0xe4,0x00,0x00),
        labelDefaultSize = 18,
        defaultType = "CCRenderLabel",
        elements =
        {
            {
                newLine = false,
                text = worshipObjInfo.uname,
                renderType = 2,-- 1 描边， 2 投影
                color = winNameColor,
            },
            {
                newLine = false,
                text = " Lv." .. worshipObjInfo.level,
                color = ccc3(0xff,0xf6,0x00),
                renderType = 2,-- 1 描边， 2 投影
            },
        }
    }
    local richTextLayer = LuaCCLabel.createRichLabel(richInfo)
    richTextLayer:setAnchorPoint(ccp(0.5,0.5))
    richTextLayer:setPosition(ccp(desNodeBg:getContentSize().width*0.5,desNodeBg:getContentSize().height*0.5))
    desNodeBg:addChild(richTextLayer)
	-- 加入玩家名字比较长，动态变动 desNodeBg 的宽
	local desNodeWidth = richTextLayer:getContentSize().width
	if desNodeWidth > 224 then
		desNodeBg:setPreferredSize(CCSizeMake(desNodeWidth,35))
	end
    -- 战斗力icon
    local forceIcon = CCSprite:create("images/lord_war/fight_bg.png")
    forceIcon:setAnchorPoint(ccp(0.5,1))
    forceIcon:setPosition(ccp(baseChairSp:getContentSize().width*0.5,desNodeBg:getPositionY()-desNodeBg:getContentSize().height))
    baseChairSp:addChild(forceIcon)
    -- 战斗力数值
    local forceFont = CCRenderLabel:create(worshipObjInfo.fight_force,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
    forceFont:setColor(ccc3(0xff,0x00,0x00))
    forceFont:setAnchorPoint(ccp(0,0.5))
    forceFont:setPosition(ccp(35,forceIcon:getContentSize().height*0.5))
    forceIcon:addChild(forceFont)
    -- 服务器名字
    if worshipObjInfo.server_name ~= nil then
	    local serverNameFont = CCRenderLabel:create("『" .. worshipObjInfo.server_name .. "』",g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	    serverNameFont:setColor(ccc3(0xff,0xff,0xff))
	    serverNameFont:setAnchorPoint(ccp(0.5,1))
	    serverNameFont:setPosition(ccp(baseChairSp:getContentSize().width*0.5,forceIcon:getPositionY()-forceIcon:getContentSize().height))
	    baseChairSp:addChild(serverNameFont)
	end
end

--[[
	@des 	: 创建膜拜的奖励TableviewCell
	@param 	: 
	@return : 
--]]
function createRewardTableviewCell( pInfo )
	local itemInfo = ItemUtil.getItemsDataByStr(pInfo)[1]
	local icon = ItemUtil.createGoodsIcon(itemInfo)
	local cell = CCTableViewCell:create()
	cell:setContentSize(icon:getContentSize())
	icon:setPosition(ccpsprite(0.2,0.4,cell))
	cell:addChild(icon)
	return cell
end

--[[
	@des 	: 创建膜拜的奖励Tableview
	@param 	: 
	@return : 
--]]
function createRewardTableview( ... )
	-- 获取奖励的数据
	local rewardData = CountryWarWorshipData.getWorshipRewardData()
	-- 创建奖励tableview
	local rewardItemData = string.split(rewardData,",")
	local function rewardItemTableCallback( fn, table, a1, a2 )
		local r
		if fn == "cellSize" then
			r = CCSizeMake(110,140)
		elseif fn == "cellAtIndex" then
			r = createRewardTableviewCell(rewardItemData[a1+1])
		elseif fn == "numberOfCells" then
			r = #rewardItemData
		elseif fn == "cellTouched" then
		end
		return r
	end
	local tableViewSize = CCSizeMake(590,140)
	local rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback),tableViewSize)
	rewardItemTable:setBounceable(true)
	rewardItemTable:setAnchorPoint(ccp(0,0))
	rewardItemTable:setPosition(ccp(5,0))
	rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
	rewardItemTable:setTouchPriority(-520)
	_worshipRewardBg:addChild(rewardItemTable)
	rewardItemTable:reloadData()
	if table.count(rewardItemData) <= 4 then
		rewardItemTable:setTouchEnabled(false)
	end
end

--[[
	@des 	: 设置膜拜按钮disabled
	@param 	: 
	@return : 
--]]
function setWorshipBtnDisabled( ... )
	_worshipBtn:setEnabled(false)
end

--[[
	@des 	: 膜拜按钮的回调
	@param 	: 
	@return : 
--]]
function worshipBtnCallback( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 网络请求
	CountryWarWorshipController.worship(function( ... )
		setWorshipBtnDisabled()
	end)
end

--[[
	@des    : 创建膜拜按钮
	@para   : 
	@return : 
--]]
function createMenuItem( pNormalString, pSelectedString, pDisabledString, pSize )
	-- normal
    local norSprite = CCScale9Sprite:create("images/common/btn/btn1_d.png")
	norSprite:setContentSize(pSize)
	local norTitle  =  CCRenderLabel:create(pNormalString,g_sFontPangWa,35,1,ccc3( 0x00,0x00,0x00),type_shadow)
	norTitle:setColor(ccc3(0xfe,0xdb,0x1c))
	norTitle:setPosition(ccpsprite(0.5,0.5,norSprite))
	norTitle:setAnchorPoint(ccp(0.5,0.5))
	norSprite:addChild(norTitle)
	-- selected
	local higSprite = CCScale9Sprite:create("images/common/btn/btn1_n.png")
	higSprite:setContentSize(pSize)
    pSelectedString = pSelectedString or pNormalString
	local higTitle  =  CCRenderLabel:create(pSelectedString,g_sFontPangWa,35,1,ccc3( 0x00,0x00,0x00),type_shadow)
	higTitle:setColor(ccc3(0xfe,0xdb,0x1c))
	higTitle:setPosition(ccpsprite(0.5,0.5,higSprite))
	higTitle:setAnchorPoint(ccp(0.5,0.5))
	higSprite:addChild(higTitle)
	-- disabled
	local graySprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
	graySprite:setContentSize(pSize)
    pDisabledString = pDisabledString or pNormalString
	local grayTitle  =  CCRenderLabel:create(pDisabledString,g_sFontPangWa,35,1,ccc3( 0x00,0x00,0x00),type_shadow)
	grayTitle:setColor(ccc3(78,78,78))
	grayTitle:setPosition(ccpsprite(0.5,0.5,graySprite))
	grayTitle:setAnchorPoint(ccp(0.5,0.5))
	graySprite:addChild(grayTitle)
	-- create btn
	local button = CCMenuItemSprite:create(norSprite,higSprite,graySprite)
    return button
end

--[[
	@des 	: 创建膜拜的奖励
	@param 	: 
	@return : 
--]]
function createReward( ... )
	-- 膜拜奖励面板
	local rewardPanel = CCScale9Sprite:create(CCRectMake(33,35,12,45),"images/recharge/vip_benefit/vipBB.png")
	rewardPanel:setPreferredSize(CCSizeMake(640,245))
	rewardPanel:setAnchorPoint(ccp(0.5,0))
	rewardPanel:setPosition(ccps(0.5,0))
	rewardPanel:setScale(MainScene.elementScale)
	_bgLayer:addChild(rewardPanel)
	_worshipRewardPanelHeight = rewardPanel:getContentSize().height
	-- 膜拜奖励背景
	_worshipRewardBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_worshipRewardBg:setContentSize(CCSizeMake(595,140))
	_worshipRewardBg:setAnchorPoint(ccp(0.5,0))
	_worshipRewardBg:setPosition(ccp(rewardPanel:getContentSize().width*0.5,70))
	rewardPanel:addChild(_worshipRewardBg)
	-- nameBg
	local nameBg = CCScale9Sprite:create(CCRectMake(86,30,4,8),"images/dress_room/name_bg.png")
	nameBg:setPreferredSize(CCSizeMake(300,68))
	nameBg:setAnchorPoint(ccp(0.5,0.5))
	nameBg:setPosition(ccp(rewardPanel:getContentSize().width*0.5,rewardPanel:getContentSize().height-3))
	rewardPanel:addChild(nameBg)
	-- 膜拜奖励
	local title = GetLocalizeStringBy("yr_2007")
	local name = CCRenderLabel:create(title,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	name:setColor(ccc3(0xff,0xf6,0x00))
	name:setAnchorPoint(ccp(0.5,0.5))
	name:setPosition(ccpsprite(0.5,0.5,nameBg))
	nameBg:addChild(name)
	-- 创建奖励tableview
	createRewardTableview()
	-- 膜拜按钮bar
	local worshipMenu = CCMenu:create()
	worshipMenu:setAnchorPoint(ccp(0,0))
	worshipMenu:setPosition(ccp(0,0))
	rewardPanel:addChild(worshipMenu)
	worshipMenu:setTouchPriority(-504)
	-- 创建膜拜按钮
	_worshipBtn = createMenuItem(GetLocalizeStringBy("yr_2000"),nil,GetLocalizeStringBy("yr_2001"),CCSizeMake(188,70))
	_worshipBtn:setAnchorPoint(ccp(0.5,0))
	_worshipBtn:setPosition(ccpsprite(0.5,0.02,rewardPanel))
	_worshipBtn:registerScriptTapHandler(worshipBtnCallback)
	worshipMenu:addChild(_worshipBtn)
	-- 膜拜时间
	local worshipTime = CountryWarWorshipData.getWorshipTime()
	local curTIme = TimeUtil.getSvrTimeByOffset(0)
	if TimeUtil.isSameDay(worshipTime,curTIme) then
		setWorshipBtnDisabled()
	end
end

--[[
	@des 	: 刷新UI
	@param 	: 
	@return : 
--]]
function updateUI( ... )
    local curTime = TimeUtil.getSvrTimeByOffset()
    local tmpTime = curTime+86400
    -- 活动结束那天的0点
    local transFormTime = os.date("*t",tmpTime)
	transFormTime.hour = 0
	transFormTime.min  = 0
	transFormTime.sec  = 0
    local zeroTime = os.time(transFormTime)
    local subTime = zeroTime-curTime
	performWithDelay(_bgLayer, function( ... )
	    _worshipBtn:setEnabled(true)
	end,subTime)
end

--[[
	@des 	: 创建UI
	@param 	: 
	@return : 
--]]
function createUI( ... )
	-- 创建膜拜奖励
	createReward()
	-- 创建膜拜的对象
	createWorshipObj()
	-- 0点刷新
	updateUI()
end

--[[
	@des 	: 创建膜拜Layer
	@param 	: 
	@return : 
--]]
function createWorshipLayer( ... )
	-- init
	init()
	_bgLayer = CCLayer:create()
	-- createUI
	createUI()

	return _bgLayer
end

--[[
	@des 	: 显示膜拜Layer
	@param 	: 
	@return : 
--]]
function showWorshipLayer( ... )
	-- body
end
