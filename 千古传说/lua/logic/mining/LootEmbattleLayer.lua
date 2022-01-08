--[[
******劫矿页*******
    -- by yao
    -- 2016/1/12
]]

local LootEmbattleLayer = class("LootEmbattleLayer", BaseLayer)

function LootEmbattleLayer:ctor(data)
    self.super.ctor(self,data)
    self.rolebtn        = {}        --己方人物按钮
    self.armyMinebtn    = {}        --敌方采矿人物按钮
    self.armyprotectBtn = {}        --地方护矿人物按钮
    self.ownpanel       = nil       --己方人物的panel
    self.caikuangpanel  = nil       --敌方采矿人物的panel
    self.hukuangpanel   = nil       --敌方护矿人物的panel
    self.xuetiaodi      = {}        --血条底
    self.xuetiao        = {}        --血条
    self.wangpic        = {}        --亡字
    self.panelPos       = {}        --敌方采矿和护矿的界面位置
    self.ismoveEnd      = false
    self.btn_challenge2 = nil
    self.btn_challenge3 = nil
    self.timeStr        = nil       --倒计时文字
    self.twoMinuteTimer = nil
    self.tenMinuteTime  = nil
    self.istenMinute    = false     --是否达到十分钟
    self.IsOnshow       = true      -- 是否运行了onshow
    self.isbeatRoleNum  = 0         -- 击败人物次数
    --self.challegeTime   = 0        --
    self.isResetBlood   = false     --是否重置血量
    self.isRobSuccess   = false     --是否打劫成功
    self.armyRoleStatu  = {1,1}     --1,存活 0,死亡
    self.challengerole  = 0         --挑战的人物是采矿者还是护矿者（1,采矿 2,护矿）
    self.armyType       = 1         --哪个界面显示在上面1.采矿 2.护矿
    self:init("lua.uiconfig_mango_new.mining.miningArmyVSLayer")
end

function LootEmbattleLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close      = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_buzhen     = TFDirector:getChildByPath(ui, "btn_buzhen")
    self.btn_reset      = TFDirector:getChildByPath(ui, "btn_reset")
    self.btn_qiehuan    = TFDirector:getChildByPath(ui, "btn_qiehuan")
    self.txt_wenben     = TFDirector:getChildByPath(ui, "txt_wenben")
    self.Img_vs2        = TFDirector:getChildByPath(ui, "Img_vs2")
    self.Img_vs         = TFDirector:getChildByPath(ui, "Img_vs")
    self.txt_coss       = TFDirector:getChildByPath(ui, "txt_coss")

    self.btn_qiehuan.logic = self
    self.btn_qiehuan:setZOrder(10)
    self.btn_reset.logic = self
    self.btn_close.logic = self

    for k=1,3 do
        local panel = TFDirector:getChildByPath(ui, "Panel_" .. k)
        local btn = {}
        for i=1,9 do
            local btnName = "panel_item" .. i;
            btn[i] = TFDirector:getChildByPath(panel, btnName);
            btnName = "btn_icon"..i;
            btn[i].bg = TFDirector:getChildByPath(panel, btnName);
            btn[i].bg:setVisible(false);
            btn[i].icon = TFDirector:getChildByPath(btn[i].bg ,"img_touxiang");
            btn[i].icon:setVisible(false);
            btn[i].img_zhiye = TFDirector:getChildByPath(btn[i], "img_zhiye");
            btn[i].img_zhiye:setVisible(false);
            btn[i].quality = TFDirector:getChildByPath(panel, btnName);

            --血条底
            local xtd = TFImage:create("ui_new/bloodybattle/xz_xueliangdirendi.png")
            xtd:setPosition(ccp(5,-35))
            btn[i].bg:addChild(xtd,1)
            btn[i].xuetiaodi = xtd
            --血条
            local xt = TFLoadingBar:create()
            xt:setTexture("ui_new/bloodybattle/xz_xueliangdiren.png")
            xt:setPosition(ccp(10,-35))
            btn[i].bg:addChild(xt,3)
            btn[i].xuetiao = xt
            --亡字
            local wz = TFImage:create("ui_new/bloodybattle/xz_wang.png")
            wz:setPosition(ccp(20,20))
            btn[i].bg:addChild(wz,3)
            btn[i].wang = wz

            btn[i].bg.posIndex = i
            btn[i].bg.hasRole = true
        end

        if k == 1 then
            self.ownpanel = panel
            self.rolebtn = btn
            local txt_name  = TFDirector:getChildByPath(panel, "txt_name")
            local txt_zhanli= TFDirector:getChildByPath(panel, "txt_zhanli")
        elseif k == 2 then
            --护矿
            self.hukuangpanel = panel
            self.armyprotectBtn = btn
            self.panelPos[1] = panel:getPosition()
            self.btn_challenge2 = TFDirector:getChildByPath(panel, "btn_challenge")
            self.btn_challenge2.logic = self
            self.btn_challenge2.tag = 2
            self.btn_challenge2:setTouchEnabled(false)
            self.btn_challenge2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChallengeCallBack))
            local txt_name  = TFDirector:getChildByPath(panel, "txt_name")
            local txt_zhanli= TFDirector:getChildByPath(panel, "txt_zhanli")
        elseif k == 3 then
            --采矿
            self.caikuangpanel = panel
            self.armyMinebtn = btn
            self.panelPos[2] = panel:getPosition()
            self.btn_challenge3 = TFDirector:getChildByPath(panel, "btn_challenge")
            self.btn_challenge3.logic = self
            self.btn_challenge3.tag = 1
            self.btn_challenge3:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChallengeCallBack))
            local txt_name  = TFDirector:getChildByPath(panel, "txt_name")
            local txt_zhanli= TFDirector:getChildByPath(panel, "txt_zhanli")
        end
    end

    self.Img_vs:setVisible(true)
    self.Img_vs2:setVisible(true)
    --self.txt_wenben:setText("战斗倒计时")
    self.txt_wenben:setText(localizable.LootEmBattleLayer_fight_time)
    self.txt_wenben:setVisible(true)
    self.txt_wenben:setPosition(ccp(20,-45))
    self.timeStr = TFLabel:create()
    self.timeStr:setPosition(ccp(-23, -30))
    self.timeStr:setFontSize(20)
    self.txt_wenben:addChild(self.timeStr)
    self.timeStr:setColor(ccc3(255,0,0))

    self:showOwnUIData()
    self:showArmyUIData()
    self:countdownTime()
    self:showBtnUIdata()
    self:showChallengeTimes()
