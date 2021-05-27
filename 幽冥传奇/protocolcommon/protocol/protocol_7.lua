--===================================请求==================================

-- 通过物品序列号装备一件物品
CSFitOutEquip = CSFitOutEquip or BaseClass(BaseProtocolStruct)
function CSFitOutEquip:__init()
	self:InitMsgType(7, 1)
	self.series = 0
	self.seat = 0					--0表示左侧，1表示右侧
	self.tran_stone = 0 			-- (uchar)是否转移宝石， 0不转移, 1转移
end

function CSFitOutEquip:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUChar(self.seat)
	MsgAdapter.WriteUChar(self.tran_stone)
end

-- 根据物品序列号脱下一件装备
CSTakeOffEquip = CSTakeOffEquip or BaseClass(BaseProtocolStruct)
function CSTakeOffEquip:__init()
	self:InitMsgType(7, 2)
	self.series = 0
end

function CSTakeOffEquip:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 根据装备位置脱下装备
CSTakeOffEquipBySeat = CSTakeOffEquipBySeat or BaseClass(BaseProtocolStruct)
function CSTakeOffEquipBySeat:__init()
	self:InitMsgType(7, 3)
	self.seat = 0
end

function CSTakeOffEquipBySeat:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.seat)
end

-- 获取自身的装备
CSGetOwnEquipInfo = CSGetOwnEquipInfo or BaseClass(BaseProtocolStruct)
function CSGetOwnEquipInfo:__init()
	self:InitMsgType(7, 4)
end

function CSGetOwnEquipInfo:Encode()
	self:WriteBegin()
end

-- 获取其他玩的装备
CSGetOtherOneEquipInfo = CSGetOtherOneEquipInfo or BaseClass(BaseProtocolStruct)
function CSGetOtherOneEquipInfo:__init()
	self:InitMsgType(7, 5)
	self.role_name = ""
end

function CSGetOtherOneEquipInfo:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)

end

-- 是否显示时装(改变后会刷新外观)
CSSetShowFashionReq = CSSetShowFashionReq or BaseClass(BaseProtocolStruct)
function CSSetShowFashionReq:__init()
	self:InitMsgType(7, 6)
	self.show_wuqi = 0 			--1显示, 0隐藏
	self.show_cloth = 0			--1显示, 0隐藏
end

function CSSetShowFashionReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.show_wuqi)
	MsgAdapter.WriteUChar(self.show_cloth)
end

-- 查看离线玩家的消息
CSGetOutLinePlayerInfo = CSGetOutLinePlayerInfo or BaseClass(BaseProtocolStruct)
function CSGetOutLinePlayerInfo:__init()
	self:InitMsgType(7, 7)
	self.role_name = 0
	self.role_id = 0
	self.show_type = 0
end

function CSGetOutLinePlayerInfo:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)
	MsgAdapter.WriteUInt(self.role_id)
	MsgAdapter.WriteUChar(self.show_type)
end

-- 查看离线玩家的战将消息(返回协议44 19)
CSGetOutLineZhanjiangInfo = CSGetOutLineZhanjiangInfo or BaseClass(BaseProtocolStruct)
function CSGetOutLineZhanjiangInfo:__init()
	self:InitMsgType(7, 8)
	self.role_id = 0
	self.zhanjiang_id = 0
end

function CSGetOutLineZhanjiangInfo:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.role_id)
	MsgAdapter.WriteUChar(self.zhanjiang_id)
end

-- 装备投保(修改了装备属性返回8 9)
CSEquipInsure = CSEquipInsure or BaseClass(BaseProtocolStruct)
function CSEquipInsure:__init()
	self:InitMsgType(7, 9)
	self.series = 0
	self.insure_count = 0
end

function CSEquipInsure:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUChar(self.insure_count)
end

-- 装备回收
CSEquipRecycle = CSEquipRecycle or BaseClass(BaseProtocolStruct)
function CSEquipRecycle:__init()
	self:InitMsgType(7, 10)
	self.recycle_type = 0 				--是否为vip随身回收, 1是, 0否
end

function CSEquipRecycle:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.recycle_type)
end

-- 获得装备槽强化数据(返回7 15)
CSEquipStrengthenInfoReq = CSEquipStrengthenInfoReq or BaseClass(BaseProtocolStruct)
function CSEquipStrengthenInfoReq:__init()
	self:InitMsgType(7, 11)
end

function CSEquipStrengthenInfoReq:Encode()
	self:WriteBegin()
end

-- 强化装备槽(返回7 16)
CSEquipStrengthen = CSEquipStrengthen or BaseClass(BaseProtocolStruct)
function CSEquipStrengthen:__init()
	self:InitMsgType(7, 12)
	self.slot = 0
	self.index = 0 -- 是否色勾选钻石替代, 1是, 0不是
end

function CSEquipStrengthen:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot)
	MsgAdapter.WriteUChar(self.index)
end

-- 申请传世装备等级数据
CSChuanShiInfoReq = CSChuanShiInfoReq or BaseClass(BaseProtocolStruct)
function CSChuanShiInfoReq:__init()
	self:InitMsgType(7, 13)
end

function CSChuanShiInfoReq:Encode()
	self:WriteBegin()
end

-- 传世装备操作(升级与进阶/激活)
CSChuanShiOptReq = CSChuanShiOptReq or BaseClass(BaseProtocolStruct)
CSChuanShiOptReq.OPT_TYPE = {
	UP_LEVEL = 1,
	UP_GRADE = 2,
}
function CSChuanShiOptReq:__init()
	self:InitMsgType(7, 14)
	self.opt_type = 0	-- 1:升级 2 :进阶/激活
	self.slot = 0		-- 槽位(从0开始)
end

function CSChuanShiOptReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
	MsgAdapter.WriteUChar(self.slot)
end


-- 是否显示绝世时装(改变后会刷新外观)
CSSetShowPeerlessReq = CSSetShowPeerlessReq or BaseClass(BaseProtocolStruct)
function CSSetShowPeerlessReq:__init()
	self:InitMsgType(7, 15)
	self.show_wuqi = 0 			--1显示, 0隐藏
	self.show_cloth = 0			--1显示, 0隐藏
end

function CSSetShowPeerlessReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.show_wuqi)
	MsgAdapter.WriteUChar(self.show_cloth)
end

-- 装备附灵
CSEquipFulingReq = CSEquipFulingReq or BaseClass(BaseProtocolStruct)
function CSEquipFulingReq:__init()
	self:InitMsgType(7, 16)
	self.is_in_bag = 1				-- 是否在背包中 1:背包中 0:身上
	self.fuling_equip = 0			-- 要附灵的装备guid
	self.consume_equip = 0			-- 要消耗的装备guid
end

function CSEquipFulingReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.is_in_bag)
	CommonReader.WriteSeries(self.fuling_equip)
	CommonReader.WriteSeries(self.consume_equip)
end

-- 下发传世装备槽升级数据
CSEquipFulingShiftReq = CSEquipFulingShiftReq or BaseClass(BaseProtocolStruct)
function CSEquipFulingShiftReq:__init()
	self:InitMsgType(7, 17)
	self.is_in_bag = 1				-- 是否在背包中 1:背包中 0:身上
	self.fuling_equip = 0			-- 要附灵的装备guid
	self.consume_equip = 0			-- 要消耗的装备guid
end

function CSEquipFulingShiftReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.is_in_bag)
	CommonReader.WriteSeries(self.fuling_equip)
	CommonReader.WriteSeries(self.consume_equip)
