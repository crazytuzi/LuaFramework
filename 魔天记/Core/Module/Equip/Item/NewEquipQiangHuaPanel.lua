require "Core.Module.Common.UIComponent"
require "Core.Module.Equip.Item.NewEquipStrongPropertyItem"

local NewEquipQiangHuaPanel = class("NewEquipQiangHuaPanel", UIComponent);
local canStrongNotice = LanguageMgr.Get("equip/NewEquipQiangHuaPanel/canStrongNotice")
local green = ColorDataManager.Get_green()
local white = ColorDataManager.Get_white()
local red = ColorDataManager.Get_red()

function NewEquipQiangHuaPanel:New()
	self = {};
	setmetatable(self, {__index = NewEquipQiangHuaPanel});
	return self
end

function NewEquipQiangHuaPanel:_Init()
	self._zhufushiInfo = nil
	self._isSelectProtect = false
	self._canSelectProtect = false
	self._zhufushiPanelOpen = false
	self._isLuckFull = false
	self._isShowNotice = true
	self:_InitReference();
	self:_InitListener();
	
end

function NewEquipQiangHuaPanel:_InitReference()
	self._txtName = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtName");
	self._txtQiangHua = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtQiangHua");
	self._txtSucRate = UIUtil.GetChildByName(self._gameObject, "UILabel", "canActive/txtSucRate");
	self._txtAddSucRate = UIUtil.GetChildByName(self._gameObject, "UILabel", "canActive/txtAddSucRate");
	
	
	self.eq_select = UIUtil.GetChildByName(self._gameObject, "Transform", "eq_select");
	
	self.eq_selectCtr = SelectEquipPanelCtrl:New();
	self.eq_selectCtr:Init(self.eq_select.gameObject, 1, false);
	
	self._txtLuck = UIUtil.GetChildByName(self._gameObject, "UILabel", "canActive/slider/txtLuck");
	self._txtLuckNotice = UIUtil.GetChildByName(self._gameObject, "UILabel", "canActive/slider/txtLuckNotice");
	self._slider = UIUtil.GetChildByName(self._gameObject, "UISlider", "canActive/slider")
	self._imgAdd = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgAdd");
	self._imgQianghua = UIUtil.GetChildByName(self._gameObject, "UISprite", "canActive/imgQianghua");
	self._txtQiangHuaLabel = UIUtil.GetChildByName(self._imgQianghua, "UILabel", "Label");
	self._phalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, NewEquipStrongPropertyItem)
	self._trsCan = UIUtil.GetChildByName(self._gameObject, "canActive")
	self._trsCant = UIUtil.GetChildByName(self._gameObject, "cantActive")
	
	-- self._imgIcon0 = UIUtil.GetChildByName(self._gameObject, "UISprite", "item0/icon")
	-- self._imgQuality0 = UIUtil.GetChildByName(self._gameObject, "UISprite", "item0/quality")
	self._item1 = UIUtil.GetChildByName(self._gameObject, "canActive/item1")
	self._imgIcon1 = UIUtil.GetChildByName(self._item1, "UISprite", "icon")
	self._imgQuality1 = UIUtil.GetChildByName(self._item1, "UISprite", "quality")
	self._txtNum1 = UIUtil.GetChildByName(self._item1, "UILabel", "num")
	
	self._item2 = UIUtil.GetChildByName(self._gameObject, "canActive/item2")
	self._imgIcon2 = UIUtil.GetChildByName(self._item2, "UISprite", "icon")
	self._imgQuality2 = UIUtil.GetChildByName(self._item2, "UISprite", "quality")
	self._txtNotice2 = UIUtil.GetChildByName(self._item2, "UILabel", "notice")
	self._goluckFull = UIUtil.GetChildByName(self._gameObject, "canActive/slider/luckFull").gameObject
	
	self._item3 = UIUtil.GetChildByName(self._gameObject, "canActive/item3")
	self._imgIcon3 = UIUtil.GetChildByName(self._item3, "UISprite", "icon")
	self._imgQuality3 = UIUtil.GetChildByName(self._item3, "UISprite", "quality")
	self._txtNotice3 = UIUtil.GetChildByName(self._item3, "UILabel", "notice")
	self._txtCantNotice3 = UIUtil.GetChildByName(self._item3, "UILabel", "notice2")
	self._goZhufushi = UIUtil.GetChildByName(self._gameObject, "canActive/trsZhufushi").gameObject
	self._goZhufushi:SetActive(self._zhufushiPanelOpen)
	self._trsMask = UIUtil.GetChildByName(self._goZhufushi, "mask")
	
	
	for i = 1, 3 do
		local info = NewEquipStrongManager.GetZhufushiByIndex(i)
		self["_goZhufushiItem" .. i] = UIUtil.GetChildByName(self._goZhufushi, "item" .. i).gameObject
		self["_imgZhufushi" .. i] = UIUtil.GetChildByName(self["_goZhufushiItem" .. i], "UISprite", "icon")
		ProductManager.SetIconSprite(self["_imgZhufushi" .. i], info.icon_id)
		self["_imgZhufushiQuality" .. i] = UIUtil.GetChildByName(self["_goZhufushiItem" .. i], "UISprite", "quality")
		self["_imgZhufushiQuality" .. i].color = ColorDataManager.GetColorByQuality(info.quality)
		self["_txtZhufushiNum" .. i] = UIUtil.GetChildByName(self["_goZhufushiItem" .. i], "UILabel", "num")
	end
