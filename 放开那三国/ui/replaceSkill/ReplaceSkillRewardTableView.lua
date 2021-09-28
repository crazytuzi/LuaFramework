-- Filename: ReplaceSkillRewardTableView.lua
-- Author: DJN
-- Date: 2014-08-12
-- Purpose: 主角换技能翻牌奖励预览tableView

module("ReplaceSkillRewardTableView", package.seeall)

require "db/DB_Teach"
require "script/ui/item/ItemUtil"
local _TableInfo = nil
local _desTable = {}
local _cellNum = 0
local _imagePath = "images/replaceskill/flipcard/"
local _eventPath = "images/replaceskill/event/"
--cell中展示的人物的头像图标，策划说写死，不读表
--local _iconArray = {"10018|10018|10018|10018|10018","10039|10039|10039|10039|10026","10039|10038|10018|10026|10037","10038|10038|10038|10046|10046","10039|10038|10033|10046|10026","10026|10026|10026|10046|10097","10033|10033|10037|10037|10018","10018|10018|10046|10097|10038"}
local _iconArray = {"qima.jpg|qima.jpg|qima.jpg|qima.jpg|qima.jpg","qiwu.jpg|qiwu.jpg|qiwu.jpg|qiwu.jpg|qima.jpg","shufa.jpg|shufa.jpg|shufa.jpg|tanqin.jpg|tanqin.jpg",
                    "suishi.jpg|suishi.jpg|suishi.jpg|qima.jpg|xiaqi.jpg","jianwu.jpg|jianwu.jpg|dalie.jpg|dalie.jpg|shufa.jpg","qiwu.jpg|qiwu.jpg|qima.jpg|xiaqi.jpg|tanqin.jpg","qima.jpg|dalie.jpg|tanqin.jpg|xiaqi.jpg|shufa.jpg"}
--  分解表中数据
function analyzeTabStr( goodsStr )
    if(goodsStr == nil)then
        return
    end
    local goodsData = {}
    local goodTab = string.split(goodsStr, ",")
    local tableCount = table.count(goodTab)
    for i = 1,tableCount do
        local tab = string.split(goodTab[i],"|")
        table.insert(goodsData,tab)
    end
    return goodsData
end

--[[
    @des    :创建tableView
    @param  :
    @return :创建好的tableView
--]]
function createTableView()
    _TableInfo = analyzeTabStr(DB_Teach.getDataById(1).draw)
    print("输出转换结果")
    print_t(_TableInfo)
   
    _cellNum = table.count(_TableInfo)
    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
           -- 
           r = CCSizeMake(575, 295)
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

    return LuaTableView:createWithHandler(h, CCSizeMake(575, 720))
end

--[[
    @des    :创建cell
    @param  :奖励的位置，从1开始（即a1+1的值）
    @return :创建好的cell
--]]
function createPreviewCell(p_pos)
    local tCell = CCTableViewCell:create()
    
    --背景
    local cellBgSprite = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBgSprite:setContentSize(CCSizeMake(555,290))
    cellBgSprite:setAnchorPoint(ccp(0,0))
    cellBgSprite:setPosition(ccp(10,10))
    tCell:addChild(cellBgSprite)

    --标题背景
    local titleBgSprite = CCSprite:create("images/sign/sign_bottom.png")
    titleBgSprite:setAnchorPoint(ccp(0,1))
    titleBgSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))
    cellBgSprite:addChild(titleBgSprite)
    --标题图片
    if(p_pos <= _cellNum) then
    local titleImage = CCSprite:create(_eventPath..p_pos..".png")
    --local titleImage = CCSprite:create("images/replaceskill/fipcard/3.png")
    titleImage:setAnchorPoint(ccp(0.5,0.5))
    --titleImage:setScale(0.8)
    titleImage:setPosition(ccp(titleBgSprite:getContentSize().width/2 ,titleBgSprite:getContentSize().height/2))
    titleBgSprite:addChild(titleImage)
    end
    --二级白色背景
    local whiteBgSprite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    whiteBgSprite:setContentSize(CCSizeMake(520,215))
    whiteBgSprite:setAnchorPoint(ccp(0.5,0))
    whiteBgSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,15))
    cellBgSprite:addChild(whiteBgSprite)
    
    -- local xiuxingLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_23"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    local xiuxingLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_23"),g_sFontPangWa,21)
    xiuxingLabel:setColor(ccc3(0x78,0x25,0x00))
    xiuxingLabel:setAnchorPoint(ccp(0,1))
    xiuxingLabel:setPosition(ccp(titleBgSprite:getContentSize().width+30,cellBgSprite:getContentSize().height-35))
    whiteBgSprite:addChild(xiuxingLabel)

    xiuxingStr = CCRenderLabel:create("+".._TableInfo[p_pos][3],g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    xiuxingStr:setColor(ccc3(0x00,0xff,0x18))
    xiuxingStr:setAnchorPoint(ccp(0,1))
    xiuxingStr:setPosition(ccp(xiuxingLabel:getContentSize().width + xiuxingLabel:getPositionX(),cellBgSprite:getContentSize().height-35))
    whiteBgSprite:addChild(xiuxingStr)

    --每一行的图片
    if(p_pos <= _cellNum )then    
        local icons = analyzeTabStr(_iconArray[p_pos])
        local count = table.count(icons[1])
        for i = 1,count do
            local iconBack = CCSprite:create("images/replaceskill/newflip/cardback.png")
            iconBack:setScale(0.6)
            local iconSprite = CCSprite:create(_eventPath..icons[1][i])
            iconSprite:setAnchorPoint(ccp(0.5,0.5))
            iconSprite:setScale(0.43)
            -- iconSprite:setPosition(ccp(97*i-30,40))
            iconSprite:setPosition(ccp(iconBack:getContentSize().width*0.5,iconBack:getContentSize().height*0.5))
            iconBack:addChild(iconSprite)
            iconBack:setAnchorPoint(ccp(0.5,0))
            iconBack:setPosition(ccp(97*i-30,40))
            whiteBgSprite:addChild(iconBack)
        end
    end
   
    -- if(p_pos < 9 )then
    --     require "script/model/utils/HeroUtil"
    --     local icons = analyzeTabStr(_iconArray[p_pos])
    --     local count = table.count(icons[1])
    --     for i = 1,count do
    --         local iconSprite = HeroUtil.getHeroIconByHTID(tostring(icons[1][i]),nil,nil,nil)
    --         iconSprite:setAnchorPoint(ccp(0.5,0))
    --         iconSprite:setPosition(ccp(97*i-30,40))
    --         whiteBgSprite:addChild(iconSprite)
    --     end
    -- end

    local requireLabel = CCLabelTTF:create(_TableInfo[p_pos][5],g_sFontPangWa,21,CCSizeMake(500,40),kCCTextAlignmentLeft)
    requireLabel:setAnchorPoint(ccp(0,0))
    requireLabel:setColor(ccc3(0x78,0x25,0x00))
    requireLabel:setPosition(ccp(50,0))
    whiteBgSprite:addChild(requireLabel)

    return tCell
end