end

-- 装备铸魂
CSMoldingSoulReq = CSMoldingSoulReq or BaseClass(BaseProtocolStruct)
function CSMoldingSoulReq:__init()
	self:InitMsgType(7, 18)
end

function CSMoldingSoulReq:Encode()
	self:WriteBegin()
end

-- 装备槽精炼
CSAffinageReq = CSAffinageReq or BaseClass(BaseProtocolStruct)
function CSAffinageReq:__init()
	self:InitMsgType(7, 20)
	self.slot = 0	-- 槽位，从0开始
end

function CSAffinageReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot)
end

-- 获取铸魂数据
CSGetMoldingSoulInfo = CSGetMoldingSoulInfo or BaseClass(BaseProtocolStruct)
function CSGetMoldingSoulInfo:__init()
	self:InitMsgType(7, 21)
end

function CSGetMoldingSoulInfo:Encode()
	self:WriteBegin()
end

-- 请求镶嵌宝石
CSEquipInsetReq = CSEquipInsetReq or BaseClass(BaseProtocolStruct)
function CSEquipInsetReq:__init()
	self:InitMsgType(7, 23)
	self.equip_slot = 0
	self.stone_slot = 0
	self.stone_series = 0
end

function CSEquipInsetReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equip_slot)
	MsgAdapter.WriteUChar(self.stone_slot)
	CommonReader.WriteSeries(self.stone_series)
end

-- 镶嵌宝石信息
CSEquipInsetInfoReq = CSEquipInsetInfoReq or BaseClass(BaseProtocolStruct)
function CSEquipInsetInfoReq:__init()
	self:InitMsgType(7, 24)
end

function CSEquipInsetInfoReq:Encode()
	self:WriteBegin()
end

-- 装备回收二次面板(返回7 28)
CSBagRecycleSecondPanelReq = CSBagRecycleSecondPanelReq or BaseClass(BaseProtocolStruct)
function CSBagRecycleSecondPanelReq:__init()
	self:InitMsgType(7, 25)
	self.equip_num = 0
	self.recycle_type = 0			-- 1 背包 2 宝物仓库
	self.equip_list = {}
end

function CSBagRecycleSecondPanelReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equip_num)
	MsgAdapter.WriteUChar(self.recycle_type)
	for k, v in pairs(self.equip_list) do
		MsgAdapter.WriteUChar(v.cfg_index)
		CommonReader.WriteSeries(v.series)
	end
end

-- 装备回收二次面板(返回7 13)
CSBagRecycleRewardReq = CSBagRecycleRewardReq or BaseClass(BaseProtocolStruct)
function CSBagRecycleRewardReq:__init()
	self:InitMsgType(7, 26)
	self.equip_num = 0
	self.recycle_type = 0						-- 1 背包 2 宝物仓库
	self.btn_index = 0  						-- 1免费, 2双倍
	self.equip_list = {}
end

function CSBagRecycleRewardReq:Encode()
	self:WriteBegin()

	MsgAdapter.WriteUChar(self.equip_num)
	MsgAdapter.WriteUChar(self.recycle_type)
	MsgAdapter.WriteUChar(self.btn_index)
	
	for k, v in pairs(self.equip_list) do
		MsgAdapter.WriteUChar(v.cfg_index)
		CommonReader.WriteSeries(v.series)
	end
end

-- 卸下宝石
CSEquipUnloadStoneReq = CSEquipUnloadStoneReq or BaseClass(BaseProtocolStruct)
function CSEquipUnloadStoneReq:__init()
	self:InitMsgType(7, 27)
	self.equip_slot = 0
	self.stone_slot = 0
end

function CSEquipUnloadStoneReq:Encode( )
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equip_slot)
	MsgAdapter.WriteUChar(self.stone_slot)
end

-- 获取封神信息
CSGetApotheosisInfo = CSGetApotheosisInfo or BaseClass(BaseProtocolStruct)
function CSGetApotheosisInfo:__init()
	self:InitMsgType(7, 28)
end

function CSGetApotheosisInfo:Encode()
	self:WriteBegin()
end

-- 请求宝石升级
CSStoneUpgrade = CSStoneUpgrade or BaseClass(BaseProtocolStruct)
function CSStoneUpgrade:__init()
	self:InitMsgType(7, 29)
	self.equip_slot = 0
	self.stone_slot = 0
end

function CSStoneUpgrade:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equip_slot)
	MsgAdapter.WriteUChar(self.stone_slot)
end

-- 请求洗炼
CSEquipRefineReq = CSEquipRefineReq or BaseClass(BaseProtocolStruct)
function CSEquipRefineReq:__init()
	self:InitMsgType(7, 30)
	self.series = 0
	self.lock_1 = 0
	self.lock_2 = 0
	self.lock_3 = 0
end

function CSEquipRefineReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUChar(self.lock_1)
	MsgAdapter.WriteUChar(self.lock_2)
	MsgAdapter.WriteUChar(self.lock_3)
end

-- 锻造-融合 请求装备融合
CSEquipmentFusion = CSEquipmentFusion or BaseClass(BaseProtocolStruct)
function CSEquipmentFusion:__init()
	self:InitMsgType(7, 31)
	self.series1 = 0
	self.series2 = 0
	self.index = 0
end

function CSEquipmentFusion:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series1)
	CommonReader.WriteSeries(self.series2)
	MsgAdapter.WriteUChar(self.index)
end

-- 神佑元素进阶
CSElementUpgrade = CSElementUpgrade or BaseClass(BaseProtocolStruct)
function CSElementUpgrade:__init()
	self:InitMsgType(7, 32)
	self.is_in_bag = 0
	self.series = 0
	self.elem_index = 0		-- 元素索引，从0开始
end

function CSElementUpgrade:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.is_in_bag)
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUChar(self.elem_index)
end

-- 进入秘境之门
CSEnterMysticGate = CSEnterMysticGate or BaseClass(BaseProtocolStruct)
function CSEnterMysticGate:__init()
	self:InitMsgType(7, 33)
	self.scene_id = 0
	self.scene_x = 0
	self.scene_y = 0
end

function CSEnterMysticGate:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteInt(self.scene_x)
	MsgAdapter.WriteInt(self.scene_y)
end

-- 请求神龙戒魂信息
CSRingSoulInfoReq = CSRingSoulInfoReq or BaseClass(BaseProtocolStruct)
CSRingSoulInfoReq.OPT_TYPE_INFO = 1
CSRingSoulInfoReq.OPT_TYPE_UP = 2
function CSRingSoulInfoReq:__init()
	self:InitMsgType(7, 35)
	self.opt_type = 1	-- 1 神龙戒魂信息，2 升级神龙戒魂
end

function CSRingSoulInfoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
end

-- 神装
CSGodEquipReq = CSGodEquipReq or BaseClass(BaseProtocolStruct)
function CSGodEquipReq:__init()
	self:InitMsgType(7, 36)
	self.equip_slot = 0
end

function CSGodEquipReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.equip_slot)
end

-- 激活热血装备
CSActRexueEquipReq = CSActRexueEquipReq or BaseClass(BaseProtocolStruct)
function CSActRexueEquipReq:__init()
	self:InitMsgType(7, 37)
	self.series = 0
end

function CSActRexueEquipReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 申请热血装备注灵数据
CSRexueEquipZhulingDataReq = CSRexueEquipZhulingDataReq or BaseClass(BaseProtocolStruct)
function CSRexueEquipZhulingDataReq:__init()
	self:InitMsgType(7, 38)
