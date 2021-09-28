-- Filename：	MineralLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-15
-- Purpose：		资源矿

module ("MineralLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/ui/active/mineral/MineralMenuItem"
require "script/ui/active/mineral/MineralInfoLayer"
require "script/utils/TimeUtil"
require "script/ui/arena/AfterBattleLayer"
require "script/ui/mail/MailData"
require "script/ui/active/mineral/MineralRobInfoLayer"

---------------------- 
require "script/ui/active/mineral/MineralUtil"
require "db/DB_Res"
require "db/DB_Vip"
require "script/ui/tip/SingleTip"
require "script/ui/active/mineral/MineralElvesService"
require "script/ui/active/mineral/MineralElfInfoLayer"
----------------------------------
-- 跑马灯类型
-- 宝藏抢夺
ksBulletElves   = 1
-- 资源矿抢夺
ksBulletNormal  = 2

local _bgLayer 		= nil
---- TOP
local _fightValueLabel 		= nil	-- 战斗力
local _bodyLabel 			= nil	-- 体力
local _silverLabel			= nil	-- 银币
local _goldLabel 			= nil	-- 金币

local _myMineralInfo 		= {}	-- 我的矿的信息
local _curDomainInfos 		= {}	-- 当前页矿的信息

local _curDomainMenuBar 	= nil	-- 当前所有矿的menubar
local _twoMenuBar			= nil	-- 自己的矿和一键找矿

local _countDownLabel 		= {}	-- 倒计时

local _updateTimeScheduler 	= nil	-- Schedule

local _curPageInfos 		= {}	-- 当前所有
local Normal_Field_Type 	= 2 	-- 普通资源矿区
local High_Field_Type 		= 1 	-- 高级资源矿区
local Gold_Field_Type       = 3     -- 金币矿区

local _curFieldType			= 1 	-- 当前是在普通还是高级
local _curDomainId 			= 1 	-- 当前区域id
local _pageMenuBarBg 		= nil 	-- 分页的底
local _curPageBtn 			= nil 	-- 当前的分页

local _curFieldButton 		= nil 	-- 当前矿区
local _curPage 				= 1 	-- 当前第几页
local _itemPerPage 			= 6 	-- 每页显示的条数

local _fieldMenuBar 		= nil 	-- 区域按钮bar
local newAnimSprite  		= nil   -- 邮件按钮上new标识
----------------------------------------------- added by bzx
local _page_menu_offset                         -- 滑动偏移量
local _page_scroll_view                         -- 页数的ScrollView
local _left_arrows                              -- 左边箭头
local _left_arrows_gray
local _right_arrows                             -- 右边箭头
local _right_arrows_gray
local _cell_width                   = 90        -- 页数按钮的宽度
local _first_page_item                          -- 第一页的按钮
local _last_page_item                           -- 最后一页的按钮
local _timer_refresh_arrows                     -- 刷新箭头
local top_sprite                                -- 战斗力/体力/银币/金币
local _border_BG                                -- 一键找矿等按钮的背景
local _choose_bar                               -- 点击一键搜索时弹出的面板
local _choose_bg
local _choose_bar_touch_priority    = -423
local _border_BG_z                  = 1000
local _page_tip                     = nil
local _current_page                 = 1
local _should_show_current_page_tip = false
local _push_mineral_robs
local _push_mineral_rob_node
local _isShowed
local _rob_node_scroll_view
local _maxCount = 0                             -- 当前页同一军团占领的最大人数
local _maxCountGuildName = nil                  -- 当前页占领人数最多的军团名字
local _guildAdditionTipLabel = nil              -- 军团加成的提示
local _guildAdditionTipLabelBg = nil
local _elvesActivityTipLabel    = nil           -- 活动时间
local _curElvesTipLabel         = nil           -- 本轮宝藏提示
local _refreshElvesTipLabelTimer               
local _startRefreshElvesTipLabelTimer
local _selfElvesBtn             = nil           -- 我的宝藏
local _selfElvesBtnEffect       = nil           -- 我的宝藏特效
-----------------------------------------------

-- 初始化
local function init()
	_bgLayer 	 		= nil
	_curDomainId 		= nil
	_fightValueLabel 	= nil	-- 战斗力
	_bodyLabel 			= nil	-- 体力
	_silverLabel 		= nil	-- 银币
	_goldLabel 			= nil	-- 金币
	_myMineralInfo 		= {}	-- 我的矿的信息
	_curDomainInfos 	= {}	-- 当前页矿的信息
	_curDomainMenuBar 	= nil	-- 当前所有矿的menubar
	_twoMenuBar			= nil	-- 自己的矿和一键找矿
	_countDownLabel 	= {}	-- 倒计时
	_updateTimeScheduler= nil	-- Schedule
	Normal_Field_Type 	= 2 	-- 普通资源矿区
	High_Field_Type 	= 1 	-- 高级资源矿区
	_curFieldType		= 1 	-- 当前是在哪个区
	_curPageInfos 		= {}	-- 当前所有
	_pageMenuBarBg 		= nil 	-- 分页的底
	_curPageBtn 		= nil 	-- 当前的分页
	_curFieldButton 	= nil 	-- 当前矿区
	_fieldMenuBar 		= nil 	-- 区域按钮bar
	newAnimSprite  		= nil   -- 邮件按钮
    -------------------------------------------- added by bzx
    _page_menu_offset   = ccp(0, 0)
    _page_scroll_view   = nil
    _border_BG          = nil
    _choose_bar         = nil
    _page_tip           = nil
    _current_page       = 1
    _push_mineral_robs  = {}
    _push_mineral_rob_node = nil
    _isShowed = false
    _guildAdditionTipLabel = nil
    _guildAdditionTipLabelBg = nil
    _elvesActivityTipLabel    = nil           -- 活动时间
    _curElvesTipLabel         = nil           -- 本轮宝藏提示
    _refreshElvesTipLabelTimer = nil
    _startRefreshElvesTipLabelTimer = nil
    _selfElvesBtn       = nil 
    _selfElvesBtnEffect = nil
    --------------------------------------------
end 

-------------------------资源矿推送 ---------------------
local function push_mineral_updatepit_callback( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
        return
    end
    local updated = false
    local pitInfo = dictData.ret
    for k, t_info in pairs(_curDomainInfos) do
        if MineralUtil.isEqual(pitInfo, t_info) then
            if(tonumber(pitInfo.uid)>0)then
                pitInfo.expireTime 			= BTUtil:getSvrTimeInterval()+ tonumber(pitInfo.due_time)
                pitInfo.protectExpireTime 	= BTUtil:getSvrTimeInterval()+ tonumber(pitInfo.protect_time)
            end
            _curDomainInfos[k] = pitInfo
            updated = true
        end
    end
    if updated == false then
        updated = MineralUtil.updateMyMineral(_myMineralInfo, pitInfo)
    else
        MineralUtil.updateMyMineral(_myMineralInfo, pitInfo)
        initGuildAdditionInfo()
        refreshGuildAdditionTip()
    end
    if updated == true then
        refreshUI()
        MineralInfoLayer.refresh(pitInfo)
    end
end

--资源矿tuisong
local function push_mineral_updatepit()
	Network.re_rpc(push_mineral_updatepit_callback, "push.mineral.updatepit", "push.mineral.updatepit")
end

function pushMineralelvesUpdateCallback(ret)
    if not  _isShowed then
        return
    end
    refreshUI()
    MineralElfInfoLayer.refresh(ret)
end

-- 宝藏抢夺推送
function pushMineralelvesRobCallback(ret)
    if _isShowed == true then
        if ret.pre_capture == UserModel.getUserName() then
            local richInfo = {}
            richInfo.elements = {}
            local element = {}
            element.type = "CCRenderLabel"
            element.text = ret.now_capture
            element.color = ccc3(0x00,0xe4,0xff)
            table.insert(richInfo.elements, element)
            require "script/ui/tip/RichAnimationTip"
            RichAnimationTip.showTip(GetNewRichInfo(GetLocalizeStringBy("key_10365"), richInfo), nil, nil, 500)
            MineralElvesData.setSelfMineralElvesData({})
            refreshSelfElvesBtn()
        end
        if ret.now_capture == UserModel.getUserName() then
            local selfMineralElvesData = {}
            selfMineralElvesData.domain_id = ret.domain_id
            MineralElvesData.setSelfMineralElvesData(selfMineralElvesData)
            refreshSelfElvesBtn()
        end
        ret.type = ksBulletElves
        table.insert(_push_mineral_robs, ret)
        showMineralRobInfoNode()
    end
end

--资源矿取消推送
local function remove_mineral_updatepit()
	Network.remove_re_rpc("push.mineral.updatepit")
end

function pushMineralRobCallback(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    if _isShowed == true then
        dictData.ret.type = ksBulletNormal
        table.insert(_push_mineral_robs, dictData.ret)
        showMineralRobInfoNode()
    end
    MineralRobInfoLayer.addMineralRobInfo(dictData.ret)
end

function getGuildAdditionInfo( ... )
    return _maxCountGuildName, _maxCount
end

function refreshRobNodePosition( ... )
    if _push_mineral_rob_node ~= nil then
        if _current_page <= 20 then
            _push_mineral_rob_node:setPosition(ccp(g_winSize.width * 0.5, _bgLayer:getContentSize().height - _top_sprite:getContentSize().height * _top_sprite:getScale() - 140 * g_fScaleX ))
        else
            _push_mineral_rob_node:setPosition(ccp(g_winSize.width * 0.5, _bgLayer:getContentSize().height - _top_sprite:getContentSize().height * _top_sprite:getScale() - 100 * g_fScaleX ))
        end
    end
end

function showMineralRobInfoNode()
    if #_push_mineral_robs == 0 then
        if _push_mineral_rob_node ~= nil then
            _push_mineral_rob_node:removeFromParentAndCleanup(true)
            _push_mineral_rob_node = nil
        end
        return
    end
    if _push_mineral_rob_node == nil then
        _push_mineral_rob_node = CCSprite:create("images/main/bulletin_bg.png")
        _bgLayer:addChild(_push_mineral_rob_node, 1000)
        _push_mineral_rob_node:setAnchorPoint(ccp(0.5, 1))
        refreshRobNodePosition()
        _push_mineral_rob_node:setScale(1 / MainScene.elementScale * g_fScaleX)
        _rob_node_scroll_view = CCScrollView:create()
        _push_mineral_rob_node:addChild(_rob_node_scroll_view)
        _rob_node_scroll_view:setPosition(ccp(14, 7))
        _rob_node_scroll_view:setViewSize(CCSizeMake(612, 20))
        _rob_node_scroll_view:setTouchEnabled(false)
    end
    local pushMineralRobInfo = _push_mineral_robs[1]
    table.remove(_push_mineral_robs, 1)
    local node = createBulletNode(pushMineralRobInfo)
    _rob_node_scroll_view:addChild(node, 10)
    node:setAnchorPoint(ccp(0, 0.5))
    node:setPosition(ccp(612, 10))
    local actionArray = CCArray:create()
    actionArray:addObject(CCMoveBy:create(10, ccp(-640 - node:getContentSize().width, 0)))
    actionArray:addObject(CCCallFunc:create(function ( ... )
            node:removeFromParentAndCleanup(true)
			showMineralRobInfoNode()
    end))
    local seq =  CCSequence:create(actionArray)
    node:runAction(seq)
end

function createBulletNode(p_data)
    local node = nil
    if p_data.type == ksBulletNormal then
        local resDb = DB_Res.getDataById(tonumber(p_data.domain_id))
        local names = {GetLocalizeStringBy("key_1427"), GetLocalizeStringBy("key_2722"), GetLocalizeStringBy("key_8312")}
        local colors = {ccc3(0xff, 0, 0xe1), ccc3(26, 175, 84), ccc3(252, 13, 27)}
        local tipNodes = {}
        tipNodes[1] = CCLabelTTF:create(p_data.now_capture, g_sFontName, 21)
        tipNodes[1]:setColor(ccc3(0x00,0xe4,0xff))
        tipNodes[2] = CCLabelTTF:create(GetLocalizeStringBy("key_8313"), g_sFontName, 21)
        tipNodes[3] = CCLabelTTF:create(p_data.pre_capture, g_sFontName, 21)
        tipNodes[3]:setColor(ccc3(0x00,0xe4,0xff))
        tipNodes[4] = CCLabelTTF:create(GetLocalizeStringBy("key_8314"), g_sFontName, 21)
        local number = 0
        if resDb.type == 1 then
            number = resDb.id - 50000
        elseif resDb.type == 2 then
            number = resDb.id - 10000
        elseif resDb.type == 3 then
            number = resDb.id - 60000
        else
            print("resDb.type有误")
        end
        tipNodes[5] = CCLabelTTF:create(string.format(GetLocalizeStringBy("key_8316"), names[resDb.type], number), g_sFontName, 21)
        tipNodes[5]:setColor(colors[resDb.type])
        tipNodes[6] = CCLabelTTF:create(GetLocalizeStringBy("key_8315"), g_sFontName, 21)
        tipNodes[7] = CCLabelTTF:create(resDb["res_name" .. p_data.pit_id], g_sFontName, 21)
        tipNodes[7]:setColor(ccc3(0x2a, 0xff, 0x00))
        node = BaseUI.createHorizontalNode(tipNodes)
    else
        local richInfo = {}
        richInfo.labelDefaultSize = 21
        richInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
        richInfo.elements = 
        {
            {
                text = p_data.now_capture,
                color = ccc3(0x00,0xe4,0xff)
            },
            {
                text = p_data.pre_capture,
                color = ccc3(0x00,0xe4,0xff)
            },
        }
        if p_data.pre_capture == "0" then
            node = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10358"), richInfo)
        else
            node = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10359"), richInfo)
        end
    end
    return node
end

--[[
function removeMineralRob()
    Network.remove_re_rpc("push.mineral.rob")
end
--]]

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
function onNodeEvent( event )
	if (event == "enter") then
		push_mineral_updatepit()
        MineralElvesService.pushMineralelvesUpdate(pushMineralelvesUpdateCallback)
        MineralElvesService.pushMineralelvesRob(pushMineralelvesRobCallback)
        _isShowed = true
	elseif (event == "exit") then
		stopTimeScheduler()
		remove_mineral_updatepit()
        _isShowed = false
        stopTimerRefreshArrows()
	end
end


function startTimerRefreshArrows()
    if _timer_refresh_arrows == nil then
        _timer_refresh_arrows = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerRefreshArrows, 0, false)
     end
end

function stopTimerRefreshArrows()
    if _timer_refresh_arrows ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_timer_refresh_arrows)
        _timer_refresh_arrows = nil
    end
end

function refreshUI()
	stopTimeScheduler()
	---- 创建两个按钮
	createTwoBtn()
    -- 我的宝藏
    refreshSelfElvesBtn()
	---- 创建当前的所有矿
	createCurDomainMineral( )
	refreshTopUI()
end

-- 刷新我的宝藏
function refreshSelfElvesBtn( ... )
    if _selfElvesBtn == nil then
        local normalSprite = CCSprite:create("images/active/mineral/my_elves_n.png")
        local selectedSprite = CCSprite:create("images/active/mineral/my_elves_h.png")
        local disabledSprite = BTGraySprite:create("images/active/mineral/my_elves_n.png")
        _selfElvesBtn = CCMenuItemSprite:create(normalSprite, selectedSprite, disabledSprite)
        _twoMenuBar:addChild(_selfElvesBtn)
        _selfElvesBtn:setPosition(ccp(560, -150))
        _selfElvesBtn:registerScriptTapHandler(selfElvesCallback)

        _selfElvesBtnEffect = XMLSprite:create("images/base/effect/wodebaozang/wodebaozang")
        _selfElvesBtn:addChild(_selfElvesBtnEffect)
        _selfElvesBtnEffect:setAnchorPoint(ccp(0.5, 0.5))
        _selfElvesBtnEffect:setPosition(ccpsprite(0.5, 0.5, _selfElvesBtn))
    end
    local status = MineralElvesData.getElvesStatus()
    if status == MineralElvesData.ksNotOpened or status == MineralElvesData.ksEnded or status == MineralElvesData.ksNotStart then
        _selfElvesBtn:setVisible(false)
    else
        _selfElvesBtn:setVisible(true)
    end
    if status == MineralElvesData.ksWaiting then
        MineralElvesData.setSelfMineralElvesData({})
    end
        local selfMineralElvesData = MineralElvesData.getSelfMineralElvesData()
    if table.isEmpty(selfMineralElvesData) then
        _selfElvesBtn:setEnabled(false)
        _selfElvesBtnEffect:setVisible(false)
    else
        _selfElvesBtn:setEnabled(true)
        _selfElvesBtnEffect:setVisible(true)
    end
end

-- 点击我的宝藏
function selfElvesCallback( ... )
    local selfMineralElvesData = MineralElvesData.getSelfMineralElvesData()
    sendDomainRequestBy(selfMineralElvesData.domain_id)
end

function initGuildAdditionInfo( ... )
    _maxCount = 0
    _maxCountGuildName = nil
    if _current_page > 20 then
        return
    end
    local guildPitInfo = {}
    for k, t_info in pairs(_curDomainInfos) do
        if t_info.guild_name ~= nil and t_info.guild_name ~= "" then
            guildPitInfo[t_info.guild_name] = guildPitInfo[t_info.guild_name] or 0
            guildPitInfo[t_info.guild_name] = guildPitInfo[t_info.guild_name] + 1
        end
    end

    for guildName, count in pairs(guildPitInfo) do
        if count > _maxCount then
            _maxCount = count
            _maxCountGuildName = guildName
        end
    end
end

function refreshGuildAdditionTip( ... )
    if _guildAdditionTipLabelBg == nil then
        _guildAdditionTipLabelBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
        _guildAdditionTipLabelBg:setContentSize(CCSizeMake(620, 40.0))
        _bgLayer:addChild(_guildAdditionTipLabelBg, 1000)
        _guildAdditionTipLabelBg:setAnchorPoint(ccp(0.5, 1))
        _guildAdditionTipLabelBg:setPosition(ccp(g_winSize.width * 0.5, _bgLayer:getContentSize().height - _top_sprite:getContentSize().height * _top_sprite:getScale() - 100 * g_fScaleX ))
        _guildAdditionTipLabelBg:setScale(1 / MainScene.elementScale * g_fScaleX)
    end

    if _current_page > 20 then
        _guildAdditionTipLabelBg:setVisible(false)
        return
    else
        _guildAdditionTipLabelBg:setVisible(true)
    end
    if _guildAdditionTipLabel ~= nil then
        _guildAdditionTipLabel:removeFromParentAndCleanup(true);
    end
    if _maxCount < 3 then
        _guildAdditionTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_10350") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        _guildAdditionTipLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    else
        local richInfo = {}
        richInfo.labelDefaultFont = "CCRenderLabel"
        richInfo.labelDefaultFont = g_sFontPangWa
        richInfo.labelDefaultSize = 21
        richInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
        richInfo.elements = 
        {
            {
                text = _maxCountGuildName,
                color = ccc3(0x00,0xe4,0xff)
            },
            {
                text = _maxCount,
                color = ccc3(0x00,0xe4,0xff)
            },
        }
        _guildAdditionTipLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10351"), richInfo);
    end
    _guildAdditionTipLabelBg:addChild(_guildAdditionTipLabel)
    _guildAdditionTipLabel:setAnchorPoint(ccp(0.5, 0.5))
    _guildAdditionTipLabel:setPosition(ccpsprite(0.5, 0.5, _guildAdditionTipLabelBg))
end

-- 我的矿的信息
function getMyMineralInfo()
	return _myMineralInfo
end

-- 放弃矿的代理
function giveUpMyMineralDelegate()
	for k, t_info in pairs(_curDomainInfos) do
		if( tonumber(t_info.domain_id) == tonumber(_myMineralInfo.domain_id) and tonumber(t_info.pit_id) == tonumber(_myMineralInfo.pit_id) ) then
			_curDomainInfos[k].due_time     = "0"
			_curDomainInfos[k].uid 			= "0"
			_curDomainInfos[k].uname 		= "0"
			_curDomainInfos[k].expireTime 	= "0"
			_curDomainInfos[k].protect_time = "0"
			break
		end
	end
	--refreshUI()
end

function startTimeScheduler()
	if(_updateTimeScheduler==nil) then
		-- 倒计时
		_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 0, false)
	end
