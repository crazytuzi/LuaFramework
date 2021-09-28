-- Filename: BowlRewardPreviewLayer.lua
-- Author: DJN
-- Date: 2015-01-13
-- Purpose: 聚宝盆奖励预览

module("BowlRewardPreviewLayer", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/rechargeActive/bowl/BowlCell"
require "script/model/utils/ActivityConfigUtil"
local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer          --触摸屏蔽层
local _preViewLayer     --TableView
local _title            --标题
local _selectedTag      --箱子索引tag
----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    _preViewLayer = nil 
    _title = nil
    _selectedTag = nil
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
       -- print("moved")
    else
       -- print("end")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end


----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建背景UI
    @param  :
    @return :
--]]
function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(620,840)
    local bgScale = MainScene.elementScale

    --主背景图
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)

    --标题背景
    local titleSprite = CCSprite:create("images/common/viewtitle1.png")
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
    bgSprite:addChild(titleSprite)
    
 
    --标题 
    local titleLabel = CCLabelTTF:create(_title, g_sFontPangWa, 30)
    titleLabel:setColor(ccc3(0xff,0xe4,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
    titleSprite:addChild(titleLabel)


    --二级背景
    local brownSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    brownSprite:setContentSize(CCSizeMake(575,665))
    brownSprite:setAnchorPoint(ccp(0.5,0.5))
    brownSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2-15))
    bgSprite:addChild(brownSprite)

    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)
    

    --关闭按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png","images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)

    createTableView(brownSprite)  
end
function createTableView(p_layer)  
    local  function rewardTableCallback(fn, t_table, a1, a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(568, 215)
        elseif fn == "cellAtIndex" then
            local rewardName = tostring("BowlReward"..a1+1)
            print("rewardName",rewardName)
            print_t(ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag])
            a2 = BowlCell.create( ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag]["BowlReward"..(a1+1)],a1+1,false)
            r = a2
        elseif fn == "numberOfCells" then
            r = tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag].rewardtime)
            --print("numberOfCells r = " ,r)
        elseif fn == "cellTouched" then
                
        end
        return r
    end
    rewardTablView = LuaTableView:createWithHandler(LuaEventHandler:create(rewardTableCallback), CCSizeMake(568,
                                                                           p_layer:getContentSize().height-10))
    rewardTablView:setBounceable(true)

    rewardTablView:setPosition(ccp(p_layer:getContentSize().width *0.5, 5))
    p_layer:addChild(rewardTablView)
    rewardTablView:setVerticalFillOrder(kCCTableViewFillTopDown)
    rewardTablView:ignoreAnchorPointForPosition(false)
    rewardTablView:setAnchorPoint(ccp(0.5, 0))
    rewardTablView:setTouchPriority(_touchPriority - 20)
end
----------------------------------------回调函数----------------------------------------
--[[
    @des    :关闭回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end
----------------------------------------回调函数----------------------------------------
--[[
    @des    :Menu回调
    @param  :
    @return :
--]]

function menuCallBack(tag, item )
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    require "script/ui/tip/AnimationTip"
    _curMenuItem:setEnabled(true)
   -- _curMenuItem:unselected()
    item:setEnabled(false)
    _curMenuItem= item

    if(_curMenuTag == tag) then
        return
    else
        _curMenuTag = tag
    end

    if(tag == _AoShiTag) then
        LordWarRewardTableView.setStage(1)
        LordWarRewardTableView.setCellNum()
        _preViewLayer:reloadData()
  
    elseif(tag == _ChuChuTag) then
        LordWarRewardTableView.setStage(2)
        LordWarRewardTableView.setCellNum()
        _preViewLayer:reloadData()
   end
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_title,p_selectedTag,p_touchPriority,p_ZOrder)
    init()
    _touchPriority = p_touchPriority or -550
    _ZOrder = p_ZOrder or 999
    _title = p_title
    _selectedTag = p_selectedTag
    --绿色触摸屏蔽层
    _bgLayer = CCLayerColor:create(ccc4(0x00,0x2e,0x49,153))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder) 
    --创建背景UI
    createBgUI()

   
end
--[[
    @des    :获得触摸优先级
    @param  :
    @return :触摸优先级
--]]
function getTouchPriority()
    return _touchPriority
end