end

function CSRexueEquipZhulingDataReq:Encode()
	self:WriteBegin()
end

-- 注灵热血装备
CSRexueEquipZhulingOptReq = CSRexueEquipZhulingOptReq or BaseClass(BaseProtocolStruct)
function CSRexueEquipZhulingOptReq:__init()
	self:InitMsgType(7, 39)
	self.slot = 0	-- 装备槽索引(0-7)
	self.equip_list = {}	-- 装备列表
end

function CSRexueEquipZhulingOptReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot)
	MsgAdapter.WriteShort(#self.equip_list)
	for i = 1, #self.equip_list do
		CommonReader.WriteSeries(self.equip_list[i].series)
	end
end

-- 附魔热血装备
CSRexueEquipFumoOptReq = CSRexueEquipFumoOptReq or BaseClass(BaseProtocolStruct)
function CSRexueEquipFumoOptReq:__init()
	self:InitMsgType(7, 40)
	self.slot = 0	-- 装备槽索引(0-7)
	self.equip_list = {}	-- 装备列表
end

function CSRexueEquipFumoOptReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot)
end

--去请求背包熔炼
CSBagMeltingReq = CSBagMeltingReq or BaseClass(BaseProtocolStruct)
function CSBagMeltingReq:__init()
	self:InitMsgType(7, 41)
	self.from_index = 0 		-- 来自   1-背包   2-寻宝仓库
	self.is_quick_melting = 0	-- 是否一键熔炼 1为一键熔炼
	self.recycle_series_list = {}	-- 待回收装备序列号
end

function CSBagMeltingReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.from_index)
	MsgAdapter.WriteUChar(self.is_quick_melting)

	--表长度
	local legth = #self.recycle_series_list
	MsgAdapter.WriteUChar(self.is_quick_melting == 0 and legth or 0)
	
	--序列号
	for i, series in ipairs(self.recycle_series_list) do
		CommonReader.WriteSeries(series)
	end
end

--获取纹章信息(返回 7 39)
CSCrestInfoReq = CSCrestInfoReq or BaseClass(BaseProtocolStruct)
function CSCrestInfoReq:__init()
	self:InitMsgType(7, 42)
end

function CSCrestInfoReq:Encode()
	self:WriteBegin()
end

--升级纹章(返回 7 40)
CSUpCrestSlotReq = CSUpCrestSlotReq or BaseClass(BaseProtocolStruct)
function CSUpCrestSlotReq:__init()
	self:InitMsgType(7, 43)
	self.crest_slot	= 0	-- 纹章槽位, 从1开始
end

function CSUpCrestSlotReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.crest_slot)
end

--一键强化装备(返回 7 41)
CSOnekeyStrenthenEquipReq = CSOnekeyStrenthenEquipReq or BaseClass(BaseProtocolStruct)
function CSOnekeyStrenthenEquipReq:__init()
	self:InitMsgType(7, 44)
	
end

function CSOnekeyStrenthenEquipReq:Encode()
	self:WriteBegin()
	
end

-- 一键装备槽精炼
CSOneKeyAffinageReq = CSOneKeyAffinageReq or BaseClass(BaseProtocolStruct)
function CSOneKeyAffinageReq:__init()
	self:InitMsgType(7, 45)
end

function CSOneKeyAffinageReq:Encode()
	self:WriteBegin()
end

-- 一键铸魂请求
CSOneKeyMoldingSoulReq = CSOneKeyMoldingSoulReq or BaseClass(BaseProtocolStruct)
function CSOneKeyMoldingSoulReq:__init()
	self:InitMsgType(7, 46)
end

function CSOneKeyMoldingSoulReq:Encode()
	self:WriteBegin()
end

-- 神器器魂请求
CSShenQiUpgrade = CSShenQiUpgrade or BaseClass(BaseProtocolStruct)
function CSShenQiUpgrade:__init()
	self:InitMsgType(7, 47)
end

function CSShenQiUpgrade:Encode()
	self:WriteBegin()
end

-- 神器基础属性升级
CSShenQiAttrUpgrade = CSShenQiAttrUpgrade or BaseClass(BaseProtocolStruct)
function CSShenQiAttrUpgrade:__init()
	self:InitMsgType(7, 48)
	self.type = 0
end

function CSShenQiAttrUpgrade:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

-- 请求鉴定装备 返回(7, 47)
-- CSAuthenticate = CSAuthenticate or BaseClass(BaseProtocolStruct)
-- function CSAuthenticate:__init()
-- 	self:InitMsgType(7, 49)
-- 	self.equip_series = 0
-- end

-- function CSAuthenticate:Encode()
-- 	self:WriteBegin()
-- 	CommonReader.WriteSeries(self.equip_series)
-- end

CSAuthenticate = CSAuthenticate or BaseClass(BaseProtocolStruct)
function CSAuthenticate:__init()
	self:InitMsgType(7, 49)
	self.jd_event = 0  				-- 鉴定事件   1-鉴定，2-替换
	self.equip_index = 0 			-- 装备槽位 从0开始
	self.jd_type = 0 				-- 鉴定类型 	1-普通， 2精致， 3极致
	self.attr_index = 0 			-- 属性槽位，从1开始
	self.jl_index = 0 				-- 几率索引，从1开始
	self.attr_idx = 0 		 		-- 属性槽位数量
	self.lock_list = {}
end

function CSAuthenticate:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.jd_event)
	MsgAdapter.WriteUChar(self.equip_index)
	if self.jd_event == 1 then
		MsgAdapter.WriteUChar(self.jd_type)
		if self.jd_type == 2 or self.jd_type == 3 then
			MsgAdapter.WriteUChar(self.attr_index)
			MsgAdapter.WriteUChar(self.jl_index)
		end
	elseif self.jd_event == 2 then
		MsgAdapter.WriteUChar(self.attr_idx)
		for i = 1, 5 do
			MsgAdapter.WriteUChar(self.lock_list[i])
		end
	end
end


-- 请求灭霸手套增幅 返回(7, 48)
CSHandAdd = CSHandAdd or BaseClass(BaseProtocolStruct)
function CSHandAdd:__init()
	self:InitMsgType(7, 50)
	self.equip_list = {}
end

function CSHandAdd:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(#self.equip_list)
	for i,v in ipairs(self.equip_list) do
		CommonReader.WriteSeries(v)
	end
end

-- 请求灭霸手套打造 返回(7, 49)
CSHandCompose = CSHandCompose or BaseClass(BaseProtocolStruct)
function CSHandCompose:__init()
	self:InitMsgType(7, 51)
end

function CSHandCompose:Encode()
	self:WriteBegin()
end

-- 请求豪装升阶（合成）
CSLuxuryEquipUpgradeReq = CSLuxuryEquipUpgradeReq or BaseClass(BaseProtocolStruct)
function CSLuxuryEquipUpgradeReq:__init()
	self:InitMsgType(7, 52)
	self.pos = 0
end

function CSLuxuryEquipUpgradeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.pos)
end

--请求加点
CSPointInfoReq = CSPointInfoReq or BaseClass(BaseProtocolStruct)
function CSPointInfoReq:__init()
	self:InitMsgType(7, 53)
	self.point_list = {}
end

function CSPointInfoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(TableSize(self.point_list))
	for k, v in ipairs(self.point_list) do
		local value = v < 0 and 0 or v
		MsgAdapter.WriteUInt(value)
	end
end

