--[[
******铁匠铺装备升星*******

	-- by Stephen.tao
	-- 2014/4/16
]]

local EquipmentStarUp = class("EquipmentStarUp", BaseLayer)

local columnNumber = 3

function EquipmentStarUp:ctor(gmId)
    self.super.ctor(self,gmId)
    self.gmId = gmId
    self:init("lua.uiconfig_mango_new.smithy.EquipmentStarUp")
end

function EquipmentStarUp:initUI(ui)
    self.super.initUI(self,ui)
    --左侧详情
    self.scroll_left            = TFDirector:getChildByPath(ui, 'scroll_left')
    self.info_panel             = require('lua.logic.smithy.EquipInfoPanel'):new(self.gmId)
    self.scroll_left:addChild(self.info_panel)
    self.panel_icon             = TFDirector:getChildByPath(self.info_panel, 'panel_icon')

    --右侧信息
    self.scroll_right           = TFDirector:getChildByPath(ui, 'scroll_right')
    --强化信息
    self.txt_base_current       = TFDirector:getChildByPath(ui, 'txt_base_current')
    self.txt_base_new           = TFDirector:getChildByPath(ui, 'txt_base_new')
    self.txt_growth_current     = TFDirector:getChildByPath(ui, 'txt_growth_current')
    self.txt_growth_new         = TFDirector:getChildByPath(ui, 'txt_growth_new')

    self.lbl_base               = TFDirector:getChildByPath(ui, 'lbl_base')
    self.lbl_growth             = TFDirector:getChildByPath(ui, 'lbl_growth')
    
    --装备星级
    self.panel_star_current     = TFDirector:getChildByPath(ui, 'panel_star_current')
    self.panel_star_new         = TFDirector:getChildByPath(ui, 'panel_star_new')
    self.img_old_star = {}
    self.img_new_star = {}

    for i=1,EquipmentManager.kMaxStarLevel do
        local str = "img_star_"..i
        self.img_old_star[i]       = TFDirector:getChildByPath(self.panel_star_current, str)
        self.img_new_star[i]       = TFDirector:getChildByPath(self.panel_star_new, str)
    end

    --消耗
    self.img_res_icon           = TFDirector:getChildByPath(ui, 'img_res_icon')
    self.txt_cost               = TFDirector:getChildByPath(ui, 'txt_cost')

    --成功率
    self.txt_success        = TFDirector:getChildByPath(ui, 'txt_percent')
    self.txt_failurerate    = TFDirector:getChildByPath(ui, 'txt_fixed')
    self.label_letter       = TFDirector:getChildByPath(ui, 'lbl_extra_fix')

    --升星按钮
    self.btn_starUp         = TFDirector:getChildByPath(ui, 'btn_starUp')
    self.btn_starUp.logic = self
    self.btn_onestepselect         = TFDirector:getChildByPath(ui, 'btn_onestepselect')
    self.btn_onestepselect.logic = self

    self.panel_table        = TFDirector:getChildByPath(ui, 'panel_table')
    self.panel_new_val      = TFDirector:getChildByPath(ui, 'panel_new_val')
    self:initTableview()
    self.dogfood = {}
    self.selectFoodNum = 0
    self.has_tip = not CCUserDefault:sharedUserDefault():getBoolForKey("equip_tip");
end

function EquipmentStarUp:onShow()
    self.super.onShow(self)
    self:refreshUI()
    self.info_panel:onShow()
end

function EquipmentStarUp:refreshUI()
    self.equipList = EquipmentManager:GetOtherEquipByUsed(self.gmId,false,true)

    -- 增加升级道具 30025 --30028
    for i=30025, 30028 do
        local bagItem = BagManager:getItemById(i)
        if bagItem and bagItem.num > 0 then
            self.equipList:insertAt(1, bagItem)
        end
    end
    -- 

    function sortlist(v1,v2)

        if v1.type > v2.type then
            return true
        end

        if v1.kind == 1 and  v2.kind == 1 then
            if v1.quality <= v2.quality then
                return true
            else
                return false
            end
        end


        if v1.quality < v2.quality then
            return true
        elseif v1.quality == v2.quality then
            if v1:getpower() < v2:getpower() then
                return true
            elseif v1:getpower() == v2:getpower() then
                if v1.star < v2.star then
                    return true
                else
                    return false
                end
            else
                return false
            end
        else
            return false
        end
    end

    self.equipList:sort(sortlist)

    self.info_panel:setEquipGmId(self.gmId)
    self:initDetails()
    self.tableView:reloadData()
    self:refreshPercent()
    self:refreshButtonState()
