local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderBuff = class("QUIDialogThunderBuff", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogThunderBuff:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing_ChooseUp.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerGreen", callback = handler(self, self._onTriggerGreen)},
        {ccbCallbackName = "onTriggerBlue", callback = handler(self, self._onTriggerBlue)},
        {ccbCallbackName = "onTriggerRed", callback = handler(self, self._onTriggerRed)},
        {ccbCallbackName = "onTriggerClose",callback = handler(self,self._onTriggerClose)},

	}
	QUIDialogThunderBuff.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true

    -- setShadow5(self._ccbOwner.tf_shadow1)
    -- setShadow5(self._ccbOwner.tf_shadow2)
   --  local i = 1
  	-- while self._ccbOwner["tf_name_"..i] do
  	-- 	setShadow5(self._ccbOwner["tf_name_"..i])
  	-- 	setShadow5(self._ccbOwner["tf_value_"..i])
  	-- 	i = i + 1
  	-- end

	local fighter = remote.thunder:getThunderFighter()
	local buffs = fighter.thunderRandBuffs
	self._selectIndex = 0
	buffs = string.split(buffs, ";")
	self._buffs = {}
	self._starNum = fighter.thunderCurrentStar - fighter.thunderCurrentUsed
	self._ccbOwner.tf_star:setString(self._starNum)
	for _,buff in pairs(buffs) do
		if buff ~= "" then
			local buffConfig = QStaticDatabase:sharedDatabase():getThunderBuffById(buff)
			local index = buffConfig.star/3
			self._ccbOwner["tf_buff"..index.."_name"]:setString(buffConfig.buff_type)
			self._ccbOwner["tf_buff"..index.."_num"]:setString("+"..buffConfig.buff_num.."%")
			self._ccbOwner["tf_buff"..index.."_star"]:setString(buffConfig.star)
			self._ccbOwner["sp_buff"..index]:setTexture(CCTextureCache:sharedTextureCache():addImage(buffConfig.ICON))
			if buffConfig.star > self._starNum then
				self._ccbOwner["tf_buff"..index.."_star"]:setColor(UNITY_COLOR_LIGHT.red)
			else
				self._ccbOwner["tf_buff"..index.."_star"]:setColor(UNITY_COLOR_LIGHT.green)
			end
			self._buffs[index] = buffConfig
		end
	end

	self._ccbOwner.frame_tf_title:setString("选择加成")

	local prop = {}

	local buffs = remote.thunder:getAllBuff()
	for _,buff in pairs(buffs) do
		local buffConfig = QStaticDatabase:sharedDatabase():getThunderBuffById(buff)
		if prop[buffConfig.buff_type] == nil then
			prop[buffConfig.buff_type] = 0
		end
		prop[buffConfig.buff_type] = prop[buffConfig.buff_type] + buffConfig.buff_num
	end
	for i=1,9 do
		self._ccbOwner["tf_name_"..i]:setString("")
		self._ccbOwner["tf_value_"..i]:setString("")
	end
	self:setBuffInfo("生命", "+%d%%", (prop["生命"] or 0))
	self:setBuffInfo("攻击", "+%d%%", (prop["攻击"] or 0))
	-- self:setBuffInfo("物防", "+%d%%", (prop["物防"] or 0))
	-- self:setBuffInfo("法防", "+%d%%", (prop["法防"] or 0))
	self:setBuffInfo("防御", "+%d%%", (prop["防御"] or 0))
	self:setBuffInfo("命中", "+%d%%", (prop["命中"] or 0))
	self:setBuffInfo("闪避", "+%d%%", (prop["闪避"] or 0))
	self:setBuffInfo("暴击", "+%d%%", (prop["暴击"] or 0))
	self:setBuffInfo("格挡", "+%d%%", (prop["格挡"] or 0))
	self:setBuffInfo("攻速", "+%d%%", (prop["攻速"] or 0))
	self:showSelect()
end

function QUIDialogThunderBuff:setBuffInfo(name, str, value)
	if self._index == nil then self._index = 1 end
	if value > 0 then
		self._ccbOwner["tf_name_"..self._index]:setString(name)
		self._ccbOwner["tf_value_"..self._index]:setString(string.format(str, value))
		self._index = self._index + 1
	end
end

function QUIDialogThunderBuff:showSelect()
	if self._selectIndex ~= 0 then
		for i=1,3 do
			self._ccbOwner["sp_buff"..i.."_on"]:setVisible(self._selectIndex==i)
			self._ccbOwner["sp_buff"..i.."_off"]:setVisible(self._selectIndex~=i)
		end
	end
end

function QUIDialogThunderBuff:_onTriggerClose( event )
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_confirm")
	if self._selectIndex == 0 then
		app.tip:floatTip("请选择一个属性加成！")
		return
	end

	remote.thunder:thunderBuyBuffRequest(self._buffs[self._selectIndex].id)

	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end
function QUIDialogThunderBuff:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end
	app.sound:playSound("common_confirm")
	if self._selectIndex == 0 then
		app.tip:floatTip("请选择一个属性加成！")
		return
	end

	remote.thunder:thunderBuyBuffRequest(self._buffs[self._selectIndex].id)

	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogThunderBuff:_onTriggerGreen()
	app.sound:playSound("common_switch")
	if self._starNum < 3 then
		app.tip:floatTip("星星不足！")
		return
	end
	self._selectIndex = 1
	self:showSelect()
end

function QUIDialogThunderBuff:_onTriggerBlue()
	app.sound:playSound("common_switch")
	if self._starNum < 6 then
		app.tip:floatTip("星星不足！")
		return
	end
	self._selectIndex = 2
	self:showSelect()
end

function QUIDialogThunderBuff:_onTriggerRed()
	app.sound:playSound("common_switch")
	if self._starNum < 9 then
		app.tip:floatTip("星星不足！")
		return
	end
	self._selectIndex = 3
	self:showSelect()
end

function QUIDialogThunderBuff:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogThunderBuff