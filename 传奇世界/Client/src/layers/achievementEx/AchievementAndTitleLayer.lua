local AchievementAndTitleLayer = class("AchievementAndTitleLayer", function() return cc.Layer:create() end)

local path = "res/achievement/"
local pathCommon = "res/common/"

function AchievementAndTitleLayer:ctor(index)
	local bg, closeBtn =  createBgSprite(self, nil,nil,true)
	self.bg = bg
	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_ACHIEVEMENT_CLOSE)

	local baseNode = cc.Node:create()
	bg:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode
	local indexDefault = index or 1
	self.achieveData = {}

	local menuFunc = function(tag,sender)
		self.baseNode:removeAllChildren()
		if tag == 1 then
			-- if self.titleLayer then
			-- 	removeFromParent(self.titleLayer)
			-- 	self.titleLayer = nil
			-- end
			self.achieveLayer = require("src/layers/achievementEx/AchievementListLayer").new(self.bg, self, self.achieveData)
			self.baseNode:addChild(self.achieveLayer)
			self.achieveData = {}
		else
			-- if self.achieveLayer then
			-- 	removeFromParent(self.achieveLayer)
			-- 	self.achieveLayer = nil
			-- end
			self.titleLayer = require("src/layers/achievementEx/TitleListLayer").new(self.bg, self)
			self.baseNode:addChild(self.titleLayer)
		end
	end
	self.menuFunc = menuFunc

	-- local title = {
	-- 				{text=game.getStrByKey("achievement_tab_achieve"), pos=cc.p(600, 605)}, 
	-- 				{text=game.getStrByKey("achievement_tab_title"), pos=cc.p(755, 605)},
	-- 			}
	-- local tab_control = {}
	-- self.tab_control = tab_control
	-- for i=1,2 do 
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
	-- 	tab_control[i].menu_item:setPosition(title[i].pos)
	-- 	tab_control[i].callback = menuFunc
	-- 	tab_control[i].label = createLabel(tab_control[i].menu_item, title[i].text, getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 24, true)
	-- end
	-- creatTabControlMenu(bg, tab_control, indexDefault)
	-- menuFunc(indexDefault)

	local tab_achieve = game.getStrByKey("achievement_tab_achieve")
	local tab_title = game.getStrByKey("achievement_tab_title")

	local tabs = {}
	tabs[#tabs+1] = tab_achieve
	tabs[#tabs+1] = tab_title

	local TabControl = Mnode.createTabControl(
	{
		src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
		size = 22,
		titles = tabs,
		margins = 2,
		ori = "|",
		align = "r",
		side_title = true,
		cb = function(node, tag)
			menuFunc(tag)
			local title_label = bg:getChildByTag(12580)
			if title_label then title_label:setString(tabs[tag]) end
		end,
		selected = indexDefault,
	})

	Mnode.addChild(
	{
		parent = bg,
		child = TabControl,
		anchor = cc.p(0, 0.0),
		pos = cc.p(931, 460),
		zOrder = 200,
	})
	self.tab_control = TabControl
	G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(2), TOUCH_ACHIEVEMENT_TITLE)

    self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_ACHIEVEMENT)
		elseif event == "exit" then
		end
	end)
end

function AchievementAndTitleLayer:setDataForAchieve(mainType, subType, groupId)
	self.achieveData = {mainType=mainType, subType=subType, groupId=groupId}
	dump(self.achieveData)
	--self.menuFunc(1)
	self.tab_control:focus(1)

	-- self.tab_control:tabAtIdx(1):selected()
	-- self.tab_control:tabAtIdx(2):unselected()
end

return AchievementAndTitleLayer