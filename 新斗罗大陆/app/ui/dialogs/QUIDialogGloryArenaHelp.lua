
--[[	
	文件名称：QUIDialogGloryArenaHelp.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogGloryArenaHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogGloryArenaHelp = class("QUIDialogGloryArenaHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")

--初始化
function QUIDialogGloryArenaHelp:ctor(options)
	QUIDialogGloryArenaHelp.super.ctor(self,ccbFile,callBacks,options)
end


function QUIDialogGloryArenaHelp:initData(  )
	-- body
	local data = {}

	table.insert(data,{oType = "describe", info = {
		helpType = "zhengbasai_shuoming_1",
		}})

	local benFuAwards =  QStaticDatabase.sharedDatabase():getGloryArenaBenfuAwards()
	local quanFuAwards =  QStaticDatabase.sharedDatabase():getGloryArenaQuanfuAwards()
	table.insert(data, {oType = "title", info = {name = "全区排行奖励:", pos = ccp(30, -10), size = CCSizeMake(720, 40)}})

	for i = 1,table.nums(quanFuAwards) do
		local tempData = QStaticDatabase.sharedDatabase():getGloryArenaAwards(i,true) 
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
		local rankStr = ""
		if tempData.rank_1 == tempData.rank_2 then
			rankStr = string.format("第%s名:", tempData.rank_1)
		else
			rankStr = string.format("第%s-%s名:", tempData.rank_1,tempData.rank_2)
		end
		temp.awardsArr = awardsArr
		temp.rankStr = rankStr
		-- if i <= 5 then
		-- 	temp.title = 600 + i
		-- end

		table.insert(data, {oType = "award", info = temp})
	end
	
	table.insert(data, {oType = "title", info = {name = "本服排行奖励:"}})

	for i = 1,table.nums(benFuAwards) do
		local tempData = QStaticDatabase.sharedDatabase():getGloryArenaAwards(i) 
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
		temp.rank1 = tempData.rank_1
		temp.rank2 = tempData.rank_2
		local rankStr = ""
		if tempData.rank_1 == tempData.rank_2 then
			rankStr = string.format("第%s名:", tempData.rank_1)
		else
			rankStr = string.format("第%s-%s名:", tempData.rank_1,tempData.rank_2)
		end
		temp.awardsArr = awardsArr



		temp.rankStr = rankStr
		table.insert(data, {oType = "award", info = temp})
	end



	table.insert(data,{oType = "describe", info = {
		helpType = "zhengbasai_shuoming_2",
		}})


	self._data = data

end

function QUIDialogGloryArenaHelp:initListView( ... )
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

	            	end
	            	isCacheNode = false
	            end

	            item:setInfo(itemData.info)
	            info.tag = itemData.oType
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 20,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end



return QUIDialogGloryArenaHelp
