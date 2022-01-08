--[[
******角色归隐*******
]]

local RoleFireLayer = class("RoleFireLayer", BaseLayer)

local RecycleSkillCost = ConstantData:getValue("Recycle.Role.Skill.Percent")
local RecycleExpCost = ConstantData:getValue("Recycle.Role.Rank.Percent")
local RecycleMeridianCost = ConstantData:getValue("Recycle.Role.Meridian.Percent")
local RecycleMeridianBreachCost = ConstantData:getValue("Recycle.Role.Meridian.Breach.Percent")
local RecyclePracticeCost = ConstantData:getValue("Recycle.Role.Practice.Percent")


function RoleFireLayer:ctor(data)
    self.super.ctor(self,data)
    self.selectType = 2;

    self:init("lua.uiconfig_mango_new.shop.RoleFire")
end

function RoleFireLayer:initUI(ui)
	self.super.initUI(self,ui)


    self.panel_menu         = TFDirector:getChildByPath(ui, 'panel_menu')
    self.btn_xiahun         = TFDirector:getChildByPath(ui, 'btn_xiahun')
    self.btn_xiake          = TFDirector:getChildByPath(ui, 'btn_xiake')
    self.btn_help          = TFDirector:getChildByPath(ui, 'btn_help')

    self.panel_list         = TFDirector:getChildByPath(ui, 'panel_list')
    self.txt_showtext         = TFDirector:getChildByPath(ui, 'Label_RoleFire_1')
    --self.txt_showtext:setText("请放入需归隐的侠客/侠魂")
    self.txt_showtext:setText(localizable.roleFireLayer_tips1)
    self.btn_xiahun:setTextureNormal("ui_new/rolebreakthrough/xl_xiahun_btn.png")

    self.btn_add_list = {}
    for i=1,6 do
        self.btn_add_list[i] = TFDirector:getChildByPath(ui, 'btn_add_'..i)

        self.btn_add_list[i].tag = i
        self.btn_add_list[i].logic = self
    end

    self.btn_addAll         = TFDirector:getChildByPath(ui, 'btn_addAll')
    self.btn_addAll.logic = self
    self.btn_guiyin         = TFDirector:getChildByPath(ui, 'btn_guiyin')
    self.btn_guiyin.logic = self

    self:initTableView()

    self.foodNum = 0
    -- self:initDate();
    self:refreshUI();
end

function RoleFireLayer:loadData(gmId)
    self.roleGmId = gmId;
end

function RoleFireLayer:onShow()
    self:refreshUI();
end

function RoleFireLayer:reShow()
    self:refreshUI();
end
function RoleFireLayer:onclear()
    self.dogfood:clear()
    self.catfood:clear()
    self.foodNum = 0
    for i=1,6 do
        self.btn_add_list[i].id = nil
        self.btn_add_list[i].foodType = nil
    end
end
function RoleFireLayer:initDate()
    self.dogfood = self.dogfood or TFArray:new()
    self.catfood = self.catfood or TFArray:new()
    -- self:onclear()
    local function cmpFun( cardRole1, cardRole2 )
        if cardRole1.quality <= cardRole2.quality then
            if cardRole1:getpower() <= cardRole2:getpower() then
                return true
            end
            return true
        else
            return false
        end
    end

    local function soulcmp( soul1, soul2 )
        if soul1.quality <= soul2.quality then
            if soul1.id <= soul2.id then
                return true
            end
            return true
        else
            return false
        end
    end
    self.roleList = CardRoleManager:getNotUsed()
    self.roleList:sort(cmpFun)
    self.soulList = BagManager:getItemByKind(EnumGameItemType.Soul,1)
    -- self.soulList = BagManager:getItemByType(EnumGameItemType.Soul)
    -- for v in self.soulList:iterator() do
    --     if v.kind == 3 then
    --         self.soulList:removeObject(v)
    --     end
    -- end
    for v in self.roleList:iterator() do
        if v:getIsMainPlayer() then
            self.roleList:removeObject(v)
        end
    end
    self.soulList:sort(soulcmp)

end
function RoleFireLayer:refreshUI()
    self:initDate()
    for i=1,6 do
        self:setAddBtn( i , self.btn_add_list[i].id , self.btn_add_list[i].foodType )
    end
    self.tableView:reloadData();
    self.tableView:scrollToYTop(0);