CSReqComposeAtBodtEquip = CSReqComposeAtBodtEquip or BaseClass(BaseProtocolStruct)
function CSReqComposeAtBodtEquip:__init()
	self:InitMsgType(7, 54)
	self.compose_type = 0
	self.equip_pos = 0
end

function CSReqComposeAtBodtEquip:Encode()
	self:WriteBegin()

	MsgAdapter.WriteUShort(self.compose_type)
	MsgAdapter.WriteUShort(self.equip_pos)
end

--请求领取手套
CSReqHandLingqu = CSReqHandLingqu or BaseClass(BaseProtocolStruct)
function CSReqHandLingqu:__init()
	self:InitMsgType(7, 55)
end

function CSReqHandLingqu:Encode()
	self:WriteBegin()
end

-- 神铸 返回(7, 54)
CSRexueShenzhu = CSRexueShenzhu or BaseClass(BaseProtocolStruct)
function CSRexueShenzhu:__init()
	self:InitMsgType(7, 56)
	self.slot = 0 -- 升级槽位, 从1开始
	self.index_1 = 0 -- 是否使用增加机率物品, 0否, 1是 
	self.index_2 = 0 -- 是否使用保级, 0否, 1是 
end

function CSRexueShenzhu:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot)
	MsgAdapter.WriteUChar(self.index_1)
	MsgAdapter.WriteUChar(self.index_2)
end

-- 神格 返回(7, 55)
CSRexueShenge = CSRexueShenge or BaseClass(BaseProtocolStruct)
function CSRexueShenge:__init()
	self:InitMsgType(7, 57)
	self.slot = 0 -- 升级槽位, 从1开始
end

function CSRexueShenge:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot)
end

-- 锻造-融合-装备分解
CS_7_58 = CS_7_58 or BaseClass(BaseProtocolStruct)
function CS_7_58:__init()
	self:InitMsgType(7, 58)
	self.series_list = {} -- 装备guid
end

function CS_7_58:Encode()
	self:WriteBegin()
	local count = #self.series_list

	-- 分解数量限制 服务端单次最多分解20个
	count = count >= 20 and 20 or count
	MsgAdapter.WriteInt(count)
	for i = 1, count do
		local series = self.series_list[i] or 0
		CommonReader.WriteSeries(series)
	end
end

--===================================下发==================================

-- 下发装备一件物品
SCOneEquip = SCOneEquip or BaseClass(BaseProtocolStruct)
function SCOneEquip:__init()
	self:InitMsgType(7, 1)
	self.equip = CommonStruct.ItemDataWrapper()
end

function SCOneEquip:Decode()
	self.equip = CommonReader.ReadItemData()
end

-- 脱下一件装备
SCTakeOffOneEquip = SCTakeOffOneEquip or BaseClass(BaseProtocolStruct)
function SCTakeOffOneEquip:__init()
	self:InitMsgType(7, 2)
	self.series = 0
end

function SCTakeOffOneEquip:Decode()
	self.series = CommonReader.ReadSeries()
end

-- 下发玩家装备数据
SCEquipList = SCEquipList or BaseClass(BaseProtocolStruct)
function SCEquipList:__init()
	self:InitMsgType(7, 3)
	self.equip_count = 0
	self.equip_list = {}
end

function SCEquipList:Decode()
	self.equip_count = MsgAdapter.ReadUChar()
	self.equip_list = {}
	for i = 1, self.equip_count do
		self.equip_list[i] = CommonReader.ReadItemData()
	end

end

-- 装备的耐久发生变化
SCEquipDurabilityChange = SCEquipDurabilityChange or BaseClass(BaseProtocolStruct)
function SCEquipDurabilityChange:__init()
	self:InitMsgType(7, 4)
	self.series = 0
	self.durability = 0
	self.durability_max = 0
end

function SCEquipDurabilityChange:Decode()
	self.series = CommonReader.ReadSeries()
	self.durability = MsgAdapter.ReadUInt()
	self.durability_max = MsgAdapter.ReadUInt()
end

-- 下发查看其他玩家的装备
SCOtherRoleEquipList = SCOtherRoleEquipList or BaseClass(BaseProtocolStruct)
function SCOtherRoleEquipList:__init()
	self:InitMsgType(7, 5)
	self.vo = RoleVo.New()
	self.up_num = 0
	self.down_num = 0
	self.attr_other = {}
end

function SCOtherRoleEquipList:Decode()
	self.vo.name = MsgAdapter.ReadStr()
	self.vo[OBJ_ATTR.ACTOR_PROF] = MsgAdapter.ReadUChar()
	self.vo[OBJ_ATTR.ACTOR_CIRCLE] = MsgAdapter.ReadUChar()
	self.vo[OBJ_ATTR.CREATURE_LEVEL] = MsgAdapter.ReadUShort()
	self.vo[OBJ_ATTR.ACTOR_SEX] = MsgAdapter.ReadUChar()
	self.vo.guild_name = MsgAdapter.ReadStr()
	self.vo[OBJ_ATTR.ACTOR_BATTLE_POWER] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ENTITY_MODEL_ID] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_MOUNT_APPEARANCE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_WING_APPEARANCE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = MsgAdapter.ReadUInt()
	self.vo.equip_count = MsgAdapter.ReadUChar()
	self.vo.equip_list = {}
	for i = 0, self.vo.equip_count - 1 do
		self.vo.equip_list[i] = CommonReader.ReadItemData()
		self.vo.equip_list[i].index = i
	end
	self.vo.equip_slots_count = MsgAdapter.ReadUChar()
	self.vo.equip_slots = {}
	for i = 0, self.vo.equip_slots_count - 1 do
		self.vo.equip_slots[i] = MsgAdapter.ReadUChar()
	end
	self.vo[OBJ_ATTR.ACTOR_SOCIAL_MASK] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_VIP_GRADE] = MsgAdapter.ReadInt()
	self.vo[OBJ_ATTR.ACTOR_MAGIC_EQUIPID] = MsgAdapter.ReadInt()
	self.vo[OBJ_ATTR.ACTOR_WARPATH_ID] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_SOUL1] = MsgAdapter.ReadUInt()   --通灵境界1总等级 = 阶数*等级,(最高16阶, 每阶12级)
	CommonReader.ReadBaseAttr(self.vo)
	self.vo[OBJ_ATTR.CREATURE_HP] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.CREATURE_MAX_HP] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.CREATURE_MP] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.CREATURE_MAX_MP] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.CREATURE_HIT_RATE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.CREATURE_DOGE_RATE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.CREATURE_LUCK] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.CREATURE_CURSE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_RUNEESSENCE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_PK_VALUE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_CHARM_VALUE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_CIRCLE_SOUL] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_INNER] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_MAX_INNER] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_RIDE_LEVEL] = MsgAdapter.ReadInt()
	self.vo[OBJ_ATTR.ACTOR_SWING_EXP] = MsgAdapter.ReadInt()
	self.vo[OBJ_ATTR.ACTOR_MAGIC_EQUIPEXP] = MsgAdapter.ReadInt()
	self.vo[OBJ_ATTR.ACTOR_CRITRATE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_RESISTANCECRIT] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_RESISTANCECRITRATE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_BOSSCRITRATE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_BATTACKBOSSCRITVALUE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_DIERRFRESHCD] = CommonReader.ReadServerUnixTime()
	-- self.vo.achieve_babge = CommonReader.ReadAchieveBabge()
end

-- 删除一件装备
SCDelOneEquip = SCDelOneEquip or BaseClass(BaseProtocolStruct)
function SCDelOneEquip:__init()
	self:InitMsgType(7, 6)
	self.series = 0
