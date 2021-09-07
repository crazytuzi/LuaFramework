--作者:hzf
--16-9-27 下10时40分45秒
--功能:联赛介绍

GuildLeagueDescPanel = GuildLeagueDescPanel or BaseClass(BasePanel)
function GuildLeagueDescPanel:__init(parent, Main)
	self.parent = parent
	self.Main = Main
	self.resList = {
		{file = AssetConfig.guildleague_desc_panel, type = AssetType.Main}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
end

function GuildLeagueDescPanel:__delete()
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function GuildLeagueDescPanel:OnHide()

end

function GuildLeagueDescPanel:OnOpen()

end

function GuildLeagueDescPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_desc_panel))
	self.gameObject.name = "GuildLeagueDescPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
	self.bgImage = self.transform:Find("bgImage"):GetComponent(Image)
	self.LevText = self.transform:Find("LevText"):GetComponent(Text)
	self.Desc = self.transform:Find("MaskScroll/Desc"):GetComponent(Text)
	-- self.ExtDesc = self.transform:Find("ExtDesc"):GetComponent(Text)
	self.Desc.text = TI18N(
		[[赛制规则：
1、世界等级达到<color='#ffff00'>65后</color>开启冠军联赛，预选赛为<color='#ffff00'>公会攻城战</color>模式，每周安排1次跨服对阵
2、预选赛：联赛划分为<color='#ffff00'>甲级、乙级和丙级3个级别</color>，并各分为8个（丙级为16个）小组，小组内依次对战3场
3、各小组前2名的队伍将晋级，其中甲级小组前2名的队伍进入<color='#ffff00'>冠军赛</color>比拼，其余公会则进入<color='#ffff00'>资格赛</color>环节
4、资格赛：与<color='#ffff00'>冠军赛</color>同步开赛，甲乙丙各小组重新分配，依次对战3场后：
		冠军组16名公会与资格赛甲组前16名，将获得下一赛季甲组资格
		资格赛甲组17~32名与资格赛乙组前16名，将获得下一赛季乙组资格
		资格赛乙组17~32名与资格赛丙组前16名，将获得下一赛季丙组资格
		丙组剩余32个名额，将根据公会实力排名，重新划分
5、<color='#ffff00'>冠军赛</color>：分为<color='#ffff00'>1/8决赛、1/4决赛、半决赛、决赛</color>共4场，决赛安排在半决赛后<color='#ffff00'>周一21:30</color>进行，夺冠公会将赢得<color='#ffff00'>冠军奖杯</color>
6、<color='#ffff00'>[冠军联赛奖杯]</color>将在每届冠军公会中流转，奖杯永久篆刻历届夺冠公会名称、流芳百世

战场规则：
1、每场比赛中双方公会各拥有<color='#ffff00'>3座水晶塔</color>，<color='#ffff00'>按顺序</color>摧毁对方3座水晶塔即可获得本场<color='#ffff00'>胜利</color>
2、比赛开始<color='#ffff00'>12</color>分钟时，<color='#ffff00'>战场大炮</color>准备就绪，成功开炮可对敌方水晶塔造成大量伤害
3、获胜的玩家可打开战场胜利宝箱，获胜公会将根据摧毁对方水晶程度获得一定积分
4、注意：双方参战人数<color='#ffff00'>上限</color>均为<color='#ffff00'>100人</color>，请在准备厅合理安排参战人员及战略
5、战斗中将根据双方<color='#ffff00'>平均等级</color>差距，给予落后方一定属性补偿（仅弥补等级上的弱势）

公会实力计算公式：
(前20名活跃玩家平均战力*30+活跃人数总战力(最大算100人))*(1+(前20名平均等
级-80)/40)]]
	)
	self.Desc.gameObject.transform.sizeDelta = Vector2(670, self.Desc.preferredHeight+0.4)
-- 	self.ExtDesc.text = TI18N(
-- 		[[战场规则：
-- 1、每场比赛中双方公会各拥有<color='#ffff00'>3座水晶塔</color>，<color='#ffff00'>按顺序</color>摧毁对方3座水晶塔即可获得本场<color='#ffff00'>胜利</color>
-- 2、比赛开始<color='#ffff00'>12</color>分钟时，<color='#ffff00'>战场大炮</color>准备就绪，成功开炮可对敌方水晶塔造成大量伤害
-- 		]]
-- 		)
end