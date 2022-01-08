--[[
******角色详情*******
    -- by king
    -- 2015/4/17
]]

local RoleBook_Hecheng = class("RoleBook_Hecheng", BaseLayer)
-- local typeDesc = {"关卡", "群豪谱", "无量山", "摩诃崖", "护驾", "龙门镖局", "商店", "招募" ,"金宝箱", "银宝箱", "暂无途径产出", "", ""}
local typeDesc = EnumItemOutPutType

function RoleBook_Hecheng:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.role_new.RoleBook_hecheng")
end

function RoleBook_Hecheng:AddBook(bookId)
    self.bookCount                = self.bookCount + 1
    self.bookList[self.bookCount] = bookId

    self:redraw()
end

function RoleBook_Hecheng:RemoveBook(index)
    -- 移除index之后的
    for i=index+1, self.bookCount do
        self.bookList[i] = 0
    end
    self.bookCount = index

    self:redraw()
end

function RoleBook_Hecheng:popBook()
    -- 移除最上面的
    if self.bookCount == 1 then
        return
    end

    self.bookList[self.bookCount] = 0
    self.bookCount = self.bookCount - 1

    self:redraw()
end

function RoleBook_Hecheng:redraw()

    local bookId = self.bookList[self.bookCount]

    if bookId == nil then
        return
    end

    -- 判断该书是否可以被合成
    local bookInfo  = MartialData:objectByID(bookId)
    local count     = 0   --所需材料个数
    local name      = ""

    -- 该节点是碎片
    if bookInfo == nil then
        local Goods  = ItemData:objectByID(bookId)

        name = Goods.name
    else
        local MartialList   = bookInfo:getMaterialTable()  -- 合成材料

        
        for i,v in pairs(MartialList) do
            count = count + 1
        end

        name = bookInfo.goodsTemplate.name
    end



    self.txt_bookname:setText(name)
    self.pannel_madeway:setVisible(false)
    self.pannel_getway:setVisible(false)

    -- 可以合成
    if count > 0 then 
        self:drawMadeWay()

        self.pannel_madeway:setVisible(true)
    -- 不可以合成
    else
        print("该书不可以再被合成了")
        self:drawReceive()

        self.pannel_getway:setVisible(true)
    end 

    self:drawClikHistoryList()
end

function RoleBook_Hecheng:onShow()
    self.super.onShow(self)
      
    self:refreshUI()
end

function RoleBook_Hecheng:refreshUI()
    if not self.isShow then
        return
    end

end

function RoleBook_Hecheng:showBtnHeCheng(bVisible)
    self.btn_hecheng:setVisible(bVisible)
    self.btn_quickGet:setVisible(bVisible)
end

function RoleBook_Hecheng:initUI(ui)
	self.super.initUI(self,ui)


    -- 
    self.txt_bookname =  TFDirector:getChildByPath(ui, "txt_bookname")

    -- 四种合成方法
    self.panel_HechengList     = {}
    for i=1,4 do
        self.panel_HechengList[i]          =  TFDirector:getChildByPath(ui, "img_hc1v" .. i)
        self.panel_HechengList[i]:setVisible(false)
    end
    self.MidPos = self.panel_HechengList[1]:getPosition()
    self.pannel_madeway = TFDirector:getChildByPath(ui, "pannel_madeway")
    self.btn_hecheng    =  TFDirector:getChildByPath(ui, "btn_hecheng")
    self.btn_hecheng    =  TFDirector:getChildByPath(ui, "btn_hecheng")
    self.btn_quickGet    =  TFDirector:getChildByPath(ui, "btn_quickGet")
    self.btn_hecheng.logic = self
    self.btn_quickGet.logic = self


    -- 获取途径
    self.pannel_getway = TFDirector:getChildByPath(ui, "pannel_getway")
    self.btn_fanhui    =  TFDirector:getChildByPath(ui, "btn_fanhui")
    self.btn_fanhui.logic = self
    self.btn_fanhui:setVisible(true)
    -- header
    -- 点击书的历史
    self.pannel_list = TFDirector:getChildByPath(ui, "pannel_list")
    -- 上面的列表的一个节点 = 
    self.panel_booknode = TFDirector:getChildByPath(ui, "panel_booknode")

    -- booklist 用于合成界面的层级
    self.bookList  = {}
    self.bookCount = 0

    self.needBookNum = 1

    -- self.panel_booknode:removeFromParentAndCleanup(false)
    -- self.panel_booknode:retain()
end

