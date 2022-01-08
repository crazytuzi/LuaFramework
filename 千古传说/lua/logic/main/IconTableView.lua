--[[
******头像列表TableView*******

	-- by Chikui.Peng
	-- 2016/3/3
]]

local IconTableView = class("IconTableView", BaseLayer)

function IconTableView:ctor(data)
    self.super.ctor(self,data)
    self.size = data.size
    self:init("lua.uiconfig_mango_new.bag.BagTableView")
end

function IconTableView:initUI(ui)
	self.super.initUI(self,ui)
    self.row = 2
    self.column = 5
	self:initTableView(ui)
end

function IconTableView:removeUI()
    self.tableView = nil
	self.super.removeUI(self)
end

-----断线重连支持方法
function IconTableView:onShow()
    self.super.onShow(self)
end

function IconTableView:initTableData()
    local function sortFunc( data1,data2 )
        if data1.quality < data2.quality then
            return false
        elseif data1.quality == data2.quality then
            if data1.id < data2.id then
                return true
            end
            return false
        elseif data1.quality > data2.quality then
            return true
        end
    end
    self.iconList = {}
    local tList = PlayerHeadIconManager:getIconList()
    for k,v in pairs(tList) do
       local roleConfig = RoleData:objectByID(v)
       self.iconList[k] = {id = v,quality = roleConfig.quality}
       if ProtagonistData:IsMainPlayer(v) == true then
            local roleId = MainPlayer:getProfession()
            local cardrole = CardRoleManager:getRoleById(roleId)
            self.iconList[k].quality = cardrole.quality
       end
    end
    table.sort( self.iconList, sortFunc )
end

function IconTableView:initTableView(ui)
    self:initTableData()
    local  tableView =  TFTableView:create()

    self.tableView = tableView
    tableView:setTableViewSize(self.size)
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, handler(IconTableView.cellSizeForTable,self))
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, handler(IconTableView.tableCellAtIndex,self))
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, handler(IconTableView.numberOfCellsInTableView,self))
    ui:addChild(tableView)
    self.tableView:reloadData()
end

function IconTableView:refreshData()
    self.tableView:reloadData()
end

function IconTableView:registerEvents()
    self.super.registerEvents(self)
end

function IconTableView:removeEvents()

    self.super.removeEvents(self)
end

--销毁方法
function IconTableView:dispose()
    self:disposeAllPanels()
    self.super.dispose(self)
end

--销毁所有TableView的Cell中的Panel
function IconTableView:disposeAllPanels()

end

function IconTableView:cellSizeForTable(table,idx)
    return 115,620
end

function IconTableView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = TFTableViewCell:create()
        cell.pzImg = {}
        cell.iconImg = {}
        for i=1,self.column do
            local node = createUIByLuaNew("lua.uiconfig_mango_new.main.HeadCell")
            cell.pzImg[i] = TFDirector:getChildByPath(node,"img_pinzhiditu1")
            cell.iconImg[i] = TFDirector:getChildByPath(node,"img_touxiang")
            cell.pzImg[i]:addMEListener(TFWIDGET_CLICK,audioClickfun(self.tableCellClick),1);
            local size = cell.pzImg[i]:getContentSize()
            local x = (size.width*0.8+20)*(i-1) + 29.5
            node:setPosition(ccp(x,0))
            
            cell:addChild(node)
        end
    end
    for i=1,self.column do
        local tmpIndex = idx * self.column + i
        if cell.pzImg[i] and tmpIndex <= #(self.iconList) then
            local iconId = self.iconList[tmpIndex].id
            if iconId and iconId > 0 then
                cell.pzImg[i]:setVisible(true)
                cell.pzImg[i].id = iconId
                local roleConfig = RoleData:objectByID(iconId)
                cell.pzImg[i]:setTexture(GetColorIconByQuality(self.iconList[tmpIndex].quality))
                cell.iconImg[i]:setTexture(roleConfig:getIconPath())
            else
                cell.pzImg[i]:setVisible(false)
                cell.pzImg[i].id = 0
            end
        else
            cell.pzImg[i]:setVisible(false)
            cell.pzImg[i].id = 0
        end
    end
    return cell
end

function IconTableView:numberOfCellsInTableView(table)
    if self.iconList and #(self.iconList) > 0 then
        local num = math.ceil((#(self.iconList))/self.column)
        if num < self.row then
            return self.row
        end

        return num
    end
    return 4
end

function IconTableView.tableCellClick(sender)
    local iconId = sender.id
    if iconId <= 0 then
        --toastMessage("无效的头像ID")
        toastMessage(localizable.HeadPicFrame_text5)
        return
    end
    PlayerHeadIconManager:requestChangeIcon(iconId)
end

return IconTableView