end

function LootEmbattleLayer:setData()
end

function LootEmbattleLayer:removeUI()
    MiningManager:setIsOpenBuzhenLayer(false)
    if self.twoMinuteTimer then
        TFDirector:removeTimer(self.twoMinuteTimer)
        self.twoMinuteTimer = nil
    end
    if self.tenMinuteTime then
        TFDirector:removeTimer(self.tenMinuteTime)
        self.tenMinuteTime = nil
    end
    self.super.removeUI(self)
end

-----断线重连支持方法
function LootEmbattleLayer:onShow()
    self.super.onShow(self)

    if Public:currentScene().__cname  ~= 'HomeScene' then
        return
    end

    if self.IsOnshow == false then
        self.IsOnshow = true
        if self.istenMinute == true then
            self.istenMinute = false
            if self.tenMinuteTime then
                TFDirector:removeTimer(self.tenMinuteTime)
                self.tenMinuteTime = nil
            end
            HoushanManager:setTenMinuteBackBossLayer(self) 
        end
        
        --print("tiao zhan wan fan hui") 
        local holdGoods = BagManager:getItemById(30067)
        local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.MINE)
        local challengetime = challengeInfo.currentValue 
        if self.isRobSuccess then
            MiningManager:requestFreshMineList()
            AlertManager:closeAllToLayer(self)
        else
            local mineList      = MiningManager:getFreshMineListResult()
            local info          = MiningManager:getLootPlayerIndexAndMine()
            local endtime       = math.ceil(mineList[info.index].endTime/1000)
            local nowtime       = MainPlayer:getNowtime()
            if endtime - nowtime < 600 then
                local str = localizable.Mining_Mining_Complete
                toastMessage(str)
                MiningManager:requestFreshMineList()
                AlertManager:closeAllToLayer(self)
                return
            end
            local info = MiningManager:getLootPlayerIndexAndMine()
            MiningManager:requestLockPlayerMine(info.minePlayerId,info.mineIndex)
        end 
    end
end

