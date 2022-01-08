--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local BagPropDetailsLayer = class("BagPropDetailsLayer", BaseLayer)

function BagPropDetailsLayer:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagPropDetails")
end

function BagPropDetailsLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.panel_root             = TFDirector:getChildByPath(ui, 'panel_root')
    self.panel_details_bg       = TFDirector:getChildByPath(ui, 'panel_details_bg')

	--左侧详情
	self.btn_icon	 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_Num			= TFDirector:getChildByPath(ui, 'txt_number')
	self.txt_Name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_quality 		= TFDirector:getChildByPath(ui, 'img_quality')
	self.txt_description    = TFDirector:getChildByPath(ui, 'txt_description')


	--招募按钮
	self.btn_use 		= TFDirector:getChildByPath(ui, 'btn_use')
    self.btn_use.logic  = self
end

function BagPropDetailsLayer:setHomeLayer(homeLayer)
    self.homeLayer = homeLayer
end

function BagPropDetailsLayer:removeUI()
	self.super.removeUI(self)

	self.panel_root = nil
	self.btn_icon = nil
	self.img_icon = nil
	self.txt_Num = nil
	self.txt_Name = nil
	self.img_quality = nil
	self.txt_description = nil
	self.btn_use = nil
    self.panel_details_bg = nil
	self.createNewHoldGoodsCallback = nil
    self.holdGoodsNumberChangedCallback = nil
    self.deleteHoldGoodsCallback = nil
end

function BagPropDetailsLayer:refreshUI()
end

--设置物品数据
function BagPropDetailsLayer:setData(data)
    self.toolNum = 0

	if data == nil  then
        self.panel_details_bg:setVisible(false)
		return false
	end

    self.toolNum = data.num

    self.panel_details_bg:setVisible(true)
	self.id = data.id
	self.txt_Name:setText(data.name)
	self.img_icon:setTexture(data:GetTextrue())
	self.btn_icon:setTextureNormal(GetColorIconByQuality(data.quality))
	self.txt_Num:setText(data.num)
	self.txt_description:setText(data.itemdata.details)

    if data.itemdata.usable == 0 then
        self.type = 0
    else
        self.type = 1
    end

end

--使用按钮点击事件处理方法
function BagPropDetailsLayer.useButtonClickHandle(sender)
    local self = sender.logic
    self:requestUse()
end

function BagPropDetailsLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_use:addMEListener(TFWIDGET_CLICK, audioClickfun(self.useButtonClickHandle),1)
    self.btn_use:addMEListener(TFWIDGET_TOUCHBEGAN, self.IconBtnTouchBeganHandle)
    self.btn_use:addMEListener(TFWIDGET_TOUCHMOVED, self.IconBtnTouchMovedHandle)
    self.btn_use:addMEListener(TFWIDGET_TOUCHENDED, self.IconBtnTouchEndedHandle)
end

--销毁方法
function BagPropDetailsLayer:dispose()
    self.super.dispose(self)
end

function BagPropDetailsLayer:removeEvents()
    self.btn_use:removeMEListener(TFWIDGET_CLICK)
    self.super.removeEvents(self)
end

--------------------------------网络相关处理---------------------------------------
--请求服务器打开礼包
function BagPropDetailsLayer:requestUse()
    -- 小喇叭
    -- if 30002 == self.id then
    --     AlertManager:close()
    --     ChatManager:showChatLayer()

    -- -- 精炼石
    -- elseif 30021 == self.id then
    --     AlertManager:close()
    --     EquipmentManager:OpenSmithyMainLaye()

    -- -- 招财神符
    -- elseif 30003 == self.id then
    --     self:showExchange(self.id)

    -- -- 真气丹
    -- -- 初级
    -- elseif 30022 == self.id then
    --     self:showExchange(self.id)

    -- -- 中级
    -- elseif 30023 == self.id then
    --     self:showExchange(self.id)

    -- -- 高级
    -- elseif 30024 == self.id then
    --     self:showExchange(self.id)
    
    

    -- else
        -- showLoading()
        BagManager:useItem(self.id)
    -- end
end