end

function stopTimeScheduler()
	if(_updateTimeScheduler)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end 

-- 修改矿的信息
function modifyMineralList( t_mineral_infos )
	if(not table.isEmpty(t_mineral_infos))then
		for k, t_info in pairs(_curDomainInfos) do
			if( tonumber(t_info.domain_id) == tonumber(t_mineral_infos.domain_id) and tonumber(t_info.pit_id) == tonumber(t_mineral_infos.pit_id) ) then
				
				t_mineral_infos.expireTime 			= BTUtil:getSvrTimeInterval()+ tonumber(t_mineral_infos.due_time)
				t_mineral_infos.protectExpireTime 	= BTUtil:getSvrTimeInterval()+ tonumber(t_mineral_infos.protect_time)

				_curDomainInfos[k] = t_mineral_infos
                MineralUtil.updateMyMineral(_myMineralInfo, t_mineral_infos)
				break
			end
		end
		refreshUI()
	end
end

-- 返回
local function backAction(tag, itembtn)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    RequestCenter.mineral_leave()
    MineralElvesService.leave()

    stopTimeScheduler()
    stopTimerRefreshArrows()
    require "script/ui/bulletLayer/BulletLayer"
    BulletLayer.closeLayer()
    require "script/ui/active/ActiveList"
    local activeListr = ActiveList.createActiveListLayer()
    MainScene.changeLayer(activeListr, "activeListr")