end

function NewEquipQiangHuaPanel:_InitListener()
	self._onClickBtnItem1 = function(go) self:_OnClickBtnItem1(self) end
	UIUtil.GetComponent(self._item1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnItem1);
	self._onClickBtnItem2 = function(go) self:_OnClickBtnItem2(self) end
	UIUtil.GetComponent(self._item2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnItem2);
	self._onClickBtnItem3 = function(go) self:_OnClickBtnItem3(self) end
	UIUtil.GetComponent(self._item3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnItem3);
	
	
	
	self._onClickZhufushi1 = function(go) self:_OnClickZhufushi1() end
	UIUtil.GetComponent(self._goZhufushiItem1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickZhufushi1);
	self._onClickZhufushi2 = function(go) self:_OnClickZhufushi2() end
	UIUtil.GetComponent(self._goZhufushiItem2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickZhufushi2);
	self._onClickZhufushi3 = function(go) self:_OnClickZhufushi3() end
	UIUtil.GetComponent(self._goZhufushiItem3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickZhufushi3);
	
	self._onClickImgQiangHua = function(go) self:_OnClickImgQiangHua(self) end
	UIUtil.GetComponent(self._imgQianghua, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickImgQiangHua);
	self._onClickImgAdd = function(go) self:_OnClickImgAdd(self) end
	UIUtil.GetComponent(self._imgAdd, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickImgAdd);
	self._onClickMask = function(go) self:_OnClickMask(self) end
	UIUtil.GetComponent(self._trsMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMask);
end

