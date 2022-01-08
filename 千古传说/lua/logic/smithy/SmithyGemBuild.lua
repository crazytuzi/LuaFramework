--[[
******铁匠铺宝石合成界面*******

	-- by david.dai
	-- 2014/5/8
]]

local SmithyGemBuild = class("SmithyGemBuild", BaseLayer)

local columnNumber = 3

function SmithyGemBuild:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.smithy.Smithysynthesis")
end

function SmithyGemBuild:initUI(ui)
	self.super.initUI(self,ui)

    --左侧详情
    self.scroll_left            = TFDirector:getChildByPath(ui, 'scroll_left')
    self.info_panel             = require('lua.logic.smithy.GemMergePanel'):new()
    self.scroll_left:addChild(self.info_panel)

    --右侧详情
    self.btn_build      = TFDirector:getChildByPath(ui, 'btn_syn')
    self.btn_auto       = TFDirector:getChildByPath(ui, 'btn_auto_syn')
    self.btn_oneKey     = TFDirector:getChildByPath(ui, 'btn_oneKey')
    self.txt_cost       = TFDirector:getChildByPath(ui, 'txt_cost')
    self.txt_autoTime   = TFDirector:getChildByPath(ui, 'txt_remian_num')
    self.panel_list     = TFDirector:getChildByPath(ui, 'panel_table')

	self.btn_build.logic = self
    self.btn_auto.logic = self
	self.btn_oneKey.logic = self
    self.btn_oneKey:setVisible(true)
    self.itemNeedChang = true
    self:initTableview()
end

function SmithyGemBuild:onShow()
    self.super.onShow(self)
    self:refreshUI()
    self.info_panel:onShow()
end

function SmithyGemBuild:refreshUI()
    self:updateTableSource()
    self.info_panel:setGmId(self.selectId)
    self:refreshBtnCost()
    self:refreshButtonState()
    self.tableView:reloadData()
    self:refreshTargetGem()
end

function SmithyGemBuild:dispose()
    self.info_panel:dispose()
    self:disposeAllPanels()
    self.super.dispose(self)
end

function SmithyGemBuild:removeUI()
	self.super.removeUI(self)
end

function SmithyGemBuild:refreshButtonState()
    if self.selectId == nil or self.selectId == 0 then
        self.btn_build:setTouchEnabled(false)
        self.btn_build:setGrayEnabled(true)
        self.btn_auto:setTouchEnabled(false)
        self.btn_auto:setGrayEnabled(true)
    else
        local bagitem = BagManager:getItemById(self.selectId)
        if not bagitem then
            self.btn_build:setTouchEnabled(false)
            self.btn_build:setGrayEnabled(true)
            self.btn_auto:setTouchEnabled(false)
            self.btn_auto:setGrayEnabled(true)
        elseif bagitem.num < 4 then
            self.btn_build:setTouchEnabled(false)
            self.btn_build:setGrayEnabled(true)
            self.btn_auto:setTouchEnabled(false)
            self.btn_auto:setGrayEnabled(true)
        else
            if self.isauto then
                self.btn_auto:setTouchEnabled(true)
                self.btn_auto:setGrayEnabled(false)
            else
                self.btn_build:setTouchEnabled(true)
                self.btn_build:setGrayEnabled(false)
                self.btn_auto:setTouchEnabled(true)
                self.btn_auto:setGrayEnabled(false)
            end
        end
    end
end

function SmithyGemBuild:refreshBtnCost()
    if self.selectId == nil or self.selectId == 0 then 
        self.txt_cost:setText("0")
        self.txt_autoTime:setText("0")
        return
    end

    local bagitem = BagManager:getItemById(self.selectId)
    if bagitem then
        local num = math.floor(bagitem.num/4)
        --print("bagitem.num : ",bagitem.num,num)
        self.txt_autoTime:setText(tostring(num))
    else    
        self.txt_autoTime:setText("0")
    end
end

function SmithyGemBuild:refreshTargetGem()
    if self.selectId == nil or self.selectId == 0 then 
        -- self.txt_newGemname:setVisible(false)
        -- self.txt_newgemattr:setVisible(false)
        -- self.img_targetIcon:setVisible(false)
        return
    end

    local gem = GemData:objectByID(self.selectId)
    if gem == nil  then
        return
    end

    self.info_panel:setGmId(self.selectId)

    self.txt_cost:setText(gem.merge_consume_coin)

    local enough = MainPlayer:isEnoughCoin(gem.merge_consume_coin,false)
    if not enough then
        -- toastMessage("铜币数量不足")
        self.txt_cost:setColor(ccc3(255,0,0))
    else
        self.txt_cost:setColor(ccc3(255,255,255))
    end
