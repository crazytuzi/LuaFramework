--未知暗殿
local undefinedNode = class("undefinedNode", function() return cc.Node:create() end)
local undefinedKillList = class("undefinedKillList", require("src/TabViewLayer"))

function undefinedNode:ctor()
	print("undefinedNode:ctor")
	self.killInfo = {}

    g_msgHandlerInst:sendNetDataByTableExEx( UNDEFINED_CS_GET_KILL_INFO , "UndefinedKillInfo", { activityID = activityID } )
    local msgids = {UNDEFINED_SC_GET_KILL_INFO_RET}
    require("src/MsgHandler").new(self, msgids)	
end

function undefinedNode:updateInfo()
    if self.killList then
        removeFromParent(self.killList)
        self.killList = nil
    end
        
    self.killList = undefinedKillList.new(self)
end

function undefinedNode:networkHander(buff,msgid)
    local switch = 
    {
        [UNDEFINED_SC_GET_KILL_INFO_RET] = function()
            local ret = g_msgHandlerInst:convertBufferToTable( "UndefinedKillInfoRet" , buff )
            local info = ret.info or {}

            self.killInfo = {}
            for k,v in pairs(info) do
                local index = #self.killInfo + 1
                local tempInfo = v
                self.killInfo[index] = {}
                self.killInfo[index].time = tempInfo.tick
                self.killInfo[index].name = tempInfo.name
            end
        end,
    }

    if switch[msgid] then
        switch[msgid]()
    end
end

-------------------------------------------------------------------------------------
function undefinedKillList:ctor(parent)
    self.killInfo = parent.killInfo
    
    local size = cc.size(346, 184)
    if tablenums(self.killInfo) > 5 then
        size = cc.size(346, 332)
    end

    local bg = createScale9Sprite(self, "res/common/scalable/6.png", cc.p(display.cx, g_scrSize.height - 82 - 17), size, cc.p(0.5, 1) ) 
    createLabel(bg, game.getStrByKey("kill_name"), cc.p(78, size.height - 20), nil, 20):setColor(MColor.lable_black)
    createLabel(bg, game.getStrByKey("kill_time"), cc.p(245, size.height - 20), nil, 20):setColor(MColor.lable_black)

    self:createTableView(bg, cc.size(size.width, size.height - 40), cc.p(0, 5), true, true)
    self:getTableView():reloadData()
    bg:runAction(cc.ScaleTo:create(0.15, 1))

    parent:addChild(self)
    registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)
end

function undefinedKillList:cellSizeForTable(table, idx) 
    return 30, 346
end

function undefinedKillList:numberOfCellsInTableView(table)
    local num = (#self.killInfo == 0) and 1 or (#self.killInfo)
    --print("undefinedNode:numberOfCellsInTableView" .. num)
    return num
end

function undefinedKillList:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new() 
    else
        cell:removeAllChildren()
    end
    local str1, str2 = self:getStrFromKillInfo(idx+1)
    --print("[undefinedKillList:tableCellAtIndex] .. ".. idx ..",str1="..str1 ..",str2="..str2)
    if str2 ~= nil then
        createLabel(cell, str1, cc.p(78, 15), cc.p(0.5, 0.5), 20, true)
        createLabel(cell, str2, cc.p(245, 15), cc.p(0.5, 0.5), 20, true)
    else
        createLabel(cell, str1, cc.p(173, 15), cc.p(0.5, 0.5), 20, true)
    end
    
    return cell
end

function undefinedKillList:getStrFromKillInfo(index)
    if #self.killInfo == 0 then
        return game.getStrByKey("empire_dead_info_no")
    end
    if index > #self.killInfo then
        return "", ""
    end

    local tempInfo = self.killInfo[index]
    if tempInfo then
        local str = os.date("%Y/%m/%d %H:%M", tempInfo.time)
        return tempInfo.name, str
    end
    return "" , ""
end

return undefinedNode