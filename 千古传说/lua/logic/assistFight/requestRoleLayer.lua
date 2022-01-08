--[[
******好友助战*******

    -- by quanhuan
    -- 2016/1/22
    
]]

local requestRoleLayer = class("requestRoleLayer")

local selectRole = {}
local requesRole = {}

function requestRoleLayer:ctor(data, layer)
    self.ui = data
    self.parentLayer = layer
    self:initUI(data)
end

function requestRoleLayer:initUI( ui )

    self.btn_chakan = TFDirector:getChildByPath(ui, "btn_chakan")
    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
    
    local xuqiuNode = TFDirector:getChildByPath(ui, "img_xuqiu")
    self.requestBtn = TFDirector:getChildByPath(ui, "img_xuqiu")
    self.imgRequestBg = TFDirector:getChildByPath(xuqiuNode, "panel_info")
    self.imgRequestBg:setTouchEnabled(true)
    self.imgRequestIcon = TFDirector:getChildByPath(xuqiuNode, "img_icon")
    self.txtRequestName = TFDirector:getChildByPath(xuqiuNode, "txt_name")
    self.img_tigong = TFDirector:getChildByPath(ui, "img_tigong")
    self.img_tigong:setTouchEnabled(true)
    

    local provideNode = TFDirector:getChildByPath(ui, 'img_tigong')
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

    -- selectRole = {}
    -- local roleInfo1 = AssistFightManager:getRoleInfoByType(1) or {}
    -- for i=1,2 do
    --     local role = CardRoleManager:getRoleById(roleInfo1[i])
    --     if role and role.gmId ~= 0 then
    --         selectRole[i] = role.gmId
    --     else
    --         selectRole[i] = 0
    --     end
    -- end
    -- -- print('roleInfo1---------------------- = ',roleInfo1)

    -- requesRole = {}
    -- local roleInfo2 = AssistFightManager:getRoleInfoByType(2)
    -- local role = RoleData:objectByID(roleInfo2)        
    -- if role then
    --     requesRole[1] = roleInfo2
    -- else
    --     requesRole[1] = 0
    -- end
    -- self.roleList = AssistFightManager:getRequestRoleList(self.parentLayer.LineUpType)
    self.roleList = TFArray:new()
    -- self:loadProvideRole()

    -- self:refreshSelectRoleDetails()
end

function requestRoleLayer:onShow()
end

function requestRoleLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);

    self.imgRequestBg.logic = self
    self.imgRequestBg.posIndex = 1
    self.imgRequestBg:addMEListener(TFWIDGET_CLICK,  self.cellClickHandle,1)        
    self.imgRequestBg:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1)
    self.imgRequestBg:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle)
    self.imgRequestBg:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle)

    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.img_tigong:addMEListener(TFWIDGET_CLICK, self.switchLayer,1)
    self.img_tigong.logic = self

    self.btn_chakan:addMEListener(TFWIDGET_CLICK, self.chakanBtnClick,1)
    self.btn_chakan.logic = self

    self.updateDemandRoleCallBack = function (event)
        requesRole = {}
        local roleInfo2 = AssistFightManager:getRoleInfoByType(2)
        -- print('roleInfo2 = ',roleInfo2)
        local role = RoleData:objectByID(roleInfo2) 
        -- print('roleInfo2 = ',roleInfo2)
        -- print('role = ',role)       
        if role then
            requesRole[1] = roleInfo2
        else
            requesRole[1] = 0
        end
        self:refreshSelectRoleDetails()
        self.TabView:reloadData()
    end
    TFDirector:addMEGlobalListener(AssistFightManager.UPDATEDEMANDROLE, self.updateDemandRoleCallBack)


    self.TabView:reloadData()
    self.registerEventCallFlag = true 
end

function requestRoleLayer:removeEvents()
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    TFDirector:removeMEGlobalListener(AssistFightManager.UPDATEDEMANDROLE, self.updateDemandRoleCallBack)
    self.updateDemandRoleCallBack = nil

    self.registerEventCallFlag = nil  
end

function requestRoleLayer:dispose()

end


function requestRoleLayer.cellSizeForTable(table,idx)
    return 135,960
end

function requestRoleLayer.numberOfCellsInTableView(table)    
    local self = table.logic;
    return math.max(math.ceil(self.roleList:length()/3)  ,3);
end

