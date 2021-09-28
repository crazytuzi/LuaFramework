-- Filename: WishRewardTableView.lua
-- Author: DJN
-- Date: 2014-08-08
-- Purpose: 跨服赛膜拜奖励tableView

module("WishRewardTableView", package.seeall)

require "db/DB_Kuafu_challengereward"
require "script/ui/item/ItemUtil"
require "script/model/utils/ActivityConfig"
local _cellNum
local _dataAfterDeal = {}
local _rewardId
--  分解奖励id字段
function analyzeGoodsTabStr( goodsStr )
    if(goodsStr == nil)then
        return
    end
    local goodsData = {}
    local goodsData = string.split(goodsStr, ",")
    return goodsData
end
--[[
    @des    :奖励数据
    @param  :
    @return :
--]]

function getData( ... )
   _rewardId = analyzeGoodsTabStr(tostring(ActivityConfig.ConfigCache.lordwar.data[1].wishReward))
   -- require "db/DB_Kuafu_personchallenge"
   -- print_t(DB_Kuafu_personchallenge.getDataById(1).wishReward)
   -- _rewardId = analyzeGoodsTabStr(tostring(DB_Kuafu_personchallenge.getDataById(1).wishReward))
    _cellNum = table.count(_rewardId)
 
    for i = 1,_cellNum do
        table.insert(_dataAfterDeal,ItemUtil.getItemsDataByStr(DB_Kuafu_challengereward.getDataById(tonumber(_rewardId[i])).reward))
    end
end
--[[
    @des    :创建tableView
    @param  :
    @return :创建好的tableView
--]]
function createTableView()
    getData()
    --暂定只有一行奖励展示
    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(575, 215)
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

    return LuaTableView:createWithHandler(h, CCSizeMake(575, 630))
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
    local titleBgSprite = CCSprite:create("images/sign/sign_bottom.png")
    titleBgSprite:setAnchorPoint(ccp(0,1))
    titleBgSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))
    cellBgSprite:addChild(titleBgSprite)

    --标题名称
    local titleLabel = CCRenderLabel:create(DB_Kuafu_challengereward.getDataById(tonumber(_rewardId[p_pos])).des,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
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
    require "script/ui/lordWar/reward/WishRewardLayer"
    innerTableView:setTouchPriority(WishRewardLayer.getTouchPriority() - 1)
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

    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(130,130)
        elseif fn == "cellAtIndex" then
            a2 = createItemCell(_dataAfterDeal[p_innerPos][a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r = #_dataAfterDeal[p_innerPos]
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
    local itemSprite = ItemUtil.createGoodsIcon(p_dataInfo,WishRewardLayer.getTouchPriority()-10)
    itemSprite:setAnchorPoint(ccp(0.5,0.5))
    itemSprite:setPosition(ccp(65,75))
    prizeViewCell:addChild(itemSprite)

    return prizeViewCell
end