function RoleBook_Hecheng:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_hecheng:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickMadeHandle))
    self.btn_quickGet:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickQuickGetHandle))
    self.btn_fanhui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickBackHandle))

    -- 
end


function RoleBook_Hecheng:removeEvents()
    self.super.removeEvents(self)

end

function RoleBook_Hecheng:removeUI()
    self.super.removeUI(self)

    -- if self.panel_booknode then
    --     self.panel_booknode:release()
    --     self.panel_booknode = nil
    -- end
end


function RoleBook_Hecheng.BtnClickHandle(sender)
    local self = sender.logic;

end


function RoleBook_Hecheng:drawMadeWay()
    -- print("self.bookList = ", self.bookList)
    local bookid        = self.bookList[self.bookCount] --61080 --
    -- local bookid        = 61080 --
    local bookInfo      = MartialData:objectByID(bookid)
    local MartialList   = bookInfo:getMaterialTable()  -- 合成材料

    -- self.txt_bookname:setText(bookInfo.goodsTemplate.name)


    self.MartialList    = {}  --需要的材料
    self.MartialNumList = {}  --对应材料的个数

    local count = 0
    for i,v in pairs(MartialList) do
        count = count + 1
    
        self.MartialList[count]     = i
        self.MartialNumList[count]  = v
    end

    self.Count  = count

    if count == 0 then
        --toastMessage("这本书不能再合成了")
        toastMessage(localizable.roleBook_hecheng_not_hecheng)
        return
    end


    -- print("bookInfo = ", bookInfo)
    -- print("MartialList = ", MartialList)
    -- print("count = ", count)
    -- print("self.MartialList = ", self.MartialList)
    -- print("self.MartialNumList = ", self.MartialNumList)

    self.img_cost = TFDirector:getChildByPath(self.pannel_madeway, "img_cost")
    self.txt_cost = TFDirector:getChildByPath(self.pannel_madeway, "txt_cost")

    self.txt_cost:setText(bookInfo.copper)

    -- 记录要合成所需的价格
    self.cost = bookInfo.copper

    for i=1,4 do
        self.panel_HechengList[i]:setVisible(false)
    end

    self.img_HeCheng = TFDirector:getChildByPath(self, "img_hc1v" .. count)
    self.img_HeCheng:setPosition(self.MidPos)
    self.img_HeCheng:setVisible(true)

    local panel_des_book = TFDirector:getChildByPath(self.img_HeCheng, "panel_des_book")
    panel_des_book.id    = bookid
    self:drawBook(panel_des_book)


    -- 记录合成的材料是否足够
    self.bCanHeCheng = true
    for i=1, count do
        local panel_src_book = TFDirector:getChildByPath(self.img_HeCheng, "panel_src_book" .. i)

        panel_src_book.id       = self.MartialList[i]
        panel_src_book.needNum  = self.MartialNumList[i]
        self:drawSrcBook(panel_src_book)
    end

    local bcanHeCheng,cost = MartialManager:isCanSynthesisById(bookid, 1)
    -- 记录要合成所需的价格
    self.cost = cost
    self.txt_cost:setText(self.cost)
    self.bCanHeCheng = bcanHeCheng

    self.img_cost:setVisible(true)
    if cost <= 0 then
        self.img_cost:setVisible(false)
    end
    -- print("self.cost = ", self.cost)
end

function RoleBook_Hecheng:drawSrcBook(book)
    -- 绘制
    self:drawBook(book)

    local txt_needNum   = TFDirector:getChildByPath(book, "txt_need")
    local txt_totalNum  = TFDirector:getChildByPath(book, "txt_num")
    local img_desc  = TFDirector:getChildByPath(book, "img_desc")
    img_desc:setTouchEnabled(false)
    -- needNum
    local needNum       = book.needNum

    -- totalNum
    local totalNum      = BagManager:getItemNumById(book.id)

    txt_needNum:setColor(ccc3(0, 0, 0))
    txt_totalNum:setColor(ccc3(0, 0, 0))

    -- txt_needNum:setText(needNum)
    -- txt_totalNum:setText("/ " .. totalNum)


    txt_needNum:setText(totalNum)
    txt_totalNum:setText("/ " .. needNum)

    if needNum > totalNum then
        txt_needNum:setColor(ccc3(255, 0, 0))

        self.bCanHeCheng = false
    end

    local img_equip    = TFDirector:getChildByPath(book, "img_equip")

    img_equip:setScale(0.5)

    img_desc:setVisible(false)
    if MartialManager:isCanSynthesisById(book.id,1) then
        img_desc:setVisible(true)
    end