end

function RoleFireLayer:removeUI()
    self.super.removeUI(self)
end

function RoleFireLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function RoleFireLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_xiahun.logic       = self
    self.btn_xiake.logic        = self

    self.btn_xiahun:addMEListener(TFWIDGET_CLICK, audioClickfun(self.XiaHunClickHandle))
    self.btn_xiake:addMEListener(TFWIDGET_CLICK, audioClickfun(self.XiaKeClickHandle))
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnHelpClickHandle))

    self.btn_addAll:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnAddAllClickHandle))
    self.btn_guiyin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnGuiYinClickHandle))

    for i=1,6 do
        self.btn_add_list[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnAddClickHandle))
    end
    self.roleHermitResultCallBack = function (event)
        self.dogfood:clear()
        self.catfood:clear()
        self.foodNum = 0
        for i=1,6 do
            self.btn_add_list[i].id = nil
            self.btn_add_list[i].foodType = nil
        end
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_HERMIT_RESULT,self.roleHermitResultCallBack)

end

function RoleFireLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_HERMIT_RESULT,self.roleHermitResultCallBack)
    self.roleHermitResultCallBack = nil
    self.dogfood:clear()
    self.catfood:clear()
    self.foodNum = 0
    for i=1,6 do
        self.btn_add_list[i].id = nil
        self.btn_add_list[i].foodType = nil
    end
end

function RoleFireLayer:HaveSelectFood()
    if self.dogfood:length() == 0 and self.catfood:length() == 0 then
        return false
    else
        return true
    end
end

function RoleFireLayer.btnGuiYinClickHandle(sender)
    local self = sender.logic
    if self:HaveSelectFood() ==false then
        --toastMessage("请选取归隐的侠客")
        toastMessage(localizable.roleFireLayer_tips5)
        return
    end
    local calculateRewardList ,hasGoodRole = self:calculateReward()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.hermit.HermitSure",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadData(calculateRewardList);
    if hasGoodRole then
        --layer:setTitle("本次归隐包含高品阶侠客或侠魂，将获得：",ccc3(255,0,0))
        layer:setTitle(localizable.roleFireLayer_tips2,ccc3(255,0,0))
    else
        --layer:setTitle("本次归隐将获得：",ccc3(0,0,0))
        layer:setTitle(localizable.roleFireLayer_tips3,ccc3(0,0,0))
    end
    layer:setBtnHandle(function ()
        self:hermitSend()
    end);
    AlertManager:show();
end
function RoleFireLayer:hermitSend()
    local dogfoodlist = {}
    local catfoodlist = {}
    local temp = 1
    for v in self.dogfood:iterator() do
        dogfoodlist[temp] = v
        temp = temp + 1
    end
    temp = 1
    for v in self.catfood:iterator() do
        local tbl = {
            v.id,
            v.num,
        }
        catfoodlist[temp] = tbl
        temp = temp + 1
    end
    CardRoleManager:roleHermit(dogfoodlist , catfoodlist )
end

function RoleFireLayer.btnAddAllClickHandle(sender)
    local self = sender.logic
    local index = 1
    if self.selectType == 1 then
        self:addAllRole()
    else
        self:addAllSoul()
    end
end

function RoleFireLayer:addAllRole()
    if self.foodNum >= 6 then
        return
    end
    local index = 1
    while(self.foodNum < 6) do
        if index <= self.roleList:length() then
            local dogfood = self.roleList:objectAt(index)
            if self.dogfood:indexOf(dogfood.gmId) == -1 and dogfood.quality < 4 then
                self.dogfood:pushBack(dogfood.gmId)
                self.foodNum = self.foodNum + 1
                self:setAddBtn(self.foodNum ,dogfood.gmId,1)
                TFDirector:dispatchGlobalEventWith("RoleFireLayer.DelDogFoodCall",{ id = dogfood.gmId, add = true})
            end
            index = index + 1
        else
            return
        end
    end
end

