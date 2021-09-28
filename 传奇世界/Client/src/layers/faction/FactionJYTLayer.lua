local FactionJYTLayer = class("FactionJYTLayer", function() return cc.Layer:create() end )

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionJYTLayer:ctor(factionData, bg)
	
    local function fbBtnFunc()        
        --package.loaded["src/layers/faction/FactionFBLayer"] = nil
        local layer = require("src/layers/faction/FactionFBLayer").new(factionData, self)
        Manimation:transit(
		{
			ref = self,
			node = layer,
			curve = "-",
			sp = self:convertToNodeSpace(cc.p(display.cx, display.cy)),
			ep = self:convertToNodeSpace(cc.p(display.cx, display.cy)),
			swallow = true,
			zOrder = 100,
		})
	end
	local fbBtn = createMenuItem(self, path.."icon_fb.png", cc.p(93, 250), fbBtnFunc)
	createLabel(fbBtn, game.getStrByKey("faction_fb"), cc.p(83, 316), nil, 22, true)
    local t = createSprite(fbBtn, "res/mainui/subbtns/fbsy.png", cc.p(83, 390), cc.p(0.5, 0.5))
    t:setScale(0.9)

    local function fbBtnFunc2()        
	end

    local fbBtn2 = createMenuItem(self, path.."icon_no.png", cc.p(268, 250), fbBtnFunc2)
	createLabel(fbBtn2, game.getStrByKey("faction_notopen"), cc.p(83, 316), nil, 22, true, nil, nil, MColor.gray)
    t = createSprite(fbBtn2, path.."icon_no2.png", cc.p(83, 390), cc.p(0.5, 0.5))
    t:setScale(0.5)

    local function fbBtnFunc3()        
	end
    local fbBtn3 = createMenuItem(self, path.."icon_no.png", cc.p(443, 250), fbBtnFunc3)
	createLabel(fbBtn3, game.getStrByKey("faction_notopen"), cc.p(83, 316), nil, 22, true, nil, nil, MColor.gray)
    t = createSprite(fbBtn3, path.."icon_no2.png", cc.p(83, 390), cc.p(0.5, 0.5))
    t:setScale(0.5)

    local function fbBtnFunc4()        
	end
    local fbBtn4 = createMenuItem(self, path.."icon_no.png", cc.p(618, 250), fbBtnFunc4)
	createLabel(fbBtn4, game.getStrByKey("faction_notopen"), cc.p(83, 316), nil, 22, true, nil, nil, MColor.gray)
    t = createSprite(fbBtn4, path.."icon_no2.png", cc.p(83, 390), cc.p(0.5, 0.5))
    t:setScale(0.5)
end

return FactionJYTLayer