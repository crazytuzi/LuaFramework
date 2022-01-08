--[[
******帮派申请界面*******

	-- by quanhuan
	-- 2015/10/23
	
]]

local ApplyLayer = class("ApplyLayer",BaseLayer)

local cell_init_num = 11
local cell_add_num = 10
local cell_h = 69
local cell_w = 618

function ApplyLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.Apply")
end

function ApplyLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.Faction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE}) 

    self.txt_none = TFDirector:getChildByPath(ui,"txt_none")

    self.panel_content = TFDirector:getChildByPath(ui,"panel_content")

    self.btn_sqjr = TFDirector:getChildByPath(ui, "btn_sqjr")
    self.btn_sqjr.logic = self
    self.btn_yjsq = TFDirector:getChildByPath(ui, "btn_yjsq")
    self.btn_yjsq.logic = self
    self.btn_create = TFDirector:getChildByPath(ui, "btn_create")
    self.btn_create.logic = self
    self.btn_rank = TFDirector:getChildByPath(ui, "btn_rank")
    self.btn_rank.logic = self
    self.btn_chazhao = TFDirector:getChildByPath(ui, "btn_chazhao")
    self.btn_chazhao.logic = self

    self.txt_xuanyan = TFDirector:getChildByPath(ui, "txt_xuanyan")
    self.txt_zdl = TFDirector:getChildByPath(ui, "txt_zdl")
    self.playernameInputbg = TFDirector:getChildByPath(ui, 'bg_input')
	self.playernameInput = TFDirector:getChildByPath(ui, 'playernameInput')
	self.playernameInput:setCursorEnabled(true)
	self.playernameInput:setVisible(true)
	self.txt_xuanyan:setText("")
	self.txt_zdl:setText("")
    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "Panel_List")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.tableChoseCell = nil
    self.tableChoseIdx = nil

    self.isFristIn = true
    self.cell_curr_max = 0

    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.faction.ApplyCell")
    self.cellModel:retain()
end

function ApplyLayer:initDataList()

	self.isFristIn = true
	self.cell_curr_max = 0
	self.updateWithMore = true

	RankManager:setDelayTimeZero(RankListType.Rank_List_FactionLevel)	
	RankManager:RequestDataFromServer(RankListType.Rank_List_FactionLevel, 0, 10)

end

function ApplyLayer:removeUI()

	self.super.removeUI(self)
	if self.cellModel then
		self.cellModel:release()
		self.cellModel = nil
	end

end

function ApplyLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function ApplyLayer:registerEvents()

	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end	

	local pos = self.ui:getPosition()
	--添加输入账号时输入框上移逻辑
	local function onTextFieldAttachHandle(input)
        self.ui:setPosition(ccp(pos.x,440))
    end    
    self.playernameInput:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)
    local function onTextFieldChangedHandle(input)
		print("<<<<<<<<<<<<<<<<<<"..self.playernameInput:getText())
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)
    local function onTextFieldDetachHandle(input)
        self.ui:setPosition(ccp(pos.x, pos.y))
        self.playernameInput:closeIME()
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)
    self.playernameInput:setMaxLengthEnabled(true)
    self.playernameInput:setMaxLength(10)

    local function spaceAreaClick(sender)
    	self.ui:setPosition(ccp(pos.x, pos.y))
    	self.playernameInput:closeIME()
	end
    self.ui:setTouchEnabled(true)
    self.ui:addMEListener(TFWIDGET_CLICK, spaceAreaClick)
    ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)


    self.btn_sqjr:addMEListener(TFWIDGET_CLICK, audioClickfun(self.sqjrButtonClick))
    self.btn_yjsq:addMEListener(TFWIDGET_CLICK, audioClickfun(self.yjsqButtonClick))
    self.btn_create:addMEListener(TFWIDGET_CLICK, audioClickfun(self.createButtonClick))
    self.btn_rank:addMEListener(TFWIDGET_CLICK, audioClickfun(self.rankButtonClick))
    self.btn_chazhao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.chazhaoButtonClick))

    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.TabView:addMEListener(TFTABLEVIEW_TOUCHED, self.tableCellTouched)  

        --监听数据请求回调
	self.requestDataCallBack = function (event)
		local userData = event.data[1][1]
		if self.updateWithMore then
			self.updateWithMore = false
			self:getRankDataMap(userData)
		end
	end
	TFDirector:addMEGlobalListener(RankManager.GetFactionList, self.requestDataCallBack)

	self.joinFactionCallBack = function ( event )
		local datamap = RankManager:getDataMapByType( RankListType.Rank_List_FactionLevel )
		self.cellDataMap = datamap.rankInfo
		self:sqjrButtonOK()
	end
	TFDirector:addMEGlobalListener(FactionManager.requestJoinFactionMsg ,self.joinFactionCallBack)

	--查询帮派信息刷新
    self.lookupOtherInfoCallBack = function (event)
       FactionManager:lookupOtherFactinoInfo()
    end
    TFDirector:addMEGlobalListener(FactionManager.lookupOtherInfo, self.lookupOtherInfoCallBack)


    FactionManager:addLayerInFaction()
