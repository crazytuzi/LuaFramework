--
-- Author: Your Name
-- Date: 2016-05-13 19:23:43
--


--[[	
	文件名称：QUIDialogCombinationRule.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogCombinationRule
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogCombinationRule = class("QUIDialogCombinationRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
--初始化
function QUIDialogCombinationRule:ctor(options)
	QUIDialogCombinationRule.super.ctor(self,options)
end

function QUIDialogCombinationRule:initData( options )
	-- body
	local data = {}
	self._data = data
	
	local options = self:getOptions()
	self._actorId = options.actorId
	
	local heroInfos = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId))
	self._combinationInfo = QStaticDatabase:sharedDatabase():getCombinationInfoByHeroId(self._actorId)
	local maxNum = #(self._combinationInfo or {})

	local activePropNum = 0 
	local unactivePropNum = 0
	local activeProp = {}
	local unactiveProp = {}

	for i = 1, maxNum do
		if remote.herosUtil:checkHeroCombination(self._actorId, self._combinationInfo[i]) or 
			remote.herosUtil:checkEnchantCombination(self._actorId, self._combinationInfo[i]) then

			self:setCombinationInfo(activeProp, self._combinationInfo[i])
			activePropNum = activePropNum + 1
		else
			self:setCombinationInfo(unactiveProp, self._combinationInfo[i])
			unactivePropNum = unactivePropNum + 1
		end
	end

	local activeWord1 = ""
	local activeWord2 = ""
	local unactiveWord1 = ""
	local unactiveWord2 = ""

	for i = 1, 4 do
		if activeProp[i] then
			activeWord1 = self:connectWord(activeWord1, activeProp[i])
		end
	end
	for i = 1, 4 do
		if unactiveProp[i] then
			unactiveWord1 = self:connectWord(unactiveWord1, unactiveProp[i])
		end
	end

	local param1 = string.format("%s%s  %s", heroInfos.name, "已激活宿命：", activePropNum.."/"..maxNum)

	local param2

	if activePropNum ~= 0 then
		param2 = "##O"..heroInfos.name.."已激活"..activePropNum.."条宿命获得：".." "..activeWord1.."##d"
	end

	if unactivePropNum ~= 0 then
		if param2 then
			param2 = param2 ..'\n'
		else
			param2 = ""
		end
		param2 = param2 .. heroInfos.name.."未激活"..unactivePropNum.."条宿命可获得：".." "..unactiveWord1
	end
	table.insert(data,{oType = "describe", info = {
		helpType = "sumin_shuoming",
		paramArr={param1,param2}
		}})

end

function QUIDialogCombinationRule:initListView( ... )
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
	            	end
	            	isCacheNode = false
	            end
	          
	            item:setInfo(itemData.info or {}, itemData.customStr)
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

function QUIDialogCombinationRule:setCombinationInfo(propValue, combinationInfo)
	local addProp = function(index, name, value)
		if propValue[index] == nil then
			propValue[index] = {}
			propValue[index].name = name
			propValue[index].value = value
		else
			propValue[index].value = propValue[index].value + value
		end
	end

   	if combinationInfo["attack_percent"] ~= nil then
		addProp(1, "攻击 +", combinationInfo["attack_percent"])
    end
    if combinationInfo["hp_percent"] ~= nil then
		addProp(2, "生命 +", combinationInfo["hp_percent"])
    end
    if combinationInfo["armor_magic_percent"] ~= nil then
		addProp(3, "法防 +", combinationInfo["armor_magic_percent"])
    end
    if combinationInfo["armor_physical_percent"] ~= nil then
		addProp(4, "物防 +", combinationInfo["armor_physical_percent"])
    end
end

function QUIDialogCombinationRule:connectWord(oldWord, newWord)
	if oldWord ~= "" then
		oldWord = oldWord.."   "
	end
	return oldWord..newWord.name..(newWord.value*100).."%"
end


return QUIDialogCombinationRule