end

-- 打开邮件
local function mailAction( tag, itembtn )
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- new 标识
	MailData.setResourcesNewMailStatus( "false" )
	newAnimSprite:setVisible(false)

	stopTimeScheduler()
    stopTimerRefreshArrows()
	require "script/ui/mail/MineralMail"
	local mailLayer = MineralMail.createMineralMailLayer(_curDomainId)
	MainScene.changeLayer(mailLayer, "mailLayer")

end

-- 创建顶部按钮
local function createTopUI()

	-- 创建头部
    _top_sprite = CCSprite:create("images/common/top_bg.png")
	_top_sprite:setAnchorPoint(ccp(0,1))
	_top_sprite:setPosition(ccp(0, _bgLayer:getContentSize().height))
	_top_sprite:setScale(1 / MainScene.elementScale * g_fScaleX)
	_bgLayer:addChild(_top_sprite)

	-- 战斗力
    _fightValueLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _fightValueLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _fightValueLabel:setPosition(78, 34)
    _top_sprite:addChild(_fightValueLabel,999)

    -- 体力标题
    local bodyTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3176"), g_sFontName, 20)
	bodyTitleLabel:setColor(ccc3(0x51, 0xfb, 0xff))
	bodyTitleLabel:setAnchorPoint(ccp(0, 0))
	bodyTitleLabel:setPosition(ccp(228, 13))
	_top_sprite:addChild(bodyTitleLabel)

    -- 体力
    _bodyLabel = CCLabelTTF:create(UserModel.getEnergyValue(), g_sFontName, 20)
	_bodyLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_bodyLabel:setAnchorPoint(ccp(0, 0))
	_bodyLabel:setPosition(ccp(278, 12))
	_top_sprite:addChild(_bodyLabel)

	-- 银币
    _silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18)  -- modified by yangrui at 2015-12-03
	_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silverLabel:setAnchorPoint(ccp(0, 0))
	_silverLabel:setPosition(ccp(402, 12))
	_top_sprite:addChild(_silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 18)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0))
	_goldLabel:setPosition(ccp(522, 12))
	_top_sprite:addChild(_goldLabel)
