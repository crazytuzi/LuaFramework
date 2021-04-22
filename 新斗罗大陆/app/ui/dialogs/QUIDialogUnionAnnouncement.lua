--
-- Author: qinyuanji
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionAnnouncement = class("QUIDialogUnionAnnouncement", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QMaskWords = import("...utils.QMaskWords")

QUIDialogUnionAnnouncement.INVALID_INPUT_ERROR = "包含无效的字符"
QUIDialogUnionAnnouncement.NO_INPUT_ERROR = "内容不能为空"
QUIDialogUnionAnnouncement.DEFAULT_ANNOUNCEMENT = "请输入宗门公告"
QUIDialogUnionAnnouncement.DEFAULT_UNION_NOTICE = "请输入宗门宣言"
QUIDialogUnionAnnouncement.DEFAULT_UNION_LEAVE_MESSAGE = "请输入留言内容"
QUIDialogUnionAnnouncement.DEFAULT_UNION_MASS_MAIL = "请输入邮件内容"

QUIDialogUnionAnnouncement.DEFAULT_NAME = "请输入宗门名"
QUIDialogUnionAnnouncement.DEFAULT_ARENA_WORD = "请输入我的宣言"
QUIDialogUnionAnnouncement.DEFAULT_ADD_FRIEND_WORD = "请输入玩家名称"
QUIDialogUnionAnnouncement.DEFAULT_MAIL_WORD = "最多输入80个字符"

QUIDialogUnionAnnouncement.TYPE_UNION_ANNOUNCEMENT = "TYPE_UNION_ANNOUNCEMENT" --宗门公告
QUIDialogUnionAnnouncement.TYPE_UNION_NOTICE = "TYPE_UNION_NOTICE" --宗门宣言
QUIDialogUnionAnnouncement.TYPE_UNION_LEAVE_MESSAGE = "TYPE_UNION_LEAVE_MESSAGE" --宗门留言
QUIDialogUnionAnnouncement.TYPE_UNION_MASS_MAIL = "TYPE_UNION_MASS_MAIL" --群发邮件
QUIDialogUnionAnnouncement.TYPE_UNION_RECRUIT = "TYPE_UNION_RECRUIT" --宗门招募

QUIDialogUnionAnnouncement.TYPE_UNION_NAME = "TYPE_UNION_NAME" --宗门名字
QUIDialogUnionAnnouncement.TYPE_ARENA_WORD = "TYPE_ARENA_WORD" --斗魂场宣言
QUIDialogUnionAnnouncement.TYPE_ADD_FRIEND = "TYPE_ADD_FRIEND" --添加好友
QUIDialogUnionAnnouncement.TYPE_MAIL = "TYPE_MAIL" --邮件

local forbidden_char = {"一","二","三","四","五","六","七","八","九","壹","贰","叁","肆","伍","陆","柒","捌","玖","零","1","2","3","4","5","6","7","8","9","0","㈠",
"㈡","㈢","㈣","㈤","㈥","㈦","㈧","㈨","㈩","①","②","③","④","⑤","⑥","⑦","⑧","⑨","⑩","⑪","⑫","⑬","⑭","⑮","⑯","⑰","⑱","⑲","⑳","㊀","㊁","㊂","㊃","㊄",
"㊅","㊆","①","②","③","④","⑤","⑥","⑦","⑧","⑨","⑩","⑪","⑫","⑬","⑭","⑮","⑯","⑰","⑱","⑲","⑳","㉑","㉒","㉓","㉔","㉕","㉖","㉗","㉘","㉙","㉚","㉛","㉜",
"㉝","㉞","㉟","㊱","㊲","㊳","㊴","㊵","㊶","㊷","㊸","㊹","㊺","㊻","㊼","㊽","㊾","㊿","⓪","❶","❷","❸","❹","❺","❻","❼","❽","❾","❿","⑴","⑵","⑶","⑷","⑸","⑹",
"⑺","⑻","⑼","⑽","㈠","㈡","㈢","㈣","㈤","㈥","㈦","㈧","㈨","㈩","㊀","㊁","㊂","㊃","㊄","㊅","㊆","㊇","㊈","㊉","１","２","３","４","５","６","７","８","９","０",
"Ⅰ","Ⅱ","Ⅲ","Ⅳ","Ⅴ","Ⅵ","Ⅶ","Ⅷ","Ⅸ","Ⅹ","Ⅺ","Ⅻ","ⅰ","ⅱ","ⅲ","ⅳ","ⅴ","ⅵ","ⅶ","ⅷ","ⅸ","ⅹ","ⅺ","ⅻ","㉈","㉉","㉊","㉋","㉌","㉍","㉎","㉏",
"⒈","⒉","⒊","⒋","⒌","⒍","⒎","⒏","⒐",
"º","¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹", 
"₀","₁","₂","₃","₄","₅","₆","₇","₈","₉",
"｜","O","o","仈","氿","彡","Q","q",}

local forbidden_count = 5

function QUIDialogUnionAnnouncement:ctor(options)
    local ccbFile = "ccb/Dialog_society_union_fixname.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogUnionAnnouncement._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogUnionAnnouncement._onTriggerClose)},
    }
    QUIDialogUnionAnnouncement.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    if options.type == nil then
        assert(false, "QUIDialogUnionAnnouncement options type is nil!")
        return
    end

    self._isChanged = false
    -- add input box
    self._unionName = ui.newEditBox({image = "ui/none.png", listener = handler(self, self.onEdit), size = CCSize(400, 40)})
    self._unionName:setFont(global.font_name, 20)
    self._unionName:setFontColor(UNITY_COLOR.brown)
    self._unionName:setPlaceholderFontColor(UNITY_COLOR.brown)
    if options.type == QUIDialogUnionAnnouncement.TYPE_UNION_ANNOUNCEMENT then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_ANNOUNCEMENT
        self._ccbOwner.frame_tf_title:setString("修改公告")
        self._unionName:setMaxLength(40)
    elseif options.type == QUIDialogUnionAnnouncement.TYPE_UNION_NOTICE then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_UNION_NOTICE
        self._unionName:setMaxLength(40)
        self._ccbOwner.frame_tf_title:setString("修改宣言")
     elseif options.type == QUIDialogUnionAnnouncement.TYPE_UNION_LEAVE_MESSAGE then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_UNION_LEAVE_MESSAGE
        self._unionName:setMaxLength(30)
        self._ccbOwner.frame_tf_title:setString("留言")
    elseif options.type == QUIDialogUnionAnnouncement.TYPE_UNION_NAME then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_NAME
        self._unionName:setMaxLength(6)
        self._ccbOwner.frame_tf_title:setString("修改宗门名")
    elseif options.type == QUIDialogUnionAnnouncement.TYPE_ARENA_WORD then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_ARENA_WORD
        self._unionName:setMaxLength(15)
        self._ccbOwner.frame_tf_title:setString("修改宣言")
    elseif options.type == QUIDialogUnionAnnouncement.TYPE_ADD_FRIEND then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_ADD_FRIEND_WORD
        self._unionName:setMaxLength(7)
        self._ccbOwner.frame_tf_title:setString("添加好友")
    elseif options.type == QUIDialogUnionAnnouncement.TYPE_MAIL then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_MAIL_WORD
        self._unionName:setMaxLength(80)
        self._ccbOwner.frame_tf_title:setString("发送邮件")
    elseif options.type == QUIDialogUnionAnnouncement.TYPE_UNION_MASS_MAIL then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_UNION_MASS_MAIL
        self._unionName:setMaxLength(80)
        self._ccbOwner.frame_tf_title:setString("宗门邮件")
    elseif options.type == QUIDialogUnionAnnouncement.TYPE_UNION_RECRUIT then
        self._defaultPrompt = QUIDialogUnionAnnouncement.DEFAULT_UNION_RECRUIT
        self._unionName:setMaxLength(30)
        self._ccbOwner.frame_tf_title:setString("宗门招募")
    end
    
    self._unionName:setPlaceHolder(self._defaultPrompt)
    if options.word then
        self._unionName:setText(options.word)
    end
    self._unionName:setVisible(true)
    self._ccbOwner.name:addChild(self._unionName)
