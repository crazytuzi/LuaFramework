require("game/shenshou/shenshou_view")
require("game/shenshou/shenshou_bag_view")
require("game/shenshou/shenshou_extrazhuzhan_tip")
require("game/shenshou/shenshou_stuff_tip")
require("game/shenshou/shenshou_skill_tip")
require("game/shenshou/shenshou_data")
require("game/shenshou/select_equip_view")
require("game/shenshou/shenshou_equip_tip")
-- require("game/shenshou/shenshou_fuling_tips")

ShenShouCtrl = ShenShouCtrl or BaseClass(BaseController)
function ShenShouCtrl:__init()
	if ShenShouCtrl.Instance ~= nil then
		print_error("[ShenShouCtrl] Attemp to create a singleton twice !")
	end
	ShenShouCtrl.Instance = self

	self.view = ShenShouView.New(ViewName.ShenShou)
	self.bag_view = ShenShouBagView.New(ViewName.ShenShouBag)
	self.shenshou_extrazhuzhan_tip = ShenShouExtraZhuZhanTip.New()
	self.shenshou_skill_tip = ShenShouSkillTip.New()
	self.shenshou_stuff_tip = ShenShouStuffTip.New()
	self.shenshou_equip_tip = ShenShouEquipTip.New()
	self.select_equip_view = SelectEquipView.New(ViewName.ShenShouSelectEquip)
	self.data = ShenShouData.New()
	self.fuling_select_material_view = FulingSelectMaterialView.New(ViewName.FulingSelectMaterialView)
	-- self.fuling_tips = FulingTips.New(ViewName.FulingTips)

	self:RegisterAllProtocols()
end

function ShenShouCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.shenshou_skill_tip then	
		self.shenshou_skill_tip:DeleteMe()
		self.shenshou_skill_tip = nil
	end

	if self.select_equip_view then
		self.select_equip_view:DeleteMe()
		self.select_equip_view = nil
	end

	if self.bag_view then
		self.bag_view:DeleteMe()
		self.bag_view = nil
	end

	if self.shenshou_extrazhuzhan_tip then
		self.shenshou_extrazhuzhan_tip:DeleteMe()
		self.shenshou_extrazhuzhan_tip = nil
	end
	if self.shenshou_stuff_tip then
		self.shenshou_stuff_tip:DeleteMe()
		self.shenshou_stuff_tip = nil
	end
	if self.data then	
		self.data:DeleteMe()
		self.data = nil
	end
	if self.shenshou_equip_tip then
		self.shenshou_equip_tip:DeleteMe()
		self.shenshou_equip_tip = nil
	end
	if self.fuling_select_material_view then
		self.fuling_select_material_view:DeleteMe()
		self.fuling_select_material_view = nil
	end

	ShenShouCtrl.Instance = nil
end

function ShenShouCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSShenshouOperaReq)
	self:RegisterProtocol(CSSHenshouReqStrength)
	self:RegisterProtocol(SCShenshouBackpackInfo, "OnShenshouBackpackInfo")
	self:RegisterProtocol(SCShenshouListInfo, "OnShenshouListInfo")
	self:RegisterProtocol(SCShenshouBaseInfo, "OnShenshouBaseInfo")
	self:RegisterProtocol(SCShenshouHuanlingListInfo, "OnShenshouHuanlingListInfo")
	self:RegisterProtocol(SCShenshouHuanlingDrawInfo, "OnShenshouHuanlingDrawInfo")

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function ShenShouCtrl:OpenShenShouBag(shou_id, cache_index)
	self.bag_view:OpenShenShouBag(shou_id, cache_index)
end

function ShenShouCtrl:OpenShenShouStuffTip(data)
	self.shenshou_stuff_tip:SetData(data)
end

function ShenShouCtrl:OpenExtraZhuZhanTip()
	self.shenshou_extrazhuzhan_tip:Open()
end

function ShenShouCtrl:OpenSkillTip(index, cell)
	self.shenshou_skill_tip:Open()
	self.shenshou_skill_tip:SetData(index, cell)
end

function ShenShouCtrl:MainuiOpenCreate()
	self:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_ALL_INFO)
	self:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_HUANLING_INFO)
end

-- 神兽操作请求
function ShenShouCtrl:SendShenshouOperaReq(opera_type, param_1, param_2, param_3, param_4)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShenshouOperaReq)
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol.param_4 = param_4 or 0
	protocol:EncodeAndSend()
end

-- 神兽请求强化装备
function ShenShouCtrl:SendSHenshouReqStrength(shenshou_id, equip_index, is_double_shuliandu, destroy_num, destroy_backpack_index_list)
	-- if #destroy_backpack_index_list ~= 0 then
	-- 	self.view:ShowQiangHuaEffect()
	-- end
	local protocol = ProtocolPool.Instance:GetProtocol(CSSHenshouReqStrength)
	protocol.shenshou_id = shenshou_id or 0
	protocol.equip_index = equip_index or 0
	protocol.is_double_shuliandu = is_double_shuliandu or 0
	protocol.destroy_num = destroy_num or 0
	protocol.destroy_backpack_index_list = destroy_backpack_index_list
	protocol:EncodeAndSend()
