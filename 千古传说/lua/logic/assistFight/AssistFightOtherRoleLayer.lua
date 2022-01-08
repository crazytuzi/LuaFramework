--[[
******助战阵容没有上阵列表信息*******

	-- by quanhuan
	-- 2015/11/25
]]

local AssistFightOtherRoleLayer = class("AssistFightOtherRoleLayer")

function AssistFightOtherRoleLayer:ctor(data)  
	self:initUI(data)
end

function AssistFightOtherRoleLayer:initUI( ui )
    self.uiNode = ui
    self.closeBtn = TFDirector:getChildByPath(self.uiNode, "btn_shousuo")
    self.closeBtn.logic = self

    self.roleSelectBg = TFDirector:getChildByPath(self.uiNode, "role_select")

    self.TabViewUI = TFDirector:getChildByPath(self.uiNode, "panel_cardregional")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.cellModel = createUIByLuaNew("lua.uiconfig_mango_new.role.ArmyRoleItem")
    self.cellModel:setScale(0.65)
    self.cellModel:retain()

end

function AssistFightOtherRoleLayer:removeUI()
    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end
end

function AssistFightOtherRoleLayer:registerEvents()

	if self.registerEventCallFlag then
		return
	end
    self.closeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClick))
        --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

   	self.registerEventCallFlag = true
end

function AssistFightOtherRoleLayer:removeEvents()
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    self.closeBtn:removeMEListener(TFWIDGET_CLICK)
    self.registerEventCallFlag = nil
end

function AssistFightOtherRoleLayer:moveIn()
    self.roleSelectBg:setVisible(true)
    self.uiNode:runAnimation("Action0",1)
end

function AssistFightOtherRoleLayer:moveOut()
    self.uiNode:runAnimation("Action1",1)
    self.uiNode:setAnimationCallBack("Action1", TFANIMATION_END, function()
        self.roleSelectBg:setVisible(false)
        end)    
end

function AssistFightOtherRoleLayer.closeBtnClick(btn)
    local self = btn.logic
    self:moveOut()
end


function AssistFightOtherRoleLayer.cellSizeForTable(table,idx)
    return 135,115
end

function AssistFightOtherRoleLayer.numberOfCellsInTableView(table)
    local self = table.logic
    return math.max(math.ceil(self.cellMax/3) ,3)
end

function AssistFightOtherRoleLayer.tableCellAtIndex(table, idx) 
    local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1
        self.allPanels[newIndex] = cell

        for i=1,3 do
            local panel = self.cellModel:clone()
            panel:setPosition(ccp(20 + 115 * (i - 1) ,0))
            cell:addChild(panel)
            panel:setTag(10086 + i)
        end    
    end
    
    for i=1,3 do
        local panel = cell:getChildByTag(10086+i)
        self:cellInfoSet(panel, idx*3+i)
    end

    return cell
end

function AssistFightOtherRoleLayer:cellInfoSet( panel, idx )

    if panel.boundData == nil then
        panel.boundData = true
        panel.panelEmpty = TFDirector:getChildByPath(panel, "panel_empty")
        panel.panelInfo = TFDirector:getChildByPath(panel, "panel_info")
        panel.btn = TFDirector:getChildByPath(panel, "btn_pingzhianniu")
        panel.img_pinzhiditu = TFDirector:getChildByPath(panel, "img_pinzhiditu")
        panel.img_touxiang = TFDirector:getChildByPath(panel, "img_touxiang")
        panel.txt_lv_word = TFDirector:getChildByPath(panel, "txt_lv_word")
        panel.img_zhan = TFDirector:getChildByPath(panel, "img_zhan")
        panel.txt_name = TFDirector:getChildByPath(panel, "txt_name")
        panel.img_zhiye = TFDirector:getChildByPath(panel, "img_zhiye")
        panel.img_quality = TFDirector:getChildByPath(panel, "img_quality")
        panel.img_fate = TFDirector:getChildByPath(panel, "img_fate")

        panel.btn:addMEListener(TFWIDGET_CLICK,audioClickfun(self.cellButtonClick))
        panel.btn.logic = self
    end

    panel.btn.idx = idx

    local roleItem = self.cardRoleList:objectAt(idx);
    if  roleItem then
        panel.panelEmpty:setVisible(true)
        panel.panelInfo:setVisible(true)

        panel.img_touxiang:setTexture(roleItem:getIconPath())    
        panel.img_pinzhiditu:setTexture(GetColorIconByQuality(roleItem.quality))
        local roleStar = ""
        if roleItem.starlevel > 0 then
            roleStar = roleStar .. " +" .. roleItem.starlevel
        end
        panel.txt_name:setText(roleItem.name..roleStar)
        panel.img_zhiye:setTexture("ui_new/fight/zhiye_".. roleItem.outline ..".png")
        panel.img_quality:setTexture(GetFightRoleIconByWuXueLevel(roleItem.martialLevel))    
        panel.img_zhan:setVisible(false)
        --print("roleItem = ",roleItem.fateid)
        if roleItem.fateid ~= 0 then
            panel.img_fate:setVisible(true)
        else
            panel.img_fate:setVisible(false)
        end

        panel.txt_lv_word:setText(roleItem.level)
    else
        panel.panelEmpty:setVisible(true)
        panel.panelInfo:setVisible(false)
    end
end

function AssistFightOtherRoleLayer:refreshData()
    
    self.cardRoleList = AssistFightManager:getCardRoleList(self.LineUpType)
    self.cellMax = self.cardRoleList:length()
    print("self.cellMax = ",self.cellMax)

    self.TabView:reloadData()
end

function AssistFightOtherRoleLayer.cellButtonClick( btn )
    local self = btn.logic
    local roleItem = self.cardRoleList:objectAt(btn.idx)

    if roleItem.fateid == 0 then
        CommonManager:showOperateSureLayer(
                function()                   
                    if self.parent then
                        self.parent:setAssistOn()
                    end
                    AssistFightManager:requestUpdateRole(self.LineUpType, self.iconIdx, roleItem.gmId)
                    self:moveOut()
                end,
                function()
                    AlertManager:close()
                end,
                {
                title = localizable.common_tips ,
                msg = localizable.common_tips_zhuzhan_text1,
                }
            )
    else
        if self.parent then
            self.parent:setAssistOn()
        end        
        AssistFightManager:requestUpdateRole(self.LineUpType, self.iconIdx, roleItem.gmId)
        self:moveOut()
    end
end

function AssistFightOtherRoleLayer:setLineUpType( Type, iconIdx ,layer)
    self.LineUpType = Type
    self.iconIdx = iconIdx
    self.parent = layer
end

function AssistFightOtherRoleLayer:setVisible( v )
    self.TabView:setVisible(v)
end
return AssistFightOtherRoleLayer