end

--销毁所有TableView的Cell中的Panel
function SmithyGemBuild:disposeAllPanels()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        if panel then
            panel:dispose()
        end
    end
end

--[[
    更新TableView显示的内容
]]
function SmithyGemBuild:updateTableSource()
    self.gemlist = BagManager:getItemByType(EnumGameItemType.Gem)

    --当其他提交都相等时使用的最简单的比较方法
    local function sortlist(src,target)
        if src.num < 4 and target.num >= 4 then
            return false
        elseif src.num >=4 and target.num < 4 then
            return true
        end
        if src.itemdata.level < target.itemdata.level then
            return false
        elseif src.itemdata.level == target.itemdata.level and src.itemdata.id < target.itemdata.id then
            return false
        else
            return true
        end
    end

    self.gemlist:sort(sortlist)
end

--[[
    全部cell都重置为未选中
]]
function SmithyGemBuild:unselectedAllCellPanels()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        if self.selectId and panel.id == self.selectId then
            --panel:setSelected(false)
            panel:refreshUI()
        end
    end
end

function SmithyGemBuild:updateSelectCell()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        panel:refreshUI()
    end
end

function SmithyGemBuild:selectDefault()
    if self.allPanels == nil then
        self.selectId = nil
        return
    end

    if self.gemlist and self.gemlist:length() > 0 then
        self:select(self.gemlist:objectAt(1).id)
    else
        self.selectId = nil
    end
end

--[[
    选中
]]
function SmithyGemBuild:select(id)
    --选中的Cell如果重复选中则不处理
    if self.selectId then
        if self.selectId == id then
            return
        end

        --self:unselectedAllCellPanels()
    end
    
    self.selectId = id
    self:updateSelectCell()

    --详细信息控件
    local item = BagManager:getItemById(id)
    if item == nil  then
        return
    end

    --self:setData(item)
end

function SmithyGemBuild.cellSizeForTable(table,idx)    
    return 185,540
end

function SmithyGemBuild.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,columnNumber do
            local gem_panel = require('lua.logic.smithy.SmithyGemIcon'):new(1)
            gem_panel:setPosition(ccp(25+137*(i-1),15))
            gem_panel:setLogic(self)
            cell:addChild(gem_panel)
            cell.gem_panel = cell.gem_panel or {}
            cell.gem_panel[i] = gem_panel

            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = gem_panel
        end
    end
    for i=1,columnNumber do
        local atIndex = idx * columnNumber + i
        --print("SmithyGemBuild.tableCellAtIndex : ",self.gemlist:length(),atIndex)
        -- if cell.gem_panel[i].effect then
        --     cell.gem_panel[i].effect:removeFromParent(true)
        --     cell.gem_panel[i].effect = nil
        -- end
        if atIndex <= self.gemlist:length() then
            local gem = self.gemlist:objectAt(atIndex)
            --cell.gem_panel[i]:setVisible(true)
            cell.gem_panel[i]:setGemid(gem.id)
        else
            cell.gem_panel[i]:setGemid(nil)
            --cell.gem_panel[i]:setVisible(false)
        end
    end
    return cell
end

function SmithyGemBuild:showOneKeyEffect( level )
    local effectList = TFArray:new()
    local temp = 1
    for v in self.gemlist:iterator() do
        local itemInfo = ItemData:objectByID(v.id)
        if itemInfo and itemInfo.level < level and temp <= 8 then
            effectList:pushBack(v.id)
            temp = temp + 1
        end
    end
    if effectList:length() > 0 then
        self:_choiceGemAction(effectList)
    end
end

function SmithyGemBuild.numberOfCellsInTableView(table)
    local self = table.logic
    if self.gemlist and self.gemlist:length() > 0 then
        local num = math.ceil(self.gemlist:length()/columnNumber)
        if num < 2 then
            return 2
        else
            return num
        end
    end
    return 2
end

function SmithyGemBuild:initTableview()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    self.tableView = tableView
    self.tableView:setZOrder(10)
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, SmithyGemBuild.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, SmithyGemBuild.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, SmithyGemBuild.numberOfCellsInTableView)

    --self:updateTableSource()
    self.panel_list:addChild(tableView)
end

