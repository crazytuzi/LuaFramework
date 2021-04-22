
--[[	
	文件名称：QUIDialogStormArenaHelp.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogStormArenaHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogStormArenaHelp = class("QUIDialogStormArenaHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
--初始化
function QUIDialogStormArenaHelp:ctor(options)
	QUIDialogStormArenaHelp.super.ctor(self,ccbFile,callBacks,options)
end

function QUIDialogStormArenaHelp:initData(  )
	-- body
	local stormArenaInfo = remote.stormArena:getStormArenaInfo()
	local data = {}
	table.insert(data,{oType = "describe", info = {
		helpType = "storm_arena_shuoming_1",
		lineSpacing = 0,
		paramArr = {remote.user.stormTopRank, stormArenaInfo.rank or 10001},
		}})
	table.insert(data,{oType = "empty", height = 10})
	table.insert(data,{oType = "line"})
	table.insert(data,{oType = "empty", height = 10})
	
	table.insert(data,{oType = "describe", info = {
		helpType = "storm_arena_shuoming_2",
		}})
	local index = #data
	local myRankAward = nil
	local unionRankAward = nil
	local curRank = 10000

	local rankAwards = self:getStormArenaAwards(remote.user.level)
	table.insert(data, {oType = "title", info = {name = "本服排行奖励:", pos = ccp(30, -10), size = CCSizeMake(720, 35)}})

	for _, tempData in  pairs(rankAwards) do
		local awardStr = tempData.awards or ""
		local awardsStrArr = string.split(awardStr, ";")
		local awardsArr = {}
		for k, v in pairs(awardsStrArr) do
			local tempAwards = string.split(v, "^")
			if tempAwards and #tempAwards == 2 then
				table.insert(awardsArr, {id = tempAwards[1],count = tempAwards[2]})
			end 
		end
		local temp = {}
		temp.awardsArr = awardsArr

		local rankStr

		if tempData.rank == tempData.rank_2 then
			if not myRankAward and curRank == tempData.rank then
				myRankAward = awardsArr
			end
			rankStr = string.format("第%s名:", tempData.rank)
		else
			if not myRankAward and curRank >= tempData.rank and curRank <= tempData.rank_2 then
				myRankAward = awardsArr
			end
			rankStr = string.format("第%s-%s名:", tempData.rank,tempData.rank_2)
		end
		
		temp.rankStr = rankStr
		temp.awardOffsetX = 20
		table.insert(data, {oType = "award", info = temp})
	end

	table.insert(data,{oType = "describe", info = {
		helpType = "storm_arena_shuoming_4"
		}})
	table.insert(data,{oType = "describe", info = {
		helpType = "storm_arena_shuoming_5"
		}})
	local rankRewards = QStaticDatabase:sharedDatabase():getRankAwardsByType("fengbao_quanfu", remote.user.level)
	local heads = QStaticDatabase:sharedDatabase():getFrames(remote.headProp.FRAME_STORM_TYPE)
	local preRank = 1
	for _, reward in ipairs(rankRewards) do
		local head = nil
		for _,v in pairs(heads) do
			local condition = string.split(v.condition, ",")
			if tonumber(condition[1]) and reward.rank >= tonumber(condition[1]) and tonumber(condition[2]) and reward.rank <= tonumber(condition[2]) then
				head = v
				break
			end
		end
		local rankStr = reward.rank
		if preRank < reward.rank then
			rankStr = preRank.."-"..reward.rank
		end
		preRank = reward.rank + 1
		table.insert(data,{oType = "rank", info = {reward = reward, head = head, rankStr = rankStr}})
	end
	self._data = data

end

function QUIDialogStormArenaHelp:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	if itemData.oType == "describe" then
	            		item = QUIWidgetHelpDescribe.new()
	            	elseif itemData.oType == "title" then
	            		item = QUIWidgetBaseHelpTitle.new()
	            	elseif itemData.oType == "award" then
	            		item = QUIWidgetBaseHelpAward.new()
	            	elseif itemData.oType == "line" then
	            		item = QUIWidgetBaseHelpLine.new()
	            	elseif itemData.oType == "empty" then
	            		item = QUIWidgetQlistviewItem.new()
            		elseif itemData.oType == "rank" then
            			item = self:getRankNode()
	            	end
	            	isCacheNode = false
	            end
	            if itemData.oType == "empty" then
	            	item:setContentSize(CCSizeMake(0, itemData.height))
	            elseif itemData.oType == "describe" then
	            	item:setInfo(itemData.info or {}, itemData.customStr)
	            else
	            	item:setInfo(itemData.info)
	            end
	           	info.tag = itemData.oType
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 15,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end

function QUIDialogStormArenaHelp:getRankNode()
	local node = CCNode:create()
	node.setInfo = function (n,info)
		-- n:removeAllChildren()
		if n.bgSp == nil then
			n.bgSp = CCSprite:create("ui/GloryTower/G_kuangtiao.png")
			n.bgSp:setPosition(792/2 + 7, -30)
			n:addChild(n.bgSp)
		end

		if n.tf_name == nil then
			n.tf_name = CCLabelTTF:create("", global.font_default, 20)
			n.tf_name:setColor(ccc3(253,237,195))
			n.tf_name:setAnchorPoint(ccp(0,0.5))
			n.tf_name:setPosition(15, -30)
			n:addChild(n.tf_name)
		end
		n.tf_name:setString("第"..info.rankStr.."名:")

		if n.sp_head ~= nil then
			n.sp_head:removeFromParent()
			n.sp_head = nil
		end
		if n.sp_head_bottom ~= nil then
			n.sp_head_bottom:removeFromParent()
			n.sp_head_bottom = nil
		end
		if info.head ~= nil then
			n.sp_head = CCSprite:create(info.head.icon)
			n.sp_head:setScale(0.35)
			n.sp_head:setPosition(n.tf_name:getContentSize().width + n.tf_name:getPositionX()+50, -25)
			n:addChild(n.sp_head)
		end
		if info.head ~= nil then
			n.sp_head_bottom = CCSprite:create(info.head.icon_bottom)
			n.sp_head_bottom:setScale(0.35)
			n.sp_head_bottom:setPosition(n.tf_name:getContentSize().width + n.tf_name:getPositionX()+50, -25)
			n:addChild(n.sp_head_bottom)
		end
		if n.node_item == nil then
			n.node_item = CCNode:create()
			n:addChild(n.node_item)
		end
		local width = n.tf_name:getContentSize().width
		local posX = n.tf_name:getPositionX() + 100
		if n.sp_head then
			width = n.sp_head:getContentSize().width
			posX = n.sp_head:getContentSize().width
		end
		n.node_item:setPosition(width * 0.35 + posX + 50, -30)

		if info.reward ~= nil then
			n.node_item:removeAllChildren()
			local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(info.reward.lucky_draw)
			for index,award in ipairs(awards) do
				local itembox = QUIWidgetItemsBox.new()
				itembox:setGoodsInfo(award.id, award.typeName, 0)
				local posX = (index-1) * 400 * 0.35
				itembox:setPositionX(posX)
				itembox:setScale(0.35)
				n.node_item:addChild(itembox)

				local tf_count = CCLabelTTF:create("X "..award.count, global.font_default, 20)
				tf_count:setAnchorPoint(ccp(0,0.5))
				tf_count:setPosition(posX + 20, -6)
				n.node_item:addChild(tf_count)
			end
		end
	end
	node:setContentSize(CCSize(792, 60))
	return node
end

function QUIDialogStormArenaHelp:getStormMoneyOutputByRank( rank , isHour)
	local rewardAll = db:getStaticByName("storm_arena_rank_reward_all")
    for _, v in pairs(rewardAll) do
        if rank >= v.rank_1 and rank <= v.rank_2 then
            if isHour then
                return (tonumber(v.awards_hour))
            else
                return (tonumber(v.awards_hour))/60.0
            end
        end
    end
    return 0
end


function QUIDialogStormArenaHelp:getStormArenaAwards( level, isUnionRank )
    -- body
    local tmp = {}
    local tmp2 
    if isUnionRank then
        tmp2 =  db:getStaticByName("storm_arena_rank_reward_group")
    else
        tmp2 =  db:getStaticByName("storm_arena_rank_reward")
    end

    for i=1,table.nums(tmp2) do
        local v = tmp2[tostring(i)]
        if level >= v.level_min and level <= v.level_max then
            table.insert(tmp, v)
        end
    end
    return tmp
end

return QUIDialogStormArenaHelp