function LootEmbattleLayer:registerEvents()
    self.super.registerEvents(self)  
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseCallBack))
    self.btn_buzhen:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBuzhenCallBack))
    self.btn_reset:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onResetCallBack))
    self.btn_qiehuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQiehuanCallBack))

    self.updateGenerralCallBack = function(event)
        self:showOwnUIData()
    end

    TFDirector:addMEGlobalListener(StrategyManager.UPDATE_GENERRAL_LIST ,self.updateGenerralCallBack ) ;
    self.recvReplayCallBack = function(event)
        self:showOwnUIData()
        self:showArmyUIData()
        self:showBtnUIdata()
    end
    TFDirector:addMEGlobalListener(MiningManager.EVENT_GET_REPLAY_RESULT ,self.recvReplayCallBack ) ;

    self.closeLimitCallBack = function(event)
        --print("event.data222",event.data)
        if self.tenMinuteTime then
            TFDirector:removeTimer(self.tenMinuteTime)
            self.tenMinuteTime = nil
        end
        HoushanManager:setTenSecondBackBossLayer()
        self:showOwnUIData()
        self:showArmyUIData()
        self:showBtnUIdata()
    end;
    TFDirector:addMEGlobalListener(FightManager.FactionBossFightLeave ,self.closeLimitCallBack )

    self.resetTenMinuteTime = function(event)
        --print("event.data",event.data)
        if self.tenMinuteTime then
            TFDirector:removeTimer(self.tenMinuteTime)
            self.tenMinuteTime = nil
        end
        if event.data[1][1] ~= 0 then
            self.armyRoleStatu[self.challengerole] = 0
            self:qieHuanAction()
        end
        self:countdownTime()
        self:showChallengeTimes()
    end;
    TFDirector:addMEGlobalListener(FightManager.FactionBossFightResult ,self.resetTenMinuteTime )

    self.resetownBlood = function(event)
        MiningManager:resetOwnBlood()
        self:showOwnUIData()
        self:showChallengeTimes()
    end;
    TFDirector:addMEGlobalListener(MiningManager.EVENT_UPDATE_CHONGZHI ,self.resetownBlood )

    self.runsuccess = function(event)
        --print("da jie cheng gong hui diao ")
        self.isRobSuccess = true
    end;
    TFDirector:addMEGlobalListener(MiningManager.EVENT_RUBMINE_SUCCESS ,self.runsuccess)

    self.updateChallengeTime = function(event)
        self:showChallengeTimes()
    end;
    TFDirector:addMEGlobalListener(BagManager.ITEMBATCH_USED_RESULT ,self.updateChallengeTime)
end

function LootEmbattleLayer:removeEvents()
    self.btn_close:removeMEListener(TFWIDGET_CLICK)
    self.btn_buzhen:removeMEListener(TFWIDGET_CLICK)
    self.btn_reset:removeMEListener(TFWIDGET_CLICK)
    self.btn_qiehuan:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(MiningManager.EVENT_UPDATE_CHONGZHI ,self.resetownBlood)
    self.resetownBlood = nil
    TFDirector:removeMEGlobalListener(MiningManager.EVENT_GET_REPLAY_RESULT, self.recvReplayCallBack );
    self.recvReplayCallBack = nil
    TFDirector:removeMEGlobalListener(StrategyManager.UPDATE_GENERRAL_LIST, self.updateGenerralCallBack );
    self.updateGenerralCallBack = nil
    TFDirector:removeMEGlobalListener(FightManager.FactionBossFightLeave ,self.closeLimitCallBack)
    self.closeLimitCallBack = nil
    TFDirector:removeMEGlobalListener(FightManager.FactionBossFightResult ,self.resetTenMinuteTime)
    self.resetTenMinuteTime = nil
    TFDirector:removeMEGlobalListener(MiningManager.EVENT_RUBMINE_SUCCESS ,self.runsuccess)
    self.runsuccess = nil
    TFDirector:removeMEGlobalListener(BagManager.ITEMBATCH_USED_RESULT ,self.updateChallengeTime)
    self.updateChallengeTime = nil

    self.super.removeEvents(self)
end

function LootEmbattleLayer:dispose()
    self.super.dispose(self)
end

function LootEmbattleLayer.onCloseCallBack(sender)
    local self = sender.logic
    if self.armyRoleStatu[1] == 0 and self.armyRoleStatu[2] == 1 then
        --local str = TFLanguageManager:getString(ErrorCodeData.Mining_Reset)
        --local str = "还有护矿者未击败，是否继续退出？"
        local str = localizable.LootEmBattleLayer_tips1
        self:openCell2(str)
    elseif self.armyRoleStatu[1] == 1 and self.armyRoleStatu[2] == 0 then
        --local str = TFLanguageManager:getString(ErrorCodeData.Mining_Reset)
        --local str = "还有采矿者未击败，是否继续退出？"
        local str =localizable.LootEmBattleLayer_tips2
        self:openCell2(str)
    else
        AlertManager:close()
        local info = MiningManager:getLootPlayerIndexAndMine()
        MiningManager:requestUnlockPlayerMine(info.minePlayerId,info.mineIndex)
    end
