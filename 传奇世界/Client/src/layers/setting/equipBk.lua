local equipBk = class("equipBk",require ("src/TabViewLayer"))

function equipBk:ctor(parent)
    local bg = createBgSprite(self,game.getStrByKey("equipBook"))
    local leftBg = createSprite(bg,"res/common/bg/buttonBg3.png",cc.p(70,290))
    self.leftBg = leftBg
    local rightBg = createSprite(bg,"res/common/bg/bg12.png",cc.p(540,290))
    local downBg = createSprite(bg,"res/common/bg/bg12-2.png",cc.p(540,65))
    createLabel(downBg,game.getStrByKey("weaponTip"),cc.p(downBg:getContentSize().width/2,downBg:getContentSize().height/2-10),nil,24,true,nil,nil,MColor.lable_black)
    -- createSprite(self,"res/common/bg/bg12-3.png",cc.p(543,530))
    -- createSprite(self,"res/common/bg/bg12-3.png",cc.p(543,310))
    self.rightBg = rightBg
    self.selectIdx = 0
    self.equipNum = {1,5,7,3,2,6,8,4}
    self.num = 1
    self.equipKind = nil
    self.layerMan = {}
    self.layerMan1 = {}
    self.tempForOld = 1
    self.sex = MRoleStruct:getAttr(PLAYER_SEX)
    -- self.equipHad = ""
    self.school = MRoleStruct:getAttr(ROLE_SCHOOL)

    self.myShop = {"weapon","clothing1","helmet","necklace","goldRing","cuff","belt","shoe1"}
    self:createTableView(leftBg,cc.size(125,522),cc.p(0,7),true)
end

function equipBk:cellSizeForTable(table,idx)
    return 68,104
end

function equipBk:numberOfCellsInTableView(table)
    return #self.myShop
end

function equipBk:tableCellTouched(table,cell)
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
                button:setTexture("res/component/button/43.png")
                if button:getChildByTag(20) then
                    button:removeChildByTag(20)
                end
            end
        end
        local button = cell:getChildByTag(10)
        if button then
            button:setTexture("res/component/button/43_sel.png")
            local select_allow =  button:getChildByTag(20)
            if select_allow then
                select_allow:setPosition(cc.p(button:getContentSize().width, button:getContentSize().height/2))
            else
                local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
                arrow:setTag(20)
            end
            self.num = num
            -- g_msgHandlerInst:sendNetDataByFmtExEx(GAMECONFIG_CS_GETEQUIPMAP, "ic", G_ROLE_MAIN.obj_id,tostring(self.equipNum[self.num]))
            local callback = function()
                if self.equipKind == nil then
                    self:setTitleEqu(num ,self.equipNum[self.num])
                end
            end
            startTimerAction(self, 0.3, false, callback)
        end
    end

    self.selectIdx = index

end

function equipBk:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local button = createSprite(cell,"res/component/button/43.png",cc.p(60,35))
    createLabel(button,game.getStrByKey(self.myShop[idx+1]),cc.p(button:getContentSize().width/2,button:getContentSize().height/2),nil,22,nil,nil,nil,MColor.lable_yellow)
    if button then
        button:setTag(10)
        if idx == self.selectIdx then
            button:setTexture("res/component/button/43_sel.png")
            local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
            arrow:setTag(20)
            local callback = function()
                if self.equipKind == nil then
                    self:setTitleEqu(1 ,1)
                end
            end
            startTimerAction(self, 0.0, false, callback)
        end
    end
    return cell
end

function equipBk:setTitleEqu(num,equipNum)
    local equipBkFun = function(num)
        if self.layerMan[self.tempForOld] then
            self.layerMan[self.tempForOld]:setVisible(false)
        end
        -- if self.layerMan1[self.tempForOld] then
        --     self.layerMan1[self.tempForOld]:setVisible(false)
        -- end
        if self.layerMan[num] == nil then
            self.layerMan[num] = require("src/layers/setting/equipBkLayer").new(equipNum,self.school,self.sex,game.getStrByKey(self.myShop[num]))
            self.rightBg:addChild(self.layerMan[num])
        else
            self.layerMan[num]:setVisible(true)
        end
        -- if self.layerMan1[num] == nil then
        --     self.layerMan1[num] = require("src/layers/setting/equipBkLayer").new(equipNum,self.school,self.sex,2,game.getStrByKey(self.myShop[num]))
        --     self:addChild(self.layerMan1[num])
        -- else
        --     self.layerMan1[num]:setVisible(true)
        -- end
        self.tempForOld = num
    end
    equipBkFun(num)
    
end

-- function equipBk:networkHander(buff,msgid)
--     local switch = {
--         [GAMECONFIG_SC_GETEQUIPMAP_RET] = function()
--             if buff then
--                 self.equipKind = buff:popChar()
--                 self.equipHad = buff:popString()
--                 self:setTitleEqu(self.num,self.equipNum[self.num])
--             end
--         end
--         ,
--     }
--     if switch[msgid] then 
--         switch[msgid]()
--     end
-- end

return equipBk