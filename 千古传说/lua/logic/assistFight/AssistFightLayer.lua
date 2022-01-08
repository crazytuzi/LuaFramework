--[[
******助战阵容列表信息*******

	-- by quanhuan
	-- 2015/11/24
]]
--assistLock
local AssistFightLayer = class("AssistFightLayer",BaseLayer)



function AssistFightLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.ZhuZhan.ZhuzhanMain")

    self.attrTbl = {}
end

function AssistFightLayer:setFateList(roleFateMap, fateList)
    self.roleFateMap = roleFateMap
    self.fateList    = fateList    
end

function AssistFightLayer:initUI( ui )
	self.super.initUI(self, ui)

    self.IconTable = {}
    self.originalPost = {}
    self.qiheIcon = {}
    for i=1,6 do
        local uiNode = TFDirector:getChildByPath(ui, "z"..i)
        self.IconTable[i] = {}
        self.IconTable[i].btn = uiNode
        self.IconTable[i].iconAdd = TFDirector:getChildByPath(uiNode, "icon_jia")        
        self.IconTable[i].iconLock = TFDirector:getChildByPath(uiNode, "img_suo")
        self.IconTable[i].iconLimit = TFDirector:getChildByPath(uiNode, "txt_kaifang"..i)
        self.IconTable[i].iconHead = TFDirector:getChildByPath(uiNode, "img_touxiang")
        self.IconTable[i].iconHeadFrame = TFDirector:getChildByPath(uiNode, "btn_icon")
        self.IconTable[i].iconHeadFrame:setTouchEnabled(false)
        self.IconTable[i].iconZhiye = TFDirector:getChildByPath(uiNode, "img_zhiye")

        self.qiheIcon[i] = {}
        self.qiheIcon[i].bg = TFDirector:getChildByPath(uiNode, "bg_lv")
        -- for j=1,5 do
        --     self.qiheIcon[i].star = {}
        --     self.qiheIcon[i].star[j] = TFDirector:getChildByPath(uiNode, "icon_lv"..j)
        -- end

        local resPath = "effect/assistLock.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("assistLock_anim")
        --effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(0, 15))
        effect:setVisible(true)
        effect:playByIndex(0, -1, -1, 1)
        self.IconTable[i].btn:addChild(effect, 100)
        self.IconTable[i].effect = effect

        --关闭换位
        -- self.originalPost[i] = uiNode:getPosition()
    end
    self.friendIcon = TFDirector:getChildByPath(ui, "z7")
    self.friendHeadFrame = TFDirector:getChildByPath(self.friendIcon, "btn_icon")
    self.friendHeadFrame:setTouchEnabled(false)
    self.friendHeadFrame:setVisible(false)
    self.friendHead = TFDirector:getChildByPath(self.friendIcon, "img_touxiang")
    self.friendZhiye = TFDirector:getChildByPath(self.friendIcon, "img_zhiye")
    self.friendBtn = TFDirector:getChildByPath(ui, "btn_hyzz")
    self.qiheBtn = TFDirector:getChildByPath(ui, "btn_qihe")
    self.backBtn = TFDirector:getChildByPath(ui,"btn_close")
    self.helpBtn = TFDirector:getChildByPath(ui,"btn_help")

    self.roleSelect = TFDirector:getChildByPath(ui, "role_select")
    self.otherRoleLayer = require("lua.logic.assistFight.AssistFightOtherRoleLayer"):new(self.ui)
    self.roleSelectBg = TFDirector:getChildByPath(ui, "role_select")

    self.bg_haoyouName = TFDirector:getChildByPath(ui, "bg_haoyouName")
    self.bg_haoyouName:setVisible(false)

    local bgSize = TFDirector:getChildByPath(ui, "bg_zhenrong")
    self.zhenrongBgSize = bgSize:getContentSize()
    self.unLockData = require('lua.table.t_s_assistant_rule')


    self.panel_fate = TFDirector:getChildByPath(ui,"Panel_yuanfen")


    local qiheNode = TFDirector:getChildByPath(ui,"bg_qihe")
    self.txtQiheTips = TFDirector:getChildByPath(qiheNode,"txt_tips")
     --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(qiheNode,"panel_table")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.icon_xiala = TFDirector:getChildByPath(ui, 'icon_xiala')


    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.ZhuZhan.ZhuzhanCell3")
    self.cellModel:retain()   