end

function SCDelOneEquip:Decode()
	self.series = CommonReader.ReadSeries()
end

-- 查找离线玩家的信息
SCOutlineRoleEquipList = SCOutlineRoleEquipList or BaseClass(BaseProtocolStruct)
function SCOutlineRoleEquipList:__init()
	self:InitMsgType(7, 7)
	self.vo = RoleVo.New()
	self.attr_other = {}
end

function SCOutlineRoleEquipList:Decode()
	self.vo.name = MsgAdapter.ReadStr()
	self.vo[OBJ_ATTR.ACTOR_PROF] = MsgAdapter.ReadUChar()
	self.vo[OBJ_ATTR.ACTOR_CIRCLE] = MsgAdapter.ReadUChar()
	self.vo[OBJ_ATTR.CREATURE_LEVEL] = MsgAdapter.ReadUShort()
	self.vo[OBJ_ATTR.ACTOR_SEX] = MsgAdapter.ReadUChar()
	self.vo.guild_name = MsgAdapter.ReadStr()
	self.vo[OBJ_ATTR.ACTOR_BATTLE_POWER] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ENTITY_MODEL_ID] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_WING_APPEARANCE] = MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_WARPATH_ID] =  MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE] =  MsgAdapter.ReadUInt()
	self.vo[OBJ_ATTR.ACTOR_GENUINEQI_APPEARANCE] =  MsgAdapter.ReadUInt() -- 真气外观

	-- 装备
	self.vo.equip_count = MsgAdapter.ReadUChar()
	self.vo.equip_list = {}
	for i = 1, self.vo.equip_count do
		self.vo.equip_list[i - 1] = CommonReader.ReadItemData()
	end


	self.vo.show_type = MsgAdapter.ReadUChar() 	-- 查看 OUT_LINE_SHOW_TYPE

	-- 装备槽数据
	self.vo.equip_slots_count = MsgAdapter.ReadUChar()
	self.vo.equip_slots = {}
	for i = 0, self.vo.equip_slots_count - 1 do
		self.vo.equip_slots[i] = MsgAdapter.ReadUShort()
	end

	-- 宝石
	self.vo.equip_slots_count = MsgAdapter.ReadUChar()
	self.vo.stone_info = {}
	for i = 1, self.vo.equip_slots_count do
		self.vo.stone_info[i - 1] = {}
		local stone_slot_count = MsgAdapter.ReadUChar()
		for j = 1, stone_slot_count do
			self.vo.stone_info[i - 1][j] = MsgAdapter.ReadUShort()
		end
	end

	--铸魂
	self.vo.soul_slots_count = MsgAdapter.ReadUChar()
	self.vo.soul_info = {}
	for i = 0, self.vo.soul_slots_count - 1 do
		self.vo.soul_info[i] = MsgAdapter.ReadUShort()
	end
	
	-- 传世
	self.vo.blood_slots_count = MsgAdapter.ReadUChar()
	self.vo.blood_info = {}
	for i = 0, self.vo.blood_slots_count - 1 do
		self.vo.blood_info[i] = MsgAdapter.ReadUShort()
	end
	-- 精炼
	self.vo.apotheosis_info = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.vo.apotheosis_info[i - 1] = MsgAdapter.ReadUShort()
	end

	-- 热血装备注灵
	self.vo.affinage_slots_count = MsgAdapter.ReadUChar()
	self.vo.affinage_info = {}
	for i = 1, self.vo.affinage_slots_count do
		self.vo.affinage_info[i] = MsgAdapter.ReadUShort()
	end

	-- 神炉等级数据
	self.vo.godf_eq_levels = {}
	for i = 0, MsgAdapter.ReadUChar() - 1 do
		self.vo.godf_eq_levels[i] = MsgAdapter.ReadUShort()
	end

	-- 神器等级数据
	self.vo.shenqi_level = MsgAdapter.ReadUInt() --神器等级
	self.vo.shenqi_add_attr_levels = {}	--神器加成属性等级列表
	for i = 1, MsgAdapter.ReadUChar() do
		self.vo.shenqi_add_attr_levels[i] = MsgAdapter.ReadUInt()
	end

	--灭霸手套等级
	self.vo.mb_hand_levels = MsgAdapter.ReadUShort()
	
	self.vo.xinghun_list = {}
	for i=1, MsgAdapter.ReadUChar() do
		local v = {}
		v.level = MsgAdapter.ReadUInt()
		v.exp = MsgAdapter.ReadUInt()
		self.vo.xinghun_list[i]  = v
	end
	

	self.vo.shen_bin_list = {}
	for i = 1, MsgAdapter.ReadUChar() do
		local v = {}
		v.shen_bin_level = MsgAdapter.ReadUChar()
		self.vo.shen_bin_list[i] = v
	end
	
	--守护神装
	self.vo.shou_hu_shen_zhuang = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.vo.shou_hu_shen_zhuang[i] = CommonReader.ReadItemData()
	end

	-- 星魂
	self.vo.xing_hun_equip = {}
	local count = MsgAdapter.ReadUChar()
	for i=1,count do
		self.vo.xing_hun_equip[i] = CommonReader.ReadItemData()
	end

	-- 神铸等级
	self.vo.all_shenzhu_data = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.vo.all_shenzhu_data[i] = MsgAdapter.ReadUShort()
	end

	-- 神格等级
	self.vo.all_shenge_data = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.vo.all_shenge_data[i] = MsgAdapter.ReadUShort()
	end
end

-- 下发装备投保提示
SCEquipInsureTips= SCEquipInsureTips or BaseClass(BaseProtocolStruct)
function SCEquipInsureTips:__init()
	self:InitMsgType(7, 10)
	self.equip = CommonStruct.ItemDataWrapper()
	self.insure_value = 0
end

function SCEquipInsureTips:Decode()
	self.equip = CommonReader.ReadItemData()
	self.insure_value = MsgAdapter.ReadUShort()
end

-- 装备使用的冻结时间发生变化
SCEquipFrozenTimeChange = SCEquipFrozenTimeChange or BaseClass(BaseProtocolStruct)
function SCEquipFrozenTimeChange:__init()
	self:InitMsgType(7, 12)
	self.gildid = 0
	self.frozen_times = 0
end

function SCEquipFrozenTimeChange:Decode()
	self.gildid = CommonReader.ReadSeries()
	self.frozen_times = MsgAdapter.ReadUShort()
end

-- 装备回收结果 旧回收
-- SCEquipRecycleResult = SCEquipRecycleResult or BaseClass(BaseProtocolStruct)
-- function SCEquipRecycleResult:__init()
-- 	self:InitMsgType(7, 13)
-- 	self.result = 0		
-- 	self.bind_gold = 0
-- 	self.exp = 0
-- 	self.jade_debris = 0
-- 	self.fuwen = 0
-- 	self.loongstone = 0
-- 	self.shadowstone = 0
-- 	self.num = 0
-- end

-- function SCEquipRecycleResult:Decode()
-- 	self.result = MsgAdapter.ReadUChar()
-- 	self.bind_gold = MsgAdapter.ReadUInt()
-- 	self.exp = MsgAdapter.ReadUInt()
-- 	self.jade_debris = MsgAdapter.ReadUInt()
-- 	self.fuwen = MsgAdapter.ReadUInt()
-- 	self.loongstone = MsgAdapter.ReadUInt()
-- 	self.shadowstone = MsgAdapter.ReadUInt()
-- 	self.num = MsgAdapter.ReadUChar()
-- end

