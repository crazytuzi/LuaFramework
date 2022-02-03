--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-28 10:17:26
-- @description    : 
		-- 我的方案item
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()

HomeworldMyPlanItem = class("HomeworldMyPlanItem", function()
    return ccui.Widget:create()
end)

function HomeworldMyPlanItem:ctor(_type)
	self.open_type = _type -- 1:套装 2:方案
	self:configUI()
	self:register_event()
end

function HomeworldMyPlanItem:configUI(  )
	self.size = cc.size(155, 196)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("homeworld/homeworld_my_plan_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.container:setSwallowTouches(false)

    self.name_txt = self.container:getChildByName("name_txt")
    self.use_sp = self.container:getChildByName("use_sp")
    self.use_sp:setVisible(false)

    self.image_bg = createSprite(PathTool.getResFrame("common", "common_1005"), self.size.width*0.5, self.size.height*0.5+20, self.container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
end

function HomeworldMyPlanItem:register_event(  )
	registerButtonEventListener(self.container, function (  )
		if self.data then
			if self.open_type == 1 then
				_controller:openHomeworldSuitWindow(true, self.data.set_id)
			end
		end
	end, true, 1, nil, nil, nil, true)

	-- 红点
    if not self.update_red_status_event and self.open_type == 1 then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(HomeworldEvent.Update_Red_Status_Data,function(bid, status)
            if bid == HomeworldConst.Red_Index.Suit then
                self:updateSuitAwardRedStatus()
            end
        end)
    end
end

function HomeworldMyPlanItem:setData( data )
	if not data then return end

	self.data = data

	-- 名称
	self.name_txt:setString(data.name)

	-- 图标
	if not self.image_icon then
		self.image_icon = createSprite(nil, self.size.width*0.5, self.size.height*0.5+20, self.container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
	end
	if not self.cur_res_id or self.cur_res_id ~= data.res_id then
		self.cur_res_id = data.res_id
		local res_path = PathTool.getSuitIconRes( data.res_id )
		self.icon_load = loadSpriteTextureFromCDN(self.image_icon, res_path, ResourcesType.single, self.icon_load)
	end

	if self.open_type == 1 then
		self:updateSuitAwardRedStatus()
	end
end

function HomeworldMyPlanItem:updateSuitAwardRedStatus(  )
	if self.data then
		local red_status = _model:checkSuitAwardRedStatus(self.data.set_id)
		addRedPointToNodeByStatus(self.container, red_status)
	end
end

function HomeworldMyPlanItem:suspendAllActions(  )
	
end

function HomeworldMyPlanItem:DeleteMe(  )
	if self.icon_load then
		self.icon_load:DeleteMe()
		self.icon_load = nil
	end
	if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end