--[[
******布阵*******

    -- by Stephen.tao
    -- 2013/12/05

    -- by haidong.gan
    -- 2014/4/10
]]


local ArmyLayer = class("ArmyLayer", BaseLayer);

CREATE_SCENE_FUN(ArmyLayer);
CREATE_PANEL_FUN(ArmyLayer);

ArmyLayer.LIST_ITEM_HEIGHT = 190; 
local RoleLen = 3

function ArmyLayer:ctor(data)
    self.super.ctor(self,data);

    self.guideRolePos = 0
    self.guideCurrPos = 0
    self.guideChangePos = 0
    self.canOpenInfo = true
    self:init("lua.uiconfig_mango_new.role.ArmyLayer");
end

function ArmyLayer:onShow()
    self.super.onShow(self)
    self.lastPoint   = nil
    self.curIndex    = nil
    self:refreshBaseUI()
    self:refreshUI()

    if self.assistFightView then
        self.assistFightView:onShow()
    end
end

function ArmyLayer:refreshBaseUI()
    if self.selectCussor then
        self.selectCussor:removeFromParentAndCleanup(true)
        self.selectCussor = nil;
    end
    self.isAutoIng = false
    self:removeLongTouchTimer()
end

function ArmyLayer:refreshUI()
    if not self.isShow then
        return
    end
    self.isAutoIng = false

    local  armylist = StrategyManager:getList()
    for pos in pairs(armylist) do
        self:updateIcon(pos)
    end
    self:updateStrategyBaseMsg()

    if not self.table_select then
        local  tableView   =  TFTableView:create()
        self.table_select  = tableView

        tableView.logic    = self
        tableView:setTableViewSize(self.bg_table:getContentSize())
        tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
        tableView:setVerticalFillOrder(0)

        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable);
        tableView:addMEListener(TFTABLEVIEW_SCROLL, self.scrollForTable);
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex);
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
        Public:bindScrollFun(tableView)
        self.bg_table:addChild(tableView,1)
        self.table_select:reloadData()
        self.table_select:scrollToYTop(0)
    else
        self:refreshTable()
    end
end

function ArmyLayer:updateStrategyBaseMsg()
    -- CardRoleManager:refreshAllRolePower()

    self.txt_RoleNum:setText(StrategyManager:getFightRoleNum() .. "/" .. StrategyManager:getMaxNum());
    self.txt_power:setText(StrategyManager:getPower());
end

function ArmyLayer:initUI(ui)
	self.super.initUI(self,ui);

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.txt_RoleNum = TFDirector:getChildByPath(ui, 'txt_shangzhenrenshu');
    self.txt_power   = TFDirector:getChildByPath(ui, 'txt_zhanlizhi_word');
    self.btn_auto    = TFDirector:getChildByPath(ui, 'btn_yijianshangzhen');

    -- self.currLineUpType = LineUpType.LineUp_Main
    self.currLineUpType = EnumFightStrategyType.StrategyType_PVE
    self.assistFightView = CommonManager:addAssistFightView(self,self.currLineUpType)
    self.assistFightView:setName("assistFightView")

    self.button = {};
    for i=1,9 do
        local btnName = "panel_item" .. i
        local cell = TFDirector:getChildByPath(ui, btnName)
        self.button[i] = cell
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

    self.img_quality_select          = TFDirector:getChildByPath(ui, 'btn_pinzhi-press');
    self.img_power_select          = TFDirector:getChildByPath(ui, 'btn_zhanli-press');
    
    self.bg_sort             = TFDirector:getChildByPath(ui, 'panel_bg');  
    -- self.bg_sort:setSwallowTouch(false);
    self.node_menu           = TFDirector:getChildByPath(ui, 'panel_menu');
    self.groupButtonManager  = GroupButtonManager:new( {[1] = self.btn_sort_power, [2] = self.btn_sort_quality});
    Public:addEffect("pinzhizhanli", self.btn_sort_power, 0, 0, 1)
    Public:addEffect("pinzhizhanli", self.btn_sort_quality, 0, 0, 1)
    self.groupButtonManager:selectBtn(self.btn_sort_quality);

    CardRoleManager:setSortStrategyForQuality();

    self.img_quality_select:setVisible(true);
    self.img_power_select:setVisible(false);

    self.node_menu:setVisible(false);
    self.btn_sort:setVisible(true);

    self.btn_equipchange = TFDirector:getChildByPath(ui, 'Button_ArmyLayer_1');
    local panel_title = TFDirector:getChildByPath(ui, 'panel_title');
    self.img_point = TFDirector:getChildByPath(panel_title, 'img_di');
    
