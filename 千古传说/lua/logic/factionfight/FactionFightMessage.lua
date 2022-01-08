--[[
    帮派争霸赛--战况回顾
	-- by yongkang
	-- 2016-02-22	
]]
local FactionFightMessage = class("FactionFightMessage", BaseLayer)

function FactionFightMessage:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.faction.FactionFightMessage")
    self.warInfos = { }
    -- 对战信息
    self.bOver = false
    -- 是否结束
    self.nextTime = 0
    -- 下一轮时间
    self.currRound = 0
    -- 当前轮次
    self.countRound = 0
end

function FactionFightMessage:initUI(ui)

    self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    if FactionFightManager:getActivityState() == 3 then --
        self.generalHead:setData(ModuleType.FactionFightMessage, {  HeadResType.COIN })
    elseif  FactionFightManager:getActivityState() == 2 then --对战信息
        self.generalHead:setData(ModuleType.FactionFightMessage, {  HeadResType.COIN })
    else
        self.generalHead:setData(ModuleType.FactionMessage, {  HeadResType.COIN })        
    end    
    self.bangpai_item = { }
    for i = 1, 16 do
        local node = TFDirector:getChildByPath(ui, "panel_bangpai" .. i)
        self.bangpai_item[i] = { }
        self.bangpai_item[i].node = node
        self.bangpai_item[i].img_qizhi = TFDirector:getChildByPath(node, "img_qizhi")
        self.bangpai_item[i].img_biaozhi = TFDirector:getChildByPath(node, "img_biaozhi")
        self.bangpai_item[i].img_shengli = TFDirector:getChildByPath(node, "img_shengli")
        self.bangpai_item[i].img_shengli:setVisible(false)
        self.bangpai_item[i].img_result = TFDirector:getChildByPath(ui, "result_" .. i)
        self.bangpai_item[i].txt_name = TFDirector:getChildByPath(node, "txt_name")
        
        self.bangpai_item[i].img_hei1 = TFDirector:getChildByPath(node, "img_hei") --旗帜
        self.bangpai_item[i].img_hei2 = TFDirector:getChildByPath(node, "img_hei2") --胜利那个字
        self.bangpai_item[i].img_empty = TFDirector:getChildByPath(node, "img_empty")
    end

    self.panel_team_vs = { }
    for i = 1, 8 do
        local node = TFDirector:getChildByPath(ui, "Panel_team" .. i)
        self.panel_team_vs[i] = TFDirector:getChildByPath(node, "img_vs")
    end

    self.btn_guizhe = TFDirector:getChildByPath(ui, "btn_guizhe")
    self.btn_jiangli = TFDirector:getChildByPath(ui, "btn_jiangli")
    self.txt_daojishi = TFDirector:getChildByPath(ui, "txt_daoji")
    self.txt_lefttime = TFDirector:getChildByPath(self.txt_daojishi, "txt_num")

    -- 处理按钮
    self.btn_check_rounds = { }
    --self.btn_check_round_1 = { "btn_check1", "btn_check2", "btn_check3", "btn_check4", "btn_check7", "btn_check8", "btn_check9", "btn_check10" }
    self.btn_check_round_1 = { "btn_check1", "btn_check7", "btn_check9", "btn_check3", "btn_check4", "btn_check10", "btn_check8", "btn_check2" }
    --self.btn_check_round_2 = { "btn_check5", "btn_check6", "btn_check11", "btn_check12" }
    self.btn_check_round_2 = { "btn_check5", "btn_check11", "btn_check12", "btn_check6" }
    self.btn_check_round_3 = { "btn_check13", "btn_check14" }
    self.btn_check_round_4 = { "btn_check15" }
    table.insert(self.btn_check_rounds, self.btn_check_round_1)
    table.insert(self.btn_check_rounds, self.btn_check_round_2)
    table.insert(self.btn_check_rounds, self.btn_check_round_3)
    table.insert(self.btn_check_rounds, self.btn_check_round_4)

    self.btn_check_nodes = { }
    for i = 1, 4 do
        self.btn_check_nodes[i] = { }
        for j = 1, #self.btn_check_rounds[i] do
            self.btn_check_nodes[i][j] = TFDirector:getChildByPath(ui, self["btn_check_round_" .. i][j])
            self.btn_check_nodes[i][j].round = i
            self.btn_check_nodes[i][j].index = j
            self.btn_check_nodes[i][j].logic = self
        end
    end

end

