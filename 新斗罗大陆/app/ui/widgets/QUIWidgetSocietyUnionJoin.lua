--[[	
	文件名称：QUIWidgetSocietyUnionJoin.lua
	创建时间：2016-03-21 16:26:47
	作者：nieming
	描述：QUIWidgetSocietyUnionJoin
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionJoin = class("QUIWidgetSocietyUnionJoin", QUIWidget)
local QUIWidgetUnionBar = import("..widgets.QUIWidgetUnionBar")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetSocietyUnionJoin.itemPageSize = 10

--初始化
function QUIWidgetSocietyUnionJoin:ctor(options)
	local ccbFile = "Widget_society_union_join.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QUIWidgetSocietyUnionJoin._onTriggerNext)},
		{ccbCallbackName = "onTriggerLast", callback = handler(self, QUIWidgetSocietyUnionJoin._onTriggerLast)},
		{ccbCallbackName = "onTriggerOnekey", callback = handler(self, QUIWidgetSocietyUnionJoin._onTriggerOnekey)},
	}
	QUIWidgetSocietyUnionJoin.super.ctor(self,ccbFile,callBacks,options)
	--代码
	if not options then
		options = {}
	end
	self._parent = options.parent
	self._curPage = 1
	self._totalPage = 1



end

--describe：
function QUIWidgetSocietyUnionJoin:_onTriggerNext(e)
	if e ~= nil then app.sound:playSound("common_common") end
	if self._curPage >= self._totalPage then
		
		return
	end

	if not self._nextIconGray and self._curPage + 1 >= self._totalPage then
		makeNodeFromNormalToGray(self._ccbOwner.nextIcon)
		self._nextIconGray = true
	end

	if self._lastIconGray then
		makeNodeFromGrayToNormal(self._ccbOwner.lastIcon)
		self._lastIconGray = nil
	end
	
	remote.union:unionRecommendListRequest(self._curPage + 1,QUIWidgetSocietyUnionJoin.itemPageSize,function (data)
        if data.consortiaRecommendList then
        	self._curPage = self._curPage + 1
            self:setInfo(data.consortiaRecommendList)
        end
    end)
	
end

--describe：
function QUIWidgetSocietyUnionJoin:_onTriggerLast(e)
	if e ~= nil then app.sound:playSound("common_common") end
	if self._curPage <= 1 then
		return
	end

	if not self._lastIconGray and self._curPage -1 <= 1 then
		makeNodeFromNormalToGray(self._ccbOwner.lastIcon)
		self._lastIconGray = true
	end

	if self._nextIconGray then
		makeNodeFromGrayToNormal(self._ccbOwner.nextIcon)
		self._nextIconGray = nil
	end

	remote.union:unionRecommendListRequest(self._curPage -1,QUIWidgetSocietyUnionJoin.itemPageSize,function (data)
        if data.consortiaRecommendList then
        	self._curPage = self._curPage -1
            self:setInfo(data.consortiaRecommendList,self._curDataPage)
        end
    end)

end

--describe：
function QUIWidgetSocietyUnionJoin:_onTriggerOnekey(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_oneKey) == false then return end
	if event ~= nil then app.sound:playSound("common_common") end

	if not remote.user:checkJoinUnionCdAndTips() then return end

	-- local joinCD = QStaticDatabase.sharedDatabase():getConfigurationValue("ENTER_SOCIETY") * 60 
	-- local leave_at  = 0
	-- if remote.user.userConsortia.leave_at and remote.user.userConsortia.leave_at >0 then
	-- 	joinCD = remote.user.userConsortia.leave_at/1000 + joinCD - q.serverTime()	
	-- 	if joinCD > 0 then
	-- 		app.tip:floatTip(string.format("%d小时%d分钟内无法加入宗门", math.floor(joinCD/(60*60)), math.floor((joinCD/60)%60))) 
	-- 		return
	-- 	end
	-- end


	remote.union:unionOneKeyEnterRequest(function ( data )
		-- body
		app.tip:floatTip("恭喜您，加入宗门成功！") 
		remote.union:resetSocietyDungeonData()
		if self._parent then
			self._parent:onTriggerBackHandler()
		end
		if data.consortia then
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionMain", options = {info = data.consortia}})
		end
	end)
end

--describe：onEnter 
--function QUIWidgetSocietyUnionJoin:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetSocietyUnionJoin:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetSocietyUnionJoin:setInfo(info)
	--代码
	self._data = info.consortiaList or {}
	self._total = info.totalConsortiaCount
	
	self._totalPage = self._total%QUIWidgetSocietyUnionJoin.itemPageSize == 0 and self._total/QUIWidgetSocietyUnionJoin.itemPageSize or math.floor(self._total/QUIWidgetSocietyUnionJoin.itemPageSize)  + 1
	
	if self._curPage == 1 then
		makeNodeFromNormalToGray(self._ccbOwner.lastIcon)
		self._lastIconGray = true
	end
	
	if self._curPage ==  self._totalPage then
		makeNodeFromNormalToGray(self._ccbOwner.nextIcon)
		self._nextIconGray = true
	end

	self:renderItem()
end

function QUIWidgetSocietyUnionJoin:renderItem( )
	-- body
	self._ccbOwner.pageNum:setString(self._curPage.."/"..self._totalPage)
	if not self._listView then
 		local cfg = {
            renderItemCallBack = function( list, index, info )
                -- body
                local isCacheNode = true
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetUnionBar.new()
                    isCacheNode = false
                end
                item:setInfo(self._data[index])
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index,"btn_join", "_onTriggerJoin", nil, true)
                list:registerBtnHandler(index,"cancelJoinBtn", "_onTriggerCancelJoin" )
                list:registerBtnHandler(index,"infoBtn", "_onTriggerInfo",1 )
                return isCacheNode
            end,
            totalNumber = #self._data,
            enableShadow = false,
            curOriginOffset = -5,
            curOffset = 5,
            spaceY = 0,
            contentOffsetX = 1,
        }  
        self._listView = QListView.new(self._ccbOwner.itemList,cfg)
        -- self._loginHistoryList:scrollToIndex(1,true)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

--describe：getContentSize 
--function QUIWidgetSocietyUnionJoin:getContentSize()
	----代码
--end

return QUIWidgetSocietyUnionJoin
