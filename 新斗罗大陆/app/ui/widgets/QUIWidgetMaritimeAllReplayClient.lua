-- @Author: vicentboo
-- @Date:   2019-04-28 12:00:23
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-11 14:21:20
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMaritimeAllReplayClient = class("QUIWidgetMaritimeAllReplayClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText") 

local shipColor = {"##b","##p","##o","##u","##y",}

function QUIWidgetMaritimeAllReplayClient:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_zb.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetMaritimeAllReplayClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._contentHeight = self._ccbOwner.background:getContentSize().height

	self:_setInfo(options)
end

function QUIWidgetMaritimeAllReplayClient:onEnter()
end

function QUIWidgetMaritimeAllReplayClient:onExit()
end

function QUIWidgetMaritimeAllReplayClient:switchForceString(force)
	if force == nil or force == "" or force <= 0 then
		return ""
	end

	local num, word = q.convertLargerNumber(force)
	return num..(word or "")
end

function QUIWidgetMaritimeAllReplayClient:_setInfo(param)
	self._info = param.info
	self._index = param.index
	local isAttackType = 0
	local isSuccess = self._info.success
	if self._info.fighterId == remote.user.userId then
		isAttackType = 1
	elseif self._info.escortId == remote.user.userId then
		isAttackType = 2
	elseif self._info.defenseId == remote.user.userId then
		isAttackType = 3
	end

	local time = q.date("%m-%d %H:%M", self._info.fightAt/1000)
	local shipInfo = remote.maritime:getMaritimeShipInfoByShipId(self._info.shipId)
	local shipName = shipInfo.ship_name or ""
	local stringFormat = ""
	local escortId  = self._info.escortId or ""
	local attckAreaName = self._info.fighterGameAreaName or ""
	local atkZmName = self._info.fighterConsortiaName or ""
	local atkNickName = self._info.fighterName or ""
	local nickName = self._info.defenseName or ""
	local zhanli = self:switchForceString(self._info.defenseForce) 
	local atkNickName = self._info.fighterName or ""
	local escortZhanli = self:switchForceString(self._info.escortForce) 
	local atkZhanLi = self:switchForceString(self._info.fighterForce)
	local areaName = self._info.defenseGameAreaName or ""
	local zongMeng = self._info.defenseConsortiaName or ""
	local escortname = self._info.escortName or ""
    --XX：XX分，【服务器】的【宗门名】的【玩家名】（战力XXXX）击败了【服务器】的【宗门名】的【玩家名】（战力XXX），成功掠夺了XX仙品
    --XX：XX分，【服务器】的【宗门名】的【玩家名】（战力XXXX）击败了由【服务器】的【宗门名】的【玩家名】（战力XXX）保护的【玩家名】的仙品，成功掠夺了XX仙品											
	local success = "掠夺成功"
	local color = isSuccess == false and "##n" or "##n"
	if isAttackType == 0 then
		if escortId == "" then
	    	stringFormat = "##n%s##e【%s(%s)】的##e%s(战力%s) ##n掠夺了##e【%s(%s)】的##e%s(战力%s)##n的%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == false and "掠夺失败" or "掠夺成功"
	    else
	    	stringFormat = "##n%s##e【%s(%s)】的##e%s(战力%s) ##n掠夺了由##e【%s(%s)】##n的##e%s(战力%s)##n保护的##e%s(战力%s)##n的%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == false and "掠夺失败" or "掠夺成功"    	
		end
	elseif isAttackType == 1 then
		if escortId == "" then
	    	stringFormat = "##n%s##n您掠夺了##e【%s(%s)】的##e%s(战力%s)##n的%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == false and "掠夺失败" or "掠夺成功"
	    else
	    	stringFormat = "##n%s##n您掠夺了由##e【%s(%s)】##n的##e%s(战力%s)##n保护的##e%s(战力%s)##n的%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == false and "掠夺失败" or "掠夺成功"    	
		end	
	elseif isAttackType == 2 then
		if escortId == "" then
	    	stringFormat = "##n%s##e【%s(%s)】的##e%s(战力%s) ##n掠夺了##e【%s(%s)】的##e%s(战力%s)##n的%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == false and "掠夺失败" or "掠夺成功"
	    else
	    	stringFormat = "##n%s##e【%s(%s)】的##e%s(战力%s) ##n掠夺了由##n您保护的##e%s(战力%s)##n的%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == false and "掠夺失败" or "掠夺成功"    	
		end	
	elseif isAttackType == 3 then
		if escortId == "" then
	    	stringFormat = "##n%s##e【%s(%s)】的##e%s(战力%s) ##n掠夺了##n您的%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == false and "掠夺失败" or "掠夺成功"
	    else
	    	stringFormat = "##n%s##e【%s(%s)】的##e%s(战力%s) ##n掠夺了由##e【%s(%s)】##n的##e%s(战力%s)##n保护的##n您的%s##n，比分%s，"..color.."%s"
	    	success = isSuccess == false and "掠夺失败" or "掠夺成功"    	
		end						
	end

	local scroe = self._info.attack_score..":"..self._info.defense_score

    if self._richText == nil then
        self._richText = QRichText.new(nil, 620, {stringType = 1, defaultSize = 20, fontName = global.font_name})
        self._richText:setAnchorPoint(0,1)
        self._ccbOwner.content:addChild(self._richText)
    end

    if isAttackType == 0 then
		if escortId == "" then
			stringFormat = string.format(stringFormat, time, atkZmName,attckAreaName,atkNickName,atkZhanLi,zongMeng,areaName,nickName,zhanli,shipName, scroe, success)
		else
			stringFormat = string.format(stringFormat, time, atkZmName,attckAreaName,atkNickName,atkZhanLi,zongMeng,areaName,escortname,escortZhanli,nickName,zhanli,shipName, scroe, success)
		end
	elseif isAttackType == 1 then
		if escortId == "" then
			stringFormat = string.format(stringFormat, time, zongMeng,areaName,nickName,zhanli,shipName, scroe, success)
		else
			stringFormat = string.format(stringFormat, time, zongMeng,areaName,escortname,escortZhanli,nickName,zhanli,shipName, scroe, success)
		end		
	elseif isAttackType == 2 then
		if escortId == "" then
			stringFormat = string.format(stringFormat, time, atkZmName,attckAreaName,atkNickName,atkZhanLi,zongMeng,areaName,nickName,zhanli,shipName, scroe, success)
		else
			stringFormat = string.format(stringFormat, time, atkZmName,attckAreaName,atkNickName,atkZhanLi,nickName,zhanli,shipName, scroe, success)
		end		
	elseif isAttackType == 3 then
		if escortId == "" then
			stringFormat = string.format(stringFormat, time, atkZmName,attckAreaName,atkNickName,atkZhanLi,shipName, scroe, success)
		else
			stringFormat = string.format(stringFormat, time, atkZmName,attckAreaName,atkNickName,atkZhanLi,zongMeng,areaName,escortname,escortZhanli,shipName, scroe, success)
		end		
	end
    self._richText:setString(stringFormat)

    local richTextSize = self._richText:getContentSize()
    local newSize = cc.size(richTextSize.width, richTextSize.height+10)
	self._ccbOwner.background:setContentSize(newSize)
	self._ccbOwner.background2:setContentSize(newSize)

	self._ccbOwner.background:setVisible(self._index%2==0)
	self._ccbOwner.background2:setVisible(self._index%2==0)
end

function QUIWidgetMaritimeAllReplayClient:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

return QUIWidgetMaritimeAllReplayClient
