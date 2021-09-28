-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_underwear = i3k_class("wnd_underwear", ui.wnd_base)
--内甲

function wnd_underwear:ctor()
	self.BtnType = {}--按钮的三种状态 1显示解锁  2显示装备 3显示装备中
	self.setModel = false
end
function wnd_underwear:configure()
	local cfg = g_i3k_game_context:GetUserCfg()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.hide_self_btn:onClick(self,self.hideSelfArmorEffect)
	widgets.hide_all_btn:onClick(self,self.hideAllArmorEffect)
	widgets.hide_all_check:setVisible(cfg:GetIsHideAllArmorEffect())
	widgets.hide_self_check:setVisible(g_i3k_game_context:getArmorHideEffect())

	self.underWearTrr = {
	{name = widgets.name1 ,level = widgets.level1,stage = widgets.stage1,trr = widgets.trr1,btn = widgets.getAllAnnex1,btnTrr = widgets.getAlltrr1,effect = widgets.Eff1 , notUnlock = widgets.notUnlock1 ,bg_btn = widgets.bg_btn1 ,equipImg = widgets.equiping1},
	{name = widgets.name2 ,level = widgets.level2,stage = widgets.stage2,trr = widgets.trr2,btn = widgets.getAllAnnex2,btnTrr = widgets.getAlltrr2,effect = widgets.Eff2 , notUnlock = widgets.notUnlock2, bg_btn = widgets.bg_btn2 ,equipImg = widgets.equiping2},
	{name = widgets.name3 ,level = widgets.level3,stage = widgets.stage3,trr = widgets.trr3,btn = widgets.getAllAnnex3,btnTrr = widgets.getAlltrr3,effect = widgets.Eff3 , notUnlock = widgets.notUnlock3, bg_btn = widgets.bg_btn3 ,equipImg = widgets.equiping3},
	}
	
	self.introduce = widgets.introduce_btn
	self.introduce:onClick(self, function ()
		--self:onCloseUI()
		g_i3k_logic:OpenUnderWearIntroduce()
	end
	)

end
function wnd_underwear:setModelData()
	--特效
	local _, UnderWearData =  g_i3k_game_context:getUnderWearData()
	self.tab = {}
	for i,v in ipairs(UnderWearData) do 
		ui_set_hero_model(self.underWearTrr[i].effect, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(), {id = i, stage = v.rank})
	end
end


function wnd_underwear:refresh()
	--默认都是未解锁，一阶的名称和特效id，然后等服务器返回结果，来刷新界面数据  i3k_db_under_wear_upStage
	--冰，火，元气
	if not self.setModel  then
		self.setModel  = true
		self:setModelData()
	end
	local curUnderWear, UnderWearData =  g_i3k_game_context:getUnderWearData()
	self.tab = {}
	for i,v in ipairs(UnderWearData) do 
		local level = v.level
		local rank = v.rank
		if v.level==0 then
			level = 1
		end
		if v.rank==0 then
			rank = 1
		end
		local nameStr = i3k_db_under_wear_upStage[v.id][rank].stageName
		local levelStr = i3k_db_under_wear_update[v.id][level].underWearLevel
		local stageStr = i3k_db_under_wear_upStage[v.id][rank].stageRank
		self.underWearTrr[i].name:setText(nameStr)
		
		--提示未解锁
		self.underWearTrr[i].level:setText(levelStr.."级")
		self.underWearTrr[i].stage:setText(stageStr.."阶")
		local str = i3k_db_under_wear_cfg[i3k_db_under_wear_cfg[v.id].restrainId].name
		self.underWearTrr[i].trr:setText(string.format("克制%s%s",str,"系内甲"))
		
		self.underWearTrr[i].btn:setTag(1000+i)
		local tab = {underwear_name = nameStr ,underwear_level =levelStr ,underwear_stage = stageStr }
		table.insert(self.tab ,i,tab)
		self.underWearTrr[i].btn:onClick(self, self.openUnderWear,self.tab) --
		
		self.underWearTrr[i].bg_btn:setTag(2000+i)
		self.underWearTrr[i].bg_btn:onClick(self, self.openLevelUp,self.tab) --
		self.underWearTrr[i].btn:enableWithChildren() 
		local str ="锻造"
		self.underWearTrr[i].btn:show()
		self.underWearTrr[i].equipImg:hide()
		if  v.unlocked ==0 then
			str ="锻造"
			self.underWearTrr[i].notUnlock:show();
			self.underWearTrr[i].level:hide()
			self.underWearTrr[i].stage:hide()
			self.BtnType[i] = {1}
		elseif i== curUnderWear then
			str ="装备中"
			self.underWearTrr[i].notUnlock:hide();
			self.underWearTrr[i].level:show()
			self.underWearTrr[i].stage:show()
			self.BtnType[i] = {3}
			self.underWearTrr[i].btn:disableWithChildren()--置灰 
			self.underWearTrr[i].btn:hide() 
			self.underWearTrr[i].equipImg:show()
		else
			str ="装备"
			self.underWearTrr[i].notUnlock:hide();
			self.underWearTrr[i].level:show()
			self.underWearTrr[i].stage:show()
			self.BtnType[i] = {2}
		end
		self.underWearTrr[i].stage:hide() --阶位字段隐藏
		self.underWearTrr[i].btnTrr:setText(str)	--装备中 不可点击
		
		self.underWearTrr[i].btn:setTouchEnabled(self.BtnType[i][1]~= 3)
		--self.underWearTrr[i].bg_btn:setTouchEnabled(self.BtnType[i][1]~= 1) --未解锁的不可点击
	end
	
