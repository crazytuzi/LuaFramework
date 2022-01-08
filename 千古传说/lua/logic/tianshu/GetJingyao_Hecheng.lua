--[[
    精要合成与获取途径界面
]]

local GetJingyao_Hecheng = class("GetJingyao_Hecheng", BaseLayer)

local AdventureMissionLayer = require("lua.logic.youli.AdventureMissionLayer")

GetJingyao_Hecheng.EnumShowStatus = 
{
    STATUS_HECHENG = 1,
    STATUS_GETWAY = 2
}

GetJingyao_Hecheng.EnumPage = 
{
    PAGE_JINGYAO = 1,
    PAGE_PIECE = 2
}

--GetJingyao_Hecheng.TEXT_WEIKAIFANG = "暂无掉落"
GetJingyao_Hecheng.TEXT_WEIKAIFANG = localizable.Tianshu_jingyao_text1


function GetJingyao_Hecheng:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.tianshu.GetJingYao_hecheng")
end

function GetJingyao_Hecheng:setDelegate(logic)
    self.logic = logic
end

function GetJingyao_Hecheng:loadData(jingyaoId, page)
    self.jingyaoId = jingyaoId
    if SkyBookManager:isJingyaoCanHecheng(jingyaoId) then
        self.status = self.EnumShowStatus.STATUS_HECHENG
    else
        self.status = self.EnumShowStatus.STATUS_GETWAY
    end
    self.page = page
    self:refreshUI()
end

function GetJingyao_Hecheng:refreshUI()
    print("++++++ {{{{{{}}}}}} ++++++")
    if self.page == self.EnumPage.PAGE_JINGYAO then
        self:drawMadeWay()
    else
        self:drawGetWay()
    end
end

function GetJingyao_Hecheng:onShow()
    self.super.onShow(self)     
    self:refreshUI()
end

function GetJingyao_Hecheng:initUI(ui)
	self.super.initUI(self,ui)

    self.txt_bookname =  TFDirector:getChildByPath(ui, "txt_bookname")

    --合成途径
    self.panel_madeway = TFDirector:getChildByPath(ui, "pannel_madeway")

    self.img_bg = TFDirector:getChildByPath(self.panel_madeway, "img_bg")
    --self.panel_madeway.hc = TFDirector:getChildByPath(self.panel_madeway, "img_hc1v1")
    self.panel_des_book = TFDirector:getChildByPath(self.panel_madeway, "panel_des_book")
    self.panel_src_book = TFDirector:getChildByPath(self.panel_madeway, "panel_src_book1")
    self.panel_des_book.img_quality = TFDirector:getChildByPath(self.panel_des_book, "img_quality")
    self.panel_des_book.img_equip = TFDirector:getChildByPath(self.panel_des_book, "img_equip")
    self.panel_src_book.img_quality = TFDirector:getChildByPath(self.panel_src_book, "img_quality")
    self.panel_src_book.img_quality.logic = self
    self.panel_src_book.img_equip = TFDirector:getChildByPath(self.panel_src_book, "img_equip")
    self.txt_need = TFDirector:getChildByPath(self.panel_src_book, "txt_need")
    self.txt_num = TFDirector:getChildByPath(self.panel_src_book, "txt_num")

    self.btn_hecheng    =  TFDirector:getChildByPath(ui, "btn_hecheng")
    self.btn_hecheng.logic = self
    self.panel_madeway:setVisible(true)
    
    -- 获取途径
    self.panel_getway = TFDirector:getChildByPath(ui, "pannel_getway")
    self.panel_way_book = TFDirector:getChildByPath(ui, "panel_way_book")
    self.panel_way_book.img_quality = TFDirector:getChildByPath(self.panel_way_book, "img_quality")
    self.panel_way_book.img_equip = TFDirector:getChildByPath(self.panel_way_book, "img_equip")
    self.panel_getway_list = TFDirector:getChildByPath(ui, "pannel_getwaylist")
    self.btn_fanhui = TFDirector:getChildByPath(ui, "btn_fanhui")
    self.btn_fanhui.logic = self
    self.panel_getway:setVisible(false)

    --产出cell
    self.bg_cell = TFDirector:getChildByPath(ui, "bg_cell")
    self.bg_cell.txt_leveldesc = TFDirector:getChildByPath(ui, "txt_leveldesc")
    self.bg_cell.txt_levelopen = TFDirector:getChildByPath(ui, "txt_levelopen")
    self.bg_cell:setVisible(false)

    self.btn_quickGet = TFDirector:getChildByPath(ui, "btn_quickGet")
    self.btn_quickGet.logic = self
