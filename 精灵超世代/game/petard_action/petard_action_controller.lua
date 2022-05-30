-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-09-19
-- --------------------------------------------------------------------
PetardActionController = PetardActionController or BaseClass(BaseController)

function PetardActionController:config()
    self.model = PetardActionModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function PetardActionController:getModel()
    return self.model
end

function PetardActionController:registerEvents()
	if not self.close_item_event then
        self.close_item_event = GlobalEvent:getInstance():Bind(MainuiEvent.CLOSE_ITEM_VIEW, function(data)
            if self.red_bag_cache_data and next(self.red_bag_cache_data) ~= nil then
                self:openRedbagInfoWindow(true, self.red_bag_cache_data)
                self.red_bag_cache_data = nil
            end
        end)
    end

    if not self.close_hook_alert_event then
    	self.close_hook_alert_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.Close_Hook_Alert_Event, function()
            if self._show_open_tips_flag then
            	self:openPetardActionTips(true)
            	self._show_open_tips_flag = false
            end
        end)
    end
end

function PetardActionController:registerProtocals()
	self:RegisterProtocal(27000, "handle27000")     -- 花火大会基础信息
	self:RegisterProtocal(27001, "handle27001")     -- 燃放烟花
	self:RegisterProtocal(27002, "handle27002")     -- 我的红包数据
	self:RegisterProtocal(27003, "handle27003")     -- 领取红包
	self:RegisterProtocal(27004, "handle27004")     -- 主界面红包显示状态
	self:RegisterProtocal(27005, "handle27005")     -- 显示花火大会开启提示
	self:RegisterProtocal(27006, "handle27006")     -- 红包传闻
	self:RegisterProtocal(27007, "handle27007")     -- 领取积分奖励
	self:RegisterProtocal(27008, "handle27008")     -- 显示主城大烟花特效
end

-- 花火大会基础信息
function PetardActionController:sender27000(  )
	self:SendProtocal(27000, {})
end

function PetardActionController:handle27000( data )
	self.model:setPetardBaseInfo(data)
	GlobalEvent:getInstance():Fire(PetardActionEvent.Get_Base_Info_Event)
end

-- 燃放烟花
function PetardActionController:sender27001( id, num )
	local protocal = {}
    protocal.id = id
    protocal.num = num
    self:SendProtocal(27001, protocal)
end

function PetardActionController:handle27001( data )
	if data.msg then
		message(data.msg)
	end
end

-- 我的红包数据
function PetardActionController:sender27002(  )
	self:SendProtocal(27002, {})
end

function PetardActionController:handle27002( data )
	self.model:setPetardRedbagData(data)
	GlobalEvent:getInstance():Fire(PetardActionEvent.Get_Redbag_Data_Event)
end

-- 领取红包(查看已领取的红包也走这条协议，并且会返回code=1,code为0会请求刷新红包列表)
function PetardActionController:sender27003( red_packet_id )
	local protocal = {}
    protocal.red_packet_id = red_packet_id
    self:SendProtocal(27003, protocal)
end

function PetardActionController:handle27003( data )
	local is_open = MainuiController:getInstance():itemExhibitionIsOpen()
	if data.msg then
		message(data.msg)
	end
	if data.code == 0 then -- 领取失败，请求刷新红包界面
		self:sender27002()
	end
	if data.get_red_packet_list and next(data.get_red_packet_list) ~= nil then
		-- 获得物品界面正在显示，先缓存数据，关闭获得物品界面后再打开
		if MainuiController:getInstance():itemExhibitionIsOpen() == false then
			self.red_bag_cache_data = data
		else
			self:openRedbagInfoWindow(true, data)
		end
	end
end

-- 主界面红包显示状态（纯后端推）
function PetardActionController:handle27004( data )
	if data.code then
		GlobalEvent:getInstance():Fire(PetardActionEvent.Update_Petard_Main_Redbag_Event, data.code)
	end
end

-- 是否显示花火大会开启提示（纯后端推）
function PetardActionController:handle27005( data )
	if data.flag == TRUE then
		-- 前往领取挂机收益的界面正在显示，则等它关闭后再显示开启弹窗
		if BattleDramaController:getInstance():checkHookAlertIsOpen() then
			self._show_open_tips_flag = true
		else
			self:openPetardActionTips(true)
			self._show_open_tips_flag = false
		end
	else
		self:openPetardActionTips(false)
		self._show_open_tips_flag = false
	end
