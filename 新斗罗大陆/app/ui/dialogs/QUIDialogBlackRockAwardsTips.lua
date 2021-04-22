local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockAwardsTips = class("QUIDialogBlackRockAwardsTips", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogBlackRockAwardsTips:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_tips.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
	}
	QUIDialogBlackRockAwardsTips.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	local info = options.info
	self._ccbOwner.tf_title:setString(info[1].name.." 奖励详情")

	local starAwardInfo = QStaticDatabase:sharedDatabase():getBlackRockStarAwardsById(info[1].id)
	local starAwards = QStaticDatabase:sharedDatabase():getLuckyDraw(starAwardInfo[1].award)
	self._ccbOwner.tf_star_award1:setString("x "..(starAwards.num_1 or 0))
	if starAwards.num_2 or tonumber(starAwards.num_2) == 0 then
		self._ccbOwner.tf_star_award2:setString("x "..(starAwards.num_2 or 0))
		local itemAwardInfo = QStaticDatabase:sharedDatabase():getItemByID(starAwards.id_2)
		if itemAwardInfo and itemAwardInfo.icon_1 then
			local texture = CCTextureCache:sharedTextureCache():addImage(itemAwardInfo.icon_1)
			self._ccbOwner.sp_star_award2:setTexture(texture)
		end		
	else
		self._ccbOwner.sp_star_award2:setVisible(false)
		self._ccbOwner.tf_star_award2:setString("")
	end

	if starAwardInfo[1] and starAwardInfo[1].star_integral and starAwardInfo[1].star_integral ~= 0 then
		self._ccbOwner.tf_star_award3:setString("x "..(starAwardInfo[1].star_integral or 0))
		self._ccbOwner.sp_star_award3:setVisible(true)	
	else
		self._ccbOwner.sp_star_award3:setVisible(false)
		self._ccbOwner.tf_star_award3:setString("")
	end
	

	for i=1,4 do
		for _,v in ipairs(info) do
			if v.combat_team_id == i then
				local num, uint = q.convertLargerNumber(v.monster_battleforce or 0)
				self._ccbOwner["tf_force"..i]:setString(num..uint)
				local awardsInfo = QStaticDatabase:sharedDatabase():getLuckyDraw(v.monster_reward)
				self._ccbOwner["tf_award"..i.."_1"]:setString("x "..(awardsInfo.num_1 or 0))
				if awardsInfo.num_2 and tonumber(awardsInfo.num_2) > 0 then
					self._ccbOwner["tf_award"..i.."_2"]:setString("x "..(awardsInfo.num_2 or 0))
					local itemaInfo = QStaticDatabase:sharedDatabase():getItemByID(awardsInfo.id_2)
					if itemaInfo and itemaInfo.icon_1 then
						local texture = CCTextureCache:sharedTextureCache():addImage(itemaInfo.icon_1)
	        			self._ccbOwner["sp_award"..i.."_2"]:setTexture(texture)
	        		end
	        	else
	        		self._ccbOwner["tf_award"..i.."_2"]:setString("")
	        		self._ccbOwner["sp_award"..i.."_2"]:setVisible(false)
	        	end
				if v.monster_integral and tonumber(v.monster_integral) > 0 then
					self._ccbOwner["tf_award"..i.."_3"]:setString("x "..(v.monster_integral or 0))
				else
					self._ccbOwner["sp_award"..i.."_3"]:setVisible(false)
					self._ccbOwner["tf_award"..i.."_3"]:setString("")
				end

				break
			end
		end
	end
end

function QUIDialogBlackRockAwardsTips:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogBlackRockAwardsTips