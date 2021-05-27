OpenServiceAcitivityData = OpenServiceAcitivityData or BaseClass()
OpenServiceAcitivityCtrl = OpenServiceAcitivityCtrl or BaseClass(BaseController)

--开服活动相关定义
OpenServiceAcitivityData.GoldDrawChange 								= "gold_draw_change"
OPEN_SERVER_TAB_INDEX.GoldDraw 											= 20 --23
OpenServiceAcitivityData.ViewTable[OPEN_SERVER_TAB_INDEX.GoldDraw] 		= ViewDef.OpenServiceAcitivity.GoldDraw


function OpenServiceAcitivityData:SetGoldDrawTabbarVisible()
	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.GoldDraw] = self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.GoldDraw] or 0
	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.GoldDraw] = self:GetGoldDrawSpareTime() > 0 and 1 or 0
	self:DispatchEvent(OpenServiceAcitivityData.TabbarDisplayChange)
end

--[[
record_list[i] = {
		name = "",
		multiple_num = 0,
		reawrd_gold_num = 0,
		}
]]
function OpenServiceAcitivityData:GetGoldDrawInfo()
	if nil == self.gold_draw_info then
		self.gold_draw_info = {
								draw_num = 0,
								already_used_num = 0,
								next_draw_need_gold_num = 0,
								draw_award_index = 0,
								record_list = {},
							}
	end
	return self.gold_draw_info 
end

function OpenServiceAcitivityData:GoldCanDrawNum()
	return self:GetGoldDrawInfo().draw_num - self:GetGoldDrawInfo().already_used_num
end

function OpenServiceAcitivityData:GoldDrawIsStart()
	return self:GetGoldDrawInfo().already_used_num >= 0
end

function OpenServiceAcitivityData:GoldDrawIsEnd()
	return self:GetGoldDrawInfo().draw_num >= #openYbTurnDiscCfg.roundList
end

function OpenServiceAcitivityData:GetGoldDrawSpareTime()
	return OtherData.Instance:GetOpenServerTime() + 86400 - TimeCtrl.Instance:GetServerTime()
end


----协议
--请求
--请求奖励领取方式
function OpenServiceAcitivityData.SendOpenServerActGoldDrawSelectTypeReq(select_award_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerActGoldDrawReq)
	protocol.req_type = 3
	protocol.select_award_type = select_award_type --领取奖励方式
	protocol:EncodeAndSend()
end

-- 请求领取等级礼包
function OpenServiceAcitivityData.SendOpenServerActGoldDrawReq(req_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerActGoldDrawReq)
	protocol.req_type = req_type	--1 抽奖 2 数据 3 选择奖励
	protocol:EncodeAndSend()
end

--下发
function OpenServiceAcitivityData:OnOpenServeActGoldDrawInfo(protocol)
	local info = self:GetGoldDrawInfo()
	info.draw_num = protocol.draw_num
	info.already_used_num = protocol.already_used_num
	info.next_draw_need_gold_num = protocol.next_draw_need_gold_num
	info.draw_award_index = protocol.draw_award_index
	info.record_list = protocol.record_list
	self:DispatchEvent(OpenServiceAcitivityData.GoldDrawChange, info)
end

function OpenServiceAcitivityData:OnOpenServeActGoldDrawCZResult(protocol)
	self:GetGoldDrawInfo().next_draw_need_gold_num = protocol.next_draw_need_gold_num
	self:GetGoldDrawInfo().draw_num = protocol.draw_num
	self:DispatchEvent(OpenServiceAcitivityData.GoldDrawChange, self:GetGoldDrawInfo())
end