end


function RoleBook_Hecheng:drawDesBook(book)
    self:drawBook(book)
end

function RoleBook_Hecheng:drawBook(book)

    local bookId = book.id
    local img_quality  = TFDirector:getChildByPath(book, "img_quality")
    local img_equip    = TFDirector:getChildByPath(book, "img_equip")
    local bookInfo     = MartialData:objectByID(bookId)
    local Goods        = nil
    if bookInfo == nil then
        Goods = ItemData:objectByID(bookId)
    else
        Goods = bookInfo.goodsTemplate
    end
    
    local bgPic        = getBookBackgroud(Goods.quality)

    img_quality:setTextureNormal(bgPic)
    img_equip:setTexture(Goods:GetPath())

    img_quality.logic      = self
    img_quality.bookid     = bookId
    img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBookClickHandle))

    local needNum = book.needNum or 0

    img_quality.needNum = needNum
    -- print("bookName = ", Goods.name)

    img_equip:setScale(0.7)

    Public:addPieceImg(img_equip,{type = EnumDropType.GOODS, itemid = bookId})
end


function RoleBook_Hecheng:drawReceive()
    local bookid    = self.bookList[self.bookCount]
    -- local bookInfo  = MartialData:objectByID(bookid)
    local bookInfo  = ItemData:objectByID(bookid)

    -- print("bookInfo = ", bookInfo)
    self.output   = bookInfo.show_way

    if self.output ~= "" then
        self.outputList  = string.split(self.output, "|")
        self.outputNum   = #self.outputList
        -- print("bookName = ", bookInfo.name)
        -- print("self.output = ", self.output)
        -- print("self.outputList = ", self.outputList)
        -- print("self.outputNum = ", self.outputNum)
        if self.outputNum > 0 then
            -- self:drawOutPutList()
        else
            self.outputNum      = 1
            self.outputList     = {}
            self.outputList[1]  = 11
        end
    else
            self.outputNum      = 1
            self.outputList     = {}
            self.outputList[1]  = 11
    end
    self:drawOutPutList()

    local img_quality  = TFDirector:getChildByPath(self.pannel_getway, "img_quality")
    local img_equip    = TFDirector:getChildByPath(self.pannel_getway, "img_equip")
    -- self:drawReceiveList()

    local bgPic        = getBookBackgroud(bookInfo.quality)

    img_quality:setTextureNormal(bgPic)
    img_equip:setTexture(bookInfo:GetPath())

    img_quality:setTouchEnabled(false)
    img_equip:setScale(0.7)

    Public:addPieceImg(img_equip,{type = EnumDropType.GOODS, itemid = bookid})
end


function RoleBook_Hecheng:drawHistory(book)

    local bookId       = self.bookList[book.index]
    local img_next     = TFDirector:getChildByPath(book, "img_next")
    local img_choosed  = TFDirector:getChildByPath(book, "img_choosed")
    local img_quality  = TFDirector:getChildByPath(book, "img_quality")
    local img_equip    = TFDirector:getChildByPath(book, "img_equip")
    -- local bookInfo     = MartialData:objectByID(bookId)
    local bookInfo     = ItemData:objectByID(bookId)
    local bgPic        = getBookBackgroud(bookInfo.quality)


    img_quality:setTextureNormal(bgPic)
    img_equip:setTexture(bookInfo:GetPath())

    img_quality.logic      = self
    img_quality.bookid     = bookId
    img_quality.index      = book.index
    img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHistoryClickHandle))


    img_next:setVisible(true)
    img_choosed:setVisible(false)
    if book.index == self.bookCount then
        img_next:setVisible(false)
        img_choosed:setVisible(true)
    end

    img_equip:setScale(0.4)

    Public:addPieceImg(img_equip,{type = EnumDropType.GOODS, itemid = bookId})
end

function RoleBook_Hecheng:drawClikHistoryList()
    if self.tableView ~= nil then
        self.tableView:reloadData()
        self.tableView:setScrollToBegin(false)
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.pannel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.tableView = tableView
    self.tableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RoleBook_Hecheng.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RoleBook_Hecheng.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleBook_Hecheng.numberOfCellsInTableView)
    tableView:reloadData()

    -- self:addChild(self.tableView,1)
    self.pannel_list:addChild(self.tableView,1)
end

function RoleBook_Hecheng.cellSizeForTable(table, idx)
    return 80, 80
end

