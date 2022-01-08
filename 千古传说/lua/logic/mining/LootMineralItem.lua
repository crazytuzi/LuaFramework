--[[
******劫矿页*******
    -- by yao
    -- 2016/1/12
]]

local LootMineralItem = class("LootMineralItem", BaseLayer)

function LootMineralItem:ctor(data)
    self.super.ctor(self,data)
    self.ui = nil
    self.mineList = {}
    self.randomPosArr = {}
    self.mineEffect = {}
    self.advanceEffect = nil
    self.panelArr = {}
    self.kuangArr = {}
    self.jubing = nil
    self:init("lua.uiconfig_mango_new.mining.jiekuang")
end

function LootMineralItem:initUI(ui)
	self.super.initUI(self,ui)
    self.ui = ui
    self.btn_qianxing = TFDirector:getChildByPath(ui, "btn_qianxing")
    self.btn_qianxing.logic = self
    self.bg = TFDirector:getChildByPath(ui, "bg")

    for k=1,6 do
        local panel_role= TFDirector:getChildByPath(self.ui, "Panel_role" .. k)
        local kuang     = TFDirector:getChildByPath(self.ui, "kuang" .. k)

        self.panelArr[k]= panel_role
        self.kuangArr[k]= kuang
        self.kuangArr[k]:setVisible(false)
    end

    self:showUIData()
end

function LootMineralItem:setData()
    --self:showUIData()
end

function LootMineralItem:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function LootMineralItem:onShow()
    self.super.onShow(self)
end

function LootMineralItem:registerEvents()
    self.super.registerEvents(self)

    self.btn_qianxing:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQianxingCallBack))
    self.eventUpdateMineList = function(event)
        --print("更新挖矿者数据")
        for i=1,6 do
            self.panelArr[i]:setVisible(false)
            self.kuangArr[i]:setVisible(false)
        end
        self:addAdvanceEffect()
    end;
    TFDirector:addMEGlobalListener(MiningManager.EVENT_UPDATE_QIANXING, self.eventUpdateMineList)  
end

function LootMineralItem:removeEvents()
    self.btn_qianxing:removeMEListener(TFWIDGET_CLICK)
    TFDirector:removeMEGlobalListener(MiningManager.EVENT_UPDATE_QIANXING, self.eventUpdateMineList)
    self.eventUpdateMineList = nil
    self.super.removeEvents(self)
end

function LootMineralItem:dispose()
    self.super.dispose(self)
end

function LootMineralItem.onQianxingCallBack(sender)
    local self = sender.logic
    MiningManager:requestFreshMineList()
    --print("ddddd:",self.jubing)
    if self.jubing ~= nil then
        TFAudio.stopEffect(self.jubing)
    end
    self.jubing = play_qianxing_jiaobusheng()
end

function LootMineralItem.onChooseRoleCallBack(sender)
    local self          = sender.logic
    local index         = sender.index
    local mineList      = sender.mineList
    local mineIndex     = mineList.id
    local minePlayerId  = mineList.playerId
  
    print("minePlayerId:",minePlayerId)
    print("mineIndex:",mineIndex)
    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.MINE)
    local challengetime = challengeInfo.currentValue
    local nowtime       = MainPlayer:getNowtime()
    local endtime       = math.ceil(mineList.endTime/1000)
    if endtime - nowtime <= 600 then
        -- local str = TFLanguageManager:getString(ErrorCodeData.Mining_Mining_Complete)
        toastMessage(localizable.Mining_Mining_Complete)
        self.jubing = play_qianxing_jiaobusheng()
        MiningManager:requestFreshMineList()
    else
        if challengetime <= 0 then
            VipRuleManager:showMineTimesLayer()
        else
            MiningManager:setLootPlayerIndexAndMine(mineIndex,minePlayerId,index) 
            MiningManager:requestLockPlayerMine(minePlayerId,mineIndex)
        end
    end
      
end

