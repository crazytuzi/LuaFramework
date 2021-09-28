-- 主面板:排行榜
RankPanel = BaseClass(CommonBackGround)

function RankPanel:__init()
	self.model = MallModel:GetInstance()
	self.id = "RankPanel"
	self.bgUrl = "bg_big1"
	self:SetTitle("排行榜")
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	if not self.rankContent then
		self.rankContent = RankContent.New()
		self.rankContent:SetXY(0, 0)
		self.container:AddChild(self.rankContent.ui)
		self.ui:AddChild(self:GetBtnClose()) 
	end
	cur = self.rankContent
	if cur then
		cur:SetVisible(true)
	end

	self:InitEvent()
end

function RankPanel:InitEvent()
	self.closeCallback = function()
		if self.rankContent ~= nil then
			self.rankContent:ClearDescTips()
		end
	end
end

-- 关闭
function RankPanel:Close()
	CommonBackGround.Close(self)
end

-- 各个面板这里布局
function RankPanel:Layout()
	-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现（仅一次）
end

function RankPanel:__delete()
	if self.rankContent then
		self.rankContent:Destroy()
	end
	self.rankContent = nil
	self.selectPanel = nil
end