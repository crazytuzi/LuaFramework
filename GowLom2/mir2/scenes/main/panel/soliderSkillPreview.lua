local soliderSkillPreview = class("soliderSkillPreview", import(".panelBase"))
local tip = import(".wingInfo")
local widgetDef = g_data.widgetDef
local iconFunc = import("..console.iconFunc")
local skillDesc = {
	[0] = {
		[3] = {
			icon = "66",
			desc2 = "释放烈火剑法时几率触发，以目标为中心，使3*3范围内的目标受到1.2倍烈火剑法的伤害。",
			desc1 = "凤凰升级至一阶十星，使用烈火剑法时，有几率触发怒之烈火。",
			skillName = "怒之烈火",
			needSkill = "烈火剑法",
			needLevel = 10
		}
	},
	{
		[3] = {
			icon = "67",
			desc2 = "释放流星火雨时几率触发，它将召唤两次火雨坠落，伤害值为流星火雨的1.8倍。",
			desc1 = "凤凰升级至一阶十星，释放流星火雨时，有几率触发怒之火雨。",
			skillName = "怒之火雨",
			needSkill = "流星火雨",
			needLevel = 10
		}
	},
	{
		[2] = {
			icon = "68",
			desc2 = "召唤怒之圣兽作为自己的随从，怒之圣兽对圣言术有一定的抵抗，主人的等级越高，抵抗的几率也越高。",
			desc1 = "太虚升级至三阶十星，可召唤强大的怒之圣兽作为随从。",
			skillName = "怒之圣兽",
			needSkill = "召唤神兽",
			needLevel = 30
		},
		[3] = {
			icon = "69",
			desc2 = "释放噬血术时几率触发，以目标为中心，使3*3范围内的目标受到1.2倍噬血术的伤害。",
			desc1 = "凤凰升级至一阶十星，释放噬血术时，有几率触发怒之噬血。",
			skillName = "怒之噬血",
			needSkill = "噬血术",
			needLevel = 10
		}
	}
}
soliderSkillPreview.ctor = function (self, soliderId)
	self.super.ctor(self)

	self.id = soliderId
	self.job = g_data.player.job

	self.setMoveable(self, true)

	return 
end
soliderSkillPreview.onEnter = function (self)
	self.initPanelUI(self, {
		title = "怒之技能",
		bg = "pic/panels/wingUpgrade/previewBg.png"
	})
	self.pos(self, display.cx + 320, display.cy)
	self.loadMainPage(self)

	return 
end
soliderSkillPreview.loadMainPage = function (self)
	self.content = self.bg
	local cfg = skillDesc[self.job][self.id]

	if not cfg then
		return 
	end

	local posY = self.content:geth() - 53
	local showNode = display.newSprite(res.gettex2("pic/panels/wingUpgrade/previewItem.png")):add2(self.content):anchor(0, 1):pos(20, posY)
	local magicId = nil
	magicId = def.magic.getMagicIdByName(cfg.needSkill, self.job)

	if magicId < 0 then
		print("需要的技能名称配置不正确")

		return 
	end

	local soliderInfo = g_data.solider:getSoliderInfo(self.id)
	local skillLvl = soliderInfo.level

	an.newLabel(cfg.skillName, 20, 1, {
		color = def.colors.title
	}):anchor(0, 0.5):pos(67, 48):addto(showNode)

	if skillLvl < cfg.needLevel then
		an.newLabel("未学习", 20, 1, {
			color = def.colors.Cf0c896
		}):anchor(0, 0.5):pos(67, 22):addto(showNode)
	else
		an.newLabel("已学习", 20, 1, {
			color = def.colors.Cf0c896
		}):anchor(0, 0.5):pos(67, 22):addto(showNode)
	end

	local filter = nil

	if skillLvl < cfg.needLevel then
		filter = res.getFilter("gray")
	end

	display.newSprite(res.gettex2("pic/console/iconbg6.png")):pos(37, 37):add2(showNode)

	local icon = display.newFilteredSprite(res.gettex2("pic/panels/solider/" .. cfg.icon .. ".png")):pos(37, 37):add2(showNode):scale(0.83)

	if filter then
		icon.setFilter(icon, filter)
	end

	posY = posY - 95

	an.newLabel("技能描述：", 20, 1, {
		color = def.colors.title
	}):anchor(0, 0.5):pos(20, posY):add2(self.content)

	posY = posY - 25
	local lblDesc = an.newLabelM(180, 18, 0, {
		manual = false,
		center = false
	}):add2(self.content):anchor(0, 1):pos(20, posY):nextLine()

	if skillLvl < cfg.needLevel then
		lblDesc.addLabel(lblDesc, cfg.desc1)
	else
		lblDesc.addLabel(lblDesc, cfg.desc2)
	end

	return 
end

return soliderSkillPreview
