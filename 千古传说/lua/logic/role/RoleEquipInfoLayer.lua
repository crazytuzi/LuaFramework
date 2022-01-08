--[[
******穿戴装备*******

    -- by Stephen.tao
    -- 2013/12/05

    -- by haidong.gan
    -- 2014/4/10
]]

local RoleEquipInfoLayer = class("RoleEquipInfoLayer", BaseLayer)

local item_height = 120;
local item_width = 110;
local item_length = 3;

function RoleEquipInfoLayer:ctor(gmId)
    self.super.ctor(self,data);

    self.isfirst = true
    self:init("lua.uiconfig_mango_new.role.EquipListLayer");

end

function RoleEquipInfoLayer:loadData(roleGmId,type)
    self.roleGmId   = roleGmId;
    self.type     = type;
    self.selectEquipGmId = nil;
end

function RoleEquipInfoLayer:onShow()
    self.super.onShow(self)
    
    self:refreshBaseUI();
    self:refreshUI();
    if self.isfirst then
        self.isfirst = false
        self.ui:runAnimation("Action0", 1)
    end
end

function RoleEquipInfoLayer:refreshBaseUI()

end


function RoleEquipInfoLayer:refreshUI()
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);
    self.equipList = nil;
    self:refreshTable();

    
    -- add by king
    self:showOutLayerWhenIsNotEnough()


end

function RoleEquipInfoLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.sortType = "power"

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_improve    = TFDirector:getChildByPath(ui, 'btn_tiejiangpu');


    -- CardRoleManager:setSortStrategyForPos();

    self.bg_table      = TFDirector:getChildByPath(ui, 'panel_zhuangbeihuadong');
    local  tableView   =  TFTableView:create();
    self.table_select  = tableView;

    tableView.logic    = self;
    tableView:setTableViewSize(self.bg_table:getContentSize());
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL);
    tableView:setVerticalFillOrder(0);

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable);
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex);
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView);
    self.bg_table:addChild(tableView,2);
    Public:bindScrollFun(tableView);
    -- Public:bindScrollFun(self.table_select);

    self.btn_sort            = TFDirector:getChildByPath(ui, 'btn_xiala');
    self.btn_sort_pos        = TFDirector:getChildByPath(ui, 'btn_zhuangbei');
    self.btn_sort_power      = TFDirector:getChildByPath(ui, 'btn_zhanli');
    self.btn_sort_quality    = TFDirector:getChildByPath(ui, 'btn_pinzhi');
    self.img_select          = TFDirector:getChildByPath(ui, 'img_select');
    
    self.bg_sort             = TFDirector:getChildByPath(ui, 'panel_bg');
    -- self.bg_sort:setSwallowTouch(false);
    self.node_menu           = TFDirector:getChildByPath(ui, 'panel_menu');
    self.groupButtonManager  = GroupButtonManager:new( {[1] = self.btn_sort_power, [2] = self.btn_sort_quality});
    
    self.img_select:setTexture("ui_new/array/js_zhanli_press_btn.png");

    self.node_menu:setVisible(false);
    self.btn_sort:setVisible(true);
end

function RoleEquipInfoLayer.onShowSortMenuClickHandle(sender)
    local self = sender.logic;
    self.node_menu:setVisible(true);
    -- self.btn_sort:setVisible(false);
end

function RoleEquipInfoLayer.onSortSelectClickHandle(sender)
    local self = sender.logic;

    self.node_menu:setVisible(false);
    -- self.btn_sort:setVisible(true);

    if (self.groupButtonManager:getSelectButton() == sender) then
       return;
    end


   -- if sender == self.btn_sort_pos then
   --      -- CardRoleManager:setSortStrategyForPos();
   --      self.img_select:setTexture("ui_new/roleequip/js_zhanli_icon.png");
   if sender == self.btn_sort_power then
        -- CardRoleManager:setSortStrategyForPower();
        self.img_select:setTexture("ui_new/array/js_zhanli_press_btn.png");
        self.sortType = "power"
   elseif sender == self.btn_sort_quality then
        -- CardRoleManager:setSortStrategyForQuality();
        self.img_select:setTexture("ui_new/array/js_pinzhi_press_btn.png");
        self.sortType = "quality"
   end

   self.groupButtonManager:selectBtn(sender);
   self:refreshTable();
end

function RoleEquipInfoLayer.onSortCancelClickHandle(sender)
    local self = sender.logic;
    self.node_menu:setVisible(false);
    self.btn_sort:setVisible(true);
end

function RoleEquipInfoLayer.cellSizeForTable(tableView,idx)
    return item_height, item_width * item_length + 50
end

function RoleEquipInfoLayer.tableCellAtIndex(tableView, idx)
    local self = tableView.logic;
    local cell = tableView:dequeueCell()
    if nil == cell then
        tableView.cells = tableView.cells or {}
        cell = TFTableViewCell:create()
        tableView.cells[cell] = true

        local item_node = TFPanel:create();
        cell:addChild(item_node);
        cell.item_node = item_node;

        for i=1,item_length do
            local m_node = createUIByLuaNew("lua.uiconfig_mango_new.role.EquipItem");
            m_node.panel_empty = TFDirector:getChildByPath(m_node, 'panel_empty');
            m_node.panel_info = TFDirector:getChildByPath(m_node, 'panel_info');

            m_node:setName("m_equip" .. i);
            m_node:setPosition(ccp(item_width * (i - 1) , 0));

            item_node:addChild(m_node);
            item_node.m_node = m_node; 
        end
    end

    for i=1,item_length do
        local index = idx*item_length + i;

        local m_node = TFDirector:getChildByPath(cell.item_node, 'm_equip' .. i);
        local equipItem = self.equipList:objectAt(index);
        if  equipItem then
            m_node.panel_empty:setVisible(true);
            m_node.panel_info:setVisible(true);
            self:loadItemNode(m_node,equipItem,index);
        else
            m_node.panel_empty:setVisible(true);
            m_node.panel_info:setVisible(false);
        end
    end

    return cell
end

function RoleEquipInfoLayer.numberOfCellsInTableView(tableView)
    local self = tableView.logic;
    return math.max(math.ceil(self.equipList:length()/item_length) + 1, 5);
end

--添加玩家节点
function RoleEquipInfoLayer:loadItemNode(item_node,equipItem,index)

    local btn_icon = TFDirector:getChildByPath(item_node, 'btn_node');
    btn_icon.logic = self;
    btn_icon.gmId = equipItem.gmId;

    btn_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCellClickHandle,play_xuanze));

    local img_xuanzhong = TFDirector:getChildByPath(btn_icon, 'img_xuanzhong');
    if self.selectEquipItem and self.selectEquipItem.gmId == equipItem.gmId then
        img_xuanzhong:setVisible(true);
        self.selectEquipItem.img_xuanzhong = img_xuanzhong; 
