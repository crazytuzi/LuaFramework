--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 
-- @DateTime:    2019-06-27 19:31:59
-- *******************************
EliteSummonController = EliteSummonController or BaseClass(BaseController)

function EliteSummonController:config()
    self.model = EliteSummonModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function EliteSummonController:getModel()
    return self.model
end
function EliteSummonController:registerProtocals()
    self:RegisterProtocal(23220, "handle23220")
    self:RegisterProtocal(23221, "handle23221")
    self:RegisterProtocal(23222, "handle23222")
    --自选精英召唤
    self:RegisterProtocal(23230, "handle23230")
    self:RegisterProtocal(23231, "handle23231")
    self:RegisterProtocal(23232, "handle23232")
    self:RegisterProtocal(23233, "handle23233")
    
    --预言召唤协议
    self:RegisterProtocal(16690, "handle16690")
    self:RegisterProtocal(16691, "handle16691")
    self:RegisterProtocal(16692, "handle16692")
    self:RegisterProtocal(16693, "handle16693")
    self:RegisterProtocal(16694, "handle16694")
end
--请求活动召唤信息
function EliteSummonController:send23220()
    self:SendProtocal(23220)
end
function EliteSummonController:handle23220(data)
	self.dispather:Fire(EliteSummonEvent.EliteSummon_Message,data)
end
--活动召唤
function EliteSummonController:send23221(times,recruit_type)
	local proto = {}
	proto.times = times
	proto.recruit_type = recruit_type
    self:SendProtocal(23221,proto)
end
function EliteSummonController:handle23221(data)
	message(data.msg)
end
--领取保底礼包
function EliteSummonController:send23222()
    self:SendProtocal(23222)
end
function EliteSummonController:handle23222(data)
	message(data.msg)
end

--自选精英召唤  ***************************
--请求许愿宝可梦自选召唤信息
function EliteSummonController:send23230()
    self:SendProtocal(23230)
end
function EliteSummonController:handle23230(data)
    -- dump(data,"******* handle23230 ******")
    self.model:setSelectSummonData(data)
	self.dispather:Fire(EliteSummonEvent.SelectEliteSummon_Message,data)
end

--许愿宝可梦活动召唤
function EliteSummonController:send23231(times,recruit_type)
	local proto = {}
	proto.times = times
	proto.recruit_type = recruit_type
    self:SendProtocal(23231,proto)
end
function EliteSummonController:handle23231(data)
	message(data.msg)
end
--许愿宝可梦领取保底礼包（成功推送23220）
function EliteSummonController:send23232(award_id, self_award_id)
    -- print("send23232(:::: ", award_id, self_award_id)
    local proto = {}
    proto.award_id = award_id
    proto.self_award_id = self_award_id
    self:SendProtocal(23232, proto)
end
function EliteSummonController:handle23232(data)
    -- dump(data,"===== handle23232 ======")
	message(data.msg)
    if data.flag == 1 then
        TimesummonController:getInstance():openHeroSelectView(false)
    end
end

--设置许愿宝可梦（成功推送26550）
function EliteSummonController:send23233(lucky_bid)
    local proto = {}
    proto.lucky_bid = lucky_bid
    self:SendProtocal(23233,proto)
end
function EliteSummonController:handle23233(data)
	message(data.msg)
end

--预言召唤  ***************************
--基础协议
function EliteSummonController:send16690()
    self:SendProtocal(16690)
end
function EliteSummonController:handle16690(data)
    self.model:setPineBaseData(data)
    self.model:setGoodsItemPos(data.predict_data)
    self.dispather:Fire(EliteSummonEvent.PresageSummon_Message,data)
end
--松果刷新
function EliteSummonController:send16691(_type)
    local proto = {}
    proto.type = _type
    self:SendProtocal(16691, proto)
end
function EliteSummonController:handle16691(data)
    message(data.msg)
    if data.code == 1 then
        self.model:updataOpenPeelPineData(data)
        self.dispather:Fire(EliteSummonEvent.PresageSummon_ReFresh,data)
    end
end
--购买松果币
function EliteSummonController:send16692(num)
    local proto = {}
    proto.num = num
    self:SendProtocal(16692, proto)
end
function EliteSummonController:handle16692(data)
    message(data.msg)
end
--购买物品
function EliteSummonController:send16693(_type)
    local proto = {}
    proto.type = _type
    self:SendProtocal(16693,proto)
end
function EliteSummonController:handle16693(data)
    message(data.msg)
    if data.code == 1 then
        self.model:updataBuyData(data)
        self.model:updataPromptGetBtnStatus(data)
        self.dispather:Fire(EliteSummonEvent.PresageSummon_Buy_Return)
    end
end
--打开松果
function EliteSummonController:send16694(_type)
    local proto = {}
    proto.type = _type
    self:SendProtocal(16694,proto)
end
function EliteSummonController:handle16694(data)
    message(data.msg)
    if data.code == 1 then
        self.model:updataPresageStatus(data)
        self.dispather:Fire(EliteSummonEvent.PresageSummon_Open_Pine)
    end
end
--end  ***************************


-- 打开自选召唤宝可梦选择界面
function EliteSummonController:openSummonSelectWindow( status )
	if status == true then
		if not self.summon_select_wnd then
			self.summon_select_wnd = SummonSelectWindow.New()
		end
		if self.summon_select_wnd:isOpen() == false then
			self.summon_select_wnd:open(data)
		end
	else
		if self.summon_select_wnd then
			self.summon_select_wnd:close()
			self.summon_select_wnd = nil
		end
	end
end


function EliteSummonController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end