end

-- 红包传闻
function PetardActionController:sender27006(  )
	self:SendProtocal(27006, {})
end

function PetardActionController:handle27006( data )
	if data.get_red_packet_list then
		GlobalEvent:getInstance():Fire(PetardActionEvent.Get_Redbag_Msg_Data_Event, data.get_red_packet_list)
	end
end

-- 请求领取积分奖励
function PetardActionController:sender27007( id )
	local protocal = {}
    protocal.id = id
    self:SendProtocal(27007, protocal)
end

function PetardActionController:handle27007( data )
	if data.msg then
		message(data.msg)
	end
end

-- 主城大烟花特效
function PetardActionController:handle27008( data )
	if data.msg then
		message(data.msg)
	end
	-- 如果是自己放的烟花，data.msg 为空字符串
	if data.flag == TRUE and data.msg ~= "" then
		MainSceneController:getInstance():showMainSceneEffect(true, 342)
	end
end

------------------------@ 界面相关
-- 打开选择烟花界面
function PetardActionController:openSelectItemWindow( status )
	if status == true then
		if not self.select_item_wnd then
			self.select_item_wnd = PetardSelectItemWindow.New()
		end
		if self.select_item_wnd:isOpen() == false then
			self.select_item_wnd:open()
		end
	else
		if self.select_item_wnd then
			self.select_item_wnd:close()
			self.select_item_wnd = nil
		end
	end
end

-- 燃放烟花确认框
function PetardActionController:openAffirmWindow( status, item_bid, item_num )
	if status == true then
		if not self.petard_affirm_wnd then
			self.petard_affirm_wnd = PetardAffirmWindow.New()
		end
		if self.petard_affirm_wnd:isOpen() == false then
			self.petard_affirm_wnd:open(item_bid, item_num)
		end
	else
		if self.petard_affirm_wnd then
			self.petard_affirm_wnd:close()
			self.petard_affirm_wnd = nil
		end
	end
end

-- 花火大会红包界面
function PetardActionController:openRedbagWindow( status )
	if status == true then
		if not self.petard_redbag_wnd then
			self.petard_redbag_wnd = PetardRedbagWindow.New()
		end
		if self.petard_redbag_wnd:isOpen() == false then
			self.petard_redbag_wnd:open()
		end
	else
		if self.petard_redbag_wnd then
			self.petard_redbag_wnd:close()
			self.petard_redbag_wnd = nil
		end
	end
end

-- 花火大会单个红包信息界面
function PetardActionController:openRedbagInfoWindow( status, data )
	if status == true then
		if not self.redbag_info_wnd then
			self.redbag_info_wnd = PetardRedbagInfoWindow.New()
		end
		if self.redbag_info_wnd:isOpen() == false then
			self.redbag_info_wnd:open(data)
		end
	else
		if self.redbag_info_wnd then
			self.redbag_info_wnd:close()
			self.redbag_info_wnd = nil
		end
		self.red_bag_cache_data = nil -- 清一下缓存数据
	end
end

-- 花火大会开启提示界面
function PetardActionController:openPetardActionTips( status )
	if status == true then
		if not self.petard_action_tips then
			self.petard_action_tips = PetardActionTips.New()
		end
		if self.petard_action_tips:isOpen() == false then
			self.petard_action_tips:open()
		end
	else
		if self.petard_action_tips then
			self.petard_action_tips:close()
			self.petard_action_tips = nil
		end
	end
end

-- 燃放小烟花的特效界面
function PetardActionController:openPetardEffectWindow( status, num )
	if status == true then
		if not self.petard_effect_wnd then
			self.petard_effect_wnd = PetardEffectWindow.new()
		end
		if self.petard_effect_wnd then
			self.petard_effect_wnd:openView(num)
		end
	else
		if self.petard_effect_wnd then
			self.petard_effect_wnd:DeleteMe()
			self.petard_effect_wnd = nil
		end
	end
end

-- 活动奖励界面
function PetardActionController:openPetardAwardWindow( status )
	if status == true then
		if not self.petard_award_wnd then
			self.petard_award_wnd = PetardAwardWindow.New()
		end
		if self.petard_award_wnd:isOpen() == false then
			self.petard_award_wnd:open()
		end
	else
		if self.petard_award_wnd then
			self.petard_award_wnd:close()
			self.petard_award_wnd = nil
		end
	end
end

function PetardActionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end