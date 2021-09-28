return { new = function(params)
local MMenuButton = require "src/component/button/MenuButton"
---------------------------------------------------------------
local initiator = params.initiator
local versus_info = params.versus_info

local res = "res/layers/random_versus/"
local root = cc.Sprite:create("res/common/5.png")

local rootSize = root:getContentSize()

local leave = function()
	if root ~= nil then
		removeFromParent(root)
		root = nil
	end
end

-- 标题
local n_title = Mnode.createSprite(
{
	src = res .. "title.png",
	parent = root,
	pos = cc.p(rootSize.width/2, rootSize.height+10),
})

n_title:registerScriptHandler(function(event)
	if event == "enter" then
	elseif event == "exit" then
		local Mversus_net = require "src/layers/random_versus/versus_net"
		local versus_info = Mversus_net:get_versus_info()
		if versus_info then
			local Manimation = require "src/young/animation"
			Manimation:transit(
			{
				--ref = self,
				node = require("src/layers/random_versus/versus_view"):new(versus_info),
				sp = g_scrCenter,
				ep = g_scrCenter,
				--trend = "-",
				zOrder = 200,
				curve = "-",
				swallow = true,
			})
		else
			dump("没有进行中的拼战")
		end
	end
end)
---------------------------------------------------------------
local cur_player_info = versus_info.players[initiator]
local initiator_head = cc.Sprite:create(Mconvertor:roleHead(cur_player_info.school, cur_player_info.sex))

Mnode.addChild(
{
	parent = root,
	child = initiator_head,
	pos = cc.p(rootSize.width/2, rootSize.height/2+45),
})

Mnode.addChild(
{
	parent = root,
	
	child = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = initiator,
			size = 21,
			color = MColor.green,
		}),
		
		v = {
			src = " "..game.getStrByKey("towards")..game.getStrByKey("you")..game.getStrByKey("launch")..game.getStrByKey("le") .. game.getStrByKey("combat_forces") .. game.getStrByKey("competition"),
			size = 20,
			color = MColor.yellow,
		}
	}),
	
	pos = cc.p(rootSize.width/2, 120),
})

-- 应战按钮
local delayCount = 5
local actTag = 1
local acceptMenu, acceptBtn = MMenuButton.new(
{
	src = "res/component/button/50.png",
	label = {
		src = game.getStrByKey("accept_a_challenge").."(" .. delayCount .. ")",
		size = 25,
		color = MColor.lable_yellow,
	},
	
	cb = function(tag, node)
		node:setEnabled(false)
		leave()
	end,
	
	parent = root,
	pos = cc.p(rootSize.width/2, 46),
})

local DelayTime = cc.DelayTime:create(1)
local CallFunc = cc.CallFunc:create(function(node)
	delayCount = delayCount - 1
	--dump(delayCount, "delayCount")
	
	node:setLabel(
	{
		src = game.getStrByKey("accept_a_challenge").."(" .. delayCount .. ")",
		size = 25,
		color = MColor.lable_yellow,
	})
		
	if delayCount < 1 then
		node:stopActionByTag(actTag)
		node:setEnabled(false)
		leave()
	end
end)

local Sequence = cc.Sequence:create(DelayTime, CallFunc)
local action = cc.RepeatForever:create(Sequence)
action:setTag(actTag)
acceptBtn:runAction(action)
---------------------------------------------------------------	
return root
---------------------------------------------------------------
end }