function RoleBook_Hecheng.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        -- node = createUIByLuaNew("lua.uiconfig_mango_new.handbook.HandbookOutPutCell")
        node = self.panel_booknode:clone()

        node:setPosition(ccp(0, -20))
        cell:addChild(node)
        node:setTag(617)
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawHistory(node)
    return cell
end

function RoleBook_Hecheng.numberOfCellsInTableView(table)
    local self = table.logic

    return self.bookCount
end

function RoleBook_Hecheng.onBookClickHandle(sender)
    local self    = sender.logic
    local bookid  = self.bookList[self.bookCount]

    if bookid == sender.bookid then
        return
    end

    -- 记录需要的个数
    self.needBookNum = sender.needNum

    self:AddBook(sender.bookid)
end


function RoleBook_Hecheng.onHistoryClickHandle(sender)
    local self    = sender.logic
    local bookid  = self.bookList[self.bookCount]

    if bookid == sender.bookid then
        return
    end


    local index = sender.index

    self:RemoveBook(index)
end

function RoleBook_Hecheng.BtnClickMadeHandle(sender)
    local self    = sender.logic
    local bookid  = self.bookList[self.bookCount]

    -- toastMessage("点击合成")
    if self.bCanHeCheng == false then
        --toastMessage("材料不足不能合成")
        toastMessage(localizable.roleBook_hecheng_not_cailiao)
        return
    end

    -- self.cost
    if MainPlayer:isEnoughCoin(self.cost, true) then
        -- toastMessage("开始合成")
        MartialManager:requestMartialSynthesis(bookid)
    end

end
function RoleBook_Hecheng.BtnClickQuickGetHandle(sender)
    local vipLevel = MainPlayer:getVipLevel()
    local openVipLevle = VipData:getMinLevelDeclear(9000)
    if  vipLevel < openVipLevle then
        local msg =  stringUtils.format(localizable.vip_qucik_saodang_not_enough,openVipLevle);
        CommonManager:showOperateSureLayer(
                function()
                    PayManager:showPayLayer();
                end,
                nil,
                {
                title = localizable.common_vip_up,
                msg = msg,
                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                }
        )

        -- toastMessage(TFLanguageManager:getString(ErrorCodeData.Sweep_No_VIP))
        return false
    end

    local self    = sender.logic
    local bookid  = self.bookList[self.bookCount]
    MartialManager:oneKeyToHechengAndGet(bookid)

end

function RoleBook_Hecheng.BtnClickBackHandle(sender)
    local self    = sender.logic

    -- 有历史节点才允许返回
    if self.bookCount > 1 then
        self:RemoveBook(self.bookCount-1)
    elseif self.bookCount == 1 then
        AlertManager:close()
    end
end


function RoleBook_Hecheng:drawOutPutList()
    --     self.output   = bookInfo.goodsTemplate.show_way

    -- self.outputList  = string.split(self.output, "|")
    -- self.outputNum   = #self.outputList

    -- if self.outputNum > 0 then
    --     self:drawOutPutList()
    -- else
    --     if self.outputTableView then
    --         self.outputTableView:setVisible(false)
    --     end

    local pannel_outList =  TFDirector:getChildByPath(self.pannel_getway, "pannel_getwaylist")
    if pannel_outList == nil then
        return
    end


    self.panel_outnode   =  TFDirector:getChildByPath(self.pannel_getway, "bg_cell")
    self.panel_outnode:setVisible(false)    

    -- if self.panel_outnode == nil then
    --     self.panel_outnode   =  TFDirector:getChildByPath(self.pannel_getway, "bg_cell")
    --     self.panel_outnode:setVisible(false)
    --     print("self.panel_outnode = ", self.panel_outnode)

    --     -- self.panel_outnode:removeFromParentAndCleanup(false)
    --     self.panel_outnode:retain()
    -- end

    if self.outputTableView ~= nil then
        self.outputTableView:setVisible(true)
        self.outputTableView:reloadData()

        if self.outputNum > 3 then
            self.outputTableView:setInertiaScrollEnabled(true)
        else
            self.outputTableView:setInertiaScrollEnabled(false)
        end
        self.outputTableView:setScrollToBegin(false)
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(pannel_outList:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.outputTableView = tableView
    self.outputTableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RoleBook_Hecheng.cellSizeForTable_out)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RoleBook_Hecheng.tableCellAtIndex_out)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleBook_Hecheng.numberOfCellsInTableView_out)
    tableView:reloadData()

    if self.outputNum > 3 then
        self.outputTableView:setInertiaScrollEnabled(true)
    else
        self.outputTableView:setInertiaScrollEnabled(false)
    end

    -- self:addChild(self.tableView,1)
    pannel_outList:addChild(tableView,1)

