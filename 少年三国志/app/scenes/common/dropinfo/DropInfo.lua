

local DropInfo = class ("DropInfo", UFCCSModelLayer)
local DropInfoTreasureFragment = require("app.scenes.common.dropinfo.views.DropInfoTreasureFragment")
local DropInfoTreasure = require("app.scenes.common.dropinfo.views.DropInfoTreasure")
local DropInfoEquipmentFragment = require("app.scenes.common.dropinfo.views.DropInfoEquipmentFragment")
local DropInfoEquipment = require("app.scenes.common.dropinfo.views.DropInfoEquipment")
local DropInfoItem = require("app.scenes.common.dropinfo.views.DropInfoItem")
local DropInfoKnight = require("app.scenes.common.dropinfo.views.DropInfoKnight")
local DropInfoKnightFragment = require("app.scenes.common.dropinfo.views.DropInfoKnightFragment")

local DropInfoOther = require("app.scenes.common.dropinfo.views.DropInfoOther")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"


local Colors = require("app.setting.Colors")

require("app.cfg.fragment_info")



function DropInfo.show(type, value, ...)
    local view = nil

    if type == G_Goods.TYPE_ITEM  then
        --道具
        view = DropInfoItem.create()
    elseif type ==G_Goods.TYPE_KNIGHT then
        --侠客
        GlobalFunc.showBaseInfo(G_Goods.TYPE_KNIGHT, value, ...)
        --view = DropInfoKnight.create()
    elseif type ==G_Goods.TYPE_EQUIPMENT then
        --装备    
        --view = DropInfoEquipment.create()
        GlobalFunc.showBaseInfo(G_Goods.TYPE_EQUIPMENT, value, ...)
    elseif type ==G_Goods.TYPE_TREASURE then
        --宝物 
        --view = DropInfoTreasure.create()
        GlobalFunc.showBaseInfo(G_Goods.TYPE_TREASURE, value, ...)
    elseif type ==G_Goods.TYPE_TREASURE_FRAGMENT then
        --宝物碎片
        GlobalFunc.showBaseInfo(G_Goods.TYPE_TREASURE_FRAGMENT, value, ...)
        --view = DropInfoTreasureFragment.create()
    elseif type == G_Goods.TYPE_PET then
        -- 战宠
        GlobalFunc.showBaseInfo(G_Goods.TYPE_PET, value, ...)
    elseif type ==G_Goods.TYPE_FRAGMENT then
        --侠客|装备|战宠碎片
        GlobalFunc.showBaseInfo(G_Goods.TYPE_FRAGMENT, value, ...)
        -- local goods = fragment_info.get(value)
        -- if goods.fragment_type == 1 then
        --     --侠客碎片
        --     --view = DropInfoKnightFragment.create()
        --     GlobalFunc.showBaseInfo(G_Goods.TYPE_FRAGMENT, value)
        -- else
        --     --装备碎片
        --     view = DropInfoEquipmentFragment.create()
        -- end
    elseif type == G_Goods.TYPE_HERO_SOUL then
        -- 将灵
        GlobalFunc.showBaseInfo(G_Goods.TYPE_HERO_SOUL, value, ...)
    else 
        --if type ==G_Goods.TYPE_DROP
        view = DropInfoOther.create()
    end
    
    if view ~= nil then
        local node = DropInfo.new()
        -- uf_notifyLayer:getModelNode():addChild(node)
        node.bgBlack = CCLayerColor:create(Colors.modelColor, display.width,display.height)
        uf_sceneManager:getCurScene():addChild(node.bgBlack, 2)
        uf_sceneManager:getCurScene():addChild(node, 2)
        --node:closeAtReturn(true)
        --黑色底图
        -- node:addChild(node.bgBlack)  

        node:setClickClose(true)

        view:setData(type, value)
        view:setCloseCallback(function()  
            node:doClose()
        end)
        view:setToggleCallback(function(continueImageY)
            if node and node._showContinue then  
                node:_showContinue(continueImageY)
            end
        end)

        --设置一下位置
        view:setPosition(view:getInitPosition())
        node:addChild(view)

        --创建continue图片
        node:_showContinue(view:getInitPosition().y)
        
    end
end
function DropInfo:_showContinue(continueImageY)
    if self._continueImage == nil then
        self._continueImage = ImageView:create()
        self._continueImage:loadTexture( G_Path.getTextPath("dianjijixu.png")) 
        self:addChild( self._continueImage)
        EffectSingleMoving.run(self._continueImage, "smoving_wait", nil , {position = true} )

    end

    self._continueImage:setPosition(ccp(display.cx, continueImageY - 25))

end

function DropInfo:onLayerEnter( ... )
    self:registerKeypadEvent(true, false)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

function DropInfo:onBackKeyEvent( ... )
    self:doClose()
    return true
end

function DropInfo:onClickClose( ... )
    self:doClose()
    return true
end

function DropInfo:doClose( ... )
    if self.bgBlack ~= nil then
        -- self.bgBlack:setVisible(false)
        self.bgBlack:removeFromParentAndCleanup(true)
        self.bgBlack = nil

        self:animationToClose()
    end    
end

return DropInfo