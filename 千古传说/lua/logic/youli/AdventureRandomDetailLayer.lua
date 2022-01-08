--[[
******奇遇随机事件-详情*******

    -- by quanhuan
    -- 2016/3/15
]]
local AdventureRandomDetailLayer = class("AdventureRandomDetailLayer", BaseLayer);

CREATE_SCENE_FUN(AdventureRandomDetailLayer);
CREATE_PANEL_FUN(AdventureRandomDetailLayer);

AdventureRandomDetailLayer.LIST_ITEM_WIDTH = 200

function AdventureRandomDetailLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.youli.MissionDetail");
    self.firstShow = true
end

function AdventureRandomDetailLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.powerTable = {0,0}

    self.btn_close          = TFDirector:getChildByPath(ui, 'Btn_close');
    self.btn_close:setVisible(false)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.youli,{HeadResType.BAOZI,HeadResType.YUELI,HeadResType.SYCEE}) 
    self.generalHead:setVisible(true)

    local bg_point = TFDirector:getChildByPath(ui, 'bg_point')
    bg_point:setVisible(false)
    --今日挑战次数
    self.txt_point            = TFDirector:getChildByPath(ui, 'txt_number')
    --推荐战斗力
    self.txt_zhanli            = TFDirector:getChildByPath(ui,'txt_zhanli')
    --今日免费次数
    self.txt_freequick        = TFDirector:getChildByPath(ui, 'txt_freequick')
    self.txt_freequick:setVisible(false)
    --消耗元宝
    self.img_qucikneed            = TFDirector:getChildByPath(ui, 'img_qucikneed')
    self.img_qucikneed:setVisible(false)
    self.txt_qucikneed            = TFDirector:getChildByPath(ui, 'txt_qucikneed')
    --关卡说明文字
    self.txt_storydetail          = TFDirector:getChildByPath(ui, 'txt_storydetail')
    --关卡名字
    self.txt_title          = TFDirector:getChildByPath(ui, 'txt_title')
    --胜利一场奖励
    self.panel_reward             = TFDirector:getChildByPath(ui, 'panel_reward')
    --胜利两场奖励
    self.panel_reward2          = TFDirector:getChildByPath(ui, 'panel_reward2')
    --敌人信息
    local texture = {
        [1] = {"ui_new/youli/btn_team1.png","ui_new/youli/btn_team1s.png"},
        [2] = {"ui_new/youli/btn_team2.png","ui_new/youli/btn_team2s.png"}
    }
    self.panel_buzhen = {}
    self.btn_team = {}
    self.button = {}
    self.panel_reward = {}
    self.panelBuzhenPos = {}
    for k=1,2 do
        self.panel_reward[k] = TFDirector:getChildByPath(ui, 'panel_reward'..k)
        self.panel_buzhen[k] = TFDirector:getChildByPath(ui, 'panel_buzhen'..k)
        self.btn_team[k] = TFDirector:getChildByPath(ui, 'btn_team'..k)   
        self.btn_team[k].selectTexture =  texture[k][2]
        self.btn_team[k].normalTexture =  texture[k][1]
        self.btn_team[k]:setZOrder(10)
        self.panelBuzhenPos[k] = self.panel_buzhen[k]:getPosition()
        for i=1,9 do
            local index = (k-1)*9 + i
            local panel = TFDirector:getChildByPath(ui, 'panel_buzhen'..k)

            local btnName = "panel_item" .. i;
            self.button[index] = TFDirector:getChildByPath(panel, btnName);

            btnName = "btn_icon"..i;
            -- print('k = ',k)
            -- print('self.button[index] = ',self.button)
            self.button[index].bg = TFDirector:getChildByPath(panel, btnName);
            self.button[index].bg:setVisible(false);

            self.button[index].icon = TFDirector:getChildByPath(self.button[index].bg ,"img_touxiang");
            self.button[index].icon:setVisible(false);

            self.button[index].img_zhiye = TFDirector:getChildByPath(self.button[index], "img_zhiye");
            self.button[index].img_zhiye:setVisible(false);

            self.button[index].quality = TFDirector:getChildByPath(panel, btnName);
        end
    end
    local bgTipsNode = TFDirector:getChildByPath(ui, "bg_xxxx")
    self.bg_xxxx = TFDirector:getChildByPath(bgTipsNode, "txt_xxxxx")
    self.bg_xxxx2 = TFDirector:getChildByPath(ui, "bg_xxxx2")

    --重置按钮
    self.btn_reset            = TFDirector:getChildByPath(ui, 'btn_reset')
    self.btn_reset:setVisible(false)
    
    self.btn_attack           = TFDirector:getChildByPath(ui, 'btn_attack')
    local img_newprice1 = TFDirector:getChildByPath(self.btn_attack,'img_newprice1')
    img_newprice1:setVisible(false)
    --布阵按钮
    self.btn_army             = TFDirector:getChildByPath(ui, 'btn_army')
    --佣兵按钮
    self.btn_yongbing         = TFDirector:getChildByPath(ui, 'btn_yongbing')
    self.btn_yongbing:setVisible(false)
    --扫荡按钮
    self.btn_quick1            = TFDirector:getChildByPath(ui, 'btn_quick1')
    self.btn_quick1:setVisible(false)
    self.btn_quick3               = TFDirector:getChildByPath(ui, 'btn_quick3')
    self.btn_quick3:setVisible(false)
    self.txt_quick_time           = TFDirector:getChildByPath(ui, 'LabelBMFont_MissionDetail_1')
    self.txt_quick_time:setVisible(false)