end
function ArmyLayer.onShowSortMenuClickHandle(sender)
    local self = sender.logic;
    self.node_menu:setVisible(not self.node_menu:isVisible());

    -- self.btn_sort:setVisible(false);
end
function ArmyLayer.onSortSelectClickHandle(sender)
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

function ArmyLayer.onSortCancelClickHandle(sender)
    local self = sender.logic;
    self.node_menu:setVisible(false);
    self.btn_sort:setVisible(true);
end


function ArmyLayer.scrollForTable(tableView)
    local self = tableView.logic;
    -- self:removeLongTouchTimer();
end

function ArmyLayer.cellSizeForTable(tableView,idx)
    return ArmyLayer.LIST_ITEM_HEIGHT, 960
end

function ArmyLayer.tableCellAtIndex(tableView, idx)
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
            local m_node = createUIByLuaNew("lua.uiconfig_mango_new.role.ArmyRoleItem");
            m_node.panel_empty = TFDirector:getChildByPath(m_node, 'panel_empty');
            m_node.panel_info = TFDirector:getChildByPath(m_node, 'panel_info');
            m_node:setName("m_role" .. i);
            m_node:setPosition(ccp(20 + 180 * (i - 1), 0));

            item_node:addChild(m_node);
            item_node.m_node = m_node; 
        end
    end

    for i=1,RoleLen do
        local roleIndex = idx*RoleLen + i;

        local m_node = TFDirector:getChildByPath(cell.item_node, 'm_role' .. i);
        local roleItem = CardRoleManager.cardRoleList:objectAt(roleIndex);
        if  roleItem then
            m_node.panel_empty:setVisible(true);
            m_node.panel_info:setVisible(true);
            self:loadItemNode(m_node,roleItem);
        else
            m_node.panel_empty:setVisible(true);
            m_node.panel_info:setVisible(false);
        end

        if roleItem and roleItem.pos ~= nil and roleItem.pos > 0 then
            CommonManager:setRedPoint(m_node, MartialManager:isHaveBook(roleItem),"isHaveBook", ccp(60, 70))
        else
            CommonManager:setRedPoint(m_node, false,"isHaveBook", ccp(60, 70))
        end
        -- CommonManager:setRedPoint(m_node, true,"isHaveCanGift",ccp(70, 80))
    end

    return cell
end

function ArmyLayer.numberOfCellsInTableView(tableView)
    local self = tableView.logic;
    return math.max(math.ceil(CardRoleManager.cardRoleList:length()/RoleLen) , RoleLen);
end

function ArmyLayer:setGuideMode(rolePos)
    self.guideRolePos = rolePos
    if rolePos > 0 then
        self.table_select:setInertiaScrollEnabled(false)
    else
        self.table_select:setInertiaScrollEnabled(true)
    end
end

--添加玩家节点
function ArmyLayer:loadItemNode(item_node,roleItem)
    -- CommonManager:setRedPoint( item_node.panel_info, CardRoleManager:isCanStarUp(roleItem.gmId),"isCanStarUp",ccp(item_node:getSize().width/2,item_node:getSize().height/2))
    -- CommonManager:setRedPoint( item_node.panel_info, CardRoleManager:isCanBreakUp(roleItem.gmId),"isCanBreakUp",ccp(item_node:getSize().width/2,item_node:getSize().height/2))
    
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
    local img_pinzhiditu = TFDirector:getChildByPath(item_node, 'img_pinzhiditu');
    img_pinzhiditu:setTexture(GetColorIconByQuality(roleItem.quality));
    -- img_pinzhiditu:setTexture(GetRoleBgByWuXueLevel(roleItem.martialLevel));

    local txt_name = TFDirector:getChildByPath(item_node, 'txt_name');
    -- txt_name:setText(roleItem.name);
    local roleStar = ""
    if roleItem.starlevel > 0 then
        roleStar = roleStar .. " +" .. roleItem.starlevel
    end
    txt_name:setText(roleItem.name..roleStar);

    -- txt_name:setColor(GetColorByQuality(roleItem.quality))

    local img_zhiye = TFDirector:getChildByPath(item_node, 'img_zhiye');
    img_zhiye:setTexture("ui_new/fight/zhiye_".. roleItem.outline ..".png");

    local img_quality = TFDirector:getChildByPath(item_node, 'img_quality');
    -- img_quality:setVisible(false)
    -- img_quality:setTexture(GetArmyPicByQuality(roleItem.quality));
    -- local roleM = 1
    img_quality:setTexture(GetFightRoleIconByWuXueLevel(roleItem.martialLevel))

    local img_fight = TFDirector:getChildByPath(item_node, 'img_zhan');
    if roleItem.pos and roleItem.pos ~= 0 then
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

    -- for i=1,5 do
    --    local img_star = TFDirector:getChildByPath(item_node, 'img_xingxing' .. i);
    --     if (roleItem.starlevel >= i) then
    --         img_star:setVisible(true);
    --     else
    --         img_star:setVisible(false);
    --     end
    -- end

    local txt_level = TFDirector:getChildByPath(item_node, 'txt_lv_word');
    txt_level:setText(roleItem.level);

    -- local img_kuang = TFDirector:getChildByPath(item_node, 'img_kuang');
    -- img_kuang:setTexture(GetColorKuangByQuality(roleItem.quality));
