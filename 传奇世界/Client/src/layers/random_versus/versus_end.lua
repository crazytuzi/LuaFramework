local flag = false
return { new = function(params)
if flag then return end

local Mversus_net = require "src/layers/random_versus/versus_net"
---------------------------------------------
if params.award == nil then return end
local is_win = params.ranking == 1
---------------------------------------------
local get_award = function(id)
	local tAwardCfg = getConfigItemByKey("CompetitionDB", "q_id")
	--local tItems = unserialize(tAwardCfg[id].q_mat)
	local DropOp = require("src/config/DropAwardOp")
	local tItems = DropOp:dropItem_ex(tAwardCfg[id].q_mat)

	return tItems
end

local award_list = get_award(params.award)
--dump(award_list, "award_list")
local awards = {}

for k, v in pairs(award_list) do
	awards[#awards+1] =
	{
		id = v.q_item,
		num = v.q_count,
		showBind = true,
		isBind = v.bdlx == 1,
	}
end

local testData =
{
	award_tip = "拼战奖励(第" .. (is_win and "1" or "2") .. "名)",
	
	getCallBack = function()
		Mversus_net:get_reward()
	end,
	
	awards = awards,
}

local layer = Awards_Panel(testData)

local tmp_node = cc.Node:create()
tmp_node:registerScriptHandler(function(event)
	if event == "enter" then
		flag = true
	elseif event == "exit" then
		flag = false
	end
end)
layer:addChild(tmp_node)
----------------------------------------------------------------	
--return layer

end }

