--[[
******奇门盾-突破*******

	-- by quanhuan
	-- 2016/1/26
	
]]

local qimenduntupoLayer = class("qimenduntupoLayer",BaseLayer)

local cellW = 306
local cellH = 119
function qimenduntupoLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.climb.qimenduntupo")
end

function qimenduntupoLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.btn_close = TFDirector:getChildByPath(ui,"btn_close")
    self.btn_tupo = TFDirector:getChildByPath(ui,"btn_tupo")

    self.txt_price = TFDirector:getChildByPath(ui,"txt_price")
    -- self.img_bagua1 = TFDirector:getChildByPath(ui, 'img_bagua1')
    -- self.img_bagua2 = TFDirector:getChildByPath(ui, 'img_bagua2')
    self:countQimenSizeInfo()
    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui,"Panel_chongshu")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.climb.qimenduntupocall")
    self.cellModel:retain()


    local info = CardRoleManager:getQimenInfo() or {}
    self.oldTableData = {}
    self.oldTableData.idx = info.idx
    self.oldTableData.level = info.level
    self:showItem()

    -- self.effectBuf = {}
    -- TFResourceHelper:instance():addArmatureFromJsonFile("effect/mainrole/light.xml")
    -- local effectMode = TFArmature:create("light_anim")
    -- for i=1,24 do
    --     local abc = math.ceil(i/8) - 1
    --     local effect = effectMode:clone()
    --     effect:setAnimationFps(GameConfig.ANIM_FPS)
    --     effect:playByIndex(abc, -1, -1, 1)
    --     effect:setVisible(false)
    --     effect:setRotation(360-(i-1)%8*45)
    --     local contentSize = self.img_bagua1:getContentSize()
    --     local offsetX = contentSize.width/2
    --     local offsetY = contentSize.height/2
    --     effect:setPosition(ccp(offsetX,offsetY))
    --     self.img_bagua1:addChild(effect)
    --     self.effectBuf[i] = effect
    -- end
    -- self:setDataInfoAll(self.oldTableData.idx, self.oldTableData.level)

    
end

function qimenduntupoLayer:showItem()
    local info = CardRoleManager:getQimenInfo() or {}
    local curLevel = math.floor(info.idx / 24)
    local curIdx = info.idx % 24
    if curIdx == 0 and curLevel ~= info.level then
        curIdx = 25
    end
    for i=1,25 do
        local j = i < 10 and ("0" .. i) or i
        local item = TFDirector:getChildByPath(self.ui, "img" .. j)
        local pic = i == 25 and "ui_new/Ys_common/sx_dadian.png" or "ui_new/Ys_common/sx_dian.png"
        if i <= curIdx then
            pic = i == 25 and "ui_new/Ys_common/sx_dadianliang.png" or "ui_new/Ys_common/sx_dianliang.png"            
        end
        item:setTexture(pic)
    end
end

function qimenduntupoLayer:countQimenSizeInfo()
    self.qimenSize = {}
    self.qimenPanelHight = 0
    for i=1,QimenBreachConfigData:length() do
        local templeteTeamInfo = self:getTeamAttrDes(i)
        local templeteInfo = self:getAttrDes(i)
        local attrNum = #templeteInfo + #templeteTeamInfo
        if attrNum  <= 2 then
            self.qimenSize[i] = CCSizeMake(300,123)
        elseif attrNum == 3 then
            self.qimenSize[i] = CCSizeMake(350,143)
        elseif attrNum >= 4 then
            self.qimenSize[i] = CCSizeMake(350,163)
        end
        self.qimenPanelHight = self.qimenPanelHight + self.qimenSize[i].height
    end
end

function qimenduntupoLayer:removeUI()
	self.super.removeUI(self)
end

function qimenduntupoLayer:onShow()
    self.super.onShow(self)
end

function qimenduntupoLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self:resetTableViewPosition()

    self.btn_tupo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTopuBtnClickHandle),1)
    self.btn_tupo.logic = self
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1)

    self.qimenBreachCallBack = function (event)
        play_lingdaolitisheng()

        -- local str = TFLanguageManager:getString(ErrorCodeData.Gossip_Breach_success)
        local info = CardRoleManager:getQimenInfo()
        -- str = string.format(str, numberToChinese(info.level))

        local str = stringUtils.format(localizable.Gossip_Breach_success, numberToChinese(info.level) )
        toastMessage(str)
        self.effectLevel = info.level
        self:resetTableViewPosition()
        if CardRoleManager:checkCanBreach(info.idx, info.level) then
            Public:addBtnWaterEffect(self.btn_tupo, true,1)
        else
            Public:addBtnWaterEffect(self.btn_tupo, false,1)
        end 
        self:showItem()
        -- self:showEffect()
    end
    TFDirector:addMEGlobalListener(CardRoleManager.QIMEN_BREACH_SUCCESS, self.qimenBreachCallBack)  

    self.isFristTime = true
    self.isFristTime = nil
    self.ui:setAnimationCallBack("Action0", TFANIMATION_END, function()
        if CardRoleManager:checkCanBreach(self.oldTableData.idx, self.oldTableData.level) then
            Public:addBtnWaterEffect(self.btn_tupo, true,1)
        else
            Public:addBtnWaterEffect(self.btn_tupo, false,1)
        end 
    end)
    self.ui:runAnimation("Action0",1)

    self.registerEventCallFlag = true 
end

function qimenduntupoLayer:removeEvents()

    self.super.removeEvents(self)

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
 	
 	self.btn_tupo:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(CardRoleManager.QIMEN_BREACH_SUCCESS, self.qimenBreachCallBack)  
    self.qimenBreachCallBack = nil

    if self.breachEffect then
        self.breachEffect:removeMEListener(TFARMATURE_COMPLETE) 
        self.breachEffect:removeFromParent()
        self.breachEffect = nil
    end
    if self.refreshEffect then
        self.refreshEffect:removeMEListener(TFARMATURE_COMPLETE) 
        self.refreshEffect:removeFromParent()
        self.refreshEffect = nil
    end

    self.registerEventCallFlag = nil  
end


function qimenduntupoLayer.cellSizeForTable(table,idx)
    local self = table.logic
    idx = idx + 1
    if self.qimenSize[idx] then
        return self.qimenSize[idx].height,self.qimenSize[idx].width
    end
    return cellH,cellW
end

function qimenduntupoLayer.numberOfCellsInTableView(table)
    local self = table.logic
    return QimenBreachConfigData:length()
end

function qimenduntupoLayer.tableCellAtIndex(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()

    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModel:clone()
        panel:setPosition(ccp(16,0))
        cell:addChild(panel)
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end
    idx = idx + 1
    self:cellInfoSet(cell, panel, idx)

    return cell
end

function qimenduntupoLayer:getTeamAttrDes(idx)
    local dataInfo = QimenBreachConfigData:getInfoById(idx) or {}
    local strTemplete = {}
    if dataInfo.team_attribute ~= '' then
        local dataBuff = string.split(dataInfo.team_attribute, '|')
        for i=1,#dataBuff do
            local awardData = stringToNumberTable(dataBuff[i], '_')
            if awardData[1] < 18 then
                strTemplete[#strTemplete + 1] = AttributeTypeStr[awardData[1]]..' +'..math.abs(awardData[2])
            else
                strTemplete[#strTemplete + 1] = AttributeTypeStr[awardData[1]]..' +'..(math.floor(math.abs(awardData[2])/100)..'%')
            end
        end
    end
    return strTemplete
end

function qimenduntupoLayer:getAttrDes(idx)
    
    local dataInfo = QimenBreachConfigData:getInfoById(idx) or {}
    local strTemplete = {}
    if dataInfo.attribute ~= '' then
        local dataBuff = string.split(dataInfo.attribute, '|')
        for i=1,#dataBuff do
            local awardData = stringToNumberTable(dataBuff[i], '_')
            if awardData[1] < 18 then
                strTemplete[#strTemplete + 1] = AttributeTypeStr[awardData[1]]..' +'..math.abs(awardData[2])
            else
                strTemplete[#strTemplete + 1] = AttributeTypeStr[awardData[1]]..' +'..(math.floor(math.abs(awardData[2])/100)..'%')
            end
        end
    end

    if dataInfo.immune_rate ~= '' then
        local awardData = stringToNumberTable(dataInfo.immune_rate, '_')            
        strTemplete[#strTemplete + 1] = SkillBuffHurtStr[awardData[1]]..' +'..(math.floor(math.abs(awardData[2])/100)..'%')   
    end

    if dataInfo.effect_active ~= '' then
        local awardData = stringToNumberTable(dataInfo.effect_active, '_')          
        strTemplete[#strTemplete + 1] = SkillBuffHurtStr[awardData[1]]..' +'..(math.floor(math.abs(awardData[2])/100)..'%')            
    end

    if dataInfo.effect_passive ~= '' then
        local awardData = stringToNumberTable(dataInfo.effect_passive, '_') 
        strTemplete[#strTemplete + 1] = SkillBuffHurtStr[awardData[1]]..' +'..(math.floor(math.abs(awardData[2])/100)..'%')                     
    end
    return strTemplete
end

function qimenduntupoLayer:cellInfoSet(cell, panel, idx)

    if not cell.boundData then
        cell.boundData = true
        cell.infoPanel = {}
        for i=1,6 do
            local bgNode = TFDirector:getChildByPath(panel, 'bg'..i)
            cell.infoPanel[i] = {}
            cell.infoPanel[i].node = bgNode
            cell.infoPanel[i].titleName = TFDirector:getChildByPath(bgNode, 'txt_name')
            for j=1,4 do
                cell.infoPanel[i]["attr"..j] = TFDirector:getChildByPath(bgNode, 'txt_'..j)
            end
        end
    end
    for i=1,6 do
        if cell.infoPanel[i] and cell.infoPanel[i].node then
            cell.infoPanel[i].node:setVisible(false)
        end
    end
    local templeteTeamInfo = self:getTeamAttrDes(idx)
    local templeteInfo = self:getAttrDes(idx)
    local attrNum = #templeteInfo + #templeteTeamInfo
    if attrNum < 2 then attrNum = 2 end
    local panelIndex = (attrNum-1)*2
    for i=panelIndex-1,panelIndex do
        cell.infoPanel[i].titleName:setText(stringUtils.format(localizable.qimenduntupo_text1, numberToChinese(idx) ))
        for k,v in ipairs(templeteInfo) do
            if v then
                cell.infoPanel[i]["attr"..k]:setVisible(true)
                cell.infoPanel[i]["attr"..k]:setText(v)
            else
                cell.infoPanel[i]["attr"..k]:setVisible(false)
            end
        end
        for k,v in ipairs(templeteTeamInfo) do
            if v then
                cell.infoPanel[i]["attr"..k+#templeteInfo]:setVisible(true)
                cell.infoPanel[i]["attr"..k+#templeteInfo]:setText(localizable.qimenduntupo_text2..v)
            else
                cell.infoPanel[i]["attr"..k+#templeteInfo]:setVisible(false)
            end
        end
        for k= #templeteInfo + #templeteTeamInfo ,4 do
            if cell.infoPanel[i]["attr"..k+#templeteInfo] then
                cell.infoPanel[i]["attr"..k+#templeteInfo]:setVisible(false)
            end
        end
    end
    
    if self.effectLevel and self.effectLevel == idx then
        self.effectLevel = nil
        self:showRefreshEffect(cell,panel,attrNum)
    end

    local qimenInfo = self.oldTableData
    if idx > qimenInfo.level then
        cell.infoPanel[panelIndex-1].node:setVisible(false)
        cell.infoPanel[panelIndex].node:setVisible(true)
    else
        cell.infoPanel[panelIndex-1].node:setVisible(true)
        cell.infoPanel[panelIndex].node:setVisible(false)
    end
end

function qimenduntupoLayer:dispose()
	self.super.dispose(self)
end

function qimenduntupoLayer.onTopuBtnClickHandle(btn)
    local self = btn.logic

    local qimenInfo = CardRoleManager:getQimenInfo()
    local info = QimenBreachConfigData:getInfoById(qimenInfo.level+1)
    if info then
        if info.level > MainPlayer:getLevel() then
            -- local str = TFLanguageManager:getString(ErrorCodeData.Gossip_Level_insufficient)
            -- str = string.format(str, info.level)
            local str = stringUtils.format(localizable.Gossip_Level_insufficient, info.level)
            toastMessage(str)
            return
        end
        if info.climb_star > MainPlayer:getClimbStarValue() then
            toastMessage(localizable.Gossip_No_Prop)
            return
        end
    else
        print('table error')
        return
    end
    if CardRoleManager:checkCanBreach(qimenInfo.idx, qimenInfo.level) then
        CardRoleManager:requestQimenBreach()
    else
        toastMessage(localizable.Gossip_No_Upgrade_complete)
    end
end

function qimenduntupoLayer.onCloseClickHandle( btn )
    AlertManager:close()
end

function qimenduntupoLayer:resetTableViewPosition()
    self.TabView:reloadData()
    local info = self.oldTableData
    local offsetY = 0
    for i=1,info.level-1 do
        offsetY = offsetY + self.qimenSize[i].height
    end
    local cellMax = QimenBreachConfigData:length()
    local viewHeight = self.TabViewUI:getContentSize().height
    viewHeight = self.qimenPanelHight - viewHeight
    viewHeight = viewHeight - offsetY
    if viewHeight < 0 then
        viewHeight = 0
    end
    self.TabView:setContentOffset(ccp(0,-viewHeight))

    local qimenInfo = QimenBreachConfigData:getInfoById(info.level+1)
    if qimenInfo then
        self.txt_price:setVisible(true)
        self.txt_price:setText(qimenInfo.climb_star)    
    else
        self.txt_price:setVisible(false)
    end
end

-- function qimenduntupoLayer:showEffect()
--     local filePath = "effect/mainrole/breach.xml"
--     TFResourceHelper:instance():addArmatureFromJsonFile(filePath)
--     local effect = TFArmature:create("breach_anim")
--     effect:setAnimationFps(GameConfig.ANIM_FPS)
--     effect:playByIndex(0, -1, -1, 0)
--     effect:setVisible(true)

--     local contentSize = self.img_bagua1:getContentSize()
--     local offsetX = contentSize.width/2
--     local offsetY = contentSize.height/2
--     effect:setPosition(ccp(offsetX-192,offsetY-18))
--     -- effect:setPosition(ccp(18,186))
--     self.img_bagua1:addChild(effect,100)
--     self.breachEffect = effect

--     self.breachEffect:addMEListener(TFARMATURE_COMPLETE, function ()
--         self.breachEffect:removeMEListener(TFARMATURE_COMPLETE) 
--         self.breachEffect:removeFromParent()
--         self.breachEffect = nil
--         local info = CardRoleManager:getQimenInfo() or {}
--         self.effectLevel = info.level
--         self:resetTableViewPosition()
--         self:setDataInfoAll(info.idx, info.level)
--         if CardRoleManager:checkCanBreach(info.idx, info.level) then
--             Public:addBtnWaterEffect(self.btn_tupo, true,1)
--         else
--             Public:addBtnWaterEffect(self.btn_tupo, false,1)
--         end 
--     end)
-- end

function qimenduntupoLayer:showRefreshEffect(cell,panel,attrNum)
    -- local panelIndex = (attrNum-1)*2
    -- local node = cell.infoPanel[panelIndex].node
    -- local node1 = cell.infoPanel[2].node
    -- local filePath = "effect/mainrole/cellRefresh.xml"
    -- TFResourceHelper:instance():addArmatureFromJsonFile(filePath)
    -- local effect = TFArmature:create("cellRefresh_anim")
    -- effect:setAnimationFps(GameConfig.ANIM_FPS)
    -- effect:playByIndex(0, -1, -1, 0)
    -- effect:setVisible(true)
    -- local offsetY = node:getContentSize().height
    -- local offsetY1 = node1:getContentSize().height
    -- effect:setPosition(node:getPosition())
    -- effect:setScaleY(offsetY / offsetY1)
    -- panel:addChild(effect,100)
    -- self.refreshEffect = effect

    -- self.refreshEffect:addMEListener(TFARMATURE_COMPLETE, function ()
    --     self.refreshEffect:removeMEListener(TFARMATURE_COMPLETE) 
    --     self.refreshEffect:removeFromParent()
    --     self.refreshEffect = nil

    --     local info = CardRoleManager:getQimenInfo() or {}
    --     self.oldTableData = {}
    --     self.oldTableData.idx = info.idx
    --     self.oldTableData.level = info.level
    --     self.TabView:reloadData()
    -- end)

    local panelIndex = (attrNum-1)*2
    local node = cell.infoPanel[panelIndex].node
    local node1 = cell.infoPanel[2].node
    local offsetY = node:getContentSize().height
    local offsetY1 = node1:getContentSize().height
    local effect = Public:addEffect("sixiang5", panel, 0, 0, 1, 0)
    effect:setVisible(true)
    effect:setScaleY(offsetY / offsetY1)
    effect:setZOrder(100)
    self.refreshEffect = effect

    ModelManager:addListener(self.refreshEffect, "ANIMATION_COMPLETE", function()
        ModelManager:removeListener(self.refreshEffect, "ANIMATION_COMPLETE")
        self.refreshEffect:removeFromParent()
        self.refreshEffect = nil

        local info = CardRoleManager:getQimenInfo() or {}
        self.oldTableData = {}
        self.oldTableData.idx = info.idx
        self.oldTableData.level = info.level
        self.TabView:reloadData()
    end)
end

-- function qimenduntupoLayer:setDataInfoAll(idx, level)

--     local currIdx = idx%24
--     if CardRoleManager:checkCanBreach(idx, level) then
--         currIdx = 30        
--     end
--     for i=1,24 do
--         if i <= currIdx then
--             self.effectBuf[i]:setVisible(true)
--         else
--             self.effectBuf[i]:setVisible(false)
--         end
--     end
--     self.img_bagua1:setRotation((idx%8)*45)
--     self.img_bagua2:setRotation((idx%8)*45)  
-- end
return qimenduntupoLayer