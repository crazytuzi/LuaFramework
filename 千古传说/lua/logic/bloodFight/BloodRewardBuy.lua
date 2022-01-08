
local BloodRewardBuy = class("BloodRewardBuy", BaseLayer)

function BloodRewardBuy:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.bloodybattle.BloodybattleAwardBuy")
end

function BloodRewardBuy:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_close1     = TFDirector:getChildByPath(ui, 'btn_close1')

    self.img_title      = TFDirector:getChildByPath(ui, 'img_title')

    self.txt_tip1       = TFDirector:getChildByPath(ui, 'txt_tip1')

    self.ItemList = {}
    for i=1,3 do
        -- img_award
        self.ItemList[i] = {}
        self.ItemList[i].node         = TFDirector:getChildByPath(ui, "img_award"..i)
        self.ItemList[i].img_quality  = TFDirector:getChildByPath(ui, "img_quality"..i)
        self.ItemList[i].img_goods    = TFDirector:getChildByPath(ui, "img_goods"..i)
        self.ItemList[i].img_goods_pos = self.ItemList[i].img_goods:getPosition();
        self.ItemList[i].txt_num      = TFDirector:getChildByPath(ui, "txt_num"..i)
        self.ItemList[i].img_gold      = TFDirector:getChildByPath(ui, "img_gold"..i)
        self.ItemList[i].txt_Cost      = TFDirector:getChildByPath(ui, "txt_cost"..i)
        self.ItemList[i].btn_buy      = TFDirector:getChildByPath(ui, "btn_buy"..i)

        self.ItemList[i].img_own      = TFDirector:getChildByPath(ui, "img_own"..i)
        
        self.ItemList[i].btn_buy.logic = self
        self.ItemList[i].btn_buy.index = i
        self.ItemList[i].btn_buy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onlickBuyBox))
        
        self.ItemList[i].node:setVisible(false)
        self.ItemList[i].node.index = i
        self.ItemList[i].node.logic = self
        self.ItemList[i].node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onlickchooseBox))

        self.ItemList[i].img_goods.index = i
        self.ItemList[i].img_goods.logic = self
        self.ItemList[i].img_goods:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onlickPrize))

    end

    self.img_totalgold       = TFDirector:getChildByPath(ui, 'img_totalgold')
    self.txt_totalgold       = TFDirector:getChildByPath(ui, 'txt_totalcost')
    self.btn_get             = TFDirector:getChildByPath(ui, 'btn_get')
    self.btn_get.logic       = self
    self.btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onlickBuyOtherTwoBox))

    self.timeResultId = {}
end

function BloodRewardBuy:registerEvents(ui)
    self.super.registerEvents(self)
    
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close1);

    self.updateBox = function(event)
        if event.data[1].index == self.boxIndex then
            print("event.data[1] = ", event.data[1])
            local boxIndex      = event.data[1].index
            local prizeIndex    = event.data[1].prizeIndex
            -- 获取类型(1-免费领取，2-购买)
            if event.data[1].getType == 1 then
                self.ItemList[prizeIndex].node:setVisible(false)
                self:playEffect(prizeIndex)

                -- 更新宝箱数据
                self.boxData = BloodFightManager:getBox(self.boxIndex).data

            -- 购买
            elseif event.data[1].getType == 2 then
                -- self:showPrizeResult(prizeIndex)
                self.btn_close1:setVisible(true)
                -- self:showOtherTwoPrizeResult()
                -- 更新宝箱数据
                self.boxData = BloodFightManager:getBox(self.boxIndex).data
                -- self:refreshUI()

                -- AlertManager:close()
            end

        end
    end

    TFDirector:addMEGlobalListener(BloodFightManager.MSG_UPDATE_BOX ,self.updateBox);
   

end

function BloodRewardBuy:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_UPDATE_BOX,self.updateBox )

    -- 停掉定时器
    if self.timeResultId then
        for i=1,4 do
            if self.timeResultId[index] and self.timeResultId[index].timeId then
                -- me.Director:getScheduler():unscheduleScriptEntry(self.timeResultId[index].timeId)
                TFDirector:removeTimer(self.timeResultId[index].timeId)
                self.timeResultId[index].timeId = nil
            end
        end
    end

    if self.timeId then
        -- me.Director:getScheduler():unscheduleScriptEntry(self.timeId)
        TFDirector:removeTimer(self.timeId)
        self.timeId = nil
    end

end

function BloodRewardBuy.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function BloodRewardBuy:loadBoxData(boxIndex, data, costType, cost)
    self.boxData    = data
    self.boxIndex   = boxIndex
    self.costType   = costType
    self.cost       = cost
end

function BloodRewardBuy:onShow()

    self.super.onShow(self)
    
    self.bIsGotBefore = false -- 之前没有领过奖

    local function checkNewStatus()
        for i=1,3 do
            local data = self.boxData[i]

            if data.isGet and data.isGet == true then
                self.bIsGotBefore = true
                return
            end
        end
    end

    checkNewStatus()
    self:refreshUI()
end

function BloodRewardBuy:refreshUI()

    local function getRewardInfo(rewardId)
        local rewardList = RewardConfigureData:GetRewardItemListById(rewardId);
        
        return rewardList:getObjectAt(1)
    end

    for i=1,3 do
        self.ItemList[i].img_goods:setPosition(self.ItemList[i].img_goods_pos)
    end

    if self.bIsGotBefore == false then
        for i=1,3 do
            local data = self.boxData[i]
            self.ItemList[i].node:setVisible(true)
            self.ItemList[i].btn_buy:setVisible(false)
            self.ItemList[i].img_gold:setVisible(false)
            self.ItemList[i].txt_Cost:setVisible(false)

            self.ItemList[i].img_quality:setVisible(false)
            -- self.ItemList[i].img_goods:setVisible(false)
            self.ItemList[i].txt_num:setVisible(false)

            self.ItemList[i].img_goods:setVisible(true)
            self.ItemList[i].img_goods:setTexture("ui_new/bloodybattle/xz_kapai1.png")
            self.ItemList[i].img_goods:setPosition(self.ItemList[i].img_goods_pos - ccp(0, 20))
        

            self.ItemList[i].img_own:setVisible(data.isGet)
        end

        -- -- 标题特效
        -- self.img_title:setVisible(false)
        -- self:playTitleEffect(self.img_title)
        self.txt_tip1:setText(localizable.bloodRewardBuy_next_box)

        self.img_totalgold:setVisible(false)
        self.btn_get:setVisible(false)
        self.closeBtn:setVisible(false)
        return
    end
    
    self.txt_tip1:setText(localizable.bloodRewardBuy_get_box_tips)
    if self.boxData == nil then
        return
    end

    local nPrizeGotNum = 0 --已获取奖品的个数
    for i=1,3 do
        local data = self.boxData[i]
        self.ItemList[i].node:setVisible(true)
        self.ItemList[i].btn_buy:setVisible(not data.isGet)
        self.ItemList[i].img_gold:setVisible(not data.isGet)
        self.ItemList[i].txt_Cost:setVisible(not data.isGet)

        self.ItemList[i].img_quality:setVisible(true)
        self.ItemList[i].img_goods:setVisible(true)
        self.ItemList[i].txt_num:setVisible(true)

   
        -- local boxInfo = data
        local img_goodsIcon     = self.ItemList[i].img_goods
        local txt_num           = self.ItemList[i].txt_num
        local img_itemBg        = self.ItemList[i].img_quality
        local img_gold          = self.ItemList[i].img_gold
        local txt_cost          = self.ItemList[i].txt_Cost

        local needResType       = data.needResType    --购买需要的资源类型
        txt_cost:setText(data.needResNum)

        -- 判断资源是否足够刷新
        if needResType == EnumDropType.COIN then
            img_gold:setTexture("ui_new/common/yuanbao1.png")
        elseif needResType == EnumDropType.SYCEE then 
            img_gold:setTexture("ui_new/common/yuanbao1.png")
        end

        -- local needResType  = data.needResType    --购买需要的资源类型

        -- local boxInfo = getRewardInfo(self.boxData[i].id)
        -- local itemInfo = boxInfo

        local itemInfo  = BaseDataManager:getReward(self.boxData[i])
        local boxInfo   = itemInfo

        if boxInfo.type == EnumDropType.ROLE then
            local role      = RoleData:objectByID(itemInfo.itemId)
            local headIcon  = role:getIconPath()
            img_goodsIcon:setTexture(headIcon)
        else
            img_goodsIcon:setTexture(itemInfo.path)
        end
        -- 
     -- lbl_goodsName:setText(itemInfo.name)
        local path = GetColorIconByQuality(itemInfo.quality)
       
        if boxInfo.type == EnumDropType.GOODS then
            local itemDetail = ItemData:objectByID(itemInfo.itemId)
            if itemDetail ~= nil and itemDetail.type == EnumGameItemType.Piece then
                path =  GetBackgroundForFragmentByQuality(itemInfo.quality)
                print("我是碎片")
            else
                path =  GetColorIconByQuality(itemInfo.quality)
            end
        end

        txt_num:setText(string.format("%d", boxInfo.number))
        img_itemBg:setTexture(path)

        Public:addPieceImg(img_goodsIcon,{type = boxInfo.type, itemid = boxInfo.itemId or boxInfo.itemid})
    
        -- 隐藏卡牌里面的按钮和价格
        self.ItemList[i].img_own:setVisible(data.isGet)
        img_gold:setVisible(false)
        self.ItemList[i].btn_buy:setVisible(false)

        if data.isGet then
            nPrizeGotNum = nPrizeGotNum + 1
        end
    end 

    local bShowBuyBtn = false
    if nPrizeGotNum < 3 then
        bShowBuyBtn = true
    end
    self.img_totalgold:setVisible(bShowBuyBtn)
    self.btn_get:setVisible(bShowBuyBtn)
    self.closeBtn:setVisible(bShowBuyBtn)
    self.txt_totalgold:setText(self.cost)
