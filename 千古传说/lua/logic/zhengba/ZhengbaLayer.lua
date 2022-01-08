
local ZhengbaLayer = class("ZhengbaLayer", BaseLayer)

function ZhengbaLayer:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.zhenbashai.Zhenbashai_jifen")


end


function ZhengbaLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.bg = TFDirector:getChildByPath(ui, 'bg')
    self.btn_canjia = TFDirector:getChildByPath(ui, 'btn_canjia')
    self:addBtnEffect(self.btn_canjia)
    self.btn_duizhan = TFDirector:getChildByPath(ui, 'btn_duizhan')
    self:addBtnEffect(self.btn_duizhan)
    self.btn_jinggong = TFDirector:getChildByPath(ui, 'btn_jinggong')
    self.btn_fangshou = TFDirector:getChildByPath(ui, 'btn_fangshou')
    self.btn_guizhe = TFDirector:getChildByPath(ui, 'btn_guizhe')
    self.btn_zhanbao = TFDirector:getChildByPath(ui, 'btn_zhanbao')
    self.bg_zhenbagonggao = TFDirector:getChildByPath(ui, 'bg_zhenbagonggao')
    self.bg_zhenbagonggao:setVisible(false)

    self.btn_tuoguan = TFDirector:getChildByPath(ui, 'btn_tuoguan')
    self.btn_quxiao = TFDirector:getChildByPath(ui, 'btn_quxiao')
    self.img_tuoguan = TFDirector:getChildByPath(ui, 'img_tuoguan')

    self.generalHead = CommonManager:addGeneralHead( self ,10)
    self.generalHead:setData(ModuleType.ZhengBa,{HeadResType.COIN,HeadResType.SYCEE})
    self:addBgEffect()
    self:refreshUI()
end

function ZhengbaLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
    self:refreshUI();
end
function ZhengbaLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.updateTimerID = TFDirector:addTimer(1000, -1, nil, 
    function()
        self:updateCDTime()
    end)
    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_canjia:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.joinBtnClickHandle,play_fight_begin),1);
    self.btn_duizhan:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.matchBtnClickHandle),1);
    self.btn_tuoguan:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.tuoguanBtnClickHandle),1);
    self.btn_quxiao:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cancelTuoguanhBtnClickHandle),1);
    self.btn_guizhe:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.guizheBtnClickHandle),1);
    self.btn_zhanbao:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.zhangbaoBtnClickHandle),1);
    self.btn_jinggong.logic =self
    self.btn_jinggong.tag = EnumFightStrategyType.StrategyType_CHAMPIONS_ATK
    self.btn_jinggong:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.armyBtnClickHandle),1);
    self.btn_fangshou.logic =self
    self.btn_fangshou.tag = EnumFightStrategyType.StrategyType_CHAMPIONS_DEF
    self.btn_fangshou:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.armyBtnClickHandle),1);

    local bg_mypaiming = TFDirector:getChildByPath(self.ui, 'Panel_mypaiming')
    for i=1,2 do
        local btn_mubiao = TFDirector:getChildByPath(bg_mypaiming, 'btn_mubiao'..i)
        btn_mubiao.logic = self
        btn_mubiao.tag = i
        btn_mubiao:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.openBoxBtnClickHandle),1);
    end


    self.gainChampionsInfo = function(event)
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(ZhengbaManager.GAINCHAMPIONSINFO ,self.gainChampionsInfo)
    TFDirector:addMEGlobalListener(ZhengbaManager.UPADTECHAMPIONSSTATUS ,self.gainChampionsInfo)
    self.championsRank = function(event)
        self:setMyRankInfo()
        self:setRankInfo()
    end
    TFDirector:addMEGlobalListener(ZhengbaManager.CHAMPIONSRANK ,self.championsRank)
    self.getGrand = function(event)
        local data = event.data[1];
        self:setJingongInfo()
        self:setFangshouInfo()
        self:setMyRankInfo()
        self:showGrand(data[1])
    end
    TFDirector:addMEGlobalListener(ZhengbaManager.GETGRAND ,self.getGrand)

     self.openEnmeyInfoLayer = function(event)
        local userData   = event.data[1]
        -- ZhengbaManager.matchTime = MainPlayer:getNowtime()
        local layer = AlertManager:addLayerByFile("lua.logic.zhengba.ZhengbasaiArmyVSLayer",AlertManager.BLOCK);
        -- if section <= self.curFightIndex then
        --     layer.btn_army:setVisible(false)
        -- end

        layer:loadData(userData[1]);
        AlertManager:show()

    end
    TFDirector:addMEGlobalListener(OtherPlayerManager.Zhengbasai, self.openEnmeyInfoLayer)

    self.openBoxSucess = function(event)
        self:freshBoxInfo()
    end
    TFDirector:addMEGlobalListener(ZhengbaManager.OPENBOXSUCESS, self.openBoxSucess)
