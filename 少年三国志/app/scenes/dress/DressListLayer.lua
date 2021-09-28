
local DressListLayer = class("DressListLayer",UFCCSNormalLayer)
require("app.cfg.dress_info")
require("app.cfg.dress_compose_info")
require("app.cfg.dress_change_text")
require("app.cfg.skill_info")
require("app.cfg.knight_info")
local MergeEquipment = require("app.data.MergeEquipment")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local JumpBackCard = require("app.scenes.common.JumpBackCard")
local EffectNode = require "app.common.effects.EffectNode"

function DressListLayer.create( container,callback)   
    local layer = DressListLayer.new("ui_layout/dress_ListLayer.json",require("app.setting.Colors").modelColor) 
    layer:updateHandle(container,callback)
    return layer
end

function DressListLayer:ctor(...)
    self.super.ctor(self, ...)
    self._equipment = G_Me.dressData:getDressed() 
    self._clickState = true
    self._type = 1
    self._noEquipLabel = self:getLabelByName("Label_equipno")
    self._noEquipLabel:createStroke(Colors.strokeBrown, 1)
    self._noEquipLabel:setText(G_lang:get("LANG_DRESS_NODRESS"))
    self:_initScrollView()

    self:registerBtnClickEvent("Button_go", function()
         require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_SHI_ZHUANG, dress_info.indexOf(1).id,
          GlobalFunc.sceneToPack("app.scenes.dress.DressMainScene"))
    end)
end

function DressListLayer:onLayerEnter( )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ADD_DRESS, self.updateScrollView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CLEAR_DRESS, self.updateScrollView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self.updateScrollView, self)
    self:updataData()
    -- self:changeAnime()
    -- self:_heroComeAnime()
end

function DressListLayer:updateHandle(layer,callback )
    self._container = layer
    self._callback = callback
end

function DressListLayer:enterAnime( )
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_dressList")}, false, 0.2, 2, 100)
end

function DressListLayer:updataData( )
    if self._equipment then
        self._equipmentInfo = G_Me.dressData:getDressInfo(self._equipment.base_id) 
    else
        self._equipmentInfo = nil
    end
    self:updateScrollView()
end

function DressListLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function DressListLayer:setClickable(state)
    self._clickState = state
end

function DressListLayer:getChoosed()
    return self._equipment
end

function DressListLayer:setType(_type)
    if self._type ~= _type then
        self._type = _type
        if _type == 2 and not self._equipment then
            self._equipment = G_Me.dressData:getDressByBaseId(self:_getDressList()[1].id)
        end
        self._listView:reloadWithLength(#self:_getDressList())
    end
end

function DressListLayer:adapterLayer()
    -- self:adapterWidgetHeight("Panel_Click", "", "", 0, 0)
    -- self:adapterWidgetHeight("Panel_middle", "", "Panel_list", 0, 0)

    self:enterAnime()
end

function DressListLayer:_initScrollView()
    self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_dressList"), LISTVIEW_DIR_HORIZONTAL)
    -- self._listView:setSpaceBorder(20, 0)
    self._listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.dress.DressListCell").new(list, index)
    end)
    self._listView:setUpdateCellHandler(function ( list, index, cell)
        local data = self:_getDressList()
        -- local data = self._dressList
        if  index < #data then
           cell:updateData(data[index+1],self._equipment,function(equipment)
                if not self._clickState then
                    return
                end
                local container = self._container
                local callback = self._callback
                if equipment.id == -1 then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_DRESS_COMING"))
                elseif equipment.id == 0 then
                    self._equipment = nil
                    -- self:_heroChangeAnime()
                    callback(container,equipment.id)
                    self:updataData()
                else
                    local hasEquip = G_Me.dressData:getDressByBaseId(equipment.id)
                    if hasEquip then
                        self._equipment = hasEquip
                        -- self:_heroChangeAnime()
                        -- container:callback(equipment.id)
                        callback(container,equipment.id)
                    else
                        require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_SHI_ZHUANG, equipment.id,
                         GlobalFunc.sceneToPack("app.scenes.dress.DressMainScene"))
                    end
                    -- self:_heroChangeAnime()
                    self:updataData()
                end
            end) 
        end
    end)
    self._listView:initChildWithDataLength( #self:_getDressList())
    -- self._listView:initChildWithDataLength( #self._dressList)
end


function DressListLayer:updateScrollView()
    local length = #self:_getDressList()
    -- local length = #self._dressList
    if length == 0 then
        self:getPanelByName("Panel_equiplist"):setVisible(false)
        self:getPanelByName("Panel_epuipno"):setVisible(true)
    else
        self:getPanelByName("Panel_equiplist"):setVisible(true)
        self:getPanelByName("Panel_epuipno"):setVisible(false)
        -- self._listView:reloadWithLength(#self:_getDressList())
        self._listView:refreshAllCell()
        self:_refreshDress()
    end
end

function DressListLayer:_refreshDress()
    if self._equipment and G_Me.dressData:getDressById(self._equipment.id) == nil then
        self._equipment = G_Me.dressData:getDressByBaseId(self._equipment.base_id)
    end
end

function DressListLayer:_getDressList()
    -- return G_Me.dressData:getShowDressList() 
    if not self._dressListInit then 
        self:_initDressList1()
        self:_initDressList2()
        self._dressListInit = true
    end
    if self._type == 1 then 
        return self._dressList1
    else
        return self._dressList2
    end
end

local sortFunc = function(a,b)
    if a.id == 0 then
        return true
    end
    if b.id == 0 then
        return false
    end
    if a.id == -1 then
        return false
    end
    if b.id == -1 then
        return true
    end
    if G_Me.dressData:getDressed() and a.id == G_Me.dressData:getDressed().base_id then
        return true
    end
    if G_Me.dressData:getDressed() and b.id == G_Me.dressData:getDressed().base_id then
        return false
    end
    local has1 = G_Me.dressData:getDressByBaseId(a.id)
    local has2 = G_Me.dressData:getDressByBaseId(b.id)
    if has1 and not has2 then
        return true
    end
    if not has1 and  has2 then
        return false
    end

    return a.id > b.id
end

function DressListLayer:_initDressList1()
    self._dressList1 = G_Me.dressData:getShowDressList() 
    table.sort(self._dressList1, sortFunc)
end

function DressListLayer:_initDressList2()
    self._dressList2 = G_Me.dressData:getShowDressList2() 
    table.sort(self._dressList2, sortFunc)
end

return DressListLayer