end

function BloodRewardBuy.onlickchooseBox(sender)
    local prizeIndex = sender.index
    local self       = sender.logic
   
    if sender:isVisible() == false then
        return
    end

    if self.bIsGotBefore == false and self.effectNode == nil then

        BloodFightManager:choose(self.boxIndex, prizeIndex)
        -- self.ItemList[prizeIndex].node:setVisible(false)
        -- self:playEffect(prizeIndex)
    end
end

function BloodRewardBuy.onlickBuyBox(sender)
    local prizeIndex = sender.index
    local self = sender.logic

    local data = self.boxData[prizeIndex]
    local needResType   = data.needResType  --购买需要的资源类型
    local num           = data.needResNum   --购买需要的资源数量

    -- 判断资源是否足够刷新
    if needResType == EnumDropType.COIN then 
        if MainPlayer:isEnoughCoin(num, true) then
            BloodFightManager:buyBox(self.boxIndex, prizeIndex)
        end
    end

    if needResType == EnumDropType.SYCEE then 
        if MainPlayer:isEnoughSycee(num, true) then
            BloodFightManager:buyBox(self.boxIndex, prizeIndex)
        end
    end
end

function BloodRewardBuy:playEffect(prizeIndex)
    if self.ChooseEffect == nil then
        local resPath = "effect/bloodfight2.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("bloodfight2_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)

        local node1          = self.ItemList[prizeIndex].node
        local nodeParent1    = node1:getParent()
        nodeParent1:addChild(effect,3)
        effect:setPosition(node1:getPosition())

        effect:setAnchorPoint(ccp(0.5, 0.5))
        self.ChooseEffect = effect
    end
    local node          = self.ItemList[prizeIndex].node
    local nodeParent    = node:getParent()
    local pos = node:getPosition()
    self.ChooseEffect:setPosition(ccp(pos.x + 438, pos.y + 245))
    self.ChooseEffect:playByIndex(0, -1, -1, 0)
    self.effectNode = node

    -- self.timeCount = 0
    if self.timeId == nil then
        local function update(delta)
            -- me.Director:getScheduler():unscheduleScriptEntry(self.timeId)
            TFDirector:removeTimer(self.timeId)
            self.timeId = nil
            self.effectNode:setVisible(true)
            self.effectNode = nil
            self.bIsGotBefore = true

            -- 标题特效
            self.img_title:setVisible(false)
            self:playTitleEffect(self.img_title)

            -- print("prizeIndex = ", prizeIndex)
            self:refreshUI()
            
            self:showPrizeResult(prizeIndex)
        end
        -- self.timeId = me.Scheduler:scheduleScriptFunc(update, 1.5, false)
        self.timeId = TFDirector:addTimer(500, -1, nil, update); 
    end
