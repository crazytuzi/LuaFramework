--[[	
	文件名称：QUIDialogSocietyGaiming.lua
	创建时间：2016-04-08 15:29:57
	作者：nieming
	描述：QUIDialogSocietyGaiming
]]

local QUIDialog = import(".QUIDialog")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogSocietyGaiming = class("QUIDialogSocietyGaiming", QUIDialog)

local QMaskWords = import("...utils.QMaskWords")

local QStaticDatabase = import("...controllers.QStaticDatabase")

--初始化quid
function QUIDialogSocietyGaiming:ctor(options)
	local ccbFile = "Dialog_society_gaiming.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyGaiming._onTriggerClose)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogSocietyGaiming._onTriggerConfirm)},
	}
	QUIDialogSocietyGaiming.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self.isAnimation = true --是否动画显示

	self._unionName = ui.newEditBox({image = "ui/none.png", listener = handler(self, self.onEdit), size = CCSize(400, 48)})
    self._unionName:setFont(global.font_default, 26)
   
    self._defaultPrompt = "请输入宗门名"
    self._unionName:setMaxLength(7)

    self._unionName:setPlaceHolder(self._defaultPrompt)
    if options.word then
        self._unionName:setText(options.word)
    end
    self._unionName:setVisible(true)
    self._ccbOwner.editBox:addChild(self._unionName)

    if (remote.union.consortia and remote.union.consortia.nameChangeCount or 0) == 0 then
        self._ccbOwner.gold:setString("免费")
        self._ccbOwner.gold:setPositionX(self._ccbOwner.gold:getPositionX()-40)
        self._ccbOwner.sp_token:setVisible(false)
    else
        local gold = db:getConfigurationValue("MODIFICATION_NAME")
        self._ccbOwner.gold:setString(gold or "")
        self._ccbOwner.sp_token:setVisible(true)
    end

    self._ccbOwner.frame_tf_title:setString("修改宗门名称")
end

function QUIDialogSocietyGaiming:onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then

    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end
--describe：
function QUIDialogSocietyGaiming:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	--代码
	self:playEffectOut()
end

--describe：
function QUIDialogSocietyGaiming:_onTriggerConfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	--代码
	local newName = self._unionName:getText()
    if self:_invalidNames(newName) then
        return
    end

    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if self:getOptions().confirmCallback then
        self:getOptions().confirmCallback(newName)
    end

end

--describe：viewAnimationOutHandler 
function QUIDialogSocietyGaiming:viewAnimationOutHandler()
	--代码
end

function QUIDialogSocietyGaiming:_invalidNames(newName)
    local nameLen = string.utf8len(newName)
    if newName == "" then
        app.tip:floatTip("宗门名不能为空")
        return true
    elseif tonumber(newName) then
    	app.tip:floatTip("宗门名不能全部由数字构成")
        return true
    elseif QMaskWords:isFind(newName) then
        app.tip:floatTip("包含无效的字符")
        return true
    elseif nameLen > 7 then
        app.tip:floatTip("宗门名字太长~")
        return true
    else
        return false
    end
end

function QUIDialogSocietyGaiming:_backClickHandler()
    self:_onTriggerClose()
end


function QUIDialogSocietyGaiming:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end



return QUIDialogSocietyGaiming
