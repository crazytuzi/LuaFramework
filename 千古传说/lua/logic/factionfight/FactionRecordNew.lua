--[[
******帮派战-战斗记录*******

	-- by quanhuan
	-- 2016/2/23
	
]]

local FactionRecordNew = class("FactionRecordNew",BaseLayer)

function FactionRecordNew:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionRecord")
end

function FactionRecordNew:initUI( ui )

	self.super.initUI(self, ui)

    self.btn_close = TFDirector:getChildByPath(ui, "btn_return")

    self.img_line2 = TFDirector:getChildByPath(ui, "img_line2")

    self.atkGuild = {}
    local atkGuildNode = TFDirector:getChildByPath(ui, "panel_bangpai1")
    self.atkImgEmpty = TFDirector:getChildByPath(atkGuildNode, "img_empty")
    self.atkGuildName = TFDirector:getChildByPath(atkGuildNode, "txt_name")
    self.atkGuildBannerBg = TFDirector:getChildByPath(atkGuildNode, "img_qizhi")
    self.atkGuildBannerIcon = TFDirector:getChildByPath(atkGuildNode, "img_biaozhi")
    self.atkGuildBuf = {}
    for i=1,3 do
        self.atkGuildBuf[i] = TFDirector:getChildByPath(atkGuildNode, "txt_zhuangtai"..i)
    end

    self.defGuild = {}
    local defGuildNode = TFDirector:getChildByPath(ui, "panel_bangpai2")
    self.defImgEmpty = TFDirector:getChildByPath(defGuildNode, "img_empty")
    self.defGuildName = TFDirector:getChildByPath(defGuildNode, "txt_name")
    self.defGuildBannerBg = TFDirector:getChildByPath(defGuildNode, "img_qizhi")
    self.defGuildBannerIcon = TFDirector:getChildByPath(defGuildNode, "img_biaozhi")
    self.defGuildBuf = {}
    for i=1,3 do
        self.defGuildBuf[i] = TFDirector:getChildByPath(defGuildNode, "txt_zhuangtai"..i)
    end

    self.img_diyi = TFDirector:getChildByPath(ui, "img_diyi")

        
    self.atkMember = {}
    self.defMember = {}
    local atkNode = TFDirector:getChildByPath(ui, "img_huangdi1")
    local defNode = TFDirector:getChildByPath(ui, "img_huangdi2")
    for i=1,11 do
        self.atkMember[i] = {}
        local atkheadNode = TFDirector:getChildByPath(atkNode, "img_tou"..i)
        local atknameNode = TFDirector:getChildByPath(atkNode, "panel_gundong"..i)
        self.atkMember[i].node = TFDirector:getChildByPath(atkNode, "panel_gundong"..i)
        self.atkMember[i].headFrame = TFDirector:getChildByPath(atkNode, "img_tou"..i)
        self.atkMember[i].headIcon = TFDirector:getChildByPath(atkheadNode, "img_touxiang")
        self.atkMember[i].imgkill = TFDirector:getChildByPath(atkheadNode, "img_sb")
        self.atkMember[i].txtName = TFDirector:getChildByPath(atknameNode, "txt_jingy")
        local atkbtn_jiahao = TFDirector:getChildByPath(atkheadNode, "btn_jiahao")
        atkbtn_jiahao:setVisible(false)

        self.defMember[i] = {}
        local defheadNode = TFDirector:getChildByPath(defNode, "img_tou"..i)
        local defnameNode = TFDirector:getChildByPath(defNode, "panel_gundong"..i)
        self.defMember[i].node = TFDirector:getChildByPath(defNode, "panel_gundong"..i)
        self.defMember[i].headFrame = TFDirector:getChildByPath(defNode, "img_tou"..i)
        self.defMember[i].headIcon = TFDirector:getChildByPath(defheadNode, "img_touxiang")
        self.defMember[i].imgkill = TFDirector:getChildByPath(defheadNode, "img_sb")
        self.defMember[i].txtName = TFDirector:getChildByPath(defnameNode, "txt_jingy")
        local defbtn_jiahao = TFDirector:getChildByPath(defheadNode, "btn_jiahao")
        defbtn_jiahao:setVisible(false)
    end

    --创建TabView
    local tabViewUI = TFDirector:getChildByPath(ui,"panel_huadong")
    local tabView =  TFTableView:create()
    local tabViewUISize = tabViewUI:getContentSize()
    tabView:setTableViewSize(tabViewUI:getContentSize())
    tabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    tabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tabView.logic = self
    tabViewUI:addChild(tabView)
    tabView:setPosition(ccp(0,0))
    self.tabView = tabView
    self.tabViewUI = tabViewUI

    local viewNode = TFDirector:getChildByPath(ui, "panel_huadong")    
    self.cellModel1 = TFDirector:getChildByPath(viewNode, 'panel_jingying')
    self.cellModel1:setVisible(false)
    self.cellModel2 = TFDirector:getChildByPath(viewNode, 'panel_putong')
    self.cellModel2:setVisible(false)
    self.cellModel3 = TFDirector:getChildByPath(viewNode, 'txt_shengli')
    self.cellModel3:setVisible(false)

    self.btn_left = TFDirector:getChildByPath(ui, "btn_left")
    self.btn_right = TFDirector:getChildByPath(ui, "btn_right")