end

function BloodRewardBuy:playTitleEffect(titleNode)
    if self.TitleEffect == nil then
        local resPath = "effect/bloodfight3.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("bloodfight3_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)

        local node1          = titleNode
        local nodeParent1    = node1:getParent()
        nodeParent1:addChild(effect,2)
        effect:setPosition(node1:getPosition())

        effect:setAnchorPoint(ccp(0.5, 0.5))
        self.TitleEffect = effect
    end
    local node          = titleNode
    local nodeParent    = node:getParent()
    local pos = node:getPosition()
    self.TitleEffect:setPosition(ccp(pos.x + 350, pos.y + 50))
    self.TitleEffect:playByIndex(0, -1, -1, 1)
end

function BloodRewardBuy:showPrizeResult(index)
    if self.timeResultId[index] == nil then
        self.timeResultId[index] = {}

        -- local function update(delta)
        self.timeResultId[index].fun = function(delta)

            if self.timeResultId == nil then
                return
            end
            -- me.Director:getScheduler():unscheduleScriptEntry(self.timeResultId[index].timeId)
            TFDirector:removeTimer(self.timeResultId[index].timeId);
            self.timeResultId[index] = nil

            local data = self.boxData[index]
            print("self.boxData = ", self.boxData)
            local rewardInfo = BaseDataManager:getReward(data)
            RewardManager:toastRewardMessage(rewardInfo)

        end
        -- local timeId = me.Scheduler:scheduleScriptFunc(self.timeResultId[index].fun, 1, false)
        local timeId = TFDirector:addTimer(1000, -1, nil, self.timeResultId[index].fun)
        self.timeResultId[index].timeId = timeId
    end
end

function BloodRewardBuy.onlickPrize(sender)
    local prizeIndex = sender.index
    local self       = sender.logic
   
    -- 没领之前不让点击
    if self.bIsGotBefore == false then
        self.onlickchooseBox(sender)
        return
    end

    local prizeData = self.boxData[prizeIndex]
    
    print("prizeData = ", prizeData)
    Public:ShowItemTipLayer(prizeData.itemId, prizeData.type)
    -- Public:ShowItemTipLayer(prizeData.itemId, 1)


    -- Public:ShowItemTipLayer(signData.reward_id, signData.reward_type)
end

function BloodRewardBuy.onlickBuyOtherTwoBox(sender)
    local self = sender.logic

    local needResType   = self.costType  --购买需要的资源类型
    local num           = self.cost   --购买需要的资源数量
    local prizeIndex    = 0


    print("购买另外两个")
    print("needResType = ", needResType)
    print("num = ", num)

    -- 判断资源是否足够刷新
    if needResType == EnumDropType.COIN then 
        if MainPlayer:isEnoughCoin(num, true) then
            BloodFightManager:buyBox(self.boxIndex, prizeIndex)
        end
    end

    if needResType == EnumDropType.SYCEE then 
        if MainPlayer:isEnoughSycee(num, true) then
            BloodFightManager:buyBox(self.boxIndex, prizeIndex)
        end
    end
end

function BloodRewardBuy:showOtherTwoPrizeResult()
    local index = 4

    if self.timeResultId[index] == nil then
        self.timeResultId[index] = {}

        -- local function update(delta)
        self.timeResultId[index].fun = function(delta)

            if self.timeResultId == nil then
                return
            end
            -- me.Director:getScheduler():unscheduleScriptEntry(self.timeResultId[index].timeId)
            TFDirector:removeTimer(self.timeResultId[index].timeId);
            self.timeResultId[index] = nil

            AlertManager:close()
        end

        -- local timeId = me.Scheduler:scheduleScriptFunc(self.timeResultId[index].fun, 1, false)
        local timeId = TFDirector:addTimer(1000, -1, nil, self.timeResultId[index].fun)
        self.timeResultId[index].timeId = timeId
    end
end

return BloodRewardBuy