function NewEquipQiangHuaPanel:_Dispose()
	UIUtil.GetComponent(self._item1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnItem1 = nil;
	UIUtil.GetComponent(self._item2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnItem2 = nil;
	UIUtil.GetComponent(self._item3, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnItem3 = nil;
	
	UIUtil.GetComponent(self._goZhufushiItem1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickZhufushi1 = nil;
	UIUtil.GetComponent(self._goZhufushiItem2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickZhufushi2 = nil;
	UIUtil.GetComponent(self._goZhufushiItem3, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickZhufushi3 = nil;
	
	
	UIUtil.GetComponent(self._imgQianghua, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickImgQiangHua = nil;
	UIUtil.GetComponent(self._imgAdd, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickImgAdd = nil;
	UIUtil.GetComponent(self._trsMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickMask = nil;
	self:_DisposeReference();
	if(self._phalanx) then
		self._phalanx:Dispose()
		self._phalanx = nil
	end
	
	self.eq_selectCtr:Dispose()
	self.eq_selectCtr = nil;
	
	
end

function NewEquipQiangHuaPanel:_OnClickZhufushi1()
	self:_OnClickZhufushi(1)
end


function NewEquipQiangHuaPanel:_OnClickZhufushi2()
	self:_OnClickZhufushi(2)
end


function NewEquipQiangHuaPanel:_OnClickZhufushi3()
	self:_OnClickZhufushi(3)
end

function NewEquipQiangHuaPanel:_OnClickZhufushi(index)
	
	if(NewEquipStrongManager.HasZhufushi(index)) then
		self._zhufushiInfo = NewEquipStrongManager.GetZhufushiByIndex(index)
		UISoundManager.PlayUISound(UISoundManager.ui_gem)
	else
		ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
		{id = NewEquipStrongManager.GetZhufushiByIndex(index).id})
		self._zhufushiInfo = nil
	end
	self._zhufushiPanelOpen = false
	self._goZhufushi:SetActive(self._zhufushiPanelOpen)
	self:UpdateZhufushi()
end

function NewEquipQiangHuaPanel:_OnClickMask()
	self._zhufushiPanelOpen = false
	self._goZhufushi:SetActive(self._zhufushiPanelOpen)
	
end

function NewEquipQiangHuaPanel:_OnClickImgQiangHua()
	
	SequenceManager.TriggerEvent(SequenceEventType.Guide.EQUIP_QH);
	
	
	if(self._isLuckFull) then
		EquipProxy.SendNewEquipStrong(self._eqinfo.idx, self._zhufushiInfo and self._zhufushiInfo.id or 0, self._isSelectProtect and 1 or 0)
	else		
		if(self._sucRate.protectItem) then
			-- if(NewEquipStrongManager.GetIsShowNotice()) then		
			if(not self._isSelectProtect) then
				if(self._isShowNotice)	then	
					self._isShowNotice = false
					-- NewEquipStrongManager.SetIsShowNotice(false)
					ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL,
					{
						msg = LanguageMgr.Get("equip/NewEquipQiangHuaPanel/protectNotice"),
						hander = function()					
							ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL, {id = self._sucRate.protectItem.id})
						end,
					})	
					return
				end
			end
		end
		local count = BackpackDataManager.GetProductTotalNumBySpid(self._sucRate.promoteItem.id)
		local need = self._sucRate.promoteItemCount
		
		if(count >= need) then
			EquipProxy.SendNewEquipStrong(self._eqinfo.idx, self._zhufushiInfo and self._zhufushiInfo.id or 0, self._isSelectProtect and 1 or 0)
		else
			local reqCount = need - count
			local refineFunc = function()				
				if(MoneyDataManager.Get_gold() >= reqCount * 1) then
					EquipProxy.SendNewEquipStrong(self._eqinfo.idx, self._zhufushiInfo and self._zhufushiInfo.id or 0, self._isSelectProtect and 1 or 0)
				else
					--ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3})	
                    ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});				
				end				
			end
			
			if(NewEquipStrongManager.GetAutoConfirm()) then				
				refineFunc()
			else
				ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM7PANEL,
				{
					title = LanguageMgr.Get("common/buyNoticeTitle"),
					toggleValue = NewEquipStrongManager.GetAutoConfirm(),
					msg = LanguageMgr.Get("equip/NewEquipQiangHuaPanel/buyNotice", {count = reqCount, num = reqCount * self._sucRate.promote_price,
					name = ProductManager.GetProductById(self._sucRate.promoteItem.id).name}),
					hander = refineFunc,
					toggleHandler = NewEquipStrongManager.SetAutoConfirm,
				})
			end
		end	
		
	end
	
	
end

function NewEquipQiangHuaPanel:_OnClickImgAdd()
	local data = nil
	local _plusId = NewEquipStrongManager.GetPlusId()
	if(_plusId == 0) then
		data = NewEquipStrongManager.GetPlusDataById(1)
		ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPNEWSTRONGSUITONEPANEL, data)
	elseif NewEquipStrongManager.IsLastPlusId(_plusId) then
		data = NewEquipStrongManager.GetPlusDataById(_plusId)
		ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPNEWSTRONGSUITONEPANEL, data)
	else
		data = {}
		data[1] = NewEquipStrongManager.GetPlusDataById(_plusId)
		data[2] = NewEquipStrongManager.GetPlusDataById(_plusId + 1)
		ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPNEWSTRONGSUITPANEL, data)
	end
end

function NewEquipQiangHuaPanel:_OnClickBtnItem1()
	ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
	{id = self._sucRate.promoteItem.id})
	-- ProductCtrl.ShowProductTip(self._sucRate.promoteItem.id, ProductCtrl.TYPE_FROM_OTHER, 1)
end

function NewEquipQiangHuaPanel:_OnClickBtnItem2()
	if(self._zhufushiInfo) then
		self._zhufushiInfo = nil
		self:UpdateZhufushi()
	else
		self._zhufushiPanelOpen = true
		for i = 1, 3 do
			local count = BackpackDataManager.GetProductTotalNumBySpid(NewEquipStrongManager.GetZhufushiByIndex(i).id)
			self["_txtZhufushiNum" .. i].text = count .. "/1"
			self["_txtZhufushiNum" .. i].color =(count > 0) and green or red
		end
		
		self._goZhufushi:SetActive(self._zhufushiPanelOpen)
	end
end