end

function EquipmentStarUp:dispose()
    self.info_panel:dispose()
    self.super.dispose(self)
end

function EquipmentStarUp:removeUI()
    if self.layer_result then
        TFDirector:killAllTween(self.layer_result)
    end
    self.super.removeUI(self)
end

function EquipmentStarUp:setEquipGmId(gmId)
    self.gmId = gmId
    self.dogfood = {}
    self.selectFoodNum = 0
    self:refreshUI()
end

function EquipmentStarUp:setNextAttr(old,now)
    self.txt_base_current:setText(old)
    self.txt_base_new:setText(now)
end

function EquipmentStarUp:setNextGrow(old,now)
    self.txt_growth_current:setText(old)
    self.txt_growth_new:setText(now)
end

function EquipmentStarUp:initDetails()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    self:refreshStarLevel()

    self.txt_success:setText("0%")
    if equip.failPercent and equip.failPercent ~= 0 then
        self.txt_failurerate:setText("+" .. equip.failPercent .. "%")
        self.label_letter:setVisible(true)
        self.txt_failurerate:setVisible(true)
    else
        self.label_letter:setVisible(false)
        self.txt_failurerate:setVisible(false)
    end

    local equipmentTemplate = EquipmentTemplateData:objectByID(equip.id)
    if equipmentTemplate == nil then
        print("没有此类装备模板信息")
        return
    end

    local grow = equipmentTemplate.growth_factor + (equip:getStar()+1)*equipmentTemplate.growth_interval
    grow = grow/100
    local attribute_index , attribute_num = equip:getBaseAttribute():getAttributeByIndex(1)
    local attribute_index1 , attribute_num1 = equip:getBaseAttributeOnOne():getAttributeByIndex(1)

    local totalGrowNum = GetTotalGrowNumByKind( attribute_index ,equip.level)
    local num = math.floor((attribute_num1 + totalGrowNum)*grow)
    --加入重铸属性
    -- num = num + math.floor(num*equip:getRecastPercent()/100)
    local temp  = num - attribute_num
    self:setNextAttr( attribute_num,num )
    self:setNextGrow( equip.grow,grow )
    self.successPrecent = 0
    local cost = equipmentTemplate:getStarUpCost(equip:getStar()+1)
    self.consumeCoin = cost
    if cost then
        self.txt_cost:setText(cost)
        if cost < MainPlayer:getCoin() then
            self.txt_cost:setColor(ccc3(255,255,255))
        else
            self.txt_cost:setColor(ccc3(255,0,0))
        end
    end

    if equip.equipType == 1 then
        --self.lbl_base:setText("基础武力：")
        --self.lbl_growth:setText("武力成长：")
        self.lbl_base:setText(localizable.smithy_EquipmentStarUp_base1)
        self.lbl_growth:setText(localizable.smithy_EquipmentStarUp_add1)
    elseif equip.equipType == 2 then
        --self.lbl_base:setText("基础防御：")
        --self.lbl_growth:setText("防御成长：")
        self.lbl_base:setText(localizable.smithy_EquipmentStarUp_base2)
        self.lbl_growth:setText(localizable.smithy_EquipmentStarUp_add2)
    elseif equip.equipType == 3 then
        --self.lbl_base:setText("基础内力：")
        --self.lbl_growth:setText("内力成长：")
        self.lbl_base:setText(localizable.smithy_EquipmentStarUp_base3)
        self.lbl_growth:setText(localizable.smithy_EquipmentStarUp_add3)
    elseif equip.equipType == 4 then
        --self.lbl_base:setText("基础血气：")
        --self.lbl_growth:setText("血气成长：")
        self.lbl_base:setText(localizable.smithy_EquipmentStarUp_base4)
        self.lbl_growth:setText(localizable.smithy_EquipmentStarUp_add4)
    elseif equip.equipType == 5 then
        --self.lbl_base:setText("基础身法：")
        --self.lbl_growth:setText("身法成长：")
        self.lbl_base:setText(localizable.smithy_EquipmentStarUp_base5)
        self.lbl_growth:setText(localizable.smithy_EquipmentStarUp_add5)
    end
