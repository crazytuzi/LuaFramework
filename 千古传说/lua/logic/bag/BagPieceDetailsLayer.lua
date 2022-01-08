--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local BagPieceDetailsLayer = class("BagPieceDetailsLayer", BaseLayer)

function BagPieceDetailsLayer:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagPieceDetails")
end

function BagPieceDetailsLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.panel_root             = TFDirector:getChildByPath(ui, 'panel_root')
    self.panel_details_bg       = TFDirector:getChildByPath(ui, 'panel_details_bg')

	--左侧详情
	self.btn_node	 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_Num			= TFDirector:getChildByPath(ui, 'txt_number')
	self.txt_Name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_quality 		= TFDirector:getChildByPath(ui, 'img_quality')
    self.txt_description    = TFDirector:getChildByPath(ui, 'txt_description')
    self.img_res_bg    = TFDirector:getChildByPath(ui, 'img_res_bg')
	self.txt_price    = TFDirector:getChildByPath(ui, 'txt_price')


	--招募按钮
	self.btn_use 		= TFDirector:getChildByPath(ui, 'btn_use')
    self.btn_use.logic  = self
    self.btn_use:setTextureNormal("ui_new/smithy/btn_syn.png")

end

function BagPieceDetailsLayer:removeUI()
	self.super.removeUI(self)
end

function BagPieceDetailsLayer:setHomeLayer(homeLayer)
    self.homeLayer = homeLayer
end

function BagPieceDetailsLayer:refreshUI()
    if not self.id then
        return
    end

    local data = BagManager:getItemById(self.id)
    if not data then
        return
    end
    self.data = data
    
    self.img_res_bg:setVisible(false)

    local itemInfo = ItemData:objectByID(self.id)
    if itemInfo.type == EnumGameItemType.Piece and itemInfo.kind == 10 then
        local bookInfo  = MartialData:objectByID(itemInfo.usable)
        if bookInfo and bookInfo.copper > 0 then
            self.txt_price:setText(bookInfo.copper)
            self.img_res_bg:setVisible(true)
            if bookInfo.copper > MainPlayer:getCoin() then
                self.txt_price:setColor(ccc3(255,0,0))
            else
                self.txt_price:setColor(ccc3(255,255,255))
            end
        end
    end
    self:updateMergeButtonEnabled()
end

--设置物品数据
function BagPieceDetailsLayer:setData(data)
	if data == nil  then
		return false
	end

	self.id = data.id
    self.txt_Name:setText(data.name)
    self.img_icon:setTexture(data:GetTextrue())
    self.btn_node:setTextureNormal(GetBackgroundForGoods(data:getData()))
    self.txt_Num:setText(data.num)
    self.txt_description:setText(data.itemdata.details)

    local rewardItem = {itemid = data.id}
    Public:addPieceImg(self.img_icon,rewardItem,true)
	self:refreshUI()
end

function BagPieceDetailsLayer:isCanMerge(data)
    return BagManager:isCanMerge(data)
end

--[[
    更新合成按钮状态
]]
function BagPieceDetailsLayer:updateMergeButtonEnabled()
    local data = self.data
    local mergeable =  self:isCanMerge(data)

    if mergeable then
        self.btn_use:setTouchEnabled(true)
        self.btn_use:setGrayEnabled(false)
    else
        self.btn_use:setTouchEnabled(false)
        self.btn_use:setGrayEnabled(true)
    end
end

--合成按钮点击事件处理方法
function BagPieceDetailsLayer.mergeButtonClickHandle(sender)
    local self = sender.logic

    local itemInfo = ItemData:objectByID(self.id)
    if itemInfo.type == EnumGameItemType.Piece and itemInfo.kind == 10 then
        local bookInfo  = MartialData:objectByID(itemInfo.usable)
        if bookInfo and bookInfo.copper > 0 then
            local warningMsg = stringUtils.format(localizable.bagPieceDetailsLayer_text1,bookInfo.copper)
            CommonManager:showOperateSureLayer(
                function()
                    if bookInfo.copper > MainPlayer:getCoin() then
                        toastMessage(localizable.bagPieceDetailsLayer_no_coin)
                        return
                    end
                    self:requestMerge(self.id)
                end,
                nil,
                {
                    msg = warningMsg
                }
            )
            return
        end
    end

    self:requestMerge(self.id)
end

function BagPieceDetailsLayer:registerEvents()
    self.super.registerEvents(self)

    --按钮事件
    self.btn_use:addMEListener(TFWIDGET_CLICK, audioClickfun(self.mergeButtonClickHandle),1)


    -- TFDirector:addProto(s2c.MERGE_EQUIPMENT_RESULT, self, self.MergeResult)
end

--销毁方法
function BagPieceDetailsLayer:dispose()
    self.super.dispose(self)
end

function BagPieceDetailsLayer:removeEvents()
    --按钮事件
    self.btn_use:removeMEListener(TFWIDGET_CLICK)
    self.super.removeEvents(self)


    -- TFDirector:removeProto(s2c.MERGE_EQUIPMENT_RESULT, self, self.MergeResult)
end

--------------------------------网络相关处理---------------------------------------
--请求服务器合成装备
function BagPieceDetailsLayer:requestMerge(mergeTargetId)
    -- self.mergeTargetId = mergeTargetId
    -- local msg = {
    --     mergeTargetId,
    -- }
    -- showLoading()
    -- TFDirector:send(c2s.MERGE_EQUIPMENT,msg)

    BagManager:requestEquipMerge(mergeTargetId)
end


-- function BagPieceDetailsLayer:MergeResult(event)
--     local data = event.data
--     local goodId = data.instanceId
--     if goodId == nil then
--         print("server not put partner instance to me. i can not found it.",goodId)
--         return
--     end
--     print("goodId = ",goodId)
--     hideLoading()
--     -- self.summonSoulId = nil
--     -- TFDirector:dispatchGlobalEventWith(BagManager.SUMMON_PALADIN,unitInstance)
--     -- local layer = require("lua.logic.shop.GetHeroResultLayer"):new(unitInstance.id)
--     -- AlertManager:addLayer(layer, AlertManager.BLOCK)
--     -- AlertManager:show()
--     local goodsTemplate = ItemData:objectByID(goodId)
--     --     self.img_icon:setTexture(equip:GetTextrue())
--     -- self.img_quality:setTexture(GetColorIconByQuality(equip.quality))
--     __G__TRACKBACK__("sdasd")
-- end

return BagPieceDetailsLayer
