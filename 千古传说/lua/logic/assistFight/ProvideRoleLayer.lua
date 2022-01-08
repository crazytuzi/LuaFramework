--[[
******好友助战*******

	-- by quanhuan
	-- 2016/1/22
	
]]

local ProvideRoleLayer = class("ProvideRoleLayer")

local selectRole = {}
local requesRole = {}

function ProvideRoleLayer:ctor(data, layer)
    self.ui = data
    self.parentLayer = layer
	self:initUI(data)

    self.cardRoleList = nil
    self.cardRoleList = TFArray:new()
    for role in CardRoleManager.cardRoleList:iterator() do
        if role.id ~= MainPlayer:getProfession() then
            self.cardRoleList:pushBack(role)
        end
    end    
end

function ProvideRoleLayer:initUI( ui )

    self.btn_chakan = TFDirector:getChildByPath(ui, "btn_chakan")
    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
    
    local xuqiuNode = TFDirector:getChildByPath(ui, "img_xuqiu")
    self.requestBtn = TFDirector:getChildByPath(ui, "img_xuqiu")
    self.requestBtn:setTouchEnabled(true)
    self.imgRequestBg = TFDirector:getChildByPath(xuqiuNode, "panel_info")
    self.imgRequestIcon = TFDirector:getChildByPath(xuqiuNode, "img_icon")
    self.txtRequestName = TFDirector:getChildByPath(xuqiuNode, "txt_name")
    

    local provideNode = TFDirector:getChildByPath(ui, 'role_select')
    self.provideTbl = {}
    for i=1,2 do
        self.provideTbl[i] = {}
        local headNode = TFDirector:getChildByPath(provideNode, 'img_di'..i)
        self.provideTbl[i].btnBg = TFDirector:getChildByPath(headNode, 'panel_info')
        self.provideTbl[i].btnBg.posIndex = i        
        self.provideTbl[i].headFrame = TFDirector:getChildByPath(headNode, 'img_quality')
        self.provideTbl[i].head = TFDirector:getChildByPath(headNode, 'img_icon')
        self.provideTbl[i].martialLevel = TFDirector:getChildByPath(headNode, 'img_martialLevel')
        self.provideTbl[i].imgZhiye = TFDirector:getChildByPath(headNode, 'img_zhiye')
        self.provideTbl[i].txtLevel = TFDirector:getChildByPath(headNode, 'txt_lv')
        self.provideTbl[i].txtCount = TFDirector:getChildByPath(headNode, 'txt_leiji')          
        self.provideTbl[i].btnBg:setTouchEnabled(true)
    end

    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui,"panel_cardregional")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    selectRole = {}
    local roleInfo1 = AssistFightManager:getRoleInfoByType(1) or {}
    for i=1,2 do
        local role = CardRoleManager:getRoleById(roleInfo1[i])
        if role and role.gmId ~= 0 then
            selectRole[i] = role.gmId
        else
            selectRole[i] = 0
        end
    end
    requesRole = {}
    local roleInfo2 = AssistFightManager:getRoleInfoByType(2)
    local role = RoleData:objectByID(roleInfo2)        
    if role then
        requesRole[1] = roleInfo2
    else
        requesRole[1] = 0
    end

    self:loadRequestRole()

    self:refreshSelectRoleDetails()
end

function ProvideRoleLayer:onShow()
end

function ProvideRoleLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)

    for i=1,2 do
        self.provideTbl[i].btnBg.logic = self
        self.provideTbl[i].btnBg.posIndex = i
        self.provideTbl[i].btnBg:addMEListener(TFWIDGET_CLICK,  self.cellClickHandle,1)
        self.provideTbl[i].btnBg:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1)
        self.provideTbl[i].btnBg:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle)
        self.provideTbl[i].btnBg:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle)
    end
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.requestBtn:addMEListener(TFWIDGET_CLICK, self.switchLayer,1)
    self.requestBtn.logic = self

    self.btn_chakan:addMEListener(TFWIDGET_CLICK, self.chakanBtnClick,1)
    self.btn_chakan.logic = self

    self.updateProvideCallBack = function (event)
        selectRole = {}
        local roleInfo1 = AssistFightManager:getRoleInfoByType(1)
        for i=1,2 do
            local role = CardRoleManager:getRoleById(roleInfo1[i])
            if role and role.gmId ~= 0 then
                selectRole[i] = role.gmId
            else
                selectRole[i] = 0
            end
        end
        self:refreshSelectRoleDetails()
        self.TabView:reloadData()
    end
    TFDirector:addMEGlobalListener(AssistFightManager.UPDATEPROVIDE, self.updateProvideCallBack)

    self.TabView:reloadData()
    self.registerEventCallFlag = true 