function RoleFireLayer:addAllSoul()
    if self.foodNum >= 6 then
        return
    end
    local index = 1
    while(self.foodNum < 6) do
        if index <= self.soulList:length() then
            local catfood = self.soulList:objectAt(index)
            local catSoul = self:findInCatfood(catfood.id)
            if catSoul == nil and catfood.quality < 4 and self:isRoleUseBySoul(catfood) == false then
                soulInfo = {}
                soulInfo.id  = catfood.id
                soulInfo.num = catfood.num
                self.catfood:pushBack(soulInfo)
                self.foodNum = self.foodNum + 1
                self:setAddBtn(self.foodNum ,catfood.id,2)
                TFDirector:dispatchGlobalEventWith("RoleFireLayer.DelDogFoodCall",{ id = catfood.id, add = true})
            end
            index = index + 1
        else
            return
        end
    end
end

function RoleFireLayer:isRoleUseBySoul( soul )
    local item = ItemData:objectByID(soul.id)
    if item == nil then
        print("该卡牌不存在 soul.id =="..soul.id)
        return
    end
    local role = RoleData:objectByID(item.usable)
    if role == nil and item.id ~= 2000  then
        print("无法找到该角色  item.id =="..item.id)
        return false
    end
    if item.id == 2000 then
        role = RoleData:objectByID(MainPlayer:getProfession())
    end
    local roleInfo = CardRoleManager:getRoleById(role.id)
    if roleInfo and roleInfo.pos ~= nil and roleInfo.pos ~= 0 then
        return true
    end
    return false
end


function RoleFireLayer.btnAddClickHandle(sender)
    local self = sender.logic
    if self.btn_add_list[sender.tag].id == nil then
        return
    end
    if self.btn_add_list[sender.tag].foodType == 1 then
        self.dogfood:removeObject(self.btn_add_list[sender.tag].id)
    else
        local soulInfo = self:findInCatfood(self.btn_add_list[sender.tag].id)
        self.catfood:removeObject(soulInfo)
    end
    if self.selectType == self.btn_add_list[sender.tag].foodType  then
        TFDirector:dispatchGlobalEventWith("RoleFireLayer.DelDogFoodCall",{ id = self.btn_add_list[sender.tag].id, add = false})
    end
    self:setAddBtnDelByIndex(sender.tag)
end


function RoleFireLayer.XiaHunClickHandle(sender)
    local self = sender.logic
    self.selectType = 2
    self.tableView:reloadData()
    self.tableView:scrollToYTop(0);
    self.btn_xiahun:setTextureNormal("ui_new/rolebreakthrough/xl_xiahun_btn.png")
    self.btn_xiake:setTextureNormal("ui_new/rolebreakthrough/xl_xiake1_btn.png")
end
function RoleFireLayer.XiaKeClickHandle(sender)
    local self = sender.logic
    self.selectType = 1
    self.tableView:reloadData()
    self.tableView:scrollToYTop(0);
    self.btn_xiahun:setTextureNormal("ui_new/rolebreakthrough/xl_xiahun1_btn.png")
    self.btn_xiake:setTextureNormal("ui_new/rolebreakthrough/xl_xiake_btn.png")
end

function RoleFireLayer.btnHelpClickHandle(sender)
    AlertManager:addLayerByFile("lua.logic.hermit.HermitHelp");
    AlertManager:show();
end


function RoleFireLayer.cellSizeForTable(table,idx)
    return 160,430
end

