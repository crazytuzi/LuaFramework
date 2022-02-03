-- --------------------------------------------------------------------
-- 获得道具展示的 物品显示单列
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
ItemExhibitionList = ItemExhibitionList or class("ItemExhibitionList", function()
	return ccui.Widget:create()
end)

ItemExhibitionList.WIDTH = 119
ItemExhibitionList.HEIGHT = 119
function ItemExhibitionList:ctor()
    self.is_play = true
    self.size = cc.size(ItemExhibitionList.WIDTH , ItemExhibitionList.HEIGHT)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
	self:setCascadeOpacityEnabled(true)

    --self.item_name_label = createLabel(24, cc.c4b(0xff,0xe8,0xff,0xff),nil, self.size.width*0.5, -20,"", self,nil, cc.p(0.5, 0.5))

    self:registerEvent()
end

function ItemExhibitionList:registerEvent()
    self:registerScriptHandler(function(event)
        if "enter" == event then
            if self.is_play == true then
                self:setOpacity(0)
                self:setScale(2)
                local fadeIn = cc.FadeIn:create(0.1)
                local scaleTo = cc.ScaleTo:create(0.1, 1)
                self:runAction(cc.Spawn:create(fadeIn, scaleTo))
            end
        elseif "exit" == event then

        end 
    end)
end

--==============================--
--desc:设置数据,根据参数确定是物品,装备,还是伙伴
--time:2017-06-05 03:06:48
--@data:
--return 
--==============================-- 
function ItemExhibitionList:setData(data,extend)
    local show_type = data.show_type or MainuiConst.item_exhibition_type.item_type
    if show_type == MainuiConst.item_exhibition_type.item_type then
        self:showItemUI(data, extend)
    elseif show_type == MainuiConst.item_exhibition_type.partner_type then
        self:showPartnerUI(data,extend)
    else
        print(TI18N("ItemExhibitionList类型出错:%s"), tostring(show_type))
    end
end

--道具ui
function ItemExhibitionList:showItemUI(data, extend)
    local item_bid = data.bid or data.base_id
    if data == nil or item_bid == nil then return end
    local quality,name = nil, nil, nil

    local item_config = Config.ItemData.data_get_data(item_bid)
    if item_config == nil then return end

    local effect = item_config.effect or {}

    if item_config ~= nil then
        quality = item_config.quality
        name = item_config.name
        if not self.item then
            self.item = BackPackItem.new(true, true)
            if item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
                --神装特殊
                local item_vo = BackpackController:getModel():getBagItemById(BackPackConst.Bag_Code.EQUIPS, data.id)
                if item_vo then
                    self.item:addCallBack(function (  )
                        HeroController:getInstance():openEquipTips(true, item_vo)
                    end)
                else
                    self.item:setDefaultTip(true)
                end
            else
                local item_vo = BackpackController:getModel():getBackPackItemById(data.id)
                if item_config.type == BackPackConst.item_type.ARTIFACTCHIPS and item_vo then
                    -- 获取符文特殊处理，点击显示符文详细信息
                    self.item:addCallBack(function (  )
                        HeroController:getInstance():openArtifactTipsWindow(true, item_vo, PartnerConst.ArtifactTips.normal)
                    end)
                else
                    self.item:setDefaultTip(true)
                end
            end
            self.item:setPosition(0,0)
            self.item:setAnchorPoint(cc.p(0, 0))
            self:addChild(self.item)
        end
        if self.item then
            local is_effect = data.is_effect
            if extend and next(extend or {}) ~= nil and extend.is_backpack == true then
                local bid = item_bid
                local num = data.val  or data.num
                self.item:setBaseData(bid,num)
            else
                self.item:setData({base_id=item_bid,id=data.id, quantity=data.num,config=item_config,is_effect = data.is_effect or false},nil,is_effect)
            end

            if item_bid == Config.ItemData.data_assets_label2id.expedition_medal then
                if PlanesafkController and PlanesafkController:getInstance():getModel():isHolidayOpen() then
                    self.item:holidHeroExpeditTag(true, TI18N("限时提升"))
                else
                    self.item:holidHeroExpeditTag(false)
                end
            else
                self.item:holidHeroExpeditTag(false)
            end
        end
    end 
    if quality ~= nil and name ~= nil and self.item then
        self.item:setExtendDesc(true, name, BackPackConst.quality_color_id[quality])
        --[[if not tolua.isnull(self.item_name_label) then
            self.item_name_label:setTextColor(BackPackConst.quality_color[quality])
            self.item_name_label:setString(name)
            local name_len = StringUtil.getStrLen(name)
            if name_len > 14 then
                self.item_name_label:setBMFontSize(20)
            else
                self.item_name_label:setBMFontSize(24)
            end
        end--]]
    end
end

--伙伴ui
function ItemExhibitionList:showPartnerUI(data, extend)
    if not data.bid then return end
    local config = Config.PartnerData.data_partner_base[data.bid] 
    if not config then return end
    self.item = HeroExhibitionItem.new(1, true)
    self.item:addCallBack(function() 
        if data.rid and data.srv_id then
            HeroController:getInstance():openHeroTipsPanel(true, data)
        else
            HeroController:getInstance():openHeroTipsPanelByBid(data.bid)
        end
    end)
    self.item:setPosition(0,0)
    self.item:setAnchorPoint(cc.p(0, 0))
    self.item:setData(data)

    self:addChild(self.item)

    local quality = data.star or config.init_star 
    quality = quality - 1
    if quality > 5 then
        quality = 5
    end
    --[[if not tolua.isnull(self.item_name_label) then
        self.item_name_label:setTextColor(BackPackConst.quality_color[quality])
        self.item_name_label:setString(config.name)
    end--]]
end

function ItemExhibitionList:showName(bool)
    --self.item_name_label:setVisible(bool)
end


function ItemExhibitionList:getRootWnd()
    if not tolua.isnull(self.item) then
            
    end
end
function ItemExhibitionList:setNewNamePosition(x,y)
     --[[x = x or self.size.width*0.5
     y = y or -10
    self.item_name_label:setPosition(x,y)--]]
end
function ItemExhibitionList:DeleteMe()
    self:stopAllActions()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end