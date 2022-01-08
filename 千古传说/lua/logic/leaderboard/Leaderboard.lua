
local Leaderboard = class("Leaderboard", BaseLayer)

local cell_h = 100
local cell_w = 494
local cell_num = 11
local cell_add_num = 10



--[[
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.leaderboard.Leaderboard.lua")
	layer:setIndex(RankListType.Rank_List_fumo)
    AlertManager:show();
]]
function Leaderboard:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.Leaderboard.LeaderboardNEW")
end

function Leaderboard:initUI( ui )

	print("Leaderboard:initUI")
	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.Leaderboard,{HeadResType.COIN,HeadResType.SYCEE,HeadResType.PUSH_MAP}) 

    self.bgLeft1 = TFDirector:getChildByPath(ui, "bgLeft1")
    self.txtMyzan = TFDirector:getChildByPath(ui, "txtMyzan")

	self.isFristIn = true
	self.isTiaoZhan = false
	self.btn_curr_type = 0
	self.cell_curr_max = 0
	self.cell_max = 50

	self.cell_select_index = 1

	--存放动画ID
	self.StorageRoleID = {}

	--初始化5个排行榜
	self.BtnTab = { TFDirector:getChildByPath(ui, "btn_yxb"),
					TFDirector:getChildByPath(ui, "btn_qhb"),
					TFDirector:getChildByPath(ui, "btn_cgb"),
					TFDirector:getChildByPath(ui, "btn_xkb"),
					TFDirector:getChildByPath(ui, "btn_sbb"),
					TFDirector:getChildByPath(ui, "btn_fmb")}
	self.BtnTab[13] = TFDirector:getChildByPath(ui, "btn_slb")
   	self.btn_normalTextures = {
	   	'ui_new/leaderboard/btn_yx.png',
	   	'ui_new/leaderboard/btn_qh.png',
	   	'ui_new/leaderboard/btn_cg.png',
	   	'ui_new/leaderboard/btn_xk.png',
	   	'ui_new/leaderboard/btn_sb.png',
	    'ui_new/leaderboard/btn_fm.png'}
	self.btn_normalTextures[13] = 'ui_new/leaderboard/btn_sl.png'
    self.btn_selectedTextures = {
	    'ui_new/leaderboard/btn_yx_hl.png',
	    'ui_new/leaderboard/btn_qh_hl.png',
	    'ui_new/leaderboard/btn_cg_hl.png',
	    'ui_new/leaderboard/btn_xk_hl.png',
	    'ui_new/leaderboard/btn_sb_hl.png',
		'ui_new/leaderboard/btn_fm_hl.png'}
    self.btn_selectedTextures[13] = 'ui_new/leaderboard/btn_sl_hl.png'
    --关闭神兵榜
    self.BtnTab[5]:setVisible(false)

    self.txtDianzancishu = TFDirector:getChildByPath(ui, "txtDianzancishu")
    self.txtDZCS = TFDirector:getChildByPath(ui, "txtDZCS")

    --self.ShenBingObj = require("lua.logic.leaderboard.RankShenbinDetails"):new()
    --self.ShenBingObj:initUI(ui)
    --self.ShenBingObj:setVisible(false)

    self.HeroObj = require("lua.logic.leaderboard.RankHeroDetails"):new()
    self.HeroObj:initUI(ui,RankListType.Rank_List_Hero,self)
    self.HeroObj:setVisible(false)

    self.XiakeObj = require("lua.logic.leaderboard.RankXiakeDetails"):new()
    self.XiakeObj:initUI(ui,self)
    self.XiakeObj:setVisible(false)

    self.currRankObj = nil
    self.Panel_sv = TFDirector:getChildByPath(ui, "Panel_sv")
    self.img_hide1 = TFDirector:getChildByPath(ui, "img_hide1")
    self.img_hide2 = TFDirector:getChildByPath(ui, "img_hide2")
    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "panel_list")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:getParent():addChild(self.TabView)
    self.TabView:setPosition(self.TabViewUI:getPosition())
    self.TabViewUI_size = self.TabViewUI:getContentSize()


    self.txtDianzancishu:setVisible(false)
    self.txtDZCS:setVisible(false)
    self.txtMyzan:setVisible(false)
   	self.HeroObj:setDefault()

end

function Leaderboard:removeUI()
	self.super.removeUI(self)
	if self.allPanels then
		for k,v in pairs(self.allPanels) do
			if v ~= nil and v.panel ~= nil then
				v.panel:dispose()
				v.panel:removeFromParent()
				v.panel = nil
			end
		end	
		self.allPanels = {}
	end
end
function Leaderboard:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    if self.HeroObj then
    	self.HeroObj:setVisible(false)
    end
    -- if self.ShenBingObj then
    -- 	self.ShenBingObj:setVisible(false)
    -- end
    if self.XiakeObj then
    	self.XiakeObj:setVisible(false)
    end
    if self.updateTimerID then
    	TFDirector:removeTimer(self.updateTimerID)
    end
    --self:registerEvents()
    --self:removeUI()    
end

function Leaderboard:setIndex( type )
	self.isFristIn = true
	self.btn_curr_type = type
	RankManager:RequestDataFromServer(type, 0, 10)
	if self.isMoveIn then
		self.isMoveIn = false
		self.ui:runAnimation("Action0",1);
	end
end

function Leaderboard:brushShaLuBang(data)
	if self.btn_curr_type ~= RankListType.Rank_List_ShaLu then
		return
	end
	if data.result == 0 then
		self.isTiaoZhan = true
		self:setIndex(RankListType.Rank_List_ShaLu)
	else
		RankManager:pushTiaoZhanId(data.playerId)
		self.TabView:reloadData()
	end
end

function Leaderboard:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function Leaderboard:tableScroll()
	local posX = self.Panel_sv:getContentOffset().x
	if posX >= 0 then
		self.img_hide1:setVisible(false)
	else
		self.img_hide1:setVisible(true)
	end
	local minPosX = self.Panel_sv:getSize().width-self.Panel_sv:getInnerContainerSize().width
	if posX <= minPosX then
		self.img_hide2:setVisible(false)
	else
		self.img_hide2:setVisible(true)
	end
end

function Leaderboard:registerEvents()

	print("---------------registerEvents")
	self.isMoveIn = true
	self.super.registerEvents(self)

	for k,v in pairs(self.BtnTab) do
		v.logic = self
        v:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tabButtonClick))
    end

    if self.generalHead then
        self.generalHead:registerEvents()
    end
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    --self.TabView:addMEListener(TFTABLEVIEW_TOUCHED, self.tableCellTouched)  
    self.updateTimerID = TFDirector:addTimer(50, -1, nil, 
    function()
        self:tableScroll()
    end)
    --监听数据请求回调
	self.requestDataCallBack = function (event)
		local userData = event.data[1][1]
		self:getRankDataMap(userData)
	end
	TFDirector:addMEGlobalListener(RankManager.GETRANKDATADONE, self.requestDataCallBack)

    --监听阵容变化 需要主动刷新数据
	self.refreshDataOfRankCallBack = function (event)
		self:refreshDataOfRank()
	end
	TFDirector:addMEGlobalListener(OtherPlayerManager.REFRESHDATAOFRANK, self.refreshDataOfRankCallBack)

	--监听点赞回调
	self.pariseSuccessCallBack = function (event)
		local playerId = event.data[1][1]
		self:pariseSuccess(playerId)
	end
	TFDirector:addMEGlobalListener(NiuBilityManager.PRAISE_SUCCESS, self.pariseSuccessCallBack)

--    self.ui:setAnimationCallBack("Action0", TFANIMATION_END, function()
--	    print("Done!!!!!!!!!!!!!!!!!!!!!!!!!!")
--    end)
	self.tiaozhanEndCallBack = function ( event )
		print("self.tiaozhanEndCallBack",event.data)
		if tonumber(event.data[1].type) == AdventureManager.fightType_2 then
			self:brushShaLuBang(event.data[1])
		end
	end
	TFDirector:addMEGlobalListener(AdventureManager.fightEndMessage, self.tiaozhanEndCallBack)

	self.unableToChallengeCallBack = function ( event )
		if event.data[1].type == AdventureManager.fightType_2 then
			self:setIndex(self.btn_curr_type)
		end
	end
	TFDirector:addMEGlobalListener(AdventureManager.unableToChallenge, self.unableToChallengeCallBack)
end

function Leaderboard:removeEvents()

	print("Leaderboard:removeEvents")
    for k,v in pairs(self.BtnTab) do
        v:removeMEListener(TFWIDGET_CLICK)
    end

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
	--self.TabView:removeMEListener(TFTABLEVIEW_TOUCHED)

	TFDirector:removeMEGlobalListener(RankManager.GETRANKDATADONE, self.requestDataCallBack)
	TFDirector:removeMEGlobalListener(NiuBilityManager.PRAISE_SUCCESS, self.pariseSuccessCallBack)
	TFDirector:removeMEGlobalListener(OtherPlayerManager.REFRESHDATAOFRANK, self.refreshDataOfRankCallBack)
	TFDirector:removeMEGlobalListener(AdventureManager.fightEndMessage, self.tiaozhanEndCallBack)
	TFDirector:removeMEGlobalListener(AdventureManager.unableToChallenge, self.unableToChallengeCallBack)

    if self.generalHead then
        self.generalHead:removeEvents()
    end

    self.super.removeEvents(self)
end


function Leaderboard.tabButtonClick(sender)

	local self = sender.logic
	local index,i = 0,1

	for k,v in pairs(self.BtnTab) do
		if(v == sender) then
			index = k
			break
		end
	end

	if index == 0 then
		index = 1
	end

	if(index ~= self.btn_curr_type) then
		self:setIndex(index)
		self:ReleaseRoleID()
	end	
end

function Leaderboard:SetAllTabNormal()

	for k,v in pairs(self.BtnTab) do
		self.BtnTab[k]:setTextureNormal(self.btn_normalTextures[k])	
	end
	
end


function Leaderboard.cellSizeForTable(table,idx)
    return cell_h,cell_w
end

function Leaderboard.tableCellAtIndex(table, idx)

	local self = table.logic
	local cell = table:dequeueCell()
	self.allPanels = self.allPanels or {}


	cell = self:CreateTableCell(cell)
	

    if cell.panel then
    	cell.index = idx + 1
    	--if cell.index == self.cell_curr_max and cell.index % 10 == 1 and self.cell_curr_max ~= 1 then
    	if cell.index == self.cell_curr_max and self.needViewMoreBtn then
    		cell.panel:SetData(self, nil)
    	else
    		if self.isFristIn == false then
    			local item = self.cellDataMap.rankInfo[cell.index]
    			cell.panel:SetData(self, item)
    		end
    	end
	end

    return cell
end

function Leaderboard.numberOfCellsInTableView(table)
	local self = table.logic
    return self.cell_curr_max
end

function Leaderboard:tableCellSelect( index )

	if self.cell_select_index == index then 
		return
	end

	self.cell_select_index = index

	self:ReleaseRoleID()

	self.currRankObj:showDetails(self.cellDataMap.rankInfo[self.cell_select_index])
	for k,v in pairs(self.allPanels) do
		if v ~= nil then
			if v.index == self.cell_select_index then
				v.panel:setChoiseVisiable(true)
			else 
				v.panel:setChoiseVisiable(false)
			end
		end
	end
end

function Leaderboard:UpdateList()
	RankManager:RequestDataFromServerByMore(self.btn_curr_type, 0, self.cell_curr_max + cell_add_num)
end

function Leaderboard:CreateTableCell(cell)

	if nil == cell then
	    cell = TFTableViewCell:create()
	    local newIndex = #self.allPanels + 1
	    self.allPanels[newIndex] = cell
	end

	local panel = nil

	if cell.type ~= nil and cell.type ~= self.btn_curr_type then
		cell.panel:dispose()
		cell.panel:removeFromParent()		
		cell.panel = nil
		cell.type = nil
	end

	if cell.type == nil then
		if self.btn_curr_type == RankListType.Rank_List_Xiake then
	        panel = require('lua.logic.leaderboard.Xiakecell'):new()
        elseif self.btn_curr_type == RankListType.Rank_List_Shengbin then
        	panel = require('lua.logic.leaderboard.Shenbincell'):new()
        elseif self.btn_curr_type == RankListType.Rank_List_fumo then
        	panel = require('lua.logic.leaderboard.fumoCell'):new()
        elseif self.btn_curr_type == RankListType.Rank_List_ShaLu then
        	panel = require('lua.logic.leaderboard.ShaLucell'):new()
    	else
    		panel = require('lua.logic.leaderboard.Qunhaocell'):new()
		end
		panel:setPosition(ccp(0,0))
	    cell:addChild(panel)
		cell.type = self.btn_curr_type
    	cell.panel = panel
	end

	return cell
end

function Leaderboard:SaveRoleID( id )
	local size = 1
	for k,v in pairs(self.StorageRoleID) do
		if v == id then
			return
		end
		size = size + 1
	end

	self.StorageRoleID[size] = id
end

function Leaderboard:ReleaseRoleID()
	print("-----------------ReleaseRoleID--------------------")
	for i=1,#self.StorageRoleID do
		GameResourceManager:deleRoleAniById(self.StorageRoleID[i])
	end
	self.StorageRoleID = {}
end

function Leaderboard:UpdateZanNum(playerId)

	if NiuBilityManager.remaining <= 0 then
		--toastMessage("剩余点赞次数不够!");
		toastMessage(localizable.leaderboard_not_times)
		return false
	else
		print("UpdateZanNum playerId = "..playerId)
		NiuBilityManager:praisePerson(playerId)
		return true
	end
