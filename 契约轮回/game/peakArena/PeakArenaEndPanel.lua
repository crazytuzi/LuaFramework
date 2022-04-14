---
--- Created by  Administrator
--- DateTime: 2019/8/2 15:52
---
PeakArenaEndPanel = PeakArenaEndPanel or class("PeakArenaEndPanel", BasePanel)
local this = PeakArenaEndPanel

function PeakArenaEndPanel:ctor(parent_node, parent_panel)
	self.abName = "peakArena";
	self.assetName = "PeakArenaEndPanel"
	self.layer = "Top"
	self.events = {}
	self.model = PeakArenaModel:GetInstance()
	self.itemicon = {}
end

function PeakArenaEndPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
	if self.endItem then
		self.endItem:destroy();
	end
	for i, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
end

function PeakArenaEndPanel:LoadCallBack()
    self.nodes = {
		"sliderObj/sliderTex","gradeObj/gradeImg","sliderObj/slider",
		"succObj/soccer","resultImg","gradeObj/gradeTex","iconParent",
    }
    self:GetChildren(self.nodes)
	self.sliderTex = GetText(self.sliderTex)
	self.gradeImg = GetImage(self.gradeImg)
	self.slider = GetImage(self.slider)
	self.soccer = GetText(self.soccer)
	self.resultImg = GetImage(self.resultImg)
	self.gradeTex = GetText(self.gradeTex)
    self:InitUI()
    self:AddEvent()
end

function PeakArenaEndPanel:Open(data)
	self.data = data
	WindowPanel.Open(self)
end

function PeakArenaEndPanel:InitUI()
	local data = {}
	data.isClear =  self.data.is_win
	data.IsCancelAutoSchedule = false
	data.layer = "UI"
	self.endItem = DungeonEndItem(self.transform, data);
	self.endItem:StartAutoClose(5)
	self:InitInfo()
	self:CreatIcons(self.data.rewards)
end

function PeakArenaEndPanel:InitInfo()
	--local gradeCfg = Config.db_combat1v1_grade[self.data.grade]
	local cfg = self.model:GetGradeCfg()
	local gradeCfg = cfg[self.data.grade]
	if not gradeCfg then
		return 
	end
	self.gradeTex.text = gradeCfg.name
	if self.data.is_win then
		--if self.data.chg > 0 then
			self.soccer.text = "Points+"..self.data.chg
		--end
		lua_resMgr:SetImageTexture(self, self.resultImg, "peakArena_image", "PArena_succ_text", false, nil, false)

	else
		if self.data.chg > 0 then
			self.soccer.text = "Points+"..self.data.chg
		else
			self.soccer.text = "Points"..self.data.chg
		end
		
		lua_resMgr:SetImageTexture(self, self.resultImg, "peakArena_image", "PArena_def_text", false, nil, false)
	end
	
	lua_resMgr:SetImageTexture(self, self.gradeImg, "peakArena_image", "PArena_rank"..math.floor(self.data.grade/10), false, nil, false)
	self:SetSlider()
	
end

function PeakArenaEndPanel:SetSlider()
	local curMaxScore = self.model:GetScoreForGrade()
	local curGrade = self.model:GetGrade()
	local lastGrade = self.model:GetGradeCfg()[curGrade].lastgrade
	local curSorre
	if lastGrade ~= 0 then
		local cfg = self.model:GetGradeCfg()
		local lastCfg = cfg[lastGrade]
		--local lastCfg = Config.db_combat1v1_grade[lastGrade]
		curSorre = self.model.score - lastCfg.score
		curMaxScore = self.model:GetScoreForGrade() - lastCfg.score
	else
		curSorre = self.model.score
	end
	if curMaxScore <= 0 then --满级
		self.slider.fillAmount = 1
		self.sliderTex.text = string.format("%s/%s",curSorre,"max")
	else
		self.slider.fillAmount = curSorre/curMaxScore
		self.sliderTex.text = string.format("%s/%s",curSorre,curMaxScore)
	end

end

function PeakArenaEndPanel:AddEvent()
	local function call_back()
		local  scene_data = SceneManager:GetInstance():GetSceneInfo()
		if self.model:Is1v1Fight(scene_data.scene) then
			SceneControler:GetInstance():RequestSceneLeave();
		end
		self:Close()
	end
	self.endItem:SetCloseCallBack(call_back);
	self.endItem:SetAutoCloseCallBack(call_back)
end

function PeakArenaEndPanel:CreatIcons(rewards)
	
	--local rewardTab = String2Table(self.data.reward)
	local index = 0
	for k, v in pairs(rewards) do
		index = index + 1
		if self.itemicon[index] == nil then
			self.itemicon[index] = GoodsIconSettorTwo(self.iconParent)
		end
		local param = {}
		param["model"] = BagModel
		param["item_id"] = k
		param["num"] = v
		--param["bind"] = rewardTab[i][3]
		param["can_click"] = true
		--param["size"] = {x = 78,y = 78}
		self.itemicon[index]:SetIcon(param)
	end

end