function RoleFireLayer.tableCellAtIndex(table, idx)

    local numInCell = 3
    local cell = table:dequeueCell()
    local self = table.logic
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,numInCell do
            local equip_panel = require('lua.logic.hermit.EatRoleIcon'):new("RoleFireLayer")
            equip_panel.panel_empty = TFDirector:getChildByPath(equip_panel, 'panel_empty');
            equip_panel.panel_info = TFDirector:getChildByPath(equip_panel, 'panel_info');

            equip_panel:setPosition(ccp(10+130*(i-1),0))
            equip_panel:setLogic( self )
            cell:addChild(equip_panel)
            cell.equip_panel = cell.equip_panel or {}
            cell.equip_panel[i] = equip_panel
        end
    end
    if self.selectType == 1 then
        for i=1,numInCell do
            if (idx * numInCell + i) <= self.roleList:length() then
                local role = self.roleList:objectAt(idx * numInCell + i)
                cell.equip_panel[i].panel_empty:setVisible(true);
                cell.equip_panel[i].panel_info:setVisible(true);
                if self.dogfood:indexOf(role.gmId) == -1 then
                    cell.equip_panel[i]:setRoleGmId( role.gmId , 0)
                else
                    cell.equip_panel[i]:setRoleGmId( role.gmId , 1)
                end
            else
                cell.equip_panel[i].panel_empty:setVisible(true);
                cell.equip_panel[i].panel_info:setVisible(false);
            end
        end
    else
        for i=1,numInCell do
            if (idx * numInCell + i) <= self.soulList:length() then
                local soul = self.soulList:objectAt(idx * numInCell + i)
                cell.equip_panel[i].panel_empty:setVisible(true);
                cell.equip_panel[i].panel_info:setVisible(true);

                local catSoul = self:findInCatfood(soul.id)
                if catSoul then
                    cell.equip_panel[i]:setSoulId( soul.id ,catSoul.num)
                else
                    cell.equip_panel[i]:setSoulId( soul.id ,0)
                end
            else
                cell.equip_panel[i].panel_empty:setVisible(true);
                cell.equip_panel[i].panel_info:setVisible(false);
            end
        end
    end
    return cell
end

function RoleFireLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local num = 0
    if self.selectType == 1 then
        num = math.max(math.ceil(self.roleList:length()/3),2);
    else
        num = math.max(math.ceil(self.soulList:length()/3),2);
    end
    return num
end



function RoleFireLayer:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    --tableView:setPosition(self.panel_list:getPosition())
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RoleFireLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RoleFireLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleFireLayer.numberOfCellsInTableView)
    Public:bindScrollFun(tableView);
    self.panel_list:addChild(tableView,2)
end



function RoleFireLayer:addDogFood( gmid , icon)
    if self.foodNum >= 6 then
        --toastMessage("一次只能归隐6人")
        toastMessage(localizable.roleFireLayer_tips4)
        return
    end
    local role = CardRoleManager:getRoleByGmid(gmid)
    if role == nil then
        print("该角色不存在 gmId =="..gmid)
        return
    end

    --quanhuan add 2015/11/30
    --策划要求关闭 2015/12/2
    -- if AssistFightManager:isInAssistAll( gmid ) then
    --     CommonManager:showOperateSureLayer(
    --             function()                   
    --                 icon:changeNum(1)
    --                 self.dogfood:pushBack(gmid)
    --                 self.foodNum = self.foodNum + 1
    --                 self:setAddBtn(self.foodNum ,gmid,1)
    --                 return true;
    --             end,
    --             function()
    --                 AlertManager:close()
    --             end,
    --             {
    --             title = "提示" ,
    --             msg = "此为助战侠客，是否确认归隐？",
    --             }
    --         )        
    --     return
    -- end

    icon:changeNum(1)
    self.dogfood:pushBack(gmid)
    self.foodNum = self.foodNum + 1
    self:setAddBtn(self.foodNum ,gmid,1)
    return true;
end

function RoleFireLayer:delDogFood( gmid , icon)
     if self.foodNum <= 0 then
        --toastMessage("没有可删除的侠魂")
        toastMessage(localizable.roleFireLayer_not_delete)
        return
    end
    local role = CardRoleManager:getRoleByGmid(gmid)
    if role == nil then
        print("该角色不存在 gmId =="..gmid)
        return
    end
    icon:changeNum(0)

    self.dogfood:removeObject(gmid)
    -- self.foodNum = self.foodNum - 1
    self:setAddBtnDel( gmid , 1 )
end

function RoleFireLayer:addCatFood( id , icon, num)
    local soulInfo = self:findInCatfood(id)
    if self.foodNum >= 6 and soulInfo == nil then
        --toastMessage("一次只能归隐6人")
        toastMessage(localizable.roleFireLayer_tips4)
        return
    end
    local bagItem = BagManager:getItemById(id)
    if bagItem == nil then
        print("该道具不存在背包 id =="..id)
        return
    end

    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end

    local index = 1
    if soulInfo == nil then
        soulInfo = {}
        soulInfo.id  = id
        soulInfo.num = bagItem.num
        self.catfood:pushBack(soulInfo)
        self.foodNum = self.foodNum + 1
        index = self.foodNum
    else
        soulInfo.num = math.min(bagItem.num ,soulInfo.num + 1)
        for i=1,6 do
            if self.btn_add_list[i].id == id then
                index = i
            end
        end
    end

    icon:changeNum(soulInfo.num)
    self:setAddBtn(index ,id,2)

    return false;
