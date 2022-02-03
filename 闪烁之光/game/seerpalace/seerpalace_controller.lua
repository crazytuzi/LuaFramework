-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-11-20
-- --------------------------------------------------------------------
SeerpalaceController = SeerpalaceController or BaseClass(BaseController)

function SeerpalaceController:config()
    self.model = SeerpalaceModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function SeerpalaceController:getModel()
    return self.model
end

function SeerpalaceController:registerEvents()
	--[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil
            -- 上线时请求
            self:requestSeerpalaceChangeInfo()
        end)
    end--]]
end

function SeerpalaceController:registerProtocals()
    self:RegisterProtocal(23213,"handle23213") --先知殿召唤返回
    self:RegisterProtocal(23214,"handle23214") --先知殿置换当前状态数据
	self:RegisterProtocal(23215,"handle23215") --先知殿置换结果
    self:RegisterProtocal(23235,"handle23235") --当日是否打开过先知水晶（用于红点）
end

-- 请求先知殿召唤
function SeerpalaceController:requestSeerpalaceSummon( group_id )
    local protocal = {}
    protocal.group_id = group_id
    self:SendProtocal(23213, protocal)
end

-- 先知召唤获得返回
function SeerpalaceController:handle23213( data )
    if data then
    	self.model:setLastSummonGroupId(data.group_id)
    	local items = {}
    	for i,v in ipairs(data.rewards or {}) do
    		items[i] = {}
    		items[i].bid = v.base_id
    		items[i].num = v.num
    	end
    	MainuiController:getInstance():openGetItemView(true, items, 0, {is_backpack = true}, MainuiConst.item_open_type.seerpalace)
    end
end

-- 请求英雄置换的当前状态数据
function SeerpalaceController:requestSeerpalaceChangeInfo(  )
    local protocal = {}
    self:SendProtocal(23214, protocal)
end

function SeerpalaceController:handle23214( data )
	self.model:setChangePartnerId(data.partner_id)
    GlobalEvent:getInstance():Fire(SeerpalaceEvent.Change_Role_Info_Event, data)
end

-- 请求置换英雄
function SeerpalaceController:requestSeerpalaceChangeRole( partner_id, action )
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.action = action
    if action and action == 1 then
    	self.model:setChangeFlag(true)
    end
    self:SendProtocal(23215, protocal)
end

function SeerpalaceController:handle23215( data )
    message(data.msg)
    if data.code == TRUE and self.model:getChangeFlag() then
    	GlobalEvent:getInstance():Fire(SeerpalaceEvent.Change_Role_Success)
    	self.model:setChangeFlag(false)
    end
end

-- 打开先知水晶请求
function SeerpalaceController:requestSummonOpen()
	local protocal = {}
    self:SendProtocal(23234, protocal)
end

-- 当日是否打开过先知水晶（用于红点）
function SeerpalaceController:handle23235( data )
	if data and data.flag then
		self.model:setFirstOpen(data.flag == 0)
		self.model:updateScoreSummonRed()
	end
	self.role_vo = RoleController:getInstance():getRoleVo()
	if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
				if key == "predict_point" and self.label then
                    self.model:updateScoreSummonRed()
                elseif key == "vip_lev" then
                    self.model:updateScoreSummonRed()
                end
            end)
        end
    end
end

---------------------------@ 打开界面
-- 先知殿主界面
function SeerpalaceController:openSeerpalaceMainWindow( status, index )
	if status == true then
		local is_open = self:checkSeerpalaceIsOpen()
		if not is_open then
			return
		end
		if self.seerpalace_main_window == nil then
			self.seerpalace_main_window = SeerpalaceMainWindow.New()
		end
		if self.seerpalace_main_window:isOpen() == false then
			self.seerpalace_main_window:open(index)
		end
	else
		if self.seerpalace_main_window then
			self.seerpalace_main_window:close()
			self.seerpalace_main_window = nil
		end
	end
end

-- 先知积分召唤界面
function SeerpalaceController:openSeerpalaceSummonScoreWindow(status)
	if status == true then
		if self.seerpalace_score_window == nil then
			self.seerpalace_score_window = SeerpalaceSummonScoreWindow.New()
		end
		if self.seerpalace_score_window:isOpen() == false then
			self.seerpalace_score_window:open(index)
		end
	else
		if self.seerpalace_score_window then
			self.seerpalace_score_window:close()
			self.seerpalace_score_window = nil
		end
	end
end

-- 引导需要
function SeerpalaceController:getSeerpalaceMainRoot(  )
	if self.seerpalace_main_window then
		return self.seerpalace_main_window.root_wnd
	end
end

-- 先知商店
function SeerpalaceController:openSeerpalaceShopWindow( status )
	if status == true then
		if self.seerpalace_shop_window == nil then
			self.seerpalace_shop_window = SeerpalaceShopWindow.New()
		end
		if self.seerpalace_shop_window:isOpen() == false then
			self.seerpalace_shop_window:open()
		end
	else
		if self.seerpalace_shop_window then
			self.seerpalace_shop_window:close()
			self.seerpalace_shop_window = nil
		end
	end
end

-- 召唤预览 tag:默认为nil，是先知这个，1是主城召唤
function SeerpalaceController:openSeerpalacePreviewWindow( status, index, tag )
	if status == true then
		if self.seerpalace_preview == nil then
			self.seerpalace_preview = SeerpalacePreviewWindow.New(tag)
		end
		if self.seerpalace_preview:isOpen() == false then
			self.seerpalace_preview:open(index)
		end
	else
		if self.seerpalace_preview then
			self.seerpalace_preview:close()
			self.seerpalace_preview = nil
		end
	end
end

-- 获取先知殿是否开启
function SeerpalaceController:checkSeerpalaceIsOpen( not_tips )
	local is_open = false
	local role_vo = RoleController:getInstance():getRoleVo()
	local limit_config = Config.RecruitHighData.data_seerpalace_const["common_limit"]
	if limit_config and role_vo.lev >= limit_config.val then
		is_open = true
	else
		is_open = false
		if not not_tips then
			message(string.format(TI18N("%d级开启先知圣殿"), limit_config.val))
		end
	end
	return is_open
end

function SeerpalaceController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end