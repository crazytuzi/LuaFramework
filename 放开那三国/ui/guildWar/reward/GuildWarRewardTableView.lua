-- Filename: GuildWarRewardTableView.lua
-- Author: DJN
-- Date: 2015-01-21
-- Purpose: 军团跨服赛奖励tableView

--module("GuildWarRewardTableView", package.seeall)
module("GuildWarRewardTableView", package.seeall)
require "db/DB_Kuafu_legionchallengereward"
require "script/ui/item/ItemUtil"
require "script/model/utils/ActivityConfig"
require "script/ui/item/ItemSprite"
local _ServerTag = nil
local _TableInfo = nil
local _stage = nil
local _cellNum = 0
local _OnWarTag  = 101  --上场奖励的tag
local _OtherTag  = 102  --未上场奖励的tag


--[[
    @des   :用stage作为表格的下标的索引，设置当前显示的是“傲视群雄”还是“初出茅庐”的奖励
    @param : stage:  2--傲视群雄  1-- 初出茅庐
    return :
--]]
function setStage(stage)
    _stage = tonumber(stage)
    if(_stage == _OnWarTag)then
        _TableInfo = ActivityConfig.ConfigCache.guildwar.data[1].strideRoutePrize
    elseif(_stage == _OtherTag)then
        _TableInfo = ActivityConfig.ConfigCache.guildwar.data[1].otherPrize
    end
    _TableInfo = ActivityConfig.ConfigCache.guildwar.data[1].serverPrize..","..ActivityConfig.ConfigCache.guildwar.data[1].cheerPrize..",".._TableInfo
    _TableInfo = string.split(_TableInfo, ",")
    print("_TableInfo")
    print_t(_TableInfo)

    _cellNum = table.count(_TableInfo)
    
end

function createTableView( p_stage )
    setStage(p_stage)  
    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(575, 210)
        elseif fn == "cellAtIndex" then
            --用a1+1做下标创建cell
            a2 = createPreviewCell(_cellNum - a1)
            r = a2
        elseif fn == "numberOfCells" then
            r = _cellNum
        else
            print("other function")
        end

        return r
    end)

    local tableViewResult = LuaTableView:createWithHandler(h, CCSizeMake(575, 661))
    tableViewResult:setVerticalFillOrder(kCCTableViewFillTopDown)
    return tableViewResult
end
--[[
    @des    :创建奖励预览cell
    @param  :奖励的位置，从1开始（即a1+1的值）
    @return :创建好的cell
--]]
function createPreviewCell(p_pos)
    local tCell = CCTableViewCell:create()

    --背景
    local cellBgSprite = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBgSprite:setContentSize(CCSizeMake(555,200))
    cellBgSprite:setAnchorPoint(ccp(0,0))
    cellBgSprite:setPosition(ccp(10,10))
    tCell:addChild(cellBgSprite)

    --标题背景
    local titleBgSprite = CCScale9Sprite:create("images/sign/sign_bottom.png")
    titleBgSprite:setContentSize(CCSizeMake(270,60))
    titleBgSprite:setAnchorPoint(ccp(0,1))
    titleBgSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))
    cellBgSprite:addChild(titleBgSprite)

    --标题名称
    local titleLabel = CCRenderLabel:create(DB_Kuafu_legionchallengereward.getDataById(tonumber(_TableInfo[p_pos])).des,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 

    titleLabel:setColor(ccc3(0xff,0xf6,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleBgSprite:getContentSize().width/2,titleBgSprite:getContentSize().height/2))
    titleBgSprite:addChild(titleLabel)

    --二级白色背景
    local whiteBgSprite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    whiteBgSprite:setContentSize(CCSizeMake(520,130))
    whiteBgSprite:setAnchorPoint(ccp(0.5,0))
    whiteBgSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,15))
    cellBgSprite:addChild(whiteBgSprite)

    --tableView嵌套tableView
    local innerTableView = createInnerTableView(p_pos)
    innerTableView:setAnchorPoint(ccp(0,0))
    innerTableView:setPosition(ccp(0,0))
    require "script/ui/lordWar/reward/LordWarRewardLayer"
    innerTableView:setTouchPriority(GuildWarRewardDialog.getTouchPriority() - 1)
    innerTableView:setDirection(kCCScrollViewDirectionHorizontal)
    innerTableView:reloadData()
    whiteBgSprite:addChild(innerTableView)

    return tCell
end

--[[
    @des    :创建内部tableView
    @param  :奖励条目
    @return :创建好的tableView
--]]
function createInnerTableView(p_innerPos)
    
    local dataAfterDeal = ItemUtil.getItemsDataByStr(DB_Kuafu_legionchallengereward.getDataById(tonumber(_TableInfo[p_innerPos])).reward)
    local tagArray = ItemUtil.analyzeGoodsStr(DB_Kuafu_legionchallengereward.getDataById(tonumber(_TableInfo[p_innerPos])).reward)
   
    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(130,130)
        elseif fn == "cellAtIndex" then
            a2 = createItemCell(dataAfterDeal[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r = #dataAfterDeal
        else
            --print("other function")
        end
        return r
    end)

    return LuaTableView:createWithHandler(h, CCSizeMake(520,130))
end

--[[
    @des    :创建内部cell
    @param  :当前的奖励信息
    @return :创建好的cell
--]]
function createItemCell(p_dataInfo)
    local prizeViewCell = CCTableViewCell:create()
    local itemSprite = ItemUtil.createGoodsIcon(p_dataInfo,GuildWarRewardDialog.getTouchPriority()-20,1000)
   
        
    itemSprite:setAnchorPoint(ccp(0.5,0.5))
    itemSprite:setPosition(ccp(65,75))
    prizeViewCell:addChild(itemSprite)
    

    return prizeViewCell
end

function itemDelegateAction( )
    MainScene.setMainSceneViewsVisible(true, true, true)
end