function NewEquipQiangHuaPanel:UpdateZhufushi()
	if(self._zhufushiInfo) then
		if(BackpackDataManager.GetProductTotalNumBySpid(self._zhufushiInfo.id) > 0) then
			ProductManager.SetIconSprite(self._imgIcon2, self._zhufushiInfo.icon_id)
			self._imgQuality2.color = ColorDataManager.GetColorByQuality(self._zhufushiInfo.quality)
			self._imgIcon2.gameObject:SetActive(true)
			self._txtNotice2.gameObject:SetActive(false)
			self._txtAddSucRate.text = "+" .. NewEquipStrongManager.ZhufushiAdd[self._zhufushiInfo.id] .. "%"
		else
			self._zhufushiInfo = nil
			self._txtNotice2.gameObject:SetActive(true)
			self._imgIcon2.gameObject:SetActive(false)
			self._txtAddSucRate.text = ""
			self._imgQuality2.color = ColorDataManager.GetColorByQuality(0)
		end
		
	else
		self._txtNotice2.gameObject:SetActive(true)
		self._imgIcon2.gameObject:SetActive(false)
		self._txtAddSucRate.text = ""
		self._imgQuality2.color = ColorDataManager.GetColorByQuality(0)
	end
end

function NewEquipQiangHuaPanel:_OnClickBtnItem3()
	if(self._canSelectProtect) then
		self._isSelectProtect = not self._isSelectProtect
		if(self._isSelectProtect) then
			if(BackpackDataManager.GetProductTotalNumBySpid(self._sucRate.protectItem.id) == 0) then
				ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
				{id = self._sucRate.protectItem.id})
				self._isSelectProtect = false
			end
		end
		
		if(self._isSelectProtect) then
			UISoundManager.PlayUISound(UISoundManager.ui_gem)
			ColorDataManager.UnSetGray(self._imgIcon3)
			self._txtNotice3.gameObject:SetActive(false)
		else
			ColorDataManager.SetGray(self._imgIcon3)
			self._txtNotice3.gameObject:SetActive(true)
		end
	end
end


function NewEquipQiangHuaPanel:_DisposeReference()
	self._getEqTipPanel = nil;
	self._txtName = nil;
	self._txtQiangHua = nil;
	self._txtSucRate = nil;
	self._txtExp = nil;
	self._imgAdd = nil;
	for i = 1, 3 do
		self["_goZhufushiItem" .. i] = nil
		self["_imgZhufushi" .. i] = nil
		self["_imgZhufushiQuality" .. i] = nil
		self["_txtZhufushiNum" .. i] = nil
	end
end

function NewEquipQiangHuaPanel:UpdatePanel(kind)
	self:CheckInfo(kind);
end

-- 是 EquipMainPanel 的 getEqTipPanel
function NewEquipQiangHuaPanel:SetEqTipPanel(getEqTipPanel)
	self._getEqTipPanel = getEqTipPanel;
end


-- 检查是否需要先去 物品 穿戴提示或者 描述提示
-- kind 装备部位
function NewEquipQiangHuaPanel:CheckInfo(kind)
	
	local eqinfo = EquipDataManager.GetProductByKind(kind);
	self._eqinfo = eqinfo
	self._isLuckFull = false
	if eqinfo == nil then
		self._sucRate = nil
		local me = HeroController:GetInstance();
		local heroInfo = me.info;
		local bag_equips = BackpackDataManager.GetFixMyEqByTypeAndKind(1, kind, heroInfo.kind);
		local t_num = table.getCount(bag_equips);
		
		if t_num > 0 then
			-- 背包 里有对应的装备
			SetUIEnable(self._getEqTipPanel, false);
			
			local eqs = EquipDataManager.GetEqBySort(bag_equips);
			MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_UPDATA, eqs);
			MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_SHOW);
			
			-- 隐藏自己功能的 ui
			self:SetEnable(false)
		else
			-- 背包里没有找到对应的装备
			SetUIEnable(self._getEqTipPanel, true);
			MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
			-- 隐藏自己功能的 ui
			self:SetEnable(false)
		end
	else
		SetUIEnable(self._getEqTipPanel, false);
		MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPDRESSTIPPANELCONTROLL_HIDE);
		-- 显示自己功能的 ui
		self:SetEnable(true)
		--- 更新数据
		self:_UpdatePanel()
		
		self.eq_selectCtr:SetProduct(self._eqinfo);
	end
	
end




local strongNotice = LanguageMgr.Get("equip/NewEquipQiangHuaPanel/strongNotice")

local strong1 = LanguageMgr.Get("equip/NewEquipQiangHuaPanel/strongLabel")
local strong2 = LanguageMgr.Get("equip/NewEquipQiangHuaPanel/freeStrongLabel")

