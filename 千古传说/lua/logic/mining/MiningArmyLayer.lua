--[[
******布阵*******

    -- by Stephen.tao
    -- 2015/11/18
]]


local MiningArmyLayer = class("MiningArmyLayer", BaseLayer);

CREATE_SCENE_FUN(MiningArmyLayer);
CREATE_PANEL_FUN(MiningArmyLayer);

MiningArmyLayer.LIST_ITEM_HEIGHT = 200;
local RoleLen = 3

function MiningArmyLayer:ctor(data)
    self.super.ctor(self,data);

    self.fightType = data
    self:init("lua.uiconfig_mango_new.role.ArmyLayer");
end

function MiningArmyLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();

    if self.assistFightView then
        self.assistFightView:onShow()
    end
end


function MiningArmyLayer:refreshUI()
    if not self.isShow then
        return;
    end

    MiningManager:updateRoleList(self.fightType - EnumFightStrategyType.StrategyType_AREAN)

    local  armylist = ZhengbaManager:getFightList( self.fightType )
    print("self.fightType = ", self.fightType)
    print("armylist= ", armylist)
    for pos in pairs(armylist) do
        self:updateIcon(pos)
    end
    self:updateStrategyBaseMsg();

    if not self.table_select then
        -- CardRoleManager:setSortBloodStrategyForQuality()
        -- CardRoleManager:reSortBloodStrategy();
        ZhengbaManager:reSortStrategy(self.fightType)
        local  tableView   =  TFTableView:create();
        self.table_select  = tableView;

        tableView.logic    = self;
        tableView:setTableViewSize(self.bg_table:getContentSize());
        tableView:setDirection(TFTableView.TFSCROLLVERTICAL);
        tableView:setVerticalFillOrder(0);

        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable);
        tableView:addMEListener(TFTABLEVIEW_SCROLL, self.scrollForTable);
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex);
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView);
        Public:bindScrollFun(tableView);
        self.bg_table:addChild(tableView,2);
        self.table_select:reloadData();
        self.table_select:scrollToYTop(0);
    else
        self:refreshTable();
    end

end

function MiningArmyLayer:updateStrategyBaseMsg()
    print("ZhengbaManager:getFightRoleNum( self.fightType ) = ",ZhengbaManager:getFightRoleNum( self.fightType ))
    self.txt_RoleNum:setText(ZhengbaManager:getFightRoleNum( self.fightType ) .. "/" .. ZhengbaManager:getMaxNum());
    self.txt_power:setText(ZhengbaManager:getPower(self.fightType));
end

