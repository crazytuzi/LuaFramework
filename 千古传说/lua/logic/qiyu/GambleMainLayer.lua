
local GambleMainLayer = class("GambleMainLayer", BaseLayer)
local column = 8
function GambleMainLayer:ctor()
    self.super.ctor(self)
    self.getItemNum  = 0
    self:init("lua.uiconfig_mango_new.qiyu.DushiLayer")
    -- QiyuManager:SengQueryEatPigMsg()
end

function GambleMainLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
end

function GambleMainLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.generalHead = CommonManager:addGeneralHead( self )
    self.generalHead:setData(ModuleType.Gamble,{HeadResType.COIN,HeadResType.SYCEE})

    self.Panel_baoshi = TFDirector:getChildByPath(ui, 'Panel_baoshi')
    self.btn_yjds = TFDirector:getChildByPath(ui, 'btn_yjds')
    self.btn_qbsq = TFDirector:getChildByPath(ui, 'btn_qbsq')
    self.btn_zhenxuan = TFDirector:getChildByPath(ui, 'btn_zhenxuan')
    self.btn_help = TFDirector:getChildByPath(ui, 'btn_help')
    self.btn_gamble = {}
    self.txt_cost = {}
    self.img_res_icon = {}
    for i=1,GambleManager.gambleMaxLevel do
        self.btn_gamble[i] = TFDirector:getChildByPath(ui, 'btn_'..i)
        local img_res_bg = TFDirector:getChildByPath(ui, 'img_res_bg'..i)
        self.txt_cost[i] = TFDirector:getChildByPath(img_res_bg, 'txt_price')
        self.img_res_icon[i] = TFDirector:getChildByPath(img_res_bg, 'img_res_icon')
    end

    self.bagItem_panel = createUIByLuaNew("lua.uiconfig_mango_new.qiyu.DushiIcon")
    self.bagItem_panel:retain() 
    self:refreshBagView()
    self:refreshButtoState()
end
function GambleMainLayer:registerEvents(ui)
    self.super.registerEvents(self)

    for i=1,GambleManager.gambleMaxLevel do
        self.btn_gamble[i].tag = i
        self.btn_gamble[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.gambleBtnClickHandle),1)
    end
    self.btn_zhenxuan.logic =self
    self.btn_zhenxuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.zhenxuanBtnClickHandle),1)
    self.btn_yjds:addMEListener(TFWIDGET_CLICK, audioClickfun(self.yjdsBtnClickHandle),1)
    self.btn_qbsq:addMEListener(TFWIDGET_CLICK, audioClickfun(self.qbsqBtnClickHandle),1)
    -- self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.helpBtnClickHandle),1)

    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.helpBtnClickHandle),1)

    self.itemChangeCallback = function(event)
        local data = event.data[1]
        self:refreshBagView()
        self.getItemNum = data[1]
        self:addAllEffect()
    end
    TFDirector:addMEGlobalListener(GambleManager.ItemChange,self.itemChangeCallback)
    self.stateChangeCallback = function(event)
        self:refreshButtoState()
    end
    TFDirector:addMEGlobalListener(GambleManager.StateChangeMessage,self.stateChangeCallback)

    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function GambleMainLayer:removeEvents()
    if self.generalHead then
        self.generalHead:removeEvents()
    end

    TFDirector:removeMEGlobalListener(GambleManager.ItemChange,self.itemChangeCallback)
    TFDirector:removeMEGlobalListener(GambleManager.StateChangeMessage,self.stateChangeCallback)
    self.super.removeEvents(self)
end
function GambleMainLayer:removeUI()
    self.super.removeUI(self)
    if self.bagItem_panel then
        self.bagItem_panel:release()
        self.bagItem_panel = nil
    end    
end

function GambleMainLayer.gambleBtnClickHandle(sender)
    local index = sender.tag
    if GambleManager:getStateByIndex(index ) then

        local gambleInfo = GambleTypeData:objectByID(2^(index-1))
        if gambleInfo then
            local consumes  = gambleInfo:getConsumes()
            local resValue = MainPlayer:getResValueByType(consumes.type)

            if consumes.value > resValue then
                --toastMessage("您的"..GetResourceName(consumes.type) .. "不足")
                toastMessage(stringUtils.format(localizable.GambleMainLayer_text1, GetResourceName(consumes.type)))
                return
            end
            if consumes.type == EnumDropType.SYCEE then
                if GambleManager.gamble_cost_tip[index] == false then
                    CommonManager:showOperateSureTipLayer(
                        function(data, widget)
                            GambleManager:requestBetByType(index)
                            GambleManager.gamble_cost_tip[index] = widget:getSelectedState() or false;
                        end,
                        function(data, widget)
                            AlertManager:close()
                            GambleManager.gamble_cost_tip[index] = widget:getSelectedState() or false;
                        end,
                        {
                            --title="操作确认",
                            title=localizable.TreasureMain_tips1,
                            --msg = gambleInfo.title.."需要花费"..consumes.value..GetResourceName(consumes.type).."，是否确认",
                            msg = stringUtils.format(localizable.GambleMainLayer_text2,gambleInfo.title,consumes.value,GetResourceName(consumes.type) ),
                            showtype = AlertManager.BLOCK_AND_GRAY
                        }
                    )
                    return

                end
            end
        end

        GambleManager:requestBetByType(index)
    end
