require "Core.Module.Common.UIComponent"
require "Core.Module.NewTrump.View.Item.SubNewTrumpRefineItem"
require "Core.Module.NewTrump.View.Item.SubNewTrumpRefineConditionItem"



SubNewTrumpRefinePanel = class("SubNewTrumpRefinePanel", UIComponent);
function SubNewTrumpRefinePanel:New(trs)
	self = {};
	setmetatable(self, {__index = SubNewTrumpRefinePanel});
	if(trs) then
		self:Init(trs)
	end
	
	return self
end


function SubNewTrumpRefinePanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SubNewTrumpRefinePanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtPro1 = UIUtil.GetChildInComponents(txts, "txtPro1");
	self._txtPro2 = UIUtil.GetChildInComponents(txts, "txtPro2");
	self._txtNotice = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtNotice")
	
	self._txtPower = UIUtil.GetChildByName(self._gameObject, "UILabel", "powerComponet/power")
	self._btnActive = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnActive");
	self._btnRefine = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnRefine");
	self._phalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "scrollView/phalanx")
	self._trsItem1 = UIUtil.GetChildByName(self._gameObject, "item1")
	self._trsItem2 = UIUtil.GetChildByName(self._gameObject, "item2")
	self._item1 = SubNewTrumpRefineConditionItem:New()
	self._item2 = SubNewTrumpRefineConditionItem:New()
	self._item1:Init(self._trsItem1)
	self._item2:Init(self._trsItem2)
	
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, SubNewTrumpRefineItem)
end

function SubNewTrumpRefinePanel:_InitListener()
	self._onClickBtnActive = function(go) self:_OnClickBtnActive(self) end
	UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnActive);
	self._onClickBtnRefine = function(go) self:_OnClickBtnRefine(self) end
	UIUtil.GetComponent(self._btnRefine, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRefine);
end

function SubNewTrumpRefinePanel:_OnClickBtnActive()
	self:_Refine()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.TRUMP_REFINE_ACTIVITY)
end

function SubNewTrumpRefinePanel:_OnClickBtnRefine()
	self:_Refine()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.TRUMP_REFINE)
end


function SubNewTrumpRefinePanel:_Refine()
	if(NewTrumpManager.CheckRefine(self.data, NewTrumpManager.GetSelectRefineLevel())) then	
		local count = BackpackDataManager.GetProductTotalNumBySpid(self.refineData.condition[1].itemId)
		if(count >= self.refineData.condition[1].itemCount) then			
			NewTrumpProxy.SendRefineTrump(self.data.id, NewTrumpManager.GetSelectRefineLevel())
		else
			local reqCount = self.refineData.condition[1].itemCount - count
			--[title:标题 msg:文本内容 ok_Label:确认按钮文本 cance_lLabel:取消按钮文本 
			--toggleValue:toggle的值 handle:确认回调 cancelHandler:取消回调 toggleHandler:toggle值变化回调
			--target:函数调用的实例]
			local refineFunc = function()				
				if(MoneyDataManager.Get_gold() >= reqCount * self.refineData.gold) then
					NewTrumpProxy.SendRefineTrump(self.data.id, NewTrumpManager.GetSelectRefineLevel())
				else
					--ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3})	
                    ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});				
				end				
			end
			
			if(NewTrumpManager.GetAutoConfirm()) then				
				refineFunc()
			else
				ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM7PANEL,
				{
					title = LanguageMgr.Get("common/buyNoticeTitle"),
					toggleValue = NewTrumpManager.GetAutoConfirm(),
					msg = LanguageMgr.Get("SubNewTrumpRefinePanel/confirm", {count = reqCount, num = reqCount * self.refineData.gold,
					name = ProductManager.GetProductById(self.refineData.condition[1].itemId).name}),
					hander = refineFunc,
					toggleHandler = NewTrumpManager.SetAutoConfirm,
				})
			end
			
		end
	end
end


function SubNewTrumpRefinePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	if(self._phalanx) then
		self._phalanx:Dispose()
		self._phalanx = nil
	end
	
	if(self._item1) then
		self._item1:Dispose()
		self._item1 = nil
	end
	
	if(self._item2) then
		self._item2:Dispose()
		self._item2 = nil
	end
	
end

function SubNewTrumpRefinePanel:_DisposeListener()
	UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnActive = nil;
	UIUtil.GetComponent(self._btnRefine, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRefine = nil;
end

function SubNewTrumpRefinePanel:_DisposeReference()
	self._btnActive = nil;
	self._btnRefine = nil;
	
	self._txtPro1 = nil;
	self._txtPro2 = nil;
end

function SubNewTrumpRefinePanel:UpdatePanel()
	self.data = NewTrumpManager.GetCurrentSelectTrump()
	if(self.data) then
		local refineData = self.data:GetAllRefineData()
		self._phalanx:Build(table.getCount(refineData), 1, refineData)
		local attr = self.data:GetAllAttr()
		local propertyData = attr:GetPropertyAndDes()
		
		if(propertyData[1]) then
			self._txtPro1.text = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), "+" .. propertyData[1].property)
		end
		
		if(propertyData[2]) then
			self._txtPro2.text = propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), "+" .. propertyData[2].property)
		end
		
		self._txtPower.text = CalculatePower(attr)
	end
	
	self:UpdateSelect()
end

function SubNewTrumpRefinePanel:UpdateSelect()
	local selectRefineLevel = NewTrumpManager.GetSelectRefineLevel()
	
	local item = self._phalanx:GetItem(selectRefineLevel)
	if(item) then
		item.itemLogic:SetToggleActive(true)
	end
end
local notice = LanguageMgr.Get("SubNewTrumpRefinePanel/notActive")
local levNotice = LanguageMgr.Get("SubNewTrumpRefinePanel/levNotice")
function SubNewTrumpRefinePanel:UpdateRefineInfo()
	local selectRefineLevel = NewTrumpManager.GetSelectRefineLevel()
	self.refineData = self.data:GetAllRefineData() [selectRefineLevel]
	if(self.refineData and self.data.state > NewTrumpInfo.State.CanActive) then
		self._txtNotice.text = ""
		if(HeroController:GetInstance().info.level < self.refineData.req_lev) then
			self._txtNotice.text = string.format(levNotice, self.refineData.req_lev)
			self._btnActive.gameObject:SetActive(false)
			self._btnRefine.gameObject:SetActive(false)
		else
			if(self.refineData.state == 0) then
				self._btnActive.gameObject:SetActive(true)
				self._btnRefine.gameObject:SetActive(false)
			else
				self._btnActive.gameObject:SetActive(false)
				self._btnRefine.gameObject:SetActive(true)
			end
		end		
	else
		
		self._btnActive.gameObject:SetActive(false)
		self._btnRefine.gameObject:SetActive(false)
		self._txtNotice.text = notice
	end
	
	self._item1:UpdateItem(self.refineData.condition[1])
	self._item2:UpdateItem({itemId = 1, itemCount = self.refineData.reqMoney})	
end

function SubNewTrumpRefinePanel:PlayRefineUIEffect(index)
	local item = self._phalanx:GetItem(index)
	if(item) then
		item.itemLogic:PlayUIEffect(true)
	end
end 