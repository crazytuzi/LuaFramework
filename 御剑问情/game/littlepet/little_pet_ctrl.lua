require("game/littlepet/little_pet_view")
require("game/littlepet/little_pet_data")
require("game/littlepet/little_pet_handle_book_view")
require("game/littlepet/little_pet_home_package_view")
require("game/littlepet/little_pet_home_recycle_view")
require("game/littlepet/little_pet_warehouse_view")
require("game/littlepet/little_pet_shop_prop_tip_view")
require("game/littlepet/little_pet_toy_bag_view")
require("game/littlepet/little_pet_recyle_select_view")
require("game/littlepet/little_pet_special_item_tips")

LittlePetCtrl = LittlePetCtrl or BaseClass(BaseController)

function LittlePetCtrl:__init()
	if LittlePetCtrl.Instance ~= nil then
		ErrorLog("[LittlePetCtrl] attempt to create singleton twice!")
		return
	end
	LittlePetCtrl.Instance = self

	self.data = LittlePetData.New()
	self.view = LittlePetView.New(ViewName.LittlePetView)
	self.toy_bag_view = LittlePetToyBagView.New(ViewName.LittlePetToyBagView)
	self.shop_prop_view = LittlPetPropTipView.New(ViewName.LittlPetPropTipView)
	self.warehouse_view = LittlePetWarehouseView.New(ViewName.LittlePetWarehouseView)
	self.little_pet_handle_book_view = LittlePetHandleBookView.New(ViewName.LittlePetHandleBookView)
	self.little_pet_home_package_view = LittlePetHomePackageView.New(ViewName.LittlePetHomePackageView)
	self.little_pet_home_recycle_view = LittlePetHomeRecycleView.New(ViewName.LittlePetHomeRecycleView)
	self.little_pet_home_recycle_select_view = LittlePetRecycleSelectView.New(ViewName.LittlePetRecycleSelectView)
	self.little_pet_special_item_tips = LittlePetSpecialItemTips.New(ViewName.LittlePetSpecialItemTips)

	self:RegisterAllProtocols()

	-- 监听背包物品变化
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	if self.main_role_enter_idle_stat == nil then
		self.main_role_enter_idle_stat = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_ENTER_IDLE_STATE, BindTool.Bind(self.OnMainRoleEnterIdleState, self))
	end

	if self.main_role_stop_idle_stat == nil then
		self.main_role_stop_idle_stat = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_STOP_IDLE_STATE, BindTool.Bind(self.OnMainRoleStopIdleState, self))
	end
end

function LittlePetCtrl:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.item_data_event = nil

	if self.main_role_enter_idle_stat ~= nil then
		GlobalEventSystem:UnBind(self.main_role_enter_idle_stat)
		self.main_role_enter_idle_stat = nil
	end

	if self.main_role_stop_idle_stat ~= nil then
		GlobalEventSystem:UnBind(self.main_role_stop_idle_stat)
		self.main_role_stop_idle_stat = nil
	end

	self:CacleChangePetModleTimer()

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.warehouse_view then
		self.warehouse_view:DeleteMe()
		self.warehouse_view = nil
	end

	if self.toy_bag_view then
		self.toy_bag_view:DeleteMe()
		self.toy_bag_view = nil
	end

	if self.shop_prop_view then
		self.shop_prop_view:DeleteMe()
		self.shop_prop_view = nil
	end

	if self.little_pet_handle_book_view then
		self.little_pet_handle_book_view:DeleteMe()
		self.little_pet_handle_book_view = nil
	end

	if self.little_pet_home_package_view then
		self.little_pet_home_package_view:DeleteMe()
		self.little_pet_home_package_view = nil
	end

	if self.little_pet_home_recycle_view then
		self.little_pet_home_recycle_view:DeleteMe()
		self.little_pet_home_recycle_view = nil
	end

	if self.little_pet_home_recycle_select_view then
		self.little_pet_home_recycle_select_view:DeleteMe()
		self.little_pet_home_recycle_select_view = nil
	end

	if self.little_pet_special_item_tips then
		self.little_pet_special_item_tips:DeleteMe()
		self.little_pet_special_item_tips = nil
	end

	LittlePetCtrl.Instance = nil
end

-- 协议注册
function LittlePetCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSLittlePetREQ)
	self:RegisterProtocol(SCLittlePetAllInfo, "OnSCLittlePetAllInfo")
	self:RegisterProtocol(SCLittlePetSingleInfo, "OnSCLittlePetSingleInfo")
	self:RegisterProtocol(SCLittlePetChouRewardList, "OnSCLittlePetChouRewardList")
	self:RegisterProtocol(SCLittlePetNotifyInfo, "OnSCLittlePetNotifyInfo")
	self:RegisterProtocol(SCLittlePetWalk, "OnSCLittlePetWalk")
	self:RegisterProtocol(SCConversionPetInfo, "OnSCConversionPetInfo")
end

function LittlePetCtrl:SendLittlePetREQ(opera_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLittlePetREQ)
	send_protocol.opera_type = opera_type
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

function LittlePetCtrl:OnSCLittlePetAllInfo(protocol)
	self.data:OnSCLittlePetAllInfo(protocol)
	self:FlushLittlePetView()
	
	RemindManager.Instance:Fire(RemindName.LittlePetHome)
	RemindManager.Instance:Fire(RemindName.LittlePetFeed)
	RemindManager.Instance:Fire(RemindName.LittlePetToy)
	RemindManager.Instance:Fire(RemindName.LittlePetShop)
