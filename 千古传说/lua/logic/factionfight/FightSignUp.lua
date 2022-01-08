--[[
******帮派战-参赛报名*******

	-- by quanhuan
	-- 2016/2/23
	
]]

local FightSignUp = class("FightSignUp",BaseLayer)

local MaxQueueNum = 3
local leaderData = {}
local memberData = {}
local btnTexture = {}
function FightSignUp:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionSignUp")
end

function FightSignUp:initUI( ui )

	self.super.initUI(self, ui)

    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")

    self.queueList = {}
    self.cellModel = nil
    for i=1,MaxQueueNum do
        self.queueList[i] = {}
        local queueNode = TFDirector:getChildByPath(ui, 'panel_zhenlie'..i)
        local leaderNode = TFDirector:getChildByPath(queueNode, 'img_jingying')

        self.queueList[i].btnLeaderAdd = TFDirector:getChildByPath(queueNode, 'img_jingying')
        self.queueList[i].btnLeaderAdd:setTouchEnabled(true)
        self.queueList[i].btnLeaderJia = TFDirector:getChildByPath(leaderNode, 'btn_jiahao')
        self.queueList[i].btnLeaderJia:setTouchEnabled(false)
        self.queueList[i].imgLeaderHead = TFDirector:getChildByPath(leaderNode, 'img_touxiang')
        self.queueList[i].txtLeaderName = TFDirector:getChildByPath(leaderNode, 'txt_name')
        self.queueList[i].txtLeaderPower = TFDirector:getChildByPath(leaderNode, 'txt_num')
        self.queueList[i].txtZhanli = TFDirector:getChildByPath(leaderNode, 'txt_zhanli')        

        self.queueList[i].txtLeaderAdd = TFDirector:getChildByPath(queueNode, 'txt_nameadd')
        self.queueList[i].btnSignUp = TFDirector:getChildByPath(queueNode, 'btn_liji')
        self.queueList[i].txt_nameExt = TFDirector:getChildByPath(queueNode, 'txt_nameExt')

        --创建TabView
        local tabViewUI = TFDirector:getChildByPath(queueNode,"Panel_role")
        local tabView =  TFTableView:create()
        tabView:setTableViewSize(tabViewUI:getContentSize())
        tabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
        tabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
        tabView.logic = self
        tabViewUI:addChild(tabView)
        tabView:setPosition(ccp(0,0))
        self.queueList[i].tabView = tabView

        local memberNode = TFDirector:getChildByPath(queueNode, 'panel_role1')
        memberNode:setVisible(false)

        if self.cellModel == nil then
            self.cellModel = TFDirector:getChildByPath(queueNode, 'panel_role1')
            self.cellModel:setVisible(false)
        end     
    end
end


function FightSignUp:removeUI()
	self.super.removeUI(self)
end

function FightSignUp:onShow()
    self.super.onShow(self)
end

function FightSignUp:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    for k,v in pairs(self.queueList) do
        self.queueList[k].btnLeaderAdd:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnLeaderAddClick))
        self.queueList[k].btnLeaderAdd.logic = self
        self.queueList[k].btnLeaderAdd.idx = k

        self.queueList[k].btnSignUp:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnSignUpClick))
        self.queueList[k].btnSignUp.logic = self
        self.queueList[k].btnSignUp.idx = k

        self.queueList[k].tabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
        self.queueList[k].tabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
        self.queueList[k].tabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
        self.queueList[k].tabView.logic = self
        self.queueList[k].tabView.idx = k        
    end

    self.guildMemberUpdateCallBack = function(event)
       self:dataReady()
    end
    TFDirector:addMEGlobalListener(FactionFightManager.guildMemberUpdate ,self.guildMemberUpdateCallBack )


    self.registerEventCallFlag = true 
end

function FightSignUp:removeEvents()

    self.super.removeEvents(self)

    for k,v in pairs(self.queueList) do
        self.queueList[k].btnLeaderAdd:removeMEListener(TFWIDGET_CLICK)
        self.queueList[k].btnSignUp:removeMEListener(TFWIDGET_CLICK)

        self.queueList[k].tabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
        self.queueList[k].tabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
        self.queueList[k].tabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    end

    if self.guildMemberUpdateCallBack then
        TFDirector:removeMEGlobalListener(FactionFightManager.guildMemberUpdate,self.guildMemberUpdateCallBack)    
        self.guildMemberUpdateCallBack = nil
    end
    self.registerEventCallFlag = nil  
end

function FightSignUp:dispose()
	self.super.dispose(self)
end

