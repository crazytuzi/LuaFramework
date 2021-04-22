-- @Author: zhouxiaoshu
-- @Date:   2019-07-30 17:25:36
-- @Last Modified by:   zhouyou
-- @Last Modified time: 2020-09-24 14:38:00
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSuperHeroGrade = class("QUIDialogSuperHeroGrade", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetItemsBoxEnchant = import("..widgets.QUIWidgetItemsBoxEnchant")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")


function QUIDialogSuperHeroGrade:ctor(options)
	local ccbFile = "ccb/Dialog_super_herobreakstar.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerAdvance", callback = handler(self, self._onTriggerAdvance)},
        {ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
        {ccbCallbackName = "onTriggerSet", callback = handler(self, self._onTriggerSet)},
        {ccbCallbackName = "onTriggerAutoAdd", callback = handler(self, self._onTriggertAutoAdd)},
    }
    QUIDialogSuperHeroGrade.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    q.setButtonEnableShadow(self._ccbOwner.btn_advance)
    q.setButtonEnableShadow(self._ccbOwner.btn_reset)
    q.setButtonEnableShadow(self._ccbOwner.btn_set)
    q.setButtonEnableShadow(self._ccbOwner.btn_autoAdd)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self:_init(options.actorId)
end



----------------------------------------
---父类重写部分

function QUIDialogSuperHeroGrade:viewDidAppear()
	QUIDialogSuperHeroGrade.super.viewDidAppear(self)
end

function QUIDialogSuperHeroGrade:viewWillDisappear()
  	QUIDialogSuperHeroGrade.super.viewWillDisappear(self)
end

function QUIDialogSuperHeroGrade:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    remote.superHeroGrade:onDialogClose()
end 


----------------------------------------
---私有部分

-- 初始化
function QUIDialogSuperHeroGrade:_init(actorId)
    self._ccbOwner.frame_tf_title:setString("魂师升星")
    self._progressWidth = self._ccbOwner.sp_bar_progress:getContentSize().width
    local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_pre_progress)
    self._preProgressStencil = progress:getStencil()
    local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_progress)
    self._progressStencil = progress:getStencil()

    self._richText = QRichText.new({}, 400, {autoCenter = true})
    self._richText:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_progress:addChild(self._richText)
    self._ccbOwner.tf_progress:setVisible(false)

    remote.superHeroGrade:setInfo(actorId)
    self:_checkOpenAutoAdd()
    self:_updateInfo()
end

-- 检查是否启动自动添加
function QUIDialogSuperHeroGrade:_checkOpenAutoAdd()
    local isOpen = remote.superHeroGrade:isOpenAutoAdd()
    self._ccbOwner.node_autoAdd:setVisible(isOpen)
    self._ccbOwner.node_auto_set:setVisible(isOpen)

    local btnPosX = 0
    if isOpen then
        btnPosX = 100
    end
    self._ccbOwner.btn_tupo:setPositionX(btnPosX)
end

-- 整体刷新
function QUIDialogSuperHeroGrade:_updateInfo()
    self._data = remote.superHeroGrade:updataAndGetData()
    self:_updateListView()
end