function requestRoleLayer.tableCellAtIndex(table, idx)

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
        local roleItem = self.roleList:objectAt(roleIndex);
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
function requestRoleLayer:loadItemNode(item_node,roleItem)
    
    local btn_icon = TFDirector:getChildByPath(item_node, 'btn_pingzhianniu');
    btn_icon.logic = self;
    btn_icon:setTag(roleItem.id);

    btn_icon:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle);
    btn_icon:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle);
    btn_icon:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle);
    btn_icon:addMEListener(TFWIDGET_CLICK,  self.cellClickHandle);

    btn_icon.posIndex = -1;  
    btn_icon.hasRole = true;  
    btn_icon.id  = roleItem.id;

    local img_icon = TFDirector:getChildByPath(item_node, 'img_touxiang');
    img_icon:setTexture(roleItem:getIconPath());
    local img_pinzhiditu = TFDirector:getChildByPath(item_node, 'img_pinzhiditu');
    img_pinzhiditu:setTexture(GetColorIconByQuality(roleItem.quality));

    local txt_name = TFDirector:getChildByPath(item_node, 'txt_name');   
    txt_name:setText(roleItem.name);

    local img_zhiye = TFDirector:getChildByPath(item_node, 'img_zhiye');
    img_zhiye:setVisible(false)
    -- img_zhiye:setTexture("ui_new/fight/zhiye_".. roleItem.outline ..".png");


    local img_quality = TFDirector:getChildByPath(item_node, 'img_quality');
    img_quality:setVisible(false)
    -- img_quality:setTexture(GetFightRoleIconByWuXueLevel(roleItem.martialLevel))

    local img_fight = TFDirector:getChildByPath(item_node, 'img_zhan');
    img_fight:setVisible(false);

    --添加助战标识
    local img_zhu = TFDirector:getChildByPath(item_node, 'img_zhu')
    img_zhu:setVisible(false)

    local txt_level = TFDirector:getChildByPath(item_node, 'txt_lv_word');
    txt_level:setVisible(false)

    local img_lv = TFDirector:getChildByPath(item_node, 'img_lv');
    img_lv:setVisible(false)

    local img_fate = TFDirector:getChildByPath(item_node, 'img_fate');
    if roleItem.fate == 1 then
        img_fate:setVisible(true)
    else
        img_fate:setVisible(false)
    end
    -- txt_level:setText(roleItem.level);
end

function requestRoleLayer:removeUI()


    self.button      = nil;
    self.btn_close   = nil;
    self.lastPoint   = nil;
    self.curIndex    = nil;
end

function requestRoleLayer.cellClickHandle(sender)
    local self = sender.logic;
    -- print('sender.isClick = ',sender.isClick)
    if sender.isClick == true then
        play_press()
    end
end

function requestRoleLayer.cellTouchBeganHandle(cell)
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

function requestRoleLayer.cellTouchMovedHandle(cell)
    local self = cell.logic;
    self.isMove = true;

    if cell.hasRole ~= true then
        return;
    end

  
    local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos());

    local pos = cell:getTouchMovePos();

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


function requestRoleLayer.cellTouchEndedHandle(cell)
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

function requestRoleLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

function requestRoleLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;
    -- print('cell = ',cell.id)
    
    local role = self:getRoleById(cell.id);
    -- print('role = ',role)
    self.selectCussor = TFImage:create();
    self.selectCussor:setFlipX(true);
    self.selectCussor:setTexture(role:getIconPath());
    -- self.selectCussor:setScale(20 / 15.0);
    self.selectCussor:setPosition(pos);
    self.ui:getParent():addChild(self.selectCussor);
    self.selectCussor:setZOrder(100);
   
    self.curIndex = cell.posIndex;
    -- print('cell.posIndex = ',cell.posIndex)
    
end

function requestRoleLayer:moveSelectCussor(cell,pos)
    local v = ccpSub(pos, self.lastPoint);
    self.lastPoint = pos;
    local scp = ccpAdd(self.selectCussor:getPosition(), v);
    self.selectCussor:setPosition(scp);
    self.selectCussor:setVisible(true);
    self.curIndex = nil
    if  self.TabView:hitTest(pos) then
        self.curIndex = -1;
    end

    if  self.imgRequestBg:hitTest(pos) then
        self.curIndex = self.imgRequestBg.posIndex
    end

end