end


function QUIDialogUnionAnnouncement:viewDidAppear()
    QUIDialogUnionAnnouncement.super.viewDidAppear(self)
end

function QUIDialogUnionAnnouncement:viewWillDisappear()
    QUIDialogUnionAnnouncement.super.viewWillDisappear(self)
    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
end

function QUIDialogUnionAnnouncement:viewAnimationInHandler()
end

function QUIDialogUnionAnnouncement:onEdit(event, editbox)
    self._isChanged = true
    if event == "began" then
    elseif event == "changed" then
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

function QUIDialogUnionAnnouncement:_onTriggerConfirm(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_confirm) == false then return end
    app.sound:playSound("common_small")
    local newName = self._unionName:getText()
    if self:_invalidNames(newName) then
        return
    end
    if self:getOptions().type == QUIDialogUnionAnnouncement.TYPE_UNION_RECRUIT then
        if not self:messageValid(newName) then
            app.tip:floatTip("包含非法字符无法发送！")
            return
        end
    end
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if self:getOptions().confirmCallback then
        self:getOptions().confirmCallback(newName)
    end
end

function QUIDialogUnionAnnouncement:_invalidNames(newName)
    if self:getOptions().type == QUIDialogUnionAnnouncement.TYPE_UNION_NAME then
        if tonumber(newName) then
            app.tip:floatTip("宗门名不能全部由数字构成")
            return true
        end
        
    end
    if newName == "" then
        app.tip:floatTip(QUIDialogUnionAnnouncement.NO_INPUT_ERROR)
        return true
        -- end
    elseif QMaskWords:isFind(newName) then
        app.tip:floatTip(QUIDialogUnionAnnouncement.INVALID_INPUT_ERROR)
        return true
    else
        return false
    end
end

function QUIDialogUnionAnnouncement:messageValid(msg)
    local count = 0
    for _, v in ipairs(forbidden_char) do
        for w in string.gmatch(msg, v) do
            count = count + 1
        end
    end

    if count >= forbidden_count then
        return false
    else
        return true
    end
end

function QUIDialogUnionAnnouncement:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogUnionAnnouncement:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_small")
    self:playEffectOut()
end

function QUIDialogUnionAnnouncement:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogUnionAnnouncement 