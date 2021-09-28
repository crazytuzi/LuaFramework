local MarriageLayer = class("MarriageLayer", function () return cc.Layer:create() end )

function MarriageLayer:ctor()
    local bg = createSprite(self,"res/weddingSystem/yuelaobg.png",cc.p(display.cx,display.cy),cc.p(0.5,0.5))
    self:refreshWithTab(bg,{})
end

function MarriageLayer:refreshWithTab(bg__,config)
    -- write menuitem directly here do not use this complex hardly use thing 
    --[[
	local ori = config.ori or "|"

    local tabs_ori = { game.getStrByKey("wdsys_banlv"), game.getStrByKey("wdsys_xiaowu") }

    local tabs = {}
    for k,v in pairs(tabs_ori) do
        table.insert(tabs,1,v)
    end
	
	local selected = 1
	
	local arrows = cc.MenuItemImage:create("res/group/arrows/9.png", "")
	
	local TabControl = Mnode.createTabControl(
	{
		src = {"res/component/TabControl/9.png", "res/component/TabControl/10.png"},
		color = {MColor.lable_yellow, MColor.lable_yellow},
		size = 25,
		titles = tabs,
		margins = 5,
		ori = ori,
		cb = function(node, tag)
			local x, y = node:getPosition()
			local size = node:getContentSize()
			arrows:setPosition(x+size.width/2+6, y)
			self:refresh(tag)
		end,
		selected = selected,
	})
	
	TabControl:addChild(arrows)
    TabControl:setPosition(cc.p(display.cx,display.cy))
    bg__:addChild(TabControl)
    ]]
end

function MarriageLayer:refresh()
end

return MarriageLayer