-- 设置魂师信息
function QUIDialogSuperHeroGrade:_setHeroInfo()
    local addGrade = remote.superHeroGrade:getAddGrade(true)
    local actorId = remote.superHeroGrade:getActorId()
    local heroInfo = remote.superHeroGrade:getHeroInfo()
	local _, color = remote.herosUtil:getBreakThrough(heroInfo.breakthrough)
	color = color or "white"
	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.hero_name1:setColor(fontColor)
	self._ccbOwner.hero_name2:setColor(fontColor)
	setShadowByFontColor(self._ccbOwner.hero_name1, fontColor)
	setShadowByFontColor(self._ccbOwner.hero_name2, fontColor)

	local oldHead = QUIWidgetHeroHead.new()
	local oldGrade = heroInfo.grade
	oldHead:setHeroSkinId(heroInfo.skinId)
	oldHead:setHero(actorId)
	oldHead:setStar(oldGrade)
	oldHead:hideSabc()
	oldHead:setBreakthrough(heroInfo.breakthrough)
    oldHead:setGodSkillShowLevel(heroInfo.godSkillGrade)
    self._ccbOwner.node_old_head:removeAllChildren()
	self._ccbOwner.node_old_head:addChild(oldHead)

		
    local heroName = db:getCharacterByID(actorId).name
    local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(oldGrade+1)
    self._ccbOwner.hero_name1:setString(heroName.."("..level..gardeName..")")


    local oldStringTilte = remote.herosUtil:getJobTitleByGradeLevelNum(oldGrade+1)
    self._ccbOwner.tf_old_value1:setString(oldStringTilte or "三界外")

    local oldHeroConfig = db:getGradeByHeroActorLevel(actorId, oldGrade)
	self._ccbOwner.tf_old_value2:setString(math.floor(oldHeroConfig.attack_value or 0))
	self._ccbOwner.tf_old_value3:setString(math.floor(oldHeroConfig.hp_value or 0))
	self._ccbOwner.tf_old_value4:setString(math.floor(oldHeroConfig.attack_grow or 0))
	self._ccbOwner.tf_old_value5:setString(math.floor(oldHeroConfig.hp_grow or 0))

    if addGrade < 1 then
        addGrade = 1
    end
    local newGrade = heroInfo.grade + addGrade
    local newHeroConfig = db:getGradeByHeroActorLevel(actorId, newGrade)
    if newHeroConfig then

        local newHead = QUIWidgetHeroHead.new()
        newHead:setHeroSkinId(heroInfo.skinId)
        newHead:setHero(actorId)
        newHead:setStar(newGrade)
        newHead:hideSabc()
        newHead:setBreakthrough(heroInfo.breakthrough)
        newHead:setGodSkillShowLevel(heroInfo.godSkillGrade)
        self._ccbOwner.node_new_head:removeAllChildren()
        self._ccbOwner.node_new_head:addChild(newHead)

        local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(newGrade+1)
        self._ccbOwner.hero_name2:setString(heroName.."("..level..gardeName..")")

        local newStringTilte = remote.herosUtil:getJobTitleByGradeLevelNum(newGrade+1)
        self._ccbOwner.tf_new_value1:setString(newStringTilte or "三界外")

        self._ccbOwner.tf_new_value2:setString(math.floor(newHeroConfig.attack_value or 0))
        self._ccbOwner.tf_new_value3:setString(math.floor(newHeroConfig.hp_value or 0))
        self._ccbOwner.tf_new_value4:setString(math.floor(newHeroConfig.attack_grow or 0))
        self._ccbOwner.tf_new_value5:setString(math.floor(newHeroConfig.hp_grow or 0))

        self._ccbOwner.arrow:setVisible(true);
        self._ccbOwner.node2:setVisible(true);
        self._ccbOwner.node1:setPositionX(-150);
    else

        self._ccbOwner.arrow:setVisible(false);
        self._ccbOwner.node2:setVisible(false);
        self._ccbOwner.node1:setPositionX(0);
    end


end

-- 更新显示方面信息
function QUIDialogSuperHeroGrade:_updateShowInfo()
    -- 魂师信息更新
    self:_setHeroInfo()

    -- 需求等级
    local isShow = (not remote.superHeroGrade:isMax())
    self._ccbOwner.icon_level:setVisible(isShow)
    self._ccbOwner.tf_level:setVisible(isShow)
    self._ccbOwner.tf_cur_level:setVisible(isShow)
    local needLevel = remote.superHeroGrade:getNeedLevel()
    self._ccbOwner.tf_level:setString("魂师"..needLevel.."级")
    self._ccbOwner.tf_level:setColor(COLORS.k)
    if remote.superHeroGrade:isLevelNotEnough() then
        self._ccbOwner.tf_level:setColor(COLORS.m)
    end

    -- 需求金币
    if remote.superHeroGrade:isSelectedEnough() then
        local needMoney = remote.superHeroGrade:getNeedMoney()
        self._ccbOwner.tf_money:setString(needMoney)
        self._ccbOwner.tf_money:setColor(COLORS.k)
        if remote.superHeroGrade:isMoneyNotEnough() then
            self._ccbOwner.tf_money:setColor(COLORS.m)
        end
    else
        isShow = false
    end
    self._ccbOwner.tf_money:setVisible(isShow)
    self._ccbOwner.icon_money:setVisible(isShow)


    -- 需求金币和需求等级icon位置更新
    local moneyTfPosX = self._ccbOwner.tf_money:getPositionX()
    local moneyTfContentWidth = self._ccbOwner.tf_money:getContentSize().width
    local levelTfContentWidth = self._ccbOwner.tf_level:getContentSize().width
    local offsetWidth = levelTfContentWidth
    if offsetWidth < moneyTfContentWidth and self._ccbOwner.tf_money:isVisible() then
        offsetWidth = moneyTfContentWidth
    end
    local newPosX = moneyTfPosX - offsetWidth - 20
    self._ccbOwner.icon_money:setPositionX(newPosX)
    self._ccbOwner.tf_cur_level:setPositionX(newPosX)
    self._ccbOwner.icon_level:setPositionX(newPosX)

    -- 摘除按钮
    self._ccbOwner.btn_reset:setVisible(remote.superHeroGrade:isShowReset())

    -- 进度条
    self:_updateExpProgress()
