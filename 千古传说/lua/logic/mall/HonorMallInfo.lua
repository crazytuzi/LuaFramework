--[[
******侠客商城信息处理*******

	-- by Chikui Peng
	-- 2016/4/13
]]

local HonorMallInfo = class("HonorMallInfo")

function HonorMallInfo:ctor()
end

function HonorMallInfo:initUI(ui,layer)
    self.logic = layer

    self.img_shensuo        = TFDirector:getChildByPath(ui, 'img_shensuo')
    self.panel_list = TFDirector:getChildByPath(ui, 'panel_list')
    self.btnNormalImg = {
        'ui_new/faction/btn_shop_putong1.png',
        'ui_new/faction/btn_shop_jingpin1.png'
    }
    self.btnHoldImg = {
        'ui_new/faction/btn_shop_putong2.png',
        'ui_new/faction/btn_shop_jingpin2.png'
    }
    self.PageList = {}
end

function HonorMallInfo:isOpen()
    if MultiServerFightManager:getActivityState() == 0 or MultiServerFightManager:getActivityState() == nil then
        return false
    else
        return true
    end
end

function HonorMallInfo:show(index)
    self:registerEvents()
    self.panel_list:removeAllChildrenWithCleanup(true)
    self.logic.generalHead.buyButtonEventBound = nil
    self.logic.generalHead:setData(ModuleType.Honor,{HeadResType.LOWHONOR,HeadResType.HIGHTHONOR,HeadResType.SYCEE})
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
    self.img_shensuo:setTexture('ui_new/shop/sc_shenzi.png')
    self.logic.btnList[1]:setPositionY(513)
    self:refreshButton()
    self:select(index)
end

function HonorMallInfo:close()
    self:removeEvents()
    self:dispose()
end

function HonorMallInfo:btnSelect(index)
    self:select(index)
end

function HonorMallInfo:brushBtnState()
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

function HonorMallInfo:refreshButton()
    local randomStore = MallManager:getrandomStoreTable()
    if randomStore[RandomStoreType.Honor]:isOpen() == false then
        self.logic.btnList[1]:setVisible(false)
    end
    if randomStore[RandomStoreType.Honor_2]:isOpen() == false then
        self.logic.btnList[2]:setVisible(false)
    end
    local temp = 0
    local pos_y = self.logic.btnList[1]:getPositionY()
    for k,v in ipairs(self.logic.btnList) do
        if v:isVisible() then
            v:setPositionY( pos_y - (k-1)*110 )
            temp = temp + 1
        end
    end
    self.img_shensuo:setPositionY(pos_y + 22 - temp*110)
end

function HonorMallInfo:registerEvents()
    print("HonorMallInfo:registerEvents() ........")
end

function HonorMallInfo:removeEvents()
    print("HonorMallInfo:removeEvents() ........")
end

function HonorMallInfo:select(index)
    self.selectedIndex = index
    if index then
        self:selectNormalShop(index)
    else
        self.selectedIndex = 1
        self:selectNormalShop(1)
    end
    self:brushBtnState()
end

function HonorMallInfo:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function HonorMallInfo:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function HonorMallInfo:showCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:show()
    end
end

function HonorMallInfo:selectNormalShop(index)
    self:hideCurrentLayer()
    local typeList = {RandomStoreType.Honor,RandomStoreType.Honor_2}
    if typeList[index] == nil then
        index = 1
    end
    if self.PageList[index] == nil then
        self.PageList[index] = require('lua.logic.mall.NormalShopPage'):new(typeList[index])
        self.panel_list:addChild(self.PageList[index])
    end
    
    self.currentLayer = self.PageList[index]
    self:showCurrentLayer()
end

-----断线重连支持方法
function HonorMallInfo:onShow()
end

function HonorMallInfo:dispose()
    for k,v in pairs(self.PageList) do
        v:dispose()
    end
    self.PageList = {}
    self.currentLayer = nil
end

return HonorMallInfo