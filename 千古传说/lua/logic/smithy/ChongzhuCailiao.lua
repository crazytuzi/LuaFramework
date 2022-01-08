--[[
******装备重铸-材料选择*******
    --by quanhuan
    --2016/1/15
]]

local ChongzhuCailiao = class("ChongzhuCailiao",BaseLayer)

local columnNumber = 3

function ChongzhuCailiao:ctor(data)

    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.smithy.ChongzhuCailiao")
end

function ChongzhuCailiao:initUI( ui )

    self.super.initUI(self, ui)

    self.TabViewUI = TFDirector:getChildByPath(ui, "panel_list")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.cellModel = createUIByLuaNew("lua.uiconfig_mango_new.smithy.EquipmentStarUpIcon")
    self.cellModel:retain()
end

function ChongzhuCailiao:initDateByFilter( gmId, equip_list, clickCallBack)

    self.equipList = equip_list or TFArray:new()
    self.bagItem = nil

    local equip = EquipmentManager:getEquipByGmid(gmId)
    if equip then
        if equip.quality == 4 then
            self.bagItem = BagManager:getItemById(30076)
        elseif equip.quality == 5 then
            self.bagItem = BagManager:getItemById(30077)
        end
    end    

    self.clickCallBack = clickCallBack
    self.TabView:reloadData()
end


function ChongzhuCailiao.cellSizeForTable(table,cell)
    return 140,120
end

function ChongzhuCailiao.tableCellAtIndex(table,idx)
    local self = table.logic
    local cell = table:dequeueCell()
    self.allPanels = self.allPanels or {}

    if cell == nil then
        cell = TFTableViewCell:create()
        local newIndex = #self.allPanels + 1
        self.allPanels[newIndex] = cell

        for i=1,columnNumber do
            local panel = self.cellModel:clone()
            panel:setPosition(ccp(26 + 140 * (i - 1) ,0))
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



function ChongzhuCailiao:cellInfoSet( panel, idx )

    if panel.boundData == nil then
        panel.boundData = true
        panel.img_quality    = TFDirector:getChildByPath(panel, 'img_quality')
        panel.img_icon       = TFDirector:getChildByPath(panel, 'img_icon')
        panel.txt_level      = TFDirector:getChildByPath(panel, 'txt_level')
        panel.img_choice     = TFDirector:getChildByPath(panel, 'Image_choose')
        panel.img_choice:setVisible(false)
        panel.img_gem = {}
        panel.img_gembg = {}
        for i=1,EquipmentManager.kGemMergeTargetNum do
            panel.img_gem[i]            = TFDirector:getChildByPath(panel, 'img_gem'..i)
            panel.img_gembg[i]          = TFDirector:getChildByPath(panel, 'img_gembg'..i)
        end
        panel.img_icon.logic = self
        panel.image_star = {}
        for i=1,5 do
            local str = "Image_star"..i
            panel.image_star[i]       = TFDirector:getChildByPath(panel, str)
        end
        --显示空白网格逻辑添加
        panel.panel_empty            = TFDirector:getChildByPath(panel, 'panel_empty')
        panel.panel_info             = TFDirector:getChildByPath(panel, 'panel_info')

        panel.btn_Del                = TFDirector:getChildByPath(panel, 'btn_chongzhi')
        panel.btn_Del:setVisible(false)
        panel.txt_num                = TFDirector:getChildByPath(panel, 'txt_num')
        panel.txt_num:setVisible(false)
        panel.txt_plus                = TFDirector:getChildByPath(panel, 'txt_plus')
        panel.txt_plus:setVisible(false)

        panel.img_icon:setTouchEnabled(true)
        panel.img_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconClickHandle))
    end

    if self.bagItem then
        idx = idx - 1
    end

    panel.img_icon.idx = idx

    if idx == 0 then
        EquipmentManager:BindEffectOnEquip(panel.img_quality, {})       
        panel.panel_empty:setVisible(false)
        panel.panel_info:setVisible(true)
            
        panel.txt_level:setVisible(true)
        panel.img_icon:setTexture(self.bagItem:GetPath())
        panel.img_quality:setTexture(GetColorIconByQuality(self.bagItem.quality))
        panel.txt_level:setText(self.bagItem.num)

        for i=1,5 do
            panel.image_star[i]:setVisible(false)
        end
        for i=1,EquipmentManager.kGemMergeTargetNum do         
            panel.img_gembg[i]:setVisible(false)                
        end         
    else
        local equip = self.equipList:objectAt(idx)
        EquipmentManager:BindEffectOnEquip(panel.img_quality, equip)        
        if equip then
            -- print(equip)
            panel.panel_empty:setVisible(false)
            panel.panel_info:setVisible(true)
            panel.txt_level:setVisible(true)
            panel.img_icon:setTexture(equip:GetTextrue())
            panel.img_quality:setTexture(GetColorIconByQuality(equip.quality))
            panel.txt_level:setText('+'..equip.level)
            for i=1,5 do
                if i <= equip:getStar() then
                    panel.image_star[i]:setVisible(true)
                else
                    panel.image_star[i]:setVisible(false)
                end
            end
            for i=1,EquipmentManager.kGemMergeTargetNum do
                if equip:getGemPos(i) then
                    panel.img_gembg[i]:setVisible(true)
                    local item = ItemData:objectByID(equip:getGemPos(i))
                    if item then
                        panel.img_gem[i]:setTexture(item:GetPath())
                    end
                else
                    panel.img_gembg[i]:setVisible(false)
                end
            end
        else
            panel.panel_empty:setVisible(true)
            panel.panel_info:setVisible(false)
        end        
    end
end

function ChongzhuCailiao.numberOfCellsInTableView(table,cell)
    local self = table.logic   
    local num = 0 
    if self.bagItem ~= nil then
        num = 1
    end
    if self.equipList ~= nil then
        num = num + self.equipList:length()
    end
    return math.ceil(num/columnNumber)
end


function ChongzhuCailiao.iconClickHandle( btn )
    local self = btn.logic
    TFFunction.call(self.clickCallBack,btn.idx)
end

function ChongzhuCailiao:removeUI()
    self.super.removeUI(self)

    if self.cellModel then
        self.cellModel:release()
        self.cellModel = nil
    end
end

function ChongzhuCailiao:onShow()
    self.super.onShow(self)
end

function ChongzhuCailiao:registerEvents()    
    self.super.registerEvents(self)
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
end

function ChongzhuCailiao:removeEvents()
    self.super.removeEvents(self)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
end

function ChongzhuCailiao:dispose()
    self.super.dispose(self)
end


return ChongzhuCailiao