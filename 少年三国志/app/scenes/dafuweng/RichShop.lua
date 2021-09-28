local RichShop = class("RichShop",UFCCSModelLayer)
require("app.cfg.richman_shop_info")

function RichShop.create(startPosition,...)
    local layer = RichShop.new("ui_layout/dafuweng_RichShop.json",Colors.modelColor,startPosition,...)
    return layer
end

function RichShop:ctor(json,color,startPosition,...)
    self._listView = nil
    self.super.ctor(self,json,color,...)
    self:showAtCenter(true)
    self.startPt = startPosition
    self._color = color

    local note = self:getLabelByName("Label_listnote")
    note:createStroke(Colors.strokeBrown, 1)
    note:setText(G_lang:get("LANG_FU_SHOP"))

    self:registerBtnClickEvent("Button_close", function()
        -- self:close()
        self:showAnimation("small")
    end)
    self:registerBtnClickEvent("Button_close02", function()
        -- self:close()
        self:showAnimation("small")
    end)
end

function RichShop:onLayerEnter()
    self:closeAtReturn(true)
    -- require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_BUY, self._onRichBuyRsp, self)

    self:_initListView()
    self:showAnimation("big")
end

-- 缓动动画
function RichShop:showAnimation(dir)
    self._dir = dir
    local startScale = 1
    local endScale = 1
    local startPos = ccp(0,0)
    local endPos = ccp(0,0)
    local _size = self:getContentSize()
    local img = self:getImageViewByName("Image_bg")
    local imgPos = ccp(img:getPosition())
    if dir == "big" then
        startScale = 0.2
        endScale = 1
        startPos = self.startPt
        -- endPos = ccp(_size.width/2,_size.height/2)
        endPos = imgPos
    else
        startScale = 1
        endScale = 0.2
        -- startPos = ccp(_size.width/2,_size.height/2)
        startPos = imgPos
        endPos = self.startPt
    end
    
    local pt = self:convertToNodeSpace(self.startPt)
    
    img:setScale(startScale)
    img:setPosition(startPos)
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.2,endPos))
    array:addObject(CCScaleTo:create(0.2,endScale))
    local sequence = transition.sequence({CCSpawn:create(array),
    CCCallFunc:create(
        function()
            if self._dir == "small" then
                self:close()
            else
                self:setBackColor(self._color)
            end
        end),
    })
    img:runAction(sequence)
end

function RichShop:_initListView()
    if self._listView == nil then
        local panel = self:getPanelByName("Panel_awardList")
        self._listView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._listView:setCreateCellHandler(function ()
            return require("app.scenes.dafuweng.RichShopItem").new()
        end)
        self._listView:setUpdateCellHandler(function ( list, index, cell)
            local item = G_Me.richData:getShopList()
            local cur = item[index+1].id
            cell:updateView(cur,G_Me.richData:leftBuyTimes(cur))
        end)
        self._listView:initChildWithDataLength(#G_Me.richData:getShopList())
    end
end

function RichShop:_onRichBuyRsp(data)
    if data.ret == 1 then
        local info = richman_shop_info.get(data.id)
        local g = G_Goods.convert(info.type,info.value)
        G_MovingTip:showMovingTip(G_lang:get("LANG_FU_BUYSUCCESS",{name=g.name,num1=info.size*data.count,num2=info.score*data.count}))
        self._listView:refreshAllCell()
    end
end

function RichShop:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

return RichShop

