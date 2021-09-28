-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedSkillUpLevel = i3k_class("wnd_steedSkillUpLevel", ui.wnd_base)

local LAYER_JNSJT1 = "ui/widgets/jnsjt1"

--标题图片
JINENGSJ_TITLE = 2078--186
UNIQUESKILL_TITLE = 2079
JINGJIESJ_TITLE = 187


function wnd_steedSkillUpLevel:ctor()
	self._skillID = 0
	self._type = nil
	self.need_item = {}
end

function wnd_steedSkillUpLevel:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.up_btn = widgets.up_btn     --升级按钮
	------------------
	self.skillIcon = widgets.skillIcon
	self.name = widgets.name
	self.level = widgets.level
	-------------------
	

	--self.next_level = widgets.next_level
	self.now_effect = widgets.now_effect	--当前效果标题
	self.next_effect = widgets.next_effect --下级效果标题
	self.title_desc = widgets.title_desc
	--self.use_item = widgets.use_item	
	self.desc1 = widgets.desc1   --当前效果描述
	self.desc2 = widgets.desc2		--下级效果描述
	self.scroll3 = widgets.scroll3   --消耗材料
	self.c_jnsj = self._layout.anis.c_jnsj
end

function wnd_steedSkillUpLevel:refresh(index,data)
	self:onSkillTips(data)
	--local cfg = i3k_db_steed_skill_cfg[data.skillCfg[skillId]][data.skillLvl]
	--local needValue = {node = node,skillCfg = skillCfg,skillLvl = needValue.skillLvl,index = index, steedId = needValue.steedId,types = 2}
	
end

function wnd_steedSkillUpLevel:onSkillTips(data)
	self.data = data	
	self._skillId = data.skillCfg.skillId
	self._skillLevel = data.skillLvl
	local cfg = i3k_db_steed_skill_cfg[self._skillId][data.skillLvl]  --data.skillCfg.skillId 骑术id
	self.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(data.skillCfg.iconID))
	self.name:setText(cfg.skillName)
	self.level:setText(data.skillLvl.."级")
	self.desc1:setText(cfg.skillDesc)
	
	local nextCfg =i3k_db_steed_skill_cfg[self._skillId][data.skillLvl+1]
	
	self.need_item = {}
	if nextCfg then
		self.desc2:setText(nextCfg.skillDesc)
		if  nextCfg.useBookId == 0 then
			for i =1,2 do
				local usePropId = string.format("usePropId%s",i)
				local usePropCount = string.format("usePropCount%s",i)
				local tab = {itemID = nextCfg[usePropId] ,itemCount = nextCfg[usePropCount] }
				if nextCfg[usePropId]~= 0 then
					table.insert(self.need_item ,tab)
				end
			end	
		else
			self.need_item = {{itemID = nextCfg.usePropId1 ,itemCount = nextCfg.usePropCount1 },{itemID = nextCfg.useBookId ,itemCount = nextCfg.useBookCount }}
		end
	else
		self.desc2:setVisible(false)
	end
	self:setScrollData()
	self.up_btn:setTouchEnabled(true)
	self.up_btn:onClick(self,self.onUpSkill)
	self:isMaxLevel(nextCfg)
end 

function wnd_steedSkillUpLevel:isMaxLevel(nextCfg)
	if not nextCfg then
	local delay = cc.DelayTime:create(0.5)
	local seq = cc.Sequence:create(delay,cc.CallFunc:create(function ()
		g_i3k_ui_mgr:PopupTipMessage("恭喜你，已达到最大级别")
		g_i3k_ui_mgr:CloseUI(eUIID_steedSkillUpLevel)
	end))
	self:runAction(seq)
	end
	
end

function wnd_steedSkillUpLevel:setScrollData()
	self.useProp = {}
	self.scroll3:removeAllChildren()
	for i=1, #self.need_item do
		local itemID = self.need_item[i].itemID
		local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemID)
		local _layer = require(LAYER_JNSJT1)()
		local widgets1 = _layer.vars
		widgets1.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemID))
		widgets1.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID,i3k_game_context:IsFemaleRole()))
		widgets1.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemID))
		widgets1.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
		local item = g_i3k_db.i3k_db_get_other_item_cfg(itemID)
		if item and item.type == UseItemHorseBook then
			widgets1.item_count:setText(g_i3k_game_context:SearchHorseBook(itemID).."/"..self.need_item[i].itemCount)
			widgets1.item_count:setTextColor(g_i3k_get_cond_color(self.need_item[i].itemCount <= g_i3k_game_context:SearchHorseBook(itemID)))
		else
			widgets1.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(itemID).."/"..self.need_item[i].itemCount)
			widgets1.item_count:setTextColor(g_i3k_get_cond_color(self.need_item[i].itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(itemID)))
		end
		widgets1.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		widgets1.tip_btn:onClick(self, self.itemTips, itemID)
		self.scroll3:addItem(_layer)
		local data = {itemid =self.need_item[i].itemID, itemCount = self.need_item[i].itemCount}
		table.insert(self.useProp , i ,data)
	end
end

function wnd_steedSkillUpLevel:onUpSkill(sender, skillID)
	
	if not  i3k_db_steed_skill_cfg[self._skillId][self._skillLevel+1] then
		g_i3k_ui_mgr:PopupTipMessage("恭喜你，已达到最大级别")
		--g_i3k_ui_mgr:CloseUI(eUIID_steedSkillUpLevel)
		return
	end
	if g_i3k_game_context:isUpSteedSkillEnough(self._skillId,self._skillLevel,1) then 
		self.up_btn:setTouchEnabled(false)
		--i3k_sbean.goto_skill_levelup(skillID, skill_lv+1, self.need_item , false,self._unique)
		i3k_sbean.steed_skill_upLevel(self._skillId ,self._skillLevel+1,self.useProp ,self.data)
		--g_i3k_ui_mgr:PopupTipMessage("材料充足可以升级")
	else
		g_i3k_ui_mgr:PopupTipMessage("材料不足无法升级")
	end
end

function wnd_steedSkillUpLevel:playUpLevelEffect(needValue)
	
	local delay = cc.DelayTime:create(0.4)
	local seq = cc.Sequence:create(cc.CallFunc:create(function ()
	self.c_jnsj.play() 
	end),delay,cc.CallFunc:create(function ()
	self:onSkillTips(needValue)
	end))
	self:runAction(seq)
end

function wnd_steedSkillUpLevel:itemTips(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_create(layout)
	local wnd = wnd_steedSkillUpLevel.new()
	wnd:create(layout)
	return wnd
end
