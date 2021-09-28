 --[[
 --
 -- @authors shan 
 -- @date    2014-05-22 14:56:33
 -- @version 
 --
 --]]

 --

local HeroSellBoard = class("HeroSellBoard", function (setBgVisible,typeIndex)
    
	return display.newNode()
end)

function HeroSellBoard:SendReq( ... )
    RequestHelper.getHeroList({
                callback = function(listData)
                    self:init(listData)
                end})
end

function HeroSellBoard:init(data)
    local rawlist = data["1"]
    dump(rawlist)
    local list = {}
    --过滤一下 将可以出售的留下
    for i = 1, #rawlist do         
        local stars = rawlist[i]["star"]       
        if stars < 5 and i ~= 1 then 
            list[#list + 1 ] = rawlist[i]
        end
    end
    --用这个table 保存选中的列表
    self.sellTable  = {}


    -- bg   
    local boardBg = require("utility.BaseBoard").new()
    local boardWidth = boardBg:getContentSize().width
    local boardHeight =boardBg:getContentSize().height

    boardBg:setPosition(display.width/2, display.height*0.45)
    self:addChild(boardBg)

    local choiceDetailNode = display.newNode()
    choiceDetailNode:setPosition(boardWidth*-0.17,boardHeight*-0.13)
    self:addChild(choiceDetailNode)

    local choiceDetailBg = display.newSprite("#submap_text_bg.png", x, y)
    choiceDetailBg:setPosition(boardWidth*0.6,boardHeight*0.4)
    choiceDetailBg:setScaleX(1.2)
    choiceDetailNode:addChild(choiceDetailBg)

     self.updateBoard = nil 

     local zongjiLable = ui.newTTFLabel({
        text = "总计出售:",
        size = 18,
        color = FONT_COLOR.LIGHT_ORANGE
        })
    zongjiLable:setPosition(choiceDetailBg:getPositionX(),choiceDetailBg:getPositionY())
    choiceDetailNode:addChild(zongjiLable)

    local yinbiLable = ui.newTTFLabel({
        text = "银币",
        size = 18,
        })
    yinbiLable:setPosition(zongjiLable:getPositionX()+zongjiLable:getContentSize().width*0.75 , choiceDetailBg:getPositionY())
    choiceDetailNode:addChild(yinbiLable)

    local priceNum = ui.newTTFLabel({
        text = 0,
        size = 18,
        color = FONT_COLOR.ORANGE
        })
    priceNum:setAnchorPoint(ccp(0, 0.5))
    priceNum:setPosition(yinbiLable:getPositionX()+yinbiLable:getContentSize().width*0.75,choiceDetailBg:getPositionY())
    choiceDetailNode:addChild(priceNum)

    local sellEquipMoney = 0
    function changeSoldMoney(num)
        if sellEquipMoney+num >= 0 then 
            sellEquipMoney = sellEquipMoney + num
            priceNum:setString(sellEquipMoney)
        end
    end

   

    local sellFont = ui.newBMFontLabel({
        text = "出 售",
        font = "fonts/font_buttons.fnt",
        })
    sellFont:setScale(0.6)


    local chushouBtn = require("utility.CommonButton").new({
        img = "#com_btn_red.png",
        font = sellFont,
        listener = function ( ... )
            local sellStr = ""
            for i =1,#self.sellTable do 
                if #sellStr ~= 0 then
                    sellStr = sellStr..","..self.sellTable[i]
                else
                    sellStr = sellStr..self.sellTable[i]
                end
            end
            

            RequestHelper.sendSellCardRes({
                callback = function(data) 
                    self.updateBoard()
                end,
                ids = sellStr
                })
            
        end
        })
    chushouBtn:setPosition(choiceDetailBg:getPositionX()+choiceDetailBg:getContentSize().width*0.6, choiceDetailBg:getPositionY() + boardHeight*-0.055)
    choiceDetailNode:addChild(chushouBtn)


    local scrollLayerNode = display.newNode()
    boardBg:addChild(scrollLayerNode)

    local  function addSellItemFunc(itemId)
        
        self.sellTable[#self.sellTable + 1] = itemId
        
    end

    local function removeSellItemFunc(itemId)
       
        for i = 1,#self.sellTable do 
            if self.sellTable[i] == itemId then
                table.remove(self.sellTable,i)
            end
        end
        
    end

     local function refreshList()
        --出售成功之后，将在出售列表中的item 从list中移除
        local removeList ={}
        for i = 1,#list do 
            for j = 1,#self.sellTable do 
                if list[i]["_id"] == self.sellTable[j] then
                    removeList[#removeList + 1] = i
                end
            end
        end

        for i =1,#removeList do
            table.remove(list,removeList[i])
        end               

    end
    

    local function updateList()
        
        scrollLayerNode:removeAllChildren()
        local function createFunc(idx)
            
            local item = require("game.Hero.HeroSellCell").new()
            return item:create({
                id       = idx,
                viewSize = CCSizeMake(boardBg:getContentSize().width, boardBg:getContentSize().height*0.95),
                listData = list,
                changeSoldMoney = changeSoldMoney,
                addSellItem = addSellItemFunc,
                removeSellItem = removeSellItemFunc                
                
            })
        end

        local function refreshFunc(cell, idx)
            cell:refresh(idx)
        end
       

        local itemList = require("utility.TableViewExt").new({
            size        = CCSizeMake(boardBg:getContentSize().width, boardBg:getContentSize().height*0.84),-- numBg:getContentSize().height - 20),
            direction   = kCCScrollViewDirectionVertical,
            createFunc  = createFunc,
            refreshFunc = refreshFunc,
            cellNum     = #list,
            cellSize    = require("game.Hero.HeroSellCell").new():getContentSize()
        })
        itemList:setPosition(-boardBg:getContentSize().width *0.49, -boardBg:getContentSize().height *0.37)-- numBg:getContentSize().height)
        scrollLayerNode:addChild(itemList)
    end

    updateList()
      

    function choseHeroByStars(starTable)
     for i =1 ,#starTable do
         if starTable[i] == 1 then
             for equipId = 1,#list do 
                 -- print("sta num"..heroes[heroID]:getStarNum())
                 if list[equipId]["star"] == i then 
                    list[equipId]["sel"] = true
                      
                 end 
             end

         end
     end
    updateList()

    end

    local sellByStarFont = ui.newBMFontLabel({
        text = "按星级出售",
        font = "fonts/font_buttons.fnt",
        })
    sellByStarFont:setScale(0.5)

    local sellByStars = require("utility.CommonButton").new({
    img = "#com_btn_large_red.png",
    font = sellByStarFont,
    listener = function ( ... )
        local sellByStarBoard = require("game.SellHeroSoul.ChoseStarLvlLayer").new({
            selStarsListener = choseHeroByStars})
        sellByStarBoard:setPosition(display.width/2, display.height*0.45)
        self:addChild(sellByStarBoard)
        
    end
    })
    sellByStars:setPosition(boardWidth*0.05, boardHeight*0.48)
    boardBg:addChild(sellByStars)


    -- local heroScrollLayer = require("app.ui.CScrollLayer").new({
    --         x = display.width*-0.25 ,
    --         y = -(boardBg:getPositionY() - boardBg:getContentSize().height*0.91/2) + nodes[1]:getContentSize().height*0.37-5,
    --         width = display.width ,
    --         height = boardBg:getContentSize().height *0.81 ,
    --         pageSize = 5,

    --         rowSize = 1,
    --         nodes = nodes,            
    --         bVertical = true,
            
        -- })
    
    
    
    
    
    -- back
    local backBtn = require("utility.CommonButton").new({
        img = "#f_win_back.png",
        listener = function ( ... )
            
            -- self.setBgVisible()
            self:removeSelf()
        end
        })
    backBtn:setPosition(boardBg:getContentSize().width*0.3,boardBg:getContentSize().height/2 - backBtn:getContentSize().height/5)
    boardBg:addChild(backBtn)

    self.updateBoard = function()
        refreshList()
        updateList()
    end

end


function HeroSellBoard:ctor(setBgVisible,typeIndex)

	self:setNodeEventEnabled(true)
    -- self.setBgVisible = setBgVisible
    --用typeIndex来判断当前是出售装备还是出售碎片
    self.typeIndex = typeIndex

	display.addSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")

	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
    self:SendReq()

end




function HeroSellBoard:onExit()
	-- body
	-- display.removeSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")

end

return HeroSellBoard