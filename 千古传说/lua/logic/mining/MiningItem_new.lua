--[[
******采矿页*******
    -- by yao
    -- 2016/1/12
]]

local MiningItem = class("MiningItem", BaseLayer)

function MiningItem:ctor(data)
    self.super.ctor(self,data)
    self.daikaicaieffect = nil
    self.status = {[1] = 0,[2] = 0}

    self:init("lua.uiconfig_mango_new.mining.caikuang")
end

function MiningItem:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_suo        = TFDirector:getChildByPath(ui, "btn_suo")
    self.bg_jiwsuosm    = TFDirector:getChildByPath(ui, "bg_jiwsuosm")
    self.jiesuoshuoming = TFDirector:getChildByPath(ui, "txt_jiesuoshuoming")
    self.bg             = TFDirector:getChildByPath(ui, "bg")

    self.btn_caikuang1  = TFDirector:getChildByPath(ui, "btn_caikuang1")
    self.btn_caikuang2  = TFDirector:getChildByPath(ui, "btn_caikuang2")
    self.btn_shouhuo1   = TFDirector:getChildByPath(ui, "btn_shouhuo1")
    self.btn_shouhuo2   = TFDirector:getChildByPath(ui, "btn_shouhuo2")
    self.jiekuangInfo1  = TFDirector:getChildByPath(ui, "Panel_jiekuangxinxi1")
    self.jiekuangInfo2  = TFDirector:getChildByPath(ui, "Panel_jiekuangxinxi2")
    self.kaicaishijian1 = TFDirector:getChildByPath(ui, "bg_kaicaishijian1")
    self.kaicaishijian2 = TFDirector:getChildByPath(ui, "bg_kaicaishijian2")
    self.bg_tips1       = TFDirector:getChildByPath(ui, "bg_tips1")
    self.bg_tips2       = TFDirector:getChildByPath(ui, "bg_tips2")
    self.panel1         = TFDirector:getChildByPath(ui, "panel1")
    self.panel2         = TFDirector:getChildByPath(ui, "panel2")



    self.txt_time1      = TFDirector:getChildByPath(self.kaicaishijian1, "txt_time")
    self.txt_time2      = TFDirector:getChildByPath(self.kaicaishijian2, "txt_time")
    --self.bg_changchu1   = TFDirector:getChildByPath(self.btn_shouhuo1, "bg_changchu")
    --self.txt_changchu1  = TFDirector:getChildByPath(self.bg_changchu1, "txt_changchu")
    --self.bg_changchu2   = TFDirector:getChildByPath(self.btn_shouhuo2, "bg_changchu")
    --self.txt_changchu2  = TFDirector:getChildByPath(self.btn_shouhuo2, "txt_changchu")
    self.txt_time1:setText("00:00:00")
    self.txt_time2:setText("00:00:00")


    self.btn_caikuang1.logic    = self
    self.btn_caikuang1.tag      = 1
    self.btn_caikuang2.logic    = self
    self.btn_caikuang2.tag      = 2
    self.btn_shouhuo1.logic     = self
    self.btn_shouhuo1.tag       = 1
    self.btn_shouhuo2.logic     = self
    self.btn_shouhuo2.tag       = 2
    self.jiekuangInfo1.tag      = 1
    self.jiekuangInfo2.tag      = 2
    self.panel1.tag             = 1
    self.panel2.tag             = 2


    self.uiManageerList = {}
    self.uiManageerList[1] = {}
    self.uiManageerList[1].btn_caikuang     = self.btn_caikuang1
    self.uiManageerList[1].btn_shouhuo      = self.btn_shouhuo1
    self.uiManageerList[1].jiekuangInfo     = self.jiekuangInfo1
    self.uiManageerList[1].kaicaishijian    = self.kaicaishijian1
    self.uiManageerList[1].txt_time         = self.txt_time1
    --self.uiManageerList[1].txt_changchu     = self.txt_changchu1
    self.uiManageerList[1].bg_tips          = self.bg_tips1
    self.uiManageerList[1].panel            = self.panel1

    self.uiManageerList[2] = {}
    self.uiManageerList[2].btn_caikuang     = self.btn_caikuang2
    self.uiManageerList[2].btn_shouhuo      = self.btn_shouhuo2
    self.uiManageerList[2].jiekuangInfo     = self.jiekuangInfo2
    self.uiManageerList[2].kaicaishijian    = self.kaicaishijian2
    self.uiManageerList[2].txt_time         = self.txt_time2
    --self.uiManageerList[2].txt_changchu     = self.txt_changchu2
    self.uiManageerList[2].btn_suo          = self.btn_suo
    self.uiManageerList[2].jiesuoshuoming   = self.jiesuoshuoming
    self.uiManageerList[2].bg_tips          = self.bg_tips2
    self.uiManageerList[2].panel            = self.panel2




    local pos1 = self.btn_caikuang1:getPosition()
    local pos2 = self.btn_caikuang2:getPosition()

    self:mineAction(self.btn_caikuang1,pos1)
    self:mineAction(self.btn_caikuang2,pos2)
    self:refreshCdTime()
