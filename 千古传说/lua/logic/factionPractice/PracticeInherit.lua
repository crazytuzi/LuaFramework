--[[
******帮派-修炼-传承*******

	-- by quanhuan
	-- 2016/1/7
	
]]

local PracticeInherit = class("PracticeInherit",BaseLayer)

local cellH = 0
local cellW = 0


local textureData = {
    {
        imgBtnSelect = 'ui_new/Zhuzhan/bg_zhuzhan3.png',
        imgIconSelect= 'ui_new/faction/xiulian/btn_touxiang2.png',
        imgBtnNormal = 'ui_new/Zhuzhan/bg_zhuzhan2.png',
        imgIconNormal= 'ui_new/faction/xiulian/btn_touxiang1.png',
    },
    {
        imgBtnSelect = 'ui_new/Zhuzhan/bg_zhuzhan3.png',
        imgIconSelect= 'ui_new/faction/xiulian/btn_touxiang4.png',
        imgBtnNormal = 'ui_new/Zhuzhan/bg_zhuzhan2.png',
        imgIconNormal= 'ui_new/faction/xiulian/btn_touxiang3.png',
    },
}

local btnPageTexture = {
    {
        imgSelect = "ui_new/faction/xiulian/btn_pt2.png",
        imgNormal = "ui_new/faction/xiulian/btn_pt1.png",
    },
    {
        imgSelect = "ui_new/faction/xiulian/btn_xl2.png",
        imgNormal = "ui_new/faction/xiulian/btn_xl1.png",
    },
}

local cellDetailData = {}
local cellDetailDataSencond = {}
--[[
    -inheritId
    -inheritName
    -inheritIcon
    -inheritCurrLevel
    -inheritCurrValue
    -inheritNextLevel
    -inheritNextValue
    -inheritSycee
    -inheritIsPercent
    -gmIdA
    -gmIdB
]]
local GmIDTblData = {0,0}
function PracticeInherit:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.PracticeInherit")
end

function PracticeInherit:initUI( ui )

	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.InheritFaction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE})
    
    self.inHeritObj = {}    
    local nodeName = {'bg_xuanzhong','bg_touxiang'}
    for i=1,2 do
        local heritNode = TFDirector:getChildByPath(ui, nodeName[i])
        self.inHeritObj[i] = {}
        self.inHeritObj[i].imgBtn = TFDirector:getChildByPath(ui, nodeName[i])
        self.inHeritObj[i].imgIcon = TFDirector:getChildByPath(heritNode, 'Image_Qihe_1')
        self.inHeritObj[i].imgArrow = TFDirector:getChildByPath(heritNode, 'img_arrow')
        self.inHeritObj[i].btnFrame = TFDirector:getChildByPath(heritNode, 'btn_icon')
        self.inHeritObj[i].btnFrame:setTouchEnabled(false)
        self.inHeritObj[i].imgHead= TFDirector:getChildByPath(heritNode, 'img_touxiang')
        self.inHeritObj[i].imgZhiye = TFDirector:getChildByPath(heritNode, 'img_zhiye')
        self.inHeritObj[i].selectState = false
    end
    
    self.noHerit = TFDirector:getChildByPath(ui, 'txt_tips')
    self.effectNode = TFDirector:getChildByPath(ui, 'bg')

    self.btnPage = {}
    for i=1,2 do
        self.btnPage[i] = i
        self.btnPage[i] = TFDirector:getChildByPath(ui, "btn_"..i)
    end
    self:refreshTableView(1)

    --创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "panel_tiaomu")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    local panelNode = TFDirector:getChildByPath(ui, 'panel_tiaomu')
    self.cellModel = TFDirector:getChildByPath(panelNode, "bg_tiaomu")
    self.cellModel:setVisible(false) 
    self.cellModelX =  self.cellModel:getPositionX()
    self.cellModelY =  self.cellModel:getContentSize().height/2 - 10

    cellH = self.cellModel:getContentSize().height
    cellW = self.cellModel:getContentSize().width

    self.img_lines = TFDirector:getChildByPath(ui, "img_lines")
    self.img_linexia = TFDirector:getChildByPath(ui, "img_linexia")
    local bg_chooseNode = TFDirector:getChildByPath(ui, "bg_choose")
    self.img_di = TFDirector:getChildByPath(bg_chooseNode, "img_di")
end


function PracticeInherit:removeUI()
	self.super.removeUI(self)
end