function FightSignUp.btnLeaderAddClick( btn )
    --选择精英
    if FactionManager:getPostInFaction() ~= 1 then
        --toastMessage("权限不够")
	toastMessage(localizable.common_no_power)
        return
    end    
    local layer = require("lua.logic.factionfight.FactionSignUpChoose"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:dataReady(btn.idx)
    AlertManager:show()
end

function FightSignUp.btnSignUpClick( btn )
    --报名
    local self = btn.logic
    local teamIndex = btn.idx
    if self:checkMySelfInTeam(teamIndex) then
        --取消报名
        FactionFightManager:requestCancelSignUp()
    else
        FactionFightManager:requestSignUp(teamIndex-1)
    end
end

function FightSignUp:checkMySelfInTeam(teamIndex)
    for k, v in pairs(memberData[teamIndex]) do
        if v.playerId == MainPlayer:getPlayerId() then
            return true
        end
    end
    return false
end

function FightSignUp.cellSizeForTable(table,idx)
    return 80,230
end

function FightSignUp.numberOfCellsInTableView(table)
    local self = table.logic;
    local idx = table.idx
    return 10
end

function FightSignUp.tableCellAtIndex(table, idx)

    local self = table.logic;
    local tableIdx = table.idx
    
    local cell = table:dequeueCell()
    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModel:clone()
        panel:setPosition(ccp(0,0))
        cell:addChild(panel)
        panel:setTag(10086)
        panel:setVisible(true)
    else
        panel = cell:getChildByTag(10086)
    end
    idx = idx + 1

    local img_putongdi = TFDirector:getChildByPath(panel, 'img_putongdi')
    local img_putong = TFDirector:getChildByPath(panel, 'img_putong')
    local img_tou = TFDirector:getChildByPath(panel, 'img_tou')
    local img_touxiang = TFDirector:getChildByPath(panel, 'img_touxiang')
    local txt_name = TFDirector:getChildByPath(panel, 'txt_name')
    local txt_num = TFDirector:getChildByPath(panel, 'txt_num')

    local itemData = memberData[tableIdx][idx]
    if itemData then
        img_putongdi:setVisible(false)
        img_putong:setVisible(true)

        local RoleIcon = RoleData:objectByID(itemData.profession)
        if RoleIcon then
            img_touxiang:setTexture(RoleIcon:getIconPath())
            Public:addFrameImg(img_touxiang,itemData.headPicFrame)
            Public:addInfoListen(img_touxiang,true,3,itemData.playerId)
            txt_name:setText(itemData.playerName)
            txt_num:setText(itemData.power)
        else
            img_putongdi:setVisible(true)
            img_putong:setVisible(false)
        end
    else
        img_putongdi:setVisible(true)
        img_putong:setVisible(false)
    end

    return cell
end

function FightSignUp:updateMemberInfo()
    for i=1,MaxQueueNum do        
        leaderData[i] = {}
        memberData[i] = {}
        btnTexture[i] = 'ui_new/faction/fight/btn_baoming2.png'
        self.queueList[i].tabView:reloadData()
    end
    FactionFightManager:requestGuildMember()
end

function FightSignUp:dataReady()
    for i=1,MaxQueueNum do        
        leaderData[i] = FactionFightManager:getLeaderDataByIndex(i)
        memberData[i] = FactionFightManager:getMemberDataByIndex(i)
        if self:checkMySelfInTeam(i) then
            btnTexture[i] = 'ui_new/faction/fight/btn_quxiao.png'
        else
            btnTexture[i] = 'ui_new/faction/fight/btn_baoming2.png'
        end
        self.queueList[i].tabView:reloadData()
    end
    self:showLeaderData()


end

function FightSignUp:showLeaderData()

    for i=1,MaxQueueNum do        
        local item = leaderData[i]
        -- print('leaderData = ',leaderData)
        local RoleIcon = RoleData:objectByID(item.profession)
        if RoleIcon then
            self.queueList[i].txtZhanli:setVisible(true)
            self.queueList[i].imgLeaderHead:setVisible(true)
            self.queueList[i].txtLeaderName:setVisible(true)
            self.queueList[i].btnLeaderJia:setVisible(false)

            self.queueList[i].imgLeaderHead:setTexture(RoleIcon:getIconPath())
            Public:addFrameImg(self.queueList[i].imgLeaderHead,item.headPicFrame)
            Public:addInfoListen(self.queueList[i].imgLeaderHead,true,3,item.playerId)
            self.queueList[i].txtLeaderName:setText(item.playerName)
            self.queueList[i].txtLeaderPower:setText(item.power)
        else
            self.queueList[i].txtZhanli:setVisible(false)
            self.queueList[i].imgLeaderHead:setVisible(false)
            self.queueList[i].txtLeaderName:setVisible(false)
            self.queueList[i].btnLeaderJia:setVisible(true)
        end

        if FactionManager:getPostInFaction() ~= 1 then
            self.queueList[i].btnLeaderJia:setVisible(false)
        end

        self.queueList[i].btnSignUp:setTextureNormal(btnTexture[i])
        --self.queueList[i].txt_nameExt:setText("获胜可得:"..TFLanguageManager:getString(ErrorCodeData.Guild_War_Output + i - 1))
	self.queueList[i].txt_nameExt:setText(localizable.GUILD_WAR_MSG[i])
    end
end
return FightSignUp