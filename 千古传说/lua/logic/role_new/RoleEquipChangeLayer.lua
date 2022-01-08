--[[
******角色装备互换界面*******
	-- by ChiKui Peng
	-- 2016/4/20
]]

local RoleEquipChangeLayer = class("RoleEquipChangeLayer", BaseLayer)

function RoleEquipChangeLayer:ctor()
    self.super.ctor(self)
    self.roleId = {}
    self:init("lua.uiconfig_mango_new.role_new.EquipChange")
end

function RoleEquipChangeLayer:initUI(ui)
	self.super.initUI(self,ui)
    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.EquipChange,{HeadResType.COIN,HeadResType.SYCEE})
    self.EquipList = {{},{}}
    for i=1,2 do
        local panel = TFDirector:getChildByPath(ui, 'panel_'..i)
        for j=1,6 do
            self.EquipList[i][j] = {}
            local item_node = TFDirector:getChildByPath(panel, 'equip_'..j)
            self.EquipList[i][j].root_Node = item_node
            self.EquipList[i][j].img_icon = TFDirector:getChildByPath(item_node, 'img_icon')
            self.EquipList[i][j].img_quality = TFDirector:getChildByPath(item_node, 'img_quality')
            self.EquipList[i][j].txt_level = TFDirector:getChildByPath(item_node, 'txt_intensify_lv')
            if j < 6 then 
                self.EquipList[i][j].img_gem_bg = {}
                self.EquipList[i][j].img_gem = {}
                for k=1,EquipmentManager.kGemMergeTargetNum do
                    self.EquipList[i][j].img_gem_bg[k] = TFDirector:getChildByPath(item_node, 'img_gembg'..k)
                    self.EquipList[i][j].img_gem[k] = TFDirector:getChildByPath(item_node, 'img_gem'..k)
                end
            end

            --显示空白网格逻辑添加
            self.EquipList[i][j].panel_empty = TFDirector:getChildByPath(item_node, 'Panel_empty')
            self.EquipList[i][j].panel_info = TFDirector:getChildByPath(item_node, 'panel_info')
        end
        self.EquipList[i].txt_power = TFDirector:getChildByPath(panel, 'txt_power_details')
    end
    self.RoleList = {{},{}}
    for i=1,2 do
        local panel = TFDirector:getChildByPath(ui, 'role_'..i)
        self.RoleList[i].panel = panel
        self.RoleList[i].img_bg1 = TFDirector:getChildByPath(panel, 'bg_wupin')
        self.RoleList[i].btn_Role = TFDirector:getChildByPath(panel, 'btn_wupin')
        self.RoleList[i].img_tag = TFDirector:getChildByPath(panel, 'img_arrow')
        self.RoleList[i].role_bg = TFDirector:getChildByPath(panel, 'btn_icon')
        self.RoleList[i].img_role = TFDirector:getChildByPath(panel, 'img_role')
    end
    self.Path_Img = {
        {[1]="ui_new/Zhuzhan/bg_zhuzhan2.png",[2]="ui_new/smithy/btn_xiake1.png",tagvisi = false},
        {[1]="ui_new/Zhuzhan/bg_zhuzhan3.png",[2]="ui_new/smithy/btn_xiake.png",tagvisi = true}
    } 
    self.btn_chuancheng = TFDirector:getChildByPath(ui, 'btn_chuancheng')
    self.btn_bangzhu = TFDirector:getChildByPath(ui, 'btn_bangzhu')
    self:refreshUI()
end

function RoleEquipChangeLayer:removeUI()
    self.super.removeUI(self)
end

function RoleEquipChangeLayer:SetRoleBtnState(index,state)
    self.RoleList[index].img_bg1:setTexture(self.Path_Img[state][1])
    self.RoleList[index].btn_Role:setTextureNormal(self.Path_Img[state][2])
    self.RoleList[index].img_tag:setVisible(self.Path_Img[state].tagvisi)
end

function RoleEquipChangeLayer:refreshRoleInfo(index)
    if index == nil then
        return
    end
    local cardRole = nil
    if self.roleId[index] then
        cardRole = CardRoleManager:getRoleById(self.roleId[index])
        if cardRole then
            self:SetRoleBtnState(index,2)
            self.RoleList[index].role_bg:setVisible(true)
            self.RoleList[index].role_bg:setTexture(GetColorIconByQuality(cardRole.quality))
            self.RoleList[index].img_role:setTexture(cardRole:getIconPath())
            self.EquipList[index].txt_power:setText(cardRole.power)
        end
    end
    if self.roleId[index] == nil or cardRole == nil then
        self:SetRoleBtnState(index,1)
        self.RoleList[index].role_bg:setVisible(false)
        self.EquipList[index].txt_power:setText("")
    end
    for i=1,5 do
        local equipInfo = nil
        if cardRole then
            equipInfo = cardRole:getEquipment():GetEquipByType(i)
        end
        self:loadEquipNode(self.EquipList[index][i],equipInfo)
    end
    local skyBook = nil
    if cardRole then
        skyBook = cardRole:getSkyBook()
    end
    self:loadSkyBookNode(self.EquipList[index][6],skyBook)
end

function RoleEquipChangeLayer:_addEffectNode(node)
    self.isEffect = true
    local effect = node:getChildByTag(100)
    if effect == nil then
        local resPath = "effect/book_get_effect.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        effect = TFArmature:create("book_get_effect_anim")
        local contentSize = node:getContentSize()
        node:addChild(effect, 100,10)
        effect:setPosition(ccp(contentSize.width*0.5, contentSize.height*0.5))
        effect:setTag(100)

        effect:addMEListener(TFARMATURE_COMPLETE,function()
            effect:removeFromParentAndCleanup(true)
            if self.isEffect == true then
                self.isEffect = false
                --self:refreshUI()
                
            end
        end)
    end

    effect:playByIndex(0, -1, -1, 0)
end

function RoleEquipChangeLayer:addEffect()
    for i=1,2 do
        if self.roleId[i] then
            local cardRole = CardRoleManager:getRoleById(self.roleId[i])
            if cardRole then
                for j=1,5 do
                    local equipInfo = cardRole:getEquipment():GetEquipByType(j)
                    if equipInfo then
                        self:_addEffectNode(self.EquipList[i][j].root_Node)
                    end
                end
                local skyBook = cardRole:getSkyBook()
                if skyBook then
                    self:_addEffectNode(self.EquipList[i][6].root_Node)
                end
            end
        end
    end
end

function RoleEquipChangeLayer:refreshUI()
    self:refreshRoleInfo(1)
    self:refreshRoleInfo(2)
end

function RoleEquipChangeLayer:registerEvents()
	self.super.registerEvents(self)
    if self.generalHead then
        self.generalHead:registerEvents()
    end
    for i=1,2 do
        self.RoleList[i].btn_Role.logic = self
        self.RoleList[i].btn_Role.idx = i
        self.RoleList[i].btn_Role:addMEListener(TFWIDGET_CLICK,audioClickfun(self.OnRoleSelectClick))
    end
    self.btn_chuancheng.logic = self
    self.btn_chuancheng:addMEListener(TFWIDGET_CLICK,audioClickfun(self.OnChangeEquip))
    self.btn_bangzhu:addMEListener(TFWIDGET_CLICK,audioClickfun(self.OnRuleClick))
    self.ChangeEquipCallBack = function(event)
        if event.data[1].result == 0 then
            self:addEffect()
            self:refreshUI()
            toastMessage(localizable.roleEquipChangeLayer_txt1)
        end
    end
    TFDirector:addMEGlobalListener(XiaKeExchangeManager.changeEquip,self.ChangeEquipCallBack)
end

function RoleEquipChangeLayer:removeEvents()
    self.super.removeEvents(self)
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    TFDirector:removeMEGlobalListener(XiaKeExchangeManager.changeEquip,self.ChangeEquipCallBack)
end

function RoleEquipChangeLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
    self:refreshUI()
end

function RoleEquipChangeLayer:dispose()
    self.super.dispose(self)
     if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end

function RoleEquipChangeLayer.sortFunc( cardRole1, cardRole2 )
    if cardRole1.quality < cardRole2.quality then
        return false
    elseif cardRole1.quality == cardRole2.quality and
           cardRole1:getpower() <= cardRole2:getpower() then
        return false
    end
    return true
end

function RoleEquipChangeLayer:getRoleList()
    local role_list = TFArray:new()
    for card in CardRoleManager.cardRoleList:iterator() do
        if card.id ~= self.roleId[1] and card.id ~= self.roleId[2] then
            role_list:pushBack(card)
        end
    end
    role_list:sort(self.sortFunc)
    return role_list
end

function RoleEquipChangeLayer.OnRoleSelectClick(sender)
    local self = sender.logic
    local index = sender.idx
    self:SetRoleBtnState(index,2)
    local tipsTxt = localizable.roleEquipChangeLayer_txt
    local layer  = require("lua.logic.factionPractice.PracticeRoleSelect"):new(index-1)
    AlertManager:addLayer(layer,AlertManager.BLOCK,AlertManager.TWEEN_NONE)
    self.clickCallBack = function (cardRole)
        layer:moveOut()
        self.roleId[index] = cardRole.id
        play_buzhenluoxia()
    end
    layer:initDate(self:getRoleList(),tipsTxt,self.clickCallBack)
    AlertManager:show()
end

function RoleEquipChangeLayer:loadEquipNode(node_item,equipItem)

    if not node_item then
        return
    end

    if equipItem then
        node_item.panel_empty:setVisible(true);
        node_item.panel_info:setVisible(true);
    else
        node_item.panel_empty:setVisible(true);
        node_item.panel_info:setVisible(false);
        return
    end

    node_item.img_icon:setTexture(equipItem:GetTextrue());
    
    node_item.img_quality:setTexture(GetColorIconByQuality(equipItem.quality));

    EquipmentManager:BindEffectOnEquip(node_item.img_quality, equipItem)
    
    node_item.txt_level:setText("+" .. equipItem.level);

    for i=1,EquipmentManager.kGemMergeTargetNum do
        local gemId = equipItem:getGemPos(i);
        if (gemId == nil) then
            node_item.img_gem_bg[i]:setVisible(false);
        else
            node_item.img_gem_bg[i]:setVisible(true);
            node_item.img_gem[i]:setTexture(ItemData:objectByID(gemId):GetPath())
        end
    end
    Public:addStarImg(node_item.img_icon,equipItem.star)
end

function RoleEquipChangeLayer:loadSkyBookNode(node_item,equipItem)

    if not node_item then
        return
    end

    if equipItem then
        node_item.panel_empty:setVisible(true);
        node_item.panel_info:setVisible(true);
    else
        node_item.panel_empty:setVisible(true);
        node_item.panel_info:setVisible(false);
        return
    end

    node_item.img_icon:setTexture(equipItem:GetTextrue());

    node_item.img_quality:setTexture(GetColorIconByQuality(equipItem.quality));

    if equipItem.level == nil or equipItem.level == 0 then
        node_item.txt_level:setVisible(false)
    else
        node_item.txt_level:setText(stringUtils.format(localizable.common_chong, EnumSkyBookLevelType[equipItem.level]))
        node_item.txt_level:setVisible(true)
    end

    Public:addStarImg(node_item.img_icon, equipItem.tupoLevel)
end

function RoleEquipChangeLayer.OnChangeEquip( sender )
    local self = sender.logic
    if self.isEffect == true then
        return
    end
    if self.roleId[1] == nil or self.roleId[2] == nil then
        toastMessage(localizable.roleEquipChangeLayer_txt)
        return
    end
    local cardRole1 = CardRoleManager:getRoleById(self.roleId[1])
    if cardRole1 == nil then
        toastMessage(localizable.roleEquipChangeLayer_txt)
        return
    end
    local cardRole2 = CardRoleManager:getRoleById(self.roleId[2])
    if cardRole2 == nil then
        toastMessage(localizable.roleEquipChangeLayer_txt)
        return
    end
    XiaKeExchangeManager:requestChangeEquip(cardRole1.gmId,cardRole2.gmId)
end

function RoleEquipChangeLayer.OnRuleClick(sender)
    CommonManager:showRuleLyaer('kuaisuhuanzhuang')
end

return RoleEquipChangeLayer