function NewEquipQiangHuaPanel:_UpdatePanel()
	
	local strongInfo = NewEquipStrongManager.GetEquipStrongDataByIdx(self._eqinfo.idx + 1)
	self._txtName.text = self._eqinfo:GetName()
	self._txtName.color = ColorDataManager.GetColorByQuality(self._eqinfo:GetQuality())
	
	-- ProductManager.SetIconSprite(self._imgIcon0, self._eqinfo.configData.icon_id)
	-- self._imgQuality0.color = ColorDataManager.GetColorByQuality(self._eqinfo:GetQuality())
	if(strongInfo) then
		self._isSelectProtect = true
		SetUIEnable(self._trsCan, strongInfo.level ~= NewEquipStrongManager.MaxStrongLevel)
		SetUIEnable(self._trsCant, strongInfo.level == NewEquipStrongManager.MaxStrongLevel)
		if(strongInfo.level > 0) then
			self._txtQiangHua.text = strongNotice .. strongInfo.level
		else
			self._txtQiangHua.text = ""
		end
		local strongattr = NewEquipStrongManager.GetEquipStrongAttrByIdx(self._eqinfo.idx)
		self._phalanx:Build(table.getCount(strongattr), 1, strongattr)
		
		if(strongInfo.level ~= NewEquipStrongManager.MaxStrongLevel) then
			local luckInfo = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.luckId)
			self._sucRate = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.level)
			
			if(luckInfo.lucky_limit > 0) then
				self._slider.value = strongInfo.luck / luckInfo.lucky_limit
				self._txtLuck.text = strongInfo.luck .. "/" .. luckInfo.lucky_limit
				self._txtLuckNotice.text = canStrongNotice .. ColorDataManager.GetColorText(green, "+" .. luckInfo.promote_lev + 1)
				self._slider.gameObject:SetActive(true)
			else
				self._slider.gameObject:SetActive(false)
			end
			
			
			
			if((luckInfo.lucky_limit > 0) and(strongInfo.luck == luckInfo.lucky_limit)) then
				self._isLuckFull = true
				self._txtSucRate.text = "100%"
				self._goluckFull:SetActive(true)
				self._txtQiangHuaLabel.text = strong2
			else
				self._txtSucRate.text = self._sucRate.rate .. "%"
				self._goluckFull:SetActive(false)
				self._txtQiangHuaLabel.text = strong1
			end
			
			
			
			ProductManager.SetIconSprite(self._imgIcon1, self._sucRate.promoteItem.icon_id)
			self._imgQuality1.color = ColorDataManager.GetColorByQuality(self._sucRate.promoteItem.quality)
			local itemNum = BackpackDataManager.GetProductTotalNumBySpid(self._sucRate.promoteItem.id)
			self._txtNum1.text = itemNum .. "/" .. self._sucRate.promoteItemCount
			self._txtNum1.color =(itemNum >= self._sucRate.promoteItemCount) and green or red
			
			--有保护符
			if(self._sucRate.protectItem) then
				self._imgIcon3.gameObject:SetActive(true)
				self._txtCantNotice3.gameObject:SetActive(false)
				self._imgQuality3.color = ColorDataManager.GetColorByQuality(self._sucRate.protectItem.quality)
				self._canSelectProtect = true
				ProductManager.SetIconSprite(self._imgIcon3, self._sucRate.protectItem.icon_id)
				--选择了保护符	
				if(self._isSelectProtect) then
					if(BackpackDataManager.GetProductTotalNumBySpid(self._sucRate.protectItem.id) > 0) then
						ColorDataManager.UnSetGray(self._imgIcon3)
						self._txtNotice3.gameObject:SetActive(false)
					else
						self._isSelectProtect = false
						ColorDataManager.SetGray(self._imgIcon3)
						self._txtNotice3.gameObject:SetActive(true)
					end
				else
					ColorDataManager.SetGray(self._imgIcon3)
					self._txtNotice3.gameObject:SetActive(true)
				end
			else
				self._isSelectProtect = false
				self._imgQuality3.color = ColorDataManager.GetColorByQuality(0)
				self._canSelectProtect = false
				self._imgIcon3.gameObject:SetActive(false)
				self._txtNotice3.gameObject:SetActive(false)
				self._txtCantNotice3.gameObject:SetActive(true)
			end
			
			self:UpdateZhufushi()
			
		else
			self._goluckFull:SetActive(false)
		end
	end
	
	
	
end


return NewEquipQiangHuaPanel 