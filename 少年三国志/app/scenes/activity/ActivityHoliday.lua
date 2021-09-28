local ActivityHoliday = class("ActivityHoliday",UFCCSNormalLayer)
require("app.cfg.holiday_event_info")
require("app.cfg.item_info")
local EffectNode = require "app.common.effects.EffectNode"

function ActivityHoliday.create(holiday)
    return ActivityHoliday.new("ui_layout/activity_ActivityHoliday.json",holiday)
end

local ItemConst = require("app.const.ItemConst")

local ActivityHolidayCell = require("app.scenes.activity.ActivityHolidayCell")
function ActivityHoliday:ctor(_,holiday)
	self._holiday = holiday
	self._listData = {}

	self.super.ctor(self)
	self:getLabelByName("Label_desc"):setText("")
	self:getLabelByName("Label_endtime"):setText("")
	self:getLabelByName("Label_num"):setText("")
	self:_createStroke()
	if not self._holiday then
		return
	end

end

function ActivityHoliday:_createStroke()
	self:getLabelByName("Label_endtimeTag"):createStroke(Colors.strokeBrown,2)
	self:getLabelByName("Label_endtime"):createStroke(Colors.strokeBrown,2)
	self:getLabelByName("Label_waziName"):createStroke(Colors.strokeBrown,2)
	self:getLabelByName("Label_num"):createStroke(Colors.strokeBrown,2)
end

function ActivityHoliday:_initListData()
	self._listData = {}
	for i=1,holiday_event_info.getLength() do
		local item = holiday_event_info.indexOf(i)
		if item then
			table.insert(self._listData,item)
		end
	end

	local sortFunc = function(a,b)
		--是否有剩余次数
		local exchangeTimesA = G_Me.activityData.holiday:getExchangeTimesById(a.id)
		local exchangeTimesB = G_Me.activityData.holiday:getExchangeTimesById(b.id)
		local leftTimeA =  0
		local leftTimeB =  0
		if exchangeTimesA == -1 then
			leftTimeA = 0
		else   --1 表示还有剩余次数
			leftTimeA = (a.num - exchangeTimesA == 0) and 0 or 1
		end 
		if exchangeTimesB == -1 then
			leftTimeB = 0
		else
			leftTimeB = (b.num - exchangeTimesB == 0) and 0 or 1
		end 


		if leftTimeA ~= leftTimeB then
			return leftTimeA > leftTimeB
		end
		return a.id < b.id 
	end

	table.sort(self._listData,sortFunc)
end

function ActivityHoliday:_setListView()
	if not self._holiday then
		return
	end
	if self._listview == nil then
		local panel = self:getPanelByName("Panel_listview")
		self._listview = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
		self._listview:setCreateCellHandler(function(list,index)
		    local item = ActivityHolidayCell.new(self._holiday.id)        
		    return item
		end)
		self._listview:setUpdateCellHandler(function(list,index,cell)
			cell:updateItem(self._listData[index+1])
		end)
		-- self._listview:setSpaceBorder(0,30)
		if self._listData ~= nil and #self._listData > 0 then
			self._listview:reloadWithLength(#self._listData,self._listview:getShowStart(),0.2)
		end
	else
		self._listview:refreshAllCell()
	end
end

function ActivityHoliday:_refreshWaziNum()
	local item = item_info.get(ItemConst.ITEM_ID.SHENG_DAN_WA_ZI)
	if item then
		local num = G_Me.bagData:getPropCount(item.id)
		self:getLabelByName("Label_num"):setText(num)
		self:getLabelByName("Label_waziName"):setText(item.name .. "：")
	end
end

function ActivityHoliday:onLayerEnter()
	--雪花粒子
	if self._emiter == nil then
		self._emiter = CCParticleSystemQuad:create("particles/snow.plist")
		self._emiter:setPosition(ccp(display.cx, display.size.height-140))
		-- self:getImageViewByName("ImageView_bg"):addNode(self._emiter)
		self:getPanelByName("Panel_lizi"):addNode(self._emiter,1)
	end

	--星星
	if self._starEffect == nil then
		self._starEffect = EffectNode.new("effect_sd_starkk", function(event, frameIndex)
		            end)  
		local image = self:getImageViewByName("Image_25")
		if image then
			self._starEffect:setPosition(ccp(0,-80))
			image:addNode(self._starEffect)
			self._starEffect:play()
		end 
	end

	-- 描述框
	if self._descEffect == nil then
		self._descEffect = EffectNode.new("effect_sd_huodongbiaoti", function(event, frameIndex)
		            end)  
		local panel = self:getPanelByName("Panel_xunhuan")
		if panel then
			local width = panel:getContentSize().width
			local height = panel:getContentSize().height
			self._descEffect:setPosition(ccp(width/2-3,height/2+5))
			panel:addNode(self._descEffect)
			self._descEffect:play()
		end 
	end

	--人物面前雪花
	if self._snowEffect == nil then
		self._snowEffect = EffectNode.new("effect_sd_jiezhi", function(event, frameIndex)
		            end)  
		local panel = self:getPanelByName("Panel_xue")
		if panel then
			local width = panel:getContentSize().width
			local height = panel:getContentSize().height
			self._snowEffect:setPosition(ccp(width/2+10,height/2))
			-- self:getImageViewByName("Image_snow"):addNode(self._effect)
			panel:addNode(self._snowEffect)
			self._snowEffect:play()
		end
	end

	if not self._holiday then
		return
	end
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HOLIDAY_ACTIVITY_INFO, self._getInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_HOLIDAY_ACTIVITY_AWARD, self._getAward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._bagChanged, self)
	
	self:adapterWidgetHeight("Panel_listviewBg", "Panel_top", "", 10, 0)
	self:adapterWidgetHeight("Panel_listview", "Panel_top", "", 20, 0)
	self:adapterWidgetHeight("Panel_zhuangshi", "Panel_top", "", 20, 0)

	self:getLabelByName("Label_desc"):setText(self._holiday.comment)
	self:getLabelByName("Label_num"):setText("0")
	self:_refreshTimer()
	self._timer = G_GlobalFunc.addTimer(1, function()
		if self and self._refreshTimer then
			self:_refreshTimer()
		end
	end)
	self:_refreshWaziNum()

	--每次进入都请求
	G_HandlersManager.activityHandler:sendHolidayEventInfo()
end

function ActivityHoliday:_refreshTimer()
	local leftSecond = G_ServerTime:getLeftSeconds(self._holiday["end_time"])
	if leftSecond > 0 then
		local leftTime = G_ServerTime:getLeftSecondsStringWithDays(self._holiday["end_time"])
		self:getLabelByName("Label_endtime"):setText(leftTime)
	else
		self:getLabelByName("Label_endtime"):setText(G_lang:get("LANG_ACTIVITY_IS_TIME_OUT"))
	end
end

function ActivityHoliday:_getInfo()
	if self._initListData then
		self:_initListData()
	end

	if self._setListView then
		self:_setListView()
	end
end

function ActivityHoliday:_getAward(data)
	if data.ret == 1 then
		if self._setListView then
			self:_setListView()
		end
		local event = holiday_event_info.get(data.id)
		if event then
			local award = {}
			local good = G_Goods.convert(event.type,event.value,event.size)
			if good then
				table.insert(award,good)
			end
			if #award > 0 then
				local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").createForHoliday(award)
				uf_notifyLayer:getModelNode():addChild(_layer)
			end
		end
	end
end

function ActivityHoliday:_bagChanged()
	self:_refreshWaziNum()
end


function ActivityHoliday:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
	if self._timer then
		GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

return ActivityHoliday