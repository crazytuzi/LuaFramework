
HpMpBoard = HpMpBoard or BaseClass()

HpMpBoard.HpBar = "res/xui/fight/hp_bar.png"
HpMpBoard.HpBg = "res/xui/fight/hp_bg.png"
HpMpBoard.InnerBar = "res/xui/fight/inner_bar.png"

local real_width = 60
local real_height = 2
local board_width = 66		-- 血条宽
local board_height = 2.4	-- 血条高

function HpMpBoard:__init()
	self.root_node = cc.Node:create()

	self.hp_board = XUI.CreateLoadingBar(0, board_height*5, HpMpBoard.HpBar, true, HpMpBoard.HpBg)
	self.hp_board:setScaleX(board_width / real_width)
	self.hp_board:setScaleY(board_height / real_height)
	self.root_node:addChild(self.hp_board)
end

function HpMpBoard:__delete()
	self.root_node = nil
end

function HpMpBoard:GetRootNode()
	return self.root_node
end

function HpMpBoard:SetHeight(height)
	self.root_node:setPosition(0, height)
end

function HpMpBoard:SetHpPercent(percent)
	if percent > 1 then percent = 1 end
	self.hp_board:setPercent(percent * 100)
end

function HpMpBoard:SetInnerPercent(percent)
	if percent > 1 then percent = 1 end
	if nil == self.inner_board then
		self.inner_board = XUI.CreateLoadingBar(0, board_height*3, HpMpBoard.InnerBar, true, HpMpBoard.HpBg)
		self.inner_board:setScaleX(board_width / real_width)
		self.inner_board:setScaleY(board_height / real_height)
		self.root_node:addChild(self.inner_board)
	end
	self.inner_board:setPercent(percent * 100)
end

function HpMpBoard:SetVisible(is_visible)
	self.root_node:setVisible(is_visible)
end