end

function ProvideRoleLayer:removeEvents()
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    TFDirector:removeMEGlobalListener(AssistFightManager.UPDATEPROVIDE, self.updateProvideCallBack)
    self.updateProvideCallBack = nil

    self.registerEventCallFlag = nil  
end

function ProvideRoleLayer:dispose()

end


function ProvideRoleLayer.cellSizeForTable(table,idx)
    return 135,960
end

function ProvideRoleLayer.numberOfCellsInTableView(table)    
    local self = table.logic;
    return math.max(math.ceil(self.cardRoleList:length()/3)  ,3);
end

function ProvideRoleLayer.tableCellAtIndex(table, idx)

    local self = table.logic;
    local cell = table:dequeueCell()
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        local item_node = TFPanel:create();
        cell:addChild(item_node);
        cell.item_node = item_node;

        for i=1,3 do
            local m_node = createUIByLuaNew("lua.uiconfig_mango_new.role.ArmyRoleItem")
            m_node:setScale(0.65)

            m_node.panel_empty = TFDirector:getChildByPath(m_node, 'panel_empty');
            m_node.panel_info  = TFDirector:getChildByPath(m_node, 'panel_info');
            -- m_node.bar_xuetiao = TFDirector:getChildByPath(m_node, 'bar_xuetiao');
            -- m_node.img_xuetiao = TFDirector:getChildByPath(m_node, 'img_xuetiao');
            -- m_node.img_xuetiao:setVisible(false)
            m_node:setName("m_role" .. i);
            m_node:setPosition(ccp(5 + 118 * (i - 1) ,0));

            item_node:addChild(m_node);
            item_node.m_node = m_node; 
        end
    end

    for i=1,3 do
        local roleIndex = idx*3 + i;

        local m_node = TFDirector:getChildByPath(cell.item_node, 'm_role' .. i);
        local roleItem = self.cardRoleList:objectAt(roleIndex);
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


--添加玩家节点
function ProvideRoleLayer:loadItemNode(item_node,roleItem)
    
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
    img_icon:setTexture(roleItem:getIconPath());
    local img_pinzhiditu = TFDirector:getChildByPath(item_node, 'img_pinzhiditu');
    img_pinzhiditu:setTexture(GetColorIconByQuality(roleItem.quality));

    local txt_name = TFDirector:getChildByPath(item_node, 'txt_name');
    local roleStar = ""
    if roleItem.starlevel > 0 then
        roleStar = roleStar .. " +" .. roleItem.starlevel
    end
    txt_name:setText(roleItem.name..roleStar);

    local img_zhiye = TFDirector:getChildByPath(item_node, 'img_zhiye');
    img_zhiye:setTexture("ui_new/fight/zhiye_".. roleItem.outline ..".png");

    local img_quality = TFDirector:getChildByPath(item_node, 'img_quality');
    img_quality:setTexture(GetFightRoleIconByWuXueLevel(roleItem.martialLevel))

    local img_fight = TFDirector:getChildByPath(item_node, 'img_zhan');
    img_fight:setVisible(false);

    --添加助战标识
    local img_zhu = TFDirector:getChildByPath(item_node, 'img_zhu')
    img_zhu:setVisible(false)

    local txt_level = TFDirector:getChildByPath(item_node, 'txt_lv_word');
    txt_level:setText(roleItem.level);
end

function ProvideRoleLayer:removeUI()


    self.button      = nil;
    self.btn_close   = nil;
    self.lastPoint   = nil;
    self.curIndex    = nil;
end

function ProvideRoleLayer.cellClickHandle(sender)
    local self = sender.logic;
    -- print('sender.isClick = ',sender.isClick)
    if sender.isClick == true then
        play_press()
    end
end

function ProvideRoleLayer.cellTouchBeganHandle(cell)
    local self = cell.logic;
    -- print('cell.hasRole = ',cell.hasRole)
    if cell.hasRole ~= true then
        return;
    end

    cell.isClick = true;
    cell.isDrag  = false;
    self.isMove = false;

    self.offest = self.TabView:getContentOffset();

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
                self.TabView:setTouchEnabled(false);
            else
                cell.isDrag  = false;
                self.TabView:setTouchEnabled(true);
            end
        end
    end;

    if (cell.posIndex == -1) then
        self:removeLongTouchTimer();
        self.longTouchTimerId = TFDirector:addTimer(0.001, -1, nil, self.onLongTouch); 
    end