end


function FactionRecordNew:removeUI()
	self.super.removeUI(self)
end

function FactionRecordNew:onShow()
    self.super.onShow(self)
end

function FactionRecordNew:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClick))
    self.btn_close.logic = self

    self.btn_left:addMEListener(TFWIDGET_CLICK, audioClickfun(self.leftBtnClick))
    self.btn_left.logic = self
    self.btn_right:addMEListener(TFWIDGET_CLICK, audioClickfun(self.rightBtnClick))
    self.btn_right.logic = self

    self.tabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tabView:addMEListener(TFTABLEVIEW_SCROLL, self.tableScroll)
    self.tabView.logic = self

    self.registerEventCallFlag = true 
end

function FactionRecordNew:removeEvents()

    self.super.removeEvents(self)

    self.tabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    self.tabView:removeMEListener(TFTABLEVIEW_SCROLL)

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end
    if self.fontMoveTime then
        TFDirector:removeTimer(self.fontMoveTime)
        self.fontMoveTime = nil
    end
    if self.delayViewTime then
        TFDirector:removeTimer(self.delayViewTime)
        self.delayViewTime = nil
    end    

    self.registerEventCallFlag = nil  
end

function FactionRecordNew:dispose()
	self.super.dispose(self)
end

function FactionRecordNew.cellSizeForTable(table,idx)
    if idx == 1 then
        return 23,760
    else
        return 80,760
    end
end

function FactionRecordNew.numberOfCellsInTableView(table)
    local self = table.logic
    
    return self.currFightIndex
end

function FactionRecordNew.tableCellAtIndex(table, idx)

    local self = table.logic
    
    local cell = table:dequeueCell()
    if cell == nil then
        cell = TFTableViewCell:create()
        cell.panel = {}

        local panel1 = self.cellModel1:clone()
        panel1:setPosition(ccp(0,0))
        cell:addChild(panel1)
        panel1:setVisible(false)        
        cell.panel[1] = panel1
        local panel2 = self.cellModel2:clone()
        panel2:setPosition(ccp(0,0))
        cell:addChild(panel2)
        panel2:setVisible(false)        
        cell.panel[2] = panel2
        local panel3 = self.cellModel3:clone()
        panel3:setPosition(ccp(0,0))
        cell:addChild(panel3)
        panel3:setVisible(false)        
        cell.panel[3] = panel3
    end

    local panels = cell.panel or {}
    idx = idx + 1

    self:showDataDetails(panels, idx)

    return cell
end