end

-- 刷新上部的UI
function refreshTopUI()
	_bodyLabel:setString(UserModel.getEnergyValue())
    _silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))  -- modified by yangrui at 2015-12-03
	_goldLabel:setString(UserModel.getGoldNumber())
end

function updateTime()
    local is_stop = true
    for k, v in pairs(_countDownLabel) do
        is_stop = false
        local my_mineral_info = _myMineralInfo[k]
        if my_mineral_info == nil then
            _countDownLabel[k]:removeFromParentAndCleanup(true)
            _countDownLabel[k] = nil
       --[[
        elseif my_mineral_info.expireTime - BTUtil:getSvrTimeInterval() <= 0 then
            _myMineralInfo[k] = nil
            _countDownLabel[k]:removeFromParentAndCleanup(true)
            _countDownLabel[k] = nil
        --]]
        else
            local remain_time = my_mineral_info.expireTime - BTUtil:getSvrTimeInterval()
            remain_time = remain_time < 0 and 0 or remain_time
            local time_str = TimeUtil.getTimeString(remain_time)
            _countDownLabel[k]:setString(time_str)
        end
    end
    if is_stop == true then
        stopTimeScheduler()
    end
end 

-- 获得某个domain的所有矿信息
function onekeySearchCallback( cbFlag, dictData, bRet )

    print(GetLocalizeStringBy("key_1394"))
    print_t(dictData)
	if (dictData.err == "ok") then
		
		if( not table.isEmpty(dictData.ret))then
			_curDomainInfos = dictData.ret
			for k, m_info in pairs(_curDomainInfos) do
				if(tonumber(m_info.uid)>0)then
					_curDomainInfos[k].expireTime 		 = BTUtil:getSvrTimeInterval() + tonumber(m_info.due_time)
					_curDomainInfos[k].protectExpireTime = BTUtil:getSvrTimeInterval() + tonumber(m_info.protect_time)
				end
				_curDomainId 	= tonumber(m_info.domain_id)
				_curFieldType 	= tonumber(m_info.domain_type)
			end
			create()
			AnimationTip.showTip(GetLocalizeStringBy("key_3055"))
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_1685"))
		end
	end
end

-- 一键搜索两个按钮Action
local function onekeyFindCallback( tag, itembtn )
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    _choose_bar:setVisible(not _choose_bar:isVisible())
end 

function createChooseBar()
    local choose_bar = CCLayer:create()
    _choose_bg = CCSprite:create("images/active/mineral/choose_bg.png")
    choose_bar:addChild(_choose_bg)
    choose_bar:setContentSize(_choose_bg:getContentSize())
    local menu = CCMenu:create()
    _choose_bg:addChild(menu)
    menu:setTouchPriority(_choose_bar_touch_priority - 1)
    menu:setPosition(ccp(0, 0))
    local menu_item_datas = {
        {
            normal_image = "images/active/mineral/btn_mineral2_h.png",
            selected_image = "images/active/mineral/btn_mineral2_n.png",
            callback = callbackIron
        },
        {
            normal_image = "images/active/mineral/copper_h.png",
            selected_image = "images/active/mineral/copper_n.png",
            callback = callbackSearchCopper
        },
        {
            normal_image = "images/active/mineral/silver_h.png",
            selected_image = "images/active/mineral/silver_n.png",
            callback = callbackSearchSilver
        },
        {
            normal_image = "images/active/mineral/gold_h.png",
            selected_image = "images/active/mineral/gold_n.png",
            callback = callbackSearchGold
        },
        {
            normal_image = "images/active/mineral/icon/s_hongbaoshi.png",
            selected_image = "images/active/mineral/hong_n.png",
            callback = callbackSearchRed
        },
        {
            normal_image = "images/active/mineral/icon/s_zuanshi.png",
            selected_image = "images/active/mineral/zuanshi_n.png",
            callback = callbackSearchDiamond
        }
    }
    local index_begin = 1
    if _curFieldType == High_Field_Type then
        index_begin = 2
    elseif _curFieldType == Gold_Field_Type then
        index_begin = 4
    end
    local menu_item_x = 0
    for i = index_begin, index_begin + 2 do
        local menu_data = menu_item_datas[i]
        local menu_item = CCMenuItemImage:create(menu_data.normal_image, menu_data.selected_image)
        menu:addChild(menu_item)
        menu_item:setAnchorPoint(ccp(0.5, 0.5))
        menu_item:registerScriptTapHandler(menu_data.callback)
        menu_item_x = menu_item_x + 107
        menu_item:setPosition(menu_item_x - 42, 50)
    end
    return choose_bar
end

function onTouchesHandlerChooseBar( eventType, x, y )
	if (eventType == "began") then
        if not _choose_bar:isVisible() then
            return false
        end
        local point = _choose_bar:convertToNodeSpace(ccp(x, y))
        local bounding_box = _choose_bg:boundingBox()
        if bounding_box:containsPoint(point) then
           return true
        end
	    return false
    elseif (eventType == "moved") then
    else
	end
end

function onNodeEventChooseBar( event )
	if (event == "enter") then
		_choose_bar:registerScriptTouchHandler(onTouchesHandlerChooseBar, false, -423, true)
        _choose_bar:setTouchEnabled(true)
	elseif (event == "exit") then
		_choose_bar:unregisterScriptTouchHandler()
	end
end

-- 搜索铁矿
function callbackIron()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    search(1)
end

-- 搜索铜矿
function callbackSearchCopper()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    search(2)
end

-- 搜索银矿
function callbackSearchSilver()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    search(3)
end

-- 搜索金矿
function callbackSearchGold()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    search(4)
end

function callbackSearchBlue()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    search(5)
end

function callbackSearchRed()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    search(6)
end

function callbackSearchDiamond()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    search(7)
end


function search(res_type)
    local data = CCArray:create()
	data:addObject(CCInteger:create(res_type))
    RequestCenter.mineral_explorePit(onekeySearchCallback, data)
end

function callbackMyMineral(tag, menu_item)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    local index = tag
    local mineral_info = _myMineralInfo[tostring(index)]
    if mineral_info == nil then
        if index == 2 then
            SingleTip.showTip(GetLocalizeStringBy("key_8351"))
        else
            SingleTip.showTip(GetLocalizeStringBy("key_8077"))
        end
    else
        sendDomainRequestBy(tonumber(mineral_info.domain_id), function ( cbFlag, dictData, bRet )
            pitsByDomainCallback(cbFlag, dictData, bRet)
            MineralInfoLayer.show(mineral_info)
        end)
    end
end

