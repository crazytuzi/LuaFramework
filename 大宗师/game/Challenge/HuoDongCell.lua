 local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")
 local data_item_item =  require("data.data_item_item")


local HuoDongCell = class("HuoDongCell", function ()
    return CCTableViewCell:new()    
end)


function HuoDongCell:getContentSize()
    -- local sprite = display.newSprite("#herolist_board.png")
    return CCSizeMake(display.width, 200) --sprite:getContentSize()
end


function HuoDongCell:getIsAllowPlay()
    return self.isAllowPlay
end


function HuoDongCell:getOpenCnt()
    return self.openCnt
end


function HuoDongCell:refresh(aid)
    local actId = aid 
    local huodongData = data_huodongfuben_huodongfuben[actId] 

    local name = data_huodongfuben_huodongfuben[actId]["icon"]
    local imagePath = "ui/ui_huodong_fb/" .. name .. ".png"
    local imageCoverName = "ui/ui_huodong/ui_huodong_cover.png"
    local imageCoverNameGray = "ui/ui_huodong/ui_huodong_cover_gray.png"

    self.openCnt = self.fubenTimes[tostring(actId)].openCnt 

    self.isAllowPlay = true 

    if actId == 1 then 
        -- self.isAllowPlay = false 
        local limit_lv  = huodongData["prebattle"] 
        if limit_lv ~= nil and limit_lv > game.player.getLevel() then 
            self.isAllowPlay = false 
        end  
    else
        if self.openCnt > 0 then 
            self.isAllowPlay = true 
        else
            self.isAllowPlay = false 
        end 
    end 

    if(self.isAllowPlay) then
        item = display.newSprite(imagePath)
        itemCover = display.newScale9Sprite(imageCoverName, 0, 0, CCSize(item:getContentSize().width+20, item:getContentSize().height+20) )
    else
        item = display.newGraySprite(imagePath, {0.4, 0.4, 0.4, 0.1}) 
        itemCover = display.newScale9Sprite(imageCoverNameGray, 0, 0, CCSize(item:getContentSize().width+20, item:getContentSize().height+20) )
    end
    item:setPosition(self._rootnode["bg_node"]:getContentSize().width/2,self._rootnode["bg_node"]:getContentSize().height/2)
    itemCover:setPosition(self._rootnode["bg_node"]:getContentSize().width/2,self._rootnode["bg_node"]:getContentSize().height/2)
    self._rootnode["bg_node"]:removeAllChildren()
    self._rootnode["bg_node"]:addChild(item) 
    self._rootnode["bg_node"]:addChild(itemCover) 
    
    local color = ccc3(255, 255, 255)
    if self.isAllowPlay then 
        color = ccc3(0, 255, 0)
    end

    if self.isAllowPlay == true then 
        local leftCntLbl = self._rootnode["leftCnt_Lbl"]
        leftCntLbl:removeAllChildren()

        -- 今日剩余次数
        local actTimes = self.fubenTimes[tostring(actId)].surplusCnt 

        local numLbl = ui.newTTFLabelWithOutline({
            text = "今日剩余次数：" .. tostring(actTimes),
            size = 22,
            color = color, 
            outlineColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
            })
        numLbl:setPosition(-numLbl:getContentSize().width-30, numLbl:getContentSize().height/2)
        leftCntLbl:addChild(numLbl)

        if huodongData.isbuy == 1 then 
            local plusBtn  = ui.newImageMenuItem({
                image = "#plus_btn.png",
                imageSelected = "#plus_btn.png",
                listener = function ()
                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
                   if actTimes > 0 then
                        ResMgr.showMsg(6)
                   else
                       local buyMsgBox = require("game.Challenge.HuoDongBuyMsgBox").new({aid = actId,removeListener = self.refreshFunc})
                       display.getRunningScene():addChild(buyMsgBox,1000)
                   end
                end
                })
            plusBtn:setScale(0.8)
            plusBtn:setPosition(plusBtn:getContentSize().width/2-30, numLbl:getContentSize().height/2) 
            leftCntLbl:addChild(ui.newMenu({plusBtn}))
        end 

        local itemID = HuoDongFuBenModel.getItemID(actId)
        local itemNum = HuoDongFuBenModel.getItemNum(actId) 

        if itemID ~= 0  then
            local rowTable = {}
            local nameColor = NAME_COLOR[5]

            local useStr = ResMgr.createShadowMsgTTF({text = "可使用",color = ccc3(0, 255, 0)}) --可使用
            rowTable[#rowTable + 1] = useStr
            local itemData = data_item_item[itemID] 
            local itemColor = NAME_COLOR[itemData.quality]
            local itemStr = ResMgr.createShadowMsgTTF({text = itemData.name,color = itemColor}) --解负令
            rowTable[#rowTable + 1] = itemStr
            local itemIcon = display.newSprite("#jiefuling.png")
            rowTable[#rowTable + 1] = itemIcon
            local chaStr = ResMgr.createShadowMsgTTF({text = "挑战(拥有:"..itemNum..")",color = ccc3(0, 255, 0)}) --可使用
            rowTable[#rowTable + 1] = chaStr

            local jiefuDescNode = ResMgr.getArrangedNode(rowTable)

            jiefuDescNode:setPosition(-jiefuDescNode.rowWidth,-39)
            leftCntLbl:addChild(jiefuDescNode)    
        end 
    end 
   
    local desc
    if  huodongData.index ~= nil then
            desc = ui.newTTFLabelWithOutline({
            text = tostring(huodongData.index),
            size = 26,
            color = color, 
            outlineColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
            })
        desc:setPosition(item:getContentSize().width/2-desc:getContentSize().width/2, item:getContentSize().height/2)
        item:addChild(desc)
    end 
end


function HuoDongCell:create(param)
    self.refreshFunc = param.refreshFunc 
    self.fubenTimes = param.fubenTimes
    local aid = param.aid 

    local proxy = CCBProxy:create()
    self._rootnode = {} 
    local node = CCBuilderReaderLoad("challenge/jingying_item.ccbi", proxy, self._rootnode)
    self:addChild(node)

    self:refresh(aid) 

    return self 
end



return HuoDongCell