function FactionFightMessage:initData()

    self.warInfos = FactionFightManager:getWarInfos() or { }

    -- 第一队分为16个队伍
    --self.
    self.teamInfoList = { }
    for i = 1,8   do
         if self.warInfos[1][i] then
            local v = self.warInfos[1][i]
            local headTemp = { }
            local tailTemp = { }
            local headIndex = v.index;
            local tailIndex = 17 - headIndex

            headTemp.id = headIndex
            headTemp.guildId = v.atkGuildId
            headTemp.bannerId = v.atkBannerId
            headTemp.guildName = v.atkGuildName

            tailTemp.id = tailIndex
            tailTemp.guildId = v.defGuildId or 0
            tailTemp.bannerId = v.defBannerId or "1_1_1_1"
            tailTemp.guildName = v.defGuildName or "无"

            self.teamInfoList[headIndex] = headTemp
            self.teamInfoList[tailIndex] = tailTemp
         else
           
            local headTemp = { }
            local tailTemp = { }
            local headIndex = i;
            local tailIndex = 17 - headIndex

            headTemp.id = headIndex
            headTemp.guildId = 0
            headTemp.bannerId = "1_1_1_1"
            headTemp.guildName = "无"

            tailTemp.id = tailIndex
            tailTemp.guildId =  0
            tailTemp.bannerId =  "1_1_1_1"
            tailTemp.guildName =  "无"

            self.teamInfoList[headIndex] = headTemp
            self.teamInfoList[tailIndex] = tailTemp
         end
    end

    for i = 1, #self.warInfos do
       if #self.warInfos[i] > 0 then
            self.countRound = i
       end
    end


    --[[
    for k, v in pairs(self.warInfos[1]) do
        


        local headTemp = { }
        local tailTemp = { }
        local headIndex = v.index;
        local tailIndex = 17 - headIndex

        headTemp.id = headIndex
        headTemp.guildId = v.atkGuildId
        headTemp.bannerId = v.atkBannerId
        headTemp.guildName = v.atkGuildName

        tailTemp.id = tailIndex
        tailTemp.guildId = v.defGuildId or 999999
        tailTemp.bannerId = v.defBannerId or "1_1_1_1"
        tailTemp.guildName = v.defGuildName or localizable.common_no

        self.teamInfoList[headIndex] = headTemp
        self.teamInfoList[tailIndex] = tailTemp
    end
    ]]

    self.currRound, self.nextTime, self.bOver = FactionFightManager:getFightRound()
   
	--[[
    self.bOver = false
    self.currRound = 0
    self.nextTime = 5    
    ]]

    if FactionFightManager:getActivityState() == 2 then 
        for i = 1, #self.teamInfoList do
            if  self.teamInfoList[i].guildId  then
                if   self.teamInfoList[i].guildId ~= 0 then
                    self:showQiZhi(i)
                    self:hideShengliImg(i)
                    self.txt_daojishi:setVisible(false)
                else
                    self:hideQiZhi(i)

                end
            end
        end
        for i=1,4 do
            for k, v in pairs(self.btn_check_nodes[i]) do         
                v:setVisible(false)
            end
        end
    

    else
        if self.bOver then
            self:refreshUI()
            self.txt_daojishi:setVisible(false)
        else
            if self.updateTimerID then
                TFDirector:removeTimer(self.updateTimerID)
                self.updateTimerID = nil
            end

            self.updateTimerID = TFDirector:addTimer(1000, -1, nil,
            function()
                self:UpdateCDTime()
            end
            )
            self:refreshUI()
            self:initTime()
        end

    end
end

function FactionFightMessage:UpdateCDTime()
    self.nextTime = self.nextTime - 1

    if self.nextTime < 0 then
        self.currRound = self.currRound + 1
        if self.currRound < 5 then
            self:refreshUI()
        else
            self:removeUpdateTime()
        end
        self.nextTime = ConstantData:objectByID("Gangwar.Team.Time").value

        --self.nextTime = 5
    end
    self:initTime()
end

function FactionFightMessage:initTime()
    local min = math.floor(self.nextTime /(60))
    local second = self.nextTime - 60 * min
    local str = string.format('%02d:%02d', min, second)
    self.txt_lefttime:setText(str)
end



function FactionFightMessage:removeUpdateTime()
    if self.updateTimerID then
        TFDirector:removeTimer(self.updateTimerID)
        self.updateTimerID = nil
    end
end