end

function Leaderboard:pariseSuccess( playerId )

	print("pariseSuccess playerId = "..playerId)

	RankManager:pariseSuccess( playerId )
	if self.btn_curr_type == RankListType.Rank_List_ShaLu then
		self.txtDianzancishu:setVisible(false)
    	self.txtDZCS:setVisible(false)
    	self.txtMyzan:setVisible(false)
    else
    	self.txtDZCS:setString(NiuBilityManager.remaining)
    	--self.txtMyzan:setString(self.cellDataMap.praiseCount.."赞")
	self.txtMyzan:setString(stringUtils.format(localizable.common_zan,self.cellDataMap.praiseCount))
		self.txtDianzancishu:setVisible(true)
		self.txtDZCS:setVisible(true)
		self.txtMyzan:setVisible(true)
	end
	self.cellDataMap = RankManager:getDataMapByType( self.btn_curr_type )
	self.TabView:reloadData()

end
function Leaderboard:getRankDataMap(userData)
	--get server data
	self.cellDataMap = nil
	self.cellDataMap = userData
	-- if self.btn_curr_type == RankListType.Rank_List_Wuliang then
	-- 	self.cellDataMap.rankInfo = nil
	-- end
	if self.cellDataMap.rankInfo == nil then
		self.cell_curr_max = 0
	    self.txtDianzancishu:setVisible(false)
	    self.txtDZCS:setVisible(false)
	    self.txtMyzan:setVisible(false)
	   	self.XiakeObj:setVisible(false)
	   	self.HeroObj:setVisible(false)
	   	self.HeroObj:setDefault()
	   	self.TabView:reloadData()
		self:SetAllTabNormal()
		self.BtnTab[self.btn_curr_type]:setTextureNormal(self.btn_selectedTextures[self.btn_curr_type])
	   	--toastMessage("虚席以待")
	   	toastMessage(localizable.common_wait)
		return
	end

	local map_size = #self.cellDataMap.rankInfo

	self.needViewMoreBtn = true
	if self.isFristIn then
		--第一次请求数据
		self.isFristIn = false
		self.cell_curr_max = cell_num

		if map_size < 10 then
			self.cell_curr_max = map_size
			self.needViewMoreBtn = false
		end

		self.cell_select_index = 1
		self:SetAllTabNormal()
		self.BtnTab[self.btn_curr_type]:setTextureNormal(self.btn_selectedTextures[self.btn_curr_type])


		self.HeroObj:setVisible(false)
		--self.ShenBingObj:setVisible(false)
		self.XiakeObj:setVisible(false)

		if self.btn_curr_type == RankListType.Rank_List_Xiake then
			self.currRankObj = self.XiakeObj
		elseif self.btn_curr_type == RankListType.Rank_List_Shengbin then
			self.currRankObj = self.ShenBingObj
		else
			self.currRankObj = self.HeroObj
		end
		self.TabView:reloadData()
		--self.TabView:setContentOffset(ccp(0,-(cell_num*cell_h - self.TabViewUI_size.height)))
		if self.isTiaoZhan ~= true then
			self.TabView:setScrollToBegin()
			if self.btn_curr_type == RankListType.Rank_List_Hero then
				self.Panel_sv:scrollToLeft(0.2,false)
			elseif self.btn_curr_type == RankListType.Rank_List_ShaLu then
				self.Panel_sv:scrollToRight(0.2,false)
			end
		end
		self.isTiaoZhan = false
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

	
	self.currRankObj:setVisible(true)
	self.currRankObj:showMyDetails(self.cellDataMap)
	self.currRankObj:showDetails(self.cellDataMap.rankInfo[self.cell_select_index])
	if self.btn_curr_type == RankListType.Rank_List_ShaLu then
		self.txtDianzancishu:setVisible(false)
    	self.txtDZCS:setVisible(false)
    	self.txtMyzan:setVisible(false)
    else
    	self.txtDZCS:setString(NiuBilityManager.remaining)
    	--self.txtMyzan:setString(self.cellDataMap.praiseCount.."赞")
	self.txtMyzan:setString(stringUtils.format(localizable.common_zan,self.cellDataMap.praiseCount))
		self.txtDianzancishu:setVisible(true)
		self.txtDZCS:setVisible(true)
		self.txtMyzan:setVisible(true)
	end
end

function Leaderboard:refreshDataOfRank()
	
	--toastMessage("排行榜信息更新")
	toastMessage(localizable.leaderboard_update)
	RankManager:setDelayTimeZero(self.btn_curr_type)
	self:setIndex(self.btn_curr_type)

end

return Leaderboard