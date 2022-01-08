--[[
******常规商城信息处理*******

    -- by Chikui Peng
    -- 2016/4/11
]]

local NormalMallInfo = class("NormalMallInfo")

function NormalMallInfo:ctor()
end

function NormalMallInfo:initUI(ui,layer)
    self.logic = layer

    self.img_shensuo        = TFDirector:getChildByPath(ui, 'img_shensuo')
    self.panel_list = TFDirector:getChildByPath(ui, 'panel_list')
    self.btnNormalImg = {
        'ui_new/shop/btn_normal_unselected.png',
        'ui_new/shop/btn_gifts_unselected.png',
        'ui_new/shop/btn_recruit_unselected.png',
        'ui_new/shop/btn_zhenbao_unselected.png'
    }
    self.btnHoldImg = {
        'ui_new/shop/btn_normal_selected.png',
        'ui_new/shop/btn_gifts_selected.png',
        'ui_new/shop/btn_recruit_selected.png',
        'ui_new/shop/btn_zhenbao_selected.png'
    }
end

function NormalMallInfo:isOpen()
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(106)
    if teamLev < openLev then
        return false
    else
        return true
    end
end

function NormalMallInfo:show(index)
    self:registerEvents()
    self.panel_list:removeAllChildrenWithCleanup(true)
    self.logic.generalHead.buyButtonEventBound = nil
    self.logic.generalHead:setData(ModuleType.Mall,{HeadResType.COIN,HeadResType.SYCEE})
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

function NormalMallInfo:close()
    self:removeEvents()
    self:dispose()
end

function NormalMallInfo:btnSelect(index)
    self:select(index)
end

function NormalMallInfo:brushBtnState()
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

function NormalMallInfo:refreshButton()
    local randomStore = MallManager:getrandomStoreTable()
    if randomStore[RandomStoreType.Xiyou]:isOpen() == false then
        self.logic.btnList[3]:setVisible(false)
    end
    if randomStore[RandomStoreType.Zhenbao]:isOpen() == false then
        self.logic.btnList[4]:setVisible(false)
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

function NormalMallInfo:registerEvents()
    print("NormalMallInfo:registerEvents() ........")
end

function NormalMallInfo:removeEvents()
    print("NormalMallInfo:removeEvents() ........")
end

function NormalMallInfo:select(index)
    self.selectedIndex = index
    if index then
        if index == 1 then
            self:selectNormalShop()
        elseif index == 2 then
            self:selectGifts()
        elseif index == 3 then
            self:selectXiyou()
        elseif index == 4 then
            self:selectZhenBao()
        end
    else
        self.selectedIndex = 1
        self:selectNormalShop()
    end
    self:brushBtnState()
end

function NormalMallInfo:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function NormalMallInfo:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function NormalMallInfo:showCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:show()
    end
end

function NormalMallInfo:selectNormalShop()
    self:hideCurrentLayer()

    --创建显示内容图层
    if self.normalShopPage == nil then
        self.normalShopPage = require('lua.logic.mall.NormalShopPage'):new()
        self.panel_list:addChild(self.normalShopPage)
    end

    self.currentLayer = self.normalShopPage
    self:showCurrentLayer()
    
    MallManager:onIntoGoodsLayer();
    CommonManager:updateRedPoint(self.btn_normal_shop, MallManager:isHaveNewGoods(),ccp(-10,-10))
end

function NormalMallInfo:selectGifts()
    self:hideCurrentLayer()

    --创建显示内容图层
    if self.giftsPage == nil then
        self.giftsPage = require('lua.logic.mall.GiftsShopPage'):new()
        self.panel_list:addChild(self.giftsPage)
    end
    
    self.currentLayer = self.giftsPage
    self:showCurrentLayer()
end


function NormalMallInfo:selectXiyou()
    self:hideCurrentLayer()

    --创建显示内容图层
    if self.xiyouPage == nil then
        self.xiyouPage = require('lua.logic.mall.XiyouShopPage'):new()
        self.panel_list:addChild(self.xiyouPage)
    end

    self.currentLayer = self.xiyouPage
    self:showCurrentLayer() 

    MallManager:onIntoXiyouLayer();
    CommonManager:updateRedPoint(self.btn_xiyou, MallManager:isHaveXiyouNewGoods(),ccp(-10,-10))
end


function NormalMallInfo:selectZhenBao()
    self:hideCurrentLayer()

    --创建显示内容图层
    if self.zhenbaoPage == nil then
        self.zhenbaoPage = require('lua.logic.mall.ZhenbaoShopPage'):new()
        self.panel_list:addChild(self.zhenbaoPage)
    end

    self.currentLayer = self.zhenbaoPage
    self:showCurrentLayer()

    MallManager:onIntoZhenBaoLayer();
    CommonManager:updateRedPoint(self.btn_zhenbao, MallManager:isHaveZhenBaoNewGoods(),ccp(-10,-10))
end

-----断线重连支持方法
function NormalMallInfo:onShow()
    if self.currentLayer then
        self.currentLayer:onShow()
    end

    CommonManager:updateRedPoint(self.btn_gifts, MallManager:isHaveNewGif(),ccp(-10,-10))
    CommonManager:updateRedPoint(self.btn_normal_shop, MallManager:isHaveNewGoods(),ccp(-10,-10))
    CommonManager:updateRedPoint(self.btn_xiyou, MallManager:isHaveXiyouNewGoods(),ccp(-10,-10))
    CommonManager:updateRedPoint(self.btn_zhenbao, MallManager:isHaveZhenBaoNewGoods(),ccp(-10,-10))
    
end

function NormalMallInfo:dispose()
    if self.giftsPage then
        self.giftsPage:dispose()
        self.giftsPage = nil
    end

    if self.normalShopPage then
        self.normalShopPage:dispose()
        self.normalShopPage = nil
    end

    if self.xiyouPage then
        self.xiyouPage:dispose()
        self.xiyouPage = nil
    end

    if self.zhenbaoPage then
        self.zhenbaoPage:dispose()
        self.zhenbaoPage = nil
    end
    self.currentLayer = nil
end

return NormalMallInfo