end

function MiningItem:setData()
    self:refresh()
end

function MiningItem:removeUI()
    self:stopeffect(miningmineEffect)
    self.super.removeUI(self)
end

-----断线重连支持方法
function MiningItem:onShow()
    self.super.onShow(self)

    self:refresh()
end


function MiningItem:refresh()
    self:drawMine(1)
    self:drawMine(2)
    self:addplayEffect()
end

function MiningItem:drawMine(index)
    local btn_caikuang  = self.uiManageerList[index].btn_caikuang
    local btn_shouhuo   = self.uiManageerList[index].btn_shouhuo
    local jiekuangInfo  = self.uiManageerList[index].jiekuangInfo
    local kaicaishijian = self.uiManageerList[index].kaicaishijian
    --local txt_changchu  = self.uiManageerList[index].txt_changchu
    local btn_suo       = self.uiManageerList[index].btn_suo
    local jiesuoshuoming= self.uiManageerList[index].jiesuoshuoming
    local bg_tips       = self.uiManageerList[index].bg_tips
    local panel         = self.uiManageerList[index].panel

    local mineralInfo   = MiningManager:getMineralDetailInfo()

    local mineData      = mineralInfo[index]

    --0:为开采 1：开采中 2.待收获
    local mineStatus    = mineData.status 
    --是否解锁
    local mineralType   = mineData.type
    --是否被打劫成功
    local isBeLoot1     = mineData.robStatus
    local level         = MainPlayer:getLevel()
    local nowtime       = MainPlayer:getNowtime()
    local startTime     = mineData.startTime
    local endTime       = mineData.endTime
    endTime             = math.ceil(endTime/1000)
    local result        = math.floor((math.sqrt(level*9.5)-10))

    btn_caikuang:setVisible(true)
    kaicaishijian:setVisible(true)
    btn_shouhuo:setVisible(true)
    bg_tips:setVisible(true)
    panel:setVisible(false)
    panel:setTouchEnabled(false)

    self:hidelightsEffect(index)
    self:hideineEffect(index)

    print("==============index ================", index)
    if mineralType ~= 0 then
        if MainPlayer:getNowtime() >= endTime and mineStatus == 1 then
            -- 采矿状态变化
            mineStatus = 2
        end

        if mineStatus == 0 then
            kaicaishijian:setVisible(false)
            btn_shouhuo:setVisible(false)
            MiningManager:setMineStauts(index, 0, 0)
            isBeLoot1 =0 
        elseif mineStatus == 1 then
            btn_caikuang:setVisible(false)
            btn_shouhuo:setVisible(false)
            self:addlightsEffect(index)
            MiningManager:setMineStauts(index, 1, mineData.endTime)
            bg_tips:setVisible(false)
            panel:setVisible(true)
            panel:setTouchEnabled(true)
        elseif mineStatus == 2 then
            btn_caikuang:setVisible(false)
            kaicaishijian:setVisible(false)
            self:showMineEffect(index, btn_shouhuo)
            MiningManager:setMineStauts(index, 2, 0)
            bg_tips:setVisible(false)
            self:showChangchu(index)
        end

        if isBeLoot1 == 0 then
            jiekuangInfo:setVisible(false)
        else
            jiekuangInfo:setVisible(true)
            self:showLootMineralInfo(jiekuangInfo,index)
        end 
        btn_shouhuo:setTextureNormal("ui_new/mining/img_ks" .. mineralType .. ".png")
        if index == 2 then
            btn_shouhuo:setTextureNormal("ui_new/mining/img_ks" .. mineralType+4 .. ".png")
        end
    end 

    self.status[index]  = mineStatus
    print("==============end ================")

    if index == 2 then
        --print("mineData = ", mineData)
        self.btn_suo:setVisible(false)
        self.bg_jiwsuosm:setVisible(false)
        if mineralType == 0 then
            --锁定
            local unlocklevel = MiningManager:getMineTwoUnlockLevel()
            btn_caikuang:setVisible(false)
            kaicaishijian:setVisible(false)
            jiekuangInfo:setVisible(false)
            btn_shouhuo:setVisible(false)
            btn_suo:setVisible(true)
            --jiesuoshuoming:setText(unlocklevel .. "级解锁")
            jiesuoshuoming:setText(stringUtils.format(localizable.common_level_unlock,unlocklevel))
        end
    end