function requestRoleLayer:releaseSelectCussor(cell,pos)

    if cell.isClick == false  then
        -- print('----------------------------------000')
        -- print('self.curIndex = ',self.curIndex)
        if (self.curIndex == nil) then
            return;
        end

        local dargRole      = self:getRoleById(cell.id);
        local toReplaceRole =  self:getRoleByIndex(self.curIndex);
        --在阵中释放
        -- print('----------------------------------111')
        if (self.curIndex ~= -1) then 
            --从列表中拖到阵中
            -- print('----------------------------------222')
            if (cell.posIndex == -1) then
                local role_pos = self:getIndexByRole(cell.id )
                --本来已经在阵中
                -- print('----------------------------------333')
                if role_pos and role_pos ~= 0 then
                    --且不是本角色目前所在的位置，做位置变更
                    if (toReplaceRole == nil or (toReplaceRole and toReplaceRole.id ~= dargRole.id)) then
                        self:ChangePos((role_pos), (self.curIndex))
                        play_buzhenyidong()
                        -- print('----------------------------------444')

                    end                
                else
                    -- print('----------------------------------555')
                    self:OnBattle(cell.id, (self.curIndex))
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

                    self:OutBattle(cell.id)

                    play_buzhenluoxia();
                --end
            end
        end
        self:refreshSelectRoleDetails()
    end
end

function requestRoleLayer:getRoleByIndex(idx)

    local id = requesRole[idx]
    local role = self:getRoleById(id)
    return role

end 

function requestRoleLayer:getIndexByRole(id)

    for k,v in pairs(requesRole) do
        if v == id then
            return k
        end
    end
end 

function requestRoleLayer:OnBattle( id, curIndex )
    -- requesRole[curIndex] = id
    -- self:refreshTableView()
    AssistFightManager:requestUpdateDemand(id)
end

function requestRoleLayer:OutBattle(id)
    -- for k,v in pairs(requesRole) do
    --     if v == id then
    --         requesRole[k] = 0
    --         break
    --     end
    -- end
    -- self:refreshTableView()
    AssistFightManager:requestUpdateDemand(0)
end
function requestRoleLayer:ChangePos(oldpos, newpos)
    -- local oldGmId = requesRole[oldpos]
    -- requesRole[oldpos] = requesRole[newpos]
    -- requesRole[newpos] = oldGmId
    -- self:refreshTableView()
end

function requestRoleLayer:refreshSelectRoleDetails()

    local roleItem = RoleData:objectByID( requesRole[1] )
    -- print('roleItem = ',roleItem)
    if roleItem then
        self.imgRequestBg.hasRole = true
        self.imgRequestBg.id = requesRole[1]
        self.imgRequestBg:setVisible(true)
        self.imgRequestIcon:setTexture(roleItem:getIconPath())
        self.txtRequestName:setVisible(true)
        self.txtRequestName:setText(roleItem.name)
    else
        self.txtRequestName:setVisible(false)
        self.imgRequestBg.hasRole = false
        self.imgRequestBg:setVisible(false)
    end
  
end

function requestRoleLayer:refreshTableView()
    self.TabView:reloadData()
end

function  requestRoleLayer.switchLayer( btn )
    local self = btn.logic
    if self.parentLayer then
        self.parentLayer:onShowLayerClick(1)
    end
end

function requestRoleLayer:setVisible(v)
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
        self.roleList = AssistFightManager:getRequestRoleList(self.parentLayer.LineUpType)

        self:loadProvideRole()

        self:refreshSelectRoleDetails()

        self.TabView:reloadData()
    end
end

function requestRoleLayer:loadProvideRole()
    -- print('selectRole = ',selectRole)
    for i=1,#self.provideTbl do       
        local roleItem = CardRoleManager:getRoleByGmid( selectRole[i] )
        -- print('roleItem = ',roleItem)
        if roleItem then
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
            self.provideTbl[i].txtCount:setVisible(false)
            self.provideTbl[i].btnBg:setVisible(false)
        end     
    end    
end

function requestRoleLayer:getRoleById(roleId)
    for role in self.roleList:iterator() do
        if role.id == roleId then
            return role
        end
    end
end

function requestRoleLayer.chakanBtnClick( btn )
    local self = btn.logic
    if self.parentLayer then
        self.parentLayer:onChakanBtnClick()
    end
end
return requestRoleLayer