function FactionFightMessage:refreshUI()

    if self.currRound > 2 then
         self.txt_daojishi:setVisible(false)
    elseif self.currRound > 3 then
        self:removeUpdateTime()
    end    

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/weekFight.xml")
    for i = 1, 4 do
        local round = i
        for k, v in pairs(self.btn_check_nodes[i]) do
            if i == self.currRound + 1 then                                              
                v:setVisible(true)
                v:removeChildByTag(666, true)
                local effect = TFArmature:create("weekFight_anim")
                effect:setPosition(ccp(0, 50))
                effect:setScale(0.5)
                effect:playByIndex(0, -1, -1, 1)
                effect:setTag(666)
                v:addChild(effect) 
                                                                                          
            elseif i < self.currRound + 1 then
                -- 前面已经打完的                    
                v:removeChildByTag(666, true)
                v:setVisible(true)      
            else
                -- 后面的隐藏以来
                v:setVisible(false)
            end
        end


        -- 战斗特效
        if self.currRound < 1 then
            for i = 1, #self.teamInfoList do
                if  self.teamInfoList[i].guildId then
                   if self.teamInfoList[i].guildId ~= 0 then
                        self:showQiZhi(i)
                        self:hideShengliImg(i)
                   else
                        self:hideQiZhi(i)
                   end 
                else
                    self:hideNode(i)
                end
            end
        else
            for i = 1, #self.teamInfoList do
                if self.teamInfoList[i].guildId  then                    
                    if self.teamInfoList[i].guildId ~= 0 then
                        if round < self.currRound + 1 then
                            self:showQiZhi(i)
                            self:showResult(i, round)
                        end
                    else
                        self:hideQiZhi(i)
                    end
                else
                    self:hideNode(i)
                end
            end        
        end
    end
    self:showResultLine()

end

function FactionFightMessage:showResult(i, round)

    local win = self:bWin(self.teamInfoList[i].guildId, round)

    if win then
        self.bangpai_item[i].img_shengli:setVisible(true)
    else
        if self.countRound >= round then
            self.bangpai_item[i].img_hei1:setVisible(true)
            self.bangpai_item[i].img_hei2:setVisible(true)
        end
    end

end

function FactionFightMessage:hideQiZhi(i)
    self.bangpai_item[i].img_qizhi:setVisible(false)
    self.bangpai_item[i].img_shengli:setVisible(false)
    self.bangpai_item[i].txt_name:setVisible(false)
    self.bangpai_item[i].img_empty:setVisible(true)
end


function FactionFightMessage:showResultLine()
    if self.currRound >= 2 then
        -- 4强
        for k, v in pairs(self.warInfos[2]) do
            local winIndex = self:getWinIndex(v.winGuildId)
            if winIndex > 8 then
                winIndex = 17 - winIndex
            end
            winIndex = winIndex * 2 - 1
            self.bangpai_item[winIndex].img_result:setVisible(true)
        end
    end

    if self.currRound >= 3 then
        -- 2强
        for k, v in pairs(self.warInfos[3]) do
            local winIndex = self:getWinIndex(v.winGuildId)
            if winIndex > 8 then
                winIndex = 17 - winIndex
            end
            winIndex = winIndex * 2
            self.bangpai_item[winIndex].img_result:setVisible(true)
        end
    end
end

function FactionFightMessage:getWinIndex(winId)
    local index = 1
    for k, v in pairs(self.teamInfoList) do
        if v.guildId == winId then
            index = k
            return index
        end
    end
    return index
end


function FactionFightMessage:bWin(guildId, Round)
    local bWin = false
    if Round < 1 or Round > 4 then
        return bWin
    else
        for k, v in pairs(self.warInfos[Round]) do
            if v.winGuildId == guildId then
                bWin = true
                return bWin
            end
        end
    end
    return bWin
end


function FactionFightMessage:showQiZhi(i)
    self.bangpai_item[i].img_qizhi:setTexture(FactionManager:getGuildBannerBgPath(self.teamInfoList[i].bannerId))
   
    local bannerInfos = stringToNumberTable(self.teamInfoList[i].bannerId, '_')
    self.bangpai_item[i].img_hei1:setTexture("ui_new/faction/fight/img_qizhi"..bannerInfos[1] ..".png" )
    
    self.bangpai_item[i].img_biaozhi:setTexture(FactionManager:getGuildBannerIconPath(self.teamInfoList[i].bannerId))
    self.bangpai_item[i].txt_name:setText(self.teamInfoList[i].guildName)