function SmithyGemBuild:gemBuild()
    if self.selectId == nil or self.selectId == 0 then
        --toastMessage("请选择你需要合成的宝石")
        toastMessage(localizable.smithyGemBuild_check_store)
        if self.isauto then
            self.isauto = false
            self.btn_auto:setTextureNormal("ui_new/smithy/btn_auto_syn.png")
        end
        self:refreshButtonState()
        return
    end
    local item = BagManager:getItemById(self.selectId)
    if item == nil or item.num < 4 then
        --toastMessage("宝石数量不足")
        toastMessage(localizable.smithyGemBuild_not_store)
        if self.isauto then
            self.isauto = false
            self.btn_auto:setTextureNormal("ui_new/smithy/btn_auto_syn.png")
        end
        self:refreshButtonState()
        return
    end

    local coin = tonumber(self.txt_cost:getText())
    local enough = MainPlayer:isEnoughCoin(coin,false)
    if not enough then
        --toastMessage("铜币数量不足")
        toastMessage(localizable.smithyGemBuild_not_coin)
        self:refreshTargetGem()
        if self.isauto then
            self.isauto = false
            self.btn_auto:setTextureNormal("ui_new/smithy/btn_auto_syn.png")
        end
        self:refreshButtonState()
        return
    end

    if self.isauto then
        self.btn_auto:setTouchEnabled(true)
        self.btn_auto:setGrayEnabled(false)
        self.btn_build:setTouchEnabled(false)
        self.btn_build:setGrayEnabled(true)
    else
        self.btn_build:setTouchEnabled(true)
        self.btn_build:setGrayEnabled(false)
        self.btn_auto:setTouchEnabled(false)
        self.btn_auto:setGrayEnabled(true)
    end
    BagManager:GemBulid(self.selectId , false)
    self:playMergeEffect()
    --self:buildGemAction()
end

function SmithyGemBuild.gemBuildAutoBtnClickHandle(btn)
	local self = btn.logic
    if self then
        if self.isauto == true then
            self.isauto = false
            self.btn_auto:setTextureNormal("ui_new/smithy/btn_auto_syn.png")
        elseif self.actionpaly == false then
            local coin = tonumber(self.txt_cost:getText())
            local enough = MainPlayer:isEnoughCoin(coin,true)
            if not enough then
                return
            end
            self.isauto = true
            self.btn_auto:setTextureNormal("ui_new/smithy/btn_auto_syn1.png")
            self:gemBuild()
        end
    end
end

function SmithyGemBuild.oneKeyBuild(btn )
    local self = btn.logic
    local has = false
    for v in self.gemlist:iterator() do
        local itemInfo = ItemData:objectByID(v.id)
        if v.num >= 4 and itemInfo and itemInfo.level < 6 then
            has = true
        end
    end
    if has == false then
        --toastMessage("没有低于6级可合成的石头")
        toastMessage(localizable.smithy_gem_not_six)
        return
    end
    CommonManager:showOperateSureLayer(function ()
            self:showOneKeyEffect(6)
        end,
        function()
            AlertManager:close()
        end,
        {
        msg = localizable.smithy_gem_oneKeyBuild,
        })
    -- 是否确认将所有低级宝石合成最高至6级？
end

function SmithyGemBuild.gemBuildBtnClickHandle(btn)
	local self = btn.logic

    local coin = tonumber(self.txt_cost:getText())
    local enough = MainPlayer:isEnoughCoin(coin,true)
    if not enough then
        return
    end

    if self and self.actionpaly == false then
        self.isauto = false
        self:gemBuild()
    end
end

function SmithyGemBuild:iconBtnClick(cell)
    if self.isauto then
       -- toastMessage("正在自动合成，不可点击更换目标")
        toastMessage(localizable.smithyGemBuild_not_change)
        return
    end

    local gem = GemData:objectByID(cell.id)
    if gem == nil  then
       -- toastMessage("该宝石数据无法找到")
        toastMessage(localizable.smithyGemBuild_not_find)
        return
    end

    if gem.merge_to == 0 then
        --toastMessage("该宝石已经是最高等级了")
        toastMessage(localizable.smithyGemBuild_max)
        return
    end

    local bagitem = BagManager:getItemById(cell.id)
    if not bagitem then
       -- toastMessage("背包中没有该宝石")
        toastMessage(localizable.smithyGemBuild_not_in_bag)
        return
    elseif bagitem.num < 4 then
         --toastMessage("宝石数量不足")
         toastMessage(localizable.smithyGemBuild_not_store)
         return
    end
    
	play_xuanze();

    self:select(cell.id)
    self.actionpaly = true
    self:choiceGemAction(cell)
    self:refreshBtnCost()
    self:refreshButtonState()
