local RankingView = class("RankingView", function () return cc.Layer:create() end)
local path = "res/ranking/"
function RankingView:ctor(index)
	local str = game.getStrByKey("title_Charm")
	if index == 2 then
		str = game.getStrByKey("title_ourSevRank")
	end
	local bg = createBgSprite(self, str)

	local menuFunc = function(tag,sender)
		-- package.loaded[ "src/layers/ranking/RankingLayer" ] = nil 
		package.loaded[ "src/layers/ranking/CharmRankingLayer" ] = nil 
		-- package.loaded[ "src/layers/ranking/RankingListLayer" ] = nil
		if tag == 1 then
			if self.rankLayer then
				removeFromParent(self.rankLayer)
				self.rankLayer = nil
			end			
			if not self.charmLayer then
				self.charmLayer = require("src/layers/ranking/CharmRankingLayer").new()
				bg:addChild(self.charmLayer)
				self.charmLayer:setPosition(cc.p(0,0))
				--self.charmLayer:setPosition(getCenterPos(bg))
			end
			self.charmLayer:setVisible(true)
		else
			if self.charmLayer then
				removeFromParent(self.charmLayer)
				self.charmLayer = nil
			end			
			if not self.rankLayer then
				self.rankLayer = require("src/layers/ranking/RankingLayer").new()
				bg:addChild(self.rankLayer)
				--self.rankLayer:setPosition(getCenterPos(bg))
			end
			self.rankLayer:setIsSelfServer(tag == 2, 0)
			self.rankLayer:setVisible(true)
		end
	end

	-- local title = {
	-- 				--{text=game.getStrByKey("title_Charm"), pos=cc.p(445, 605)}, 
	-- 				{text=game.getStrByKey("title_Charm"), pos=cc.p(600, 605)}, 
	-- 				{text=game.getStrByKey("title_ourSevRank"), pos=cc.p(755, 605)},
	-- 			}
	-- local tab_control = {}
	-- for i=1,2 do 
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
	-- 	tab_control[i].menu_item:setPosition(title[i].pos)
	-- 	tab_control[i].callback = menuFunc
	-- 	tab_control[i].label = createLabel(tab_control[i].menu_item, title[i].text, getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 24, true)
	-- end
	-- creatTabControlMenu(bg, tab_control, 1)
	menuFunc(index or 1)
end

return RankingView