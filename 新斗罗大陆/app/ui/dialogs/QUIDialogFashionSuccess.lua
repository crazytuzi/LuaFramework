--
-- Kumo.Wang
-- 時裝衣櫃统一成功界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFashionSuccess = class("QUIDialogFashionSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")
local QRichText = import("...utils.QRichText")
local QActorProp = import("...models.QActorProp")

function QUIDialogFashionSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Fashion_Success.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
    QUIDialogFashionSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("task_complete")

    if options then
        self._callback = options.callback
        self._id = options.id
        self._type = options.type -- 寶錄or繪卷
    end

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    self._ccbOwner.node_rtf_prop:removeAllChildren()
    local rtf = QRichText.new(nil, 220, {autoCenter = false})
    rtf:setAnchorPoint(ccp(0.5, 1))
    self._ccbOwner.node_rtf_prop:addChild(rtf)
    local textTbl = {}

    if self._id and self._type then
        if self._type == remote.fashion.FUNC_TYPE_FASHION_COMBINATION then
            -- 繪卷
            QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("fashionCombinationTitle"))
            QSetDisplayFrameByPath(self._ccbOwner.sp_icon, QResPath("fashionCombinationIcon"))
            self._ccbOwner.tf_icon_name:setString("羁绊绘卷")
            self._ccbOwner.tf_action_name:setString("绘卷天赋激活：")

            local configs = db:getStaticByName("skins_combination_skills")
            for _, config in pairs(configs) do
                if tostring(config.id) == tostring(self._id) then
                    self._ccbOwner.tf_name:setString(config.name)
                    self._ccbOwner.tf_name_small:setString("【"..config.name.."】")

                    local characterTbl = string.split(config.character_skins, ";")
                    local allCharacterNameStr = ""
                    if characterTbl and #characterTbl > 0 then
                        for _, id in pairs(characterTbl) do
                            local skinConfig = remote.fashion:getSkinConfigDataBySkinId(id)
                            if skinConfig then
                                local characterConfig = db:getCharacterByID(skinConfig.character_id)
                                if characterConfig then
                                    if characterConfig.name then
                                        if allCharacterNameStr ~= "" then
                                            allCharacterNameStr = allCharacterNameStr.."和"
                                        end
                                        allCharacterNameStr = allCharacterNameStr..characterConfig.name
                                    end
                                end
                            end
                        end
                    end

                    for key, value in pairs(config) do
                        local propFields = QActorProp:getPropFields()
                        if propFields[key] then
                            if #textTbl ~= 0 then
                                table.insert(textTbl, {oType = "wrap"})
                            end
                            local nameStr = propFields[key].uiName or propFields[key].name
                            local num = tonumber(value)
                            if propFields[key].isPercent then
                                num = (num * 100).."%"
                            end
                            if key == "enter_rage" and allCharacterNameStr and allCharacterNameStr ~= "" then
                                table.insert(textTbl, {oType = "font", content = allCharacterNameStr..nameStr.."："..num, size = 20, color = COLORS.b})
                            else
                                table.insert(textTbl, {oType = "font", content = "全队"..nameStr.."："..num, size = 20, color = COLORS.b})
                                -- table.insert(textTbl, {oType = "font", content = nameStr.."：", size = 20, color = COLORS.b})
                                -- table.insert(textTbl, {oType = "font", content = "+ "..num, size = 20, color = COLORS.c})
                            end
                        end
                    end
                    break
                end
            end
        else
            -- 寶籙
            QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("fashionTitle"))
            QSetDisplayFrameByPath(self._ccbOwner.sp_icon, QResPath("fashionIcon"))
            self._ccbOwner.tf_icon_name:setString("时装宝录")
            self._ccbOwner.tf_action_name:setString("宝录天赋激活：")

            local configs = db:getStaticByName("skins_wardrobe_prop")
            for _, config in pairs(configs) do
                if tostring(config.id) == tostring(self._id) then
                    self._ccbOwner.tf_name:setString(config.name)
                    self._ccbOwner.tf_name_small:setString("【"..config.name.."】")

                    if config.desc then
                        local strText = config.desc or ""
                        local tbl = string.split(strText, "\n")
                        for _, v in ipairs(tbl) do
                            if #textTbl ~= 0 then
                                table.insert(textTbl, {oType = "wrap"})
                            end
                            table.insert(textTbl, {oType = "font", content = v, size = 20, color = COLORS.b})
                            -- local _tbl = string.split(v, "+")
                            -- table.insert(textTbl, {oType = "font", content = _tbl[1].."：", size = 20, color = COLORS.b})
                            -- table.insert(textTbl, {oType = "font", content = "+ ".._tbl[2], size = 20, color = COLORS.c})
                        end
                    end
                    break
                end
            end
        end
    end
    rtf:setString(textTbl)


    self._isSelected = false
	self._ccbOwner.node_select:setVisible(false)
	self._playOver = false
	scheduler.performWithDelayGlobal(function ()
		self._playOver = true
	end, 2)
end

function QUIDialogFashionSuccess:viewDidAppear()
	QUIDialogFashionSuccess.super.viewDidAppear(self)
end

function QUIDialogFashionSuccess:viewWillDisappear()
  	QUIDialogFashionSuccess.super.viewWillDisappear(self)
end

function QUIDialogFashionSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not self._isSelected)
end

function QUIDialogFashionSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogFashionSuccess:_backClickHandler()
	if self._playOver == true then
		self:playEffectOut()
	end
end

function QUIDialogFashionSuccess:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback ~= nil then
		callback()
	end
	
end

return QUIDialogFashionSuccess
