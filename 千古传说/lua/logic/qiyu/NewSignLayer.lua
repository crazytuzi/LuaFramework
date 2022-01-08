
local NewSignLayer = class("NewSignLayer", BaseLayer)

function NewSignLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.NewSignLayer")

    -- QiyuManager:GetSignStatus()
end

function NewSignLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.ruleBtn        = TFDirector:getChildByPath(ui, 'btn_guize')
    self.yueLabel       = TFDirector:getChildByPath(ui, 'txt_yue')
    self.cishuLabel     = TFDirector:getChildByPath(ui, 'txt_cishu')

    self.layer_list     = TFDirector:getChildByPath(ui, 'panel_kuangti')

    self.cishuLabel:setText("")
    self.yueLabel:setText("")
    -- self:initSignData()
    -- self:setSignMonth(self.month)
    -- self:setSignTimes(self.nowDayIndex)
    -- self:drawSignList()
    -- self:draw()

    -- self:initSignData()
    -- self:initRewardList()
    if not self.nTimerId then
        self.nTimerId = TFDirector:addTimer(1000, -1, nil, function(event)
            TFDirector:removeTimer(self.nTimerId)
            self.nTimerId = nil
            QiyuManager:GetSignStatus()
        end) 
    end
end

function NewSignLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.ruleBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ruleBtnClickHandle));
    
    -- ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
    TFDirector:addMEGlobalListener("getSignRequest", function() self:getSignRequest() end)
    TFDirector:addMEGlobalListener("signResult", function() self:getSignResult() end)

end

function NewSignLayer:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener("getSignRequest")
    TFDirector:removeMEGlobalListener("signResult")

    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
    end

end

function NewSignLayer:onShow()
    self.super.onShow(self)

    if self.tableView then
        self.tableView:reloadData()
    end
end

function NewSignLayer.ruleBtnClickHandle(sender)
    -- print("NewSignLayer.ruleBtnClickHandle")
    local layer = AlertManager:addLayerByFile("lua.logic.qiyu.SignRuleLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    local winSize =  GameConfig.WS
    -- print("winsize = (%f, %f)", winSize.width, winSize.height)
    layer:setPosition(ccp(winSize.width/2, winSize.height/2))
    layer:setZOrder(10)
    AlertManager:show()
end



function NewSignLayer:setSignMonth(month)
    self.yueLabel:setText(string.format("%d", month))
end

function NewSignLayer:setSignTimes(times)
    self.cishuLabel:setText(string.format("%d", times))
end

function NewSignLayer:drawSignList()
    if self.tableView ~= nil then
        print("绘制签到列表")
        self.tableView:reloadData()
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.layer_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    -- tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLBOTTOMUP)
    tableView:setPosition(self.layer_list:getPosition())
    self.tableView = tableView
    self.tableView.logic = self

    local function numberOfCellsInTableView(table)
        return self.pageNum
    end

    -- tableView:addMEListener(TFTABLEVIEW_TOUCHED, NewSignLayer.tableCellTouched)
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, NewSignLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, NewSignLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, numberOfCellsInTableView)
    tableView:reloadData()

    self.layer_list:getParent():addChild(self.tableView,1)

-- self.pageNum
    local nRowIndex = math.ceil(self.nowDayIndex/7)
    -- 该月第一次签到
    if nRowIndex == 0 then
        nRowIndex = 1
    end
    -- nRowIndex = 3
    local view = self.tableView:getViewSize()
    local size = self.tableView:getContentSize()
    local pos  = self.tableView:getContentOffset()

    -- local height = size.height / self.pageNum
    local height = view.height / 2

    local newPosY = pos.y + (nRowIndex - 1) * height

    if newPosY > 0 then
        newPosY = 0
    end
    print("nRowIndex = ", nRowIndex)
    self.tableView:setContentOffsetInDuration(ccp(pos.x , newPosY), 0)
    -- print("view = ", view)
    -- print("size = ", size)
    -- print("pos = ", pos)

end