end

function MiningItem:showChangchu(index)
    local roleMineInfo  = MiningManager:getRoleMineInfo()
    local rewardResource   = roleMineInfo.info[index].rewardResource
    -- if rewardResource == nil then
    --     return
    -- end
    local table,rewardNum = stringToTable(rewardResource,'&')
    
    print("table =",table)
    print("rewardNum =",rewardNum)
    local btn_shouhuo   = self.uiManageerList[index].btn_shouhuo

    -- local changchu1     = TFDirector:getChildByPath(btn_shouhuo, "bg_changchu")
    -- local img_tongbi1   = TFDirector:getChildByPath(changchu1, "img_tongbi")
    -- local txt_changchu1 = TFDirector:getChildByPath(changchu1, "txt_changchu")
    -- local changchu2     = TFDirector:getChildByPath(btn_shouhuo, "bg_changchu2")
    -- local img_tongbi2   = TFDirector:getChildByPath(changchu2, "img_tongbi")
    -- local txt_changchu2 = TFDirector:getChildByPath(changchu2, "txt_changchu")

    local texture = {"ui_new/common/xx_tongbi_icon.png","ui_new/common/yuanbao2.png","ui_new/smithy/intensify_stone_s.png","ui_new/common/xx_baoshi_icon.png","ui_new/common/xx_baoshi1_icon.png"}
    local bg_changchu = {"bg_changchu","bg_changchu2"}
    for i=1,2 do
        local changchu     = TFDirector:getChildByPath(btn_shouhuo, bg_changchu[i])
        local img_tongbi   = TFDirector:getChildByPath(changchu, "img_tongbi")
        local txt_changchu = TFDirector:getChildByPath(changchu, "txt_changchu")
        changchu:setVisible(false)
        if i<= rewardNum then
            changchu:setVisible(true)
            local rewardtable = stringToTable(table[i],',')
            txt_changchu:setText(rewardtable[3])

            local data = {}
            data.type = tonumber(rewardtable[1])
            data.itemId = tonumber(rewardtable[2])
            data.number = tonumber(rewardtable[3])
            
            if data.type == EnumDropType.COIN then
                img_tongbi:setTexture(texture[1])
            elseif data.type == EnumDropType.SYCEE then
                img_tongbi:setTexture(texture[2])
            elseif data.type == EnumDropType.GOODS then
                if rewardtable[2] == "30021" then
                    img_tongbi:setTexture(texture[3]) 
                elseif rewardtable[2] == "40039" then
                    img_tongbi:setTexture(texture[4]) 
                elseif rewardtable[2] == "40040" then
                    img_tongbi:setTexture(texture[5]) 
                end
            end
        end
    end