function FactionRecordNew:setCellData(panel,idx, showTime)
    
    local atkNode = TFDirector:getChildByPath(panel, "img_hongdi1")
    local atkplayerName = TFDirector:getChildByPath(atkNode, "txt_name")
    local atkheadFrame = TFDirector:getChildByPath(atkNode, "img_tou2")
    local atkheadIcon = TFDirector:getChildByPath(atkNode, "img_touxiang")
    local atkimgLost = TFDirector:getChildByPath(atkNode, "panel_shibai")
    local atkimgWin = TFDirector:getChildByPath(atkNode, "panel_shengli")

    local defNode = TFDirector:getChildByPath(panel, "img_hongdi2")
    local defplayerName = TFDirector:getChildByPath(defNode, "txt_name")
    local defheadFrame = TFDirector:getChildByPath(defNode, "img_tou2")
    local defheadIcon = TFDirector:getChildByPath(defNode, "img_touxiang")
    local defimgLost = TFDirector:getChildByPath(defNode, "panel_shibai")
    local defimgWin = TFDirector:getChildByPath(defNode, "panel_shengli")

    local itemData = self.fightRecordData[idx]
    local atkInfo = self:getPlayerInfo(self.atkMemberInfo, itemData.atkPlayerId)
    local defInfo = self:getPlayerInfo(self.defMemberInfo, itemData.defPlayerId)

    local img_jingying = TFDirector:getChildByPath(panel, "img_jingying")
    local btn_huifang = TFDirector:getChildByPath(panel, "btn_huifang")
    btn_huifang:setVisible(true)
    btn_huifang.replayId = itemData.replayId
    btn_huifang:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onReplayClick))

    --设置特效
    if panel.fightEffect then
        panel.fightEffect:removeFromParent()
        panel.fightEffect = nil
    end
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/weekFight.xml")
    local effect = TFArmature:create("weekFight_anim") 
    effect:setPosition(ccp(380, 40))
    effect:setScale(0.5)
    effect:playByIndex(0, -1, -1, 1)
    effect:setZOrder(100)
    panel:addChild(effect) 
    panel.fightEffect = effect
    effect:setVisible(false)
    

    --设置是否精英
    if idx == 1 then
        img_jingying:setVisible(true)
    else
        img_jingying:setVisible(false)
    end

    --设置攻击方信息
    if atkInfo then
        atkplayerName:setText(atkInfo.name)
        local RoleIcon = RoleData:objectByID(atkInfo.profession)
        atkheadIcon:setTexture(RoleIcon:getIconPath())
        Public:addFrameImg(atkheadIcon,atkInfo.headPicFrame)
        Public:addInfoListen(atkheadIcon,true,3,itemData.defPlayerId)
        if itemData.winPlayerId == itemData.atkPlayerId then
            atkimgWin:setVisible(true)
            atkimgLost:setVisible(false)
        else
            atkimgWin:setVisible(false)
            atkimgLost:setVisible(true)
        end
    else
        atkplayerName:setVisible(false)
        atkheadFrame:setVisible(false)
        atkheadIcon:setVisible(false)
        atkimgLost:setVisible(false)
        atkimgWin:setVisible(false)
    end

    --设置防守方信息
    if defInfo then
        defplayerName:setText(defInfo.name)
        local RoleIcon = RoleData:objectByID(defInfo.profession)
        defheadIcon:setTexture(RoleIcon:getIconPath())
        Public:addFrameImg(defheadIcon,defInfo.headPicFrame)
        Public:addInfoListen(atkheadIcon,true,3,itemData.atkPlayerId)
        if itemData.winPlayerId == itemData.defPlayerId then
            defimgWin:setVisible(true)
            defimgLost:setVisible(false)
        else
            defimgWin:setVisible(false)
            defimgLost:setVisible(true)
        end
    else
        defplayerName:setVisible(false)
        defheadFrame:setVisible(false)
        defheadIcon:setVisible(false)
        defimgLost:setVisible(false)
        defimgWin:setVisible(false)
    end

    --设置是否需要显示时间
    local txt_time = TFDirector:getChildByPath(panel, "txt_time")
    txt_time:setVisible(true)
    
    if showTime then
        atkimgWin:setVisible(false)
        atkimgLost:setVisible(false)
        defimgWin:setVisible(false)
        defimgLost:setVisible(false)
        btn_huifang:setVisible(false)

        panel.fightEffect:setVisible(true)   
        panel.fightEffect:playByIndex(0, -1, -1, 1)     
        self.txtDelayTime = txt_time     
        txt_time:setText("00:"..string.format("%02d",self.cutTime))   
    else
        panel.fightEffect:setVisible(false)
        txt_time:setVisible(false)
    end