end

function AssistFightLayer:removeUI()
   	self.super.removeUI(self)

    if self.otherRoleLayer then
        self.otherRoleLayer:removeUI()
        self.otherRoleLayer = nil
    end
    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end
end

function AssistFightLayer:onShow()
    self.super.onShow(self)

    self:refreshWindow()
    self:drawFateTableView()

    self:refreshXialaIcon()
end

function AssistFightLayer:registerEvents()

	if self.registerEventCallFlag then
		return
	end
	self.super.registerEvents(self)

    self.friendIcon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.friendIconClick))
    self.friendIcon.logic = self
    self.friendBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.friendButtonClick))
    self.friendBtn.logic = self
    self.qiheBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.qiheButtonClick))
    self.qiheBtn.logic = self
    self.backBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.backButtonClick))
    self.helpBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.helpButtonClick))

    for i=1,6 do
        self.IconTable[i].btn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconTableBtnClick))
        self.IconTable[i].btn.idx = i
        self.IconTable[i].btn.logic = self        
    end

    self.refreshWindowCallBack = function (event)
        self:refreshWindow()
        if self.gridStateOld then
            self:playunLockAnim()
        end
        self:refreshFateList()
        self:playAssistOnAnim()
    end
    TFDirector:addMEGlobalListener(AssistFightManager.refreshWindow, self.refreshWindowCallBack)

    self.getAssistRoleCallBack = function (event)
        self:refreshFriendIcon()
        self:refreshWindow()        
        self:refreshFateList()
        self:playGetRoleAnim()
        local friendName = event.data[1][1]
        local roleName = event.data[1][2]
        print('event.data= ',event.data)
        if friendName and roleName then
            -- local str = TFLanguageManager:getString(ErrorCodeData.Assist_Somebody_Assist_You)
            -- str = string.format(str, friendName, roleName)
            local str = stringUtils.format(localizable.Assist_Somebody_Assist_You, friendName, roleName)
            toastMessage(str)
        end
    end
    TFDirector:addMEGlobalListener(AssistFightManager.GETASSISTROLESUCCESS, self.getAssistRoleCallBack)

    self.FriendAssistCallBack = function (event)
        -- local layer = AlertManager:addLayerByFile("lua.logic.assistFight.FriendRoleListLayer", AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
        -- layer:initDate(self.LineUpType)
        -- AlertManager:show()
    end
    TFDirector:addMEGlobalListener(AssistFightManager.FRIENDASSISTLIST, self.FriendAssistCallBack)

    self.otherRoleLayer:registerEvents()
    self.roleSelectBg:setVisible(false)

    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.TabView:addMEListener(TFTABLEVIEW_SCROLL, self.tableScroll)

	
   	self.registerEventCallFlag = true
end

function AssistFightLayer:removeEvents()

    self.friendIcon:removeMEListener(TFWIDGET_CLICK)
    self.friendBtn:removeMEListener(TFWIDGET_CLICK)
    self.qiheBtn:removeMEListener(TFWIDGET_CLICK)

    if self.otherRoleLayer then
        self.otherRoleLayer:removeEvents()
    end

    for i=1,6 do
        self.IconTable[i].btn:removeMEListener(TFWIDGET_CLICK)
    end

    TFDirector:removeMEGlobalListener(AssistFightManager.refreshWindow, self.refreshWindowCallBack)
    self.refreshWindowCallBack = nil
    TFDirector:removeMEGlobalListener(AssistFightManager.GETASSISTROLESUCCESS, self.getAssistRoleCallBack)
    self.getAssistRoleCallBack = nil
    TFDirector:removeMEGlobalListener(AssistFightManager.FRIENDASSISTLIST, self.FriendAssistCallBack)
    self.FriendAssistCallBack = nil
    
    if self.currAssistOnAnim then
        self.currAssistOnAnim:removeMEListener(TFARMATURE_COMPLETE) 
        self.currAssistOnAnim:removeFromParent()
        self.assistOnOld = nil  
        self.currAssistOnAnim = nil      
    end
    
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    self.TabView:removeMEListener(TFTABLEVIEW_SCROLL)

    self.super.removeEvents(self)
    self.registerEventCallFlag = nil
end

function AssistFightLayer:dispose()
    self.super.dispose(self)
end

function AssistFightLayer:refreshWindow()
    self:refreshGridInfo()
    self:showQiheStar()
end

function AssistFightLayer:refreshFateList()
    local roleList = AssistFightManager:getAssistRoleList(self.LineUpType)

    -- print("roleList = ", roleList)
    local assistlist = {}
    assistlist = FateManager:LinkStrategyAndAssit(AssistFightManager:getStrategyList(self.LineUpType), roleList,self.LineUpType)

    FateManager:updateFateWithChange(self.roleFateMap, assistlist)
    -- 获取缘分列表
    self.fateList = FateManager:getFateList(self.roleFateMap)
    self:drawFateTableView()
end

function AssistFightLayer.friendIconClick(btn)
    local self = btn.logic
    for i=1,#AssistFightManager.CloseFriendType do
        if self.LineUpType == AssistFightManager.CloseFriendType[i] then
            toastMessage(localizable.assistFightLayer_friend)
            return
        end
    end
    --self.friendRoleListLayer:setLineUpType( self.LineUpType, btn.idx, self )
    if self.currAssistOnAnim then
        self.currAssistOnAnim:removeMEListener(TFARMATURE_COMPLETE) 
        self.currAssistOnAnim:removeFromParent()
        self.assistOnOld = nil  
        self.currAssistOnAnim = nil      
    end
    local info = AssistFightManager:getFriendIconInfo()
    if info.friendRoleId ~= 0 then
        AssistFightManager:requestGetAssitRole( 0, 0, AssistFightManager.GETASSISTROLESUCCESS )
        return
    else
        local layer = AlertManager:addLayerByFile("lua.logic.assistFight.FriendRoleListLayer", AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
        layer:initDate(self.LineUpType)
        AlertManager:show()
    end
end

function AssistFightLayer.friendButtonClick(btn)
    -- toastMessage("即将开放,敬请期待!")
    local self = btn.logic

    for i=1,#AssistFightManager.CloseFriendType do
        if self.LineUpType == AssistFightManager.CloseFriendType[i] then
            toastMessage(localizable.assistFightLayer_friend)
            return
        end
    end

    local layer = AlertManager:addLayerByFile("lua.logic.assistFight.ZhuzhanFriendLayer", AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    -- print('self.LineUpType = ',self.LineUpType)
    -- -- pp.pp = 1
    layer:setLineUpType(self.LineUpType)
    AlertManager:show()
end

function AssistFightLayer.qiheButtonClick(btn)
    local self = btn.logic
    local openLevel = FunctionOpenConfigure:getOpenLevel(1204) or 50

    if MainPlayer:getLevel() < openLevel then
        toastMessage(stringUtils.format(localizable.common_openlevel_text1,openLevel))
        return
    end
    local layer = AlertManager:addLayerByFile("lua.logic.assistFight.AssistAgreeLayer", AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    layer:loadData(self.LineUpType)
    AlertManager:show()
end

function AssistFightLayer.helpButtonClick(btn)
    -- local layer = AlertManager:addLayerByFile("lua.logic.assistFight.AssistFightRuleLayer", AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    -- AlertManager:show()
    CommonManager:showRuleLyaer( 'zhuzhan' )
end

function AssistFightLayer.backButtonClick(btn)
    AlertManager:close()
end

function AssistFightLayer.iconTableBtnClick(btn)
    local self = btn.logic
    local gridState = AssistFightManager:getGridList()
    local unLockState = self.unLockData:getObjectAt(btn.idx)
    local roleList = AssistFightManager:getAssistRoleList( self.LineUpType )

    print("gridState[btn.idx] = ",gridState[btn.idx])
    print("roleList[btn.idx] = ",roleList[btn.idx])
    if self.currAssistOnAnim then
        self.currAssistOnAnim:removeMEListener(TFARMATURE_COMPLETE) 
        self.currAssistOnAnim:removeFromParent()
        self.assistOnOld = nil  
        self.currAssistOnAnim = nil      
    end
    if gridState and gridState[btn.idx] then
        if roleList[btn.idx] and roleList[btn.idx] > 0 then            
            AssistFightManager:requestUpdateRole(self.LineUpType, btn.idx, 0)
        else
            self.otherRoleLayer:setLineUpType( self.LineUpType, btn.idx, self )
            self.otherRoleLayer:refreshData()
            self.otherRoleLayer:moveIn()
        end
    else
        if btn.idx == 4 then
            if ClimbManager:getClimbFloorNum() >= unLockState.val then
                self.gridStateOld = {}
                for i=1,#gridState do
                    self.gridStateOld[i] = gridState[i]
                end
                AssistFightManager:requestOpenGrid(btn.idx-1)
            else

                toastMessage(stringUtils.format(localizable.common_climb_openlevel,unLockState.val))
            end
        elseif btn.idx == 5 then
            if MainPlayer:getSycee() < unLockState.val then
                toastMessage(localizable.common_no_yuanbao)
            else
                local msg =  stringUtils.format(localizable.common_use_yuanbao_open,unLockState.val)
                    CommonManager:showOperateSureLayer(
                        function()
                            self.gridStateOld = {}
                            for i=1,#gridState do
                                self.gridStateOld[i] = gridState[i]
                            end
                            AssistFightManager:requestOpenGrid(btn.idx-1)
                        end,
                        function()
                            AlertManager:close()
                        end,
                        {
                        title = localizable.common_tips ,
                        msg = msg,
                        --uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                    )
            end
        elseif btn.idx == 6 then
            if MainPlayer:getVipLevel() >= unLockState.val then
                self.gridStateOld = {}
                for i=1,#gridState do
                    self.gridStateOld[i] = gridState[i]
                end
                AssistFightManager:requestOpenGrid(btn.idx-1)
            else
                toastMessage(stringUtils.format(localizable.assistFightLayer_vip_unlock,unLockState.val))
            end
        elseif MainPlayer:getLevel() >= unLockState.val then
            --open grid
            self.gridStateOld = {}
            for i=1,#gridState do
                self.gridStateOld[i] = gridState[i]
            end
            AssistFightManager:requestOpenGrid(btn.idx-1)
        else
            --toastMessage(localizable.common_team_level..unLockState.val..localizable.common_unlock)
            toastMessage(stringUtils.format(localizable.common_team_unlock,unLockState.val))
        end
    end   
    
end

function AssistFightLayer:refreshGridInfo()
    local gridState = nil
    local roleList = AssistFightManager:getAssistRoleList( self.LineUpType )
     
    if self.gridStateOld then
        gridState = self.gridStateOld
    else
        gridState = AssistFightManager:getGridList()
    end
     
    

    local gridIdx = 1
    for k,v in pairs(gridState) do
        --print("k = ",k)
        --print("v = ",v)
        self.IconTable[k].iconAdd:setVisible(v)
        self.IconTable[k].iconHeadFrame:setVisible(v)
        self.IconTable[k].iconLock:setVisible(not v)
        self.IconTable[k].iconLimit:setVisible(not v)
        self.IconTable[k].effect:setVisible(false)
        if v then
            -- self.IconTable[k].btn:setPosition(self.originalPost[gridIdx])
            gridIdx = gridIdx + 1
            --print("roleList[k] = ",roleList[k])
            if roleList[k] and roleList[k] > 0 then
                local cardRole = CardRoleManager:getRoleByGmid( roleList[k] )
                if cardRole then
                    self.IconTable[k].iconHeadFrame:setTextureNormal(GetColorRoadIconByQuality(cardRole.quality))
                    self.IconTable[k].iconHead:setTexture(cardRole:getHeadPath())
                    self.IconTable[k].iconZhiye:setTexture("ui_new/fight/zhiye_".. cardRole.outline ..".png")
                else
                    self.IconTable[k].iconHeadFrame:setVisible(false)
                end
            else
                self.IconTable[k].iconHeadFrame:setVisible(false)
            end
        else
            local unLockState = self.unLockData:getObjectAt(k)
            --print("unLockState = ",unLockState)
            if k == 4 then
                --self.IconTable[k].iconLimit:setText("无量山"..unLockState.val.."层")
                self.IconTable[k].iconLimit:setText(stringUtils.format(localizable.assistFightLayer_clibmLevel, unLockState.val))
                if ClimbManager:getClimbFloorNum() >= unLockState.val then
                    self.IconTable[k].effect:setVisible(true)
                    self.IconTable[k].iconLock:setVisible(false)
                end
            elseif k == 5 then
                self.IconTable[k].iconLimit:setText(unLockState.val)
                -- if MainPlayer:getSycee() >= unLockState.val then
                    -- self.IconTable[k].effect:setVisible(true)
                    -- self.IconTable[k].iconLock:setVisible(false)
                -- end
            elseif k == 6 then
                --self.IconTable[k].iconLimit:setText("VIP"..unLockState.val.."解锁")
                self.IconTable[k].iconLimit:setText(stringUtils.format(localizable.assistFightLayer_vip_unlock,unLockState.val))
                if MainPlayer:getVipLevel() >= unLockState.val then
                    self.IconTable[k].effect:setVisible(true)
                    self.IconTable[k].iconLock:setVisible(false)
                end
            else
                self.IconTable[k].iconLimit:setText(stringUtils.format(localizable.common_level_unlock,unLockState.val))
                --self.IconTable[k].iconLimit:setText(unLockState.val.."级解锁")
                if MainPlayer:getLevel() >= unLockState.val then
                    self.IconTable[k].effect:setVisible(true)
                    self.IconTable[k].iconLock:setVisible(false)
                end
            end
        end        
    end  
    self:refreshFriendIcon()

    for k,v in pairs(gridState) do
        if v == false then            
            -- self.IconTable[k].btn:setPosition(self.originalPost[gridIdx])
            gridIdx = gridIdx + 1
        end
    end    
end

function AssistFightLayer:refreshFriendIcon()
    for i=1,#AssistFightManager.CloseFriendType do
        if self.LineUpType == AssistFightManager.CloseFriendType[i] then
            self.friendHeadFrame:setVisible(false)
            return
        end
    end

    local info = AssistFightManager:getFriendIconInfo()
    local cardRole = RoleData:objectByID(info.friendRoleId)
    if cardRole then
        self.friendHeadFrame:setVisible(true)
        self.friendHeadFrame:setTextureNormal(GetColorRoadIconByQuality(cardRole.quality))
        self.friendHead:setTexture(cardRole:getHeadPath())
        self.friendZhiye:setTexture("ui_new/fight/zhiye_".. cardRole.outline ..".png")
    else
        self.friendHeadFrame:setVisible(false)
    end
end
function AssistFightLayer:setLineUpType( Type )
    self.LineUpType = Type
    -- if self.otherRoleLayer then
    --     self.otherRoleLayer:setLineUpType( Type )
    -- end
    AssistFightManager:requestFriendAssistList()
end

function AssistFightLayer:drawFateTableView()
    if self.fateTableView ~= nil then
        self.fateTableView:reloadData()
        -- self.fateTableView:setScrollToBegin(false)
        self.fateTableView:setVisible(true)
        return
    end

    local  fateTableView =  TFTableView:create()
    fateTableView:setTableViewSize(self.panel_fate:getContentSize())
    fateTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    fateTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    fateTableView:setPosition(self.panel_fate:getPosition())
    self.fateTableView = fateTableView
    self.fateTableView.logic = self

    fateTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable_fate)
    fateTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex_fate)
    fateTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView_fate)
    fateTableView:reloadData()

    self.panel_fate:getParent():addChild(self.fateTableView,1)
end

function AssistFightLayer.numberOfCellsInTableView_fate(table)
    local self = table.logic

    return self.fateList:length()
end

function AssistFightLayer.cellSizeForTable_fate(table,idx)
    -- return 109, 416
    local self = table.logic

    local index = idx + 1
    local fateRoleNode = self.fateList:objectAt(index)

    if fateRoleNode.type == 1 then --1为角色 2为缘分id
        return 76, 430
    else
        return 109, 430
    end
end

function AssistFightLayer.tableCellAtIndex_fate(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = createUIByLuaNew("lua.uiconfig_mango_new.ZhuZhan.ZhuzhanCell2")

        node:setPosition(ccp(10, -5))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawFateCell(node)
    node:setVisible(true)
    return cell
end

function AssistFightLayer:drawFateCell(node)
    local panel_role    = TFDirector:getChildByPath(node, 'panel_role')
    local img_bg1       = TFDirector:getChildByPath(node, 'bg1')
    local img_bg2       = TFDirector:getChildByPath(node, 'bg2')
    local txt_FightName     = TFDirector:getChildByPath(node, 'txt_name')
    local txt_battletime    = TFDirector:getChildByPath(node, 'txt_battletime')
    local btn_share         = TFDirector:getChildByPath(node, 'btn_fenxiang')
    local btn_guanzhan      = TFDirector:getChildByPath(node, 'btn_guanzhan')
    local icon_up           = TFDirector:getChildByPath(node, 'icon_up')

    local fateDataNode = self.fateList:objectAt(node.index)

    if fateDataNode.type == 1 then --1为角色 2为缘分id
        img_bg1:setVisible(false)
        img_bg2:setVisible(false)
        panel_role:setVisible(true)
        local rolebg    =  TFDirector:getChildByPath(node, 'rolebg')
        local roleicon  =  TFDirector:getChildByPath(node, 'roleicon')

        local roleItem          = RoleData:objectByID(fateDataNode.id)
        if fateDataNode.id == MainPlayer:getProfession() then
            local cardRole = CardRoleManager:getRoleById(fateDataNode.id)
            rolebg:setTexture(GetColorIconByQuality(cardRole.quality));
        else
            rolebg:setTexture(GetColorIconByQuality(roleItem.quality));
        end
        roleicon:setTexture(roleItem:getIconPath());
    else
        -- img_bg1:setVisible(true) --激活
        -- img_bg2:setVisible(true)

        panel_role:setVisible(false)
        img_bg1:setVisible(fateDataNode.match)
        img_bg2:setVisible(not fateDataNode.match)

        local fate = RoleFateData:objectByID(fateDataNode.id)

        local title1   = TFDirector:getChildByPath(img_bg1, 'txt_name')
        local details1 = TFDirector:getChildByPath(img_bg1, 'txt_yuanfen')

        local title2   = TFDirector:getChildByPath(img_bg2, 'txt_name')
        local details2 = TFDirector:getChildByPath(img_bg2, 'txt_yuanfen')

        title1:setText(fate.title)
        details1:setText(fate.details)
        title2:setText(fate.title)
        details2:setText(fate.details)
    end

end

function AssistFightLayer:playunLockAnim()
    print("self.gridStateOld = ",self.gridStateOld)
    if self.gridStateOld == nil then
        return
    end
    local nodeIdx = nil
    local gridStateNew = AssistFightManager:getGridList()
    for k,v in pairs(self.gridStateOld) do
        if gridStateNew[k] ~= v then
            nodeIdx = k
        end
    end
    print("gridStateNew = ",gridStateNew)
    print("nodeIdx = ",nodeIdx)
    if nodeIdx then
        self.IconTable[nodeIdx].effect:setVisible(false)
        self.IconTable[nodeIdx].iconLock:setVisible(false)
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/assistLock.xml")
        local effect = TFArmature:create("assistLock_anim")
        effect:playByIndex(1, -1, -1, 0)
        effect:setVisible(true)
        effect:setZOrder(1)
        self.IconTable[nodeIdx].effect:getParent():addChild(effect)
        effect:setPosition(self.IconTable[nodeIdx].effect:getPosition())
        self.IconTable[nodeIdx].effect:setVisible(false)
        effect:addMEListener(TFARMATURE_COMPLETE, function ()
            effect:removeMEListener(TFARMATURE_COMPLETE) 
            effect:removeFromParent()
            effect:setVisible(false)
            self.gridStateOld = nil
            self:refreshGridInfo()
        end)
    end
end

function AssistFightLayer:setAssistOn()
    print("setAssistOn")
    local roleList = AssistFightManager:getAssistRoleList( self.LineUpType )
    self.assistOnOld = {}
    for i=1,#roleList do
        self.assistOnOld[i] = roleList[i]
    end
end
function AssistFightLayer:playAssistOnAnim()
    if self.assistOnOld == nil then
        return
    end
    local nodeIdx = nil
    local roleList = AssistFightManager:getAssistRoleList( self.LineUpType )
    for k,v in pairs(self.assistOnOld) do
        if roleList[k] ~= v then
            nodeIdx = k
        end
    end
    if nodeIdx then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/assistOpen.xml")
        local effect = TFArmature:create("assistOpen_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:playByIndex(0, -1, -1, 0)
        effect:setVisible(true)
        -- effect:setZOrder(100)
        self.currAssistOnAnim = effect
        self.IconTable[nodeIdx].btn:getParent():addChild(effect,100)
        local x = self.IconTable[nodeIdx].btn:getPosition().x + self.zhenrongBgSize.width/2
        local y = self.IconTable[nodeIdx].btn:getPosition().y + self.zhenrongBgSize.height/2
        effect:setPosition(ccp(x,y))
        effect:addMEListener(TFARMATURE_COMPLETE, function ()
            effect:removeMEListener(TFARMATURE_COMPLETE) 
            effect:removeFromParent()
            self.assistOnOld = nil
            self.currAssistOnAnim = nil
        end)
    end
end

function AssistFightLayer:playGetRoleAnim()
    local info = AssistFightManager:getFriendIconInfo()
    if info.friendRoleId and info.friendRoleId ~= 0 then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/assistOpen.xml")
        local effect = TFArmature:create("assistOpen_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:playByIndex(0, -1, -1, 0)
        effect:setVisible(true)
        self.currAssistOnAnim = effect
        self.friendIcon:addChild(effect,100)        
        effect:addMEListener(TFARMATURE_COMPLETE, function ()
            effect:removeMEListener(TFARMATURE_COMPLETE) 
            effect:removeFromParent()
            self.currAssistOnAnim = nil
        end)
    end
    
end

function AssistFightLayer:showQiheStar()
   
    if MainPlayer:getLevel() < 50 then
        for i=1,6 do
            self.qiheIcon[i].bg:setVisible(false)
        end
        self.txtQiheTips:setVisible(true)
        self.TabViewUI:setVisible(false)
    else
        self:showQiheDetailList()
        local gridList = AssistFightManager:getGridList()
        local levelTbl = AssistFightManager:getQiheLevelInfo()
        for i=1,6 do
            if gridList[i] then
                self.qiheIcon[i].bg:setVisible(true)
                local level = levelTbl[i]
                for j=1,5 do
                    local uiNode = self.qiheIcon[i].bg
                    local starIcon = TFDirector:getChildByPath(uiNode, "icon_lv"..j)
                    if level < j then
                        starIcon:setVisible(false)
                    else
                        starIcon:setVisible(true)
                    end
                end
            else
                self.qiheIcon[i].bg:setVisible(false)
            end
        end
    end
end

function AssistFightLayer:showQiheDetailList()
    self.TabViewUI:setVisible(true)
    self.txtQiheTips:setVisible(false)

    local attrList = AssistFightManager:getQihePreviewInfo(self.LineUpType)
    self.attrTbl = {}
    for idx,val in pairs(attrList) do
        local len = #self.attrTbl + 1
        self.attrTbl[len] = {}
        self.attrTbl[len].idx = tonumber(idx)
        self.attrTbl[len].val = tonumber(val)
        if self.attrTbl[len].idx >= 18 then
            self.attrTbl[len].val = self.attrTbl[len].val/100
        end        
    end

    self.TabView:reloadData()
end


function AssistFightLayer.cellSizeForTable(table,idx)
    return 28,276
end

function AssistFightLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local len = #self.attrTbl
    return math.ceil(len/2)
end

function AssistFightLayer.tableCellAtIndex(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()

    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()

        panel = self.cellModel:clone()
        panel:setPosition(ccp(0,0))
        cell:addChild(panel)
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end


    idx = idx + 1

    local attr1 = TFDirector:getChildByPath(panel, "attr1")
    local item1 = self.attrTbl[idx*2 - 1]
    if item1.idx >= 18 then
        attr1:setText(AttributeTypeStr[item1.idx]..':'..item1.val..'%')
    else
        attr1:setText(AttributeTypeStr[item1.idx]..':'..item1.val)
    end

    local attr2 = TFDirector:getChildByPath(panel, "attr2")
    local item2 = self.attrTbl[idx*2]
    -- print('item2 = ',item2)
    if item2 then
        attr2:setVisible(true)
        if item2.idx >= 18 then
            attr2:setText(AttributeTypeStr[item2.idx]..':'..item2.val..'%')
        else
            attr2:setText(AttributeTypeStr[item2.idx]..':'..item2.val)
        end
    else
        attr2:setVisible(false)
    end

    return cell
end

function AssistFightLayer:refreshXialaIcon()
    if self.TabView then
        local len = #self.attrTbl
        len = math.ceil(len/2)
        if len > 3 then
            local offsetMax = self.TabViewUI:getContentSize().height-28*len
            local currPosition = self.TabView:getContentOffset()
            
            if currPosition.y < 0 and offsetMax >= currPosition.y then
                self.icon_xiala:setVisible(true)
            else
                self.icon_xiala:setVisible(false)
            end
        else
            self.icon_xiala:setVisible(false)
        end
    end
end

function AssistFightLayer.tableScroll( table )
    local self = table.logic
    self:refreshXialaIcon()
end
return AssistFightLayer