end

function EquipmentStarUp:refreshStarLevel()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    for i=1,EquipmentManager.kMaxStarLevel do
        if i <= equip:getStar() then
            self.img_old_star[i]:setTexture("ui_new/smithy/star_full.png")
        else
            self.img_old_star[i]:setTexture("ui_new/smithy/star_empty.png")
        end
    end

    if equip:getStar() >= 5 then
        self.panel_new_val:setVisible(false)
        self.txt_cost:setVisible(false)
        self.img_res_icon:setVisible(false)
    else
        self.img_res_icon:setVisible(true)
        self.txt_cost:setVisible(true)
        self.panel_new_val:setVisible(true)
        for i=1,EquipmentManager.kMaxStarLevel do
            if i <= equip:getStar()+1 then
                self.img_new_star[i]:setTexture("ui_new/smithy/star_full.png")
            else
                self.img_new_star[i]:setTexture("ui_new/smithy/star_empty.png")
            end
        end
    end

end

function EquipmentStarUp:refreshPercent()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end
    self.successPrecent = 0
    for k,v in pairs(self.dogfood) do
        -- local tempEquip = EquipmentManager:getEquipByGmid(k)
        local tempEquip = self:getEquipByGmid(k)
        if tempEquip then
            -- local temp = 0.2*(1+tempEquip.star*0.25+tempEquip.level*0.01)*(6-equip.star)*(1+(tempEquip.quality-equip.quality)*0.2)/5*100
            local temp = 0

                print("refreshPercent num = ", v)
            if tempEquip.type == 1 then
                temp = 0.2*(1+tempEquip.star*0.25+tempEquip.level*0.01)*(6-equip.star)*(1+(tempEquip.quality-equip.quality)*0.2)/5*100
            else
                temp = 0

                for i=1,v do
                    temp = temp + 0.2*(1+0+0)*(6-equip.star)*(1+(tempEquip.quality-equip.quality)*0.2)/5*100
                end
            end
            self.successPrecent = self.successPrecent + temp
        end
    end

    self.successPrecent = math.ceil(self.successPrecent)
    local totalPercent = self.successPrecent
    if (self.successPrecent + equip.failPercent) >= 100 then
        totalPercent = 100
        self.tableView:reloadData()
    end

    self.txt_success:setText(totalPercent .. "%")
    if equip.failPercent and equip.failPercent ~= 0 then
        self.txt_failurerate:setText("+" .. equip.failPercent .. "%")
        self.label_letter:setVisible(true)
        self.txt_failurerate:setVisible(true)
    else
        self.txt_failurerate:setVisible(false)
        self.label_letter:setVisible(false)
    end

end


function EquipmentStarUp.cellSizeForTable(table,idx)
    return 130,483
end

function EquipmentStarUp.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    local offset = 30
    local space = 5
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,columnNumber do
            local equip_panel = require('lua.logic.smithy.EquipmentStarUpIcon'):new()
            equip_panel:setPosition(ccp(130*(i-1) + offset,0))
            equip_panel:setLogic( self )
            cell:addChild(equip_panel)
            cell.equip_panel = cell.equip_panel or {}
            cell.equip_panel[i] = equip_panel
        end
    end
    for i=1,columnNumber do
        if (idx * columnNumber + i) <= self.equipList:length() then
            local equip = self.equipList:objectAt(idx * columnNumber + i)
            cell.equip_panel[i]:setEquipGmid(equip.gmId)
            --cell.equip_panel[i]:setVisible(true)
        else
            --cell.equip_panel[i]:setVisible(false)
            cell.equip_panel[i]:setEquipGmid(nil)
        end
    end
    return cell
