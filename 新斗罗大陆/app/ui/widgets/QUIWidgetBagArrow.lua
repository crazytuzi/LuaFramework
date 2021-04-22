--
--  zxs
--  段位icon
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBagArrow = class("QUIWidgetBagArrow", QUIWidget)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetBagArrow:ctor(options)
    local ccbFile = "ccb/Widget_Bag_Arr.ccbi"
    options = options or {}
    local callBacks = {
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
    }
    QUIWidgetBagArrow.super.ctor(self,ccbFile,callBacks,options)

   self._packs = options.packs or {}
    -- if app.unlock:getUnlockGemStone() 
    --     or remote.gemstone:checkGemstoneBackPackItemNum() 
    --     or remote.spar:checkSparBackPackItemNum() then
    --     -- 2：魂骨、晶石
    --     -- table.insert(packs, #packs+1)
    --     table.insert(self._packs, 2)
    -- end
    -- if remote.soulSpirit:checkSoulSpiritUnlock() or remote.soulSpirit:checkSoulSpiritPackItemNum() then
    --     -- 3：魂灵
    --     -- table.insert(packs, #packs+1)
    --     table.insert(self._packs, 3)
    -- end
    
    -- if remote.godarm:checkGodArmUnlock() or remote.godarm:checkGodArmbBackPackItemNum() then
    --     table.insert(self._packs, 4)
    -- end

    -- if remote.magicHerb:checkMagicHerbUnlock() or remote.magicHerb:checkMagicHerbBackPackItemNum() then
    --     -- 4：仙品
    --     -- table.insert(packs, #packs+1)
    --     table.insert(self._packs, 5)
    -- end

    self._ccbOwner.node_right:setVisible(#self._packs > 1)
    self._ccbOwner.node_left:setVisible(#self._packs > 1)

end

function QUIWidgetBagArrow:setBagTag(tag)
    self._cur_tag = tag or 1
end

function QUIWidgetBagArrow:_onTriggerRight(event)
    print("_onTriggerRight  self._cur_tag",self._cur_tag,#self._packs)
    local tag_ = 1
    if self._cur_tag > #self._packs then
        self._cur_tag = #self._packs
    end

    if self._cur_tag ~= #self._packs then
        tag_ = self._cur_tag + 1
    end
    tag_ = self._packs[tag_]
    self:ChangeBagByTag(tag_)
end


function QUIWidgetBagArrow:_onTriggerLeft(event)
    print("_onTriggerLeft  ")
    local tag_ = #self._packs

    if self._cur_tag > #self._packs then
        self._cur_tag = #self._packs
    end
    if self._cur_tag ~= 1 then
        tag_ = self._cur_tag - 1
    end
    tag_ = self._packs[tag_]
    self:ChangeBagByTag(tag_)
end


function QUIWidgetBagArrow:ChangeBagByTag(tag )

    print("ChangeBagByTag tag = "..tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    if tag == 1 then
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBackpack",options = {packs = self._packs}})
    elseif tag == 2 then
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack",options = {packs = self._packs}})
    elseif tag == 3 then
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSoulSpiritBackpack",options = {packs = self._packs}})
    elseif tag == 4 then
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodarmBackpack",options = {packs = self._packs}})
    elseif tag == 5 then
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMagicHerbBackpack",options = {packs = self._packs}})        
    end 
end


return QUIWidgetBagArrow