end
function GambleMainLayer.zhenxuanBtnClickHandle(sender)
    local self = sender.logic

    local zhenxuanInfo = GambleZxData:objectByID(1)
    if zhenxuanInfo == nil then
        print("甄选数据有错误")
        return
    end
    local consumes  = zhenxuanInfo:getConsumes()
    local resValue = MainPlayer:getResValueByType(consumes.type)

    if GambleManager.zhenxuan_cost_tip then
        if resValue < consumes.value then
            --toastMessage("您的元宝不足")
            toastMessage(localizable.common_your_yuanbao)
            return
        end
        GambleManager:requestPick()
        return
    end

    CommonManager:showOperateSureTipLayer(
        function(data, widget)
            if resValue < consumes.value then
               --toastMessage("您的元宝不足")
               toastMessage(localizable.common_your_yuanbao)
            else
                GambleManager:requestPick()
            end
            GambleManager.zhenxuan_cost_tip = widget:getSelectedState() or false;
        end,
        function(data, widget)
            AlertManager:close()
            GambleManager.zhenxuan_cost_tip = widget:getSelectedState() or false;
        end,
        {
            --title="操作确认",
            title=localizable.TreasureMain_tips1,
            --msg="甄选需要花费"..consumes.value..GetResourceName(consumes.type).."，是否确认",
            msg=stringUtils.format(localizable.GambleMainLayer_text3,consumes.value,GetResourceName(consumes.type) ),
            showtype = AlertManager.BLOCK_AND_GRAY
        }
    )
end


--一键赌石
function GambleMainLayer.yjdsBtnClickHandle(sender)
    local vipLevel = VipData:getMinLevelDeclear(8100)
    if MainPlayer:getVipLevel() < vipLevel then
        local msg =  stringUtils.format(localizable.vip_gamble_not_enough,vipLevel);
        CommonManager:showOperateSureLayer(
                function()
                    PayManager:showPayLayer();
                end,
                nil,
                {
                title = localizable.common_vip_up,
                msg = msg,
                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                }
        )
        return
    end
    GambleManager:requestBatchBetAuto(10)
end

--一键拾取
function GambleMainLayer.qbsqBtnClickHandle(sender)
    GambleManager:requestPickup(0)
end

function GambleMainLayer.helpBtnClickHandle(sender)
    CommonManager:showRuleLyaer("dushi")
end


function GambleMainLayer:refreshBagView()
    if self.tableView == nil then
        local  tableView =  TFTableView:create()
        tableView:setTableViewSize(self.Panel_baoshi:getContentSize())
        tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
        tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)


        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, GambleMainLayer.cellSizeForTable)
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, GambleMainLayer.tableCellAtIndex)
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, GambleMainLayer.numberOfCellsInTableView)
        self.tableView = tableView
        self.tableView.logic = self
        self.Panel_baoshi:addChild(tableView)
    end
    self.tableView:reloadData()
    self.tableView:setScrollToEnd(false)
end

function GambleMainLayer:refreshButtoState()
    for i=1,GambleManager.gambleMaxLevel do
        if GambleManager:getStateByIndex(i) then
            self.btn_gamble[i]:setGrayEnabled(false)
            self.btn_gamble[i]:setTouchEnabled(true)
        else
            self.btn_gamble[i]:setGrayEnabled(true)
            self.btn_gamble[i]:setTouchEnabled(false)
        end
        local gambleInfo = GambleTypeData:objectByID(2^(i-1))
        if gambleInfo then
            local consumes  = gambleInfo:getConsumes()
            local resValue = MainPlayer:getResValueByType(consumes.type)
            self.txt_cost[i]:setText(consumes.value)
            self.img_res_icon[i]:setTexture(GetResourceIcon(consumes.type))

            if consumes.value <= resValue then
                self.txt_cost[i]:setColor(ccc3(255,255,255))
            else
                self.txt_cost[i]:setColor(ccc3(255,0,0))
            end
        end
    end
    if GambleManager:getStateByIndex(4) then
        self.btn_zhenxuan:setGrayEnabled(true)
        self.btn_zhenxuan:setTouchEnabled(false)
    else
        self.btn_zhenxuan:setGrayEnabled(false)
        self.btn_zhenxuan:setTouchEnabled(true)
    end
