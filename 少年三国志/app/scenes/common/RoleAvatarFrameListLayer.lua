--头像框列表

require("app.cfg.frame_info")
local FunctionLevelConst = require "app.const.FunctionLevelConst"

local RoleAvatarFrameListLayer = class("RoleAvatarFrameListLayer", UFCCSModelLayer)

function RoleAvatarFrameListLayer.create(...)
	return RoleAvatarFrameListLayer.new("ui_layout/common_RoleAvatarFrameListLayer.json", Colors.modelColor, ...)
end

function RoleAvatarFrameListLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)
   
	self._vipFrameListView = nil
	self._specialFrameListView = nil 

	self._specialFrameListData = {} 
	self._vipFrameListData = {}

	self._curFrameId = G_Me.userData:getFrameId()

	self._callback = nil

    self:_initTabs()
	self:_initWidgets()

	self:_initVipFrameListView()
	self:_initSpecialFrameListView()

end

function RoleAvatarFrameListLayer:setConfirmCallback( callback )
	self._callback = callback
end

function RoleAvatarFrameListLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

--[[
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AVATAR_FRAME_CHANGE, function()
        if self._callback then
        	self._callback()
        end
        
    end, self)
]]


	for i=1, 2 do
		-- 红点
		local nMode = i
		if 1 then --FIXME
			self:showWidgetByName("Image_Tip"..nMode, false)
		else
			self:showWidgetByName("Image_Tip"..nMode, true)
		end
	end

	-- if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SET_AVATAR) then
	-- 	local result = G_moduleUnlock:setModuleEntered(FunctionLevelConst.SET_AVATAR)
	--     if result then
	--         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AVATAR_FRAME_FUNCTION, nil, false)
	--     end
	-- end
	
end

function RoleAvatarFrameListLayer:onLayerExit()

end

function RoleAvatarFrameListLayer:_initWidgets()
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onConfirm))
    self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))

end

function RoleAvatarFrameListLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(2, self, self._onTabChecked, self._onTabUnchecked)
	self._tabs:add("CheckBox_Vip", self:getPanelByName("Panel_Vip"), "Label_Vip")
	self._tabs:add("CheckBox_Special", self:getPanelByName("Panel_Special"), "Label_Special")

	--TODO 暂时不开放
	self:getCheckBoxByName("CheckBox_Special"):setTouchEnabled(false)
	
	self._tabs:checked("CheckBox_Vip")
end


function RoleAvatarFrameListLayer:_initVipFrameListView()
	self:_initVipFrameData()

	if not self._vipFrameListView then
		local panel = self:getPanelByName("Panel_ListView_Vip")
		self._vipFrameListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._vipFrameListView:setCreateCellHandler(function(list, index)
			local frameItem = require("app.scenes.common.RoleAvatarFrameItem")
			return frameItem.new()
		end)

		self._vipFrameListView:setUpdateCellHandler(function(list, index, cell)

			if index < #self._vipFrameListData then
				local frameItem = self._vipFrameListData[index + 1]
				cell:updateItem(frameItem, 1)
				cell:setGotoGetEvent(function()
					self:close()
				end)

				cell:setCheckBoxEvent(function(isChecked)

	                if isChecked == true then
	                	if frameItem.id ~= self._curFrameId then
	                		local index = 0
	                		if self._curFrameId > 0 then
	                			for i=1, #self._vipFrameListData do   
							    	local v = self._vipFrameListData[i]
							    	if v.id == self._curFrameId then
							        	index = i
							        	break
							    	end
								 end
	                		end

	                		if index > 0 then
	                			local cell = self._vipFrameListView:getCellByIndex(index - 1)
	                			if cell then
	                				cell:setCheckBoxState(false)
	                			end
	                		end

	                		self._curFrameId = frameItem.id
	                	end
	                else
	                    self._curFrameId = 0 
	                end
	            end)
			end

		end)

		self._vipFrameListView:setClickCellHandler(function (  list, index, cell )
            --cell:setSelectedHandler()
        end)
	end

	self._vipFrameListView:reloadWithLength(#self._vipFrameListData)
end


function RoleAvatarFrameListLayer:_initSpecialFrameListView()
	self:_initSpecialFrameData()

--[[  TODO...
	if not self._specialFrameListView then
		local panel = self:getPanelByName("Panel_ListView_Special")
		self._specialFrameListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._specialFrameListView:setCreateCellHandler(function(list, index)
			local frameItem = require("app.scenes.common.RoleAvatarFrameItem")
			return frameItem.new()
		end)

		self._specialFrameListView:setUpdateCellHandler(function(list, index, cell)

			if index < #self._specialFrameListData then
				local frameItem = self._specialFrameListData[index + 1]
				cell:updateItem(frameItem, 2)
				cell:setGotoGetEvent(function()
					self:close()
				end)

				cell:setCheckBoxEvent(function(isChecked)

	                if isChecked == true then
	                	if frameItem.id ~= self._curFrameId then
	                		local index = 0
	                		if self._curFrameId > 0 then
	                			for i=1, #self._specialFrameListData do   
							    	local v = self._specialFrameListData[i]
							    	if v.id == self._curFrameId then
							        	index = i
							        	break
							    	end
								 end
	                		end

	                		if index > 0 then
	                			local cell = self._specialFrameListView:getCellByIndex(index - 1)
	                			if cell then
	                				cell:setCheckBoxState(false)
	                			end
	                		end

	                		self._curFrameId = frameItem.id
	                	end
	                else
	                    self._curFrameId = 0 
	                end
	            end)
			end

		end)

		self._specialFrameListView:setClickCellHandler(function (  list, index, cell )
            cell:setSelectedHandler()
        end)

	end

	self._specialFrameListView:reloadWithLength(#self._specialFrameListData)
]]

end

function RoleAvatarFrameListLayer:_onConfirm()

	--仅当改变时才SEND REQUEST
	if G_Me.userData:getFrameId() ~= self._curFrameId then
    	G_HandlersManager.avatarFrameHandler:sendSetPictureFrame(self._curFrameId)
    end

	self:animationToClose()
end

function RoleAvatarFrameListLayer:_onCloseWindow()
	self:animationToClose()
end

function RoleAvatarFrameListLayer:_onTabChecked(szCheckBoxName)
	if szCheckBoxName == "CheckBox_Vip" then
		self:_switchPage(1)
	elseif szCheckBoxName == "CheckBox_Special" then
		self:_switchPage(2)
	end
end

function RoleAvatarFrameListLayer:_switchPage(nMode)
	if nMode == 1 then
		self:_initVipFrameListView()
	elseif nMode == 2 then
		self:_initSpecialFrameListView()
		--TODO 请求服务器
	end
end

function RoleAvatarFrameListLayer:_onTabUnchecked()
	
end

function RoleAvatarFrameListLayer:_initVipFrameData()

	self._vipFrameListData = {}

	for i=1, frame_info.getLength() do   
    	local v = frame_info.indexOf(i)
    	if v.vip_level > 0 then
        	self._vipFrameListData[#self._vipFrameListData+1]=v
    	end
	 end

end

function RoleAvatarFrameListLayer:_initSpecialFrameData()

	--TODO
	self._specialFrameListData = {}

	--[[ 暂时关闭 TODO

	for i=1, frame_info.getLength() do   
        local v = frame_info.indexOf(i)
        if v.vip_level == 0 then
            self._vipFrameListData[#self._vipFrameListData+1]=v
        end
   	end
   	]]

end


return RoleAvatarFrameListLayer