-- 创建自己的矿和一键搜索两个按钮
function createTwoBtn()
    if(_border_BG) then
        stopTimeScheduler()
        _countDownLabel = {}
        _border_BG:removeFromParentAndCleanup(true)
		_border_BG = nil
        _selfElvesBtn = nil
        _selfElvesBtnEffect = nil
	end
    _border_BG = CCNode:create()--CCLayerColor:create(ccc4(255, 0, 0, 255))
    _border_BG:ignoreAnchorPointForPosition(false)
    _border_BG:setContentSize(CCSizeMake(640, 100))
    _border_BG:setAnchorPoint(ccp(0.5,1))
    _border_BG:setPosition(ccp(g_winSize.width * 0.5,
                            _bgLayer:getContentSize().height - _top_sprite:getContentSize().height * _top_sprite:getScale()))
    _bgLayer:addChild(_border_BG, _border_BG_z)
    _border_BG:setScale(1 / MainScene.elementScale * g_fScaleX)

    local left_bar = CCScale9Sprite:create("images/active/mineral/top_bar.png",
                                            CCRectMake(0, 0, 209, 49),
                                            CCRectMake(90, 34, 25, 4))
    _border_BG:addChild(left_bar)
    left_bar:setAnchorPoint(ccp(0, 0))
    left_bar:setPosition(ccp(-30, 0))
    left_bar:setPreferredSize(CCSizeMake(--[[310]]209, 93))
    local right_bar = CCScale9Sprite:create("images/active/mineral/top_bar.png",
                                            CCRectMake(0, 0, 209, 49),
                                            CCRectMake(90, 34, 25, 4))
    _border_BG:addChild(right_bar)
    right_bar:setAnchorPoint(ccp(1, 0))
    right_bar:setPreferredSize(CCSizeMake(360, 93))
    right_bar:setPosition(ccp(_border_BG:getContentSize().width, 0))

    _twoMenuBar = CCMenu:create()
	_twoMenuBar:setPosition(ccp(0, 0))
	_border_BG:addChild(_twoMenuBar)


	-- 我自己的矿
    for i = 1, 2 do
        local mineral_btn = nil
        local mineral_status_text = nil
        local my_mineral_info = _myMineralInfo[tostring(i)]
        if my_mineral_info ~= nil then
            local mineral_db = DB_Res.getDataById(tonumber(my_mineral_info.domain_id))
            local normal_image_name = "images/active/mineral/icon/s_" .. mineral_db["res_icon" .. my_mineral_info.pit_id]
            local hight_lighted_image_name = "images/active/mineral/icon/s_" .. mineral_db["res_icon" .. my_mineral_info.pit_id]
            mineral_btn = CCMenuItemImage:create(normal_image_name, hight_lighted_image_name)
            if MineralUtil.isMyGuardMineral(my_mineral_info) then
                mineral_status_text = GetLocalizeStringBy("key_8064")
            else
                mineral_status_text = GetLocalizeStringBy("key_8065")
            end
            local expire_time = my_mineral_info.expireTime - BTUtil:getSvrTimeInterval()
            if expire_time < 0 then
                expire_time = 0
            end
            local time_str = TimeUtil.getTimeString(expire_time)
            local countDownLabel = CCLabelTTF:create(time_str, g_sFontName, 21)
            countDownLabel:setColor(ccc3(0x2a, 0xff, 0x00))
            countDownLabel:setAnchorPoint(ccp(0.5, 1))
            countDownLabel:setPosition(ccp(mineral_btn:getContentSize().width * 0.5, 9))
            countDownLabel:setTag(i)
            mineral_btn:addChild(countDownLabel)
            _countDownLabel[tostring(i)] = countDownLabel
            -- 倒计时
            startTimeScheduler()
            --if my_mineral_info.domain_type ~= "3" then
            MineralMenuItem.addGuard(mineral_btn, my_mineral_info, mineral_db, true)
            --end
        else
            mineral_status_text = GetLocalizeStringBy("key_8063")
            local normal_image_name = "images/active/mineral/btn_mineral_n.png"
            local hight_lighted_image_name = "images/active/mineral/btn_mineral_h.png"
            mineral_btn = CCMenuItemImage:create(normal_image_name, hight_lighted_image_name)
        end
        local mineral_status_label = CCRenderLabel:create(mineral_status_text , g_sFontName, 19, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
        mineral_btn:addChild(mineral_status_label)
        mineral_status_label:setAnchorPoint(ccp(0.5, 0))
        mineral_status_label:setPosition(ccp(mineral_btn:getContentSize().width * 0.5, 13))
        mineral_status_label:setColor(ccc3(0xff, 0xff, 0xff))
        _twoMenuBar:addChild(mineral_btn, 5 - i)
        mineral_btn:setTag(i)
        mineral_btn:setAnchorPoint(ccp(0.5, 0))
        mineral_btn:setPosition(ccp(80 + 120 * (i - 1), 13))
        mineral_btn:registerScriptTapHandler(callbackMyMineral)
    end
    -- 一键找矿
	local normalImageName 		= "images/active/mineral/btn_onekey_n.png"
	local hightLightedImageName = "images/active/mineral/btn_onekey_h.png"
	local oneKeyBtn = CCMenuItemImage:create(normalImageName, hightLightedImageName)
	oneKeyBtn:setAnchorPoint(ccp(0.5, 0))
	oneKeyBtn:registerScriptTapHandler(onekeyFindCallback)
	oneKeyBtn:setPosition(ccp(465, 0))
	_twoMenuBar:addChild(oneKeyBtn, 1, 95002 )
   
     require "script/ui/guild/city/BattlefieldReportLayer"
    _choose_bar = createChooseBar()
    _choose_bar:setPosition((-_choose_bar:getContentSize().width + oneKeyBtn:getContentSize().width) * 0.5,
                            -_choose_bar:getContentSize().height)
    _choose_bar:registerScriptHandler(onNodeEventChooseBar)
    _choose_bar:setVisible(false)
    oneKeyBtn:addChild(_choose_bar)
    
     -- 返回的按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0.5, 0))
	closeMenuItem:registerScriptTapHandler(backAction)
	closeMenuItem:setPosition(ccp(568, oneKeyBtn:getPositionY() + 6))
	_twoMenuBar:addChild(closeMenuItem)

	-- 邮件入口
	local mailMenuItem = CCMenuItemImage:create("images/active/mineral/btn_mail_n.png","images/active/mineral/btn_mail_h.png")
	mailMenuItem:setAnchorPoint(ccp(0.5, 0))
	mailMenuItem:registerScriptTapHandler(mailAction)
	mailMenuItem:setPosition(ccp(350, oneKeyBtn:getPositionY() + 4))
	_twoMenuBar:addChild(mailMenuItem)
	-- new
	newAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/mail/new/new"), -1,CCString:create(""));
    newAnimSprite:setPosition(ccp(mailMenuItem:getContentSize().width*0.5-20,mailMenuItem:getContentSize().height-10))
   	mailMenuItem:addChild(newAnimSprite,3,10)
   	local isShow = MailData.getResourcesNewMailStatus()
   	if(isShow == "true")then
   		newAnimSprite:setVisible(true)
   	else
   		newAnimSprite:setVisible(false)
   	end

end

-- 矿的操作
local function mineralBtnAction( tag, itembtn )
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
	local mineral_info = _curDomainInfos[tag-9000]
    MineralInfoLayer.show(mineral_info)
end

-- 创建当前页的矿
function createCurDomainMineral( )
	local xPositionScale = {120.0/640, 425.0/640, 260.0/640, 140.0/640, 470.0/640}
	local yPositionScale = {605.0/960, 650.0/960, 418.0/960, 240.0/960, 350.0/960}

	if(_curDomainMenuBar)then
		_curDomainMenuBar:removeFromParentAndCleanup(true)
		_curDomainMenuBar=nil
	end
	_curDomainMenuBar = CCMenu:create()
	_curDomainMenuBar:setPosition(ccp(0,0))
	_bgLayer:addChild(_curDomainMenuBar)

	
	for i=1, 5 do
		local m_btn = MineralMenuItem.createMenuItemByData( _curDomainInfos[i] )
		m_btn:setAnchorPoint(ccp(0.5,0))
		m_btn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*(xPositionScale[i]), _bgLayer:getContentSize().height*yPositionScale[i]))
		m_btn:registerScriptTapHandler(mineralBtnAction)
		_curDomainMenuBar:addChild(m_btn, 2, 9000+i)
	end
    if _should_show_current_page_tip == true then
        showCurrentPageTip()
        _should_show_current_page_tip = false
    end

    loadElves()
end

function loadElves( ... )
    -- 宝藏出现剩余时间
    local remainStartTime = 0
    local status = MineralElvesData.getElvesStatus()
    if status == MineralElvesData.ksNotOpened or status == MineralElvesData.ksEnded then
        return
    end
    if _curPage > tonumber(MineralElvesData.getElvesDb().page) then
        return
    end
    if status == MineralElvesData.ksNotStart then
        remainStartTime = MineralElvesData.getTodayStartRemainTime()
    elseif status == MineralElvesData.ksWaiting then
        remainStartTime = MineralElvesData.getNextElvesStartRemainTime()
    end
    if remainStartTime > 0 then
        performWithDelay(_curDomainMenuBar, function ( ... )
            refreshSelfElvesBtn()
            MineralElvesService.getMineralElvesByDomainId(_curDomainId, createCurDomainMineralElves)
        end, remainStartTime)
    else
        MineralElvesService.getMineralElvesByDomainId(_curDomainId, createCurDomainMineralElves)
    end
