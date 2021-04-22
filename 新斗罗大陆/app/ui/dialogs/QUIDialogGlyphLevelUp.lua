--
-- Author: Kumo.Wang
-- Date: Sat Apr 30 17:31:41 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGlyphLevelUp = class("QUIDialogGlyphLevelUp", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetGlyphClientCell = import("..widgets.QUIWidgetGlyphClientCell")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogGlyphLevelUp:ctor(options)
	local ccbFile = "ccb/Dialog_DiaoWen_shengji.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogGlyphLevelUp._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
    QUIDialogGlyphLevelUp.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

    self._callBackFun = options.callBack
    self._successTip = options.successTip
    self._addLevel = options.addlevel or 1
    self.aniPlayer = options.aniPlayer
    self.actionPlaying = true
    
    local titleWidget = QUIWidgetTitelEffect.new()
    self._ccbOwner.node_title_effect:addChild(titleWidget)

    local oldConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(options.skillId, options.oldLevel)
    local oldIcon = QUIWidgetGlyphClientCell.new()
    oldIcon:setSkill( options.skillId, options.oldLevel )
    oldIcon:setEnabled(false)
    self._ccbOwner.node_old_icon:addChild( oldIcon )
    local str1 = self:_getExplainBySkillConfig(oldConfig)
    -- self._ccbOwner.tf_old_explain:setString(oldConfig.level_describle)
    self._ccbOwner.tf_old_explain:setString(str1)

    local newConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(options.skillId, options.oldLevel + self._addLevel)
    local newIcon = QUIWidgetGlyphClientCell.new()
    newIcon:setSkill( options.skillId, options.oldLevel + self._addLevel )
    newIcon:setEnabled(false)
    scheduler.performWithDelayGlobal(self:safeHandler(function ()
        newIcon:showEffect()
        self.actionPlaying = false
    end), 40/30)
    self._ccbOwner.node_new_icon:addChild( newIcon )
    local str2 = self:_getExplainBySkillConfig(newConfig)
    -- self._ccbOwner.tf_new_explain:setString(newConfig.level_describle)
    self._ccbOwner.tf_new_explain:setString(str2)

    app.sound:playSound("hero_grow_up")

    self._isSelected = false
    self:showSelectState()
    self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
end

function QUIDialogGlyphLevelUp:_getExplainBySkillConfig( skillLevelConfig )
    local tbl = {}
    local str = ""
    -- local findMagicKey = 0
    -- local findPhysicsKey = 0
    for name, filed in pairs(QActorProp._field) do
        if skillLevelConfig[name] then
            -- print("[Kumo] QUIDialogGlyphLevelUp:_getExplainBySkillConfig() ", name, skillLevelConfig[name], skillLevelConfig.glyph_level, skillLevelConfig.glyph_name)
            local strName = filed.name
            -- print(strName)
            -- if string.find(strName, "法术") then
                -- findMagicKey = findMagicKey + 1
            strName = string.gsub(strName, "法术", "")
            strName = string.gsub(strName, "法防", "防御")
            -- end
            -- if string.find(strName, "物理") then
                -- findPhysicsKey = findPhysicsKey + 1
            strName = string.gsub(strName, "物理", "")
            strName = string.gsub(strName, "物防", "防御")
            -- end
            strName = string.gsub(strName, "百分比", "")
            strName = string.gsub(strName, "全队PVP", "PVP")
            -- print(strName)
            local strNum = tostring(skillLevelConfig[name])
            -- print(string.find(strNum, "%."))
            if string.find(strNum, "%.") then
                -- 数据是百分比
                strNum = (skillLevelConfig[name] * 100).."%"
            end

            -- 防止重复，同时，让类似魔法防御和物理防御这样的成对属性合并成防御属性
            local isNew = true
            for _, value in pairs(tbl) do
                -- print("[Kumo] QUIDialogGlyphLevelUp:_getExplainBySkillConfig() ", value, strName, strNum, string.len(strName))
                if string.len(strName) < 12 then
                    -- 不换行
                    if value == strName.." + "..strNum then
                        -- print("==================> isNew = false")
                        isNew = false
                    end
                else
                    -- 换行
                    if value == strName.."\n + "..strNum then
                        -- print("==================> isNew = false")
                        isNew = false
                    end
                end
            end

            if isNew then
                if string.len(strName) < 12 then
                    -- 不换行
                    table.insert(tbl, strName.." + "..strNum)
                else
                    -- 换行
                    table.insert(tbl, strName.."\n + "..strNum)
                end
            end
        end
    end

    for index, value in pairs(tbl) do
        if index == #tbl then
            str = str..value
            break
        end
        str = str..value.."\n"
    end

    -- return tbl
    return str
end

function QUIDialogGlyphLevelUp:viewDidAppear()
	QUIDialogGlyphLevelUp.super.viewDidAppear(self)
end

function QUIDialogGlyphLevelUp:viewWillDisappear()
  	QUIDialogGlyphLevelUp.super.viewWillDisappear(self)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogGlyphLevelUp:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogGlyphLevelUp:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogGlyphLevelUp:_backClickHandler()
    -- if self.actionPlaying and self.aniPlayer then
    --     self.aniPlayer:stopAnimation()
    --     -- self.actionPlaying = false
    -- else
    --     self:_onTriggerConfirm()
    -- end
    if not self.actionPlaying then
        self:_onTriggerConfirm()
    end
end

function QUIDialogGlyphLevelUp:_onTriggerConfirm()
	local callback = self._callBackFun
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback()
    end
    if self._isSelected == true then
        app.master:setMasterShowState(self._successTip)
    end
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.class.__cname == "QUIPageMainMenu" then
		printInfo("call QUIPageMainMenu function checkGuiad()")
		page:checkGuiad()
	end
end

return QUIDialogGlyphLevelUp