-- FileName: CountryWarExplainDialog.lua
-- Author: lichenyang
-- Date: 2015-04-00
-- Purpose: TM_FILENAME
--[[TODO List]]

module("CountryWarExplainDialog", package.seeall)


local _touchPriority = nil

function init( ... )
	_touchPriority = nil
end

function show( p_touchPriority )
    local scene = CCDirector:sharedDirector():getRunningScene()
    local layer = create(p_touchPriority)
    scene:addChild(layer,999,1231)
end

local function cardLayerTouch(eventType, x, y) 
    return true
end

function create( p_touchPriority )
    init()
	_touchPriority = p_touchPriority or -1024
	local maskLayer = CCLayerColor:create(ccc4(11,11,11,166))--BaseUI.createMaskLayer(-_touchPriority)
    maskLayer:setTouchEnabled(true)
    maskLayer:registerScriptTouchHandler(cardLayerTouch,false,_touchPriority-10,true)
    m_layerSize = CCSizeMake(580, 660)
	local m_reportBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    m_reportBg:setContentSize(m_layerSize)
    m_reportBg:setAnchorPoint(ccp(0.5,0.5))
    m_reportBg:setPosition(ccps(0.5,0.5))
    maskLayer:addChild(m_reportBg)
    setAdaptNode(m_reportBg)
    
    local displayName = CCRenderLabel:create(GetLocalizeStringBy("key_3022"), g_sFontPangWa, 35, 3, ccc3( 255, 255, 255), type_stroke)
    displayName:setColor(ccc3( 0x78, 0x25, 0x00));
    displayName:setPosition(m_layerSize.width*0.42,m_layerSize.height*0.93)
    m_reportBg:addChild(displayName)

    local scrollView = CCScrollView:create()
    scrollView:setViewSize(CCSizeMake(m_reportBg:getContentSize().width, m_reportBg:getContentSize().height*0.8))
    -- 在不同的机型上，Label的行高有时会不一样，所以得算
    local height =  0
    scrollView:setContentSize(CCSizeMake(m_reportBg:getContentSize().width*0.9, height))
    scrollView:setContentOffset(ccp(0, scrollView:getViewSize().height - scrollView:getContentSize().height))
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setTouchPriority(_touchPriority - 50)
    scrollView:setPosition(ccp(0, 30))
    scrollView:setAnchorPoint(ccp(0, 0))
    m_reportBg:addChild(scrollView, 20)
    
    require "db/DB_Help_tips"
    local desContent = DB_Help_tips.getDataById(9).tips
    desContent = string.gsub(desContent, "|", "\n")

    local  level = CountryWarMainData.getNeedLevel()
    local  needDay = CountryWarMainData.getNeedDay()
    local  weekDay = getWeekDay()
    local  startTime = getStartTime()
    local  overTime = getOverTime()
    local  auditionTime = getAuditionTime()
    local  finalNum = getFinalNum()
    local  supportTime = getSupportTime()
    local  resNum = getResNum()
    local  robRes = getRobRes()
    local  finaltionTime = getFinaltionTime()
    local  reward = getRewardDes()
    desContent = string.format(desContent, level ,needDay ,weekDay ,startTime,overTime,auditionTime,finalNum,supportTime,resNum,robRes,finaltionTime,reward)
    local descLabel = CCLabelTTF:create(desContent,g_sFontName,24,CCSizeMake(m_layerSize.width*0.9, height),kCCTextAlignmentLeft)
    descLabel:setColor(ccc3( 0x78, 0x25, 0x00));
    descLabel:setAnchorPoint(ccp(0, 0))
    descLabel:setPosition(35, 30)
    scrollView:addChild(descLabel)

    --TODO : lichenyang
    scrollView:setContentSize(CCSizeMake(m_reportBg:getContentSize().width*0.9, descLabel:getContentSize().height + 30))
    scrollView:setContentOffset(ccp(0, scrollView:getViewSize().height - scrollView:getContentSize().height))

    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-10)
    m_reportBg:addChild(menuBar)
    
    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(m_layerSize.width*1.02, m_layerSize.height*1.02))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(function( ... )
        maskLayer:removeFromParentAndCleanup(true)
        AudioUtil.playEffect("audio/effect/guanbi.mp3")
    end)
	return maskLayer
end


--[[
    @des:周几开启
--]]
function getWeekDay()
    local signUpTime = CountryWarMainData.getStageStartTime(CountryWarDef.SIGNUP)
    local wday = os.date("*t",signUpTime).wday
    local weekDesInfo = string.split(GetLocalizeStringBy("lcyx_2019"), ",")
    return weekDesInfo[tonumber(wday)] or ""
end

--[[
    @des:开启时间
--]]
function getStartTime()
    local signUpTime = CountryWarMainData.getStageStartTime(CountryWarDef.SIGNUP)
    return TimeUtil.getTimeOnlyMin(signUpTime)
end

--[[
    @des:结束时间
--]]
function getOverTime()
    local overTime = CountryWarMainData.getStageOverTime(CountryWarDef.FINALTION)
    return TimeUtil.getTimeOnlyMin(overTime)
end

--[[
    @des:初始持续时间
--]]
function getAuditionTime()
    local startTime = CountryWarMainData.getStageStartTime(CountryWarDef.AUDITION_READY)
    local overTime = CountryWarMainData.getStageOverTime(CountryWarDef.AUDITION)
    local time = TimeUtil.getTimeDesByInterval(overTime-startTime)
    return time
end

--[[
    @des:得到决赛名额
--]]
function getFinalNum()
    local dbInfo = DB_National_war.getDataById(1)
    return dbInfo.final_num
end

--[[
    @des:得到助威阶段持续时间
--]]
function getSupportTime()
    local startTime = CountryWarMainData.getStageStartTime(CountryWarDef.SUPPORT)
    local overTime = CountryWarMainData.getStageOverTime(CountryWarDef.SUPPORT)
    local time = TimeUtil.getTimeDesByInterval(overTime-startTime)
    return time
end

--[[
    @des:初始资源
--]]
function getResNum( ... )
    local dbInfo = DB_National_war.getDataById(1)
    return dbInfo.final_resource
end

--[[
    @des:抢夺资源
--]]
function getRobRes( ... )
    local dbInfo = DB_National_war.getDataById(1)
    return dbInfo.rob_resource
end

--[[
    @des:决赛持续时间
--]]
function getFinaltionTime( ... )
    local startTime = CountryWarMainData.getStageStartTime(CountryWarDef.FINALTION)
    local overTime = CountryWarMainData.getStageOverTime(CountryWarDef.FINALTION)
    local time = TimeUtil.getTimeDesByInterval(overTime-startTime)
    return time
end

--[[
    @des:得到奖励描述
--]]
function getRewardDes( ... )
    local dbInfo = DB_National_war.getDataById(1)
    local rewardInfo = dbInfo.win_rewards
    local info = ItemUtil.getItemsDataByStr(rewardInfo)
    local name,num = "",""
    if info[1] then
        name = tostring(info[1].name) or ""
        num = tostring(info[1].num) or ""
    end
    return string.format("%s%s",num, name)
end

