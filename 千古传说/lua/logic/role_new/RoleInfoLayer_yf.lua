--[[
******角色详情*******
    -- by king
    -- 2015/4/17
]]

local RoleInfoLayer_yf = class("RoleInfoLayer_yf", BaseLayer)

function RoleInfoLayer_yf:ctor(data)
    self.super.ctor(self,data)
    self.flag = 1
    self.fightType = EnumFightStrategyType.StrategyType_PVE
    self:init("lua.uiconfig_mango_new.role_new.RoleInfoLayer_yf")
end


function RoleInfoLayer_yf:onShow()
    self.super.onShow(self)
      
    self:refreshBaseUI()
    self:refreshUI()
end

function RoleInfoLayer_yf:refreshBaseUI()

end

function RoleInfoLayer_yf:refreshUI()
    print("------------------------> RoleInfoLayer_yf:refreshUI")
    -- if not self.isShow then
    --     return
    -- end
    self.updateFateWidget = self.updateFateWidget or TFArray:new()
    self.updateFateWidget:clear()

    local fateArray = RoleFateData:getRoleFateById(self.cardRole.id)
    local scrollView = self.list_fate:getChildByTag(4617)
    local offsetY = -118 * fateArray:length()
    if scrollView then
        if self.flag == 0 then
            offsetY = scrollView:getContentOffset().y
        end
        scrollView:removeFromParent()
        scrollView = nil
    end
    self.flag = 0

    scrollView = TFScrollView:create()
    scrollView:setPosition(ccp(0,0))
    scrollView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    scrollView:setTag(4617)

    scrollView:setSize(self.list_fate:getSize())
    scrollView:setInnerContainerSize(CCSizeMake(self.list_fate:getSize().width , 100 * fateArray:length() + 40))
    self.list_fate:addChild(scrollView)
    scrollView:setBounceEnabled(true)
    Public:bindScrollFun(scrollView)
    self.scrollView = scrollView

    local panel_hui_yuanfen      = TFDirector:getChildByPath(self, 'panel_hui_yuanfen')
    local panel_liang_yuanfen    = TFDirector:getChildByPath(self, 'panel_liang_yuanfen')

    self.node_fateList = {}
    self.txt_fateList = {}
    self.txt_titleList = {}
    for i=1,fateArray:length() do
        self.node_fateList[i] =  panel_hui_yuanfen:clone()

        self.txt_fateList[i] = TFDirector:getChildByPath(self.node_fateList[i], "txt_yuanfen_word")
        self.txt_titleList[i] = TFDirector:getChildByPath(self.node_fateList[i], "txt_name")
        self.node_fateList[i].btn_useItem = TFDirector:getChildByPath(self.node_fateList[i], "btn_useItem")
        self.node_fateList[i].btn_useItem.logic = self
        self.node_fateList[i].btn_useItem:addMEListener(TFWIDGET_CLICK, audioClickfun(self.useFateItemClickHandle),1)
        self.node_fateList[i] :setPosition(ccp(0, (fateArray:length() - i) * 118 + 40))
        scrollView:addChild(self.node_fateList[i] )
    end

    self.node_fateLList = {}
    self.txt_fateLList = {}
    self.txt_titleLList = {}
    self.icon_yuanwa = {}
    for i=1,fateArray:length() do
        self.node_fateLList[i] = panel_liang_yuanfen:clone()
        self.txt_fateLList[i] = TFDirector:getChildByPath(self.node_fateLList[i], "txt_yuanfen_word")
        self.txt_titleLList[i] = TFDirector:getChildByPath(self.node_fateLList[i], "txt_name")
        self.node_fateLList[i].txt_showTime = TFDirector:getChildByPath(self.node_fateLList[i], "txt_showTime")
        self.icon_yuanwa[i] = TFDirector:getChildByPath(self.node_fateLList[i], "icon_yuanwa")
        self.node_fateLList[i].btn_add = TFDirector:getChildByPath(self.node_fateLList[i], "btn_add")
        self.node_fateLList[i].btn_add.logic = self
        self.node_fateLList[i].btn_add:addMEListener(TFWIDGET_CLICK, audioClickfun(self.useFateItemClickHandle),1)
        self.node_fateLList[i]:setPosition(ccp(0, (fateArray:length() - i) * 118 + 40))
        scrollView:addChild(self.node_fateLList[i])
    end



    local index = 1;

    for fate in fateArray:iterator() do
        local status = self.cardRole:getFateStatusByFightType(self.fightType,fate.id)
        if status and self.type == "self" then
            self.node_fateLList[index]:setVisible(true);  
            local fateItemInfo = FateManager:getFateItemInfo( self.cardRole.id,fate.id )
            self.node_fateLList[index].txt_showTime:setVisible(false)
            self.icon_yuanwa[index]:setVisible(false)
            self.node_fateLList[index].btn_add:setVisible(false)
            if fateItemInfo then
                if fateItemInfo.forever then
                    self.node_fateLList[index].txt_showTime:setText("永久")
                    self.node_fateLList[index].txt_showTime:setVisible(true)
                    self.icon_yuanwa[index]:setVisible(true)
                elseif fateItemInfo.endTime >= MainPlayer:getNowtime() then
                    self:showTime(self.node_fateLList[index].txt_showTime ,fateItemInfo.endTime )
                    self.node_fateLList[index].txt_showTime:setVisible(true)
                    self.icon_yuanwa[index]:setVisible(true)
                    self.updateFateWidget:push({widget = self.node_fateLList[index].txt_showTime,endtime = fateItemInfo.endTime})
                    self.node_fateLList[index].btn_add.fate = fate
                    self.node_fateLList[index].btn_add:setVisible(true)
                else
                    self.cardRole:updateFate()
                end
            end
            self.node_fateList[index]:setVisible(false);
        else
            self.node_fateLList[index]:setVisible(false);  
            self.node_fateList[index]:setVisible(true);
            if self:canUseItemActivateFate(fate) and self.type == "self" then
                self.node_fateList[index].btn_useItem:setVisible(true)
                self.node_fateList[index].btn_useItem.fate = fate
            else
                self.node_fateList[index].btn_useItem:setVisible(false)
            end
        end
        
        self.txt_fateList[index]:setText(fate.details);
        self.txt_fateLList[index]:setText(fate.details);
        self.txt_titleList[index]:setText(fate.title);
        self.txt_titleLList[index]:setText(fate.title);

        index = index +1;
    end
    scrollView:setInnerContainerSizeForHeight(118 * fateArray:length() + 40)
    scrollView:setContentOffset(ccp(0,offsetY));