-- 下发当天装备回收总经验
SCEquipRecycleExp = SCEquipRecycleExp or BaseClass(BaseProtocolStruct)
function SCEquipRecycleExp:__init()
	self:InitMsgType(7, 14)
	self.recycle_exp = 0  --当天回收总经验,第二天会清0
end

function SCEquipRecycleExp:Decode()
	self.recycle_exp = MsgAdapter.ReadUInt()
end

-- 下发装备槽强化数据
SCEquipstrengthenInfo = SCEquipstrengthenInfo or BaseClass(BaseProtocolStruct)
function SCEquipstrengthenInfo:__init()
	self:InitMsgType(7, 15)
	self.strengthen_count = 0
	self.strengthen_list = {}
end

function SCEquipstrengthenInfo:Decode()
	self.strengthen_count = MsgAdapter.ReadUChar()
	self.strengthen_list = {}
	for i = 0, self.strengthen_count - 1 do
		local vo = {}
		vo.slot = i
		vo.strengthen_level = MsgAdapter.ReadUShort()	
		self.strengthen_list[i] = vo
	end
end

-- 强化装备槽结果
SCEquipstrengthenResult = SCEquipstrengthenResult or BaseClass(BaseProtocolStruct)
function SCEquipstrengthenResult:__init()
	self:InitMsgType(7, 16)
	self.data = EQUIP_STRENGTHEN_INFO
	self.result = 0
end

function SCEquipstrengthenResult:Decode()
	self.data = {}
	self.data.slot = MsgAdapter.ReadUChar()
	self.data.strengthen_level = MsgAdapter.ReadUShort()
	self.result = MsgAdapter.ReadUChar()
end

-- 下发传世装备槽升级数据
SCChanShiInfo = SCChanShiInfo or BaseClass(BaseProtocolStruct)
function SCChanShiInfo:__init()
	self:InitMsgType(7, 17)
	self.equip_list = {}
end

function SCChanShiInfo:Decode()
	for i = 1, MsgAdapter.ReadUChar() do
		self.equip_list[i - 1] = {
			level = MsgAdapter.ReadUShort(),	-- 槽位等级
		}
	end
end

-- 下发传世装备升级结果
SCChuanShiUpResult = SCChuanShiUpResult or BaseClass(BaseProtocolStruct)
function SCChuanShiUpResult:__init()
	self:InitMsgType(7, 18)
	self.slot = 0
	self.level = 0
end

function SCChuanShiUpResult:Decode()
	self.slot = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadUShort()
end

-- 装备附灵结果
SCEquipFulingResult = SCEquipFulingResult or BaseClass(BaseProtocolStruct)
function SCEquipFulingResult:__init()
	self:InitMsgType(7, 19)
	self.result = 0
	self.level = 0
	self.exp = 0
end

function SCEquipFulingResult:Decode()
	self.result = MsgAdapter.ReadUChar()
	self.equip_series = CommonReader.ReadSeries()
	self.level = MsgAdapter.ReadUChar()
	self.exp = MsgAdapter.ReadInt()
end

-- 装备附灵转移结果
SCEquipFulingShiftResult = SCEquipFulingShiftResult or BaseClass(BaseProtocolStruct)
function SCEquipFulingShiftResult:__init()
	self:InitMsgType(7, 20)
	self.result = 0
	self.level = 0
	self.exp = 0
end

function SCEquipFulingShiftResult:Decode()
	self.result = MsgAdapter.ReadUChar()
	self.fuling_series = CommonReader.ReadSeries()
	self.consume_series = CommonReader.ReadSeries()
	self.level = MsgAdapter.ReadUChar()
	self.exp = MsgAdapter.ReadInt()
end

SCMoldingSoulResult = SCMoldingSoulResult or BaseClass(BaseProtocolStruct)
function SCMoldingSoulResult:__init()
	self:InitMsgType(7, 21)
	self.slot = 0
	self.strengthen_level = 0
end

function SCMoldingSoulResult:Decode()
	self.slot = MsgAdapter.ReadUChar()
	self.strengthen_level = MsgAdapter.ReadUShort()
end

-- 精炼结果
SCAffinageResult = SCAffinageResult or BaseClass(BaseProtocolStruct)
function SCAffinageResult:__init()
	self:InitMsgType(7, 23)
	self.slot = 0	-- 槽位，从0开始
	self.affinage_lv = 0
end

function SCAffinageResult:Decode()
	self.slot = MsgAdapter.ReadUChar()
	self.affinage_lv = MsgAdapter.ReadUShort()
end

-- 获得装备槽铸魂信息
SCMsStrengthInfo = SCMsStrengthInfo or BaseClass(BaseProtocolStruct)
function SCMsStrengthInfo:__init()
	self:InitMsgType(7, 24)
	self.slot_count = 0
	self.ms_strength_list = {}
end

function SCMsStrengthInfo:Decode()
	self.slot_count = MsgAdapter.ReadUChar()
	self.ms_strength_list = {}
	for i = 1, self.slot_count do
		self.ms_strength_list[i] = MsgAdapter.ReadUShort()
	end
end

-- 下发宝石镶嵌结果
SCEquipInsetResult = SCEquipInsetResult or BaseClass(BaseProtocolStruct)
function SCEquipInsetResult:__init()
	self:InitMsgType(7, 26)
	self.equip_slot = 0 		--装备槽位从1开始
	self.stone_slot = 0 		--宝石槽位从1开始
	self.stone_index = 0 		--宝石等级(宝石索引)
	self.stone_is_blind = 0    --1为绑定  0为不绑定
end

function SCEquipInsetResult:Decode()
	self.equip_slot = MsgAdapter.ReadUChar()
	self.stone_slot = MsgAdapter.ReadUChar()
	self.stone_index = MsgAdapter.ReadShort()
	self.stone_is_blind = MsgAdapter.ReadUChar()
end

-- 下发宝石镶嵌信息
SCEquipInsetInfo = SCEquipInsetInfo or BaseClass(BaseProtocolStruct)
function SCEquipInsetInfo:__init()
	self:InitMsgType(7, 27)
	self.equip_slot_count = 0
	self.stone_slot_count = 0
	self.stone_info = {}
end

function SCEquipInsetInfo:Decode()
	self.equip_slot_count = MsgAdapter.ReadUChar()
	self.stone_info = {}
	for i = 1, self.equip_slot_count do
		self.stone_slot_count = MsgAdapter.ReadUChar()
		self.stone_info[i] = {}
		for j = 1, self.stone_slot_count do
			self.stone_info[i][j] = {}
			self.stone_info[i][j].stone_is_blind = MsgAdapter.ReadUChar()
			self.stone_info[i][j].stone_index = MsgAdapter.ReadShort()
		end
	end
end


-- 升级宝石结果
SCStoneUpgradeResult = SCStoneUpgradeResult or BaseClass(BaseProtocolStruct)
function SCStoneUpgradeResult:__init()
	self:InitMsgType(7, 28)
	self.equip_slot = 0
	self.stone_slot = 0
end

function SCStoneUpgradeResult:Decode()
	self.equip_slot = MsgAdapter.ReadUChar()
	self.stone_slot = MsgAdapter.ReadUChar()
end

-- 卸下宝石结果
SCEquipUnloadStoneResult = SCEquipUnloadStoneResult or BaseClass(BaseProtocolStruct)
function SCEquipUnloadStoneResult:__init()
	self:InitMsgType(7, 29)
	self.equip_slot = 0
	self.stone_slot = 0
end

