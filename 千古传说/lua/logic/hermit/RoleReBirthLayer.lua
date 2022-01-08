--[[
******角色归隐*******
]]

local RoleReBirthLayer = class("RoleReBirthLayer", BaseLayer)

local RecycleSkillCost = ConstantData:getValue("Recycle.Role.Skill.Percent")
local RecycleExpCost = ConstantData:getValue("Recycle.Role.Rank.Percent")
local RecycleMeridianCost = ConstantData:getValue("Recycle.Role.Meridian.Percent")
local RecycleMeridianBreachCost = ConstantData:getValue("Recycle.Role.Meridian.Breach.Percent")
local RecyclePracticeCost = ConstantData:getValue("Recycle.Role.Practice.Percent")


function RoleReBirthLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.shop.RoleReborn")
end

function RoleReBirthLayer:initUI(ui)
	self.super.initUI(self,ui)


    self.panel_menu         = TFDirector:getChildByPath(ui, 'panel_menu')
    self.btn_xiake          = TFDirector:getChildByPath(ui, 'btn_xiake')
    self.btn_help         = TFDirector:getChildByPath(ui, 'btn_help')

    self.panel_list         = TFDirector:getChildByPath(ui, 'panel_list')

    self.btn_xiake:setTextureNormal("ui_new/rolebreakthrough/xl_xiake_btn.png")

    self.btn_add = TFDirector:getChildByPath(ui, 'btn_add')
    self.btn_add.tag = i
    self.btn_add.logic = self

    self.btn_rebirth         = TFDirector:getChildByPath(ui, 'Button_RoleReborn_1')
    self.btn_rebirth.logic = self


    
    self.dogfood = nil
    self:refreshUI();
    
end

function RoleReBirthLayer:onclear()
    self.dogfood = nil
end
function RoleReBirthLayer:onShow()
    self:refreshUI();
end

function RoleReBirthLayer:reShow()
    self:refreshUI();
end


function RoleReBirthLayer:refreshUI()
    
    local function cmpFun( cardRole1, cardRole2 )
        if cardRole1.quality <= cardRole2.quality then
            if cardRole1:getpower() <= cardRole2:getpower() then
                return false
            end
            return true
        else
            return true
        end
    end


    self.roleList = CardRoleManager:getNotUsedAndNotDevelop()
    self.roleList:sort(cmpFun)

    -- self.dogfood = nil
    if self.tableView == nil then
        self:initTableView()
    end
    self.tableView:reloadData();
    self.tableView:scrollToYTop(0);

    self:setAddBtn( self.dogfood  )

end

function RoleReBirthLayer:removeUI()
    self.super.removeUI(self)
end

function RoleReBirthLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function RoleReBirthLayer:registerEvents()
    self.super.registerEvents(self)


    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnHelpClickHandle))
    self.btn_rebirth:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnRebirthClickHandle))

    self.btn_add:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnAddClickHandle))

    self.roleRebirthResultCallBack = function (event)
        self.dogfood = nil
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_REBIRTH_RESULT,self.roleRebirthResultCallBack)

end

function RoleReBirthLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_REBIRTH_RESULT,self.roleRebirthResultCallBack)
    self.roleRebirthResultCallBack = nil
end

function RoleReBirthLayer:HaveSelectFood()
    if self.dogfood == nil then
        return false
    else
        return true
    end
end

function RoleReBirthLayer.btnRebirthClickHandle(sender)
    local self = sender.logic
    if self:HaveSelectFood() ==false then
        --toastMessage("请选取重生的侠客")
        toastMessage(localizable.roleReBirthLayer_getplayer)
        return
    end
    local calculateRewardList ,hasGoodRole = self:calculateReward()
    if calculateRewardList == nil then
        return
    end
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.hermit.HermitSure",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadData(calculateRewardList);
    if hasGoodRole then
        --layer:setTitle("本次重生包含高品阶侠客，将获得",ccc3(255,0,0))
        layer:setTitle(localizable.roleReBirthLayer_award1,ccc3(255,0,0))
    else
        --layer:setTitle("本次侠客重生将获得：")
        layer:setTitle(localizable.roleReBirthLayer_award2)
    end
    layer:setBtnHandle(function ()
        CardRoleManager:roleRebirth( self.dogfood  )
    end);
    AlertManager:show();
end



function RoleReBirthLayer.btnAddClickHandle(sender)
    local self = sender.logic
    if self.dogfood == nil then
        return
    end
    TFDirector:dispatchGlobalEventWith("RoleReBirthLayer.DelDogFoodCall",{ id = self.dogfood , add = false})
    self.dogfood = nil
    self:setAddBtnDel()
end

function RoleReBirthLayer.cellSizeForTable(table,idx)
    return 160,430
end