end

-- 更新经验条
function QUIDialogSuperHeroGrade:_updateExpProgress()
    local isMax = remote.superHeroGrade:isMax()
    local curExp = remote.superHeroGrade:getCurExp()
    local consumeExp = remote.superHeroGrade:getConsumeExp()
    local addExp = remote.superHeroGrade:getAddExp()
    local addGrade = remote.superHeroGrade:getAddGrade(true)

    self._ccbOwner.tf_progress:setVisible(isMax)
    self._ccbOwner.node_progress:setVisible(not isMax)
    if isMax then
        self._ccbOwner.tf_progress:setString("MAX")
        self._progressStencil:setPositionX(0)
        self._preProgressStencil:setPositionX(0)
        return
    end

    local richTextContent = {}
    local curValue = curExp/consumeExp
    local tempValue = (addExp+curExp)/consumeExp
    if tempValue >= 1 then
        tempValue = 1
    end

    if addExp > 0 then
        table.insert(richTextContent, {oType = "font", content = curExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal})
        table.insert(richTextContent, {oType = "font", content = "+"..addExp, size = 18, color = GAME_COLOR_SHADOW.property, strokeColor = GAME_COLOR_LIGHT.normal})
        table.insert(richTextContent, {oType = "font", content = "/"..consumeExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal})
        if addGrade > 0 then
            table.insert(richTextContent, {oType = "font", content = "（升" .. addGrade .. "星）", size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal})
        end
    else
        table.insert(richTextContent, {oType = "font", content = curExp.."/"..consumeExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal})
    end
    self._richText:setString(richTextContent)
    self._ccbOwner.tf_progress:setString((addExp+curExp).."/"..consumeExp)
    self._progressStencil:setPositionX(curValue*self._progressWidth - self._progressWidth)
    self._preProgressStencil:setPositionX(tempValue*self._progressWidth - self._progressWidth)
end

-- 更新itemWidget的显示
function QUIDialogSuperHeroGrade:_updateListItemInfo(isRefreshAll)
    if isRefreshAll then
        for i = 1, #self._data do 
            local item = self._listView:getItemByIndex(i)
            if item then
                item:setInfo(self._data[i])
            end
        end
    else
        local curIndex = self._listView:getCurTouchIndex()
        if curIndex and curIndex > 0 then
            local item = self._listView:getItemByIndex(curIndex)
            item:setInfo(self._data[curIndex])
        end
    end
    self:_updateShowInfo()
end

-- 更新listView
function QUIDialogSuperHeroGrade:_updateListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
	     	ignoreCanDrag = true,
	     	enableShadow = false,
	     	isVertical = false,
	        spaceX = 10,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
    self:_updateShowInfo()
end

-- listView渲染回调
function QUIDialogSuperHeroGrade:_renderItemCallBack(list, index, info)
    -- body
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetItemsBoxEnchant.new()
    	item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_CLICK, handler(self, self.itemClickHandler))
    	item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK, handler(self, self.itemMinusClickHandler))
        isCacheNode = false
    end
    item:setInfo(data)
    item:checkNeedItem()
    item:setScale(0.8)
    item:setNameVisibility(false)
    info.item = item
    info.size = CCSize(item:getContentSize().width*0.8,item:getContentSize().height*0.8)
    info.offsetPos = ccp(45, -43)

    list:registerTouchHandler(index, "onTouchListView")

    return isCacheNode
end

-- 添加碎片成功的动画
function QUIDialogSuperHeroGrade:_levelUpAni()
    app.sound:playSound("equipment_enhance")
    local fcaAnimation = QUIWidgetFcaAnimation.new("fca/hunling_tsbao1", "res")
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(fcaAnimation)
    fcaAnimation:playAnimation("animation", false)
    fcaAnimation:setScaleX(1.5)
    fcaAnimation:setPositionY(-10)