end

function ApplyLayer:removeEvents()

	if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.playernameInput:removeMEListener(TFTEXTFIELD_ATTACH)
    self.playernameInput:removeMEListener(TFTEXTFIELD_TEXTCHANGE)
    self.playernameInput:removeMEListener(TFTEXTFIELD_DETACH)
    if self.ui then
    	self.ui:removeMEListener(TFWIDGET_CLICK)
    end

    self.btn_sqjr:removeMEListener(TFWIDGET_CLICK)
    self.btn_yjsq:removeMEListener(TFWIDGET_CLICK)
    self.btn_create:removeMEListener(TFWIDGET_CLICK)
    self.btn_rank:removeMEListener(TFWIDGET_CLICK)
    self.btn_chazhao:removeMEListener(TFWIDGET_CLICK)

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
	self.TabView:removeMEListener(TFTABLEVIEW_TOUCHED)

	TFDirector:removeMEGlobalListener(RankManager.GetFactionList, self.requestDataCallBack)
	TFDirector:removeMEGlobalListener(FactionManager.requestJoinFactionMsg ,self.joinFactionCallBack)	
	TFDirector:removeMEGlobalListener(FactionManager.lookupOtherInfo, self.lookupOtherInfoCallBack)
    self.super.removeEvents(self)

    FactionManager:deleteLayerInFaction()
end

function ApplyLayer:dispose()

	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end

function ApplyLayer.cellSizeForTable(table,idx)
    return cell_h,cell_w
end

function ApplyLayer.numberOfCellsInTableView(table)
	local self = table.logic
    return self.cell_curr_max
end

function ApplyLayer.tableCellAtIndex(table, idx)

	local self = table.logic
	local cell = table:dequeueCell()

	local panel = nil
	if cell == nil then
	    cell = TFTableViewCell:create()

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