end

function ArmyLayer:removeUI()
	self.super.removeUI(self);

	self.button      = nil;
    self.btn_close   = nil;
    self.lastPoint   = nil;
    self.curIndex    = nil;
end

function ArmyLayer:setChangePosGuide(pos, changePos)
    self.guideCurrPos = pos
    self.guideChangePos = changePos
end

function ArmyLayer:setCanOpenInfo(vaule)
    if vaule == nil then
        vaule = true
    end
    self.canOpenInfo = vaule
end

function ArmyLayer.cellClickHandle(sender)
    local self = sender.logic;
    local gmId = sender.gmId;
    if self.guideRolePos > 0 or self.guideCurrPos >0 then
        return
    end

    if sender.isClick == true and self.canOpenInfo == true then
        play_press()
        CardRoleManager:openRoleInfo(gmId);
    end
end

function ArmyLayer.cellTouchBeganHandle(cell)
    print("cellTouchBeganHandle--------------------->")
    local self = cell.logic;
    if cell.hasRole ~= true then
        return;
    end

    if self.guideRolePos > 0 then 
        local cellRole = CardRoleManager:getRoleByGmid(cell.gmId)
        if cellRole ~= nil and cellRole.pos > 0 then
            return
        end
    end

    if self.guideCurrPos > 0 then 
        local cellRole = CardRoleManager:getRoleByGmid(cell.gmId)
        if cellRole ~= nil and cellRole.pos ~= self.guideCurrPos then
            return
        end
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

function ArmyLayer.cellTouchMovedHandle(cell)
    local self = cell.logic;
    self.isMove = true;

    if cell.hasRole ~= true then
        return;
    end

    if self.guideRolePos > 0 then 
        local cellRole = CardRoleManager:getRoleByGmid(cell.gmId)
        if cellRole ~= nil and cellRole.pos > 0 then
            return
        end
    end

    if self.guideCurrPos > 0 then 
        local cellRole = CardRoleManager:getRoleByGmid(cell.gmId)
        if cellRole ~= nil and cellRole.pos ~= self.guideCurrPos then
            return
        end
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

    if cell.isClick == true then
        return;
    end
    -- self.table_select:setContentOffset(self.offest );
    self:moveSelectCussor(cell,pos);
end


function ArmyLayer.cellTouchEndedHandle(cell)
    local self = cell.logic;
    if self.selectCussor then
        self.selectCussor:removeFromParentAndCleanup(true);
        self.selectCussor = nil;
    end
    self.isAutoIng = false;

    if cell.hasRole ~= true then
        return;
    end

    self:removeLongTouchTimer();

    local pos = cell:getTouchEndPos();

    self:releaseSelectCussor(cell,pos);
    self.table_select:setTouchEnabled(true);
end

function ArmyLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

function ArmyLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;

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

function ArmyLayer:moveSelectCussor(cell,pos)
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