end

function RoleBook_Hecheng.cellSizeForTable_out(table, idx)
    return 70, 348
end

function RoleBook_Hecheng.tableCellAtIndex_out(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        -- node = createUIByLuaNew("lua.uiconfig_mango_new.handbook.HandbookOutPutCell")
        node = self.panel_outnode:clone()
        node:setName("HandbookOutPutCell")
        node:setPosition(ccp(180, 30))
        cell:addChild(node)
        node:setTag(617)
    end

    node = cell:getChildByTag(617)
    local output = string.split(self.outputList[idx + 1], "_")
    node.type    = tonumber(output[1])
    node.mission = tonumber(output[2])
    node.logic   = self
    self:drawOutNode(node)

    node:setVisible(true)
    return cell
end

function RoleBook_Hecheng.numberOfCellsInTableView_out(table)
    local self = table.logic

    return self.outputNum
end

function RoleBook_Hecheng:drawOutNode(node)
    
    local txt_leveldesc  = TFDirector:getChildByPath(node, "txt_leveldesc")
    local txt_levelopen  = TFDirector:getChildByPath(node, "txt_levelopen")

   -- print("node.type = ", node.type)

    -- 不是关卡则return
    local type = node.type
    if  type ~= 1 then

        local desc = typeDesc[type]
        txt_leveldesc:setText(desc)
        txt_levelopen:setText("")
        return
    end

    local missionId     = node.mission
    local open          = MissionManager:getMissionIsOpen(missionId)
    -- txt_levelopen:setVisible(not open)

    local mission = MissionManager:getMissionById(missionId);
    if mission == nil then
        print("mission == nil ,missionId =" , missionId)
        return
    end
    local missionlist = MissionManager:getMissionListByMapId(mission.mapid);
    local curMissionlist = missionlist[mission.difficulty];
    local index = curMissionlist:indexOf(mission);
    local map = MissionManager:getMapById(mission.mapid)

    local difficulty = mission.difficulty
    if difficulty == 1 then
        --txt_levelopen:setText("(普通)")
        txt_levelopen:setText(localizable.common_round_normal)
    elseif difficulty == 2 then
        --txt_levelopen:setText("(宗师)")
        txt_levelopen:setText(localizable.common_round_high)
    else
         txt_levelopen:setText("")
    end

    -- print("mission = ", mission)
    txt_leveldesc:setText( map.name .. " " .. mission.stagename)

    node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOutClickHandle),1)

    if open then
        txt_leveldesc:setColor(ccc3(0,0,0))
        txt_levelopen:setColor(ccc3(0,0,0))
        node:setTexture("ui_new/rolebook/bg_cell.png")
    else
        txt_leveldesc:setColor(ccc3(141,141,141))
        txt_levelopen:setColor(ccc3(141,141,141))
        node:setTexture("ui_new/rolebook/bg_cell2.png")
    end

    print("mission.stagename = ", mission.stagename)

end

function RoleBook_Hecheng.onOutClickHandle(sender)
    local self    = sender.logic
    local type    = sender.type
    local mission = sender.mission

    -- print("sender.type = ", sender.type)
    -- if type == 1 then
    --     local open    = MissionManager:getMissionIsOpen(mission)

    --     if open then
    --         MissionManager:showHomeToMissionLayer(mission)
    --     else
    --         toastMessage("关卡尚未开启")
    --     end
        
    -- elseif type == 2 then
    --     -- if PlayerGuideManager:GetArenaOpenLevel() <= MainPlayer:getLevel() then
    --     if FunctionOpenConfigure:getOpenLevel(301) <= MainPlayer:getLevel() then

    --         MallManager:openQunHaoShopHome()
    --     else
    --         toastMessage("群豪谱尚未开启")
    --     end

    -- elseif type == 7 then
    --     -- 进入商店
    --     -- MallManager:openMallLayer()
    --     local bookid  = self.bookList[self.bookCount]
    --     MallManager:openMallLayer(self.id)
    -- end
    if type == 1 and AlertManager:isInQueueByKey("") then
        toastMessage("")
        return
    end

    local bookid    = self.bookList[self.bookCount]
    print("需要书的id = ", bookid)
    print("需要的个数   = ", self.needBookNum)
    MissionManager:quickPassToGetFGoods(bookid, self.needBookNum)
    IllustrationManager:gotoProductSystem(type, mission)
end

return RoleBook_Hecheng
