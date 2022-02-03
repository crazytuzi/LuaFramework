--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-12 16:19:06
-- @description    : 
		-- 天界副本关卡 item
--------------------------------- 
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

HeavenCustomsItem = class("HeavenCustomsItem", function()
    return ccui.Widget:create()
end)

function HeavenCustomsItem:ctor(call_back)
	self.call_back = call_back
	self.star_list = {}

	self:configUI()
	self:register_event()
end

function HeavenCustomsItem:configUI( )
	self.size = cc.size(120, 180)
	self:setTouchEnabled(false)
	self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("heaven/heaven_customs_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.customs_icon = container:getChildByName("customs_icon")
    self.customs_icon:ignoreContentAdaptWithSize(true)
    self.customs_num = self.root_wnd:getChildByName("customs_num")
    self.boss_sp = self.root_wnd:getChildByName("boss_sp")
    self.boss_sp:setVisible(false)
    self.arrow_sp = container:getChildByName("arrow_sp")
    self.arrow_sp:setVisible(false)
    
    for i=1,3 do
    	local star = container:getChildByName("star_" .. i)
    	if star then
    		_table_insert(self.star_list, star)
    	end
    end

    local act_1 = cc.MoveBy:create(1, cc.p(0, 8))
    local act_2 = cc.MoveBy:create(1, cc.p(0, -8))
    container:runAction(cc.RepeatForever:create(cc.Sequence:create(act_1, act_2)))
end

function HeavenCustomsItem:register_event(  )
	registerButtonEventListener(self.container, function (  )
		if self.select_status and self.customs_vo then
			if self.customs_vo.star == 3 then
				message(TI18N("本关已经完美通关啦"))
			elseif self.cfg_data then
				--[[if _model:getLeftChallengeCount() <= 0 then
			        message(TI18N("挑战次数不足"))
			        return
			    end--]]
			    if self.cfg_data.type == 1 then -- BOSS关
		            HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.HeavenBoss, {chapter_id = self.cfg_data.id, customs_id = self.cfg_data.order_id})
		        else
		            HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Heaven, {chapter_id = self.cfg_data.id, customs_id = self.cfg_data.order_id})
		        end
			end
		elseif self.call_back then
			self.call_back(self)
		end
	end)
end

function HeavenCustomsItem:setData( customs_vo, cfg_data )
	if not customs_vo or not cfg_data then return end

	if self.customs_vo ~= nil then
        if self.update_self_event ~= nil then
            self.customs_vo:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end
	
	self.cfg_data = cfg_data
	self.customs_vo = customs_vo

	if self.customs_vo then
		if self.update_self_event == nil then
            self.update_self_event = self.customs_vo:Bind(HeavenEvent.Update_Customs_Vo_Event, function()
                self:updateStarInfo()
            end)
        end
	end

	self:updateCustomsItem()
end

function HeavenCustomsItem:updateCustomsItem(  )
	if not self.cfg_data then return end
	
	-- 关卡图标
	if not self.icon_res_id or self.icon_res_id ~= self.cfg_data.res_id then
		self.icon_res_id = self.cfg_data.res_id
		local res_path = PathTool.getHeavenCustomsIconRes( self.cfg_data.res_id )
		self.res_load = loadImageTextureFromCDN(self.customs_icon, res_path, ResourcesType.single, self.res_load)
	end

	-- 关卡章节
	if self.cfg_data.type == 1 then  -- boss关卡
		self.customs_num:setVisible(false)
		self.boss_sp:setVisible(true)
	else
		self.boss_sp:setVisible(false)
		self.customs_num:setVisible(true)
		self.customs_num:setString(self.cfg_data.id .. "-" .. self.cfg_data.order_id)
	end

	-- 星数
	self:updateStarInfo()
end

function HeavenCustomsItem:updateStarInfo( )
	local pass_star = 0
	if self.customs_vo then
		pass_star = self.customs_vo.star
	end
	for i,star in ipairs(self.star_list) do
		star:setVisible(i <= pass_star)
	end
end

function HeavenCustomsItem:setSelected( status )
	if status == true then
		self.container:setScale(1.1)
		self.arrow_sp:setVisible(true)
		self:setLocalZOrder(99)
	else
		self.container:setScale(1.0)
		self.arrow_sp:setVisible(false)
		self:setLocalZOrder(1)
	end
	self.select_status = status
end

function HeavenCustomsItem:getData(  )
	return self.cfg_data
end

function HeavenCustomsItem:getCustomsId(  )
	if self.cfg_data then
		return self.cfg_data.order_id
	end
end

function HeavenCustomsItem:DeleteMe(  )
	if self.res_load then
		self.res_load:DeleteMe()
		self.res_load = nil
	end
	if self.customs_vo ~= nil then
        if self.update_self_event ~= nil then
            self.customs_vo:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end
	self:removeAllChildren()
    self:removeFromParent()
end