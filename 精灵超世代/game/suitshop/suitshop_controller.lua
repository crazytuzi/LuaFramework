--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 
-- @DateTime:    2019-04-23 09:41:27
-- *******************************
SuitShopController = SuitShopController or BaseClass(BaseController)

function SuitShopController:config()
    self.model = SuitShopModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function SuitShopController:getModel()
    return self.model
end

function SuitShopController:registerEvents()

end

function SuitShopController:registerProtocals()
	-- self:RegisterProtocal(13030, "handle13030")

end
function SuitShopController:send13030()
    -- self:SendProtocal(13030, {})
end

--打开神装商店界面
function SuitShopController:openSuitShopMainView(status)
    if status == true then
        if not self.suit_shop_view then
            self.suit_shop_view = SuitShopMainWindow.New()
        end
        self.suit_shop_view:open()
    else
        if self.suit_shop_view then 
            self.suit_shop_view:close()
            self.suit_shop_view = nil
        end
    end
end

function SuitShopController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

