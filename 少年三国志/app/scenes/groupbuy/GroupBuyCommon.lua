-- GroupBuyCommon.lua
local GroupBuyCommon = {}

local GroupBuyConst = require("app.const.GroupBuyConst")
local CheckFunc     = require("app.scenes.common.CheckFunc")

function GroupBuyCommon.getHandler() return G_HandlersManager.groupBuyHandler end
function GroupBuyCommon.getData() return G_Me.groupBuyData end

-- 计算进度条的比例
function GroupBuyCommon.calProgressRatio(item, nowBuyNum)
	local pre = 0
	if nowBuyNum <= item.buyer_num_1 and item.buyer_num_1 ~= 0 then
		pre = 25 * nowBuyNum / item.buyer_num_1
	elseif nowBuyNum <= item.buyer_num_2 and item.buyer_num_2 - item.buyer_num_1 ~= 0 then
		pre = 25 * (nowBuyNum - item.buyer_num_1) / (item.buyer_num_2 - item.buyer_num_1) + 25
	elseif nowBuyNum <= item.buyer_num_3 and item.buyer_num_3 - item.buyer_num_2 ~= 0 then
		pre = 25 * (nowBuyNum - item.buyer_num_2) / (item.buyer_num_3 - item.buyer_num_2) + 50
	elseif nowBuyNum <= item.buyer_num_4 and item.buyer_num_4 - item.buyer_num_3 ~= 0 then
		pre = 25 * (nowBuyNum - item.buyer_num_3) / (item.buyer_num_4 - item.buyer_num_3) + 75
	elseif nowBuyNum > item.buyer_num_4 then
		pre = 100
	end
	return pre
end

-- 排行榜，得到对应的奖励信息
function GroupBuyCommon.getAward(_rank, _type)
	for i = 1 , wheel_prize_info.getLength() do 
		local info = wheel_prize_info.indexOf(i)
		if info.type == _type and info.event_type == GroupBuyConst.RANK_AWARD_TEMP_ID and _rank <= info.lower_rank and _rank >= info.upper_rank then
			return info
		end
	end
	return nil
end

function GroupBuyCommon.showGetItemLayer(rewards)
	local awards = {}
		for i, v in ipairs(rewards) do
			if v.type ~= 0 then
				table.insert(awards, v)
			end
		end
	local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
	uf_sceneManager:getCurScene():addChild(layer, 1000)
end

-- 左对齐的设置
function GroupBuyCommon.setKeyValueLabelByLeft(keyLabel, valueLabel, kLangStr, vText)
	keyLabel:setText(G_lang:get(kLangStr) or "")
	keyLabel:createStroke(Colors.strokeBrown, 1)
	valueLabel:setText(vText or "")
	valueLabel:createStroke(Colors.strokeBrown, 1)
	valueLabel:setPositionX(keyLabel:getContentSize().width)
end

-- 右对齐的设置
function GroupBuyCommon.setKeyValueLabelByRight(keyLabel, valueLabel, kLangStr, vText)
	keyLabel:setText(G_lang:get(kLangStr) or "")
	keyLabel:createStroke(Colors.strokeBrown, 1)
	valueLabel:setText(vText or "")
	valueLabel:createStroke(Colors.strokeBrown, 1)
	keyLabel:setPositionX(-valueLabel:getContentSize().width)
end

function GroupBuyCommon.setKeyValueLabelByUpDown(keyLabel, valueLabel, kLangStr, vText)
	keyLabel:setText(G_lang:get(kLangStr) or "")
	keyLabel:createStroke(Colors.strokeBrown, 1)
	valueLabel:setText(vText or "")
	valueLabel:createStroke(Colors.strokeBrown, 1)
	valueLabel:setPositionY(keyLabel:getPositionY() - 40)
end

function GroupBuyCommon.checkBagisFull(type_, size)
	if type(type_) ~= "number" or type(size) ~= "number" then return false end
	if CheckFunc.checkDiffByType(type_, type) then
        return true
    end
    return false
end

return GroupBuyCommon