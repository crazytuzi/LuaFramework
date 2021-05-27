require("scripts/game/explore/explore_data")
require("scripts/game/explore/explore_view")
require("scripts/game/explore/item_show_view")

ExploreCtrl = ExploreCtrl or BaseClass(BaseController)
--寻宝
function ExploreCtrl:__init()
	if	ExploreCtrl.Instance then
		ErrorLog("[ExploreCtrl]:Attempt to create singleton twice!")
	end
	ExploreCtrl.Instance = self

	self.data = ExploreData.New()
	self.view = ExploreView.New(ViewDef.Explore)
	self.item_show_view = ItemShowView.New(ViewDef.ItemShow)

	self.item_kind_list = {}
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function ExploreCtrl:__delete()
	ExploreCtrl.Instance = nil
	
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.item_show_view then
		self.item_show_view:DeleteMe()
		self.item_show_view = nil
	end

	if self.view then
		self.data:DeleteMe()
		self.data = nil
	end

	ExploreCtrl.Instance = nil
end

--登记所有协议
function ExploreCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCXunBaoResult,"OnXunBaoResult")					--寻宝结果
	self:RegisterProtocol(SCWearHouseDataFrom,"OnWearHouseDataFrom")		--仓库数据
	self:RegisterProtocol(SCExploreStorageAddItem,"OnExploreStorageAddItem") -- 寻宝仓库增加物品
	self:RegisterProtocol(SCXunBaoRecord, "OnXunBaoRecord")					--寻宝日志
	self:RegisterProtocol(SCMoveToBag, "OnMoveToBag")						--移动到背包
	self:RegisterProtocol(SCXunBaoBlessingInfo, "OnXunBaoBlessingInfo")		--祝福信息
	-- self:RegisterProtocol(SCDiamondsCreateResult, "OnDiamondsCreateResult")	--钻石打造
	self:RegisterProtocol(SCWorldRewardData,"OnWorldRewardData") 			-- 全服信息
	self:RegisterProtocol(SCXunBaoConfigInfo,"OnXunBaoInfo") 			-- 寻宝信息

	self:RegisterProtocol(SCExchangeResult,"OnExchangeResult") 			-- 积分兑换结果
	self:RegisterProtocol(SCRareTreasureData,"OnRareTreasureData") 			-- 接收龙皇宝藏数据

end

function ExploreCtrl:OnDiamondsCreateResult(protocol)
	self.data:SetCreateResults(protocol)
end

--刷新寻宝钻石
function ExploreCtrl:OnXunBaoBlessingInfo(protocol)
	self.data:SetXunBaoBlessing(protocol)
	self.data:SetOwnRewardData(protocol)
end

function ExploreCtrl:OnXunBaoInfo(protocol)
	self.data:SetXunBaoInfo(protocol)
end

-- 寻宝结果
function ExploreCtrl:OnXunBaoResult(protocol)
	self.data:SetXunBaoBlessing(protocol)

	for k,v in pairs(protocol.xunbao_item_list) do
		table.insert(self.item_kind_list, v)
	end

	if nil == self.delay_result_timer then
		if nil ~= next(self.item_kind_list) then
			local index = 1
			local fly_func = function ()		
				local item = self.item_kind_list[index]
				if nil ~= item then
					self:StartFlyItem(item.item_id)
				end

				if nil == self.delay_result_timer or self.delay_result_timer[4] == 0 then
					self.delay_result_timer = nil
					self.item_kind_list = {}
				else
					index = index + 1
				end
			end
			self.delay_result_timer = GlobalTimerQuest:AddTimesTimer(fly_func, 0.12, #self.item_kind_list)
		end
	else
		-- 延长记时器调用次数 飞行次数最多增加至50次,飞行时间为6秒
		local times = self.delay_result_timer[4] + #protocol.xunbao_item_list
		times = times > 50 and 50 or times
		self.delay_result_timer[4] = times
	end
end

--仓库数据(36, 4)
function ExploreCtrl:OnWearHouseDataFrom(protocol)
	self.data:SetWearHouseData(protocol)
end

-- 寻宝仓库增加物品(36, 20)
function ExploreCtrl:OnExploreStorageAddItem(protocol)
	self.data:ExploreStorageAddItem(protocol.item)
end

--接收寻宝日志(36, 6)
function ExploreCtrl:OnXunBaoRecord(protocol)
	self.data:SetXunBaoRecord(protocol)
	if protocol.record == 2 and protocol.bool_add == 1 and (nil == self.item_show_view or not self.item_show_view:IsOpen()) then
		self:CheckOpenShowView()
	end
end

--检查打开显示视图
function ExploreCtrl:CheckOpenShowView()
	if next(self.data.my_world_record_list) then
		local data = ExploreData.Instance:GetMyWordXunBaoRecord()
		self:OpenItemShow(data.item_data, data.reward_type, true)
	end
end

function ExploreCtrl:OpenItemShow(item_data, reward_type, need_check)
	self.item_show_view:SetData(item_data, reward_type, need_check)
	self.item_show_view:Open()
end

--移动到背包
function ExploreCtrl:OnMoveToBag(protocol)
	if #protocol.item_list == 0 then return end
	self.data:SetXunBaoBag(protocol)
end

-- 抽奖请求
function ExploreCtrl:SendXunbaoReq(type_index, is_zs)
	local protocol = ProtocolPool.Instance:GetProtocol(CSXunbaoReq)
	protocol.type_index = type_index
	protocol.is_replace = is_zs
	protocol:EncodeAndSend()
end

--界面首页数据
function ExploreCtrl:RecvMainInfoCallBack()
	local openlimit = DmkjConfig and DmkjConfig.openlimit or {}
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if role_lv >= openlimit.level then
		self:SendFirstPageDataReq()
	end

	self:SendReturnWarehouseDataReq()
end

--界面首页数据
function ExploreCtrl:SendFirstPageDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSFirstPageDataReq)
	protocol:EncodeAndSend()
