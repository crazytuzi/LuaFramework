--[[
******帮派聚义厅申请列表*******

	-- by quanhuan
	-- 2015/10/26
	
]]

local FactinApply = class("FactinApply",BaseLayer)

function FactinApply:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactinApply")
end

function FactinApply:initUI( ui )

	self.super.initUI(self, ui)

	--创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "Panel_shenqingliebiao")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.btn_qklb = TFDirector:getChildByPath(ui, "btn_qklb")

    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.faction.FactionApplyCell")
    self.cellModel:retain()

    self.cellMax = 0

end

function FactinApply:removeUI()
   	self.super.removeUI(self)
   	if self.cellModel then
   		self.cellModel:release()
   		self.cellModel = nil
   	end
   	self.allPanels = self.allPanels or {}
    for k,v in pairs(self.allPanels) do
		if v.agreeBtn then
			v.agreeBtn:removeMEListener(TFWIDGET_CLICK)
		end
		if v.ignoreBtn then
			v.ignoreBtn:removeMEListener(TFWIDGET_CLICK)
		end
		local panel = v:getChildByTag(10086)
		panel:removeFromParent()
	end	
	self.allPanels = {}
end

function FactinApply:onShow()
    self.super.onShow(self)
end

function FactinApply:registerEvents()

	if self.registerEventCallFlag then
		return
	end

	self.super.registerEvents(self)

    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.btn_qklb:addMEListener(TFWIDGET_CLICK, audioClickfun(self.qklbButtonClick))
    self.btn_qklb.logic = self
 
    self.registerEventCallFlag = true
    self.tableViewNeedInit = true
end

function FactinApply:removeEvents()

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    

    self.btn_qklb:removeMEListener(TFWIDGET_CLICK)
    self.super.removeEvents(self)
    self.registerEventCallFlag = nil
end

function FactinApply:dispose()
    self.super.dispose(self)
end


function FactinApply.cellSizeForTable(table,idx)
    return 137,794
end

function FactinApply.numberOfCellsInTableView(table)
	local self = table.logic
    return self.cellMax
end

function FactinApply.tableCellAtIndex(table, idx)

	local self = table.logic
	local cell = table:dequeueCell()
	self.allPanels = self.allPanels or {}
	local panel = nil
	if cell == nil then
	    cell = TFTableViewCell:create()
	    local newIndex = #self.allPanels + 1
	    self.allPanels[newIndex] = cell

	    panel = self.cellModel:clone()
		panel:setPosition(ccp(0,0))
		cell:addChild(panel)
		panel:setTag(10086)
	else
		panel = cell:getChildByTag(10086)
	end

	idx = idx + 1
	self:cellInfoSet(cell, panel, idx)

    return cell
end