end

function EquipmentStarUp.numberOfCellsInTableView(table)
    local self = table.logic
    if self.equipList and self.equipList:length() > 0 then
        local num = math.ceil(self.equipList:length()/columnNumber)
        if num < 2 then
            return 2
        else
            return num
        end
    end
    return 2
end

function EquipmentStarUp:initTableview()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_table:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, EquipmentStarUp.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, EquipmentStarUp.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, EquipmentStarUp.numberOfCellsInTableView)
    

    self.panel_table:addChild(tableView)
end

function EquipmentStarUp:refreshButtonState()
    local foodNum = 0
    for k,v in pairs(self.dogfood) do
       foodNum = foodNum + 1
    end

    if foodNum == 0 then
        self.btn_starUp:setTouchEnabled(false)
        self.btn_starUp:setGrayEnabled(true)
    else
        self.btn_starUp:setTouchEnabled(true)
        self.btn_starUp:setGrayEnabled(false)
    end
end

function EquipmentStarUp.starUpButtonClickHandle(sender)
	local self = sender.logic
    if self.lockMark == true then
        return
    end
    local dogfoodlist = {}
    local stuffList   = {} --道具列表
    local temp = 1
    local chooseNum = 1
    for k,v in pairs(self.dogfood) do
        print("dog food : k,v",k,v)
        if k >= 1048576 then
            dogfoodlist[temp] = k
            temp = temp + 1
        else
            stuffList[chooseNum] = {k, v}
            chooseNum = chooseNum + 1
        end

    end

    chooseNum = chooseNum + temp - 2
    -- if #dogfoodlist == 0 then
    if chooseNum == 0 then
        --toastMessage("请选择材料")
        toastMessage(localizable.smithy_EquipmentStarUp_check)
        return
    end

    local coin = self.consumeCoin
    local enough = MainPlayer:isEnoughCoin(coin,true)
    if not enough then
        return
    end
    self.lockMark = true

    -- print("dogfoodlist = ", dogfoodlist)
    -- print("stuffList   = ", stuffList)
	EquipmentManager:EquipmentStarUp(self.gmId , dogfoodlist, stuffList)
end


function EquipmentStarUp.onestepSelectButtonClickHandle( sender )
    print("EquipmentStarUp.onestepSelectButtonClickHandle( sender )")
    sender.logic:btnChoiceOnce()
end

function EquipmentStarUp:getTotalPercent()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return 0
    end

    return self.successPrecent + equip.failPercent
end

function EquipmentStarUp:IconBtnClick_Equip(gmId, icon)
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("111 equipment not found .",self.gmId)
        return false
    end

    if equip.star >= 5 then
        toastMessage("星级到达上限")
        return false
    end

    play_xuanze()


    if self.dogfood[gmId] then
        self.dogfood[gmId] = nil
        self:refreshUI()

        self.selectFoodNum = self.selectFoodNum - 1 -- add by king 20141015
    else
        -- 限制升星的最大个数
        if self.selectFoodNum >= 5 then 
            --toastMessage("一次吞噬上限为5件")
            toastMessage(localizable.smithy_EquipmentStarUp_max)
            return
        end

        if self.successPrecent + equip.failPercent >= 100 then
            --toastMessage("成功率已经达到[100%]，无需再选择新的装备")
            toastMessage(localizable.smithy_EquipmentStarUp_suc)
            return false
        end

        -- local selectEquip = EquipmentManager:getEquipByGmid(gmId)
        local selectEquip = self:getEquipByGmid(gmId)
        if selectEquip == nil  then
            print("222 equipment not found .",gmId)
            return false
        end

        local dialogMsg = self:getEquipMsg(selectEquip)
        if dialogMsg then
            CommonManager:showOperateSureTipLayer(
                function(data, widget)
                    self.dogfood[gmId] = 1
                    self.selectFoodNum = self.selectFoodNum + 1  -- add by king 20141015
                    self:refreshUI()
                    self:getHasTip(widget)
                end,
                function(data, widget)
                    AlertManager:close()
                    self:getHasTip(widget)
                    --self:refreshUI()
                end,
                {
                    msg = dialogMsg,
                    showtype = AlertManager.BLOCK_AND_GRAY
                }
            )
        else
            -- self.dogfood[gmId] = true
            self.dogfood[gmId] = 1
            self.selectFoodNum = self.selectFoodNum + 1  -- add by king 20141015
            self:refreshUI()
        end

    end

    self.tableView:reloadData()
    return true