end

function LootEmbattleLayer.onBuzhenCallBack(sender)
    -- CardRoleManager:openRoleList(false);
    MiningManager:EnterMainArmy()
end

function LootEmbattleLayer.onResetCallBack(sender) 
    local self = sender.logic
    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.MINE)
    local challengetime = challengeInfo.currentValue
    local info = MiningManager:getLootPlayerIndexAndMine()
    --print("challengetime:",challengetime)
    --print("totalBlood:",totalBlood)
    local isMaxBlood = MiningManager:getOwnBloodIsMax()
    if isMaxBlood then
        --toastMessage("满血时不能重置")
        toastMessage(localizable.LootEmBattleLayer_not_reset)
    else
        if challengetime <= 0 then
            local holdGoods = BagManager:getItemById(30067)
            if not holdGoods then
                --次数不足
                toastMessage(localizable.Mining_No_Chance)
            else
                VipRuleManager:showMineTimesLayer()
            end            
        else
            -- local str = TFLanguageManager:getString(ErrorCodeData.Mining_Reset)
            --local str = "是否消耗1次打劫次数重置打劫状态"
            self:openCell(localizable.Mining_Reset,info.mineIndex,info.minePlayerId)
        end
    end
    
end

function LootEmbattleLayer.onQiehuanCallBack(sender)
    local self = sender.logic
    self:qieHuanAction()
end

function LootEmbattleLayer.onChallengeCallBack(sender)
    local self      = sender.logic
    local tag       = sender.tag        --1采矿，2护矿
    local info      = MiningManager:getLootPlayerIndexAndMine()
    --print("info == :",info)
    
    local totalBlood    = MiningManager:getOwnTotalBlood()
    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.MINE)
    local challengetime = challengeInfo.currentValue
    local nowtime       = MainPlayer:getNowtime()
    local mineList      = MiningManager:getFreshMineListResult()
    local endtime       = math.ceil(mineList[info.index].endTime/1000)
    self.challengerole  = tag
    --print("armyId:",info.minePlayerId)
    --print("info.mineIndex:",info.mineIndex)
    --print("tag:",tag)

    if totalBlood == 0 then
        if challengetime > 0 then
            -- local str = TFLanguageManager:getString(ErrorCodeData.Mining_Dead)
            toastMessage(localizable.Mining_Dead)
        else
            -- 判断死亡角色和总角色个数
            local totalRoleNum = CardRoleManager:getRoleNum()
            local deadRoleNum  = MiningManager:getMyDeadRoleNum()
            -- 全部死亡
            if totalRoleNum <= deadRoleNum then
                VipRuleManager:showMineTimesLayer()
                return
            else
                -- local str = TFLanguageManager:getString(ErrorCodeData.Mining_Dead)
                toastMessage(localizable.Mining_Dead)          
            end
        end   
        return
    else
        if endtime - nowtime > 600 then
            self.isRobSuccess = false
            MiningManager:requestChallengeMine(info.minePlayerId,info.mineIndex,tag)
        else    
            -- local str = TFLanguageManager:getString(ErrorCodeData.Mining_Mining_Complete)
            toastMessage(localizable.Mining_Mining_Complete)
            return
        end  
    end
    
    if self.twoMinuteTimer then
        TFDirector:removeTimer(self.twoMinuteTimer)
        self.twoMinuteTimer = nil
    end
    if self.tenMinuteTime then
        TFDirector:removeTimer(self.tenMinuteTime)
        self.tenMinuteTime = nil
    end
    self:tenMinuteTimeLimite()
    self.IsOnshow = false
end

function LootEmbattleLayer.cellClickHandle(sender) 
    local self = sender.logic;
    local role = sender.role;
    if sender.isClick == false then
        return
    end
    --print("role.level:",role.level)
    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,role.level)
end