function SCEquipUnloadStoneResult:Decode()
	self.equip_slot = MsgAdapter.ReadUChar()
	self.stone_slot = MsgAdapter.ReadUChar()
end

-- 返回精炼槽位信息
SCAffinageInfo = SCAffinageInfo or BaseClass(BaseProtocolStruct)
function SCAffinageInfo:__init()
	self:InitMsgType(7, 30)
	self.slot_count = 0
	self.affinage_lv_list = {}
end

function SCAffinageInfo:Decode()
	self.slot_count = MsgAdapter.ReadUChar()
	for i = 0, self.slot_count - 1 do
		self.affinage_lv_list[i] = MsgAdapter.ReadUShort()
	end
end

-- 返回时装升级信息
SCFashionUpInfo = SCFashionUpInfo or BaseClass(BaseProtocolStruct)
function SCFashionUpInfo:__init()
	self:InitMsgType(7, 31)
	self.result = 0
	self.equip_type = 0
	self.index = 0
	self.level = 0
	self.star = 0
end

function SCFashionUpInfo:Decode()
	self.result = MsgAdapter.ReadUChar()
	self.equip_type = MsgAdapter.ReadUChar()
	self.index = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadInt()
	self.star = MsgAdapter.ReadInt()
end

-- 神佑升级结果
SCGodSaveResult = SCGodSaveResult or BaseClass(BaseProtocolStruct)
function SCGodSaveResult:__init()
	self:InitMsgType(7, 32)
	self.level = -1		
end

function SCGodSaveResult:Decode()
	self.level = -1
	self.level = MsgAdapter.ReadUChar()
end

-- 藏宝图打开秘境之门
SCMysticGateOpen = SCMysticGateOpen or BaseClass(BaseProtocolStruct)
function SCMysticGateOpen:__init()
	self:InitMsgType(7, 33)
	self.flag = 0
	self.scene_id = 0
	self.scene_x = 0
	self.scene_y = 0
end

function SCMysticGateOpen:Decode()
	self.flag = MsgAdapter.ReadUChar()
	self.scene_id = MsgAdapter.ReadInt()
	self.scene_x = MsgAdapter.ReadInt()
	self.scene_y = MsgAdapter.ReadInt()
end

-- 神龙戒魂操作结果
SCRingSoulInfo = SCRingSoulInfo or BaseClass(BaseProtocolStruct)
function SCRingSoulInfo:__init()
	self:InitMsgType(7, 35)
	self.opt_type = 0	-- 1信息 2升级
	self.soul_level = 0	-- 操作类型2时 等级为0 ：升级失败
end

function SCRingSoulInfo:Decode()
	self.opt_type = MsgAdapter.ReadUChar()
	self.soul_level = MsgAdapter.ReadUChar()
end

-- 下发热血装备注灵数据
SCRexueEquipZhulingData = SCRexueEquipZhulingData or BaseClass(BaseProtocolStruct)
function SCRexueEquipZhulingData:__init()
	self:InitMsgType(7, 36)
	self.data = {}
end

function SCRexueEquipZhulingData:Decode()
	-- 装备槽索引(0-7)
	for i = 1, MsgAdapter.ReadUChar() do
		self.data[i - 1] = {
			level = MsgAdapter.ReadShort(),
			val = MsgAdapter.ReadUInt(),
		}
	end
end

-- 下发注灵热血成功结果
SCRexueEquipZhulingResult = SCRexueEquipZhulingResult or BaseClass(BaseProtocolStruct)
function SCRexueEquipZhulingResult:__init()
	self:InitMsgType(7, 37)
	self.slot = 0	-- 装备槽索引(0-7)
	self.zhuling_level = 0
	self.zhuling_val = 0
end

function SCRexueEquipZhulingResult:Decode()
	self.slot = MsgAdapter.ReadUChar()
	self.zhuling_level = MsgAdapter.ReadShort()
	self.zhuling_val = MsgAdapter.ReadUInt()
end

-- 装备回收结果
SCEquipRecycleResult = SCEquipRecycleResult or BaseClass(BaseProtocolStruct)
function SCEquipRecycleResult:__init()
	self:InitMsgType(7, 38)	
	self.from_index = 0
	self.item_list = {}
end

function SCEquipRecycleResult:Decode()
	self.from_index = MsgAdapter.ReadUChar()
	self.item_list = {}
	if 2 == self.from_index then -- 寻宝仓库
		local count = MsgAdapter.ReadUInt()
		for index = 1, count do
			self.item_list[index] = CommonReader.ReadSeries()
		end
	end
end

-- 下发纹章信息
SCCrestInfo = SCCrestInfo or BaseClass(BaseProtocolStruct)
function SCCrestInfo:__init()
	self:InitMsgType(7, 39)	
	self.crest_info = {}
end

function SCCrestInfo:Decode()
	local num = MsgAdapter.ReadUChar()
	for i = 1, num do
		self.crest_info[i] = MsgAdapter.ReadUShort()
	end
end

-- 升级纹章结果
SCUpCrestSlotResult = SCUpCrestSlotResult or BaseClass(BaseProtocolStruct)
function SCUpCrestSlotResult:__init()
	self:InitMsgType(7, 40)	
	self.crest_slot = 0
	self.slot_level = 0
end

function SCUpCrestSlotResult:Decode()
	self.crest_slot = MsgAdapter.ReadUChar()
	self.slot_level = MsgAdapter.ReadUShort()
end

-- 一键强化装备槽结果
SCOneKeyStrengthenEquipResult = SCOneKeyStrengthenEquipResult or BaseClass(BaseProtocolStruct)
function SCOneKeyStrengthenEquipResult:__init()
	self:InitMsgType(7, 41)	
	self.strengthen_list = {}
end

function SCOneKeyStrengthenEquipResult:Decode()
	self.strengthen_list = {}
	local cnt = MsgAdapter.ReadUChar()
	for i = 1,cnt, 1 do	
		local vo = {}
		local slot = MsgAdapter.ReadUChar() 	-- uchar: 第几个槽位, 从1开始
		vo.slot = slot - 1
		vo.strengthen_level = MsgAdapter.ReadUShort()	-- ushort: 升级后的等级
		self.strengthen_list[vo.slot] = vo
	end
end

-- 返回一键精炼槽位信息
SCOneKeyAffinageInfo = SCOneKeyAffinageInfo or BaseClass(BaseProtocolStruct)
function SCOneKeyAffinageInfo:__init()
	self:InitMsgType(7, 42)
	self.affinage_lv_list = {}
end

function SCOneKeyAffinageInfo:Decode()
	self.affinage_lv_list = {}
	local cnt = MsgAdapter.ReadUChar()
	for i = 1, cnt do
		local slot = MsgAdapter.ReadUChar()
		self.affinage_lv_list[slot-1] = MsgAdapter.ReadUShort()
	end
end

-- 一键装备槽铸魂信息
SCMsStrengthOneKeyInfo = SCMsStrengthOneKeyInfo or BaseClass(BaseProtocolStruct)
function SCMsStrengthOneKeyInfo:__init()
	self:InitMsgType(7, 43)
	self.ms_strength_list = {}
end

function SCMsStrengthOneKeyInfo:Decode()
	local cnt = MsgAdapter.ReadUChar()
	self.ms_strength_list = {}
	for i = 1, cnt, 1 do
		local slot = MsgAdapter.ReadUChar()
		self.ms_strength_list[slot] = MsgAdapter.ReadUShort()
	end