end

function ZhengbaLayer:removeEvents()
    self.super.removeEvents(self)
    if self.updateTimerID then
        TFDirector:removeTimer(self.updateTimerID)
        self.updateTimerID = nil
    end
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    TFDirector:removeMEGlobalListener(ZhengbaManager.GAINCHAMPIONSINFO ,self.gainChampionsInfo)
    TFDirector:removeMEGlobalListener(ZhengbaManager.UPADTECHAMPIONSSTATUS ,self.gainChampionsInfo)
    self.gainChampionsInfo = nil
    TFDirector:removeMEGlobalListener(ZhengbaManager.CHAMPIONSRANK ,self.championsRank)
    self.championsRank = nil
    TFDirector:removeMEGlobalListener(ZhengbaManager.GETGRAND ,self.getGrand)
    self.getGrand = nil
    TFDirector:removeMEGlobalListener(ZhengbaManager.OPENBOXSUCESS ,self.openBoxSucess)
    self.openBoxSucess = nil
    TFDirector:removeMEGlobalListener(OtherPlayerManager.Zhengbasai ,self.openEnmeyInfoLayer)
    self.openEnmeyInfoLayer = nil
end

function ZhengbaLayer:removeUI()
    self.super.removeUI(self)
end
function ZhengbaLayer.joinBtnClickHandle(sender)
    ZhengbaManager:joinChampions()
end
function ZhengbaLayer.matchBtnClickHandle(sender)
    ZhengbaManager:match()
end
function ZhengbaLayer.tuoguanBtnClickHandle(sender)
    ZhengbaManager:updateHosting(true)
end
function ZhengbaLayer.cancelTuoguanhBtnClickHandle(sender)
    ZhengbaManager:updateHosting(false)
end
function ZhengbaLayer.guizheBtnClickHandle(sender)
-- ZhengbaManager:test002()
    -- ZhengbaManager:openGuizheLayer()
    CommonManager:showRuleLyaer('zhengbasaijifen')
end
function ZhengbaLayer.zhangbaoBtnClickHandle(sender)
    ZhengbaManager:openZhangBaoLayer()
end
function ZhengbaLayer.openBoxBtnClickHandle(sender)
    ZhengbaManager:openBox(sender.tag)
end

function ZhengbaLayer.armyBtnClickHandle(sender)
    ZhengbaManager:openArmyLayer(sender.tag)
end

function ZhengbaLayer:updateCDTime()
    local status = ZhengbaManager:getActivityStatus()
    print("self.showTime = ",self.showTime)
    if self.showTime == nil or self.showTime <= 0 then
        return
    end
    self.showTime = self.showTime - 1
    if status == 2 then
        local txt_ready_time = TFDirector:getChildByPath(self.ui, 'txt_ready_time')
        txt_ready_time:setText(timeFormat(self.showTime))
    elseif status == 3 then
        local txt_shengyushijian = TFDirector:getChildByPath(self.ui, 'txt_shengyushijian')
        txt_shengyushijian:setText(timeFormat(self.showTime))
    end
end

function ZhengbaLayer:getGrandEffect()
    self.grandEffect = self.grandEffect or {}
    for i=1,2 do
        if self.grandEffect[i] == nil then
            TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/zhengbasai_jifen_lihua.xml")
            local effect = TFArmature:create("zhengbasai_jifen_lihua_anim")
            if i == 1 then
                effect:setPosition(ccp(-70,20))
            else
                effect:setPosition(ccp(600,20))
                effect:setScaleX(-1)
            end
            self.bg_zhenbagonggao:addChild(effect,100)
            self.grandEffect[i] = effect
        end
    end
    return self.grandEffect