end

function SmithyGemBuild:buildGemAction()
    self.actionpaly = true
    self.percent = 0
    if self.timerId then
        TFDirector:removeTimer(self.timerId)
        self.timerId = nil
    end
    self.timerId = TFDirector:addTimer(100,10,
    function ()
        TFDirector:removeTimer(self.timerId)
        self.timerId = nil
        TFAudio.playEffect("sound/effect/btn_succeed.mp3", false)
        local item = BagManager:getItemById(self.selectId)
        if self.isauto and item and item.num >= 4 then
            self:gemBuild()
        else
            self.actionpaly = false
            -- self.Bar_percent:setPercent(0)
        end
    end,function ()
        self.percent = self.percent + 10
        -- self.Bar_percent:setPercent(self.percent)
    end)
end

function SmithyGemBuild:choiceGemAction(cell)

    local gem = ItemData:objectByID(cell.id)
    if gem == nil  then
        return
    end

    local temp = 1
    local pic = TFImage:create()
    --local pos = cell:getParent():convertToWorldSpace(cell:getPosition())
    --pos.x = pos.x - 32
    --pos.y = pos.y + 16

    local pos = cell:getEffectPosition()
    local _parent = self.ui:getParent()
    local rootPos = _parent:convertToWorldSpaceAR(self.ui:getPosition())
    pos.x = pos.x - rootPos.x
    pos.y = pos.y - rootPos.y
    --self:playEffect(pos.x + cell:getSize().width/2,pos.y + cell:getSize().height/2)
    self:playEffect(pos.x,pos.y)

    pic:setAnchorPoint(CCPointMake(0.5,0.5))
    pic:setTexture(gem:GetPath())
    pic:setZOrder(100)
    self.ui:addChild(pic)
   
    self.info_panel:setGemIconVisiable(false)
    self:choiceGemActionPlay(pic,gem:GetPath(),pos,1)
end

function SmithyGemBuild:choiceGemActionPlay(pic,path,pos,index)
    play_hechengbaoshiqianru()
    pic:setPosition(pos)
    local newPos = self.info_panel.gem_table[index]:getParent():convertToWorldSpaceAR(self.info_panel.gem_table[index]:getPosition())
    local _parent = self.ui:getParent()
    local rootPos = _parent:convertToWorldSpaceAR(self.ui:getPosition())
    --print("new world pos : ",newPos,index,self.ui:getPosition())
    newPos.x = newPos.x - rootPos.x
    newPos.y = newPos.y - rootPos.y
    local tween = {
        target = pic,
            {
                ease = {type=TFEaseType.EASE_IN_OUT, rate=3},
                duration = 0.3,
                x = newPos.x,
                y = newPos.y,
                onComplete = function ()
                    self:playEffect(newPos.x,newPos.y)
                    self.info_panel.gem_table[index]:setVisible(true)
                    self.info_panel.gem_table[index]:setTexture(path)
                    local bagitem = BagManager:getItemById(self.selectId)
                    if bagitem then
                        -- self.txt_gemnum[index]:setVisible(true)
                        -- self.txt_gemnum[index]:setText(bagitem.num)
                    end
                    if index == 4 or bagitem == nil or bagitem.num == index then
                        self:refreshTargetGem()
                        pic:removeFromParentAndCleanup(true)
                        pic = nil         
                        self.actionpaly = false
                    else
                        self:choiceGemActionPlay(pic,path,pos,(index+1))
                    end     
                end,
            },
    }
    TFDirector:toTween(tween)
end

function SmithyGemBuild:playEffect(x,y)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/gem_click.xml")
    local effect = TFArmature:create("gem_click_anim")
    if effect == nil then
        return
    end

    effect:setZOrder(100)
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)

    effect:setPosition(ccp(x, y))

    self.ui:addChild(effect)
    effect:addMEListener(TFARMATURE_COMPLETE,
    function()
        self.ui:removeChild(effect)
    end)
end


