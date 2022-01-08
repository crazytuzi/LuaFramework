--[[
******常规商城信息处理*******

    -- by Chikui Peng
    -- 2016/4/11
]]

local AdventureMallInfo = class("AdventureMallInfo")

function AdventureMallInfo:ctor()
end

function AdventureMallInfo:initUI(ui,layer)
    self.logic = layer

    self.img_shensuo        = TFDirector:getChildByPath(ui, 'img_shensuo')
    self.panel_list = TFDirector:getChildByPath(ui, 'panel_list')
    self.btnNormalImg = {
        'ui_new/youli/shop/btn_1.png',
        'ui_new/youli/shop/btn_2.png',
        'ui_new/youli/shop/btn_3.png',
        'ui_new/youli/shop/btn_4.png',
        'ui_new/youli/shop/btn_5.png'
    }
    self.btnHoldImg = {
        'ui_new/youli/shop/btn_1s.png',
        'ui_new/youli/shop/btn_2s.png',
        'ui_new/youli/shop/btn_3s.png',
        'ui_new/youli/shop/btn_4s.png',
        'ui_new/youli/shop/btn_5s.png'
    }
    self.headType = {   HeadResType.ZHENBCY,
                        HeadResType.SHANBCY,
                        HeadResType.QUANBCY,
                        HeadResType.CHAOBCY,
                        HeadResType.CANBCY}
    self:initData()
end

function AdventureMallInfo:initData()
    self.dataList = {}
    for data in AdventureShopData:iterator() do
        self.dataList[data.type] = self.dataList[data.type] or {}
        local len = #(self.dataList[data.type])
        self.dataList[data.type][len+1] = data
    end
end

function AdventureMallInfo:isOpen()
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2203)
    if teamLev < openLev then
        return false
    else
        return true
    end
end

function AdventureMallInfo:show(index)
    self:registerEvents()
    self.panel_list:removeAllChildrenWithCleanup(true)
    self.logic.generalHead.buyButtonEventBound = nil
    self.logic.generalHead:setData(ModuleType.CangShuGe,{self.headType[1],HeadResType.SYCEE})
    for k,v in ipairs(self.logic.btnList) do
        if self.btnHoldImg[k] then
            v:setTextureNormal(self.btnNormalImg[k])
            v:setTexturePressed(self.btnHoldImg[k])
            v:setVisible(true)
            CommonManager:updateRedPoint(v,false)
        else
            v:setVisible(false)
        end
    end
    self.currentLayer = nil
    self.img_shensuo:setTexture('ui_new/youli/shop/img_weiba.png')
    self.logic.btnList[1]:setPositionY(518)
    self:refreshButton()
    self:select(index)
end

function AdventureMallInfo:close()
    self:removeEvents()
    self:dispose()
end

function AdventureMallInfo:btnSelect(index)
    self:select(index)
end

function AdventureMallInfo:brushBtnState()
    for k,v in ipairs(self.logic.btnList) do
        if self.btnHoldImg[k] then
            if self.selectedIndex == k then
                v:setTextureNormal(self.btnHoldImg[k])
            else
                v:setTextureNormal(self.btnNormalImg[k])
            end
            
            v:setTexturePressed(self.btnHoldImg[k])
        end
    end
end

function AdventureMallInfo:refreshButton()
    local temp = 0
    local pos_y = self.logic.btnList[1]:getPositionY()
    for k,v in ipairs(self.logic.btnList) do
        if v:isVisible() then
            v:setPositionY( pos_y - (k-1)*100 )
            temp = temp + 1
        end
    end
    self.img_shensuo:setPositionY(pos_y + 22 - temp*100)
end

function AdventureMallInfo:registerEvents()
    print("AdventureMallInfo:registerEvents() ........")
    self.shopBuyCallBack = function(event)
        self.normalShopPage.tableView:reloadData()
        self.logic.generalHead:refreshUI()
    end
    TFDirector:addMEGlobalListener(AdventureManager.adventureShopBuy, self.shopBuyCallBack)
end

function AdventureMallInfo:removeEvents()
    print("AdventureMallInfo:removeEvents() ........")
    TFDirector:removeMEGlobalListener(AdventureManager.adventureShopBuy, self.shopBuyCallBack)
end

function AdventureMallInfo:select(index)
    self.selectedIndex = index
    if index then
        self:selectNormalShop(index)
    else
        self.selectedIndex = 1
        self:selectNormalShop(1)
    end
    self:brushBtnState()
end

function AdventureMallInfo:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function AdventureMallInfo:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function AdventureMallInfo:showCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:show()
    end
end

function AdventureMallInfo:selectNormalShop(index)
    --创建显示内容图层
    if self.normalShopPage == nil then
        self.normalShopPage = require('lua.logic.mall.AdventureShopPage'):new()
        self.normalShopPage:setName("shopPage")
        self.panel_list:addChild(self.normalShopPage)
    end
    self.logic.generalHead.buyButtonEventBound = nil
    self.logic.generalHead:setData(ModuleType.CangShuGe,{self.headType[index],HeadResType.SYCEE})
    local data = self.dataList[index]
    self.normalShopPage:setData(self.headType[index],data)
end

-----断线重连支持方法
function AdventureMallInfo:onShow()

end

function AdventureMallInfo:dispose()
    if self.normalShopPage then
        self.normalShopPage:dispose()
        self.normalShopPage = nil
    end
end

return AdventureMallInfo