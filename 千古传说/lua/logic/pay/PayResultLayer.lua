--[[
******充值 充值结果*******

    -- by king
    -- 2015/5/21
]]
local PayResultLayer = class("PayResultLayer", BaseLayer);

CREATE_SCENE_FUN(PayResultLayer);
CREATE_PANEL_FUN(PayResultLayer);


function PayResultLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.pay.Result");
    self.firstShow = true
end

function PayResultLayer:initUI(ui)
    self.super.initUI(self,ui);


    self.btn_close 		= TFDirector:getChildByPath(ui, 'Btn_OK');

    self.txt_result1       = TFDirector:getChildByPath(ui, 'txt_result1')
    self.txt_result2       = TFDirector:getChildByPath(ui, 'txt_result2')
    self.img_rz_bg1       = TFDirector:getChildByPath(ui, 'img_rz_bg')
    self.img_rz_bg2       = TFDirector:getChildByPath(ui, 'img_rz_bg2')
    self.img_rz_icon       = TFDirector:getChildByPath(self.img_rz_bg1, 'img_rz_icon')
    self.panel_fanbei       = TFDirector:getChildByPath(ui, 'Panel_fanbei')
    self.pay_cell       = TFDirector:getChildByPath(ui, 'pay_cell')
    self.panel_list       = TFDirector:getChildByPath(ui, 'panel_list')

    self.panel_fanbei:setVisible(false)
    self.pay_cell:retain()
    self.pay_cell:removeFromParent(true)
    self.pay_cell:setVisible(false)
end

function PayResultLayer:setIcon(rechargeId)
    print("---rechargeId---",rechargeId)
    self.img_rz_icon:setTexture("ui_new/pay/VIP_yb"..rechargeId..".png");
end

function PayResultLayer:setVipLevel(vip1, vip2)
    self.vip1  = vip1 or 0
    self.vip2  = vip2 or 0 
end

function PayResultLayer:setValue(baseValue, extValue,showMultiple)
    self.baseValue  = baseValue
    self.extValue   = extValue
    self.showMultiple   = showMultiple or false
end

function PayResultLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()


    if self.firstShow == true then
        self.ui:runAnimation("Action0", 10);
        self.firstShow = false
    end
end

function PayResultLayer:refreshBaseUI()

end


function PayResultLayer:refreshUI()
    if self.txt_result1 and self.baseValue then
        print("self.baseValue = ", self.baseValue)
        self.txt_result1:setText(self.baseValue)
    end

    if self.txt_result2 and self.extValue then
        print("self.extValue = ", self.extValue)
        self.txt_result2:setText(self.extValue)

        local show = true

        if self.extValue <= 0 then
            show = false
        end
        self.img_rz_bg2:setVisible(show)
    end
    local num = PayManager:getDoubleRechargeListNum()
    self.rechargeListNum = num or 0
    if self.showMultiple and num > 0 then
        self.panel_fanbei:setVisible(true)
        if self.tableView == nil then
            self:creatTableView()
        end
        self.tableView:reloadData()

        for i=1,#self.panelList do
            self:showEffect(self.panelList[i],"pay_multi_result")
        end
    else
        self.panel_fanbei:setVisible(false)
    end

end

function PayResultLayer:showEffect( panel , effectName )
    -- equipIntensify_3
    print("PayResultLayer:showEffect")
    local resPath = "effect/"..effectName..".xml"
    if not TFFileUtil:existFile(resPath) then
        print("--------------effect == existFile == false")
        return
    end
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create(effectName.."_anim")
    if effect == nil then
        print("--------------effect == nil")
        return
    end
    -- effect:setScale(0.9)
    -- effect:setScaleX(0.7)
    effect:setPosition(ccp(130, 20))
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setZOrder(10)
    panel:addChild(effect)
    effect:playByIndex(0, -1, -1, 0)
end

function PayResultLayer:creatTableView()
    local  tableView =  TFTableView:create()
    -- tableView:setName("btnTableView")
    tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    tableView:setPosition(self.panel_list:getPosition())
    self.tableView = tableView

    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, PayResultLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, PayResultLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, PayResultLayer.numberOfCellsInTableView)


    self.panel_list:getParent():addChild(self.tableView,1)
end


function PayResultLayer.cellSizeForTable(table,cell)
    return 50,254
end
function PayResultLayer.numberOfCellsInTableView(table,cell)
    local self = table.logic
    return self.rechargeListNum or 0
end

function PayResultLayer.tableCellAtIndex(table,idx)
    local self = table.logic
    local cell = table:dequeueCell()
    self.panelList = self.panelList or {}
    if cell == nil then
        cell = TFTableViewCell:create()
        local panel = self.pay_cell:clone()
        panel:setVisible(true)
        self.panelList[#self.panelList + 1] = panel
        cell:addChild(panel)
        panel:setPosition(ccp(0,0))
        panel:setTag(100)
    end
    local index = idx + 1
    local panel = cell:getChildByTag(100)
    self:setCellInfo(panel,index)
    return cell
end

function PayResultLayer:setCellInfo(panel,index)
    local pay_index , multiple = PayManager:getDoubleRechargeByIndex(index)
    print("pay_index , multiple  == ",pay_index , multiple)
    local txt_cost = TFDirector:getChildByPath(panel, 'txt_cost')
    local txt_num = TFDirector:getChildByPath(panel, 'txt_num')
    local rechargeItem = PayManager.rechargeList:objectByID(pay_index);
    txt_cost:setText(stringUtils.format(localizable.Pay_multiple_txt,rechargeItem.price))
    txt_num:setText(multiple)
end

function PayResultLayer:removeUI()
    self.super.removeUI(self);
    -- if self.pay_cell then
    --     self.pay_cell:release()
    --     self.pay_cell = nil
    -- end
end



--注册事件
function PayResultLayer:registerEvents()
   self.super.registerEvents(self)

   -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close.logic = self
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closePayResult),1)

    self:addMEListener(TFWIDGET_EXIT, function ()
        if self.vip1 ~= self.vip2 then
        print("vip 等级改变 之前vip="..self.vip1.."  现在vip="..self.vip2)
        -- AlertManager:close(AlertManager.TWEEN_NONE)
        -- 弹出。。。
			
			if self.vip2 > 15 and self.vip2 <= 18 then
				MainPlayer:setFirstLogin(true)
			end
			
            PayManager:showVipChangeLayer()

            OperationActivitiesManager:vipChanged(self.vip2)
        end
        -- body
    end)
end

function PayResultLayer:removeEvents()
    self.firstShow = true
end

function PayResultLayer.closePayResult(sender)
    local self = sender.logic

    -- AlertManager:close()
    AlertManager:close(AlertManager.TWEEN_NONE)
    if self.vip1 ~= self.vip2 then
        print("vip 等级改变 之前vip="..self.vip1.."  现在vip="..self.vip2)
        -- AlertManager:close(AlertManager.TWEEN_NONE)
        -- 弹出。。。
		
		if self.vip2 > 15 and self.vip2 <= 18 then
			MainPlayer:setFirstLogin(true)
		end
		
        PayManager:showVipChangeLayer()

        OperationActivitiesManager:vipChanged(self.vip2)
    end
end




return PayResultLayer