function LootEmbattleLayer:showOwnUIData()
    local mineFormationInfo = MiningManager:getMineFormationInfo()
    local myInfos = mineFormationInfo.myInfos
    local btn = self.rolebtn
    for i=1,9 do
        local role = StrategyManager:getRoleByIndex(i)
        if role ~= nil then
            btn[i].icon:setVisible(true);
            btn[i].icon:setTexture(role:getHeadPath());
            btn[i].icon:setFlipX(true)
            btn[i].bg:setVisible(true);
            btn[i].bg.role = role;
            btn[i].bg.logic = self;
            btn[i].bg.gmId = role.gmId
            btn[i].bg.posIndex = i
            btn[i].bg.hasRole = true
            btn[i].bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);
            btn[i].bg:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1);
            btn[i].bg:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle);
            btn[i].bg:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle);
            btn[i].img_zhiye:setVisible(true);
            btn[i].img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");
            btn[i].img_zhiye:setZOrder(2)
            btn[i].img_zhiye:setPosition(ccp(-35,-30))
            btn[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality))
            
            role.role_id = role.id

            --print("role:",role)
            local maxHp = role.totalAttribute:getAttribute(1)
            --print("maxHp:",maxHp)
            local curHp = MiningManager:getOwnBloodByPos(role.gmId)
            --print("curHp:",curHp)  
            if curHp == nil then
                btn[i].xuetiao:setPercent(100)
                btn[i].wang:setVisible(false)
                btn[i].bg:setGrayEnabled(false)
            elseif curHp == 0 then
                btn[i].bg:setGrayEnabled(true)
                btn[i].xuetiao:setPercent(0)
                btn[i].wang:setVisible(true)
                btn[i].wang:setGrayEnabled(false)
                btn[i].bg:setTouchEnabled(false)
            else
                btn[i].xuetiao:setPercent(curHp/maxHp*100)
                btn[i].wang:setVisible(false)
                btn[i].bg:setGrayEnabled(false)  
                btn[i].bg:setTouchEnabled(true)
            end
            Public:addLianTiEffect(btn[i].icon,role:getMaxLianTiQua(),true)
        else
            btn[i].img_zhiye:setVisible(false);  
            btn[i].icon:setVisible(false);
            btn[i].bg:setVisible(false);
            Public:addLianTiEffect(btn[i].icon,0,false)
        end
    end
    local name = TFDirector:getChildByPath(self.ownpanel, "txt_name")
    local zhanli = TFDirector:getChildByPath(self.ownpanel, "txt_zhanli")
    name:setText(MainPlayer:getPlayerName())
    zhanli:setText(MainPlayer:getPower())

    local img_headIcon = TFDirector:getChildByPath(self.ownpanel, "img_role")         --pck change head icon and head icon frame
    img_headIcon:setFlipX(true)
    img_headIcon:setTexture(MainPlayer:getIconPath())
    Public:addFrameImg(img_headIcon,MainPlayer:getHeadPicFrameId())                   --end
end

function LootEmbattleLayer:showArmyUIData()    
    for k=1,2 do
        local states = {}
        local btn = {}
        local npc = nil 
        local roleId = {}
        local roleInfo = nil
        --人物的详细信息
        local roledetailInfo = MiningManager:getDetailInfoByIndex(k)
        local armyInfo = MiningManager:getOtherPlayerInfoByIndex(k)

        if k == 1 then
            btn = self.armyMinebtn
            local name = TFDirector:getChildByPath(self.caikuangpanel, "txt_name")
            local zhanli = TFDirector:getChildByPath(self.caikuangpanel, "txt_zhanli")
            name:setText(armyInfo.details.name)
            zhanli:setText(armyInfo.details.power)    

            local img_headIcon = TFDirector:getChildByPath(self.caikuangpanel, "img_role")            --pck change head icon and head icon frame
            local roleConfig = RoleData:objectByID(armyInfo.details.icon)
            img_headIcon:setTexture(roleConfig:getIconPath())
            Public:addFrameImg(img_headIcon,armyInfo.details.headPicFrame)                           --end   
            Public:addInfoListen(img_headIcon,true,2,armyInfo.details.playerId)
        elseif k == 2 then
            btn = self.armyprotectBtn
            if armyInfo ~= nil then
                self.hukuangpanel:setVisible(true)
                self.btn_qiehuan:setVisible(true)
                local name = TFDirector:getChildByPath(self.hukuangpanel, "txt_name")
                local zhanli = TFDirector:getChildByPath(self.hukuangpanel, "txt_zhanli")
                name:setText(armyInfo.details.name)
                zhanli:setText(armyInfo.details.power)

                local img_headIcon = TFDirector:getChildByPath(self.hukuangpanel, "img_role")            --pck change head icon and head icon frame
                local roleConfig = RoleData:objectByID(armyInfo.details.icon)
                img_headIcon:setTexture(roleConfig:getIconPath())
                Public:addFrameImg(img_headIcon,armyInfo.details.headPicFrame)                          --end
                Public:addInfoListen(img_headIcon,true,2,armyInfo.details.playerId)
            else
                self.hukuangpanel:setVisible(false)
                self.btn_qiehuan:setVisible(false)
                self.btn_challenge2:setTouchEnabled(true)
            end
        end
        
        for i=1,9 do  
            if armyInfo == nil then
                roleInfo = nil
            else
                roleInfo = self:getroleInfoByIndex(armyInfo.details,i)
            end 
            if roleInfo ~= nil then
                --print("i:",i)
                local roleparatInfo = MiningManager:getMineParatInfoByPos(k,i)
                --print("roleparatInfo",roleparatInfo)
                roleId[i] = roleInfo.id
                local quality = roleInfo.quality
                local role = RoleData:objectByID(roleId[i])
                btn[i].icon:setVisible(true);
                btn[i].icon:setTexture(role:getHeadPath());
                btn[i].bg:setVisible(true);
                btn[i].bg.role  = role
                btn[i].bg.logic = self
                btn[i].bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);
                btn[i].img_zhiye:setVisible(true);
                btn[i].img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");
                btn[i].img_zhiye:setZOrder(2)
                btn[i].img_zhiye:setPosition(ccp(-35,-30))
                btn[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(quality))
                role.role_id = role.id
                role.level = roleInfo.level

                local currHp = roleparatInfo.currHp
                local maxHp = roleparatInfo.maxHp
                if currHp == 0 then
                    btn[i].bg:setTouchEnabled(false)
                    btn[i].bg:setGrayEnabled(true)
                    btn[i].xuetiao:setPercent(0)
                    btn[i].wang:setVisible(true)
                    btn[i].wang:setGrayEnabled(false) 
                else
                    btn[i].xuetiao:setPercent(currHp/maxHp*100)
                    btn[i].wang:setVisible(false)
                    btn[i].bg:setGrayEnabled(false)
                    btn[i].bg:setTouchEnabled(true)
                    if self.armyType == k then
                        btn[i].bg:setTouchEnabled(true)
                    else
                        btn[i].bg:setTouchEnabled(false)
                    end
                end
                Public:addLianTiEffect(btn[i].icon,roleInfo.forgingQuality,true)
            else
                btn[i].img_zhiye:setVisible(false);  
                btn[i].icon:setVisible(false);
                btn[i].bg:setVisible(false);
                Public:addLianTiEffect(btn[i].icon,0,false)
            end
        end
    end
end

function LootEmbattleLayer:countdownTime()
    if self.twoMinuteTimer ~= nil then
        return
    end
    local cutDownTime = 120
    local function showCutDownString( times )
        local str = nil
        local month = math.floor(times/3600)
        local min = math.floor(times%3600/60)
        local sec = times%60
        str = string.format("%02d",month)..":"..string.format("%02d",min)..":"..string.format("%02d",sec)     
        return str
    end
    local timeStr = showCutDownString( cutDownTime )
    self.timeStr:setText(timeStr)
    self.twoMinuteTimer = TFDirector:addTimer(1000, -1, nil, 
        function () 
        if cutDownTime <= 0 then
            if self.twoMinuteTimer then
                TFDirector:removeTimer(self.twoMinuteTimer)
                self.twoMinuteTimer = nil
            end
            self.IsOnshow = true
            local info = MiningManager:getLootPlayerIndexAndMine()
            MiningManager:requestUnlockPlayerMine(info.minePlayerId,info.mineIndex)
            AlertManager:closeAllToLayer(self)
            HoushanManager:setTwoMinuteBackBossLayer(self)
        else
            cutDownTime = cutDownTime - 1
            local timeStr = showCutDownString( cutDownTime )
            self.timeStr:setText(timeStr)
        end
    end) 
end

function LootEmbattleLayer:tenMinuteTimeLimite()
    if self.tenMinuteTime then
        return
    end
    local cutDownTime = 600
    self.tenMinuteTime = TFDirector:addTimer(1000, -1, nil, 
        function () 
        if cutDownTime <= 0 then
            if self.tenMinuteTime then
                TFDirector:removeTimer(self.tenMinuteTime)
                self.tenMinuteTime = nil
            end
            self.istenMinute = true
            TFDirector:dispatchGlobalEventWith(FightManager.LeaveFightCommand, {})
        else
            cutDownTime = cutDownTime - 1
        end
    end)
end

--获得人物详细信息
function LootEmbattleLayer:getroleInfoByIndex(roledetailInfo,index)
    local roleInfo = nil
    for m,n in pairs(roledetailInfo.warside) do
        if n.warIndex+1 == index then
            roleInfo = n
        end
    end
    return roleInfo
end

--提示(重置)
function LootEmbattleLayer:openCell(str,mineIndex,minePlayerId)
    CommonManager:showOperateSureLayer(
        function()
            MiningManager:requestResetChallengeMine(mineIndex,minePlayerId)
        end,
        function()
            AlertManager:close()
        end,
        {
            --title = "提示" ,
            title = localizable.common_tips ,
            msg = str,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure"
        }
    )
end

--提示(退出)
function LootEmbattleLayer:openCell2(str)
    CommonManager:showOperateSureLayer(
        function()
            AlertManager:close()
            local info = MiningManager:getLootPlayerIndexAndMine()
            MiningManager:requestUnlockPlayerMine(info.minePlayerId,info.mineIndex)
        end,
        function()
            AlertManager:close()
        end,
        {
            --title = "提示" ,
            title = localizable.common_tips ,
            msg = str,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure"
        }
    )
end

--切换动作
function LootEmbattleLayer:qieHuanAction()
    if self.ismoveEnd then
        return
    end
    self.ismoveEnd = true
    local move1 = CCMoveTo:create(0.2,ccp(self.panelPos[1].x-220,self.panelPos[1].y))
    local move2 = CCMoveTo:create(0.2,ccp(self.panelPos[2].x+220,self.panelPos[2].y))
    local move3 = CCMoveTo:create(0.2,ccp(self.panelPos[1].x,self.panelPos[1].y))
    local move4 = CCMoveTo:create(0.2,ccp(self.panelPos[2].x,self.panelPos[2].y))
    
    local function changeOrder()
        self.hukuangpanel:setZOrder(2)
        self.caikuangpanel:setZOrder(1)
    end
    local function changeOrder2()
        self.hukuangpanel:setZOrder(1)
        self.caikuangpanel:setZOrder(2)
    end
    local function moveEnd()
        self.ismoveEnd = false
    end
    if self.armyType == 1 then
        self.armyType = 2
        self.btn_challenge2:setTouchEnabled(true)
        self.btn_challenge3:setTouchEnabled(false)
        local act1 = CCSequence:createWithTwoActions(move1,move4)
        self.hukuangpanel:runAction(act1)
        local act2 = CCSequence:createWithTwoActions(move2,CCCallFunc:create(changeOrder))
        local act3 = CCSequence:createWithTwoActions(act2,move3)
        self.caikuangpanel:runAction(CCSequence:createWithTwoActions(act3,CCCallFunc:create(moveEnd)))
    else
        self.armyType = 1
        self.btn_challenge2:setTouchEnabled(false)
        self.btn_challenge3:setTouchEnabled(true)
        local act1 = CCSequence:createWithTwoActions(move2,move3)
        self.hukuangpanel:runAction(act1)
        local act2 = CCSequence:createWithTwoActions(move1,CCCallFunc:create(changeOrder2))
        local act3 = CCSequence:createWithTwoActions(act2,move4)
        self.caikuangpanel:runAction(CCSequence:createWithTwoActions(act3,CCCallFunc:create(moveEnd)))
    end  
    self:showArmyUIData()
    self:showBtnUIdata()
end

function LootEmbattleLayer:showBtnUIdata()
    --k=1采矿 k=2护矿
    local totalbloodcaikuang = MiningManager:getArmyTotalBloodByIndex(1)
    local totalbloodhukuang = MiningManager:getArmyTotalBloodByIndex(2)
    if totalbloodcaikuang == 0 then
        self.btn_challenge3:setTouchEnabled(false)
        self.btn_challenge3:setGrayEnabled(true)
    elseif totalbloodhukuang == 0 then
         self.btn_challenge2:setTouchEnabled(false)
         self.btn_challenge2:setGrayEnabled(true)
    end
end

function LootEmbattleLayer:showChallengeTimes()
    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.MINE)
    local challengetime = challengeInfo.currentValue
    self.txt_coss:setText(challengetime)
end