end

function GetJingyao_Hecheng:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_hecheng:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHechengClickHandle))
    self.btn_fanhui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBackClickHandle))
    self.panel_src_book.img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onPieceClickHandle))
    self.btn_quickGet:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQuickGetClickHandle))

    self.quickPassCallBack = function(event)       
        if self and self.refreshUI then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(MissionManager.QUICK_PASS_RESULT ,self.quickPassCallBack)
end


function GetJingyao_Hecheng:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(MissionManager.QUICK_PASS_RESULT, self.quickPassCallBack)
    self.quickPassCallBack = nil
end

function GetJingyao_Hecheng:removeUI()
    self.super.removeUI(self)
end


function GetJingyao_Hecheng.onHechengClickHandle(sender)
    local self = sender.logic

    print("++++++merge jingyaoId +++++++,", self.jingyaoId)
    if SkyBookManager:isJingyaoCanHecheng(self.jingyaoId) then
        SkyBookManager:requestEssentialMerge(self.jingyaoId)
    else
        --toastMessage("碎片不够合成")
        toastMessage(localizable.Tianshu_hecheng_text1)
    end
end

function GetJingyao_Hecheng.onQuickGetClickHandle(sender)
    local self = sender.logic

    SkyBookManager:oneKeyToHechengAndGet(self.jingyaoId)
end

function GetJingyao_Hecheng.onPieceClickHandle(sender)
    local self = sender.logic

    self:loadData(self.jingyaoId, self.EnumPage.PAGE_PIECE)
end

function GetJingyao_Hecheng:drawMadeWay()
    self.panel_madeway:setVisible(true)
    self.panel_getway:setVisible(false)

    local item = ItemData:objectByID(tonumber(self.jingyaoId))
    self.txt_bookname:setText(item.name)
    self.panel_des_book.img_quality:setScale(0.7)
    self.panel_des_book.img_quality:setTextureNormal(GetColorIconByQuality(item.quality))
    self.panel_des_book.img_equip:setTexture(item:GetPath())

    item = EssentialData:objectByID(tonumber(self.jingyaoId))
    if not item then
        return
    end

    local consume = item.comsume
    local tab = string.split(consume, "_")
    local pieceId = tab[1]
    local pieceNum = tab[2]
    local bagItem = BagManager:getItemById(tonumber(pieceId))
    local num = 0
    if bagItem then
        num = bagItem.num
    end
    local pieceTemplate = ItemData:objectByID(tonumber(pieceId))

    self.panel_src_book.img_quality:setTextureNormal(GetBackgroundForFragmentByQuality(pieceTemplate.quality))    
    self.panel_src_book.img_quality:setScale(0.52)
    self.panel_src_book.img_equip:setTexture(pieceTemplate:GetPath())
    --self.panel_src_book.img_equip:setScale(0.5)
    Public:addPieceImg(self.panel_src_book.img_equip, {type = EnumDropType.GOODS,itemid = tonumber(pieceId)}, true, 1.05)

    self.txt_num:setText("/" .. pieceNum)
    self.txt_need:setText(num)

    self.txt_num:setColor(ccc3(0, 0, 0))
    self.txt_need:setColor(ccc3(0, 0, 0))

    if num < tonumber(pieceNum) then
        self.txt_need:setColor(ccc3(255, 0, 0))
    end

    --self.txt_num:setColor(ccc3(0, 0, 0))
    --self.txt_need:setColor(ccc3(0, 0, 0))
end

