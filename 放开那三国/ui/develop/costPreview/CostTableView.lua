-- Filename：    CostTableView.lua
-- Author：      DJN
-- Date：        2015-7-27
-- Purpose：     进化消耗预览tableView

module ("CostTableView", package.seeall)

require "script/ui/item/ItemSprite"
require "script/ui/develop/costPreview/DevelopCostLayer"

local _countryInfo

--[[
    @des    :创建tableView
    @param  :相应国家的武将信息
    @return :创建好的tableView
--]]
function createTableView(p_countryInfo)
    _countryInfo = p_countryInfo

    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(580, 130)
        elseif fn == "cellAtIndex" then
            a2 = createCell((math.ceil(#_countryInfo/5) - 1 - a1)*5)
            r = a2
        elseif fn == "numberOfCells" then
            r = math.ceil(#_countryInfo/5)
        else
            print("other function")
        end

        return r
    end)

    return LuaTableView:createWithHandler(h, CCSizeMake(580,475))
end

--[[
    @des    :创建cell
    @param  :开始下标
    @return :创建好的cell
--]]
function createCell(p_beginIndex)
    local tCell = CCTableViewCell:create()
    local cellMenu = CCMenu:create()
    cellMenu:setContentSize(CCSizeMake(580, 130))
    cellMenu:setAnchorPoint(ccp(0,0))
    cellMenu:setPosition(ccp(0,0))
    cellMenu:setTouchPriority(CostPreviewLayer.getTouchPriority() - 5)
    tCell:addChild(cellMenu)

    for i = p_beginIndex + 1,p_beginIndex + 5 do
        if i <= #_countryInfo then
            local posX = 50 + 120*(i - p_beginIndex - 1)

            --武将头像
            --local headSprite = ItemSprite.getHeroIconItemByhtid(_countryInfo[i],-570)
            local headSprite = HeroUtil.getHeroIconByHTID(_countryInfo[i])
            local headItem = CCMenuItemSprite:create(headSprite,headSprite)
            headItem:setAnchorPoint(ccp(0.5,1))
            headItem:setPosition(ccp(posX,125))
            headItem:registerScriptTapHandler(heroCb)
            cellMenu:addChild(headItem,1,_countryInfo[i])

            --武将名字
            require "db/DB_Heroes"
            local heroInfo = DB_Heroes.getDataById(_countryInfo[i])
            local heroNameLabel = CCRenderLabel:create(heroInfo.name,g_sFontName,18,2,ccc3(0x00,0x00,0x00),type_stroke)
            heroNameLabel:setColor(ccc3(0xff,0x84,0x00))
            heroNameLabel:setAnchorPoint(ccp(0.5,0))
            heroNameLabel:setPosition(posX,5)
            tCell:addChild(heroNameLabel)
        end
    end

    return tCell
end
function heroCb( p_tag,p_item)
    DevelopCostLayer.showLayer(p_tag,CostPreviewLayer.getTouchPriority() - 30)
    -- body
end