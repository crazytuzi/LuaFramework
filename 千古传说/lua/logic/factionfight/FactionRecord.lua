--[[
    -- 实时战况
	-- by yongkang
	-- 2016-02-24	
]]

local FactionRecord = class("FactionRecord", BaseLayer)

function FactionRecord:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.faction.FactionRecord")
    self.replayInfos = {}
end

function FactionRecord:initUI(ui)
    self.super.initUI(self, ui)

    self.backBtn = TFDirector:getChildByPath(ui, "btn_return")
    self.table_content = TFDirector:getChildByPath(ui, "panel_huadong")

    self.img_title = TFDirector:getChildByPath(ui, "img_diyi")

    -- 头部帮派信息
    self.panel_team1 = TFDirector:getChildByPath(ui, "Panel_team1")
    self.panel_bangpai = { }
    for i = 1, 2 do
        self.panel_bangpai[i] = { }
        self.panel_bangpai[i].node = TFDirector:getChildByPath(self.panel_team1, "panel_bangpai" .. i)
        self.panel_bangpai[i].img_qizhi = TFDirector:getChildByPath(self.panel_bangpai[i].node, "img_qizhi")
        self.panel_bangpai[i].img_biaozhi = TFDirector:getChildByPath(self.panel_bangpai[i].node, "img_qizhi")
        self.panel_bangpai[i].txt_name = TFDirector:getChildByPath(self.panel_bangpai[i].node, "img_qizhi")
        self.panel_bangpai[i].txt_status1 = TFDirector:getChildByPath(self.panel_bangpai[i].node, "txt_zhuangtai1")
        self.panel_bangpai[i].txt_status2 = TFDirector:getChildByPath(self.panel_bangpai[i].node, "txt_zhuangtai2")
        self.panel_bangpai[i].txt_status3 = TFDirector:getChildByPath(self.panel_bangpai[i].node, "txt_zhuangtai3")

    end
    -- 中部队员详细信息
    self.team_node_1 = { }
    self.team_node_2 = { }
    self.panel_team_detail_1 = { }
    self.panel_team_detail_2 = { }
    self.gonggao = { }
    for j = 1, 2 do
        self["team_node_" .. j] = TFDirector:getChildByPath(ui, "img_huangdi" .. j)
        self["panel_team_detail_" .. j] = { }

        for i = 1, 11 do
            self["panel_team_detail_" .. j][i] = { }
            -- 头像信息
            self["panel_team_detail_" .. j][i].node = TFDirector:getChildByPath(self["team_node_" .. j], "img_tou" .. i)
            self["panel_team_detail_" .. j][i].btn_jiahao = TFDirector:getChildByPath(self["panel_team_detail_" .. j][i].node, "btn_jiahao")
            self["panel_team_detail_" .. j][i].img_touxiang = TFDirector:getChildByPath(self["panel_team_detail_" .. j][i].node, "img_touxiang")
            self["panel_team_detail_" .. j][i].img_sb = TFDirector:getChildByPath(self["panel_team_detail_" .. j][i].node, "img_sb")
            -- 名字信息
            self["panel_team_detail_" .. j][i].panel_name = TFDirector:getChildByPath(self["team_node_" .. j], "panel_gundong" .. i)
            self["panel_team_detail_" .. j][i].txt_name = TFDirector:getChildByPath(self["panel_team_detail_" .. j][i].panel_name, "txt_jingy")
        end
    end

    self.oldIndex = 0

end

function FactionRecord:setData(round,index)
    self.round = round
    self.index = index
    FactionFightManager:requireRePlayeInfos(round,index)
end

