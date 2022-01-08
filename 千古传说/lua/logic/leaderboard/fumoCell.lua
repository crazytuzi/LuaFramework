
local fumoCell = class("fumoCell", BaseLayer)

function fumoCell:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.Leaderboard.Leaderboardcell_fumobang")

end

function fumoCell:initUI( ui )

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
	self.Btn_zan = TFDirector:getChildByPath(ui, "Btn_zan")
	self.Btn_huifang = TFDirector:getChildByPath(ui, "Btn_huifang")	
	self.txt_zan = TFDirector:getChildByPath(ui, "txt_zan")
	self.Img_chenhao = TFDirector:getChildByPath(ui, "Img_chenhao")
	self.txt_cengshu = TFDirector:getChildByPath(ui, "txt_cengshu")


	self.btn_more = TFDirector:getChildByPath(ui, "btn_more")
	self.btn_more.logic = self
	self.btn_more:setVisible(false)



	self.Btn_zan.logic = self
	self.Btn_huifang.logic = self

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

function fumoCell:removeUI()
	self.super.removeUI(self)	
end

function fumoCell:registerEvents()
	self.super.registerEvents(self)

	self.btn_more:addMEListener(TFWIDGET_CLICK, audioClickfun(self.GetMoreButtonClick))

	self.Btn_zan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ZanButtonClick))
	self.Btn_huifang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ReplayeClick))

	self.bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.touchBgCell))
end

function fumoCell:dispose()
	 self:removeEvents()
	 self:removeUI()
end
function fumoCell:removeEvents()

    self.super.removeEvents(self)

    self.btn_more:removeMEListener(TFWIDGET_CLICK)
    self.Btn_zan:removeMEListener(TFWIDGET_CLICK)
    self.Btn_huifang:removeMEListener(TFWIDGET_CLICK)
    self.bg:removeMEListener(TFWIDGET_CLICK)
end

function fumoCell:SetData(layer,item)
	
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

		self.Btn_huifang.replayID = item.replayId
		--设置选中框是否可见
		print('item.replayId = ',item.replayId)
		if item.ranking == layer.cell_select_index then
			self.bg_select:setVisible(true)
		else
			self.bg_select:setVisible(false)
		end

		--设置zan按钮是否有效
		if NiuBilityManager:isCanPraise(item.playerId) then
			self.Btn_zan:setTouchEnabled(true)
			self.Btn_zan:setTextureNormal('ui_new/leaderboard/btn_zan.png')
		else
			self.Btn_zan:setTouchEnabled(false)
			self.Btn_zan:setTextureNormal('ui_new/leaderboard/btn_zan2.png')
		end

		--设置录像按钮
		if item.replayId and item.replayId ~= 0 then
			self.Btn_huifang:setVisible(true)
		else
			self.Btn_huifang:setVisible(false)
		end

		--设置赞的个数
		--self.txt_zan:setString(item.goodNum.."赞")
		self.txt_zan:setString(stringUtils.format(localizable.common_zan,item.goodNum))

		--self.txt_zhandouli:setText("战斗力:")
		self.txt_zhandouli:setText(localizable.common_ce_text)
		if layer.btn_curr_type == RankListType.Rank_List_fumo then
			--设置附魔榜显示层数
			self.txt_name:setString(item.name)
			self.txt_cengshu:setVisible(false)
			--self.txt_zhandouli:setText("最高伤害:")
			self.txt_zhandouli:setText(localizable.common_max_hurt)
			self.txt_zhandouli:setVisible(true)
			self.txt_zhandouli_word:setVisible(true)
			self.txt_zhandouli_word:setString(item.totalDamage)
			print("totalDamage"..item.totalDamage)

		elseif layer.btn_curr_type == RankListType.Rank_List_Wuliang then
			--设置无量榜显示层数
			self.txt_name:setString(item.name)
			self.txt_zhandouli:setVisible(false)
			self.txt_zhandouli_word:setVisible(false)
			self.txt_cengshu:setVisible(true)
			--self.txt_cengshu:setString(item.value.."层")
			self.txt_cengshu:setString(stringUtils.format(localizable.common_ceng,item.value))			
		else
			self.txt_name:setString(item.name)
			self.txt_cengshu:setVisible(false)
			self.txt_zhandouli:setVisible(true)
			self.txt_zhandouli_word:setVisible(true)
			self.txt_zhandouli_word:setString(item.power)
		end	

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

function fumoCell:setChoiseVisiable( enable )
	self.bg_select:setVisible(enable)
end
function fumoCell.GetMoreButtonClick(btn)

	local self = btn.logic
	self.layer:UpdateList()	
end

function fumoCell.ZanButtonClick(btn)
	
	local self = btn.logic
	if self.layer:UpdateZanNum(self.item.playerId) == true then
		self.Btn_zan:setTouchEnabled(false)
		self.Btn_zan:setTextureNormal('ui_new/leaderboard/btn_zan2.png')
	end
end

function fumoCell.touchBgCell( btn )
	local self = btn.logic
	self.layer:tableCellSelect(self.item.ranking)
end

function fumoCell:isMoreButton()
	return self.moreBtnType
end

function fumoCell.ReplayeClick( btn )
	if btn and (btn.replayID and btn.replayID ~= 0) then
		showLoading()
        TFDirector:send(c2s.PLAY_ARENA_TOP_BATTLE_REPORT, {btn.replayID})
        print('btn.replayID = ',btn.replayID)
	else
		print('cannot find replay id = ',btn.replayID)
	end
end
return fumoCell