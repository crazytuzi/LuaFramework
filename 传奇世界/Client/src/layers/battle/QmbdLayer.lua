local QmbdLayer = class("QmbdLayer", require("src/TabViewLayer"))

function QmbdLayer:ctor(params)
    params = params or {}
    self.params = params
    
	self.activityName = "qmbd"
    self.arrowsFlag = nil
    self.btnItem = {}
    self.mapid = 7000
	self.cfgData = getConfigItemByKey( "ActivityNormalDB", "q_id" )
	for k,v in pairs(self.cfgData) do
        if v.q_key == self.activityName then
            self.cfg = v
            break
        end
    end

	local title = self.cfg and self.cfg.q_name or ""
	local base_node = createBgSprite(self, title)
    local size = base_node:getContentSize()
    local left_bg_size = cc.size(896, 500)
    local left_bg = createScale9Frame(
        base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 38),
        left_bg_size,
        5
    )

    local insert_bg1 = createScale9Sprite(
        base_node,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(227, 46),
        cc.size(692, 254),
        cc.p(0, 0)
    )    

    local insert_bg = createScale9Sprite(
        base_node,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(41, 46),
        cc.size(178, 254),
        cc.p(0, 0)
    )

    local midbg = cc.Node:create()
    base_node:addChild(midbg)
    self.bg = midbg

    local image = "res/layers/battle/bd-min.jpg"
    createSprite( base_node , image , cc.p( size.width/2 , size.height - 104 ) , cc.p(  0.5 , 1 ) , nil )  

    self.gotoBtn = createMenuItem(self.bg, "res/component/button/50.png", cc.p(840, 90), function() self:gotoBtnCallBack() end)
    self.gotoBtn:setEnabled(false)

    self.btnLab = createLabel(self.gotoBtn, game.getStrByKey("join_activity"), getCenterPos(self.gotoBtn), nil, 22, true)

    SwallowTouches(self)
    
    local activityID = (self.cfg and self.cfg.q_activity_id or 2)
    g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN , "ActivityNormalCanJoin", { activityID = activityID } )
    local msgids = {ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN_RET}
    require("src/MsgHandler").new(self, msgids)


    local tempMapCfg = {7000, 7001, 7002, 7003}
    local mapCfgInfo = {}
    for k,v in pairs(tempMapCfg) do
        mapCfgInfo[k] = getConfigItemByKey("MapInfo", "q_map_id", v)
    end

    self.btnData = {}
    for i=1, #mapCfgInfo do
        local index = i
        local tempInfo = mapCfgInfo[i]
        self.btnData[index] = {}
        self.btnData[index].map_name = tempInfo.q_map_name
        self.btnData[index].min_lev = tempInfo.q_map_min_level
        if i > 1 then
            self.btnData[index - 1].max_lev = tempInfo.q_map_min_level - 1
        end
        if i == #mapCfgInfo then
            self.btnData[index].max_lev = tempInfo.q_map_max_level
        end
    end
    --dump(self.btnData, "self.btnData")

    self:createTableView(self.bg, cc.size(195, 250 ), cc.p(41, 48), true)
    self:getTableView():reloadData()
    self:chooseOneBtn()
end

function QmbdLayer:cfgInfo(index)
    if self.cfgNode then
        removeFromParent(self.cfgNode)
        self.cfgNode = nil
    end

    local cfgNode = cc.Node:create()
    self.bg:addChild(cfgNode)
    self.cfgNode = cfgNode

    local tempWidth = 553
    local topHeight, offSetY = 495, 30
    
    local textCfg = {  
                            { str = game.getStrByKey("activity_time") , pos = cc.p( 75 - 30 +190 , 280 - 20) , } ,
                            { str = "参与条件：" , pos = cc.p( 660 , 280 - 20) , } ,
                            { str = game.getStrByKey("activity_rule") , pos = cc.p( 75 - 30 +190, 280 - 40 - 20) , } ,
                            { str = game.getStrByKey("activity_awards") , pos =  cc.p( 75 - 30 +190, 260 - 180 + 20 ) , } ,
                        }
    for i = 1 , #textCfg do
        createLabel( cfgNode , textCfg[i]["str"]  , textCfg[i]["pos"] , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    end

    local timeTab =  DATA_Battle:formatTime( self.cfg and self.cfg.q_time or "" )      --活动时间
    local str = ""
    for i , v in ipairs( timeTab ) do str = str .. " " .. v end
    createLabel( cfgNode , str , cc.p( 75 + 110 - 30 + 190 - 5, 280 - 20) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )

    createLabel( cfgNode , "活跃度达到60", cc.p( 660 + 110, 280 - 20) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )
    local ruleText = createLabel( cfgNode , self.cfg and self.cfg.q_rule  or ""  , cc.p( 75 + 110 - 30 + 190, 280 - 15 - 20) , cc.p( 0 , 1 ) , 22 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )
    ruleText:setDimensions( 690  + 60 ,0)

    local dropCfg = {23, 24, 25, 26}
    local dropid = dropCfg[index + 1] or 23

    local DropOp = require("src/config/DropAwardOp")
    local gdItem = DropOp:getItemBySexAndSchool(dropid)
    table.sort(gdItem, function(a, b) return a.q_group > b.q_group end)
    local j = 1
    for m,n in pairs(gdItem) do
        if j > 4 then 
            break 
        end

        local Mprop = require "src/layers/bag/prop"
        local icon = Mprop.new(
        {
            protoId = tonumber(n.q_item),
            --num = tonumber(n.q_count),    
            swallow = true,
            cb = "tips",
            showBind = true,
            isBind = n.q_isBind,
        })
        icon:setTag(9)
        cfgNode:addChild(icon)
        icon:setPosition(cc.p(360 + (j - 1)  * 85 -5 , 90))
        icon:setAnchorPoint(0, 0.5)
        icon:setScale(0.9)
        j = j + 1
    end
end

function QmbdLayer:cellSizeForTable(table, idx) 
    return 70, 176
end

function QmbdLayer:numberOfCellsInTableView(table)
    return #self.btnData
end

function QmbdLayer:tableCellTouched(table,cell)
    AudioEnginer.playTouchPointEffect()
    local index = cell:getIdx() + 1
    if self.selectIdx == index - 1 then
        return 
    end
    if not cell.canTouch then
        return
    end

    if self.selectIdx then
        local targetCell = self:getTableView():cellAtIndex(self.selectIdx)
        if tolua.cast(targetCell, "cc.TableViewCell") then 
            targetCell.bg:setTexture("res/component/button/40.png") 
        end
    end     

    self.selectIdx = index - 1
    cell.bg:setTexture("res/component/button/40_sel.png")
    local pos = cc.p(cell:getPosition())
    if not self.arrowsFlag then
        self.arrowsFlag = createSprite(self:getTableView(), "res/group/arrows/9.png" ,  cc.p(pos.x+173, pos.y + 35), cc.p( 0, 0.5 ) )
    end
    self.arrowsFlag:setPosition(cc.p(pos.x+176, pos.y + 35))

    self:cfgInfo(index - 1)
end

function QmbdLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new() 
    else
        cell:removeAllChildren()
    end
    
    local itemData = self.btnData[idx + 1]
    --dump(itemData, "itemData")

    local roleLev = MRoleStruct:getAttr(ROLE_LEVEL)
    cell.canTouch = true
    local btnRes = "res/component/button/40.png"
    if itemData.max_lev < roleLev then
        cell.canTouch = false
        btnRes = "res/component/button/40_gray.png"
    elseif self.selectIdx and idx == self.selectIdx then
        btnRes = "res/component/button/40_sel.png"
    end        

    if cell.canTouch and not self.canTouchIndex then
        self.canTouchIndex = idx
    end

    local button = createSprite(cell, btnRes, cc.p(2, 2), cc.p(0, 0))
    cell.bg = button

    local lab1 = createLabel(button, itemData.map_name, getCenterPos(button, 0, 12), nil, 20, true)

    local str = "( Lv." .. itemData.min_lev .. "-"..itemData.max_lev .. " )"
    local lab2 = createLabel(button, str, getCenterPos(button, 0, -12), nil, 20, true)
    if roleLev < itemData.min_lev then
        lab2:setColor(MColor.red)
    elseif itemData.min_lev <= roleLev and roleLev <= itemData.max_lev then
        lab2:setColor(MColor.green)
    else
        lab2:setColor(MColor.gray)
        lab1:setColor(MColor.gray)
    end

    return cell
end

function QmbdLayer:gotoBtnCallBack()
    if self:checkLev() then
        __GotoTarget( { ru = "a218" } )
    end
end

function QmbdLayer:checkLev()
    local cfg = self.cfg
    if cfg and cfg.q_level > MRoleStruct:getAttr(ROLE_LEVEL) then
        TIPS( {str = string.format(game.getStrByKey("activity_begain_atLev"), cfg.q_level)} )
        return false
    end

    local itemData = self.btnData[self.selectIdx + 1]
    local roleLev = MRoleStruct:getAttr(ROLE_LEVEL)
    if itemData and itemData.min_lev and itemData.min_lev > roleLev then
        local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 37600 , 4 } )
        local msgStr = string.format( msg_item.msg , tostring( itemData.min_lev ) )
        TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr })                    
        return false
    end   
    return true
end

function QmbdLayer:chooseOneBtn()
    if self.canTouchIndex then
        local targetCell = self:getTableView():cellAtIndex(self.canTouchIndex)
        local pos = nil
        if targetCell then
            pos = cc.p(targetCell:getPosition())
        else
            pos = cc.p(0, (#self.btnData - self.canTouchIndex - 1) * 70)
        end
        local pos2 = self:getTableView():getContentOffset()
        --dump(pos)
        --dump(pos2)
        if pos2.y < 0 then
            local offsetY = (pos2.y + pos.y < 0) and -pos.y or pos2.y
            --dump(offsetY)
            self:getTableView():setContentOffset(cc.p(0, offsetY))
        end
        local targetCell = self:getTableView():cellAtIndex(self.canTouchIndex)
        if targetCell then
            self:tableCellTouched(self:getTableView(), targetCell)
        end
    end
end

function QmbdLayer:networkHander(buff,msgid)
    local switch = 
    {
        [ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN_RET] = function()
            local t = g_msgHandlerInst:convertBufferToTable( "ActivityNormalCanJoinRet" , buff )    
            local retNum = t.canJoin
            dump(retNum, "retNum")

            local str = game.getStrByKey("join_activity")
            if retNum == 1 then
                str = game.getStrByKey("join_activityLate")
            end
            
            if self.btnLab then
                self.btnLab:setString(str)
            end

            if self.gotoBtn then
                self.gotoBtn:setEnabled(retNum == 0)
            end
        end,
    }

    if switch[msgid] then
        switch[msgid]()
    end
end

return QmbdLayer