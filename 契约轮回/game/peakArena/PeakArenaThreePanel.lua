---
--- Created by  Administrator
--- DateTime: 2019/8/1 10:09
---
PeakArenaThreePanel = PeakArenaThreePanel or class("PeakArenaThreePanel", WindowPanel)
local this = PeakArenaThreePanel

function PeakArenaThreePanel:ctor(parent_node, parent_panel)
	
	self.abName = "peakArena"
	self.assetName = "PeakArenaThreePanel"
	self.image_ab = "peakArena_image";
	self.layer = "UI"
	
	self.panel_type = 2
	self.model = PeakArenaModel:GetInstance()
	self.show_sidebar = true        --是否显示侧边栏
	--self.is_show_money=true
	if self.show_sidebar then
		-- 侧边栏配置
		self.sidebar_data = {
			{ text = ConfigLanguage.PeakArena.reward, id = 1 },
			{ text = ConfigLanguage.PeakArena.target , id = 2 },
			{ text = ConfigLanguage.PeakArena.rank , id = 3 },
		}
	end
	self.events = {}

end

function PeakArenaThreePanel:Open(page)
	WindowPanel.Open(self)
	
	self.defPage = page
end

function PeakArenaThreePanel:dctor()
	GlobalEvent:RemoveTabListener(self.events)
	if self.currentView then
		self.currentView:destroy();
	end
end




function PeakArenaThreePanel:LoadCallBack()
	self:SetTileTextImage("peakArena_image", "PArena_title_text2");
	
	self:InitUI();
	self:AddEvent();
	self:UpdateRedDot()
	--self:SwitchCallBack(self.defPage)
end

function PeakArenaThreePanel:UpdateRedDot()
	--self:SetIndexRedDotParam(1,bo)
	local isRed = false
	--local cfg = Config.db_combat1v1_merit_reward
	local cfg = self.model:GetMeritCfg()
	for i = 1, #cfg do
		if self.model:IsMeritReward(cfg[i].merit) == 0 then
			isRed = true
			break
		end
	end
	self:SetIndexRedDotParam(1,isRed)
	self:SetIndexRedDotParam(3,self.model.daily_reward == 1)
	
end

function PeakArenaThreePanel:SetTabIndex()
	if self.bg_win then
		self.bg_win:SetTabIndex(self.defPage)
	end
end

function PeakArenaThreePanel:InitUI()
	
end

function PeakArenaThreePanel:AddEvent()

	self.events[#self.events + 1] = GlobalEvent.AddEventListener(PeakArenaEvent.ShowRedPoint, handler(self, self.UpdateRedDot))
end

function PeakArenaThreePanel:SwitchCallBack(index)
	if self.currentView then
		self.currentView:destroy();
	end
	
	self.currentView = nil
	if index == 1 then
		self.currentView = PeakArenaRewardPanel(self.transform, "UI");
		self:PopUpChild(self.currentView)
	elseif index == 2 then
		self.currentView = PeakArenaTargetPanel(self.transform, "UI");
		self:PopUpChild(self.currentView)
	elseif index == 3 then
		self.currentView = PeakArenaRankPanel(self.transform, "UI");
		self:PopUpChild(self.currentView)
	end
	
	self.selectedIndex = index
	
end