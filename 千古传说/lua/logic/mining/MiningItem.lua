--[[
******采矿页*******
    -- by yao
    -- 2016/1/12
]]

local MiningItem = class("MiningItem", BaseLayer)

function MiningItem:ctor(data)
    self.super.ctor(self,data)
    self.miningState    = 0         --采矿状态(0.未开采 1.开采中 3.收获)
    self.miningState2   = 0
    self.countDownTimer1= nil       --开采中计时器
    self.countDownTimer2= nil       --开采中计时器
    self.mineralInfo    = {}        --矿洞数据
    self.lightEffect1   = nil
    self.lightEffect2   = nil

    self:init("lua.uiconfig_mango_new.mining.caikuang")
end

function MiningItem:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_caikuang1  = TFDirector:getChildByPath(ui, "btn_caikuang1")
    self.btn_caikuang2  = TFDirector:getChildByPath(ui, "btn_caikuang2")
    self.btn_shouhuo1   = TFDirector:getChildByPath(ui, "btn_shouhuo1")
    self.btn_shouhuo2   = TFDirector:getChildByPath(ui, "btn_shouhuo2")
    self.jiekuangInfo1  = TFDirector:getChildByPath(ui, "Panel_jiekuangxinxi1")
    self.jiekuangInfo2  = TFDirector:getChildByPath(ui, "Panel_jiekuangxinxi2")
    self.kaicaishijian1 = TFDirector:getChildByPath(ui, "bg_kaicaishijian1")
    self.txt_time1      = TFDirector:getChildByPath(self.kaicaishijian1, "txt_time")
    self.kaicaishijian2 = TFDirector:getChildByPath(ui, "bg_kaicaishijian2")
    self.txt_time2      = TFDirector:getChildByPath(self.kaicaishijian2, "txt_time")
    self.bg_changchu1   = TFDirector:getChildByPath(self.btn_shouhuo1, "bg_changchu")
    self.txt_changchu1  = TFDirector:getChildByPath(self.bg_changchu1, "txt_changchu")
    self.bg_changchu2   = TFDirector:getChildByPath(self.btn_shouhuo2, "bg_changchu")
    self.txt_changchu2  = TFDirector:getChildByPath(self.btn_shouhuo2, "txt_changchu")
    --self.txt_changchu2  = TFDirector:getChildByPath(self.btn_shouhuo2, "txt_changchu")
    self.btn_suo        = TFDirector:getChildByPath(ui, "btn_suo")
    self.bg_jiwsuosm    = TFDirector:getChildByPath(ui, "bg_jiwsuosm")
    self.jiesuoshuoming = TFDirector:getChildByPath(ui, "txt_jiesuoshuoming")
    self.bg             = TFDirector:getChildByPath(ui, "bg")

    self.btn_caikuang1.logic    = self
    self.btn_caikuang1.tag      = 1
    self.btn_caikuang2.logic    = self
    self.btn_caikuang2.tag      = 2
    self.btn_shouhuo1.logic     = self
    self.btn_shouhuo1.tag       = 3
    self.btn_shouhuo2.logic     = self
    self.btn_shouhuo2.tag       = 4
    self.jiekuangInfo1.tag      = 11
    self.jiekuangInfo2.tag      = 12

    local pos1 = self.btn_caikuang1:getPosition()
    local pos2 = self.btn_caikuang2:getPosition()
    self:mineAction(self.btn_caikuang1,pos1)
    self:mineAction(self.btn_caikuang2,pos2)
    --self:ShowUIData()
end

function MiningItem:setData()
    self:ShowUIData()
    --print("刷新矿石222")
end

function MiningItem:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function MiningItem:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function MiningItem:registerEvents()
    self.super.registerEvents(self)

    self.btn_caikuang1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCaiKuangBack))
    self.btn_caikuang2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCaiKuangBack))
    self.btn_shouhuo1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShouhuoCallBack))
    self.btn_shouhuo2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShouhuoCallBack)) 
    self.btn_suo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJiesuoCallBack)) 
end