function PracticeInherit:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function PracticeInherit:registerEvents()

    if self.registerEventCallFlag then
        return
    end
    self.canTouch = true
	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    for i=1,#self.inHeritObj do
        self.inHeritObj[i].imgBtn:setTouchEnabled(true)
        self.inHeritObj[i].imgBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHeadBtnClick))
        self.inHeritObj[i].imgBtn.logic = self
        self.inHeritObj[i].imgBtn.idx = i

        self.inHeritObj[i].btnFrame:setVisible(false)
    end
    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.TabView:addMEListener(TFTABLEVIEW_SCROLL, self.tableScroll)

    self.inheritanceSucessCallBack = function (event)

        if self.inheritanceSucessEffect then
            self.inheritanceSucessEffect:removeMEListener(TFARMATURE_COMPLETE)
            self.inheritanceSucessEffect:removeFromParent()
            self.inheritanceSucessEffect = nil
        end

        TFResourceHelper:instance():addArmatureFromJsonFile("effect/InheritOutPut.xml")
        local effect = TFArmature:create("InheritOutPut_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:playByIndex(0, -1, -1, 0)
        effect:setVisible(true)
        effect:setPosition(ccp(120,430))
        self.inheritanceSucessEffect = effect
        self.effectNode:addChild(effect,100)

        self.canTouch = false
        self.inheritanceSucessEffect:addMEListener(TFARMATURE_COMPLETE,function ()
            self.inheritanceSucessEffect:removeMEListener(TFARMATURE_COMPLETE)
            self.inheritanceSucessEffect:removeFromParent()
            self.inheritanceSucessEffect = nil

            self:addRole( 1, GmIDTblData[1] )
            self:showTips()
            local layer  = require("lua.logic.factionPractice.PracticeInheritResult"):new()
            AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE) 
            layer:setData(event.data[1], self)   
            AlertManager:show()
        end)
    end
    TFDirector:addMEGlobalListener(FactionPracticeManager.inheritanceSucess, self.inheritanceSucessCallBack) 

    -- self.ui:setTouchEnabled(true)
    -- self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(function (btn)
    --     TFDirector:dispatchGlobalEventWith(FactionPracticeManager.inheritanceSucess, {})
    -- end))

    for i=1,2 do
        self.btnPage[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectBtnClick))
        self.btnPage[i].logic = self
        self.btnPage[i].idx = i
    end

    self.registerEventCallFlag = true 
end

function PracticeInherit:removeEvents()

    self.super.removeEvents(self)

	if self.generalHead then
        self.generalHead:removeEvents()
    end
 	
    for i=1,#self.inHeritObj do
        self.inHeritObj[i].imgBtn:removeMEListener(TFWIDGET_CLICK)
    end

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    TFDirector:removeMEGlobalListener(FactionPracticeManager.inheritanceSucess, self.inheritanceSucessCallBack)
    self.inheritanceSucessCallBack = nil

    if self.inheritanceSucessEffect then
        self.inheritanceSucessEffect:removeMEListener(TFARMATURE_COMPLETE)
        self.inheritanceSucessEffect:removeFromParent()
        self.inheritanceSucessEffect = nil
    end

    for i=1,2 do
        self.btnPage[i]:removeMEListener(TFWIDGET_CLICK)
    end

    self.registerEventCallFlag = nil  
end

function PracticeInherit:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end


function PracticeInherit.cellSizeForTable(table,idx)
    return cellH,cellW
end