end

function ProvideRoleLayer.cellTouchMovedHandle(cell)
    local self = cell.logic;
    self.isMove = true;

    if cell.hasRole ~= true then
        return;
    end
  
    local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos());

    local pos = cell:getTouchMovePos();
    print('pos = ',pos)

    if self.selectCussor == nil then
        if (cell.posIndex ~= -1 or cell.isDrag == true ) then
            self:createSelectCussor(cell,pos);
        end
    end

    if cell.isClick == true then
        return;
    end   

    self:moveSelectCussor(cell,pos);
end


function ProvideRoleLayer.cellTouchEndedHandle(cell)
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
    self.TabView:setTouchEnabled(true);
end

function ProvideRoleLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

function ProvideRoleLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;
    -- print('cell.gmId = ',cell.gmId)
    local role = CardRoleManager:getRoleByGmid(cell.gmId);
    self.selectCussor = TFImage:create();
    self.selectCussor:setFlipX(true);
    self.selectCussor:setTexture(role:getIconPath());
    self.selectCussor:setScale(0.7)
    -- self.selectCussor:setScale(20 / 15.0);
    self.selectCussor:setPosition(pos);
    self.ui:getParent():addChild(self.selectCussor);
    self.selectCussor:setZOrder(100);
   
    self.curIndex = cell.posIndex;
end

function ProvideRoleLayer:moveSelectCussor(cell,pos)
    local v = ccpSub(pos, self.lastPoint);
    self.lastPoint = pos;
    local scp = ccpAdd(self.selectCussor:getPosition(), v);
    self.selectCussor:setPosition(scp);
    self.selectCussor:setVisible(true);
    self.curIndex = nil
    if  self.TabView:hitTest(pos) then
        self.curIndex = -1;
    end
    for i=1,2 do
        if  self.provideTbl[i].btnBg:hitTest(pos) then
            self.curIndex = self.provideTbl[i].btnBg.posIndex;
            break;
        end
    end

end

function ProvideRoleLayer:releaseSelectCussor(cell,pos)

    if cell.isClick == false  then
        -- print('----------------------------------000')
        -- print('self.curIndex = ',self.curIndex)
        if (self.curIndex == nil) then
            return;
        end

        local dargRole      = CardRoleManager:getRoleByGmid(cell.gmId);
        local toReplaceRole =  self:getRoleByIndex(self.curIndex);
        --在阵中释放
        -- print('----------------------------------111')
        if (self.curIndex ~= -1) then 
            --从列表中拖到阵中
            -- print('----------------------------------222')
            if (cell.posIndex == -1) then
                local role_pos = self:getIndexByRole(cell.gmId )
                --本来已经在阵中
                -- print('----------------------------------333')
                if role_pos and role_pos ~= 0 then
                    --且不是本角色目前所在的位置，做位置变更
                    if (toReplaceRole == nil or (toReplaceRole and toReplaceRole.gmId ~= dargRole.gmId)) then
                        self:ChangePos((role_pos), (self.curIndex))
                        play_buzhenyidong()
                        -- print('----------------------------------444')

                    end                
                else
                    -- print('----------------------------------555')
                    self:OnBattle(cell.gmId, (self.curIndex))
                    play_buzhenyidong()
                end
            --阵中操作，更换位置   
            else
                -- print('----------------------------------666')
                self:ChangePos((cell.posIndex), (self.curIndex))
                play_buzhenyidong()
            end
            self:refreshSelectRoleDetails()
            return;
        end

        --在右边列表释放
        if (self.curIndex == -1) then

            if (cell.posIndex == -1 ) then
                --放弃上阵，不做操作
            else
                    -- print("下阵:",dargRole.name);

                    self:OutBattle(cell.gmId)

                    play_buzhenluoxia();
                --end
            end
        end
        self:refreshSelectRoleDetails()
    end
end

function ProvideRoleLayer:getRoleByIndex(idx)

    local gmId = selectRole[idx]
    local role = CardRoleManager:getRoleByGmid(gmId)
    return role

end 

function ProvideRoleLayer:getIndexByRole(gmId)

    for k,v in pairs(selectRole) do
        if v == gmId then
            return k
        end
    end
end 

function ProvideRoleLayer:OnBattle( gmId, curIndex )

    local roleId = {0,0}
    for i=1,2 do
        local cardRole = CardRoleManager:getRoleByGmid(selectRole[i])
        if cardRole then
            roleId[i] = cardRole.gmId
        end
    end

    local cardRole = CardRoleManager:getRoleByGmid(gmId)
    if cardRole then
        roleId[curIndex] = cardRole.gmId
        -- print('cardRole.id = ',cardRole.id)
    end
    -- print('gmId= ',gmId)
    -- print('curIndex= ',curIndex)
    AssistFightManager:requestUpdateProvide(roleId[1],roleId[2])
end

function ProvideRoleLayer:OutBattle(gmId)

    local roleId = {0,0}
    for i=1,2 do
        local cardRole = CardRoleManager:getRoleByGmid(selectRole[i]) or {}
        if cardRole and cardRole.gmId == gmId then
            roleId[i] = 0
        else
            roleId[i] = cardRole.gmId or 0
        end
    end

    AssistFightManager:requestUpdateProvide(roleId[1],roleId[2])
end
function ProvideRoleLayer:ChangePos(oldpos, newpos)

    local roleId = {0,0}

    local oldGmId = selectRole[oldpos]
    roleId[oldpos] = selectRole[newpos]
    roleId[newpos] = oldGmId
     for i=1,2 do
        local cardRole = CardRoleManager:getRoleByGmid(roleId[i])
        if cardRole then
            roleId[i] = cardRole.gmId
        else
            roleId[i] = 0
        end
    end
    AssistFightManager:requestUpdateProvide(roleId[1],roleId[2])
end

function ProvideRoleLayer:refreshSelectRoleDetails()
    
    for i=1,#self.provideTbl do
        local roleItem = CardRoleManager:getRoleByGmid( selectRole[i] )
        if roleItem then
            self.provideTbl[i].btnBg.hasRole = true
            self.provideTbl[i].btnBg.gmId = selectRole[i]
            self.provideTbl[i].btnBg:setVisible(true)
            self.provideTbl[i].headFrame:setTexture(GetColorIconByQuality(roleItem.quality))
            self.provideTbl[i].head:setTexture(roleItem:getIconPath())

            self.provideTbl[i].martialLevel:setTexture(GetFightRoleIconByWuXueLevel(roleItem.martialLevel))
            self.provideTbl[i].imgZhiye:setTexture("ui_new/fight/zhiye_".. roleItem.outline ..".png");
            self.provideTbl[i].txtLevel:setText(roleItem.level)
            local useInfo = AssistFightManager:getMyRoleUseInfo( roleItem.id ) or {}
            local useCount = useInfo.times or 0
            -- local str = TFLanguageManager:getString(ErrorCodeData.Assist_UI_Assist)
            -- str = string.format(str, useCount)
            local str = stringUtils.format(localizable.Assist_UI_Assist, useCount)

            self.provideTbl[i].txtCount:setVisible(true)
            self.provideTbl[i].txtCount:setText(str)
        else
            self.provideTbl[i].btnBg.hasRole = false
            self.provideTbl[i].btnBg:setVisible(false)
            self.provideTbl[i].txtCount:setVisible(false)
        end
            
    end
end

function ProvideRoleLayer:refreshTableView()
    self.TabView:reloadData()
end

function  ProvideRoleLayer.switchLayer( btn )
    local self = btn.logic
    if self.parentLayer then
        self.parentLayer:onShowLayerClick(2)
    end
end

function ProvideRoleLayer:setVisible(v)
    self.ui:setVisible(v)
    if v then
        selectRole = {}
        local roleInfo1 = AssistFightManager:getRoleInfoByType(1) or {}
        for i=1,2 do
            local role = CardRoleManager:getRoleById(roleInfo1[i])
            if role and role.gmId ~= 0 then
                selectRole[i] = role.gmId
            else
                selectRole[i] = 0
            end
        end
        requesRole = {}
        local roleInfo2 = AssistFightManager:getRoleInfoByType(2)
        local role = RoleData:objectByID(roleInfo2)        
        if role then
            requesRole[1] = roleInfo2
        else
            requesRole[1] = 0
        end

        self:loadRequestRole()

        self:refreshSelectRoleDetails()
    end
end

function ProvideRoleLayer:loadRequestRole()
    local roleId = requesRole[1]
    local role = RoleData:objectByID(roleId)
    if role then
        self.imgRequestBg:setVisible(true)
        self.imgRequestIcon:setTexture(role:getIconPath())
        self.txtRequestName:setVisible(true)
        self.txtRequestName:setText(role.name)
    else
        self.txtRequestName:setVisible(false)
        self.imgRequestBg:setVisible(false)
    end
end

function ProvideRoleLayer.chakanBtnClick( btn )
    local self = btn.logic
    if self.parentLayer then
        self.parentLayer:onChakanBtnClick()
    end
end
return ProvideRoleLayer