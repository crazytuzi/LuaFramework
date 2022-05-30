-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      手机绑定界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
BindPhonePanel = class("BindPhonePanel", function()
	return ccui.Widget:create()
end)

function BindPhonePanel:ctor()
	self.item_list = {}
	self.bind_phone_status = 0
	self:createRootWnd()
	self:registerEvent()
end

function BindPhonePanel:createRootWnd()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/bind_phone_panel"))
	self:addChild(self.root_wnd)
	self:setPosition(- 40, - 80)
	self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.bg = main_container:getChildByName("bg")

	local txt1 = main_container:getChildByName("txt1")
	txt1:setString(TI18N("活动规则"))

	local txt2 = main_container:getChildByName("txt2")
	txt2:setString(TI18N("绑定手机即可领取超值礼包\n每个账号仅能领取一次绑定奖励\n同一手机号仅能绑定一个账号"))
	local real_label = txt2:getVirtualRenderer()
    if real_label then
        real_label:setLineSpacing(6)
    end

	self.item_container = main_container:getChildByName("item_container")
	self.ok_btn = main_container:getChildByName("ok_btn")
	self.ok_btn_label = self.ok_btn:getChildByName("label")

	-- 加载背景图片
	self:loadBackground()
	-- 设置奖励物品
	self:setItemList()
	-- 设置绑定状态
	self:updateBindPhoneStatus()
	-- 判断红点状态
	self:checkRedStatus()
end

function BindPhonePanel:registerEvent()
	registerButtonEventListener(self.ok_btn, function() 
		if self.bind_phone_status == 0 then			-- 前往绑定
			if PLATFORM_NAME == "icebird" then
				if ICEBIRD_APPID and ICEBIRD_ACCESSTOKEN then
					WelfareController:getInstance():requestBindPhone(tostring(ICEBIRD_APPID), tostring(ICEBIRD_ACCESSTOKEN))
				end
			elseif PLATFORM_NAME == "9377" or PLATFORM_NAME == "9377ios" then
				WelfareController:getInstance():requestBindPhone(tostring(0), tostring(0))
			else
				WelfareController:getInstance():openCertifyBindPhoneWindow(true)
			end
		elseif self.bind_phone_status == 1 then		-- 已发送奖励
			message(TI18N("奖励已发送"))
		end
	end, true, 1) 

	if self.bind_phone_event == nil then
		self.bind_phone_event = GlobalEvent:getInstance():Bind(WelfareEvent.UpdateBindPhoneStatus, function() 
			self:updateBindPhoneStatus()
		end)
	end
end

function BindPhonePanel:checkRedStatus()
	-- local bind_data = WelfareController:getInstance():getBindPhoneData()

	-- if phone_number ~= "" and bind_data and bind_data.code == 0 then
	-- else
		WelfareController:getInstance():setWelfareStatus(WelfareIcon.bindphone, false)
	-- end
end

function BindPhonePanel:setItemList()
	local bind_data = WelfareController:getInstance():getBindPhoneData()
	if bind_data == nil or bind_data.items == nil then return end

	for i, v in ipairs(bind_data.items) do
		if self.item_list[i] == nil then
			self.item_list[i] = BackPackItem.new(false, true, false, 1, false, true)
			self.item_container:addChild(self.item_list[i])
			self.item_list[i]:setPosition(60 +(i - 1) * 134, 66)
		end
		local item = self.item_list[i]
		item:setBaseData(v.bid, v.num)
	end
end 

--==============================--
--desc:设置绑定状态
--time:2019-01-28 10:32:29
--@return 
--==============================--
function BindPhonePanel:updateBindPhoneStatus()
	local bind_data = WelfareController:getInstance():getBindPhoneData()
	if bind_data == nil then return end

	if self.bind_phone_status ~= bind_data.code then
		self.bind_phone_status = bind_data.code 
		if bind_data.code == 0 then
			self.ok_btn_label:setString(TI18N("前往绑定"))
		elseif bind_data.code == 1 then
			self.ok_btn_label:setString(TI18N("已发送"))
		end
	end
end

function BindPhonePanel:setVisibleStatus(status)
	bool = bool or false
	self:setVisible(status)
end

function BindPhonePanel:loadBackground()
	local bg_path = PathTool.getPlistImgForDownLoad("bigbg/welfare", "txt_cn_bind_phone")
	self.loader = loadSpriteTextureFromCDN(self.bg, bg_path, ResourcesType.single)
end 

function BindPhonePanel:DeleteMe()
    if self.loader then
        self.loader:DeleteMe()
    end
    self.loader = nil
    if self.item_list then
        for k,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
	if self.bind_phone_event then
		GlobalEvent:getInstance():UnBind(self.bind_phone_event)
		self.bind_phone_event = nil
	end
end 