end

function FactionFightMessage:hideShengliImg(i)
    self.bangpai_item[i].img_shengli:setVisible(false)
end

function FactionFightMessage:hideNode(i)
    self.bangpai_item[i].node:setVisible(false)
    -- 对战 VS按钮隐藏
    if i > 8 then
        i = 17 - i
    end
    --local index = math.modf( (i + 1) / 2)
    local index = i
    self.panel_team_vs[index]:setVisible(false)
    
    self.btn_check_nodes[1][index]:setVisible(false)
end

function FactionFightMessage:removeUI()
    self.super.removeUI(self)

end

function FactionFightMessage:onShow()
    self.super.onShow(self)
end

function FactionFightMessage:registerEvents()
    if self.registerEventCallFlag then
        return
    end

    self.super.registerEvents(self)
    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_guizhe:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGuizheButtonClick))
    self.btn_jiangli:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJiangliButtonClick))

    for i = 1, #self.btn_check_nodes do
        for j = 1, #self.btn_check_nodes[i] do
            self.btn_check_nodes[i][j]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnCheck))
        end
    end

    -- 监听战斗结束 跳转到结束界面
    self.activityStateChangeCallback = function(event)
        FactionFightManager:switchToFightOrMainLayer(self)
    end
    TFDirector:addMEGlobalListener(FactionFightManager.activityStateChange, self.activityStateChangeCallback)

    -- 对战信息
    self.fightMessageCallBack = function(event)
        -- FactionFightManager:switchToFightOrMainLayer(self)
        self:initData()
    end
    TFDirector:addMEGlobalListener(FactionFightManager.requesWarInfosSuccess, self.fightMessageCallBack)

    self.registerEventCallFlag = true
end

function FactionFightMessage:removeEvents()
    if self.generalHead then
        self.generalHead:removeEvents()
    end

    self.btn_guizhe:removeMEListener(TFWIDGET_CLICK)
    self.btn_jiangli:removeMEListener(TFWIDGET_CLICK)

    for i = 1, #self.btn_check_nodes do
        for j = 1, #self.btn_check_nodes[i] do
            self.btn_check_nodes[i][j]:removeMEListener(TFWIDGET_CLICK)
        end
    end

    TFDirector:removeMEGlobalListener(FactionFightManager.activityStateChange, self.activityStateChangeCallback)
    self.activityStateChangeCallback = nil

    TFDirector:removeMEGlobalListener(FactionFightManager.requesWarInfosSuccess, self.fightMessageCallBack)
    self.fightMessageCallBack = nil

    if self.updateTimerID then
        TFDirector:removeTimer(self.updateTimerID)
        self.updateTimerID = nil
    end

    self.super.removeEvents(self)
    self.registerEventCallFlag = nil
end

function FactionFightMessage:dispose()
    self.super.dispose(self)
end


function FactionFightMessage.onGuizheButtonClick(btn)
    -- body
    --toastMessage("onGuizheButtonClick")
    FactionFightManager:showRuleLayer()
end

function FactionFightMessage.onJiangliButtonClick(btn)
    -- body
    FactionFightManager:showAwardLayer()

end

function FactionFightMessage.onBtnCheck(btn)
    local self = btn.logic

    -- 场次信息
    local index = btn.index
    local round = btn.round
    --int("index=%d-----round=%d",index,round)
    -- body
    if not self.warInfos[round] or not self.warInfos[round][index] then
        --toastMessage("没有该场战斗信息")
	toastMessage(localizable.faction_no_battle_info)
        return
    end

    local atkInfo = {}
    print('self.warInfos = ',self.warInfos)
    if self.warInfos[round] and self.warInfos[round][index] then
        atkInfo.bannerId = self.warInfos[round][index].atkBannerId
        atkInfo.name = self.warInfos[round][index].atkGuildName
    end

    local defInfo = {}
    if self.warInfos[round] and self.warInfos[round][index] then
        defInfo.bannerId = self.warInfos[round][index].defBannerId
        defInfo.name = self.warInfos[round][index].defGuildName
    end




    FactionFightManager:setGuildDataInfo(atkInfo, defInfo)



    FactionFightManager:requireRePlayeInfos(round, index)
    --toastMessage("第" .. round .. "轮" .. "第" .. index .. "场")
    -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.factionfight.FactionRecord");
    -- layer:setData(round, index)
    -- AlertManager:show();
end

return FactionFightMessage