function MiningArmyLayer:initUI(ui)
	self.super.initUI(self,ui);

    --添加助战入口    
    local titleTexture = "ui_new/array/js_buzhen_title.png"
    if self.fightType == 1 then
        self.currLineUpType = LineUpType.LineUp_Attack
    elseif self.fightType == 3 then
        self.currLineUpType = LineUpType.LineUp_QunhaoDef
        titleTexture = "ui_new/common/title_fangshoubuzhen.png"
    else
        self.currLineUpType = LineUpType.LineUp_Defense
    end 

    self.currLineUpType = self.fightType

    self.assistFightView = CommonManager:addAssistFightView(self,self.currLineUpType)

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.txt_RoleNum = TFDirector:getChildByPath(ui, 'txt_shangzhenrenshu');
    self.txt_power   = TFDirector:getChildByPath(ui, 'txt_zhanlizhi_word');
    self.btn_auto    = TFDirector:getChildByPath(ui, 'btn_yijianshangzhen');
    self.btn_auto:setVisible(false)

    self.button = {};
    for i=1,9 do
        local btnName = "panel_item" .. i
        local cell = TFDirector:getChildByPath(ui, btnName)
        self.button[i] = cell

        -- btnName = "btn_icon"..i;
        -- self.button[i].bg = TFDirector:getChildByPath(ui, btnName);
        -- self.button[i].bg:setVisible(false);

        -- self.button[i].icon = TFDirector:getChildByPath(self.button[i].bg ,"img_touxiang");
        -- self.button[i].icon:setVisible(false);
        -- -- self.button[i].icon:setFlipX(true);

        -- self.button[i].quality  = TFDirector:getChildByPath(ui, btnName);
        -- self.button[i].img_zhiye = TFDirector:getChildByPath(self.button[i], "img_zhiye");
        -- self.button[i].img_zhiye:setVisible(false);


        -- self.button[i].bg.logic = self;
        -- self.button[i].bg.posIndex = i;
        -- self.button[i].bg.hasRole = false;

        -- self.button[i].logic = self;
        -- self.button[i].posIndex = i;
        -- self.button[i].hasRole = false;

        cell.spawn = TFDirector:getChildByPath(cell, "Panel_Body")
        cell.img_zhiye = TFDirector:getChildByPath(cell, "img_zhiye")
        cell.img_zhiye:setVisible(false)
        cell.logic = self
        cell.posIndex = i
        cell.hasRole = false

        local posName = TFDirector:getChildByPath(cell, "img_zhenming")
        cell.posName = posName
    end

    self.bg_table      = TFDirector:getChildByPath(ui, 'panel_cardregional');

    self.btn_sort            = TFDirector:getChildByPath(ui, 'btn_xiala');
    self.btn_sort_pos        = TFDirector:getChildByPath(ui, 'btn_zhuangbei');
    self.btn_sort_power      = TFDirector:getChildByPath(ui, 'btn_zhanli');
    self.btn_sort_quality    = TFDirector:getChildByPath(ui, 'btn_pinzhi');
    self.img_select          = TFDirector:getChildByPath(ui, 'img_select');
    self.btn_sort:setVisible(false)

    self.img_quality_select          = TFDirector:getChildByPath(ui, 'btn_pinzhi-press');
    self.img_power_select          = TFDirector:getChildByPath(ui, 'btn_zhanli-press');
    
    self.bg_sort             = TFDirector:getChildByPath(ui, 'panel_bg');  
    -- self.bg_sort:setSwallowTouch(false);
    self.node_menu           = TFDirector:getChildByPath(ui, 'panel_menu');
    self.groupButtonManager  = GroupButtonManager:new( {[1] = self.btn_sort_power, [2] = self.btn_sort_quality});
    self.node_menu:setVisible(false)

    self.groupButtonManager:selectBtn(self.btn_sort_quality);

    -- self.img_quality_select:setVisible(true);
    -- self.img_power_select:setVisible(false);
    -- self.node_menu:setVisible(false);
    -- self.btn_sort:setVisible(true);

    --挑战
    -- self.btn_xiala       = TFDirector:getChildByPath(ui, 'btn_xiala');
    -- self.btn_xiala:setVisible(false)

    -- self.img_title = TFDirector:getChildByPath(ui, 'img_title')
    -- self.img_title:setTexture(titleTexture)
    -- self:drawAttackBtn()

    self.btn_equipchange = TFDirector:getChildByPath(ui, 'Button_ArmyLayer_1');
    local panel_title = TFDirector:getChildByPath(ui, 'panel_title');
    self.img_point = TFDirector:getChildByPath(panel_title, 'img_di');
end

function MiningArmyLayer.onShowSortMenuClickHandle(sender)
    local self = sender.logic;
    self.node_menu:setVisible(not self.node_menu:isVisible());

    -- self.btn_sort:setVisible(false);
end

function MiningArmyLayer.onSortSelectClickHandle(sender)
    local self = sender.logic;

    self.node_menu:setVisible(false);
    -- self.btn_sort:setVisible(true);

    if (self.groupButtonManager:getSelectButton() == sender) then
       return;
    end

    self.img_quality_select:setVisible(false);
    self.img_power_select:setVisible(false);

   if sender == self.btn_sort_pos then
        CardRoleManager:setSortStrategyForPos();
        self.img_power_select:setVisible(true);
   elseif sender == self.btn_sort_power then
        CardRoleManager:setSortStrategyForPower();
        self.img_power_select:setVisible(true);
   elseif sender == self.btn_sort_quality then
        CardRoleManager:setSortStrategyForQuality();
        self.img_quality_select:setVisible(true);
   end

   self.groupButtonManager:selectBtn(sender);
   self:refreshTable();
