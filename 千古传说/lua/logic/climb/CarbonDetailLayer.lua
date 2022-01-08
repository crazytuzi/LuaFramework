--[[
******无量山-万能副本详情*******

    -- by haidong.gan
    -- 2013/11/27
]]
local CarbonDetailLayer = class("CarbonDetailLayer", BaseLayer);

CREATE_SCENE_FUN(CarbonDetailLayer);
CREATE_PANEL_FUN(CarbonDetailLayer);

CarbonDetailLayer.LIST_ITEM_WIDTH = 200; 

local CarbonSweepData  = require('lua.table.t_s_sweep')

function CarbonDetailLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.climb.ClimbMountainSoulDetail");
end

function CarbonDetailLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close');

    self.img_title          = TFDirector:getChildByPath(ui, 'img_title')

    self.btn_attack           = TFDirector:getChildByPath(ui, 'btn_attack')
    self.btn_army             = TFDirector:getChildByPath(ui, 'btn_army')
    self.img_diff             = TFDirector:getChildByPath(ui, 'img_diff')

    self.node_reward           = TFDirector:getChildByPath(ui, 'node_reward')

    self.txt_storydetail           = TFDirector:getChildByPath(ui, 'txt_storydetail')
    self.btn_yongbing           = TFDirector:getChildByPath(ui, 'btn_yongbing')

    self.button = {};
    for i=1,9 do
        local btnName = "panel_item" .. i;
        self.button[i] = TFDirector:getChildByPath(ui, btnName);

        btnName = "btn_icon"..i;
        self.button[i].bg = TFDirector:getChildByPath(ui, btnName);
        self.button[i].bg:setVisible(false);

        self.button[i].icon = TFDirector:getChildByPath(self.button[i].bg ,"img_touxiang");
        self.button[i].icon:setVisible(false);

        self.button[i].quality = TFDirector:getChildByPath(ui, btnName);

        btnName = "img_zhiye"..i;
        self.button[i].img_zhiye = TFDirector:getChildByPath(ui, btnName);
        
    end

    self.btnQuick = TFDirector:getChildByPath(ui, 'btn_quick3')
    self.txt_num = TFDirector:getChildByPath(self.btnQuick, 'LabelBMFont_MissionDetail_1')

    self.panel_reward = TFDirector:getChildByPath(ui, 'node_reward')

    self.quick_need_money_tip = CCUserDefault:sharedUserDefault():getBoolForKey("quick_need_money_tip");

    self.img_qucikneed = TFDirector:getChildByPath(ui, 'img_qucikneed')
    self.txt_freequick = TFDirector:getChildByPath(ui, 'txt_freequick')
    self.txt_qucikneed = TFDirector:getChildByPath(ui, 'txt_qucikneed')
end

function CarbonDetailLayer:loadData(index)

    print("--CarbonDetailLayer:loadData index = ", index)
    self.carbonItem = MoHeYaConfigure:objectAt(index);
end

function CarbonDetailLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();
    self:refreshBaseUI();
end

function CarbonDetailLayer:refreshBaseUI()
    self.txt_freequick:setVisible(false)
    self.img_qucikneed:setVisible(false)
    -- 判断扫荡道具
    local tool = BagManager:getItemById(30035)
    if tool and tool.num > 0 then
        self.txt_freequick:setVisible(true)
        --self.txt_freequick:setText("扫荡令：" .. tool.num)
        self.txt_freequick:setText(stringUtils.format(localizable.carbonDetailLayer_sweep_pro ,tool.num))
    else        
        local freeQuickprice = ConstantData:getValue("Mission.FreeQuick.price");
        self.img_qucikneed:setVisible(true);
        --self.txt_qucikneed:setText("每次扫荡消耗" .. freeQuickprice)
        self.txt_qucikneed:setText(stringUtils.format(localizable.carbonDetailLayer_use ,freeQuickprice))
        self.txt_qucikneed.cost = freeQuickprice;
    end
end