end


function GambleMainLayer.cellSizeForTable(table,idx)
    return 110,940
end


function GambleMainLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    if nil == cell then
        cell = TFTableViewCell:create()
        for i=1,column do
            local bagItem_panel = self.bagItem_panel:clone()
            bagItem_panel:setScale(0.8)
            local width = bagItem_panel:getSize().width*0.8
            local x = width*(i-1) + 15
            -- if i > 1 then
            --     x = x + (i-1)*10
            -- end
            bagItem_panel:setPosition(ccp(x,0))

            cell:addChild(bagItem_panel)
            cell.bagItem_panel = cell.bagItem_panel or {}
            cell.bagItem_panel[i] = bagItem_panel
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = bagItem_panel
        end
    end
    for i=1,column do
        local tmpIndex = idx * column + i
        if tmpIndex <= GambleManager:getBagNum() then
            local _item = GambleManager.itemArray:objectAt(tmpIndex)
            if _item then
                cell.bagItem_panel[i].stone_index = tmpIndex
                cell.bagItem_panel[i]:setVisible(true)
                local rewardItem = BaseDataManager:getReward({itemId = _item.resId,type = _item.resType,number =_item.resNum})
                self:loadIconNode(cell.bagItem_panel[i],rewardItem,_item)
            else
                cell.bagItem_panel[i]:setVisible(false)
                cell.bagItem_panel[i].stone_index = 0
            end
        else
            cell.bagItem_panel[i].stone_index = 0
            cell.bagItem_panel[i]:setVisible(false)
        end
        if cell.bagItem_panel[i].effect then
            cell.bagItem_panel[i].effect:removeFromParent(true)
            cell.bagItem_panel[i].effect = nil
        end
    end
    return cell
end


function GambleMainLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    self.super.dispose(self)
end

function GambleMainLayer:addAllEffect()
    local length = #self.allPanels
    for i=1,length do
        local panel = self.allPanels[i]
        local index = panel.stone_index
        if index ~= 0 and index + self.getItemNum > GambleManager:getBagNum() and index <= GambleManager:getBagNum() then
            -- print("index = ",index)
            -- print("self.getItemNum = ",self.getItemNum)
            -- print("GambleManager:getBagNum() = ",GambleManager:getBagNum())
            local parent = panel:getParent()
            panel:setVisible(false)
            self:addGetEffect(parent,panel)
        end
    end
    self.getItemNum  = 0
end

function GambleMainLayer:addGetEffect(cell,node)
    local filePath = "effect/ui/gamble_stone.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(filePath)
    local effect = TFArmature:create("gamble_stone_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    local posX = node:getPositionX()
    effect:setPosition(ccp(posX+55,55))
    effect:setZOrder(10)
    cell:addChild(effect)
    node.effect = effect
    local step = 1
    effect:addMEListener(TFARMATURE_UPDATE,function()
        step = step + 1
        if step == 14 then 
            node:setVisible(true)
            effect:removeMEListener(TFARMATURE_UPDATE)
        end
        end)
end

function GambleMainLayer:loadIconNode(node,rewardItem,itemInfo)
    local img_icon  = TFDirector:getChildByPath(node, 'img_icon');
    local txt_price   = TFDirector:getChildByPath(node, 'txt_price');
    -- local txt_name  = TFDirector:getChildByPath(node, 'txt_name');
    local bg_icon   = TFDirector:getChildByPath(node, 'bg_icon');

    if bg_icon then
        bg_icon:setTextureNormal(GetColorIconByQuality_118(rewardItem.quality));
        function onClick( sender )
          Public:ShowItemTipLayer(rewardItem.itemid, rewardItem.type);
        end
        bg_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(onClick));
    end
    -- if txt_name then
    --     txt_name:setText(rewardItem.name);
    -- end
    if img_icon then
        img_icon:setTexture(rewardItem.path);
        -- self:addPieceImg(img_icon,rewardItem);
    end
    txt_price:setVisible(false)
    if itemInfo.resType == EnumDropType.GOODS then
        local item = ItemData:objectByID(itemInfo.resId)
        if item and item.type == EnumGameItemType.Rubbish then
            txt_price:setVisible(true)
            txt_price:setText(item.price)
        end
    end

    return node;
end


function GambleMainLayer.numberOfCellsInTableView(table)
    return math.ceil(GambleManager:getBagNum()/column)
end

return GambleMainLayer