end

function EquipmentStarUp:IconBtnClick_Tool(gmId, icon, bIsAddTool)
    -- if true then
    --     return
    -- end
    if self.lockMark == true then
        return
    end
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        -- print("111 equipment not found .",self.gmId)
        return false
    end

    if equip.star >= 5 then
        --toastMessage("星级到达上限")
        toastMessage(localizable.smithy_EquipmentStarUp_start)
        return false
    end

    play_xuanze()

    -- 点击去掉按钮
    if bIsAddTool == false then
        if self.dogfood[gmId] then
            self.dogfood[gmId] = self.dogfood[gmId] - 1

            self.selectFoodNum = self.selectFoodNum - 1 -- add by king 20141015

            if self.dogfood[gmId] < 1 then
                self.dogfood[gmId] = nil
                -- self.selectFoodNum = self.selectFoodNum - 1 -- add by king 20141015
            end

            self:refreshUI()
        end

        return
    end

    if self.successPrecent + equip.failPercent >= 100 then
        --toastMessage("成功率已经达到[100%]，无需再选择新的装备")
        toastMessage(localizable.smithy_EquipmentStarUp_suc)
        return false
    end
    
    if self.selectFoodNum >= 5 then 
        --toastMessage("一次吞噬上限为5件")
        toastMessage(localizable.smithy_EquipmentStarUp_max)
        return
    end
    local itemInfo = BagManager:getItemById(gmId)
    self.dogfood[gmId] = self.dogfood[gmId] or 0
    if itemInfo.num > self.dogfood[gmId]  then
        self.dogfood[gmId] = self.dogfood[gmId] + 1
        self.selectFoodNum = self.selectFoodNum + 1 
    end
    self:refreshUI()
    self.tableView:reloadData()
    return true
end

function EquipmentStarUp:getHasTip( widget )
    local state = widget:getSelectedState();
    print("state == ",state)
    if state == true then
        self.has_tip = false
        CCUserDefault:sharedUserDefault():setBoolForKey("equip_tip",not self.has_tip);
        CCUserDefault:sharedUserDefault():flush();
        return
    end
end

function EquipmentStarUp:registerEvents()
	self.super.registerEvents(self)

    self.btn_starUp:addMEListener(TFWIDGET_CLICK, audioClickfun(self.starUpButtonClickHandle),1)
	self.btn_onestepselect:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onestepSelectButtonClickHandle),1)

    self.equipmentStarUpResultCallBack = function (event)
        self.dogfood = {}
        self.selectFoodNum = 0
        self:refreshButtonState()
        if event.data[1].success == true then
            play_qianghuabaoji_shengxingchenggong()
            self:playSuccessEffect(true)
        else
            play_shengxingshibai()
            self:playSuccessEffect(false)
        end
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_STAR_UP_RESULT,self.equipmentStarUpResultCallBack)
end


function EquipmentStarUp:removeEvents()
    self.super.removeEvents(self)

    if self.equip_panel then
        self.ui:removeChild(self.equip_panel)
        self.equip_panel = nil
    end
    if self.successEffect then
        self.ui:removeChild(self.successEffect)
        self.successEffect = nil
    end

    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_STAR_UP_RESULT,self.equipmentStarUpResultCallBack)
    self.lockMark = false
    -- --[[ flush 升星提示 ]]
    -- CCUserDefault:sharedUserDefault():setBoolForKey("equip_tip",not self.has_tip);
    -- CCUserDefault:sharedUserDefault():flush();
end