end

function LittlePetCtrl:OnSCLittlePetSingleInfo(protocol)
	self.data:OnSCLittlePetSingleInfo(protocol)
	self:FlushLittlePetView()

	if self.little_pet_special_item_tips:IsOpen() then
		self.little_pet_special_item_tips:Flush()
	end

	RemindManager.Instance:Fire(RemindName.LittlePetHome)
	RemindManager.Instance:Fire(RemindName.LittlePetFeed)
	RemindManager.Instance:Fire(RemindName.LittlePetToy)
	RemindManager.Instance:Fire(RemindName.LittlePetShop)
end

--抽奖信息
function LittlePetCtrl:OnSCLittlePetChouRewardList(protocol)
	self.data:OnSCLittlePetChouRewardList(protocol)
	self:FlushLittlePetView()
	if self.view and self.view:IsOpen() then
		self.view:GetChouJiangReward()
	end
	RemindManager.Instance:Fire(RemindName.LittlePetShop)
end

function LittlePetCtrl:OnSCLittlePetNotifyInfo(protocol)
	self.data:OnSCLittlePetNotifyInfo(protocol)
	self:FlushLittlePetView()
	RemindManager.Instance:Fire(RemindName.LittlePetShop)
end

function LittlePetCtrl:FlushLittlePetView()
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
end

-- 背包更新刷新回收面板
function LittlePetCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.little_pet_home_recycle_view:IsOpen() then
		ViewManager.Instance:FlushView(ViewName.LittlePetHomeRecycleView, "clear")
	end

	if item_id and self.data:IsLittlePetItem(item_id, true) then
		self:FlushLittlePetView()
		RemindManager.Instance:Fire(RemindName.LittlePetHome)
		RemindManager.Instance:Fire(RemindName.LittlePetFeed)
		RemindManager.Instance:Fire(RemindName.LittlePetToy)
	end
end


function LittlePetCtrl:ShowShopPropTip(data, close_call_back)
	if self.shop_prop_view and not self.shop_prop_view:IsOpen() and nil ~= data then 
		self.shop_prop_view:SetData(data, close_call_back)
	end
end

function LittlePetCtrl:ShowToyBagView(data)
	if self.toy_bag_view and not self.toy_bag_view:IsOpen() and nil ~= data then 
		self.toy_bag_view:SetData(data)
	end
end

function LittlePetCtrl:OnSelfChestShopItemList(protocol)
	self.data:IsHavePetReward(protocol)
	RemindManager.Instance:Fire(RemindName.LittlePetWarehouse)

	if self.warehouse_view and self.warehouse_view:IsOpen() then
		self.warehouse_view:Flush()
	end
end

function LittlePetCtrl:OpenRecyleView(call_back)
	self.little_pet_home_recycle_select_view:SetCallBack(call_back)
	self.little_pet_home_recycle_select_view:Open()
end

function LittlePetCtrl:OnMainRoleEnterIdleState()
	self:CacleChangePetModleTimer()
	if IS_ON_CROSSSERVER then
		return
	end

	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsAtk() then
		return
	end

	local delay_time = self.data:GetLittlePetAppearInterval()
	if delay_time <= 0 then return end

	self.change_pet_modle_timer = GlobalTimerQuest:AddDelayTimer(function()
		local is_require = self.data:IsRequirePetWalkPro()
		if not is_require then return end

		local idle_time = Scene.Instance:GetMainRole():GetTotalStandTime()
		if idle_time >= delay_time then
			self:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTEL_PET_REQ_WALK, 1)
		end
	end, delay_time)	
end

function LittlePetCtrl:OnMainRoleStopIdleState()
	self:CacleChangePetModleTimer()
	if IS_ON_CROSSSERVER then
		return
	end

	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsAtk() then
		return
	end

	local is_require = self.data:IsRequirePetWalkPro()
	if not is_require then return end

	self:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTEL_PET_REQ_WALK, 0)
end

function LittlePetCtrl:OnMainRoleTakeOffPet()
	local is_same = self.data:IsScenceShowPetId()
	if not is_same then return end

	self:OnMainRoleStopIdleState()
	self:OnMainRoleEnterIdleState()
end

function LittlePetCtrl:CacleChangePetModleTimer()
	if self.change_pet_modle_timer then
		GlobalTimerQuest:CancelQuest(self.change_pet_modle_timer)
		self.change_pet_modle_timer = nil
	end
end

function LittlePetCtrl:OnSCLittlePetWalk(protocol)
	local obj_id = protocol.obj_id or 0
	local pet_id = protocol.pet_id or 0				--id为0表示宠物消失
	local pet_name = protocol.pet_name or ""
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.obj_id == obj_id then
		self.data:SetSceneShowPetId(pet_id)
	end

	local role = Scene.Instance:GetObj(obj_id)
	if role then
		role.vo.pet_id = pet_id
		role:SetAttr("use_pet_id")
	end
end

function LittlePetCtrl:OnSCConversionPetInfo(protocol)
	self.data:OnSCConversionPetInfo(protocol)
	if self.little_pet_special_item_tips:IsOpen() then
		self.little_pet_special_item_tips:Flush()
	end
	self:FlushLittlePetView()
	RemindManager.Instance:Fire(RemindName.LittlePetHome)
end