function NewSignLayer:draw()

    -- self:initSignData()
    -- self:initRewardList()

    self.pageNum = math.ceil(self.days/7)

    self:setSignMonth(self.month)
    self:setSignTimes(self.nowDayIndex)
    self:drawSignList()
end

function NewSignLayer.cellSizeForTable(table,idx)
    -- return 160,130*7
    return 160, 120*7
end

function NewSignLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic

    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        for i=1,7 do
            local sign_node = createUIByLuaNew("lua.uiconfig_mango_new.qiyu.SignEntity");
            sign_node:setPosition(ccp(10 + (i-1)*120, 0))
            cell:addChild(sign_node);
            sign_node:setTag(100+i)

            local singNode  = TFDirector:getChildByPath(sign_node, 'panel_wuping')
            singNode.Parent = sign_node
            singNode.logic  = self
            singNode:addMEListener(TFWIDGET_CLICK, audioClickfun(self.touchSignNode))

            sign_node:setScale(0.95)
        end
    end

    --绘制每个节点
    for i=1,7 do
        local node = cell:getChildByTag(100+i)
        local dayIndex = idx*7 + i
        node.dayIndex  = dayIndex
        local isVsible = false
        if dayIndex > self.days then
            -- node:setVisible(false)
        else
            -- node:setVisible(true)
            -- self:drawSignEntity(node, dayIndex)
            isVsible = true
        end
        self.isVsible = isVsible
        self:drawSignEntity(node, dayIndex, isVsible)
    end

    return cell
end

function NewSignLayer:initRewardList()
    if self.SignRewardList then
        return
    end

    self.SignRewardList = TFArray:new()

    local rewardList = require("lua.table.t_s_sign")

    -- 把当前月份的数据取出来
    for v in rewardList:iterator() do
        if self.month == v.month  then
            self.SignRewardList:push(v)
        end
    end
    
    -- 比较函数
    local function sortlist( v1,v2 )
        if v1.id < v2.id then
            return true
        end
        return false
    end

    self.SignRewardList:sort(sortlist)

    self.days = self.SignRewardList:length()
end

function NewSignLayer:getSignDataByDayIndex(dayIndex)
    local data = self.SignRewardList:getObjectAt(dayIndex)
    return data
end

function NewSignLayer:drawSignEntity(node, dayIndex, isVsible)

    local panel_info = TFDirector:getChildByPath(node, 'panel_info')
    panel_info:setVisible(isVsible)


    local panel_empty = TFDirector:getChildByPath(node, 'panel_empty')
    panel_empty:setVisible(not isVsible)

    if isVsible == false then
        self:playSignEffect(node, false)
        return
    end

    local img_vipBg     = TFDirector:getChildByPath(node, 'img_vipdi')
    local img_vipDesc   = TFDirector:getChildByPath(node, 'img_vip')
    local img_vipBeishu = TFDirector:getChildByPath(node, 'img_beishu')
    local lbl_goodsNum  = TFDirector:getChildByPath(node, 'txt_num')
    local lbl_goodsName = TFDirector:getChildByPath(node, 'txt_name')
    local img_goodsIcon = TFDirector:getChildByPath(node, 'img_wuping')
    local img_sign      = TFDirector:getChildByPath(node, 'img_yiqiandao')
    local img_choose    = TFDirector:getChildByPath(node, 'img_xuanzhong')
    local img_itemBg    = TFDirector:getChildByPath(node, 'img_pinzhikuang')


    -- local img_gouxuan   = TFDirector:getChildByPath(node, 'img_gouxuan')
    local img_zhezhao   = TFDirector:getChildByPath(node, 'img_zhezhao')
    local img_di        = TFDirector:getChildByPath(node, 'img_di')
    local img_di1       = TFDirector:getChildByPath(node, 'img_di1')

