--[[
******帮派排行榜*******

	-- by quanhuan
	-- 2015/10/30
	
]]

local RankingList = class("RankingList",BaseLayer)

local cell_h = 77
local cell_w = 908
local cell_add_num = 10
local cell_num = cell_add_num + 1
local ImgSortTexture = {'ui_new/leaderboard/no1.png','ui_new/leaderboard/no2.png','ui_new/leaderboard/no3.png'}

function RankingList:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.RankingList")
end

function RankingList:initUI( ui )
	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.Rank_Faction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE}) 

    self.btnTable = {
        [1] = {
            btn = TFDirector:getChildByPath(ui, "btn_dengji"),
            normal = "ui_new/faction/tab_dengji2.png",
            touch = "ui_new/faction/tab_dengji1.png",
        },
        [2] = {
            btn = TFDirector:getChildByPath(ui, "btn_zhanli"),
            normal = "ui_new/faction/tab_zhanli2.png",
            touch = "ui_new/faction/tab_zhanli1.png",
        }
    }

    --self.txtTemp = {"帮派等级","帮派战力"}
    self.txtTemp = localizable.rankingList_text
    self.level_or_power = TFDirector:getChildByPath(ui, "txt_3")

    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "Panel_List")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.faction.RankingListCell")
    self.cellModel:retain()

    self.txt_none = TFDirector:getChildByPath(ui,"txt_none")

    self.currIdx = 1
    self.cellMax = 0
   
end

function RankingList:removeUI()
   	self.super.removeUI(self)
    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end
end

function RankingList:onShow()
    self.super.onShow(self)

    self.generalHead:onShow()
end

function RankingList:registerEvents()

	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    for i=1,#self.btnTable do
        self.btnTable[i].btn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnTabClickHandle))
        self.btnTable[i].btn.logic = self
        self.btnTable[i].btn.idx = i
    end
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.TabView:addMEListener(TFTABLEVIEW_TOUCHED, self.tableCellTouched)  

        --监听数据请求回调
    self.requestDataCallBack = function (event)
        local userData = event.data[1][1]
        self:getRankDataMap(userData)
        -- print("event = ",userData)
    end
    TFDirector:addMEGlobalListener(RankManager.GETRANKDATADONE, self.requestDataCallBack)


end

function RankingList:removeEvents()
	
    self.super.removeEvents(self)
    if self.generalHead then
        self.generalHead:removeEvents()
    end

    for i=1,#self.btnTable do
        self.btnTable[i].btn:removeMEListener(TFWIDGET_CLICK)
    end
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    self.TabView:removeMEListener(TFTABLEVIEW_TOUCHED)

    TFDirector:removeMEGlobalListener(RankManager.GETRANKDATADONE, self.requestDataCallBack)

    
end

function RankingList:dispose()
    self.super.dispose(self)

    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end


function RankingList.cellSizeForTable(table,idx)
    return cell_h,cell_w
end

function RankingList.numberOfCellsInTableView(table)
    local self = table.logic
    return self.cellMax
end

function RankingList.tableCellAtIndex(table, idx)

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

function RankingList:cellInfoSet(cell, panel, idx)

    if cell.boundData == nil then
        cell.boundData = true
        cell.on = TFDirector:getChildByPath(panel, "on")
        cell.imgSort = TFDirector:getChildByPath(panel, "Img_paiming")
        cell.txtSort = TFDirector:getChildByPath(panel, "txt_paiming")
        cell.txtId = TFDirector:getChildByPath(panel, "txt_2")
        cell.power = TFDirector:getChildByPath(panel, "txt_3")
        cell.txtName = TFDirector:getChildByPath(panel, "txt_4")
        cell.num = TFDirector:getChildByPath(panel, "txt_5")
        cell.presidentName = TFDirector:getChildByPath(panel, "txt_6")
        cell.btnMore = TFDirector:getChildByPath(panel, "more")
    end
    
    
    if idx == self.cellMax and self.needViewMoreBtn then
        cell.isMoreButton = true
        cell.on:setVisible(false)     
        cell.btnMore:setVisible(true)
    else
        cell.isMoreButton = false
        cell.on:setVisible(true)     
        cell.btnMore:setVisible(false)

        local item = self.cellDataMap[idx]
        cell.txtId:setText(item.guildId)
        if self.currIdx == 1 then
            --cell.power:setText(item.level..'级')
            cell.power:setText(stringUtils.format(localizable.common_LV,item.level))
        else
            cell.power:setText(item.power)
        end

        cell.txtName:setText(item.name)
        local maxNum = FactionManager:getFactionMaxMember(item.level)   
        cell.num:setText(item.memberCount.."/"..maxNum)
        cell.presidentName:setText(item.presidentName)

        if idx < 4 then
            cell.imgSort:setTexture(ImgSortTexture[idx])
            cell.imgSort:setVisible(true)
            cell.txtSort:setVisible(false)
        else
            cell.txtSort:setText(idx)
            cell.imgSort:setVisible(false)
            cell.txtSort:setVisible(true)
        end
    end
end

function RankingList.tableCellTouched(table,cell)
    
    local self = table.logic
    local idx = cell:getIdx() + 1

    if cell.boundData and cell.isMoreButton then
        --加载更多  
        play_press()
        self:onBtnMoreClickHandl()
        return
    end

end
function RankingList.btnTabClickHandle( btn )

    local self = btn.logic
    self.currIdx = btn.idx
    self:setEnterFirst(self.currIdx)

end

function RankingList:refreshButton()

    for i=1,#self.btnTable do
        if i == self.currIdx then
            self.btnTable[i].btn:setTextureNormal(self.btnTable[i].touch)
        else
            self.btnTable[i].btn:setTextureNormal(self.btnTable[i].normal)
        end
        self.level_or_power:setText(self.txtTemp[self.currIdx])
    end

end

function RankingList:setEnterFirst( idx )
    self.isFristIn = true
    self.currIdx = idx
    if idx == 1 then
        --等级榜
        RankManager:RequestDataFromServer(RankListType.Rank_List_FactionLevel, 0, 10)        
    elseif idx == 2 then
        --战力榜
        RankManager:RequestDataFromServer(RankListType.Rank_List_FactionPower, 0, 10)
    end
    self:refreshButton()
end

function RankingList:getRankDataMap(userData)

    self.cellDataMap = nil
    self.cellDataMap = userData.rankInfo

    self.txt_none:setVisible(false)
    if self.cellDataMap == nil then
        self.cellMax = 0
        self.TabView:reloadData()
        --toastMessage("虚席以待")
        self.txt_none:setVisible(true)
        return
    end

    local map_size = #self.cellDataMap

    self.needViewMoreBtn = true
    if self.isFristIn then
        --第一次请求数据
        self.isFristIn = false
        self.cellMax = cell_num

        if map_size < 10 then
            self.cellMax = map_size
            self.needViewMoreBtn = false
        end

        self.TabView:reloadData()
        self.TabView:setScrollToBegin()
    else
        --加载更多请求数据  
        local oldNum = self.cellMax
        self.cellMax = self.cellMax + cell_add_num
        if map_size < (self.cellMax - 1) then
            self.cellMax = map_size
            self.needViewMoreBtn = false
        end
        if self.cellMax >= 50 then
            self.cellMax = 50
            self.needViewMoreBtn = false
        end


        local numDx = cell_h*(self.cellMax - oldNum)
        self.TabView:reloadData()
        self.TabView:setContentOffset(ccp(0,-numDx))
    end   

end

function RankingList:onBtnMoreClickHandl()

    if self.currIdx == 1 then
        --等级榜
        RankManager:RequestDataFromServerByMore(RankListType.Rank_List_FactionLevel, 0, self.cellMax + cell_add_num)
    elseif self.currIdx == 2 then
        --战力榜
        RankManager:RequestDataFromServerByMore(RankListType.Rank_List_FactionPower, 0, self.cellMax + cell_add_num)
    end

end

return RankingList