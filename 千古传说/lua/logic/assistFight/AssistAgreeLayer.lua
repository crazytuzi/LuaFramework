--[[
******助战契合*******

	-- by quanhuan
	-- 2015/12/18
]]

local AssistAgreeLayer = class("AssistAgreeLayer",BaseLayer)

local AchieveMax = 5    --成就最大条数
local IconPosMax = 6    
local qiheMaxLevel = 5

local LocalAchieveData = {}
local LocalIconData = {}

local cellH = 85

local AttrTextrueNormal = {
    [1] = 'ui_new/Zhuzhan/bg_kw_qixue1.png',
    [2] = 'ui_new/Zhuzhan/bg_kw_wuli1.png',
    [3] = 'ui_new/Zhuzhan/bg_kw_fanyu1.png',
    [4] = 'ui_new/Zhuzhan/bg_kw_neili1.png',
    [5] = 'ui_new/Zhuzhan/bg_kw_shenfa1.png',
    [100] = 'ui_new/Zhuzhan/bg_kw_quanshuxing1.png',
}
local AttrTextrueSelect = {
    [1] = 'ui_new/Zhuzhan/bg_kw_qixue2.png',
    [2] = 'ui_new/Zhuzhan/bg_kw_wuli2.png',
    [3] = 'ui_new/Zhuzhan/bg_kw_fanyu2.png',
    [4] = 'ui_new/Zhuzhan/bg_kw_neili2.png',
    [5] = 'ui_new/Zhuzhan/bg_kw_shenfa2.png',
    [100] = 'ui_new/Zhuzhan/bg_kw_quanshuxing2.png',
}

function AssistAgreeLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.ZhuZhan.Qihe")
end

function AssistAgreeLayer:initUI( ui )
	self.super.initUI(self, ui)

    self.IconTable = {}
    for i=1,IconPosMax do
        local iconNode = TFDirector:getChildByPath(ui, "z"..i)
        --img_suo
        self.IconTable[i] = {}
        self.IconTable[i].IconBtn = iconNode
        self.IconTable[i].Lock = TFDirector:getChildByPath(iconNode, "img_suo")
        self.IconTable[i].kaifang = TFDirector:getChildByPath(iconNode, "txt_kaifang"..i)
        self.IconTable[i].headFrame = TFDirector:getChildByPath(iconNode, "btn_icon")
        self.IconTable[i].head = TFDirector:getChildByPath(iconNode, "img_touxiang")
        self.IconTable[i].zhiye = TFDirector:getChildByPath(iconNode, "img_zhiye")
        self.IconTable[i].starNode = TFDirector:getChildByPath(iconNode, "bg_lv")
        self.IconTable[i].arrow = TFDirector:getChildByPath(iconNode, "img_arrow")        
    end

    self.effectNode = {}
    local detailNode = TFDirector:getChildByPath(ui, "bg_xuanzhong")
    self.detailAttrImg = TFDirector:getChildByPath(detailNode, "Image_Qihe_1")
    self.detailStarNode = TFDirector:getChildByPath(detailNode, "bg_lv")
    local instruNode = TFDirector:getChildByPath(ui,'bg_shuxing')
    self.effectNode[1] = TFDirector:getChildByPath(ui, 'bg_shuxing')
    self.detailCurrName = TFDirector:getChildByPath(instruNode, "txt_qihe1")
    self.detailCurrAdd = TFDirector:getChildByPath(instruNode, "txt_shuxing1")
    self.detailNextName = TFDirector:getChildByPath(instruNode, "txt_qihe2")
    self.detailNextAdd = TFDirector:getChildByPath(instruNode, "txt_shuxing2")
    self.detailInstr = TFDirector:getChildByPath(instruNode, 'TextArea_Qihe_1')
    self.detailArrow1 = TFDirector:getChildByPath(instruNode, 'icon_jiantou1')
    self.detailArrow2 = TFDirector:getChildByPath(instruNode, 'icon_jiantou2')

    self.itemPanel = TFDirector:getChildByPath(ui, 'icon_panel')
    self.btnQihe = TFDirector:getChildByPath(ui, 'Button_Qihe_1')
    self.closeBtn = TFDirector:getChildByPath(ui,'btn_close')
    local coinNode = TFDirector:getChildByPath(ui, 'img_res_bg_1')
    self.txtCoin = TFDirector:getChildByPath(coinNode, 'txt_number_1')
    self.btnCoin = TFDirector:getChildByPath(coinNode, 'btn_add')
    coinNode:setVisible(false)
    local syceeNode = TFDirector:getChildByPath(ui, 'img_res_bg_2')
    self.txtSycee = TFDirector:getChildByPath(syceeNode, 'txt_number_2')
    self.btnSycee = TFDirector:getChildByPath(syceeNode, 'btn_add')
    syceeNode:setVisible(false)

    self.icon_xiala = TFDirector:getChildByPath(ui, 'icon_xiala')
    
    -- 创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui,"Panel_Qihechengjiu")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))   
    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.ZhuZhan.QiheCell")
    self.cellModel:retain()  
end

function AssistAgreeLayer:removeUI()
   	self.super.removeUI(self)
    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end    
end

function AssistAgreeLayer:onShow()
    self.super.onShow(self)

    self:showIocnLevelList()
    self:showIocnLevelDetails()    

    self.txtCoin:setText(getResValueExpressionByTypeForGH(HeadResType.COIN))
    self.txtSycee:setText(getResValueExpressionByTypeForGH(HeadResType.SYCEE))
    
end

function AssistAgreeLayer:registerEvents()

	if self.registerEventCallFlag then
		return
	end
    self.successFlag = false
    self.iconJihuo = nil
    self.needAchieveEffect = false

	self.super.registerEvents(self)  

    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);

    self.levelUpAgreeSuccessCallBack = function (event)
        local data = event.data[1]
        local pos = data.pos
        self.successFlag = true
        self:achieveDataReady()
        self:iconDataReadyByPos(pos)
        self:showIocnLevelNode(pos, true)
        self:showIocnLevelDetails()
        self:playEffect(true)
    end
    TFDirector:addMEGlobalListener(AssistFightManager.levelUpAgreeSuccess, self.levelUpAgreeSuccessCallBack)

    self.btnQihe:addMEListener(TFWIDGET_CLICK, audioClickfun(self.qiheButtonClick))
    self.btnQihe.logic = self
    self.btnCoin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.coinButtonClick))
    self.btnCoin.logic = self
    self.btnSycee:addMEListener(TFWIDGET_CLICK, audioClickfun(self.syceeButtonClick))
    self.btnSycee.logic = self
	
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.TabView:addMEListener(TFTABLEVIEW_SCROLL, self.tableScroll)
    

    for i=1,IconPosMax do
        self.IconTable[i].IconBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconPosClick))
        self.IconTable[i].IconBtn.logic = self
        self.IconTable[i].IconBtn.idx = i
    end

   	self.registerEventCallFlag = true
end

function AssistAgreeLayer:removeEvents()

    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(AssistFightManager.levelUpAgreeSuccess, self.levelUpAgreeSuccessCallBack)
    self.levelUpAgreeSuccessCallBack = nil

    self.btnQihe:removeMEListener(TFWIDGET_CLICK)
    for i=1,IconPosMax do
        self.IconTable[i].IconBtn:removeMEListener(TFWIDGET_CLICK)
    end
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    self.TabView:removeMEListener(TFTABLEVIEW_SCROLL)

    if self.successEffect then
        self.successEffect:removeMEListener(TFARMATURE_COMPLETE)
        self.successEffect:removeFromParent()
        self.successEffect = nil
    end
    self.registerEventCallFlag = nil
end

function AssistAgreeLayer:dispose()
    self.super.dispose(self)
end

function AssistAgreeLayer:showAchieveList()
    
end

function AssistAgreeLayer:showIocnLevelList()
    for i=1,IconPosMax do
        self:showIocnLevelNode(i, self.currIndex == i)
    end
end


function AssistAgreeLayer:showIocnLevelNode(pos, isSelect)

    local gridState = AssistFightManager:getGridList()
    local iconData = LocalIconData[pos]
    local iconNode = self.IconTable[pos]

    iconNode.arrow:setVisible(false)
    if iconData.LockState then
        local textureTbl = AttrTextrueNormal
        if isSelect then
            textureTbl = AttrTextrueSelect
            iconNode.arrow:setVisible(true)
        end
        local texture = textureTbl[100]
        if #iconData.attrTbl == 1 then
            local attrIdx = tonumber(iconData.attrTbl[1])
            texture = textureTbl[attrIdx]
        end

        iconNode.IconBtn:setTextureNormal(texture)
        iconNode.Lock:setVisible(false)
        iconNode.kaifang:setVisible(false)

        iconNode.starNode:setVisible(true)
        for j=1,5 do
            local starIcon = TFDirector:getChildByPath(iconNode.starNode, "icon_lv"..j)
            if iconData.level < j then
                starIcon:setVisible(false)
            else
                starIcon:setVisible(true)
            end
        end
    else            
        local texture = AttrTextrueNormal[100]
        if #iconData.attrTbl == 1 then
            local attrIdx = tonumber(iconData.attrTbl[1])
            texture = AttrTextrueNormal[attrIdx]
        end
        iconNode.IconBtn:setTextureNormal(texture)
        iconNode.Lock:setVisible(true)
        iconNode.kaifang:setVisible(true)
        iconNode.starNode:setVisible(false)
    end
end

function AssistAgreeLayer:showIocnLevelDetails()
    local data = LocalIconData[self.currIndex]

    for j=1,5 do
        local starIcon = TFDirector:getChildByPath(self.detailStarNode, "icon_lv"..j)
        if data.level < j then
            starIcon:setVisible(false)
        else
            starIcon:setVisible(true)
            if self.successFlag then
                self.effectNode[2] = starIcon
            end
        end
    end
    local currValue = math.floor(data.currBuf/100)
    local nextValue = math.floor(data.nextBuf/100)
    local currAdd,texture,tips,nextAdd
    local stringTemplete = localizable.assistAgreeLayer_add
    local TipsTemplete =  localizable.assistAgreeLayer_text1 
    if #data.attrTbl == 1 then
        local attrIdx = tonumber(data.attrTbl[1])
        print('data.attrTbl[1] = ',attrIdx)
        texture = AttrTextrueSelect[attrIdx]
        currAdd = stringUtils.format(stringTemplete, AttributeTypeStr[attrIdx], currValue)
        nextAdd = stringUtils.format(stringTemplete, AttributeTypeStr[attrIdx], nextValue)
        tips = stringUtils.format(TipsTemplete, AttributeTypeStr[attrIdx])
    else

        texture = AttrTextrueSelect[100]
        currAdd = stringUtils.format(stringTemplete, localizable.assistAgreeLayer_all, currValue)
        nextAdd = stringUtils.format(stringTemplete, localizable.assistAgreeLayer_all, nextValue)
        local attrStr = nil
        for _,attrIdx in pairs(data.attrTbl) do
            if attrStr then
                attrStr = attrStr..','..AttributeTypeStr[tonumber(attrIdx)]
            else
                attrStr = AttributeTypeStr[tonumber(attrIdx)]
            end
        end
        tips = stringUtils.format(TipsTemplete, attrStr)
    end
    
    self.detailAttrImg:setTexture(texture)
    local str = stringUtils.format(localizable.assistAgreeLayer_text2, data.level)
    self.detailCurrName:setText(str)
    self.detailCurrAdd:setText(currAdd)
    self.detailInstr:setText(tips)
    
    if data.level == qiheMaxLevel then
        self.detailNextName:setVisible(false)
        self.detailNextAdd:setVisible(false)
        self.itemPanel:setVisible(false)
        self.detailArrow1:setVisible(false)
        self.detailArrow2:setVisible(false)
    else
        self.detailArrow1:setVisible(true)
        self.detailArrow2:setVisible(true)
        self.detailNextName:setVisible(true)
        self.detailNextAdd:setVisible(true)
	local str = stringUtils.format(localizable.assistAgreeLayer_text2, data.level + 1)
        self.detailNextName:setText(str)
        self.detailNextAdd:setText(nextAdd)


        self.itemPanel:setVisible(true)
        self.itemPanel:removeAllChildren()
        for k,item in pairs(data.item) do
            local icon = require('lua.logic.role_new.RoleStarUpPreviewNumCell'):new()
            icon:setPosition(ccp((k-1)*(self.itemPanel:getContentSize().width + 10), 0))
            local curr_num = BagManager:getItemNumById( item.id )
            icon:setData(item.id,curr_num,item.num)
            self.itemPanel:addChild(icon)
        end
    end
end

function AssistAgreeLayer:loadData(Type)
    self.LineUpType = Type
    self.currIndex = AssistFightManager:getLastSelectPos() or 1

    self:achieveDataReady()
    self:iconDataReady()
end

