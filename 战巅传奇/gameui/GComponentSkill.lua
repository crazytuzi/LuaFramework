local GComponentSkill = {}

function GComponentSkill:initView(extend)
	if self.xmlTips then
		self.xmlTips:setContentSize(display.width, display.height):setTouchEnabled(true)
		self.xmlTips:getWidgetByName("box_new_skill"):align(display.CENTER, display.cx, display.cy)

		self.xmlTips:getWidgetByName("img_new_skill_inner"):setOpacity(255 * 0.8)

		local imgSkillIcon = self.xmlTips:getWidgetByName("img_skill_icon")--:scale(52/72)
		--imgSkillIcon:loadTexture("image/icon/skill"..extend.skillId..".png")
		
		local path = "image/icon/skill"..extend.skillId..".png"
		asyncload_callback(path, imgSkillIcon, function(path, texture)
			imgSkillIcon:loadTexture(path)
		end)
		
		self.xmlTips:getWidgetByName("lbl_skill_name"):setString("【"..extend.skillName.."】")
		
		local function startFlySkill()
			local position = GameUtilSenior.getWidgetCenterPos(imgSkillIcon)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_FLY_NEW_SKILL, skillId = extend.skillId, position = position})
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end

		GUIFocusPoint.addUIPoint(self.xmlTips, function ()
			startFlySkill()
		end)

		self.xmlTips:runAction(cca.seq({
			cca.delay(7),
			cca.cb(function ()
				startFlySkill()
			end)
		}))

	end
end

return GComponentSkill