--[[
******帮派战-选择精英*******

	-- by quanhuan
	-- 2016/2/23
	
]]

local FactionSignUpChoose = class("FactionSignUpChoose",BaseLayer)

local memberData = {}
function FactionSignUpChoose:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionSignUpChoose")
end

function FactionSignUpChoose:initUI( ui )

	self.super.initUI(self, ui)

    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_ok = TFDirector:getChildByPath(ui, "btn_ok")
    

    --创建TabView
    local tabViewUI = TFDirector:getChildByPath(ui,"panel_table")
    local tabView =  TFTableView:create()
    tabView:setTableViewSize(tabViewUI:getContentSize())
    tabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    tabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tabView.logic = self
    tabViewUI:addChild(tabView)
    tabView:setPosition(ccp(0,0))
    self.tabView = tabView

    self.cellModel = TFDirector:getChildByPath(ui, 'panel_zhenlie1')
    self.cellModel:setVisible(false)
end


function FactionSignUpChoose:removeUI()
	self.super.removeUI(self)
end

function FactionSignUpChoose:onShow()
    self.super.onShow(self)
end

function FactionSignUpChoose:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnOkClick))
    self.btn_ok.logic = self

    self.tabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tabView.logic = self



    self.registerEventCallFlag = true 
end

function FactionSignUpChoose:removeEvents()

    self.super.removeEvents(self)

    self.btn_ok:removeMEListener(TFWIDGET_CLICK)

    self.tabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)


    self.registerEventCallFlag = nil  
end

function FactionSignUpChoose:dispose()
	self.super.dispose(self)
end

function FactionSignUpChoose.cellSizeForTable(table,idx)
    return 78,290
end

function FactionSignUpChoose.numberOfCellsInTableView(table)
    return 5
end

function FactionSignUpChoose.tableCellAtIndex(table, idx)

    local self = table.logic
    
    local cell = table:dequeueCell()
    if cell == nil then
        cell = TFTableViewCell:create()
        cell.panels = {}

        local panel1 = self.cellModel:clone()
        panel1:setPosition(ccp(0,0))
        cell:addChild(panel1)
        panel1:setVisible(true)        
        cell.panels[1] = panel1

        local panel2 = self.cellModel:clone()
        panel2:setPosition(ccp(300,0))
        cell:addChild(panel2)
        panel2:setVisible(true)
        cell.panels[2] = panel2
    end

    local panels = cell.panels or {}

    for k,panel in pairs(panels) do

        local img_jingying1di = TFDirector:getChildByPath(panel, 'img_jingying1di')
        local img_jingying1 = TFDirector:getChildByPath(panel, 'img_jingying1')
        local img_jingying2 = TFDirector:getChildByPath(panel, 'img_jingying2')

        local dataIndex = idx*2 + k
        local itemData = memberData[dataIndex]
        if itemData then
            img_jingying1di:setVisible(false)
            img_jingying1:setVisible(true)
            img_jingying2:setVisible(true)

            if dataIndex == self.currSelectIdx then
                img_jingying1:setVisible(false)

                local img_touxiang = TFDirector:getChildByPath(img_jingying2, 'img_touxiang')
                local txt_name = TFDirector:getChildByPath(img_jingying2, 'txt_name')
                local txt_num = TFDirector:getChildByPath(img_jingying2, 'txt_num')
                local btn_xuanze = TFDirector:getChildByPath(img_jingying2, 'btn_xuanze')

                local RoleIcon = RoleData:objectByID(itemData.profession)
                img_touxiang:setTexture(RoleIcon:getIconPath())
                Public:addFrameImg(img_touxiang,itemData.headPicFrame)
                Public:addInfoListen(img_touxiang,true,3,itemData.playerId)
                txt_name:setText(itemData.playerName)
                txt_num:setText(itemData.power)

                btn_xuanze.logic = self
                btn_xuanze.idx = dataIndex
                btn_xuanze:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnXuanzeClick))
                btn_xuanze:setTextureNormal('ui_new/climb/btn_gouxuan_press.png')
            else
                img_jingying2:setVisible(false)

                local img_touxiang = TFDirector:getChildByPath(img_jingying1, 'img_touxiang')
                local txt_name = TFDirector:getChildByPath(img_jingying1, 'txt_name')
                local txt_num = TFDirector:getChildByPath(img_jingying1, 'txt_num')
                local btn_xuanze = TFDirector:getChildByPath(img_jingying1, 'btn_xuanze')

                local RoleIcon = RoleData:objectByID(itemData.profession)
                img_touxiang:setTexture(RoleIcon:getIconPath())
                Public:addFrameImg(img_touxiang,itemData.headPicFrame)
                Public:addInfoListen(img_touxiang,true,3,itemData.playerId)
                txt_name:setText(itemData.playerName)
                txt_num:setText(itemData.power)

                btn_xuanze.logic = self
                btn_xuanze.idx = dataIndex
                btn_xuanze:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnXuanzeClick))                
            end
        else
            img_jingying1di:setVisible(true)
            img_jingying1:setVisible(false)
            img_jingying2:setVisible(false)
        end
    end
    return cell
end

function FactionSignUpChoose:dataReady(queueIndex)

    memberData = FactionFightManager:getMemberDataByIndex(queueIndex)
    local leaderData = FactionFightManager:getLeaderDataByIndex(queueIndex)
    self.currSelectIdx = 0
    if leaderData then
        for k,v in pairs(memberData) do
            if v.playerId == leaderData.playerId then
                self.currSelectIdx = k
                break
            end
        end
    end
    self.queueIndex = queueIndex
    self.tabView:reloadData()
end

function FactionSignUpChoose.btnOkClick( btn )
    local self = btn.logic
    local info = FactionManager:getFactionInfo()
    if FactionManager:getPostInFaction() ~= 1 then
        --toastMessage("权限不够")
        toastMessage(localizable.common_no_power)
        return
    end    
    AlertManager:close()
    local data = memberData[self.currSelectIdx] or {}
    local playerId = data.playerId or 0

    print('playerId = ',playerId)
    if playerId ~= 0 then
        FactionFightManager:requestUpdateLeader(self.queueIndex - 1, playerId)    
    end
end

function FactionSignUpChoose.btnXuanzeClick( btn )
    local self = btn.logic
    self.currSelectIdx = btn.idx
    self.tabView:reloadData()
end
return FactionSignUpChoose