function AssistAgreeLayer:achieveDataReady()
    local achieveCount = 0
    for i=1,AchieveMax do
        LocalAchieveData[i] = {}
        local level = i
        LocalAchieveData[i].level = level

        local currNum,totalNum = AssistFightManager:getAchieveState(level)
        LocalAchieveData[i].currNum = currNum
        LocalAchieveData[i].totalNum = totalNum
        LocalAchieveData[i].attr = {}
        local attrTbl,achieveName = AssistFightManager:getAchieveTemplete(level)
        for k,v in pairs(attrTbl) do
            LocalAchieveData[i].attr[k] = v
        end
        LocalAchieveData[i].achieveName = achieveName
        if currNum >= totalNum then
            achieveCount = achieveCount + 1
        end
    end
    local oldAchieveCount = self.currAchieveCount
    self.currAchieveCount = achieveCount

    if oldAchieveCount ~= self.currAchieveCount then
        self.needAchieveEffect = true
    else
        self.needAchieveEffect = false
    end
    if self.TabView then
        local achieveLevel = achieveCount
        if achieveLevel <= 0 then
            achieveLevel = 1
        end
        local offsetMax = cellH*AchieveMax - self.TabViewUI:getContentSize().height
        local offset = offsetMax - (achieveLevel-1)*cellH
        if offset < 0 then
            offset = 0
        end

        self.TabView:reloadData()
        self.TabView:setContentOffset(ccp(0,-(offset)))
    end
end

function AssistAgreeLayer:iconDataReady()
    for i=1,IconPosMax do
        self:iconDataReadyByPos(i)
    end
end

function AssistAgreeLayer:iconDataReadyByPos(pos)

    local levelTbl = AssistFightManager:getQiheLevelInfo()
    LocalIconData[pos] = {}
    local level = levelTbl[pos] or 0
    LocalIconData[pos].level = level
    if level == 0 then
        LocalIconData[pos].attrTbl = AgreeAttributeData:GetAttrTblIndex( 1, pos )
    else
        LocalIconData[pos].attrTbl = AgreeAttributeData:GetAttrTblIndex( level, pos )
    end
    LocalIconData[pos].currBuf = AgreeRuleData:GetPercentValue(level)
    LocalIconData[pos].nextBuf = AgreeRuleData:GetPercentValue(level+1)
    LocalIconData[pos].Gmid = AssistFightManager:getGmidByPos(self.LineUpType, pos) 
    local goods = AgreeRuleData:GetDataInfo( level + 1 )
    if goods then
        LocalIconData[pos].item = goods:GetItemInfo()
    end

    local gridState = AssistFightManager:getGridList()
    LocalIconData[pos].LockState = gridState[pos]
end

function AssistAgreeLayer.qiheButtonClick( btn )
    local self = btn.logic
    local data = LocalIconData[self.currIndex]

    if data.LockState == false then
        toastMessage(localizable.assistAgreeLayer_open)
        return
    end


    if data.level >= qiheMaxLevel then
        toastMessage(localizable.assistAgreeLayer_top_level)
        return
    end
    for k,item in pairs(data.item) do
        local curr_num = BagManager:getItemNumById( item.id )
        if curr_num < item.num then
            toastMessage(localizable.assistAgreeLayer_no_pro)
            return
        end
    end
    
    AssistFightManager:requestQihe(self.currIndex)
end


function AssistAgreeLayer.cellSizeForTable(table,idx)
    return cellH,416
end

function AssistAgreeLayer.numberOfCellsInTableView(table)
    return AchieveMax
end

function AssistAgreeLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()

    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()

        panel = self.cellModel:clone()
        local offset_x = self.TabViewUI:getContentSize().width-panel:getContentSize().width
        panel:setPosition(ccp(offset_x/2,0))
        -- panel:setPosition(ccp(0,0))
        cell:addChild(panel)
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end

    idx = idx + 1
    self:cellInfoSet(cell, panel, idx)

    return cell
end

function AssistAgreeLayer:cellInfoSet(cell, panel, idx)

    local bgOff = TFDirector:getChildByPath(panel, 'bg_t1')
    local titleOff = TFDirector:getChildByPath(bgOff, 'txt_title')
    local shuomingOff = TFDirector:getChildByPath(bgOff, 'txt_shuoming')
    local jinduOff = TFDirector:getChildByPath(bgOff, 'txt_jindu')

    local bgOn = TFDirector:getChildByPath(panel, 'bg_t2')
    local titleOn = TFDirector:getChildByPath(bgOn, 'txt_title')
    local shuomingOn = TFDirector:getChildByPath(bgOn, 'txt_shuoming')
    local jinduOn = TFDirector:getChildByPath(bgOn, 'txt_jindu')
    local icon_jihuo = TFDirector:getChildByPath(bgOn, 'icon_jihuo')

    local item = LocalAchieveData[idx]

    titleOff:setText(item.achieveName)
    titleOn:setText(item.achieveName)

    local attrAddName = nil
    for k,v in pairs(item.attr) do
        local value = v
        if k >= 18 then
            value = math.floor(value/100)
            value = value..'%'
        end
        if attrAddName then
            attrAddName = attrAddName..' '..AttributeTypeStr[k]..'+'..value
        else
            attrAddName =stringUtils.format(localizable.assistAgreeLayer_up_all,AttributeTypeStr[k],value)
        end
    end

    shuomingOff:setText(attrAddName)
    shuomingOn:setText(attrAddName)
    
    jinduOff:setText(item.currNum..'/'..item.totalNum)
    jinduOn:setText(item.currNum..'/'..item.totalNum)

    if item.currNum >= item.totalNum then
        bgOff:setVisible(false)
        bgOn:setVisible(true)
        icon_jihuo:setVisible(true)
        if self.needAchieveEffect then
            self.effectNode[3] = panel
            self.iconJihuo = icon_jihuo
        end
    else
        bgOff:setVisible(true)
        bgOn:setVisible(false)
    end
