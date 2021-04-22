--
-- Author: Your Name
-- Date: 2015-01-14 11:50:04
--
local QBaseModel = import("..models.QBaseModel")
local QMails = class("QMails",QBaseModel)
local QLogFile = import(".QLogFile")
local QStaticDatabase = import("..controllers.QStaticDatabase")

QMails.MAILS_UPDATE_EVENT = "MAILS_UPDATE_EVENT"
QMails.MAILS_UPDATE_AVATAR_EVENT = "MAILS_UPDATE_AVATAR_EVENT"

QMails.ENUM_ALL = 0
QMails.ENUM_AWARDS = 1
QMails.ENUM_NO_AWARDS = 2
QMails.ENUM_UNION_MAIL = 3

function QMails:ctor(options)
    QMails.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._mails = {}
    self._mailsId = {}
    self._totalCount = 0
    self._notReadTotal = 0
    -- self._offset = 0
end

--创建时初始化事件
function QMails:didappear()
    self._markProxy = cc.EventProxy.new(remote.mark)
    self._markProxy:addEventListener(remote.mark.EVENT_UPDATE, handler(self, self.markUpdateHandler))
end

--创建时初始化事件
function QMails:disappear()
    if self._markProxy then
        self._markProxy:removeAllEventListeners()
    end
end