function ArmyLayer:releaseSelectCussor(cell,pos)
    print("ArmyLayer:releaseSelectCussor(cell,pos) ------------1111")
    if cell.isClick == false  then
        print("ArmyLayer:releaseSelectCussor(cell,pos) ------------222")


        if (self.curIndex == nil) then
            return;
        end
        print("ArmyLayer:releaseSelectCussor(cell,pos) ------------333")

        local dargRole      = CardRoleManager:getRoleByGmid(cell.gmId);
        local toReplaceRole =  StrategyManager:getRoleByIndex(self.curIndex);

        if dargRole == nil then
            print("dargRole is nil ")
            return
        end

        if self.guideRolePos > 0 and self.curIndex ~= self.guideRolePos then
            return
        end
        print("ArmyLayer:releaseSelectCussor(cell,pos) ------------444")

        if self.guideChangePos > 0 and self.curIndex ~= self.guideChangePos then 
            return
        end
        print("ArmyLayer:releaseSelectCussor(cell,pos) ------------555",self.curIndex ,self.guideChangePos )

        --在阵中释放
        if (self.curIndex ~= -1) then 
            --从列表中拖到阵中
            if (cell.posIndex == -1) then
                --本来已经在阵中
                if dargRole.pos and dargRole.pos ~= 0 then
                    --且不是本角色目前所在的位置，做位置变更
                    if (toReplaceRole == nil or (toReplaceRole and toReplaceRole.gmId ~= dargRole.gmId)) then
                        print("ArmyLayer:releaseSelectCussor(cell,pos) ------------666",dargRole.pos,self.curIndex)
                        local sendMsg = {
                        dargRole.pos - 1,
                        self.curIndex - 1,
                        };
                        showLoading();
                        TFDirector:send(c2s.CHANGE_INDEX,sendMsg);
                        play_buzhenyidong()
                    end
                --要上阵，但是已经到达上限
                elseif (toReplaceRole == nil and not StrategyManager:canAddFightRole()) then
                    if StrategyManager.maxNum == 5 then
                        toastMessage(localizable.common_function_number_out);
                    else
                        local needLevel = FunctionOpenConfigure:getOpenLevel(700 + (StrategyManager.maxNum + 1))
                        if MainPlayer:getLevel() < needLevel then
                            local str = stringUtils.format(localizable.common_function_up_number,needLevel, StrategyManager.maxNum + 1)
                            toastMessage(str);
                        end
                    end 

                --要替换，但是替换对象是主角
                --elseif (toReplaceRole and  toReplaceRole.gmId == MainPlayer:getPlayerId()) then
                --    toastMessage("主角不能下阵");

                --上阵，如果目标存在角色，将其下阵
                else

                    --check是否为助战侠客
                    if AssistFightManager:isInAssist( self.currLineUpType, cell.gmId ) then
                        CommonManager:showOperateSureLayer(
                                        function()
                                            AssistFightManager:updateRoleOff(self.currLineUpType, cell.gmId)
                                            local battle = {cell.gmId,( self.curIndex - 1)}
                                            showLoading();
                                            TFDirector:send(c2s.TO_BATTLE,{battle})
                                            play_buzhenyidong()
                                        end,
                                        function()
                                            AlertManager:close()
                                            
                                        end,
                                        {
                                        title = localizable.common_tips,
                                        msg = localizable.common_tips_zhuzhan,
                                        }
                                    )
                    else
                        print("ArmyLayer:releaseSelectCussor(cell,pos) ------------777",cell.gmId,( self.curIndex - 1))
                        local battle = {cell.gmId,( self.curIndex - 1)}
                        showLoading();
                        TFDirector:send(c2s.TO_BATTLE,{battle})

                        play_buzhenyidong()
                    end
                end

            --阵中操作，更换位置   
            else
                local sendMsg = {              
                cell.posIndex - 1,
                self.curIndex - 1,   
                };
                print("ArmyLayer:releaseSelectCussor(cell,pos) ------------8888",sendMsg)
                showLoading();
                TFDirector:send(c2s.CHANGE_INDEX,sendMsg);

                play_buzhenyidong()
            end

            return;
        end

        --在右边列表释放
        if (self.curIndex == -1) then

            if (cell.posIndex == -1 ) then
                --放弃上阵，不做操作

            else
                --下阵
                --if (dargRole.gmId == MainPlayer:getPlayerId()) then
                --    toastMessage("主角不能下阵");
                --else
                    print("下阵:",dargRole.name);
                    showLoading();
                    TFDirector:send(c2s.OUT_BATTLE,{cell.gmId});
                    play_buzhenluoxia();
                --end
            end
        end
    end

    if cell:hitTest(pos) then     
        -- ArmyLayer.cellClickHandle(cell);
    end
