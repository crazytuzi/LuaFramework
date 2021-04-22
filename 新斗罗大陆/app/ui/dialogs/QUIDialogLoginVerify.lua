local QUIDialog = import(".QUIDialog")
local QUIDialogLoginVerify = class("QUIDialogLoginVerify", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIDialogLoginVerify.verifySignKey = "ZPjKjxfJeHFL7LBw6qzb"
QUIDialogLoginVerify.statusSignKey = "56M5RJWNLqCqPGxsFGfh"

function QUIDialogLoginVerify:ctor(options)
	local ccbFile = "ccb/Dialog_Yanzheng.ccbi"
	local callBacks = {
    }
    QUIDialogLoginVerify.super.ctor(self, ccbFile, callBacks, options)
    app:hideLoading()
	local function onEdit(event, editbox)
	    if event == "began" then
	    elseif event == "changed" then
	    	self._ccbOwner.labeL_num3:setString(editbox:getText())
	    	self:loginVerify(editbox:getText())
	    elseif event == "ended" then
	    elseif event == "return" then
	    end
	end
    self._edit_num1 = ui.newEditBox({
        image = "ui/none.png",
        listener = onEdit,
        size = CCSize(90, 90)})
    self._edit_num1:setFont(global.font_default, 0)
    self._edit_num1:setFontSize(0)
    self._edit_num1:setReturnType(kKeyboardReturnTypeDone)

    self._edit_num1:setPosition(132,-28)

    self._ccbOwner.node_input:addChild(self._edit_num1)
    if options then
    	self.num1 = options.num1 or 0
    	self.num2 = options.num2 or 0
    	self.caculate = options.caculate or 1
    	self._callBack = options.callback
    end
    self:initPage()
end

function QUIDialogLoginVerify:initPage()
	self._ccbOwner.labeL_num1:setString(self.num1 or 0)
    self._ccbOwner.labeL_num2:setString(self.num2 or 0)
    if self.caculate == 1 then
    	self._ccbOwner.jia:setVisible(true)
    	self._ccbOwner.jian:setVisible(false)
		self._ccbOwner.cheng:setVisible(false)    	
	elseif self.caculate == 2 then
		self._ccbOwner.jian:setVisible(true)
		self._ccbOwner.jia:setVisible(false)
		self._ccbOwner.cheng:setVisible(false)
	elseif self.caculate == 3 then
		self._ccbOwner.jian:setVisible(false)
		self._ccbOwner.jia:setVisible(false)
		self._ccbOwner.cheng:setVisible(true)	
    end
    self._ccbOwner.labeL_num3:setString("")
    self._edit_num1:setText("")
end



function QUIDialogLoginVerify:loginVerify(result)
    local localResult = 0
    if self.caculate == 1 then
    	localResult = self.num1 + self.num2
	elseif self.caculate == 2 then
		localResult = self.num1 - self.num2
	elseif self.caculate == 3 then
		localResult = self.num1 * self.num2	
    end
    result = tonumber(result)
    if result and result == localResult then
    	local verifyUrl = self:getVerifyUrl(result)
    	local verifyJson = httpGet(verifyUrl, 1)
        if verifyJson == nil then return end
        local data = json.decode(verifyJson)
        if data and data.status == 1 then
        	self:playEffectOut()
        else
        	self:refreshVerify()
        end
    end
end

function QUIDialogLoginVerify:getVerifyUrl(authorizeExpr)
	local channelId = FinalSDK.getChannelID()
	local userAccount = FinalSDK.getSessionId()
	local timestamp = math.floor(q.serverTime() * 1000)
	local sign = crypto.md5("authorizeAnswer="..authorizeExpr.."&opId="..channelId.."&timestamp="..timestamp.."&userAccount="..userAccount..QUIDialogLoginVerify.verifySignKey)
	return LOGINHISTORY_URL..string.format("/account_authorize?userAccount=%s&timestamp=%s&authorizeAnswer=%s&opId=%s&sign=%s", userAccount,timestamp, authorizeExpr, channelId, sign)
end

function QUIDialogLoginVerify:refreshVerify()
	local accountUrl = self:getAccountStatusUrl()
	local accountStatusJson = httpGet(accountUrl, 1)
	if accountStatusJson == nil then return end
	local data = json.decode(accountStatusJson)
	if data then
		if data.status == 0 then
			local authorizeExpr = data.authorizeExpr
			local nums = string.split(authorizeExpr, ";")
			if #nums == 3 then
				self.num1 = tonumber(nums[1])
				self.num2 = tonumber(nums[3])
				self.caculate = tonumber(nums[2])
			end
		elseif data.status == 1 then
			self:playEffectOut()
		elseif data.status == 2 then		
		end
	end
	self:initPage()
end

function QUIDialogLoginVerify:getAccountStatusUrl()
	local channelId = FinalSDK.getChannelID()
	local userAccount = FinalSDK.getSessionId()
	local timestamp = math.floor(q.serverTime() * 1000)
	local sign = crypto.md5("opId="..channelId.."&timestamp="..timestamp.."&userAccount="..userAccount..QUIDialogLoginVerify.statusSignKey)
	return LOGINHISTORY_URL..string.format("/account_status?userAccount=%s&timestamp=%s&opId=%s&sign=%s", userAccount,timestamp, channelId, sign)
end

function QUIDialogLoginVerify:viewAnimationOutHandler()
	local callback = self._callBack
	self:popSelf()
	if callback then
		callback()
	end
end

return QUIDialogLoginVerify