--获取目前前端的所有邮件列表
function QMails:getMails(mailTab)
    if mailTab == nil then mailTab = QMails.ENUM_ALL end

    local awardsMails = {}
    local systemMails = {}
    local unionMails = {}
    for _, mail in pairs(self._mails) do
        if ( mail.awards ~= nil and next(mail.awards) ~= nil ) or ( mail.items ~= nil and next(mail.items) ~= nil ) then
            awardsMails[#awardsMails+1] = mail
        elseif tonumber(mail.key) == QMails.ENUM_UNION_MAIL then
            mail.delete = 1
            unionMails[#unionMails+1] = mail
        else
            systemMails[#systemMails+1] = mail
        end 
    end

    local mails = nil
    if mailTab == QMails.ENUM_ALL then
        mails = self._mails
    elseif mailTab == QMails.ENUM_AWARDS then
        mails = awardsMails
    elseif mailTab == QMails.ENUM_NO_AWARDS then
        mails = systemMails
    elseif mailTab == QMails.ENUM_UNION_MAIL then
        mails = unionMails
    end
    -- QPrintTable(mails)
    table.sort(mails, function( a, b ) 
            if a.readed == true and b.readed == false then
                return false
            elseif a.readed == false and b.readed == true then
                return true
            else
                if a.publishTime > b.publishTime then
                    return true
                else
                    return false
                end
            end
        end)
    return mails or {}
end

--删除前端不需要的邮件
function QMails:removeMailsForId(mailId, isPatch)
    self._mailsId[mailId] = nil
	for index,value in ipairs(self._mails) do
		if value.mailId == mailId then
			table.remove(self._mails, index)
            self._mailsId[value.mailId] = nil
            self._totalCount = self._totalCount - 1

            if isPatch ~= false then
                self:dispatchEvent({name = QMails.MAILS_UPDATE_EVENT})
            end
			return 
		end
	end
end

function QMails:updateMail(mails)
    local isUpdate = false
    local isUpdateAvatarUtil = false
    if mails ~= nil then
        for _,mail in pairs(mails) do
            if self._mailsId[mail.mailId] == nil then   
                self._mailsId[mail.mailId] = mail
                self:mailAwardsHandler(mail)
                table.insert(self._mails, mail)
                isUpdate = true
                -- self._offset = self._offset + 1
                self._totalCount = self._totalCount + 1
            else
                for key,value in pairs(mail) do
                    self._mailsId[mail.mailId][key] = value
                end
                self._mailsId[mail.mailId].isConvert = false
                self:mailAwardsHandler(self._mailsId[mail.mailId])
                isUpdate = true
            end

            if mail.key == "storm_arena_season" then
                isUpdateAvatarUtil = true
            end
        end
    end
    if isUpdateAvatarUtil then
        self:dispatchEvent({name = QMails.MAILS_UPDATE_AVATAR_EVENT})
    end
    if isUpdate == true then
        self:mailSort()
        self:checkAwardsMails()
        self:dispatchEvent({name = QMails.MAILS_UPDATE_EVENT})
        return true
    end
    return false
end

--解析邮件的奖励内容 提出金魂币 体力 斗魂场币奖励
--根据邮件模版解析邮件
function QMails:mailAwardsHandler(mail)
    --检查是否有邮件模版
    local mailStencil = QStaticDatabase:sharedDatabase():getMailStencilByKey(mail.key)
    if mailStencil ~= nil and mail.isConvert ~= true then
        mail.title = mailStencil.title

        mail.from = mailStencil.addresser
        mail.delete = mailStencil.delete
        mailStencil.paramNum = mailStencil.paramNum or 0
        mail.oldContent = mail.content
        
        if mail.content ~= nil then
            local contents = string.split(mail.content, "#") or {}
            mail.content = mailStencil.content
            if mailStencil.paramNum > #contents then
                for i = 1, mailStencil.paramNum-#contents do
                    table.insert(contents, 0)
                end
            end
            --xurui: 不需要设置参数的邮件会报错
            if unpack(contents) ~= "" and unpack(contents) ~= nil then
                mail.content = string.format(mail.content, unpack(contents))
            end
        end
    end
    mail.isConvert = true

    if mail.attachment ~= "" then
        local items = string.split(mail.attachment, ";")                
        mail.items = {}      
        mail.awards = {}
        for _, item in pairs(items) do
            if item ~= "" then
                local isDone = false
                local obj = string.split(item, "^")
                local itemType = remote.items:getItemType(obj[1])
                if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
                    table.insert(mail.awards, {type = itemType, count = tonumber(obj[2])})
                    isDone = true
                end
                if isDone == false then
                    table.insert(mail.items, {type = ITEM_TYPE.ITEM, itemId = tonumber(obj[1]), count = tonumber(obj[2])})
                end
            end
        end
    end
end

-- 按照要求排序
function QMails:mailSort()
    table.sort(self._mails, function (mailA, mailB)

        if mailA.attachment ~= "" and mailB.attachment ~= "" then
            return mailA.publishTime > mailB.publishTime
        elseif mailB.attachment and mailB.attachment ~= "" then
            return false
        elseif mailA.attachment and mailA.attachment ~= "" then
            return true
        elseif mailA.readed == true and mailB.readed == true then
            return mailA.publishTime > mailB.publishTime 
        elseif mailA.readed == true and mailB.readed == false then
            return false
        elseif mailA.readed == false and mailB.readed == true then
            return true
        else 
            return mailA.publishTime > mailB.publishTime
        end
    end)
end

function QMails:checkAwardsMails()
    local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
    local maxCount = configuration["MAIL_NUM"].value or 50

    local mails = clone(self._mails or {})
    local awardsMailNum = 0
    local systemMailNum = 0
    for _, mail in pairs(mails) do
        if ( mail.awards ~= nil and next(mail.awards) ~= nil ) or ( mail.items ~= nil and next(mail.items) ~= nil ) then
            if awardsMailNum >= maxCount then
                self:removeMailsForId(mail.mailId, false)
            else
                awardsMailNum = awardsMailNum + 1
            end
        else
            if systemMailNum >= maxCount then
                self:removeMailsForId(mail.mailId, false)
            else
                systemMailNum = systemMailNum + 1
            end
        end 
    end
end

--是否有新邮件
function QMails:checkSystemMails()
    for _, mail in pairs(remote.mails:getMails(QMails.ENUM_NO_AWARDS)) do
        if mail.readed == false then
        QLogFile:info("getIsNewMail at client "..mail.mailId)
        return true
        end
    end
    return false
end

--检查是否有未领取奖励的邮件 
function QMails:checkAwardMail(excludeMail)
    for _, mail in pairs(remote.mails:getMails(QMails.ENUM_AWARDS)) do
        if not (excludeMail and mail.mailId == excludeMail.mailId) then
            if mail.readed == false then
                return true
            end
            -- if (mail.awards ~= nil and #mail.awards > 0) or (mail.items ~= nil and #mail.items > 0)then
            --     return true
            -- end
        end
    end
    return false
end 

--是否有新邮件
function QMails:checkUnionMails()
    for _, mail in pairs(remote.mails:getMails(QMails.ENUM_UNION_MAIL)) do
        if mail.readed == false then
            return true
        end
    end
    return false
end

--检查邮件是否全部拉取
function QMails:checkMailCanGet()
    return self._totalCount > #self._mails or self._markUpdate == 1
end

-- 检查邮件小红点
function QMails:checkMailRedTips()
    if self:checkSystemMails() then
        return true
    elseif self:checkAwardMail() then
        return true
    elseif self:checkUnionMails() then
        return true
    end
    return false
end

--拉取最新的邮件
function QMails:requestMailList(callBack)
    local maxId = nil
    for _,mail in ipairs(self._mails) do
        if maxId == nil then
            maxId = mail.id
        else
            maxId = math.max(maxId, (mail.id or 0))
        end
    end
    if maxId == nil then maxId = 0 end
    self:getNewMailRequest(maxId, callBack)
end

function QMails:markUpdateHandler(event)
    local mark = remote.mark:getMark(remote.mark.MARK_MAIL)
    if self._markUpdate ~= 1 and mark == 1 then
        self._markUpdate = mark
    end
    if self._markUpdate == 1 then
        self:dispatchEvent({name = QMails.MAILS_UPDATE_EVENT, isMark = true})
    end
end

-------------------------------------------------------requets area-----------------------------------------
-- 邮件返回
function QMails:mailResponse(response,success)
    if response.mailGetResponse ~= nil then
        self:updateMail(response.mailGetResponse.mailWithAttachment)
        self:updateMail(response.mailGetResponse.mailWithoutAttachment)
    end
    if response.mailCheckResponse ~= nil then
        self:updateMail(response.mailCheckResponse.lostMail)
    end
    if response.mails ~= nil then
        self:updateMail(response.mails)
    end
    if success ~= nil then success(response) end
end

--拉取邮件列表
function QMails:mailGetRequest(success, fail, status)
    local mailGetRequest = {}
    local request = {api = "MAIL_GET", mailGetRequest = mailGetRequest}
    local successCallback = function (response)
        self:mailResponse(response,success)
    end
    app:getClient():requestPackageHandler("MAIL_GET", request, successCallback, fail)
end

--检查是否有新的邮件
function QMails:getNewMailRequest(maxId, success, fail, status)
    local mailCheckRequest = {maxMailId = maxId}
    local request = {api = "MAIL_CHECK", mailCheckRequest = mailCheckRequest}
    local successCallback = function (response)
        self:mailResponse(response,success)
    end
    app:getClient():requestPackageHandler("MAIL_CHECK", request, successCallback, fail)
end

--[[
    删除邮件
]]
function QMails:mailDelRequest(mailId, success, fail)
    local mailDelRequest = {mailId = mailId}
    local request = {api = "MAIL_DEL", mailDelRequest = mailDelRequest}
    local successCallback = function (response)
        self:mailResponse(response,success)
    end
    app:getClient():requestPackageHandler("MAIL_DEL", request, function (response)
        self:removeMailsForId(mailId)
        if success ~= nil then
            success(data)
        end
    end, fail)
end

--[[
/**
 *  阅读一个邮件
    required string mailId = 1;                                                   // 邮件ID
 *  @return 返回这个邮件的更新后的状态 在 data.updatedMails
 */
--]]
function QMails:mailRead(mailId, success, fail, status)
    local mailReadRequest = {mailId = mailId}
    local request = {api = "MAIL_READ", mailReadRequest = mailReadRequest}
    local successCallback = function (response)
        self:mailResponse(response,success)
    end
    self._notReadTotal = self._notReadTotal -1
    app:getClient():requestPackageHandler("MAIL_READ", request, successCallback, fail, false, true)
end

--[[
  /**
   * 领取邮件中得奖励
   required string mailId = 1;                                                   // 邮件ID
   */
--]]
function QMails:mailRecvAward(mailId, success, fail, status)
    local mailReceiveAwardRequest = {mailId = mailId}
    local request = {api = "MAIL_RECEIVE_AWARD", mailReceiveAwardRequest = mailReceiveAwardRequest}
    local successCallback = function (response)
        self:mailResponse(response,success)
    end
    app:getClient():requestPackageHandler("MAIL_RECEIVE_AWARD", request, successCallback, fail)
end

--[[
    一键领取邮件  
]]
function QMails:oneGetmailAward(success, fail, status)
    local mailReceiveAwardRequest = {mailId = ""}
    local request = {api = "MAIL_RECEIVE_AWARD", mailReceiveAwardRequest = mailReceiveAwardRequest}
    local successCallback = function (response)
        self:mailResponse(response,success)
    end
    app:getClient():requestPackageHandler("MAIL_RECEIVE_AWARD", request, successCallback, fail)
end

return QMails