--显示升星失败对话框
function EquipmentStarUp:showFailDialog()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end
    if equip.failPercent > 0 then
        --toastMessage("升星失败,累计补偿成功概率["..equip.failPercent .."%]")
        toastMessage(stringUtils.format(localizable.smithy_EquipmentStarUp_radio,equip.failPercent))
    else
        --toastMessage("升星失败")
        toastMessage(localizable.smithy_EquipmentStarUp_fail)
    end
end

--显示升星成功对话框
function EquipmentStarUp:showSuccessDialog()
    if self.layer_result == nil then
        self.layer_result = TFImage:create("ui_new/smithy/shengxing_word.png")
        self.layer_result:setAnchorPoint(ccp(0.5,0.5))
        self.layer_result:setPosition(ccp(self.ui:getContentSize().width/2,self.ui:getContentSize().height/2))
        self.ui:addChild(self.layer_result)
    end

    TFDirector:killAllTween(self.layer_result)
    self.layer_result:setVisible(true)
    self.layer_result:setZOrder(100)
    self.layer_result:setScale(0.1)
    local tween = {
        target = self.layer_result,
            {
                duration = 0.1,
                scale = 1,
            },
            {
                duration = 0.1,
                scale = 0.8,
            },
            {
                duration = 0.1,
                scale = 1,
            },
            {
                duration = 0,
                delay = 1,
                onComplete = function ()
                    self.layer_result:setVisible(false)
                    self.lockMark = false
                end,
            },
    }
    TFDirector:toTween(tween)
end

--[[特效相关代码]]
function EquipmentStarUp:playSuccessEffect(success)
    --local size = GameConfig.WS
    --local center = ccp(size.width/2,size.height/2)

    local size = self.ui:getSize()
    local center = ccp(size.width/2,size.height/2+100)

    local equip_panel = require('lua.logic.smithy.SmithyEquipIcon'):new()

    equip_panel:setEquipGmId(self.gmId)
    equip_panel:setStarByFailPercent()
    equip_panel:setZOrder(99)
    equip_panel:setAnchorPoint(ccp(0.5,0.5))
    equip_panel:setPosition(center)
    equip_panel:setScale(1.8)
    equip_panel:setTouchEnabled(false)
    equip_panel:removeEvents()

    -- 牛逼的策划又要隐藏一些本来公共显示的东西
    local img_equiped = TFDirector:getChildByPath(equip_panel, 'img_equiped')
    local img_splash  = TFDirector:getChildByPath(equip_panel, 'img_splash')
    local txt_power   = TFDirector:getChildByPath(equip_panel, 'txt_power')
    local img_zhanli  = TFDirector:getChildByPath(equip_panel, 'img_zhanli')

    img_equiped:setVisible(false)
    img_splash:setVisible(false)
    txt_power:setVisible(false)
    img_zhanli:setVisible(false)

    equip_panel:setVisible(false)

    local effect = Public:addEffect("equip_star_lv_up_1", self.panel_icon, 340, 50, 1, 0)
    effect:setZOrder(100)

    -- TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/equip_star_lv_up_1.xml")
    -- local effect = TFArmature:create("equip_star_lv_up_1_anim")
    -- if effect == nil then
    --     return
    -- end

    -- effect:setZOrder(100)
    -- effect:setAnimationFps(GameConfig.ANIM_FPS)
    -- effect:playByIndex(0, -1, -1, 0)

    -- effect:setPosition(center)

    --local currentScene = Public:currentScene()
    --currentScene:addChild(equip_panel)
    --currentScene:addChild(effect)

    self.equip_panel = equip_panel
    self.successEffect = effect
    self.ui:addChild(equip_panel)
    -- self.ui:addChild(effect)
    effect:addMEListener(TFSKELETON_COMPLETE,
    function()
        self.ui:removeChild(equip_panel)
        self.ui:removeChild(effect)
        self.equip_panel = nil
        self.successEffect = nil
        if success then
            self:playStarEffect()
            self:playIconEffect()
            self:showSuccessDialog()
            --self:playBattleScoreChangedEffect()
        else 
            self:refreshUI()
            self:showFailDialog()
            self.lockMark = false
        end
    end)