end

function ZhengbaLayer:addBgEffect()
    if self.bgEffect == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/zhengbasai_jifen_bg.xml")
        local effect = TFArmature:create("zhengbasai_jifen_bg_anim")
        effect:setPosition(ccp(568,320))
        self.bg:addChild(effect,100)
        self.bgEffect = effect
        effect:playByIndex(0,-1,-1,1)
    end
    return self.bgEffect
end
function ZhengbaLayer:addBtnEffect(widget)
    if widget.effect == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/zhengbasai_jifen_btn.xml")
        local effect = TFArmature:create("zhengbasai_jifen_btn_anim")
        effect:setPosition(ccp(0,0))
        widget:addChild(effect,100)
        widget.effect = effect
        effect:playByIndex(0,-1,-1,1)
    end
    return widget.effect
end

function ZhengbaLayer:showGrand(message)
    local nowtime = MainPlayer:getNowtime()
    if self.showGrandTime ~= nil and nowtime - self.showGrandTime < 3 then
        return
    end
    self.showGrandTime = nowtime

    local txt_zhenbagonggao = TFDirector:getChildByPath(self.bg_zhenbagonggao, 'txt_zhenbagonggao')
    txt_zhenbagonggao:setPosition(ccp(270,19))
    local show_text = message.message
    if message.score then
        show_text = show_text .. message.score
    end
    if self.bg_zhenbagonggao:isVisible() == false then
        if message.showEffect == true then
            local effect_list = self:getGrandEffect()
            for i=1,2 do
                if effect_list[i] then
                    effect_list[i]:playByIndex(0, -1, -1, 0)
                end
            end
        end
        self.bg_zhenbagonggao:setVisible(true)
        txt_zhenbagonggao:setText(show_text)
        return
    end
    local tween = {
        target = txt_zhenbagonggao,
        {
            duration = 1,
            x = 270,
            y = 54,
            onComplete = function ()
                if message.showEffect == true then
                    local effect_list = self:getGrandEffect()
                    for i=1,2 do
                        if effect_list[i] then
                            effect_list[i]:playByIndex(0, -1, -1, 0)
                        end
                    end
                end
                txt_zhenbagonggao:setPosition(ccp(270,19))
                txt_zhenbagonggao:setText(show_text)
            end,
        }
    }
    TFDirector:toTween(tween)
end
function ZhengbaLayer:refreshBaseUI()
end

function ZhengbaLayer:refreshUI()
    if not self.isShow then
        return;
    end
    local status = ZhengbaManager:getActivityStatus()
    local isJoin = ZhengbaManager:isJoinActivity()
    if status == 1 then
        -- toastMessage("活动还未开始")
        toastMessage(localizable.zhengba_ZhengbaLayer_huodongweikaiqi)
        AlertManager:close();
        return
    end
    if status == 4 then
        self:statusClosedShow()
        return
    end
    if isJoin == false then
        self:statusNotBeginShow()
        return
    end

    if status == 2 then
        self:statusReadyShow()
    else
        self:statusRunningShow()
    end
end


function ZhengbaLayer:statusNotBeginShow()
    self:setStatusNotBegin(true)
    self:setStatusReady(false)
    self:setStatusRunning(false)
    self:setHostingStatus(false,false)
end

function ZhengbaLayer:statusReadyShow()
    self:setStatusNotBegin(false)
    self:setStatusRunning(false)
    self:setHostingStatus(false,false)
    self:setStatusReady(true)
    local status , time = ZhengbaManager:getNowState()
    if status~= 2 or time == nil then
        time = 0
    end
    self.showTime = time
    local txt_ready_time = TFDirector:getChildByPath(self.ui, 'txt_ready_time')
    txt_ready_time:setText(timeFormat(self.showTime))
end

function ZhengbaLayer:statusRunningShow()
    self:setStatusNotBegin(false)
    self:setStatusReady(false)
    self:setStatusRunning(true)
    self:setHostingStatus(ZhengbaManager.hosting,true)
    local status , time = ZhengbaManager:getNowState()
    print("status , time=-",status , time)
    if status~= 3 or time == nil then
        time = 0
    end
    self.showTime = time
    local txt_shengyushijian = TFDirector:getChildByPath(self.ui, 'txt_shengyushijian')
    txt_shengyushijian:setText(timeFormat(self.showTime))