function PracticeInherit.numberOfCellsInTableView(table)
    local self = table.logic

    local count = #cellDetailData
    if self.currBtnIndex == 2 then
        count = #cellDetailDataSencond
    end
    -- self.noHerit:setVisible(true)
    -- if count ~= 0 then
        
    -- end 
    self.noHerit:setVisible(false)
    if (GmIDTblData[1] == 0 and GmIDTblData[2] ~= 0) or (GmIDTblData[1] == 0 and GmIDTblData[2] == 0) then
        self.noHerit:setVisible(true)
        -- self.noHerit:setText('请选择传承侠客')
        self.noHerit:setText(localizable.PracticeInherit_desc1)
        
    elseif GmIDTblData[1] ~= 0 and GmIDTblData[2] == 0 then
        self.noHerit:setVisible(true)
        -- self.noHerit:setText('请选择受传承侠客')
        self.noHerit:setText(localizable.PracticeInherit_desc2)

    elseif (self.currBtnIndex == 1 and #cellDetailData == 0) or (self.currBtnIndex == 2 and #cellDetailDataSencond == 0) then         
        self.noHerit:setVisible(true)
        -- self.noHerit:setText('暂无可传承技能')
        self.noHerit:setText(localizable.PracticeInherit_desc3)
    end
    return count
end

function PracticeInherit.tableCellAtIndex(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()

    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModel:clone()
        local size = panel:getContentSize()
        panel:setPosition(ccp(self.cellModelX, self.cellModelY))
        cell:addChild(panel)
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end
    panel:setVisible(true)
    idx = idx + 1
    self:cellInfoSet(cell, panel, idx)

    return cell
end


function PracticeInherit:cellInfoSet(cell, panel, idx)

    if not cell.boundData then
        cell.boundData = true
        cell.inHeritName = TFDirector:getChildByPath(panel, 'txt1')
        cell.btn_xiulian = TFDirector:getChildByPath(panel, 'btn_xiulian')
        cell.skillIcon = TFDirector:getChildByPath(panel, 'img_tu')
        cell.currLevel = TFDirector:getChildByPath(panel, 'txt_level3')
        cell.currAttr = TFDirector:getChildByPath(panel, 'txt_leveldang')
        cell.nextLevel = TFDirector:getChildByPath(panel, 'txt_level5')
        cell.nextAttr = TFDirector:getChildByPath(panel, 'txt_level6')
        cell.txtPice = TFDirector:getChildByPath(panel, 'txt_price')

        cell.btn_xiulian:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onXiuLianBtnClick))
    end
    cell.btn_xiulian.logic = self
    cell.btn_xiulian.idx = idx
    local dataInfo = cellDetailData[idx]
    if self.currBtnIndex == 2 then
        dataInfo = cellDetailDataSencond[idx]
    end

--[[
    -inheritId
    -inheritName
    -inheritIcon
    -inheritCurrLevel
    -inheritCurrValue
    -inheritNextLevel
    -inheritNextValue
    -inheritSycee
]]
    cell.inHeritName:setText(dataInfo.inheritName)
    cell.skillIcon:setTexture(dataInfo.inheritIcon)
    cell.currLevel:setText('LV '..dataInfo.inheritCurrLevel)
    cell.nextLevel:setText('LV '..dataInfo.inheritNextLevel)
    
    local currValue = 0
    local nextValue = 0
    if dataInfo.inheritIsPercent then
        currValue = math.floor(dataInfo.inheritCurrValue/100)
        currValue = math.abs(currValue)
        currValue = currValue .. '%'
        nextValue = math.floor(dataInfo.inheritNextValue/100)
        nextValue = math.abs(nextValue)
        nextValue = nextValue .. '%'
    else
        currValue = dataInfo.inheritCurrValue
        currValue = math.abs(currValue)
        nextValue = dataInfo.inheritNextValue
        nextValue = math.abs(nextValue)
    end

    cell.currAttr:setText(currValue)
    cell.nextAttr:setText(nextValue)
   
    cell.txtPice:setText(dataInfo.inheritSycee)
end

function PracticeInherit:dataReady()
    GmIDTblData = {0,0}
    cellDetailData = {}
    cellDetailDataSencond = {}
    self.TabView:reloadData()
    self:refresLeftRole()

    self.noHerit:setVisible(true)
    -- self.noHerit:setText('请选择传承侠客')
    self.noHerit:setText(localizable.PracticeInherit_desc1)
end

function PracticeInherit.onHeadBtnClick( btn )
    local self = btn.logic
    local idx = btn.idx
    self.choseIndex = idx    
    local tipsTxt = localizable.PracticeInherit_desc1 -- "请选择传承侠客"
    if idx == 2 then
        tipsTxt = localizable.PracticeInherit_desc2  --'请选择受传承侠客'
    end

    for i=1,#self.inHeritObj do
        self.inHeritObj[i].selectState = false
    end
    self.inHeritObj[idx].selectState = true
    
    if GmIDTblData[idx] ~= 0 then
        self:removeRole(idx)
        self:showTips()
        return
    else
        self:refresLeftRole()
    end

    --显示角色选择界面
    local role_list
    if idx == 1 then
        role_list = TFArray:new()
        for card in CardRoleManager.cardRoleList:iterator() do
            local factionPractice = card:getFactionPractice() or {}
            for k,v in pairs(factionPractice) do
                if v.level > 0 then
                    role_list:pushBack(card)
                    break
                end
            end
        end
    else
        role_list = CardRoleManager.cardRoleList
    end
    local filter_list = FactionPracticeManager:getHouseCardList()
    for k,v in pairs(GmIDTblData) do
        local cardRole = CardRoleManager:getRoleByGmid(v)
        if cardRole then
            filter_list:pushBack(cardRole)
        end
    end

    local layer  = require("lua.logic.factionPractice.PracticeRoleSelect"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK,AlertManager.TWEEN_NONE)
    self.clickCallBack = function (cardRole)
        layer:moveOut()
        self:addRole(self.choseIndex, cardRole.gmId)
        self:showTips()
        play_buzhenluoxia()
        --print("fffffffffffffffffffffff")
    end
    layer:initDateByFilter( role_list, filter_list,tipsTxt,self.clickCallBack)
    AlertManager:show()