end

-- 神兽背包信息
function ShenShouCtrl:OnShenshouBackpackInfo(protocol)
	if protocol.is_full_backpack == 1 then
		self.data:SetShenshouGridList(protocol.grid_list)
	elseif protocol.is_full_backpack == 0 then
		local bag_list = self.data:GetShenshouGridList()
		table.insert(bag_list, protocol.grid_list[1])
		self.data:SetShenshouGridList(bag_list)

		-- local item = ShenShouData.Instance:GetShenShouEqCfg(protocol.grid_list[1].item_id)
		-- local item_cfg = ItemData.Instance:GetItemConfig(item.icon_id)
		-- if item_cfg then
		-- 	local color_str = C3b2Str(ITEM_COLOR[item.quality + 1])
		-- 	local item_name = string.format("{wordcolor;%s;%s}", color_str, item.name)
		-- 	SysMsgCtrl.Instance:FloatingLabel(string.format(Language.SysRemind.AddItem, item_name, 1))
		-- end
	end

	self.view:Flush()
	self.bag_view:Flush()

	RemindManager.Instance:Fire(RemindName.ShenShou)
    RemindManager.Instance:Fire(RemindName.ShenShouFuling)
    RemindManager.Instance:Fire(RemindName.ShenShouCompose)
end

-- 神兽信息
function ShenShouCtrl:OnShenshouListInfo(protocol)
	if protocol.is_all_shenshou == 1 then
		self.data:SetShenshouListInfo(protocol.shenshou_list)
	elseif protocol.is_all_shenshou == 0 then
		local shenshou_list = self.data:GetShenshouListInfo()
		if #shenshou_list == 0 then
			table.insert(shenshou_list, protocol.shenshou_list[1])
		else
			local loop = 0
			for i=1, #shenshou_list do
				if shenshou_list[i].shou_id == protocol.shenshou_list[1].shou_id then
					shenshou_list[i] = protocol.shenshou_list[1]
				else
					loop = loop + 1
				end

				if loop == #shenshou_list then
					table.insert(shenshou_list, protocol.shenshou_list[1])
				end
			end
		end
		self.data:SetShenshouListInfo(shenshou_list)

		local eq_num = 0
		for k,v in pairs(protocol.shenshou_list[1].equip_list) do
			if v.item_id ~= 0 then
				eq_num = eq_num + 1
			end
		end
		-- if eq_num == GameEnum.SHENSHOU_MAX_EQUIP_SLOT_INDEX + 1 then
		-- 	self.shenshou_equip_bag_view:ShowActiveEffect()
		-- end
	end

	self.view:Flush()
	self.bag_view:Flush()

	RemindManager.Instance:Fire(RemindName.ShenShou)
    RemindManager.Instance:Fire(RemindName.ShenShouFuling)
end

function ShenShouCtrl:OnShenshouBaseInfo(protocol)
	self.data:SetExtraZhuZhanCount(protocol.extra_zhuzhan_count)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.ShenShou)
	RemindManager.Instance:Fire(RemindName.ShenShouFuling)
end

function ShenShouCtrl:OnShenshouHuanlingListInfo(protocol)
	self.data:SetShenshouHuanlingListInfo(protocol)
	self.view:Flush()
	KuafuGuildBattleCtrl.Instance:Flush()

	RemindManager.Instance:Fire(RemindName.ShenShouHuanling)
end

function ShenShouCtrl:OnShenshouHuanlingDrawInfo(protocol)
	self.data:SetShenshouHuanlingDrawInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ShenShouHuanling)
	self.view:FlushAnimation()
end

function ShenShouCtrl:SetShouSkillData(data)
	self.shenshou_skill_desc:SetData(data)
end

function ShenShouCtrl:SetDataAndOepnEquipTip(data, form_view, shou_id)
	self.shenshou_equip_tip:SetData(data, form_view, shou_id)
end

function ShenShouCtrl:SetFulingSelectMaterialViewCallBack(callback)
	self.fuling_select_material_view:SetCallBack(callback)
end

function ShenShouCtrl:SetFulingSelectMaterialViewCloseCallBack(callback)
	self.fuling_select_material_view:SetCloseCallBack(callback)
end

function ShenShouCtrl:SSHeChengUpLevelBagOpen(select_item)
	self.select_equip_view:SetHeChengData(select_item)
	self.select_equip_view:Open()
end

function ShenShouCtrl:SetTipsCloseCallBack(call_back)
	-- self.fuling_tips:SetCloseCallBack(call_back)
end

function ShenShouCtrl:SetTipsOpenCallBack(call_back)
	-- self.fuling_tips:SetOpenCallBack(call_back)
end