-- self.nowDayIndex = 5

    -- local hideSignImg = false
    -- -- if dayIndex <= self.nowDayIndex then
    -- if dayIndex < self.nowDayIndex then
    --     hideSignImg = true
    -- end
    -- img_sign:setVisible(hideSignImg)
    -- -- img_gouxuan:setVisible(hideSignImg)
    -- img_zhezhao:setVisible(hideSignImg)

    img_di1:setVisible(false)

    --控制已签到标签的隐藏
    img_sign:setVisible(false)
    if dayIndex <= self.nowDayIndex then
        img_sign:setVisible(true)
    end

    -- 控制遮罩的隐藏
    img_zhezhao:setVisible(true)
    if self.isSign == false then
        if dayIndex > self.nowDayIndex then
        img_zhezhao:setVisible(false)
        end
    else
        if dayIndex >= self.nowDayIndex then
            img_zhezhao:setVisible(false)
        end
    end

    

    --绘制选中框
    local bThisNodeNeedSign = false
    img_choose:setVisible(false)
    -- 未签到的最后一个
    if dayIndex == (self.nowDayIndex + 1) and self.isSign == false then
        -- img_choose:setVisible(true)
        img_di1:setVisible(true)
        bThisNodeNeedSign = true
    end
    self:playSignEffect(node, bThisNodeNeedSign)

    -- 已签到的最后一个
    if dayIndex == (self.nowDayIndex) and self.isSign == true then
        img_di1:setVisible(false)
        -- img_gouxuan:setVisible(false)
        img_sign:setVisible(true)
        img_di1:setVisible(true)
    end

    img_di:setVisible(not img_di1:isVisible())

    if img_di1:isVisible() then
        lbl_goodsName:setColor(ccc3(0,0,0))
    else
        lbl_goodsName:setColor(ccc3(0x3d,0x3d,0x3d))
    end

    local signData = self:getSignDataByDayIndex(dayIndex)
 
    --绘制vip 及 倍数
    if signData.vip_lv == 0 and signData.multiple == 0 then
        img_vipBg:setVisible(false)
    else
        img_vipBg:setVisible(true)

        -- 绘制vip等级
        if signData.vip_lv > 0 then
            img_vipDesc:setVisible(true)
            local desc = string.format("qd_V%d.png", signData.vip_lv)
            img_vipDesc:setTexture("ui_new/qiyu/" .. desc)
        else
            img_vipDesc:setVisible(false)
        end

         -- 绘制倍数
        if signData.multiple > 0 then
            img_vipBeishu:setVisible(true)
            local desc = string.format("qd_%dbei.png", signData.multiple)
            img_vipBeishu:setTexture("ui_new/qiyu/" .. desc)
        else
            img_vipBeishu:setVisible(false)
        end
    end

    -- 绘制物品数量
     if signData.reward_num > 0 then
        lbl_goodsNum:setVisible(true)
        local desc = string.format("%d", signData.reward_num)
        lbl_goodsNum:setText(desc)
    else
        lbl_goodsNum:setVisible(false)
    end

    -- 绘制物品icon 及 名称
    local item = {type = signData.reward_type, number = signData.reward_num, itemId = signData.reward_id}
    local itemInfo = BaseDataManager:getReward(item)
    if signData.reward_type == EnumDropType.ROLE then
        local role      = RoleData:objectByID(signData.reward_id)
        local headIcon  = role:getIconPath()
        img_goodsIcon:setTexture(headIcon)
        Public:addPieceImg(img_goodsIcon, {type = signData.reward_type,itemid = signData.reward_id},false);
    else
        img_goodsIcon:setTexture(itemInfo.path)
    end
    -- 
 -- lbl_goodsName:setText(itemInfo.name)
    local path = GetColorIconByQuality(itemInfo.quality)
   
    if signData.reward_type == EnumDropType.GOODS then
        local itemDetail = ItemData:objectByID(item.itemId)
        if itemDetail ~= nil and itemDetail.type == EnumGameItemType.Piece then
            -- path =  GetBackgroundForFragmentByQuality(itemInfo.quality)
            print("我是碎片")
        else
            path =  GetColorIconByQuality(itemInfo.quality)
        end

        if itemDetail.kind == 3 and itemDetail.type == 7 then

        else
            Public:addPieceImg(img_goodsIcon, {type = signData.reward_type,itemid = signData.reward_id});
        end
    end

    --lbl_goodsName:setText(string.format("第%d天", dayIndex))
    lbl_goodsName:setText(stringUtils.format(localizable.common_index_day, dayIndex))
    img_itemBg:setTexture(path)


    -- Public:addPieceImg(img_goodsIcon,{type = signData.reward_type,itemid = signData.reward_id});

    -- print("itemInfo = ", itemInfo)
    -- if itemInfo.kind == 3 and itemInfo.type == 7 then

    -- else
    --     Public:addPieceImg(img_goodsIcon,{type = signData.reward_type,itemid = signData.reward_id});
    -- end
