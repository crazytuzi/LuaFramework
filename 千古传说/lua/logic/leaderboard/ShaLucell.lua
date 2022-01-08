
local ShaLucell = class("ShaLucell", BaseLayer)

function ShaLucell:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.Leaderboard.Leaderboardcell_shalubang")

end

function ShaLucell:initUI( ui )

	self.super.initUI(self, ui)

	self.bg = TFDirector:getChildByPath(ui, "bg")
	self.bg.logic = self
	self.bg:setTouchEnabled(true)
	
	
	--选择框设置不可见
	self.bg_select = TFDirector:getChildByPath(ui, "bg_select")
	self.bg_select:setVisible(false)

	self.Img_paiming = TFDirector:getChildByPath(ui, "Img_paiming")
	self.txt_paiming = TFDirector:getChildByPath(ui, "txt_paiming")
	self.txt_name = TFDirector:getChildByPath(ui, "txt_name")
	self.txt_zhandouli = TFDirector:getChildByPath(ui, "txt_zhandouli")
	self.txt_zhandouli_word = TFDirector:getChildByPath(ui, "txt_zhandouli_word")
	self.Btn_tiaozhan = TFDirector:getChildByPath(ui, "Btn_tiaozhan")
	self.Img_chenhao = TFDirector:getChildByPath(ui, "Img_chenhao")
	self.txt_cengshu = TFDirector:getChildByPath(ui, "txt_cengshu")
	self.img_ytz = TFDirector:getChildByPath(ui, "img_ytz")


	self.btn_more = TFDirector:getChildByPath(ui, "btn_more")
	self.btn_more.logic = self
	self.btn_more:setVisible(false)

	self.Btn_tiaozhan.logic = self

	self.Img_paiming_data = {'ui_new/leaderboard/no1.png','ui_new/leaderboard/no2.png','ui_new/leaderboard/no3.png'}
	self.Img_chenhao_Textures = {
		'ui_new/leaderboard/n1.png',
		'ui_new/leaderboard/n2.png',
		'ui_new/leaderboard/n3.png',
		'ui_new/leaderboard/n4.png',
		'ui_new/leaderboard/n5.png',
		'ui_new/leaderboard/n6.png',
		'ui_new/leaderboard/n7.png',
		'ui_new/leaderboard/n8.png',
		'ui_new/leaderboard/n9.png',
		'ui_new/leaderboard/n10.png'}
end

function ShaLucell:removeUI()
	self.super.removeUI(self)	
end

function ShaLucell:registerEvents()
	self.super.registerEvents(self)

	self.btn_more:addMEListener(TFWIDGET_CLICK, audioClickfun(self.GetMoreButtonClick))

	self.Btn_tiaozhan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnTiaoZhanClick))

	self.bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.touchBgCell))
end

function ShaLucell:dispose()
	 self:removeEvents()
	 self:removeUI()
end

function ShaLucell:removeEvents()
    self.super.removeEvents(self)
end

function ShaLucell:SetData(layer,item)
	
	self.layer = layer
	self.item = item

	if item == nil then
		--加载更多
		self.moreBtnType = true
		self.bg:setVisible(false)
		self.btn_more:setVisible(true)
	else
		self.moreBtnType = false
		self.bg:setVisible(true)
		self.btn_more:setVisible(false)
		local limitNum = ConstantData:objectByID("Kill.challenge.num").value
		if item.ranking <= limitNum and item.playerId ~= MainPlayer:getPlayerId() then
			if RankManager:canTiaoZhan(item.playerId) == true then
				self.img_ytz:setVisible(false)
				self.Btn_tiaozhan:setVisible(true)
				local teamLev = MainPlayer:getLevel()
			    local openLev = FunctionOpenConfigure:getOpenLevel(2203)
			    if teamLev < openLev then
			    	self.Btn_tiaozhan:setVisible(false)
			    else
			    	self.Btn_tiaozhan:setVisible(true)
			    end
			else
				self.img_ytz:setVisible(true)
				self.Btn_tiaozhan:setVisible(false)
			end
		else
			self.Btn_tiaozhan:setVisible(false)
			self.img_ytz:setVisible(false)
		end

		self.Btn_tiaozhan.playerId = item.playerId

		--设置选中框是否可见
		if item.ranking == layer.cell_select_index then
			self.bg_select:setVisible(true)
		else
			self.bg_select:setVisible(false)
		end
		self.txt_name:setString(item.name)
		self.txt_zhandouli_word:setString(item.massacreValue)

		--设置名次
		if item.ranking <= 3 then
			self.Img_paiming:setVisible(true)
			self.Img_paiming:setTexture(self.Img_paiming_data[item.ranking])
			self.txt_paiming:setVisible(false)
		else
			self.Img_paiming:setVisible(false)
			self.txt_paiming:setVisible(true)
			self.txt_paiming:setString(item.ranking)
		end

		--设置称号
		local rankingHero = RankManager:isInTen(item.playerId)
		if rankingHero > 10 then
			self.Img_chenhao:setVisible(false)
		else
			self.Img_chenhao:setVisible(true)
			self.Img_chenhao:setTexture(self.Img_chenhao_Textures[rankingHero]) 
		end
	end

end

function ShaLucell:setChoiseVisiable( enable )
	self.bg_select:setVisible(enable)
end
function ShaLucell.GetMoreButtonClick(btn)
	local self = btn.logic
	self.layer:UpdateList()	
end

function ShaLucell.OnTiaoZhanClick(btn)
	AdventureManager:openShaluVsLayer(btn.playerId,AdventureManager.fightType_2)
	--RankManager:pushTiaoZhanId(btn.playerId)
end

function ShaLucell.touchBgCell( btn )
	local self = btn.logic
	self.layer:tableCellSelect(self.item.ranking)
end

function ShaLucell:isMoreButton()
	return self.moreBtnType
end

return ShaLucell