function BagPropDetailsLayer.IconBtnTouchBeganHandle(sender)

    local self = sender.logic

    local ItemId = self.id
    if 30022 == ItemId or 30023 == ItemId or 30024 == ItemId or 30003 == ItemId then
        return
    end
    
    if self.type == 1 then
        local times = 1;
        local function onLongTouch()
            if self.toolNum <= 0 then
                return;
            end

            print("BagPropDetailsLayer.IconBtnTouchBeganHandle")

            self.isAdd = true;

            self.useButtonClickHandle(sender)

            TFDirector:removeTimer(self.longAddTouchTimerId);

            self.longAddTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch);

            times = times + 1;
        end
        self.longAddTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch); 
    end
end

function BagPropDetailsLayer.IconBtnTouchMovedHandle(sender, pos, seekPos)
    local self = sender.logic
    local rect = sender:boundingBox()
    local size = rect.size
    local point = rect.origin
    local anPos = sender:getAnchorPoint()
    point = self:getParent():convertToWorldSpace(point)

    local minx = point.x 
    local maxx = point.x + size.width
    local miny = point.y
    local maxy = point.y + size.height
    if pos.x < minx or pos.x > maxx or pos.y < miny or pos.y > maxy then
        if self.longAddTouchTimerId then
            TFDirector:removeTimer(self.longAddTouchTimerId);
            self.longAddTouchTimerId = nil;
        end
    end

end

function BagPropDetailsLayer.IconBtnTouchEndedHandle(sender)
    local self = sender.logic;
    if self.longAddTouchTimerId then
        TFDirector:removeTimer(self.longAddTouchTimerId);
        self.longAddTouchTimerId = nil;
    end

    if self.isAdd then
        self.useButtonClickHandle(sender)
    end

    self.isAdd = false;
end

-- 物品从被使用完
function BagPropDetailsLayer:endLongPressUseGoods()
    if self.longAddTouchTimerId then
        TFDirector:removeTimer(self.longAddTouchTimerId);
        self.longAddTouchTimerId = nil;
    end
end

function BagPropDetailsLayer:showExchange(ItemId)

    -- 招财神符
    if 30003 == ItemId then
        local item = ItemData:objectByID( ItemId );
        local num = BagManager:getItemNumById( ItemId );
        if num > 0 then
            local layer = CommonManager:showOperateSureLayer(
                    function()
                        BagManager:useBatchItem( item.id,num )
                    end,
                    nil,
                    {
                    uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                    --      title = item.name .. num .. "个",
                    --msg = "可兑换" .. item.usable * num
                    title = item.name .. stringUtils.format(localizable.bagPropDetailsLayer_number,num),
                    msg = stringUtils.format(localizable.bagPropDetailsLayer_exchange ,item.usable * num)
                    }
            )
            local img1 = TFDirector:getChildByPath(layer, 'img1');
            local img2 = TFDirector:getChildByPath(layer, 'img2');
  
            img1:setTexture(item:GetPath());
            img2:setTexture(GetResourceIconForGeneralHead(HeadResType.COIN))
            return;
        end
        
    -- 真气丹
    -- 初级 -- 中级 -- 高级
    elseif 30022 == ItemId or 30023 == ItemId or 30024 == ItemId then

        local item = ItemData:objectByID( ItemId );
        local num = BagManager:getItemNumById( ItemId );
        if num > 0 then
            local layer = CommonManager:showOperateSureLayer(
                    function()
                        BagManager:useBatchItem( item.id,num )
                    end,
                    nil,
                    {
                    uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                    title = item.name .. stringUtils.format(localizable.bagPropDetailsLayer_number,num),
                    msg = stringUtils.format(localizable.bagPropDetailsLayer_exchange ,item.usable * num)

                    }
            )
            local img1 = TFDirector:getChildByPath(layer, 'img1');
            local img2 = TFDirector:getChildByPath(layer, 'img2');
  
            img1:setTexture(item:GetPath());
            img2:setTexture(GetResourceIconForGeneralHead(EnumDropType.GENUINE_QI))
            return;
        end
    end
end

return BagPropDetailsLayer
