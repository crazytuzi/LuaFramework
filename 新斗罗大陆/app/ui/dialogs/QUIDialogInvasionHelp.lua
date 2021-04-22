
--[[	
	文件名称：QUIDialogInvasionHelp.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogInvasionHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogInvasionHelp = class("QUIDialogInvasionHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetInvasionHelpCell = import("..widgets.QUIWidgetInvasionHelpCell")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")
--初始化
function QUIDialogInvasionHelp:ctor(options)
	QUIDialogInvasionHelp.super.ctor(self,options)
end

function QUIDialogInvasionHelp:initData( options )
	-- body
	local data = {}
	self._data = data

	local configs = QStaticDatabase:sharedDatabase():getIntrusionRankAwardByLevel(1, remote.user.level)
	local invasion = remote.invasion:getSelfInvasion() 
	table.sort( configs, function (a, b)
		return a.rank < b.rank
	end)

	local minRank1 = nil
	local minRank2 = nil
	local widgets1 = {}
	local widgets2 = {}
	for index,rankAward in ipairs(configs) do
		if invasion.allHurtRank ~= nil and invasion.allHurtRank <= rankAward.rank and (minRank1 == nil or configs[minRank1].rank > rankAward.rank) then
			minRank1 = index
		end
		if invasion.maxHurtRank ~= nil and invasion.maxHurtRank <= rankAward.rank and (minRank2 == nil or configs[minRank2].rank > rankAward.rank) then
			minRank2 = index
		end

		local temp = {}
		local awardsArr = {}
		temp.awardsArr = awardsArr
		if configs[index-1] ~= nil and (configs[index-1].rank + 1) ~= rankAward.rank then
			temp.rankStr = "第"..(configs[index-1].rank + 1).."~"..rankAward.rank.."名："
		else
			temp.rankStr = "第"..rankAward.rank.."名："
		end

		local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(rankAward.intrusion_rank)
		for index,value in ipairs(awards) do
			table.insert(awardsArr, {id = value.id or value.typeName, count = math.floor(value.count * (1 + (rankAward.intrusion_rank_compensate or 0)))})
		end
		table.insert(widgets1, {oType = "invasionAward", info = temp})

		temp = {}
		awardsArr = {}
		temp.awardsArr = awardsArr
		if configs[index-1] ~= nil and (configs[index-1].rank+1) ~= rankAward.rank then
			temp.rankStr = "第"..(configs[index-1].rank+1).."~"..rankAward.rank.."名："
		else
			temp.rankStr = "第"..rankAward.rank.."名："
		end

		local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(rankAward.intrusion_hurt_rank)
		for index,value in ipairs(awards) do
			table.insert(awardsArr, {id = value.id or value.typeName, count = math.floor(value.count * (1 + (rankAward.intrusion_hurt_rank_compensate or 0)))})
		end
		table.insert(widgets2, {oType = "invasionAward", info = temp})
	end

	
	local paramStr2 = ""
	if minRank1 ~= nil then
		if configs[minRank1-1] ~= nil then
			if configs[minRank1-1].rank+1 ~= configs[minRank1].rank then
				paramStr2 = "名，保持排名（第"..(configs[minRank1-1].rank+1).."至"..configs[minRank1].rank.."名），可领取以下奖励："
			else
				paramStr2 = "名，保持排名（第"..configs[minRank1].rank.."名），可领取以下奖励："
			end
		else
			paramStr2 = "名，保持排名（第"..configs[minRank1].rank.."名以上），可领取以下奖励："
		end

		table.insert(data,{oType = "describe", info = {
			helpType = "fortress_shuoming_1",
			paramArr = {invasion.allHurtRank or 0, paramStr2},
		}})

		local temp = {}
		local awardsArr = {}
		temp.awardsArr = awardsArr
		local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(configs[minRank1].intrusion_rank)
		for index,value in ipairs(awards) do
			table.insert(awardsArr, {id = value.id or value.typeName, count = math.floor(value.count * (1 + (configs[minRank1].intrusion_rank_compensate or 0)))})
		end
		table.insert( data,  {oType = "award", info = temp})

	else
		paramStr2 = "名（尚未进榜）"
		table.insert(data,{oType = "describe", info = {
			helpType = "fortress_shuoming_1",
			paramArr = {invasion.allHurtRank or 0, paramStr2},
		}})
	end


	if minRank2 ~= nil then
		if configs[minRank2-1] ~= nil and (configs[minRank2-1].rank+1) ~= configs[minRank2].rank then
			paramStr2 = "名，保持排名（第"..(configs[minRank2-1].rank+1).."至"..configs[minRank2].rank.."名），可领取以下奖励："
		else
			paramStr2 = "名，保持排名（第"..configs[minRank2].rank.."名以上），可领取以下奖励："
		end
		table.insert(data,{oType = "describe", info = {
			helpType = "fortress_shuoming_2",
			paramArr = {invasion.maxHurtRank or 0, paramStr2},
		}})

		local temp = {}
		local awardsArr = {}
		temp.awardsArr = awardsArr

		local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(configs[minRank2].intrusion_hurt_rank)
		for index,value in ipairs(awards) do
			table.insert(awardsArr, {id = value.id or value.typeName, count = math.floor(value.count * (1 + (configs[minRank2].intrusion_hurt_rank_compensate or 0)))})
		end
		table.insert( data,  {oType = "award", info = temp})
	else
		paramStr2 = "名（尚未进榜）"
		table.insert(data,{oType = "describe", info = {
			helpType = "fortress_shuoming_2",
			paramArr = {invasion.maxHurtRank or 0, paramStr2},
		}})
	end
	table.insert(data,{oType = "describe", info = {
			helpType = "fortress_shuoming_3",
		}})


	for _, v in pairs(widgets1) do
		table.insert( data, v )
	end

	table.insert(data,{oType = "describe", info = {
			helpType = "fortress_shuoming_4",
		}})
	for _, v in pairs(widgets2) do
		table.insert( data, v )
	end


	table.insert(data,{oType = "describe", info = {
			helpType = "fortress_shuoming_5",
		}})
end

function QUIDialogInvasionHelp:initListView( ... )
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
	            	elseif itemData.oType == "invasionAward" then
	            		item = QUIWidgetInvasionHelpCell.new()
	            	elseif itemData.oType == "award" then
	            		item = QUIWidgetInvasionHelpCell.new()
	            	elseif itemData.oType == "line" then
	            		item = QUIWidgetBaseHelpLine.new()
	            	elseif itemData.oType == "empty" then
	            		item = QUIWidgetQlistviewItem.new()
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



return QUIDialogInvasionHelp