function CarbonDetailLayer:refreshUI()
    if not self.isShow then
        return;
    end


    -- local rewardList = ClimbManager:getSoulRewardItemList(self.carbonItem.id)

    -- local index = 1;
    -- for reward in rewardList:iterator() do
    --     local rewardNode = Public:createIconNumNode(reward)
    --     -- local txt_num   = TFDirector:getChildByPath(rewardNode, 'txt_num');
    --     -- txt_num:setVisible(false);

    --     rewardNode:setScale(0.6);
    --     rewardNode:setPosition((index - 1) * 75,0)
    --     self.node_reward:addChild(rewardNode);
    --     index = index + 1;
    -- end
    self:drawReward()
    print('self.carbonItem.difficulty = ', self.carbonItem.difficulty)
    self.img_diff:setTexture("ui_new/climb/img_diff" .. self.carbonItem.difficulty .. ".png")
    -- self.img_title:setTexture("ui_new/climb/img_soul_title" .. math.floor(self.carbonItem.id / 3) + 1 .. ".png")
    self.img_title:setTexture("ui_new/climb/img_soul_title_word" .. math.ceil(self.carbonItem.id / 4) .. ".png")
    self.txt_storydetail:setText(self.carbonItem.description)

    local npcs = NPCData:GetNPCListByIds(self.carbonItem.npc);

    for index=1,9 do
        local role = npcs[index];
        if  role ~= nil then
            self.button[index].icon:setVisible(true);
            self.button[index].icon:setTexture(role:getHeadPath());

            self.button[index].bg:setVisible(true);
            self.button[index].bg.role = role;

            self.button[index].bg.logic = self;
            self.button[index].bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);

            self.button[index].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality));

            local roleData = RoleData:objectByID(role.role_id);

            self.button[index].img_zhiye:setVisible(true);
            self.button[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. roleData.outline ..".png");

        else
            self.button[index].img_zhiye:setVisible(false);
            self.button[index].icon:setVisible(false);
            self.button[index].bg:setVisible(false);     
        end
    end

    self.btnQuick:setVisible(false)
    self.btn_army:setVisible(false)
    self.btn_yongbing:setVisible(false)
    if ClimbManager:getCarbonStarByID( self.carbonItem.id ) >= 3 then
        self.btnQuick:setVisible(true)
        local resInfo = MainPlayer:GetChallengeTimesInfo(self.carbonItem.res_type)
        self.txt_num:setText(resInfo.currentValue)
    else
        self.btn_army:setVisible(true)
        -- self.btn_yongbing:setVisible(true)
    end
end



function CarbonDetailLayer.cellClickHandle(sender)
    local self = sender.logic;
    local role = sender.role;
    
    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,role.level) 
    -- CardRoleManager:openRoleSimpleInfo(role);
end

--   local status = MissionManager:getMissionPassStatus(missionId);
function CarbonDetailLayer.onAttackClickHandle(sender)
    local self = sender.logic;

    -- if not MainPlayer:isEnoughTimes(EnumRecoverableResType.CLIMB,1, true) then
    --     return ;
    -- end
    
    local carbonItemId = self.carbonItem.id;
    AlertManager:close(AlertManager.TWEEN_NONE);

    ClimbManager:challengeClimbWanneng(carbonItemId);
end
--   local status = MissionManager:getMissionPassStatus(missionId);
function CarbonDetailLayer.onYongbingClickHandle(sender)
    local self = sender.logic;


    EmployManager:openRoleList(function ()
        AlertManager:close()
        local carbonItemId = self.carbonItem.id;
        AlertManager:close(AlertManager.TWEEN_NONE);
        ClimbManager:challengeClimbWanneng(carbonItemId,EnumFightStrategyType.StrategyType_HIRE_TEAM);
    end)


end

function CarbonDetailLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openRoleList(false);
end

--注册事件
function CarbonDetailLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    self.btn_close:setClickAreaLength(100);
    
   self.btn_attack.logic = self;
   self.btn_attack:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1);
   self.btn_yongbing.logic = self;
   self.btn_yongbing:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onYongbingClickHandle),1);

   self.btn_army.logic = self;
   self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1);

   self.btnQuick.logic = self
   self.btnQuick:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnQuickClickHandle),1);
