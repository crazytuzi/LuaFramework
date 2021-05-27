--基本系统导航按钮
MainuiNavBtn = MainuiNavBtn or BaseClass()

function MainuiNavBtn:__init(parent,view_name,group,index,data)
	self.parent = parent
	self.view_name = view_name
	self.group = group

	self.width = 90
	self.height =  95

	self.container = XUI.CreateLayout(0,0,self.width,self.height)
	self.container:setAnchorPoint(0,0)
	parent:addChild(self.container)

	local bg = XUI.CreateImageView(self.width * 0.5,self.height-12,ResPath.GetMainui("icon_bg_4"),true)
	bg:setAnchorPoint(0.5,1)
	self.container:addChild(bg)

	self.icon_img = XUI.CreateImageView(self.width * 0.5,self.height-12,ResPath.GetMainui("icon_01_img"),true)
	self.icon_img:setAnchorPoint(0.5,1)
	self.container:addChild(self.icon_img)

	local text_bg = XUI.CreateImageView(self.width * 0.5,5,ResPath.GetMainui("icon_text_bg"),true)
	text_bg:setAnchorPoint(0.5,0)
	self.container:addChild(text_bg)

	self.title_text = XUI.CreateImageView(self.width * 0.5,3,ResPath.GetMainui("icon_01_word"),true)
	self.title_text:setAnchorPoint(0.5,0)
	self.container:addChild(self.title_text)

	local w = 50
	local h = 20
	self.tip_text_bg = XUI.CreateImageView(75,63,ResPath.GetMainui("remind_flag"),true)
	self.tip_text_bg:setVisible(false)
	self.container:addChild(self.tip_text_bg)
	self.tip_text = XUI.CreateText(79,81,w,h)
	self.tip_text:setColor(COLOR3B.WHITE)
	self.tip_text:setAnchorPoint(0.5,0.5)
	self.container:addChild(self.tip_text)

	self.flag_bg = XUI.CreateImageView(75, 63, ResPath.GetMainui("remind_flag"),true)
	self.flag_bg:setVisible(false)
	self.container:addChild(self.flag_bg)
	self.index = index or -1
	self.data = data
	self.container:setHittedScale(1.05)
end

function MainuiNavBtn:__delete()
end	

function MainuiNavBtn:SetData(data)
	self.data = data
end

function MainuiNavBtn:GetData()
	return self.data
end

function MainuiNavBtn:SetImageIcon(icon_index,word_index)
	self.icon_img:loadTexture(ResPath.GetMainui("icon_".. icon_index .. "_img"))
	self.title_text:loadTexture(ResPath.GetMainui("icon_".. word_index .. "_word"))
end	

function MainuiNavBtn:GetViewName()
	return self.view_name
end	

function MainuiNavBtn:GetGroup()
	return self.group
end	

function MainuiNavBtn:SetTipText(txt)
	self.tip_text:setString(txt)
	self.tip_text_bg:setVisible(txt ~= nil and txt ~= "")
end	

function MainuiNavBtn:GetView()
	return self.container
end	

function MainuiNavBtn:SetFlagTip(num)
	self.flag_bg:setVisible(num > 0)
end

-- 提醒标志显隐状态
function MainuiNavBtn:GetFlagTipVis()
	if self.flag_bg then
		return self.flag_bg:isVisible()
	end
end

function MainuiNavBtn:SetTxtImgPos(x, y)
	self.title_text:setPosition(x or self.width * 0.5, y or 3)
end

function MainuiNavBtn:SetIndex(index)
	self.index = index
end

function MainuiNavBtn:GetIndex()
	return self.index
end