end
function ZhengbaLayer:statusClosedShow()
    self:setStatusNotBegin(false)
    self:setStatusReady(false)
    self:setStatusRunning(false)
    self:setHostingStatus(false,false)
    self:setStatusClosed(true)
end
function ZhengbaLayer:setStatusNotBegin( bool )
    self.btn_canjia:setVisible(bool)
end

function ZhengbaLayer:setStatusReady( bool )
    local img_jijiangkaishi = TFDirector:getChildByPath(self.ui, 'img_jijiangkaishi')
    img_jijiangkaishi:setVisible(bool)
    -- local img_bishaijieshu = TFDirector:getChildByPath(self.ui, 'img_bishaijieshu')
    -- img_bishaijieshu:setVisible(false)
    local bg_jingong = TFDirector:getChildByPath(self.ui, 'bg_jingong')
    bg_jingong:setVisible(bool)
    local bg_fangshou = TFDirector:getChildByPath(self.ui, 'bg_fangshou')
    bg_fangshou:setVisible(bool)
    self:setJingongInfo()
    self:setFangshouInfo()
    self:setMyRankInfo()
    self:setRankInfo()
end

function ZhengbaLayer:setStatusRunning( bool )
    self.btn_duizhan:setVisible(bool)
    local bg_jingong = TFDirector:getChildByPath(self.ui, 'bg_jingong')
    bg_jingong:setVisible(bool)
    local bg_fangshou = TFDirector:getChildByPath(self.ui, 'bg_fangshou')
    bg_fangshou:setVisible(bool)
    -- local bg_mypaiming = TFDirector:getChildByPath(self.ui, 'Panel_mypaiming')
    -- bg_mypaiming:setVisible(bool)
    -- local bg_paihangbang = TFDirector:getChildByPath(self.ui, 'Panel_paihangbang')
    -- bg_paihangbang:setVisible(bool)
    local txt_shijianshengyu = TFDirector:getChildByPath(self.ui, 'txt_shijianshengyu')
    local txt_shengyushijian = TFDirector:getChildByPath(self.ui, 'txt_shengyushijian')
    txt_shijianshengyu:setVisible(bool)
    txt_shengyushijian:setVisible(bool)
    local img_bishaijieshu = TFDirector:getChildByPath(self.ui, 'img_bishaijieshu')
    img_bishaijieshu:setVisible(false)
    if bool == false then
        return
    end
    self:setJingongInfo()
    self:setFangshouInfo()
    self:setMyRankInfo()
    self:setRankInfo()
end
function ZhengbaLayer:setHostingStatus(value ,openStatus)
    if openStatus == false then
        self.btn_tuoguan:setVisible(false)
        self.btn_quxiao:setVisible(false)
        self.img_tuoguan:setVisible(false)
        return
    end
    if value == true then
        self.btn_duizhan:setVisible(false)
    end
    self.btn_tuoguan:setVisible(not value)
    self.btn_quxiao:setVisible(value)
    self.img_tuoguan:setVisible(value)

end

function ZhengbaLayer:setStatusClosed( bool )
    -- local bg_mypaiming = TFDirector:getChildByPath(self.ui, 'Panel_mypaiming')
    -- bg_mypaiming:setVisible(bool)
    -- local bg_paihangbang = TFDirector:getChildByPath(self.ui, 'Panel_paihangbang')
    -- bg_paihangbang:setVisible(bool)
    local img_bishaijieshu = TFDirector:getChildByPath(self.ui, 'img_bishaijieshu')
    img_bishaijieshu:setVisible(bool)

    self:setMyRankInfo()
    self:setRankInfo()
end

function ZhengbaLayer:setJingongInfo()
    local bg_jingong = TFDirector:getChildByPath(self.ui, 'bg_jingong')
    local txt_zhanji = TFDirector:getChildByPath(bg_jingong, 'txt_zhanji')
    local txt_liansheng = TFDirector:getChildByPath(bg_jingong, 'txt_liansheng')
    if ZhengbaManager.championsInfo == nil then
        -- txt_zhanji:setText("0胜0败")
        -- txt_liansheng:setText("0连胜")
        txt_zhanji:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_shengfu, 0, 0))
        txt_liansheng:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_jiliansheng, 0))
        return
    end
    -- txt_zhanji:setText(ZhengbaManager.championsInfo.atkWinCount.."胜"..ZhengbaManager.championsInfo.atkLostCount.."败")
    -- txt_liansheng:setText(ZhengbaManager.championsInfo.atkWinStreak.."连胜")

    txt_zhanji:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_shengfu, ZhengbaManager.championsInfo.atkWinCount, ZhengbaManager.championsInfo.atkLostCount))
    txt_liansheng:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_jiliansheng, ZhengbaManager.championsInfo.atkWinStreak))
        
end

function ZhengbaLayer:setFangshouInfo()
    local bg_fangshou = TFDirector:getChildByPath(self.ui, 'bg_fangshou')
    local txt_zhanji = TFDirector:getChildByPath(bg_fangshou, 'txt_zhanji')
    local txt_liansheng = TFDirector:getChildByPath(bg_fangshou, 'txt_liansheng')
    if ZhengbaManager.championsInfo == nil then
        -- txt_zhanji:setText("0胜0败")
        -- txt_liansheng:setText("0连胜")
        -- return
        txt_zhanji:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_shengfu, 0, 0))
        txt_liansheng:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_jiliansheng, 0))
        return
    end
    -- txt_zhanji:setText(ZhengbaManager.championsInfo.defWinCount.."胜"..ZhengbaManager.championsInfo.defLostCount.."败")
    -- txt_liansheng:setText(ZhengbaManager.championsInfo.defWinStreak.."连胜")


    txt_zhanji:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_shengfu, ZhengbaManager.championsInfo.defWinCount, ZhengbaManager.championsInfo.defLostCount))
    txt_liansheng:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_jiliansheng, ZhengbaManager.championsInfo.defWinStreak))
       
end

function ZhengbaLayer:setMyRankInfo()
    local bg_mypaiming = TFDirector:getChildByPath(self.ui, 'Panel_mypaiming')
    local txt_paiming = TFDirector:getChildByPath(bg_mypaiming, 'txt_paiming')
    local txt_jifen = TFDirector:getChildByPath(bg_mypaiming, 'txt_jifen')
    local txt_gift = {}
    -- local btn_mubiao = {}
    for i=1,2 do
        txt_gift[i] = TFDirector:getChildByPath(bg_mypaiming, 'txt_gift'..i)
        -- btn_mubiao[i] = TFDirector:getChildByPath(bg_mypaiming, 'btn_mubiao'..i)
    end

    local isJoin = ZhengbaManager:isJoinActivity()
    if isJoin == false then
        -- txt_paiming:setText("未参加")
        -- txt_jifen:setText("未上榜")
        -- txt_gift[1]:setText("未参加")


        txt_paiming:setText(localizable.zhengba_ZhengbaLayer_no_jion)
        txt_jifen:setText(localizable.zhengba_ZhengbaLayer_no_rank)
        
        txt_gift[1]:setText(localizable.zhengba_ZhengbaLayer_no_jion)

        txt_gift[2]:setVisible(false)
        -- btn_mubiao[1]:setVisible(false)
        -- btn_mubiao[2]:setVisible(false)
        self:freshBoxInfo()
        return
    end

    -- txt_paiming:setText(ZhengbaManager.myRank or "未入榜")
    txt_paiming:setText(ZhengbaManager.myRank or localizable.zhengba_ZhengbaLayer_no_rank)
    txt_jifen:setText(ZhengbaManager.championsInfo.score)

    if ZhengbaManager.myRank then
        --local rewardRank = ZhengbaManager.myRank > 8 and 0 or ZhengbaManager.myRank
        local rewardRank = ZhengbaManager.myRank
        --add by quanhuan 2015/12/7
        local rewardInfo = ChampionsAwardData:getRewardData(1,rewardRank)
        if rewardInfo then
            local rewardlist = rewardInfo:getReward()
            for i=1,2 do
                if rewardlist[i] ~= nil then
                    txt_gift[i]:setVisible(true)
                    local reward = BaseDataManager:getReward(rewardlist[i])
                    if reward then
                        txt_gift[i]:setText(reward.name.."x"..reward.number)
                    end
                else
                    txt_gift[i]:setVisible(false)
                end
            end
        end
    end
    self:freshBoxInfo()