function MiningItem:removeEvents()
    self.btn_caikuang1:removeMEListener(TFWIDGET_CLICK)
    self.btn_caikuang2:removeMEListener(TFWIDGET_CLICK)
    self.btn_shouhuo1:removeMEListener(TFWIDGET_CLICK)
    self.btn_shouhuo2:removeMEListener(TFWIDGET_CLICK)
    self.btn_suo:removeMEListener(TFWIDGET_CLICK)
    if self.countDownTimer1 then
        TFDirector:removeTimer(self.countDownTimer1)
        self.countDownTimer1 = nil
    end
    if self.countDownTimer2 then
        TFDirector:removeTimer(self.countDownTimer2)
        self.countDownTimer2 = nil
    end
    self.super.removeEvents(self)
end

function MiningItem:dispose()
    self.super.dispose(self)
end

function MiningItem:ShowUIData()
    self.mineralInfo = MiningManager:getMineralDetailInfo()
    --0:为开采 1：开采中 2.待收获
    self.miningState = self.mineralInfo[1].status 
    --是否解锁
    local mineralType  = self.mineralInfo[1].type
    --是否被打劫成功
    local isBeLoot1  = self.mineralInfo[1].robStatus
    local level = MainPlayer:getLevel()
    local result = math.floor((math.sqrt(level*9.5)-10))
    print("isBeLoot1:",isBeLoot1)
    if mineralType ~= 0 then
        local nowtime = MainPlayer:getNowtime()
        local startTime = self.mineralInfo[1].startTime
        local endTime = self.mineralInfo[1].endTime
        local redutime = math.floor((endTime-startTime)/1000)-(nowtime-math.floor(startTime/1000))
        if redutime < 0 then
            redutime = 0
            if self.miningState == 1 then
                self.miningState = 2
            end 
        end
        if self.miningState == 0 then
            self.btn_caikuang1:setVisible(true)
            self.kaicaishijian1:setVisible(false)
            self.btn_shouhuo1:setVisible(false)
        elseif self.miningState == 1 then
            self.btn_caikuang1:setVisible(false)
            self.kaicaishijian1:setVisible(true)
            self.btn_shouhuo1:setVisible(false)
            self:countdownTime(redutime,self.txt_time1) 
            self:addlightsEffect1()
            MiningManager:setMineStauts(1, self.miningState, self.mineralInfo[1].endTime)            
        elseif self.miningState == 2 then
            self.btn_caikuang1:setVisible(false)
            self.kaicaishijian1:setVisible(false)
            self.btn_shouhuo1:setVisible(true)    
        end

        local mineInfo = MineTemplateData:getMinetempById(mineralType)
        if isBeLoot1 == 0 then
            self.jiekuangInfo1:setVisible(false)
            self.txt_changchu1:setText(mineInfo.reward_coin*result)
        else
            self.jiekuangInfo1:setVisible(true)
            self:showLootMineralInfo(self.jiekuangInfo1,1)
            self.txt_changchu1:setText(mineInfo.reward_coin*result-self.mineralInfo[1].robInfo.robCoin)
        end 
        self.btn_shouhuo1:setTextureNormal("ui_new/mining/img_ks" .. mineralType .. ".png")
    else
        --锁定
    end

    self.miningState2 = self.mineralInfo[2].status
    --是否解锁
    local mineralType2  = self.mineralInfo[2].type     
    --是否被打劫成功
    local isBeLoot2  = self.mineralInfo[2].robStatus
    print("isBeLoot2:",isBeLoot2)
    if mineralType2 ~= 0 then
        local nowtime = MainPlayer:getNowtime()
        local startTime = self.mineralInfo[2].startTime
        local endTime = self.mineralInfo[2].endTime
        local redutime = math.floor((endTime-startTime)/1000)-(nowtime-math.floor(startTime/1000))
        if redutime < 0 then
            redutime = 0
            if self.miningState2 == 1 then
                self.miningState2 = 2
            end   
        end
        if self.miningState2 == 0 then
            self.btn_caikuang2:setVisible(true)
            self.kaicaishijian2:setVisible(false)
            self.btn_shouhuo2:setVisible(false)
        elseif self.miningState2 == 1 then
            self.btn_caikuang2:setVisible(false)
            self.kaicaishijian2:setVisible(true)
            self.btn_shouhuo2:setVisible(false)  
            self:countdownTime2(redutime,self.txt_time2)
            self:addlightsEffect2()
            MiningManager:setMineStauts(2, self.miningState2, self.mineralInfo[2].endTime)   
        elseif self.miningState2 == 2 then
            self.btn_caikuang2:setVisible(false)
            self.kaicaishijian2:setVisible(false)
            self.btn_shouhuo2:setVisible(true)
        end

        local mineInfo = MineTemplateData:getMinetempById(mineralType2)
        self.btn_shouhuo2:setTextureNormal("ui_new/mining/img_ks" .. mineralType2 .. ".png")
        if isBeLoot2 == 0 then
            self.jiekuangInfo2:setVisible(false)
            self.txt_changchu2:setText(mineInfo.reward_coin*result)
        else
            self.jiekuangInfo2:setVisible(true)
            self:showLootMineralInfo(self.jiekuangInfo2,2)
            self.txt_changchu2:setText(mineInfo.reward_coin*result-self.mineralInfo[2].robInfo.robCoin)
        end
        self.txt_changchu2:setPosition(ccp(15,2))
        self.btn_suo:setVisible(false)
        self.bg_jiwsuosm:setVisible(false)
    else
        --锁定
        local unlocklevel = MiningManager:getMineTwoUnlockLevel()
        self.btn_caikuang2:setVisible(false)
        self.kaicaishijian2:setVisible(false)
        self.jiekuangInfo2:setVisible(false)
        self.btn_shouhuo2:setVisible(false)
        self.btn_suo:setVisible(true)
        --self.jiesuoshuoming:setText(unlocklevel .. "级解锁")
        self.jiesuoshuoming:setText(stringUtils.format(localizable.common_level_unlock, unlocklevel))
    end
end

--
function MiningItem:showLootMineralInfo(panel,type)
    local bg_roleinfo   = TFDirector:getChildByPath(panel, "bg_roleinfo")
    local txt_name      = TFDirector:getChildByPath(bg_roleinfo, "txt_name")
    local bg_zhanli     = TFDirector:getChildByPath(bg_roleinfo, "bg_zhanli")
    local txt_zhandouli = TFDirector:getChildByPath(bg_zhanli, "txt_zhandouli")
    local bg_touxiang   = TFDirector:getChildByPath(bg_roleinfo, "bg_touxiang")
    local img_head      = TFDirector:getChildByPath(bg_touxiang, "img_head")
    local bg_jiede      = TFDirector:getChildByPath(panel, "bg_jiede")
    local img_jd        = TFDirector:getChildByPath(bg_jiede, "img_jd")
    local img_tongbi    = TFDirector:getChildByPath(bg_jiede, "img_tongbi")
    local txt_tongbi    = TFDirector:getChildByPath(bg_jiede, "txt_tongbi")
    local bg_huifang    = TFDirector:getChildByPath(panel, "bg_huifang")
    local btn_huifang   = TFDirector:getChildByPath(bg_huifang, "btn_huifang")

    local roleMineInfo = MiningManager:getRoleMineInfo()
    local rabroleinfo = roleMineInfo.info[type].robInfo

    if rabroleinfo.icon == nil or rabroleinfo.icon <= 0 then                --pck change head icon and head icon frame
        rabroleinfo.icon = rabroleinfo.profession
    else
        Public:addInfoListen(img_head,true,1,rabroleinfo.playerId)
    end
    local roleIcon = RoleData:objectByID(rabroleinfo.icon) 
    img_head:setTexture(roleIcon:getIconPath())
    Public:addFrameImg(img_head,rabroleinfo.headPicFrame)                       --end
    txt_name:setText(rabroleinfo.name)
    txt_zhandouli:setText(rabroleinfo.power)
    txt_tongbi:setText(rabroleinfo.robCoin)
    btn_huifang:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onHuifangCallBack))
    btn_huifang.logic = self
    btn_huifang.tag = 100+type
    btn_huifang.reportId = roleMineInfo.info[type].robInfo.battleId
end

function MiningItem:countdownTime(time,label)
    if self.countDownTimer1 ~= nil then
        return
    end
    local cutDownTime = time
    local function showCutDownString( times )
        local str = nil
        local month = math.floor(times/3600)
        local min = math.floor(times%3600/60)
        local sec = times%60
        str = string.format("%02d",month)..":"..string.format("%02d",min)..":"..string.format("%02d",sec)     
        return str
    end
    local timeStr = showCutDownString( cutDownTime )
    label:setText(timeStr)
    self.countDownTimer1 = TFDirector:addTimer(1000, -1, nil, 
        function () 
        if cutDownTime <= 0 then
            if self.countDownTimer1 then
                TFDirector:removeTimer(self.countDownTimer1)
                self.countDownTimer1 = nil
            end
            self:ShowUIData()
        else
            cutDownTime = cutDownTime - 1
            local timeStr = showCutDownString( cutDownTime )
            label:setText(timeStr)
        end
    end) 
end

function MiningItem:countdownTime2(time,label)
    if self.countDownTimer2 ~= nil then
        return
    end
    local cutDownTime = time
    local function showCutDownString( times )
        local str = nil
        local month = math.floor(times/3600)
        local min = math.floor(times%3600/60)
        local sec = times%60
        str = string.format("%02d",month)..":"..string.format("%02d",min)..":"..string.format("%02d",sec)     
        return str
    end
    local timeStr = showCutDownString( cutDownTime )
    label:setText(timeStr)
    self.countDownTimer2 = TFDirector:addTimer(1000, -1, nil, 
        function () 
        if cutDownTime <= 0 then
            if self.countDownTimer2 then
                TFDirector:removeTimer(self.countDownTimer2)
                self.countDownTimer2 = nil
            end
            self:ShowUIData()
        else
            cutDownTime = cutDownTime - 1
            local timeStr = showCutDownString( cutDownTime )
            label:setText(timeStr)
        end
    end)
end

--采矿按钮回调（进入选矿界面）
function MiningItem.onCaiKuangBack(sender)
    local self = sender.logic
    local tag  = sender.tag
    --print("tag:",tag)
    if tag == 1 then
        if self.miningState == 0 then
            local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mining.ChooseMineralLayer")
            layer:loadData(1)
            AlertManager:show()
        else
            
        end   
    elseif tag == 2 then
        if self.miningState2 == 0 then
            local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mining.ChooseMineralLayer")
            layer:loadData(2)
            AlertManager:show()
            return
        else
        end
    end 
end

--收获按钮回调
function MiningItem.onShouhuoCallBack(sender)
    local self = sender.logic
    local tag  = sender.tag
    --print("tag:",tag)
    if tag == 3 then
        MiningManager:requestGetMineReward(1) 
    elseif tag == 4 then
        MiningManager:requestGetMineReward(2)
    end 
end

--回放按钮回调
function MiningItem.onHuifangCallBack(sender)
    local self  = sender.logic
    local tag   = sender.tag
    local reportId = sender.reportId
    print("chong bo vvvv")
    MiningManager:requestChongbo(reportId)
end

--解锁按钮回调
function MiningItem.onJiesuoCallBack()
    local roleLevel = MainPlayer:getLevel()
    local openLevel = MiningManager:getMineTwoUnlockLevel()
    if roleLevel >= openLevel then
        MiningManager:requestUnlockMine()
    else
        --toastMessage(openLevel .. "级解锁")
        toastMessage(stringUtils.format(localizable.common_level_unlock,openLevel))
    end  
end

function MiningItem:mineAction(sender,pos)
    local moveup = CCMoveTo:create(0.8,ccp(pos.x,pos.y+30))
    local movedown = CCMoveTo:create(0.8,ccp(pos.x,pos.y-30))
    local act1 = CCSequence:createWithTwoActions(moveup,movedown)
    sender:runAction(CCRepeatForever:create(act1))
end

function MiningItem:addlightsEffect1()
    if self.lightEffect1 == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/doorlight.xml")
        self.lightEffect1 = TFArmature:create("doorlight_anim")
        if self.lightEffect1 == nil then
            return
        end
        self.lightEffect1:setZOrder(100)
        self.lightEffect1:setAnimationFps(GameConfig.ANIM_FPS)
        self.bg:addChild(self.lightEffect1,10)
        self.lightEffect1:setPosition(ccp(570,320))
    end
    self.lightEffect1:playByIndex(0, -1, -1, 1)
end
function MiningItem:addlightsEffect2()
    if self.lightEffect2 == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/doorlight.xml")
        self.lightEffect2 = TFArmature:create("doorlight_anim")
        if self.lightEffect2 == nil then
            return
        end
        self.lightEffect2:setZOrder(100)
        self.lightEffect2:setAnimationFps(GameConfig.ANIM_FPS)
        self.bg:addChild(self.lightEffect2,10)
        self.lightEffect2:setPosition(ccp(570,320))
    end
    self.lightEffect2:playByIndex(1, -1, -1, 1)
    
end

return MiningItem