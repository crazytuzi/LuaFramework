local EmpireLayer = class("EmpireLayer", function() return cc.Layer:create() end)
local path = "res/empire/"

function EmpireLayer:ctor(tabIndex)
	tabIndex = tabIndex or 1
	local title = game.getStrByKey("title_ZZZB")
	if tabIndex == 1 then
		title = game.getStrByKey("title_LDZD")
	elseif tabIndex == 3 then
		title = game.getStrByKey("title_SCZB")
	end

	local baseNode = cc.Node:create()
	baseNode:setContentSize(cc.size(960,640))
	baseNode:setPosition(cc.p((g_scrSize.width-960)/2,(g_scrSize.height-640)/2))
	self:addChild(baseNode)	

	local Mbaseboard = require "src/functional/baseboard"
	local bg = Mbaseboard.new(
	{
		src = "res/common/bg/bg18.png",
		close = {
			src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
			offset = { x = -8, y = 4 },
			handler = function() removeFromParent(self) end,
		},
		title = {
			src = title,
			size = 25,
			color = MColor.lable_yellow,
			offset = { y = -25 },
		}
	})

	self.bg = bg
	bg:setPosition(cc.p(480, 320))
	baseNode:addChild(bg)
	self.baseNode = baseNode

    -- package.loaded["src/layers/empire/AreaNode"] = nil
    -- package.loaded["src/layers/empire/BiQiNode"] = nil
    -- package.loaded["src/layers/empire/BiQiEmpireRank"] = nil
    -- package.loaded["src/layers/shaWar/shaWarNode"] = nil
    -- package.loaded["src/layers/shaWar/ShaWarContributionRank"] = nil

	if tabIndex and tabIndex == 1 then
		self:createAreaView()
	elseif tabIndex and tabIndex == 2 then
		self:createBiQiView()
	elseif tabIndex and tabIndex == 3 then
		self:createShaWarView()
	else
		self:createAreaView()
	end
	registerOutsideCloseFunc(bg , function() removeFromParent(self) end, true)
end

function EmpireLayer:createAreaView()
	self.contentNode = require("src/layers/empire/AreaNode").new(self.baseNode:getContentSize())
	if self.baseNode then
		self.baseNode:addChild(self.contentNode)
		self.contentNode:setPosition(cc.p(0, 0))
	end 
end

function EmpireLayer:createBiQiView()
	self.contentNode = require("src/layers/empire/BiQiNode").new(self.baseNode:getContentSize())
	if self.baseNode then
		self.baseNode:addChild(self.contentNode)
		self.contentNode:setPosition(cc.p(0, 0))
	end 
end

function EmpireLayer:createShaWarView()
	self.contentNode = require("src/layers/shaWar/shaWarNode").new(self.baseNode:getContentSize())
	if self.baseNode then
		self.baseNode:addChild(self.contentNode)
		self.contentNode:setPosition(cc.p(0, 0))
	end 
end

return EmpireLayer