end

function FactionRecordNew:showDataDetails(panels, idx)
    local panel = panels[1]
    if idx == 2 then
        panels[1]:setVisible(false)
        panels[2]:setVisible(false)
        panels[3]:setVisible(true)
        panel = panels[3]
        panel:setPosition(ccp(300,10))
        local txtDescr = TFDirector:getChildByPath(panel, "txt_jiacheng")
        txtDescr:setText(TFLanguageManager:getString(ErrorCodeData.Guild_War_Output + self.selectTeamIndex - 1))
        return
    end

    local fightIndex = idx

    -- if ((self.currFightIndex == fightIndex) or (self.currFightIndex == 2)) and self.isEnd == false then
    if fightIndex == 1 then
        --显示正在战斗 并显示倒计时
        panels[1]:setVisible(true)
        panels[2]:setVisible(false)
        panels[3]:setVisible(false)
        panel = panels[1]
        if self.isEnd then
            self:setCellData(panel, fightIndex, false)       
        else
            self:setCellData(panel, fightIndex, self.currFightIndex == 2)       
        end
    else
        panels[1]:setVisible(false)
        panels[2]:setVisible(true)
        panels[3]:setVisible(false)
        panel = panels[2]

        if self.isEnd then
            self:setCellData(panel, fightIndex-1, false)
        else
            self:setCellData(panel, fightIndex-1, self.currFightIndex == fightIndex)
        end
    end
end

function FactionRecordNew:setFightRound( index )

    FactionFightManager:setCurrFightStartTime( index )

    -- 查找当前战斗到第几小队
    -- 如果全部战斗完成则选择第一小队的信息
    self.selectTeamIndex = 1
    for i=1,3 do
        local isEnd,currFightIndex,cutTime = FactionFightManager:getStateByTeamIndex(i)
        if isEnd == false then
            self.selectTeamIndex = i
            break
        end
    end

    if FactionFightManager:getActivityState() ~= FactionFightManager.ActivityState_3 then
        self.selectTeamIndex = 1
    end
    
    self:refreshTeamInfoByIndex()
end

function FactionRecordNew:refreshTeamInfoByIndex()
    
    self.isEnd,self.currFightIndex,self.cutTime = FactionFightManager:getStateByTeamIndex(self.selectTeamIndex)

    --设置左右箭头
    if self.selectTeamIndex == 1 then
        self.btn_left:setVisible(false)
        self.btn_right:setVisible(true)
    elseif self.selectTeamIndex == 3 then
        self.btn_left:setVisible(true)
        self.btn_right:setVisible(false)
    else
        self.btn_left:setVisible(true)
        self.btn_right:setVisible(true)
    end

    if self.currFightIndex <= 3 then
        self.img_line2:setVisible(false)
    else
        self.img_line2:setVisible(true)
    end

    -- print("self.isEnd = ",self.isEnd)
    -- print("self.currFightIndex = ",self.currFightIndex)
    -- print("self.cutTime = ",self.cutTime)

    self.fightRecordData = FactionFightManager:getTeamInfoByIndex(self.selectTeamIndex)
    self.atkMemberInfo = FactionFightManager:getAtkMemberInfo(self.selectTeamIndex)
    self.defMemberInfo = FactionFightManager:getDefMemberInfo(self.selectTeamIndex)

    if self.currFightIndex ~= 0 then
        self.currFightIndex = self.currFightIndex + 1
    end
    self:refreshGuildInfo()
    self:refreshMemberHead()

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    if self.isEnd then
        self.tabView:reloadData()
        self.tabView:setScrollToBegin()
    else
        self.tabView:reloadData()
        self.tabView:setScrollToEnd()

        self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function ()
        if self.txtDelayTime then
            self.txtDelayTime:setText("00:"..string.format("%02d",self.cutTime))
        end
        print('self.cutTime = ',self.cutTime) 
            if self.cutTime <= 0 then
                self:refreshTeamInfoByIndex()
            else
                self.cutTime = self.cutTime - 1
                if self.txtDelayTime then
                    self.txtDelayTime:setText("00:"..string.format("%02d",self.cutTime))
                end
            end
        end)
    end

    self:moveFont()
