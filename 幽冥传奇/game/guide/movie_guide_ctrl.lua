require("scripts/game/guide/movie_guide_data")
require("scripts/game/guide/movie_guide_view")
MovieGuideCtrl = MovieGuideCtrl or BaseClass(BaseController)

function MovieGuideCtrl:__init()
	if MovieGuideCtrl.Instance ~= nil then
		ErrorLog("[MovieGuideCtrl] attempt to create singleton twice!")
		return
	end
	MovieGuideCtrl.Instance = self

	self.view = MovieGuideView.New()              --电影对白
	self.data = MovieGuideData.New()

	self.cur_guide = nil
	self.cur_index = 1
	self.cur_id = -1
	self:RegisterAllProtocols()
end	

function MovieGuideCtrl:__delete()
	self.view:DeleteMe()
	self.data:DeleteMe()
end	

function MovieGuideCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBeginMovieGuide, "OnBeginMovieGuide")
end

function MovieGuideCtrl:OnBeginMovieGuide(protocol)
	self.cur_id = protocol.guide_id
	self:StartGuide(protocol.guide_id)
end	

function MovieGuideCtrl:StartGuide(guide_id)
	if self.cur_guide == nil then
		self.cur_guide = self.data:GetGuideById(guide_id)
		if self.cur_guide then
			ViewManager.Instance:CloseAllView() --关闭所有模块
			MainuiCtrl.Instance:GetView():GetRootLayout():setVisible(false)
			self.view:Open()
			self:DoStep(self.cur_index)
		end
	end 
end	

function MovieGuideCtrl:DoStep(index)
	local step = self.cur_guide.steps[index]
	self.view:DoStep(step)
end	

function MovieGuideCtrl:IsGuiding()
	return self.cur_guide ~= nil
end	

function MovieGuideCtrl:OnClick()
	if self.cur_guide then
		self.cur_index = self.cur_index + 1
		if self.cur_index <= #self.cur_guide.steps then
			self:DoStep(self.cur_index)
		else
			self:EndMovie()
		end	
	end	
end	

function MovieGuideCtrl:EndMovie()
	if self.cur_guide then
		if self.cur_id ~= -1 then
			MovieGuideCtrl.SendEndMovieGuide(self.cur_id)
			self.cur_id = -1
		end
		self.cur_guide.is_end = true
		self.cur_guide = nil
		self.cur_index = 1
		self.view:Close()
		MainuiCtrl.Instance:GetView():GetRootLayout():setVisible(true)
		GuideCtrl.Instance:CheckCurGuide()
		GuideCtrl.Instance:KeyEquipViewCloseCallBack()
	end	
end	

function MovieGuideCtrl.SendEndMovieGuide(guide_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEndMovieGuideReq)
	protocol.guide_id = guide_id
	protocol:EncodeAndSend() 
end