end

function ArmyLayer.onAutoClickHandle(sender)
    local self = sender.logic;

    -- local  armylist = StrategyManager:getList()
    -- for pos in pairs(armylist) do
    --     self.button[pos].bg:setVisible(false);
    -- end

    self.isAutoIng = true;
    showLoading();
    TFDirector:send(c2s.AUTO_WAR_MATIX,{});
end

function ArmyLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    self.btn_close:setClickAreaLength(100);

    if self.assistFightView then
        self.assistFightView:registerEvents()
    end
    
    self.btn_auto.logic = self;
    self.btn_auto:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onAutoClickHandle));

    for i=1,9 do
        self.button[i]:addMEListener(TFWIDGET_CLICK,  self.cellClickHandle,1);
        self.button[i]:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1);
        self.button[i]:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle);
        self.button[i]:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle);
    end

    self.btn_sort.logic = self;
    self.btn_sort_pos.logic = self;
    self.btn_sort_power.logic = self;
    self.btn_sort_quality.logic = self;
    self.bg_sort.logic = self;

    self.btn_sort:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onShowSortMenuClickHandle));
    self.btn_sort_pos:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle),1);
    self.btn_sort_power:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle),1);
    self.btn_sort_quality:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle),1);
    self.bg_sort:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortCancelClickHandle));

    self.callEquipChange = function(sender)
        XiaKeExchangeManager:openEquipChangeLayer()
    end
    self.btn_equipchange:addMEListener(TFWIDGET_CLICK,audioClickfun(self.callEquipChange))

    self.updatePosCallBack = function(event)
    print("self.updatePosCallBack  ---111")
        if not self.isAutoIng then
            self:updateIcon(event.data[1])
        end
        self:updateStrategyBaseMsg();
    end;
    TFDirector:addMEGlobalListener(StrategyManager.UPDATE_STARTEGY_POS ,self.updatePosCallBack ) ;

    self.updateGenerralCallBack = function(event)
    print("self.updateGenerralCallBack  ---111")
        self:updateStrategyBaseMsg();
        self:refreshTable();
    end;
    TFDirector:addMEGlobalListener(StrategyManager.UPDATE_GENERRAL_LIST ,self.updateGenerralCallBack ) ;

    self.RoleStarUpResultCallBack = function (event)

        self:updateStrategyBaseMsg();
        self:refreshTable();
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_TRANSFER_RESULT,self.RoleStarUpResultCallBack)
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_BREAKTHROUGH_RESULT,self.RoleStarUpResultCallBack)


    self.AutoMatixComCallBack = function (event)
        self.isAutoIng = false;
        play_yijianshangzhen()
        local resPath = "effect/role_auto_matix_up.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("role_auto_matix_up_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))

        self:addChild(effect,2)

        effect:addMEListener(TFARMATURE_COMPLETE,function()
            effect:removeMEListener(TFARMATURE_COMPLETE) 
            effect:removeFromParent()
        end)
        effect:playByIndex(0, -1, -1, 0)
        self.playAutoMatixTimeId = TFDirector:addTimer(600, 1, nil, function()
            self:playAutoMatixComEffect()
        end);
        
    end
    TFDirector:addMEGlobalListener(StrategyManager.AUTO_WAR_MATIX_RESULT,self.AutoMatixComCallBack)


    -- add by king  大月卡增加属性
    self.monthCardUpdateAttr = function (event)
        self:updateStrategyBaseMsg()
    end
    TFDirector:addMEGlobalListener(MonthCardManager.MONTH_CARD_RefeshAttr,self.monthCardUpdateAttr)
    -- end
    if XiaKeExchangeManager:IsOpenEquipChange() == true then
        self.btn_equipchange:setVisible(true)
        self.img_point:setVisible(false)
    else
        self.img_point:setVisible(true)
        self.btn_equipchange:setVisible(false)
    end
end

function ArmyLayer:playAutoMatixComEffect()

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

    local  armylist = StrategyManager:getList()
        for index in pairs(armylist) do

            self:updateIcon( index );
            -- self.button[index].bg:setVisible(false);

            local role = StrategyManager:getRoleByIndex(index);
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

