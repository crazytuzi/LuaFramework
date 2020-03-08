local tbUi = Ui:CreateClass("FiveElements3")
tbUi.tbSeries = {
	"Gold",
	"Wood",
	"Water",
	"Fire",
	"Earth",
}
tbUi.tbFactionHistory = {
	"天王帮由南朝义军天王之女杨瑛所创。由钟相、杨幺大楚政权的余部组织而成，继承了其宗教传统，信奉道教，尤尊吕仙人，平时炼药修身，习武行侠，战时人人皆能持兵上阵。",
	"在天下女子所创的武林门派中，以峨嵋派为第一，其弟子均为女性。峨嵋派门规极严，门下弟子非常洁身自好，不仅武功高强，而且多才多艺，琴棋书画无所不通。",
	"桃花岛位于东海之滨的， 由被誉为天下第一才女的黄暮云所创立，桃花岛上弟子均为女性，桃花岛的一手弓术威力无比， 不逊色于唐门机关弩机。",
	"数百年前，天纵之才的逍遥子创立逍遥派，门人弟子也均是天之骄子，文武双全，后曾衰落。当代掌门玄空子悟得逍遥派武学精要，重振逍遥，自此逍遥派长盛不衰，至今已又是百年。",
	"武当派弟子均为男性，以侠义名满天下，同门之间极重情义。此派虽然属于道教全真一派，但却直属麻衣道人、陈搏、火龙真人一系，派中弟子无须斋戒，可以婚配。",
	"天忍教是金国为了对付宋国武林人士而创建的组织，信奉的是金国的国教萨满教，创派教主是金国国师完颜洪烈，教中高手无数，还招募了宋国一些邪派高手和正派的叛徒。",
	"武林名门正派之首，门中弟子诵经练武，武功高强，富有正义感。此派弟子均为男性，分为出家弟子和俗家弟子两类，出家弟子在寺中修行，俗家弟子分散各处，行侠仗义。",
	"翠烟门与唐门并称“武林二门”，门中弟子多绝色，因其神秘色彩而名动江湖，是江湖男子的一个迷离的美梦，对江湖男子而言，翠烟门到底是地狱还是天堂，谁也说不清。",
	"唐门与翠烟门并称“武林二门”，世代居于四川唐家堡，是一个家族式的江湖门派，很少同外界接触。他们只生活在自己的世界里。既不愿与名门正派结交，也不屑与邪魔歪道为伍。",
	"昆仑派居于西域，实力强劲，隐隐有与少林、武当、峨嵋相抗衡之意。门中弟子有男有女，虽然信奉道教，但主要是指利用茅山道士的法术，弟子允许婚配，不禁荤食。",
	"丐帮的历史非常久远，从宋初开始就有天下第一帮的称号，帮中卧虎藏龙，人才辈出。丐帮由于弟子众多，性格、出身各有不同，因此帮规极严，帮中等级分明、戒律严谨。",
	"五毒教是近年来才在武林中突然兴起的新兴教派。组织严密，巢穴十分隐蔽，教徒行踪诡秘，轻易不显露身份，再加上五毒教用毒出神入化，杀人于无形，因此江湖中人谈五毒教色变。",
	"大唐神龙元年，叶孟秋于杭州西子湖畔建造了名动天下的藏剑山庄。几百年来藏剑山庄在江湖中都颇有威名。山庄祖师出身书香门第，所以历来要求弟子文武双修，且门人均为用剑高手。",
	"唐武德六年，杨子敬在千岛湖中的其中一个小岛上修筑了相知山庄，这就是长歌门的前身，后成为大唐风雅之地。长歌门门人长老多是当世的名士豪俊，弟子文武双修。",
	"天山派比较特立独行，无心世俗事物，故多年以来天山派弟子基本都隐居在派内，在江湖上走动的不多。天山弟子以凌厉的琴音攻击敌人，性格冷清，有一种遗世而独立的感觉。",
	"五代十国末期，王氏家族一支迁入雍州陇南附近成立了霸刀门。霸刀弟子性格热情，天然带着一股豪气，以凌厉威猛的刀法著称，悍不畏死，有破釜沉舟血战到底的气势。",
	"华山派最早的历史可以追溯至秦汉时代，至今已是武林中声名显赫的名门正派。华山剑术取西岳华山齐、险二字，奇拔峻秀，高远绝伦，招式处处透着「正合奇胜，险中求胜」的意境。",
	"明教初称摩尼教，因自己教义信仰光明，因此改称明教。明教教众均持双刀，刀法繁复，服色尚白，且衣物上多绣火焰，皆素食事明尊，行事颇为神秘，与江湖上其他门派交流无多。",
	"段氏一族原为河西四郡之武威郡人，其武学源于武威佛窟。段氏子弟多深受佛学浸淫，大都以行侠仗义，惩奸除恶为己任，江湖上好评颇多，段氏亦名列名门正派之中。",
	"大唐开元年间万花谷初代谷主于秦岭青岩隐居，招贤纳士，远离朝堂，不问世事，后万花谷逐渐成为江湖上第一风雅之地。万花弟子多使判官笔，一身长衫，儒侠风范。",
	"杨门起于五代鳞州，为报宋氏皇恩，世为宋将，人人以保大宋江山为己任，国事重于一切。杨门弟子金盔银甲，手持长枪，背悬强弓，体型健硕，龙行虎步。",
}
function tbUi:OnOpenEnd()
	local nMyFaction    = me.nFaction
	local nMySex        = me.nSex
	local nMySeries     = KPlayer.GetPlayerInitInfo(nMyFaction, nMySex).nSeries
	local tbRelation    = Npc.tbSeriesRelation[nMySeries]
	local tbSeries      = {tbRelation[2], nMySeries, tbRelation[1]}
	local tbFactionList = {}
	local tbNode        = {"Restrained", "Own", "Restraint"}
	for i, szNode in ipairs(tbNode) do
		local nSeries = tbSeries[i]
		self.pPanel:Sprite_SetSprite(szNode .. "Faction", "FactionSelect_" .. self.tbSeries[nSeries])
		self.pPanel:Sprite_SetSprite(szNode .. "Icon", self.tbSeries[nSeries] .. "Mark")
		
		local tbFaction = Faction:GetSeriesFaction(nSeries)
		local tbFactionName = {}
		for j = 1, 5 do
			local nFaction = tbFaction[j]
			self.pPanel:SetActive(szNode .. "Faction" .. j, nFaction or false)
			if nFaction then
				self.pPanel:Sprite_SetSprite(szNode .. "Faction" .. j, Faction:GetIcon(nFaction))
				self.pPanel:Label_SetText(szNode .. "FactionName" .. j, Faction:GetName(nFaction))
				if nFaction ~= nMyFaction then
					table.insert(tbFactionName, Faction:GetName(nFaction))
				end
			end
		end
		tbFactionList[i] = table.concat(tbFactionName, ", ")
	end
	local szBg = string.format("UI/Textures/FactionSelect/%s", Faction.tbFactionInfo[nMyFaction]["szBackground" .. nMySex])
	self.pPanel:Texture_SetTexture("Texture", szBg)
	self.pPanel:Sprite_SetSprite("FactionInfo", Faction:GetFactionSchoolIcon(nMyFaction))
	local szIntroduce = string.format("门派历史：\n%s\n\n门派特色：\n门派与%s同属%s系，被%s系的%s克制，克制%s系的%s",
		self.tbFactionHistory[nMyFaction],
		tbFactionList[2], Npc.Series[nMySeries],
		Npc.Series[tbRelation[2]], tbFactionList[1],
		Npc.Series[tbRelation[1]], tbFactionList[3])
	self.pPanel:Label_SetText("Introduce", szIntroduce)
end

tbUi.tbOnClick = {
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end
}