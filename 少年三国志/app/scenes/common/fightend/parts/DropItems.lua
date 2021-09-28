
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local FightEndItemCell = require "app.scenes.common.fightend.controls.FightEndItemCell"

local DropItems = class ("DropItems", function() return display.newNode() end)



function DropItems:ctor( awards, endCallback)
   
    self:setNodeEventEnabled(true)

    self._endCallback = endCallback

    self._awards = awards

    self._boxes = {}

    self._playBoxIndex = 1      --正在开哪个箱子
    self._playBoxCardLines = 0 -- 发牌发在第几行


    self._cardsLayer = display.newNode()
    self._cardsLayer:setPositionX(-235)
    self._cardsLayer:setPositionY(60)

    self:addChild(self._cardsLayer)


    --一共有几种类型的箱子? 进行分类

    -- 筛选物品品质
    local list = {gold = {}, silver ={}, cu ={}}
 
    --按照物品类型分
    -- 侠客 装备,其他
    for k,v in pairs(awards) do
        local data = G_Goods.convert(v.type, v.value)
        if data then
            data.size = v.size
            local type = data.type

            if type ==G_Goods.TYPE_KNIGHT then
                --侠客
                table.insert(list.gold,data)
            elseif type ==G_Goods.TYPE_EQUIPMENT then
                --装备    
                table.insert(list.silver,data)
            
            elseif type ==G_Goods.TYPE_FRAGMENT then
                --侠客|装备碎片
                local goods = fragment_info.get(v.value)
                if goods.fragment_type == 1 then
                    --侠客碎片
                   table.insert(list.gold,data)
                else
                    --装备碎片
                    table.insert(list.silver,data)
                end
            else 
                table.insert(list.cu,data)
            end

        end
    end


    self._list = list

    self._boxTypes = 0

    if #(list.cu) > 0 then
        self._boxTypes = self._boxTypes + 1
    end

    if #(list.silver)> 0 then
        self._boxTypes = self._boxTypes +1
    end

    if #(list.gold)> 0 then
        self._boxTypes = self._boxTypes +1
    end


end

function DropItems:play()
    --先展示出现动画
    self._node = EffectMovingNode.new("moving_fightend1_drop_items", 
        function(key)
            if key == "box1" or key == "box2" or key == "box3" then
                --从gold silver, cu中选一个, 选过的记得删掉
                local boxType, typeList
                local ks ={"gold", "silver", "cu"}
                for i,k in ipairs(ks) do
                    if self._list[k] and #self._list[k] > 0  then
                        boxType = k
                        typeList = self._list[k]
                        self._list[k] = nil
                        break
                    end

                end
         
                
                local box = require("app.scenes.common.fightend.controls.BoxNode").new(boxType, typeList, handler(self, self._onBoxOpen))
                table.insert(self._boxes, box)    
                return box 
                  
            elseif key == "title" then
                local bg =  CCSprite:create(G_Path.getFightEndDir() .. "jiesuan_title.png")    
                local title =  CCSprite:create(G_Path.getTextPath("title_diaoluojiangli.png") )  
                local size = bg:getContentSize()  
                title:setPosition(ccp(size.width/2, size.height/2))
                bg:addChild(title)
                return bg

            end        
        end,
        function(event)
            if event == "box1" and self._boxTypes == 1 then
                --停止
                print("stop box1")
                self:_finishAppearBoxes()
            elseif event == "box2" and self._boxTypes == 2 then
                print("stop box2")

                self:_finishAppearBoxes()
            elseif event == "box3"  then
                print("stop box3")

                self:_finishAppearBoxes()
            end   
        end
    )


    self:addChild(self._node)
    self._node:play()

end

function DropItems:_finishAppearBoxes()
    self._node:pause()

    --开始逐个宝箱播放动画

    self._playBoxIndex = 1

    self:_playNextBox()

end

function DropItems:_playNextBox()
    local box = self._boxes[self._playBoxIndex]
    
    if box == nil then
        self:_end()
        return
    end

    --继续播放抖动动画
    box:play()

    --等到宝箱打开的时候开始发牌, 会收到回调_onBoxOpen


end

function DropItems:_onBoxOpen()


    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BOX_OPEN)
    
    local box = self._boxes[self._playBoxIndex]
    local boxType = box:getType()
    local list = box:getItemList()

    
    --开始发牌, 
    local timer 
    local listIndex = 1
    timer = GlobalFunc.addTimer(0.1, function() 
        if listIndex > #list then
            GlobalFunc.removeTimer(timer)
            self:_onFinishFapai(box)
        else
            local card = list[listIndex]
            local cell = FightEndItemCell.new()
            cell:updateData(card.icon, card.quality, card.size,card.type)

            --计算box的世界坐标, 然后再转成 self._cardsLayer 的本地坐标
            local boxWorldPosition = box:convertToWorldSpace(ccp(0, 0))
            -- print(boxWorldPosition.x)
            -- print(boxWorldPosition.y)
            local boxPosition = self._cardsLayer:convertToNodeSpace(  boxWorldPosition  )

            local lineHeight = 95
            local cellGap = 95


            local mx = cellGap*((listIndex-1) % 6)
            local my = -self._playBoxCardLines * lineHeight 
            -- print(boxPosition.x)
            -- print(boxPosition.y)
            cell:setScale(0.01)
            cell:setOpacity(0)            
            cell:setPosition(boxPosition)
            cell:setRotation(-90)
            --修改层级
            self._cardsLayer:addChild(cell,#list-listIndex)

            transition.scaleTo(cell, {scale=1, time=0.1})
            transition.fadeIn(cell, { time=0.1})
            transition.moveTo(cell, {x=mx, y=my,  time=0.1})
            transition.rotateTo(cell, {rotate=0,  time=0.1})


            
            if listIndex > 1 and listIndex % 6 ==0 then
                self._playBoxCardLines = self._playBoxCardLines + 1
            end

            listIndex = listIndex + 1
        end


    end)


end

function DropItems:_onFinishFapai(box)
    self._playBoxCardLines = self._playBoxCardLines + 1
    --box:removeEffect()
    self._playBoxIndex = self._playBoxIndex + 1
    self:_playNextBox()
end

function DropItems:_end()
    
    if self._endCallback ~= nil then
        self._endCallback()
        self._endCallback  = nil
    end
    
end

function DropItems:onExit()
    self:setNodeEventEnabled(false)
    if  self._node then
        self._node:stop()
    end
    
end

return DropItems