end

-- 创建当前页的宝藏
function createCurDomainMineralElves( ... )
    local xPositionScale = {450.0/640}
    local yPositionScale = {470.0/960}
    local mineralElvesDatas = MineralElvesData.getCurMineralElvesDatas()
    local elfBtns = {}
    for i = 1, 1 do
        local elfData = mineralElvesDatas[i]
        if table.isEmpty(elfData) then
            break
        end
        local elfBtn = MineralMenuItem.createElfMenuItemByData(elfData)
        elfBtn:setAnchorPoint(ccp(0.5, 0))
        elfBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*(xPositionScale[i]), _bgLayer:getContentSize().height*yPositionScale[i]))
        elfBtn:registerScriptTapHandler(mineralElfBtnAction)
        _curDomainMenuBar:addChild(elfBtn, 2, i)
        table.insert(elfBtns, elfBtn)
    end
    -- 得到本波结束倒计时
    local curElvesEndRemainTime = MineralElvesData.getCurElvesEndRemainTime()
    performWithDelay(_curDomainMenuBar, function ( ... )
        for k, v in pairs(elfBtns) do
            v:removeFromParentAndCleanup(true)
        end
        MineralElfInfoLayer.close()
        loadElves()
        MineralElvesData.setSelfMineralElvesData({})
        refreshSelfElvesBtn()
    end, curElvesEndRemainTime)
end

function mineralElfBtnAction(p_tag, p_menuItem)
    local mineralElvesDatas = MineralElvesData.getCurMineralElvesDatas()
    MineralElfInfoLayer.show(mineralElvesDatas[p_tag])
end

function showCurrentPageTip()
    if _page_tip ~= nil then
        _page_tip:removeFromParentAndCleanup(true)
    end
    _page_tip = CCSprite:create("images/active/mineral/page_tip_bg.png")
    _bgLayer:addChild(_page_tip, 10000)
    _page_tip:setAnchorPoint(ccp(0.5, 0.5))
    _page_tip:setPosition(g_winSize.width * 0.5, g_winSize.height * 0.5)
    local tip_lables = {}
    if _curFieldType == Normal_Field_Type then
        tip_lables[1] = CCLabelTTF:create(GetLocalizeStringBy("key_2722"), g_sFontPangWa, 28)
        tip_lables[1]:setColor(ccc3(0x00, 0xeb, 0x21))
    elseif _curFieldType == High_Field_Type then
        tip_lables[1] = CCLabelTTF:create(GetLocalizeStringBy("key_1427"), g_sFontPangWa, 28)
        tip_lables[1]:setColor(ccc3(0xff, 0x00, 0xe1))
    elseif _curFieldType == Gold_Field_Type then
        tip_lables[1] = CCLabelTTF:create( GetLocalizeStringBy("key_8312"), g_sFontPangWa, 28)
        tip_lables[1]:setColor(ccc3(0xff, 0x00, 0xe1))
    end
    tip_lables[2] = CCLabelTTF:create(_current_page .. GetLocalizeStringBy("key_2763"), g_sFontPangWa, 28)
    tip_lables[2]:setColor(ccc3(0xff, 0xf6, 00))
    local page_tip_lable = CCSprite:create()
    _page_tip:addChild(page_tip_lable)
    page_tip_lable:setCascadeOpacityEnabled(true)
    local tip_width = 0
    for i = 1, #tip_lables do
        local label = tip_lables[i]
        page_tip_lable:addChild(label)
        label:setAnchorPoint(ccp(0, 0.5))
        label:setPosition(ccp(tip_width, tip_lables[1]:getContentSize().height * 0.5))
        tip_width = tip_width + label:getContentSize().width
    end
    page_tip_lable:setContentSize(CCSizeMake(tip_width, tip_lables[1]:getContentSize().height))
    
    
    page_tip_lable:setAnchorPoint(ccp(0.5, 0.5))
    page_tip_lable:setPosition(ccp(_page_tip:getContentSize().width * 0.5, _page_tip:getContentSize().height * 0.5 - 9))
    _page_tip:setCascadeOpacityEnabled(true)
    
    _page_tip:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCFadeOut:create(2)))
end

-- 选中哪一页
local function pageAction( tag, itembtn)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    _curPageBtn:setEnabled(true)
	if(_curPageBtn ~= itembtn) then
		_curPageBtn = itembtn
		_curPageBtn:setEnabled(false)
        _current_page = tag
        _should_show_current_page_tip = true
        sendDomainRequestBy( _curPageInfos[tag] )
        refreshRobNodePosition()
	end
end 