function LootEmbattleLayer.cellTouchBeganHandle(cell)
    local self = cell.logic;
    if cell.hasRole ~= true then
        return;
    end

    cell.isClick = true;
    cell.isDrag  = false;
    self.isMove = false;

    self.onLongTouch = function(event)
        if self.isMove == false then
            return;
        end
        local pos = cell:getTouchMovePos();         
        local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos());   
        if (v.x < 30 and v.y < 30 )  then
            -- if (v.x < 0 or v.y < 0 ) then
            --     self:removeLongTouchTimer();  
            --     cell.isDrag  = false;
            -- end
            -- self:removeLongTouchTimer();
            -- self.longTouchTimerId = TFDirector:addTimer(0.001, 1, nil, self.onLongTouch); 

        else 
            self:removeLongTouchTimer();    
            if (v.x - v.y > -10) then
                cell.isDrag  = true;         
            else
                cell.isDrag  = false;
            end
        end
    end;

    if (cell.posIndex == -1) then
        self:removeLongTouchTimer();
        self.longTouchTimerId = TFDirector:addTimer(0.001, -1, nil, self.onLongTouch); 
    end
end


function LootEmbattleLayer.cellTouchMovedHandle(cell)
    local self = cell.logic;
    self.isMove = true;
           
    if cell.hasRole ~= true then
        return;
    end

    local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos());
    local pos = cell:getTouchMovePos();

    if self.selectCussor == nil then
        if (cell.posIndex ~= -1) then
            if (v.y < 30 and v.y > -30) and  (v.x < 30 and v.x > -30)  then
               return;
            end
        end

        if (cell.posIndex ~= -1 or cell.isDrag == true ) then
            self:createSelectCussor(cell,pos);
        end
    end

    self:moveSelectCussor(cell,pos);
end

function LootEmbattleLayer.cellTouchEndedHandle(cell)
    local self = cell.logic;
    if self.selectCussor then
        self.selectCussor:removeFromParentAndCleanup(true);
        self.selectCussor = nil;
    end
    if cell.hasRole ~= true then
        return;
    end

    self:removeLongTouchTimer();
    local pos = cell:getTouchEndPos();

    self:releaseSelectCussor(cell,pos);
end

function LootEmbattleLayer:moveSelectCussor(cell,pos)
    local self = cell.logic;
    local v = ccpSub(pos, self.lastPoint);
    self.lastPoint = pos;
    local scp = ccpAdd(self.selectCussor:getPosition(), v);
    self.selectCussor:setPosition(scp);
    self.selectCussor:setVisible(true);

    self.curIndex = nil;
    for i=1,9 do
        if  self.rolebtn[i].bg:hitTest(pos) then
            --print("i:",i)
            --print("self.curIndex:",self.curIndex)
            self.curIndex = self.rolebtn[i].bg.posIndex;
            break;
        end
    end
end

function LootEmbattleLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;

    local role = CardRoleManager:getRoleByGmid(cell.gmId);
    self.selectCussor = TFImage:create();
    self.selectCussor:setFlipX(true);
    self.selectCussor:setTexture(role:getHeadPath());
    self.selectCussor:setScale(20 / 15.0);
    self.selectCussor:setPosition(pos);
    self:addChild(self.selectCussor);
    self.selectCussor:setZOrder(100);
   
    self.curIndex = cell.posIndex;  
end

function LootEmbattleLayer:releaseSelectCussor(cell,pos) 
    if cell.isClick == false  then
        if (self.curIndex == nil) then
            return;
        end

        local dargRole      = CardRoleManager:getRoleByGmid(cell.gmId);
        local toReplaceRole =  StrategyManager:getRoleByIndex(self.curIndex);

        if dargRole == nil then
            return
        end

        --在阵中释放
        if (self.curIndex ~= -1) then 
            --从列表中拖到阵中
            if (cell.posIndex == -1) then
                --本来已经在阵中
                if dargRole.pos and dargRole.pos ~= 0 then
                    --且不是本角色目前所在的位置，做位置变更
                    if (toReplaceRole == nil or (toReplaceRole and toReplaceRole.gmId ~= dargRole.gmId)) then
                        --print("ArmyLayer:releaseSelectCussor(cell,pos) ------------666",dargRole.pos,self.curIndex)
                        local sendMsg = {
                        dargRole.pos - 1,
                        self.curIndex - 1,
                        };
                        showLoading();
                        TFDirector:send(c2s.CHANGE_INDEX,sendMsg);
                        play_buzhenyidong()

                    end               
                end
            --阵中操作，更换位置   
            else
                local sendMsg = {              
                cell.posIndex - 1,
                self.curIndex - 1,   
                };
                --print("ArmyLayer:releaseSelectCussor(cell,pos) ------------8888",sendMsg)
                showLoading();
                TFDirector:send(c2s.CHANGE_INDEX,sendMsg);

                play_buzhenyidong()
            end

            return;
        end
    end
end

function LootEmbattleLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

return LootEmbattleLayer