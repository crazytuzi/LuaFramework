local GUIConfirm = class("GUIConfirm",function ()
	  return ccui.Widget:create()
end)

function GUIConfirm:ctor(strMsg)
	self.checkbox = ccui.CheckBox:create()
	self.checkbox:loadTextures("btn_checkbox","btn_checkbox_sel","btn_checkbox_sel","","",ccui.TextureResType.plistType)
	:addTo(self)
	self.checkbox:setScale(0.7)
	self.checkbox:setPosition(cc.p(0,0))
	self.checkbox:setSelected(false)
	self.checkbox:addEventListener(function(sender,touchType)
		local unShowMsg = GameSetting.getConf("GUIConfirm")
		if touchType == ccui.CheckBoxEventType.selected then
			if not table.indexof(unShowMsg,strMsg) then
				table.insert(unShowMsg,#unShowMsg+1,strMsg)
				GameSetting.setConf("GUIConfirm",unShowMsg)
			end
		elseif touchType ==ccui.CheckBoxEventType.unselected then
			local index = table.indexof(unShowMsg,strMsg)
			if index then
				table.remove(unShowMsg,index)
				GameSetting.setConf("GUIConfirm",unShowMsg)
			end
		end
	end)
	self.label = cc.ui.UILabel.new({
			UILabelType = 2,
			text = "本次不再提示！",
			size = 18,
			color = GameConst.color(1),
			align = cc.ui.TEXT_VALIGN_CENTER,
			x=self.checkbox:getPositionX()+self.checkbox:getContentSize().width/2,
			y=0,
			}):addTo(self):setName("showtext")
end

function GUIConfirm:setString(str)
	self.label:setString(str)
	return self
end

function GUIConfirm:isSelected()
	return self.checkbox:isSelected()
end
function GUIConfirm:setSelected(bool)
	self.checkbox:setSelected(bool)
	return self
end
return GUIConfirm