end

function MiningItem:drawCdTime(index)
    local function showCutDownString( times )
        local str = nil
        -- local month = math.floor(times/3600)
        -- local min = math.floor(times%3600/60)
        -- local sec = times%60

        -- str = string.format("%02d",hour)..":"..string.format("%02d",min)..":"..string.format("%02d",sec)

        local hour = math.floor(times/3600)
        local min = math.floor((times - hour * 3600) / 60)
        local sec = math.fmod(times, 60)

        str = string.format("%02d:%02d:%02d", hour, min, sec)
        return str
    end

    local mineralInfo   = MiningManager:getMineralDetailInfo()
    local mineData      = mineralInfo[index]
    --0:为开采 1：开采中 2.待收获
    local mineStatus    = mineData.status
    if mineStatus ~= 1 then
        return
    end

    local txt_time = self.uiManageerList[index].txt_time
    local endTime  = math.ceil(mineData.endTime/1000)
    local gapTime  = endTime - MainPlayer:getNowtime()


    -- print("index = ", index)
    -- print("MainPlayer:getNowtime() = ", MainPlayer:getNowtime())
    -- print("endTime = ", endTime)
    --print("gapTime = ", gapTime)

    if gapTime <= 0 then
         gapTime = 0
        txt_time:setText(showCutDownString(gapTime))
        if self.status[index] == 1 then
            MiningManager:requestMiningInfo()
            self.status[index] = 2
        end
        self:drawMine(index)
    else
        txt_time:setText(showCutDownString(gapTime))
    end
end

function MiningItem:refreshCdTime()
    --公告框
    local function update(delta)
        -- print("refreshCdTime ---- ")
        self:drawCdTime(1)
        self:drawCdTime(2)
    end

    if self.timeId then
        return
    end

    self.timeId = TFDirector:addTimer(1000, -1, nil, update)
    self:drawCdTime(1) 
    self:drawCdTime(2)
end

function MiningItem:stopTimer()
    if self.timeId then
        TFDirector:removeTimer(self.timeId)
        self.timeId = nil
    end
end

function MiningItem:registerEvents()
    self.super.registerEvents(self)

    self.btn_caikuang1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCaiKuangBack))
    self.btn_caikuang2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCaiKuangBack))
    self.btn_shouhuo1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShouhuoCallBack))
    self.btn_shouhuo2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShouhuoCallBack)) 
    self.btn_suo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJiesuoCallBack))
    self.panel1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEffectTouchEndedHandle))
    self.panel2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEffectTouchEndedHandle))
end

function MiningItem:removeEvents()
    if miningTimer then
        TFDirector:removeTimer(miningTimer)
        miningTimer = nil
    end
    self:stopTimer()
    self.super.removeEvents(self)
end

function MiningItem:dispose()
    self.super.dispose(self)
end



--
function MiningItem:showLootMineralInfo(panel,index)
    local bg_roleinfo   = TFDirector:getChildByPath(panel, "bg_roleinfo")
    local txt_name      = TFDirector:getChildByPath(bg_roleinfo, "txt_name")
    local bg_zhanli     = TFDirector:getChildByPath(bg_roleinfo, "bg_zhanli")
    local txt_zhandouli = TFDirector:getChildByPath(bg_zhanli, "txt_zhandouli")
    local bg_touxiang   = TFDirector:getChildByPath(bg_roleinfo, "bg_touxiang")
    local img_head      = TFDirector:getChildByPath(bg_touxiang, "img_head")
    local bg_huifang    = TFDirector:getChildByPath(panel, "bg_huifang")
    local btn_huifang   = TFDirector:getChildByPath(bg_huifang, "btn_huifang")

    -- local bg_jiede      = TFDirector:getChildByPath(panel, "bg_jiede")
    -- local img_jd        = TFDirector:getChildByPath(bg_jiede, "img_jd")
    -- local img_tongbi    = TFDirector:getChildByPath(bg_jiede, "img_tongbi")
    -- local txt_tongbi    = TFDirector:getChildByPath(bg_jiede, "txt_tongbi")
    -- local img_tongbi    = TFDirector:getChildByPath(bg_jiede, "img_tongbi")
    -- local txt_tongbi    = TFDirector:getChildByPath(bg_jiede, "txt_tongbi")
    local bg_jiede2     = TFDirector:getChildByPath(panel, "bg_jiede2")
    bg_jiede2:setVisible(false)

    local roleMineInfo  = MiningManager:getRoleMineInfo()
    local rabroleinfo   = roleMineInfo.info[index].robInfo
    --local robCoin       = roleMineInfo.info[index].robCoin
    local robResource   = roleMineInfo.info[index].robResource
    local table,Resourcenum = stringToTable(robResource,'&')
    if rabroleinfo ~= nil then
        if rabroleinfo.icon == nil or rabroleinfo.icon <= 0 then                --pck change head icon and head icon frame
            rabroleinfo.icon = rabroleinfo.profession
        else
            Public:addInfoListen(img_head,true,1,rabroleinfo.playerId)
        end
        local roleIcon = RoleData:objectByID(rabroleinfo.icon) 
        img_head:setTexture(roleIcon:getIconPath())
        Public:addFrameImg(img_head,rabroleinfo.headPicFrame)                  --end
        txt_name:setText(rabroleinfo.name)
        txt_zhandouli:setText(rabroleinfo.power)
        btn_huifang:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onHuifangCallBack))
        btn_huifang.logic = self
        btn_huifang.tag = 100+index
        btn_huifang.reportId = roleMineInfo.info[index].robInfo.battleId
        bg_roleinfo:setVisible(true)
        btn_huifang:setVisible(true)
    else
        if table[2] ~= 0 then
            bg_roleinfo:setVisible(false)
            btn_huifang:setVisible(false)
        end
    end

    local jiede = {"bg_jiede","bg_jiede2"}
    local texture = {"ui_new/common/xx_tongbi_icon.png","ui_new/common/yuanbao2.png","ui_new/smithy/intensify_stone_s.png","ui_new/common/xx_baoshi_icon.png","ui_new/common/xx_baoshi1_icon.png"}
    for i=1,Resourcenum do
        local bg_jiede      = TFDirector:getChildByPath(panel, jiede[i])
        local img_jd        = TFDirector:getChildByPath(bg_jiede, "img_jd")
        local img_tongbi    = TFDirector:getChildByPath(bg_jiede, "img_tongbi")
        local txt_tongbi    = TFDirector:getChildByPath(bg_jiede, "txt_tongbi")
        bg_jiede:setVisible(true)
        local resourcetable = stringToTable(table[i],',')
               
        local data = {}
        data.type = tonumber(resourcetable[1])
        data.itemId = tonumber(resourcetable[2])
        data.number = tonumber(resourcetable[3])
        local reward = BaseDataManager:getReward(data)

        if data.type == EnumDropType.COIN then
                img_tongbi:setTexture(texture[1])
        elseif data.type == EnumDropType.SYCEE then
                img_tongbi:setTexture(texture[2])
        elseif data.type == EnumDropType.GOODS then
            if resourcetable[2] == "30021" then
                img_tongbi:setTexture(texture[3]) 
            elseif resourcetable[2] == "40039" then
                img_tongbi:setTexture(texture[4]) 
            elseif resourcetable[2] == "40040" then
                img_tongbi:setTexture(texture[5]) 
            end
        end
        txt_tongbi:setText(resourcetable[3])
    end   
end


--采矿按钮回调（进入选矿界面）
function MiningItem.onCaiKuangBack(sender)
    local self = sender.logic
    local index  = sender.tag

    local mineralInfo   = MiningManager:getMineralDetailInfo()
    local mineData      = mineralInfo[index]
    --0:为开采 1：开采中 2.待收获
    local mineStatus    = mineData.status 

    if mineStatus == 0 then
        local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mining.ChooseMineralLayer")
        layer:loadData(index)
        AlertManager:show()
    end
