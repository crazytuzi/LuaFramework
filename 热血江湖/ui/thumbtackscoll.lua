
module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_thumbtackScoll = i3k_class("wnd_thumbtackScoll", ui.wnd_base)

local TUDING = "ui/widgets/tudingt"
local MAXCOUNT = 5 --图钉里最大显示行数 个数除以2
local COLUMNCOUNT = 2

function wnd_thumbtackScoll:ctor()
	self._mapSize = nil
	self._mapID = 0
end

function wnd_thumbtackScoll:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_thumbtackScoll:refresh(mapID, mapSize)
	self._mapID = mapID
	self._mapSize = mapSize
	local scollData = g_i3k_game_context:getThumbtackOrderTable()
	--根据重构数据数量加载scoll个数
	local weights = self._layout.vars
	local scoll = weights.scoll
	local scollImage = weights.scollImage
	local value = #scollData	
	local count = 0  -- 几行
	local vipUseCount = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].useTuDingCount
	local height = 0
	local width = 0
	local curMap = self:isCurMap(mapID)
	
	if value == 0 then
		count = 1
		width = self._nodeSize.width
	elseif value == vipUseCount then
		count = math.ceil(value / 2)
		width = self._nodeSize.width * 2
	else
		if curMap then
			count = value % 2 == 0 and math.ceil(value / 2 + 1) or math.ceil(value / 2)
		else
			count = math.ceil(value / 2)
		end
		
		width = self._nodeSize.width * 2
	end
		
	if count <= MAXCOUNT then
		height = self._nodeSize.height * count
		scoll:stateToNoSlip()
	else
		height = self._nodeSize.height * MAXCOUNT
		scoll:stateToSlip()
	end			
	
	scoll:setContentSize(self._scollSize.width, height)
	scollImage:setContentSize(self._scollSize.width, height)	
	--获得VIP等级的vipUseCount 根据这个数来确定scoll的子节点总数
	local function refreshNode(item, itemData)
		if itemData == nil then
			item.normalImage:hide()
			item.addImage:show()
			item.addBt:onClick(self, self.onAddThumbtackBt, self._mapID)
		else
			item.normalImage:show()
			item.addImage:hide()
			local mapName = i3k_db_dungeon_base[itemData.mapId].desc
			item.name:setText(mapName .. itemData.index)
			item.des:setText(itemData.remarks)
			item.itemBt:onClick(self, self.transferTextMethod, itemData)
			item.modify:onClick(self, self.onThumbtackItemBt, itemData)
		end
	end
	
	if curMap then	
		if value < vipUseCount then
			value = value + 1
			scoll:addChildWithCount(TUDING, COLUMNCOUNT, value, true)
		
			for i = 1, value do 
				local item = scoll:getChildAtIndex(i).vars
			
				if i == value then
					refreshNode(item)
				else
					refreshNode(item, scollData[i])
				end
			end
		else
			scoll:addChildWithCount(TUDING, COLUMNCOUNT, vipUseCount, true)
				
			for i = 1, value do 			
				local item = scoll:getChildAtIndex(i).vars
				refreshNode(item, scollData[i])
			end
		end
	else
		if value == 1 then 
			width = self._nodeSize.width
		end
		
		scoll:addChildWithCount(TUDING, COLUMNCOUNT, value, true)
		
		for i = 1, value do 		
			local item = scoll:getChildAtIndex(i).vars
			refreshNode(item, scollData[i])
		end
	end
	
	scoll:setContentSize(width, height)
	scollImage:setContentSize(width, height)	
end

function wnd_thumbtackScoll:isCurMap(mapId)
	return 	g_i3k_game_context:GetWorldMapID() == mapId
end

--点击加号添加事件
function wnd_thumbtackScoll:onAddThumbtackBt(sender, mapID)
	if not self:isCurLevelMaxCount(mapID) then
		g_i3k_ui_mgr:PopupTipMessage("当前图钉数量已达到最大值")
		return
	end
	
	local value = g_i3k_game_context:getThumbtackTaBleIndex(mapID)
	g_i3k_logic:OpenThumbtackDetailUI(value, mapID)
end

function wnd_thumbtackScoll:isCurLevelMaxCount(mapID)
	local vipUseCount = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].useTuDingCount
	local thumbtack = g_i3k_game_context:getThumbtack()
	if thumbtack == nil then return true end
	
	local count = 0
	
	for _, v in pairs(thumbtack) do
		if v ~= nil then
			for _, n in pairs(v) do
				if n ~= nil then
					count = count + 1
				end 
			end	
		end
	end
	
	return count < vipUseCount
end

function wnd_thumbtackScoll:addThumbtackImage(info)	
	info.pos = i3k_game_get_player_hero()._curPosE
	info.thumbAddTime = info.addTime
	local baseMap = GetBaseMap()
	baseMap:addThumbtackNode(info, self._mapSize)
	self:refresh(self._mapID, self._mapSize)
end

--点击单个进行传送或者改动和删除操作
function wnd_thumbtackScoll:onThumbtackItemBt(sender, item)
	g_i3k_logic:OpenThumbtackDeleteUI(item)
end

function wnd_thumbtackScoll:removeThumbtackImage(info)
	local baseMap = GetBaseMap()	
	baseMap:clearThumbtackImgBYID(info.index, info.mapId)
	
	local scollData = g_i3k_game_context:getThumbtackOrderTable()
	
	if #scollData == 0 and not self:isCurMap(self._mapID) then
		self:onCloseUI()
		return
	end
	
	self:refresh(self._mapID, self._mapSize)
end

function wnd_thumbtackScoll:refreshModifyThumbtackUI(info)
	local thumbData = g_i3k_game_context:getThumbtack()
	if thumbData == nil then return end
	local mapData = thumbData[info.mapId]
	if mapData == nil then return end
	
	for _, v in pairs(mapData) do 
		if v ~= nil and v.index == info.index then
			v.remarks = info.remarks
		end
	end
	
	self:refresh(self._mapID, self._mapSize)
end

function wnd_thumbtackScoll:transferTextMethod(sender, item)
	if not g_i3k_game_context:IsTransNeedItem() then
		if g_i3k_game_context:getThumbtackVipFlag() then
			g_i3k_game_context:doThumbtackTransfer(item.index, item.mapId)
			self:onCloseUI()
			g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
		else
			g_i3k_logic:OpenThumbtackTransferUI(item.index, item.mapId, true)
		end
	else
		if g_i3k_game_context:getThumbtackNomalFlag() then
			if not g_i3k_game_context:CheckCanTrans(i3k_db_common.activity.transNeedItemId, 1) then
				g_i3k_ui_mgr:PopupTipMessage("传送失败")
				return
			end
			g_i3k_game_context:doThumbtackTransfer(item.index, item.mapId)
		else		
			g_i3k_logic:OpenThumbtackTransferUI(item.index, item.mapId, false)
		end
	end
end

function wnd_thumbtackScoll:onShow()
	local node = require(TUDING)()
	self._nodeSize = node.vars.typeImg:getSize()
	local scoll = self._layout.vars.scoll
	self._scollSize = scoll:getContentSize()
end

function wnd_thumbtackScoll:onHide()

end

function wnd_create(layout)
	local wnd = wnd_thumbtackScoll.new();
	wnd:create(layout);
	return wnd;
end
