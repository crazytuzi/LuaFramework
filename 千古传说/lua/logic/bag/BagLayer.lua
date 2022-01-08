--[[
******背包层*******

	-- by david.dai
	-- 2014/6/2
]]

BagTableView_SELECT_CELL = "BagTableView.SELECT_CELL"

local BagLayer = class("BagLayer", BaseLayer)

function BagLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.bag.BagLayer")
    self.firstShow = true
end

function BagLayer:loadData(data)
    self.selectedButton = nil;
end

function BagLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.generalHead = CommonManager:addGeneralHead( self ,10)

    self.generalHead:setData(ModuleType.Bag,{HeadResType.COIN,HeadResType.SYCEE})

    self.tab = {TFDirector:getChildByPath(ui, 'btn_all'),TFDirector:getChildByPath(ui, 'btn_prop'),TFDirector:getChildByPath(ui, 'btn_wx'),TFDirector:getChildByPath(ui, 'btn_tianshu'),TFDirector:getChildByPath(ui, 'btn_soul'),TFDirector:getChildByPath(ui, 'btn_piece')}
    -- self.tab = {TFDirector:getChildByPath(ui, 'btn_all'),TFDirector:getChildByPath(ui, 'btn_prop'),TFDirector:getChildByPath(ui, 'btn_wx'),TFDirector:getChildByPath(ui, 'btn_soul'),TFDirector:getChildByPath(ui, 'btn_piece')}

    -- self.tab[5]:setVisible(false)
    self.panel_details  = TFDirector:getChildByPath(ui, 'panel_details')
    self.panel_tableView= TFDirector:getChildByPath(ui, 'panel_tableView')


    self.normalTextures = {'ui_new/bag/tab-dj2.png','ui_new/bag/tab-wx2.png','ui_new/bag/tab-xh2.png','ui_new/tianshu/tab_ts.png','ui_new/bag/tab-sp2.png','ui_new/bag/tab-wxsp2.png'}
    self.selectedTextures = {'ui_new/bag/tab-dj.png','ui_new/bag/tab-wx.png','ui_new/bag/tab-xh.png','ui_new/tianshu/tab_tsh.png','ui_new/bag/tab-sp.png','ui_new/bag/tab-wxsp.png'}
    -- self.layerPath = {'lua.logic.bag.ItemDetails','lua.logic.bag.BagSoulDetailsLayer','lua.logic.bag.BagPieceDetailsLayer','lua.logic.bag.ItemDetails'}
   -- self.normalTextures = {'ui_new/bag/tab-qb2.png','ui_new/bag/tab-dj2.png','ui_new/bag/tab-wx2.png','ui_new/bag/tab-xh2.png','ui_new/bag/tab-sp2.png'}
   --  self.selectedTextures = {'ui_new/bag/tab-qb.png','ui_new/bag/tab-dj.png','ui_new/bag/tab-wx.png','ui_new/bag/tab-xh.png','ui_new/bag/tab-sp.png'}
    self.layerPath = {'lua.logic.bag.ItemDetails','lua.logic.bag.ItemDetails','lua.logic.bag.BagSoulDetailsLayer','lua.logic.bag.SkyBookDetailsLayer','lua.logic.bag.BagPieceDetailsLayer','lua.logic.bag.BagPieceDetailsLayer'}
    self.detailsLayer = {}

    local temp = 1
    for k,v in pairs(self.tab) do
        v.logic = self
        v:setTexturePressed(self.selectedTextures[temp])
        temp = temp + 1
    end

    self.img_empty = TFDirector:getChildByPath(ui, 'img_empty')

    self:selectTabDefault(1)
end

function BagLayer:removeUI()
    self.super.removeUI(self)
    -- self.generalHead:dispose()
end

function BagLayer:allBtnToNormal()
    for i = 1,#self.tab do
        self.tab[i]:setTextureNormal(self.normalTextures[i])
    end
end

function BagLayer:selectTabDefault(index)
    if self.selectedIndex then
        return
    end

    self:allBtnToNormal()
    self.tab[index]:setTextureNormal(self.selectedTextures[index])
    self.selectedIndex = index
end

function BagLayer.tabButtonClick(sender)
    local self = sender.logic
    -- local index,i = 0,1
    -- for k,v in pairs(self.tab) do
    --     if v == sender then
    --         index = i
    --         break
    --     end
    --     i = i+1
    -- end

    -- if index == 0 then
    --     index = 1
    -- end
    local index = sender:getTag()
    print("index==",index)
    self:updateDetails(index)
    self.bagTableView:selectDefault()
end


function BagLayer:setSelectedButtonIndex(index )
    self:updateDetails(index)
    self.bagTableView:selectDefault()
end

function BagLayer:updateDetails(index)
    if self.selectedIndex == index then
        return
    end
    -- print("BagLayer:updateDetails(index)")
    self:allBtnToNormal()
    self.tab[index]:setTextureNormal(self.selectedTextures[index])
    self:showDetailsLayer(index)

    -- if self.bagTableView then
    --     self.bagTableView:removeFromParent()
    --     self.bagTableView = nil
    -- end

    -- self.bagTableView = require('lua.logic.bag.BagTableView'):new()
    -- self.bagTableView:setHomeLayer(self)
    -- self.panel_tableView:addChild(self.bagTableView)
    self.bagTableView:setType(index)
    self.selectedIndex = index
end

function BagLayer:showDetailsLayer(index)
    local key = tostring(index)
    local layer = self.detailsLayer[key]
    if not layer then
        layer = require(self.layerPath[index]):new()
        layer:setHomeLayer(self)
        self.panel_details:addChild(layer)
        self.detailsLayer[key] = layer
    end
    self:showCurrentLayer(layer)