end

function MiningArmyLayer.onSortCancelClickHandle(sender)
    local self = sender.logic;
    self.node_menu:setVisible(false);
    self.btn_sort:setVisible(true);
end


function MiningArmyLayer.scrollForTable(tableView)
    local self = tableView.logic;
    -- self:removeLongTouchTimer();
end

function MiningArmyLayer.cellSizeForTable(tableView,idx)
    return MiningArmyLayer.LIST_ITEM_HEIGHT,960
end

function MiningArmyLayer.tableCellAtIndex(tableView, idx)
    local self = tableView.logic;
    local cell = tableView:dequeueCell()
    if nil == cell then
        tableView.cells = tableView.cells or {}
        cell = TFTableViewCell:create()
        tableView.cells[cell] = true

        local item_node = TFPanel:create();
        cell:addChild(item_node);
        cell.item_node = item_node;

        for i=1,RoleLen do
            -- local m_node = createUIByLuaNew("lua.uiconfig_mango_new.role.ArmyRoleItem")
            local m_node = createUIByLuaNew("lua.uiconfig_mango_new.bloodybattle.BloodybattleArmyRoleItem")

            m_node.panel_empty = TFDirector:getChildByPath(m_node, 'panel_empty');
            m_node.panel_info  = TFDirector:getChildByPath(m_node, 'panel_info');
            m_node.bar_xuetiao = TFDirector:getChildByPath(m_node, 'bar_xuetiao');
            m_node.img_xuetiao = TFDirector:getChildByPath(m_node, 'img_xuetiao');
            m_node.img_xuetiao:setVisible(false)
            m_node:setName("m_role" .. i);
            m_node:setPosition(ccp(20 + 140 * (i - 1) ,10));

            item_node:addChild(m_node);
            item_node.m_node = m_node; 
        end
    end

    for i=1,RoleLen do
        local roleIndex = idx*RoleLen + i;

        local m_node = TFDirector:getChildByPath(cell.item_node, 'm_role' .. i);
        local roleItem = MiningManager.cardRoleList:objectAt(roleIndex);
        if  roleItem then
            m_node.panel_empty:setVisible(true);
            m_node.panel_info:setVisible(true);
            self:loadItemNode(m_node,roleItem);
     
        else
            m_node.panel_empty:setVisible(true);
            m_node.panel_info:setVisible(false);
        end

    end

    return cell
end

function MiningArmyLayer.numberOfCellsInTableView(tableView)
    local self = tableView.logic;
    return math.max(math.ceil(MiningManager.cardRoleList:length()/RoleLen), RoleLen);
end

--添加玩家节点
function MiningArmyLayer:loadItemNode(item_node,roleItem)
    
    local btn_icon = TFDirector:getChildByPath(item_node, 'btn_pingzhianniu');
    btn_icon.logic = self;
    btn_icon:setTag(roleItem.gmId);

    btn_icon:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle);
    btn_icon:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle);
    btn_icon:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle);
    btn_icon:addMEListener(TFWIDGET_CLICK,  self.cellClickHandle);

    btn_icon.posIndex = -1;  
    btn_icon.hasRole = true;  
    btn_icon.gmId  = roleItem.gmId;

    local img_icon = TFDirector:getChildByPath(item_node, 'img_touxiang');

    -- img_icon:setTexture(roleItem:getHeadPath());
    img_icon:setTexture(roleItem:getIconPath());
    local img_quality = TFDirector:getChildByPath(item_node, 'img_pinzhiditu');
    img_quality:setTexture(GetColorIconByQuality(roleItem.quality));
    -- img_quality:setTexture(GetRoleBgByWuXueLevel(roleItem.martialLevel));


    local txt_name = TFDirector:getChildByPath(item_node, 'txt_name');
    local roleStar = ""
    if roleItem.starlevel > 0 then
        roleStar = roleStar .. " +" .. roleItem.starlevel
    end
    txt_name:setText(roleItem.name..roleStar);

    -- txt_name:setColor(GetColorByQuality(roleItem.quality))

    local img_zhiye = TFDirector:getChildByPath(item_node, 'img_zhiye');
    img_zhiye:setTexture("ui_new/fight/zhiye_".. roleItem.outline ..".png");

    local img_fight = TFDirector:getChildByPath(item_node, 'img_zhan');
    local role_pos = ZhengbaManager:getIndexByRole(self.fightType,roleItem.gmId )
    if role_pos and role_pos ~= 0 then
        img_fight:setVisible(true);
    else
        img_fight:setVisible(false);
    end
    --添加助战标识
    local img_zhu = TFDirector:getChildByPath(item_node, 'img_zhu')
    if AssistFightManager:isInAssist( self.currLineUpType, roleItem.gmId ) then
        img_zhu:setVisible(true)
    else
        img_zhu:setVisible(false)
    end
    
    local txt_level = TFDirector:getChildByPath(item_node, 'txt_lv_word');
    txt_level:setText(roleItem.level);

    item_node.bar_xuetiao:setVisible(false)

    local img_wuxuelevel = TFDirector:getChildByPath(item_node, 'img_wuxuelevel');
    img_wuxuelevel:setTexture(GetFightRoleIconByWuXueLevel(roleItem.martialLevel))
end

function MiningArmyLayer:removeUI()
	self.super.removeUI(self);

	self.button      = nil;
    self.btn_close   = nil;
    self.lastPoint   = nil;
    self.curIndex    = nil;
end

function MiningArmyLayer.cellClickHandle(sender)
    local self = sender.logic;
    local gmId = sender.gmId;

    if sender.isClick == true then
        play_press()
    end
end

function MiningArmyLayer.cellTouchBeganHandle(cell)
    local self = cell.logic;
    if cell.hasRole ~= true then
        return;
    end

    cell.isClick = true;
    cell.isDrag  = false;
    self.isMove = false;

    self.offest = self.table_select:getContentOffset();

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
                self.table_select:setTouchEnabled(false);
            else
                cell.isDrag  = false;
                self.table_select:setTouchEnabled(true);
            end
        end
    end;

    if (cell.posIndex == -1) then
        self:removeLongTouchTimer();
        self.longTouchTimerId = TFDirector:addTimer(0.001, -1, nil, self.onLongTouch); 
    end

end

function MiningArmyLayer.cellTouchMovedHandle(cell)
    local self = cell.logic;
    self.isMove = true;

    if cell.hasRole ~= true then
        return;
    end

  
    local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos());

    if (v.y < 30) then
        -- self.table_select:setContentOffset(self.offest );
    end

    local pos = cell:getTouchMovePos();

    if self.selectCussor == nil then
        if (cell.posIndex ~= -1 or cell.isDrag == true ) then
            self:createSelectCussor(cell,pos);
        end
    end

    if cell.isClick == true then
        return;
    end
    -- self.table_select:setContentOffset(self.offest );
    self:moveSelectCussor(cell,pos);
end


function MiningArmyLayer.cellTouchEndedHandle(cell)
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
    self.table_select:setTouchEnabled(true);
end

function MiningArmyLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

function MiningArmyLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;

    -- local role = CardRoleManager:getRoleByGmid(cell.gmId);
    -- self.selectCussor = TFImage:create();
    -- self.selectCussor:setFlipX(true);
    -- self.selectCussor:setTexture(role:getHeadPath());
    -- self.selectCussor:setScale(20 / 15.0);
    -- self.selectCussor:setPosition(pos);
    -- self:addChild(self.selectCussor);
    -- self.selectCussor:setZOrder(100);

    local role = CardRoleManager:getRoleByGmid(cell.gmId);
    local roleData =  RoleData:objectByID(role.id)
    local armatureID = roleData.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    local model = ModelManager:createResource(1, armatureID)
    model:setScale(0.5)
    self.selectCussor = model 
    self.selectCussor:setPosition(pos);
    self:addChild(self.selectCussor);
    self.selectCussor:setZOrder(100);
   
    self.curIndex = cell.posIndex;
    