end

function EquipmentStarUp:playStarEffect()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/equip_star_lv_up_3.xml")
    local effect = TFArmature:create("equip_star_lv_up_3_anim")
    if effect == nil then
        return
    end

    effect:setZOrder(100)
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)

    local newStar = self.img_old_star[equip.star]
    local parent = self.panel_star_current
    if newStar == nil then
        return
    end
    local pos = newStar:getPosition()
    effect:setPosition(ccp(pos.x,pos.y))

    parent:addChild(effect)
    effect:addMEListener(TFARMATURE_COMPLETE,
    function()
        parent:removeChild(effect)
        self:refreshUI()
    end)
end

function EquipmentStarUp:playIconEffect()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/equip_star_lv_up_2.xml")
    local effect = TFArmature:create("equip_star_lv_up_2_anim")
    if effect == nil then
        return
    end

    effect:setZOrder(100)
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)

    local position = self.info_panel:getIconCenterWorldPos()
    local _parent = self.ui:getParent()
    local rootPos = _parent:convertToWorldSpaceAR(self.ui:getPosition())
    position.x = position.x - rootPos.x
    position.y = position.y - rootPos.y
    effect:setPosition(position)

    self.ui:addChild(effect)
    effect:addMEListener(TFARMATURE_COMPLETE,
    function()
        self.ui:removeChild(effect)
        self:playBattleScoreChangedEffect()
    end)
end

function EquipmentStarUp:playBattleScoreChangedEffect()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    if 1 then
        return
    end
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/equip_star_lv_up_4.xml")
    local effect = TFArmature:create("equip_star_lv_up_4_anim")
    if effect == nil then
        return
    end

    effect:setZOrder(100)
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)

    local position = self.info_panel:getPowerWorldPos()
    local _parent = self.ui:getParent()
    local rootPos = _parent:convertToWorldSpaceAR(self.ui:getPosition())
    position.x = position.x - rootPos.x - 100
    position.y = position.y - rootPos.y
    effect:setPosition(position)

    self.ui:addChild(effect)
    effect:addMEListener(TFARMATURE_COMPLETE,
    function()
        self.ui:removeChild(effect)
    end)
end

function EquipmentStarUp:isTouchInTableView(position)
    local _parent = self.tableView:getParent()
    local rootPos = _parent:convertToWorldSpaceAR(self.tableView:getPosition())
    local size = self.tableView:getTableViewSize()
    if position.x > rootPos.x and position.x < rootPos.x+size.width 
        and position.y <rootPos.y + size.height and position.y > rootPos.y then
        return true
    end
    return false
end

