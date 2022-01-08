--[[
******助战阵容没有上阵列表信息*******

	-- by quanhuan
	-- 2015/11/25
]]

local FriendRoleListLayer = class("FriendRoleListLayer",BaseLayer)

local columnNumber = 3

function FriendRoleListLayer:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.ZhuZhan.ZhuzhanRoleSelect")
end

function FriendRoleListLayer:initUI( ui )
    self.super.initUI(self, ui)

    self.btn_shousuo = TFDirector:getChildByPath(ui, "btn_shousuo")
    self.roleSelectBg = TFDirector:getChildByPath(ui, "role_select")

    self.TabViewUI = TFDirector:getChildByPath(ui, "panel_cardregional")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.cellModel = createUIByLuaNew("lua.uiconfig_mango_new.ZhuZhan.RoleItem")
    self.cellModel:retain()

end

function FriendRoleListLayer:initDate(LineUpType)
    self.LineUpType = LineUpType
    self.roleList = AssistFightManager:getFriendAssistListForSelect(LineUpType)
    self.TabView:reloadData()  
    if #self.roleList <= 0 then
        toastMessage(localizable.Assist_No_Assist_hero)
    end
end

function FriendRoleListLayer.cellSizeForTable(table,cell)
    return 216,166
end

function FriendRoleListLayer.tableCellAtIndex(table,idx)
    local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1
        self.allPanels[newIndex] = cell

        for i=1,columnNumber do
            local panel = self.cellModel:clone()
            panel:setPosition(ccp(40+220 * (i - 1) ,0))
            cell:addChild(panel)
            panel:setTag(i)
        end
    end
    for i=1,columnNumber do
        local panel = cell:getChildByTag(i)
        self:cellInfoSet(panel, idx*columnNumber+i)
    end

    return cell
end

function FriendRoleListLayer:cellInfoSet( panel, idx )

    if panel.boundData == nil then
        panel.boundData = true
        panel.panelEmpty = TFDirector:getChildByPath(panel, "panel_empty")
        panel.panelInfo = TFDirector:getChildByPath(panel, "panel_card")

        panel.btn = TFDirector:getChildByPath(panel, "bg_full")
        panel.img_pinzhiditu = TFDirector:getChildByPath(panel, "img_quality")
        panel.img_touxiang = TFDirector:getChildByPath(panel, "img_icon")
        panel.txt_lv_word = TFDirector:getChildByPath(panel, "txt_lv")
        panel.txtPlayerName = TFDirector:getChildByPath(panel, "txt_name")
        panel.txt_name = TFDirector:getChildByPath(panel, "txt_time")
        panel.img_zhiye = TFDirector:getChildByPath(panel, "img_zhiye")
        panel.img_quality = TFDirector:getChildByPath(panel, "img_martialLevel")
        panel.img_yuan = TFDirector:getChildByPath(panel, "img_yuan")

        panel.btn:setTouchEnabled(true)
        panel.btn:addMEListener(TFWIDGET_CLICK,audioClickfun(self.cellButtonClick))
        panel.btn.logic = self
    end

    panel.btn.idx = idx

    local roleItem = self.roleList[idx]
    if  roleItem and roleItem.role then
        panel.panelEmpty:setVisible(true)
        panel.panelInfo:setVisible(true)
        -- print('roleItem.playerName = ',roleItem.playerName)
        panel.txtPlayerName:setText(roleItem.playerName)
        panel.img_touxiang:setTexture(roleItem.role:getIconPath())    
        panel.img_pinzhiditu:setTexture(GetColorIconByQuality(roleItem.role.quality))        
        panel.txt_name:setText(roleItem.role.name)
        panel.img_zhiye:setTexture("ui_new/fight/zhiye_".. roleItem.role.outline ..".png")
        panel.img_quality:setTexture(GetFightRoleIconByWuXueLevel(1))
        panel.txt_lv_word:setText(1)

        if roleItem.fate == 1 then
            panel.img_yuan:setVisible(true)
        else
            panel.img_yuan:setVisible(false)
        end
    else
        panel.panelEmpty:setVisible(true)
        panel.panelInfo:setVisible(false)
    end
end

function FriendRoleListLayer.numberOfCellsInTableView(table,cell)
    local self = table.logic
    if self.roleList == nil then
        return 0
    end
    return math.ceil(#self.roleList/columnNumber)
end


function FriendRoleListLayer.cellButtonClick( btn )
    local self = btn.logic
    local idx = btn.idx
    local info = self.roleList[idx]
    if info then
        AssistFightManager:requestGetAssitRole(info.playerId, info.role.id, AssistFightManager.GETASSISTROLESUCCESS)
    end
    self:moveOut()
end

function FriendRoleListLayer:removeUI()
    self.super.removeUI(self)

    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end
end

function FriendRoleListLayer:onShow()
    self.super.onShow(self)

    if self.isFirst then
        print('self.isFirst = ',self.isFirst)
        self:moveIn()
        self.isFirst = false
    end
end



function FriendRoleListLayer.closeBtnClick(btn)
    local self = btn.logic
    self:moveOut()
end


function FriendRoleListLayer:moveIn()
    self.ui:runAnimation("Action0",1)
end
function FriendRoleListLayer:moveOut()
    self.ui:runAnimation("Action1",1)
    self.ui:setAnimationCallBack("Action1", TFANIMATION_END, function()
        AlertManager:close()
        end)
end

function FriendRoleListLayer:registerEvents()
    self.btn_shousuo.logic = self
    self.ui.logic = self
    self.isFirst = true
    self.ui:setTouchEnabled(true)
    self.btn_shousuo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClick))
    self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClick))

    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.super.registerEvents(self)
end

function FriendRoleListLayer:removeEvents()
    self.isFirst = true
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)    
    self.super.removeEvents(self)
end

function FriendRoleListLayer:dispose()

    self.super.dispose(self)
end


return FriendRoleListLayer