end

-- 选中动画
function QUIDialogSuperHeroGrade:_showSelectAnimation(itemId, itemWidget)
    local icon = QUIWidgetItemsBoxEnchant.new(true)
    icon:setGoodsInfo(itemId, ITEM_TYPE.ITEM, 0, false)
    icon:setNameVisibility(false)

    local p = itemWidget:convertToWorldSpaceAR(ccp(-display.width/2, -display.height/2))
    icon:setPosition(p.x, p.y)
    icon:setScale(0.8)
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(icon)

    local effectPosX, effectPosY  = self._ccbOwner.node_effect:getPosition()
    local targetP = ccp(effectPosX, effectPosY+80)
    local arr = CCArray:create()
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.endPosition = targetP
    bezierConfig.controlPoint_1 = ccp(p.x + (targetP.x - p.x) * 0.333, p.y + (targetP.y- p.y) * 0.8)
    bezierConfig.controlPoint_2 = ccp(p.x + (targetP.x - p.x) * 0.667, p.y + (targetP.y- p.y) * 1)

    local bezierTo = CCBezierTo:create(0.4, bezierConfig)
    arr:addObject(CCSpawn:createWithTwoActions(bezierTo, CCDelayTime:create(0.2)))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParent()
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(seq)
end




----------------------------------------
---交互回调部分

-- 背景被点击
function QUIDialogSuperHeroGrade:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭被点击
function QUIDialogSuperHeroGrade:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	if event then
  		app.sound:playSound("common_close")
  	end
	self:playEffectOut()
end

-- 降星被点击
function QUIDialogSuperHeroGrade:_onTriggerReset(event)
    app.sound:playSound("common_small")

    remote.superHeroGrade:onReset(function(data)
        remote.user:update(data.wallet)
        if data.items then remote.items:setItems(data.items) end

        if self:safeCheck() then
            self:_updateInfo()
        end
        -- 展示奖励页面
        if data.heroGradeReturnResponse then
            local awards = {}
            local tbl = string.split(data.heroGradeReturnResponse.recoverItemInfo or "", ";")
            for _, awardStr in pairs(tbl or {}) do

                local id, typeName, count = remote.rewardRecover:getItemBoxParaMetet(awardStr)
                if tonumber(count) > 0 then
                    if id then
                        print("id :"..id.."value"..count)
                        table.insert(awards, {id = id, value = count})
                    elseif typeName then
                        print("id :"..typeName.."value"..count)
                        if "glyphs" == typeName then 
                            typeName = "glyphMoney"
                        end
                        
                        table.insert(awards, {id = typeName, value = count})
                    end
                end

            end
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                options = {compensations = awards, type = 13, subtitle = "重生返还以下道具"}}, {isPopCurrentDialog = false})
        end
    end)
end

-- 设置被点击
function QUIDialogSuperHeroGrade:_onTriggerSet(event)
    app.sound:playSound("common_small")
    remote.superHeroGrade:onSet()
end

-- 一键添加被点击
function QUIDialogSuperHeroGrade:_onTriggertAutoAdd(event)
    app.sound:playSound("common_small")
    remote.superHeroGrade:autoSelect()
    self:_updateListItemInfo(true)
end

-- 帮助被点击
function QUIDialogSuperHeroGrade:_onTriggerHelp(event)
    app.sound:playSound("common_small")
    remote.superHeroGrade:onHelp()
end

-- 升星被点击
function QUIDialogSuperHeroGrade:_onTriggerAdvance(event)
    app.sound:playSound("common_small")

    local needClose = remote.superHeroGrade:onAdvance(function()
        if self:safeCheck() then
            self:_updateInfo()
            self:_levelUpAni()
        end
    end)
    
    if needClose then
        self:_onTriggerClose()
    end
end

-- item碎片被点击
function QUIDialogSuperHeroGrade:itemClickHandler(event)
    remote.superHeroGrade:onAddItem(event, function()
        self:_showSelectAnimation(event.itemID, event.source)
        self:_updateListItemInfo()
    end)
end

-- item碎片减选被点击
function QUIDialogSuperHeroGrade:itemMinusClickHandler(event)
    remote.superHeroGrade:onMinusItem(event, function()
        self:_updateListItemInfo()
    end)
end

return QUIDialogSuperHeroGrade