function SmithyGemBuild:_choiceGemAction(list)
    local id = list:pop()
    local gem = ItemData:objectByID(id)
    if gem == nil  then
        return
    end

    local temp = 1
    local pic = TFImage:create()
    --local pos = cell:getParent():convertToWorldSpace(cell:getPosition())
    --pos.x = pos.x - 32
    --pos.y = pos.y + 16

    local pos = ccp(700,250)
    local _parent = self.ui:getParent()
    local rootPos = _parent:convertToWorldSpaceAR(self.ui:getPosition())
    pos.x = pos.x - rootPos.x
    pos.y = pos.y - rootPos.y
    --self:playEffect(pos.x + cell:getSize().width/2,pos.y + cell:getSize().height/2)
    self:playEffect(pos.x,pos.y)

    pic:setAnchorPoint(CCPointMake(0.5,0.5))
    pic:setTexture(gem:GetPath())
    pic:setZOrder(100)
    self.ui:addChild(pic)
   
    self.info_panel:setGemIconVisiable(false)
    self:_choiceGemActionPlay(pic,gem:GetPath(),pos,list)
end

function SmithyGemBuild:_choiceGemActionPlay(pic,path,pos,list)
    play_hechengbaoshiqianru()
    pic:setPosition(pos)
    local newPos = ccp(300,300)
    local _parent = self.ui:getParent()
    local rootPos = _parent:convertToWorldSpaceAR(self.ui:getPosition())
    --print("new world pos : ",newPos,index,self.ui:getPosition())
    newPos.x = newPos.x - rootPos.x
    newPos.y = newPos.y - rootPos.y
    local tween = {
        target = pic,
            {
                ease = {type=TFEaseType.EASE_IN_OUT, rate=3},
                duration = 0.3,
                x = newPos.x,
                y = newPos.y,
                onComplete = function ()
                    pic:removeFromParentAndCleanup(true)
                    pic = nil
                    if list:length() > 0 then
                        self:_choiceGemAction(list)
                    else
                        BagManager:autoMergeGemRequest(6)
                        self:playMergeEffect()
                    end
                end,
            },
    }
    TFDirector:toTween(tween)
end



function SmithyGemBuild:_playEffect(panel)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/gem_click.xml")
    local effect = TFArmature:create("gem_click_anim")
    if effect == nil then
        return
    end

    effect:setZOrder(100)
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)

    -- effect:setPosition(ccp(x, y))

    panel:addChild(effect)
    panel.effect = effect
    panel.effect:addMEListener(TFARMATURE_COMPLETE,
    function()
        panel.effect:removeFromParent(true)
        panel.effect = nil
    end)
end

function SmithyGemBuild:playMergeEffect()
    local effect = self.ui.effect;
    if not effect or not effect:getParent() then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/merge_gem.xml")
        effect = TFArmature:create("merge_gem_anim")
        if effect == nil then
            return
        end

        effect:setZOrder(100)
        effect:setAnimationFps(GameConfig.ANIM_FPS)

        local position = self.info_panel:getMergeEffectPosition()
        local _parent = self.ui:getParent()
        local rootPos = _parent:convertToWorldSpaceAR(self.ui:getPosition())
        position.x = position.x - rootPos.x
        position.y = position.y - rootPos.y
        effect:setPosition(position)

        self.ui:addChild(effect)
        self.ui.effect = effect;
        effect:addMEListener(TFARMATURE_COMPLETE,
        function()
            self.ui:removeChild(effect)
            self.ui.effect = nil;
            if self.isatuo then

            else
                self.btn_build:setTouchEnabled(true)
                self.btn_build:setGrayEnabled(false)
                self.btn_auto:setTouchEnabled(true)
                self.btn_auto:setGrayEnabled(false)
            end
            self:refreshButtonState()
        end)
        effect:playByIndex(0, -1, -1, 0)
    else
        if self.isauto then

        else
            effect:playByIndex(0, -1, -1, 0)
        end
    end

end

