
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local TimePrivilegeConst = require("app.const.TimePrivilegeConst")

local TimePrivilegeAwardItem = class("TimePrivilegeAwardItem", function()
	return CCSItemCellBase:create("ui_layout/timeprivilege_AwardItem.json")
end)


function TimePrivilegeAwardItem:ctor()
	self._nCurState = TimePrivilegeConst.CLAIM_STATE.UNFINISH

	self._des1 = self:getLabelByName("Label_des1")
    self._des2 = self:getLabelByName("Label_des2")
    self._des3 = self:getLabelByName("Label_des3")

    self:attachImageTextForBtn("Button_get", "Image_8")
end

function TimePrivilegeAwardItem:updateItem(tTmpl)
	if not tTmpl then
        return
	end

	local nRechargeCount = G_Me.timePrivilegeData:getRechargeCount() 
    self:getButtonByName("Button_get"):setVisible(true)
	if tTmpl._nState == TimePrivilegeConst.CLAIM_STATE.CLAIMED then
		self._nCurState = TimePrivilegeConst.CLAIM_STATE.CLAIMED
		self:getButtonByName("Button_get"):setVisible(false)
		self:getImageViewByName("Image_get"):setVisible(true)
	else
		if nRechargeCount >= tTmpl.num then
			-- 可以领取了
			self._nCurState = TimePrivilegeConst.CLAIM_STATE.CAN_CLAIM
            tTmpl._nState = TimePrivilegeConst.CLAIM_STATE.CAN_CLAIM
			self:getImageViewByName("Image_get"):setVisible(false)
            self:enableWidgetByName("Button_get", true)
		else
			-- 还未完成
			self._nCurState = TimePrivilegeConst.CLAIM_STATE.UNFINISH
            tTmpl._nState = TimePrivilegeConst.CLAIM_STATE.UNFINISH
			self:getImageViewByName("Image_get"):setVisible(false)
			self:enableWidgetByName("Button_get", false)
		end
	end

	local tGoods = G_Goods.convert(tTmpl.type, tTmpl.value, tTmpl.size)
	self:_initGoods(tGoods)

	CommonFunc._updateLabel(self, "Label_title", {text=tGoods.name .. "*" .. G_GlobalFunc.ConvertNumToCharacter3(tGoods.size), stroke=Colors.strokeBrown})
	self._des1:setText(G_lang:get("LANG_TIME_PRIVILEGE_BUY1"))
	self._des2:setText(G_lang:get("LANG_TIME_PRIVILEGE_BUY2", {num=tTmpl.num}))
	self._des3:setText(G_lang:get("LANG_TIME_PRIVILEGE_BUY3"))
	self:_refreshPos()

    self:getButtonByName("Button_get"):setTag(tTmpl.id)
	self:registerBtnClickEvent("Button_get", handler(self, self._onClickClaimButton))
end

function TimePrivilegeAwardItem:_refreshPos()
    local pos1 = ccp(self._des1:getPosition())
    local width1 = self._des1:getContentSize().width
    self._des2:setPosition(ccp(pos1.x+width1,pos1.y))
    local pos2 = ccp(self._des2:getPosition())
    local width2 = self._des2:getContentSize().width
    self._des3:setPosition(ccp(pos2.x+width2,pos2.y))
end

function TimePrivilegeAwardItem:_initGoods(tGoods)
	local imgBg = self:getImageViewByName("Image_boardbg")
	if not tGoods then
		imgBg:setVisible(false)
	else
		imgBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality))
		-- 掉落物品的品质框
		local btnQulaity = self:getButtonByName("Button_border")
		btnQulaity:loadTextureNormal(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
		btnQulaity._nType = tGoods.type
		btnQulaity._nValue= tGoods.value
		-- 掉落的物品icon
		local imgIcon = self:getImageViewByName("Image_icon")
		if imgIcon then
			imgIcon:loadTexture(tGoods.icon)
		end
		-- 绑定点击事件
		self:registerBtnClickEvent("Button_border", handler(self, self._onClickAwardItem))
	end
end

function TimePrivilegeAwardItem:_onClickAwardItem(sender)
	local nType = sender._nType
	local nValue = sender._nValue
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
end

function TimePrivilegeAwardItem:_onClickClaimButton(sender)
	local nId = sender:getTag()
	G_HandlersManager.timePrivilegeHandler:sendShopTimeGetReward(nId)
end

return TimePrivilegeAwardItem