end

function ZhengbaLayer:addBoxEffect(widget,visible)
    local widget_effect = widget:getChildByTag(100)
    if widget_effect == nil and visible == false then
        return
    end
    if widget_effect == nil then
        local resPath = "effect/smallBox.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("smallBox_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(23, 13))
        widget:addChild(effect,100)
        effect:setTag(100)
        effect:playByIndex(0, -1, -1, 1)
        widget_effect = effect
    end
    widget_effect:setVisible(visible)
end

function ZhengbaLayer:freshBoxInfo()
    local bg_mypaiming = TFDirector:getChildByPath(self.ui, 'Panel_mypaiming')
    local btn_mubiao = {}
    for i=1,2 do
        btn_mubiao[i] = TFDirector:getChildByPath(bg_mypaiming, 'btn_mubiao'..i)
        local img_baoxiang = TFDirector:getChildByPath(btn_mubiao[i], 'img_baoxiang')
        local txt_mubiao = TFDirector:getChildByPath(btn_mubiao[i], 'txt_mubiao')
        btn_mubiao[i]:setVisible(true)
        local boxes_id = ZhengbaManager.boxes[i] or 0
        local boxInfo = ChampionsBoxData:objectByID(i*1000 + boxes_id)
        self:addBoxEffect(img_baoxiang,false)
        if boxInfo == nil then
            -- txt_mubiao:setText("已领取完毕")
            txt_mubiao:setText(localizable.zhengba_ZhengbaLayer_no_prize)
            
        else
            if i == 1 then
                -- txt_mubiao:setText("取得进攻".. boxInfo.value .."连胜")
                txt_mubiao:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_liansheng, boxInfo.value))
                if ZhengbaManager.championsInfo and ZhengbaManager.championsInfo.atkMaxWinStreak >= boxInfo.value then
                    self:addBoxEffect(img_baoxiang,true)
                end
            else
                -- txt_mubiao:setText("进行".. boxInfo.value .."次对战")
                txt_mubiao:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_duizhan, boxInfo.value))

                if ZhengbaManager.championsInfo and ZhengbaManager.matchCount >= boxInfo.value then
                    self:addBoxEffect(img_baoxiang,true)
                end
            end
        end
    end
end

function ZhengbaLayer:setRankInfo()
    local bg_paihangbang = TFDirector:getChildByPath(self.ui, 'Panel_paihangbang')
    for i=1,8 do
        local bg_no = TFDirector:getChildByPath(bg_paihangbang, 'no'..i)
        local txt_name = TFDirector:getChildByPath(bg_no, 'txt_no'..i)
        local txt_jifen = TFDirector:getChildByPath(bg_no, 'txt_jifen')
        if ZhengbaManager.championsRankInfo == nil or ZhengbaManager.championsRankInfo[i] == nil then
            txt_name:setVisible(false)
            txt_jifen:setVisible(false)
        else
            txt_name:setVisible(true)
            txt_jifen:setVisible(true)
            txt_name:setText(ZhengbaManager.championsRankInfo[i].name)
            -- txt_jifen:setText("积分："..ZhengbaManager.championsRankInfo[i].score)
            txt_jifen:setText(stringUtils.format(localizable.zhengba_ZhengbaLayer_jifen, ZhengbaManager.championsRankInfo[i].score))
        end
    end
end


function timeFormat(totalSecond)
    local hour = math.floor(totalSecond/3600)
    local min = math.floor((totalSecond - hour*3600)/60)
    local sec = totalSecond - hour*3600 - min*60

    if hour < 10 then
        hour = "0"..hour
    else
        hour = tostring(hour)
    end

    if min < 10 then
        min = "0"..min
    else
        min = tostring(min)
    end

    if sec < 10 then
        sec = "0"..sec
    else
        sec = tostring(sec)
    end

    return hour..":"..min..":"..sec
end
return ZhengbaLayer