function SmithyGemBuild:registerEvents()
	self.super.registerEvents(self)

	self.btn_build:addMEListener(TFWIDGET_CLICK, audioClickfun(self.gemBuildBtnClickHandle),1)
    self.btn_auto:addMEListener(TFWIDGET_CLICK, audioClickfun(self.gemBuildAutoBtnClickHandle),1)
	self.btn_oneKey:addMEListener(TFWIDGET_CLICK, audioClickfun(self.oneKeyBuild),1)

    self.gemBuildResuleCallBack = function(event)
        play_hechenghecheng()
        --toastMessage("宝石合成成功")
        self:refreshBtnCost()
        local item = BagManager:getItemById(self.selectId)
        if self.isauto then
            if item and item.num >= 4 then
                self:gemBuild()
            else
                self.isauto = false
                self.btn_auto:setTextureNormal("ui_new/smithy/btn_auto_syn.png")
            end
        end
        self.info_panel:refreshUI()
        --self:showSuccessDialog()
    end
    TFDirector:addMEGlobalListener(BagManager.GEM_BULID_RESULT,self.gemBuildResuleCallBack)

	self.gemOneKyBuildResuleCallBack = function(event)
        play_hechenghecheng()
        self:updateTableSource()
        self.tableView:reloadData()
        self:refreshBtnCost()
        self.info_panel:refreshUI()
        self.itemNeedChang = true

        local data = event.data[1][1]
        print(data)
        if #data == 0 then
            return
        end
        local rewardList = TFArray:new();
        for i=1,#data do
            local rewardArr = {itemId = data[i].id , number = data[i].changeNum,type = EnumDropType.GOODS}
            local rewardInfo = BaseDataManager:getReward(rewardArr)
            rewardList:push(rewardInfo);
        end
        RewardManager:showRewardListLayer(rewardList)
    end
	TFDirector:addMEGlobalListener(BagManager.GEM_ONEKEY_BULID_RESULT,self.gemOneKyBuildResuleCallBack)

    self.itemAddCallBack = function (event)
        local holdGoods = event.data[1]
        if not holdGoods or self.itemNeedChang == false then
            return
        end
        if holdGoods.itemdata.type ==  EnumGameItemType.Gem then
            self:updateTableSource()
            self.tableView:reloadData()
        end
    end

    self.itemDeleteCallBack = function (event)
        local holdGoods = event.data[1]
        if not holdGoods or self.itemNeedChang == false then
            return
        end
        if holdGoods.itemdata.type ==  EnumGameItemType.Gem then
            self:updateTableSource()
            self.tableView:reloadData()
        end
    end

    self.itemNumberChangedCallBack = function (event)
        if  self.itemNeedChang == false then
            return
        end
        self:updateTableSource()
        self.tableView:reloadData()
    end
    
    TFDirector:addMEGlobalListener(BagManager.ItemAdd,self.itemAddCallBack)
    TFDirector:addMEGlobalListener(BagManager.ItemDel,self.itemDeleteCallBack)
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemNumberChangedCallBack)
    
end

function SmithyGemBuild:removeEvents()
    self.super.removeEvents(self)
    
    TFDirector:removeMEGlobalListener(BagManager.GEM_BULID_RESULT,self.gemBuildResuleCallBack)
    TFDirector:removeMEGlobalListener(BagManager.GEM_ONEKEY_BULID_RESULT,self.gemOneKyBuildResuleCallBack)
    TFDirector:removeMEGlobalListener(BagManager.ItemAdd,self.itemAddCallBack)
    TFDirector:removeMEGlobalListener(BagManager.ItemDel,self.itemDeleteCallBack)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.itemNumberChangedCallBack)
    self.gemBuildResuleCallBack = nil
    self.gemOneKyBuildResuleCallBack = nil
    --self.btn_build:removeMEListener(TFWIDGET_CLICK)
    --self.btn_auto:removeMEListener(TFWIDGET_CLICK)
end

function SmithyGemBuild:stopAutoBuild()
    self.isauto = false
    self.itemNeedChang = true
end

--显示升星成功对话框
function SmithyGemBuild:showSuccessDialog()
    if self.layer_result == nil then
        self.layer_result = TFImage:create("ui_new/smithy/hecheng_word.png")
        self.layer_result:setAnchorPoint(ccp(0.5,0.5))
        self.layer_result:setPosition(ccp(self.ui:getContentSize().width/2,self.ui:getContentSize().height/2))
        self.ui:addChild(self.layer_result)
    end

    TFDirector:killAllTween(self.layer_result)
    self.layer_result:setVisible(true)
    self.layer_result:setZOrder(100)
    self.layer_result:setScale(0.1)
    local tween = {
        target = self.layer_result,
            {
                duration = 0.1,
                scale = 1,
            },
            {
                duration = 0.1,
                scale = 0.8,
            },
            {
                duration = 0.1,
                scale = 1,
            },
            {
                duration = 0,
                delay = 1,
                onComplete = function ()
                    self.layer_result:setVisible(false)
                end,
            },
    }
    TFDirector:toTween(tween)
end

--[[
验证点是否在TableView内部
]]
function SmithyGemBuild:isTouchInTableView(position)
    local _parent = self.tableView:getParent()
    local rootPos = _parent:convertToWorldSpaceAR(self.tableView:getPosition())
    local size = self.tableView:getTableViewSize()
    if position.x > rootPos.x and position.x < rootPos.x+size.width 
        and position.y <rootPos.y + size.height and position.y > rootPos.y then
        return true
    end
    return false
end

return SmithyGemBuild;