function ApplyLayer:cellInfoSet(cell, panel, idx)

	if cell.info == nil then
		local panel_on = TFDirector:getChildByPath(panel, "bg_list2")
		local panel_off = TFDirector:getChildByPath(panel, "bg_list1")
		cell.info = {
			touchOn = {
				btn = panel_on,
				img = TFDirector:getChildByPath(panel_on, "Image_shenqing"),
				idx = TFDirector:getChildByPath(panel_on, "txt_1"),
				level = TFDirector:getChildByPath(panel_on, "txt_2"),
				factionName = TFDirector:getChildByPath(panel_on, "txt3"),
				memberCount = TFDirector:getChildByPath(panel_on, "txt4"),
				presidentName = TFDirector:getChildByPath(panel_on, "txt5"),
			},
			touchOff = {
				btn = panel_off,
				img = TFDirector:getChildByPath(panel_off, "Image_shenqing"),
				idx = TFDirector:getChildByPath(panel_off, "txt_1"),
				level = TFDirector:getChildByPath(panel_off, "txt_2"),
				factionName = TFDirector:getChildByPath(panel_off, "txt3"),
				memberCount = TFDirector:getChildByPath(panel_off, "txt4"),
				presidentName = TFDirector:getChildByPath(panel_off, "txt5"),
			},
			btnMore = {
				btn = TFDirector:getChildByPath(panel, "bg_more")
			}
		}
	end
	local item = self.cellDataMap[idx]

    cell.info.isMoreButton = false
	if self.tableChoseIdx == idx then
		self.tableChoseCell = cell    
		cell.info.touchOn.btn:setVisible(true)		
		cell.info.touchOff.btn:setVisible(false)
		cell.info.btnMore.btn:setVisible(false)

		self.txt_xuanyan:setText(item.declaration)
    	--self.txt_zdl:setText("战斗力:"..item.power)
    	self.txt_zdl:setText(stringUtils.format(localizable.common_CE,item.power))
		if item.apply then
			self.btn_sqjr:setTextureNormal("ui_new/faction/btn_qxsq.png")
		else
			self.btn_sqjr:setTextureNormal("ui_new/faction/btn_sqjr.png")
		end    	

	elseif idx == self.cell_curr_max and self.needViewMoreBtn then
		cell.info.isMoreButton = true
		cell.info.touchOn.btn:setVisible(false)		
		cell.info.touchOff.btn:setVisible(false)
		cell.info.btnMore.btn:setVisible(true)
	else
 		cell.info.touchOn.btn:setVisible(false)		
		cell.info.touchOff.btn:setVisible(true)
		cell.info.btnMore.btn:setVisible(false)
	end

	
	if cell.info.isMoreButton == false then
		
		local maxNum = FactionManager:getFactionMaxMember(item.level)	
		cell.info.touchOn.img:setVisible(item.apply)
		cell.info.touchOn.idx:setText(item.guildId)
		--cell.info.touchOn.level:setText(item.level..'级')
		cell.info.touchOn.level:setText(stringUtils.format(localizable.common_LV,item.level))

		cell.info.touchOn.factionName:setText(item.name)
		cell.info.touchOn.memberCount:setText(item.memberCount.."/"..maxNum)
		cell.info.touchOn.presidentName:setText(item.presidentName)

		cell.info.touchOff.img:setVisible(item.apply)
		cell.info.touchOff.idx:setText(item.guildId)
		--cell.info.touchOff.level:setText(item.level..'级')
		cell.info.touchOff.level:setText(stringUtils.format(localizable.common_LV,item.level))		
		cell.info.touchOff.factionName:setText(item.name)
		cell.info.touchOff.memberCount:setText(item.memberCount.."/"..maxNum)
		cell.info.touchOff.presidentName:setText(item.presidentName)
	end

end

function ApplyLayer.tableCellTouched(table,cell)

	play_press()
	local self = table.logic
	local idx = cell:getIdx() + 1

	print("idx = ",idx)

	if idx == self.tableChoseIdx then
		return
	end

	if cell.info and cell.info.isMoreButton then
		--加载更多	
		self:onBtnMoreClickHandl()
		return
	end

	local preCell = self.tableChoseCell
	if preCell then
		preCell.info.touchOff.btn:setVisible(true)
		preCell.info.touchOn.btn:setVisible(false)
	end
	
	cell.info.touchOff.btn:setVisible(false)
	cell.info.touchOn.btn:setVisible(true)
	self.tableChoseCell = cell
	self.tableChoseIdx = idx

	local item = self.cellDataMap[idx]
	print("item = ",item)
	if item then
		if item.apply then 
			self.btn_sqjr:setTextureNormal("ui_new/faction/btn_qxsq.png")
		else
			self.btn_sqjr:setTextureNormal("ui_new/faction/btn_sqjr.png")
		end
		self.txt_xuanyan:setText(item.declaration)
    	--self.txt_zdl:setText("帮派战斗力:"..item.power)
    	self.txt_zdl:setText(stringUtils.format(localizable.common_faction_CE,item.power))
	end
end

function ApplyLayer:onBtnMoreClickHandl()
	self.updateWithMore = true
	RankManager:RequestDataFromServerByMore(RankListType.Rank_List_FactionLevel, 0, self.cell_curr_max + cell_add_num)
end