end


function RoleFireLayer:delCatFood( id , icon,num)
    if self.foodNum <= 0 then
        --toastMessage("没有可删除的侠魂")
        toastMessage(localizable.roleFireLayer_not_delete)
        return
    end
    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end


    local soulInfo = self:findInCatfood(id)
    soulInfo.num = soulInfo.num - 1
    icon:changeNum(soulInfo.num)
    if soulInfo.num == 0 then
        self.catfood:removeObject(soulInfo)
        self:setAddBtnDel( id , 2 )
        return
    end
    for i=1,#self.btn_add_list do
        if self.btn_add_list[i].id == id then
            self:setAddBtn( i , id , 2 )
            return
        end
    end
end

function RoleFireLayer:findInCatfood( id )
    for v in self.catfood:iterator() do
        if v.id == id then
            return v
        end
    end
end

function RoleFireLayer:setAddBtn( index , id , foodType )
    local img_quality = TFDirector:getChildByPath(self.btn_add_list[index], 'img_quality')
    local img_icon = TFDirector:getChildByPath(self.btn_add_list[index], 'img_icon')
    local txt_num = TFDirector:getChildByPath(self.btn_add_list[index], 'txt_num')
    if id == nil then
        self.btn_add_list[index].id = nil
        self.btn_add_list[index].foodType = nil
        img_icon:setVisible(false)
        img_quality:setVisible(false)
        txt_num:setVisible(false)
        return
    end
    self.btn_add_list[index].id = id
    self.btn_add_list[index].foodType = foodType

    img_icon:setVisible(true)
    img_quality:setVisible(true)
    if foodType == 1 then
        local role = CardRoleManager:getRoleByGmid(id)
        if role == nil then
            print("无法找到该角色, gmid == "..id)
            return
        end
        img_icon:setTexture(role:getIconPath())
        img_quality:setTexture(GetColorIconByQuality( role.quality ))
        txt_num:setVisible(false)
        Public:addPieceImg(img_icon,rewardItem,false);
    elseif foodType == 2 then
        local bagItem = BagManager:getItemById(id)
        if bagItem == nil then
            print("该道具不存在背包 id =="..id)
            return
        end
        local catfood = self:findInCatfood(id)
        if catfood == nil then
            print("该道具不存在猫粮队列 id =="..id)
            return
        end
        local item = ItemData:objectByID(id)
        if item == nil then
            print("该卡牌不存在 id =="..id)
            return
        end

        local role = RoleData:objectByID(item.usable)
        if role == nil and item.id ~= 2000 then
            print("无法找到该角色  id =="..id)
            return
        end
        if role == nil then
            role = RoleData:objectByID(MainPlayer:getProfession())
        end

        img_icon:setTexture(role:getIconPath())
        img_quality:setTexture(GetColorIconByQuality( role.quality ))
        local rewardItem = {itemid = id}

        if item.kind ~= 3 then
            Public:addPieceImg(img_icon,rewardItem,true);
        end
        txt_num:setVisible(true)
        txt_num:setText(catfood.num.."/"..bagItem.num)
    end
end


function RoleFireLayer:setAddBtnDel( id , foodType )
    if self.foodNum <= 0 then
        --toastMessage("没有侠客可以删除")
        toastMessage(localizable.roleFireLayer_not_delete)
        return
    end

    local delBegin = false
    for i=1,self.foodNum do
        if self.btn_add_list[i].id == id and self.btn_add_list[i].foodType == foodType  then
            delBegin = true
        end
        if delBegin == true then
            if i < self.foodNum then
                self:setAddBtn( i , self.btn_add_list[i+1].id , self.btn_add_list[i+1].foodType )
            else
                self:setAddBtn( i , nil , nil )
            end
        end
    end
    self.foodNum = self.foodNum - 1