end

function NewSignLayer.touchSignNode(sender)
    local self = sender.logic
    local tag  = sender.Parent.dayIndex
    print("NewSignLayer.touchSignNode tag = %d", tag)

    if sender.Parent.isVsible == false then
        print("NewSignLayer.touchSignNode")
        return
    end

    local showItem = true

    -- 今天已经签过到了
    if self.isSign and tag == (self.nowDayIndex + 1) then
        print("今天已经签过到了")
        -- toastMessage("今天已经签过到了")
    elseif tag == (self.nowDayIndex + 1) then
        print("请求签到")
        QiyuManager:SignRequest()
        showItem = false
    end

    if showItem then
        print("showItem ---", tag)
        local dayIndex = tag
        local signData = self:getSignDataByDayIndex(dayIndex)
        local item = {type = signData.reward_type, number = signData.reward_num, itemId = signData.reward_id}
        local reward_item = BaseDataManager:getReward(item)

        print(reward_item.itemId, reward_item.type)
        -- Public:ShowItemTipLayer(reward_item.itemId, reward_item.type)
        Public:ShowItemTipLayer(signData.reward_id, signData.reward_type)
    end
end

function NewSignLayer:initSignData()
    self.nowDayIndex = 0 --当前日期的索引
    self.month       = 7
    self.days        = 31 --总天数
    self.isSign      = false
end

function NewSignLayer:getSignRequest()
    local data = QiyuManager.GetSignRequest

    self.nowDayIndex = data.monthDay    --当天是本月第几天
    self.month       = data.month       --当前月数    
    -- self.days        = data.monthDaySum --当前月数总共天数
    self.isSign      = data.isSign      --是否已签到

    -- for test 
    -- self.nowDayIndex = 1
    -- self.isSign      = false
    -- self.days = 31
    -- print("....NewSignLayer:getSignRequest... num = %d", #data)
    print("(%d, %d, %d, %d)", self.nowDayIndex, self.month, self.days, self.isSign)

    self:initRewardList()
    self:draw()
end

function NewSignLayer:getSignResult()
    -- local data = QiyuManager.SignResult
    print("签到成功")
    -- 签到成功
    self.nowDayIndex = self.nowDayIndex + 1
    self.isSign      = true

    self:setSignTimes(self.nowDayIndex)
    self.tableView:reloadData()


    if self.logic then
        self.logic:redraw()
    end
end

function NewSignLayer:setSignData(data)
    self.nowDayIndex = data.monthDay    --当天是本月第几天
    self.month       = data.month       --当前月数    
    -- self.days        = data.monthDaySum --当前月数总共天数
    self.isSign      = data.isSign      --是否已签到
end

function NewSignLayer:playSignEffect(titleNode, playEffect)
    if titleNode == nil then
        return
    end

    if playEffect == false then
        if titleNode.signEffect then
            titleNode.signEffect:removeFromParent()
            titleNode.signEffect = nil
        end
        return
    end

    if titleNode.signEffect then
        titleNode.signEffect:removeFromParent()
        titleNode.signEffect = nil
    end


    if playEffect == true and titleNode.signEffect == nil then
        print("add effect ")
        local resPath = "effect/sign.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("sign_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)

        titleNode:addChild(effect,2)
        effect:setScale(0.95)
        effect:setPosition(ccp(47,56))

        effect:setAnchorPoint(ccp(0.5, 0.5))
        titleNode.signEffect = effect
    end

        print("play effect ")
    titleNode.signEffect:playByIndex(0, -1, -1, 1)
end

return NewSignLayer