function LootMineralItem:showUIData()
    self.mineList = MiningManager:getFreshMineListResult()
    self.randomPosArr = MiningManager:getRandomPostable()
    --print("self.mineList:",#self.mineList)
    local minenum = 0
    for k=1,6 do
        local posIndex      = self.randomPosArr[k]
        local panel_role    = self.panelArr[posIndex]
        --local panel_role    = TFDirector:getChildByPath(self.ui, "Panel_role" .. posIndex)
        local bg_name       = TFDirector:getChildByPath(panel_role, "bg_name")
        local txt_name      = TFDirector:getChildByPath(bg_name, "txt_name")
        local bg_zhanli     = TFDirector:getChildByPath(panel_role, "bg_zhanli")
        local txt_zhandouli = TFDirector:getChildByPath(bg_zhanli, "txt_zhandouli")
        local bg_huwei      = TFDirector:getChildByPath(panel_role, "bg_huwei")
        local img_huwei     = TFDirector:getChildByPath(bg_huwei, "img_huwei")
        local img_di        = TFDirector:getChildByPath(bg_huwei, "img_di")
        local btn_bgrole    = TFDirector:getChildByPath(panel_role, "bg_role")
        local img_role      = TFDirector:getChildByPath(panel_role, "img_role")

        if next(self.mineList) ~= nil and self.mineList[k] ~= nil then
            local roleIcon = RoleData:objectByID(self.mineList[k].icon)                             --pck change head icon and head icon frame
            panel_role:setVisible(true)
            txt_name:setText(self.mineList[k].name)
            txt_zhandouli:setText(self.mineList[k].power)
            img_role:setTexture(roleIcon:getIconPath()) 
            Public:addFrameImg(img_role,self.mineList[k].headPicFrame)                             --end
            --Public:addInfoListen(img_role,true,1,self.mineList[k].playerId)
            --btn_bgrole:setTexture(GetColorRoadIconByQuality(roleIcon.quality))
            btn_bgrole:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChooseRoleCallBack))
            btn_bgrole.logic = self
            btn_bgrole.index = k
            btn_bgrole.mineList = self.mineList[k]

            local guardInfo = self.mineList[k].guardInfo
            if guardInfo == nil then
                bg_huwei:setVisible(false)
            else
                bg_huwei:setVisible(true)
                local huweiIcon = RoleData:objectByID(guardInfo.icon)                               --pck change head icon and head icon frame
                img_huwei:setTexture(huweiIcon:getIconPath())
                Public:addFrameImg(img_huwei,guardInfo.headPicFrame)                               --end
                --Public:addInfoListen(img_huwei,true,1,guardInfo.playerId)
            end
            self.kuangArr[posIndex]:setVisible(true)
            
            self.kuangArr[posIndex]:setTexture("ui_new/mining/k" .. self.mineList[k].type .. ".png")
            print("self.mineList[k].id",self.mineList[k].id)
            if self.mineList[k].id == 2 then
                self.kuangArr[posIndex]:setTexture("ui_new/mining/k" .. self.mineList[k].type+4 .. ".png")
            end
            minenum = minenum + 1
        else
            panel_role:setVisible(false)
        end
        if self.mineEffect[posIndex] == nil then
            TFResourceHelper:instance():addArmatureFromJsonFile("effect/mineeffect.xml")
            local effect = TFArmature:create("mineeffect_anim")
            if effect == nil then
                return
            end
            effect:setAnimationFps(GameConfig.ANIM_FPS)
            effect:playByIndex(0, -1, -1, 1)
            effect:setPosition(ccp(60,50))
            btn_bgrole:addChild(effect,10)
            self.mineEffect[posIndex] = effect
            effect:setZOrder(100)
            if posIndex > 3 then
                effect:setRotation3D(0,180,0)
                effect:setPosition(ccp(60,50))
                --print("ffffffffff")
            end
        else
            self.mineEffect[posIndex]:playByIndex(0, -1, -1, 1)
        end
    end  
    if minenum > 0 then
        play_daicaikuang()
    end
end

function LootMineralItem:addAdvanceEffect()
    if self.advanceEffect == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/mineadvance.xml")
        self.advanceEffect = TFArmature:create("mineadvance_anim")
        if self.advanceEffect == nil then
            return
        end
        self.advanceEffect:setZOrder(100)
        self.advanceEffect:setAnimationFps(GameConfig.ANIM_FPS)
        self.advanceEffect:setPosition(ccp(572,315))
        self.bg:addChild(self.advanceEffect,10)
        self.advanceEffect = self.advanceEffect
        self.advanceEffect:setScale(0.99)
        self.advanceEffect:setTouchEnabled(true)
        self.advanceEffect:addMEListener(TFWIDGET_CLICK, self.onEffectTouchEndedHandle);
        self.advanceEffect.logic = self
    end
    self.advanceEffect:setVisible(true)
    self.advanceEffect:playByIndex(0, -1, -1, 0)
    self.advanceEffect:addMEListener(TFARMATURE_COMPLETE,function ()
        self.advanceEffect:setVisible(false)
        self:showUIData()
    end)
end

function LootMineralItem.onEffectTouchEndedHandle(sender)
    local self  = sender.logic
    self.advanceEffect:setVisible(false)
    self:showUIData()
end

return LootMineralItem