end

function AssistAgreeLayer.iconPosClick( btn )
    local self = btn.logic
    local choseIdx = btn.idx
    -- if choseIdx == self.currIndex then
    --     return
    -- end
    if self.successFlag then
        return
    end

    if LocalIconData[choseIdx].LockState then
        self:showIocnLevelList(choseIdx, false)
        self.currIndex = choseIdx
        AssistFightManager:setLastSelectPos(choseIdx) 
        self:showIocnLevelList(choseIdx, true)        
        self:showIocnLevelDetails()
    else
        toastMessage(localizable.assistAgreeLayer_open)
    end
end

function AssistAgreeLayer.coinButtonClick( btn )
    CommonManager:showNeedCoinComfirmLayer()
end

function AssistAgreeLayer.syceeButtonClick( btn )
    PayManager:showPayLayer()
end

function AssistAgreeLayer:refreshArrowBtn()
    if self.TabView then
        local offsetMax = self.TabViewUI:getContentSize().height-cellH*AchieveMax
        local currPosition = self.TabView:getContentOffset()
        if currPosition.y < 0 and offsetMax >= currPosition.y then
            self.icon_xiala:setVisible(true)
        else
            self.icon_xiala:setVisible(false)
        end
    end
end

function AssistAgreeLayer.tableScroll( table )
    local self = table.logic
    self:refreshArrowBtn()
end

function AssistAgreeLayer:playEffect(isTrue) 
    if isTrue then
        self.TabView:setTouchEnabled(false)
        self:addResultEffect(self.effectNode, 1)
        if self.iconJihuo then
            self.iconJihuo:setVisible(false)
        end
    else
        if self.iconJihuo then
            self.iconJihuo:setVisible(true)
        end
        self.iconJihuo = nil
        self.needAchieveEffect = false
        self.successFlag = false
        self.TabView:setTouchEnabled(true)
    end
end

function AssistAgreeLayer:addResultEffect(parentNode, index) 

    local offsetPos = {
        {x = 190,y = 80},
        {x = 10,y = 10},
        {x = 208,y = 37}
    }
    if self.successEffect then
        self.successEffect:removeMEListener(TFARMATURE_COMPLETE)
        self.successEffect:removeFromParent()
        self.successEffect = nil
    end
    
    if parentNode[index] == nil then
        print('找不到node',index)
        if index == 3 or (index == 2 and self.needAchieveEffect == false) then
            self:playEffect(false)
            return
        end        
        local newIdx = index + 1
        self:addResultEffect(self.effectNode, newIdx)    
        return
    end

    local fileName = 'qihe'..index
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/"..fileName..".xml")
    local effect = TFArmature:create(fileName.."_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    parentNode[index]:addChild(effect)
    
    local newX = offsetPos[index].x
    local newY = offsetPos[index].y
    effect:setPosition(ccp(newX, newY))
    effect:setZOrder(500)

    self.successEffect = effect
    self.successEffect:playByIndex(0, -1, -1, 0)

    local function showComplete()
        effect:addMEListener(TFARMATURE_COMPLETE,function()
            effect:removeFromParent()
            self.successEffect = nil
            if index == 3 then
                self:playEffect(false)
                return
            end        
            local newIdx = index + 1
            self:addResultEffect(self.effectNode, newIdx)    
        end)
    end
    local function showUpdate()
        local updateIdex = 1
        effect:addMEListener(TFARMATURE_UPDATE,function()
            updateIdex = updateIdex + 1
            if updateIdex >= 25 then
                effect:removeFromParent()
                self.successEffect = nil
                if index == 3 or (index == 2 and self.needAchieveEffect == false)then
                    self:playEffect(false)
                    return
                end        
                local newIdx = index + 1
                self:addResultEffect(self.effectNode, newIdx)   
            end 
        end)
    end
    
    if index == 2 then
        showUpdate()
    else
        showComplete()
    end
end


return AssistAgreeLayer
