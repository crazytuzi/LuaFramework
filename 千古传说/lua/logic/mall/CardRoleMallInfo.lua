--[[
******侠客商城信息处理*******

	-- by Chikui Peng
	-- 2016/4/12
]]

local CardRoleMallInfo = class("CardRoleMallInfo")

function CardRoleMallInfo:ctor()
end

function CardRoleMallInfo:initUI(ui,layer)
    self.logic = layer

    self.img_shensuo        = TFDirector:getChildByPath(ui, 'img_shensuo')
    self.panel_list = TFDirector:getChildByPath(ui, 'panel_list')
    self.btnNormalImg = {
        'ui_new/faction/btn_shop_putong1.png'
    }
    self.btnHoldImg = {
        'ui_new/faction/btn_shop_putong2.png'
    }
end

function CardRoleMallInfo:isOpen()
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2201)
    if teamLev < openLev then
        return false
    else
        return true
    end
end

function CardRoleMallInfo:show(index)
    self:registerEvents()
    self.panel_list:removeAllChildrenWithCleanup(true)
    self.logic.generalHead.buyButtonEventBound = nil
    self.logic.generalHead:setData(ModuleType.XiaKe,{HeadResType.XIAYI,HeadResType.COIN,HeadResType.SYCEE})
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
    self.img_shensuo:setTexture('ui_new/shop/sc_shenzi.png')
    self.logic.btnList[1]:setPositionY(513)
    self:refreshButton()
    self:select(index)
end

function CardRoleMallInfo:close()
    self:removeEvents()
    self:dispose()
end

function CardRoleMallInfo:btnSelect(index)
    self:select(index)
end

function CardRoleMallInfo:brushBtnState()
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

function CardRoleMallInfo:refreshButton()
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

function CardRoleMallInfo:registerEvents()
    print("CardRoleMallInfo:registerEvents() ........")
end

function CardRoleMallInfo:removeEvents()
    print("CardRoleMallInfo:removeEvents() ........")
end

function CardRoleMallInfo:select(index)
    self.selectedIndex = index
    self:selectCardRoleShop()
    self:brushBtnState()
end

function CardRoleMallInfo:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function CardRoleMallInfo:selectCardRoleShop()
    if self.cardroleShopPage == nil then
        self.cardroleShopPage = require('lua.logic.hermit.RoleShopPage'):new()
        self.panel_list:addChild(self.cardroleShopPage)
    end
end

-----断线重连支持方法
function CardRoleMallInfo:onShow()
end

function CardRoleMallInfo:dispose()
    if self.cardroleShopPage then
        self.cardroleShopPage:dispose()
        self.cardroleShopPage = nil
    end
end

return CardRoleMallInfo