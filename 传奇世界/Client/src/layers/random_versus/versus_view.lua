local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local Mversus_net = require "src/layers/random_versus/versus_net"
local res = "res/layers/random_versus/"

local time_to_string = function(time_value)
	if time_value <= 0 then
		return "00:00"
	end
	
	local minute = math.floor(time_value/60)
	local sec = time_value%60
	return (minute < 10 and ("0" .. minute) or minute) .. ":" .. (sec < 10 and ("0" .. sec) or sec)
end


local get_award = function(id)
	local tAwardCfg = getConfigItemByKey("CompetitionDB", "q_id")
	--dump(tAwardCfg, "tAwardCfg")
	local dropID = tonumber(tAwardCfg[id].q_mat)
	
	local DropOp = require("src/config/DropAwardOp")
	local awardsConfig = DropOp:dropItem_ex(dropID)
	
	return awardsConfig
	
	--[[
	local list = {}
	for k, v in pairs(awardsConfig) do
		list[tonumber(v.q_item)] = tonumber(v.q_count)
	end
		
	return list
	]]
end

new = function(self, info)
	local Mbaseboard = require "src/functional/baseboard"
	local MMenuButton = require "src/component/button/MenuButton"
	
	local root = Mbaseboard.new(
	{
		src = "res/common/bg/bg18.png",
		
		title = {src=game.getStrByKey("combat_forces")..game.getStrByKey("competition"), color = MColor.lable_yellow, size = 24,},
		
		close = {
			src = "res/component/button/x2.png",
			offset = { x = -15, y = 0 },
			
			handler = function(root)
				if root then removeFromParent(root)  root = nil end
			end,
		},
	})

	local rootSize = root:getContentSize()
		
	local bg = Mnode.createSprite(
	{
		src = "res/common/bg/bg18-12.png",
		parent = root,
		pos = cc.p(rootSize.width/2, rootSize.height/2-20),
	})
	
	local bg_size = bg:getContentSize()
	------------------------------------------------------
	-- 数据
	local rank = info.ranking
	local me = MRoleStruct:getAttr(ROLE_NAME)
	local other = rank[1] == me and rank[2] or rank[1]
	local me_info = info.players[me]
	me_info.result = MRoleStruct:getAttr(PLAYER_BATTLE)
	local other_info = info.players[other]
	local isMeLead = me_info.result >= other_info.result
	
	local left_center_x, right_center_x = 164, 629
	------------------------------------------------------
	-- 己方
	------------------------------------------------------
	-- 战斗力
	local Mnumber = require "src/component/number/view"
	local NumberBuilder = Mnumber.new("res/component/number/10.png")
	
	local power_bg = cc.Sprite:create("res/common/misc/powerbg_1.png")
	local power_bg_size = power_bg:getContentSize()
	local power = Mnode.createKVP(
	{
		k = cc.Sprite:create("res/common/misc/power_b.png"),
		v = NumberBuilder:create(me_info.result, -5),
		margin = 15,
	})

	power:setScale(0.55)
	Mnode.addChild(
	{
		parent = power_bg,
		child = power,
		pos = cc.p(power_bg_size.width/2, power_bg_size.height/2),
	})
	
	Mnode.addChild(
	{
		parent = bg,
		child = power_bg,
		pos = cc.p(left_center_x, 400),
	})
	
	-- 名字
	local str = me
	if isMeLead then
		str = str .. "(领先)"
	end
	
	Mnode.createLabel(
	{
		parent = bg,
		src = str,
		size = 20,
		color = MColor.lable_yellow,
		pos = cc.p(left_center_x, 360),
	})
	
	-- 角色模型
	local dress = MPackManager:getPack(MPackStruct.eDress)
	local weaponID = dress:protoId(MPackStruct.eWeapon)
	local clothID = dress:protoId(MPackStruct.eClothing)
	local wingID = G_WING_INFO.id
	local n_role = createRoleNode(MRoleStruct:getAttr(ROLE_SCHOOL), clothID, weaponID, wingID, 0.8, MRoleStruct:getAttr(PLAYER_SEX), nil)
	
	Mnode.addChild(
	{
		parent = bg,
		child = n_role,
		pos = cc.p(left_center_x, 200),
	})
	
	-- 进阶秘籍
	MMenuButton.new(
	{
		src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
		--effect = "b2s",
		
		label = {
			src = game.getStrByKey("advanced")..game.getStrByKey("cheats"),
			size = 25,
			color = MColor.yellow,
		},
		
		parent = bg,
		
		pos = cc.p(left_center_x, 50),
		
		cb = function(tag, node)
			node:setEnabled(false)
			removeFromParent(root)
			__GotoTarget({ ru = "a136" })
		end,
	})
	------------------------------------------------------
	-- 对手
	------------------------------------------------------
	-- 战斗力
	local power_bg = cc.Sprite:create("res/common/misc/powerbg_1.png")
	local power_bg_size = power_bg:getContentSize()
	local power = Mnode.createKVP(
	{
		k = cc.Sprite:create("res/common/misc/power_b.png"),
		v = NumberBuilder:create(tonumber(other_info.result) or 0, -5),
		margin = 15,
	})
	
	power:setScale(0.55)
	Mnode.addChild(
	{
		parent = power_bg,
		child = power,
		pos = cc.p(power_bg_size.width/2, power_bg_size.height/2),
	})
	
	Mnode.addChild(
	{
		parent = bg,
		child = power_bg,
		pos = cc.p(right_center_x, 400),
	})
	
	-- 名字
	local str = other
	if not isMeLead then
		str = str .. "(领先)"
	end
	
	Mnode.createLabel(
	{
		parent = bg,
		src = str,
		size = 20,
		color = MColor.lable_yellow,
		pos = cc.p(right_center_x, 360),
	})
	
	-- 角色模型
	local n_role = createRoleNode(other_info.school, other_info.clothID, other_info.weaponID, other_info.wingID, 0.8, other_info.sex, nil)
	
	Mnode.addChild(
	{
		parent = bg,
		child = n_role,
		pos = cc.p(right_center_x, 200),
	})
	
	-- 好友申请
	if not info.isFriend then
		MMenuButton.new(
		{
			src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
			--effect = "b2s",
			
			label = {
				src = game.getStrByKey("addas_friend"),
				size = 25,
				color = MColor.yellow,
			},
			
			parent = bg,
			
			pos = cc.p(right_center_x, 50),
			
			cb = function(tag, node)
				AddFriends(other)
				info.isFriend = true
				node:setEnabled(false)
			end,
		})
	end
	------------------------------------------------------
	-- 中间区域
	------------------------------------------------------
	-- 描述信息
	Mnode.createLabel(
	{
		parent = bg,
		src = game.getStrByKey("competition_rule_tips_1"),
		size = 20,
		color = MColor.lable_yellow,
		pos = cc.p(bg_size.width/2, 435),
	})
	
	-- 倒计时
	local n_countdown = Mnode.createLabel(
	{
		src = time_to_string(info.time_remaining),
		size = 20,
		color = MColor.white,
	})
	
	local refresh_countdown = function(remaining)
		if remaining then
			n_countdown:setString(remaining)
		end
	end
	
	Mnode.addChild(
	{
		parent = bg,
		child = n_countdown,
		pos = cc.p(bg_size.width/2, 400),
	})
	
	-- 战
	Mnode.createSprite(
	{
		src = res .. "zhan.png",
		parent = bg,
		pos = cc.p(bg_size.width/2, bg_size.height/2+15),
	})
	
	-- 第一名奖励
	local Mprop = require "src/layers/bag/prop"
	local award_list = get_award(info.award[1])
	local icons = {}
	
	for k, v in pairs(award_list) do
		icons[#icons+1] = Mprop.new(
		{
			protoId = v.q_item,
			num = v.q_count,
			cb = "tips",
			showBind = true,
			isBind = v.bdlx == 1,
		})
	end
	
	Mnode.addChild(
	{
		parent = bg,
		child = Mnode.combineNode(
		{
			nodes = icons,
			margins = 10,
		}),
		
		pos = cc.p(340, 100),
	})
	
	Mnode.createLabel(
	{
		parent = bg,
		src = "第一名奖励",
		size = 20,
		color = MColor.lable_yellow,
		pos = cc.p(340, 35),
	})
	
	-- 第二名奖励
	local Mprop = require "src/layers/bag/prop"
	local award_list = get_award(info.award[2])
	local icons = {}
	
	for k, v in pairs(award_list) do
		icons[#icons+1] = Mprop.new(
		{
			protoId = v.q_item,
			num = v.q_count,
			cb = "tips",
			showBind = true,
			isBind = v.bdlx == 1,
		})
	end
	
	Mnode.addChild(
	{
		parent = bg,
		child = Mnode.combineNode(
		{
			nodes = icons,
			margins = 10,
		}),
		
		pos = cc.p(462, 100),
	})
	
	Mnode.createLabel(
	{
		parent = bg,
		src = "第二名奖励",
		size = 20,
		color = MColor.lable_yellow,
		pos = cc.p(462, 35),
	})
	------------------------------------------------------
	local onEventArrive = function(Mversus_net, event, info)
		--dump(info, "versus_info")
		
		if event == "vs_begin" then
		
		elseif event == "vs_countdown" then
			refresh_countdown(time_to_string(info.time_remaining))
		elseif event == "vs_end" then
			if root then removeFromParent(root)  root = nil end
		elseif event == "vs_over" then
			
		else
			dump("未知事件", "拼战")
		end
	end
	------------------------------------------------------------------------------------------------------------
	root:registerScriptHandler(function(event)
		if event == "enter" then
			Mversus_net:register(onEventArrive)
		elseif event == "exit" then
			Mversus_net:unregister(onEventArrive)
		end
	end)
	------------------------------------------------------------------------------------------------------------
	return root
end