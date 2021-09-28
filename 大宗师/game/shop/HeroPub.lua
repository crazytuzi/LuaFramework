 --[[
 --
 -- @authors shan 
 -- @date    2014-06-18 16:44:59
 -- @version 
 --
 --]]

local HeroPub = class("HeroPub", function ( ... )
	return display.newNode("HeroPub")
end)


function HeroPub:ctor( ... )
	self:setNodeEventEnabled(true)

    local proxy = CCBProxy:create()
    local rootnode = rootnode or {}

    local node = CCBuilderReaderLoad("shop/shop_pub.ccbi", proxy, rootnode)
    local layer = tolua.cast(node,"CCLayer")
    self:addChild(layer)


    local function getOneHero(tag)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        RequestHelper.recrute({
            callback = function(data)
                dump(data)
            end,
            t = tag,
            n = 1
        })
    end

    rootnode["commonHeroBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, getOneHero)

    rootnode["nbHeroBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, getOneHero)

    rootnode["superNBHeroBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, getOneHero)


    rootnode["payBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(tag)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 

    end)
end

function HeroPub:onCloseCallback(f)
    self.callback = f
end




return HeroPub