end

function AdventureRandomDetailLayer:loadData(missionId)

    self.missionId = missionId
    self.selectTeamIndex = 1
end

function AdventureRandomDetailLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();
    self:refreshBaseUI();

    self.generalHead:onShow()
    -- if self.firstShow == true then
    --     self.ui:runAnimation("Action0",1);
    --     self.firstShow = false
    -- end
end

function AdventureRandomDetailLayer:refreshBaseUI()

end

function AdventureRandomDetailLayer:refreshUI()

    if not self.isShow then
        return;
    end

    local mission = AdventureMissionManager:getMissionById(self.missionId)
    
    self.txt_title:setText( mission.name )
    self.txt_storydetail:setText(mission.desc)

    self:drawReward()

    local panelCount = 1
    self.btn_team[1]:setVisible(false)
    self.btn_team[2]:setVisible(false)
    self.panel_buzhen[2]:setVisible(false)
    if mission.fight_type == 4 then
        panelCount = 2
        self.btn_team[1]:setVisible(true)
        self.btn_team[2]:setVisible(true)
        self.panel_buzhen[2]:setVisible(true)
    end
    

    for k=1,panelCount do
        local power = 0
        local npcSetting = mission.npc
        if k == 2 then
            npcSetting = mission.second_npc
        end

        local npcs = NPCData:GetNPCListByIds(npcSetting)
        for i=1,9 do
            local role = npcs[i];
            local index = (k-1)*9 + i
            if  role ~= nil then
                power = power + adventureEventNpc:getPowerByLevelAndOccupation(MainPlayer:getLevel(), RoleData:objectByID(role.role_id).outline)

                self.button[index].icon:setVisible(true);
                self.button[index].icon:setTexture(role:getHeadPath());

                self.button[index].bg:setVisible(true);
                self.button[index].bg.role = role;

                self.button[index].bg.logic = self;
                self.button[index].bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);

                self.button[index].img_zhiye:setVisible(true);
                self.button[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. RoleData:objectByID(role.role_id).outline ..".png");
                
                self.button[index].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality))
            else
                self.button[index].img_zhiye:setVisible(false);  
                self.button[index].icon:setVisible(false);
                self.button[index].bg:setVisible(false);     
            end
        end

        if k == 2 then
            power = math.floor((mission.modulus/10000)*power)
        end
        self.powerTable[k] = power
    end

    self.btn_attack:setVisible(true)

    self.txt_zhanli:setText(self.powerTable[self.selectTeamIndex])
end

function AdventureRandomDetailLayer.cellClickHandle(sender)
    local self = sender.logic;
    local role = sender.role;

    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,MainPlayer:getLevel())
end

function AdventureRandomDetailLayer.onCloseClickHandle(sender)
    local self = sender.logic;
    -- self.ui:setAnimationCallBack("Action1", TFANIMATION_END, function()
        AlertManager:close()
    -- end)

    -- self.ui:runAnimation("Action1",1)
end

function AdventureRandomDetailLayer.onAttackClickHandle(sender)
    local self = sender.logic;
    local missionId = self.missionId
    AlertManager:close(AlertManager.TWEEN_NONE);
    AdventureManager:requestEventComplete( missionId )   
end

function AdventureRandomDetailLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    if self.selectTeamIndex == 1 then
        ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_DOUBLE_1, false)
    else
        ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_DOUBLE_2, false)
    end
end
function AdventureRandomDetailLayer.onMercenaryClickHandle(sender)
    -- local self = sender.logic;
    -- local missionId = self.missionId;
    -- EmployManager:openRoleList(function ()
    --     AlertManager:close()
    --     AlertManager:close()
    --     MissionManager:attackMission(missionId,EnumFightStrategyType.StrategyType_HIRE_TEAM);
    -- end)
end

--注册事件
function AdventureRandomDetailLayer:registerEvents()
    self.super.registerEvents(self);
    

    if self.generalHead then
        self.generalHead:registerEvents()
    end    
    self.btn_close:setClickAreaLength(100);
    self.ui:setTouchEnabled(true)
    self.btn_close.logic = self
    self.ui.logic = self
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1);
    self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1);

    self.btn_attack.logic = self;
    self.btn_attack:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1);

    for i=1,2 do
        self.btn_team[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnTeamClick),1);
        self.btn_team[i].logic = self
        self.btn_team[i].idx = i
    end

   self.btn_army.logic = self;
   self.btn_army:setVisible(true)
   self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1);

   self.btn_yongbing.logic = self;
   self.btn_yongbing:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onMercenaryClickHandle),1);

end

function AdventureRandomDetailLayer:removeEvents()
    self.firstShow = true
        if self.generalHead then
        self.generalHead:removeEvents()
    end
end

function AdventureRandomDetailLayer:drawReward()

    local mission = AdventureMissionManager:getMissionById(self.missionId)
    local panelCount = 1
    self.panel_reward[2]:setVisible(false)
    self.bg_xxxx2:setVisible(false)
    if mission.fight_type == 4 then
        self.bg_xxxx:setText(localizable.youli_reward_tips2)
        panelCount = 2
        self.bg_xxxx2:setVisible(true)
        self.panel_reward[2]:setVisible(true)
    else
        self.bg_xxxx:setText(localizable.youli_reward_tips1)
    end
    self.rewardList = {}
    self.tableView = self.tableView or {}
    for k=1,panelCount do
        local rewardList
        if k==1 then
            rewardList = DropGroupData:GetDropItemListByIdsStr(mission.reward_id)
            if mission.experience and mission.experience > 0 then
                rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.YUELI,number = mission.experience}))
            end
            if mission.coin and mission.coin > 0 then
                rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.COIN,number = mission.coin}))
            end
        else
            rewardList = DropGroupData:GetDropItemListByIdsStr(mission.second_reward_id)
            if mission.second_experience and mission.second_experience > 0 then
                rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.YUELI,number = mission.second_experience}))
            end
            if mission.second_coin and mission.second_coin > 0 then
                rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.COIN,number = mission.second_coin}))
            end
        end
        
        self.rewardList[k] = rewardList

        if self.tableView[k] == nil then

            local  tableView =  TFTableView:create()
            tableView:setTableViewSize(self.panel_reward[k]:getContentSize())
            tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
            tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
            tableView:setPosition(ccp(0,0))
            self.tableView[k] = tableView
            self.tableView[k].logic = self
            self.tableView[k].index = k

            tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
            tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
            tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
            tableView:reloadData()

            self.panel_reward[k]:addChild(self.tableView[k],1)
        else
            self.tableView[k]:reloadData()
        end
    end
end

function AdventureRandomDetailLayer.cellSizeForTable(table, idx)
    return 90, 82
end

function AdventureRandomDetailLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        
        local node = Public:createIconNumNode(reward)
        node:setScale(0.65)

        node:setPosition(ccp(0, 0))
        cell:addChild(node)
        cell.node = node
    end

    self:drawCell(cell, idx + 1, table.index)
    return cell
end

function AdventureRandomDetailLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local index = table.index
    local totalNum = self.rewardList[index]:length()
    return totalNum
end

function AdventureRandomDetailLayer:drawCell(cell, cellIndex, tableIndex)
    local node  = cell.node
    node.index = cellIndex
    node:setVisible(true)
    self:drawRewardNode(node, tableIndex)
end

function AdventureRandomDetailLayer:drawRewardNode(node,tableIndex)

    local index = node.index
    local totalNum = self.rewardList[1]:length()
    local rewardItem = self.rewardList[tableIndex]:getObjectAt(index)

    Public:loadIconNode(node,rewardItem)

    CommonManager:setRedPoint(node, MartialManager:dropRewardRedPoint(rewardItem), "dropRewardRedPoint", ccp(80,80))
end

function AdventureRandomDetailLayer.onBtnTeamClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if idx == self.selectTeamIndex or self.ismoveEnd then
        return
    end
    self:qieHuanAction()
end


--切换动作
function AdventureRandomDetailLayer:qieHuanAction()
    if self.ismoveEnd then
        return
    end
    self.ismoveEnd = true
    local move1 = CCMoveTo:create(0.2,ccp(self.panelBuzhenPos[2].x-50,self.panelBuzhenPos[2].y))
    local move2 = CCMoveTo:create(0.2,ccp(self.panelBuzhenPos[1].x+50,self.panelBuzhenPos[1].y))
    local move3 = CCMoveTo:create(0.2,ccp(self.panelBuzhenPos[2].x,self.panelBuzhenPos[2].y))
    local move4 = CCMoveTo:create(0.2,ccp(self.panelBuzhenPos[1].x,self.panelBuzhenPos[1].y))
 
    local function changeOrder()
        self.panel_buzhen[1]:setZOrder(1)
        self.panel_buzhen[2]:setZOrder(2)
    end
    local function changeOrder2()
        self.panel_buzhen[1]:setZOrder(2)
        self.panel_buzhen[2]:setZOrder(1)
    end
    local function moveEnd()
        self.ismoveEnd = false
        for i=1,2 do
            if i == self.selectTeamIndex then
                self.btn_team[i]:setTextureNormal(self.btn_team[i].selectTexture)
            else
                self.btn_team[i]:setTextureNormal(self.btn_team[i].normalTexture)
            end
        end
        self.txt_zhanli:setText(self.powerTable[self.selectTeamIndex])
    end
    if self.selectTeamIndex == 1 then
        self.selectTeamIndex = 2

        local act1 = CCSequence:createWithTwoActions(move1,move4)
        self.panel_buzhen[2]:runAction(act1)
        local act2 = CCSequence:createWithTwoActions(move2,CCCallFunc:create(changeOrder))
        local act3 = CCSequence:createWithTwoActions(act2,move3)
        self.panel_buzhen[1]:runAction(CCSequence:createWithTwoActions(act3,CCCallFunc:create(moveEnd)))
    else
        self.selectTeamIndex = 1

        local act1 = CCSequence:createWithTwoActions(move2,move3)
        self.panel_buzhen[2]:runAction(act1)
        local act2 = CCSequence:createWithTwoActions(move1,CCCallFunc:create(changeOrder2))
        local act3 = CCSequence:createWithTwoActions(act2,move4)
        self.panel_buzhen[1]:runAction(CCSequence:createWithTwoActions(act3,CCCallFunc:create(moveEnd)))
    end  
end

function AdventureRandomDetailLayer:dispose()

    self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    
end
return AdventureRandomDetailLayer;
