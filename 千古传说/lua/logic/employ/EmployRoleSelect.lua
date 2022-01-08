

local EmployRoleSelect = class("EmployRoleSelect",BaseLayer)

local columnNumber = 4

function EmployRoleSelect:ctor(data)

	self.super.ctor(self, data)
	self.isFirst = true
	self:init("lua.uiconfig_mango_new.yongbing.EmployRoleSelect")
end

function EmployRoleSelect:initUI( ui )

	self.super.initUI(self, ui)
    self.panel_cardregional = TFDirector:getChildByPath(ui, 'panel_huadong')


    self.panel_choice = TFDirector:getChildByPath(ui, 'panel_choice')

    self.btn_choice = {}
    for i=1,4 do
        self.btn_choice[i] = TFDirector:getChildByPath(ui, 'btn_choice_'..i)
    end
    self.btn_listType = TFDirector:getChildByPath(ui, 'btn_listType')
    self.img_listType = TFDirector:getChildByPath(ui, 'img_listType')

    self.filterType = 0

    self.panel_choice:setVisible(false)

	self.cellModel = createUIByLuaNew("lua.uiconfig_mango_new.role.ArmyRoleItem")
    self.cellModel:setScale(0.9)
    self.cellModel:retain()

    self.normalTextureBlack = {"ui_new/yongbing/btn_quanbu1.png","ui_new/yongbing/btn_gongji1.png","ui_new/yongbing/btn_fangyu1.png","ui_new/yongbing/btn_zhiliao1.png","ui_new/yongbing/btn_kongzhi1.png"}
    self.normalTexture = {"ui_new/yongbing/btn_quanbu.png","ui_new/yongbing/btn_gongji.png","ui_new/yongbing/btn_fangyu.png","ui_new/yongbing/btn_zhiliao.png","ui_new/yongbing/btn_kongzhi.png"}
end


function EmployRoleSelect:initDate( role_list, clickCallBack)
	self.allRoleList = role_list
	self.clickCallBack = clickCallBack

    self:freshUI()
end

function EmployRoleSelect:initDateByFilter( role_list, filter_list,clickCallBack)
    self.allRoleList = self.allRoleList or TFArray:new()
    self.allRoleList:clear()

    for v in role_list:iterator() do
        if filter_list:indexOf(v) == -1 then
            self.allRoleList:pushBack(v)
        end
    end
    self.clickCallBack = clickCallBack

    self:freshUI()
end

function EmployRoleSelect:freshUI()
    self.roleList = self.roleList or TFArray:new()
    self.roleList:clear()

    for v in self.allRoleList:iterator() do
        if self.filterType == 0 or v.outline == self.filterType then
            self.roleList:pushBack(v)
        end
    end

    if self.tableView == nil then
        self:creatTableView()
    end
    self.tableView:reloadData()

    local temp = 1
    for i=0,4 do
        if i ~= self.filterType then
            self.btn_choice[temp]:setTextureNormal(self.normalTexture[i+1])
            -- self.btn_choice[temp]:setPressedTexture(self.normalTexture[i+1])
            temp = temp + 1
        else
            self.img_listType:setTexture(self.normalTextureBlack[i+1])
        end
    end
end


function EmployRoleSelect:creatTableView()
	local  tableView =  TFTableView:create()
    -- tableView:setName("btnTableView")
    tableView:setTableViewSize(self.panel_cardregional:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    tableView:setPosition(self.panel_cardregional:getPosition())
    self.tableView = tableView
     
    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, EmployRoleSelect.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, EmployRoleSelect.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, EmployRoleSelect.numberOfCellsInTableView)


    self.panel_cardregional:getParent():addChild(self.tableView,1)
end


function EmployRoleSelect.cellSizeForTable(table,cell)
	return 173,600
end

function EmployRoleSelect.tableCellAtIndex(table,idx)
	local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1
        self.allPanels[newIndex] = cell

        for i=1,columnNumber do
            local panel = self.cellModel:clone()
            panel:setPosition(ccp(30 + 160 * (i - 1) ,0))
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



function EmployRoleSelect:cellInfoSet( panel, idx )

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

    local roleItem = self.roleList:objectAt(idx);
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
        -- --print("roleItem = ",roleItem.fateid)
        -- if roleItem.fateid ~= 0 then
        --     panel.img_fate:setVisible(true)
        -- else
        panel.img_fate:setVisible(false)
        -- end

        panel.txt_lv_word:setText(roleItem.level)
    else
        panel.panelEmpty:setVisible(true)
        panel.panelInfo:setVisible(false)
    end
end

function EmployRoleSelect.numberOfCellsInTableView(table,cell)
    local self = table.logic
	if self.roleList == nil then
		return 0
	end
	return math.ceil(self.roleList:length()/columnNumber)
end


function EmployRoleSelect.cellButtonClick( btn )
    local self = btn.logic

    CommonManager:showOperateSureLayer(function()
            self.clickCallBack(self.roleList:objectAt(btn.idx))
        end,
        function()
            AlertManager:close()
        end,
        {
        showtype = AlertManager.BLOCK_AND_GRAY,
        --title = "提示" ,
        title = localizable.common_tips ,
        --msg = "派遣的角色至少需要30分钟，确定派遣角色",
        msg = localizable.common_tips_zhuzhan_text2,
        }
    )

    
end

function EmployRoleSelect:removeUI()
	self.super.removeUI(self)

end

function EmployRoleSelect:onShow()
    self.super.onShow(self)

end


function EmployRoleSelect:registerEvents()
	self.super.registerEvents(self)

    self.panel_choice.logic = self
    self.panel_choice:addMEListener(TFWIDGET_CLICK, audioClickfun(self.choiceLayerClick))

    for i=1,4 do
        self.btn_choice[i].logic = self
        self.btn_choice[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.choiceButtonClick))
        self.btn_choice[i]:setTag(i)
    end
    self.btn_listType.logic = self
    self.btn_listType:addMEListener(TFWIDGET_CLICK, audioClickfun(self.buttonListTypeClick))

end

function EmployRoleSelect.choiceLayerClick(sender)
    local self = sender.logic
    self.panel_choice:setVisible(false)
end

function EmployRoleSelect.choiceButtonClick(sender)
    local self = sender.logic
    local index = sender:getTag()
    local temp = 0
    for i=0,4 do
        if i ~= self.filterType then
            temp = temp + 1
        end
        if temp == index then
            self.filterType = i
            self.panel_choice:setVisible(false)
            self:freshUI()
            return
        end
    end
end

function EmployRoleSelect.buttonListTypeClick(sender)
    local self = sender.logic
    self.panel_choice:setVisible(true)
end

function EmployRoleSelect:removeEvents()
    self.super.removeEvents(self)
end

function EmployRoleSelect:dispose()
	self.super.dispose(self)
end


return EmployRoleSelect