-- 左右翻页
--[[
local function nextPageAction( tag, itembtn )
	if(tag == 12301) then
		if(_curPage>1)then
			sendDomainRequestBy( _curPageInfos[(_curPage-1)*6] )
		end
	elseif(tag == 12302) then
		if(_curPage>1)then
			
		end

		if((_curPage*_itemPerPage + 1) <=  #_curPageInfos) then
			sendDomainRequestBy(_curPageInfos[_curPage*_itemPerPage + 1])
		end
	end
end
--]]

-- 分页
function curMineralFieldByPage()
	_curPageInfos = getDomainByField(_curFieldType)

	if(_pageMenuBarBg)then
		_pageMenuBarBg:removeFromParentAndCleanup(true)
		_pageMenuBarBg=nil
	end

	
	_pageMenuBarBg = CCScale9Sprite:create("images/common/bg/m_9s_bg.png")
	_pageMenuBarBg:setContentSize(CCSizeMake(640, 65))
	_pageMenuBarBg:setAnchorPoint(ccp(0.5, 0.5))
	_pageMenuBarBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.15))
	_bgLayer:addChild(_pageMenuBarBg)

	local totalPages = math.ceil(#_curPageInfos/_itemPerPage)
	local curIndex = 1
	for k, domain_id in pairs(_curPageInfos) do
		if(tonumber(domain_id) == _curDomainId) then
			curIndex = k
			break
		end
	end
	_curPage =  math.ceil(curIndex/_itemPerPage)
	local pageMenuBar = CCMenu:create()
	pageMenuBar:setPosition(ccp(0,0))
	_pageMenuBarBg:addChild(pageMenuBar)

    ------------------------------------------- added by bzx
    local page_menu_layer = CCLayer:create()
    local menu = CCMenu:create()
    menu:setPosition(ccp(0, 0))
    page_menu_layer:addChild(menu)
    local start = (_curPage-1)*_itemPerPage
    local index_max = #_curPageInfos
    page_menu_layer:setContentSize(CCSizeMake(_cell_width * index_max, _pageMenuBarBg:getContentSize().height))
    for i = 1, index_max do
        local page_item = CCMenuItemImage:create("images/active/mineral/btn_page_n.png", "images/active/mineral/btn_page_h.png", "images/active/mineral/btn_page_h.png")
        menu:addChild(page_item)
        page_item:setAnchorPoint(ccp(1, 0.5))
        page_item:setPosition(ccp(90 * i - 10, _pageMenuBarBg:getContentSize().height * 0.5))
        page_item:registerScriptTapHandler(pageAction)
        page_item:setTag(i)
        local page_label = CCRenderLabel:create(i , g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        page_label:setAnchorPoint(ccp(0.5, 0.5))
        page_label:setColor(ccc3(0xff, 0xff, 0xff))
        page_label:setPosition(ccp(page_item:getContentSize().width * 0.5, page_item:getContentSize().height * 0.5))
        page_item:addChild(page_label)

        if tonumber(_curPageInfos[i]) == _curDomainId then
            page_item:selected()
            _curPageBtn = page_item
            _current_page = i
        end
    end
    _page_scroll_view = CCScrollView:create()
    _pageMenuBarBg:addChild(_page_scroll_view)
    _page_scroll_view:setDirection(kCCScrollViewDirectionHorizontal)
    _page_scroll_view:setViewSize(CCSizeMake(540, _pageMenuBarBg:getContentSize().height))
    _page_scroll_view:setContentSize(CCSizeMake(page_menu_layer:getContentSize().width, _pageMenuBarBg:getContentSize().height))
    _page_scroll_view:setTouchPriority(menu:getTouchPriority() - 10)
    _page_scroll_view:setPosition(ccp((_pageMenuBarBg:getContentSize().width - _page_scroll_view:getViewSize().width) * 0.5, 0))
    _page_scroll_view:setContainer(page_menu_layer)
    _page_scroll_view:setContentOffset(_page_menu_offset)

    _left_arrows = CCSprite:create("images/active/mineral/btn_left.png")
    _left_arrows:setAnchorPoint(ccp(0.5, 0.5))
    _left_arrows_gray = BTGraySprite:create("images/active/mineral/btn_left.png")
    _left_arrows_gray:setAnchorPoint(_left_arrows:getAnchorPoint())
    local left_arrows_position = ccp(28, _pageMenuBarBg:getContentSize().height * 0.5)
    _left_arrows:setPosition(left_arrows_position)
    _left_arrows_gray:setPosition(left_arrows_position)
    _pageMenuBarBg:addChild(_left_arrows)
    _pageMenuBarBg:addChild(_left_arrows_gray)
    _right_arrows = CCSprite:create("images/active/mineral/btn_right.png")
    _right_arrows:setAnchorPoint(_left_arrows:getAnchorPoint())
    _right_arrows_gray = BTGraySprite:create("images/active/mineral/btn_right.png")
    _right_arrows_gray:setAnchorPoint(_left_arrows:getAnchorPoint())
    local right_arrows_position = ccp(610, _pageMenuBarBg:getContentSize().height * 0.5)
    _right_arrows:setPosition(right_arrows_position)
    _right_arrows_gray:setPosition(right_arrows_position)
    _pageMenuBarBg:addChild(_right_arrows_gray)
    _pageMenuBarBg:addChild(_right_arrows)
    -------------------------------------------
    timerRefreshArrows()
    startTimerRefreshArrows()
end

function timerRefreshArrows(time)
    local offset = _page_scroll_view:getContentOffset()
    if offset.x >= 0 then
        _left_arrows:setVisible(false)
        _left_arrows_gray:setVisible(true)
    else
        _left_arrows_gray:setVisible(false)
        _left_arrows:setVisible(true)
    end
    if offset.x <= -_page_scroll_view:getContentSize().width + _page_scroll_view:getViewSize().width then
        _right_arrows:setVisible(false)
        _right_arrows_gray:setVisible(true)
    else
        _right_arrows_gray:setVisible(false)
        _right_arrows:setVisible(true)
    end
end

---- 选择矿区
function selectFieldAction( tag, itembtn )
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
	itembtn:selected()
    _page_menu_offset = ccp(0, 0)
    _page_scroll_view:setContentOffset(_page_menu_offset)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    print("tag=", tag)
	if(_curFieldButton ~= itembtn ) then
		stopTimeScheduler()
		_curFieldButton:unselected()
		_curFieldButton = itembtn
		_curFieldButton:selected()
		_curFieldType = tag
        _current_page = 1
		_curPageInfos = getDomainByField(_curFieldType)
		sendDomainRequestBy( _curPageInfos[1] )
        refreshRobNodePosition()
	end
end

---- 创建区域按钮
function createFieldButton( )
	---- 普通区域和高级区域的两个按钮

	if(_fieldMenuBar)then
		_fieldMenuBar:removeFromParentAndCleanup(true)
		_fieldMenuBar=nil
	end
	_fieldMenuBar = CCMenu:create()
	_fieldMenuBar:setPosition(ccp(0, 0))
	_fieldMenuBar:setTouchPriority(-402)
	_bgLayer:addChild(_fieldMenuBar)

	-- 普通
	local normalBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_2722"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	normalBtn:setAnchorPoint(ccp(0.5, 0.5))
	normalBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*0.2, _bgLayer:getContentSize().height*0.05))
	normalBtn:registerScriptTapHandler(selectFieldAction)
	_fieldMenuBar:addChild(normalBtn,1, Normal_Field_Type)

	-- 高级
	local highBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple_n.png","images/common/btn/btn_purple_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_1427"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	highBtn:setAnchorPoint(ccp(0.5, 0.5))
	highBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.05))
	highBtn:registerScriptTapHandler(selectFieldAction)
	_fieldMenuBar:addChild(highBtn,1,High_Field_Type)

    local goldBtn = LuaCC.create9ScaleMenuItem("images/common/btn/red_btn_n.png","images/common/btn/red_btn_h.png",CCSizeMake(200, 71), GetLocalizeStringBy("key_8312"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	goldBtn:setAnchorPoint(ccp(0.5, 0.5))
	goldBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*0.8, _bgLayer:getContentSize().height*0.05))
	goldBtn:registerScriptTapHandler(selectFieldAction)
	_fieldMenuBar:addChild(goldBtn,1,Gold_Field_Type)

    -- todo

	if(_curFieldType == Normal_Field_Type) then
		_curFieldButton = normalBtn
	elseif _curFieldType == High_Field_Type then
		_curFieldButton = highBtn
	elseif _curFieldType == Gold_Field_Type then
        _curFieldButton = goldBtn
    else
        _curFieldButton = normalBtn
    end

	_curFieldButton:selected()
end

-- create
function create()
    if _page_scroll_view ~= nil then
        local x_min = -_page_scroll_view:getContentSize().width + _page_scroll_view:getViewSize().width
        local x_max = 0
        _page_menu_offset = _page_scroll_view:getContentOffset()
        if _page_menu_offset.x > x_max then
            _page_menu_offset.x = x_max
        elseif _page_menu_offset.x < x_min then
            _page_menu_offset.x = x_min
        end
    end
	local bgLayerSize = _bgLayer:getContentSize()
---- 创建两个按钮
	createTwoBtn()
    -- 计算军团加成
    initGuildAdditionInfo()
---- 创建当前的所有矿
	createCurDomainMineral( )
---- 创建枫叶
	curMineralFieldByPage()
---- 创建区域按钮
	createFieldButton()
    -- 抢矿信息
    createRobInfoBtn()
    -- 资源矿说明
    createDescBtn()
    -- 弹幕
    createBulletBtn()
    -- 军团加成说明
    refreshGuildAdditionTip()
    refreshRobNodePosition()
    loadElvesTipLabel()
    -- 我的宝藏
    refreshSelfElvesBtn()
end

function loadElvesTipLabel( ... )
    local status = MineralElvesData.getElvesStatus()
    print("elves_status = ", status)
    if status == MineralElvesData.ksNotStart then
        local startRemainTime = MineralElvesData.getTodayStartRemainTime()
        if _startRefreshElvesTipLabelTimer == nil then
            performWithDelay(_bgLayer, startRefreshElvesTipLabel, startRemainTime)
        end
    elseif status > MineralElvesData.ksNotStart and status < MineralElvesData.ksEnded then
        startRefreshElvesTipLabel();
    end
end

function startRefreshElvesTipLabel( ... )
    refreshElvesTipLabel()
    if _refreshElvesTipLabelTimer == nil then
        _refreshElvesTipLabelTimer = schedule(_bgLayer, refreshElvesTipLabel, 1)
    end
end



