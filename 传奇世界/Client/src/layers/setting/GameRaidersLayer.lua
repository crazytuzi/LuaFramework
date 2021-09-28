local GameRaidersLayer = class("GameRaidersLayer",require ("src/TabViewLayer"))

function GameRaidersLayer:ctor(parent)
    local leftBg = createSprite(self,"res/common/bg/buttonBg2.png", cc.p(12, 20), cc.p(0, 0))
    self.leftBg = leftBg
    local rightBg = createSprite(self,"res/common/bg/tableBg2.png", cc.p(208, 20), cc.p(0, 0))
    self.rightBg = rightBg
    self.selectIdx = 0
    self.titleTable = {}
    self.n = require("src/config/GameRaidersCfg")
    for k,v in pairs(self.n) do
        if v.q_Raidersheading then
            table.insert(self.titleTable,v.q_Raidersheading)
        end
    end
    self:createTableView(leftBg,cc.size(200,522),cc.p(0,8),true)
end

function GameRaidersLayer:cellSizeForTable(table,idx)
    return 68,104
end

function GameRaidersLayer:numberOfCellsInTableView(table)
    return tonumber(self.n[#self.n].q_id)
end

function GameRaidersLayer:tableCellTouched(table,cell)
    local index = cell:getIdx()
    local num = index + 1
    if self.selectIdx == index or not self:isVisible() then
        return 
    else
        AudioEnginer.playTouchPointEffect()
        local old_cell = table:cellAtIndex(self.selectIdx)
        if old_cell then
            local button = tolua.cast(old_cell:getChildByTag(10),"cc.Sprite")
            if button then
                button:setTexture("res/component/button/40.png")
                if button:getChildByTag(20) then
                    button:removeChildByTag(20)
                end
            end
        end
        local button = cell:getChildByTag(10)
        if button then
            button:setTexture("res/component/button/40_sel.png")
            local select_allow =  button:getChildByTag(20)
            if select_allow then
                select_allow:setPosition(cc.p(button:getContentSize().width, button:getContentSize().height/2))
            else
                local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
                arrow:setTag(20)
            end
            self:setTitleBck(num)
        end
    end
    self.selectIdx = index

end

function GameRaidersLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local button = createSprite(cell,"res/component/button/40.png",cc.p(95,35))
    createLabel(button,self.titleTable[idx+1],cc.p(button:getContentSize().width/2,button:getContentSize().height/2),nil,22,true,nil,nil,MColor.lable_yellow)
    if button then
        button:setTag(10)
        if idx == self.selectIdx then
            button:setTexture("res/component/button/40_sel.png")
            local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
            arrow:setTag(20)
            self:setTitleBck(idx+1)
        end
    end
    return cell
end

function GameRaidersLayer:setTitleBck( num )
    local GameRaiders = function(num)
        if self.layerMan == nil then
            self.layerMan = require("src/layers/setting/GameRaidersTxt").new(num)
            self:addChild(self.layerMan)
        else
            self.layerMan:createLayout(num)
        end
    end
    GameRaiders(num)
end

return GameRaidersLayer