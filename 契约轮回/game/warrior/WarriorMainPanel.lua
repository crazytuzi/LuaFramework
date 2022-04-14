---
--- Created by  Administrator
--- DateTime: 2019/8/13 11:21
---
WarriorMainPanel = WarriorMainPanel or class("WarriorMainPanel", BaseItem)
local this = WarriorMainPanel

function WarriorMainPanel:ctor(parent_node, parent_panel)
    self.abName = "warrior";
    self.image_ab = "warrior_image";
    self.assetName = "WarriorMainPanel"
    self.layer = "UI"
    self.events = {}
	self.rankAwards = {}
    self.model = WarriorModel:GetInstance()
    WarriorMainPanel.super.Load(self)
end

function WarriorMainPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
	for i, v in pairs(self.rankAwards) do
		v:destroy()
	end
	self.rankAwards = {}
end

function WarriorMainPanel:LoadCallBack()
    self.nodes = {
		"icon/rankBtn","icon/shopBtn","enterBtn","downObj/gxBg/gxTex","downObj/gxBg/gxIcon",
		"rank/rank_3_award/Viewport/award_con_3","rank/rank_1_award/Viewport/award_con_1","rank/rank_2_award/Viewport/award_con_2",
		"leftObj/powerObj/power","leftObj/title","wenhao"
    }
    self:GetChildren(self.nodes)
	self.gxTex = GetText(self.gxTex)
	self.gxIcon = GetImage(self.gxIcon)
	self.titleImg = GetImage(self.title)
	self.power = GetText(self.power)
    self:InitUI()
    self:AddEvent()
	--WarriorController:GetInstance():RequesWarriorInfo()
end

function WarriorMainPanel:InitUI()
	--local iconName = Config.db_item[enum.ITEM.ITEM_HONOR].icon
	GoodIconUtil:CreateIcon(self, self.gxIcon, enum.ITEM.ITEM_HONOR, true)
	local money = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.Honor)
	self.gxTex.text = money
	self:InitRankAward()
	local attriList = String2Table(Config.db_title[46120].attrib)
	self.power.text = GetPowerByConfigList(attriList)

	lua_resMgr:SetImageTexture(self, self.titleImg, Constant.TITLE_IMG_PATH, 46120, false, nil, false)
end

function WarriorMainPanel:AddEvent()
	local function callBack()
		--local roleLevel = RoleInfoModel:GetInstance():GetMainRoleLevel();
		--local actTab = Config.db_activity[10231];
		--if actTab then
		--	local sceneConfig = Config.db_scene[actTab.scene];
		--	if sceneConfig then
		--		local reqs = String2Table(sceneConfig.reqs);
		--		if reqs[1] == "level" then
		--			if roleLevel < reqs[2] then
		--				Notify.ShowText("等级不足" .. reqs[2] .. ",无法进入");
		--				return ;
		--			end
		--		end
		--	else
		--		Notify.ShowText("没有找到相关场景配置,请检查");
		--	end
		--
		--	SceneControler:GetInstance():RequestSceneChange(actTab.scene, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, 10231);
		--else
		--	Notify.ShowText("没有找到活动,请检查配置");
		--end
		self.model:EnterWarriorDungeon()
	end
	AddClickEvent(self.enterBtn.gameObject,callBack)
	
	local function callBack()
		lua_panelMgr:GetPanelOrCreate(WarriorTowPanel):Open()
	end
	AddButtonEvent(self.rankBtn.gameObject,callBack)

	local function callBack()
		UnpackLinkConfig("180@1@3")
	end
	AddButtonEvent(self.shopBtn.gameObject,callBack)

	local function call_back()
		ShowHelpTip(HelpConfig.Warrior.Help1,true,700)
	end
	AddButtonEvent(self.wenhao.gameObject,call_back)
end

function WarriorMainPanel:InitRankAward()
	local cfg = Config.db_warrior_reward

	local isCross = false
	local openTime1 = String2Table(Config.db_activity[10232].reqs)[2]
	local day = LoginModel.GetInstance():GetOpenTime()
	if day >= openTime1 then
		isCross = true
	end
	for i = 1, 3 do
		local reward = String2Table(cfg[i].gain)
		if isCross then
			reward =  String2Table(cfg[i].cross_gain)
		end
		for j = 1, #reward do
			local awardItem = GoodsIconSettorTwo(self["award_con_" .. i]);
			local param = {}
			param["item_id"] = reward[j][1];
			param["can_click"] = true;
			param["bind"] = true;
			param["size"] = { x = 80, y = 80 }
			param["effect_type"] = 1
			param["color_effect"] = 4
			param["num"] = reward[j][2];
			awardItem:SetIcon(param);
			table.insert(self.rankAwards, awardItem);
		end
	end
end