end

function wnd_underwear:updateModule(armorId, armorStage)
	self:changeArmorEffect(self.underWearTrr[armorId].effect,  armorId, armorStage,true)
end
function wnd_underwear:openLevelUp(sender,tab)
	 local tag = sender:getTag() -2000
	if self.BtnType[tag][1] ==1 then
		--g_i3k_ui_mgr:PopupTipMessage("请先解锁")
		 --todo 前往解锁
	   g_i3k_logic:OpenUnderWearUnlock(tag)
	else
		g_i3k_logic:OpenUnderWearUpdate(tag, self.tab[tag])
		self:onCloseUI()
	end
	
	
end

function wnd_underwear:openUnderWear(sender,tab)
	local tag = sender:getTag() -1000
	if self.BtnType[tag][1] ==1 then
	 --todo 前往解锁
	   g_i3k_logic:OpenUnderWearUnlock(tag)
	elseif self.BtnType[tag][1] ==2 then
		--TODO装备此内甲
		i3k_sbean.equipArmor(tag,tab)
	elseif self.BtnType[tag][1] ==3 then	
		--装备中 不可点击
	end	
end

function wnd_underwear:updateModulePlay(armorType)
	local data
	local standData 
	if i3k_db_under_wear_cfg[armorType] then
		data =  i3k_db_under_wear_cfg[armorType].playCelebrateAction
		standData =  i3k_db_under_wear_cfg[armorType].playStandbyAction
	end
	
	if data and standData then
		for i,v in ipairs(data)	do
			self.underWearTrr[armorType].effect:pushActionList(v, 1)
		end
		self.underWearTrr[armorType].effect:pushActionList(standData[1],-1)
		self.underWearTrr[armorType].effect:playActionList()
	else
		self.underWearTrr[armorType].effect:playAction("stand")
	end
end

function wnd_underwear:hideSelfArmorEffect(  )
	--隐藏自己的要存服务器
	local check = self._layout.vars.hide_self_check
	check:setVisible(not g_i3k_game_context:getArmorHideEffect())
	i3k_sbean.hide_self_armor_effect(not g_i3k_game_context:getArmorHideEffect())
end

function wnd_underwear:hideAllArmorEffect(  )
	--隐藏所有人的要存本地
	local cfg = g_i3k_game_context:GetUserCfg()
	local isHide = cfg:SetIsHideAllArmorEffect(not cfg:GetIsHideAllArmorEffect())
	self._layout.vars.hide_all_check:setVisible(isHide)
	local world = i3k_game_get_logic():GetWorld()
	world:SetAllArmorEffect()
end


function wnd_underwear:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear)
end

function wnd_create(layout)
	local wnd = wnd_underwear.new();
	wnd:create(layout);
	return wnd;
end


