require("game/museum_card/museum_card_data")
require("game/museum_card/museum_card_view")
require("game/museum_card/museum_card_fenjie")
require("game/museum_card/museum_card_info")
require("game/museum_card/museum_card_attrtip")
require("game/museum_card/museum_card_theme")

MuseumCardCtrl = MuseumCardCtrl or BaseClass(BaseController)

function MuseumCardCtrl:__init()
	if MuseumCardCtrl.Instance ~= nil then
		print_error("[MuseumCardCtrl] Attemp to create a singleton twice !")
	end
	MuseumCardCtrl.Instance = self
	self.view = MuseumCardView.New(ViewName.MuseumCardChapter)
	self.fenjie_view = MuseumCardFenJie.New(ViewName.MuseumCardFenJie)
	self.info_view = MuseumCardInfo.New(ViewName.MuseumCardInfo)
	self.attr_tip_view = MuseumCardAttrTip.New(ViewName.MuseumCardAttrTip)
	self.theme_view = MuseumCardTheme.New(ViewName.MuseumCardTheme)
	self.data = MuseumCardData.New()

	self:RegisterAllProtocols()

	RemindManager.Instance:Register(RemindName.MuseumCardOne, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.MuseumCardOne))
	RemindManager.Instance:Register(RemindName.MuseumCardTwo, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.MuseumCardTwo))
	RemindManager.Instance:Register(RemindName.MuseumCardThree, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.MuseumCardThree))
	RemindManager.Instance:Register(RemindName.MuseumCardFour, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.MuseumCardFour))

	if nil == self.item_change_callback then
		self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	end
end

function MuseumCardCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.fenjie_view then
		self.fenjie_view:DeleteMe()
		self.fenjie_view = nil
	end

	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	if self.attr_tip_view then
		self.attr_tip_view:DeleteMe()
		self.attr_tip_view = nil
	end

	if self.theme_view then
		self.theme_view:DeleteMe()
		self.theme_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	RemindManager.Instance:UnRegister(RemindName.MuseumCardOne)
	RemindManager.Instance:UnRegister(RemindName.MuseumCardTwo)
	RemindManager.Instance:UnRegister(RemindName.MuseumCardThree)
	RemindManager.Instance:UnRegister(RemindName.MuseumCardFour)

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	MuseumCardCtrl.Instance = nil
end

function MuseumCardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHoChiCardStateInfo, "OnHoChiCardStateInfo")
end

-- 请求信息
function MuseumCardCtrl:SendCommonOperateReq(opera_type, param1, param2, param3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHoChiCommonOperateReq)
	protocol.opera_type = opera_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol:EncodeAndSend()
end

-- 卡牌信息
function MuseumCardCtrl:OnHoChiCardStateInfo(protocol)
	RemindManager.Instance:Fire(RemindName.MuseumCardOne)
	RemindManager.Instance:Fire(RemindName.MuseumCardTwo)
	RemindManager.Instance:Fire(RemindName.MuseumCardThree)
	RemindManager.Instance:Fire(RemindName.MuseumCardFour)

	self.data:SetHoChiCardStateInfo(protocol)
	if self.view then
		self.view:Flush()
	end

	if self.theme_view then
		self.theme_view:Flush()
	end

	if self.info_view then
		self.info_view:Flush("card_state")
	end
end

function MuseumCardCtrl:OpenCardThemeView(file_id, chapter_id)
	if self.theme_view then
		self.theme_view:SetData(file_id, chapter_id)
		self.theme_view:Open()
	end
end

function MuseumCardCtrl:OpenCardInfoView(file_id, chapter_id, card_id)
	if self.info_view then
		self.info_view:SetData(file_id, chapter_id, card_id)
		self.info_view:Open()
		self.info_view:Flush()
	end
end

function MuseumCardCtrl:OpenAttrView(file_id, chapter_id)
	if self.attr_tip_view then
		self.attr_tip_view:SetData(file_id, chapter_id)
		self.attr_tip_view:Open()
		self.attr_tip_view:Flush()
	end
end

function MuseumCardCtrl:OnCardUpStarResult(result)
	if self.info_view then
		self.info_view:FlushUpStarResult(result)
	end
end

function MuseumCardCtrl:GetGemChangeRemind(remind_type)
	local flag = 0
	if remind_type == RemindName.MuseumCardOne then
		if self.data:GetHasRemindByFile(1) then
			flag = 1
		end
	elseif remind_type == RemindName.MuseumCardTwo then
		if self.data:GetHasRemindByFile(2) then
			flag = 1
		end
	elseif remind_type == RemindName.MuseumCardThree then
		if self.data:GetHasRemindByFile(3) then
			flag = 1
		end
	elseif remind_type == RemindName.MuseumCardFour then
		if self.data:GetHasRemindByFile(4) then
			flag = 1
		end
	end

	return flag
end

function MuseumCardCtrl:OnItemDataChange(change_item_id)
	local item_list = self.data:GetMuseumCardItemList()
	for k, v in pairs(item_list) do
		if v == change_item_id then
			MuseumCardCtrl.Instance:SendCommonOperateReq(RA_MUSEUM_CARD_OPERA_TYPE.RA_MUSEUM_CARD_OPERA_TYPE_ALL_INFO)
		end
	end
end