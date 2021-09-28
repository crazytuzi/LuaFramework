require("game/image_fuling/image_fuling_data")
require("game/image_fuling/image_fuling_view")
require("game/image_fuling/image_fuling_content_view")

ImageFuLingCtrl = ImageFuLingCtrl or BaseClass(BaseController)

function ImageFuLingCtrl:__init()
	if ImageFuLingCtrl.Instance then
		return
	end
	ImageFuLingCtrl.Instance = self

	self.view = ImageFuLingView.New(ViewName.ImageFuLing)
	self.data = ImageFuLingData.New()

	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))

	self:RegisterAllProtocols()
end

function ImageFuLingCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	ImageFuLingCtrl.Instance = nil
end

function ImageFuLingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCImgFulingInfo, "OnImgFulingInfo")
	self:RegisterProtocol(CSImgFulingOperate)
end

function ImageFuLingCtrl:OnImgFulingInfo(protocol)
	self.data:SetImgFuLingData(protocol)
	RemindManager.Instance:Fire(RemindName.ImgFuLing)
	self.view:Flush()
end

function ImageFuLingCtrl:SendImgFuLingUpLevelReq(fuling_type, item_index)
	self:SendImgFuLingOperate(IMG_FULING_OPERATE_TYPE.IMG_FULING_OPERATE_TYPE_LEVEL_UP, fuling_type, item_index)
end

function ImageFuLingCtrl:SendImgFuLingOperate(operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSImgFulingOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function ImageFuLingCtrl:MianUIOpenComlete()
	self:SendImgFuLingOperate(IMG_FULING_OPERATE_TYPE.IMG_FULING_OPERATE_TYPE_INFO_REQ)
end

function ImageFuLingCtrl:GetCanConsumeStuffData(img_fuling_type)
	local temp_list = self.data:GetCanConsumeStuff(img_fuling_type)
	return temp_list
end