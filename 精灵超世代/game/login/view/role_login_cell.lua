-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      游戏服务器中角色选择单元
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

RoleLoginCell = class("RoleLoginCell", function()
	return ccui.Widget:create()
end)

function RoleLoginCell:ctor(data, parent)
	self.data = data
	self.isEmpty = data.isEmpty
	local size = cc.size(397, 84)
	parent:addChild(self)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(size)
	self.Bg = createImage(self, PathTool.getResFrame("common","common_1034"), 0, self:getContentSize().height/2, cc.p(0, 0.5), true)
    self:setAnchorPoint(0, 1)
	self.Bg:setContentSize(size)
	self.Bg:setScale9Enabled(true)

	self.select_bg = createImage(self, PathTool.getResFrame("common","common_1034"), -3, self:getContentSize().height/2, cc.p(0, 0.5), true)
	self.select_bg:setVisible(false)
	self.select_bg:setCapInsets(cc.rect(21, 20, 1, 1))
	self.select_bg:setContentSize(cc.size(size.width+6, size.height+10))
	self.select_bg:setScale9Enabled(true)

	self.roleBg = PlayerHead.new(PlayerHead.type.circle)
	self.roleBg:setPosition(42,39)
	self.roleBg:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(self.roleBg)
	self.roleBg:setScale(0.7)

	local res = PathTool.getResFrame("common","common_90026") 
	local add_tag = createImage(self.roleBg, res, 53.5, 50.5, cc.p(0.5, 0.5), true)

	self.isAddDelBtn = false
	if self.isEmpty then
		add_tag:setVisible(true)
		self.isCanDel = false
	else
		add_tag:setVisible(false)
		local vo = {}
		vo.name = data.name
        vo.lev = data.lev
        vo.face_id = data.face_id or  1
		res = PathTool.getHeadIcon(vo.face_id)
		if self.roleBg then
			self.roleBg:setHeadRes(vo.face_id)
		end
		local str = ("【")
		local name_list = {}
		local role_name =vo.name 
		if string.find(vo.name,str) then
			name_list = Split(vo.name,str)
			str = "】"
			name_list = Split(name_list[2],str)
			role_name = name_list[2]
		end
		self.txt_name = createLabel(22, Config.ColorData.data_new_color4[6], nil, 90, 42, role_name, self, 0, cc.p(0, 0))
		self.txt_lev = createLabel(22, Config.ColorData.data_new_color4[7], nil, 90, 12, StringFormat("Lv.{0}", vo.lev), self, 0, cc.p(0, 0))
	end
end

function RoleLoginCell:addCallBack( fun )
	self.callBack = fun
	self:setTouchEnabled(true)
	
	local beganPos = 0
	local movePos = 0
	local endPos = 0
	local isMove = false
	self:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			local pos = sender:getTouchBeganPosition()
			beganPos = sender:convertToNodeSpace(cc.p(pos.x, pos.y))
			isMove = false
	    elseif eventType == ccui.TouchEventType.moved then
	    	local pos = sender:getTouchMovePosition()
	    	movePos = sender:convertToNodeSpace(cc.p(pos.x, pos.y))
	    	if beganPos.x > 5 and movePos.x < 200 and movePos.x - beganPos.x > 30 and not isMove and self.isCanDel and not self.isAddDelBtn then
	    		isMove = true
	    		self.isAddDelBtn = true
	    	end
	    elseif eventType == ccui.TouchEventType.ended then
	    	beganPos = sender:getTouchBeganPosition()
	    	endPos = sender:getTouchEndPosition()
	    	self:clickHandler()
	    end
	end)

end

function RoleLoginCell:clickHandler()
	if self.callBack then
		self.callBack(self)
	end
	self:showSelectBg(true)
end

function RoleLoginCell:showSelectBg( status )
	if self.select_bg then
		self.select_bg:setVisible(status)
	end
end

function RoleLoginCell:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end