end

function CarbonDetailLayer:removeEvents()

end


function CarbonDetailLayer:drawReward()

    local rewardList = ClimbManager:getSoulRewardItemList(self.carbonItem.id)
    self.rewardList = rewardList

    if self.tableView ~= nil then
        self.tableView:reloadData()
        self.tableView:setScrollToBegin(false)
        return
    end


    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_reward:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.tableView = tableView
    self.tableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, CarbonDetailLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, CarbonDetailLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, CarbonDetailLayer.numberOfCellsInTableView)
    tableView:reloadData()

    -- self:addChild(self.tableView,1)
    self.panel_reward:addChild(self.tableView,1)
end

function CarbonDetailLayer.cellSizeForTable(table, idx)
    return 100, 90
end

function CarbonDetailLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        local node = Public:createIconNumNode(reward)
        node:setScale(0.7);
        -- node:setPosition(-160 + (index - 1) * 85,-50)

        node:setPosition(ccp(0, 0))
        cell:addChild(node)
        node:setTag(617)

    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawRewardNode(node)
    return cell
end

function CarbonDetailLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local totalNum = self.rewardList:length()

    return totalNum
end


function CarbonDetailLayer:drawRewardNode(node)
    local index = node.index
    local rewardItem = self.rewardList:getObjectAt(index)
    Public:loadIconNode(node,rewardItem)

    CommonManager:setRedPoint(node, MartialManager:dropRewardRedPoint(rewardItem), "dropRewardRedPoint", ccp(80,80))
end

function CarbonDetailLayer.onBtnQuickClickHandle( btn )
    local self = btn.logic

    local id = self.carbonItem.id
    local resInfo = MainPlayer:GetChallengeTimesInfo(self.carbonItem.res_type)    

    local saoDangCardNum = 0
    local sweepConfigure = CarbonSweepData:objectByID(1)
    if sweepConfigure then
        local cost = sweepConfigure.token_num or 1
        local sweepID = sweepConfigure.token_id
        -- 判断扫荡道具 30035
        local tool = BagManager:getItemById(sweepID)
        if tool and tool.num > 0 then
            saoDangCardNum = tool.num
        end
        saoDangCardNum = math.floor(saoDangCardNum/cost)
    end


    if resInfo.currentValue > saoDangCardNum then
        local freeQuickprice = ConstantData:getValue("Mission.FreeQuick.price");   
        local needCostTimes = resInfo.currentValue - saoDangCardNum
        local costNum =  freeQuickprice * needCostTimes
        local msg =stringUtils.format(localizable.carbonDetailLayer_tips1,costNum)    
        --local msg = "扫荡令不足,是否花费" .. costNum .. "元宝进行扫荡？" ;        
        if not self.quick_need_money_tip then   
            CommonManager:showOperateSureTipLayer(
                    function(data, widget)
                        if MainPlayer:isEnoughSycee( costNum , true) then
                            ClimbManager:requestCarbonQuickPass(self.carbonItem.id, resInfo.currentValue)
                            self:getHasTip(widget)
                        end
                    end,
                    function(data, widget)
                        AlertManager:close()
                        self:getHasTip(widget)
                    end,
                    {
                        msg = msg
                    }
            )
        else    
            if MainPlayer:isEnoughSycee( costNum , true) then
                ClimbManager:requestCarbonQuickPass(self.carbonItem.id, resInfo.currentValue)
            end
        end
    else
        ClimbManager:requestCarbonQuickPass(self.carbonItem.id, resInfo.currentValue)
    end
end

function CarbonDetailLayer:getHasTip( widget )
    local state = widget:getSelectedState();
    print("state == ",state)
    if state == true then
        self.quick_need_money_tip = true
        CCUserDefault:sharedUserDefault():setBoolForKey("quick_need_money_tip", self.quick_need_money_tip);
        CCUserDefault:sharedUserDefault():flush();
        return
    end
end

return CarbonDetailLayer;