end



function RoleInfoLayer_yf:refreshUIOnly()
    print("RoleInfoLayer_yf:refreshUIOnly")
    -- if not self.isShow then
    --     return
    -- end
    self.updateFateWidget = self.updateFateWidget or TFArray:new()
    self.updateFateWidget:clear()

    local fateArray = RoleFateData:getRoleFateById(self.cardRole.id)

    local index = 1;

    for fate in fateArray:iterator() do
        local status = self.cardRole:getFateStatusByFightType(self.fightType,fate.id)
        if status and self.type == "self" then
            self.node_fateLList[index]:setVisible(true);  
            local fateItemInfo = FateManager:getFateItemInfo( self.cardRole.id,fate.id )
            self.node_fateLList[index].txt_showTime:setVisible(false)
            self.icon_yuanwa[index]:setVisible(false)
            self.node_fateLList[index].btn_add:setVisible(false)
            if fateItemInfo then
                if fateItemInfo.forever then
                    self.node_fateLList[index].txt_showTime:setText("永久")
                    self.node_fateLList[index].txt_showTime:setVisible(true)
                    self.icon_yuanwa[index]:setVisible(true)
                elseif fateItemInfo.endTime >= MainPlayer:getNowtime() then
                    self:showTime(self.node_fateLList[index].txt_showTime ,fateItemInfo.endTime )
                    self.node_fateLList[index].txt_showTime:setVisible(true)
                    self.icon_yuanwa[index]:setVisible(true)
                    self.updateFateWidget:push({widget = self.node_fateLList[index].txt_showTime,endtime = fateItemInfo.endTime})
                    self.node_fateLList[index].btn_add.fate = fate
                    self.node_fateLList[index].btn_add:setVisible(true)
                else
                    self.cardRole:updateFate()
                end
            end
            self.node_fateList[index]:setVisible(false);
        else
            self.node_fateLList[index]:setVisible(false);  
            self.node_fateList[index]:setVisible(true);
            if self:canUseItemActivateFate(fate) and self.type == "self" then
                self.node_fateList[index].btn_useItem:setVisible(true)
                self.node_fateList[index].btn_useItem.fate = fate
            else
                self.node_fateList[index].btn_useItem:setVisible(false)
            end
        end
        self.txt_fateList[index]:setText(fate.details);
        self.txt_fateLList[index]:setText(fate.details);
        self.txt_titleList[index]:setText(fate.title);
        self.txt_titleLList[index]:setText(fate.title);

        index = index +1;
    end
end


function RoleInfoLayer_yf:canUseItemActivateFate( fate )
    local targetList = fate:gettarget()
    if #targetList == 0 then
        return false
    end
    if targetList[1].fateType ~= 1 then
        return false
    end
    local num = #targetList
    local quality = self.cardRole.quality
    local itemList = ItemData:GetItemByType( EnumGameItemType.Item ,47)
    for v in itemList:iterator() do
        if v.quality >= quality and v.usable >= num+1 then
            local num = BagManager:getItemNumById( v.id )
            if num > 0 then
                return true
            end
        end
    end
    return false
end

function RoleInfoLayer_yf.useFateItemClickHandle( sender )
    local self = sender.logic
    local fate = sender.fate
    local targetList = fate:gettarget()
    if #targetList == 0 then
        return
    end
    if targetList[1].fateType ~= 1 then
        return
    end
    local num = #targetList
    local quality = self.cardRole.quality
    local itemList = ItemData:GetItemByType( EnumGameItemType.Item ,47)
    local canUseItemList = TFArray:new()
    for v in itemList:iterator() do
        if v.quality >= quality and v.usable >= num+1 then
            local item = BagManager:getItemById( v.id )
            if item and item.num > 0 then
                canUseItemList:push(item)
            end
        end
    end
    if canUseItemList:length() <= 0 then
        --toastMessage("没有可使用的道具")
        toastMessage(localizable.roleInfoLayer_not_pro)
        return
    end
    local layer  = require("lua.logic.role_new.RoleInfoLayer_yfSelect"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_NONE)
    self.clickCallBack = function (id , item_num)
        local item_template = ItemData:objectByID(id)
        if item_template.quality > self.cardRole.quality then
            CommonManager:showOperateSureLayer(
                function()
                    AlertManager:close()
                    AlertManager:close()
                    FateManager:activateFateByItem( self.cardRole.gmId,fate.id ,id ,item_num)
                end,
                nil,
                {
                    --msg = "该替身娃娃品质高于目标缘分，是否继续？"
                    msg = localizable.roleInfoLayer_tips_1
                }
            )
        elseif item_template.usable > (num+1) then
            CommonManager:showOperateSureLayer(
                function()
                    AlertManager:close()
                    AlertManager:close()
                    FateManager:activateFateByItem( self.cardRole.gmId,fate.id ,id ,item_num)
                end,
                nil,
                {
                    --msg = "该替身娃娃可激活人物缘分数高于目标缘分，是否继续？"
                    msg = localizable.roleInfoLayer_tips_2
                }
            )
        else
            AlertManager:close()
            AlertManager:close()
            FateManager:activateFateByItem( self.cardRole.gmId,fate.id ,id ,item_num)
        end
    end
    layer:initDate( canUseItemList, self.clickCallBack)
    AlertManager:show()


end

function RoleInfoLayer_yf:initUI(ui)
	self.super.initUI(self,ui)

    self.list_fate      = TFDirector:getChildByPath(ui, 'panel_list');
end

function RoleInfoLayer_yf:registerEvents(ui)
    self.super.registerEvents(self)
    self.updateFateMessageCallBack = function (event)
        local data = event.data[1]
        -- print(" = =========>",data,self.cardRole.gmId)
        if self.cardRole.gmId == data[1] then
            -- local offset = self.scrollView:getContentOffset().y
            -- print("offset = ",offset)
            self:refreshUI()
            -- self.scrollView:setContentOffset(ccp(0,-200));
        end
    end
    TFDirector:addMEGlobalListener(CardRoleManager.updateFateMessage, self.updateFateMessageCallBack)


    self.widgetTimer = TFDirector:addTimer(1000,-1,nil,function ()
        if self.updateFateWidget then
            local need_update = false
            for v in self.updateFateWidget:iterator() do
                if v.endtime >= MainPlayer:getNowtime() then
                    self:showTime(v.widget,v.endtime)
                else
                    need_update = true
                end
            end
            if need_update then
                self.cardRole:updateFate()
            end
        end
    end)
end


function RoleInfoLayer_yf:showTime(widget ,endTime )
    local second = endTime - MainPlayer:getNowtime()
    local day = math.floor(second/(24*60*60))
    second = second - 24*60*60*day
    local hour = math.floor(second/(60*60))
    second = second - 60*60*hour
    local min = math.floor(second/(60))
    second = second - 60*min
    local str = ""
    if day > 0 then
        --str = string.format('%d天%d小时', day, hour)
        str = stringUtils.format(localizable.common_time_7, day, hour)
    elseif hour > 0 then
        --str = string.format('%d小时%d分',  hour, min)
        str = stringUtils.format(localizable.common_time_8,  hour, min)
    else
        --str = string.format('%d分%d秒',  min, second)
        str = stringUtils.format(localizable.common_time_9,  min, second)
    end
    widget:setText(str)

end

function RoleInfoLayer_yf:removeEvents()
    self.super.removeEvents(self);
    TFDirector:removeMEGlobalListener(CardRoleManager.updateFateMessage, self.updateFateMessageCallBack)  
    self.updateFateMessageCallBack = nil

    if self.widgetTimer then
        TFDirector:removeTimer(self.widgetTimer)
        self.widgetTimer = nil
    end

end


function RoleInfoLayer_yf.onCloseClickHandle(sender)
    local self = sender.logic;

    if (self.img_select) then
        self:removeSelectIcon();
        self:closeEquipListLayer();
       return;
    end 
    AlertManager:close(AlertManager.TWEEN_1);
end


function RoleInfoLayer_yf.BtnClickHandle(sender)
    local self  = sender.logic

end

function RoleInfoLayer_yf:setCardRole(cardRole)
    self.cardRole = cardRole

    if cardRole then
        if self.roleGmid == nil  or self.roleGmid ~= cardRole.gmId then
            self.flag = 1
        end
        self.roleGmid = cardRole.gmId
    end
end

return RoleInfoLayer_yf