end

--移动到背包
function ExploreCtrl:SendMovetoBagReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMovetoBagReq)
	protocol.series = series 
	protocol:EncodeAndSend()
end

--发送仓库数据的请求
function ExploreCtrl:SendReturnWarehouseDataReq()
	self.data.storage_page_list = {}
	local protocol = ProtocolPool.Instance:GetProtocol(CSReturnWarehouseDataReq)
	protocol:EncodeAndSend()
end

--发送钻石打造请求
function ExploreCtrl:SendDiamondsCreateReq(item_type, create_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDiamondsCreateReq)
	protocol.item_type = item_type
	protocol.create_type = create_type
	protocol:EncodeAndSend()
end

--发送个人寻宝次数领奖请求
function ExploreCtrl:SendOwnNumRewardReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRewardXunbaoOwnNumReq)
	protocol.rew_index = index
	protocol:EncodeAndSend()
end

--开始物品飞行
function ExploreCtrl:StartFlyItem(item_id)
	local fly_to_target = ViewManager.Instance:GetUiNode("Explore", "Explore#Storage")
	local path = ""
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)

	if nil ~= item_cfg and item_cfg.icon and item_cfg.icon > 0 then
		path = ResPath.GetItem(item_cfg.icon) --物品图标路径
	end
	
	if "" == path or nil == fly_to_target then return end

	local screen_w = HandleRenderUnit:GetWidth()		--得到显示屏的宽
	local screen_h = HandleRenderUnit:GetHeight()		--得到显示屏的高
	local fly_icon = XUI.CreateImageView(0, 0, path, false)

	fly_icon:setAnchorPoint(0, 0)
	HandleRenderUnit:AddUi(fly_icon, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)  --添加ui
	local world_pos = fly_icon:convertToWorldSpace(cc.p(0,0))
	fly_icon:setPosition(screen_w / 2, screen_h / 2)

	local fly_to_pos = fly_to_target:convertToWorldSpace(cc.p(0,0))
	local move_to =cc.MoveTo:create(0.8, cc.p(fly_to_pos.x, fly_to_pos.y))
	local spawn = cc.Spawn:create(move_to)
	local callback = cc.CallFunc:create(BindTool.Bind(self.ItemFlyEnd, self, fly_icon))
	local action = cc.Sequence:create(spawn, callback)
	fly_icon:runAction(action)
end

--物品飞行结束回调
function ExploreCtrl:ItemFlyEnd(fly_icon)
	if fly_icon then
		fly_icon:removeFromParent() 	--从父节点中删除
	end
end

-- 积分兑换物品
function ExploreCtrl:ExchageItemReq(type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExchangeItemReq)
	protocol.exc_type = type
	protocol.exc_index = index
	protocol:EncodeAndSend()
end

-- 积分兑换结果
function ExploreCtrl:OnExchangeResult(protocol)
	self.data:SetExchangeResult(protocol)
end
function ExploreCtrl:OnRareTreasureData(protocol)
	self.data:SetRareTreasureData(protocol)
end

-- 请求全服奖励信息
function ExploreCtrl:WorldInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldRewardInfoReq)
	protocol:EncodeAndSend()
end

-- 下发全服奖励信息
function ExploreCtrl:OnWorldRewardData(protocol)
	self.data:SetWorldData(protocol)
end

-- 请求龙皇宝藏寻宝(36, 15)
function ExploreCtrl.RareTreasureReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRareTreasureReq)
	protocol:EncodeAndSend()
end

-- 请求进入龙皇秘境(36, 16)
function ExploreCtrl.EnterRareplaceReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterRareplaceReq)
	protocol.index = index -- 进入层数, 从1开始
	protocol:EncodeAndSend()
end

-- 购买龙皇秘境次数(36, 17)
function ExploreCtrl.BuyRareplaceTimesReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyRareplaceTimesReq)
	protocol:EncodeAndSend()
end