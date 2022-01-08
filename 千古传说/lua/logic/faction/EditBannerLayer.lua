--[[
******帮派-旗帜*******

	-- by quanhuan
	-- 2016/1/19
	
]]

local EditBannerLayer = class("EditBannerLayer",BaseLayer)

local ChoseInfo = {}
local OldInfo = {}

local cellBgW = 252
local cellBgH = 243
local cellBgMax = 5
local cellIconW = 145
local cellIconH = 155
local cellIconMax = 7
function EditBannerLayer:ctor(data)

    ChoseInfo.stepIndex = 1
    ChoseInfo.bannerBg = 1
    ChoseInfo.bannerBgColor = 1
    ChoseInfo.bannerIcon = 1
    ChoseInfo.bannerIconColor = 1

    self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionChooseFlag")
end

function EditBannerLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.stepBtnChose1 = TFDirector:getChildByPath(ui, "btn_qizhi1")
    self.stepBtnChose2 = TFDirector:getChildByPath(ui, "btn_qizhi2")
    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_suiji = TFDirector:getChildByPath(ui, "btn_suiji")
    self.btn_next = TFDirector:getChildByPath(ui, "btn_next")
    self.btn_save = TFDirector:getChildByPath(ui, "btn_save")
    self.btn_huanyuan = TFDirector:getChildByPath(ui, "btn_huanyuan")
    self.bg_qizhi = TFDirector:getChildByPath(ui, "bg_qizhi")
    self.img_qi = TFDirector:getChildByPath(self.bg_qizhi, "img_qi")

    local qzColorName = {'btn_bai','btn_hei','btn_huang','btn_fen','btn_lan','btn_hong'}
    local qzColorNode = TFDirector:getChildByPath(ui, 'panel_qz')
    self.qzColorBtn = {}
    for i=1,6 do
        self.qzColorBtn[i] = TFDirector:getChildByPath(qzColorNode, qzColorName[i])
        self.qzColorBtn[i].logic = self
        self.qzColorBtn[i].idx = i
    end
    self.qzColorXuanzhong = TFDirector:getChildByPath(qzColorNode, 'img_xuanzhong')
    self.qzColorXuanzhong:setVisible(false)
    self.qzColorNode = TFDirector:getChildByPath(ui, 'panel_qz')

    local tuanColorName = {'btn_bai','btn_jin','btn_huang','btn_fen','btn_lan','btn_hong'}
    local tuanColorNode = TFDirector:getChildByPath(ui, 'panel_tuan')
    self.tuanColorBtn = {}
    for i=1,6 do
        self.tuanColorBtn[i] = TFDirector:getChildByPath(tuanColorNode, tuanColorName[i])
        self.tuanColorBtn[i].logic = self
        self.tuanColorBtn[i].idx = i
    end
    self.tuanColorXuanzhong = TFDirector:getChildByPath(tuanColorNode, 'img_xuanzhong')
    self.tuanColorXuanzhong:setVisible(false)
    self.tuanColorNode = TFDirector:getChildByPath(ui, 'panel_tuan')

    self.LabelBMFont_yb = TFDirector:getChildByPath(ui, 'LabelBMFont_yb')
    self.txt_YbRed = TFDirector:getChildByPath(ui, 'txt_YbRed')
    self.txt_tips = TFDirector:getChildByPath(ui, 'txt_tips')

    self.img_newprice_bg = TFDirector:getChildByPath(ui, 'img_newprice_bg')

    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "panel_slide")
    self.TabViewBg =  TFTableView:create()
    self.TabViewBg:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabViewBg:setDirection(TFTableView.TFSCROLLHORIZONTAL)    
    self.TabViewBg:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabViewBg.logic = self
    self.TabViewUI:addChild(self.TabViewBg)
    self.TabViewBg:setPosition(ccp(0,0))

    self.TabViewIcon =  TFTableView:create()
    self.TabViewIcon:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabViewIcon:setDirection(TFTableView.TFSCROLLHORIZONTAL)    
    self.TabViewIcon:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabViewIcon.logic = self
    self.TabViewUI:addChild(self.TabViewIcon)
    self.TabViewIcon:setPosition(ccp(0,0))

    self.cellModelBg  = createUIByLuaNew("lua.uiconfig_mango_new.faction.FactionChooseFlagCell1")
    self.cellModelBg:retain()
    self.cellModelIcon  = createUIByLuaNew("lua.uiconfig_mango_new.faction.FactionChooseFlagCell2")
    self.cellModelIcon:retain() 

    self:showTipsOrYb()
end


function EditBannerLayer:removeUI()
	self.super.removeUI(self)
    if self.cellModelBg then
        self.cellModelBg:release()
        self.cellModelBg = nil
    end
    if self.cellModelIcon then
        self.cellModelIcon:release()
        self.cellModelIcon = nil
    end
end

function EditBannerLayer:onShow()
    self.super.onShow(self)

    self:refreshLeftDetails()
    self:refreshRightDetails()
end

function EditBannerLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)

    self.stepBtnChose1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onStepBtnClick))
    self.stepBtnChose1.logic = self
    self.stepBtnChose1.idx = 1
    self.stepBtnChose2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onStepBtnClick))
    self.stepBtnChose2.logic = self
    self.stepBtnChose2.idx = 2
    
    self.btn_suiji:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSuijiBtnClick))
    self.btn_suiji.logic = self
    self.btn_next:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onNextBtnClick))
    self.btn_next.logic = self
    self.btn_save:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSaveBtnClick))
    self.btn_save.logic = self
    self.btn_huanyuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHuanyuanBtnClick))
    self.btn_huanyuan.logic = self

    --注册TabView事件
    self.TabViewBg:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTableBg)
    self.TabViewBg:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableViewBg)
    self.TabViewBg:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndexBg)

    self.TabViewIcon:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTableIcon)
    self.TabViewIcon:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableViewIcon)
    self.TabViewIcon:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndexIcon)

    for i=1,6 do
        self.qzColorBtn[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBannerBgColorClick))
        self.tuanColorBtn[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBannerIconColorClick))
    end

    self.registerEventCallFlag = true 
end

function EditBannerLayer:removeEvents()

    self.super.removeEvents(self)

    self.stepBtnChose1:removeMEListener(TFWIDGET_CLICK)
    self.stepBtnChose2:removeMEListener(TFWIDGET_CLICK)
    self.btn_suiji:removeMEListener(TFWIDGET_CLICK)
    self.btn_next:removeMEListener(TFWIDGET_CLICK)
    self.btn_save:removeMEListener(TFWIDGET_CLICK)
    self.btn_huanyuan:removeMEListener(TFWIDGET_CLICK)

    self.TabViewBg:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabViewBg:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabViewBg:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    self.TabViewIcon:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabViewIcon:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabViewIcon:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    self.registerEventCallFlag = nil  
end

function EditBannerLayer:dispose()
	self.super.dispose(self)
end

function EditBannerLayer:refreshRightDetails()
    if ChoseInfo.stepIndex == 1 then
        self.btn_next:setVisible(true)
        self.btn_save:setVisible(false)
        self.stepBtnChose1:setTextureNormal('ui_new/faction/btn_qizhi2.png')
        self.stepBtnChose2:setTextureNormal('ui_new/faction/btn_tuan1.png')
    else
        self.btn_next:setVisible(false)
        self.btn_save:setVisible(true)
        self.stepBtnChose1:setTextureNormal('ui_new/faction/btn_qizhi1.png')
        self.stepBtnChose2:setTextureNormal('ui_new/faction/btn_tuan2.png')
    end

    self.img_newprice_bg:setVisible(false)
    if self.needMessage and ChoseInfo.stepIndex == 2 then
        self.img_newprice_bg:setVisible(true)
    end

    self:showTipsOrYb()
    
    self.bg_qizhi:setTexture(FactionManager:getBannerBgPath(ChoseInfo.bannerBg,ChoseInfo.bannerBgColor))
    self.img_qi:setTexture(FactionManager:getBannerIconPath(ChoseInfo.bannerIcon,ChoseInfo.bannerIconColor))
end

function EditBannerLayer.onStepBtnClick( btn )
    local self = btn.logic
    local idx = btn.idx

    if ChoseInfo.stepIndex == idx then
        return
    end

    ChoseInfo.stepIndex = idx
    self:refreshLeftDetails()
    self:refreshRightDetails()
    self:showTipsOrYb()

    self:resetTableViewPosition(ChoseInfo.stepIndex)
end

function EditBannerLayer:refreshLeftDetails()
    if ChoseInfo.stepIndex == 1 then
        self.qzColorNode:setVisible(true)
        self.tuanColorNode:setVisible(false)
        if self.qzColorFrame then
            self.qzColorFrame:removeFromParent()
            self.qzColorFrame = nil
        end
        self.qzColorFrame = self.qzColorXuanzhong:clone()
        self.qzColorFrame:setPosition(ccp(0,0))
        self.qzColorFrame:setVisible(true)
        local currColorBtn = self.qzColorBtn[ChoseInfo.bannerBgColor]
        currColorBtn:addChild(self.qzColorFrame)
        self.TabViewBg:setVisible(true)
        self.TabViewIcon:setVisible(false)
        self.TabViewBg:reloadData()
    else
        self.qzColorNode:setVisible(false)
        self.tuanColorNode:setVisible(true)
        if self.qzColorFrame then
            self.qzColorFrame:removeFromParent()
            self.qzColorFrame = nil
        end
        self.qzColorFrame = self.tuanColorXuanzhong:clone()
        self.qzColorFrame:setPosition(ccp(0,0))
        self.qzColorFrame:setVisible(true)
        local currColorBtn = self.tuanColorBtn[ChoseInfo.bannerIconColor]
        currColorBtn:addChild(self.qzColorFrame)
        self.TabViewBg:setVisible(false)
        self.TabViewIcon:setVisible(true)
        self.TabViewIcon:reloadData()
    end
end


function EditBannerLayer.cellSizeForTableBg(table,idx)
    return cellBgH,cellBgW
end

function EditBannerLayer.numberOfCellsInTableViewBg(table)
    return cellBgMax
end

function EditBannerLayer.tableCellAtIndexBg(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()

    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModelBg:clone()
        panel:setPosition(ccp(0,-25))
        cell:addChild(panel)

        panel.imgBg = TFDirector:getChildByPath(panel, "bg_qizhi")
        panel.imgXuanzhong = TFDirector:getChildByPath(panel, "img_xuanzhong1")

        panel.imgBg:setTouchEnabled(true)
        panel.imgBg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBannerBgClick))
        panel.imgBg.logic = self
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end

    idx = idx + 1
    panel.imgBg.idx = idx

    local bannerBgPath
    if idx == ChoseInfo.bannerBg then
        bannerBgPath = FactionManager:getBannerBgPath(ChoseInfo.bannerBg,ChoseInfo.bannerBgColor)
        panel.imgXuanzhong:setVisible(true)
    else
        bannerBgPath = FactionManager:getBannerBgPath(idx,7)
        panel.imgXuanzhong:setVisible(false)
    end
    panel.imgBg:setTexture(bannerBgPath)

    return cell
end


function EditBannerLayer.cellSizeForTableIcon(table,idx)
    return cellIconH,cellIconW
end

function EditBannerLayer.numberOfCellsInTableViewIcon(table)
    return cellIconMax
end

function EditBannerLayer.tableCellAtIndexIcon(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()

    local panel = {}
    if cell == nil then
        cell = TFTableViewCell:create()
        for i=1,2 do
            panel[i] = self.cellModelIcon:clone()
            panel[i]:setPosition(ccp(0,-(i-1)*140))
            cell:addChild(panel[i])
            panel[i].imgBg = TFDirector:getChildByPath(panel[i], "img_qi")
            panel[i].imgXuanzhong = TFDirector:getChildByPath(panel[i], "img_xuanzhong1")

            panel[i].imgBg:setTouchEnabled(true)
            panel[i].imgBg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBannerIconClick))
            panel[i].imgBg.logic = self
        end
        cell.panelNode = panel    
    else
        panel = cell.panelNode
    end

    for i=1,2 do
        local index = idx*2 + i
        local bannerIconPath = FactionManager:getBannerIconPath(index,1)
        panel[i].imgBg:setTexture(bannerIconPath)
        panel[i].imgBg.idx = index
        if index == ChoseInfo.bannerIcon then
            panel[i].imgXuanzhong:setVisible(true)
        else
            panel[i].imgXuanzhong:setVisible(false)
        end
    end
    return cell
end

function EditBannerLayer.onBannerBgClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if idx == ChoseInfo.bannerBg then
        return
    end
    ChoseInfo.bannerBg = idx
    self:refreshLeftDetails()
    self:refreshRightDetails()
end

function EditBannerLayer.onBannerIconClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if idx == ChoseInfo.bannerIcon then
        return
    end
    ChoseInfo.bannerIcon = idx
    self:refreshLeftDetails()
    self:refreshRightDetails()
end

function EditBannerLayer.onSuijiBtnClick( btn )

    local self = btn.logic
    local stepIndex = ChoseInfo.stepIndex
    ChoseInfo = FactionManager:getRandomBannerInfo()
    ChoseInfo.stepIndex = stepIndex

    self:refreshLeftDetails()
    self:refreshRightDetails()
    self:resetTableViewPosition(ChoseInfo.stepIndex)
end

function EditBannerLayer.onNextBtnClick(btn)
    local self = btn.logic
    if ChoseInfo.stepIndex >= 2 then
        ChoseInfo.stepIndex = 2
    else
        ChoseInfo.stepIndex = ChoseInfo.stepIndex + 1
    end
    self:refreshLeftDetails()
    self:refreshRightDetails()
end

function EditBannerLayer.onSaveBtnClick( btn )
    local self = btn.logic

    if self.needMessage then
        --send message
        local sycee = ConstantData:objectByID("guild.change.flag").value
        if MainPlayer:getSycee() < sycee then
            --toastMessage("元宝不够")
            toastMessage(localizable.common_no_yuanbao)
            return
        end
        local strMsg = string.format('%d_%d_%d_%d',ChoseInfo.bannerBg,ChoseInfo.bannerBgColor,ChoseInfo.bannerIcon,ChoseInfo.bannerIconColor)
        if (OldInfo.bannerBg ~= ChoseInfo.bannerBg) or (OldInfo.bannerBgColor ~= ChoseInfo.bannerBgColor) or 
            (OldInfo.bannerIcon ~= ChoseInfo.bannerIcon) or (OldInfo.bannerIconColor ~= ChoseInfo.bannerIconColor) then
            FactionManager:requestUpdateBanner(strMsg)
        end
    end
    TFFunction.call(self.clickCallBack,ChoseInfo)
    AlertManager:close()
end

function EditBannerLayer.onHuanyuanBtnClick( btn )
    local self = btn.logic

    ChoseInfo.bannerBg = OldInfo.bannerBg
    ChoseInfo.bannerBgColor = OldInfo.bannerBgColor
    ChoseInfo.bannerIcon = OldInfo.bannerIcon
    ChoseInfo.bannerIconColor = OldInfo.bannerIconColor

    self:refreshLeftDetails()
    self:refreshRightDetails()
end

function EditBannerLayer:setData( bannerInfo,needMessage,clickCallBack)
    self.clickCallBack = clickCallBack
    self.needMessage = needMessage
    bannerInfo = bannerInfo or {}
    OldInfo.bannerBg = bannerInfo.bannerBg or 1
    OldInfo.bannerBgColor = bannerInfo.bannerBgColor or 1
    OldInfo.bannerIcon = bannerInfo.bannerIcon or 1
    OldInfo.bannerIconColor = bannerInfo.bannerIconColor or 1

    ChoseInfo.stepIndex = 1
    ChoseInfo.bannerBg = OldInfo.bannerBg
    ChoseInfo.bannerBgColor = OldInfo.bannerBgColor
    ChoseInfo.bannerIcon = OldInfo.bannerIcon
    ChoseInfo.bannerIconColor = OldInfo.bannerIconColor

    self:refreshLeftDetails()
    self:refreshRightDetails()

    self:resetTableViewPosition(ChoseInfo.stepIndex)
    
end

function EditBannerLayer:showTipsOrYb()

    if self.needMessage ~= true then
        self.img_newprice_bg:setVisible(false)
        self.txt_tips:setVisible(false)
        return
    end

    local sycee = ConstantData:objectByID("guild.change.flag").value
    self.LabelBMFont_yb:setText(sycee)
    self.txt_YbRed:setText(sycee)
    local tool = BagManager:getItemById(30069)
    if tool and tool.num > 0 then
        self.txt_tips:setVisible(true)
        -- local str = TFLanguageManager:getString(ErrorCodeData.Guild_UI)
        -- str = string.format(str, tool.num)        
        local str = stringUtils.format(localizable.Guild_UI, tool.num)
        
        self.txt_tips:setText(str)
        self.img_newprice_bg:setVisible(false)
        self.txt_YbRed:setVisible(false)
        self.LabelBMFont_yb:setVisible(false)
    elseif MainPlayer:getSycee() < sycee then
        self.img_newprice_bg:setVisible(true)
        self.txt_tips:setVisible(false)
        self.txt_YbRed:setVisible(true)
        self.LabelBMFont_yb:setVisible(false)
    else
        self.img_newprice_bg:setVisible(true)
        self.txt_tips:setVisible(false)
        self.txt_YbRed:setVisible(false)
        self.LabelBMFont_yb:setVisible(true)
    end
end

function EditBannerLayer:resetTableViewPosition( stepIndex )
    if stepIndex == 1 then
        local offsetX = cellBgW*( ChoseInfo.bannerBg - 2)
        if offsetX < 0 then
            offsetX = 0
        end
        local viewWidth = self.TabViewUI:getContentSize().width
        viewWidth = cellBgMax*cellBgW - viewWidth
        if offsetX > viewWidth then
            offsetX = viewWidth
        end
        self.TabViewBg:setContentOffset(ccp(-offsetX,0))
    else
        local choseindex = math.ceil(ChoseInfo.bannerIcon/2)
        local offsetX = cellIconW*( choseindex - 4)
        if offsetX < 0 then
            offsetX = 0
        end
        local viewWidth = self.TabViewUI:getContentSize().width
        viewWidth = cellIconMax*cellIconW - viewWidth
        if offsetX > viewWidth then
            offsetX = viewWidth
        end
        self.TabViewIcon:setContentOffset(ccp(-offsetX,0))
    end
end

function EditBannerLayer.onBannerBgColorClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if ChoseInfo.bannerBgColor == idx then
        return
    end
    ChoseInfo.bannerBgColor = idx
    self:refreshLeftDetails()
    self:refreshRightDetails()
end

function EditBannerLayer.onBannerIconColorClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if ChoseInfo.bannerIconColor == idx then
        return
    end
    ChoseInfo.bannerIconColor = idx
    self:refreshLeftDetails()
    self:refreshRightDetails()
end
return EditBannerLayer