function FactinApply:cellInfoSet( cell, panel, idx )

	if cell.boundData == nil then
		cell.boundData = true
		cell.agreeBtn = TFDirector:getChildByPath(panel, "Btn_tongyi")
		cell.ignoreBtn = TFDirector:getChildByPath(panel, "Btn_hulue")
		cell.name = TFDirector:getChildByPath(panel, "txt_name")
		cell.imgHead = TFDirector:getChildByPath(panel, "Image_MembersCell_1")
		cell.level = TFDirector:getChildByPath(panel, "txt_level")
		cell.vip = TFDirector:getChildByPath(panel, "txt_vip")
		cell.fighting = TFDirector:getChildByPath(panel, "txt_zhandouli")
		cell.offline = TFDirector:getChildByPath(panel, "txt_2")
		cell.headBtn = TFDirector:getChildByPath(panel, "bg")

		cell.imgFrame = TFDirector:getChildByPath(panel, "bg_touxiang")

        --added by wuqi
        cell.img_vip = TFDirector:getChildByPath(panel, "img_vip")

		cell.headBtn:setTouchEnabled(true)
		cell.headBtn:addMEListener(TFWIDGET_CLICK,audioClickfun(self.headButtonClick))
		cell.headBtn.logic = self

		
		cell.agreeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.agreeButtonClick))
		cell.ignoreBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ignoreButtonClick))

		cell.agreeBtn.logic = self
		cell.ignoreBtn.logic = self
	end
	cell.agreeBtn.idx = idx
	cell.ignoreBtn.idx = idx
	cell.headBtn.idx = idx

	local cellItem = self.dataList[idx]
	if cellItem then
        --added by wuqi
        cell.vip:setVisible(true)
        cell.img_vip:setVisible(false)

		local RoleIcon = RoleData:objectByID(cellItem.icon)						        	--pck change head icon and head icon frame
		if RoleIcon == nil then
			RoleIcon = RoleData:objectByID(cellItem.profession)
		end
		cell.imgHead:setTexture(RoleIcon:getIconPath())
		cell.level:setText(cellItem.level..'d')
		cell.name:setText(cellItem.name)
		cell.vip:setText("o"..cellItem.vip)
		cell.fighting:setText(cellItem.power)
		local dTime = MainPlayer:getNowtime() - math.floor(cellItem.lastLoginTime/1000)
		local txtTime = FriendManager:formatTimeToString(dTime)
		cell.offline:setText(txtTime)
		Public:addFrameImg(cell.imgHead,cellItem.headPicFrame)							--end

        --added by wuqi
        if tonumber(cellItem.vip) > 15 and tonumber(cellItem.vip) <= 18 then
            cell.vip:setVisible(false)
            cell.img_vip:setVisible(true)
            Public:addVipEffect(cell.img_vip, tonumber(cellItem.vip), 0.8)
        end

        if SettingManager.TAG_VIP_YINCANG == tonumber(cellItem.vip) then
           cell.vip:setVisible(false)
           cell.img_vip:setVisible(false)
        end
	end
end

function FactinApply.agreeButtonClick( btn )

    local post = FactionManager:getPostInFaction()
    if post == 1 or post == 2 then
    	local item = btn.logic.dataList[btn.idx] 
		if item then
			FactionManager:agreenJoin( item.playerId, item.name )
		end
	else
		--toastMessage("权限不够")
		toastMessage(localizable.common_no_power)
        TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	end
end

function FactinApply.ignoreButtonClick( btn )
	local post = FactionManager:getPostInFaction()
    if post == 1 or post == 2 then	
		local item = btn.logic.dataList[btn.idx]
		if item then
			FactionManager:deleteJoin( item.playerId )
		end	
	else
		toastMessage(localizable.common_no_power)
		--toastMessage("权限不够")
        TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	end		
end

function FactinApply:refreshDataList()
	self.dataList = FactionManager:getOtherMemberList()
	local sortFunc = function(a, b) 
  		if a.applyTime <= b.applyTime then
			return true
		else
			return false
		end
  	end
	table.sort(self.dataList, sortFunc )	

	self.cellMax = #self.dataList
end
function FactinApply:refreshWindow()
	self:refreshDataList()
	self.TabView:reloadData()
	if self.tableViewNeedInit then
		self.tableViewNeedInit = false
		self.TabView:setScrollToBegin()
	end
end

function FactinApply.qklbButtonClick(btn)
	local post = FactionManager:getPostInFaction()
	local self = btn.logic
    if post == 1 or post == 2 then
    	if self.cellMax <= 0 then
			--toastMessage("列表内无申请消息")
			toastMessage(localizable.factionApply_no_message)
		else	
			FactionManager:deleteJoin(0)
		end
	else
		--toastMessage("权限不够")
		toastMessage(localizable.common_no_power)		
        TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	end
end

function FactinApply.headButtonClick( btn )
	
	local player = btn.logic.dataList[btn.idx]
	-- OtherPlayerManager:showOtherPlayerdetails(player.playerId, "overview")
	local info = {}
    info.profession = player.profession
    info.level = player.level
    info.name = player.name
    info.vip = player.vip
    info.power = player.power
    info.lastLoginTime = player.lastLoginTime
    info.playerId = player.playerId
    info.icon = player.icon 								--pck change head icon and head icon frame
    info.headPicFrame = player.headPicFrame					--end

	local layer = require("lua.logic.friends.FriendInfoLayer"):new(1)
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:setInfo(info)
	AlertManager:show()
	--local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.friends.FriendInfoLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    -- AlertManager:show();
end

return FactinApply