function refreshElvesTipLabel( ... )
    if _elvesActivityTipLabel ~= nil then
        _elvesActivityTipLabel:removeFromParentAndCleanup(true)
    end
    if _curElvesTipLabel ~= nil then
        _curElvesTipLabel:removeFromParentAndCleanup(true)
    end
    local status = MineralElvesData.getElvesStatus()
    print("status = ", status)
    if status == MineralElvesData.ksEnded and _refreshElvesTipLabelTimer ~= nil then
        _bgLayer:stopAction(_refreshElvesTipLabelTimer)
        return
    end
    local endRemainTime = MineralElvesData.getTodayEndRemainTime()
    local text = string.format(GetLocalizeStringBy("key_10360"), TimeUtil.getTimeString(endRemainTime))
    _elvesActivityTipLabel = CCRenderLabel:create(text, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _elvesActivityTipLabel:setColor(ccc3(0x36, 0xFF, 0x00))
    _bgLayer:addChild(_elvesActivityTipLabel, 20)
    _elvesActivityTipLabel:setAnchorPoint(ccp(1, 0.5))
    --_elvesActivityTipLabel:setPosition(ccp(_bgLayer:getContentSize().width - 20 , 320 * MainScene.elementScale))
    _elvesActivityTipLabel:setPosition(ccp(_bgLayer:getContentSize().width - 20, _bgLayer:getContentSize().height*0.34))

    local text = ""
    if status == MineralElvesData.ksFighting then
        local curElvesEndRemainTime = MineralElvesData.getCurElvesEndRemainTime()
        text = string.format(GetLocalizeStringBy("key_10361"), TimeUtil.getTimeString(curElvesEndRemainTime))
    elseif status == MineralElvesData.ksWaiting then
        local nextElvesStartRemainTime = MineralElvesData.getNextElvesStartRemainTime()
        text = string.format(GetLocalizeStringBy("key_10362"), TimeUtil.getTimeString(nextElvesStartRemainTime))
    end
    _curElvesTipLabel = CCRenderLabel:create(text, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _curElvesTipLabel:setColor(ccc3(0x36, 0xFF, 0x00))
    _bgLayer:addChild(_curElvesTipLabel, 20)
    _curElvesTipLabel:setAnchorPoint(ccp(1, 0.5))
    --_curElvesTipLabel:setPosition(ccp(_bgLayer:getContentSize().width - 20, 295 * MainScene.elementScale))
    _curElvesTipLabel:setPosition(ccp(_bgLayer:getContentSize().width - 20, _bgLayer:getContentSize().height*0.31))
end

function createDescBtn( ... )
    local description_btn = CCMenuItemImage:create("images/recycle/btn/btn_explanation_h.png", "images/recycle/btn/btn_explanation_n.png")
    _fieldMenuBar:addChild(description_btn)
    description_btn:setAnchorPoint(ccp(0.5, 0.5))
    description_btn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*0.73, _bgLayer:getContentSize().height*0.25))
    description_btn:registerScriptTapHandler(descriptionCallback)
end

function descriptionCallback( ... )
    require "script/ui/active/mineral/MineralDescLayer"
    MineralDescLayer.show()
end


function createRobInfoBtn()
    local robInfoBtn = CCMenuItemImage:create("images/active/mineral/btn_rob_n.png", "images/active/mineral/btn_rob_h.png")
    -- LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),"抢矿111信息",ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	robInfoBtn:setAnchorPoint(ccp(0.5, 0.5))
	robInfoBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*0.9, _bgLayer:getContentSize().height*0.25))
	robInfoBtn:registerScriptTapHandler(robInfoBtnCallback)
	_fieldMenuBar:addChild(robInfoBtn)
end

-- 弹幕
function createBulletBtn( ... )
    require "script/ui/bulletLayer/BulletDef"
    require "script/ui/bulletLayer/BulletUtil"
    local bulletBtn = BulletUtil.createItem(BulletType.SCREEN_TYPE_MINE) 
    _fieldMenuBar:addChild(bulletBtn)
    bulletBtn:setAnchorPoint(ccp(0.5, 0.5))
    bulletBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*0.55, _bgLayer:getContentSize().height*0.25))
end

function robInfoBtnCallback()
    require "script/ui/active/mineral/MineralRobInfoLayer"
    MineralRobInfoLayer.show(-460)
end

-- 获得某个domain的所有矿信息
function pitsByDomainCallback( cbFlag, dictData, bRet )
	if (dictData.err == "ok") then
		_curDomainInfos = dictData.ret
		if( not table.isEmpty(_curDomainInfos))then
			for k, m_info in pairs(_curDomainInfos) do
				if(tonumber(m_info.uid)>0)then
					_curDomainInfos[k].expireTime 		 = BTUtil:getSvrTimeInterval()+ tonumber(m_info.due_time)
					_curDomainInfos[k].protectExpireTime = BTUtil:getSvrTimeInterval()+ tonumber(m_info.protect_time)
				end
				_curDomainId 	= tonumber(m_info.domain_id)
				_curFieldType 	= tonumber(m_info.domain_type)
			end
			create()
			-- 资源矿新手
			addGuideMineralGuide3()
		end
	end
end

-- 战斗结束了
function callbackBattleLayerEnd()
    require "script/ui/main/MainScene"
    MainScene.setMainSceneViewsVisible(false, false, true)
end

-- 请求某页前页的矿
function sendDomainRequestBy( domain_id , callback)
    callback = callback or pitsByDomainCallback
	local args = Network.argsHandler(domain_id)
	RequestCenter.mineral_getPitsByDomain(callback, args)
end

-- 请求自己矿的回调
function selfPitsInfoCallback(cbFlag, dictData, bRet)
	if(dictData.err ~= "ok") then
        return
    end
    _curFieldType = High_Field_Type
    
    ----------------------------- added by bzx
    for i = 1, #dictData.ret.pits do
        local mineral_info = dictData.ret.pits[i]
        MineralUtil.updateMyMineral(_myMineralInfo, mineral_info)
    end
    -----------------------------
    --[[
    if ( not table.isEmpty(dictData.ret)) then
        _myMineralInfo = dictData.ret[1]
        if( not table.isEmpty( _myMineralInfo ) ) then
            _myMineralInfo.expireTime = BTUtil:getSvrTimeInterval()+ tonumber(_myMineralInfo.due_time)
            if( _curDomainId == nil )then
                _curDomainId 	= tonumber(_myMineralInfo.domain_id)
            end
            _curFieldType 	= tonumber(_myMineralInfo.domain_type)
        end
    end
    --]]
    if( _curDomainId == nil )then
        local domin_ids = getDomainByField(_curFieldType)
        _curDomainId = domin_ids[1]
    end
    sendDomainRequestBy(_curDomainId)
end


------------ util --------------
-- 分区域获得 资源矿
function getDomainByField(fieldType)
	require "db/DB_Res"
	local mineralDesc = DB_Res.getArrDataByField("type", tonumber(fieldType))
	
	local domin_ids = {}
	for k,v in pairs(mineralDesc) do
		table.insert(domin_ids,tonumber(v.id))
	end
	
	local function sortFunc ( key_1, key_2 )
	   	return key_1 < key_2
	end
	table.sort( domin_ids, sortFunc )

	return domin_ids
end

-- create
function createLayer( domin_id)
	init()
	_curDomainId = domin_id
	_bgLayer = MainScene.createBaseLayer("images/active/mineral/mineralbg.jpg", false, false,true)
	_bgLayer:registerScriptHandler(onNodeEvent)
	createTopUI()
    MineralElvesService.getSelfMineralElves(function ( ... )
        RequestCenter.mineral_getSelfPitsInfo(selfPitsInfoCallback)
    end)
	return _bgLayer
end


---[==[资源矿 第3步
---------------------新手引导---------------------------------
function addGuideMineralGuide3( ... )
	require "script/guide/NewGuide"
	require "script/guide/MineralGuide"
    if(NewGuide.guideClass ==  ksGuideResource and MineralGuide.stepNum == 2) then
        MineralGuide.show(3, nil)
    end
end
---------------------end-------------------------------------
--]==]


-- 资源矿邮件new
function addNewTip( ... )
	if(newAnimSprite ~= nil)then
		newAnimSprite:setVisible(true)
	end
end