end
-- 神器数据
SCShenQiInfo = SCShenQiInfo or BaseClass(BaseProtocolStruct)
function SCShenQiInfo:__init()
	self:InitMsgType(7, 44)
	self.level  = 0 --神器等级
	self.attr_list = {}  --基础属性加成等级列表
end

function SCShenQiInfo:Decode()
	self.level = MsgAdapter.ReadInt()
	local count =  MsgAdapter.ReadUChar()
	for i = 1, count do
		self.attr_list[i] = MsgAdapter.ReadInt()
	end
end

-- 神器器魂结果
SCShenQiUpgradeResult = SCShenQiUpgradeResult or BaseClass(BaseProtocolStruct)
function SCShenQiUpgradeResult:__init()
	self:InitMsgType(7, 45)
	self.level  = 0 --神器等级
end

function SCShenQiUpgradeResult:Decode()
	self.level = MsgAdapter.ReadInt()
end

-- 神器基础属性升级结果
SCShenQiAttrUpResult = SCShenQiAttrUpResult or BaseClass(BaseProtocolStruct)
function SCShenQiAttrUpResult:__init()
	self:InitMsgType(7, 46)
	self.type  = 0 --属性类型
	self.level  = 0 --属性等级
end

function SCShenQiAttrUpResult:Decode()
	self.type = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadInt()
end

-- 鉴定装备下发 请求(7, 49)
-- SCAuthenticateResult = SCAuthenticateResult or BaseClass(BaseProtocolStruct)
-- function SCAuthenticateResult:__init()
-- 	self:InitMsgType(7, 47)
-- 	self.authenticate = {} -- 鉴定属性
-- 	self.series  = 0 --装备槽位
-- end

-- function SCAuthenticateResult:Decode()
-- 	self.series  = CommonReader.ReadSeries() --装备槽位
-- 	self.authenticate = {}
-- 	self.authenticate.attr = {}
-- 	local count = MsgAdapter.ReadUChar()
-- 	for i = 1, count do
-- 		local value = MsgAdapter.ReadInt()
-- 		if i == 1 then
-- 			self.authenticate.quality = bit:_and(value, 0xff)
-- 			self.authenticate.times = bit:_rshift(value, 8)
-- 		else
-- 			self.authenticate.attr[i - 1] = {
-- 				type = bit:_and(value, 0xff),
-- 				value = bit:_rshift(value, 8),
-- 			}
-- 		end
-- 	end
-- end

SCAuthenticateResult = SCAuthenticateResult or BaseClass(BaseProtocolStruct)
function SCAuthenticateResult:__init()
	self:InitMsgType(7, 47)
	self.series  = 0 --装备槽位
	self.authenticate = {} -- 鉴定属性
end

function SCAuthenticateResult:Decode()
	self.series = MsgAdapter.ReadUChar()
	self.authenticate = {}
	local count = MsgAdapter.ReadUChar()

	for i = 1, count do
		local vo = {
			jd_type = MsgAdapter.ReadUChar(),
			attr_type = MsgAdapter.ReadUChar(),
			attr_index = MsgAdapter.ReadUChar(),

			ls_jd_type = MsgAdapter.ReadUChar(), 
			ls_attr_type = MsgAdapter.ReadUChar(),
			ls_attr_index= MsgAdapter.ReadUChar(),
		}
		table.insert(self.authenticate, vo)
	end

	-- PrintTable(self.authenticate)
end

-- 手套槽位数据下发 请求(7, 50)
SCHandAdd = SCHandAdd or BaseClass(BaseProtocolStruct)
function SCHandAdd:__init()
	self:InitMsgType(7, 48)
	self.level = 0 -- 手套等级
	self.exp  = 0  -- 能量&经验
end

function SCHandAdd:Decode()	
	self.level = MsgAdapter.ReadUShort()
	self.exp = MsgAdapter.ReadUInt()
end

-- 手套打造结果下发 请求(7, 51)
SCHandCompose = SCHandCompose or BaseClass(BaseProtocolStruct)
function SCHandCompose:__init()
	self:InitMsgType(7, 49)
	self.end_time = 0
	self.q_idx = 0	--品质库索引
	self.i_idx = 0	--物品库索引
end

function SCHandCompose:Decode()	
	self.end_time = CommonReader.ReadServerUnixTime()
	self.q_idx = MsgAdapter.ReadUChar()
	self.i_idx = MsgAdapter.ReadUChar()
end

-- 下发总属性点
SCPointInfo = SCPointInfo or BaseClass(BaseProtocolStruct)
function SCPointInfo:__init()
	self:InitMsgType(7, 50)
	self.left_points = 0
	self.attr_point_list = {}
end

function SCPointInfo:Decode()
	self.left_points = MsgAdapter.ReadUInt()
	local count = MsgAdapter.ReadChar()
	self.attr_point_list = {}
	for i=1, count do
		self.attr_point_list[i] = MsgAdapter.ReadUInt()
	end
end


-- 下发全部装备的鉴定数据
SCAllEquipAutResult = SCAllEquipAutResult or BaseClass(BaseProtocolStruct)
function SCAllEquipAutResult:__init()
	self:InitMsgType(7, 51)
	self.all_equip = {} -- 鉴定属性
end

function SCAllEquipAutResult:Decode()
	self.all_equip = {}

	local equ_count = MsgAdapter.ReadUChar()

	for i = 1, equ_count do
		local attr_count = MsgAdapter.ReadUChar()
		local data = {}
		for i1 = 1, attr_count do
			local vo = {
				jd_type = MsgAdapter.ReadUChar(),
				attr_type = MsgAdapter.ReadUChar(),
				attr_index = MsgAdapter.ReadUChar(),

				ls_jd_type = MsgAdapter.ReadUChar(), 
				ls_attr_type = MsgAdapter.ReadUChar(),
				ls_attr_index= MsgAdapter.ReadUChar(),
			}
			table.insert(data, vo)
		end
		table.insert(self.all_equip, data)
	end

	-- PrintTable(self.all_equip[3])
end

-- 接收所有神铸数据
SCAllShenzhuData = SCAllShenzhuData or BaseClass(BaseProtocolStruct)
function SCAllShenzhuData:__init()
	self:InitMsgType(7, 52)
	self.data = {} -- 神铸数据
end

function SCAllShenzhuData:Decode()
	local count = MsgAdapter.ReadUChar()
	for i = 1, count do
		self.data[i] = MsgAdapter.ReadUShort()
	end
end

-- 接收所有神格数据
SCAllShengeData = SCAllShengeData or BaseClass(BaseProtocolStruct)
function SCAllShengeData:__init()
	self:InitMsgType(7, 53)
	self.data = {} -- 神格数据
end

function SCAllShengeData:Decode()
	local count = MsgAdapter.ReadUChar()
	for i = 1, count do
		self.data[i] = MsgAdapter.ReadUShort()
	end
end

-- 接收神铸结果
SCShenzhuResult = SCShenzhuResult or BaseClass(BaseProtocolStruct)
function SCShenzhuResult:__init()
	self:InitMsgType(7, 54)
	self.slot = {} -- 槽位 从1开始
	self.level = {} -- 神铸等级
end

function SCShenzhuResult:Decode()
	self.slot = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadUShort()
end

-- 接收神格结果
SCShengeResult = SCShengeResult or BaseClass(BaseProtocolStruct)
function SCShengeResult:__init()
	self:InitMsgType(7, 55)
	self.slot = {} -- 槽位 从1开始
	self.level = {} -- 神格等级
end

function SCShengeResult:Decode()
	self.slot = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadUShort()
end
