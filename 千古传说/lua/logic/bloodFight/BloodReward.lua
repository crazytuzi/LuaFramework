
local BloodReward = class("BloodReward", BaseLayer)

function BloodReward:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.bloodybattle.BloodybattleAward")
end

function BloodReward:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')

    self.prizeBtn       = TFDirector:getChildByPath(ui, 'btn_choujiang')
    self.prizeBtn.logic = self
    self.prizeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onlickPrizeBtn));
    
    self.img_di2 = TFDirector:getChildByPath(ui, 'img_di2')
    self.ItemList = {}
    for i=1,3 do
        -- img_award
        self.ItemList[i] = {}
        self.ItemList[i].node         = TFDirector:getChildByPath(ui, "img_award"..i)
        self.ItemList[i].img_quality  = TFDirector:getChildByPath(ui, "img_quality"..i)
        self.ItemList[i].img_goods    = TFDirector:getChildByPath(ui, "img_goods"..i)
        self.ItemList[i].txt_num      = TFDirector:getChildByPath(ui, "txt_num"..i)

        self.ItemList[i].img_goods.index = i
        self.ItemList[i].img_goods.logic = self
        self.ItemList[i].img_goods:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onlickPrize))
    end
end

function BloodReward:registerEvents(ui)
    self.super.registerEvents(self)
    -- self.ruleBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ruleBtnClickHandle));
    -- self.closeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClickHandle));
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function BloodReward:removeEvents()
    self.super.removeEvents(self)

end

function BloodReward.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function BloodReward:loadBoxData(boxIndex,data)
    self.boxData    = data
    self.boxIndex   = boxIndex
end

function BloodReward:onShow()
    self.super.onShow(self)
    self:refreshUI();
end

function BloodReward:refreshUI()
    if self.boxData == nil then
        return
    end
    -- print("boxInfo = ", self.boxData)

    for i=1,3 do
        local img_goodsIcon     = self.ItemList[i].img_goods
        local txt_num           = self.ItemList[i].txt_num
        local img_itemBg        = self.ItemList[i].img_quality

        -- local boxInfo = getRewardInfo(self.boxData[i].id)
        -- print("boxInfo = ", boxInfo)
        -- 绘制物品icon 及 名称
        -- local item = {type = boxInfo.type, number = boxInfo.num, itemId = boxInfo.id}
        -- local itemInfo = boxInfo
        local itemInfo  = BaseDataManager:getReward(self.boxData[i])
        local boxInfo   = itemInfo
        
        if boxInfo.type == EnumDropType.ROLE then
            local role      = RoleData:objectByID(itemInfo.itemid)
            local headIcon  = role:getIconPath()
            img_goodsIcon:setTexture(headIcon)
        else
            img_goodsIcon:setTexture(itemInfo.path)
        end
        -- 
     -- lbl_goodsName:setText(itemInfo.name)
        local path = GetColorIconByQuality(itemInfo.quality)
       
        if boxInfo.type == EnumDropType.GOODS then
            local itemDetail = ItemData:objectByID(boxInfo.itemid)
            if itemDetail ~= nil and itemDetail.type == EnumGameItemType.Piece then
                path =  GetBackgroundForFragmentByQuality(itemInfo.quality)
            else
                path =  GetColorIconByQuality(itemInfo.quality)
            end
        end

        txt_num:setText(string.format("%d", boxInfo.number))
        img_itemBg:setTexture(path)

        
        Public:addPieceImg(img_goodsIcon,{type = boxInfo.type, itemid = boxInfo.itemid})
        -- print("self.boxData[i] = ", self.boxData[i])
        -- print("itemInfo = ", itemInfo)
        -- print("boxInfo = ", boxInfo)
    end 
end 


function BloodReward:playEffect()
    if self.ChooseEffect == nil then
        local resPath = "effect/bloodfight1.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("bloodfight1_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(self:getSize().width/2-7,self:getSize().height/2-25))

        self:addChild(effect,2)

        effect:addMEListener(TFARMATURE_COMPLETE,function()
            local boxIndex = self.boxIndex
            AlertManager:close()
            BloodFightManager:beginGetPrize(boxIndex, false)
        end)

        self.ChooseEffect = effect
    end

    self.ChooseEffect:playByIndex(0, -1, -1, 0)
end

function BloodReward:moveNode(node, pos)
    local function onCompleteCallback()
        self.count = self.count + 1

        if self.count == 2 then
            for i=1,3 do
                self.ItemList[i].node:setVisible(false)
            end

            self:playEffect()
            return
        end
    end

    local toastTween = {
        target = node,
        {
            duration = 0.5,
            x = pos.x,    -- x坐标
            y = pos.y,    -- y坐标
        },
        {
            duration = 0,
            delay = 1 / 60;
            onComplete = onCompleteCallback;
        }
    }

    TFDirector:toTween(toastTween);
end

function BloodReward.onlickPrizeBtn(sender)
    local self = sender.logic
    print("0.开始抽奖 随机")

    self.count = 0

    self.prizeBtn:setVisible(false)
    self.img_di2:setVisible(false)
    self:moveNode(self.ItemList[1].node, self.ItemList[2].node:getPosition())
    self:moveNode(self.ItemList[3].node, self.ItemList[2].node:getPosition())
end


function BloodReward.onlickPrize(sender)
    local prizeIndex = sender.index
    local self       = sender.logic
   
    local prizeData = self.boxData[prizeIndex]
    
    print("prizeData = ", prizeData)
    Public:ShowItemTipLayer(prizeData.itemId, prizeData.type)
    -- Public:ShowItemTipLayer(signData.reward_id, signData.reward_type)
end

function BloodReward:getRewardInfo(rewardId)
    local rewardList = RewardConfigureData:GetRewardItemListById(rewardId);
        --目前只获取第一个奖励
    return rewardList:getObjectAt(1)
end

return BloodReward