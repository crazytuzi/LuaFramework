GuildQuestionRewadPanel = GuildQuestionRewadPanel or class("GuildQuestionRewadPanel",WindowPanel)
local GuildQuestionRewadPanel = GuildQuestionRewadPanel

function GuildQuestionRewadPanel:ctor()
	self.abName = "guild_house"
	self.assetName = "GuildQuestionRewadPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.model = GuildHouseModel:GetInstance()
	self.item_list = {}
end

function GuildQuestionRewadPanel:dctor()
end

--data:ranklist
function GuildQuestionRewadPanel:Open()
	GuildQuestionRewadPanel.super.Open(self)
end

function GuildQuestionRewadPanel:LoadCallBack()
	self.nodes = {
		"Scroll View/Viewport/Content","ScrollView/Viewport/Content/QuestionRankItem2",
	}
	self:GetChildren(self.nodes)
	self.QuestionRankItem2_gameobject = self.QuestionRankItem2.gameObject
	SetVisible(self.QuestionRankItem2_gameobject, false)

	self:AddEvent()
	self:SetPanelSize(642, 500)
	self:SetTileTextImage("guild_house_image", "question_reward_title_img")
	self:SetTitleImgPos(63, -4.2)
end

function GuildQuestionRewadPanel:AddEvent()

end

function GuildQuestionRewadPanel:OpenCallBack()
	self:UpdateView()
end

function GuildQuestionRewadPanel:UpdateView( )
	for i=1, #Config.db_guild_question_reward do
		local item = self.item_list[i] or QuestionRankItem2(self.QuestionRankItem2_gameobject, self.RightContent)
		item:SetData(Config.db_guild_question_reward[i], i)
		self.item_list[i] = item
	end
end

function GuildQuestionRewadPanel:CloseCallBack(  )
	for i=1, #self.item_list do 
		self.item_list[i]:destroy()
	end
end
function GuildQuestionRewadPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	--if self.table_index == 1 then
		-- if not self.show_panel then
		-- 	self.show_panel = ChildPanel(self.transform)
		-- end
		-- self:PopUpChild(self.show_panel)
	--end
end