end
function RoleFireLayer:setAddBtnDelByIndex(index)

    if self.btn_add_list[index].id == nil then
        return
    end
    for i=index,self.foodNum do
        if i < self.foodNum then
            self:setAddBtn( i , self.btn_add_list[i+1].id , self.btn_add_list[i+1].foodType )
        else
            self:setAddBtn( i , nil , nil )
        end
    end
    self.foodNum = self.foodNum - 1
end

function RoleFireLayer:expExChangeItem( exp )
    local exp_num = exp
    local rewardList = {}
    local itemList = ItemData:GetItemByType( 7 ,3)
    local function itemExpcmp( item1, item2 )
        if item1.provide_exp < item2.provide_exp then
            return false
        else
            return true
        end
    end
    itemList:sort(itemExpcmp)
    for v in itemList:iterator() do
        local provide_exp = v.provide_exp
        local num = math.floor(exp_num/provide_exp)
        exp_num = exp_num - num*provide_exp
        if exp_num >0 and v.quality == 1 then
            num = num + 1
        end
        if num ~= 0 then
            local reward = {}
            reward.id = v.id
            reward.num = num
            rewardList[#rewardList+1] = reward
        end
    end
    return rewardList
end

function RoleFireLayer:calculateReward()
    local xiayi = 0
    local exp = 0
    local coin = 0
    local vesselbreach = 0
    local martialRewardList = {}
    local genuine_qi = 0
    local hasGoodRole = false
    local boom = 0
    for v in self.dogfood:iterator() do
        local cardRole = CardRoleManager:getRoleByGmid( v )
        if cardRole == nil then
            print("该角色不存在 gmId =="..v)
        else
            if cardRole.quality >= 4 then
                hasGoodRole = true
            end
            local soul_card_id = cardRole.soul_card_id
            xiayi = xiayi + GetXiaYiBySoulIdAndNum( soul_card_id , cardRole:getChangSoulNum() )
            exp = exp + cardRole:getTotalExp()
            genuine_qi = genuine_qi + math.ceil(cardRole:getMeridianAllCost()*RecycleMeridianCost/100)
            coin = coin + math.ceil(cardRole:getSpellAllCost()*RecycleSkillCost/100)
            vesselbreach = vesselbreach + math.ceil(cardRole:getMeridianBreachAllCost()*RecycleMeridianBreachCost/100)
            local factionCost,factionTbl = cardRole:getFactionPracticeCost()
            boom = boom + math.ceil(factionCost*RecyclePracticeCost/100)

            for k,v in pairs(factionTbl) do
                martialRewardList[k] = martialRewardList[k] or 0
                martialRewardList[k] = martialRewardList[k] + v
            end

            local martialReward = MartialLevelExchangeData:getRewardListByLevel(cardRole.martialLevel)
            for k,v in pairs(martialReward) do
                martialRewardList[k] = martialRewardList[k] or 0
                martialRewardList[k] = martialRewardList[k] + v
            end
        end
    end
    exp =math.ceil(exp*RecycleExpCost/100)
    for v in self.catfood:iterator() do
        local item = ItemData:objectByID(v.id)
        if item and item.quality >=  4 then
            hasGoodRole = true
        end
        xiayi = xiayi + GetXiaYiBySoulIdAndNum(  v.id, v.num)
    end
    local expItemList = self:expExChangeItem(exp)
    local calculateRewardList = TFArray:new();

    if xiayi > 0 then
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.XIAYI
        rewardInfo.number = xiayi
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
    if coin > 0 then
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.COIN
        rewardInfo.number = coin
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
    if genuine_qi > 0 then
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.GENUINE_QI
        rewardInfo.number = genuine_qi
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
    if vesselbreach > 0 then
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.VESSELBREACH
        rewardInfo.number = vesselbreach
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
    if boom > 0 then
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.FACTION_GX
        rewardInfo.number = boom
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
    for k,v in pairs(expItemList) do
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.GOODS
        rewardInfo.itemId = v.id
        rewardInfo.number = v.num
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
    for k,v in pairs(martialRewardList) do
        local rewardInfo = {}
        rewardInfo.type = EnumDropType.GOODS
        rewardInfo.itemId = k
        rewardInfo.number = v
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end
    return calculateRewardList ,hasGoodRole
end

return RoleFireLayer
