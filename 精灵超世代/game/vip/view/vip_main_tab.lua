--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-27 17:15:14
-- @description    : 
		-- 功能描述
---------------------------------
VipMainTabBtn = class("VipMainTabBtn", function (  )
	return ccui.Widget:create()
end)

function VipMainTabBtn:ctor(callback)
	self.callback = callback

	self:configUI()
	self:register_event()
end

function VipMainTabBtn:configUI(  )
	self.size = cc.size(155, 130)
	self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("vip/vip_tab_btn")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")

    self.tips = container:getChildByName("tab_tips")
    self.tips:setVisible(false)
    self.red_num = container:getChildByName("red_num")
    self.red_num:setVisible(false)
    self.select_bg = container:getChildByName("select_bg")
    self.select_bg:setVisible(false)
    self.unselect_bg = container:getChildByName("unselect_bg")
    self.title_label = container:getChildByName("title")
    self.title_img = container:getChildByName("title_img")
	self.title_img:setVisible(false)
	
    self.unselect_bg:ignoreContentAdaptWithSize(true)
    --self.select_bg:ignoreContentAdaptWithSize(true)
end

function VipMainTabBtn:register_event(  )
	self:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playTabButtonSound()
            if self.tab_type and self.callback then
            	self.callback(self.tab_type)
            end
        end
    end)
end

function VipMainTabBtn:setSelect( status )
	self.select_bg:setVisible(status)
	--self.unselect_bg:setVisible(not status)
	self.title_img:setVisible(status)
	self.title_label:setVisible(not status)
end

function VipMainTabBtn:showRedTips( status, num )
	self.red_tips_status = status
	self.tips:setVisible(status)
	if num and num > 0 then
		self.red_num:setVisible(true)
		self.red_num:setString(num)
	else
		self.red_num:setVisible(false)
	end
end

function VipMainTabBtn:getRedTipsStatus(  )
	return self.red_tips_status
end

function VipMainTabBtn:setData( data )
	self.data = data or {}

	self.tab_type = self.data.index

	self.title_label:setString(self.data.label)
	self.title_img:setString(self.data.label)
	self:setTouchEnabled(self.data.status)

	local unselect_res
	local select_res
	if self.tab_type == VIPTABCONST.CHARGE then
		unselect_res = PathTool.getResFrame("vip","vip_tab10")
		select_res = PathTool.getResFrame("vip","vip_tab1")
	elseif self.tab_type == VIPTABCONST.ACC_CHARGE then
		unselect_res = PathTool.getResFrame("vip","vip_tab10")
		select_res = PathTool.getResFrame("vip","vip_tab1")
	elseif self.tab_type == VIPTABCONST.VIP then
		unselect_res = PathTool.getResFrame("vip","vip_tab30")
		select_res = PathTool.getResFrame("vip","vip_tab3")
		self.title_img:setScale(0.9)
	elseif self.tab_type == VIPTABCONST.DAILY_GIFT then
		unselect_res = PathTool.getResFrame("vip","vip_tab40")
		select_res = PathTool.getResFrame("vip","vip_tab4")
	elseif self.tab_type == VIPTABCONST.PRIVILEGE then
		unselect_res = PathTool.getResFrame("vip","vip_tab50")
		select_res = PathTool.getResFrame("vip","vip_tab5")
	end
	if unselect_res then
		self.unselect_bg:loadTexture(unselect_res, LOADTEXT_TYPE_PLIST)
	end
	--if select_res then
	--	self.select_bg:loadTexture(select_res, LOADTEXT_TYPE_PLIST)
	--end
end

function VipMainTabBtn:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end