end

function PracticeInherit:removeRole( idx )
    GmIDTblData[idx] = 0
    cellDetailData = {}
    cellDetailDataSencond = {}
    self:refresLeftRole()
    self.TabView:reloadData()

end

function PracticeInherit:addRole( idx, gmId )
    local lastGmId = GmIDTblData[idx]
    GmIDTblData[idx] = gmId
    self:refresLeftRole()

    if lastGmId ~= gmId then
        self:playSelectRoleAnim(idx)
    end

    if GmIDTblData[1] ~= 0 and GmIDTblData[2] ~= 0 then
        cellDetailData = {}
        cellDetailDataSencond = {}
        local cardRoleA = CardRoleManager:getRoleByGmid(GmIDTblData[1])
        local cardRoleB = CardRoleManager:getRoleByGmid(GmIDTblData[2])
        if cardRoleA and cardRoleB then  
            local tblA = cardRoleA.factionPractice or {}
            local tblB = cardRoleB.factionPractice or {}
            
            local tblListA = {}
            local tblListB = {}
            for k,v in pairs(tblA) do
                tblListA[v.type] = v.level
            end
            for k,v in pairs(tblB) do
                tblListB[v.type] = v.level
            end

            for attrType,attrLevel in pairs(tblListA) do
                local LevelB = tblListB[attrType] or 0
                if attrLevel > LevelB then
                    local templeteDataA = GuildPracticeData:getPracticeInfoByTypeAndLevel( attrType,attrLevel,cardRoleA.outline )
                    if templeteDataA then
    
                        local templeteDataB = GuildPracticeData:getPracticeInfoByTypeAndLevel( attrType,LevelB,cardRoleB.outline )
                        local itemData = {}                            
                        itemData = {}
                        itemData.inheritId = attrType
                        itemData.inheritName = templeteDataA.title
                        itemData.inheritIcon = 'ui_new/faction/xiulian/'..templeteDataA.icon..'.png'
                        itemData.inheritNextLevel = attrLevel
                        local inheritData = GuildPracticeData:getPracticeInfoByTypeAndLevel( attrType,attrLevel,cardRoleB.outline )
                        itemData.inheritNextValue = inheritData:getAttributeValue().value
                        itemData.inheritIsPercent = inheritData:getAttributeValue().percent
                        itemData.gmIdA = cardRoleA.gmId
                        itemData.gmIdB = cardRoleB.gmId

                        if templeteDataB then
                            itemData.inheritCurrLevel = LevelB
                            itemData.inheritCurrValue = templeteDataB:getAttributeValue().value
                        else
                            itemData.inheritCurrLevel = 0
                            itemData.inheritCurrValue = 0
                        end
                        local studyInfo = GuildPracticeStudyData:getPracticeInfoByTypeAndLevel(attrType,attrLevel)
                        itemData.inheritSycee = studyInfo:getConsumes().value

                        if templeteDataA.page == 1 then
                            table.insert(cellDetailData, itemData)
                        else
                            table.insert(cellDetailDataSencond, itemData)
                        end                        
                    end
                end
            end
        end       
    else
        cellDetailData = {}
        cellDetailDataSencond = {}
    end 
    self.TabView:reloadData()   
end

function PracticeInherit:refresLeftRole()
    print('GmIDTblData = ',GmIDTblData)
    local needViewBtn = true
    for k,v in pairs(GmIDTblData) do
        local cardRole = CardRoleManager:getRoleByGmid( v )
        if cardRole then
            self.inHeritObj[k].btnFrame:setVisible(true)
            self.inHeritObj[k].btnFrame:setTextureNormal(GetColorRoadIconByQuality(cardRole.quality))
            self.inHeritObj[k].imgHead:setTexture(cardRole:getHeadPath())
            self.inHeritObj[k].imgZhiye:setTexture("ui_new/fight/zhiye_".. cardRole.outline ..".png")
        else
            GmIDTblData[k] = 0
            self.inHeritObj[k].btnFrame:setVisible(false)
            needViewBtn = false
        end

        if self.inHeritObj[k].selectState then
            self.inHeritObj[k].imgArrow:setVisible(true)            
            self.inHeritObj[k].imgBtn:setTexture(textureData[k].imgBtnSelect)
            self.inHeritObj[k].imgIcon:setTexture(textureData[k].imgIconSelect)
        else
            self.inHeritObj[k].imgArrow:setVisible(false)            
            self.inHeritObj[k].imgBtn:setTexture(textureData[k].imgBtnNormal)
            self.inHeritObj[k].imgIcon:setTexture(textureData[k].imgIconNormal)
        end
    end
    for i=1,2 do
        self.btnPage[i]:setVisible(needViewBtn)
        self.img_lines:setVisible(needViewBtn)
        self.img_linexia:setVisible(needViewBtn)
        self.img_di:setVisible(needViewBtn)
    end
