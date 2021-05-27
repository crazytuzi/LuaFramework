RoleInfoView = RoleInfoView or BaseClass()
-----
--@通用接口
--Update: 更新视图

--神器cell
function RoleInfoView.CreateShenQiCell(parent)
	local view = {}

	local get_shenqi_level = function ()
		return ShenqiData.Instance:GetShenQiLevel()
	end

	local get_shenqi_vir_equip_data = function ()
		return ShenqiData.Instance:GetVirtualEquipData()
	end

	function view:SetGetShenqiLevelFunc(func)
		get_shenqi_level = func
	end

	function view:SetGetShenqiEquipDataFunc(func)
		get_shenqi_vir_equip_data = func
	end

	local cell = BaseCell.New()
	cell:SetPosition(380, 200)
	parent:addChild(cell:GetView(), 999, 999)
	local cfg = ShenqiData.GetShenQiCfgByLevel(get_shenqi_level())
	cell:SetItemEffect(cfg.eff_id)
	cell.item_effect:setScale(0.30)
	cell.item_effect:setPositionY(cell.item_effect:getPositionY() - 5)

	function view:Update()
		local level = get_shenqi_level()
		-- local cfg = ShenqiData.GetShenQiCfgByLevel(level)
		-- cell:SetItemEffect(cfg.eff_id)
		
		cell:SetData(get_shenqi_vir_equip_data())
		cell:GetView():setEnabled(level > 0)
		cell:MakeGray(level == 0)
		cell:SetBindIconVisible(false)
	end

	XUI.AddClickEventListener(cell:GetView(), function ()
		local equip_data = get_shenqi_vir_equip_data()
		if nil == equip_data then return end
		TipCtrl.Instance:OpenItem(equip_data, EquipTip.FROM_NORMAL)
	end)

	view:Update()

	return view
end


--灭霸手套cell
function RoleInfoView.CreateMBHandCell(parent, fromView)
	local view = {}
	view.change_call = EquipData.Instance:AddEventListener(EquipData.CHANGE_ONE_EQUIP, function ()
		view:Update()
	end)
	view.item_change_call = BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, function ()
		view:Update()
	end)

	local get_level = function ()
		return MeiBaShouTaoData.Instance:GetAddData().level
	end

	local get_equip_data = function ()
		if fromView == EquipTip.FROME_BROWSE_ROLE then
			return BrowseData.Instance:GetEquipBySolt(EquipData.EquipSlot.itGlovePos)
		else
			return EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itGlovePos)
		end
	end

	function view:SetGetShenqiLevelFunc(func)
		get_level = func
	end

	function view:SetGetShenqiEquipDataFunc(func)
		get_equip_data = func
	end

	local cell = BaseCell.New()
	cell:SetPosition(358, 170)

	parent:addChild(cell:GetView(), 999, 999)
	-- local cfg = ShenqiData.GetShenQiCfgByLevel(get_level())
	-- cell:SetItemEffect(cfg.eff_id)
	-- cell.item_effect:setScale(0.30)
	-- cell.item_effect:setPositionY(cell.item_effect:getPositionY() - 5)

	function view:DeleteMe()
		cell:DeleteMe()
		EquipData.Instance:RemoveEventListener(view.change_call)
		BagData.Instance:RemoveEventListener(view.item_change_call)
		view.change_call = nil
		view.item_change_call = nil
	end

	function view:Update()
		local vis = false
		if nil == get_equip_data() then
			cell:SetData({item_id = 299})
			vis = true
		else
			cell:SetData(get_equip_data())
		end
		cell:SetAddIconPath(vis)
		cell:MakeGray(nil == get_equip_data())
    	cell:SetRightTopNumText(get_equip_data() and get_level() or 0, COLOR3B.GREEN)
		cell:SetBindIconVisible(false)
		cell:SetRemind(nil ~= EquipData.Instance:GetBestHandEquip(get_equip_data()) and fromView ~= EquipTip.FROME_BROWSE_ROLE)
	end

	XUI.AddClickEventListener(cell:GetView(), function ()
		local equip_data = get_equip_data()
		if true then
			if fromView == EquipTip.FROME_BROWSE_ROLE then
				TipCtrl.Instance:OpenItem(equip_data, fromView)
			else
				local best_eq = EquipData.Instance:GetBestHandEquip(equip_data)
				if best_eq then
					EquipCtrl.SendFitOutEquip(best_eq.series)
				else
					if equip_data == nil then
						if ViewManager.Instance:CanOpen(ViewDef.MainGodEquipView.ReXueFuzhuang.MeiBaShouTao) then
							ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.ReXueFuzhuang.MeiBaShouTao)
						end
					else				
						TipCtrl.Instance:OpenItem(equip_data,  EquipTip.FROM_ROLE_HAND)
					end
				end
			end
		end
	end)

	view:Update()

	return view
end