end

--[[
选中物品
]]
function BagLayer:select(holdGoods)
    --if self.goodsId and self.goodsId == holdGoods.itemdata.id then
    --    return
    --end

    --show or refresh details layer
    local function calculateIndex(holdGoods)
        local _type, _kind = 0, 0
        if holdGoods.itemdata then
            _type = holdGoods.itemdata.type
            _kind = holdGoods.itemdata.kind
        else
            _type = holdGoods:getConfigType()
            _kind = holdGoods:getConfigKind()
        end
        if _type == EnumGameItemType.Item or _type == EnumGameItemType.Box or _type == EnumGameItemType.RandomPack or _type == EnumGameItemType.HeadPicFrame then
            return 1
        elseif _type == EnumGameItemType.Book then
            return 2
        elseif _type == EnumGameItemType.Soul then
            return 3
        -- elseif _type == EnumGameItemType.Piece and _kind == 3 then
        --[[
            changed by wuqi
        ]]
        elseif _type == EnumGameItemType.SkyBook then
            return 4
        elseif _type == EnumGameItemType.Piece and ( _kind >= 1 and _kind <= 5) then
            return 5
        elseif _type == EnumGameItemType.Piece and _kind == 10 then
            return 6
        --[[
        elseif _type == EnumGameItemType.Piece and ( _kind >= 1 and _kind <= 5) then
            return 4
        elseif _type == EnumGameItemType.Piece and _kind == 10 then
            return 5
        ]]
        else
            return 1
        end
    end

    local index = calculateIndex(holdGoods)
    if holdGoods.itemdata then
        self.goodsId = holdGoods.itemdata.id
    else
        self.goodsId = holdGoods.instanceId
    end
    self:showDetailsLayer(index)
    if self.currentLayer then
        self.currentLayer:setData(holdGoods)
    end
end

function BagLayer:registerEvents()
    print("BagLayer:registerEvents")
    self.super.registerEvents(self)

    for k,v in pairs(self.tab) do
        v:setTag(k)
        v:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tabButtonClick))
    end
   
    self.cellSelected = function(event)
        local data = event.data[1]
        if not data then
            self:hideCurrentLayer()
            return
        end
        self:select(data)
    end
    TFDirector:addMEGlobalListener(BagTableView_SELECT_CELL,self.cellSelected)

    if self.bagTableView then
        self.bagTableView:registerEvents()
        self.bagTableView:refreshUI()
        if self.bagTableView.itemlist:length() == 0 then
            if self.currentLayer then
                self.currentLayer:setVisible(false)
            end
        end
    end
    if self.bagTableView == nil then
        self.bagTableView = require('lua.logic.bag.BagTableView'):new()
        self.bagTableView:setHomeLayer(self)
        self.bagTableView:setType(1)
        self.panel_tableView:addChild(self.bagTableView)
    end

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    if self.detailsLayer then
        for k,v in pairs(self.detailsLayer) do
            v:registerEvents()
        end
    end
end

function BagLayer:removeEvents()
    for k,v in pairs(self.tab) do
        v:removeMEListener(TFWIDGET_CLICK)
    end

    TFDirector:removeMEGlobalListener(BagTableView_SELECT_CELL,self.cellSelected)

    if self.generalHead then
        self.generalHead:removeEvents()
    end

    if self.bagTableView then
        self.bagTableView:removeEvents()
    end

    if self.detailsLayer then
        for k,v in pairs(self.detailsLayer) do
            v:removeEvents()
        end
    end
    self.firstShow = true
    self.super.removeEvents(self)
end

function BagLayer:dispose()
    if self.bagTableView then
        self.bagTableView:dispose()
        self.bagTableView = nil
    end

    if self.detailsLayer then
        for k,v in pairs(self.detailsLayer) do
            v:dispose()
        end
        self.detailsLayer = nil
    end

    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function BagLayer:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function BagLayer:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function BagLayer:showCurrentLayer(layer)
    self:hideCurrentLayer()
    self.currentLayer = layer
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:refreshUI()
    end
end

-----断线重连支持方法
function BagLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    self:refreshUI()

    
    if self.firstShow == true then
        self.ui:runAnimation("Action0",1);
        self.firstShow = false
    end
end

function BagLayer:numberChanged()
     if self.currentLayer then
        self.currentLayer:refreshUI()
    end
end

function BagLayer:refreshUI()
    if self.currentLayer then
        self.currentLayer:refreshUI()
    end
    
    self:refreshRedPointState()
    self.bagTableView:refreshUI()
end

function BagLayer:refreshRedPointState()
    local position = ccp(0,-10)
    local canUse = BagManager:isHaveCanProp()
    if not canUse then
        canUse = BagManager:isHaveCanGift()
    end
    if not canUse then
        canUse = BagManager:isHaveCanFrame()
    end

    CommonManager:updateRedPoint(self.tab[1], canUse,position)

    local canZhaomu = BagManager:isHaveCanZhaomu()
    CommonManager:updateRedPoint(self.tab[3],canZhaomu,position)
    local canMerge = BagManager:isHaveCanEquipPiece()
    CommonManager:updateRedPoint(self.tab[5],canMerge,position)

    -- if canUse or canMerge or canZhaomu then
    --     CommonManager:updateRedPoint(self.tab[1],true,position)
    -- else
    --     CommonManager:updateRedPoint(self.tab[1],false,position)
    -- end
end

return BagLayer