---------   换地方 by stephen
        self.selectEquipGmId = equipItem.gmId;
        self:openEquipDetail(equipItem);
    else
        img_xuanzhong:setVisible(false);
    end

    local curEquip = self.cardRole:getEquipment():GetEquipByType(self.type)

    local img_icon = TFDirector:getChildByPath(item_node, 'img_skill_icon');
    img_icon:setTexture(equipItem:GetTextrue());

    local img_quality = TFDirector:getChildByPath(item_node, 'btn_equip');
    img_quality:setTextureNormal(GetColorIconByQuality(equipItem.quality));

    EquipmentManager:BindEffectOnEquip(img_quality, equipItem)

    local txt_name = TFDirector:getChildByPath(item_node, 'txt_zhuangbeiming');
    txt_name:setText(equipItem.name);
    -- txt_name:setColor(GetColorByQuality(equipItem.quality));

    local txt_level = TFDirector:getChildByPath(item_node, 'txt_qianghualv');
    txt_level:setText("+" .. equipItem.level);
    
    -- for i=1,5 do
    --    local img_star = TFDirector:getChildByPath(item_node, 'img_xingxing' .. i);
    --     if (equipItem.star >= i) then
    --         img_star:setVisible(true);
    --     else
    --         img_star:setVisible(false);
    --     end
    -- end
    local img_arrow = TFDirector:getChildByPath(item_node, 'img_jiantousheng');
    local img_hasEquip = TFDirector:getChildByPath(item_node, 'img_equiped');
    local txt_equiped_name = TFDirector:getChildByPath(item_node, 'txt_equiped_name');


    img_arrow:setVisible(true);
    img_hasEquip:setVisible(false);

    if (curEquip == nil or equipItem:getpower() > curEquip:getpower()) then
        img_arrow:setTexture("ui_new/roleequip/js_jts_icon.png");
    else
        img_arrow:setTexture("ui_new/roleequip/js_jtx_icon.png");
    end

    if (curEquip ~= nil and  curEquip.gmId == equipItem.gmId) then
        -- img_arrow:setTexture("ui_new/roleequip/js_chuan_icon.png");
        img_arrow:setVisible(false);
        img_hasEquip:setVisible(true);
        local role = CardRoleManager:getRoleById(equipItem.equip)
        -- txt_equiped_name:setText(role.name)
        if role.isMainPlayer then
            txt_equiped_name:setText(MainPlayer.verticalName)
        else
            txt_equiped_name:setText(role.name)
        end
    end

    if (equipItem.equip and equipItem.equip ~= 0) then
        -- img_arrow:setTexture("ui_new/roleequip/js_chuan_icon.png");
        img_arrow:setVisible(false);
        img_hasEquip:setVisible(true);
        local role = CardRoleManager:getRoleById(equipItem.equip)
        -- txt_equiped_name:setText(role.name)
        if role.isMainPlayer then
            txt_equiped_name:setText(MainPlayer.verticalName)
        else
            txt_equiped_name:setText(role.name)
        end
    end

    local img_yuan = TFDirector:getChildByPath(item_node, 'img_yuan');
    if self.cardRole:hasFate( 2 , equipItem.id ) then
        img_yuan:setVisible(true)
    else
        img_yuan:setVisible(false)        
    end

    local img_gem_bg = {}
    local img_gem = {}

    for i=1,EquipmentManager.kGemMergeTargetNum do
        img_gem_bg[i] = TFDirector:getChildByPath(item_node, 'img_baoshicao'..i);
        img_gem[i] = TFDirector:getChildByPath(item_node, 'img_gem'..i);
        local gemId = equipItem:getGemPos(i);
        if (gemId == nil) then
            img_gem_bg[i]:setVisible(false);
        else
            img_gem_bg[i]:setVisible(true);
            img_gem[i]:setTexture(ItemData:objectByID(gemId):GetPath())
        end
    end
    Public:addStarImg(img_icon,equipItem.star)
end

function RoleEquipInfoLayer.onCellClickHandle(sender) 
    local self = sender.logic;

    local equipGmId = sender.gmId;
    local equipItem = EquipmentManager:getEquipByGmid(equipGmId);  

    if not equipItem or self.selectEquipItem == equipItem then
        return
    end

    if self.selectEquipItem and self.selectEquipItem.img_xuanzhong then
        self.selectEquipItem.img_xuanzhong:setVisible(false);
    end

    local img_xuanzhong = TFDirector:getChildByPath(sender, 'img_xuanzhong');
    img_xuanzhong:setVisible(true);
    self.selectEquipItem = equipItem;
    self.selectEquipItem.img_xuanzhong = img_xuanzhong;

    self.selectEquipGmId = equipItem.gmId;

    self:openEquipDetail(equipItem); 
    print("RoleEquipInfoLayer.onCellClickHandle(sender) ")
end

function RoleEquipInfoLayer:openEquipDetail(equipItem) 

    if self.curLeyer then
        self.curLeyer:getParent():removeLayer(self.curLeyer, not self.curLeyer.isCache);
    end
    local curEquip = self.cardRole:getEquipment():GetEquipByType(self.type)

    local layer = nil;
    if (equipItem == curEquip) then
        layer = AlertManager:getLayerFromCacheByName("lua.logic.role.EquipuninstallLayer")
    elseif (curEquip == nil) then
        layer = AlertManager:getLayerFromCacheByName("lua.logic.role.EquipdressLayer")
    else
        layer = AlertManager:getLayerFromCacheByName("lua.logic.role.EquipreplaceLayer")
    end

    if not layer then
        if (equipItem == curEquip) then
            layer = require("lua.logic.role.EquipuninstallLayer"):new();
        elseif (curEquip == nil) then
            layer = require("lua.logic.role.EquipdressLayer"):new();
        else
            layer = require("lua.logic.role.EquipreplaceLayer"):new();
        end
    end
    layer.isfirst = self.isfirst
    layer:loadData(self.cardRole.gmId,equipItem.gmId);
    layer:onShow();
    layer:setZOrder(0);
    self:addLayer(layer);
    self.curLeyer = layer;
end

function RoleEquipInfoLayer:refreshTable()

    if self.curLeyer then
        self.curLeyer:getParent():removeLayer(self.curLeyer, not self.curLeyer.isCache);
        self.curLeyer = nil;
    end

    local function cmpFunPower(equip1, equip2)

        if equip1:getpower() > equip2:getpower() then
            return true;
        elseif equip1:getpower() == equip2:getpower() then
            if equip1.quality > equip2.quality then
                return true;
            elseif equip1.quality == equip2.quality then
                if equip1.gmId > equip2.gmId then
                    return true;
                end
            end 
        end
        return false;
    end

    local function cmpFunQuality(equip1, equip2)
        if equip1.quality > equip2.quality then
            return true;
        elseif equip1.quality == equip2.quality then
            if equip1:getpower() > equip2:getpower() then
                return true;
            elseif equip1:getpower() == equip2:getpower() then
                if equip1.gmId > equip2.gmId then
                    return true;
                end
            end 
        end
        return false;
    end

    --[[--
        返回指定装备类型的装备
        @param type: 装备类型
        @return 指定Key值的元素
    ]]  
    local equipItem = self.cardRole:getEquipmentByIndex(self.type);
     
    if (self.equipList == nil) then
        --[[--
            返回指定装备类型的装备
            @param equipType: 装备类型
            @return 指定Key值的元素,是一个TFArray
        ]]
        self.equipList = EquipmentManager:GetEquipByType(self.type);
        if self.sortType == "power" then
            self.equipList:sort(cmpFunPower);
        else
            self.equipList:sort(cmpFunQuality);
        end

        if self.selectEquipGmId then
            self.selectEquipItem = EquipmentManager:getEquipByGmid(self.selectEquipGmId);
        else
            if equipItem then
                self.selectEquipItem = equipItem;
                self.equipList:removeObject(equipItem);
                self.equipList:pushFront(equipItem);
            else
                for item in self.equipList:iterator() do
                    if item.equip == nil or item.equip == 0 then
                        self.selectEquipItem = item;
                        self.selectEquipGmId = item.gmId;
                        self:openEquipDetail(item);
                        break;
                    end
                end
                -- self.selectEquipItem = self.equipList:objectAt(1);
            end
        end
        self.table_select:reloadData();
        self.table_select:scrollToYTop(0);
    else
        self.equipList = EquipmentManager:GetEquipByType(self.type);
        if self.sortType == "power" then
            self.equipList:sort(cmpFunPower);
        else
            self.equipList:sort(cmpFunQuality);
        end

        if self.selectEquipGmId then
            self.selectEquipItem = EquipmentManager:getEquipByGmid(self.selectEquipGmId);
        else
            if equipItem then
                self.selectEquipItem = equipItem;
                self.equipList:removeObject(equipItem);
                self.equipList:pushFront(equipItem);
            else
                for item in self.equipList:iterator() do
                    if item.equip == nil or item.equip == 0 then
                        self.selectEquipItem = item;
                        break;
                    end
                end
                -- self.selectEquipItem = self.equipList:objectAt(1);
            end
        end

        local tb_pos = self.table_select:getContentOffset();
        self.table_select:reloadData();
        self.table_select:setContentOffset(tb_pos);
    end

    -- self.table_select:setInnerContainerSizeForHeight(self.table_select:getTableViewSize().height);
end   


function RoleEquipInfoLayer.onImproveClickHandle(sender)
     local self = sender.logic;

     if self.selectEquipGmId then
        EquipmentManager:openSmithyLayer(self.selectEquipGmId,self.equipList,self.type,true)
        -- EquipmentManager:OpenOperationLayer(self.selectEquipGmId)
     else
        EquipmentManager:OpenSmithyMainLaye();
     end
end

function RoleEquipInfoLayer:registerEvents(ui)
    self.super.registerEvents(self);

    self.btn_sort.logic = self;
    -- self.btn_sort_pos.logic = self;
    self.btn_sort_power.logic = self;
    self.btn_sort_quality.logic = self;
    self.bg_sort.logic = self;

    self.btn_sort:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShowSortMenuClickHandle));
    -- self.btn_sort_pos:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSortSelectClickHandle));
    self.btn_sort_power:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSortSelectClickHandle),1);
    self.btn_sort_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSortSelectClickHandle),1);
    self.bg_sort:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSortCancelClickHandle));


    self.btn_improve.logic     = self;
    self.btn_improve:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onImproveClickHandle));



    self.EquipUpdateCallBack = function(event)
        self.selectEquipItem = nil;
        self.curLeyer = nil;

        self:refreshUI();
        self:refreshTable();
    end

    TFDirector:addMEGlobalListener(EquipmentManager.EQUIP_OPERATION,  self.EquipUpdateCallBack)
    TFDirector:addMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION ,  self.EquipUpdateCallBack)
end

function RoleEquipInfoLayer:removeEvents()
    self.super.removeEvents(self);
    self.isfirst = true
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIP_OPERATION, self.EquipUpdateCallBack)
    TFDirector:removeMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION, self.EquipUpdateCallBack)
end

function RoleEquipInfoLayer:showOutLayerWhenIsNotEnough()
    local equipItem = self.cardRole:getEquipmentByIndex(self.type);
    if equipItem == nil then
        local equipTotalNum  =  self.equipList:length()
        local equipNum = 0
        for index=1, equipTotalNum do
            equipItem = self.equipList:objectAt(index)
            if equipItem.equip == 0 then
                equipNum = equipNum + 1
                return
            end
        end

        if equipNum < 1 then
            print("没有足够该类型的装备")
            self:showOutLayer()
        end
    end
end

function RoleEquipInfoLayer:showOutLayer()
    if self.curLeyer then
        self.curLeyer:getParent():removeLayer(self.curLeyer, not self.curLeyer.isCache)
    end
    local curEquip = self.cardRole:getEquipment():GetEquipByType(self.type)

    local layer = nil
    layer = AlertManager:getLayerFromCacheByName("lua.logic.role.EquipOutLayer")

    if not layer then
        layer = require("lua.logic.role.EquipOutLayer"):new()
    end
    layer.isfirst = self.isfirst
    layer:loadData(self.type);
    layer:onShow();
    layer:setZOrder(0);
    self:addLayer(layer);
    self.curLeyer = layer;
end

return RoleEquipInfoLayer