function RoleReBirthLayer.btnHelpClickHandle(sender)
    AlertManager:addLayerByFile("lua.logic.hermit.HermitHelp");
    AlertManager:show();
end
function RoleReBirthLayer.tableCellAtIndex(table, idx)

    local numInCell = 3
    local cell = table:dequeueCell()
    local self = table.logic
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,numInCell do
            local equip_panel = require('lua.logic.hermit.EatRoleIcon'):new("RoleReBirthLayer")
            equip_panel.panel_empty = TFDirector:getChildByPath(equip_panel, 'panel_empty');
            equip_panel.panel_info = TFDirector:getChildByPath(equip_panel, 'panel_info');

            equip_panel:setPosition(ccp(10 + 130*(i-1),0))
            equip_panel:setLogic( self )
            cell:addChild(equip_panel)
            cell.equip_panel = cell.equip_panel or {}
            cell.equip_panel[i] = equip_panel
        end
    end
    for i=1,numInCell do
        if (idx * numInCell + i) <= self.roleList:length() then
            local role = self.roleList:objectAt(idx * numInCell + i)
            cell.equip_panel[i].panel_empty:setVisible(true);
            cell.equip_panel[i].panel_info:setVisible(true);
            if self.dogfood ~= role.gmId then
                cell.equip_panel[i]:setRoleGmId( role.gmId , 0)
            else
                cell.equip_panel[i]:setRoleGmId( role.gmId , 1)
            end
        else
            cell.equip_panel[i].panel_empty:setVisible(true);
            cell.equip_panel[i].panel_info:setVisible(false);
        end
    end
    return cell
end

function RoleReBirthLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local num = math.max(math.ceil(self.roleList:length()/3),2);
    return num
end



function RoleReBirthLayer:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    --tableView:setPosition(self.panel_list:getPosition())
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RoleReBirthLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RoleReBirthLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleReBirthLayer.numberOfCellsInTableView)
    Public:bindScrollFun(tableView);
    self.panel_list:addChild(tableView,2)
end



function RoleReBirthLayer:addDogFood( gmid , icon)
    if self.dogfood ~= nil then
        --toastMessage("一次只能重生1人")
        toastMessage(localizable.roleReBirthLayer_count)
        return
    end
    local role = CardRoleManager:getRoleByGmid(gmid)
    if role == nil then
        print("该角色不存在 gmId =="..gmid)
        return
    end

    icon:changeNum(1)
    self.dogfood = gmid
    self:setAddBtn(gmid)
    return true;
end

function RoleReBirthLayer:delDogFood( gmid , icon)
     if self.dogfood == nil then
        --toastMessage("没有可重生的侠客")
        toastMessage(localizable.roleReBirthLayer_not)
        return
    end
    local role = CardRoleManager:getRoleByGmid(gmid)
    if role == nil then
        print("该角色不存在 gmId =="..gmid)
        return
    end
    icon:changeNum(0)

    self.dogfood = nil
    self:setAddBtnDel()
end

function RoleReBirthLayer:setAddBtn( id  )
    local img_quality = TFDirector:getChildByPath(self.btn_add, 'img_quality')
    local img_icon = TFDirector:getChildByPath(self.btn_add, 'img_icon')

    if id == nil then
        self.ui:stopAnimation("rotate_cycle")
        img_icon:setVisible(false)
        img_quality:setVisible(false)
        return
    end
    self.ui:runAnimation("rotate_cycle",-1)
    img_icon:setVisible(true)
    img_quality:setVisible(true)
    local role = CardRoleManager:getRoleByGmid(id)
    if role == nil then
        print("无法找到该角色, gmid == "..id)
        return
    end
    img_icon:setTexture(role:getIconPath())
    img_quality:setTexture(GetColorIconByQuality( role.quality ))
end


function RoleReBirthLayer:setAddBtnDel()
    self.dogfood = nil
    self:setAddBtn( nil  )
end

function RoleReBirthLayer:expExChangeItem( exp )
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

function RoleReBirthLayer:calculateReward()
    local xiayi = 0
    local exp = 0
    local coin = 0
    local vesselbreach = 0
    local boom = 0
    local martialRewardList = {}
    local genuine_qi = 0
    local hasGoodRole = false
    local cardRole = CardRoleManager:getRoleByGmid( self.dogfood )
    if cardRole == nil then
        print("该角色不存在 gmId =="..self.dogfood)
        return
    else
        if cardRole.quality >= 4 then
            hasGoodRole = true
        end
        local soul_card_id = cardRole.soul_card_id
        xiayi = xiayi + GetXiaYiBySoulIdAndNum( soul_card_id , cardRole:getStarSoulNum() )
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

    exp =math.ceil(exp*RecycleExpCost/100)
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
    return calculateRewardList , hasGoodRole
end

return RoleReBirthLayer