end

--收获按钮回调
function MiningItem.onShouhuoCallBack(sender)
    local self = sender.logic
    local tag  = sender.tag
    
    MiningManager:requestGetMineReward(tag)
end

--回放按钮回调
function MiningItem.onHuifangCallBack(sender)
    local self  = sender.logic
    local tag   = sender.tag
    local reportId = sender.reportId

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


function MiningItem:addlightsEffect(index)
    if self.effectList == nil then
        self.effectList = {}
    end

    if self.effectList[index] == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/doorlight.xml")
        self.effectList[index] = TFArmature:create("doorlight_anim")
        if self.effectList[index] == nil then
            return
        end
        self.effectList[index]:setZOrder(100)
        self.effectList[index]:setAnimationFps(GameConfig.ANIM_FPS)
        self.bg:addChild(self.effectList[index],10)
        self.effectList[index]:setPosition(ccp(570,320)) 
    end
    
    self.effectList[index]:playByIndex(index-1, -1, -1, 1)    
    if self.effectList[index] then
        self.effectList[index]:setVisible(true)
    end
end

function MiningItem:hidelightsEffect(index)
    if self.effectList == nil then
        return
    end

    if self.effectList[index] then
        self.effectList[index]:setVisible(false)
    end
end

function MiningItem:showMineEffect(index, node)
    if self.effectMineList == nil then
        self.effectMineList = {}
    end

    if self.effectMineList[index] == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/level_up_light.xml")
        self.effectMineList[index] = TFArmature:create("level_up_light_anim")
        if self.effectMineList[index] == nil then
            return
        end
        self.effectMineList[index]:setZOrder(100)
        self.effectMineList[index]:setAnimationFps(GameConfig.ANIM_FPS)
        node:getParent():addChild(self.effectMineList[index],1)
        self.effectMineList[index]:setPosition(node:getPosition())
        self.effectMineList[index]:setScale(0.3)
    end
    self.effectMineList[index]:playByIndex(0, -1, -1, 1)
    
    if self.effectMineList[index] then
        self.effectMineList[index]:setVisible(true)
    end
end

function MiningItem:hideineEffect(index)
    if self.effectMineList == nil then
        return
    end

    if self.effectMineList[index] then
        self.effectMineList[index]:setVisible(false)
    end
end

function MiningItem:addplayEffect()
    local enterpage = MiningManager:getPage()
    print("enterpage = ",enterpage)
    if enterpage ~= 2 then
        return
    end
    self:stopeffect(miningmineEffect)
    if self.status[1] == 1 or self.status[2] == 1 then
        self:playcaikuangEffect()
        self:LoopplayEffect(2)
    else
        if self.status[1] == 0 or self.status == 0 then
            self:playcaikuangEffect()
        end
    end
end

function MiningItem:LoopplayEffect(time)
    if miningTimer then
        return
    end
    function timerEnd()
        if miningTimer then
            TFDirector:removeTimer(miningTimer)
            miningTimer = nil
        end 
        self:playcaikuangEffect()
        self:LoopplayEffect(2)
    end
    miningTimer = TFDirector:addTimer(time*1000, -1, nil,timerEnd) 
end

function MiningItem:stopeffect(effect)
    if effect ~= nil then
        TFAudio.stopEffect(effect)
        effect = nil
    end
end

function MiningItem:playcaikuangEffect()
    local toplayer = PlayerGuideManager:getTopLayer()
    --print("toplayer==",toplayer.__cname)
    if toplayer.__cname == "MiningLayer" then
        self:stopeffect(miningmineEffect)
        miningmineEffect = play_daicaikuang()
    end
end

function MiningItem.onEffectTouchEndedHandle(sender)
    local tag = sender.tag
    print("tag = ",tag)
    MiningManager:showOwnMiningformation(tag)
end

return MiningItem