end

function PracticeInherit.onXiuLianBtnClick(btn)
    local self = btn.logic
    local dataInfo = cellDetailData[btn.idx]
    if self.currBtnIndex == 2 then
        dataInfo = cellDetailDataSencond[btn.idx]
    end

    if self.canTouch == false then
        return
    end

    local need = dataInfo.inheritSycee
    local str = '传承需要消耗%d元宝'
    str = stringUtils.format(localizable.PracticeInherit_cost,need)
    CommonManager:showOperateSureLayer(
        function()
            if MainPlayer:isEnoughSycee( need , true) then
                FactionPracticeManager:requestInheritance(dataInfo.gmIdA,dataInfo.inheritId,dataInfo.gmIdB)
            end
        end,
        nil,
        {
            msg = str
        }
    )
end

function PracticeInherit:showTips()
    if (GmIDTblData[1] == 0 and GmIDTblData[2] ~= 0) or (GmIDTblData[1] == 0 and GmIDTblData[2] == 0) then
        self.noHerit:setVisible(true)
        -- self.noHerit:setText('请选择传承侠客')
        self.noHerit:setText(localizable.PracticeInherit_desc1)
        
    elseif GmIDTblData[1] ~= 0 and GmIDTblData[2] == 0 then
        self.noHerit:setVisible(true)
        -- self.noHerit:setText('请选择受传承侠客')
        self.noHerit:setText(localizable.PracticeInherit_desc2)

    elseif (self.currBtnIndex == 1 and #cellDetailData == 0) or (self.currBtnIndex == 2 and #cellDetailDataSencond == 0) then         
        self.noHerit:setVisible(true)
        -- self.noHerit:setText('暂无可传承技能')
        self.noHerit:setText(localizable.PracticeInherit_desc3)
    end
end
function PracticeInherit:playSelectRoleAnim(pos)
    
    if self.currSelectRoleAnim then
        self.currSelectRoleAnim:removeFromParent()
        self.currSelectRoleAnim = nil
    end

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/assistOpen.xml")
    local effect = TFArmature:create("assistOpen_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    effect:setVisible(true)
       
    self.currSelectRoleAnim = effect
    local desNode = self.inHeritObj[pos].imgBtn
    desNode:addChild(effect,100)
    local x = desNode:getContentSize().width/2
    local y = desNode:getContentSize().height/2

    effect:setPosition(ccp(x,y))
    effect:addMEListener(TFARMATURE_COMPLETE, function ()
        effect:removeMEListener(TFARMATURE_COMPLETE) 
        effect:removeFromParent()
        self.currSelectRoleAnim = nil
    end)
end

function PracticeInherit.onSelectBtnClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if self.currBtnIndex == idx then
        return
    end
    self:refreshTableView(idx)
end

function PracticeInherit:refreshTableView( idx )
    self.currBtnIndex = idx

    for i=1,2 do
        if i == idx then
            self.btnPage[i]:setTextureNormal(btnPageTexture[i].imgSelect)
        else
            self.btnPage[i]:setTextureNormal(btnPageTexture[i].imgNormal)
        end
    end

    if self.TabView then
        self.TabView:reloadData()
    end
end

function PracticeInherit:refreshArrowBtn()
    local currPosition = self.TabView:getContentOffset()
    
    if self.TabView then
        local cellHeight = cellH        
        local guildPracticeNum = #cellDetailData
        if self.currBtnIndex == 2 then
            guildPracticeNum = #cellDetailDataSencond
        end
        
        local offsetMax = self.TabViewUI:getContentSize().height-cellHeight*guildPracticeNum
        local currPosition = self.TabView:getContentOffset()
        if currPosition.y < 0 and offsetMax >= currPosition.y then
            self.img_lines:setVisible(false)
        else
            self.img_lines:setVisible(true)
        end

        if currPosition.y >= 0 then
            self.img_linexia:setVisible(false)
        else
            self.img_linexia:setVisible(true)
        end
    end
end

function PracticeInherit.tableScroll( table )
    local self = table.logic
    self:refreshArrowBtn()
end
return PracticeInherit