function GetJingyao_Hecheng:drawGetWay()
    self.panel_madeway:setVisible(false)
    self.panel_getway:setVisible(true)
    self.btn_fanhui:setVisible(true)

    local item = ItemData:objectByID(tonumber(self.jingyaoId))
    self.txt_bookname:setText(item.name)

    item = EssentialData:objectByID(tonumber(self.jingyaoId))
    if not item then
        return
    end

    local consume = item.comsume
    local tab = string.split(consume, "_")
    local pieceId = tonumber(tab[1])
    local pieceNum = tonumber(tab[2])
    local bagItem = BagManager:getItemById(tonumber(pieceId))
    local num = 0
    if bagItem then
        num = bagItem.num
    end
    local pieceTemplate = ItemData:objectByID(tonumber(pieceId))

    self.panel_way_book.img_quality:setTextureNormal(GetBackgroundForFragmentByQuality(pieceTemplate.quality))    
    self.panel_way_book.img_quality:setScale(0.6)
    self.panel_way_book.img_equip:setTexture(pieceTemplate:GetPath())
    self.panel_way_book.img_equip:setScale(0.65)

    Public:addPieceImg(self.panel_way_book.img_equip,{type = EnumDropType.GOODS,itemid = tonumber(pieceId)}, true)

    --Public:addPieceImg(self.panel_way_book.img_equip, {type = EnumDropType.GOODS, itemid = pieceId})
 
    self:drawGetWayList(pieceId, pieceNum)
end

function GetJingyao_Hecheng:drawGetWayList(pieceId, pieceNum)
    local pieceInfo  = ItemData:objectByID(pieceId)
    self.output = pieceInfo.show_way

    if self.output ~= "" then
        self.outputList  = string.split(self.output, "|")
        self.outputNum   = #self.outputList

        if self.outputNum > 0 then
            --self:drawOutPutList()
        else
            self.outputNum = 1
            self.outputList = {}
            self.outputList[1] = -1
        end
    else
        self.outputNum = 1
        self.outputList = {}
        self.outputList[1] = -1
    end
    self:drawOutPutList()

    --local img_quality = TFDirector:getChildByPath(self.panel_getway, "img_quality")
    --local img_equip = TFDirector:getChildByPath(self.pannel_getway, "img_equip")

    --local bgPic = getBookBackgroud(bookInfo.quality)

    --img_quality:setTextureNormal(bgPic)
    --img_equip:setTexture(bookInfo:GetPath())

    --img_quality:setTouchEnabled(false)
    --img_equip:setScale(0.7)

    --Public:addPieceImg(img_equip,{type = EnumDropType.GOODS, itemid = bookid})
end

--返回按钮handle
function GetJingyao_Hecheng.onBackClickHandle(sender)
    local self = sender.logic

    if self.page == self.EnumPage.PAGE_PIECE then
        self:loadData(self.jingyaoId, self.EnumPage.PAGE_JINGYAO)
    elseif self.page == self.EnumPage.PAGE_JINGYAO then
        AlertManager:close()
    end
end

--绘制产出列表
function GetJingyao_Hecheng:drawOutPutList()
    if not self.panel_getway_list then
        return
    end

    self.panel_outnode = TFDirector:getChildByPath(self.panel_getway, "bg_cell")
    self.panel_outnode:setVisible(false)    

    if self.outputTableView ~= nil then
        self.outputTableView:setVisible(true)
        self.outputTableView:reloadData()
        self.outputTableView:setScrollToBegin(false)
        return
    end

    local tableView = TFTableView:create()
    tableView:setTableViewSize(self.panel_getway_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0, 0))
    self.outputTableView = tableView
    self.outputTableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, GetJingyao_Hecheng.cellSizeForTable_out)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, GetJingyao_Hecheng.tableCellAtIndex_out)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, GetJingyao_Hecheng.numberOfCellsInTableView_out)
    tableView:reloadData()

    self.panel_getway_list:addChild(tableView, 1)
end

function GetJingyao_Hecheng.cellSizeForTable_out(table, idx)
    return 70, 348
end

function GetJingyao_Hecheng.tableCellAtIndex_out(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = self.panel_outnode:clone()
        node:setName("JingyaoPieceOutPutCell")
        node:setPosition(ccp(180, 30))
        cell:addChild(node)
        node:setTag(617)
    end

    node = cell:getChildByTag(617)
    if self.outputList[idx + 1] == -1 then
        node.type = -1
        node.mission = -1
    else
        local output = string.split(self.outputList[idx + 1], "_")
        node.type    = tonumber(output[1])
        node.mission = tonumber(output[2])
    end

    print("{{{{{{{{{{{{")
    print(node.type, node.mission)
    node.logic   = self
    self:drawOutNode(node)

    node:setVisible(true)
    return cell
end

function GetJingyao_Hecheng.numberOfCellsInTableView_out(table)
    local self = table.logic

    return self.outputNum
end

--绘制产出列表cell
function GetJingyao_Hecheng:drawOutNode(node)    
    local txt_leveldesc  = TFDirector:getChildByPath(node, "txt_leveldesc")
    local txt_levelopen  = TFDirector:getChildByPath(node, "txt_levelopen")

    -- 不是关卡则return
    local type = node.type
    
    if type == -1 then
        local desc = self.TEXT_WEIKAIFANG
        txt_leveldesc:setText(desc)
        txt_levelopen:setText("")
        txt_leveldesc:setColor(ccc3(141,141,141))
        node:setTexture("ui_new/rolebook/bg_cell2.png")
        return
    end
    
    local missionId = node.mission

    local open = true
    local mission = AdventureMissionManager:getMissionById(missionId)
    if not mission then
        print("mission == nil ,missionId =" , missionId)
        return
    end
    if mission.starLevel == MissionManager.STARLEVEL0 then
        open = false
    end

    local map = AdventureMissionManager:getMapById(mission.map_id)
    txt_leveldesc:setText(map.name .. " " .. mission.name)
    local difficulty = mission.difficulty

    --local missionlist = AdventureMissionManager:getMissionListByMapIdAndDifficulty(mission.map_id, difficulty)

    --txt_leveldesc:setText(map.name .. " " .. mission.stagename)

    node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOutClickHandle), 1)

    node.mission = mission
    node.open = open

    if open then
        txt_leveldesc:setColor(ccc3(0,0,0))
        txt_levelopen:setColor(ccc3(0,0,0))
        --txt_levelopen:setText("(已开放)")
        txt_levelopen:setText(localizable.Tianshu_hecheng_text2)
        --txt_levelopen:setText()
        node:setTexture("ui_new/rolebook/bg_cell.png")
    else
        txt_leveldesc:setColor(ccc3(141,141,141))
        txt_levelopen:setColor(ccc3(141,141,141))
        --txt_levelopen:setText("(未开放)")
        txt_levelopen:setText(localizable.Tianshu_hecheng_text3)
        node:setTexture("ui_new/rolebook/bg_cell2.png")
    end
end

function GetJingyao_Hecheng.onOutClickHandle(sender)
    local self    = sender.logic
    local mission = sender.mission
    local open = sender.open

    item = EssentialData:objectByID(tonumber(self.jingyaoId))
    if not item then
        return
    end

    local consume = item.comsume
    local tab = string.split(consume, "_")
    local pieceId = tonumber(tab[1])
    local pieceNum = tonumber(tab[2])
    local bagItem = BagManager:getItemById(tonumber(pieceId))
    local num = 0
    if bagItem then
        num = bagItem.num
    end

    if open then
        --[[
        local layer = require("lua.logic.youli.AdventureMissionLayer"):new()
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
        AlertManager:show()
        layer:showMissionById(mission.id)
        ]]
        MissionManager:quickPassToGetFGoods(pieceId, pieceNum)
        local layer = AdventureManager:openMissLayer()
        if layer then 
            layer:showMissionById(mission.id)
        end
    else
        toastMessage(localizable.Tianshu_hecheng_text4)
    end
end

return GetJingyao_Hecheng