end

function FactionRecordNew:getPlayerInfo( desTable, playerId)
    for k,v in pairs(desTable) do
        if v.playerId == playerId then
            return v
        end
    end
    return nil
end

function FactionRecordNew:refreshMemberHead()
    local atkDeathPlayer = {}
    local defDeathPlayer = {}

    local fightCount = self.currFightIndex

    if self.isEnd then
        fightCount = #self.fightRecordData
    elseif fightCount ~= 0 then
        fightCount = fightCount - 2
    end

    for i=2,fightCount do
        local data = self.fightRecordData[i]
        if data and data.winPlayerId then
            if data.winPlayerId == data.atkPlayerId then
                defDeathPlayer[#defDeathPlayer + 1] = data.defPlayerId or 0
            else
                atkDeathPlayer[#atkDeathPlayer + 1] = data.atkPlayerId or 0
            end
        end
    end
    -- print('self.fightRecordData = ',self.fightRecordData)
    -- print('atkDeathPlayer = ',atkDeathPlayer)
    -- print('defDeathPlayer = ',defDeathPlayer)

    local function checkInTablePlayer( tbl, playerId )
        for k,v in pairs(tbl) do
            if v == playerId then
                return true
            end
        end
        return false
    end

    local function getLeaderDataIndex( tbl )
         for k,v in pairs(tbl) do
            if v.isLeader then
                return k
            end
        end
        return 1
    end


    for k,v in pairs(self.atkMember) do
        local data = self.atkMemberInfo[k]
        if k == 1 then
            local leaderIndex = getLeaderDataIndex(self.atkMemberInfo)
            data = self.atkMemberInfo[leaderIndex]
        else
            data = self.atkMemberInfo[k-1]
        end

        if data then
            v.headIcon:setVisible(true)            
            v.txtName:setVisible(true)
            local RoleIcon = RoleData:objectByID(data.profession)
            v.headIcon:setTexture(RoleIcon:getIconPath())
            Public:addFrameImg(v.headIcon,data.headPicFrame)
            Public:addInfoListen(v.headIcon,true,3,data.playerId)
            v.txtName:setText(data.name)

            if checkInTablePlayer(atkDeathPlayer, data.playerId) then
                v.imgkill:setVisible(true)
            else
                v.imgkill:setVisible(false)
            end
        else
            v.headIcon:setVisible(false)
            v.imgkill:setVisible(false)
            v.txtName:setVisible(false)
        end
    end


    for k,v in pairs(self.defMember) do
        local data = self.defMemberInfo[k]
        if k == 1 then
            local leaderIndex = getLeaderDataIndex(self.defMemberInfo)
            data = self.defMemberInfo[leaderIndex]
        else
            data = self.defMemberInfo[k-1]
        end

        if data then
            v.headIcon:setVisible(true)            
            v.txtName:setVisible(true)
            local RoleIcon = RoleData:objectByID(data.profession)
            v.headIcon:setTexture(RoleIcon:getIconPath())
            Public:addFrameImg(v.headIcon,data.headPicFrame)
            Public:addInfoListen(v.headIcon,true,3,data.playerId)
            v.txtName:setText(data.name)
            if checkInTablePlayer(defDeathPlayer, data.playerId) then
                v.imgkill:setVisible(true)
            else
                v.imgkill:setVisible(false)
            end
        else
            v.headIcon:setVisible(false)
            v.imgkill:setVisible(false)
            v.txtName:setVisible(false)
        end
    end

    print('self.currFightIndex = ',self.currFightIndex)
    print('self.isEnd = ',self.isEnd)
    if self.isEnd or self.currFightIndex >= 3 then
        local data = self.fightRecordData[1]
        if data and data.winPlayerId then
            if data.winPlayerId == data.atkPlayerId then
                self.defMember[1].imgkill:setVisible(true)
                self.atkMember[1].imgkill:setVisible(false)
            else
                self.atkMember[1].imgkill:setVisible(true)
                self.defMember[1].imgkill:setVisible(false)
            end
        end
    end
end

function FactionRecordNew:refreshGuildInfo()

    local atkGuildBuf = false
    local defGuildBuf = false
    local isEnd,currFightIndex = FactionFightManager:getStateByTeamIndex(self.selectTeamIndex)
    if isEnd or currFightIndex > 1 then
        local fightRecord = FactionFightManager:getTeamInfoByIndex(self.selectTeamIndex)
        if fightRecord and fightRecord[1] then
            if fightRecord[1].winPlayerId == fightRecord[1].atkPlayerId then
                atkGuildBuf = true
            else
                defGuildBuf = true
            end
        end
    end

    local atkGuildData,defGuildData = FactionFightManager:getGuildDataInfo()
    for i=1,3 do
        self.atkGuildBuf[i]:setVisible(false)
    end

    if atkGuildData and atkGuildData.name then
        self.atkImgEmpty:setVisible(false)
        self.atkGuildName:setVisible(true)
        self.atkGuildName:setText(atkGuildData.name)
        self.atkGuildBannerBg:setTexture(FactionManager:getGuildBannerBgPath(atkGuildData.bannerId))
        self.atkGuildBannerIcon:setTexture(FactionManager:getGuildBannerIconPath(atkGuildData.bannerId))

        -- local bufIndex = 1
        if atkGuildBuf then
            self.atkGuildBuf[1]:setVisible(true)
            self.atkGuildBuf[1]:setText(TFLanguageManager:getString(ErrorCodeData.Guild_War_Output + self.selectTeamIndex - 1))
        end
        -- for i=1,3 do
        --     if atkGuildBuf[i] then
        --         self.atkGuildBuf[bufIndex]:setVisible(true)                
        --         self.atkGuildBuf[bufIndex]:setText(TFLanguageManager:getString(ErrorCodeData.Guild_War_Output + i - 1))
        --         bufIndex = bufIndex + 1
        --     end
        -- end
    else
        self.atkImgEmpty:setVisible(true)
        self.atkGuildName:setVisible(false)
    end

    for i=1,3 do
        self.defGuildBuf[i]:setVisible(false)
    end
    if defGuildData and defGuildData.name then
        self.defImgEmpty:setVisible(false)
        self.defGuildName:setVisible(true)        
        self.defGuildName:setText(defGuildData.name)
        self.defGuildBannerBg:setTexture(FactionManager:getGuildBannerBgPath(defGuildData.bannerId))
        self.defGuildBannerIcon:setTexture(FactionManager:getGuildBannerIconPath(defGuildData.bannerId))
        if defGuildBuf then
            self.defGuildBuf[1]:setVisible(true)
            self.defGuildBuf[1]:setText(TFLanguageManager:getString(ErrorCodeData.Guild_War_Output + self.selectTeamIndex - 1))
        end
        -- local bufIndex = 1
        -- for i=1,3 do
        --     if defGuildBuf[i] then
        --         self.defGuildBuf[bufIndex]:setVisible(true)
        --         self.defGuildBuf[bufIndex]:setText(TFLanguageManager:getString(ErrorCodeData.Guild_War_Output + i - 1))
        --         bufIndex = bufIndex + 1
        --     end
        -- end
    else
        self.defImgEmpty:setVisible(true)
        self.defGuildName:setVisible(false)        
    end
    self.img_diyi:setTexture('ui_new/faction/fight/img_di'..self.selectTeamIndex..'.png')
end


function FactionRecordNew:refreshBtnView()

end

function FactionRecordNew.leftBtnClick( btn )
    local self = btn.logic
    if self.selectTeamIndex == 1 then
        return
    end
    if self.fontMoveTime then
        TFDirector:removeTimer(self.fontMoveTime)
        self.fontMoveTime = nil
    end
    if self.delayViewTime then
        TFDirector:removeTimer(self.delayViewTime)
        self.delayViewTime = nil
    end    

    self.selectTeamIndex = self.selectTeamIndex - 1
    self:refreshTeamInfoByIndex()
end

function FactionRecordNew.rightBtnClick( btn )
    local self = btn.logic
    if self.selectTeamIndex == 3 then
        return
    end
    if self.fontMoveTime then
        TFDirector:removeTimer(self.fontMoveTime)
        self.fontMoveTime = nil
    end
    if self.delayViewTime then
        TFDirector:removeTimer(self.delayViewTime)
        self.delayViewTime = nil
    end    

    self.selectTeamIndex = self.selectTeamIndex + 1
    self:refreshTeamInfoByIndex()
end

function FactionRecordNew:moveFont()   
    if self.fontMoveTime then
        return
    else
        for i=1,11 do
            self.atkMember[i].txtName:setPosition(ccp(0,0))
            self.defMember[i].txtName:setPosition(ccp(0,0))
        end        
    end
    if self.delayViewTime then
        TFDirector:removeTimer(self.delayViewTime)
        self.delayViewTime = nil
    end

    self.fontMoveTime = TFDirector:addTimer(200, -1, 
        nil,
        function()
            --每次进来            
            local isNeedReset = true
            for i=1,11 do
                -- if self.atkMember[i]
                local clipSize = self.atkMember[i].node:getContentSize().width
                local fontSize = self.atkMember[i].txtName:getContentSize().width -- + math.ceil(clipSize/2 + self.gonggao:getPositionX())
                local offsetX = fontSize - clipSize + self.atkMember[i].txtName:getPositionX()
                if offsetX > 0 then
                    
                    self.atkMember[i].txtName:setPositionX(self.atkMember[i].txtName:getPositionX() - 2)     
                    isNeedReset = false       
                end
                local clipSize = self.defMember[i].node:getContentSize().width
                local fontSize = self.defMember[i].txtName:getContentSize().width -- + math.ceil(clipSize/2 + self.gonggao:getPositionX())
                local offsetX = fontSize - clipSize + self.defMember[i].txtName:getPositionX()
                if offsetX > 0 then
                    
                    self.defMember[i].txtName:setPositionX(self.defMember[i].txtName:getPositionX() - 2)     
                    isNeedReset = false       
                end
            end
            if isNeedReset then
                if self.fontMoveTime then
                    TFDirector:removeTimer(self.fontMoveTime)
                    self.fontMoveTime = nil
                end
                if self.delayViewTime then
                    TFDirector:removeTimer(self.delayViewTime)
                    self.delayViewTime = nil
                end
                self.delayViewTime = TFDirector:addTimer(2000, 2,
                    function ()
                        self:moveFont()
                    end,
                    function ()
                        for i=1,11 do
                            self.atkMember[i].txtName:setPosition(ccp(0,0))
                            self.defMember[i].txtName:setPosition(ccp(0,0))
                        end
                    end)
            end
        end)
end

function FactionRecordNew.onReplayClick( btn )
    local replayId = btn.replayId
    if replayId and replayId ~= 0 then
        WeekRaceManager:requestPlayVideo( replayId )
    end
end
function FactionRecordNew.closeBtnClick( btn )
    local self = btn.logic
    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end
    if self.fontMoveTime then
        TFDirector:removeTimer(self.fontMoveTime)
        self.fontMoveTime = nil
    end
    if self.delayViewTime then
        TFDirector:removeTimer(self.delayViewTime)
        self.delayViewTime = nil
    end  
    AlertManager:close()
end

function FactionRecordNew.tableScroll(table)
    local self = table.logic
    local currPosY = self.tabView:getContentOffset().y
    local sizeHeight = self.tabViewUI:getContentSize().height
    local initY = sizeHeight - (80*(self.currFightIndex - 1) + 23) + 2

    -- print('initY = ',initY)
    -- print('currPosY = ',currPosY)
    if currPosY < initY then
        self.img_line2:setVisible(false)
    else
        self.img_line2:setVisible(true)
    end
end
return FactionRecordNew