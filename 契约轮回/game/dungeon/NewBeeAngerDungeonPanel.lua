NewBeeAngerDungeonPanel = NewBeeAngerDungeonPanel or class("NewBeeAngerDungeonPanel",NoviceDungeonPanel)
local NewBeeAngerDungeonPanel = NewBeeAngerDungeonPanel

function NewBeeAngerDungeonPanel:ctor()
	self.is_guided = false



	self.boss = nil
	self.boss_hp_event_id = nil
end

function NewBeeAngerDungeonPanel:dctor()
	if self.mask_item then
		self.mask_item:destroy()
		self.mask_item = nil
	end
	self.parent_item = nil

	if self.guide_item then
		self.guide_item:destroy()
		self.guide_item = nil
	end


	if self.boss and self.boss.object_info and self.boss_hp_event_id then
		self.boss.object_info:RemoveListener(self.buff_event_id)
	end
	self.boss = nil
	self.boss_hp_event_id = nil
end

function NewBeeAngerDungeonPanel:Open(data)
	NewBeeAngerDungeonPanel.super.Open(self, data)
end

function NewBeeAngerDungeonPanel:LoadCallBack()
	NewBeeAngerDungeonPanel.super.LoadCallBack(self)
end

function NewBeeAngerDungeonPanel:AddEvent()
	NewBeeAngerDungeonPanel.super.AddEvent(self)

	local mainpanel = lua_panelMgr:GetPanelOrCreate(MainUIView)
    self.parent_item = mainpanel.main_bottom_right.skill_list[14]
    if not self.mask_item then
    	self.mask_item = DungeonNewBeeSkillMaskItem(self.parent_item.transform)
    end
end

function NewBeeAngerDungeonPanel:RequseInfo()
    
end

--重写父类的同名方法
function NewBeeAngerDungeonPanel:InitScene()

	NewBeeAngerDungeonPanel.super.InitScene(self)
	

    local createdMonTab = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP);
    if createdMonTab then
		for k, monster in pairs(createdMonTab) do

			self.boss = monster

			--监听boss血量	
			--等到boss召唤出小怪时出怒气技能指引
			local function call_back(  )
				local cur_hp = self.boss.object_info:GetValue("hp")
				local max_hp = self.boss.object_info:GetValue("hpmax")
				--logError("boss的hp:"..cur_hp..",maxhp:"..max_hp)
				if cur_hp / max_hp <= 0.60 then
					self:StartGuide()
					self.boss.object_info:RemoveListener(self.boss_hp_event_id)
					self.boss = nil
					self.boss_hp_event_id = nil
				end
			end
			self.boss_hp_event_id = self.boss.object_info:BindData("hp", call_back);

			return
        end
    end
end

function NewBeeAngerDungeonPanel:StartGuide()
	self.is_guided = true
	--关掉其他Ui层界面
	local panel_list = lua_panelMgr:GetPanelListByLayer(LayerManager.LayerNameList.UI)
	if not table.isempty(panel_list) then
		for panel, _ in pairs(panel_list) do
			panel:Close()
		end
	end
	
	--切换到技能页
	lua_panelMgr:GetPanelOrCreate(MainUIView).main_bottom_right:Switch(false)

	--停止自动战斗
	AutoFightManager.GetInstance():StopAutoFight()

	local function call_back()
		if self.mask_item then
			self.mask_item:destroy()
			self.mask_item = nil
		end

		if not self.guide_item then

			--直接怒气加满
			local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
            SceneControler:GetInstance():RequestAddBuff(300410016,main_role_id)

			self.guide_item = DungeonNewBeeGuideItem(self.parent_item.transform)
			local function click_callback()
				TargetClickCall(self.parent_item.img_anger.gameObject)
				AutoFightManager.GetInstance():StartAutoFight()
			end

			local guide_text = "Tap to unleash ultra skill-Unceasing Wrath"
			--local countdown_format = "（%s秒后自动释放）"
			local x1 = (ScreenWidth / 2) - 223
			--刘海屏偏移检测 ffh
			x1 = x1 - UIAdaptManager:GetInstance():GetBanScreenOffsetX()

			local y1 = -(ScreenHeight / 2) + 228
			local pos = {x= x1,y= y1,z=70000}
			self.guide_item:SetData(click_callback, self.parent_item.img_anger.gameObject,true,guide_text,pos)
		end

	end
	--GlobalSchedule:StartOnce(call_back, 1.5)
	call_back()
end