function ArmyLayer:refreshTable()
    if self.table_select == nil then
        return
    end
    
    CardRoleManager:reSortStrategy();
    local tb_pos = self.table_select:getContentOffset();
    self.table_select:reloadData();
    local currentSize = self.table_select:getContentSize()
    local tabSize = self.table_select:getSize()
    tb_pos.y = math.max(tb_pos.y , tabSize.height - currentSize.height)
    self.table_select:setContentOffset(tb_pos);
end   

function ArmyLayer:removeEvents()
    self.super.removeEvents(self)

    for i=1,9 do
        self.button[i]:removeMEListener(TFWIDGET_CLICK)
        self.button[i]:removeMEListener(TFWIDGET_TOUCHBEGAN)
        self.button[i]:removeMEListener(TFWIDGET_TOUCHMOVED)
        self.button[i]:removeMEListener(TFWIDGET_TOUCHENDED)
    end
    
    TFDirector:removeMEGlobalListener(StrategyManager.UPDATE_STARTEGY_POS, self.updatePosCallBack );
    self.updatePosCallBack = nil;

    TFDirector:removeMEGlobalListener(StrategyManager.UPDATE_GENERRAL_LIST, self.updateGenerralCallBack );
    self.updateGenerralCallBack = nil;

    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_TRANSFER_RESULT, self.RoleStarUpResultCallBack );
    self.RoleStarUpResultCallBack = nil;

    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_BREAKTHROUGH_RESULT, self.RoleStarUpResultCallBack );
    self.RoleStarUpResultCallBack = nil;

    TFDirector:removeMEGlobalListener(StrategyManager.AUTO_WAR_MATIX_RESULT, self.AutoMatixComCallBack );
    self.AutoMatixComCallBack = nil;

    TFDirector:removeTimer(self.playAutoMatixTimeId);
    self.playAutoMatixTimeId = nil;

    if self.assistFightView then
        self.assistFightView:removeEvents()
    end
    
    -- add by king  大月卡增加属性
    TFDirector:removeMEGlobalListener(MonthCardManager.MONTH_CARD_RefeshAttr,self.monthCardUpdateAttr)
    self.monthCardUpdateAttr = nil
    -- end
end

function ArmyLayer:updateIcon( index )
    local role = StrategyManager:getRoleByIndex(index)

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
        cell.hasRole = false;   
        Public:addLianTiEffect(cell,0,false)
    end
end


-- function ArmyLayer:isHaveBook(cardRole)
--     if cardRole == nil then 
--         return false
--     end

--     -- 武学等级
--     local martialLevel = cardRole.martialLevel
--     local martialList  = cardRole.martialList
--     local bookListData = MartialRoleConfigure:findByRoleIdAndMartialLevel(cardRole.id, martialLevel)

--     local bookList     = bookListData:getMartialTable()
--     for i=1, 6 do
--         local status = self:isBookOnThisPosition(i, cardRole.level, bookList, martialList)

--         if status == true then
--             return true
--         end
--     end

--     return false
-- end

-- function ArmyLayer:isBookOnThisPosition(index, roleLevel, bookList, martialList)

--     local bookid   = bookList[index]
--     local bookInfo = MartialData:objectByID(bookid)

--     -- 该位置有书装备
--     if martialList[index] == nil then

--         local status = self:getBookStatus(bookInfo, roleLevel)

--         if status ==  1 or status == 3 then

--             return true
--         end
--     end


--     return false
-- end

-- function ArmyLayer:getBookStatus(bookInfo, Level)
    
--     -- 0 不存在
--     -- 1 背包存在并且可以穿戴
--     -- 2 背包存在并且不可以穿戴
--     -- 3 可以合成并且可以穿戴
--     -- 4 可以合成并且不可以穿戴
--     local bookStatus = 0

--     local roleLevel = Level
--     local id        = bookInfo.goodsTemplate.id
--     local bag       = BagManager:getItemById(id)
--     local bookLevel = bookInfo.goodsTemplate.level

--     -- 背包中存在
--     if bag then
--         bookStatus = 1
--     else
--         if MartialManager:isCanSynthesisById(id, 1) then
--             bookStatus = 3
--         end
--     end

--     -- 穿戴等级
--     -- 有物品 才判断等级
--     if bookLevel > roleLevel and bookStatus > 0 then
--         bookStatus = bookStatus + 1
--     end

--     return bookStatus
-- end

return ArmyLayer;