function FactionRecord:initData()
    local fightCD = 15 --战斗一场CD
    local currtime =0  --当前时间
    
    self.atkInfos = {}
    self.defInfos ={}
    self.replays ={}

    --self.replayInfos = FactionFightManager:getReplayInfosRound()
    local currRound ,bOverRound, fightIndex, curr_replays_team ,replays_team ,atkInfos,defInfos = FactionFightManager:getReplayInfosRound()

    self.atkInfos = atkInfos or {}
    self.defInfos = defInfos or atkInfos

    self:initDataTeam()
    --[[
    self.atkInfos = self.replayInfos.atkGuildMemberInfo.infos
    self.defInfos = self.replayInfos.defGuildMemberInfo.infos
    self.replays = self.replayInfos.replays

    --分3队计算  每一队需要的时间
    self.replays_team_1 = {}
    self.replays_team_2 = {}
    self.replays_team_3 = {}
    --当前小队的数据
    self.curr_replays_team = {}

    for i=1,#self.replays do
        if self.replays[i].team == 0 then
            table.insert(self.replays_team_1,self.replays[i])
        elseif self.replays[i].team == 1 then
            table.insert(self.replays_team_2,self.replays[i])
        elseif self.replays[i].team == 2 then
            table.insert(self.replays_team_2,self.replays[i])
        end    
    end

    self.currRound = 1 --当前场次
    --if self.fightCD *
    self.bOverRound_1 = false --是否打完
    self.bOverRound_2 = false --是否打完
    self.bOverRound_3 = false --是否打完

    self.iRoundTime = 0 --一小队的时间

    if self.currtime > self.fightCD * #self.replays then --时间大于所有的时间 所有的都打完了
        self.currRound = 3
        self.bOver = true       
    else
        if self.currtime > self.fightCD * (#self.replays_team_1 + #self.replays_team_2) then --处于第三场
            self.currRound = 3 
            self.bOverRound_1 = true 
            self.bOverRound_2 = true 
            self.iRoundTime = self.currtime - self.fightCD * (#self.replays_team_1 + #self.replays_team_2)
            self.fightIndex = math.modf(self.iRoundTime / self.fightCD)
            self.curr_replays_team = self:getCurrReplayTeamInfo(self.fightIndex,self.replays_team_3)
        elseif  self.currtime >self.fightCD * (#self.replays_team_1) then --处于第二场
            self.currRound = 2
            self.bOverRound_1 = true
            self.iRoundTime =  self.currtime - self.fightCD * (#self.replays_team_1)

            self.fightIndex = math.modf(self.iRoundTime / self.fightCD)
            self.curr_replays_team = self:getCurrReplayTeamInfo(self.fightIndex,self.replays_team_2)

        else  --处于第一场
            self.currRound = 1
            self.iRoundTime = self.currtime

            self.fightIndex = math.modf(self.iRoundTime / self.fightCD)
            self.curr_replays_team = self:getCurrReplayTeamInfo(self.fightIndex,self.replays_team_1)
        end    
    end  
    self.oldIndex = self.fightIndex
    --self.currFightTime = math.fmod(self.iRoundTime ,self.fightCD) --这一场战斗到的时间
    ]]
    --self:initDataByTeam(self.currRound)
    --self:initTableviewData()
end


function FactionRecord:getCurrReplayTeamInfo(teamIndex,teams)
    local tempTeams ={}
    if teamIndex > #teams then
        return tempTeams
    else     
        for i=1,teamIndex do
            table.insert(tempTeams,teams[i])
        end
    end
    return tempTeams
end


function FactionRecord:initDataTeam()
   
    --local info = 
    local atkBattleInfos = self.atkInfos.battleInfo
    local defBattleInfos = self.defInfos.battleInfo

    --精英算2个头像
    table.insert(atkBattleInfos,1,atkBattleInfos[1])
    table.insert(defBattleInfos,1,defBattleInfos[1])

    local atkeliteId = tonumber(self.atkInfos.eliteId)
    local defeliteId = tonumber(self.defInfos.eliteId)

    local j = 1
    if atkeliteId == 0 then  --攻击方没有人        
        for i = 1, 11 do                    
            self["panel_team_detail_" .. j][i].img_touxiang:setVisible(false)
            self["panel_team_detail_" .. j][i].img_sb:setVisible(false)
            -- 名字信息
            self["panel_team_detail_" .. j][i].panel_name:setVisible(false)
        end
    else
        for i=1,#atkBattleInfos do
            self["panel_team_detail_" .. j][i].img_touxiang:setVisible(true)
            --self["panel_team_detail_" .. j][i].img_sb:setVisible(true)
            -- 名字信息
            self["panel_team_detail_" .. j][i].panel_name:setVisible(true)
            
            self["panel_team_detail_" .. j][i].img_touxiang:setTexture(self:getHeadIconByProfession(atkBattleInfos[i].profession))
            self["panel_team_detail_" .. j][i].txt_name:setText(atkBattleInfos[i].name)
        end

        for i=#atkBattleInfos + 1 , 11 do
            self["panel_team_detail_" .. j][i].img_touxiang:setVisible(false)
            self["panel_team_detail_" .. j][i].img_sb:setVisible(false)
            -- 名字信息
            self["panel_team_detail_" .. j][i].panel_name:setVisible(false)
        end


    end

    j = 2
    if defeliteId == 0 then --防守方没有人        
        for i = 1, 11 do                    
            self["panel_team_detail_" .. j][i].img_touxiang:setVisible(false)
            self["panel_team_detail_" .. j][i].img_sb:setVisible(false)
            -- 名字信息
            self["panel_team_detail_" .. j][i].panel_name:setVisible(false)
        end
    else   
        for i=1,#defBattleInfos do
            self["panel_team_detail_" .. j][i].img_touxiang:setVisible(true)
            --self["panel_team_detail_" .. j][i].img_sb:setVisible(true)
            -- 名字信息
            self["panel_team_detail_" .. j][i].panel_name:setVisible(true)
            
            self["panel_team_detail_" .. j][i].img_touxiang:setTexture(self:getHeadIconByProfession(defBattleInfos[i].profession))
            self["panel_team_detail_" .. j][i].txt_name:setText(defBattleInfos[i].name)
        end

        for i=#defBattleInfos + 1 , 11 do
            self["panel_team_detail_" .. j][i].img_touxiang:setVisible(false)
            self["panel_team_detail_" .. j][i].img_sb:setVisible(false)
            -- 名字信息
            self["panel_team_detail_" .. j][i].panel_name:setVisible(false)
        end
    end

    --todo  攻防头像计算完成
    --计算下方详细对战信息
end

function FactionRecord:initTableviewData()
   
    self:initTableview()

    if self.updateTimerID then
        TFDirector:removeTimer(self.updateTimerID)
        self.updateTimerID = nil
    end 

    self.updateTimerID = TFDirector:addTimer(1000, -1, nil,
    function()
        self:UpdateCDTime()
    end
    )
end


function FactionRecord:getHeadIconByProfession(profession)
    local role = RoleData:objectByID(profession)
    if role then
        return role:getIconPath()
    end
end

function FactionRecord:initNameTimer()

    self.updateNameTimerID = TFDirector:addTimer(1000, -1, nil,
    function()
        self:updateNameTimer()
    end )

end

function FactionRecord:updateNameTimer()
    for j = 1, 2 do
        for i = 1, 11 do
            -- self["panel_team_detail_" .. j][i].txt_name.cdTimer = 0
            local node = self["panel_team_detail_" .. j][i].txt_name
            local parentNode = self["panel_team_detail_" .. j][i].panel_name

            local clipWidth = parentNode:getContentSize().width
            local fontWidth = node:getContentSize().width

            if clipWidth < fontWidth then
                local moveX = 10
                local times = math.ceil((fontWidth - clipWidth) / 10)

                local currX = node:getPositionX()
                currX = currX - 5
                node:setPositionX(currX)
                print("currX==" .. currX)
                --print(moveTimes .. "-")
                local max_x = clipWidth - fontWidth
                if currX < max_x - 10 then
                    node:setPositionX(0)
                end
            end
        end
    end
end

function FactionRecord:initTableview()
    -- body
    local tableview = TFTableView:create()
    tableview:setTableViewSize(self.table_content:getContentSize())
    tableview:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableview:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableview:setPosition(self.table_content:getPosition())
    self.tableview = tableview
    self.tableview.logic = self

    self.tableview:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tableview:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tableview:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tableview:reloadData()

    self.table_content:getParent():addChild(self.tableview)


    local tb_pos = self.tableview:getContentOffset();
    -- self.table_select:reloadData();
    local currentSize = self.tableview:getContentSize()
    local tabSize = self.tableview:getSize()
    tb_pos.y = math.max(tb_pos.y, tabSize.height - currentSize.height)

    -- tb_pos.y  = 0
    -- self.tableview:setContentOffset(tb_pos,25)
end


function FactionRecord.numberOfCellsInTableView(table)
    local self = table.logic

    if self.currRound == 1 and self.bOverRound_1 then
        return #self.replays_team_1
    elseif self.currRound == 2 and self.bOverRound_2 then
        return #self.replays_team_2
    elseif self.currRound == 3 and self.bOverRound_3 then
        return #self.replays_team_3   
    else 
        return #self.curr_replays_team  
    end         
end

function FactionRecord.cellSizeForTable(table, idx)
--[[
    local self = table.logic
    local index = idx + 1
    local info = self.testData[index]
    if info.dataType == 0 or info.dataType == 1 then
        return 80, 680
    else
        return 22, 680
    end
    ]]
    return 80,680
end

function FactionRecord.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or { }
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = createUIByLuaNew("lua.uiconfig_mango_new.faction.FactionRecordCell")
        cell:addChild(node)
        node:setPosition(ccp(10, -10))
        node:setTag(617)
        node.logic = self
    end
    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawCell(node)
    node:setVisible(true)
    return cell
end


function FactionRecord:drawCell(node)
    -- body
    local panel_jingying = TFDirector:getChildByPath(node, 'panel_jingying')
    local panel_putong = TFDirector:getChildByPath(node, 'panel_putong')
    local panel_txt = TFDirector:getChildByPath(node, 'panel_txt')

    local img_jy_bg1 = TFDirector:getChildByPath(panel_jingying, 'img_hongdi1')
    local img_jy_bg2 = TFDirector:getChildByPath(panel_jingying, 'img_hongdi2')

    local txt_jy_name1 = TFDirector:getChildByPath(img_jy_bg1, 'txt_name')
    local txt_jy_name2 = TFDirector:getChildByPath(img_jy_bg2, 'txt_name')

    local img_pt_bg1 = TFDirector:getChildByPath(panel_putong, 'img_hongdi1')
    local img_pt_bg2 = TFDirector:getChildByPath(panel_putong, 'img_hongdi2')

    local txt_pt_name1 = TFDirector:getChildByPath(img_pt_bg1, 'txt_name')
    local txt_pt_name2 = TFDirector:getChildByPath(img_pt_bg2, 'txt_name')

    --local info = self.testData[node.index]
    --[[
    if info.dataType == 0 then
        panel_jingying:setVisible(false)
        panel_putong:setVisible(true)
        panel_txt:setVisible(false)
        txt_pt_name1:setText(info.name)
        txt_pt_name2:setText(info.name)
    elseif info.dataType == 1 then
        panel_jingying:setVisible(true)
        panel_putong:setVisible(false)
        panel_txt:setVisible(false)
        txt_jy_name1:setText(info.name)
        txt_jy_name2:setText(info.name)
    else
        panel_jingying:setVisible(false)
        panel_putong:setVisible(false)
        panel_txt:setVisible(true)
    end
    ]]
end

function FactionRecord:UpdateCDTime()
    --self.cd = tonumber(self.cd) -1

    --self.fightCD = 10
    self.newIndex = math.ceil(self.currtime /  self.fightCD)
    if self.newIndex ~= self.oldIndex then
        table.insert(self.curr_replays_team,self["replays_team_"..self.currRound][self.newIndex]) 
        self.tableview:reloadData()

        local cell_h_max = 80
        local cell_h_min = 22

        local tb_pos = self.tableview:getContentOffset();
        local tb_pos_old = self.tableview:getContentOffset(); --新增数据后的offset

        local currentSize = self.tableview:getContentSize()
        local tabSize = self.tableview:getSize()

        tb_pos.y = tabSize.height - currentSize.height
        tb_pos_old.y = tabSize.height - currentSize.height

        local numDx_old = cell_h_max * self.oldIndex
        tb_pos_old.y = tb_pos_old.y + numDx_old   --计算新增数据后原始偏移
        self.tableview:setContentOffset(tb_pos_old)  --先移动到原始位置  reloadData会导致从头开始

        local numDx = cell_h_max * self.newIndex
        tb_pos.y = tb_pos.y + numDx
        self.tableview:setContentOffset(tb_pos, 3)

        self.oldIndex = self.newIndex
    end

    self.currtime = self.currtime + 1

end


function FactionRecord:createTestData()
    -- dataType 0正常状态  1精英状态  2文字
    self.testData = { }    
    for i = 1 ,2  do
        table.insert(self.testData,{dataType = i % 3,name = stringUtils.format(localizable.faction_name, i)})
    end
     
    self.champInfoList = {}
    self.champInfoList[1] = {round = 1,index = 1}
end

function FactionRecord.backButtonClick(btn)
    AlertManager:close()
end

function FactionRecord:removeUI()
    self.super.removeUI(self)
end

function FactionRecord:onShow()
    self.super.onShow(self)
end

function FactionRecord:registerEvents()
    if self.registerEventCallFlag then
        return
    end
    self.super.registerEvents(self)

    self.backBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.backButtonClick))

    
     self.replayInfosCallBack = function (event)       
        self:initData()
        print("replayInfosCallBack")
    end
    TFDirector:addMEGlobalListener(FactionFightManager.onReplayInfosSuccess, self.replayInfosCallBack)
    

    self.registerEventCallFlag = true

end

function FactionRecord:removeEvents()
    self.super.removeEvents(self)

    if self.updateNameTimerID then
        TFDirector:removeTimer(self.updateNameTimerID)
        self.updateNameTimerID = nil
    end

    if self.updateTimerID then
        TFDirector:removeTimer(self.updateTimerID)
        self.updateTimerID = nil
    end

    TFDirector:removeMEGlobalListener(FactionFightManager.onReplayInfosSuccess, self.replayInfosCallBack)
    self.replayInfosCallBack = nil

    self.registerEventCallFlag = nil
end

function FactionRecord:dispose()
    self.super.dispose(self)
end

return FactionRecord