end

function MiningArmyLayer:moveSelectCussor(cell,pos)
    local v = ccpSub(pos, self.lastPoint);
    self.lastPoint = pos;
    local scp = ccpAdd(self.selectCussor:getPosition(), v);
    self.selectCussor:setPosition(scp);
    self.selectCussor:setVisible(true);

    self.curIndex = nil;
    if  self.bg_table:hitTest(pos) then
        self.curIndex = -1;
    end
    for i=1,9 do
        if  self.button[i]:hitTest(pos) then
            self.curIndex = self.button[i].posIndex;
            break;
        end
    end

end

function MiningArmyLayer:releaseSelectCussor(cell,pos)

    if cell.isClick == false  then
        if (self.curIndex == nil) then
            return;
        end

        local dargRole      = CardRoleManager:getRoleByGmid(cell.gmId);
        local toReplaceRole =  ZhengbaManager:getRoleByIndex(self.fightType,self.curIndex);
        --在阵中释放
        if (self.curIndex ~= -1) then 

            --从列表中拖到阵中
            if (cell.posIndex == -1) then
                local role_pos = ZhengbaManager:getIndexByRole(self.fightType,cell.gmId )
                --本来已经在阵中
                if role_pos and role_pos ~= 0 then

                    --且不是本角色目前所在的位置，做位置变更
                    if (toReplaceRole == nil or (toReplaceRole and toReplaceRole.gmId ~= dargRole.gmId)) then
                        self:ChangePos((role_pos), (self.curIndex))

                        play_buzhenyidong()

                    end
                --要上阵，但是已经到达上限
                elseif (toReplaceRole == nil and not ZhengbaManager:canAddFightRole(self.fightType)) then
                    if ZhengbaManager:getMaxNum() == 5 then
                        --toastMessage("上阵人数已满");
                        toastMessage(localizable.common_function_number_out);  
                    else
                        local needLevel = FunctionOpenConfigure:getOpenLevel(700 + (ZhengbaManager:getMaxNum() + 1))
                        if MainPlayer:getLevel() < needLevel then
                            --toastMessage("团队等级" .. needLevel .. "级可上阵" .. (ZhengbaManager:getMaxNum() + 1) .."人");
                            toastMessage(stringUtils.format(localizable.common_function_up_number,needLevel, ZhengbaManager.getMaxNum() + 1 ))
                            
                        end
                    end
                else
                    --check是否为助战侠客
                    if AssistFightManager:isInAssist( self.currLineUpType, cell.gmId ) then
                        CommonManager:showOperateSureLayer(
                                        function()
                                            AssistFightManager:updateRoleOff(self.currLineUpType, cell.gmId)
                                            self:OnBattle(cell.gmId, (self.curIndex))
                                            play_buzhenyidong()
                                        end,
                                        function()
                                            AlertManager:close()
                                            
                                        end,
                                        {
                                        --title = "提示" ,
                                        --msg = "此为助战侠客，上阵将无法助战，是否继续？",       
                                        title = localizable.common_tips ,
                                        msg = localizable.common_tips_zhuzhan,

                                        }
                                    )
                    else
                        self:OnBattle(cell.gmId, (self.curIndex))

                        play_buzhenyidong()
                    end

                end

            --阵中操作，更换位置   
            else
                self:ChangePos((cell.posIndex), (self.curIndex))

                play_buzhenyidong()
            end

            return;
        end

        --在右边列表释放
        if (self.curIndex == -1) then

            if (cell.posIndex == -1 ) then
                --放弃上阵，不做操作

            else
                    print("下阵:",dargRole.name);

                    self:OutBattle(cell.gmId)

                    play_buzhenluoxia();
                --end
            end
        end
    end

    if cell:hitTest(pos) then     
        -- MiningArmyLayer.cellClickHandle(cell);
    end
