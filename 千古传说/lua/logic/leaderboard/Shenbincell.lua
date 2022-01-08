
local Shenbincell = class("Shenbincell", BaseLayer)

function Shenbincell:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.Leaderboard.Leaderboardcell_shenbingbang")

end

function Shenbincell:initUI( ui )

	self.super.initUI(self, ui)

	self.bg = TFDirector:getChildByPath(ui, "bg")

	self.bg_select = TFDirector:getChildByPath(ui, "bg_select")
	--选择框设置不可见
	self.bg_select:setVisible(false)

	self.Img_paiming = TFDirector:getChildByPath(ui, "Img_paiming")
	self.txt_paiming = TFDirector:getChildByPath(ui, "txt_paiming")
	self.txt_name = TFDirector:getChildByPath(ui, "txt_name")
	self.txt_zhandouli = TFDirector:getChildByPath(ui, "txt_zhandouli")
	self.txt_zhandouli_word = TFDirector:getChildByPath(ui, "txt_zhandouli_word")
	self.Btn_zan = TFDirector:getChildByPath(ui, "Btn_zan")
	self.txt_zan = TFDirector:getChildByPath(ui, "txt_zan")
	self.txt_chiyouzhe = TFDirector:getChildByPath(ui, "txt_chiyouzhe")
	self.img_quality = TFDirector:getChildByPath(ui, "img_quality")
	self.img_icon = TFDirector:getChildByPath(ui, "img_icon")
	self.txt_intensify_lv = TFDirector:getChildByPath(ui, "txt_intensify_lv")

	self.panel_star = TFDirector:getChildByPath(ui, "panel_star")
	self.img_star = {}
    for i=1,5 do
    	self.img_star[i] = TFDirector:getChildByPath(ui, "img_star_"..i)
    end
    self.img_gembg = TFDirector:getChildByPath(ui, "img_gembg") 
	self.img_gem = TFDirector:getChildByPath(ui, "img_gem")
	self.btn_more = TFDirector:getChildByPath(ui, "btn_more")
	self.btn_more.logic = self
	self.btn_more:setVisible(false)

	self.Img_paiming_data = {'ui_new/leaderboard/no1.png','ui_new/leaderboard/no2.png','ui_new/leaderboard/no3.png'}
	self.sort = nil

	self.layer = nil

	self.Btn_zan.logic = self
end

function Shenbincell:removeUI()
	self.super.removeUI(self)
end

function Shenbincell:registerEvents()
	self.super.registerEvents(self)

	self.btn_more:addMEListener(TFWIDGET_CLICK, audioClickfun(self.GetMoreButtonClick))
	self.Btn_zan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ZanButtonClick))
end

function Shenbincell:removeEvents()

    self.super.removeEvents(self)

    self.btn_more:removeMEListener(TFWIDGET_CLICK)
    self.Btn_zan:removeMEListener(TFWIDGET_CLICK)
end

function Shenbincell:SetData(layer,item)



	self.layer = layer
	if item == nil then
		--加载更多
		self.bg:setVisible(false)
		self.btn_more:setVisible(true)
		self.img_quality:setVisible(false)
	else

		self.bg:setVisible(true)
		self.btn_more:setVisible(false)
		self.img_quality:setVisible(true)

		--设置选中框是否可见
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

		self.sort = item.ranking

		--设置赞的个数
		--self.txt_zan:setString(item.goodNum.."赞")
		self.txt_zan:setString(stringUtils.format(localizable.common_zan,item.goodNum))

		self.txt_name:setString(item.name)
		self.txt_zhandouli_word:setString(item.value)

		

		local itemData = ItemData:objectByID(item.goodsId)
		self.img_quality:setTexture(GetColorIconByQuality(itemData.quality))
		self.img_icon:setTexture(itemData:GetPath())
		self.txt_intensify_lv:setText("+"..item.intensifyLevel)

	    for i=1,item.starLevel do
	    	self.img_star[i]:setVisible(true)
	    end
	    for i=item.starLevel+1,5 do
	    	self.img_star[i]:setVisible(false)
	    end

	    local gemData = ItemData:objectByID(item.gemId)
	    if gemData then
	    	self.img_gembg:setVisible(true)
			self.img_gem:setTexture(gemData:GetPath())
		else
			self.img_gembg:setVisible(false)
		end

		--设置称号
		if item.ranking <= 3 then
			self.Img_paiming:setVisible(true)
			self.Img_paiming:setTexture(self.Img_paiming_data[self.sort])
			self.txt_paiming:setVisible(false)
		else
			self.Img_paiming:setVisible(false)
			self.txt_paiming:setVisible(true)
			self.txt_paiming:setString(self.sort)
		end
	end
end

function Shenbincell.GetMoreButtonClick(btn)
	local self = btn.logic

	self.layer:UpdateList()
end

function Shenbincell.ZanButtonClick(btn)

	local self = btn.logic
	self.layer:UpdateZanNum(self.sort)

end

return Shenbincell