function ApplyLayer.sqjrButtonClick(btn)
	
	local self = btn.logic


	if self.tableChoseCell then
		local item = self.cellDataMap[self.tableChoseIdx]

		if item.apply then
			--取消申请
			FactionManager:requestCancelJoinFaction( item.guildId )
		else
			if FactionManager:checkCanJoinFaction() == false then
				--toastMessage("退出帮派时间没有超过24小时")
				toastMessage(localizable.applyLayer_exit_tips)

				return
			end
			--申请
			if FactionManager:getRequestOneKeyTimes() <= 0 then
				--toastMessage("已达到申请上限")
				toastMessage(localizable.applyLayer_text1)
			else
				FactionManager:requestJoinFaction( item.guildId )
			end			
		end
	end
end

function ApplyLayer:sqjrButtonOK()

	local item = self.cellDataMap[self.tableChoseIdx]
	if item.apply then 
		self.btn_sqjr:setTextureNormal("ui_new/faction/btn_qxsq.png")
	else
		self.btn_sqjr:setTextureNormal("ui_new/faction/btn_sqjr.png")
	end
	self.TabView:reloadData()

end
function ApplyLayer.yjsqButtonClick(btn)
	--一键申请
	if FactionManager:checkCanJoinFaction() == false then
		--toastMessage("退出帮派时间没有超过24小时")
		toastMessage(localizable.applyLayer_exit_tips)
		return
	end	

	local idNum = FactionManager:getRequestOneKeyTimes()
	if idNum > 0 then
		FactionManager:requestJoinFactionOneKey({0})
	else
		toastMessage(localizable.applyLayer_text1)
		--toastMessage("已达到申请上限")
	end
	-- 	local ids = RankManager:getApplyIdTable(idNum)
	-- 	if #ids > 0 then
	-- 		FactionManager:requestJoinFactionOneKey(ids)
	-- 	end
	-- else
	-- 	toastMessage("已达到申请上限")
	-- end
end

function ApplyLayer.createButtonClick(btn)
	--创建帮派
	if FactionManager:checkCanJoinFaction() == false then
		--toastMessage("退出帮派时间没有超过24小时")
		toastMessage(localizable.applyLayer_exit_tips)		
		return
	end	
	FactionManager:openCreateFaction()
end


function ApplyLayer.rankButtonClick(btn)
	--帮派排行榜
	FactionManager:openFactionRankLayer()
end

function ApplyLayer.chazhaoButtonClick(btn)
	--帮派查询

	local guildId = btn.logic.playernameInput:getText()
	if guildId == nil or guildId == "" then
		--toastMessage("请输入帮派ID")
		toastMessage(localizable.applyLayer_text2)
		return
	end

	FactionManager:requestOtherFactinoInfo(guildId)
end

function ApplyLayer:getRankDataMap(userData)
	--get server data
	self.cellDataMap = nil
	self.cellDataMap = userData.rankInfo

	-- print("self.cellDataMap = ",self.cellDataMap)
	self.txt_none:setVisible(false)
	if self.cellDataMap == nil then
		self.cell_curr_max = 0
	   	self.TabView:reloadData()
	   	-- toastMessage("虚席以待")
	   	self.txt_none:setVisible(true)
		return
	end
	

	local map_size = #self.cellDataMap

	self.needViewMoreBtn = true
	if self.isFristIn then
		--第一次请求数据
		self.isFristIn = false
		self.cell_curr_max = cell_init_num

		print("第一次请求数据 = ",cell_init_num)
		if map_size < 10 then
			self.cell_curr_max = map_size
			self.needViewMoreBtn = false
		end

		self.tableChoseIdx = 1

		self.TabView:reloadData()
		self.TabView:setScrollToBegin()
	else
		--加载更多请求数据	
		local oldNum = self.cell_curr_max
		self.cell_curr_max = self.cell_curr_max + cell_add_num
		if map_size < (self.cell_curr_max - 1) then
			self.cell_curr_max = map_size
			self.needViewMoreBtn = false
		end

		if self.cell_curr_max >= 50 then
			self.cell_curr_max = 50
			self.needViewMoreBtn = false
		end

		local numDx = cell_h*(self.cell_curr_max - oldNum)
		self.TabView:reloadData()
		self.TabView:setContentOffset(ccp(0,-numDx))
	end 	
end

return ApplyLayer