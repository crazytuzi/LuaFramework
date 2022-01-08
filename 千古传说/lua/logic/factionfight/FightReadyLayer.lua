--[[
******帮派战-预选界面*******

	-- by quanhuan
	-- 2016/2/22
	
]]

local FightReadyLayer = class("FightReadyLayer")

local MaxRankItem = 16
function FightReadyLayer:ctor(data, layer)

	self.ui = data
    self.parentLayer = layer
    self:initUI(data)
end

function FightReadyLayer:initUI( ui )
    local myNode = TFDirector:getChildByPath(ui, "img_bangpai")
    local localNode = TFDirector:getChildByPath(myNode, "txt_paiming")
    self.myRank = TFDirector:getChildByPath(localNode, "txt_num1")
    localNode = nil
    localNode = TFDirector:getChildByPath(myNode, "txt_fanrongdu")
    self.myFanRong = TFDirector:getChildByPath(localNode, "txt_num1")
    localNode = nil
    localNode = TFDirector:getChildByPath(myNode, "txt_time")
    self.endTime = TFDirector:getChildByPath(localNode, "txt_num1")

    local img_heidi1 = TFDirector:getChildByPath(ui, "img_heidi1")
    img_heidi1:setVisible(false)
    local img_heidi2 = TFDirector:getChildByPath(ui, "img_heidi2")
    img_heidi2:setVisible(false)
    local img_heidi3 = TFDirector:getChildByPath(ui, "img_heidi3")
    img_heidi3:setVisible(false)

    self.offsetX = img_heidi3:getPositionX() - img_heidi1:getPositionX()
    self.offsetY = img_heidi2:getPositionY() - img_heidi1:getPositionY() - 0.4
    self.originalPos = img_heidi1:getPosition()

    self.cellModel = TFDirector:getChildByPath(ui, "img_heidi1")
    self.cellModel:setVisible(false) 
    self.cellModel2 = TFDirector:getChildByPath(ui, "img_heidi2")
    self.cellModel2:setVisible(false) 

    self.panel_weikaiqi = TFDirector:getChildByPath(ui, "panel_weikaiqi")
    self.panel_kaiqi = TFDirector:getChildByPath(ui, "panel_kaiqi")
end

function FightReadyLayer:removeUI()
	
end

function FightReadyLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end

    self.panel_weikaiqi:setVisible(false)
    self.panel_kaiqi:setVisible(false)

    self.updateRankSuccessCallBack = function (event)
        if FactionFightManager:checkInReadyTime() then
            self.panel_weikaiqi:setVisible(false)
            self.panel_kaiqi:setVisible(true)
        else
            self.panel_weikaiqi:setVisible(true)
            self.panel_kaiqi:setVisible(false)
        end
        self.countDown = FactionFightManager:getCutDownTimeByState(FactionFightManager.ActivityState_1)
        self.rankItemData = FactionFightManager:getGuildBoomList()
        self:showRankItemList()
        self:showCutDownTimer()
    end
    TFDirector:addMEGlobalListener(FactionFightManager.updateRankSuccess, self.updateRankSuccessCallBack)

    self.registerEventCallFlag = true 
end

function FightReadyLayer:removeEvents()

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end
    if self.updateRankSuccessCallBack then
        TFDirector:removeMEGlobalListener(FactionFightManager.updateRankSuccess, self.updateRankSuccessCallBack)    
        self.updateRankSuccessCallBack = nil
    end

    self.registerEventCallFlag = nil  
end

function FightReadyLayer:dispose()

end

function FightReadyLayer:setVisible(v)
    self.ui:setVisible(v)

    if v then
        self:registerEvents()
        FactionFightManager:requestUpdateRank()
    else
        self:removeEvents()        
    end
end

function FightReadyLayer:showRankItemList()
    if self.rankItemList == nil then
        self.rankItemList = {}
        for i=1,MaxRankItem do 
            local x = self.originalPos.x + (math.floor(i/9)*self.offsetX)
            local y = self.originalPos.y + ((i-1)%8)*self.offsetY

            local item = nil
            if i%2 == 0 then
                item = self.cellModel:clone()

            else
                item = self.cellModel:clone()
            end


            self.cellModel:getParent():addChild(item)

            self.rankItemList[i] = item
            self.rankItemList[i]:setVisible(false)
            self.rankItemList[i]:setPosition(ccp(x,y))

        end
    end

    for i=1,MaxRankItem do
        self.rankItemList[i]:setVisible(true)
        local imgRank = TFDirector:getChildByPath(self.rankItemList[i], 'img_paiming')
        imgRank:setVisible(false)
        local txtName = TFDirector:getChildByPath(self.rankItemList[i], 'txt_name')
        txtName:setVisible(false)
        local txtNum = TFDirector:getChildByPath(self.rankItemList[i], 'txt_num')
        txtNum:setVisible(false)
        local txtRank = TFDirector:getChildByPath(self.rankItemList[i], 'txt_shunxu')
        txtRank:setVisible(false)

        local itemData = self.rankItemData[i]
        if itemData then
            if i < 4 then
                imgRank:setVisible(true)
                imgRank:setTexture("ui_new/leaderboard/no"..i..".png")
            else
                txtRank:setVisible(true)
                txtRank:setText(i)
            end
            txtName:setVisible(true)
            txtName:setText(itemData.guildName)
            txtNum:setVisible(true)
            txtNum:setText(itemData.guildBoom)
        end
    end

    local myData = FactionFightManager:getMyGuildBoomRank()
    if myData and myData.rank ~= 0 then
        self.myRank:setText(myData.rank)
        self.myFanRong:setText(myData.boom)
    else
        --self.myRank:setText("未上榜")
	self.myRank:setText(localizable.faction_no_rank)
        self.myFanRong:setText("0")
    end
end

function FightReadyLayer:showCutDownTimer()

    self.endTime:setText(FactionFightManager:getTimeString( self.countDown ))
    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function () 
        if self.countDown <= 0 then
            if self.countDownTimer then
                TFDirector:removeTimer(self.countDownTimer)
                self.countDownTimer = nil
            end
            self.endTime:setText(FactionFightManager:getTimeString( self.countDown ))
        else
            self.countDown = self.countDown - 1
            self.endTime:setText(FactionFightManager:getTimeString( self.countDown ))
        end
    end)
end

return FightReadyLayer