end


function MiningArmyLayer:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    self.btn_close:setClickAreaLength(100);


    for i=1,9 do
        self.button[i]:addMEListener(TFWIDGET_CLICK,  self.cellClickHandle,1);
        self.button[i]:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1);
        self.button[i]:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle);
        self.button[i]:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle);
    end

    self.callEquipChange = function(sender)
        XiaKeExchangeManager:openEquipChangeLayer()
    end
    self.btn_equipchange:addMEListener(TFWIDGET_CLICK,audioClickfun(self.callEquipChange))

    if self.assistFightView then
        self.assistFightView:registerEvents()
    end
    -- self.btn_sort.logic = self;
    -- self.btn_sort_pos.logic = self;
    -- self.btn_sort_power.logic = self;
    -- self.btn_sort_quality.logic = self;
    -- self.bg_sort.logic = self;

    -- self.btn_sort:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onShowSortMenuClickHandle));
    -- self.btn_sort_pos:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle),1);
    -- self.btn_sort_power:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle),1);
    -- self.btn_sort_quality:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle),1);
    -- self.bg_sort:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortCancelClickHandle));

    self.updateFormationSucess = function(event)
        print("----------self.updateFormationSucess")
        self:refreshUI()
    end;
    TFDirector:addMEGlobalListener(ZhengbaManager.UPDATEFORMATIONSUCESS ,self.updateFormationSucess ) ;

    
    self.RoleStarUpResultCallBack = function (event)
        print("----------self.RoleStarUpResultCallBack")
        self:updateStrategyBaseMsg();
        self:refreshTable();
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_TRANSFER_RESULT,self.RoleStarUpResultCallBack)
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_BREAKTHROUGH_RESULT,self.RoleStarUpResultCallBack)

    if XiaKeExchangeManager:IsOpenEquipChange() == true then
        self.btn_equipchange:setVisible(true)
        self.img_point:setVisible(false)
    else
        self.img_point:setVisible(true)
        self.btn_equipchange:setVisible(false)
    end
end

function MiningArmyLayer:playAutoMatixComEffect()

    local resPath = "effect/role_auto_matix_down.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("role_auto_matix_down_anim")

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))

    self:addChild(effect,2)

    effect:addMEListener(TFARMATURE_COMPLETE,function()
        effect:removeMEListener(TFARMATURE_COMPLETE) 
        effect:removeFromParent()
    end)

    local  armylist = ZhengbaManager:getFightList( self.fightType )
        for index in pairs(armylist) do

            self:updateIcon( index );
            self.button[index].bg:setVisible(false);

            local role = ZhengbaManager:getRoleByIndex(self.fightType,index);
            if role then
                local tempNode = self.button[index].bg:clone();
                tempNode:setPosition(self.button[index].bg:getPosition().x,self.button[index].bg:getPosition().y)
                self.button[index].bg:getParent():addChild(tempNode);
                tempNode:setVisible(true);
                tempNode:setAlpha(0);

                local toastTween = {
                      target = tempNode,
                     {
                        duration = 0,
                        delay = 0.1 + (index - 1)*0.08,
                      },
                      {
                        duration = 0,
                        alpha = 1,
                      },
                      {
                        duration = 4/24,
                        scale = 1.7,
                      },
                      { 
                        duration = 4/24,
                        scale = 2,
                        alpha = 0,
                      },

                      {
                         duration = 0,
                         alpha = 1,
                         scale = 1,
                      },
                      {
                        duration = 0,
                        onComplete = function() 
                            tempNode:removeFromParent();
                            self:updateIcon( index );
                        end
                      }
                    }

                TFDirector:toTween(toastTween);

            end
        end    

    effect:playByIndex(0, -1, -1, 0)
end