--一键选取
function EquipmentStarUp:btnChoiceOnce()
    if self.lockMark == true then
        return
    end
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("111 equipment not found .",self.gmId)
        return false
    end

    if equip.star >= 5 then
        --toastMessage("星级到达上限")
        toastMessage(localizable.smithy_EquipmentStarUp_start)
        return false
    end

    local equipList = EquipmentManager:GetOtherEquipByUsed(self.gmId,false,true)
    local has_num = equipList:length()
    local itemList = BagManager:getItemByKind(9 ,1)
    for v in itemList:iterator() do
        has_num = has_num + v.num
    end

    local max_num = has_num > 5 and 5 or has_num
    local num = max_num - self.selectFoodNum
    if num  <= 0 then
        return
    end

    local addList = {}
    local dialogMsg = nil
    local successPrecent = self.successPrecent
    for v in itemList:iterator() do
        local use_num = self.dogfood[v.id] or 0
        if v.num - use_num > 0 then
            -- self.dogfood[v.id] = self.dogfood[v.id] or 0
            local add_num = math.min(v.num - use_num , num)
            local success_temp = self:getSuccessPercent(false,v.id)
            local success_need = 100 - successPrecent
            add_num = math.min(add_num , math.ceil(success_need/success_temp) )
            successPrecent = add_num*success_temp + successPrecent
            -- self.dogfood[v.id] = self.dogfood[v.id] + add_num
            addList[#addList + 1] = {}
            addList[#addList].id = v.id
            addList[#addList].num = add_num
            num = num - add_num
            if successPrecent >= 100 then
                num = 0
            end
        end
        if num == 0 then
            break
        end
    end
    if num > 0 then
        for i=1,self.equipList:length() do
            local equip = self.equipList:objectAt(i)
            if equip.type ~= 9 then
                if self.dogfood[equip.gmId] == nil then
                    num = num - 1
                    addList[#addList + 1] = {}
                    addList[#addList].id = equip.gmId
                    addList[#addList].num = 1
                    local success_temp = self:getSuccessPercent(true,equip.gmId)
                    successPrecent = successPrecent + success_temp
                    if dialogMsg == nil then
                        dialogMsg = self:getEquipMsg(equip)
                    end
                end
            end
            if num == 0 or successPrecent >= 100 then
                break
            end
        end
    end
    if dialogMsg then
        CommonManager:showOperateSureTipLayer(
            function(data, widget)
            local totalNum = 0
                for i=1,#addList do
                    self.dogfood[addList[i].id] = self.dogfood[addList[i].id] or 0
                    self.dogfood[addList[i].id] = self.dogfood[addList[i].id] + addList[i].num
                    totalNum = totalNum + addList[i].num
                end
                self.selectFoodNum = self.selectFoodNum + totalNum
                self:refreshUI()
                self:getHasTip(widget)
            end,
            function(data, widget)
                AlertManager:close()
                self:getHasTip(widget)
            end,
            {
                msg = dialogMsg,
                showtype = AlertManager.BLOCK_AND_GRAY
            }
        )
    else
        local totalNum = 0
        for i=1,#addList do
            self.dogfood[addList[i].id] = self.dogfood[addList[i].id] or 0
            self.dogfood[addList[i].id] = self.dogfood[addList[i].id] + addList[i].num
            totalNum = totalNum + addList[i].num
        end
        self.selectFoodNum = self.selectFoodNum + totalNum
        self:refreshUI()
    end
end

function EquipmentStarUp:getEquipMsg( equip)
    if self.has_tip == false then
        return nil
    end

    if equip.type == 9 then
        return nil
    end

    local dialogMsg = nil
    if equip:getGemPos(1) then
        --dialogMsg = "您选择的是已经镶嵌宝石的装备，是否确认选择吞噬此装备？"
        dialogMsg = localizable.smithy_EquipmentStarUp_text1
    elseif equip.star >0  then
        --dialogMsg = "您选择的是已经升星的装备，是否确认选择吞噬此装备？"
        dialogMsg = localizable.smithy_EquipmentStarUp_text2
    elseif equip.level > 0 then
        --dialogMsg = "您选择的是已经强化过的装备，是否确认选择吞噬此装备？"
        dialogMsg = localizable.smithy_EquipmentStarUp_text3
    elseif equip.quality >= 4 then
        --dialogMsg = "您选择的是稀有品质装备，是否确认选择吞噬此装备？"
        dialogMsg = localizable.smithy_EquipmentStarUp_text4
    end
    return dialogMsg
end

function EquipmentStarUp:getEquipByGmid(gmid)
  

    local equip = EquipmentManager:getEquipByGmid(gmid)

    if equip then
        -- print("find a equip :", gmid)
        return equip
    end

    equip = BagManager:getItemById(gmid)

    return equip
end

function EquipmentStarUp:getSuccessPercent( equip , gmid )
    local equipInfo = EquipmentManager:getEquipByGmid(self.gmId)
    local temp = 0
    if equipInfo == nil  then
        print("111 equipment not found .",self.gmId)
        return false
    end
    if equip then
        local info = EquipmentManager:getEquipByGmid(gmid)
        temp = 0.2*(1+info.star*0.25+info.level*0.01)*(6-equipInfo.star)*(1+(info.quality-equipInfo.quality)*0.2)/5*100
    else
        local info = BagManager:getItemById(gmid)
        temp = temp + 0.2*(1+0+0)*(6-equipInfo.star)*(1+(info.quality-equipInfo.quality)*0.2)/5*100
    end
    return temp
end

return EquipmentStarUp