function MiningArmyLayer:refreshTable()

    if self.table_select == nil then
        return
    end
    print("MiningArmyLayer:refreshTable")
    ZhengbaManager:reSortStrategy(self.fightType, MiningManager.cardRoleList)
    local tb_pos = self.table_select:getContentOffset();
    self.table_select:reloadData();
    local currentSize = self.table_select:getContentSize()
    local tabSize = self.table_select:getSize()
    tb_pos.y = math.max(tb_pos.y , tabSize.height - currentSize.height)
    self.table_select:setContentOffset(tb_pos);
end   

function MiningArmyLayer:removeEvents()
    self.super.removeEvents(self)
    
    TFDirector:removeMEGlobalListener(ZhengbaManager.UPDATEFORMATIONSUCESS, self.updateFormationSucess );
    self.updateFormationSucess = nil;


    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_TRANSFER_RESULT, self.RoleStarUpResultCallBack );
    self.RoleStarUpResultCallBack = nil;

    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_BREAKTHROUGH_RESULT, self.RoleStarUpResultCallBack );
    self.RoleStarUpResultCallBack = nil;

    if self.assistFightView then
        self.assistFightView:removeEvents()
    end

    TFDirector:removeTimer(self.playAutoMatixTimeId);
    self.playAutoMatixTimeId = nil;
    
end

function MiningArmyLayer:updateIcon( index )
    local role = ZhengbaManager:getRoleByIndex( self.fightType,index);

    local cell = self.button[index]
    local model = cell.model
    if model then
        cell.spawn:removeChild(model)
        cell.model = nil
    end

    local show = role ~= nil
    cell.posName:setVisible(not show)
    cell.img_zhiye:setVisible(show)
    if role then
        -- self.button[index].icon:setVisible(true);
        -- self.button[index].icon:setTexture(role:getHeadPath());

        -- self.button[index].bg:setVisible(true);
        -- self.button[index].quality:setTextureNormal(GetColorRoadIconByQuality(role.quality));
        -- -- self.button[index].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle(role.martialLevel))

        -- self.button[index].img_zhiye:setVisible(true);
        -- self.button[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");


        -- self.button[index].bg.hasRole = true;
        -- self.button[index].bg.gmId  = role.gmId;


        -- -- local maxHp = role.blood_maxHp
        -- -- local curHp = role.blood_curHp
        -- -- local bGray = false
        -- -- if curHp <= 0 then
        -- --     bGray = true
        -- -- end
        -- -- self.button[index].icon:setGrayEnabled(bGray)
        -- Public:addLianTiEffect(self.button[index].icon,role:getMaxLianTiQua(),true)
        cell.img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");
        cell.hasRole = true;
        cell.gmId  = role.gmId;

         -- local role = CardRoleManager:getRoleByGmid(role.gmId);
        local roleData =  RoleData:objectByID(role.id)
        local armatureID = roleData.image
        ModelManager:addResourceFromFile(1, armatureID, 1)
        local model = ModelManager:createResource(1, armatureID)
        model:setScale(0.6)
        cell.spawn:addChild(model)
        cell.model = model
        ModelManager:playWithNameAndIndex(model, "stand", -1, 1, -1, -1)

        Public:addLianTiEffect(cell,role:getMaxLianTiQua(),true)
    else
        -- self.button[index].img_zhiye:setVisible(false);
        -- self.button[index].icon:setVisible(false);
        -- self.button[index].bg:setVisible(false); 
  
        -- self.button[index].bg.hasRole = false;   
        -- Public:addLianTiEffect(self.button[index].icon,0,false)
        cell.hasRole = false;   
        Public:addLianTiEffect(cell,0,false)
    end
end

-- 上阵
function MiningArmyLayer:OnBattle(gmid, posIndex)
   ZhengbaManager:OnBattle(self.fightType,gmid, posIndex)
end

-- 下阵
function MiningArmyLayer:OutBattle(gmid)
    ZhengbaManager:OutBattle(self.fightType,gmid)
end

-- 换位置
function MiningArmyLayer:ChangePos(oldPos, newPos)
    ZhengbaManager:ChangePos(self.fightType,oldPos, newPos)
end

return MiningArmyLayer;
